class ZONCL_OC_CUSTOMIZING definition
  public
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IV_DOMAINV type ZONDE_DOMAIN optional
      !IV_BUSINESS_PROC type ZONDE_PROCESS optional .
  methods FILL_INFO_FIELD
    importing
      !IT_TABLES type ZONTT_RELATIONS optional
      !IT_COLUMNS type ZONTT_COLUMNS_ALV_EXT optional
      !IV_ANY type ZABAP_BOOLEAN optional
      !IV_ALIAS type BOOLEAN optional
    exporting
      !ET_COLUMNS type ZONTT_COLUMNS
      !ET_EXISTING_REL type ZONTT_RELATIONS
      !ET_EXISTING_COL type ZONTT_COL_ALL .
  methods GET_INFO_FIELD
    importing
      !EV_TABNAME type TABNAME
      !EV_FLDNAME type FIELDNAME
    exporting
      !ET_COLUMNS type ZONTT_COLUMNS .
  methods CREATE_TABLES_FOR_JOIN
    importing
      !IT_TABLES type ZONTT_RELATIONS optional
    exporting
      !ET_DBSA type AQDBSA
      !ET_DBOB type AQDBSA
      !ET_DBOS type AQTDBOB
      !ET_DBIF type AQTDBIF
      !ET_DBSF type AQTDBSF
      !ET_DBSG type AQTDBSG
      !ET_DBAN type AQTDBAN
      !ET_DBJT type AQTDBJT
      !ET_DBJC type AQTDBJC
      !ET_DBZT type AQTDBZT
      !ET_DBZC type AQTDBZC
      !ET_DBZL type AQTDBZL
      !ET_DBDP type AQTDBDP
      !ET_DBPA type AQTDBPA
      !ET_DBWR type AQTDBWR
      !ET_DBAR type AQTDBAR
      !ET_DBFT type AQTDBFT
      !ET_SGTEXT type AQTTXSG
      !ET_TTAB type AQQ_T_TTAB .
  methods REFRESH_TABLES .
  methods RETURN_TABLES_AFTER_JOIN
    importing
      !IT_DBSG type AQTDBSG
      !IT_DBJT type AQTDBJT
      !IT_DBAN type AQTDBAN
      !IT_TTAB type AQQ_T_TTAB
      !IT_DBJC type AQTDBJC
      !IT_JOIN type AQQ_T_JOIN optional
    exporting
      !ET_RELATIONS type ZONTT_RELATIONS .
  methods GET_FIELD_POSITIONS
    importing
      !IV_TABLE type TABNAME
      !IT_POSITIONS type AQTDBJC
    exporting
      !ET_POSITIONS_NEW type AQTDBJC .
  methods SHOW_FILTER_OPTIONS_NEW
    importing
      !IT_RELATIONS type ZONTT_RELATIONS
      !IT_COLUMNS type ZONTT_COL_ALL
      value(IT_RANGES) type ZONTT_RANGES optional
    exporting
      !ET_FILTERS type ZONTT_FILTERS
      !ET_RANGES type ZONTT_RANGES
      !EV_NOCHANGES type BOOLEAN .
  methods SHOW_FILTER_OPTIONS
    importing
      !IT_RELATIONS type ZONTT_RELATIONS
      !IT_COLUMNS type ZONTT_COLUMNS
      value(IT_RANGES) type ZONTT_RANGES optional
    exporting
      !ET_FILTERS type ZONTT_FILTERS
      !ET_RANGES type ZONTT_RANGES
      !EV_NOCHANGES type BOOLEAN .
  methods GET_TABLE_KEYS_NEW
    importing
      !IT_TABLES type ZONTT_RELATIONS
    exporting
      !ET_KEYS type ZONTT_COL_ALL
      !ET_FIELDS type ZONTT_COL_ALL .
  methods GET_TABLE_KEYS
    importing
      !IT_TABLES type ZONTT_RELATIONS
    exporting
      !ET_KEYS type ZONTT_OC_COLUMNS
      !ET_FIELDS type ZONTT_OC_COLUMNS .
  methods VALIDATE_ALIAS
    changing
      !IT_COLUMNS type ZONTT_COLUMNS optional .
  methods FILL_INFO_FIELD_NEW
    importing
      !IT_TABLES type ZONTT_RELATIONS optional
      !IT_COLUMNS type ZONTT_COLUMNS_ALV_EXT optional
      !IV_ANY type ZABAP_BOOLEAN optional
      !IV_ALIAS type BOOLEAN optional
    exporting
      !ET_COLUMNS type ZONTT_COL_ALL
      !ET_EXISTING_REL type ZONTT_RELATIONS
      !ET_EXISTING_COL type ZONTT_COL_ALL .
  methods SEND_JSON_METADATA
    importing
      !IV_ENTITY type ZONDE_PROCESS
      !IV_DOMAIN type ZONDE_DOMAIN
    exporting
      !EV_JSON type STRING .
  methods SEND_EXCEL_METADATA
    importing
      !IV_ENTITY type ZONDE_PROCESS
      !IV_DOMAIN type ZONDE_DOMAIN
      !IV_FILE type RLGRAP-FILENAME .
protected section.
private section.

  types:
    BEGIN OF st_chain,
      sort  TYPE sy-tabix,
      table TYPE tabname,
    END OF st_chain .
  types:
    BEGIN OF st_alias,
*      tabname TYPE tabname,
      alias TYPE zonde_aliasfld,
      cons  TYPE i,
    END OF st_alias .
  types:
    BEGIN OF st_relations,
      domainv           TYPE zonde_domain,
      business_proc     TYPE zonde_process,
      tabname           TYPE tabname,
      contflag          TYPE contflag,
      field_main        TYPE zonde_fieldm,
      field_sec         TYPE zonde_fields,
      parent_relation   TYPE zonde_parentrel,
      join_type         TYPE zonde_jointyp,
      sequence          TYPE zonde_sequence,
      subsequence       TYPE zonde_subsequence,
      levelv            TYPE zonde_oc_level,
      alias_tabname     TYPE zonde_aliastab,
      description_table TYPE zonde_desctab,
    END OF st_relations .
  types:
    BEGIN OF st_col_all,
      tabname           TYPE tabname,
      alias_tabname     TYPE zonde_aliastab,
      fldname           TYPE zonde_fieldname_long,
      alias_fldname     TYPE zonde_aliasfld,
      key_field         TYPE zonde_keyflag,
      selection_field   TYPE zonde_selflag,
      description_field TYPE zonde_descfld,
*           seckey_field      TYPE zonde_skeyflag,
*           positionf         TYPE  tabfdpos,
      inttype           TYPE dfies-inttype,
      leng              TYPE dfies-leng,
    END OF st_col_all .
  types:
    BEGIN OF st_franges,
      domainv       TYPE zonde_domain,
      business_proc TYPE zonde_process,
*           variant       TYPE variant,
      tabname       TYPE tabname,
      counter       TYPE zonde_counter,
      fldname       TYPE fieldname,
      sign          TYPE tvarv_sign,
      opti          TYPE tvarv_opti,
      low           TYPE rsdsselop_,
      high          TYPE rsdsselop_,
    END OF st_franges .
  types:
    BEGIN OF st_filters,
      domainv       TYPE zonde_domain,
      business_proc TYPE zonde_process,
*          VARIANT        type VARIANT,
      tabname       TYPE tabname,
      counter       TYPE  zonde_counter,
      fldname       TYPE fieldname,
      where_clause  TYPE  zonde_where,
    END OF st_filters .
  types:
    BEGIN OF st_dataproduct,
           process_prefix TYPE zonde_procpref,
           mmodule        TYPE  zonde_module,
           smodule        TYPE zonde_smodule,
           e2e            TYPE  zonde_e2e,
           lob            TYPE zonde_lob,
           solution_pg    TYPE zonde_solpg,
           submodule_name TYPE zonde_submname,
         END OF st_dataproduct .

  data:
    gt_relationsy   TYPE STANDARD TABLE OF st_relations .
  data:
    gt_columns_ally TYPE STANDARD TABLE OF st_col_all .
  data:
    gt_frangesy     TYPE STANDARD TABLE OF st_franges .
  data:
    gt_filtersy     TYPE STANDARD TABLE OF st_filters .
  data GS_DATAPRODUCT type ST_DATAPRODUCT .
  data GS_INFO type ZONTA_OBJ_OC .
  data:
    gt_tables TYPE STANDARD TABLE OF zonta_relations .
  data:
    gt_columns TYPE STANDARD TABLE OF zonta_oc_col_all .
  data GS_DBJC type AQDBJC .
  data:
    gt_col_all TYPE STANDARD TABLE OF zonta_oc_col_all .
  data GT_RELATIONS type ZONTT_RELATIONS .
  data GV_DOMAINV type ZONDE_DOMAIN .
  data GV_BUSINESS_PROC type ZONDE_PROCESS .
  data:
    gt_dbjc_old TYPE STANDARD TABLE OF aqdbjc .
  data:
    gs_old      LIKE LINE OF gt_dbjc_old .
  data:
    gt_dbsg_map TYPE STANDARD TABLE OF st_chain .
  data:
    gt_ind   TYPE STANDARD TABLE OF st_alias .
  data:
    gt_clogsg TYPE STANDARD TABLE OF aqclsg .
  data:
    gt_dbsa   TYPE STANDARD TABLE OF aqdbsa .
  data:
    gt_dbob  	TYPE STANDARD TABLE OF aqdbob .
  data:
    gt_dbos   TYPE STANDARD TABLE OF aqdbos .
  data:
    gt_dbif   TYPE STANDARD TABLE OF aqdbif .
  data:
    gt_dbsf   TYPE STANDARD TABLE OF aqdbsf .
  data:
    gt_dbsg   TYPE STANDARD TABLE OF aqdbsg .
  data:
    gt_dban   TYPE STANDARD TABLE OF aqdban .
  data:
    gt_dbjt   TYPE STANDARD TABLE OF aqdbjt .
  data:
    gt_dbjc   TYPE STANDARD TABLE OF aqdbjc .
  data:
    gt_dbzt   TYPE STANDARD TABLE OF aqdbzt .
  data:
    gt_dbzc   TYPE STANDARD TABLE OF aqdbzc .
  data:
    gt_dbzl   TYPE STANDARD TABLE OF aqdbzl .
  data:
    gt_dbdp   TYPE STANDARD TABLE OF aqdbdp .
  data:
    gt_dbpa   TYPE STANDARD TABLE OF aqdbpa .
  data:
    gt_dbwr   TYPE STANDARD TABLE OF aqdbwr .
  data:
    gt_dbar   TYPE STANDARD TABLE OF aqdbar .
  data:
    gt_dbft   TYPE STANDARD TABLE OF aqdbft .
  data:
    gt_sgtext TYPE STANDARD TABLE OF aqtxsg .
  data:
    gt_existing_relations TYPE STANDARD TABLE OF zonta_relations .
  data:
    gt_existing_columns TYPE STANDARD TABLE OF zonta_oc_col_all .
  data:
    gt_existing_col_all TYPE STANDARD TABLE OF zonta_oc_col_all .
  data GS_EXISTING_COLUMNS type ZONTA_OC_COL_ALL .
  data GS_EXISTING_COL_ALL type ZONTA_OC_COL_ALL .
  data GT_EXDBFI type AQQ_T_EXDBFI .
  data GT_TTAB type AQQ_T_TTAB .
  data GV_HEADSG type AQHDSG .
  data GV_MAXSG type AQS_TINDX .
  data GV_DFIES_MANDT type DFIES .
  data:
    gt_reserved TYPE STANDARD TABLE OF zonta_oc_reserv .
  data GT_EXISTING_TABLES type C .
  data GS_EXISTING_TABLES type C .
  data GV_ANY type ZABAP_BOOLEAN .
  data GT_COLUMNS_ALV type ZONTT_COLUMNS_ALV_EXT .
  data GV_FORCE_ALIAS type BOOLEAN value ABAP_FALSE ##NO_TEXT.

  methods ADD_INFO_LINE_FIELD
    importing
      !LS_DFIES_TAB type DFIES .
  methods ADD_INFO_LINE_FIELD_NEW
    importing
      !LS_DFIES_TAB type DFIES .
  methods BUILD_SORT_MAP .
  methods GET_SORT
    importing
      !IV_TABNAME type TABNAME
    changing
      !CV_SORT type I .
  methods APPEND_BASE_UNIQUE
    importing
      !IV_LTABLE type TABNAME
      !IV_RTABLE type TABNAME .
  methods APPEND_COND_OR_FLIPPED
    importing
      !IV_LTABLE type TABNAME
      !IV_RTABLE type TABNAME .
  methods GET_TABLES_METADATA
    importing
      !IV_DOMAIN type ZONDE_DOMAIN
      !IV_ENTITY type ZONDE_PROCESS
    exporting
      !EV_RESULT type SY-SUBRC .
  methods WRITE_CELL
    importing
      !IV_SHEET type OLE2_OBJECT
      !IV_ROW type I
      !IV_COL type I
      !IV_VALUE type ANY .
ENDCLASS.



CLASS ZONCL_OC_CUSTOMIZING IMPLEMENTATION.


  METHOD add_info_line_field.

    CONSTANTS: c_undersc       TYPE c VALUE '_',
               c_node          TYPE string VALUE 'NODE',
               c_dot           TYPE c VALUE '.',
               c_perc          TYPE c VALUE '%',
               c_dots          TYPE c VALUE ':',
               c_sum           TYPE c VALUE '+',
               c_guion         TYPE c VALUE '-',
               c_percentage(4) TYPE c VALUE 'perc',
               c_aa(1)         TYPE c VALUE 'á',
               c_a(1)          TYPE c VALUE 'a',
               c_ee(1)         TYPE c VALUE 'é',
               c_e(1)          TYPE c VALUE 'e',
               c_ii(1)         TYPE c VALUE 'í',
               c_i(1)          TYPE c VALUE 'i',
               c_oo(1)         TYPE c VALUE 'ó',
               c_o(1)          TYPE c VALUE 'o',
               c_uu(1)         TYPE c VALUE 'ú',
               c_u(1)          TYPE c VALUE 'u',
               c_as(1)         TYPE c VALUE 'Á',
               c_ass(1)        TYPE c VALUE 'A',
               c_es(1)         TYPE c VALUE 'É',
               c_ess(1)        TYPE c VALUE 'E',
               c_is(1)         TYPE c VALUE 'Í',
               c_iss(1)        TYPE c VALUE 'I',
               c_os(1)         TYPE c VALUE 'Ó',
               c_oss(1)        TYPE c VALUE 'O',
               c_us(1)         TYPE c VALUE 'Ú',
               c_uss(1)        TYPE c VALUE 'U',
               c_n(1)          TYPE c VALUE 'ñ',
               c_nn(1)         TYPE c VALUE 'n',
               c_x(1)          TYPE c VALUE 'x',
               c_any(3)        TYPE c VALUE 'ANY'.

    DATA: lv_fldname   TYPE fieldname,
          lv_fld1      TYPE fieldname,
          lv_fld2      TYPE fieldname,
          lv_fld3      TYPE fieldname,
          lv_cons      TYPE i,
          lv_new       TYPE string,
          lv_string1   TYPE string,
          lv_string2   TYPE string,
          lv_get_alias TYPE boolean.

    DATA: ls_alias LIKE LINE OF gt_columns.

    FIELD-SYMBOLS: <fs_ind>   LIKE LINE OF gt_ind,
                   <fs_alias> LIKE LINE OF gt_columns.

    lv_cons = 0.

    IF ls_dfies_tab-datatype EQ c_node.
*      ls_dfies_tab = gv_dfies_tab.
    ENDIF.

    CHECK ls_dfies_tab-datatype NE c_node.
    APPEND INITIAL LINE TO gt_columns ASSIGNING <fs_alias>.
    <fs_alias>-mandt     = sy-mandt.
    <fs_alias>-tabname   = ls_dfies_tab-tabname.
    <fs_alias>-fldname   = ls_dfies_tab-fieldname.
    <fs_alias>-selection_field = <fs_alias>-key_field = ls_dfies_tab-keyflag.
    <fs_alias>-positionf = ls_dfies_tab-position.

    IF ls_dfies_tab-scrtext_s IS NOT INITIAL.
      lv_fldname = ls_dfies_tab-scrtext_s.
    ELSE.
      lv_fldname = ls_dfies_tab-fieldname.
    ENDIF.

    IF ls_dfies_tab-scrtext_l IS NOT INITIAL.
      <fs_alias>-description_field = ls_dfies_tab-scrtext_l.
    ENDIF.


    REPLACE ALL OCCURRENCES OF c_dots   IN lv_fldname WITH space.
    REPLACE ALL OCCURRENCES OF c_perc   IN lv_fldname WITH c_percentage .
    REPLACE ALL OCCURRENCES OF c_aa     IN lv_fldname WITH c_a.
    REPLACE ALL OCCURRENCES OF c_ee     IN lv_fldname WITH c_e.
    REPLACE ALL OCCURRENCES OF c_ii     IN lv_fldname WITH c_i.
    REPLACE ALL OCCURRENCES OF c_oo     IN lv_fldname WITH c_o.
    REPLACE ALL OCCURRENCES OF c_uu     IN lv_fldname WITH c_u.
    REPLACE ALL OCCURRENCES OF c_as     IN lv_fldname WITH c_ass.
    REPLACE ALL OCCURRENCES OF c_es     IN lv_fldname WITH c_ess.
    REPLACE ALL OCCURRENCES OF c_is     IN lv_fldname WITH c_iss.
    REPLACE ALL OCCURRENCES OF c_os     IN lv_fldname WITH c_oss.
    REPLACE ALL OCCURRENCES OF c_us     IN lv_fldname WITH c_uss.
    REPLACE ALL OCCURRENCES OF c_n      IN lv_fldname WITH c_nn.
    TRANSLATE lv_fldname TO LOWER CASE.
    SPLIT lv_fldname AT space INTO lv_fld1 lv_fld2 lv_fld3.

    REPLACE ALL OCCURRENCES OF REGEX '[^[:alnum:]]' IN lv_fld1 WITH space .
    REPLACE ALL OCCURRENCES OF REGEX '[^[:alnum:]]' IN lv_fld2 WITH space .
    REPLACE ALL OCCURRENCES OF REGEX '[^[:alnum:]]' IN lv_fld3 WITH space .

    IF lv_fld1 IS INITIAL OR lv_fld1+0(1)  CA '0123456789'.
      lv_fldname = ls_dfies_tab-scrtext_m.


      REPLACE ALL OCCURRENCES OF c_aa     IN lv_fldname WITH c_a.
      REPLACE ALL OCCURRENCES OF c_ee     IN lv_fldname WITH c_e.
      REPLACE ALL OCCURRENCES OF c_ii     IN lv_fldname WITH c_i.
      REPLACE ALL OCCURRENCES OF c_oo     IN lv_fldname WITH c_o.
      REPLACE ALL OCCURRENCES OF c_uu     IN lv_fldname WITH c_u.
      REPLACE ALL OCCURRENCES OF c_as     IN lv_fldname WITH c_ass.
      REPLACE ALL OCCURRENCES OF c_es     IN lv_fldname WITH c_ess.
      REPLACE ALL OCCURRENCES OF c_is     IN lv_fldname WITH c_iss.
      REPLACE ALL OCCURRENCES OF c_os     IN lv_fldname WITH c_oss.
      REPLACE ALL OCCURRENCES OF c_us     IN lv_fldname WITH c_uss.
      REPLACE ALL OCCURRENCES OF c_n      IN lv_fldname WITH c_nn.

      REPLACE ALL OCCURRENCES OF c_dots   IN lv_fldname WITH space.
      REPLACE ALL OCCURRENCES OF c_perc   IN lv_fldname WITH c_percentage .
      TRANSLATE lv_fldname TO LOWER CASE.
      SPLIT lv_fldname AT space INTO lv_fld1 lv_fld2 lv_fld3.

      REPLACE ALL OCCURRENCES OF REGEX '[^[:alnum:]]' IN lv_fld1 WITH space .
      REPLACE ALL OCCURRENCES OF REGEX '[^[:alnum:]]' IN lv_fld2 WITH space .
      REPLACE ALL OCCURRENCES OF REGEX '[^[:alnum:]]' IN lv_fld3 WITH space .
    ENDIF.

    IF lv_fld3 IS NOT INITIAL.
      lv_fldname = |{ lv_fld1 }| & |{ c_undersc }| & |{ lv_fld2 }| & |{ c_undersc }| & |{ lv_fld3 }|.
    ELSEIF lv_fld2 IS NOT INITIAL.
      lv_fldname = |{ lv_fld1 }| & |{ c_undersc }| & |{ lv_fld2 }|.
    ELSE.
      lv_fldname = lv_fld1.
    ENDIF.
    REPLACE ALL OCCURRENCES OF c_sum    IN lv_fldname WITH c_undersc .
    REPLACE ALL OCCURRENCES OF c_guion  IN lv_fldname WITH c_undersc .

    IF lv_fldname+0(1) CA '0123456789'.
      lv_fldname+0(1) = c_undersc.
    ENDIF.

    CLEAR lv_get_alias.
    SORT gt_columns_alv BY tabname fldname.
    READ TABLE gt_columns_alv TRANSPORTING NO FIELDS WITH KEY tabname = ls_dfies_tab-tabname
                                                              fldname = ls_dfies_tab-fieldname BINARY SEARCH.
    IF sy-subrc = 0.
      lv_get_alias = abap_true.
    ENDIF.
    IF gv_domainv = c_any.
      lv_get_alias = abap_true.
    ENDIF.

    READ TABLE gt_tables TRANSPORTING NO FIELDS WITH KEY  parent_relation = ls_dfies_tab-tabname
                                                          field_main      = ls_dfies_tab-fieldname.
    IF sy-subrc = 0.
      lv_get_alias = abap_true.
      <fs_alias>-seckey_field = abap_true.
    ENDIF.

    READ TABLE gt_tables TRANSPORTING NO FIELDS WITH KEY  tabname         = ls_dfies_tab-tabname
                                                          field_sec       = ls_dfies_tab-fieldname.
    IF sy-subrc = 0.
      lv_get_alias = abap_true.
      <fs_alias>-seckey_field = abap_true.
    ENDIF.

    IF ls_dfies_tab-keyflag = 'X'.
      lv_get_alias = abap_true.
    ENDIF.

    IF gv_force_alias = abap_true.
      lv_get_alias = abap_true.
    ENDIF.

    IF lv_get_alias = abap_true.
      SORT gt_existing_columns BY tabname fldname.
      READ TABLE gt_existing_columns INTO gs_existing_columns WITH KEY tabname = ls_dfies_tab-tabname fldname = ls_dfies_tab-fieldname BINARY SEARCH.
      IF sy-subrc = 0 AND gs_existing_columns-alias_fldname IS NOT INITIAL.
        <fs_alias>-alias_fldname  =  gs_existing_columns-alias_fldname.
        READ TABLE gt_ind ASSIGNING <fs_ind> WITH KEY alias   = <fs_alias>-alias_fldname BINARY SEARCH.  "*********
        IF sy-subrc NE 0.
          APPEND INITIAL LINE TO gt_ind ASSIGNING <fs_ind>.
        ENDIF.
*        MOVE-CORRESPONDING gs_existing_columns TO <fs_ind>.
        <fs_ind>-alias = gs_existing_columns-alias_fldname.
        <fs_ind>-cons = 0.
      ELSE.
        SORT gt_existing_columns BY fldname.
        READ TABLE gt_existing_columns INTO gs_existing_columns WITH KEY fldname = ls_dfies_tab-fieldname BINARY SEARCH.
        IF sy-subrc = 0 AND gs_existing_columns-alias_fldname IS NOT INITIAL.
          <fs_alias>-alias_fldname  =  gs_existing_columns-alias_fldname.
          READ TABLE gt_ind ASSIGNING <fs_ind> WITH KEY alias   = <fs_alias>-alias_fldname BINARY SEARCH.  "*********
          IF sy-subrc NE 0.
            APPEND INITIAL LINE TO gt_ind ASSIGNING <fs_ind>.
          ENDIF.
*          MOVE-CORRESPONDING gs_existing_columns TO <fs_ind>.
          <fs_ind>-alias = gs_existing_columns-alias_fldname.
          <fs_ind>-cons = 0.
        ENDIF.
      ENDIF.
*    ENDIF.
        IF strlen( <fs_alias>-alias_fldname ) > 27.
          <fs_alias>-alias_fldname = <fs_alias>-alias_fldname(27).
        ENDIF.

      IF <fs_alias>-alias_fldname IS INITIAL.
        SORT gt_columns BY fldname alias_fldname DESCENDING.
        READ TABLE gt_columns INTO ls_alias WITH KEY fldname = ls_dfies_tab-fieldname BINARY SEARCH.
        IF sy-subrc = 0 AND ls_alias-alias_fldname IS NOT INITIAL.
          <fs_alias>-alias_fldname  =  ls_alias-alias_fldname.
          READ TABLE gt_ind ASSIGNING <fs_ind> WITH KEY alias   = <fs_alias>-alias_fldname BINARY SEARCH.  "*********
          IF sy-subrc NE 0.
            APPEND INITIAL LINE TO gt_ind ASSIGNING <fs_ind>.
          ENDIF.
*        MOVE-CORRESPONDING ls_alias TO <fs_ind>.
          <fs_ind>-alias = ls_alias-alias_fldname.
          <fs_ind>-cons = 0.
        ELSE.
          SORT gt_columns BY alias_fldname.
          READ TABLE gt_columns INTO ls_alias WITH KEY alias_fldname = lv_fldname BINARY SEARCH.
          IF sy-subrc = 0 AND ls_alias-fldname NE <fs_alias>-fldname.
            SORT gt_ind BY alias.
            READ TABLE gt_ind ASSIGNING <fs_ind> WITH KEY alias   = lv_fldname BINARY SEARCH.
            IF sy-subrc = 0.
              <fs_ind>-cons = <fs_ind>-cons + 1.
              lv_cons = <fs_ind>-cons.
            ELSE.
              APPEND INITIAL LINE TO gt_ind ASSIGNING <fs_ind>.
              MOVE-CORRESPONDING ls_alias TO <fs_ind>.
              <fs_ind>-alias = ls_alias-alias_fldname.
              <fs_ind>-cons = 1.
              lv_cons = <fs_ind>-cons.
            ENDIF.
          ENDIF.
        ENDIF.

        IF <fs_alias>-alias_fldname IS INITIAL.
          IF lv_cons = 0.
            <fs_alias>-alias_fldname = lv_fldname.
          ELSE.
            lv_fldname = |{ lv_fldname }| & |{ <fs_ind>-cons }|.
            <fs_alias>-alias_fldname = lv_fldname.
          ENDIF.
        ENDIF.

        IF ls_dfies_tab-fieldname = 'MANDT'
        OR ls_dfies_tab-fieldname = 'mandt'.
          gv_dfies_mandt = ls_dfies_tab.
        ENDIF.

        DATA: lv_lower TYPE string,
              lv_upper TYPE string.

        lv_lower = <fs_alias>-alias_fldname.
        lv_upper = <fs_alias>-alias_fldname.
        TRANSLATE lv_lower TO LOWER CASE.
        TRANSLATE lv_upper TO UPPER CASE.

        DATA: ls_reserved LIKE LINE OF gt_reserved.

*    ls_reserved = VALUE #( gt_reserved[ name = lv_lower ] OPTIONAL ).
        READ TABLE gt_reserved INTO ls_reserved WITH KEY name = lv_lower .
        IF ls_reserved IS INITIAL.
          READ TABLE gt_reserved INTO ls_reserved WITH KEY name = lv_upper .
*      ls_reserved = VALUE #( gt_reserved[ name = lv_upper ] OPTIONAL ).
        ELSE.
          lv_new = |{ ls_reserved-name }{ c_x }|.
          REPLACE ls_reserved-name WITH lv_new INTO <fs_alias>-alias_fldname .
        ENDIF.
        IF NOT ls_reserved IS INITIAL.
          lv_new = |{ lv_upper }{ c_x }|.
          REPLACE <fs_alias>-alias_fldname WITH lv_new INTO <fs_alias>-alias_fldname .
          IF sy-subrc NE 0.
            lv_new = |{ lv_lower }{ c_x }|.
            REPLACE <fs_alias>-alias_fldname WITH lv_new INTO <fs_alias>-alias_fldname .
          ENDIF.
        ENDIF.
        IF strlen( <fs_alias>-alias_fldname ) > 27.
          <fs_alias>-alias_fldname = <fs_alias>-alias_fldname(27).
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD ADD_INFO_LINE_FIELD_NEW.

    CONSTANTS: c_undersc       TYPE c VALUE '_',
               c_node          TYPE string VALUE 'NODE',
               c_dot           TYPE c VALUE '.',
               c_perc          TYPE c VALUE '%',
               c_dots          TYPE c VALUE ':',
               c_sum           TYPE c VALUE '+',
               c_guion         TYPE c VALUE '-',
               c_percentage(4) TYPE c VALUE 'perc',
               c_aa(1)         TYPE c VALUE 'á',
               c_a(1)          TYPE c VALUE 'a',
               c_ee(1)         TYPE c VALUE 'é',
               c_e(1)          TYPE c VALUE 'e',
               c_ii(1)         TYPE c VALUE 'í',
               c_i(1)          TYPE c VALUE 'i',
               c_oo(1)         TYPE c VALUE 'ó',
               c_o(1)          TYPE c VALUE 'o',
               c_uu(1)         TYPE c VALUE 'ú',
               c_u(1)          TYPE c VALUE 'u',
               c_as(1)         TYPE c VALUE 'Á',
               c_ass(1)        TYPE c VALUE 'A',
               c_es(1)         TYPE c VALUE 'É',
               c_ess(1)        TYPE c VALUE 'E',
               c_is(1)         TYPE c VALUE 'Í',
               c_iss(1)        TYPE c VALUE 'I',
               c_os(1)         TYPE c VALUE 'Ó',
               c_oss(1)        TYPE c VALUE 'O',
               c_us(1)         TYPE c VALUE 'Ú',
               c_uss(1)        TYPE c VALUE 'U',
               c_n(1)          TYPE c VALUE 'ñ',
               c_nn(1)         TYPE c VALUE 'n',
               c_x(1)          TYPE c VALUE 'x',
               c_any(3)        TYPE c VALUE 'ANY'.

    DATA: lv_fldname   TYPE fieldname,
          lv_fld1      TYPE fieldname,
          lv_fld2      TYPE fieldname,
          lv_fld3      TYPE fieldname,
          lv_cons      TYPE i,
          lv_new       TYPE string,
          lv_string1   TYPE string,
          lv_string2   TYPE string,
          lv_get_alias TYPE boolean.

    DATA: ls_alias LIKE LINE OF gt_col_all.

    FIELD-SYMBOLS: <fs_ind>   LIKE LINE OF gt_ind,
                   <fs_alias> LIKE LINE OF gt_col_all.

    lv_cons = 0.

    IF ls_dfies_tab-datatype EQ c_node.
*      ls_dfies_tab = gv_dfies_tab.
    ENDIF.

    CHECK ls_dfies_tab-datatype NE c_node.
    APPEND INITIAL LINE TO gt_col_all ASSIGNING <fs_alias>.
    <fs_alias>-mandt     = sy-mandt.
    <fs_alias>-tabname   = ls_dfies_tab-tabname.
    <fs_alias>-fldname   = ls_dfies_tab-fieldname.
    <fs_alias>-selection_field = <fs_alias>-key_field = ls_dfies_tab-keyflag.
    <fs_alias>-positionf = ls_dfies_tab-position.

    IF ls_dfies_tab-scrtext_s IS NOT INITIAL.
      lv_fldname = ls_dfies_tab-scrtext_s.
    ELSE.
      lv_fldname = ls_dfies_tab-fieldname.
    ENDIF.

    IF ls_dfies_tab-scrtext_l IS NOT INITIAL.
      <fs_alias>-description_field = ls_dfies_tab-scrtext_l.
    ENDIF.


    REPLACE ALL OCCURRENCES OF c_dots   IN lv_fldname WITH space.
    REPLACE ALL OCCURRENCES OF c_perc   IN lv_fldname WITH c_percentage .
    REPLACE ALL OCCURRENCES OF c_aa     IN lv_fldname WITH c_a.
    REPLACE ALL OCCURRENCES OF c_ee     IN lv_fldname WITH c_e.
    REPLACE ALL OCCURRENCES OF c_ii     IN lv_fldname WITH c_i.
    REPLACE ALL OCCURRENCES OF c_oo     IN lv_fldname WITH c_o.
    REPLACE ALL OCCURRENCES OF c_uu     IN lv_fldname WITH c_u.
    REPLACE ALL OCCURRENCES OF c_as     IN lv_fldname WITH c_ass.
    REPLACE ALL OCCURRENCES OF c_es     IN lv_fldname WITH c_ess.
    REPLACE ALL OCCURRENCES OF c_is     IN lv_fldname WITH c_iss.
    REPLACE ALL OCCURRENCES OF c_os     IN lv_fldname WITH c_oss.
    REPLACE ALL OCCURRENCES OF c_us     IN lv_fldname WITH c_uss.
    REPLACE ALL OCCURRENCES OF c_n      IN lv_fldname WITH c_nn.
    TRANSLATE lv_fldname TO LOWER CASE.
    SPLIT lv_fldname AT space INTO lv_fld1 lv_fld2 lv_fld3.

    REPLACE ALL OCCURRENCES OF REGEX '[^[:alnum:]]' IN lv_fld1 WITH space .
    REPLACE ALL OCCURRENCES OF REGEX '[^[:alnum:]]' IN lv_fld2 WITH space .
    REPLACE ALL OCCURRENCES OF REGEX '[^[:alnum:]]' IN lv_fld3 WITH space .

    IF lv_fld1 IS INITIAL OR lv_fld1+0(1)  CA '0123456789'.
      lv_fldname = ls_dfies_tab-scrtext_m.


      REPLACE ALL OCCURRENCES OF c_aa     IN lv_fldname WITH c_a.
      REPLACE ALL OCCURRENCES OF c_ee     IN lv_fldname WITH c_e.
      REPLACE ALL OCCURRENCES OF c_ii     IN lv_fldname WITH c_i.
      REPLACE ALL OCCURRENCES OF c_oo     IN lv_fldname WITH c_o.
      REPLACE ALL OCCURRENCES OF c_uu     IN lv_fldname WITH c_u.
      REPLACE ALL OCCURRENCES OF c_as     IN lv_fldname WITH c_ass.
      REPLACE ALL OCCURRENCES OF c_es     IN lv_fldname WITH c_ess.
      REPLACE ALL OCCURRENCES OF c_is     IN lv_fldname WITH c_iss.
      REPLACE ALL OCCURRENCES OF c_os     IN lv_fldname WITH c_oss.
      REPLACE ALL OCCURRENCES OF c_us     IN lv_fldname WITH c_uss.
      REPLACE ALL OCCURRENCES OF c_n      IN lv_fldname WITH c_nn.

      REPLACE ALL OCCURRENCES OF c_dots   IN lv_fldname WITH space.
      REPLACE ALL OCCURRENCES OF c_perc   IN lv_fldname WITH c_percentage .
      TRANSLATE lv_fldname TO LOWER CASE.
      SPLIT lv_fldname AT space INTO lv_fld1 lv_fld2 lv_fld3.

      REPLACE ALL OCCURRENCES OF REGEX '[^[:alnum:]]' IN lv_fld1 WITH space .
      REPLACE ALL OCCURRENCES OF REGEX '[^[:alnum:]]' IN lv_fld2 WITH space .
      REPLACE ALL OCCURRENCES OF REGEX '[^[:alnum:]]' IN lv_fld3 WITH space .
    ENDIF.

    IF lv_fld3 IS NOT INITIAL.
      lv_fldname = |{ lv_fld1 }| & |{ c_undersc }| & |{ lv_fld2 }| & |{ c_undersc }| & |{ lv_fld3 }|.
    ELSEIF lv_fld2 IS NOT INITIAL.
      lv_fldname = |{ lv_fld1 }| & |{ c_undersc }| & |{ lv_fld2 }|.
    ELSE.
      lv_fldname = lv_fld1.
    ENDIF.
    REPLACE ALL OCCURRENCES OF c_sum    IN lv_fldname WITH c_undersc .
    REPLACE ALL OCCURRENCES OF c_guion  IN lv_fldname WITH c_undersc .

    IF lv_fldname+0(1) CA '0123456789'.
      lv_fldname+0(1) = c_undersc.
    ENDIF.

    CLEAR lv_get_alias.
    SORT gt_columns_alv BY tabname fldname.
    READ TABLE gt_columns_alv TRANSPORTING NO FIELDS WITH KEY tabname = ls_dfies_tab-tabname
                                                              fldname = ls_dfies_tab-fieldname BINARY SEARCH.
    IF sy-subrc = 0.
      lv_get_alias = abap_true.
    ENDIF.
    IF gv_domainv = c_any.
      lv_get_alias = abap_true.
    ENDIF.

    READ TABLE gt_tables TRANSPORTING NO FIELDS WITH KEY  parent_relation = ls_dfies_tab-tabname
                                                          field_main      = ls_dfies_tab-fieldname.
    IF sy-subrc = 0.
      lv_get_alias = abap_true.
      <fs_alias>-seckey_field = abap_true.
    ENDIF.

    READ TABLE gt_tables TRANSPORTING NO FIELDS WITH KEY  tabname         = ls_dfies_tab-tabname
                                                          field_sec       = ls_dfies_tab-fieldname.
    IF sy-subrc = 0.
      lv_get_alias = abap_true.
      <fs_alias>-seckey_field = abap_true.
    ENDIF.

    IF ls_dfies_tab-keyflag = 'X'.
      lv_get_alias = abap_true.
    ENDIF.

    IF gv_force_alias = abap_true.
      lv_get_alias = abap_true.
    ENDIF.

    IF lv_get_alias = abap_true.
      SORT gt_existing_col_all BY tabname fldname.
      READ TABLE gt_existing_col_all INTO gs_existing_col_all WITH KEY tabname = ls_dfies_tab-tabname fldname = ls_dfies_tab-fieldname BINARY SEARCH.
      IF sy-subrc = 0 AND gs_existing_col_all-alias_fldname IS NOT INITIAL.
        <fs_alias>-alias_fldname  =  gs_existing_col_all-alias_fldname.
        READ TABLE gt_ind ASSIGNING <fs_ind> WITH KEY alias   = <fs_alias>-alias_fldname BINARY SEARCH.  "*********
        IF sy-subrc NE 0.
          APPEND INITIAL LINE TO gt_ind ASSIGNING <fs_ind>.
        ENDIF.
*        MOVE-CORRESPONDING gs_existing_col_all TO <fs_ind>.
        <fs_ind>-alias = gs_existing_col_all-alias_fldname.
        <fs_ind>-cons = 0.
      ELSE.
        SORT gt_existing_col_all BY fldname.
        READ TABLE gt_existing_col_all INTO gs_existing_col_all WITH KEY fldname = ls_dfies_tab-fieldname BINARY SEARCH.
        IF sy-subrc = 0 AND gs_existing_col_all-alias_fldname IS NOT INITIAL.
          <fs_alias>-alias_fldname  =  gs_existing_col_all-alias_fldname.
          READ TABLE gt_ind ASSIGNING <fs_ind> WITH KEY alias   = <fs_alias>-alias_fldname BINARY SEARCH.  "*********
          IF sy-subrc NE 0.
            APPEND INITIAL LINE TO gt_ind ASSIGNING <fs_ind>.
          ENDIF.
*          MOVE-CORRESPONDING gs_existing_col_all TO <fs_ind>.
          <fs_ind>-alias = gs_existing_col_all-alias_fldname.
          <fs_ind>-cons = 0.
        ENDIF.
      ENDIF.
*    ENDIF.
      IF strlen( <fs_alias>-alias_fldname ) > 27.
         <fs_alias>-alias_fldname = <fs_alias>-alias_fldname(27).
      ENDIF.

      IF <fs_alias>-alias_fldname IS INITIAL.
        SORT gt_col_all BY fldname alias_fldname DESCENDING.
        READ TABLE gt_col_all INTO ls_alias WITH KEY fldname = ls_dfies_tab-fieldname BINARY SEARCH.
        IF sy-subrc = 0 AND ls_alias-alias_fldname IS NOT INITIAL.
          <fs_alias>-alias_fldname  =  ls_alias-alias_fldname.
          READ TABLE gt_ind ASSIGNING <fs_ind> WITH KEY alias   = <fs_alias>-alias_fldname BINARY SEARCH.  "*********
          IF sy-subrc NE 0.
            APPEND INITIAL LINE TO gt_ind ASSIGNING <fs_ind>.
          ENDIF.
*        MOVE-CORRESPONDING ls_alias TO <fs_ind>.
          <fs_ind>-alias = ls_alias-alias_fldname.
          <fs_ind>-cons = 0.
        ELSE.
          SORT gt_col_all BY alias_fldname.
          READ TABLE gt_col_all INTO ls_alias WITH KEY alias_fldname = lv_fldname BINARY SEARCH.
          IF sy-subrc = 0 AND ls_alias-fldname NE <fs_alias>-fldname.
            SORT gt_ind BY alias.
            READ TABLE gt_ind ASSIGNING <fs_ind> WITH KEY alias   = lv_fldname BINARY SEARCH.
            IF sy-subrc = 0.
              <fs_ind>-cons = <fs_ind>-cons + 1.
              lv_cons = <fs_ind>-cons.
            ELSE.
              APPEND INITIAL LINE TO gt_ind ASSIGNING <fs_ind>.
              MOVE-CORRESPONDING ls_alias TO <fs_ind>.
              <fs_ind>-alias = ls_alias-alias_fldname.
              <fs_ind>-cons = 1.
              lv_cons = <fs_ind>-cons.
            ENDIF.
          ENDIF.
        ENDIF.

        IF <fs_alias>-alias_fldname IS INITIAL.
          IF lv_cons = 0.
            <fs_alias>-alias_fldname = lv_fldname.
          ELSE.
            lv_fldname = |{ lv_fldname }| & |{ <fs_ind>-cons }|.
            <fs_alias>-alias_fldname = lv_fldname.
          ENDIF.
        ENDIF.

        IF ls_dfies_tab-fieldname = 'MANDT'
        OR ls_dfies_tab-fieldname = 'mandt'.
          gv_dfies_mandt = ls_dfies_tab.
        ENDIF.

        DATA: lv_lower TYPE string,
              lv_upper TYPE string.

        lv_lower = <fs_alias>-alias_fldname.
        lv_upper = <fs_alias>-alias_fldname.
        TRANSLATE lv_lower TO LOWER CASE.
        TRANSLATE lv_upper TO UPPER CASE.

        DATA: ls_reserved LIKE LINE OF gt_reserved.

*    ls_reserved = VALUE #( gt_reserved[ name = lv_lower ] OPTIONAL ).
        READ TABLE gt_reserved INTO ls_reserved WITH KEY name = lv_lower .
        IF ls_reserved IS INITIAL.
          READ TABLE gt_reserved INTO ls_reserved WITH KEY name = lv_upper .
*      ls_reserved = VALUE #( gt_reserved[ name = lv_upper ] OPTIONAL ).
        ELSE.
          lv_new = |{ ls_reserved-name }{ c_x }|.
          REPLACE ls_reserved-name WITH lv_new INTO <fs_alias>-alias_fldname .
        ENDIF.
        IF NOT ls_reserved IS INITIAL.
          lv_new = |{ lv_upper }{ c_x }|.
          REPLACE <fs_alias>-alias_fldname WITH lv_new INTO <fs_alias>-alias_fldname .
          IF sy-subrc NE 0.
            lv_new = |{ lv_lower }{ c_x }|.
            REPLACE <fs_alias>-alias_fldname WITH lv_new INTO <fs_alias>-alias_fldname .
          ENDIF.
        ENDIF.
        IF strlen( <fs_alias>-alias_fldname ) > 27.
          <fs_alias>-alias_fldname = <fs_alias>-alias_fldname(27).
        ENDIF.
      ENDIF.
    ENDIF.
***    VALIDATE ALIAS
    DATA LS_COL_ALL TYPE zonta_oc_col_all.
    DO 10 TIMES.
      if <fs_alias>-alias_fldname is INITIAL.
        CONCATENATE <fs_alias>-fldname '01' INTO  <fs_alias>-alias_fldname.
        CONDENSE  <fs_alias>-alias_fldname.
        TRANSLATE  <fs_alias>-alias_fldname TO LOWER CASE.
      endif.
      READ TABLE GT_COL_ALL INTO LS_col_all WITH KEY ALIAS_FLDNAME = <fs_alias>-alias_fldname tabname = <fs_alias>-tabname.
      if sy-subrc ne 0.
        exit.
      else.
        if strlen( <fs_alias>-alias_fldname ) < 23.
          CONCATENATE <fs_alias>-alias_fldname <fs_alias>-POSITIONF into <fs_alias>-alias_fldname.
          exit.
        else.
          CONCATENATE <fs_alias>-alias_fldname+0(23) <fs_alias>-POSITIONF into <fs_alias>-alias_fldname.
          exit.
        endif.
      endif.
    ENDDO.
  ENDMETHOD.


  METHOD APPEND_BASE_UNIQUE.
  "Prevent duplicates of base rows
  LOOP AT gt_dbjc INTO gs_dbjc
       WHERE jind = space
         AND ltable = iv_ltable
         AND rtable = iv_rtable.
    RETURN.
  ENDLOOP.

  CLEAR gs_dbjc.
  gs_dbjc-jind   = space.
  gs_dbjc-ltable = iv_ltable.
  gs_dbjc-rtable = iv_rtable.
  APPEND gs_dbjc TO gt_dbjc.
  ENDMETHOD.


  METHOD append_cond_or_flipped.

    DATA: lv_tmp70 TYPE c LENGTH 70.

    "1) Direct orientation conditions
    LOOP AT gt_dbjc_old INTO gs_old
         WHERE jind   = '1'
           AND ltable = iv_ltable
           AND rtable = iv_rtable.
      APPEND gs_old TO gt_dbjc.
    ENDLOOP.

    "2) Reverse orientation -> flip L/R names
    LOOP AT gt_dbjc_old INTO gs_old
         WHERE jind   = '1'
           AND ltable = iv_rtable
           AND rtable = iv_ltable.

      CLEAR gs_dbjc.
      gs_dbjc = gs_old.
      gs_dbjc-ltable = iv_ltable.
      gs_dbjc-rtable = iv_rtable.

      lv_tmp70       = gs_dbjc-lname.
      gs_dbjc-lname  = gs_dbjc-rname.
      gs_dbjc-rname  = lv_tmp70.

      APPEND gs_dbjc TO gt_dbjc.
    ENDLOOP.
  ENDMETHOD.


  METHOD build_sort_map.
    DATA: ls_dbsg LIKE LINE OF gt_dbsg,
          ls_map  LIKE LINE OF gt_dbsg_map.

    REFRESH gt_dbsg_map.
    LOOP AT gt_dbsg INTO ls_dbsg.
      ls_map-sort = ls_dbsg-tindx.
      ls_map-table = ls_dbsg-name.
      INSERT ls_map  INTO TABLE gt_dbsg_map.
    ENDLOOP.
  ENDMETHOD.


  METHOD constructor.
    CLEAR gt_tables[].

    SELECT *
    INTO TABLE gt_tables
     FROM zonta_relations
     WHERE domainv       = iv_domainv
       AND business_proc = iv_business_proc.

    gv_domainv = iv_domainv.
    gv_business_proc = iv_business_proc.
  ENDMETHOD.


  METHOD create_tables_for_join.

*    TYPES: BEGIN OF st_cds,
*             ddls_name TYPE ddlname,
*             view_name TYPE objectname,
*           END OF st_cds.

    DATA: lv_mode      TYPE  i.
    DATA: ls_maint   TYPE zonta_relations,
          lt_tablesu TYPE STANDARD TABLE OF zonta_relations,
          ls_tables  TYPE zonta_relations,
          lt_dd02v   TYPE STANDARD TABLE OF dd02v,
          lv_ind     TYPE sy-tabix,
          ls_dbsg    LIKE LINE OF gt_dbsg,
          ls_dbjt    LIKE LINE OF gt_dbjt,
          ls_dban    LIKE LINE OF gt_dban,
          ls_dbjc    LIKE LINE OF gt_dbjc,
          ls_ttab    TYPE aqq_s_ttab,
          ls_sgtext  TYPE aqtxsg,
          ls_dd02v   TYPE dd02v,
*          ls_cds     TYPE st_cds,
          lv_top     TYPE i,
          lv_left    TYPE i,
          lv_mod     TYPE i,
          lv_rname   TYPE string,
          lv_lname   TYPE string.

    DATA: lv_sequence TYPE zonde_sequence,
          ls_ttmp     LIKE LINE OF gt_tables.

    CONSTANTS: lc_guion  TYPE c VALUE '-',
               lc_top    TYPE i VALUE 27,
               lc_width  TYPE i VALUE 250,
               lc_height TYPE i VALUE 200,
               lc_dist   TYPE i VALUE 50,
               lc_leftd  TYPE i VALUE 300,
               lc_lefti  TYPE i VALUE 50,
               lc_i      TYPE c LENGTH 1 VALUE 'I',
               lc_o      TYPE c LENGTH 1 VALUE 'L',
               lc_inner  TYPE string VALUE 'INNER',
               lc_outer  TYPE string VALUE 'LEFT OUTER'.

    DATA: ls_tables1 LIKE LINE OF gt_tables,
          ls_tables2 LIKE LINE OF it_tables.

    IF lines( it_tables ) = 0.
      SELECT *
      INTO TABLE gt_tables
       FROM zonta_relations
       WHERE domainv       = gv_domainv
         AND business_proc = gv_business_proc.
    ELSE.
      CLEAR gt_tables[].
*      MOVE-CORRESPONDING it_tables[] TO gt_tables[].

      REFRESH gt_tables[].
      LOOP AT it_tables INTO ls_tables2.
        CLEAR ls_tables1.
        MOVE-CORRESPONDING ls_tables2 TO ls_tables1.
        APPEND ls_tables1 TO gt_tables.
      ENDLOOP.
    ENDIF.

    lt_tablesu[] = gt_tables[].
    SORT lt_tablesu BY sequence.
    DELETE ADJACENT DUPLICATES FROM lt_tablesu COMPARING sequence.

* Get current information of the business process
    IF lines( gt_tables ) > 0.
      SELECT *
        INTO TABLE lt_dd02v
        FROM dd02v
        FOR ALL ENTRIES IN gt_tables
        WHERE tabname    = gt_tables-tabname
          AND ddlanguage = sy-langu.

      SORT lt_dd02v BY tabname.
      SORT gt_tables BY sequence tabname.
      READ TABLE gt_tables INTO ls_maint INDEX 1.

      lv_ind = 1.
      lv_top  = lc_top.
      lv_left = lc_lefti.

      LOOP AT lt_tablesu INTO ls_tables.

* GS_DBSG
        CLEAR ls_dbsg.
        ls_dbsg-name  = ls_tables-tabname.
        ls_dbsg-tindx = ls_tables-sequence + 1.
        APPEND ls_dbsg TO gt_dbsg.

*GT_DBJT
        CLEAR ls_dbjt.
        lv_sequence = ls_tables-sequence + 1.
        READ TABLE gt_tables INTO ls_ttmp WITH KEY sequence = lv_sequence.
        CASE ls_ttmp-join_type.
          WHEN lc_inner.
            ls_dbjt-outerflag  = lc_i.
          WHEN lc_outer.
            ls_dbjt-outerflag  = lc_o.
          WHEN OTHERS.
            CLEAR ls_dbjt-outerflag.
        ENDCASE.

        ls_dbjt-table     = ls_tables-tabname.
        ls_dbjt-top_vz    = lv_top.
        ls_dbjt-left_vz   = lv_left.
        lv_left           = lv_left + lc_leftd.
        ls_dbjt-width_vz  = lc_width.
        ls_dbjt-height_vz = lc_height.
        APPEND ls_dbjt TO gt_dbjt.
        lv_mod = lv_ind MOD 4.

        IF lv_mod = 0.
          lv_top  = lv_top  + lc_height + lc_dist.
          lv_left = lc_lefti.
        ENDIF.


* GT_TTAB
        CLEAR ls_ttab.
        CLEAR ls_dd02v.
        ls_ttab-orig_name = ls_tables-tabname.

        READ TABLE lt_dd02v INTO ls_dd02v WITH KEY tabname = ls_tables-tabname BINARY SEARCH.
        IF sy-subrc = 0.
          ls_ttab-ddic = ls_dd02v.
        ELSE.
* ECC does not have CDS views
*          SELECT SINGLE ddls_name view_name
*            INTO ls_cds
*            FROM acm_ddlstbviw_1r
*            WHERE ddls_name = ls_tables-tabname.
*          IF sy-subrc = 0.
*            SELECT SINGLE *
*              INTO ls_dd02v
*              FROM dd02v
*              WHERE tabname = ls_cds-view_name.
*            ls_ttab-ddic = ls_dd02v.
*          ENDIF.
        ENDIF.
        IF NOT ls_tables-description_table IS INITIAL.
          ls_ttab-ddic-ddtext = ls_tables-description_table.
        ENDIF.
        APPEND ls_ttab TO gt_ttab.

* GT_DBJC
        IF ls_tables-sequence NE 1.
          CLEAR ls_dbjc.
          ls_dbjc-ltable = ls_tables-parent_relation.  "parent
          ls_dbjc-rtable = ls_tables-tabname.  "table
          APPEND ls_dbjc TO gt_dbjc.
        ENDIF.

* GT_DBAN
        CLEAR ls_dban.
        ls_dban-table = ls_tables-tabname.
        ls_dban-alias = ls_tables-alias_tabname.
        APPEND ls_dban TO gt_dban.


      ENDLOOP.

      LOOP AT gt_tables INTO ls_tables WHERE sequence  > 1.
*GT_DBJC
        CONCATENATE ls_maint-tabname lc_guion ls_tables-field_main INTO lv_lname.
        CONCATENATE ls_tables-tabname lc_guion ls_tables-field_sec INTO lv_rname.

        CLEAR ls_dbjc.
        ls_dbjc-ltable = ls_tables-parent_relation.  "parent
        ls_dbjc-rtable = ls_tables-tabname.  "table
        ls_dbjc-jind   = ls_tables-subsequence+1(2). "lv_ind.
        ls_dbjc-lname  = lv_lname.
        ls_dbjc-rname  = lv_rname.
        APPEND ls_dbjc TO gt_dbjc.


*          lv_ind = lv_ind + 1.
      ENDLOOP.
    ENDIF.


    et_dbsg[] = gt_dbsg[].
    et_dbjt[] = gt_dbjt[].
    et_ttab[] = gt_ttab[].
    et_dbjc[] = gt_dbjc[].
    et_dban[] = gt_dban[].

  ENDMETHOD.


  METHOD fill_info_field.


    DATA: lt_dfies_tab TYPE TABLE OF   dfies,
          ls_dfies_tab TYPE  dfies,
          lv_fldname   TYPE zonta_oc_col_all-fldname,
          lv_fld1      TYPE zonta_oc_col_all-fldname,
          lv_fld2      TYPE zonta_oc_col_all-fldname,
          lv_fld3      TYPE zonta_oc_col_all-fldname.

    DATA: lt_tables       TYPE STANDARD TABLE OF zonta_relations,
          ls_ex_relations TYPE zonta_relations,
          ls_ex_columns   TYPE zonta_oc_col_all,
          ls_columns      TYPE zonta_oc_col_all,
          ls_col_alv      TYPE zonst_columns_alv_ext,
          ls_table        LIKE LINE OF lt_tables.

    FIELD-SYMBOLS: <fs_col> TYPE zonta_oc_columns.

    REFRESH: gt_tables[],
             gt_ind[],
             gt_columns[],
             gt_reserved[],
             gt_existing_columns[],
             gt_existing_relations[],
             gt_columns_alv[].

    CLEAR:   gv_any.

    gv_any = iv_any.
    gt_columns_alv[] = it_columns[].
    gv_force_alias = abap_false.

    IF iv_alias IS NOT INITIAL.
      gv_force_alias = iv_alias.
    ENDIF.

* Get reserved names
    SELECT name
      INTO CORRESPONDING FIELDS OF TABLE gt_reserved
      FROM zonta_oc_reserv.

    IF it_tables IS INITIAL.
      SELECT *
        INTO TABLE lt_tables
        FROM zonta_relations
        WHERE domainv = gv_domainv
          AND business_proc = gv_business_proc.

    ELSE.
      lt_tables[] = it_tables[].
    ENDIF.

    gt_tables[] = lt_tables[].
    IF lines( lt_tables ) > 0.
      SELECT *
        INTO TABLE gt_existing_relations
        FROM zonta_relations
        FOR ALL ENTRIES IN lt_tables
        WHERE NOT (  domainv     = gv_domainv
              AND business_proc  = gv_business_proc )
          AND tabname            = lt_tables-tabname
          AND alias_tabname      = lt_tables-alias_tabname.
      IF sy-subrc = 0.
        SELECT *
          INTO TABLE gt_existing_columns
          FROM zonta_oc_col_all
          FOR ALL ENTRIES IN gt_existing_relations
           WHERE tabname       = gt_existing_relations-tabname
             AND alias_tabname = gt_existing_relations-alias_tabname.
      ENDIF.
      SORT gt_existing_relations BY tabname.
      DELETE ADJACENT DUPLICATES FROM gt_existing_relations COMPARING tabname.
      SORT gt_existing_columns BY tabname fldname.
      DELETE ADJACENT DUPLICATES FROM gt_existing_columns COMPARING tabname fldname.
    ENDIF.

    LOOP AT gt_existing_relations INTO ls_table.

      CALL FUNCTION 'DDIF_FIELDINFO_GET'
        EXPORTING
          tabname        = ls_table-tabname
          langu          = sy-langu
        TABLES
          dfies_tab      = lt_dfies_tab
        EXCEPTIONS
          not_found      = 1
          internal_error = 2
          OTHERS         = 3.
      IF sy-subrc = 0.

        SORT lt_dfies_tab BY position.
        LOOP AT lt_dfies_tab INTO ls_dfies_tab.
          add_info_line_field( EXPORTING ls_dfies_tab = ls_dfies_tab ).
        ENDLOOP.
      ENDIF.

      DELETE lt_tables WHERE tabname = ls_table-tabname.

    ENDLOOP.

    SORT lt_tables BY sequence.
    LOOP AT lt_tables INTO ls_table.

      CALL FUNCTION 'DDIF_FIELDINFO_GET'
        EXPORTING
          tabname        = ls_table-tabname
          langu          = sy-langu
        TABLES
          dfies_tab      = lt_dfies_tab
        EXCEPTIONS
          not_found      = 1
          internal_error = 2
          OTHERS         = 3.
      IF sy-subrc = 0.

        SORT lt_dfies_tab BY position.
        LOOP AT lt_dfies_tab INTO ls_dfies_tab.
          add_info_line_field( EXPORTING ls_dfies_tab = ls_dfies_tab ).
        ENDLOOP.
      ENDIF.
    ENDLOOP.


    et_columns = gt_columns[].
    et_existing_rel = gt_existing_relations[].
    et_existing_col = gt_existing_columns[].

  ENDMETHOD.


  METHOD fill_info_field_new.


    DATA: lt_dfies_tab TYPE TABLE OF   dfies,
          ls_dfies_tab TYPE  dfies,
          lv_fldname   TYPE zonta_oc_col_all-fldname,
          lv_fld1      TYPE zonta_oc_col_all-fldname,
          lv_fld2      TYPE zonta_oc_col_all-fldname,
          lv_fld3      TYPE zonta_oc_col_all-fldname.

    DATA: lt_tables       TYPE STANDARD TABLE OF zonta_relations,
          ls_ex_relations TYPE zonta_relations,
          ls_ex_columns   TYPE zonta_oc_col_all,
          ls_columns      TYPE zonta_oc_col_all,
          ls_col_alv      TYPE zonst_columns_alv_ext,
          ls_table        LIKE LINE OF lt_tables.

    FIELD-SYMBOLS: <fs_col> TYPE zonta_oc_col_all.

    REFRESH: gt_tables[],
             gt_ind[],
             gt_col_all[],
             gt_reserved[],
             gt_existing_col_all[],
             gt_existing_relations[],
             gt_columns_alv[].

    CLEAR:   gv_any.

    gv_any = iv_any.
    gt_columns_alv[] = it_columns[].
    gv_force_alias = abap_false.

    IF iv_alias IS NOT INITIAL.
      gv_force_alias = iv_alias.
    ENDIF.

* Get reserved names
    SELECT name
      INTO CORRESPONDING FIELDS OF TABLE gt_reserved
      FROM zonta_oc_reserv.

    IF it_tables IS INITIAL.
      SELECT *
        INTO TABLE lt_tables
        FROM zonta_relations
        WHERE domainv = gv_domainv
          AND business_proc = gv_business_proc.

    ELSE.
      lt_tables[] = it_tables[].
    ENDIF.

    gt_tables[] = lt_tables[].
    IF lines( lt_tables ) > 0.
      SELECT *
        INTO TABLE gt_existing_relations
        FROM zonta_relations
        FOR ALL ENTRIES IN lt_tables
        WHERE NOT (  domainv     = gv_domainv
              AND business_proc  = gv_business_proc )
          AND tabname            = lt_tables-tabname
          AND alias_tabname      = lt_tables-alias_tabname.
      IF sy-subrc = 0.
        SELECT *
          INTO TABLE gt_existing_col_all
          FROM zonta_oc_col_all
          FOR ALL ENTRIES IN gt_existing_relations
           WHERE tabname       = gt_existing_relations-tabname
             AND alias_tabname = gt_existing_relations-alias_tabname.
      ENDIF.
      SORT gt_existing_relations BY tabname.
      DELETE ADJACENT DUPLICATES FROM gt_existing_relations COMPARING tabname.
      SORT gt_existing_col_all BY tabname fldname.
      DELETE ADJACENT DUPLICATES FROM gt_existing_col_all COMPARING tabname fldname.
    ENDIF.

    IF gv_any = abap_true AND lines( gt_existing_col_all ) = 0.
      gv_force_alias = abap_true.
    ENDIF.

    LOOP AT gt_existing_relations INTO ls_table.

      CALL FUNCTION 'DDIF_FIELDINFO_GET'
        EXPORTING
          tabname        = ls_table-tabname
          langu          = sy-langu
        TABLES
          dfies_tab      = lt_dfies_tab
        EXCEPTIONS
          not_found      = 1
          internal_error = 2
          OTHERS         = 3.
      IF sy-subrc = 0.

        SORT lt_dfies_tab BY position.
        LOOP AT lt_dfies_tab INTO ls_dfies_tab.
          add_info_line_field_new( EXPORTING ls_dfies_tab = ls_dfies_tab ).
        ENDLOOP.
      ENDIF.

      DELETE lt_tables WHERE tabname = ls_table-tabname.

    ENDLOOP.

    SORT lt_tables BY sequence.
    LOOP AT lt_tables INTO ls_table.

      CALL FUNCTION 'DDIF_FIELDINFO_GET'
        EXPORTING
          tabname        = ls_table-tabname
          langu          = sy-langu
        TABLES
          dfies_tab      = lt_dfies_tab
        EXCEPTIONS
          not_found      = 1
          internal_error = 2
          OTHERS         = 3.
      IF sy-subrc = 0.

        SORT lt_dfies_tab BY position.
        LOOP AT lt_dfies_tab INTO ls_dfies_tab.
          add_info_line_field_new( EXPORTING ls_dfies_tab = ls_dfies_tab ).
        ENDLOOP.
      ENDIF.
    ENDLOOP.


    et_columns = gt_col_all[].
    et_existing_rel = gt_existing_relations[].
    et_existing_col = gt_existing_col_all[].

  ENDMETHOD.


  METHOD get_field_positions.

    CONSTANTS: lc_guion TYPE c LENGTH 1 VALUE '-'.
    FIELD-SYMBOLS: <fs_positions>  LIKE LINE OF it_positions.

    DATA: lt_dfies_tab TYPE TABLE OF   dfies,
          ls_dfies_tab TYPE  dfies,
          lv_fldname   TYPE zonta_oc_columns-fldname,
          lv_table     TYPE zonta_oc_columns-fldname,
          lt_positions TYPE aqtdbjc.

    lt_positions = it_positions[].
    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname        = iv_table
        langu          = sy-langu
      TABLES
        dfies_tab      = lt_dfies_tab
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.
    IF sy-subrc = 0.
      SORT lt_dfies_tab BY fieldname.
      LOOP AT lt_positions ASSIGNING <fs_positions>.
        SPLIT <fs_positions>-rname AT lc_guion INTO lv_table lv_fldname.

        READ TABLE lt_dfies_tab INTO ls_dfies_tab WITH KEY fieldname = lv_fldname BINARY SEARCH.
        IF sy-subrc = 0.
          <fs_positions>-jind  = ls_dfies_tab-position+2(2).
        ENDIF.
      ENDLOOP.
    ENDIF.

    SORT lt_positions BY jind.
    LOOP AT lt_positions ASSIGNING <fs_positions>.
      <fs_positions>-jind = sy-tabix.
    ENDLOOP.

    et_positions_new = lt_positions[].

  ENDMETHOD.


  METHOD GET_INFO_FIELD.
    SORT gt_columns BY tabname fldname.

    et_columns = gt_columns.

  ENDMETHOD.


  METHOD get_sort.
    DATA: gs_sort LIKE LINE OF gt_dbsg_map.

    READ TABLE gt_dbsg_map WITH TABLE KEY table = iv_tabname INTO gs_sort.
    IF sy-subrc = 0.
      cv_sort = gs_sort-sort.
    ELSE.
      "If not found, push to the end but keep deterministic order
      cv_sort = 999999.
    ENDIF.
  ENDMETHOD.


  METHOD get_tables_metadata.

    TYPES: BEGIN OF st_dd02l,
             tabname  TYPE tabname,
             contflag TYPE contflag,
           END OF st_dd02l.

    DATA: lt_columns_tmp TYPE STANDARD TABLE OF st_col_all,
          lt_tab         TYPE STANDARD TABLE OF dfies,
          lt_tab_all     TYPE STANDARD TABLE OF dfies,
          lt_dd02l       TYPE STANDARD TABLE OF st_dd02l,
          ls_dd02l       TYPE st_dd02l,
          lv_entity      TYPE zonta_obj_oc-business_proc,
          ls_tab         TYPE dfies,
          lr_struc       TYPE REF TO cl_abap_structdescr,
          ls_comp        TYPE abap_compdescr.


    FIELD-SYMBOLS:
      <fs_rel>     LIKE LINE OF gt_relationsy,
      <fs_col>     LIKE LINE OF gt_columns_ally,
      <fs_cola>    LIKE LINE OF gt_columns_ally,
      <fs_franges> LIKE LINE OF gt_frangesy,
      <fs_filters> LIKE LINE OF gt_filtersy,
      <fs_any>     TYPE any,
      <fs_value>   TYPE any.

    IF iv_domain = 'ANY'.
      MESSAGE i121(zon_cl_oc) DISPLAY LIKE 'I'.
      ev_result = 4.
      RETURN.
    ENDIF.

    REFRESH: gt_relationsy,
             gt_columns_ally,
             gt_filtersy,
             gt_frangesy.

    CLEAR gs_info.
    CLEAR gs_dataproduct.

    ev_result = 0.

* Read data
    SELECT SINGLE *
      FROM zonta_obj_oc
      INTO gs_info
      WHERE domainv     = iv_domain
      AND business_proc = iv_entity.
    IF sy-subrc NE 0.
      ev_result = 4.
      RETURN.
    ENDIF.

    IF gs_info-tag5 IS NOT INITIAL.
      SELECT SINGLE process_prefix
             mmodule
             smodule
             e2e
             lob
             solution_pg
             submodule_name
        FROM zonta_dataprodc
        INTO gs_dataproduct
        WHERE process_prefix = gs_info-tag5
          AND spras = sy-langu.
    ENDIF.

    SELECT  domainv
            business_proc
            tabname
            field_main
            field_sec
            parent_relation
            join_type
            sequence
            subsequence
            levelv
            alias_tabname
            description_table
      INTO CORRESPONDING FIELDS OF TABLE gt_relationsy
      FROM zonta_relations
      WHERE domainv       = iv_domain
        AND business_proc = iv_entity.

    IF sy-subrc = 0.
      SELECT tabname contflag
        INTO TABLE lt_dd02l
        FROM dd02l
        FOR ALL ENTRIES IN gt_relationsy
        WHERE tabname       = gt_relationsy-tabname
          AND as4vers       = 'A'. "Active
      SORT lt_dd02l BY tabname.

      SELECT domainv
            business_proc
*          variant,
            tabname
            counter
            fldname
            sign
            opti
            low
            high
         INTO TABLE gt_frangesy
        FROM zonta_oc_franges
        WHERE domainv     = iv_domain
        AND business_proc = iv_entity
          AND variant       IS null. "INITIAL


      SELECT  domainv
              business_proc
*            VARIANT
              tabname
              counter
              fldname
              where_clause
        INTO TABLE gt_filtersy
        FROM zonta_oc_filters
        WHERE domainv     = iv_domain
        AND business_proc = iv_entity
          AND variant       IS null   .

      SELECT
          tabname
          alias_tabname
          fldname
          alias_fldname
          key_field
          selection_field
          description_field
*        seckey_field,
*        positionf
        INTO TABLE lt_columns_tmp
        FROM zonta_oc_col_all
        FOR ALL ENTRIES IN gt_relationsy
        WHERE tabname       = gt_relationsy-tabname
          AND alias_tabname = gt_relationsy-alias_tabname.


      LOOP AT gt_relationsy ASSIGNING <fs_rel>.
        READ TABLE lt_dd02l INTO ls_dd02l WITH KEY tabname = <fs_rel>-tabname BINARY SEARCH.
        IF sy-subrc = 0.
          <fs_rel>-contflag = ls_dd02l-contflag.
        ENDIF.

        CALL FUNCTION 'DDIF_FIELDINFO_GET'
          EXPORTING
            tabname        = <fs_rel>-tabname
          TABLES
            dfies_tab      = lt_tab
          EXCEPTIONS
            not_found      = 1
            internal_error = 2
            OTHERS         = 3.
        IF sy-subrc = 0.
          SORT lt_tab BY position fieldname.
          SORT lt_columns_tmp BY tabname fldname.
          LOOP AT lt_tab INTO ls_tab.
            READ TABLE lt_columns_tmp ASSIGNING <fs_col> WITH KEY tabname = <fs_rel>-tabname
                                                                  fldname = ls_tab-fieldname BINARY SEARCH.
            IF sy-subrc = 0.
              APPEND INITIAL LINE TO gt_columns_ally ASSIGNING <fs_cola>.
              <fs_cola> = <fs_col>.
              <fs_cola>-inttype = ls_tab-inttype.
              <fs_cola>-leng    = ls_tab-leng.
            ENDIF.
          ENDLOOP.

        ENDIF.

      ENDLOOP.


    ENDIF.


  ENDMETHOD.


METHOD get_table_keys.

  CONSTANTS: c_x      TYPE c VALUE 'X',
             c_mandt  TYPE c LENGTH 5 VALUE 'MANDT',
             c_mandtl TYPE c LENGTH 5 VALUE 'mandt'.

  DATA: lt_dfies_tab TYPE TABLE OF   dfies,
        ls_dfies_tab TYPE  dfies,
        lv_fldname   TYPE zonta_oc_columns-fldname,
        ls_table     LIKE LINE OF it_tables,
        lt_keys      TYPE STANDARD TABLE OF zonta_oc_columns,
        lt_fields    TYPE STANDARD TABLE OF zonta_oc_columns.

  FIELD-SYMBOLS: <fs_keys>  TYPE zonta_oc_columns,
                 <fs_field> TYPE zonta_oc_columns.

  LOOP AT it_tables INTO ls_table.

    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname        = ls_table-tabname
        langu          = sy-langu
      TABLES
        dfies_tab      = lt_dfies_tab
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.
    IF sy-subrc = 0.

      SORT lt_dfies_tab BY position.
      LOOP AT lt_dfies_tab INTO ls_dfies_tab .
        APPEND INITIAL LINE TO lt_fields ASSIGNING <fs_field>.
        <fs_field>-tabname = ls_dfies_tab-tabname.
        <fs_field>-fldname = ls_dfies_tab-fieldname.
        <fs_field>-description_field = ls_dfies_tab-scrtext_m.

        IF ls_dfies_tab-keyflag = c_x.
            APPEND INITIAL LINE TO lt_keys ASSIGNING <fs_keys>.
            <fs_keys>-tabname = ls_dfies_tab-tabname.
            <fs_keys>-fldname = ls_dfies_tab-fieldname.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

  et_keys   = lt_keys[].
  et_fields = lt_fields[].


ENDMETHOD.


METHOD GET_TABLE_KEYS_NEW.

  CONSTANTS: c_x      TYPE c VALUE 'X',
             c_mandt  TYPE c LENGTH 5 VALUE 'MANDT',
             c_mandtl TYPE c LENGTH 5 VALUE 'mandt'.

  DATA: lt_dfies_tab TYPE TABLE OF   dfies,
        ls_dfies_tab TYPE  dfies,
        lv_fldname   TYPE zonta_oc_columns-fldname,
        ls_table     LIKE LINE OF it_tables,
        lt_keys      TYPE STANDARD TABLE OF zonta_oc_col_all,
        lt_fields    TYPE STANDARD TABLE OF zonta_oc_col_all.

  FIELD-SYMBOLS: <fs_keys>  TYPE zonta_oc_col_all,
                 <fs_field> TYPE zonta_oc_col_all.

  LOOP AT it_tables INTO ls_table.

    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname        = ls_table-tabname
        langu          = sy-langu
      TABLES
        dfies_tab      = lt_dfies_tab
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.
    IF sy-subrc = 0.

      SORT lt_dfies_tab BY position.
      LOOP AT lt_dfies_tab INTO ls_dfies_tab .
        APPEND INITIAL LINE TO lt_fields ASSIGNING <fs_field>.
        <fs_field>-tabname = ls_dfies_tab-tabname.
        <fs_field>-fldname = ls_dfies_tab-fieldname.
        <fs_field>-description_field = ls_dfies_tab-scrtext_m.
        <fs_field>-positionf  = ls_dfies_tab-position.

        IF ls_dfies_tab-keyflag = c_x.
            APPEND INITIAL LINE TO lt_keys ASSIGNING <fs_keys>.
            <fs_keys>-tabname = ls_dfies_tab-tabname.
            <fs_keys>-fldname = ls_dfies_tab-fieldname.
            <fs_keys>-positionf = ls_dfies_tab-position.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

  et_keys   = lt_keys[].
  et_fields = lt_fields[].


ENDMETHOD.


  METHOD refresh_tables.

    CLEAR:
            gv_domainv,
            gv_business_proc,
            gt_dbsa[],
            gt_dbob[],
            gt_dbos[],
            gt_dbif[],
            gt_dbsf[],
            gt_dbsg[],
            gt_dban[],
            gt_dbjt[],
            gt_dbjc[],
            gt_dbzt[],
            gt_dbzc[],
            gt_dbzl[],
            gt_dbdp[],
            gt_dbpa[],
            gt_dbwr[],
            gt_dbar[],
            gt_dbft[],
            gt_sgtext[],
            gt_ttab[].
  ENDMETHOD.


  METHOD return_tables_after_join.
    CONSTANTS: lc_guion TYPE c VALUE '-',
               lc_i     TYPE c LENGTH 1 VALUE 'I',
               lc_o     TYPE c LENGTH 1 VALUE 'L', "left outer
               lc_inner TYPE string VALUE 'INNER',
               lc_outer TYPE string VALUE 'LEFT OUTER'.

    TYPES: BEGIN OF st_alias,
             tabname       TYPE tabname,
             alias_tabname TYPE zonta_relations-alias_tabname,
           END OF st_alias.

    DATA: lt_sug_alias TYPE STANDARD TABLE OF st_alias.

    DATA:
      ls_dbsg          LIKE LINE OF gt_dbsg,
      ls_dbjt          LIKE LINE OF gt_dbjt,
      ls_dban          LIKE LINE OF gt_dban,
      ls_dbjc          LIKE LINE OF gt_dbjc,
      lt_dbjt          TYPE STANDARD TABLE OF aqdbjt,
      lt_join_or       TYPE aqq_t_join,
      lt_join          TYPE aqq_t_join,
      ls_ttab          TYPE aqq_s_ttab,
      ls_relations     TYPE zonta_relations,
      ls_relt          TYPE zonta_relations,
      lv_index         TYPE sy-tabix,
      lt_positions     TYPE aqtdbjc,
      lt_positions_new TYPE aqtdbjc,
      lv_tindex        TYPE n LENGTH 5.


    DATA: lt_rel_tmp  TYPE STANDARD TABLE OF zonta_relations,
          ls_rel      LIKE LINE OF gt_relations,
          lv_sequence TYPE i.

    FIELD-SYMBOLS: <fs_rel>  LIKE LINE OF gt_relations,
                   <fs_dbsg> LIKE LINE OF it_dbsg,
                   <fs_join> LIKE LINE OF it_join.

    DATA: lv_table TYPE tabname.
    DATA: ls_join LIKE LINE OF it_join.
    DATA: lv_ltab   TYPE tabname,
          lv_rtab   TYPE tabname,
          lv_sort_l TYPE i,
          lv_sort_r TYPE i.

    CLEAR gt_relations[].

    gt_dbsg[] = it_dbsg[].
    gt_dbjc[] = it_dbjc[].
    gt_dbjt[] = it_dbjt[].
    gt_dban[] = it_dban[].
    gt_ttab[] = it_ttab[].

    IF lines( gt_dbsg ) > 0.
      SELECT tabname alias_tabname
        INTO TABLE lt_sug_alias
        FROM zonta_relations
        FOR ALL ENTRIES IN gt_dbsg
        WHERE tabname = gt_dbsg-name.
      SORT lt_sug_alias BY tabname alias_tabname.
      DELETE ADJACENT DUPLICATES FROM lt_sug_alias COMPARING tabname.
      DATA: ls_sug_a LIKE LINE OF lt_sug_alias.
    ENDIF.

********

    IF lines( it_join ) > 0.
      REFRESH gt_dbsg[].
      lt_dbjt[] = gt_dbjt[].
      REFRESH gt_dbjt[].

      lt_join_or[] = it_join[].

      LOOP AT lt_dbjt INTO ls_dbjt.
        LOOP AT lt_join_or ASSIGNING <fs_join> WHERE tabnamel = ls_dbjt-table.
          APPEND <fs_join> TO lt_join.
          <fs_join>-type = '9'.
        ENDLOOP.
      ENDLOOP.

      LOOP AT lt_join_or ASSIGNING <fs_join> WHERE type NE '9'.
        APPEND <fs_join> TO lt_join.
      ENDLOOP.

      lv_tindex = 2.
      LOOP AT lt_join INTO ls_join.
        IF sy-tabix = 1.
          APPEND INITIAL LINE TO gt_dbsg ASSIGNING <fs_dbsg>.
          <fs_dbsg>-name = ls_join-tabnamel.
          <fs_dbsg>-tindx = lv_tindex.
          lv_tindex = lv_tindex + 1.
        ENDIF.

        APPEND INITIAL LINE TO gt_dbsg ASSIGNING <fs_dbsg>.
        <fs_dbsg>-name = ls_join-tabnamer.
        <fs_dbsg>-tindx = lv_tindex.
        lv_tindex = lv_tindex + 1.
      ENDLOOP.

      LOOP AT gt_dbsg ASSIGNING <fs_dbsg>.
        READ TABLE lt_dbjt INTO ls_dbjt WITH KEY table = <fs_dbsg>-name.
        IF sy-subrc = 0.
          APPEND ls_dbjt TO gt_dbjt.
        ENDIF.
      ENDLOOP.

*    lv_tindex = 2.
*    LOOP AT gt_dbjt INTO ls_dbjt.
*      APPEND INITIAL LINE TO gt_dbsg ASSIGNING <fs_dbsg>.
*      <fs_dbsg>-name = ls_dbjt-table.
*      <fs_dbsg>-tindx = lv_tindex.
*      lv_tindex = lv_tindex + 1.
*    ENDLOOP.

      me->build_sort_map( ).

      gt_dbjc_old[] = gt_dbjc[].
      REFRESH gt_dbjc.

      "Take base relations from OLD and orient them by sort
      LOOP AT gt_dbjc_old INTO gs_old WHERE jind = space.

        lv_ltab = gs_old-ltable.
        lv_rtab = gs_old-rtable.

        CALL METHOD me->get_sort
          EXPORTING
            iv_tabname = lv_ltab
          CHANGING
            cv_sort    = lv_sort_l.

        CALL METHOD me->get_sort
          EXPORTING
            iv_tabname = lv_rtab
          CHANGING
            cv_sort    = lv_sort_r.

        "Ensure left table has smaller sort (if equal, keep original)
        IF lv_sort_l > lv_sort_r.
          "swap
          lv_ltab = gs_old-rtable.
          lv_rtab = gs_old-ltable.
        ENDIF.

        "1) Base row in oriented direction
        CALL METHOD me->append_base_unique
          EXPORTING
            iv_ltable = lv_ltab
            iv_rtable = lv_rtab.


        "2) Matching condition rows in same direction (flip if needed)
        CALL METHOD me->append_cond_or_flipped
          EXPORTING
            iv_ltable = lv_ltab
            iv_rtable = lv_rtab.

      ENDLOOP.
      SORT gt_dbsg BY tindx.
    ENDIF.
*******


    LOOP AT gt_dbsg INTO ls_dbsg.
      lv_index = sy-tabix.

      CLEAR ls_relations.
      CLEAR: ls_dbjt, ls_dban, ls_sug_a, ls_ttab.
      ls_relations-domainv = gv_domainv.
      ls_relations-business_proc = gv_business_proc.
      ls_relations-tabname = ls_dbsg-name.

      READ TABLE gt_dbjt      INTO ls_dbjt  WITH KEY table        = ls_dbsg-name.
      READ TABLE gt_dban      INTO ls_dban  WITH KEY table        = ls_dbsg-name.
      READ TABLE lt_sug_alias INTO ls_sug_a WITH KEY tabname      = ls_dbsg-name.
      READ TABLE gt_ttab      INTO ls_ttab  WITH KEY ddic-tabname = ls_dbsg-name.
*      ls_dbjt  = VALUE #( gt_dbjt[ table = ls_dbsg-name ] OPTIONAL ).
*      ls_dban  = VALUE #( gt_dban[ table = ls_dbsg-name ] OPTIONAL ).
*      ls_sug_a = VALUE #( lt_sug_alias[ tabname = ls_dbsg-name ] OPTIONAL ).
*      ls_ttab  = VALUE #( gt_ttab[ ddic-tabname = ls_dbsg-name ] OPTIONAL ).

      ls_relations-sequence = lv_index.
      CASE ls_dbjt-outerflag.
        WHEN lc_i.
          ls_relations-join_type = lc_inner.
        WHEN lc_o.
          ls_relations-join_type = lc_outer.
      ENDCASE.

      IF lv_index > 1 AND ls_relations-join_type IS INITIAL.
        ls_relations-join_type = lc_inner.
      ENDIF.

      IF ls_dban-alias IS INITIAL.
        ls_relations-alias_tabname = ls_sug_a-alias_tabname.
      ELSE.
        ls_relations-alias_tabname = ls_dban-alias.
      ENDIF.
      ls_relations-description_table = ls_ttab-ddic-ddtext.

      lt_positions = gt_dbjc[].
      DELETE lt_positions WHERE rtable NE ls_dbsg-name.
      DELETE lt_positions WHERE rname IS INITIAL.

      IF lines( lt_positions ) > 0.
        CALL METHOD me->get_field_positions
          EXPORTING
            iv_table         = ls_dbsg-name
            it_positions     = lt_positions[]
          IMPORTING
            et_positions_new = lt_positions_new[].
        LOOP AT lt_positions_new INTO ls_dbjc.
          CLEAR: ls_dbjt, ls_ttab, ls_dban.
          SPLIT ls_dbjc-lname AT lc_guion INTO lv_table ls_relations-field_main.
          SPLIT ls_dbjc-rname AT lc_guion INTO lv_table ls_relations-field_sec.
          ls_relations-parent_relation = ls_dbjc-ltable.
          ls_relations-subsequence = ls_dbjc-jind.
          APPEND ls_relations TO gt_relations.
        ENDLOOP.
      ELSE.
        READ TABLE lt_join INTO ls_join WITH KEY tabnamer = ls_dbsg-name.
        IF sy-subrc = 0.
          CLEAR: ls_dbjt, ls_ttab, ls_dban.
          ls_relations-parent_relation = ls_join-tabnamel.
          ls_relations-field_sec = ls_join-colnamel.
          ls_relations-field_main = ls_join-colnamer.
          ls_relations-subsequence = ls_dbjc-jind.
          APPEND ls_relations TO gt_relations.
        ELSE.
          ls_relations-subsequence = 1.
          APPEND ls_relations TO gt_relations.
        ENDIF.
      ENDIF.
    ENDLOOP.


* Handle levels
    SORT gt_relations BY sequence.
    lt_rel_tmp[] = gt_relations[].
    LOOP AT gt_relations ASSIGNING <fs_rel>.
      IF <fs_rel>-sequence = 1.
        <fs_rel>-levelv = 1.
        CLEAR <fs_rel>-join_type.
        READ TABLE gt_relations INTO ls_relt WITH KEY sequence = 2.
        IF sy-subrc = 0.
          <fs_rel>-field_main = ls_relt-field_sec.
        ENDIF.
      ELSE.
        READ TABLE gt_relations INTO ls_rel WITH KEY tabname = <fs_rel>-parent_relation.
        IF sy-subrc = 0.
          <fs_rel>-levelv    = ls_rel-levelv + 1.
        ENDIF.

        lv_sequence = <fs_rel>-sequence - 1.
        READ TABLE lt_rel_tmp INTO ls_rel WITH KEY sequence = lv_sequence.
        IF sy-subrc = 0.
          <fs_rel>-join_type    = ls_rel-join_type.
        ENDIF.

      ENDIF.
    ENDLOOP.

    et_relations = gt_relations[].
  ENDMETHOD.


  METHOD send_excel_metadata.


    DATA:
      lo_excel     TYPE ole2_object,
      lo_workbooks TYPE ole2_object,
      lo_workbook  TYPE ole2_object,
      lo_sheet     TYPE ole2_object,
      lo_sheets    TYPE ole2_object,
      lo_cell      TYPE ole2_object,
      lv_sheetn    TYPE char31,
      lv_entity    TYPE zonta_obj_oc-business_proc,
      lr_struc     TYPE REF TO cl_abap_structdescr,
      ls_comp      TYPE abap_compdescr,
      lv_skip      TYPE boolean.

    DATA:
      lv_row   TYPE i,
      lv_col   TYPE i,
      lv_subrc TYPE sy-subrc.

    FIELD-SYMBOLS:
      <fs_rel>     LIKE LINE OF gt_relationsy,
      <fs_col>     LIKE LINE OF gt_columns_ally,
      <fs_cola>    LIKE LINE OF gt_columns_ally,
      <fs_franges> LIKE LINE OF gt_frangesy,
      <fs_filters> LIKE LINE OF gt_filtersy,
      <fs_any>     TYPE any,
      <fs_value>   TYPE any.

    CALL METHOD me->get_tables_metadata
      EXPORTING
        iv_domain = iv_domain
        iv_entity = iv_entity
      IMPORTING
        ev_result = lv_subrc.

    IF lv_subrc NE 0.
      MESSAGE i123(zon_cl_oc) WITH iv_entity DISPLAY LIKE 'E'.
    ENDIF.

    CHECK lv_subrc = 0.
* Start Excel
    CREATE OBJECT lo_excel 'Excel.Application'.
    SET PROPERTY OF lo_excel 'Visible' = 0.

* Create workbook
    CALL METHOD OF lo_excel 'Workbooks' = lo_workbooks.
    CALL METHOD OF lo_workbooks 'Add' = lo_workbook.

    CALL METHOD OF lo_workbook 'Worksheets' = lo_sheets.
    CALL METHOD OF lo_sheets 'Add'.
    CALL METHOD OF lo_sheets 'Add'.
    CALL METHOD OF lo_sheets 'Add'.
    CALL METHOD OF lo_sheets 'Add'.
    CALL METHOD OF lo_sheets 'Add'.

* Sheet 1 : MAIN INFO
    lv_entity = iv_entity.
    IF strlen( iv_entity ) > 21.
      lv_entity = iv_entity(21).
    ENDIF.

    lv_sheetn = lv_entity && '_INFO'.
    lv_sheetn = lv_sheetn+0(31).

    CALL METHOD OF lo_sheets 'Item' = lo_sheet EXPORTING #1 = 1.
    SET PROPERTY OF lo_sheet 'Name' = lv_sheetn.

    lv_row = 1.
    lv_col = 1.


    lr_struc ?= cl_abap_typedescr=>describe_by_data( gs_info ).

    LOOP AT lr_struc->components INTO ls_comp.

      ASSIGN COMPONENT ls_comp-name OF STRUCTURE gs_info TO <fs_value>.

      IF sy-subrc = 0.
*        PERFORM write_cell USING lo_sheet lv_row 1 ls_comp-name.
        CALL METHOD me->write_cell
          EXPORTING
            iv_sheet = lo_sheet
            iv_row   = lv_row
            iv_col   = 1
            iv_value = ls_comp-name.


*        PERFORM write_cell USING lo_sheet lv_row 2 <fs_value>.
        CALL METHOD me->write_cell
          EXPORTING
            iv_sheet = lo_sheet
            iv_row   = lv_row
            iv_col   = 2
            iv_value = <fs_value>.

        lv_row = lv_row + 1.
      ENDIF.

    ENDLOOP.

* Sheet 2 : RELATIONS
    lv_sheetn = lv_entity && '_RELATIONS'.
    lv_sheetn = lv_sheetn+0(31).

    CALL METHOD OF lo_sheets 'Item' = lo_sheet EXPORTING #1 = 2.
    SET PROPERTY OF lo_sheet 'Name' = lv_sheetn.

    lv_row = 1.
    lv_col = 1.

* Write header
    lr_struc ?= cl_abap_typedescr=>describe_by_data( VALUE st_relations( ) ).

    LOOP AT lr_struc->components INTO ls_comp.
*      PERFORM write_cell USING lo_sheet lv_row lv_col ls_comp-name.
      IF lv_col = 4.
        lv_skip = abap_true.
        lv_col = lv_col + 1.
        CONTINUE.
      ENDIF.

      IF lv_col = 5 AND lv_skip = abap_true.
        lv_col = 4.
        lv_skip = abap_false.
      ENDIF.

      CALL METHOD me->write_cell
        EXPORTING
          iv_sheet = lo_sheet
          iv_row   = lv_row
          iv_col   = lv_col
          iv_value = ls_comp-name.

      lv_col = lv_col + 1.
    ENDLOOP.

* Write data
    lv_row = 2.

    LOOP AT gt_relationsy ASSIGNING <fs_rel>.
      lv_col = 1.
      DO.
        ASSIGN COMPONENT sy-index OF STRUCTURE <fs_rel> TO <fs_any>.
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.

        IF lv_col = 4.
          lv_skip = abap_true.
          lv_col = lv_col + 1.
          CONTINUE.
        ENDIF.

        IF lv_col = 5 AND lv_skip = abap_true.
          lv_col = 4.
          lv_skip = abap_false.
        ENDIF.

        CALL METHOD me->write_cell
          EXPORTING
            iv_sheet = lo_sheet
            iv_row   = lv_row
            iv_col   = lv_col
            iv_value = <fs_any>.

        lv_col = lv_col + 1.
      ENDDO.
      lv_row = lv_row + 1.
    ENDLOOP.

* Sheet 3 : COLUMNS
    lv_sheetn = lv_entity && '_COLUMNS'.
    lv_sheetn = lv_sheetn+0(31).

    CALL METHOD OF lo_sheets 'Item' = lo_sheet EXPORTING #1 = 3.
    SET PROPERTY OF lo_sheet 'Name' = lv_sheetn.

    lv_row = 1.
    lv_col = 1.

    lr_struc ?= cl_abap_typedescr=>describe_by_data( VALUE st_col_all( ) ).
    LOOP AT lr_struc->components INTO ls_comp.
*      PERFORM write_cell USING lo_sheet lv_row lv_col ls_comp-name.
      CALL METHOD me->write_cell
        EXPORTING
          iv_sheet = lo_sheet
          iv_row   = lv_row
          iv_col   = lv_col
          iv_value = ls_comp-name.

      lv_col = lv_col + 1.
    ENDLOOP.

    lv_row = 2.

    LOOP AT gt_columns_ally ASSIGNING <fs_col>.
      lv_col = 1.
      DO.
        ASSIGN COMPONENT sy-index OF STRUCTURE <fs_col> TO <fs_any>.
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.

*        PERFORM write_cell USING lo_sheet lv_row lv_col <fs_any>.
        CALL METHOD me->write_cell
          EXPORTING
            iv_sheet = lo_sheet
            iv_row   = lv_row
            iv_col   = lv_col
            iv_value = <fs_any>.

        lv_col = lv_col + 1.
      ENDDO.

      lv_row = lv_row + 1.
    ENDLOOP.

* Sheet 4 : FILTERS
    lv_sheetn = lv_entity && '_FILTERS'.
    lv_sheetn = lv_sheetn+0(31).

    CALL METHOD OF lo_sheets 'Item' = lo_sheet EXPORTING #1 = 4.
    SET PROPERTY OF lo_sheet 'Name' = lv_sheetn.

    lv_row = 1.
    lv_col = 1.

    lr_struc ?= cl_abap_typedescr=>describe_by_data( VALUE st_franges( ) ).
    LOOP AT lr_struc->components INTO ls_comp.
*      PERFORM write_cell USING lo_sheet lv_row lv_col ls_comp-name.
      CALL METHOD me->write_cell
        EXPORTING
          iv_sheet = lo_sheet
          iv_row   = lv_row
          iv_col   = lv_col
          iv_value = ls_comp-name.

      lv_col = lv_col + 1.
    ENDLOOP.

    lv_row = 2.

    LOOP AT gt_frangesy ASSIGNING <fs_franges>.
      lv_col = 1.
      DO.
        ASSIGN COMPONENT sy-index OF STRUCTURE <fs_franges> TO <fs_any>.
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.

*        PERFORM write_cell USING lo_sheet lv_row lv_col <fs_any>.
        CALL METHOD me->write_cell
          EXPORTING
            iv_sheet = lo_sheet
            iv_row   = lv_row
            iv_col   = lv_col
            iv_value = <fs_any>.

        lv_col = lv_col + 1.
      ENDDO.

      lv_row = lv_row + 1.
    ENDLOOP.


* Sheet 5 : WHERE
    lv_sheetn = lv_entity && '_WHERE'.
    lv_sheetn = lv_sheetn+0(31).

    CALL METHOD OF lo_sheets 'Item' = lo_sheet EXPORTING #1 = 5.
    SET PROPERTY OF lo_sheet 'Name' = lv_sheetn.

    lv_row = 1.
    lv_col = 1.

    lr_struc ?= cl_abap_typedescr=>describe_by_data( VALUE st_filters( ) ).
    LOOP AT lr_struc->components INTO ls_comp.
*      PERFORM write_cell USING lo_sheet lv_row lv_col ls_comp-name.
      CALL METHOD me->write_cell
        EXPORTING
          iv_sheet = lo_sheet
          iv_row   = lv_row
          iv_col   = lv_col
          iv_value = ls_comp-name.

      lv_col = lv_col + 1.
    ENDLOOP.

    lv_row = 2.

    LOOP AT gt_filtersy ASSIGNING <fs_filters>.
      lv_col = 1.
      DO.
        ASSIGN COMPONENT sy-index OF STRUCTURE <fs_filters> TO <fs_any>.
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.

*        PERFORM write_cell USING lo_sheet lv_row lv_col <fs_any>.
        CALL METHOD me->write_cell
          EXPORTING
            iv_sheet = lo_sheet
            iv_row   = lv_row
            iv_col   = lv_col
            iv_value = <fs_any>.

        lv_col = lv_col + 1.
      ENDDO.

      lv_row = lv_row + 1.
    ENDLOOP.

* Save Excel
    CALL METHOD OF lo_workbook 'SaveAs'
      EXPORTING
        #1 = iv_file
        #2 = 51.   "xlsx

* Close Excel
    CALL METHOD OF lo_workbook 'Close'.
    CALL METHOD OF lo_excel 'Quit'.

    FREE OBJECT lo_sheet.
    FREE OBJECT lo_sheets.
    FREE OBJECT lo_workbook.
    FREE OBJECT lo_workbooks.
    FREE OBJECT lo_excel.

    MESSAGE i120(zon_cl_oc) DISPLAY LIKE 'S'.


  ENDMETHOD.


  METHOD send_json_metadata.

    TYPES:
      tt_relations TYPE STANDARD TABLE OF st_relations WITH EMPTY KEY,
      tt_columns   TYPE STANDARD TABLE OF st_col_all WITH EMPTY KEY,
      tt_filters   TYPE STANDARD TABLE OF st_filters WITH EMPTY KEY,
      tt_franges   TYPE STANDARD TABLE OF st_franges WITH EMPTY KEY.

    TYPES: BEGIN OF ty_metadata,
             entity    TYPE zonde_process,
             info      TYPE zonta_obj_oc,
             dataprodclass type st_dataproduct,
             relations TYPE tt_relations,
             columns   TYPE tt_columns,
             filters   TYPE tt_franges,
             where     TYPE tt_filters,
           END OF ty_metadata.


    DATA: ls_metadata TYPE ty_metadata,
          lv_subrc    TYPE sy-subrc,
          lv_json     TYPE string.


    CALL METHOD me->get_tables_metadata
      EXPORTING
        iv_domain = iv_domain
        iv_entity = iv_entity
      IMPORTING
        ev_result = lv_subrc.

    IF lv_subrc NE 0.
      MESSAGE i123(zon_cl_oc) WITH iv_entity DISPLAY LIKE 'E'.
    ENDIF.

    CHECK lv_subrc = 0.

    ls_metadata-entity    = gs_info-business_proc.
    ls_metadata-info      = gs_info.
    ls_metadata-dataprodclass = gs_dataproduct.
    ls_metadata-relations = gt_relationsy.
    ls_metadata-columns   = gt_columns_ally.
    ls_metadata-filters   = gt_frangesy.
    ls_metadata-where     = gt_filtersy.


    DELETE ls_metadata-columns WHERE fldname IS INITIAL.
    DELETE ls_metadata-relations WHERE tabname IS INITIAL.

    lv_json = zoncl_ui2_cl_json=>serialize(
                 data             = ls_metadata
                 compress         = abap_false
                 assoc_arrays     = abap_true
                 assoc_arrays_opt = abap_true
                 pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).

    ev_json = lv_json.

  ENDMETHOD.


  METHOD show_filter_options.

    CONSTANTS: c_separator TYPE c VALUE '~'.

    DATA selid          TYPE rsdynsel-selid.
    DATA field_tab      TYPE TABLE OF rsdsfields.
    DATA field_tab_ini  TYPE TABLE OF rsdsfields.
    DATA field_tab_excl TYPE TABLE OF rsdsfields.
    DATA ls_field_ini   TYPE rsdsfields.
    DATA field_ranges   TYPE rsds_trange.
    DATA table_tab      TYPE TABLE OF rsdstabs.
    DATA cond_tab       TYPE rsds_twhere.
    DATA lv_title       TYPE sy-title.
    DATA lv_counter     TYPE i.
    DATA lt_filters     TYPE zontt_filters.
    DATA ls_filters     LIKE LINE OF lt_filters.
    DATA lv_fieldname_complex TYPE string.
    DATA lt_ranges        TYPE STANDARD TABLE OF zonta_oc_franges.
    DATA ls_ranges        LIKE LINE OF lt_ranges.
    DATA lt_ranges_ini    TYPE rsds_trange.
    DATA ls_rsds_range    TYPE rsds_range.
    DATA lt_frange_t      TYPE rsds_frange_t.
    DATA ls_rsds_frange   TYPE rsds_frange.
    DATA lt_rsds_selopt_t TYPE rsds_selopt_t.
    DATA ls_rsdsselopt    TYPE rsdsselopt.
    DATA lv_fldname       TYPE fieldname.
    DATA lv_tablename     TYPE tabname.
    DATA lv_nochanges     TYPE boolean.
    DATA lv_where_string  TYPE string.


    DATA: lt_dfies_tab  TYPE TABLE OF dfies,
          lt_all_fields TYPE TABLE OF dfies,
          ls_dfies_tab  TYPE  dfies.

    DATA: rl_fldname   TYPE RANGE OF fieldname.
    DATA: lt_relations TYPE STANDARD TABLE OF zonta_relations,
          ls_relations TYPE zonta_relations,
          lt_columns   TYPE STANDARD TABLE OF zonta_oc_columns.

    DATA: lt_columns_tmp TYPE STANDARD TABLE OF zonta_oc_columns,
          ls_all_fields  LIKE LINE OF lt_all_fields.

    FIELD-SYMBOLS: <fs_table_tab>      LIKE LINE OF table_tab,
                   <fs_relations>      LIKE LINE OF lt_relations,
                   <fs_field_tab_excl> LIKE LINE OF field_tab_excl,
                   <fs_cond_tab>       LIKE LINE OF cond_tab,
                   <fs_filters>        LIKE LINE OF lt_filters.

    DATA: ls_field_tab LIKE LINE OF field_tab,
          ls_where     LIKE LINE OF <fs_cond_tab>-where_tab,
          ls_field_r   LIKE LINE OF field_ranges,
          ls_range_d   TYPE rsds_frange,
          ls_selopt    TYPE rsdsselopt.

    DATA: lwr_fldname    TYPE selopt,
          ls_columns_tmp LIKE LINE OF lt_columns_tmp.


    CLEAR lt_rsds_selopt_t[].
    CLEAR lt_frange_t[].
    CLEAR ls_rsds_range.
    CLEAR lt_ranges_ini[].


    lt_relations[] = it_relations[].
    lt_columns[]   = it_columns[].

    lv_nochanges = abap_false.
    DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING sequence.

    SORT lt_columns BY fldname tabname.

    CLEAR lt_all_fields[].
    LOOP AT lt_relations ASSIGNING <fs_relations>.
      APPEND INITIAL LINE TO table_tab ASSIGNING <fs_table_tab>.
      <fs_table_tab>-prim_tab = <fs_relations>-tabname.

      CALL FUNCTION 'DDIF_FIELDINFO_GET'
        EXPORTING
          tabname        = <fs_relations>-tabname
          langu          = sy-langu
        TABLES
          dfies_tab      = lt_dfies_tab
        EXCEPTIONS
          not_found      = 1
          internal_error = 2
          OTHERS         = 3.
      IF sy-subrc = 0.
        APPEND LINES OF lt_dfies_tab TO lt_all_fields.
        lt_columns_tmp = lt_columns[].
        DELETE lt_columns_tmp WHERE tabname NE <fs_relations>-tabname.
*
*        rl_fldname = VALUE #( FOR sl_fldname IN lt_columns_tmp (   sign = 'I'
*                                                                 option = 'EQ'
*                                                                    low = sl_fldname-fldname ) ).
        CLEAR rl_fldname[].
        LOOP AT lt_columns_tmp INTO ls_columns_tmp.
          lwr_fldname-sign    =   'I'.
          lwr_fldname-option  =   'EQ'.
          lwr_fldname-low     =   ls_columns_tmp-fldname.
          APPEND lwr_fldname TO rl_fldname.
        ENDLOOP.

        DELETE lt_dfies_tab WHERE fieldname IN rl_fldname[].
        LOOP AT lt_dfies_tab INTO ls_dfies_tab.
          APPEND INITIAL LINE TO field_tab_excl ASSIGNING <fs_field_tab_excl>.
          <fs_field_tab_excl>-tablename = ls_dfies_tab-tabname.
          <fs_field_tab_excl>-fieldname = ls_dfies_tab-fieldname.
        ENDLOOP.
      ENDIF.
    ENDLOOP.


    CLEAR field_tab_ini[].

    IF lines( it_ranges ) > 0.
      SORT it_ranges BY tabname fldname.
      READ TABLE it_ranges INTO ls_ranges INDEX 1.
      lv_fldname   = ls_ranges-fldname.
      lv_tablename = ls_ranges-tabname.

      ls_field_ini-tablename = ls_ranges-tabname.
      ls_field_ini-fieldname = ls_ranges-fldname.
      SORT lt_all_fields BY tabname fieldname.
      READ TABLE lt_all_fields INTO ls_all_fields WITH KEY tabname = ls_ranges-tabname fieldname = ls_ranges-fldname BINARY SEARCH.
      IF sy-subrc = 0.
        ls_field_ini-type = ls_all_fields-inttype.
        ls_field_ini-where_leng = ls_all_fields-leng."ls_all_fields-outputlen.
      ENDIF.
      APPEND ls_field_ini TO field_tab_ini.

      LOOP AT it_ranges INTO ls_ranges.
        IF ls_ranges-tabname NE lv_tablename.
          IF NOT lt_rsds_selopt_t IS INITIAL.
            ls_rsds_frange-fieldname  = lv_fldname.
            ls_rsds_frange-selopt_t[] = lt_rsds_selopt_t[].
            CLEAR lt_rsds_selopt_t[].
            APPEND ls_rsds_frange TO lt_frange_t .
          ENDIF.

          ls_rsds_range-tablename = lv_tablename.
          ls_rsds_range-frange_t[] = lt_frange_t[].
          APPEND ls_rsds_range TO lt_ranges_ini[].
          CLEAR lt_frange_t[].
          CLEAR ls_rsds_range.
        ELSE.
          IF ls_ranges-fldname NE lv_fldname.
            ls_rsds_frange-fieldname  = lv_fldname.
            ls_rsds_frange-selopt_t[] = lt_rsds_selopt_t[].
            CLEAR lt_rsds_selopt_t[].
            APPEND ls_rsds_frange TO lt_frange_t .

            ls_field_ini-tablename = ls_ranges-tabname.
            ls_field_ini-fieldname = ls_ranges-fldname.
            SORT lt_all_fields BY tabname fieldname.
            READ TABLE lt_all_fields INTO ls_all_fields WITH KEY tabname = ls_ranges-tabname fieldname = ls_ranges-fldname BINARY SEARCH.
            IF sy-subrc = 0.
              ls_field_ini-type = ls_all_fields-inttype.
              ls_field_ini-where_leng = ls_all_fields-leng."ls_all_fields-outputlen.
            ENDIF.
            APPEND ls_field_ini TO field_tab_ini.
          ELSE.

          ENDIF.
        ENDIF.

        ls_rsdsselopt-sign   = ls_ranges-sign.
        ls_rsdsselopt-option = ls_ranges-opti.
        ls_rsdsselopt-low    = ls_ranges-low.
        ls_rsdsselopt-high   = ls_ranges-high.
        APPEND ls_rsdsselopt TO lt_rsds_selopt_t.

        lv_fldname = ls_ranges-fldname.
        lv_tablename = ls_ranges-tabname.

      ENDLOOP.
    ENDIF.


    IF NOT lt_rsds_selopt_t IS INITIAL.
      ls_rsds_frange-fieldname = ls_ranges-fldname.
      ls_rsds_frange-selopt_t[] = lt_rsds_selopt_t[].
      CLEAR lt_rsds_selopt_t[].
      APPEND ls_rsds_frange TO lt_frange_t .

      ls_rsds_range-tablename = ls_ranges-tabname.
      ls_rsds_range-frange_t[] = lt_frange_t[].
      APPEND ls_rsds_range TO lt_ranges_ini[].

      ls_field_ini-tablename = ls_ranges-tabname.
      ls_field_ini-fieldname = ls_ranges-fldname.
      SORT lt_all_fields BY tabname fieldname.
      READ TABLE lt_all_fields INTO ls_all_fields WITH KEY tabname = ls_ranges-tabname fieldname = ls_ranges-fldname BINARY SEARCH.
      IF sy-subrc = 0.
        ls_field_ini-type = ls_all_fields-inttype.
        ls_field_ini-where_leng = ls_all_fields-leng.
      ENDIF.
      APPEND ls_field_ini TO field_tab_ini.
    ENDIF.

    SORT field_tab_ini BY tablename fieldname.
    DELETE ADJACENT DUPLICATES FROM field_tab_ini COMPARING tablename fieldname.

    CALL FUNCTION 'FREE_SELECTIONS_INIT'
      EXPORTING
        kind                  = 'T'
        field_ranges_int      = lt_ranges_ini[]
      IMPORTING
        selection_id          = selid
      TABLES
        tables_tab            = table_tab
        fields_tab            = field_tab_ini
        tabfields_not_display = field_tab_excl
*       fields_not_selected   = field_tab_excl
      EXCEPTIONS
        OTHERS                = 4.
    IF sy-subrc <> 0.
      MESSAGE 'Error in initialization' TYPE 'I' DISPLAY LIKE 'E'.
      lv_nochanges = abap_true.
      LEAVE PROGRAM.
    ENDIF.

    IF gv_domainv IS INITIAL
    OR gv_business_proc IS INITIAL.
      READ TABLE lt_relations INTO ls_relations INDEX 1.
      gv_domainv = ls_relations-domainv.
      gv_business_proc = ls_relations-business_proc.
    ENDIF.

    CONCATENATE 'Entity'
               gv_domainv
               ' - '
               gv_business_proc
               INTO  lv_title
               SEPARATED BY space.


    CALL FUNCTION 'FREE_SELECTIONS_DIALOG'
      EXPORTING
        selection_id  = selid
        title         = lv_title
        as_window     = ' '
      IMPORTING
        where_clauses = cond_tab
        field_ranges  = field_ranges
      TABLES
        fields_tab    = field_tab
      EXCEPTIONS
        OTHERS        = 4.
    IF sy-subrc <> 0.
      MESSAGE 'No changes were saved' TYPE 'I'.
      lv_nochanges = abap_true.
*      LEAVE PROGRAM.
    ENDIF.




    CLEAR lt_filters[].
    SORT cond_tab BY tablename.
*    LOOP AT cond_tab ASSIGNING <fs_cond_tab>.
*      ls_filters-domainv = gv_domainv.
*      ls_filters-business_proc = gv_business_proc.
*      ls_filters-tabname = <fs_cond_tab>-tablename.
*      lv_counter = 1.
*      LOOP AT field_tab INTO ls_field_tab WHERE tablename = ls_filters-tabname.
*
*        LOOP AT <fs_cond_tab>-where_tab INTO ls_where WHERE line CS ls_field_tab-fieldname.
*          ls_filters-counter = lv_counter.
*          ls_filters-fldname = ls_field_tab-fieldname.
*          lv_fieldname_complex = |{ ls_filters-tabname }{ c_separator }{ ls_field_tab-fieldname }|.
*          lv_where_string = ls_where-line.
*          REPLACE ALL OCCURRENCES OF ls_field_tab-fieldname IN lv_where_string WITH lv_fieldname_complex.
*          ls_filters-where_clause = lv_where_string. "ls_where-line.
*          lv_counter = lv_counter + 1.
*          APPEND ls_filters TO lt_filters.
*        ENDLOOP.
*      ENDLOOP.
*
*
*    ENDLOOP.
    DATA: lv_tabix     TYPE sy-tabix,
          lv_tabix_tab TYPE sy-tabix.
    LOOP AT cond_tab ASSIGNING <fs_cond_tab>.
      ls_filters-domainv = gv_domainv.
      ls_filters-business_proc = gv_business_proc.
      ls_filters-tabname = <fs_cond_tab>-tablename.
      lv_counter = 1.


      lv_tabix = 1.
      lv_tabix_tab = 1.

      LOOP AT field_tab INTO ls_field_tab WHERE tablename = ls_filters-tabname.
        DO.

          READ TABLE <fs_cond_tab>-where_tab INTO ls_where INDEX lv_tabix.
          IF sy-subrc = 0 AND ls_where-line CS ls_field_tab-fieldname .
            ls_filters-counter = lv_counter.
            ls_filters-fldname = ls_field_tab-fieldname.
            lv_fieldname_complex = |{ ls_filters-tabname }{ c_separator }{ ls_field_tab-fieldname }|.
            lv_where_string = ls_where-line.
            REPLACE ALL OCCURRENCES OF ls_field_tab-fieldname IN lv_where_string WITH lv_fieldname_complex.
            ls_filters-where_clause = lv_where_string. "ls_where-line.
            lv_counter = lv_counter + 1.
            APPEND ls_filters TO lt_filters.
          ELSE.
            EXIT.
          ENDIF.
          lv_tabix = lv_tabix + 1.

        ENDDO.


        lv_tabix_tab = lv_tabix_tab + 1.
        READ TABLE field_tab INTO ls_field_tab INDEX lv_tabix_tab.
        IF  ls_where-line CS ls_field_tab-fieldname.
        ELSE.
          READ TABLE <fs_cond_tab>-where_tab INTO ls_where INDEX lv_tabix.
          IF sy-subrc = 0.
            IF ls_where-line CS ls_field_tab-fieldname .
            ELSE.
              READ TABLE lt_filters ASSIGNING <fs_filters> FROM ls_filters.
              IF sy-subrc = 0.
                CONCATENATE <fs_filters>-where_clause ls_where-line INTO <fs_filters>-where_clause
                SEPARATED BY space.

              ENDIF.
              lv_tabix = lv_tabix + 1.
            ENDIF.
          ENDIF.
        ENDIF.

      ENDLOOP.

    ENDLOOP.

    lv_counter = 1.
    LOOP AT field_ranges INTO ls_field_r.
      ls_ranges-domainv = gv_domainv.
      ls_ranges-business_proc = gv_business_proc.
      ls_ranges-tabname = ls_field_r-tablename.
      LOOP AT ls_field_r-frange_t INTO ls_range_d.
        ls_ranges-fldname = ls_range_d-fieldname.

        LOOP AT ls_range_d-selopt_t INTO ls_selopt.
          ls_ranges-counter = lv_counter.
          ls_ranges-sign = ls_selopt-sign.
          ls_ranges-opti = ls_selopt-option.
          ls_ranges-low  = ls_selopt-low.
          ls_ranges-high = ls_selopt-high.
          APPEND ls_ranges TO lt_ranges.
          lv_counter = lv_counter + 1.
          CLEAR: ls_ranges-sign,
                 ls_ranges-opti,
                 ls_ranges-low,
                 ls_ranges-high.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

    et_filters   = lt_filters[].
    et_ranges    = lt_ranges[].
    ev_nochanges = lv_nochanges.
  ENDMETHOD.


  METHOD show_filter_options_new.



    CONSTANTS: c_separator TYPE c VALUE '~'.

    DATA selid          TYPE rsdynsel-selid.
    DATA field_tab      TYPE TABLE OF rsdsfields.
    DATA field_tab_ini  TYPE TABLE OF rsdsfields.
    DATA field_tab_init TYPE TABLE OF rsdsfields.
    DATA field_tab_excl TYPE TABLE OF rsdsfields.
    DATA ls_field_ini   TYPE rsdsfields.
    DATA field_ranges   TYPE rsds_trange.
    DATA table_tab      TYPE TABLE OF rsdstabs.
    DATA cond_tab       TYPE rsds_twhere.
    DATA lv_title       TYPE sy-title.
    DATA lv_counter     TYPE i.
    DATA lt_filters     TYPE zontt_filters.
    DATA ls_filters     LIKE LINE OF lt_filters.
    DATA lv_fieldname_complex TYPE string.
    DATA lt_ranges        TYPE STANDARD TABLE OF zonta_oc_franges.
    DATA ls_ranges        LIKE LINE OF lt_ranges.
    DATA lt_ranges_ini    TYPE rsds_trange.
    DATA ls_rsds_range    TYPE rsds_range.
    DATA lt_frange_t      TYPE rsds_frange_t.
    DATA ls_rsds_frange   TYPE rsds_frange.
    DATA lt_rsds_selopt_t TYPE rsds_selopt_t.
    DATA ls_rsdsselopt    TYPE rsdsselopt.
    DATA lv_fldname       TYPE fieldname.
    DATA lv_tablename     TYPE tabname.
    DATA lv_nochanges     TYPE boolean.
    DATA lv_where_string  TYPE string.


    DATA: lt_dfies_tab  TYPE TABLE OF dfies,
          lt_all_fields TYPE TABLE OF dfies,
          ls_dfies_tab  TYPE  dfies.

    DATA: rl_fldname   TYPE RANGE OF fieldname.
    DATA: lt_relations TYPE STANDARD TABLE OF zonta_relations,
          ls_relations TYPE zonta_relations,
          lt_columns   TYPE STANDARD TABLE OF zonta_oc_col_all.

    DATA: lt_columns_tmp TYPE STANDARD TABLE OF zonta_oc_col_all,
          ls_all_fields  LIKE LINE OF lt_all_fields.

    FIELD-SYMBOLS: <fs_table_tab>      LIKE LINE OF table_tab,
                   <fs_relations>      LIKE LINE OF lt_relations,
                   <fs_field_tab_excl> LIKE LINE OF field_tab_excl,
                   <fs_cond_tab>       LIKE LINE OF cond_tab,
                   <fs_filters>        LIKE LINE OF lt_filters,
                   <fs_tab>            LIKE LINE OF field_tab_ini.

    DATA: ls_field_tab LIKE LINE OF field_tab,
          ls_where     LIKE LINE OF <fs_cond_tab>-where_tab,
          ls_field_r   LIKE LINE OF field_ranges,
          ls_range_d   TYPE rsds_frange,
          ls_selopt    TYPE rsdsselopt.

    DATA: lwr_fldname    TYPE selopt,
          ls_columns_tmp LIKE LINE OF lt_columns_tmp.


    CLEAR lt_rsds_selopt_t[].
    CLEAR lt_frange_t[].
    CLEAR ls_rsds_range.
    CLEAR lt_ranges_ini[].


    lt_relations[] = it_relations[].
    lt_columns[]   = it_columns[].

    lv_nochanges = abap_false.
    DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING sequence.

    SORT lt_columns BY fldname tabname.

    CLEAR lt_all_fields[].
    LOOP AT lt_relations ASSIGNING <fs_relations>.
      APPEND INITIAL LINE TO table_tab ASSIGNING <fs_table_tab>.
      <fs_table_tab>-prim_tab = <fs_relations>-tabname.

      CALL FUNCTION 'DDIF_FIELDINFO_GET'
        EXPORTING
          tabname        = <fs_relations>-tabname
          langu          = sy-langu
        TABLES
          dfies_tab      = lt_dfies_tab
        EXCEPTIONS
          not_found      = 1
          internal_error = 2
          OTHERS         = 3.
      IF sy-subrc = 0.
        APPEND LINES OF lt_dfies_tab TO lt_all_fields.
        lt_columns_tmp = lt_columns[].
        DELETE lt_columns_tmp WHERE tabname NE <fs_relations>-tabname.
*
*        rl_fldname = VALUE #( FOR sl_fldname IN lt_columns_tmp (   sign = 'I'
*                                                                 option = 'EQ'
*                                                                    low = sl_fldname-fldname ) ).
        CLEAR rl_fldname[].
        LOOP AT lt_columns_tmp INTO ls_columns_tmp.
          lwr_fldname-sign    =   'I'.
          lwr_fldname-option  =   'EQ'.
          lwr_fldname-low     =   ls_columns_tmp-fldname.
          APPEND lwr_fldname TO rl_fldname.
        ENDLOOP.

        DELETE lt_dfies_tab WHERE fieldname IN rl_fldname[].
        LOOP AT lt_dfies_tab INTO ls_dfies_tab.
          APPEND INITIAL LINE TO field_tab_excl ASSIGNING <fs_field_tab_excl>.
          <fs_field_tab_excl>-tablename = ls_dfies_tab-tabname.
          <fs_field_tab_excl>-fieldname = ls_dfies_tab-fieldname.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

    FIELD-SYMBOLS: <fs_ranges> LIKE LINE OF it_ranges.
    SORT lt_all_fields BY tabname fieldname.
    LOOP AT it_ranges ASSIGNING <fs_ranges>.
      READ TABLE lt_all_fields INTO  ls_dfies_tab WITH KEY tabname = <fs_ranges>-tabname
                                                           fieldname = <fs_ranges>-fldname BINARY SEARCH.
      IF sy-subrc = 0.
        <fs_ranges>-counter = ls_dfies_tab-position.
      ENDIF.
    ENDLOOP.

    CLEAR field_tab_ini[].

    IF lines( it_ranges ) > 0.
      SORT it_ranges BY tabname counter. "fldname counter.
      READ TABLE it_ranges INTO ls_ranges INDEX 1.
      lv_fldname   = ls_ranges-fldname.
      lv_tablename = ls_ranges-tabname.

      ls_field_ini-tablename = ls_ranges-tabname.
      ls_field_ini-fieldname = ls_ranges-fldname.
      SORT lt_all_fields BY tabname fieldname.
      READ TABLE lt_all_fields INTO ls_all_fields WITH KEY tabname = ls_ranges-tabname fieldname = ls_ranges-fldname BINARY SEARCH.
      IF sy-subrc = 0.
        ls_field_ini-type = ls_all_fields-inttype.
        ls_field_ini-where_leng = ls_all_fields-leng."ls_all_fields-outputlen.
      ENDIF.
      READ TABLE field_tab_ini TRANSPORTING NO FIELDS WITH KEY tablename = ls_field_ini-tablename
                                                               fieldname = ls_field_ini-fieldname.
      IF sy-subrc NE 0.
        APPEND ls_field_ini TO field_tab_ini.
      ENDIF.

      LOOP AT it_ranges INTO ls_ranges.
        IF ls_ranges-tabname NE lv_tablename.
          IF NOT lt_rsds_selopt_t IS INITIAL.
            ls_rsds_frange-fieldname  = lv_fldname.
            ls_rsds_frange-selopt_t[] = lt_rsds_selopt_t[].
            CLEAR lt_rsds_selopt_t[].
            APPEND ls_rsds_frange TO lt_frange_t .
          ENDIF.

          ls_rsds_range-tablename = lv_tablename.
          ls_rsds_range-frange_t[] = lt_frange_t[].
          APPEND ls_rsds_range TO lt_ranges_ini[].
          CLEAR lt_frange_t[].
          CLEAR ls_rsds_range.
        ELSE.
          IF ls_ranges-fldname NE lv_fldname.
            ls_rsds_frange-fieldname  = lv_fldname.
            ls_rsds_frange-selopt_t[] = lt_rsds_selopt_t[].
            CLEAR lt_rsds_selopt_t[].
            APPEND ls_rsds_frange TO lt_frange_t .

            ls_field_ini-tablename = ls_ranges-tabname.
            ls_field_ini-fieldname = ls_ranges-fldname.
            SORT lt_all_fields BY tabname fieldname.
            READ TABLE lt_all_fields INTO ls_all_fields WITH KEY tabname = ls_ranges-tabname fieldname = ls_ranges-fldname BINARY SEARCH.
            IF sy-subrc = 0.
              ls_field_ini-type = ls_all_fields-inttype.
              ls_field_ini-where_leng = ls_all_fields-leng."ls_all_fields-outputlen.
            ENDIF.
            READ TABLE field_tab_ini TRANSPORTING NO FIELDS WITH KEY tablename = ls_field_ini-tablename
                                                                     fieldname = ls_field_ini-fieldname.
            IF sy-subrc NE 0.
              APPEND ls_field_ini TO field_tab_ini.
            ENDIF.
          ELSE.

          ENDIF.
        ENDIF.

        ls_rsdsselopt-sign   = ls_ranges-sign.
        ls_rsdsselopt-option = ls_ranges-opti.
        ls_rsdsselopt-low    = ls_ranges-low.
        ls_rsdsselopt-high   = ls_ranges-high.
        APPEND ls_rsdsselopt TO lt_rsds_selopt_t.

        lv_fldname = ls_ranges-fldname.
        lv_tablename = ls_ranges-tabname.

        ls_field_ini-tablename = ls_ranges-tabname.
        ls_field_ini-fieldname = ls_ranges-fldname.
        SORT lt_all_fields BY tabname fieldname.
        READ TABLE lt_all_fields INTO ls_all_fields WITH KEY tabname = ls_ranges-tabname fieldname = ls_ranges-fldname BINARY SEARCH.
        IF sy-subrc = 0.
          ls_field_ini-type = ls_all_fields-inttype.
          ls_field_ini-where_leng = ls_all_fields-leng."ls_all_fields-outputlen.
        ENDIF.
        READ TABLE field_tab_ini TRANSPORTING NO FIELDS WITH KEY tablename = ls_field_ini-tablename
                                                                 fieldname = ls_field_ini-fieldname.
        IF sy-subrc NE 0.
          APPEND ls_field_ini TO field_tab_ini.
        ENDIF.

      ENDLOOP.
    ENDIF.


    IF NOT lt_rsds_selopt_t IS INITIAL.
      ls_rsds_frange-fieldname = ls_ranges-fldname.
      ls_rsds_frange-selopt_t[] = lt_rsds_selopt_t[].
      CLEAR lt_rsds_selopt_t[].
      APPEND ls_rsds_frange TO lt_frange_t .

      ls_rsds_range-tablename = ls_ranges-tabname.
      ls_rsds_range-frange_t[] = lt_frange_t[].
      APPEND ls_rsds_range TO lt_ranges_ini[].

      ls_field_ini-tablename = ls_ranges-tabname.
      ls_field_ini-fieldname = ls_ranges-fldname.
      SORT lt_all_fields BY tabname fieldname.
      READ TABLE lt_all_fields INTO ls_all_fields WITH KEY tabname = ls_ranges-tabname fieldname = ls_ranges-fldname BINARY SEARCH.
      IF sy-subrc = 0.
        ls_field_ini-type = ls_all_fields-inttype.
        ls_field_ini-where_leng = ls_all_fields-leng.
      ENDIF.
      READ TABLE field_tab_ini TRANSPORTING NO FIELDS WITH KEY tablename = ls_field_ini-tablename
                                                               fieldname = ls_field_ini-fieldname.
      IF sy-subrc NE 0.
        APPEND ls_field_ini TO field_tab_ini.
      ENDIF.
    ENDIF.

*    SORT field_tab_ini BY tablename fieldname.
*    DELETE ADJACENT DUPLICATES FROM field_tab_ini COMPARING tablename fieldname.

    LOOP AT field_tab_ini ASSIGNING <fs_tab> WHERE where_leng > 45.
      <fs_tab>-where_leng = 45.
    ENDLOOP.

    CALL FUNCTION 'FREE_SELECTIONS_INIT'
      EXPORTING
        kind                  = 'T'
        field_ranges_int      = lt_ranges_ini[]
      IMPORTING
        selection_id          = selid
      TABLES
        tables_tab            = table_tab
        fields_tab            = field_tab_ini
        tabfields_not_display = field_tab_excl
*       fields_not_selected   = field_tab_excl
      EXCEPTIONS
        OTHERS                = 4.
    IF sy-subrc <> 0.
      MESSAGE 'Error in initialization' TYPE 'I' DISPLAY LIKE 'E'.
      lv_nochanges = abap_true.
      LEAVE PROGRAM.
    ENDIF.

    IF gv_domainv IS INITIAL
    OR gv_business_proc IS INITIAL.
      READ TABLE lt_relations INTO ls_relations INDEX 1.
      gv_domainv = ls_relations-domainv.
      gv_business_proc = ls_relations-business_proc.
    ENDIF.

    CONCATENATE 'Entity'
               gv_domainv
               ' - '
               gv_business_proc
               INTO  lv_title
               SEPARATED BY space.


    CALL FUNCTION 'FREE_SELECTIONS_DIALOG'
      EXPORTING
        selection_id  = selid
        title         = lv_title
        as_window     = ' '
      IMPORTING
        where_clauses = cond_tab
        field_ranges  = field_ranges
      TABLES
        fields_tab    = field_tab
      EXCEPTIONS
        OTHERS        = 4.
    IF sy-subrc <> 0.
      MESSAGE 'No changes were saved' TYPE 'I'.
      lv_nochanges = abap_true.
*      LEAVE PROGRAM.
    ENDIF.




    CLEAR lt_filters[].
    SORT cond_tab BY tablename.
*    LOOP AT cond_tab ASSIGNING <fs_cond_tab>.
*      ls_filters-domainv = gv_domainv.
*      ls_filters-business_proc = gv_business_proc.
*      ls_filters-tabname = <fs_cond_tab>-tablename.
*      lv_counter = 1.
*      LOOP AT field_tab INTO ls_field_tab WHERE tablename = ls_filters-tabname.
*
*        LOOP AT <fs_cond_tab>-where_tab INTO ls_where WHERE line CS ls_field_tab-fieldname.
*          ls_filters-counter = lv_counter.
*          ls_filters-fldname = ls_field_tab-fieldname.
*          lv_fieldname_complex = |{ ls_filters-tabname }{ c_separator }{ ls_field_tab-fieldname }|.
*          lv_where_string = ls_where-line.
*          REPLACE ALL OCCURRENCES OF ls_field_tab-fieldname IN lv_where_string WITH lv_fieldname_complex.
*          ls_filters-where_clause = lv_where_string. "ls_where-line.
*          lv_counter = lv_counter + 1.
*          APPEND ls_filters TO lt_filters.
*        ENDLOOP.
*      ENDLOOP.
*
*
*    ENDLOOP.
    DATA: lv_tabix     TYPE sy-tabix,
          lv_tabix_tab TYPE sy-tabix.
    LOOP AT cond_tab ASSIGNING <fs_cond_tab>.
      ls_filters-domainv = gv_domainv.
      ls_filters-business_proc = gv_business_proc.
      ls_filters-tabname = <fs_cond_tab>-tablename.
      lv_counter = 1.


      lv_tabix = 1.
      lv_tabix_tab = 1.

      LOOP AT field_tab INTO ls_field_tab WHERE tablename = ls_filters-tabname.
        DO.

          READ TABLE <fs_cond_tab>-where_tab INTO ls_where INDEX lv_tabix.
          IF sy-subrc = 0 AND ls_where-line CS ls_field_tab-fieldname .
            ls_filters-counter = lv_counter.
            ls_filters-fldname = ls_field_tab-fieldname.
            lv_fieldname_complex = |{ ls_filters-tabname }{ c_separator }{ ls_field_tab-fieldname }|.
            lv_where_string = ls_where-line.
            REPLACE ALL OCCURRENCES OF ls_field_tab-fieldname IN lv_where_string WITH lv_fieldname_complex.
            ls_filters-where_clause = lv_where_string. "ls_where-line.
            lv_counter = lv_counter + 1.
            APPEND ls_filters TO lt_filters.
          ELSE.
            EXIT.
          ENDIF.
          lv_tabix = lv_tabix + 1.

        ENDDO.


        lv_tabix_tab = lv_tabix_tab + 1.
        READ TABLE field_tab INTO ls_field_tab INDEX lv_tabix_tab.
        IF  ls_where-line CS ls_field_tab-fieldname.
        ELSE.
          READ TABLE <fs_cond_tab>-where_tab INTO ls_where INDEX lv_tabix.
          IF sy-subrc = 0.
            IF ls_where-line CS ls_field_tab-fieldname .
            ELSE.
              READ TABLE lt_filters ASSIGNING <fs_filters> FROM ls_filters.
              IF sy-subrc = 0.
                CONCATENATE <fs_filters>-where_clause ls_where-line INTO <fs_filters>-where_clause
                SEPARATED BY space.

              ENDIF.
              lv_tabix = lv_tabix + 1.
            ENDIF.
          ENDIF.
        ENDIF.

      ENDLOOP.

    ENDLOOP.

    lv_counter = 1.
    LOOP AT field_ranges INTO ls_field_r.
      ls_ranges-domainv = gv_domainv.
      ls_ranges-business_proc = gv_business_proc.
      ls_ranges-tabname = ls_field_r-tablename.
      LOOP AT ls_field_r-frange_t INTO ls_range_d.
        ls_ranges-fldname = ls_range_d-fieldname.

        LOOP AT ls_range_d-selopt_t INTO ls_selopt.
          ls_ranges-counter = lv_counter.
          ls_ranges-sign = ls_selopt-sign.
          ls_ranges-opti = ls_selopt-option.
          ls_ranges-low  = ls_selopt-low.
          ls_ranges-high = ls_selopt-high.
          APPEND ls_ranges TO lt_ranges.
          lv_counter = lv_counter + 1.
          CLEAR: ls_ranges-sign,
                 ls_ranges-opti,
                 ls_ranges-low,
                 ls_ranges-high.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

    et_filters   = lt_filters[].
    et_ranges    = lt_ranges[].
    ev_nochanges = lv_nochanges.
  ENDMETHOD.


  METHOD validate_alias.


    DATA: lt_columns TYPE STANDARD TABLE OF zonta_oc_columns,
          lt_domains TYPE STANDARD TABLE OF zonta_oc_columns,
          ls_domains TYPE zonta_oc_columns,
          ls_columns TYPE zonta_oc_columns.

    FIELD-SYMBOLS: <fs_col> TYPE zonta_oc_columns.

    lt_columns = it_columns[].
    SORT lt_columns BY domainv business_proc fldname.
    lt_domains = lt_columns[].

    DELETE ADJACENT DUPLICATES FROM lt_domains COMPARING domainv business_proc.
    DELETE ADJACENT DUPLICATES FROM lt_columns COMPARING domainv business_proc fldname.
    SORT lt_columns BY domainv business_proc fldname.

    LOOP AT lt_domains INTO ls_domains.
      LOOP AT lt_columns INTO ls_columns WHERE domainv       = ls_domains-domainv
                                           AND business_proc = ls_domains-business_proc.
        READ TABLE gt_existing_columns INTO gs_existing_columns WITH KEY tabname = ls_domains-tabname
                                                     fldname = ls_domains-fldname BINARY SEARCH.
        IF   sy-subrc NE 0
        OR ( sy-subrc = 0  AND gs_existing_columns-key_field IS INITIAL ).
          LOOP AT it_columns ASSIGNING <fs_col> WHERE domainv       = ls_domains-domainv
                                                  AND business_proc = ls_domains-business_proc
                                                  AND fldname       = ls_columns-fldname.
            <fs_col>-alias_fldname = ls_columns-alias_fldname.
          ENDLOOP.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


  METHOD write_cell.

    DATA: lo_cell TYPE ole2_object.

    CALL METHOD OF iv_sheet 'Cells' = lo_cell
      EXPORTING
        #1 = iv_row
        #2 = iv_col.

    SET PROPERTY OF lo_cell 'Value' = iv_value.

    FREE OBJECT lo_cell.

  ENDMETHOD.
ENDCLASS.
