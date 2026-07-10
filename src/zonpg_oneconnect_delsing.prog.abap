*&---------------------------------------------------------------------*
*& Report ZONPG_ONECONNECT_DELSING
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zonpg_oneconnect_delsing.

TABLES: zonta_obj_oc.
*TABLES: gs_entity.

PARAMETERS: r_dela RADIOBUTTON GROUP g1 DEFAULT 'X',
            r_delt RADIOBUTTON GROUP g1.

DATA: go_json     TYPE REF TO zoncl_fetch_data,
      gt_entities TYPE STANDARD TABLE OF zonta_obj_oc,
      gs_entity   TYPE zonta_obj_oc,
      lt_relt     TYPE STANDARD TABLE OF zonta_relations,
      ls_relt     LIKE LINE OF lt_relt,
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

SELECT-OPTIONS: s_domain FOR zonta_obj_oc-domainv,
                s_entity FOR zonta_obj_oc-business_proc.

SELECT *
  INTO TABLE gt_entities
  FROM zonta_obj_oc
  WHERE domainv IN s_domain[]
    AND business_proc IN s_entity[].

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



  LOOP AT gt_entities INTO ls_entity.

    gs_entity = ls_entity.

    CREATE OBJECT go_json.
    IF r_dela = abap_true.

      IF go_json IS INITIAL.
        CREATE OBJECT go_json.
      ENDIF.

      SELECT *
        INTO TABLE lt_relt
        FROM zonta_relations
        WHERE domainv = ls_entity-domainv
         AND  business_proc = ls_entity-business_proc.
      IF sy-subrc = 0.
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
      ENDIF.
    ENDIF.


    LOOP AT lt_relt INTO ls_relt.
      DELETE FROM zonta_oc_col_all WHERE tabname = ls_relt-tabname
                               AND alias_tabname = ls_relt-alias_tabname.

      DELETE FROM zonta_oc_conv  WHERE tabname = ls_relt-tabname
                               AND alias_tabname = ls_relt-alias_tabname.
    ENDLOOP.


    DELETE FROM zonta_oc_ddic  WHERE  domainv        = ls_entity-domainv
                                  AND business_proc  = ls_entity-business_proc.
    DELETE FROM zonta_relations WHERE domainv        = ls_entity-domainv
                                  AND business_proc  = ls_entity-business_proc.
    DELETE FROM zonta_obj_oc WHERE domainv           = ls_entity-domainv
                                  AND business_proc  = ls_entity-business_proc.
    DELETE FROM zonta_oc_franges WHERE domainv       = ls_entity-domainv
                                  AND business_proc  = ls_entity-business_proc.
    DELETE FROM zonta_oc_filters WHERE domainv       = ls_entity-domainv
                                  AND business_proc  = ls_entity-business_proc.
    DELETE FROM zonta_oc_auth WHERE id = ls_entity-id.

    COMMIT WORK.


    CLEAR go_json.
  ENDLOOP.

  MESSAGE s038(zon_cl_oc) WITH lv_lines.
ENDIF.


*&---------------------------------------------------------------------*
*& Form send_error_to_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

FORM send_error_to_screen.

  DATA: lo_out        TYPE REF TO if_demo_output,
        lv_text_error TYPE string,
        it_log_ext    TYPE STANDARD TABLE OF zonst_oc_log_ext.

  lo_out = cl_demo_output=>new( ).
  lo_out->begin_section( 'ONE CONNECT EXECUTION LOG' ).

  lo_out->write_data( gs_entity-business_proc ).

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
