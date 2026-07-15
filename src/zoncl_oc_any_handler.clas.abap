class ZONCL_OC_ANY_HANDLER definition
  public
  inheriting from ZONCL_OC_BASE_HANDLER
  create public .

public section.

  methods SEND_JSON_ANY_LTABLES_RAP
    importing
      !IV_TABNAME type TABNAME
      !IV_ALIASTAB type TABNAME optional
      !IV_UPDATE type BOOLEAN
      !IV_DELETE type BOOLEAN
      !IT_TABLES_DATA type ANY TABLE
      !IV_ALIAS type BOOLEAN default 'X'
      !IV_DEST type RFCDEST optional
      !IV_FIELDNAME type BOOLEAN optional
      !IV_BOTHNAMES type BOOLEAN optional
      !IV_ENTITY_BUSINESS_PROC type ZONTA_OBJ_OC-BUSINESS_PROC .
  methods SEND_JSON_ANY_TABLE_LTABLES
    importing
      !IV_TABNAME type TABNAME
      !IV_ALIASTAB type TABNAME optional
      !IV_UPDATE type BOOLEAN
      !IV_DELETE type BOOLEAN
      !IT_TABLES_DATA type ANY TABLE
      !IV_ALIAS type BOOLEAN default 'X'
      !IV_DEST type RFCDEST optional
      !IV_FIELDNAME type BOOLEAN optional
      !IV_BOTHNAMES type BOOLEAN optional
      !IV_ENTITY_BUSINESS_PROC type ZONTA_OBJ_OC-BUSINESS_PROC
      !IV_STRUCTURE type TABNAME optional
      !IV_ALIASTABLONG type ZONDE_ALIASTAB optional
    exporting
      !EV_SIZE type ZONDE_OC_NUM30
      !EV_RECORDS type ZONDE_OC_NUM30 .
  methods SEND_JSON_ANY_TABLE_CDS
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
  methods SEND_JSON_ANY_CON
    importing
      !IV_TABNAME type TABNAME
      !IV_ALIASTAB type TABNAME optional
      !IV_UPDATE type BOOLEAN
      !IV_DELETE type BOOLEAN
      !IT_WHERE type ZONTTRSDSWHERE optional
      !IV_ALIAS type BOOLEAN default 'X'
      !IV_DEST type RFCDEST optional
      !IV_FIELDNAME type BOOLEAN optional
      !IV_BOTHNAMES type BOOLEAN optional
      !IV_UUID type UUID optional
    exporting
      !R_SIZE type ZONDE_OC_NUM30
      !R_RECORDS type ZONDE_OC_NUM30 .
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
  methods SEND_JSON_ANY_TABLE_COND
    importing
      !IV_TABNAME type TABNAME
      !IV_UPDATE type BOOLEAN
      !IV_DELETE type BOOLEAN
      !IT_WHERE type RSDS_WHERE_TAB optional
      !IV_ALIAS type BOOLEAN optional
      !IV_TABNAMEB type TABNAME .
  methods SEND_JSON_ANY_TABLE_HCM
    importing
      !IV_TABNAME type TABNAME
      !IV_UPDATE type BOOLEAN
      !IV_DELETE type BOOLEAN
      !IT_WHERE type RSDS_WHERE_TAB optional
      !IV_ALIAS type BOOLEAN default 'X' .
  methods RESPON_FM_PARALLEL
    importing
      !P_TASK type CLIKE .

  methods GET_DATA
    redefinition .
  methods ZONIF_OC_DATA_HANDLER~SEND_DATA
    redefinition .
  PROTECTED SECTION.
private section.

  data GV_RETURN type STRING .
  data GV_SIZE type ZONDE_OC_NUM30 .
  data GV_RECORDS_FM type ZONDE_OC_NUM30 .
  data GV_RESPONSE_FM type STRING .
  data GV_MSG1 type STRING .
  data GV_MSG2 type STRING .
  data GV_MSG3 type STRING .
  data GV_MSG4 type STRING .
  data GV_MSG5 type STRING .
  data GV_PROG type SYREPID .
  data GV_SLINE type I .

  methods GET_DATA_PROPERTIES_ANY
    changing
      value(CS_PROPERTIES) type ANY optional .
  methods SET_TABLE_ANY
    importing
      !IT_FCAT type SLIS_T_FIELDCAT_ALV
      !IV_ANYTABLE type BOOLEAN optional
      !IV_ALIAS type BOOLEAN default 'X'
    returning
      value(RT_TABLE) type ref to DATA .
  methods SET_METADATA_NODE_ANY
    importing
      !IT_FCAT type SLIS_T_FIELDCAT_ALV
      !IV_ALIAS type BOOLEAN default 'X'
      !IV_STRUCTURE type TABNAME optional
    changing
      !CT_METADATA type ANY .
  methods SET_KEY_ANY
    importing
      !IT_FCAT type SLIS_T_FIELDCAT_ALV
      !IS_LINE type ANY
      !IV_ALIAS type BOOLEAN default 'X'
    returning
      value(RV_KEY) type STRING .
  methods PRETTY_JSON_ANY
    importing
      !IV_MODE type STRING
    changing
      !CV_JSON type STRING .
  methods SET_WHERE_ANY
    importing
      !IV_ANY type BOOLEAN optional
    returning
      value(R_WHERE) type ZONTTRSDSWHERE .
  methods DEBUG_PROCEDURE .
ENDCLASS.



CLASS ZONCL_OC_ANY_HANDLER IMPLEMENTATION.


  METHOD debug_procedure.

    DATA: ls_param TYPE zonta_oc_param.

    SELECT SINGLE *  INTO ls_param
      FROM zonta_oc_param
      WHERE name = 'DEBUG'.
    IF sy-subrc = 0 AND ls_param-low = 'X'.
      DO. ENDDO.
      WRITE: 'Debug procedure...'.
    ENDIF.

  ENDMETHOD.


  METHOD get_data.
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

    ASSIGN COMPONENT 'MESSAGETYPE' OF STRUCTURE <fs_properties> TO <fs>.    <fs> = gv_messagetype.
    ASSIGN COMPONENT 'CHANGE' OF STRUCTURE <fs_properties> TO <fs>.         <fs> = gv_update.
    ASSIGN COMPONENT 'DELETE' OF STRUCTURE <fs_properties> TO <fs>.         <fs> = gv_delete.
    ASSIGN COMPONENT 'DOMAIN' OF STRUCTURE <fs_properties> TO <fs>.         <fs> = gs_oc_obj-domainv.
    ASSIGN COMPONENT 'ENTITY' OF STRUCTURE <fs_properties> TO <fs>.         <fs> = gs_oc_obj-business_proc.
    ASSIGN COMPONENT 'DESCRIPTION' OF STRUCTURE <fs_properties> TO <fs>.    <fs> = gs_oc_obj-description.

    IF gs_oc_obj-data EQ abap_true.
      ASSIGN COMPONENT 'TAG1' OF STRUCTURE <fs_properties> TO <fs>.         <fs> = gs_oc_obj-tag1.
      ASSIGN COMPONENT 'TAG2' OF STRUCTURE <fs_properties> TO <fs>.         <fs> = gs_oc_obj-tag2.
      ASSIGN COMPONENT 'TAG3' OF STRUCTURE <fs_properties> TO <fs>.         <fs> = gs_oc_obj-tag3.
      ASSIGN COMPONENT 'TAG4' OF STRUCTURE <fs_properties> TO <fs>.         <fs> = gs_oc_obj-tag4.
      ASSIGN COMPONENT 'TAG5' OF STRUCTURE <fs_properties> TO <fs>.         <fs> = gs_oc_obj-tag5.
    ENDIF.

    cs_properties = <fs_properties>.

  ENDMETHOD.


  METHOD pretty_json_any.

    DATA: lv_type_binary TYPE string,
          lv_type_string TYPE string.

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


  METHOD respon_fm_parallel.

    CLEAR: gv_records_fm, gv_return, gv_response_fm, gv_size.

    RECEIVE RESULTS FROM FUNCTION 'ZONFM_ONE_CONNECT_OPENCURSOR' KEEPING TASK
            IMPORTING ev_return   = gv_return
                      ev_size     = gv_size
                      ev_records  = gv_records_fm
                      ev_response = gv_response_fm.
  ENDMETHOD.


  METHOD send_json_any_con.

    CONSTANTS: c_rawstring TYPE c VALUE 'y',
               c_string    TYPE c VALUE 'X',
               c_256       TYPE c LENGTH 6 VALUE '000256',
*BEGIN CECHAVARRIA 19/08/2025
               c_type      TYPE zonta_oc_param-type VALUE 'P',
               c_name      TYPE zonta_oc_param-name VALUE 'OPEN_MAX_RECORDS'.
*END CECHAVARRIA 19/08/2025

    "------------------------------------------------------------
    " Local Data Declarations
    "------------------------------------------------------------
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
          lv_alias2       TYPE zonde_aliastab,
          lw_alias        TYPE zonta_oc_anyalia,
          lv_fields       TYPE string,
          lv_message_v2   TYPE string,
          lv_result       TYPE string,
          lv_exit         TYPE abap_bool,
          lv_error(200)   TYPE c,
          lo_ref          TYPE REF TO cx_sy_dynamic_osql_semantics,
          lo_msg          TYPE REF TO cx_root, "CECHAVARRIA 19/08/2025
          lt_fields       TYPE TABLE OF line,
          lv_tab          TYPE tabname,
          lv_error_stop   TYPE boolean,
          ls_dfies        LIKE LINE OF gt_dfies_tab,
          lv_send         TYPE boolean,
*BEGIN CECHAVARRIA 19/08/2025
          lv_cursor       TYPE cursor,
          lv_pakage       TYPE i,
          lv_count        TYPE i,
          lv_msg          TYPE char120,
          lv_low          TYPE zonta_oc_param-low.
*END CECHAVARRIA 19/08/2025


    DATA: lv_number     TYPE n LENGTH 10,
          lv_returncode TYPE inri-returncode,
          lv_object     TYPE inri-object,
          lt_dfies      TYPE TABLE OF dfies,
          lw_dfies      TYPE dfies,
          lw_col_all    TYPE zonta_oc_col_all.

    "------------------------------------------------------------
    " Field-Symbols
    "------------------------------------------------------------
    FIELD-SYMBOLS: <fs_root>            TYPE any,
                   <fs_oneconnect>      TYPE any,
                   <fs_properties>      TYPE any,
                   <fs_metadata>        TYPE any,
                   <fs_body_root>       TYPE any,
                   <fs_json>            LIKE LINE OF gt_json, "TYPE any,
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
                   <fs_keys_event>      TYPE LINE OF tty_where,
                   <fs_fcat>            LIKE LINE OF lt_fcat.


    "------------------------------------------------------------
    " Initialization and Global Variable Assignment
    "------------------------------------------------------------
    me->debug_procedure( ).

    lv_error_stop  = abap_false.
    gv_update    = iv_update.
    gv_uuid      = iv_uuid.
    gv_delete    = iv_delete.
    gv_anytable  = iv_tabname.
    gv_aliastab  = iv_aliastab.
    gv_alias     = iv_alias."CECHAVARRIA 19/08/2025
    gt_where     = it_where.
    gv_entity    = 'ANY'.
    gv_domainv   = 'ANY'.
    gv_dest      = iv_dest.
    gv_fieldname = iv_fieldname.
    gv_bothnames = iv_bothnames.

    " Log start of processing
    me->append_slg1_log(
      EXPORTING
        iv_tabname    = space
        iv_message_v1 = '*** Any Table Process TABLE***'
        iv_message_v2 = space
        iv_message_v3 = space
        iv_mestyp     = 'S' ).

*BEGIN CECHAVARRIA 19/08/2025
*    IF sy-batch = abap_true.
*      CLEAR: gv_alias.
*      gv_fieldname = abap_true.
*    ENDIF.
***Get parameter for open cursor
**    SELECT SINGLE low
**       INTO lv_low
**       FROM zonta_oc_param
**       WHERE name =  c_name
**          AND type = c_type.
**    IF  sy-subrc EQ 0.
**      lv_pakage = lv_low.
**      IF lv_pakage <= 0.
**        lv_pakage = 1000.
**      ENDIF.
**    ELSE.
**      lv_pakage = 1000.
**    ENDIF.
***END CECHAVARRIA 19/08/2025

    "------------------------------------------------------------
    " Retrieve metadata: columns, ALV field catalog, and DFIES
    "------------------------------------------------------------
    SELECT * INTO TABLE gt_columns_all
      FROM zonta_oc_col_all
      WHERE tabname      = iv_tabname.
*        AND alias_tabname = iv_aliastab.


    IF sy-subrc NE 0.
      CLEAR lv_message_v2.
      lv_message_v2 = gv_entity.

      me->append_slg1_log(
        iv_tabname    = space
        iv_message_v1 = 'No data found in table ZONTA_OC_COL_ALL for entity'
        iv_message_v2 = lv_message_v2
        iv_mestyp     = 'S' ).

      me->update_slg1_log( it_log_ext = gt_log_ext ).
      RETURN.
    ENDIF.

    CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name = iv_tabname
      CHANGING
        ct_fieldcat      = lt_fcat
      EXCEPTIONS
        OTHERS           = 3.

    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname   = iv_tabname
      TABLES
        dfies_tab = gt_dfies_tab
      EXCEPTIONS
        OTHERS    = 3.

    IF sy-subrc <> 0.
      " Handle DFIES error if needed
    ENDIF.


    SORT gt_dfies_tab BY position fieldname.
    SORT lt_fcat BY fieldname.
    LOOP AT gt_dfies_tab INTO ls_dfies.
      READ TABLE lt_fcat ASSIGNING <fs_fcat> WITH KEY fieldname = ls_dfies-fieldname BINARY SEARCH.
      IF sy-subrc NE 0.
        APPEND INITIAL LINE TO lt_fcat ASSIGNING <fs_fcat>.
        MOVE-CORRESPONDING ls_dfies TO <fs_fcat>.
      ENDIF.

      <fs_fcat>-ddic_outputlen = ls_dfies-offset.
      <fs_fcat>-inttype        = ls_dfies-inttype.
      <fs_fcat>-decimals_out   = ls_dfies-decimals.
      <fs_fcat>-col_pos        = ls_dfies-position.
      <fs_fcat>-offset         = ls_dfies-offset.
      <fs_fcat>-outputlen      = ls_dfies-outputlen.

      IF <fs_fcat>-inttype = c_rawstring.
        <fs_fcat>-inttype = c_string.
        <fs_fcat>-ddic_outputlen = c_256.
      ENDIF.

      IF <fs_fcat>-seltext_l IS INITIAL.
        <fs_fcat>-seltext_l = ls_dfies-scrtext_l.
        <fs_fcat>-seltext_m = ls_dfies-scrtext_m.
        <fs_fcat>-seltext_s = ls_dfies-scrtext_s.
      ENDIF.
    ENDLOOP.

    SORT lt_fcat BY row_pos fieldname.

    "------------------------------------------------------------
    " Load base configuration object and destination if missing
    "------------------------------------------------------------
    SELECT SINGLE * INTO gs_oc_obj
      FROM zonta_obj_oc
      WHERE domainv       = 'ANY'
        AND business_proc = 'ANY'.

    IF sy-subrc EQ 0.
**Get parameter for open cursor
* Begin of change Dic2025
      lv_pakage = gs_oc_obj-no_registros.
* End of change Dic2025

      DATA lv_ali TYPE  rvari_val_255.
      DATA lv_ali2 TYPE  rvari_val_255.
      SELECT SINGLE low FROM zonta_oc_param INTO lv_ali WHERE name = 'USE_ALIAS'.
      IF sy-subrc = 0.
        IF lv_ali IS NOT INITIAL.
          SELECT SINGLE alias_tabname INTO lv_alias
            FROM zonta_oc_anyalia
            WHERE tabname = iv_tabname.
        ENDIF.
      ENDIF.
      SELECT SINGLE low FROM zonta_oc_param INTO lv_ali2 WHERE name = 'USE_ALIAS_ANY'.
      IF sy-subrc = 0.
        IF lv_ali2 IS NOT INITIAL.
          SELECT SINGLE alias_tabname INTO lv_alias2
            FROM zonta_oc_anyalia
            WHERE tabname = iv_tabname.
          IF  lv_alias2 IS INITIAL.
            lv_alias2 = iv_tabname.
          ENDIF.
        ENDIF.
      ENDIF.
      IF gv_dest IS INITIAL.
        SELECT SINGLE low INTO gv_dest
          FROM zonta_oc_param
          WHERE name = 'RFC_DESTINATION'
            AND type = 'P'
            AND numb = 1.
      ENDIF.

      IF gv_dest IS NOT INITIAL. "sy-subrc EQ 0.

        "--------------------------------------------------------
        " Create root structure for ONECONNECT export
        "--------------------------------------------------------
        IF gs_oc_obj-data EQ abap_true.
          CREATE DATA dref_table_root TYPE ty_oneconnect_meta.
        ELSE.
          CREATE DATA dref_table_root TYPE ty_oneconnect.
        ENDIF.

        ASSIGN dref_table_root->* TO <fs_root>.
        ASSIGN COMPONENT 'ONECONNECT' OF STRUCTURE <fs_root> TO <fs_oneconnect>.
        ASSIGN COMPONENT 'PROPERTIES' OF STRUCTURE <fs_oneconnect> TO <fs_properties>.

        " Fill PROPERTIES node
        me->get_data_properties_any( CHANGING cs_properties = <fs_properties> ).

        ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_oneconnect> TO <fs_metadata_root>.
        APPEND INITIAL LINE TO <fs_metadata_root> ASSIGNING <fs_metadata>.
        ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_metadata> TO <fs_field_metadata>.

        " Set metadata field label (alias or table name)
*        IF iv_fieldname IS INITIAL.
        IF gv_fieldname IS INITIAL.
          IF NOT iv_bothnames IS INITIAL.
            <fs_field_metadata> = iv_tabname && '_' && lv_alias.
          ELSEIF NOT lv_alias IS INITIAL.
            <fs_field_metadata> = lv_alias.
          ELSEIF NOT lv_alias2 IS INITIAL.
            <fs_field_metadata> = lv_alias2.
          ELSE.
            <fs_field_metadata> = iv_tabname.
          ENDIF.
        ELSE.
          IF lv_ali2 IS INITIAL.
            <fs_field_metadata> = iv_tabname.
          ELSE.
            <fs_field_metadata> = lv_alias2.
          ENDIF.
        ENDIF.

        ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_metadata> TO <fs_metadata_line>.
        ASSIGN COMPONENT 'BODY' OF STRUCTURE <fs_oneconnect> TO <fs_body_root>.
        ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_body_root> TO <fs_field>.

        " Set field name for BODY node
*        IF iv_fieldname IS INITIAL.
        IF gv_fieldname IS INITIAL AND lv_ali2 IS INITIAL.
          IF NOT iv_bothnames IS INITIAL.
            <fs_field> = iv_tabname && '_' && lv_alias.
          ELSEIF NOT lv_alias IS INITIAL.
            <fs_field> = lv_alias.
          ELSEIF NOT lv_alias2 IS INITIAL.
            <fs_field> = lv_alias2.
          ELSE.
            <fs_field> = iv_tabname.
          ENDIF.
        ELSE.
          IF lv_ali2 IS INITIAL.
            <fs_field> = iv_tabname.
          ELSE.
            <fs_field> = lv_alias2.
          ENDIF.
        ENDIF.

        ASSIGN COMPONENT 'DATA' OF STRUCTURE <fs_body_root> TO <fs_table_body_line>.

        "--------------------------------------------------------
        " Create dynamic tables for BODY and result data
        "--------------------------------------------------------
        CALL METHOD me->set_table_any
          EXPORTING
            iv_alias = gv_alias
            it_fcat  = lt_fcat
          RECEIVING
            rt_table = <fs_table_body_line>.

        ASSIGN <fs_table_body_line>->* TO <fs_body>.

        CALL METHOD me->set_table_any
          EXPORTING
            iv_alias = gv_alias "iv_fieldname CHECK
            it_fcat  = lt_fcat
          RECEIVING
            rt_table = lo_data.

        ASSIGN lo_data->* TO <fs_table>.

        "--------------------------------------------------------
        " Compose WHERE and SELECT fields
        "--------------------------------------------------------
*      lv_fields = me->set_fields( iv_alias = iv_alias ).


        IF gt_where IS INITIAL.
          lv_where = me->set_where_any( iv_any = abap_true ).
          me->set_process( IMPORTING ev_closed = lv_exit ).
          IF lv_exit EQ abap_true.
            RETURN.
          ENDIF.
          gt_where = lv_where.
        ELSE.
          lv_where = gt_where.
        ENDIF.

        IF lv_where IS INITIAL.
          MESSAGE i000(fb) WITH 'No filter selected'.
          RETURN.
        ENDIF.

        "--------------------------------------------------------
        " Run as Background Batch if Configured
        "--------------------------------------------------------
*BEGIN CECHAVARRIA 19/08/2025
        IF NOT gv_batch IS INITIAL.
          me->execute_batch(
            EXPORTING
              iv_anytab  = abap_true
              iv_tabname = iv_tabname ).
          RETURN.
        ENDIF.
*END CECHAVARRIA 19/08/2025
        "--------------------------------------------------------
        " Fill METADATA node
        "--------------------------------------------------------
        me->set_metadata_node_any(
          EXPORTING
*            iv_alias    = iv_fieldname
            iv_alias    = gv_fieldname
            it_fcat     = lt_fcat
          CHANGING
            ct_metadata = <fs_metadata_line> ).

        "--------------------------------------------------------
        " Fetch Data Dynamically (CDS or Transparent Table)
        "--------------------------------------------------------
        TRY.
*BEGIN CECHAVARRIA 19/08/2025
*              lv_fields = me->set_fields( iv_alias = iv_alias ).
            lv_fields = me->set_fields( iv_alias = gv_alias ).
            OPEN CURSOR WITH HOLD lv_cursor FOR SELECT (lv_fields)  FROM (iv_tabname) WHERE (lv_where).
*            ENDIF.
*END CECHAVARRIA 19/08/2025

            IF sy-subrc NE 0.
              MESSAGE i000(fb) WITH 'No data found'.

              me->append_slg1_log(
                EXPORTING
                  iv_tabname    = space
                  iv_message_v1 = 'No data found'
                  iv_message_v2 = space
                  iv_message_v3 = space
                  iv_mestyp     = 'S' ).
              me->send_json_result( ).
              RETURN.
            ENDIF.

          CATCH cx_sy_dynamic_osql_semantics INTO lo_ref.
            lv_result = lo_ref->get_text( ).
            lv_error  = lv_result.

            sy-msgv1 = lv_error+0(50).
            sy-msgv2 = lv_error+50(50).
            sy-msgv3 = lv_error+100(50).
            sy-msgv4 = lv_error+150(50).

            gs_elog-type       = 'SEND_JSON_ANY_TABLE'.
            gs_elog-severity   = gc_error.
            gs_elog-message    = lo_msg->get_longtext( ).
            CALL METHOD lo_msg->get_source_position
              IMPORTING
                program_name = gv_prog
                source_line  = gv_sline.
            gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
            gs_elog-details-db = 'ZONCL_OC_ANY_HANDLER-SEND_JSON_ANY_TABLE'.
            gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.


            gs_elog-metadata-error_code = gs_elog-details-error_code.
            interpret_message( EXPORTING iv_msgnr = '097' iv_msgv1 = iv_tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '098' iv_msgv1 = iv_tabname  IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '099' iv_msgv1 = iv_tabname  IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '100'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '101'  IMPORTING ev_message = gv_msg5 CHANGING ct_table = gt_causes ).
            CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 gv_msg5 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
            interpret_message( EXPORTING iv_msgnr = '076'  iv_msgv1 = iv_tabname IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '086'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '087'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_fixes ).
            CONCATENATE gv_msg1 gv_msg2 gv_msg3 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.
            print_error_otel( ).
            send_json_error( ).

*            MESSAGE i000(fb) WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*            me->send_json_result( ).
            lv_error_stop = abap_true.
        ENDTRY.

        CHECK lv_error_stop = abap_false.


        "--------------------------------------------------------
        " Loop over selected data and build JSON objects
        "--------------------------------------------------------
*BEGIN CECHAVARRIA 19/08/2025
        CLEAR lv_count.
        DO.
          lv_count = sy-index.
          TRY.
              FETCH NEXT CURSOR lv_cursor
                INTO CORRESPONDING FIELDS OF TABLE <fs_table> PACKAGE SIZE lv_pakage.

              IF sy-subrc NE 0.
                CLOSE CURSOR lv_cursor.
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
              CLOSE CURSOR lv_cursor.
              lv_result = lo_msg->get_text( ).
              lv_error  = lv_result.

              sy-msgv1 = lv_error+0(50).
              sy-msgv2 = lv_error+50(50).
              sy-msgv3 = lv_error+100(50).
              sy-msgv4 = lv_error+150(50).

              gs_elog-type       = 'SEND_JSON_ANY_CON'.
              gs_elog-severity   = gc_error.
              gs_elog-message    = lo_msg->get_longtext( ).
              CALL METHOD lo_msg->get_source_position
                IMPORTING
                  program_name = gv_prog
                  source_line  = gv_sline.
              gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
              gs_elog-details-db = 'ZONCL_OC_ANY_HANDLER-SEND_JSON_ANY_CON'.
              gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.


              gs_elog-metadata-error_code = gs_elog-details-error_code.
              interpret_message( EXPORTING iv_msgnr = '097' iv_msgv1 = iv_tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
              interpret_message( EXPORTING iv_msgnr = '098' iv_msgv1 = iv_tabname  IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
              interpret_message( EXPORTING iv_msgnr = '099' iv_msgv1 = iv_tabname  IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
              interpret_message( EXPORTING iv_msgnr = '100'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
              interpret_message( EXPORTING iv_msgnr = '101'  IMPORTING ev_message = gv_msg5 CHANGING ct_table = gt_causes ).
              CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 gv_msg5 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
              interpret_message( EXPORTING iv_msgnr = '076'  iv_msgv1 = iv_tabname IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_fixes ).
              interpret_message( EXPORTING iv_msgnr = '086'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_fixes ).
              interpret_message( EXPORTING iv_msgnr = '087'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_fixes ).
              CONCATENATE gv_msg1 gv_msg2 gv_msg3 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.
              print_error_otel( ).
              send_json_error( ).

*              MESSAGE i000(fb) WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*              me->send_json_result( ).
              EXIT.
          ENDTRY.
*END CECHAVARRIA 19/08/2025
          gs_log_json_result-recordst = gs_log_json_result-recordst + lv_recordst.
          gs_log_json_result-recordst = gs_log_json_result-recordst + lv_recordst.

          CLEAR lt_keys.

          lv_send = abap_false.
          LOOP AT <fs_table> ASSIGNING <fs_data>.
            CLEAR lt_keys.

            " Generate key from line content
            CALL METHOD me->set_key_any
              EXPORTING
*               iv_alias = iv_alias
                iv_alias = gv_alias
                it_fcat  = lt_fcat
                is_line  = <fs_data>
              RECEIVING
                rv_key   = lv_key.

            ASSIGN lv_key TO <fs_key>.

            " Track new keys to count records
            IF lv_keys_temp NE lv_key.
              lv_keys_temp   = lv_key.
              lv_max_records = lv_max_records + 1.
*              gv_recordst_obj = gv_recordst_obj + 1.
              gs_log_json_result-recordst_obj = gs_log_json_result-recordst_obj + 1.
            ENDIF.

            " Log key to application log
            me->append_slg1_log(
              iv_tabname = iv_tabname
              iv_mestyp  = 'S'
              iv_key     = lv_key ).

            " Add line to body node
            APPEND INITIAL LINE TO <fs_body> ASSIGNING <fs_line>.
            MOVE-CORRESPONDING <fs_data> TO <fs_line>.

            " Apply conversion exit for display format
            me->conversion_exit(
              EXPORTING
                iv_tabname = iv_tabname
              CHANGING
                cs_string  = <fs_line> ).

            " Add event ID if configured
            IF gs_oc_obj-eventid  = abap_true OR
               gs_oc_obj-metadata = abap_true.

              IF <fs_key> IS ASSIGNED.
                APPEND INITIAL LINE TO lt_keys ASSIGNING <fs_keys_event>.
                <fs_keys_event>-line = <fs_key>.
              ENDIF.

              me->get_eventid(
                EXPORTING
                  it_keys      = lt_keys
                CHANGING
                  cs_line_json = <fs_line> ).
            ENDIF.

            " Serialize and send when reaching max records per message
            IF lv_max_records EQ gs_oc_obj-no_registros.
              APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
              <fs_json>-json_id = gv_jsonid.
              <fs_json>-json =  zoncl_ui2_cl_json=>serialize(
                    data             = <fs_root>
                    compress         = abap_false
                    assoc_arrays     = abap_true
                    assoc_arrays_opt = abap_true
                    pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).

              " Replace technical strings for compatibility
              REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
              REPLACE 'TABL'        WITH 'TABLE'        INTO <fs_json>-json.
              gv_jsonid = gv_jsonid + 1.
              CLEAR: lv_max_records, <fs_body>.
              lv_send = abap_true.
            ENDIF.
          ENDLOOP.

          "--------------------------------------------------------
          " Serialize remaining records if limit not reached
          "--------------------------------------------------------
          IF lv_max_records LT gs_oc_obj-no_registros AND lv_send = abap_false.
            IF lv_max_records = 0000."CECHAVARRIA 19/08/2025
              APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
              DELETE gt_json WHERE json IS INITIAL. "table_line = space."CECHAVARRIA 19/08/2025
              IF sy-subrc NE 0.
                <fs_json>-json_id = gv_jsonid.
                <fs_json>-json =  zoncl_ui2_cl_json=>serialize(
                        data             = <fs_root>
                        compress         = abap_false
                        assoc_arrays     = abap_true
                        assoc_arrays_opt = abap_true
                        pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).

                REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
                REPLACE 'TABL'        WITH 'TABLE'        INTO <fs_json>-json.
              ENDIF.
            ELSE."CECHAVARRIA 19/08/2025
              APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
              <fs_json>-json_id = gv_jsonid.
              <fs_json>-json =  zoncl_ui2_cl_json=>serialize(
                    data             = <fs_root>
                    compress         = abap_false
                    assoc_arrays     = abap_true
                    assoc_arrays_opt = abap_true
                    pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).

              REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
              REPLACE 'TABL'        WITH 'TABLE'        INTO <fs_json>-json.
              EXIT.
            ENDIF."CECHAVARRIA 19/08/2025
          ENDIF.
        ENDDO.

        "--------------------------------------------------------
        " Send each JSON payload and track result
        "--------------------------------------------------------
        LOOP AT gt_json INTO gs_json.

          gv_json = gs_json-json.
          gv_jsonid = gs_json-json_id.

*            IF gv_recordst_obj IS INITIAL.
*              gv_recordst_obj = 1.
*            ENDIF.
          IF gs_log_json_result-recordst_obj IS INITIAL.
            gs_log_json_result-recordst_obj = 1.
          ENDIF.

          me->pretty_json_any(
            EXPORTING
              iv_mode = c_table
            CHANGING
              cv_json = gv_json ).

*            IF sy-batch = abap_true.
*              me->send_json_http_con(
*                EXPORTING
*                  i_dest     = gv_dest
*                IMPORTING
*                  e_return   = lv_return
*                  e_size     = e_size
*                  e_records  = e_records
*                  e_response = lv_response ).
*            ELSE.
          me->send_json_http_con_rap(
              EXPORTING
                i_dest     = gv_dest
              IMPORTING
                e_return   = lv_return
                e_size     = e_size
                e_records  = e_records
                e_response = lv_response ).



*BEGIN CECHAVARRIA 28/08/2025
          IF me->gv_uuid IS NOT INITIAL.
            IF  e_size IS NOT INITIAL.
              me->update_table_json(
                iv_json    = gv_json
                iv_uuid    = me->gv_uuid
                iv_message = lv_response
                iv_status_code  = 'P'
              ).
            ELSE.
              me->update_table_json(
                iv_json    = gv_json
                iv_uuid    = me->gv_uuid
                iv_message = lv_response
                iv_status_code  = 'E'
              ).
            ENDIF.
          ENDIF.

*          gv_sizet    = gv_sizet + e_size.
*          gv_recordst = gv_recordst + 1.
          gs_log_json_result-sizet    = gs_log_json_result-sizet + e_size.
          gs_log_json_result-recordst = gs_log_json_result-recordst + 1.
        ENDLOOP.
        gv_jsonid = gv_jsonid + 1.
* *BEGIN CECHAVARRIA 19/08/2025
        CLEAR: gt_json[], lv_max_records, <fs_body>.

*END CECHAVARRIA 19/08/2025
        "--------------------------------------------------------
        " Finalize logging and output
        "--------------------------------------------------------
*        me->send_json_result( ).
        me->update_slg1_log( it_log_ext = gt_log_ext ).
*        r_size    = gv_sizet.
*        r_records = gv_recordst.
        r_size    = gs_log_json_result-sizet.
        r_records = gs_log_json_result-recordst.
      ENDIF.
    ELSE.
      CLEAR lv_message_v2.
      lv_message_v2 = gv_entity.

      me->append_slg1_log(
        iv_tabname    = space
        iv_message_v1 = 'No data found in table ZONTA_OBJ_OC for entity'
        iv_message_v2 = lv_message_v2
        iv_mestyp     = 'S' ).

      me->update_slg1_log( it_log_ext = gt_log_ext ).
    ENDIF.

  ENDMETHOD.

**  METHOD send_json_any_con.
**
**    CONSTANTS: c_rawstring TYPE c VALUE 'y',
**               c_string    TYPE c VALUE 'X',
**               c_256       TYPE c LENGTH 6 VALUE '000256',
***BEGIN CECHAVARRIA 19/08/2025
**               c_type      TYPE zonta_oc_param-type VALUE 'P',
**               c_name      TYPE zonta_oc_param-name VALUE 'OPEN_MAX_RECORDS'.
***END CECHAVARRIA 19/08/2025
**
**    "------------------------------------------------------------
**    " Local Data Declarations
**    "------------------------------------------------------------
**    DATA: dref_table_root TYPE REF TO data,
**          dref_table      TYPE REF TO data,
**          lo_table        TYPE REF TO data,
**          lo_data         TYPE REF TO data,
**          lt_fcat         TYPE slis_t_fieldcat_alv,
**          e_size          TYPE zonde_oc_num30,
**          e_records       TYPE zonde_oc_num30,
**          lt_keys         TYPE tty_where,
**          lv_return       TYPE string,
**          lv_recordst     TYPE sy-tabix,
**          lv_response     TYPE string,
**          lv_key          TYPE string,
**          lv_keys_temp    TYPE string,
**          lv_max_records  TYPE zonde_registrosn,
**          lv_where        TYPE rsds_where_tab,
**          lv_alias        TYPE zonde_aliastab,
**          lv_alias2       TYPE zonde_aliastab,
**          lw_alias        TYPE zonta_oc_anyalia,
**          lv_fields       TYPE string,
**          lv_message_v2   TYPE string,
**          lv_result       TYPE string,
**          lv_exit         TYPE abap_bool,
**          lv_error(200)   TYPE c,
**          lo_ref          TYPE REF TO cx_sy_dynamic_osql_semantics,
**          lo_msg          TYPE REF TO cx_root, "CECHAVARRIA 19/08/2025
**          lt_fields       TYPE TABLE OF line,
**          lv_tab          TYPE tabname,
**          lv_error_stop   TYPE boolean,
**          ls_dfies        LIKE LINE OF gt_dfies_tab,
**          lv_send         TYPE boolean,
***BEGIN CECHAVARRIA 19/08/2025
**          lv_cursor       TYPE cursor,
**          lv_pakage       TYPE i,
**          lv_count        TYPE i,
**          lv_msg          TYPE char120,
**          lv_low          TYPE zonta_oc_param-low.
***END CECHAVARRIA 19/08/2025
**
**
**    DATA: lv_number     TYPE n LENGTH 10,
**          lv_returncode TYPE inri-returncode,
**          lv_object     TYPE inri-object,
**          lt_dfies      TYPE TABLE OF dfies,
**          lw_dfies      TYPE dfies,
**          lw_col_all    TYPE zonta_oc_col_all.
**
**    "------------------------------------------------------------
**    " Field-Symbols
**    "------------------------------------------------------------
**    FIELD-SYMBOLS: <fs_root>            TYPE any,
**                   <fs_oneconnect>      TYPE any,
**                   <fs_properties>      TYPE any,
**                   <fs_metadata>        TYPE any,
**                   <fs_body_root>       TYPE any,
**                   <fs_json>            LIKE LINE OF gt_json, "TYPE any,
**                   <fs_field_metadata>  TYPE any,
**                   <fs_metadata_line>   TYPE any,
**                   <fs_field>           TYPE any,
**                   <fs_line>            TYPE any,
**                   <fs_table_body_line> TYPE any,
**                   <fs_body>            TYPE STANDARD TABLE,
**                   <fs_metadata_root>   TYPE STANDARD TABLE,
**                   <fs_table>           TYPE STANDARD TABLE,
**                   <fs_table2>          TYPE ANY TABLE,
**                   <fs_data>            TYPE any,
**                   <fs_table_line>      TYPE any,
**                   <fs_key>             TYPE any,
**                   <fs_key_main>        TYPE any,
**                   <fs_keys_event>      TYPE LINE OF tty_where,
**                   <fs_fcat>            LIKE LINE OF lt_fcat.
**
**
**    "------------------------------------------------------------
**    " Initialization and Global Variable Assignment
**    "------------------------------------------------------------
**    me->debug_procedure( ).
**
**    lv_error_stop  = abap_false.
**    gv_update    = iv_update.
**    gv_uuid      = iv_uuid.
**    gv_delete    = iv_delete.
**    gv_anytable  = iv_tabname.
**    gv_aliastab  = iv_aliastab.
**    gv_alias     = iv_alias."CECHAVARRIA 19/08/2025
**    gt_where     = it_where.
**    gv_entity    = 'ANY'.
**    gv_domainv   = 'ANY'.
**    gv_dest      = iv_dest.
**    gv_fieldname = iv_fieldname.
**    gv_bothnames = iv_bothnames.
**
**    " Log start of processing
**    me->append_slg1_log(
**      EXPORTING
**        iv_tabname    = space
**        iv_message_v1 = '*** Any Table Process TABLE***'
**        iv_message_v2 = space
**        iv_message_v3 = space
**        iv_mestyp     = 'S' ).
**
***BEGIN CECHAVARRIA 19/08/2025
***    IF sy-batch = abap_true.
***      CLEAR: gv_alias.
***      gv_fieldname = abap_true.
***    ENDIF.
*****Get parameter for open cursor
****    SELECT SINGLE low
****       INTO lv_low
****       FROM zonta_oc_param
****       WHERE name =  c_name
****          AND type = c_type.
****    IF  sy-subrc EQ 0.
****      lv_pakage = lv_low.
****      IF lv_pakage <= 0.
****        lv_pakage = 1000.
****      ENDIF.
****    ELSE.
****      lv_pakage = 1000.
****    ENDIF.
*****END CECHAVARRIA 19/08/2025
**
**    "------------------------------------------------------------
**    " Retrieve metadata: columns, ALV field catalog, and DFIES
**    "------------------------------------------------------------
**    SELECT * INTO TABLE gt_columns_all
**      FROM zonta_oc_col_all
**      WHERE tabname      = iv_tabname.
***        AND alias_tabname = iv_aliastab.
**
**
**    IF sy-subrc NE 0.
**      CLEAR lv_message_v2.
**      lv_message_v2 = gv_entity.
**
**      me->append_slg1_log(
**        iv_tabname    = space
**        iv_message_v1 = 'No data found in table ZONTA_OC_COL_ALL for entity'
**        iv_message_v2 = lv_message_v2
**        iv_mestyp     = 'S' ).
**
**      me->update_slg1_log( it_log_ext = gt_log_ext ).
**      RETURN.
**    ENDIF.
**
**    CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
**      EXPORTING
**        i_structure_name = iv_tabname
**      CHANGING
**        ct_fieldcat      = lt_fcat
**      EXCEPTIONS
**        OTHERS           = 3.
**
**    CALL FUNCTION 'DDIF_FIELDINFO_GET'
**      EXPORTING
**        tabname   = iv_tabname
**      TABLES
**        dfies_tab = gt_dfies_tab
**      EXCEPTIONS
**        OTHERS    = 3.
**
**    IF sy-subrc <> 0.
**      " Handle DFIES error if needed
**    ENDIF.
**
**
**    SORT gt_dfies_tab BY position fieldname.
**    SORT lt_fcat BY fieldname.
**    LOOP AT gt_dfies_tab INTO ls_dfies.
**      READ TABLE lt_fcat ASSIGNING <fs_fcat> WITH KEY fieldname = ls_dfies-fieldname BINARY SEARCH.
**      IF sy-subrc NE 0.
**        APPEND INITIAL LINE TO lt_fcat ASSIGNING <fs_fcat>.
**        MOVE-CORRESPONDING ls_dfies TO <fs_fcat>.
**      ENDIF.
**
**      <fs_fcat>-ddic_outputlen = ls_dfies-offset.
**      <fs_fcat>-inttype        = ls_dfies-inttype.
**      <fs_fcat>-decimals_out   = ls_dfies-decimals.
**      <fs_fcat>-col_pos        = ls_dfies-position.
**      <fs_fcat>-offset         = ls_dfies-offset.
**      <fs_fcat>-outputlen      = ls_dfies-outputlen.
**
**      IF <fs_fcat>-inttype = c_rawstring.
**        <fs_fcat>-inttype = c_string.
**        <fs_fcat>-ddic_outputlen = c_256.
**      ENDIF.
**
**      IF <fs_fcat>-seltext_l IS INITIAL.
**        <fs_fcat>-seltext_l = ls_dfies-scrtext_l.
**        <fs_fcat>-seltext_m = ls_dfies-scrtext_m.
**        <fs_fcat>-seltext_s = ls_dfies-scrtext_s.
**      ENDIF.
**    ENDLOOP.
**
**    SORT lt_fcat BY row_pos fieldname.
**
**    "------------------------------------------------------------
**    " Load base configuration object and destination if missing
**    "------------------------------------------------------------
**    SELECT SINGLE * INTO gs_oc_obj
**      FROM zonta_obj_oc
**      WHERE domainv       = 'ANY'
**        AND business_proc = 'ANY'.
**
**    IF sy-subrc EQ 0.
****Get parameter for open cursor
*** Begin of change Dic2025
**      lv_pakage = gs_oc_obj-no_registros.
*** End of change Dic2025
**
**      DATA lv_ali TYPE  rvari_val_255.
**      DATA lv_ali2 TYPE  rvari_val_255.
**      SELECT SINGLE low FROM zonta_oc_param INTO lv_ali WHERE name = 'USE_ALIAS'.
**      IF sy-subrc = 0.
**        IF lv_ali IS NOT INITIAL.
**          SELECT SINGLE alias_tabname INTO lv_alias
**            FROM zonta_oc_anyalia
**            WHERE tabname = iv_tabname.
**        ENDIF.
**      ENDIF.
**      SELECT SINGLE low FROM zonta_oc_param INTO lv_ali2 WHERE name = 'USE_ALIAS_ANY'.
**      IF sy-subrc = 0.
**        IF lv_ali2 IS NOT INITIAL.
**          SELECT SINGLE alias_tabname INTO lv_alias2
**            FROM zonta_oc_anyalia
**            WHERE tabname = iv_tabname.
**          IF  lv_alias2 IS INITIAL.
**            lv_alias2 = iv_tabname.
**          ENDIF.
**        ENDIF.
**      ENDIF.
**      IF gv_dest IS INITIAL.
**        SELECT SINGLE low INTO gv_dest
**          FROM zonta_oc_param
**          WHERE name = 'RFC_DESTINATION'
**            AND type = 'P'
**            AND numb = 1.
**      ENDIF.
**
**      IF sy-subrc EQ 0.
**
**        "--------------------------------------------------------
**        " Create root structure for ONECONNECT export
**        "--------------------------------------------------------
**        IF gs_oc_obj-data EQ abap_true.
**          CREATE DATA dref_table_root TYPE ty_oneconnect_meta.
**        ELSE.
**          CREATE DATA dref_table_root TYPE ty_oneconnect.
**        ENDIF.
**
**        ASSIGN dref_table_root->* TO <fs_root>.
**        ASSIGN COMPONENT 'ONECONNECT' OF STRUCTURE <fs_root> TO <fs_oneconnect>.
**        ASSIGN COMPONENT 'PROPERTIES' OF STRUCTURE <fs_oneconnect> TO <fs_properties>.
**
**        " Fill PROPERTIES node
**        me->get_data_properties_any( CHANGING cs_properties = <fs_properties> ).
**
**        ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_oneconnect> TO <fs_metadata_root>.
**        APPEND INITIAL LINE TO <fs_metadata_root> ASSIGNING <fs_metadata>.
**        ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_metadata> TO <fs_field_metadata>.
**
**        " Set metadata field label (alias or table name)
***        IF iv_fieldname IS INITIAL.
**        IF gv_fieldname IS INITIAL.
**          IF NOT iv_bothnames IS INITIAL.
**            <fs_field_metadata> = iv_tabname && '_' && lv_alias.
**          ELSEIF NOT lv_alias IS INITIAL.
**            <fs_field_metadata> = lv_alias.
**          ELSEIF NOT lv_alias2 IS INITIAL.
**            <fs_field_metadata> = lv_alias2.
**          ELSE.
**            <fs_field_metadata> = iv_tabname.
**          ENDIF.
**        ELSE.
**          IF lv_ali2 IS INITIAL.
**            <fs_field_metadata> = iv_tabname.
**          ELSE.
**            <fs_field_metadata> = lv_alias2.
**          ENDIF.
**        ENDIF.
**
**        ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_metadata> TO <fs_metadata_line>.
**        ASSIGN COMPONENT 'BODY' OF STRUCTURE <fs_oneconnect> TO <fs_body_root>.
**        ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_body_root> TO <fs_field>.
**
**        " Set field name for BODY node
***        IF iv_fieldname IS INITIAL.
**        IF gv_fieldname IS INITIAL AND lv_ali2 IS INITIAL.
**          IF NOT iv_bothnames IS INITIAL.
**            <fs_field> = iv_tabname && '_' && lv_alias.
**          ELSEIF NOT lv_alias IS INITIAL.
**            <fs_field> = lv_alias.
**          ELSEIF NOT lv_alias2 IS INITIAL.
**            <fs_field> = lv_alias2.
**          ELSE.
**            <fs_field> = iv_tabname.
**          ENDIF.
**        ELSE.
**          IF lv_ali2 IS INITIAL.
**            <fs_field> = iv_tabname.
**          ELSE.
**            <fs_field> = lv_alias2.
**          ENDIF.
**        ENDIF.
**
**        ASSIGN COMPONENT 'DATA' OF STRUCTURE <fs_body_root> TO <fs_table_body_line>.
**
**        "--------------------------------------------------------
**        " Create dynamic tables for BODY and result data
**        "--------------------------------------------------------
**        CALL METHOD me->set_table_any
**          EXPORTING
**            iv_alias = gv_alias
**            it_fcat  = lt_fcat
**          RECEIVING
**            rt_table = <fs_table_body_line>.
**
**        ASSIGN <fs_table_body_line>->* TO <fs_body>.
**
**        CALL METHOD me->set_table_any
**          EXPORTING
**            iv_alias = gv_alias "iv_fieldname CHECK
**            it_fcat  = lt_fcat
**          RECEIVING
**            rt_table = lo_data.
**
**        ASSIGN lo_data->* TO <fs_table>.
**
**        "--------------------------------------------------------
**        " Compose WHERE and SELECT fields
**        "--------------------------------------------------------
***      lv_fields = me->set_fields( iv_alias = iv_alias ).
**
**
**        IF gt_where IS INITIAL.
**          lv_where = me->set_where_any( iv_any = abap_true ).
**          me->set_process( IMPORTING ev_closed = lv_exit ).
**          IF lv_exit EQ abap_true.
**            RETURN.
**          ENDIF.
**          gt_where = lv_where.
**        ELSE.
**          lv_where = gt_where.
**        ENDIF.
**
**        IF lv_where IS INITIAL.
**          MESSAGE i000(fb) WITH 'No filter selected'.
**          RETURN.
**        ENDIF.
**
**        "--------------------------------------------------------
**        " Run as Background Batch if Configured
**        "--------------------------------------------------------
***BEGIN CECHAVARRIA 19/08/2025
**        IF NOT gv_batch IS INITIAL.
**          me->execute_batch(
**            EXPORTING
**              iv_anytab  = abap_true
**              iv_tabname = iv_tabname ).
**          RETURN.
**        ENDIF.
***END CECHAVARRIA 19/08/2025
**        "--------------------------------------------------------
**        " Fill METADATA node
**        "--------------------------------------------------------
**        me->set_metadata_node_any(
**          EXPORTING
***            iv_alias    = iv_fieldname
**            iv_alias    = gv_fieldname
**            it_fcat     = lt_fcat
**          CHANGING
**            ct_metadata = <fs_metadata_line> ).
**
**        "--------------------------------------------------------
**        " Fetch Data Dynamically (CDS or Transparent Table)
**        "--------------------------------------------------------
**        TRY.
***BEGIN CECHAVARRIA 19/08/2025
***              lv_fields = me->set_fields( iv_alias = iv_alias ).
**            lv_fields = me->set_fields( iv_alias = gv_alias ).
**            OPEN CURSOR WITH HOLD lv_cursor FOR SELECT (lv_fields)  FROM (iv_tabname) WHERE (lv_where).
***            ENDIF.
***END CECHAVARRIA 19/08/2025
**
**            IF sy-subrc NE 0.
**              MESSAGE i000(fb) WITH 'No data found'.
**
**              me->append_slg1_log(
**                EXPORTING
**                  iv_tabname    = space
**                  iv_message_v1 = 'No data found'
**                  iv_message_v2 = space
**                  iv_message_v3 = space
**                  iv_mestyp     = 'S' ).
**              me->send_json_result( ).
**              RETURN.
**            ENDIF.
**
**          CATCH cx_sy_dynamic_osql_semantics INTO lo_ref.
**            lv_result = lo_ref->get_text( ).
**            lv_error  = lv_result.
**
**            sy-msgv1 = lv_error+0(50).
**            sy-msgv2 = lv_error+50(50).
**            sy-msgv3 = lv_error+100(50).
**            sy-msgv4 = lv_error+150(50).
**
**            gs_elog-type       = 'SEND_JSON_ANY_TABLE'.
**            gs_elog-severity   = gc_error.
**            gs_elog-message    = lo_msg->get_longtext( ).
**            CALL METHOD lo_msg->get_source_position
**              IMPORTING
**                program_name = gv_prog
**                source_line  = gv_sline.
**            gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
**            gs_elog-details-db = 'ZONCL_OC_ANY_HANDLER-SEND_JSON_ANY_TABLE'.
**            gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.
**
**
**            gs_elog-metadata-error_code = gs_elog-details-error_code.
**            interpret_message( EXPORTING iv_msgnr = '097' iv_msgv1 = iv_tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
**            interpret_message( EXPORTING iv_msgnr = '098' iv_msgv1 = iv_tabname  IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
**            interpret_message( EXPORTING iv_msgnr = '099' iv_msgv1 = iv_tabname  IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
**            interpret_message( EXPORTING iv_msgnr = '100'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
**            interpret_message( EXPORTING iv_msgnr = '101'  IMPORTING ev_message = gv_msg5 CHANGING ct_table = gt_causes ).
**            CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 gv_msg5 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
**            interpret_message( EXPORTING iv_msgnr = '076'  iv_msgv1 = iv_tabname IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_fixes ).
**            interpret_message( EXPORTING iv_msgnr = '086'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_fixes ).
**            interpret_message( EXPORTING iv_msgnr = '087'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_fixes ).
**            CONCATENATE gv_msg1 gv_msg2 gv_msg3 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.
**            print_error_otel( ).
**            send_json_error( ).
**
***            MESSAGE i000(fb) WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
***            me->send_json_result( ).
**            lv_error_stop = abap_true.
**        ENDTRY.
**
**        CHECK lv_error_stop = abap_false.
**
**
**        "--------------------------------------------------------
**        " Loop over selected data and build JSON objects
**        "--------------------------------------------------------
***BEGIN CECHAVARRIA 19/08/2025
**        CLEAR lv_count.
**        DO.
**          lv_count = sy-index.
**          TRY.
**              FETCH NEXT CURSOR lv_cursor
**                INTO CORRESPONDING FIELDS OF TABLE <fs_table> PACKAGE SIZE lv_pakage.
**
**              IF sy-subrc NE 0.
**                CLOSE CURSOR lv_cursor.
**                IF lv_count = 1.
**                  MESSAGE i000(fb) WITH 'No data found'.
**
**                  me->append_slg1_log(
**                    EXPORTING
**                      iv_tabname    = space
**                      iv_message_v1 = 'No data found'
**                      iv_message_v2 = space
**                      iv_message_v3 = space
**                      iv_mestyp     = 'S' ).
**
**                ENDIF.
**                EXIT.
**              ENDIF.
**            CATCH cx_root INTO lo_msg.
**              CLOSE CURSOR lv_cursor.
**              lv_result = lo_msg->get_text( ).
**              lv_error  = lv_result.
**
**              sy-msgv1 = lv_error+0(50).
**              sy-msgv2 = lv_error+50(50).
**              sy-msgv3 = lv_error+100(50).
**              sy-msgv4 = lv_error+150(50).
**
**              gs_elog-type       = 'SEND_JSON_ANY_CON'.
**              gs_elog-severity   = gc_error.
**              gs_elog-message    = lo_msg->get_longtext( ).
**              CALL METHOD lo_msg->get_source_position
**                IMPORTING
**                  program_name = gv_prog
**                  source_line  = gv_sline.
**              gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
**              gs_elog-details-db = 'ZONCL_OC_ANY_HANDLER-SEND_JSON_ANY_CON'.
**              gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.
**
**
**              gs_elog-metadata-error_code = gs_elog-details-error_code.
**              interpret_message( EXPORTING iv_msgnr = '097' iv_msgv1 = iv_tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
**              interpret_message( EXPORTING iv_msgnr = '098' iv_msgv1 = iv_tabname  IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
**              interpret_message( EXPORTING iv_msgnr = '099' iv_msgv1 = iv_tabname  IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
**              interpret_message( EXPORTING iv_msgnr = '100'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
**              interpret_message( EXPORTING iv_msgnr = '101'  IMPORTING ev_message = gv_msg5 CHANGING ct_table = gt_causes ).
**              CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 gv_msg5 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
**              interpret_message( EXPORTING iv_msgnr = '076'  iv_msgv1 = iv_tabname IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_fixes ).
**              interpret_message( EXPORTING iv_msgnr = '086'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_fixes ).
**              interpret_message( EXPORTING iv_msgnr = '087'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_fixes ).
**              CONCATENATE gv_msg1 gv_msg2 gv_msg3 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.
**              print_error_otel( ).
**              send_json_error( ).
**
***              MESSAGE i000(fb) WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
***              me->send_json_result( ).
**              EXIT.
**          ENDTRY.
***END CECHAVARRIA 19/08/2025
**          gv_recordst = gv_recordst + lv_recordst.
**
**          CLEAR lt_keys.
**
**          lv_send = abap_false.
**          LOOP AT <fs_table> ASSIGNING <fs_data>.
**            CLEAR lt_keys.
**
**            " Generate key from line content
**            CALL METHOD me->set_key_any
**              EXPORTING
***               iv_alias = iv_alias
**                iv_alias = gv_alias
**                it_fcat  = lt_fcat
**                is_line  = <fs_data>
**              RECEIVING
**                rv_key   = lv_key.
**
**            ASSIGN lv_key TO <fs_key>.
**
**            " Track new keys to count records
**            IF lv_keys_temp NE lv_key.
**              lv_keys_temp   = lv_key.
**              lv_max_records = lv_max_records + 1.
**              gv_recordst_obj = gv_recordst_obj + 1.
**            ENDIF.
**
**            " Log key to application log
**            me->append_slg1_log(
**              iv_tabname = iv_tabname
**              iv_mestyp  = 'S'
**              iv_key     = lv_key ).
**
**            " Add line to body node
**            APPEND INITIAL LINE TO <fs_body> ASSIGNING <fs_line>.
**            MOVE-CORRESPONDING <fs_data> TO <fs_line>.
**
**            " Apply conversion exit for display format
**            me->conversion_exit(
**              EXPORTING
**                iv_tabname = iv_tabname
**              CHANGING
**                cs_string  = <fs_line> ).
**
**            " Add event ID if configured
**            IF gs_oc_obj-eventid  = abap_true OR
**               gs_oc_obj-metadata = abap_true.
**
**              IF <fs_key> IS ASSIGNED.
**                APPEND INITIAL LINE TO lt_keys ASSIGNING <fs_keys_event>.
**                <fs_keys_event>-line = <fs_key>.
**              ENDIF.
**
**              me->get_eventid(
**                EXPORTING
**                  it_keys      = lt_keys
**                CHANGING
**                  cs_line_json = <fs_line> ).
**            ENDIF.
**
**            " Serialize and send when reaching max records per message
**            IF lv_max_records EQ gs_oc_obj-no_registros.
**              APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
**              <fs_json>-json_id = gv_jsonid.
**              <fs_json>-json =  zoncl_ui2_cl_json=>serialize(
**                    data             = <fs_root>
**                    compress         = abap_false
**                    assoc_arrays     = abap_true
**                    assoc_arrays_opt = abap_true
**                    pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).
**
**              " Replace technical strings for compatibility
**              REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
**              REPLACE 'TABL'        WITH 'TABLE'        INTO <fs_json>-json.
**              gv_jsonid = gv_jsonid + 1.
**              CLEAR: lv_max_records, <fs_body>.
**              lv_send = abap_true.
**            ENDIF.
**          ENDLOOP.
**
**          "--------------------------------------------------------
**          " Serialize remaining records if limit not reached
**          "--------------------------------------------------------
**          IF lv_max_records LT gs_oc_obj-no_registros AND lv_send = abap_false.
**            IF lv_max_records = 0000."CECHAVARRIA 19/08/2025
**              APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
**              DELETE gt_json WHERE json IS INITIAL. "table_line = space."CECHAVARRIA 19/08/2025
**              IF sy-subrc NE 0.
**                <fs_json>-json_id = gv_jsonid.
**                <fs_json>-json =  zoncl_ui2_cl_json=>serialize(
**                        data             = <fs_root>
**                        compress         = abap_false
**                        assoc_arrays     = abap_true
**                        assoc_arrays_opt = abap_true
**                        pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).
**
**                REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
**                REPLACE 'TABL'        WITH 'TABLE'        INTO <fs_json>-json.
**              ENDIF.
**            ELSE."CECHAVARRIA 19/08/2025
**              APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
**              <fs_json>-json_id = gv_jsonid.
**              <fs_json>-json =  zoncl_ui2_cl_json=>serialize(
**                    data             = <fs_root>
**                    compress         = abap_false
**                    assoc_arrays     = abap_true
**                    assoc_arrays_opt = abap_true
**                    pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).
**
**              REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
**              REPLACE 'TABL'        WITH 'TABLE'        INTO <fs_json>-json.
**              exit.
**            ENDIF."CECHAVARRIA 19/08/2025
**          ENDIF.
**enddo.
**
**          "--------------------------------------------------------
**          " Send each JSON payload and track result
**          "--------------------------------------------------------
**          LOOP AT gt_json INTO gs_json.
**
**            gv_json = gs_json-json.
**            gv_jsonid = gs_json-json_id.
**
**            IF gv_recordst_obj IS INITIAL.
**              gv_recordst_obj = 1.
**            ENDIF.
**
**            me->pretty_json_any(
**              EXPORTING
**                iv_mode = c_table
**              CHANGING
**                cv_json = gv_json ).
**
***            IF sy-batch = abap_true.
***              me->send_json_http_con(
***                EXPORTING
***                  i_dest     = gv_dest
***                IMPORTING
***                  e_return   = lv_return
***                  e_size     = e_size
***                  e_records  = e_records
***                  e_response = lv_response ).
***            ELSE.
**            me->send_json_http_con_rap(
**                EXPORTING
**                  i_dest     = gv_dest
**                IMPORTING
**                  e_return   = lv_return
**                  e_size     = e_size
**                  e_records  = e_records
**                  e_response = lv_response ).
**
**
**
***BEGIN CECHAVARRIA 28/08/2025
**            IF me->gv_uuid IS NOT INITIAL.
**              IF  e_size IS NOT INITIAL.
**                me->update_table_json(
**                  iv_json    = gv_json
**                  iv_uuid    = me->gv_uuid
**                  iv_message = lv_response
**                  iv_status_code  = 'P'
**                ).
**              ELSE.
**                me->update_table_json(
**                  iv_json    = gv_json
**                  iv_uuid    = me->gv_uuid
**                  iv_message = lv_response
**                  iv_status_code  = 'E'
**                ).
**              ENDIF.
**            ENDIF.
**
**            gv_sizet    = gv_sizet + e_size.
**            gv_recordst = gv_recordst + 1.
**          ENDLOOP.
**          gv_jsonid = gv_jsonid + 1.
*** *BEGIN CECHAVARRIA 19/08/2025
**          CLEAR: gt_json[], lv_max_records, <fs_body>.
**
***      ENDDO. "quitar Diana
***END CECHAVARRIA 19/08/2025
**        "--------------------------------------------------------
**        " Finalize logging and output
**        "--------------------------------------------------------
***        me->send_json_result( ).
**        me->update_slg1_log( it_log_ext = gt_log_ext ).
**        r_size    = gv_sizet.
**        r_records = gv_recordst.
**      ENDIF.
**    ELSE.
**      CLEAR lv_message_v2.
**      lv_message_v2 = gv_entity.
**
**      me->append_slg1_log(
**        iv_tabname    = space
**        iv_message_v1 = 'No data found in table ZONTA_OBJ_OC for entity'
**        iv_message_v2 = lv_message_v2
**        iv_mestyp     = 'S' ).
**
**      me->update_slg1_log( it_log_ext = gt_log_ext ).
**    ENDIF.
**
**  ENDMETHOD.


  METHOD send_json_any_ltables_rap.

    CONSTANTS: c_rawstring TYPE c VALUE 'y',
               c_string    TYPE c VALUE 'X',
               c_256       TYPE c LENGTH 6 VALUE '000256'.


    "------------------------------------------------------------
    " Local Data Declarations
    "------------------------------------------------------------
    DATA: dref_table_root TYPE REF TO data,
          dref_table      TYPE REF TO data,
          lo_table        TYPE REF TO data,
          lo_data         TYPE REF TO data,
          lo_linea_ref    TYPE REF TO data,
          lo_rtti_origen  TYPE REF TO cl_abap_structdescr,
          lt_fcat         TYPE slis_t_fieldcat_alv,
          e_size          TYPE zonde_oc_num30,
          e_records       TYPE zonde_oc_num30,
          lt_keys         TYPE tty_where,
          lt_component    TYPE cl_abap_structdescr=>component_table,
          lt_component_2  TYPE cl_abap_structdescr=>component_table,
          lv_return       TYPE string,
          lv_recordst     TYPE sy-tabix,
          lv_response     TYPE string,
          lv_key          TYPE string,
          lv_keys_temp    TYPE string,
          lv_max_records  TYPE zonde_registrosn,
          lv_where        TYPE rsds_where_tab,
          lv_alias        TYPE zonde_aliastab,
          lv_fields       TYPE string,
          lv_result       TYPE string,
          lv_message_v2   TYPE string,
          lv_error(200)   TYPE c,
          lo_ref          TYPE REF TO cx_sy_dynamic_osql_semantics,
          lt_fields       TYPE TABLE OF line,
          lv_tab          TYPE tabname,
          lv_ltab         TYPE tabname,
          lv_ltabname     TYPE tabname,
          lv_aliastab     TYPE zonde_aliastab,
          lv_error_stop   TYPE boolean,
          lv_send         TYPE boolean,
          ls_dfies        LIKE LINE OF gt_dfies_tab.

    FIELD-SYMBOLS: <fs_data_table> TYPE any.
    DATA ls_fieldname LIKE LINE OF lt_component.
    DATA ls_field_2 like LINE OF lt_component_2.
    DATA ls_column2 LIKE LINE OF gt_columns_all.
    DATA ls_column LIKE LINE OF gt_columns_all.

    "------------------------------------------------------------
    " Field-Symbols
    "------------------------------------------------------------
    FIELD-SYMBOLS: <fs_root>            TYPE any,
                   <fs_oneconnect>      TYPE any,
                   <fs_properties>      TYPE any,
                   <fs_metadata>        TYPE any,
                   <fs_body_root>       TYPE any,
                   <fs_json>            LIKE LINE OF gt_json, "TYPE any,
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
                   <fs_keys_event>      TYPE LINE OF tty_where,
                   <fs_fcat>            LIKE LINE OF lt_fcat,
                   <ls_linea_table>     TYPE any,
                   <fs_field_data>      TYPE any,
                   <fs_field_tosend>    TYPE any.

    "------------------------------------------------------------
    " Initialization and Global Variable Assignment
    "------------------------------------------------------------
     me->debug_procedure( ).

    lv_error_stop  = abap_false.
    gv_update    = iv_update.
    gv_delete    = iv_delete.
    gv_anytable  = iv_tabname.
    gv_aliastab  = iv_aliastab.
*    gt_where     = it_where.
    gv_entity    = iv_entity_business_proc.
    gv_domainv   = 'ANY'.
    gv_dest      = iv_dest.
    gv_fieldname = iv_fieldname.
    gv_bothnames = iv_bothnames.

    " Log start of processing
    me->append_slg1_log(
      EXPORTING
        iv_tabname    = space
        iv_message_v1 = '*** Any Table Process TABLE Automatic***'
        iv_message_v2 = space
        iv_message_v3 = space
        iv_mestyp     = 'S' ).

    "------------------------------------------------------------
    " Retrieve metadata: columns, ALV field catalog, and DFIES
    "------------------------------------------------------------
    lv_ltabname = iv_tabname.
    lv_ltabname = to_upper( lv_ltabname ).

    lv_aliastab = iv_aliastab.
    lv_aliastab  = to_upper(  lv_aliastab ).

    SELECT * INTO TABLE gt_columns_all
      FROM zonta_oc_col_all
      WHERE tabname      = lv_ltabname
        AND alias_tabname = lv_aliastab .

    IF sy-subrc NE 0.
      CLEAR lv_message_v2.
      lv_message_v2 = gv_entity.

      me->append_slg1_log(
        iv_tabname    = space
        iv_message_v1 = 'No data found in table ZONTA_OC_COL_ALL for entity'
        iv_message_v2 = lv_message_v2
        iv_mestyp     = 'S' ).

      me->update_slg1_log( it_log_ext = gt_log_ext ).
      RETURN.
    ENDIF.

    CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name = iv_tabname
      CHANGING
        ct_fieldcat      = lt_fcat
      EXCEPTIONS
        OTHERS           = 3.

    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname   = iv_tabname
      TABLES
        dfies_tab = gt_dfies_tab
      EXCEPTIONS
        OTHERS    = 3.

    IF sy-subrc <> 0.
      " Handle DFIES error if needed
    ENDIF.

    SORT gt_dfies_tab BY position fieldname.
    SORT lt_fcat BY fieldname.
    LOOP AT gt_dfies_tab INTO ls_dfies.
      READ TABLE lt_fcat ASSIGNING <fs_fcat> WITH KEY fieldname = ls_dfies-fieldname BINARY SEARCH.
      IF sy-subrc NE 0.
        APPEND INITIAL LINE TO lt_fcat ASSIGNING <fs_fcat>.
        MOVE-CORRESPONDING ls_dfies TO <fs_fcat>.
      ENDIF.

      <fs_fcat>-ddic_outputlen = ls_dfies-offset.
      <fs_fcat>-inttype        = ls_dfies-inttype.
      <fs_fcat>-decimals_out   = ls_dfies-decimals.
      <fs_fcat>-col_pos        = ls_dfies-position.
      <fs_fcat>-offset         = ls_dfies-offset.
      <fs_fcat>-outputlen      = ls_dfies-outputlen.

      IF <fs_fcat>-inttype = c_rawstring.
        <fs_fcat>-inttype = c_string.
        <fs_fcat>-ddic_outputlen = c_256.
      ENDIF.

      IF <fs_fcat>-seltext_l IS INITIAL.
        <fs_fcat>-seltext_l = ls_dfies-scrtext_l.
        <fs_fcat>-seltext_m = ls_dfies-scrtext_m.
        <fs_fcat>-seltext_s = ls_dfies-scrtext_s.
      ENDIF.
    ENDLOOP.

    SORT lt_fcat BY row_pos fieldname.

    "------------------------------------------------------------
    " Load base configuration object and destination if missing
    "------------------------------------------------------------
    SELECT SINGLE * INTO gs_oc_obj
      FROM zonta_obj_oc
      WHERE domainv       = gv_domainv
        AND business_proc = gv_entity.

    IF sy-subrc EQ 0.

      SELECT SINGLE alias_tabname INTO lv_alias
        FROM zonta_oc_anyalia
        WHERE tabname = iv_tabname.

      IF gv_dest IS INITIAL.
        SELECT SINGLE low INTO gv_dest
          FROM zonta_oc_param
          WHERE name = 'RFC_DESTINATION'
            AND type = 'P'
            AND numb = 1.
      ENDIF.

      IF gv_dest IS NOT INITIAL. "sy-subrc EQ 0.

        "--------------------------------------------------------
        " Create root structure for ONECONNECT export
        "--------------------------------------------------------
        IF gs_oc_obj-data EQ abap_true.
          CREATE DATA dref_table_root TYPE ty_oneconnect_meta.
        ELSE.
          CREATE DATA dref_table_root TYPE ty_oneconnect.
        ENDIF.

        ASSIGN dref_table_root->* TO <fs_root>.
        ASSIGN COMPONENT 'ONECONNECT' OF STRUCTURE <fs_root> TO <fs_oneconnect>.
        ASSIGN COMPONENT 'PROPERTIES' OF STRUCTURE <fs_oneconnect> TO <fs_properties>.

        " Fill PROPERTIES node
        me->get_data_properties_any( CHANGING cs_properties = <fs_properties> ).

        ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_oneconnect> TO <fs_metadata_root>.
        APPEND INITIAL LINE TO <fs_metadata_root> ASSIGNING <fs_metadata>.
        ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_metadata> TO <fs_field_metadata>.

        " Set metadata field label (alias or table name)
        IF iv_fieldname IS INITIAL.
          IF NOT iv_bothnames IS INITIAL.
            <fs_field_metadata> = iv_tabname && '_' && lv_alias.
          ELSEIF lv_alias IS NOT INITIAL AND gv_alias IS NOT INITIAL.
            <fs_field_metadata> = lv_alias.
          ELSE.
            <fs_field_metadata> = iv_tabname.
          ENDIF.
        ELSE.
          <fs_field_metadata> = iv_tabname.
        ENDIF.

        ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_metadata> TO <fs_metadata_line>.
        ASSIGN COMPONENT 'BODY' OF STRUCTURE <fs_oneconnect> TO <fs_body_root>.
        ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_body_root> TO <fs_field>.

        " Set field name for BODY node
        IF iv_fieldname IS INITIAL.
          IF NOT iv_bothnames IS INITIAL.
            <fs_field> = iv_tabname && '_' && lv_alias.
          ELSEIF lv_alias IS NOT INITIAL AND gv_alias IS NOT INITIAL.
            <fs_field> = lv_alias.
          ELSE.
            <fs_field> = iv_tabname.
          ENDIF.
        ELSE.
          <fs_field> = iv_tabname.
        ENDIF.

        ASSIGN COMPONENT 'DATA' OF STRUCTURE <fs_body_root> TO <fs_table_body_line>.

        "--------------------------------------------------------
        " Create dynamic tables for BODY and result data
        "--------------------------------------------------------
        CALL METHOD me->set_table_any
          EXPORTING
            iv_alias = iv_alias
            it_fcat  = lt_fcat
          RECEIVING
            rt_table = <fs_table_body_line>.

        ASSIGN <fs_table_body_line>->* TO <fs_body>.

        CALL METHOD me->set_table_any
          EXPORTING
            iv_alias = iv_alias "iv_fieldname CHECK
            it_fcat  = lt_fcat
          RECEIVING
            rt_table = lo_data.

        ASSIGN lo_data->* TO <fs_table>.

        "--------------------------------------------------------
        " Compose WHERE and SELECT fields
        "--------------------------------------------------------
*      lv_fields = me->set_fields( iv_alias = iv_alias ).


*        IF gt_where IS INITIAL.
*          lv_where = me->set_where_any( iv_any = abap_true ).
*          me->set_process( ).
*          gt_where = lv_where.
*        ELSE.
*          lv_where = gt_where.
*        ENDIF.
*
*        IF lv_where IS INITIAL.
*          MESSAGE i000(fb) WITH 'No filter selected'.
*          RETURN.
*        ENDIF.
        "--------------------------------------------------------
        " Fetch Data Dynamically (CDS or Transparent Table)
        "--------------------------------------------------------
        TRY.
*            IF is_cds_entity( iv_tabname ) = abap_true.
*            me->set_fields_in_table(
*              EXPORTING
*                iv_tabname = iv_tabname
*                iv_alias   = iv_alias
*              IMPORTING
*                et_fields  = lt_fields ).
*
*              SELECT (lt_fields) FROM (iv_tabname)
*                WHERE (lv_where)
*                INTO CORRESPONDING FIELDS OF TABLE @<fs_table>.
*            ELSE.
*              lv_fields = me->set_fields( iv_alias = iv_alias ).
*              SELECT (lv_fields)
*                INTO CORRESPONDING FIELDS OF TABLE <fs_table>
*                FROM (iv_tabname)
*                WHERE (lv_where).
*            ENDIF.

            LOOP AT it_tables_data ASSIGNING <fs_data_table>.
              IF sy-tabix EQ 1.
                lo_rtti_origen ?= cl_abap_typedescr=>describe_by_data( <fs_data_table> ).
                lt_component = lo_rtti_origen->get_components( ).
              ENDIF.
              CREATE DATA lo_linea_ref LIKE LINE OF <fs_table>.
              ASSIGN lo_linea_ref->* TO <ls_linea_table>.

              IF sy-subrc = 0.
                MOVE-CORRESPONDING <fs_data_table> TO <ls_linea_table>.
                IF <ls_linea_table> IS INITIAL.
                  LOOP AT lt_component INTO ls_fieldname.

                    IF ls_fieldname-as_include = abap_true.
                      lo_rtti_origen ?= ls_fieldname-type.
                      lt_component_2 = lo_rtti_origen->get_components( ).

                      LOOP AT lt_component_2 INTO ls_field_2.

                        ASSIGN COMPONENT ls_field_2-name OF STRUCTURE <fs_data_table> TO <fs_field_data>.

                        READ TABLE gt_columns_all INTO ls_column2
                                WITH KEY tabname = iv_tabname
                                         fldname = ls_field_2-name.
                        IF sy-subrc EQ 0.

                          IF ls_column2-alias_fldname IS NOT INITIAL.
                            ASSIGN COMPONENT ls_column2-alias_fldname OF STRUCTURE <ls_linea_table> TO <fs_field_tosend>.
                          ELSE.
                            ASSIGN COMPONENT ls_column2-fldname OF STRUCTURE <ls_linea_table> TO <fs_field_tosend>.
                          ENDIF.

                          IF <fs_field_data> IS ASSIGNED AND <fs_field_tosend> IS ASSIGNED.
                            <fs_field_tosend> = <fs_field_data>.
                          ENDIF.
                        ENDIF.
                      ENDLOOP.

                    ENDIF.
                    ASSIGN COMPONENT ls_fieldname-name OF STRUCTURE <fs_data_table> TO <fs_field_data>.

                    READ TABLE gt_columns_all INTO ls_column
                            WITH KEY tabname = iv_tabname
                                     fldname = ls_fieldname-name.
                    IF sy-subrc EQ 0.

                      IF ls_column-alias_fldname IS NOT INITIAL.
                        ASSIGN COMPONENT ls_column-alias_fldname OF STRUCTURE <ls_linea_table> TO <fs_field_tosend>.
                      ELSE.
                        ASSIGN COMPONENT ls_column-fldname OF STRUCTURE <ls_linea_table> TO <fs_field_tosend>.
                      ENDIF.

                      IF <fs_field_data> IS ASSIGNED AND <fs_field_tosend> IS ASSIGNED.
                        <fs_field_tosend> = <fs_field_data>.
                      ENDIF.
                    ENDIF.
                  ENDLOOP.
                ENDIF.
                IF <ls_linea_table> IS NOT INITIAL.
                  APPEND <ls_linea_table> TO <fs_table>.
                ENDIF.
              ENDIF.
            ENDLOOP.

            IF <fs_table> IS INITIAL.
              MESSAGE i000(fb) WITH 'No data found'.

              me->append_slg1_log(
                EXPORTING
                  iv_tabname    = space
                  iv_message_v1 = 'No data found'
                  iv_message_v2 = space
                  iv_message_v3 = space
                  iv_mestyp     = 'S' ).

              RETURN.
            ENDIF.

          CATCH cx_sy_dynamic_osql_semantics INTO lo_ref.
            lv_result = lo_ref->get_text( ).
            lv_error  = lv_result.

            sy-msgv1 = lv_error+0(50).
            sy-msgv2 = lv_error+50(50).
            sy-msgv3 = lv_error+100(50).
            sy-msgv4 = lv_error+150(50).


            gs_elog-type       = 'SEND_JSON_ANY_TABLE_RAP'.
            gs_elog-severity   = gc_error.
            gs_elog-message    = lo_ref->get_longtext( ).
            CALL METHOD lo_ref->get_source_position
              IMPORTING
                program_name = gv_prog
                source_line  = gv_sline.
            gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
            gs_elog-details-db = 'ZONCL_OC_ANY_HANDLER-SEND_JSON_ANY_TABLE_RAP'.
            gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.


            gs_elog-metadata-error_code = gs_elog-details-error_code.
            interpret_message( EXPORTING iv_msgnr = '097' iv_msgv1 = iv_tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '098' iv_msgv1 = iv_tabname  IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '099' iv_msgv1 = iv_tabname  IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '100'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '101'  IMPORTING ev_message = gv_msg5 CHANGING ct_table = gt_causes ).
            CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 gv_msg5 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
            interpret_message( EXPORTING iv_msgnr = '076'  iv_msgv1 = iv_tabname IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '086'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '087'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_fixes ).
            CONCATENATE gv_msg1 gv_msg2 gv_msg3 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.
            print_error_otel( ).
            send_json_error( ).
*            MESSAGE i000(fb) WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

            lv_error_stop = abap_true.
        ENDTRY.

        CHECK lv_error_stop = abap_false.
        "--------------------------------------------------------
        " Run as Background Batch if Configured
        "--------------------------------------------------------
        IF NOT gv_batch IS INITIAL.
          me->execute_batch(
            EXPORTING
              iv_anytab  = abap_true
              iv_tabname = iv_tabname ).
          RETURN.
        ENDIF.

        "--------------------------------------------------------
        " Fill METADATA node
        "--------------------------------------------------------
        me->set_metadata_node_any(
          EXPORTING
            iv_alias    = iv_fieldname
            it_fcat     = lt_fcat
          CHANGING
            ct_metadata = <fs_metadata_line> ).

        "--------------------------------------------------------
        " Loop over selected data and build JSON objects
        "--------------------------------------------------------
*        gv_recordst = gv_recordst + lv_recordst.
        gs_log_json_result-recordst = gs_log_json_result-recordst + lv_recordst.

        CLEAR lt_keys.

        lv_send = abap_false.
        LOOP AT <fs_table> ASSIGNING <fs_data>.
          CLEAR lt_keys.

          " Generate key from line content
          CALL METHOD me->set_key_any
            EXPORTING
              iv_alias = iv_alias
              it_fcat  = lt_fcat
              is_line  = <fs_data>
            RECEIVING
              rv_key   = lv_key.

          ASSIGN lv_key TO <fs_key>.

          " Track new keys to count records
          IF lv_keys_temp NE lv_key.
            lv_keys_temp   = lv_key.
            lv_max_records = lv_max_records + 1.
*            gv_recordst_obj = gv_recordst_obj + 1.
            gs_log_json_result-recordst_obj = gs_log_json_result-recordst_obj + 1.
          ENDIF.

          " Log key to application log
          me->append_slg1_log(
            iv_tabname = iv_tabname
            iv_mestyp  = 'S'
            iv_key     = lv_key ).

          " Add line to body node
          APPEND INITIAL LINE TO <fs_body> ASSIGNING <fs_line>.
          MOVE-CORRESPONDING <fs_data> TO <fs_line>.

          " Apply conversion exit for display format
          me->conversion_exit(
            EXPORTING
              iv_tabname = iv_tabname
            CHANGING
              cs_string  = <fs_line> ).

          " Add event ID if configured
          IF gs_oc_obj-eventid  = abap_true OR
             gs_oc_obj-metadata = abap_true.

            IF <fs_key> IS ASSIGNED.
              APPEND INITIAL LINE TO lt_keys ASSIGNING <fs_keys_event>.
              <fs_keys_event>-line = <fs_key>.
            ENDIF.

            me->get_eventid(
              EXPORTING
                it_keys      = lt_keys
              CHANGING
                cs_line_json = <fs_line> ).
          ENDIF.

          " Serialize and send when reaching max records per message
          IF lv_max_records EQ gs_oc_obj-no_registros.
            APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
            <fs_json>-json_id = gv_jsonid.
            <fs_json>-json =  zoncl_ui2_cl_json=>serialize(
                data             = <fs_root>
                compress         = abap_false
                assoc_arrays     = abap_true
                assoc_arrays_opt = abap_true
                pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).

            " Replace technical strings for compatibility
            REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
            REPLACE 'TABL'        WITH 'TABLE'        INTO <fs_json>-json.
            gv_jsonid = gv_jsonid + 1.
            CLEAR: lv_max_records, <fs_body>.
            lv_send = abap_true.
          ENDIF.
        ENDLOOP.

        "--------------------------------------------------------
        " Serialize remaining records if limit not reached
        "--------------------------------------------------------
        IF lv_max_records LT gs_oc_obj-no_registros AND lv_send = abap_false.
          APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
          <fs_json>-json_id = gv_jsonid.
          <fs_json>-json = zoncl_ui2_cl_json=>serialize(
            data             = <fs_root>
            compress         = abap_false
            assoc_arrays     = abap_true
            assoc_arrays_opt = abap_true
            pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).

          REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
          REPLACE 'TABL'        WITH 'TABLE'        INTO <fs_json>-json.
        ENDIF.

        "--------------------------------------------------------
        " Send each JSON payload and track result
        "--------------------------------------------------------
        LOOP AT gt_json INTO gs_json.

          gv_json = gs_json-json.
          gv_jsonid = gs_json-json_id.

*          IF gv_recordst_obj IS INITIAL.
*            gv_recordst_obj = 1.
*          ENDIF.
          IF gs_log_json_result-recordst_obj IS INITIAL.
            gs_log_json_result-recordst_obj = 1.
          ENDIF.

          me->pretty_json_any(
            EXPORTING
              iv_mode = c_table
            CHANGING
              cv_json = gv_json ).

          me->send_json_http_con_rap(
            EXPORTING
              i_dest     = gv_dest
            IMPORTING
              e_return   = lv_return
              e_size     = e_size
              e_records  = e_records
              e_response = lv_response ).

*          gv_sizet    = gv_sizet + e_size.
*          gv_recordst = gv_recordst + 1.
          gs_log_json_result-sizet    = gs_log_json_result-sizet + e_size.
          gs_log_json_result-recordst = gs_log_json_result-recordst + 1.
        ENDLOOP.

        "--------------------------------------------------------
        " Finalize logging and output
        "--------------------------------------------------------
        me->send_json_result( ).
        me->update_slg1_log( it_log_ext = gt_log_ext ).

      ENDIF.
    ELSE.
      CLEAR lv_message_v2.
      lv_message_v2 = gv_entity.

      me->append_slg1_log(
        iv_tabname    = space
        iv_message_v1 = 'No data found in table ZONTA_OBJ_OC for entity'
        iv_message_v2 = lv_message_v2
        iv_mestyp     = 'S' ).

      me->update_slg1_log( it_log_ext = gt_log_ext ).
    ENDIF.

  ENDMETHOD.


**  METHOD send_json_any_ltables_rap.
**
**    CONSTANTS: c_rawstring TYPE c VALUE 'y',
**               c_string    TYPE c VALUE 'X',
**               c_256       TYPE c LENGTH 6 VALUE '000256'.
**
**
**    "------------------------------------------------------------
**    " Local Data Declarations
**    "------------------------------------------------------------
**    DATA: dref_table_root TYPE REF TO data,
**          dref_table      TYPE REF TO data,
**          lo_table        TYPE REF TO data,
**          lo_data         TYPE REF TO data,
**          lo_linea_ref    TYPE REF TO data,
**          lo_rtti_origen  TYPE REF TO cl_abap_structdescr,
**          lt_fcat         TYPE slis_t_fieldcat_alv,
**          e_size          TYPE zonde_oc_num30,
**          e_records       TYPE zonde_oc_num30,
**          lt_keys         TYPE tty_where,
**          lt_component    TYPE cl_abap_structdescr=>component_table,
**          lt_component_2  TYPE cl_abap_structdescr=>component_table,
**          lv_return       TYPE string,
**          lv_recordst     TYPE sy-tabix,
**          lv_response     TYPE string,
**          lv_key          TYPE string,
**          lv_keys_temp    TYPE string,
**          lv_max_records  TYPE zonde_registrosn,
**          lv_where        TYPE rsds_where_tab,
**          lv_alias        TYPE zonde_aliastab,
**          lv_fields       TYPE string,
**          lv_result       TYPE string,
**          lv_message_v2   TYPE string,
**          lv_error(200)   TYPE c,
**          lo_ref          TYPE REF TO cx_sy_dynamic_osql_semantics,
**          lt_fields       TYPE TABLE OF line,
**          lv_tab          TYPE tabname,
**          lv_ltab         TYPE tabname,
**          lv_ltabname     TYPE tabname,
**          lv_aliastab     TYPE zonde_aliastab,
**          lv_error_stop   TYPE boolean,
**          lv_send         TYPE boolean,
**          ls_dfies        LIKE LINE OF gt_dfies_tab.
**
**    "------------------------------------------------------------
**    " Field-Symbols
**    "------------------------------------------------------------
**    FIELD-SYMBOLS: <fs_root>            TYPE any,
**                   <fs_oneconnect>      TYPE any,
**                   <fs_properties>      TYPE any,
**                   <fs_metadata>        TYPE any,
**                   <fs_body_root>       TYPE any,
**                   <fs_json>            LIKE LINE OF gt_json, "TYPE any,
**                   <fs_field_metadata>  TYPE any,
**                   <fs_metadata_line>   TYPE any,
**                   <fs_field>           TYPE any,
**                   <fs_line>            TYPE any,
**                   <fs_table_body_line> TYPE any,
**                   <fs_body>            TYPE STANDARD TABLE,
**                   <fs_metadata_root>   TYPE STANDARD TABLE,
**                   <fs_table>           TYPE STANDARD TABLE,
**                   <fs_table2>          TYPE ANY TABLE,
**                   <fs_data>            TYPE any,
**                   <fs_table_line>      TYPE any,
**                   <fs_key>             TYPE any,
**                   <fs_key_main>        TYPE any,
**                   <fs_keys_event>      TYPE LINE OF tty_where,
**                   <fs_fcat>            LIKE LINE OF lt_fcat,
**                   <ls_linea_table>     TYPE any,
**                   <fs_field_data>      TYPE any,
**                   <fs_field_tosend>    TYPE any.
**
*******
**    FIELD-SYMBOLS: <fs_data_table> TYPE any.
**    DATA ls_fieldname LIKE LINE OF lt_component.
**    DATA ls_field_2 like LINE OF lt_component_2.
**    DATA ls_column2 LIKE LINE OF gt_columns_all.
**    DATA ls_column LIKE LINE OF gt_columns_all.
*******
**
**    "------------------------------------------------------------
**    " Initialization and Global Variable Assignment
**    "------------------------------------------------------------
**    me->debug_procedure( ).
**
**    lv_error_stop  = abap_false.
**    gv_update    = iv_update.
**    gv_delete    = iv_delete.
**    gv_anytable  = iv_tabname.
**    gv_aliastab  = iv_aliastab.
***    gt_where     = it_where.
**    gv_entity    = iv_entity_business_proc.
**    gv_domainv   = 'ANY'.
**    gv_dest      = iv_dest.
**    gv_fieldname = iv_fieldname.
**    gv_bothnames = iv_bothnames.
**
**    " Log start of processing
**    me->append_slg1_log(
**      EXPORTING
**        iv_tabname    = space
**        iv_message_v1 = '*** Any Table Process TABLE Automatic***'
**        iv_message_v2 = space
**        iv_message_v3 = space
**        iv_mestyp     = 'S' ).
**
**    "------------------------------------------------------------
**    " Retrieve metadata: columns, ALV field catalog, and DFIES
**    "------------------------------------------------------------
**    lv_ltabname = iv_tabname.
**    lv_ltabname = to_upper( lv_ltabname ).
**
**    lv_aliastab = iv_aliastab.
**    lv_aliastab  = to_upper(  lv_aliastab ).
**
**    SELECT * INTO TABLE gt_columns_all
**      FROM zonta_oc_col_all
**      WHERE tabname      = lv_ltabname
**        AND alias_tabname = lv_aliastab .
**
**    IF sy-subrc NE 0.
**      CLEAR lv_message_v2.
**      lv_message_v2 = gv_entity.
**
**      me->append_slg1_log(
**        iv_tabname    = space
**        iv_message_v1 = 'No data found in table ZONTA_OC_COL_ALL for entity'
**        iv_message_v2 = lv_message_v2
**        iv_mestyp     = 'S' ).
**
**      me->update_slg1_log( it_log_ext = gt_log_ext ).
**      RETURN.
**    ENDIF.
**
**    CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
**      EXPORTING
**        i_structure_name = iv_tabname
**      CHANGING
**        ct_fieldcat      = lt_fcat
**      EXCEPTIONS
**        OTHERS           = 3.
**
**    CALL FUNCTION 'DDIF_FIELDINFO_GET'
**      EXPORTING
**        tabname   = iv_tabname
**      TABLES
**        dfies_tab = gt_dfies_tab
**      EXCEPTIONS
**        OTHERS    = 3.
**
**    IF sy-subrc <> 0.
**      " Handle DFIES error if needed
**    ENDIF.
**
**    SORT gt_dfies_tab BY position fieldname.
**    SORT lt_fcat BY fieldname.
**    LOOP AT gt_dfies_tab INTO ls_dfies.
**      READ TABLE lt_fcat ASSIGNING <fs_fcat> WITH KEY fieldname = ls_dfies-fieldname BINARY SEARCH.
**      IF sy-subrc NE 0.
**        APPEND INITIAL LINE TO lt_fcat ASSIGNING <fs_fcat>.
**        MOVE-CORRESPONDING ls_dfies TO <fs_fcat>.
**      ENDIF.
**
**      <fs_fcat>-ddic_outputlen = ls_dfies-offset.
**      <fs_fcat>-inttype        = ls_dfies-inttype.
**      <fs_fcat>-decimals_out   = ls_dfies-decimals.
**      <fs_fcat>-col_pos        = ls_dfies-position.
**      <fs_fcat>-offset         = ls_dfies-offset.
**      <fs_fcat>-outputlen      = ls_dfies-outputlen.
**
**      IF <fs_fcat>-inttype = c_rawstring.
**        <fs_fcat>-inttype = c_string.
**        <fs_fcat>-ddic_outputlen = c_256.
**      ENDIF.
**
**      IF <fs_fcat>-seltext_l IS INITIAL.
**        <fs_fcat>-seltext_l = ls_dfies-scrtext_l.
**        <fs_fcat>-seltext_m = ls_dfies-scrtext_m.
**        <fs_fcat>-seltext_s = ls_dfies-scrtext_s.
**      ENDIF.
**    ENDLOOP.
**
**    SORT lt_fcat BY row_pos fieldname.
**
**    "------------------------------------------------------------
**    " Load base configuration object and destination if missing
**    "------------------------------------------------------------
**    SELECT SINGLE * INTO gs_oc_obj
**      FROM zonta_obj_oc
**      WHERE domainv       = gv_domainv
**        AND business_proc = gv_entity.
**
**    IF sy-subrc EQ 0.
**
**      SELECT SINGLE alias_tabname INTO lv_alias
**        FROM zonta_oc_anyalia
**        WHERE tabname = iv_tabname.
**
**      IF gv_dest IS INITIAL.
**        SELECT SINGLE low INTO gv_dest
**          FROM zonta_oc_param
**          WHERE name = 'RFC_DESTINATION'
**            AND type = 'P'
**            AND numb = 1.
**      ENDIF.
**
**      IF sy-subrc EQ 0.
**
**        "--------------------------------------------------------
**        " Create root structure for ONECONNECT export
**        "--------------------------------------------------------
**        IF gs_oc_obj-data EQ abap_true.
**          CREATE DATA dref_table_root TYPE ty_oneconnect_meta.
**        ELSE.
**          CREATE DATA dref_table_root TYPE ty_oneconnect.
**        ENDIF.
**
**        ASSIGN dref_table_root->* TO <fs_root>.
**        ASSIGN COMPONENT 'ONECONNECT' OF STRUCTURE <fs_root> TO <fs_oneconnect>.
**        ASSIGN COMPONENT 'PROPERTIES' OF STRUCTURE <fs_oneconnect> TO <fs_properties>.
**
**        " Fill PROPERTIES node
**        me->get_data_properties_any( CHANGING cs_properties = <fs_properties> ).
**
**        ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_oneconnect> TO <fs_metadata_root>.
**        APPEND INITIAL LINE TO <fs_metadata_root> ASSIGNING <fs_metadata>.
**        ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_metadata> TO <fs_field_metadata>.
**
**        " Set metadata field label (alias or table name)
**        IF iv_fieldname IS INITIAL.
**          IF NOT iv_bothnames IS INITIAL.
**            <fs_field_metadata> = iv_tabname && '_' && lv_alias.
**          ELSEIF lv_alias IS NOT INITIAL AND gv_alias IS NOT INITIAL.
**            <fs_field_metadata> = lv_alias.
**          ELSE.
**            <fs_field_metadata> = iv_tabname.
**          ENDIF.
**        ELSE.
**          <fs_field_metadata> = iv_tabname.
**        ENDIF.
**
**        ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_metadata> TO <fs_metadata_line>.
**        ASSIGN COMPONENT 'BODY' OF STRUCTURE <fs_oneconnect> TO <fs_body_root>.
**        ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_body_root> TO <fs_field>.
**
**        " Set field name for BODY node
**        IF iv_fieldname IS INITIAL.
**          IF NOT iv_bothnames IS INITIAL.
**            <fs_field> = iv_tabname && '_' && lv_alias.
**          ELSEIF lv_alias IS NOT INITIAL AND gv_alias IS NOT INITIAL.
**            <fs_field> = lv_alias.
**          ELSE.
**            <fs_field> = iv_tabname.
**          ENDIF.
**        ELSE.
**          <fs_field> = iv_tabname.
**        ENDIF.
**
**        ASSIGN COMPONENT 'DATA' OF STRUCTURE <fs_body_root> TO <fs_table_body_line>.
**
**        "--------------------------------------------------------
**        " Create dynamic tables for BODY and result data
**        "--------------------------------------------------------
**        CALL METHOD me->set_table_any
**          EXPORTING
**            iv_alias = iv_alias
**            it_fcat  = lt_fcat
**          RECEIVING
**            rt_table = <fs_table_body_line>.
**
**        ASSIGN <fs_table_body_line>->* TO <fs_body>.
**
**        CALL METHOD me->set_table_any
**          EXPORTING
**            iv_alias = iv_alias "iv_fieldname CHECK
**            it_fcat  = lt_fcat
**          RECEIVING
**            rt_table = lo_data.
**
**        ASSIGN lo_data->* TO <fs_table>.
**
**        "--------------------------------------------------------
**        " Compose WHERE and SELECT fields
**        "--------------------------------------------------------
***      lv_fields = me->set_fields( iv_alias = iv_alias ).
**
**
***        IF gt_where IS INITIAL.
***          lv_where = me->set_where_any( iv_any = abap_true ).
***          me->set_process( ).
***          gt_where = lv_where.
***        ELSE.
***          lv_where = gt_where.
***        ENDIF.
***
***        IF lv_where IS INITIAL.
***          MESSAGE i000(fb) WITH 'No filter selected'.
***          RETURN.
***        ENDIF.
**        "--------------------------------------------------------
**        " Fetch Data Dynamically (CDS or Transparent Table)
**        "--------------------------------------------------------
**        TRY.
***            IF is_cds_entity( iv_tabname ) = abap_true.
***            me->set_fields_in_table(
***              EXPORTING
***                iv_tabname = iv_tabname
***                iv_alias   = iv_alias
***              IMPORTING
***                et_fields  = lt_fields ).
***
***              SELECT (lt_fields) FROM (iv_tabname)
***                WHERE (lv_where)
***                INTO CORRESPONDING FIELDS OF TABLE @<fs_table>.
***            ELSE.
***              lv_fields = me->set_fields( iv_alias = iv_alias ).
***              SELECT (lv_fields)
***                INTO CORRESPONDING FIELDS OF TABLE <fs_table>
***                FROM (iv_tabname)
***                WHERE (lv_where).
***            ENDIF.
**
***            LOOP AT it_tables_data ASSIGNING FIELD-SYMBOL(<fs_data_table>).
**            LOOP AT it_tables_data ASSIGNING <fs_data_table>.
**              IF sy-tabix EQ 1.
**                lo_rtti_origen ?= cl_abap_typedescr=>describe_by_data( <fs_data_table> ).
**                lt_component = lo_rtti_origen->get_components( ).
**              ENDIF.
**              CREATE DATA lo_linea_ref LIKE LINE OF <fs_table>.
**              ASSIGN lo_linea_ref->* TO <ls_linea_table>.
**
**              IF sy-subrc = 0.
**                MOVE-CORRESPONDING <fs_data_table> TO <ls_linea_table>.
**                IF <ls_linea_table> IS INITIAL.
***                  LOOP AT lt_component INTO data(ls_fieldname).
**                  LOOP AT lt_component INTO ls_fieldname.
**
**                    IF ls_fieldname-as_include = abap_true.
**                      lo_rtti_origen ?= ls_fieldname-type.
**                      lt_component_2 = lo_rtti_origen->get_components( ).
**
***                      LOOP AT lt_component_2 INTO data(ls_field_2).
**                      LOOP AT lt_component_2 INTO ls_field_2.
**
**                        ASSIGN COMPONENT ls_field_2-name OF STRUCTURE <fs_data_table> TO <fs_field_data>.
**
***                        READ TABLE gt_columns_all INTO data(ls_column2)
**                        READ TABLE gt_columns_all INTO ls_column2
**                                WITH KEY tabname = iv_tabname
**                                         fldname = ls_field_2-name.
**                        IF sy-subrc EQ 0.
**
**                          IF ls_column2-alias_fldname IS NOT INITIAL.
**                            ASSIGN COMPONENT ls_column2-alias_fldname OF STRUCTURE <ls_linea_table> TO <fs_field_tosend>.
**                          ELSE.
**                            ASSIGN COMPONENT ls_column2-fldname OF STRUCTURE <ls_linea_table> TO <fs_field_tosend>.
**                          ENDIF.
**
**                          IF <fs_field_data> IS ASSIGNED AND <fs_field_tosend> IS ASSIGNED.
**                            <fs_field_tosend> = <fs_field_data>.
**                          ENDIF.
**                        ENDIF.
**                      ENDLOOP.
**
**                    ENDIF.
**                    ASSIGN COMPONENT ls_fieldname-name OF STRUCTURE <fs_data_table> TO <fs_field_data>.
**
***                    READ TABLE gt_columns_all INTO data(ls_column)
**                    READ TABLE gt_columns_all INTO ls_column
**                            WITH KEY tabname = iv_tabname
**                                     fldname = ls_fieldname-name.
**                    IF sy-subrc EQ 0.
**
**                      IF ls_column-alias_fldname IS NOT INITIAL.
**                        ASSIGN COMPONENT ls_column-alias_fldname OF STRUCTURE <ls_linea_table> TO <fs_field_tosend>.
**                      ELSE.
**                        ASSIGN COMPONENT ls_column-fldname OF STRUCTURE <ls_linea_table> TO <fs_field_tosend>.
**                      ENDIF.
**
**                      IF <fs_field_data> IS ASSIGNED AND <fs_field_tosend> IS ASSIGNED.
**                        <fs_field_tosend> = <fs_field_data>.
**                      ENDIF.
**                    ENDIF.
**                  ENDLOOP.
**                ENDIF.
**                IF <ls_linea_table> IS NOT INITIAL.
**                  APPEND <ls_linea_table> TO <fs_table>.
**                ENDIF.
**              ENDIF.
**            ENDLOOP.
**
**            IF <fs_table> IS INITIAL.
**              MESSAGE i000(fb) WITH 'No data found'.
**
**              me->append_slg1_log(
**                EXPORTING
**                  iv_tabname    = space
**                  iv_message_v1 = 'No data found'
**                  iv_message_v2 = space
**                  iv_message_v3 = space
**                  iv_mestyp     = 'S' ).
**
**              RETURN.
**            ENDIF.
**
**          CATCH cx_sy_dynamic_osql_semantics INTO lo_ref.
**            lv_result = lo_ref->get_text( ).
**            lv_error  = lv_result.
**
**            sy-msgv1 = lv_error+0(50).
**            sy-msgv2 = lv_error+50(50).
**            sy-msgv3 = lv_error+100(50).
**            sy-msgv4 = lv_error+150(50).
**
**
**            gs_elog-type       = 'SEND_JSON_ANY_TABLE_RAP'.
**            gs_elog-severity   = gc_error.
**            gs_elog-message    = lo_ref->get_longtext( ).
**            CALL METHOD lo_ref->get_source_position
**              IMPORTING
**                program_name = gv_prog
**                source_line  = gv_sline.
**            gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
**            gs_elog-details-db = 'ZONCL_OC_ANY_HANDLER-SEND_JSON_ANY_TABLE_RAP'.
**            gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.
**
**
**            gs_elog-metadata-error_code = gs_elog-details-error_code.
**            interpret_message( EXPORTING iv_msgnr = '097' iv_msgv1 = iv_tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
**            interpret_message( EXPORTING iv_msgnr = '098' iv_msgv1 = iv_tabname  IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
**            interpret_message( EXPORTING iv_msgnr = '099' iv_msgv1 = iv_tabname  IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
**            interpret_message( EXPORTING iv_msgnr = '100'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
**            interpret_message( EXPORTING iv_msgnr = '101'  IMPORTING ev_message = gv_msg5 CHANGING ct_table = gt_causes ).
**            CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 gv_msg5 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
**            interpret_message( EXPORTING iv_msgnr = '076'  iv_msgv1 = iv_tabname IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_fixes ).
**            interpret_message( EXPORTING iv_msgnr = '086'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_fixes ).
**            interpret_message( EXPORTING iv_msgnr = '087'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_fixes ).
**            CONCATENATE gv_msg1 gv_msg2 gv_msg3 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.
**            print_error_otel( ).
**            send_json_error( ).
***            MESSAGE i000(fb) WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
**
**            lv_error_stop = abap_true.
**        ENDTRY.
**
**        CHECK lv_error_stop = abap_false.
**        "--------------------------------------------------------
**        " Run as Background Batch if Configured
**        "--------------------------------------------------------
**        IF NOT gv_batch IS INITIAL.
**          me->execute_batch(
**            EXPORTING
**              iv_anytab  = abap_true
**              iv_tabname = iv_tabname ).
**          RETURN.
**        ENDIF.
**
**        "--------------------------------------------------------
**        " Fill METADATA node
**        "--------------------------------------------------------
**        me->set_metadata_node_any(
**          EXPORTING
**            iv_alias    = iv_fieldname
**            it_fcat     = lt_fcat
**          CHANGING
**            ct_metadata = <fs_metadata_line> ).
**
**        "--------------------------------------------------------
**        " Loop over selected data and build JSON objects
**        "--------------------------------------------------------
**        gv_recordst = gv_recordst + lv_recordst.
**
**        CLEAR lt_keys.
**
**        lv_send = abap_false.
**        LOOP AT <fs_table> ASSIGNING <fs_data>.
**          CLEAR lt_keys.
**
**          " Generate key from line content
**          CALL METHOD me->set_key_any
**            EXPORTING
**              iv_alias = iv_alias
**              it_fcat  = lt_fcat
**              is_line  = <fs_data>
**            RECEIVING
**              rv_key   = lv_key.
**
**          ASSIGN lv_key TO <fs_key>.
**
**          " Track new keys to count records
**          IF lv_keys_temp NE lv_key.
**            lv_keys_temp   = lv_key.
**            lv_max_records = lv_max_records + 1.
**            gv_recordst_obj = gv_recordst_obj + 1.
**          ENDIF.
**
**          " Log key to application log
**          me->append_slg1_log(
**            iv_tabname = iv_tabname
**            iv_mestyp  = 'S'
**            iv_key     = lv_key ).
**
**          " Add line to body node
**          APPEND INITIAL LINE TO <fs_body> ASSIGNING <fs_line>.
**          MOVE-CORRESPONDING <fs_data> TO <fs_line>.
**
**          " Apply conversion exit for display format
**          me->conversion_exit(
**            EXPORTING
**              iv_tabname = iv_tabname
**            CHANGING
**              cs_string  = <fs_line> ).
**
**          " Add event ID if configured
**          IF gs_oc_obj-eventid  = abap_true OR
**             gs_oc_obj-metadata = abap_true.
**
**            IF <fs_key> IS ASSIGNED.
**              APPEND INITIAL LINE TO lt_keys ASSIGNING <fs_keys_event>.
**              <fs_keys_event>-line = <fs_key>.
**            ENDIF.
**
**            me->get_eventid(
**              EXPORTING
**                it_keys      = lt_keys
**              CHANGING
**                cs_line_json = <fs_line> ).
**          ENDIF.
**
**          " Serialize and send when reaching max records per message
**          IF lv_max_records EQ gs_oc_obj-no_registros.
**            APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
**            <fs_json>-json_id = gv_jsonid.
**            <fs_json>-json =  zoncl_ui2_cl_json=>serialize(
**                data             = <fs_root>
**                compress         = abap_false
**                assoc_arrays     = abap_true
**                assoc_arrays_opt = abap_true
**                pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).
**
**            " Replace technical strings for compatibility
**            REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
**            REPLACE 'TABL'        WITH 'TABLE'        INTO <fs_json>-json.
**            gv_jsonid = gv_jsonid + 1.
**            CLEAR: lv_max_records, <fs_body>.
**            lv_send = abap_true.
**          ENDIF.
**        ENDLOOP.
**
**        "--------------------------------------------------------
**        " Serialize remaining records if limit not reached
**        "--------------------------------------------------------
**        IF lv_max_records LT gs_oc_obj-no_registros AND lv_send = abap_false.
**          APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
**          <fs_json>-json_id = gv_jsonid.
**          <fs_json>-json = zoncl_ui2_cl_json=>serialize(
**            data             = <fs_root>
**            compress         = abap_false
**            assoc_arrays     = abap_true
**            assoc_arrays_opt = abap_true
**            pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).
**
**          REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
**          REPLACE 'TABL'        WITH 'TABLE'        INTO <fs_json>-json.
**        ENDIF.
**
**        "--------------------------------------------------------
**        " Send each JSON payload and track result
**        "--------------------------------------------------------
**        LOOP AT gt_json INTO gs_json.
**
**          gv_json = gs_json-json.
**          gv_jsonid = gs_json-json_id.
**
**          IF gv_recordst_obj IS INITIAL.
**            gv_recordst_obj = 1.
**          ENDIF.
**
**          me->pretty_json_any(
**            EXPORTING
**              iv_mode = c_table
**            CHANGING
**              cv_json = gv_json ).
**
**          me->send_json_http_con_rap(
**            EXPORTING
**              i_dest     = gv_dest
**            IMPORTING
**              e_return   = lv_return
**              e_size     = e_size
**              e_records  = e_records
**              e_response = lv_response ).
**
**          gv_sizet    = gv_sizet + e_size.
**          gv_recordst = gv_recordst + 1.
**        ENDLOOP.
**
**        "--------------------------------------------------------
**        " Finalize logging and output
**        "--------------------------------------------------------
**        me->send_json_result( ).
**        me->update_slg1_log( it_log_ext = gt_log_ext ).
**
**      ENDIF.
**    ELSE.
**      CLEAR lv_message_v2.
**      lv_message_v2 = gv_entity.
**
**      me->append_slg1_log(
**        iv_tabname    = space
**        iv_message_v1 = 'No data found in table ZONTA_OBJ_OC for entity'
**        iv_message_v2 = lv_message_v2
**        iv_mestyp     = 'S' ).
**
**      me->update_slg1_log( it_log_ext = gt_log_ext ).
**    ENDIF.
**
**  ENDMETHOD.


  METHOD send_json_any_table.




    CONSTANTS: c_rawstring TYPE c VALUE 'y',
               c_string    TYPE c VALUE 'X',
               c_256       TYPE c LENGTH 6 VALUE '000256',
*BEGIN CECHAVARRIA 19/08/2025
               c_type      TYPE zonta_oc_param-type VALUE 'P',
               c_name      TYPE zonta_oc_param-name VALUE 'OPEN_MAX_RECORDS'.
*END CECHAVARRIA 19/08/2025

    "------------------------------------------------------------
    " Local Data Declarations
    "------------------------------------------------------------
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
          lv_exit         TYPE abap_bool,
          lv_max_records  TYPE zonde_registrosn,
          lv_where        TYPE rsds_where_tab,
          lv_alias        TYPE zonde_aliastab,
          lv_alias2       TYPE zonde_aliastab,
          lw_alias        TYPE zonta_oc_anyalia,
          lv_fields       TYPE string,
          lv_message_v2   TYPE string,
          lv_result       TYPE string,
          lv_error(200)   TYPE c,
          lo_ref          TYPE REF TO cx_sy_dynamic_osql_semantics,
          lo_msg          TYPE REF TO cx_root, "CECHAVARRIA 19/08/2025
          lt_fields       TYPE TABLE OF line,
          lv_tab          TYPE tabname,
          lv_error_stop   TYPE boolean,
          ls_dfies        LIKE LINE OF gt_dfies_tab,
          lv_send         TYPE boolean,
*BEGIN CECHAVARRIA 19/08/2025
          lv_cursor       TYPE cursor,
          lv_pakage       TYPE i,
          lv_count        TYPE i,
          lv_msg          TYPE char120,
          lv_low          TYPE zonta_oc_param-low.
*END CECHAVARRIA 19/08/2025


    DATA: lv_number     TYPE n LENGTH 10,
          lv_returncode TYPE inri-returncode,
          lv_object     TYPE inri-object,
          lt_dfies      TYPE TABLE OF dfies,
          lw_dfies      TYPE dfies,
          lw_col_all    TYPE zonta_oc_col_all.

    "------------------------------------------------------------
    " Field-Symbols
    "------------------------------------------------------------
    FIELD-SYMBOLS: <fs_root>            TYPE any,
                   <fs_oneconnect>      TYPE any,
                   <fs_properties>      TYPE any,
                   <fs_metadata>        TYPE any,
                   <fs_body_root>       TYPE any,
                   <fs_json>            LIKE LINE OF gt_json, "TYPE any,
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
                   <fs_keys_event>      TYPE LINE OF tty_where,
                   <fs_fcat>            LIKE LINE OF lt_fcat.


    "------------------------------------------------------------
    " Initialization and Global Variable Assignment
    "------------------------------------------------------------
     me->debug_procedure( ).

    lv_error_stop  = abap_false.
    gv_update    = iv_update.
    gv_delete    = iv_delete.
    gv_anytable  = iv_tabname.
    gv_aliastab  = iv_aliastab.
    gv_alias     = iv_alias."CECHAVARRIA 19/08/2025
    gt_where     = it_where.
    gv_entity    = 'ANY'.
    gv_domainv   = 'ANY'.
    gv_dest      = iv_dest.
    gv_fieldname = iv_fieldname.
    gv_bothnames = iv_bothnames.

    " Log start of processing
    me->append_slg1_log(
      EXPORTING
        iv_tabname    = space
        iv_message_v1 = '*** Any Table Process TABLE***'
        iv_message_v2 = space
        iv_message_v3 = space
        iv_mestyp     = 'S' ).

    "------------------------------------------------------------
    " Retrieve metadata: columns, ALV field catalog, and DFIES
    "------------------------------------------------------------
    SELECT * INTO TABLE gt_columns_all
      FROM zonta_oc_col_all
      WHERE tabname      = iv_tabname.
*        AND alias_tabname = iv_aliastab.


    IF sy-subrc NE 0.
      CLEAR lv_message_v2.
      lv_message_v2 = gv_entity.

      me->append_slg1_log(
        iv_tabname    = space
        iv_message_v1 = 'No data found in table ZONTA_OC_COL_ALL for entity'
        iv_message_v2 = lv_message_v2
        iv_mestyp     = 'S' ).

      me->update_slg1_log( it_log_ext = gt_log_ext ).
      RETURN.
    ENDIF.

    CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name = iv_tabname
      CHANGING
        ct_fieldcat      = lt_fcat
      EXCEPTIONS
        OTHERS           = 3.

    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname   = iv_tabname
      TABLES
        dfies_tab = gt_dfies_tab
      EXCEPTIONS
        OTHERS    = 3.

    IF sy-subrc <> 0.
      " Handle DFIES error if needed
    ENDIF.


    SORT gt_dfies_tab BY position fieldname.
    SORT lt_fcat BY fieldname.
    LOOP AT gt_dfies_tab INTO ls_dfies.
      READ TABLE lt_fcat ASSIGNING <fs_fcat> WITH KEY fieldname = ls_dfies-fieldname BINARY SEARCH.
      IF sy-subrc NE 0.
        APPEND INITIAL LINE TO lt_fcat ASSIGNING <fs_fcat>.
        MOVE-CORRESPONDING ls_dfies TO <fs_fcat>.
      ENDIF.

      <fs_fcat>-ddic_outputlen = ls_dfies-offset.
      <fs_fcat>-inttype        = ls_dfies-inttype.
      <fs_fcat>-decimals_out   = ls_dfies-decimals.
      <fs_fcat>-col_pos        = ls_dfies-position.
      <fs_fcat>-offset         = ls_dfies-offset.
      <fs_fcat>-outputlen      = ls_dfies-outputlen.

      IF <fs_fcat>-inttype = c_rawstring.
        <fs_fcat>-inttype = c_string.
        <fs_fcat>-ddic_outputlen = c_256.
      ENDIF.

      IF <fs_fcat>-seltext_l IS INITIAL.
        <fs_fcat>-seltext_l = ls_dfies-scrtext_l.
        <fs_fcat>-seltext_m = ls_dfies-scrtext_m.
        <fs_fcat>-seltext_s = ls_dfies-scrtext_s.
      ENDIF.
    ENDLOOP.

    SORT lt_fcat BY row_pos fieldname.

    "------------------------------------------------------------
    " Load base configuration object and destination if missing
    "------------------------------------------------------------
    SELECT SINGLE * INTO gs_oc_obj
      FROM zonta_obj_oc
      WHERE domainv       = 'ANY'
        AND business_proc = 'ANY'.

    IF sy-subrc EQ 0.
**Get parameter for open cursor
* Begin of change Dic2025
      lv_pakage = gs_oc_obj-no_registros.
* End of change Dic2025

      DATA lv_ali TYPE  rvari_val_255.
      DATA lv_ali2 TYPE  rvari_val_255.
      SELECT SINGLE low FROM zonta_oc_param INTO lv_ali WHERE name = 'USE_ALIAS'.
      IF sy-subrc = 0.
        IF lv_ali IS NOT INITIAL.
          SELECT SINGLE alias_tabname INTO lv_alias
            FROM zonta_oc_anyalia
            WHERE tabname = iv_tabname.
        ENDIF.
      ENDIF.
      SELECT SINGLE low FROM zonta_oc_param INTO lv_ali2 WHERE name = 'USE_ALIAS_ANY'.
      IF sy-subrc = 0.
        IF lv_ali2 IS NOT INITIAL.
          SELECT SINGLE alias_tabname INTO lv_alias2
            FROM zonta_oc_anyalia
            WHERE tabname = iv_tabname.
        ENDIF.
      ENDIF.
      IF gv_dest IS INITIAL.
        SELECT SINGLE low INTO gv_dest
          FROM zonta_oc_param
          WHERE name = 'RFC_DESTINATION'
            AND type = 'P'
            AND numb = 1.
      ENDIF.

      IF gv_dest IS NOT INITIAL. "sy-subrc EQ 0.

        "--------------------------------------------------------
        " Create root structure for ONECONNECT export
        "--------------------------------------------------------
        IF gs_oc_obj-data EQ abap_true.
          CREATE DATA dref_table_root TYPE ty_oneconnect_meta.
        ELSE.
          CREATE DATA dref_table_root TYPE ty_oneconnect.
        ENDIF.

        ASSIGN dref_table_root->* TO <fs_root>.
        ASSIGN COMPONENT 'ONECONNECT' OF STRUCTURE <fs_root> TO <fs_oneconnect>.
        ASSIGN COMPONENT 'PROPERTIES' OF STRUCTURE <fs_oneconnect> TO <fs_properties>.

        " Fill PROPERTIES node
        me->get_data_properties_any( CHANGING cs_properties = <fs_properties> ).

        ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_oneconnect> TO <fs_metadata_root>.
        APPEND INITIAL LINE TO <fs_metadata_root> ASSIGNING <fs_metadata>.
        ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_metadata> TO <fs_field_metadata>.

        " Set metadata field label (alias or table name)
        IF gv_fieldname IS INITIAL.
          IF NOT iv_bothnames IS INITIAL.
            <fs_field_metadata> = iv_tabname && '_' && lv_alias.
          ELSEIF NOT lv_alias IS INITIAL.
            <fs_field_metadata> = lv_alias.
          ELSEIF NOT lv_alias2 IS INITIAL.
            <fs_field_metadata> = lv_alias2.
          ELSE.
            <fs_field_metadata> = iv_tabname.
          ENDIF.
        ELSE.
          IF lv_ali2 IS INITIAL.
            <fs_field_metadata> = iv_tabname.
          ELSE.
            <fs_field_metadata> = lv_alias2.
          ENDIF.
        ENDIF.

        ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_metadata> TO <fs_metadata_line>.
        ASSIGN COMPONENT 'BODY' OF STRUCTURE <fs_oneconnect> TO <fs_body_root>.
        ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_body_root> TO <fs_field>.

        " Set field name for BODY node
        IF gv_fieldname IS INITIAL AND lv_ali2 IS INITIAL.
          IF NOT iv_bothnames IS INITIAL.
            <fs_field> = iv_tabname && '_' && lv_alias.
          ELSEIF NOT lv_alias IS INITIAL.
            <fs_field> = lv_alias.
          ELSEIF NOT lv_alias2 IS INITIAL.
            <fs_field> = lv_alias2.
          ELSE.
            <fs_field> = iv_tabname.
          ENDIF.
        ELSE.
          IF lv_ali2 IS INITIAL.
            <fs_field> = iv_tabname.
          ELSE.
            <fs_field> = lv_alias2.
          ENDIF.
        ENDIF.

        ASSIGN COMPONENT 'DATA' OF STRUCTURE <fs_body_root> TO <fs_table_body_line>.

        "--------------------------------------------------------
        " Create dynamic tables for BODY and result data
        "--------------------------------------------------------
        CALL METHOD me->set_table_any
          EXPORTING
            iv_alias = gv_alias
            it_fcat  = lt_fcat
          RECEIVING
            rt_table = <fs_table_body_line>.

        ASSIGN <fs_table_body_line>->* TO <fs_body>.

        CALL METHOD me->set_table_any
          EXPORTING
            iv_alias = gv_alias "iv_fieldname CHECK
            it_fcat  = lt_fcat
          RECEIVING
            rt_table = lo_data.

        ASSIGN lo_data->* TO <fs_table>.

        "--------------------------------------------------------
        " Compose WHERE and SELECT fields
        "--------------------------------------------------------
        IF gt_where IS INITIAL.
          lv_where = me->set_where_any( iv_any = abap_true ).
          me->set_process( IMPORTING ev_closed = lv_exit ).
          IF lv_exit EQ abap_true.
            RETURN.
          ENDIF.
          gt_where = lv_where.
        ELSE.
          lv_where = gt_where.
        ENDIF.

        IF lv_where IS INITIAL.
          MESSAGE i000(fb) WITH 'No filter selected'.
          RETURN.
        ENDIF.

        "--------------------------------------------------------
        " Run as Background Batch if Configured
        "--------------------------------------------------------
*BEGIN CECHAVARRIA 19/08/2025
        IF NOT gv_batch IS INITIAL.
          me->execute_batch(
            EXPORTING
              iv_anytab  = abap_true
              iv_tabname = iv_tabname ).
          RETURN.
        ENDIF.
*END CECHAVARRIA 19/08/2025
        "--------------------------------------------------------
        " Fill METADATA node
        "--------------------------------------------------------
        me->set_metadata_node_any(
          EXPORTING
*            iv_alias    = iv_fieldname
            iv_alias    = gv_fieldname
            it_fcat     = lt_fcat
          CHANGING
            ct_metadata = <fs_metadata_line> ).

        "--------------------------------------------------------
        " Fetch Data Dynamically (CDS or Transparent Table)
        "--------------------------------------------------------
        TRY.
*BEGIN CECHAVARRIA 19/08/2025
            lv_fields = me->set_fields( iv_alias = gv_alias ).
            OPEN CURSOR WITH HOLD lv_cursor FOR SELECT (lv_fields)  FROM (iv_tabname) WHERE (lv_where).
*END CECHAVARRIA 19/08/2025

            IF sy-subrc NE 0.
              MESSAGE i000(fb) WITH 'No data found'.

              me->append_slg1_log(
                EXPORTING
                  iv_tabname    = space
                  iv_message_v1 = 'No data found'
                  iv_message_v2 = space
                  iv_message_v3 = space
                  iv_mestyp     = 'S' ).
              me->send_json_result( ).
              RETURN.
            ENDIF.

          CATCH cx_sy_dynamic_osql_semantics INTO lo_ref.
            lv_result = lo_ref->get_text( ).
            lv_error  = lv_result.

            sy-msgv1 = lv_error+0(50).
            sy-msgv2 = lv_error+50(50).
            sy-msgv3 = lv_error+100(50).
            sy-msgv4 = lv_error+150(50).

            gs_elog-type       = 'SEND_JSON_ANY_TABLE'.
            gs_elog-severity   = gc_error.
            gs_elog-message    = lo_ref->get_longtext( ).
            CALL METHOD lo_ref->get_source_position
              IMPORTING
                program_name = gv_prog
                source_line  = gv_sline.
            gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
            gs_elog-details-db = 'ZONCL_OC_ANY_HANDLER-SEND_JSON_ANY_TABLE'.
            gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.


            gs_elog-metadata-error_code = gs_elog-details-error_code.
            interpret_message( EXPORTING iv_msgnr = '097' iv_msgv1 = iv_tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '098' iv_msgv1 = iv_tabname  IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '099' iv_msgv1 = iv_tabname  IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '100'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '101'  IMPORTING ev_message = gv_msg5 CHANGING ct_table = gt_causes ).
            CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 gv_msg5 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
            interpret_message( EXPORTING iv_msgnr = '076'  iv_msgv1 = iv_tabname IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '086'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '087'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_fixes ).
            CONCATENATE gv_msg1 gv_msg2 gv_msg3 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.
            print_error_otel( ).
            send_json_error( ).
            lv_error_stop = abap_true.
        ENDTRY.

        CHECK lv_error_stop = abap_false.


        "--------------------------------------------------------
        " Loop over selected data and build JSON objects
        "--------------------------------------------------------
*BEGIN CECHAVARRIA 19/08/2025
        CLEAR lv_count.
        DO.
          lv_count = sy-index.
          TRY.
              FETCH NEXT CURSOR lv_cursor
                INTO CORRESPONDING FIELDS OF TABLE <fs_table> PACKAGE SIZE lv_pakage.

              IF sy-subrc NE 0.
                CLOSE CURSOR lv_cursor.
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
              CLOSE CURSOR lv_cursor.
              lv_result = lo_msg->get_text( ).
              lv_error  = lv_result.

              sy-msgv1 = lv_error+0(50).
              sy-msgv2 = lv_error+50(50).
              sy-msgv3 = lv_error+100(50).
              sy-msgv4 = lv_error+150(50).


              gs_elog-type       = 'SEND_JSON_ANY_TABLE'.
              gs_elog-severity   = gc_error.
              gs_elog-message    = lo_msg->get_longtext( ).
              CALL METHOD lo_msg->get_source_position
                IMPORTING
                  program_name = gv_prog
                  source_line  = gv_sline.
              gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
              gs_elog-details-db = 'ZONCL_OC_ANY_HANDLER-SEND_JSON_ANY_TABLE'.
              gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.


              gs_elog-metadata-error_code = gs_elog-details-error_code.
              interpret_message( EXPORTING iv_msgnr = '097' iv_msgv1 = iv_tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
              interpret_message( EXPORTING iv_msgnr = '098' iv_msgv1 = iv_tabname  IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
              interpret_message( EXPORTING iv_msgnr = '099' iv_msgv1 = iv_tabname  IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
              interpret_message( EXPORTING iv_msgnr = '100'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
              interpret_message( EXPORTING iv_msgnr = '101'  IMPORTING ev_message = gv_msg5 CHANGING ct_table = gt_causes ).
              CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 gv_msg5 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
              interpret_message( EXPORTING iv_msgnr = '076'  iv_msgv1 = iv_tabname IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_fixes ).
              interpret_message( EXPORTING iv_msgnr = '086'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_fixes ).
              interpret_message( EXPORTING iv_msgnr = '087'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_fixes ).
              CONCATENATE gv_msg1 gv_msg2 gv_msg3 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.
              print_error_otel( ).
              send_json_error( ).
              EXIT.
          ENDTRY.
*END CECHAVARRIA 19/08/2025
*          gv_recordst = gv_recordst + lv_recordst.
          gs_log_json_result-recordst = gs_log_json_result-recordst + lv_recordst.

          CLEAR lt_keys.

          lv_send = abap_false.
          LOOP AT <fs_table> ASSIGNING <fs_data>.
            CLEAR lt_keys.

            " Generate key from line content
            CALL METHOD me->set_key_any
              EXPORTING
*               iv_alias = iv_alias
                iv_alias = gv_alias
                it_fcat  = lt_fcat
                is_line  = <fs_data>
              RECEIVING
                rv_key   = lv_key.

            ASSIGN lv_key TO <fs_key>.

            " Track new keys to count records
            IF lv_keys_temp NE lv_key.
              lv_keys_temp   = lv_key.
              lv_max_records = lv_max_records + 1.
*              gv_recordst_obj = gv_recordst_obj + 1.
              gs_log_json_result-recordst_obj = gs_log_json_result-recordst_obj + 1.
            ENDIF.

            " Log key to application log
            me->append_slg1_log(
              iv_tabname = iv_tabname
              iv_mestyp  = 'S'
              iv_key     = lv_key ).

            " Add line to body node
            APPEND INITIAL LINE TO <fs_body> ASSIGNING <fs_line>.
            MOVE-CORRESPONDING <fs_data> TO <fs_line>.

            " Apply conversion exit for display format
            me->conversion_exit(
              EXPORTING
                iv_tabname = iv_tabname
              CHANGING
                cs_string  = <fs_line> ).

            " Add event ID if configured
            IF gs_oc_obj-eventid  = abap_true OR
               gs_oc_obj-metadata = abap_true.

              IF <fs_key> IS ASSIGNED.
                APPEND INITIAL LINE TO lt_keys ASSIGNING <fs_keys_event>.
                <fs_keys_event>-line = <fs_key>.
              ENDIF.

              me->get_eventid(
                EXPORTING
                  it_keys      = lt_keys
                CHANGING
                  cs_line_json = <fs_line> ).
            ENDIF.

            " Serialize and send when reaching max records per message
            IF lv_max_records EQ gs_oc_obj-no_registros.
              APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
              <fs_json>-json_id = gv_jsonid.
              <fs_json>-json  = zoncl_ui2_cl_json=>serialize(
                    data             = <fs_root>
                    compress         = abap_false
                    assoc_arrays     = abap_true
                    assoc_arrays_opt = abap_true
                    pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).

              " Replace technical strings for compatibility
              REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
              REPLACE 'TABL'        WITH 'TABLE'        INTO <fs_json>-json.
              gv_jsonid = gv_jsonid + 1.
              CLEAR: lv_max_records, <fs_body>.
              lv_send = abap_true.
            ENDIF.
          ENDLOOP.

          "--------------------------------------------------------
          " Serialize remaining records if limit not reached
          "--------------------------------------------------------
          IF lv_max_records LT gs_oc_obj-no_registros AND lv_send = abap_false.
            IF lv_max_records = 0000."CECHAVARRIA 19/08/2025
              APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
              DELETE gt_json WHERE json IS INITIAL. "table_line = space."CECHAVARRIA 19/08/2025
              IF sy-subrc NE 0.
                <fs_json>-json_id = gv_jsonid.
                <fs_json>-json  = zoncl_ui2_cl_json=>serialize(
                        data             = <fs_root>
                        compress         = abap_false
                        assoc_arrays     = abap_true
                        assoc_arrays_opt = abap_true
                        pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).

                REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
                REPLACE 'TABL'        WITH 'TABLE'        INTO <fs_json>-json.
              ENDIF.

            ELSE."CECHAVARRIA 19/08/2025
              APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
              <fs_json>-json_id = gv_jsonid.
              <fs_json>-json  = zoncl_ui2_cl_json=>serialize(
                    data             = <fs_root>
                    compress         = abap_false
                    assoc_arrays     = abap_true
                    assoc_arrays_opt = abap_true
                    pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).

              REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
              REPLACE 'TABL'        WITH 'TABLE'        INTO <fs_json>-json.
              EXIT.  "db
            ENDIF."CECHAVARRIA 19/08/2025
          ENDIF.
        ENDDO.
        "--------------------------------------------------------
        " Send each JSON payload and track result
        "--------------------------------------------------------
        LOOP AT gt_json INTO gs_json.

          gv_json = gs_json-json.
          gv_jsonid = gs_json-json_id.

*          IF gv_recordst_obj IS INITIAL.
*            gv_recordst_obj = 1.
*          ENDIF.
          IF gs_log_json_result-recordst_obj IS INITIAL.
            gs_log_json_result-recordst_obj = 1.
          ENDIF.

          me->pretty_json_any(
            EXPORTING
              iv_mode = c_table
            CHANGING
              cv_json = gv_json ).

          me->send_json_http_con_rap(
              EXPORTING
                i_dest     = gv_dest
              IMPORTING
                e_return   = lv_return
                e_size     = e_size
                e_records  = e_records
                e_response = lv_response ).
          CONSTANTS :
            lc_error           TYPE char2 VALUE 'E',
            lc_process         TYPE char2 VALUE 'P',
            lc_type            TYPE zonta_oc_param-type VALUE 'P',
            lc_use_resend_json TYPE zonta_oc_param-name VALUE 'USE_RESEND_JSON'.

          DATA ls_paramter TYPE zonta_oc_param.
          IF e_size IS NOT INITIAL.
            IF me->gv_uuid IS NOT INITIAL.
              CLEAR ls_paramter.
              zoncl_json_save_log=>get_parameter_active_log(
                EXPORTING
                  iv_name_parameter = lc_use_resend_json
                  iv_type           = lc_type
                IMPORTING
                  es_parameter      = ls_paramter
              ).

              IF ls_paramter-low EQ abap_true.
                me->update_table_json(
                               iv_json = gv_json
                               iv_uuid = me->gv_uuid
                               iv_status_code = 'P'
                               iv_zoffset = e_size
                ).
              ELSE.
                DELETE FROM zonta_oc_fetch_r WHERE uuid_rec = me->gv_uuid.
              ENDIF.
            ENDIF.
          ELSE.
            IF me->gv_uuid IS NOT INITIAL.
              CLEAR ls_paramter.
              zoncl_json_save_log=>get_parameter_active_log(
                EXPORTING
                  iv_name_parameter = lc_use_resend_json
                  iv_type           = lc_type
                IMPORTING
                  es_parameter      = ls_paramter
              ).

              IF ls_paramter-low EQ abap_true.
                me->update_table_json(
                               iv_json = gv_json
                               iv_uuid = me->gv_uuid
                               iv_status_code = 'E'
                               iv_zoffset = e_size
                ).
              ELSE.
                DELETE FROM zonta_oc_fetch_r WHERE uuid_rec = me->gv_uuid.
              ENDIF.
            ENDIF.
          ENDIF.

*          gv_sizet    = gv_sizet + e_size.
*          gv_recordst = gv_recordst + 1.

          gs_log_json_result-sizet = gs_log_json_result-sizet + e_size.
          gs_log_json_result-recordst  = gs_log_json_result-recordst + 1.
        ENDLOOP.
        gv_jsonid = gv_jsonid + 1.
**BEGIN CECHAVARRIA 19/08/2025
        CLEAR: gt_json[], lv_max_records, <fs_body>.
*        ENDDO.  quitar Diana
*END CECHAVARRIA 19/08/2025
        "--------------------------------------------------------
        " Finalize logging and output
        "--------------------------------------------------------
        me->send_json_result( ).
        me->update_slg1_log( it_log_ext = gt_log_ext ).

      ENDIF.
    ELSE.
      CLEAR lv_message_v2.
      lv_message_v2 = gv_entity.

      me->append_slg1_log(
        iv_tabname    = space
        iv_message_v1 = 'No data found in table ZONTA_OBJ_OC for entity'
        iv_message_v2 = lv_message_v2
        iv_mestyp     = 'S' ).

      me->update_slg1_log( it_log_ext = gt_log_ext ).
    ENDIF.

  ENDMETHOD.

**
**  METHOD send_json_any_table.
**
**
**
**    CONSTANTS: c_rawstring TYPE c VALUE 'y',
**               c_string    TYPE c VALUE 'X',
**               c_256       TYPE c LENGTH 6 VALUE '000256',
***BEGIN CECHAVARRIA 19/08/2025
**               c_type      TYPE zonta_oc_param-type VALUE 'P',
**               c_name      TYPE zonta_oc_param-name VALUE 'OPEN_MAX_RECORDS'.
***END CECHAVARRIA 19/08/2025
**
**    "------------------------------------------------------------
**    " Local Data Declarations
**    "------------------------------------------------------------
**    DATA: dref_table_root TYPE REF TO data,
**          dref_table      TYPE REF TO data,
**          lo_table        TYPE REF TO data,
**          lo_data         TYPE REF TO data,
**          lt_fcat         TYPE slis_t_fieldcat_alv,
**          e_size          TYPE zonde_oc_num30,
**          e_records       TYPE zonde_oc_num30,
**          lt_keys         TYPE tty_where,
**          lv_return       TYPE string,
**          lv_recordst     TYPE sy-tabix,
**          lv_response     TYPE string,
**          lv_key          TYPE string,
**          lv_keys_temp    TYPE string,
**          lv_exit         TYPE abap_bool,
**          lv_max_records  TYPE zonde_registrosn,
**          lv_where        TYPE rsds_where_tab,
**          lv_alias        TYPE zonde_aliastab,
**          lv_alias2       TYPE zonde_aliastab,
**          lw_alias        TYPE zonta_oc_anyalia,
**          lv_fields       TYPE string,
**          lv_message_v2   TYPE string,
**          lv_result       TYPE string,
**          lv_error(200)   TYPE c,
**          lo_ref          TYPE REF TO cx_sy_dynamic_osql_semantics,
**          lo_msg          TYPE REF TO cx_root, "CECHAVARRIA 19/08/2025
**          lt_fields       TYPE TABLE OF line,
**          lv_tab          TYPE tabname,
**          lv_error_stop   TYPE boolean,
**          ls_dfies        LIKE LINE OF gt_dfies_tab,
**          lv_send         TYPE boolean,
***BEGIN CECHAVARRIA 19/08/2025
**          lv_cursor       TYPE cursor,
**          lv_pakage       TYPE i,
**          lv_count        TYPE i,
**          lv_msg          TYPE char120,
**          lv_low          TYPE zonta_oc_param-low.
***END CECHAVARRIA 19/08/2025
**
**
**    DATA: lv_number     TYPE n LENGTH 10,
**          lv_returncode TYPE inri-returncode,
**          lv_object     TYPE inri-object,
**          lt_dfies      TYPE TABLE OF dfies,
**          lw_dfies      TYPE dfies,
**          lw_col_all    TYPE zonta_oc_col_all.
**
**    "------------------------------------------------------------
**    " Field-Symbols
**    "------------------------------------------------------------
**    FIELD-SYMBOLS: <fs_root>            TYPE any,
**                   <fs_oneconnect>      TYPE any,
**                   <fs_properties>      TYPE any,
**                   <fs_metadata>        TYPE any,
**                   <fs_body_root>       TYPE any,
**                   <fs_json>            LIKE LINE OF gt_json, "TYPE any,
**                   <fs_field_metadata>  TYPE any,
**                   <fs_metadata_line>   TYPE any,
**                   <fs_field>           TYPE any,
**                   <fs_line>            TYPE any,
**                   <fs_table_body_line> TYPE any,
**                   <fs_body>            TYPE STANDARD TABLE,
**                   <fs_metadata_root>   TYPE STANDARD TABLE,
**                   <fs_table>           TYPE STANDARD TABLE,
**                   <fs_table2>          TYPE ANY TABLE,
**                   <fs_data>            TYPE any,
**                   <fs_table_line>      TYPE any,
**                   <fs_key>             TYPE any,
**                   <fs_key_main>        TYPE any,
**                   <fs_keys_event>      TYPE LINE OF tty_where,
**                   <fs_fcat>            LIKE LINE OF lt_fcat.
**
**
**    "------------------------------------------------------------
**    " Initialization and Global Variable Assignment
**    "------------------------------------------------------------
**    me->debug_procedure( ).
**
**    lv_error_stop  = abap_false.
**    gv_update    = iv_update.
**    gv_delete    = iv_delete.
**    gv_anytable  = iv_tabname.
**    gv_aliastab  = iv_aliastab.
**    gv_alias     = iv_alias."CECHAVARRIA 19/08/2025
**    gt_where     = it_where.
**    gv_entity    = 'ANY'.
**    gv_domainv   = 'ANY'.
**    gv_dest      = iv_dest.
**    gv_fieldname = iv_fieldname.
**    gv_bothnames = iv_bothnames.
**
**    " Log start of processing
**    me->append_slg1_log(
**      EXPORTING
**        iv_tabname    = space
**        iv_message_v1 = '*** Any Table Process TABLE***'
**        iv_message_v2 = space
**        iv_message_v3 = space
**        iv_mestyp     = 'S' ).
**
**    "------------------------------------------------------------
**    " Retrieve metadata: columns, ALV field catalog, and DFIES
**    "------------------------------------------------------------
**    SELECT * INTO TABLE gt_columns_all
**      FROM zonta_oc_col_all
**      WHERE tabname      = iv_tabname.
***        AND alias_tabname = iv_aliastab.
**
**
**    IF sy-subrc NE 0.
**      CLEAR lv_message_v2.
**      lv_message_v2 = gv_entity.
**
**      me->append_slg1_log(
**        iv_tabname    = space
**        iv_message_v1 = 'No data found in table ZONTA_OC_COL_ALL for entity'
**        iv_message_v2 = lv_message_v2
**        iv_mestyp     = 'S' ).
**
**      me->update_slg1_log( it_log_ext = gt_log_ext ).
**      RETURN.
**    ENDIF.
**
**    CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
**      EXPORTING
**        i_structure_name = iv_tabname
**      CHANGING
**        ct_fieldcat      = lt_fcat
**      EXCEPTIONS
**        OTHERS           = 3.
**
**    CALL FUNCTION 'DDIF_FIELDINFO_GET'
**      EXPORTING
**        tabname   = iv_tabname
**      TABLES
**        dfies_tab = gt_dfies_tab
**      EXCEPTIONS
**        OTHERS    = 3.
**
**    IF sy-subrc <> 0.
**      " Handle DFIES error if needed
**    ENDIF.
**
**
**    SORT gt_dfies_tab BY position fieldname.
**    SORT lt_fcat BY fieldname.
**    LOOP AT gt_dfies_tab INTO ls_dfies.
**      READ TABLE lt_fcat ASSIGNING <fs_fcat> WITH KEY fieldname = ls_dfies-fieldname BINARY SEARCH.
**      IF sy-subrc NE 0.
**        APPEND INITIAL LINE TO lt_fcat ASSIGNING <fs_fcat>.
**        MOVE-CORRESPONDING ls_dfies TO <fs_fcat>.
**      ENDIF.
**
**      <fs_fcat>-ddic_outputlen = ls_dfies-offset.
**      <fs_fcat>-inttype        = ls_dfies-inttype.
**      <fs_fcat>-decimals_out   = ls_dfies-decimals.
**      <fs_fcat>-col_pos        = ls_dfies-position.
**      <fs_fcat>-offset         = ls_dfies-offset.
**      <fs_fcat>-outputlen      = ls_dfies-outputlen.
**
**      IF <fs_fcat>-inttype = c_rawstring.
**        <fs_fcat>-inttype = c_string.
**        <fs_fcat>-ddic_outputlen = c_256.
**      ENDIF.
**
**      IF <fs_fcat>-seltext_l IS INITIAL.
**        <fs_fcat>-seltext_l = ls_dfies-scrtext_l.
**        <fs_fcat>-seltext_m = ls_dfies-scrtext_m.
**        <fs_fcat>-seltext_s = ls_dfies-scrtext_s.
**      ENDIF.
**    ENDLOOP.
**
**    SORT lt_fcat BY row_pos fieldname.
**
**    "------------------------------------------------------------
**    " Load base configuration object and destination if missing
**    "------------------------------------------------------------
**    SELECT SINGLE * INTO gs_oc_obj
**      FROM zonta_obj_oc
**      WHERE domainv       = 'ANY'
**        AND business_proc = 'ANY'.
**
**    IF sy-subrc EQ 0.
****Get parameter for open cursor
*** Begin of change Dic2025
**      lv_pakage = gs_oc_obj-no_registros.
*** End of change Dic2025
**
**      DATA lv_ali TYPE  rvari_val_255.
**      DATA lv_ali2 TYPE  rvari_val_255.
**      SELECT SINGLE low FROM zonta_oc_param INTO lv_ali WHERE name = 'USE_ALIAS'.
**      IF sy-subrc = 0.
**        IF lv_ali IS NOT INITIAL.
**          SELECT SINGLE alias_tabname INTO lv_alias
**            FROM zonta_oc_anyalia
**            WHERE tabname = iv_tabname.
**        ENDIF.
**      ENDIF.
**      SELECT SINGLE low FROM zonta_oc_param INTO lv_ali2 WHERE name = 'USE_ALIAS_ANY'.
**      IF sy-subrc = 0.
**        IF lv_ali2 IS NOT INITIAL.
**          SELECT SINGLE alias_tabname INTO lv_alias2
**            FROM zonta_oc_anyalia
**            WHERE tabname = iv_tabname.
**        ENDIF.
**      ENDIF.
**      IF gv_dest IS INITIAL.
**        SELECT SINGLE low INTO gv_dest
**          FROM zonta_oc_param
**          WHERE name = 'RFC_DESTINATION'
**            AND type = 'P'
**            AND numb = 1.
**      ENDIF.
**
**      IF sy-subrc EQ 0.
**
**        "--------------------------------------------------------
**        " Create root structure for ONECONNECT export
**        "--------------------------------------------------------
**        IF gs_oc_obj-data EQ abap_true.
**          CREATE DATA dref_table_root TYPE ty_oneconnect_meta.
**        ELSE.
**          CREATE DATA dref_table_root TYPE ty_oneconnect.
**        ENDIF.
**
**        ASSIGN dref_table_root->* TO <fs_root>.
**        ASSIGN COMPONENT 'ONECONNECT' OF STRUCTURE <fs_root> TO <fs_oneconnect>.
**        ASSIGN COMPONENT 'PROPERTIES' OF STRUCTURE <fs_oneconnect> TO <fs_properties>.
**
**        " Fill PROPERTIES node
**        me->get_data_properties_any( CHANGING cs_properties = <fs_properties> ).
**
**        ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_oneconnect> TO <fs_metadata_root>.
**        APPEND INITIAL LINE TO <fs_metadata_root> ASSIGNING <fs_metadata>.
**        ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_metadata> TO <fs_field_metadata>.
**
**        " Set metadata field label (alias or table name)
**        IF gv_fieldname IS INITIAL.
**          IF NOT iv_bothnames IS INITIAL.
**            <fs_field_metadata> = iv_tabname && '_' && lv_alias.
**          ELSEIF NOT lv_alias IS INITIAL.
**            <fs_field_metadata> = lv_alias.
**          ELSEIF NOT lv_alias2 IS INITIAL.
**            <fs_field_metadata> = lv_alias2.
**          ELSE.
**            <fs_field_metadata> = iv_tabname.
**          ENDIF.
**        ELSE.
**          IF lv_ali2 IS INITIAL.
**            <fs_field_metadata> = iv_tabname.
**          ELSE.
**            <fs_field_metadata> = lv_alias2.
**          ENDIF.
**        ENDIF.
**
**        ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_metadata> TO <fs_metadata_line>.
**        ASSIGN COMPONENT 'BODY' OF STRUCTURE <fs_oneconnect> TO <fs_body_root>.
**        ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_body_root> TO <fs_field>.
**
**        " Set field name for BODY node
**        IF gv_fieldname IS INITIAL AND lv_ali2 IS INITIAL.
**          IF NOT iv_bothnames IS INITIAL.
**            <fs_field> = iv_tabname && '_' && lv_alias.
**          ELSEIF NOT lv_alias IS INITIAL.
**            <fs_field> = lv_alias.
**          ELSEIF NOT lv_alias2 IS INITIAL.
**            <fs_field> = lv_alias2.
**          ELSE.
**            <fs_field> = iv_tabname.
**          ENDIF.
**        ELSE.
**          IF lv_ali2 IS INITIAL.
**            <fs_field> = iv_tabname.
**          ELSE.
**            <fs_field> = lv_alias2.
**          ENDIF.
**        ENDIF.
**
**        ASSIGN COMPONENT 'DATA' OF STRUCTURE <fs_body_root> TO <fs_table_body_line>.
**
**        "--------------------------------------------------------
**        " Create dynamic tables for BODY and result data
**        "--------------------------------------------------------
**        CALL METHOD me->set_table_any
**          EXPORTING
**            iv_alias = gv_alias
**            it_fcat  = lt_fcat
**          RECEIVING
**            rt_table = <fs_table_body_line>.
**
**        ASSIGN <fs_table_body_line>->* TO <fs_body>.
**
**        CALL METHOD me->set_table_any
**          EXPORTING
**            iv_alias = gv_alias "iv_fieldname CHECK
**            it_fcat  = lt_fcat
**          RECEIVING
**            rt_table = lo_data.
**
**        ASSIGN lo_data->* TO <fs_table>.
**
**        "--------------------------------------------------------
**        " Compose WHERE and SELECT fields
**        "--------------------------------------------------------
**        IF gt_where IS INITIAL.
**          lv_where = me->set_where_any( iv_any = abap_true ).
**          me->set_process( IMPORTING ev_closed = lv_exit ).
**          IF lv_exit EQ abap_true.
**            RETURN.
**          ENDIF.
**          gt_where = lv_where.
**        ELSE.
**          lv_where = gt_where.
**        ENDIF.
**
**        IF lv_where IS INITIAL.
**          MESSAGE i000(fb) WITH 'No filter selected'.
**          RETURN.
**        ENDIF.
**
**        "--------------------------------------------------------
**        " Run as Background Batch if Configured
**        "--------------------------------------------------------
***BEGIN CECHAVARRIA 19/08/2025
**        IF NOT gv_batch IS INITIAL.
**          me->execute_batch(
**            EXPORTING
**              iv_anytab  = abap_true
**              iv_tabname = iv_tabname ).
**          RETURN.
**        ENDIF.
***END CECHAVARRIA 19/08/2025
**        "--------------------------------------------------------
**        " Fill METADATA node
**        "--------------------------------------------------------
**        me->set_metadata_node_any(
**          EXPORTING
***            iv_alias    = iv_fieldname
**            iv_alias    = gv_fieldname
**            it_fcat     = lt_fcat
**          CHANGING
**            ct_metadata = <fs_metadata_line> ).
**
**        "--------------------------------------------------------
**        " Fetch Data Dynamically (CDS or Transparent Table)
**        "--------------------------------------------------------
**        TRY.
***BEGIN CECHAVARRIA 19/08/2025
**            lv_fields = me->set_fields( iv_alias = gv_alias ).
**            OPEN CURSOR WITH HOLD lv_cursor FOR SELECT (lv_fields)  FROM (iv_tabname) WHERE (lv_where).
***END CECHAVARRIA 19/08/2025
**
**            IF sy-subrc NE 0.
**              MESSAGE i000(fb) WITH 'No data found'.
**
**              me->append_slg1_log(
**                EXPORTING
**                  iv_tabname    = space
**                  iv_message_v1 = 'No data found'
**                  iv_message_v2 = space
**                  iv_message_v3 = space
**                  iv_mestyp     = 'S' ).
**              me->send_json_result( ).
**              RETURN.
**            ENDIF.
**
**          CATCH cx_sy_dynamic_osql_semantics INTO lo_ref.
**            lv_result = lo_ref->get_text( ).
**            lv_error  = lv_result.
**
**            sy-msgv1 = lv_error+0(50).
**            sy-msgv2 = lv_error+50(50).
**            sy-msgv3 = lv_error+100(50).
**            sy-msgv4 = lv_error+150(50).
**
**            gs_elog-type       = 'SEND_JSON_ANY_TABLE'.
**            gs_elog-severity   = gc_error.
**            gs_elog-message    = lo_ref->get_longtext( ).
**            CALL METHOD lo_ref->get_source_position
**              IMPORTING
**                program_name = gv_prog
**                source_line  = gv_sline.
**            gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
**            gs_elog-details-db = 'ZONCL_OC_ANY_HANDLER-SEND_JSON_ANY_TABLE'.
**            gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.
**
**
**            gs_elog-metadata-error_code = gs_elog-details-error_code.
**            interpret_message( EXPORTING iv_msgnr = '097' iv_msgv1 = iv_tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
**            interpret_message( EXPORTING iv_msgnr = '098' iv_msgv1 = iv_tabname  IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
**            interpret_message( EXPORTING iv_msgnr = '099' iv_msgv1 = iv_tabname  IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
**            interpret_message( EXPORTING iv_msgnr = '100'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
**            interpret_message( EXPORTING iv_msgnr = '101'  IMPORTING ev_message = gv_msg5 CHANGING ct_table = gt_causes ).
**            CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 gv_msg5 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
**            interpret_message( EXPORTING iv_msgnr = '076'  iv_msgv1 = iv_tabname IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_fixes ).
**            interpret_message( EXPORTING iv_msgnr = '086'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_fixes ).
**            interpret_message( EXPORTING iv_msgnr = '087'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_fixes ).
**            CONCATENATE gv_msg1 gv_msg2 gv_msg3 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.
**            print_error_otel( ).
**            send_json_error( ).
**            lv_error_stop = abap_true.
**        ENDTRY.
**
**        CHECK lv_error_stop = abap_false.
**
**
**        "--------------------------------------------------------
**        " Loop over selected data and build JSON objects
**        "--------------------------------------------------------
***BEGIN CECHAVARRIA 19/08/2025
**        CLEAR lv_count.
**        DO.
**          lv_count = sy-index.
**          TRY.
**              FETCH NEXT CURSOR lv_cursor
**                INTO CORRESPONDING FIELDS OF TABLE <fs_table> PACKAGE SIZE lv_pakage.
**
**              IF sy-subrc NE 0.
**                CLOSE CURSOR lv_cursor.
**                IF lv_count = 1.
**                  MESSAGE i000(fb) WITH 'No data found'.
**
**                  me->append_slg1_log(
**                    EXPORTING
**                      iv_tabname    = space
**                      iv_message_v1 = 'No data found'
**                      iv_message_v2 = space
**                      iv_message_v3 = space
**                      iv_mestyp     = 'S' ).
**
**                ENDIF.
**                EXIT.
**              ENDIF.
**            CATCH cx_root INTO lo_msg.
**              CLOSE CURSOR lv_cursor.
**              lv_result = lo_msg->get_text( ).
**              lv_error  = lv_result.
**
**              sy-msgv1 = lv_error+0(50).
**              sy-msgv2 = lv_error+50(50).
**              sy-msgv3 = lv_error+100(50).
**              sy-msgv4 = lv_error+150(50).
**
**
**              gs_elog-type       = 'SEND_JSON_ANY_TABLE'.
**              gs_elog-severity   = gc_error.
**              gs_elog-message    = lo_msg->get_longtext( ).
**              CALL METHOD lo_msg->get_source_position
**                IMPORTING
**                  program_name = gv_prog
**                  source_line  = gv_sline.
**              gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
**              gs_elog-details-db = 'ZONCL_OC_ANY_HANDLER-SEND_JSON_ANY_TABLE'.
**              gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.
**
**
**              gs_elog-metadata-error_code = gs_elog-details-error_code.
**              interpret_message( EXPORTING iv_msgnr = '097' iv_msgv1 = iv_tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
**              interpret_message( EXPORTING iv_msgnr = '098' iv_msgv1 = iv_tabname  IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
**              interpret_message( EXPORTING iv_msgnr = '099' iv_msgv1 = iv_tabname  IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
**              interpret_message( EXPORTING iv_msgnr = '100'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
**              interpret_message( EXPORTING iv_msgnr = '101'  IMPORTING ev_message = gv_msg5 CHANGING ct_table = gt_causes ).
**              CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 gv_msg5 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
**              interpret_message( EXPORTING iv_msgnr = '076'  iv_msgv1 = iv_tabname IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_fixes ).
**              interpret_message( EXPORTING iv_msgnr = '086'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_fixes ).
**              interpret_message( EXPORTING iv_msgnr = '087'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_fixes ).
**              CONCATENATE gv_msg1 gv_msg2 gv_msg3 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.
**              print_error_otel( ).
**              send_json_error( ).
**              EXIT.
**          ENDTRY.
***END CECHAVARRIA 19/08/2025
**          gv_recordst = gv_recordst + lv_recordst.
**
**          CLEAR lt_keys.
**
**          lv_send = abap_false.
**          LOOP AT <fs_table> ASSIGNING <fs_data>.
**            CLEAR lt_keys.
**
**            " Generate key from line content
**            CALL METHOD me->set_key_any
**              EXPORTING
***               iv_alias = iv_alias
**                iv_alias = gv_alias
**                it_fcat  = lt_fcat
**                is_line  = <fs_data>
**              RECEIVING
**                rv_key   = lv_key.
**
**            ASSIGN lv_key TO <fs_key>.
**
**            " Track new keys to count records
**            IF lv_keys_temp NE lv_key.
**              lv_keys_temp   = lv_key.
**              lv_max_records = lv_max_records + 1.
**              gv_recordst_obj = gv_recordst_obj + 1.
**            ENDIF.
**
**            " Log key to application log
**            me->append_slg1_log(
**              iv_tabname = iv_tabname
**              iv_mestyp  = 'S'
**              iv_key     = lv_key ).
**
**            " Add line to body node
**            APPEND INITIAL LINE TO <fs_body> ASSIGNING <fs_line>.
**            MOVE-CORRESPONDING <fs_data> TO <fs_line>.
**
**            " Apply conversion exit for display format
**            me->conversion_exit(
**              EXPORTING
**                iv_tabname = iv_tabname
**              CHANGING
**                cs_string  = <fs_line> ).
**
**            " Add event ID if configured
**            IF gs_oc_obj-eventid  = abap_true OR
**               gs_oc_obj-metadata = abap_true.
**
**              IF <fs_key> IS ASSIGNED.
**                APPEND INITIAL LINE TO lt_keys ASSIGNING <fs_keys_event>.
**                <fs_keys_event>-line = <fs_key>.
**              ENDIF.
**
**              me->get_eventid(
**                EXPORTING
**                  it_keys      = lt_keys
**                CHANGING
**                  cs_line_json = <fs_line> ).
**            ENDIF.
**
**            " Serialize and send when reaching max records per message
**            IF lv_max_records EQ gs_oc_obj-no_registros.
**              APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
**              <fs_json>-json_id = gv_jsonid.
**              <fs_json>-json  = zoncl_ui2_cl_json=>serialize(
**                    data             = <fs_root>
**                    compress         = abap_false
**                    assoc_arrays     = abap_true
**                    assoc_arrays_opt = abap_true
**                    pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).
**
**              " Replace technical strings for compatibility
**              REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
**              REPLACE 'TABL'        WITH 'TABLE'        INTO <fs_json>-json.
**              gv_jsonid = gv_jsonid + 1.
**              CLEAR: lv_max_records, <fs_body>.
**              lv_send = abap_true.
**            ENDIF.
**          ENDLOOP.
**
**          "--------------------------------------------------------
**          " Serialize remaining records if limit not reached
**          "--------------------------------------------------------
**          IF lv_max_records LT gs_oc_obj-no_registros AND lv_send = abap_false.
**            IF lv_max_records = 0000."CECHAVARRIA 19/08/2025
**              APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
**              DELETE gt_json WHERE json IS INITIAL. "table_line = space."CECHAVARRIA 19/08/2025
**              IF sy-subrc NE 0.
**                <fs_json>-json_id = gv_jsonid.
**                <fs_json>-json  = zoncl_ui2_cl_json=>serialize(
**                        data             = <fs_root>
**                        compress         = abap_false
**                        assoc_arrays     = abap_true
**                        assoc_arrays_opt = abap_true
**                        pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).
**
**                REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
**                REPLACE 'TABL'        WITH 'TABLE'        INTO <fs_json>-json.
**              ENDIF.
**
**            ELSE."CECHAVARRIA 19/08/2025
**              APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
**              <fs_json>-json_id = gv_jsonid.
**              <fs_json>-json  = zoncl_ui2_cl_json=>serialize(
**                    data             = <fs_root>
**                    compress         = abap_false
**                    assoc_arrays     = abap_true
**                    assoc_arrays_opt = abap_true
**                    pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).
**
**              REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
**              REPLACE 'TABL'        WITH 'TABLE'        INTO <fs_json>-json.
**              EXIT.  "db
**            ENDIF."CECHAVARRIA 19/08/2025
**          ENDIF.
**        ENDDO.
**        "--------------------------------------------------------
**        " Send each JSON payload and track result
**        "--------------------------------------------------------
**        LOOP AT gt_json INTO gs_json.
**
**          gv_json = gs_json-json.
**          gv_jsonid = gs_json-json_id.
**
**          IF gv_recordst_obj IS INITIAL.
**            gv_recordst_obj = 1.
**          ENDIF.
**
**          me->pretty_json_any(
**            EXPORTING
**              iv_mode = c_table
**            CHANGING
**              cv_json = gv_json ).
**
**          me->send_json_http_con_rap(
**              EXPORTING
**                i_dest     = gv_dest
**              IMPORTING
**                e_return   = lv_return
**                e_size     = e_size
**                e_records  = e_records
**                e_response = lv_response ).
**          CONSTANTS :
**            lc_error           TYPE char2 VALUE 'E',
**            lc_process         TYPE char2 VALUE 'P',
**            lc_type            TYPE zonta_oc_param-type VALUE 'P',
**            lc_use_resend_json TYPE zonta_oc_param-name VALUE 'USE_RESEND_JSON'.
**
**          DATA ls_paramter TYPE zonta_oc_param.
**          IF e_size IS NOT INITIAL.
**            IF me->gv_uuid IS NOT INITIAL.
**              CLEAR ls_paramter.
***              zoncl_json_save_log=>get_parameter_active_log(
***                EXPORTING
***                  iv_name_parameter = lc_use_resend_json
***                  iv_type           = lc_type
***                IMPORTING
***                  es_parameter      = ls_paramter
***              ).
**
**              IF ls_paramter-low EQ abap_true.
**                me->update_table_json(
**                               iv_json = gv_json
**                               iv_uuid = me->gv_uuid
**                               iv_status_code = 'P'
**                               iv_zoffset = e_size
**                ).
**              ELSE.
***                DELETE FROM zonta_oc_fetch_r WHERE uuid_rec = me->gv_uuid.
**              ENDIF.
**            ENDIF.
**          ELSE.
**            IF me->gv_uuid IS NOT INITIAL.
**              CLEAR ls_paramter.
***              zoncl_json_save_log=>get_parameter_active_log(
***                EXPORTING
***                  iv_name_parameter = lc_use_resend_json
***                  iv_type           = lc_type
***                IMPORTING
***                  es_parameter      = ls_paramter
***              ).
**
**              IF ls_paramter-low EQ abap_true.
**                me->update_table_json(
**                               iv_json = gv_json
**                               iv_uuid = me->gv_uuid
**                               iv_status_code = 'E'
**                               iv_zoffset = e_size
**                ).
**              ELSE.
***                DELETE FROM zonta_oc_fetch_r WHERE uuid_rec = me->gv_uuid.
**              ENDIF.
**            ENDIF.
**          ENDIF.
**
**          gv_sizet    = gv_sizet + e_size.
**          gv_recordst = gv_recordst + 1.
**        ENDLOOP.
**        gv_jsonid = gv_jsonid + 1.
****BEGIN CECHAVARRIA 19/08/2025
**        CLEAR: gt_json[], lv_max_records, <fs_body>.
***        ENDDO.  quitar Diana
***END CECHAVARRIA 19/08/2025
**        "--------------------------------------------------------
**        " Finalize logging and output
**        "--------------------------------------------------------
**        me->send_json_result( ).
**        me->update_slg1_log( it_log_ext = gt_log_ext ).
**
**      ENDIF.
**    ELSE.
**      CLEAR lv_message_v2.
**      lv_message_v2 = gv_entity.
**
**      me->append_slg1_log(
**        iv_tabname    = space
**        iv_message_v1 = 'No data found in table ZONTA_OBJ_OC for entity'
**        iv_message_v2 = lv_message_v2
**        iv_mestyp     = 'S' ).
**
**      me->update_slg1_log( it_log_ext = gt_log_ext ).
**    ENDIF.
**
**  ENDMETHOD.


  METHOD send_json_any_table_cds.

    CONSTANTS: c_rawstring TYPE c VALUE 'y',
               c_string    TYPE c VALUE 'X',
               c_256       TYPE c LENGTH 6 VALUE '000256',
*BEGIN CECHAVARRIA 19/08/2025
               c_type      TYPE zonta_oc_param-type VALUE 'P',
               c_name      TYPE zonta_oc_param-name VALUE 'OPEN_MAX_RECORDS'.
*END CECHAVARRIA 19/08/2025

    "------------------------------------------------------------
    " Local Data Declarations
    "------------------------------------------------------------
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
          lv_message_v2   TYPE string,
          lv_exit         TYPE abap_bool,
          lv_result       TYPE string,
          lv_error(200)   TYPE c,
          lo_ref          TYPE REF TO cx_sy_dynamic_osql_semantics,
          lt_fields       TYPE TABLE OF line,
          lv_tab          TYPE tabname,
          lv_error_stop   TYPE boolean,
          lv_send         TYPE boolean,
          ls_dfies        LIKE LINE OF gt_dfies_tab,
*BEGIN CECHAVARRIA 19/08/2025,
          lv_msg          TYPE char40,
          lv_cursor       TYPE cursor,
          lv_pakage       TYPE i,
          lv_low          TYPE zonta_oc_param-low.
*END CECHAVARRIA 19/08/2025

    "------------------------------------------------------------
    " Field-Symbols
    "------------------------------------------------------------
    FIELD-SYMBOLS: <fs_root>            TYPE any,
                   <fs_oneconnect>      TYPE any,
                   <fs_properties>      TYPE any,
                   <fs_metadata>        TYPE any,
                   <fs_body_root>       TYPE any,
                   <fs_json>            LIKE LINE OF gt_json, "TYPE any,
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
                   <fs_keys_event>      TYPE LINE OF tty_where,
                   <fs_fcat>            LIKE LINE OF lt_fcat.


    "------------------------------------------------------------
    " Initialization and Global Variable Assignment
    "------------------------------------------------------------
    me->debug_procedure( ).

    lv_error_stop  = abap_false.
    gv_update    = iv_update.
    gv_delete    = iv_delete.
    gv_anytable  = iv_tabname.
    gv_aliastab  = iv_aliastab.
    gv_alias     = iv_alias."CECHAVARRIA 19/08/2025
    gt_where     = it_where.
    gv_entity    = 'ANY'.
    gv_domainv   = 'ANY'.
    gv_dest      = iv_dest.
    gv_fieldname = iv_fieldname.
    gv_bothnames = iv_bothnames.

    " Log start of processing
    me->append_slg1_log(
      EXPORTING
        iv_tabname    = space
        iv_message_v1 = '*** Any Table Process TABLE***'
        iv_message_v2 = space
        iv_message_v3 = space
        iv_mestyp     = 'S' ).

*BEGIN CECHAVARRIA 19/08/2025
*    IF sy-batch = abap_true.
*      CLEAR: gv_alias.
*      gv_fieldname = abap_true.
*    ENDIF.
*Get parameter for open cursor
**    SELECT SINGLE low
**       INTO lv_low
**       FROM zonta_oc_param
**       WHERE name =  c_name
**          AND type = c_type.
**    IF  sy-subrc EQ 0.
**      lv_pakage = lv_low.
**      IF lv_pakage <= 0.
**        lv_pakage = 1000.
**      ENDIF.
**    ELSE.
**      lv_pakage = 1000.
**    ENDIF.
***END CECHAVARRIA 19/08/2025

    "------------------------------------------------------------
    " Retrieve metadata: columns, ALV field catalog, and DFIES
    "------------------------------------------------------------
    SELECT * INTO TABLE gt_columns_all
      FROM zonta_oc_col_all
      WHERE tabname      = iv_tabname
        AND alias_tabname = iv_aliastab.

    IF sy-subrc NE 0.
      CLEAR lv_message_v2.
      lv_message_v2 = gv_entity.

      me->append_slg1_log(
        iv_tabname    = space
        iv_message_v1 = 'No data found in table ZONTA_OC_COL_ALL for entity'
        iv_message_v2 = lv_message_v2
        iv_mestyp     = 'S' ).

      me->update_slg1_log( it_log_ext = gt_log_ext ).
      RETURN.
    ENDIF.

    CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name = iv_tabname
      CHANGING
        ct_fieldcat      = lt_fcat
      EXCEPTIONS
        OTHERS           = 3.

    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname   = iv_tabname
      TABLES
        dfies_tab = gt_dfies_tab
      EXCEPTIONS
        OTHERS    = 3.

    IF sy-subrc <> 0.
      " Handle DFIES error if needed
    ENDIF.


    SORT gt_dfies_tab BY position fieldname.
    SORT lt_fcat BY fieldname.
    LOOP AT gt_dfies_tab INTO ls_dfies.
      READ TABLE lt_fcat ASSIGNING <fs_fcat> WITH KEY fieldname = ls_dfies-fieldname BINARY SEARCH.
      IF sy-subrc NE 0.
        APPEND INITIAL LINE TO lt_fcat ASSIGNING <fs_fcat>.
        MOVE-CORRESPONDING ls_dfies TO <fs_fcat>.
      ENDIF.

      <fs_fcat>-ddic_outputlen = ls_dfies-offset.
      <fs_fcat>-inttype        = ls_dfies-inttype.
      <fs_fcat>-decimals_out   = ls_dfies-decimals.
      <fs_fcat>-col_pos        = ls_dfies-position.
      <fs_fcat>-offset         = ls_dfies-offset.
      <fs_fcat>-outputlen      = ls_dfies-outputlen.

      IF <fs_fcat>-inttype = c_rawstring.
        <fs_fcat>-inttype = c_string.
        <fs_fcat>-ddic_outputlen = c_256.
      ENDIF.

      IF <fs_fcat>-seltext_l IS INITIAL.
        <fs_fcat>-seltext_l = ls_dfies-scrtext_l.
        <fs_fcat>-seltext_m = ls_dfies-scrtext_m.
        <fs_fcat>-seltext_s = ls_dfies-scrtext_s.
      ENDIF.
    ENDLOOP.

    SORT lt_fcat BY row_pos fieldname.

    "------------------------------------------------------------
    " Load base configuration object and destination if missing
    "------------------------------------------------------------
    SELECT SINGLE * INTO gs_oc_obj
      FROM zonta_obj_oc
      WHERE domainv       = 'ANY'
        AND business_proc = 'ANY'.

    IF sy-subrc EQ 0.
**Get parameter for open cursor
* Begin of change Dic2025
      lv_pakage = gs_oc_obj-no_registros.
* End of change Dic2025

      DATA lv_ali TYPE  rvari_val_255.
      SELECT SINGLE low FROM zonta_oc_param INTO lv_ali WHERE name = 'USE_ALIAS'.
      IF sy-subrc = 0.
        IF lv_ali IS NOT INITIAL.
          SELECT SINGLE alias_tabname INTO lv_alias
            FROM zonta_oc_anyalia
            WHERE tabname = iv_tabname.
        ENDIF.
      ENDIF.
      IF gv_dest IS INITIAL.
        SELECT SINGLE low INTO gv_dest
          FROM zonta_oc_param
          WHERE name = 'RFC_DESTINATION'
            AND type = 'P'
            AND numb = 1.
      ENDIF.

      IF gv_dest IS NOT INITIAL. "sy-subrc EQ 0.

        "--------------------------------------------------------
        " Create root structure for ONECONNECT export
        "--------------------------------------------------------
        IF gs_oc_obj-data EQ abap_true.
          CREATE DATA dref_table_root TYPE ty_oneconnect_meta.
        ELSE.
          CREATE DATA dref_table_root TYPE ty_oneconnect.
        ENDIF.

        ASSIGN dref_table_root->* TO <fs_root>.
        ASSIGN COMPONENT 'ONECONNECT' OF STRUCTURE <fs_root> TO <fs_oneconnect>.
        ASSIGN COMPONENT 'PROPERTIES' OF STRUCTURE <fs_oneconnect> TO <fs_properties>.

        " Fill PROPERTIES node
        me->get_data_properties_any( CHANGING cs_properties = <fs_properties> ).

        ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_oneconnect> TO <fs_metadata_root>.
        APPEND INITIAL LINE TO <fs_metadata_root> ASSIGNING <fs_metadata>.
        ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_metadata> TO <fs_field_metadata>.

        " Set metadata field label (alias or table name)
*        IF iv_fieldname IS INITIAL.
        IF gv_fieldname IS INITIAL.
          IF NOT iv_bothnames IS INITIAL.
            <fs_field_metadata> = iv_tabname && '_' && lv_alias.
          ELSEIF NOT lv_alias IS INITIAL.
            <fs_field_metadata> = lv_alias.
          ELSE.
            <fs_field_metadata> = iv_tabname.
          ENDIF.
        ELSE.
          <fs_field_metadata> = iv_tabname.
        ENDIF.

        ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_metadata> TO <fs_metadata_line>.
        ASSIGN COMPONENT 'BODY' OF STRUCTURE <fs_oneconnect> TO <fs_body_root>.
        ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_body_root> TO <fs_field>.

        " Set field name for BODY node
*        IF iv_fieldname IS INITIAL.
        IF gv_fieldname IS INITIAL.
          IF NOT iv_bothnames IS INITIAL.
            <fs_field> = iv_tabname && '_' && lv_alias.
          ELSEIF NOT lv_alias IS INITIAL.
            <fs_field> = lv_alias.
          ELSE.
            <fs_field> = iv_tabname.
          ENDIF.
        ELSE.
          <fs_field> = iv_tabname.
        ENDIF.

        ASSIGN COMPONENT 'DATA' OF STRUCTURE <fs_body_root> TO <fs_table_body_line>.

        "--------------------------------------------------------
        " Create dynamic tables for BODY and result data
        "--------------------------------------------------------
        CALL METHOD me->set_table_any
          EXPORTING
*           iv_alias = iv_alias
            iv_alias = gv_alias
            it_fcat  = lt_fcat
          RECEIVING
            rt_table = <fs_table_body_line>.

        ASSIGN <fs_table_body_line>->* TO <fs_body>.

        CALL METHOD me->set_table_any
          EXPORTING
*           iv_alias = iv_alias "iv_fieldname CHECK
            iv_alias = gv_alias "iv_fieldname CHECK
            it_fcat  = lt_fcat
          RECEIVING
            rt_table = lo_data.

        ASSIGN lo_data->* TO <fs_table>.

        "--------------------------------------------------------
        " Compose WHERE and SELECT fields
        "--------------------------------------------------------
*      lv_fields = me->set_fields( iv_alias = iv_alias ).


        IF gt_where IS INITIAL.
          lv_where = me->set_where_any( iv_any = abap_true ).
          me->set_process( IMPORTING ev_closed = lv_exit ).
          IF lv_exit EQ abap_true.
            RETURN.
          ENDIF.
          gt_where = lv_where.
        ELSE.
          lv_where = gt_where.
        ENDIF.

        IF lv_where IS INITIAL.
          MESSAGE i000(fb) WITH 'No filter selected'.
          RETURN.
        ENDIF.

        "--------------------------------------------------------
        " Run as Background Batch if Configured
        "--------------------------------------------------------
*BEGIN CECHAVARRIA 19/08/2025
        IF NOT gv_batch IS INITIAL.
          me->execute_batch(
            EXPORTING
              iv_anytab  = abap_true
              iv_tabname = iv_tabname ).
          RETURN.
        ENDIF.
*END CECHAVARRIA 19/08/2025
        "--------------------------------------------------------
        " Fill METADATA node
        "--------------------------------------------------------
        me->set_metadata_node_any(
          EXPORTING
            iv_alias    = gv_fieldname
            it_fcat     = lt_fcat
          CHANGING
            ct_metadata = <fs_metadata_line> ).

        "--------------------------------------------------------
        " Fetch Data Dynamically (CDS or Transparent Table)
        "--------------------------------------------------------
        TRY.
*            IF is_cds_entity( iv_tabname ) = abap_true.
            me->set_fields_in_table(
              EXPORTING
                iv_tabname = iv_tabname
                iv_alias   = gv_alias
              IMPORTING
                et_fields  = lt_fields ).

*BEGIN CECHAVARRIA 19/08/2025
            SELECT (lt_fields) FROM (iv_tabname)
              WHERE (lv_where)
              INTO CORRESPONDING FIELDS OF TABLE @<fs_table>
              PACKAGE SIZE @lv_pakage.

*              gv_recordst = gv_recordst + lv_recordst.
              gs_log_json_result-recordst = gs_log_json_result-recordst + lv_recordst.

              CLEAR lt_keys.

              lv_send = abap_false.
              LOOP AT <fs_table> ASSIGNING <fs_data>.
                CLEAR lt_keys.

                " Generate key from line content
                CALL METHOD me->set_key_any
                  EXPORTING
                    iv_alias = gv_alias
                    it_fcat  = lt_fcat
                    is_line  = <fs_data>
                  RECEIVING
                    rv_key   = lv_key.

                ASSIGN lv_key TO <fs_key>.

                " Track new keys to count records
                IF lv_keys_temp NE lv_key.
                  lv_keys_temp   = lv_key.
                  lv_max_records = lv_max_records + 1.
*                  gv_recordst_obj = gv_recordst_obj + 1.
                  gs_log_json_result-recordst_obj = gs_log_json_result-recordst_obj + 1.
                ENDIF.

                " Log key to application log
                me->append_slg1_log(
                  iv_tabname = iv_tabname
                  iv_mestyp  = 'S'
                  iv_key     = lv_key ).

                " Add line to body node
                APPEND INITIAL LINE TO <fs_body> ASSIGNING <fs_line>.
                MOVE-CORRESPONDING <fs_data> TO <fs_line>.

                " Apply conversion exit for display format
                me->conversion_exit(
                  EXPORTING
                    iv_tabname = iv_tabname
                  CHANGING
                    cs_string  = <fs_line> ).

                " Add event ID if configured
                IF gs_oc_obj-eventid  = abap_true OR
                   gs_oc_obj-metadata = abap_true.

                  IF <fs_key> IS ASSIGNED.
                    APPEND INITIAL LINE TO lt_keys ASSIGNING <fs_keys_event>.
                    <fs_keys_event>-line = <fs_key>.
                  ENDIF.

                  me->get_eventid(
                    EXPORTING
                      it_keys      = lt_keys
                    CHANGING
                      cs_line_json = <fs_line> ).
                ENDIF.

                " Serialize and send when reaching max records per message
                IF lv_max_records EQ gs_oc_obj-no_registros.
                  APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
                  <fs_json>-json_id = gv_jsonid.
                  <fs_json>-json = zoncl_ui2_cl_json=>serialize(
                            data             = <fs_root>
                            compress         = abap_false
                            assoc_arrays     = abap_true
                            assoc_arrays_opt = abap_true
                            pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).

                  " Replace technical strings for compatibility
                  REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
                  REPLACE 'TABL'        WITH 'TABLE'        INTO <fs_json>-json.
                  gv_jsonid = gv_jsonid + 1.
                  CLEAR: lv_max_records, <fs_body>.
                  lv_send = abap_true.
                ENDIF.
              ENDLOOP.

              "--------------------------------------------------------
              " Serialize remaining records if limit not reached
              "--------------------------------------------------------
              IF lv_max_records LT gs_oc_obj-no_registros AND lv_send = abap_false.
                IF lv_max_records = 0000.
                  APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
                  DELETE gt_json WHERE json IS INITIAL. "table_line = space.
                  IF sy-subrc NE 0.
                    <fs_json>-json_id = gv_jsonid.
                    <fs_json>-json = zoncl_ui2_cl_json=>serialize(
                                data             = <fs_root>
                                compress         = abap_false
                                assoc_arrays     = abap_true
                                assoc_arrays_opt = abap_true
                                pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).

                    REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
                    REPLACE 'TABL'        WITH 'TABLE'        INTO <fs_json>-json.
                  ENDIF.
                ELSE.
                  APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
                  <fs_json>-json_id = gv_jsonid.
                  <fs_json>-json =  zoncl_ui2_cl_json=>serialize(
                            data             = <fs_root>
                            compress         = abap_false
                            assoc_arrays     = abap_true
                            assoc_arrays_opt = abap_true
                            pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).

                  REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
                  REPLACE 'TABL'        WITH 'TABLE'        INTO <fs_json>-json.
                ENDIF.
              ENDIF.

              "--------------------------------------------------------
              " Send each JSON payload and track result
              "--------------------------------------------------------
              LOOP AT gt_json INTO gs_json.

                gv_json = gs_json-json.
                gv_jsonid = gs_json-json_id.

*                IF gv_recordst_obj IS INITIAL.
*                  gv_recordst_obj = 1.
*                ENDIF.
                IF gs_log_json_result-recordst_obj IS INITIAL.
                  gs_log_json_result-recordst_obj = 1.
                ENDIF.


                me->pretty_json_any(
                  EXPORTING
                    iv_mode = c_table
                  CHANGING
                    cv_json = gv_json ).

                CALL FUNCTION 'ZONFM_ONE_CONNECT_CURSOR_UPDAT' IN UPDATE TASK
                  EXPORTING
                    iv_dest               = gv_dest
                    iv_json               = gv_json
                  IMPORTING
                    ev_return             = lv_return
                    ev_size               = e_size
                    ev_records            = e_records
                    ev_response           = lv_response
                  EXCEPTIONS
                    communication_failure = 1
                    system_failure        = 2
                    resource_failure      = 3.

*                CALL FUNCTION 'ZONFM_ONE_CONNECT_OPENCURSOR' STARTING NEW TASK 'OPEN_CUR'
*                  DESTINATION 'NONE'
*                  CALLING respon_fm_parallel ON END OF TASK
*                  EXPORTING
*                    iv_dest               = gv_dest
*                    iv_json               = gv_json
*                  EXCEPTIONS
*                    communication_failure = 1 MESSAGE lv_msg
*                    system_failure        = 2 MESSAGE lv_msg
*                    resource_failure      = 3.

                CASE sy-subrc.
                  WHEN 0.
                  WHEN 1.
                    MESSAGE lv_msg TYPE 'I'.
                  WHEN 2.
                    MESSAGE lv_msg TYPE 'I'.
                  WHEN 3.
                    WAIT UNTIL me->gv_size IS NOT INITIAL UP TO 5 SECONDS.
                    IF sy-subrc NE 0.
                      MESSAGE 'Resource Failure' TYPE 'I'.
                    ENDIF.
                  WHEN OTHERS.
                    MESSAGE 'Other error' TYPE 'I'.
                ENDCASE.

                WAIT UNTIL me->gv_size IS NOT INITIAL UP TO 5 SECONDS.

*                lv_return = me->gv_return.
*                e_size = me->gv_size.
*                e_records = me->gv_size.
*                lv_response = me->gv_response_fm.

*                gv_sizet    = gv_sizet + e_size.
*                gv_recordst = gv_recordst + 1.

                gs_log_json_result-sizet    = gs_log_json_result-sizet + e_size.
                gs_log_json_result-recordst = gs_log_json_result-recordst + 1.

*                CALL FUNCTION 'RFC_CONNECTION_CLOSE'
*                  EXPORTING
*                    destination          = 'NONE'
*                    taskname             = 'OPEN_CUR'
*                  EXCEPTIONS
*                    destination_not_open = 1
*                    OTHERS               = 2.
*                IF sy-subrc <> 0.
** Implement suitable error handling here
*                ENDIF.
              ENDLOOP.
              gv_jsonid = gv_jsonid + 1.
              CLEAR: gt_json[], lv_max_records, <fs_body>.
*                     <fs_table>.

            ENDSELECT.

            COMMIT WORK.


*              RETURN.
*END CECHAVARRIA 19/08/2025
*            ELSE.
*              lv_fields = me->set_fields( iv_alias = iv_alias ).
*            lv_fields = me->set_fields( iv_alias = gv_alias ).
*              SELECT (lv_fields)
*                INTO CORRESPONDING FIELDS OF TABLE <fs_table>
*                FROM (iv_tabname)
*                WHERE (lv_where).
*              OPEN CURSOR WITH HOLD lv_cursor FOR SELECT (lv_fields)  FROM (iv_tabname) WHERE (lv_where).
*            ENDIF.

            IF sy-subrc NE 0.
              MESSAGE i000(fb) WITH 'No data found'.

              me->append_slg1_log(
                EXPORTING
                  iv_tabname    = space
                  iv_message_v1 = 'No data found'
                  iv_message_v2 = space
                  iv_message_v3 = space
                  iv_mestyp     = 'S' ).

              RETURN.
            ENDIF.

          CATCH cx_sy_dynamic_osql_semantics INTO lo_ref.
            lv_result = lo_ref->get_text( ).
            lv_error  = lv_result.

            sy-msgv1 = lv_error+0(50).
            sy-msgv2 = lv_error+50(50).
            sy-msgv3 = lv_error+100(50).
            sy-msgv4 = lv_error+150(50).

*            MESSAGE i000(fb) WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

            gs_elog-type       = 'SEND_JSON_ANY_TABLE'.
            gs_elog-severity   = gc_error.
            gs_elog-message    = lo_ref->get_longtext( ).
            CALL METHOD lo_ref->get_source_position
              IMPORTING
                program_name = gv_prog
                source_line  = gv_sline.
            gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
            gs_elog-details-db = 'ZONCL_OC_ANY_HANDLER-SEND_JSON_ANY_TABLE'.
            gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.


            gs_elog-metadata-error_code = gs_elog-details-error_code.
            interpret_message( EXPORTING iv_msgnr = '097' iv_msgv1 = iv_tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '098' iv_msgv1 = iv_tabname  IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '099' iv_msgv1 = iv_tabname  IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '100'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '101'  IMPORTING ev_message = gv_msg5 CHANGING ct_table = gt_causes ).
            CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 gv_msg5 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
            interpret_message( EXPORTING iv_msgnr = '076'  iv_msgv1 = iv_tabname IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '086'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '087'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_fixes ).
            CONCATENATE gv_msg1 gv_msg2 gv_msg3 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.
            print_error_otel( ).
            send_json_error( ).
            lv_error_stop = abap_true.
        ENDTRY.

        CHECK lv_error_stop = abap_false.

        "--------------------------------------------------------
        " Finalize logging and output
        "--------------------------------------------------------
        me->send_json_result( ).
        me->update_slg1_log( it_log_ext = gt_log_ext ).

      ENDIF.
    ELSE.
      CLEAR lv_message_v2.
      lv_message_v2 = gv_entity.

      me->append_slg1_log(
        iv_tabname    = space
        iv_message_v1 = 'No data found in table ZONTA_OBJ_OC for entity'
        iv_message_v2 = lv_message_v2
        iv_mestyp     = 'S' ).

      me->update_slg1_log( it_log_ext = gt_log_ext ).
    ENDIF.

  ENDMETHOD.

**  METHOD send_json_any_table_cds.
**
**    CONSTANTS: c_rawstring TYPE c VALUE 'y',
**               c_string    TYPE c VALUE 'X',
**               c_256       TYPE c LENGTH 6 VALUE '000256',
***BEGIN CECHAVARRIA 19/08/2025
**               c_type      TYPE zonta_oc_param-type VALUE 'P',
**               c_name      TYPE zonta_oc_param-name VALUE 'OPEN_MAX_RECORDS'.
***END CECHAVARRIA 19/08/2025
**
**    "------------------------------------------------------------
**    " Local Data Declarations
**    "------------------------------------------------------------
**    DATA: dref_table_root TYPE REF TO data,
**          dref_table      TYPE REF TO data,
**          lo_table        TYPE REF TO data,
**          lo_data         TYPE REF TO data,
**          lt_fcat         TYPE slis_t_fieldcat_alv,
**          e_size          TYPE zonde_oc_num30,
**          e_records       TYPE zonde_oc_num30,
**          lt_keys         TYPE tty_where,
**          lv_return       TYPE string,
**          lv_recordst     TYPE sy-tabix,
**          lv_response     TYPE string,
**          lv_key          TYPE string,
**          lv_keys_temp    TYPE string,
**          lv_max_records  TYPE zonde_registrosn,
**          lv_where        TYPE rsds_where_tab,
**          lv_alias        TYPE zonde_aliastab,
**          lv_fields       TYPE string,
**          lv_message_v2   TYPE string,
**          lv_exit         TYPE abap_bool,
**          lv_result       TYPE string,
**          lv_error(200)   TYPE c,
**          lo_ref          TYPE REF TO cx_sy_dynamic_osql_semantics,
**          lt_fields       TYPE TABLE OF line,
**          lv_tab          TYPE tabname,
**          lv_error_stop   TYPE boolean,
**          lv_send         TYPE boolean,
**          ls_dfies        LIKE LINE OF gt_dfies_tab,
***BEGIN CECHAVARRIA 19/08/2025,
**          lv_msg          TYPE char40,
**          lv_cursor       TYPE cursor,
**          lv_pakage       TYPE i,
**          lv_low          TYPE zonta_oc_param-low.
***END CECHAVARRIA 19/08/2025
**
**    "------------------------------------------------------------
**    " Field-Symbols
**    "------------------------------------------------------------
**    FIELD-SYMBOLS: <fs_root>            TYPE any,
**                   <fs_oneconnect>      TYPE any,
**                   <fs_properties>      TYPE any,
**                   <fs_metadata>        TYPE any,
**                   <fs_body_root>       TYPE any,
**                   <fs_json>            LIKE LINE OF gt_json, "TYPE any,
**                   <fs_field_metadata>  TYPE any,
**                   <fs_metadata_line>   TYPE any,
**                   <fs_field>           TYPE any,
**                   <fs_line>            TYPE any,
**                   <fs_table_body_line> TYPE any,
**                   <fs_body>            TYPE STANDARD TABLE,
**                   <fs_metadata_root>   TYPE STANDARD TABLE,
**                   <fs_table>           TYPE STANDARD TABLE,
**                   <fs_table2>          TYPE ANY TABLE,
**                   <fs_data>            TYPE any,
**                   <fs_table_line>      TYPE any,
**                   <fs_key>             TYPE any,
**                   <fs_key_main>        TYPE any,
**                   <fs_keys_event>      TYPE LINE OF tty_where,
**                   <fs_fcat>            LIKE LINE OF lt_fcat.
**
**
**    "------------------------------------------------------------
**    " Initialization and Global Variable Assignment
**    "------------------------------------------------------------
**    me->debug_procedure( ).
**
**    lv_error_stop  = abap_false.
**    gv_update    = iv_update.
**    gv_delete    = iv_delete.
**    gv_anytable  = iv_tabname.
**    gv_aliastab  = iv_aliastab.
**    gv_alias     = iv_alias."CECHAVARRIA 19/08/2025
**    gt_where     = it_where.
**    gv_entity    = 'ANY'.
**    gv_domainv   = 'ANY'.
**    gv_dest      = iv_dest.
**    gv_fieldname = iv_fieldname.
**    gv_bothnames = iv_bothnames.
**
**    " Log start of processing
**    me->append_slg1_log(
**      EXPORTING
**        iv_tabname    = space
**        iv_message_v1 = '*** Any Table Process TABLE***'
**        iv_message_v2 = space
**        iv_message_v3 = space
**        iv_mestyp     = 'S' ).
**
***BEGIN CECHAVARRIA 19/08/2025
***    IF sy-batch = abap_true.
***      CLEAR: gv_alias.
***      gv_fieldname = abap_true.
***    ENDIF.
***Get parameter for open cursor
****    SELECT SINGLE low
****       INTO lv_low
****       FROM zonta_oc_param
****       WHERE name =  c_name
****          AND type = c_type.
****    IF  sy-subrc EQ 0.
****      lv_pakage = lv_low.
****      IF lv_pakage <= 0.
****        lv_pakage = 1000.
****      ENDIF.
****    ELSE.
****      lv_pakage = 1000.
****    ENDIF.
*****END CECHAVARRIA 19/08/2025
**
**    "------------------------------------------------------------
**    " Retrieve metadata: columns, ALV field catalog, and DFIES
**    "------------------------------------------------------------
**    SELECT * INTO TABLE gt_columns_all
**      FROM zonta_oc_col_all
**      WHERE tabname      = iv_tabname
**        AND alias_tabname = iv_aliastab.
**
**    IF sy-subrc NE 0.
**      CLEAR lv_message_v2.
**      lv_message_v2 = gv_entity.
**
**      me->append_slg1_log(
**        iv_tabname    = space
**        iv_message_v1 = 'No data found in table ZONTA_OC_COL_ALL for entity'
**        iv_message_v2 = lv_message_v2
**        iv_mestyp     = 'S' ).
**
**      me->update_slg1_log( it_log_ext = gt_log_ext ).
**      RETURN.
**    ENDIF.
**
**    CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
**      EXPORTING
**        i_structure_name = iv_tabname
**      CHANGING
**        ct_fieldcat      = lt_fcat
**      EXCEPTIONS
**        OTHERS           = 3.
**
**    CALL FUNCTION 'DDIF_FIELDINFO_GET'
**      EXPORTING
**        tabname   = iv_tabname
**      TABLES
**        dfies_tab = gt_dfies_tab
**      EXCEPTIONS
**        OTHERS    = 3.
**
**    IF sy-subrc <> 0.
**      " Handle DFIES error if needed
**    ENDIF.
**
**
**    SORT gt_dfies_tab BY position fieldname.
**    SORT lt_fcat BY fieldname.
**    LOOP AT gt_dfies_tab INTO ls_dfies.
**      READ TABLE lt_fcat ASSIGNING <fs_fcat> WITH KEY fieldname = ls_dfies-fieldname BINARY SEARCH.
**      IF sy-subrc NE 0.
**        APPEND INITIAL LINE TO lt_fcat ASSIGNING <fs_fcat>.
**        MOVE-CORRESPONDING ls_dfies TO <fs_fcat>.
**      ENDIF.
**
**      <fs_fcat>-ddic_outputlen = ls_dfies-offset.
**      <fs_fcat>-inttype        = ls_dfies-inttype.
**      <fs_fcat>-decimals_out   = ls_dfies-decimals.
**      <fs_fcat>-col_pos        = ls_dfies-position.
**      <fs_fcat>-offset         = ls_dfies-offset.
**      <fs_fcat>-outputlen      = ls_dfies-outputlen.
**
**      IF <fs_fcat>-inttype = c_rawstring.
**        <fs_fcat>-inttype = c_string.
**        <fs_fcat>-ddic_outputlen = c_256.
**      ENDIF.
**
**      IF <fs_fcat>-seltext_l IS INITIAL.
**        <fs_fcat>-seltext_l = ls_dfies-scrtext_l.
**        <fs_fcat>-seltext_m = ls_dfies-scrtext_m.
**        <fs_fcat>-seltext_s = ls_dfies-scrtext_s.
**      ENDIF.
**    ENDLOOP.
**
**    SORT lt_fcat BY row_pos fieldname.
**
**    "------------------------------------------------------------
**    " Load base configuration object and destination if missing
**    "------------------------------------------------------------
**    SELECT SINGLE * INTO gs_oc_obj
**      FROM zonta_obj_oc
**      WHERE domainv       = 'ANY'
**        AND business_proc = 'ANY'.
**
**    IF sy-subrc EQ 0.
****Get parameter for open cursor
*** Begin of change Dic2025
**      lv_pakage = gs_oc_obj-no_registros.
*** End of change Dic2025
**
**      DATA lv_ali TYPE  rvari_val_255.
**      SELECT SINGLE low FROM zonta_oc_param INTO lv_ali WHERE name = 'USE_ALIAS'.
**      IF sy-subrc = 0.
**        IF lv_ali IS NOT INITIAL.
**          SELECT SINGLE alias_tabname INTO lv_alias
**            FROM zonta_oc_anyalia
**            WHERE tabname = iv_tabname.
**        ENDIF.
**      ENDIF.
**      IF gv_dest IS INITIAL.
**        SELECT SINGLE low INTO gv_dest
**          FROM zonta_oc_param
**          WHERE name = 'RFC_DESTINATION'
**            AND type = 'P'
**            AND numb = 1.
**      ENDIF.
**
**      IF sy-subrc EQ 0.
**
**        "--------------------------------------------------------
**        " Create root structure for ONECONNECT export
**        "--------------------------------------------------------
**        IF gs_oc_obj-data EQ abap_true.
**          CREATE DATA dref_table_root TYPE ty_oneconnect_meta.
**        ELSE.
**          CREATE DATA dref_table_root TYPE ty_oneconnect.
**        ENDIF.
**
**        ASSIGN dref_table_root->* TO <fs_root>.
**        ASSIGN COMPONENT 'ONECONNECT' OF STRUCTURE <fs_root> TO <fs_oneconnect>.
**        ASSIGN COMPONENT 'PROPERTIES' OF STRUCTURE <fs_oneconnect> TO <fs_properties>.
**
**        " Fill PROPERTIES node
**        me->get_data_properties_any( CHANGING cs_properties = <fs_properties> ).
**
**        ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_oneconnect> TO <fs_metadata_root>.
**        APPEND INITIAL LINE TO <fs_metadata_root> ASSIGNING <fs_metadata>.
**        ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_metadata> TO <fs_field_metadata>.
**
**        " Set metadata field label (alias or table name)
***        IF iv_fieldname IS INITIAL.
**        IF gv_fieldname IS INITIAL.
**          IF NOT iv_bothnames IS INITIAL.
**            <fs_field_metadata> = iv_tabname && '_' && lv_alias.
**          ELSEIF NOT lv_alias IS INITIAL.
**            <fs_field_metadata> = lv_alias.
**          ELSE.
**            <fs_field_metadata> = iv_tabname.
**          ENDIF.
**        ELSE.
**          <fs_field_metadata> = iv_tabname.
**        ENDIF.
**
**        ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_metadata> TO <fs_metadata_line>.
**        ASSIGN COMPONENT 'BODY' OF STRUCTURE <fs_oneconnect> TO <fs_body_root>.
**        ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_body_root> TO <fs_field>.
**
**        " Set field name for BODY node
***        IF iv_fieldname IS INITIAL.
**        IF gv_fieldname IS INITIAL.
**          IF NOT iv_bothnames IS INITIAL.
**            <fs_field> = iv_tabname && '_' && lv_alias.
**          ELSEIF NOT lv_alias IS INITIAL.
**            <fs_field> = lv_alias.
**          ELSE.
**            <fs_field> = iv_tabname.
**          ENDIF.
**        ELSE.
**          <fs_field> = iv_tabname.
**        ENDIF.
**
**        ASSIGN COMPONENT 'DATA' OF STRUCTURE <fs_body_root> TO <fs_table_body_line>.
**
**        "--------------------------------------------------------
**        " Create dynamic tables for BODY and result data
**        "--------------------------------------------------------
**        CALL METHOD me->set_table_any
**          EXPORTING
***           iv_alias = iv_alias
**            iv_alias = gv_alias
**            it_fcat  = lt_fcat
**          RECEIVING
**            rt_table = <fs_table_body_line>.
**
**        ASSIGN <fs_table_body_line>->* TO <fs_body>.
**
**        CALL METHOD me->set_table_any
**          EXPORTING
***           iv_alias = iv_alias "iv_fieldname CHECK
**            iv_alias = gv_alias "iv_fieldname CHECK
**            it_fcat  = lt_fcat
**          RECEIVING
**            rt_table = lo_data.
**
**        ASSIGN lo_data->* TO <fs_table>.
**
**        "--------------------------------------------------------
**        " Compose WHERE and SELECT fields
**        "--------------------------------------------------------
***      lv_fields = me->set_fields( iv_alias = iv_alias ).
**
**
**        IF gt_where IS INITIAL.
**          lv_where = me->set_where_any( iv_any = abap_true ).
**          me->set_process( IMPORTING ev_closed = lv_exit ).
**          IF lv_exit EQ abap_true.
**            RETURN.
**          ENDIF.
**          gt_where = lv_where.
**        ELSE.
**          lv_where = gt_where.
**        ENDIF.
**
**        IF lv_where IS INITIAL.
**          MESSAGE i000(fb) WITH 'No filter selected'.
**          RETURN.
**        ENDIF.
**
**        "--------------------------------------------------------
**        " Run as Background Batch if Configured
**        "--------------------------------------------------------
***BEGIN CECHAVARRIA 19/08/2025
**        IF NOT gv_batch IS INITIAL.
**          me->execute_batch(
**            EXPORTING
**              iv_anytab  = abap_true
**              iv_tabname = iv_tabname ).
**          RETURN.
**        ENDIF.
***END CECHAVARRIA 19/08/2025
**        "--------------------------------------------------------
**        " Fill METADATA node
**        "--------------------------------------------------------
**        me->set_metadata_node_any(
**          EXPORTING
**            iv_alias    = gv_fieldname
**            it_fcat     = lt_fcat
**          CHANGING
**            ct_metadata = <fs_metadata_line> ).
**
**        "--------------------------------------------------------
**        " Fetch Data Dynamically (CDS or Transparent Table)
**        "--------------------------------------------------------
**        TRY.
***            IF is_cds_entity( iv_tabname ) = abap_true.
**            me->set_fields_in_table(
**              EXPORTING
**                iv_tabname = iv_tabname
**                iv_alias   = gv_alias
**              IMPORTING
**                et_fields  = lt_fields ).
**
****BEGIN CECHAVARRIA 19/08/2025
***            SELECT (lt_fields) FROM (iv_tabname)
***              WHERE (lv_where)
***              INTO CORRESPONDING FIELDS OF TABLE @<fs_table>
***              PACKAGE SIZE @lv_pakage.
**
**            SELECT (lt_fields)
**              INTO CORRESPONDING FIELDS OF TABLE <fs_table>
**              PACKAGE SIZE lv_pakage
**            FROM (iv_tabname)
**              WHERE (lv_where).
**
**              gv_recordst = gv_recordst + lv_recordst.
**
**              CLEAR lt_keys.
**
**              lv_send = abap_false.
**              LOOP AT <fs_table> ASSIGNING <fs_data>.
**                CLEAR lt_keys.
**
**                " Generate key from line content
**                CALL METHOD me->set_key_any
**                  EXPORTING
**                    iv_alias = gv_alias
**                    it_fcat  = lt_fcat
**                    is_line  = <fs_data>
**                  RECEIVING
**                    rv_key   = lv_key.
**
**                ASSIGN lv_key TO <fs_key>.
**
**                " Track new keys to count records
**                IF lv_keys_temp NE lv_key.
**                  lv_keys_temp   = lv_key.
**                  lv_max_records = lv_max_records + 1.
**                  gv_recordst_obj = gv_recordst_obj + 1.
**                ENDIF.
**
**                " Log key to application log
**                me->append_slg1_log(
**                  iv_tabname = iv_tabname
**                  iv_mestyp  = 'S'
**                  iv_key     = lv_key ).
**
**                " Add line to body node
**                APPEND INITIAL LINE TO <fs_body> ASSIGNING <fs_line>.
**                MOVE-CORRESPONDING <fs_data> TO <fs_line>.
**
**                " Apply conversion exit for display format
**                me->conversion_exit(
**                  EXPORTING
**                    iv_tabname = iv_tabname
**                  CHANGING
**                    cs_string  = <fs_line> ).
**
**                " Add event ID if configured
**                IF gs_oc_obj-eventid  = abap_true OR
**                   gs_oc_obj-metadata = abap_true.
**
**                  IF <fs_key> IS ASSIGNED.
**                    APPEND INITIAL LINE TO lt_keys ASSIGNING <fs_keys_event>.
**                    <fs_keys_event>-line = <fs_key>.
**                  ENDIF.
**
**                  me->get_eventid(
**                    EXPORTING
**                      it_keys      = lt_keys
**                    CHANGING
**                      cs_line_json = <fs_line> ).
**                ENDIF.
**
**                " Serialize and send when reaching max records per message
**                IF lv_max_records EQ gs_oc_obj-no_registros.
**                  APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
**                  <fs_json>-json_id = gv_jsonid.
**                  <fs_json>-json = zoncl_ui2_cl_json=>serialize(
**                            data             = <fs_root>
**                            compress         = abap_false
**                            assoc_arrays     = abap_true
**                            assoc_arrays_opt = abap_true
**                            pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).
**
**                  " Replace technical strings for compatibility
**                  REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
**                  REPLACE 'TABL'        WITH 'TABLE'        INTO <fs_json>-json.
**                  gv_jsonid = gv_jsonid + 1.
**                  CLEAR: lv_max_records, <fs_body>.
**                  lv_send = abap_true.
**                ENDIF.
**              ENDLOOP.
**
**              "--------------------------------------------------------
**              " Serialize remaining records if limit not reached
**              "--------------------------------------------------------
**              IF lv_max_records LT gs_oc_obj-no_registros AND lv_send = abap_false.
**                IF lv_max_records = 0000.
**                  APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
**                  DELETE gt_json WHERE json IS INITIAL. "table_line = space.
**                  IF sy-subrc NE 0.
**                    <fs_json>-json_id = gv_jsonid.
**                    <fs_json>-json = zoncl_ui2_cl_json=>serialize(
**                                data             = <fs_root>
**                                compress         = abap_false
**                                assoc_arrays     = abap_true
**                                assoc_arrays_opt = abap_true
**                                pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).
**
**                    REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
**                    REPLACE 'TABL'        WITH 'TABLE'        INTO <fs_json>-json.
**                  ENDIF.
**                ELSE.
**                  APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
**                  <fs_json>-json_id = gv_jsonid.
**                  <fs_json>-json =  zoncl_ui2_cl_json=>serialize(
**                            data             = <fs_root>
**                            compress         = abap_false
**                            assoc_arrays     = abap_true
**                            assoc_arrays_opt = abap_true
**                            pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).
**
**                  REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
**                  REPLACE 'TABL'        WITH 'TABLE'        INTO <fs_json>-json.
**                ENDIF.
**              ENDIF.
**
**              "--------------------------------------------------------
**              " Send each JSON payload and track result
**              "--------------------------------------------------------
**              LOOP AT gt_json INTO gs_json.
**
**                gv_json = gs_json-json.
**                gv_jsonid = gs_json-json_id.
**
**                IF gv_recordst_obj IS INITIAL.
**                  gv_recordst_obj = 1.
**                ENDIF.
**
**                me->pretty_json_any(
**                  EXPORTING
**                    iv_mode = c_table
**                  CHANGING
**                    cv_json = gv_json ).
**
**                CALL FUNCTION 'ZONFM_ONE_CONNECT_CURSOR_UPDAT' IN UPDATE TASK
**                  EXPORTING
**                    iv_dest               = gv_dest
**                    iv_json               = gv_json
**                  IMPORTING
**                    ev_return             = lv_return
**                    ev_size               = e_size
**                    ev_records            = e_records
**                    ev_response           = lv_response
**                  EXCEPTIONS
**                    communication_failure = 1
**                    system_failure        = 2
**                    resource_failure      = 3.
**
***                CALL FUNCTION 'ZONFM_ONE_CONNECT_OPENCURSOR' STARTING NEW TASK 'OPEN_CUR'
***                  DESTINATION 'NONE'
***                  CALLING respon_fm_parallel ON END OF TASK
***                  EXPORTING
***                    iv_dest               = gv_dest
***                    iv_json               = gv_json
***                  EXCEPTIONS
***                    communication_failure = 1 MESSAGE lv_msg
***                    system_failure        = 2 MESSAGE lv_msg
***                    resource_failure      = 3.
**
**                CASE sy-subrc.
**                  WHEN 0.
**                  WHEN 1.
**                    MESSAGE lv_msg TYPE 'I'.
**                  WHEN 2.
**                    MESSAGE lv_msg TYPE 'I'.
**                  WHEN 3.
**                    WAIT UNTIL me->gv_size IS NOT INITIAL UP TO 5 SECONDS.
**                    IF sy-subrc NE 0.
**                      MESSAGE 'Resource Failure' TYPE 'I'.
**                    ENDIF.
**                  WHEN OTHERS.
**                    MESSAGE 'Other error' TYPE 'I'.
**                ENDCASE.
**
**                WAIT UNTIL me->gv_size IS NOT INITIAL UP TO 5 SECONDS.
**
***                lv_return = me->gv_return.
***                e_size = me->gv_size.
***                e_records = me->gv_size.
***                lv_response = me->gv_response_fm.
**
**                gv_sizet    = gv_sizet + e_size.
**                gv_recordst = gv_recordst + 1.
**
***                CALL FUNCTION 'RFC_CONNECTION_CLOSE'
***                  EXPORTING
***                    destination          = 'NONE'
***                    taskname             = 'OPEN_CUR'
***                  EXCEPTIONS
***                    destination_not_open = 1
***                    OTHERS               = 2.
***                IF sy-subrc <> 0.
**** Implement suitable error handling here
***                ENDIF.
**              ENDLOOP.
**              gv_jsonid = gv_jsonid + 1.
**              CLEAR: gt_json[], lv_max_records, <fs_body>.
***                     <fs_table>.
**
**            ENDSELECT.
**
**            COMMIT WORK.
**
**
***              RETURN.
***END CECHAVARRIA 19/08/2025
***            ELSE.
***              lv_fields = me->set_fields( iv_alias = iv_alias ).
***            lv_fields = me->set_fields( iv_alias = gv_alias ).
***              SELECT (lv_fields)
***                INTO CORRESPONDING FIELDS OF TABLE <fs_table>
***                FROM (iv_tabname)
***                WHERE (lv_where).
***              OPEN CURSOR WITH HOLD lv_cursor FOR SELECT (lv_fields)  FROM (iv_tabname) WHERE (lv_where).
***            ENDIF.
**
**            IF sy-subrc NE 0.
**              MESSAGE i000(fb) WITH 'No data found'.
**
**              me->append_slg1_log(
**                EXPORTING
**                  iv_tabname    = space
**                  iv_message_v1 = 'No data found'
**                  iv_message_v2 = space
**                  iv_message_v3 = space
**                  iv_mestyp     = 'S' ).
**
**              RETURN.
**            ENDIF.
**
**          CATCH cx_sy_dynamic_osql_semantics INTO lo_ref.
**            lv_result = lo_ref->get_text( ).
**            lv_error  = lv_result.
**
**            sy-msgv1 = lv_error+0(50).
**            sy-msgv2 = lv_error+50(50).
**            sy-msgv3 = lv_error+100(50).
**            sy-msgv4 = lv_error+150(50).
**
***            MESSAGE i000(fb) WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
**
**            gs_elog-type       = 'SEND_JSON_ANY_TABLE'.
**            gs_elog-severity   = gc_error.
**            gs_elog-message    = lo_ref->get_longtext( ).
**            CALL METHOD lo_ref->get_source_position
**              IMPORTING
**                program_name = gv_prog
**                source_line  = gv_sline.
**            gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
**            gs_elog-details-db = 'ZONCL_OC_ANY_HANDLER-SEND_JSON_ANY_TABLE'.
**            gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.
**
**
**            gs_elog-metadata-error_code = gs_elog-details-error_code.
**            interpret_message( EXPORTING iv_msgnr = '097' iv_msgv1 = iv_tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
**            interpret_message( EXPORTING iv_msgnr = '098' iv_msgv1 = iv_tabname  IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
**            interpret_message( EXPORTING iv_msgnr = '099' iv_msgv1 = iv_tabname  IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
**            interpret_message( EXPORTING iv_msgnr = '100'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
**            interpret_message( EXPORTING iv_msgnr = '101'  IMPORTING ev_message = gv_msg5 CHANGING ct_table = gt_causes ).
**            CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 gv_msg5 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
**            interpret_message( EXPORTING iv_msgnr = '076'  iv_msgv1 = iv_tabname IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_fixes ).
**            interpret_message( EXPORTING iv_msgnr = '086'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_fixes ).
**            interpret_message( EXPORTING iv_msgnr = '087'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_fixes ).
**            CONCATENATE gv_msg1 gv_msg2 gv_msg3 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.
**            print_error_otel( ).
**            send_json_error( ).
**            lv_error_stop = abap_true.
**        ENDTRY.
**
**        CHECK lv_error_stop = abap_false.
**
**        "--------------------------------------------------------
**        " Finalize logging and output
**        "--------------------------------------------------------
**        me->send_json_result( ).
**        me->update_slg1_log( it_log_ext = gt_log_ext ).
**
**      ENDIF.
**    ELSE.
**      CLEAR lv_message_v2.
**      lv_message_v2 = gv_entity.
**
**      me->append_slg1_log(
**        iv_tabname    = space
**        iv_message_v1 = 'No data found in table ZONTA_OBJ_OC for entity'
**        iv_message_v2 = lv_message_v2
**        iv_mestyp     = 'S' ).
**
**      me->update_slg1_log( it_log_ext = gt_log_ext ).
**    ENDIF.
**
**  ENDMETHOD.


  METHOD send_json_any_table_cond.

    DATA: dref_table_root   TYPE REF TO data,
          lo_data           TYPE REF TO data,
          lt_fcat           TYPE slis_t_fieldcat_alv,
          e_size            TYPE zonde_oc_num30,
          e_records         TYPE zonde_oc_num30,
          lt_keys           TYPE tty_where,
          lv_return         TYPE string,
          lv_recordst       TYPE sy-tabix,
          lv_response       TYPE string,
          lv_message_v2     TYPE string,
          lv_key            TYPE string,
          lv_keys_temp      TYPE string,
          lv_max_records    TYPE zonde_registrosn,
          lv_where          TYPE zonttrsdswhere,
          lv_alias          TYPE zonde_aliastab,
          lv_fields         TYPE string,
          lv_message_v1     TYPE string,
          lv_exit           TYPE abap_bool,
          lv_exit_set_where TYPE abap_bool,
          lv_send           TYPE boolean.

    FIELD-SYMBOLS: <fs_root>            TYPE any,
                   <fs_oneconnect>      TYPE any,
                   <fs_properties>      TYPE any,
                   <fs_metadata>        TYPE any,
                   <fs_body_root>       TYPE any,
                   <fs_json>            LIKE LINE OF gt_json, "TYPE any,
                   <fs_field_metadata>  TYPE any,
                   <fs_metadata_line>   TYPE any,
                   <fs_field>           TYPE any,
                   <fs_line>            TYPE any,
                   <fs_table_body_line> TYPE any,
                   <fs_body>            TYPE STANDARD TABLE,
                   <fs_metadata_root>   TYPE STANDARD TABLE,
                   <fs_table>           TYPE STANDARD TABLE,
                   <fs_data>            TYPE any,
                   <fs_key>             TYPE any,
                   <fs_keys_event>      TYPE LINE OF tty_where.

    "Validate if debug is active
     me->debug_procedure( ).

    gv_update   = iv_update.
    gv_delete   = iv_delete.
    gv_anytable = iv_tabname.
    gt_where    = it_where.
    gv_entity   = 'ANY'.
    gv_domainv  = 'ANY'.

    IF iv_alias IS INITIAL.
      gv_fieldname = abap_true.
    ENDIF.

    CONCATENATE '*** Price Condition Table' iv_tabname 'Process TABLE***'
                INTO lv_message_v1 SEPARATED BY space.

    me->append_slg1_log(
      EXPORTING
        iv_tabname    = space
        iv_message_v1 = lv_message_v1
        iv_message_v2 = space
        iv_message_v3 = space
        iv_mestyp     = 'S' ).

    SELECT * INTO TABLE gt_columns_all
           FROM zonta_oc_col_all
           WHERE tabname = iv_tabname.

    IF sy-subrc NE 0.
      CLEAR lv_message_v2.
      lv_message_v2 = gv_entity.

      me->append_slg1_log(
        iv_tabname    = space
        iv_message_v1 = 'No data found in table ZONTA_OC_COL_ALL for entity'
        iv_message_v2 = lv_message_v2
        iv_mestyp     = 'S' ).

      me->update_slg1_log( it_log_ext = gt_log_ext ).
      RETURN.
    ENDIF.

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

    SELECT SINGLE * INTO gs_oc_obj
           FROM zonta_obj_oc
           WHERE domainv = 'ANY' AND business_proc = 'ANY'.

    IF sy-subrc = 0.

      SELECT SINGLE alias_tabname INTO lv_alias
             FROM zonta_oc_anyalia
             WHERE tabname = iv_tabname.

      SELECT SINGLE low INTO gv_dest
             FROM zonta_oc_param
             WHERE name = 'RFC_DESTINATION' AND type = 'P' AND numb = 1.

      IF sy-subrc = 0.

        IF gs_oc_obj-data = abap_true.
          CREATE DATA dref_table_root TYPE ty_oneconnect_meta.
        ELSE.
          CREATE DATA dref_table_root TYPE ty_oneconnect.
        ENDIF.

        ASSIGN dref_table_root->* TO <fs_root>.
        ASSIGN COMPONENT 'ONECONNECT' OF STRUCTURE <fs_root> TO <fs_oneconnect>.
        ASSIGN COMPONENT 'PROPERTIES' OF STRUCTURE <fs_oneconnect> TO <fs_properties>.
        me->get_data_properties_any( CHANGING cs_properties = <fs_properties> ).

        ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_oneconnect> TO <fs_metadata_root>.
        APPEND INITIAL LINE TO <fs_metadata_root> ASSIGNING <fs_metadata>.
        ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_metadata> TO <fs_field_metadata>.

        IF NOT iv_alias IS INITIAL AND lv_alias IS NOT INITIAL.
          <fs_field_metadata> = lv_alias.
        ELSE.
          <fs_field_metadata> = iv_tabname.
        ENDIF.

        ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_metadata> TO <fs_metadata_line>.
        ASSIGN COMPONENT 'BODY' OF STRUCTURE <fs_oneconnect> TO <fs_body_root>.
        ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_body_root> TO <fs_field>.

        IF NOT iv_alias IS INITIAL AND lv_alias IS NOT INITIAL.
          <fs_field> = lv_alias.
        ELSE.
          <fs_field> = iv_tabname.
        ENDIF.

        ASSIGN COMPONENT 'DATA' OF STRUCTURE <fs_body_root> TO <fs_table_body_line>.

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

        lv_fields = me->set_fields( iv_alias = iv_alias ).

        IF gt_where IS INITIAL.
*          lv_where = me->set_where( iv_any = abap_true ).
          me->set_where( EXPORTING iv_any = abap_true
                         IMPORTING ev_closed = lv_exit_set_where
                                   r_where = lv_where ).
          IF lv_exit_set_where EQ abap_true.
            RETURN.
          ENDIF.
          me->set_process( IMPORTING ev_closed = lv_exit ).
          IF lv_exit EQ abap_true.
            RETURN.
          ENDIF.
          gt_where = lv_where.
        ELSE.
          lv_where = gt_where.
        ENDIF.

        IF lv_where IS INITIAL.
          RETURN.
        ENDIF.

        SELECT (lv_fields) INTO CORRESPONDING FIELDS OF TABLE <fs_table>
               FROM (iv_tabname) WHERE (lv_where).

        IF sy-subrc NE 0.
          me->append_slg1_log(
            EXPORTING
              iv_tabname    = space
              iv_message_v1 = 'No data found'
              iv_message_v2 = space
              iv_message_v3 = space
              iv_mestyp     = 'S' ).
          RETURN.
        ENDIF.

        IF NOT gv_batch IS INITIAL.
          me->execute_batch( EXPORTING iv_anytab = abap_true iv_tabname = iv_tabname ).
          RETURN.
        ENDIF.

        me->set_metadata_node_any(
          EXPORTING
            iv_alias    = iv_alias
            it_fcat     = lt_fcat
          CHANGING
            ct_metadata = <fs_metadata_line> ).

*        gv_recordst = gv_recordst + lv_recordst.
        gs_log_json_result-recordst   = gs_log_json_result-recordst + lv_recordst.
        CLEAR lt_keys.

        lv_send = abap_false.
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
*            gv_recordst_obj = gv_recordst_obj + 1.
            gs_log_json_result-recordst_obj = gs_log_json_result-recordst_obj + 1.
          ENDIF.

          me->append_slg1_log( iv_tabname = iv_tabname iv_mestyp = 'S' iv_key = lv_key ).

          APPEND INITIAL LINE TO <fs_body> ASSIGNING <fs_line>.
          MOVE-CORRESPONDING <fs_data> TO <fs_line>.

          me->conversion_exit( EXPORTING iv_tabname = iv_tabname CHANGING cs_string = <fs_line> ).

          IF gs_oc_obj-eventid = abap_true OR gs_oc_obj-metadata = abap_true.
            IF <fs_key> IS ASSIGNED.
              APPEND INITIAL LINE TO lt_keys ASSIGNING <fs_keys_event>.
              <fs_keys_event>-line = <fs_key>.
            ENDIF.

            me->get_eventid( EXPORTING it_keys = lt_keys CHANGING cs_line_json = <fs_line> ).
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

            REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
            REPLACE 'TABL' WITH 'TABLE' INTO <fs_json>-json.
            gv_jsonid = gv_jsonid + 1.
            CLEAR: lv_max_records, <fs_body>.
            lv_send = abap_true.
          ENDIF.
        ENDLOOP.

        IF lv_max_records LT gs_oc_obj-no_registros AND lv_send = abap_false.
          APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
          <fs_json>-json_id = gv_jsonid.
          <fs_json>-json =  zoncl_ui2_cl_json=>serialize(
            data             = <fs_root>
            compress         = abap_false
            assoc_arrays     = abap_true
            assoc_arrays_opt = abap_true
            pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).

          REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
          REPLACE 'TABL' WITH 'TABLE' INTO <fs_json>-json.
        ENDIF.

        LOOP AT gt_json INTO gs_json.
          gv_json = gs_json-json.
          gv_jsonid = gs_json-json_id.

          me->send_json_http_con(
            EXPORTING
              i_dest     = gv_dest
            IMPORTING
              e_return   = lv_return
              e_size     = e_size
              e_records  = e_records
              e_response = lv_response ).

*          gv_sizet    = gv_sizet + e_size.
*          gv_recordst = gv_recordst + 1.

          gs_log_json_result-sizet = gs_log_json_result-sizet + e_size.
          gs_log_json_result-recordst   = gs_log_json_result-recordst + 1.

        ENDLOOP.

        me->update_slg1_log( it_log_ext = gt_log_ext ).
      ENDIF.
    ELSE.
      CLEAR lv_message_v2.
      lv_message_v2 = gv_entity.

      me->append_slg1_log(
        iv_tabname    = space
        iv_message_v1 = 'No data found in table ZONTA_OBJ_OC for entity'
        iv_message_v2 = lv_message_v2
        iv_mestyp     = 'S' ).

      me->update_slg1_log( it_log_ext = gt_log_ext ).
    ENDIF.


  ENDMETHOD.

**  METHOD send_json_any_table_cond.
**
**    DATA: dref_table_root   TYPE REF TO data,
**          lo_data           TYPE REF TO data,
**          lt_fcat           TYPE slis_t_fieldcat_alv,
**          e_size            TYPE zonde_oc_num30,
**          e_records         TYPE zonde_oc_num30,
**          lt_keys           TYPE tty_where,
**          lv_return         TYPE string,
**          lv_recordst       TYPE sy-tabix,
**          lv_response       TYPE string,
**          lv_message_v2     TYPE string,
**          lv_key            TYPE string,
**          lv_keys_temp      TYPE string,
**          lv_max_records    TYPE zonde_registrosn,
***          lv_where          TYPE rsds_where_tab,
**          lv_where TYPE zonttrsdswhere,
**          lv_alias          TYPE zonde_aliastab,
**          lv_fields         TYPE string,
**          lv_message_v1     TYPE string,
**          lv_exit           TYPE abap_bool,
**          lv_exit_set_where TYPE abap_bool,
**          lv_send           TYPE boolean.
**
**    FIELD-SYMBOLS: <fs_root>            TYPE any,
**                   <fs_oneconnect>      TYPE any,
**                   <fs_properties>      TYPE any,
**                   <fs_metadata>        TYPE any,
**                   <fs_body_root>       TYPE any,
**                   <fs_json>            LIKE LINE OF gt_json, "TYPE any,
**                   <fs_field_metadata>  TYPE any,
**                   <fs_metadata_line>   TYPE any,
**                   <fs_field>           TYPE any,
**                   <fs_line>            TYPE any,
**                   <fs_table_body_line> TYPE any,
**                   <fs_body>            TYPE STANDARD TABLE,
**                   <fs_metadata_root>   TYPE STANDARD TABLE,
**                   <fs_table>           TYPE STANDARD TABLE,
**                   <fs_data>            TYPE any,
**                   <fs_key>             TYPE any,
**                   <fs_keys_event>      TYPE LINE OF tty_where.
**
**    "Validate if debug is active
**    me->debug_procedure( ).
**
**    gv_update   = iv_update.
**    gv_delete   = iv_delete.
**    gv_anytable = iv_tabname.
**    gt_where    = it_where.
**    gv_entity   = 'ANY'.
**    gv_domainv  = 'ANY'.
**
**    IF iv_alias IS INITIAL.
**      gv_fieldname = abap_true.
**    ENDIF.
**
**    CONCATENATE '*** Price Condition Table' iv_tabname 'Process TABLE***'
**                INTO lv_message_v1 SEPARATED BY space.
**
**    me->append_slg1_log(
**      EXPORTING
**        iv_tabname    = space
**        iv_message_v1 = lv_message_v1
**        iv_message_v2 = space
**        iv_message_v3 = space
**        iv_mestyp     = 'S' ).
**
**    SELECT * INTO TABLE gt_columns_all
**           FROM zonta_oc_col_all
**           WHERE tabname = iv_tabname.
**
**    IF sy-subrc NE 0.
**      CLEAR lv_message_v2.
**      lv_message_v2 = gv_entity.
**
**      me->append_slg1_log(
**        iv_tabname    = space
**        iv_message_v1 = 'No data found in table ZONTA_OC_COL_ALL for entity'
**        iv_message_v2 = lv_message_v2
**        iv_mestyp     = 'S' ).
**
**      me->update_slg1_log( it_log_ext = gt_log_ext ).
**      RETURN.
**    ENDIF.
**
**    CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
**      EXPORTING
**        i_structure_name       = iv_tabname
**      CHANGING
**        ct_fieldcat            = lt_fcat
**      EXCEPTIONS
**        inconsistent_interface = 1
**        program_error          = 2
**        OTHERS                 = 3.
**
**    CALL FUNCTION 'DDIF_FIELDINFO_GET'
**      EXPORTING
**        tabname        = iv_tabname
**      TABLES
**        dfies_tab      = gt_dfies_tab
**      EXCEPTIONS
**        not_found      = 1
**        internal_error = 2
**        OTHERS         = 3.
**
**    SELECT SINGLE * INTO gs_oc_obj
**           FROM zonta_obj_oc
**           WHERE domainv = 'ANY' AND business_proc = 'ANY'.
**
**    IF sy-subrc = 0.
**
**      SELECT SINGLE alias_tabname INTO lv_alias
**             FROM zonta_oc_anyalia
**             WHERE tabname = iv_tabname.
**
**      SELECT SINGLE low INTO gv_dest
**             FROM zonta_oc_param
**             WHERE name = 'RFC_DESTINATION' AND type = 'P' AND numb = 1.
**
**      IF sy-subrc = 0.
**
**        IF gs_oc_obj-data = abap_true.
**          CREATE DATA dref_table_root TYPE ty_oneconnect_meta.
**        ELSE.
**          CREATE DATA dref_table_root TYPE ty_oneconnect.
**        ENDIF.
**
**        ASSIGN dref_table_root->* TO <fs_root>.
**        ASSIGN COMPONENT 'ONECONNECT' OF STRUCTURE <fs_root> TO <fs_oneconnect>.
**        ASSIGN COMPONENT 'PROPERTIES' OF STRUCTURE <fs_oneconnect> TO <fs_properties>.
**        me->get_data_properties_any( CHANGING cs_properties = <fs_properties> ).
**
**        ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_oneconnect> TO <fs_metadata_root>.
**        APPEND INITIAL LINE TO <fs_metadata_root> ASSIGNING <fs_metadata>.
**        ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_metadata> TO <fs_field_metadata>.
**
**        IF NOT iv_alias IS INITIAL AND lv_alias IS NOT INITIAL.
**          <fs_field_metadata> = lv_alias.
**        ELSE.
**          <fs_field_metadata> = iv_tabname.
**        ENDIF.
**
**        ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_metadata> TO <fs_metadata_line>.
**        ASSIGN COMPONENT 'BODY' OF STRUCTURE <fs_oneconnect> TO <fs_body_root>.
**        ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_body_root> TO <fs_field>.
**
**        IF NOT iv_alias IS INITIAL AND lv_alias IS NOT INITIAL.
**          <fs_field> = lv_alias.
**        ELSE.
**          <fs_field> = iv_tabname.
**        ENDIF.
**
**        ASSIGN COMPONENT 'DATA' OF STRUCTURE <fs_body_root> TO <fs_table_body_line>.
**
**        CALL METHOD me->set_table_any
**          EXPORTING
**            iv_alias = iv_alias
**            it_fcat  = lt_fcat
**          RECEIVING
**            rt_table = <fs_table_body_line>.
**
**        ASSIGN <fs_table_body_line>->* TO <fs_body>.
**
**        CALL METHOD me->set_table_any
**          EXPORTING
**            iv_alias = iv_alias
**            it_fcat  = lt_fcat
**          RECEIVING
**            rt_table = lo_data.
**
**        ASSIGN lo_data->* TO <fs_table>.
**
**        lv_fields = me->set_fields( iv_alias = iv_alias ).
**
**        IF gt_where IS INITIAL.
***          lv_where = me->set_where( iv_any = abap_true ).
**          me->set_where( EXPORTING iv_any = abap_true
**                         IMPORTING ev_closed = lv_exit_set_where
**                                   r_where = lv_where ).
**          IF lv_exit_set_where EQ abap_true.
**            RETURN.
**          ENDIF.
**          me->set_process( IMPORTING ev_closed = lv_exit ).
**          IF lv_exit EQ abap_true.
**            RETURN.
**          ENDIF.
**          gt_where = lv_where.
**        ELSE.
**          lv_where = gt_where.
**        ENDIF.
**
**        IF lv_where IS INITIAL.
**          RETURN.
**        ENDIF.
**
**        SELECT (lv_fields) INTO CORRESPONDING FIELDS OF TABLE <fs_table>
**               FROM (iv_tabname) WHERE (lv_where).
**
**        IF sy-subrc NE 0.
**          me->append_slg1_log(
**            EXPORTING
**              iv_tabname    = space
**              iv_message_v1 = 'No data found'
**              iv_message_v2 = space
**              iv_message_v3 = space
**              iv_mestyp     = 'S' ).
**          RETURN.
**        ENDIF.
**
**        IF NOT gv_batch IS INITIAL.
**          me->execute_batch( EXPORTING iv_anytab = abap_true iv_tabname = iv_tabname ).
**          RETURN.
**        ENDIF.
**
**        me->set_metadata_node_any(
**          EXPORTING
**            iv_alias    = iv_alias
**            it_fcat     = lt_fcat
**          CHANGING
**            ct_metadata = <fs_metadata_line> ).
**
**        gv_recordst = gv_recordst + lv_recordst.
**        CLEAR lt_keys.
**
**        lv_send = abap_false.
**        LOOP AT <fs_table> ASSIGNING <fs_data>.
**          CLEAR lt_keys.
**
**          CALL METHOD me->set_key_any
**            EXPORTING
**              iv_alias = iv_alias
**              it_fcat  = lt_fcat
**              is_line  = <fs_data>
**            RECEIVING
**              rv_key   = lv_key.
**
**          ASSIGN lv_key TO <fs_key>.
**
**          IF lv_keys_temp NE lv_key.
**            lv_keys_temp   = lv_key.
**            lv_max_records = lv_max_records + 1.
**            gv_recordst_obj = gv_recordst_obj + 1.
**          ENDIF.
**
**          me->append_slg1_log( iv_tabname = iv_tabname iv_mestyp = 'S' iv_key = lv_key ).
**
**          APPEND INITIAL LINE TO <fs_body> ASSIGNING <fs_line>.
**          MOVE-CORRESPONDING <fs_data> TO <fs_line>.
**
**          me->conversion_exit( EXPORTING iv_tabname = iv_tabname CHANGING cs_string = <fs_line> ).
**
**          IF gs_oc_obj-eventid = abap_true OR gs_oc_obj-metadata = abap_true.
**            IF <fs_key> IS ASSIGNED.
**              APPEND INITIAL LINE TO lt_keys ASSIGNING <fs_keys_event>.
**              <fs_keys_event>-line = <fs_key>.
**            ENDIF.
**
**            me->get_eventid( EXPORTING it_keys = lt_keys CHANGING cs_line_json = <fs_line> ).
**          ENDIF.
**
**          IF lv_max_records EQ gs_oc_obj-no_registros.
**            APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
**            <fs_json>-json_id = gv_jsonid.
**            <fs_json>-json = zoncl_ui2_cl_json=>serialize(
**                data             = <fs_root>
**                compress         = abap_false
**                assoc_arrays     = abap_true
**                assoc_arrays_opt = abap_true
**                pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).
**
**            REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
**            REPLACE 'TABL' WITH 'TABLE' INTO <fs_json>-json.
**            gv_jsonid = gv_jsonid + 1.
**            CLEAR: lv_max_records, <fs_body>.
**            lv_send = abap_true.
**          ENDIF.
**        ENDLOOP.
**
**        IF lv_max_records LT gs_oc_obj-no_registros AND lv_send = abap_false.
**          APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
**          <fs_json>-json_id = gv_jsonid.
**          <fs_json>-json =  zoncl_ui2_cl_json=>serialize(
**            data             = <fs_root>
**            compress         = abap_false
**            assoc_arrays     = abap_true
**            assoc_arrays_opt = abap_true
**            pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).
**
**          REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
**          REPLACE 'TABL' WITH 'TABLE' INTO <fs_json>-json.
**        ENDIF.
**
**        LOOP AT gt_json INTO gs_json.
**          gv_json = gs_json-json.
**          gv_jsonid = gs_json-json_id.
**
**          me->send_json_http_con(
**            EXPORTING
**              i_dest     = gv_dest
**            IMPORTING
**              e_return   = lv_return
**              e_size     = e_size
**              e_records  = e_records
**              e_response = lv_response ).
**
**          gv_sizet    = gv_sizet + e_size.
**          gv_recordst = gv_recordst + 1.
**        ENDLOOP.
**
**        me->update_slg1_log( it_log_ext = gt_log_ext ).
**      ENDIF.
**    ELSE.
**      CLEAR lv_message_v2.
**      lv_message_v2 = gv_entity.
**
**      me->append_slg1_log(
**        iv_tabname    = space
**        iv_message_v1 = 'No data found in table ZONTA_OBJ_OC for entity'
**        iv_message_v2 = lv_message_v2
**        iv_mestyp     = 'S' ).
**
**      me->update_slg1_log( it_log_ext = gt_log_ext ).
**    ENDIF.
**
**
**  ENDMETHOD.


  METHOD send_json_any_table_hcm.



    ""  ⊢― Initialization and Setup
    DATA: dref_table_root   TYPE REF TO data,
          dref_table        TYPE REF TO data,
          lo_table          TYPE REF TO data,
          lo_data           TYPE REF TO data,
          lt_fcat           TYPE slis_t_fieldcat_alv,
          e_size            TYPE zonde_oc_num30,
          e_records         TYPE zonde_oc_num30,
          lt_keys           TYPE tty_where,
          lv_return         TYPE string,
          lv_recordst       TYPE sy-tabix,
          lv_response       TYPE string,
          lv_message_v2     TYPE string,
          lv_exit           TYPE abap_bool,
          lv_exit_set_where TYPE abap_bool,
          lv_key            TYPE string,
          lv_keys_temp      TYPE string,
          lv_max_records    TYPE zonde_registrosn,
          lv_where          TYPE zonttrsdswhere,
          lv_alias          TYPE zonde_aliastab,
          lv_fields         TYPE string,
          lv_send           TYPE boolean,
          lv_message_v1     TYPE string.

    FIELD-SYMBOLS: <fs_root>            TYPE any,
                   <fs_oneconnect>      TYPE any,
                   <fs_properties>      TYPE any,
                   <fs_metadata>        TYPE any,
                   <fs_body_root>       TYPE any,
                   <fs_json>            LIKE LINE OF gt_json, "TYPE any,
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

    " "  ⊢― Set global context
    gv_update   = iv_update.
    gv_delete   = iv_delete.
    gv_anytable = iv_tabname.
    gt_where    = it_where.
    gv_entity   = 'ANY'.
    gv_domainv  = 'ANY'.

    IF iv_alias IS INITIAL.
      gv_fieldname = abap_true.
    ENDIF.

    " "  ⊢― Log process start
    CONCATENATE '*** HCM Table ' iv_tabname ' Process TABLE***'
                INTO lv_message_v1 SEPARATED BY space.

    me->append_slg1_log(
      EXPORTING
        iv_tabname    = space
        iv_message_v1 = lv_message_v1
        iv_message_v2 = space
        iv_message_v3 = space
        iv_mestyp     = 'S' ).

    "  ⊢― Get column definitions
    SELECT * INTO TABLE gt_columns_all
           FROM zonta_oc_col_all
           WHERE tabname EQ iv_tabname.

    IF sy-subrc NE 0.
      CLEAR lv_message_v2.
      lv_message_v2 = gv_entity.

      me->append_slg1_log(
        iv_tabname    = space
        iv_message_v1 = 'No data found in table ZONTA_OC_COL_ALL for entity'
        iv_message_v2 = lv_message_v2
        iv_mestyp     = 'S' ).

      me->update_slg1_log( it_log_ext = gt_log_ext ).
      RETURN.
    ENDIF.
    "  ⊢― Get ALV field catalog
    CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name       = iv_tabname
      CHANGING
        ct_fieldcat            = lt_fcat
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.

    "  ⊢― Get DDIC info
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
      RETURN.
    ENDIF.

    "  ⊢― Load main object and alias configuration
    SELECT SINGLE * INTO gs_oc_obj
           FROM zonta_obj_oc
           WHERE domainv       EQ 'ANY'
             AND business_proc EQ 'ANY'.

    IF sy-subrc EQ 0.

      SELECT SINGLE alias_tabname INTO lv_alias
             FROM zonta_oc_anyalia
             WHERE tabname EQ iv_tabname.

      SELECT SINGLE low INTO gv_dest
             FROM zonta_oc_param
             WHERE name EQ 'RFC_DESTINATION'
               AND type EQ 'P'
               AND numb EQ 1.

      IF sy-subrc EQ 0.

        "  ⊢― Create root object structure (META or standard)
        IF gs_oc_obj-data EQ abap_true.
          CREATE DATA dref_table_root TYPE ty_oneconnect_meta.
        ELSE.
          CREATE DATA dref_table_root TYPE ty_oneconnect.
        ENDIF.

        ASSIGN dref_table_root->* TO <fs_root>.

        ASSIGN COMPONENT 'ONECONNECT' OF STRUCTURE <fs_root> TO <fs_oneconnect>.
        ASSIGN COMPONENT 'PROPERTIES' OF STRUCTURE <fs_oneconnect> TO <fs_properties>.
        me->get_data_properties_any( CHANGING cs_properties = <fs_properties> ).

        ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_oneconnect> TO <fs_metadata_root>.
        APPEND INITIAL LINE TO <fs_metadata_root> ASSIGNING <fs_metadata>.
        ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_metadata> TO <fs_field_metadata>.

        "  ⊢― Determine alias name for metadata
        IF NOT iv_alias IS INITIAL.
          IF NOT lv_alias IS INITIAL.
            <fs_field_metadata> = lv_alias.
          ELSE.
            <fs_field_metadata> = iv_tabname.
          ENDIF.
        ELSE.
          <fs_field_metadata> = iv_tabname.
        ENDIF.

        ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_metadata> TO <fs_metadata_line>.
        ASSIGN COMPONENT 'BODY' OF STRUCTURE <fs_oneconnect> TO <fs_body_root>.
        ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_body_root> TO <fs_field>.

        "  ⊢― Determine alias name for body
        IF NOT iv_alias IS INITIAL.
          IF NOT lv_alias IS INITIAL.
            <fs_field> = lv_alias.
          ELSE.
            <fs_field> = iv_tabname.
          ENDIF.
        ELSE.
          <fs_field> = iv_tabname.
        ENDIF.

        ASSIGN COMPONENT 'DATA' OF STRUCTURE <fs_body_root> TO <fs_table_body_line>.

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

        lv_fields = me->set_fields( iv_alias = gv_fieldname ).

        IF gt_where IS INITIAL.
*          lv_where = me->set_where( iv_any = abap_true ).
          me->set_where( EXPORTING iv_any = abap_true
                                 IMPORTING ev_closed = lv_exit_set_where
                                           r_where = lv_where ).
          IF lv_exit_set_where EQ abap_true.
            RETURN.
          ENDIF.
          me->set_process( IMPORTING ev_closed = lv_exit ).
          IF lv_exit EQ abap_true.
            RETURN.
          ENDIF.
          gt_where = lv_where.
        ELSE.
          lv_where = gt_where.
        ENDIF.

        IF lv_where IS INITIAL.
          RETURN.
        ENDIF.

        "  ⊢― Data extraction
        SELECT (lv_fields)
               INTO CORRESPONDING FIELDS OF TABLE <fs_table>
               FROM (iv_tabname)
               WHERE (lv_where).

        IF sy-subrc NE 0.
          me->append_slg1_log(
            EXPORTING
              iv_tabname    = space
              iv_message_v1 = 'No data found'
              iv_message_v2 = space
              iv_message_v3 = space
              iv_mestyp     = 'S' ).
          RETURN.
        ENDIF.

        "  ⊢― Batch support
        IF NOT gv_batch IS INITIAL.
          me->execute_batch( EXPORTING
                               iv_anytab  = abap_true
                               iv_tabname = iv_tabname ).
          RETURN.
        ENDIF.

        "  ⊢― Build metadata node
        me->set_metadata_node_any(
          EXPORTING
            iv_alias   = gv_fieldname
            it_fcat    = lt_fcat
          CHANGING
            ct_metadata = <fs_metadata_line> ).

        "  ⊢― Process table content
        CLEAR lt_keys.

        lv_send = abap_false.
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
*            gv_recordst_obj = gv_recordst_obj + 1.
            gs_log_json_result-recordst_obj = gs_log_json_result-recordst_obj + 1.
          ENDIF.

          me->append_slg1_log(
            iv_tabname = iv_tabname
            iv_mestyp  = 'S'
            iv_key     = lv_key ).

          APPEND INITIAL LINE TO <fs_body> ASSIGNING <fs_line>.
          MOVE-CORRESPONDING <fs_data> TO <fs_line>.

          "  ⊢― Conversion exit
          me->conversion_exit(
            EXPORTING iv_tabname = iv_tabname
            CHANGING  cs_string  = <fs_line> ).

          "  ⊢― Event ID logic
          IF gs_oc_obj-eventid EQ abap_true OR
             gs_oc_obj-metadata EQ abap_true.

            IF <fs_key> IS ASSIGNED.
              APPEND INITIAL LINE TO lt_keys ASSIGNING <fs_keys_event>.
              <fs_keys_event>-line = <fs_key>.
            ENDIF.

            me->get_eventid(
              EXPORTING it_keys = lt_keys
              CHANGING  cs_line_json = <fs_line> ).
          ENDIF.

          "  ⊢― Serialize and flush JSON if max reached
          IF lv_max_records EQ gs_oc_obj-no_registros.
            APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
            <fs_json>-json_id = gv_jsonid.
            <fs_json>-json =  zoncl_ui2_cl_json=>serialize(
                data             = <fs_root>
                compress         = abap_false
                assoc_arrays     = abap_true
                assoc_arrays_opt = abap_true
                pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).

            REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
            REPLACE 'TABL'        WITH 'TABLE'       INTO <fs_json>-json.
            gv_jsonid = gv_jsonid + 1.
            CLEAR: lv_max_records, <fs_body>.
            lv_send = abap_true.
          ENDIF.
        ENDLOOP.

        "  ⊢― Flush remaining records
        IF lv_max_records LT gs_oc_obj-no_registros AND lv_send = abap_false.
          APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
          <fs_json>-json_id = gv_jsonid.
          <fs_json>-json =  zoncl_ui2_cl_json=>serialize(
            data             = <fs_root>
            compress         = abap_false
            assoc_arrays     = abap_true
            assoc_arrays_opt = abap_true
            pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).

          REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
          REPLACE 'TABL'        WITH 'TABLE'       INTO <fs_json>-json.
        ENDIF.

        "  ⊢― Send JSON batches
        LOOP AT gt_json INTO gs_json.

          gv_json = gs_json-json.
          gv_jsonid = gs_json-json_id.


          me->send_json_http_con(
            EXPORTING i_dest     = gv_dest
            IMPORTING e_return   = lv_return
                      e_size     = e_size
                      e_records  = e_records
                      e_response = lv_response ).

*          gv_sizet    = gv_sizet + e_size.
*          gv_recordst = gv_recordst + 1.

          gs_log_json_result-sizet = gs_log_json_result-sizet + e_size.
          gs_log_json_result-recordst = gs_log_json_result-recordst + 1.

        ENDLOOP.

        "  ⊢― Update log
        me->update_slg1_log( it_log_ext = gt_log_ext ).
      ENDIF.
    ELSE.
      CLEAR lv_message_v2.
      lv_message_v2 = gv_entity.

      me->append_slg1_log(
        iv_tabname    = space
        iv_message_v1 = 'No data found in table ZONTA_OBJ_OC for entity'
        iv_message_v2 = lv_message_v2
        iv_mestyp     = 'S' ).

      me->update_slg1_log( it_log_ext = gt_log_ext ).
    ENDIF.
  ENDMETHOD.

**  METHOD send_json_any_table_hcm.
**
**
**    ""  ⊢― Initialization and Setup
**    DATA: dref_table_root   TYPE REF TO data,
**          dref_table        TYPE REF TO data,
**          lo_table          TYPE REF TO data,
**          lo_data           TYPE REF TO data,
**          lt_fcat           TYPE slis_t_fieldcat_alv,
**          e_size            TYPE zonde_oc_num30,
**          e_records         TYPE zonde_oc_num30,
**          lt_keys           TYPE tty_where,
**          lv_return         TYPE string,
**          lv_recordst       TYPE sy-tabix,
**          lv_response       TYPE string,
**          lv_message_v2     TYPE string,
**          lv_exit           TYPE abap_bool,
**          lv_exit_set_where TYPE abap_bool,
**          lv_key            TYPE string,
**          lv_keys_temp      TYPE string,
**          lv_max_records    TYPE zonde_registrosn,
***          lv_where          TYPE rsds_where_tab,
**          lv_where TYPE zonttrsdswhere,
**          lv_alias          TYPE zonde_aliastab,
**          lv_fields         TYPE string,
**          lv_send           TYPE boolean,
**          lv_message_v1     TYPE string.
**
**    FIELD-SYMBOLS: <fs_root>            TYPE any,
**                   <fs_oneconnect>      TYPE any,
**                   <fs_properties>      TYPE any,
**                   <fs_metadata>        TYPE any,
**                   <fs_body_root>       TYPE any,
**                   <fs_json>            LIKE LINE OF gt_json, "TYPE any,
**                   <fs_field_metadata>  TYPE any,
**                   <fs_metadata_line>   TYPE any,
**                   <fs_field>           TYPE any,
**                   <fs_line>            TYPE any,
**                   <fs_table_body_line> TYPE any,
**                   <fs_body>            TYPE STANDARD TABLE,
**                   <fs_metadata_root>   TYPE STANDARD TABLE,
**                   <fs_table>           TYPE STANDARD TABLE,
**                   <fs_table2>          TYPE ANY TABLE,
**                   <fs_data>            TYPE any,
**                   <fs_table_line>      TYPE any,
**                   <fs_key>             TYPE any,
**                   <fs_key_main>        TYPE any,
**                   <fs_keys_event>      TYPE LINE OF tty_where.
**
**    " "  ⊢― Set global context
**    gv_update   = iv_update.
**    gv_delete   = iv_delete.
**    gv_anytable = iv_tabname.
**    gt_where    = it_where.
**    gv_entity   = 'ANY'.
**    gv_domainv  = 'ANY'.
**
**    IF iv_alias IS INITIAL.
**      gv_fieldname = abap_true.
**    ENDIF.
**
**    " "  ⊢― Log process start
**    CONCATENATE '*** HCM Table ' iv_tabname ' Process TABLE***'
**                INTO lv_message_v1 SEPARATED BY space.
**
**    me->append_slg1_log(
**      EXPORTING
**        iv_tabname    = space
**        iv_message_v1 = lv_message_v1
**        iv_message_v2 = space
**        iv_message_v3 = space
**        iv_mestyp     = 'S' ).
**
**    "  ⊢― Get column definitions
**    SELECT * INTO TABLE gt_columns_all
**           FROM zonta_oc_col_all
**           WHERE tabname EQ iv_tabname.
**
**    IF sy-subrc NE 0.
**      CLEAR lv_message_v2.
**      lv_message_v2 = gv_entity.
**
**      me->append_slg1_log(
**        iv_tabname    = space
**        iv_message_v1 = 'No data found in table ZONTA_OC_COL_ALL for entity'
**        iv_message_v2 = lv_message_v2
**        iv_mestyp     = 'S' ).
**
**      me->update_slg1_log( it_log_ext = gt_log_ext ).
**      RETURN.
**    ENDIF.
**    "  ⊢― Get ALV field catalog
**    CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
**      EXPORTING
**        i_structure_name       = iv_tabname
**      CHANGING
**        ct_fieldcat            = lt_fcat
**      EXCEPTIONS
**        inconsistent_interface = 1
**        program_error          = 2
**        OTHERS                 = 3.
**
**    "  ⊢― Get DDIC info
**    CALL FUNCTION 'DDIF_FIELDINFO_GET'
**      EXPORTING
**        tabname        = iv_tabname
**      TABLES
**        dfies_tab      = gt_dfies_tab
**      EXCEPTIONS
**        not_found      = 1
**        internal_error = 2
**        OTHERS         = 3.
**    IF sy-subrc <> 0.
**      RETURN.
**    ENDIF.
**
**    "  ⊢― Load main object and alias configuration
**    SELECT SINGLE * INTO gs_oc_obj
**           FROM zonta_obj_oc
**           WHERE domainv       EQ 'ANY'
**             AND business_proc EQ 'ANY'.
**
**    IF sy-subrc EQ 0.
**
**      SELECT SINGLE alias_tabname INTO lv_alias
**             FROM zonta_oc_anyalia
**             WHERE tabname EQ iv_tabname.
**
**      SELECT SINGLE low INTO gv_dest
**             FROM zonta_oc_param
**             WHERE name EQ 'RFC_DESTINATION'
**               AND type EQ 'P'
**               AND numb EQ 1.
**
**      IF sy-subrc EQ 0.
**
**        "  ⊢― Create root object structure (META or standard)
**        IF gs_oc_obj-data EQ abap_true.
**          CREATE DATA dref_table_root TYPE ty_oneconnect_meta.
**        ELSE.
**          CREATE DATA dref_table_root TYPE ty_oneconnect.
**        ENDIF.
**
**        ASSIGN dref_table_root->* TO <fs_root>.
**
**        ASSIGN COMPONENT 'ONECONNECT' OF STRUCTURE <fs_root> TO <fs_oneconnect>.
**        ASSIGN COMPONENT 'PROPERTIES' OF STRUCTURE <fs_oneconnect> TO <fs_properties>.
**        me->get_data_properties_any( CHANGING cs_properties = <fs_properties> ).
**
**        ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_oneconnect> TO <fs_metadata_root>.
**        APPEND INITIAL LINE TO <fs_metadata_root> ASSIGNING <fs_metadata>.
**        ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_metadata> TO <fs_field_metadata>.
**
**        "  ⊢― Determine alias name for metadata
**        IF NOT iv_alias IS INITIAL.
**          IF NOT lv_alias IS INITIAL.
**            <fs_field_metadata> = lv_alias.
**          ELSE.
**            <fs_field_metadata> = iv_tabname.
**          ENDIF.
**        ELSE.
**          <fs_field_metadata> = iv_tabname.
**        ENDIF.
**
**        ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_metadata> TO <fs_metadata_line>.
**        ASSIGN COMPONENT 'BODY' OF STRUCTURE <fs_oneconnect> TO <fs_body_root>.
**        ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_body_root> TO <fs_field>.
**
**        "  ⊢― Determine alias name for body
**        IF NOT iv_alias IS INITIAL.
**          IF NOT lv_alias IS INITIAL.
**            <fs_field> = lv_alias.
**          ELSE.
**            <fs_field> = iv_tabname.
**          ENDIF.
**        ELSE.
**          <fs_field> = iv_tabname.
**        ENDIF.
**
**        ASSIGN COMPONENT 'DATA' OF STRUCTURE <fs_body_root> TO <fs_table_body_line>.
**
**        CALL METHOD me->set_table_any
**          EXPORTING
**            iv_alias = iv_alias
**            it_fcat  = lt_fcat
**          RECEIVING
**            rt_table = <fs_table_body_line>.
**
**        ASSIGN <fs_table_body_line>->* TO <fs_body>.
**
**        CALL METHOD me->set_table_any
**          EXPORTING
**            iv_alias = iv_alias
**            it_fcat  = lt_fcat
**          RECEIVING
**            rt_table = lo_data.
**
**        ASSIGN lo_data->* TO <fs_table>.
**
**        lv_fields = me->set_fields( iv_alias = gv_fieldname ).
**
**        IF gt_where IS INITIAL.
***          lv_where = me->set_where( iv_any = abap_true ).
**          me->set_where( EXPORTING iv_any = abap_true
**                         IMPORTING ev_closed = lv_exit_set_where
**                                   r_where = lv_where ).
**          IF lv_exit_set_where EQ abap_true.
**            RETURN.
**          ENDIF.
**          me->set_process( IMPORTING ev_closed = lv_exit ).
**          IF lv_exit EQ abap_true.
**            RETURN.
**          ENDIF.
**          gt_where = lv_where.
**        ELSE.
**          lv_where = gt_where.
**        ENDIF.
**
**        IF lv_where IS INITIAL.
**          RETURN.
**        ENDIF.
**
**        "  ⊢― Data extraction
**        SELECT (lv_fields)
**               INTO CORRESPONDING FIELDS OF TABLE <fs_table>
**               FROM (iv_tabname)
**               WHERE (lv_where).
**
**        IF sy-subrc NE 0.
**          me->append_slg1_log(
**            EXPORTING
**              iv_tabname    = space
**              iv_message_v1 = 'No data found'
**              iv_message_v2 = space
**              iv_message_v3 = space
**              iv_mestyp     = 'S' ).
**          RETURN.
**        ENDIF.
**
**        "  ⊢― Batch support
**        IF NOT gv_batch IS INITIAL.
**          me->execute_batch( EXPORTING
**                               iv_anytab  = abap_true
**                               iv_tabname = iv_tabname ).
**          RETURN.
**        ENDIF.
**
**        "  ⊢― Build metadata node
**        me->set_metadata_node_any(
**          EXPORTING
**            iv_alias   = gv_fieldname
**            it_fcat    = lt_fcat
**          CHANGING
**            ct_metadata = <fs_metadata_line> ).
**
**        "  ⊢― Process table content
**        CLEAR lt_keys.
**
**        lv_send = abap_false.
**        LOOP AT <fs_table> ASSIGNING <fs_data>.
**          CLEAR lt_keys.
**
**          CALL METHOD me->set_key_any
**            EXPORTING
**              iv_alias = iv_alias
**              it_fcat  = lt_fcat
**              is_line  = <fs_data>
**            RECEIVING
**              rv_key   = lv_key.
**
**          ASSIGN lv_key TO <fs_key>.
**
**          IF lv_keys_temp NE lv_key.
**            lv_keys_temp   = lv_key.
**            lv_max_records = lv_max_records + 1.
**            gv_recordst_obj = gv_recordst_obj + 1.
**          ENDIF.
**
**          me->append_slg1_log(
**            iv_tabname = iv_tabname
**            iv_mestyp  = 'S'
**            iv_key     = lv_key ).
**
**          APPEND INITIAL LINE TO <fs_body> ASSIGNING <fs_line>.
**          MOVE-CORRESPONDING <fs_data> TO <fs_line>.
**
**          "  ⊢― Conversion exit
**          me->conversion_exit(
**            EXPORTING iv_tabname = iv_tabname
**            CHANGING  cs_string  = <fs_line> ).
**
**          "  ⊢― Event ID logic
**          IF gs_oc_obj-eventid EQ abap_true OR
**             gs_oc_obj-metadata EQ abap_true.
**
**            IF <fs_key> IS ASSIGNED.
**              APPEND INITIAL LINE TO lt_keys ASSIGNING <fs_keys_event>.
**              <fs_keys_event>-line = <fs_key>.
**            ENDIF.
**
**            me->get_eventid(
**              EXPORTING it_keys = lt_keys
**              CHANGING  cs_line_json = <fs_line> ).
**          ENDIF.
**
**          "  ⊢― Serialize and flush JSON if max reached
**          IF lv_max_records EQ gs_oc_obj-no_registros.
**            APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
**            <fs_json>-json_id = gv_jsonid.
**            <fs_json>-json =  zoncl_ui2_cl_json=>serialize(
**                data             = <fs_root>
**                compress         = abap_false
**                assoc_arrays     = abap_true
**                assoc_arrays_opt = abap_true
**                pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).
**
**            REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
**            REPLACE 'TABL'        WITH 'TABLE'       INTO <fs_json>-json.
**            gv_jsonid = gv_jsonid + 1.
**            CLEAR: lv_max_records, <fs_body>.
**            lv_send = abap_true.
**          ENDIF.
**        ENDLOOP.
**
**        "  ⊢― Flush remaining records
**        IF lv_max_records LT gs_oc_obj-no_registros AND lv_send = abap_false.
**          APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
**          <fs_json>-json_id = gv_jsonid.
**          <fs_json>-json =  zoncl_ui2_cl_json=>serialize(
**            data             = <fs_root>
**            compress         = abap_false
**            assoc_arrays     = abap_true
**            assoc_arrays_opt = abap_true
**            pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).
**
**          REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
**          REPLACE 'TABL'        WITH 'TABLE'       INTO <fs_json>-json.
**        ENDIF.
**
**        "  ⊢― Send JSON batches
**        LOOP AT gt_json INTO gs_json.
**
**          gv_json = gs_json-json.
**          gv_jsonid = gs_json-json_id.
**
**
**          me->send_json_http_con(
**            EXPORTING i_dest     = gv_dest
**            IMPORTING e_return   = lv_return
**                      e_size     = e_size
**                      e_records  = e_records
**                      e_response = lv_response ).
**
**          gv_sizet    = gv_sizet + e_size.
**          gv_recordst = gv_recordst + 1.
**        ENDLOOP.
**
**        "  ⊢― Update log
**        me->update_slg1_log( it_log_ext = gt_log_ext ).
**      ENDIF.
**    ELSE.
**      CLEAR lv_message_v2.
**      lv_message_v2 = gv_entity.
**
**      me->append_slg1_log(
**        iv_tabname    = space
**        iv_message_v1 = 'No data found in table ZONTA_OBJ_OC for entity'
**        iv_message_v2 = lv_message_v2
**        iv_mestyp     = 'S' ).
**
**      me->update_slg1_log( it_log_ext = gt_log_ext ).
**    ENDIF.
**  ENDMETHOD.


  METHOD send_json_any_table_ltables.

    CONSTANTS: c_rawstring TYPE c VALUE 'y',
               c_string    TYPE c VALUE 'X',
               c_256       TYPE c LENGTH 6 VALUE '000256'.

    "------------------------------------------------------------
    " Local Data Declarations
    "------------------------------------------------------------
    DATA: dref_table_root TYPE REF TO data,
          dref_table      TYPE REF TO data,
          lo_table        TYPE REF TO data,
          lo_data         TYPE REF TO data,
          lo_linea_ref    TYPE REF TO data,
          lo_rtti_origen  TYPE REF TO cl_abap_structdescr,
          lt_fcat         TYPE slis_t_fieldcat_alv,
          e_size          TYPE zonde_oc_num30,
          e_records       TYPE zonde_oc_num30,
          lt_keys         TYPE tty_where,
          lt_component    TYPE cl_abap_structdescr=>component_table,
          lt_component_2  TYPE cl_abap_structdescr=>component_table,
          lv_return       TYPE string,
          lv_recordst     TYPE sy-tabix,
          lv_response     TYPE string,
          lv_key          TYPE string,
          lv_keys_temp    TYPE string,
          lv_max_records  TYPE zonde_registrosn,
          lv_where        TYPE rsds_where_tab,
          lv_alias        TYPE zonde_aliastab,
          lv_fields       TYPE string,
          lv_result       TYPE string,
          lv_message_v2   TYPE string,
          lv_error(200)   TYPE c,
          lo_ref          TYPE REF TO cx_sy_dynamic_osql_semantics,
          lt_fields       TYPE TABLE OF line,
          lv_tab          TYPE tabname,
          lv_ltab         TYPE tabname,
          lv_ltabname     TYPE tabname,
          lv_aliastab     TYPE zonde_aliastab,
          lv_error_stop   TYPE boolean,
          lv_send         TYPE boolean,
          lv_addcol       TYPE boolean,
          ls_columns_all  TYPE zonta_oc_col_all,
          ls_dfies        LIKE LINE OF gt_dfies_tab.

    FIELD-SYMBOLS: <fs_data_table> TYPE any.

    DATA ls_fieldname LIKE LINE OF lt_component.
    DATA ls_field_2   LIKE LINE OF lt_component_2.
    DATA ls_column2   LIKE LINE OF gt_columns_all.
    DATA ls_column   LIKE LINE OF gt_columns_all.
    "------------------------------------------------------------
    " Field-Symbols
    "------------------------------------------------------------
    FIELD-SYMBOLS: <fs_root>            TYPE any,
                   <fs_oneconnect>      TYPE any,
                   <fs_properties>      TYPE any,
                   <fs_metadata>        TYPE any,
                   <fs_body_root>       TYPE any,
                   <fs_json>            LIKE LINE OF gt_json, "TYPE any,
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
                   <fs_keys_event>      TYPE LINE OF tty_where,
                   <fs_fcat>            LIKE LINE OF lt_fcat,
                   <ls_linea_table>     TYPE any,
                   <fs_field_data>      TYPE any,
                   <fs_field_tosend>    TYPE any.

    "------------------------------------------------------------
    " Initialization and Global Variable Assignment
    "------------------------------------------------------------
   me->debug_procedure( ).

    lv_error_stop  = abap_false.

    " Reset JSON accumulators so the method is self-contained and does not
    " depend on the caller doing FREE go_handler between calls. Prevents both
    " unbounded memory growth (SYSTEM_NO_ROLL) and re-sending stale payloads.
    CLEAR: gt_json[], gv_jsonid, gv_json.

    gv_update    = iv_update.
    gv_delete    = iv_delete.
    gv_anytable  = iv_tabname.
    gv_aliastab  = iv_aliastab.

    IF iv_aliastablong IS NOT INITIAL.
      gv_aliastab = iv_aliastablong.
    ENDIF.

*    gt_where     = it_where.
    gv_entity    = iv_entity_business_proc.
    gv_domainv   = 'ANY'.
    gv_dest      = iv_dest.
    gv_fieldname = iv_fieldname.
    gv_bothnames = iv_bothnames.

    " Log start of processing
    me->append_slg1_log(
      EXPORTING
        iv_tabname    = space
        iv_message_v1 = '*** Any Table Process TABLE Automatic***'
        iv_message_v2 = space
        iv_message_v3 = space
        iv_mestyp     = 'S' ).

    "------------------------------------------------------------
    " Retrieve metadata: columns, ALV field catalog, and DFIES
    "------------------------------------------------------------
    lv_ltabname = iv_tabname.
    lv_ltabname = to_upper( lv_ltabname ).

    lv_aliastab = iv_aliastab.
    lv_aliastab  = to_upper(  lv_aliastab ).


*020626
    IF iv_structure IS INITIAL.
      SELECT * INTO TABLE gt_columns_all
        FROM zonta_oc_col_all
        WHERE tabname      = lv_ltabname
        AND alias_tabname = lv_aliastab .
      IF sy-subrc NE 0.
        CLEAR lv_message_v2.
        lv_message_v2 = gv_entity.

        me->append_slg1_log(
          iv_tabname    = space
          iv_message_v1 = 'No data found in table ZONTA_OC_COL_ALL for entity'
          iv_message_v2 = lv_message_v2
          iv_mestyp     = 'S' ).
        me->update_slg1_log( it_log_ext = gt_log_ext ).
        lv_addcol = abap_true.
*        RETURN.
      ENDIF.
    ENDIF.

    IF iv_structure IS INITIAL.
      CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
        EXPORTING
          i_structure_name = iv_tabname
        CHANGING
          ct_fieldcat      = lt_fcat
        EXCEPTIONS
          OTHERS           = 3.

      CALL FUNCTION 'DDIF_FIELDINFO_GET'
        EXPORTING
          tabname   = iv_tabname
        TABLES
          dfies_tab = gt_dfies_tab
        EXCEPTIONS
          OTHERS    = 3.

      IF sy-subrc <> 0.
        " Handle DFIES error if needed
      ENDIF.
    ELSE.

      CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
        EXPORTING
          i_structure_name = iv_structure
        CHANGING
          ct_fieldcat      = lt_fcat
        EXCEPTIONS
          OTHERS           = 3.

      CALL FUNCTION 'DDIF_FIELDINFO_GET'
        EXPORTING
          tabname   = iv_structure
        TABLES
          dfies_tab = gt_dfies_tab
        EXCEPTIONS
          OTHERS    = 3.

      IF sy-subrc = 0.
        lv_addcol = abap_true.
      ENDIF.
    ENDIF.

    SORT gt_dfies_tab BY position fieldname.
    SORT lt_fcat BY fieldname.
    LOOP AT gt_dfies_tab INTO ls_dfies.
      READ TABLE lt_fcat ASSIGNING <fs_fcat> WITH KEY fieldname = ls_dfies-fieldname BINARY SEARCH.
      IF sy-subrc NE 0.
        APPEND INITIAL LINE TO lt_fcat ASSIGNING <fs_fcat>.
        MOVE-CORRESPONDING ls_dfies TO <fs_fcat>.
      ENDIF.

      <fs_fcat>-ddic_outputlen = ls_dfies-offset.
      <fs_fcat>-inttype        = ls_dfies-inttype.
      <fs_fcat>-decimals_out   = ls_dfies-decimals.
      <fs_fcat>-col_pos        = ls_dfies-position.
      <fs_fcat>-offset         = ls_dfies-offset.
      <fs_fcat>-outputlen      = ls_dfies-outputlen.

      IF <fs_fcat>-inttype = c_rawstring.
        <fs_fcat>-inttype = c_string.
        <fs_fcat>-ddic_outputlen = c_256.
      ENDIF.

      IF <fs_fcat>-seltext_l IS INITIAL.
        <fs_fcat>-seltext_l = ls_dfies-scrtext_l.
        <fs_fcat>-seltext_m = ls_dfies-scrtext_m.
        <fs_fcat>-seltext_s = ls_dfies-scrtext_s.
      ENDIF.
      IF lv_addcol = abap_true.
        ls_columns_all-id_column          = '000'.
        ls_columns_all-tabname            = iv_tabname.
        ls_columns_all-alias_tabname      = ''.
        ls_columns_all-fldname            = ls_dfies-fieldname.
        ls_columns_all-alias_fldname      = ''.
        ls_columns_all-key_field          = ls_dfies-keyflag.
        ls_columns_all-selection_field    = ''.
        ls_columns_all-description_field  = ''.
        ls_columns_all-seckey_field       = ''.
        ls_columns_all-positionf          = ls_dfies-position.
        APPEND ls_columns_all TO gt_columns_all.
        CLEAR ls_columns_all.
      ENDIF.
    ENDLOOP.

    SORT lt_fcat BY row_pos fieldname.

    "------------------------------------------------------------
    " Load base configuration object and destination if missing
    "------------------------------------------------------------
    SELECT SINGLE * INTO gs_oc_obj
      FROM zonta_obj_oc
      WHERE domainv       = gv_domainv
        AND business_proc = gv_entity.

    IF sy-subrc EQ 0.

      SELECT SINGLE alias_tabname INTO lv_alias
        FROM zonta_oc_anyalia
        WHERE tabname = iv_tabname.

      IF gv_dest IS INITIAL.
        SELECT SINGLE low INTO gv_dest
          FROM zonta_oc_param
          WHERE name = 'RFC_DESTINATION'
            AND type = 'P'
            AND numb = 1.
      ENDIF.

      IF gv_dest IS NOT INITIAL. "sy-subrc EQ 0.

        "--------------------------------------------------------
        " Create root structure for ONECONNECT export
        "--------------------------------------------------------
        IF gs_oc_obj-data EQ abap_true.
          CREATE DATA dref_table_root TYPE ty_oneconnect_meta.
        ELSE.
          CREATE DATA dref_table_root TYPE ty_oneconnect.
        ENDIF.

        ASSIGN dref_table_root->* TO <fs_root>.
        ASSIGN COMPONENT 'ONECONNECT' OF STRUCTURE <fs_root> TO <fs_oneconnect>.
        ASSIGN COMPONENT 'PROPERTIES' OF STRUCTURE <fs_oneconnect> TO <fs_properties>.

        " Fill PROPERTIES node
        me->get_data_properties_any( CHANGING cs_properties = <fs_properties> ).

        ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_oneconnect> TO <fs_metadata_root>.
        APPEND INITIAL LINE TO <fs_metadata_root> ASSIGNING <fs_metadata>.
        ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_metadata> TO <fs_field_metadata>.

        " Set metadata field label (alias or table name)
        IF iv_fieldname IS INITIAL.
          IF NOT iv_bothnames IS INITIAL.
            <fs_field_metadata> = iv_tabname && '_' && lv_alias.
          ELSEIF lv_alias IS NOT INITIAL AND gv_alias IS NOT INITIAL.
            <fs_field_metadata> = lv_alias.
          ELSE.
            <fs_field_metadata> = iv_tabname.
          ENDIF.
        ELSE.
          <fs_field_metadata> = iv_tabname.
        ENDIF.

        ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_metadata> TO <fs_metadata_line>.
        ASSIGN COMPONENT 'BODY' OF STRUCTURE <fs_oneconnect> TO <fs_body_root>.
        ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_body_root> TO <fs_field>.

        " Set field name for BODY node
        IF iv_fieldname IS INITIAL.
          IF NOT iv_bothnames IS INITIAL.
            <fs_field> = iv_tabname && '_' && lv_alias.
          ELSEIF lv_alias IS NOT INITIAL AND gv_alias IS NOT INITIAL.
            <fs_field> = lv_alias.
          ELSE.
            <fs_field> = iv_tabname.
          ENDIF.
        ELSE.
          <fs_field> = iv_tabname.
        ENDIF.

        ASSIGN COMPONENT 'DATA' OF STRUCTURE <fs_body_root> TO <fs_table_body_line>.

        "--------------------------------------------------------
        " Create dynamic tables for BODY and result data
        "--------------------------------------------------------
        CALL METHOD me->set_table_any
          EXPORTING
            iv_alias = iv_alias
            it_fcat  = lt_fcat
          RECEIVING
            rt_table = <fs_table_body_line>.

        ASSIGN <fs_table_body_line>->* TO <fs_body>.

        CALL METHOD me->set_table_any
          EXPORTING
            iv_alias = iv_alias "iv_fieldname CHECK
            it_fcat  = lt_fcat
          RECEIVING
            rt_table = lo_data.

        ASSIGN lo_data->* TO <fs_table>.

        "--------------------------------------------------------
        " Compose WHERE and SELECT fields
        "--------------------------------------------------------
*      lv_fields = me->set_fields( iv_alias = iv_alias ).


*        IF gt_where IS INITIAL.
*          lv_where = me->set_where_any( iv_any = abap_true ).
*          me->set_process( ).
*          gt_where = lv_where.
*        ELSE.
*          lv_where = gt_where.
*        ENDIF.
*
*        IF lv_where IS INITIAL.
*          MESSAGE i000(fb) WITH 'No filter selected'.
*          RETURN.
*        ENDIF.
        "--------------------------------------------------------
        " Fetch Data Dynamically (CDS or Transparent Table)
        "--------------------------------------------------------
        TRY.
*            IF is_cds_entity( iv_tabname ) = abap_true.
*            me->set_fields_in_table(
*              EXPORTING
*                iv_tabname = iv_tabname
*                iv_alias   = iv_alias
*              IMPORTING
*                et_fields  = lt_fields ).
*
*              SELECT (lt_fields) FROM (iv_tabname)
*                WHERE (lv_where)
*                INTO CORRESPONDING FIELDS OF TABLE @<fs_table>.
*            ELSE.
*              lv_fields = me->set_fields( iv_alias = iv_alias ).
*              SELECT (lv_fields)
*                INTO CORRESPONDING FIELDS OF TABLE <fs_table>
*                FROM (iv_tabname)
*                WHERE (lv_where).
*            ENDIF.

            LOOP AT it_tables_data ASSIGNING <fs_data_table>.
              IF sy-tabix EQ 1.
                lo_rtti_origen ?= cl_abap_typedescr=>describe_by_data( <fs_data_table> ).
                lt_component = lo_rtti_origen->get_components( ).
              ENDIF.
              CREATE DATA lo_linea_ref LIKE LINE OF <fs_table>.
              ASSIGN lo_linea_ref->* TO <ls_linea_table>.

              IF sy-subrc = 0.
                MOVE-CORRESPONDING <fs_data_table> TO <ls_linea_table>.
                IF <ls_linea_table> IS INITIAL.
                  LOOP AT lt_component INTO ls_fieldname.

                    IF ls_fieldname-as_include = abap_true.
                      lo_rtti_origen ?= ls_fieldname-type.
                      lt_component_2 = lo_rtti_origen->get_components( ).

                      LOOP AT lt_component_2 INTO ls_field_2.

                        ASSIGN COMPONENT ls_field_2-name OF STRUCTURE <fs_data_table> TO <fs_field_data>.

                        READ TABLE gt_columns_all INTO ls_column2
                                WITH KEY tabname = iv_tabname
                                         fldname = ls_field_2-name.
                        IF sy-subrc EQ 0.

                          IF ls_column2-alias_fldname IS NOT INITIAL.
                            ASSIGN COMPONENT ls_column2-alias_fldname OF STRUCTURE <ls_linea_table> TO <fs_field_tosend>.
                          ELSE.
                            ASSIGN COMPONENT ls_column2-fldname OF STRUCTURE <ls_linea_table> TO <fs_field_tosend>.
                          ENDIF.

                          IF <fs_field_data> IS ASSIGNED AND <fs_field_tosend> IS ASSIGNED.
                            <fs_field_tosend> = <fs_field_data>.
                          ENDIF.
                        ENDIF.
                      ENDLOOP.

                    ENDIF.
                    ASSIGN COMPONENT ls_fieldname-name OF STRUCTURE <fs_data_table> TO <fs_field_data>.

                    READ TABLE gt_columns_all INTO ls_column
                            WITH KEY tabname = iv_tabname
                                     fldname = ls_fieldname-name.
                    IF sy-subrc EQ 0.

                      IF ls_column-alias_fldname IS NOT INITIAL.
                        ASSIGN COMPONENT ls_column-alias_fldname OF STRUCTURE <ls_linea_table> TO <fs_field_tosend>.
                      ELSE.
                        ASSIGN COMPONENT ls_column-fldname OF STRUCTURE <ls_linea_table> TO <fs_field_tosend>.
                      ENDIF.

                      IF <fs_field_data> IS ASSIGNED AND <fs_field_tosend> IS ASSIGNED.
                        <fs_field_tosend> = <fs_field_data>.
                      ENDIF.
                    ENDIF.
                  ENDLOOP.
                ENDIF.
                IF <ls_linea_table> IS NOT INITIAL.
                  APPEND <ls_linea_table> TO <fs_table>.
                ENDIF.
              ENDIF.
            ENDLOOP.

            IF <fs_table> IS INITIAL.
              MESSAGE i000(fb) WITH 'No data found'.

              me->append_slg1_log(
                EXPORTING
                  iv_tabname    = space
                  iv_message_v1 = 'No data found'
                  iv_message_v2 = space
                  iv_message_v3 = space
                  iv_mestyp     = 'S' ).

              RETURN.
            ENDIF.

          CATCH cx_sy_dynamic_osql_semantics INTO lo_ref.
            lv_result = lo_ref->get_text( ).
            lv_error  = lv_result.

            sy-msgv1 = lv_error+0(50).
            sy-msgv2 = lv_error+50(50).
            sy-msgv3 = lv_error+100(50).
            sy-msgv4 = lv_error+150(50).



            gs_elog-type       = 'SEND_JSON_ANY_TABLE'.
            gs_elog-severity   = gc_error.
            gs_elog-message    = lo_ref->get_longtext( ).
            CALL METHOD lo_ref->get_source_position
              IMPORTING
                program_name = gv_prog
                source_line  = gv_sline.
            gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
            gs_elog-details-db = 'ZONCL_OC_ANY_HANDLER-SEND_JSON_ANY_TABLE'.
            gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.


            gs_elog-metadata-error_code = gs_elog-details-error_code.
            interpret_message( EXPORTING iv_msgnr = '097' iv_msgv1 = iv_tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '098' iv_msgv1 = iv_tabname  IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '099' iv_msgv1 = iv_tabname  IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '100'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
            interpret_message( EXPORTING iv_msgnr = '101'  IMPORTING ev_message = gv_msg5 CHANGING ct_table = gt_causes ).
            CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 gv_msg5 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
            interpret_message( EXPORTING iv_msgnr = '076'  iv_msgv1 = iv_tabname IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '086'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_fixes ).
            interpret_message( EXPORTING iv_msgnr = '087'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_fixes ).
            CONCATENATE gv_msg1 gv_msg2 gv_msg3 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.
            print_error_otel( ).
            send_json_error( ).
*            MESSAGE i000(fb) WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            lv_error_stop = abap_true.
        ENDTRY.

        CHECK lv_error_stop = abap_false.
        "--------------------------------------------------------
        " Run as Background Batch if Configured
        "--------------------------------------------------------
        IF NOT gv_batch IS INITIAL.
          me->execute_batch(
            EXPORTING
              iv_anytab  = abap_true
              iv_tabname = iv_tabname ).
          RETURN.
        ENDIF.

        "--------------------------------------------------------
        " Fill METADATA node
        "--------------------------------------------------------
        me->set_metadata_node_any(
          EXPORTING
            iv_alias      = iv_fieldname
            iv_structure  = iv_structure
            it_fcat     = lt_fcat
          CHANGING
            ct_metadata = <fs_metadata_line> ).

        "--------------------------------------------------------
        " Loop over selected data and build JSON objects
        "--------------------------------------------------------
*        gv_recordst = gv_recordst + lv_recordst.
        gs_log_json_result-recordst   = gs_log_json_result-recordst + lv_recordst.

        CLEAR lt_keys.

        lv_send = abap_false.
        LOOP AT <fs_table> ASSIGNING <fs_data>.
          CLEAR lt_keys.

          " Generate key from line content
          CALL METHOD me->set_key_any
            EXPORTING
              iv_alias = iv_alias
              it_fcat  = lt_fcat
              is_line  = <fs_data>
            RECEIVING
              rv_key   = lv_key.

          ASSIGN lv_key TO <fs_key>.

          " Track new keys to count records
          IF lv_keys_temp NE lv_key.
            lv_keys_temp   = lv_key.
            lv_max_records = lv_max_records + 1.
*            gv_recordst_obj = gv_recordst_obj + 1.
            gs_log_json_result-recordst_obj = gs_log_json_result-recordst_obj + 1.
          ENDIF.

          " Log key to application log
          me->append_slg1_log(
            iv_tabname = iv_tabname
            iv_mestyp  = 'S'
            iv_key     = lv_key ).

          " Add line to body node
          APPEND INITIAL LINE TO <fs_body> ASSIGNING <fs_line>.
          MOVE-CORRESPONDING <fs_data> TO <fs_line>.

          " Apply conversion exit for display format
          me->conversion_exit(
            EXPORTING
              iv_tabname = iv_tabname
            CHANGING
              cs_string  = <fs_line> ).

          " Add event ID if configured
          IF gs_oc_obj-eventid  = abap_true OR
             gs_oc_obj-metadata = abap_true.

            IF <fs_key> IS ASSIGNED.
              APPEND INITIAL LINE TO lt_keys ASSIGNING <fs_keys_event>.
              <fs_keys_event>-line = <fs_key>.
            ENDIF.

            me->get_eventid(
              EXPORTING
                it_keys      = lt_keys
              CHANGING
                cs_line_json = <fs_line> ).
          ENDIF.

          " Serialize and send when reaching max records per message
          IF lv_max_records EQ gs_oc_obj-no_registros.
            APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
            <fs_json>-json_id = gv_jsonid.
            <fs_json>-json =  zoncl_ui2_cl_json=>serialize(
                data             = <fs_root>
                compress         = abap_false
                assoc_arrays     = abap_true
                assoc_arrays_opt = abap_true
                pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).

            " Replace technical strings for compatibility
            REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
            REPLACE 'TABL'        WITH 'TABLE'        INTO <fs_json>-json.
            gv_jsonid = gv_jsonid + 1.
            CLEAR: lv_max_records, <fs_body>.
            lv_send = abap_true.
          ENDIF.
        ENDLOOP.

        "--------------------------------------------------------
        " Serialize remaining records if limit not reached
        "--------------------------------------------------------
        IF lv_max_records LT gs_oc_obj-no_registros AND lv_send = abap_false.
          APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
          <fs_json>-json_id = gv_jsonid.
          <fs_json>-json = zoncl_ui2_cl_json=>serialize(
            data             = <fs_root>
            compress         = abap_false
            assoc_arrays     = abap_true
            assoc_arrays_opt = abap_true
            pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).

          REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
          REPLACE 'TABL'        WITH 'TABLE'        INTO <fs_json>-json.
        ENDIF.

        "--------------------------------------------------------
        " Send each JSON payload and track result
        "--------------------------------------------------------
        LOOP AT gt_json INTO gs_json.

          gv_json = gs_json-json.
          gv_jsonid = gs_json-json_id.

*          IF gv_recordst_obj IS INITIAL.
*            describe table <fs_table> lines gv_recordst_obj.
*          ENDIF.
          IF gs_log_json_result-recordst_obj IS INITIAL.
            DESCRIBE TABLE <fs_table> LINES gs_log_json_result-recordst_obj.
          ENDIF.

          me->pretty_json_any(
            EXPORTING
              iv_mode = c_table
            CHANGING
              cv_json = gv_json ).

          me->send_json_http_con(
            EXPORTING
              i_dest     = gv_dest
            IMPORTING
              e_return   = lv_return
              e_size     = e_size
              e_records  = e_records
              e_response = lv_response ).

*          gv_sizet    = gv_sizet + e_size.
*          ev_size    = gv_sizet + e_size.
*          gv_recordst = gv_recordst + 1.
*          ev_records = gv_recordst + 1.

          gs_log_json_result-sizet    = gs_log_json_result-sizet + e_size.
          ev_size    = gs_log_json_result-sizet + e_size.
          gs_log_json_result-recordst = gs_log_json_result-recordst + 1.
          ev_records = gs_log_json_result-recordst + 1.

*          gs_log_json_result-sizet = gv_sizet.
*          gs_log_json_result-recordst   = gv_recordst.
*          gs_log_json_result-recordst_obj = gv_recordst_obj.

        ENDLOOP.

        "--------------------------------------------------------
        " Finalize logging and output
        "--------------------------------------------------------
        IF iv_structure IS INITIAL.
          me->send_json_result( ).
        ENDIF.

        me->update_slg1_log( it_log_ext = gt_log_ext ).

      ENDIF.
    ELSE.
      CLEAR lv_message_v2.
      lv_message_v2 = gv_entity.

      me->append_slg1_log(
        iv_tabname    = space
        iv_message_v1 = 'No data found in table ZONTA_OBJ_OC for entity'
        iv_message_v2 = lv_message_v2
        iv_mestyp     = 'S' ).

      me->update_slg1_log( it_log_ext = gt_log_ext ).
    ENDIF.

  ENDMETHOD.

**  METHOD send_json_any_table_ltables.
**
**    CONSTANTS: c_rawstring TYPE c VALUE 'y',
**               c_string    TYPE c VALUE 'X',
**               c_256       TYPE c LENGTH 6 VALUE '000256'.
**
**    "------------------------------------------------------------
**    " Local Data Declarations
**    "------------------------------------------------------------
**    DATA: dref_table_root TYPE REF TO data,
**          dref_table      TYPE REF TO data,
**          lo_table        TYPE REF TO data,
**          lo_data         TYPE REF TO data,
**          lo_linea_ref    TYPE REF TO data,
**          lo_rtti_origen  TYPE REF TO cl_abap_structdescr,
**          lt_fcat         TYPE slis_t_fieldcat_alv,
**          e_size          TYPE zonde_oc_num30,
**          e_records       TYPE zonde_oc_num30,
**          lt_keys         TYPE tty_where,
**          lt_component    TYPE cl_abap_structdescr=>component_table,
**          lt_component_2  TYPE cl_abap_structdescr=>component_table,
**          lv_return       TYPE string,
**          lv_recordst     TYPE sy-tabix,
**          lv_response     TYPE string,
**          lv_key          TYPE string,
**          lv_keys_temp    TYPE string,
**          lv_max_records  TYPE zonde_registrosn,
**          lv_where        TYPE rsds_where_tab,
**          lv_alias        TYPE zonde_aliastab,
**          lv_fields       TYPE string,
**          lv_result       TYPE string,
**          lv_message_v2   TYPE string,
**          lv_error(200)   TYPE c,
**          lo_ref          TYPE REF TO cx_sy_dynamic_osql_semantics,
**          lt_fields       TYPE TABLE OF line,
**          lv_tab          TYPE tabname,
**          lv_ltab         TYPE tabname,
**          lv_ltabname     TYPE tabname,
**          lv_aliastab     TYPE zonde_aliastab,
**          lv_error_stop   TYPE boolean,
**          lv_send         TYPE boolean,
**          lv_addcol       TYPE boolean,
**          ls_columns_all  TYPE zonta_oc_col_all,
**          ls_dfies        LIKE LINE OF gt_dfies_tab.
**
**    "------------------------------------------------------------
**    " Field-Symbols
**    "------------------------------------------------------------
**    FIELD-SYMBOLS: <fs_root>            TYPE any,
**                   <fs_oneconnect>      TYPE any,
**                   <fs_properties>      TYPE any,
**                   <fs_metadata>        TYPE any,
**                   <fs_body_root>       TYPE any,
**                   <fs_json>            LIKE LINE OF gt_json, "TYPE any,
**                   <fs_field_metadata>  TYPE any,
**                   <fs_metadata_line>   TYPE any,
**                   <fs_field>           TYPE any,
**                   <fs_line>            TYPE any,
**                   <fs_table_body_line> TYPE any,
**                   <fs_body>            TYPE STANDARD TABLE,
**                   <fs_metadata_root>   TYPE STANDARD TABLE,
**                   <fs_table>           TYPE STANDARD TABLE,
**                   <fs_table2>          TYPE ANY TABLE,
**                   <fs_data>            TYPE any,
**                   <fs_table_line>      TYPE any,
**                   <fs_key>             TYPE any,
**                   <fs_key_main>        TYPE any,
**                   <fs_keys_event>      TYPE LINE OF tty_where,
**                   <fs_fcat>            LIKE LINE OF lt_fcat,
**                   <ls_linea_table>     TYPE any,
**                   <fs_field_data>      TYPE any,
**                   <fs_field_tosend>    TYPE any.
**
********
**    FIELD-SYMBOLS: <fs_data_table> TYPE any.
**
**    DATA ls_fieldname LIKE LINE OF lt_component.
**    data ls_field_2   like line of lt_component_2.
**    data ls_column2   like line of gt_columns_all.
**    data ls_column   like line of gt_columns_all.
**
********
**
**    "------------------------------------------------------------
**    " Initialization and Global Variable Assignment
**    "------------------------------------------------------------
**    me->debug_procedure( ).
**
**    lv_error_stop  = abap_false.
**    gv_update    = iv_update.
**    gv_delete    = iv_delete.
**    gv_anytable  = iv_tabname.
**    gv_aliastab  = iv_aliastab.
**
**
**    IF iv_aliastablong IS NOT INITIAL.
**      gv_aliastab = iv_aliastablong.
**    ENDIF.
**
***    gt_where     = it_where.
**    gv_entity    = iv_entity_business_proc.
**    gv_domainv   = 'ANY'.
**    gv_dest      = iv_dest.
**    gv_fieldname = iv_fieldname.
**    gv_bothnames = iv_bothnames.
**
**    " Log start of processing
**    me->append_slg1_log(
**      EXPORTING
**        iv_tabname    = space
**        iv_message_v1 = '*** Any Table Process TABLE Automatic***'
**        iv_message_v2 = space
**        iv_message_v3 = space
**        iv_mestyp     = 'S' ).
**
**    "------------------------------------------------------------
**    " Retrieve metadata: columns, ALV field catalog, and DFIES
**    "------------------------------------------------------------
**    lv_ltabname = iv_tabname.
**    lv_ltabname = to_upper( lv_ltabname ).
**
**    lv_aliastab = iv_aliastab.
**    lv_aliastab  = to_upper(  lv_aliastab ).
**
**
***020626
**    IF iv_structure IS INITIAL.
**      SELECT * INTO TABLE gt_columns_all
**        FROM zonta_oc_col_all
**        WHERE tabname      = lv_ltabname
**        AND alias_tabname = lv_aliastab .
**      IF sy-subrc NE 0.
**        CLEAR lv_message_v2.
**        lv_message_v2 = gv_entity.
**
**        me->append_slg1_log(
**          iv_tabname    = space
**          iv_message_v1 = 'No data found in table ZONTA_OC_COL_ALL for entity'
**          iv_message_v2 = lv_message_v2
**          iv_mestyp     = 'S' ).
**        me->update_slg1_log( it_log_ext = gt_log_ext ).
**        lv_addcol = abap_true.
***        RETURN.
**      ENDIF.
**    ENDIF.
**
**    IF iv_structure IS INITIAL.
**      CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
**        EXPORTING
**          i_structure_name = iv_tabname
**        CHANGING
**          ct_fieldcat      = lt_fcat
**        EXCEPTIONS
**          OTHERS           = 3.
**
**      CALL FUNCTION 'DDIF_FIELDINFO_GET'
**        EXPORTING
**          tabname   = iv_tabname
**        TABLES
**          dfies_tab = gt_dfies_tab
**        EXCEPTIONS
**          OTHERS    = 3.
**
**      IF sy-subrc <> 0.
**        " Handle DFIES error if needed
**      ENDIF.
**    ELSE.
**
**      CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
**        EXPORTING
**          i_structure_name = iv_structure
**        CHANGING
**          ct_fieldcat      = lt_fcat
**        EXCEPTIONS
**          OTHERS           = 3.
**
**      CALL FUNCTION 'DDIF_FIELDINFO_GET'
**        EXPORTING
**          tabname   = iv_structure
**        TABLES
**          dfies_tab = gt_dfies_tab
**        EXCEPTIONS
**          OTHERS    = 3.
**
**      IF sy-subrc = 0.
**        lv_addcol = abap_true.
**      ENDIF.
**    ENDIF.
**
**    SORT gt_dfies_tab BY position fieldname.
**    SORT lt_fcat BY fieldname.
**    LOOP AT gt_dfies_tab INTO ls_dfies.
**      READ TABLE lt_fcat ASSIGNING <fs_fcat> WITH KEY fieldname = ls_dfies-fieldname BINARY SEARCH.
**      IF sy-subrc NE 0.
**        APPEND INITIAL LINE TO lt_fcat ASSIGNING <fs_fcat>.
**        MOVE-CORRESPONDING ls_dfies TO <fs_fcat>.
**      ENDIF.
**
**      <fs_fcat>-ddic_outputlen = ls_dfies-offset.
**      <fs_fcat>-inttype        = ls_dfies-inttype.
**      <fs_fcat>-decimals_out   = ls_dfies-decimals.
**      <fs_fcat>-col_pos        = ls_dfies-position.
**      <fs_fcat>-offset         = ls_dfies-offset.
**      <fs_fcat>-outputlen      = ls_dfies-outputlen.
**
**      IF <fs_fcat>-inttype = c_rawstring.
**        <fs_fcat>-inttype = c_string.
**        <fs_fcat>-ddic_outputlen = c_256.
**      ENDIF.
**
**      IF <fs_fcat>-seltext_l IS INITIAL.
**        <fs_fcat>-seltext_l = ls_dfies-scrtext_l.
**        <fs_fcat>-seltext_m = ls_dfies-scrtext_m.
**        <fs_fcat>-seltext_s = ls_dfies-scrtext_s.
**      ENDIF.
**      IF lv_addcol = abap_true.
**        ls_columns_all-id_column          = '000'.
**        ls_columns_all-tabname            = iv_tabname.
**        ls_columns_all-alias_tabname      = ''.
**        ls_columns_all-fldname            = ls_dfies-fieldname.
**        ls_columns_all-alias_fldname      = ''.
**        ls_columns_all-key_field          = ls_dfies-keyflag.
**        ls_columns_all-selection_field    = ''.
**        ls_columns_all-description_field  = ''.
**        ls_columns_all-seckey_field       = ''.
**        ls_columns_all-positionf          = ls_dfies-position.
**        APPEND ls_columns_all TO gt_columns_all.
**        CLEAR ls_columns_all.
**      ENDIF.
**    ENDLOOP.
**
**    SORT lt_fcat BY row_pos fieldname.
**
**    "------------------------------------------------------------
**    " Load base configuration object and destination if missing
**    "------------------------------------------------------------
**    SELECT SINGLE * INTO gs_oc_obj
**      FROM zonta_obj_oc
**      WHERE domainv       = gv_domainv
**        AND business_proc = gv_entity.
**
**    IF sy-subrc EQ 0.
**
**      SELECT SINGLE alias_tabname INTO lv_alias
**        FROM zonta_oc_anyalia
**        WHERE tabname = iv_tabname.
**
**      IF gv_dest IS INITIAL.
**        SELECT SINGLE low INTO gv_dest
**          FROM zonta_oc_param
**          WHERE name = 'RFC_DESTINATION'
**            AND type = 'P'
**            AND numb = 1.
**      ENDIF.
**
**      IF sy-subrc EQ 0.
**
**        "--------------------------------------------------------
**        " Create root structure for ONECONNECT export
**        "--------------------------------------------------------
**        IF gs_oc_obj-data EQ abap_true.
**          CREATE DATA dref_table_root TYPE ty_oneconnect_meta.
**        ELSE.
**          CREATE DATA dref_table_root TYPE ty_oneconnect.
**        ENDIF.
**
**        ASSIGN dref_table_root->* TO <fs_root>.
**        ASSIGN COMPONENT 'ONECONNECT' OF STRUCTURE <fs_root> TO <fs_oneconnect>.
**        ASSIGN COMPONENT 'PROPERTIES' OF STRUCTURE <fs_oneconnect> TO <fs_properties>.
**
**        " Fill PROPERTIES node
**        me->get_data_properties_any( CHANGING cs_properties = <fs_properties> ).
**
**        ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_oneconnect> TO <fs_metadata_root>.
**        APPEND INITIAL LINE TO <fs_metadata_root> ASSIGNING <fs_metadata>.
**        ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_metadata> TO <fs_field_metadata>.
**
**        " Set metadata field label (alias or table name)
**        IF iv_fieldname IS INITIAL.
**          IF NOT iv_bothnames IS INITIAL.
**            <fs_field_metadata> = iv_tabname && '_' && lv_alias.
**          ELSEIF lv_alias IS NOT INITIAL AND gv_alias IS NOT INITIAL.
**            <fs_field_metadata> = lv_alias.
**          ELSE.
**            <fs_field_metadata> = iv_tabname.
**          ENDIF.
**        ELSE.
**          <fs_field_metadata> = iv_tabname.
**        ENDIF.
**
**        ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_metadata> TO <fs_metadata_line>.
**        ASSIGN COMPONENT 'BODY' OF STRUCTURE <fs_oneconnect> TO <fs_body_root>.
**        ASSIGN COMPONENT 'TABLE' OF STRUCTURE <fs_body_root> TO <fs_field>.
**
**        " Set field name for BODY node
**        IF iv_fieldname IS INITIAL.
**          IF NOT iv_bothnames IS INITIAL.
**            <fs_field> = iv_tabname && '_' && lv_alias.
**          ELSEIF lv_alias IS NOT INITIAL AND gv_alias IS NOT INITIAL.
**            <fs_field> = lv_alias.
**          ELSE.
**            <fs_field> = iv_tabname.
**          ENDIF.
**        ELSE.
**          <fs_field> = iv_tabname.
**        ENDIF.
**
**        ASSIGN COMPONENT 'DATA' OF STRUCTURE <fs_body_root> TO <fs_table_body_line>.
**
**        "--------------------------------------------------------
**        " Create dynamic tables for BODY and result data
**        "--------------------------------------------------------
**        CALL METHOD me->set_table_any
**          EXPORTING
**            iv_alias = iv_alias
**            it_fcat  = lt_fcat
**          RECEIVING
**            rt_table = <fs_table_body_line>.
**
**        ASSIGN <fs_table_body_line>->* TO <fs_body>.
**
**        CALL METHOD me->set_table_any
**          EXPORTING
**            iv_alias = iv_alias "iv_fieldname CHECK
**            it_fcat  = lt_fcat
**          RECEIVING
**            rt_table = lo_data.
**
**        ASSIGN lo_data->* TO <fs_table>.
**
**        "--------------------------------------------------------
**        " Compose WHERE and SELECT fields
**        "--------------------------------------------------------
***      lv_fields = me->set_fields( iv_alias = iv_alias ).
**
**
***        IF gt_where IS INITIAL.
***          lv_where = me->set_where_any( iv_any = abap_true ).
***          me->set_process( ).
***          gt_where = lv_where.
***        ELSE.
***          lv_where = gt_where.
***        ENDIF.
***
***        IF lv_where IS INITIAL.
***          MESSAGE i000(fb) WITH 'No filter selected'.
***          RETURN.
***        ENDIF.
**        "--------------------------------------------------------
**        " Fetch Data Dynamically (CDS or Transparent Table)
**        "--------------------------------------------------------
**        TRY.
***            IF is_cds_entity( iv_tabname ) = abap_true.
***            me->set_fields_in_table(
***              EXPORTING
***                iv_tabname = iv_tabname
***                iv_alias   = iv_alias
***              IMPORTING
***                et_fields  = lt_fields ).
***
***              SELECT (lt_fields) FROM (iv_tabname)
***                WHERE (lv_where)
***                INTO CORRESPONDING FIELDS OF TABLE @<fs_table>.
***            ELSE.
***              lv_fields = me->set_fields( iv_alias = iv_alias ).
***              SELECT (lv_fields)
***                INTO CORRESPONDING FIELDS OF TABLE <fs_table>
***                FROM (iv_tabname)
***                WHERE (lv_where).
***            ENDIF.
**
***            LOOP AT it_tables_data ASSIGNING field-symbol(<fs_data_table>).
**            LOOP AT it_tables_data ASSIGNING <fs_data_table>.
**              IF sy-tabix EQ 1.
**                lo_rtti_origen ?= cl_abap_typedescr=>describe_by_data( <fs_data_table> ).
**                lt_component = lo_rtti_origen->get_components( ).
**              ENDIF.
**              CREATE DATA lo_linea_ref LIKE LINE OF <fs_table>.
**              ASSIGN lo_linea_ref->* TO <ls_linea_table>.
**
**              IF sy-subrc = 0.
**                MOVE-CORRESPONDING <fs_data_table> TO <ls_linea_table>.
**                IF <ls_linea_table> IS INITIAL.
***                  LOOP AT lt_component INTO data(ls_fieldname).
**                  LOOP AT lt_component INTO ls_fieldname.
**
**                    IF ls_fieldname-as_include = abap_true.
**                      lo_rtti_origen ?= ls_fieldname-type.
**                      lt_component_2 = lo_rtti_origen->get_components( ).
**
***                      LOOP AT lt_component_2 INTO data(ls_field_2).
**                      LOOP AT lt_component_2 INTO ls_field_2.
**
**                        ASSIGN COMPONENT ls_field_2-name OF STRUCTURE <fs_data_table> TO <fs_field_data>.
**
***                        READ TABLE gt_columns_all INTO data(ls_column2)
**                        READ TABLE gt_columns_all INTO ls_column2
**                                WITH KEY tabname = iv_tabname
**                                         fldname = ls_field_2-name.
**                        IF sy-subrc EQ 0.
**
**                          IF ls_column2-alias_fldname IS NOT INITIAL.
**                            ASSIGN COMPONENT ls_column2-alias_fldname OF STRUCTURE <ls_linea_table> TO <fs_field_tosend>.
**                          ELSE.
**                            ASSIGN COMPONENT ls_column2-fldname OF STRUCTURE <ls_linea_table> TO <fs_field_tosend>.
**                          ENDIF.
**
**                          IF <fs_field_data> IS ASSIGNED AND <fs_field_tosend> IS ASSIGNED.
**                            <fs_field_tosend> = <fs_field_data>.
**                          ENDIF.
**                        ENDIF.
**                      ENDLOOP.
**
**                    ENDIF.
**                    ASSIGN COMPONENT ls_fieldname-name OF STRUCTURE <fs_data_table> TO <fs_field_data>.
**
***                    READ TABLE gt_columns_all INTO data(ls_column)
**                    READ TABLE gt_columns_all INTO ls_column
**                            WITH KEY tabname = iv_tabname
**                                     fldname = ls_fieldname-name.
**                    IF sy-subrc EQ 0.
**
**                      IF ls_column-alias_fldname IS NOT INITIAL.
**                        ASSIGN COMPONENT ls_column-alias_fldname OF STRUCTURE <ls_linea_table> TO <fs_field_tosend>.
**                      ELSE.
**                        ASSIGN COMPONENT ls_column-fldname OF STRUCTURE <ls_linea_table> TO <fs_field_tosend>.
**                      ENDIF.
**
**                      IF <fs_field_data> IS ASSIGNED AND <fs_field_tosend> IS ASSIGNED.
**                        <fs_field_tosend> = <fs_field_data>.
**                      ENDIF.
**                    ENDIF.
**                  ENDLOOP.
**                ENDIF.
**                IF <ls_linea_table> IS NOT INITIAL.
**                  APPEND <ls_linea_table> TO <fs_table>.
**                ENDIF.
**              ENDIF.
**            ENDLOOP.
**
**            IF <fs_table> IS INITIAL.
**              MESSAGE i000(fb) WITH 'No data found'.
**
**              me->append_slg1_log(
**                EXPORTING
**                  iv_tabname    = space
**                  iv_message_v1 = 'No data found'
**                  iv_message_v2 = space
**                  iv_message_v3 = space
**                  iv_mestyp     = 'S' ).
**
**              RETURN.
**            ENDIF.
**
**          CATCH cx_sy_dynamic_osql_semantics INTO lo_ref.
**            lv_result = lo_ref->get_text( ).
**            lv_error  = lv_result.
**
**            sy-msgv1 = lv_error+0(50).
**            sy-msgv2 = lv_error+50(50).
**            sy-msgv3 = lv_error+100(50).
**            sy-msgv4 = lv_error+150(50).
**
**
**
**            gs_elog-type       = 'SEND_JSON_ANY_TABLE'.
**            gs_elog-severity   = gc_error.
**            gs_elog-message    = lo_ref->get_longtext( ).
**            CALL METHOD lo_ref->get_source_position
**              IMPORTING
**                program_name = gv_prog
**                source_line  = gv_sline.
**            gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
**            gs_elog-details-db = 'ZONCL_OC_ANY_HANDLER-SEND_JSON_ANY_TABLE'.
**            gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.
**
**
**            gs_elog-metadata-error_code = gs_elog-details-error_code.
**            interpret_message( EXPORTING iv_msgnr = '097' iv_msgv1 = iv_tabname IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
**            interpret_message( EXPORTING iv_msgnr = '098' iv_msgv1 = iv_tabname  IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
**            interpret_message( EXPORTING iv_msgnr = '099' iv_msgv1 = iv_tabname  IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
**            interpret_message( EXPORTING iv_msgnr = '100'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_causes ).
**            interpret_message( EXPORTING iv_msgnr = '101'  IMPORTING ev_message = gv_msg5 CHANGING ct_table = gt_causes ).
**            CONCATENATE gv_msg1 gv_msg2 gv_msg3 gv_msg4 gv_msg5 INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
**            interpret_message( EXPORTING iv_msgnr = '076'  iv_msgv1 = iv_tabname IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_fixes ).
**            interpret_message( EXPORTING iv_msgnr = '086'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_fixes ).
**            interpret_message( EXPORTING iv_msgnr = '087'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_fixes ).
**            CONCATENATE gv_msg1 gv_msg2 gv_msg3 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.
**            print_error_otel( ).
**            send_json_error( ).
***            MESSAGE i000(fb) WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
**            lv_error_stop = abap_true.
**        ENDTRY.
**
**        CHECK lv_error_stop = abap_false.
**        "--------------------------------------------------------
**        " Run as Background Batch if Configured
**        "--------------------------------------------------------
**        IF NOT gv_batch IS INITIAL.
**          me->execute_batch(
**            EXPORTING
**              iv_anytab  = abap_true
**              iv_tabname = iv_tabname ).
**          RETURN.
**        ENDIF.
**
**        "--------------------------------------------------------
**        " Fill METADATA node
**        "--------------------------------------------------------
**        me->set_metadata_node_any(
**          EXPORTING
**            iv_alias      = iv_fieldname
**            iv_structure  = iv_structure
**            it_fcat     = lt_fcat
**          CHANGING
**            ct_metadata = <fs_metadata_line> ).
**
**        "--------------------------------------------------------
**        " Loop over selected data and build JSON objects
**        "--------------------------------------------------------
**        gv_recordst = gv_recordst + lv_recordst.
**
**        CLEAR lt_keys.
**
**        lv_send = abap_false.
**        LOOP AT <fs_table> ASSIGNING <fs_data>.
**          CLEAR lt_keys.
**
**          " Generate key from line content
**          CALL METHOD me->set_key_any
**            EXPORTING
**              iv_alias = iv_alias
**              it_fcat  = lt_fcat
**              is_line  = <fs_data>
**            RECEIVING
**              rv_key   = lv_key.
**
**          ASSIGN lv_key TO <fs_key>.
**
**          " Track new keys to count records
**          IF lv_keys_temp NE lv_key.
**            lv_keys_temp   = lv_key.
**            lv_max_records = lv_max_records + 1.
**            gv_recordst_obj = gv_recordst_obj + 1.
**          ENDIF.
**
**          " Log key to application log
**          me->append_slg1_log(
**            iv_tabname = iv_tabname
**            iv_mestyp  = 'S'
**            iv_key     = lv_key ).
**
**          " Add line to body node
**          APPEND INITIAL LINE TO <fs_body> ASSIGNING <fs_line>.
**          MOVE-CORRESPONDING <fs_data> TO <fs_line>.
**
**          " Apply conversion exit for display format
**          me->conversion_exit(
**            EXPORTING
**              iv_tabname = iv_tabname
**            CHANGING
**              cs_string  = <fs_line> ).
**
**          " Add event ID if configured
**          IF gs_oc_obj-eventid  = abap_true OR
**             gs_oc_obj-metadata = abap_true.
**
**            IF <fs_key> IS ASSIGNED.
**              APPEND INITIAL LINE TO lt_keys ASSIGNING <fs_keys_event>.
**              <fs_keys_event>-line = <fs_key>.
**            ENDIF.
**
**            me->get_eventid(
**              EXPORTING
**                it_keys      = lt_keys
**              CHANGING
**                cs_line_json = <fs_line> ).
**          ENDIF.
**
**          " Serialize and send when reaching max records per message
**          IF lv_max_records EQ gs_oc_obj-no_registros.
**            APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
**            <fs_json>-json_id = gv_jsonid.
**            <fs_json>-json =  zoncl_ui2_cl_json=>serialize(
**                data             = <fs_root>
**                compress         = abap_false
**                assoc_arrays     = abap_true
**                assoc_arrays_opt = abap_true
**                pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).
**
**            " Replace technical strings for compatibility
**            REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
**            REPLACE 'TABL'        WITH 'TABLE'        INTO <fs_json>-json.
**            gv_jsonid = gv_jsonid + 1.
**            CLEAR: lv_max_records, <fs_body>.
**            lv_send = abap_true.
**          ENDIF.
**        ENDLOOP.
**
**        "--------------------------------------------------------
**        " Serialize remaining records if limit not reached
**        "--------------------------------------------------------
**        IF lv_max_records LT gs_oc_obj-no_registros AND lv_send = abap_false.
**          APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
**          <fs_json>-json_id = gv_jsonid.
**          <fs_json>-json = zoncl_ui2_cl_json=>serialize(
**            data             = <fs_root>
**            compress         = abap_false
**            assoc_arrays     = abap_true
**            assoc_arrays_opt = abap_true
**            pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).
**
**          REPLACE 'messagetype' WITH 'messageType' INTO <fs_json>-json.
**          REPLACE 'TABL'        WITH 'TABLE'        INTO <fs_json>-json.
**        ENDIF.
**
**        "--------------------------------------------------------
**        " Send each JSON payload and track result
**        "--------------------------------------------------------
**        LOOP AT gt_json INTO gs_json.
**
**          gv_json = gs_json-json.
**          gv_jsonid = gs_json-json_id.
**
**          IF gv_recordst_obj IS INITIAL.
**            gv_recordst_obj = 1.
**          ENDIF.
**
**          me->pretty_json_any(
**            EXPORTING
**              iv_mode = c_table
**            CHANGING
**              cv_json = gv_json ).
**
**          me->send_json_http_con(
**            EXPORTING
**              i_dest     = gv_dest
**            IMPORTING
**              e_return   = lv_return
**              e_size     = e_size
**              e_records  = e_records
**              e_response = lv_response ).
**
**          gv_sizet    = gv_sizet + e_size.
**          ev_size    = gv_sizet + e_size.
**          gv_recordst = gv_recordst + 1.
**          ev_records = gv_recordst + 1.
**        ENDLOOP.
**
**        "--------------------------------------------------------
**        " Finalize logging and output
**        "--------------------------------------------------------
**        IF iv_structure IS INITIAL.
**          me->send_json_result( ).
**        ENDIF.
**
**        me->update_slg1_log( it_log_ext = gt_log_ext ).
**
**      ENDIF.
**    ELSE.
**      CLEAR lv_message_v2.
**      lv_message_v2 = gv_entity.
**
**      me->append_slg1_log(
**        iv_tabname    = space
**        iv_message_v1 = 'No data found in table ZONTA_OBJ_OC for entity'
**        iv_message_v2 = lv_message_v2
**        iv_mestyp     = 'S' ).
**
**      me->update_slg1_log( it_log_ext = gt_log_ext ).
**    ENDIF.
**
**  ENDMETHOD.


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
                      lv_field
                      INTO rv_key
                      SEPARATED BY space.

          UNASSIGN <fs_field>.
        ENDIF.
      ENDIF.
    ENDLOOP.

    SHIFT rv_key LEFT DELETING LEADING space.
  ENDMETHOD.


  METHOD set_metadata_node_any.

    DATA: ls_columns    TYPE zonta_oc_col_all,
          ls_component  TYPE zonta_oc_col_all,
          lt_col_single TYPE STANDARD TABLE OF zonta_oc_col_all,
          lt_df_single  TYPE STANDARD TABLE OF  dfies,
          lt_dfies_tab  TYPE STANDARD TABLE OF  dfies,
          lt_dfies_tabt TYPE STANDARD TABLE OF  dfies,
          lt_dfies_taba TYPE STANDARD TABLE OF  dfies,
          ls_dfies      TYPE dfies,
          lv_int        TYPE i,
          lv_len        TYPE outputlen.
*
    FIELD-SYMBOLS: <fs_metadata>   TYPE any,
                   <fs_field>      TYPE any,
                   <fs_dfies_tab>  TYPE dfies,
                   <fs_dfies_taba> TYPE dfies,
                   <fs_col>        TYPE zonta_oc_col_all,
                   <fs_len>        TYPE any.

    FIELD-SYMBOLS: <fs_metadata_chg> TYPE STANDARD TABLE.

    ASSIGN ct_metadata TO <fs_metadata_chg>.

    IF gt_columns_all IS INITIAL.
      lt_df_single[] = lt_dfies_tab[].
      SORT lt_df_single BY tabname.
      DELETE ADJACENT DUPLICATES FROM lt_df_single COMPARING tabname.
    ELSE.
      lt_col_single[] = gt_columns_all[].
      SORT lt_col_single BY tabname.
      DELETE ADJACENT DUPLICATES FROM lt_col_single COMPARING tabname.
    ENDIF.

    LOOP AT lt_df_single INTO ls_dfies.
      APPEND INITIAL LINE TO lt_col_single ASSIGNING <fs_col>.
      <fs_col>-tabname = ls_dfies-tabname.
    ENDLOOP.

    CLEAR lt_dfies_taba[].

    LOOP AT lt_col_single ASSIGNING <fs_col>.
      CLEAR lt_dfies_tabt[].
      IF iv_structure IS INITIAL.
        CALL FUNCTION 'DDIF_FIELDINFO_GET'
          EXPORTING
            tabname        = <fs_col>-tabname
          TABLES
            dfies_tab      = lt_dfies_tabt
          EXCEPTIONS
            not_found      = 1
            internal_error = 2
            OTHERS         = 3.
        IF sy-subrc = 0.
          APPEND LINES OF lt_dfies_tabt[] TO lt_dfies_taba[].
        ENDIF.
      ELSE.
        CALL FUNCTION 'DDIF_FIELDINFO_GET'
          EXPORTING
            tabname        = iv_structure
          TABLES
            dfies_tab      = lt_dfies_tabt
          EXCEPTIONS
            not_found      = 1
            internal_error = 2
            OTHERS         = 3.
        IF sy-subrc = 0.
          APPEND LINES OF lt_dfies_tabt[] TO lt_dfies_taba[].
        ENDIF.
      ENDIF.
    ENDLOOP.


    IF gt_columns_all IS INITIAL.
      LOOP AT lt_dfies_taba ASSIGNING <fs_dfies_taba>.

        APPEND INITIAL LINE TO <fs_metadata_chg> ASSIGNING <fs_metadata>.

        ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE <fs_metadata> TO <fs_field>.
        READ TABLE gt_columns_all WITH KEY tabname = <fs_dfies_taba>-tabname
                                             fldname = <fs_dfies_taba>-fieldname
                                             INTO ls_component.
        IF sy-subrc EQ 0.
          IF gv_bothnames EQ abap_true.
            <fs_field> = <fs_dfies_taba>-fieldname &&
                         '_'                 &&
                         ls_component-alias_fldname.

          ELSE.
            IF gv_fieldname EQ abap_true.
              <fs_field> = <fs_dfies_taba>-fieldname.
            ELSE.
              IF NOT ls_component-alias_fldname IS INITIAL.
                <fs_field> = ls_component-alias_fldname.
              ELSE.
                <fs_field> = <fs_dfies_taba>-fieldname.
              ENDIF.
            ENDIF.
          ENDIF.
        ELSE.
          <fs_field> = <fs_dfies_taba>-fieldname.
        ENDIF.

        REPLACE ALL OCCURRENCES OF '\'   IN <fs_field> WITH '_'.
        REPLACE ALL OCCURRENCES OF '/'   IN <fs_field> WITH '_'.


        TRANSLATE <fs_field> TO LOWER CASE.

        ASSIGN COMPONENT 'OFFSET' OF STRUCTURE <fs_metadata> TO <fs_field>.
        <fs_field>    = <fs_dfies_taba>-offset.


*       Check length
        IF <fs_dfies_taba>-outputlen < <fs_dfies_taba>-intlen.
          lv_len = <fs_dfies_taba>-intlen.
        ELSE.
          lv_len = <fs_dfies_taba>-outputlen.
        ENDIF.

        ASSIGN COMPONENT 'TYPE' OF STRUCTURE <fs_metadata> TO <fs_field>.
        <fs_field>      = <fs_dfies_taba>-inttype.
        IF <fs_field> = 'y'.
          ASSIGN COMPONENT 'LENGTH' OF STRUCTURE <fs_metadata> TO <fs_len>.
          metadata_conversion( CHANGING cv_type  =  <fs_field> cv_len = <fs_len> ).
          ASSIGN COMPONENT 'LENGTH' OF STRUCTURE <fs_metadata> TO <fs_field>.
          <fs_field>    = <fs_len>.
        ELSE.
          metadata_conversion( CHANGING cv_type  =  <fs_field>  ).
          ASSIGN COMPONENT 'LENGTH' OF STRUCTURE <fs_metadata> TO <fs_field>.
          <fs_field>    = lv_len. "<fs_dfies_taba>-outputlen.
        ENDIF.


        ASSIGN COMPONENT 'FIELDTEXT' OF STRUCTURE <fs_metadata> TO <fs_field>.
        <fs_field> = <fs_dfies_taba>-fieldtext.

        ASSIGN COMPONENT 'KEYFLAG' OF STRUCTURE <fs_metadata> TO <fs_field>.
        IF NOT <fs_dfies_taba>-keyflag IS INITIAL.
          <fs_field>   = <fs_dfies_taba>-keyflag.
        ELSE.
          <fs_field>   = space.
        ENDIF.

        ASSIGN COMPONENT 'DECIMALS' OF STRUCTURE <fs_metadata> TO <fs_field>.
        lv_int      = <fs_dfies_taba>-decimals.
        <fs_field>  = lv_int.  "DECIMALS INT
        CONDENSE <fs_field>.
      ENDLOOP.
    ELSE.
      LOOP AT lt_dfies_taba ASSIGNING <fs_dfies_taba>.

        READ TABLE gt_columns_all WITH KEY fldname = <fs_dfies_taba>-fieldname
                                  INTO ls_columns.
        IF sy-subrc EQ 0.
          APPEND INITIAL LINE TO <fs_metadata_chg> ASSIGNING <fs_metadata>.

          ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE <fs_metadata> TO <fs_field>.

          IF gv_bothnames EQ abap_true.
            <fs_field> = <fs_dfies_taba>-fieldname &&
                         '_'               &&
                         ls_columns-alias_fldname.

          ELSE.
            IF gv_fieldname EQ abap_true.
              <fs_field> = <fs_dfies_taba>-fieldname.
            ELSE.
              IF NOT ls_columns-alias_fldname IS INITIAL.
                <fs_field> = ls_columns-alias_fldname.
              ELSE.
                <fs_field> = <fs_dfies_taba>-fieldname.
              ENDIF.
            ENDIF.
          ENDIF.

          REPLACE ALL OCCURRENCES OF '\'   IN <fs_field> WITH '_'.
          REPLACE ALL OCCURRENCES OF '/'   IN <fs_field> WITH '_'.

          TRANSLATE <fs_field> TO LOWER CASE.

          ASSIGN COMPONENT 'OFFSET' OF STRUCTURE <fs_metadata> TO <fs_field>.
          <fs_field>    = <fs_dfies_taba>-offset.

*          ASSIGN COMPONENT 'LENGTH' OF STRUCTURE <fs_metadata> TO <fs_field>.
*          <fs_field>    = <fs_dfies_taba>-outputlen.

*       Check length
          IF <fs_dfies_taba>-outputlen < <fs_dfies_taba>-intlen.
            lv_len = <fs_dfies_taba>-intlen.
          ELSE.
            lv_len = <fs_dfies_taba>-outputlen.
          ENDIF.

          ASSIGN COMPONENT 'TYPE' OF STRUCTURE <fs_metadata> TO <fs_field>.
          <fs_field>      = <fs_dfies_taba>-inttype.
          IF <fs_field> = 'y'.
            ASSIGN COMPONENT 'LENGTH' OF STRUCTURE <fs_metadata> TO <fs_len>.
            metadata_conversion( CHANGING cv_type  =  <fs_field> cv_len = <fs_len> ).
            ASSIGN COMPONENT 'LENGTH' OF STRUCTURE <fs_metadata> TO <fs_field>.
            <fs_field>    = <fs_len>.
          ELSE.
            metadata_conversion( CHANGING cv_type  =  <fs_field>  ).
            ASSIGN COMPONENT 'LENGTH' OF STRUCTURE <fs_metadata> TO <fs_field>.
            <fs_field>    = lv_len. "<fs_dfies_taba>-outputlen.
          ENDIF.

          ASSIGN COMPONENT 'FIELDTEXT' OF STRUCTURE <fs_metadata> TO <fs_field>.
          IF iv_alias IS INITIAL.
            IF NOT ls_columns-alias_fldname IS INITIAL.
              <fs_field> = ls_columns-description_field.
            ELSE.
              <fs_field> = <fs_dfies_taba>-fieldtext.
            ENDIF.
          ELSE.
            <fs_field> = <fs_dfies_taba>-fieldtext.
          ENDIF.

          ASSIGN COMPONENT 'KEYFLAG' OF STRUCTURE <fs_metadata> TO <fs_field>.
          IF NOT <fs_dfies_taba>-keyflag IS INITIAL.
            <fs_field>   = <fs_dfies_taba>-keyflag.
          ELSE.
            <fs_field>   = space.
          ENDIF.

          ASSIGN COMPONENT 'DECIMALS' OF STRUCTURE <fs_metadata> TO <fs_field>.
          lv_int      = <fs_dfies_taba>-decimals.
          <fs_field>  = lv_int.  "DECIMALS INT
          CONDENSE <fs_field>.
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
        IF NOT <fs_dfies_tab>-keyflag IS INITIAL.
          <fs_field>   = <fs_dfies_tab>-keyflag.
        ELSE.
          <fs_field>   = space.
        ENDIF.

        ASSIGN COMPONENT 'DECIMALS' OF STRUCTURE <fs_metadata> TO <fs_field>.
        <fs_field> = <fs_dfies_tab>-decimals.
      ENDLOOP.

    ENDIF.

** End Add Event id fields

  ENDMETHOD.


  METHOD set_table_any.

    DATA: ls_dyn_fcat      TYPE lvc_s_fcat,
          lt_dyn_fcat      TYPE lvc_t_fcat,
          lt_dfies_tab     TYPE STANDARD TABLE OF dfies,
          lt_dfies_tab_cat TYPE STANDARD TABLE OF dfies,
          ls_fcat          TYPE LINE OF slis_t_fieldcat_alv,
          lv_pos           TYPE i,
          fname            TYPE string,
          lv_field         TYPE string,
          lv_tabname       TYPE  ddobjname,
          lt_dyn_table     TYPE REF TO data.


    FIELD-SYMBOLS: <fs_fcat>          LIKE LINE OF it_fcat, "TYPE any,
                   <fs_columns>       TYPE zonta_oc_col_all,
                   <fs_dfies_tab>     TYPE dfies,
                   <fs_dfies_tab_add> TYPE dfies,
                   <fs_dyn_table>     TYPE STANDARD TABLE.

*** This would create structure Vendor Jan13 Feb13 Mar13 ....
    IF iv_anytable IS INITIAL.
      SORT gt_columns_all BY key_field DESCENDING.

      IF NOT gt_columns_all IS INITIAL.
        LOOP AT gt_columns_all ASSIGNING <fs_columns>.
          READ TABLE it_fcat WITH KEY  fieldname = <fs_columns>-fldname
                                       ASSIGNING <fs_fcat>.
          IF sy-subrc EQ 0.
            MOVE-CORRESPONDING <fs_fcat> TO ls_dyn_fcat.
            ls_dyn_fcat-decimals = <fs_fcat>-decimals_out.

            IF  gv_fieldname IS INITIAL .
              IF NOT gv_bothnames IS INITIAL.
                ls_dyn_fcat-fieldname = <fs_columns>-fldname.
              ELSE.
                IF NOT <fs_columns>-alias_fldname IS INITIAL AND gv_alias IS NOT INITIAL.
                  ls_dyn_fcat-fieldname = <fs_columns>-alias_fldname.
                ELSE.
                  ls_dyn_fcat-fieldname = <fs_columns>-fldname.
                ENDIF.
              ENDIF.
            ELSE.
              ls_dyn_fcat-fieldname = <fs_columns>-fldname.
            ENDIF.
            TRANSLATE ls_dyn_fcat-fieldname TO UPPER CASE.
            APPEND ls_dyn_fcat TO lt_dyn_fcat.

          ENDIF.
        ENDLOOP.
      ELSE.
        LOOP AT it_fcat ASSIGNING <fs_fcat>.
          lv_pos = lv_pos + 1.
          MOVE-CORRESPONDING <fs_fcat> TO ls_dyn_fcat.
          ls_dyn_fcat-decimals = <fs_fcat>-decimals_out.
          APPEND ls_dyn_fcat TO lt_dyn_fcat.
        ENDLOOP.
      ENDIF.

    ELSE.
      LOOP AT it_fcat ASSIGNING <fs_fcat>.
        lv_pos = lv_pos + 1.
        MOVE-CORRESPONDING <fs_fcat> TO ls_dyn_fcat.
        ls_dyn_fcat-decimals = <fs_fcat>-decimals_out.
        APPEND ls_dyn_fcat TO lt_dyn_fcat.
      ENDLOOP.
    ENDIF.

** Start Add Event id fields
    IF gs_oc_obj-eventid  EQ abap_true OR
       gs_oc_obj-metadata EQ abap_true.

      SORT lt_dyn_fcat BY col_pos.

      DESCRIBE TABLE lt_dyn_fcat LINES lv_pos.

      READ TABLE lt_dyn_fcat INDEX lv_pos
                             INTO ls_dyn_fcat.

      lv_pos = ls_dyn_fcat-col_pos..


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

        READ TABLE lt_dyn_fcat WITH KEY fieldname = <fs_dfies_tab>-fieldname
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

          CLEAR ls_dyn_fcat.

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
          APPEND ls_dyn_fcat TO lt_dyn_fcat.
          CLEAR ls_dyn_fcat.

        ENDIF.
      ENDLOOP.

    ENDIF.

** End Add Event id fields

* Create a dynamic internal table with this structure.
    SORT lt_dyn_fcat BY fieldname.
    DELETE ADJACENT DUPLICATES FROM lt_dyn_fcat COMPARING fieldname.
    SORT lt_dyn_fcat BY tabname col_pos.

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

  ENDMETHOD.


  METHOD set_where_any.

    TYPES: BEGIN OF lty_rsds_where,
             tablename TYPE rsdstabs-prim_tab,
             where_tab TYPE zonttrsdswhere,
           END OF lty_rsds_where.

    TYPES: ty_rsds_twhere TYPE STANDARD TABLE OF lty_rsds_where.

    DATA: selid          TYPE rsdynsel-selid,
          field_tab      TYPE TABLE OF rsdsfields,
          field_tab_excl TYPE TABLE OF rsdsfields,
          table_tab      TYPE TABLE OF rsdstabs,
          cond_tab       TYPE rsds_twhere,
          lv_title       TYPE sy-title,
          lv_join        TYPE string,
          lt_relations   TYPE STANDARD TABLE OF zonta_relations,
          lt_columns     TYPE STANDARD TABLE OF zonta_oc_col_all,
          lt_cond_tab    TYPE ty_rsds_twhere,
          ls_relations   TYPE zonta_relations,
          ls_cond_tab    TYPE LINE OF ty_rsds_twhere,
          lv_lines       TYPE sy-tabix,
          lv_sequence    TYPE string,
          lv_tabname     TYPE  ddobjname.

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


  METHOD zonif_oc_data_handler~send_data.

  ENDMETHOD.
ENDCLASS.
