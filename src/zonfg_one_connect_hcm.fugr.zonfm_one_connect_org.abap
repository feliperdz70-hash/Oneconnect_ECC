FUNCTION zonfm_one_connect_org.
*"----------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_NEW_IMAGE) TYPE  AFT_IMAGE
*"     VALUE(IV_DELETE) TYPE  BOOLEAN
*"     VALUE(IV_UPDATE) TYPE  BOOLEAN
*"----------------------------------------------------------------------
  CONSTANTS: lc_comilla   TYPE c LENGTH 1 VALUE ''''.

  DATA : lo_json  TYPE REF TO zoncl_fetch_data_v2,
         lv_table TYPE tabname,
         lt_where	TYPE rsds_where_tab,
         lv_plvar TYPE string,
         lv_otype TYPE string,
         lv_objid TYPE string,
         lv_istat TYPE string,
         lv_begda TYPE string,
         lv_endda TYPE string,
         lv_seqnr TYPE string,
         lv_alias TYPE boolean.



  FIELD-SYMBOLS:<fs_where> TYPE rsdswhere.

  lv_table = 'HRP' && is_new_image-infty.

  CREATE OBJECT lo_json.

  APPEND INITIAL LINE TO lt_where ASSIGNING <fs_where>.
  lv_plvar = |{ lc_comilla } { is_new_image-plvar } { lc_comilla }| .
  CONDENSE lv_plvar NO-GAPS.
  CONCATENATE '( PLVAR EQ '
             lv_plvar
             ') AND'
             INTO <fs_where>-line
             SEPARATED BY space.

  APPEND INITIAL LINE TO lt_where ASSIGNING <fs_where>.
  lv_otype = |{ lc_comilla } { is_new_image-otype } { lc_comilla }| .
  CONDENSE lv_otype NO-GAPS.
  CONCATENATE '( OTYPE EQ '
             lv_otype
             ') AND'
             INTO <fs_where>-line
             SEPARATED BY space.

  APPEND INITIAL LINE TO lt_where ASSIGNING <fs_where>.
  lv_objid = |{ lc_comilla } { is_new_image-objid } { lc_comilla }| .
  CONDENSE lv_objid NO-GAPS.
  CONCATENATE '( OBJID EQ '
             lv_objid
             ') AND'
             INTO <fs_where>-line
             SEPARATED BY space.

  APPEND INITIAL LINE TO lt_where ASSIGNING <fs_where>.
  lv_istat = |{ lc_comilla } { is_new_image-istat } { lc_comilla }| .
  CONDENSE lv_istat NO-GAPS.
  CONCATENATE '( ISTAT EQ '
             lv_istat
             ') AND'
             INTO <fs_where>-line
             SEPARATED BY space.

  APPEND INITIAL LINE TO lt_where ASSIGNING <fs_where>.
  lv_begda = |{ lc_comilla } { is_new_image-begda } { lc_comilla }| .
  CONDENSE lv_begda NO-GAPS.
  CONCATENATE '( BEGDA EQ '
             lv_begda
             ') AND'
             INTO <fs_where>-line
             SEPARATED BY space.

  APPEND INITIAL LINE TO lt_where ASSIGNING <fs_where>.
  lv_endda = |{ lc_comilla } { is_new_image-endda } { lc_comilla }| .
  CONDENSE lv_endda NO-GAPS.
  CONCATENATE '( ENDDA EQ '
             lv_endda
             ') AND'
             INTO <fs_where>-line
             SEPARATED BY space.

  APPEND INITIAL LINE TO lt_where ASSIGNING <fs_where>.
  lv_seqnr = |{ lc_comilla } { is_new_image-seqnr } { lc_comilla }| .
  CONDENSE lv_seqnr NO-GAPS.
  CONCATENATE '( SEQNR EQ '
             lv_seqnr
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
      iv_alias   = abap_true.


ENDFUNCTION.
