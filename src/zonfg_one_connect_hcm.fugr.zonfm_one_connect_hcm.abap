FUNCTION zonfm_one_connect_hcm.
*"----------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_NEW_INNNN) TYPE  PRELP
*"     VALUE(IV_TCLAS) TYPE  TCLAS
*"     VALUE(IV_DELETE) TYPE  BOOLEAN
*"     VALUE(IV_UPDATE) TYPE  BOOLEAN
*"----------------------------------------------------------------------
  CONSTANTS: lc_comilla   TYPE c LENGTH 1 VALUE ''''.

  DATA : lo_json  TYPE REF TO zoncl_fetch_data_v2,
         lv_table TYPE tabname,
         lt_where	TYPE rsds_where_tab,
         lv_pernr TYPE string,
         lv_alias TYPE boolean.


  FIELD-SYMBOLS:<fs_where> TYPE rsdswhere.


  lv_table = 'P'             &&
             iv_tclas        &&
             is_new_innnn-infty.

  CREATE OBJECT lo_json.

  APPEND INITIAL LINE TO lt_where ASSIGNING <fs_where>.

  lv_pernr = |{ lc_comilla } { is_new_innnn-pernr } { lc_comilla }| .

  CONDENSE lv_pernr NO-GAPS.

  CONCATENATE '( PERNR EQ '
              lv_pernr
              ')'
              INTO <fs_where>-line
              SEPARATED BY space.

  SELECT SINGLE low
         INTO lv_alias
         FROM zonta_oc_param
         WHERE name EQ 'USE_ALIAS'.

  CALL METHOD lo_json->send_json_any_table_hcm
    EXPORTING
      iv_tabname = lv_table
      iv_update  = iv_update
      iv_delete  = iv_delete
      it_where   = lt_where
      iv_alias   = lv_alias.


ENDFUNCTION.
