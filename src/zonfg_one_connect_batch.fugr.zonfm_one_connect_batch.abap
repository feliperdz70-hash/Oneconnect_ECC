FUNCTION zonfm_one_connect_batch.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_DOMAINV) TYPE  ZONDE_DOMAIN OPTIONAL
*"     VALUE(IV_BUSINESS_PROC) TYPE  ZONDE_PROCESS OPTIONAL
*"     VALUE(IV_KDOC) TYPE  BOOLEAN OPTIONAL
*"     VALUE(IV_TABLE) TYPE  BOOLEAN OPTIONAL
*"     VALUE(IV_DDIC) TYPE  BOOLEAN OPTIONAL
*"     VALUE(IV_DEST) TYPE  RFCDEST DEFAULT 'ONIBEX_KDOCS'
*"     VALUE(IV_UPDATE) TYPE  BOOLEAN OPTIONAL
*"     VALUE(IV_DELETE) TYPE  BOOLEAN OPTIONAL
*"     REFERENCE(IT_WHERE) TYPE  ZONTTRSDSWHERE
*"     VALUE(IV_ANY_TABLE) TYPE  BOOLEAN OPTIONAL
*"     VALUE(IV_TABNAME) TYPE  TABNAME OPTIONAL
*"     REFERENCE(IT_WHERE_COND_TAB) TYPE  RSDS_TWHERE OPTIONAL
*"     VALUE(IV_ALIAS) TYPE  BOOLEAN OPTIONAL
*"     VALUE(IV_BOTH) TYPE  BOOLEAN OPTIONAL
*"----------------------------------------------------------------------
  DATA: lo_fetch_data TYPE REF TO zoncl_fetch_data, "_v2, "FIXDB
        it_table      TYPE REF TO data,
        lx_text       TYPE REF TO cx_root,
        lv_both       TYPE boolean,
        lv_alias      TYPE boolean,
        lv_fieldname  TYPE boolean.

  CREATE OBJECT lo_fetch_data.
*  DO.  ENDDO.

**  SELECT SINGLE low
**     INTO lv_alias
**     FROM zonta_oc_param
**     WHERE name = 'USE_ALIAS'.
**  IF  sy-subrc = 0.
  IF iv_both IS INITIAL.
    IF iv_alias = abap_true.
      lv_alias         = abap_true.
      lv_fieldname     = abap_false.
    ELSE.
      lv_alias         = abap_false.
      lv_fieldname     = abap_true.
    ENDIF.
  ELSE.
    lv_alias         = abap_false.
    lv_fieldname     = abap_false.
    lv_both          = abap_true.
  ENDIF.


  TRY.
      IF NOT iv_any_table IS INITIAL.
        lo_fetch_data->send_json_any_table( EXPORTING
           iv_tabname   = iv_tabname
           iv_update    = abap_true
           iv_delete    = abap_false
*BEGIN CECHAVARRIA 19/08/2025
           iv_alias     = lv_alias
           iv_fieldname = lv_fieldname
*END CECHAVARRIA 19/08/2025
           it_where     = it_where ).
      ELSE.
        lo_fetch_data->get_relation( EXPORTING
              iv_domainv       = iv_domainv
              iv_business_proc = iv_business_proc
              iv_kdoc          = iv_kdoc
              iv_table         = iv_table
              iv_ddic          = abap_false
              iv_dest          = iv_dest
              iv_update        = iv_update
              iv_delete        = iv_delete
              iv_alias         = lv_alias
              iv_fieldname     = lv_fieldname
              iv_bothnames     = lv_both
*          it_where         = it_where
             it_where_cond_tab = it_where_cond_tab
*     iv_key_queue     =
*     iv_batch         =
        ).
      ENDIF.
    CATCH cx_root INTO lx_text.
*      WRITE: / 'Error:', lx_text->get_text( ).
  ENDTRY.
ENDFUNCTION.
