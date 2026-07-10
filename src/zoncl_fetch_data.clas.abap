class ZONCL_FETCH_DATA definition
  public
  inheriting from ZONCL_OC_BASE_HANDLER
  final
  create public .

public section.

  methods ADD_JSON_FIELD
    importing
      !IV_FIELDNAME type STRING
      !IV_TABNAME type STRING
      !IV_LENGTH type I .
  methods CONSTRUCTOR .
  methods CREATE_JSON_DDIC_FOR_REG
    importing
      !IV_DOMAINV_SOURCE type ZONDE_DOMAIN
      !IV_BUSINESS_PROC_SOURCE type ZONDE_PROCESS
      !IV_DOMAINV_TARGET type ZONDE_DOMAIN
      !IV_BUSINESS_PROC_TARGET type ZONDE_PROCESS
      !IV_STRUCTURE_SOURCE type DDOBJNAME
      !IV_STRUCTURE_TARGET type DDOBJNAME
    exporting
      !EV_SUBRC type SY-SUBRC .
  methods CREATE_JSON_DDIC
    importing
      !IV_DOMAINV type ZONDE_DOMAIN optional
      !IV_BUSINESS_PROC type ZONDE_PROCESS optional .
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
  methods DELETE_JSON_DDIC
    importing
      !IV_DOMAINV type ZONDE_DOMAIN
      !IV_BUSINESS_PROC type ZONDE_PROCESS
      !IV_DELETE_ENTITY type BOOLEAN optional .
  type-pools RSDS .
  type-pools ABAP .
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
      !IV_ANYTABLE type TABNAME optional
      !IV_ALIAS type BOOLEAN optional
      !IT_ENDPOINTS type TTY_ENDPOINTS optional
      value(IT_WHERE_COND_TAB) type RSDS_TWHERE optional
      !IV_FIELDNAME type BOOLEAN optional
      !IV_TAGDATA type BOOLEAN optional
      !IV_TAGMETADATA type BOOLEAN optional
      !IV_BOTHNAMES type BOOLEAN optional
      !IV_UUID type UUID optional
      !IV_VARIANT type VARIANT optional
      !IV_TM type ABAP_BOOL optional
      value(IT_RANGES_WHERE) type ZONTT_OC_RSPARAMS_TT optional
    exporting
      !EV_SIZET type ZONDE_OC_NUM30
      !EV_RECORDST type ZONDE_OC_NUM30
    exceptions
      NOT_DATA_FOUND .
  methods GET_DATA_TAB .
  methods SEND_OUTPUT_TYPE
    importing
      !I_OBJECT type NAST .
  methods SEND_EVENT_AUTOMATIC
    importing
      !IS_SENDER type SIBFLPORB
      !I_EVENT type SIBFEVENT
      !IV_UUID type UUID optional .
  methods DELETE_JSON_DDIC_OBJECT
    importing
      !IV_OBJNAME type DDOBJNAME
      !IV_OBJTYPE type DDEUTYPE
    exporting
      !EV_SUBRC type SY-SUBRC .
*  methods GET_VARIANT_VALUES
*    importing
*      !IV_VARIANT type VARIANT
*      !IV_DOMAINV type ZONDE_DOMAIN
*      !IV_ENTITY type ZONDE_PROCESS
*    exporting
*      !ET_WHERE type RSDS_TWHERE .
*    METHODS send_json_any_table
*      IMPORTING
*        !iv_tabname   TYPE tabname
*        !iv_update    TYPE boolean
*        !iv_delete    TYPE boolean
*        !it_where     TYPE zonttrsdswhere OPTIONAL
*        !iv_alias     TYPE boolean DEFAULT 'X'
*        !iv_dest      TYPE rfcdest OPTIONAL
*        !iv_fieldname TYPE boolean OPTIONAL
*        !iv_bothnames TYPE boolean OPTIONAL .
*METHODS set_table_custom REDEFINITION.
*  IMPORTING
*    iv_add_tabname TYPE abap_bool OPTIONAL
*  RETURNING
*    VALUE(rt_table) TYPE REF TO data.
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
  methods SEND_JSON_ANY_LTABLE_RAP
    importing
      !IV_TABNAME type TABNAME
      !IV_ALIASTAB type TABNAME optional
      !IV_UPDATE type BOOLEAN
      !IV_DELETE type BOOLEAN
      !IT_TABLES_DATA type ANY TABLE optional
      !IV_ALIAS type BOOLEAN default 'X'
      !IV_DEST type RFCDEST optional
      !IV_FIELDNAME type BOOLEAN optional
      !IV_BOTHNAMES type BOOLEAN optional
      !IV_ENTITY_BUSINESS_PROC type ZONTA_OBJ_OC-BUSINESS_PROC .
  methods SEND_JSON_ANY_INTERNAL_TABLE
    importing
      !IV_TABNAME type TABNAME
      !IV_ALIASTAB type TABNAME optional
      !IV_UPDATE type BOOLEAN
      !IV_DELETE type BOOLEAN
      !IT_TABLES_DATA type ANY TABLE optional
      !IV_ALIAS type BOOLEAN default 'X'
      !IV_DEST type RFCDEST optional
      !IV_FIELDNAME type BOOLEAN optional
      !IV_BOTHNAMES type BOOLEAN optional
      !IV_ENTITY_BUSINESS_PROC type ZONTA_OBJ_OC-BUSINESS_PROC
      !IV_STRUCTURE type TABNAME optional
    exporting
      !EV_SIZE type ZONDE_OC_NUM30
      !EV_RECORDS type ZONDE_OC_NUM30 .
  methods SEND_JSON_ANY_TABLE_PRICE
    importing
      !IV_TABNAME type TABNAME
      !IV_ALIASTAB type TABNAME optional
      !IV_UPDATE type BOOLEAN
      !IV_DELETE type BOOLEAN
      !IT_WHERE type RSDS_WHERE_TAB optional
      !IV_ALIAS type BOOLEAN optional
      !IV_DEST type RFCDEST optional
      !IV_FIELDNAME type BOOLEAN optional
      !IV_BOTHNAMES type BOOLEAN optional
      !IV_KNUMH type KNUMH optional
    exporting
      !R_SIZE type ZONDE_OC_NUM30
      !R_RECORDS type ZONDE_OC_NUM30 .
  methods SEND_JSON_ANY_TABLE_COND
    importing
      !IV_TABNAME type TABNAME
      !IV_ALIASTAB type TABNAME optional
      !IV_UPDATE type BOOLEAN
      !IV_DELETE type BOOLEAN
      !IT_WHERE type ZONTTRSDSWHERE optional
      !IV_ALIAS type BOOLEAN default 'X'
      !IV_DEST type RFCDEST optional
      !IV_FIELDNAME type BOOLEAN optional
      !IV_BOTHNAMES type BOOLEAN optional .
  methods SEND_JSON_ANY_TABLE_CON
    importing
      !IV_TABNAME type TABNAME
      !IV_ALIASTAB type TABNAME optional
      !IV_UPDATE type BOOLEAN
      !IV_DELETE type BOOLEAN
      !IT_WHERE type ZONTTRSDSWHERE optional
      !IV_ALIAS type BOOLEAN default 'X'
      !IV_DEST type RFCDEST optional
      !IV_FIELDNAME type BOOLEAN optional
      !IV_BOTHNAMES type BOOLEAN optional .
  methods SEND_JSON_ANY_TABLE
    importing
      !IV_TABNAME type TABNAME
      !IV_ALIASTAB type TABNAME optional
      !IV_UPDATE type BOOLEAN
      !IV_DELETE type BOOLEAN
      !IT_WHERE type ZONTTRSDSWHERE optional
      !IV_ALIAS type BOOLEAN default 'X'
      !IV_DEST type RFCDEST optional
      !IV_FIELDNAME type BOOLEAN optional
      !IV_BOTHNAMES type BOOLEAN optional .
  methods DEBUG_PROCEDURE
    importing
      !IV_REALT type BOOLEAN optional .

  methods GET_DATA
    redefinition .
protected section.
private section.

  types:
    BEGIN OF ty_delete,
        objname TYPE ddobjname,
        objtype TYPE DDEUTYPE,
      END OF ty_delete .
  types:
    ty_ddic TYPE STANDARD TABLE OF zonta_oc_ddic .

  data:
    gt_delete TYPE STANDARD TABLE OF ty_delete .
  data GT_OBJECTS type ZONTT_E071 .
  data GV_PROG type SYREPID .
  data GV_SLINE type I .
  data GV_MSG1 type STRING .
  data GV_MSG2 type STRING .
  data GV_MSG3 type STRING .
  data GV_MSG4 type STRING .
  data GV_MSG5 type STRING .

  methods CREATE_JSON_DDIC_MAIN .
  methods CREATE_JSON_DDIC_KDOC .
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
  methods CREATE_JSON_DDIC_BODY
    importing
      !IS_RELATIONS type ZONTA_RELATIONS
      !IV_DEF_TAB type BOOLEAN optional
      !IV_DATA_NODE type STRING default 'DATA'
      !IV_MAIN type BOOLEAN optional
      !IS_COLUMNS type ZONTA_OC_COL_ALL optional
    exporting
      !EV_TYPE type STRING .
  methods SET_FIELDS_STRUCTURE
    importing
      !IV_TYPE_NAME type STRING optional
      !IV_TYPE_FIELD type STRING optional
      !IV_TYPE_TABLE type STRING optional
      !IV_TYPE type STRING optional .
  methods ADD_OBJECT_ENTRY
    importing
      !IV_PGMID type PGMID
      !IV_OBJECT type TROBJTYPE
      !IV_OBJECT_NAME type TADIR-OBJ_NAME .
  methods PRINT_ERROR .
  methods GET_FIELDSKEY_CDS
    importing
      !IV_TABNAME type DD03L-TABNAME
    exporting
      !EXT_KEYS_FIELDS type TTY_PRIMARY_KEY_NAMES .
  methods SAVE_LOG
    importing
      !IS_SENDER type SIBFLPORB
      !IV_EVENT type SIBFEVENT
      !IV_STATUS type CHAR02 default 'R'
      !IV_DEST type RFCDEST default 'ONIBEX_KDOCS'
      !IS_ZONTA_RELATIONS type ZONTA_RELATIONS optional
    changing
      !CV_UUID type UUID .
ENDCLASS.



CLASS ZONCL_FETCH_DATA IMPLEMENTATION.


  METHOD add_json_field.

    FIELD-SYMBOLS: <fs_json_map> TYPE dd03p.

    READ TABLE gt_json_map ASSIGNING <fs_json_map> WITH KEY fieldname = iv_fieldname
                                                            tabname   = iv_tabname.
    IF sy-subrc NE 0.
      APPEND INITIAL LINE TO gt_json_map ASSIGNING <fs_json_map>.
      <fs_json_map>-fieldname  = iv_fieldname.
      <fs_json_map>-tabname    = iv_tabname.
      <fs_json_map>-ddlanguage = sy-langu.
      <fs_json_map>-datatype   = 'STRG'.
      <fs_json_map>-inttype    = 'g'.
      <fs_json_map>-intlen     = iv_length.
    ENDIF.

  ENDMETHOD.


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


  METHOD constructor.

    CALL METHOD super->constructor.
    CLEAR: gt_log_ext,
           gt_json,
           gv_json.

    REFRESH: gt_log_ext,
             gt_json.

    CLEAR: gs_log_json_result.

    CLEAR: gv_kdoc,
           gv_table,
           gv_dest,
*           gv_sizet,
*           gv_recordst,
           gv_key_queue,
           gv_entity,
           gv_domainv,
           gv_anytable,
           gt_objects[],
           gv_back_2_process,
           gt_ddic[].
  ENDMETHOD.


  METHOD create_json_ddic.

    DATA: lv_sizet    TYPE zonde_oc_num30,
          lv_recordst TYPE zonde_oc_num30.

    IF NOT iv_domainv IS INITIAL
    AND NOT iv_business_proc IS INITIAL.
      CALL METHOD me->set_globals
        EXPORTING
          iv_domainv = iv_domainv
          iv_entity  = iv_business_proc.

    ENDIF.

    " 1. Prepare metadata
    me->get_relation(
    EXPORTING
        iv_domainv        = gv_domainv
      iv_business_proc  = gv_entity
      iv_kdoc           = abap_true
      iv_table          = abap_false
      iv_ddic           = abap_true
      iv_dest           = gv_dest
      iv_update         = abap_false
      iv_delete         = abap_false
      iv_key_queue      = gv_key_queue
      iv_batch          = abap_false
      it_where          = gt_where
      iv_instid         = gv_instid
      iv_anytable       = gv_anytable
      iv_alias          = gv_alias
      it_endpoints      = gt_endpoints
      it_where_cond_tab = gt_where_cond_tab
      iv_fieldname      = gv_fieldname
      iv_tagdata        = gv_tagdata
      iv_tagmetadata    = gv_tagmetadata
      iv_bothnames      = gv_bothnames
      IMPORTING
          ev_sizet        = lv_sizet
        ev_recordst     = lv_recordst
    ).

    " 2. Set target table
    me->set_table( ).

    " 3. Define field structure
    me->set_fields_structure(  ).

    " 4. Create DDIC object
    me->create_json_ddic_main(  ).
    me->create_json_ddic_kdoc(  ).

    " 5. Log the operation
    me->append_slg1_log(
      iv_tabname    = gv_anytable
      iv_message_v1 = 'DDIC created'
      iv_mestyp     = 'S'
    ).
    me->update_slg1_log( it_log_ext = gt_log_ext ).

  ENDMETHOD.


  METHOD create_json_ddic_add.

    DATA: lt_relations TYPE STANDARD TABLE OF zonta_relations,
          lv_typename  TYPE rollname.

    FIELD-SYMBOLS: <fs_relations>   TYPE zonta_relations,
                   <fs_json_map>    TYPE dd03p,
                   <fs_columns_all> TYPE zonta_oc_col_all.

    " 1. Get unique children of the current relation
    lt_relations = gt_relations.
    SORT lt_relations BY tabname.
    DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING tabname.
    DELETE lt_relations WHERE parent_relation <> is_relations-tabname.
    SORT lt_relations BY sequence.

    LOOP AT lt_relations ASSIGNING <fs_relations>.

* Change 2801
**      " 2. Get type name from columns
**      READ TABLE gt_columns_all WITH KEY
**          tabname       = <fs_relations>-tabname
**          alias_tabname = <fs_relations>-alias_tabname
**          ASSIGNING <fs_columns_all>.
**      IF sy-subrc <> 0.
**        CONTINUE.
**      ENDIF.

      " 3. Generate structure type name
*      CONCATENATE 'ZON' <fs_columns_all>-id_column 'S' 'SEQ'  Change 2801
      CONCATENATE 'ZON' <fs_relations>-id 'S' 'SEQ'
                  <fs_relations>-sequence 'TABLE' gv_messagetype
                  INTO lv_typename.

      " 4. Append mapping entry
      APPEND INITIAL LINE TO gt_json_map ASSIGNING <fs_json_map>.
      <fs_json_map>-tabname    = is_relations-tabname.
      CONCATENATE 'SEQ' <fs_relations>-sequence INTO <fs_json_map>-fieldname.  "= |SEQ{ <fs_relations>-sequence ALPHA = OUT }|.
      <fs_json_map>-ddlanguage = sy-langu.
      <fs_json_map>-rollname   = lv_typename.
      <fs_json_map>-ddtext     = TEXT-002 && gv_messagetype.
      <fs_json_map>-depth      = '00'.
      <fs_json_map>-comptype   = 'N'.

      IF <fs_json_map>-ddtext IS INITIAL.
        <fs_json_map>-ddtext = is_relations-tabname.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD create_json_ddic_body.

    DATA: lv_rc         TYPE sy-subrc,
          lv_obj_name   TYPE tadir-obj_name,
          lv_typename   TYPE rollname,
          lv_name       TYPE ddobjname,
          lv_position   TYPE tabfdpos,
          ls_dd02v      TYPE dd02v,
          ls_dd09l      TYPE dd09l,
          lt_dd03p      TYPE STANDARD TABLE OF dd03p WITH DEFAULT KEY,
          lt_relations  TYPE STANDARD TABLE OF zonta_relations,
          lt_json_map   TYPE STANDARD TABLE OF dd03p,
          lv_message_v1 TYPE string,
          lv_message_v2 TYPE string,
          lv_message_v3 TYPE string,
          lv_object     TYPE string.

    FIELD-SYMBOLS: <ls_dd03p>       TYPE dd03p,
                   <fs_relations>   TYPE zonta_relations,
                   <fs_columns_all> TYPE zonta_oc_col_all.

    lt_relations = gt_relations.
    SORT lt_relations BY levelv tabname.
    DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING tabname.

    lv_obj_name = |ZON{ is_relations-id }S{ is_relations-tabname }{ gv_messagetype }|.
    lv_name = lv_obj_name.

    lt_json_map = gt_json_map.
    DELETE lt_json_map WHERE tabname <> is_relations-tabname.

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
          IF sy-subrc <> 0. CONTINUE. ENDIF.

          IF iv_main = abap_true AND <fs_relations>-alias_tabname IS INITIAL.
            <fs_relations>-alias_tabname = <fs_relations>-tabname.
          ENDIF.

          lv_position = lv_position + 1.

*          lv_typename = |ZON{ <fs_columns_all>-id_column }TT{ COND string( WHEN iv_main = abap_true THEN <fs_relations>-alias_tabname ELSE |SEQ{ <fs_relations>-sequence }| ) }|.
*          lv_typename = |ZON{ <fs_relations>-id }TT{ COND string( WHEN iv_main = abap_true THEN <fs_relations>-alias_tabname ELSE |SEQ{ <fs_relations>-sequence }| ) }|. "change 2801
          IF iv_main = 'X'.
            lv_typename = |ZON{ <fs_relations>-id }TT{ <fs_relations>-alias_tabname }|.
          ELSE.
            lv_typename = |ZON{ <fs_relations>-id }TTSEQ{ <fs_relations>-sequence }|.
          ENDIF.

          APPEND INITIAL LINE TO lt_json_map ASSIGNING <ls_dd03p>.
          <ls_dd03p>-tabname   = lv_obj_name.
          <ls_dd03p>-position  = lv_position.
          <ls_dd03p>-ddlanguage = sy-langu.
          <ls_dd03p>-rollname   = lv_typename.
          <ls_dd03p>-datatype   = 'TTYP'.
          <ls_dd03p>-depth      = '00'.
          <ls_dd03p>-comptype   = 'L'.

          IF iv_main = abap_true.
*                      <ls_dd03p>-fieldname = COND string( WHEN iv_def_tab IS INITIAL THEN iv_data_node && <fs_relations>-alias_tabname ELSE <fs_relations>-alias_tabname ).
            IF  iv_def_tab IS INITIAL.
              <ls_dd03p>-fieldname = iv_data_node && <fs_relations>-alias_tabname.
            ELSE.
              <ls_dd03p>-fieldname = <fs_relations>-alias_tabname.
            ENDIF.
          ELSE.
*            <ls_dd03p>-fieldname = COND string( WHEN iv_def_tab IS INITIAL THEN iv_data_node && 'SEQ' && <fs_relations>-sequence ELSE 'SEQ' && <fs_relations>-sequence ).
            IF  iv_def_tab IS INITIAL.
              <ls_dd03p>-fieldname = iv_data_node && 'SEQ' && <fs_relations>-sequence.
            ELSE.
              <ls_dd03p>-fieldname = 'SEQ' && <fs_relations>-sequence.
            ENDIF.
          ENDIF.
        ENDLOOP.

        lv_object = 'TABL'.

      WHEN OTHERS.
*        lv_typename =  |ZON{ is_relations-id }TT{ cond STRING( WHEN iv_main = abap_true THEN is_relations-alias_tabname ELSE |SEQ{ is_relations-sequence }| ) }| .
        IF iv_main = abap_true.
          lv_typename = |ZON{ is_relations-id }TT{ is_relations-alias_tabname }|.
        ELSE.
          lv_typename = |ZON{ is_relations-id }TTSEQ{ is_relations-sequence }|.
        ENDIF.

        "Change 2801
*        lv_typename = COND string(
*          WHEN is_columns IS INITIAL
*          THEN |ZON{ is_relations-id }TT{ COND string( WHEN iv_main = abap_true THEN is_relations-alias_tabname ELSE |SEQ{ is_relations-sequence }| ) }|
*          ELSE |ZON{ is_columns-id_column }TT{ COND string( WHEN iv_main = abap_true THEN is_relations-alias_tabname ELSE |SEQ{ is_relations-sequence }| ) }|
*        ).

        APPEND INITIAL LINE TO lt_json_map ASSIGNING <ls_dd03p>.
        <ls_dd03p>-tabname    = lv_obj_name.
        <ls_dd03p>-fieldname  = iv_data_node.
        <ls_dd03p>-position   = '0002'.
        <ls_dd03p>-ddlanguage = sy-langu.
        <ls_dd03p>-rollname   = lv_typename.
        <ls_dd03p>-datatype   = 'TTYP'.
        <ls_dd03p>-depth      = '00'.
        <ls_dd03p>-comptype   = 'L'.

        lv_object = 'TTYP'.
    ENDCASE.

* Table header
    ls_dd02v-tabname    = lv_obj_name.
    ls_dd02v-ddlanguage = sy-langu.
    ls_dd02v-tabclass   = 'INTTAB'.
*    ls_dd02v-ddtext     = cond STRING( WHEN text-002 IS INITIAL THEN lv_obj_name ELSE text-002 && gv_messagetype ).
    IF text-002 IS INITIAL.
      ls_dd02v-ddtext     = lv_obj_name.
    ELSE.
      ls_dd02v-ddtext     = text-002 && gv_messagetype.
    ENDIF.
    ls_dd02v-exclass    = '0'.

* Create table
    CALL FUNCTION 'DDIF_TABL_PUT'
      EXPORTING
        name      = lv_name
        dd02v_wa  = ls_dd02v
        dd09l_wa  = ls_dd09l
      TABLES
        dd03p_tab = lt_json_map
      EXCEPTIONS
        OTHERS    = 1.

    IF sy-subrc <> 0.
      lv_message_v3 = |migrate, error from DDIF_TABL_PUT-{ lv_obj_name }|.
    ELSE.
      IF gv_devclass IS INITIAL.
        CALL FUNCTION 'TR_TADIR_INTERFACE'
          EXPORTING
            wi_tadir_pgmid    = 'R3TR'
            wi_tadir_object   = 'TABL'
            wi_tadir_obj_name = lv_obj_name
            wi_set_genflag    = abap_true
            wi_test_modus     = abap_false.
      ELSE.
        CALL FUNCTION 'TR_TADIR_INTERFACE'
          EXPORTING
            wi_tadir_pgmid    = 'R3TR'
            wi_tadir_object   = 'TABL'
            wi_tadir_obj_name = lv_obj_name
            wi_set_genflag    = abap_true
            wi_test_modus     = abap_false
            wi_tadir_devclass = gv_devclass.
      ENDIF.

      lv_object = 'TABL'.  "++FIXDB
      lv_object = lv_object && lv_obj_name.

      me->set_corr_insert( iv_mode = 'I' iv_object = lv_object ).
    ENDIF.

* Activate table
    IF sy-subrc = 0.
      CALL FUNCTION 'DDIF_TABL_ACTIVATE'
        EXPORTING
          name     = lv_name
          auth_chk = abap_false
        IMPORTING
          rc       = lv_rc
        EXCEPTIONS
          OTHERS   = 3.

      IF sy-subrc <> 0 OR lv_rc > 0.
        lv_message_v3 = |migrate, error from DDIF_TABL_ACTIVATE-{ lv_obj_name }|.
      ENDIF.
    ENDIF.

    me->validate_ddic_active( iv_object = lv_obj_name ).
    me->add_object_entry( iv_pgmid = 'R3TR'  iv_object  = 'TABL'  iv_object_name = lv_obj_name ). "++TRKORR DB

* Log result
    lv_message_v1 = 'DDIC'.
    lv_message_v2 = lv_name.
    IF lv_message_v3 IS INITIAL.
      lv_message_v3 = 'activated success'.
    ENDIF.

    me->append_slg1_log(
      iv_tabname    = lv_name
      iv_message_v1 = lv_message_v1
      iv_message_v2 = lv_message_v2
      iv_message_v3 = lv_message_v3
    ).

    ev_type = lv_obj_name.

  ENDMETHOD.


  METHOD create_json_ddic_for_reg.
    DATA: lt_source_fields TYPE STANDARD TABLE OF dd03p,
          lt_target_fields TYPE STANDARD TABLE OF dd03p,
          lt_source_keep   TYPE STANDARD TABLE OF dd03p,
          lt_target_keep   TYPE STANDARD TABLE OF dd03p,
          lt_final_fields  TYPE STANDARD TABLE OF dd03p,
          ls_dd02v         TYPE dd02v,
          lv_found         TYPE abap_bool.

    FIELD-SYMBOLS: <fs_src> LIKE LINE OF lt_source_fields,
                   <fs_tgt> LIKE LINE OF lt_target_fields,
                   <fs_final> LIKE LINE OF lt_final_fields.

    DATA lv_pos TYPE dd03p-position.

    CLEAR gt_log_ext.
    ev_subrc = 0.


* Read SOURCE structure
    CALL FUNCTION 'DDIF_TABL_GET'
      EXPORTING
        name      = iv_structure_source
        state     = 'A'
      IMPORTING
        dd02v_wa  = ls_dd02v
      TABLES
        dd03p_tab = lt_source_fields.

    IF sy-subrc <> 0.
      ev_subrc = sy-subrc.
      RETURN.
    ENDIF.

* Keep source fields UNTIL SEQ*
*    LOOP AT lt_source_fields ASSIGNING field-symbol(<fs_src>).
    LOOP AT lt_source_fields ASSIGNING <fs_src>.

      IF <fs_src>-fieldname CP 'SEQ*'.
        EXIT.
      ENDIF.

      <fs_src>-tabname = iv_structure_target.
      APPEND <fs_src> TO lt_source_keep.

    ENDLOOP.

* Read TARGET structure
    CLEAR ls_dd02v.

    CALL FUNCTION 'DDIF_TABL_GET'
      EXPORTING
        name      = iv_structure_target
        state     = 'A'
      IMPORTING
        dd02v_wa  = ls_dd02v
      TABLES
        dd03p_tab = lt_target_fields.

    IF sy-subrc <> 0.
      ev_subrc = sy-subrc.
      RETURN.
    ENDIF.

* Keep TARGET fields FROM SEQ* onward
    lv_found = abap_false.

*    LOOP AT lt_target_fields ASSIGNING field-symbol(<fs_tgt>).
    LOOP AT lt_target_fields ASSIGNING <fs_tgt>.

      IF <fs_tgt>-fieldname CP 'SEQ*'.
        lv_found = abap_true.
      ENDIF.

      IF lv_found = abap_true.
        APPEND <fs_tgt> TO lt_target_keep.
      ENDIF.

    ENDLOOP.

    IF lt_target_keep IS INITIAL.
      ev_subrc = 4.
      RETURN.
    ENDIF.

* Merge
    lt_final_fields = lt_source_keep.
    APPEND LINES OF lt_target_keep TO lt_final_fields.

* Recalculate POSITION
*    data(lv_pos) = 1.
    lv_pos = 1.
*    LOOP AT lt_final_fields ASSIGNING field-symbol(<fs_final>).
    LOOP AT lt_final_fields ASSIGNING <fs_final>.
      <fs_final>-position = lv_pos.
      lv_pos = lv_pos + 1.
    ENDLOOP.

* Update DDIC
    CALL FUNCTION 'DDIF_TABL_PUT'
      EXPORTING
        name      = iv_structure_target
        dd02v_wa  = ls_dd02v
      TABLES
        dd03p_tab = lt_final_fields.

    IF sy-subrc <> 0.
      ev_subrc = sy-subrc.

      me->append_slg1_log(
        iv_tabname    = iv_structure_target
        iv_message_v1 = 'Error while changing'
        iv_mestyp     = 'E'
      ).

    ENDIF.

* Activate
    IF ev_subrc = 0.
      CALL FUNCTION 'DDIF_TABL_ACTIVATE'
        EXPORTING
          name = iv_structure_target.
      IF sy-subrc NE 0.
        ev_subrc = sy-subrc.
        me->append_slg1_log(
        iv_tabname    = iv_structure_target
        iv_message_v1 = 'Error while activating'
        iv_mestyp     = 'E'
      ).
      ENDIF.
    ENDIF.

    IF ev_subrc = 0.
* Log the operation
      me->append_slg1_log(
        iv_tabname    = iv_structure_target
        iv_message_v1 = 'DDIC updated'
        iv_mestyp     = 'S'
      ).
    ENDIF.
    me->update_slg1_log( it_log_ext = gt_log_ext ).

  ENDMETHOD.


  METHOD create_json_ddic_kdoc.

*
*    DATA: lv_type_name TYPE string,
*          lt_relations TYPE STANDARD TABLE OF zonta_relations,
*          ls_relations TYPE zonta_relations.
*
*    FIELD-SYMBOLS: <fs_columns> TYPE zonta_oc_col_all.
*
*    " 1. Copy and prepare relations
*    lt_relations = gt_relations.
*    SORT lt_relations BY levelv.
*    DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING tabname.
*    READ TABLE lt_relations INDEX 1 INTO ls_relations.
*    IF ls_relations IS INITIAL.
*      RETURN.
*    ENDIF.
*
*
*    " 2. Get matching column metadata (optional, for BODY definition)
*    READ TABLE gt_columns_all WITH KEY
*      tabname       = ls_relations-tabname
*      alias_tabname = ls_relations-alias_tabname
*      ASSIGNING <fs_columns>.
*
*    " 3. Ensure alias is filled
*    IF ls_relations-alias_tabname IS INITIAL.
*      ls_relations-alias_tabname = ls_relations-tabname.
*    ENDIF.
*
*    " 4. Define the BODY structure (dynamic content table)
*    ls_relations-tabname = 'BODY'.
*
*    gv_messagetype = c_kdoc.
*
*    me->create_json_ddic_body(
*      EXPORTING
*        is_relations = ls_relations
*        is_columns   = <fs_columns>
*        iv_def_tab   = abap_true
*      IMPORTING
*        ev_type      = lv_type_name
*    ).
*
*    me->set_fields_structure(
*      EXPORTING
*        iv_type_name  = lv_type_name
*        iv_type       = 'STRU'
*        iv_type_field = 'BODY'
*        iv_type_table = 'CONNECTDET'
*    ).
*
*    " 5. Define the CONNECTDET wrapper structure
*    ls_relations-tabname       = 'CONNECTDET'.
*    ls_relations-alias_tabname = 'CONNECTDET'.
*
*    me->create_json_ddic_structure(
*      EXPORTING
*        is_relations = ls_relations
*        iv_main      = abap_true
*        iv_header    = abap_true
*      IMPORTING
*        ev_type      = lv_type_name
*    ).
*
*    me->set_fields_structure(
*      EXPORTING
*        iv_type_name  = lv_type_name
*        iv_type       = 'STRU'
*        iv_type_field = 'ONECONNECT'
*        iv_type_table = 'CONNECT'
*    ).
*
*    " 6. Define the root CONNECT structure
*    ls_relations-tabname       = 'CONNECT'.
*    ls_relations-alias_tabname = 'CONNECT'.
*
*    me->create_json_ddic_structure(
*      EXPORTING
*        is_relations = ls_relations
*        iv_main      = abap_true
*        iv_header    = abap_true
*      IMPORTING
*        ev_type      = lv_type_name
*    ).
*

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
    IF NOT ls_relations IS INITIAL AND <fs_columns> IS ASSIGNED.
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
*

    DATA: lv_type_name TYPE string,
          lt_relations TYPE STANDARD TABLE OF zonta_relations,
          ls_relations TYPE zonta_relations.

    FIELD-SYMBOLS: <fs_relations> TYPE zonta_relations.

    lt_relations = me->gt_relations.
    SORT lt_relations BY levelv.
    DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING tabname.

    " --- Phase 1: Create base structures and types
    LOOP AT lt_relations ASSIGNING <fs_relations>.
      me->create_json_ddic_structure(    is_relations   = <fs_relations>
                                         iv_event       = gs_oc_obj-eventid
                                         iv_tagmetadata = gs_oc_obj-metadata ).
      me->create_json_ddic_type_table(   is_relations   = <fs_relations> ).
    ENDLOOP.

    " --- Phase 2: Prepare deep structures
    LOOP AT lt_relations ASSIGNING <fs_relations>.
      me->create_json_ddic_structure(    is_relations = <fs_relations>
                                         iv_def_tab   = abap_true  ).
      me->create_json_ddic_add(          is_relations = <fs_relations>  ).
    ENDLOOP.

    " --- Phase 3: Create deep structure copies again
    LOOP AT lt_relations ASSIGNING <fs_relations>.
      me->create_json_ddic_structure(   is_relations   = <fs_relations>
                                        iv_event       = gs_oc_obj-eventid
                                        iv_tagmetadata = gs_oc_obj-metadata  ).
      me->create_json_ddic_type_table(    is_relations = <fs_relations>  ).
    ENDLOOP.

    " --- Final Metadata Structures: PROPERTIES and METADATADET
    READ TABLE lt_relations INDEX 1 INTO ls_relations.
    IF sy-subrc = 0.
      ls_relations-tabname       = 'PROPERTIES'.
      ls_relations-alias_tabname = 'PROPERTIES'.

      me->create_json_ddic_structure(
        EXPORTING
          is_relations = ls_relations
          iv_main      = abap_true
          iv_header    = abap_true
        IMPORTING
          ev_type      = lv_type_name  ).

      me->set_fields_structure(
        EXPORTING
          iv_type_name  = lv_type_name
          iv_type       = 'STRU'
          iv_type_field = 'PROPERTIES'
          iv_type_table = 'CONNECTDET' ).

      ls_relations-tabname       = 'METADATADET'.
      ls_relations-alias_tabname = 'METADATADET'.

      me->create_json_ddic_structure(
        is_relations = ls_relations
        iv_main      = abap_true
        iv_header    = abap_true
      ).

      me->create_json_ddic_type_table(
        is_relations = ls_relations
        iv_main      = abap_true
        iv_header    = abap_true
      ).


      " --- Final METADATA structure and type table
      ls_relations-tabname       = 'METADATA'.
      ls_relations-alias_tabname = 'METADATADET'.

      me->create_json_ddic_body(  is_relations = ls_relations
                                  iv_def_tab   = abap_true
                                  iv_data_node = 'METADATA'
                                  iv_main      = abap_true   ).

      ls_relations-alias_tabname = 'METADATA'.

      me->create_json_ddic_type_table(
        EXPORTING
          is_relations = ls_relations
          iv_main      = abap_true
          iv_header    = abap_true
        IMPORTING
          ev_type      = lv_type_name   ).

      me->set_fields_structure(
        EXPORTING
          iv_type_name  = lv_type_name
          iv_type       = 'TTYP'
          iv_type_field = 'METADATA'
          iv_type_table = 'CONNECTDET'   ).
    ENDIF.



  ENDMETHOD.


  METHOD create_json_ddic_structure.

    DATA: lv_obj_name       TYPE tadir-obj_name,
          lv_name           TYPE ddobjname,
          lv_message2       TYPE string,
          lv_tabname        TYPE tabname,
          lv_typename       TYPE rollname,
          lv_position       TYPE tabfdpos,
          lv_id             TYPE string,
          lv_object         TYPE string,
          lv_message_v3     TYPE string,
          lv_rc             TYPE sy-subrc,
          ls_dd02v          TYPE dd02v,
          ls_dd09l          TYPE dd09l,
          lt_dd03p          TYPE STANDARD TABLE OF dd03p,
          lt_json_map       TYPE STANDARD TABLE OF dd03p,
          ls_json_tmp       TYPE dd03p,
          ls_conv           LIKE LINE OF gt_converted,
          lt_json_map_event TYPE STANDARD TABLE OF dd03p,
          lt_dfies_tmp      TYPE STANDARD TABLE OF dfies,
          ls_dfies_tmp      TYPE dfies.

    FIELD-SYMBOLS: <fs_json_map>      TYPE dd03p,
                   <fs_json_tmp>      TYPE dd03p,
                   <fs_columns_all>   TYPE zonta_oc_col_all,
                   <fs_json_position> TYPE dd03p.

*
*   SORT gt_json_map by tabname fieldname position.
*   DELETE ADJACENT DUPLICATES FROM gt_json_map comparing tabname fieldname position.

* 1. Determine ID   - Change 2801
*    IF iv_header = abap_true.
    lv_id = is_relations-id.
*    ELSE.
*      READ TABLE gt_columns_all WITH KEY
*           tabname        = is_relations-tabname
*           alias_tabname = is_relations-alias_tabname
*           ASSIGNING <fs_columns_all>.
*      IF sy-subrc = 0.
*        lv_id = <fs_columns_all>-id_column.
*      ENDIF.
*    ENDIF.

* 2. Compose name manually (avoid string templates)
    CLEAR lv_obj_name.
    IF iv_main = abap_true.
      IF iv_def_tab IS INITIAL.
        CONCATENATE 'ZON' lv_id 'S' is_relations-alias_tabname gv_messagetype INTO lv_obj_name.
      ELSE.
        CONCATENATE 'ZON' lv_id 'S' is_relations-alias_tabname 'TABLE' gv_messagetype INTO lv_obj_name.
      ENDIF.
    ELSE.
      IF iv_def_tab IS INITIAL.
        CONCATENATE 'ZON' lv_id 'SSEQ' is_relations-sequence gv_messagetype INTO lv_obj_name.
      ELSE.
        CONCATENATE 'ZON' lv_id 'SSEQ' is_relations-sequence 'TABLE' gv_messagetype INTO lv_obj_name.
      ENDIF.
    ENDIF.

    lv_name = lv_obj_name.

* 3. Field list
    CLEAR lv_position.
    IF iv_def_tab IS INITIAL.
      lt_json_map = gt_json_map.
      DELETE lt_json_map WHERE tabname <> is_relations-tabname.

      LOOP AT lt_json_map ASSIGNING <fs_json_position>.
        lv_position = lv_position + 1.
        <fs_json_position>-tabname  = lv_obj_name.
        <fs_json_position>-position = lv_position.
      ENDLOOP.

*      IF gs_oc_obj-eventid = abap_true OR gs_oc_obj-metadata = abap_true.
      IF iv_event EQ abap_true OR iv_tagmetadata EQ abap_true.

        lt_json_map_event = gt_json_map.
        DELETE lt_json_map_event WHERE tabname <> 'ZONST_OC_EVENTID'.

        LOOP AT lt_json_map_event ASSIGNING <fs_json_position>.
          lv_position = lv_position + 1.
          APPEND INITIAL LINE TO lt_json_map ASSIGNING <fs_json_map>.
          MOVE-CORRESPONDING <fs_json_position> TO <fs_json_map>.
          <fs_json_map>-tabname  = lv_obj_name.
          <fs_json_map>-position = lv_position.
        ENDLOOP.
      ENDIF.

    ELSE.
      APPEND INITIAL LINE TO lt_json_map ASSIGNING <fs_json_map>.
      <fs_json_map>-tabname   = lv_obj_name.
      <fs_json_map>-fieldname = 'TABLE'.
      <fs_json_map>-position  = '0001'.
      <fs_json_map>-datatype  = 'CHAR'.
      <fs_json_map>-leng      = '000060'.

      READ TABLE gt_columns_all WITH KEY
           tabname        = is_relations-tabname
           alias_tabname = is_relations-alias_tabname
           ASSIGNING <fs_columns_all>.

      IF sy-subrc = 0.
*        CONCATENATE 'ZON' <fs_columns_all>-id_column 'TTSEQ' is_relations-sequence gv_messagetype  Change 2801
        CONCATENATE 'ZON' is_relations-id 'TTSEQ' is_relations-sequence gv_messagetype
                   INTO lv_typename.
      ENDIF.

      APPEND INITIAL LINE TO lt_json_map ASSIGNING <fs_json_map>.
      <fs_json_map>-tabname     = lv_obj_name.
      <fs_json_map>-fieldname   = iv_data_node.
      <fs_json_map>-position    = '0002'.
      <fs_json_map>-ddlanguage  = sy-langu.
      <fs_json_map>-rollname    = lv_typename.
      <fs_json_map>-datatype    = 'TTYP'.
      <fs_json_map>-depth       = '00'.
      <fs_json_map>-comptype    = 'L'.
    ENDIF.

* 4. Header metadata
    CLEAR ls_dd02v.
    ls_dd02v-tabname    = lv_obj_name.
    ls_dd02v-ddlanguage = sy-langu.
    ls_dd02v-tabclass   = 'INTTAB'.
    IF text-002 IS INITIAL.
      ls_dd02v-ddtext = lv_obj_name.
    ELSE.
      CONCATENATE text-002 gv_messagetype INTO ls_dd02v-ddtext.
    ENDIF.
    ls_dd02v-exclass = '0'.

* Validate ref table and ref fied.
    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname   = is_relations-tabname
      TABLES
        dfies_tab = lt_dfies_tmp
      EXCEPTIONS
        OTHERS    = 3.


***SE CAMBIA LONGITUD DE 27 A 25 FRG VAREX 11.06.26
    DATA: lv_fieldname_short TYPE char27,
          lv_fieldname27 TYPE char27.

* Fill REFTABLE and REFFIELD if needed
    DELETE lt_dfies_tmp WHERE reffield IS INITIAL.
    LOOP AT lt_dfies_tmp INTO ls_dfies_tmp WHERE reffield IS NOT INITIAL .
      IF strlen( ls_dfies_tmp-fieldname ) > 27.
        lv_fieldname_short = ls_dfies_tmp-fieldname+0(27).
      ELSE.
        lv_fieldname_short = ls_dfies_tmp-fieldname.
      ENDIF.

      READ TABLE lt_json_map ASSIGNING <fs_json_map> WITH KEY fieldname = lv_fieldname_short."ls_dfies_tmp-fieldname.
      IF sy-subrc = 0.
*        IF <fs_json_map>-reftable IS INITIAL.
        IF ls_dfies_tmp-reftable NE is_relations-tabname.
          <fs_json_map>-reftable = ls_dfies_tmp-reftable.
        ELSE.
          <fs_json_map>-reftable = lv_name. "ls_dfies_tmp-reftable.
        ENDIF.
        IF <fs_json_map>-reffield IS INITIAL.
          <fs_json_map>-reffield = ls_dfies_tmp-reffield.

*          data(lv_fieldname27) = <fs_json_map>-reffield+0(27).
          lv_fieldname27 = <fs_json_map>-reffield+0(27).
* Check reffield is ok, and not in converted table
          READ TABLE gt_converted INTO ls_conv WITH KEY fldname1 = lv_fieldname27.
          IF sy-subrc = 0.
            <fs_json_map>-reffield  = lv_fieldname27.
          ENDIF.
        ELSE.

          lv_fieldname27 = <fs_json_map>-reffield+0(27).
* Check reffield is ok, and not in converted table
          READ TABLE gt_converted INTO ls_conv WITH KEY fldname1 = lv_fieldname27.
          IF sy-subrc = 0.
            <fs_json_map>-reffield  = lv_fieldname27.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.


*    LOOP AT lt_json_map ASSIGNING <fs_json_map> WHERE reffield IS NOT INITIAL
*                                                  AND reftable IS INITIAL.
*      lv_fieldname27 = <fs_json_map>-reffield+0(27).
** Check reffield is ok, and not in converted table
*      READ TABLE gt_converted INTO ls_conv WITH KEY fldname1 = lv_fieldname27.
*      IF sy-subrc = 0.
*        <fs_json_map>-reffield  = lv_fieldname27.
*      ENDIF.
*
** IF the reffield exists, add the table as reftable
*      READ TABLE lt_json_map INTO ls_json_tmp WITH KEY fieldname = <fs_json_map>-reffield.
*      IF sy-subrc = 0.
*        <fs_json_map>-reftable = lv_name.
*      ELSE.
*        READ TABLE lt_dfies_tmp INTO ls_dfies_tmp WITH KEY fieldname = <fs_json_map>-reffield.
*        APPEND INITIAL LINE TO lt_json_map ASSIGNING <fs_json_tmp>.
*        MOVE-CORRESPONDING ls_dfies_tmp TO <fs_json_tmp>.
*        <fs_json_tmp>-tabname = lv_name.
*        <fs_json_map>-reftable = lv_name.
*      ENDIF.
*    ENDLOOP.

* 5. Create structure
    CALL FUNCTION 'DDIF_TABL_PUT'
      EXPORTING
        name      = lv_name
        dd02v_wa  = ls_dd02v
        dd09l_wa  = ls_dd09l
      TABLES
        dd03p_tab = lt_json_map
      EXCEPTIONS
        OTHERS    = 1.
    IF sy-subrc <> 0.
      lv_message_v3 = 'DDIF_TABL_PUT-' && lv_obj_name.
      lv_rc = 1.
    ENDIF.

* 6. Register in TADIR
    IF lv_rc = 0.
      IF gv_devclass IS INITIAL.
        CALL FUNCTION 'TR_TADIR_INTERFACE'
          EXPORTING
            wi_tadir_pgmid    = 'R3TR'
            wi_tadir_object   = 'TABL'
            wi_tadir_obj_name = lv_obj_name
            wi_set_genflag    = abap_true
            wi_test_modus     = abap_false
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
        lv_message_v3 = 'TR_TADIR_INTERFACE-' && lv_obj_name.
        lv_rc = 1.
      ENDIF.
    ENDIF.

* 7. Activate structure
    IF lv_rc = 0.
      CALL FUNCTION 'DDIF_TABL_ACTIVATE'
        EXPORTING
          name     = lv_name
          auth_chk = abap_false
        IMPORTING
          rc       = lv_rc
        EXCEPTIONS
          OTHERS   = 3.
      IF sy-subrc <> 0 OR lv_rc > 1.
        lv_message_v3 = 'ACTIVATE-' && lv_obj_name.
        lv_rc = 1.
      ENDIF.
    ENDIF.

    "8. Validation and log
    me->validate_ddic_active( EXPORTING iv_object = lv_obj_name CHANGING cv_subrc = lv_rc ).
    me->add_object_entry( iv_pgmid = 'R3TR'  iv_object  = 'TABL'  iv_object_name = lv_obj_name ). "++TRKORR DB

    IF lv_message_v3 IS INITIAL.
      lv_message_v3 = 'activated success'.
    ENDIF.

    DATA lv_mestyp TYPE symsgty.

    lv_tabname = lv_obj_name.
    lv_message2 = lv_name.
    IF lv_rc EQ 0.
      lv_mestyp = 'S'.
    ELSE.
      lv_mestyp = 'E'.
    ENDIF.
    CALL METHOD me->append_slg1_log
      EXPORTING
        iv_tabname    = lv_tabname
        iv_message_v1 = 'DDIC'
        iv_message_v2 = lv_message2
        iv_message_v3 = lv_message_v3
        iv_mestyp     = lv_mestyp.
*        iv_mestyp     = cond
*        #
*                        ( WHEN lv_rc = 0 THEN 'S' ELSE 'E' ).

    ev_type = lv_obj_name.

  ENDMETHOD.


  METHOD create_json_ddic_type_table.

    "----------------------------------------------------------------------
    " Local variable declarations
    "----------------------------------------------------------------------
    DATA: dd40v_wa      TYPE dd40v,
          lv_obj_name   TYPE tadir-obj_name,
          lv_name       TYPE ddobjname,
          lv_id         TYPE string,
          lv_rc         TYPE sy-subrc,
          lv_message_v1 TYPE string,
          lv_message_v2 TYPE string,
          lv_message_v3 TYPE string,
          lv_typename   TYPE rollname,
          lv_object     TYPE string.

    FIELD-SYMBOLS: <fs_columns_all> TYPE zonta_oc_col_all.

    "----------------------------------------------------------------------
    " Step 1: Determine ID based on header flag
    "----------------------------------------------------------------------
*    IF iv_header EQ abap_true.  Changes 2801
      lv_id = is_relations-id.
*    ELSE.
*      READ TABLE gt_columns_all
*        WITH KEY tabname       = is_relations-tabname
*                 alias_tabname = is_relations-alias_tabname   ASSIGNING <fs_columns_all>.
*      IF <fs_columns_all> IS ASSIGNED.
*        lv_id = <fs_columns_all>-id_column.
*      ENDIF.
*    ENDIF.

    "----------------------------------------------------------------------
    " Step 2: Compose name of the DDIC table type
    "----------------------------------------------------------------------
    IF iv_main EQ abap_true.
      lv_typename = 'ZON' && lv_id && 'TT' && is_relations-alias_tabname && gv_messagetype.
    ELSE.
      lv_typename = 'ZON' && lv_id && 'TT' && 'SEQ' && is_relations-sequence && gv_messagetype.
    ENDIF.

    dd40v_wa-typename   = lv_typename.
    dd40v_wa-ddlanguage = sy-langu.

    "----------------------------------------------------------------------
    " Step 3: Compose name of the structure used as row type
    "----------------------------------------------------------------------
    IF iv_main EQ abap_true.
      lv_typename = 'ZON' && lv_id && 'S' && is_relations-alias_tabname && gv_messagetype.
    ELSE.
      lv_typename = 'ZON' && lv_id && 'S' && 'SEQ' && is_relations-sequence && gv_messagetype.
    ENDIF.

    dd40v_wa-rowtype    = lv_typename.
    dd40v_wa-rowkind    = 'S'.
    dd40v_wa-accessmode = 'T'.
    dd40v_wa-keydef     = 'D'.
    dd40v_wa-keykind    = 'N'.
    dd40v_wa-ddtext     = TEXT-001 && gv_messagetype.

    " Fallback to typename if no text defined
    IF dd40v_wa-ddtext IS INITIAL.
      dd40v_wa-ddtext = lv_typename.
    ENDIF.

    " Store the generated name for further use
    lv_obj_name = dd40v_wa-typename.
    lv_name     = lv_obj_name.

    "----------------------------------------------------------------------
    " Step 4: Create the DDIC table type in the dictionary
    "----------------------------------------------------------------------
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
      lv_message_v3 = 'DDIF_TTYP_PUT-' && lv_obj_name.
    ENDIF.

    "----------------------------------------------------------------------
    " Step 5: Register the object in TADIR
    "----------------------------------------------------------------------
    IF sy-subrc EQ 0.
      IF gv_devclass IS INITIAL.
        CALL FUNCTION 'TR_TADIR_INTERFACE'
          EXPORTING
            wi_tadir_pgmid    = 'R3TR'
            wi_tadir_object   = 'TTYP'
            wi_tadir_obj_name = lv_obj_name
            wi_set_genflag    = abap_true
            wi_test_modus     = abap_false
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
        lv_message_v3 = 'TR_TADIR_INTERFACE-' && lv_obj_name.
      ENDIF.

      " Save object for correction registration
      lv_object = 'TTYP' && lv_obj_name.

      me->set_corr_insert(
        iv_mode   = 'I'
        iv_object = lv_object ).
    ENDIF.

    "----------------------------------------------------------------------
    " Step 6: Activate the new table type
    "----------------------------------------------------------------------
    IF sy-subrc EQ 0.
      CALL FUNCTION 'DDIF_TTYP_ACTIVATE'
        EXPORTING
          name        = lv_name
        IMPORTING
          rc          = lv_rc
        EXCEPTIONS
          not_found   = 1
          put_failure = 2
          OTHERS      = 3.

      IF sy-subrc <> 0 OR lv_rc <> 0.
        IF lv_rc <> 4.
          lv_message_v3 = 'migrate, error from DDIF_TABL_ACTIVATE-' && lv_obj_name.
        ENDIF.
      ENDIF.
    ENDIF.

    "----------------------------------------------------------------------
    " Step 7: Validate and register object in internal tracking
    "----------------------------------------------------------------------
    me->validate_ddic_active( iv_object = lv_obj_name ).

    me->add_object_entry(
      iv_pgmid        = 'R3TR'
      iv_object       = 'TTYP'
      iv_object_name  = lv_obj_name ).

    "----------------------------------------------------------------------
    " Step 8: Log creation and activation
    "----------------------------------------------------------------------
    lv_message_v1 = 'DDIC'.
    lv_message_v2 = lv_name.

    IF lv_message_v3 IS INITIAL.
      lv_message_v3 = 'activated success'.
    ENDIF.

    CALL METHOD me->append_slg1_log
      EXPORTING
        iv_tabname    = lv_name
        iv_message_v1 = lv_message_v1
        iv_message_v2 = lv_message_v2
        iv_message_v3 = lv_message_v3.

    "----------------------------------------------------------------------
    " Step 9: Output the type name
    "----------------------------------------------------------------------
    ev_type = lv_obj_name.





***********+ OK
*  METHOD create_json_ddic_type_table.
*    DATA: dd40v_wa      TYPE  dd40v,
*          lv_obj_name   TYPE tadir-obj_name,
*          lv_name       TYPE  ddobjname,
*          lv_id         TYPE string,
*          lv_rc         TYPE sy-subrc,
*          lv_message_v1 TYPE string, "symsgv,
*          lv_message_v2 TYPE string, "symsgv,
*          lv_message_v3 TYPE string, "symsgv,
*          lv_typename   TYPE rollname,
*          lv_object     TYPE string.
*
*    FIELD-SYMBOLS: <fs_columns_all> TYPE zonta_oc_col_all.
*
*
*    IF iv_header EQ abap_true.
*      lv_id = is_relations-id.
*    ELSE.
*      READ TABLE gt_columns_all WITH KEY tabname       = is_relations-tabname
*                                         alias_tabname = is_relations-alias_tabname
*                                         ASSIGNING <fs_columns_all>.
*      lv_id = <fs_columns_all>-id_column .
*    ENDIF.
*
*    IF iv_main EQ abap_true.
*      lv_typename = 'ZON' && lv_id && 'TT' && is_relations-alias_tabname && gv_messagetype.
*    ELSE.
*      lv_typename = 'ZON' && lv_id && 'TT' && 'SEQ' && is_relations-sequence && gv_messagetype.
*    ENDIF.
*
*    dd40v_wa-typename    =  lv_typename.
*    dd40v_wa-ddlanguage  =  sy-langu.
*
*    IF iv_main EQ abap_true.
*      lv_typename = 'ZON' && lv_id && 'S' && is_relations-alias_tabname && gv_messagetype.
*    ELSE.
*      lv_typename = 'ZON' && lv_id && 'S' && 'SEQ' && is_relations-sequence && gv_messagetype.
*    ENDIF.
*
*
*    dd40v_wa-rowtype     =  lv_typename.
*    dd40v_wa-rowkind     =  'S'.
*    dd40v_wa-accessmode  =  'T'.
*    dd40v_wa-keydef      =  'D'.
*    dd40v_wa-keykind     =  'N'.
*    dd40v_wa-ddtext      = TEXT-001 && gv_messagetype. "is_relations-description_table.
*
**CECHAVARRIA 12/06/2025
*    IF dd40v_wa-ddtext IS INITIAL.
*      dd40v_wa-ddtext = lv_typename.
*    ENDIF.
**CECHAVARRIA 12/06/2025
*
*    lv_obj_name = dd40v_wa-typename.
*
*    lv_name = lv_obj_name.
*
*    CALL FUNCTION 'DDIF_TTYP_PUT'
*      EXPORTING
*        name              = lv_name
*        dd40v_wa          = dd40v_wa
*      EXCEPTIONS
*        ttyp_not_found    = 1
*        name_inconsistent = 2
*        ttyp_inconsistent = 3
*        put_failure       = 4
*        put_refused       = 5
*        OTHERS            = 6.
*    IF sy-subrc <> 0.
**      WRITE:/ 'DDIF_TTYP_PUT',  lv_obj_name.
**      RETURN.
*      lv_message_v3 = 'DDIF_TTYP_PUT-' && lv_obj_name.
*    ENDIF.
*
*    IF sy-subrc EQ 0.
*      IF gv_devclass IS INITIAL.
*        CALL FUNCTION 'TR_TADIR_INTERFACE'
*          EXPORTING
*            wi_tadir_pgmid    = 'R3TR'
*            wi_tadir_object   = 'TTYP'
*            wi_tadir_obj_name = lv_obj_name
*            wi_set_genflag    = abap_true
*            wi_test_modus     = abap_false
**           wi_tadir_devclass = '$TMP'
*          EXCEPTIONS
*            OTHERS            = 1.
*      ELSE.
*        CALL FUNCTION 'TR_TADIR_INTERFACE'
*          EXPORTING
*            wi_tadir_pgmid    = 'R3TR'
*            wi_tadir_object   = 'TTYP'
*            wi_tadir_obj_name = lv_obj_name
*            wi_set_genflag    = abap_true
*            wi_test_modus     = abap_false
*            wi_tadir_devclass = gv_devclass
*          EXCEPTIONS
*            OTHERS            = 1.
*      ENDIF.
*      IF sy-subrc <> 0.
**      WRITE:/ 'zcx_abapgit_exception=>raise_t100( )' , lv_obj_name.
**      RETURN.
*
*        lv_message_v3 = 'TR_TADIR_INTERFACE-' && lv_obj_name.
*
*      ENDIF.
*
*      lv_object = 'TTYP' && lv_obj_name.
*
*      me->set_corr_insert( iv_mode   = 'I'
*                           iv_object = lv_object ).
*
*    ENDIF.
*
*    IF sy-subrc EQ 0.
*      CALL FUNCTION 'DDIF_TTYP_ACTIVATE'
*        EXPORTING
*          name        = lv_name
**         PRID        = -1
*        IMPORTING
*          rc          = lv_rc
*        EXCEPTIONS
*          not_found   = 1
*          put_failure = 2
*          OTHERS      = 3.
*
*      IF sy-subrc <> 0 OR lv_rc <> 0.
*        IF lv_rc <> 4.
**        WRITE :/ 'migrate, error from DDIF_TABL_ACTIVATE ' , lv_obj_name.
**        RETURN.
*          lv_message_v3 = 'migrate, error from DDIF_TABL_ACTIVATE-' && lv_obj_name.
*
*        ENDIF.
*      ENDIF.
*    ENDIF.
*
*    me->validate_ddic_active( iv_object = lv_obj_name ).
*    me->add_object_entry( iv_pgmid = 'R3TR'  iv_object  = 'TTYP'  iv_object_name = lv_obj_name ). "++TRKORR DB
*
*
**** Generate log
*    lv_message_v1 = 'DDIC'.
*    lv_message_v2 = lv_name.
*    IF lv_message_v3 IS INITIAL.
*      lv_message_v3 = 'activated success'.
*    ENDIF.
*
*
*    CALL METHOD me->append_slg1_log
*      EXPORTING
*        iv_tabname    = lv_name
**       iv_key        =
*        iv_message_v1 = lv_message_v1
*        iv_message_v2 = lv_message_v2
*        iv_message_v3 = lv_message_v3.
*
*
*    ev_type = lv_obj_name.
*  ENDMETHOD.
*
*
*
*



**********************VIEJO
*  METHOD create_json_ddic_type_table.
*
*    DATA: dd40v_wa      TYPE dd40v,
*          lv_obj_name   TYPE tadir-obj_name,
*          lv_name       TYPE ddobjname,
*          lv_id         TYPE string,
*          lv_rc         TYPE sy-subrc,
*          lv_message_v1 TYPE string, "symsgv,
*          lv_message_v2 TYPE string, "symsgv,
*          lv_message_v3 TYPE string,  "symsgv,
*          lv_typename   TYPE rollname,
*          lv_object     TYPE string.
*
*    FIELD-SYMBOLS: <fs_columns_all> TYPE zonta_oc_col_all.
*
*    " Determine identifier based on header flag
*    IF iv_header = abap_true.
*      lv_id = is_relations-id.
*    ELSE.
*      READ TABLE gt_columns_all WITH KEY
*        tabname       = is_relations-tabname
*        alias_tabname = is_relations-alias_tabname
*        ASSIGNING <fs_columns_all>.
*      IF sy-subrc = 0.
*        lv_id = <fs_columns_all>-id_column.
*      ENDIF.
*    ENDIF.
*
*    " Compose type name for table type
*    IF iv_main = abap_true.
*      CONCATENATE 'ZON' lv_id 'TT' is_relations-alias_tabname gv_messagetype
*        INTO lv_typename.
*    ELSE.
*      CONCATENATE 'ZON' lv_id 'TT' 'SEQ' is_relations-sequence gv_messagetype
*        INTO lv_typename.
*    ENDIF.
*
*    dd40v_wa-typename   = lv_typename.
*    dd40v_wa-ddlanguage = sy-langu.
*
*    " Compose row structure name
*    IF iv_main = abap_true.
*      CONCATENATE 'ZON' lv_id 'S' is_relations-alias_tabname gv_messagetype
*        INTO lv_obj_name.
*    ELSE.
*      CONCATENATE 'ZON' lv_id 'SSEQ' is_relations-sequence gv_messagetype
*        INTO lv_obj_name.
*    ENDIF.
*
*    dd40v_wa-rowtype    = lv_obj_name.
*    dd40v_wa-rowkind    = 'S'.
*    dd40v_wa-accessmode = 'T'.
*    dd40v_wa-keydef     = 'D'.
*    dd40v_wa-keykind    = 'N'.
*
*    " Description for the table type
*    dd40v_wa-rowtype     =  lv_typename.
*    dd40v_wa-rowkind     =  'S'.
*    dd40v_wa-accessmode  =  'T'.
*    dd40v_wa-keydef      =  'D'.
*    dd40v_wa-keykind     =  'N'.
*    dd40v_wa-ddtext      = TEXT-001 && gv_messagetype.
*
*    IF dd40v_wa-ddtext IS INITIAL.
*      dd40v_wa-ddtext = lv_typename.
*    ENDIF.
*
*    lv_obj_name = dd40v_wa-typename.
*
*    lv_name = lv_obj_name.
*    " Create the table type
*    CALL FUNCTION 'DDIF_TTYP_PUT'
*      EXPORTING
*        name     = lv_name
*        dd40v_wa = dd40v_wa
*      EXCEPTIONS
*        OTHERS   = 1.
*
*    IF sy-subrc <> 0.
*      lv_message_v3 = 'DDIF_TTYP_PUT-' && lv_obj_name.
*    ENDIF.
*
*    " Register in TADIR
*    IF sy-subrc = 0.
*      IF gv_devclass IS INITIAL.
*        CALL FUNCTION 'TR_TADIR_INTERFACE'
*          EXPORTING
*            wi_tadir_pgmid    = 'R3TR'
*            wi_tadir_object   = 'TTYP'
*            wi_tadir_obj_name = lv_obj_name
*            wi_set_genflag    = abap_true
*            wi_test_modus     = abap_false
*          EXCEPTIONS
*            OTHERS            = 1.
*      ELSE.
*        CALL FUNCTION 'TR_TADIR_INTERFACE'
*          EXPORTING
*            wi_tadir_pgmid    = 'R3TR'
*            wi_tadir_object   = 'TTYP'
*            wi_tadir_obj_name = lv_obj_name
*            wi_set_genflag    = abap_true
*            wi_test_modus     = abap_false
*            wi_tadir_devclass = gv_devclass
*          EXCEPTIONS
*            OTHERS            = 1.
*      ENDIF.
*
*      IF sy-subrc <> 0.
*        lv_message_v3 = 'TR_TADIR_INTERFACE-' && lv_obj_name.
*      ENDIF.
*
*      lv_object = 'TTYP' && lv_obj_name.
*      me->set_corr_insert( iv_mode   = 'I'
*                           iv_object = lv_object  ).
*    ENDIF.
*
*    " Activate type
*    IF sy-subrc = 0.
*      CALL FUNCTION 'DDIF_TTYP_ACTIVATE'
*        EXPORTING
*          name   = lv_name
*        IMPORTING
*          rc     = lv_rc
*        EXCEPTIONS
*          OTHERS = 3.
*
*      IF sy-subrc <> 0 OR lv_rc <> 0.
*        IF lv_rc <> 4.
*          lv_message_v3 = 'ACTIVATE-' && lv_obj_name.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*
*    me->validate_ddic_active( iv_object = lv_obj_name ).
*    me->add_object_entry( iv_pgmid = 'R3TR'  iv_object  = 'TTYP'  iv_object_name = lv_obj_name ). "++TRKORR DB
*
*    lv_message_v1 = 'DDIC'.
*    lv_message_v2 = lv_name.
*    IF lv_message_v3 IS INITIAL.
*      lv_message_v3 = 'activated success'.
*    ENDIF.
*
*    me->append_slg1_log(
*    iv_tabname    = lv_name
*    iv_message_v1 = lv_message_v1
*    iv_message_v2 = lv_message_v2
*    iv_message_v3 = lv_message_v3
*  ).
*
*    ev_type = lv_obj_name.
*
*  ENDMETHOD.
  ENDMETHOD.


  METHOD debug_procedure.

    CONSTANTS: c_deb   TYPE c LENGTH 5 VALUE 'DEBUG',
               c_debrt TYPE c LENGTH 7 VALUE 'DEBUGRT'.

    DATA: ls_param TYPE zonta_oc_param,
          lv_name  TYPE zonta_oc_param-name.

    IF iv_realt = abap_true.
      lv_name = c_debrt.
    ELSE.
      lv_name = c_deb.
    ENDIF.

    SELECT SINGLE *  INTO ls_param
      FROM zonta_oc_param
      WHERE name = lv_name.
    IF sy-subrc = 0 AND ls_param-low = 'X'.
      DO. ENDDO.
      WRITE: 'Debug procedure......'.
    ENDIF.


  ENDMETHOD.


  METHOD delete_json_ddic.
    DATA: lv_objname TYPE ddobjname,
          lv_tabix   TYPE sy-tabix,
          lv_subrc   TYPE sy-subrc,
          lv_object  TYPE string,
          lt_ddic    TYPE STANDARD TABLE OF zonta_oc_ddic.

    FIELD-SYMBOLS: <fs_delete>    TYPE ty_delete,
                   <fs_relations> TYPE zonta_relations,
                   <fs_columns>   TYPE zonta_oc_col_all,
                   <fs_ddic>      TYPE zonta_oc_ddic.



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
      IF <fs_columns> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.
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


**validar que no se borren si se usa en otra en borrado
**en regeneracion si se borra pero validar que se cree de nuevo igual

** Changes 2801 - Delete all from specific ID
* begin of DB 16/oct
**    IF iv_delete_entity = abap_true.
**      IF lines( gt_delete ) > 0.
**        SELECT *
**          INTO TABLE @DATA(lt_ddic_others)
**          FROM zonta_oc_ddic
**          FOR ALL ENTRIES IN @gt_delete
**          WHERE object =   @gt_delete-objname
**            AND id     NE  @<fs_relations>-id.
**        IF sy-subrc = 0.
**          SORT lt_ddic_others BY object.
**          LOOP AT gt_delete ASSIGNING <fs_delete>.
**            READ TABLE lt_ddic_others TRANSPORTING NO FIELDS WITH KEY object = <fs_delete>-objname BINARY SEARCH.
**            IF sy-subrc = 0.
**              <fs_delete>-objtype = 'Y'.
**            ENDIF.
**          ENDLOOP.
**        ENDIF.
**      ENDIF.
**      DELETE gt_delete WHERE objtype = 'Y'.
**    ENDIF.
* End of DB 16/oct

    DO 10 TIMES.
      LOOP AT gt_delete ASSIGNING <fs_delete>.
        lv_tabix = sy-tabix.

*        APPEND INITIAL LINE TO lt_ddic ASSIGNING <fs_ddic>.
*        <fs_ddic>-id            = <fs_relations>-id. "<fs_delete>-objname+3(6).
*        <fs_ddic>-domainv       = gv_domainv.
*        <fs_ddic>-business_proc = gv_entity.
*        <fs_ddic>-object        = <fs_delete>-objname.
***        <fs_ddic>-object_type   = <fs_delete>-objtype.

        me->delete_json_ddic_object( EXPORTING
                                      iv_objname = <fs_delete>-objname
                                      iv_objtype = <fs_delete>-objtype
                                      IMPORTING
                                       ev_subrc  = lv_subrc ).

        IF lv_subrc EQ 0.
          DELETE gt_delete INDEX lv_tabix.
        ENDIF.
      ENDLOOP.

      DELETE FROM zonta_oc_ddic WHERE id = <fs_relations>-id.
      IF sy-subrc = 0.
        COMMIT WORK.
      ENDIF.
      IF gt_delete IS INITIAL.
        EXIT.
      ENDIF.
    ENDDO.

*** Update Log
    me->update_slg1_log( it_log_ext = gt_log_ext ).
  ENDMETHOD.


  METHOD delete_json_ddic_object.
    DATA: lv_name       TYPE ddobjname,
          lv_message_v1 TYPE string, "symsgv,
          lv_message_v2 TYPE string, "symsgv,
          lv_message_v3 TYPE string, "symsgv,
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
      WAIT UP TO 2 SECONDS.
    ENDIF.

    lv_name = iv_objname.

    lv_message_v1 = 'DDIC'.
    lv_message_v2 = lv_name.


    CALL METHOD me->append_slg1_log
      EXPORTING
        iv_tabname    = lv_name
*       iv_key        =
        iv_message_v1 = lv_message_v1
        iv_message_v2 = lv_message_v2
        iv_message_v3 = lv_message_v3
        iv_mestyp     = lv_mestyp.

  ENDMETHOD.


  METHOD get_data.
  ENDMETHOD.


  METHOD get_data_tab.
  ENDMETHOD.


  METHOD get_fieldskey_cds.

*    DATA:
*      lt_primary_key_elements TYPE stringtab,
*      ls_primary_key_element  LIKE LINE OF lt_primary_key_elements,
*      lv_id                   TYPE if_sadl_entity=>ty_entity_id.
*
*    TRY.
*        " 1. Get primary key information using SADL
*        lv_id = iv_tabname.
*        DATA(lo_sadl_entity) = cl_sadl_entity_factory=>get_instance( )->get_entity(
*          iv_id   = lv_id
*          iv_type = cl_sadl_entity_factory=>co_type-cds
*        ).
*
*        lo_sadl_entity->get_primary_key_elements(
*          IMPORTING
*            et_primary_key_elements = lt_primary_key_elements
*        ).
*
*        " Store primary key names in a hashed table for quick lookup
*        LOOP AT lt_primary_key_elements INTO ls_primary_key_element.
*          INSERT ls_primary_key_element INTO TABLE ext_keys_fields.
*        ENDLOOP.
*
*      CATCH cx_sy_move_cast_error INTO DATA(lx_cast).
*        gs_elog-type       = 'CAST_ERROR'.
*        gs_elog-severity   = gc_error.
*        gs_elog-message    = lx_cast->get_longtext( ).
*        CALL METHOD lx_cast->get_source_position
*          IMPORTING
*            program_name = gv_prog
*            source_line  = gv_sline.
*        gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
*        gs_elog-details-db = 'ZONCL_FETCH_DATA-GET_FIELDSKEY_CDS'.
*        gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.
*
*        gs_elog-metadata-error_code = gs_elog-details-error_code.
*        interpret_message( EXPORTING iv_msgnr = '088'  IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
*        interpret_message( EXPORTING iv_msgnr = '089' iv_msgv1 = 'CDS' IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
*        interpret_message( EXPORTING iv_msgnr = '090'  IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
*        interpret_message( EXPORTING iv_msgnr = '091'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
*        CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
*        interpret_message( EXPORTING iv_msgnr = '086'  IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
*        interpret_message( EXPORTING iv_msgnr = '087'  IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_fixes ).
*        CONCATENATE gv_msg1 gv_msg2 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.
*        print_error_otel( ).
*
*        send_json_error( ).
**        MESSAGE 'Error: Type cast issue during metadata retrieval.' TYPE 'E'.
*      CATCH cx_sy_itab_line_not_found INTO DATA(lx_notf).
*        gs_elog-type       = 'ITAB_LINE_NOT_FOUND'.
*        gs_elog-severity   = gc_error.
*        gs_elog-message    = lx_notf->get_longtext( ).
*        CALL METHOD lx_notf->get_source_position
*          IMPORTING
*            program_name = gv_prog
*            source_line  = gv_sline.
*        gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
*        gs_elog-details-db = 'ZONCL_FETCH_DATA-GET_FIELDSKEY_CDS'.
*        gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.
*
*        gs_elog-metadata-error_code = gs_elog-details-error_code.
*        interpret_message( EXPORTING iv_msgnr = '094'   iv_msgv1 = iv_tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
*        interpret_message( EXPORTING iv_msgnr = '095'   iv_msgv1 = iv_tabname IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
*        interpret_message( EXPORTING iv_msgnr = '096'   iv_msgv1 = iv_tabname IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
*        interpret_message( EXPORTING iv_msgnr = '097'   iv_msgv1 = iv_tabname IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
*        CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
*        interpret_message( EXPORTING iv_msgnr = '098'   iv_msgv1 = iv_tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
*        gs_elog-metadata-possible_fix = gv_msg1.
*        print_error_otel( ).
*
*        send_json_error( ).
**        MESSAGE 'Error: Component not found during description.' TYPE 'E'.
*    ENDTRY.
  ENDMETHOD.


  METHOD get_objects.
    et_objects = gt_objects[].
    et_ddic    = gt_ddic[].

  ENDMETHOD.


  METHOD get_relation.

    "Validate if debug is active
    me->debug_procedure( ).


    IF iv_variant IS NOT INITIAL.
      CALL METHOD me->get_variant_values
        EXPORTING
          iv_domainv      = iv_domainv
          iv_entity       = iv_business_proc
          iv_variant      = iv_variant
        IMPORTING
          et_where        = it_where_cond_tab
          et_ranges_where = it_ranges_where.
    ENDIF.

    " 1. Set global attributes
    me->set_globals(
      iv_kdoc           = iv_kdoc
      iv_table          = iv_table
      iv_ddic           = iv_ddic
      iv_dest           = iv_dest
      iv_update         = iv_update
      iv_delete         = iv_delete
      iv_domainv        = iv_domainv
      iv_entity         = iv_business_proc
      iv_key_queue      = iv_key_queue
      iv_batch          = iv_batch
      it_where          = it_where
      iv_instid         = iv_instid
      iv_anytable       = iv_anytable
      iv_alias          = iv_alias
      iv_uuid           = iv_uuid
      iv_fieldname      = iv_fieldname
      iv_tagdata        = iv_tagdata
      iv_tagmetadata    = iv_tagmetadata
      iv_bothnames      = iv_bothnames
      iv_tm             = iv_tm
      iv_variant        = iv_variant
      it_endpoints      = it_endpoints
      it_where_cond_tab = it_where_cond_tab
      it_ranges_where   = it_ranges_where
    ).

    " 2. Adjust flags (custom logic from call stack)
    me->adjust_context_from_callstack( ).

    me->get_global_data( ).

    " 3. Skip if DDIC
    IF iv_ddic = abap_true.
      RETURN.
    ENDIF.

    DATA v_tryoff TYPE c.
    SELECT SINGLE low INTO v_tryoff FROM zonta_oc_param WHERE name = 'SET_TRY_OFF'.

    " 4. Single endpoint case
    IF it_endpoints IS INITIAL.

      me->get_handler_by_flags( ).
      IF v_tryoff IS NOT INITIAL.

        IF mo_handler IS BOUND.

          mo_handler->call_base_get_data(
            IMPORTING
              ev_sizet    = gs_log_json_result-sizet " gv_sizet
              ev_recordst = gs_log_json_result-recordst " gv_recordst
          ).
        ENDIF.

* if both kdoc and table are set
        IF gv_back_2_process = abap_true.
          me->get_handler_by_flags( ).

          IF mo_handler IS BOUND.
            mo_handler->get_data(
              IMPORTING
                ev_sizet    = ev_sizet
                ev_recordst = ev_recordst
            ).
          ENDIF.
        ENDIF.
* DO TRY
      ELSE.
        TRY.
            IF mo_handler IS BOUND.

              mo_handler->call_base_get_data(
                IMPORTING
                  ev_sizet    = gs_log_json_result-sizet " gv_sizet
                  ev_recordst = gs_log_json_result-recordst " gv_recordst
              ).
            ENDIF.

* if both kdoc and table are set
            IF gv_back_2_process = abap_true.
              me->get_handler_by_flags( ).

              IF mo_handler IS BOUND.
                mo_handler->get_data(
                  IMPORTING
                    ev_sizet    = ev_sizet
                    ev_recordst = ev_recordst
                ).
              ENDIF.
            ENDIF.
          CATCH cx_root INTO gx_text.
            gs_elog-type       = 'HANDLER-GET_DATA'.
            gs_elog-severity   = gc_error.
            gs_elog-message    = gx_text->get_longtext( ).
            CALL METHOD gx_text->get_source_position
              IMPORTING
                program_name = gv_prog
                source_line  = gv_sline.
            gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
            gs_elog-details-db = 'ZONCL_FETCH_DATA-GET_RELATION'.
            gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

            gs_elog-metadata-error_code = gs_elog-details-error_code.
            interpret_message( EXPORTING iv_msgnr = '094'  iv_msgv1 = gv_entity IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '095'  IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '090'  IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '091'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
            CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
            interpret_message( EXPORTING iv_msgnr = '086'  IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '096'  IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '087'  IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_fixes ).
            CONCATENATE gv_msg1 gv_msg2 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.
            print_error_otel( ).

            send_json_error( ).
*          CONCATENATE 'Error when get the Relation : ' gx_text-text INTO gx_text-text.
*            me->print_error( ).
        ENDTRY.
      ENDIF.
    ELSE.

      LOOP AT it_endpoints INTO gs_endpoints.

        gv_dest = gs_endpoints-endpoint.

        CASE gs_endpoints-transm_medium.
          WHEN 'K'.
            gv_kdoc  = abap_true.
            gv_table = abap_false.
          WHEN 'T'.
            gv_kdoc  = abap_false.
            gv_table = abap_true.
          WHEN 'B'.
            gv_kdoc  = abap_true.
            gv_table = abap_true.
          WHEN OTHERS.
            gv_kdoc  = abap_false.
            gv_table = abap_true.
        ENDCASE.

        IF v_tryoff IS NOT INITIAL.
          me->get_handler_by_flags( ).

          IF mo_handler IS BOUND.
            mo_handler->get_data(
              IMPORTING
                ev_sizet    = ev_sizet
                ev_recordst = ev_recordst
            ).
          ENDIF.

* If both KDOC and table are set
          IF gv_back_2_process = abap_true.
            me->get_handler_by_flags( ).

            IF mo_handler IS BOUND.
              mo_handler->get_data(
                IMPORTING
                  ev_sizet    = ev_sizet
                  ev_recordst = ev_recordst
              ).
            ENDIF.

          ENDIF.
        ELSE.
          TRY.
              me->get_handler_by_flags( ).

              IF mo_handler IS BOUND.
                mo_handler->get_data(
                  IMPORTING
                    ev_sizet    = ev_sizet
                    ev_recordst = ev_recordst
                ).
              ENDIF.

* If both KDOC and table are set
              IF gv_back_2_process = abap_true.
                me->get_handler_by_flags( ).

                IF mo_handler IS BOUND.
                  mo_handler->get_data(
                    IMPORTING
                      ev_sizet    = ev_sizet
                      ev_recordst = ev_recordst
                  ).
                ENDIF.

              ENDIF.
            CATCH cx_root INTO gx_text.
              gs_elog-type       = 'HANDLER-GET_DATA'.
              gs_elog-severity   = gc_error.
              gs_elog-message    = gx_text->get_longtext( ).
              CALL METHOD gx_text->get_source_position
                IMPORTING
                  program_name = gv_prog
                  source_line  = gv_sline.
              gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
              gs_elog-details-db = 'ZONCL_FETCH_DATA-GET_RELATION'.
              gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

              gs_elog-metadata-error_code = gs_elog-details-error_code.
              interpret_message( EXPORTING iv_msgnr = '088'  IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
              interpret_message( EXPORTING iv_msgnr = '089'  IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
              interpret_message( EXPORTING iv_msgnr = '090'  IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
              interpret_message( EXPORTING iv_msgnr = '091'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
              CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
              interpret_message( EXPORTING iv_msgnr = '086'  IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
              interpret_message( EXPORTING iv_msgnr = '087'  IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_fixes ).
              CONCATENATE gv_msg1 gv_msg2 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.
              print_error_otel( ).

              send_json_error( ).
*              me->print_error( ).
          ENDTRY.
        ENDIF.
      ENDLOOP.

    ENDIF.


  ENDMETHOD.


  METHOD print_error.
    DATA: lo_out TYPE REF TO if_demo_output.


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


  METHOD save_log.

    DATA lv_tst TYPE timestampl. "timest.
    DATA ls_fetch_r TYPE zonta_oc_fetch_r.
    DATA ls_fetch_rp TYPE zonta_oc_fetchrp.

    DATA ls_status TYPE char01.

    GET TIME STAMP FIELD lv_tst.

    IF cv_uuid IS INITIAL.
      cv_uuid = cl_system_uuid=>create_uuid_x16_static( ).
*      DATA(ls_status) = 'S'.
      ls_status = 'S'.
    ELSE.
      ls_status = 'P'.
    ENDIF.

    SELECT SINGLE *
    INTO ls_fetch_r
    FROM zonta_oc_fetch_r
    WHERE uuid_rec = cv_uuid.

    IF sy-subrc EQ 0.

      ls_fetch_r-zdate           = sy-datum.
      ls_fetch_r-time            = sy-uzeit.
      ls_fetch_r-creation_datime = lv_tst.
      ls_fetch_r-status_header   = 'E'.
      ls_fetch_r-creation_user   = sy-uname.
      ls_fetch_r-ernam           = sy-uname.

    ELSE.

*      ls_fetch_r = VALUE zonta_oc_fetch_r( uuid_rec = cv_uuid
*      mandt           = sy-mandt
*      instid          = is_sender-instid
*      typeid          = is_sender-typeid
*      catid           = is_sender-catid
*      event           = iv_event
*      domainv         = is_zonta_relations-domainv
*      entity_name     = is_zonta_relations-business_proc
*      destination     = iv_dest
*      zdate           = sy-datum
*      status_header   = 'E'
*      time            = sy-uzeit
*      creation_datime = lv_tst
*      creation_user   = sy-uname
*      ernam           = sy-uname
*       ).

      ls_fetch_r-uuid_rec = cv_uuid.
      ls_fetch_r-mandt           = sy-mandt.
      ls_fetch_r-instid          = is_sender-instid.
      ls_fetch_r-typeid          = is_sender-typeid.
      ls_fetch_r-catid           = is_sender-catid.
      ls_fetch_r-event           = iv_event.
      ls_fetch_r-domainv         = is_zonta_relations-domainv.
      ls_fetch_r-entity_name     = is_zonta_relations-business_proc.
      ls_fetch_r-destination     = iv_dest.
      ls_fetch_r-zdate           = sy-datum.
      ls_fetch_r-status_header   = 'E'.
      ls_fetch_r-time            = sy-uzeit.
      ls_fetch_r-creation_datime = lv_tst.
      ls_fetch_r-creation_user   = sy-uname.
      ls_fetch_r-ernam           = sy-uname.

    ENDIF.

    MODIFY zonta_oc_fetch_r FROM ls_fetch_r.

  ENDMETHOD.


  METHOD send_event_automatic.

    "----------------------------------------------------------------------
    " Initialization and Constants
    "----------------------------------------------------------------------
    CONSTANTS: lc_comilla TYPE c LENGTH 1 VALUE ''''.

    TYPES: BEGIN OF ty_dd03l,
             tabname   TYPE dd03l-tabname,
             fieldname TYPE dd03l-fieldname,
             as4local  TYPE dd03l-as4local,
             as4vers   TYPE dd03l-as4vers,
             position  TYPE dd03l-position,
             keyflag   TYPE dd03l-keyflag,
             rollname  TYPE dd03l-rollname,
           END OF ty_dd03l.

    DATA: lt_oc_param              TYPE STANDARD TABLE OF zonta_oc_param,
          lt_endpoints             TYPE STANDARD TABLE OF zonta_oc_endp,
          lt_where_cond_tab        TYPE rsds_twhere,
          lt_entities_aux          TYPE STANDARD TABLE OF zonta_obj_oc,
          lt_relations             TYPE STANDARD TABLE OF zonta_relations,
          lt_columns               TYPE STANDARD TABLE OF zonta_oc_col_all,
          lt_relations_aux         TYPE STANDARD TABLE OF zonta_relations,
          lt_dd03l_keyfieldbytable TYPE STANDARD TABLE OF ty_dd03l,
          lt_primary_key_names     TYPE HASHED TABLE OF string WITH UNIQUE KEY table_line,
          lt_info                  TYPE STANDARD TABLE OF swotrk,
          lt_info_hdr              TYPE STANDARD TABLE OF swotrk,
          lv_objtype               TYPE swotobjid-objtype,
          lv_object                TYPE zonde_oc_sibftypeid,
          lv_key                   TYPE string,
          lv_key1                  TYPE string,
          lv_key2                  TYPE string,
          lv_destination           TYPE rfcdest,
          lv_vbeln                 TYPE string,
          lv_update                TYPE char1,
          lv_delete                TYPE char1,
          lv_lines                 TYPE sy-index,
          ls_obj_oc                TYPE zonta_obj_oc,
          lv_sequence              TYPE zonde_sequence,
          lv_kdoc(01)              TYPE c,
          lv_tabl(01)              TYPE c,
          lv_kunnr                 TYPE kunnr,
          lv_reffld                TYPE swc_reffld,
          lv_reffld2               TYPE swc_reffld,
          lv_pos(02)               TYPE n,
          lv_tabix                 TYPE sy-tabix,
          lv_objtype_cl            TYPE char30,
          lv_tabix_aux             TYPE sy-tabix,
          lv_alias                 TYPE boolean,
          lv_fieldname             TYPE boolean,
          lv_class                 TYPE string,
          lo_descr                 TYPE REF TO cl_abap_objectdescr,
          lo_obj                   TYPE REF TO object,
          lo_iface                 TYPE REF TO zonif_code,
          lv_entity                TYPE zonde_process,
          lv_endpoint              TYPE rfcdest,
          lv_where                 TYPE string,
          lx_create                TYPE REF TO cx_sy_create_object_error,
          lx_cast                  TYPE REF TO cx_sy_move_cast_error,
          v_cont                   TYPE i,
          v_prlog                  TYPE c,
          v_lm1                    TYPE symsgv,
          v_lm2                    TYPE symsgv,
          v_lm3                    TYPE symsgv,
          v_lm4                    TYPE symsgv,
          lt_entities              TYPE STANDARD TABLE OF zonta_obj_oc,
          ls_entities              TYPE zonta_obj_oc,
          ls_relations             TYPE zonta_relations,
          ls_columns               TYPE zonta_oc_col_all. ",
*          lw_dd02b                 TYPE dd02b.

    DATA ls_entity_log TYPE zonta_obj_oc.

    FIELD-SYMBOLS: <fs_where_cond_tab> TYPE LINE OF rsds_twhere,
                   <fs_where_tab>      TYPE LINE OF rsds_where_tab,
                   <fs_where_tab2>     TYPE LINE OF rsds_where_tab,
                   <fs_info>           TYPE swotrk,
                   <fs_info_hdr>       TYPE swotrk,
                   <fs_oc_param>       TYPE zonta_oc_param.

* Check if debug procedure is active
    me->debug_procedure( iv_realt = abap_true ).

    "----------------------------------------------------------------------
    " Extract Sender Info
    "----------------------------------------------------------------------
    lv_object  = is_sender-typeid.
    lv_objtype = is_sender-typeid.
*    DO.ENDDO.
    "----------------------------------------------------------------------
    " Load Process Configuration (Entities, Relations, Keys)
    "----------------------------------------------------------------------
    SELECT * INTO TABLE lt_entities FROM zonta_obj_oc WHERE objtype = lv_object.
    SELECT SINGLE low FROM zonta_oc_param INTO v_prlog WHERE name = 'PROCESS_LOG' AND low = 'X'.

    IF v_prlog = 'X'.
*      LOOP AT lt_entities INTO data(ls_entity_log).
      LOOP AT lt_entities INTO ls_entity_log.
        ADD 1 TO v_cont.
        MOVE 'EVENT_AUT : GET ENTITIES' TO v_lm1.
        MOVE v_cont TO v_lm2.
        MOVE ls_entity_log-business_proc TO v_lm3.
        CALL METHOD me->set_process_log
          EXPORTING
            i_text1   = v_lm1
            i_text2   = v_lm2
            i_text3   = v_lm3
            i_process = 'SEND_EVENT'.
      ENDLOOP.
    ENDIF.

    "----------------------------------------------------------------------
    " Deduplicate & Load Relations/Key Fields for All Entities
    "----------------------------------------------------------------------
    IF lt_entities[] IS NOT INITIAL.
      lt_entities_aux[] = lt_entities[].
      SORT lt_entities_aux BY id domainv business_proc.
      DELETE ADJACENT DUPLICATES FROM lt_entities_aux COMPARING id domainv business_proc.

      IF lt_entities_aux[] IS NOT INITIAL.
*        SELECT * FROM zonta_relations INTO TABLE @lt_relations
*          FOR ALL ENTRIES IN @lt_entities_aux WHERE id = @lt_entities_aux-id AND sequence = 1.
        SELECT * FROM zonta_relations INTO TABLE lt_relations
          FOR ALL ENTRIES IN lt_entities_aux WHERE id = lt_entities_aux-id AND sequence = 1.

        IF sy-subrc = 0.
          lt_relations_aux[] = lt_relations[].
          SORT lt_relations_aux BY tabname sequence.
          DELETE lt_relations_aux WHERE sequence NE 1.
          DELETE ADJACENT DUPLICATES FROM lt_relations_aux COMPARING tabname sequence.

          IF lt_relations_aux[] IS NOT INITIAL.
*            SELECT tabname, fieldname, as4local, as4vers, POSITION, keyflag, rollname
*              into table @lt_dd03l_keyfieldbytable
*              from dd03l
*              for all entries in @lt_relations_aux
*              where tabname = @lt_relations_aux-tabname and fieldname <> 'MANDT'
*                and as4local = 'A' and keyflag = @abap_true.
            SELECT tabname fieldname as4local as4vers position keyflag rollname
              INTO TABLE lt_dd03l_keyfieldbytable
              FROM dd03l
              FOR ALL ENTRIES IN lt_relations_aux
              WHERE tabname = lt_relations_aux-tabname AND fieldname <> 'MANDT'
                AND as4local = 'A' AND keyflag = 'X'.
            IF sy-subrc <> 0.
              CLEAR lt_dd03l_keyfieldbytable[].
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    "----------------------------------------------------------------------
    " Process Each Entity
    "----------------------------------------------------------------------
    LOOP AT lt_entities INTO ls_obj_oc.

      "--- Handle dynamic class handler if provided ---
      IF ls_obj_oc-class_name IS NOT INITIAL.

        SELECT SINGLE low
          INTO lv_endpoint
          FROM zonta_oc_param
          WHERE name = 'RFC_DESTINATION'.

        lv_class  = ls_obj_oc-class_name.
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
            gs_elog-type       = 'CL_ABAP_OBJECTDESCR'.
            gs_elog-severity   = gc_error.
            gs_elog-message    = lx_create->get_longtext( ).
            CALL METHOD lx_create->get_source_position
              IMPORTING
                program_name = gv_prog
                source_line  = gv_sline.
            gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
            gs_elog-details-db = 'ZONCL_FETCH_DATA-SEND_EVENT_AUTOMATIC'.
            gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

            gs_elog-metadata-error_code = gs_elog-details-error_code.
            interpret_message( EXPORTING iv_msgnr = '088'  IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '089' iv_msgv1 = lv_class IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '090'  IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '091'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
            CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
            interpret_message( EXPORTING iv_msgnr = '086'  IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '087'  IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_fixes ).
            CONCATENATE gv_msg1 gv_msg2 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.
            print_error_otel( ).

            send_json_error( ).
*            MESSAGE lx_create->get_text( ) TYPE 'E'.
          CATCH cx_sy_move_cast_error INTO lx_cast.
            gs_elog-type       = 'CAST_DATA'.
            gs_elog-severity   = gc_error.
            gs_elog-message    = lx_cast->get_longtext( ).
            CALL METHOD lx_cast->get_source_position
              IMPORTING
                program_name = gv_prog
                source_line  = gv_sline.
            gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
            gs_elog-details-db = 'ZONCL_FETCH_DATA-SEND_EVENT_AUTOMATIC'.
            gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.

            gs_elog-metadata-error_code = gs_elog-details-error_code.
            interpret_message( EXPORTING iv_msgnr = '092'  iv_msgv1 = lv_class IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '093'  IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
            CONCATENATE gv_msg1 gv_msg2 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
            interpret_message( EXPORTING iv_msgnr = '086'  IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '087'  IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_fixes ).
            CONCATENATE gv_msg1 gv_msg2 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.
            print_error_otel( ).

            send_json_error( ).
*            MESSAGE lx_cast->get_text( ) TYPE 'E'.
        ENDTRY.

      ELSE.

        "--- Load relation and columns for standard handler ---
*        ls_relations = value #( lt_relations[ ID = ls_obj_oc-id SEQUENCE = 1 ] OPTIONAL ).
        READ TABLE lt_relations INTO ls_relations WITH KEY id = ls_obj_oc-id sequence = 1.

        IF ls_relations-sequence IS NOT INITIAL.
          lv_sequence = ls_relations-sequence.
        ENDIF.

        SELECT * "#EC CI_NOFIRST.
          FROM zonta_oc_col_all
          INTO TABLE lt_columns
          WHERE tabname = ls_relations-tabname.

        IF lv_sequence IS INITIAL.
          RETURN.
        ENDIF.

        "--- Process Log: Log event type being sent ---
        IF v_prlog = 'X'.
          ADD 1 TO v_cont.
          CLEAR: v_lm1, v_lm2, v_lm3, v_lm4.
          MOVE 'EVENT_AUT : EVENT_TYPE' TO v_lm1.
          MOVE v_cont                  TO v_lm2.
          MOVE is_sender-catid        TO v_lm3.
          MOVE lv_objtype             TO v_lm4.
          CALL METHOD me->set_process_log
            EXPORTING
              i_text1   = v_lm1
              i_text2   = v_lm2
              i_text3   = v_lm3
              i_text4   = v_lm4
              i_process = 'SEND_EVENT'.
        ENDIF.
        "--- Generate WHERE clause by BO or CDS logic ---
        CASE is_sender-catid.
          WHEN 'BO'.

            " Get key fields for the BOR object type
            CALL FUNCTION 'SWO_QUERY_KEYFIELDS'
              EXPORTING
                objtype = lv_objtype
              TABLES
                info    = lt_info.

            " Sort fields by edit order to build key sequence
            SORT lt_info BY editorder.
            lv_lines = lines( lt_info ).

            " Prepare header list of unique object types
            lt_info_hdr = lt_info.
            SORT lt_info_hdr BY objtype.
            DELETE ADJACENT DUPLICATES FROM lt_info_hdr COMPARING objtype.

            " Loop over each unique object type
            LOOP AT lt_info_hdr ASSIGNING <fs_info_hdr>.
              APPEND INITIAL LINE TO lt_where_cond_tab ASSIGNING <fs_where_cond_tab>.

              " If the relation matches the info object type, use that
              IF ls_relations-tabname = <fs_info_hdr>-objtype.
                <fs_where_cond_tab>-tablename = <fs_info_hdr>-objtype.

                " Loop over all matching key fields
                LOOP AT lt_info ASSIGNING <fs_info>
                            WHERE objtype EQ <fs_info_hdr>-objtype.

                  APPEND INITIAL LINE TO <fs_where_cond_tab>-where_tab ASSIGNING <fs_where_tab>.
                  lv_tabix = sy-tabix.

                  " Handle special case: convert 'PARTNER' to 'KUNNR' if exists
                  IF <fs_info>-reffield = 'PARTNER'.
                    lv_kunnr = is_sender-instid.
                    SELECT SINGLE kunnr INTO lv_kunnr FROM kna1 WHERE kunnr = lv_kunnr.
                    IF sy-subrc = 0.
                      <fs_info>-reffield = 'KUNNR'.
                    ENDIF.
                  ENDIF.

                  " Only consider reffield if it exists in known columns
                  READ TABLE lt_columns INTO ls_columns
                       WITH KEY tabname = ls_relations-tabname
                                fldname = <fs_info>-reffield.
                  IF sy-subrc = 0.
                    lv_key1 = <fs_info>-reffield.
                  ELSE.
                    CONTINUE.
                  ENDIF.

                  " Extract and clean key value from instance ID
                  lv_vbeln = |{ lc_comilla } { is_sender-instid+lv_pos(<fs_info>-outlength) } { lc_comilla }|.
                  CONDENSE lv_vbeln NO-GAPS.

                  " Construct WHERE clause for the current key field
                  IF lv_tabix NE lv_lines.
                    CONCATENATE lv_key
                                '('
                                lv_key1
                                'EQ'
                                lv_vbeln
                                ') AND'
                                INTO <fs_where_tab>-line
                                SEPARATED BY space.
                  ELSE.
                    CONCATENATE lv_key
                                '('
                                lv_key1
                                'EQ'
                                lv_vbeln
                                ')'
                                INTO <fs_where_tab>-line
                                SEPARATED BY space.
                  ENDIF.

                  " Advance position for next key segment
                  lv_pos = lv_pos + <fs_info>-outlength.
                ENDLOOP.

              ELSE.
                " Relation doesn't match object type – fallback logic
                <fs_where_cond_tab>-tablename = ls_relations-tabname.

                LOOP AT lt_info ASSIGNING <fs_info>
                            WHERE objtype EQ <fs_info_hdr>-objtype.

                  APPEND INITIAL LINE TO <fs_where_cond_tab>-where_tab ASSIGNING <fs_where_tab>.
                  lv_tabix = sy-tabix.

                  " Same PARTNER → KUNNR mapping
                  IF <fs_info>-reffield = 'PARTNER'.
                    lv_kunnr = is_sender-instid.
                    SELECT SINGLE kunnr INTO lv_kunnr FROM kna1 WHERE kunnr = lv_kunnr.
                    IF sy-subrc = 0.
                      <fs_info>-reffield = 'KUNNR'.
                    ENDIF.
                  ENDIF.

                  " Use main field if reffield does not match relation field
                  IF ls_relations-field_main = <fs_info>-reffield.
                    lv_key1 = <fs_info>-reffield.
                  ELSEIF ls_relations-field_main IS NOT INITIAL.
*                    SELECT SINGLE * FROM dd02b INTO lw_dd02b WHERE strucobjn = ls_relations-tabname.
*                    IF sy-subrc EQ 0.
*                      lv_key1 = ls_relations-field_main.
*                    ELSE.
                    lv_key1 = <fs_info>-reffield.
*                    ENDIF.
                  ELSE.
                    CONTINUE.
                  ENDIF.

                  " Extract key value from instance ID using offset
                  lv_vbeln = |{ lc_comilla } { is_sender-instid+lv_pos(<fs_info>-outlength) } { lc_comilla }|.
                  CONDENSE lv_vbeln NO-GAPS.

                  " Append condition to WHERE line
                  IF lv_tabix NE lv_lines.
                    CONCATENATE lv_key
                                '('
                                lv_key1
                                'EQ'
                                lv_vbeln
                                ') AND'
                                INTO <fs_where_tab>-line
                                SEPARATED BY space.
                  ELSE.
                    CONCATENATE lv_key
                                '('
                                lv_key1
                                'EQ'
                                lv_vbeln
                                ')'
                                INTO <fs_where_tab>-line
                                SEPARATED BY space.
                  ENDIF.

                  lv_pos = lv_pos + <fs_info>-outlength.
                ENDLOOP.

              ENDIF. " relation tabname match

            ENDLOOP. " info header loop

          WHEN 'CL'.

**********************************************************************
            DATA lt_keys_cl TYPE TABLE OF swc_reffld.

            DATA: lo_strucdescr TYPE REF TO cl_abap_structdescr.
            DATA ls_dd03l LIKE LINE OF lt_dd03l_keyfieldbytable.
            DATA ls_key LIKE LINE OF lt_primary_key_names.
            DATA lt_fields TYPE ddfields.
            DATA ls_fields LIKE LINE OF lt_fields.
            DATA ls_str_typeid TYPE zonta_oc_oty_str.
            DATA ls_keys_cl LIKE LINE OF lt_keys_cl.
            DATA lv_uuid TYPE uuid.
**********************************************************************

            " Determine the technical object (typically a database table or CDS view)
            lv_objtype_cl = ls_relations-tabname.
*            lv_tabix_aux = sy-tabix.
*            CLEAR lv_tabix_aux.

            " Try to get key fields from DDIC structure (preloaded list)
            IF lt_dd03l_keyfieldbytable[] IS NOT INITIAL.

*              LOOP AT lt_dd03l_keyfieldbytable INTO data(ls_dd03l)
              LOOP AT lt_dd03l_keyfieldbytable INTO ls_dd03l
                   WHERE tabname = ls_relations-tabname.
*                ADD 1 TO lv_tabix_aux.
*                IF lv_tabix_aux EQ 1.
*                  lv_reffld = ls_dd03l-fieldname.
*                ELSE.
*                  lv_reffld2 = ls_dd03l-fieldname.
*                ENDIF.
                APPEND ls_dd03l-fieldname TO lt_keys_cl.
              ENDLOOP.

            ELSE.
              " If not available, retrieve keys from CDS entity definition
              CLEAR: lt_primary_key_names[].

              get_fieldskey_cds(
                EXPORTING
                  iv_tabname      = ls_relations-tabname
                IMPORTING
                  ext_keys_fields = lt_primary_key_names
              ).

*              LOOP AT lt_primary_key_names INTO data(ls_key).
              LOOP AT lt_primary_key_names INTO ls_key.
*                ADD 1 TO lv_tabix_aux.
*                IF lv_tabix_aux EQ 1.
*                  lv_reffld = ls_key.
*                ELSE.
*                  lv_reffld2 = ls_key.
*                  EXIT.
*                ENDIF.
*                APPEND ls_dd03l-fieldname TO lt_keys_cl.
                APPEND ls_key TO lt_keys_cl.
              ENDLOOP.

            ENDIF.

            " Append a new WHERE clause container for this table/entity
            APPEND INITIAL LINE TO lt_where_cond_tab ASSIGNING <fs_where_cond_tab>.
            <fs_where_cond_tab>-tablename = lv_objtype_cl.

**********************************************************************
            SELECT SINGLE *
*            INTO @data(ls_str_typeid)
            INTO ls_str_typeid
            FROM zonta_oc_oty_str
*            WHERE objtype = @is_sender-typeid.
            WHERE objtype = is_sender-typeid.

            IF sy-subrc NE 0.

              APPEND INITIAL LINE TO <fs_where_cond_tab>-where_tab ASSIGNING <fs_where_tab>.

              CLEAR lv_vbeln.
              lv_vbeln = |{ lc_comilla }{ is_sender-instid }{ lc_comilla }|.
              CONDENSE lv_vbeln NO-GAPS.

*              <fs_where_tab>-line = |( { lt_keys_cl[ 1 ] } EQ { lv_vbeln } )|.
              READ TABLE lt_keys_cl INTO ls_keys_cl INDEX 1.
              IF sy-subrc EQ 0.
                <fs_where_tab>-line = |( { ls_keys_cl } EQ { lv_vbeln } )|.
              ENDIF.

            ELSE.

              lo_strucdescr ?= cl_abap_typedescr=>describe_by_name( ls_str_typeid-tabname ).

*              data(lt_fields) = lo_strucdescr->get_ddic_field_list( ).
              lt_fields = lo_strucdescr->get_ddic_field_list( ).

              IF ls_str_typeid-only_key EQ abap_true.
                DELETE lt_fields WHERE keyflag NE abap_true.
              ENDIF.

              IF ls_str_typeid-without_client EQ abap_true.
                DELETE lt_fields WHERE datatype = 'CLNT'.
              ENDIF.

              CLEAR lv_pos.

*              LOOP AT lt_fields INTO data(ls_fields).
              LOOP AT lt_fields INTO ls_fields.
*                READ TABLE lt_keys_cl INTO data(ls_keys_cl) WITH KEY table_line = ls_fields-fieldname.
                READ TABLE lt_keys_cl INTO ls_keys_cl WITH KEY table_line = ls_fields-fieldname.
                IF sy-subrc EQ 0.
                  APPEND INITIAL LINE TO <fs_where_cond_tab>-where_tab ASSIGNING <fs_where_tab>.

                  CLEAR lv_vbeln.
                  lv_vbeln = |{ lc_comilla }{ is_sender-instid+lv_pos(ls_fields-leng) }{ lc_comilla }|.
                  CONDENSE lv_vbeln NO-GAPS.

                  <fs_where_tab>-line = |( { ls_keys_cl } EQ { lv_vbeln } )|.
                  IF lines( <fs_where_cond_tab>-where_tab ) > 1.
                    <fs_where_tab>-line = |AND { <fs_where_tab>-line }|.
                  ENDIF.
                  ADD ls_fields-leng TO lv_pos.

                ENDIF.

              ENDLOOP.

            ENDIF.

*            " Build WHERE clause depending on sender type
*            CASE is_sender-typeid.
*
*                " Special case: material documents (MBLNR + MJAHR)
*              WHEN 'CL_MMIM_MATDOC_EVENT'.
*                APPEND INITIAL LINE TO <fs_where_cond_tab>-where_tab ASSIGNING <fs_where_tab>.
*
*                " First key: MBLNR
*                lv_key1 = lv_reffld.
*                lv_vbeln = |{ lc_comilla }{ is_sender-instid+04(10) }{ lc_comilla }|.
*                CONDENSE lv_vbeln NO-GAPS.
*
*                CONCATENATE '(' lv_key1 'EQ' lv_vbeln ') AND'
*                            INTO <fs_where_tab>-line
*                            SEPARATED BY space.
*
*                " Second key: MJAHR
*                lv_key2 = lv_reffld2.
*                lv_vbeln = |{ lc_comilla }{ is_sender-instid(04) }{ lc_comilla }|.
*                CONDENSE lv_vbeln NO-GAPS.
*
*                CONCATENATE <fs_where_tab>-line
*                            '(' lv_key2 'EQ' lv_vbeln ')'
*                            INTO <fs_where_tab>-line
*                            SEPARATED BY space.
*
*                " Default case: single-key access
*              WHEN OTHERS.
*                APPEND INITIAL LINE TO <fs_where_cond_tab>-where_tab ASSIGNING <fs_where_tab>.
*
*                lv_key = lv_reffld.
*                lv_vbeln = |{ lc_comilla }{ is_sender-instid }{ lc_comilla }|.
*                CONDENSE lv_vbeln NO-GAPS.
*
*                CONCATENATE '(' lv_key 'EQ' lv_vbeln ')'
*                            INTO <fs_where_tab>-line
*                            SEPARATED BY space.
*
*            ENDCASE.
        ENDCASE.

        "--- Flag update or delete ---
        CASE i_event.
          WHEN 'DELETE' OR 'DELETED'.
            lv_delete = abap_true.
          WHEN OTHERS.
            lv_update = abap_true.
        ENDCASE.

        "--- Load global parameters ---
        SELECT * INTO TABLE lt_oc_param FROM zonta_oc_param.
        IF sy-subrc EQ 0.
          LOOP AT lt_oc_param ASSIGNING <fs_oc_param>.
            CASE <fs_oc_param>-name.
              WHEN 'RFC_DESTINATION'.
                lv_destination = <fs_oc_param>-low.
              WHEN 'TRANSMISSION_MEDIUM'.
                CASE <fs_oc_param>-low.
                  WHEN 'T'. lv_kdoc = abap_false. lv_tabl = abap_true.
                  WHEN 'K'. lv_kdoc = abap_true.  lv_tabl = abap_false.
                  WHEN 'B'. lv_kdoc = abap_true.  lv_tabl = abap_true.
                  WHEN OTHERS. lv_kdoc = abap_false. lv_tabl = abap_true.
                ENDCASE.
              WHEN 'USE_ALIAS'.
                lv_alias = <fs_oc_param>-low.
            ENDCASE.
          ENDLOOP.
        ENDIF.

        IF lv_alias EQ abap_false.
          lv_fieldname = abap_true.
        ENDIF.

        SELECT * INTO TABLE lt_endpoints "#EC CI_NOFIRST.
          FROM zonta_oc_endp
          WHERE domainv       EQ ls_obj_oc-domainv
            AND business_proc EQ ls_obj_oc-business_proc.

        "--- Log WHERE condition blocks if needed ---


        IF v_prlog = 'X'.
          CLEAR v_cont.
          LOOP AT lt_where_cond_tab ASSIGNING <fs_where_cond_tab>.
            ADD 1 TO v_cont.
            CLEAR: v_lm1, v_lm2, v_lm3, v_lm4.
            MOVE 'EVENT_AUT : WHERE_TAB' TO v_lm1.
            MOVE v_cont TO v_lm2.
            MOVE <fs_where_cond_tab>-tablename TO v_lm3.
            LOOP AT <fs_where_cond_tab>-where_tab ASSIGNING <fs_where_tab2>.
              CONCATENATE v_lm4 <fs_where_tab2>-line INTO v_lm4 SEPARATED BY ','.
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
        "----------------------------------------------------------------------
        " Save Log
        "----------------------------------------------------------------------
        READ TABLE lt_relations INDEX 1 INTO ls_relations.

*        data(lv_uuid) = iv_uuid.
        lv_uuid = iv_uuid.
        me->save_log( EXPORTING is_sender          = is_sender
                                iv_event           = i_event
                                iv_dest            = lv_destination
                                is_zonta_relations = ls_relations
                       CHANGING cv_uuid   = lv_uuid ).
        "--- Trigger outbound process via handler ---
        CALL METHOD me->get_relation
          EXPORTING
            iv_domainv        = ls_obj_oc-domainv
            iv_business_proc  = ls_obj_oc-business_proc
            iv_kdoc           = lv_kdoc
            iv_table          = lv_tabl
            iv_key_queue      = lv_key
            iv_dest           = lv_destination
            iv_update         = lv_update
            iv_delete         = lv_delete
            iv_instid         = is_sender-instid
            iv_fieldname      = lv_fieldname
            iv_uuid           = lv_uuid
            it_endpoints      = lt_endpoints
            it_where_cond_tab = lt_where_cond_tab
          EXCEPTIONS
            not_data_found    = 1
            OTHERS            = 2.
        IF sy-subrc <> 0.
          " Add your own error handling
        ELSE.
**FRG 25.07.25 Delete Where table after sent
          CLEAR lt_where_cond_tab[].
        ENDIF.
      ENDIF.
    ENDLOOP.


    "----------------------------------------------------------------------
    " Save Log
    "----------------------------------------------------------------------
    IF lv_uuid IS INITIAL.
      READ TABLE lt_relations INDEX 1 INTO ls_relations.
      me->save_log( EXPORTING is_sender = is_sender
                              iv_event = i_event
*                              iv_status = 'P'
                              is_zonta_relations = ls_relations
                    CHANGING cv_uuid = lv_uuid ).
    ENDIF.
  ENDMETHOD.


  METHOD send_json_any_internal_table.

    DATA lo_handler TYPE REF TO zoncl_oc_any_handler.

    " 1. Set global attributes
    me->set_globals(
      iv_update    = iv_update
      iv_delete    = iv_delete
      iv_domainv   = 'ANY'
      iv_entity    = iv_entity_business_proc
      iv_alias     = iv_alias
      iv_fieldname = iv_fieldname
      iv_bothnames = iv_bothnames
    ).


*    DATA(lo_handler) = NEW zoncl_oc_any_handler( ).
    CREATE OBJECT lo_handler.
    lo_handler->send_json_any_table_ltables(
      EXPORTING
        iv_tabname              = iv_tabname
        iv_aliastab             = iv_aliastab
        iv_update               = iv_update
        iv_delete               = iv_delete
        it_tables_data          = it_tables_data
        iv_structure            = iv_structure
        iv_alias                = iv_alias
        iv_dest                 = iv_dest
        iv_fieldname            = iv_fieldname
        iv_bothnames            = iv_bothnames
        iv_entity_business_proc = iv_entity_business_proc
     IMPORTING
       ev_size                  = ev_size
       ev_records               = ev_records
    ).

    me->clear_globals( ).

  ENDMETHOD.


  METHOD send_json_any_ltable_rap.

    DATA lo_handler TYPE REF TO zoncl_oc_any_handler.

    " 1. Set global attributes
    me->set_globals(
      iv_update    = iv_update
      iv_delete    = iv_delete
      iv_domainv   = 'ANY'
      iv_entity    = iv_entity_business_proc
*      it_where     = it_where
      iv_alias     = iv_alias
      iv_fieldname = iv_fieldname
      iv_bothnames = iv_bothnames
    ).


*    DATA(lo_handler) = NEW zoncl_oc_any_handler( ).
    CREATE OBJECT lo_handler.
    lo_handler->send_json_any_ltables_rap(
      EXPORTING
        iv_tabname              = iv_tabname
        iv_aliastab             = iv_aliastab
        iv_update               = iv_update
        iv_delete               = iv_delete
*       it_where       = it_where
        it_tables_data          = it_tables_data
        iv_alias                = iv_alias
        iv_dest                 = iv_dest
        iv_fieldname            = iv_fieldname
        iv_bothnames            = iv_bothnames
        iv_entity_business_proc = iv_entity_business_proc
    ).

    me->clear_globals( ).

  ENDMETHOD.


  METHOD send_json_any_table.

    DATA lo_handler TYPE REF TO zoncl_oc_any_handler.

    " 1. Set global attributes
    me->set_globals(
      iv_update         = iv_update
      iv_delete         = iv_delete
      iv_domainv        = 'ANY'
      iv_entity         = 'ANY'
      it_where          = it_where
      iv_alias          = iv_alias
      iv_fieldname      = iv_fieldname
      iv_bothnames      = iv_bothnames
    ).


*    DATA(lo_handler) = NEW zoncl_oc_any_handler( ).
    CREATE OBJECT lo_handler.
*BEGIN CECHAVARRIA 19/08/2025
*Validate if it is CDS or DICC and call the method
    IF is_cds_entity( iv_tabname ) = abap_false.
      lo_handler->send_json_any_table(
        EXPORTING
          iv_tabname   = iv_tabname
          iv_aliastab  = iv_aliastab
          iv_update    = iv_update
          iv_delete    = iv_delete
          it_where     = it_where
          iv_alias     = iv_alias
          iv_dest      = iv_dest
          iv_fieldname = iv_fieldname
          iv_bothnames = iv_bothnames
     ).

    ELSE.
      lo_handler->send_json_any_table_cds(
        EXPORTING
          iv_tabname   = iv_tabname
          iv_aliastab  = iv_aliastab
          iv_update    = iv_update
          iv_delete    = iv_delete
          it_where     = it_where
          iv_alias     = iv_alias
          iv_dest      = iv_dest
          iv_fieldname = iv_fieldname
          iv_bothnames = iv_bothnames
     ).
    ENDIF.
*END CECHAVARRIA 19/08/2025

    me->clear_globals( ).

  ENDMETHOD.


  METHOD send_json_any_table_con.

    DATA lo_handler TYPE REF TO zoncl_oc_any_handler.

    " 1. Set global attributes
    me->set_globals(
      iv_update         = iv_update
      iv_delete         = iv_delete
      iv_domainv        = 'ANY'
      iv_entity         = 'ANY'
      it_where          = it_where
      iv_alias          = iv_alias
      iv_fieldname      = iv_fieldname
      iv_bothnames      = iv_bothnames
    ).


*    DATA(lo_handler) = NEW zoncl_oc_any_handler( ).
    CREATE OBJECT lo_handler.
*BEGIN CECHAVARRIA 19/08/2025
*Validate if it is CDS or DICC and call the method
    IF is_cds_entity( iv_tabname ) = abap_false.
      lo_handler->send_json_any_table(
        EXPORTING
          iv_tabname   = iv_tabname
          iv_aliastab  = iv_aliastab
          iv_update    = iv_update
          iv_delete    = iv_delete
          it_where     = it_where
          iv_alias     = iv_alias
          iv_dest      = iv_dest
          iv_fieldname = iv_fieldname
          iv_bothnames = iv_bothnames
     ).

    ELSE.
      lo_handler->send_json_any_table_cds(
        EXPORTING
          iv_tabname   = iv_tabname
          iv_aliastab  = iv_aliastab
          iv_update    = iv_update
          iv_delete    = iv_delete
          it_where     = it_where
          iv_alias     = iv_alias
          iv_dest      = iv_dest
          iv_fieldname = iv_fieldname
          iv_bothnames = iv_bothnames
     ).
    ENDIF.
*END CECHAVARRIA 19/08/2025

    me->clear_globals( ).

  ENDMETHOD.


  METHOD send_json_any_table_cond.

    DATA lo_handler TYPE REF TO zoncl_oc_any_handler.

    " 1. Set global attributes
    me->set_globals(
      iv_update         = iv_update
      iv_delete         = iv_delete
      iv_domainv        = 'ANY'
      iv_entity         = 'ANY'
      it_where          = it_where
      iv_alias          = iv_alias
      iv_fieldname      = iv_fieldname
      iv_bothnames      = iv_bothnames
    ).


*    DATA(lo_handler) = NEW zoncl_oc_any_handler( ).
    CREATE OBJECT lo_handler.
*BEGIN CECHAVARRIA 19/08/2025
*Validate if it is CDS or DICC and call the method
    IF is_cds_entity( iv_tabname ) = abap_false.
      lo_handler->send_json_any_table(
        EXPORTING
          iv_tabname   = iv_tabname
          iv_aliastab  = iv_aliastab
          iv_update    = iv_update
          iv_delete    = iv_delete
          it_where     = it_where
          iv_alias     = iv_alias
          iv_dest      = iv_dest
          iv_fieldname = iv_fieldname
          iv_bothnames = iv_bothnames
     ).

    ELSE.
      lo_handler->send_json_any_table_cds(
        EXPORTING
          iv_tabname   = iv_tabname
          iv_aliastab  = iv_aliastab
          iv_update    = iv_update
          iv_delete    = iv_delete
          it_where     = it_where
          iv_alias     = iv_alias
          iv_dest      = iv_dest
          iv_fieldname = iv_fieldname
          iv_bothnames = iv_bothnames
     ).
    ENDIF.
*END CECHAVARRIA 19/08/2025

    me->clear_globals( ).

  ENDMETHOD.


  METHOD send_json_any_table_price.

    DATA :lt_where2   TYPE zonttrsdswhere.
    DATA : lv_alias   TYPE tabname.
    DATA : lw_alias   TYPE zonta_oc_anyalia.
    DATA : lv_number     TYPE n LENGTH 10,
           lv_returncode TYPE inri-returncode,
           lv_object     TYPE inri-object,
           lt_dfies      TYPE TABLE OF dfies,
           lw_dfies      TYPE dfies,
           lw_col_all    TYPE zonta_oc_col_all.

    DATA:
      is_sender TYPE  sibflporb,
      i_event   TYPE  sibfevent,
      iv_uuid   TYPE  uuid,
      v_dest    TYPE  rfc_dest,
      ls_relations TYPE zonta_relations.

    DATA lv_destination TYPE  zonta_oc_param-low.
    DATA lv_uuid TYPE uuid.
    DATA lo_handler TYPE REF TO zoncl_oc_any_handler.

    lt_where2 = it_where.
    " 1. Set global attributes

    IF iv_knumh IS NOT INITIAL.
      is_sender-instid =  iv_knumh.
      is_sender-typeid =  'R_PRECIOS'.
      is_sender-catid  =  'CL'.
      ls_relations-domainv = 'ANY'.
      ls_relations-business_proc = iv_tabname.

*      SELECT SINGLE low INTO @DATA(lv_destination) FROM zonta_oc_param WHERE name = 'RFC_DESTINATION'.
      SELECT SINGLE low INTO lv_destination FROM zonta_oc_param WHERE name = 'RFC_DESTINATION'.
      v_dest = lv_destination.
*      data(lv_uuid) = iv_uuid.
      lv_uuid = iv_uuid.
      me->save_log( EXPORTING is_sender          = is_sender
                              iv_event           = i_event
                              iv_dest            = v_dest
                              is_zonta_relations = ls_relations
                     CHANGING cv_uuid   = lv_uuid ).


    ENDIF.
    me->set_globals(
      iv_update         = iv_update
      iv_delete         = iv_delete
      iv_domainv        = 'ANY'
      iv_entity         = 'ANY'
      it_where          = lt_where2
      iv_alias          = iv_alias
      iv_uuid           = lv_uuid
      iv_fieldname      = iv_fieldname
      iv_bothnames      = iv_bothnames
    ).


    SELECT SINGLE tabname INTO lv_alias
      FROM zonta_oc_anyalia
      WHERE tabname = iv_tabname.
    IF sy-subrc NE 0.
      EXIT.
    ENDIF.

    SELECT * INTO TABLE gt_columns_all
      FROM zonta_oc_col_all
      WHERE tabname      = iv_tabname.
    IF sy-subrc NE 0.
      EXIT.
    ENDIF.
*    data(lo_handler) = new zoncl_oc_any_handler( ).
    CREATE OBJECT lo_handler.
*BEGIN CECHAVARRIA 19/08/2025
*Validate if it is CDS or DICC and call the method
    IF is_cds_entity( iv_tabname ) = abap_false.
*      lo_handler->send_json_any_table_cond(
      lo_handler->send_json_any_con(
        EXPORTING
          iv_tabname   = iv_tabname
          iv_update    = iv_update
          iv_delete    = iv_delete
          it_where     = lt_where2
          iv_uuid      = lv_uuid
          iv_alias     = iv_alias
          iv_fieldname = iv_fieldname
        IMPORTING
          r_size       = r_size
          r_records     = r_records
      ).
    ENDIF.
*END CECHAVARRIA 19/08/2025

    me->clear_globals( ).

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


    FIELD-SYMBOLS: <fs_info>           TYPE swotrk,
                   <fs_info_hdr>       TYPE swotrk,
                   <fs_oc_param>       TYPE zonta_oc_param,
                   <fs_where_cond_tab> TYPE LINE OF rsds_twhere,
                   <fs_where_tab>      TYPE LINE OF rsds_where_tab.


* Check if debug procedure is active
    me->debug_procedure( ).

    SELECT name
           low
           INTO CORRESPONDING FIELDS OF TABLE lt_params
           FROM zonta_oc_param.
    IF sy-subrc = 0.

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

      IF lv_alias EQ abap_false.
        lv_fieldname = abap_true.
      ENDIF.

      SELECT *
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


  METHOD set_fields_structure.

    FIELD-SYMBOLS: <fs_json_map> TYPE dd03p.

*    CLEAR gt_json_map.
*    REFRESH gt_json_map.

    IF iv_type_name IS INITIAL.
      CALL METHOD me->add_json_field EXPORTING iv_fieldname = 'MESSAGETYPE' iv_tabname = 'PROPERTIES' iv_length = 8.
      CALL METHOD me->add_json_field EXPORTING iv_fieldname = 'CHANGE' iv_tabname = 'PROPERTIES' iv_length = 8.
      CALL METHOD me->add_json_field EXPORTING iv_fieldname = 'DELETE' iv_tabname = 'PROPERTIES' iv_length = 8.
      CALL METHOD me->add_json_field EXPORTING iv_fieldname = 'DOMAIN' iv_tabname = 'PROPERTIES' iv_length = 8.
      CALL METHOD me->add_json_field EXPORTING iv_fieldname = 'ENTITY' iv_tabname = 'PROPERTIES' iv_length = 8.
      CALL METHOD me->add_json_field EXPORTING iv_fieldname = 'DESCRIPTION' iv_tabname = 'PROPERTIES' iv_length = 8.

      IF gs_oc_obj-data = abap_true.
        CALL METHOD me->add_json_field EXPORTING iv_fieldname = 'TAG1' iv_tabname = 'PROPERTIES' iv_length = 5.
        CALL METHOD me->add_json_field EXPORTING iv_fieldname = 'TAG2' iv_tabname = 'PROPERTIES' iv_length = 200.
        CALL METHOD me->add_json_field EXPORTING iv_fieldname = 'TAG3' iv_tabname = 'PROPERTIES' iv_length = 200.
        CALL METHOD me->add_json_field EXPORTING iv_fieldname = 'TAG4' iv_tabname = 'PROPERTIES' iv_length = 200.
        CALL METHOD me->add_json_field EXPORTING iv_fieldname = 'TAG5' iv_tabname = 'PROPERTIES' iv_length = 200.
      ENDIF.


      CALL METHOD me->add_json_field EXPORTING iv_fieldname = 'FIELDNAME' iv_tabname = 'METADATADET' iv_length = 8.
      CALL METHOD me->add_json_field EXPORTING iv_fieldname = 'OFFSET' iv_tabname = 'METADATADET' iv_length = 8.
      CALL METHOD me->add_json_field EXPORTING iv_fieldname = 'LENGHT' iv_tabname = 'METADATADET' iv_length = 8.
      CALL METHOD me->add_json_field EXPORTING iv_fieldname = 'TYPE' iv_tabname = 'METADATADET' iv_length = 8.
      CALL METHOD me->add_json_field EXPORTING iv_fieldname = 'FIELDTEXT' iv_tabname = 'METADATADET' iv_length = 8.
      CALL METHOD me->add_json_field EXPORTING iv_fieldname = 'KEYFLAG' iv_tabname = 'METADATADET' iv_length = 8.
      CALL METHOD me->add_json_field EXPORTING iv_fieldname = 'DECIMALS' iv_tabname = 'METADATADET' iv_length = 8.


    ELSE.
      APPEND INITIAL LINE TO gt_json_map ASSIGNING <fs_json_map>.
      <fs_json_map>-fieldname   = iv_type_field.
      <fs_json_map>-tabname     = iv_type_table.
      <fs_json_map>-ddlanguage  = sy-langu.
      <fs_json_map>-datatype    = iv_type.

      CASE iv_type.
        WHEN 'STRU'.
          <fs_json_map>-mask = 'STRUS'.
          <fs_json_map>-comptype = 'S'.
        WHEN 'TTYP'.
          <fs_json_map>-mask = 'TTYPL'.
          <fs_json_map>-comptype = 'L'.
      ENDCASE.

      <fs_json_map>-rollname = iv_type_name.
    ENDIF.


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
    DATA lv_msg        TYPE  bal_s_msg.

    lv_msg-msgty     = 'S'.
    lv_msg-msgid     = '99'.
    lv_msg-msgno     = '999'.
    lv_msg-msgv1     = i_text1.
    lv_msg-msgv2     = i_text2.
    lv_msg-msgv3     = i_text3.
    lv_msg-msgv4     = i_text4.
    lv_msg-probclass = 2.

    CALL FUNCTION 'BAL_LOG_MSG_ADD' ##FM_SUBRC_OK
      EXPORTING
        i_log_handle     = lv_log_handle
        i_s_msg          = lv_msg
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


  METHOD set_trkorr.
    gv_korrnum = iv_tkorr.
  ENDMETHOD.
ENDCLASS.
