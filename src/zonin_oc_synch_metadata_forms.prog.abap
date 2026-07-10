**----------------------------------------------------------------------*
****INCLUDE ZONIN_OC_SYNCH_METADATA_FORMS.
**----------------------------------------------------------------------*
FORM download_json  USING    p_json.
  DATA: lv_filename TYPE string VALUE 'metadata.json',
        lv_path     TYPE string,
        lv_fullpath TYPE string,
        lt_data     TYPE STANDARD TABLE OF string.


  " 1. Convertir string a tabla (líneas)
  SPLIT p_json AT cl_abap_char_utilities=>newline INTO TABLE lt_data.

  " 2. Dialogo para guardar archivo
  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
      default_extension = 'json'
      default_file_name = lv_filename
    CHANGING
      filename          = lv_filename
      path              = lv_path
      fullpath          = lv_fullpath.

  IF lv_fullpath IS NOT INITIAL.

    " 3. Descargar archivo
    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        filename = lv_fullpath
        filetype = 'ASC'
      CHANGING
        data_tab = lt_data.

  ENDIF.
ENDFORM.
*-----------------------------------------------------------*
*& Form f4_domain
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_domain USING p_val.
  TYPES: BEGIN OF st_domain,
           domainv     TYPE zonde_domain,
           description TYPE zonde_description,
         END OF st_domain.

  DATA: lt_ret  TYPE TABLE OF ddshretval,
        lt_data TYPE TABLE OF st_domain,
        ls_data TYPE st_domain,
        lv_dynp TYPE help_info-dynprofld.

  SELECT domainv description
    INTO TABLE lt_data
    FROM zonta_domains
     WHERE spras = sy-langu.

  CONCATENATE 'S_DOM_' p_val INTO lv_dynp.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield    = 'DOMAINV'
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = lv_dynp
      value_org   = 'S'
    TABLES
      value_tab   = lt_data
      return_tab  = lt_ret.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form do_selection_process
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM do_selection_process .

  SELECT *
     INTO TABLE gt_entities
     FROM zonta_obj_oc
     WHERE domainv IN s_dom
       AND business_proc IN s_ent.
  IF sy-subrc NE 0.
    MESSAGE e125(zon_cl_oc).
  ELSE.
    LOOP AT gt_entities INTO gs_entities.
      CLEAR gv_json.

      CREATE OBJECT go_cust
        EXPORTING
          iv_domainv       = gs_entities-domainv
          iv_business_proc = gs_entities-business_proc.

      CALL METHOD go_cust->send_json_metadata
        EXPORTING
          iv_entity = gs_entities-business_proc
          iv_domain = gs_entities-domainv
        IMPORTING
          ev_json   = gv_json.

      IF p_prev = abap_false.
        PERFORM download_json USING gv_json.
      ELSE.
        cl_demo_output=>display_json( json = gv_json ).
      ENDIF.
      FREE go_cust.
    ENDLOOP.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form f4_entity
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_entity USING p_val.

  TYPES: BEGIN OF st_entity,
           domainv TYPE zonde_domain,
           entity  TYPE zonde_process,
         END OF st_entity.

  DATA: lt_ret  TYPE TABLE OF ddshretval,
        lt_data TYPE TABLE OF st_entity,
        ls_data TYPE st_entity,
        lv_dynp TYPE help_info-dynprofld.

  SELECT domainv business_proc AS entity
    INTO TABLE lt_data
    FROM zonta_obj_oc
     WHERE domainv IN s_dom.

  CONCATENATE 'S_ENT_' p_val INTO lv_dynp.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield    = 'BUSINESS_PROC'
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = lv_dynp
      value_org   = 'S'
    TABLES
      value_tab   = lt_data
      return_tab  = lt_ret.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form open_file
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM open_file .

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      field_name = 'P_FILE'
    IMPORTING
      file_name  = gv_file.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form send_json_endpoint
*&---------------------------------------------------------------------*
FORM send_json_endpoint USING p_json TYPE string.
  DATA: lo_client   TYPE REF TO if_http_client,
        lv_status   TYPE i,
        lv_status_c TYPE char10,
        lv_reason   TYPE string,
        lv_response TYPE string,
        lv_msg      TYPE string,
        lv_ok       TYPE abap_bool.

  cl_http_client=>create_by_destination(
    EXPORTING
      destination              = p_dest
    IMPORTING
      client                   = lo_client
    EXCEPTIONS
      argument_not_found       = 1
      destination_not_found    = 2
      destination_no_authority = 3
      plugin_not_active        = 4
      internal_error           = 5
      OTHERS                   = 6
  ).
  IF sy-subrc <> 0.
    MESSAGE 'Could not create HTTP client for SM59 destination' TYPE 'E'.
    RETURN.
  ENDIF.

  lo_client->request->set_method( if_http_request=>co_request_method_post ).
  lo_client->request->set_header_field( name  = 'Content-Type'
                                        value = 'application/json' ).
  lo_client->request->set_cdata( data = p_json ).

  lo_client->send(
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      OTHERS                     = 3
  ).
  IF sy-subrc <> 0.
    lo_client->close( ).
    MESSAGE 'Error sending JSON to endpoint' TYPE 'E'.
    RETURN.
  ENDIF.

  lo_client->receive(
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3
      OTHERS                     = 4
  ).
  IF sy-subrc <> 0.
    lo_client->close( ).
    MESSAGE 'Error receiving response from endpoint' TYPE 'E'.
    RETURN.
  ENDIF.

  lo_client->response->get_status( IMPORTING code   = lv_status
                                             reason = lv_reason ).
  lv_response = lo_client->response->get_cdata( ).
  lo_client->close( ).

  WRITE lv_status TO lv_status_c LEFT-JUSTIFIED.
  CONDENSE lv_status_c.

  IF lv_status >= 200 AND lv_status < 300.
    lv_ok = abap_true.
    CONCATENATE 'JSON sent successfully. HTTP' lv_status_c
      INTO lv_msg SEPARATED BY space.
  ELSE.
    lv_ok = abap_false.
    CONCATENATE 'Error sending JSON. HTTP' lv_status_c ':' lv_reason
      INTO lv_msg SEPARATED BY space.
  ENDIF.

  PERFORM save_send_log       USING lv_status_c lv_reason lv_msg lv_ok.
  PERFORM display_send_result USING lv_msg lv_response.

  IF lv_ok = abap_true.
    MESSAGE lv_msg TYPE 'S'.
  ELSE.
    MESSAGE lv_msg TYPE 'E'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_send_log
*& Persists the send result to BAL using the same object as base handler
*&---------------------------------------------------------------------*
FORM save_send_log
  USING pv_status_c TYPE char10
        pv_reason   TYPE string
        pv_message  TYPE string
        pv_ok       TYPE abap_bool.

  DATA: lv_log_handle TYPE balloghndl,
        ls_log_header TYPE bal_s_log,
        ls_msg        TYPE bal_s_msg.

  ls_log_header-object    = 'ZONI_OC'.
  ls_log_header-subobject = gs_entities-domainv.
  ls_log_header-extnumber = gs_entities-business_proc.

  CALL FUNCTION 'BAL_LOG_CREATE'
    EXPORTING
      i_s_log      = ls_log_header
    IMPORTING
      e_log_handle = lv_log_handle
    EXCEPTIONS
      OTHERS       = 1.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  IF pv_ok = abap_true.
    ls_msg-msgty = 'S'.
  ELSE.
    ls_msg-msgty = 'E'.
  ENDIF.
  ls_msg-msgid = 'FB'.
  ls_msg-msgno = '000'.
  ls_msg-msgv1 = pv_message.   " auto-truncated to CHAR50
  ls_msg-msgv2 = p_dest.
  ls_msg-msgv3 = pv_status_c.

  CALL FUNCTION 'BAL_LOG_MSG_ADD'
    EXPORTING
      i_log_handle = lv_log_handle
      i_s_msg      = ls_msg
    EXCEPTIONS
      OTHERS       = 1.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  CALL FUNCTION 'BAL_DB_SAVE'
    EXPORTING
      i_save_all = abap_true
    EXCEPTIONS
      OTHERS     = 1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_send_result
*& Shows result status and response body in a single cl_demo_output window
*&---------------------------------------------------------------------*
FORM display_send_result
  USING pv_msg      TYPE string
        pv_response TYPE string.

  DATA: lv_output  TYPE string,
        lv_msg_esc TYPE string.

  lv_msg_esc = pv_msg.
  REPLACE ALL OCCURRENCES OF '"' IN lv_msg_esc WITH '\"'.

  IF pv_response IS NOT INITIAL.
    CONCATENATE '{ "result": "' lv_msg_esc '", "response": ' pv_response ' }'
      INTO lv_output.
  ELSE.
    CONCATENATE '{ "result": "' lv_msg_esc '" }'
      INTO lv_output.
  ENDIF.

  cl_demo_output=>display_json( json = lv_output ).
ENDFORM.
