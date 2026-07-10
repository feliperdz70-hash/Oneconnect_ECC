*&---------------------------------------------------------------------*
*& Report ZONPG_ONECONNECT_DELALL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zonpg_oneconnect_delall.


TABLES: zonta_obj_oc.

PARAMETERS: r_dela RADIOBUTTON GROUP g1 DEFAULT 'X',
            r_delt RADIOBUTTON GROUP g1.

DATA: go_json     TYPE REF TO zoncl_fetch_data,
      gt_entities TYPE STANDARD TABLE OF zonta_obj_oc,
      ls_entity   TYPE zonta_obj_oc,
      gx_text     TYPE REF TO cx_root,
      ls_request  TYPE trwbo_request,
      lv_task     TYPE e071-trkorr,
      lt_e071     TYPE STANDARD TABLE OF e071,
      lt_e071k    TYPE STANDARD TABLE OF e071k,
      lt_e070     TYPE STANDARD TABLE OF e070,
      lv_order    TYPE e071-trkorr,
      lv_answer   TYPE c,
      lv_lines    TYPE i,
      lv_text     TYPE string.


SELECT *
  INTO TABLE gt_entities
  FROM zonta_obj_oc.

DESCRIBE TABLE gt_entities LINES lv_lines.

lv_text = | { lv_lines }{ ' - ' }{ TEXT-t01 } |.
CALL FUNCTION 'POPUP_TO_CONFIRM'
  EXPORTING
    text_question  = lv_text
  IMPORTING
    answer         = lv_answer
  EXCEPTIONS
    text_not_found = 1
    OTHERS         = 2.
IF sy-subrc <> 0.
ENDIF.

IF lv_answer = '1' AND lv_lines > 0.
  CALL FUNCTION 'TRINT_ORDER_CHOICE'
    EXPORTING
      wi_order_type          = 'K'
      wi_task_type           = 'S'
      wi_category            = 'SYST'
    IMPORTING
      we_order               = lv_order
      we_task                = lv_task
    TABLES
      wt_e071                = lt_e071
      wt_e071k               = lt_e071k
    EXCEPTIONS
      no_correction_selected = 1
      display_mode           = 2
      object_append_error    = 3
      recursive_call         = 4
      wrong_order_type       = 5
      OTHERS                 = 6.

  CHECK sy-subrc = 0.

* Delete entity structures
  IF r_dela = abap_true.
    LOOP AT gt_entities INTO ls_entity.

      IF go_json IS INITIAL.
        CREATE OBJECT go_json.
      ENDIF.

      CALL METHOD go_json->set_trkorr
        EXPORTING
          iv_tkorr = lv_task.

      TRY.
          CALL METHOD go_json->delete_json_ddic
            EXPORTING
              iv_domainv       = ls_entity-domainv
              iv_business_proc = ls_entity-business_proc
              iv_delete_entity = abap_true.

        CATCH cx_root INTO gx_text.
*            PERFORM send_error_to_screen.
      ENDTRY.

      CLEAR go_json.
    ENDLOOP.

  ENDIF.


  DELETE FROM zonta_oc_col_all.
  DELETE FROM zonta_oc_conv.
  DELETE FROM zonta_oc_ddic .
  DELETE FROM zonta_relations.
  DELETE FROM zonta_obj_oc .
  DELETE FROM zonta_oc_franges .
  DELETE FROM zonta_oc_filters .
  DELETE FROM zonta_oc_auth.

  COMMIT WORK.

  MESSAGE s038(zon_cl_oc) WITH lv_lines.
ENDIF.
* Save deleted entries into transport request
*  PERFORM save_deleted_entity_into_tr.



FORM send_error_to_screen.

  DATA: lo_out        TYPE REF TO if_demo_output,
        lv_text_error TYPE string,
        it_log_ext    TYPE STANDARD TABLE OF zonst_oc_log_ext.

  lo_out = cl_demo_output=>new( ).
  lo_out->begin_section( 'ONE CONNECT EXECUTION LOG' ).

  lo_out->write_data( zonta_obj_oc-business_proc ).

  lo_out->write_data( gx_text->get_text( ) ).
  lo_out->write_data( gx_text->get_longtext( ) ).

  lo_out->display( ).

  lv_text_error = gx_text->get_text( ).

  IF go_json IS BOUND.
    "Log the operation
    go_json->append_slg1_log(
      iv_tabname    = space
      iv_message_v1 = 'ERROR'
      iv_message_v3 = lv_text_error
      iv_mestyp     = 'E' ).
    go_json->return_log_table( IMPORTING et_log_ext = it_log_ext[] ).
    go_json->update_slg1_log( it_log_ext = it_log_ext ).
  ENDIF.

ENDFORM.
