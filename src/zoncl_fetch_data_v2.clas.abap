class ZONCL_FETCH_DATA_V2 definition
  public
  final
  create public .

public section.
  type-pools RSDS .
  type-pools SLIS .

  types:
    tty_where TYPE STANDARD TABLE OF rsdswhere .
  types:
    tty_line TYPE STANDARD TABLE OF line .
  types:
    tty_primary_key_names TYPE HASHED TABLE OF string WITH UNIQUE KEY table_line .
  types:
    BEGIN OF ty_delete,
        objname TYPE ddobjname,
        objtype TYPE ddeutype,
      END OF ty_delete .
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
*** Metadata
    BEGIN OF ty_metadatadet,
        fieldname TYPE string,
        offset    TYPE string,
        length    TYPE string,
        type      TYPE string,
        fieldtext TYPE string,
        keyflag   TYPE string,
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
* OneConnect Detail
    BEGIN OF ty_oneconnectdet,
        properties TYPE ty_properties,
        metadata   TYPE STANDARD TABLE OF ty_metadata_s WITH NON-UNIQUE DEFAULT KEY,
        body       TYPE ty_body,
      END OF ty_oneconnectdet .
  types:
* OneConnect Detail Metadata
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
    BEGIN OF ty_cdpos,
        tabname TYPE cdpos-tabname,
        tabkey  TYPE cdpos-tabkey,
      END OF ty_cdpos .
  types:
    tty_cdpos TYPE STANDARD TABLE OF ty_cdpos .
  types:
    tty_columns TYPE STANDARD TABLE OF zonta_oc_col_all .
  types:
    tty_endpoints TYPE STANDARD TABLE OF zonta_oc_endp .

  constants C_KDOC type STRING value 'KDOC' ##NO_TEXT.
  constants C_TABLE type STRING value 'TABL' ##NO_TEXT.
  data:
    gt_relations TYPE STANDARD TABLE OF zonta_relations .
  data:
    gt_log_ext  TYPE STANDARD TABLE OF zonst_oc_log_ext .
  data:
    gt_columns TYPE STANDARD TABLE OF zonta_oc_columns .
  data:
    gt_columns_all TYPE STANDARD TABLE OF zonta_oc_col_all .
  data:
    gt_filters TYPE STANDARD TABLE OF zonta_oc_filters .
  data:
    gt_dfies_tab_cat TYPE STANDARD TABLE OF dfies .
  data:
    gt_dfies_tab TYPE STANDARD TABLE OF dfies .
  data GV_JSON type STRING .
  data:
    gt_json TYPE STANDARD TABLE OF string .
  data:
    gt_json_map TYPE STANDARD TABLE OF dd03p .
  data GS_OC_OBJ type ZONTA_OBJ_OC .
  data GV_MESSAGETYPE type STRING .
  data GT_WHERE type ZONTTRSDSWHERE .                       "tab_rsdswhere .
  data:
    gt_delete TYPE STANDARD TABLE OF ty_delete .
  data GV_DEVCLASS type TADIR-DEVCLASS .
  data GV_KORRNUM type E070-TRKORR .
  data GT_OBJECTS type ZONTT_E071 .

  methods CONSTRUCTOR .
  methods SET_GLOBAL_VARIABLE
    importing
      !IV_DOMAINV type ZONDE_DOMAIN
      !IV_BUSINESS_PROC type ZONDE_PROCESS
      !IV_KDOC type BOOLEAN
      !IV_TABLE type BOOLEAN
      !IV_DDIC type BOOLEAN optional
      !IV_DEST type RFCDEST default 'ONIBEX_KDOCS'
      !IV_UPDATE type BOOLEAN default 'X'
      !IV_DELETE type BOOLEAN optional
      !IV_KEY_QUEUE type STRING optional
      !IV_BATCH type BOOLEAN optional
    exceptions
      NOT_DATA_FOUND .
  methods GET_RELATION
    importing
      !IV_DOMAINV type ZONDE_DOMAIN
      !IV_BUSINESS_PROC type ZONDE_PROCESS
      !IV_KDOC type BOOLEAN
      !IV_TABLE type BOOLEAN
      !IV_DDIC type BOOLEAN optional
      !IV_DEST type RFCDEST default 'ONIBEX_KDOCS'
      !IV_UPDATE type BOOLEAN default 'X'
      !IV_DELETE type BOOLEAN optional
      !IV_KEY_QUEUE type STRING optional
      !IV_BATCH type BOOLEAN optional
      !IT_WHERE type ZONTTRSDSWHERE optional
      !IV_INSTID type SIBFBORIID optional
      !IV_ANYTABLE type STRING optional
      !IV_ALIAS type BOOLEAN optional
      !IT_ENDPOINTS type TTY_ENDPOINTS optional
      !IT_WHERE_COND_TAB type RSDS_TWHERE optional
      !IV_FIELDNAME type BOOLEAN optional
      !IV_TAGDATA type BOOLEAN optional
      !IV_TAGMETADATA type BOOLEAN optional
      !IV_BOTHNAMES type BOOLEAN optional
    exporting
      !EV_SIZET type ZONDE_OC_NUM30
      !EV_RECORDST type ZONDE_OC_NUM30
    exceptions
      NOT_DATA_FOUND .
  methods DELETE_JSON_DDIC
    importing
      !IV_DOMAINV type ZONDE_DOMAIN
      !IV_BUSINESS_PROC type ZONDE_PROCESS .
  methods CREATE_JSON_DDIC
    importing
      !IV_DOMAINV type ZONDE_DOMAIN
      !IV_BUSINESS_PROC type ZONDE_PROCESS .
  methods SEND_OUTPUT_TYPE
    importing
      !I_OBJECT type NAST .
  methods SEND_EVENT_AUTOMATIC
    importing
      !IS_SENDER type SIBFLPORB
      !I_EVENT type SIBFEVENT .
  methods GET_DATA_TAB
    importing
      !IT_DATA type ANY .
  methods GET_DATA_KDOC
    importing
      !IT_DATA type ANY TABLE .
  methods SEND_JSON_ANY_TABLE_COND
    importing
      !IV_TABNAME type TABNAME
      !IV_UPDATE type BOOLEAN
      !IV_DELETE type BOOLEAN
      !IT_WHERE type RSDS_WHERE_TAB optional
      !IV_ALIAS type BOOLEAN default 'X' .
  methods SEND_JSON_ANY_TABLE_HCM
    importing
      !IV_TABNAME type TABNAME
      !IV_UPDATE type BOOLEAN
      !IV_DELETE type BOOLEAN
      !IT_WHERE type RSDS_WHERE_TAB optional
      !IV_ALIAS type BOOLEAN default 'X' .
  methods SEND_JSON_ANY_TABLE
    importing
      !IV_TABNAME type TABNAME
      !IV_UPDATE type BOOLEAN
      !IV_DELETE type BOOLEAN
      !IT_WHERE type ZONTTRSDSWHERE optional
      !IV_ALIAS type BOOLEAN default 'X'
      !IV_DEST type RFCDEST optional
      !IV_FIELDNAME type BOOLEAN optional
      !IV_BOTHNAMES type BOOLEAN optional
      !IV_ALIASTAB type TABNAME optional .
  methods SEND_JSON_CODE
    importing
      !IT_DATA type ANY TABLE
      !IV_TABNAME type TABNAME
      !IV_UPDATE type BOOLEAN
      !IT_FIELDCAT type SLIS_T_FIELDCAT_ALV
      !IV_ENTITY type ZONDE_PROCESS
      !IV_DEST type RFCDEST
      !IV_ENT_DATA type ZONTA_OBJ_OC .
  methods SEND_JSON_ANY
    importing
      !IT_DATA type ANY TABLE
      !IV_TABNAME type TABNAME
      !IV_UPDATE type BOOLEAN
      !IV_DELETE type BOOLEAN
      !IT_FIELDCAT type SLIS_T_FIELDCAT_ALV .
  methods GET_DATABASE_DATA
    returning
      value(RV_TABLE) type ref to DATA .
  methods SET_TRKORR
    importing
      !IV_TKORR type TRKORR .
  methods GET_OBJECTS
    exporting
      !ET_OBJECTS type ZONTT_E071
      !ET_DDIC type ZONTT_OC_DDIC .
  methods SET_PROCESS_LOG
    importing
      !I_TEXT1 type SYMSGV optional
      !I_TEXT2 type SYMSGV optional
      !I_TEXT3 type SYMSGV optional
      !I_TEXT4 type MSGV4 optional
      !I_PROCESS type BALNREXT optional .
protected section.
private section.

  data GV_KDOC type BOOLEAN .
  data GV_TABLE type BOOLEAN .
  data GV_DEST type RFCDEST .
  data GV_SIZET type ZONDE_OC_NUM30 .
  data GV_RECORDST type ZONDE_OC_NUM30 .
  data GV_DOMAINV type ZONDE_DOMAIN .
  data GV_ENTITY type ZONDE_PROCESS .
  data GV_KEY_QUEUE type STRING .
  data GV_BATCH type BOOLEAN .
  data GV_UPDATE type BOOLEAN .
  data GV_DELETE type BOOLEAN .
  data GV_INSTID type SIBFBORIID .
  data GV_ANYTABLE type STRING .
  data GV_RECORDST_OBJ type ZONDE_OC_NUM30 .
  data GT_CDPOS type TTY_CDPOS .
  data GV_ALIAS type BOOLEAN .
  data GV_EVENT_ID type STRING .
  data GS_ENDPOINTS type ZONTA_OC_ENDP .
  data GT_COND_TAB type RSDS_TWHERE .
  data GT_WHERE_COND_TAB type RSDS_TWHERE .
  data GV_FIELDNAME type BOOLEAN .
  data GV_BOTHNAMES type BOOLEAN .
  data GO_TDESCR type ref to CL_ABAP_TABLEDESCR .
  data GV_SENDING type STRING .
  data C_ALIAS type STRING value 'ALIAS' ##NO_TEXT.
  data C_BOTH type STRING value 'BOTH' ##NO_TEXT.
  data GV_EVENTID_ACTIVE type BOOLEAN .
  data GV_ERROR type BOOLEAN .
  data GV_ERROR_NO_DATA type BOOLEAN .
  data GV_CHANGE type BOOLEAN .
  data GT_DDIC type ZONTT_OC_DDIC .

  methods PROCESS_DATA .
  methods SET_JOIN
    returning
      value(R_JOIN) type STRING .
  methods SET_FIELDS_NEW
    importing
      !IV_ALIAS type BOOLEAN default 'X'
      !IV_TABNAME type TABNAME optional
    returning
      value(R_FIELDS) type STRING .
  methods SET_FIELDS
    importing
      !IV_ALIAS type BOOLEAN default 'X'
    returning
      value(R_FIELDS) type STRING .
  methods SET_TABLE_ANY_COND
    importing
      !IT_FCAT type SLIS_T_FIELDCAT_ALV
      !IV_ANYTABLE type BOOLEAN optional
      !IV_ALIAS type BOOLEAN default 'X'
    returning
      value(RT_TABLE) type ref to DATA .
  methods SET_TABLE_ANY
    importing
      !IT_FCAT type SLIS_T_FIELDCAT_ALV
      !IV_ANYTABLE type BOOLEAN optional
      !IV_ALIAS type BOOLEAN default 'X'
    returning
      value(RT_TABLE) type ref to DATA .
  methods SET_TABLE
    importing
      !IV_ADD_TABNAME type BOOLEAN optional
    returning
      value(RT_TABLE) type ref to DATA .
  methods SET_WHERE_ANY
    returning
      value(R_WHERE) type RSDS_WHERE_TAB .
  methods SET_WHERE_NEW
    importing
      !IV_ANY type BOOLEAN optional .
  methods GET_WHERE
    importing
      !IV_ANY type BOOLEAN optional
      !IV_TABNAME type TABNAME optional
    returning
      value(R_WHERE) type ZONTTRSDSWHERE .
  methods SET_WHERE
    importing
      !IV_ANY type BOOLEAN optional
    returning
      value(R_WHERE) type ZONTTRSDSWHERE .
  methods DELETE_DATA_TABLE
    importing
      !IT_DATA type ANY .
  methods GET_DATA_TABLE
    importing
      !IT_DATA type ANY .
  methods GET_DATA_PROPERTIES_ANY
    changing
      value(CS_PROPERTIES) type ANY optional .
  methods GET_DATA_PROPERTIES
    changing
      value(CS_PROPERTIES) type ANY optional .
  methods SET_FIELDS_IN_TABLE
    importing
      !IV_ALIAS type BOOLEAN default 'X'
      !IV_TABNAME type TABNAME optional
    exporting
      value(ET_FIELDS) type TTY_LINE .
  methods DELETE_DATA_BODY
    importing
      !IV_PARENT_RELATION type ZONDE_PARENTREL
      !IT_DATA type ANY
      !IS_LINE type ANY optional
    changing
      !CS_LINE_JSON type ANY optional
      value(CS_BODY) type ANY optional
      value(CS_ROOT) type ANY optional .
  methods GET_DATA_BODY
    importing
      !IV_PARENT_RELATION type ZONDE_PARENTREL
      !IT_DATA type ANY
      !IS_LINE type ANY optional
    changing
      !CS_LINE_JSON type ANY optional
      value(CS_BODY) type ANY optional
      value(CS_ROOT) type ANY optional .
  methods GET_DATA_BY_TABLE_DATA
    importing
      !IV_TABLE type TABNAME
      !IV_PARENT_RELATION type ZONDE_PARENTREL optional
    exporting
      !ET_FCAT type LVC_T_FCAT
      !ET_DATA type ref to DATA .
  methods GET_DATA_BY_TABLE
    importing
      !IV_TABLE type TABNAME
      !IV_PARENT_RELATION type ZONDE_PARENTREL optional
    exporting
      !ET_FCAT type LVC_T_FCAT
      !ET_DATA type ref to DATA .
  methods GET_KEY
    importing
      !IV_PARENT_RELATION type ZONDE_PARENTREL
      !IV_TABNAME type TABNAME
    exporting
      !ET_KEYS type TTY_WHERE
      !EV_KEY type STRING
      !EV_KEY_MAIN type STRING .
  methods SET_METADATA_NODE
    importing
      !IT_FCAT type LVC_T_FCAT
      !IV_TABNAME type TABNAME optional
    changing
      !CS_METADATA type ANY .
  methods GET_DATA_METADATA
    changing
      !CS_METADATA type ANY .
  methods SET_METADATA_TABLE_NODE
    importing
      !IV_TABNAME type TABNAME
    changing
      !CS_METADATA type ANY .
  methods CREATE_JSON_DDIC_BODY
    importing
      !IS_RELATIONS type ZONTA_RELATIONS
      !IV_DEF_TAB type BOOLEAN optional
      !IV_DATA_NODE type STRING default 'DATA'
      !IV_MAIN type BOOLEAN optional
      !IS_COLUMNS type ZONTA_OC_COL_ALL optional
    exporting
      !EV_TYPE type STRING .
  methods CREATE_JSON_DDIC_STRUCTURE
    importing
      !IS_RELATIONS type ZONTA_RELATIONS
      !IV_DEF_TAB type BOOLEAN optional
      !IV_DATA_NODE type STRING default 'DATA'
      !IV_EVENT type ZONDE_EVENTIDACTN optional
      !IV_MAIN type BOOLEAN optional
      !IV_TAGMETADATA type BOOLEAN optional
      !IV_HEADER type BOOLEAN optional
    exporting
      !EV_TYPE type STRING .
  methods CREATE_JSON_DDIC_ADD
    importing
      !IS_RELATIONS type ZONTA_RELATIONS .
  methods CREATE_JSON_DDIC_TYPE_TABLE
    importing
      !IS_RELATIONS type ZONTA_RELATIONS
      !IV_MAIN type BOOLEAN optional
      !IV_HEADER type BOOLEAN optional
    exporting
      !EV_TYPE type STRING .
  methods SET_FIELDS_STRUCTURE
    importing
      !IV_TYPE_NAME type STRING optional
      !IV_TYPE type STRING optional
      !IV_TYPE_FIELD type STRING optional
      !IV_TYPE_TABLE type STRING optional .
  methods CREATE_JSON_DDIC_MAIN .
  methods CREATE_JSON_DDIC_KDOC .
  methods CREATE_JSON_DDIC_TABL .
  methods SEND_JSON_HTTP_CON
    importing
      !I_DEST type RFCDEST
    exporting
      !E_RETURN type STRING
      !E_SIZE type ZONDE_OC_NUM30
      !E_RECORDS type ZONDE_OC_NUM30
      value(E_RESPONSE) type STRING .
  methods SEND_JSON_RESULT .
  methods DOWNLOAD_LOG_FILE .
  methods UPDATE_SLG1_LOG
    importing
      !IT_LOG_EXT type ZONTT_OC_LOG_EXT optional .
  methods APPEND_SLG1_LOG
    importing
      !IV_TABNAME type TABNAME
      !IV_KEY type ANY optional
      !IV_MESSAGE_V1 type SYMSGV default 'Object'
      !IV_MESSAGE_V2 type SYMSGV optional
      !IV_MESSAGE_V3 type SYMSGV default 'Transmitted'
      !IV_MESTYP type BAPI_MTYPE optional .
  methods VALIDATE_DDIC_ACTIVE
    importing
      !IV_OBJECT type TADIR-OBJ_NAME .
  methods GET_GLOBAL_DATA .
  methods GET_TIMESTAMP
    returning
      value(RV_TIMESTAMP) type STRING .
  methods GET_EVENTID
    importing
      !IT_KEYS type TTY_WHERE
    changing
      !CS_LINE_JSON type ANY .
  methods PRETTY_JSON_ANY
    importing
      !IV_MODE type STRING
    changing
      !CV_JSON type STRING .
  methods PRETTY_JSON
    importing
      !IV_MODE type STRING
    changing
      !CV_JSON type STRING .
  methods EXECUTE_BATCH
    importing
      !IV_ANYTAB type BOOLEAN optional
      !IV_TABNAME type TABNAME optional .
  methods SET_PROCESS .
  methods DELETE_JSON_DDIC_OBJECT
    importing
      !IV_OBJNAME type DDOBJNAME
      !IV_OBJTYPE type DDEUTYPE
    exporting
      !EV_SUBRC type SY-SUBRC .
  methods SET_CORR_INSERT
    importing
      !IV_MODE type STRING
      !IV_OBJECT type STRING .
  methods SET_KEY_ANY
    importing
      !IT_FCAT type SLIS_T_FIELDCAT_ALV
      !IS_LINE type ANY
      !IV_ALIAS type BOOLEAN default 'X'
    returning
      value(RV_KEY) type STRING .
  methods SET_METADATA_NODE_ANY
    importing
      !IT_FCAT type SLIS_T_FIELDCAT_ALV
      !IV_ALIAS type BOOLEAN default 'X'
    changing
      !CT_METADATA type ANY .
  methods GET_LENGHT_KEY
    importing
      !IV_TABNAME type DDOBJNAME
      !IV_PARENT type ZONDE_PARENTREL optional
    returning
      value(RV_LENGHT) type NUMC2 .
  methods ASSIGN_COMPONENT_TABLE
    importing
      !IS_SOURCE type ANY
      !IS_RELATIONS type ZONTA_RELATIONS
      !IV_ALIAS type BOOLEAN
      !IT_COLUMNS type TTY_COLUMNS
    changing
      !CS_TARGET type ANY .
  methods ALIAS_BOTH_JSON
    importing
      !IV_OPTION type STRING
    changing
      !CV_JSON type STRING .
  methods ALIAS_JSON
    changing
      !CV_JSON type STRING .
  methods FIELDNAME_JSON
    changing
      !CV_JSON type STRING .
  methods CONVERTION_EXIT
    importing
      !IV_TABNAME type TABNAME
    changing
      !CS_STRING type ANY .
  methods BOTHNAMES_JSON
    changing
      !CV_JSON type STRING .
  methods ADD_POSITION_TABLE
    importing
      !IV_TABNAME type STRING .
  methods REPLACE_DATA_METADATA
    importing
      !IV_TABNAME type ZONTA_OC_COL_ALL-TABNAME
      !IV_ALIAS_TABNAME type ZONTA_OC_COL_ALL-ALIAS_TABNAME
      !IV_TECHNICAL type ZONTA_OC_COL_ALL-FLDNAME
      !IV_ALIAS_FLDNAME type ZONTA_OC_COL_ALL-ALIAS_FLDNAME
      !IV_OPTION type STRING
    changing
      !CV_JSON type STRING .
  methods IS_CDS_ENTITY
    importing
      !IV_TABNAME type DD03L-TABNAME
    returning
      value(R_IS_CDS_ENTITY) type ABAP_BOOL .
  methods GET_DDICOBJECT_FROM_CDS
    importing
      !IV_TABNAME type DD03L-TABNAME
    returning
      value(RV_DDIC_OBJECT) type tabname.
  methods ADD_OBJECT_ENTRY
    importing
      !IV_PGMID type PGMID
      !IV_OBJECT type TROBJTYPE
      !IV_OBJECT_NAME type TADIR-OBJ_NAME .
  methods GET_FIELDSKEY_CDS
    importing
      !IV_TABNAME type DD03L-TABNAME
    exporting
      !EXT_KEYS_FIELDS type TTY_PRIMARY_KEY_NAMES .
ENDCLASS.



CLASS ZONCL_FETCH_DATA_V2 IMPLEMENTATION.


  METHOD add_object_entry.
    DATA: ls_e071 TYPE e071,
          ls_ddic TYPE zonta_oc_ddic.

    ls_e071-pgmid    = iv_pgmid.
    ls_e071-object   = iv_object.
    ls_e071-obj_name = iv_object_name.
    APPEND ls_e071 TO gt_objects.


    ls_ddic-mandt         = sy-mandt.
    ls_ddic-business_proc = gv_entity.
    ls_ddic-domainv       = gv_domainv.
    ls_ddic-id            = gs_oc_obj-id.
    ls_ddic-object        = iv_object_name.
    ls_ddic-object_type   = iv_object.
    APPEND ls_ddic TO gt_ddic.

  ENDMETHOD.


  METHOD add_position_table.

    DATA: lt_dd03l TYPE STANDARD TABLE OF dd03l,
          ls_dd03l TYPE dd03l.

    FIELD-SYMBOLS:
                   <fs_columns>   TYPE zonta_oc_col_all.

    SELECT   *
        FROM dd03l
        INTO TABLE lt_dd03l
       WHERE tabname = iv_tabname.
    IF sy-subrc NE 0.
      CLEAR lt_dd03l[].
    ELSE.
      SORT lt_dd03l BY tabname fieldname.
      LOOP AT gt_columns_all ASSIGNING <fs_columns>
                   WHERE tabname EQ iv_tabname.

        READ TABLE lt_dd03l INTO ls_dd03l
             WITH KEY tabname = iv_tabname
                      fieldname = <fs_columns>-fldname
                      BINARY SEARCH.

        IF sy-subrc EQ 0.
          <fs_columns>-positionf = ls_dd03l-position.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD alias_both_json.


    TYPES: BEGIN OF ty_match,
             table_pos  TYPE i,
             table_name TYPE string,
             json       TYPE string,
           END OF ty_match.

    DATA: lt_tables     TYPE STANDARD TABLE OF ty_match WITH EMPTY KEY,
          lt_tables_tmp TYPE STANDARD TABLE OF ty_match WITH EMPTY KEY,
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


    FIELD-SYMBOLS: <fs_columns> TYPE zonta_oc_col_all,
                   <fs_table>   TYPE ty_match.

    lv_json = cv_json.
    CLEAR lt_tables[].

    sort gt_columns_all by tabname alias_tabname fldname alias_fldname.
    WHILE lv_cursor < strlen( lv_json ).
      lv_subjson = lv_json+lv_cursor.

      CLEAR lt_match.
      FIND REGEX '"table":"([^"]+)"' IN lv_subjson RESULTS lt_match.

      IF sy-subrc = 0 AND lines( lt_match ) > 0.
        READ TABLE lt_match INDEX 1 INTO ls_match_line.
        IF sy-subrc = 0 AND lines( ls_match_line-submatches ) > 0.

          lv_offset = ls_match_line-submatches[ 1 ]-offset.
          lv_length = ls_match_line-submatches[ 1 ]-length.

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

        READ TABLE gt_columns_all ASSIGNING <fs_columns> WITH KEY alias_tabname = <fs_table>-table_name.
        IF sy-subrc = 0.
          lv_alias = <fs_columns>-alias_tabname.
          lv_name  = <fs_columns>-tabname.
        ELSE.
          READ TABLE gt_columns_all ASSIGNING <fs_columns> WITH KEY tabname = <fs_table>-table_name.
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
*  METHOD alias_both_json.
*
*
*    TYPES: BEGIN OF ty_match,
*             table_pos  TYPE i,
*             table_name TYPE string,
*             json       TYPE string,
*           END OF ty_match.
*
*    DATA: lt_tables     TYPE STANDARD TABLE OF ty_match WITH EMPTY KEY,
*          lt_tables_tmp TYPE STANDARD TABLE OF ty_match WITH EMPTY KEY,
*          ls_tables     LIKE LINE OF lt_tables,
*          ls_next       LIKE LINE OF lt_tables.
*
*    DATA: lv_table_name TYPE string,
*          lv_offset     TYPE i,
*          lv_tabix      TYPE sy-tabix,
*          lv_json       TYPE string.
*
*    DATA: lv_source TYPE string,
*          lv_target TYPE string.
*
*    DATA: lv_search_pos TYPE i VALUE 0.
*    DATA: lv_fieldname TYPE string,
*          lv_alias     TYPE zonta_oc_col_all-alias_tabname,
*          lv_name      TYPE zonta_oc_col_all-tabname.
*
*    DATA: lv_index         TYPE sy-tabix,
*          lv_last_position TYPE i,
*          lv_range_slice   TYPE string,
*          lv_cursor        TYPE i VALUE 0,
*          lv_subjson       TYPE string,
*          lv_difference    TYPE i.
*
*    DATA: lv_match TYPE string,
*          ls_match TYPE ty_match.
*
*    DATA: lt_match      TYPE match_result_tab,
*          ls_match_line TYPE match_result,
*          lv_length     TYPE i.
*
*
*    FIELD-SYMBOLS: <fs_columns> TYPE zonta_oc_col_all,
*                   <fs_table>   TYPE ty_match.
*
*    lv_json = cv_json.
*    CLEAR lt_tables[].
*
*    WHILE lv_cursor < strlen( lv_json ).
*      lv_subjson = lv_json+lv_cursor.
*
*      CLEAR lt_match.
*      FIND REGEX '"table":"([^"]+)"' IN lv_subjson RESULTS lt_match.
*
*      IF sy-subrc = 0 AND lines( lt_match ) > 0.
*        READ TABLE lt_match INDEX 1 INTO ls_match_line.
*        IF sy-subrc = 0 AND lines( ls_match_line-submatches ) > 0.
*
*          lv_offset = ls_match_line-submatches[ 1 ]-offset.
*          lv_length = ls_match_line-submatches[ 1 ]-length.
*
*          lv_table_name = lv_subjson+lv_offset(lv_length).
*
*          ls_match-table_name = lv_table_name.
*          ls_match-table_pos  = lv_cursor + ls_match_line-offset.
*          APPEND ls_match TO lt_tables.
*
*          " Move cursor forward to continue parsing
*          lv_cursor = lv_cursor + ls_match_line-offset + 1.
*        ELSE.
*          EXIT.
*        ENDIF.
*      ELSE.
*        EXIT.
*      ENDIF.
*    ENDWHILE.
*
** TABLE
*    IF gv_sending = c_table.
*
*      SORT lt_tables BY table_name.
*      DELETE ADJACENT DUPLICATES FROM lt_tables COMPARING table_name.
*      LOOP AT lt_tables INTO ls_tables.
*        READ TABLE gt_columns_all ASSIGNING <fs_columns> WITH KEY alias_tabname = ls_tables-table_name.
*        IF sy-subrc = 0.
*          lv_alias = <fs_columns>-alias_tabname.
*          lv_name  = <fs_columns>-tabname.
*        ELSE.
*          READ TABLE gt_columns_all ASSIGNING <fs_columns> WITH KEY tabname = ls_tables-table_name.
*          IF sy-subrc = 0.
*            CLEAR lv_alias.
*            lv_name = <fs_columns>-tabname.
*          ENDIF.
*        ENDIF.
*
*        LOOP AT gt_columns_all ASSIGNING <fs_columns> WHERE tabname = lv_name
*                                                        AND alias_tabname = lv_alias. "ls_tables-table_name.
*
*
*          CLEAR: lv_source, lv_target.
** Translate metadata
*          TRANSLATE <fs_columns>-fldname TO LOWER CASE.
*          TRANSLATE <fs_columns>-alias_fldname TO LOWER CASE.
*
*          lv_source = '"fieldname":"'   && <fs_columns>-fldname && '"'.
*          IF iv_option = c_alias.
*            lv_target = '"fieldname":"' && <fs_columns>-alias_fldname && '"'.
*          ELSE.
*            lv_target = '"fieldname":"' && <fs_columns>-fldname && '_' && <fs_columns>-alias_fldname  && '"'.
*          ENDIF.
*
*          REPLACE ALL OCCURRENCES OF '\'   IN lv_target WITH '_'.
*          REPLACE ALL OCCURRENCES OF '/'   IN lv_target WITH '_'.
*
*          REPLACE ALL OCCURRENCES OF lv_source IN cv_json WITH lv_target.
*
** Translate data
*          CLEAR: lv_source, lv_target.
*          TRANSLATE <fs_columns>-fldname TO LOWER CASE.
*          TRANSLATE <fs_columns>-alias_fldname TO LOWER CASE.
*
*          lv_source = '"' && <fs_columns>-fldname && '":'.
*          IF iv_option = c_alias.
*            lv_target = '"' && <fs_columns>-alias_fldname       && '":'.
*          ELSE.
*            lv_target = '"' && <fs_columns>-fldname && '_' && <fs_columns>-alias_fldname  && '":'.
*          ENDIF.
*
*          REPLACE ALL OCCURRENCES OF '\'   IN lv_target WITH '_'.
*          REPLACE ALL OCCURRENCES OF '/'   IN lv_target WITH '_'.
*
*          REPLACE ALL OCCURRENCES OF lv_source IN cv_json WITH lv_target.
*
*        ENDLOOP.
*      ENDLOOP.
*
*
*    ELSEIF gv_sending = c_kdoc.
*
** KDOC
*      SORT lt_tables BY table_pos.
*      lv_search_pos = 0.
*      lv_index = 1.
*
*      LOOP AT lt_tables ASSIGNING <fs_table>.
*        lv_tabix = sy-tabix + 1.
*        lv_difference = <fs_table>-table_pos - lv_search_pos.
*        <fs_table>-json = cv_json+lv_search_pos(lv_difference).
*        lv_search_pos = <fs_table>-table_pos.
*
**        IF lv_tabix > 1.
**          IF lv_index = 2.
**            lv_index = lv_index - 1.
**          ENDIF.
**          READ TABLE lt_tables_tmp INTO ls_tables INDEX lv_index.
**          IF sy-subrc = 0.
**            <fs_table>-table_name = ls_tables-table_name.
**          ENDIF.
**        ENDIF.
**        lv_index = lv_index + 1.
*      ENDLOOP.
*
*
*
*      APPEND INITIAL LINE TO lt_tables ASSIGNING <fs_table>.
*      lv_difference = strlen( cv_json ) -  lv_search_pos.
*      <fs_table>-table_pos = strlen( cv_json ).
*      <fs_table>-json = cv_json+lv_search_pos(lv_difference).
*
*      lt_tables_tmp[] = lt_tables[].
*      LOOP AT lt_tables ASSIGNING <fs_table> FROM 2.
*        lv_index = sy-tabix - 1.
*        READ TABLE lt_tables_tmp INTO ls_next INDEX lv_index.
*        IF sy-subrc = 0.
*          <fs_table>-table_name = ls_next-table_name.
*        ENDIF.
*      ENDLOOP.
*
*      DATA: lv_tabname TYPE zonde_aliastab.
*      CLEAR lv_tabname.
*      LOOP AT lt_tables ASSIGNING <fs_table>.
*        lv_index = sy-tabix.
*
*        READ TABLE gt_columns_all ASSIGNING <fs_columns> WITH KEY alias_tabname = <fs_table>-table_name.
*        IF sy-subrc = 0.
*          lv_alias = <fs_columns>-alias_tabname.
*          lv_name  = <fs_columns>-tabname.
*        ELSE.
*          READ TABLE gt_columns_all ASSIGNING <fs_columns> WITH KEY tabname = <fs_table>-table_name.
*          IF sy-subrc = 0.
*            CLEAR lv_alias.
*            lv_name = <fs_columns>-tabname.
*          ENDIF.
*        ENDIF.
*
*        LOOP AT gt_columns_all ASSIGNING <fs_columns> WHERE tabname = lv_name
*                                                        AND alias_tabname = lv_alias. "ls_tables-table_name.
*
*
*          CLEAR: lv_source, lv_target.
** Translate metadata
*          TRANSLATE <fs_columns>-fldname TO LOWER CASE.
*          TRANSLATE <fs_columns>-alias_fldname TO LOWER CASE.
*
*          lv_source = '"fieldname":"'   && <fs_columns>-fldname && '"'.
*          IF iv_option = c_alias.
*            lv_target = '"fieldname":"' && <fs_columns>-alias_fldname && '"'.
*          ELSE.
*            lv_target = '"fieldname":"' && <fs_columns>-fldname && '_' && <fs_columns>-alias_fldname  && '"'.
*          ENDIF.
*
*          REPLACE ALL OCCURRENCES OF '\'   IN lv_target WITH '_'.
*          REPLACE ALL OCCURRENCES OF '/'   IN lv_target WITH '_'.
*
*          REPLACE ALL OCCURRENCES OF lv_source IN cv_json WITH lv_target.
*
** Translate data
*          CLEAR: lv_source, lv_target.
*          TRANSLATE <fs_columns>-fldname TO LOWER CASE.
*          TRANSLATE <fs_columns>-alias_fldname TO LOWER CASE.
*
*          lv_source = '"' && <fs_columns>-fldname && '":'.
*          IF iv_option = c_alias.
*            lv_target = '"' && <fs_columns>-alias_fldname       && '":'.
*          ELSE.
*            lv_target = '"' && <fs_columns>-fldname && '_' && <fs_columns>-alias_fldname  && '":'.
*          ENDIF.
*
*          REPLACE ALL OCCURRENCES OF '\'   IN lv_target WITH '_'.
*          REPLACE ALL OCCURRENCES OF '/'   IN lv_target WITH '_'.
*
*          REPLACE ALL OCCURRENCES OF lv_source IN <fs_table>-json WITH lv_target.
*
*        ENDLOOP.
*        IF lv_index = 1.
*          lv_json = <fs_table>-json.
*        ELSE.
*          lv_json = lv_json && <fs_table>-json.
*        ENDIF.
*        lv_tabname = <fs_table>-table_name.
*      ENDLOOP.
*      cv_json = lv_json.
*    ENDIF.
*
*
*  ENDMETHOD.


  METHOD alias_json.


    TYPES: BEGIN OF ty_match,
             table_pos  TYPE i,
             table_name TYPE string,
             json       TYPE string,
           END OF ty_match.

    DATA: lt_tables TYPE STANDARD TABLE OF ty_match WITH EMPTY KEY,
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
   clear lt_tables[].

    WHILE lv_cursor < strlen( lv_json ).
      lv_subjson = lv_json+lv_cursor.

      CLEAR lt_match.
      FIND REGEX '"table":"([^"]+)"' IN lv_subjson RESULTS lt_match.

      IF sy-subrc = 0 AND lines( lt_match ) > 0.
        READ TABLE lt_match INDEX 1 INTO ls_match_line.
        IF sy-subrc = 0 AND lines( ls_match_line-submatches ) > 0.

          lv_offset = ls_match_line-submatches[ 1 ]-offset.
          lv_length = ls_match_line-submatches[ 1 ]-length.

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
    FIELD-SYMBOLS: <fs_lox_ext> TYPE zonst_oc_log_ext.
    TRY. "CECHAVARRIA 11/06/2025
        APPEND INITIAL LINE TO gt_log_ext ASSIGNING <fs_lox_ext>.
        <fs_lox_ext>-process    = gv_entity. "gv_domainv.
        <fs_lox_ext>-cdobjcl    = gs_oc_obj-cdobjectcl.
        <fs_lox_ext>-mestyp     = gs_oc_obj-kschl.
        <fs_lox_ext>-tabname    = iv_tabname.
*CECHAVARRIA 11/06/2025
        TRY.
            IF  iv_key IS NOT INITIAL.
              <fs_lox_ext>-key        = iv_key.
            ENDIF.
          CATCH cx_root.
        ENDTRY.
*CECHAVARRIA 11/06/2025
        <fs_lox_ext>-type       = iv_mestyp.
        <fs_lox_ext>-id         = 'FB'.
        <fs_lox_ext>-number     = '000'.
        <fs_lox_ext>-message_v1 = iv_message_v1. "'Object'.
        IF iv_key IS INITIAL..
          <fs_lox_ext>-message_v2 = iv_message_v2. "iv_key.
        ELSE.
          <fs_lox_ext>-message_v2 = iv_key.
        ENDIF.
        <fs_lox_ext>-message_v3 = iv_message_v3. "'transmitted'.
        CONCATENATE <fs_lox_ext>-message_v1
                    <fs_lox_ext>-message_v2
                    <fs_lox_ext>-message_v3
        INTO <fs_lox_ext>-message
        SEPARATED BY space.
        <fs_lox_ext>-endpoint = gv_dest.
*CECHAVARRIA 11/06/2025
      CATCH cx_root.
    ENDTRY.
*CECHAVARRIA 11/06/2025
  ENDMETHOD.


  METHOD assign_component_table.
    DATA: lv_source TYPE string,
          lv_target TYPE string.

    FIELD-SYMBOLS: <fs_columns> TYPE zonta_oc_col_all,
                   <fs_source>  TYPE any,
                   <fs_target>  TYPE any.
*DO. ENDDO.
    LOOP AT it_columns ASSIGNING <fs_columns>.
      IF NOT iv_alias IS INITIAL.
        IF NOT <fs_columns>-alias_fldname IS INITIAL.
          lv_source  = <fs_columns>-alias_fldname.
        ELSE.
          lv_source  = <fs_columns>-fldname.
        ENDIF.
      ELSE.
        lv_source  = <fs_columns>-fldname.
      ENDIF.

      lv_target = lv_source.

      lv_source = lv_source && is_relations-sequence.

      TRANSLATE lv_source TO UPPER CASE.

      TRANSLATE lv_target TO UPPER CASE.

      ASSIGN COMPONENT lv_source OF STRUCTURE is_source TO <fs_source>.
      IF NOT <fs_source> IS ASSIGNED.           "CDS_NAMES_FIX  Add function to validate 30 char
        lv_source = lv_source+0(30).
        ASSIGN COMPONENT lv_source OF STRUCTURE is_source TO <fs_source>.
      ENDIF.

      ASSIGN COMPONENT lv_target OF STRUCTURE cs_target TO <fs_target>.

      <fs_target> = <fs_source>.
      UNASSIGN <fs_source>.

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


  METHOD constructor.
    CLEAR: gt_relations,
           gt_columns,
           gt_columns_all,
           gt_dfies_tab_cat,
           gt_json_map,
           gt_log_ext .

    REFRESH: gt_relations,
             gt_columns,
             gt_columns_all,
             gt_dfies_tab_cat,
             gt_json_map,
             gt_log_ext .

    CLEAR: gv_json,
           gv_messagetype,
           gv_kdoc,
           gv_table,
           gv_dest,
           gv_sizet,
           gv_recordst,
           gv_key_queue,
           gv_devclass ,
           gv_korrnum ,
           gv_anytable,
           gt_objects.
  ENDMETHOD.


  METHOD convertion_exit.
    DATA: lt_dfies_tab TYPE STANDARD TABLE OF dfies,
          ls_columns   TYPE zonta_oc_col_all,
          lv_function  TYPE rs38l_fnam.

    FIELD-SYMBOLS: <fs_field> TYPE any,
                   <fs_value> TYPE any,
                   <fs_dfies> TYPE dfies.

    lt_dfies_tab = gt_dfies_tab.

    DELETE lt_dfies_tab WHERE tabname NE iv_tabname.

    DELETE lt_dfies_tab WHERE convexit IS INITIAL.

    LOOP AT lt_dfies_tab ASSIGNING <fs_dfies>.
      READ TABLE gt_columns_all WITH KEY tabname = iv_tabname
                                     fldname = <fs_dfies>-fieldname
                                     INTO ls_columns.
      IF sy-subrc EQ 0.
        IF gv_fieldname IS INITIAL.
          IF NOT ls_columns-alias_fldname IS INITIAL.
            ASSIGN ls_columns-alias_fldname TO <fs_field> .
          ELSE.
            ASSIGN ls_columns-fldname TO <fs_field> .
          ENDIF.
        ELSE.
          ASSIGN ls_columns-fldname TO <fs_field> .
        ENDIF.
      ELSE.
        ASSIGN <fs_dfies>-fieldname TO <fs_field> .
      ENDIF.

      TRANSLATE <fs_field> TO UPPER CASE.

      ASSIGN COMPONENT  <fs_field>  OF STRUCTURE cs_string TO <fs_value>.

      IF <fs_value> IS ASSIGNED.
        lv_function = 'CONVERSION_EXIT_'  &&
                      <fs_dfies>-convexit &&
                      '_OUTPUT'.

        CALL FUNCTION lv_function
          EXPORTING
            input  = <fs_value>
          IMPORTING
            output = <fs_value>.

        UNASSIGN <fs_value>.

      ENDIF.

    ENDLOOP.
  ENDMETHOD.


  METHOD create_json_ddic.
    DATA: lv_type_name TYPE string.

*** Create Body Structure
    me->get_relation( iv_domainv       = iv_domainv
                      iv_business_proc = iv_business_proc
                      iv_kdoc          = abap_false
                      iv_table         = abap_false
                      iv_ddic          = abap_true
                     ) .

    me->set_table( ).

    me->set_fields_structure( ).

*** Create Main Data Json Structure
    me->create_json_ddic_main( ).

*** Create KDOC Json Structure
    me->create_json_ddic_kdoc( ).

*** Create TABLE Json Structure
*    me->create_json_ddic_tabl( ).

*** Update Log
    me->update_slg1_log( it_log_ext = gt_log_ext ).
  ENDMETHOD.


  METHOD create_json_ddic_add.
    DATA: lt_relations TYPE STANDARD TABLE OF zonta_relations,
          lv_typename  TYPE rollname.

    FIELD-SYMBOLS: <fs_relations>   TYPE zonta_relations,
                   <fs_json_map>    TYPE dd03p,
                   <fs_columns_all> TYPE zonta_oc_col_all.

    lt_relations = gt_relations.

    SORT lt_relations BY tabname.

    DELETE ADJACENT DUPLICATES FROM lt_relations
                               COMPARING tabname.

    DELETE lt_relations WHERE parent_relation NE is_relations-tabname.

    SORT lt_relations BY sequence.

    LOOP AT lt_relations ASSIGNING <fs_relations>.
*      IF <fs_relations>-alias_tabname IS INITIAL.
*        <fs_relations>-alias_tabname = <fs_relations>-tabname.
*      ENDIF.

*      DATA(lv_typename) = 'ZON' && is_relations-id  && 'S' && <fs_relations>-alias_tabname && 'TABLE' && gv_messagetype.

      READ TABLE gt_columns_all WITH KEY tabname       = <fs_relations>-tabname
                                         alias_tabname = <fs_relations>-alias_tabname
                                         ASSIGNING <fs_columns_all>.

      lv_typename = 'ZON' && <fs_columns_all>-id_column && 'S' && 'SEQ' && <fs_relations>-sequence && 'TABLE' && gv_messagetype.
      APPEND INITIAL LINE TO gt_json_map ASSIGNING <fs_json_map>.
      <fs_json_map>-tabname     = is_relations-tabname.
*      <fs_json_map>-fieldname   = <fs_relations>-alias_tabname.
      <fs_json_map>-fieldname   = 'SEQ' && <fs_relations>-sequence.
      <fs_json_map>-ddlanguage  = sy-langu.
      <fs_json_map>-rollname    = lv_typename.
      <fs_json_map>-ddtext      = TEXT-002 && gv_messagetype."<fs_relations>-description_table.
      <fs_json_map>-depth       = '00'.
      <fs_json_map>-comptype    = 'N'.

*CECHAVARRIA 12/06/2025
      IF <fs_json_map>-ddtext IS INITIAL.
        <fs_json_map>-ddtext = is_relations-tabname.
      ENDIF.
*CECHAVARRIA 12/06/2025
    ENDLOOP.


  ENDMETHOD.


  METHOD create_json_ddic_body.
    DATA: lv_rc         LIKE sy-subrc,
          lv_obj_name   TYPE tadir-obj_name,
          lv_typename   TYPE rollname,
          lv_name       TYPE ddobjname,
          lv_position   TYPE tabfdpos,
          ls_dd02v      TYPE dd02v,
          ls_dd09l      TYPE dd09l,
          lt_dd03p      TYPE STANDARD TABLE OF dd03p WITH DEFAULT KEY,
          lv_message_v1 TYPE symsgv,
          lv_message_v2 TYPE symsgv,
          lv_message_v3 TYPE symsgv,
          lt_relations  TYPE STANDARD TABLE OF zonta_relations,
          lt_json_map   TYPE STANDARD TABLE OF dd03p,
          lv_object     TYPE string.

    FIELD-SYMBOLS: <ls_dd03p>       TYPE dd03p,
                   <fs_relations>   TYPE zonta_relations,
                   <fs_columns_all> TYPE zonta_oc_col_all.

    lt_relations = gt_relations.

    SORT lt_relations BY levelv tabname .

    DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING tabname.

*    READ TABLE gt_columns_all WITH KEY tabname       = is_relations-tabname
*                                       alias_tabname = is_relations-alias_tabname
*                                       ASSIGNING <fs_columns_all>.

    lv_obj_name = 'ZON' && is_relations-id && 'S' && is_relations-tabname && gv_messagetype.

    lv_name = lv_obj_name.

    lt_json_map = gt_json_map.

    DELETE lt_json_map WHERE tabname NE is_relations-tabname.

    APPEND INITIAL LINE TO lt_json_map ASSIGNING <ls_dd03p>.
    <ls_dd03p>-tabname   = lv_obj_name.
    <ls_dd03p>-fieldname = 'TABLE'.
    <ls_dd03p>-position  = '0001'.
    <ls_dd03p>-datatype  = 'CHAR'.
    <ls_dd03p>-leng      = '000060'.

    CASE gv_messagetype.
      WHEN 'TABL'.
        lv_position = 1.

        LOOP AT lt_relations ASSIGNING <fs_relations>.
          READ TABLE gt_columns_all WITH KEY tabname = <fs_relations>-tabname
                                       alias_tabname = <fs_relations>-alias_tabname
                                       ASSIGNING <fs_columns_all>.

          IF iv_main EQ abap_true.
            IF <fs_relations>-alias_tabname IS INITIAL.
              <fs_relations>-alias_tabname = <fs_relations>-tabname.
            ENDIF.
          ENDIF.
          lv_position = lv_position + 1.

          IF iv_main EQ abap_true.
            lv_typename = 'ZON' && <fs_columns_all>-id_column && 'TT' && <fs_relations>-alias_tabname.
          ELSE.
            lv_typename = 'ZON' && <fs_columns_all>-id_column && 'TT' && 'SEQ' && <fs_relations>-sequence.
          ENDIF.
          APPEND INITIAL LINE TO lt_json_map ASSIGNING <ls_dd03p>.
          <ls_dd03p>-tabname     = lv_obj_name.
          IF iv_main EQ abap_true.
            IF iv_def_tab IS INITIAL.
              <ls_dd03p>-fieldname   = iv_data_node && <fs_relations>-alias_tabname .
            ELSE.
              <ls_dd03p>-fieldname   =  <fs_relations>-alias_tabname .
            ENDIF.
          ELSE.
            IF iv_def_tab IS INITIAL.
              <ls_dd03p>-fieldname   = iv_data_node && 'SEQ' && <fs_relations>-sequence .
            ELSE.
              <ls_dd03p>-fieldname   =  'SEQ' && <fs_relations>-sequence .
            ENDIF.
          ENDIF.
          <ls_dd03p>-position    = lv_position.
          <ls_dd03p>-ddlanguage  = sy-langu.
          <ls_dd03p>-rollname    = lv_typename.
          <ls_dd03p>-datatype    = 'TTYP'.
*    <ls_dd03p>-ddtext      = 'Data'.
          <ls_dd03p>-depth       = '00'.
          <ls_dd03p>-comptype    = 'L'.
        ENDLOOP.

        lv_object = 'TABL'.

      WHEN OTHERS.
        IF is_columns IS INITIAL.
          IF iv_main EQ abap_true.
            lv_typename = 'ZON' && is_relations-id && 'TT' && is_relations-alias_tabname.
          ELSE.
            lv_typename = 'ZON' && is_relations-id && 'TT' && 'SEQ' && is_relations-sequence.
          ENDIF.
        ELSE.
          IF iv_main EQ abap_true.
            lv_typename = 'ZON' && is_columns-id_column && 'TT' && is_relations-alias_tabname.
          ELSE.
            lv_typename = 'ZON' && is_columns-id_column && 'TT' && 'SEQ' && is_relations-sequence.
          ENDIF.
        ENDIF.

        APPEND INITIAL LINE TO lt_json_map ASSIGNING <ls_dd03p>.
        <ls_dd03p>-tabname     = lv_obj_name.
        <ls_dd03p>-fieldname   = iv_data_node.
        <ls_dd03p>-position    = '0002'.
        <ls_dd03p>-ddlanguage  = sy-langu.
        <ls_dd03p>-rollname    = lv_typename.
        <ls_dd03p>-datatype    = 'TTYP'.
*    <ls_dd03p>-ddtext      = 'Data'.
        <ls_dd03p>-depth       = '00'.
        <ls_dd03p>-comptype    = 'L'.
        lv_object = 'TTYP'.

    ENDCASE.


    ls_dd02v-tabname    = lv_obj_name.
    ls_dd02v-ddlanguage = sy-langu.
    ls_dd02v-tabclass   = 'INTTAB'.
    ls_dd02v-ddtext     = text-002 && gv_messagetype. "is_relations-alias_tabname.
    ls_dd02v-exclass    = '0'.


    CALL FUNCTION 'DDIF_TABL_PUT'
      EXPORTING
        name              = lv_name
        dd02v_wa          = ls_dd02v
        dd09l_wa          = ls_dd09l
      TABLES
        dd03p_tab         = lt_json_map
      EXCEPTIONS
        tabl_not_found    = 1
        name_inconsistent = 2
        tabl_inconsistent = 3
        put_failure       = 4
        put_refused       = 5
        OTHERS            = 6.
    IF sy-subrc <> 0.
*      WRITE:/  'zcx_abapgit_exception=>raise_t100( )'.
*      RETURN.
      lv_message_v3 = 'migrate, error from DDIF_TABL_PUT-' && lv_obj_name.
    ENDIF.


    IF sy-subrc EQ 0.
      IF gv_devclass IS INITIAL.
        CALL FUNCTION 'TR_TADIR_INTERFACE'
          EXPORTING
            wi_tadir_pgmid    = 'R3TR'
            wi_tadir_object   = 'TABL'
            wi_tadir_obj_name = lv_obj_name
            wi_set_genflag    = abap_true
            wi_test_modus     = abap_false
*           wi_tadir_devclass = '$TMP'
          EXCEPTIONS
            OTHERS            = 1.
      ELSE.
        CALL FUNCTION 'TR_TADIR_INTERFACE'
          EXPORTING
            wi_tadir_pgmid    = 'R3TR'
            wi_tadir_object   = 'TABL'
            wi_tadir_obj_name = lv_obj_name
            wi_set_genflag    = abap_true
            wi_test_modus     = abap_false
            wi_tadir_devclass = gv_devclass
          EXCEPTIONS
            OTHERS            = 1.
      ENDIF.
      IF sy-subrc <> 0.
*      WRITE:/ 'zcx_abapgit_exception=>raise_t100( )'.
*      RETURN.
        lv_message_v3 = 'migrate, error from TR_TADIR_INTERFACE-' && lv_obj_name.

      ENDIF.

      lv_object = 'TABL'.  "++FIXDB
      lv_object = lv_object && lv_obj_name.

      me->set_corr_insert( iv_mode    =  'I'
                           iv_object  = lv_object ).
    ENDIF.

    IF sy-subrc EQ 0.
      CALL FUNCTION 'DDIF_TABL_ACTIVATE'
        EXPORTING
          name        = lv_name
          auth_chk    = abap_false
        IMPORTING
          rc          = lv_rc
        EXCEPTIONS
          not_found   = 1
          put_failure = 2
          OTHERS      = 3.
      IF sy-subrc <> 0 OR lv_rc <> 0.
        IF lv_rc <> 4.
*        WRITE :/ 'migrate, error from DDIF_TABL_ACTIVATE' , lv_obj_name .
*        RETURN.
          lv_message_v3 = 'migrate, error from DDIF_TABL_ACTIVATE-' && lv_obj_name.

        ENDIF.
      ENDIF.
    ENDIF.

    me->validate_ddic_active( iv_object = lv_obj_name ) .
    me->add_object_entry( iv_pgmid = 'R3TR'  iv_object  = 'TABL'  iv_object_name = lv_obj_name ). "++TRKORR DB


*** Generate Log
    lv_message_v1 = 'DDIC'.
    lv_message_v2 = lv_name.
    IF lv_message_v3 IS INITIAL.
      lv_message_v3 = 'activated success'.
    ENDIF.

    CALL METHOD me->append_slg1_log
      EXPORTING
        iv_tabname    = lv_name
*       iv_key        =
        iv_message_v1 = lv_message_v1
        iv_message_v2 = lv_message_v2
        iv_message_v3 = lv_message_v3.


    ev_type = lv_obj_name.

  ENDMETHOD.


  METHOD create_json_ddic_kdoc.

    DATA: lv_type_name TYPE string,
          lt_relations TYPE STANDARD TABLE OF zonta_relations,
          ls_relations TYPE zonta_relations.

    FIELD-SYMBOLS: <fs_columns> TYPE zonta_oc_col_all.

    lt_relations = gt_relations.

    SORT lt_relations BY levelv .

    DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING tabname.

    READ TABLE lt_relations INDEX 1 INTO ls_relations.

    READ TABLE gt_columns_all WITH KEY tabname       = ls_relations-tabname
                                       alias_tabname = ls_relations-alias_tabname
                                       ASSIGNING <fs_columns>.

*    IF sy-subrc EQ 0.
    IF NOT ls_relations IS INITIAL.
      gv_messagetype = c_kdoc.

      IF ls_relations-alias_tabname IS INITIAL.
        ls_relations-alias_tabname = ls_relations-tabname.
*    ELSE.
*      ls_relations-alias_tabname = 'HEADER'.
      ENDIF.

      ls_relations-tabname       = 'BODY'.

      me->create_json_ddic_body( EXPORTING is_relations = ls_relations
                                           is_columns   = <fs_columns>
                                           iv_def_tab   = abap_true
                                 IMPORTING ev_type      = lv_type_name ).

      me->set_fields_structure( EXPORTING iv_type_name   = lv_type_name
                                          iv_type        = 'STRU'
                                          iv_type_field  = 'BODY'
                                          iv_type_table  = 'CONNECTDET').

      ls_relations-tabname       = 'CONNECTDET'.
      ls_relations-alias_tabname = 'CONNECTDET'.

      me->create_json_ddic_structure( EXPORTING is_relations = ls_relations
                                                iv_main      = abap_true
                                                iv_header    = abap_true
                                      IMPORTING ev_type      = lv_type_name ) .

      me->set_fields_structure( EXPORTING iv_type_name   = lv_type_name
                                          iv_type        = 'STRU'
                                          iv_type_field  = 'ONECONNECT'
                                          iv_type_table  = 'CONNECT').

      ls_relations-tabname       = 'CONNECT'.
      ls_relations-alias_tabname = 'CONNECT'.

      me->create_json_ddic_structure( EXPORTING is_relations = ls_relations
                                                iv_main      = abap_true
                                                iv_header    = abap_true
                                      IMPORTING ev_type      = lv_type_name ) .
    ENDIF.
  ENDMETHOD.


  METHOD create_json_ddic_main.

    DATA: lv_type_name TYPE string,
          lt_relations TYPE STANDARD TABLE OF zonta_relations,
          ls_relations TYPE zonta_relations.

    FIELD-SYMBOLS: <fs_relations> TYPE zonta_relations.

    lt_relations = gt_relations.

    SORT lt_relations BY levelv .

    DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING tabname.

*** Create Structures
    LOOP AT lt_relations ASSIGNING <fs_relations>.
      me->create_json_ddic_structure( is_relations    = <fs_relations>
                                      iv_event        = gs_oc_obj-eventid
                                      iv_tagmetadata  = gs_oc_obj-metadata ) .
      me->create_json_ddic_type_table( is_relations = <fs_relations> ) .
    ENDLOOP.


*** Prepare Deep Structures
    LOOP AT lt_relations ASSIGNING <fs_relations>.

      me->create_json_ddic_structure( is_relations = <fs_relations>
                                      iv_def_tab   = abap_true ) .

      me->create_json_ddic_add( is_relations = <fs_relations> ).

    ENDLOOP.

*** Create Deep Structures
    LOOP AT lt_relations ASSIGNING <fs_relations>.
      me->create_json_ddic_structure( is_relations    = <fs_relations>
                                      iv_event        = gs_oc_obj-eventid
                                      iv_tagmetadata  = gs_oc_obj-metadata ).

      me->create_json_ddic_type_table( is_relations = <fs_relations> ) .
    ENDLOOP.


    READ TABLE lt_relations INDEX 1 INTO ls_relations.
    IF sy-subrc EQ 0.

      ls_relations-tabname       = 'PROPERTIES'.
      ls_relations-alias_tabname = 'PROPERTIES'.
      me->create_json_ddic_structure( EXPORTING is_relations = ls_relations
                                                iv_main      = abap_true
                                                iv_header    = abap_true
                                      IMPORTING ev_type      = lv_type_name ) .

      me->set_fields_structure( EXPORTING iv_type_name   = lv_type_name
                                          iv_type        = 'STRU'
                                          iv_type_field  = 'PROPERTIES'
                                          iv_type_table  = 'CONNECTDET'
                                          ).

      ls_relations-tabname       = 'METADATADET'.
      ls_relations-alias_tabname = 'METADATADET'.

      me->create_json_ddic_structure( is_relations = ls_relations
                                      iv_main      = abap_true
                                      iv_header    = abap_true ).                                     .
      me->create_json_ddic_type_table( is_relations = ls_relations
                                       iv_main      = abap_true
                                       iv_header    = abap_true ) .

      READ TABLE lt_relations INDEX 1 INTO ls_relations.
      IF sy-subrc EQ 0.
        ls_relations-tabname       = 'METADATA'.
        ls_relations-alias_tabname = 'METADATADET'.
        me->create_json_ddic_body( is_relations = ls_relations
                                   iv_def_tab   = abap_true
                                   iv_data_node = 'METADATA'
                                   iv_main      = abap_true  ).

        ls_relations-alias_tabname = 'METADATA'.
        me->create_json_ddic_type_table( EXPORTING is_relations = ls_relations
                                                   iv_main      = abap_true
                                                   iv_header    = abap_true
                                         IMPORTING ev_type      = lv_type_name ) .

        me->set_fields_structure( EXPORTING iv_type_name   = lv_type_name
                                            iv_type        = 'TTYP'
                                            iv_type_field  = 'METADATA'
                                            iv_type_table  = 'CONNECTDET').
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD create_json_ddic_structure.
    DATA: lv_rc             LIKE sy-subrc,
          lv_obj_name       TYPE tadir-obj_name,
          lv_name           TYPE ddobjname,
          lv_id             TYPE string,
          lv_typename       TYPE rollname,
          lv_position       TYPE tabfdpos,
          ls_dd02v          TYPE dd02v,
          ls_dd09l          TYPE dd09l,
          lt_dd03p          TYPE STANDARD TABLE OF dd03p WITH DEFAULT KEY,
          lt_json_map       TYPE STANDARD TABLE OF dd03p,
          lt_json_map_event TYPE STANDARD TABLE OF dd03p,
          lv_message_v1     TYPE symsgv,
          lv_message_v2     TYPE symsgv,
          lv_message_v3     TYPE symsgv,
          lv_mestyp	        TYPE bapi_mtype VALUE 'S',
          lv_object         TYPE string.


    FIELD-SYMBOLS: <ls_dd03p>          TYPE dd03p,
                   <fs_json_position>  TYPE dd03p,
                   <fs_json_map_event> TYPE dd03p,
                   <fs_columns_all>    TYPE zonta_oc_col_all.


    IF iv_header EQ abap_true.
      lv_id  = is_relations-id.
    ELSE.
      READ TABLE gt_columns_all WITH KEY tabname       = is_relations-tabname
                                        alias_tabname = is_relations-alias_tabname
                                        ASSIGNING <fs_columns_all>.
      lv_id  = <fs_columns_all>-id_column.
    ENDIF.

    IF iv_main EQ abap_true.
      IF iv_def_tab IS INITIAL.
        lv_obj_name = 'ZON' && lv_id  && 'S' && is_relations-alias_tabname && gv_messagetype.
      ELSE.
        lv_obj_name = 'ZON' && lv_id  && 'S' && is_relations-alias_tabname && 'TABLE' && gv_messagetype.
      ENDIF.
    ELSE.
      IF iv_def_tab IS INITIAL.
        lv_obj_name = 'ZON' && lv_id  && 'SSEQ' && is_relations-sequence && gv_messagetype.
      ELSE.
        lv_obj_name = 'ZON' && lv_id  && 'SSEQ' && is_relations-sequence && 'TABLE' && gv_messagetype.
      ENDIF.
    ENDIF.


    lv_name = lv_obj_name.

    IF iv_def_tab IS INITIAL.
      lt_json_map = gt_json_map.

      DELETE lt_json_map WHERE tabname NE is_relations-tabname.

      LOOP AT lt_json_map ASSIGNING <fs_json_position>.
        lv_position = lv_position + 1.

        <fs_json_position>-tabname   = lv_obj_name.
        <fs_json_position>-position  = lv_position.
      ENDLOOP.

      IF iv_event       EQ abap_true OR
         iv_tagmetadata EQ abap_true.
        lt_json_map_event = gt_json_map.

        DELETE lt_json_map_event WHERE tabname NE 'ZONST_OC_EVENTID'.

        LOOP AT lt_json_map_event ASSIGNING <fs_json_position>.
          lv_position = lv_position + 1.

          APPEND INITIAL LINE TO lt_json_map ASSIGNING <fs_json_map_event>.

          <fs_json_map_event> = <fs_json_position>.

          <fs_json_map_event>-tabname   = lv_obj_name.
          <fs_json_map_event>-position  = lv_position.
        ENDLOOP.
      ENDIF.

    ELSE.
      APPEND INITIAL LINE TO lt_json_map ASSIGNING <ls_dd03p>.
      <ls_dd03p>-tabname   = lv_obj_name.
      <ls_dd03p>-fieldname = 'TABLE'.
      <ls_dd03p>-position  = '0001'.
      <ls_dd03p>-datatype  = 'CHAR'.
      <ls_dd03p>-leng      = '000060'.

*      DATA(lv_typename) = 'ZON' && is_relations-id && 'TT' && is_relations-alias_tabname && gv_messagetype.
      lv_typename = 'ZON' && <fs_columns_all>-id_column && 'TT' && 'SEQ' && is_relations-sequence && gv_messagetype.
      APPEND INITIAL LINE TO lt_json_map ASSIGNING <ls_dd03p>.
      <ls_dd03p>-tabname     = lv_obj_name.
      <ls_dd03p>-fieldname   = iv_data_node.
      <ls_dd03p>-position    = '0002'.
      <ls_dd03p>-ddlanguage  = sy-langu.
      <ls_dd03p>-rollname    = lv_typename.
      <ls_dd03p>-datatype    = 'TTYP'.
*      <ls_dd03p>-ddtext      = 'Data'.
      <ls_dd03p>-depth       = '00'.
      <ls_dd03p>-comptype    = 'L'.
    ENDIF.

    ls_dd02v-tabname    = lv_obj_name.
    ls_dd02v-ddlanguage = sy-langu.
    ls_dd02v-tabclass   = 'INTTAB'.
    ls_dd02v-ddtext     = TEXT-002 && gv_messagetype. "is_relations-alias_tabname.
    ls_dd02v-exclass    = '0'.

*CECHAVARRIA 12/06/2025
    IF ls_dd02v-ddtext IS INITIAL.
      ls_dd02v-ddtext = lv_obj_name.
    ENDIF.
*CECHAVARRIA 12/06/2025


    CALL FUNCTION 'DDIF_TABL_PUT'
      EXPORTING
        name              = lv_name
        dd02v_wa          = ls_dd02v
        dd09l_wa          = ls_dd09l
      TABLES
        dd03p_tab         = lt_json_map
      EXCEPTIONS
        tabl_not_found    = 1
        name_inconsistent = 2
        tabl_inconsistent = 3
        put_failure       = 4
        put_refused       = 5
        OTHERS            = 6.
    IF sy-subrc <> 0.
*      WRITE:/  'DDIF_TABL_PUT' , lv_obj_name .
*      RETURN.

      lv_message_v3 = 'DDIF_TABL_PUT-' && lv_obj_name.
      lv_mestyp	 = 'E'.
    ENDIF.

    IF sy-subrc EQ 0.
      IF gv_devclass IS INITIAL.
        CALL FUNCTION 'TR_TADIR_INTERFACE'
          EXPORTING
            wi_tadir_pgmid    = 'R3TR'
            wi_tadir_object   = 'TABL'
            wi_tadir_obj_name = lv_obj_name
            wi_set_genflag    = abap_true
            wi_test_modus     = abap_false
*           wi_tadir_devclass = '$TMP'
          EXCEPTIONS
            OTHERS            = 1.
      ELSE.
        CALL FUNCTION 'TR_TADIR_INTERFACE'
          EXPORTING
            wi_tadir_pgmid    = 'R3TR'
            wi_tadir_object   = 'TABL'
            wi_tadir_obj_name = lv_obj_name
            wi_set_genflag    = abap_true
            wi_test_modus     = abap_false
            wi_tadir_devclass = gv_devclass
          EXCEPTIONS
            OTHERS            = 1.
      ENDIF.
      IF sy-subrc <> 0.
*      WRITE:/ 'TR_TADIR_INTERFACE' , lv_obj_name.
*      RETURN.

        lv_message_v3 = 'TR_TADIR_INTERFACE-' && lv_obj_name.
        lv_mestyp	 = 'E'.
      ENDIF.

      lv_object = 'TABL' && lv_obj_name.

      me->set_corr_insert( iv_mode   = 'I'
                           iv_object = lv_object ).

    ENDIF.

    IF sy-subrc EQ 0.
      CALL FUNCTION 'DDIF_TABL_ACTIVATE'
        EXPORTING
          name        = lv_name
          auth_chk    = abap_false
        IMPORTING
          rc          = lv_rc
        EXCEPTIONS
          not_found   = 1
          put_failure = 2
          OTHERS      = 3.
      IF sy-subrc <> 0 OR lv_rc <> 0.
        IF lv_rc <> 4.
*        WRITE :/ 'migrate, error from DDIF_TABL_ACTIVATE' , lv_obj_name .
*        RETURN.
          lv_message_v3 = 'migrate, error from DDIF_TABL_ACTIVATE-' && lv_obj_name.
          lv_mestyp	 = 'E'.
        ENDIF.
      ENDIF.
    ENDIF.

    me->validate_ddic_active( iv_object = lv_obj_name ).
    me->add_object_entry( iv_pgmid = 'R3TR'  iv_object  = 'TABL'  iv_object_name = lv_obj_name ). "++TRKORR DB

    lv_message_v1 = 'DDIC'.
    lv_message_v2 = lv_name.
    IF lv_message_v3 IS INITIAL.
      lv_message_v3 = 'activated success'.
    ENDIF.

    CALL METHOD me->append_slg1_log
      EXPORTING
        iv_tabname    = lv_name
*       iv_key        =
        iv_message_v1 = lv_message_v1
        iv_message_v2 = lv_message_v2
        iv_message_v3 = lv_message_v3
        iv_mestyp     = lv_mestyp.


    ev_type = lv_obj_name.
  ENDMETHOD.


  METHOD create_json_ddic_tabl.
    DATA: lt_relations TYPE STANDARD TABLE OF zonta_relations,
          ls_relations TYPE zonta_relations,
          lv_type_name TYPE string.

    FIELD-SYMBOLS: <fs_relations> TYPE zonta_relations.

    lt_relations = gt_relations.

    SORT lt_relations BY levelv  .

    DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING tabname.

    READ TABLE lt_relations INDEX 1 INTO ls_relations.

    IF sy-subrc EQ 0.

      gv_messagetype = c_table.

*** create structures
      LOOP AT lt_relations ASSIGNING <fs_relations>.
        me->create_json_ddic_structure( is_relations = <fs_relations>
                                        iv_event     = gs_oc_obj-eventid ) .
        me->create_json_ddic_type_table( is_relations = <fs_relations> ) .
      ENDLOOP.

      IF ls_relations-alias_tabname IS INITIAL.
        ls_relations-alias_tabname = ls_relations-tabname.
*    ELSE.
*      ls_relations-alias_tabname = 'HEADER'.
      ENDIF.

      ls_relations-tabname       = 'BODY'.


      me->create_json_ddic_body( EXPORTING is_relations = ls_relations
                                          iv_def_tab   = abap_true
                                IMPORTING ev_type      = lv_type_name ).

      DELETE gt_json_map WHERE tabname EQ  'CONNECTDET'
                           AND fieldname EQ 'BODY'.

      me->set_fields_structure( EXPORTING iv_type_name   = lv_type_name
                                          iv_type        = 'STRU'
                                          iv_type_field  = 'BODY'
                                          iv_type_table  = 'CONNECTDET').

      ls_relations-tabname       = 'CONNECTDET'.
      ls_relations-alias_tabname = 'CONNECTDET'.

      me->create_json_ddic_structure( EXPORTING is_relations = ls_relations
                                                iv_main      = abap_true
                                                iv_header    = abap_true
                                      IMPORTING ev_type      = lv_type_name ) .

      DELETE gt_json_map WHERE tabname EQ 'CONNECT'.

      me->set_fields_structure( EXPORTING iv_type_name   = lv_type_name
                                          iv_type        = 'STRU'
                                          iv_type_field  = 'ONECONNECT'
                                          iv_type_table  = 'CONNECT').

      ls_relations-tabname       = 'CONNECT'.
      ls_relations-alias_tabname = 'CONNECT'.

      me->create_json_ddic_structure( EXPORTING is_relations = ls_relations
                                                iv_main      = abap_true
                                                iv_header    = abap_true
                                      IMPORTING ev_type      = lv_type_name ) .
    ENDIF.
  ENDMETHOD.


  METHOD create_json_ddic_type_table.
    DATA: dd40v_wa      TYPE  dd40v,
          lv_obj_name   TYPE tadir-obj_name,
          lv_name       TYPE  ddobjname,
          lv_id         TYPE string,
          lv_rc         TYPE sy-subrc,
          lv_message_v1 TYPE symsgv,
          lv_message_v2 TYPE symsgv,
          lv_message_v3 TYPE symsgv,
          lv_typename   TYPE rollname,
          lv_object     TYPE string.

    FIELD-SYMBOLS: <fs_columns_all> TYPE zonta_oc_col_all.


    IF iv_header EQ abap_true.
      lv_id = is_relations-id.
    ELSE.
      READ TABLE gt_columns_all WITH KEY tabname       = is_relations-tabname
                                         alias_tabname = is_relations-alias_tabname
                                         ASSIGNING <fs_columns_all>.
      lv_id = <fs_columns_all>-id_column .
    ENDIF.

    IF iv_main EQ abap_true.
      lv_typename = 'ZON' && lv_id && 'TT' && is_relations-alias_tabname && gv_messagetype.
    ELSE.
      lv_typename = 'ZON' && lv_id && 'TT' && 'SEQ' && is_relations-sequence && gv_messagetype.
    ENDIF.

    dd40v_wa-typename    =  lv_typename.
    dd40v_wa-ddlanguage  =  sy-langu.

    IF iv_main EQ abap_true.
      lv_typename = 'ZON' && lv_id && 'S' && is_relations-alias_tabname && gv_messagetype.
    ELSE.
      lv_typename = 'ZON' && lv_id && 'S' && 'SEQ' && is_relations-sequence && gv_messagetype.
    ENDIF.


    dd40v_wa-rowtype     =  lv_typename.
    dd40v_wa-rowkind     =  'S'.
    dd40v_wa-accessmode  =  'T'.
    dd40v_wa-keydef      =  'D'.
    dd40v_wa-keykind     =  'N'.
    dd40v_wa-ddtext      = TEXT-001 && gv_messagetype. "is_relations-description_table.

*CECHAVARRIA 12/06/2025
    IF dd40v_wa-ddtext IS INITIAL.
      dd40v_wa-ddtext = lv_typename.
    ENDIF.
*CECHAVARRIA 12/06/2025

    lv_obj_name = dd40v_wa-typename.

    lv_name = lv_obj_name.

    CALL FUNCTION 'DDIF_TTYP_PUT'
      EXPORTING
        name              = lv_name
        dd40v_wa          = dd40v_wa
      EXCEPTIONS
        ttyp_not_found    = 1
        name_inconsistent = 2
        ttyp_inconsistent = 3
        put_failure       = 4
        put_refused       = 5
        OTHERS            = 6.
    IF sy-subrc <> 0.
*      WRITE:/ 'DDIF_TTYP_PUT',  lv_obj_name.
*      RETURN.
      lv_message_v3 = 'DDIF_TTYP_PUT-' && lv_obj_name.
    ENDIF.

    IF sy-subrc EQ 0.
      IF gv_devclass IS INITIAL.
        CALL FUNCTION 'TR_TADIR_INTERFACE'
          EXPORTING
            wi_tadir_pgmid    = 'R3TR'
            wi_tadir_object   = 'TTYP'
            wi_tadir_obj_name = lv_obj_name
            wi_set_genflag    = abap_true
            wi_test_modus     = abap_false
*           wi_tadir_devclass = '$TMP'
          EXCEPTIONS
            OTHERS            = 1.
      ELSE.
        CALL FUNCTION 'TR_TADIR_INTERFACE'
          EXPORTING
            wi_tadir_pgmid    = 'R3TR'
            wi_tadir_object   = 'TTYP'
            wi_tadir_obj_name = lv_obj_name
            wi_set_genflag    = abap_true
            wi_test_modus     = abap_false
            wi_tadir_devclass = gv_devclass
          EXCEPTIONS
            OTHERS            = 1.
      ENDIF.
      IF sy-subrc <> 0.
*      WRITE:/ 'zcx_abapgit_exception=>raise_t100( )' , lv_obj_name.
*      RETURN.

        lv_message_v3 = 'TR_TADIR_INTERFACE-' && lv_obj_name.

      ENDIF.

      lv_object = 'TTYP' && lv_obj_name.

      me->set_corr_insert( iv_mode   = 'I'
                           iv_object = lv_object ).

    ENDIF.

    IF sy-subrc EQ 0.
      CALL FUNCTION 'DDIF_TTYP_ACTIVATE'
        EXPORTING
          name        = lv_name
*         PRID        = -1
        IMPORTING
          rc          = lv_rc
        EXCEPTIONS
          not_found   = 1
          put_failure = 2
          OTHERS      = 3.

      IF sy-subrc <> 0 OR lv_rc <> 0.
        IF lv_rc <> 4.
*        WRITE :/ 'migrate, error from DDIF_TABL_ACTIVATE ' , lv_obj_name.
*        RETURN.
          lv_message_v3 = 'migrate, error from DDIF_TABL_ACTIVATE-' && lv_obj_name.

        ENDIF.
      ENDIF.
    ENDIF.

    me->validate_ddic_active( iv_object = lv_obj_name ).
    me->add_object_entry( iv_pgmid = 'R3TR'  iv_object  = 'TTYP'  iv_object_name = lv_obj_name ). "++TRKORR DB


*** Generate log
    lv_message_v1 = 'DDIC'.
    lv_message_v2 = lv_name.
    IF lv_message_v3 IS INITIAL.
      lv_message_v3 = 'activated success'.
    ENDIF.


    CALL METHOD me->append_slg1_log
      EXPORTING
        iv_tabname    = lv_name
*       iv_key        =
        iv_message_v1 = lv_message_v1
        iv_message_v2 = lv_message_v2
        iv_message_v3 = lv_message_v3.


    ev_type = lv_obj_name.
  ENDMETHOD.


    METHOD delete_data_body.
      DATA: lv_tabname        TYPE string,
            lv_field          TYPE string,
            lv_tabnameddif    TYPE ddobjname,
            lv_keys           TYPE string,
            lv_keys_main      TYPE string,
            lv_keys_temp      TYPE string,
            lv_root           TYPE string,
            lt_dfies_tab      TYPE STANDARD TABLE OF  dfies,
            lt_keys           TYPE tty_where,
            iv_message_v1     TYPE  symsgv,
            lt_relations      TYPE STANDARD TABLE OF zonta_relations,
            ls_relations_last TYPE zonta_relations,
            ls_relations      TYPE zonta_relations,
            lv_lines          TYPE sy-tabix,
            lo_data           TYPE REF TO data,
            lv_max_records    TYPE zonde_registrosn,
            lv_lenght         TYPE numc2.

      DATA : dref_table  TYPE REF TO data,
             dref_table1 TYPE REF TO data.


      FIELD-SYMBOLS: <fs_table>        TYPE STANDARD TABLE,
                     <fs_table1>       TYPE STANDARD TABLE,
                     <fs_table2>       TYPE STANDARD TABLE,
                     <fs_field>        TYPE any,
                     <fs_field1>       TYPE STANDARD TABLE,
                     <fs_wa>           TYPE any,
                     <fs_relations>    TYPE zonta_relations,
                     <fs_line>         TYPE any,
                     <fs_line_json>    TYPE any,
                     <fs_field_mandt>  TYPE any,
                     <fs_key>          TYPE any,
                     <fs_keys_event>   TYPE LINE OF tty_where,
                     <fs_result>       TYPE any,
                     <fs_data>         TYPE any,
                     <fs_table_line>   TYPE any,
                     <fs_json>         TYPE any,
                     <fs_key_main>     TYPE any,
                     <fs_cdpos>        TYPE ty_cdpos,
                     <fs_columns>      TYPE zonta_oc_col_all,
                     <fs_value_source> TYPE any,
                     <fs_value_target> TYPE any,
                     <fs_line_source>  TYPE any.


      IF NOT gt_cdpos IS INITIAL.
        IF iv_parent_relation IS INITIAL.
          CLEAR gv_recordst_obj.

          CASE sy-xform.
            WHEN 'ZONFM_ONE_CONNECT_BATCH'.
              iv_message_v1 = '*** Batch Process KDOC***'.
            WHEN 'SWF_EVT_HANDLER_START_INTERNAL'.
              iv_message_v1 = '*** Event Process KDOC ***'.
*CECHAVARRIA 07/05/2025
            WHEN 'FM_BGMC_PROCESS'.
              iv_message_v1 = '*** Direct Process KDOC RAP BO***'.
*CECHAVARRIA 07/05/2025
            WHEN OTHERS.
              iv_message_v1 = '*** Direct Process KDOC***'.
          ENDCASE.

          me->append_slg1_log(
            EXPORTING
              iv_tabname    = space
*       iv_key        =
              iv_message_v1 = iv_message_v1
              iv_message_v2 = space
              iv_message_v3 = space
              iv_mestyp     = 'S' ).
        ENDIF.

        lt_relations = gt_relations.

        SORT lt_relations BY sequence.
        DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING sequence.

        SORT lt_relations BY levelv.

        lv_lines = lines( lt_relations ).

        READ TABLE lt_relations INDEX lv_lines INTO ls_relations_last.

        IF iv_parent_relation IS INITIAL.

          READ TABLE lt_relations INDEX 1 INTO ls_relations.

          lv_root = 'ZON' && ls_relations-id && 'SBODY' && gv_messagetype.

          CREATE DATA dref_table TYPE (lv_root).
          ASSIGN dref_table->* TO <fs_wa>.
        ELSE.
          ASSIGN cs_line_json TO <fs_wa>.
        ENDIF.

        LOOP AT lt_relations ASSIGNING <fs_relations>
                             WHERE parent_relation EQ iv_parent_relation.

          CLEAR: lt_keys ,
                 lv_keys.

          me->get_key( EXPORTING  iv_parent_relation = iv_parent_relation
                                  iv_tabname         = <fs_relations>-tabname
                       IMPORTING  et_keys            = lt_keys
                                   ev_key            = lv_keys
                                   ev_key_main       = lv_keys_main ).

          IF iv_parent_relation IS INITIAL.
            lv_tabname = 'DATA'.
          ELSE.
*        lv_tabname = <fs_relations>-alias_tabname && '-DATA'.
            lv_tabname = 'SEQ' && <fs_relations>-sequence && '-DATA'.
          ENDIF.

          me->get_data_by_table_data( EXPORTING
                                      iv_parent_relation = iv_parent_relation
                                      iv_table           = <fs_relations>-tabname
                                      IMPORTING
                                       et_data           = lo_data ).

          IF NOT lo_data IS INITIAL.
            ASSIGN lo_data->* TO <fs_table>.

            ASSIGN it_data TO <fs_table2>.

            LOOP AT <fs_table2> ASSIGNING <fs_data>.
              APPEND INITIAL LINE TO <fs_table> ASSIGNING <fs_table_line>.
              MOVE-CORRESPONDING <fs_data> TO <fs_table_line> .
            ENDLOOP.

            ASSIGN COMPONENT lv_tabname OF STRUCTURE <fs_wa> TO <fs_table1>.

            ASSIGN <fs_relations>-alias_tabname TO <fs_field>.

            IF iv_parent_relation IS INITIAL.
              lv_field = 'TABLE'.
            ELSE.
*          lv_field = <fs_relations>-alias_tabname && '-TABLE'.
              lv_field = 'SEQ' && <fs_relations>-sequence && '-TABLE'.
            ENDIF.

            ASSIGN COMPONENT lv_field OF STRUCTURE <fs_wa> TO <fs_field>.
*        <fs_field> = <fs_relations>-alias_tabname.
            <fs_field> = 'SEQ' && <fs_relations>-sequence.
            TRANSLATE <fs_field> TO LOWER CASE.

            SORT <fs_table>.
            DELETE ADJACENT DUPLICATES FROM <fs_table>.


*        LOOP AT <fs_table> ASSIGNING <fs_line>
*                           WHERE (lv_keys).


            me->get_lenght_key(
              EXPORTING
                iv_tabname = <fs_relations>-tabname
                iv_parent  = iv_parent_relation
              RECEIVING
                rv_lenght  = lv_lenght ).

            LOOP AT gt_cdpos ASSIGNING <fs_cdpos>
                          WHERE tabname EQ <fs_relations>-tabname.
              CREATE DATA dref_table TYPE (<fs_relations>-tabname).
              ASSIGN dref_table->* TO <fs_line_source>.

              APPEND INITIAL LINE TO <fs_table1> ASSIGNING <fs_line_json>.

              LOOP AT gt_columns_all ASSIGNING <fs_columns> WHERE tabname EQ <fs_relations>-tabname.
                ASSIGN COMPONENT <fs_columns>-fldname OF STRUCTURE <fs_line_source> TO <fs_value_source>.

                <fs_line_source> = <fs_cdpos>-tabkey(lv_lenght).

                IF NOT <fs_columns>-alias_fldname IS INITIAL.
                  TRANSLATE <fs_columns>-alias_fldname TO UPPER CASE.
                  ASSIGN COMPONENT <fs_columns>-alias_fldname OF STRUCTURE <fs_line_json> TO <fs_value_target>.
                ELSE.
                  ASSIGN COMPONENT <fs_columns>-fldname OF STRUCTURE <fs_line_json> TO <fs_value_target>.
                ENDIF.

                <fs_value_target> = <fs_value_source>.
              ENDLOOP.


*          APPEND INITIAL LINE TO <fs_table1> ASSIGNING <fs_line_json>.
*          MOVE-CORRESPONDING <fs_line> TO <fs_line_json>.
              ASSIGN COMPONENT 1  OF STRUCTURE <fs_line_json> TO <fs_field_mandt>.
              IF <fs_field_mandt> IS ASSIGNED.
                <fs_field_mandt> = sy-mandt.
              ENDIF.

              IF iv_parent_relation IS INITIAL.

                gv_recordst_obj = gv_recordst_obj + 1.

                ASSIGN COMPONENT 2 OF STRUCTURE <fs_line> TO <fs_key>.

                IF <fs_key> IS ASSIGNED.
                  me->append_slg1_log( iv_mestyp = 'S'
                                       iv_tabname = <fs_relations>-tabname
                                       iv_key     = <fs_key> ).
                ENDIF.

                ASSIGN COMPONENT lv_keys_main OF STRUCTURE <fs_line_json> TO <fs_key_main>.

                IF lv_keys_temp NE <fs_key_main>.
                  lv_keys_temp   = <fs_key_main>.
                  lv_max_records = lv_max_records + 1.
                ENDIF.

              ENDIF.

*** Fill Even ID
              IF gs_oc_obj-eventid  EQ abap_true OR
                 gs_oc_obj-metadata EQ abap_true.
                IF <fs_key> IS ASSIGNED.
                  APPEND INITIAL LINE TO lt_keys ASSIGNING <fs_keys_event>.
                  <fs_keys_event>-line = <fs_key>.
                ENDIF.

                me->get_eventid(  EXPORTING it_keys = lt_keys
                                  CHANGING cs_line_json = <fs_line_json> ).
              ENDIF.

              IF ls_relations_last-levelv NE <fs_relations>-levelv.

                me->delete_data_body( EXPORTING  iv_parent_relation = <fs_relations>-tabname
                                                 it_data = it_data
*                                             is_line = <fs_line>
                                                 is_line = <fs_line_json>
                                      CHANGING   cs_line_json = <fs_line_json> ) .
              ENDIF.

              UNASSIGN <fs_key>.

              IF iv_parent_relation IS INITIAL.
                IF lv_max_records EQ gs_oc_obj-no_registros.
                  ASSIGN COMPONENT 'ONECONNECT-BODY' OF STRUCTURE cs_root TO <fs_result>.
                  <fs_result> = <fs_wa> .
*              ASSIGN <fs_wa> TO <fs_result>.
*              cs_body = <fs_result>.

                  APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.

                  <fs_json>  = zoncl_ui2_cl_json=>serialize(
                           data             = cs_root "<fs_root>
                           compress         = abap_false "abap_true
                           assoc_arrays     = abap_true
                           assoc_arrays_opt = abap_true
                           pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).

                  ASSIGN COMPONENT 'ONECONNECT-BODY-DATA' OF STRUCTURE cs_root TO <fs_result>.
                  CLEAR <fs_result>.

                  ASSIGN COMPONENT 'DATA' OF STRUCTURE <fs_wa> TO <fs_result>.
                  CLEAR <fs_result>.

                  CLEAR: lv_max_records.

                ENDIF.
              ENDIF.

            ENDLOOP.
          ENDIF.
        ENDLOOP.

        IF iv_parent_relation IS INITIAL.

*      <fs_wa> TO <fs_result>.
*      cs_body = <fs_result>.

          IF lv_max_records LT gs_oc_obj-no_registros.

            ASSIGN COMPONENT 'ONECONNECT-BODY' OF STRUCTURE cs_root TO <fs_result>.
            <fs_result> = <fs_wa> .

            APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.

            <fs_json>  = zoncl_ui2_cl_json=>serialize(
                     data             = cs_root "<fs_root>
                     compress         = abap_false "abap_true
                     assoc_arrays     = abap_true
                     assoc_arrays_opt = abap_true
                     pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).
          ENDIF.
        ENDIF.
      ENDIF.
    ENDMETHOD.


  METHOD delete_data_table.
    DATA: lv_tabname        TYPE string,
          lv_condense       TYPE string,
          lv_field          TYPE string,
          lv_tabnameddif    TYPE ddobjname,
          lv_keys           TYPE string,
          lv_keys_main      TYPE string,
          lv_keys_temp      TYPE string,
          lv_root           TYPE string,
          lt_dfies_tab      TYPE STANDARD TABLE OF  dfies,
          lt_fcat           TYPE lvc_t_fcat,
          dref_table        TYPE REF TO data,
          dref_table_root   TYPE REF TO data,
          dref_table_body   TYPE REF TO data,
          lt_keys           TYPE tty_where,
          iv_message_v1     TYPE  symsgv,
          lt_relations      TYPE STANDARD TABLE OF zonta_relations,
          lv_lines          TYPE sy-tabix,
          ls_relations_last TYPE zonta_relations,
          lo_data           TYPE REF TO data,
          lv_recordst       TYPE sy-tabix,
          lv_max_records    TYPE zonde_registrosn,
          lv_lenght         TYPE numc2,
*CECHAVARRIA 8/05/2025
          lv_tabnames       TYPE zonta_relations-tabname,
          lv_tabname_aux    TYPE dd27s-tabname,
*CECHAVARRIA 8/05/2025
          lv_pretty         TYPE string,
          lv_empty          TYPE string.


    FIELD-SYMBOLS: <fs_table>           TYPE STANDARD TABLE,
                   <fs_table1>          TYPE STANDARD TABLE,
                   <fs_body>            TYPE STANDARD TABLE,
                   <fs_metadata_root>   TYPE STANDARD TABLE,
                   <fs_relations>       TYPE zonta_relations,
                   <fs_root>            TYPE any,
                   <fs_oneconnect>      TYPE any,
                   <fs_properties>      TYPE any,
                   <fs_body_root>       TYPE any,
                   <fs_json>            TYPE any,
                   <fs_metadata>        TYPE any,
                   <fs_field_metadata>  TYPE any,
                   <fs_metadata_line>   TYPE any,
                   <fs_field>           TYPE any,
                   <fs_cdpos>           TYPE ty_cdpos,
                   <fs_key>             TYPE any,
                   <fs_key_main>        TYPE any,
                   <fs_keys_event>      TYPE LINE OF tty_where,
                   <fs_table_body_line> TYPE any,
                   <fs_table2>          TYPE STANDARD TABLE,
                   <fs_table_line>      TYPE any,
                   <fs_data>            TYPE any,
                   <fs_columns>         TYPE zonta_oc_col_all,
                   <fs_value_source>    TYPE any,
                   <fs_value_target>    TYPE any,
                   <fs_line_source>     TYPE any,
                   <fs_line>            TYPE any.

    IF NOT gt_cdpos IS INITIAL.
      CASE sy-xform.
        WHEN 'ZONFM_ONE_CONNECT_BATCH'.
          iv_message_v1 = '*** Batch Process TABLE***'.
        WHEN 'SWF_EVT_HANDLER_START_INTERNAL'.
          iv_message_v1 = '*** Event Process TABLE ***'.
*CECHAVARRIA 07/05/2025
        WHEN 'FM_BGMC_PROCESS'.
          iv_message_v1 = '*** Direct Process TABLE RAP BO***'.
*CECHAVARRIA 07/05/2025
        WHEN OTHERS.
          iv_message_v1 = '*** Direct Process TABLE***'.
      ENDCASE.


      me->append_slg1_log(
        EXPORTING
          iv_tabname    = space
*         iv_key        =
          iv_message_v1 = iv_message_v1
          iv_message_v2 = space
          iv_message_v3 = space
          iv_mestyp     = 'S' ).

      IF gv_instid IS INITIAL.
        CLEAR gt_json.
      ENDIF.

      lt_relations = gt_relations.

      SORT lt_relations BY sequence.
      DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING sequence.

      SORT lt_relations BY levelv.

      lv_lines = lines( lt_relations ).

*    DATA(ls_relations_last) = lt_relations[ lv_lines ].

      READ TABLE lt_relations INDEX lv_lines INTO ls_relations_last.


      LOOP AT lt_relations ASSIGNING <fs_relations>.

        IF <fs_relations>-parent_relation IS INITIAL.
          CLEAR gv_recordst_obj .
        ENDIF.

*        lv_root = 'ZON' && <fs_relations>-id && 'SCONNECT' && c_table.
*  CREATE DATA dref_table_root TYPE (lv_root).
        IF gs_oc_obj-data EQ abap_true.
          CREATE DATA dref_table_root TYPE ty_oneconnect_meta.
        ELSE.
          CREATE DATA dref_table_root TYPE ty_oneconnect.
        ENDIF.
        ASSIGN dref_table_root->* TO <fs_root>.

        ASSIGN COMPONENT 'ONECONNECT' OF STRUCTURE <fs_root> TO <fs_oneconnect>.

        ASSIGN COMPONENT 'PROPERTIES' OF STRUCTURE <fs_oneconnect> TO <fs_properties>.
        IF NOT gv_update IS INITIAL.
          gv_update = abap_false.
          gv_delete = abap_true.
        ENDIF.
        me->get_data_properties( CHANGING cs_properties = <fs_properties> ).

        ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_oneconnect> TO <fs_metadata_root>.

        ASSIGN COMPONENT 'BODY' OF STRUCTURE <fs_oneconnect> TO <fs_body_root>.

        lv_tabname = 'SEQ' && <fs_relations>-sequence.

        APPEND INITIAL LINE TO <fs_metadata_root> ASSIGNING <fs_metadata>.

        ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_metadata> TO <fs_field_metadata>.
        <fs_field_metadata> = lv_tabname.
        TRANSLATE <fs_field_metadata> TO LOWER CASE.

        ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_metadata> TO <fs_metadata_line>.

        ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_body_root> TO <fs_field>.

        <fs_field> = lv_tabname.
        TRANSLATE <fs_field> TO LOWER CASE.

        IF gv_table IS INITIAL.
          lv_tabname = 'DATA' && lv_tabname.
        ENDIF.

        lv_condense = lv_tabname.

*        ASSIGN COMPONENT lv_tabname OF STRUCTURE <fs_body_root> TO <fs_body>.
        ASSIGN COMPONENT 'DATA' OF STRUCTURE <fs_body_root> TO <fs_table_body_line> .

        me->get_data_by_table( EXPORTING iv_parent_relation = <fs_relations>-parent_relation
                                         iv_table           = <fs_relations>-tabname
                               IMPORTING et_fcat            = lt_fcat
*                                    et_data            = lo_data ).
                                         et_data            = <fs_table_body_line> ).

        ASSIGN <fs_table_body_line>->* TO <fs_body>.

        CLEAR lt_keys .

        me->get_key( EXPORTING iv_parent_relation = <fs_relations>-parent_relation
                               iv_tabname         = <fs_relations>-tabname
                     IMPORTING et_keys            = lt_keys
                               ev_key             = lv_keys
                               ev_key_main        = lv_keys_main ).


        me->set_metadata_node( EXPORTING it_fcat     = lt_fcat
                                         iv_tabname  = <fs_relations>-tabname
                               CHANGING  cs_metadata = <fs_metadata_line> ).

        me->get_data_by_table( EXPORTING iv_parent_relation = <fs_relations>-parent_relation
                                         iv_table           = <fs_relations>-tabname
                               IMPORTING et_fcat            = lt_fcat
                                         et_data            = lo_data ).

        ASSIGN lo_data->* TO <fs_line>.

        me->get_lenght_key(
          EXPORTING
            iv_tabname = <fs_relations>-tabname
            iv_parent  = <fs_relations>-parent_relation
          RECEIVING
            rv_lenght  = lv_lenght ).

*CECHAVARRIA 8/05/2025
        IF line_exists( gt_cdpos[ tabname = <fs_relations>-tabname ] ).
          lv_tabnames = <fs_relations>-tabname."*CECHAVARRIA 8/05/2025
        ELSE.
*Get relation CDS VIEW vs Table}
          lv_tabnames = <fs_relations>-tabname.
          DO.
            SELECT SINGLE dd27s_pivot~tabname
                    FROM dd27s AS dd27s_pivot
                  WHERE dd27s_pivot~viewname EQ @lv_tabnames
                 INTO @lv_tabname_aux.

            IF sy-subrc NE 0.
*            lv_tabnames = 'VBAK'.
              EXIT.
            ELSE.
              lv_tabnames = lv_tabname_aux.
            ENDIF.
          ENDDO.

        ENDIF.
*CECHAVARRIA 8/05/2025

        LOOP AT gt_cdpos ASSIGNING <fs_cdpos>
*CECHAVARRIA 8/05/2025
*                         WHERE tabname EQ <fs_relations>-tabname.
                           WHERE tabname EQ lv_tabnames.
*CECHAVARRIA 8/05/2025

          UNASSIGN <fs_line_source>.
          CREATE DATA dref_table TYPE (<fs_relations>-tabname).
          ASSIGN dref_table->* TO <fs_line_source>.

          <fs_line_source> = <fs_cdpos>-tabkey(lv_lenght).

          APPEND INITIAL LINE TO <fs_body> ASSIGNING <fs_table_body_line>.

*** Convert Exit
          me->convertion_exit( EXPORTING iv_tabname = <fs_relations>-tabname
                               CHANGING  cs_string  = <fs_table_body_line> ).

          LOOP AT gt_columns_all ASSIGNING <fs_columns> WHERE tabname EQ <fs_relations>-tabname.
            ASSIGN COMPONENT <fs_columns>-fldname OF STRUCTURE <fs_line_source> TO <fs_value_source>.
*            IF gv_fieldname IS INITIAL.
*              IF NOT <fs_columns>-alias_fldname IS INITIAL.
*                TRANSLATE <fs_columns>-alias_fldname TO UPPER CASE.
*                ASSIGN COMPONENT <fs_columns>-alias_fldname OF STRUCTURE <fs_table_body_line> TO <fs_value_target>.
*              ELSE.
*                ASSIGN COMPONENT <fs_columns>-fldname OF STRUCTURE <fs_table_body_line> TO <fs_value_target>.
*              ENDIF.
*            ELSE.
*            ASSIGN COMPONENT <fs_columns>-fldname OF STRUCTURE <fs_table_body_line> TO <fs_value_target>.
*            ENDIF.

*CECHAVARRIA 8/05/2025
*            IF sy-subrc NE 0.
            ASSIGN COMPONENT <fs_columns>-fldname OF STRUCTURE <fs_table_body_line> TO <fs_value_target>.
*            ENDIF.
*CECHAVARRIA 8/05/2025

            <fs_value_target> = <fs_value_source>.
          ENDLOOP.

          UNASSIGN <fs_key_main>."CECHAVARRIA 8/05/2025
          ASSIGN COMPONENT lv_keys_main OF STRUCTURE <fs_table_body_line> TO <fs_key_main>.

*CECHAVARRIA 8/05/2025
          IF sy-subrc NE 0.
            IF lv_keys_temp NE lv_keys_main.
              lv_keys_temp = lv_keys_main.
              lv_max_records = lv_max_records + 1.
            ENDIF.
          ELSE.
            IF lv_keys_temp NE <fs_key_main>.
              lv_keys_temp = <fs_key_main>.
              lv_max_records = lv_max_records + 1.
            ENDIF.
          ENDIF.
*CECHAVARRIA 8/05/2025

          IF <fs_relations>-parent_relation IS INITIAL.

            gv_recordst_obj = gv_recordst_obj + 1.

            ASSIGN COMPONENT 2 OF STRUCTURE <fs_table_body_line> TO <fs_key>.

            IF <fs_key> IS ASSIGNED.
              me->append_slg1_log( iv_tabname = <fs_relations>-tabname
                                   iv_mestyp  = 'S'
                                   iv_key     = <fs_key> ).
            ENDIF.
          ENDIF.

*** Fill Even ID
          IF gs_oc_obj-eventid  EQ abap_true OR
             gs_oc_obj-metadata EQ abap_true.

            IF <fs_key> IS ASSIGNED.

              APPEND INITIAL LINE TO lt_keys ASSIGNING <fs_keys_event>.
              <fs_keys_event>-line = <fs_key>.
            ENDIF.

            me->get_eventid( EXPORTING it_keys      = lt_keys
                             CHANGING  cs_line_json = <fs_table_body_line> ).
          ENDIF.


*        APPEND INITIAL LINE TO <fs_body> ASSIGNING <fs_table_body_line>.

*        MOVE-CORRESPONDING <fs_line> TO <fs_table_body_line>.

          ASSIGN COMPONENT 1 OF STRUCTURE <fs_table_body_line> TO <fs_field>.
          IF <fs_field> IS ASSIGNED.
            <fs_field>  = sy-mandt.
          ENDIF.

          UNASSIGN <fs_key> .

          IF lv_max_records EQ gs_oc_obj-no_registros.
            APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.

            <fs_json> = zoncl_ui2_cl_json=>serialize(
              data             = <fs_root>
              compress         = abap_false "abap_true
              assoc_arrays     = abap_true
              assoc_arrays_opt = abap_true
              pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).

            CLEAR: lv_max_records,
                   <fs_body>.
          ENDIF.

        ENDLOOP.

        IF sy-subrc NE 0.
          lv_empty = abap_true.
        ENDIF.

        IF lv_max_records LT gs_oc_obj-no_registros.
          APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.

          <fs_json> = zoncl_ui2_cl_json=>serialize(
            data             = <fs_root>
            compress         = abap_false "abap_true
            assoc_arrays     = abap_true
            assoc_arrays_opt = abap_true
            pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).
        ENDIF.

        TRANSLATE lv_condense TO LOWER CASE.

        IF lv_empty EQ abap_true.
          lv_pretty = '"seq'                  &&
                      <fs_relations>-sequence &&
                      '":[],'.

          lv_empty  = '"seq'                  &&
                      <fs_relations>-sequence &&
                      '":[*],'.
          REPLACE lv_pretty WITH lv_empty INTO <fs_json>.
          IF sy-subrc NE 0.
            lv_pretty = '"seq'                  &&
                        <fs_relations>-sequence &&
                        '":[]'.

            lv_empty  = '"seq'                &&
                      <fs_relations>-sequence &&
                      '":[*]'.

            REPLACE lv_pretty WITH lv_empty INTO <fs_json>.
            IF sy-subrc NE 0.
              lv_pretty = '"data' &&
                          '":[]'.

              lv_empty  = '"seq'                &&
                        <fs_relations>-sequence &&
                        '":[*]'.


              REPLACE lv_pretty WITH lv_empty INTO <fs_json>.
            ENDIF.
          ENDIF.

          lv_empty = abap_false.
        ENDIF.

        UNASSIGN <fs_root>.

      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD delete_json_ddic.

    DATA: lv_objname TYPE ddobjname,
          lv_objtype TYPE ddeutype,
          lv_tabix   TYPE sy-tabix,
          lv_subrc   TYPE sy-subrc,
          lv_object  TYPE string.

    FIELD-SYMBOLS: <fs_relations> TYPE zonta_relations,
                   <fs_delete>    TYPE ty_delete,
                   <fs_columns>   TYPE zonta_oc_col_all.

*** Create Body Structure
    me->get_relation( iv_domainv       = iv_domainv
                      iv_business_proc = iv_business_proc
                      iv_kdoc          = abap_false
                      iv_table         = abap_false
                      iv_ddic          = abap_true
                     ) .


    READ TABLE gt_relations INDEX 1
                            ASSIGNING <fs_relations> .

    APPEND INITIAL LINE TO gt_delete ASSIGNING <fs_delete>.
    <fs_delete>-objname = 'ZON' && <fs_relations>-id && 'SCONNECTKDOC'.
    <fs_delete>-objtype = 'S'.

    APPEND INITIAL LINE TO gt_delete ASSIGNING <fs_delete>.
    <fs_delete>-objname = 'ZON' && <fs_relations>-id && 'SCONNECTDETKDOC'.
    <fs_delete>-objtype = 'S'.

    APPEND INITIAL LINE TO gt_delete ASSIGNING <fs_delete>.
    <fs_delete>-objname = 'ZON' && <fs_relations>-id && 'SCONNECTDETTABL'.
    <fs_delete>-objtype = 'S'.

    APPEND INITIAL LINE TO gt_delete ASSIGNING <fs_delete>.
    <fs_delete>-objname = 'ZON' && <fs_relations>-id && 'SCONNECTTABL'.
    <fs_delete>-objtype = 'S'.

    APPEND INITIAL LINE TO gt_delete ASSIGNING <fs_delete>.
    <fs_delete>-objname = 'ZON' && <fs_relations>-id && 'SPROPERTIES'.
    <fs_delete>-objtype = 'S'.

    APPEND INITIAL LINE TO gt_delete ASSIGNING <fs_delete>.
    <fs_delete>-objname = 'ZON' && <fs_relations>-id && 'TTMETADATA'.
    <fs_delete>-objtype = 'A'.

    APPEND INITIAL LINE TO gt_delete ASSIGNING <fs_delete>.
    <fs_delete>-objname = 'ZON' && <fs_relations>-id && 'SMETADATA'.
    <fs_delete>-objtype = 'S'.

    APPEND INITIAL LINE TO gt_delete ASSIGNING <fs_delete>.
    <fs_delete>-objname = 'ZON' && <fs_relations>-id && 'TTMETADATADET'.
    <fs_delete>-objtype = 'A'.

    APPEND INITIAL LINE TO gt_delete ASSIGNING <fs_delete>.
    <fs_delete>-objname = 'ZON' && <fs_relations>-id && 'SMETADATADET'.
    <fs_delete>-objtype = 'S'.

    APPEND INITIAL LINE TO gt_delete ASSIGNING <fs_delete>.
    <fs_delete>-objname = 'ZON' && <fs_relations>-id && 'SBODYKDOC'.
    <fs_delete>-objtype = 'S'.

    APPEND INITIAL LINE TO gt_delete ASSIGNING <fs_delete>.
    <fs_delete>-objname = 'ZON' && <fs_relations>-id && 'SBODYTABL'.
    <fs_delete>-objtype = 'S'.


    SORT gt_relations BY id.

    LOOP AT gt_relations ASSIGNING <fs_relations>.

      READ TABLE gt_columns_all WITH KEY tabname       = <fs_relations>-tabname
                                         alias_tabname = <fs_relations>-alias_tabname
                                     ASSIGNING <fs_columns>.
      if <fs_columns> is NOT ASSIGNED.
         continue.
      endif.
      APPEND INITIAL LINE TO gt_delete ASSIGNING <fs_delete>.
      <fs_delete>-objname = 'ZON' && <fs_columns>-id_column && 'SSEQ' && <fs_relations>-sequence && 'TABLE'.
      <fs_delete>-objtype = 'S'.

      APPEND INITIAL LINE TO gt_delete ASSIGNING <fs_delete>.
      <fs_delete>-objname = 'ZON' && <fs_columns>-id_column && 'TTSEQ' && <fs_relations>-sequence && 'TABLE'.
      <fs_delete>-objtype = 'A'.

      APPEND INITIAL LINE TO gt_delete ASSIGNING <fs_delete>.
      <fs_delete>-objname = 'ZON' && <fs_columns>-id_column && 'TTSEQ' && <fs_relations>-sequence && c_table.
      <fs_delete>-objtype = 'A'.


      APPEND INITIAL LINE TO gt_delete ASSIGNING <fs_delete>.
      <fs_delete>-objname = 'ZON' && <fs_columns>-id_column && 'TTSEQ' && <fs_relations>-sequence.
      <fs_delete>-objtype = 'A'.

      APPEND INITIAL LINE TO gt_delete ASSIGNING <fs_delete>.
      <fs_delete>-objname = 'ZON' && <fs_columns>-id_column && 'SSEQ' && <fs_relations>-sequence && 'TABLE'.
      <fs_delete>-objtype = 'S'.

      APPEND INITIAL LINE TO gt_delete ASSIGNING <fs_delete>.
      <fs_delete>-objname = 'ZON' && <fs_columns>-id_column && 'SSEQ' && <fs_relations>-sequence && c_table.
      <fs_delete>-objtype = 'S'.

      APPEND INITIAL LINE TO gt_delete ASSIGNING <fs_delete>.
      <fs_delete>-objname = 'ZON' && <fs_columns>-id_column && 'SSEQ' && <fs_relations>-sequence.
      <fs_delete>-objtype = 'S'.

*** Delete old Structure version
      APPEND INITIAL LINE TO gt_delete ASSIGNING <fs_delete>.
      <fs_delete>-objname = 'ZON' && <fs_relations>-id && 'SSEQ' && <fs_relations>-sequence && 'TABLE'.
      <fs_delete>-objtype = 'S'.

      APPEND INITIAL LINE TO gt_delete ASSIGNING <fs_delete>.
      <fs_delete>-objname = 'ZON' && <fs_relations>-id && 'TTSEQ' && <fs_relations>-sequence && 'TABLE'.
      <fs_delete>-objtype = 'A'.

      APPEND INITIAL LINE TO gt_delete ASSIGNING <fs_delete>.
      <fs_delete>-objname = 'ZON' && <fs_relations>-id && 'TTSEQ' && <fs_relations>-sequence && c_table.
      <fs_delete>-objtype = 'A'.


      APPEND INITIAL LINE TO gt_delete ASSIGNING <fs_delete>.
      <fs_delete>-objname = 'ZON' && <fs_relations>-id && 'TTSEQ' && <fs_relations>-sequence.
      <fs_delete>-objtype = 'A'.

      APPEND INITIAL LINE TO gt_delete ASSIGNING <fs_delete>.
      <fs_delete>-objname = 'ZON' && <fs_relations>-id && 'SSEQ' && <fs_relations>-sequence && 'TABLE'.
      <fs_delete>-objtype = 'S'.

      APPEND INITIAL LINE TO gt_delete ASSIGNING <fs_delete>.
      <fs_delete>-objname = 'ZON' && <fs_relations>-id && 'SSEQ' && <fs_relations>-sequence && c_table.
      <fs_delete>-objtype = 'S'.

      APPEND INITIAL LINE TO gt_delete ASSIGNING <fs_delete>.
      <fs_delete>-objname = 'ZON' && <fs_relations>-id && 'SSEQ' && <fs_relations>-sequence.
      <fs_delete>-objtype = 'S'.

    ENDLOOP.

    DO 10 TIMES.
      LOOP AT gt_delete ASSIGNING <fs_delete>.
        lv_tabix = sy-tabix.

        me->delete_json_ddic_object( EXPORTING
                                      iv_objname = <fs_delete>-objname
                                      iv_objtype = <fs_delete>-objtype
                                      IMPORTING
                                       ev_subrc  = lv_subrc ).

        IF lv_subrc EQ 0.
          DELETE gt_delete INDEX lv_tabix.
        ENDIF.
      ENDLOOP.
      IF gt_delete IS INITIAL.
        EXIT.
      ENDIF.
    ENDDO.

*** Update Log
    me->update_slg1_log( it_log_ext = gt_log_ext ).
  ENDMETHOD.


METHOD DELETE_JSON_DDIC_OBJECT.
  DATA: lv_name       TYPE ddobjname,
        lv_message_v1 TYPE symsgv,
        lv_message_v2 TYPE symsgv,
        lv_message_v3 TYPE symsgv,
        lv_mestyp	    TYPE bapi_mtype VALUE 'S'.

  CALL FUNCTION 'RS_DD_DELETE_OBJ'
    EXPORTING
      no_ask               = abap_true
      objname              = iv_objname
      objtype              = iv_objtype
    CHANGING
      corrnum              = gv_korrnum
    EXCEPTIONS
      not_executed         = 1
      object_not_found     = 2
      object_not_specified = 3
      permission_failure   = 4
      dialog_needed        = 5
      OTHERS               = 6.
  IF sy-subrc <> 0.
    IF sy-subrc EQ 2.
      lv_message_v3 = 'Deleted success'.
      ev_subrc = 0.
    ELSE.
      lv_message_v3 = 'Error for deletion'.
      ev_subrc = sy-subrc.
    ENDIF.
  ELSE      .
    lv_message_v3 = 'Deleted success'.
    ev_subrc = sy-subrc.
  ENDIF.

  lv_name = iv_objname.

  lv_message_v1 = 'DDIC'.
  lv_message_v2 = lv_name.


  CALL METHOD me->append_slg1_log
    EXPORTING
      iv_tabname    = lv_name
*     iv_key        =
      iv_message_v1 = lv_message_v1
      iv_message_v2 = lv_message_v2
      iv_message_v3 = lv_message_v3
      iv_mestyp     = lv_mestyp.

ENDMETHOD.


  METHOD download_log_file.
    TYPES: BEGIN OF ty_log.
             INCLUDE   TYPE zonst_oc_log_ext.
             TYPES:   timestamp(27) TYPE c.
    TYPES : END OF ty_log.

    DATA: lv_path TYPE string,
          lv_tsl  TYPE timestampl,
*          lv_record TYPE string,
          lt_log  TYPE STANDARD TABLE OF ty_log.

    FIELD-SYMBOLS: <fs_log_ext> TYPE zonst_oc_log_ext,
                   <fs_log>     TYPE ty_log.

    GET TIME STAMP FIELD lv_tsl.

    lv_path =  gs_oc_obj-file_path     &&
               '/'                     &&
               gs_oc_obj-business_proc &&
               '.txt' .

    TRY.
        OPEN DATASET lv_path FOR APPENDING IN TEXT MODE ENCODING DEFAULT.

        LOOP AT gt_log_ext ASSIGNING <fs_log_ext>.
          APPEND INITIAL LINE TO lt_log ASSIGNING <fs_log>.
          MOVE-CORRESPONDING <fs_log_ext> TO <fs_log>.
          <fs_log>-timestamp = lv_tsl.
        ENDLOOP.

        LOOP AT lt_log ASSIGNING <fs_log>.
          TRANSFER <fs_log> TO lv_path .
        ENDLOOP.

        CLOSE DATASET lv_path.

        IF sy-subrc EQ 0.
          MESSAGE s000(fb) WITH text-e09
                                lv_path.
        ENDIF.
      CATCH cx_sy_file_open_mode.
        MESSAGE i202(cacsib_edt) WITH lv_path.
    ENDTRY.
  ENDMETHOD.


  METHOD execute_batch.
    DATA: ls_stdt_input  TYPE tbtcstrt,
          ls_stdt_output TYPE tbtcstrt,
          lv_id          TYPE char30.

    DATA: gv_number           TYPE tbtcjob-jobcount,
          gv_name             TYPE tbtcjob-jobname VALUE 'ONECONNECT_BATCH',
          gv_job_was_released TYPE btch0000-char1,
          gv_strtimmed        TYPE btch0000-char1,
          gv_uzeit            TYPE sy-uzeit.

    gv_uzeit = sy-uzeit.

    lv_id =  sy-datum && sy-uname && gv_uzeit.

    IF NOT gt_cond_tab IS INITIAL.
      EXPORT where = gt_cond_tab TO DATABASE zontconnectbatch(sc) ID lv_id .
    ENDIF.

    IF NOT gt_where IS INITIAL.
      EXPORT where = gt_where TO DATABASE zontconnectbatch(sc) ID lv_id .
    ENDIF.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.


    CALL FUNCTION 'BP_START_DATE_EDITOR'
      EXPORTING
        stdt_dialog                    = 'Y'
        stdt_input                     = ls_stdt_input
        stdt_opcode                    = 14
      IMPORTING
        stdt_output                    = ls_stdt_output
      EXCEPTIONS
        fcal_id_not_defined            = 1
        incomplete_last_startdate      = 2
        incomplete_startdate           = 3
        invalid_dialog_type            = 4
        invalid_eventid                = 5
        invalid_opcode                 = 6
        invalid_opmode_name            = 7
        invalid_periodbehaviour        = 8
        invalid_predecessor_jobname    = 9
        last_startdate_in_the_past     = 10
        no_period_data_given           = 11
        no_startdate_given             = 12
        period_and_predjob_no_way      = 13
        period_too_small_for_limit     = 14
        predecessor_jobname_not_unique = 15
        startdate_interval_too_large   = 16
        startdate_in_the_past          = 17
        startdate_is_a_holiday         = 18
        startdate_out_of_fcal_range    = 19
        stdt_before_holiday_in_past    = 20
        unknown_fcal_error_occured     = 21
        no_workday_nr_given            = 22
        invalid_workday_countdir       = 23
        invalid_workday_nr             = 24
        notbefore_stdt_missing         = 25
        workday_starttime_missing      = 26
        no_eventid_given               = 27
        OTHERS                         = 28.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    CASE ls_stdt_output-startdttyp.
      WHEN 'I'.
        gv_strtimmed = abap_true.
      WHEN OTHERS.
        gv_strtimmed = abap_false.
    ENDCASE.

    CALL FUNCTION 'JOB_OPEN'
      EXPORTING
        jobname          = gv_name
      IMPORTING
        jobcount         = gv_number
      EXCEPTIONS
        cant_create_job  = 1
        invalid_job_data = 2
        jobname_missing  = 3
        OTHERS           = 4.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.


    SUBMIT zonpg_oneconnect_batch
    WITH p_domain EQ gv_domainv
    WITH p_busine EQ gv_entity
    WITH p_kdoc   EQ gv_kdoc
    WITH p_table  EQ gv_table
    WITH p_dest   EQ gv_dest
    WITH p_uzeit  EQ gv_uzeit
    WITH p_anytab EQ iv_anytab
    WITH p_tabnam EQ iv_tabname
    VIA JOB gv_name NUMBER gv_number
    AND RETURN.


    CALL FUNCTION 'JOB_CLOSE'
      EXPORTING
*       AT_OPMODE               = ' '
*       AT_OPMODE_PERIODIC      = ' '
*       CALENDAR_ID             = CALENDARID
        event_id                = ls_stdt_output-eventid
        event_param             = ls_stdt_output-eventparm
        event_periodic          = ls_stdt_output-periodic
        jobcount                = gv_number
        jobname                 = gv_name
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
*       STARTDATE_RESTRICTION   = BTC_PROCESS_ALWAYS
        strtimmed               = gv_strtimmed
*       TARGETSYSTEM            = ' '
*       START_ON_WORKDAY_NOT_BEFORE       = SY-DATUM
*       START_ON_WORKDAY_NR     = 0
        workday_count_direction = ls_stdt_output-wdaycdir
*       RECIPIENT_OBJ           =
*       TARGETSERVER            = ' '
*       DONT_RELEASE            = ' '
*       TARGETGROUP             = ' '
*       DIRECT_START            =
*       INHERIT_RECIPIENT       =
*       INHERIT_TARGET          =
*       REGISTER_CHILD          = ABAP_FALSE
*       time_zone               = ls_stdt_output-tmzone
*       EMAIL_NOTIFICATION      =
      IMPORTING
        job_was_released        = gv_job_was_released
* CHANGING
*       RET                     =
      EXCEPTIONS
        cant_start_immediate    = 1
        invalid_startdate       = 2
        jobname_missing         = 3
        job_close_failed        = 4
        job_nosteps             = 5
        job_notex               = 6
        lock_failed             = 7
        invalid_target          = 8
        invalid_time_zone       = 9
        OTHERS                  = 10.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.


  ENDMETHOD.


  METHOD fieldname_json.
    DATA: lv_source TYPE string,
          lv_target TYPE string.

    FIELD-SYMBOLS: <fs_columns> TYPE zonta_oc_col_all .

    LOOP AT gt_columns_all ASSIGNING <fs_columns>.
      TRANSLATE <fs_columns>-fldname TO LOWER CASE.

      lv_source = '"' && <fs_columns>-fldname && '":'.
      lv_target = '"' && <fs_columns>-fldname && '":'.

      REPLACE ALL OCCURRENCES OF '\'   IN lv_target WITH '_'.
      REPLACE ALL OCCURRENCES OF '/'   IN lv_target WITH '_'.

      REPLACE ALL OCCURRENCES OF lv_source IN cv_json WITH lv_target.

    ENDLOOP.
  ENDMETHOD.


  METHOD get_database_data.
    CONSTANTS: lc_comilla   TYPE c LENGTH 1 VALUE ''''.

    DATA: lv_join          TYPE string,
          lv_fields        TYPE string,
          lv_del_where     TYPE string,
          lv_where         TYPE zonttrsdswhere,
          lo_table         TYPE REF TO data,
          lo_table_final   TYPE REF TO data,
          lo_table_for_all TYPE REF TO data,
          lt_relations     TYPE STANDARD TABLE OF zonta_relations,
          ls_relations     TYPE zonta_relations,
*CECHAVARRIA 03/06/2025
          lv_is_cds_entity TYPE abap_bool, "
          lt_fields        TYPE TABLE OF line,
*CECHAVARRIA 03/06/2025
          lv_tabname       TYPE string.

    FIELD-SYMBOLS: <fs_table>            TYPE ANY TABLE,
                   <fs_table_final>      TYPE STANDARD TABLE,
                   <fs_table_for_all>    TYPE STANDARD TABLE,
                   <fs_table_line>       TYPE any,
                   <fs_table_line_final> TYPE any,
                   <fs_tabname>          TYPE any.


    lo_table  = me->set_table( iv_add_tabname = abap_true ).

    ASSIGN lo_table->* TO <fs_table>.

    lo_table_final  = me->set_table( iv_add_tabname = abap_true ).

    ASSIGN lo_table_final->* TO <fs_table_final>.

    lo_table_for_all  = me->set_table( iv_add_tabname = abap_true ).

    ASSIGN lo_table_for_all->* TO <fs_table_for_all>.

    lt_relations = gt_relations.

    SORT lt_relations BY sequence.

    DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING sequence.

    LOOP AT lt_relations INTO ls_relations.

*CECHAVARRIA 03/06/2025
*      IF sy-tabix EQ 1.
        lv_is_cds_entity = me->is_cds_entity( ls_relations-tabname ).
*      ENDIF.
*CECHAVARRIA 03/06/2025

      lv_where = me->get_where( iv_tabname = ls_relations-tabname ).

*CECHAVARRIA 03/06/2025
      IF abap_false = lv_is_cds_entity.
        lv_fields = me->set_fields_new( iv_tabname = ls_relations-tabname ).

      ELSE.
        me->set_fields_in_table( EXPORTING iv_tabname = ls_relations-tabname
                                 IMPORTING et_fields  = lt_fields ).
      ENDIF.
*CECHAVARRIA 03/06/2025

      TRY.
          IF ls_relations-parent_relation IS INITIAL.
*CECHAVARRIA 03/06/2025
            IF abap_false = lv_is_cds_entity.
              SELECT (lv_fields)
                      INTO CORRESPONDING FIELDS OF TABLE <fs_table>
                      FROM (ls_relations-tabname)
                     WHERE (lv_where).
            ELSE.
*WITH PRIVILEGED ACCESS
*              cl_abap_dyn_prg=>
              SELECT (lt_fields)
                FROM (ls_relations-tabname)
               WHERE (lv_where)
                 INTO CORRESPONDING FIELDS OF TABLE @<fs_table>.


            ENDIF.
*CECHAVARRIA 03/06/2025

          ELSE.

            <fs_table_for_all> = <fs_table_final>.

            lv_tabname = lc_comilla                   &&
                         ls_relations-parent_relation &&
                         lc_comilla.

            CONCATENATE 'TABNAME NE'
                         lv_tabname
                         INTO lv_del_where
                         SEPARATED BY space.

            DELETE <fs_table_for_all> WHERE (lv_del_where).

            IF NOT <fs_table_for_all> IS INITIAL.
*CECHAVARRIA 03/06/2025
              IF abap_false = lv_is_cds_entity.
                SELECT (lv_fields)
                        INTO CORRESPONDING FIELDS OF TABLE <fs_table>
                        FROM (ls_relations-tabname)
                        FOR ALL ENTRIES IN <fs_table_for_all>
                        WHERE (lv_where).
              ELSE.

                SELECT (lt_fields) FROM (ls_relations-tabname)
    FOR ALL ENTRIES IN @<fs_table_for_all>
                 WHERE (lv_where)
                  INTO CORRESPONDING FIELDS OF TABLE @<fs_table>.
              ENDIF.
*CECHAVARRIA 03/06/2025

            ELSE.
              sy-subrc = 4.
            ENDIF.
          ENDIF.
        CATCH cx_sy_dynamic_osql_semantics." INTO DATA(lo_error).
*          DATA(lv_messag) = lo_error->get_longtext( ).
*          DATA(lv_message) = lo_error->get_text( ).
          IF gv_instid IS INITIAL.
            MESSAGE e000(fb) WITH 'Error - Parse data on SQL , check structures'.
          ENDIF.

          me->append_slg1_log(
            EXPORTING
              iv_tabname    = space
*             iv_key        =
              iv_message_v1 = 'Error - Parse data on SQL'
              iv_message_v2 = 'check structures'
              iv_message_v3 = space
              iv_mestyp     = 'E' ).

          me->update_slg1_log( it_log_ext = gt_log_ext ).

          RETURN.
      ENDTRY.

      IF sy-subrc EQ 0.
        LOOP AT <fs_table> ASSIGNING <fs_table_line>.
          APPEND INITIAL LINE TO <fs_table_final> ASSIGNING <fs_table_line_final>.
          MOVE-CORRESPONDING <fs_table_line> TO <fs_table_line_final>.

          ASSIGN COMPONENT 'TABNAME' OF STRUCTURE <fs_table_line_final> TO <fs_tabname>.
          <fs_tabname> = ls_relations-tabname.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

    rv_table = lo_table_final.

  ENDMETHOD.


  METHOD get_data_body.
    CONSTANTS: lc_comilla   TYPE c LENGTH 1 VALUE ''''.

    DATA: lv_tabname        TYPE string,
          lv_field          TYPE string,
          lv_tabnameddif    TYPE ddobjname,
          lv_keys           TYPE string,
          lv_keys_main      TYPE string,
          lv_keys_temp      TYPE string,
          lv_root           TYPE string,
          lt_dfies_tab      TYPE STANDARD TABLE OF  dfies,
          lt_keys           TYPE tty_where,
          iv_message_v1     TYPE  symsgv,
          lt_relations      TYPE STANDARD TABLE OF zonta_relations,
          ls_relations_last TYPE zonta_relations,
          ls_relations      TYPE zonta_relations,
          lv_lines          TYPE sy-tabix,
          lo_data           TYPE REF TO data,
          lv_max_records    TYPE zonde_registrosn,
          lt_columns        TYPE STANDARD TABLE OF zonta_oc_col_all,
          lv_del_where      TYPE string,
          lv_del_tabname    TYPE string.

    DATA : dref_table  TYPE REF TO data,
           dref_table1 TYPE REF TO data.


    FIELD-SYMBOLS: <fs_table>       TYPE STANDARD TABLE,
                   <fs_table1>      TYPE STANDARD TABLE,
                   <fs_table2>      TYPE STANDARD TABLE,
                   <fs_field>       TYPE any,
                   <fs_field1>      TYPE STANDARD TABLE,
                   <fs_wa>          TYPE any,
                   <fs_relations>   TYPE zonta_relations,
                   <fs_line>        TYPE any,
                   <fs_line_json>   TYPE any,
                   <fs_field_mandt> TYPE any,
                   <fs_key>         TYPE any,
                   <fs_keys_event>  TYPE LINE OF tty_where,
                   <fs_result>      TYPE any,
                   <fs_data>        TYPE any,
                   <fs_table_line>  TYPE any,
                   <fs_json>        TYPE any,
                   <fs_key_main>    TYPE any,
                   <fs_body>        TYPE any.

    IF iv_parent_relation IS INITIAL.
      CLEAR gv_recordst_obj.

      CASE sy-xform.
        WHEN 'ZONFM_ONE_CONNECT_BATCH'.
          iv_message_v1 = '*** Batch Process KDOC***'.
        WHEN 'SWF_EVT_HANDLER_START_INTERNAL'.
          iv_message_v1 = '*** Event Process KDOC ***'.
*CECHAVARRIA 07/05/2025
        WHEN 'FM_BGMC_PROCESS'.
          iv_message_v1 = '*** Direct Process KDOC RAP BO***'.
*CECHAVARRIA 07/05/2025
        WHEN OTHERS.
          iv_message_v1 = '*** Direct Process KDOC***'.
      ENDCASE.

      me->append_slg1_log(
        EXPORTING
          iv_tabname    = space
*       iv_key        =
          iv_message_v1 = iv_message_v1
          iv_message_v2 = space
          iv_message_v3 = space
          iv_mestyp     = 'S' ).
    ENDIF.

    lt_relations = gt_relations.

    SORT lt_relations BY sequence.
    DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING sequence.

    SORT lt_relations BY levelv.

    lv_lines = lines( lt_relations ).

    READ TABLE lt_relations INDEX lv_lines INTO ls_relations_last.

    IF iv_parent_relation IS INITIAL.

      READ TABLE lt_relations INDEX 1 INTO ls_relations.

      lv_root = 'ZON' && ls_relations-id && 'SBODY' && gv_messagetype.

      CREATE DATA dref_table TYPE (lv_root).
      ASSIGN dref_table->* TO <fs_wa>.
    ELSE.
      ASSIGN cs_line_json TO <fs_wa>.
    ENDIF.

    LOOP AT lt_relations ASSIGNING <fs_relations>
                         WHERE parent_relation EQ iv_parent_relation.

      CALL FUNCTION 'DDIF_FIELDINFO_GET'
        EXPORTING
          tabname        = <fs_relations>-tabname
        TABLES
          dfies_tab      = gt_dfies_tab
        EXCEPTIONS
          not_found      = 1
          internal_error = 2
          OTHERS         = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      CLEAR: lt_keys ,
             lv_keys.

      me->get_key( EXPORTING  iv_parent_relation = iv_parent_relation
                              iv_tabname         = <fs_relations>-tabname
                   IMPORTING  et_keys            = lt_keys
                               ev_key            = lv_keys
                               ev_key_main       = lv_keys_main ).

      IF iv_parent_relation IS INITIAL.
        lv_tabname = 'DATA'.
      ELSE.
*        lv_tabname = <fs_relations>-alias_tabname && '-DATA'.
        lv_tabname = 'SEQ' && <fs_relations>-sequence && '-DATA'.
      ENDIF.

      me->get_data_by_table_data( EXPORTING
                                  iv_parent_relation = iv_parent_relation
                                  iv_table           = <fs_relations>-tabname
                                  IMPORTING
                                   et_data           = lo_data ).

      IF NOT lo_data IS INITIAL.
        ASSIGN lo_data->* TO <fs_table>.

        ASSIGN it_data TO <fs_table2>.

        lt_columns = gt_columns_all.
        DELETE lt_columns WHERE tabname NE <fs_relations>-tabname.

        lv_del_tabname = lc_comilla             &&
                         <fs_relations>-tabname &&
                         lc_comilla.

        CONCATENATE 'TABNAME EQ'
                    lv_del_tabname
                    INTO lv_del_where
                    SEPARATED BY space.

        LOOP AT <fs_table2> ASSIGNING <fs_data> WHERE (lv_del_where) .
          APPEND INITIAL LINE TO <fs_table> ASSIGNING <fs_table_line>.
*          MOVE-CORRESPONDING <fs_data> TO <fs_table_line> .
          me->assign_component_table(
            EXPORTING
              is_source    = <fs_data>
              is_relations = <fs_relations>
              iv_alias     = gv_alias
              it_columns   = lt_columns
            CHANGING
              cs_target    = <fs_table_line>
              ).
        ENDLOOP.

        ASSIGN COMPONENT lv_tabname OF STRUCTURE <fs_wa> TO <fs_table1>.

        ASSIGN <fs_relations>-alias_tabname TO <fs_field>.

        IF iv_parent_relation IS INITIAL.
          lv_field = 'TABLE'.
        ELSE.
*          lv_field = <fs_relations>-alias_tabname && '-TABLE'.
          lv_field = 'SEQ' && <fs_relations>-sequence && '-TABLE'.
        ENDIF.

        ASSIGN COMPONENT lv_field OF STRUCTURE <fs_wa> TO <fs_field>.
*        <fs_field> = <fs_relations>-alias_tabname.
        <fs_field> = 'SEQ' && <fs_relations>-sequence.
        TRANSLATE <fs_field> TO LOWER CASE.

        SORT <fs_table>.
        DELETE ADJACENT DUPLICATES FROM <fs_table>.

        LOOP AT <fs_table> ASSIGNING <fs_line>
                           WHERE (lv_keys).
          APPEND INITIAL LINE TO <fs_table1> ASSIGNING <fs_line_json>.
          MOVE-CORRESPONDING <fs_line> TO <fs_line_json>.

*** Convert Exit
          me->convertion_exit( EXPORTING iv_tabname = <fs_relations>-tabname
                               CHANGING  cs_string  = <fs_line_json> ).

          ASSIGN COMPONENT 1  OF STRUCTURE <fs_line_json> TO <fs_field_mandt>.
          IF <fs_field_mandt> IS ASSIGNED.
            <fs_field_mandt> = sy-mandt.
          ENDIF.

          IF iv_parent_relation IS INITIAL.

            CLEAR gv_event_id.

            gv_recordst_obj = gv_recordst_obj + 1.

            ASSIGN COMPONENT 2 OF STRUCTURE <fs_line> TO <fs_key>.

            IF <fs_key> IS ASSIGNED.
              me->append_slg1_log( iv_mestyp = 'S'
                                   iv_tabname = <fs_relations>-tabname
                                   iv_key     = <fs_key> ).
            ENDIF.

            ASSIGN COMPONENT lv_keys_main OF STRUCTURE <fs_line> TO <fs_key_main>.

            IF lv_keys_temp NE <fs_key_main>.
              lv_keys_temp   = <fs_key_main>.
              lv_max_records = lv_max_records + 1.
            ENDIF.

          ENDIF.

*** Fill Even ID
          IF gs_oc_obj-eventid  EQ abap_true OR
             gs_oc_obj-metadata EQ abap_true.
            IF <fs_key> IS ASSIGNED.
              APPEND INITIAL LINE TO lt_keys ASSIGNING <fs_keys_event>.
              IF <fs_key> IS NOT INITIAL."CECHAVARRIA 10/07/2025
                <fs_keys_event>-line = <fs_key>.
              ENDIF."CECHAVARRIA 10/07/2025
            ENDIF.

            me->get_eventid(  EXPORTING it_keys = lt_keys
                              CHANGING cs_line_json = <fs_line_json> ).
          ENDIF.

          IF ls_relations_last-levelv NE <fs_relations>-levelv.

            me->get_data_body( EXPORTING  iv_parent_relation = <fs_relations>-tabname
                                          it_data = it_data
                                          is_line = <fs_line>
                               CHANGING   cs_line_json = <fs_line_json> ) .
          ENDIF.

          UNASSIGN <fs_key>.

          IF iv_parent_relation IS INITIAL.
            IF lv_max_records EQ gs_oc_obj-no_registros.
              ASSIGN COMPONENT 'ONECONNECT-BODY' OF STRUCTURE cs_root TO <fs_result>.
              <fs_result> = <fs_wa> .
*              ASSIGN <fs_wa> TO <fs_result>.
*              cs_body = <fs_result>.

              APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.

              <fs_json>  = zoncl_ui2_cl_json=>serialize(
                       data             = cs_root "<fs_root>
                       compress         = abap_false "abap_true
                       assoc_arrays     = abap_true
                       assoc_arrays_opt = abap_true
                       pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).

              ASSIGN COMPONENT 'ONECONNECT-BODY-DATA' OF STRUCTURE cs_root TO <fs_result>.
              CLEAR <fs_result>.

              ASSIGN COMPONENT 'DATA' OF STRUCTURE <fs_wa> TO <fs_result>.
              CLEAR <fs_result>.

              CLEAR: lv_max_records.

            ENDIF.
          ENDIF.

        ENDLOOP.
      ENDIF.
    ENDLOOP.

    IF iv_parent_relation IS INITIAL.

*      <fs_wa> TO <fs_result>.
*      cs_body = <fs_result>.

      IF lv_max_records LT gs_oc_obj-no_registros.

        ASSIGN COMPONENT 'ONECONNECT-BODY' OF STRUCTURE cs_root TO <fs_result>.
        <fs_result> = <fs_wa> .

        APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.

        <fs_json>  = zoncl_ui2_cl_json=>serialize(
                 data             = cs_root "<fs_root>
                 compress         = abap_false "abap_true
                 assoc_arrays     = abap_true
                 assoc_arrays_opt = abap_true
                 pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD get_data_by_table.
    DATA : fname TYPE string.
    DATA : gv_pos1 TYPE i.
    DATA : gw_dyn_fcat      TYPE lvc_s_fcat,
           gt_dyn_fcat      TYPE lvc_t_fcat,
           gt_dyn_fcat_json TYPE lvc_t_fcat,
           lt_columns       TYPE STANDARD TABLE OF zonta_oc_col_all,
           lv_field         TYPE dfies-fieldname,
           lt_components    TYPE abap_component_tab. "++DB

    DATA: lt_dfies_tab       TYPE STANDARD TABLE OF  dfies,
          lv_parent_relation TYPE zonde_parentrel.

    FIELD-SYMBOLS: <fs_relations>     TYPE zonta_relations,
                   <fs_dfies_tab_add> TYPE dfies,
                   <fs_columns>       TYPE zonta_oc_col_all,
                   <fs_dfies_tab>     TYPE dfies,
                   <fs_component>     LIKE LINE OF lt_components. "++DB

***** Set Catalog
    lv_parent_relation = iv_parent_relation.
    IF lv_parent_relation IS INITIAL.
      lv_parent_relation = iv_table.
    ENDIF.

    LOOP AT gt_relations ASSIGNING <fs_relations>
*                         WHERE parent_relation EQ lv_parent_relation.
                         WHERE tabname EQ iv_table.

*      IF NOT line_exists( gt_dyn_fcat[ fieldname = <fs_relations>-field_main ] ).
      READ TABLE gt_dfies_tab_cat WITH KEY tabname  = <fs_relations>-tabname
                                          fieldname = <fs_relations>-field_main
                                          ASSIGNING <fs_dfies_tab_add>.
      IF sy-subrc EQ 0.
        gv_pos1 = gv_pos1 + 1.

        gw_dyn_fcat-fieldname = <fs_dfies_tab_add>-fieldname.
        gw_dyn_fcat-tabname   = <fs_dfies_tab_add>-tabname.
        gw_dyn_fcat-coltext   = <fs_dfies_tab_add>-scrtext_l.
        gw_dyn_fcat-col_pos   = <fs_dfies_tab_add>-position. "gv_pos1.
        gw_dyn_fcat-key       = abap_true.
        gw_dyn_fcat-datatype  = <fs_dfies_tab_add>-datatype.

        APPEND gw_dyn_fcat TO gt_dyn_fcat.
*          CLEAR gw_dyn_fcat.
      ENDIF.

*      IF NOT line_exists( gt_dyn_fcat_json[ fieldname = <fs_relations>-field_main
*                                             tabname   = <fs_relations>-tabname ] ).
      READ TABLE gt_dyn_fcat_json WITH KEY fieldname = <fs_relations>-field_main
                                           tabname   = <fs_relations>-tabname
                                           TRANSPORTING NO FIELDS.
      IF sy-subrc NE 0.
        APPEND gw_dyn_fcat TO gt_dyn_fcat_json.
      ENDIF.

      CLEAR gw_dyn_fcat.
*      ENDIF.
    ENDLOOP.

    lt_columns = gt_columns_all.

    DELETE lt_columns WHERE tabname         NE iv_table.

    LOOP AT lt_columns ASSIGNING <fs_columns>.

*      IF NOT line_exists( gt_dyn_fcat[ fieldname = <fs_columns>-fldname ] ).
      TRANSLATE <fs_columns>-fldname TO UPPER CASE.

      READ TABLE gt_dfies_tab_cat WITH KEY tabname   = <fs_columns>-tabname
                                           fieldname = <fs_columns>-fldname
                                           ASSIGNING <fs_dfies_tab_add>.
      IF sy-subrc EQ 0.
        gv_pos1 = gv_pos1 + 1.

        gw_dyn_fcat-fieldname = <fs_dfies_tab_add>-fieldname.
        gw_dyn_fcat-tabname   = <fs_dfies_tab_add>-tabname.
        gw_dyn_fcat-coltext   = <fs_columns>-description_field.  "FR |4.04.2025 <fs_dfies_tab_add>-scrtext_l.
        gw_dyn_fcat-col_pos   = <fs_dfies_tab_add>-position. "gv_pos1.
        gw_dyn_fcat-key       = <fs_dfies_tab_add>-keyflag.
        gw_dyn_fcat-datatype  = <fs_dfies_tab_add>-datatype.
*        IF NOT line_exists( gt_dyn_fcat[ fieldname = <fs_columns>-fldname ] ).
        READ TABLE  gt_dyn_fcat WITH KEY fieldname = <fs_columns>-fldname
                                TRANSPORTING NO FIELDS.
        IF sy-subrc NE 0.
          APPEND gw_dyn_fcat TO gt_dyn_fcat.
*          CLEAR gw_dyn_fcat.
        ENDIF.

*        IF NOT line_exists( gt_dyn_fcat_json[ fieldname = <fs_columns>-fldname
*                                              tabname   = <fs_columns>-tabname ] ).
        READ TABLE gt_dyn_fcat_json WITH KEY fieldname = <fs_columns>-fldname
                                             tabname   = <fs_columns>-tabname
                                             TRANSPORTING NO FIELDS.
        IF sy-subrc NE 0.
          APPEND gw_dyn_fcat TO gt_dyn_fcat_json.
        ENDIF.

        CLEAR gw_dyn_fcat.
      ENDIF.
    ENDLOOP.
    IF sy-subrc NE 0.
      LOOP AT gt_dfies_tab_cat ASSIGNING <fs_dfies_tab_add>
                               WHERE tabname EQ iv_table.

*        IF NOT line_exists( gt_dyn_fcat[ fieldname = <fs_dfies_tab_add>-fieldname ] ).
        READ TABLE  gt_dyn_fcat WITH KEY fieldname = <fs_dfies_tab_add>-fieldname
                                TRANSPORTING NO FIELDS.
        IF sy-subrc NE 0.
          gv_pos1 = gv_pos1 + 1.

          gw_dyn_fcat-fieldname = <fs_dfies_tab_add>-fieldname.
          gw_dyn_fcat-tabname   = <fs_dfies_tab_add>-tabname.
          gw_dyn_fcat-coltext   = <fs_dfies_tab_add>-scrtext_l.
          gw_dyn_fcat-col_pos   = <fs_dfies_tab_add>-position ."gv_pos1.
          gw_dyn_fcat-key       = <fs_dfies_tab_add>-keyflag.
          gw_dyn_fcat-datatype  = <fs_dfies_tab_add>-datatype.
          APPEND gw_dyn_fcat TO gt_dyn_fcat.

*          IF NOT line_exists( gt_dyn_fcat_json[ fieldname = <fs_dfies_tab_add>-fieldname
*                                                tabname   = <fs_dfies_tab_add>-tabname ] ).
          READ TABLE gt_dyn_fcat_json WITH KEY fieldname = <fs_dfies_tab_add>-fieldname
                                               tabname   = <fs_dfies_tab_add>-tabname
                                               TRANSPORTING NO FIELDS.
          IF sy-subrc NE 0.
            APPEND gw_dyn_fcat TO gt_dyn_fcat_json.
          ENDIF.

          CLEAR gw_dyn_fcat.
        ENDIF.
      ENDLOOP.
    ENDIF.

** Start Add Event id fields
    IF gs_oc_obj-eventid  EQ abap_true OR
       gs_oc_obj-metadata EQ abap_true.

      CALL FUNCTION 'DDIF_FIELDINFO_GET'
        EXPORTING
          tabname        = 'ZONST_OC_EVENTID'
        TABLES
          dfies_tab      = lt_dfies_tab
        EXCEPTIONS
          not_found      = 1
          internal_error = 2
          OTHERS         = 3.
      IF sy-subrc EQ 0.
        IF gs_oc_obj-eventid  EQ abap_false.
          DELETE lt_dfies_tab WHERE fieldname EQ 'OBJECTID'
                                 OR fieldname EQ 'EVENTID'.

        ENDIF.

        IF gs_oc_obj-metadata EQ abap_false.
          DELETE lt_dfies_tab WHERE fieldname(03) EQ 'TAG'.
        ENDIF.

        APPEND LINES OF lt_dfies_tab TO gt_dfies_tab_cat.
      ENDIF.

      LOOP AT lt_dfies_tab ASSIGNING <fs_dfies_tab>
                             WHERE fieldname NE 'MANDT'.

*        IF NOT line_exists( gt_dyn_fcat[ fieldname = <fs_dfies_tab>-fieldname ] ).
        READ TABLE gt_dyn_fcat WITH KEY fieldname = <fs_dfies_tab>-fieldname
                               TRANSPORTING NO FIELDS.
        IF sy-subrc NE 0.
          lv_field = <fs_dfies_tab>-fieldname.
        ELSE.
          CONTINUE.
        ENDIF.

        READ TABLE gt_dfies_tab_cat WITH KEY tabname   = <fs_dfies_tab>-tabname
                                             fieldname = <fs_dfies_tab>-fieldname
                                       ASSIGNING <fs_dfies_tab_add>.
        IF sy-subrc EQ 0.
*          gv_pos = gv_pos + 1.

          gw_dyn_fcat-fieldname = <fs_dfies_tab_add>-fieldname.
          gw_dyn_fcat-tabname   = <fs_dfies_tab_add>-tabname.
          gw_dyn_fcat-coltext   = <fs_dfies_tab_add>-scrtext_l.
          gw_dyn_fcat-col_pos   = <fs_dfies_tab>-position. "gv_pos.
          gw_dyn_fcat-key       = <fs_dfies_tab_add>-keyflag.
          gw_dyn_fcat-datatype  = <fs_dfies_tab>-datatype.
          APPEND gw_dyn_fcat TO gt_dyn_fcat.

*          IF NOT line_exists( gt_dyn_fcat_json[ fieldname = <fs_dfies_tab_add>-fieldname
*                                                tabname   = <fs_dfies_tab_add>-tabname ] ).
          READ TABLE gt_dyn_fcat_json WITH KEY  fieldname = <fs_dfies_tab_add>-fieldname
                                                tabname   = <fs_dfies_tab_add>-tabname
                                                TRANSPORTING NO FIELDS.
          IF sy-subrc NE 0.
            APPEND gw_dyn_fcat TO gt_dyn_fcat_json.
          ENDIF.

          CLEAR gw_dyn_fcat.
        ENDIF.
      ENDLOOP.

    ENDIF.

** End Add Event id fields

**** Sete dynamic table

    LOOP AT gt_relations ASSIGNING <fs_relations>
                         WHERE tabname EQ iv_table.
      READ TABLE lt_columns WITH KEY tabname        = <fs_relations>-tabname
                                     alias_tabname  = <fs_relations>-alias_tabname
                                     INTO <fs_columns>.
*      IF <fs_relations>-alias_tabname IS INITIAL.
*        <fs_relations>-alias_tabname = <fs_relations>-tabname.
*      ENDIF.
*      fname = 'ZON' && <fs_relations>-id && 'TT' && <fs_relations>-alias_tabname.
*      fname = 'ZON' && <fs_relations>-id && 'TT' && 'SEQ' && <fs_relations>-sequence.
      fname = 'ZON' && <fs_columns>-id_column && 'TT' && 'SEQ' && <fs_relations>-sequence.

    ENDLOOP.

* Begin of insert DB
*    BREAK frdev2.
* If ALIAS will be used, then create correct structure
    IF gv_alias = abap_true.
      DATA: "go_tdescr TYPE REF TO cl_abap_tabledescr,
        go_sdescr    TYPE REF TO cl_abap_structdescr,
        cl_wwarea    TYPE REF TO cl_abap_typedescr,
        lv_name      TYPE string,
        lv_temptable TYPE string.

* create fieldcat with Alias if needed
      CLEAR go_tdescr.

*******        SORT lt_columns BY tabname fldname.
      SORT lt_columns BY positionf.

      LOOP AT lt_columns ASSIGNING <fs_columns>.
        LOOP AT gt_dyn_fcat_json INTO gw_dyn_fcat WHERE tabname = <fs_columns>-tabname
                                                    AND fieldname = <fs_columns>-fldname.
          APPEND INITIAL LINE TO lt_components ASSIGNING <fs_component>.
          lv_temptable = <fs_columns>-tabname.
          IF sy-subrc = 0.
            <fs_component>-name =  <fs_columns>-alias_fldname.

          ELSE.
            <fs_component>-name =  gw_dyn_fcat-fieldname.
          ENDIF.
          CONCATENATE gw_dyn_fcat-tabname '-' gw_dyn_fcat-fieldname  INTO lv_name.
          CALL METHOD cl_abap_elemdescr=>describe_by_name
            EXPORTING
              p_name         = lv_name
            RECEIVING
              p_descr_ref    = cl_wwarea
            EXCEPTIONS
              type_not_found = 1
              OTHERS         = 2.
          IF sy-subrc IS INITIAL.
            <fs_component>-type ?= cl_wwarea.
          ENDIF.

        ENDLOOP.
      ENDLOOP.


      LOOP AT gt_dyn_fcat_json INTO gw_dyn_fcat WHERE tabname NE lv_temptable.
        APPEND INITIAL LINE TO lt_components ASSIGNING <fs_component>.
        READ TABLE lt_columns ASSIGNING <fs_columns> WITH KEY tabname = gw_dyn_fcat-tabname
                                                      fldname = gw_dyn_fcat-fieldname BINARY SEARCH.
*                                                           fldname = gw_dyn_fcat-alias_fldname BINARY SEARCH.
        IF sy-subrc = 0.
          <fs_component>-name =  <fs_columns>-alias_fldname.

        ELSE.
          <fs_component>-name =  gw_dyn_fcat-fieldname.
        ENDIF.
        CONCATENATE gw_dyn_fcat-tabname '-' gw_dyn_fcat-fieldname  INTO lv_name.
        CALL METHOD cl_abap_elemdescr=>describe_by_name
          EXPORTING
            p_name         = lv_name
          RECEIVING
            p_descr_ref    = cl_wwarea
          EXCEPTIONS
            type_not_found = 1
            OTHERS         = 2.
        IF sy-subrc IS INITIAL.
          <fs_component>-type ?= cl_wwarea.
        ENDIF.
      ENDLOOP.

      DELETE lt_components WHERE name IS INITIAL OR type IS INITIAL.

      go_sdescr  = cl_abap_structdescr=>create( lt_components ).
      go_tdescr  = cl_abap_tabledescr=>create( go_sdescr ).

    ENDIF.
* End of insert DB


* Create a dynamic internal table with this structure.
    DATA : gt_dyn_table  TYPE REF TO data.

    FIELD-SYMBOLS: <gfs_dyn_table> TYPE STANDARD TABLE.
*    BREAK frdev2.
* Begin of insert DB
    IF gv_alias = abap_true.
      CREATE DATA gt_dyn_table TYPE HANDLE go_tdescr.
    ELSE.
* End of insert DB
      CREATE DATA gt_dyn_table TYPE (fname).
    ENDIF. "++DB

    ASSIGN gt_dyn_table->* TO <gfs_dyn_table>.

    et_data = gt_dyn_table.

    SORT gt_dyn_fcat_json BY tabname col_pos.

    et_fcat = gt_dyn_fcat_json.

  ENDMETHOD.


  METHOD get_data_by_table_data.
    DATA : fname TYPE ttypename.
    DATA : gv_pos1 TYPE i.
    DATA : gw_dyn_fcat        TYPE lvc_s_fcat,
           gt_dyn_fcat        TYPE lvc_t_fcat,
           gt_dyn_fcat_json   TYPE lvc_t_fcat,
           lv_parent_relation	TYPE zonde_parentrel.

    FIELD-SYMBOLS: <fs_relations> TYPE zonta_relations,
                   <fs_columns>   TYPE zonta_oc_col_all.

    lv_parent_relation = iv_parent_relation.
    IF lv_parent_relation IS INITIAL.
      lv_parent_relation = iv_table.
    ENDIF.

    LOOP AT gt_relations ASSIGNING <fs_relations>
                         WHERE tabname EQ iv_table.
*      IF <fs_relations>-alias_tabname IS INITIAL.
*        <fs_relations>-alias_tabname = <fs_relations>-tabname.
*      ENDIF.
*      fname = 'ZON' && <fs_relations>-id && 'TT' && <fs_relations>-alias_tabname.
      READ TABLE gt_columns_all WITH KEY tabname       = <fs_relations>-tabname
                                         alias_tabname = <fs_relations>-alias_tabname
                                     ASSIGNING <fs_columns>.

*      fname = 'ZON' && <fs_relations>-id && 'TT' && 'SEQ' && <fs_relations>-sequence.
      fname = 'ZON' && <fs_columns>-id_column && 'TT' && 'SEQ' && <fs_relations>-sequence.
    ENDLOOP.


* Create a dynamic internal table with this structure.
    DATA : gt_dyn_table  TYPE REF TO data.



    FIELD-SYMBOLS: <gfs_dyn_table> TYPE STANDARD TABLE.

    CREATE DATA gt_dyn_table TYPE (fname).

    ASSIGN gt_dyn_table->* TO <gfs_dyn_table>.

    et_data = gt_dyn_table.


  ENDMETHOD.


  METHOD get_data_kdoc.
    DATA : dref_table      TYPE REF TO data,
           dref_table_body TYPE REF TO data,
           lv_root         TYPE string,
           e_size          TYPE zonde_oc_num30,
           e_records       TYPE zonde_oc_num30,
           lv_response     TYPE string,
           lv_return       TYPE string,
           lv_where        TYPE tty_where,
           i_dest          TYPE rfcdest VALUE 'ONIBEX_KDOCS',
           ls_relations    TYPE zonta_relations,
           lv_keys_main    TYPE string,
           lv_keys_temp    TYPE string.

    FIELD-SYMBOLS: <fs_root>       TYPE any,
                   <fs_oneconnect> TYPE any,
                   <fs_properties> TYPE any,
                   <fs_metadata>   TYPE any,
                   <fs_body>       TYPE any.

    CLEAR gt_json.

    READ TABLE gt_relations INDEX 1 INTO ls_relations.

    lv_root = 'ZON' && ls_relations-id && 'SCONNECT' && c_kdoc.

    CREATE DATA dref_table TYPE (lv_root).
    ASSIGN dref_table->* TO <fs_root>.

    ASSIGN COMPONENT 'ONECONNECT' OF STRUCTURE <fs_root> TO <fs_oneconnect>.

    ASSIGN COMPONENT 'PROPERTIES' OF STRUCTURE <fs_oneconnect> TO <fs_properties>.
    me->get_data_properties( CHANGING cs_properties = <fs_properties> ).

    ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_oneconnect> TO <fs_metadata>.
    me->get_data_metadata( CHANGING cs_metadata = <fs_metadata> ).

    ASSIGN COMPONENT 'BODY' OF STRUCTURE <fs_oneconnect> TO <fs_body>.

    IF gv_delete EQ abap_true.
      me->delete_data_body( EXPORTING iv_parent_relation = space
                                      it_data            = it_data "<fs_table>
                            CHANGING  cs_body            = <fs_body>
                                      cs_root            = <fs_root> ).
    ELSE.
      me->get_data_body( EXPORTING iv_parent_relation = space
                                   it_data            = it_data "<fs_table>
                         CHANGING  cs_body            = <fs_body>
                                   cs_root            = <fs_root> ).
    ENDIF.

    LOOP AT gt_json INTO gv_json.

      me->pretty_json( EXPORTING iv_mode = c_kdoc
                       CHANGING  cv_json = gv_json
                               ).

      me->send_json_http_con(
        EXPORTING
          i_dest     = gv_dest
        IMPORTING
          e_return   = lv_return
          e_size     = e_size
          e_records  = e_records
*                        receiving
          e_response = lv_response ).

      gv_sizet    = e_size.

      gv_recordst = gv_recordst + 1.
    ENDLOOP.

    me->send_json_result( ).

    me->update_slg1_log( it_log_ext = gt_log_ext ).

    CLEAR gv_sizet.
    CLEAR gv_recordst.
  ENDMETHOD.


  METHOD GET_DATA_METADATA.
    DATA: lt_fcat    TYPE lvc_t_fcat,
          lt_relations TYPE STANDARD TABLE OF zonta_relations,
          lv_tabname TYPE string,
          lo_data TYPE REF TO data.

    FIELD-SYMBOLS: <fs_metadata_chg> TYPE STANDARD TABLE,
                   <fs_relations> TYPE zonta_relations,
                   <fs_metadata> TYPE any,
                   <fs_table> TYPE any,
                   <fs_metadata_line> TYPE any.

    ASSIGN cs_metadata TO <fs_metadata_chg> .

    lt_relations = gt_relations.

    SORT lt_relations BY sequence.

    DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING sequence.

    LOOP AT lt_relations ASSIGNING <fs_relations>.

*      IF NOT <fs_relations>-alias_tabname IS INITIAL.
*        lv_tabname = <fs_relations>-alias_tabname.
*      ELSE.
*        lv_tabname = <fs_relations>-tabname.
*      ENDIF.

      lv_tabname = 'SEQ' && <fs_relations>-sequence.

      APPEND INITIAL LINE TO <fs_metadata_chg> ASSIGNING <fs_metadata>.

      ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_metadata> TO <fs_table>.
      <fs_table> = lv_tabname.
      TRANSLATE <fs_table> TO LOWER CASE.

      ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_metadata> TO <fs_metadata_line>.

      me->get_data_by_table( EXPORTING
                                iv_parent_relation = <fs_relations>-parent_relation
                                iv_table           = <fs_relations>-tabname
                             IMPORTING
                                 et_fcat           = lt_fcat
                                 et_data           = lo_data ).

      me->set_metadata_node( EXPORTING
                                it_fcat    = lt_fcat
                                iv_tabname = <fs_relations>-tabname
                             CHANGING
                                cs_metadata = <fs_metadata_line> ).

    ENDLOOP.

  ENDMETHOD.


  METHOD get_data_properties.

    DATA : dref_table   TYPE REF TO data,
           lv_root      TYPE string,
           ls_relations TYPE zonta_relations.

    FIELD-SYMBOLS: <fs>            TYPE any,
                   <fs_properties> TYPE any.

    IF NOT gv_kdoc IS INITIAL.
      gv_messagetype = c_kdoc.
    ELSE.
      gv_messagetype = c_table.
    ENDIF.

    READ TABLE gt_relations INDEX 1 INTO ls_relations.

*    lv_root = 'ZON' && ls_relations-id && 'SPROPERTIES'.
    IF gs_oc_obj-data EQ abap_true.
      lv_root = 'TY_PROPERTIES_META'.
    ELSE.
      lv_root = 'TY_PROPERTIES'.
    ENDIF.


    CREATE DATA dref_table TYPE (lv_root).
    ASSIGN dref_table->* TO <fs_properties>.

    ASSIGN COMPONENT 'MESSAGETYPE' OF STRUCTURE <fs_properties> TO <fs>.
    <fs> = gv_messagetype.
    ASSIGN COMPONENT 'CHANGE' OF STRUCTURE <fs_properties> TO <fs>.
    <fs>      = gv_update.
    ASSIGN COMPONENT 'DELETE' OF STRUCTURE <fs_properties> TO <fs>.
*    <fs>      = 'null'.
    <fs>      = gv_delete.
    ASSIGN COMPONENT 'DOMAIN' OF STRUCTURE <fs_properties> TO <fs>.
    <fs>      = gv_domainv.

    ASSIGN COMPONENT 'ENTITY' OF STRUCTURE <fs_properties> TO <fs>.
    <fs>      = gv_entity.

    ASSIGN COMPONENT 'DESCRIPTION' OF STRUCTURE <fs_properties> TO <fs>.
    <fs>      = gs_oc_obj-description.

    IF gs_oc_obj-data EQ abap_true.
      ASSIGN COMPONENT 'TAG1' OF STRUCTURE <fs_properties> TO <fs>.
      <fs>      = gs_oc_obj-tag1.
      ASSIGN COMPONENT 'TAG2' OF STRUCTURE <fs_properties> TO <fs>.
      <fs>      = gs_oc_obj-tag2.
      ASSIGN COMPONENT 'TAG3' OF STRUCTURE <fs_properties> TO <fs>.
      <fs>      = gs_oc_obj-tag3.
      ASSIGN COMPONENT 'TAG4' OF STRUCTURE <fs_properties> TO <fs>.
      <fs>      = gs_oc_obj-tag4.
      ASSIGN COMPONENT 'TAG5' OF STRUCTURE <fs_properties> TO <fs>.
      <fs>      = gs_oc_obj-tag5.
    ENDIF.

    cs_properties = <fs_properties>.

  ENDMETHOD.


  METHOD get_data_properties_any.

    DATA : dref_table   TYPE REF TO data,
           lv_root      TYPE string,
           ls_relations TYPE zonta_relations.

    FIELD-SYMBOLS: <fs>            TYPE any,
                   <fs_properties> TYPE any.

    IF NOT gv_kdoc IS INITIAL.
      gv_messagetype = c_kdoc.
    ELSE.
      gv_messagetype = c_table.
    ENDIF.

    IF gs_oc_obj-data EQ abap_true.
      lv_root = 'TY_PROPERTIES_META'.
    ELSE.
      lv_root = 'TY_PROPERTIES'.
    ENDIF.

    CREATE DATA dref_table TYPE (lv_root).
    ASSIGN dref_table->* TO <fs_properties>.

    ASSIGN COMPONENT 'MESSAGETYPE' OF STRUCTURE <fs_properties> TO <fs>.
    <fs> = gv_messagetype.
    ASSIGN COMPONENT 'CHANGE' OF STRUCTURE <fs_properties> TO <fs>.
    <fs>      = gv_update.
    ASSIGN COMPONENT 'DELETE' OF STRUCTURE <fs_properties> TO <fs>.
*    <fs>      = 'null'.
    <fs>      = gv_delete.
    ASSIGN COMPONENT 'DOMAIN' OF STRUCTURE <fs_properties> TO <fs>.
    <fs>      = gs_oc_obj-domainv.

    ASSIGN COMPONENT 'ENTITY' OF STRUCTURE <fs_properties> TO <fs>.
    <fs>      = gs_oc_obj-business_proc.

    ASSIGN COMPONENT 'DESCRIPTION' OF STRUCTURE <fs_properties> TO <fs>.
    <fs>      = gs_oc_obj-description.

    IF gs_oc_obj-data EQ abap_true.
      ASSIGN COMPONENT 'TAG1' OF STRUCTURE <fs_properties> TO <fs>.
      <fs>      = gs_oc_obj-tag1.
      ASSIGN COMPONENT 'TAG2' OF STRUCTURE <fs_properties> TO <fs>.
      <fs>      = gs_oc_obj-tag2.
      ASSIGN COMPONENT 'TAG3' OF STRUCTURE <fs_properties> TO <fs>.
      <fs>      = gs_oc_obj-tag3.
      ASSIGN COMPONENT 'TAG4' OF STRUCTURE <fs_properties> TO <fs>.
      <fs>      = gs_oc_obj-tag4.
      ASSIGN COMPONENT 'TAG5' OF STRUCTURE <fs_properties> TO <fs>.
      <fs>      = gs_oc_obj-tag5.
    ENDIF.


    cs_properties = <fs_properties>.

  ENDMETHOD.


  METHOD get_data_tab.
    DATA : dref_table  TYPE REF TO data,
           lv_root     TYPE string,
           e_size	     TYPE zonde_oc_num30,
           e_records   TYPE zonde_oc_num30,
           lv_response TYPE string,
           lv_return   TYPE string,
           lv_where    TYPE tty_where,
           i_dest      TYPE rfcdest VALUE 'ONIBEX_KDOCS'.

    IF NOT gv_kdoc IS INITIAL.
      CLEAR gv_kdoc.
    ENDIF.

    IF gv_delete EQ abap_true.
      me->delete_data_table( it_data = it_data ).
    ELSE.
      IF gv_instid IS INITIAL.
        me->get_data_table( EXPORTING it_data = it_data )."<fs_table> ).
      ELSE.
        me->get_data_table( EXPORTING it_data = it_data )."<fs_table> ).
        me->delete_data_table( it_data = it_data ).
      ENDIF.
    ENDIF.

    LOOP AT gt_json INTO gv_json.

      me->pretty_json( EXPORTING iv_mode = c_table
                       CHANGING  cv_json = gv_json ).

      me->send_json_http_con(
                       EXPORTING
                         i_dest     = gv_dest
                       IMPORTING
                         e_return   = lv_return
                         e_size     = e_size
                         e_records  = e_records
*                       receiving
                         e_response = lv_response ).

      gv_sizet    = gv_sizet + e_size.

      gv_recordst = gv_recordst + 1.
    ENDLOOP.

    me->send_json_result( ).

    me->update_slg1_log( it_log_ext = gt_log_ext ).

    CLEAR gv_sizet.
    CLEAR gv_recordst.
  ENDMETHOD.


  METHOD get_data_table.
    CONSTANTS: lc_comilla   TYPE c LENGTH 1 VALUE ''''.

    DATA: lv_tabname        TYPE string,
          lv_condense       TYPE string,
          lv_field          TYPE string,
          lv_tabnameddif    TYPE ddobjname,
          lv_keys           TYPE string,
          lv_keys_main      TYPE string,
          lv_keys_temp      TYPE string,
          lv_root           TYPE string,
          lt_dfies_tab      TYPE STANDARD TABLE OF  dfies,
          lt_fcat           TYPE lvc_t_fcat,
          lt_columns        TYPE STANDARD TABLE OF zonta_oc_col_all,
          dref_table        TYPE REF TO data,
          dref_table_root   TYPE REF TO data,
          dref_table_body   TYPE REF TO data,
          lt_keys           TYPE tty_where,
          iv_message_v1     TYPE  symsgv,
          lt_relations      TYPE STANDARD TABLE OF zonta_relations,
          lv_lines          TYPE sy-tabix,
          ls_relations_last TYPE zonta_relations,
          lo_data           TYPE REF TO data,
          lv_recordst       TYPE sy-tabix,
          lv_max_records    TYPE zonde_registrosn,
          lv_pretty         TYPE string,
          lv_empty          TYPE string,
          lv_del_tabname    TYPE string,
          lv_del_where      TYPE string.



    FIELD-SYMBOLS: <fs_table>           TYPE STANDARD TABLE,
                   <fs_table1>          TYPE STANDARD TABLE,
                   <fs_body>            TYPE STANDARD TABLE,
                   <fs_metadata_root>   TYPE STANDARD TABLE,
                   <fs_relations>       TYPE zonta_relations,
                   <fs_root>            TYPE any,
                   <fs_oneconnect>      TYPE any,
                   <fs_properties>      TYPE any,
                   <fs_body_root>       TYPE any,
                   <fs_json>            TYPE any,
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
*CECHAVARRIA 07/05/2025
      WHEN 'FM_BGMC_PROCESS'.
        iv_message_v1 = '*** Direct Process TABLE RAP BO***'.
*CECHAVARRIA 07/05/2025
      WHEN OTHERS.
        iv_message_v1 = '*** Direct Process TABLE***'.
    ENDCASE.


    me->append_slg1_log(
      EXPORTING
        iv_tabname    = space
*       iv_key        =
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

*    DATA(ls_relations_last) = lt_relations[ lv_lines ].

    READ TABLE lt_relations INDEX lv_lines INTO ls_relations_last.


    LOOP AT lt_relations ASSIGNING <fs_relations>.

      CALL FUNCTION 'DDIF_FIELDINFO_GET'
        EXPORTING
          tabname        = <fs_relations>-tabname
        TABLES
          dfies_tab      = gt_dfies_tab
        EXCEPTIONS
          not_found      = 1
          internal_error = 2
          OTHERS         = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      IF <fs_relations>-parent_relation IS INITIAL.
        CLEAR gv_recordst_obj .
      ENDIF.

*      lv_root = 'ZON' && <fs_relations>-id && 'SCONNECT' && c_table.
*      CREATE DATA dref_table_root TYPE (lv_root).
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

      ASSIGN COMPONENT 'BODY' OF STRUCTURE <fs_oneconnect> TO <fs_body_root>.

      lv_tabname = 'SEQ' && <fs_relations>-sequence.

      APPEND INITIAL LINE TO <fs_metadata_root> ASSIGNING <fs_metadata>.

      ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_metadata> TO <fs_field_metadata>.
      <fs_field_metadata> = lv_tabname.
      TRANSLATE <fs_field_metadata> TO LOWER CASE.

      ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_metadata> TO <fs_metadata_line>.

      ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_body_root> TO <fs_field>.

      <fs_field> = lv_tabname.
      TRANSLATE <fs_field> TO LOWER CASE.

      IF gv_table IS INITIAL.
        lv_tabname = 'DATA' && lv_tabname.
      ENDIF.

      lv_condense = lv_tabname.

*      ASSIGN COMPONENT lv_tabname OF STRUCTURE <fs_body_root> TO <fs_body>.
      ASSIGN COMPONENT 'DATA' OF STRUCTURE <fs_body_root> TO <fs_table_body_line> .

      me->get_data_by_table( EXPORTING iv_parent_relation = <fs_relations>-parent_relation
                                       iv_table           = <fs_relations>-tabname
                             IMPORTING et_fcat            = lt_fcat
*                                  et_data            = lo_data ).
                                       et_data            = <fs_table_body_line> ).

*************************************************************************************************************************
*************************************************************************************************************************
*************************************************************************************************************************

* Begin of insert GE - the ultimate try
* Begin of insert DB

      IF gv_alias = abap_true.

* End of insert DB
        DATA : lt_bodyt  TYPE REF TO data.
        CREATE DATA lt_bodyt TYPE HANDLE go_tdescr.
        ASSIGN lt_bodyt->* TO <fs_body>.


        DATA:

          lr_root_orig        TYPE REF TO data,
          lr_root_new         TYPE REF TO data,
          lr_target           TYPE REF TO data, " Assuming <fs_target> points to data ref lr_target
          lo_root_descr       TYPE REF TO cl_abap_structdescr,
          lo_oneconnect_descr TYPE REF TO cl_abap_structdescr,
          lo_body_descr       TYPE REF TO cl_abap_structdescr,
          lo_target_descr     TYPE REF TO cl_abap_typedescr,
          lt_root_comp        TYPE abap_component_tab,
          lt_oneconnect_comp  TYPE abap_component_tab,
          lt_body_comp        TYPE abap_component_tab,
          ls_comp             TYPE abap_componentdescr,
          lo_new_body_type    TYPE REF TO cl_abap_structdescr,
          lo_new_oc_type      TYPE REF TO cl_abap_structdescr,
          lo_new_root_type    TYPE REF TO cl_abap_structdescr.

        FIELD-SYMBOLS:
          <fs_root_new>       TYPE any,
          <fs_oneconnect_new> TYPE any,
*  <fs_body_new>       TYPE any,
          <fs_seq001_new>     TYPE any.


* --- Start Dynamic Type Creation using RTTS ---

        " 1. Describe the target structure type (<fs_target>)
        lo_target_descr = cl_abap_typedescr=>describe_by_data( <fs_body> ).

        " 2. Describe the original root structure type (<fs_root>)
        lo_root_descr ?= cl_abap_typedescr=>describe_by_data( <fs_root> ).
        lt_root_comp = lo_root_descr->get_components( ).

        " 3. Find and Describe the 'ONECONNECT' component type
        READ TABLE lt_root_comp WITH KEY name = 'ONECONNECT' INTO ls_comp.
        IF sy-subrc <> 0.
          " Error handling: ONECONNECT not found
*      RAISE EXCEPTION TYPE cx_sy_assign_error.
        ENDIF.
        lo_oneconnect_descr ?= ls_comp-type.
        lt_oneconnect_comp = lo_oneconnect_descr->get_components( ).

        " 4. Find and Describe the 'BODY' component type
        READ TABLE lt_oneconnect_comp WITH KEY name = 'BODY' INTO ls_comp.
        IF sy-subrc <> 0.
          " Error handling: BODY not found
*      RAISE EXCEPTION TYPE cx_sy_assign_error.
        ENDIF.
        lo_body_descr ?= ls_comp-type.
        lt_body_comp = lo_body_descr->get_components( ).

        " 5. Create the NEW 'BODY' component list
        LOOP AT lt_body_comp ASSIGNING FIELD-SYMBOL(<fs_comp_body>).
*      IF <fs_comp_body>-name = 'SEQ001'.
          IF <fs_comp_body>-name = lv_tabname.
            " Replace the type description for SEQ001
            <fs_comp_body>-type ?= lo_target_descr.
          ENDIF.
        ENDLOOP.
*    IF NOT line_exists( lt_body_comp[ name = 'SEQ001' ] ).
        IF NOT line_exists( lt_body_comp[ name = lv_tabname ] ).
          " Error handling: SEQ001 not found in BODY
*        RAISE EXCEPTION TYPE cx_sy_assign_error.
        ENDIF.

        " 6. Create the NEW 'BODY' structure type description
        lo_new_body_type = cl_abap_structdescr=>create( lt_body_comp ).

        " 7. Create the NEW 'ONECONNECT' component list
        LOOP AT lt_oneconnect_comp ASSIGNING FIELD-SYMBOL(<fs_comp_oc>).
          IF <fs_comp_oc>-name = 'BODY'.
            " Replace the type description for BODY
            <fs_comp_oc>-type = lo_new_body_type.
          ENDIF.
        ENDLOOP.
        " (Error check for BODY existence already done)

        " 8. Create the NEW 'ONECONNECT' structure type description
        lo_new_oc_type = cl_abap_structdescr=>create( lt_oneconnect_comp ).

        " 9. Create the NEW ROOT ('ZONCOMPLEXTABLE') component list
        LOOP AT lt_root_comp ASSIGNING FIELD-SYMBOL(<fs_comp_root>).
          IF <fs_comp_root>-name = 'ONECONNECT'.
            " Replace the type description for ONECONNECT
            <fs_comp_root>-type = lo_new_oc_type.
          ENDIF.
        ENDLOOP.
        " (Error check for ONECONNECT existence already done)

        " 10. Create the NEW ROOT structure type description
        lo_new_root_type = cl_abap_structdescr=>create( lt_root_comp ).

        " 11. Create the final data object with the NEW dynamic type
        CREATE DATA lr_root_new TYPE HANDLE lo_new_root_type.
        ASSIGN lr_root_new->* TO <fs_root_new>.

        " 12. Copy data from original to new structure
        " MOVE-CORRESPONDING might work for many parts, but be careful with nested changes.
        " A safer approach is often component-by-component copy or a dedicated deep copy method.
        " Let's try MOVE-CORRESPONDING first, then assign the specific changed part.

*          MOVE-CORRESPONDING <fs_root> TO <fs_root_new> EXPANDING NESTED TABLES KEEPING TARGET LINES.

        UNASSIGN:
                  <fs_root>,
                  <fs_oneconnect>,
                  <fs_properties>,
                  <fs_metadata_root>,
                  <fs_body_root>,
                  <fs_metadata>,
                  <fs_field_metadata>,
                  <fs_metadata_line>,
                  <fs_field>,
                  <fs_body>.

        ASSIGN <fs_root_new> TO <fs_root>.
        ASSIGN COMPONENT 'ONECONNECT' OF STRUCTURE <fs_root> TO <fs_oneconnect>.
        ASSIGN COMPONENT 'PROPERTIES' OF STRUCTURE <fs_oneconnect> TO <fs_properties>.
        me->get_data_properties( CHANGING cs_properties = <fs_properties> ).
        ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_oneconnect> TO <fs_metadata_root>.
        ASSIGN COMPONENT 'BODY' OF STRUCTURE <fs_oneconnect> TO <fs_body_root>.
        lv_tabname = 'SEQ' && <fs_relations>-sequence.
        APPEND INITIAL LINE TO <fs_metadata_root> ASSIGNING <fs_metadata>.
        ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_metadata> TO <fs_field_metadata>.
        <fs_field_metadata> = lv_tabname.
        TRANSLATE <fs_field_metadata> TO LOWER CASE.
        ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_metadata> TO <fs_metadata_line>.
        ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_body_root> TO <fs_field>.
        ASSIGN COMPONENT lv_tabname OF STRUCTURE <fs_body_root> TO <fs_body>.
        IF gv_fieldname = abap_false.
          <fs_field> = <fs_relations>-alias_tabname. "This one is kind of tricky
        ELSE.
          <fs_field> = <fs_relations>-tabname. "This one is kind of tricky
        ENDIF.
*          FREE: lo_data, "--DB 15.05.2025 aquí se usa <fs_table_body_line> en lugar de lo_Data
        FREE: <fs_table_body_line>,
              lt_fcat.

        me->get_data_by_table( EXPORTING iv_parent_relation = <fs_relations>-parent_relation
                                         iv_table           = <fs_relations>-tabname
                               IMPORTING et_fcat            = lt_fcat
                                         et_data            = lo_data ).

      ELSE.
*          ASSIGN COMPONENT lv_tabname OF STRUCTURE <fs_body_root> TO <fs_body>.
        ASSIGN <fs_table_body_line>->* TO <fs_body>.
      ENDIF.
* End of insert DB
* End of insert GE
*************************************************************************************************************************
*************************************************************************************************************************
*************************************************************************************************************************


*      ASSIGN <fs_table_body_line>->* TO <fs_body>.  "--DB 15.05.2025

      CLEAR lt_keys .

      me->get_key( EXPORTING iv_parent_relation = <fs_relations>-parent_relation
                             iv_tabname         = <fs_relations>-tabname
                   IMPORTING et_keys            = lt_keys
                             ev_key             = lv_keys
                             ev_key_main        = lv_keys_main ).


      me->set_metadata_node( EXPORTING it_fcat     = lt_fcat
                                       iv_tabname  = <fs_relations>-tabname
                             CHANGING  cs_metadata = <fs_metadata_line> ).

      me->get_data_by_table( EXPORTING iv_parent_relation = <fs_relations>-parent_relation
                                       iv_table           = <fs_relations>-tabname
                             IMPORTING et_fcat            = lt_fcat
                                       et_data            = lo_data ).


      ASSIGN lo_data->* TO <fs_table>.

      ASSIGN it_data TO <fs_table2>.

      lt_columns = gt_columns_all.
      DELETE lt_columns WHERE tabname NE <fs_relations>-tabname.

      lv_del_tabname = lc_comilla             &&
                       <fs_relations>-tabname &&
                       lc_comilla.

      CONCATENATE 'TABNAME EQ'
                  lv_del_tabname
                  INTO lv_del_where
                  SEPARATED BY space.

      LOOP AT <fs_table2> ASSIGNING <fs_data> WHERE (lv_del_where).
        APPEND INITIAL LINE TO <fs_table> ASSIGNING <fs_table_line>.
*        MOVE-CORRESPONDING <fs_data> TO <fs_table_line> .

        me->assign_component_table(
          EXPORTING
            is_source    = <fs_data>
            is_relations = <fs_relations>
            iv_alias     = gv_alias
            it_columns   = lt_columns
          CHANGING
            cs_target    = <fs_table_line>
        ).

      ENDLOOP.
*      MOVE-CORRESPONDING it_data TO <fs_table> .

      SORT <fs_table>.

      DELETE ADJACENT DUPLICATES FROM <fs_table> .

* Get Fields to b'e exported
      lv_recordst  = lines( <fs_table> ).

*      gv_recordst =  gv_recordst + lv_recordst.

      LOOP AT <fs_table> ASSIGNING <fs_line>.

        CLEAR lt_keys.

        ASSIGN COMPONENT lv_keys_main OF STRUCTURE <fs_line> TO <fs_key_main>.

        IF <fs_relations>-parent_relation IS INITIAL.
          IF lv_keys_temp NE <fs_key_main>.
            lv_keys_temp = <fs_key_main>.
          ENDIF.
        ENDIF.

        lv_max_records = lv_max_records + 1.

        IF <fs_relations>-parent_relation IS INITIAL.
          gv_recordst_obj = gv_recordst_obj + 1.
        ENDIF.

        ASSIGN COMPONENT 2 OF STRUCTURE <fs_line> TO <fs_key>.

        IF <fs_key> IS ASSIGNED.
          me->append_slg1_log( iv_tabname = <fs_relations>-tabname
                               iv_mestyp  = 'S'
                               iv_key     = <fs_key> ).
        ENDIF.


*** Fill Even ID
        IF gs_oc_obj-eventid  EQ abap_true OR
           gs_oc_obj-metadata EQ abap_true.

          IF <fs_key> IS ASSIGNED.

            APPEND INITIAL LINE TO lt_keys ASSIGNING <fs_keys_event>.
            IF <fs_key> IS NOT INITIAL."CECHAVARRIA 11/06/2025
              IF abap_false = is_cds_entity( iv_tabname = <fs_relations>-tabname ).
                <fs_keys_event>-line = <fs_key>.
              ELSE.
                <fs_keys_event>-line = <fs_key_main>.
              ENDIF.
            ELSEIF abap_true = is_cds_entity( iv_tabname = <fs_relations>-tabname ).
              <fs_keys_event>-line = <fs_key_main>.
            ENDIF."CECHAVARRIA 11/06/2025
          ENDIF.

          me->get_eventid( EXPORTING it_keys      = lt_keys
                           CHANGING  cs_line_json = <fs_line> ).
        ENDIF.


        APPEND INITIAL LINE TO <fs_body> ASSIGNING <fs_table_body_line>.

        MOVE-CORRESPONDING <fs_line> TO <fs_table_body_line>.

*** Convert Exit
        me->convertion_exit( EXPORTING iv_tabname = <fs_relations>-tabname
                             CHANGING  cs_string  = <fs_table_body_line> ).

        ASSIGN COMPONENT 1 OF STRUCTURE <fs_table_body_line> TO <fs_field>.
        IF <fs_field> IS ASSIGNED.
          IF abap_false = me->is_cds_entity( <fs_relations>-tabname )."CECHAVARRIA 11/06/2025
            <fs_field>  = sy-mandt.
          ENDIF."CECHAVARRIA 11/06/2025
        ENDIF.

        UNASSIGN <fs_key> .

        IF lv_max_records EQ gs_oc_obj-no_registros.
          APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.

          <fs_json> = zoncl_ui2_cl_json=>serialize(
            data             = <fs_root>
            compress         = abap_false "abap_true
            assoc_arrays     = abap_true
            assoc_arrays_opt = abap_true
            pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).

          CLEAR: lv_max_records,
                 <fs_body>.
        ENDIF.

      ENDLOOP.

      IF sy-subrc NE 0.
        lv_empty = abap_true.
      ENDIF.

      IF lv_max_records LT gs_oc_obj-no_registros.
        APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.

        <fs_json> = zoncl_ui2_cl_json=>serialize(
          data             = <fs_root>
          compress         = abap_false "abap_true
          assoc_arrays     = abap_true
          assoc_arrays_opt = abap_true
          pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).

        CLEAR lv_max_records.
      ENDIF.

      TRANSLATE lv_condense TO LOWER CASE.

      IF lv_empty EQ abap_true.
        lv_pretty = '"seq'                  &&
                    <fs_relations>-sequence &&
                    '":[],'.

        lv_empty  = '"seq'                  &&
                    <fs_relations>-sequence &&
                    '":[*],'.
        REPLACE lv_pretty WITH lv_empty INTO <fs_json>.
        IF sy-subrc NE 0.
          lv_pretty = '"seq'                  &&
                      <fs_relations>-sequence &&
                      '":[]'.

          lv_empty  = '"seq'                &&
                    <fs_relations>-sequence &&
                    '":[*]'.

          REPLACE lv_pretty WITH lv_empty INTO <fs_json>.
          IF sy-subrc NE 0.
            lv_pretty = '"data' &&
                        '":[]'.

            lv_empty  = '"seq'                &&
                      <fs_relations>-sequence &&
                      '":[*]'.


            REPLACE lv_pretty WITH lv_empty INTO <fs_json>.
          ENDIF.
        ENDIF.

        lv_empty = abap_false.
      ENDIF.

      UNASSIGN <fs_root>.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_ddicobject_from_cds.

*Get view ddic from CDS
**    SELECT SINGLE cds_db_view "#EC CI_NO_TABLE.
**      FROM ddl_object_names
**      INTO @rv_ddic_object
**     WHERE cds_ddl = @iv_tabname.

  ENDMETHOD.


  METHOD get_eventid.
    DATA: lv_key       TYPE string,
          lv_timestamp TYPE string.


    FIELD-SYMBOLS: <fs_line_json>      TYPE any,
                   <fs_field_objectid> TYPE any,
                   <fs_field_event>    TYPE any,
                   <fs_field_key>      TYPE any,
                   <fs_field_tag>      TYPE any,
                   <fs_key>            TYPE LINE OF tty_where.

    ASSIGN cs_line_json TO <fs_line_json>.

    ASSIGN COMPONENT 'OBJECTID'  OF STRUCTURE <fs_line_json> TO <fs_field_objectid>.
    IF <fs_field_objectid> IS ASSIGNED.
      <fs_field_objectid> = gs_oc_obj-objtype.
    ENDIF.

    ASSIGN COMPONENT 'EVENTID'  OF STRUCTURE <fs_line_json> TO <fs_field_event>.
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

*      IF gv_event_id IS INITIAL.
      gv_event_id = gs_oc_obj-cdobjectcl && lv_key && lv_timestamp.
*      ENDIF.

      CONDENSE gv_event_id NO-GAPS.

      <fs_field_event> = gv_event_id.
    ENDIF.

    IF gs_oc_obj-metadata EQ abap_true.
      ASSIGN COMPONENT 'TAG1'  OF STRUCTURE <fs_line_json> TO <fs_field_tag>.
      IF <fs_field_tag> IS ASSIGNED.
        <fs_field_tag> = gs_oc_obj-tag1.

        UNASSIGN <fs_field_tag>.
      ENDIF.

      ASSIGN COMPONENT 'TAG2'  OF STRUCTURE <fs_line_json> TO <fs_field_tag>.
      IF <fs_field_tag> IS ASSIGNED.
        <fs_field_tag> = gs_oc_obj-tag2.

        UNASSIGN <fs_field_tag>.
      ENDIF.

      ASSIGN COMPONENT 'TAG3'  OF STRUCTURE <fs_line_json> TO <fs_field_tag>.
      IF <fs_field_tag> IS ASSIGNED.
        <fs_field_tag> = gs_oc_obj-tag3.

        UNASSIGN <fs_field_tag>.
      ENDIF.

      ASSIGN COMPONENT 'TAG4'  OF STRUCTURE <fs_line_json> TO <fs_field_tag>.
      IF <fs_field_tag> IS ASSIGNED.
        <fs_field_tag> = gs_oc_obj-tag4.

        UNASSIGN <fs_field_tag>.
      ENDIF.

      ASSIGN COMPONENT 'TAG5'  OF STRUCTURE <fs_line_json> TO <fs_field_tag>.
      IF <fs_field_tag> IS ASSIGNED.
        <fs_field_tag> = gs_oc_obj-tag5.

        UNASSIGN <fs_field_tag>.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD get_fieldskey_cds.

    DATA:
      lt_primary_key_elements TYPE stringtab,
      ls_primary_key_element  LIKE LINE OF lt_primary_key_elements,
      lv_id                   TYPE if_sadl_entity=>ty_entity_id.

    TRY.
        " 1. Get primary key information using SADL
        lv_id = iv_tabname.
        DATA(lo_sadl_entity) = cl_sadl_entity_factory=>get_instance( )->get_entity(
          iv_id   = lv_id
          iv_type = cl_sadl_entity_factory=>co_type-cds
        ).

        lo_sadl_entity->get_primary_key_elements(
          IMPORTING
            et_primary_key_elements = lt_primary_key_elements
        ).

        " Store primary key names in a hashed table for quick lookup
        LOOP AT lt_primary_key_elements INTO ls_primary_key_element.
          INSERT ls_primary_key_element INTO TABLE ext_keys_fields.
        ENDLOOP.

      CATCH cx_sy_move_cast_error.
*        MESSAGE 'Error: Type cast issue during metadata retrieval.' TYPE 'E'.
      CATCH cx_sy_itab_line_not_found.
*        MESSAGE 'Error: Component not found during description.' TYPE 'E'.
    ENDTRY.
  ENDMETHOD.


  METHOD get_global_data.
    DATA: "lt_dependencies TYPE STANDARD TABLE OF ddldependency,
      lv_tabname   TYPE tabname,
      ls_relations TYPE zonta_relations,
      lt_cdhdr     TYPE tty_cdhdr,
      lv_time      TYPE sy-uzeit.


**** Get Columns

    SELECT *
       INTO TABLE gt_columns
       FROM zonta_oc_columns
       WHERE domainv       EQ gv_domainv
         AND business_proc EQ gv_entity.
    IF sy-subrc NE 0.

    ENDIF.

*** Get Relations
    SELECT * "#EC CI_NOFIRST
           INTO TABLE gt_relations
           FROM zonta_relations
           WHERE domainv       EQ gv_domainv
             AND business_proc EQ gv_entity
             ORDER BY sequence.
    IF sy-subrc EQ 0.

*** Get Columns

      SELECT * "#EC CI_NOFIRST
         INTO TABLE gt_columns_all
         FROM zonta_oc_col_all
         FOR ALL ENTRIES IN gt_relations
         WHERE tabname       EQ gt_relations-tabname
           AND alias_tabname EQ gt_relations-alias_tabname.

      READ TABLE gt_relations INDEX 1 INTO ls_relations.

*** Get OEvent id info
      SELECT SINGLE *
             INTO gs_oc_obj
             FROM zonta_obj_oc
             WHERE id            EQ ls_relations-id
               AND domainv       EQ gv_domainv
               AND business_proc EQ gv_entity.

*** Get Filters
      SELECT *
             INTO TABLE gt_filters
             FROM zonta_oc_filters
              WHERE domainv       EQ gv_domainv
                AND business_proc EQ gv_entity.


*** Uncomment this code if you are using S4HANA
*      LOOP AT gt_relations ASSIGNING FIELD-SYMBOL(<fs_relations>).
*        CALL FUNCTION 'RS_ABAP_GET_DDL_DEPENDENCIES_E'
*          EXPORTING
*            p_objectname   = <fs_relations>-tabname
*          TABLES
*            p_dependencies = lt_dependencies
*          EXCEPTIONS
*            not_found      = 1
*            OTHERS         = 2.
*        IF sy-subrc EQ 0.
*          TRY.
*              DATA(ls_dependencies) = lt_dependencies[ objecttype = 'VIEW' ].
*
*              lv_tabname = <fs_relations>-tabname.
*
*              <fs_relations>-tabname = ls_dependencies-objectname.
*
*              LOOP AT gt_columns ASSIGNING FIELD-SYMBOL(<fs_components>)
*                                 WHERE tabname = lv_tabname  .
*
*                <fs_components>-tabname = <fs_relations>-tabname .
*
*              ENDLOOP.
*
*            CATCH  cx_sy_itab_line_not_found.
*          ENDTRY.
*        ENDIF.
*      ENDLOOP.
      IF NOT gv_delete IS INITIAL OR
         NOT gv_instid IS INITIAL.

        lv_time = sy-uzeit - 30.

        SELECT objectclas
               objectid
               changenr
               INTO TABLE lt_cdhdr
               FROM cdhdr
               WHERE objectclas EQ gs_oc_obj-cdobjectcl
                 AND objectid   EQ gv_instid
                 AND udate EQ sy-datum
                 AND utime BETWEEN lv_time AND sy-uzeit.
        IF sy-subrc EQ 0.
          SELECT tabname
                 tabkey
                 INTO TABLE gt_cdpos
                 FROM cdpos
                 FOR ALL ENTRIES IN lt_cdhdr
                 WHERE objectclas EQ lt_cdhdr-objectclas
                   AND objectid   EQ lt_cdhdr-objectid
                   AND changenr   EQ lt_cdhdr-changenr
                   AND fname      EQ 'KEY'
                   AND chngind    EQ 'D'.
        ENDIF.
      ENDIF.

    ELSE.
*      RAISE not_data_found.
      MESSAGE i000(fb) WITH 'No data found on ZONTA_RELATIONS '.
      RETURN.
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

      SORT lt_relations_keys BY sequence
                                subsequence.

      DELETE lt_relations_keys  WHERE parent_relation NE iv_parent_relation.

      DELETE lt_relations_keys  WHERE tabname NE iv_tabname.


      lv_lines = lines( lt_relations_keys ).

*      r_key = 'NOT ( '.
      LOOP AT lt_relations_keys ASSIGNING <fs_keys>.

        lv_tabix = sy-tabix.

*        TRY.
*            DATA(ls_columns) = gt_columns[ tabname = iv_parent_relation
*                                           fldname =  <fs_keys>-field_main ].

        READ TABLE gt_columns_all WITH KEY tabname = iv_parent_relation
                                       fldname =  <fs_keys>-field_main
                                       INTO ls_columns.
        IF sy-subrc EQ 0.
          IF NOT gv_alias IS INITIAL.
            IF NOT ls_columns-alias_fldname IS INITIAL.
              <fs_keys>-field_main = ls_columns-alias_fldname.
            ENDIF.
          ENDIF.
        ENDIF.
*          CATCH cx_sy_itab_line_not_found.
*        ENDTRY.

*        TRY.
*            ls_columns = gt_columns[ tabname = iv_tabname
*                                     fldname =  <fs_keys>-field_sec ].
        READ TABLE gt_columns_all WITH KEY tabname = iv_tabname
                                       fldname =  <fs_keys>-field_sec
                                       INTO ls_columns.
        IF sy-subrc EQ 0.
          IF NOT gv_alias IS INITIAL.
            IF NOT ls_columns-alias_fldname IS INITIAL.
              <fs_keys>-field_sec = ls_columns-alias_fldname.
            ENDIF.
          ENDIF.
        ENDIF.
*          CATCH cx_sy_itab_line_not_found.
*        ENDTRY.

        lv_field = 'is_line-' &&
                   <fs_keys>-field_main.

        IF lv_tabix LT lv_lines.
          CONCATENATE ev_key
                      <fs_keys>-field_sec
                      'EQ'
                      lv_field
                      'AND'
                       INTO ev_key
                       SEPARATED BY space.

        ELSE.
          CONCATENATE ev_key
                     <fs_keys>-field_sec
                     'EQ'
                     lv_field
                      INTO ev_key
                      SEPARATED BY space.
        ENDIF.

        IF gs_oc_obj-eventid EQ abap_true.
          APPEND INITIAL LINE TO et_keys ASSIGNING <fs_keys_tab>.
          <fs_keys_tab>-line = <fs_keys>-field_sec.
        ENDIF.
      ENDLOOP.

*      r_key = r_key &&
*                ')'.
    ELSE.
      READ TABLE gt_columns_all WITH KEY tabname   = iv_tabname
                                     key_field = abap_true
                                     INTO ls_columns.
      IF sy-subrc EQ 0.
        IF NOT gv_alias IS INITIAL.
          IF NOT ls_columns-alias_fldname IS INITIAL.
            ev_key_main = ls_columns-alias_fldname.
          ELSE.
            ev_key_main = ls_columns-fldname.
          ENDIF.
        ELSE.
          ev_key_main = ls_columns-fldname.
        ENDIF.

        TRANSLATE  ev_key_main TO UPPER CASE.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD GET_LENGHT_KEY.
    CONSTANTS: lc_comilla   TYPE c LENGTH 1 VALUE ''''.

    DATA: lt_dfies_tab TYPE STANDARD TABLE OF dfies.
    DATA : dref_table TYPE REF TO data,
           lv_fields  TYPE string,
           lv_where   TYPE string,
           lv_instid  TYPE string.

    FIELD-SYMBOLS: <fs_table> TYPE any,
                   <fs_cdpos> TYPE ty_cdpos.


    FIELD-SYMBOLS: <fs_dfies> TYPE dfies.

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
* Implement suitable error handling here
      rv_lenght = 0.
    ELSE.
      DELETE lt_dfies_tab WHERE keyflag NE abap_true.

      LOOP AT lt_dfies_tab ASSIGNING <fs_dfies>.
        rv_lenght = rv_lenght + <fs_dfies>-leng.

        CONCATENATE lv_fields
                    <fs_dfies>-fieldname
                    INTO lv_fields
                    SEPARATED BY space.
      ENDLOOP.
    ENDIF.

*    IF  iv_parent IS INITIAL AND
*    NOT gv_instid IS INITIAL.
*
*      lv_where  = <fs_dfies>-fieldname.
*
*      READ TABLE gt_cdpos WITH KEY tabname = iv_tabname
*                          TRANSPORTING NO FIELDS.
*      IF sy-subrc NE 0.
*        CREATE DATA dref_table TYPE (iv_tabname) .
*        ASSIGN dref_table->* TO <fs_table>.
*
*        lv_instid = |{ lc_comilla } { gv_instid } { lc_comilla }| .
*
*        CONDENSE lv_instid NO-GAPS.
*
*        CONCATENATE lv_where
*                   'EQ'
*                   lv_instid
*                  INTO lv_where
*                  SEPARATED BY space.
*
*        SELECT SINGLE (lv_fields)
*                 INTO CORRESPONDING FIELDS OF <fs_table>
*                 FROM (iv_tabname)
*                WHERE (lv_where).
*        IF sy-subrc EQ 0.
*          APPEND INITIAL LINE TO gt_cdpos ASSIGNING <fs_cdpos>.
*          <fs_cdpos>-TABNAME = iv_tabname.
*          <fs_cdpos>-TABKEY  = <fs_table>(rv_lenght).
*        ENDIF.
*      ENDIF.
*    ENDIF.

  ENDMETHOD.


  METHOD get_objects.
    et_objects = gt_objects[].
    et_ddic    = gt_ddic[].

    CLEAR gt_objects[].
    CLEAR gt_ddic[].

  ENDMETHOD.


  METHOD get_relation.

* Begin of insert Dev version
    DATA:
      it_abap_callstack TYPE abap_callstack,
      ws_abap_callstack TYPE abap_callstack_line,
      it_syst_callstack TYPE sys_callst.
* End of insert Dev version

    gv_kdoc          = iv_kdoc.
    gv_table         = iv_table.
    gv_domainv       = iv_domainv.
    gv_entity        = iv_business_proc.
    gv_key_queue     = iv_key_queue.
    gv_batch         = iv_batch.
    gt_where         = it_where.
    gt_where_cond_tab = it_where_cond_tab.
    gv_delete        = iv_delete.
    gv_update        = iv_update.
    gv_instid        = iv_instid.
    gv_anytable      = iv_anytable.
    gv_alias         = iv_alias.
    gv_dest          = iv_dest.
    gv_fieldname     = iv_fieldname.
    gv_bothnames     = iv_bothnames.

* Begin of insert Dev version
    CALL FUNCTION 'SYSTEM_CALLSTACK'
      EXPORTING
        max_level    = 20
      IMPORTING
        callstack    = it_abap_callstack
        et_callstack = it_syst_callstack.
* Assign an internal table
    READ TABLE it_abap_callstack INTO ws_abap_callstack WITH KEY mainprogram = 'ZONPG_ONECONNECT_CUST_EXE'
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
* End of insert Dev version

    me->get_global_data( ).

    IF iv_ddic IS INITIAL.
      IF it_endpoints IS INITIAL.
*        IF gv_kdoc = abap_true AND gv_table = abap_true.
*          gv_kdoc = abap_true.
*          gv_table = abap_false.
          me->process_data( ).
*          gv_kdoc = abap_false.
*          gv_table = abap_true.
*          me->process_data( ).
*        ELSE.
*          me->process_data( ).
*        ENDIF.

        ev_sizet    = gv_sizet.
        ev_recordst = gv_recordst.
      ELSE..
        LOOP AT it_endpoints INTO gs_endpoints.
          gv_dest          = gs_endpoints-endpoint.

          CASE gs_endpoints-transm_medium.
            WHEN 'T'.
              gv_kdoc  = abap_false.
              gv_table = abap_true.
            WHEN 'K'.
              gv_kdoc = abap_true.
              gv_table = abap_false.
            WHEN 'B'.
              gv_kdoc = abap_true.
              gv_table = abap_true.
            WHEN OTHERS.
              gv_kdoc = abap_false.
              gv_table = abap_true.
          ENDCASE.

*          IF gv_kdoc = abap_true AND gv_table = abap_true.
*            gv_kdoc = abap_true.
*            gv_table = abap_false.
*            me->process_data( ).
*            gv_kdoc = abap_false.
*            gv_table = abap_true.
*            me->process_data( ).
*          ELSE.
            me->process_data( ).
*          ENDIF.

          ev_sizet    = gv_sizet.
          ev_recordst = gv_recordst.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD GET_TIMESTAMP.
    DATA: lv_time_stamp TYPE timestamp,
          lv_date       TYPE d,
          lv_time       TYPE t,
          lv_tz         TYPE ttzz-tzone.

    lv_tz = sy-tzone.

    GET TIME STAMP FIELD lv_time_stamp.
    CONVERT TIME STAMP lv_time_stamp TIME ZONE lv_tz INTO DATE lv_date TIME lv_time.
    rv_timestamp = lv_time_stamp.

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

          READ TABLE lt_relations WITH KEY tabname = <fs_cond_tab>-tablename
                                  INTO ls_relations.
          IF sy-subrc EQ 0.
            APPEND INITIAL LINE TO lt_cond_tab ASSIGNING <fs_cond_tab_tmp>.
            <fs_cond_tab_tmp>-tablename = <fs_cond_tab>-tablename .
            <fs_cond_tab_tmp>-where_tab = <fs_cond_tab>-where_tab .
          ENDIF.
        ENDLOOP.

*** Add Conditions for all entries
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

            READ TABLE gt_relations WITH KEY tabname = <fs_relations>-parent_relation
                                    ASSIGNING  <fs_relations_parent> .

*CECHAVARRIA 03/06/2025
            IF abap_false = me->is_cds_entity( iv_tabname ).
              lv_field = '<fs_table_for_all>-' &&
                         lv_field              &&
                         <fs_relations_parent>-sequence.

            ELSE.
              lv_field = '@<fs_table_for_all>-' &&
                            lv_field              &&
                            <fs_relations_parent>-sequence.
            ENDIF.
*CECHAVARRIA 03/06/2025

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
*** Add Conditions Filter
        LOOP AT lt_relations ASSIGNING <fs_relations>.

          READ TABLE lt_cond_tab WITH KEY tablename = <fs_relations>-tabname
                                 INTO ls_cond_tab.

          IF sy-subrc EQ 0.

            LOOP AT ls_cond_tab-where_tab ASSIGNING <fs_where_tab_tmp>.

              APPEND INITIAL LINE TO r_where ASSIGNING <fs_where>.

              <fs_where>-line = <fs_where_tab_tmp>-line.

            ENDLOOP.

            APPEND INITIAL LINE TO r_where ASSIGNING <fs_where>.

            <fs_where>-line = 'AND'.
          ENDIF.

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


  METHOD is_cds_entity.

    DATA: lv_is_ddic TYPE dd03l-tabname.

*Validate if is dicc or CDS
    SELECT SINGLE tabname
        FROM dd03l
       INTO lv_is_ddic
      WHERE tabname = iv_tabname.

*If the table exist is false because is DICC object
    IF sy-subrc EQ 0.
      r_is_cds_entity = abap_false.
*If not exist in table is CDS entity and is TRUE
    ELSE.
      r_is_cds_entity = abap_true.
    ENDIF.
  ENDMETHOD.


  METHOD pretty_json.
    CONSTANTS: lc_empty  TYPE string VALUE ',"data":[]',
               lc_empty2 TYPE string VALUE '"data":{"table":""},',
               lc_empty3 TYPE string VALUE ',"data":{"table":""}'.

    DATA: lt_relations TYPE STANDARD TABLE OF zonta_relations,
          lv_tabname   TYPE string,
          lv_data      TYPE string.

    FIELD-SYMBOLS: <fs_relations> TYPE zonta_relations.

    lt_relations = gt_relations.
    SORT lt_relations BY sequence.
    DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING sequence.

    IF iv_mode EQ c_kdoc.
      LOOP AT lt_relations ASSIGNING <fs_relations>.
        lv_tabname = 'SEQ' && <fs_relations>-sequence.
        TRANSLATE lv_tabname TO LOWER CASE.
*        TRANSLATE <fs_relations>-alias_tabname TO LOWER CASE.
        IF gv_fieldname IS INITIAL.
          IF NOT <fs_relations>-alias_tabname IS INITIAL.
            REPLACE ALL OCCURRENCES OF lv_tabname IN cv_json WITH <fs_relations>-alias_tabname.
          ELSE.
            REPLACE ALL OCCURRENCES OF lv_tabname IN cv_json WITH <fs_relations>-tabname.
          ENDIF.
        ELSE.
          REPLACE ALL OCCURRENCES OF lv_tabname IN cv_json WITH <fs_relations>-tabname.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF iv_mode EQ c_table.

      LOOP AT lt_relations ASSIGNING <fs_relations>.
        lv_data   = '"' && 'SEQ' && <fs_relations>-sequence && '":'.
        TRANSLATE lv_data TO LOWER CASE.
        REPLACE ALL OCCURRENCES OF lv_data IN cv_json WITH '"data":'.


        lv_tabname = 'SEQ' && <fs_relations>-sequence.
        TRANSLATE lv_tabname TO LOWER CASE.
*        TRANSLATE <fs_relations>-alias_tabname TO LOWER CASE.
        IF gv_fieldname IS INITIAL.
          IF NOT <fs_relations>-alias_tabname IS INITIAL.
            REPLACE ALL OCCURRENCES OF lv_tabname IN cv_json WITH <fs_relations>-alias_tabname.
          ELSE.
            REPLACE ALL OCCURRENCES OF lv_tabname IN cv_json WITH <fs_relations>-tabname.
          ENDIF.
        ELSE.
          REPLACE ALL OCCURRENCES OF lv_tabname IN cv_json WITH <fs_relations>-tabname.
        ENDIF.

        REPLACE ALL OCCURRENCES OF lc_empty IN cv_json WITH space.
        REPLACE ALL OCCURRENCES OF lc_empty2 IN cv_json WITH space.
        REPLACE ALL OCCURRENCES OF lc_empty3 IN cv_json WITH space.
      ENDLOOP.

      REPLACE ALL OCCURRENCES OF '[*]' IN cv_json WITH '[]'.
    ENDIF.

    REPLACE 'messagetype' WITH 'messageType' INTO cv_json.

    REPLACE 'TABL' WITH 'TABLE' INTO cv_json.

*CECHAVARRIA 12/05/2025
*    DATA(lo_conv) = cl_abap_conv_out_ce=>create( ).
*    lo_conv->write( data = 'Prueba de Xstring ABAP RAP BO' ).
*    DATA(lv_xstring) = lo_conv->get_buffer( ).
*
**add new field to json xstring
*    DATA(lv_lengh) = strlen( cv_json ).
*    lv_lengh = lv_lengh - 2.
*    cv_json = cv_json(lv_lengh) && '"' && 'ATTCH' && '"' &&  ':' && '"' && lv_xstring && '"' && '}}'.

*CECHAVARRIA 12/05/2025

    IF NOT gv_bothnames IS INITIAL.
*      me->bothnames_json( CHANGING cv_json = cv_json ).
      me->alias_both_json( EXPORTING iv_option = c_both CHANGING cv_json = cv_json ).
    ENDIF.

    IF gv_fieldname IS INITIAL AND gv_bothnames  IS INITIAL.
*      me->alias_json( CHANGING cv_json = cv_json ).
      me->alias_both_json( EXPORTING iv_option = c_alias CHANGING cv_json = cv_json ).
    ENDIF.

    IF NOT gv_fieldname IS INITIAL .
      me->fieldname_json( CHANGING cv_json = cv_json ).
    ENDIF.



  ENDMETHOD.


  METHOD pretty_json_any.

    IF NOT gv_bothnames IS INITIAL.
      me->bothnames_json( CHANGING cv_json = cv_json ).
    ENDIF.

    IF gv_fieldname IS INITIAL AND gv_bothnames  IS INITIAL.
      me->alias_json( CHANGING cv_json = cv_json ).
    ENDIF.

    IF NOT gv_fieldname IS INITIAL .
      me->fieldname_json( CHANGING cv_json = cv_json ).
    ENDIF.

  ENDMETHOD.


  METHOD process_data.
    DATA: lv_join       TYPE string,
          lv_fields     TYPE string,
          lo_table      TYPE REF TO data,
          dref_table    TYPE REF TO data,
          lv_root       TYPE string,
          e_size        TYPE zonde_oc_num30,
          e_records     TYPE zonde_oc_num30,
          lv_response   TYPE string,
          lv_return     TYPE string,
          lv_where      TYPE zonttrsdswhere,
          lv_message_v1	TYPE symsgv,
          lv_message_v2	TYPE symsgv,
          lv_message_v3	TYPE symsgv,
          i_dest        TYPE rfcdest VALUE 'ONIBEX_KDOCS'.

    FIELD-SYMBOLS: <fs_table>     TYPE ANY TABLE,
                   <fs_where>     TYPE LINE OF zonttrsdswhere,
                   <fs_where_tab> TYPE LINE OF rsds_where_tab.


    lo_table  = me->set_table( ).
    IF gv_key_queue IS INITIAL.
      IF gt_where_cond_tab IS INITIAL.
        me->set_where_new( ).

        me->set_process( ).

        gt_where_cond_tab = gt_cond_tab.
      ELSE.
        gt_cond_tab = gt_where_cond_tab.
      ENDIF.
    ELSE.

      gt_cond_tab = gt_where_cond_tab.

    ENDIF.

    IF gt_where_cond_tab IS INITIAL.
      MESSAGE i000(fb) WITH 'No filter selected'.
      RETURN.
    ENDIF.

    IF gv_batch IS INITIAL.

      IF gv_update EQ abap_true OR
         gv_delete EQ abap_true.

        lo_table = me->get_database_data( ).

        ASSIGN lo_table->* TO <fs_table>.

        IF NOT <fs_table> IS ASSIGNED.
          IF gv_instid IS INITIAL.
            MESSAGE i000(fb) WITH 'No data found'.
          ENDIF.

          lv_message_v2 = gv_instid.

          me->append_slg1_log(
                               EXPORTING
                                 iv_tabname    = space
*                               iv_key        =
                                 iv_message_v1 = 'No data found for'
                                 iv_message_v2 = lv_message_v2
                                 iv_message_v3 = space
                                 iv_mestyp     = 'S' ).

          me->update_slg1_log( it_log_ext = gt_log_ext ).

          RETURN.
        ENDIF..
      ENDIF.

      clear gv_sending.
      IF NOT gv_kdoc IS INITIAL.
        gv_sending = c_kdoc.
        me->get_data_kdoc( it_data = <fs_table> ).
      ENDIF.

      IF NOT gv_table IS INITIAL.
        gv_sending = c_table.
        me->get_data_tab( it_data = <fs_table> ).
      ENDIF.
    ELSE.

      me->execute_batch( ).

    ENDIF.
  ENDMETHOD.


  METHOD replace_data_metadata.

    DATA: ls_col LIKE LINE OF gt_columns_all.
    DATA: lv_source        TYPE string,
          lv_target        TYPE string,
          lv_technical     TYPE zonta_oc_col_all-fldname,
          lv_alias_fldname TYPE zonta_oc_col_all-alias_fldname.

    lv_technical = iv_technical.
    lv_alias_fldname = iv_alias_fldname.

    TRANSLATE lv_alias_fldname TO UPPER CASE.

    DO.
      READ  TABLE gt_columns_all INTO ls_col WITH KEY fldname = lv_alias_fldname.
      IF sy-subrc = 0 AND ( lv_alias_fldname NE lv_technical ).
        CALL METHOD me->replace_data_metadata
          EXPORTING
            iv_tabname       = iv_tabname
            iv_alias_tabname = iv_alias_tabname
            iv_technical     = ls_col-fldname
            iv_alias_fldname = ls_col-alias_fldname
            iv_option        = iv_option
          CHANGING
            cv_json          = cv_json.
      ELSE.
* replace
        CLEAR: lv_source, lv_target.
* Translate metadata
        TRANSLATE lv_technical TO LOWER CASE.
        TRANSLATE lv_alias_fldname TO LOWER CASE.

        lv_source = '"fieldname":"'   && iv_technical && '"'.
        IF iv_option = c_alias.
          lv_target = '"fieldname":"' && iv_alias_fldname && '"'.
        ELSE.
          lv_target = '"fieldname":"' && iv_technical && '_' && iv_alias_fldname  && '"'.
        ENDIF.

        REPLACE ALL OCCURRENCES OF '\'   IN lv_target WITH '_'.
        REPLACE ALL OCCURRENCES OF '/'   IN lv_target WITH '_'.

        REPLACE ALL OCCURRENCES OF lv_source IN cv_json WITH lv_target.


* Translate data
        CLEAR: lv_source, lv_target.
        TRANSLATE lv_technical TO LOWER CASE.
        TRANSLATE lv_alias_fldname TO LOWER CASE.

        lv_source = '"' && lv_technical && '":'.
        IF iv_option = c_alias.
          lv_target = '"' && lv_alias_fldname       && '":'.
        ELSE.
          lv_target = '"' && lv_technical && '_' && lv_alias_fldname  && '":'.
        ENDIF.

        REPLACE ALL OCCURRENCES OF '\'   IN lv_target WITH '_'.
        REPLACE ALL OCCURRENCES OF '/'   IN lv_target WITH '_'.

        REPLACE ALL OCCURRENCES OF lv_source IN cv_json WITH lv_target.
      ENDIF.
      EXIT.
    ENDDO.


* replace
    CLEAR: lv_source, lv_target.
* Translate metadata
    TRANSLATE lv_technical TO LOWER CASE.
    TRANSLATE lv_alias_fldname TO LOWER CASE.

    lv_source = '"fieldname":"'   && iv_technical && '"'.
    IF iv_option = c_alias.
      lv_target = '"fieldname":"' && iv_alias_fldname && '"'.
    ELSE.
      lv_target = '"fieldname":"' && iv_technical && '_' && iv_alias_fldname  && '"'.
    ENDIF.

    REPLACE ALL OCCURRENCES OF '\'   IN lv_target WITH '_'.
    REPLACE ALL OCCURRENCES OF '/'   IN lv_target WITH '_'.

    REPLACE ALL OCCURRENCES OF lv_source IN cv_json WITH lv_target.


* Translate data
    CLEAR: lv_source, lv_target.
    TRANSLATE lv_technical TO LOWER CASE.
    TRANSLATE lv_alias_fldname TO LOWER CASE.

    lv_source = '"' && lv_technical && '":'.
    IF iv_option = c_alias.
      lv_target = '"' && lv_alias_fldname       && '":'.
    ELSE.
      lv_target = '"' && lv_technical && '_' && lv_alias_fldname  && '":'.
    ENDIF.

    REPLACE ALL OCCURRENCES OF '\'   IN lv_target WITH '_'.
    REPLACE ALL OCCURRENCES OF '/'   IN lv_target WITH '_'.

    REPLACE ALL OCCURRENCES OF lv_source IN cv_json WITH lv_target.

  ENDMETHOD.


  METHOD send_event_automatic.

    CONSTANTS: lc_comilla   TYPE c LENGTH 1 VALUE ''''.

*CECHAVARRIA 8/05/2025
    TYPES: BEGIN OF ty_dd03l,
             tabname   TYPE dd03l-tabname,
             fieldname TYPE dd03l-fieldname,
             as4local  TYPE dd03l-as4local,
             as4vers   TYPE dd03l-as4vers,
             position  TYPE dd03l-position,
             keyflag   TYPE dd03l-keyflag,
             rollname  TYPE dd03l-rollname,
           END OF ty_dd03l.
*CECHAVARRIA 8/05/2025

    DATA: lt_oc_param              TYPE STANDARD TABLE OF zonta_oc_param,
          lt_endpoints             TYPE STANDARD TABLE OF zonta_oc_endp,
          lt_where_cond_tab        TYPE rsds_twhere,
*CECHAVARRIA 8/05/2025
          lt_entities_aux          TYPE STANDARD TABLE OF zonta_obj_oc,
          lt_relations             TYPE STANDARD TABLE OF zonta_relations,
          lt_columns               TYPE STANDARD TABLE OF zonta_oc_col_all,
          lt_relations_aux         TYPE STANDARD TABLE OF zonta_relations,
          lt_dd03l_keyfieldbytable TYPE STANDARD TABLE OF ty_dd03l,
          lt_primary_key_names     TYPE HASHED TABLE OF string WITH UNIQUE KEY table_line,
*CECHAVARRIA 8/05/2025
          lv_objtype               TYPE swotobjid-objtype,
          lv_object                TYPE zonde_oc_sibftypeid,
          lv_key                   TYPE string,
          lv_key1                  TYPE string,
          lv_key2                  TYPE string,
          lv_destination           TYPE rfcdest,
          lv_vbeln                 TYPE string,
          lt_info                  TYPE STANDARD TABLE OF swotrk,
          lt_info_hdr              TYPE STANDARD TABLE OF swotrk,
          lv_update                TYPE char1,
          lv_delete                TYPE char1,
          ls_obj_oc                TYPE zonta_obj_oc,
          lv_sequence              TYPE zonde_sequence,
          lv_kdoc(01)              TYPE c,
          lv_tabl(01)              TYPE c,
          lv_kunnr                 TYPE kunnr,
          lv_reffld                TYPE swc_reffld,
          lv_reffld2               TYPE swc_reffld,
          lv_pos(02)               TYPE n,
          lv_lines                 TYPE sy-index,
          lv_tabix                 TYPE sy-tabix,
*CECHAVARRIA 8/05/2025
*          lv_objtype_cl     TYPE swo_objtyp,
          lv_objtype_cl            TYPE char30,
          lv_tabix_aux             TYPE sy-tabix,
*CECHAVARRIA 8/05/2025
          lv_alias                 TYPE boolean,
          lv_fieldname             TYPE boolean.

* Begin of insert DB 06/04/2025
    DATA: lx_create TYPE REF TO cx_sy_create_object_error,
          lx_cast   TYPE REF TO cx_sy_move_cast_error.

    DATA: lv_class TYPE string,
          lo_descr TYPE REF TO cl_abap_objectdescr,
          lo_obj   TYPE REF TO object.
    DATA: lo_iface    TYPE REF TO zonif_code,
          lv_entity   TYPE zonde_process,
          lv_endpoint TYPE rfcdest,
          lv_where    TYPE string.
* End of insert DB 06/04/2025

    FIELD-SYMBOLS: <fs_info>           TYPE swotrk,
                   <fs_info_hdr>       TYPE swotrk,
                   <fs_oc_param>       TYPE zonta_oc_param,
                   <fs_where_cond_tab> TYPE LINE OF rsds_twhere,
                   <fs_where_tab>      TYPE LINE OF rsds_where_tab.

    lv_object  = is_sender-typeid.
    lv_objtype = is_sender-typeid.

*    DO .". TIMES.
***
*    ENDDO.
* Begin of insert DB 08/05
    DATA: lt_entities  TYPE STANDARD TABLE OF zonta_obj_oc,
          ls_entities  TYPE zonta_obj_oc,
          ls_relations TYPE zonta_relations,
          ls_columns   TYPE zonta_oc_col_all.

    SELECT *
      INTO TABLE lt_entities
      FROM zonta_obj_oc
           WHERE objtype EQ lv_object.
*<<< add process log
    DATA: v_cont  TYPE i,
          v_prlog TYPE c,
          v_lm1   TYPE symsgv,
          v_lm2   TYPE symsgv,
          v_lm3   TYPE symsgv,
          v_lm4   TYPE symsgv.
    CLEAR v_prlog.
    SELECT SINGLE low FROM zonta_oc_param INTO v_prlog WHERE name = 'PROCESS_LOG' AND low = 'X'.
    IF sy-subrc = 0.
      LOOP AT lt_entities INTO ls_entities.
        ADD 1 TO v_cont.
        CLEAR: v_lm1, v_lm2, v_lm3, v_lm4.
        MOVE 'EVENT_AUT : GET ENTITIES' TO v_lm1.
        MOVE v_cont TO v_lm2.
        MOVE ls_entities-business_proc TO v_lm3.
        CALL METHOD me->set_process_log
          EXPORTING
            i_text1   = v_lm1
            i_text2   = v_lm2
            i_text3   = v_lm3
            i_process = 'SEND_EVENT'.
      ENDLOOP.
    ENDIF.
*add process log >>>
*BEGIN CECHAVARRIA 16/05/2025
*    LOOP AT lt_entities INTO ls_obj_oc.
*      SELECT SINGLE *
*        INTO ls_relations
*        FROM zonta_relations
*        WHERE id       = ls_obj_oc-id
*          AND sequence = 1.
*      IF sy-subrc = 0.
*        lv_sequence = ls_relations-sequence.
*      ENDIF.

*BEGIN CECHAVARRIA 03/057/2025
*    IF sy-subrc EQ 0.
    IF lt_entities[] IS NOT INITIAL.
*END CECHAVARRIA 03/057/2025

      lt_entities_aux[] = lt_entities[].
      SORT lt_entities_aux BY id domainv business_proc.
      DELETE ADJACENT DUPLICATES FROM lt_entities_aux
                       COMPARING id domainv business_proc.

      IF lt_entities_aux[] IS NOT INITIAL.
        SELECT *
          FROM zonta_relations
          FOR ALL ENTRIES IN @lt_entities_aux
          WHERE id       = @lt_entities_aux-id
            AND sequence = 1
          INTO TABLE @lt_relations.

        IF sy-subrc EQ 0.

          lt_relations_aux[] = lt_relations[].
          SORT lt_relations_aux BY tabname sequence.
          DELETE lt_relations_aux WHERE sequence NE 1.
          DELETE ADJACENT DUPLICATES FROM lt_relations_aux
                           COMPARING tabname sequence.

          IF lt_relations_aux[] IS NOT INITIAL.

            SELECT tabname, fieldname, as4local, as4vers,
                   position, keyflag, rollname
                   FROM dd03l
                FOR ALL ENTRIES IN @lt_relations_aux
                  WHERE tabname = @lt_relations_aux-tabname
                    AND fieldname <> 'MANDT'
                    AND as4local  = 'A'
                    AND keyflag   = @abap_true
                    INTO TABLE @lt_dd03l_keyfieldbytable.
            IF sy-subrc NE 0.
              CLEAR lt_dd03l_keyfieldbytable[].
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
*END CECHAVARRIA 16/05/2025

    LOOP AT lt_entities INTO ls_obj_oc.

* Begin of insert DB 06/04/2025
      IF ls_obj_oc-class_name IS NOT INITIAL.

        SELECT SINGLE low
          INTO lv_endpoint
          FROM zonta_oc_param
          WHERE name = 'RFC_DESTINATION'.

        lv_class = ls_obj_oc-class_name.
        lv_entity = ls_obj_oc-business_proc.

        CASE is_sender-typeid.
          WHEN 'CL_MDM_PRD_EVENTS'.
            lv_where = ' A~MATNR = ' && ' ''' && is_sender-instid && ' '''.
        ENDCASE.

        TRY.
            lo_descr ?= cl_abap_objectdescr=>describe_by_name( lv_class ).

            CREATE OBJECT lo_obj TYPE (lv_class).
            lo_iface ?= lo_obj.
            CALL METHOD lo_iface->send_data
              EXPORTING
                iv_data   = ls_obj_oc
                iv_entity = lv_entity
                iv_dest   = lv_endpoint
                iv_where  = lv_where.

          CATCH cx_sy_create_object_error INTO lx_create.
            MESSAGE lx_create->get_text( ) TYPE 'E'.

          CATCH cx_sy_move_cast_error INTO lx_cast.
            MESSAGE lx_cast->get_text( ) TYPE 'E'.

        ENDTRY.

      ELSE.
* End of insert DB 06/04/2025
*BEGIN CECHAVARRIA 16/05/2025
*      SELECT SINGLE *
*        INTO ls_relations
*        FROM zonta_relations
*        WHERE id       = ls_obj_oc-id
*          AND sequence = 1.
*      IF sy-subrc = 0.
*        lv_sequence = ls_relations-sequence.
*      ENDIF.
* end of insert DB 08/05

        ls_relations = VALUE #( lt_relations[ id = ls_obj_oc-id  sequence = 1 ] OPTIONAL ).

        IF ls_relations-sequence IS NOT INITIAL.
          lv_sequence = ls_relations-sequence.
        ENDIF.

        SELECT * "#EC CI_NOFIRST
          FROM zonta_oc_col_all
          INTO TABLE lt_columns
          WHERE tabname      = ls_relations-tabname.
*END CECHAVARRIA 16/05/2025
* end of insert DB 08/05

* begin of delete DB 08/05
*    SELECT SINGLE
*               id
*               domainv
*               business_proc
*               INTO CORRESPONDING FIELDS OF ls_obj_oc
*               FROM zonta_obj_oc
*               WHERE objtype EQ lv_object.
*
*    IF  ls_obj_oc IS INITIAL.
*      RETURN.
*    ENDIF.
*
*    SELECT SINGLE
*           sequence
*           INTO lv_sequence
*           FROM zonta_relations
*           WHERE id       EQ ls_obj_oc-id
*             AND sequence EQ 1.
*
* end of delete DB 08/05
        IF lv_sequence IS INITIAL.
          RETURN.
        ENDIF.
*<<< add process log
        IF v_prlog = 'X'.
          CLEAR v_cont.
          ADD 1 TO v_cont.
          CLEAR: v_lm1, v_lm2, v_lm3, v_lm4.
          MOVE 'EVENT_AUT : EVENT_TYPE' TO v_lm1.
          MOVE v_cont TO v_lm2.
          MOVE is_sender-catid TO v_lm3.
          MOVE lv_objtype      TO v_lm4.

          CALL METHOD me->set_process_log
            EXPORTING
              i_text1   = v_lm1
              i_text2   = v_lm2
              i_text3   = v_lm3
              i_text4   = v_lm4
              i_process = 'SEND_EVENT'.
        ENDIF.
*add process log >>>

        CASE is_sender-catid.
          WHEN 'BO'.
            CALL FUNCTION 'SWO_QUERY_KEYFIELDS'
              EXPORTING
                objtype = lv_objtype
              TABLES
                info    = lt_info.

            SORT lt_info BY editorder.

            lv_lines = lines( lt_info ).

            lt_info_hdr = lt_info.
            SORT lt_info_hdr BY objtype.
            DELETE ADJACENT DUPLICATES FROM lt_info_hdr
                            COMPARING objtype.

            LOOP AT lt_info_hdr ASSIGNING <fs_info_hdr>.
              APPEND INITIAL LINE TO lt_where_cond_tab ASSIGNING <fs_where_cond_tab>.

              IF ls_relations-tabname = <fs_info_hdr>-objtype."*CECHAVARRIA 7/05/2025

                <fs_where_cond_tab>-tablename = <fs_info_hdr>-objtype.
*CECHAVARRIA 7/05/2025
                LOOP AT lt_info ASSIGNING <fs_info>
                                WHERE objtype EQ <fs_info_hdr>-objtype.

                  APPEND INITIAL LINE TO <fs_where_cond_tab>-where_tab ASSIGNING <fs_where_tab>.

                  lv_tabix = sy-tabix.

                  CASE <fs_info>-reffield.
                    WHEN 'PARTNER'.

                      lv_kunnr = is_sender-instid .

                      SELECT SINGLE kunnr
                             INTO lv_kunnr
                             FROM kna1
                             WHERE kunnr EQ lv_kunnr.
                      IF sy-subrc EQ 0.
                        <fs_info>-reffield = 'KUNNR'.
                      ENDIF.
                  ENDCASE.

*            CONCATENATE 'T'
*                        lv_sequence"'001
*                        '~'
*                        <fs_info>-reffield
*                         INTO lv_key1.

*              IF ls_relations-field_main = <fs_info>-reffield."*CECHAVARRIA 7/05/2025
                  READ TABLE lt_columns INTO ls_columns WITH KEY tabname = ls_relations-tabname fldname = <fs_info>-reffield.
                  IF sy-subrc = 0.
                    lv_key1 = <fs_info>-reffield.
*CECHAVARRIA 7/05/2025
                  ELSE.
                    CONTINUE.
                  ENDIF.
*CECHAVARRIA 7/05/2025

                  lv_vbeln = |{ lc_comilla } { is_sender-instid+lv_pos(<fs_info>-outlength) } { lc_comilla }| .

                  CONDENSE lv_vbeln NO-GAPS.

                  IF lv_tabix NE lv_lines.
                    CONCATENATE lv_key
                                '('
                                lv_key1
                                'EQ'
                                lv_vbeln
                                ') AND'
                                INTO <fs_where_tab>-line"lv_key
                                SEPARATED BY space.
                  ELSE.
                    CONCATENATE lv_key
                             '('
                             lv_key1
                             'EQ'
                             lv_vbeln
                             ')'
                             INTO <fs_where_tab>-line"lv_key
                             SEPARATED BY space.
                  ENDIF.
                  lv_pos = lv_pos + <fs_info>-outlength.
                ENDLOOP.
*cechavarria 7/05/2025
              ELSE.
                <fs_where_cond_tab>-tablename = ls_relations-tabname.

                LOOP AT lt_info ASSIGNING <fs_info>
                                WHERE objtype EQ <fs_info_hdr>-objtype.

                  APPEND INITIAL LINE TO <fs_where_cond_tab>-where_tab ASSIGNING <fs_where_tab>.

                  lv_tabix = sy-tabix.

                  CASE <fs_info>-reffield.
                    WHEN 'PARTNER'.

                      lv_kunnr = is_sender-instid .

                      SELECT SINGLE kunnr
                             INTO lv_kunnr
                             FROM kna1
                             WHERE kunnr EQ lv_kunnr.
                      IF sy-subrc EQ 0.
                        <fs_info>-reffield = 'KUNNR'.
                      ENDIF.
                  ENDCASE.

*            CONCATENATE 'T'
*                        lv_sequence"'001
*                        '~'
*                        <fs_info>-reffield
*                         INTO lv_key1.

                  IF ls_relations-field_main EQ <fs_info>-reffield."*CECHAVARRIA 7/05/2025
                    lv_key1 = <fs_info>-reffield.
*CECHAVARRIA 7/05/2025
                  ELSE.
                    IF ls_relations-field_main IS NOT INITIAL.
                      lv_key1 = ls_relations-field_main.
                    ELSE.
                      CONTINUE.
                    ENDIF.

                  ENDIF.
*CECHAVARRIA 7/05/2025

                  lv_vbeln = |{ lc_comilla } { is_sender-instid+lv_pos(<fs_info>-outlength) } { lc_comilla }| .

                  CONDENSE lv_vbeln NO-GAPS.

                  IF lv_tabix NE lv_lines.
                    CONCATENATE lv_key
                                '('
                                lv_key1
                                'EQ'
                                lv_vbeln
                                ') AND'
                                INTO <fs_where_tab>-line"lv_key
                                SEPARATED BY space.
                  ELSE.
                    CONCATENATE lv_key
                             '('
                             lv_key1
                             'EQ'
                             lv_vbeln
                             ')'
                             INTO <fs_where_tab>-line"lv_key
                             SEPARATED BY space.
                  ENDIF.
                  lv_pos = lv_pos + <fs_info>-outlength.
                ENDLOOP.
              ENDIF.

            ENDLOOP.
          WHEN 'CL'.


*BEGIN CECHAVARRIA 16/05/2025
*          DATA(ls_dd03l) = VALUE #( lt_dd03l_keyfieldbytable[ tabname = ls_relations-tabname ] OPTIONAL ).
            lv_objtype_cl = ls_relations-tabname.
*Get key field by table
            lv_tabix_aux = sy-tabix.
            CLEAR lv_tabix_aux.

            IF lt_dd03l_keyfieldbytable[] IS NOT INITIAL."CECHAVARRIA 20/06/2025

              LOOP AT lt_dd03l_keyfieldbytable INTO DATA(ls_dd03l)
                                               WHERE tabname = ls_relations-tabname.
                ADD 1 TO lv_tabix_aux.

                IF lv_tabix_aux EQ 1.
                  lv_reffld     = ls_dd03l-fieldname.
                ELSE.
                  lv_reffld2    = ls_dd03l-fieldname.
                ENDIF.
              ENDLOOP.
*BEGIN CECHAVARRIA 20/06/2025
*Get key from CDS entity or CDS view
            ELSE.
              CLEAR: lt_primary_key_names[].


              get_fieldskey_cds(
                EXPORTING
                  iv_tabname      = ls_relations-tabname
                IMPORTING
                  ext_keys_fields = lt_primary_key_names
              ).

              LOOP AT lt_primary_key_names INTO DATA(ls_key).
                ADD 1 TO lv_tabix_aux.

                IF lv_tabix_aux EQ 1.
                  lv_reffld     = ls_key.
                ELSE.
                  lv_reffld2    = ls_key.
                  EXIT.
                ENDIF.
              ENDLOOP.
            ENDIF.
*END CECHAVARRIA 20/06/2025

*          CASE is_sender-typeid.
*            WHEN 'CL_CO_WF_PRODUCTION_ORDER'.
*              lv_reffld = 'AUFNR'.
*              lv_objtype_cl = 'AFKO'.
*            WHEN 'CL_MM_PUR_WF_OBJECT_PO'.
*              lv_reffld = 'EBELN'.
*              lv_objtype_cl = 'EKKO'.
*            WHEN 'CL_MMIM_MATDOC_EVENT'.
*              lv_reffld     = 'MBLNR'.
*              lv_reffld2    = 'MJAHR'.
*              lv_objtype_cl = 'MKPF'.
*            WHEN 'CL_SD_BIL_BD_EVENT'.
*              lv_reffld     = 'VBELN'.
*              lv_objtype_cl = 'VBRK'.
*            WHEN 'CL_MDM_PRD_EVENTS'.
*              lv_reffld     = 'MATNR'.
*              lv_objtype_cl = 'MARA'.
*CECHAVARRIA 8/05/2025
*          WHEN 'R_SALESORDERTP'."RAP BO SALES ORDER
*            lv_objtype_cl = ls_relations-tabname.
*            lv_reffld     = ls_relations-field_main.
*          WHEN 'R_PURCHASEORDERTP'."RAP BO Purchase Order
*            lv_objtype_cl = ls_relations-tabname.
*            lv_reffld     = ls_relations-field_main.
*          WHEN 'R_PRODUCTIONORDERTP'."RAP BO Production Order
*            when lv_object."RAP BO
*          lv_objtype_cl = ls_relations-tabname.
*          lv_reffld     = ls_relations-field_main.
*CECHAVARRIA 8/05/2025
*          ENDCASE.
*      ENDCASE.
*END CECHAVARRIA 16/05/2025

            APPEND INITIAL LINE TO lt_where_cond_tab ASSIGNING <fs_where_cond_tab>.
            <fs_where_cond_tab>-tablename = lv_objtype_cl .

            CASE is_sender-typeid.
              WHEN 'CL_MMIM_MATDOC_EVENT'.
                APPEND INITIAL LINE TO <fs_where_cond_tab>-where_tab ASSIGNING <fs_where_tab>.

                lv_key1 = lv_reffld  .

                lv_vbeln = |{ lc_comilla } { is_sender-instid+04(10) } { lc_comilla }| .

                CONDENSE lv_vbeln NO-GAPS.

                CONCATENATE '('
                            lv_key1
                            'EQ'
                            lv_vbeln
                            ') AND'
                            INTO <fs_where_tab>-line"lv_key1
                            SEPARATED BY space.


                lv_key2 = lv_reffld2 .

                lv_vbeln = |{ lc_comilla } { is_sender-instid(04) } { lc_comilla }| .

                CONDENSE lv_vbeln NO-GAPS.

                CONCATENATE
                            <fs_where_tab>-line
                            '('
                            lv_key2
                            'EQ'
                            lv_vbeln
                            ')'
                            INTO <fs_where_tab>-line"lv_key2
                            SEPARATED BY space.

*            CONCATENATE lv_key1
*                        'AND'
*                        lv_key2
*                        INTO lv_key
*                        SEPARATED BY space.
              WHEN OTHERS.
                APPEND INITIAL LINE TO <fs_where_cond_tab>-where_tab ASSIGNING <fs_where_tab>.

*            CONCATENATE 'T'
*                         lv_sequence"'001
*                         '~'
*                         lv_reffld
*                          INTO lv_key.

                lv_key = lv_reffld.

                lv_vbeln = |{ lc_comilla } { is_sender-instid } { lc_comilla }| .

                CONDENSE lv_vbeln NO-GAPS.

                CONCATENATE '('
                            lv_key
                            'EQ'
                            lv_vbeln
                            ')'
                            INTO <fs_where_tab>-line"lv_key
                            SEPARATED BY space.
            ENDCASE.
        ENDCASE.

        CASE i_event.
          WHEN 'DELETE' OR 'DELETED'.
            lv_delete = abap_true.
          WHEN OTHERS.
            lv_update = abap_true.
        ENDCASE.

        SELECT *
           INTO TABLE lt_oc_param
           FROM zonta_oc_param.
        IF sy-subrc EQ 0.
          LOOP AT lt_oc_param ASSIGNING <fs_oc_param>.
            CASE <fs_oc_param>-name.
              WHEN 'RFC_DESTINATION'.
                lv_destination = <fs_oc_param>-low.
              WHEN 'TRANSMISSION_MEDIUM'.
                CASE <fs_oc_param>-low.
                  WHEN 'T'.
                    lv_kdoc = abap_false.
                    lv_tabl = abap_true.
                  WHEN 'K'.
                    lv_kdoc = abap_true.
                    lv_tabl = abap_false.
                  WHEN 'B'.
                    lv_kdoc = abap_true.
                    lv_tabl = abap_true.
                  WHEN OTHERS.
                    lv_kdoc = abap_false.
                    lv_tabl = abap_true.
                ENDCASE.
              WHEN 'USE_ALIAS'.
                lv_alias  = <fs_oc_param>-low.
            ENDCASE.
          ENDLOOP.
        ENDIF.

        IF lv_alias EQ abap_false.
          lv_fieldname = abap_true.
        ENDIF.

        SELECT * "#EC CI_NOFIRST
               INTO TABLE lt_endpoints
               FROM zonta_oc_endp
               WHERE domainv       EQ ls_obj_oc-domainv
                 AND business_proc EQ ls_obj_oc-business_proc.

*<<< add process log
        IF v_prlog = 'X'.

          CLEAR v_cont.
          LOOP AT lt_where_cond_tab ASSIGNING <fs_where_cond_tab>.
            ADD 1 TO v_cont.
            CLEAR: v_lm1, v_lm2, v_lm3, v_lm4.
            MOVE 'EVENT_AUT : WHERE_TAB' TO v_lm1.
            MOVE v_cont TO v_lm2.
            MOVE <fs_where_cond_tab>-tablename TO v_lm3.

            LOOP AT <fs_where_cond_tab>-where_tab INTO <fs_where_tab>-line.
              CONCATENATE v_lm4 <fs_where_tab>-line INTO v_lm4 SEPARATED BY ','.

            ENDLOOP.
            CALL METHOD me->set_process_log
              EXPORTING
                i_text1   = v_lm1
                i_text2   = v_lm2
                i_text3   = v_lm3
                i_text4   = v_lm4
                i_process = 'SEND_EVENT'.
          ENDLOOP.
        ENDIF.
*add process log >>>

        CALL METHOD me->get_relation
          EXPORTING
            iv_domainv        = ls_obj_oc-domainv
            iv_business_proc  = ls_obj_oc-business_proc
            iv_kdoc           = lv_kdoc
            iv_table          = lv_tabl
            iv_key_queue      = lv_key
*           iv_ddic           =
            iv_dest           = lv_destination
            iv_update         = lv_update
            iv_delete         = lv_delete
            iv_instid         = is_sender-instid
*           iv_alias          = lv_alias
            iv_fieldname      = lv_fieldname
            it_endpoints      = lt_endpoints
            it_where_cond_tab = lt_where_cond_tab
          EXCEPTIONS
            not_data_found    = 1
            OTHERS            = 2.
        IF sy-subrc <> 0.
*     Implement suitable error handling here
        ENDIF.
      ENDIF.  "++DB
    ENDLOOP.  "++DB

  ENDMETHOD.


METHOD SEND_JSON_ANY.
  DATA: dref_table_root TYPE REF TO data,
        e_size          TYPE zonde_oc_num30,
        e_records       TYPE zonde_oc_num30,
        lv_return       TYPE string,
        lv_recordst     TYPE sy-tabix,
        lv_response     TYPE string,
        lv_key          TYPE string,
        lv_keys_temp    TYPE string,
        lv_max_records  TYPE zonde_registrosn.

  FIELD-SYMBOLS: <fs_root>            TYPE any,  "ty_oneconnect, --DB
                 <fs_oneconnect>      TYPE any,
                 <fs_properties>      TYPE any,
                 <fs_metadata>        TYPE any,
                 <fs_body_root>       TYPE any,
                 <fs_json>            TYPE any,
                 <fs_field_metadata>  TYPE any,
                 <fs_metadata_line>   TYPE any,
                 <fs_field>           TYPE any,
                 <fs_line>            TYPE any,
                 <fs_table_body_line> TYPE any,
                 <fs_body>            TYPE STANDARD TABLE,
                 <fs_metadata_root>   TYPE STANDARD TABLE,
                 <fs_table>           TYPE STANDARD TABLE,
                 <fs_table2>          TYPE STANDARD TABLE,
                 <fs_data>            TYPE any,
                 <fs_table_line>      TYPE any.

  gv_update = iv_update.
  gv_delete = iv_delete.

  me->append_slg1_log(
    EXPORTING
      iv_tabname    = space
*       iv_key        =
      iv_message_v1 = '*** Any Internal Table Process TABLE***'
      iv_message_v2 = space
      iv_message_v3 = space
      iv_mestyp     = 'S' ).

*** Get Relations
  SELECT SINGLE *
         INTO gs_oc_obj
         FROM zonta_obj_oc
         WHERE domainv       EQ 'ANY'
           AND business_proc EQ 'ANY'.

  IF sy-subrc EQ 0.
    SELECT SINGLE low
           INTO gv_dest
           FROM zonta_oc_param
           WHERE name EQ 'RFC_DESTINATION'
             AND type EQ 'P'
             AND numb EQ 1.

    IF sy-subrc EQ 0.
*      CREATE DATA dref_table_root TYPE ty_oneconnect.  --DB
      IF gs_oc_obj-data EQ abap_true.
        CREATE DATA dref_table_root TYPE ty_oneconnect_meta.
      ELSE.
        CREATE DATA dref_table_root TYPE ty_oneconnect.
      ENDIF.

      ASSIGN dref_table_root->* TO <fs_root>.

      ASSIGN COMPONENT 'ONECONNECT' OF STRUCTURE <fs_root> TO <fs_oneconnect>.

      ASSIGN COMPONENT 'PROPERTIES' OF STRUCTURE <fs_oneconnect> TO <fs_properties>.
      me->get_data_properties_any( CHANGING cs_properties = <fs_properties> ) .

      ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_oneconnect> TO <fs_metadata_root>.

      APPEND INITIAL LINE TO <fs_metadata_root> ASSIGNING <fs_metadata>.

      ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_metadata> TO <fs_field_metadata>.
      <fs_field_metadata> = iv_tabname.
      TRANSLATE <fs_field_metadata> TO LOWER CASE.

      ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_metadata> TO <fs_metadata_line>.

      ASSIGN COMPONENT 'BODY' OF STRUCTURE <fs_oneconnect> TO <fs_body_root>.

      ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_body_root> TO <fs_field>.

      <fs_field> = iv_tabname.
      TRANSLATE <fs_field> TO LOWER CASE.

      ASSIGN COMPONENT 'DATA' OF STRUCTURE <fs_body_root> TO <fs_table_body_line> .

      CALL METHOD me->set_table_any
        EXPORTING
          it_fcat  = it_fieldcat
        RECEIVING
          rt_table = <fs_table_body_line>.

      ASSIGN <fs_table_body_line>->* TO <fs_table>.

      ASSIGN it_data TO <fs_table2>.

      LOOP AT <fs_table2> ASSIGNING <fs_data>.
        APPEND INITIAL LINE TO <fs_table> ASSIGNING <fs_table_line>.
        MOVE-CORRESPONDING <fs_data> TO <fs_table_line> .
      ENDLOOP.

      me->set_metadata_node_any( EXPORTING
                                     it_fcat    = it_fieldcat
                                 CHANGING
                                     ct_metadata = <fs_metadata_line> ).


* Get Fields to b'e exported

      LOOP AT it_data ASSIGNING <fs_data>.

        CALL METHOD me->set_key_any
          EXPORTING
            it_fcat = it_fieldcat
            is_line = <fs_data>
          RECEIVING
            rv_key  = lv_key.

        IF lv_keys_temp NE lv_key.
          lv_keys_temp   = lv_key.
          lv_max_records = lv_max_records + 1.

          gv_recordst_obj = gv_recordst_obj + 1.
        ENDIF.

        me->append_slg1_log( iv_tabname = iv_tabname
                             iv_mestyp  = 'S'
                             iv_key     = lv_key ).

        IF lv_max_records EQ gs_oc_obj-no_registros.
          APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.

          <fs_json>  = zoncl_ui2_cl_json=>serialize(
                   data             = <fs_root>
                   compress         = abap_false "abap_true
                   assoc_arrays     = abap_true
                   assoc_arrays_opt = abap_true
                   pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).

          CLEAR: lv_max_records,
                 <fs_body>.
        ENDIF.
      ENDLOOP.

      IF lv_max_records LT gs_oc_obj-no_registros.
        APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.

        <fs_json>  = zoncl_ui2_cl_json=>serialize(
                 data             = <fs_root>
                 compress         = abap_false "abap_true
                 assoc_arrays     = abap_true
                 assoc_arrays_opt = abap_true
                 pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).
      ENDIF.


      LOOP AT gt_json INTO gv_json.
        me->pretty_json( EXPORTING iv_mode = c_table
                         CHANGING  cv_json = gv_json ).

        me->send_json_http_con(
                             EXPORTING
                               i_dest     = gv_dest
                             IMPORTING
                               e_return   = lv_return
                               e_size     = e_size
                               e_records  = e_records
*                       receiving
                               e_response = lv_response ).

        gv_sizet    = gv_sizet + e_size.

        gv_recordst = gv_recordst + 1.
      ENDLOOP.

      me->send_json_result( ).

      me->update_slg1_log( it_log_ext = gt_log_ext ).
    ENDIF.
  ENDIF.
ENDMETHOD.


METHOD send_json_any_table.
  DATA: dref_table_root  TYPE REF TO data,
        dref_table       TYPE REF TO data,
        lo_table         TYPE REF TO data,
        lo_data          TYPE REF TO data,
        lt_fcat          TYPE slis_t_fieldcat_alv,
        e_size           TYPE zonde_oc_num30,
        e_records        TYPE zonde_oc_num30,
        lt_keys          TYPE tty_where,
        lv_return        TYPE string,
        lv_recordst      TYPE sy-tabix,
        lv_response      TYPE string,
        lv_key           TYPE string,
        lv_keys_temp     TYPE string,
        lv_max_records   TYPE zonde_registrosn,
        lv_where         TYPE rsds_where_tab,
        lv_alias         TYPE zonde_aliastab,
        lv_fields        TYPE string,
        lv_result        TYPE string,
        lv_error(200)    TYPE c,
*BEGIN CECHAVARRIA 09/07/2025
        lv_is_cds_entity TYPE abap_bool,
        lt_fields        TYPE TABLE OF line,
*END CECHAVARRIA 09/07/2025
        lo_ref           TYPE REF TO cx_sy_dynamic_osql_semantics.

  FIELD-SYMBOLS: <fs_root>            TYPE any, "ty_oneconnect,
                 <fs_oneconnect>      TYPE any,
                 <fs_properties>      TYPE any,
                 <fs_metadata>        TYPE any,
                 <fs_body_root>       TYPE any,
                 <fs_json>            TYPE any,
                 <fs_field_metadata>  TYPE any,
                 <fs_metadata_line>   TYPE any,
                 <fs_field>           TYPE any,
                 <fs_line>            TYPE any,
                 <fs_table_body_line> TYPE any,
                 <fs_body>            TYPE STANDARD TABLE,
                 <fs_metadata_root>   TYPE STANDARD TABLE,
                 <fs_table>           TYPE STANDARD TABLE,
                 <fs_table2>          TYPE ANY TABLE,
                 <fs_data>            TYPE any,
                 <fs_table_line>      TYPE any,
                 <fs_key>             TYPE any,
                 <fs_key_main>        TYPE any,
                 <fs_keys_event>      TYPE LINE OF tty_where.

  gv_update    = iv_update.
  gv_delete    = iv_delete.
  gv_anytable  = iv_tabname.
  gt_where     = it_where.
  gv_entity    = 'ANY'.
  gv_domainv   = 'ANY'.
  gv_dest      = iv_dest.
  gv_fieldname = iv_fieldname.
  gv_bothnames = iv_bothnames.


  me->append_slg1_log(
    EXPORTING
      iv_tabname    = space
*       iv_key        =
      iv_message_v1 = '*** Any Table Process TABLE***'
      iv_message_v2 = space
      iv_message_v3 = space
      iv_mestyp     = 'S' ).

*** Get Columns
  SELECT * "#EC CI_NOFIRST
         INTO TABLE gt_columns_all
         FROM zonta_oc_col_all
         WHERE tabname EQ iv_tabname
           AND alias_tabname EQ iv_aliastab."CECHAVARRIA 09/07/2025
*** Get Field Cat
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = iv_tabname
    CHANGING
      ct_fieldcat            = lt_fcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname        = iv_tabname
    TABLES
      dfies_tab      = gt_dfies_tab
    EXCEPTIONS
      not_found      = 1
      internal_error = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

*** Get Relations
  SELECT SINGLE *
         INTO gs_oc_obj
         FROM zonta_obj_oc
         WHERE domainv       EQ 'ANY'
           AND business_proc EQ 'ANY'.

  IF sy-subrc EQ 0.

    SELECT SINGLE alias_tabname
           INTO lv_alias
           FROM zonta_oc_anyalia
           WHERE tabname EQ iv_tabname.
    IF gv_dest IS INITIAL.
      SELECT SINGLE low
             INTO gv_dest
             FROM zonta_oc_param
             WHERE name EQ 'RFC_DESTINATION'
               AND type EQ 'P'
               AND numb EQ 1.
    ENDIF.

    IF sy-subrc EQ 0.
      IF gs_oc_obj-data EQ abap_true.
        CREATE DATA dref_table_root TYPE ty_oneconnect_meta.
      ELSE.
        CREATE DATA dref_table_root TYPE ty_oneconnect.
      ENDIF.
      ASSIGN dref_table_root->* TO <fs_root>.

      ASSIGN COMPONENT 'ONECONNECT' OF STRUCTURE <fs_root> TO <fs_oneconnect>.

      ASSIGN COMPONENT 'PROPERTIES' OF STRUCTURE <fs_oneconnect> TO <fs_properties>.
      me->get_data_properties_any( CHANGING cs_properties = <fs_properties> ) .

      ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_oneconnect> TO <fs_metadata_root>.

      APPEND INITIAL LINE TO <fs_metadata_root> ASSIGNING <fs_metadata>.

      ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_metadata> TO <fs_field_metadata>.

      IF iv_fieldname IS INITIAL.
        IF NOT iv_bothnames IS INITIAL.
          <fs_field_metadata> = iv_tabname &&
                                '_'        &&
                                lv_alias.
        ELSE.
          IF NOT lv_alias IS INITIAL.
            <fs_field_metadata> = lv_alias.
          ELSE.
            <fs_field_metadata> = iv_tabname.
          ENDIF.
        ENDIF.
      ELSE.
        <fs_field_metadata> = iv_tabname.
      ENDIF.

*      TRANSLATE <fs_field_metadata> TO LOWER CASE.

      ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_metadata> TO <fs_metadata_line>.

      ASSIGN COMPONENT 'BODY' OF STRUCTURE <fs_oneconnect> TO <fs_body_root>.

      ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_body_root> TO <fs_field>.

      IF iv_fieldname IS INITIAL.
        IF NOT iv_bothnames IS INITIAL.
          <fs_field> = iv_tabname &&
                       '_'        &&
                       lv_alias.
        ELSE.
          IF NOT lv_alias IS INITIAL.
            <fs_field> = lv_alias.
          ELSE.
            <fs_field> = iv_tabname.
          ENDIF.
        ENDIF.
      ELSE.
        <fs_field> = iv_tabname.
      ENDIF.

*      TRANSLATE <fs_field> TO LOWER CASE.

      ASSIGN COMPONENT 'DATA' OF STRUCTURE <fs_body_root> TO <fs_table_body_line> .

      CALL METHOD me->set_table_any
        EXPORTING
          iv_alias = iv_alias
          it_fcat  = lt_fcat
        RECEIVING
          rt_table = <fs_table_body_line>.

      ASSIGN <fs_table_body_line>->* TO <fs_body>.


      CALL METHOD me->set_table_any
        EXPORTING
          iv_alias = iv_fieldname
          it_fcat  = lt_fcat
        RECEIVING
          rt_table = lo_data.


      ASSIGN lo_data->* TO <fs_table>.

*BEGIN CECHAVARRIA 09/07/2025
      lv_is_cds_entity = me->is_cds_entity( iv_tabname ).
      IF abap_false = lv_is_cds_entity.
*END CECHAVARRIA 09/07/2025

*      lv_where  = me->set_where( iv_any = abap_true ).
        lv_fields = me->set_fields( iv_alias = iv_fieldname ).

*BEGIN CECHAVARRIA 09/07/2025
      ELSE.
        me->set_fields_in_table( EXPORTING iv_tabname = iv_tabname
                                 IMPORTING et_fields  = lt_fields ).
      ENDIF.
*END CECHAVARRIA 09/07/2025

      IF gt_where IS INITIAL.
        lv_where  = me->set_where( iv_any = abap_true ).

        me->set_process( ).

        gt_where = lv_where.
      ELSE.
        lv_where = gt_where.
      ENDIF.

      IF lv_where IS INITIAL.
        MESSAGE i000(fb) WITH 'No filter selected'.
        RETURN.
      ENDIF.



      TRY.
          IF lv_fields IS INITIAL.
            lv_fields = '*'.
          ENDIF.


          IF abap_false = lv_is_cds_entity."CECHAVARRIA 09/07/2025

            SELECT  (lv_fields) "*
              INTO CORRESPONDING FIELDS OF TABLE <fs_table>
              FROM (iv_tabname)
             WHERE (lv_where).

*BEGIN CECHAVARRIA 09/07/2025
          ELSE.

            TRY.
                SELECT (lt_fields)
                  FROM (iv_tabname)
                 WHERE (lv_where)
                   INTO CORRESPONDING FIELDS OF TABLE @<fs_table>.

              CATCH cx_sy_no_handler INTO DATA(lo_error).
                DATA(lv_errorw) = lo_error->get_text( ).
            ENDTRY.
          ENDIF.
*END CECHAVARRIA 09/07/2025

          IF sy-subrc NE 0.
            MESSAGE i000(fb) WITH 'No data found'.

            me->append_slg1_log(
                                 EXPORTING
                                   iv_tabname    = space
*                               iv_key        =
                                   iv_message_v1 = 'No data found'
                                   iv_message_v2 = space
                                   iv_message_v3 = space
                                   iv_mestyp     = 'S' ).

            RETURN.
          ENDIF.
        CATCH cx_sy_dynamic_osql_semantics INTO lo_ref.
          lv_result = lo_ref->get_text( ).

          lv_error = lv_result.

          sy-msgv1 = lv_error+0(50).
          sy-msgv2 = lv_error+50(50).
          sy-msgv3 = lv_error+100(50).
          sy-msgv4 = lv_error+150(50).


          MESSAGE i000(fb) WITH sy-msgv1
                                sy-msgv2
                                sy-msgv3
                                sy-msgv4 .

      ENDTRY.

      IF NOT gv_batch IS INITIAL.
        me->execute_batch( EXPORTING
                              iv_anytab    = abap_true
                              iv_tabname   = iv_tabname ).
        RETURN.
      ENDIF.

      me->set_metadata_node_any( EXPORTING
                                     iv_alias   = iv_fieldname
                                     it_fcat    = lt_fcat
                                 CHANGING
                                     ct_metadata = <fs_metadata_line> ).


* Get Fields to b'e exported

      gv_recordst =  gv_recordst + lv_recordst.

      CLEAR lt_keys .

      LOOP AT <fs_table> ASSIGNING <fs_data>.

        CLEAR lt_keys.

        CALL METHOD me->set_key_any
          EXPORTING
            iv_alias = iv_alias
            it_fcat  = lt_fcat
            is_line  = <fs_data>
          RECEIVING
            rv_key   = lv_key.

        ASSIGN lv_key TO <fs_key>.

        IF lv_keys_temp NE lv_key.
          lv_keys_temp   = lv_key.
          lv_max_records = lv_max_records + 1.

          gv_recordst_obj = gv_recordst_obj + 1.
        ENDIF.


        me->append_slg1_log( iv_tabname = iv_tabname
                             iv_mestyp  = 'S'
                             iv_key     = lv_key ).

        APPEND INITIAL LINE TO <fs_body> ASSIGNING <fs_line> .

        MOVE-CORRESPONDING <fs_data> TO <fs_line> .

*** Convert Exit
        me->convertion_exit( EXPORTING iv_tabname = iv_tabname
                             CHANGING  cs_string  = <fs_line> ).

*** Fill Even ID
        IF gs_oc_obj-eventid  EQ abap_true OR
           gs_oc_obj-metadata EQ abap_true.
          IF <fs_key> IS ASSIGNED.

            APPEND INITIAL LINE TO lt_keys ASSIGNING <fs_keys_event>.
            <fs_keys_event>-line = <fs_key>.
          ENDIF.

          me->get_eventid(  EXPORTING it_keys = lt_keys
                            CHANGING cs_line_json = <fs_line> ).
        ENDIF.

        IF lv_max_records EQ gs_oc_obj-no_registros.
          APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.

          <fs_json>  = zoncl_ui2_cl_json=>serialize(
                   data             = <fs_root>
                   compress         = abap_false "abap_true
                   assoc_arrays     = abap_true
                   assoc_arrays_opt = abap_true
                   pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).

          REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>.

          REPLACE 'TABL' WITH 'TABLE' INTO <fs_json>.

          CLEAR: lv_max_records,
                 <fs_body>.
        ENDIF.
      ENDLOOP.

      IF lv_max_records LT gs_oc_obj-no_registros.
        APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.

        <fs_json>  = zoncl_ui2_cl_json=>serialize(
                 data             = <fs_root>
                 compress         = abap_false "abap_true
                 assoc_arrays     = abap_true
                 assoc_arrays_opt = abap_true
                 pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).

        REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>.

        REPLACE 'TABL' WITH 'TABLE' INTO <fs_json>.
      ENDIF.

      LOOP AT gt_json INTO gv_json.

        me->pretty_json_any( EXPORTING iv_mode = c_table
                             CHANGING  cv_json = gv_json ).


        me->send_json_http_con(
                             EXPORTING
                               i_dest     = gv_dest
                             IMPORTING
                               e_return   = lv_return
                               e_size     = e_size
                               e_records  = e_records
*                       receiving
                               e_response = lv_response ).

        gv_sizet    = gv_sizet + e_size.

        gv_recordst = gv_recordst + 1.
      ENDLOOP.

      me->send_json_result( ).

      me->update_slg1_log( it_log_ext = gt_log_ext ).
    ENDIF.
  ENDIF.
ENDMETHOD.


METHOD send_json_any_table_cond.
  DATA: dref_table_root TYPE REF TO data,
        dref_table      TYPE REF TO data,
        lo_table        TYPE REF TO data,
        lo_data         TYPE REF TO data,
        lt_fcat         TYPE slis_t_fieldcat_alv,
        e_size          TYPE zonde_oc_num30,
        e_records       TYPE zonde_oc_num30,
        lt_keys         TYPE tty_where,
        lv_return       TYPE string,
        lv_recordst     TYPE sy-tabix,
        lv_response     TYPE string,
        lv_key          TYPE string,
        lv_keys_temp    TYPE string,
        lv_max_records  TYPE zonde_registrosn,
        lv_where        TYPE rsds_where_tab,
        lv_alias        TYPE zonde_aliastab,
        lv_fields       TYPE string,
        lv_message_v1   TYPE symsgv.

  FIELD-SYMBOLS: <fs_root>            TYPE any, "ty_oneconnect, --DB
                 <fs_oneconnect>      TYPE any,
                 <fs_properties>      TYPE any,
                 <fs_metadata>        TYPE any,
                 <fs_body_root>       TYPE any,
                 <fs_json>            TYPE any,
                 <fs_field_metadata>  TYPE any,
                 <fs_metadata_line>   TYPE any,
                 <fs_field>           TYPE any,
                 <fs_line>            TYPE any,
                 <fs_table_body_line> TYPE any,
                 <fs_body>            TYPE STANDARD TABLE,
                 <fs_metadata_root>   TYPE STANDARD TABLE,
                 <fs_table>           TYPE STANDARD TABLE,
                 <fs_table2>          TYPE ANY TABLE,
                 <fs_data>            TYPE any,
                 <fs_table_line>      TYPE any,
                 <fs_key>             TYPE any,
                 <fs_key_main>        TYPE any,
                 <fs_keys_event>      TYPE LINE OF tty_where.

  gv_update   = iv_update.
  gv_delete   = iv_delete.
  gv_anytable = iv_tabname.
  gt_where    = it_where.
  gv_entity   = 'ANY'.
  gv_domainv  = 'ANY'.
  IF iv_alias IS INITIAL.
    gv_fieldname = abap_true.
  ENDIF.


  CONCATENATE '*** Price Condition Table '
              iv_tabname
              ' Process TABLE***'
              INTO lv_message_v1
              SEPARATED BY space.

  me->append_slg1_log(
    EXPORTING
      iv_tabname    = space
*     iv_key        =
      iv_message_v1 = lv_message_v1
      iv_message_v2 = space
      iv_message_v3 = space
      iv_mestyp     = 'S' ).

*** Get Columns
  SELECT * "#EC CI_NOFIRST
         INTO TABLE gt_columns_all
         FROM zonta_oc_col_all
         WHERE tabname EQ iv_tabname.
*** Get Field Cat
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = iv_tabname
    CHANGING
      ct_fieldcat            = lt_fcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname        = iv_tabname
    TABLES
      dfies_tab      = gt_dfies_tab
    EXCEPTIONS
      not_found      = 1
      internal_error = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

*** Get Relations
  SELECT SINGLE *
         INTO gs_oc_obj
         FROM zonta_obj_oc
         WHERE domainv       EQ 'ANY'
           AND business_proc EQ 'ANY'.

  IF sy-subrc EQ 0.

    SELECT SINGLE alias_tabname
           INTO lv_alias
           FROM zonta_oc_anyalia
           WHERE tabname EQ iv_tabname.

    SELECT SINGLE low
           INTO gv_dest
           FROM zonta_oc_param
           WHERE name EQ 'RFC_DESTINATION'
             AND type EQ 'P'
             AND numb EQ 1.

    IF sy-subrc EQ 0.
*      CREATE DATA dref_table_root TYPE ty_oneconnect.  --DB
      IF gs_oc_obj-data EQ abap_true.
        CREATE DATA dref_table_root TYPE ty_oneconnect_meta.
      ELSE.
        CREATE DATA dref_table_root TYPE ty_oneconnect.
      ENDIF.

      ASSIGN dref_table_root->* TO <fs_root>.

      ASSIGN COMPONENT 'ONECONNECT' OF STRUCTURE <fs_root> TO <fs_oneconnect>.

      ASSIGN COMPONENT 'PROPERTIES' OF STRUCTURE <fs_oneconnect> TO <fs_properties>.
      me->get_data_properties_any( CHANGING cs_properties = <fs_properties> ) .

      ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_oneconnect> TO <fs_metadata_root>.

      APPEND INITIAL LINE TO <fs_metadata_root> ASSIGNING <fs_metadata>.

      ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_metadata> TO <fs_field_metadata>.
      IF NOT iv_alias IS INITIAL.
        IF NOT lv_alias IS INITIAL.
          <fs_field_metadata> = lv_alias.
        ELSE.
          <fs_field_metadata> = iv_tabname.
        ENDIF.
      ELSE.
        <fs_field_metadata> = iv_tabname.
      ENDIF.
*      TRANSLATE <fs_field_metadata> TO LOWER CASE.

      ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_metadata> TO <fs_metadata_line>.

      ASSIGN COMPONENT 'BODY' OF STRUCTURE <fs_oneconnect> TO <fs_body_root>.

      ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_body_root> TO <fs_field>.

      IF NOT iv_alias IS INITIAL.
        IF NOT lv_alias IS INITIAL.
          <fs_field> = lv_alias.
        ELSE.
          <fs_field> = iv_tabname.
        ENDIF.
      ELSE.
        <fs_field> = iv_tabname.
      ENDIF.

*      TRANSLATE <fs_field> TO LOWER CASE.

      ASSIGN COMPONENT 'DATA' OF STRUCTURE <fs_body_root> TO <fs_table_body_line> .

      CALL METHOD me->set_table_any_cond
        EXPORTING
          iv_alias = iv_alias
          it_fcat  = lt_fcat
        RECEIVING
          rt_table = <fs_table_body_line>.

      ASSIGN <fs_table_body_line>->* TO <fs_body>.


      CALL METHOD me->set_table_any_cond
        EXPORTING
          iv_alias = iv_alias
          it_fcat  = lt_fcat
        RECEIVING
          rt_table = lo_data.


      ASSIGN lo_data->* TO <fs_table>.

*      lv_where  = me->set_where( iv_any = abap_true ).
      lv_fields = me->set_fields( iv_alias = iv_alias ).

      IF gt_where IS INITIAL.
        lv_where  = me->set_where( iv_any = abap_true ).

        me->set_process( ).

        gt_where = lv_where.
      ELSE.
        lv_where = gt_where.
      ENDIF.

      IF lv_where IS INITIAL.
*        MESSAGE i000(fb) WITH 'No filter selected'.
        RETURN.
      ENDIF.

      SELECT  (lv_fields) "*
              INTO CORRESPONDING FIELDS OF TABLE <fs_table>
              FROM (iv_tabname)
             WHERE (lv_where).
      IF sy-subrc NE 0.
*        MESSAGE i000(fb) WITH 'No data found'.

        me->append_slg1_log(
          EXPORTING
            iv_tabname    = space
*           iv_key        =
            iv_message_v1 = 'No data found'
            iv_message_v2 = space
            iv_message_v3 = space
            iv_mestyp     = 'S' ).

        RETURN.
      ENDIF.

      IF NOT gv_batch IS INITIAL.
        me->execute_batch( EXPORTING iv_anytab  = abap_true
                                     iv_tabname = iv_tabname ).
        RETURN.
      ENDIF.

      me->set_metadata_node_any( EXPORTING iv_alias    = iv_alias
                                           it_fcat     = lt_fcat
                                 CHANGING  ct_metadata = <fs_metadata_line> ).


* Get Fields to b'e exported

      gv_recordst =  gv_recordst + lv_recordst.

      CLEAR lt_keys .

      LOOP AT <fs_table> ASSIGNING <fs_data>.

        CLEAR lt_keys.

        CALL METHOD me->set_key_any
          EXPORTING
            iv_alias = iv_alias
            it_fcat  = lt_fcat
            is_line  = <fs_data>
          RECEIVING
            rv_key   = lv_key.

        ASSIGN lv_key TO <fs_key>.

        IF lv_keys_temp NE lv_key.
          lv_keys_temp   = lv_key.
          lv_max_records = lv_max_records + 1.

          gv_recordst_obj = gv_recordst_obj + 1.
        ENDIF.


        me->append_slg1_log( iv_tabname = iv_tabname
                             iv_mestyp  = 'S'
                             iv_key     = lv_key ).

        APPEND INITIAL LINE TO <fs_body> ASSIGNING <fs_line> .

        MOVE-CORRESPONDING <fs_data> TO <fs_line> .

*** Convert Exit
        me->convertion_exit( EXPORTING iv_tabname = iv_tabname
                             CHANGING  cs_string  = <fs_line> ).

*** Fill Even ID
        IF gs_oc_obj-eventid  EQ abap_true OR
           gs_oc_obj-metadata EQ abap_true.

          IF <fs_key> IS ASSIGNED.

            APPEND INITIAL LINE TO lt_keys ASSIGNING <fs_keys_event>.
            <fs_keys_event>-line = <fs_key>.
          ENDIF.

          me->get_eventid( EXPORTING it_keys      = lt_keys
                           CHANGING  cs_line_json = <fs_line> ).
        ENDIF.

        IF lv_max_records EQ gs_oc_obj-no_registros.
          APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.

          <fs_json> = zoncl_ui2_cl_json=>serialize(
            data             = <fs_root>
            compress         = abap_false "abap_true
            assoc_arrays     = abap_true
            assoc_arrays_opt = abap_true
            pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).

          REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>.

          REPLACE 'TABL' WITH 'TABLE' INTO <fs_json>.

          CLEAR: lv_max_records,
                 <fs_body>.
        ENDIF.
      ENDLOOP.

      IF lv_max_records LT gs_oc_obj-no_registros.
        APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.

        <fs_json> = zoncl_ui2_cl_json=>serialize(
          data             = <fs_root>
          compress         = abap_false "abap_true
          assoc_arrays     = abap_true
          assoc_arrays_opt = abap_true
          pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).

        REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>.

        REPLACE 'TABL' WITH 'TABLE' INTO <fs_json>.
      ENDIF.

      gv_sending = c_table.

      LOOP AT gt_json INTO gv_json.

        me->pretty_json_any( EXPORTING iv_mode = c_table
                             CHANGING  cv_json = gv_json ).

        me->send_json_http_con(
          EXPORTING
            i_dest     = gv_dest
          IMPORTING
            e_return   = lv_return
            e_size     = e_size
            e_records  = e_records
*                       receiving
            e_response = lv_response ).

        gv_sizet    = gv_sizet + e_size.

        gv_recordst = gv_recordst + 1.
      ENDLOOP.

*      me->send_json_result( ).

      me->update_slg1_log( it_log_ext = gt_log_ext ).
    ENDIF.
  ENDIF.
ENDMETHOD.


METHOD send_json_any_table_hcm.
  DATA: dref_table_root TYPE REF TO data,
        dref_table      TYPE REF TO data,
        lo_table        TYPE REF TO data,
        lo_data         TYPE REF TO data,
        lt_fcat         TYPE slis_t_fieldcat_alv,
        e_size          TYPE zonde_oc_num30,
        e_records       TYPE zonde_oc_num30,
        lt_keys         TYPE tty_where,
        lv_return       TYPE string,
        lv_recordst     TYPE sy-tabix,
        lv_response     TYPE string,
        lv_key          TYPE string,
        lv_keys_temp    TYPE string,
        lv_max_records  TYPE zonde_registrosn,
        lv_where        TYPE rsds_where_tab,
        lv_alias        TYPE zonde_aliastab,
        lv_fields       TYPE string,
        lv_message_v1   TYPE symsgv.

  FIELD-SYMBOLS: <fs_root>            TYPE any, "ty_oneconnect, --DB
                 <fs_oneconnect>      TYPE any,
                 <fs_properties>      TYPE any,
                 <fs_metadata>        TYPE any,
                 <fs_body_root>       TYPE any,
                 <fs_json>            TYPE any,
                 <fs_field_metadata>  TYPE any,
                 <fs_metadata_line>   TYPE any,
                 <fs_field>           TYPE any,
                 <fs_line>            TYPE any,
                 <fs_table_body_line> TYPE any,
                 <fs_body>            TYPE STANDARD TABLE,
                 <fs_metadata_root>   TYPE STANDARD TABLE,
                 <fs_table>           TYPE STANDARD TABLE,
                 <fs_table2>          TYPE ANY TABLE,
                 <fs_data>            TYPE any,
                 <fs_table_line>      TYPE any,
                 <fs_key>             TYPE any,
                 <fs_key_main>        TYPE any,
                 <fs_keys_event>      TYPE LINE OF tty_where.

  gv_update   = iv_update.
  gv_delete   = iv_delete.
  gv_anytable = iv_tabname.
  gt_where    = it_where.
  gv_entity   = 'ANY'.
  gv_domainv  = 'ANY'.

  IF iv_alias IS INITIAL.
    gv_fieldname = abap_true.
  ENDIF.


  CONCATENATE '*** HCM Table '
              iv_tabname
              ' Process TABLE***'
              INTO lv_message_v1
              SEPARATED BY space.

  me->append_slg1_log(
    EXPORTING
      iv_tabname    = space
*       iv_key        =
      iv_message_v1 = lv_message_v1
      iv_message_v2 = space
      iv_message_v3 = space
      iv_mestyp     = 'S' ).

*** Get Columns
  SELECT *
         INTO TABLE gt_columns_all
         FROM ZONTA_OC_COL_ALL
         WHERE tabname EQ iv_tabname.
*** Get Field Cat
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = iv_tabname
    CHANGING
      ct_fieldcat            = lt_fcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname        = iv_tabname
    TABLES
      dfies_tab      = gt_dfies_tab
    EXCEPTIONS
      not_found      = 1
      internal_error = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

*** Get Relations
  SELECT SINGLE *
         INTO gs_oc_obj
         FROM zonta_obj_oc
         WHERE domainv       EQ 'ANY'
           AND business_proc EQ 'ANY'.

  IF sy-subrc EQ 0.

    SELECT SINGLE alias_tabname
           INTO lv_alias
           FROM zonta_oc_anyalia
           WHERE tabname EQ iv_tabname.

    SELECT SINGLE low
           INTO gv_dest
           FROM zonta_oc_param
           WHERE name EQ 'RFC_DESTINATION'
             AND type EQ 'P'
             AND numb EQ 1.

    IF sy-subrc EQ 0.
*      CREATE DATA dref_table_root TYPE ty_oneconnect.  --DB
      IF gs_oc_obj-data EQ abap_true.
        CREATE DATA dref_table_root TYPE ty_oneconnect_meta.
      ELSE.
        CREATE DATA dref_table_root TYPE ty_oneconnect.
      ENDIF.

      ASSIGN dref_table_root->* TO <fs_root>.

      ASSIGN COMPONENT 'ONECONNECT' OF STRUCTURE <fs_root> TO <fs_oneconnect>.

      ASSIGN COMPONENT 'PROPERTIES' OF STRUCTURE <fs_oneconnect> TO <fs_properties>.
      me->get_data_properties_any( CHANGING cs_properties = <fs_properties> ) .

      ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_oneconnect> TO <fs_metadata_root>.

      APPEND INITIAL LINE TO <fs_metadata_root> ASSIGNING <fs_metadata>.

      ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_metadata> TO <fs_field_metadata>.
      IF NOT iv_alias IS INITIAL.
        IF NOT lv_alias IS INITIAL.
          <fs_field_metadata> = lv_alias.
        ELSE.
          <fs_field_metadata> = iv_tabname.
        ENDIF.
      ELSE.
        <fs_field_metadata> = iv_tabname.
      ENDIF.
*      TRANSLATE <fs_field_metadata> TO LOWER CASE.

      ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_metadata> TO <fs_metadata_line>.

      ASSIGN COMPONENT 'BODY' OF STRUCTURE <fs_oneconnect> TO <fs_body_root>.

      ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_body_root> TO <fs_field>.

      IF NOT iv_alias IS INITIAL.
        IF NOT lv_alias IS INITIAL.
          <fs_field> = lv_alias.
        ELSE.
          <fs_field> = iv_tabname.
        ENDIF.
      ELSE.
        <fs_field> = iv_tabname.
      ENDIF.

*      TRANSLATE <fs_field> TO LOWER CASE.

      ASSIGN COMPONENT 'DATA' OF STRUCTURE <fs_body_root> TO <fs_table_body_line> .

      CALL METHOD me->set_table_any
        EXPORTING
          iv_alias = iv_alias
          it_fcat  = lt_fcat
        RECEIVING
          rt_table = <fs_table_body_line>.

      ASSIGN <fs_table_body_line>->* TO <fs_body>.


      CALL METHOD me->set_table_any
        EXPORTING
          iv_alias = iv_alias
          it_fcat  = lt_fcat
        RECEIVING
          rt_table = lo_data.


      ASSIGN lo_data->* TO <fs_table>.

*      lv_where  = me->set_where( iv_any = abap_true ).
      lv_fields = me->set_fields( iv_alias = gv_fieldname ).

      IF gt_where IS INITIAL.
        lv_where  = me->set_where( iv_any = abap_true ).

        me->set_process( ).

        gt_where = lv_where.
      ELSE.
        lv_where = gt_where.
      ENDIF.

      IF lv_where IS INITIAL.
*        MESSAGE i000(fb) WITH 'No filter selected'.
        RETURN.
      ENDIF.

      SELECT  (lv_fields) "*
              INTO CORRESPONDING FIELDS OF TABLE <fs_table>
              FROM (iv_tabname)
             WHERE (lv_where).
      IF sy-subrc NE 0.
*        MESSAGE i000(fb) WITH 'No data found'.

        me->append_slg1_log(
                             EXPORTING
                               iv_tabname    = space
*                               iv_key        =
                               iv_message_v1 = 'No data found'
                               iv_message_v2 = space
                               iv_message_v3 = space
                               iv_mestyp     = 'S' ).

        RETURN.
      ENDIF.

      IF NOT gv_batch IS INITIAL.
        me->execute_batch( EXPORTING
                              iv_anytab    = abap_true
                              iv_tabname   = iv_tabname ).
        RETURN.
      ENDIF.

      me->set_metadata_node_any( EXPORTING
                                     iv_alias   = gv_fieldname
                                     it_fcat    = lt_fcat
                                 CHANGING
                                     ct_metadata = <fs_metadata_line> ).


* Get Fields to b'e exported

      gv_recordst =  gv_recordst + lv_recordst.

      CLEAR lt_keys .

      LOOP AT <fs_table> ASSIGNING <fs_data>.

        CLEAR lt_keys.

        CALL METHOD me->set_key_any
          EXPORTING
            iv_alias = iv_alias
            it_fcat  = lt_fcat
            is_line  = <fs_data>
          RECEIVING
            rv_key   = lv_key.

        ASSIGN lv_key TO <fs_key>.

        IF lv_keys_temp NE lv_key.
          lv_keys_temp   = lv_key.
          lv_max_records = lv_max_records + 1.

          gv_recordst_obj = gv_recordst_obj + 1.
        ENDIF.


        me->append_slg1_log( iv_tabname = iv_tabname
                             iv_mestyp  = 'S'
                             iv_key     = lv_key ).

        APPEND INITIAL LINE TO <fs_body> ASSIGNING <fs_line> .

        MOVE-CORRESPONDING <fs_data> TO <fs_line> .

*** Convert Exit
        me->convertion_exit( EXPORTING iv_tabname = iv_tabname
                             CHANGING  cs_string  = <fs_line> ).

*** Fill Even ID
        IF gs_oc_obj-eventid  EQ abap_true OR
           gs_oc_obj-metadata EQ abap_true.

          IF <fs_key> IS ASSIGNED.

            APPEND INITIAL LINE TO lt_keys ASSIGNING <fs_keys_event>.
            <fs_keys_event>-line = <fs_key>.
          ENDIF.

          me->get_eventid(  EXPORTING it_keys = lt_keys
                            CHANGING cs_line_json = <fs_line> ).
        ENDIF.

        IF lv_max_records EQ gs_oc_obj-no_registros.
          APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.

          <fs_json>  = zoncl_ui2_cl_json=>serialize(
                   data             = <fs_root>
                   compress         = abap_false "abap_true
                   assoc_arrays     = abap_true
                   assoc_arrays_opt = abap_true
                   pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).

          REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>.

          REPLACE 'TABL' WITH 'TABLE' INTO <fs_json>.

          CLEAR: lv_max_records,
                 <fs_body>.
        ENDIF.
      ENDLOOP.

      IF lv_max_records LT gs_oc_obj-no_registros.
        APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.

        <fs_json>  = zoncl_ui2_cl_json=>serialize(
                 data             = <fs_root>
                 compress         = abap_false "abap_true
                 assoc_arrays     = abap_true
                 assoc_arrays_opt = abap_true
                 pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).

        REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>.

        REPLACE 'TABL' WITH 'TABLE' INTO <fs_json>.
      ENDIF.


      LOOP AT gt_json INTO gv_json.
        me->send_json_http_con(
                             EXPORTING
                               i_dest     = gv_dest
                             IMPORTING
                               e_return   = lv_return
                               e_size     = e_size
                               e_records  = e_records
*                       receiving
                               e_response = lv_response ).

        gv_sizet    = gv_sizet + e_size.

        gv_recordst = gv_recordst + 1.
      ENDLOOP.

*      me->send_json_result( ).

      me->update_slg1_log( it_log_ext = gt_log_ext ).
    ENDIF.
  ENDIF.
ENDMETHOD.


METHOD send_json_code.
  DATA: dref_table_root TYPE REF TO data,
        e_size          TYPE zonde_oc_num30,
        e_records       TYPE zonde_oc_num30,
        lv_return       TYPE string,
        lv_recordst     TYPE sy-tabix,
        lv_response     TYPE string,
        lv_key          TYPE string,
        lv_keys_temp    TYPE string,
        lv_max_records  TYPE zonde_registrosn.

  FIELD-SYMBOLS: <fs_root>            TYPE any, "ty_oneconnect, --DB
                 <fs_oneconnect>      TYPE any,
                 <fs_properties>      TYPE any,
                 <fs_metadata>        TYPE any,
                 <fs_body_root>       TYPE any,
                 <fs_json>            TYPE any,
                 <fs_field_metadata>  TYPE any,
                 <fs_metadata_line>   TYPE any,
                 <fs_field>           TYPE any,
                 <fs_line>            TYPE any,
                 <fs_table_body_line> TYPE any,
                 <fs_body>            TYPE STANDARD TABLE,
                 <fs_metadata_root>   TYPE STANDARD TABLE,
                 <fs_table>           TYPE STANDARD TABLE,
                 <fs_table2>          TYPE STANDARD TABLE,
                 <fs_data>            TYPE any,
                 <fs_table_line>      TYPE any,
                 <fs_key>             TYPE any.

  gv_update  = iv_update.
  gv_entity  = iv_entity.
  GV_DOMAINV = iv_ent_data-domainv.

  me->append_slg1_log(
    EXPORTING
      iv_tabname    = space
*       iv_key        =
      iv_message_v1 = '***' && iv_tabname && 'Table Process TABLE***'
      iv_message_v2 = space
      iv_message_v3 = space
      iv_mestyp     = 'S' ).

*** Get Relations
  SELECT SINGLE *
         INTO gs_oc_obj
         FROM zonta_obj_oc
         WHERE business_proc EQ iv_entity.

  IF sy-subrc EQ 0.

    gv_dest = iv_dest.

    IF sy-subrc EQ 0.
*      CREATE DATA dref_table_root TYPE ty_oneconnect.  --DB
      IF gs_oc_obj-data EQ abap_true.
        CREATE DATA dref_table_root TYPE ty_oneconnect_meta.
      ELSE.
        CREATE DATA dref_table_root TYPE ty_oneconnect.
      ENDIF.

      ASSIGN dref_table_root->* TO <fs_root>.

      ASSIGN COMPONENT 'ONECONNECT' OF STRUCTURE <fs_root> TO <fs_oneconnect>.

      ASSIGN COMPONENT 'PROPERTIES' OF STRUCTURE <fs_oneconnect> TO <fs_properties>.
      me->get_data_properties_any( CHANGING cs_properties = <fs_properties> ) .

      ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_oneconnect> TO <fs_metadata_root>.

      APPEND INITIAL LINE TO <fs_metadata_root> ASSIGNING <fs_metadata>.

      ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_metadata> TO <fs_field_metadata>.
      <fs_field_metadata> = iv_tabname.
      TRANSLATE <fs_field_metadata> TO LOWER CASE.

      ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_metadata> TO <fs_metadata_line>.

      ASSIGN COMPONENT 'BODY' OF STRUCTURE <fs_oneconnect> TO <fs_body_root>.

      ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_body_root> TO <fs_field>.

      <fs_field> = iv_tabname.
      TRANSLATE <fs_field> TO LOWER CASE.

      ASSIGN COMPONENT 'DATA' OF STRUCTURE <fs_body_root> TO <fs_table_body_line> .

      CALL METHOD me->set_table_any
        EXPORTING
          it_fcat  = it_fieldcat
        RECEIVING
          rt_table = <fs_table_body_line>.

      ASSIGN <fs_table_body_line>->* TO <fs_table>.

      ASSIGN it_data TO <fs_table2>.

      LOOP AT <fs_table2> ASSIGNING <fs_data>.
        APPEND INITIAL LINE TO <fs_table> ASSIGNING <fs_table_line>.
        MOVE-CORRESPONDING <fs_data> TO <fs_table_line> .
      ENDLOOP.

      me->set_metadata_node_any( EXPORTING
                                     it_fcat    = it_fieldcat
                                 CHANGING
                                     ct_metadata = <fs_metadata_line> ).


* Get Fields to b'e exported

      LOOP AT it_data ASSIGNING <fs_data>.

        lv_max_records = lv_max_records + 1.

        gv_recordst_obj = gv_recordst_obj + 1.

        ASSIGN COMPONENT 1 OF STRUCTURE <fs_data> TO <fs_key>.

        lv_key = <fs_key>.

        me->append_slg1_log( iv_tabname = iv_tabname
                             iv_mestyp  = 'S'
                             iv_key     = lv_key ).

        IF lv_max_records EQ gs_oc_obj-no_registros.
          APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.

          <fs_json>  = zoncl_ui2_cl_json=>serialize(
                   data             = <fs_root>
                   compress         = abap_false "abap_true
                   assoc_arrays     = abap_true
                   assoc_arrays_opt = abap_true
                   pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).

          CLEAR: lv_max_records.
*                 <fs_body>.  "--DB
        ENDIF.
      ENDLOOP.

      IF lv_max_records LT gs_oc_obj-no_registros.
        APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.

        <fs_json>  = zoncl_ui2_cl_json=>serialize(
                 data             = <fs_root>
                 compress         = abap_false "abap_true
                 assoc_arrays     = abap_true
                 assoc_arrays_opt = abap_true
                 pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).
      ENDIF.


      LOOP AT gt_json INTO gv_json.
        me->pretty_json( EXPORTING iv_mode = c_table
                         CHANGING  cv_json = gv_json ).

        me->send_json_http_con(
                             EXPORTING
                               i_dest     = gv_dest
                             IMPORTING
                               e_return   = lv_return
                               e_size     = e_size
                               e_records  = e_records
*                       receiving
                               e_response = lv_response ).

        gv_sizet    = gv_sizet + e_size.

        gv_recordst = gv_recordst + 1.
      ENDLOOP.

      me->send_json_result( ).

      me->update_slg1_log( it_log_ext = gt_log_ext ).
    ENDIF.
  ENDIF.
ENDMETHOD.


  METHOD SEND_JSON_HTTP_CON.
    DATA:
      lv_response    TYPE string,
      lv_return      TYPE string,
      lv_string      TYPE string,
      lv_stini       TYPE timestamp,
      lv_stfin       TYPE timestamp,
      lo_http_client TYPE REF TO if_http_client,
      lv_destination TYPE rfcdes-rfcdest,
      lv_servicenr   TYPE rfcdisplay-rfcsysid,
      lv_server      TYPE rfcdisplay-rfchost,
      lv_path_prefix TYPE string,
      lv_err_string  TYPE string,
      lv_ret_code    TYPE sy-subrc,
      r_str          TYPE string,
      result_tab     TYPE TABLE OF string,
      lv_dest        TYPE rfcdest,
      lv_table       TYPE char20,
      lv_low         TYPE rfcdest,
      lv_size        TYPE zonde_oc_num30,
      lv_message     TYPE symsgv.


    CLEAR:lv_string.
*    DATA : "json_doc TYPE REF TO zoncl_json_document,


    GET TIME STAMP FIELD lv_stini.

    lv_low = i_dest.

    IF lv_low IS NOT INITIAL.
      lv_dest = lv_low.

      CALL METHOD cl_http_client=>create_by_destination
        EXPORTING
          destination              = lv_dest
        IMPORTING
          client                   = lo_http_client
        EXCEPTIONS
          destination_not_found    = 1
          internal_error           = 2
          argument_not_found       = 3
          destination_no_authority = 4
          plugin_not_active        = 5
          OTHERS                   = 6.

      CASE sy-subrc.
        WHEN 1.
          lv_message = text-e01.
        WHEN 2.
          lv_message = text-e02.
        WHEN 3.
          lv_message = text-e03.
        WHEN 4.
          lv_message = text-e04.
        WHEN 5.
          lv_message = text-e05.
        WHEN 6.
      ENDCASE.

      IF sy-subrc NE 0.
        me->append_slg1_log(
          EXPORTING
           iv_tabname    = space
*           iv_key        =
           iv_message_v1 = lv_message
           iv_message_v2 = space
           iv_message_v3 = space
           iv_mestyp     = 'E' ).

        EXIT.
      ENDIF.

      DATA lv_payload_x TYPE xstring.
      CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
        EXPORTING
          text   = me->gv_json
        IMPORTING
          buffer = lv_payload_x.
*do. enddo.

      lo_http_client->request->set_method( 'POST' ).
      lo_http_client->request->set_content_type( 'text/plain' ). "'application/json' ).
      lo_http_client->request->set_data( lv_payload_x ).

* Sending the request
      lo_http_client->send(
                            EXCEPTIONS http_communication_failure = 1
                                       http_invalid_state         = 2 ).

      CASE sy-subrc.
        WHEN 1.
          lv_message = text-e06.
        WHEN 2.
          lv_message = text-e07.
      ENDCASE.

      IF sy-subrc NE 0.
        me->append_slg1_log(
          EXPORTING
           iv_tabname    = space
*           iv_key        =
           iv_message_v1 = lv_message
           iv_message_v2 = space
           iv_message_v3 = space
           iv_mestyp     = 'E' ).

        EXIT.
      ENDIF.

* Receiving the response
      lo_http_client->receive( EXCEPTIONS  http_communication_failure = 1
                                           http_invalid_state         = 2
                                           http_processing_failed     = 3 ).

      CASE sy-subrc.
        WHEN 1.
          lv_message = text-e06.
        WHEN 2.
          lv_message = text-e07.
        WHEN 3.
          lv_message = text-e08.
      ENDCASE.

      IF sy-subrc NE 0.
        me->append_slg1_log(
          EXPORTING
           iv_tabname    = space
*           iv_key        =
           iv_message_v1 = lv_message
           iv_message_v2 = space
           iv_message_v3 = space
           iv_mestyp     = 'E' ).

        EXIT.
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

        EXIT.
      ENDIF.

      CLEAR lv_response .
      lv_response = lo_http_client->response->get_cdata( ).
      CLEAR result_tab .
      SPLIT lv_response AT cl_abap_char_utilities=>cr_lf INTO TABLE result_tab .

      CALL METHOD lo_http_client->close.
      lv_size = xstrlen( lv_payload_x ).

      GET TIME STAMP FIELD lv_stfin.
      FORMAT COLOR 3.

      FORMAT COLOR OFF.
    ENDIF.

    e_response = lv_response.
    e_return   = lv_ret_code.
    e_size     = lv_size.
  ENDMETHOD.


  METHOD SEND_JSON_RESULT.

    DATA: total_size_sent          TYPE string,
          total_number_of_requests TYPE string,
          total_number_of_records  TYPE string,
          out                      TYPE REF TO if_demo_output,
          ls_sent                  TYPE zonta_relations.

    IF sy-batch IS INITIAL.
      out = cl_demo_output=>new( ).
      out->begin_section( 'ONE CONNECT EXECUTION LOG' ).

      SHIFT gv_sizet        LEFT DELETING LEADING '0'.
      SHIFT gv_recordst     LEFT DELETING LEADING '0'.
      SHIFT gv_recordst_obj LEFT DELETING LEADING '0'.
      total_size_sent          = gv_sizet.
      total_number_of_requests = gv_recordst.
      total_number_of_records  = gv_recordst_obj.
      out->write_data( gv_entity ).
      IF lines( gt_relations ) > 0.
        out->write_data( gt_relations ).
      ENDIF.
      out->write_data( total_size_sent ).
      out->write_data( total_number_of_requests ).
      out->write_data( total_number_of_records ).

*    out->write_text( |Please validate complete log in ZONT_HIST_DL transaction code| ).
      out->display( ).
    ELSE.
*      DATA: total_size_sent          TYPE string,
*             total_number_of_requests TYPE string.


      WRITE:/ 'ONE CONNECT EXECUTION LOG' .

      SHIFT gv_sizet         LEFT DELETING LEADING '0'.
      SHIFT gv_recordst      LEFT DELETING LEADING '0'.
      SHIFT gv_recordst_obj LEFT DELETING LEADING '0'.
      total_size_sent          = gv_sizet.
      total_number_of_requests = gv_recordst.
      total_number_of_records  = gv_recordst_obj.
      WRITE:/ gv_entity .
      SKIP.
      WRITE: / 'Entity', gv_entity.
      SKIP.

      IF lines( gt_relations  ) > 0.
        WRITE: /5 'Entity',
               30 'Description'.
*             70 'Description'.
        LOOP AT gt_relations INTO ls_sent.
          WRITE: /5   ls_sent-business_proc,
                   30 ls_sent-description_table.
*                 70 ls_sent-description.
        ENDLOOP.
      ENDIF.

      SKIP 2.
      WRITE : / 'Total Size Sent',          30 total_size_sent.
      WRITE : / 'Total Number of requests', 30 total_number_of_requests.
      WRITE : / 'Total Number of records',  30 total_number_of_records.
      SKIP.
      SKIP.
      WRITE /: '**********Please validate complete log in ZONT_HIST_DL transaction code**********'.
    ENDIF.
  ENDMETHOD.


  METHOD send_output_type.

    CONSTANTS: lc_comilla   TYPE c LENGTH 1 VALUE ''''.

    DATA: lv_objtype        TYPE swotobjid-objtype,
          lv_object         TYPE cdobjectcl,
          lv_key            TYPE string,
          lv_destination    TYPE rfcdest,
          lv_key_data       TYPE string,
          lt_info           TYPE STANDARD TABLE OF swotrk,
          lt_info_hdr       TYPE STANDARD TABLE OF swotrk,
          lt_endpoints      TYPE STANDARD TABLE OF zonta_oc_endp,
          lt_where_cond_tab TYPE rsds_twhere,
          lv_update         TYPE char1,
          lv_delete         TYPE char1,
          ls_params         TYPE zonta_oc_param,
          lv_kdoc           TYPE char1,
          lv_table          TYPE char1,
          lv_both           TYPE char1,
          lt_params         TYPE STANDARD TABLE OF zonta_oc_param,
          lt_obj_oc         TYPE STANDARD TABLE OF zonta_obj_oc,
          ls_obj_oc         TYPE zonta_obj_oc,
          lv_sequence       TYPE zonde_subsequence,
          lv_alias          TYPE boolean,
          lv_fieldname      TYPE boolean.
*          ls_sender      tYPE SIBFLPORB.

    FIELD-SYMBOLS: <fs_info>           TYPE swotrk,
                   <fs_info_hdr>       TYPE swotrk,
                   <fs_oc_param>       TYPE zonta_oc_param,
                   <fs_where_cond_tab> TYPE LINE OF rsds_twhere,
                   <fs_where_tab>      TYPE LINE OF rsds_where_tab.


*    lv_object = i_object-objectid. "is_sender-typeid.
*    lv_objtype = i_object-objectid."is_sender-typeid.

    SELECT name
           low
           INTO CORRESPONDING FIELDS OF TABLE lt_params
           FROM zonta_oc_param.
    IF sy-subrc = 0.

*      ls_params = VALUE #( lt_params[ name = 'RFC_DESTINATION' ] OPTIONAL ).
      READ TABLE lt_params WITH KEY name = 'RFC_DESTINATION'
                           INTO ls_params.

      IF ls_params IS INITIAL.
        lv_destination = 'ONIBEX_KDOCS'.
      ELSE.
        lv_destination = ls_params-low.
      ENDIF.
      CLEAR ls_params.

      CLEAR:  lv_kdoc,
              lv_table,
              lv_both.
*      ls_params = value #( lt_params[ NAME = 'KDOC' ] OPTIONAL ).
      READ TABLE lt_params WITH KEY name = 'TRANSMISSION_MEDIUM'
                          INTO ls_params.
      IF sy-subrc EQ 0.
        CASE ls_params-low.
          WHEN 'T'.
            lv_kdoc = abap_false.
            lv_table = abap_true.
          WHEN 'K'.
            lv_kdoc = abap_true.
            lv_table = abap_false.
          WHEN 'B'.
            lv_kdoc = abap_true.
            lv_table = abap_true.
          WHEN OTHERS.
            lv_kdoc = abap_false.
            lv_table = abap_true.
        ENDCASE.
      ENDIF.

      CLEAR ls_params.

      READ TABLE lt_params WITH KEY name = 'USE_ALIAS'
                          INTO ls_params.

      IF sy-subrc EQ 0.
        lv_alias = ls_params-low.
      ENDIF.

*      ls_params = value #( lt_params[ NAME = 'SEND_KDOC_TABLE' ] OPTIONAL ).
*      READ TABLE lt_params WITH KEY name = 'SEND_KDOC_TABLE'
*                          INTO ls_params.
*      IF ls_params-low = abap_true.
*        lv_kdoc = abap_true.
*        lv_table = abap_true.
*      ENDIF.
*      CLEAR ls_params.
    ENDIF.


    SELECT *
      INTO TABLE lt_obj_oc
      FROM zonta_obj_oc
      WHERE kschl = i_object-kschl.

    LOOP AT lt_obj_oc INTO ls_obj_oc.

      SELECT SINGLE
             sequence
             INTO lv_sequence
             FROM zonta_relations
             WHERE id EQ ls_obj_oc-id
               AND sequence EQ 1.

      lv_objtype = ls_obj_oc-objtype. "cdobjectcl.

      IF lv_sequence IS INITIAL.
        RETURN.
      ENDIF.
      CALL FUNCTION 'SWO_QUERY_KEYFIELDS'
        EXPORTING
          objtype = lv_objtype
        TABLES
          info    = lt_info.

      lt_info_hdr = lt_info.
      SORT lt_info_hdr BY objtype.
      DELETE ADJACENT DUPLICATES FROM lt_info_hdr
                      COMPARING objtype.

      LOOP AT lt_info_hdr ASSIGNING <fs_info_hdr>.
        APPEND INITIAL LINE TO lt_where_cond_tab ASSIGNING <fs_where_cond_tab>.

        <fs_where_cond_tab>-tablename = <fs_info_hdr>-objtype.

        LOOP AT lt_info ASSIGNING <fs_info>
                          WHERE objtype EQ <fs_info_hdr>-objtype.

          APPEND INITIAL LINE TO <fs_where_cond_tab>-where_tab ASSIGNING <fs_where_tab>.

*          CONCATENATE 'T'
*                      lv_sequence"'001
*                      '~'
*                      <fs_info>-reffield
*                       INTO lv_key.

          lv_key = <fs_info>-reffield .

          lv_key_data = |{ lc_comilla } { i_object-objky } { lc_comilla }| .

          CONDENSE lv_key_data NO-GAPS.

          CONCATENATE '('
                      lv_key
                      'EQ'
                      lv_key_data
                      ')'
                      INTO <fs_where_tab>-line"lv_key
                      SEPARATED BY space.
        ENDLOOP.
      ENDLOOP.

*      lv_key = |{ ' ( ' } { lv_sequence }{ '~VBELN EQ ' } { lc_comilla }{ i_object-objky }{ lc_comilla } { ' )' }|.

      IF lv_alias EQ abap_false.
        lv_fieldname = abap_true.
      ENDIF.

      SELECT * "#EC CI_NOFIRST
             INTO TABLE lt_endpoints
             FROM zonta_oc_endp
             WHERE domainv       EQ ls_obj_oc-domainv
               AND business_proc EQ ls_obj_oc-business_proc.

      lv_update = abap_true.
      CALL METHOD me->get_relation
        EXPORTING
          iv_domainv        = ls_obj_oc-domainv
          iv_business_proc  = ls_obj_oc-business_proc
          iv_kdoc           = lv_kdoc
          iv_table          = lv_table
          iv_key_queue      = lv_key
*         iv_ddic           =
          iv_dest           = lv_destination
          iv_update         = lv_update
          iv_delete         = lv_delete
*         iv_alias          = lv_alias
          iv_fieldname      = lv_fieldname
          it_endpoints      = lt_endpoints
          it_where_cond_tab = lt_where_cond_tab
        EXCEPTIONS
          not_data_found    = 1
          OTHERS            = 2.
      IF sy-subrc <> 0.
*     Implement suitable error handling here
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


METHOD SET_CORR_INSERT.

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
* Implement suitable error handling here
      ENDIF.
    WHEN 'DELETE'.
      CALL FUNCTION 'RS_CORR_INSERT'
        EXPORTING
          object              = iv_object
          object_class        = 'DICT'
          mode                = iv_mode
          global_lock         = abap_true
*          devclass            = gv_devclass
          korrnum             = gv_korrnum
        IMPORTING
*          devclass            = gv_devclass
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
           lv_sequence      TYPE string,
           lv_fldname       TYPE string,
           lv_is_cds_entity TYPE abap_bool, " CECHAVARRIA 09/07/2025
           lv_tablename     TYPE zonta_relations-tabname, " CECHAVARRIA 09/07/2025
           lv_alias_fldname TYPE string.

     FIELD-SYMBOLS: <fs_relations> TYPE zonta_relations,
                    <fs_columns>   TYPE zonta_oc_col_all,
                    <fs_dfies_tab> TYPE dfies.


     DATA: lv_field   TYPE string,
           lv_tabname TYPE  ddobjname.


     IF NOT gv_anytable IS INITIAL.
*CECHAVARRIA 22/05/2025
*Add position to tbale gt_columns_all
       add_position_table( iv_tabname = gv_anytable ).
       SORT gt_columns_all BY tabname positionf.
*CECHAVARRIA 22/05/2025
       lv_tablename = gv_anytable.
       lv_is_cds_entity = me->is_cds_entity( lv_tablename  )."CECHAVARRIA 09/07/2025

       LOOP AT gt_columns_all ASSIGNING <fs_columns>
                              WHERE tabname EQ gv_anytable.
*                             AND fldname NE 'MANDT'.

         TRANSLATE <fs_columns>-alias_fldname TO UPPER CASE.

         FIND <fs_columns>-fldname IN r_fields.
*
         IF sy-subrc NE 0.

           IF iv_alias IS INITIAL.
             IF NOT gv_bothnames IS INITIAL.
               lv_field =  <fs_columns>-fldname.
             ELSE.
               IF NOT <fs_columns>-alias_fldname IS INITIAL.

                 lv_field = <fs_columns>-fldname    .

                 CONCATENATE   lv_field
                               'AS'
                              <fs_columns>-alias_fldname
                              INTO  lv_field
                              SEPARATED BY space.

               ELSE.

                 lv_field =  <fs_columns>-fldname.

               ENDIF.
             ENDIF.
           ELSE.
             lv_field =  <fs_columns>-fldname.
           ENDIF.

           IF abap_false = lv_is_cds_entity."CECHAVARRIA 09/07/2025
             CONCATENATE r_fields
                         lv_field
                         INTO r_fields
                         SEPARATED BY space ."', '.
*BEGIN CECHAVARRIA 09/07/2025
           ELSE.
             CONCATENATE r_fields
                       lv_field
                       INTO r_fields
                       SEPARATED BY ',' .
           ENDIF.
*END CECHAVARRIA 09/07/2025
         ENDIF.
       ENDLOOP.

     ELSE.
       lt_relations = gt_relations.
       lt_columns   = gt_columns_all.

       DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING sequence.

       SORT lt_columns BY fldname tabname.

       LOOP AT lt_relations ASSIGNING <fs_relations>.
         LOOP AT lt_columns ASSIGNING <fs_columns>
                            WHERE tabname EQ <fs_relations>-tabname
                              AND fldname NE 'MANDT'.

           TRANSLATE <fs_columns>-alias_fldname TO UPPER CASE.

           lv_fldname = <fs_columns>-fldname && <fs_relations>-sequence.

           lv_alias_fldname = <fs_columns>-alias_fldname && <fs_relations>-sequence.

           IF NOT iv_alias IS INITIAL.
             IF NOT <fs_columns>-alias_fldname IS INITIAL.

               lv_sequence = 'T' && <fs_relations>-sequence.

               lv_field =  lv_sequence             && "<fs_relations>-sequence &&
                           '~'                     &&
                           <fs_columns>-fldname    .

               CONCATENATE   lv_field
                             'AS'
                            lv_alias_fldname
                            INTO  lv_field
                            SEPARATED BY space.

             ELSE.
               lv_sequence = 'T' && <fs_relations>-sequence.

               lv_field =  lv_sequence             && "<fs_relations>-sequence &&
                           '~'                     &&
                           <fs_columns>-fldname.

               CONCATENATE   lv_field
                            'AS'
                           lv_fldname
                           INTO  lv_field
                           SEPARATED BY space.

             ENDIF.
           ELSE.
             lv_sequence = 'T' && <fs_relations>-sequence.

             lv_field =  lv_sequence             && "<fs_relations>-sequence &&
                         '~'                     &&
                         <fs_columns>-fldname.
           ENDIF.

           CONCATENATE r_fields
                       lv_field
                       INTO r_fields
                       SEPARATED BY space ."', '.
*          ENDIF.
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

           LOOP AT lt_dfies_tab ASSIGNING <fs_dfies_tab>.
             IF <fs_dfies_tab>-fieldname EQ 'MANDT'.
               CONTINUE.
             ENDIF.

             FIND <fs_dfies_tab>-fieldname IN r_fields.

             IF sy-subrc NE 0.
               lv_sequence = 'T' && <fs_relations>-sequence.

               lv_field =  lv_sequence             && "<fs_relations>-sequence &&
                           '~'                     &&
                           <fs_dfies_tab>-fieldname.

               CONCATENATE r_fields
                           lv_field
                           INTO r_fields
                           SEPARATED BY space ."', '.
             ENDIF.
           ENDLOOP.

         ENDIF.
       ENDLOOP.

       REPLACE FIRST OCCURRENCE OF ',' IN r_fields WITH space.
     ENDIF.
   ENDMETHOD.


   METHOD set_fields_in_table.

     DATA: lt_dfies_tab     TYPE STANDARD TABLE OF dfies,
           lt_relations     TYPE STANDARD TABLE OF zonta_relations,
           lt_columns       TYPE STANDARD TABLE OF zonta_oc_col_all,
           lv_sequence      TYPE string,
*           lv_fldname       TYPE string,"CECHAVARRIA 03/06/2025
           lv_fldname       TYPE lvc_s_fcat-fieldname, "CECHAVARRIA 03/06/2025
           lv_alias_fldname TYPE string,
*CECHAVARRIA 03/06/2025
           lv_fields        TYPE string,
           lv_tablename     TYPE zonta_relations-tabname,
*           lv_tabnames      TYPE string,
           lv_lines         TYPE i,
           lv_is_cds_entity TYPE abap_bool,
           lv_tabix         TYPE i.
*CECHAVARRIA 03/06/2025

     FIELD-SYMBOLS: <fs_relations> TYPE zonta_relations,
                    <fs_columns>   TYPE zonta_oc_col_all,
                    <fs_dfies_tab> TYPE dfies.


     DATA: lv_field     TYPE string,
           lv_field_aux TYPE string,
           lv_tabname   TYPE  ddobjname.

     IF NOT gv_anytable IS INITIAL.
*BEGIN CECHAVARRIA 03/06/2025
       CLEAR: lv_tabix, lv_lines.
       DESCRIBE TABLE gt_columns_all LINES lv_lines.
       lv_tablename = gv_anytable.
       lv_is_cds_entity = me->is_cds_entity( lv_tablename ).
*END CECHAVARRIA 03/06/2025
       LOOP AT gt_columns_all ASSIGNING <fs_columns>
                            WHERE tabname EQ gv_anytable.
*                             AND fldname NE 'MANDT'.

         ADD 1 TO lv_tabix."*CECHAVARRIA 03/06/2025

         TRANSLATE <fs_columns>-alias_fldname TO UPPER CASE.

         FIND <fs_columns>-fldname IN lv_fields.
*
         IF sy-subrc NE 0.

           IF NOT iv_alias IS INITIAL.

             IF NOT <fs_columns>-alias_fldname IS INITIAL.

               lv_field = <fs_columns>-fldname    .

               CONCATENATE   lv_field
                             'AS'
                            <fs_columns>-alias_fldname
                            INTO  lv_field
                            SEPARATED BY space.

             ELSE.

               lv_field =  <fs_columns>-fldname.

             ENDIF.
           ELSE.
             lv_field =  <fs_columns>-fldname.
           ENDIF.

           CONCATENATE lv_fields
                       lv_field
                       INTO lv_fields
                       SEPARATED BY space ."', '.
         ENDIF.

*CECHAVARRIA 03/06/2025
         IF lv_tabix < lv_lines AND
            lv_is_cds_entity = abap_true.
           CLEAR lv_field_aux.
           CONCATENATE lv_field
                        ','
                  INTO lv_field_aux.
         ENDIF.
         APPEND lv_field_aux TO et_fields.
*CECHAVARRIA 03/06/2025
       ENDLOOP.
     ELSE.
       lt_relations = gt_relations.
       lt_columns   = gt_columns_all.

       DELETE lt_relations WHERE tabname NE iv_tabname.

       DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING tabname.
       DELETE lt_columns WHERE tabname NE iv_tabname."CECHAVARRIA 09/06/2025

       SORT lt_columns BY fldname tabname.

       CLEAR: lv_tabix, lv_lines."*CECHAVARRIA 03/06/2025
       DESCRIBE TABLE lt_columns LINES lv_lines. "*CECHAVARRIA 03/06/2025

       LOOP AT lt_relations ASSIGNING <fs_relations>.
         lv_is_cds_entity = me->is_cds_entity( <fs_relations>-tabname ). "*CECHAVARRIA 03/06/2025

         LOOP AT lt_columns ASSIGNING <fs_columns>
                            WHERE tabname EQ <fs_relations>-tabname
                              AND fldname NE 'MANDT'.

           ADD 1 TO lv_tabix."*CECHAVARRIA 03/06/2025

           TRANSLATE <fs_columns>-alias_fldname TO UPPER CASE.

           lv_fldname = <fs_columns>-fldname && <fs_relations>-sequence.

           lv_alias_fldname = <fs_columns>-alias_fldname && <fs_relations>-sequence.

           IF NOT iv_alias IS INITIAL.
             IF NOT gv_alias IS INITIAL.
               IF NOT <fs_columns>-alias_fldname IS INITIAL.

*             lv_sequence = 'T' && <fs_relations>-sequence.

                 lv_field =  "lv_sequence             && "<fs_relations>-sequence &&
                             "'~'                     &&
                             <fs_columns>-fldname    .

                 CONCATENATE   lv_field
                               'AS'
                              lv_alias_fldname
                              INTO  lv_field
                              SEPARATED BY space.

               ELSE.
*             lv_sequence = 'T' && <fs_relations>-sequence.

                 lv_field =  "lv_sequence             && "<fs_relations>-sequence &&
                             "'~'                     &&
                             <fs_columns>-fldname.

                 CONCATENATE   lv_field
                              'AS'
                             lv_fldname
                             INTO  lv_field
                             SEPARATED BY space.

               ENDIF.
             ELSE.
               lv_field =  "lv_sequence             && "<fs_relations>-sequence &&
                          "'~'                     &&
                          <fs_columns>-fldname.

               CONCATENATE   lv_field
                            'AS'
                           lv_fldname
                           INTO  lv_field
                           SEPARATED BY space.
*CECHAVARRIA 03/06/2025
               IF lv_tabix < lv_lines AND
                  lv_is_cds_entity = abap_true.
                 CONCATENATE lv_field
                              ','
                        INTO  lv_field.
               ENDIF.
               APPEND lv_field TO et_fields.
*CECHAVARRIA 03/06/2025
             ENDIF.
           ELSE.
*           lv_sequence = 'T' && <fs_relations>-sequence.

             lv_field =  "lv_sequence             && "<fs_relations>-sequence &&
                         "'~'                     &&
                         <fs_columns>-fldname.
           ENDIF.

           CONCATENATE lv_fields
                       lv_field
                       INTO lv_fields
                       SEPARATED BY space ."', '.
*          ENDIF.
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

           LOOP AT lt_dfies_tab ASSIGNING <fs_dfies_tab>.
             IF <fs_dfies_tab>-fieldname EQ 'MANDT'.
               CONTINUE.
             ENDIF.

             FIND <fs_dfies_tab>-fieldname IN lv_fields.

             IF sy-subrc NE 0.
*             lv_sequence = 'T' && <fs_relations>-sequence.

               lv_field =  "lv_sequence             && "<fs_relations>-sequence &&
                           "'~'                     &&
                           <fs_dfies_tab>-fieldname.

               CONCATENATE lv_fields
                           lv_field
                           INTO lv_fields
                           SEPARATED BY space ."', '.
             ENDIF.
           ENDLOOP.

         ENDIF.
       ENDLOOP.

       IF lv_is_cds_entity = abap_false."CECHAVARRIA 03/06/2025
         REPLACE FIRST OCCURRENCE OF ',' IN lv_fields WITH space.
       ENDIF."*CECHAVARRIA 03/06/2025
     ENDIF.
   ENDMETHOD.


   METHOD set_fields_new.

     DATA: lt_dfies_tab     TYPE STANDARD TABLE OF dfies,
           lt_relations     TYPE STANDARD TABLE OF zonta_relations,
           lt_columns       TYPE STANDARD TABLE OF zonta_oc_col_all,
           lv_sequence      TYPE string,
           lv_fldname       TYPE string,
           lv_alias_fldname TYPE string,
*CECHAVARRIA 03/06/2025
           lv_tabnames      TYPE string,
           lv_lines         TYPE i,
           lv_is_cds_entity TYPE abap_bool,
           lv_tabix         TYPE i.
*CECHAVARRIA 03/06/2025

     FIELD-SYMBOLS: <fs_relations> TYPE zonta_relations,
                    <fs_columns>   TYPE zonta_oc_col_all,
                    <fs_dfies_tab> TYPE dfies.


     DATA: lv_field   TYPE string,
           lv_tabname TYPE  ddobjname.

     IF NOT gv_anytable IS INITIAL.
       LOOP AT gt_columns_all ASSIGNING <fs_columns>
                            WHERE tabname EQ gv_anytable.
*                             AND fldname NE 'MANDT'.

         TRANSLATE <fs_columns>-alias_fldname TO UPPER CASE.

         FIND <fs_columns>-fldname IN r_fields.
*
         IF sy-subrc NE 0.

           IF NOT iv_alias IS INITIAL.

             IF NOT <fs_columns>-alias_fldname IS INITIAL.

               lv_field = <fs_columns>-fldname    .

               CONCATENATE   lv_field
                             'AS'
                            <fs_columns>-alias_fldname
                            INTO  lv_field
                            SEPARATED BY space.

             ELSE.

               lv_field =  <fs_columns>-fldname.

             ENDIF.
           ELSE.
             lv_field =  <fs_columns>-fldname.
           ENDIF.

           CONCATENATE r_fields
                       lv_field
                       INTO r_fields
                       SEPARATED BY space ."', '.
         ENDIF.
       ENDLOOP.
     ELSE.
*CECHAVARRIA 09/06/2025
       lv_tabnames = iv_tabname.
*Add position to tbale gt_columns_all
       add_position_table( iv_tabname = lv_tabnames ).
       SORT gt_columns_all BY tabname positionf.
*CECHAVARRIA 09/06/2025
       lt_relations = gt_relations.
       lt_columns   = gt_columns_all.

       DELETE lt_relations WHERE tabname NE iv_tabname.

       DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING tabname.
       DELETE lt_columns where tabname ne iv_tabname."CECHAVARRIA 09/06/2025

       SORT lt_columns BY fldname tabname.

       CLEAR: lv_tabix, lv_lines."*CECHAVARRIA 03/06/2025
       DESCRIBE TABLE lt_columns LINES lv_lines. "*CECHAVARRIA 03/06/2025

       LOOP AT lt_relations ASSIGNING <fs_relations>.
         lv_is_cds_entity = me->is_cds_entity( <fs_relations>-tabname ). "*CECHAVARRIA 03/06/2025

         LOOP AT lt_columns ASSIGNING <fs_columns>
                            WHERE tabname EQ <fs_relations>-tabname
                              AND fldname NE 'MANDT'.

           ADD 1 TO lv_tabix."*CECHAVARRIA 03/06/2025

           TRANSLATE <fs_columns>-alias_fldname TO UPPER CASE.

           lv_fldname = <fs_columns>-fldname && <fs_relations>-sequence.

           lv_alias_fldname = <fs_columns>-alias_fldname && <fs_relations>-sequence.

           IF NOT iv_alias IS INITIAL.
             IF NOT gv_alias IS INITIAL.
               IF NOT <fs_columns>-alias_fldname IS INITIAL.

*             lv_sequence = 'T' && <fs_relations>-sequence.

                 lv_field =  "lv_sequence             && "<fs_relations>-sequence &&
                             "'~'                     &&
                             <fs_columns>-fldname    .

                 CONCATENATE   lv_field
                               'AS'
                              lv_alias_fldname
                              INTO  lv_field
                              SEPARATED BY space.

               ELSE.
*             lv_sequence = 'T' && <fs_relations>-sequence.

                 lv_field =  "lv_sequence             && "<fs_relations>-sequence &&
                             "'~'                     &&
                             <fs_columns>-fldname.

                 CONCATENATE   lv_field
                              'AS'
                             lv_fldname
                             INTO  lv_field
                             SEPARATED BY space.

               ENDIF.
             ELSE.
               lv_field =  "lv_sequence             && "<fs_relations>-sequence &&
                          "'~'                     &&
                          <fs_columns>-fldname.

               CONCATENATE   lv_field
                            'AS'
                           lv_fldname
                           INTO  lv_field
                           SEPARATED BY space.
*CECHAVARRIA 03/06/2025
               IF lv_tabix < lv_lines AND
                  lv_is_cds_entity = abap_true.
                 CONCATENATE lv_field
                              ','
                        INTO  lv_field.
               ENDIF.
*CECHAVARRIA 03/06/2025
             ENDIF.
           ELSE.
*           lv_sequence = 'T' && <fs_relations>-sequence.

             lv_field =  "lv_sequence             && "<fs_relations>-sequence &&
                         "'~'                     &&
                         <fs_columns>-fldname.
           ENDIF.

           CONCATENATE r_fields
                       lv_field
                       INTO r_fields
                       SEPARATED BY space ."', '.
*          ENDIF.
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

           LOOP AT lt_dfies_tab ASSIGNING <fs_dfies_tab>.
             IF <fs_dfies_tab>-fieldname EQ 'MANDT'.
               CONTINUE.
             ENDIF.

             FIND <fs_dfies_tab>-fieldname IN r_fields.

             IF sy-subrc NE 0.
*             lv_sequence = 'T' && <fs_relations>-sequence.

               lv_field =  "lv_sequence             && "<fs_relations>-sequence &&
                           "'~'                     &&
                           <fs_dfies_tab>-fieldname.

               CONCATENATE r_fields
                           lv_field
                           INTO r_fields
                           SEPARATED BY space ."', '.
             ENDIF.
           ENDLOOP.

         ENDIF.
       ENDLOOP.

       IF lv_is_cds_entity = abap_false."CECHAVARRIA 03/06/2025
         REPLACE FIRST OCCURRENCE OF ',' IN r_fields WITH space.
       ENDIF."*CECHAVARRIA 03/06/2025
     ENDIF.
   ENDMETHOD.


  METHOD set_fields_structure.
    FIELD-SYMBOLS: <fs_json_map> TYPE dd03p.
    IF iv_type_name IS INITIAL.
      APPEND INITIAL LINE TO gt_json_map ASSIGNING <fs_json_map>.
      <fs_json_map>-fieldname   = 'MESSAGETYPE'. "<fs_dfies_tab_add>-fieldname.
      <fs_json_map>-tabname     = 'PROPERTIES'. "<fs_dfies_tab_add>-tabname.
      <fs_json_map>-ddlanguage  = sy-langu.
      <fs_json_map>-datatype    = 'STRG'. "<fs_dfies_tab_add>-datatype.
      <fs_json_map>-inttype     = 'g'.
      <fs_json_map>-intlen      = 8.

      APPEND INITIAL LINE TO gt_json_map ASSIGNING <fs_json_map>.
      <fs_json_map>-fieldname   = 'CHANGE'. "<fs_dfies_tab_add>-fieldname.
      <fs_json_map>-tabname     = 'PROPERTIES'. "<fs_dfies_tab_add>-tabname.
      <fs_json_map>-ddlanguage  = sy-langu.
      <fs_json_map>-datatype    = 'STRG'. "<fs_dfies_tab_add>-datatype.
      <fs_json_map>-inttype     = 'g'.
      <fs_json_map>-intlen      = 8.

      APPEND INITIAL LINE TO gt_json_map ASSIGNING <fs_json_map>.
      <fs_json_map>-fieldname   = 'DELETE'. "<fs_dfies_tab_add>-fieldname.
      <fs_json_map>-tabname     = 'PROPERTIES'. "<fs_dfies_tab_add>-tabname.
      <fs_json_map>-ddlanguage  = sy-langu.
      <fs_json_map>-datatype    = 'STRG'. "<fs_dfies_tab_add>-datatype.
      <fs_json_map>-inttype     = 'g'.
      <fs_json_map>-intlen      = 8.

      APPEND INITIAL LINE TO gt_json_map ASSIGNING <fs_json_map>.
      <fs_json_map>-fieldname   = 'DOMAIN'. "<fs_dfies_tab_add>-fieldname.
      <fs_json_map>-tabname    = 'PROPERTIES'. "<fs_dfies_tab_add>-tabname.
      <fs_json_map>-ddlanguage  = sy-langu.
      <fs_json_map>-datatype    = 'STRG'. "<fs_dfies_tab_add>-datatype.
      <fs_json_map>-inttype     = 'g'.
      <fs_json_map>-intlen      = 8.

      APPEND INITIAL LINE TO gt_json_map ASSIGNING <fs_json_map>.
      <fs_json_map>-fieldname   = 'ENTITY'. "<fs_dfies_tab_add>-fieldname.
      <fs_json_map>-tabname    = 'PROPERTIES'. "<fs_dfies_tab_add>-tabname.
      <fs_json_map>-ddlanguage  = sy-langu.
      <fs_json_map>-datatype    = 'STRG'. "<fs_dfies_tab_add>-datatype.
      <fs_json_map>-inttype     = 'g'.
      <fs_json_map>-intlen      = 8.

      APPEND INITIAL LINE TO gt_json_map ASSIGNING <fs_json_map>.
      <fs_json_map>-fieldname   = 'DESCRIPTION'. "<fs_dfies_tab_add>-fieldname.
      <fs_json_map>-tabname     = 'PROPERTIES'. "<fs_dfies_tab_add>-tabname.
      <fs_json_map>-ddlanguage  = sy-langu.
      <fs_json_map>-datatype    = 'STRG'. "<fs_dfies_tab_add>-datatype.
      <fs_json_map>-inttype     = 'g'.
      <fs_json_map>-intlen      = 8.

      IF gs_oc_obj-data EQ abap_true.
        APPEND INITIAL LINE TO gt_json_map ASSIGNING <fs_json_map>.
        <fs_json_map>-fieldname   = 'TAG1'. "<fs_dfies_tab_add>-fieldname.
        <fs_json_map>-tabname     = 'PROPERTIES'. "<fs_dfies_tab_add>-tabname.
        <fs_json_map>-ddlanguage  = sy-langu.
        <fs_json_map>-datatype    = 'STRG'. "<fs_dfies_tab_add>-datatype.
        <fs_json_map>-inttype     = 'g'.
        <fs_json_map>-intlen      = 50.

        APPEND INITIAL LINE TO gt_json_map ASSIGNING <fs_json_map>.
        <fs_json_map>-fieldname   = 'TAG2'. "<fs_dfies_tab_add>-fieldname.
        <fs_json_map>-tabname     = 'PROPERTIES'. "<fs_dfies_tab_add>-tabname.
        <fs_json_map>-ddlanguage  = sy-langu.
        <fs_json_map>-datatype    = 'STRG'. "<fs_dfies_tab_add>-datatype.
        <fs_json_map>-inttype     = 'g'.
        <fs_json_map>-intlen      = 200.

        APPEND INITIAL LINE TO gt_json_map ASSIGNING <fs_json_map>.
        <fs_json_map>-fieldname   = 'TAG3'. "<fs_dfies_tab_add>-fieldname.
        <fs_json_map>-tabname     = 'PROPERTIES'. "<fs_dfies_tab_add>-tabname.
        <fs_json_map>-ddlanguage  = sy-langu.
        <fs_json_map>-datatype    = 'STRG'. "<fs_dfies_tab_add>-datatype.
        <fs_json_map>-inttype     = 'g'.
        <fs_json_map>-intlen      = 200.

        APPEND INITIAL LINE TO gt_json_map ASSIGNING <fs_json_map>.
        <fs_json_map>-fieldname   = 'TAG4'. "<fs_dfies_tab_add>-fieldname.
        <fs_json_map>-tabname     = 'PROPERTIES'. "<fs_dfies_tab_add>-tabname.
        <fs_json_map>-ddlanguage  = sy-langu.
        <fs_json_map>-datatype    = 'STRG'. "<fs_dfies_tab_add>-datatype.
        <fs_json_map>-inttype     = 'g'.
        <fs_json_map>-intlen      = 200.

        APPEND INITIAL LINE TO gt_json_map ASSIGNING <fs_json_map>.
        <fs_json_map>-fieldname   = 'TAG5'. "<fs_dfies_tab_add>-fieldname.
        <fs_json_map>-tabname     = 'PROPERTIES'. "<fs_dfies_tab_add>-tabname.
        <fs_json_map>-ddlanguage  = sy-langu.
        <fs_json_map>-datatype    = 'STRG'. "<fs_dfies_tab_add>-datatype.
        <fs_json_map>-inttype     = 'g'.
        <fs_json_map>-intlen      = 200.
      ENDIF.

      APPEND INITIAL LINE TO gt_json_map ASSIGNING <fs_json_map>.
      <fs_json_map>-fieldname   = 'FIELDNAME'. "<fs_dfies_tab_add>-fieldname.
      <fs_json_map>-tabname     = 'METADATADET'. "<fs_dfies_tab_add>-tabname.
      <fs_json_map>-ddlanguage  = sy-langu.
      <fs_json_map>-datatype    = 'STRG'. "<fs_dfies_tab_add>-datatype.
      <fs_json_map>-inttype     = 'g'.
      <fs_json_map>-intlen      = 8.

      APPEND INITIAL LINE TO gt_json_map ASSIGNING <fs_json_map>.
      <fs_json_map>-fieldname   = 'OFFSET'. "<fs_dfies_tab_add>-fieldname.
      <fs_json_map>-tabname     = 'METADATADET'. "<fs_dfies_tab_add>-tabname.
      <fs_json_map>-ddlanguage  = sy-langu.
      <fs_json_map>-datatype    = 'STRG'. "<fs_dfies_tab_add>-datatype.
      <fs_json_map>-inttype     = 'g'.
      <fs_json_map>-intlen      = 8.

      APPEND INITIAL LINE TO gt_json_map ASSIGNING <fs_json_map>.
      <fs_json_map>-fieldname   = 'LENGTH'. "<fs_dfies_tab_add>-fieldname.
      <fs_json_map>-tabname     = 'METADATADET'. "<fs_dfies_tab_add>-tabname.
      <fs_json_map>-ddlanguage  = sy-langu.
      <fs_json_map>-datatype    = 'STRG'. "<fs_dfies_tab_add>-datatype.
      <fs_json_map>-inttype     = 'g'.
      <fs_json_map>-intlen      = 8.

      APPEND INITIAL LINE TO gt_json_map ASSIGNING <fs_json_map>.
      <fs_json_map>-fieldname   = 'TYPE'. "<fs_dfies_tab_add>-fieldname.
      <fs_json_map>-tabname     = 'METADATADET'. "<fs_dfies_tab_add>-tabname.
      <fs_json_map>-ddlanguage  = sy-langu.
      <fs_json_map>-datatype    = 'STRG'. "<fs_dfies_tab_add>-datatype.
      <fs_json_map>-inttype     = 'g'.
      <fs_json_map>-intlen      = 8.

      APPEND INITIAL LINE TO gt_json_map ASSIGNING <fs_json_map>.
      <fs_json_map>-fieldname   = 'FIELDTEXT'. "<fs_dfies_tab_add>-fieldname.
      <fs_json_map>-tabname     = 'METADATADET'. "<fs_dfies_tab_add>-tabname.
      <fs_json_map>-ddlanguage  = sy-langu.
      <fs_json_map>-datatype    = 'STRG'. "<fs_dfies_tab_add>-datatype.
      <fs_json_map>-inttype     = 'g'.
      <fs_json_map>-intlen      = 8.

      APPEND INITIAL LINE TO gt_json_map ASSIGNING <fs_json_map>.
      <fs_json_map>-fieldname   = 'KEYFLAG'. "<fs_dfies_tab_add>-fieldname.
      <fs_json_map>-tabname     = 'METADATADET'. "<fs_dfies_tab_add>-tabname.
      <fs_json_map>-ddlanguage  = sy-langu.
      <fs_json_map>-datatype    = 'STRG'. "<fs_dfies_tab_add>-datatype.
      <fs_json_map>-inttype     = 'g'.
      <fs_json_map>-intlen      = 8.

    ELSE.
      APPEND INITIAL LINE TO gt_json_map ASSIGNING <fs_json_map>.
      <fs_json_map>-fieldname   = iv_type_field. "<fs_dfies_tab_add>-fieldname.
      <fs_json_map>-tabname     = iv_type_table . "<fs_dfies_tab_add>-tabname.
      <fs_json_map>-ddlanguage  = sy-langu.
      <fs_json_map>-datatype    = iv_type. "<fs_dfies_tab_add>-datatype.
      CASE iv_type.
        WHEN 'STRU'.
          <fs_json_map>-mask = 'STRUS'.
          <fs_json_map>-comptype = 'S'.
        WHEN 'TTYP'.
          <fs_json_map>-mask = 'TTYPL'.
          <fs_json_map>-comptype = 'L'.
      ENDCASE.
      <fs_json_map>-rollname    = iv_type_name.
    ENDIF.
  ENDMETHOD.


  METHOD SET_GLOBAL_VARIABLE.

    gv_kdoc          = iv_kdoc.
    gv_table         = iv_table.
    gv_dest          = iv_dest.
    gv_domainv       = iv_domainv.
    GV_ENTITY = iv_business_proc.
    gv_key_queue     = iv_key_queue.
    gv_batch         = iv_batch.

  ENDMETHOD.


  METHOD SET_JOIN.

    DATA: "lt_dependencies TYPE STANDARD TABLE OF ddldependency,
      lv_join            TYPE string,
      lv_fields          TYPE string,
      lv_sequence        TYPE string,
      lv_current_line    TYPE sy-index,
      lv_tabname         TYPE objectname,
      lt_relations_group TYPE STANDARD TABLE OF zonta_relations,
      lt_relations       TYPE STANDARD TABLE OF zonta_relations,
      ls_relations       TYPE zonta_relations,
      ls_group_ref       TYPE zonta_relations,
      ls_relations_tmp   TYPE zonta_relations,
      ls_parent          TYPE zonta_relations,
      lv_lines           TYPE sy-tabix.


    IF NOT gv_anytable IS INITIAL.
      r_join = gv_anytable.

    ELSE.
      FIELD-SYMBOLS: <fs_relations> TYPE zonta_relations.


      lt_relations_group = gt_relations.

      SORT gt_relations BY sequence
                           subsequence.

      SORT lt_relations_group BY sequence
                                 tabname
                                 parent_relation .

      DELETE ADJACENT DUPLICATES FROM lt_relations_group
                                 COMPARING sequence
                                           tabname
                                           parent_relation.

      LOOP AT lt_relations_group INTO ls_group_ref.

        lt_relations = gt_relations.

        DELETE lt_relations WHERE sequence NE ls_group_ref-sequence.

        lv_lines = lines( lt_relations ).

*      (ls_relations_tmp = lt_relations[ 1 ].

        READ TABLE lt_relations INDEX 1 INTO ls_relations_tmp .

        lv_tabname = ls_group_ref-tabname.

*      CALL FUNCTION 'RS_ABAP_GET_DDL_DEPENDENCIES_E'
*        EXPORTING
*          p_objectname   = lv_tabname
*        TABLES
*          p_dependencies = lt_dependencies
*        EXCEPTIONS
*          not_found      = 1
*          OTHERS         = 2.
*      IF sy-subrc EQ 0.
*        TRY.
*            DATA(ls_dependencies) = lt_dependencies[ objecttype = 'STOB' ].
*            lv_tabname = ls_dependencies-ddlname.
*
*          CATCH  cx_sy_itab_line_not_found.
*        ENDTRY.
*      ENDIF.


        IF ls_group_ref-parent_relation IS INITIAL.
          lv_sequence = 'T' && ls_group_ref-sequence.

          CONCATENATE lv_tabname "ls_group_ref->tabname
                     'AS'
                     lv_sequence "ls_group_ref-sequence
                     INTO r_join
                     SEPARATED BY space.
        ELSE.

*        data(ls_parent) = gt_relations[ tabname = ls_group_ref->parent_relation ].

          READ TABLE gt_relations WITH KEY tabname = ls_group_ref-parent_relation
                                  INTO ls_parent.

          lv_sequence = 'T' && ls_group_ref-sequence.

          CONCATENATE r_join
                      ls_relations_tmp-join_type 'JOIN'
                      lv_tabname "ls_group_ref->tabname
                      'AS'
                      lv_sequence "ls_group_ref-sequence
                      'ON'
                      INTO r_join
                      SEPARATED BY space.

          CLEAR lv_current_line.

          LOOP AT gt_relations ASSIGNING <fs_relations>
                               WHERE sequence        EQ ls_group_ref-sequence
                                 AND tabname         EQ ls_group_ref-tabname
                                 AND parent_relation EQ ls_group_ref-parent_relation.

            lv_current_line = lv_current_line + 1.

            lv_sequence = 'T' && ls_group_ref-sequence.

            lv_fields = lv_sequence            && "ls_group_ref-sequence &&
                        '~'                    &&
                        <fs_relations>-field_sec.

            CONCATENATE r_join
                        lv_fields
                        'EQ'
                      INTO r_join
                      SEPARATED BY space.

            lv_sequence = 'T' && ls_parent-sequence.

            lv_fields =  lv_sequence        &&"ls_parent-sequence &&
                         '~'                &&
                         <fs_relations>-field_main.

            IF NOT lv_current_line EQ lv_lines.
              CONCATENATE r_join
                          lv_fields
                          'AND'
                        INTO r_join
                        SEPARATED BY space.
            ELSE.
              CONCATENATE r_join
                          lv_fields
                        INTO r_join
                        SEPARATED BY space.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


METHOD set_key_any.

  DATA: lv_field TYPE string.
  FIELD-SYMBOLS: <fs_fcat>    TYPE LINE OF slis_t_fieldcat_alv,
                 <fs_field>   TYPE any,
                 <fs_columns> TYPE zonta_oc_col_all.

  LOOP AT it_fcat ASSIGNING <fs_fcat>
                   WHERE NOT key IS INITIAL.

    IF <fs_fcat>-col_pos NE 1.

      IF NOT iv_alias IS INITIAL.
        READ TABLE gt_columns_all WITH KEY fldname = <fs_fcat>-fieldname
                                  ASSIGNING <fs_columns>.

        IF sy-subrc EQ 0.
          IF NOT <fs_columns>-alias_fldname IS INITIAL.
            ASSIGN COMPONENT <fs_columns>-alias_fldname OF STRUCTURE is_line TO <fs_field>.
          ELSE.
            ASSIGN COMPONENT <fs_fcat>-fieldname OF STRUCTURE is_line TO <fs_field>.
          ENDIF.
        ELSE.
          ASSIGN COMPONENT <fs_fcat>-fieldname OF STRUCTURE is_line TO <fs_field>.
        ENDIF.
      ELSE.
        ASSIGN COMPONENT <fs_fcat>-fieldname OF STRUCTURE is_line TO <fs_field>.
      ENDIF.

      IF <fs_field> IS ASSIGNED.
        lv_field = <fs_field>.
        CONCATENATE rv_key
                    lv_field "<fs_field>
                    INTO rv_key
                    SEPARATED BY space.

        UNASSIGN <fs_field>.
      ENDIF.
    ENDIF.
  ENDLOOP.

  SHIFT rv_key LEFT DELETING LEADING space.

ENDMETHOD.


  METHOD set_metadata_node.
    DATA: lt_fcat       TYPE lvc_t_fcat,
          lt_fcat_evet  TYPE lvc_t_fcat,
          lt_fcat_event TYPE lvc_t_fcat,
          ls_fcat       TYPE dfies,
          ls_component  TYPE zonta_oc_col_all.

    FIELD-SYMBOLS: <fs_fcat>     TYPE LINE OF lvc_t_fcat,
                   <fs_metadata> TYPE any,
                   <fs_field>    TYPE any.

    FIELD-SYMBOLS: <fs_metadata_chg> TYPE STANDARD TABLE.

    ASSIGN cs_metadata TO <fs_metadata_chg>.

    lt_fcat = it_fcat.

    lt_fcat_event = it_fcat.

    DELETE lt_fcat WHERE tabname NE iv_tabname.

    DELETE lt_fcat_event WHERE tabname NE 'ZONST_OC_EVENTID'.

    APPEND LINES OF lt_fcat_event TO lt_fcat.

    LOOP AT lt_fcat ASSIGNING <fs_fcat>.

*      TRY.
*          data(ls_fcat) = gt_dfies_tab_cat [ tabname   = <fs_fcat>-tabname
*                                            fieldname = <fs_fcat>-fieldname ].

      READ TABLE gt_dfies_tab_cat WITH KEY tabname   = <fs_fcat>-tabname
                                           fieldname = <fs_fcat>-fieldname
                                           INTO ls_fcat.
      IF sy-subrc EQ 0.
        APPEND INITIAL LINE TO <fs_metadata_chg> ASSIGNING <fs_metadata>.

        ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE <fs_metadata> TO <fs_field>.

*        TRY.
*            data(ls_component) = gt_columns[ tabname = <fs_fcat>-tabname
*                                             fldname = <fs_fcat>-fieldname ].

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
*          CATCH   cx_sy_itab_line_not_found.
*            <fs_field> = ls_fcat-fieldname.
*        ENDTRY.

        REPLACE ALL OCCURRENCES OF '\'   IN <fs_field> WITH '_'.
        REPLACE ALL OCCURRENCES OF '/'   IN <fs_field> WITH '_'.

        TRANSLATE <fs_field> TO LOWER CASE.

        ASSIGN COMPONENT 'OFFSET' OF STRUCTURE <fs_metadata> TO <fs_field>.
        <fs_field>    = ls_fcat-offset.

        ASSIGN COMPONENT 'LENGTH' OF STRUCTURE <fs_metadata> TO <fs_field>.
        <fs_field>    = ls_fcat-outputlen.

        ASSIGN COMPONENT 'TYPE' OF STRUCTURE <fs_metadata> TO <fs_field>.
        <fs_field>      = ls_fcat-inttype.

        ASSIGN COMPONENT 'FIELDTEXT' OF STRUCTURE <fs_metadata> TO <fs_field>.
        <fs_field> = ls_fcat-fieldtext.

        ASSIGN COMPONENT 'KEYFLAG' OF STRUCTURE <fs_metadata> TO <fs_field>.
        IF NOT ls_fcat-keyflag IS INITIAL.
          <fs_field>   = ls_fcat-keyflag.
        ELSE.
          <fs_field>   = space. "'null'.
        ENDIF.
      ENDIF.
*        CATCH cx_sy_itab_line_not_found .
*      ENDTRY.
    ENDLOOP.

    IF NOT iv_tabname IS INITIAL AND
       NOT gv_kdoc IS INITIAL .

      me->set_metadata_table_node( EXPORTING iv_tabname = iv_tabname
                                   CHANGING cs_metadata     = cs_metadata ).
    ENDIF.

  ENDMETHOD.


METHOD set_metadata_node_any.
*  DATA: lt_fcat       TYPE lvc_t_fcat,
**       lt_fcat_evet  TYPE lvc_t_fcat,
**       lt_fcat_event TYPE lvc_t_fcat,
***       ls_fcat       TYPE dfies,
  DATA: ls_columns   TYPE zonta_oc_col_all,
        ls_component TYPE zonta_oc_col_all,
        lt_dfies_tab TYPE STANDARD TABLE OF  dfies.
*
  FIELD-SYMBOLS: <fs_fcat>      TYPE LINE OF slis_t_fieldcat_alv,
                 <fs_metadata>  TYPE any,
                 <fs_field>     TYPE any,
                 <fs_dfies_tab> TYPE dfies.

  FIELD-SYMBOLS: <fs_metadata_chg> TYPE STANDARD TABLE.

  ASSIGN ct_metadata TO <fs_metadata_chg>.

  IF gt_columns_all IS INITIAL.
    LOOP AT it_fcat ASSIGNING <fs_fcat>.

      APPEND INITIAL LINE TO <fs_metadata_chg> ASSIGNING <fs_metadata>.

      ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE <fs_metadata> TO <fs_field>.
*      <fs_field> = <fs_fcat>-fieldname.
      READ TABLE gt_columns_all WITH KEY tabname = <fs_fcat>-tabname
                                           fldname = <fs_fcat>-fieldname
                                           INTO ls_component.
      IF sy-subrc EQ 0.
        IF gv_bothnames EQ abap_true.
          <fs_field> = <fs_fcat>-fieldname &&
                       '_'                 &&
                       ls_component-alias_fldname.

        ELSE.
          IF gv_fieldname EQ abap_true.
            <fs_field> = <fs_fcat>-fieldname.
          ELSE.
            IF NOT ls_component-alias_fldname IS INITIAL.
              <fs_field> = ls_component-alias_fldname.
            ELSE.
              <fs_field> = <fs_fcat>-fieldname.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        <fs_field> = <fs_fcat>-fieldname.
      ENDIF.

      REPLACE ALL OCCURRENCES OF '\'   IN <fs_field> WITH '_'.
      REPLACE ALL OCCURRENCES OF '/'   IN <fs_field> WITH '_'.


      TRANSLATE <fs_field> TO LOWER CASE.

      ASSIGN COMPONENT 'OFFSET' OF STRUCTURE <fs_metadata> TO <fs_field>.
      <fs_field>    = <fs_fcat>-ddic_outputlen. "<fs_fcat>-offset.

      ASSIGN COMPONENT 'LENGTH' OF STRUCTURE <fs_metadata> TO <fs_field>.
      <fs_field>    = <fs_fcat>-ddic_outputlen.

      ASSIGN COMPONENT 'TYPE' OF STRUCTURE <fs_metadata> TO <fs_field>.
      <fs_field>      = <fs_fcat>-inttype.

      ASSIGN COMPONENT 'FIELDTEXT' OF STRUCTURE <fs_metadata> TO <fs_field>.
      <fs_field> = <fs_fcat>-seltext_l.

      ASSIGN COMPONENT 'KEYFLAG' OF STRUCTURE <fs_metadata> TO <fs_field>.
      IF NOT <fs_fcat>-key IS INITIAL.
        <fs_field>   = <fs_fcat>-key.
      ELSE.
        <fs_field>   = space.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT it_fcat ASSIGNING <fs_fcat>.

      READ TABLE gt_columns_all WITH KEY fldname = <fs_fcat>-fieldname
                                INTO ls_columns.
      IF sy-subrc EQ 0.
        APPEND INITIAL LINE TO <fs_metadata_chg> ASSIGNING <fs_metadata>.

        ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE <fs_metadata> TO <fs_field>.

        IF gv_bothnames EQ abap_true.
          <fs_field> = <fs_fcat>-fieldname &&
                       '_'               &&
                       ls_columns-alias_fldname.

        ELSE.
          IF gv_fieldname EQ abap_true.
            <fs_field> = <fs_fcat>-fieldname.
          ELSE.
            IF NOT ls_columns-alias_fldname IS INITIAL.
              <fs_field> = ls_columns-alias_fldname.
            ELSE.
              <fs_field> = <fs_fcat>-fieldname.
            ENDIF.
          ENDIF.
        ENDIF.

        REPLACE ALL OCCURRENCES OF '\'   IN <fs_field> WITH '_'.
        REPLACE ALL OCCURRENCES OF '/'   IN <fs_field> WITH '_'.

        TRANSLATE <fs_field> TO LOWER CASE.

        ASSIGN COMPONENT 'OFFSET' OF STRUCTURE <fs_metadata> TO <fs_field>.
        <fs_field>    = <fs_fcat>-ddic_outputlen. "<fs_fcat>-offset.

        ASSIGN COMPONENT 'LENGTH' OF STRUCTURE <fs_metadata> TO <fs_field>.
        <fs_field>    = <fs_fcat>-ddic_outputlen.

        ASSIGN COMPONENT 'TYPE' OF STRUCTURE <fs_metadata> TO <fs_field>.
        <fs_field>      = <fs_fcat>-inttype.

        ASSIGN COMPONENT 'FIELDTEXT' OF STRUCTURE <fs_metadata> TO <fs_field>.
        IF iv_alias IS INITIAL.
          IF NOT ls_columns-alias_fldname IS INITIAL.
            <fs_field> = ls_columns-description_field.
          ELSE.
            <fs_field> = <fs_fcat>-seltext_l.
          ENDIF.
        ELSE.
          <fs_field> = <fs_fcat>-seltext_l.
        ENDIF.

        ASSIGN COMPONENT 'KEYFLAG' OF STRUCTURE <fs_metadata> TO <fs_field>.
        IF NOT <fs_fcat>-key IS INITIAL.
          <fs_field>   = <fs_fcat>-key.
        ELSE.
          <fs_field>   = space.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

** Start Add Event id fields
  IF gs_oc_obj-eventid EQ abap_true.

    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname        = 'ZONST_OC_EVENTID'
      TABLES
        dfies_tab      = lt_dfies_tab
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.

    LOOP AT lt_dfies_tab ASSIGNING <fs_dfies_tab>
                           WHERE fieldname NE 'MANDT'.
      APPEND INITIAL LINE TO <fs_metadata_chg> ASSIGNING <fs_metadata>.

      ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE <fs_metadata> TO <fs_field>.
      <fs_field> = <fs_dfies_tab>-fieldname.

      TRANSLATE <fs_field> TO LOWER CASE.

      ASSIGN COMPONENT 'OFFSET' OF STRUCTURE <fs_metadata> TO <fs_field>.
      <fs_field>    = <fs_dfies_tab>-offset.

      ASSIGN COMPONENT 'LENGTH' OF STRUCTURE <fs_metadata> TO <fs_field>.
      <fs_field>    = <fs_dfies_tab>-outputlen.

      ASSIGN COMPONENT 'TYPE' OF STRUCTURE <fs_metadata> TO <fs_field>.
      <fs_field>      = <fs_dfies_tab>-inttype.

      ASSIGN COMPONENT 'FIELDTEXT' OF STRUCTURE <fs_metadata> TO <fs_field>.
      <fs_field> = <fs_dfies_tab>-scrtext_l.


      ASSIGN COMPONENT 'KEYFLAG' OF STRUCTURE <fs_metadata> TO <fs_field>.
      IF NOT <fs_fcat>-key IS INITIAL.
        <fs_field>   = <fs_dfies_tab>-keyflag.
      ELSE.
        <fs_field>   = space.
      ENDIF.

    ENDLOOP.

  ENDIF.

** End Add Event id fields

ENDMETHOD.


  METHOD SET_METADATA_TABLE_NODE.
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
                                   WHERE parent_relation EQ iv_tabname.

      APPEND INITIAL LINE TO <fs_metadata_chg> ASSIGNING <fs_metadata>.
*      IF NOT <fs_relations>-alias_tabname IS INITIAL.
*        lv_fieldname = <fs_relations>-alias_tabname.
*      ELSE.
*        lv_fieldname = <fs_relations>-tabname.
*      ENDIF.

      lv_fieldname = 'SEQ' && <fs_relations>-sequence.

      TRANSLATE lv_fieldname TO LOWER CASE.

      ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE <fs_metadata> TO <fs_field>.
      <fs_field> = lv_fieldname.

      ASSIGN COMPONENT 'OFFSET' OF STRUCTURE <fs_metadata> TO <fs_field>.
      <fs_field>    = '0'.

      ASSIGN COMPONENT 'LENGTH' OF STRUCTURE <fs_metadata> TO <fs_field>.
      <fs_field>    = '0'.

      ASSIGN COMPONENT 'TYPE' OF STRUCTURE <fs_metadata> TO <fs_field>.
      <fs_field>      = 'table'.

      ASSIGN COMPONENT 'FIELDTEXT' OF STRUCTURE <fs_metadata> TO <fs_field>.
      <fs_field> = lv_fieldname.

      ASSIGN COMPONENT 'KEYFLAG' OF STRUCTURE <fs_metadata> TO <fs_field>.
      <fs_field>   = space. "'null'.
    ENDLOOP.
  ENDMETHOD.


METHOD SET_PROCESS.
  DATA: lv_answer TYPE char1.
  CALL FUNCTION 'POPUP_WITH_2_BUTTONS_TO_CHOOSE'
    EXPORTING
*     DEFAULTOPTION = '1'
      diagnosetext1 = 'Execution Mode'
*     DIAGNOSETEXT2 = ' '
*     DIAGNOSETEXT3 = ' '
      textline1     = 'Please select mode'
*     TEXTLINE2     = ' '
*     TEXTLINE3     = ' '
      text_option1  = 'Online'
      text_option2  = 'Background'
      titel         = 'Process'
    IMPORTING
      answer        = lv_answer.

  IF lv_answer EQ 1.
  ELSE.
    gv_batch = abap_true.
  ENDIF.
  .
ENDMETHOD.


  METHOD set_process_log.

**      IF prlog IS NOT INITIAL.
    DATA: lv_log_handle TYPE balloghndl.
    DATA: ls_log_header TYPE bal_s_log.

* Populate log header information
    ls_log_header-object    = 'ZONI_OC'.     " Your object from SLG0
    ls_log_header-subobject = 'PROCESS_LOG'.  " Your subobject from SLG0 (optional)
    ls_log_header-extnumber = i_process. " External number (e.g., document number, unique ID)
    ls_log_header-aluser    = sy-uname.     " User who created the log
    ls_log_header-alprog    = sy-repid.     " Program that created the log
* Add more fields as needed from BAL_S_LOG structure
*do. enddo.
    CALL FUNCTION 'BAL_LOG_CREATE'
      EXPORTING
        i_s_log                 = ls_log_header
      IMPORTING
        e_log_handle            = lv_log_handle
      EXCEPTIONS
        log_header_inconsistent = 1
        OTHERS                  = 2.
    DATA lV_msg        TYPE  bal_s_msg.

    lV_msg-msgty     = 'S'.
    lV_msg-msgid     = '99'.
    lV_msg-msgno     = '999'.
    lV_msg-msgv1     = I_text1.
    lV_msg-msgv2     = I_text2.
    lV_msg-msgv3     = i_text3.
    lV_msg-msgv4     = i_text4.
    lV_msg-probclass = 2.

    CALL FUNCTION 'BAL_LOG_MSG_ADD' ##FM_SUBRC_OK
      EXPORTING
        i_log_handle     = lV_log_handle
        i_s_msg          = lV_msg
      EXCEPTIONS
        log_not_found    = 1
        msg_inconsistent = 2
        log_is_full      = 3
        OTHERS           = 4.



    DATA: lt_log_handle TYPE bal_t_logh.

    APPEND lv_log_handle TO lt_log_handle. " Append your log handle(s) to a table


    CALL FUNCTION 'BAL_DB_SAVE'
      EXPORTING
        i_t_log_handle   = lt_log_handle " Table of log handles to save
        i_save_all       = 'X'           " Save all logs in memory
      EXCEPTIONS
        log_not_found    = 1
        save_not_allowed = 2
        numbering_error  = 3
        OTHERS           = 4.
    COMMIT WORK AND WAIT .


  ENDMETHOD.


  METHOD set_table.
    DATA: lt_dfies_tab     TYPE STANDARD TABLE OF dfies,
          lt_dfies_tab_cat TYPE STANDARD TABLE OF dfies,
          ls_dfies_tab_cat TYPE dfies,
          lt_relations     TYPE STANDARD TABLE OF zonta_relations,
          lt_columns       TYPE STANDARD TABLE OF zonta_oc_col_all.
*          lt_dependencies  TYPE STANDARD TABLE OF ddldependency.

    DATA: gw_dyn_fcat TYPE lvc_s_fcat,
          gt_dyn_fcat TYPE lvc_t_fcat.

    DATA : gv_pos TYPE i.
    DATA : fname TYPE string.


    DATA: lv_field   TYPE string,
          lv_tabname TYPE  ddobjname.

    FIELD-SYMBOLS: <fs_relations>     TYPE zonta_relations,
                   <fs_columns>       TYPE zonta_oc_col_all,
                   <fs_dfies_tab>     TYPE dfies,
                   <fs_json_map>      TYPE dd03p,
                   <fs_dfies_tab_add> TYPE dfies.

    DATA : gt_dyn_table  TYPE REF TO data.

    FIELD-SYMBOLS: <gfs_dyn_table> TYPE STANDARD TABLE.

    SORT gt_dyn_fcat BY fieldname.

    IF NOT gv_anytable IS INITIAL.
      CREATE DATA gt_dyn_table TYPE (gv_anytable).
    ELSE.
      lt_relations = gt_relations.
      lt_columns   = gt_columns_all.

      DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING sequence.

      SORT lt_columns BY fldname tabname.

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

        APPEND LINES OF lt_dfies_tab TO lt_dfies_tab_cat.
      ENDLOOP.
***13.05.25 fr begin
      LOOP AT lt_dfies_tab_cat INTO ls_dfies_tab_cat.
        REPLACE ALL OCCURRENCES OF '/' IN ls_dfies_tab_cat-fieldtext WITH '_'.
        REPLACE ALL OCCURRENCES OF '\' IN ls_dfies_tab_cat-fieldtext WITH '_'.
        REPLACE ALL OCCURRENCES OF '"' IN ls_dfies_tab_cat-fieldtext WITH '_'.
        MODIFY lt_dfies_tab_cat FROM ls_dfies_tab_cat.
      ENDLOOP.
***13.05.25 fr end

** This would create structure Vendor Jan13 Feb13 Mar13 ....

      LOOP AT lt_relations ASSIGNING <fs_relations>.
        LOOP AT lt_columns ASSIGNING <fs_columns>
                            WHERE tabname EQ <fs_relations>-tabname.
          READ TABLE lt_dfies_tab_cat WITH KEY  tabname   = <fs_columns>-tabname
                                                fieldname = <fs_columns>-fldname
                                                ASSIGNING <fs_dfies_tab>.
          IF sy-subrc EQ 0.
            gv_pos = gv_pos + 1.

            IF NOT gv_alias IS INITIAL.
              IF NOT <fs_columns>-alias_fldname IS INITIAL.
                gw_dyn_fcat-fieldname = <fs_columns>-alias_fldname.
              ELSE.
                gw_dyn_fcat-fieldname = <fs_dfies_tab>-fieldname.
              ENDIF.
            ELSE.
              gw_dyn_fcat-fieldname = <fs_dfies_tab>-fieldname.
            ENDIF.

            TRANSLATE gw_dyn_fcat-fieldname TO UPPER CASE.

*          IF NOT line_exists( gt_dyn_fcat[ fieldname = gw_dyn_fcat-fieldname ] ).
            READ TABLE gt_dyn_fcat WITH KEY fieldname = gw_dyn_fcat-fieldname
                                   TRANSPORTING NO FIELDS.
*            IF sy-subrc eq 0.
            gw_dyn_fcat-fieldname = gw_dyn_fcat-fieldname && <fs_relations>-sequence.
*            ENDIF.
*            MOVE-CORRESPONDING <fs_dfies_tab> to gw_dyn_fcat.
            gw_dyn_fcat-tabname   = <fs_dfies_tab>-tabname.
*            gw_dyn_fcat-coltext   = <fs_dfies_tab>-scrtext_l.
            gw_dyn_fcat-col_pos   = gv_pos ."<fs_dfies_tab>-position."gv_pos.
            gw_dyn_fcat-key       = <fs_dfies_tab>-keyflag.
*            gw_dyn_fcat-datatype  = <fs_dfies_tab>-datatype.
*            gw_dyn_fcat-intlen    = <fs_dfies_tab>-intlen.
*            gw_dyn_fcat-outputlen = <fs_dfies_tab>-outputlen.
            gw_dyn_fcat-ref_field = <fs_dfies_tab>-fieldname.
            gw_dyn_fcat-ref_table = <fs_dfies_tab>-tabname.
            APPEND gw_dyn_fcat TO gt_dyn_fcat.
            CLEAR gw_dyn_fcat.
*            ENDIF.

            APPEND INITIAL LINE TO gt_json_map ASSIGNING <fs_json_map>.

            MOVE-CORRESPONDING <fs_dfies_tab> TO <fs_json_map>.

*CECHAVARRIA 12/06/2025
*Validate if reftable is a CDS, add correct table DDIC
            IF abap_true = is_cds_entity( iv_tabname = <fs_json_map>-reftable ) AND
              <fs_json_map>-reftable IS NOT INITIAL.
              <fs_json_map>-reftable = get_ddicobject_from_cds( iv_tabname = <fs_json_map>-reftable ).
            ENDIF.
*CECHAVARRIA 12/06/2025

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
*          <fs_json_map>-fieldname = <fs_dfies_tab>-fieldname.
            <fs_json_map>-tabname   = <fs_dfies_tab>-tabname.
*          gw_dyn_fcat-coltext   = <fs_dfies_tab>-scrtext_l.
            <fs_json_map>-datatype  = <fs_dfies_tab>-datatype.
            <fs_json_map>-leng      = <fs_dfies_tab>-leng.
            <fs_json_map>-position  = <fs_dfies_tab>-position.
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

          LOOP AT lt_dfies_tab ASSIGNING <fs_dfies_tab>
                               WHERE fieldname NE 'MANDT'.

*          IF NOT line_exists( gt_dyn_fcat[ fieldname = <fs_dfies_tab>-fieldname ] ).
            READ TABLE gt_dyn_fcat WITH KEY fieldname = <fs_dfies_tab>-fieldname
                                   TRANSPORTING NO FIELDS.
*            IF sy-subrc NE 0.
*              lv_field = <fs_dfies_tab>-fieldname.
*            ELSE.
            lv_field = <fs_dfies_tab>-fieldname && <fs_relations>-sequence.
*            ENDIF.

            READ TABLE lt_dfies_tab_cat WITH KEY tabname   = <fs_dfies_tab>-tabname
                                                 fieldname = <fs_dfies_tab>-fieldname
                                           ASSIGNING <fs_dfies_tab_add>.
            IF sy-subrc EQ 0.
              gv_pos = gv_pos + 1.

              gw_dyn_fcat-fieldname = lv_field.
              gw_dyn_fcat-tabname   = <fs_dfies_tab_add>-tabname.
              gw_dyn_fcat-coltext   = <fs_dfies_tab_add>-scrtext_l.
              gw_dyn_fcat-col_pos   = gv_pos. "<fs_dfies_tab>-position. "gv_pos.
              gw_dyn_fcat-key       = <fs_dfies_tab_add>-keyflag.
              gw_dyn_fcat-datatype  = <fs_dfies_tab>-datatype.
              APPEND gw_dyn_fcat TO gt_dyn_fcat.
              CLEAR gw_dyn_fcat.

              APPEND INITIAL LINE TO gt_json_map ASSIGNING <fs_json_map>.

              MOVE-CORRESPONDING <fs_dfies_tab> TO <fs_json_map>.

              <fs_json_map>-fieldname = <fs_dfies_tab_add>-fieldname.
              <fs_json_map>-tabname   = <fs_dfies_tab_add>-tabname.
*          gw_dyn_fcat-coltext   = <fs_dfies_tab>-scrtext_l.
              <fs_json_map>-datatype  = <fs_dfies_tab_add>-datatype.
              <fs_json_map>-leng      = <fs_dfies_tab_add>-leng.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDLOOP.

** Start Add Event id fields
      IF gs_oc_obj-eventid  EQ abap_true OR
         gs_oc_obj-metadata EQ abap_true.

*      SORT gt_dyn_fcat BY col_pos.

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
                                   OR fieldname EQ 'EVENTID'.

          ENDIF.

          IF gs_oc_obj-metadata EQ abap_false.
            DELETE lt_dfies_tab WHERE fieldname(03) EQ 'TAG'.
          ENDIF.
          APPEND LINES OF lt_dfies_tab TO lt_dfies_tab_cat.
        ENDIF.

*      DESCRIBE TABLE  gt_dyn_fcat LINES gv_pos.
*
*      READ TABLE gt_dyn_fcat INDEX gv_pos
*                             INTO gw_dyn_fcat.
*      IF sy-subrc EQ 0.
*        gv_pos = gw_dyn_fcat-col_pos.
*      ENDIF.

        LOOP AT lt_dfies_tab ASSIGNING <fs_dfies_tab>
                               WHERE fieldname NE 'MANDT'.

*        IF NOT line_exists( gt_dyn_fcat[ fieldname = <fs_dfies_tab>-fieldname ] ).
          READ TABLE gt_dyn_fcat WITH KEY fieldname = <fs_dfies_tab>-fieldname
                                TRANSPORTING NO FIELDS.
*          IF sy-subrc NE 0.
*            lv_field = <fs_dfies_tab>-fieldname.
*          ELSE.
          lv_field = <fs_dfies_tab>-fieldname && <fs_relations>-sequence.
*          ENDIF.

          READ TABLE lt_dfies_tab_cat WITH KEY tabname   = <fs_dfies_tab>-tabname
                                               fieldname = <fs_dfies_tab>-fieldname
                                         ASSIGNING <fs_dfies_tab_add>.
          IF sy-subrc EQ 0.
            gv_pos = gv_pos + 1.

            gw_dyn_fcat-fieldname = lv_field.
            gw_dyn_fcat-tabname   = <fs_dfies_tab_add>-tabname.
            gw_dyn_fcat-coltext   = <fs_dfies_tab_add>-scrtext_l.
            gw_dyn_fcat-col_pos   = gv_pos.
            gw_dyn_fcat-key       = <fs_dfies_tab_add>-keyflag.
            gw_dyn_fcat-datatype  = <fs_dfies_tab>-datatype.
            gw_dyn_fcat-inttype   = <fs_dfies_tab>-inttype.
            gw_dyn_fcat-intlen    = <fs_dfies_tab>-intlen.
            APPEND gw_dyn_fcat TO gt_dyn_fcat.
            CLEAR gw_dyn_fcat.

            APPEND INITIAL LINE TO gt_json_map ASSIGNING <fs_json_map>.

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
        gv_pos = gv_pos + 1.

        gw_dyn_fcat-fieldname = 'TABNAME'.
        gw_dyn_fcat-coltext   = 'Table Name'.
        gw_dyn_fcat-col_pos   = gv_pos.
        gw_dyn_fcat-datatype  = 'C'.
        gw_dyn_fcat-inttype   = 'C'.
        gw_dyn_fcat-intlen    = 30.

        APPEND gw_dyn_fcat TO gt_dyn_fcat.
        CLEAR gw_dyn_fcat.

      ENDIF.

* Create a dynamic internal table with this structure.

      DELETE ADJACENT DUPLICATES FROM gt_dyn_fcat COMPARING fieldname.

      SORT gt_dyn_fcat BY tabname col_pos.

      CALL METHOD cl_alv_table_create=>create_dynamic_table
        EXPORTING
          i_style_table             = abap_false "'X'
          it_fieldcatalog           = gt_dyn_fcat
        IMPORTING
          ep_table                  = gt_dyn_table
        EXCEPTIONS
          generate_subpool_dir_full = 1
          OTHERS                    = 2.

    ENDIF.

    ASSIGN gt_dyn_table->* TO <gfs_dyn_table>.

    rt_table = gt_dyn_table.

    gt_dfies_tab_cat = lt_dfies_tab_cat.

    SORT gt_json_map BY tabname position.

  ENDMETHOD.


  METHOD set_table_any.

    DATA: gw_dyn_fcat      TYPE lvc_s_fcat,
          gt_dyn_fcat      TYPE lvc_t_fcat,
          lt_dfies_tab     TYPE STANDARD TABLE OF dfies,
          lt_dfies_tab_cat TYPE STANDARD TABLE OF dfies,
          ls_fcat          TYPE LINE OF slis_t_fieldcat_alv.

    DATA : gv_pos TYPE i.
    DATA : fname TYPE string.


    DATA: lv_field   TYPE string,
          lv_tabname TYPE  ddobjname.

    FIELD-SYMBOLS: <fs_fcat>          TYPE any,
                   <fs_columns>       TYPE zonta_oc_col_all,
                   <fs_dfies_tab>     TYPE dfies,
                   <fs_dfies_tab_add> TYPE dfies.

*** This would create structure Vendor Jan13 Feb13 Mar13 ....
    IF iv_anytable IS INITIAL.
      SORT gt_columns_all BY key_field DESCENDING.

      IF NOT gt_columns_all IS INITIAL.
        LOOP AT gt_columns_all ASSIGNING <fs_columns>.
          READ TABLE it_fcat WITH KEY  "tabname   = <fs_columns>-tabname
                                       fieldname = <fs_columns>-fldname
                                       ASSIGNING <fs_fcat>.
          IF sy-subrc EQ 0.
            MOVE-CORRESPONDING <fs_fcat> TO gw_dyn_fcat.

            IF  gv_fieldname IS INITIAL .
              IF NOT gv_bothnames IS INITIAL.
                gw_dyn_fcat-fieldname = <fs_columns>-fldname.
              ELSE.
                IF NOT <fs_columns>-alias_fldname IS INITIAL.
                  gw_dyn_fcat-fieldname = <fs_columns>-alias_fldname.
                ELSE.
                  gw_dyn_fcat-fieldname = <fs_columns>-fldname.
                ENDIF.
              ENDIF.
            ELSE.
              gw_dyn_fcat-fieldname = <fs_columns>-fldname.
            ENDIF.

            TRANSLATE gw_dyn_fcat-fieldname TO UPPER CASE.

            APPEND gw_dyn_fcat TO gt_dyn_fcat.

          ENDIF.
        ENDLOOP.
      ELSE.
        LOOP AT it_fcat ASSIGNING <fs_fcat>.
          gv_pos = gv_pos + 1.
          MOVE-CORRESPONDING <fs_fcat> TO gw_dyn_fcat.
          APPEND gw_dyn_fcat TO gt_dyn_fcat.
        ENDLOOP.
      ENDIF.

    ELSE.
      LOOP AT it_fcat ASSIGNING <fs_fcat>.
        gv_pos = gv_pos + 1.

        MOVE-CORRESPONDING <fs_fcat> TO gw_dyn_fcat.
        APPEND gw_dyn_fcat TO gt_dyn_fcat.
      ENDLOOP.
    ENDIF.

** Start Add Event id fields
    IF gs_oc_obj-eventid  EQ abap_true OR
       gs_oc_obj-metadata EQ abap_true.

      SORT gt_dyn_fcat BY col_pos.

      DESCRIBE TABLE gt_dyn_fcat LINES gv_pos.

      READ TABLE gt_dyn_fcat INDEX gv_pos
                             INTO gw_dyn_fcat.

      gv_pos = gw_dyn_fcat-col_pos..


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
        APPEND LINES OF lt_dfies_tab TO lt_dfies_tab_cat.
      ENDIF.


      LOOP AT lt_dfies_tab ASSIGNING <fs_dfies_tab>
                             WHERE fieldname NE 'MANDT'.

        READ TABLE gt_dyn_fcat WITH KEY fieldname = <fs_dfies_tab>-fieldname
                              TRANSPORTING NO FIELDS.
        IF sy-subrc NE 0.
          lv_field = <fs_dfies_tab>-fieldname.
        ELSE.
          CONTINUE.
        ENDIF.

        READ TABLE lt_dfies_tab_cat WITH KEY tabname   = <fs_dfies_tab>-tabname
                                             fieldname = <fs_dfies_tab>-fieldname
                                       ASSIGNING <fs_dfies_tab_add>.
        IF sy-subrc EQ 0.

          CLEAR gw_dyn_fcat.

          gv_pos = gv_pos + 1.

          gw_dyn_fcat-fieldname = lv_field.
          gw_dyn_fcat-tabname   = <fs_dfies_tab_add>-tabname.
          gw_dyn_fcat-coltext   = <fs_dfies_tab_add>-scrtext_l.
          gw_dyn_fcat-col_pos   = gv_pos.
          gw_dyn_fcat-key       = <fs_dfies_tab_add>-keyflag.
          gw_dyn_fcat-datatype  = <fs_dfies_tab>-datatype.
          gw_dyn_fcat-inttype   = <fs_dfies_tab>-inttype.
          gw_dyn_fcat-intlen              = <fs_dfies_tab>-intlen.
          APPEND gw_dyn_fcat TO gt_dyn_fcat.
          CLEAR gw_dyn_fcat.

        ENDIF.
      ENDLOOP.

    ENDIF.

** End Add Event id fields

* Create a dynamic internal table with this structure.
    DATA : gt_dyn_table  TYPE REF TO data.

    FIELD-SYMBOLS: <gfs_dyn_table> TYPE STANDARD TABLE.

    SORT gt_dyn_fcat BY fieldname.

    DELETE ADJACENT DUPLICATES FROM gt_dyn_fcat COMPARING fieldname.

    SORT gt_dyn_fcat BY tabname col_pos.

    CALL METHOD cl_alv_table_create=>create_dynamic_table
      EXPORTING
        i_style_table             = abap_false "'X'
        it_fieldcatalog           = gt_dyn_fcat
      IMPORTING
        ep_table                  = gt_dyn_table
      EXCEPTIONS
        generate_subpool_dir_full = 1
        OTHERS                    = 2.

    ASSIGN gt_dyn_table->* TO <gfs_dyn_table>.

    rt_table = gt_dyn_table.

*    gt_dfies_tab_cat = lt_dfies_tab_cat.
*
*    SORT gt_json_map BY tabname position.


  ENDMETHOD.


  METHOD set_table_any_cond.

    DATA: gw_dyn_fcat      TYPE lvc_s_fcat,
          gt_dyn_fcat      TYPE lvc_t_fcat,
          lt_dfies_tab     TYPE STANDARD TABLE OF dfies,
          lt_dfies_tab_cat TYPE STANDARD TABLE OF dfies,
          ls_fcat          TYPE LINE OF slis_t_fieldcat_alv.

    DATA : gv_pos TYPE i.
    DATA : fname TYPE string.


    DATA: lv_field   TYPE string,
          lv_tabname TYPE  ddobjname.

    FIELD-SYMBOLS: <fs_fcat>          TYPE any,
                   <fs_columns>       TYPE zonta_oc_col_all,
                   <fs_dfies_tab>     TYPE dfies,
                   <fs_dfies_tab_add> TYPE dfies.

*** This would create structure Vendor Jan13 Feb13 Mar13 ....
    IF iv_anytable IS INITIAL.
      SORT gt_columns_all BY key_field DESCENDING.

      IF NOT gt_columns_all IS INITIAL.
        LOOP AT gt_columns_all ASSIGNING <fs_columns>.
          READ TABLE it_fcat WITH KEY  "tabname   = <fs_columns>-tabname
                                       fieldname = <fs_columns>-fldname
                                       ASSIGNING <fs_fcat>.
          IF sy-subrc EQ 0.
            MOVE-CORRESPONDING <fs_fcat> TO gw_dyn_fcat.

*            IF  gv_fieldname IS INITIAL .
*              IF NOT gv_bothnames IS INITIAL.
*                gw_dyn_fcat-fieldname = <fs_columns>-fldname.
*              ELSE.
*                IF NOT <fs_columns>-alias_fldname IS INITIAL.
*                  gw_dyn_fcat-fieldname = <fs_columns>-alias_fldname.
*                ELSE.
*                  gw_dyn_fcat-fieldname = <fs_columns>-fldname.
*                ENDIF.
*              ENDIF.
*            ELSE.
            gw_dyn_fcat-fieldname = <fs_columns>-fldname.
*            ENDIF.

            TRANSLATE gw_dyn_fcat-fieldname TO UPPER CASE.

            APPEND gw_dyn_fcat TO gt_dyn_fcat.

          ENDIF.
        ENDLOOP.
      ELSE.
        LOOP AT it_fcat ASSIGNING <fs_fcat>.
          gv_pos = gv_pos + 1.
          MOVE-CORRESPONDING <fs_fcat> TO gw_dyn_fcat.
          APPEND gw_dyn_fcat TO gt_dyn_fcat.
        ENDLOOP.
      ENDIF.

    ELSE.
      LOOP AT it_fcat ASSIGNING <fs_fcat>.
        gv_pos = gv_pos + 1.

        MOVE-CORRESPONDING <fs_fcat> TO gw_dyn_fcat.
        APPEND gw_dyn_fcat TO gt_dyn_fcat.
      ENDLOOP.
    ENDIF.

** Start Add Event id fields
    IF gs_oc_obj-eventid  EQ abap_true OR
       gs_oc_obj-metadata EQ abap_true.

      SORT gt_dyn_fcat BY col_pos.

      DESCRIBE TABLE gt_dyn_fcat LINES gv_pos.

      READ TABLE gt_dyn_fcat INDEX gv_pos
                             INTO gw_dyn_fcat.

      gv_pos = gw_dyn_fcat-col_pos..


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
        APPEND LINES OF lt_dfies_tab TO lt_dfies_tab_cat.
      ENDIF.


      LOOP AT lt_dfies_tab ASSIGNING <fs_dfies_tab>
                             WHERE fieldname NE 'MANDT'.

        READ TABLE gt_dyn_fcat WITH KEY fieldname = <fs_dfies_tab>-fieldname
                              TRANSPORTING NO FIELDS.
        IF sy-subrc NE 0.
          lv_field = <fs_dfies_tab>-fieldname.
        ELSE.
          CONTINUE.
        ENDIF.

        READ TABLE lt_dfies_tab_cat WITH KEY tabname   = <fs_dfies_tab>-tabname
                                             fieldname = <fs_dfies_tab>-fieldname
                                       ASSIGNING <fs_dfies_tab_add>.
        IF sy-subrc EQ 0.

          CLEAR gw_dyn_fcat.

          gv_pos = gv_pos + 1.

          gw_dyn_fcat-fieldname = lv_field.
          gw_dyn_fcat-tabname   = <fs_dfies_tab_add>-tabname.
          gw_dyn_fcat-coltext   = <fs_dfies_tab_add>-scrtext_l.
          gw_dyn_fcat-col_pos   = gv_pos.
          gw_dyn_fcat-key       = <fs_dfies_tab_add>-keyflag.
          gw_dyn_fcat-datatype  = <fs_dfies_tab>-datatype.
          gw_dyn_fcat-inttype   = <fs_dfies_tab>-inttype.
          gw_dyn_fcat-intlen              = <fs_dfies_tab>-intlen.
          APPEND gw_dyn_fcat TO gt_dyn_fcat.
          CLEAR gw_dyn_fcat.

        ENDIF.
      ENDLOOP.

    ENDIF.

** End Add Event id fields

* Create a dynamic internal table with this structure.
    DATA : gt_dyn_table  TYPE REF TO data.

    FIELD-SYMBOLS: <gfs_dyn_table> TYPE STANDARD TABLE.

    SORT gt_dyn_fcat BY fieldname.

    DELETE ADJACENT DUPLICATES FROM gt_dyn_fcat COMPARING fieldname.

    SORT gt_dyn_fcat BY tabname col_pos.

    CALL METHOD cl_alv_table_create=>create_dynamic_table
      EXPORTING
        i_style_table             = abap_false "'X'
        it_fieldcatalog           = gt_dyn_fcat
      IMPORTING
        ep_table                  = gt_dyn_table
      EXCEPTIONS
        generate_subpool_dir_full = 1
        OTHERS                    = 2.

    ASSIGN gt_dyn_table->* TO <gfs_dyn_table>.

    rt_table = gt_dyn_table.

*    gt_dfies_tab_cat = lt_dfies_tab_cat.
*
*    SORT gt_json_map BY tabname position.


  ENDMETHOD.


  method SET_TRKORR.
    gv_korrnum = iv_tkorr.
  endmethod.


  METHOD set_where.
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
    DATA: lt_relations TYPE STANDARD TABLE OF zonta_relations,
          lt_columns   TYPE STANDARD TABLE OF zonta_oc_col_all,
          lt_cond_tab  TYPE ty_rsds_twhere,
          ls_relations TYPE zonta_relations,
          ls_cond_tab  TYPE LINE OF ty_rsds_twhere,
          lv_lines     TYPE sy-tabix,
          lv_sequence  TYPE string,
          lv_tabname   TYPE  ddobjname.

    FIELD-SYMBOLS: <fs_relations>      TYPE zonta_relations,
                   <fs_table_tab>      TYPE rsdstabs,
                   <fs_dfies_tab_cat>  TYPE dfies,
                   <fs_field_tab_excl> TYPE rsdsfields,
                   <fs_cond_tab>       TYPE LINE OF rsds_twhere,
                   <fs_cond_tab_tmp>   TYPE LINE OF ty_rsds_twhere,
                   <fs_where_tab>      TYPE LINE OF rsds_where_tab,
                   <fs_where_tab_tmp>  TYPE LINE OF zonttrsdswhere,
                   <fs_where>          TYPE LINE OF zonttrsdswhere,
                   <fs_where_tab_line> TYPE LINE OF rsds_where_tab,
                   <fs_filter>         TYPE zonta_oc_filters,
                   <fs_columns>        TYPE zonta_oc_columns.

    IF NOT gv_anytable IS INITIAL.
      APPEND INITIAL LINE TO table_tab ASSIGNING <fs_table_tab>.
      <fs_table_tab>-prim_tab = gv_anytable.
      IF NOT iv_any IS INITIAL.

        lv_tabname = gv_anytable.

        CALL FUNCTION 'DDIF_FIELDINFO_GET'
          EXPORTING
            tabname        = lv_tabname
          TABLES
            dfies_tab      = gt_dfies_tab_cat
          EXCEPTIONS
            not_found      = 1
            internal_error = 2
            OTHERS         = 3.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

        LOOP AT gt_dfies_tab_cat ASSIGNING <fs_dfies_tab_cat>.

          READ TABLE gt_columns_all WITH KEY tabname         = <fs_dfies_tab_cat>-tabname
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
                                 WHERE tabname EQ <fs_relations>-tabname.
          READ TABLE lt_columns WITH KEY tabname = <fs_dfies_tab_cat>-tabname
                                TRANSPORTING NO FIELDS.
          IF sy-subrc NE 0.
            CONTINUE.
          ENDIF.

          READ TABLE lt_columns WITH KEY tabname         = <fs_dfies_tab_cat>-tabname
                                         fldname         = <fs_dfies_tab_cat>-fieldname
                                         selection_field = abap_true
                                         TRANSPORTING NO FIELDS.
          IF sy-subrc NE 0.
            APPEND INITIAL LINE TO field_tab_excl ASSIGNING <fs_field_tab_excl>.
            <fs_field_tab_excl>-tablename = <fs_dfies_tab_cat>-tabname.
            <fs_field_tab_excl>-fieldname = <fs_dfies_tab_cat>-fieldname.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

    CALL FUNCTION 'FREE_SELECTIONS_INIT'
      EXPORTING
        kind                  = 'T'
      IMPORTING
        selection_id          = selid
      TABLES
        tables_tab            = table_tab
        tabfields_not_display = field_tab_excl
*       fields_not_selected   = field_tab_excl
      EXCEPTIONS
        OTHERS                = 4.
    IF sy-subrc <> 0.
      MESSAGE 'Error in initialization' TYPE 'I' DISPLAY LIKE 'E'.
      LEAVE PROGRAM.
    ENDIF.

    IF <fs_relations> IS ASSIGNED.
      CONCATENATE 'Entity'
                 <fs_relations>-domainv
                 ' - '
                 <fs_relations>-business_proc
                 INTO  lv_title
                 SEPARATED BY space.
    ELSE.
      lv_title =  'Entity - ANY'.
    ENDIF.

    CALL FUNCTION 'FREE_SELECTIONS_DIALOG'
      EXPORTING
        selection_id  = selid
        title         = lv_title
        as_window     = ' '
      IMPORTING
        where_clauses = cond_tab
      TABLES
        fields_tab    = field_tab
      EXCEPTIONS
        OTHERS        = 4.
    IF sy-subrc <> 0.
      MESSAGE 'No free selection created' TYPE 'I'.
      LEAVE PROGRAM.
    ENDIF.

    IF NOT cond_tab IS INITIAL.
      IF NOT gv_anytable IS INITIAL.
        LOOP AT cond_tab ASSIGNING <fs_cond_tab>.
          LOOP AT <fs_cond_tab>-where_tab ASSIGNING <fs_where_tab>.
            SHIFT <fs_where_tab>-line LEFT DELETING LEADING space.
          ENDLOOP.
          r_where = <fs_cond_tab>-where_tab.
        ENDLOOP.
      ELSE.
        LOOP AT cond_tab ASSIGNING <fs_cond_tab>.

          LOOP AT <fs_cond_tab>-where_tab ASSIGNING <fs_where_tab>.
            SHIFT <fs_where_tab>-line LEFT DELETING LEADING space.
          ENDLOOP.

          READ TABLE lt_relations WITH KEY tabname = <fs_cond_tab>-tablename
                                  INTO ls_relations.
          IF sy-subrc EQ 0.
            APPEND INITIAL LINE TO lt_cond_tab ASSIGNING <fs_cond_tab_tmp>.
            <fs_cond_tab_tmp>-tablename = <fs_cond_tab>-tablename .
            <fs_cond_tab_tmp>-where_tab = <fs_cond_tab>-where_tab .

            LOOP AT gt_dfies_tab_cat ASSIGNING <fs_dfies_tab_cat>
                                     WHERE tabname EQ <fs_cond_tab>-tablename.

              lv_sequence = 'T' && ls_relations-sequence.

              lv_join = lv_sequence           &&
                        '~'                   &&
                       <fs_dfies_tab_cat>-fieldname.


              REPLACE ALL OCCURRENCES OF <fs_dfies_tab_cat>-fieldname IN TABLE <fs_cond_tab_tmp>-where_tab WITH lv_join.
            ENDLOOP.
          ENDIF.
        ENDLOOP.

        LOOP AT lt_relations ASSIGNING <fs_relations>.

          READ TABLE lt_cond_tab WITH KEY tablename = <fs_relations>-tabname
                                 INTO ls_cond_tab.

          IF sy-subrc EQ 0.

            LOOP AT ls_cond_tab-where_tab ASSIGNING <fs_where_tab_tmp>.

              APPEND INITIAL LINE TO r_where ASSIGNING <fs_where>.

              <fs_where>-line = <fs_where_tab_tmp>-line.

            ENDLOOP.

            APPEND INITIAL LINE TO r_where ASSIGNING <fs_where>.

            <fs_where>-line = 'AND'.
          ENDIF.

        ENDLOOP.

        IF NOT gt_filters IS INITIAL.
          LOOP AT gt_filters ASSIGNING <fs_filter>.

            READ TABLE lt_relations WITH KEY tabname = <fs_filter>-tabname
                                    INTO ls_relations.

            IF sy-subrc EQ 0.

              lv_sequence = 'T' && ls_relations-sequence.

              REPLACE ALL OCCURRENCES OF <fs_filter>-tabname IN <fs_filter>-where_clause WITH lv_sequence .

              APPEND INITIAL LINE TO r_where ASSIGNING <fs_where>.

              <fs_where>-line = <fs_filter>-where_clause.

              APPEND INITIAL LINE TO r_where ASSIGNING <fs_where>.

              <fs_where>-line = 'AND'.

            ENDIF.

          ENDLOOP.
        ENDIF.

        lv_lines = lines( r_where ).

        DELETE r_where INDEX lv_lines.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD SET_WHERE_ANY.
    DATA selid          TYPE rsdynsel-selid.
    DATA field_tab      TYPE TABLE OF rsdsfields.
    DATA field_tab_excl TYPE TABLE OF rsdsfields.
    DATA table_tab      TYPE TABLE OF rsdstabs.
    DATA cond_tab       TYPE rsds_twhere.
    DATA lv_title       TYPE sy-title.
    DATA: lv_join       TYPE string.
    DATA:  lt_relations TYPE STANDARD TABLE OF zonta_relations,
           lt_columns   TYPE STANDARD TABLE OF ZONTA_OC_COL_ALL,
           ls_relations TYPE zonta_relations,
           ls_cond_tab  TYPE LINE OF rsds_twhere ,
           lv_lines     TYPE sy-tabix,
           lv_sequence  TYPE string.

    FIELD-SYMBOLS: <fs_relations> TYPE zonta_relations,
                   <fs_table_tab> TYPE rsdstabs,
                   <fs_dfies_tab_cat> TYPE dfies,
                   <fs_field_tab_excl> TYPE rsdsfields,
                   <fs_cond_tab> TYPE LINE OF rsds_twhere,
                   <fs_where_tab> TYPE LINE OF  rsds_where_tab,
                   <fs_where> TYPE LINE OF rsds_where_tab,
                   <fs_where_tab_line> TYPE LINE OF rsds_where_tab,
                   <fs_filter> TYPE zonta_oc_filters.

    IF NOT gv_anytable IS INITIAL.
      APPEND INITIAL LINE TO table_tab ASSIGNING <fs_table_tab>.
      <fs_table_tab>-prim_tab = gv_anytable.
    ELSE.
      lt_relations = gt_relations.
      lt_columns   = gt_columns_All.

      DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING sequence.

      SORT lt_columns BY fldname tabname.
*    DELETE ADJACENT DUPLICATES FROM lt_columns COMPARING fldname.


      LOOP AT lt_relations ASSIGNING <fs_relations>.
        APPEND INITIAL LINE TO table_tab ASSIGNING <fs_table_tab>.
        <fs_table_tab>-prim_tab = <fs_relations>-tabname.
      ENDLOOP.

      LOOP AT lt_relations ASSIGNING <fs_relations>.
        LOOP AT gt_dfies_tab_cat ASSIGNING <fs_dfies_tab_cat>
                                 WHERE tabname EQ <fs_relations>-tabname.
*        IF NOT line_exists( lt_columns[ tabname = <fs_dfies_tab_cat>-tabname ] ).
          READ TABLE lt_columns WITH KEY tabname = <fs_dfies_tab_cat>-tabname
                                TRANSPORTING NO FIELDS.
          IF sy-subrc NE 0.
            CONTINUE.
          ENDIF.

*        IF NOT line_exists( lt_columns[ tabname         = <fs_dfies_tab_cat>-tabname
*                                        fldname         = <fs_dfies_tab_cat>-fieldname
*                                        selection_field = abap_true ] ).
          READ TABLE lt_columns WITH KEY tabname         = <fs_dfies_tab_cat>-tabname
                                         fldname         = <fs_dfies_tab_cat>-fieldname
                                         selection_field = abap_true
                                         TRANSPORTING NO FIELDS.
          IF sy-subrc NE 0.
            APPEND INITIAL LINE TO field_tab_excl ASSIGNING <fs_field_tab_excl>.
            <fs_field_tab_excl>-tablename = <fs_dfies_tab_cat>-tabname.
            <fs_field_tab_excl>-fieldname = <fs_dfies_tab_cat>-fieldname.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

    CALL FUNCTION 'FREE_SELECTIONS_INIT'
      EXPORTING
        kind                  = 'T'
      IMPORTING
        selection_id          = selid
      TABLES
        tables_tab            = table_tab
        tabfields_not_display = field_tab_excl
*       fields_not_selected   = field_tab_excl
      EXCEPTIONS
        OTHERS                = 4.
    IF sy-subrc <> 0.
      MESSAGE 'Error in initialization' TYPE 'I' DISPLAY LIKE 'E'.
      LEAVE PROGRAM.
    ENDIF.

    IF <fs_relations> IS ASSIGNED.
      CONCATENATE 'Entity'
                 <fs_relations>-domainv
                 ' - '
                 <fs_relations>-business_proc
                 INTO  lv_title
                 SEPARATED BY space.
    ENDIF.

    CALL FUNCTION 'FREE_SELECTIONS_DIALOG'
      EXPORTING
        selection_id  = selid
        title         = lv_title
        as_window     = ' '
      IMPORTING
        where_clauses = cond_tab
      TABLES
        fields_tab    = field_tab
      EXCEPTIONS
        OTHERS        = 4.
    IF sy-subrc <> 0.
      MESSAGE 'No free selection created' TYPE 'I'.
      LEAVE PROGRAM.
    ENDIF.

    IF NOT cond_tab IS INITIAL.
      IF NOT gv_anytable IS INITIAL.
        LOOP AT cond_tab ASSIGNING <fs_cond_tab>.
          APPEND INITIAL LINE TO r_where ASSIGNING <fs_where>.
          <fs_where>-line = <fs_where_tab>-line.
        ENDLOOP.
      ELSE.
        LOOP AT cond_tab ASSIGNING <fs_cond_tab>.
*        data(ls_relations) = lt_relations[ tabname = <fs_cond_tab>-tablename ].
          LOOP AT <fs_cond_tab>-where_tab ASSIGNING <fs_where_tab>.
            SHIFT <fs_where_tab>-line LEFT DELETING LEADING space.
          ENDLOOP.

          READ TABLE lt_relations WITH KEY tabname = <fs_cond_tab>-tablename
                                  INTO ls_relations.

          LOOP AT gt_dfies_tab_cat ASSIGNING <fs_dfies_tab_cat>
                                   WHERE tabname EQ <fs_cond_tab>-tablename.

            lv_sequence = 'T' && ls_relations-sequence.

            lv_join = lv_sequence           && "ls_relations-sequence &&
                      '~'                   &&
                     <fs_dfies_tab_cat>-fieldname.
            REPLACE ALL OCCURRENCES OF <fs_dfies_tab_cat>-fieldname IN TABLE <fs_cond_tab>-where_tab WITH lv_join.
          ENDLOOP.

        ENDLOOP.

        LOOP AT lt_relations ASSIGNING <fs_relations>.

*        TRY.
*        data(ls_cond_tab) = cond_tab[ tablename = <fs_relations>-tabname ] .

          READ TABLE cond_tab WITH KEY tablename = <fs_relations>-tabname
                              INTO ls_cond_tab.

          IF sy-subrc EQ 0.

            LOOP AT ls_cond_tab-where_tab ASSIGNING <fs_where_tab>.

              APPEND INITIAL LINE TO r_where ASSIGNING <fs_where>.

*            APPEND INITIAL LINE TO <fs_where>-where_tab ASSIGNING <fs_where_tab_line>.
              <fs_where>-line = <fs_where_tab>-line.

            ENDLOOP.

            APPEND INITIAL LINE TO r_where ASSIGNING <fs_where>.

*          APPEND INITIAL LINE TO <fs_where>-where_tab ASSIGNING <fs_where_tab_line>.

            <fs_where>-line = 'AND'.
          ENDIF.
*          CATCH cx_sy_itab_line_not_found.
*        ENDTRY.
        ENDLOOP.

        IF NOT gt_filters IS INITIAL.
          LOOP AT gt_filters ASSIGNING <fs_filter>.
*          TRY.
*              ls_relations = lt_relations[ tabname = <fs_filter>-tabname ].

            READ TABLE lt_relations WITH KEY tabname = <fs_filter>-tabname
                                    INTO ls_relations.

            IF sy-subrc EQ 0.

              lv_sequence = 'T' && ls_relations-sequence.

              REPLACE ALL OCCURRENCES OF <fs_filter>-tabname IN <fs_filter>-where_clause WITH lv_sequence ."ls_relations-sequence.

              APPEND INITIAL LINE TO r_where ASSIGNING <fs_where>.

*            APPEND INITIAL LINE TO <fs_where>-where_tab ASSIGNING <fs_where_tab_line>.

              <fs_where>-line = <fs_filter>-where_clause.

*            <fs_where>-line = <fs_filter>-where_clause.

              APPEND INITIAL LINE TO r_where ASSIGNING <fs_where>.

*            APPEND INITIAL LINE TO <fs_where>-where_tab ASSIGNING <fs_where_tab_line>.

              <fs_where>-line = 'AND'.

*            <fs_where>-line = 'AND'.
            ENDIF.
*            CATCH cx_sy_itab_line_not_found.
*          ENDTRY.
          ENDLOOP.
        ENDIF.

        lv_lines = lines( r_where ).

        DELETE r_where INDEX lv_lines.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD SET_WHERE_NEW.
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
    DATA: lt_relations TYPE STANDARD TABLE OF zonta_relations,
          lt_columns   TYPE STANDARD TABLE OF ZONTA_OC_COL_ALL,
          lt_cond_tab  TYPE ty_rsds_twhere,
          ls_relations TYPE zonta_relations,
          ls_cond_tab  TYPE LINE OF ty_rsds_twhere,
          lv_lines     TYPE sy-tabix,
          lv_sequence  TYPE string,
          lv_tabname   TYPE  ddobjname.

    FIELD-SYMBOLS: <fs_relations>      TYPE zonta_relations,
                   <fs_table_tab>      TYPE rsdstabs,
                   <fs_dfies_tab_cat>  TYPE dfies,
                   <fs_field_tab_excl> TYPE rsdsfields,
                   <fs_cond_tab>       TYPE LINE OF rsds_twhere,
                   <fs_cond_tab_tmp>   TYPE LINE OF ty_rsds_twhere,
                   <fs_where_tab>      TYPE LINE OF rsds_where_tab,
                   <fs_where_tab_tmp>  TYPE LINE OF zonttrsdswhere,
                   <fs_where>          TYPE LINE OF zonttrsdswhere,
                   <fs_where_tab_line> TYPE LINE OF rsds_where_tab,
                   <fs_filter>         TYPE zonta_oc_filters,
                   <fs_columns>        TYPE zonta_oc_columns.

    IF NOT gv_anytable IS INITIAL.
      APPEND INITIAL LINE TO table_tab ASSIGNING <fs_table_tab>.
      <fs_table_tab>-prim_tab = gv_anytable.
      IF NOT iv_any IS INITIAL.

        lv_tabname = gv_anytable.

        CALL FUNCTION 'DDIF_FIELDINFO_GET'
          EXPORTING
            tabname        = lv_tabname
          TABLES
            dfies_tab      = gt_dfies_tab_cat
          EXCEPTIONS
            not_found      = 1
            internal_error = 2
            OTHERS         = 3.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.

        LOOP AT gt_dfies_tab_cat ASSIGNING <fs_dfies_tab_cat>.

          READ TABLE gt_columns_all WITH KEY tabname         = <fs_dfies_tab_cat>-tabname
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
                                 WHERE tabname EQ <fs_relations>-tabname.
          READ TABLE lt_columns WITH KEY tabname = <fs_dfies_tab_cat>-tabname
                                TRANSPORTING NO FIELDS.
          IF sy-subrc NE 0.
            CONTINUE.
          ENDIF.

          READ TABLE lt_columns WITH KEY tabname         = <fs_dfies_tab_cat>-tabname
                                         fldname         = <fs_dfies_tab_cat>-fieldname
                                         selection_field = abap_true
                                         TRANSPORTING NO FIELDS.
          IF sy-subrc NE 0.
            APPEND INITIAL LINE TO field_tab_excl ASSIGNING <fs_field_tab_excl>.
            <fs_field_tab_excl>-tablename = <fs_dfies_tab_cat>-tabname.
            <fs_field_tab_excl>-fieldname = <fs_dfies_tab_cat>-fieldname.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

    CALL FUNCTION 'FREE_SELECTIONS_INIT'
      EXPORTING
        kind                  = 'T'
      IMPORTING
        selection_id          = selid
      TABLES
        tables_tab            = table_tab
        tabfields_not_display = field_tab_excl
*       fields_not_selected   = field_tab_excl
      EXCEPTIONS
        OTHERS                = 4.
    IF sy-subrc <> 0.
      MESSAGE 'Error in initialization' TYPE 'I' DISPLAY LIKE 'E'.
      LEAVE PROGRAM.
    ENDIF.

    IF <fs_relations> IS ASSIGNED.
      CONCATENATE 'Entity'
                 <fs_relations>-domainv
                 ' - '
                 <fs_relations>-business_proc
                 INTO  lv_title
                 SEPARATED BY space.
    ELSE.
      lv_title =  'Entity - ANY'.
    ENDIF.

    CALL FUNCTION 'FREE_SELECTIONS_DIALOG'
      EXPORTING
        selection_id  = selid
        title         = lv_title
        as_window     = ' '
      IMPORTING
        where_clauses = gt_cond_tab
      TABLES
        fields_tab    = field_tab
      EXCEPTIONS
        OTHERS        = 4.
    IF sy-subrc <> 0.
      MESSAGE 'No free selection created' TYPE 'I'.
      LEAVE PROGRAM.
    ENDIF.
  ENDMETHOD.


  METHOD update_slg1_log.
    DATA: li_log_handle TYPE  bal_t_logh,
          ls_log_handle TYPE  balloghndl,
          ls_msg        TYPE  bal_s_msg,
          lv_message    TYPE  string,
          lv_text       TYPE  char128,
          ls_log_extu   TYPE  zonst_oc_log_extu,
          ls_log_ext    TYPE  LINE OF zontt_oc_log_ext.


    DATA:  ls_log     TYPE  bal_s_log.

    CASE gs_oc_obj-log_type.
      WHEN 'S' OR space. " SLG1

        ls_log-object     = 'ZONI_OC'.
        ls_log-subobject  = gv_domainv.
        ls_log-alprog     = sy-cprog.


***Open Log
        CALL FUNCTION 'BAL_LOG_CREATE'
          EXPORTING
            i_s_log                 = ls_log
          IMPORTING
            e_log_handle            = ls_log_handle
          EXCEPTIONS
            log_header_inconsistent = 1
            OTHERS                  = 2.

        IF sy-subrc EQ 0.

***Create message
          LOOP AT it_log_ext INTO ls_log_ext.

            CALL FUNCTION 'FORMAT_MESSAGE' ##FM_SUBRC_OK
              EXPORTING
                id        = ls_log_ext-id
                lang      = sy-langu
                no        = ls_log_ext-number
                v1        = ls_log_ext-message_v1
                v2        = ls_log_ext-message_v2
                v3        = ls_log_ext-message_v3
              IMPORTING
                msg       = lv_message
              EXCEPTIONS
                not_found = 1
                OTHERS    = 2.

            lv_text = lv_message.
            CLEAR ls_msg.
            ls_msg-msgty     = ls_log_ext-type.
            ls_msg-msgid     = ls_log_ext-id.
            ls_msg-msgno     = ls_log_ext-number.
            ls_msg-msgv1     = ls_log_ext-message_v1.
            ls_msg-msgv2     = ls_log_ext-message_v2.
            ls_msg-msgv3     = ls_log_ext-message_v3.
            ls_msg-probclass = 2.

* Add message context
            MOVE-CORRESPONDING ls_log_ext TO ls_log_extu.
            ls_log_extu-comments   = ls_log_ext-message.
            ls_msg-context-value   = ls_log_extu.
            ls_msg-context-tabname = 'ZONST_OC_LOG_EXTU'.


            CALL FUNCTION 'BAL_LOG_MSG_ADD' ##FM_SUBRC_OK
              EXPORTING
                i_log_handle     = ls_log_handle
                i_s_msg          = ls_msg
              EXCEPTIONS
                log_not_found    = 1
                msg_inconsistent = 2
                log_is_full      = 3
                OTHERS           = 4.

            INSERT ls_log_handle INTO TABLE li_log_handle.
          ENDLOOP.


          CALL FUNCTION 'BAL_DB_SAVE'
            EXPORTING
              i_client         = sy-mandt
              i_save_all       = abap_true
              i_t_log_handle   = li_log_handle
            EXCEPTIONS
              log_not_found    = 1
              save_not_allowed = 2
              numbering_error  = 3
              OTHERS           = 4.

          IF sy-subrc EQ 0.
            CLEAR: li_log_handle[].
          ENDIF.
        ENDIF.
      WHEN 'F'.
        me->download_log_file( ).
    ENDCASE.

    REFRESH gt_log_ext.
  ENDMETHOD.


  METHOD VALIDATE_DDIC_ACTIVE.

    DATA: lv_name     TYPE ddobjname,
          lv_gotstate TYPE  ddgotstate.

    lv_name = iv_object.

    DO 10000 TIMES.

      CLEAR lv_gotstate.

      CALL FUNCTION 'DDIF_TABL_GET'
        EXPORTING
          name          = lv_name
          state         = 'M'
        IMPORTING
          gotstate      = lv_gotstate
        EXCEPTIONS
          illegal_input = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      IF lv_gotstate EQ 'A'.
        EXIT.
      ENDIF.
    ENDDO.

  ENDMETHOD.
ENDCLASS.
