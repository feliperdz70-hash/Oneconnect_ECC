*&---------------------------------------------------------------------*
*& Report  ZONPG_BILLING_WORKER
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zonpg_billing_worker.


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

TABLES: vbrk.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-b02.
PARAMETERS: p_domain TYPE zonde_domain,
            p_entity TYPE zonde_process OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-b01.
SELECT-OPTIONS: s_vbeln FOR vbrk-vbeln,
                s_erdat FOR vbrk-erdat.
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
      ls_vbrk_rel   TYPE zonta_relations,
      ls_vbrp_rel   TYPE zonta_relations,
      lt_vbrk       TYPE STANDARD TABLE OF vbrk,
      lt_vbrp       TYPE STANDARD TABLE OF vbrp,
      lt_r_vbeln    TYPE STANDARD TABLE OF ty_r_vbeln,
      ls_r_vbeln    TYPE ty_r_vbeln,
      lx_root       TYPE REF TO cx_root,
      lv_alias      TYPE boolean,
      lv_total_vbrk TYPE i,
      lv_total_vbrp TYPE i,
      lv_errors     TYPE i,
      lv_lines      TYPE i,
      lv_msg        TYPE string,
      lv_ts_start   TYPE timestampl,
      lv_ts_end     TYPE timestampl,
      lv_elapsed    TYPE p LENGTH 8 DECIMALS 3.

FIELD-SYMBOLS: <fs_vbrk>  TYPE vbrk,
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

  " Step 1: Read ZONTA_RELATIONS for VBRK
  SELECT SINGLE * FROM zonta_relations INTO ls_vbrk_rel
    WHERE domainv       = p_domain
      AND business_proc = p_entity
      AND tabname       = 'VBRK'.
  IF sy-subrc <> 0.
    MESSAGE 'No ZONTA_RELATIONS entry found for VBRK.' TYPE 'E'.
  ENDIF.

  " Step 1: Read ZONTA_RELATIONS for VBRP
  SELECT SINGLE * FROM zonta_relations INTO ls_vbrp_rel
    WHERE domainv       = p_domain
      AND business_proc = p_entity
      AND tabname       = 'VBRP'.
  IF sy-subrc <> 0.
    MESSAGE 'No ZONTA_RELATIONS entry found for VBRP.' TYPE 'E'.
  ENDIF.

  " Step 2: Instantiate handler
  CREATE OBJECT go_handler.
  lv_alias = p_alias.

  " Step 3: Loop VBRK by package
  SELECT * FROM vbrk
    INTO TABLE lt_vbrk
    PACKAGE SIZE p_pkgsz
    WHERE vbeln IN s_vbeln
      AND erdat IN s_erdat.

    " 3.1: Build VBELN range from current package
    CLEAR lt_r_vbeln.
    LOOP AT lt_vbrk ASSIGNING <fs_vbrk>.
      ls_r_vbeln-sign   = 'I'.
      ls_r_vbeln-option = 'EQ'.
      ls_r_vbeln-low    = <fs_vbrk>-vbeln.
      APPEND ls_r_vbeln TO lt_r_vbeln.
    ENDLOOP.

    " 3.2: Read VBRP for this package (uses primary key VBELN)
    SELECT * FROM vbrp INTO TABLE lt_vbrp
      WHERE vbeln IN lt_r_vbeln.

    " 3.3: Send VBRK package
    ASSIGN lt_vbrk TO <fs_table>.
    TRY.
        go_handler->send_json_any_table_ltables(
          EXPORTING
            iv_tabname              = ls_vbrk_rel-tabname
            iv_aliastablong         = ls_vbrk_rel-alias_tabname
            iv_entity_business_proc = 'ANY'
            iv_dest                 = p_dest
            iv_delete               = ''
            iv_update               = 'X'
            iv_alias                = lv_alias
            it_tables_data          = <fs_table> ).
        DESCRIBE TABLE lt_vbrk LINES lv_lines.
        lv_total_vbrk = lv_total_vbrk + lv_lines.
      CATCH cx_root INTO lx_root.
        ADD 1 TO lv_errors.
        lv_msg = lx_root->get_text( ).
        MESSAGE lv_msg TYPE 'W'.
    ENDTRY.

    " 3.4: Send VBRP package
    ASSIGN lt_vbrp TO <fs_table>.
    TRY.
        go_handler->send_json_any_table_ltables(
          EXPORTING
            iv_tabname              = ls_vbrp_rel-tabname
            iv_aliastablong         = ls_vbrp_rel-alias_tabname
            iv_entity_business_proc = 'ANY'
            iv_dest                 = p_dest
            iv_delete               = ''
            iv_update               = 'X'
            iv_alias                = lv_alias
            it_tables_data          = <fs_table> ).
        DESCRIBE TABLE lt_vbrp LINES lv_lines.
        lv_total_vbrp = lv_total_vbrp + lv_lines.
      CATCH cx_root INTO lx_root.
        ADD 1 TO lv_errors.
        lv_msg = lx_root->get_text( ).
        MESSAGE lv_msg TYPE 'W'.
    ENDTRY.

    " 3.5: Free memory (mandatory to prevent NEW_PAGE_ALLOCATION dump)
    FREE lt_vbrk.
    FREE lt_vbrp.
    FREE lt_r_vbeln.

  ENDSELECT.

END-OF-SELECTION.
  GET TIME STAMP FIELD lv_ts_end.
  lv_elapsed = lv_ts_end - lv_ts_start.

  IF sy-batch = abap_true.
    MESSAGE |=== BILLING WORKER - EXECUTION SUMMARY ===| TYPE 'I'.
    MESSAGE |VBRK records sent : { lv_total_vbrk }|     TYPE 'I'.
    MESSAGE |VBRP records sent : { lv_total_vbrp }|     TYPE 'I'.
    MESSAGE |Errors            : { lv_errors }|         TYPE 'I'.
    MESSAGE |Execution time    : { lv_elapsed } sec|    TYPE 'I'.
  ELSE.
    cl_demo_output=>write_text( '=== BILLING WORKER - EXECUTION SUMMARY ===' ).
    cl_demo_output=>write_text( |VBRK records sent : { lv_total_vbrk }| ).
    cl_demo_output=>write_text( |VBRP records sent : { lv_total_vbrp }| ).
    cl_demo_output=>write_text( |Errors            : { lv_errors }| ).
    cl_demo_output=>write_text( |Execution time    : { lv_elapsed } sec| ).
    cl_demo_output=>display( ).
  ENDIF.

  lv_msg = |Done: { lv_total_vbrk } VBRK / { lv_total_vbrp } VBRP. Errors: { lv_errors }. Time: { lv_elapsed } sec.|.
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
      tabname     = 'VBRK'
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
