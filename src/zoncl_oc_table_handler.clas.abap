CLASS zoncl_oc_table_handler DEFINITION
  PUBLIC
  INHERITING FROM zoncl_oc_base_handler
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS get_data_tablet .

    METHODS get_data
        REDEFINITION .
    METHODS zonif_oc_data_handler~get_data
        REDEFINITION .
  PROTECTED SECTION.
private section.

  data GV_PROG type SYREPID .
  data GV_SLINE type I .
  data GV_MSG1 type STRING .
  data GV_MSG2 type STRING .
  data GV_MSG3 type STRING .
  data GV_MSG4 type STRING .
  data GV_MSG5 type STRING .

  methods DELETE_DATA_TABLE .
ENDCLASS.



CLASS ZONCL_OC_TABLE_HANDLER IMPLEMENTATION.


  METHOD delete_data_table.

    DATA: lv_tabname        TYPE string,
          lv_condense       TYPE string,
          lv_keys           TYPE string,
          lv_keys_main      TYPE string,
          lv_keys_temp      TYPE string,
          lv_root           TYPE string,
          lt_dfies_tab      TYPE STANDARD TABLE OF dfies,
          lt_fcat           TYPE lvc_t_fcat,
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
          lv_lenght         TYPE numc2,
          lv_tabnames       TYPE zonta_relations-tabname,
          lv_tabname_aux    TYPE dd27s-tabname,
          lv_pretty         TYPE string,
          lv_ddlname        TYPE zonde_ddlname, "CECHAVARRIA 31/07/2025
          lv_empty          TYPE string.

    FIELD-SYMBOLS:
      <fs_table>           TYPE STANDARD TABLE,
      <fs_body>            TYPE STANDARD TABLE,
      <fs_metadata_root>   TYPE STANDARD TABLE,
      <fs_relations>       TYPE zonta_relations,
      <fs_root>            TYPE any,
      <fs_oneconnect>      TYPE any,
      <fs_properties>      TYPE any,
      <fs_body_root>       TYPE any,
      <fs_json>            LIKE LINE OF gt_json, "TYPE any,
      <fs_metadata>        TYPE any,
      <fs_field_metadata>  TYPE any,
      <fs_metadata_line>   TYPE any,
      <fs_field>           TYPE any,
      <fs_cdpos>           TYPE ty_cdpos,
      <fs_key_main>        TYPE any,
      <fs_keys_event>      TYPE LINE OF tty_where,
      <fs_table_body_line> TYPE any,
      <fs_data>            TYPE any,
      <fs_columns>         TYPE zonta_oc_col_all,
      <fs_value_source>    TYPE any,
      <fs_value_target>    TYPE any,
      <fs_line_source>     TYPE any,
      <fs_key>             TYPE any,
      <fs_line>            TYPE any.

*DO.ENDDO.

    IF gt_cdpos IS INITIAL.
      RETURN.
    ENDIF.

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
        iv_mestyp     = 'S' ).

    IF gv_instid IS INITIAL.
      CLEAR gt_json.
    ENDIF.

    lt_relations = gt_relations.
    SORT lt_relations BY sequence.
    DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING sequence.
    SORT lt_relations BY levelv.
    lv_lines = lines( lt_relations ).
    READ TABLE lt_relations INDEX lv_lines INTO ls_relations_last.

    LOOP AT lt_relations ASSIGNING <fs_relations>.

      IF <fs_relations>-parent_relation IS INITIAL.
*        CLEAR gv_recordst_obj.
        CLEAR gs_log_json_result-recordst_obj.
      ENDIF.

      IF gs_oc_obj-data = abap_true.
        CREATE DATA dref_table_root TYPE ty_oneconnect_meta.
      ELSE.
        CREATE DATA dref_table_root TYPE ty_oneconnect.
      ENDIF.
      ASSIGN dref_table_root->* TO <fs_root>.
      ASSIGN COMPONENT 'ONECONNECT' OF STRUCTURE <fs_root> TO <fs_oneconnect>.
      ASSIGN COMPONENT 'PROPERTIES' OF STRUCTURE <fs_oneconnect> TO <fs_properties>.

      IF gv_update = abap_true.
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
      ASSIGN COMPONENT 'DATA' OF STRUCTURE <fs_body_root> TO <fs_table_body_line>.
      me->get_data_by_table(
        EXPORTING iv_parent_relation = <fs_relations>-parent_relation
                  iv_table           = <fs_relations>-tabname
        IMPORTING et_fcat            = lt_fcat
                  et_data            = <fs_table_body_line> ).

      ASSIGN <fs_table_body_line>->* TO <fs_body>.

      me->get_key(
        EXPORTING iv_parent_relation = <fs_relations>-parent_relation
                  iv_tabname         = <fs_relations>-tabname
        IMPORTING et_keys            = lt_keys
                  ev_key             = lv_keys
                  ev_key_main        = lv_keys_main ).

      me->set_metadata_node(
        EXPORTING it_fcat     = lt_fcat
                  iv_tabname  = <fs_relations>-tabname
        CHANGING  cs_metadata = <fs_metadata_line> ).

      me->get_data_by_table(
        EXPORTING iv_parent_relation = <fs_relations>-parent_relation
                  iv_table           = <fs_relations>-tabname
        IMPORTING et_fcat            = lt_fcat
                  et_data            = lo_data ).

      ASSIGN lo_data->* TO <fs_line>.

      me->get_lenght_key(
        EXPORTING iv_tabname = <fs_relations>-tabname
                  iv_parent  = <fs_relations>-parent_relation
        RECEIVING rv_lenght  = lv_lenght ).

      lv_tabnames = <fs_relations>-tabname.
*      IF NOT line_exists( gt_cdpos[ tabname = lv_tabnames ] ).

      READ TABLE gt_cdpos TRANSPORTING NO FIELDS WITH KEY tabname = lv_tabnames.
      IF sy-subrc <> 0.
        DO.
          SELECT SINGLE dd27s~tabname
            INTO lv_tabname_aux
            FROM dd27s
            WHERE viewname = lv_tabnames.
          IF sy-subrc <> 0.
            EXIT.
          ENDIF.
          lv_tabnames = lv_tabname_aux.
        ENDDO.
*DO. ENDDO.
*BEGIN ECHAVARRIA 31/07/2025
        IF lv_tabname_aux IS INITIAL.

*         lv_ddlname = lv_tabnames.
*          DATA(lo_finder) = NEW cl_dd_ddl_field_tracker( iv_ddlname = lv_ddlname ).
*          TRY.
*              DATA(lt_field_infos) = lo_finder->get_base_field_information( ).
*            CATCH cx_dd_ddl_read INTO DATA(lo_ex).
*              gs_elog-type       = 'GET_FIELD_INFORMATION'.
*              gs_elog-severity   = gc_error.
*              gs_elog-message    = lo_ex->get_longtext( ).
*              CALL METHOD lo_ex->get_source_position
*                IMPORTING
*                  program_name = gv_prog
*                  source_line  = gv_sline.
*              gs_elog-details-query = |Error in { gv_prog } at line { gv_sline } |.
*              gs_elog-details-db = 'ZONCL_OC_TABLE_HANDLER-DELETE_DATA_TABLE'.
*              gs_elog-details-error_code = sy-msgid && sy-msgno && sy-msgty.
*
*
*              gs_elog-metadata-error_code = gs_elog-details-error_code.
*              interpret_message( EXPORTING iv_msgnr = '102' iv_msgv1 = lv_tabnames IMPORTING ev_message = gv_msg1 CHANGING ct_table = gt_causes ).
*              interpret_message( EXPORTING iv_msgnr = '103' iv_msgv1 = lv_tabnames  IMPORTING ev_message = gv_msg2 CHANGING ct_table = gt_causes ).
*              interpret_message( EXPORTING iv_msgnr = '104' IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_causes ).
*              CONCATENATE gv_msg1 gv_msg2 gv_msg3  INTO gs_elog-metadata-possible_cause SEPARATED BY cl_abap_char_utilities=>newline.
*              interpret_message( EXPORTING iv_msgnr = '105'  iv_msgv1 = lv_tabnames IMPORTING ev_message = gv_msg3 CHANGING ct_table = gt_fixes ).
*              interpret_message( EXPORTING iv_msgnr = '086'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_fixes ).
*              interpret_message( EXPORTING iv_msgnr = '087'  IMPORTING ev_message = gv_msg4 CHANGING ct_table = gt_fixes ).
*              CONCATENATE gv_msg1 gv_msg2 gv_msg3 INTO gs_elog-metadata-possible_fix SEPARATED BY cl_abap_char_utilities=>newline.
*              print_error_otel( ).
*              send_json_error( ).
*              CLEAR lv_ddlname.
*          ENDTRY.
*          READ TABLE gt_columns_all INTO DATA(ls_columns)
*                 WITH KEY tabname = lv_ddlname
*                          key_field = abap_true.
*          IF sy-subrc EQ 0.
*            READ TABLE lt_field_infos INTO DATA(ls_field_info)
*                 WITH KEY entity_name  = lv_ddlname
*                          element_name = ls_columns-fldname.
*            IF sy-subrc EQ 0.
*              lv_tabnames = ls_field_info-base_object.
*            ENDIF.
*          ENDIF.
        ENDIF.
*END ECHAVARRIA 31/07/2025
      ENDIF.
      LOOP AT gt_cdpos ASSIGNING <fs_cdpos> WHERE tabname = lv_tabnames.
        CREATE DATA dref_table TYPE (<fs_relations>-tabname).
        ASSIGN dref_table->* TO <fs_line_source>.
        IF lv_ddlname IS NOT INITIAL.
          <fs_line_source> = <fs_cdpos>-tabkey+3(lv_lenght).
        ELSE.
          <fs_line_source> = <fs_cdpos>-tabkey(lv_lenght).
        ENDIF.

        APPEND INITIAL LINE TO <fs_body> ASSIGNING <fs_table_body_line>.
        me->conversion_exit( EXPORTING iv_tabname = <fs_relations>-tabname
                             CHANGING  cs_string  = <fs_table_body_line> ).

        LOOP AT gt_columns_all ASSIGNING <fs_columns> WHERE tabname = <fs_relations>-tabname.
          ASSIGN COMPONENT <fs_columns>-fldname OF STRUCTURE <fs_line_source> TO <fs_value_source>.
          ASSIGN COMPONENT <fs_columns>-fldname OF STRUCTURE <fs_table_body_line> TO <fs_value_target>.
          <fs_value_target> = <fs_value_source>.
        ENDLOOP.

        UNASSIGN <fs_key_main>.
        ASSIGN COMPONENT lv_keys_main OF STRUCTURE <fs_table_body_line> TO <fs_key_main>.

        IF sy-subrc <> 0.
          IF lv_keys_temp <> lv_keys_main.
            lv_keys_temp = lv_keys_main.
            lv_max_records = lv_max_records + 1.
          ENDIF.
        ELSE.
          IF lv_keys_temp <> <fs_key_main>.
            lv_keys_temp = <fs_key_main>.
            lv_max_records = lv_max_records + 1.
          ENDIF.
        ENDIF.

        IF <fs_relations>-parent_relation IS INITIAL.
*          gv_recordst_obj = gv_recordst_obj + 1.
          gs_log_json_result-recordst_obj = gs_log_json_result-recordst_obj + 1.
          IF lv_ddlname IS NOT INITIAL.
            ASSIGN COMPONENT 1 OF STRUCTURE <fs_table_body_line> TO <fs_key>.
          ELSE.
            ASSIGN COMPONENT 2 OF STRUCTURE <fs_table_body_line> TO <fs_key>.
          ENDIF.

          IF <fs_key> IS ASSIGNED.
            me->append_slg1_log(
              iv_message_v1  = 'Deletion object'
              iv_tabname = <fs_relations>-tabname
              iv_mestyp  = 'S'
              iv_key     = <fs_key> ).
          ENDIF.
        ENDIF.

        IF gs_oc_obj-eventid = abap_true OR gs_oc_obj-metadata = abap_true.
          IF <fs_key> IS ASSIGNED.
            APPEND INITIAL LINE TO lt_keys ASSIGNING <fs_keys_event>.
            <fs_keys_event>-line = <fs_key>.
          ENDIF.
          me->get_eventid(
            EXPORTING it_keys      = lt_keys
            CHANGING  cs_line_json = <fs_table_body_line> ).
        ENDIF.

        ASSIGN COMPONENT 1 OF STRUCTURE <fs_table_body_line> TO <fs_field>.
        IF <fs_field> IS ASSIGNED.
          IF lv_ddlname IS INITIAL.
            <fs_field> = sy-mandt.
          ENDIF.
        ENDIF.

        IF lv_max_records = gs_oc_obj-no_registros.
          gv_jsonid = gv_jsonid + 1.
          APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
          <fs_json>-json_id = gv_jsonid.
          <fs_json>-json = zoncl_ui2_cl_json=>serialize(
            data             = <fs_root>
            compress         = abap_false
            assoc_arrays     = abap_true
            assoc_arrays_opt = abap_true
            pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).
          CLEAR: lv_max_records, <fs_body>.
        ENDIF.
      ENDLOOP.

      IF sy-subrc <> 0.
        lv_empty = abap_true.
      ENDIF.

      IF lv_max_records < gs_oc_obj-no_registros.
        gv_jsonid = gv_jsonid + 1.
        APPEND INITIAL LINE TO gt_json ASSIGNING <fs_json>.
        <fs_json>-json_id = gv_jsonid.
        <fs_json>-json = zoncl_ui2_cl_json=>serialize(
          data             = <fs_root>
          compress         = abap_false
          assoc_arrays     = abap_true
          assoc_arrays_opt = abap_true
          pretty_name      = zoncl_ui2_cl_json=>pretty_mode-low_case ).
      ENDIF.

      TRANSLATE lv_condense TO LOWER CASE.

      IF lv_empty = abap_true.
        lv_pretty = '"seq' && <fs_relations>-sequence && '":[]'.
        lv_empty  = '"seq' && <fs_relations>-sequence && '":[*]'.
        REPLACE lv_pretty WITH lv_empty INTO <fs_json>-json.
        IF sy-subrc <> 0.
          lv_pretty = '"data":[]'.
          lv_empty  = '"seq' && <fs_relations>-sequence && '":[*]'.
          REPLACE lv_pretty WITH lv_empty INTO <fs_json>-json.
        ENDIF.
        lv_empty = abap_false.
      ENDIF.

      UNASSIGN <fs_root>.
    ENDLOOP.

  ENDMETHOD.


  METHOD get_data.


    DATA: lo_table          TYPE REF TO data,
          ls_datat          LIKE LINE OF gt_datat,
          lv_exit           TYPE abap_bool,
          lv_exit_set_where TYPE abap_bool,
          lv_message_v2     TYPE string,
          lv_id             TYPE char50.

    FIELD-SYMBOLS: <fs_table> TYPE ANY TABLE.

    IF gv_back_2_process = abap_true.
      CONCATENATE '2PC' gv_entity INTO lv_id.
      IMPORT gt_cond_tab = gt_cond_tab FROM MEMORY ID lv_id.
      CONCATENATE '2PW' gv_entity INTO lv_id.
      IMPORT gt_where_cond_tab = gt_where_cond_tab FROM MEMORY ID lv_id.
      CONCATENATE '2PJP' gv_entity INTO lv_id.
      IMPORT gv_json_prev = gv_json_prev FROM MEMORY ID lv_id.
    ENDIF.

    SELECT SINGLE low
      INTO gv_send_immediately
      FROM zonta_oc_param
      WHERE name = 'SEND_IMM'.

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

* Send immediately json by json
    IF gv_send_immediately = abap_true.
      " 2. Determine data or batch mode
      IF gv_batch IS INITIAL.

        " 2a. Load database records (only if update/delete)
        IF gv_update = abap_true OR gv_delete = abap_true.
          me->get_database_datat_open_imm( ir_hdl = me ).
*          gv_recordst_obj = gv_recordst_obji.
          gs_log_json_result-recordst_obj = gv_recordst_obji.
          me->send_json_result( ).
          CLEAR gv_recordst_obji.
          me->update_slg1_log( it_log_ext = gt_log_ext ).
          CLEAR: gs_log_json_result-sizet, gs_log_json_result-recordst.
*          CLEAR gv_sizet.
*          CLEAR gv_recordst.
        ENDIF.

      ELSE.
        " 2c. Execute batch logic
        me->execute_batch( ).
      ENDIF.

    ELSE.

      " 2. Determine data or batch mode
      IF gv_batch IS INITIAL.

        " 2a. Load database records (only if update/delete)
        IF gv_update = abap_true OR gv_delete = abap_true.
          me->get_database_datat_open( ).
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
        me->get_data_tablet(  )  .
      ELSE.
        " 2c. Execute batch logic
        me->execute_batch( ).
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD get_data_tablet.
    DATA : dref_table  TYPE REF TO data,
           lv_root     TYPE string,
           e_size      TYPE zonde_oc_num30,
           e_records   TYPE zonde_oc_num30,
           lv_response TYPE string,
           lv_return   TYPE string,
           lv_where    TYPE tty_where,
           it_data     TYPE REF TO data,
           i_dest      TYPE rfcdest VALUE 'ONIBEX_KDOCS'.

    IF NOT gv_kdoc IS INITIAL.
      CLEAR gv_kdoc.
    ENDIF.

    IF gv_delete EQ abap_true.
      me->delete_data_table(  ).
    ELSE.
      IF gv_instid IS INITIAL.
        me->get_data_table( ).
      ELSE.
        me->get_data_table( ).
        me->delete_data_table(  ).
      ENDIF.
    ENDIF.

    LOOP AT gt_json INTO gs_json.
*      gv_dest = gv_primary.
      gv_json = gs_json-json.
      gv_jsonid = gs_json-json_id.
      me->pretty_json( EXPORTING iv_mode = c_table
                       CHANGING  cv_json = gv_json ).


      me->send_json_http_con(
        EXPORTING
          i_dest     = gv_dest
        IMPORTING
          e_return   = lv_return
          e_size     = e_size
          e_records  = e_records
          e_response = lv_response ).

*      gv_sizet    = gv_sizet + e_size.
*      gv_recordst = gv_recordst + 1.

      gs_log_json_result-sizet    = gs_log_json_result-sizet + e_size.
      gs_log_json_result-recordst = gs_log_json_result-recordst + 1.

    ENDLOOP.

    IF gv_send_immediately = abap_false.
      gv_response = lv_response.  "++DB Multiple endpoints
      me->send_json_result( ).

      me->update_slg1_log( it_log_ext = gt_log_ext ).

*      CLEAR gv_sizet.
*      CLEAR gv_recordst.
      CLEAR: gs_log_json_result-sizet, gs_log_json_result-recordst.
    ENDIF.
  ENDMETHOD.


  METHOD zonif_oc_data_handler~get_data.

  ENDMETHOD.
ENDCLASS.
