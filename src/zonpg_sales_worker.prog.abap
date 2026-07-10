*&---------------------------------------------------------------------*
*& Report  ZONPG_SALES_WORKER
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zonpg_sales_worker.



*----------------------------------------------------------------------*
* TYPES
*----------------------------------------------------------------------*
TYPES: BEGIN OF ty_r_vbeln,
         sign   TYPE c LENGTH 1,
         option TYPE c LENGTH 2,
         low    TYPE vbeln_vf,
         high   TYPE vbeln_vf,
       END OF ty_r_vbeln.

*----------------------------------------------------------------------*
* SELECTION SCREEN
*----------------------------------------------------------------------*

TABLES: vbak.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-b02.
PARAMETERS: p_domain TYPE zonde_domain,
            p_entity TYPE zonde_process OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-b01.
SELECT-OPTIONS: s_vbeln FOR vbak-vbeln,
                s_erdat FOR vbak-erdat.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-b03.
PARAMETERS: p_dest  TYPE rfcdest OBLIGATORY,
            p_alias AS CHECKBOX DEFAULT ' '.
SELECTION-SCREEN END OF BLOCK b3.

SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE text-b04.
PARAMETERS: p_pkgsz TYPE i DEFAULT 5000.
SELECTION-SCREEN END OF BLOCK b4.

*----------------------------------------------------------------------*
* DATA
*----------------------------------------------------------------------*
DATA: go_handler    TYPE REF TO zoncl_oc_any_handler,
      ls_vbak_rel   TYPE zonta_relations,
      ls_vbap_rel   TYPE zonta_relations,
      lt_vbak       TYPE STANDARD TABLE OF vbak,
      lt_vbap       TYPE STANDARD TABLE OF vbap,
      lt_r_vbeln    TYPE STANDARD TABLE OF ty_r_vbeln,
      ls_r_vbeln    TYPE ty_r_vbeln,
      lx_root       TYPE REF TO cx_root,
      lv_alias      TYPE boolean,
      lv_total_vbak TYPE i,
      lv_total_vbap TYPE i,
      lv_errors     TYPE i,
      lv_lines      TYPE i,
      lv_msg        TYPE string,
      lv_ts_start   TYPE timestampl,
      lv_ts_end     TYPE timestampl,
      lv_elapsed    TYPE p LENGTH 8 DECIMALS 3.

FIELD-SYMBOLS: <fs_vbak>  TYPE vbak,
               <fs_table> TYPE STANDARD TABLE.

*----------------------------------------------------------------------*
* SELECTION-SCREEN VALIDATIONS
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_domain.
  PERFORM f4_domain.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_entity.
  PERFORM f4_entity.

*AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_vbeln-low.
*  PERFORM f4_vbeln.

AT SELECTION-SCREEN.
  IF s_vbeln[] IS INITIAL AND s_erdat[] IS INITIAL.
    MESSAGE 'Enter at least a billing document or a date range.' TYPE 'E'.
  ENDIF.
  IF p_pkgsz < 100 OR p_pkgsz > 50000.
    MESSAGE 'Package size must be between 100 and 50,000.' TYPE 'E'.
  ENDIF.

*----------------------------------------------------------------------*
* MAIN PROCESSING
*----------------------------------------------------------------------*
START-OF-SELECTION.

  GET TIME STAMP FIELD lv_ts_start.

  " Step 1: Read ZONTA_RELATIONS for vbak
  SELECT SINGLE * FROM zonta_relations INTO ls_vbak_rel
    WHERE domainv       = p_domain
      AND business_proc = p_entity
      AND tabname       = 'VBAK'.
  IF sy-subrc <> 0.
    MESSAGE 'No ZONTA_RELATIONS entry found for VBAP.' TYPE 'E'.
  ENDIF.

  " Step 1: Read ZONTA_RELATIONS for vbap
  SELECT SINGLE * FROM zonta_relations INTO ls_vbap_rel
    WHERE domainv       = p_domain
      AND business_proc = p_entity
      AND tabname       = 'VBAP'.
  IF sy-subrc <> 0.
    MESSAGE 'No ZONTA_RELATIONS entry found for VBAP.' TYPE 'E'.
  ENDIF.

  " Step 2: Instantiate handler
  CREATE OBJECT go_handler.
  lv_alias = p_alias.

  " Step 3: Loop vbak by package
  SELECT * FROM vbak
    INTO TABLE lt_vbak
    PACKAGE SIZE p_pkgsz
    WHERE vbeln IN s_vbeln
      AND erdat IN s_erdat.

    " 3.1: Build VBELN range from current package
    CLEAR lt_r_vbeln.
    LOOP AT lt_vbak ASSIGNING <fs_vbak>.
      ls_r_vbeln-sign   = 'I'.
      ls_r_vbeln-option = 'EQ'.
      ls_r_vbeln-low    = <fs_vbak>-vbeln.
      APPEND ls_r_vbeln TO lt_r_vbeln.
    ENDLOOP.

    " 3.2: Read vbap for this package (uses primary key VBELN)
    SELECT * FROM vbap INTO TABLE lt_vbap
      WHERE vbeln IN lt_r_vbeln.

    " 3.3: Send vbak package
    ASSIGN lt_vbak TO <fs_table>.
    TRY.
        go_handler->send_json_any_table_ltables(
          EXPORTING
            iv_tabname              = ls_vbak_rel-tabname
            iv_aliastablong         = ls_vbak_rel-alias_tabname
            iv_entity_business_proc = 'ANY'
            iv_dest                 = p_dest
            iv_delete               = ''
            iv_update               = 'X'
            iv_alias                = lv_alias
            it_tables_data          = <fs_table> ).
        DESCRIBE TABLE lt_vbak LINES lv_lines.
        lv_total_vbak = lv_total_vbak + lv_lines.
      CATCH cx_root INTO lx_root.
        ADD 1 TO lv_errors.
        lv_msg = lx_root->get_text( ).
        MESSAGE lv_msg TYPE 'W'.
    ENDTRY.

    " 3.4: Send vbap package
    ASSIGN lt_vbap TO <fs_table>.
    TRY.
        go_handler->send_json_any_table_ltables(
          EXPORTING
            iv_tabname              = ls_vbap_rel-tabname
            iv_aliastablong         = ls_vbap_rel-alias_tabname
            iv_entity_business_proc = 'ANY'
            iv_dest                 = p_dest
            iv_delete               = ''
            iv_update               = 'X'
            iv_alias                = lv_alias
            it_tables_data          = <fs_table> ).
        DESCRIBE TABLE lt_vbap LINES lv_lines.
        lv_total_vbap = lv_total_vbap + lv_lines.
      CATCH cx_root INTO lx_root.
        ADD 1 TO lv_errors.
        lv_msg = lx_root->get_text( ).
        MESSAGE lv_msg TYPE 'W'.
    ENDTRY.

    " 3.5: Free memory (mandatory to prevent NEW_PAGE_ALLOCATION dump)
    FREE lt_vbak.
    FREE lt_vbap.
    FREE lt_r_vbeln.

  ENDSELECT.

END-OF-SELECTION.
  GET TIME STAMP FIELD lv_ts_end.
  lv_elapsed = lv_ts_end - lv_ts_start.

  IF sy-batch = abap_true.
    MESSAGE |=== SALES WORKER - EXECUTION SUMMARY ===| TYPE 'I'.
    MESSAGE |VBAK records sent : { lv_total_vbak }|     TYPE 'I'.
    MESSAGE |VBAP records sent : { lv_total_vbap }|     TYPE 'I'.
    MESSAGE |Errors            : { lv_errors }|         TYPE 'I'.
    MESSAGE |Execution time    : { lv_elapsed } sec|    TYPE 'I'.
  ELSE.
    cl_demo_output=>write_text( '=== SALES WORKER - EXECUTION SUMMARY ===' ).
    cl_demo_output=>write_text( |VBAK records sent : { lv_total_vbak }| ).
    cl_demo_output=>write_text( |VBAP records sent : { lv_total_vbap }| ).
    cl_demo_output=>write_text( |Errors            : { lv_errors }| ).
    cl_demo_output=>write_text( |Execution time    : { lv_elapsed } sec| ).
    cl_demo_output=>display( ).
  ENDIF.

  lv_msg = |Done: { lv_total_vbak } VBAK / { lv_total_vbap } VBAP. Errors: { lv_errors }. Time: { lv_elapsed } sec.|.
  MESSAGE lv_msg TYPE 'S'.

*----------------------------------------------------------------------*
* F4 HELPERS
*----------------------------------------------------------------------*
FORM f4_domain.
  TYPES: BEGIN OF ty_domain,
           domainv     TYPE zonde_domain,
           description TYPE zonde_description,
         END OF ty_domain.

  DATA: lt_ret  TYPE TABLE OF ddshretval,
        lt_data TYPE TABLE OF ty_domain,
        ls_ret  TYPE ddshretval,
        lv_dynp TYPE help_info-dynprofld.

  SELECT domainv description
    INTO TABLE lt_data
    FROM zonta_domains
    WHERE spras = sy-langu.

  lv_dynp = 'P_DOMAIN'.
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

  READ TABLE lt_ret INTO ls_ret INDEX 1.
  IF sy-subrc = 0.
    p_domain = ls_ret-fieldval.
  ENDIF.
ENDFORM.

FORM f4_entity.
  TYPES: BEGIN OF ty_entity,
           domainv       TYPE zonde_domain,
           business_proc TYPE zonde_process,
         END OF ty_entity.

  DATA: lt_ret  TYPE TABLE OF ddshretval,
        lt_data TYPE TABLE OF ty_entity,
        ls_ret  TYPE ddshretval,
        lv_dynp TYPE help_info-dynprofld.

  SELECT domainv business_proc
    INTO TABLE lt_data
    FROM zonta_obj_oc
    WHERE domainv = p_domain.

  lv_dynp = 'P_ENTITY'.
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

  READ TABLE lt_ret INTO ls_ret INDEX 1.
  IF sy-subrc = 0.
    p_entity = ls_ret-fieldval.
  ENDIF.
ENDFORM.

FORM f4_vbeln.
  DATA: lt_ret  TYPE TABLE OF ddshretval,
        ls_ret  TYPE ddshretval,
        lv_dynp TYPE help_info-dynprofld.

  lv_dynp = 'S_VBELN-LOW'.
  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      tabname     = 'vbak'
      fieldname   = 'VBELN'
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = lv_dynp
    TABLES
      return_tab  = lt_ret.

  READ TABLE lt_ret INTO ls_ret INDEX 1.
  IF sy-subrc = 0.
    s_vbeln-low = ls_ret-fieldval.
  ENDIF.
ENDFORM.
