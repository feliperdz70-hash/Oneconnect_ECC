class ZONCL_OC_KDOC_HANDLER definition
  public
  inheriting from ZONCL_OC_BASE_HANDLER
  create public .

public section.

  methods DELETE_DATA_BODY
    importing
      !IV_PARENT_RELATION type ZONDE_PARENTREL
      !IS_LINE type ANY optional
    changing
      !CS_LINE_JSON type ANY optional
      value(CS_BODY) type ANY optional
      value(CS_ROOT) type ANY optional .
  methods GET_DATA_BODY
    importing
      !IV_PARENT_RELATION type ZONDE_PARENTREL
      !IS_LINE type ANY optional
    changing
      !CS_LINE_JSON type ANY optional
      value(CS_BODY) type ANY optional
      value(CS_ROOT) type ANY optional .
  methods GET_DATA_KDOC .

  methods GET_DATA
    redefinition .
  methods ZONIF_OC_DATA_HANDLER~GET_DATA
    redefinition .
protected section.
private section.

  data:
    mt_path TYPE STANDARD TABLE OF string . " WITH EMPTY KEY .
  data:
    mt_kdoc_guard TYPE HASHED TABLE OF string
                   WITH UNIQUE KEY table_line .
ENDCLASS.



CLASS ZONCL_OC_KDOC_HANDLER IMPLEMENTATION.


METHOD delete_data_body.

  " Local declarations
  DATA: lv_tabname        TYPE string,
        lv_field          TYPE string,
        lv_keys           TYPE string,
        lt_keys           TYPE tty_where,
        lv_keys_main      TYPE string,
        lv_keys_temp      TYPE string,
        lv_root           TYPE string,
        lv_lines          TYPE sy-tabix,
        lv_max_records    TYPE zonde_registrosn,
        lv_lenght         TYPE numc2,
        iv_message_v1     TYPE string,
        lt_relations      TYPE STANDARD TABLE OF zonta_relations,
        ls_relations      TYPE zonta_relations,
        ls_relations_last TYPE zonta_relations,
        lo_data           TYPE REF TO data,
        ls_datat          TYPE ty_datat,
        dref_table        TYPE REF TO data,
        lv_send           TYPE boolean,
        it_data           TYPE REF TO data.

  FIELD-SYMBOLS:
    <fs_wa>           TYPE any,
    <fs_table>        TYPE STANDARD TABLE,
    <fs_table1>       TYPE STANDARD TABLE,
    <fs_table2>       TYPE STANDARD TABLE,
    <fs_table_line>   TYPE any,
    <fs_data>         TYPE any,
    <fs_line_json>    TYPE any,
    <fs_field>        TYPE any,
    <fs_key>          TYPE any,
    <fs_key_main>     TYPE any,
    <fs_field_mandt>  TYPE any,
    <fs_line>         TYPE any,
    <fs_json>         LIKE LINE OF gt_json,
    <fs_result>       TYPE any,
    <fs_relations>    TYPE zonta_relations,
    <fs_cdpos>        TYPE ty_cdpos,
    <fs_columns>      TYPE zonta_oc_col_all,
    <fs_line_source>  TYPE any,
    <fs_value_source> TYPE any,
    <fs_value_target> TYPE any,
    <fs_keys_event>   TYPE LINE OF tty_where.

  IF NOT gt_cdpos IS INITIAL.

*--------------------------------------------------------------------*
* Logging based on caller
*--------------------------------------------------------------------*
    IF iv_parent_relation IS INITIAL.
*      CLEAR gv_recordst_obj.
      CLEAR gs_log_json_result-recordst_obj.

      CASE sy-xform.
        WHEN 'ZONFM_ONE_CONNECT_BATCH'.
          iv_message_v1 = '*** Batch Process KDOC***'.
        WHEN 'SWF_EVT_HANDLER_START_INTERNAL'.
          iv_message_v1 = '*** Event Process KDOC ***'.
        WHEN 'FM_BGMC_PROCESS'.
          iv_message_v1 = '*** Direct Process KDOC RAP BO***'.
        WHEN OTHERS.
          iv_message_v1 = '*** Direct Process KDOC***'.
      ENDCASE.

      me->append_slg1_log(
        iv_tabname    = space
        iv_message_v1 = iv_message_v1
        iv_mestyp     = 'S' ).
    ENDIF.

*--------------------------------------------------------------------*
* Prepare relations
*--------------------------------------------------------------------*
    lt_relations = gt_relations.
    SORT lt_relations BY sequence.
    DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING sequence.
    SORT lt_relations BY levelv.

    lv_lines = lines( lt_relations ).
    READ TABLE lt_relations INDEX lv_lines INTO ls_relations_last.

    IF iv_parent_relation IS INITIAL.
      READ TABLE lt_relations INDEX 1 INTO ls_relations.
      lv_tabname = ls_relations-tabname.
      CONCATENATE 'ZON' ls_relations-id 'SBODY' gv_messagetype INTO lv_root.
      CREATE DATA dref_table TYPE (lv_root).
      ASSIGN dref_table->* TO <fs_wa>.
    ELSE.
      lv_tabname = iv_parent_relation.
      ASSIGN cs_line_json TO <fs_wa>.
    ENDIF.

*--------------------------------------------------------------------*
* Loop through child relations
*--------------------------------------------------------------------*
    lv_send = abap_false.

    LOOP AT lt_relations ASSIGNING <fs_relations>
         WHERE parent_relation = iv_parent_relation.

      READ TABLE gt_datat INTO ls_datat
           WITH KEY tabname = <fs_relations>-tabname.
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.

      it_data = ls_datat-lo_table.

      CLEAR: lt_keys, lv_keys.

      me->get_key(
        EXPORTING
          iv_parent_relation = iv_parent_relation
          iv_tabname         = <fs_relations>-tabname
        IMPORTING
          et_keys            = lt_keys
          ev_key             = lv_keys
          ev_key_main        = lv_keys_main ).

*------------------------------------------------------------------*
* Prepare JSON node
*------------------------------------------------------------------*
      IF iv_parent_relation IS INITIAL.
        lv_tabname = 'DATA'.
      ELSE.
        CONCATENATE 'SEQ' <fs_relations>-sequence '-DATA' INTO lv_tabname.
      ENDIF.

      me->get_data_by_table_data(
        EXPORTING
          iv_parent_relation = iv_parent_relation
          iv_table           = <fs_relations>-tabname
        IMPORTING
          et_data            = lo_data ).

      IF lo_data IS BOUND.

        ASSIGN lo_data->* TO <fs_table>.
        ASSIGN it_data->* TO <fs_table2>.

        CLEAR <fs_table>.                "<<< FIX 1: avoid mixed tables

        LOOP AT <fs_table2> ASSIGNING <fs_data>.
          APPEND INITIAL LINE TO <fs_table> ASSIGNING <fs_table_line>.
          MOVE-CORRESPONDING <fs_data> TO <fs_table_line>.
        ENDLOOP.

        ASSIGN COMPONENT lv_tabname OF STRUCTURE <fs_wa> TO <fs_table1>.

*------------------------------------------------------------------*
* Fill TABLE component correctly
*------------------------------------------------------------------*
        IF iv_parent_relation IS INITIAL.
          lv_field = 'TABLE'.
        ELSE.
          CONCATENATE 'SEQ' <fs_relations>-sequence '-TABLE' INTO lv_field.
        ENDIF.

        ASSIGN COMPONENT lv_field OF STRUCTURE <fs_wa> TO <fs_field>.
        IF <fs_field> IS ASSIGNED.        "<<< FIX 2
          <fs_field> = <fs_relations>-tabname.
          TRANSLATE <fs_field> TO LOWER CASE.
        ENDIF.

        SORT <fs_table>.
        DELETE ADJACENT DUPLICATES FROM <fs_table>.

*------------------------------------------------------------------*
* Build delete rows from CDPOS
*------------------------------------------------------------------*
        me->get_lenght_key(
          EXPORTING
            iv_tabname = <fs_relations>-tabname
            iv_parent  = iv_parent_relation
          RECEIVING
            rv_lenght  = lv_lenght ).

        LOOP AT gt_cdpos ASSIGNING <fs_cdpos>
             WHERE tabname = <fs_relations>-tabname.

          CREATE DATA dref_table TYPE (<fs_relations>-tabname).
          ASSIGN dref_table->* TO <fs_line_source>.

          APPEND INITIAL LINE TO <fs_table1> ASSIGNING <fs_line_json>.

          LOOP AT gt_columns_all ASSIGNING <fs_columns>
               WHERE tabname = <fs_relations>-tabname.

            ASSIGN COMPONENT <fs_columns>-fldname
              OF STRUCTURE <fs_line_source> TO <fs_value_source>.

            <fs_line_source> = <fs_cdpos>-tabkey(lv_lenght).

            ASSIGN COMPONENT <fs_columns>-fldname
              OF STRUCTURE <fs_line_json> TO <fs_value_target>.

            IF <fs_value_target> IS ASSIGNED
               AND <fs_value_source> IS ASSIGNED.
              <fs_value_target> = <fs_value_source>.
            ENDIF.
          ENDLOOP.

          ASSIGN COMPONENT 1 OF STRUCTURE <fs_line_json> TO <fs_field_mandt>.
          IF <fs_field_mandt> IS ASSIGNED.
            <fs_field_mandt> = sy-mandt.
          ENDIF.

*------------------------------------------------------------------*
* EventID handling
*------------------------------------------------------------------*
          CLEAR lt_keys.                 "<<< FIX 3

          IF gs_oc_obj-eventid = abap_true
          OR gs_oc_obj-metadata = abap_true.

            ASSIGN COMPONENT lv_keys_main
              OF STRUCTURE <fs_line_json> TO <fs_key>.

            IF <fs_key> IS ASSIGNED.
              APPEND INITIAL LINE TO lt_keys ASSIGNING <fs_keys_event>.
              <fs_keys_event>-line = <fs_key>.
            ENDIF.

            me->get_eventid(
              EXPORTING it_keys      = lt_keys
              CHANGING  cs_line_json = <fs_line_json> ).
          ENDIF.

*------------------------------------------------------------------*
* Recursive delete
*------------------------------------------------------------------*
          IF ls_relations_last-levelv NE <fs_relations>-levelv.
            me->delete_data_body(
              EXPORTING
                iv_parent_relation = <fs_relations>-tabname
                is_line            = <fs_line_json>
              CHANGING
                cs_line_json       = <fs_line_json> ).
          ENDIF.

*------------------------------------------------------------------*
* Flush JSON
*------------------------------------------------------------------*
          IF iv_parent_relation IS INITIAL
             AND lv_max_records = gs_oc_obj-no_registros.

            ASSIGN COMPONENT 'ONECONNECT-BODY'
              OF STRUCTURE cs_root TO <fs_result>.
            <fs_result> = <fs_wa>.

            gv_jsonid = gv_jsonid + 1.
            APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
            <fs_json>-json_id = gv_jsonid.
            <fs_json>-json = zoncl_ui2_cl_json=>serialize(
              data             = cs_root
              compress         = abap_false
              assoc_arrays     = abap_true
              assoc_arrays_opt = abap_true
              pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).

            CLEAR lv_max_records.
            lv_send = abap_true.
          ENDIF.

        ENDLOOP.
      ENDIF.
    ENDLOOP.

*--------------------------------------------------------------------*
* Final flush
*--------------------------------------------------------------------*
    IF iv_parent_relation IS INITIAL
       AND lv_send = abap_false.

      ASSIGN COMPONENT 'ONECONNECT-BODY'
        OF STRUCTURE cs_root TO <fs_result>.
      <fs_result> = <fs_wa>.

      gv_jsonid = gv_jsonid + 1.
      APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
      <fs_json>-json_id = gv_jsonid.
      <fs_json>-json = zoncl_ui2_cl_json=>serialize(
        data             = cs_root
        compress         = abap_false
        assoc_arrays     = abap_true
        assoc_arrays_opt = abap_true
        pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).
    ENDIF.

  ENDIF.

ENDMETHOD.


**  METHOD delete_data_body.
**
**    " Local declarations
**    DATA: lv_tabname        TYPE string,
**          lv_field          TYPE string,
**          lv_keys           TYPE string,
**          lt_keys           TYPE tty_where,
**          lv_keys_main      TYPE string,
**          lv_keys_temp      TYPE string,
**          lv_root           TYPE string,
**          lv_lines          TYPE sy-tabix,
**          lv_max_records    TYPE zonde_registrosn,
**          lv_lenght         TYPE numc2,
**          iv_message_v1     TYPE string,
**          lt_relations      TYPE STANDARD TABLE OF zonta_relations,
**          ls_relations      TYPE zonta_relations,
**          ls_relations_last TYPE zonta_relations,
**          lo_data           TYPE REF TO data,
**          ls_datat          TYPE ty_datat,
**          dref_table        TYPE REF TO data,
**          lv_send           TYPE boolean,
**          it_data           TYPE REF TO data.
**
**
**    FIELD-SYMBOLS: <fs_wa>           TYPE any,
**                   <fs_table>        TYPE STANDARD TABLE,
**                   <fs_table1>       TYPE STANDARD TABLE,
**                   <fs_table2>       TYPE STANDARD TABLE,
**                   <fs_table_line>   TYPE any,
**                   <fs_data>         TYPE any,
**                   <fs_line_json>    TYPE any,
**                   <fs_field>        TYPE any,
**                   <fs_key>          TYPE any,
**                   <fs_key_main>     TYPE any,
**                   <fs_field_mandt>  TYPE any,
**                   <fs_line>         TYPE any,
**                   <fs_json>         like line of gt_json, "TYPE any,
**                   <fs_result>       TYPE any,
**                   <fs_relations>    TYPE zonta_relations,
**                   <fs_cdpos>        TYPE ty_cdpos,
**                   <fs_columns>      TYPE zonta_oc_col_all,
**                   <fs_line_source>  TYPE any,
**                   <fs_value_source> TYPE any,
**                   <fs_value_target> TYPE any,
**                   <fs_keys_event>   TYPE LINE OF tty_where.
**
**
**    IF NOT gt_cdpos IS INITIAL.
**
**      " Logging based on caller
**      IF iv_parent_relation IS INITIAL.
**        CLEAR gv_recordst_obj.
**
**        CASE sy-xform.
**          WHEN 'ZONFM_ONE_CONNECT_BATCH'.
**            iv_message_v1 = '*** Batch Process KDOC***'.
**          WHEN 'SWF_EVT_HANDLER_START_INTERNAL'.
**            iv_message_v1 = '*** Event Process KDOC ***'.
**          WHEN 'FM_BGMC_PROCESS'.
**            iv_message_v1 = '*** Direct Process KDOC RAP BO***'.
**          WHEN OTHERS.
**            iv_message_v1 = '*** Direct Process KDOC***'.
**        ENDCASE.
**
**        me->append_slg1_log(
**          EXPORTING
**            iv_tabname     = space
**            iv_message_v1  = iv_message_v1
**            iv_mestyp      = 'S' ).
**      ENDIF.
**
**      " Prepare relations
**      lt_relations = gt_relations.
**      SORT lt_relations BY sequence.
**      DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING sequence.
**      SORT lt_relations BY levelv.
**      lv_lines = lines( lt_relations ).
**      READ TABLE lt_relations INDEX lv_lines INTO ls_relations_last.
**
**      IF iv_parent_relation IS INITIAL.
**        READ TABLE lt_relations INDEX 1 INTO ls_relations.
**        lv_tabname = ls_relations-tabname.
**        CONCATENATE 'ZON' ls_relations-id 'SBODY' gv_messagetype INTO lv_root.
**        CREATE DATA dref_table TYPE (lv_root).
**        ASSIGN dref_table->* TO <fs_wa>.
**      ELSE.
**        lv_tabname = iv_parent_relation.
**        ASSIGN cs_line_json TO <fs_wa>.
**      ENDIF.
**
**      " Loop through child relations
**      lv_send = abap_false.
**      LOOP AT lt_relations ASSIGNING <fs_relations>
**           WHERE parent_relation = iv_parent_relation.
**
**        READ TABLE gt_datat INTO ls_datat WITH KEY tabname = <fs_relations>-tabname.
**        IF sy-subrc = 0.
**          it_data = ls_datat-lo_table.
**        ELSE.
**          RETURN.
**        ENDIF.
**
**        CLEAR: lt_keys, lv_keys.
**
**        me->get_key(
**          EXPORTING
**            iv_parent_relation = iv_parent_relation
**            iv_tabname         = <fs_relations>-tabname
**          IMPORTING
**            et_keys            = lt_keys
**            ev_key             = lv_keys
**            ev_key_main        = lv_keys_main ).
**
**        IF iv_parent_relation IS INITIAL.
**          lv_tabname = 'DATA'.
**        ELSE.
**          CONCATENATE 'SEQ' <fs_relations>-sequence '-DATA' INTO lv_tabname.
**        ENDIF.
**
**        me->get_data_by_table_data(
**          EXPORTING
**            iv_parent_relation = iv_parent_relation
**            iv_table           = <fs_relations>-tabname
**          IMPORTING
**            et_data            = lo_data ).
**
**        IF lo_data IS BOUND.
**          ASSIGN lo_data->* TO <fs_table>.
**          ASSIGN it_data->* TO <fs_table2>.
**
**          LOOP AT <fs_table2> ASSIGNING <fs_data>.
**            APPEND INITIAL LINE TO <fs_table> ASSIGNING <fs_table_line>.
**            MOVE-CORRESPONDING <fs_data> TO <fs_table_line>.
**          ENDLOOP.
**
**          ASSIGN COMPONENT lv_tabname OF STRUCTURE <fs_wa> TO <fs_table1>.
**
**          IF iv_parent_relation IS INITIAL.
**            lv_field = 'TABLE'.
**          ELSE.
**            CONCATENATE 'SEQ' <fs_relations>-sequence '-TABLE' INTO lv_field.
**          ENDIF.
**
**          ASSIGN COMPONENT lv_field OF STRUCTURE <fs_wa> TO <fs_field>.
**          CONCATENATE 'SEQ' <fs_relations>-sequence INTO <fs_field>.
**          TRANSLATE <fs_field> TO LOWER CASE.
**
**          SORT <fs_table>.
**          DELETE ADJACENT DUPLICATES FROM <fs_table>.
**
**          me->get_lenght_key(
**            EXPORTING
**              iv_tabname = <fs_relations>-tabname
**              iv_parent  = iv_parent_relation
**            RECEIVING
**              rv_lenght  = lv_lenght ).
**
**          LOOP AT gt_cdpos ASSIGNING <fs_cdpos>
**               WHERE tabname = <fs_relations>-tabname.
**
**            CREATE DATA dref_table TYPE (<fs_relations>-tabname).
**            ASSIGN dref_table->* TO <fs_line_source>.
**            APPEND INITIAL LINE TO <fs_table1> ASSIGNING <fs_line_json>.
**
**            LOOP AT gt_columns_all ASSIGNING <fs_columns>
**                 WHERE tabname = <fs_relations>-tabname.
**
**              ASSIGN COMPONENT <fs_columns>-fldname OF STRUCTURE <fs_line_source> TO <fs_value_source>.
**              <fs_line_source> = <fs_cdpos>-tabkey(lv_lenght).
**
***            IF <fs_columns>-alias_fldname IS NOT INITIAL.
***              TRANSLATE <fs_columns>-alias_fldname TO UPPER CASE.
***              ASSIGN COMPONENT <fs_columns>-alias_fldname OF STRUCTURE <fs_line_json> TO <fs_value_target>.
***            ELSE.
**              ASSIGN COMPONENT <fs_columns>-fldname OF STRUCTURE <fs_line_json> TO <fs_value_target>.
***            ENDIF.
**
**              IF <fs_value_target> IS ASSIGNED AND <fs_value_source> IS ASSIGNED.
**                <fs_value_target> = <fs_value_source>.
**              ENDIF.
**            ENDLOOP.
**
**            ASSIGN COMPONENT 1 OF STRUCTURE <fs_line_json> TO <fs_field_mandt>.
**            IF <fs_field_mandt> IS ASSIGNED.
**              <fs_field_mandt> = sy-mandt.
**            ENDIF.
**
**            IF iv_parent_relation IS INITIAL.
**              gv_recordst_obj = gv_recordst_obj + 1.
**              ASSIGN COMPONENT 2 OF STRUCTURE <fs_line_json> TO <fs_key>.
**              IF <fs_key> IS ASSIGNED.
**                me->append_slg1_log(
**                  iv_message_v1  = 'Deletion object'
**                  iv_mestyp      = 'S'
**                  iv_tabname     = <fs_relations>-tabname
**                  iv_key     = <fs_key> ).
**              ENDIF.
**
**              ASSIGN COMPONENT lv_keys_main OF STRUCTURE <fs_line_json> TO <fs_key_main>.
**              IF lv_keys_temp NE <fs_key_main>.
**                lv_keys_temp = <fs_key_main>.
**                lv_max_records = lv_max_records + 1.
**              ENDIF.
**            ENDIF.
**
**            IF gs_oc_obj-eventid = abap_true OR gs_oc_obj-metadata = abap_true.
**              IF <fs_key> IS ASSIGNED.
**                APPEND INITIAL LINE TO lt_keys ASSIGNING <fs_keys_event>.
**                <fs_keys_event>-line = <fs_key>.
**              ENDIF.
**              me->get_eventid(
**                EXPORTING it_keys = lt_keys
**                CHANGING  cs_line_json = <fs_line_json> ).
**            ENDIF.
**
**            IF ls_relations_last-levelv NE <fs_relations>-levelv.
**              me->delete_data_body(
**                EXPORTING
**                  iv_parent_relation = <fs_relations>-tabname
***                  it_data            = it_data
**                  is_line            = <fs_line_json>
**                CHANGING
**                  cs_line_json       = <fs_line_json> ).
**            ENDIF.
**
**            UNASSIGN <fs_key>.
**
**            IF iv_parent_relation IS INITIAL AND lv_max_records = gs_oc_obj-no_registros.
**              ASSIGN COMPONENT 'ONECONNECT-BODY' OF STRUCTURE cs_root TO <fs_result>.
**              <fs_result> = <fs_wa>.
**
**              gv_jsonid = gv_jsonid + 1.
**              APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
**              <fs_json>-json_id = gv_jsonid.
**              <fs_json>-json = zoncl_ui2_cl_json=>serialize(
**                data             = cs_root
**                compress         = abap_false
**                assoc_arrays     = abap_true
**                assoc_arrays_opt = abap_true
**                pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).
**
**              ASSIGN COMPONENT 'ONECONNECT-BODY-DATA' OF STRUCTURE cs_root TO <fs_result>.
**              CLEAR <fs_result>.
**
**              ASSIGN COMPONENT 'DATA' OF STRUCTURE <fs_wa> TO <fs_result>.
**              CLEAR <fs_result>.
**
**              CLEAR lv_max_records.
**              lv_send = abap_true.
**            ENDIF.
**
**          ENDLOOP.
**        ENDIF.
**      ENDLOOP.
**
**      IF iv_parent_relation IS INITIAL AND lv_max_records < gs_oc_obj-no_registros AND lv_send = abap_false.
**        ASSIGN COMPONENT 'ONECONNECT-BODY' OF STRUCTURE cs_root TO <fs_result>.
**        <fs_result> = <fs_wa>.
**
**        gv_jsonid = gv_jsonid + 1.
**        APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
**        <fs_json>-json_id = gv_jsonid.
**        <fs_json>-json = zoncl_ui2_cl_json=>serialize(
**          data             = cs_root
**          compress         = abap_false
**          assoc_arrays     = abap_true
**          assoc_arrays_opt = abap_true
**          pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).
**      ENDIF.
**
**    ENDIF.
**
**  ENDMETHOD.


  METHOD get_data.

    DATA: lo_table          TYPE REF TO data,
          ls_datat          LIKE LINE OF gt_datat,
          lv_exit           TYPE abap_bool,
          lv_exit_set_where TYPE abap_bool,
          lv_message_v2     TYPE string,
          lv_id             TYPE char50.

    FIELD-SYMBOLS: <fs_table> TYPE ANY TABLE.


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
* Variant
    ELSEIF gv_key_queue IS INITIAL AND gt_where_cond_tab IS NOT INITIAL AND gv_variant IS NOT INITIAL.
      gt_cond_tab = gt_where_cond_tab.
      me->set_where( IMPORTING ev_closed = lv_exit_set_where ).
      IF lv_exit_set_where EQ abap_true.
        RETURN.
      ENDIF.
      me->set_process( IMPORTING ev_closed = lv_exit ).
      IF lv_exit EQ abap_true.
        RETURN.
      ENDIF.

    ELSEIF gt_where_cond_tab IS NOT INITIAL.
      gt_cond_tab = gt_where_cond_tab.
    ENDIF.

    IF gt_where_cond_tab IS INITIAL.
      MESSAGE i000(fb) WITH 'No filter selected'.
      RETURN.
    ENDIF.

    IF gv_back_2_process = abap_true.
      CONCATENATE '2PC' gv_entity INTO lv_id.
      EXPORT gt_cond_tab = gt_cond_tab TO MEMORY ID lv_id.
      CONCATENATE '2PW' gv_entity INTO lv_id.
      EXPORT gt_where_cond_tab = gt_where_cond_tab TO MEMORY ID lv_id.
      CONCATENATE '2PJP' gv_entity INTO lv_id.
      EXPORT gv_json_prev = gv_json_prev TO MEMORY ID lv_id.
    ENDIF.

    " 2. Determine data or batch mode
    IF gv_batch IS INITIAL.

      " 2a. Load database records (only if update/delete)
      IF gv_update = abap_true OR gv_delete = abap_true.
*        lo_table = me->get_database_data( ).
*        ASSIGN lo_table->* TO <fs_table>.
*        IF <fs_table> IS INITIAL.
*        me->get_database_datat( ).
         me->GET_DATABASE_DATAT_OPEN( ).
*        IF me->gt_datat[] IS INITIAL.
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
          RETURN.
        ENDIF.
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
*        gv_recordst_obj = lines( <fs_table> ).
        gs_log_json_result-recordst_obj = lines( <fs_table> ).
      ENDIF.

      me->get_data_kdoc(  ) ."EXPORTING   it_data = <fs_table> )  .

    ELSE.
      " 2c. Execute batch logic
      me->execute_batch( ).
    ENDIF.


  ENDMETHOD.


METHOD get_data_body.


  CONSTANTS lc_comilla TYPE c LENGTH 1 VALUE ''''.

  DATA:
    lv_tabname       TYPE string,
    lv_tabname_table TYPE string, "used to fill sibling -TABLE component
    lv_root          TYPE string,
    lv_keys          TYPE string,
    lv_keys_main     TYPE string,
    lv_lines         TYPE sy-tabix,
    lo_data          TYPE REF TO data,
    lt_columns       TYPE STANDARD TABLE OF zonta_oc_col_all,
    ls_datat         TYPE ty_datat,
    it_data          TYPE REF TO data,
    lv_message_v1    TYPE string,
    lv_guard_key     TYPE string.

  FIELD-SYMBOLS:
    <fs_wa>          TYPE any,
    <fs_table>       TYPE STANDARD TABLE,
    <fs_table2>      TYPE STANDARD TABLE,
    <fs_table1>      TYPE STANDARD TABLE,
    <fs_table_name>  TYPE any,          "for component TABLE (string)
    <fs_relations>   TYPE zonta_relations,
    <fs_line>        TYPE any,
    <fs_line_json>   TYPE any,
    <fs_data>        TYPE any,
    <fs_table_line>  TYPE any,
    <fs_key_main>    TYPE any,
    <fs_result>      TYPE any,
    <fs_json>        LIKE LINE OF gt_json,
    <fs_field_mandt> TYPE any.

  DATA:
    lt_relations      TYPE STANDARD TABLE OF zonta_relations,
    ls_relations      TYPE zonta_relations,
    ls_relations_last TYPE zonta_relations,
    lt_keys           TYPE tty_where.

***
  FIELD-SYMBOLS: <fs_key_evt> LIKE LINE OF lt_keys.
***

*--------------------------------------------------------------------*
* Recursion guard (relation + business key)
*--------------------------------------------------------------------*
  IF iv_parent_relation IS NOT INITIAL AND is_line IS NOT INITIAL.

    ASSIGN COMPONENT lv_keys_main OF STRUCTURE is_line TO <fs_key_main>.
    IF <fs_key_main> IS ASSIGNED AND <fs_key_main> IS NOT INITIAL.

      CONCATENATE iv_parent_relation <fs_key_main>
        INTO lv_guard_key SEPARATED BY '|'.

      READ TABLE mt_kdoc_guard
        WITH TABLE KEY table_line = lv_guard_key
        TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        RETURN.
      ENDIF.

      INSERT lv_guard_key INTO TABLE mt_kdoc_guard.
    ENDIF.
  ENDIF.

*--------------------------------------------------------------------*
* Root handling
*--------------------------------------------------------------------*
  IF iv_parent_relation IS INITIAL.

*    CLEAR gv_recordst_obj.
    CLEAR gs_log_json_result-recordst_obj.

    CASE sy-xform.
      WHEN 'ZONFM_ONE_CONNECT_BATCH'.
        lv_message_v1 = '*** Batch Process KDOC***'.
      WHEN 'SWF_EVT_HANDLER_START_INTERNAL'.
        lv_message_v1 = '*** Event Process KDOC ***'.
      WHEN 'FM_BGMC_PROCESS'.
        lv_message_v1 = '*** Direct Process KDOC RAP BO***'.
      WHEN OTHERS.
        lv_message_v1 = '*** Direct Process KDOC***'.
    ENDCASE.

    me->append_slg1_log(
      iv_tabname    = space
      iv_message_v1 = lv_message_v1
      iv_mestyp     = 'S' ).
  ENDIF.

*--------------------------------------------------------------------*
* Prepare relations
*--------------------------------------------------------------------*
  lt_relations = gt_relations.
  SORT lt_relations BY sequence.
  DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING sequence.
  SORT lt_relations BY levelv.

  lv_lines = lines( lt_relations ).
  READ TABLE lt_relations INDEX lv_lines INTO ls_relations_last.

  IF iv_parent_relation IS INITIAL.
    READ TABLE lt_relations INDEX 1 INTO ls_relations.
    lv_root = 'ZON' && ls_relations-id && 'SBODY' && gv_messagetype.
    CREATE DATA lo_data TYPE (lv_root).
    ASSIGN lo_data->* TO <fs_wa>.
  ELSE.
    ASSIGN cs_line_json TO <fs_wa>.
  ENDIF.

*--------------------------------------------------------------------*
* Traverse relations
*--------------------------------------------------------------------*
  LOOP AT lt_relations ASSIGNING <fs_relations>
       WHERE parent_relation = iv_parent_relation.

*------------------------------------------------------------------*
* Build key filter (ONCE per parent row)
*------------------------------------------------------------------*
    CLEAR: lv_keys, lv_keys_main, lt_keys.

    me->get_key_kdoc(
      EXPORTING
        iv_parent_relation = iv_parent_relation
        iv_tabname         = <fs_relations>-tabname
        is_line            = is_line
      IMPORTING
        et_keys            = lt_keys
        ev_key             = lv_keys
        ev_key_main        = lv_keys_main ).

*------------------------------------------------------------------*
* Get child data
*------------------------------------------------------------------*
    me->get_data_by_table_data(
      EXPORTING
        iv_parent_relation = iv_parent_relation
        iv_table           = <fs_relations>-tabname
      IMPORTING
        et_data            = lo_data ).

    IF lo_data IS INITIAL.
      CONTINUE.
    ENDIF.

    ASSIGN lo_data->* TO <fs_table>.

    READ TABLE gt_datat INTO ls_datat
         WITH KEY tabname = <fs_relations>-tabname.
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    it_data = ls_datat-lo_table.
    IF it_data IS NOT INITIAL.
      ASSIGN it_data->* TO <fs_table2>.
    ELSE.
      CONTINUE. "no child data → skip safely
    ENDIF.

*------------------------------------------------------------------*
* Prepare JSON target
*------------------------------------------------------------------*
    IF iv_parent_relation IS INITIAL.
      lv_tabname = 'DATA'.
    ELSE.
      lv_tabname = 'SEQ' && <fs_relations>-sequence && '-DATA'.
    ENDIF.

    ASSIGN COMPONENT lv_tabname OF STRUCTURE <fs_wa> TO <fs_table1>.
    IF <fs_table1> IS NOT ASSIGNED.
      CONTINUE.
    ENDIF.

    lv_tabname_table = lv_tabname.
    REPLACE FIRST OCCURRENCE OF '-DATA' IN lv_tabname_table WITH '-TABLE'.
    IF lv_tabname_table = lv_tabname. "root case: DATA -> TABLE
      REPLACE FIRST OCCURRENCE OF 'DATA' IN lv_tabname_table WITH 'TABLE'.
    ENDIF.

    ASSIGN COMPONENT lv_tabname_table OF STRUCTURE <fs_wa> TO <fs_table_name>.
    IF <fs_table_name> IS ASSIGNED AND <fs_table_name> IS INITIAL.
      <fs_table_name> = <fs_relations>-tabname.
    ENDIF.

*------------------------------------------------------------------*
* Build filtered rows
*------------------------------------------------------------------*
    lt_columns = gt_columns_all.
    DELETE lt_columns WHERE tabname <> <fs_relations>-tabname.
*    IF  gv_recordst_obj IS INITIAL.
    IF gs_log_json_result-recordst_obj IS INITIAL.
      IF <fs_table2>  IS ASSIGNED.
*        gv_recordst_obj = lines( <fs_table2> ).
        gs_log_json_result-recordst_obj = lines( <fs_table2> ).
      ENDIF.
    ENDIF.
    IF lv_keys IS INITIAL.
      LOOP AT <fs_table2> ASSIGNING <fs_data>.
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
    ELSE.
      LOOP AT <fs_table2> ASSIGNING <fs_data> WHERE (lv_keys).
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

*------------------------------------------------------------------*
* Recurse
*------------------------------------------------------------------*
    LOOP AT <fs_table> ASSIGNING <fs_line>.

      APPEND INITIAL LINE TO <fs_table1> ASSIGNING <fs_line_json>.
      MOVE-CORRESPONDING <fs_line> TO <fs_line_json>.

      me->conversion_exit(
        EXPORTING iv_tabname = <fs_relations>-tabname
        CHANGING  cs_string  = <fs_line_json> ).

      IF gs_oc_obj-eventid EQ abap_true OR gs_oc_obj-metadata EQ abap_true.
        CLEAR lt_keys.

        IF lv_keys_main IS NOT INITIAL.
*          APPEND INITIAL LINE TO lt_keys ASSIGNING FIELD-SYMBOL(<fs_key_evt>).
          APPEND INITIAL LINE TO lt_keys ASSIGNING <fs_key_evt>.
          <fs_key_evt>-line = lv_keys_main.
        ENDIF.

        me->get_eventid(
          EXPORTING it_keys      = lt_keys
          CHANGING  cs_line_json = <fs_line_json> ).
      ENDIF.

      ASSIGN COMPONENT 1 OF STRUCTURE <fs_line_json> TO <fs_field_mandt>.
      IF <fs_field_mandt> IS ASSIGNED.
        <fs_field_mandt> = sy-mandt.
      ENDIF.

      IF ls_relations_last-levelv <> <fs_relations>-levelv.
        me->get_data_body(
          EXPORTING
            iv_parent_relation = <fs_relations>-tabname
            is_line            = <fs_line>
          CHANGING
            cs_line_json       = <fs_line_json> ).
      ENDIF.

    ENDLOOP.

  ENDLOOP.

*--------------------------------------------------------------------*
* Final JSON flush
*--------------------------------------------------------------------*
  IF iv_parent_relation IS INITIAL.
    ASSIGN COMPONENT 'ONECONNECT-BODY' OF STRUCTURE cs_root TO <fs_result>.
    <fs_result> = <fs_wa>.

    gv_jsonid = gv_jsonid + 1.
    APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
    <fs_json>-json_id = gv_jsonid.
    <fs_json>-json = zoncl_ui2_cl_json=>serialize(
      data             = cs_root
      compress         = abap_false
      assoc_arrays     = abap_true
      assoc_arrays_opt = abap_true
      pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).
  ENDIF.

*--------------------------------------------------------------------*
* Cleanup recursion guard
*--------------------------------------------------------------------*
  IF lv_guard_key IS NOT INITIAL.
    DELETE mt_kdoc_guard WHERE table_line = lv_guard_key.
  ENDIF.

ENDMETHOD.


  METHOD get_data_kdoc.


    DATA: dref_table      TYPE REF TO data,
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

    FIELD-SYMBOLS:
      <fs_root>       TYPE any,
      <fs_oneconnect> TYPE any,
      <fs_properties> TYPE any,
      <fs_metadata>   TYPE any,
      <fs_body>       TYPE any.

    " Reset JSON content
    CLEAR gt_json.
    CHECK lines( gt_datat ) > 0.

    " Identify DDIC structure name for root
    READ TABLE gt_relations INDEX 1 INTO ls_relations.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    lv_root = |ZON{ ls_relations-id }SCONNECT{ c_kdoc }|.

    " Create structure for root container
    CREATE DATA dref_table TYPE (lv_root).
    ASSIGN dref_table->* TO <fs_root>.
    IF <fs_root> IS ASSIGNED.

      ASSIGN COMPONENT 'ONECONNECT' OF STRUCTURE <fs_root> TO <fs_oneconnect>.
      IF <fs_oneconnect> IS ASSIGNED.

        " PROPERTIES
        ASSIGN COMPONENT 'PROPERTIES' OF STRUCTURE <fs_oneconnect> TO <fs_properties>.
        IF <fs_properties> IS ASSIGNED.
          me->get_data_properties( CHANGING cs_properties = <fs_properties> ).
        ENDIF.

        " METADATA
        ASSIGN COMPONENT 'METADATA' OF STRUCTURE <fs_oneconnect> TO <fs_metadata>.
        IF <fs_metadata> IS ASSIGNED.
          me->get_data_metadata( CHANGING cs_metadata = <fs_metadata> ).
        ENDIF.

        " BODY
        ASSIGN COMPONENT 'BODY' OF STRUCTURE <fs_oneconnect> TO <fs_body>.
        IF <fs_body> IS ASSIGNED.

          IF gv_delete = abap_true.
            me->delete_data_body(
              EXPORTING
                iv_parent_relation = space
*                it_data            = it_data
              CHANGING
                cs_body            = <fs_body>
                cs_root            = <fs_root>
            ).
          ELSE.
            me->get_data_body(
              EXPORTING
                iv_parent_relation = space
*                it_data            = it_data
              CHANGING
                cs_body            = <fs_body>
                cs_root            = <fs_root>
            ).
          ENDIF.

        ENDIF.
      ENDIF.
    ENDIF.

    " Loop over the JSON and send it
    LOOP AT gt_json INTO gs_json.

      gv_json = gs_json-json.
      gv_jsonid = gs_json-json_id.

      me->pretty_json(
        EXPORTING
          iv_mode = c_kdoc
        CHANGING
          cv_json = gv_json
      ).

      me->send_json_http_con(
        EXPORTING
          i_dest     = gv_dest
        IMPORTING
          e_return   = lv_return
          e_size     = e_size
          e_records  = e_records
          e_response = lv_response
      ).

*      gv_sizet    = e_size.
*      gv_recordst = gv_recordst + 1.

      gs_log_json_result-sizet    = e_size.
      gs_log_json_result-recordst = gs_log_json_result-recordst + 1.

    ENDLOOP.

    IF gv_send_immediately = abap_false.
      " Send result and finalize
      me->send_json_result( ).
      me->update_slg1_log( it_log_ext = gt_log_ext ).

*      CLEAR: gv_sizet, gv_recordst.
      CLEAR: gs_log_json_result-sizet, gs_log_json_result-recordst.

    ENDIF.

  ENDMETHOD.


  METHOD zonif_oc_data_handler~get_data.
  ENDMETHOD.
ENDCLASS.
