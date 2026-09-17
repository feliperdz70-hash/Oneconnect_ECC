*&---------------------------------------------------------------------*
*& Report ZONRE_OC_DELETE_LOG                                          *
*&         Borrado de logs One Connect                                 *
*&                                                                     *
*&---------------------------------------------------------------------*
*&        ONIBEX                                                       *
*&        September 2026                                               *
*&---------------------------------------------------------------------*
*& Deletes the application logs written by One Connect (transaction     *
*& SLG1, tables BALHDR / BALDAT) with the standard API BAL_DB_SEARCH    *
*& and BAL_DB_DELETE, and optionally the execution logs stored in the   *
*& table ZONTA_OC_EXLOG.                                                *
*&                                                                      *
*& The logs are deleted in packages with an intermediate COMMIT WORK,   *
*& so the report can be scheduled as a periodic housekeeping job.       *
*& The test run is active by default, nothing is deleted until the      *
*& flag is removed.                                                     *
*&---------------------------------------------------------------------*
REPORT zonre_oc_delete_log.

TABLES: balhdr.

TYPES: BEGIN OF ty_result,
         icon       TYPE icon_d,
         lognumber  TYPE balhdr-lognumber,
         object     TYPE balhdr-object,
         subobject  TYPE balhdr-subobject,
         extnumber  TYPE balhdr-extnumber,
         aldate     TYPE balhdr-aldate,
         altime     TYPE balhdr-altime,
         aluser     TYPE balhdr-aluser,
         altcode    TYPE balhdr-altcode,
         alprog     TYPE balhdr-alprog,
         aldate_del TYPE balhdr-aldate_del,
         del_before TYPE balhdr-del_before,
         status     TYPE char40,
       END OF ty_result.

DATA: gt_header  TYPE balhdr_t,
      gt_delete  TYPE balhdr_t,
      gt_date    TYPE bal_r_date,
      gt_result  TYPE STANDARD TABLE OF ty_result
                      WITH NON-UNIQUE DEFAULT KEY
                      WITH UNIQUE SORTED KEY k_log COMPONENTS lognumber,
      gv_test    TYPE abap_bool,
      gv_deleted TYPE i,
      gv_skipped TYPE i,
      gv_error   TYPE i,
      gv_exlog   TYPE i.

CONSTANTS: c_i      TYPE char1  VALUE 'I',
           c_eq     TYPE char2  VALUE 'EQ',
           c_le     TYPE char2  VALUE 'LE',
           c_green  TYPE icon_d VALUE '@08@',
           c_yellow TYPE icon_d VALUE '@09@',
           c_red    TYPE icon_d VALUE '@0A@'.

*&---------------------------------------------------------------------*
*& Selection screen
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01.
  PARAMETERS:     p_obje TYPE balobj_d DEFAULT 'ZONI_OC' OBLIGATORY.
  SELECT-OPTIONS: s_subo FOR balhdr-subobject.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-t02.
  PARAMETERS:     p_days TYPE i DEFAULT 30.
  SELECT-OPTIONS: s_date FOR balhdr-aldate,
                  s_user FOR balhdr-aluser,
                  s_code FOR balhdr-altcode,
                  s_prog FOR balhdr-alprog.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-t03.
  PARAMETERS: p_expi AS CHECKBOX DEFAULT 'X',
              p_prot AS CHECKBOX,
              p_exlo AS CHECKBOX,
              p_test AS CHECKBOX DEFAULT 'X',
              p_pack TYPE i DEFAULT 500,
              p_list AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK b3.

*&---------------------------------------------------------------------*
*& Events
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_subo-low.
  PERFORM get_subobjects CHANGING s_subo-low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_subo-high.
  PERFORM get_subobjects CHANGING s_subo-high.

AT SELECTION-SCREEN.
  PERFORM check_selection.

START-OF-SELECTION.

  PERFORM build_selection.
  PERFORM search_logs.
  PERFORM filter_logs.

  IF gv_test = abap_false AND sy-batch IS INITIAL.
    PERFORM confirm_deletion.
  ENDIF.

  PERFORM delete_logs.

  IF p_exlo = abap_true.
    PERFORM delete_exec_logs.
  ENDIF.

END-OF-SELECTION.

  PERFORM display_result.

*&---------------------------------------------------------------------*
*&      Form  CHECK_SELECTION
*&---------------------------------------------------------------------*
*       Consistency of the selection screen and authorization
*----------------------------------------------------------------------*
FORM check_selection.

  IF p_days > 0 AND s_date[] IS NOT INITIAL.
    MESSAGE e130(zon_cl_oc).
  ENDIF.

  IF p_days < 0.
    MESSAGE e131(zon_cl_oc).
  ENDIF.

  IF p_pack <= 0.
    MESSAGE e132(zon_cl_oc).
  ENDIF.

  AUTHORITY-CHECK OBJECT 'S_APPL_LOG'
    ID 'ALG_OBJECT' FIELD p_obje
    ID 'ALG_SUBOBJ' DUMMY
    ID 'ACTVT'      FIELD '06'.
  IF sy-subrc <> 0.
    MESSAGE e133(zon_cl_oc) WITH p_obje.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  BUILD_SELECTION
*&---------------------------------------------------------------------*
*       Derives the date range from the age in days
*----------------------------------------------------------------------*
FORM build_selection.

  DATA: ls_date TYPE bal_s_date.

  gv_test = p_test.

  IF s_date[] IS INITIAL.
*   Logs older than the requested number of days
    ls_date-sign   = c_i.
    ls_date-option = c_le.
    ls_date-low    = sy-datum - p_days.
    APPEND ls_date TO gt_date.
  ELSE.
    gt_date[] = s_date[].
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SEARCH_LOGS
*&---------------------------------------------------------------------*
*       Reads the log headers from the database (BALHDR)
*----------------------------------------------------------------------*
FORM search_logs.

  DATA: ls_filter TYPE bal_s_lfil,
        lt_object TYPE bal_r_logn,
        ls_object TYPE bal_s_logn,
        lt_subobj TYPE bal_r_sub,
        ls_subobj TYPE bal_s_sub.

  ls_object-sign   = c_i.
  ls_object-option = c_eq.
  ls_object-low    = p_obje.
  APPEND ls_object TO lt_object.

  LOOP AT s_subo.
    CLEAR ls_subobj.
    MOVE-CORRESPONDING s_subo TO ls_subobj.
    APPEND ls_subobj TO lt_subobj.
  ENDLOOP.

  ls_filter-object    = lt_object[].
  ls_filter-subobject = lt_subobj[].
  ls_filter-aldate    = gt_date[].

  CALL FUNCTION 'BAL_DB_SEARCH'
    EXPORTING
      i_s_log_filter     = ls_filter
    IMPORTING
      e_t_log_header     = gt_header
    EXCEPTIONS
      log_not_found      = 1
      no_filter_criteria = 2
      OTHERS             = 3.
  IF sy-subrc <> 0.
    CLEAR gt_header.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FILTER_LOGS
*&---------------------------------------------------------------------*
*       Applies the remaining selections and the expiry date rules
*----------------------------------------------------------------------*
FORM filter_logs.

  DATA: ls_header TYPE balhdr,
        ls_result TYPE ty_result.

  IF s_user[] IS NOT INITIAL.
    DELETE gt_header WHERE aluser NOT IN s_user[].
  ENDIF.

  IF s_code[] IS NOT INITIAL.
    DELETE gt_header WHERE altcode NOT IN s_code[].
  ENDIF.

  IF s_prog[] IS NOT INITIAL.
    DELETE gt_header WHERE alprog NOT IN s_prog[].
  ENDIF.

  LOOP AT gt_header INTO ls_header.

    CLEAR ls_result.
    MOVE-CORRESPONDING ls_header TO ls_result.

    IF p_expi = abap_true.

*     Only logs whose expiry date has already been reached
      IF ls_header-aldate_del IS INITIAL OR ls_header-aldate_del > sy-datum.
        ls_result-icon   = c_yellow.
        ls_result-status = TEXT-s01.
        APPEND ls_result TO gt_result.
        gv_skipped = gv_skipped + 1.
        CONTINUE.
      ENDIF.

    ELSE.

*     Logs marked as "keep until expiry date" are only deleted on demand
      IF p_prot = abap_false AND ls_header-del_before = abap_true
         AND ( ls_header-aldate_del IS INITIAL OR ls_header-aldate_del > sy-datum ).
        ls_result-icon   = c_yellow.
        ls_result-status = TEXT-s02.
        APPEND ls_result TO gt_result.
        gv_skipped = gv_skipped + 1.
        CONTINUE.
      ENDIF.

    ENDIF.

    ls_result-icon   = c_yellow.
    ls_result-status = TEXT-s03.
    APPEND ls_result TO gt_result.
    APPEND ls_header TO gt_delete.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CONFIRM_DELETION
*&---------------------------------------------------------------------*
*       Asks the user before deleting in dialog mode
*----------------------------------------------------------------------*
FORM confirm_deletion.

  DATA: lv_answer TYPE c,
        lv_lines  TYPE i,
        lv_text   TYPE string.

  lv_lines = lines( gt_delete ).
  CHECK lv_lines > 0.

  lv_text = |{ lv_lines } { TEXT-s16 }|.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      text_question  = lv_text
    IMPORTING
      answer         = lv_answer
    EXCEPTIONS
      text_not_found = 1
      OTHERS         = 2.
  IF sy-subrc <> 0.
    CLEAR lv_answer.
  ENDIF.

  IF lv_answer <> '1'.
*   The user cancelled, the report goes on as a test run
    gv_test = abap_true.
    MESSAGE s138(zon_cl_oc).
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DELETE_LOGS
*&---------------------------------------------------------------------*
*       Deletes the application logs package by package
*----------------------------------------------------------------------*
FORM delete_logs.

  DATA: lt_package TYPE balhdr_t,
        lv_lines   TYPE i,
        lv_from    TYPE i,
        lv_to      TYPE i,
        lv_subrc   TYPE sy-subrc.

  lv_lines = lines( gt_delete ).
  CHECK lv_lines > 0.

  IF gv_test = abap_true.
    PERFORM set_status USING gt_delete c_yellow TEXT-s04.
    RETURN.
  ENDIF.

  lv_from = 1.

  WHILE lv_from <= lv_lines.

    lv_to = lv_from + p_pack - 1.
    IF lv_to > lv_lines.
      lv_to = lv_lines.
    ENDIF.

    CLEAR lt_package.
    APPEND LINES OF gt_delete FROM lv_from TO lv_to TO lt_package.

    PERFORM delete_package USING lt_package CHANGING lv_subrc.

    IF lv_subrc = 0.
      gv_deleted = gv_deleted + lines( lt_package ).
      PERFORM set_status USING lt_package c_green TEXT-s05.
    ELSE.
*     One of the logs of the package could not be deleted (locked,
*     protected, ...), the package is repeated log by log
      PERFORM delete_one_by_one USING lt_package.
    ENDIF.

    lv_from = lv_to + 1.

  ENDWHILE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DELETE_PACKAGE
*&---------------------------------------------------------------------*
*       Standard deletion of the logs of one package
*----------------------------------------------------------------------*
FORM delete_package USING    it_header TYPE balhdr_t
                    CHANGING cv_subrc  TYPE sy-subrc.

  CALL FUNCTION 'BAL_DB_DELETE'
    EXPORTING
      i_t_logs_to_delete = it_header
    EXCEPTIONS
      OTHERS             = 1.

  cv_subrc = sy-subrc.

  IF cv_subrc = 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DELETE_ONE_BY_ONE
*&---------------------------------------------------------------------*
*       Repetition of a package which could not be deleted as a whole
*----------------------------------------------------------------------*
FORM delete_one_by_one USING it_header TYPE balhdr_t.

  DATA: lt_single TYPE balhdr_t,
        ls_header TYPE balhdr,
        lv_subrc  TYPE sy-subrc.

  LOOP AT it_header INTO ls_header.

    CLEAR lt_single.
    APPEND ls_header TO lt_single.

    PERFORM delete_package USING lt_single CHANGING lv_subrc.

    IF lv_subrc = 0.
      gv_deleted = gv_deleted + 1.
      PERFORM set_status USING lt_single c_green TEXT-s05.
    ELSE.
      gv_error = gv_error + 1.
      PERFORM set_status USING lt_single c_red TEXT-s06.
    ENDIF.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_STATUS
*&---------------------------------------------------------------------*
*       Updates the result list of the processed logs
*----------------------------------------------------------------------*
FORM set_status USING it_header TYPE balhdr_t
                      iv_icon   TYPE icon_d
                      iv_status TYPE clike.

  DATA: ls_header TYPE balhdr.

  FIELD-SYMBOLS: <fs_result> TYPE ty_result.

  LOOP AT it_header INTO ls_header.

    READ TABLE gt_result ASSIGNING <fs_result>
         WITH TABLE KEY k_log COMPONENTS lognumber = ls_header-lognumber.
    IF sy-subrc = 0.
      <fs_result>-icon   = iv_icon.
      <fs_result>-status = iv_status.
    ENDIF.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DELETE_EXEC_LOGS
*&---------------------------------------------------------------------*
*       Deletes the One Connect execution logs (ZONTA_OC_EXLOG)
*----------------------------------------------------------------------*
FORM delete_exec_logs.

  DATA: lt_exlog  TYPE STANDARD TABLE OF zonta_oc_exlog,
        lt_domain TYPE RANGE OF zonta_oc_exlog-domainv,
        ls_domain LIKE LINE OF lt_domain.

  LOOP AT s_subo.
    CLEAR ls_domain.
    ls_domain-sign   = s_subo-sign.
    ls_domain-option = s_subo-option.
    ls_domain-low    = s_subo-low.
    ls_domain-high   = s_subo-high.
    APPEND ls_domain TO lt_domain.
  ENDLOOP.

  IF gv_test = abap_true.

    SELECT COUNT(*) FROM zonta_oc_exlog
      WHERE datum   IN gt_date
        AND domainv IN lt_domain.

    gv_exlog = sy-dbcnt.
    RETURN.

  ENDIF.

  DO.

    CLEAR lt_exlog.

    SELECT * INTO TABLE lt_exlog
      FROM zonta_oc_exlog
      UP TO p_pack ROWS
      WHERE datum   IN gt_date
        AND domainv IN lt_domain.

    IF lt_exlog IS INITIAL.
      EXIT.
    ENDIF.

    DELETE zonta_oc_exlog FROM TABLE lt_exlog.

    IF sy-dbcnt = 0.
*     Nothing could be deleted, the loop is left to avoid endless reading
      ROLLBACK WORK.
      EXIT.
    ENDIF.

    gv_exlog = gv_exlog + sy-dbcnt.
    COMMIT WORK AND WAIT.

  ENDDO.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_RESULT
*&---------------------------------------------------------------------*
*       Result of the deletion
*----------------------------------------------------------------------*
FORM display_result.

  DATA: lv_lines TYPE i.

  IF gt_result IS INITIAL AND gv_exlog = 0.
    MESSAGE i134(zon_cl_oc).
    RETURN.
  ENDIF.

  IF p_exlo = abap_true AND sy-batch IS INITIAL.
    MESSAGE i137(zon_cl_oc) WITH gv_exlog.
  ENDIF.

  IF gv_test = abap_true.
    lv_lines = lines( gt_delete ).
    MESSAGE s136(zon_cl_oc) WITH lv_lines.
  ELSE.
    MESSAGE s135(zon_cl_oc) WITH gv_deleted.
  ENDIF.

  IF sy-batch IS INITIAL AND p_list = abap_true AND gt_result IS NOT INITIAL.
    PERFORM display_alv.
  ELSE.
    PERFORM write_summary.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       Detail list of the processed logs
*----------------------------------------------------------------------*
FORM display_alv.

  DATA: lo_alv     TYPE REF TO cl_salv_table,
        lo_columns TYPE REF TO cl_salv_columns_table,
        lo_column  TYPE REF TO cl_salv_column_table,
        lv_header  TYPE lvc_title.

  TRY.

      cl_salv_table=>factory( IMPORTING r_salv_table = lo_alv
                              CHANGING  t_table      = gt_result ).

      lo_alv->get_functions( )->set_all( abap_true ).

      lo_columns = lo_alv->get_columns( ).
      lo_columns->set_optimize( abap_true ).

      TRY.
          lo_column ?= lo_columns->get_column( 'ICON' ).
          lo_column->set_icon( if_salv_c_bool_sap=>true ).
          lo_column->set_short_text( 'Status' ).
          lo_column->set_medium_text( 'Status' ).
          lo_column->set_long_text( 'Status' ).

          lo_column ?= lo_columns->get_column( 'STATUS' ).
          lo_column->set_short_text( 'Result' ).
          lo_column->set_medium_text( 'Result' ).
          lo_column->set_long_text( 'Result of the deletion' ).
        CATCH cx_salv_not_found.                        "#EC NO_HANDLER
      ENDTRY.

      lv_header = |{ TEXT-s17 } { p_obje }|.

      lo_alv->get_display_settings( )->set_list_header( lv_header ).
      lo_alv->get_display_settings( )->set_striped_pattern( abap_true ).

      lo_alv->display( ).

    CATCH cx_salv_msg.
      PERFORM write_summary.
  ENDTRY.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  WRITE_SUMMARY
*&---------------------------------------------------------------------*
*       Summary for background processing
*----------------------------------------------------------------------*
FORM write_summary.

  DATA: lv_selected TYPE i.

  lv_selected = lines( gt_result ).

  WRITE: / TEXT-s17, p_obje.
  SKIP.
  WRITE: / TEXT-s10, lv_selected.
  WRITE: / TEXT-s11, gv_deleted.
  WRITE: / TEXT-s12, gv_skipped.
  WRITE: / TEXT-s13, gv_error.

  IF p_exlo = abap_true.
    WRITE: / TEXT-s14, gv_exlog.
  ENDIF.

  IF gv_test = abap_true.
    SKIP.
    WRITE: / TEXT-s15.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_SUBOBJECTS
*&---------------------------------------------------------------------*
*       Value help for the One Connect subobjects
*----------------------------------------------------------------------*
FORM get_subobjects CHANGING p_subobj.

  TYPES: BEGIN OF ty_val,
           domainv TYPE zonde_domain,
         END OF ty_val.

  DATA: lt_values TYPE STANDARD TABLE OF ty_val,
        lt_return TYPE STANDARD TABLE OF ddshretval,
        ls_return LIKE LINE OF lt_return.

  SELECT domainv
    FROM zonta_domains
    INTO TABLE lt_values
    WHERE spras = sy-langu.

  IF sy-subrc NE 0.
    RETURN.
  ENDIF.

  SORT lt_values BY domainv.
  DELETE ADJACENT DUPLICATES FROM lt_values.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'DOMAINV'
      value_org       = 'S'
    TABLES
      value_tab       = lt_values
      return_tab      = lt_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc NE 0.
    RETURN.
  ENDIF.

  READ TABLE lt_return INTO ls_return INDEX 1.
  IF sy-subrc = 0.
    p_subobj = ls_return-fieldval.
  ENDIF.

ENDFORM.
