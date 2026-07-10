FUNCTION zonfm_cond_price.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(EVENT) LIKE  SWETYPECOU-EVENT
*"     VALUE(RECTYPE) LIKE  SWETYPECOU-RECTYPE
*"     VALUE(OBJTYPE) LIKE  SWETYPECOU-OBJTYPE
*"     VALUE(OBJKEY) LIKE  SWEINSTCOU-OBJKEY
*"  TABLES
*"      EVENT_CONTAINER STRUCTURE  SWCONT
*"----------------------------------------------------------------------
*  DATA: l_container       TYPE REF TO if_swf_cnt_container.
*  DATA: lt_values         TYPE swconttab.
*  DATA: l_sender          TYPE sibflporb.
*  DATA: l_event           TYPE sibfevent.
*  DATA: l_rectype         TYPE swferectyp.
*  DATA: l_handler         TYPE sibflporb.
*
*  l_sender-catid  = swfev_objcateg_bor.
*  l_sender-typeid = objtype.
*  l_event         = event.
*  l_rectype       = rectype.

  CONSTANTS: lc_comilla   TYPE c LENGTH 1 VALUE ''''.

  TYPES: BEGIN OF ty_konh,
           knumh   TYPE konh-knumh,
           kvewe   TYPE konh-kvewe,
           kotabnr TYPE konh-kotabnr,
           kappl   TYPE konh-kappl,
           kschl   TYPE konh-kschl,
           datab   TYPE konh-datab,
           datbi   TYPE konh-datbi,
         END OF ty_konh.

  DATA: gv_knumh TYPE knumh,
        gs_konh  TYPE ty_konh.

  DATA : lo_json  TYPE REF TO zoncl_fetch_data_v2,
         lv_table TYPE tabname,
         lt_where TYPE rsds_where_tab,
         lv_kappl TYPE string,
         lv_kschl TYPE string,
         lv_datbi TYPE string,
         lv_datab TYPE string,
         lv_knumh TYPE string,
         lv_alias TYPE boolean.

  FIELD-SYMBOLS:<fs_where> TYPE rsdswhere.

  gv_knumh = objkey.

  SELECT SINGLE
         knumh
         kvewe
         kotabnr
         kappl
         kschl
         datab
         datbi
         INTO gs_konh
         FROM konh
         WHERE knumh EQ gv_knumh.

  IF sy-subrc EQ 0.
*** Send Info Axxx table
    lv_table = gs_konh-kvewe &&
               gs_konh-kotabnr .

    CREATE OBJECT lo_json.

    APPEND INITIAL LINE TO lt_where ASSIGNING <fs_where>.
    lv_kappl = |{ lc_comilla } { gs_konh-kappl } { lc_comilla }| .
    CONDENSE lv_kappl NO-GAPS.
    CONCATENATE '( KAPPL EQ '
              lv_kappl
              ') AND'
              INTO <fs_where>-line
              SEPARATED BY space.

    APPEND INITIAL LINE TO lt_where ASSIGNING <fs_where>.
    lv_kschl = |{ lc_comilla } { gs_konh-kschl } { lc_comilla }| .
    CONDENSE lv_kschl NO-GAPS.
    CONCATENATE '( KSCHL EQ '
              lv_kschl
              ') AND'
              INTO <fs_where>-line
              SEPARATED BY space.

    APPEND INITIAL LINE TO lt_where ASSIGNING <fs_where>.
    lv_datbi = |{ lc_comilla } { gs_konh-datbi } { lc_comilla }| .
    CONDENSE lv_datbi NO-GAPS.
    CONCATENATE '( DATBI EQ '
              lv_datbi
              ') AND'
              INTO <fs_where>-line
              SEPARATED BY space.

    APPEND INITIAL LINE TO lt_where ASSIGNING <fs_where>.
    lv_datab = |{ lc_comilla } { gs_konh-datab } { lc_comilla }| .
    CONDENSE lv_datab NO-GAPS.
    CONCATENATE '( DATAB EQ '
              lv_datab
              ') AND'
              INTO <fs_where>-line
              SEPARATED BY space.

    APPEND INITIAL LINE TO lt_where ASSIGNING <fs_where>.
    lv_knumh = |{ lc_comilla } { gs_konh-knumh } { lc_comilla }| .
    CONDENSE lv_knumh NO-GAPS.
    CONCATENATE '( KNUMH EQ '
                lv_knumh
                ')'
                INTO <fs_where>-line
                SEPARATED BY space.

    SELECT SINGLE low
        INTO lv_alias
        FROM zonta_oc_param
        WHERE name EQ 'USE_ALIAS'.

    CALL METHOD lo_json->send_json_any_table_cond
      EXPORTING
        iv_tabname = lv_table
        iv_update  = abap_true
        iv_delete  = abap_false
        it_where   = lt_where
        iv_alias   = abap_true.

    FREE lo_json.
*** Send Info KONP table

    CLEAR lt_where.

    lv_table = 'KONP'.

    CREATE OBJECT lo_json.

    APPEND INITIAL LINE TO lt_where ASSIGNING <fs_where>.
    lv_knumh = |{ lc_comilla } { gs_konh-knumh } { lc_comilla }| .
    CONDENSE lv_knumh NO-GAPS.
    CONCATENATE '( KNUMH EQ '
                lv_knumh
                ')'
                INTO <fs_where>-line
                SEPARATED BY space.

    CALL METHOD lo_json->send_json_any_table_cond
      EXPORTING
        iv_tabname = lv_table
        iv_update  = abap_true
        iv_delete  = abap_false
        it_where   = lt_where
        iv_alias   = abap_true.
  ENDIF.
ENDFUNCTION.
