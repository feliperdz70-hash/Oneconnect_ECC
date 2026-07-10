class ZONCL_OC_BASE_HANDLER definition
  public
  abstract
  create public .

public section.
  type-pools RSDS .
  type-pools SLIS .

  interfaces ZONIF_OC_DATA_HANDLER .

  types:
    ty_table TYPE STANDARD TABLE OF string .
  types:
    BEGIN OF ty_properties_meta,
        messagetype TYPE string,
        change      TYPE string,
        delete      TYPE string,
        domain      TYPE string,
        entity      TYPE string,
        description TYPE string,
        tag1        TYPE string,
        tag2        TYPE string,
        tag3        TYPE string,
        tag4        TYPE string,
        tag5        TYPE string,
      END OF ty_properties_meta .
  types:
    tty_relations TYPE STANDARD TABLE OF zonta_relations .
  types:
*** Metadata
    BEGIN OF ty_metadatadet,
        fieldname TYPE string,
        offset    TYPE string,
        length    TYPE string,
        type      TYPE string,
        fieldtext TYPE string,
        keyflag   TYPE string,
        decimals  TYPE string,
      END OF ty_metadatadet .
  types:
    BEGIN OF ty_metadata_s,
        table(60) TYPE c,
        metadata  TYPE STANDARD TABLE OF ty_metadatadet WITH NON-UNIQUE DEFAULT KEY,
      END OF ty_metadata_s .
  types:
* BOdy
    BEGIN OF ty_body,
        table(60) TYPE c,
        data      TYPE REF TO data,
      END OF ty_body .
  types:
    BEGIN OF ty_properties,
        messagetype TYPE string,
        change      TYPE string,
        delete      TYPE string,
        domain      TYPE string,
        entity      TYPE string,
        description TYPE string,
      END OF ty_properties .
  types:
* OneConnect Detail
    BEGIN OF ty_oneconnectdet,
        properties TYPE ty_properties,
        metadata   TYPE STANDARD TABLE OF ty_metadata_s WITH NON-UNIQUE DEFAULT KEY,
        body       TYPE ty_body,
      END OF ty_oneconnectdet .
  types:
    BEGIN OF ty_oneconnectdet_meta,
        properties TYPE ty_properties_meta,
        metadata   TYPE STANDARD TABLE OF ty_metadata_s WITH NON-UNIQUE DEFAULT KEY,
        body       TYPE ty_body,
      END OF ty_oneconnectdet_meta .
  types:
* OneConnect
    BEGIN OF ty_oneconnect,
        oneconnect TYPE ty_oneconnectdet,
      END OF ty_oneconnect .
  types:
* OneConnect Meta
    BEGIN OF ty_oneconnect_meta,
        oneconnect TYPE ty_oneconnectdet_meta,
      END OF ty_oneconnect_meta .
  types:
    BEGIN OF ty_cdhdr,
        objectclas TYPE cdhdr-objectclas,
        objectid   TYPE cdhdr-objectid,
        changenr   TYPE cdhdr-changenr,
      END OF ty_cdhdr .
  types:
    tty_cdhdr TYPE STANDARD TABLE OF ty_cdhdr .
  types:
    tty_where TYPE STANDARD TABLE OF rsdswhere .
  types:
    tty_columns TYPE STANDARD TABLE OF zonta_oc_col_all .
  types:
    tty_endpoints TYPE STANDARD TABLE OF zonta_oc_endp .
  types:
    tty_line TYPE STANDARD TABLE OF line .
  types:
    tty_primary_key_names TYPE HASHED TABLE OF string WITH UNIQUE KEY table_line .
  types:
    BEGIN OF ty_cdpos,
        tabname TYPE cdpos-tabname,
        tabkey  TYPE cdpos-tabkey,
      END OF ty_cdpos .
  types:
    BEGIN OF ty_json,
        json_id TYPE zonde_json_id,
        json    TYPE string,
      END OF ty_json .
  types:
    tty_cdpos TYPE STANDARD TABLE OF ty_cdpos .
  types:
    BEGIN OF ty_datat,
        tabname  TYPE tabname,
        lo_table TYPE REF TO data,
      END OF ty_datat .

  data:
**  types:
**    tt_table_log TYPE STANDARD TABLE OF ty_table_log .
**  types:
**    BEGIN OF ty_log_json_result,
**             sizet          TYPE zonde_oc_num30,
**             recordst TYPE zonde_oc_num30,
**             recordst_obj  TYPE zonde_oc_num30,
**             tables                   LIKE ltt_table_log,
**           END OF ty_log_json_result .
*********
    gt_datat TYPE STANDARD TABLE OF ty_datat .
  data:
    gt_causes TYPE STANDARD TABLE OF string .
  data:
    gt_fixes TYPE STANDARD TABLE OF string .
  data GV_COMMIT type BOOLEAN_FLG .
  data C_ALIAS type STRING value 'ALIAS' ##NO_TEXT.
  data C_BOTH type STRING value 'BOTH' ##NO_TEXT.
  data GV_CONTEXT_SET type ABAP_BOOL .
  data GV_EVENT_ID type STRING .
*    DATA gv_sizet TYPE zonde_oc_num30 .
*    DATA gv_recordst TYPE zonde_oc_num30 .
  data GV_JSON type STRING .
  data GS_ELOG type ZONST_LOG_OTEL .
  data GV_JSONID type ZONDE_JSON_ID .
  data:
    gt_json     TYPE STANDARD TABLE OF ty_json .   "string .
  data:
    gs_json LIKE LINE OF gt_json .
  data:
    gt_log_ext TYPE STANDARD TABLE OF zonst_oc_log_ext .
  data GT_CDPOS type TTY_CDPOS .
*    DATA gv_recordst_obj TYPE zonde_oc_num30 .
  data GV_RECORDST_OBJI type ZONDE_OC_NUM30 .
  data:
    gt_dfies_tab TYPE STANDARD TABLE OF dfies .
  data GT_RANGES_WHERE type ZONTT_OC_RSPARAMS_TT .
  data GV_UUID type UUID .
  class-data GV_CANCELLED type BOOLEAN .

  methods GET_DATA
  abstract
    exporting
      !EV_SIZET type ZONDE_OC_NUM30
      !EV_RECORDST type ZONDE_OC_NUM30 .
  methods CALL_BASE_GET_DATA
    exporting
      !EV_SIZET type ZONDE_OC_NUM30
      !EV_RECORDST type ZONDE_OC_NUM30 .
  methods SET_GLOBALS
    importing
      !IV_KDOC type BOOLEAN optional
      !IV_TABLE type BOOLEAN optional
      !IV_DDIC type BOOLEAN optional
      !IV_DEST type RFCDEST optional
      !IV_UPDATE type BOOLEAN optional
      !IV_DELETE type BOOLEAN optional
      !IV_DOMAINV type ZONDE_DOMAIN optional
      !IV_ENTITY type ZONDE_PROCESS optional
      !IV_KEY_QUEUE type STRING optional
      !IV_BATCH type BOOLEAN optional
      !IT_WHERE type ZONTTRSDSWHERE optional
      !IV_INSTID type SIBFBORIID optional
      !IV_ANYTABLE type TABNAME optional
      !IV_ALIAS type BOOLEAN optional
      !IV_FIELDNAME type BOOLEAN optional
      !IV_TAGDATA type BOOLEAN optional
      !IV_TAGMETADATA type BOOLEAN optional
      !IV_BOTHNAMES type BOOLEAN optional
      !IT_ENDPOINTS type TTY_ENDPOINTS optional
      !IT_WHERE_COND_TAB type RSDS_TWHERE optional
      !IV_UUID type UUID optional
      !IV_VARIANT type VARIANT optional
      !IV_TM type ABAP_BOOL optional
      !IT_RANGES_WHERE type ZONTT_OC_RSPARAMS_TT optional .
  methods GET_LENGHT_KEY
    importing
      !IV_TABNAME type DDOBJNAME
      !IV_PARENT type ZONDE_PARENTREL optional
    returning
      value(RV_LENGHT) type NUMC2 .
  methods ADJUST_CONTEXT_FROM_CALLSTACK .
  methods SET_VARIANT .
  methods RETURN_WHERE_VARIABLES
    exporting
      value(ET_CONDTAB) type RSDS_TWHERE
      value(ET_FIELDTAB) type RSDSFIELDS_T .
  methods SET_WHERE
    importing
      !IV_ANY type BOOLEAN optional
    exporting
      !EV_CLOSED type ABAP_BOOL
      value(R_WHERE) type ZONTTRSDSWHERE .
  methods GET_VARIANT_VALUES
    importing
      !IV_VARIANT type VARIANT
      !IV_DOMAINV type ZONDE_DOMAIN
      !IV_ENTITY type ZONDE_PROCESS
    exporting
      !ET_WHERE type RSDS_TWHERE
      !ES_WHERE type ZONTTRSDSWHERE
      !ET_RANGES_WHERE type ZONTT_OC_RSPARAMS_TT .
  methods DISPLAY_WHERE_WITH_VARIANT
    returning
      value(R_WHERE) type ZONTTRSDSWHERE .
  methods SET_WHERE_WITH_VARIANT
    returning
      value(R_WHERE) type ZONTTRSDSWHERE .
  methods COPY_CONTEXT_FROM
    importing
      !IO_SOURCE type ref to ZONCL_OC_BASE_HANDLER .
  methods GET_GLOBAL_DATA .
  methods GET_DATA_TABLE .
  methods GET_HANDLER_BY_FLAGS .
  methods SET_PROCESS
    exporting
      !EV_CLOSED type ABAP_BOOL .
  methods DOWNLOAD_LOG_FILE .
  methods GET_PROCESS_CONTEXT_MESSAGE
    returning
      value(RV_MESSAGE) type STRING .
  methods GET_DATABASE_DATAT_OPEN_IMM
    importing
      !IR_HDL type ref to ZONCL_OC_BASE_HANDLER
    returning
      value(RV_TABLE) type ref to DATA .
  methods GET_DATABASE_DATAT_OPEN
    returning
      value(RV_TABLE) type ref to DATA .
  methods GET_DATABASE_DATAT
    returning
      value(RV_TABLE) type ref to DATA .
  methods GET_DATABASE_DATA
    returning
      value(RV_TABLE) type ref to DATA .
  methods ALIAS_BOTH_JSON
    importing
      !IV_OPTION type STRING
    changing
      !CV_JSON type STRING .
  methods GET_WHERE
    importing
      !IV_ANY type BOOLEAN optional
      !IV_TABNAME type TABNAME optional
    returning
      value(R_WHERE) type ZONTTRSDSWHERE .
  methods FIELDNAME_JSON
    changing
      !CV_JSON type STRING .
  methods GET_DATA_BY_TABLE
    importing
      !IV_TABLE type TABNAME
      !IV_PARENT_RELATION type ZONDE_PARENTREL optional
    exporting
      !ET_FCAT type LVC_T_FCAT
      !ET_DATA type ref to DATA .
  methods SET_FIELDS
    importing
      !IV_ALIAS type BOOLEAN default 'X'
      !IV_TABNAME type TABNAME optional
    returning
      value(R_FIELDS) type STRING .
  methods SET_FIELDS_BOTH
    importing
      !IV_ALIAS type BOOLEAN default 'X'
      !IV_TABNAME type TABNAME optional
    exporting
      !EV_FIELDS type STRING
      value(ET_FIELDS) type TTY_LINE .
  methods SET_FIELDS_IN_TABLE
    importing
      !IV_ALIAS type BOOLEAN default 'X'
      !IV_TABNAME type TABNAME optional
    exporting
      value(ET_FIELDS) type TTY_LINE .
  methods CONVERSION_EXIT
    importing
      !IV_TABNAME type TABNAME
    changing
      !CS_STRING type ANY .
  methods GET_EVENTID
    importing
      !IT_KEYS type TTY_WHERE
    changing
      !CS_LINE_JSON type ANY .
  methods GET_TIMESTAMP
    returning
      value(RV_TIMESTAMP) type STRING .
  methods SEND_JSON_RESULT .
  methods SET_METADATA_NODE
    importing
      !IT_FCAT type LVC_T_FCAT
      !IV_TABNAME type TABNAME optional
    changing
      !CS_METADATA type ANY .
  methods SET_METADATA_TABLE_NODE
    importing
      !IV_TABNAME type TABNAME
    changing
      !CS_METADATA type ANY .
  methods GET_TABLE_BY_TABLE_DATA_KDOC
    importing
      !IV_TABLE type TABNAME
      !IV_PARENT_RELATION type ZONDE_PARENTREL optional
    exporting
      !ET_FCAT type LVC_T_FCAT
      !ET_DATA type ref to DATA .
  methods GET_DATA_BY_TABLE_DATA
    importing
      !IV_TABLE type TABNAME
      !IV_PARENT_RELATION type ZONDE_PARENTREL optional
    exporting
      !ET_FCAT type LVC_T_FCAT
      !ET_DATA type ref to DATA .
  methods ASSIGN_COMPONENT_TABLE
    importing
      !IS_SOURCE type ANY
      !IS_RELATIONS type ZONTA_RELATIONS
      !IV_ALIAS type BOOLEAN
      !IT_COLUMNS type TTY_COLUMNS
    changing
      !CS_TARGET type ANY .
  methods ASSIGN_COMPONENT_TABLE_KDOC
    importing
      !IS_SOURCE type ANY
      !IS_RELATIONS type ZONTA_RELATIONS
      !IV_ALIAS type BOOLEAN
      !IT_COLUMNS type TTY_COLUMNS
    changing
      !CS_TARGET type ANY .
  methods GET_KEY_KDOC
    importing
      !IV_PARENT_RELATION type ZONDE_PARENTREL
      !IV_TABNAME type TABNAME
      !IS_LINE type ANY optional
    exporting
      !ET_KEYS type TTY_WHERE
      !EV_KEY type STRING
      !EV_KEY_MAIN type STRING .
  methods GET_KEY
    importing
      !IV_PARENT_RELATION type ZONDE_PARENTREL
      !IV_TABNAME type TABNAME
    exporting
      !ET_KEYS type TTY_WHERE
      !EV_KEY type STRING
      !EV_KEY_MAIN type STRING .
  methods SET_TABLE_CUSTOM
    importing
      !IV_ADD_TABNAME type ABAP_BOOL optional
    exporting
      value(RT_TABLE) type ref to DATA
    changing
      !CT_JSON_MAP type ZONTT_DD03P optional .
  methods PRETTY_JSON
    importing
      !IV_MODE type STRING
    changing
      !CV_JSON type STRING .
  methods SEND_JSON_HTTP_CON_RAP
    importing
      !I_DEST type RFCDEST
    exporting
      !E_RETURN type STRING
      !E_SIZE type ZONDE_OC_NUM30
      !E_RECORDS type ZONDE_OC_NUM30
      value(E_RESPONSE) type STRING .
  methods SEND_JSON_HTTP_CON_OPENCURSOR
    importing
      !IV_DEST type RFCDEST
      !IV_JSON type STRING
    exporting
      !EV_RETURN type STRING
      !EV_SIZE type ZONDE_OC_NUM30
      !EV_RECORDS type ZONDE_OC_NUM30
      value(EV_RESPONSE) type STRING .
  methods SEND_JSON_HTTP_CON_NEW
    importing
      !I_DEST type RFCDEST
    exporting
      !E_RETURN type STRING
      !E_SIZE type ZONDE_OC_NUM30
      !E_RECORDS type ZONDE_OC_NUM30
      value(E_RESPONSE) type STRING .
  methods SEND_JSON_HTTP_CON
    importing
      !I_DEST type RFCDEST
    exporting
      !E_RETURN type STRING
      !E_SIZE type ZONDE_OC_NUM30
      !E_RECORDS type ZONDE_OC_NUM30
      value(E_RESPONSE) type STRING .
  methods GET_DATA_PROPERTIES
    changing
      !CS_PROPERTIES type ANY .
  methods GET_DATA_METADATA
    changing
      !CS_METADATA type ANY .
  methods SEND_JSON_ERROR .
  methods UPDATE_SLG1_LOG
    importing
      !IT_LOG_EXT type ZONTT_OC_LOG_EXT .
  methods RETURN_LOG_TABLE
    exporting
      !ET_LOG_EXT type ZONTT_OC_LOG_EXT .
  methods APPEND_SLG1_LOG
    importing
      !IV_TABNAME type TABNAME
      !IV_KEY type ANY optional
      !IV_MESSAGE_V1 type STRING default 'Object'
      !IV_MESSAGE_V2 type STRING optional
      !IV_MESSAGE_V3 type STRING default 'Transmitted'
      !IV_MESTYP type SYMSGTY optional .
  methods VALIDATE_DDIC_ACTIVE
    importing
      !IV_OBJECT type TADIR-OBJ_NAME
    changing
      value(CV_SUBRC) type SY-SUBRC optional .
  methods SET_CORR_INSERT
    importing
      !IV_MODE type STRING
      !IV_OBJECT type STRING .
  methods GET_DDICOBJECT_FROM_CDS
    importing
      !IV_TABNAME type DD03L-TABNAME
    returning
      value(RV_DDIC_OBJECT) type TABNAME .
  methods EXECUTE_BATCH
    importing
      !IV_ANYTAB type BOOLEAN optional
      !IV_TABNAME type TABNAME optional .
  methods SET_TABLE
    importing
      !IV_ADD_TABNAME type ABAP_BOOL optional
    returning
      value(RT_TABLE) type ref to DATA .
  methods ADD_POSITION_TABLE
    importing
      !IV_TABNAME type STRING .
  methods IS_CDS_ENTITY
    importing
      !IV_TABNAME type DD03L-TABNAME
    returning
      value(RV_IS_CDS_ENTITY) type BOOLEAN .
  methods SET_GLOBALS_ANY
    importing
      !IV_TABNAME type TABNAME
      !IV_UPDATE type BOOLEAN
      !IV_DELETE type BOOLEAN
      !IT_WHERE type ZONTTRSDSWHERE optional
      !IV_ALIAS type BOOLEAN default 'X'
      !IV_DEST type RFCDEST optional
      !IV_FIELDNAME type BOOLEAN optional
      !IV_BOTHNAMES type BOOLEAN optional .
*  methods BUILD_METADATA_ANY
*    importing
*      !IV_TABNAME type TABNAME
*      !IV_FIELDNAME type BOOLEAN
*    changing
*      !CT_FCAT type SLIS_T_FIELDCAT_ALV .
  methods BOTHNAMES_JSON
    changing
      !CV_JSON type STRING .
  methods ALIAS_JSON
    changing
      !CV_JSON type STRING .
  methods CLEAR_GLOBALS .
  methods METADATA_CONVERSION
    changing
      value(CV_TYPE) type ANY
      !CV_LEN type ANY optional .
  methods UPDATE_TABLE_JSON
    importing
      !IV_JSON type STRING
      !IV_UUID type UUID
      !IV_MESSAGE type STRING optional
      !IV_RET_CODE type SY-SUBRC optional
      !IV_STATUS_CODE type CHAR2
      !IV_ZOFFSET type ZONDE_OC_NUM30 optional .
  methods NORMALIZE_WHERE_KEYS
    importing
      !IV_TABNAME type TABNAME
      !IV_WHERE type STRING
    exporting
      value(EV_WHERE) type STRING .
  methods SEND_LOG_OTEL
    importing
      !IS_LOG_OTEL type ZONST_LOG_OTEL .
  methods INTERPRET_MESSAGE
    importing
      !IV_MSGNR type MSGNR
      !IV_MSGV1 type ANY optional
      !IV_MSGV2 type ANY optional
      !IV_MSGV3 type ANY optional
      !IV_MSGV4 type ANY optional
    exporting
      !EV_MESSAGE type STRING
    changing
      !CT_TABLE type TY_TABLE .
  methods PRINT_ERROR_OTEL .
  methods CHECK_ENTITY_CONSISTENCY .
protected section.


*********
    TYPES: BEGIN OF ty_table_log,
             tabname TYPE char50,
             size    TYPE I,
           END OF ty_table_log.

    TYPES: tt_table_log TYPE STANDARD TABLE OF ty_table_log.

    DATA ltt_table_log TYPE tt_table_log.

  data MO_HANDLER type ref to ZONCL_OC_BASE_HANDLER .
  constants C_KDOC type STRING value 'KDOC' ##NO_TEXT.
  constants GC_WARNING type STRING value 'WARNING' ##NO_TEXT.
  constants GC_ERROR type STRING value 'ERROR' ##NO_TEXT.
  constants C_TABLE type STRING value 'TABL' ##NO_TEXT.
  data GS_OC_OBJ type ZONTA_OBJ_OC .
  data:
    gt_json_map       TYPE STANDARD TABLE OF dd03p WITH DEFAULT KEY .
  data GV_MESSAGETYPE type STRING .
  data:
    gt_relations      TYPE STANDARD TABLE OF zonta_relations WITH DEFAULT KEY .
  data:
    gt_relations_aux     TYPE STANDARD TABLE OF zonta_relations WITH DEFAULT KEY .
  data:
    gt_relations_aux2    TYPE STANDARD TABLE OF zonta_relations WITH DEFAULT KEY .
  data:
    gt_columns_all    TYPE STANDARD TABLE OF zonta_oc_col_all WITH DEFAULT KEY .
  data:
    gt_converted    TYPE STANDARD TABLE OF zonta_oc_conv WITH DEFAULT KEY .
  data:
    gt_filters        TYPE STANDARD TABLE OF zonta_oc_filters WITH DEFAULT KEY .
  data:
    gt_dfies_tab_cat  TYPE STANDARD TABLE OF dfies WITH DEFAULT KEY .
  data GR_CACHED_TYPE_WO type ref to CL_ABAP_TABLEDESCR .
  data GR_CACHED_TYPE_W type ref to CL_ABAP_TABLEDESCR .
  data GV_KDOC type BOOLEAN .
  data GV_TABLE type BOOLEAN .
  data GV_DDIC type BOOLEAN .
  data GV_DEST type RFCDEST .
  data GV_PRIMARY type RFCDEST .
  data GV_SECONDARY type RFCDEST .
  data GV_UPDATE type BOOLEAN .
  data GV_DELETE type BOOLEAN .
  data GV_SENDING type STRING .
  data GV_DOMAINV type ZONDE_DOMAIN .
  data GV_ENTITY type ZONDE_PROCESS .
  data GV_KEY_QUEUE type STRING .
  data GV_JSON_PREV type BOOLEAN .
  data GV_BATCH type BOOLEAN .
  data GV_INSTID type SIBFBORIID .
  data GV_ANYTABLE type TABNAME .
  data GV_ALIAS type BOOLEAN .
  data GV_FIELDNAME type BOOLEAN .
  data GV_TAGDATA type BOOLEAN .
  data GV_TAGMETADATA type BOOLEAN .
  data GV_BOTHNAMES type BOOLEAN .
  data GT_WHERE type ZONTTRSDSWHERE .
  data GT_ENDPOINTS type TTY_ENDPOINTS .
  data:
    gs_endpoints      LIKE LINE OF gt_endpoints .
  data GT_WHERE_COND_TAB type RSDS_TWHERE .
  data GT_COND_TAB type RSDS_TWHERE .
  data:
    gt_fieldtab TYPE STANDARD TABLE OF rsdsfields .
  data:
    gt_par_field TYPE STANDARD TABLE OF rsdsfields .
  data GV_KORRNUM type E070-TRKORR .
  data GV_DEVCLASS type TADIR-DEVCLASS .
  data GV_ALIASTAB type ZONTA_OC_COL_ALL-ALIAS_TABNAME .
  data:
    gt_ddic TYPE STANDARD TABLE OF zonta_oc_ddic .
  data GV_BACK_2_PROCESS type BOOLEAN .
  data GX_TEXT type ref to CX_ROOT .
  data GV_RESPONSE type STRING .
  data GV_VARIANT type VARIANT .
  data GT_FIELD_RANGES type RSDS_TRANGE .
  data GV_TM type ABAP_BOOL .
  data GV_ERROR type BOOLEAN .
  data GV_SEND_IMMEDIATELY type BOOLEAN .

*********


    TYPES: BEGIN OF ty_log_json_result,
             sizet          TYPE zonde_oc_num30,
             recordst TYPE zonde_oc_num30,
             recordst_obj  TYPE zonde_oc_num30,
             tables                   LIKE ltt_table_log,
           END OF ty_log_json_result.
*********

  data GS_LOG_JSON_RESULT type TY_LOG_JSON_RESULT .
private section.

  types:
    tty_json_map  TYPE STANDARD TABLE OF dd03p .
  types:
*********************
  "--- Tipos auxiliares para condiciones dinámicas -------------------
    BEGIN OF ty_rsds_where,
        tablename TYPE rsdstabs-prim_tab,
        where_tab TYPE zonttrsdswhere,
      END OF ty_rsds_where .
  types:
    ty_rsds_twhere TYPE STANDARD TABLE OF ty_rsds_where WITH DEFAULT KEY .
  types:
    ty_t_relations TYPE STANDARD TABLE OF zonta_relations WITH DEFAULT KEY .

  data:
  "--- Lista de claves propagadas (por ejemplo VBELN) ----------------
    mt_root_keys TYPE STANDARD TABLE OF string WITH DEFAULT KEY .
  data:
    mt_filter_tabnames TYPE STANDARD TABLE OF tabname .
  data GV_PROG type SYREPID .
  data GV_SLINE type I .
  data GV_MSG1 type STRING .
  data GV_MSG2 type STRING .
  data GV_MSG3 type STRING .
  data GV_MSG4 type STRING .
  data GV_MSG5 type STRING .
  data GV_SEND_IMMEDIATELY_JSON type BOOLEAN .

  methods SET_LOG_JSON_RESULT
    importing
      !IV_TABNAME type TABNAME
      !IV_SIZE type I .
  methods REPLACE_DATA_METADATA
    importing
      !IV_TABNAME type ZONTA_OC_COL_ALL-TABNAME
      !IV_ALIAS_TABNAME type ZONTA_OC_COL_ALL-ALIAS_TABNAME
      !IV_TECHNICAL type ZONTA_OC_COL_ALL-FLDNAME
      !IV_ALIAS_FLDNAME type ZONTA_OC_COL_ALL-ALIAS_FLDNAME
      !IV_OPTION type STRING
    changing
      !CV_JSON type STRING .
  methods REPLACE_DATA_BODY
    importing
      !IV_TABNAME type ZONTA_OC_COL_ALL-TABNAME
      !IV_ALIAS_TABNAME type ZONTA_OC_COL_ALL-ALIAS_TABNAME
      !IV_TECHNICAL type ZONTA_OC_COL_ALL-FLDNAME
      !IV_ALIAS_FLDNAME type ZONTA_OC_COL_ALL-ALIAS_FLDNAME
    changing
      !CV_JSON type STRING .
  methods PRINT_ERROR .
  methods CHECK_JSON_SIZE
    importing
      !IV_SIZE type ZONDE_OC_NUM30
    returning
      value(R_GOOD_TO_SEND) type BOOLEAN .
  methods GET_READ_TEXT_LONGTEXT
    importing
      !IV_TABNAME type TABNAME
    changing
      !ISC_TABLE type ANY .
  methods SORT_RELATIONS
    changing
      !CHT_RELATIONS type TTY_RELATIONS .
  methods VALIDATE_WHERE_3_TABLES
    returning
      value(R_MESSAGE) type STRING .
  methods VALIDATE_DATA_WHERE
    changing
      !CH_TABLE type ref to DATA optional .
  methods BUILD_ROOT_FILTERS
    exporting
      !ET_RETURN type SUBRC
    changing
      !CT_FILTERS type RSDS_TWHERE .
  methods CREATE_DESTINATION
    importing
      !IV_DESTINATION type RFCDEST
      !IV_SECONDARY type BOOLEAN
    exporting
      !EV_SUBRC type SY-SUBRC
      value(RO_HTTP_CLIENT) type ref to IF_HTTP_CLIENT .
*    preferred parameter IV_XMSG
  methods SEND_MSG_TO_HTTP
    importing
      !IV_XMSG type XSTRING optional
      !IV_MSG type STRING optional
      !IO_HTTP_CLIENT type ref to IF_HTTP_CLIENT
    exporting
      !EV_RES type CHAR01
      !EV_RETURN type STRING
      !EV_SIZE type ZONDE_OC_NUM30
      !EV_RECORDS type ZONDE_OC_NUM30
      !EV_RESPONSE type STRING .
  methods DO_SELECT
    importing
      !IV_TABNAME type TABNAME
      !IV_PARENT_REL type ANY
      !IV_IS_CDS_ENTITY type BOOLEAN_FLG
      !IV_FIELDS type STRING
      !IT_FIELDS type ANY TABLE
      !IV_WHERE type ZONTTRSDSWHERE
      !IT_PR type ANY TABLE
    changing
      !CT_FINAL type ANY TABLE
      !CT_FAE_BACK type ANY TABLE
      !CT_FAE type ANY TABLE
      !CT_RESULT type ANY TABLE .
  methods SEND_HTTP_WITH_FAILOVER
    importing
      !IV_PRIMARY_DEST type RFCDEST
      !IV_PAYLOAD type XSTRING
    exporting
      !EV_RESPONSE type STRING
      !EV_HTTP_CODE type I
      !EV_USED_DEST type RFCDEST
      !EV_COMM_ERROR type BOOLEAN_FLG
      !EV_ERROR_MESSAGE type STRING
      !EV_HTTP_REASON type STRING .
  methods SEND_RECEIVE_HTTP
    importing
      !IO_CLIENT type ref to IF_HTTP_CLIENT
      !IV_PAYLOAD type XSTRING
    exporting
      !EV_HTTP_CODE type I
      !EV_HTTP_REASON type STRING
      !EV_RESPONSE type STRING
      !EV_COMM_ERROR type BOOLEAN_FLG
      !EV_ERROR_TEXT type STRING .
  methods GET_FIELDS_PARAMETRIZED_CDS
    importing
      !IV_TABNAME type TABNAME .
ENDCLASS.



CLASS ZONCL_OC_BASE_HANDLER IMPLEMENTATION.


  METHOD add_position_table.

    DATA: lt_dfies_tab TYPE STANDARD TABLE OF dfies,
          ls_dfies     TYPE dfies,
          lv_tabname   TYPE ddobjname.

    FIELD-SYMBOLS: <fs_columns> TYPE zonta_oc_col_all.

    lv_tabname = iv_tabname.

    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname        = lv_tabname
      TABLES
        dfies_tab      = lt_dfies_tab
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.

    SORT lt_dfies_tab BY position    .

    LOOP AT gt_columns_all ASSIGNING <fs_columns>
         WHERE tabname = iv_tabname.

      READ TABLE lt_dfies_tab INTO ls_dfies
           WITH KEY tabname = iv_tabname
                    fieldname = <fs_columns>-fldname
           BINARY SEARCH.

      IF sy-subrc = 0.
        <fs_columns>-positionf = ls_dfies-position.
      ENDIF.

    ENDLOOP.


  ENDMETHOD.


  METHOD adjust_context_from_callstack.

    DATA: it_abap_callstack TYPE abap_callstack,
          ws_abap_callstack TYPE abap_callstack_line,
          it_syst_callstack TYPE sys_callst.

    CALL FUNCTION 'SYSTEM_CALLSTACK'
      EXPORTING
        max_level    = 20
      IMPORTING
        callstack    = it_abap_callstack
        et_callstack = it_syst_callstack.

    READ TABLE it_abap_callstack INTO ws_abap_callstack
      WITH KEY mainprogram = 'ZONPG_ONECONNECT_CUST_EXE'
               include     = 'ZONPG_ONECONNECT_CUST_EXE_F01'
               blockname   = 'GENERATE_STRUCTURES'.

    IF sy-subrc = 0.
      CLEAR gv_alias.
      gv_fieldname = abap_true.
    ELSE.
      IF gv_fieldname IS NOT INITIAL.
        CLEAR gv_alias.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD alias_both_json.

    CONSTANTS: c_guion TYPE c VALUE '_'.

    TYPES: BEGIN OF ty_match,
             table_pos  TYPE i,
             table_name TYPE string,
             json       TYPE string,
           END OF ty_match.

    TYPES: BEGIN OF st_table,
             tabname       TYPE tabname,
             alias_tabname TYPE zonde_aliastab,
             both          TYPE string,
           END OF st_table.

    DATA: lt_tables     TYPE STANDARD TABLE OF ty_match ,"WITH EMPTY KEY,
          lt_tables_tmp TYPE STANDARD TABLE OF ty_match ,"WITH EMPTY KEY,
          ls_tables     LIKE LINE OF lt_tables,
          ls_next       LIKE LINE OF lt_tables.

    DATA: lv_table_name TYPE string,
          lv_offset     TYPE i,
          lv_tabix      TYPE sy-tabix,
          lv_json       TYPE string.

    DATA: lv_source TYPE string,
          lv_target TYPE string.

    DATA: lv_search_pos TYPE i VALUE 0.
    DATA: lv_fieldname TYPE string,
          lv_alias     TYPE zonta_oc_col_all-alias_tabname,
          lv_name      TYPE zonta_oc_col_all-tabname.

    DATA: lv_index         TYPE sy-tabix,
          lv_last_position TYPE i,
          lv_range_slice   TYPE string,
          lv_cursor        TYPE i VALUE 0,
          lv_subjson       TYPE string,
          lv_difference    TYPE i.

    DATA: lv_match TYPE string,
          ls_match TYPE ty_match.

    DATA: lt_match      TYPE match_result_tab,
          ls_match_line TYPE match_result,
          lv_length     TYPE i.



    DATA: lt_col_all     TYPE STANDARD TABLE OF zonta_oc_col_all,
          ls_col_all     LIKE LINE OF lt_col_all,
          lt_table_names TYPE STANDARD TABLE OF st_table.

    FIELD-SYMBOLS: <fs_tabn>    TYPE st_table,
                   <fs_columns> TYPE zonta_oc_col_all,
                   <fs_table>   TYPE ty_match.

    lv_json = cv_json.
    CLEAR lt_tables[].

    SORT gt_columns_all BY tabname alias_tabname fldname alias_fldname.
    WHILE lv_cursor < strlen( lv_json ).
      lv_subjson = lv_json+lv_cursor.

      CLEAR lt_match.
      FIND REGEX '"table":"([^"]+)"' IN lv_subjson RESULTS lt_match.

      IF sy-subrc = 0 AND lines( lt_match ) > 0.
        READ TABLE lt_match INDEX 1 INTO ls_match_line.
        IF sy-subrc = 0 AND lines( ls_match_line-submatches ) > 0.

*          lv_offset = ls_match_line-submatches[ 1 ]-offset.
*          lv_length = ls_match_line-submatches[ 1 ]-length.
          DATA: ls_submatch LIKE LINE OF ls_match_line-submatches.

          READ TABLE ls_match_line-submatches INTO ls_submatch INDEX 1.
          IF sy-subrc = 0.
            lv_offset = ls_submatch-offset.
            lv_length = ls_submatch-length.
          ELSE.
            lv_offset = 0.
            lv_length = 0.
          ENDIF.

          lv_table_name = lv_subjson+lv_offset(lv_length).

          ls_match-table_name = lv_table_name.
          ls_match-table_pos  = lv_cursor + ls_match_line-offset.
          APPEND ls_match TO lt_tables.

          " Move cursor forward to continue parsing
          lv_cursor = lv_cursor + ls_match_line-offset + 1.
        ELSE.
          EXIT.
        ENDIF.
      ELSE.
        EXIT.
      ENDIF.
    ENDWHILE.

    IF gv_bothnames = abap_true.
      lt_col_all[] = gt_columns_all[].
      SORT lt_col_all BY tabname alias_tabname.
      DELETE ADJACENT DUPLICATES FROM lt_col_all COMPARING tabname alias_tabname.

      LOOP AT lt_col_all INTO ls_col_all.
        APPEND INITIAL LINE TO lt_table_names ASSIGNING <fs_tabn>.
        MOVE-CORRESPONDING ls_col_all TO <fs_tabn> .
        <fs_tabn>-both = |{ ls_col_all-tabname }{ c_guion }{ ls_col_all-alias_tabname }|.
      ENDLOOP.
    ENDIF.

    SORT lt_table_names BY both.
    SORT gt_converted BY tabname fldname.
* TABLE
    IF gv_sending = c_table.

      SORT lt_tables BY table_name.
      DELETE ADJACENT DUPLICATES FROM lt_tables COMPARING table_name.
      LOOP AT lt_tables INTO ls_tables.
        IF gv_bothnames = abap_true.
          READ TABLE lt_table_names ASSIGNING <fs_tabn> WITH KEY both = ls_tables-table_name BINARY SEARCH.
          IF sy-subrc = 0.
            ls_tables-table_name = <fs_tabn>-alias_tabname.
          ENDIF.
        ENDIF.

        READ TABLE gt_columns_all ASSIGNING <fs_columns> WITH KEY alias_tabname = ls_tables-table_name.
        IF sy-subrc = 0.
          lv_alias = <fs_columns>-alias_tabname.
          lv_name  = <fs_columns>-tabname.
        ELSE.
          READ TABLE gt_columns_all ASSIGNING <fs_columns> WITH KEY tabname = ls_tables-table_name.
          IF sy-subrc = 0.
            CLEAR lv_alias.
            lv_name = <fs_columns>-tabname.
          ENDIF.
        ENDIF.
        LOOP AT gt_columns_all ASSIGNING <fs_columns> WHERE tabname = lv_name
                                                AND alias_tabname = lv_alias. "ls_tables-table_name.

          CALL METHOD me->replace_data_metadata
            EXPORTING
              iv_tabname       = lv_name
              iv_alias_tabname = lv_alias
              iv_technical     = <fs_columns>-fldname
              iv_alias_fldname = <fs_columns>-alias_fldname
              iv_option        = iv_option
            CHANGING
              cv_json          = cv_json.


        ENDLOOP.
      ENDLOOP.


    ELSEIF gv_sending = c_kdoc.

* KDOC
      SORT lt_tables BY table_pos.
      lv_search_pos = 0.
      lv_index = 1.

      LOOP AT lt_tables ASSIGNING <fs_table>.
        lv_tabix = sy-tabix + 1.
        lv_difference = <fs_table>-table_pos - lv_search_pos.
        <fs_table>-json = cv_json+lv_search_pos(lv_difference).
        lv_search_pos = <fs_table>-table_pos.
      ENDLOOP.



      APPEND INITIAL LINE TO lt_tables ASSIGNING <fs_table>.
      lv_difference = strlen( cv_json ) -  lv_search_pos.
      <fs_table>-table_pos = strlen( cv_json ).
      <fs_table>-json = cv_json+lv_search_pos(lv_difference).

      lt_tables_tmp[] = lt_tables[].
      LOOP AT lt_tables ASSIGNING <fs_table> FROM 2.
        lv_index = sy-tabix - 1.
        READ TABLE lt_tables_tmp INTO ls_next INDEX lv_index.
        IF sy-subrc = 0.
          <fs_table>-table_name = ls_next-table_name.
        ENDIF.
      ENDLOOP.

      DATA: lv_tabname TYPE zonde_aliastab.
      CLEAR lv_tabname.
      LOOP AT lt_tables ASSIGNING <fs_table>.
        lv_index = sy-tabix.
        clear lv_alias.
        clear lv_name.


        READ TABLE gt_columns_all ASSIGNING <fs_columns> WITH KEY alias_tabname = <fs_table>-table_name.
        IF sy-subrc = 0.
          lv_alias = <fs_columns>-alias_tabname.
          lv_name  = <fs_columns>-tabname.
        ELSE.
          READ TABLE gt_columns_all ASSIGNING <fs_columns> WITH KEY tabname = <fs_table>-table_name.
          IF sy-subrc = 0.
*            CLEAR lv_alias.   "DB Delete Feb2026
            lv_alias = <fs_columns>-alias_tabname.
            lv_name = <fs_columns>-tabname.
          ENDIF.
        ENDIF.
        IF lv_name IS INITIAL AND lv_alias IS INITIAL.
          SPLIT <fs_table>-table_name AT '_' INTO lv_name lv_alias.
        ENDIF.

        LOOP AT gt_columns_all ASSIGNING <fs_columns> WHERE tabname = lv_name
                                                        AND alias_tabname = lv_alias. "ls_tables-table_name.

*          IF <FS_Columns>-fldname = 'LOEKZ'.
*            BREAK-POINT.
*          endif.

          CALL METHOD me->replace_data_metadata
            EXPORTING
              iv_tabname       = lv_name
              iv_alias_tabname = lv_alias
              iv_technical     = <fs_columns>-fldname
              iv_alias_fldname = <fs_columns>-alias_fldname
              iv_option        = iv_option
            CHANGING
              cv_json          = <fs_table>-json.


        ENDLOOP.
        IF lv_index = 1.
          lv_json = <fs_table>-json.
        ELSE.
          lv_json = lv_json && <fs_table>-json.
        ENDIF.
        lv_tabname = <fs_table>-table_name.
      ENDLOOP.
      cv_json = lv_json.
    ENDIF.


  ENDMETHOD.


  METHOD alias_json.


    TYPES: BEGIN OF ty_match,
             table_pos  TYPE i,
             table_name TYPE string,
             json       TYPE string,
           END OF ty_match.

    DATA: lt_tables TYPE STANDARD TABLE OF ty_match ,"WITH EMPTY KEY,
          ls_tables LIKE LINE OF lt_tables.

    DATA: lv_table_name TYPE string,
          lv_offset     TYPE i,
          lv_json       TYPE string.

    DATA: lv_source TYPE string,
          lv_target TYPE string.

    DATA: lv_search_pos TYPE i VALUE 0.
    DATA: lv_fieldname TYPE string.

    DATA: lv_index         TYPE sy-tabix,
          lv_last_position TYPE i,
          lv_range_slice   TYPE string,
          lv_cursor        TYPE i VALUE 0,
          lv_subjson       TYPE string,
          lv_difference    TYPE i.

    DATA: lv_match TYPE string,
          ls_match TYPE ty_match.

    DATA: lt_match      TYPE match_result_tab,
          ls_match_line TYPE match_result,
          lv_length     TYPE i.


    FIELD-SYMBOLS: <fs_columns> TYPE zonta_oc_col_all,
                   <fs_table>   TYPE ty_match.

    lv_json = cv_json.
    CLEAR lt_tables[].

    WHILE lv_cursor < strlen( lv_json ).
      lv_subjson = lv_json+lv_cursor.

      CLEAR lt_match.
      FIND REGEX '"table":"([^"]+)"' IN lv_subjson RESULTS lt_match.

      IF sy-subrc = 0 AND lines( lt_match ) > 0.
        READ TABLE lt_match INDEX 1 INTO ls_match_line.
        IF sy-subrc = 0 AND lines( ls_match_line-submatches ) > 0.

*          lv_offset = ls_match_line-submatches[ 1 ]-offset.
*          lv_length = ls_match_line-submatches[ 1 ]-length.
          DATA ls_submatch LIKE LINE OF ls_match_line-submatches.

          READ TABLE ls_match_line-submatches INTO ls_submatch INDEX 1.
          IF sy-subrc = 0.
            lv_offset = ls_submatch-offset.
            lv_length = ls_submatch-length.
          ELSE.
            lv_offset = 0.
            lv_length = 0.
          ENDIF.


          lv_table_name = lv_subjson+lv_offset(lv_length).

          ls_match-table_name = lv_table_name.
          ls_match-table_pos  = lv_cursor + ls_match_line-offset.
          APPEND ls_match TO lt_tables.

          " Move cursor forward to continue parsing
          lv_cursor = lv_cursor + ls_match_line-offset + 1.
        ELSE.
          EXIT.
        ENDIF.
      ELSE.
        EXIT.
      ENDIF.
    ENDWHILE.

* TABLE
    IF gv_sending = c_table.

      SORT lt_tables BY table_name.
      DELETE ADJACENT DUPLICATES FROM lt_tables COMPARING table_name.
      LOOP AT lt_tables INTO ls_tables.
        LOOP AT gt_columns_all ASSIGNING <fs_columns> WHERE alias_tabname = ls_tables-table_name.
          TRANSLATE <fs_columns>-fldname TO LOWER CASE.
          TRANSLATE <fs_columns>-alias_fldname TO LOWER CASE.

          lv_source = '"' && <fs_columns>-fldname && '"'.  ":'.
          lv_target = '"' && <fs_columns>-alias_fldname       && '"'.  ":'.

          REPLACE ALL OCCURRENCES OF '\'   IN lv_target WITH '_'.
          REPLACE ALL OCCURRENCES OF '/'   IN lv_target WITH '_'.

          REPLACE ALL OCCURRENCES OF lv_source IN cv_json WITH lv_target.

        ENDLOOP.
      ENDLOOP.


    ELSEIF gv_sending = c_kdoc.

* KDOC
      SORT lt_tables BY table_pos.
      lv_search_pos = 0.
      LOOP AT lt_tables ASSIGNING <fs_table>.
        lv_difference = <fs_table>-table_pos - lv_search_pos.
        <fs_table>-json = cv_json+lv_search_pos(lv_difference).
        lv_search_pos = <fs_table>-table_pos.
      ENDLOOP.
      APPEND INITIAL LINE TO lt_tables ASSIGNING <fs_table>.
      lv_difference = strlen( cv_json ) -  lv_search_pos.
      <fs_table>-table_pos = strlen( cv_json ).
      <fs_table>-json = cv_json+lv_search_pos(lv_difference).

      DATA: lv_tabname TYPE zonde_aliastab.
      CLEAR lv_tabname.
      LOOP AT lt_tables ASSIGNING <fs_table>.
        lv_index = sy-tabix.


        LOOP AT gt_columns_all ASSIGNING <fs_columns> WHERE alias_tabname = lv_tabname.
          TRANSLATE <fs_columns>-fldname TO LOWER CASE.
          TRANSLATE <fs_columns>-alias_fldname TO LOWER CASE.

          lv_source = '"' && <fs_columns>-fldname && '"'. ":'.
          lv_target = '"' && <fs_columns>-alias_fldname       && '"'.  ":'.

          REPLACE ALL OCCURRENCES OF '\'   IN lv_target WITH '_'.
          REPLACE ALL OCCURRENCES OF '/'   IN lv_target WITH '_'.

          REPLACE ALL OCCURRENCES OF lv_source IN <fs_table>-json WITH lv_target.

        ENDLOOP.
        IF lv_index = 1.
          lv_json = <fs_table>-json.
        ELSE.
          lv_json = lv_json && <fs_table>-json.
        ENDIF.
        lv_tabname = <fs_table>-table_name.
      ENDLOOP.
      cv_json = lv_json.
    ENDIF.


  ENDMETHOD.


  METHOD append_slg1_log.

    FIELD-SYMBOLS: <fs_log_ext> TYPE zonst_oc_log_ext.


    DATA v_tryoff TYPE c.
    SELECT SINGLE low INTO v_tryoff FROM zonta_oc_param WHERE name = 'SET_TRY_OFF'.
    IF v_tryoff IS NOT INITIAL.
      APPEND INITIAL LINE TO gt_log_ext ASSIGNING <fs_log_ext>.

      <fs_log_ext>-process    = gv_entity.
      <fs_log_ext>-cdobjcl    = gs_oc_obj-cdobjectcl.
      <fs_log_ext>-mestyp     = gs_oc_obj-kschl.
      <fs_log_ext>-tabname    = iv_tabname.
      <fs_log_ext>-type       = iv_mestyp.
      <fs_log_ext>-id         = 'FB'.
      <fs_log_ext>-number     = '000'.
      <fs_log_ext>-message_v1 = iv_message_v1.
      <fs_log_ext>-message_v3 = iv_message_v3.

      IF <fs_log_ext>-tabname IS INITIAL.
        CLEAR <fs_log_ext>-endpoint.
        CLEAR <fs_log_ext>-json_id.
      ELSE.
        <fs_log_ext>-endpoint   = gv_dest.
        <fs_log_ext>-json_id    = gv_jsonid.
      ENDIF.

      IF iv_key IS NOT INITIAL.
        <fs_log_ext>-key        = iv_key.
        <fs_log_ext>-message_v2 = iv_key.
      ELSE.
        <fs_log_ext>-message_v2 = iv_message_v2.
      ENDIF.

      CONCATENATE
        <fs_log_ext>-message_v1
        <fs_log_ext>-message_v2
        <fs_log_ext>-message_v3
        INTO <fs_log_ext>-message
        SEPARATED BY space.

    ELSE.

      TRY. "FR
          APPEND INITIAL LINE TO gt_log_ext ASSIGNING <fs_log_ext>.

          <fs_log_ext>-process    = gv_entity.
          <fs_log_ext>-cdobjcl    = gs_oc_obj-cdobjectcl.
          <fs_log_ext>-mestyp     = gs_oc_obj-kschl.
          <fs_log_ext>-tabname    = iv_tabname.
          <fs_log_ext>-type       = iv_mestyp.
          <fs_log_ext>-id         = 'FB'.
          <fs_log_ext>-number     = '000'.
          <fs_log_ext>-message_v1 = iv_message_v1.
          <fs_log_ext>-message_v3 = iv_message_v3.
          IF <fs_log_ext>-tabname IS INITIAL.
            CLEAR <fs_log_ext>-endpoint.
            CLEAR <fs_log_ext>-json_id.
          ELSE.
            <fs_log_ext>-endpoint   = gv_dest.
            <fs_log_ext>-json_id    = gv_jsonid.
          ENDIF.

          IF iv_key IS NOT INITIAL.
            <fs_log_ext>-key        = iv_key.
            <fs_log_ext>-message_v2 = iv_key.
          ELSE.
            <fs_log_ext>-message_v2 = iv_message_v2.
          ENDIF.

          CONCATENATE
            <fs_log_ext>-message_v1
            <fs_log_ext>-message_v2
            <fs_log_ext>-message_v3
            INTO <fs_log_ext>-message
            SEPARATED BY space.

        CATCH cx_root INTO gx_text.
          gs_elog-type       = 'APPEND_LOG'.
          gs_elog-severity   = gc_error.
          gs_elog-message    = gx_text->get_longtext( ).
          CALL METHOD gx_text->get_source_position
            IMPORTING
              program_name = gv_prog
              source_line  = gv_sline.
          gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
          gs_elog-details-db = 'ZONCL_OC_BASE_HANDLER-APPEND_SLG1_LOG'.
          gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

          gs_elog-metadata-error_code = gs_elog-details-error_code.
          interpret_message( EXPORTING iv_msgnr = '051' IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
          interpret_message( EXPORTING iv_msgnr = '052' iv_msgv1 = iv_message_v1 iv_msgv2 = iv_message_v3 IMPORTING ev_message = gv_msg2  CHANGING ct_table = gt_causes ).
          CONCATENATE gv_msg1 gv_msg2 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
          interpret_message( EXPORTING iv_msgnr = '053' IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
          interpret_message( EXPORTING iv_msgnr = '054' IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_fixes ).
          interpret_message( EXPORTING iv_msgnr = '055' IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_fixes ).
          CONCATENATE gv_msg1 gv_msg2 gv_msg3 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.

          print_error_otel( ).
          send_json_error( ).
          " Swallow error silently to prevent logging interruption
      ENDTRY.
    ENDIF.
  ENDMETHOD.


  METHOD assign_component_table.

    DATA: lv_source    TYPE string,
          lv_target    TYPE string,
          ls_converted LIKE LINE OF gt_converted.

    FIELD-SYMBOLS: <fs_columns> TYPE zonta_oc_col_all,
                   <fs_source>  TYPE any,
                   <fs_target>  TYPE any.

    LOOP AT it_columns ASSIGNING <fs_columns>.

      IF iv_alias = abap_true AND NOT <fs_columns>-alias_fldname IS INITIAL.
        lv_source = <fs_columns>-alias_fldname.
      ELSE.
        lv_source = <fs_columns>-fldname.
      ENDIF.

      lv_target = lv_source.

      lv_source = lv_source && is_relations-sequence.

      TRANSLATE lv_source TO UPPER CASE.
      TRANSLATE lv_target TO UPPER CASE.

      ASSIGN COMPONENT lv_source OF STRUCTURE is_source TO <fs_source>.
      IF sy-subrc NE 0.
*        IF iv_alias ne abap_true.
          READ TABLE gt_converted INTO ls_converted WITH KEY tabname = <fs_columns>-tabname
                                                             alias_tabname = <fs_columns>-alias_tabname
                                                             fldname  = <fs_columns>-fldname.
          IF sy-subrc = 0.
            lv_source = ls_converted-fldname1.
            lv_source = lv_source && is_relations-sequence.
            TRANSLATE lv_source TO UPPER CASE.
            ASSIGN COMPONENT lv_source OF STRUCTURE is_source TO <fs_source>.  "*CONVERSION
          ENDIF.
*        else.
*          READ TABLE gt_converted INTO ls_converted WITH KEY tabname = <fs_columns>-tabname
*                                                             alias_tabname = <fs_columns>-alias_tabname
*                                                             alias_fldname  = <fs_columns>-alias_fldname.
*          IF sy-subrc = 0.
*            lv_source = ls_converted-alias_fldname1.
*            lv_source = lv_source && is_relations-sequence.
*            TRANSLATE lv_source TO UPPER CASE.
*            ASSIGN COMPONENT lv_source OF STRUCTURE is_source TO <fs_source>.  "*CONVERSION
*          ENDIF.
*        ENDIF.
      ENDIF.

      ASSIGN COMPONENT lv_target OF STRUCTURE cs_target TO <fs_target>.
      IF sy-subrc NE 0.
*        IF iv_alias ne abap_true.
          READ TABLE gt_converted INTO ls_converted WITH KEY tabname = <fs_columns>-tabname
                                                             alias_tabname = <fs_columns>-alias_tabname
                                                             fldname  = <fs_columns>-fldname.
          IF sy-subrc = 0.
            lv_target = ls_converted-fldname1.
            TRANSLATE lv_target TO UPPER CASE.
            ASSIGN COMPONENT lv_target OF STRUCTURE cs_target TO <fs_target>.  "*CONVERSION
          ENDIF.
*        ELSE.
*          READ TABLE gt_converted INTO ls_converted WITH KEY tabname = <fs_columns>-tabname
*                                                             alias_tabname = <fs_columns>-alias_tabname
*                                                             alias_fldname  = <fs_columns>-alias_fldname.
*          IF sy-subrc = 0.
*            lv_target = ls_converted-alias_fldname1.
*            TRANSLATE lv_target TO UPPER CASE.
*            ASSIGN COMPONENT lv_target OF STRUCTURE cs_target TO <fs_target>.  "*CONVERSION
*          ENDIF.
*        ENDIF.
      ENDIF.

      IF <fs_source> IS ASSIGNED AND <fs_target> IS ASSIGNED.
        <fs_target> = <fs_source>.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD assign_component_table_kdoc.

    DATA: lv_source    TYPE string,
          lv_target    TYPE string,
          ls_converted LIKE LINE OF gt_converted.

    FIELD-SYMBOLS: <fs_columns> TYPE zonta_oc_col_all,
                   <fs_source>  TYPE any,
                   <fs_target>  TYPE any.

    LOOP AT it_columns ASSIGNING <fs_columns>.

      IF iv_alias = abap_true AND NOT <fs_columns>-alias_fldname IS INITIAL.
        READ TABLE gt_converted INTO ls_converted WITH KEY tabname = <fs_columns>-tabname
                                                           alias_tabname = <fs_columns>-alias_tabname
                                                           alias_fldname  = <fs_columns>-alias_fldname.
        if sy-subrc = 0.
          lv_source = ls_converted-alias_fldname1.
        else.
          lv_source = <fs_columns>-alias_fldname.
        endif.
      ELSE.
        lv_source = <fs_columns>-fldname.
      ENDIF.

      lv_target = <fs_columns>-fldname.

      lv_source = lv_source && is_relations-sequence.

      TRANSLATE lv_source TO UPPER CASE.
      TRANSLATE lv_target TO UPPER CASE.

      ASSIGN COMPONENT lv_source OF STRUCTURE is_source TO <fs_source>.
      IF sy-subrc NE 0.
        READ TABLE gt_converted INTO ls_converted WITH KEY tabname = <fs_columns>-tabname
                                                           alias_tabname = <fs_columns>-alias_tabname
                                                           fldname  = <fs_columns>-fldname.
        IF sy-subrc = 0.
          lv_source = ls_converted-fldname1.
          lv_source = lv_source && is_relations-sequence.
          TRANSLATE lv_source TO UPPER CASE.
          ASSIGN COMPONENT lv_source OF STRUCTURE is_source TO <fs_source>.  "*CONVERSION
        ENDIF.
      ENDIF.
      ASSIGN COMPONENT lv_target OF STRUCTURE cs_target TO <fs_target>.
      IF sy-subrc NE 0.
        READ TABLE gt_converted INTO ls_converted WITH KEY tabname = <fs_columns>-tabname
                                                           alias_tabname = <fs_columns>-alias_tabname
                                                           fldname  = <fs_columns>-fldname.
        IF sy-subrc = 0.
          lv_target = ls_converted-fldname1.
          TRANSLATE lv_target TO UPPER CASE.
          ASSIGN COMPONENT lv_target OF STRUCTURE cs_target TO <fs_target>.  "*CONVERSION
        ENDIF.
      ENDIF.

      IF <fs_source> IS ASSIGNED AND <fs_target> IS ASSIGNED.
        <fs_target> = <fs_source>.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.


  METHOD bothnames_json.

    DATA: lv_source TYPE string,
          lv_target TYPE string.

    FIELD-SYMBOLS: <fs_columns> TYPE zonta_oc_col_all.

    LOOP AT gt_columns_all ASSIGNING <fs_columns>.
      TRANSLATE <fs_columns>-fldname TO LOWER CASE.
      TRANSLATE <fs_columns>-alias_fldname TO LOWER CASE.

      lv_source = '"' && <fs_columns>-fldname && '":'.
      lv_target = '"' && <fs_columns>-fldname && '_' && <fs_columns>-alias_fldname  && '":'.

      REPLACE ALL OCCURRENCES OF '\'   IN lv_target WITH '_'.
      REPLACE ALL OCCURRENCES OF '/'   IN lv_target WITH '_'.

      REPLACE ALL OCCURRENCES OF lv_source IN cv_json WITH lv_target.

    ENDLOOP.
  ENDMETHOD.


METHOD build_root_filters.

  CONSTANTS: c_symb TYPE c VALUE '~'.

  TYPES: BEGIN OF st_tables,
           tabname     TYPE tabname,
           sequence    TYPE zonta_relations-sequence,
           fieldname   TYPE fieldname,
           subsequence TYPE zonta_relations-subsequence,
           line        TYPE string,
         END OF st_tables.

  DATA: lt_tables     TYPE STANDARD TABLE OF st_tables,
        ls_tables     TYPE st_tables,
        ls_rel        TYPE zonta_relations,
        ls_root       TYPE zonta_relations,
        lv_where_join TYPE string,
        lv_where_filt TYPE string,
        lv_where      TYPE string,
        lv_where_aux  TYPE string,
        lv_tabroot    TYPE tabname,
        lv_keyroot    TYPE fieldname,
        lv_line       TYPE string,
        lv_found      TYPE boolean_flg,
        lv_text       TYPE string,
        lv_text1      TYPE string,
        lv_text2      TYPE string,
        lv_text3      TYPE string.


  DATA: lt_val   TYPE STANDARD TABLE OF string,
        ls_val   TYPE string,
        lv_field TYPE string,
        lv_final TYPE string.

  DATA: lt_tabs         TYPE STANDARD TABLE OF zonta_relations,
        ls_tab          TYPE zonta_relations,
        lt_col          TYPE TABLE OF zonta_oc_col_all,
        ls_col          TYPE zonta_oc_col_all,
        lt_filters      TYPE rsds_twhere,
        ls_filter       TYPE rsdswhere,
        lv_from         TYPE string,
        lv_fields       TYPE string,
        lv_join         TYPE string,
        lv_sql          TYPE string,
        lv_alias        TYPE string,
        lv_parent_alias TYPE string,
        lv_main_seq     TYPE zonta_relations-sequence,
        lv_seq          TYPE zonta_relations-sequence.


  DATA lv_value  TYPE string.
  DATA lo_table  TYPE REF TO data.
  DATA: lv_f1           TYPE string,
        lv_f2           TYPE string,
        lv_target_field TYPE string,
        lv_tblant       TYPE tabname,
        ls_w            TYPE rsdswhere.

  FIELD-SYMBOLS: <fs_table>  TYPE ANY TABLE,
                 <fs_row>    TYPE any,
                 <fs_col>    TYPE any,
                 <fs_val>    TYPE any,
                 <fs_filt>   TYPE rsds_where,
                 <fs_wheret> TYPE rsdswhere.

**********************************************************************
  DATA ls_filter_pre TYPE zonta_oc_filters.
  FIELD-SYMBOLS: <fs_filter> TYPE rsds_where.

  LOOP AT gt_filters INTO ls_filter_pre.
    READ TABLE ct_filters ASSIGNING <fs_filter> WITH KEY tablename = ls_filter_pre-tabname.
    IF sy-subrc NE 0.
      APPEND INITIAL LINE TO ct_filters ASSIGNING <fs_filter>.
      <fs_filter>-tablename = ls_filter_pre-tabname.
    ENDIF.
    REPLACE '~' INTO ls_filter_pre-where_clause WITH ''.
    CONDENSE ls_filter_pre-tabname.
    REPLACE ls_filter_pre-tabname IN ls_filter_pre-where_clause WITH ''.
    IF <fs_filter>-where_tab IS NOT INITIAL.
*        APPEND 'AND ' TO <fs_filter>-where_tab.
      IF ls_filter_pre-where_clause CP '*AND*'.
        APPEND ls_filter_pre-where_clause  TO <fs_filter>-where_tab.
      ELSE.
        APPEND |AND { ls_filter_pre-where_clause }| TO <fs_filter>-where_tab.
      ENDIF.
    ELSE.
      APPEND ls_filter_pre-where_clause  TO <fs_filter>-where_tab.
    ENDIF.

  ENDLOOP.

  CLEAR gt_filters.

**********************************************************************

* LT_TABLES will contain the data of the filters
  LOOP AT ct_filters ASSIGNING <fs_filt>.
    LOOP AT <fs_filt>-where_tab INTO ls_w.
      CLEAR ls_tables.

      ls_tables-tabname = <fs_filt>-tablename.
      ls_tables-line    = ls_w-line.

      FIND REGEX '\b(?!AND\b|OR\b|NOT\b)([A-Z0-9_]+)\b'
           IN ls_w-line SUBMATCHES ls_tables-fieldname.

      READ TABLE gt_relations INTO ls_rel
           WITH KEY tabname   = ls_tables-tabname
                    field_main = ls_tables-fieldname.

      IF sy-subrc = 0.
        ls_tables-sequence    = ls_rel-sequence.
        ls_tables-subsequence = ls_rel-subsequence.
      ELSE.
        READ TABLE gt_relations INTO ls_rel
             WITH KEY tabname = ls_tables-tabname.
        ls_tables-sequence    = ls_rel-sequence.
        ls_tables-subsequence = ls_rel-subsequence.
      ENDIF.

      APPEND ls_tables TO lt_tables.
    ENDLOOP.
  ENDLOOP.

  lv_found = abap_false.
  IF lt_tables IS INITIAL.
    RETURN.
  ELSE.
    LOOP AT  lt_tables INTO ls_tables WHERE sequence NE 1.
      lv_found = abap_true.
    ENDLOOP.
  ENDIF.

  IF lv_found = abap_false.
    RETURN.
  ENDIF.

  SORT lt_tables BY sequence subsequence.

* Get the main field and table
  lt_tabs = gt_relations.
  SORT lt_tabs BY sequence.

  READ TABLE lt_tabs INTO ls_tab WITH KEY sequence = 1.
  IF sy-subrc = 0.
    lv_main_seq = ls_tab-sequence.
  ELSE.
    RETURN.
  ENDIF.

  lv_tabroot = ls_tab-tabname.
  lv_keyroot = ls_tab-field_main.

* Do the Dynamic form
  CLEAR lv_from.

  LOOP AT lt_tabs INTO ls_tab WHERE sequence <= 3.
    lv_alias = |A{ ls_tab-sequence }|.

    IF ls_tab-sequence = 1.
      lv_from = |{ ls_tab-tabname } AS { lv_alias }|.
    ELSE.
      lv_seq = ls_tab-sequence - 1.
      lv_parent_alias = |A{ lv_seq }|.

      CASE ls_tab-join_type.
        WHEN 'INNER'.       lv_join = 'INNER JOIN'.
        WHEN 'LEFT OUTER'.  lv_join = 'LEFT OUTER JOIN'.
        WHEN OTHERS.        lv_join = 'LEFT OUTER JOIN'.
      ENDCASE.

      CONCATENATE lv_parent_alias c_symb ls_tab-field_main INTO lv_f1.
      CONCATENATE lv_alias c_symb ls_tab-field_sec INTO lv_f2.
      IF lv_tblant NE ls_tab-tabname.
        CONCATENATE
          lv_from
          lv_join
          ls_tab-tabname
          'AS'
          lv_alias
          'ON'
          lv_f1
          '='
          lv_f2
          INTO lv_from
          SEPARATED BY space.
      ELSE.
        CONCATENATE
          lv_from
          'AND'
          lv_f1
          '='
          lv_f2
          INTO lv_from
          SEPARATED BY space.
      ENDIF.
      lv_tblant = ls_tab-tabname.
    ENDIF.
  ENDLOOP.

* Build Dynamic WHERE
  CLEAR lv_where.

  LOOP AT ct_filters ASSIGNING <fs_filt>.

    CLEAR lv_where_aux.

    "1) Obtener secuencia según tabla
    lv_seq = 0.
    LOOP AT lt_tabs INTO ls_tab WHERE tabname = <fs_filt>-tablename.
      lv_seq = ls_tab-sequence.
      EXIT.
    ENDLOOP.

    IF lv_seq = 0.
      CONTINUE.
    ENDIF.

    lv_alias = |A{ ls_tab-sequence }|.

    LOOP AT <fs_filt>-where_tab INTO ls_w.

      lv_line = ls_w-line.

*      REPLACE ALL OCCURRENCES OF |{ <fs_filt>-tablename }~| IN lv_line WITH ''.
*
*      REPLACE REGEX '^\s*AND\s+' IN lv_line WITH ''.
*      REPLACE REGEX '^\s*OR\s+'  IN lv_line WITH ''.
*      REPLACE REGEX '(\(?\s*)([A-Z0-9_]+)(\s+)'
*             IN lv_line WITH |$1{ lv_alias }~$2$3|.
*      REPLACE REGEX '(BETWEEN\s+)([A-Z0-9_]+)'
*             IN lv_line WITH |$1{ lv_alias }~$2|.
*      REPLACE REGEX '(\s+AND\s+)([A-Z0-9_]+)'
*             IN lv_line WITH |$1{ lv_alias }~$2|.
*      REPLACE REGEX '(\s+OR\s+)([A-Z0-9_]+)'
*             IN lv_line WITH |$1{ lv_alias }~$2|.
*      REPLACE REGEX '(\s+IN\s*\(\s*)([A-Z0-9_]+)'
*             IN lv_line WITH |$1{ lv_alias }~$2|.

*      IF lv_where IS INITIAL.
      if lv_where_aux  IS INITIAL.
*        lv_where = lv_line.
         lv_where_aux = lv_line.
      ELSE.
*         CONCATENATE lv_where 'AND' lv_line INTO lv_where SEPARATED BY space.
        CONCATENATE lv_where_aux lv_line INTO lv_where_aux SEPARATED BY space.
      ENDIF.

    ENDLOOP.

    REPLACE ALL OCCURRENCES OF REGEX
'\b(?!AND\b|OR\b|NOT\b|IN\b|EQ\b|NE\b|LT\b|GT\b|LE\b|GE\b|BT\b|BETWEEN\b|CP\b|NP\b|IS\b|NULL\b)([A-Z][A-Z0-9_]*)\b(?=\s*(EQ|NE|LT|GT|LE|GE|BT|BETWEEN|CP|NP|IN)\b|\s+BETWEEN\b)'
IN lv_where_aux
WITH |{ lv_alias }~$1|.

    IF lv_where IS NOT INITIAL.
      CONCATENATE lv_where ' AND ' INTO lv_where SEPARATED BY space.
    ENDIF.

    CONCATENATE lv_where lv_where_aux  INTO lv_where SEPARATED BY space.

  ENDLOOP.

* Do the big select
  lt_col = gt_columns_all[].
  SORT lt_col BY tabname fldname.
  CONCATENATE 'A' lv_main_seq c_symb lv_keyroot INTO lv_f1.

  IF gv_alias = abap_true.
    READ TABLE lt_col INTO ls_col WITH KEY tabname = lv_tabroot
                                                 fldname = lv_keyroot BINARY SEARCH.
    CONCATENATE ls_col-alias_fldname lv_main_seq  INTO lv_f2.
    TRANSLATE lv_f2 TO UPPER CASE.
  ELSE.
    CONCATENATE lv_keyroot lv_main_seq  INTO lv_f2.
  ENDIF.


  lv_target_field = lv_f2.
  CONCATENATE lv_f1 'AS' lv_f2 INTO lv_fields SEPARATED BY space.

  lo_table  = me->set_table( iv_add_tabname = abap_true ).
  ASSIGN lo_table->* TO <fs_table>.


  DATA v_tryoff TYPE c.
  SELECT SINGLE low INTO v_tryoff FROM zonta_oc_param WHERE name = 'SET_TRY_OFF'.
  IF v_tryoff IS NOT INITIAL.

    SELECT DISTINCT (lv_fields)
      INTO CORRESPONDING FIELDS OF TABLE @<fs_table>
      FROM (lv_from)
      WHERE (lv_where)   .

    IF sy-subrc <> 0.
      et_return = 4.
      RETURN.
    ELSE.
      et_return = 0.
    ENDIF.
  ELSE.
    TRY.
        SELECT DISTINCT (lv_fields)
         INTO CORRESPONDING FIELDS OF TABLE @<fs_table>
         FROM (lv_from)
         WHERE (lv_where)   .

        IF sy-subrc <> 0.
          et_return = 4.
          RETURN.
        ELSE.
          et_return = 0.
        ENDIF.

*      CATCH cx_sy_dynamic_osql_semantics INTO DATA(lo_ref1).
        DATA lo_ref1 TYPE REF TO cx_sy_dynamic_osql_semantics.
      CATCH cx_sy_dynamic_osql_semantics INTO lo_ref1.
        gs_elog-type       = 'SELECT_FILTERS'.
        gs_elog-severity   = gc_error.
        gs_elog-message    = lo_ref1->get_longtext( ).
        CALL METHOD lo_ref1->get_source_position
          IMPORTING
            program_name = gv_prog
            source_line  = gv_sline.
        gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
        gs_elog-details-db = 'ZONCL_OC_BASE_HANDLER-BUILD_ROOT_FILTERS'.
        gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

        gs_elog-metadata-error_code = gs_elog-details-error_code.
        interpret_message( EXPORTING iv_msgnr = '073'  IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
        interpret_message( EXPORTING iv_msgnr = '071'  IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
        interpret_message( EXPORTING iv_msgnr = '072'  iv_msgv1 = lv_from IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
        interpret_message( EXPORTING iv_msgnr = '068'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
        CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
        interpret_message( EXPORTING iv_msgnr = '076' iv_msgv1 = lv_from IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
        interpret_message( EXPORTING iv_msgnr = '065' iv_msgv1 = gv_entity IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_fixes ).
        interpret_message( EXPORTING iv_msgnr = '070' IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_fixes ).
        CONCATENATE gv_msg1 gv_msg2 gv_msg3 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.
        print_error_otel( ).

        send_json_error( ).

        lv_text = lo_ref1->get_text( ).
        lv_text1 = lv_text+0(50).
        lv_text2 = lv_text+50(50).
        lv_text3 = lv_text+100.
        MESSAGE e000(fb) WITH 'Error on Select for filters' lv_text1 lv_text2 lv_text3.
        me->append_slg1_log(
          EXPORTING
            iv_tabname    = space
            iv_message_v1 = 'Error on Select for filters'
            iv_message_v2 = space
            iv_message_v3 = space
            iv_mestyp     = 'E' ).

        me->update_slg1_log( it_log_ext = gt_log_ext ).

        RETURN.
    ENDTRY.
  ENDIF.

* Add entry in GT_COND_TABLE

  LOOP AT <fs_table> ASSIGNING <fs_row>.

    ASSIGN COMPONENT lv_target_field OF STRUCTURE <fs_row> TO <fs_val>.
    IF sy-subrc = 0 AND <fs_val> IS NOT INITIAL.
      lv_f1 = |'{ <fs_val> }'|.
      IF sy-tabix = 1.
        CONCATENATE '(' lv_keyroot 'EQ' lv_f1 ')' INTO lv_f2 SEPARATED BY space.
      ELSE.
        CONCATENATE 'OR (' lv_keyroot 'EQ'  lv_f1 ')' INTO lv_f2 SEPARATED BY space.
      ENDIF.
      APPEND lv_f2 TO lt_val.
    ENDIF.

  ENDLOOP.

  IF lt_val IS NOT  INITIAL.
    APPEND INITIAL LINE TO ct_filters ASSIGNING <fs_filt>.
    <fs_filt>-tablename = lv_tabroot.

    LOOP AT lt_val INTO ls_val.
      APPEND INITIAL LINE TO <fs_filt>-where_tab ASSIGNING <fs_wheret>.
      <fs_wheret>-line = ls_val.
    ENDLOOP.
  ENDIF.


* Validate if there is another table that needs to be filtered

  DELETE lt_tables WHERE fieldname = lv_keyroot.
  DELETE lt_tables WHERE tabname = lv_tabroot.
  LOOP AT lt_tables INTO ls_tables.
    LOOP AT lt_col INTO ls_col WHERE tabname NE ls_tables-tabname AND fldname = ls_tables-fieldname.
      READ TABLE gt_relations INTO ls_rel WITH KEY tabname         = ls_col-tabname
                                                   parent_relation = ls_tables-tabname
                                                   field_sec       = ls_col-fldname.
      IF sy-subrc = 0.
        APPEND INITIAL LINE TO ct_filters ASSIGNING <fs_filt>.
        <fs_filt>-tablename =  ls_col-tabname.
        APPEND INITIAL LINE TO <fs_filt>-where_tab ASSIGNING <fs_wheret>.
        SPLIT ls_tables-line AT '(' INTO lv_f1 lv_f2.
        CONCATENATE '(' lv_f2 INTO lv_f2 SEPARATED BY space.
        <fs_wheret>-line = lv_f2.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

ENDMETHOD.


  METHOD call_base_get_data.
    " Just delegate to the base get_data implementation
    me->get_data(
      IMPORTING
        ev_sizet    = ev_sizet
        ev_recordst = ev_recordst
    ).
  ENDMETHOD.


  METHOD check_entity_consistency.

    TYPES: BEGIN OF st_structures,
             tabname  TYPE dd02l-tabname,
             as4local TYPE dd02l-as4local,
           END OF st_structures.

    DATA: lt_table    TYPE STANDARD TABLE OF st_structures,
          ls_ddic     LIKE LINE OF gt_ddic,
          ls_table    LIKE LINE OF lt_table,
          lv_noactive TYPE boolean_flg,
          lv_missing  TYPE boolean_flg.

    DATA: it_abap_callstack TYPE abap_callstack,
          ws_abap_callstack TYPE abap_callstack_line,
          it_syst_callstack TYPE sys_callst.

    CLEAR lv_noactive.
    CLEAR lv_missing.

    CALL FUNCTION 'SYSTEM_CALLSTACK'
      EXPORTING
        max_level    = 20
      IMPORTING
        callstack    = it_abap_callstack
        et_callstack = it_syst_callstack.

    READ TABLE it_abap_callstack INTO ws_abap_callstack
      WITH KEY blocktype   = 'FORM'
               blockname   = 'EXECUTE_PROCESS'.

    IF sy-subrc = 0.

      SELECT *
        INTO TABLE gt_ddic
        FROM zonta_oc_ddic
        WHERE domainv = gv_domainv
          AND business_proc = gv_entity.

      IF lines( gt_ddic ) > 0.
        SELECT tabname as4local
          INTO TABLE lt_table
          FROM dd02l
          FOR ALL ENTRIES IN gt_ddic
          WHERE tabname = gt_ddic-object.
        SELECT typename AS tabname as4local
          APPENDING TABLE lt_table
          FROM dd40l
          FOR ALL ENTRIES IN gt_ddic
          WHERE typename = gt_ddic-object.
        SORT lt_table BY tabname.
        LOOP AT gt_ddic INTO ls_ddic.
          READ TABLE lt_table INTO ls_table WITH KEY tabname = ls_ddic-object.
          IF sy-subrc = 0.
            IF ls_table-as4local NE 'A'.
              lv_noactive = abap_true.
              EXIT.
            ENDIF.
          ELSE.
            lv_missing = abap_true.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.

      IF lv_noactive = abap_true.
        gs_elog-type       = 'NO_ACTIVE_STRUCTURE'.
        gs_elog-severity   = gc_error.
        gs_elog-message    = |Not all tables/structures from Entity are Active.|.
        gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
        gs_elog-details-db = 'ZONCL_OC_BASE_HANDLER-CHECK_ENTITY_CONSISTENCY'.
        gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

        gs_elog-metadata-error_code = gs_elog-details-error_code.
        interpret_message( EXPORTING iv_msgnr = '110' IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
        gs_elog-metadata-possible_cause = gv_msg1.
        interpret_message( EXPORTING iv_msgnr = '107' IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
        gs_elog-metadata-possible_fix = gv_msg1.

        print_error_otel( ).
        send_json_error( ).

        MESSAGE e112(zon_cl_oc) WITH gv_entity.
      ENDIF.

      IF lv_missing = abap_true.
        gs_elog-type       = 'MISSING_STRUCTURE'.
        gs_elog-severity   = gc_error.
        gs_elog-message    = |Not all tables/structures from Entity were created.|.
        gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
        gs_elog-details-db = 'ZONCL_OC_BASE_HANDLER-CHECK_ENTITY_CONSISTENCY'.
        gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

        gs_elog-metadata-error_code = gs_elog-details-error_code.
        interpret_message( EXPORTING iv_msgnr = '111' IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
        gs_elog-metadata-possible_cause = gv_msg1.
        interpret_message( EXPORTING iv_msgnr = '107' IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
        gs_elog-metadata-possible_fix = gv_msg1.

        print_error_otel( ).
        send_json_error( ).
        MESSAGE e112(zon_cl_oc) WITH gv_entity.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD check_json_size.
    DATA: lv_size  TYPE zonta_oc_param-low,
          lv_sizev TYPE zonde_oc_num30.
    SELECT SINGLE low
      INTO lv_size
      FROM zonta_oc_param
      WHERE name = 'MAX_JSON_SIZE'.

    IF sy-subrc = 0.
      lv_sizev = lv_size.
      IF lv_sizev > iv_size.
        r_good_to_send = abap_true.
      ELSE.
        r_good_to_send = abap_false.
      ENDIF.
    ELSE.
      r_good_to_send = abap_true.
    ENDIF.

  ENDMETHOD.


  METHOD clear_globals.

    CLEAR:gv_kdoc,
        gv_table,
        gv_ddic,
        gv_dest,
        gv_update,
        gv_delete,
        gv_domainv,
        gv_entity,
        gv_key_queue,
        gv_batch,
        gt_where,
        gv_instid,
        gv_anytable,
        gv_alias,
        gv_fieldname,
        gv_tagdata,
        gv_tagmetadata,
        gv_bothnames,
        gt_endpoints,
        gt_where_cond_tab[].
  ENDMETHOD.


  METHOD conversion_exit.

    CONSTANTS: c_point TYPE c VALUE '.'.

    DATA: lt_dfies_tab TYPE STANDARD TABLE OF dfies,
          ls_columns   TYPE zonta_oc_col_all,
          lv_function  TYPE rs38l_fnam,
          lv_valuec    TYPE c LENGTH 10,
          lv_result    TYPE string,
          lv_len       TYPE i,
          lv_lenc      TYPE i.

    FIELD-SYMBOLS: <fs_field>  TYPE any,
                   <fs_value>  TYPE any,
                   <fs_valuec> TYPE char10,
                   <fs_dfies>  TYPE dfies.
***
    lt_dfies_tab = gt_dfies_tab.
***
    DELETE lt_dfies_tab WHERE tabname NE iv_tabname.
***    DELETE lt_dfies_tab WHERE convexit IS INITIAL.
***

    LOOP AT lt_dfies_tab ASSIGNING <fs_dfies>.
      READ TABLE gt_columns_all WITH KEY tabname = iv_tabname
                                     fldname = <fs_dfies>-fieldname
                                     INTO ls_columns.

      IF sy-subrc = 0.
        IF gv_fieldname IS INITIAL.
          IF NOT ls_columns-alias_fldname IS INITIAL.
            ASSIGN ls_columns-alias_fldname TO <fs_field>.
          ELSE.
            ASSIGN ls_columns-fldname TO <fs_field>.
          ENDIF.
        ELSE.
          ASSIGN ls_columns-fldname TO <fs_field>.
        ENDIF.
      ELSE.
        ASSIGN <fs_dfies>-fieldname TO <fs_field>.
      ENDIF.

      TRANSLATE <fs_field> TO UPPER CASE.

      ASSIGN COMPONENT <fs_field> OF STRUCTURE cs_string TO <fs_value>.
**** Commented to remove ceros on Entities.
****      IF <fs_value> IS NOT ASSIGNED.
****        ASSIGN <fs_dfies>-fieldname TO <fs_field>.
****        TRANSLATE <fs_field> TO UPPER CASE.
****        ASSIGN COMPONENT <fs_field> OF STRUCTURE cs_string TO <fs_value>.
****      ENDIF.
***
***      IF <fs_value> IS ASSIGNED.
***        IF <fs_dfies>-leng > <fs_dfies>-outputlen.
***          lv_function = |CONVERSION_EXIT_{ <fs_dfies>-convexit }_OUTPUT|.
***          CALL FUNCTION lv_function
***            EXPORTING
***              input  = <fs_value>
***            IMPORTING
***              output = lv_result. "<fs_value>.
***          <fs_value> = lv_result.
***        ENDIF.
***        UNASSIGN <fs_value>.
***      ENDIF.

      IF <fs_value> IS ASSIGNED.
        IF <fs_dfies>-domname EQ 'DATUM_INV'.
          lv_function = |CONVERSION_EXIT_{ <fs_dfies>-convexit }_OUTPUT|.
          CALL FUNCTION lv_function
            EXPORTING
              input  = <fs_value>
            IMPORTING
* Begin of change DB FIX GDATU
              output = lv_valuec.
          DESCRIBE FIELD lv_valuec LENGTH lv_lenc  IN CHARACTER MODE.
          DESCRIBE FIELD <fs_value> LENGTH lv_len IN CHARACTER MODE.
          IF lv_lenc > lv_len.
            REPLACE ALL OCCURRENCES OF c_point IN lv_valuec WITH space.
            CONDENSE lv_valuec.
            <fs_value> = lv_valuec.
          ENDIF.
* End of change DB FIX GDATU
        ENDIF.
        UNASSIGN <fs_value>.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

**  METHOD conversion_exit.
**
**
**
*****    DATA: lt_dfies_tab TYPE STANDARD TABLE OF dfies,
*****          ls_columns   TYPE zonta_oc_col_all,
*****          lv_function  TYPE rs38l_fnam,
*****          lv_result    TYPE string.
*****
*****    FIELD-SYMBOLS: <fs_field> TYPE any,
*****                   <fs_value> TYPE any,
*****                   <fs_dfies> TYPE dfies.
*****
*****    lt_dfies_tab = gt_dfies_tab.
*****
*****    DELETE lt_dfies_tab WHERE tabname NE iv_tabname.
*****    DELETE lt_dfies_tab WHERE convexit IS INITIAL.
*****
*****    LOOP AT lt_dfies_tab ASSIGNING <fs_dfies>.
*****
*****      READ TABLE gt_columns_all WITH KEY tabname = iv_tabname
*****                                     fldname = <fs_dfies>-fieldname
*****                                     INTO ls_columns.
*****
*****      IF sy-subrc = 0.
*****        IF gv_fieldname IS INITIAL.
*****          IF NOT ls_columns-alias_fldname IS INITIAL.
*****            ASSIGN ls_columns-alias_fldname TO <fs_field>.
*****          ELSE.
*****            ASSIGN ls_columns-fldname TO <fs_field>.
*****          ENDIF.
*****        ELSE.
*****          ASSIGN ls_columns-fldname TO <fs_field>.
*****        ENDIF.
*****      ELSE.
*****        ASSIGN <fs_dfies>-fieldname TO <fs_field>.
*****      ENDIF.
*****
*****      TRANSLATE <fs_field> TO UPPER CASE.
*****
*****      ASSIGN COMPONENT <fs_field> OF STRUCTURE cs_string TO <fs_value>.
****** Commented to remove ceros on Entities.
******      IF <fs_value> IS NOT ASSIGNED.
******        ASSIGN <fs_dfies>-fieldname TO <fs_field>.
******        TRANSLATE <fs_field> TO UPPER CASE.
******        ASSIGN COMPONENT <fs_field> OF STRUCTURE cs_string TO <fs_value>.
******      ENDIF.
*****
*****      IF <fs_value> IS ASSIGNED.
*****        IF <fs_dfies>-leng > <fs_dfies>-outputlen.
*****          lv_function = |CONVERSION_EXIT_{ <fs_dfies>-convexit }_OUTPUT|.
*****          CALL FUNCTION lv_function
*****            EXPORTING
*****              input  = <fs_value>
*****            IMPORTING
*****              output = lv_result. "<fs_value>.
*****          <fs_value> = lv_result.
*****        ENDIF.
*****        UNASSIGN <fs_value>.
*****      ENDIF.
*****
*****    ENDLOOP.
**
**  ENDMETHOD.


  METHOD copy_context_from.

    " Copy global context attributes
    me->gv_kdoc           = io_source->gv_kdoc.
    me->gv_table          = io_source->gv_table.
    me->gv_ddic           = io_source->gv_ddic.
    me->gv_dest           = io_source->gv_dest.
    me->gv_update         = io_source->gv_update.
    me->gv_delete         = io_source->gv_delete.
    me->gv_domainv        = io_source->gv_domainv.
    me->gv_entity         = io_source->gv_entity.
    me->gv_key_queue      = io_source->gv_key_queue.
    me->gv_batch          = io_source->gv_batch.
    me->gt_where          = io_source->gt_where.
    me->gv_instid         = io_source->gv_instid.
    me->gv_anytable       = io_source->gv_anytable.
    me->gv_alias          = io_source->gv_alias.
    me->gv_uuid           = io_source->gv_uuid.
    me->gv_fieldname      = io_source->gv_fieldname.
    me->gv_tagdata        = io_source->gv_tagdata.
    me->gv_tagmetadata    = io_source->gv_tagmetadata.
    me->gv_bothnames      = io_source->gv_bothnames.
    me->gt_cond_tab       = io_source->gt_cond_tab.
    me->gt_where_cond_tab = io_source->gt_where_cond_tab.
    me->gt_relations      = io_source->gt_relations.
    me->gt_cdpos          = io_source->gt_cdpos.
    me->gt_columns_all    = io_source->gt_columns_all.
    me->gt_dfies_tab_cat  = io_source->gt_dfies_tab_cat.
    me->gs_oc_obj         = io_source->gs_oc_obj.
    me->gv_sending        = io_source->gv_sending.
    me->gt_filters        = io_source->gt_filters[].
    me->gv_variant        = io_source->gv_variant.
    me->gv_tm             = io_source->gv_tm.
    me->gt_ranges_where   = io_source->gt_ranges_where.
    me->gv_back_2_process = io_source->gv_back_2_process.

  ENDMETHOD.


  METHOD create_destination.

    DATA: lv_message TYPE string,
          ls_rfcdest TYPE rfcdes.

    ev_subrc = 0.

    SELECT SINGLE *
      INTO ls_rfcdest
      FROM rfcdes
      WHERE rfcdest = iv_destination
        AND rfctype = 'G'.
    IF sy-subrc NE 0.

      lv_message = |Endpoint: { iv_destination }| && |does not exist in SM59|.
      me->append_slg1_log(
       EXPORTING
        iv_tabname    = space
        iv_message_v1 = lv_message
        iv_message_v2 = space
        iv_message_v3 = space
        iv_mestyp     = 'E' ).

      IF iv_secondary = abap_true.
        gs_elog-type       = 'CREATE_DESTINATION'.
        gs_elog-severity   = gc_error.
        gs_elog-message    = lv_message.

        gs_elog-details-query = lv_message.
        gs_elog-details-db = 'ENDPOINT_DOES_NOT_EXIST'.
        gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

        gs_elog-metadata-error_code = gs_elog-details-error_code.
        send_json_error( ).

        MESSAGE e113(zon_cl_oc) WITH iv_destination.
      ENDIF.

      ev_subrc = sy-subrc.
      EXIT.
    ENDIF.

    CALL METHOD cl_http_client=>create_by_destination
      EXPORTING
        destination              = iv_destination
      IMPORTING
        client                   = ro_http_client
      EXCEPTIONS
        destination_not_found    = 1
        internal_error           = 2
        argument_not_found       = 3
        destination_no_authority = 4
        plugin_not_active        = 5
        OTHERS                   = 6.
    IF sy-subrc = 0.
      ev_subrc = sy-subrc.
    ELSE.
      ev_subrc = sy-subrc.
      ro_http_client->get_last_error( IMPORTING   message = lv_message ).
      me->append_slg1_log(
        EXPORTING
         iv_tabname    = space
*           iv_key        =
         iv_message_v1 = lv_message
         iv_message_v2 = space
         iv_message_v3 = space
         iv_mestyp     = 'E' ).

      gs_elog-type       = 'SENDING_PRIMARY_ENDPOINT'.
      gs_elog-severity   = gc_error.
      gs_elog-message    = lv_message.

      gs_elog-details-query = |Error while sending to  { iv_destination } |.
      gs_elog-details-db = 'CREATE_DESTINATION'.
      gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

      gs_elog-metadata-error_code = gs_elog-details-error_code.
      send_json_error( ).

    ENDIF.
  ENDMETHOD.


  METHOD display_where_with_variant.


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
    DATA: ls_whereret     TYPE zonttrsdswhere.
    DATA: lv_message_error TYPE string.


    DATA: lt_dfies_tab  TYPE TABLE OF dfies,
          lt_all_fields TYPE TABLE OF dfies,
          ls_dfies_tab  TYPE  dfies.

    DATA: rl_fldname   TYPE RANGE OF fieldname.
    DATA: lt_relations TYPE STANDARD TABLE OF zonta_relations,
          ls_relations TYPE zonta_relations,
          lt_columns   TYPE STANDARD TABLE OF zonta_oc_col_all.

    DATA: lt_columns_tmp TYPE STANDARD TABLE OF zonta_oc_col_all,
          ls_all_fields  LIKE LINE OF lt_all_fields,
          ls_variant     TYPE zonta_oc_variant.

    FIELD-SYMBOLS: <fs_table_tab>      LIKE LINE OF table_tab,
                   <fs_relations>      LIKE LINE OF lt_relations,
                   <fs_field_tab_excl> LIKE LINE OF field_tab_excl,
                   <fs_cond_tab>       LIKE LINE OF cond_tab,
                   <fs_filters>        LIKE LINE OF lt_filters.

    DATA: ls_field_tab    LIKE LINE OF field_tab,
          ls_where        LIKE LINE OF <fs_cond_tab>-where_tab,
          ls_field_r      LIKE LINE OF field_ranges,
          ls_range_d      TYPE rsds_frange,
          ls_selopt       TYPE rsdsselopt,
          ls_ranges_where LIKE LINE OF gt_ranges_where.

    DATA: lwr_fldname    TYPE selopt,
          ls_columns_tmp LIKE LINE OF lt_columns_tmp.

    FIELD-SYMBOLS: <fs_ranges> LIKE LINE OF lt_ranges.

    SELECT * INTO TABLE lt_ranges
      FROM zonta_oc_franges
      WHERE domainv       = gv_domainv
        AND business_proc = gv_entity
        AND variant       = gv_variant.
    IF sy-subrc NE 0.
      LOOP AT gt_ranges_where INTO ls_ranges_where.
        APPEND INITIAL LINE TO lt_ranges ASSIGNING <fs_ranges>.
        MOVE-CORRESPONDING ls_ranges_where TO <fs_ranges>.
        <fs_ranges>-fldname = ls_ranges_where-selname.
        <fs_ranges>-opti = ls_ranges_where-option.
        <fs_ranges>-business_proc = gv_entity.
        <fs_ranges>-domainv = gv_domainv.
        <fs_ranges>-variant = gv_variant.
      ENDLOOP.
    ENDIF.

    CLEAR lt_rsds_selopt_t[].
    CLEAR lt_frange_t[].
    CLEAR ls_rsds_range.
    CLEAR lt_ranges_ini[].


    REFRESH gt_fieldtab.
    REFRESH gt_cond_tab.

    lt_relations[] = gt_relations[].
*    lt_columns[]   = it_columns[].

    lv_nochanges = abap_false.


    DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING sequence.

    SORT lt_columns BY fldname tabname.

    CLEAR lt_all_fields[].

    IF lines( lt_ranges ) > 0.
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

      IF lines( lt_ranges ) > 0.
        SORT lt_ranges BY tabname fldname.
        READ TABLE lt_ranges INTO ls_ranges INDEX 1.
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

        LOOP AT lt_ranges INTO ls_ranges.
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
* Dynamic values
    ELSE.
    ENDIF.

    IF lines( field_tab_ini ) > 0.
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
*         fields_not_selected   = field_tab_excl
        EXCEPTIONS
          OTHERS                = 4.
      IF sy-subrc <> 0.
        MESSAGE 'Error in initialization' TYPE 'I' DISPLAY LIKE 'E'.
        lv_nochanges = abap_true.
        LEAVE PROGRAM.
      ENDIF.

*    IF gv_domainv IS INITIAL
*    OR gv_entity IS INITIAL.
*      READ TABLE gt_relations INTO ls_relations INDEX 1.
*      gv_domainv = ls_relations-domainv.
*      gv_business_proc = ls_relations-business_proc.
*    ENDIF.

      CONCATENATE 'Entity'
                 gv_domainv
                 ' - '
                 gv_entity
                 INTO  lv_title
                 SEPARATED BY space.


      CALL FUNCTION 'FREE_SELECTIONS_DIALOG'
        EXPORTING
          selection_id  = selid
          title         = lv_title
          as_window     = abap_false
        IMPORTING
          where_clauses = gt_cond_tab
          field_ranges  = gt_field_ranges
        TABLES
          fields_tab    = gt_fieldtab
        EXCEPTIONS
          OTHERS        = 4.
      IF sy-subrc <> 0.
        MESSAGE 'No changes were saved' TYPE 'I'.
        lv_nochanges = abap_true.
*      LEAVE PROGRAM.
      ENDIF.


*BEGIN CHEL 10/0172025
      IF gt_cond_tab[] IS NOT INITIAL.
        lv_message_error = validate_where_3_tables( ).
        IF lv_message_error IS NOT INITIAL.
          MESSAGE lv_message_error TYPE 'E'.
        ENDIF.
      ENDIF.
*END CHEL 10/01/2025

      IF gv_entity NE 'ANY' AND lv_nochanges = abap_false.   "DB Fixvariant
*     Call new screen to save variants
        me->set_variant( ).
        IF gv_variant IS NOT INITIAL.
          CALL METHOD me->get_variant_values
            EXPORTING
              iv_variant = gv_variant
              iv_domainv = gv_domainv
              iv_entity  = gv_entity
            IMPORTING
              et_where   = gt_cond_tab[]
              et_ranges_where = gt_ranges_where[].
        ENDIF.
      ENDIF.
    ELSE.
      MESSAGE e045(zon_cl_oc) WITH gv_variant.
      CLEAR gv_variant.
    ENDIF.
    r_where = ls_whereret.
*    ELSE.
*      MESSAGE i046(zon_cl_oc) WITH gv_variant DISPLAY LIKE 'E'.
*      gv_error = abap_true.
*    ENDIF.


  ENDMETHOD.


  METHOD download_log_file.

    CONSTANTS: c_tab  TYPE c LENGTH 1 VALUE cl_abap_char_utilities=>horizontal_tab.
    TYPES: BEGIN OF ty_log,
*             include   TYPE zonst_oc_log_ext,
             process    TYPE  zonde_process,
             cdobjcl    TYPE  cdobjectcl,
             mestyp     TYPE  edi_mestyp,
             tabname    TYPE  tabname,
             key        TYPE  zonde_oc_key,
             type       TYPE  bapi_mtype,
             id         TYPE  symsgid,
             number     TYPE  symsgno,
             message    TYPE  bapi_msg,
             message_v1 TYPE  symsgv,
             message_v2 TYPE  symsgv,
             message_v3 TYPE  symsgv,
             endpoint   TYPE  rfcdest,
             timestamp  TYPE c LENGTH 27,
           END OF ty_log.

    DATA: lv_path TYPE string,
          lv_tsl  TYPE timestampl,
          lt_log  TYPE STANDARD TABLE OF ty_log,
          lv_line TYPE string.

    FIELD-SYMBOLS: <fs_log_ext> TYPE zonst_oc_log_ext,
                   <fs_log>     TYPE ty_log.

    CLEAR: lt_log[].
    " Generate timestamp and output file path
    GET TIME STAMP FIELD lv_tsl.

    lv_path = gs_oc_obj-file_path &&
              '/' &&
              gs_oc_obj-business_proc &&
              '.txt'.
    DATA v_tryoff TYPE c.
    SELECT SINGLE low INTO v_tryoff FROM zonta_oc_param WHERE name = 'SET_TRY_OFF'.
    IF v_tryoff IS NOT INITIAL.
      OPEN DATASET lv_path FOR APPENDING IN TEXT MODE ENCODING DEFAULT.
      IF sy-subrc NE 0.
        OPEN DATASET lv_path FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
      ENDIF.
      LOOP AT gt_log_ext ASSIGNING <fs_log_ext>.
        APPEND INITIAL LINE TO lt_log ASSIGNING <fs_log>.
        MOVE-CORRESPONDING <fs_log_ext> TO <fs_log>.
        <fs_log>-timestamp = lv_tsl.
      ENDLOOP.

      LOOP AT lt_log ASSIGNING <fs_log>.
        CLEAR lv_line.
        CONCATENATE
          <fs_log>-process
          <fs_log>-cdobjcl
          <fs_log>-mestyp
          <fs_log>-tabname
          <fs_log>-key
          <fs_log>-type
          <fs_log>-id
          <fs_log>-number
          <fs_log>-message
          <fs_log>-message_v1
          <fs_log>-message_v2
          <fs_log>-message_v3
          <fs_log>-endpoint
          <fs_log>-timestamp
        INTO lv_line SEPARATED BY c_tab.
        TRANSFER lv_line TO lv_path.
*        TRANSFER <fs_log> TO lv_path.
      ENDLOOP.

      CLOSE DATASET lv_path.

      IF sy-subrc = 0.
        MESSAGE s000(fb) WITH TEXT-e09 lv_path.
      ENDIF.
    ELSE.

      TRY.
          OPEN DATASET lv_path FOR APPENDING IN TEXT MODE ENCODING DEFAULT.
          IF sy-subrc NE 0.
            OPEN DATASET lv_path FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
          ENDIF.
          LOOP AT gt_log_ext ASSIGNING <fs_log_ext>.
            APPEND INITIAL LINE TO lt_log ASSIGNING <fs_log>.
            MOVE-CORRESPONDING <fs_log_ext> TO <fs_log>.
            <fs_log>-timestamp = lv_tsl.
          ENDLOOP.

          LOOP AT lt_log ASSIGNING <fs_log>.
            CLEAR lv_line.
            CONCATENATE
              <fs_log>-process
              <fs_log>-cdobjcl
              <fs_log>-mestyp
              <fs_log>-tabname
              <fs_log>-key
              <fs_log>-type
              <fs_log>-id
              <fs_log>-number
              <fs_log>-message
              <fs_log>-message_v1
              <fs_log>-message_v2
              <fs_log>-message_v3
              <fs_log>-endpoint
              <fs_log>-timestamp
            INTO lv_line SEPARATED BY c_tab.
            TRANSFER lv_line TO lv_path.
*            TRANSFER <fs_log> TO lv_path.
          ENDLOOP.

          CLOSE DATASET lv_path.

          IF sy-subrc = 0.
            MESSAGE s000(fb) WITH TEXT-e09 lv_path.
          ENDIF.

        DATA lx_file TYPE REF TO cx_sy_file_open_mode.
        CATCH cx_sy_file_open_mode INTO lx_file.
          gs_elog-type       = 'OPEN_DATASET'.
          gs_elog-severity   = gc_error.
          gs_elog-message    = lx_file->get_longtext( ).
          CALL METHOD lx_file->get_source_position
            IMPORTING
              program_name = gv_prog
              source_line  = gv_sline.
          gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
          gs_elog-details-db = 'ZONCL_OC_BASE_HANDLER-DOWNLOAD_LOG_FILE'.
          gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

          gs_elog-metadata-error_code = gs_elog-details-error_code.
          interpret_message( EXPORTING iv_msgnr = '077'  IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
          interpret_message( EXPORTING iv_msgnr = '078' iv_msgv1 = lv_path IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
          interpret_message( EXPORTING iv_msgnr = '079'  IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
          interpret_message( EXPORTING iv_msgnr = '080'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
          CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
          interpret_message( EXPORTING iv_msgnr = '081'  IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
          interpret_message( EXPORTING iv_msgnr = '082'  IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_fixes ).
          interpret_message( EXPORTING iv_msgnr = '083'  IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_fixes ).
          CONCATENATE gv_msg1 gv_msg2 gv_msg3 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.
          print_error_otel( ).
          send_json_error( ).
          MESSAGE i202(cacsib_edt) WITH lv_path.
      ENDTRY.
    ENDIF.
  ENDMETHOD.


METHOD do_select.

  CONSTANTS lc_quote TYPE c LENGTH 1 VALUE ''''.

  FIELD-SYMBOLS <fs_table_for_all> TYPE STANDARD TABLE.

  DATA lv_del_where TYPE string.

  "--------------------------------------------------
  " ROOT SELECT (same logic)
  "--------------------------------------------------
  IF iv_parent_rel IS INITIAL.

    SELECT (iv_fields)
      INTO CORRESPONDING FIELDS OF TABLE ct_result
      FROM (iv_tabname)
      WHERE (iv_where).

    RETURN.
  ENDIF.


  ct_fae = ct_final.

  ASSIGN ct_fae TO <fs_table_for_all>.

  IF <fs_table_for_all> IS INITIAL.
    sy-subrc = 4.
    RETURN.
  ENDIF.

  CLEAR lv_del_where.

  FIELD-SYMBOLS <ls_pr> TYPE any.
  data lv_one type string.
  LOOP AT it_pr ASSIGNING <ls_pr>.
    ASSIGN COMPONENT 'PARENT_RELATION'
      OF STRUCTURE <ls_pr>
*      TO FIELD-SYMBOL(<lv_pr>).
      TO <ls_pr>.

*     IF sy-subrc <> 0 OR <lv_pr> IS INITIAL.
    IF sy-subrc <> 0 OR <ls_pr> IS INITIAL.
      CONTINUE.
    ENDIF.

*    DATA(lv_one) = lc_quote && <lv_pr> && lc_quote.
    lv_one = lc_quote && <ls_pr> && lc_quote.

    IF lv_del_where IS INITIAL.
      CONCATENATE 'TABNAME EQ' lv_one INTO lv_del_where SEPARATED BY space.
    ELSE.
      CONCATENATE lv_del_where 'AND TABNAME EQ' lv_one
        INTO lv_del_where SEPARATED BY space.
    ENDIF.
  ENDLOOP.

  IF lv_del_where IS NOT INITIAL.
    DELETE <fs_table_for_all> WHERE (lv_del_where).
  ENDIF.

  IF <fs_table_for_all> IS INITIAL.
    sy-subrc = 4.
    RETURN.
  ENDIF.

  SELECT (iv_fields)
    INTO CORRESPONDING FIELDS OF TABLE ct_result
    FROM (iv_tabname)
    FOR ALL ENTRIES IN <fs_table_for_all>
    WHERE (iv_where).

ENDMETHOD.

**METHOD do_select.
**
**  CONSTANTS lc_quote TYPE c LENGTH 1 VALUE ''''.
**
**  FIELD-SYMBOLS <fs_table_for_all> TYPE STANDARD TABLE.
**
**  DATA lv_del_where TYPE string.
**
**  "--------------------------------------------------
**  " Root select
**  "--------------------------------------------------
**  IF iv_parent_rel IS INITIAL.
**
**    SELECT (iv_fields)
**      INTO CORRESPONDING FIELDS OF TABLE ct_result
**      FROM (iv_tabname)
**      WHERE (iv_where).
**
**    RETURN.
**  ENDIF.
**
**  "--------------------------------------------------
**  " FOR ALL ENTRIES part (same logic)
**  "--------------------------------------------------
**  ct_fae_back = ct_final.
**  ct_fae      = ct_fae_back.
**
**  ASSIGN ct_fae TO <fs_table_for_all>.
**
**  CLEAR lv_del_where.
**
**  LOOP AT it_pr ASSIGNING FIELD-SYMBOL(<ls_pr>).
**    ASSIGN COMPONENT 'PARENT_RELATION' OF STRUCTURE <ls_pr>
**      TO FIELD-SYMBOL(<lv_pr>).
**    IF sy-subrc <> 0 OR <lv_pr> IS INITIAL.
**      CONTINUE.
**    ENDIF.
**
**    DATA(lv_one) = lc_quote && <lv_pr> && lc_quote.
**
**    IF lv_del_where IS INITIAL.
**      CONCATENATE 'TABNAME EQ' lv_one INTO lv_del_where SEPARATED BY space.
**    ELSE.
**      CONCATENATE lv_del_where 'AND TABNAME EQ' lv_one
**        INTO lv_del_where SEPARATED BY space.
**    ENDIF.
**  ENDLOOP.
**
**  IF lv_del_where IS NOT INITIAL.
**    DELETE <fs_table_for_all> WHERE (lv_del_where).
**  ENDIF.
**
**  IF <fs_table_for_all> IS INITIAL.
**    sy-subrc = 4.
**    RETURN.
**  ENDIF.
**
**  SELECT (iv_fields)
**    INTO CORRESPONDING FIELDS OF TABLE ct_result
**    FROM (iv_tabname)
**    FOR ALL ENTRIES IN <fs_table_for_all>
**    WHERE (iv_where).
**
**ENDMETHOD.


  METHOD execute_batch.
    DATA: ls_stdt_input       TYPE tbtcstrt,
          ls_stdt_output      TYPE tbtcstrt,
          lv_id               TYPE char30,
          lv_idt              TYPE char30,
          lv_number           TYPE tbtcjob-jobcount,
          lv_name             TYPE tbtcjob-jobname VALUE 'OC_',
          lv_job_was_released TYPE btch0000-char1,
          lv_strtimmed        TYPE btch0000-char1,
          lv_uzeit            TYPE sy-uzeit,
          lv_any              TYPE boolean_flg.


    DATA: ls_track           TYPE zonta_oc_batch,
          lv_parent_jobname  TYPE tbtco-jobname,
          lv_parent_jobcount TYPE tbtco-jobcount.

    DATA: lt_released TYPE STANDARD TABLE OF tbtco,
          ls_latest   TYPE tbtco.

    DATA: lo_out  TYPE REF TO if_demo_output,
          lv_text TYPE string.

    lv_uzeit = sy-uzeit.
    lv_id = sy-datum && lv_uzeit.
    lv_idt = lv_id.


    IF NOT gt_where_cond_tab IS INITIAL.
      lv_id = lv_idt && 'C'.
      EXPORT wheret = gt_where_cond_tab TO DATABASE zontconnectbatch(sc) ID lv_id .
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
    ELSE.
      lv_id = lv_idt && 'R'.
      EXPORT where = gt_where TO DATABASE zontconnectbatch(sc) ID lv_id .
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
    ENDIF.

* Name of job
    lv_name = lv_name && gv_entity.

* Get parent job info (if this is running inside a periodic job)
    CALL FUNCTION 'GET_JOB_RUNTIME_INFO'
      IMPORTING
        jobcount        = lv_parent_jobcount
        jobname         = lv_parent_jobname
      EXCEPTIONS
        no_runtime_info = 1
        OTHERS          = 2.

    CALL FUNCTION 'BP_START_DATE_EDITOR'
      EXPORTING
        stdt_dialog = 'Y'
        stdt_input  = ls_stdt_input
        stdt_opcode = 14
      IMPORTING
        stdt_output = ls_stdt_output
      EXCEPTIONS
        OTHERS      = 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    CASE ls_stdt_output-startdttyp.
      WHEN 'I'.
        lv_strtimmed = abap_true.
      WHEN OTHERS.
        lv_strtimmed = abap_false.
    ENDCASE.

* Open child job
    CALL FUNCTION 'JOB_OPEN'
      EXPORTING
        jobname          = lv_name
      IMPORTING
        jobcount         = lv_number
      EXCEPTIONS
        cant_create_job  = 1
        invalid_job_data = 2
        jobname_missing  = 3
        OTHERS           = 4.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    " Save tracking in Z table
    ls_track-domainv         = gv_domainv.
    ls_track-business_proc   = gv_entity.
    ls_track-execid          = lv_id.
    ls_track-parent_jobname  = lv_parent_jobname.   " Parent periodic job
    ls_track-parent_jobcount = lv_parent_jobcount.
    ls_track-child_jobname   = lv_name.
    ls_track-child_jobcount  = lv_number.
    ls_track-created_by      = sy-uname.
    ls_track-created_on      = sy-datum.
    ls_track-created_at      = sy-uzeit.
    ls_track-submit_prog     = sy-cprog.
    ls_track-status          = 'R'.
    ls_track-variant         = gv_variant.

    INSERT zonta_oc_batch FROM ls_track.
    IF sy-subrc = 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
    ENDIF.

    IF gv_anytable IS NOT INITIAL.
      lv_any = abap_true.
    ELSE.
      lv_any = abap_false.
    ENDIF.
*break frgdev.
    SUBMIT zonpg_oneconnect_batch
        WITH p_execid EQ lv_id
        WITH p_domain EQ gv_domainv
        WITH p_busine EQ gv_entity
        WITH p_kdoc   EQ gv_kdoc
        WITH p_table  EQ gv_table
        WITH p_dest   EQ gv_dest
        WITH p_uzeit  EQ lv_uzeit
        WITH p_anytab EQ lv_any
        WITH p_tabnam EQ gv_anytable
        WITH p_alias  EQ gv_alias
        WITH p_var    EQ gv_variant
        WITH p_both   EQ gv_bothnames
        VIA JOB lv_name NUMBER lv_number
        AND RETURN.

* Close job to release it for execution
    CALL FUNCTION 'JOB_CLOSE'
      EXPORTING
        event_id                = ls_stdt_output-eventid
        event_param             = ls_stdt_output-eventparm
        event_periodic          = ls_stdt_output-periodic
        jobcount                = lv_number
        jobname                 = lv_name
        laststrtdt              = ls_stdt_output-laststrtdt
        laststrttm              = ls_stdt_output-laststrttm
        prddays                 = ls_stdt_output-prddays
        prdhours                = ls_stdt_output-prdhours
        prdmins                 = ls_stdt_output-prdmins
        prdmonths               = ls_stdt_output-prdmonths
        prdweeks                = ls_stdt_output-prdweeks
        predjob_checkstat       = ls_stdt_output-checkstat
        pred_jobcount           = ls_stdt_output-predjobcnt
        pred_jobname            = ls_stdt_output-predjob
        sdlstrtdt               = ls_stdt_output-sdlstrtdt
        sdlstrttm               = ls_stdt_output-sdlstrttm
        strtimmed               = lv_strtimmed
        workday_count_direction = ls_stdt_output-wdaycdir
      IMPORTING
        job_was_released        = lv_job_was_released
      EXCEPTIONS
        OTHERS                  = 1.

    IF sy-subrc = 0.

      lo_out = cl_demo_output=>new( ).
      lo_out->begin_section( 'ONE CONNECT EXECUTION LOG' ).

      lo_out->write_data( gv_entity ).
      lv_text = 'Job created ' && space && lv_name.
      lo_out->write_data( lv_text ).
      lv_text = 'Please validate your own jobs'.
      lo_out->write_data( lv_text ).

      lo_out->display( ).
    ENDIF.

    SELECT * FROM tbtco
      INTO TABLE lt_released
      WHERE jobname = lv_name
        AND status  IN ('S', 'R', 'Y').  " Scheduled, Released, Ready

    " Sort by planned start (latest first)
    SORT lt_released BY sdlstrtdt DESCENDING sdlstrttm DESCENDING.

    READ TABLE lt_released INTO ls_latest INDEX 1.
    ls_track-parent_jobname  = ls_latest-jobname.
    ls_track-parent_jobcount = ls_latest-jobcount.

    ls_track-child_jobname   = lv_name.
    ls_track-child_jobcount  = lv_number.
    ls_track-changed_by      = sy-uname.
    ls_track-changed_on      = sy-datum.
    ls_track-changed_at      = sy-uzeit.
    ls_track-periodic        = ls_stdt_output-periodic.
    ls_track-variant         = gv_variant.

    MODIFY zonta_oc_batch FROM ls_track .
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

  ENDMETHOD.


  METHOD fieldname_json.

    DATA: lv_source    TYPE string,
          lv_target    TYPE string,
          lv_fieldname TYPE zonta_oc_col_all-fldname,
          ls_conv      LIKE LINE OF gt_converted.

    FIELD-SYMBOLS: <fs_columns> TYPE zonta_oc_col_all.

    SORT gt_converted BY tabname fldname.
    LOOP AT gt_columns_all ASSIGNING <fs_columns>.

      TRANSLATE <fs_columns>-fldname TO   UPPER CASE.

      READ TABLE gt_converted INTO ls_conv WITH KEY tabname = <fs_columns>-tabname
                                                    fldname = <fs_columns>-fldname BINARY SEARCH.
      IF sy-subrc = 0.
        lv_fieldname = ls_conv-fldname1.
        TRANSLATE lv_fieldname TO LOWER CASE.
        lv_source = |"{ lv_fieldname }":|.
        TRANSLATE <fs_columns>-fldname TO LOWER CASE.
        lv_fieldname = |"{ <fs_columns>-fldname }":|.
        lv_target = lv_fieldname.
      ELSE.
        lv_fieldname = <fs_columns>-fldname.
        TRANSLATE lv_fieldname TO LOWER CASE.
        lv_source = |"{ lv_fieldname }":|.
        lv_target = lv_source.
      ENDIF.


      REPLACE ALL OCCURRENCES OF '\' IN lv_target WITH '_'.
      REPLACE ALL OCCURRENCES OF '/' IN lv_target WITH '_'.

      REPLACE ALL OCCURRENCES OF lv_source IN cv_json WITH lv_target.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_database_data.


    CONSTANTS: lc_comilla TYPE c LENGTH 1 VALUE ''''.

    DATA: lv_join               TYPE string,
          lv_fields             TYPE string,
          lv_del_where          TYPE string,
          lv_where              TYPE zonttrsdswhere,
          lo_table              TYPE REF TO data,
          lo_table_final        TYPE REF TO data,
          lo_table_for_all      TYPE REF TO data,
          lo_table_for_all2     TYPE REF TO data,
          lo_table_for_all_back TYPE REF TO data,
          lt_relations          TYPE STANDARD TABLE OF zonta_relations,
          ls_relations          TYPE zonta_relations,
          ls_relations2         TYPE zonta_relations,
          lv_is_cds_entity      TYPE abap_bool,
          lt_fields             TYPE TABLE OF line,
          lv_tabname            TYPE string,
          lo_ref                TYPE REF TO  cx_sy_dynamic_osql_syntax,
          lv_text               TYPE string,
          lv_text1              TYPE string,
          lv_text2              TYPE string,
          lv_text3              TYPE string.

    FIELD-SYMBOLS: <fs_table>              TYPE ANY TABLE,
                   <fs_table_final>        TYPE STANDARD TABLE,
                   <fs_table_for_all>      TYPE STANDARD TABLE,
                   <fs_table_for_all2>     TYPE STANDARD TABLE,
                   <fs_table_for_all_back> TYPE STANDARD TABLE,
                   <fs_table_line>         TYPE any,
                   <fs_table_line_final>   TYPE any,
                   <fs_tabname>            TYPE any.

***CHEL 09/17/2025
*    CLEAR gt_relations_aux[].
*    gt_relations_aux = gt_relations.
*    me->sort_relations( CHANGING cht_relations = gt_relations ).
***CHEL 09/17/2025

    lo_table  = me->set_table( iv_add_tabname = abap_true ).
    ASSIGN lo_table->* TO <fs_table>.

    lo_table_final  = me->set_table( iv_add_tabname = abap_true ).
    ASSIGN lo_table_final->* TO <fs_table_final>.


    lo_table_for_all  = me->set_table( iv_add_tabname = abap_true ).
    ASSIGN lo_table_for_all->* TO <fs_table_for_all>.

    lo_table_for_all2  = me->set_table( iv_add_tabname = abap_true ).
    ASSIGN lo_table_for_all2->* TO <fs_table_for_all2>.

* Begin of DB
    lo_table_for_all_back  = me->set_table( iv_add_tabname = abap_true ).
    ASSIGN lo_table_for_all_back->* TO <fs_table_for_all_back>.
* End of DB


*do. enddo.
    lt_relations = gt_relations.
    SORT lt_relations BY sequence.

    DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING sequence.


    me->build_root_filters( CHANGING ct_filters = gt_cond_tab ). "++DB FILTERS

    LOOP AT lt_relations INTO ls_relations.
      lv_is_cds_entity = me->is_cds_entity( ls_relations-tabname ).
      lv_where = me->get_where( iv_tabname = ls_relations-tabname ).

* Begin of insert DB FILTERS
      IF ls_relations-sequence = 1 AND lv_where IS INITIAL.
        rv_table = lo_table_final.
        RETURN.
      ENDIF.
* End of insert DB FILTERS

      CALL METHOD me->set_fields_both
        EXPORTING
          iv_tabname = ls_relations-tabname
        IMPORTING
          ev_fields  = lv_fields
          et_fields  = lt_fields[].

      DATA v_tryoff TYPE c.
      SELECT SINGLE low INTO v_tryoff FROM zonta_oc_param WHERE name = 'SET_TRY_OFF'.
      IF v_tryoff IS NOT INITIAL.
        IF ls_relations-parent_relation IS INITIAL.
          IF abap_false = lv_is_cds_entity.
            SELECT (lv_fields)
              INTO CORRESPONDING FIELDS OF TABLE <fs_table>
              FROM (ls_relations-tabname)
              WHERE (lv_where).
          ELSE.
            SELECT (lt_fields)
              INTO CORRESPONDING FIELDS OF TABLE <fs_table>
              FROM (ls_relations-tabname)
              WHERE (lv_where).
          ENDIF.
        ELSE.
          <fs_table_for_all_back> = <fs_table_final>.
          <fs_table_for_all> = <fs_table_for_all_back>."<fs_table_final>.

**02.08.25 FRG Solution for a running total with new records. begin
***          lv_tabname = lc_comilla && ls_relations-parent_relation && lc_comilla.
***          CONCATENATE 'TABNAME NE' lv_tabname INTO lv_del_where SEPARATED BY space.

          LOOP AT gt_relations INTO ls_relations2 WHERE tabname = ls_relations-tabname.
            IF lv_del_where IS INITIAL.
              lv_tabname = lc_comilla                   &&
                           ls_relations2-parent_relation &&
                           lc_comilla.

              CONCATENATE 'TABNAME NE'
                           lv_tabname
                           INTO lv_del_where
                           SEPARATED BY space.
            ELSE.
              lv_tabname = lc_comilla                   &&
                           ls_relations2-parent_relation &&
                           lc_comilla.

              CONCATENATE  lv_del_where
                           'AND TABNAME NE'
                           lv_tabname
                           INTO lv_del_where
                           SEPARATED BY space.
            ENDIF.
          ENDLOOP.

          DELETE <fs_table_for_all> WHERE (lv_del_where).
          CLEAR lv_del_where.
**02.08.25 FRG Solution for a running total with new records. end

          IF NOT <fs_table_for_all> IS INITIAL.
            IF abap_false = lv_is_cds_entity.
              SELECT (lv_fields)
                INTO CORRESPONDING FIELDS OF TABLE <fs_table>
                FROM (ls_relations-tabname)
                FOR ALL ENTRIES IN <fs_table_for_all>
                WHERE (lv_where).
            ELSE.
              SELECT (lt_fields)
                FROM (ls_relations-tabname)
                INTO CORRESPONDING FIELDS OF TABLE <fs_table>
                FOR ALL ENTRIES IN <fs_table_for_all>
                WHERE (lv_where).
            ENDIF.
          ELSE.
            sy-subrc = 4.
          ENDIF.
        ENDIF.

*        me->append_slg1_log(
*          EXPORTING
*            iv_tabname    = space
*            iv_message_v1 = 'Error - Parse data on SQL'
*            iv_message_v2 = 'check structures'
*            iv_message_v3 = space
*            iv_mestyp     = 'E' ).
*
*        me->update_slg1_log( it_log_ext = gt_log_ext ).


      ELSE.

        TRY."FR
            IF ls_relations-parent_relation IS INITIAL.
              IF abap_false = lv_is_cds_entity.
                SELECT (lv_fields)
                  INTO CORRESPONDING FIELDS OF TABLE <fs_table>
                  FROM (ls_relations-tabname)
                  WHERE (lv_where).
              ELSE.
                SELECT (lt_fields)
                  FROM (ls_relations-tabname)
                  INTO CORRESPONDING FIELDS OF TABLE <fs_table>
                  WHERE (lv_where)
                  .
              ENDIF.
            ELSE.
              <fs_table_for_all_back> = <fs_table_final>.
              <fs_table_for_all> = <fs_table_for_all_back>."<fs_table_final>.

**02.08.25 FRG Solution for a running total with new records. begin
***          lv_tabname = lc_comilla && ls_relations-parent_relation && lc_comilla.
***          CONCATENATE 'TABNAME NE' lv_tabname INTO lv_del_where SEPARATED BY space.

              LOOP AT gt_relations INTO ls_relations2 WHERE tabname = ls_relations-tabname.
                IF lv_del_where IS INITIAL.
                  lv_tabname = lc_comilla                   &&
                               ls_relations2-parent_relation &&
                               lc_comilla.

*                  CONCATENATE 'TABNAME NE'
                  CONCATENATE 'TABNAME EQ'
                               lv_tabname
                               INTO lv_del_where
                               SEPARATED BY space.
                ELSE.
                  lv_tabname = lc_comilla                   &&
                               ls_relations2-parent_relation &&
                               lc_comilla.

                  CONCATENATE  lv_del_where
*                               'AND TABNAME NE'
                               'AND TABNAME EQ'
                               lv_tabname
                               INTO lv_del_where
                               SEPARATED BY space.
                ENDIF.
              ENDLOOP.

*              DELETE <fs_table_for_all> WHERE (lv_del_where).>
*              <fs_table_for_all> = FILTER #( <fs_table_for_all> WHERE (lv_del_where) ).
*              field-SYMBOLS <v_line> like line of  <fs_table_for_all>.
              <fs_table_for_all2> = <fs_table_for_all>.
              REFRESH <fs_table_for_all>.
              free <fs_table_for_all>.
              FIELD-SYMBOLs <v_line> TYPE any.
*              LOOP AT <fs_table_for_all2> ASSIGNING FIELD-SYMBOL(<v_line>) WHERE (lv_del_where).
              LOOP AT <fs_table_for_all2> ASSIGNING <v_line> WHERE (lv_del_where).
                 APPEND <v_line> to <fs_table_for_all>.
              ENDLOOP.

              CLEAR lv_del_where.
**02.08.25 FRG Solution for a running total with new records. end

              IF NOT <fs_table_for_all> IS INITIAL.
                IF abap_false = lv_is_cds_entity.
                  SELECT (lv_fields)
                    INTO CORRESPONDING FIELDS OF TABLE <fs_table>
                    FROM (ls_relations-tabname)
                    FOR ALL ENTRIES IN <fs_table_for_all>
                    WHERE (lv_where).
                ELSE.
                  SELECT (lt_fields)
                    FROM (ls_relations-tabname)
                    INTO CORRESPONDING FIELDS OF TABLE <fs_table>
                    FOR ALL ENTRIES IN <fs_table_for_all>
                    WHERE (lv_where).
                ENDIF.
              ELSE.
                sy-subrc = 4.
              ENDIF.
            ENDIF.
            DATA: lo_ref1 TYPE REF TO cx_sy_dynamic_osql_semantics.
            CATCH cx_sy_dynamic_osql_semantics INTO lo_ref1.
            gs_elog-type       = 'DYNAMIC_OSQL_SEMANTICS'.
            gs_elog-message    = lo_ref1->get_longtext( ).
            CALL METHOD lo_ref1->get_source_position
              IMPORTING
                program_name = gv_prog
                source_line  = gv_sline.
            lv_text = lo_ref1->get_longtext( ).
            gs_elog-severity   = gc_error.
            gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
            gs_elog-details-db = 'ZONCL_OC_BASE_HANDLER-GET_DATABASE_DATA'.
            gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

            gs_elog-metadata-error_code = gs_elog-details-error_code.
            interpret_message( EXPORTING iv_msgnr = '072' iv_msgv1 = ls_relations-tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '073' IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '074' IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '075' IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
            CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
            interpret_message( EXPORTING iv_msgnr = '076' iv_msgv1 = ls_relations-tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '065' IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '070' IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_fixes ).
            CONCATENATE gv_msg1 gv_msg2 gv_msg3 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.

            "DB FIX to stop out of bounds error
            lv_text1 = substring( val = lv_text off = 0   len = 50 ).
            lv_text2 = substring( val = lv_text off = 50  len = 50 ).
            lv_text3 = substring( val = lv_text off = 100 len = 50 ).

            IF gv_instid IS INITIAL.
              print_error_otel( ).
              send_json_error( ).
              EXIT.
            ENDIF.

            me->append_slg1_log(
              EXPORTING
                iv_tabname    = space
                iv_message_v1 = 'Error - Parse data on SQL'
                iv_message_v2 = 'check structures'
                iv_message_v3 = space
                iv_mestyp     = 'E' ).

            me->update_slg1_log( it_log_ext = gt_log_ext ).

            RETURN.
            DATA: lo_sql TYPE REF TO cx_sy_dynamic_osql_error.
          CATCH cx_sy_dynamic_osql_error INTO lo_sql.
            gs_elog-type = 'DYNAMIC_OSQL_ERROR'.
            gs_elog-message    = lo_sql->get_longtext( ).
            CALL METHOD lo_sql->get_source_position
              IMPORTING
                program_name = gv_prog
                source_line  = gv_sline.
            lv_text = lo_sql->get_longtext( ).

            gs_elog-severity   = gc_error.
            gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
            gs_elog-details-db = 'ZONCL_OC_BASE_HANDLER-GET_DATABASE_DATA'.
            gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

            gs_elog-metadata-error_code = gs_elog-details-error_code.
            interpret_message( EXPORTING iv_msgnr = '072' iv_msgv1 = ls_relations-tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '073' IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '074' IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '075' IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
            CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
            interpret_message( EXPORTING iv_msgnr = '076' iv_msgv1 = ls_relations-tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '065' IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '070' IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_fixes ).
            CONCATENATE gv_msg1 gv_msg2 gv_msg3 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.

            "DB FIX to stop out of bounds error
            lv_text1 = substring( val = lv_text off = 0   len = 50 ).
            lv_text2 = substring( val = lv_text off = 50  len = 50 ).
            lv_text3 = substring( val = lv_text off = 100 len = 50 ).

            IF gv_instid IS INITIAL.
              print_error_otel( ).
              send_json_error( ).
              EXIT.
            ENDIF.

            me->append_slg1_log(
              EXPORTING
                iv_tabname    = space
                iv_message_v1 = 'Error - Parse data on SQL'
                iv_message_v2 = 'check structures'
                iv_message_v3 = space
                iv_mestyp     = 'E' ).

            me->update_slg1_log( it_log_ext = gt_log_ext ).

            RETURN.
          CATCH cx_root INTO gx_text.
            gs_elog-type = 'TECHNICAL_ERROR'.
            gs_elog-message    = gx_text->get_longtext( ).
            CALL METHOD gx_text->get_source_position
              IMPORTING
                program_name = gv_prog
                source_line  = gv_sline.
            lv_text = gx_text->get_longtext( ).

            gs_elog-severity   = gc_error.
            gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
            gs_elog-details-db = 'ZONCL_OC_BASE_HANDLER-GET_DATABASE_DATA'.
            gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

            gs_elog-metadata-error_code = gs_elog-details-error_code.
            interpret_message( EXPORTING iv_msgnr = '072' iv_msgv1 = ls_relations-tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '073' IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '074' IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '075' IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
            CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
            interpret_message( EXPORTING iv_msgnr = '076' iv_msgv1 = ls_relations-tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '065' IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '070' IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_fixes ).
            CONCATENATE gv_msg1 gv_msg2 gv_msg3 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.

            "DB FIX to stop out of bounds error
            lv_text1 = substring( val = lv_text off = 0   len = 50 ).
            lv_text2 = substring( val = lv_text off = 50  len = 50 ).
            lv_text3 = substring( val = lv_text off = 100 len = 50 ).

            IF gv_instid IS INITIAL.
              print_error_otel( ).
              send_json_error( ).
              EXIT.
            ENDIF.


            me->append_slg1_log(
              EXPORTING
                iv_tabname    = space
                iv_message_v1 = 'Error - Parse data on SQL'
                iv_message_v2 = 'check structures'
                iv_message_v3 = space
                iv_mestyp     = 'E' ).

            me->update_slg1_log( it_log_ext = gt_log_ext ).

            RETURN.
        ENDTRY.
      ENDIF.
*      IF sy-subrc EQ 0 AND <fs_table_final> IS ASSIGNED.




      "--------------------------------------------------
      " Append to final table (memory safe)
      "--------------------------------------------------
      "--------------------------------------------------
      " Append to final table (correct + memory safe)
      "--------------------------------------------------
      IF <fs_table_final> IS ASSIGNED AND <fs_table> IS NOT INITIAL.

        LOOP AT <fs_table> ASSIGNING <fs_table_line>.
          APPEND <fs_table_line> TO <fs_table_final> ASSIGNING <fs_table_line_final>.

          ASSIGN COMPONENT 'TABNAME' OF STRUCTURE <fs_table_line_final> TO <fs_tabname>.
          IF <fs_tabname> IS ASSIGNED.
            <fs_tabname> = ls_relations-tabname.
          ENDIF.
        ENDLOOP.

        FREE <fs_table>.  " release immediately
      ENDIF.



**02.08.25 FRG Solution for a running total with new records. begin
*        LOOP AT <fs_table> ASSIGNING <fs_table_line>.
*          APPEND INITIAL LINE TO <fs_table_final> ASSIGNING <fs_table_line_final>.
*          MOVE-CORRESPONDING <fs_table_line> TO <fs_table_line_final>.
*          ASSIGN COMPONENT 'TABNAME' OF STRUCTURE <fs_table_line_final> TO <fs_tabname>.
*          <fs_tabname> = ls_relations-tabname.
*        ENDLOOP.

*******        DATA lv_tabix TYPE i.
*******        DATA lv_tabix3 TYPE i.
*******        DATA: lr_current_source_line TYPE REF TO data.
*******        DATA: lr_previous_target_line TYPE REF TO data.
*******        DATA: lr_combined_result TYPE REF TO data.
*******        FIELD-SYMBOLS: "<fs_table>             TYPE ANY TABLE, " Para la tabla de origen completa
*******          "<fs_table_final>       TYPE ANY TABLE, " Para la tabla destino completa
*******          <fs_current_source_line> TYPE any,    " Para la línea actual de la tabla de origen
*******          <fs_current_target_line> TYPE any,    " Para la línea actual de la tabla destino
*******          <fs_result_struct>       TYPE any.    " Para el resultado combinado
*******
*******        DESCRIBE TABLE  <fs_table_final> LINES  lv_tabix3.
*******        DATA V_STOP TYPE I.
*******        ADD 25000 TO V_STOP.
*******        LOOP AT <fs_table> ASSIGNING <fs_current_source_line>.
*******
*********Get long text from STXL "++CHEL
********          IF  ls_relations-tabname EQ 'STXL'.
********            me->get_read_text_longtext( EXPORTING iv_tabname = ls_relations-tabname
********                                         CHANGING isc_table = <fs_current_source_line> ).
********          ENDIF.
********          lv_tabix = sy-tabix. " Get current loop index  "++DB
*******          " Append an initial line to the final table
*******          APPEND INITIAL LINE TO <fs_table_final> ASSIGNING <fs_current_target_line>.
*******          lv_tabix = sy-tabix. " Get current loop index  --DB
********          READ TABLE lt_relations INTO ls_relations2 INDEX lv_tabix.
*******          READ TABLE lt_relations INTO ls_relations2 WITH  KEY tabname = ls_relations-tabname.
*******          IF lv_tabix = 1 OR sy-subrc NE 0.
*******            MOVE-CORRESPONDING <fs_current_source_line> TO <fs_current_target_line>.
*******          ELSE.
*******            GET REFERENCE OF <fs_current_source_line> INTO lr_current_source_line.
*******            lv_tabix = lv_tabix - 1.
*******            READ TABLE <fs_table_final> REFERENCE INTO lr_previous_target_line INDEX lv_tabix3.
*******
*******            IF lr_previous_target_line IS BOUND.
*******              TRY.
*******                  CALL METHOD zoncl_dynamic_combiner=>combine_non_initial_fields
*******                    EXPORTING
*******                      is_source1 = lr_current_source_line    " Current line from source table
*******                      is_source2 = lr_previous_target_line   " Previous line from target table
*******                    IMPORTING
*******                      es_target  = lr_combined_result.       " Reference to the NEWLY CREATED combined result
*******
*******                  ASSIGN lr_combined_result->* TO <fs_result_struct>.
*******
*******                  IF <fs_result_struct> IS ASSIGNED.
*******                    MOVE-CORRESPONDING <fs_result_struct> TO <fs_current_target_line>.
*******                  ELSE.
*******                    MOVE-CORRESPONDING <fs_current_source_line> TO <fs_current_target_line>.
*******                  ENDIF.
*******                  CLEAR <fs_result_struct>.
*******              ENDTRY.
*******            ELSE.
*******              " Should not happen if lv_tabix - 1 is a valid index, but good for robustness
*******              MOVE-CORRESPONDING <fs_current_source_line> TO <fs_current_target_line>.
*******            ENDIF.
*******          ENDIF.
*******
*******          ASSIGN COMPONENT 'TABNAME' OF STRUCTURE <fs_current_target_line> TO <fs_tabname>.
*******          IF <fs_tabname> IS ASSIGNED.
*******            <fs_tabname> = ls_relations-tabname.
*******          ENDIF.
*******        ENDLOOP.
*02.08.25 FRG Solution for a running total with new records. end
*            BREAK FRGDEV.

*      ENDIF.

    ENDLOOP.

***CHEL 09/17/2025
*    validate_data_where( CHANGING ch_table = lo_table_final ).
*    gt_relations = gt_relations_aux.
*    CLEAR gt_relations_aux[].
***CHEL 09/17/2025

    rv_table = lo_table_final.
  ENDMETHOD.


  METHOD get_database_datat.



    CONSTANTS lc_comilla TYPE c LENGTH 1 VALUE ''''.

    DATA:
      lv_fields             TYPE string,
      lv_del_where          TYPE string,
      lv_where              TYPE zonttrsdswhere,
      lv_tabname            TYPE string,
      lv_is_cds_entity      TYPE abap_bool,
      lt_fields             TYPE TABLE OF line,
      lt_relations          TYPE STANDARD TABLE OF zonta_relations,
      ls_relations          TYPE zonta_relations,
      ls_relations2         TYPE zonta_relations,
      ls_datat              TYPE ty_datat,
      lo_table              TYPE REF TO data,
      lo_table_for_all      TYPE REF TO data,
      lo_table_for_all2     TYPE REF TO data,
      lo_table_for_all_back TYPE REF TO data,
      lo_ref                TYPE REF TO cx_sy_dynamic_osql_syntax,
      lv_text               TYPE string,
      lv_text1              TYPE string,
      lv_text2              TYPE string,
      lv_text3              TYPE string,
      v_tryoff              TYPE c,
      lo_table_copy         TYPE REF TO data.


    FIELD-SYMBOLS:
      <fs_table>              TYPE ANY TABLE,
      <fs_table_for_all>      TYPE STANDARD TABLE,
      <fs_table_for_all2>     TYPE STANDARD TABLE,
      <fs_table_for_all_back> TYPE STANDARD TABLE,
      <fs_table_copy>         TYPE ANY TABLE.

    "--------------------------------------------------
    " Read TRY OFF flag once
    "--------------------------------------------------
    SELECT SINGLE low
      INTO v_tryoff
      FROM zonta_oc_param
      WHERE name = 'SET_TRY_OFF'.

    "--------------------------------------------------
    " Prepare helper tables
    "--------------------------------------------------
    lo_table_for_all      = me->set_table( iv_add_tabname = abap_true ).
    lo_table_for_all2     = me->set_table( iv_add_tabname = abap_true ).
    lo_table_for_all_back = me->set_table( iv_add_tabname = abap_true ).

    ASSIGN lo_table_for_all->*      TO <fs_table_for_all>.
    ASSIGN lo_table_for_all2->*     TO <fs_table_for_all2>.
    ASSIGN lo_table_for_all_back->* TO <fs_table_for_all_back>.

    lt_relations = gt_relations.
    SORT lt_relations BY sequence.
    DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING sequence.

    me->build_root_filters( CHANGING ct_filters = gt_cond_tab ).

    LOOP AT lt_relations INTO ls_relations.

      lv_is_cds_entity = me->is_cds_entity( ls_relations-tabname ).
      lv_where         = me->get_where( iv_tabname = ls_relations-tabname ).

      "--------------------------------------------------
      " Create WORK table per iteration
      "--------------------------------------------------
      lo_table = me->set_table( iv_add_tabname = abap_true ).
      ASSIGN lo_table->* TO <fs_table>.

      CALL METHOD me->set_fields_both
        EXPORTING
          iv_tabname = ls_relations-tabname
        IMPORTING
          ev_fields  = lv_fields
          et_fields  = lt_fields[].

      IF v_tryoff IS NOT INITIAL.

        IF ls_relations-parent_relation IS INITIAL.

*          IF abap_false = lv_is_cds_entity.
          SELECT (lv_fields)
            INTO CORRESPONDING FIELDS OF TABLE <fs_table>
            FROM (ls_relations-tabname)
            WHERE (lv_where).
*          ELSE.
*            SELECT (lt_fields)
*              FROM (ls_relations-tabname)
*              WHERE (lv_where)
*              INTO CORRESPONDING FIELDS OF TABLE @<fs_table>.
*          ENDIF.

        ELSE.

          REFRESH <fs_table_for_all>.
          FREE <fs_table_for_all>.

          LOOP AT gt_datat INTO ls_datat WHERE tabname = ls_relations-parent_relation.

            lo_table_for_all2 = ls_datat-lo_table.
            ASSIGN lo_table_for_all2->* TO <fs_table_for_all2>.

            APPEND LINES OF <fs_table_for_all2> TO <fs_table_for_all>.

          ENDLOOP.


          IF <fs_table_for_all> IS NOT INITIAL.

*            IF abap_false = lv_is_cds_entity.
            SELECT (lv_fields)
              INTO CORRESPONDING FIELDS OF TABLE <fs_table>
              FROM (ls_relations-tabname)
              FOR ALL ENTRIES IN <fs_table_for_all>
              WHERE (lv_where).
*            ELSE.
*              SELECT (lt_fields)
*                FROM (ls_relations-tabname)
*                FOR ALL ENTRIES IN @<fs_table_for_all>
*                WHERE (lv_where)
*                INTO CORRESPONDING FIELDS OF TABLE @<fs_table>.
*            ENDIF.

          ELSE.
            sy-subrc = 4.
          ENDIF.

        ENDIF.

      ELSE.

        DATA lo_ref1 TYPE REF TO cx_sy_dynamic_osql_semantics.
        DATA lo_sql  TYPE REF TO cx_sy_dynamic_osql_error.

        TRY.

            IF ls_relations-parent_relation IS INITIAL.

*              IF abap_false = lv_is_cds_entity.
              SELECT (lv_fields)
                INTO CORRESPONDING FIELDS OF TABLE <fs_table>
                FROM (ls_relations-tabname)
                WHERE (lv_where).
*              ELSE.
*                SELECT (lt_fields)
*                  FROM (ls_relations-tabname)
*                  WHERE (lv_where)
*                  INTO CORRESPONDING FIELDS OF TABLE @<fs_table>.
*              ENDIF.

            ELSE.

              REFRESH <fs_table_for_all>.
              FREE <fs_table_for_all>.

              LOOP AT gt_datat INTO ls_datat WHERE tabname = ls_relations-parent_relation.

                lo_table_for_all2 = ls_datat-lo_table.
                ASSIGN lo_table_for_all2->* TO <fs_table_for_all2>.

                APPEND LINES OF <fs_table_for_all2> TO <fs_table_for_all>.

              ENDLOOP.

              IF <fs_table_for_all> IS NOT INITIAL.

*                IF abap_false = lv_is_cds_entity.
                SELECT (lv_fields)
                  INTO CORRESPONDING FIELDS OF TABLE <fs_table>
                  FROM (ls_relations-tabname)
                  FOR ALL ENTRIES IN <fs_table_for_all>
                  WHERE (lv_where).
*                ELSE.
*                  SELECT (lt_fields)
*                    FROM (ls_relations-tabname)
*                    FOR ALL ENTRIES IN @<fs_table_for_all>
*                    WHERE (lv_where)
*                    INTO CORRESPONDING FIELDS OF TABLE @<fs_table>.
*                ENDIF.

              ELSE.
                sy-subrc = 4.
              ENDIF.

            ENDIF.

*           CATCH cx_sy_dynamic_osql_semantics INTO data(lo_ref1).
          CATCH cx_sy_dynamic_osql_semantics INTO lo_ref1.
            gs_elog-type       = 'DYNAMIC_OSQL_SEMANTICS'.
            gs_elog-message    = lo_ref1->get_longtext( ).
            CALL METHOD lo_ref1->get_source_position
              IMPORTING
                program_name = gv_prog
                source_line  = gv_sline.
            lv_text = lo_ref1->get_longtext( ).
            gs_elog-severity   = gc_error.
            gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
            gs_elog-details-db = 'ZONCL_OC_BASE_HANDLER-GET_DATABASE_DATA'.
            gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

            gs_elog-metadata-error_code = gs_elog-details-error_code.
            interpret_message( EXPORTING iv_msgnr = '072' iv_msgv1 = ls_relations-tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '073' IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '074' IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '075' IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
            CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
            interpret_message( EXPORTING iv_msgnr = '076' iv_msgv1 = ls_relations-tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '065' IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '070' IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_fixes ).
            CONCATENATE gv_msg1 gv_msg2 gv_msg3 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.

            "DB FIX to stop out of bounds error
            lv_text1 = substring( val = lv_text off = 0   len = 50 ).
            lv_text2 = substring( val = lv_text off = 50  len = 50 ).
            lv_text3 = substring( val = lv_text off = 100 len = 50 ).

            IF gv_instid IS INITIAL.
              print_error_otel( ).
              send_json_error( ).
              EXIT.
            ENDIF.

            me->append_slg1_log(
              EXPORTING
                iv_tabname    = space
                iv_message_v1 = 'Error - Parse data on SQL'
                iv_message_v2 = 'check structures'
                iv_message_v3 = space
                iv_mestyp     = 'E' ).

            me->update_slg1_log( it_log_ext = gt_log_ext ).

            RETURN.

*          CATCH cx_sy_dynamic_osql_error INTO data(lo_sql).
          CATCH cx_sy_dynamic_osql_error INTO lo_sql.

            gs_elog-type = 'DYNAMIC_OSQL_ERROR'.
            gs_elog-message    = lo_sql->get_longtext( ).
            CALL METHOD lo_sql->get_source_position
              IMPORTING
                program_name = gv_prog
                source_line  = gv_sline.
            lv_text = lo_sql->get_longtext( ).

            gs_elog-severity   = gc_error.
            gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
            gs_elog-details-db = 'ZONCL_OC_BASE_HANDLER-GET_DATABASE_DATA'.
            gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

            gs_elog-metadata-error_code = gs_elog-details-error_code.
            interpret_message( EXPORTING iv_msgnr = '072' iv_msgv1 = ls_relations-tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '073' IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '074' IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '075' IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
            CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
            interpret_message( EXPORTING iv_msgnr = '076' iv_msgv1 = ls_relations-tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '065' IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '070' IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_fixes ).
            CONCATENATE gv_msg1 gv_msg2 gv_msg3 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.

            "DB FIX to stop out of bounds error
            lv_text1 = substring( val = lv_text off = 0   len = 50 ).
            lv_text2 = substring( val = lv_text off = 50  len = 50 ).
            lv_text3 = substring( val = lv_text off = 100 len = 50 ).

            IF gv_instid IS INITIAL.
              print_error_otel( ).
              send_json_error( ).
              EXIT.
            ENDIF.

            me->append_slg1_log(
              EXPORTING
                iv_tabname    = space
                iv_message_v1 = 'Error - Parse data on SQL'
                iv_message_v2 = 'check structures'
                iv_message_v3 = space
                iv_mestyp     = 'E' ).

            me->update_slg1_log( it_log_ext = gt_log_ext ).

            RETURN.
          CATCH cx_root INTO gx_text.
            gs_elog-type = 'TECHNICAL_ERROR'.
            gs_elog-message    = gx_text->get_longtext( ).
            CALL METHOD gx_text->get_source_position
              IMPORTING
                program_name = gv_prog
                source_line  = gv_sline.
            lv_text = gx_text->get_longtext( ).

            gs_elog-severity   = gc_error.
            gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
            gs_elog-details-db = 'ZONCL_OC_BASE_HANDLER-GET_DATABASE_DATA'.
            gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

            gs_elog-metadata-error_code = gs_elog-details-error_code.
            interpret_message( EXPORTING iv_msgnr = '072' iv_msgv1 = ls_relations-tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '073' IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '074' IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '075' IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
            CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
            interpret_message( EXPORTING iv_msgnr = '076' iv_msgv1 = ls_relations-tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '065' IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '070' IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_fixes ).
            CONCATENATE gv_msg1 gv_msg2 gv_msg3 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.

            "DB FIX to stop out of bounds error
            lv_text1 = substring( val = lv_text off = 0   len = 50 ).
            lv_text2 = substring( val = lv_text off = 50  len = 50 ).
            lv_text3 = substring( val = lv_text off = 100 len = 50 ).

            IF gv_instid IS INITIAL.
              print_error_otel( ).
              send_json_error( ).
              EXIT.
            ENDIF.


            me->append_slg1_log(
              EXPORTING
                iv_tabname    = space
                iv_message_v1 = 'Error - Parse data on SQL'
                iv_message_v2 = 'check structures'
                iv_message_v3 = space
                iv_mestyp     = 'E' ).

            me->update_slg1_log( it_log_ext = gt_log_ext ).

            RETURN.
        ENDTRY.
      ENDIF.



      "--------------------------------------------------
      " Clone and store table (memory safe)
      "--------------------------------------------------
      IF <fs_table> IS NOT INITIAL.
        FIELD-SYMBOLS: <fs_datat> LIKE LINE OF gt_datat.
        CREATE DATA lo_table_copy LIKE <fs_table>.
        ASSIGN lo_table_copy->* TO <fs_table_copy>.
        <fs_table_copy> = <fs_table>.

*****
        DATA lv_size TYPE i.

        CLEAR lv_size.
        IF <fs_table> IS ASSIGNED.
          lv_size = lines(  <fs_table> ).
        ELSE.
          lv_size = 0.
        ENDIF.
        set_log_json_result( EXPORTING iv_tabname = ls_relations-tabname iv_size = lv_size ).
*****

*        APPEND INITIAL LINE TO gt_datat ASSIGNING field-symbol(<fs_datat>).
        APPEND INITIAL LINE TO gt_datat ASSIGNING <fs_datat>.
        <fs_datat>-tabname  = ls_relations-tabname.
        <fs_datat>-lo_table = lo_table_copy.

        FREE <fs_table>.
      ELSE.

        APPEND INITIAL LINE TO gt_datat ASSIGNING <fs_datat>.
        <fs_datat>-tabname  = ls_relations-tabname.

      ENDIF.

    ENDLOOP.


  ENDMETHOD.


METHOD get_database_datat_open.

  CONSTANTS: lc_comilla TYPE c LENGTH 1 VALUE '''',
             lc_inner   TYPE c LENGTH 5 VALUE 'INNER'.

  DATA:
    lv_fields             TYPE string,
    lo_msg                TYPE REF TO cx_root,
    lv_del_where          TYPE string,
    lv_result             TYPE string,
    lv_error(200)         TYPE c,
    lv_where              TYPE zonttrsdswhere,
    lv_tabname            TYPE string,
    lv_is_cds_entity      TYPE abap_bool,
    lt_fields             TYPE TABLE OF line,
    lt_relations          TYPE STANDARD TABLE OF zonta_relations,
    ls_relations          TYPE zonta_relations,
    ls_relations2         TYPE zonta_relations,
    lt_datat_tmp          TYPE STANDARD TABLE OF ty_datat,
    ls_datat              TYPE ty_datat,
    lo_table              TYPE REF TO data,
    lo_table_for_all      TYPE REF TO data,
    lo_table_for_all2     TYPE REF TO data,
    lo_table_for_all_back TYPE REF TO data,
    lo_ref                TYPE REF TO cx_sy_dynamic_osql_syntax,
    lv_text               TYPE string,
    lv_text1              TYPE string,
    lv_text2              TYPE string,
    lv_text3              TYPE string,
    v_tryoff              TYPE c,
    lo_table_copy         TYPE REF TO data,
    lv_cursor             TYPE cursor,
    lv_pakage             TYPE i,
    lv_lpakage            TYPE zonta_oc_param-low,
    lv_count              TYPE i.

  FIELD-SYMBOLS:
    <fs_table>              TYPE ANY TABLE,
    <fs_table_for_all>      TYPE STANDARD TABLE,
    <fs_table_for_all2>     TYPE STANDARD TABLE,
    <fs_table_for_all_back> TYPE STANDARD TABLE,
    <fs_table_copy>         TYPE ANY TABLE,
    <fs_existing>           TYPE ty_datat,
    <fs_existing_tab>       TYPE ANY TABLE,
    <fs_new_tab>            TYPE ANY TABLE.


  "--------------------------------------------------
  " Read TRY OFF flag once
  "--------------------------------------------------
  SELECT SINGLE low
    INTO v_tryoff
    FROM zonta_oc_param
    WHERE name = 'SET_TRY_OFF'.

  "--------------------------------------------------
  " Read PAKAGE for OPEN CURSOR
  "--------------------------------------------------
  SELECT SINGLE low
    INTO lv_lpakage
    FROM zonta_oc_param
    WHERE name = 'OPEN_CURSOR_OFFSET'.
  IF sy-subrc = 0.
    lv_pakage = lv_lpakage.
  ELSE.
    lv_pakage = gs_oc_obj-no_registros.
  ENDIF.
  "--------------------------------------------------
  " Prepare helper tables
  "--------------------------------------------------
  lo_table_for_all      = me->set_table( iv_add_tabname = abap_true ).
  lo_table_for_all2     = me->set_table( iv_add_tabname = abap_true ).
  lo_table_for_all_back = me->set_table( iv_add_tabname = abap_true ).

  ASSIGN lo_table_for_all->*      TO <fs_table_for_all>.
  ASSIGN lo_table_for_all2->*     TO <fs_table_for_all2>.
  ASSIGN lo_table_for_all_back->* TO <fs_table_for_all_back>.

  lt_relations = gt_relations.
  SORT lt_relations BY sequence.
  DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING sequence.

  me->build_root_filters( CHANGING ct_filters = gt_cond_tab ).



  READ TABLE lt_relations INTO ls_relations WITH KEY sequence = 1.

* New code for open
  lv_where         = me->get_where( iv_tabname = ls_relations-tabname ).

  lo_table = me->set_table( iv_add_tabname = abap_true ).
  ASSIGN lo_table->* TO <fs_table>.

  CALL METHOD me->set_fields_both
    EXPORTING
      iv_tabname = ls_relations-tabname
    IMPORTING
      ev_fields  = lv_fields
      et_fields  = lt_fields[].

  " OPEN CURSOR WITH HOLD @lv_cursor FOR SELECT (lv_fields)  FROM (ls_relations-tabname) WHERE (lv_where).
  OPEN CURSOR WITH HOLD @lv_cursor FOR SELECT (lt_fields)  FROM (ls_relations-tabname) WHERE (lv_where).

  CLEAR lv_count.
  DO.
    lv_count = lv_count + 1.
    TRY.
        FETCH NEXT CURSOR @lv_cursor
          INTO CORRESPONDING FIELDS OF TABLE @<fs_table> PACKAGE SIZE @lv_pakage.
        IF sy-subrc NE 0.
          CLOSE CURSOR @lv_cursor.
          IF lv_count = 1.
            MESSAGE i000(fb) WITH 'No data found'.

            me->append_slg1_log(
              EXPORTING
                iv_tabname    = space
                iv_message_v1 = 'No data found'
                iv_message_v2 = space
                iv_message_v3 = space
                iv_mestyp     = 'S' ).

          ENDIF.
          EXIT.
        ENDIF.
      CATCH cx_root INTO lo_msg.
*        CLOSE CURSOR lv_cursor.   "DB March 2026
        lv_result = lo_msg->get_text( ).
        lv_error  = lv_result.

        sy-msgv1 = lv_error+0(50).
        sy-msgv2 = lv_error+50(50).
        sy-msgv3 = lv_error+100(50).
        sy-msgv4 = lv_error+150(50).


        gs_elog-type       = 'GET_DATABASE_DATAT_OPEN'.
        gs_elog-severity   = gc_error.
        gs_elog-message    = lo_msg->get_longtext( ).
        CALL METHOD lo_msg->get_source_position
          IMPORTING
            program_name = gv_prog
            source_line  = gv_sline.
        gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
        gs_elog-details-db = 'ZONCL_OC_BASE_HANDLER-GET_DATABASE_DATAT_OPEN'.
        gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.


        gs_elog-metadata-error_code = gs_elog-details-error_code.
        interpret_message( EXPORTING iv_msgnr = '117' iv_msgv1 = lv_tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
        gs_elog-metadata-possible_cause = gv_msg1.
        interpret_message( EXPORTING iv_msgnr = '118'  IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
        gs_elog-metadata-possible_fix = gv_msg1.
        print_error_otel( ).
        send_json_error( ).
        EXIT.
    ENDTRY.

    LOOP AT lt_relations INTO ls_relations.

      IF ls_relations-parent_relation IS NOT INITIAL.
        lv_is_cds_entity = me->is_cds_entity( ls_relations-tabname ).
        lv_where         = me->get_where( iv_tabname = ls_relations-tabname ).

        "--------------------------------------------------
        " Create WORK table per iteration
        "--------------------------------------------------
        lo_table = me->set_table( iv_add_tabname = abap_true ).
        ASSIGN lo_table->* TO <fs_table>.

        CALL METHOD me->set_fields_both
          EXPORTING
            iv_tabname = ls_relations-tabname
          IMPORTING
            ev_fields  = lv_fields
            et_fields  = lt_fields[].
      ENDIF.


      IF v_tryoff IS NOT INITIAL.

        IF ls_relations-parent_relation IS NOT INITIAL.
          REFRESH <fs_table_for_all>.
          FREE <fs_table_for_all>.

          LOOP AT lt_datat_tmp INTO ls_datat WHERE tabname = ls_relations-parent_relation.
            lo_table_for_all2 = ls_datat-lo_table.
            ASSIGN lo_table_for_all2->* TO <fs_table_for_all2>.
            APPEND LINES OF <fs_table_for_all2> TO <fs_table_for_all>.
          ENDLOOP.

          IF <fs_table_for_all> IS NOT INITIAL.

            IF abap_false = lv_is_cds_entity.
              SELECT (lv_fields)
                INTO CORRESPONDING FIELDS OF TABLE <fs_table>
                FROM (ls_relations-tabname)
                FOR ALL ENTRIES IN <fs_table_for_all>
                WHERE (lv_where).
            ELSE.
              SELECT (lt_fields)
                FROM (ls_relations-tabname)
                FOR ALL ENTRIES IN @<fs_table_for_all>
                WHERE (lv_where)
                INTO CORRESPONDING FIELDS OF TABLE @<fs_table>.
            ENDIF.

          ELSE.
            sy-subrc = 4.
          ENDIF.

        ENDIF.

      ELSE.

        TRY.

            IF ls_relations-parent_relation IS NOT INITIAL.

              REFRESH <fs_table_for_all>.
              FREE <fs_table_for_all>.

              LOOP AT lt_datat_tmp INTO ls_datat WHERE tabname = ls_relations-parent_relation.

                lo_table_for_all2 = ls_datat-lo_table.
                ASSIGN lo_table_for_all2->* TO <fs_table_for_all2>.

                APPEND LINES OF <fs_table_for_all2> TO <fs_table_for_all>.

              ENDLOOP.

              IF <fs_table_for_all> IS NOT INITIAL.

                IF abap_false = lv_is_cds_entity.
                  SELECT (lv_fields)
                    INTO CORRESPONDING FIELDS OF TABLE <fs_table>
                    FROM (ls_relations-tabname)
                    FOR ALL ENTRIES IN <fs_table_for_all>
                    WHERE (lv_where).
                ELSE.
                  SELECT (lt_fields)
                    FROM (ls_relations-tabname)
                    FOR ALL ENTRIES IN @<fs_table_for_all>
                    WHERE (lv_where)
                    INTO CORRESPONDING FIELDS OF TABLE @<fs_table>.
                ENDIF.

              ELSE.
                sy-subrc = 4.
              ENDIF.

            ENDIF.

          CATCH cx_sy_dynamic_osql_semantics INTO DATA(lo_ref1).
            gs_elog-type       = 'DYNAMIC_OSQL_SEMANTICS'.
            gs_elog-message    = lo_ref1->get_longtext( ).
            CALL METHOD lo_ref1->get_source_position
              IMPORTING
                program_name = gv_prog
                source_line  = gv_sline.
            lv_text = lo_ref1->get_longtext( ).
            gs_elog-severity   = gc_error.
            gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
            gs_elog-details-db = 'ZONCL_OC_BASE_HANDLER-GET_DATABASE_DATA'.
            gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

            gs_elog-metadata-error_code = gs_elog-details-error_code.
            interpret_message( EXPORTING iv_msgnr = '072' iv_msgv1 = ls_relations-tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '073' IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '074' IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '075' IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
            CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
            interpret_message( EXPORTING iv_msgnr = '076' iv_msgv1 = ls_relations-tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '065' IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '070' IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_fixes ).
            CONCATENATE gv_msg1 gv_msg2 gv_msg3 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.

            "DB FIX to stop out of bounds error
            lv_text1 = substring( val = lv_text off = 0   len = 50 ).
            lv_text2 = substring( val = lv_text off = 50  len = 50 ).
            lv_text3 = substring( val = lv_text off = 100 len = 50 ).

            IF gv_instid IS INITIAL.
              print_error_otel( ).
              send_json_error( ).
              EXIT.
            ENDIF.

            me->append_slg1_log(
              EXPORTING
                iv_tabname    = space
                iv_message_v1 = 'Error - Parse data on SQL'
                iv_message_v2 = 'check structures'
                iv_message_v3 = space
                iv_mestyp     = 'E' ).

            me->update_slg1_log( it_log_ext = gt_log_ext ).

            RETURN.
          CATCH cx_sy_dynamic_osql_error INTO DATA(lo_sql).
            gs_elog-type = 'DYNAMIC_OSQL_ERROR'.
            gs_elog-message    = lo_sql->get_longtext( ).
            CALL METHOD lo_sql->get_source_position
              IMPORTING
                program_name = gv_prog
                source_line  = gv_sline.
            lv_text = lo_sql->get_longtext( ).

            gs_elog-severity   = gc_error.
            gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
            gs_elog-details-db = 'ZONCL_OC_BASE_HANDLER-GET_DATABASE_DATA'.
            gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

            gs_elog-metadata-error_code = gs_elog-details-error_code.
            interpret_message( EXPORTING iv_msgnr = '072' iv_msgv1 = ls_relations-tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '073' IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '074' IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '075' IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
            CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
            interpret_message( EXPORTING iv_msgnr = '076' iv_msgv1 = ls_relations-tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '065' IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '070' IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_fixes ).
            CONCATENATE gv_msg1 gv_msg2 gv_msg3 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.

            "DB FIX to stop out of bounds error
            lv_text1 = substring( val = lv_text off = 0   len = 50 ).
            lv_text2 = substring( val = lv_text off = 50  len = 50 ).
            lv_text3 = substring( val = lv_text off = 100 len = 50 ).

            IF gv_instid IS INITIAL.
              print_error_otel( ).
              send_json_error( ).
              EXIT.
            ENDIF.

            me->append_slg1_log(
              EXPORTING
                iv_tabname    = space
                iv_message_v1 = 'Error - Parse data on SQL'
                iv_message_v2 = 'check structures'
                iv_message_v3 = space
                iv_mestyp     = 'E' ).

            me->update_slg1_log( it_log_ext = gt_log_ext ).

            RETURN.
          CATCH cx_root INTO gx_text.
            gs_elog-type = 'TECHNICAL_ERROR'.
            gs_elog-message    = gx_text->get_longtext( ).
            CALL METHOD gx_text->get_source_position
              IMPORTING
                program_name = gv_prog
                source_line  = gv_sline.
            lv_text = gx_text->get_longtext( ).

            gs_elog-severity   = gc_error.
            gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
            gs_elog-details-db = 'ZONCL_OC_BASE_HANDLER-GET_DATABASE_DATA'.
            gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

            gs_elog-metadata-error_code = gs_elog-details-error_code.
            interpret_message( EXPORTING iv_msgnr = '072' iv_msgv1 = ls_relations-tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '073' IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '074' IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '075' IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
            CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
            interpret_message( EXPORTING iv_msgnr = '076' iv_msgv1 = ls_relations-tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '065' IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '070' IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_fixes ).
            CONCATENATE gv_msg1 gv_msg2 gv_msg3 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.

            "DB FIX to stop out of bounds error
            lv_text1 = substring( val = lv_text off = 0   len = 50 ).
            lv_text2 = substring( val = lv_text off = 50  len = 50 ).
            lv_text3 = substring( val = lv_text off = 100 len = 50 ).

            IF gv_instid IS INITIAL.
              print_error_otel( ).
              send_json_error( ).
              EXIT.
            ENDIF.


            me->append_slg1_log(
              EXPORTING
                iv_tabname    = space
                iv_message_v1 = 'Error - Parse data on SQL'
                iv_message_v2 = 'check structures'
                iv_message_v3 = space
                iv_mestyp     = 'E' ).

            me->update_slg1_log( it_log_ext = gt_log_ext ).

            RETURN.
        ENDTRY.
      ENDIF.

* INNER adjustment March 2026
      IF sy-subrc = 4 AND ls_relations-join_type = lc_inner.
        " REFRESH gt_datat[].
        CLEAR <fs_table>.
        " EXIT.
        CONTINUE.
      ENDIF.

      "--------------------------------------------------
      " Clone and store table (memory safe)
      "--------------------------------------------------
      IF <fs_table> IS NOT INITIAL.

        CREATE DATA lo_table_copy LIKE <fs_table>.
        ASSIGN lo_table_copy->* TO <fs_table_copy>.
        <fs_table_copy> = <fs_table>.

*****
        DATA lv_size TYPE i.

        CLEAR lv_size.
        IF <fs_table> IS ASSIGNED.
          lv_size = lines(  <fs_table> ).
        ELSE.
          lv_size = 0.
        ENDIF.
        set_log_json_result( EXPORTING iv_tabname = ls_relations-tabname iv_size = lv_size ).
*****

        READ TABLE gt_datat ASSIGNING <fs_existing>
             WITH KEY tabname = ls_relations-tabname.

        IF sy-subrc = 0 AND <fs_existing>-lo_table IS NOT INITIAL.
          "Existing entry → append data to same internal table
          ASSIGN <fs_existing>-lo_table->* TO <fs_existing_tab>.
          ASSIGN lo_table_copy->*          TO <fs_new_tab>.

          IF <fs_existing_tab> IS ASSIGNED
             AND <fs_new_tab> IS ASSIGNED
             AND <fs_new_tab> IS NOT INITIAL.

            INSERT LINES OF <fs_new_tab> INTO TABLE <fs_existing_tab>.

          ENDIF.
        ELSE.
          APPEND INITIAL LINE TO gt_datat ASSIGNING FIELD-SYMBOL(<fs_datat>).
          <fs_datat>-tabname  = ls_relations-tabname.
          <fs_datat>-lo_table = lo_table_copy.
        ENDIF.

        READ TABLE lt_datat_tmp ASSIGNING <fs_existing>
            WITH KEY tabname = ls_relations-tabname.

        IF sy-subrc = 0 AND <fs_existing>-lo_table IS NOT INITIAL.
          "Existing entry → append data to same internal table
          ASSIGN <fs_existing>-lo_table->* TO <fs_existing_tab>.
          ASSIGN lo_table_copy->*          TO <fs_new_tab>.

          IF <fs_existing_tab> IS ASSIGNED
             AND <fs_new_tab> IS ASSIGNED
             AND <fs_new_tab> IS NOT INITIAL.

            INSERT LINES OF <fs_new_tab> INTO TABLE <fs_existing_tab>.

          ENDIF.
        ELSE.

          APPEND INITIAL LINE TO lt_datat_tmp ASSIGNING <fs_datat>.
          <fs_datat>-tabname  = ls_relations-tabname.
          <fs_datat>-lo_table = lo_table_copy.

        ENDIF.

        FREE <fs_table>.
      ELSE.
        READ TABLE gt_datat ASSIGNING <fs_existing>
             WITH KEY tabname = ls_relations-tabname.

        IF sy-subrc NE 0.
          APPEND INITIAL LINE TO gt_datat ASSIGNING <fs_datat>.
          <fs_datat>-tabname  = ls_relations-tabname.

          APPEND INITIAL LINE TO lt_datat_tmp ASSIGNING <fs_datat>.
          <fs_datat>-tabname  = ls_relations-tabname.
        ENDIF.
      ENDIF.

    ENDLOOP.
    REFRESH lt_datat_tmp[].
  ENDDO.


ENDMETHOD.


METHOD get_database_datat_open_imm.



  CONSTANTS lc_comilla TYPE c LENGTH 1 VALUE ''''.

  DATA:
    lv_fields             TYPE string,
    lo_msg                TYPE REF TO cx_root,
    lv_del_where          TYPE string,
    lv_result             TYPE string,
    lv_error(200)         TYPE c,
    lv_where              TYPE zonttrsdswhere,
    lv_tabname            TYPE string,
    lv_is_cds_entity      TYPE abap_bool,
    lt_fields             TYPE TABLE OF line,
    lt_relations          TYPE STANDARD TABLE OF zonta_relations,
    ls_relations          TYPE zonta_relations,
    ls_relations2         TYPE zonta_relations,
    lt_datat_tmp          TYPE STANDARD TABLE OF ty_datat,
    ls_datat              TYPE ty_datat,
    lo_table              TYPE REF TO data,
    lo_table_for_all      TYPE REF TO data,
    lo_table_for_all2     TYPE REF TO data,
    lo_table_for_all_back TYPE REF TO data,
    lo_ref                TYPE REF TO cx_sy_dynamic_osql_syntax,
    lv_text               TYPE string,
    lv_text1              TYPE string,
    lv_text2              TYPE string,
    lv_text3              TYPE string,
    v_tryoff              TYPE c,
    lo_table_copy         TYPE REF TO data,
    lv_cursor             TYPE cursor,
    lv_pakage             TYPE i,
    lv_lpakage            TYPE zonta_oc_param-low,
    lv_count              TYPE i.

  FIELD-SYMBOLS:
    <fs_table>              TYPE ANY TABLE,
    <fs_table_for_all>      TYPE STANDARD TABLE,
    <fs_table_for_all2>     TYPE STANDARD TABLE,
    <fs_table_for_all_back> TYPE STANDARD TABLE,
    <fs_table_copy>         TYPE ANY TABLE,
    <fs_existing>           TYPE ty_datat,
    <fs_existing_tab>       TYPE ANY TABLE,
    <fs_new_tab>            TYPE ANY TABLE.

**********************************************************************
  DATA: lr_kdoc  TYPE REF TO zoncl_oc_kdoc_handler,
        lr_table TYPE REF TO zoncl_oc_table_handler.

  IF gv_sending = c_kdoc.
    lr_kdoc ?= ir_hdl.
  ELSE.
    lr_table ?= ir_hdl.
  ENDIF.

**********************************************************************

  "--------------------------------------------------
  " Read TRY OFF flag once
  "--------------------------------------------------
  SELECT SINGLE low
    INTO v_tryoff
    FROM zonta_oc_param
    WHERE name = 'SET_TRY_OFF'.

  "--------------------------------------------------
  " Read PAKAGE for OPEN CURSOR
  "--------------------------------------------------
  SELECT SINGLE low
    INTO lv_lpakage
    FROM zonta_oc_param
    WHERE name = 'OPEN_CURSOR_OFFSET'.
  IF sy-subrc = 0.
    lv_pakage = lv_lpakage.
  ELSE.
    lv_pakage = gs_oc_obj-no_registros.
  ENDIF.
  "--------------------------------------------------
  " Prepare helper tables
  "--------------------------------------------------
  lo_table_for_all      = me->set_table( iv_add_tabname = abap_true ).
  lo_table_for_all2     = me->set_table( iv_add_tabname = abap_true ).
  lo_table_for_all_back = me->set_table( iv_add_tabname = abap_true ).

  ASSIGN lo_table_for_all->*      TO <fs_table_for_all>.
  ASSIGN lo_table_for_all2->*     TO <fs_table_for_all2>.
  ASSIGN lo_table_for_all_back->* TO <fs_table_for_all_back>.

  lt_relations = gt_relations.
  SORT lt_relations BY sequence.
  DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING sequence.

  me->build_root_filters( CHANGING ct_filters = gt_cond_tab ).



  READ TABLE lt_relations INTO ls_relations WITH KEY sequence = 1.

* New code for open
  lv_where         = me->get_where( iv_tabname = ls_relations-tabname ).

  lo_table = me->set_table( iv_add_tabname = abap_true ).
  ASSIGN lo_table->* TO <fs_table>.

  CALL METHOD me->set_fields_both
    EXPORTING
      iv_tabname = ls_relations-tabname
    IMPORTING
      ev_fields  = lv_fields
      et_fields  = lt_fields[].

* Begin of insert DB 04.29.2026
  IF gv_delete = abap_true.
    IF gv_sending = c_kdoc.
      lr_kdoc->get_data_kdoc( ).
    ELSE.
      lr_table->get_data_tablet(  ).
    ENDIF.
  ELSE.
* End of Insert DB 04.29.2026

* OPEN CURSOR WITH HOLD lv_cursor FOR SELECT (lv_fields)  FROM (ls_relations-tabname) WHERE (lv_where).
    IF lv_where IS NOT INITIAL.
      OPEN CURSOR WITH HOLD @lv_cursor FOR SELECT (lt_fields)  FROM (ls_relations-tabname) WHERE (lv_where).
    ENDIF.


    CLEAR lv_count.
    DO.
      lv_count = lv_count + 1.
      TRY.
          FETCH NEXT CURSOR @lv_cursor
            INTO CORRESPONDING FIELDS OF TABLE @<fs_table> PACKAGE SIZE @lv_pakage.
          IF sy-subrc NE 0.
            CLOSE CURSOR @lv_cursor.
            IF lv_count = 1.
              MESSAGE i000(fb) WITH 'No data found'.

              me->append_slg1_log(
                EXPORTING
                  iv_tabname    = space
                  iv_message_v1 = 'No data found'
                  iv_message_v2 = space
                  iv_message_v3 = space
                  iv_mestyp     = 'S' ).

            ENDIF.
            EXIT.
          ENDIF.


          LOOP AT lt_relations INTO ls_relations.

            IF ls_relations-parent_relation IS NOT INITIAL.
              lv_is_cds_entity = me->is_cds_entity( ls_relations-tabname ).
              lv_where         = me->get_where( iv_tabname = ls_relations-tabname ).

              "--------------------------------------------------
              " Create WORK table per iteration
              "--------------------------------------------------
              lo_table = me->set_table( iv_add_tabname = abap_true ).
              ASSIGN lo_table->* TO <fs_table>.

              CALL METHOD me->set_fields_both
                EXPORTING
                  iv_tabname = ls_relations-tabname
                IMPORTING
                  ev_fields  = lv_fields
                  et_fields  = lt_fields[].
            ENDIF.

            TRY.
                IF ls_relations-parent_relation IS NOT INITIAL.

                  REFRESH <fs_table_for_all>.
                  FREE <fs_table_for_all>.

                  LOOP AT lt_datat_tmp INTO ls_datat WHERE tabname = ls_relations-parent_relation.

                    lo_table_for_all2 = ls_datat-lo_table.
                    ASSIGN lo_table_for_all2->* TO <fs_table_for_all2>.

                    APPEND LINES OF <fs_table_for_all2> TO <fs_table_for_all>.

                  ENDLOOP.

                  IF <fs_table_for_all> IS NOT INITIAL.

                    IF abap_false = lv_is_cds_entity.
                      SELECT (lv_fields)
                        INTO CORRESPONDING FIELDS OF TABLE <fs_table>
                        FROM (ls_relations-tabname)
                        FOR ALL ENTRIES IN <fs_table_for_all>
                        WHERE (lv_where).
                    ELSE.
                      SELECT (lt_fields)
                        FROM (ls_relations-tabname)
                        FOR ALL ENTRIES IN @<fs_table_for_all>
                        WHERE (lv_where)
                        INTO CORRESPONDING FIELDS OF TABLE @<fs_table>.
                    ENDIF.

                  ELSE.
                    sy-subrc = 4.
                  ENDIF.

                ENDIF.

              CATCH cx_sy_dynamic_osql_semantics INTO DATA(lo_ref1).
                IF v_tryoff IS NOT INITIAL.
                  IF lo_ref1->previous IS NOT INITIAL.
                    RAISE EXCEPTION lo_ref1->previous.
                  ELSE.
                    RAISE EXCEPTION lo_ref1.
                  ENDIF.
                ENDIF.

                gs_elog-type       = 'DYNAMIC_OSQL_SEMANTICS'.
                gs_elog-message    = lo_ref1->get_longtext( ).
                CALL METHOD lo_ref1->get_source_position
                  IMPORTING
                    program_name = gv_prog
                    source_line  = gv_sline.
                lv_text = lo_ref1->get_longtext( ).
                gs_elog-severity   = gc_error.
                gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
                gs_elog-details-db = 'ZONCL_OC_BASE_HANDLER-GET_DATABASE_DATA'.
                gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

                gs_elog-metadata-error_code = gs_elog-details-error_code.
                interpret_message( EXPORTING iv_msgnr = '072' iv_msgv1 = ls_relations-tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
                interpret_message( EXPORTING iv_msgnr = '073' IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
                interpret_message( EXPORTING iv_msgnr = '074' IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
                interpret_message( EXPORTING iv_msgnr = '075' IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
                CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
                interpret_message( EXPORTING iv_msgnr = '076' iv_msgv1 = ls_relations-tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
                interpret_message( EXPORTING iv_msgnr = '065' IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_fixes ).
                interpret_message( EXPORTING iv_msgnr = '070' IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_fixes ).
                CONCATENATE gv_msg1 gv_msg2 gv_msg3 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.

                "DB FIX to stop out of bounds error
                lv_text1 = substring( val = lv_text off = 0   len = 50 ).
                lv_text2 = substring( val = lv_text off = 50  len = 50 ).
                lv_text3 = substring( val = lv_text off = 100 len = 50 ).

                IF gv_instid IS INITIAL.
                  print_error_otel( ).
                  send_json_error( ).
                  EXIT.
                ENDIF.

                me->append_slg1_log(
                  EXPORTING
                    iv_tabname    = space
                    iv_message_v1 = 'Error - Parse data on SQL'
                    iv_message_v2 = 'check structures'
                    iv_message_v3 = space
                    iv_mestyp     = 'E' ).

                me->update_slg1_log( it_log_ext = gt_log_ext ).

                RETURN.
              CATCH cx_sy_dynamic_osql_error INTO DATA(lo_sql).

                IF v_tryoff IS NOT INITIAL.
                  IF lo_sql->previous IS NOT INITIAL.
                    RAISE EXCEPTION lo_sql->previous.
                  ELSE.
                    RAISE EXCEPTION lo_sql.
                  ENDIF.
                ENDIF.

                gs_elog-type = 'DYNAMIC_OSQL_ERROR'.
                gs_elog-message    = lo_sql->get_longtext( ).
                CALL METHOD lo_sql->get_source_position
                  IMPORTING
                    program_name = gv_prog
                    source_line  = gv_sline.
                lv_text = lo_sql->get_longtext( ).

                gs_elog-severity   = gc_error.
                gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
                gs_elog-details-db = 'ZONCL_OC_BASE_HANDLER-GET_DATABASE_DATA'.
                gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

                gs_elog-metadata-error_code = gs_elog-details-error_code.
                interpret_message( EXPORTING iv_msgnr = '072' iv_msgv1 = ls_relations-tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
                interpret_message( EXPORTING iv_msgnr = '073' IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
                interpret_message( EXPORTING iv_msgnr = '074' IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
                interpret_message( EXPORTING iv_msgnr = '075' IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
                CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
                interpret_message( EXPORTING iv_msgnr = '076' iv_msgv1 = ls_relations-tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
                interpret_message( EXPORTING iv_msgnr = '065' IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_fixes ).
                interpret_message( EXPORTING iv_msgnr = '070' IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_fixes ).
                CONCATENATE gv_msg1 gv_msg2 gv_msg3 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.

                "DB FIX to stop out of bounds error
                lv_text1 = substring( val = lv_text off = 0   len = 50 ).
                lv_text2 = substring( val = lv_text off = 50  len = 50 ).
                lv_text3 = substring( val = lv_text off = 100 len = 50 ).

                IF gv_instid IS INITIAL.
                  print_error_otel( ).
                  send_json_error( ).
                  EXIT.
                ENDIF.

                me->append_slg1_log(
                  EXPORTING
                    iv_tabname    = space
                    iv_message_v1 = 'Error - Parse data on SQL'
                    iv_message_v2 = 'check structures'
                    iv_message_v3 = space
                    iv_mestyp     = 'E' ).

                me->update_slg1_log( it_log_ext = gt_log_ext ).

                RETURN.
              CATCH cx_root INTO gx_text.
                IF v_tryoff IS NOT INITIAL.
                  IF gx_text->previous IS NOT INITIAL.
                    RAISE EXCEPTION gx_text->previous.
                  ELSE.
                    RAISE EXCEPTION gx_text.
                  ENDIF.
                ENDIF.

                gs_elog-type = 'TECHNICAL_ERROR'.
                gs_elog-message    = gx_text->get_longtext( ).
                CALL METHOD gx_text->get_source_position
                  IMPORTING
                    program_name = gv_prog
                    source_line  = gv_sline.
                lv_text = gx_text->get_longtext( ).

                gs_elog-severity   = gc_error.
                gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
                gs_elog-details-db = 'ZONCL_OC_BASE_HANDLER-GET_DATABASE_DATA'.
                gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

                gs_elog-metadata-error_code = gs_elog-details-error_code.
                interpret_message( EXPORTING iv_msgnr = '072' iv_msgv1 = ls_relations-tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
                interpret_message( EXPORTING iv_msgnr = '073' IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
                interpret_message( EXPORTING iv_msgnr = '074' IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
                interpret_message( EXPORTING iv_msgnr = '075' IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
                CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
                interpret_message( EXPORTING iv_msgnr = '076' iv_msgv1 = ls_relations-tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
                interpret_message( EXPORTING iv_msgnr = '065' IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_fixes ).
                interpret_message( EXPORTING iv_msgnr = '070' IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_fixes ).
                CONCATENATE gv_msg1 gv_msg2 gv_msg3 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.

                "DB FIX to stop out of bounds error
                lv_text1 = substring( val = lv_text off = 0   len = 50 ).
                lv_text2 = substring( val = lv_text off = 50  len = 50 ).
                lv_text3 = substring( val = lv_text off = 100 len = 50 ).

                IF gv_instid IS INITIAL.
                  print_error_otel( ).
                  send_json_error( ).
                  EXIT.
                ENDIF.

                me->append_slg1_log(
                  EXPORTING
                    iv_tabname    = space
                    iv_message_v1 = 'Error - Parse data on SQL'
                    iv_message_v2 = 'check structures'
                    iv_message_v3 = space
                    iv_mestyp     = 'E' ).

                me->update_slg1_log( it_log_ext = gt_log_ext ).

                RETURN.
            ENDTRY.
*      ENDIF.

            "--------------------------------------------------
            " Clone and store table (memory safe)
            "--------------------------------------------------
            IF <fs_table> IS NOT INITIAL.

              CREATE DATA lo_table_copy LIKE <fs_table>.
              ASSIGN lo_table_copy->* TO <fs_table_copy>.
              <fs_table_copy> = <fs_table>.

*****
              DATA lv_size TYPE i.

              CLEAR lv_size.
              IF <fs_table> IS ASSIGNED.
                lv_size = lines(  <fs_table> ).
              ELSE.
                lv_size = 0.
              ENDIF.
              set_log_json_result( EXPORTING iv_tabname = ls_relations-tabname iv_size = lv_size ).
*****

              READ TABLE gt_datat ASSIGNING <fs_existing>
                   WITH KEY tabname = ls_relations-tabname.

              IF sy-subrc = 0 AND <fs_existing>-lo_table IS NOT INITIAL.
                "Existing entry → append data to same internal table
                ASSIGN <fs_existing>-lo_table->* TO <fs_existing_tab>.
                ASSIGN lo_table_copy->*          TO <fs_new_tab>.

                IF <fs_existing_tab> IS ASSIGNED
                   AND <fs_new_tab> IS ASSIGNED
                   AND <fs_new_tab> IS NOT INITIAL.

                  INSERT LINES OF <fs_new_tab> INTO TABLE <fs_existing_tab>.

                ENDIF.
              ELSE.
                APPEND INITIAL LINE TO gt_datat ASSIGNING FIELD-SYMBOL(<fs_datat>).
                <fs_datat>-tabname  = ls_relations-tabname.
                <fs_datat>-lo_table = lo_table_copy.

                APPEND INITIAL LINE TO lt_datat_tmp ASSIGNING <fs_datat>.
                <fs_datat>-tabname  = ls_relations-tabname.
                <fs_datat>-lo_table = lo_table_copy.
              ENDIF.
              FREE <fs_table>.
            ELSE.
              READ TABLE gt_datat ASSIGNING <fs_existing>
                   WITH KEY tabname = ls_relations-tabname.

              IF sy-subrc NE 0.
                APPEND INITIAL LINE TO gt_datat ASSIGNING <fs_datat>.
                <fs_datat>-tabname  = ls_relations-tabname.

                APPEND INITIAL LINE TO lt_datat_tmp ASSIGNING <fs_datat>.
                <fs_datat>-tabname  = ls_relations-tabname.
              ENDIF.
            ENDIF.

          ENDLOOP.
          REFRESH lt_datat_tmp[].

**********************************************************************

          DATA lv_message_v2     TYPE string.

          READ TABLE gt_datat INDEX 1 INTO ls_datat.
          IF ls_datat-lo_table IS INITIAL.
            IF gv_instid IS INITIAL.
              MESSAGE i000(fb) WITH 'No data found'.
            ENDIF.

            lv_message_v2 = gv_instid.

            me->append_slg1_log(
              iv_tabname    = space
              iv_message_v1 = 'No data found for'
              iv_message_v2 = lv_message_v2
              iv_mestyp     = 'S' ).

            me->update_slg1_log( it_log_ext = gt_log_ext ).
          ENDIF.

          READ TABLE gt_datat INTO ls_datat INDEX 1.
          IF sy-subrc = 0.
            lo_table = ls_datat-lo_table.
            ASSIGN lo_table->* TO <fs_table>.
          ENDIF.

          IF <fs_table> IS ASSIGNED.
            IF gv_update = abap_true AND <fs_table> IS INITIAL.
              RETURN.
            ENDIF.
          ENDIF.

          gv_tm = 'X'.

          IF gv_sending = c_kdoc.
            lr_kdoc->get_data_kdoc( ).
          ELSE.
            lr_table->get_data_tablet(  ).
          ENDIF.

          CLEAR gt_datat.
**********************************************************************
        CATCH cx_root INTO gx_text.
          IF v_tryoff IS NOT INITIAL.
            IF gx_text->previous IS NOT INITIAL.
              RAISE EXCEPTION gx_text->previous.
            ELSE.
              RAISE EXCEPTION gx_text.
            ENDIF.
          ENDIF.

          gs_elog-type = 'TECHNICAL_ERROR'.
          gs_elog-message    = gx_text->get_longtext( ).
          CALL METHOD gx_text->get_source_position
            IMPORTING
              program_name = gv_prog
              source_line  = gv_sline.
          gs_elog-severity   = gc_error.
          gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
          gs_elog-details-db = 'ZONCL_OC_BASE_HANDLER-GET_DATABASE_DATA_OPEN_IMM'.
          gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

          gs_elog-metadata-error_code = gs_elog-details-error_code.
          interpret_message( EXPORTING iv_msgnr = '126' IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
          gs_elog-metadata-possible_cause = gv_msg1.
          interpret_message( EXPORTING iv_msgnr = '126' IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
          gs_elog-metadata-possible_fix = gv_msg1.
          RETURN.
      ENDTRY.
    ENDDO.
  ENDIF.  "++DB 04.29.2026

  IF cl_system_transaction_state=>get_in_update_task( ) = abap_false.
    COMMIT WORK .
  ENDIF.

ENDMETHOD.


  METHOD get_data_by_table.

    DATA: fname              TYPE string,
          lv_pos1            TYPE i,
          ls_dyn_fcat        TYPE lvc_s_fcat,
          lt_dyn_fcat        TYPE lvc_t_fcat,
          lt_dyn_fcat_json   TYPE lvc_t_fcat,
          lt_columns         TYPE STANDARD TABLE OF zonta_oc_col_all,
          lt_components      TYPE abap_component_tab,
          lt_dfies_tab       TYPE STANDARD TABLE OF dfies,
          lv_field           TYPE dfies-fieldname,
          lv_parent_relation TYPE zonde_parentrel,
          lt_dyn_table       TYPE REF TO data,
          lo_tdescr          TYPE REF TO cl_abap_tabledescr,
          lo_sdescr          TYPE REF TO cl_abap_structdescr,
          cl_wwarea          TYPE REF TO cl_abap_typedescr,
          lv_name            TYPE string,
          lv_temptable       TYPE string,
          lv_indexm          TYPE string,
          w_tadir1           TYPE tadir.

    FIELD-SYMBOLS: <fs_relations>     TYPE zonta_relations,
                   <fs_dfies_tab_add> TYPE dfies,
                   <fs_columns>       TYPE zonta_oc_col_all,
                   <fs_component>     LIKE LINE OF lt_components,
                   <fs_dyn_table>     TYPE STANDARD TABLE.


    IF iv_parent_relation IS INITIAL.
      lv_parent_relation = iv_table.
    ENDIF.

* Process only main field from gt_relations
    LOOP AT gt_relations ASSIGNING <fs_relations> WHERE tabname = iv_table.
      READ TABLE gt_dfies_tab_cat WITH KEY tabname = <fs_relations>-tabname fieldname = <fs_relations>-field_main ASSIGNING <fs_dfies_tab_add>.
      IF sy-subrc = 0.
        CLEAR ls_dyn_fcat.
        ls_dyn_fcat-fieldname = <fs_dfies_tab_add>-fieldname.
        ls_dyn_fcat-tabname   = <fs_dfies_tab_add>-tabname.
        ls_dyn_fcat-coltext   = <fs_dfies_tab_add>-scrtext_l.
        ls_dyn_fcat-col_pos   = <fs_dfies_tab_add>-position.
        ls_dyn_fcat-key       = abap_true.
        ls_dyn_fcat-datatype  = <fs_dfies_tab_add>-datatype.

        APPEND ls_dyn_fcat TO lt_dyn_fcat.

**revisar 1702
**        IF NOT line_exists( lt_dyn_fcat_json[ fieldname = ls_dyn_fcat-fieldname tabname = ls_dyn_fcat-tabname ] ).
**          APPEND ls_dyn_fcat TO lt_dyn_fcat_json.
**        ENDIF.
        " Check if the line exists using the older READ TABLE syntax
        READ TABLE lt_dyn_fcat_json TRANSPORTING NO FIELDS
          WITH KEY fieldname = ls_dyn_fcat-fieldname
                   tabname   = ls_dyn_fcat-tabname.
        IF sy-subrc <> 0.
          APPEND ls_dyn_fcat TO lt_dyn_fcat_json.
        ENDIF.

      ENDIF.
    ENDLOOP.

* Only include columns from current table
    lt_columns = gt_columns_all.
    DELETE lt_columns WHERE tabname <> iv_table.

* Use gt_dfies_tab_cat to build structure
    LOOP AT lt_columns ASSIGNING <fs_columns>.
      TRANSLATE <fs_columns>-fldname TO UPPER CASE.
      READ TABLE gt_dfies_tab_cat WITH KEY tabname = <fs_columns>-tabname fieldname = <fs_columns>-fldname ASSIGNING <fs_dfies_tab_add>.
      IF sy-subrc = 0.
        CLEAR ls_dyn_fcat.
        ls_dyn_fcat-fieldname = <fs_dfies_tab_add>-fieldname.
        ls_dyn_fcat-tabname   = <fs_dfies_tab_add>-tabname.
        ls_dyn_fcat-coltext   = <fs_columns>-description_field.
        ls_dyn_fcat-col_pos   = <fs_dfies_tab_add>-position.
        ls_dyn_fcat-key       = <fs_dfies_tab_add>-keyflag.
        ls_dyn_fcat-datatype  = <fs_dfies_tab_add>-datatype.
        ls_dyn_fcat-decimals  = <fs_dfies_tab_add>-decimals.  "DECIMALS


**revisar 1702
**        IF NOT line_exists( lt_dyn_fcat[ fieldname = <fs_columns>-fldname ] ).
**          APPEND ls_dyn_fcat TO lt_dyn_fcat.
**        ENDIF.

        READ TABLE lt_dyn_fcat TRANSPORTING NO FIELDS WITH KEY fieldname = <fs_columns>-fldname.
        IF sy-subrc <> 0.
          APPEND ls_dyn_fcat TO lt_dyn_fcat.
        ENDIF.

**revisar 1702
**        IF NOT line_exists( lt_dyn_fcat_json[ fieldname = <fs_columns>-fldname tabname = <fs_columns>-tabname ] ).
**          APPEND ls_dyn_fcat TO lt_dyn_fcat_json.
**        ENDIF.
        READ TABLE lt_dyn_fcat_json TRANSPORTING NO FIELDS WITH KEY fieldname = <fs_columns>-fldname tabname = <fs_columns>-tabname.
        IF sy-subrc <> 0.
          APPEND ls_dyn_fcat TO lt_dyn_fcat_json.
        ENDIF.


      ENDIF.
    ENDLOOP.

* Add event ID fields if required
    IF gs_oc_obj-eventid EQ abap_true OR gs_oc_obj-metadata EQ abap_true.
      CALL FUNCTION 'DDIF_FIELDINFO_GET'
        EXPORTING
          tabname   = 'ZONST_OC_EVENTID'
        TABLES
          dfies_tab = lt_dfies_tab.

      IF gs_oc_obj-eventid = abap_false.
        DELETE lt_dfies_tab WHERE fieldname = 'OBJECTID' OR fieldname = 'EVENTID'
                               OR fieldname = 'OBJECTIDEVT' OR fieldname = 'EVENTIDEVT' .
      ENDIF.

      IF gs_oc_obj-metadata = abap_false.
        DELETE lt_dfies_tab WHERE fieldname CP 'TAG*'.
      ENDIF.

      APPEND LINES OF lt_dfies_tab TO gt_dfies_tab_cat.

      LOOP AT lt_dfies_tab ASSIGNING <fs_dfies_tab_add> WHERE fieldname NE 'MANDT'.
**revisar 1702
**        IF NOT line_exists( lt_dyn_fcat[ fieldname = <fs_dfies_tab_add>-fieldname ] ).
        READ TABLE lt_dyn_fcat TRANSPORTING NO FIELDS WITH KEY fieldname = <fs_dfies_tab_add>-fieldname.
        IF sy-subrc <> 0.
          CLEAR ls_dyn_fcat.
          ls_dyn_fcat-fieldname = <fs_dfies_tab_add>-fieldname.
          ls_dyn_fcat-tabname   = <fs_dfies_tab_add>-tabname.
          ls_dyn_fcat-coltext   = <fs_dfies_tab_add>-scrtext_l.
          ls_dyn_fcat-col_pos   = <fs_dfies_tab_add>-position.
          ls_dyn_fcat-key       = <fs_dfies_tab_add>-keyflag.
          ls_dyn_fcat-datatype  = <fs_dfies_tab_add>-datatype.
          ls_dyn_fcat-decimals  = <fs_dfies_tab_add>-decimals.  "DECIMALS

          APPEND ls_dyn_fcat TO lt_dyn_fcat.

**revisar 1702
**          IF NOT line_exists( lt_dyn_fcat_json[ fieldname = <fs_dfies_tab_add>-fieldname tabname = <fs_dfies_tab_add>-tabname ] ).
          READ TABLE lt_dyn_fcat_json TRANSPORTING NO FIELDS WITH KEY fieldname = <fs_dfies_tab_add>-fieldname tabname = <fs_dfies_tab_add>-tabname.
          IF sy-subrc <> 0.
            APPEND ls_dyn_fcat TO lt_dyn_fcat_json.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

* Begin of insert DBFIX 08/11
    READ TABLE lt_columns TRANSPORTING NO FIELDS WITH KEY positionf = space.
    IF sy-subrc = 0.
      SORT lt_columns BY positionf DESCENDING.
      READ TABLE lt_columns ASSIGNING <fs_columns> INDEX 1.
      lv_indexm = <fs_columns>-positionf.
      lv_indexm = lv_indexm + 1.
      LOOP AT lt_columns ASSIGNING <fs_columns> WHERE positionf = space.
        <fs_columns>-positionf = lv_indexm.
        lv_indexm = lv_indexm + 1.
      ENDLOOP.
    ENDIF.
* End of insert DBFIX 08/11

    TRY.
* Generate dynamic structure
        IF gv_alias = abap_true.
          SORT lt_columns BY positionf.
          LOOP AT lt_columns ASSIGNING <fs_columns>.
            LOOP AT lt_dyn_fcat_json INTO ls_dyn_fcat WHERE tabname = <fs_columns>-tabname AND fieldname = <fs_columns>-fldname.
              APPEND INITIAL LINE TO lt_components ASSIGNING <fs_component>.
              lv_temptable = <fs_columns>-tabname.
**revisar 1702
**              <fs_component>-name = cond STRING( WHEN <fs_columns>-alias_fldname IS NOT INITIAL THEN <fs_columns>-alias_fldname ELSE ls_dyn_fcat-fieldname ).
              IF <fs_columns>-alias_fldname IS NOT INITIAL.
                <fs_component>-name = <fs_columns>-alias_fldname.
              ELSE.
                <fs_component>-name = ls_dyn_fcat-fieldname.
              ENDIF.

              CONCATENATE ls_dyn_fcat-tabname '-' ls_dyn_fcat-fieldname INTO lv_name.
              CALL METHOD cl_abap_elemdescr=>describe_by_name
                EXPORTING
                  p_name      = lv_name
                RECEIVING
                  p_descr_ref = cl_wwarea.
              <fs_component>-type ?= cl_wwarea.
            ENDLOOP.
          ENDLOOP.

          LOOP AT lt_dyn_fcat_json INTO ls_dyn_fcat WHERE tabname NE lv_temptable.
            APPEND INITIAL LINE TO lt_components ASSIGNING <fs_component>.
            READ TABLE lt_columns ASSIGNING <fs_columns> WITH KEY tabname = ls_dyn_fcat-tabname fldname = ls_dyn_fcat-fieldname BINARY SEARCH.

**revisar 1702
**            <fs_component>-name = cond STRING( WHEN sy-subrc = 0 THEN <fs_columns>-alias_fldname ELSE ls_dyn_fcat-fieldname ).
            IF sy-subrc = 0.
              <fs_component>-name = <fs_columns>-alias_fldname.
            ELSE.
              <fs_component>-name = ls_dyn_fcat-fieldname.
            ENDIF.
            CONCATENATE ls_dyn_fcat-tabname '-' ls_dyn_fcat-fieldname INTO lv_name.
            CALL METHOD cl_abap_elemdescr=>describe_by_name
              EXPORTING
                p_name      = lv_name
              RECEIVING
                p_descr_ref = cl_wwarea.
            <fs_component>-type ?= cl_wwarea.
          ENDLOOP.

          DELETE lt_components WHERE name IS INITIAL OR type IS INITIAL.
          lo_sdescr = cl_abap_structdescr=>create( lt_components ).
          lo_tdescr = cl_abap_tabledescr=>create( lo_sdescr ).
          CREATE DATA lt_dyn_table TYPE HANDLE lo_tdescr.
        ELSE.
          LOOP AT gt_relations ASSIGNING <fs_relations> WHERE tabname = iv_table.
            READ TABLE lt_columns WITH KEY tabname = <fs_relations>-tabname alias_tabname = <fs_relations>-alias_tabname INTO <fs_columns>.
*            fname = 'ZON' && <fs_columns>-id_column && 'TT' && 'SEQ' && <fs_relations>-sequence. "change 2801
            fname = 'ZON' && <fs_relations>-id && 'TT' && 'SEQ' && <fs_relations>-sequence.

            SELECT SINGLE * FROM tadir INTO w_tadir1 WHERE obj_name = fname.
            IF sy-subrc NE 0.
              CLEAR fname.
*              fname = 'ZON' && <fs_columns>-id_column+3(3) && 'TT' && 'SEQ' && <fs_relations>-sequence. Change 2801
              fname = 'ZON' && <fs_relations>-id+3(3) && 'TT' && 'SEQ' && <fs_relations>-sequence.
            ENDIF.
          ENDLOOP.
          CREATE DATA lt_dyn_table TYPE (fname).
        ENDIF.

*      CATCH cx_sy_create_data_error INTO data(lx_create).
       data lx_create TYPE REF TO cx_sy_create_data_error.
       CATCH cx_sy_create_data_error INTO lx_create.
        " Type does not exist / not active
        gs_elog-type       = 'CREATING_REF_TABLE'.
        gs_elog-severity   = gc_error.
        gs_elog-message    = lx_create->get_longtext( ).
        CALL METHOD lx_create->get_source_position
          IMPORTING
            program_name = gv_prog
            source_line  = gv_sline.
        gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
        gs_elog-details-db = 'ZONCL_OC_BASE_HANDLER-GET_DATA_BY_TABLE'.
        gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

        gs_elog-metadata-error_code = gs_elog-details-error_code.
        interpret_message( EXPORTING iv_msgnr = '106' iv_msgv1 = fname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
        gs_elog-metadata-possible_cause = gv_msg1.
        interpret_message( EXPORTING iv_msgnr = '107' IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
        gs_elog-metadata-possible_fix = gv_msg1.

        print_error_otel( ).
        send_json_error( ).
        RETURN.

*      CATCH cx_sy_dyn_call_illegal_type INTO data(lx_illegal).
      data lx_illegal TYPE REF TO cx_sy_dyn_call_illegal_type .
      CATCH cx_sy_dyn_call_illegal_type INTO lx_illegal.
        " Invalid dynamic type name
        gs_elog-type       = 'CREATING_REF_TABLE'.
        gs_elog-severity   = gc_error.
        gs_elog-message    = lx_create->get_longtext( ).
        CALL METHOD lx_create->get_source_position
          IMPORTING
            program_name = gv_prog
            source_line  = gv_sline.
        gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
        gs_elog-details-db = 'ZONCL_OC_BASE_HANDLER-GET_DATA_BY_TABLE'.
        gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

        gs_elog-metadata-error_code = gs_elog-details-error_code.
        interpret_message( EXPORTING iv_msgnr = '108' iv_msgv1 = fname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
        gs_elog-metadata-possible_cause = gv_msg1.
        interpret_message( EXPORTING iv_msgnr = '107' IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
        gs_elog-metadata-possible_fix = gv_msg1.

        print_error_otel( ).
        send_json_error( ).
        RETURN.

    ENDTRY.

    TRY.
        ASSIGN lt_dyn_table->* TO <fs_dyn_table>.

*      CATCH cx_sy_ref_is_initial INTO data(lx_ref).
      data lx_ref TYPE REF TO cx_sy_ref_is_initial.
      CATCH cx_sy_ref_is_initial INTO lx_ref.
        " ASSIGN on initial ref
        gs_elog-type       = 'ASSIGNING_TABLE'.
        gs_elog-severity   = gc_error.
        gs_elog-message    = lx_create->get_longtext( ).
        CALL METHOD lx_create->get_source_position
          IMPORTING
            program_name = gv_prog
            source_line  = gv_sline.
        gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
        gs_elog-details-db = 'ZONCL_OC_BASE_HANDLER-GET_DATA_BY_TABLE'.
        gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

        gs_elog-metadata-error_code = gs_elog-details-error_code.
        interpret_message( EXPORTING iv_msgnr = '109' iv_msgv1 = fname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
        gs_elog-metadata-possible_cause = gv_msg1.
        interpret_message( EXPORTING iv_msgnr = '107' IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
        gs_elog-metadata-possible_fix = gv_msg1.

        print_error_otel( ).
        send_json_error( ).
        RETURN.

        RETURN.
    ENDTRY.

    et_data  = lt_dyn_table.
    et_fcat  = lt_dyn_fcat_json.


  ENDMETHOD.


  METHOD get_data_by_table_data.

    DATA: fname              TYPE ttypename,
          lv_parent_relation TYPE zonde_parentrel,
          lt_dyn_table       TYPE REF TO data.

    FIELD-SYMBOLS:
      <fs_relations>  TYPE zonta_relations,
      <fs_columns>    TYPE zonta_oc_col_all,
      <gfs_dyn_table> TYPE STANDARD TABLE.

    lv_parent_relation = iv_parent_relation.
    IF lv_parent_relation IS INITIAL.
      lv_parent_relation = iv_table.
    ENDIF.

    LOOP AT gt_relations ASSIGNING <fs_relations>
               WHERE tabname = iv_table.

* Change 2801
*      READ TABLE gt_columns_all
*        WITH KEY tabname       = <fs_relations>-tabname
*                 alias_tabname = <fs_relations>-alias_tabname
*        ASSIGNING <fs_columns>.
*
*      IF sy-subrc = 0 AND <fs_columns>-id_column IS NOT INITIAL.
*        fname = |ZON{ <fs_columns>-id_column }TTSEQ{ <fs_relations>-sequence }|. change 2801
      fname = |ZON{ <fs_relations>-id }TTSEQ{ <fs_relations>-sequence }|.
*      ENDIF.

    ENDLOOP.

* Create dynamic internal table
    CREATE DATA lt_dyn_table TYPE (fname).
    ASSIGN lt_dyn_table->* TO <gfs_dyn_table>.

    et_data = lt_dyn_table.

  ENDMETHOD.


  METHOD get_data_metadata.

    DATA: lt_fcat      TYPE lvc_t_fcat,
          lt_relations TYPE STANDARD TABLE OF zonta_relations,
          lv_tabname   TYPE string,
          lo_data      TYPE REF TO data.

    FIELD-SYMBOLS: <fs_metadata_chg>  TYPE STANDARD TABLE,
                   <fs_relations>     TYPE zonta_relations,
                   <fs_metadata>      TYPE any,
                   <fs_table>         TYPE any,
                   <fs_metadata_line> TYPE any.

    ASSIGN cs_metadata TO <fs_metadata_chg>.

    lt_relations = gt_relations.
    SORT lt_relations BY sequence.
    DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING sequence.

    LOOP AT lt_relations ASSIGNING <fs_relations>.

      lv_tabname = 'SEQ' && <fs_relations>-sequence.

      APPEND INITIAL LINE TO <fs_metadata_chg> ASSIGNING <fs_metadata>.

      ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_metadata> TO <fs_table>.
      <fs_table> = lv_tabname.
      TRANSLATE <fs_table> TO LOWER CASE.

      ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_metadata> TO <fs_metadata_line>.

      me->get_data_by_table(
        EXPORTING
          iv_parent_relation = <fs_relations>-parent_relation
          iv_table           = <fs_relations>-tabname
        IMPORTING
          et_fcat            = lt_fcat
          et_data            = lo_data
      ).


      me->set_metadata_node(
        EXPORTING
          it_fcat    = lt_fcat
          iv_tabname = <fs_relations>-tabname
        CHANGING
          cs_metadata = <fs_metadata_line>
      ).

    ENDLOOP.

  ENDMETHOD.


  METHOD get_data_properties.

    DATA: lv_dref_table TYPE REF TO data,
          lv_root       TYPE string,
          ls_relations  TYPE zonta_relations.

    FIELD-SYMBOLS: <fs>            TYPE any,
                   <fs_properties> TYPE any.

    IF gv_kdoc = abap_true.
      gv_messagetype = c_kdoc.
    ELSE.
      gv_messagetype = c_table.
    ENDIF.

    READ TABLE gt_relations INDEX 1 INTO ls_relations.

    IF gs_oc_obj-data = abap_true.
      lv_root = 'TY_PROPERTIES_META'.
    ELSE.
      lv_root = 'TY_PROPERTIES'.
    ENDIF.

    CREATE DATA lv_dref_table TYPE (lv_root).
    ASSIGN lv_dref_table->* TO <fs_properties>.

    ASSIGN COMPONENT 'MESSAGETYPE' OF STRUCTURE <fs_properties> TO <fs>. <fs> = gv_messagetype.
    ASSIGN COMPONENT 'CHANGE'      OF STRUCTURE <fs_properties> TO <fs>. <fs> = gv_update.
    ASSIGN COMPONENT 'DELETE'      OF STRUCTURE <fs_properties> TO <fs>. <fs> = gv_delete.
    ASSIGN COMPONENT 'DOMAIN'      OF STRUCTURE <fs_properties> TO <fs>. <fs> = gv_domainv.
    ASSIGN COMPONENT 'ENTITY'      OF STRUCTURE <fs_properties> TO <fs>. <fs> = gv_entity.
    ASSIGN COMPONENT 'DESCRIPTION' OF STRUCTURE <fs_properties> TO <fs>. <fs> = gs_oc_obj-description.

    IF gs_oc_obj-data = abap_true.
      ASSIGN COMPONENT 'TAG1' OF STRUCTURE <fs_properties> TO <fs>. <fs> = gs_oc_obj-tag1.
      ASSIGN COMPONENT 'TAG2' OF STRUCTURE <fs_properties> TO <fs>. <fs> = gs_oc_obj-tag2.
      ASSIGN COMPONENT 'TAG3' OF STRUCTURE <fs_properties> TO <fs>. <fs> = gs_oc_obj-tag3.
      ASSIGN COMPONENT 'TAG4' OF STRUCTURE <fs_properties> TO <fs>. <fs> = gs_oc_obj-tag4.
      ASSIGN COMPONENT 'TAG5' OF STRUCTURE <fs_properties> TO <fs>. <fs> = gs_oc_obj-tag5.
    ENDIF.

    cs_properties = <fs_properties>.

  ENDMETHOD.


METHOD get_data_table.
  CONSTANTS: lc_comilla   TYPE c LENGTH 1 VALUE ''''.

  DATA: lv_tabname        TYPE string,
        lv_condense       TYPE string,
        lv_field          TYPE string,
        lv_tabnameddif    TYPE ddobjname,
        lv_keys           TYPE string,
        lv_keyv           TYPE string,
        lv_keys_main      TYPE string,
        lv_keys_temp      TYPE string,
        lv_root           TYPE string,
        lv_compline       TYPE i,
        lt_dfies_tab      TYPE STANDARD TABLE OF dfies,
        lt_fcat           TYPE lvc_t_fcat,
        lt_columns        TYPE STANDARD TABLE OF zonta_oc_col_all,
        lt_coli           TYPE STANDARD TABLE OF zonta_oc_col_all,
        ls_coli           TYPE zonta_oc_col_all,
        dref_table        TYPE REF TO data,
        dref_table_root   TYPE REF TO data,
        dref_table_body   TYPE REF TO data,
        lt_keys           TYPE tty_where,
        iv_message_v1     TYPE string,
        lt_relations      TYPE STANDARD TABLE OF zonta_relations,
        lv_lines          TYPE sy-tabix,
        ls_relations_last TYPE zonta_relations,
        lo_data           TYPE REF TO data,
        lv_recordst       TYPE sy-tabix,
        lv_max_records    TYPE zonde_registrosn,
        lv_pretty         TYPE string,
        lv_empty          TYPE string,
        lv_del_tabname    TYPE string,
        lv_del_where      TYPE string,
        lv_send           TYPE boolean,
        ls_columns        LIKE LINE OF lt_columns,
        lv_ind            TYPE i,
        ls_datat          TYPE ty_datat,
        it_data           TYPE REF TO data.

  DATA: lo_tab_descr    TYPE REF TO cl_abap_tabledescr,
        lo_struct_descr TYPE REF TO cl_abap_structdescr,
        lt_components   TYPE cl_abap_structdescr=>component_table,
        ls_component    LIKE LINE OF lt_components.

  FIELD-SYMBOLS: <fs_table>           TYPE STANDARD TABLE,
                 <fs_table1>          TYPE STANDARD TABLE,
                 <fs_body>            TYPE STANDARD TABLE,
                 <fs_metadata_root>   TYPE STANDARD TABLE,
                 <fs_relations>       TYPE zonta_relations,
                 <fs_root>            TYPE any,
                 <fs_oneconnect>      TYPE any,
                 <fs_properties>      TYPE any,
                 <fs_body_root>       TYPE any,
                 <fs_json>            LIKE LINE OF gt_json,
                 <fs_metadata>        TYPE any,
                 <fs_field_metadata>  TYPE any,
                 <fs_metadata_line>   TYPE any,
                 <fs_field>           TYPE any,
                 <fs_line>            TYPE any,
                 <fs_key>             TYPE any,
                 <fs_key_main>        TYPE any,
                 <fs_keys_event>      TYPE LINE OF tty_where,
                 <fs_table_body_line> TYPE any,
                 <fs_table2>          TYPE STANDARD TABLE,
                 <fs_table_line>      TYPE any,
                 <fs_data>            TYPE any.

  CASE sy-xform.
    WHEN 'ZONFM_ONE_CONNECT_BATCH'.
      iv_message_v1 = '*** Batch Process TABLE***'.
    WHEN 'SWF_EVT_HANDLER_START_INTERNAL'.
      iv_message_v1 = '*** Event Process TABLE ***'.
    WHEN 'FM_BGMC_PROCESS'.
      iv_message_v1 = '*** Direct Process TABLE RAP BO***'.
    WHEN OTHERS.
      iv_message_v1 = '*** Direct Process TABLE***'.
  ENDCASE.

  me->append_slg1_log(
    EXPORTING
      iv_tabname    = space
      iv_message_v1 = iv_message_v1
      iv_message_v2 = space
      iv_message_v3 = space
      iv_mestyp     = 'S' ).

  CLEAR gt_json.

  lt_relations = gt_relations.

  SORT lt_relations BY sequence.
  DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING sequence.
  SORT lt_relations BY levelv.

  lv_lines = lines( lt_relations ).
  READ TABLE lt_relations INDEX lv_lines INTO ls_relations_last.

  LOOP AT lt_relations ASSIGNING <fs_relations>.

    READ TABLE gt_datat INTO ls_datat WITH KEY tabname = <fs_relations>-tabname.
    IF sy-subrc = 0.
      it_data = ls_datat-lo_table.
    ELSE.
      RETURN.
    ENDIF.

    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname   = <fs_relations>-tabname
      TABLES
        dfies_tab = gt_dfies_tab
      EXCEPTIONS
        OTHERS    = 3.

    IF <fs_relations>-parent_relation IS INITIAL.
*      CLEAR gv_recordst_obj.
      CLEAR gs_log_json_result-recordst_obj.
    ENDIF.

    IF gs_oc_obj-data EQ abap_true.
      CREATE DATA dref_table_root TYPE ty_oneconnect_meta.
    ELSE.
      CREATE DATA dref_table_root TYPE ty_oneconnect.
    ENDIF.

    ASSIGN dref_table_root->* TO <fs_root>.
    ASSIGN COMPONENT 'ONECONNECT' OF STRUCTURE <fs_root> TO <fs_oneconnect>.
    ASSIGN COMPONENT 'PROPERTIES' OF STRUCTURE <fs_oneconnect> TO <fs_properties>.

    me->get_data_properties( CHANGING cs_properties = <fs_properties> ).

    ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_oneconnect> TO <fs_metadata_root>.
    ASSIGN COMPONENT 'BODY'     OF STRUCTURE <fs_oneconnect> TO <fs_body_root>.

    lv_tabname = 'SEQ' && <fs_relations>-sequence.
    APPEND INITIAL LINE TO <fs_metadata_root> ASSIGNING <fs_metadata>.
    ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_metadata> TO <fs_field_metadata>.
    <fs_field_metadata> = lv_tabname.
    TRANSLATE <fs_field_metadata> TO LOWER CASE.

    ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_metadata> TO <fs_metadata_line>.
    ASSIGN COMPONENT 'TABLE'    OF STRUCTURE <fs_body_root> TO <fs_field>.
    <fs_field> = lv_tabname.
    TRANSLATE <fs_field> TO LOWER CASE.

    IF gv_table IS INITIAL.
      lv_tabname = 'DATA' && lv_tabname.
    ENDIF.

    lv_condense = lv_tabname.

    ASSIGN COMPONENT 'DATA' OF STRUCTURE <fs_body_root> TO <fs_table_body_line>.

    "this keeps your original behavior (get_data_by_table sets correct type)
    me->get_data_by_table(
      EXPORTING
        iv_parent_relation = <fs_relations>-parent_relation
        iv_table           = <fs_relations>-tabname
      IMPORTING
        et_fcat            = lt_fcat
        et_data            = <fs_table_body_line> ).

    "+++ DB 2701 FIX: If no rows, bind DATA ref as empty table so JSON outputs "data":[]
    "NOTE: This must be here (outside loops), because when no rows the loops won't run
    IF it_data IS NOT INITIAL.
      "it_data ref exists; if it points to an empty table, we still want data:[]
      "If get_data_by_table didn't bind the ref (or it got cleared), bind it now
      IF <fs_table_body_line> IS NOT BOUND.
********
*        CREATE DATA <fs_table_body_line> LIKE it_data->*.
        DATA: lo_descr TYPE REF TO cl_abap_typedescr,
              lo_table TYPE REF TO cl_abap_tabledescr,
              lo_line  TYPE REF TO cl_abap_structdescr,
              lr_data  TYPE REF TO data.

        lo_descr ?= cl_abap_typedescr=>describe_by_data_ref( it_data ).
        lo_table ?= lo_descr.
        lo_line  ?= lo_table->get_table_line_type( ).

        CREATE DATA lr_data TYPE HANDLE lo_line.

        ASSIGN lr_data->* TO <fs_table_body_line>.
*******+
      ENDIF.
    ENDIF.
    "+++ end fix

    ASSIGN <fs_table_body_line>->* TO <fs_body>.
    CLEAR lt_keys.

    me->get_key(
      EXPORTING
        iv_parent_relation = <fs_relations>-parent_relation
        iv_tabname         = <fs_relations>-tabname
      IMPORTING
        et_keys            = lt_keys
        ev_key             = lv_keys
        ev_key_main        = lv_keys_main ).

    me->set_metadata_node(
      EXPORTING
        it_fcat     = lt_fcat
        iv_tabname  = <fs_relations>-tabname
      CHANGING
        cs_metadata = <fs_metadata_line> ).

    me->get_data_by_table(
      EXPORTING
        iv_parent_relation = <fs_relations>-parent_relation
        iv_table           = <fs_relations>-tabname
      IMPORTING
        et_fcat            = lt_fcat
        et_data            = lo_data ).

    ASSIGN lo_data->* TO <fs_table>.

    "Guard against initial ref (no dump)
    IF it_data IS NOT INITIAL.
      ASSIGN it_data->* TO <fs_table2>.
    ELSE.
      "no source data ref -> keep <fs_table2> unassigned
    ENDIF.

    lt_columns = gt_columns_all.
    DELETE lt_columns WHERE tabname NE <fs_relations>-tabname.

    lv_del_tabname = lc_comilla && <fs_relations>-tabname && lc_comilla.
    CONCATENATE 'TABNAME EQ' lv_del_tabname INTO lv_del_where SEPARATED BY space.

    IF it_data IS NOT INITIAL.
      LOOP AT <fs_table2> ASSIGNING <fs_data>. "WHERE (lv_del_where).
        APPEND INITIAL LINE TO <fs_table> ASSIGNING <fs_table_line>.

        me->assign_component_table(
          EXPORTING
            is_source    = <fs_data>
            is_relations = <fs_relations>
            iv_alias     = gv_alias
            it_columns   = lt_columns
          CHANGING
            cs_target    = <fs_table_line> ).
      ENDLOOP.
    ENDIF.

    SORT <fs_table>.
    DELETE ADJACENT DUPLICATES FROM <fs_table>.

    lv_recordst = lines( <fs_table> ).

    lv_send = abap_false.

    LOOP AT <fs_table> ASSIGNING <fs_line>.
      CLEAR lt_keys.
      ASSIGN COMPONENT lv_keys_main OF STRUCTURE <fs_line> TO <fs_key_main>.

      IF <fs_relations>-parent_relation IS INITIAL.
        IF <fs_key_main> IS ASSIGNED.
          IF lv_keys_temp NE <fs_key_main>.
            lv_keys_temp = <fs_key_main>.
          ENDIF.
        ENDIF.
      ENDIF.

      lv_max_records = lv_max_records + 1.

      IF <fs_relations>-parent_relation IS INITIAL.
*        gv_recordst_obj  = gv_recordst_obj + 1.
        gs_log_json_result-recordst_obj  = gs_log_json_result-recordst_obj + 1.
        gv_recordst_obji = gv_recordst_obji + 1.
      ENDIF.

      " Begin of insert DBFIX 08/11
*      DATA(lt_coli) = lt_columns[].
      lt_coli  = lt_columns[].

      DELETE lt_coli WHERE tabname NE <fs_relations>-tabname.

      DELETE lt_coli WHERE key_field = space.
      SORT lt_coli BY positionf.
      READ TABLE lt_coli INTO ls_coli INDEX 1.
      IF gv_alias = abap_true.
        lv_keyv = ls_coli-alias_fldname.
      ELSE.
        lv_keyv = ls_coli-fldname.
      ENDIF.

      ASSIGN COMPONENT lv_keyv OF STRUCTURE <fs_line> TO <fs_key>.
      " End of insert DBFIX 08/11

      IF <fs_key> IS ASSIGNED.
        me->append_slg1_log(
          iv_tabname = <fs_relations>-tabname
          iv_mestyp  = 'S'
          iv_key     = <fs_key> ).
      ENDIF.

      IF gs_oc_obj-eventid EQ abap_true OR gs_oc_obj-metadata EQ abap_true.
        IF <fs_key> IS ASSIGNED.
          APPEND INITIAL LINE TO lt_keys ASSIGNING <fs_keys_event>.
          IF <fs_key> IS NOT INITIAL.
            IF abap_false = is_cds_entity( iv_tabname = <fs_relations>-tabname ).
              <fs_keys_event>-line = <fs_key>.
            ELSEIF <fs_key_main> IS ASSIGNED.
              <fs_keys_event>-line = <fs_key_main>.
            ENDIF.
          ELSEIF abap_true = is_cds_entity( iv_tabname = <fs_relations>-tabname ).
            IF <fs_key_main> IS ASSIGNED.
              <fs_keys_event>-line = <fs_key_main>.
            ENDIF.
          ENDIF.
        ENDIF.

        me->get_eventid(
          EXPORTING it_keys      = lt_keys
          CHANGING  cs_line_json = <fs_line> ).
      ENDIF.

      "++DB 2701: ONLY append body row when there is source data
      IF it_data IS NOT INITIAL.

        APPEND INITIAL LINE TO <fs_body> ASSIGNING <fs_table_body_line>.
        MOVE-CORRESPONDING <fs_line> TO <fs_table_body_line>.

        me->conversion_exit(
          EXPORTING iv_tabname = <fs_relations>-tabname
          CHANGING  cs_string  = <fs_table_body_line> ).

        " Begin of insert DBFIX 08/11
        ASSIGN COMPONENT 1 OF STRUCTURE <fs_table_body_line> TO <fs_field>.
        IF <fs_field> IS ASSIGNED AND abap_false = me->is_cds_entity( <fs_relations>-tabname ).
          <fs_field> = sy-mandt.
        ENDIF.
        " End of insert DBFIX 08/11

        UNASSIGN <fs_key>.

      ENDIF.

      IF lv_max_records EQ gs_oc_obj-no_registros.

        APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
        <fs_json>-json_id = gv_jsonid.
        <fs_json>-json = zoncl_ui2_cl_json=>serialize(
                      data             = <fs_root>
                      compress         = abap_false
                      assoc_arrays     = abap_true
                      assoc_arrays_opt = abap_true
                      pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).
        gv_jsonid = gv_jsonid + 1.
        CLEAR: lv_max_records, <fs_body>.
        lv_send = abap_true.
      ELSE.
        lv_send = abap_false.
      ENDIF.
    ENDLOOP.

    IF sy-subrc NE 0.
      lv_empty = abap_true.
    ENDIF.

    IF lv_max_records LT gs_oc_obj-no_registros AND lv_send = abap_false.

      APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
      <fs_json>-json_id = gv_jsonid.
      <fs_json>-json = zoncl_ui2_cl_json=>serialize(
                    data             = <fs_root>
                    compress         = abap_false
                    assoc_arrays     = abap_true
                    assoc_arrays_opt = abap_true
                    pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).
      CLEAR lv_max_records.
      gv_jsonid = gv_jsonid + 1.
    ENDIF.

    TRANSLATE lv_condense TO LOWER CASE.

    IF lv_empty EQ abap_true.
      lv_pretty = '"seq' && <fs_relations>-sequence && '":[],'.
      lv_empty  = '"seq' && <fs_relations>-sequence && '":[*],'.
      REPLACE lv_pretty WITH lv_empty INTO <fs_json>-json.
      IF sy-subrc NE 0.
        lv_pretty = '"seq' && <fs_relations>-sequence && '":[]'.
        lv_empty  = '"seq' && <fs_relations>-sequence && '":[*]'.
        REPLACE lv_pretty WITH lv_empty INTO <fs_json>-json.
        IF sy-subrc NE 0.
          lv_pretty = '"data":[]'.
          lv_empty  = '"seq' && <fs_relations>-sequence && '":[*]'.
          REPLACE lv_pretty WITH lv_empty INTO <fs_json>-json.
        ENDIF.
      ENDIF.
      lv_empty = abap_false.
    ENDIF.

    UNASSIGN <fs_root>.
  ENDLOOP.

ENDMETHOD.


  METHOD get_ddicobject_from_cds.

**Get view ddic from CDS
*    SELECT SINGLE cds_db_view
*      FROM ddddlsrc
*      INTO rv_ddic_object
*     WHERE cds_ddl = iv_tabname.
  ENDMETHOD.


  METHOD get_eventid.

    DATA: lv_key       TYPE string,
          lv_timestamp TYPE string,
          lv_tag_name  TYPE string.

    FIELD-SYMBOLS: <fs_line_json>      TYPE any,
                   <fs_field_objectid> TYPE any,
                   <fs_field_event>    TYPE any,
                   <fs_field_key>      TYPE any,
                   <fs_field_tag>      TYPE any,
                   <fs_key>            TYPE LINE OF tty_where.

    ASSIGN cs_line_json TO <fs_line_json>.

* Set OBJECTID
    ASSIGN COMPONENT 'OBJECTIDEVT' OF STRUCTURE <fs_line_json> TO <fs_field_objectid>.
    IF sy-subrc NE 0.
      ASSIGN COMPONENT 'OBJECTID' OF STRUCTURE <fs_line_json> TO <fs_field_objectid>.
    ENDIF.
    IF <fs_field_objectid> IS ASSIGNED.
      <fs_field_objectid> = gs_oc_obj-objtype.
    ENDIF.

* Set EVENTID
    ASSIGN COMPONENT 'EVENTID' OF STRUCTURE <fs_line_json> TO <fs_field_event>.
    IF SY-SUBRC NE 0.
        ASSIGN COMPONENT 'EVENTIDEVT' OF STRUCTURE <fs_line_json> TO <fs_field_event>.
    ENDIF.
    IF <fs_field_event> IS ASSIGNED.

      lv_timestamp = me->get_timestamp( ).

      LOOP AT it_keys ASSIGNING <fs_key>.
        ASSIGN COMPONENT <fs_key>-line OF STRUCTURE <fs_line_json> TO <fs_field_key>.
        IF <fs_field_key> IS ASSIGNED.
          lv_key = lv_key && <fs_field_key>.
        ELSE.
          lv_key = <fs_key>-line.
        ENDIF.
      ENDLOOP.

      gv_event_id = gs_oc_obj-cdobjectcl && lv_key && lv_timestamp.
      CONDENSE gv_event_id NO-GAPS.

      <fs_field_event> = gv_event_id.
    ENDIF.

* Add TAG1–TAG5 if metadata flag is true
    IF gs_oc_obj-metadata = abap_true.

      DO 5 TIMES.
        lv_tag_name = |TAG{ sy-index }|.
        ASSIGN COMPONENT lv_tag_name OF STRUCTURE <fs_line_json> TO <fs_field_tag>.

        IF <fs_field_tag> IS ASSIGNED.
          ASSIGN COMPONENT lv_tag_name OF STRUCTURE gs_oc_obj TO <fs_field_key>.
          IF <fs_field_key> IS ASSIGNED.
            <fs_field_tag> = <fs_field_key>.
          ENDIF.

          UNASSIGN <fs_field_tag>.
        ENDIF.
      ENDDO.

    ENDIF.

  ENDMETHOD.


  METHOD get_fields_parametrized_cds.

*    DATA: lt_dd10b TYPE STANDARD TABLE OF dd10b,
*          ls_dd10b TYPE dd10b,
*          ls_par   TYPE  rsdsfields.
*
*
*    SELECT *
*      INTO TABLE lt_dd10b
*      FROM dd10b
*      WHERE strucobjn = iv_tabname.
*
*    LOOP AT lt_dd10b INTO ls_dd10b.
*      CLEAR ls_par.
**ls_par-TABLENAME = ls_dd10b-
**ls_par-FIELDNAME = ls_dd10b-
**ls_par-TYPE = ls_dd10b-
**ls_par-WHERE_LENG = ls_dd10b-
**ls_par-SIGN = ls_dd10b-
**ls_par-DECIMALS = ls_dd10b-decimals.
**append ls_par to gt_par_field.
*    ENDLOOP.
  ENDMETHOD.


  METHOD get_global_data.
    DATA: lv_tabname   TYPE tabname,
          ls_relations TYPE zonta_relations,
          lt_cdhdr     TYPE tty_cdhdr,
          lv_time      TYPE sy-uzeit,
          lo_table     TYPE REF TO data.
*DO ." TIMES.
*
*ENDDO.
    " 2. Load relation definitions
    SELECT *
      INTO TABLE gt_relations
      FROM zonta_relations
      WHERE domainv       = gv_domainv
        AND business_proc = gv_entity
      ORDER BY sequence.

    IF sy-subrc <> 0.
      MESSAGE i000(fb) WITH 'No data found on ZONTA_RELATIONS'.
      RETURN.
    ENDIF.

    " 3. Load column definitions for these relations
    SELECT *
      INTO TABLE gt_columns_all
      FROM zonta_oc_col_all
      FOR ALL ENTRIES IN gt_relations
      WHERE tabname       = gt_relations-tabname
        AND alias_tabname = gt_relations-alias_tabname.

    SELECT *
      INTO TABLE gt_converted
      FROM zonta_oc_conv
      FOR ALL ENTRIES IN gt_relations
      WHERE tabname       = gt_relations-tabname
        AND alias_tabname = gt_relations-alias_tabname.

    " 4. Object configuration (for event ID, metadata, etc.)
    READ TABLE gt_relations INDEX 1 INTO ls_relations.
    IF sy-subrc = 0.
      SELECT SINGLE *
        INTO gs_oc_obj
        FROM zonta_obj_oc
        WHERE id            = ls_relations-id
          AND domainv       = gv_domainv
          AND business_proc = gv_entity.
    ENDIF.

    " 5. Load filter definitions (for free selection)
    IF gv_variant IS INITIAL.
      SELECT *
       INTO TABLE gt_filters
       FROM zonta_oc_filters
       WHERE domainv       = gv_domainv
         AND business_proc = gv_entity
         AND variant       = space.
    ENDIF.
    " 6. Optional: get deleted change logs from CDHDR/CDPOS
    IF gv_delete = abap_true OR gv_instid IS NOT INITIAL.
      lv_time = sy-uzeit - 30.

      SELECT objectclas
             objectid
             changenr
        INTO TABLE lt_cdhdr
        FROM cdhdr
        WHERE objectclas = gs_oc_obj-cdobjectcl
          AND objectid   = gv_instid
          AND udate      = sy-datum
          AND utime BETWEEN lv_time AND sy-uzeit.

      IF sy-subrc = 0.
        SELECT tabname
               tabkey
          INTO TABLE gt_cdpos
          FROM cdpos
          FOR ALL ENTRIES IN lt_cdhdr
          WHERE objectclas = lt_cdhdr-objectclas
            AND objectid   = lt_cdhdr-objectid
            AND changenr   = lt_cdhdr-changenr
            AND fname      = 'KEY'
            AND chngind    = 'D'.
      ENDIF.
    ENDIF.

    lo_table  = me->set_table( ).

  ENDMETHOD.


  METHOD get_handler_by_flags.


    " Reset handler reference
    CLEAR mo_handler.
    CLEAR gv_sending.

    " Determine appropriate handler by flag
    IF gv_kdoc = abap_true AND gv_table = abap_false.
      gv_sending = c_kdoc.
      CREATE OBJECT mo_handler TYPE zoncl_oc_kdoc_handler.

    ELSEIF gv_table = abap_true AND gv_kdoc = abap_false.
      gv_sending = c_table.
      CREATE OBJECT mo_handler TYPE zoncl_oc_table_handler.

    ELSE.
      IF gv_back_2_process = abap_true.
        gv_sending = c_table.
        CREATE OBJECT mo_handler TYPE zoncl_oc_table_handler.
      ELSE.
        gv_sending = c_kdoc.
        CREATE OBJECT mo_handler TYPE zoncl_oc_kdoc_handler.
        gv_back_2_process = abap_true.
      ENDIF.
    ENDIF.

    " Copy context from current base handler to the selected handler
    IF mo_handler IS BOUND.
      mo_handler->copy_context_from( me ).
    ENDIF.



  ENDMETHOD.


  METHOD get_key.

    DATA: lv_field          TYPE string,
          lv_lines          TYPE sy-tabix,
          lt_relations_keys TYPE STANDARD TABLE OF zonta_relations,
          ls_columns        TYPE zonta_oc_col_all,
          lv_tabix          TYPE sy-tabix.

    FIELD-SYMBOLS: <fs_keys>     TYPE zonta_relations,
                   <fs_keys_tab> TYPE LINE OF tty_where.

    lt_relations_keys = gt_relations.

    IF NOT iv_parent_relation IS INITIAL.

      SORT lt_relations_keys BY sequence subsequence.

      DELETE lt_relations_keys WHERE parent_relation NE iv_parent_relation.
      DELETE lt_relations_keys WHERE tabname NE iv_tabname.

      lv_lines = lines( lt_relations_keys ).

      LOOP AT lt_relations_keys ASSIGNING <fs_keys>.

        lv_tabix = sy-tabix.

        READ TABLE gt_columns_all WITH KEY tabname = iv_parent_relation
                                       fldname =  <fs_keys>-field_main
                                       INTO ls_columns.
*        IF sy-subrc = 0 AND gv_alias IS NOT INITIAL AND ls_columns-alias_fldname IS NOT INITIAL.
*          <fs_keys>-field_main = ls_columns-alias_fldname.
*        ELSE.
          <fs_keys>-field_main = ls_columns-fldname.
*        ENDIF.

        READ TABLE gt_columns_all WITH KEY tabname = iv_tabname
                                       fldname =  <fs_keys>-field_sec
                                       INTO ls_columns.
*        IF sy-subrc = 0 AND gv_alias IS NOT INITIAL AND ls_columns-alias_fldname IS NOT INITIAL.
*          <fs_keys>-field_sec = ls_columns-alias_fldname.
*        ELSE.
          <fs_keys>-field_sec = ls_columns-fldname.
*        ENDIF.

        lv_field = 'is_line-' && <fs_keys>-field_main.

        IF lv_tabix < lv_lines.
          CONCATENATE ev_key <fs_keys>-field_sec 'EQ' lv_field 'AND'
                      INTO ev_key SEPARATED BY space.
        ELSE.
          CONCATENATE ev_key <fs_keys>-field_sec 'EQ' lv_field
                      INTO ev_key SEPARATED BY space.
        ENDIF.

        IF gs_oc_obj-eventid = abap_true.
          APPEND INITIAL LINE TO et_keys ASSIGNING <fs_keys_tab>.
          <fs_keys_tab>-line = <fs_keys>-field_sec.
        ENDIF.

      ENDLOOP.

    ELSE.

      READ TABLE gt_columns_all WITH KEY tabname = iv_tabname
                                     key_field = abap_true
                                     INTO ls_columns.

      IF sy-subrc = 0.
*        IF gv_alias IS NOT INITIAL AND ls_columns-alias_fldname IS NOT INITIAL.
*          ev_key_main = ls_columns-alias_fldname.
*        ELSE.
          ev_key_main = ls_columns-fldname.
*        ENDIF.

        TRANSLATE ev_key_main TO UPPER CASE.
      ENDIF.

    ENDIF.

  ENDMETHOD.


METHOD get_key_kdoc.

  DATA: lv_lines  TYPE sy-tabix,
        lv_tabix  TYPE sy-tabix,
        lv_value  TYPE string,
        lv_quoted TYPE string,
        lv_mkey   TYPE string.

  DATA: lt_relations_keys TYPE STANDARD TABLE OF zonta_relations,
        ls_columns        TYPE zonta_oc_col_all.

  FIELD-SYMBOLS:
    <fs_keys>         TYPE zonta_relations,
    <fs_keys_tab>     TYPE LINE OF tty_where,
    <fs_parent_value> TYPE any.

  CLEAR: ev_key, ev_key_main, et_keys.

  lt_relations_keys = gt_relations.

  "------------------------------------------------------------
  " CHILD TABLE: build WHERE using parent row values
  "------------------------------------------------------------
  IF iv_parent_relation IS NOT INITIAL.

    SORT lt_relations_keys BY sequence subsequence.

    DELETE lt_relations_keys WHERE parent_relation NE iv_parent_relation.
    DELETE lt_relations_keys WHERE tabname NE iv_tabname.

    IF lt_relations_keys IS INITIAL.
      RETURN.  " This table is NOT a child of the parent
    ENDIF.

    lv_lines = lines( lt_relations_keys ).

    LOOP AT lt_relations_keys ASSIGNING <fs_keys>.

      lv_tabix = sy-tabix.

      " Resolve parent field name
      READ TABLE gt_columns_all
           WITH KEY tabname = iv_parent_relation
                    fldname = <fs_keys>-field_main
           INTO ls_columns.
      IF sy-subrc = 0.
        <fs_keys>-field_main = ls_columns-fldname.
      ENDIF.

      " Resolve child field name
      READ TABLE gt_columns_all
           WITH KEY tabname = iv_tabname
                    fldname = <fs_keys>-field_sec
           INTO ls_columns.
      IF sy-subrc = 0.
        <fs_keys>-field_sec = ls_columns-fldname.
      ENDIF.

      ASSIGN COMPONENT <fs_keys>-field_main
             OF STRUCTURE is_line
             TO <fs_parent_value>.
      IF <fs_parent_value> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      lv_value = <fs_parent_value>.
      REPLACE ALL OCCURRENCES OF '''' IN lv_value WITH ''''''.

      CONCATENATE '''' lv_value '''' INTO lv_quoted.
      CONCATENATE <fs_keys>-field_sec <fs_keys>-sequence INTO lv_mkey.

      IF lv_tabix < lv_lines.
        CONCATENATE ev_key
                    lv_mkey "<fs_keys>-field_sec
                    'EQ'
                    lv_quoted
                    'AND'
               INTO ev_key SEPARATED BY space.
      ELSE.
        CONCATENATE ev_key
                    lv_mkey "<fs_keys>-field_sec
                    'EQ'
                    lv_quoted
               INTO ev_key SEPARATED BY space.
      ENDIF.

      IF gs_oc_obj-eventid = abap_true.
        APPEND INITIAL LINE TO et_keys ASSIGNING <fs_keys_tab>.
        <fs_keys_tab>-line = <fs_keys>-field_sec.
      ENDIF.

    ENDLOOP.

    "------------------------------------------------------------
    " ROOT TABLE: identify main key field
    "------------------------------------------------------------
  ELSE.

    READ TABLE gt_columns_all
         WITH KEY tabname   = iv_tabname
                  key_field = abap_true
         INTO ls_columns.

    IF sy-subrc = 0.
      ev_key_main = ls_columns-fldname.
      TRANSLATE ev_key_main TO UPPER CASE.
    ENDIF.

  ENDIF.

ENDMETHOD.


  METHOD get_lenght_key.

    CONSTANTS: lc_comilla TYPE c LENGTH 1 VALUE ''''.

    DATA: lt_dfies_tab TYPE STANDARD TABLE OF dfies,
          dref_table   TYPE REF TO data,
          lv_fields    TYPE string,
          lv_where     TYPE string,
          lv_instid    TYPE string.

    FIELD-SYMBOLS: <fs_table> TYPE any,
                   <fs_cdpos> TYPE ty_cdpos,
                   <fs_dfies> TYPE dfies.

    CLEAR rv_lenght.

    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname        = iv_tabname
      TABLES
        dfies_tab      = lt_dfies_tab
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.

    IF sy-subrc <> 0.
      rv_lenght = 0.
      RETURN.
    ENDIF.

    DELETE lt_dfies_tab WHERE keyflag NE abap_true.

    LOOP AT lt_dfies_tab ASSIGNING <fs_dfies>.
      rv_lenght = rv_lenght + <fs_dfies>-leng.

      CONCATENATE lv_fields <fs_dfies>-fieldname
                  INTO lv_fields SEPARATED BY space.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_process_context_message.
    CASE sy-xform.
      WHEN 'ZONFM_ONE_CONNECT_BATCH'.
        rv_message = 'Batch Process - TABLE'.
      WHEN 'SWF_EVT_HANDLER_START_INTERNAL'.
        rv_message = 'Event Triggered Process - TABLE'.
      WHEN 'FM_BGMC_PROCESS'.
        rv_message = 'Direct RAP BO Process - TABLE'.
      WHEN OTHERS.
        rv_message = 'Direct Process - TABLE'.
    ENDCASE.
  ENDMETHOD.


  METHOD get_read_text_longtext.
    CONSTANTS: lc_id     TYPE char4 VALUE 'TDID',
               lc_object TYPE char8 VALUE 'TDOBJECT',
               lc_name   TYPE char6 VALUE 'TDNAME',
               lc_langu  TYPE char8 VALUE 'TDSPRAS',
               lc_data   TYPE char6 VALUE 'CLUSTD'.

    DATA: lt_lines  TYPE STANDARD TABLE OF tline, " Table to hold the retrieved text lines
          ls_header TYPE thead.                 " Structure to hold text header information

* Define the parameters for the text to be read
    DATA: lv_object    TYPE tdobject,
          lv_name      TYPE tdobname,
          lv_fieldname TYPE zonta_oc_col_all-fldname,
          ls_column2   TYPE zonta_oc_col_all,
          ls_relations TYPE zonta_relations,
          ls_line      LIKE LINE OF lt_lines,
          lv_id        TYPE tdid,
          lv_text      TYPE string,
          lv_language  TYPE tdspras.

    FIELD-SYMBOLS: <fs_field>      TYPE any.

*revisar 1702
    LOOP AT gt_columns_all INTO ls_column2
                           WHERE tabname = iv_tabname.

      READ TABLE gt_relations INTO ls_relations
                             WITH KEY tabname = iv_tabname.
      IF sy-subrc EQ 0.
        CONCATENATE ls_column2-alias_fldname ls_relations-sequence INTO lv_fieldname.

        ASSIGN COMPONENT lv_fieldname OF STRUCTURE isc_table TO <fs_field> .
        IF <fs_field> IS NOT ASSIGNED.
          CONCATENATE ls_column2-fldname ls_relations-sequence INTO lv_fieldname.
          ASSIGN COMPONENT lv_fieldname OF STRUCTURE isc_table TO <fs_field> .
        ENDIF.

        CASE ls_column2-fldname.
          WHEN lc_id.
            IF <fs_field>  IS ASSIGNED.
              lv_id  = <fs_field>.
            ENDIF.

          WHEN lc_object.
            IF <fs_field>  IS ASSIGNED.
              lv_object = <fs_field>.
            ENDIF.

          WHEN lc_name.
            IF <fs_field>  IS ASSIGNED.
              lv_name  = <fs_field>.
            ENDIF.

          WHEN  lc_langu.
            IF <fs_field>  IS ASSIGNED.
              lv_language  = <fs_field>.
            ENDIF.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
      UNASSIGN <fs_field>.
    ENDLOOP.

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        client    = sy-mandt
        object    = lv_object
        name      = lv_name
        id        = lv_id
        language  = lv_language
      IMPORTING
        header    = ls_header
      TABLES
        lines     = lt_lines
      EXCEPTIONS
        id        = 1
        language  = 2
        name      = 3
        not_found = 4
        object    = 5
        OTHERS    = 8.

    IF sy-subrc EQ 0.
* Text successfully read
      LOOP AT lt_lines INTO ls_line.
        WRITE: / .
        CONCATENATE lv_text ls_line-tdline INTO lv_text SEPARATED BY space.
      ENDLOOP.
      IF lv_text IS NOT INITIAL.
        READ TABLE gt_columns_all INTO ls_column2
                                   WITH KEY tabname = iv_tabname
                                            fldname = lc_data.

        IF sy-subrc EQ 0.


          READ TABLE gt_relations INTO ls_relations
                               WITH KEY tabname = iv_tabname.
          IF sy-subrc EQ 0.
            CONCATENATE ls_column2-alias_fldname ls_relations-sequence INTO ls_column2-alias_fldname.

            ASSIGN COMPONENT ls_column2-alias_fldname OF STRUCTURE isc_table TO <fs_field> .
            IF <fs_field> IS NOT ASSIGNED.
              CONCATENATE ls_column2-fldname ls_relations-sequence INTO ls_column2-fldname.
              ASSIGN COMPONENT ls_column2-fldname OF STRUCTURE isc_table TO <fs_field> .
            ENDIF.
          ENDIF.
          IF <fs_field>  IS ASSIGNED.
            <fs_field> = lv_text.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
* Handle errors based on sy-subrc
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDMETHOD.


  METHOD GET_TABLE_BY_TABLE_DATA_KDOC.

    DATA: fname              TYPE ttypename,
          lv_parent_relation TYPE zonde_parentrel,
          lt_dyn_table       TYPE REF TO data.

    FIELD-SYMBOLS:
      <fs_relations>  TYPE zonta_relations,
      <fs_columns>    TYPE zonta_oc_col_all,
      <gfs_dyn_table> TYPE STANDARD TABLE.

    lv_parent_relation = iv_parent_relation.
    IF lv_parent_relation IS INITIAL.
      lv_parent_relation = iv_table.
    ENDIF.

    LOOP AT gt_relations ASSIGNING <fs_relations>
               WHERE tabname = iv_table.

* Change 2801
*      READ TABLE gt_columns_all
*        WITH KEY tabname       = <fs_relations>-tabname
*                 alias_tabname = <fs_relations>-alias_tabname
*        ASSIGNING <fs_columns>.
*
*      IF sy-subrc = 0 AND <fs_columns>-id_column IS NOT INITIAL.
*        fname = |ZON{ <fs_columns>-id_column }TTSEQ{ <fs_relations>-sequence }|.
        fname = |ZON{ <fs_relations>-id }TTSEQ{ <fs_relations>-sequence }|.
*      ENDIF.

    ENDLOOP.

* Create dynamic internal table
    CREATE DATA lt_dyn_table TYPE (fname).
    ASSIGN lt_dyn_table->* TO <gfs_dyn_table>.

    et_data = lt_dyn_table.

  ENDMETHOD.


  METHOD get_timestamp.

    DATA: lv_time_stamp TYPE timestamp,
          lv_date       TYPE d,
          lv_time       TYPE t,
          lv_tz         TYPE ttzz-tzone.

    lv_tz = sy-tzone.
    GET TIME STAMP FIELD lv_time_stamp.
    CONVERT TIME STAMP lv_time_stamp TIME ZONE lv_tz INTO DATE lv_date TIME lv_time.

    rv_timestamp = lv_time_stamp.

  ENDMETHOD.


  METHOD get_variant_values.

    TYPES: BEGIN OF st_filters,
             tabname      TYPE tabname,
             counter      TYPE zonde_counter,
             fldname      TYPE fieldname,
             where_clause TYPE zonde_where.
    TYPES:       END OF st_filters.

    DATA: lo_interpreter TYPE REF TO zoncl_dynamic_interpreter.
    DATA: lt_variant     TYPE STANDARD TABLE OF zonta_oc_variant,
          ls_variant     LIKE LINE OF lt_variant,
          lv_varname     TYPE tvarvc-name,
          lt_range       TYPE zonst_oc_rsparams,
          ls_range       TYPE zonst_oc_date,
          lt_where_tmp   TYPE rsds_twhere,
          lt_where_whole TYPE rsds_twhere,
*          lt_filters     TYPE STANDARD TABLE OF zonta_oc_filters,
          ls_rwhere      TYPE zonttrsdswhere,
          lv_or          TYPE boolean,
          lt_relations   TYPE STANDARD TABLE OF zonta_relations,
          ls_cond        TYPE rsds_where,
*          lt_where       TYPE rsds_where_tab,
*          ls_cond_tab    like LINE OF lt_where_whole,
          lt_filt        TYPE STANDARD TABLE OF st_filters,
          ls_filt        LIKE LINE OF lt_filt,
          lt_range_whole TYPE zontt_oc_rsparams_tt. "zontt_oc_date.

    DATA: lt_filters   TYPE TABLE OF zonta_oc_filters,
          lv_tabname   TYPE tabname,
          lv_clause    TYPE zonde_where,
*          lt_relations TYPE TABLE OF zonta_relations,
          ls_relations TYPE zonta_relations,
          ls_cond_tab  LIKE LINE OF lt_where_whole,
          lt_where     TYPE rsds_where_tab,
          ls_line      TYPE rsdswhere,
          lv_first     TYPE abap_bool.

    FIELD-SYMBOLS: <fs_filtero> LIKE LINE OF lt_filters,
                   <fs_filter>  LIKE LINE OF lt_filt.


    SELECT *
    FROM zonta_oc_variant
    INTO TABLE lt_variant
    WHERE domainv       = iv_domainv
      AND business_proc = iv_entity
      AND variant       = iv_variant.

    READ TABLE lt_variant INTO ls_variant INDEX 1.
    IF sy-subrc = 0 AND ls_variant-variant_type = 'D'.
* Dynamic variant
      CREATE OBJECT lo_interpreter.
      LOOP AT lt_variant INTO ls_variant.
        "TVARVC selection
        IF ls_variant-vtype = 'T'.

          lv_varname = ls_variant-description.

          CALL METHOD lo_interpreter->get_dynamic_variable
            EXPORTING
              iv_varname   = lv_varname
              iv_tabname   = ls_variant-tabname
              iv_fieldname = ls_variant-fieldname
            IMPORTING
              et_range     = lt_range
              et_where     = lt_where_tmp
            CHANGING
              et_where_all = lt_where_whole
              et_range_all = lt_range_whole.

          " DYNAMIC variable
        ELSE.

          CALL METHOD lo_interpreter->get_dynamic_date
            EXPORTING
              iv_tabname   = ls_variant-tabname
              iv_fieldname = ls_variant-fieldname
              iv_varname   = ls_variant-sapvar
              iv_vtype     = ls_variant-vtype
              iv_offset1   = ls_variant-val1
              iv_offset2   = ls_variant-val2
              iv_sign1     = ls_variant-sign1
              iv_sign2     = ls_variant-sign2
            IMPORTING
              es_range     = ls_range
              et_where     = lt_where_tmp
              et_range     = lt_range
            CHANGING
              et_where_all = lt_where_whole
              et_range_all = lt_range_whole.

          gt_ranges_where = lt_range_whole.
          et_ranges_where = gt_ranges_where.
        ENDIF.
      ENDLOOP.

      et_where = lt_where_whole[].
* Variant with values
    ELSE.
      " 1. Get filters
      SELECT *
        INTO TABLE lt_filters
        FROM zonta_oc_filters
        WHERE domainv       = iv_domainv
          AND business_proc = iv_entity
          AND variant       = iv_variant.

      IF sy-subrc = 0.

        REFRESH gt_filters.
        CLEAR lv_first.
        SORT lt_filters BY tabname counter. "fldname.
*        READ TABLE lt_filters INTO DATA(ls_fil) INDEX 1.
*        lv_tabname = ls_fil-tabname.


        REFRESH lt_filt[].
        LOOP AT lt_filters ASSIGNING <fs_filtero>.
          CLEAR ls_filt.
          MOVE-CORRESPONDING <fs_filtero> TO ls_filt.
          APPEND ls_filt TO lt_filt.
        ENDLOOP.

        SORT lt_filt BY tabname counter.
        LOOP AT lt_filt ASSIGNING <fs_filter>.
          lv_clause = <fs_filter>-where_clause.
*          IF lv_first IS INITIAL.
*            APPEND value rsdswhere( LINE = lv_clause ) TO lt_where.
**            lv_first = abap_true.
*          ELSE.
*            APPEND value rsdswhere( LINE = |AND { lv_clause }| ) TO lt_where.
*          ENDIF.
          DATA ls_where TYPE rsdswhere.

          IF lv_first IS INITIAL.
            ls_where-line = lv_clause.
            APPEND ls_where TO lt_where.
            CLEAR ls_where.
            lv_first = abap_true.
          ELSE.
            CONCATENATE 'AND' lv_clause INTO ls_where-line SEPARATED BY space.
            APPEND ls_where TO lt_where.
            CLEAR ls_where.

          ENDIF.


*          IF lv_tabname NE <fs_filter>-tabname.
          AT END OF tabname.
            " Fill GT_COND_TAB row
            ls_cond_tab-tablename = <fs_filter>-tabname.
            ls_cond_tab-where_tab = lt_where.
            APPEND ls_cond_tab TO et_where.
            CLEAR lv_first.
            CLEAR lt_where[].
            lv_first = abap_true.
          ENDAT.
*            lv_tabname = <fs_filter>-tabname.
*          ENDIF.
        ENDLOOP.
      ENDIF.

    ENDIF.


  ENDMETHOD.


  METHOD get_where.

    TYPES: BEGIN OF lty_rsds_where,
             tablename TYPE rsdstabs-prim_tab,
             where_tab TYPE zonttrsdswhere,
           END OF lty_rsds_where.

    TYPES: ty_rsds_twhere TYPE STANDARD TABLE OF lty_rsds_where.

    DATA selid          TYPE rsdynsel-selid.
    DATA field_tab      TYPE TABLE OF rsdsfields.
    DATA field_tab_excl TYPE TABLE OF rsdsfields.
    DATA table_tab      TYPE TABLE OF rsdstabs.
    DATA cond_tab       TYPE rsds_twhere.
    DATA lv_title       TYPE sy-title.
    DATA: lv_join       TYPE string.
    DATA: lt_relations         TYPE STANDARD TABLE OF zonta_relations,
          lt_relations_for_all TYPE STANDARD TABLE OF zonta_relations,
          lt_columns           TYPE STANDARD TABLE OF zonta_oc_columns,
          lt_cond_tab          TYPE ty_rsds_twhere,
          ls_relations         TYPE zonta_relations,
          ls_cond_tab          TYPE LINE OF ty_rsds_twhere,
          ls_conv              TYPE  zonta_oc_conv ,
          lv_lines             TYPE sy-tabix,
          lv_sequence          TYPE string,
          lv_tabname           TYPE  ddobjname,
          lv_field             TYPE string,
          lv_or                TYPE boolean.
    FIELD-SYMBOLS: <fs_relations>        TYPE zonta_relations,
                   <fs_relations_parent> TYPE zonta_relations,
                   <fs_table_tab>        TYPE rsdstabs,
                   <fs_dfies_tab_cat>    TYPE dfies,
                   <fs_field_tab_excl>   TYPE rsdsfields,
                   <fs_cond_tab>         TYPE LINE OF rsds_twhere,
                   <fs_cond_tab_tmp>     TYPE LINE OF ty_rsds_twhere,
                   <fs_where_tab>        TYPE LINE OF rsds_where_tab,
                   <fs_where_tab_tmp>    TYPE LINE OF zonttrsdswhere,
                   <fs_where>            TYPE LINE OF zonttrsdswhere,
                   <fs_where_tab_line>   TYPE LINE OF rsds_where_tab,
                   <fs_filter>           TYPE zonta_oc_filters,
                   <fs_columns>          TYPE zonta_oc_col_all.

    IF NOT gt_cond_tab IS INITIAL.

      lt_relations         = gt_relations.
      lt_relations_for_all = gt_relations.

      DELETE lt_relations WHERE tabname NE iv_tabname.
      DELETE lt_relations_for_all WHERE tabname NE iv_tabname.

      DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING sequence.

      SORT lt_relations BY sequence.
      SORT lt_relations BY sequence subsequence.

      IF NOT gv_anytable IS INITIAL.
        LOOP AT gt_cond_tab ASSIGNING <fs_cond_tab>.
          LOOP AT <fs_cond_tab>-where_tab ASSIGNING <fs_where_tab>.
            SHIFT <fs_where_tab>-line LEFT DELETING LEADING space.
          ENDLOOP.
          r_where = <fs_cond_tab>-where_tab.
        ENDLOOP.
      ELSE.
        LOOP AT gt_cond_tab ASSIGNING <fs_cond_tab>
                                      WHERE tablename EQ iv_tabname.

          LOOP AT <fs_cond_tab>-where_tab ASSIGNING <fs_where_tab>.
            SHIFT <fs_where_tab>-line LEFT DELETING LEADING space.
          ENDLOOP.

* Begin of change DB FIX TCURR
*          READ TABLE lt_relations WITH KEY tabname = <fs_cond_tab>-tablename
*                                  INTO ls_relations.
*          IF sy-subrc EQ 0.
*            APPEND INITIAL LINE TO lt_cond_tab ASSIGNING <fs_cond_tab_tmp>.
*            <fs_cond_tab_tmp>-tablename = <fs_cond_tab>-tablename .
*            <fs_cond_tab_tmp>-where_tab = <fs_cond_tab>-where_tab .
*          ENDIF.
          IF <fs_cond_tab>-tablename = iv_tabname.
            APPEND INITIAL LINE TO lt_cond_tab ASSIGNING <fs_cond_tab_tmp>.
            <fs_cond_tab_tmp>-tablename = <fs_cond_tab>-tablename .
            <fs_cond_tab_tmp>-where_tab = <fs_cond_tab>-where_tab .
          ENDIF.
* End of change DB FIX TCURR
        ENDLOOP.

        LOOP AT lt_relations_for_all ASSIGNING <fs_relations>.
          IF NOT <fs_relations>-parent_relation IS INITIAL.
            READ TABLE gt_columns_all WITH KEY tabname = <fs_relations>-parent_relation
                                           fldname = <fs_relations>-field_main
                                           ASSIGNING <fs_columns>.
            IF sy-subrc EQ 0.
              IF gv_alias EQ abap_true.
                IF NOT <fs_columns>-alias_fldname IS INITIAL.
                  lv_field = <fs_columns>-alias_fldname.
                ELSE.
                  lv_field = <fs_columns>-fldname.
                ENDIF.
              ELSE.
                lv_field = <fs_columns>-fldname.
              ENDIF.
            ELSE.
              lv_field = <fs_relations>-field_sec.
            ENDIF.

            IF gv_alias ne abap_true.
              READ TABLE gt_converted INTO ls_conv WITH KEY tabname = <fs_relations>-parent_relation
                                                                  fldname  = lv_field.
              IF sy-subrc = 0.
                lv_field = ls_conv-fldname1.
              ENDIF.  "23.06.26 frg short alias begin
            ELSE.
              READ TABLE gt_converted INTO ls_conv WITH KEY tabname = <fs_relations>-parent_relation
                                                            alias_fldname  = lv_field.
              IF sy-subrc = 0.
                lv_field = ls_conv-alias_fldname1.
              ENDIF.
            ENDIF. "23.06.26 frg short alias end

            READ TABLE gt_relations WITH KEY tabname = <fs_relations>-parent_relation
                                    ASSIGNING  <fs_relations_parent> .

            IF abap_false = me->is_cds_entity( iv_tabname ).
              lv_field = '<fs_table_for_all>-' &&
                         lv_field              &&
                         <fs_relations_parent>-sequence.

            ELSE.
              lv_field = '@<fs_table_for_all>-' &&
                            lv_field              &&
                            <fs_relations_parent>-sequence.
            ENDIF.

            TRANSLATE lv_field TO UPPER CASE.
            APPEND INITIAL LINE TO r_where ASSIGNING <fs_where>.
            CONCATENATE '('
                         <fs_relations>-field_sec
                        'EQ'
                         lv_field
                         ')'
                        INTO <fs_where>-line
                        SEPARATED BY space.

            APPEND INITIAL LINE TO r_where ASSIGNING <fs_where>.
            <fs_where>-line = 'AND'.
          ENDIF.
        ENDLOOP.

        LOOP AT lt_relations ASSIGNING <fs_relations>.

* Begin of change DB FIX TCURR
*          READ TABLE lt_cond_tab WITH KEY tablename = <fs_relations>-tabname
*                                 INTO ls_cond_tab.
*
*          IF sy-subrc EQ 0.
*            LOOP AT ls_cond_tab-where_tab ASSIGNING <fs_where_tab_tmp>.
*              APPEND INITIAL LINE TO r_where ASSIGNING <fs_where>.
*              <fs_where>-line = <fs_where_tab_tmp>-line.
*            ENDLOOP.
*            APPEND INITIAL LINE TO r_where ASSIGNING <fs_where>.
*            <fs_where>-line = 'AND'.
*          ENDIF.
          LOOP AT lt_cond_tab ASSIGNING <fs_cond_tab_tmp>
                              WHERE tablename = <fs_relations>-tabname.

            LOOP AT <fs_cond_tab_tmp>-where_tab ASSIGNING <fs_where_tab_tmp>.
              APPEND INITIAL LINE TO r_where ASSIGNING <fs_where>.
              <fs_where>-line = <fs_where_tab_tmp>-line.
            ENDLOOP.

            APPEND INITIAL LINE TO r_where ASSIGNING <fs_where>.
            <fs_where>-line = 'AND'.

          ENDLOOP.

* End of change DB FIX TCURR

        ENDLOOP.

        IF NOT gt_filters IS INITIAL.
          LOOP AT gt_filters ASSIGNING <fs_filter>.

            READ TABLE lt_relations WITH KEY tabname = <fs_filter>-tabname
                                    INTO ls_relations.

            IF sy-subrc EQ 0.

              APPEND INITIAL LINE TO r_where ASSIGNING <fs_where>.

              <fs_where>-line = <fs_filter>-where_clause.

              FIND 'OR' IN <fs_where>-line.
              IF sy-subrc NE 0.
                FIND 'AND' IN <fs_where>-line.
                IF sy-subrc EQ 0.
                  REPLACE 'AND' WITH space INTO <fs_where>-line.
                ENDIF.
              ENDIF.

              IF sy-subrc EQ 0.
                lv_or = abap_true.
              ELSE.
                APPEND INITIAL LINE TO r_where ASSIGNING <fs_where>.

                <fs_where>-line = 'AND'.

              ENDIF.

            ENDIF.

          ENDLOOP.
        ENDIF.

        IF lv_or EQ abap_false OR
           gt_filters IS INITIAL.
          lv_lines = lines( r_where ).

          IF lv_lines NE 0.
            DELETE r_where INDEX lv_lines.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.
**  METHOD get_where.
**    TYPES: BEGIN OF lty_rsds_where,
**             tablename TYPE rsdstabs-prim_tab,
**             where_tab TYPE zonttrsdswhere,
**           END OF lty_rsds_where.
**
**    TYPES: ty_rsds_twhere TYPE STANDARD TABLE OF lty_rsds_where.
**
**    DATA selid          TYPE rsdynsel-selid.
**    DATA field_tab      TYPE TABLE OF rsdsfields.
**    DATA field_tab_excl TYPE TABLE OF rsdsfields.
**    DATA table_tab      TYPE TABLE OF rsdstabs.
**    DATA cond_tab       TYPE rsds_twhere.
**    DATA lv_title       TYPE sy-title.
**    DATA: lv_join       TYPE string.
**    DATA: lt_relations         TYPE STANDARD TABLE OF zonta_relations,
**          lt_relations_for_all TYPE STANDARD TABLE OF zonta_relations,
**          lt_columns           TYPE STANDARD TABLE OF zonta_oc_columns,
**          lt_cond_tab          TYPE ty_rsds_twhere,
**          ls_relations         TYPE zonta_relations,
**          ls_cond_tab          TYPE LINE OF ty_rsds_twhere,
**          lv_lines             TYPE sy-tabix,
**          lv_sequence          TYPE string,
**          lv_tabname           TYPE  ddobjname,
**          lv_field             TYPE string,
**          lv_or                TYPE boolean.
**    FIELD-SYMBOLS: <fs_relations>        TYPE zonta_relations,
**                   <fs_relations_parent> TYPE zonta_relations,
**                   <fs_table_tab>        TYPE rsdstabs,
**                   <fs_dfies_tab_cat>    TYPE dfies,
**                   <fs_field_tab_excl>   TYPE rsdsfields,
**                   <fs_cond_tab>         TYPE LINE OF rsds_twhere,
**                   <fs_cond_tab_tmp>     TYPE LINE OF ty_rsds_twhere,
**                   <fs_where_tab>        TYPE LINE OF rsds_where_tab,
**                   <fs_where_tab_tmp>    TYPE LINE OF zonttrsdswhere,
**                   <fs_where>            TYPE LINE OF zonttrsdswhere,
**                   <fs_where_tab_line>   TYPE LINE OF rsds_where_tab,
**                   <fs_filter>           TYPE zonta_oc_filters,
**                   <fs_columns>          TYPE zonta_oc_col_all.
**
**    IF NOT gt_cond_tab IS INITIAL.
**
**      lt_relations         = gt_relations.
**      lt_relations_for_all = gt_relations.
**
**      DELETE lt_relations WHERE tabname NE iv_tabname.
**      DELETE lt_relations_for_all WHERE tabname NE iv_tabname.
**
**      DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING sequence.
**
**      SORT lt_relations BY sequence.
**      SORT lt_relations BY sequence subsequence.
**
**      IF NOT gv_anytable IS INITIAL.
**        LOOP AT gt_cond_tab ASSIGNING <fs_cond_tab>.
**          LOOP AT <fs_cond_tab>-where_tab ASSIGNING <fs_where_tab>.
**            SHIFT <fs_where_tab>-line LEFT DELETING LEADING space.
**          ENDLOOP.
**          r_where = <fs_cond_tab>-where_tab.
**        ENDLOOP.
**      ELSE.
**        LOOP AT gt_cond_tab ASSIGNING <fs_cond_tab>
**                                      WHERE tablename EQ iv_tabname.
**
**          LOOP AT <fs_cond_tab>-where_tab ASSIGNING <fs_where_tab>.
**            SHIFT <fs_where_tab>-line LEFT DELETING LEADING space.
**          ENDLOOP.
**
**          READ TABLE lt_relations WITH KEY tabname = <fs_cond_tab>-tablename
**                                  INTO ls_relations.
**          IF sy-subrc EQ 0.
**            APPEND INITIAL LINE TO lt_cond_tab ASSIGNING <fs_cond_tab_tmp>.
**            <fs_cond_tab_tmp>-tablename = <fs_cond_tab>-tablename .
**            <fs_cond_tab_tmp>-where_tab = <fs_cond_tab>-where_tab .
**          ENDIF.
**        ENDLOOP.
**
**        LOOP AT lt_relations_for_all ASSIGNING <fs_relations>.
**          IF NOT <fs_relations>-parent_relation IS INITIAL.
**            READ TABLE gt_columns_all WITH KEY tabname = <fs_relations>-parent_relation
**                                           fldname = <fs_relations>-field_main
**                                           ASSIGNING <fs_columns>.
**            IF sy-subrc EQ 0.
**              IF gv_alias EQ abap_true.
**                IF NOT <fs_columns>-alias_fldname IS INITIAL.
**                  lv_field = <fs_columns>-alias_fldname.
**                ELSE.
**                  lv_field = <fs_columns>-fldname.
**                ENDIF.
**              ELSE.
**                lv_field = <fs_columns>-fldname.
**              ENDIF.
**            ELSE.
**              lv_field = <fs_relations>-field_sec.
**            ENDIF.
**
**            READ TABLE gt_converted INTO DATA(ls_conv) WITH KEY tabname = <fs_relations>-parent_relation
**                                               fldname  = lv_field.
**            IF sy-subrc = 0.
**              lv_field = ls_conv-fldname1.
**            ENDIF.
**
**            READ TABLE gt_relations WITH KEY tabname = <fs_relations>-parent_relation
**                                    ASSIGNING  <fs_relations_parent> .
**
**            IF abap_false = me->is_cds_entity( iv_tabname ).
**              lv_field = '<fs_table_for_all>-' &&
**                         lv_field              &&
**                         <fs_relations_parent>-sequence.
**
**            ELSE.
**              lv_field = '@<fs_table_for_all>-' &&
**                            lv_field              &&
**                            <fs_relations_parent>-sequence.
**            ENDIF.
**
**            TRANSLATE lv_field TO UPPER CASE.
**            APPEND INITIAL LINE TO r_where ASSIGNING <fs_where>.
**            CONCATENATE '('
**                         <fs_relations>-field_sec
**                        'EQ'
**                         lv_field
**                         ')'
**                        INTO <fs_where>-line
**                        SEPARATED BY space.
**
**            APPEND INITIAL LINE TO r_where ASSIGNING <fs_where>.
**            <fs_where>-line = 'AND'.
**          ENDIF.
**        ENDLOOP.
**
**        LOOP AT lt_relations ASSIGNING <fs_relations>.
**
**          READ TABLE lt_cond_tab WITH KEY tablename = <fs_relations>-tabname
**                                 INTO ls_cond_tab.
**
**          IF sy-subrc EQ 0.
**
**            LOOP AT ls_cond_tab-where_tab ASSIGNING <fs_where_tab_tmp>.
**
**              APPEND INITIAL LINE TO r_where ASSIGNING <fs_where>.
**
**              <fs_where>-line = <fs_where_tab_tmp>-line.
**
**            ENDLOOP.
**            APPEND INITIAL LINE TO r_where ASSIGNING <fs_where>.
**
**            <fs_where>-line = 'AND'.
**          ENDIF.
**
**        ENDLOOP.
**
**        IF NOT gt_filters IS INITIAL.
**          LOOP AT gt_filters ASSIGNING <fs_filter>.
**
**            READ TABLE lt_relations WITH KEY tabname = <fs_filter>-tabname
**                                    INTO ls_relations.
**
**            IF sy-subrc EQ 0.
**
**              APPEND INITIAL LINE TO r_where ASSIGNING <fs_where>.
**
**              <fs_where>-line = <fs_filter>-where_clause.
**
**              FIND 'OR' IN <fs_where>-line.
**              IF sy-subrc NE 0.
**                FIND 'AND' IN <fs_where>-line.
**                IF sy-subrc EQ 0.
**                  REPLACE 'AND' WITH space INTO <fs_where>-line.
**                ENDIF.
**              ENDIF.
**
**              IF sy-subrc EQ 0.
**                lv_or = abap_true.
**              ELSE.
**                APPEND INITIAL LINE TO r_where ASSIGNING <fs_where>.
**
**                <fs_where>-line = 'AND'.
**
**              ENDIF.
**
**            ENDIF.
**
**          ENDLOOP.
**        ENDIF.
**
**        IF lv_or EQ abap_false OR
**           gt_filters IS INITIAL.
**          lv_lines = lines( r_where ).
**
**          IF lv_lines NE 0.
**            DELETE r_where INDEX lv_lines.
**          ENDIF.
**        ENDIF.
**      ENDIF.
**    ENDIF.
**  ENDMETHOD.


  METHOD interpret_message.

data: lv_msgv1 type SYMSGV,
      lv_msgv2 type SYMSGV,
      lv_msgv3 type SYMSGV,
      lv_msgv4 type SYMSGV.

      lv_msgv1 = iv_msgv1.
      lv_msgv2 = iv_msgv2.
      lv_msgv3 = iv_msgv3.
      lv_msgv4 = iv_msgv4.

    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
        msgid               = 'ZON_CL_OC'
        msgnr               = iv_msgnr
        msgv1               = lv_msgv1
        msgv2               = lv_msgv2
        msgv3               = lv_msgv3
        msgv4               = lv_msgv4
      IMPORTING
        message_text_output = ev_message.

    APPEND ev_message TO ct_table.

  ENDMETHOD.


  METHOD is_cds_entity.
    DATA: lv_is_ddic TYPE dd03l-tabname.
    SELECT SINGLE tabname
        FROM dd03l
       INTO lv_is_ddic
      WHERE tabname = iv_tabname.
    IF sy-subrc EQ 0.
      rv_is_cds_entity = abap_false.
    ELSE.
      rv_is_cds_entity = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD metadata_conversion.


    CONSTANTS: c_byte      TYPE c  VALUE 'b',
               c_integer   TYPE c  VALUE 'I',
               c_rawstring TYPE c  VALUE 'y',
               c_string    TYPE c  VALUE 'C',
               c_256       TYPE c  LENGTH 6 VALUE '000256'.

    CASE cv_type.
      WHEN c_byte.   "byte
        cv_type = c_integer.
      WHEN c_rawstring.
        cv_type = c_string.
        cv_len  = c_256.
    ENDCASE.

  ENDMETHOD.


METHOD normalize_where_keys.
  " Map alias fieldnames to technical for a given table
  " and remove "is_line-" prefixes that appear in get_key().
  " In:  iv_where  (possibly aliasy)
  " Out: ev_where  (pure technical)

  DATA: lt_cols TYPE STANDARD TABLE OF zonta_oc_col_all,
        ls_col  TYPE zonta_oc_col_all.

  ev_where = iv_where.

  REPLACE ALL OCCURRENCES OF 'is_line-' IN ev_where WITH ''.

  lt_cols = gt_columns_all.
  DELETE lt_cols WHERE tabname NE iv_tabname.

  LOOP AT lt_cols INTO ls_col
       WHERE alias_fldname IS NOT INITIAL
         AND fldname       IS NOT INITIAL.
    REPLACE ALL OCCURRENCES OF ls_col-alias_fldname IN ev_where
      WITH ls_col-fldname.
  ENDLOOP.
ENDMETHOD.


  METHOD pretty_json.
    CONSTANTS: lc_empty  TYPE string VALUE ',"data":[]',
               lc_empty2 TYPE string VALUE '"data":{"table":""},',
               lc_empty3 TYPE string VALUE ',"data":{"table":""}',
               lc_guion  TYPE c      VALUE '_',
               lc_qm     TYPE c      VALUE '"'.

    DATA: lt_relations   TYPE STANDARD TABLE OF zonta_relations,
          lv_tabname     TYPE string,
          lv_data        TYPE string,
          lv_find        TYPE string,
          lv_replace     TYPE string,
          lv_bothnames   TYPE string,
          lv_type_binary TYPE string,
          lv_type_string TYPE string.

    FIELD-SYMBOLS: <fs_relation> TYPE zonta_relations.

    lt_relations = gt_relations.
    SORT lt_relations BY sequence.
    DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING sequence.

*  Replace Binary metadata with Character
    lv_type_binary = '"type":"X"'.
    lv_type_string = '"type":"C"'.
    REPLACE ALL OCCURRENCES OF lv_type_binary IN cv_json WITH lv_type_string.

*BEGIN CECHAVARRIA 19/08/2025
*  Replace data null with space
    lv_type_binary = 'null'.
    lv_type_string = '""'.
    REPLACE ALL OCCURRENCES OF lv_type_binary IN cv_json WITH lv_type_string.
*END CECHAVARRIA 19/08/2025

* Added Feb2026
  IF gv_kdoc = abap_true.
    LOOP AT lt_relations ASSIGNING <fs_relation>.
      CONCATENATE 'seq' <fs_relation>-sequence INTO lv_tabname.
      TRANSLATE lv_tabname TO LOWER CASE.
      lv_find = lc_qm && lv_tabname && lc_qm && ':{' &&  lc_qm && 'table' && lc_qm && ':' && lc_qm && lc_qm && ','.
      lv_replace = lc_qm && lv_tabname && lc_qm && ':{' &&  lc_qm && 'table' && lc_qm && ':' && lc_qm && lv_tabname && lc_qm && ','.
      REPLACE ALL OCCURRENCES OF lv_find IN cv_json WITH lv_replace.
    ENDLOOP.
  ENDIF.
* End of Added Feb2026

    IF iv_mode = c_kdoc.
      LOOP AT lt_relations ASSIGNING <fs_relation>.
        CONCATENATE 'SEQ' <fs_relation>-sequence INTO lv_tabname.
        TRANSLATE lv_tabname TO LOWER CASE.


        REPLACE ALL OCCURRENCES OF '/'  IN <fs_relation>-alias_tabname WITH lc_guion.
        REPLACE ALL OCCURRENCES OF '\'  IN <fs_relation>-alias_tabname WITH lc_guion.

        REPLACE ALL OCCURRENCES OF '/'  IN <fs_relation>-tabname WITH lc_guion.
        REPLACE ALL OCCURRENCES OF '\'  IN <fs_relation>-tabname WITH lc_guion.

        IF gv_bothnames = abap_true.
          CONCATENATE <fs_relation>-tabname lc_guion <fs_relation>-alias_tabname INTO lv_bothnames.
          REPLACE ALL OCCURRENCES OF lv_tabname IN cv_json WITH lv_bothnames.
          CONCATENATE lc_qm 'table' lc_qm ':' lc_qm <fs_relation>-tabname lc_qm INTO lv_find.
          CONCATENATE lc_qm 'table' lc_qm ':' lc_qm lv_bothnames lc_qm INTO lv_replace.
          "table":"EKPO",
          REPLACE ALL OCCURRENCES OF lv_find IN cv_json WITH lv_replace.
        ELSEIF gv_fieldname IS INITIAL.
          IF <fs_relation>-alias_tabname IS NOT INITIAL.
            REPLACE ALL OCCURRENCES OF lv_tabname IN cv_json WITH <fs_relation>-alias_tabname.
            REPLACE ALL OCCURRENCES OF <fs_relation>-tabname IN cv_json WITH <fs_relation>-alias_tabname. "++DB Feb2026
          ELSE.
            REPLACE ALL OCCURRENCES OF lv_tabname IN cv_json WITH <fs_relation>-tabname.
          ENDIF.
        ELSE.
          REPLACE ALL OCCURRENCES OF lv_tabname IN cv_json WITH <fs_relation>-tabname.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF iv_mode = c_table.
      LOOP AT lt_relations ASSIGNING <fs_relation>.
        CONCATENATE '"' 'SEQ' <fs_relation>-sequence '":' INTO lv_data.
        TRANSLATE lv_data TO LOWER CASE.
        REPLACE ALL OCCURRENCES OF lv_data IN cv_json WITH '"data":'.

        CONCATENATE 'SEQ' <fs_relation>-sequence INTO lv_tabname.
        TRANSLATE lv_tabname TO LOWER CASE.

        REPLACE ALL OCCURRENCES OF '/'  IN <fs_relation>-alias_tabname WITH lc_guion.
        REPLACE ALL OCCURRENCES OF '\'  IN <fs_relation>-alias_tabname WITH lc_guion.

        REPLACE ALL OCCURRENCES OF '/'  IN <fs_relation>-tabname WITH lc_guion.
        REPLACE ALL OCCURRENCES OF '\'  IN <fs_relation>-tabname WITH lc_guion.

        IF gv_bothnames = abap_true.
          CONCATENATE <fs_relation>-tabname lc_guion <fs_relation>-alias_tabname INTO lv_bothnames.
          REPLACE ALL OCCURRENCES OF lv_tabname IN cv_json WITH lv_bothnames.
        ELSEIF gv_fieldname IS INITIAL.
          IF <fs_relation>-alias_tabname IS NOT INITIAL.
            REPLACE ALL OCCURRENCES OF lv_tabname IN cv_json WITH <fs_relation>-alias_tabname.
          ELSE.
            REPLACE ALL OCCURRENCES OF lv_tabname IN cv_json WITH <fs_relation>-tabname.
          ENDIF.
        ELSE.
          REPLACE ALL OCCURRENCES OF lv_tabname IN cv_json WITH <fs_relation>-tabname.
        ENDIF.

        REPLACE ALL OCCURRENCES OF lc_empty  IN cv_json WITH space.
        REPLACE ALL OCCURRENCES OF lc_empty2 IN cv_json WITH space.
        REPLACE ALL OCCURRENCES OF lc_empty3 IN cv_json WITH space.
      ENDLOOP.

      REPLACE ALL OCCURRENCES OF '[*]' IN cv_json WITH '[]'.
    ENDIF.

    REPLACE 'messagetype' WITH 'messageType' INTO cv_json.
    REPLACE 'TABL'        WITH 'TABLE'        INTO cv_json.

    IF gv_bothnames = abap_true.
      me->alias_both_json(
        EXPORTING
          iv_option = c_both
        CHANGING
          cv_json   = cv_json ).
    ENDIF.

    IF gv_fieldname IS INITIAL AND gv_bothnames IS INITIAL.
      me->alias_both_json(
        EXPORTING
          iv_option = c_alias
        CHANGING
          cv_json   = cv_json ).
    ENDIF.

    IF gv_fieldname = abap_true.
      me->fieldname_json( CHANGING cv_json = cv_json ).
    ENDIF.
  ENDMETHOD.


  METHOD print_error.


    DATA: lo_out                      TYPE REF TO if_demo_output.

    lo_out = cl_demo_output=>new( ).
    lo_out->begin_section( 'ONE CONNECT EXECUTION LOG' ).

    lo_out->write_data( gv_entity ).

    lo_out->write_data( gx_text->get_text( ) ).
    lo_out->write_data( gx_text->get_longtext( ) ).
    lo_out->write_data( sy-cprog ).
    lo_out->write_data( sy-repid ).
    lo_out->write_data( |Error in { gv_prog } at line { gv_sline } | ).

    lo_out->display( ).

  ENDMETHOD.


  METHOD print_error_otel.

    DATA: lo_out   TYPE REF TO if_demo_output,
          lw_param TYPE zonta_oc_param.

    SELECT SINGLE * FROM zonta_oc_param INTO lw_param WHERE name = 'RFC_OTEL'.
    IF lw_param-low IS NOT INITIAL.
      lo_out = cl_demo_output=>new( ).
      lo_out->begin_section( 'ONE CONNECT EXECUTION LOG' ).

      lo_out->write_data( gv_entity ).

      lo_out->write_data( sy-cprog ).
      lo_out->write_data( sy-repid ).
      lo_out->write_data( |Error in { gv_prog } at line { gv_sline } | ).

      lo_out->begin_section( 'POSSIBLE CAUSES' ).
      FIELD-SYMBOLS <lv_line> type clike.
      LOOP AT gt_causes ASSIGNING <lv_line>.
        lo_out->write_text( <lv_line> ).
      ENDLOOP.

      lo_out->begin_section( 'POSSIBLE FIXES' ).
      LOOP AT gt_fixes ASSIGNING <lv_line>.
        lo_out->write_text( <lv_line> ).
      ENDLOOP.

      lo_out->display( ).
    ENDIF.

  ENDMETHOD.


METHOD replace_data_body.

  DATA: lv_from   TYPE string,
        lv_to     TYPE string,
        lv_before TYPE string,
        lv_after  TYPE string,
        lv_data   TYPE string,
        lv_pos1   TYPE i,
        lv_pos2   TYPE i,
        lv_len    TYPE i,
        lv_temp_json TYPE string.

  IF iv_technical IS INITIAL OR iv_alias_fldname IS INITIAL.
    RETURN.
  ENDIF.

  FIND '"data":[' IN cv_json MATCH OFFSET lv_pos1.
  IF sy-subrc <> 0.
    RETURN. " No data section found
  ENDIF.

  lv_temp_json = cv_json+lv_pos1.
  FIND ']' IN lv_temp_json MATCH OFFSET lv_pos2.
  IF sy-subrc <> 0.
    RETURN. " No closing bracket
  ENDIF.
  lv_pos2 = lv_pos2 + lv_pos1.

  lv_len = lv_pos2 - lv_pos1.
  lv_data = cv_json+lv_pos1(lv_len).

  lv_from = |"{ iv_technical }":|.
  lv_to   = |"{ iv_alias_fldname }":|.
  REPLACE ALL OCCURRENCES OF lv_from IN lv_data WITH lv_to IGNORING CASE.

  lv_before = cv_json+0(lv_pos1).
  lv_after  = cv_json+lv_pos2.
  CONCATENATE lv_before lv_data lv_after INTO cv_json.

ENDMETHOD.


  METHOD replace_data_metadata.

    DATA: lv_source        TYPE string,
          lv_target        TYPE string,
          lv_technical     TYPE string,
          lv_alias_fldname TYPE string,
          ls_conv          LIKE LINE OF gt_converted,
          lv_technical2    TYPE string,
          lv_alias2    TYPE string.

    FIELD-SYMBOLS: <fs_col> TYPE zonta_oc_col_all.

    SORT gt_converted BY tabname fldname.


    READ TABLE gt_converted INTO ls_conv WITH KEY tabname = iv_tabname
                                                  alias_fldname = iv_alias_fldname.
    IF sy-subrc = 0.
      lv_alias_fldname = ls_conv-alias_fldname1.
      lv_alias2        = ls_conv-alias_fldname.
    ELSE.
      lv_alias_fldname = iv_alias_fldname.
      lv_alias2        = iv_alias_fldname.
    ENDIF.

    TRANSLATE lv_alias_fldname TO UPPER CASE.
    TRANSLATE lv_alias2        TO UPPER CASE.


    READ TABLE gt_converted INTO ls_conv WITH KEY tabname = iv_tabname
                                                  fldname = iv_technical BINARY SEARCH.
    IF sy-subrc = 0.
      lv_technical = ls_conv-fldname1.
      lv_technical2 = ls_conv-fldname.
    ELSE.
      lv_technical = iv_technical.
      lv_technical2 = lv_technical.
    ENDIF.


    " Handle nested aliasing
**    READ TABLE gt_columns_all ASSIGNING <fs_col> WITH KEY fldname = lv_alias_fldname.
    READ TABLE gt_columns_all ASSIGNING <fs_col> WITH KEY tabname = iv_tabname fldname = lv_alias_fldname.
    IF sy-subrc = 0 AND lv_alias_fldname <> lv_technical.
      me->replace_data_metadata(
        EXPORTING
          iv_tabname       = iv_tabname
          iv_alias_tabname = iv_alias_tabname
          iv_technical     = <fs_col>-fldname
          iv_alias_fldname = <fs_col>-alias_fldname
          iv_option        = iv_option
        CHANGING
          cv_json          = cv_json ).
    ENDIF.


    " Transform metadata fieldname
    lv_technical     = to_lower( lv_technical ).
    lv_alias_fldname = to_lower( lv_alias_fldname ).

    lv_source = |"fieldname":"{ lv_technical }"|.
*    lv_target = COND string(
*                  WHEN iv_option = c_alias
*                  THEN |"fieldname":"{ lv_alias_fldname }"|
*                  ELSE |"fieldname":"{ lv_technical }_{ lv_alias_fldname }"|
*               ).
    IF iv_option = c_alias.
      CONCATENATE '"fieldname":"' lv_alias_fldname '"' INTO lv_target.
    ELSE.
      CONCATENATE '"fieldname":"' lv_technical '_' lv_alias_fldname '"' INTO lv_target.
    ENDIF.

    REPLACE ALL OCCURRENCES OF '\' IN lv_target WITH '_'.
    REPLACE ALL OCCURRENCES OF '/' IN lv_target WITH '_'.
    REPLACE ALL OCCURRENCES OF lv_source IN cv_json WITH lv_target.

    " Transform actual data fieldname
    lv_source = |"{ lv_technical }":|.

    TRANSLATE lv_technical2 TO LOWER CASE.
    IF lv_technical NE lv_technical2.
      lv_technical = lv_technical2.
    ENDIF.
    TRANSLATE lv_alias2 TO LOWER CASE.
    IF lv_alias_fldname NE lv_alias2.
      lv_alias_fldname = lv_alias2.
    ENDIF.


*    lv_target = COND string(
*                  WHEN iv_option = c_alias
*                  THEN |"{ lv_alias_fldname }":|
*                  ELSE |"{ lv_technical }_{ lv_alias_fldname }":|
*               ).

    IF iv_option = c_alias.
      CONCATENATE '"' lv_alias_fldname '":'   INTO lv_target.
    ELSE.
      CONCATENATE '"' lv_technical '_' lv_alias_fldname '":'    INTO lv_target.
    ENDIF.

    REPLACE ALL OCCURRENCES OF '\' IN lv_target WITH '_'.
    REPLACE ALL OCCURRENCES OF '/' IN lv_target WITH '_'.
    REPLACE ALL OCCURRENCES OF lv_source IN cv_json WITH lv_target.

  ENDMETHOD.


  METHOD return_log_table.
    et_log_ext = gt_log_ext[].
  ENDMETHOD.


  METHOD return_where_variables.
    et_condtab  = gt_cond_tab[].
    et_fieldtab = gt_fieldtab[].
  ENDMETHOD.


METHOD send_http_with_failover.

  DATA:
    lo_client        TYPE REF TO if_http_client,
    lv_subrc         TYPE sy-subrc,
    lv_reason        TYPE string,
    lv_try_secondary TYPE abap_bool VALUE abap_false.

  FIELD-SYMBOLS: <fs_log_ext> LIKE LINE OF gt_log_ext.

  ev_comm_error = abap_false.
  gv_dest = iv_primary_dest.

  "---------------------------
  " 1. Try PRIMARY
  "---------------------------
*  lo_client =
  me->create_destination(
    EXPORTING
      iv_destination = iv_primary_dest
      iv_secondary   = abap_false
    IMPORTING
      ev_subrc       = lv_subrc
ro_http_client = lo_client ).

  IF lv_subrc <> 0.
    lv_try_secondary = abap_true.
  ELSE.
    CALL METHOD me->send_receive_http
      EXPORTING
        io_client      = lo_client
        iv_payload     = iv_payload
      IMPORTING
        ev_http_code   = ev_http_code
        ev_http_reason = ev_http_reason
        ev_response    = ev_response
        ev_comm_error  = ev_comm_error
        ev_error_text  = ev_error_message.

    IF ev_comm_error = abap_true.
      lv_try_secondary = abap_true.
*      gv_primary = iv_primary_dest.
      me->append_slg1_log(
        EXPORTING
        iv_tabname    = space
        iv_message_v1 = |Primary destination failure ({ gv_primary })|
        iv_message_v2 = space
        iv_message_v3 = space
        iv_mestyp     = 'E'
        ).

      me->append_slg1_log(
       EXPORTING
       iv_tabname    = space
       iv_message_v1 = ev_error_message
       iv_message_v2 = space
       iv_message_v3 = space
       iv_mestyp     = 'E'
       ).
    ELSE.
      ev_used_dest = iv_primary_dest.
      RETURN.
    ENDIF.
  ENDIF.

  "---------------------------
  " 2. Try SECONDARY
  "---------------------------
  SELECT SINGLE low INTO gv_secondary
    FROM zonta_oc_param
    WHERE name = 'RFC_SECONDARY'.

  IF gv_secondary IS INITIAL.
    ev_comm_error = abap_true.
    ev_error_message = 'Primary failed and no secondary configured'.
    me->append_slg1_log(
      EXPORTING
      iv_tabname    = space
      iv_message_v1 = ev_error_message
      iv_message_v2 = space
      iv_message_v3 = space
      iv_mestyp     = 'E'
      ).
    RETURN.
  ENDIF.

*  lo_client =
  me->create_destination(
    EXPORTING
      iv_destination = gv_secondary
      iv_secondary   = abap_true
    IMPORTING
      ev_subrc       = lv_subrc
     ro_http_client = lo_client
     ).

  IF lv_subrc <> 0.
    ev_comm_error = abap_true.
    ev_error_message = 'Secondary destination creation failed'.
    me->append_slg1_log(
      EXPORTING
      iv_tabname    = space
      iv_message_v1 = ev_error_message
      iv_message_v2 = space
      iv_message_v3 = space
      iv_mestyp     = 'E'
      ).
    RETURN.
  ENDIF.

  CALL METHOD me->send_receive_http
    EXPORTING
      io_client      = lo_client
      iv_payload     = iv_payload
    IMPORTING
      ev_http_code   = ev_http_code
      ev_http_reason = ev_http_reason
      ev_response    = ev_response
      ev_comm_error  = ev_comm_error
      ev_error_text  = ev_error_message.

  IF ev_comm_error = abap_false.
    ev_used_dest = gv_secondary.
  ELSE.
    me->append_slg1_log(
      EXPORTING
      iv_tabname    = space
      iv_message_v1 = |Secondary destination failure ({ gv_secondary })|
      iv_message_v2 = space
      iv_message_v3 = space
      iv_mestyp     = 'E'
      ).

    me->append_slg1_log(
      EXPORTING
      iv_tabname    = space
      iv_message_v1 = ev_error_message
      iv_message_v2 = space
      iv_message_v3 = space
      iv_mestyp     = 'E'
      ).
  ENDIF.

  IF ev_used_dest = gv_secondary.
    LOOP AT gt_log_ext ASSIGNING <fs_log_ext> WHERE tabname IS NOT INITIAL AND json_id = gv_jsonid.
      <fs_log_ext>-endpoint = ev_used_dest.
    ENDLOOP.

  ENDIF.

ENDMETHOD.


  METHOD send_json_error.

    DATA: lv_message   TYPE string,
          lv_text      TYPE char128,
          lv_errorj    TYPE zonta_oc_param-low,
          ls_errorl    TYPE zonst_log_otel,
          lv_timestamp TYPE timestamp,
          lv_times     TYPE string,
          lv_env       TYPE char50,
          ls_context   TYPE zonst_log_otel_context,
          ls_correl    TYPE zontt_log_otel_corr.

    ls_context-user_id = sy-uname.

    lv_timestamp = me->get_timestamp( ).
    lv_times = |{ lv_timestamp TIMESTAMP = ISO }.000Z|.
    lv_env       = sy-sysid && sy-mandt.
    gv_event_id  = gs_oc_obj-cdobjectcl && lv_timestamp.
    SELECT SINGLE low INTO lv_errorj  FROM zonta_oc_param WHERE name = 'ERROR_JSON'.
    IF sy-subrc = 0 AND lv_errorj = 'X'.
*      ls_errorl = VALUE zonst_log_otel(
*      event_id  = gv_event_id
*      timestamp = lv_times
*      service-name   = gv_entity
*      type      = gs_elog-type
*      severity  = gs_elog-severity
*      message   = gs_elog-message
*      details   = gs_elog-details "VALUE zonst_log_otel_details( )
*      context   = ls_context   "VALUE zonst_log_otel_context( user_id = sy-uname )
*      metadata  = VALUE zonst_log_otel_metadata( environment = lv_env )
*     ).
      CLEAR ls_errorl. " Siempre es buena práctica limpiar antes
      ls_errorl-event_id     = gv_event_id.
      ls_errorl-timestamp    = lv_times.
      ls_errorl-service-name = gv_entity.
      ls_errorl-type         = gs_elog-type.
      ls_errorl-severity     = gs_elog-severity.
      ls_errorl-message      = gs_elog-message.
      ls_errorl-details      = gs_elog-details.
      ls_errorl-context      = ls_context.
      CLEAR ls_errorl-metadata.
      ls_errorl-metadata-environment = lv_env.

      send_log_otel( is_log_otel = ls_errorl ).
      CLEAR gs_elog.
      REFRESH gt_causes.
      REFRESH gt_fixes.
    ENDIF.

  ENDMETHOD.


  METHOD send_json_http_con.
    CONSTANTS: lc_error           TYPE char2 VALUE 'E',
               lc_process         TYPE char2 VALUE 'P',
               lc_type            TYPE zonta_oc_param-type VALUE 'P',
               lc_use_resend_json TYPE zonta_oc_param-name VALUE 'USE_RESEND_JSON'.

    DATA:
      lv_response     TYPE string,
      lv_subrc        TYPE sy-subrc,
      lv_return       TYPE string,
      lv_string       TYPE string,
      lv_stini        TYPE timestamp,
      lv_stfin        TYPE timestamp,
      lo_http_client  TYPE REF TO if_http_client,
      lv_destination  TYPE rfcdes-rfcdest,
      lv_servicenr    TYPE rfcdisplay-rfcsysid,
      lv_server       TYPE rfcdisplay-rfchost,
      lv_path_prefix  TYPE string,
      lv_err_string   TYPE string,
      lv_ret_code     TYPE sy-subrc,
      lv_ret_codes    TYPE string,
      r_str           TYPE string,
      result_tab      TYPE TABLE OF string,
      lv_dest         TYPE rfcdest,
      lv_table        TYPE char20,
      lv_low          TYPE rfcdest,
      lv_size         TYPE zonde_oc_num30,
      ls_paramter     TYPE zonta_oc_param, "cechavarria 15/08/2025
      lv_json         TYPE string, "symsgv.
      lv_message      TYPE string, "symsgv.
      lv_message1     TYPE string, "symsgv.
      lv_message2     TYPE string, "symsgv.
      lv_message3     TYPE string, "symsgv.
      lv_good_to_send TYPE boolean_flg,
      lv_sizes        TYPE string.
*BEGIN CECHAVARRIA 15/08/2025
*If json_prev is true only show json
    do. enddo.
    IF gv_json_prev = abap_true.
      IF gv_send_immediately = abap_true AND gv_send_immediately_json = abap_false.
        MESSAGE i128(zon_cl_oc).
        gv_send_immediately_json = abap_true.
      ENDIF.
      cl_demo_output=>display_json( json = gv_json ).
*      ELSE.
*        DATA lr_json TYPE REF TO zoncl_oc_json.
*        CREATE OBJECT lr_json.
*        lr_json->display( EXPORTING iv_json = gv_json  iv_immediately = gv_send_immediately ).
*        lr_json->set_json( EXPORTING iv_json = gv_json ).
*        lr_json->show_popup( EXPORTING iv_immediately = gv_send_immediately ).
      RETURN.
*      ENDIF.
    ENDIF.


*If parameter is true save json in log sap
    IF ls_paramter-low EQ abap_true.
*      TRY.
*          zoncl_json_save_log=>log_json_data( iv_json_string = gv_json ).
*        CATCH cx_bali_runtime INTO DATA(lx_error).
*          gs_elog-type       = 'ZONCL_JSON_SAVE_LOG'.
*          gs_elog-severity   = gc_error.
*          gs_elog-message    = lx_error->get_longtext( ).
*          CALL METHOD lx_error->get_source_position
*            IMPORTING
*              program_name = gv_prog
*              source_line  = gv_sline.
*          gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
*          gs_elog-details-db = 'ZONCL_OC_BASE_HANDLER-SEND_JSON_HTTP_CON'.
*          gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.
*
*          gs_elog-metadata-error_code = gs_elog-details-error_code.
*          interpret_message( EXPORTING iv_msgnr = '056' IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
*          interpret_message( EXPORTING iv_msgnr = '057' IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
*          interpret_message( EXPORTING iv_msgnr = '058' IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
*          interpret_message( EXPORTING iv_msgnr = '059' IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
*          interpret_message( EXPORTING iv_msgnr = '060' IMPORTING ev_message = gv_msg5 CHANGING ct_table = gt_causes ).
*          CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 gv_msg5 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
*          interpret_message( EXPORTING iv_msgnr = '061' iv_msgv1 = zoncl_rapevent_factory=>gc_log_object iv_msgv2 = zoncl_rapevent_factory=>gc_jsonlog_subobject
*                             IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
*          gs_elog-metadata-possible_fix = gv_msg1.
*          print_error_otel( ).
*          send_json_error( ).
*          MESSAGE lx_error->get_text( ) TYPE 'E'.
*      ENDTRY.
    ENDIF.
*END CECHAVARRIA 15/08/2025

    CLEAR:lv_string.
    GET TIME STAMP FIELD lv_stini.

    lv_low = i_dest.
    lv_json = gv_json.
    IF lv_low IS NOT INITIAL.
      lv_dest = lv_low.
      CLEAR gv_secondary.

***revisar 17.02
      CALL METHOD me->create_destination
        EXPORTING
          iv_destination = lv_dest
          iv_secondary   = abap_true
        IMPORTING
          ev_subrc       = lv_subrc
*  RECEIVING
          ro_http_client = lo_http_client.
      IF lv_subrc NE 0.
*BEGIN CECHAVARRIA 28/08/2025
        IF me->gv_uuid IS NOT INITIAL.
          me->update_table_json(
            iv_json    = gv_json
            iv_uuid    = me->gv_uuid
            iv_message = lv_message
            iv_status_code  = lc_error
          ).
        ENDIF.
*END CECHAVARRIA 28/08/2025
        EXIT.
      ENDIF.
**11.04.26 frg validate SYNCRONOS inicia
      DATA lv_get_resp TYPE c.
      CALL FUNCTION 'RFC_READ_HTTP_DESTINATION'
        EXPORTING
          destination             = lv_dest
         AUTHORITY_CHECK               = ' '
        IMPORTING
          path_prefix             = lv_path_prefix
        EXCEPTIONS
          authority_not_available = 1
          destination_not_exist   = 2
          information_failure     = 3
          internal_failure        = 4
          no_http_destination     = 5
          OTHERS                  = 6.
      IF sy-subrc = 0.
        CLEAR lv_get_resp.
        IF lv_path_prefix CS '/synchronous'.
          lv_get_resp = 'X'.
        ENDIF.
      ELSE.
          lv_get_resp = 'X'.
      ENDIF.

**11.04.26 frg validate SYNCRONos termina
      DATA lv_payload_x TYPE xstring.
      CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
        EXPORTING
          text   = me->gv_json
        IMPORTING
          buffer = lv_payload_x.

* Checking size of json to validate if this is allowed
      lv_size = xstrlen( lv_payload_x ).
      CALL METHOD me->check_json_size
        EXPORTING
          iv_size        = lv_size
        RECEIVING
          r_good_to_send = lv_good_to_send.

      IF lv_good_to_send = abap_true.
        lo_http_client->request->set_method( 'POST' ).
        lo_http_client->request->set_content_type( 'text/plain' ).
        lo_http_client->request->set_data( lv_payload_x ).

* Sending the request
        lo_http_client->send(
                              EXCEPTIONS http_communication_failure = 1
                                         http_invalid_state         = 2 ).
**do.enddo.
        IF sy-subrc NE 0.
          lo_http_client->get_last_error( IMPORTING   message = lv_message ).
          me->append_slg1_log(
            EXPORTING
             iv_tabname    = space
             iv_message_v1 = lv_message
             iv_message_v2 = space
             iv_message_v3 = space
             iv_mestyp     = 'E' ).


          gs_elog-type       = 'SEND_JSON_HTTP_CON'.
          gs_elog-severity   = gc_error.
          gs_elog-message    = lv_message.

          gs_elog-details-query = |Error while sending to  { lv_dest } |.
          gs_elog-details-db = 'SENDING'.
          gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

          gs_elog-metadata-error_code = gs_elog-details-error_code.
          send_json_error( ).

*BEGIN CECHAVARRIA 28/08/2025
          IF me->gv_uuid IS NOT INITIAL.
            me->update_table_json(
              iv_json = gv_json
              iv_uuid = me->gv_uuid
              iv_message = lv_message
              iv_status_code  = lc_error
            ).
          ENDIF.
*END CECHAVARRIA 28/08/2025
          EXIT.
        ENDIF.
        IF lv_get_resp ne 'X'.
          wait UP TO 2 SECONDS.
        endif.
        IF lv_get_resp = 'X'.
* Receiving the response
          lo_http_client->receive( EXCEPTIONS  http_communication_failure = 1
                                               http_invalid_state         = 2
                                               http_processing_failed     = 3 ).
          IF sy-subrc NE 0.

            lo_http_client->get_last_error( IMPORTING   message = lv_message ).
            SELECT SINGLE low
              INTO gv_secondary
              FROM zonta_oc_param
              WHERE name = 'RFC_SECONDARY'.
            IF gv_secondary = lv_dest.
              CLEAR gv_secondary.
            ENDIF.

            me->append_slg1_log(
              EXPORTING
               iv_tabname    = space
               iv_message_v1 = lv_message
               iv_message_v2 = space
               iv_message_v3 = space
               iv_mestyp     = 'E' ).

            gs_elog-type       = 'SEND_JSON_HTTP_CON'.
            gs_elog-severity   = gc_error.
            gs_elog-message    = lv_message.

            gs_elog-details-query = |Error while receiving from  { lv_dest } |.
            gs_elog-details-db = 'RECEIVING'.
            gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

            gs_elog-metadata-error_code = gs_elog-details-error_code.
            send_json_error( ).

*BEGIN CECHAVARRIA 28/08/2025
            IF me->gv_uuid IS NOT INITIAL.
              me->update_table_json(
                iv_json = gv_json
                iv_uuid = me->gv_uuid
                iv_message = lv_message
                iv_status_code  = lc_error
              ).
            ENDIF.
*END CECHAVARRIA 28/08/2025
            IF gv_secondary IS INITIAL.
              me->append_slg1_log(
                EXPORTING
                 iv_tabname    = space
                 iv_message_v1 = |'No secondary endpoint is defined'|
                 iv_message_v2 = space
                 iv_message_v3 = space
                 iv_mestyp     = 'E' ).

              gs_elog-type       = 'SEND_JSON_HTTP_CON'.
              gs_elog-severity   = gc_error.
              gs_elog-message    = |'No secondary endpoint is defined'|.

              gs_elog-details-query = |'No secondary endpoint is defined'|.
              gs_elog-details-db = 'NO_SECONDARY_ENDPOINT'.
              gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

              gs_elog-metadata-error_code = gs_elog-details-error_code.
              send_json_error( ).

              EXIT.  "check
            ENDIF.
          ENDIF.
        ENDIF.

*IF is TM not commit
        IF gv_tm = abap_false.
          IF cl_system_transaction_state=>get_in_update_task( ) = abap_false.
            COMMIT WORK .
          ENDIF.
        ENDIF.
        IF lv_get_resp = 'X'.
          lo_http_client->response->get_status( IMPORTING  code   = lv_ret_code
                                                           reason = lv_err_string ).
        ELSE.
          lv_ret_code = 200.
        ENDIF.
        IF NOT ( lv_ret_code BETWEEN 200 AND 299 ).

          lv_message = lv_ret_code &&
                       '-'         &&
                       lv_err_string.
          me->append_slg1_log(
            EXPORTING
             iv_tabname    = space
             iv_message_v1 = lv_message
             iv_message_v2 = space
             iv_message_v3 = space
             iv_mestyp     = 'E' ).

          gs_elog-type       = 'SEND_JSON_HTTP_CON'.
          gs_elog-severity   = gc_error.
          gs_elog-message    = lv_message.

          gs_elog-details-query = |Error while taking response from { lv_dest } |.
          gs_elog-details-db = 'RESPONSE'.
          gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

          gs_elog-metadata-error_code = gs_elog-details-error_code.
          send_json_error( ).

*BEGIN CECHAVARRIA 28/08/2025
          IF me->gv_uuid IS NOT INITIAL.
            me->update_table_json(
              iv_json     = gv_json
              iv_uuid     = me->gv_uuid
              iv_message  = lv_message
              iv_ret_code = lv_ret_code
              iv_status_code   = lc_error
            ).
          ENDIF.
*END CECHAVARRIA 28/08/2025
          IF gv_secondary IS INITIAL.
*            EXIT.
            CLEAR lv_size.
          ENDIF.
        ENDIF.

        CLEAR lv_response .
        IF lv_get_resp = 'X'.
          lv_response = lo_http_client->response->get_cdata( ).
*          do. enddo.
***add new record to log begin
          DATA: i_parce  TYPE TABLE OF zonst_field50,
                i_parce1 TYPE TABLE OF zonst_field50,
                w_parce  TYPE zonst_field50,
                w_parce1 TYPE zonst_field50,
                lv_res   TYPE c.
          CLEAR: lv_res .

          IF ( lv_ret_code BETWEEN 200 AND 299 ).
            lv_res = 'S'.
          ELSE.
            lv_res = 'E'.
          ENDIF.

          IF lv_response IS NOT INITIAL.
            CLEAR lv_message.
            CASE lv_res.
              WHEN 'S'.
                REPLACE ALL OCCURRENCES OF '{' IN lv_response WITH ''.
                REPLACE ALL OCCURRENCES OF '}' IN lv_response WITH ''.
                SPLIT lv_response AT ',' INTO TABLE i_parce.
                READ TABLE i_parce INTO w_parce INDEX 1.
                REPLACE ALL OCCURRENCES OF '{' IN lv_json WITH ''.
                REPLACE ALL OCCURRENCES OF '}' IN lv_json WITH ''.
                SPLIT lv_json AT ',' INTO TABLE i_parce1.
                READ TABLE i_parce1 INTO w_parce1 INDEX 12.
                REPLACE '"metadata":[' INTO w_parce1 WITH ''.
                CONCATENATE w_parce1 w_parce INTO lv_message SEPARATED BY '-'.
              WHEN 'E'.
                REPLACE ALL OCCURRENCES OF '{' IN lv_response WITH ''.
                REPLACE ALL OCCURRENCES OF '}' IN lv_response WITH ''.
                SPLIT lv_response AT ',' INTO TABLE i_parce.
                READ TABLE i_parce INTO w_parce INDEX 1.
                REPLACE ALL OCCURRENCES OF '{' IN lv_json WITH ''.
                REPLACE ALL OCCURRENCES OF '}' IN lv_json WITH ''.
                SPLIT lv_json AT ',' INTO TABLE i_parce1.
                READ TABLE i_parce1 INTO w_parce1 INDEX 12.
                REPLACE '"metadata":[' INTO w_parce1 WITH ''.
                CONCATENATE w_parce1 w_parce INTO lv_message SEPARATED BY '-'.
              WHEN OTHERS.
            ENDCASE.
          ENDIF.
        ELSE.
          lv_res = 'S'.
        ENDIF.
***add new record to log begin

        CLEAR result_tab .
        SPLIT lv_response AT cl_abap_char_utilities=>cr_lf INTO TABLE result_tab .

        CALL METHOD lo_http_client->close.

        GET TIME STAMP FIELD lv_stfin.
* Not sending due to size
      ELSE.
        lv_response = 'Not sending due to size exceeds maximum allowed'.
        lv_message  = lv_response.
        SHIFT lv_size LEFT DELETING LEADING '0'.
        lv_sizes    = lv_size.

        CLEAR lv_ret_code.
        me->append_slg1_log(
           EXPORTING
            iv_tabname    = space
            iv_message_v1 = lv_message
            iv_message_v2 = lv_sizes
            iv_message_v3 = space
            iv_mestyp     = 'E' ).

        gs_elog-type       = 'SEND_JSON_HTTP_CON'.
        gs_elog-severity   = gc_error.
        gs_elog-message    = lv_message.

        gs_elog-details-query = |Maximun size allowed exceeds|.
        gs_elog-details-db = 'MAXIMUM_SIZE_EXCEEDS'.
        gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

        gs_elog-metadata-error_code = gs_elog-details-error_code.
        send_json_error( ).

        CLEAR lv_size.
      ENDIF.  "size
    ENDIF.  "low

*BEGIN CECHAVARRIA 28/08/2025
    IF me->gv_uuid IS NOT INITIAL.
      CLEAR ls_paramter.

      IF ls_paramter-low EQ abap_true.
        me->update_table_json(
                       iv_json = gv_json
                       iv_uuid = me->gv_uuid
                       iv_status_code = lc_process
                       iv_zoffset = lv_size
        ).
      ELSE.
*        DELETE FROM zonta_oc_fetch_r WHERE uuid_rec = me->gv_uuid.
      ENDIF.
    ENDIF.
*END CECHAVARRIA 28/08/2025

    IF gv_secondary IS NOT INITIAL.
      CLEAR lv_size.
      me->append_slg1_log(
       EXPORTING
        iv_tabname    = space
        iv_message_v1 = |Primary endpoint { lv_dest } not working, trying with Secondary { gv_secondary }|
        iv_message_v2 = space
        iv_message_v3 = space
        iv_mestyp     = 'E' ).

      gs_elog-type       = 'SEND_JSON_HTTP_CON'.
      gs_elog-severity   = gc_error.
      gs_elog-message    = lv_message.

      gs_elog-details-query = |Primary endpoint { lv_dest } not working, trying with Secondary { gv_secondary }|.
      gs_elog-details-db = 'PRIMARY_ENDPOINT_FAILURE'.
      gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

      gs_elog-metadata-error_code = gs_elog-details-error_code.
      send_json_error( ).

      me->send_json_http_con(
        EXPORTING
          i_dest     = gv_secondary
        IMPORTING
          e_return   = lv_ret_codes
          e_size     = lv_size
          e_records  = e_records
          e_response = lv_response ).
      lv_ret_code = lv_ret_codes.
      lv_dest = gv_secondary.
    ENDIF.

    IF gv_dest NE lv_dest.
      gv_secondary = lv_dest.

      FIELD-SYMBOLS:  <fs_log_ext> LIKE LINE OF gt_log_ext.

*      LOOP AT gt_log_ext ASSIGNING field-symbol(<fs_log_ext>) WHERE tabname IS NOT INITIAL AND json_id >= gv_jsonid.
      LOOP AT gt_log_ext ASSIGNING <fs_log_ext> WHERE tabname IS NOT INITIAL AND json_id >= gv_jsonid.
        <fs_log_ext>-endpoint = gv_secondary.
      ENDLOOP.
      gv_dest = gv_secondary.
    ENDIF.

    e_response = lv_response.
    e_return   = lv_ret_code.
    e_size     = lv_size.


  ENDMETHOD.


METHOD SEND_JSON_HTTP_CON_NEW.
*BEGIN CECHAVARRIA 28/08/2025
  CONSTANTS:
    lc_error           TYPE char2 VALUE 'E',
    lc_process         TYPE char2 VALUE 'P',
    lc_type            TYPE zonta_oc_param-type VALUE 'P',
    lc_use_resend_json TYPE zonta_oc_param-name VALUE 'USE_RESEND_JSON'.
*END CECHAVARRIA 28/08/2025
  DATA:
    lv_response      TYPE string,
    lv_message       TYPE string,
    lv_json          TYPE string,
    lv_size          TYPE zonde_oc_num30,
    lv_sizes         TYPE string,
    lv_dest          TYPE rfcdest,
    lv_low           TYPE rfcdest,
    lv_good_to_send  TYPE boolean_flg,
    lv_payload_x     TYPE xstring,
    lv_http_code     TYPE i,
    lv_used_dest     TYPE rfcdest,
    lv_comm_error    TYPE boolean_flg,
    lv_error_message TYPE string,
    ls_paramter      TYPE zonta_oc_param,
    result_tab       TYPE TABLE OF string.
  gv_commit = abap_true.
*--------------------------------------------------------------------*
* JSON preview
*--------------------------------------------------------------------*
  IF gv_json_prev = abap_true.
    cl_demo_output=>display_json( json = gv_json ).
    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* Save JSON in log if parameter active
*--------------------------------------------------------------------*
*  zoncl_json_save_log=>get_parameter_active_log(
*    EXPORTING
*      iv_name_parameter = zoncl_rapevent_factory=>gc_json_log_name
*      iv_type           = zoncl_rapevent_factory=>gc_json_log_type
*    IMPORTING
*      es_parameter      = ls_paramter
*  ).

  IF ls_paramter-low EQ abap_true.
*    TRY.
*        zoncl_json_save_log=>log_json_data( iv_json_string = gv_json ).
*      CATCH cx_bali_runtime INTO DATA(lx_error).
*        gs_elog-type     = 'ZONCL_JSON_SAVE_LOG'.
*        gs_elog-severity = gc_error.
*        gs_elog-message  = lx_error->get_longtext( ).
*
*        CALL METHOD lx_error->get_source_position
*          IMPORTING
*            program_name = gv_prog
*            source_line  = gv_sline.
*
*        gs_elog-details-query     = |Error in { gv_prog } at line { gv_sline } |.
*        gs_elog-details-db        = 'ZONCL_OC_BASE_HANDLER-SEND_JSON_HTTP_CON'.
*        gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.
*        gs_elog-metadata-error_code = gs_elog-details-error_code.
*
*        interpret_message( EXPORTING iv_msgnr = '056' IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
*        interpret_message( EXPORTING iv_msgnr = '057' IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
*        interpret_message( EXPORTING iv_msgnr = '058' IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
*        interpret_message( EXPORTING iv_msgnr = '059' IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
*        interpret_message( EXPORTING iv_msgnr = '060' IMPORTING ev_message = gv_msg5 CHANGING ct_table = gt_causes ).
*
*        CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 gv_msg5
*          INTO gs_elog-metadata-possible_cause
*          SEPARATED BY cl_abap_char_utilities=>newline.
*
*        interpret_message(
*          EXPORTING
*            iv_msgnr = '061'
*            iv_msgv1 = zoncl_rapevent_factory=>gc_log_object
*            iv_msgv2 = zoncl_rapevent_factory=>gc_jsonlog_subobject
*          IMPORTING
*            ev_message = gv_msg1
*          CHANGING
*            ct_table = gt_fixes
*        ).
*
*        gs_elog-metadata-possible_fix = gv_msg1.
*
*        print_error_otel( ).
*        send_json_error( ).
*        MESSAGE lx_error->get_text( ) TYPE 'E'.
*    ENDTRY.
  ENDIF.

*--------------------------------------------------------------------*
* Prepare payload
*--------------------------------------------------------------------*
  lv_low  = i_dest.
  lv_json = gv_json.

  IF lv_low IS INITIAL.
    RETURN.
  ENDIF.

  lv_dest = lv_low.

  CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
    EXPORTING
      text   = gv_json
    IMPORTING
      buffer = lv_payload_x.

*--------------------------------------------------------------------*
* Size validation
*--------------------------------------------------------------------*
  lv_size = xstrlen( lv_payload_x ).

  me->check_json_size(
    EXPORTING
      iv_size        = lv_size
    RECEIVING
      r_good_to_send = lv_good_to_send
  ).

  IF lv_good_to_send <> abap_true.
    lv_response = 'Not sending due to size exceeds maximum allowed'.
    lv_message  = lv_response.
    SHIFT lv_size LEFT DELETING LEADING '0'.
    lv_sizes = lv_size.

    me->append_slg1_log(
      EXPORTING
        iv_tabname    = space
        iv_message_v1 = lv_message
        iv_message_v2 = lv_sizes
        iv_message_v3 = space
        iv_mestyp     = 'E'
    ).
    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* SEND with failover (NEW)
*--------------------------------------------------------------------*
  me->send_http_with_failover(
    EXPORTING
      iv_primary_dest = lv_dest
      iv_payload      = lv_payload_x
    IMPORTING
      ev_response      = lv_response
      ev_http_code     = lv_http_code
      ev_used_dest     = lv_used_dest
      ev_comm_error    = lv_comm_error
      ev_error_message = lv_error_message
  ).

*--------------------------------------------------------------------*
* Communication error
*--------------------------------------------------------------------*
  IF lv_comm_error = abap_true.

    me->append_slg1_log(
      EXPORTING
        iv_tabname    = space
        iv_message_v1 = |HTTP communication error ({ lv_used_dest }): { lv_error_message }|
        iv_message_v2 = space
        iv_message_v3 = space
        iv_mestyp     = 'E'
    ).

*BEGIN CECHAVARRIA 28/08/2025
    IF me->gv_uuid IS NOT INITIAL.
      me->update_table_json(
        iv_json        = gv_json
        iv_uuid        = me->gv_uuid
        iv_message     = lv_error_message
        iv_status_code = lc_error
      ).
    ENDIF.
*END CECHAVARRIA 28/08/2025
    CLEAR lv_size.
*    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* HTTP application error
*--------------------------------------------------------------------*
  IF NOT ( lv_http_code BETWEEN 200 AND 299 ).

    lv_message = |HTTP { lv_http_code } - { lv_error_message }|.

    me->append_slg1_log(
      EXPORTING
        iv_tabname    = space
        iv_message_v1 = lv_message
        iv_message_v2 = space
        iv_message_v3 = space
        iv_mestyp     = 'E'
    ).

*BEGIN CECHAVARRIA 28/08/2025
    IF me->gv_uuid IS NOT INITIAL.
      me->update_table_json(
        iv_json        = gv_json
        iv_uuid        = me->gv_uuid
        iv_message     = lv_message
        iv_ret_code    = lv_http_code
        iv_status_code = lc_error
      ).
    ENDIF.
*END CECHAVARRIA 28/08/2025

    CLEAR lv_size.
*    RETURN.
  ENDIF.

*--------------------------------------------------------------------*
* Success path (original logic preserved)
*--------------------------------------------------------------------*
  CLEAR result_tab.
  SPLIT lv_response AT cl_abap_char_utilities=>cr_lf INTO TABLE result_tab.

*--------------------------------------------------------------------*
* Resend / cleanup logic (unchanged)
*--------------------------------------------------------------------*
*BEGIN CECHAVARRIA 28/08/2025
  IF me->gv_uuid IS NOT INITIAL.

    CLEAR ls_paramter.

*    zoncl_json_save_log=>get_parameter_active_log(
*      EXPORTING
*        iv_name_parameter = lc_use_resend_json
*        iv_type           = lc_type
*      IMPORTING
*        es_parameter      = ls_paramter
*    ).

    IF ls_paramter-low EQ abap_true.
      me->update_table_json(
        iv_json        = gv_json
        iv_uuid        = me->gv_uuid
        iv_status_code = lc_process
        iv_zoffset     = lv_size
      ).
    ELSE.
*      DELETE FROM zonta_oc_fetch_r WHERE uuid_rec = me->gv_uuid.
    ENDIF.

  ENDIF.
*END CECHAVARRIA 28/08/2025

*--------------------------------------------------------------------*
* Output
*--------------------------------------------------------------------*
  e_response = lv_response.
  e_return   = lv_http_code.
  e_size     = lv_size.

ENDMETHOD.


**  METHOD send_json_http_con.
***BEGIN CECHAVARRIA 28/08/2025
**    CONSTANTS: lc_error           TYPE char2 VALUE 'E',
**               lc_process         TYPE char2 VALUE 'P',
**               lc_type            TYPE zonta_oc_param-type VALUE 'P',
**               lc_use_resend_json TYPE zonta_oc_param-name VALUE 'USE_RESEND_JSON'.
***END CECHAVARRIA 28/08/2025
**
**    DATA:
**      lv_response     TYPE string,
**      lv_subrc        TYPE sy-subrc,
**      lv_return       TYPE string,
**      lv_string       TYPE string,
**      lv_stini        TYPE timestamp,
**      lv_stfin        TYPE timestamp,
**      lo_http_client  TYPE REF TO if_http_client,
**      lv_destination  TYPE rfcdes-rfcdest,
**      lv_servicenr    TYPE rfcdisplay-rfcsysid,
**      lv_server       TYPE rfcdisplay-rfchost,
**      lv_path_prefix  TYPE string,
**      lv_err_string   TYPE string,
**      lv_ret_code     TYPE sy-subrc,
**      r_str           TYPE string,
**      result_tab      TYPE TABLE OF string,
**      lv_dest         TYPE rfcdest,
**      lv_table        TYPE char20,
**      lv_low          TYPE rfcdest,
**      lv_size         TYPE zonde_oc_num30,
**      ls_paramter     TYPE zonta_oc_param, "cechavarria 15/08/2025
**      lv_json         TYPE string, "symsgv.
**      lv_message      TYPE string, "symsgv.
**      lv_message1     TYPE string, "symsgv.
**      lv_message2     TYPE string, "symsgv.
**      lv_message3     TYPE string, "symsgv.
**      lv_good_to_send TYPE abap_boolean,
**      lv_sizes        TYPE string.
**
**
**
***BEGIN CECHAVARRIA 15/08/2025
***If json_prev is true only show json
**    IF gv_json_prev = abap_true.
**      cl_demo_output=>display_json( json = gv_json ).
**      RETURN.
**    ENDIF.
**
**    zoncl_json_save_log=>get_parameter_active_log(
**      EXPORTING
**        iv_name_parameter = zoncl_rapevent_factory=>gc_json_log_name
**        iv_type           = zoncl_rapevent_factory=>gc_json_log_type
**      IMPORTING
**        es_parameter      = ls_paramter
**    ).
**
***If parameter is true save json in log sap
**    IF ls_paramter-low EQ abap_true.
**      TRY.
**          zoncl_json_save_log=>log_json_data( iv_json_string = gv_json ).
**        CATCH cx_bali_runtime INTO DATA(lx_error).
**          gs_elog-type       = 'ZONCL_JSON_SAVE_LOG'.
**          gs_elog-severity   = gc_error.
**          gs_elog-message    = lx_error->get_longtext( ).
**          CALL METHOD lx_error->get_source_position
**            IMPORTING
**              program_name = gv_prog
**              source_line  = gv_sline.
**          gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
**          gs_elog-details-db = 'ZONCL_OC_BASE_HANDLER-SEND_JSON_HTTP_CON'.
**          gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.
**
**          gs_elog-metadata-error_code = gs_elog-details-error_code.
**          interpret_message( EXPORTING iv_msgnr = '056' IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
**          interpret_message( EXPORTING iv_msgnr = '057' IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
**          interpret_message( EXPORTING iv_msgnr = '058' IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
**          interpret_message( EXPORTING iv_msgnr = '059' IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
**          interpret_message( EXPORTING iv_msgnr = '060' IMPORTING ev_message = gv_msg5 CHANGING ct_table = gt_causes ).
**          CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 gv_msg5 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
**          interpret_message( EXPORTING iv_msgnr = '061' iv_msgv1 = zoncl_rapevent_factory=>gc_log_object iv_msgv2 = zoncl_rapevent_factory=>gc_jsonlog_subobject
**                             IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
**          gs_elog-metadata-possible_fix = gv_msg1.
**          print_error_otel( ).
**          send_json_error( ).
**          MESSAGE lx_error->get_text( ) TYPE 'E'.
**      ENDTRY.
**    ENDIF.
***END CECHAVARRIA 15/08/2025
**
**    CLEAR:lv_string.
**    GET TIME STAMP FIELD lv_stini.
**
**    lv_low = i_dest.
**    lv_json = gv_json.
**    IF lv_low IS NOT INITIAL.
**      lv_dest = lv_low.
**      lo_http_client  =  me->create_destination( EXPORTING iv_destination =  lv_dest
**                                                           iv_secondary   =  abap_true
**                                                 IMPORTING ev_subrc       =  lv_subrc ).     " Logical destination (specified in function call)
**
**
**      IF lv_subrc NE 0.
***BEGIN CECHAVARRIA 28/08/2025
**        IF me->gv_uuid IS NOT INITIAL.
**          me->update_table_json(
**            iv_json    = gv_json
**            iv_uuid    = me->gv_uuid
**            iv_message = lv_message
**            iv_status_code  = lc_error
**          ).
**        ENDIF.
***END CECHAVARRIA 28/08/2025
**        EXIT.
**      ENDIF.
**
**
**      DATA lv_payload_x TYPE xstring.
**      CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
**        EXPORTING
**          text   = me->gv_json
**        IMPORTING
**          buffer = lv_payload_x.
**
*** Checking size of json to validate if this is allowed
**      lv_size = xstrlen( lv_payload_x ).
**      CALL METHOD me->check_json_size
**        EXPORTING
**          iv_size        = lv_size
**        RECEIVING
**          r_good_to_send = lv_good_to_send.
**
**
**      IF sy-uname = 'FRGDEV' . DO. ENDDO. ENDIF.
**
**
**      IF lv_good_to_send = abap_true.
**        lo_http_client->request->set_method( 'POST' ).
**        lo_http_client->request->set_content_type( 'text/plain' ).
**        lo_http_client->request->set_data( lv_payload_x ).
**
*****DO . eNDDO.
*** Sending the request
**        lo_http_client->send(
**                              EXCEPTIONS http_communication_failure = 1
**                                         http_invalid_state         = 2 ).
**
**        CASE sy-subrc.
**          WHEN 1.
**            lv_message = TEXT-e06.
**          WHEN 2.
**            lv_message = TEXT-e07.
**        ENDCASE.
**
**        IF sy-subrc NE 0.
**          me->append_slg1_log(
**            EXPORTING
**             iv_tabname    = space
**             iv_message_v1 = lv_message
**             iv_message_v2 = space
**             iv_message_v3 = space
**             iv_mestyp     = 'E' ).
**
***BEGIN CECHAVARRIA 28/08/2025
**          IF me->gv_uuid IS NOT INITIAL.
**            me->update_table_json(
**              iv_json = gv_json
**              iv_uuid = me->gv_uuid
**              iv_message = lv_message
**              iv_status_code  = lc_error
**            ).
**          ENDIF.
***END CECHAVARRIA 28/08/2025
**          EXIT.
**        ENDIF.
**
*** Receiving the response
**        lo_http_client->receive( EXCEPTIONS  http_communication_failure = 1
**                                             http_invalid_state         = 2
**                                             http_processing_failed     = 3 ).
**
**        CASE sy-subrc.
**          WHEN 1.
**            lv_message = TEXT-e06.
**          WHEN 2.
**            lv_message = TEXT-e07.
**          WHEN 3.
**            lv_message = TEXT-e08.
**        ENDCASE.
**
**        IF sy-subrc NE 0.
**          me->append_slg1_log(
**            EXPORTING
**             iv_tabname    = space
***           iv_key        =
**             iv_message_v1 = lv_message
**             iv_message_v2 = space
**             iv_message_v3 = space
**             iv_mestyp     = 'E' ).
**
***BEGIN CECHAVARRIA 28/08/2025
**          IF me->gv_uuid IS NOT INITIAL.
**            me->update_table_json(
**              iv_json = gv_json
**              iv_uuid = me->gv_uuid
**              iv_message = lv_message
**              iv_status_code  = lc_error
**            ).
**          ENDIF.
***END CECHAVARRIA 28/08/2025
**          EXIT.
**        ENDIF.
**
***IF is TM not commit
**        IF gv_tm = abap_false.
**          IF cl_system_transaction_state=>get_in_update_task( ) = abap_false.
**            COMMIT WORK .
**          ENDIF.
**        ENDIF.
**
**        lo_http_client->response->get_status( IMPORTING  code   = lv_ret_code
**                                                         reason = lv_err_string ).
**
**        IF NOT ( lv_ret_code BETWEEN 200 AND 299 ).
**
**          lv_message = lv_ret_code &&
**                       '-'         &&
**                       lv_err_string.
**          me->append_slg1_log(
**            EXPORTING
**             iv_tabname    = space
***           iv_key        =
**             iv_message_v1 = lv_message
**             iv_message_v2 = space
**             iv_message_v3 = space
**             iv_mestyp     = 'E' ).
**
***BEGIN CECHAVARRIA 28/08/2025
**          IF me->gv_uuid IS NOT INITIAL.
**            me->update_table_json(
**              iv_json     = gv_json
**              iv_uuid     = me->gv_uuid
**              iv_message  = lv_message
**              iv_ret_code = lv_ret_code
**              iv_status_code   = lc_error
**            ).
**          ENDIF.
***END CECHAVARRIA 28/08/2025
**          EXIT.
**        ENDIF.
**
**        CLEAR lv_response .
**        lv_response = lo_http_client->response->get_cdata( ).
**
**
*****add new record to log begin
**        DATA: i_parce  TYPE TABLE OF zonst_field50,
**              i_parce1 TYPE TABLE OF zonst_field50,
**              w_parce  TYPE zonst_field50,
**              w_parce1 TYPE zonst_field50,
**              lv_res   TYPE c.
**        CLEAR: lv_res .
**
**        IF ( lv_ret_code BETWEEN 200 AND 299 ).
**          lv_res = 'S'.
**        ELSE.
**          lv_res = 'E'.
**        ENDIF.
**
**        IF lv_response IS NOT INITIAL.
**          CLEAR lv_message.
**          CASE lv_res.
**            WHEN 'S'.
**              REPLACE ALL OCCURRENCES OF '{' IN lv_response WITH ''.
**              REPLACE ALL OCCURRENCES OF '}' IN lv_response WITH ''.
**              SPLIT lv_response AT ',' INTO TABLE i_parce.
**              READ TABLE i_parce INTO w_parce INDEX 1.
**              REPLACE ALL OCCURRENCES OF '{' IN lv_json WITH ''.
**              REPLACE ALL OCCURRENCES OF '}' IN lv_json WITH ''.
**              SPLIT lv_json AT ',' INTO TABLE i_parce1.
**              READ TABLE i_parce1 INTO w_parce1 INDEX 12.
**              REPLACE '"metadata":[' INTO w_parce1 WITH ''.
**              CONCATENATE w_parce1 w_parce INTO lv_message SEPARATED BY '-'.
**            WHEN 'E'.
**              REPLACE ALL OCCURRENCES OF '{' IN lv_response WITH ''.
**              REPLACE ALL OCCURRENCES OF '}' IN lv_response WITH ''.
**              SPLIT lv_response AT ',' INTO TABLE i_parce.
**              READ TABLE i_parce INTO w_parce INDEX 1.
**              REPLACE ALL OCCURRENCES OF '{' IN lv_json WITH ''.
**              REPLACE ALL OCCURRENCES OF '}' IN lv_json WITH ''.
**              SPLIT lv_json AT ',' INTO TABLE i_parce1.
**              READ TABLE i_parce1 INTO w_parce1 INDEX 12.
**              REPLACE '"metadata":[' INTO w_parce1 WITH ''.
**              CONCATENATE w_parce1 w_parce INTO lv_message SEPARATED BY '-'.
**            WHEN OTHERS.
**          ENDCASE.
**
**          me->append_slg1_log(
**            EXPORTING
**             iv_tabname    = space
***           iv_key        =
**             iv_message_v1 = lv_message
**             iv_message_v2 = space
**             iv_message_v3 = space
**             iv_mestyp     = lv_res ).
**        ENDIF.
*****add new record to log begin
**
**        CLEAR result_tab .
**        SPLIT lv_response AT cl_abap_char_utilities=>cr_lf INTO TABLE result_tab .
**
**
**
**        CALL METHOD lo_http_client->close.
***      lv_size = xstrlen( lv_payload_x ).
**
**        GET TIME STAMP FIELD lv_stfin.
**        FORMAT COLOR 3.
**
**        FORMAT COLOR OFF.
***      ENDIF.
*** Not sending due to size
**      ELSE.
**        lv_response = 'Not sending due to size exceeds maximum allowed'.
**        lv_message  = lv_response.
**        SHIFT lv_size LEFT DELETING LEADING '0'.
**        lv_sizes    = lv_size.
**
**        CLEAR lv_ret_code.
**        me->append_slg1_log(
**           EXPORTING
**            iv_tabname    = space
**            iv_message_v1 = lv_message
**            iv_message_v2 = lv_sizes
**            iv_message_v3 = space
**            iv_mestyp     = 'E' ).
**
**        CLEAR lv_size.
**      ENDIF.  "size
**    ENDIF.  "low
**
***BEGIN CECHAVARRIA 28/08/2025
**    IF me->gv_uuid IS NOT INITIAL.
**      CLEAR ls_paramter.
**      zoncl_json_save_log=>get_parameter_active_log(
**        EXPORTING
**          iv_name_parameter = lc_use_resend_json
**          iv_type           = lc_type
**        IMPORTING
**          es_parameter      = ls_paramter
**      ).
**
**      IF ls_paramter-low EQ abap_true.
**        me->update_table_json(
**                       iv_json = gv_json
**                       iv_uuid = me->gv_uuid
**                       iv_status_code = lc_process
**                       iv_zoffset = lv_size
**        ).
**      ELSE.
**        DELETE FROM zonta_oc_fetch_r WHERE uuid_rec = me->gv_uuid.
**      ENDIF.
**    ENDIF.
***END CECHAVARRIA 28/08/2025
**
**    e_response = lv_response.
**    e_return   = lv_ret_code.
**    e_size     = lv_size.
**
**
**  ENDMETHOD.


  METHOD send_json_http_con_opencursor.

    DATA:
      lv_response     TYPE string,
      lv_return       TYPE string,
      lv_string       TYPE string,
      lv_stini        TYPE timestamp,
      lv_stfin        TYPE timestamp,
      lo_http_client  TYPE REF TO if_http_client,
      lv_destination  TYPE rfcdes-rfcdest,
      lv_servicenr    TYPE rfcdisplay-rfcsysid,
      lv_server       TYPE rfcdisplay-rfchost,
      lv_path_prefix  TYPE string,
      lv_err_string   TYPE string,
      lv_ret_code     TYPE sy-subrc,
      lv_ret_codes    TYPE string,
      r_str           TYPE string,
      result_tab      TYPE TABLE OF string,
      lv_dest         TYPE rfcdest,
      lv_table        TYPE char20,
      lv_low          TYPE rfcdest,
      lv_size         TYPE zonde_oc_num30,
      lv_subrc        TYPE sy-subrc,
      ls_paramter     TYPE zonta_oc_param, "cechavarria 15/08/2025
      lv_json         TYPE string, "symsgv.
      lv_message      TYPE string, "symsgv.
      lv_message1     TYPE string, "symsgv.
      lv_message2     TYPE string, "symsgv.
      lv_message3     TYPE string, "symsgv.
      lv_good_to_send TYPE boolean_flg,
      lv_sizes        TYPE string.
    IF gv_json IS INITIAL.
      gv_json = iv_json.
    ENDIF.

    CLEAR:lv_string.
    GET TIME STAMP FIELD lv_stini.

    lv_low = iv_dest.
    lv_json = gv_json.
    IF lv_low IS NOT INITIAL.
      lv_dest = lv_low.
      CLEAR gv_secondary.
***revisar 17.02
      CALL METHOD me->create_destination
        EXPORTING
          iv_destination = lv_dest
          iv_secondary   = abap_true
        IMPORTING
          ev_subrc       = lv_subrc
*  RECEIVING
          ro_http_client   = lo_http_client.

*      lo_http_client =  me->create_destination( EXPORTING iv_destination =  lv_dest
*                                                          iv_secondary   =  abap_true
*                                                IMPORTING ev_subrc       =  lv_subrc ).     " Logical destination (specified in function call)

      IF lv_subrc NE 0.
        EXIT.
      ENDIF.

      DATA lv_payload_x TYPE xstring.
      CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
        EXPORTING
          text   = me->gv_json
        IMPORTING
          buffer = lv_payload_x.

* Checking size of json to validate if this is allowed
      lv_size = xstrlen( lv_payload_x ).
      CALL METHOD me->check_json_size
        EXPORTING
          iv_size        = lv_size
        RECEIVING
          r_good_to_send = lv_good_to_send.

      IF lv_good_to_send = abap_true.

        lo_http_client->request->set_method( 'POST' ).
        lo_http_client->request->set_content_type( 'text/plain' ).
        lo_http_client->request->set_data( lv_payload_x ).

* Sending the request
        lo_http_client->send(
                              EXCEPTIONS http_communication_failure = 1
                                         http_invalid_state         = 2 ).

        IF sy-subrc NE 0.
          lo_http_client->get_last_error( IMPORTING   message = lv_message ).

          me->append_slg1_log(
            EXPORTING
             iv_tabname    = space
             iv_message_v1 = lv_message
             iv_message_v2 = space
             iv_message_v3 = space
             iv_mestyp     = 'E' ).

          gs_elog-type       = 'SEND_JSON_HTTP_CON_OPENCURSOR'.
          gs_elog-severity   = gc_error.
          gs_elog-message    = lv_message.

          gs_elog-details-query = |Error while sending to  { lv_dest } |.
          gs_elog-details-db = 'SENDING'.
          gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

          gs_elog-metadata-error_code = gs_elog-details-error_code.
          send_json_error( ).
          EXIT.
        ENDIF.

* Receiving the response
        lo_http_client->receive( EXCEPTIONS  http_communication_failure = 1
                                             http_invalid_state         = 2
                                             http_processing_failed     = 3 ).

        IF sy-subrc NE 0.
          lo_http_client->get_last_error( IMPORTING   message = lv_message ).
          SELECT SINGLE low
            INTO gv_secondary
            FROM zonta_oc_param
            WHERE name = 'RFC_SECONDARY'.
          IF gv_secondary = lv_dest.
            CLEAR gv_secondary.
          ENDIF.


          me->append_slg1_log(
            EXPORTING
             iv_tabname    = space
*           iv_key        =
             iv_message_v1 = lv_message
             iv_message_v2 = space
             iv_message_v3 = space
             iv_mestyp     = 'E' ).

          IF gv_secondary IS INITIAL.
            me->append_slg1_log(
              EXPORTING
               iv_tabname    = space
               iv_message_v1 = |'No secondary endpoint is defined'|
               iv_message_v2 = space
               iv_message_v3 = space
               iv_mestyp     = 'E' ).

            gs_elog-type       = 'SEND_JSON_HTTP_CON_OPENCURSOR'.
            gs_elog-severity   = gc_error.
            gs_elog-message    = lv_message.

            gs_elog-details-query = |Error while receiving from  { lv_dest } |.
            gs_elog-details-db = 'RECEIVING'.
            gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

            gs_elog-metadata-error_code = gs_elog-details-error_code.
            send_json_error( ).
            EXIT.  "check
          ENDIF.
        ENDIF.

        IF cl_system_transaction_state=>get_in_update_task( ) = abap_false.
          COMMIT WORK .
        ENDIF.

        lo_http_client->response->get_status( IMPORTING  code   = lv_ret_code
                                                         reason = lv_err_string ).

        IF NOT ( lv_ret_code BETWEEN 200 AND 299 ).

          lv_message = lv_ret_code &&
                       '-'         &&
                       lv_err_string.
          me->append_slg1_log(
            EXPORTING
             iv_tabname    = space
*           iv_key        =
             iv_message_v1 = lv_message
             iv_message_v2 = space
             iv_message_v3 = space
             iv_mestyp     = 'E' ).

          gs_elog-type       = 'SEND_JSON_HTTP_CON_OPENCURSOR'.
          gs_elog-severity   = gc_error.
          gs_elog-message    = lv_message.

          gs_elog-details-query = |Error while taking response from { lv_dest } |.
          gs_elog-details-db = 'RESPONSE'.
          gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

          gs_elog-metadata-error_code = gs_elog-details-error_code.
          send_json_error( ).

          EXIT.
        ENDIF.

        CLEAR lv_response .
        lv_response = lo_http_client->response->get_cdata( ).


***add new record to log begin
        DATA: i_parce  TYPE TABLE OF zonst_field50,
              i_parce1 TYPE TABLE OF zonst_field50,
              w_parce  TYPE zonst_field50,
              w_parce1 TYPE zonst_field50,
              lv_res   TYPE c.
        CLEAR: lv_res .

        IF ( lv_ret_code BETWEEN 200 AND 299 ).
          lv_res = 'S'.
        ELSE.
          lv_res = 'E'.
        ENDIF.

        IF lv_response IS NOT INITIAL.
          CLEAR lv_message.
          CASE lv_res.
            WHEN 'S'.
              REPLACE ALL OCCURRENCES OF '{' IN lv_response WITH ''.
              REPLACE ALL OCCURRENCES OF '}' IN lv_response WITH ''.
              SPLIT lv_response AT ',' INTO TABLE i_parce.
              READ TABLE i_parce INTO w_parce INDEX 1.
              REPLACE ALL OCCURRENCES OF '{' IN lv_json WITH ''.
              REPLACE ALL OCCURRENCES OF '}' IN lv_json WITH ''.
              SPLIT lv_json AT ',' INTO TABLE i_parce1.
              READ TABLE i_parce1 INTO w_parce1 INDEX 12.
              REPLACE '"metadata":[' INTO w_parce1 WITH ''.
              CONCATENATE w_parce1 w_parce INTO lv_message SEPARATED BY '-'.
            WHEN 'E'.
              REPLACE ALL OCCURRENCES OF '{' IN lv_response WITH ''.
              REPLACE ALL OCCURRENCES OF '}' IN lv_response WITH ''.
              SPLIT lv_response AT ',' INTO TABLE i_parce.
              READ TABLE i_parce INTO w_parce INDEX 1.
              REPLACE ALL OCCURRENCES OF '{' IN lv_json WITH ''.
              REPLACE ALL OCCURRENCES OF '}' IN lv_json WITH ''.
              SPLIT lv_json AT ',' INTO TABLE i_parce1.
              READ TABLE i_parce1 INTO w_parce1 INDEX 12.
              REPLACE '"metadata":[' INTO w_parce1 WITH ''.
              CONCATENATE w_parce1 w_parce INTO lv_message SEPARATED BY '-'.
            WHEN OTHERS.
          ENDCASE.

          me->append_slg1_log(
            EXPORTING
             iv_tabname    = space
*           iv_key        =
             iv_message_v1 = lv_message
             iv_message_v2 = space
             iv_message_v3 = space
             iv_mestyp     = lv_res ).
        ENDIF.
***add new record to log begin

        CLEAR result_tab .
        SPLIT lv_response AT cl_abap_char_utilities=>cr_lf INTO TABLE result_tab .

        CALL METHOD lo_http_client->close.
        lv_size = xstrlen( lv_payload_x ).

        GET TIME STAMP FIELD lv_stfin.
        FORMAT COLOR 3.

        FORMAT COLOR OFF.
* Not sending due to size
      ELSE.
        lv_response = 'Not sending due to size exceeds maximum allowed'.
        lv_message  = lv_response.
        SHIFT lv_size LEFT DELETING LEADING '0'.
        lv_sizes    = lv_size.

        CLEAR lv_ret_code.
        me->append_slg1_log(
           EXPORTING
            iv_tabname    = space
            iv_message_v1 = lv_message
            iv_message_v2 = lv_sizes
            iv_message_v3 = space
            iv_mestyp     = 'E' ).

        gs_elog-type       = 'SEND_JSON_HTTP_CON_OPENCURSOR'.
        gs_elog-severity   = gc_error.
        gs_elog-message    = lv_message.

        gs_elog-details-query = |Maximun size allowed exceeds|.
        gs_elog-details-db = 'MAXIMUM_SIZE_EXCEEDS'.
        gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

        gs_elog-metadata-error_code = gs_elog-details-error_code.
        send_json_error( ).
        CLEAR lv_size.
      ENDIF.  "size
    ENDIF.  "low


    IF gv_secondary IS NOT INITIAL.
      CLEAR lv_size.
      me->append_slg1_log(
       EXPORTING
        iv_tabname    = space
        iv_message_v1 = |'Primary endpoint' { lv_dest } 'not working, trying with Secondary' { gv_secondary }|
        iv_message_v2 = space
        iv_message_v3 = space
        iv_mestyp     = 'E' ).

      gs_elog-type       = 'SEND_JSON_HTTP_CON_OPENCURSOR'.
      gs_elog-severity   = gc_error.
      gs_elog-message    = lv_message.

      gs_elog-details-query = |Primary endpoint { lv_dest } not working, trying with Secondary { gv_secondary }|.
      gs_elog-details-db = 'PRIMARY_ENDPOINT_FAILURE'.
      gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

      gs_elog-metadata-error_code = gs_elog-details-error_code.
      send_json_error( ).


      me->send_json_http_con(
        EXPORTING
          i_dest     = gv_secondary
        IMPORTING
          e_return   = lv_ret_codes
          e_size     = lv_size
          e_records  = ev_records
          e_response = lv_response ).
      lv_ret_code = lv_ret_codes.
      lv_dest = gv_secondary.
    ENDIF.

    IF gv_dest NE lv_dest.
      gv_secondary = lv_dest.
      FIELD-SYMBOLs <fs_log_ext> like LINE OF  gt_log_ext.
*      LOOP AT gt_log_ext ASSIGNING FIELD-SYMBOL(<fs_log_ext>) WHERE tabname IS NOT INITIAL AND json_id >= gv_jsonid.
      LOOP AT gt_log_ext ASSIGNING <fs_log_ext> WHERE tabname IS NOT INITIAL AND json_id >= gv_jsonid.
        <fs_log_ext>-endpoint = gv_secondary.
      ENDLOOP.
      gv_dest = gv_secondary.
    ENDIF.

    ev_response = lv_response.
    ev_return   = lv_ret_code.
    ev_size     = lv_size.
  ENDMETHOD.


  METHOD send_json_http_con_rap.
    DATA:
      lv_response     TYPE string,
      lv_return       TYPE string,
      lv_string       TYPE string,
      lv_stini        TYPE timestamp,
      lv_stfin        TYPE timestamp,
      lo_http_client  TYPE REF TO if_http_client,
      lv_destination  TYPE rfcdes-rfcdest,
      lv_servicenr    TYPE rfcdisplay-rfcsysid,
      lv_server       TYPE rfcdisplay-rfchost,
      lv_path_prefix  TYPE string,
      lv_err_string   TYPE string,
      lv_ret_code     TYPE sy-subrc,
      lv_ret_codes    TYPE string,
      r_str           TYPE string,
      result_tab      TYPE TABLE OF string,
      lv_dest         TYPE rfcdest,
      lv_subrc        TYPE sy-subrc,
      lv_table        TYPE char20,
      lv_low          TYPE rfcdest,
      lv_size         TYPE zonde_oc_num30,
      ls_paramter     TYPE zonta_oc_param, "cechavarria 15/08/2025
      lv_json         TYPE string, "symsgv.
      lv_message      TYPE string, "symsgv.
      lv_message1     TYPE string, "symsgv.
      lv_message2     TYPE string, "symsgv.
      lv_message3     TYPE string, "symsgv.
      lv_good_to_send TYPE boolean_flg,
      lv_sizes        TYPE string.

*BEGIN CECHAVARRIA 15/08/2025

    IF gv_json_prev = abap_true.
      cl_demo_output=>display_json( json = gv_json ).
      RETURN.
    ENDIF.

*    zoncl_json_save_log=>get_parameter_active_log(
*      EXPORTING
*        iv_name_parameter = zoncl_rapevent_factory=>gc_json_log_name
*        iv_type           = zoncl_rapevent_factory=>gc_json_log_type
*      IMPORTING
*        es_parameter      = ls_paramter
*    ).
*
*If parameter is true save json in log sap
    IF ls_paramter-low EQ abap_true.
*      TRY.
*          zoncl_json_save_log=>log_json_data( iv_json_string = gv_json ).
*        CATCH cx_bali_runtime INTO DATA(lx_error).
*          gs_elog-type       = 'SAVE_LOG'.
*          gs_elog-severity   = gc_error.
*          gs_elog-message    = lx_error->get_longtext( ).
*          CALL METHOD lx_error->get_source_position
*            IMPORTING
*              program_name = gv_prog
*              source_line  = gv_sline.
*          gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
*          gs_elog-details-db = 'ZONCL_OC_BASE_HANDLER-SEND_JSON_HTTP_CON_RAP'.
*          gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.
*
*          gs_elog-metadata-error_code = gs_elog-details-error_code.
*          interpret_message( EXPORTING iv_msgnr = '084'  IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
*          interpret_message( EXPORTING iv_msgnr = '085'  IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
*          CONCATENATE gv_msg1 gv_msg2 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
*          interpret_message( EXPORTING iv_msgnr = '086'  IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
*          interpret_message( EXPORTING iv_msgnr = '087'  IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_fixes ).
*          CONCATENATE gv_msg1 gv_msg2 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.
*          print_error_otel( ).
*
*          send_json_error( ).
*          MESSAGE lx_error->get_text( ) TYPE 'E'.
*      ENDTRY.
    ENDIF.
*END CECHAVARRIA 15/08/2025

    CLEAR:lv_string.
    GET TIME STAMP FIELD lv_stini.

    lv_low = i_dest.
    lv_json = gv_json.
    IF lv_low IS NOT INITIAL.
      lv_dest = lv_low.
      CLEAR gv_secondary.
***revisar 17.02
      CALL METHOD me->create_destination
        EXPORTING
          iv_destination = lv_dest
          iv_secondary   = abap_true
        IMPORTING
          ev_subrc       = lv_subrc
*  RECEIVING
          ro_http_client   = lo_http_client.

*      lo_http_client =  me->create_destination( EXPORTING iv_destination =  lv_dest
*                                                          iv_secondary   =  abap_true
*                                                IMPORTING ev_subrc       =  lv_subrc ).     " Logical destination (specified in function call)

      IF lv_subrc NE 0.
        EXIT.
      ENDIF.

      DATA lv_payload_x TYPE xstring.
      CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
        EXPORTING
          text   = me->gv_json
        IMPORTING
          buffer = lv_payload_x.

* Checking size of json to validate if this is allowed
      lv_size = xstrlen( lv_payload_x ).
      CALL METHOD me->check_json_size
        EXPORTING
          iv_size        = lv_size
        RECEIVING
          r_good_to_send = lv_good_to_send.

      IF lv_good_to_send = abap_true.

        lo_http_client->request->set_method( 'POST' ).
        lo_http_client->request->set_content_type( 'text/plain' ).
        lo_http_client->request->set_data( lv_payload_x ).

* Sending the request
        lo_http_client->send(
          EXCEPTIONS
            http_communication_failure = 1
            http_invalid_state         = 2 ).

        IF sy-subrc NE 0.
          lo_http_client->get_last_error( IMPORTING   message = lv_message ).
          me->append_slg1_log(
            EXPORTING
              iv_tabname    = space
              iv_message_v1 = lv_message
              iv_message_v2 = space
              iv_message_v3 = space
              iv_mestyp     = 'E' ).

          gs_elog-type       = 'SEND_JSON_HTTP_CON_RAP'.
          gs_elog-severity   = gc_error.
          gs_elog-message    = lv_message.

          gs_elog-details-query = |Error while sending to  { lv_dest } |.
          gs_elog-details-db = 'SENDING'.
          gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

          gs_elog-metadata-error_code = gs_elog-details-error_code.
          send_json_error( ).
          EXIT.
        ENDIF.

* Receiving the response
        lo_http_client->receive( EXCEPTIONS http_communication_failure = 1
                                            http_invalid_state         = 2
                                            http_processing_failed     = 3 ).

        IF sy-subrc NE 0.
          lo_http_client->get_last_error( IMPORTING   message = lv_message ).
          SELECT SINGLE low
            INTO gv_secondary
            FROM zonta_oc_param
            WHERE name = 'RFC_SECONDARY'.
          IF gv_secondary = lv_dest.
            CLEAR gv_secondary.
          ENDIF.

          me->append_slg1_log(
            EXPORTING
              iv_tabname    = space
*           iv_key        =
              iv_message_v1 = lv_message
              iv_message_v2 = space
              iv_message_v3 = space
              iv_mestyp     = 'E' ).

          gs_elog-type       = 'SEND_JSON_HTTP_CON_RAP'.
          gs_elog-severity   = gc_error.
          gs_elog-message    = lv_message.

          gs_elog-details-query = |Error while receiving from  { lv_dest } |.
          gs_elog-details-db = 'RECEIVING'.
          gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

          gs_elog-metadata-error_code = gs_elog-details-error_code.
          send_json_error( ).

          IF gv_secondary IS INITIAL.
            me->append_slg1_log(
              EXPORTING
               iv_tabname    = space
               iv_message_v1 = |'No secondary endpoint is defined'|
               iv_message_v2 = space
               iv_message_v3 = space
               iv_mestyp     = 'E' ).

            gs_elog-type       = 'SEND_JSON_HTTP_CON_RAP'.
            gs_elog-severity   = gc_error.
            gs_elog-message    = |'No secondary endpoint is defined'|.

            gs_elog-details-query = |'No secondary endpoint is defined'|.
            gs_elog-details-db = 'NO_SECONDARY_ENDPOINT'.
            gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

            gs_elog-metadata-error_code = gs_elog-details-error_code.
            send_json_error( ).
            EXIT.  "check
          ENDIF.
        ENDIF.

        lo_http_client->response->get_status( IMPORTING code   = lv_ret_code
                                                        reason = lv_err_string ).

        IF NOT ( lv_ret_code BETWEEN 200 AND 299 ).

          lv_message = lv_ret_code &&
                       '-'         &&
                       lv_err_string.
          me->append_slg1_log(
            EXPORTING
              iv_tabname    = space
*           iv_key        =
              iv_message_v1 = lv_message
              iv_message_v2 = space
              iv_message_v3 = space
              iv_mestyp     = 'E' ).

          gs_elog-type       = 'SEND_JSON_HTTP_CON_RAP'.
          gs_elog-severity   = gc_error.
          gs_elog-message    = lv_message.

          gs_elog-details-query = |Error while taking response from { lv_dest } |.
          gs_elog-details-db = 'RESPONSE'.
          gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

          gs_elog-metadata-error_code = gs_elog-details-error_code.
          send_json_error( ).

          IF gv_secondary IS INITIAL.
*            EXIT.
            CLEAR lv_size.
          ENDIF.
        ENDIF.

        CLEAR lv_response .
        lv_response = lo_http_client->response->get_cdata( ).


***add new record to log begin
        DATA: i_parce  TYPE TABLE OF zonst_field50,
              i_parce1 TYPE TABLE OF zonst_field50,
              w_parce  TYPE zonst_field50,
              w_parce1 TYPE zonst_field50,
              lv_res   TYPE c.
        CLEAR: lv_res .

        IF ( lv_ret_code BETWEEN 200 AND 299 ).
          lv_res = 'S'.
        ELSE.
          lv_res = 'E'.
        ENDIF.

        IF lv_response IS NOT INITIAL.
          CLEAR lv_message.
          CASE lv_res.
            WHEN 'S'.
              REPLACE ALL OCCURRENCES OF '{' IN lv_response WITH ''.
              REPLACE ALL OCCURRENCES OF '}' IN lv_response WITH ''.
              SPLIT lv_response AT ',' INTO TABLE i_parce.
              READ TABLE i_parce INTO w_parce INDEX 1.
              REPLACE ALL OCCURRENCES OF '{' IN lv_json WITH ''.
              REPLACE ALL OCCURRENCES OF '}' IN lv_json WITH ''.
              SPLIT lv_json AT ',' INTO TABLE i_parce1.
              READ TABLE i_parce1 INTO w_parce1 INDEX 12.
              REPLACE '"metadata":[' INTO w_parce1 WITH ''.
              CONCATENATE w_parce1 w_parce INTO lv_message SEPARATED BY '-'.
            WHEN 'E'.
              REPLACE ALL OCCURRENCES OF '{' IN lv_response WITH ''.
              REPLACE ALL OCCURRENCES OF '}' IN lv_response WITH ''.
              SPLIT lv_response AT ',' INTO TABLE i_parce.
              READ TABLE i_parce INTO w_parce INDEX 1.
              REPLACE ALL OCCURRENCES OF '{' IN lv_json WITH ''.
              REPLACE ALL OCCURRENCES OF '}' IN lv_json WITH ''.
              SPLIT lv_json AT ',' INTO TABLE i_parce1.
              READ TABLE i_parce1 INTO w_parce1 INDEX 12.
              REPLACE '"metadata":[' INTO w_parce1 WITH ''.
              CONCATENATE w_parce1 w_parce INTO lv_message SEPARATED BY '-'.
            WHEN OTHERS.
          ENDCASE.

          me->append_slg1_log(
            EXPORTING
              iv_tabname    = space
*           iv_key        =
              iv_message_v1 = lv_message
              iv_message_v2 = space
              iv_message_v3 = space
              iv_mestyp     = lv_res ).
        ENDIF.
***add new record to log begin

        CLEAR result_tab .
        SPLIT lv_response AT cl_abap_char_utilities=>cr_lf INTO TABLE result_tab .



        CALL METHOD lo_http_client->close.

        GET TIME STAMP FIELD lv_stfin.
        FORMAT COLOR 3.

        FORMAT COLOR OFF.
* Not sending due to size
      ELSE.
        lv_response = 'Not sending due to size exceeds maximum allowed'.
        lv_message  = lv_response.
        SHIFT lv_size LEFT DELETING LEADING '0'.
        lv_sizes    = lv_size.

        CLEAR lv_ret_code.
        me->append_slg1_log(
           EXPORTING
            iv_tabname    = space
            iv_message_v1 = lv_message
            iv_message_v2 = lv_sizes
            iv_message_v3 = space
            iv_mestyp     = 'E' ).

        gs_elog-type       = 'SEND_JSON_HTTP_CON_RAP'.
        gs_elog-severity   = gc_error.
        gs_elog-message    = lv_message.

        gs_elog-details-query = |Maximun size allowed exceeds|.
        gs_elog-details-db = 'MAXIMUM_SIZE_EXCEEDS'.
        gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

        gs_elog-metadata-error_code = gs_elog-details-error_code.
        send_json_error( ).
        CLEAR lv_size.
      ENDIF.  "size
    ENDIF.  "low

    IF gv_secondary IS NOT INITIAL.
      CLEAR lv_size.
      me->append_slg1_log(
       EXPORTING
        iv_tabname    = space
        iv_message_v1 = |'Primary endpoint' { lv_dest } 'not working, trying with Secondary' { gv_secondary }|
        iv_message_v2 = space
        iv_message_v3 = space
        iv_mestyp     = 'E' ).

      gs_elog-type       = 'SEND_JSON_HTTP_CON_RAP'.
      gs_elog-severity   = gc_error.
      gs_elog-message    = lv_message.

      gs_elog-details-query = |Primary endpoint { lv_dest } not working, trying with Secondary { gv_secondary }|.
      gs_elog-details-db = 'PRIMARY_ENDPOINT_FAILURE'.
      gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

      gs_elog-metadata-error_code = gs_elog-details-error_code.
      send_json_error( ).

      me->send_json_http_con(
        EXPORTING
          i_dest     = gv_secondary
        IMPORTING
          e_return   = lv_ret_codes
          e_size     = lv_size
          e_records  = e_records
          e_response = lv_response ).
      lv_ret_code = lv_ret_codes.
      lv_dest = gv_secondary.
    ENDIF.

    IF gv_dest NE lv_dest.
      gv_secondary = lv_dest.
      FIELD-SYMBOLs <fs_log_ext> like LINE OF  gt_log_ext.
*      LOOP AT gt_log_ext ASSIGNING FIELD-SYMBOL(<fs_log_ext>) WHERE tabname IS NOT INITIAL AND json_id >= gv_jsonid.
      LOOP AT gt_log_ext ASSIGNING <fs_log_ext> WHERE tabname IS NOT INITIAL AND json_id >= gv_jsonid.
        <fs_log_ext>-endpoint = gv_secondary.
      ENDLOOP.
      gv_dest = gv_secondary.
    ENDIF.

    e_response = lv_response.
    e_return   = lv_ret_code.
    e_size     = lv_size.
  ENDMETHOD.


  METHOD send_json_result.

    DATA: total_size_sent          TYPE string,
          total_number_of_requests TYPE string,
          total_number_of_records  TYPE string,
          out                      TYPE REF TO if_demo_output,
          ls_sent                  TYPE zonta_relations,
          lv_message               TYPE string.

*BEGIN CECHAVARRIA 17/10/2025
*If json_prev is true only show json
    IF gv_json_prev = abap_true.
      RETURN.
    ENDIF.
*END CECHAVARRIA 17/10/2025

    IF sy-batch IS INITIAL.

      out = cl_demo_output=>new( ).
      out->begin_section( 'ONE CONNECT EXECUTION LOG' ).

*      SHIFT gv_sizet        LEFT DELETING LEADING '0'.
*      SHIFT gv_recordst     LEFT DELETING LEADING '0'.
*      SHIFT gv_recordst_obj LEFT DELETING LEADING '0'.

      SHIFT gs_log_json_result-sizet        LEFT DELETING LEADING '0'.
      SHIFT gs_log_json_result-recordst     LEFT DELETING LEADING '0'.
      SHIFT gs_log_json_result-recordst_obj LEFT DELETING LEADING '0'.

*      total_size_sent          = gv_sizet.
*      total_number_of_requests = gv_recordst.
*      total_number_of_records  = gv_recordst_obj.

      total_size_sent          = gs_log_json_result-sizet.
      total_number_of_requests = gs_log_json_result-recordst.
      total_number_of_records  = gs_log_json_result-recordst_obj.

      out->write_data( gv_entity ).

      IF lines( gt_relations ) > 0.
        out->write_data( gt_relations ).
      ENDIF.

      out->write_data( total_size_sent ).
      out->write_data( total_number_of_requests ).
      out->write_data( total_number_of_records ).

*******
      IF gs_log_json_result-tables IS NOT INITIAL.
        out->write_data( gs_log_json_result-tables  ).
      ENDIF.
********
      IF total_number_of_records IS INITIAL AND total_size_sent IS INITIAL. "++DB multiple endpoints
        lv_message = '***DATA NOT FOUND, NO RECORDS WERE SENT***'.
        out->write( lv_message ).
        out->write( gv_response ).
        CLEAR gv_response.
      ENDIF.

      out->display( ).

    ELSE.

      WRITE:/ 'ONE CONNECT EXECUTION LOG'.

*      SHIFT gv_sizet        LEFT DELETING LEADING '0'.
*      SHIFT gv_recordst     LEFT DELETING LEADING '0'.
*      SHIFT gv_recordst_obj LEFT DELETING LEADING '0'.

      SHIFT gs_log_json_result-sizet        LEFT DELETING LEADING '0'.
      SHIFT gs_log_json_result-recordst     LEFT DELETING LEADING '0'.
      SHIFT gs_log_json_result-recordst_obj LEFT DELETING LEADING '0'.

*      total_size_sent          = gv_sizet.
*      total_number_of_requests = gv_recordst.
*      total_number_of_records  = gv_recordst_obj.

      total_size_sent          = gs_log_json_result-sizet.
      total_number_of_requests = gs_log_json_result-recordst.
      total_number_of_records  = gs_log_json_result-recordst_obj.

      WRITE:/ gv_entity.
      SKIP.
      WRITE: / 'Entity', gv_entity.
      SKIP.

      IF lines( gt_relations ) > 0.
        WRITE: /5 'Entity',
                   30 'Description'.

        LOOP AT gt_relations INTO ls_sent.
          WRITE: /5  ls_sent-business_proc,
                    30 ls_sent-description_table.
        ENDLOOP.
      ENDIF.

      SKIP 2.
      WRITE : / 'Total Size Sent',          30 total_size_sent.
      WRITE : / 'Total Number of requests', 30 total_number_of_requests.
      WRITE : / 'Total Number of records',  30 total_number_of_records.

*******
      LOOP AT gs_log_json_result-tables INTO DATA(ls_data).
        WRITE : / ls_data-tabname,          30 ls_data-size.
      ENDLOOP.
********

      IF total_number_of_records IS INITIAL.
        WRITE : / '***ERROR WHILE SENDING, NO RECORDS WERE SENT***'.
        WRITE : / gv_response.
        CLEAR  gv_response.
      ENDIF.

      SKIP.
      SKIP.
      WRITE /: '**********Please validate complete log in ZONT_HIST_DL transaction code**********'.

    ENDIF.

  ENDMETHOD.


  METHOD send_log_otel.

    DATA: lv_dest    TYPE rfcdest,
          lv_message TYPE string,
          lv_subrc   TYPE sy-subrc.



    DATA: ls_log_otel TYPE ZONST_LOG_OTEL,
          lv_json TYPE string.
    ls_log_otel = is_log_otel.

****      lv_json = /ui2/cl_json=>serialize(
****      EXPORTING
****        data             = is_log_otel
****        pretty_name      = /ui2/cl_json=>pretty_mode-low_case    ).

    SELECT SINGLE low INTO lv_dest FROM zonta_oc_param WHERE name = 'RFC_OTEL'.

    IF sy-subrc NE 0 OR lv_dest IS INITIAL.
      lv_message = |Destination has not been configured in the PARAM table.|.

      me->append_slg1_log( EXPORTING iv_tabname    = space
        iv_message_v1 = 'RFC_OTEL'
        iv_message_v2 = lv_message
        iv_message_v3 = space
        iv_mestyp     = 'E' ).
      RETURN.

    ENDIF.

***revisar 17.02
      data lo_http  TYPE REF TO if_http_client.

      CALL METHOD me->create_destination
        EXPORTING
          iv_destination = lv_dest
          iv_secondary   = abap_false
        IMPORTING
          ev_subrc       = lv_subrc
*  RECEIVING
          ro_http_client   = lo_http.

**
**    DATA(lo_http) =  me->create_destination( EXPORTING iv_destination =  lv_dest
**                                                       iv_secondary   =  abap_false
**                                             IMPORTING ev_subrc       =  lv_subrc ).                " Logical destination (specified in function call)

    IF lv_subrc NE 0.
      EXIT.
    ENDIF.
    IF lo_http IS NOT INITIAL.
      data: lv_return    TYPE string,
            lv_size      TYPE ZONDE_OC_NUM30,
            lv_response  TYPE string,
            lv_records   TYPE ZONDE_OC_NUM30.
      me->send_msg_to_http( EXPORTING
                  iv_msg  = lv_json
                  io_http_client  =  lo_http
                  IMPORTING ev_return = lv_return
                  ev_size	= lv_size
                  ev_records = lv_records
                  ev_response = lv_response ).
    ENDIF.

  ENDMETHOD.


  METHOD send_msg_to_http.

    DATA: lt_result     TYPE TABLE OF string.

    DATA: lv_stfin        TYPE timestamp,
          lv_payload_x    TYPE xstring,
          lv_message      TYPE string,
          lv_size         TYPE zonde_oc_num30,
          lv_sizes        TYPE string,
          lv_good_to_send TYPE boolean_flg,
          lv_err_string   TYPE string,
          lv_ret_code     TYPE sy-subrc,
          lv_response     TYPE string,
          lv_res          TYPE c.

    IF iv_msg IS NOT INITIAL.

      CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
        EXPORTING
          text   = iv_msg
        IMPORTING
          buffer = lv_payload_x.

    ELSE.

      lv_payload_x = iv_xmsg.

    ENDIF.

    CHECK lv_payload_x IS NOT INITIAL.

    " Checking size of json to validate if this is allowed
    lv_size = xstrlen( lv_payload_x ).

    CALL METHOD me->check_json_size
      EXPORTING
        iv_size        = lv_size
      RECEIVING
        r_good_to_send = lv_good_to_send.

    IF lv_good_to_send = abap_true.

      io_http_client->request->set_method( 'POST' ).
      io_http_client->request->set_content_type( 'application/json' ). "'text/plain' ).
      io_http_client->request->set_data( lv_payload_x ).

      " Sending the request
      io_http_client->send( EXCEPTIONS http_communication_failure = 1
                                       http_invalid_state         = 2 ).

      CASE sy-subrc.
        WHEN 1.
          lv_message = TEXT-e06.
        WHEN 2.
          lv_message = TEXT-e07.
      ENDCASE.

      IF sy-subrc NE 0.
        me->append_slg1_log( EXPORTING iv_tabname    = space
                                       iv_message_v1 = lv_message
                                       iv_message_v2 = space
                                       iv_message_v3 = space
                                       iv_mestyp     = 'E' ).

        RETURN.
      ENDIF.

* Receiving the response
      io_http_client->receive( EXCEPTIONS http_communication_failure = 1
                                          http_invalid_state         = 2
                                          http_processing_failed     = 3 ).

      CASE sy-subrc.
        WHEN 1.
          lv_message = TEXT-e06.
        WHEN 2.
          lv_message = TEXT-e07.
        WHEN 3.
          lv_message = TEXT-e08.
      ENDCASE.

      IF sy-subrc NE 0.
        me->append_slg1_log( EXPORTING iv_tabname    = space
                                       iv_message_v1 = lv_message
                                       iv_message_v2 = space
                                       iv_message_v3 = space
                                       iv_mestyp     = 'E' ).

        ev_res = 'E'.
        ev_response = lv_message.

        RETURN.
      ENDIF.

      io_http_client->response->get_status( IMPORTING code   = lv_ret_code
                                                      reason = lv_err_string ).

      IF NOT ( lv_ret_code BETWEEN 200 AND 299 ).

        lv_message = |{ lv_ret_code }-{ lv_err_string }|.

        me->append_slg1_log( EXPORTING iv_tabname    = space
                                       iv_message_v1 = lv_message
                                       iv_message_v2 = space
                                       iv_message_v3 = space
                                       iv_mestyp     = 'E' ).

        ev_res = 'E'.
        ev_response = lv_message.

        RETURN.
      ENDIF.

      CLEAR lv_response .
      lv_response = io_http_client->response->get_cdata( ).

      " add new record to log begin
      CLEAR: lv_res .

      IF ( lv_ret_code BETWEEN 200 AND 299 ).
        lv_res = 'S'.
      ELSE.
        lv_res = 'E'.
      ENDIF.

      IF lv_response IS NOT INITIAL.
        CLEAR lv_message.
        lv_message = lv_response.
      ENDIF.

      " add new record to log begin
      CLEAR lt_result.
      SPLIT lv_response AT cl_abap_char_utilities=>cr_lf INTO TABLE lt_result.

      CALL METHOD io_http_client->close.

      GET TIME STAMP FIELD lv_stfin.

      FORMAT COLOR 3.

      FORMAT COLOR OFF.

    ELSE.  " Not sending due to size
      lv_message  = lv_response = |Not sending due to size exceeds maximum allowed|.
*      lv_message  = lv_response.
      SHIFT lv_size LEFT DELETING LEADING '0'.
      lv_sizes    = lv_size.

      CLEAR lv_ret_code.
      me->append_slg1_log( EXPORTING iv_tabname    = space
                                     iv_message_v1 = lv_message
                                     iv_message_v2 = lv_sizes
                                     iv_message_v3 = space
                                     iv_mestyp     = 'E' ).

      CLEAR lv_size.
    ENDIF.  "size

    ev_response = lv_response.
    ev_return   = lv_ret_code.
    ev_size     = lv_size.
    ev_res = lv_res.

  ENDMETHOD.


METHOD send_receive_http.

  CLEAR:
    ev_http_code,
    ev_http_reason,
    ev_response,
    ev_comm_error,
    ev_error_text.

  io_client->request->set_method( 'POST' ).
  io_client->request->set_content_type( 'text/plain' ).
  io_client->request->set_data( iv_payload ).

  io_client->send(
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2 ).

  IF sy-subrc <> 0.
    ev_comm_error = abap_true.
    io_client->get_last_error( IMPORTING   message = ev_error_text ).
    RETURN.
  ENDIF.

  io_client->receive(
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3 ).

  IF sy-subrc <> 0.
    ev_comm_error = abap_true.
    io_client->get_last_error( IMPORTING   message = ev_error_text
).

*    RETURN.
  ENDIF.

  IF gv_commit = abap_true AND cl_system_transaction_state=>get_in_update_task( ) = abap_false.
    COMMIT WORK .
  ENDIF.

  io_client->response->get_status(
    IMPORTING
      code   = ev_http_code
      reason = ev_http_reason ).

  ev_response = io_client->response->get_cdata( ).


  io_client->close( ).
ENDMETHOD.


  METHOD set_corr_insert.
    CASE iv_mode.
      WHEN 'I'.
        CALL FUNCTION 'RS_CORR_INSERT'
          EXPORTING
            object              = iv_object
            object_class        = 'DICT'
            mode                = iv_mode
            global_lock         = abap_true
            devclass            = gv_devclass
            korrnum             = gv_korrnum
            master_language     = sy-langu
            activation_call     = sy-langu
          IMPORTING
            devclass            = gv_devclass
            korrnum             = gv_korrnum
          EXCEPTIONS
            cancelled           = 1
            permission_failure  = 2
            unknown_objectclass = 3
            OTHERS              = 4.
        IF sy-subrc <> 0.
        ENDIF.
      WHEN 'DELETE'.
        CALL FUNCTION 'RS_CORR_INSERT'
          EXPORTING
            object              = iv_object
            object_class        = 'DICT'
            mode                = iv_mode
            global_lock         = abap_true
            korrnum             = gv_korrnum
          IMPORTING
            korrnum             = gv_korrnum
          EXCEPTIONS
            cancelled           = 1
            permission_failure  = 2
            unknown_objectclass = 3
            OTHERS              = 4.
    ENDCASE.
  ENDMETHOD.


  METHOD set_fields.


    DATA: lt_dfies_tab     TYPE STANDARD TABLE OF dfies,
          lt_relations     TYPE STANDARD TABLE OF zonta_relations,
          lt_columns       TYPE STANDARD TABLE OF zonta_oc_col_all,
          lv_fldname       TYPE string,
          lv_alias_fldname TYPE string,
          lv_tabname       TYPE ddobjname,
          lv_field         TYPE string,
          lv_lines         TYPE i,
          lv_tabix         TYPE i,
          lv_is_cds_entity TYPE abap_bool,
          lv_tabnames      TYPE string.

    FIELD-SYMBOLS: <fs_relations> TYPE zonta_relations,
                   <fs_columns>   TYPE zonta_oc_col_all,
                   <fs_dfies_tab> TYPE dfies.


    IF NOT gv_anytable IS INITIAL.

      LOOP AT gt_columns_all ASSIGNING <fs_columns> WHERE tabname = gv_anytable.

        TRANSLATE <fs_columns>-alias_fldname TO UPPER CASE.

        FIND <fs_columns>-fldname IN r_fields.
        IF sy-subrc NE 0.
          IF iv_alias = abap_true AND <fs_columns>-alias_fldname IS NOT INITIAL.
            CONCATENATE <fs_columns>-fldname 'AS' <fs_columns>-alias_fldname INTO lv_field SEPARATED BY space.
          ELSE.
            lv_field = <fs_columns>-fldname.
          ENDIF.

          CONCATENATE r_fields lv_field INTO r_fields SEPARATED BY space.
        ENDIF.

      ENDLOOP.

    ELSE.

      lv_tabnames = iv_tabname.
      add_position_table( iv_tabname = lv_tabnames ).
      SORT gt_columns_all BY tabname positionf.

      lt_relations = gt_relations.
      lt_columns   = gt_columns_all.

      DELETE lt_relations WHERE tabname NE iv_tabname.
      DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING tabname.
      DELETE lt_columns   WHERE tabname NE iv_tabname.

      SORT lt_columns BY fldname tabname.

      DESCRIBE TABLE lt_columns LINES lv_lines.
      CLEAR lv_tabix.

      LOOP AT lt_relations ASSIGNING <fs_relations>.
        lv_is_cds_entity = me->is_cds_entity( <fs_relations>-tabname ).

        LOOP AT lt_columns ASSIGNING <fs_columns> WHERE tabname = <fs_relations>-tabname AND fldname NE 'MANDT'.

          ADD 1 TO lv_tabix.

          TRANSLATE <fs_columns>-alias_fldname TO UPPER CASE.

          lv_fldname        = <fs_columns>-fldname && <fs_relations>-sequence.
          lv_alias_fldname  = <fs_columns>-alias_fldname && <fs_relations>-sequence.

          IF iv_alias = abap_true AND gv_alias = abap_true.
            IF <fs_columns>-alias_fldname IS NOT INITIAL.
              CONCATENATE <fs_columns>-fldname 'AS' lv_alias_fldname INTO lv_field SEPARATED BY space.
            ELSE.
              CONCATENATE <fs_columns>-fldname 'AS' lv_fldname INTO lv_field SEPARATED BY space.
            ENDIF.
          ELSEIF iv_alias = abap_true.
            CONCATENATE <fs_columns>-fldname 'AS' lv_fldname INTO lv_field SEPARATED BY space.
          ELSE.
            lv_field = <fs_columns>-fldname.
          ENDIF.

          IF lv_tabix < lv_lines AND lv_is_cds_entity = abap_true.
            CONCATENATE lv_field ',' INTO lv_field.
          ENDIF.

          CONCATENATE r_fields lv_field INTO r_fields SEPARATED BY space.

        ENDLOOP.

        IF sy-subrc NE 0.

          lv_tabname = <fs_relations>-tabname.

          CALL FUNCTION 'DDIF_FIELDINFO_GET'
            EXPORTING
              tabname   = lv_tabname
            TABLES
              dfies_tab = lt_dfies_tab
            EXCEPTIONS
              OTHERS    = 3.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.

          LOOP AT lt_dfies_tab ASSIGNING <fs_dfies_tab>.
            IF <fs_dfies_tab>-fieldname = 'MANDT'.
              CONTINUE.
            ENDIF.

            FIND <fs_dfies_tab>-fieldname IN r_fields.
            IF sy-subrc NE 0.
              lv_field = <fs_dfies_tab>-fieldname .
              CONCATENATE r_fields lv_field INTO r_fields SEPARATED BY space.
            ENDIF.

          ENDLOOP.

        ENDIF.

      ENDLOOP.

      IF lv_is_cds_entity = abap_false.
        REPLACE FIRST OCCURRENCE OF ',' IN r_fields WITH space.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD set_fields_both.

    DATA: lt_dfies_tab     TYPE STANDARD TABLE OF dfies,
          lt_relations     TYPE STANDARD TABLE OF zonta_relations,
          lt_columns       TYPE STANDARD TABLE OF zonta_oc_col_all,
          ls_conv          LIKE LINE OF gt_converted,
          lv_fldname       TYPE string,
          lv_alias_fldname TYPE string,
          lv_tabname       TYPE ddobjname,
          lv_field         TYPE string,
          lv_lines         TYPE i,
          lv_tabix         TYPE i,
          lv_is_cds_entity TYPE abap_bool,
          lv_tabnames      TYPE string,
          lv_rfields       TYPE string,
          ls_fields        LIKE LINE OF et_fields,
          lv_nlines        TYPE i,
          lv_search        TYPE string,
          lv_fullrfields   TYPE string.

    FIELD-SYMBOLS: <fs_relations> TYPE zonta_relations,
                   <fs_columns>   TYPE zonta_oc_col_all,
                   <fs_dfies_tab> TYPE dfies,
                   <fs_fields>    LIKE LINE OF et_fields.

    SORT gt_converted BY tabname fldname.

    lv_tabnames = iv_tabname.
    add_position_table( iv_tabname = lv_tabnames ).
    SORT gt_columns_all BY tabname positionf.

    IF NOT gv_anytable IS INITIAL.

      LOOP AT gt_columns_all ASSIGNING <fs_columns> WHERE tabname = gv_anytable.

        TRANSLATE <fs_columns>-alias_fldname TO UPPER CASE.

        lv_search = | { <fs_columns>-fldname } |.
        lv_fullrfields = | { lv_rfields } |.
        CONCATENATE ' ' lv_fullrfields ' ' INTO lv_fullrfields.

        FIND lv_search IN lv_fullrfields.
        IF sy-subrc NE 0.
          IF iv_alias = abap_true AND <fs_columns>-alias_fldname IS NOT INITIAL.
            READ TABLE gt_converted INTO ls_conv WITH KEY tabname = <fs_columns>-tabname
                                                          fldname = <fs_columns>-alias_fldname.
            IF sy-subrc = 0.
              CONCATENATE <fs_columns>-fldname 'AS' ls_conv-alias_fldname1 INTO lv_field SEPARATED BY space.
            else.
              CONCATENATE <fs_columns>-fldname 'AS' <fs_columns>-alias_fldname INTO lv_field SEPARATED BY space.
            ENDIF.

          ELSE.
            lv_field = <fs_columns>-fldname.
            READ TABLE gt_converted INTO ls_conv WITH KEY tabname = <fs_columns>-tabname
                                                          fldname = <fs_columns>-fldname BINARY SEARCH.
            IF sy-subrc = 0.
              lv_field = ls_conv-fldname1.
            ENDIF.
          ENDIF.

          CONCATENATE lv_rfields lv_field INTO lv_rfields SEPARATED BY space.
          CONCATENATE lv_field ',' INTO lv_field.
          ls_fields-line = lv_field.
          APPEND ls_fields TO et_fields.
        ENDIF.

      ENDLOOP.

    ELSE.

      lv_tabnames = iv_tabname.
      add_position_table( iv_tabname = lv_tabnames ).
      SORT gt_columns_all BY tabname positionf.

      lt_relations = gt_relations.
      lt_columns   = gt_columns_all.

      DELETE lt_relations WHERE tabname NE iv_tabname.
      DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING tabname.
      DELETE lt_columns   WHERE tabname NE iv_tabname.

      SORT lt_columns BY positionf.

      DESCRIBE TABLE lt_columns LINES lv_lines.
      CLEAR lv_tabix.

      LOOP AT lt_relations ASSIGNING <fs_relations>.
        lv_is_cds_entity = me->is_cds_entity( <fs_relations>-tabname ).

        LOOP AT lt_columns ASSIGNING <fs_columns> WHERE tabname = <fs_relations>-tabname AND fldname NE 'MANDT'.

          ADD 1 TO lv_tabix.

          READ TABLE gt_converted INTO ls_conv WITH KEY tabname = <fs_columns>-tabname
                                                        fldname = <fs_columns>-fldname BINARY SEARCH.
          IF sy-subrc = 0.
            lv_fldname = ls_conv-fldname1 && <fs_relations>-sequence.
          ELSE.
            lv_fldname        = <fs_columns>-fldname && <fs_relations>-sequence.
          ENDIF.

          READ TABLE gt_converted INTO ls_conv WITH KEY tabname = <fs_columns>-tabname
                                                        alias_fldname = <fs_columns>-alias_fldname.
          IF sy-subrc = 0.
            lv_alias_fldname  = ls_conv-alias_fldname1 && <fs_relations>-sequence.
          ELSE.
            lv_alias_fldname  = <fs_columns>-alias_fldname && <fs_relations>-sequence.
          ENDIF.

          TRANSLATE <fs_columns>-alias_fldname TO UPPER CASE.
          TRANSLATE lv_alias_fldname           TO UPPER CASE.

          IF iv_alias = abap_true AND gv_alias = abap_true.
            IF <fs_columns>-alias_fldname IS NOT INITIAL.
              CONCATENATE <fs_columns>-fldname 'AS' lv_alias_fldname INTO lv_field SEPARATED BY space.
            ELSE.
              CONCATENATE <fs_columns>-fldname 'AS' lv_fldname INTO lv_field SEPARATED BY space.
            ENDIF.
          ELSEIF iv_alias = abap_true.
            CONCATENATE <fs_columns>-fldname 'AS' lv_fldname INTO lv_field SEPARATED BY space.
          ELSE.
            lv_field = <fs_columns>-fldname.
          ENDIF.


          CONCATENATE lv_rfields lv_field INTO lv_rfields SEPARATED BY space.
          CONCATENATE lv_field ',' INTO lv_field.
          ls_fields-line = lv_field.
          APPEND ls_fields TO et_fields.
        ENDLOOP.

        IF sy-subrc NE 0.

          lv_tabname = <fs_relations>-tabname.

          CALL FUNCTION 'DDIF_FIELDINFO_GET'
            EXPORTING
              tabname   = lv_tabname
            TABLES
              dfies_tab = lt_dfies_tab
            EXCEPTIONS
              OTHERS    = 3.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.

          LOOP AT lt_dfies_tab ASSIGNING <fs_dfies_tab>.
            IF <fs_dfies_tab>-fieldname = 'MANDT'.
              CONTINUE.
            ENDIF.

            FIND <fs_dfies_tab>-fieldname IN lv_rfields.
            IF sy-subrc NE 0.
              lv_field = <fs_dfies_tab>-fieldname .
              CONCATENATE lv_rfields lv_field INTO lv_rfields SEPARATED BY space.
              CONCATENATE lv_field ',' INTO lv_field.
              ls_fields-line = lv_field.
              APPEND ls_fields TO et_fields.
            ENDIF.

          ENDLOOP.

        ENDIF.

      ENDLOOP.
    ENDIF.


    DESCRIBE TABLE et_fields LINES lv_nlines.
    READ TABLE et_fields ASSIGNING <fs_fields> INDEX lv_nlines.
    IF <fs_fields> IS ASSIGNED.
      REPLACE ALL OCCURRENCES OF ',' IN <fs_fields> WITH space.
    ENDIF.

    ev_fields = lv_rfields.
  ENDMETHOD.


  METHOD set_fields_in_table.




    DATA: lt_dfies_tab     TYPE STANDARD TABLE OF dfies,
          lt_relations     TYPE STANDARD TABLE OF zonta_relations,
          lt_columns       TYPE STANDARD TABLE OF zonta_oc_col_all,
          lv_fldname       TYPE string,
          lv_alias_fldname TYPE string,
          lv_tabname       TYPE ddobjname,
          lv_field         TYPE string,
          lv_lines         TYPE i,
          lv_tabix         TYPE i,
          lv_is_cds_entity TYPE abap_bool,
          lv_tabnames      TYPE string,
          lv_rfields       TYPE string,
          ls_fields        LIKE LINE OF et_fields,
          lv_nlines        TYPE i,
          lv_search        TYPE string,
          lv_fullrfields   TYPE string.

    FIELD-SYMBOLS: <fs_relations> TYPE zonta_relations,
                   <fs_columns>   TYPE zonta_oc_col_all,
                   <fs_dfies_tab> TYPE dfies,
                   <fs_fields>    LIKE LINE OF et_fields.

    IF NOT gv_anytable IS INITIAL.

      LOOP AT gt_columns_all ASSIGNING <fs_columns> WHERE tabname = gv_anytable.

        TRANSLATE <fs_columns>-alias_fldname TO UPPER CASE.

        lv_search = | { <fs_columns>-fldname } |.
        lv_fullrfields = | { lv_rfields } |.
        CONCATENATE ' ' lv_fullrfields ' ' INTO lv_fullrfields.


*      FIND <fs_columns>-fldname IN lv_rfields.
        FIND lv_search IN lv_fullrfields.
        IF sy-subrc NE 0.
          IF iv_alias = abap_true AND <fs_columns>-alias_fldname IS NOT INITIAL.
            CONCATENATE <fs_columns>-fldname 'AS' <fs_columns>-alias_fldname INTO lv_field SEPARATED BY space.
          ELSE.
            lv_field = <fs_columns>-fldname.
          ENDIF.

          CONCATENATE lv_rfields lv_field INTO lv_rfields SEPARATED BY space.
          CONCATENATE lv_field ',' INTO lv_field.
          ls_fields-line = lv_field.
          APPEND ls_fields TO et_fields.
        ENDIF.

      ENDLOOP.

    ELSE.

      lv_tabnames = iv_tabname.
      add_position_table( iv_tabname = lv_tabnames ).
      SORT gt_columns_all BY tabname positionf.

      lt_relations = gt_relations.
      lt_columns   = gt_columns_all.

      DELETE lt_relations WHERE tabname NE iv_tabname.
      DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING tabname.
      DELETE lt_columns   WHERE tabname NE iv_tabname.

      SORT lt_columns BY fldname tabname.

      DESCRIBE TABLE lt_columns LINES lv_lines.
      CLEAR lv_tabix.

      LOOP AT lt_relations ASSIGNING <fs_relations>.
        lv_is_cds_entity = me->is_cds_entity( <fs_relations>-tabname ).

        LOOP AT lt_columns ASSIGNING <fs_columns> WHERE tabname = <fs_relations>-tabname AND fldname NE 'MANDT'.

          ADD 1 TO lv_tabix.

          TRANSLATE <fs_columns>-alias_fldname TO UPPER CASE.

          lv_fldname        = <fs_columns>-fldname && <fs_relations>-sequence.
          lv_alias_fldname  = <fs_columns>-alias_fldname && <fs_relations>-sequence.

          IF iv_alias = abap_true AND gv_alias = abap_true.
            IF <fs_columns>-alias_fldname IS NOT INITIAL.
              CONCATENATE <fs_columns>-fldname 'AS' lv_alias_fldname INTO lv_field SEPARATED BY space.
            ELSE.
              CONCATENATE <fs_columns>-fldname 'AS' lv_fldname INTO lv_field SEPARATED BY space.
            ENDIF.
          ELSEIF iv_alias = abap_true.
            CONCATENATE <fs_columns>-fldname 'AS' lv_fldname INTO lv_field SEPARATED BY space.
          ELSE.
            lv_field = <fs_columns>-fldname.
          ENDIF.

*        IF lv_tabix < lv_lines AND lv_is_cds_entity = abap_true.
*          CONCATENATE lv_field ',' INTO lv_field.
*        ENDIF.

          CONCATENATE lv_rfields lv_field INTO lv_rfields SEPARATED BY space.
          CONCATENATE lv_field ',' INTO lv_field.
          ls_fields-line = lv_field.
          APPEND ls_fields TO et_fields.
        ENDLOOP.

        IF sy-subrc NE 0.

          lv_tabname = <fs_relations>-tabname.

          CALL FUNCTION 'DDIF_FIELDINFO_GET'
            EXPORTING
              tabname   = lv_tabname
            TABLES
              dfies_tab = lt_dfies_tab
            EXCEPTIONS
              OTHERS    = 3.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.

          LOOP AT lt_dfies_tab ASSIGNING <fs_dfies_tab>.
            IF <fs_dfies_tab>-fieldname = 'MANDT'.
              CONTINUE.
            ENDIF.

            FIND <fs_dfies_tab>-fieldname IN lv_rfields.
            IF sy-subrc NE 0.
              lv_field = <fs_dfies_tab>-fieldname .
              CONCATENATE lv_rfields lv_field INTO lv_rfields SEPARATED BY space.
              CONCATENATE lv_field ',' INTO lv_field.
              ls_fields-line = lv_field.
              APPEND ls_fields TO et_fields.
            ENDIF.

          ENDLOOP.

        ENDIF.

      ENDLOOP.
    ENDIF.


    DESCRIBE TABLE et_fields LINES lv_nlines.
    READ TABLE et_fields ASSIGNING <fs_fields> INDEX lv_nlines.
    IF <fs_fields> IS ASSIGNED.
      REPLACE ALL OCCURRENCES OF ',' IN <fs_fields> WITH space.
    ENDIF.

  ENDMETHOD.


  METHOD set_globals.
    gv_kdoc           = iv_kdoc.
    gv_table          = iv_table.
    gv_ddic           = iv_ddic.
    gv_dest           = iv_dest.
    gv_update         = iv_update.
    gv_delete         = iv_delete.
    gv_domainv        = iv_domainv.
    gv_entity         = iv_entity.
    gv_key_queue      = iv_key_queue.
    gv_batch          = iv_batch.
    gt_where          = it_where.
    gv_instid         = iv_instid.
    gv_anytable       = iv_anytable.
    gv_alias          = iv_alias.
    gv_uuid           = iv_uuid.
    gv_fieldname      = iv_fieldname.
    gv_tagdata        = iv_tagdata.
    gv_tagmetadata    = iv_tagmetadata.
    gv_bothnames      = iv_bothnames.
    gt_endpoints      = it_endpoints.
    gt_where_cond_tab = it_where_cond_tab.
    gv_variant        = iv_variant.
    gv_tm             = iv_tm.
    gt_ranges_where   = it_ranges_where.
    gv_primary        = iv_dest.

   CLEAR gv_secondary.
    IF iv_kdoc = abap_true.
      CLEAR gv_alias.
    ENDIF.

    me->check_entity_consistency( ).
  ENDMETHOD.


  METHOD set_globals_any.

*    CLEAR: gv_recordst_obj, gv_recordst, gv_sizet.

    CLEAR gs_log_json_result.

    gv_update    = iv_update.
    gv_delete    = iv_delete.
    gv_anytable  = iv_tabname.
    gv_entity    = 'ANY'.
    gv_domainv   = 'ANY'.
    gv_dest      = iv_dest.
    gv_fieldname = iv_fieldname.
    gv_bothnames = iv_bothnames.
    gt_where     = it_where.

    me->append_slg1_log(
      EXPORTING
        iv_tabname    = space
        iv_message_v1 = '*** Any Table Process TABLE ***'
        iv_message_v2 = space
        iv_message_v3 = space
        iv_mestyp     = 'S'
    ).

  ENDMETHOD.


  METHOD set_log_json_result.

    FIELD-SYMBOLS: <fs_log> TYPE ty_table_log.

    READ TABLE gs_log_json_result-tables ASSIGNING <fs_log> WITH KEY tabname = iv_tabname.
    IF sy-subrc NE 0.
      APPEND INITIAL LINE TO gs_log_json_result-tables ASSIGNING <fs_log>.
      <fs_log>-tabname = iv_tabname.
      <fs_log>-size = iv_size.
    ELSE.
      <fs_log>-size = <fs_log>-size + iv_size.
    ENDIF.

  ENDMETHOD.


  METHOD set_metadata_node.

    DATA: lt_fcat       TYPE lvc_t_fcat,
          lt_fcat_evet  TYPE lvc_t_fcat,
          lt_fcat_event TYPE lvc_t_fcat,
          ls_fcat       TYPE dfies,
          ls_component  TYPE zonta_oc_col_all,
          lv_int        TYPE i,
          lv_len        TYPE outputlen.

    FIELD-SYMBOLS: <fs_fcat>     TYPE LINE OF lvc_t_fcat,
                   <fs_metadata> TYPE any,
                   <fs_field>    TYPE any,
                   <fs_len>      TYPE any.

    FIELD-SYMBOLS: <fs_metadata_chg> TYPE STANDARD TABLE.

    ASSIGN cs_metadata TO <fs_metadata_chg>.

    lt_fcat = it_fcat.

    lt_fcat_event = it_fcat.

    DELETE lt_fcat WHERE tabname NE iv_tabname.

    DELETE lt_fcat_event WHERE tabname NE 'ZONST_OC_EVENTID'.

    APPEND LINES OF lt_fcat_event TO lt_fcat.

    LOOP AT lt_fcat ASSIGNING <fs_fcat>.

      READ TABLE gt_dfies_tab_cat WITH KEY tabname   = <fs_fcat>-tabname
                                           fieldname = <fs_fcat>-fieldname
                                           INTO ls_fcat.
      IF sy-subrc EQ 0.
        APPEND INITIAL LINE TO <fs_metadata_chg> ASSIGNING <fs_metadata>.

        ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE <fs_metadata> TO <fs_field>.
        READ TABLE gt_columns_all WITH KEY tabname = <fs_fcat>-tabname
                                           fldname = <fs_fcat>-fieldname
                                           INTO ls_component.
        IF sy-subrc EQ 0.
          IF gv_bothnames EQ abap_true.
            <fs_field> = ls_fcat-fieldname &&
                         '_'               &&
                         ls_component-alias_fldname.

          ELSE.
            IF gv_fieldname EQ abap_true.
              <fs_field> = ls_fcat-fieldname.
            ELSE.
              IF NOT ls_component-alias_fldname IS INITIAL.
                <fs_field> = ls_component-alias_fldname.
              ELSE.
                <fs_field> = ls_fcat-fieldname.
              ENDIF.
            ENDIF.
          ENDIF.
        ELSE.
          <fs_field> = ls_fcat-fieldname.
        ENDIF.

        REPLACE ALL OCCURRENCES OF '\'   IN <fs_field> WITH '_'.
        REPLACE ALL OCCURRENCES OF '/'   IN <fs_field> WITH '_'.

        TRANSLATE <fs_field> TO LOWER CASE.

        ASSIGN COMPONENT 'OFFSET' OF STRUCTURE <fs_metadata> TO <fs_field>.
        <fs_field>    = ls_fcat-offset.

*        ASSIGN COMPONENT 'LENGTH' OF STRUCTURE <fs_metadata> TO <fs_field>.
*        <fs_field>    = ls_fcat-outputlen.

*       Check length
        IF ls_fcat-outputlen < ls_fcat-intlen.
          lv_len = ls_fcat-intlen.
        ELSE.
          lv_len = ls_fcat-outputlen.
        ENDIF.

        ASSIGN COMPONENT 'TYPE' OF STRUCTURE <fs_metadata> TO <fs_field>.
        <fs_field>      = ls_fcat-inttype.
        IF <fs_field> = 'y'.
          ASSIGN COMPONENT 'LENGTH' OF STRUCTURE <fs_metadata> TO <fs_len>.
          metadata_conversion( CHANGING cv_type  =  <fs_field> cv_len = <fs_len> ).
          ASSIGN COMPONENT 'LENGTH' OF STRUCTURE <fs_metadata> TO <fs_field>.
          <fs_field>    = <fs_len>.
        ELSE.
          metadata_conversion( CHANGING cv_type  =  <fs_field>  ).
          ASSIGN COMPONENT 'LENGTH' OF STRUCTURE <fs_metadata> TO <fs_field>.
          <fs_field>    = lv_len. "ls_fcat-outputlen.
        ENDIF.

        ASSIGN COMPONENT 'FIELDTEXT' OF STRUCTURE <fs_metadata> TO <fs_field>.
        <fs_field> = ls_fcat-fieldtext.

        ASSIGN COMPONENT 'KEYFLAG' OF STRUCTURE <fs_metadata> TO <fs_field>.
        IF NOT ls_fcat-keyflag IS INITIAL.
          <fs_field>   = ls_fcat-keyflag.
        ELSE.
          <fs_field>   = space. "'null'.
        ENDIF.

        ASSIGN COMPONENT 'DECIMALS' OF STRUCTURE <fs_metadata> TO <fs_field>.
        lv_int = ls_fcat-decimals.
        <fs_field>      =  lv_int.  "DECIMALS INT
        CONDENSE <fs_field>.
      ENDIF.
    ENDLOOP.

    IF NOT iv_tabname IS INITIAL AND
       NOT gv_kdoc IS INITIAL .

      me->set_metadata_table_node( EXPORTING iv_tabname  = iv_tabname
                                   CHANGING  cs_metadata = cs_metadata ).
    ENDIF.

  ENDMETHOD.


  METHOD set_metadata_table_node.

    DATA: lt_relations TYPE STANDARD TABLE OF zonta_relations,
          lv_fieldname TYPE string.

    FIELD-SYMBOLS: <fs_metadata_chg> TYPE STANDARD TABLE,
                   <fs_relations>    TYPE zonta_relations,
                   <fs_metadata>     TYPE any,
                   <fs_field>        TYPE any.

    ASSIGN cs_metadata TO <fs_metadata_chg>.

    lt_relations = gt_relations.
    SORT lt_relations BY sequence.
    DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING sequence.

    LOOP AT lt_relations ASSIGNING <fs_relations>
                               WHERE parent_relation = iv_tabname.

      APPEND INITIAL LINE TO <fs_metadata_chg> ASSIGNING <fs_metadata>.

      lv_fieldname = 'SEQ' && <fs_relations>-sequence.
      TRANSLATE lv_fieldname TO LOWER CASE.

      ASSIGN COMPONENT 'FIELDNAME'  OF STRUCTURE <fs_metadata> TO <fs_field>. <fs_field> = lv_fieldname.
      ASSIGN COMPONENT 'OFFSET'     OF STRUCTURE <fs_metadata> TO <fs_field>. <fs_field> = '0'.
      ASSIGN COMPONENT 'LENGTH'     OF STRUCTURE <fs_metadata> TO <fs_field>. <fs_field> = '0'.
      ASSIGN COMPONENT 'TYPE'       OF STRUCTURE <fs_metadata> TO <fs_field>. <fs_field> = 'table'.
      ASSIGN COMPONENT 'FIELDTEXT'  OF STRUCTURE <fs_metadata> TO <fs_field>. <fs_field> = lv_fieldname.
      ASSIGN COMPONENT 'KEYFLAG'    OF STRUCTURE <fs_metadata> TO <fs_field>. <fs_field> = space.
      ASSIGN COMPONENT 'DECIMALS'    OF STRUCTURE <fs_metadata> TO <fs_field>. <fs_field> = space.  "*decimals

    ENDLOOP.

  ENDMETHOD.


  METHOD set_process.
    DATA: lv_answer TYPE char1.

*BEGIN CECHAVARRIA 15/08/2025
**    CALL FUNCTION 'POPUP_WITH_2_BUTTONS_TO_CHOOSE'
**      EXPORTING
**        diagnosetext1 = 'Execution Mode'
**        textline1     = 'Please select mode'
**        text_option1  = 'Online'
**        text_option2  = 'Background'
**        titel         = 'Process'
**      IMPORTING
**        answer        = lv_answer.
**
**    IF lv_answer = '2'.
**      gv_batch = abap_true.
**    ELSE.
**      gv_batch = abap_false.
**    ENDIF.

    CALL FUNCTION 'POPUP_WITH_3_BUTTONS_TO_CHOOSE'
      EXPORTING
        diagnosetext1 = 'Execution Mode'
        textline1     = 'Please select mode'
        text_option1  = 'Online'
        text_option2  = 'Background'
        text_option3  = 'Preview Json'
        titel         = 'Process'
      IMPORTING
        answer        = lv_answer.

    CASE lv_answer.
      WHEN '2'.
        IF lv_answer = '2'.
          gv_batch = abap_true.
        ELSE.
          gv_batch = abap_false.
        ENDIF.
      WHEN  '3'.
        IF lv_answer = '3'.
          gv_json_prev = abap_true.
        ELSE.
          gv_json_prev = abap_false.
        ENDIF.
      WHEN  'A'."Cancel
        ev_closed = abap_true.
        RETURN.
      WHEN OTHERS.
    ENDCASE.
*END CECHAVARRIA 15/08/2025
  ENDMETHOD.


  METHOD set_table.

    DATA: lt_json_map TYPE zontt_dd03p,
          ls_json_map LIKE LINE OF lt_json_map,
          ls_gtjson   LIKE LINE OF gt_json_map.

    FIELD-SYMBOLS: <fs_json_map> LIKE LINE OF gt_json_map.

    IF NOT gv_anytable IS INITIAL.
      CREATE DATA rt_table TYPE (gv_anytable).
    ELSE.
      " Delegate logic to subclass
      CALL METHOD me->set_table_custom
        EXPORTING
          iv_add_tabname = iv_add_tabname
        IMPORTING
          rt_table       = rt_table
        CHANGING
          ct_json_map    = lt_json_map.

      IF lines( gt_json_map ) = 0.
        APPEND LINES OF lt_json_map TO gt_json_map.
      ENDIF.

    ENDIF.


  ENDMETHOD.


  METHOD set_table_custom.


    DATA: lt_dfies_tab     TYPE STANDARD TABLE OF dfies,
          lt_dfies_tab_cat TYPE STANDARD TABLE OF dfies,
          ls_dfies_tab_cat TYPE dfies,
          lt_relations     TYPE STANDARD TABLE OF zonta_relations,
          lt_columns       TYPE STANDARD TABLE OF zonta_oc_col_all,
          ls_conv          LIKE LINE OF gt_converted,
          ls_dyn_fcat      TYPE lvc_s_fcat,
          lt_dyn_fcat      TYPE lvc_t_fcat,
          lv_pos           TYPE i,
          lt_dyn_table     TYPE REF TO data,
          lv_field         TYPE string,
          lv_tabname       TYPE ddobjname,
          lv_created       TYPE boolean.

    FIELD-SYMBOLS: <fs_relations>     TYPE zonta_relations,
                   <fs_columns>       TYPE zonta_oc_col_all,
                   <fs_dfies_tab>     TYPE dfies,
                   <fs_json_map>      TYPE dd03p,
                   <fs_dfies_tab_add> TYPE dfies,
                   <fs_fcat>          LIKE LINE OF lt_dyn_fcat.

    FIELD-SYMBOLS: <fs_dyn_table> TYPE STANDARD TABLE.

    SORT lt_dyn_fcat BY fieldname.

    IF lines( gt_relations ) = 0.
      SELECT *
        INTO TABLE gt_relations
        FROM zonta_relations
        WHERE domainv = gv_domainv
          AND business_proc = gv_entity.
    ENDIF.

    IF lines( gt_converted ) = 0 AND lines( gt_relations ) > 0.
      SELECT *
        INTO TABLE gt_converted
        FROM zonta_oc_conv
        FOR ALL ENTRIES IN gt_relations
        WHERE tabname = gt_relations-tabname
         AND  alias_tabname = gt_relations-alias_tabname.
    ENDIF.

    IF NOT gv_anytable IS INITIAL.
      CREATE DATA lt_dyn_table TYPE (gv_anytable).
    ELSE.
      lt_relations = gt_relations.
      lt_columns   = gt_columns_all.

      DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING sequence.

      SORT lt_columns BY fldname tabname.
      SORT gt_converted BY tabname fldname.

      DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING sequence.


      LOOP AT lt_relations ASSIGNING <fs_relations>.

        lv_tabname = <fs_relations>-tabname.

        CALL FUNCTION 'DDIF_FIELDINFO_GET'
          EXPORTING
            tabname        = lv_tabname
          TABLES
            dfies_tab      = lt_dfies_tab
          EXCEPTIONS
            not_found      = 1
            internal_error = 2
            OTHERS         = 3.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        DELETE lt_dfies_tab WHERE fieldname CP '.NODE*'."CECHAVARRIA 17/07/2025
        APPEND LINES OF lt_dfies_tab TO lt_dfies_tab_cat.
      ENDLOOP.
      LOOP AT lt_dfies_tab_cat INTO ls_dfies_tab_cat.
        REPLACE ALL OCCURRENCES OF '/' IN ls_dfies_tab_cat-fieldtext WITH '_'.
        REPLACE ALL OCCURRENCES OF '\' IN ls_dfies_tab_cat-fieldtext WITH '_'.
        REPLACE ALL OCCURRENCES OF '"' IN ls_dfies_tab_cat-fieldtext WITH '_'.
        MODIFY lt_dfies_tab_cat FROM ls_dfies_tab_cat.
      ENDLOOP.
      LOOP AT lt_relations ASSIGNING <fs_relations>.
        LOOP AT lt_columns ASSIGNING <fs_columns>
                            WHERE tabname EQ <fs_relations>-tabname.
          CLEAR ls_conv.
          READ TABLE gt_converted WITH KEY tabname = <fs_columns>-tabname
                                           fldname = <fs_columns>-fldname
                                           INTO ls_conv BINARY SEARCH.
          READ TABLE lt_dfies_tab_cat WITH KEY  tabname   = <fs_columns>-tabname
                                                fieldname = <fs_columns>-fldname
                                                ASSIGNING <fs_dfies_tab>.
          IF sy-subrc EQ 0.
            lv_pos = lv_pos + 1.

            IF NOT gv_alias IS INITIAL.
              IF NOT <fs_columns>-alias_fldname IS INITIAL.
                ls_dyn_fcat-fieldname = <fs_columns>-alias_fldname.
              ELSE.
                ls_dyn_fcat-fieldname = <fs_dfies_tab>-fieldname.
              ENDIF.
            ELSE.
              ls_dyn_fcat-fieldname = <fs_dfies_tab>-fieldname.
            ENDIF.
            IF ls_conv IS NOT INITIAL.
              ls_dyn_fcat-fieldname = ls_conv-fldname1.   "30
*              <fs_dfies_tab>-fieldname = ls_conv-fldname1.
            ENDIF.

            TRANSLATE ls_dyn_fcat-fieldname TO UPPER CASE.

            READ TABLE lt_dyn_fcat WITH KEY fieldname = ls_dyn_fcat-fieldname
                                   TRANSPORTING NO FIELDS.
            ls_dyn_fcat-fieldname = ls_dyn_fcat-fieldname && <fs_relations>-sequence.
            ls_dyn_fcat-tabname   = <fs_dfies_tab>-tabname.
            ls_dyn_fcat-col_pos   = lv_pos ."<fs_dfies_tab>-position."lv_pos.
            ls_dyn_fcat-key       = <fs_dfies_tab>-keyflag.
            ls_dyn_fcat-ref_field = <fs_dfies_tab>-fieldname.
            ls_dyn_fcat-ref_table = <fs_dfies_tab>-tabname.
            ls_dyn_fcat-decimals  = <fs_dfies_tab>-decimals.  "DECIMALS
            ls_dyn_fcat-outputlen = <fs_dfies_tab>-outputlen.
            ls_dyn_fcat-intlen    = <fs_dfies_tab>-intlen.

            APPEND ls_dyn_fcat TO lt_dyn_fcat.
            CLEAR ls_dyn_fcat.

            APPEND INITIAL LINE TO ct_json_map ASSIGNING <fs_json_map>.

            MOVE-CORRESPONDING <fs_dfies_tab> TO <fs_json_map>.

*Validate if reftable is a CDS, add correct table DDIC
            IF abap_true = is_cds_entity( iv_tabname = <fs_json_map>-reftable ) AND
              <fs_json_map>-reftable IS NOT INITIAL.
              <fs_json_map>-reftable = get_ddicobject_from_cds( iv_tabname = <fs_json_map>-reftable ).
            ENDIF.
            IF NOT gv_alias IS INITIAL.
              IF NOT <fs_columns>-alias_fldname IS INITIAL.
                <fs_json_map>-fieldname = <fs_columns>-alias_fldname.
                TRANSLATE <fs_json_map>-fieldname TO UPPER CASE.
              ELSE.
                <fs_json_map>-fieldname = <fs_dfies_tab>-fieldname.
              ENDIF.
            ELSE.
              <fs_json_map>-fieldname = <fs_dfies_tab>-fieldname.
            ENDIF.
            <fs_json_map>-tabname   = <fs_dfies_tab>-tabname.
            <fs_json_map>-datatype  = <fs_dfies_tab>-datatype.
            <fs_json_map>-leng      = <fs_dfies_tab>-leng.
            <fs_json_map>-position  = <fs_dfies_tab>-position.

            IF ls_conv IS NOT INITIAL.
              <fs_json_map>-fieldname = ls_conv-fldname1.
            ENDIF.
          ENDIF.
        ENDLOOP.
        IF sy-subrc NE 0.
          lv_tabname = <fs_relations>-tabname.

          CALL FUNCTION 'DDIF_FIELDINFO_GET'
            EXPORTING
              tabname        = lv_tabname
            TABLES
              dfies_tab      = lt_dfies_tab
            EXCEPTIONS
              not_found      = 1
              internal_error = 2
              OTHERS         = 3.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.

          DELETE lt_dfies_tab WHERE fieldname CP '.NODE*'."CECHAVARRIA 17/07/2025
          LOOP AT lt_dfies_tab ASSIGNING <fs_dfies_tab>
                               WHERE fieldname NE 'MANDT'.
            CLEAR ls_conv.
            READ TABLE gt_converted WITH KEY tabname = <fs_dfies_tab>-tabname
                                             fldname = <fs_dfies_tab>-fieldname
                                             INTO ls_conv BINARY SEARCH.

            READ TABLE lt_dyn_fcat WITH KEY fieldname = <fs_dfies_tab>-fieldname
                                   TRANSPORTING NO FIELDS.

            IF ls_conv IS NOT INITIAL.
              lv_field = ls_conv-fldname1 && <fs_relations>-sequence.   "30
            ELSE.
              lv_field = <fs_dfies_tab>-fieldname && <fs_relations>-sequence.
            ENDIF.


            READ TABLE lt_dfies_tab_cat WITH KEY tabname   = <fs_dfies_tab>-tabname
                                                 fieldname = <fs_dfies_tab>-fieldname
                                           ASSIGNING <fs_dfies_tab_add>.
            IF sy-subrc EQ 0.

              lv_pos = lv_pos + 1.

              ls_dyn_fcat-fieldname = lv_field.
              ls_dyn_fcat-tabname   = <fs_dfies_tab_add>-tabname.
              ls_dyn_fcat-coltext   = <fs_dfies_tab_add>-scrtext_l.
              ls_dyn_fcat-col_pos   = lv_pos. "<fs_dfies_tab>-position. "lv_pos.
              ls_dyn_fcat-key       = <fs_dfies_tab_add>-keyflag.
              ls_dyn_fcat-datatype  = <fs_dfies_tab>-datatype.
              ls_dyn_fcat-decimals  = <fs_dfies_tab>-decimals. "DECIMALS
              ls_dyn_fcat-outputlen = <fs_dfies_tab>-outputlen.
              ls_dyn_fcat-intlen    = <fs_dfies_tab>-intlen.
              APPEND ls_dyn_fcat TO lt_dyn_fcat.
              CLEAR ls_dyn_fcat.

              APPEND INITIAL LINE TO ct_json_map ASSIGNING <fs_json_map>.

              MOVE-CORRESPONDING <fs_dfies_tab> TO <fs_json_map>.

              <fs_json_map>-fieldname = <fs_dfies_tab_add>-fieldname.
              <fs_json_map>-tabname   = <fs_dfies_tab_add>-tabname.
              <fs_json_map>-datatype  = <fs_dfies_tab_add>-datatype.
              <fs_json_map>-leng      = <fs_dfies_tab_add>-leng.
              IF ls_conv IS NOT INITIAL.
                <fs_json_map>-fieldname = ls_conv-fldname1.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDLOOP.


** Start Add Event id fields
      IF gs_oc_obj-eventid  EQ abap_true OR
         gs_oc_obj-metadata EQ abap_true.

        lv_tabname = 'ZONST_OC_EVENTID'.

        CALL FUNCTION 'DDIF_FIELDINFO_GET'
          EXPORTING
            tabname        = lv_tabname
          TABLES
            dfies_tab      = lt_dfies_tab
          EXCEPTIONS
            not_found      = 1
            internal_error = 2
            OTHERS         = 3.
        IF sy-subrc EQ 0.
          IF gs_oc_obj-eventid  EQ abap_false.
            DELETE lt_dfies_tab WHERE fieldname EQ 'OBJECTID'
                                   OR fieldname EQ 'EVENTID'
                                   OR fieldname EQ 'OBJECTIDEVT'
                                   OR fieldname EQ 'EVENTIDEVT'.

          ENDIF.

          IF gs_oc_obj-metadata EQ abap_false.
            DELETE lt_dfies_tab WHERE fieldname(03) EQ 'TAG'.
          ENDIF.
          APPEND LINES OF lt_dfies_tab TO lt_dfies_tab_cat.
        ENDIF.


        LOOP AT lt_dfies_tab ASSIGNING <fs_dfies_tab>
                               WHERE fieldname NE 'MANDT'.
          CLEAR ls_conv.
          READ TABLE gt_converted WITH KEY tabname = <fs_dfies_tab>-tabname
                                           fldname = <fs_dfies_tab>-fieldname
                                           INTO ls_conv BINARY SEARCH.

          READ TABLE lt_dyn_fcat WITH KEY fieldname = <fs_dfies_tab>-fieldname
                                TRANSPORTING NO FIELDS.

          IF ls_conv IS NOT INITIAL.
            lv_field = ls_conv-fldname1 && <fs_relations>-sequence.   "30
          ELSE.
            lv_field = <fs_dfies_tab>-fieldname && <fs_relations>-sequence.
          ENDIF.


          READ TABLE lt_dfies_tab_cat WITH KEY tabname   = <fs_dfies_tab>-tabname
                                               fieldname = <fs_dfies_tab>-fieldname
                                         ASSIGNING <fs_dfies_tab_add>.
          IF sy-subrc EQ 0.
            lv_pos = lv_pos + 1.

            ls_dyn_fcat-fieldname = lv_field.
            ls_dyn_fcat-tabname   = <fs_dfies_tab_add>-tabname.
            ls_dyn_fcat-coltext   = <fs_dfies_tab_add>-scrtext_l.
            ls_dyn_fcat-col_pos   = lv_pos.
            ls_dyn_fcat-key       = <fs_dfies_tab_add>-keyflag.
            ls_dyn_fcat-datatype  = <fs_dfies_tab>-datatype.
            ls_dyn_fcat-inttype   = <fs_dfies_tab>-inttype.
            ls_dyn_fcat-intlen    = <fs_dfies_tab>-intlen.
            ls_dyn_fcat-decimals  = <fs_dfies_tab>-decimals.  "DECIMALS
            ls_dyn_fcat-outputlen = <fs_dfies_tab>-outputlen.
            ls_dyn_fcat-intlen    = <fs_dfies_tab>-intlen.
            ls_dyn_fcat-outputlen = <fs_dfies_tab>-outputlen.
            ls_dyn_fcat-intlen    = <fs_dfies_tab>-intlen.
            APPEND ls_dyn_fcat TO lt_dyn_fcat.
            CLEAR ls_dyn_fcat.

            APPEND INITIAL LINE TO ct_json_map ASSIGNING <fs_json_map>.

            MOVE-CORRESPONDING <fs_dfies_tab> TO <fs_json_map>.

            <fs_json_map>-fieldname = <fs_dfies_tab_add>-fieldname.
            <fs_json_map>-tabname   = <fs_dfies_tab_add>-tabname.
            <fs_json_map>-datatype  = <fs_dfies_tab_add>-datatype.
            <fs_json_map>-leng      = <fs_dfies_tab_add>-leng.
          ENDIF.
        ENDLOOP.

      ENDIF.

** End Add Event id fields

** Add tab name field
      IF NOT iv_add_tabname IS INITIAL.
        lv_pos = lv_pos + 1.

        ls_dyn_fcat-fieldname = 'TABNAME'.
        ls_dyn_fcat-coltext   = 'Table Name'.
        ls_dyn_fcat-col_pos   = lv_pos.
        ls_dyn_fcat-datatype  = 'C'.
        ls_dyn_fcat-inttype   = 'C'.
        ls_dyn_fcat-intlen    = 30.

        APPEND ls_dyn_fcat TO lt_dyn_fcat.
        CLEAR ls_dyn_fcat.

      ENDIF.

* Review not allowed types
      LOOP AT lt_dyn_fcat ASSIGNING <fs_fcat> WHERE inttype = 'y'.
        <fs_fcat>-inttype = 'X'.
        <fs_fcat>-outputlen = '256'.
      ENDLOOP.

* Create a dynamic internal table with this structure.
      SORT lt_dyn_fcat BY fieldname.
      DELETE ADJACENT DUPLICATES FROM lt_dyn_fcat COMPARING fieldname.

      SORT lt_dyn_fcat BY tabname col_pos.


      lv_created = abap_false.
      IF iv_add_tabname = abap_true AND gr_cached_type_w IS NOT INITIAL.
        CREATE DATA lt_dyn_table TYPE HANDLE gr_cached_type_w.
        ASSIGN lt_dyn_table->* TO <fs_dyn_table>.
        rt_table = lt_dyn_table.
        lv_created = abap_true.
      ELSEIF iv_add_tabname = abap_false AND gr_cached_type_wo IS NOT INITIAL.
        CREATE DATA lt_dyn_table TYPE HANDLE gr_cached_type_wo.
        ASSIGN lt_dyn_table->* TO <fs_dyn_table>.
        rt_table = lt_dyn_table.
        lv_created = abap_true.
      ENDIF.

      IF lv_created = abap_false.

        CALL METHOD cl_alv_table_create=>create_dynamic_table
          EXPORTING
            i_style_table             = abap_false "'X'
            it_fieldcatalog           = lt_dyn_fcat
          IMPORTING
            ep_table                  = lt_dyn_table
          EXCEPTIONS
            generate_subpool_dir_full = 1
            OTHERS                    = 2.
        ASSIGN lt_dyn_table->* TO <fs_dyn_table>.
        rt_table = lt_dyn_table.

        IF iv_add_tabname = abap_true.
          gr_cached_type_w ?= cl_abap_tabledescr=>describe_by_data_ref( lt_dyn_table ).
        ELSEIF iv_add_tabname = abap_false.
          gr_cached_type_wo ?= cl_abap_tabledescr=>describe_by_data_ref( lt_dyn_table ).
        ENDIF.

      ENDIF.

    ENDIF. "lv_created

*    ASSIGN lt_dyn_table->* TO <fs_dyn_table>.
*    rt_table = lt_dyn_table.

    gt_dfies_tab_cat = lt_dfies_tab_cat.

    SORT ct_json_map BY tabname position.

  ENDMETHOD.


  METHOD set_variant.

    DATA: lo_interpreter TYPE REF TO zoncl_dynamic_interpreter.

    DATA: lv_answer TYPE char1,
          lv_memory TYPE char25.

    DATA: lt_variant TYPE STANDARD TABLE OF zonta_oc_variant.

    IF gv_variant IS INITIAL.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          text_question         = 'Select option'
          text_button_1         = 'Execute'
          icon_button_1         = 'ICON_EXECUTE_OBJECT'
          text_button_2         = 'Save Variant'
          icon_button_2         = 'ICON_ALV_VARIANT_SAVE'
          default_button        = '1'
          display_cancel_button = 'X'
        IMPORTING
          answer                = lv_answer
        EXCEPTIONS
          text_not_found        = 1
          OTHERS                = 2.

      IF lv_answer = '2'.
        CONCATENATE 'ZVARI' sy-uname INTO lv_memory.
        " Export both tables to memory
        EXPORT gt_cond_tab = gt_cond_tab
               gt_fieltab  = gt_fieldtab
               gt_field_ranges = gt_field_ranges
               gv_entity       = gv_entity
               gv_domainv      = gv_domainv
          TO MEMORY ID lv_memory.
        CALL TRANSACTION 'ZONT_VARIANT'.
      ENDIF.

      IF lv_answer = 'A'.
        gv_cancelled = abap_true.
        call TRANSACTION 'ZONT_ONECM'.
      ENDIF.

      CONCATENATE 'ZGVAR' sy-uname INTO lv_memory.
      IMPORT gv_variant = gv_variant FROM MEMORY ID lv_memory.

    ELSE.

      CONCATENATE 'ZVARI' sy-uname INTO lv_memory.
      " Export both tables to memory
      EXPORT gt_cond_tab = gt_cond_tab
             gt_fieltab  = gt_fieldtab
             gt_field_ranges = gt_field_ranges
             gv_entity       = gv_entity
             gv_domainv      = gv_domainv
             gv_variant      = gv_variant
        TO MEMORY ID lv_memory.

      CALL TRANSACTION 'ZONT_VARIANT'.


      CONCATENATE 'ZGVAR' sy-uname INTO lv_memory.
      IMPORT gv_variant = gv_variant FROM MEMORY ID lv_memory.
    ENDIF.
  ENDMETHOD.


  METHOD set_where.
    TYPES: BEGIN OF lty_rsds_where,
             tablename TYPE rsdstabs-prim_tab,
             where_tab TYPE zonttrsdswhere,
           END OF lty_rsds_where.

    TYPES: ty_rsds_twhere TYPE STANDARD TABLE OF lty_rsds_where.

    DATA: selid            TYPE rsdynsel-selid,
*          field_tab      TYPE TABLE OF rsdsfields,
          field_tab_excl   TYPE TABLE OF rsdsfields,
          table_tab        TYPE TABLE OF rsdstabs,
          cond_tab         TYPE rsds_twhere,
          lv_title         TYPE sy-title,
          lv_tabname       TYPE ddobjname,
          lv_message_error TYPE string, "chel 10/01/2025
          lt_relations     TYPE STANDARD TABLE OF zonta_relations,
          ls_variant       TYPE zonta_oc_variant,
          ls_franges       TYPE zonta_oc_franges,
          lt_columns       TYPE STANDARD TABLE OF zonta_oc_col_all,
          lr_where         type ZONTTRSDSWHERE.

    FIELD-SYMBOLS: <fs_table_tab>      TYPE rsdstabs,
                   <fs_dfies_tab_cat>  TYPE dfies,
                   <fs_field_tab_excl> TYPE rsdsfields,
                   <fs_relations>      TYPE zonta_relations.


    ev_closed = abap_false.

    IF gv_variant IS NOT INITIAL.
      SELECT SINGLE *
        INTO ls_variant
        FROM zonta_oc_variant
        WHERE domainv       = gv_domainv
          AND business_proc = gv_entity
          AND variant       = gv_variant.
      IF sy-subrc =  0.
        IF ls_variant-variant_type = 'F'.
          SELECT SINGLE *
            INTO ls_franges
            FROM zonta_oc_franges
            WHERE domainv       = gv_domainv
           AND business_proc = gv_entity
           AND variant       = gv_variant.
          IF sy-subrc NE 0.
            MESSAGE i045(zon_cl_oc) WITH gv_variant DISPLAY LIKE 'E'.
            CLEAR gv_variant.
          ENDIF.
        ELSE.

        ENDIF.
      ELSE.
        MESSAGE i046(zon_cl_oc) WITH gv_variant DISPLAY LIKE 'E'.
        CLEAR gv_variant.
      ENDIF.
    ENDIF.

    IF gv_variant IS INITIAL.
      REFRESH gt_fieldtab.
      REFRESH gt_cond_tab.
      IF NOT gv_anytable IS INITIAL.
        APPEND INITIAL LINE TO table_tab ASSIGNING <fs_table_tab>.
        <fs_table_tab>-prim_tab = gv_anytable.

        IF NOT iv_any IS INITIAL.
          lv_tabname = gv_anytable.
          CALL FUNCTION 'DDIF_FIELDINFO_GET'
            EXPORTING
              tabname   = lv_tabname
            TABLES
              dfies_tab = gt_dfies_tab_cat.

          LOOP AT gt_dfies_tab_cat ASSIGNING <fs_dfies_tab_cat>.
            READ TABLE gt_columns_all WITH KEY
              tabname         = <fs_dfies_tab_cat>-tabname
              fldname         = <fs_dfies_tab_cat>-fieldname
              selection_field = abap_true
              TRANSPORTING NO FIELDS.

            IF sy-subrc NE 0.
              APPEND INITIAL LINE TO field_tab_excl ASSIGNING <fs_field_tab_excl>.
              <fs_field_tab_excl>-tablename = <fs_dfies_tab_cat>-tabname.
              <fs_field_tab_excl>-fieldname = <fs_dfies_tab_cat>-fieldname.
            ENDIF.
          ENDLOOP.
        ENDIF.

      ELSE.
        lt_relations = gt_relations.
        lt_columns   = gt_columns_all.
        DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING sequence.
        SORT lt_columns BY fldname tabname.

        LOOP AT lt_relations ASSIGNING <fs_relations>.
          APPEND INITIAL LINE TO table_tab ASSIGNING <fs_table_tab>.
          <fs_table_tab>-prim_tab = <fs_relations>-tabname.
        ENDLOOP.

        LOOP AT lt_relations ASSIGNING <fs_relations>.
          LOOP AT gt_dfies_tab_cat ASSIGNING <fs_dfies_tab_cat>
                                   WHERE tabname = <fs_relations>-tabname.
            READ TABLE lt_columns WITH KEY
              tabname = <fs_dfies_tab_cat>-tabname
              TRANSPORTING NO FIELDS.
            IF sy-subrc NE 0.
              CONTINUE.
            ENDIF.

            READ TABLE lt_columns WITH KEY
              tabname         = <fs_dfies_tab_cat>-tabname
              fldname         = <fs_dfies_tab_cat>-fieldname
              selection_field = abap_true
              TRANSPORTING NO FIELDS.
            IF sy-subrc NE 0.
              APPEND INITIAL LINE TO field_tab_excl ASSIGNING <fs_field_tab_excl>.
              <fs_field_tab_excl>-tablename = <fs_dfies_tab_cat>-tabname.
              <fs_field_tab_excl>-fieldname = <fs_dfies_tab_cat>-fieldname.
            ENDIF.
          ENDLOOP.
***
          " Exclude the node (blank fieldname)
          APPEND INITIAL LINE TO field_tab_excl ASSIGNING <fs_field_tab_excl>.
          <fs_field_tab_excl>-tablename =  <fs_relations>-tabname.
          <fs_field_tab_excl>-fieldname = '.NODE1'.               " << THIS IS IMPORTANT
*****
        ENDLOOP.
      ENDIF.

      CALL FUNCTION 'FREE_SELECTIONS_INIT'
        EXPORTING
          kind                  = 'T'
        IMPORTING
          selection_id          = selid
        TABLES
          tables_tab            = table_tab
          tabfields_not_display = field_tab_excl.

      READ TABLE lt_relations INDEX 1 ASSIGNING <fs_relations>.
      IF <fs_relations> IS ASSIGNED.
        CONCATENATE 'Entity' <fs_relations>-domainv ' -' <fs_relations>-business_proc
                    INTO lv_title SEPARATED BY space.
      ELSE.
        lv_title = 'Entity - ANY'.
      ENDIF.
      DATA v_tryoff TYPE c.
      SELECT SINGLE low INTO v_tryoff FROM zonta_oc_param WHERE name = 'SET_TRY_OFF'.
      IF v_tryoff IS NOT INITIAL.
        CALL FUNCTION 'FREE_SELECTIONS_DIALOG'
          EXPORTING
            selection_id    = selid
            title           = lv_title
            as_window       = abap_false
          IMPORTING
            where_clauses   = gt_cond_tab
            field_ranges    = gt_field_ranges
          TABLES
            fields_tab      = gt_fieldtab
          EXCEPTIONS
            internal_error  = 1
            no_action       = 2
            selid_not_found = 3
            illegal_status  = 4
            OTHERS          = 5.
        IF sy-subrc <> 0.
          IF sy-subrc EQ 2.
            ev_closed = abap_true.
            RETURN.
          ENDIF.
        ENDIF.
      ELSE.

        TRY."FR
            CALL FUNCTION 'FREE_SELECTIONS_DIALOG'
              EXPORTING
                selection_id    = selid
                title           = lv_title
                as_window       = abap_false
              IMPORTING
                where_clauses   = gt_cond_tab
                field_ranges    = gt_field_ranges
              TABLES
                fields_tab      = gt_fieldtab
              EXCEPTIONS
                internal_error  = 1
                no_action       = 2
                selid_not_found = 3
                illegal_status  = 4
                OTHERS          = 5.
            IF sy-subrc <> 0.
            ENDIF.

          CATCH cx_root INTO gx_text.
            gs_elog-type       = 'FREE_SELECTIONS_DIALOG'.
            gs_elog-severity   = gc_error.
            gs_elog-message    = gx_text->get_longtext( ).
            CALL METHOD gx_text->get_source_position
              IMPORTING
                program_name = gv_prog
                source_line  = gv_sline.
            gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
            gs_elog-details-db = 'ZONCL_OC_BASE_HANDLER-SET_WHERE'.
            gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

            gs_elog-metadata-error_code = gs_elog-details-error_code.
            interpret_message( EXPORTING iv_msgnr = '066' IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '067' IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '068' IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
            CONCATENATE gv_msg1 gv_msg2 gv_msg3 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
            interpret_message( EXPORTING iv_msgnr = '069' iv_msgv1 = gv_entity IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '065' iv_msgv1 = gv_entity IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '070' IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_fixes ).
            CONCATENATE gv_msg1 gv_msg2 gv_msg3 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.
            print_error_otel( ).
            send_json_error( ).
            me->print_error( ).
        ENDTRY.
      ENDIF.

*BEGIN CHEL 10/0172025
      IF gt_cond_tab[] IS NOT INITIAL.
        lv_message_error = validate_where_3_tables( ).
        IF lv_message_error IS NOT INITIAL.
          MESSAGE lv_message_error TYPE 'E'.
        ENDIF.
      ENDIF.
*END CHEL 10/01/2025

      IF gv_entity NE 'ANY'.
*     Call new screen to save variants
        me->set_variant( ).
        IF gv_variant IS NOT INITIAL.
          CALL METHOD me->get_variant_values
            EXPORTING
              iv_variant      = gv_variant
              iv_domainv      = gv_domainv
              iv_entity       = gv_entity
            IMPORTING
              et_where        = gt_cond_tab[]
              et_ranges_where = gt_ranges_where[].
        ENDIF.
      ENDIF.

* Variant already exists
    ELSE.

*      CALL METHOD me->get_variant_values
*        EXPORTING
*          iv_variant = gv_variant
*          iv_domainv = gv_domainv
*          iv_entity  = gv_entity
*        IMPORTING
*          et_where   = gt_cond_tab[].

      CALL METHOD me->display_where_with_variant
        RECEIVING
          r_where = lr_where.


    ENDIF.
  ENDMETHOD.


  METHOD set_where_with_variant.


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
          lt_columns   TYPE STANDARD TABLE OF zonta_oc_col_all.

    DATA: lt_columns_tmp TYPE STANDARD TABLE OF zonta_oc_col_all,
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

    SELECT * INTO TABLE lt_ranges
      FROM zonta_oc_franges
      WHERE domainv       = gv_domainv
        AND business_proc = gv_entity
        AND variant       = gv_variant.


    CLEAR lt_rsds_selopt_t[].
    CLEAR lt_frange_t[].
    CLEAR ls_rsds_range.
    CLEAR lt_ranges_ini[].


    REFRESH gt_fieldtab.
    REFRESH gt_cond_tab.

    lt_relations[] = gt_relations[].
*    lt_columns[]   = it_columns[].

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

    IF lines( lt_ranges ) > 0.
      SORT lt_ranges BY tabname fldname.
      READ TABLE lt_ranges INTO ls_ranges INDEX 1.
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

      LOOP AT lt_ranges INTO ls_ranges.
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

*    IF gv_domainv IS INITIAL
*    OR gv_entity IS INITIAL.
*      READ TABLE gt_relations INTO ls_relations INDEX 1.
*      gv_domainv = ls_relations-domainv.
*      gv_business_proc = ls_relations-business_proc.
*    ENDIF.

    CONCATENATE 'Entity'
               gv_domainv
               ' - '
               gv_entity
               INTO  lv_title
               SEPARATED BY space.


    CALL FUNCTION 'FREE_SELECTIONS_DIALOG'
      EXPORTING
        selection_id  = selid
        title         = lv_title
        as_window     = abap_false
      IMPORTING
        where_clauses = gt_cond_tab
      TABLES
        fields_tab    = gt_fieldtab
      EXCEPTIONS
        OTHERS        = 4.
    IF sy-subrc <> 0.
      MESSAGE 'No changes were saved' TYPE 'I'.
      lv_nochanges = abap_true.
*      LEAVE PROGRAM.
    ENDIF.







**    TYPES: BEGIN OF lty_rsds_where,
**             tablename TYPE rsdstabs-prim_tab,
**             where_tab TYPE zonttrsdswhere,
**           END OF lty_rsds_where.
**
**    TYPES: ty_rsds_twhere TYPE STANDARD TABLE OF lty_rsds_where.
**
**    DATA: selid          TYPE rsdynsel-selid,
***          field_tab      TYPE TABLE OF rsdsfields,
**          field_tab_excl TYPE TABLE OF rsdsfields,
**          table_tab      TYPE TABLE OF rsdstabs,
**          cond_tab       TYPE rsds_twhere,
**          lv_title       TYPE sy-title,
**          lv_tabname     TYPE ddobjname,
**          lt_relations   TYPE STANDARD TABLE OF zonta_relations,
**          lt_columns     TYPE STANDARD TABLE OF zonta_oc_col_all.
**
**    FIELD-SYMBOLS: <fs_table_tab>      TYPE rsdstabs,
**                   <fs_dfies_tab_cat>  TYPE dfies,
**                   <fs_field_tab_excl> TYPE rsdsfields,
**                   <fs_relations>      TYPE zonta_relations.
**
**    REFRESH gt_fieldtab.
**    REFRESH gt_cond_tab.
**    IF NOT gv_anytable IS INITIAL.
**      APPEND INITIAL LINE TO table_tab ASSIGNING <fs_table_tab>.
**      <fs_table_tab>-prim_tab = gv_anytable.
**
**      IF NOT iv_any IS INITIAL.
**        lv_tabname = gv_anytable.
**        CALL FUNCTION 'DDIF_FIELDINFO_GET'
**          EXPORTING
**            tabname   = lv_tabname
**          TABLES
**            dfies_tab = gt_dfies_tab_cat.
**
**        LOOP AT gt_dfies_tab_cat ASSIGNING <fs_dfies_tab_cat>.
**          READ TABLE gt_columns_all WITH KEY
**            tabname         = <fs_dfies_tab_cat>-tabname
**            fldname         = <fs_dfies_tab_cat>-fieldname
**            selection_field = abap_true
**            TRANSPORTING NO FIELDS.
**
**          IF sy-subrc NE 0.
**            APPEND INITIAL LINE TO field_tab_excl ASSIGNING <fs_field_tab_excl>.
**            <fs_field_tab_excl>-tablename = <fs_dfies_tab_cat>-tabname.
**            <fs_field_tab_excl>-fieldname = <fs_dfies_tab_cat>-fieldname.
**          ENDIF.
**        ENDLOOP.
**      ENDIF.
**
**    ELSE.
**      lt_relations = gt_relations.
**      lt_columns   = gt_columns_all.
**      DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING sequence.
**      SORT lt_columns BY fldname tabname.
**
**      LOOP AT lt_relations ASSIGNING <fs_relations>.
**        APPEND INITIAL LINE TO table_tab ASSIGNING <fs_table_tab>.
**        <fs_table_tab>-prim_tab = <fs_relations>-tabname.
**      ENDLOOP.
**
**      LOOP AT lt_relations ASSIGNING <fs_relations>.
**        LOOP AT gt_dfies_tab_cat ASSIGNING <fs_dfies_tab_cat>
**                                 WHERE tabname = <fs_relations>-tabname.
**          READ TABLE lt_columns WITH KEY
**            tabname = <fs_dfies_tab_cat>-tabname
**            TRANSPORTING NO FIELDS.
**          IF sy-subrc NE 0.
**            CONTINUE.
**          ENDIF.
**
**          READ TABLE lt_columns WITH KEY
**            tabname         = <fs_dfies_tab_cat>-tabname
**            fldname         = <fs_dfies_tab_cat>-fieldname
**            selection_field = abap_true
**            TRANSPORTING NO FIELDS.
**          IF sy-subrc NE 0.
**            APPEND INITIAL LINE TO field_tab_excl ASSIGNING <fs_field_tab_excl>.
**            <fs_field_tab_excl>-tablename = <fs_dfies_tab_cat>-tabname.
**            <fs_field_tab_excl>-fieldname = <fs_dfies_tab_cat>-fieldname.
**          ENDIF.
**        ENDLOOP.
*****
**        " Exclude the node (blank fieldname)
**        APPEND INITIAL LINE TO field_tab_excl ASSIGNING <fs_field_tab_excl>.
**        <fs_field_tab_excl>-tablename =  <fs_relations>-tabname.
**        <fs_field_tab_excl>-fieldname = '.NODE1'.               " << THIS IS IMPORTANT
*******
**      ENDLOOP.
**    ENDIF.
**
*****BREAK-POINT .
**
**    CALL FUNCTION 'FREE_SELECTIONS_INIT'
***    call FUNCTION 'ZONFM_FREE_SELECTIONS_INIT'  "DB Variant
**      EXPORTING
**        kind                  = 'T'
**      IMPORTING
**        selection_id          = selid
**      TABLES
**        tables_tab            = table_tab
**        tabfields_not_display = field_tab_excl.
**
**    READ TABLE lt_relations INDEX 1 ASSIGNING <fs_relations>.
**    IF <fs_relations> IS ASSIGNED.
**      CONCATENATE 'Entity' <fs_relations>-domainv ' -' <fs_relations>-business_proc
**                  INTO lv_title SEPARATED BY space.
**    ELSE.
**      lv_title = 'Entity - ANY'.
**    ENDIF.
**    DATA v_tryoff TYPE c.
**    SELECT SINGLE low INTO v_tryoff FROM zonta_oc_param WHERE name = 'SET_TRY_OFF'.
**    IF v_tryoff IS NOT INITIAL.
**      CALL FUNCTION 'FREE_SELECTIONS_DIALOG'
***      CALL FUNCTION 'ZONFM_FREE_SELECTIONS_DIALOG'  "DB Variant
**        EXPORTING
**          selection_id    = selid
**          title           = lv_title
**          as_window       = abap_false
**        IMPORTING
**          where_clauses   = gt_cond_tab
**        TABLES
**          fields_tab      = gt_fieldtab
**        EXCEPTIONS
**          internal_error  = 1
**          no_action       = 2
**          selid_not_found = 3
**          illegal_status  = 4
**          OTHERS          = 5.
**      IF sy-subrc <> 0.
**      ENDIF.
**    ELSE.
**
**      TRY."FR
**          CALL FUNCTION 'FREE_SELECTIONS_DIALOG'
***          CALL FUNCTION 'ZONFM_FREE_SELECTIONS_DIALOG'  "DB Variant
**            EXPORTING
**              selection_id    = selid
**              title           = lv_title
**              as_window       = abap_false
**            IMPORTING
**              where_clauses   = gt_cond_tab
**            TABLES
**              fields_tab      = gt_fieldtab
**            EXCEPTIONS
**              internal_error  = 1
**              no_action       = 2
**              selid_not_found = 3
**              illegal_status  = 4
**              OTHERS          = 5.
**          IF sy-subrc <> 0.
**          ENDIF.
**
**        CATCH cx_root INTO gx_text.
**          me->print_error( ).
**      ENDTRY.
**    ENDIF.
**
**
**    me->set_variant( ).
  ENDMETHOD.


  METHOD sort_relations.
    TYPES: BEGIN OF ty_range,
             sign	TYPE tvarv_sign,
             opti TYPE tvarv_opti,
             low  TYPE zonta_relations-tabname,
             high TYPE zonta_relations-tabname,
           END OF ty_range.

    DATA: ls_range              TYPE ty_range,
          ls_relation           TYPE zonta_relations,
          lt_relations          TYPE STANDARD TABLE OF zonta_relations,
          lt_relations_to_order TYPE STANDARD TABLE OF zonta_relations,
          lt_relations_to_pross TYPE STANDARD TABLE OF zonta_relations,
          lt_table_pross        TYPE STANDARD TABLE OF ty_range,
          lt_relations_sort     TYPE STANDARD TABLE OF zonta_relations.

    DATA: lv_change TYPE abap_bool,
          lv_lines  TYPE i,
          lv_tabix  TYPE i,
          lv_count  TYPE i.

    FIELD-SYMBOLS: <fs_cond_tab>               TYPE LINE OF rsds_twhere,
                   <fs_filters>                LIKE LINE OF gt_filters,
                   <fs_relations>              TYPE zonta_relations,
                   <fs_relations_parent_aux>   TYPE zonta_relations,
                   <fs_relations_parent_origi> TYPE zonta_relations,
                   <fs_relations_aux>          TYPE zonta_relations,
                   <fs_relations_parent>       TYPE zonta_relations.

    lt_relations_to_pross = cht_relations.
    lt_relations = cht_relations.

    ls_range-sign = 'I'.
    ls_range-opti = 'EQ'.

*Get tables with where
    LOOP AT lt_relations ASSIGNING <fs_relations>.

      READ TABLE gt_cond_tab ASSIGNING <fs_cond_tab>
               WITH KEY tablename = <fs_relations>-tabname.
      IF sy-subrc EQ 0.
        APPEND <fs_relations> TO lt_relations_to_order.
      ENDIF.

      READ TABLE gt_filters ASSIGNING <fs_filters>
         WITH KEY tabname = <fs_relations>-tabname.
      IF sy-subrc EQ 0.
        APPEND <fs_relations> TO lt_relations_to_order.
      ENDIF.
    ENDLOOP.

    DELETE ADJACENT DUPLICATES FROM lt_relations_to_order COMPARING tabname.

    SORT lt_relations_to_order BY sequence ASCENDING.
    CLEAR: lv_count, lv_lines, lv_change.

*If the first table is parent and have where exit
    READ TABLE lt_relations_to_order ASSIGNING <fs_relations_aux>
             INDEX 1.

    IF sy-subrc EQ 0 AND <fs_relations_aux>-parent_relation = ' '.
      RETURN.
     ELSEIF sy-subrc NE 0."If not get where exit
      RETURN.
    ENDIF.

    DO.

      lv_count = lv_count + 1.

      LOOP AT lt_relations_to_pross ASSIGNING <fs_relations>.

*Search tables to order
        READ TABLE lt_relations_to_order ASSIGNING <fs_relations_aux>
                 WITH KEY tabname = <fs_relations>-tabname.

        IF sy-subrc EQ 0.

          IF lv_count EQ 1.
            MOVE-CORRESPONDING <fs_relations> TO ls_relation.
*Search tables for parent
            READ TABLE lt_relations_to_pross ASSIGNING <fs_relations_parent>
                     WITH KEY tabname = <fs_relations>-parent_relation
                              parent_relation = ' '.

            IF sy-subrc EQ 0.

              CLEAR lv_tabix.
*only the table to order
              LOOP AT lt_relations_to_order ASSIGNING <fs_relations_parent_aux>
                                                WHERE tabname = <fs_relations>-tabname.

                lv_tabix = lv_tabix + 1.

                MOVE-CORRESPONDING <fs_relations_parent_aux> TO ls_relation.
*              ls_relation-sequence        = <fs_relations_parent>-sequence.

*Search tables for parent original
                READ TABLE lt_relations ASSIGNING <fs_relations_parent_origi>
                   WITH KEY tabname = <fs_relations_parent_aux>-parent_relation
                            parent_relation = ' '.

                IF sy-subrc EQ 0.
                  ls_relation-sequence        = <fs_relations_parent_origi>-sequence.
                  ls_relation-parent_relation = <fs_relations_parent_origi>-parent_relation.
                  ls_relation-join_type       = <fs_relations_parent_origi>-join_type.
                ENDIF.

                ls_relation-subsequence     = <fs_relations_parent_aux>-subsequence.
                ls_relation-field_sec       = <fs_relations_parent_aux>-field_sec.

*              ls_relation-levelv          = <fs_relations_parent>-levelv.

                IF lv_tabix EQ 1.
                  <fs_relations_parent>-sequence        = <fs_relations>-sequence.
                  <fs_relations_parent>-subsequence     = <fs_relations>-subsequence.
                  <fs_relations_parent>-field_sec       = <fs_relations>-field_sec.
                  <fs_relations_parent>-parent_relation = <fs_relations>-tabname.
                  <fs_relations_parent>-join_type       = <fs_relations>-join_type.
*              <fs_relations_parent>-levelv          = <fs_relations>-levelv.

                ENDIF.
                APPEND ls_relation  TO lt_relations_sort.

                ls_range-low = <fs_relations_parent_aux>-tabname.
                APPEND  ls_range TO lt_table_pross.
                DELETE lt_relations_to_pross WHERE tabname = <fs_relations_parent_aux>-tabname
                                               AND field_main = <fs_relations_parent_aux>-field_main.
                lv_change = abap_true.
              ENDLOOP.
            ENDIF.
          ENDIF.
*Validate if exit in process or parent is blank
        ELSEIF lv_count > 1 AND
                ( <fs_relations>-parent_relation IS INITIAL OR
                 ( <fs_relations>-parent_relation IS NOT INITIAL AND
                   lv_change = abap_true
                  AND <fs_relations>-parent_relation IN lt_table_pross  ) ).

          APPEND <fs_relations> TO lt_relations_sort.
          ls_range-low = <fs_relations>-tabname.
          APPEND  ls_range TO lt_table_pross.
          DELETE lt_relations_to_pross WHERE tabname = <fs_relations>-tabname
                                         AND field_main = <fs_relations>-field_main.
          lv_change = abap_true.
        ENDIF.

      ENDLOOP.

      " if exit some error exit
      IF lv_change = abap_false.
        " error
        EXIT.
      ENDIF.

      DESCRIBE TABLE lt_relations_to_pross LINES lv_lines.
      "if not exist more register exit
      IF lv_lines = 0.
        EXIT.
      ENDIF.
    ENDDO.

    cht_relations = lt_relations_sort.
  ENDMETHOD.


  METHOD update_slg1_log.

    DATA: lt_log_handle TYPE bal_t_logh,
          lv_log_handle TYPE balloghndl,
          ls_log_ext    TYPE LINE OF zontt_oc_log_ext,
          ls_log_extu   TYPE zonst_oc_log_extu,
          ls_log        TYPE bal_s_log,
          ls_msg        TYPE bal_s_msg,
          lv_message    TYPE string,
          lv_text       TYPE char128,
          lv_errorj     TYPE zonta_oc_param-low,
          ls_errorl     TYPE zonst_log_otel,
          lv_timestamp  TYPE timestamp,
          lv_env        type char50.

    CASE gs_oc_obj-log_type.
      WHEN 'S' OR space. " SLG1 logging

        ls_log-object     = 'ZONI_OC'.
        ls_log-subobject  = gv_domainv.
        ls_log-alprog     = sy-cprog.

        CALL FUNCTION 'BAL_LOG_CREATE'
          EXPORTING
            i_s_log      = ls_log
          IMPORTING
            e_log_handle = lv_log_handle
          EXCEPTIONS
            OTHERS       = 1.

        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

        LOOP AT it_log_ext INTO ls_log_ext.

          CALL FUNCTION 'FORMAT_MESSAGE' ##FM_SUBRC_OK
            EXPORTING
              id   = ls_log_ext-id
              lang = sy-langu
              no   = ls_log_ext-number
              v1   = ls_log_ext-message_v1
              v2   = ls_log_ext-message_v2
              v3   = ls_log_ext-message_v3
            IMPORTING
              msg  = lv_message.

          lv_text = lv_message.

          CLEAR ls_msg.
          ls_msg-msgty     = ls_log_ext-type.
          ls_msg-msgid     = ls_log_ext-id.
          ls_msg-msgno     = ls_log_ext-number.
          ls_msg-msgv1     = ls_log_ext-message_v1.
          ls_msg-msgv2     = ls_log_ext-message_v2.
          ls_msg-msgv3     = ls_log_ext-message_v3.
          ls_msg-probclass = '2'.

          MOVE-CORRESPONDING ls_log_ext TO ls_log_extu.
          ls_log_extu-comments   = lv_text.
          ls_msg-context-value   = ls_log_extu.
          ls_msg-context-tabname = 'ZONST_OC_LOG_EXTU'.

          CALL FUNCTION 'BAL_LOG_MSG_ADD' ##FM_SUBRC_OK
            EXPORTING
              i_log_handle = lv_log_handle
              i_s_msg      = ls_msg
            EXCEPTIONS
              OTHERS       = 1.

          INSERT lv_log_handle INTO TABLE lt_log_handle.

        ENDLOOP.

        CALL FUNCTION 'BAL_DB_SAVE'
          EXPORTING
            i_client       = sy-mandt
            i_save_all     = abap_true
            i_t_log_handle = lt_log_handle
          EXCEPTIONS
            OTHERS         = 1.

      WHEN 'F'.
        me->download_log_file( ). " F = File-based log

    ENDCASE.

    CLEAR gt_log_ext.

* Begin of insert DB Error handling
*    lv_timestamp = me->get_timestamp( ).
*    lv_env       = sy-sysid && sy-mandt.
*    gv_event_id  = gs_oc_obj-cdobjectcl && lv_timestamp.
*    SELECT SINGLE low INTO lv_errorj  FROM zonta_oc_param WHERE name = 'ERROR_JSON'.
*    IF sy-subrc = 0 AND lv_errorj = 'X'.
*      ls_errorl = VALUE zonst_log_otel(
*      event_id  = gv_event_id
*      timestamp = lv_timestamp
*      service   = gv_entity
*      type      = gs_elog-type
*      severity  = gs_elog-severity
*      message   = gs_elog-message
*      details   = gs_elog-details "VALUE zonst_log_otel_details( )
*      context   = VALUE zonst_log_otel_context( user_id = sy-uname )
*      metadata  = VALUE zonst_log_otel_metadata( environment = lv_env )
*     ).
*
*      send_log_otel( is_log_otel = ls_errorl ).
*    ENDIF.

  ENDMETHOD.


  METHOD update_table_json.
*    DATA: ls_fetch_r  TYPE zonta_oc_fetch_r,
*          ls_fetch_rp TYPE zonta_oc_fetchrp.
*
*    DATA lv_tst TYPE timest.
*
*    GET TIME STAMP FIELD lv_tst.
*
*    IF iv_uuid IS NOT INITIAL.
*      DATA(lv_status) = 'P'.
*
*      SELECT SINGLE *
*       INTO ls_fetch_r
*       FROM zonta_oc_fetch_r
*       WHERE uuid_rec = iv_uuid.
*
*      IF sy-subrc EQ 0.
*        ls_fetch_rp-uuid_rec  = ls_fetch_r-uuid_rec.
*        ls_fetch_rp-uuid_rpos = cl_system_uuid=>create_uuid_x16_static( ).
*        ls_fetch_rp-json      = iv_json.
*        ls_fetch_rp-message   = iv_message.
*        ls_fetch_rp-ret_code  = iv_ret_code.
*        ls_fetch_rp-zoffset   = iv_zoffset.
*        ls_fetch_rp-status    = iv_status_code.
*        ls_fetch_r-status_header = iv_status_code.
*        ls_fetch_r-time          = sy-uzeit.
*      ENDIF.
*
*      MODIFY zonta_oc_fetchrp FROM ls_fetch_rp.
*      MODIFY zonta_oc_fetch_r FROM ls_fetch_r.
*      COMMIT WORK AND WAIT.
*    ENDIF.
  ENDMETHOD.


  METHOD validate_data_where.

    CONSTANTS: lc_comilla TYPE c LENGTH 1 VALUE ''''.

    DATA:
      ls_relation           TYPE zonta_relations,
      lt_relations          TYPE STANDARD TABLE OF zonta_relations,
      lt_relations_to_order TYPE STANDARD TABLE OF zonta_relations,
      lt_relations_sort     TYPE STANDARD TABLE OF zonta_relations.

    DATA: lv_change       TYPE abap_bool,
          lv_tabix        TYPE i,
          lv_field_main   TYPE string,
          lv_field        TYPE string,
          lv_where        TYPE string,
          lv_where_parent TYPE string VALUE 'TABNAME = <FS_RELATIONS>-PARENT_RELATION',
          lv_where_key    TYPE string,
          lv_exist_value  TYPE abap_bool.

    FIELD-SYMBOLS: <fs_cond_tab>         TYPE LINE OF rsds_twhere,
                   <fs_relations>        TYPE zonta_relations,
                   <fs_relations_aux>    TYPE zonta_relations,
                   <fs_table>            TYPE ANY TABLE,
                   <fs_field>            TYPE any,
                   <fs_line>             TYPE any,
                   <fs_line_aux>         TYPE any,
                   <fs_line_exist>       TYPE any,
                   <fs_filters>          LIKE LINE OF gt_filters,
                   <fs_relations_parent> TYPE zonta_relations.

    lt_relations = gt_relations_aux.

    lv_where = 'TABNAME = <FS_RELATIONS>-TABNAME'.

*Get tables with where
    LOOP AT lt_relations ASSIGNING <fs_relations>.

      READ TABLE gt_cond_tab ASSIGNING <fs_cond_tab>
               WITH KEY tablename = <fs_relations>-tabname.
      IF sy-subrc EQ 0.
        APPEND <fs_relations> TO lt_relations_to_order.
      ENDIF.

      READ TABLE gt_filters ASSIGNING <fs_filters>
          WITH KEY tabname = <fs_relations>-tabname.
      IF sy-subrc EQ 0.
        APPEND <fs_relations> TO lt_relations_to_order.
      ENDIF.
    ENDLOOP.

    DELETE ADJACENT DUPLICATES FROM lt_relations_to_order COMPARING tabname.

    SORT lt_relations_to_order BY sequence DESCENDING.
    CLEAR: lv_exist_value, lv_tabix, lv_change.

*If not have where exit
*If the first table is parent and have where exit
    READ TABLE lt_relations_to_order ASSIGNING <fs_relations_aux>
             INDEX 1.

    IF sy-subrc EQ 0 AND <fs_relations_aux>-parent_relation = ' '.
      RETURN.
    ELSEIF sy-subrc NE 0."If not get where exit
      RETURN.
    ENDIF.

    ASSIGN ch_table->* TO <fs_table>.
    IF sy-subrc EQ 0.
      LOOP AT lt_relations_to_order ASSIGNING <fs_relations>.
        lv_exist_value = abap_false.

*Validate if exit the table in data if not clear all data
        LOOP AT <fs_table> ASSIGNING <fs_line> WHERE (lv_where).
          CLEAR lv_tabix.
          lv_exist_value = abap_true.
*Get table parent
          LOOP AT <fs_table> ASSIGNING <fs_line_aux> WHERE (lv_where_parent).
            lv_tabix = sy-tabix.
            lv_change = abap_true.

            CLEAR: lv_field, lv_field_main, lv_where_key.
            UNASSIGN <fs_field>.

            lv_field = <fs_relations>-field_sec && <fs_relations>-subsequence.
            lv_field_main = <fs_relations>-field_main && <fs_relations>-sequence.

            ASSIGN COMPONENT lv_field OF STRUCTURE <fs_line_aux> TO <fs_field>.
            IF <fs_field> IS ASSIGNED.
              IF <fs_field> IS NOT INITIAL.

                CONCATENATE lv_where
                             'AND'
                             lv_field_main
                             '='
                             <fs_field>
                             INTO lv_where_key
                             SEPARATED BY space.
*Validate from table with where to table parent
                LOOP AT <fs_table> ASSIGNING <fs_line_exist> WHERE (lv_where_key).
                  lv_change = abap_false.
                ENDLOOP.
              ELSE.
                lv_change = abap_false.
              ENDIF.
            ENDIF.
          ENDLOOP.
          IF lv_change = abap_true.
            IF <fs_line_aux>  IS ASSIGNED.
              DELETE TABLE <fs_table> FROM <fs_line_aux>.
            ENDIF.
          ENDIF.
        ENDLOOP.
*If not found data clear all data
        IF lv_exist_value = abap_false.
          CLEAR <fs_table>[].
          EXIT.
        ELSE.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD validate_ddic_active.
    DATA: lv_name     TYPE ddobjname,
          lv_gotstate TYPE ddgotstate.

    lv_name = iv_object.
    DO 10000 TIMES.
      CLEAR lv_gotstate.
*     Check from table
      CALL FUNCTION 'DDIF_TABL_GET'
        EXPORTING
          name          = lv_name
          state         = 'M'
        IMPORTING
          gotstate      = lv_gotstate
        EXCEPTIONS
          illegal_input = 1
          OTHERS        = 2.
* It means it is ot a table
      IF lv_gotstate IS INITIAL.
        CLEAR lv_gotstate.
* Check from table type
        CALL FUNCTION 'DDIF_TTYP_GET'
          EXPORTING
            name          = lv_name
            state         = 'M'
          IMPORTING
            gotstate      = lv_gotstate
          EXCEPTIONS
            illegal_input = 1
            OTHERS        = 2.
* It is a table type and it is active
        IF lv_gotstate = 'A'.
          cv_subrc = 0.
          EXIT.
        ENDIF.
* It is a table and it is active
      ELSEIF lv_gotstate = 'A'.
        cv_subrc = 0.
        EXIT.
      ENDIF.

**      IF sy-subrc <> 0.
**        cv_subrc = 1.
**        EXIT.
**      ENDIF.
**      IF lv_gotstate = 'A'.
**        cv_subrc = 0.
**        EXIT.
**      ENDIF.
    ENDDO.
  ENDMETHOD.


  METHOD validate_where_3_tables.

    DATA:
      ls_relation  TYPE zonta_relations,
      lt_relations TYPE STANDARD TABLE OF zonta_relations.

    FIELD-SYMBOLS: <fs_cond_tab>  TYPE LINE OF rsds_twhere,
                   <fs_relations> TYPE zonta_relations.
*Get tables with where
    LOOP AT gt_cond_tab ASSIGNING <fs_cond_tab>.

      READ TABLE gt_relations ASSIGNING <fs_relations>
               WITH KEY tabname = <fs_cond_tab>-tablename.
      IF sy-subrc EQ 0.
        IF <fs_relations>-sequence > 3.
          r_message = 'Note: Filters only apply to the first 3 tables in the sequence of the entity'.
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD zonif_oc_data_handler~copy_context_from.

    DATA: lo_source TYPE REF TO zoncl_oc_base_handler.


    IF io_source_type IS BOUND.
      lo_source ?= io_source_type.
      IF lo_source IS BOUND.
        me->gv_update      = lo_source->gv_update.
        me->gv_delete      = lo_source->gv_delete.
        me->gv_batch       = lo_source->gv_batch.
        me->gv_instid      = lo_source->gv_instid.
        me->gv_domainv     = lo_source->gv_domainv.
        me->gv_entity      = lo_source->gv_entity.
        me->gv_dest        = lo_source->gv_dest.
        me->gv_key_queue   = lo_source->gv_key_queue.
        me->gv_fieldname   = lo_source->gv_fieldname.
        me->gv_bothnames   = lo_source->gv_bothnames.
        me->gv_alias       = lo_source->gv_alias.
        me->gv_anytable    = lo_source->gv_anytable.
        me->gt_where       = lo_source->gt_where.
        me->gt_columns_all = lo_source->gt_columns_all.
        me->gt_relations   = lo_source->gt_relations.
        me->gt_dfies_tab_cat = lo_source->gt_dfies_tab_cat.
        me->gs_oc_obj      = lo_source->gs_oc_obj.
      ENDIF.
    ENDIF.




  ENDMETHOD.


  METHOD zonif_oc_data_handler~delete_data.
  ENDMETHOD.


  METHOD zonif_oc_data_handler~get_data.

    DATA: lo_table          TYPE REF TO data,
          lv_exit           TYPE abap_bool,
          lv_exit_set_where TYPE abap_bool,
          lv_message_v2     TYPE string.

    FIELD-SYMBOLS: <fs_table> TYPE ANY TABLE.

* Read variant
    IF gv_variant IS NOT INITIAL.
    ENDIF.

    " 1. Setup filtering
    IF gv_key_queue IS INITIAL AND gt_where_cond_tab IS INITIAL.
      me->set_where( IMPORTING ev_closed = lv_exit_set_where ).
      IF lv_exit_set_where EQ abap_true.
        RETURN.
      ENDIF.
      me->set_process( IMPORTING ev_closed = lv_exit ).
      IF lv_exit EQ abap_true.
        RETURN.
      ENDIF.

      gt_where_cond_tab = gt_cond_tab.
    ELSEIF gt_where_cond_tab IS NOT INITIAL.
*    ELSEIF gv_key_queue IS NOT INITIAL.
      gt_cond_tab = gt_where_cond_tab.
    ENDIF.

    IF gt_where_cond_tab IS INITIAL.
      MESSAGE i000(fb) WITH 'No filter selected'.
      RETURN.
    ENDIF.

    " 2. Determine data or batch mode
    IF gv_batch IS INITIAL.

      " 2a. Load database records (only if update/delete)
      IF gv_update = abap_true OR gv_delete = abap_true.
        lo_table = me->get_database_data( ).
        ASSIGN lo_table->* TO <fs_table>.
        IF <fs_table> IS INITIAL.
          IF gv_instid IS INITIAL.
            MESSAGE i000(fb) WITH 'No data found'.
          ENDIF.

          lv_message_v2 = gv_instid.

          me->append_slg1_log(
            iv_tabname    = space
            iv_message_v1 = 'No data found for'
            iv_message_v2 = lv_message_v2
            iv_mestyp     = 'S' ).

          me->update_slg1_log( it_log_ext = gt_log_ext ).
          RETURN.
        ENDIF.
      ENDIF.
      DATA v_tryoff TYPE c.
      SELECT SINGLE low INTO v_tryoff FROM zonta_oc_param WHERE name = 'SET_TRY_OFF'.
      IF v_tryoff IS NOT INITIAL.
        " 2b. Delegate logic to subclass
        IF mo_handler IS BOUND.
          mo_handler->get_data(
            IMPORTING
              ev_sizet    = gs_LOG_JSON_RESULT-sizet " gv_sizet
              ev_recordst = gs_LOG_JSON_RESULT-recordst " gv_recordst
          ).
        ENDIF.
      ELSE.
        TRY."FR
            " 2b. Delegate logic to subclass
            IF mo_handler IS BOUND.
              mo_handler->get_data(
                IMPORTING
                  ev_sizet    = gs_LOG_JSON_RESULT-sizet " gv_sizet
                  ev_recordst = gs_LOG_JSON_RESULT-recordst " gv_recordst
              ).
            ENDIF.
          CATCH cx_root INTO gx_text.
            DATA lo_prev type ref to cx_root.
            lo_prev = gx_text->previous.

            IF lo_prev IS BOUND.
              DATA lv_textp type string.
              lv_textp = lo_prev->get_longtext( ).
            ENDIF.

            gs_elog-type       = 'HANDLER-GET_DATA'.
            gs_elog-severity   = gc_error.
            IF lv_textp IS INITIAL.
              gs_elog-message    = gx_text->get_longtext( ).
            ELSE.
              gs_elog-message    = lv_textp.
            ENDIF.
            CALL METHOD gx_text->get_source_position
              IMPORTING
                program_name = gv_prog
                source_line  = gv_sline.
            gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
            gs_elog-details-db = 'ZONCL_OC_BASE_HANDLER-ZONIF_OC_DTA_HANDLER-GET_DATA'.
            gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

            gs_elog-metadata-error_code = gs_elog-details-error_code.
            interpret_message( EXPORTING iv_msgnr = '062' IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '063' iv_msgv1 = gv_entity IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '064' IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
            CONCATENATE gv_msg1 gv_msg2 gv_msg3 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
            interpret_message( EXPORTING iv_msgnr = '065' IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
            gs_elog-metadata-possible_fix = gv_msg1.
            print_error_otel( ).
            send_json_error( ).
*            print_error( ).
        ENDTRY.
      ENDIF.
    ELSE.
      " 2c. Execute batch logic
      me->execute_batch( ).
    ENDIF.

  ENDMETHOD.


  METHOD zonif_oc_data_handler~send_data.
  ENDMETHOD.


  METHOD zonif_oc_data_handler~set_context.


    IF gv_context_set = abap_true.
      RETURN. " Already initialized, skip
    ENDIF.

    gv_kdoc           = iv_kdoc.
    gv_table          = iv_table.
    gv_ddic           = iv_ddic.
    gv_dest           = iv_dest.
    gv_update         = iv_update.
    gv_delete         = iv_delete.
    gv_domainv        = iv_domainv.
    gv_entity         = iv_entity.
    gv_key_queue      = iv_key_queue.
    gv_batch          = iv_batch.
    gt_where          = it_where.
    gv_instid         = iv_instid.
    gv_anytable       = iv_anytable.
    gv_alias          = iv_alias.
    gv_fieldname      = iv_fieldname.
    gv_tagdata        = iv_tagdata.
    gv_tagmetadata    = iv_tagmetadata.
    gv_bothnames      = iv_bothnames.
    gt_endpoints      = it_endpoints.
    gt_where_cond_tab = it_where_cond_tab.

    gv_context_set = abap_true.

  ENDMETHOD.
ENDCLASS.
