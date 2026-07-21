*----------------------------------------------------------------------*
***INCLUDE ZONPG_ONECONNECT_CUST_EXE_F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form init_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init_list .
  DATA: grid_layout     TYPE lvc_s_layo,
        grid_fcat       TYPE lvc_t_fcat,
        grid_disvariant TYPE disvariant.

  gv_new = abap_false.
  IF go_json IS INITIAL.
    CREATE OBJECT go_json.
  ENDIF.

  IF g_grid0100 IS INITIAL.

*   create custom container and grid
    IF g_container0100 IS INITIAL.
      CREATE OBJECT g_container0100
        EXPORTING
          container_name              = 'GRID_CONT0100'
        EXCEPTIONS
          cntl_error                  = 1
          cntl_system_error           = 2
          create_error                = 3
          lifetime_error              = 4
          lifetime_dynpro_dynpro_link = 5.
      IF sy-subrc NE 0.
**        message a911 with 'create object g_container0100'
*                          sy-dynnr space space.
      ENDIF.
    ENDIF.

    CREATE OBJECT g_grid0100
      EXPORTING
        i_parent = g_container0100.

    PERFORM prepare_grid_layout CHANGING grid_layout.
*
    PERFORM prepare_grid_fieldcat CHANGING grid_fcat.


    DATA l_repid TYPE sy-repid.
    l_repid = sy-repid.
    grid_disvariant-report = l_repid.
    grid_disvariant-username  = sy-uname.

    PERFORM get_current_data.

    g_grid0100->set_table_for_first_display(
      EXPORTING
        is_layout       = grid_layout
        i_save          = 'U'
        is_variant      = grid_disvariant
      CHANGING
        it_fieldcatalog = grid_fcat
        it_outtab       = gt_obj_oc[] ).

    PERFORM prepare_grid_events .

    g_grid0100->set_toolbar_interactive( ). " raises event toolbar
    cl_gui_control=>set_focus( EXPORTING control = g_grid0100 ).
  ELSE.

    PERFORM refresh_grid_display.

  ENDIF.

ENDFORM.                    "init_list
*&---------------------------------------------------------------------*
*& Form init_domain
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init_domain .

  TYPES: BEGIN OF st_vrm,
           key(40)  TYPE c,
           text(80) TYPE c,
         END OF st_vrm.

  DATA lt_domain TYPE STANDARD TABLE OF st_vrm.
  SELECT domainv AS key domainv  AS text
    INTO CORRESPONDING FIELDS OF TABLE lt_domain
     FROM zonta_domains
     WHERE spras = sy-langu.


  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = 'ZONTA_DOMAINS-DOMAINV'
      values          = lt_domain
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.
  IF sy-subrc NE 0.
* Implement suitable error handling here
  ENDIF.
*

ENDFORM.                    "init_domain
*&---------------------------------------------------------------------*
*&      Form  prepare_grid_layout
*&---------------------------------------------------------------------*
*      <--P_GRID_LAYOUT  layout structure of alv grid
*----------------------------------------------------------------------*
FORM prepare_grid_layout CHANGING p_layout TYPE lvc_s_layo.

  CLEAR p_layout.

  p_layout-cwidth_opt = co_true.
  p_layout-no_merging = 'X'.
  p_layout-smalltitle = co_true.
  p_layout-grid_title = 'One Connect Saved Domains/Business Processes'(t01).

ENDFORM.                    "prepare_grid_layout

*&---------------------------------------------------------------------*
*&      Form  prepare_grid_fieldcat
*&---------------------------------------------------------------------*
*      <--P_FCAT fieldcatalog
*----------------------------------------------------------------------*
FORM prepare_grid_fieldcat CHANGING p_fcat TYPE lvc_t_fcat.
*
  DATA: ls_fcat TYPE lvc_s_fcat.

  CLEAR p_fcat.

* Domain
  ls_fcat-ref_table = 'ZONTA_OBJ_OC'.
  ls_fcat-ref_field = 'DOMAINV'.
  ls_fcat-fieldname = 'DOMAINV'.
  ls_fcat-key       = 'X'.
  ls_fcat-coltext   = text-001.
  ls_fcat-seltext   = text-001.
  ls_fcat-rollname  = 'ZONDE_DOMAIN'.
  APPEND ls_fcat TO p_fcat.

* Type
  CLEAR ls_fcat.
  ls_fcat-ref_table = 'ZONTA_OBJ_OC'.
  ls_fcat-ref_field = 'TYPE'.
  ls_fcat-fieldname = 'TYPE'.
  ls_fcat-rollname  = 'ZONDE_TIPO'.
  ls_fcat-coltext   = text-002.
  ls_fcat-seltext   = text-002.
  APPEND ls_fcat TO p_fcat.

* Business Process
  CLEAR ls_fcat.
  ls_fcat-ref_table = 'ZONTA_OBJ_OC'.
  ls_fcat-ref_field = 'BUSINESS_PROC'.
  ls_fcat-fieldname = 'BUSINESS_PROC'.
  ls_fcat-coltext   = text-003.
  ls_fcat-seltext   = text-003.
  ls_fcat-rollname  = 'ZONDE_PROCESO'.
  APPEND ls_fcat TO p_fcat.

* Description
  CLEAR ls_fcat.
  ls_fcat-ref_table = 'ZONTA_OBJ_OC'.
  ls_fcat-ref_field = 'DESCRIPTION'.
  ls_fcat-fieldname = 'DESCRIPTION'.
  ls_fcat-rollname  = 'DESCRIPTION'.
  ls_fcat-coltext   = text-004.
  ls_fcat-seltext   = text-004.
  APPEND ls_fcat TO p_fcat.

* Created on
  CLEAR ls_fcat.
  ls_fcat-ref_table = 'ZONTA_OBJ_OC'.
  ls_fcat-ref_field = 'ERDAT'.
  ls_fcat-fieldname = 'ERDAT'.
  ls_fcat-rollname  = 'ERDAT'.
  ls_fcat-coltext   = text-005.
  ls_fcat-seltext   = text-005.
  APPEND ls_fcat TO p_fcat.

* Created by
  CLEAR ls_fcat.
  ls_fcat-ref_table = 'ZONTA_OBJ_OC'.
  ls_fcat-ref_field = 'ERNAM'.
  ls_fcat-fieldname = 'ERNAM'.
  ls_fcat-rollname  = 'SY-UNAME'.
  ls_fcat-coltext   = text-006.
  ls_fcat-seltext   = text-006.
  APPEND ls_fcat TO p_fcat.

* Upated on
  CLEAR ls_fcat.
  ls_fcat-ref_table = 'ZONTA_OBJ_OC'.
  ls_fcat-ref_field = 'UPDATED_ON'.
  ls_fcat-fieldname = 'UPDATED_ON'.
  ls_fcat-rollname  = 'SY-DATUM'.
  ls_fcat-coltext   = text-009.
  ls_fcat-seltext   = text-009.
  APPEND ls_fcat TO p_fcat.

* Upated by
  CLEAR ls_fcat.
  ls_fcat-ref_table = 'ZONTA_OBJ_OC'.
  ls_fcat-ref_field = 'UPDATED_BY'.
  ls_fcat-fieldname = 'UPDATED_BY'.
  ls_fcat-rollname  = 'SY-UNAME'.
  ls_fcat-coltext   = text-010.
  ls_fcat-seltext   = text-010.
  APPEND ls_fcat TO p_fcat.


ENDFORM.                    " prepare_grid_fieldcat
*&---------------------------------------------------------------------*
*&      Form  prepare_grid_events
*&---------------------------------------------------------------------*
FORM prepare_grid_events.

  CREATE OBJECT events0100.

  SET HANDLER: events0100->handle_user_command         FOR g_grid0100,
               events0100->handle_toolbar              FOR g_grid0100,
               events0100->handle_double_click         FOR g_grid0100,
               events0100->handle_context_menu_request FOR g_grid0100.

ENDFORM.                    " prepare_grid_events
*&---------------------------------------------------------------------*
*& Form get_current_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_current_data .

  CLEAR gt_obj_oc[].

  IF zonta_obj_oc-domainv IS INITIAL.
    SELECT *
      INTO TABLE gt_obj_oc
      FROM zonta_obj_oc.
  ELSE.
    SELECT *
      INTO TABLE gt_obj_oc
      FROM zonta_obj_oc
      WHERE domainv = zonta_obj_oc-domainv.
  ENDIF.

ENDFORM.                    "get_current_data


*&---------------------------------------------------------------------*
*&      Form  refresh_grid_display
*&---------------------------------------------------------------------*
FORM refresh_grid_display.

  DATA: l_stable  TYPE lvc_s_stbl,
        l_title   TYPE lvc_title,
        ls_layout TYPE lvc_s_layo.

  l_stable-row = co_true.
  l_stable-col = co_true.
  l_title      = 'List of Created Processes'(t02).

  g_grid0100->get_frontend_layout( IMPORTING es_layout = ls_layout ).
  ls_layout-cwidth_opt = co_true.
  g_grid0100->set_frontend_layout( EXPORTING is_layout = ls_layout ).

  g_grid0100->set_gridtitle( EXPORTING i_gridtitle = l_title ).



*BEGIN CECHAVARRIA 01/07/2025
  DATA v_tryoff TYPE c.
  SELECT SINGLE low INTO v_tryoff FROM zonta_oc_param WHERE name = 'SET_TRY_OFF'.
  IF v_tryoff IS NOT INITIAL.
    g_grid0100->refresh_table_display( EXPORTING is_stable = l_stable ).

    g_grid0100->refresh_table_display( EXPORTING i_soft_refresh = 'X'
                                                 is_stable      = l_stable ).
  ELSE.
    TRY. "CECHAVARRIA 01/07/2025
        g_grid0100->refresh_table_display( EXPORTING is_stable = l_stable ).
      CATCH cx_salv_method_not_supported.
        g_grid0100->refresh_table_display( EXPORTING i_soft_refresh = 'X'
                                                     is_stable      = l_stable ).
    ENDTRY.
  ENDIF.
*END CECHAVARRIA 01/07/2025

ENDFORM.                    " refresh_grid_display
*&---------------------------------------------------------------------*
*& Form update_columns_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_columns_alv .

  DATA: ls_row    LIKE LINE OF gt_selected_rows,
        ls_tables LIKE LINE OF gt_tables.

  " Get selected row
  lo_alv_tables->get_selected_rows(
    IMPORTING
      et_index_rows = gt_selected_rows
  ).

  " Retrieve the sales order number
  LOOP AT gt_selected_rows INTO ls_row.
    READ TABLE gt_tables INDEX ls_row-index INTO ls_tables.
  ENDLOOP.

  " Fetch and display columns data
  CLEAR gt_columns[].
  IF lines( gt_tables ) > 0.
    SELECT * FROM zonta_oc_col_all
      INTO TABLE gt_columns
      FOR ALL ENTRIES IN gt_tables
      WHERE tabname = gt_tables-tabname
        AND alias_tabname = gt_tables-alias_tabname.
  ENDIF.

  lo_alv_columns->set_table_for_first_display(
    EXPORTING
      i_structure_name = 'ZONTA_OC_COL_ALL'  "columns
    CHANGING
      it_outtab        = gt_columns
      it_fieldcatalog  = gt_fcat_columns
  ).


ENDFORM.                    "update_columns_alv
*&---------------------------------------------------------------------*
*& Form update_grid
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_grid USING p_grid TYPE REF TO cl_gui_alv_grid.
  DATA lv_stable TYPE lvc_s_stbl.

  CHECK p_grid IS BOUND.
*
  CLEAR lv_stable.
  MOVE abap_true TO:
    lv_stable-col,
    lv_stable-row.

  IF gv_option = co_display.
    CALL METHOD p_grid->set_ready_for_input
      EXPORTING
        i_ready_for_input = 0.
  ELSE.
    CALL METHOD p_grid->set_ready_for_input
      EXPORTING
        i_ready_for_input = 1.
  ENDIF.



  DATA: lt_callstack TYPE abap_callstack, " Table type for the call stack
        ls_callstack LIKE LINE OF lt_callstack.

  CALL FUNCTION 'SYSTEM_CALLSTACK'
    IMPORTING
      callstack = lt_callstack.
  READ TABLE lt_callstack INTO ls_callstack WITH KEY blockname = 'SAVE_DATA'.
  IF sy-subrc NE 0.
*BEGIN CECHAVARRIA 01/07/2025
    DATA v_tryoff TYPE c.
    SELECT SINGLE low INTO v_tryoff FROM zonta_oc_param WHERE name = 'SET_TRY_OFF'.
    IF v_tryoff IS NOT INITIAL.
      CALL METHOD p_grid->refresh_table_display.
      CALL METHOD p_grid->refresh_table_display
        EXPORTING
          i_soft_refresh = 'X'
          is_stable      = lv_stable
        EXCEPTIONS
          OTHERS         = 99.
    ELSE.
      TRY."CECHAVARRIA 01/07/2025
          CALL METHOD p_grid->refresh_table_display.
        CATCH cx_salv_method_not_supported.
          CALL METHOD p_grid->refresh_table_display
            EXPORTING
              i_soft_refresh = 'X'
              is_stable      = lv_stable
            EXCEPTIONS
              OTHERS         = 99.
      ENDTRY.
    ENDIF.
  ENDIF.

ENDFORM.                    "update_grid
*&---------------------------------------------------------------------*
*& Form fieldcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_TABLES_ALV[]
*&      <-- GT_FCAT_TABLES
*&---------------------------------------------------------------------*
FORM fieldcat_variant USING       pt_table     TYPE ANY TABLE
                        CHANGING  pt_fieldcat  TYPE lvc_t_fcat.

  DATA:
    lr_tabdescr TYPE REF TO cl_abap_structdescr,
    lr_data     TYPE REF TO data,
    lt_dfies    TYPE ddfields,
    ls_dfies    TYPE dfies,
    ls_fieldcat TYPE lvc_s_fcat.

  CLEAR pt_fieldcat.

  CREATE DATA lr_data LIKE LINE OF pt_table.
  lr_tabdescr ?= cl_abap_structdescr=>describe_by_data_ref( lr_data ).
  lt_dfies = cl_salv_data_descr=>read_structdescr( lr_tabdescr ).

  LOOP AT lt_dfies INTO ls_dfies.
    CLEAR ls_fieldcat.
    MOVE-CORRESPONDING ls_dfies TO ls_fieldcat.

    ls_fieldcat-no_out = 'X'.
    CASE ls_fieldcat-fieldname.
      WHEN  'FIELDTEXT'.
        ls_fieldcat-reptext = 'Field Name'.
        ls_fieldcat-outputlen = '15'.
      WHEN  'TABNAME'.
        ls_fieldcat-reptext = 'Table Name'.
        ls_fieldcat-outputlen = '15'.
      WHEN 'VTYPE'.
        ls_fieldcat-f4availabl = 'X'.
        ls_fieldcat-outputlen = '15'.
      WHEN 'VTEXT'.
        ls_fieldcat-f4availabl = 'X'.
        ls_fieldcat-outputlen = '30'.
    ENDCASE.


    IF ls_fieldcat-fieldname = 'FIELDTEXT'
    OR ls_fieldcat-fieldname = 'TABNAME'
    OR ls_fieldcat-fieldname = 'VTYPE'
    OR ls_fieldcat-fieldname = 'VTEXT'.
      ls_fieldcat-no_out = ' '.
    ENDIF.

    APPEND ls_fieldcat TO pt_fieldcat.
  ENDLOOP.
ENDFORM.                    "fieldcat


*&---------------------------------------------------------------------*
*& Form fieldcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_TABLES_ALV[]
*&      <-- GT_FCAT_TABLES
*&--------------------------------------------------------------------*
FORM fieldcat USING       pt_table     TYPE ANY TABLE
                CHANGING  pt_fieldcat  TYPE lvc_t_fcat.

  DATA:
    lr_tabdescr TYPE REF TO cl_abap_structdescr,
    lr_data     TYPE REF TO data,
    lt_dfies    TYPE ddfields,
    ls_dfies    TYPE dfies,
    ls_fieldcat TYPE lvc_s_fcat.

  CLEAR pt_fieldcat.

  CREATE DATA lr_data LIKE LINE OF pt_table.
  lr_tabdescr ?= cl_abap_structdescr=>describe_by_data_ref( lr_data ).
  lt_dfies = cl_salv_data_descr=>read_structdescr( lr_tabdescr ).

  LOOP AT lt_dfies INTO ls_dfies.
    CLEAR ls_fieldcat.
    MOVE-CORRESPONDING ls_dfies TO ls_fieldcat.

    IF ls_fieldcat-fieldname = 'POSITIONF'.
      ls_fieldcat-no_out = 'X'.
    ENDIF.

    IF ls_fieldcat-fieldname = 'ALIAS_TABNAME'
    OR ls_fieldcat-fieldname = 'DESCRIPTION_TABLE'.
      ls_fieldcat-outputlen = 40.
    ENDIF.

    APPEND ls_fieldcat TO pt_fieldcat.
  ENDLOOP.
ENDFORM.                    "fieldcat
*&---------------------------------------------------------------------*
*& Form switch_mode
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM switch_mode .
  IF gv_option = co_change.
    gv_option = co_display.
  ELSE.
    gv_option = co_change.
  ENDIF.

  IF gv_option = co_change. "lo_alv_tables->is_ready_for_input( ) EQ 0.
    CALL METHOD lo_alv_tables->set_ready_for_input
      EXPORTING
        i_ready_for_input = 1.
    CALL METHOD lo_alv_columns->set_ready_for_input
      EXPORTING
        i_ready_for_input = 1.

  ELSE.
    CALL METHOD lo_alv_tables->set_ready_for_input
      EXPORTING
        i_ready_for_input = 0.
    CALL METHOD lo_alv_columns->set_ready_for_input
      EXPORTING
        i_ready_for_input = 0.

  ENDIF.


ENDFORM. "switch_edit_mode
*&---------------------------------------------------------------------*
*& Form exclude_options_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM exclude_options_alv .
  CLEAR: gt_exclude[],
         gt_exclude_col[].

  " Remove options in ALV
  gs_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row .
  APPEND gs_exclude TO gt_exclude.

  gs_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row .
  APPEND gs_exclude TO gt_exclude.

  gs_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row .
  APPEND gs_exclude TO gt_exclude.

  gs_exclude = cl_gui_alv_grid=>mc_fc_detail .
  APPEND gs_exclude TO gt_exclude.

  gs_exclude = cl_gui_alv_grid=>mc_fc_check .
  APPEND gs_exclude TO gt_exclude.

  gs_exclude = cl_gui_alv_grid=>mc_fc_refresh .
  APPEND gs_exclude TO gt_exclude.

  gs_exclude = cl_gui_alv_grid=>mc_fc_loc_copy .
  APPEND gs_exclude TO gt_exclude.

  gs_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row .
  APPEND gs_exclude TO gt_exclude.

  gs_exclude = cl_gui_alv_grid=>mc_fc_loc_cut .
  APPEND gs_exclude TO gt_exclude.

  gs_exclude = cl_gui_alv_grid=>mc_fc_loc_paste .
  APPEND gs_exclude TO gt_exclude.

  gs_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND gs_exclude TO gt_exclude.

  gs_exclude = cl_gui_alv_grid=>mc_fc_loc_undo .
  APPEND gs_exclude TO gt_exclude.

  gs_exclude = cl_gui_alv_grid=>mc_fc_info.
  APPEND gs_exclude TO gt_exclude.

ENDFORM.                    "exclude_options_alv
*&---------------------------------------------------------------------*
*& Form register_alv_events
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LO_ALV_COLUMNS
*&---------------------------------------------------------------------*
FORM register_alv_events  CHANGING p_grid_alv TYPE REF TO cl_gui_alv_grid.

  DATA: lo_event_handler TYPE REF TO lcl_event_handler.

  CREATE OBJECT lo_event_handler.

  CALL METHOD p_grid_alv->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter
    EXCEPTIONS
      error      = 1
      OTHERS     = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  " Register event for data change
  SET HANDLER lo_event_handler->on_data_changed FOR p_grid_alv.
  SET HANDLER lo_event_handler->on_data_changed_finished FOR p_grid_alv.


  IF gv_option = co_display.
    CALL METHOD p_grid_alv->set_ready_for_input
      EXPORTING
        i_ready_for_input = 0.
  ELSE.
    CALL METHOD p_grid_alv->set_ready_for_input
      EXPORTING
        i_ready_for_input = 1.
  ENDIF.

ENDFORM.                    "register_alv_events

*&---------------------------------------------------------------------*
*& Form register_alv_events
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LO_ALV_VARIANT
*&---------------------------------------------------------------------*
FORM register_alv_events_var  CHANGING p_grid_alv TYPE REF TO cl_gui_alv_grid.

  DATA: lo_event_handler TYPE REF TO lcl_event_handler_var.
* data for event handling
  DATA: ls_f4 TYPE lvc_s_f4,
        lt_f4 TYPE lvc_t_f4.

  CREATE OBJECT lo_event_handler.

  CALL METHOD p_grid_alv->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter
    EXCEPTIONS
      error      = 1
      OTHERS     = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  ls_f4-fieldname  = 'VTEXT'.
  ls_f4-register   = 'X'.
  APPEND ls_f4 TO lt_f4.

  ls_f4-fieldname  = 'VTYPE'.
  ls_f4-register   = 'X'.
  APPEND ls_f4 TO lt_f4.

  CALL METHOD p_grid_alv->register_f4_for_fields
    EXPORTING
      it_f4 = lt_f4.

  " Register event for data change
  SET HANDLER lo_event_handler->on_data_changed FOR p_grid_alv.
  SET HANDLER lo_event_handler->on_data_changed_finished FOR p_grid_alv.
  SET HANDLER lo_event_handler->on_f4 FOR p_grid_alv.



  CALL METHOD p_grid_alv->set_ready_for_input
    EXPORTING
      i_ready_for_input = 1.


ENDFORM.                    "register_alv_events


*&---------------------------------------------------------------------*
*& Form register_alv_events
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LO_ALV_VARIANT
*&---------------------------------------------------------------------*
FORM register_alv_events_varatt  CHANGING p_grid_alv TYPE REF TO cl_gui_alv_grid.

  DATA: lo_event_handler TYPE REF TO lcl_event_handler_varatt.
* data for event handling
  DATA: ls_f4 TYPE lvc_s_f4,
        lt_f4 TYPE lvc_t_f4.

  CREATE OBJECT lo_event_handler.

  CALL METHOD p_grid_alv->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter
    EXCEPTIONS
      error      = 1
      OTHERS     = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  ls_f4-fieldname  = 'OPTION'.
  ls_f4-register   = 'X'.
  APPEND ls_f4 TO lt_f4.

  ls_f4-fieldname  = 'SIGN'.
  ls_f4-register   = 'X'.
  APPEND ls_f4 TO lt_f4.

  CALL METHOD p_grid_alv->register_f4_for_fields
    EXPORTING
      it_f4 = lt_f4.

  " Register event for data change
  SET HANDLER lo_event_handler->on_data_changed FOR p_grid_alv.
  SET HANDLER lo_event_handler->on_data_changed_finished FOR p_grid_alv.
  SET HANDLER lo_event_handler->on_f4 FOR p_grid_alv.



  CALL METHOD p_grid_alv->set_ready_for_input
    EXPORTING
      i_ready_for_input = 1.


ENDFORM.                    "register_alv_events

*&---------------------------------------------------------------------*
*& Form register_alv_events
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LO_ALV_COLUMNS
*&---------------------------------------------------------------------*
FORM register_alv_events_any  CHANGING p_grid_alv TYPE REF TO cl_gui_alv_grid.

  DATA: lo_event_handler_any TYPE REF TO lcl_event_handler_any.

  CREATE OBJECT lo_event_handler_any.

  CALL METHOD p_grid_alv->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter
    EXCEPTIONS
      error      = 1
      OTHERS     = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  " Register event for data change
  SET HANDLER lo_event_handler_any->on_data_changed FOR p_grid_alv.

  IF gv_option = co_display.
    CALL METHOD p_grid_alv->set_ready_for_input
      EXPORTING
        i_ready_for_input = 0.
  ELSE.
    CALL METHOD p_grid_alv->set_ready_for_input
      EXPORTING
        i_ready_for_input = 1.
  ENDIF.

ENDFORM.                    "register_alv_events_any
*&---------------------------------------------------------------------*
* text
*----------------------------------------------------------------------*
* --> p1 text
* <-- p2 text
*----------------------------------------------------------------------*
FORM prepare_celltab_tables .

  FIELD-SYMBOLS: <fs_alv> LIKE LINE OF gt_tables_alv.

  DATA: lv_index   TYPE sy-tabix.
  DATA: ls_celltab  TYPE lvc_s_styl,
        lv_style    TYPE raw4,
        lv_styleall TYPE raw4,
        lv_tabname1 TYPE tabname,
        lv_tabname2 TYPE tabname,
        ls_alvt     LIKE LINE OF gt_tables_alv.

  CLEAR: gt_celltab[],
         gt_celltab_all[].

  IF gv_option = co_display.
    lv_style    = cl_gui_alv_grid=>mc_style_disabled.
    lv_styleall = cl_gui_alv_grid=>mc_style_disabled.
  ELSE.
    lv_style    = cl_gui_alv_grid=>mc_style_enabled.
    lv_styleall = cl_gui_alv_grid=>mc_style_disabled.
  ENDIF.

  ls_celltab-style = lv_styleall.
  ls_celltab-fieldname = 'ALIAS_TABNAME'.
  INSERT ls_celltab INTO TABLE gt_celltab_all.

  ls_celltab-style = lv_styleall.
  ls_celltab-fieldname = 'DESCRIPTION_TABLE'.
  INSERT ls_celltab INTO TABLE gt_celltab_all.

  ls_celltab-style = lv_style.
  ls_celltab-fieldname = 'ALIAS_TABNAME'.
  INSERT ls_celltab INTO TABLE gt_celltab.

  ls_celltab-style = lv_style.
  ls_celltab-fieldname = 'DESCRIPTION_TABLE'.
  INSERT ls_celltab INTO TABLE gt_celltab.


  SORT gt_tables_alv BY tabname.
  READ TABLE gt_tables_alv INTO ls_alvt INDEX 1.
  lv_tabname1 = ls_alvt-tabname.

  LOOP AT gt_tables_alv ASSIGNING <fs_alv>.
    lv_tabname1 = <fs_alv>-tabname.
    IF sy-tabix = 1.
      CLEAR <fs_alv>-celltab.
      INSERT LINES OF gt_celltab INTO TABLE <fs_alv>-celltab.
    ELSE.
      IF lv_tabname1 = lv_tabname2.
        CLEAR <fs_alv>-celltab.
        INSERT LINES OF gt_celltab_all INTO TABLE <fs_alv>-celltab.
      ELSE.
        CLEAR <fs_alv>-celltab.
        INSERT LINES OF gt_celltab INTO TABLE <fs_alv>-celltab.
        lv_tabname2 = lv_tabname1.

      ENDIF.
    ENDIF.

  ENDLOOP.


ENDFORM.                    "prepare_celltab_tables

*&---------------------------------------------------------------------*
* text
*----------------------------------------------------------------------*
* --> p1 text
* <-- p2 text
*----------------------------------------------------------------------*
FORM prepare_celltab_columns .

  FIELD-SYMBOLS: <fs_alv> LIKE LINE OF gt_columns_alv.

  DATA: lv_index        TYPE sy-tabix.
  DATA: ls_celltab      TYPE lvc_s_styl,
        lv_styled       TYPE raw4,
        lv_stylee       TYPE raw4,
        ls_columns      TYPE zonta_oc_col_all,
        ls_alvc         LIKE LINE OF gt_columns_alv,
        lt_columns_curr TYPE STANDARD TABLE OF zonta_oc_col_all,
        ls_col_curr     LIKE LINE OF lt_columns_curr.

  CLEAR: gt_celltab[],
         gt_celltab_all[].

  lv_stylee    = cl_gui_alv_grid=>mc_style_enabled.
  lv_styled    = cl_gui_alv_grid=>mc_style_disabled.

  ls_celltab-style = lv_stylee.
  ls_celltab-fieldname = 'ALIAS_FLDNAME'.
  INSERT ls_celltab INTO TABLE gt_celltab_all.

  ls_celltab-style = lv_stylee.
  ls_celltab-fieldname = 'SELECTION_FIELD'.
  INSERT ls_celltab INTO TABLE gt_celltab_all.

  ls_celltab-style = lv_stylee.
  ls_celltab-fieldname = 'DESCRIPTION_FIELD'.
  INSERT ls_celltab INTO TABLE gt_celltab_all.

  ls_celltab-style = lv_styled.
  ls_celltab-fieldname = 'ALIAS_FLDNAME'.
  INSERT ls_celltab INTO TABLE gt_celltab.

  ls_celltab-style = lv_styled.
  ls_celltab-fieldname = 'SELECTION_FIELD'.
  INSERT ls_celltab INTO TABLE gt_celltab.

  ls_celltab-style = lv_styled.
  ls_celltab-fieldname = 'DESCRIPTION_FIELD'.
  INSERT ls_celltab INTO TABLE gt_celltab.

  CALL METHOD go_cust->fill_info_field_new
    EXPORTING
      it_tables       = gt_tables[]
      it_columns      = gt_columns_alv[]
    IMPORTING
      et_columns      = gt_columns[]
      et_existing_rel = gt_ex_rel[]
      et_existing_col = gt_ex_col[].

  IF lines( gt_tables_alv ) > 0.
    SELECT *
      INTO TABLE lt_columns_curr
      FROM  zonta_oc_col_all
      FOR ALL ENTRIES IN gt_tables_alv
      WHERE tabname = gt_tables_alv-tabname
        AND alias_tabname = gt_tables_alv-alias_tabname.
    SORT lt_columns_curr BY tabname fldname.
  ENDIF.

  SORT gt_columns BY tabname fldname.
  SORT gt_ex_col BY tabname fldname.
  LOOP AT gt_columns_alv ASSIGNING <fs_alv>.
    IF <fs_alv>-alias_fldname IS INITIAL.
      READ TABLE gt_columns INTO ls_columns WITH KEY tabname = <fs_alv>-tabname
                                                   fldname = <fs_alv>-fldname BINARY SEARCH.
      IF sy-subrc = 0.
        MOVE-CORRESPONDING ls_columns TO <fs_alv>.
      ENDIF.
    ENDIF.

    READ TABLE gt_ex_col INTO gs_ex_col WITH KEY tabname = <fs_alv>-tabname
                                                 fldname = <fs_alv>-fldname BINARY SEARCH.
    IF sy-subrc = 0 AND gs_ex_col-key_field = c_x.
      CLEAR <fs_alv>-celltab.
      INSERT LINES OF gt_celltab INTO TABLE <fs_alv>-celltab.
    ELSEIF sy-subrc = 0 AND gs_ex_col-fldname = c_mandt.
      CLEAR <fs_alv>-celltab.
      INSERT LINES OF gt_celltab INTO TABLE <fs_alv>-celltab.
    ELSE.
      READ TABLE lt_columns_curr INTO ls_col_curr WITH KEY tabname = <fs_alv>-tabname
                                                 fldname = <fs_alv>-fldname BINARY SEARCH.
      IF sy-subrc = 0.
        IF <fs_alv>-key_field = c_x OR <fs_alv>-fldname = c_mandt.
          CLEAR <fs_alv>-celltab.
          INSERT LINES OF gt_celltab INTO TABLE <fs_alv>-celltab.
        ELSE.
          CLEAR <fs_alv>-celltab.
          INSERT LINES OF gt_celltab_all INTO TABLE <fs_alv>-celltab.
        ENDIF.
      ELSE.
        CLEAR <fs_alv>-celltab.
        INSERT LINES OF gt_celltab_all INTO TABLE <fs_alv>-celltab.
      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFORM.                    "prepare_celltab_columns

*&---------------------------------------------------------------------*
* text
*----------------------------------------------------------------------*
* --> p1 text
* <-- p2 text
*----------------------------------------------------------------------*
FORM prepare_celltab_auth .

  FIELD-SYMBOLS: <fs_alv> LIKE LINE OF gt_auth_alv.

  DATA: lv_index   TYPE sy-tabix.
  DATA: ls_celltab  TYPE lvc_s_styl,
        lv_style    TYPE raw4,
        lv_styleall TYPE raw4,
        ls_alvt     LIKE LINE OF gt_auth_alv.

  CLEAR: gt_celltab[],
         gt_celltab_all[].

  IF gv_option = co_display.
    lv_style    = cl_gui_alv_grid=>mc_style_disabled.
    lv_styleall = cl_gui_alv_grid=>mc_style_disabled.
  ELSE.
    lv_style    = cl_gui_alv_grid=>mc_style_enabled.
    lv_styleall = cl_gui_alv_grid=>mc_style_disabled.
  ENDIF.

  ls_celltab-style = lv_styleall.
  ls_celltab-fieldname = 'FIEL'.
  INSERT ls_celltab INTO TABLE gt_celltab_all.

  ls_celltab-style = lv_style.
  ls_celltab-fieldname = 'VAL'.
  INSERT ls_celltab INTO TABLE gt_celltab_all.


  LOOP AT gt_auth_alv ASSIGNING <fs_alv>.
    CLEAR <fs_alv>-celltab.
    INSERT LINES OF gt_celltab_all INTO TABLE <fs_alv>-celltab.
  ENDLOOP.


ENDFORM.                    "prepare_celltab_auth

*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form decide_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM decide_screen .

  IF    gv_mains     = abap_true
  AND   gv_tabless   = abap_true
  AND   gv_columnss  = abap_true.
    gv_screen = 300.
  ELSEIF  gv_mains    = abap_true
    AND   gv_tabless  = abap_true
    AND  gv_columnss  = abap_false.
    gv_screen = 310.
  ELSEIF gv_mains     = abap_true
    AND  gv_tabless   = abap_false
    AND  gv_columnss  = abap_true.
    gv_screen = 320.
  ELSEIF  gv_mains    = abap_true
    AND  gv_tabless   = abap_false
   AND   gv_columnss  = abap_false.
    gv_screen = 330.
  ELSEIF    gv_mains     = abap_false
  AND   gv_tabless   = abap_true
  AND   gv_columnss  = abap_true.
    gv_screen = 340.
  ELSEIF  gv_mains    = abap_false
    AND   gv_tabless  = abap_true
    AND  gv_columnss  = abap_false.
    gv_screen = 350.
  ELSEIF gv_mains     = abap_false
    AND  gv_tabless   = abap_false
    AND  gv_columnss  = abap_true.
    gv_screen = 360.
  ELSEIF  gv_mains    = abap_false
    AND  gv_tabless   = abap_false
   AND   gv_columnss  = abap_false.
    gv_screen = 370.
  ENDIF.

ENDFORM.                    "decide_screen

*&---------------------------------------------------------------------*
*& Form ready_input
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LO_ALV_COLUMNS
*&---------------------------------------------------------------------*
FORM ready_input  CHANGING p_grid_alv TYPE REF TO cl_gui_alv_grid.


  IF gv_option = co_display.
    CALL METHOD p_grid_alv->set_ready_for_input
      EXPORTING
        i_ready_for_input = 0.
  ELSE.
    CALL METHOD p_grid_alv->set_ready_for_input
      EXPORTING
        i_ready_for_input = 1.
  ENDIF.

ENDFORM.                    "ready_input
*&---------------------------------------------------------------------*
*& Form call_join_tables
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_join_tables .
  DATA: lv_mode    TYPE i,
        lt_rel     TYPE zontt_relations,
        ls_tab_alv LIKE LINE OF gt_tables_alv,
        lv_tables  TYPE i,
        lv_descrip TYPE i,
        ls_dbjt    LIKE LINE OF gt_dbjt,
        ls_ttab    LIKE LINE OF gt_ttab. ",
*        ls_ddl     TYPE ddddlsrct.

  DATA: ls_rel     LIKE LINE OF lt_rel.

  FIELD-SYMBOLS: <fs_dban> LIKE LINE OF gt_dban,
                 <fs_ttab> LIKE LINE OF gt_ttab.

  IF lines( gt_dbsg ) = 0.
    LOOP AT gt_tables_alv INTO ls_tab_alv.
      CLEAR ls_rel.
      MOVE-CORRESPONDING ls_tab_alv TO ls_rel.
      APPEND ls_rel TO lt_rel.
    ENDLOOP.

    CALL METHOD go_cust->create_tables_for_join
      EXPORTING
        it_tables = lt_rel[]
      IMPORTING
        et_dbsg   = gt_dbsg[]
        et_dbjt   = gt_dbjt[]
        et_ttab   = gt_ttab[]
        et_dbjc   = gt_dbjc[]
        et_dban   = gt_dban[].
  ELSE.
    LOOP AT gt_dban ASSIGNING <fs_dban>.
      READ TABLE gt_tables_alv INTO ls_tab_alv WITH KEY tabname = <fs_dban>-table.
      IF sy-subrc = 0.
        <fs_dban>-alias = ls_tab_alv-alias_tabname.
      ENDIF.
    ENDLOOP.
    LOOP AT gt_ttab ASSIGNING <fs_ttab>.
      READ TABLE gt_tables_alv INTO ls_tab_alv WITH KEY tabname = <fs_ttab>-ddic.
      IF sy-subrc = 0.
        <fs_ttab>-ddic-ddtext = ls_tab_alv-description_table.
      ENDIF.
    ENDLOOP.

  ENDIF.

  lv_mode = 1.
  SORT gt_dbjt BY table.
  DELETE ADJACENT DUPLICATES FROM gt_dbjt COMPARING table.
  SORT gt_dban BY table.
  DELETE ADJACENT DUPLICATES FROM gt_dban COMPARING table.
  SORT gt_ttab BY ddic.
  DELETE ADJACENT DUPLICATES FROM gt_ttab COMPARING ddic.

  DESCRIBE TABLE gt_dbjt LINES lv_tables.
  DESCRIBE TABLE gt_ttab LINES lv_descrip.
  IF lv_tables > lv_descrip.
    LOOP AT gt_dbjt INTO ls_dbjt.
      READ TABLE gt_ttab ASSIGNING <fs_ttab> WITH KEY ddic-tabname = ls_dbjt-table.
      IF sy-subrc NE 0.
*        SELECT SINGLE *
*          INTO  ls_ddl
*          FROM  ddddlsrct
*          WHERE ddlname = ls_dbjt-table.
*        IF sy-subrc = 0.
*          APPEND INITIAL LINE TO gt_ttab ASSIGNING <fs_ttab>.
*          <fs_ttab>-ddic-tabname = ls_dbjt-table.
*          <fs_ttab>-ddic-ddtext  = ls_ddl-ddtext.
*        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

  CALL FUNCTION 'ZONFM_DJ_DEFINE_JOIN_CNTRL'
    EXPORTING
      act_workspace_input = 'G'
      sgname_input        = 'ONE_CONNECT'
      caller_id_input     = space
      grafic_input        = 'X'
    TABLES
      clogsg_input        = gt_clogsg[]
      dbsa_input          = gt_dbsa[]
      dbob_input          = gt_dbob[]
      dbos_input          = gt_dbos[]
      dbif_input          = gt_dbif[]
      dbsf_input          = gt_dbsf[]
      dbsg_input          = gt_dbsg[]
      dban_input          = gt_dban[]
      dbjt_input          = gt_dbjt[]
      dbjc_input          = gt_dbjc[]
      dbzt_input          = gt_dbzt[]
      dbzc_input          = gt_dbzc[]
      dbzl_input          = gt_dbzl[]
      dbdp_input          = gt_dbdp[]
      dbpa_input          = gt_dbpa[]
      dbwr_input          = gt_dbwr[]
      dbar_input          = gt_dbar[]
      dbft_input          = gt_dbft[]
      sgtext_input        = gt_sgtext[]
      exdbfi_input        = gt_exdbfi[]
      ttab_input          = gt_ttab[]
      join_ok             = gt_join[]
    CHANGING
      headsg_input        = gv_headsg
      mode_input          = lv_mode
      maxsg_tindx_input   = gv_maxsg
    EXCEPTIONS
      cancelled           = 1
      OTHERS              = 2.
  IF sy-subrc = 0.
    DATA: lt_relations TYPE STANDARD TABLE OF zonta_relations,
          ls_t_alv     LIKE LINE OF gt_tables_alv.

    FIELD-SYMBOLS: <fs_rel> LIKE LINE OF lt_relations.

    CALL METHOD go_cust->return_tables_after_join
      EXPORTING
        it_dbsg      = gt_dbsg[]
        it_dbjt      = gt_dbjt[]
        it_dban      = gt_dban[]
        it_dbjc      = gt_dbjc[]
        it_ttab      = gt_ttab[]
        it_join      = gt_join[]
      IMPORTING
        et_relations = lt_relations[].

    DATA: ls_relations  LIKE LINE OF gt_tables,
          ls_tables_alv LIKE LINE OF gt_tables_alv.

    LOOP AT gt_tables_alv INTO ls_t_alv.
      READ TABLE lt_relations ASSIGNING <fs_rel> WITH KEY   tabname    = ls_t_alv-tabname
                                                            field_main = ls_t_alv-field_main
                                                            field_sec  = ls_t_alv-field_sec.
      IF sy-subrc = 0.
        <fs_rel>-alias_tabname = ls_t_alv-alias_tabname.
      ENDIF.
    ENDLOOP.
    CLEAR gt_tables_alv[].

    REFRESH gt_tables[].
    REFRESH gt_tables_alv[].
    LOOP AT lt_relations INTO ls_relations.
      CLEAR ls_tables_alv.
      APPEND ls_relations TO gt_tables.
      MOVE-CORRESPONDING ls_relations TO ls_tables_alv.
      APPEND ls_tables_alv TO gt_tables_alv.
    ENDLOOP.

    PERFORM check_first_field_main.
    PERFORM refresh_colums_after_change.
    PERFORM get_column_information.
    PERFORM generate_key_columns.
    PERFORM generate_ext_key_columns.
  ENDIF.

ENDFORM.                    "call_join_tables
*&---------------------------------------------------------------------*
*& Form clear_tables
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM clear_tables .

  CLEAR:
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
            gt_ttab[],
            gt_filters[],
            gt_franges[],
            gt_filters_new[],
            gt_franges_new[],
            gt_variant[],
            gt_variantd[],
            gt_varatt[],
            node_itab_left[],
            node_itab_right[],
            gt_ex_rel[],
            gt_ex_col[],
            gt_yrelations[],
            gt_ycolumns[],
            gt_regen[],
            mes1,
            mes2,
            gv_changes_rel,
            gv_changes_col,
            gv_changes_col_ex,
            gt_columns_alv,
            gt_columns_any_alv[],
            gt_tables_alv[],
            gt_filters_alv[],
            gt_variant_alv[],
            gt_tables[],
            gt_columns[],
            gt_columns_any[],
            gt_col_info[],
            gt_relations[],
            gt_filters[],
            gt_franges[],
            gt_filters_new[],
            gt_franges_new[],
            gt_fcat_tables[],
            gt_fcat_columns[],
            gt_fcat_col_any[],
            gt_selected_rows[],
            gt_celltab[],
            gt_celltab_all[],
            gt_exclude_col[],
            gt_auth_alv[],
            gt_converted[],
            gt_convertedt[],
            gs_auth,
            gs_varatt,
            gs_variant_alv.

  CLEAR:   gv_columnss,
           gv_tabless,
           gv_mains,
           gv_mode-text,
           gv_entity_type,
           gv_variant_exist,
           gv_variantd_exist,
           gv_variant,
           gv_xxstring,
           gv_yystring,
           gv_xxval,
           gv_xxsign,
           gv_yyval,
           gv_yysign,
           gv_screenv,
           gv_domainv,
           gv_entity.

  CLEAR:   zonta_oc_auth.

  IF go_cust IS NOT INITIAL.
    go_cust->refresh_tables( ).
  ENDIF.
  FREE go_json.

ENDFORM.                    "clear_tables
*&---------------------------------------------------------------------*
*& Form save_customizing
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_customizing .
  CONSTANTS: lc_mandt TYPE string VALUE 'MANDT'.

  DATA: lv_error          TYPE boolean,
        lv_entity         TYPE zonta_obj_oc-business_proc,
        lt_relations_save TYPE STANDARD TABLE OF zonta_relations,
        ls_relations_save TYPE zonta_relations,
        lt_columns_save   TYPE STANDARD TABLE OF zonta_oc_col_all,
        ls_columns_save   TYPE zonta_oc_col_all,
        ls_obj_tmp        TYPE zonta_obj_oc,
        lv_id             TYPE zonta_obj_oc-id,
        ls_tables_alv     LIKE LINE OF gt_tables_alv,
        lv_answer         TYPE c,
        ls_columns_alv    LIKE LINE OF gt_columns_alv,
        ls_col            LIKE LINE OF gt_ex_col,
        ls_col_tmp        LIKE LINE OF lt_columns_save,
        ls_col_tab        TYPE zonta_oc_col_all,
        lv_id_col         TYPE zonta_oc_col_all-id_column,
        lt_columns_tab    TYPE STANDARD TABLE OF zonta_oc_col_all,
        lv_continue       TYPE boolean.

  FIELD-SYMBOLS: <fs_col_alv> LIKE LINE OF gt_columns_alv.


  PERFORM check_entity_name.

  lv_continue = abap_true.

  IF zonta_obj_oc-log_type = 'F' AND zonta_obj_oc-file_path IS NOT INITIAL.
    PERFORM validate_filepath.
    IF gv_path_error = abap_true.
      lv_continue = abap_false.
    ENDIF.
  ENDIF.

  CHECK lv_continue = abap_true.

*BEGIN CECHAVARRIA 08/08/2025
  IF zonta_obj_oc-no_registros = '0000'.
    zonta_obj_oc-no_registros = '1'.
  ENDIF.
*END CECHAVARRIA 08/08/2025

  IF lo_alv_tables IS BOUND.
    lo_alv_tables->check_changed_data( ).
  ENDIF.
  IF lo_alv_columns IS BOUND.
    lo_alv_columns->check_changed_data( ).
  ENDIF.
  IF zonta_obj_oc-domainv IS INITIAL.
    zonta_obj_oc-domainv = zonta_obj_oc-tag1.
  ENDIF.

  lv_error = abap_false.
  PERFORM check_reference_fields.
  PERFORM check_first_field_main.
  PERFORM check_alias_tables.
  PERFORM check_changes.

  IF lines( gt_regen ) > 0.
    CALL FUNCTION 'POPUP_TO_DECIDE'
      EXPORTING
        textline1    = text-g01
        textline2    = text-g05
        textline3    = text-g06
        text_option1 = text-g02
        text_option2 = text-g03
        titel        = text-g04
      IMPORTING
        answer       = lv_answer.
  ELSE.
    lv_answer = '1'.
  ENDIF.

  IF gv_new = abap_true.
    gv_changes_col = abap_true.
    gv_changes_rel = abap_true.
  ENDIF.

  IF slg1 = abap_true.
    zonta_obj_oc-log_type = c_slg1.
    CLEAR zonta_obj_oc-file_path.
  ELSE.
    zonta_obj_oc-log_type = c_file.
    IF zonta_obj_oc-file_path IS INITIAL.
      lv_error = abap_true.
      MESSAGE i031(zon_cl_oc) DISPLAY LIKE 'I'.
    ENDIF.
  ENDIF.

  CHECK lv_error = abap_false.
  IF lv_answer = '1'.

* Save main customizing first
    SELECT SINGLE *
      INTO ls_obj_tmp
      FROM zonta_obj_oc
      WHERE domainv       = zonta_obj_oc-domainv
        AND business_proc = zonta_obj_oc-business_proc.
    IF sy-subrc = 0.
      lv_id = zonta_obj_oc-id.
      zonta_obj_oc-updated_by = sy-uname.
      zonta_obj_oc-updated_on = sy-datum.
      MODIFY zonta_obj_oc FROM zonta_obj_oc.
      IF sy-subrc = 0.
        COMMIT WORK.
      ELSE.
        lv_error = abap_true.
        PERFORM handle_error USING 'MAIN'.
      ENDIF.
    ELSE.
*      SELECT MAX( id )
*        INTO lv_id
*        FROM zonta_obj_oc.
      PERFORM get_next_range USING c_rentity CHANGING lv_id.

      IF lv_id = 0 OR lv_id IS INITIAL.
        lv_id = 1.
*      ELSE.
*        lv_id = lv_id + 1.
      ENDIF.

      IF gv_new = abap_true.
        zonta_obj_oc-erdat = sy-datum.
        zonta_obj_oc-ernam = sy-uname.
      ENDIF.

      zonta_obj_oc-mandt = sy-mandt.
      zonta_obj_oc-id = lv_id.
      zonta_obj_oc-updated_on = sy-datum.
      zonta_obj_oc-updated_by = sy-uname.
      MODIFY zonta_obj_oc FROM zonta_obj_oc.
      IF sy-subrc = 0.
        COMMIT WORK.
      ELSE.
        lv_error = abap_true.
      ENDIF.

    ENDIF.

* Delete structures before saving
    IF go_json IS INITIAL.
      CREATE OBJECT go_json.
    ELSE.
      FREE go_json.
      CREATE OBJECT go_json.
    ENDIF.

* Regenerate always
    IF gv_entity_type = c_relat.
      gv_changes_col = abap_true.
      gv_changes_rel = abap_true.
    ENDIF.

*BEGIN CECHAVARRIA 29/07/2025
    IF gv_new_excel = abap_true.
      gv_new_excel = abap_false.
      gv_new = abap_true.
    ENDIF.
*END CECHAVARRIA 29/07/2025

    IF zonta_obj_oc-domainv NE c_any
    AND gv_new = abap_false.
      IF gv_changes_col = abap_true
      OR gv_changes_rel = abap_true.
        DATA v_tryoff TYPE c.
        SELECT SINGLE low INTO v_tryoff FROM zonta_oc_param WHERE name = 'SET_TRY_OFF'.
        IF v_tryoff IS NOT INITIAL.
          CALL METHOD go_json->delete_json_ddic
            EXPORTING
              iv_domainv       = zonta_obj_oc-domainv
              iv_business_proc = zonta_obj_oc-business_proc.
*          PERFORM send_error_to_screen.
        ELSE.
          TRY.
              CALL METHOD go_json->delete_json_ddic
                EXPORTING
                  iv_domainv       = zonta_obj_oc-domainv
                  iv_business_proc = zonta_obj_oc-business_proc.
            CATCH cx_root INTO gx_text.
              PERFORM send_error_to_screen.
          ENDTRY.
        ENDIF.
      ENDIF.
    ENDIF.

** Save main customizing first
*    SELECT SINGLE *
*      INTO ls_obj_tmp
*      FROM zonta_obj_oc
*      WHERE domainv       = zonta_obj_oc-domainv
*        AND business_proc = zonta_obj_oc-business_proc.
*    IF sy-subrc = 0.
*      lv_id = zonta_obj_oc-id.
*      zonta_obj_oc-updated_by = sy-uname.
*      zonta_obj_oc-updated_on = sy-datum.
*      MODIFY zonta_obj_oc FROM zonta_obj_oc.
*      IF sy-subrc = 0.
*        COMMIT WORK.
*      ELSE.
*        lv_error = abap_true.
*        PERFORM handle_error USING 'MAIN'.
*      ENDIF.
*    ELSE.
**      SELECT MAX( id )
**        INTO lv_id
**        FROM zonta_obj_oc.
*      PERFORM get_next_range USING c_rentity CHANGING lv_id.
*
*      IF lv_id = 0 OR lv_id IS INITIAL.
*        lv_id = 1.
**      ELSE.
**        lv_id = lv_id + 1.
*      ENDIF.
*
*      IF gv_new = abap_true.
*        zonta_obj_oc-erdat = sy-datum.
*        zonta_obj_oc-ernam = sy-uname.
*      ENDIF.
*
*      zonta_obj_oc-mandt = sy-mandt.
*      zonta_obj_oc-id = lv_id.
*      zonta_obj_oc-updated_on = sy-datum.
*      zonta_obj_oc-updated_by = sy-uname.
*      MODIFY zonta_obj_oc FROM zonta_obj_oc.
*      IF sy-subrc = 0.
*        COMMIT WORK.
*      ELSE.
*        lv_error = abap_true.
*      ENDIF.
*
*    ENDIF.

    CHECK lv_error = abap_false.
* Save relations information
    IF gv_changes_rel = abap_true.
      LOOP AT gt_tables_alv INTO ls_tables_alv.
        MOVE-CORRESPONDING ls_tables_alv TO ls_relations_save.
        TRANSLATE ls_relations_save-alias_tabname USING c_guion.
        ls_relations_save-mandt         = sy-mandt.
        ls_relations_save-id            = lv_id.
        ls_relations_save-domainv       = zonta_obj_oc-domainv.
        ls_relations_save-business_proc = zonta_obj_oc-business_proc.
        APPEND ls_relations_save TO lt_relations_save.
      ENDLOOP.
      DELETE FROM zonta_relations WHERE domainv = zonta_obj_oc-domainv
                              AND business_proc = zonta_obj_oc-business_proc.
      IF sy-subrc = 0.
        COMMIT WORK.
      ENDIF.

      MODIFY zonta_relations FROM TABLE lt_relations_save.
      IF sy-subrc = 0.
        COMMIT WORK.
      ELSE.
        lv_error = abap_true.
      ENDIF.
    ENDIF.

    CHECK lv_error = abap_false.
* Save columns information   CHECK
    SORT gt_ex_rel BY tabname alias_tabname.
    SORT gt_columns_alv BY tabname fldname.
    SORT gt_ex_col BY tabname.
*    SELECT MAX( id_column )
*      INTO lv_id_col
*      FROM zonta_oc_col_all.
*    lv_id_col = lv_id_col + 1.
    SORT gt_columns BY tabname alias_tabname.

    IF lines( gt_tables_alv ) > 0.
      SELECT *
        INTO TABLE lt_columns_tab
        FROM zonta_oc_col_all
        FOR ALL ENTRIES IN gt_tables_alv
        WHERE tabname = gt_tables_alv-tabname
          AND alias_tabname = gt_tables_alv-alias_tabname.
      SORT lt_columns_tab BY tabname alias_tabname.
    ENDIF.

    LOOP AT gt_columns_alv INTO ls_columns_alv.
      MOVE-CORRESPONDING ls_columns_alv TO ls_columns_save.
      IF ls_columns_save-fldname = lc_mandt.
        CLEAR ls_columns_save-key_field .
      ENDIF.
      ls_columns_save-mandt         = sy-mandt.
      READ TABLE gt_ex_col INTO ls_col WITH KEY tabname = ls_columns_save-tabname
                                                alias_tabname = ls_columns_save-alias_tabname BINARY SEARCH.
      IF sy-subrc = 0.
        ls_columns_save-id_column = ls_col-id_column.
        ls_columns_save-alias_tabname = ls_col-alias_tabname.
      ELSE.
        READ TABLE gt_tables_alv INTO ls_tables_alv WITH KEY tabname = ls_columns_save-tabname.
        IF sy-subrc = 0.
          ls_columns_save-alias_tabname = ls_tables_alv-alias_tabname.
        ENDIF.


        SORT lt_columns_save BY tabname alias_tabname.
        READ TABLE lt_columns_save INTO ls_col_tmp WITH KEY tabname = ls_columns_save-tabname
                                                       alias_tabname = ls_columns_save-alias_tabname BINARY SEARCH.
        IF sy-subrc = 0.
          ls_columns_save-id_column = ls_col_tmp-id_column.
          ls_columns_save-alias_tabname = ls_col_tmp-alias_tabname.
        ELSE.
          READ TABLE lt_columns_tab INTO ls_col_tab  WITH KEY tabname = ls_columns_save-tabname
                                                       alias_tabname = ls_columns_save-alias_tabname BINARY SEARCH.
          IF sy-subrc = 0.
            ls_columns_save-id_column = ls_col_tab-id_column.
            ls_columns_save-alias_tabname = ls_col_tab-alias_tabname.
          ELSE.
            PERFORM get_next_range USING c_rcol_all CHANGING lv_id_col.
            ls_columns_save-id_column = lv_id_col.
          ENDIF.
        ENDIF.

      ENDIF.
      APPEND ls_columns_save TO lt_columns_save.

    ENDLOOP.

    DELETE lt_columns_save WHERE tabname IS INITIAL.
    PERFORM check_position_columns TABLES lt_columns_save[].

    DATA: lt_tables_col TYPE STANDARD TABLE OF zonta_oc_col_all.
    lt_tables_col[] = lt_columns_save[].
    SORT lt_tables_col BY tabname alias_tabname.
    DELETE ADJACENT DUPLICATES FROM lt_tables_col COMPARING tabname alias_tabname.
    LOOP AT lt_tables_col INTO ls_columns_save.
      DELETE FROM zonta_oc_col_all WHERE tabname = ls_columns_save-tabname
                               AND alias_tabname = ls_columns_save-alias_tabname.
      IF sy-subrc = 0.
        COMMIT WORK.
      ENDIF.
    ENDLOOP.

    PERFORM add_secondary_keys TABLES lt_columns_save[].
    PERFORM validate_alias_table TABLES lt_columns_save.
    PERFORM check_alias_fldname TABLES lt_columns_save[].

    MODIFY zonta_oc_col_all FROM TABLE lt_columns_save.
    IF sy-subrc = 0.
      COMMIT WORK.
    ELSE.
      lv_error = abap_true.
    ENDIF.

    PERFORM check_technical_names TABLES lt_columns_save[].

    CLEAR gt_columns_alv[].
    LOOP AT lt_columns_save INTO ls_columns_save.
      APPEND INITIAL LINE TO gt_columns_alv ASSIGNING <fs_col_alv>.
      MOVE-CORRESPONDING ls_columns_save TO <fs_col_alv>.
    ENDLOOP.

    IF lv_error = abap_false.
      MESSAGE s005(zon_cl_oc) WITH  zonta_obj_oc-business_proc DISPLAY LIKE 'S'.
    ENDIF.
** CHECK

    WAIT UP TO 3 SECONDS.
    IF lines( gt_franges_new ) > 0.
      DELETE FROM zonta_oc_franges WHERE domainv = zonta_obj_oc-domainv
                               AND business_proc = zonta_obj_oc-business_proc.
      MODIFY zonta_oc_franges FROM TABLE gt_franges_new.
      IF sy-subrc = 0.
        COMMIT WORK.
      ENDIF.
      DELETE FROM zonta_oc_filters WHERE domainv = zonta_obj_oc-domainv
                               AND business_proc = zonta_obj_oc-business_proc.
      MODIFY zonta_oc_filters FROM TABLE gt_filters_alv.
      IF sy-subrc = 0.
        COMMIT WORK.
      ENDIF.

    ENDIF.

    IF zonta_obj_oc-domainv NE c_any.
      IF gv_changes_rel = abap_true
      OR gv_changes_col = abap_true.
        PERFORM generate_structures.
      ENDIF.
    ENDIF.

    IF lines( gt_regen ) > 0 AND gv_changes_col = abap_true.
      PERFORM save_cus_existing_entities.
    ENDIF.
  ENDIF.


* Save authorization objects
  IF zonta_oc_auth-objct IS INITIAL.
    DELETE FROM zonta_oc_auth WHERE id = zonta_obj_oc-id.
    COMMIT WORK.
  ELSE.
    MOVE zonta_oc_auth-objct TO gs_auth-objct.
    DELETE FROM zonta_oc_auth WHERE id = zonta_obj_oc-id.
    gs_auth-id = zonta_obj_oc-id.
    MODIFY zonta_oc_auth FROM gs_auth.
    IF sy-subrc = 0.
      COMMIT WORK.
    ENDIF.
  ENDIF.


*Refresh initial list
  SELECT *
    FROM zonta_obj_oc
    INTO TABLE gt_obj_oc.

  gv_new = abap_false.

ENDFORM.                    "save_customizing

*&---------------------------------------------------------------------*
*& Form generate_structures
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM generate_structures .
  DATA: lt_col_temp TYPE STANDARD TABLE OF zonta_oc_col_all.

  IF lines( gt_tables_alv ) > 0.
  ELSE.
    SELECT *
      FROM zonta_relations
      INTO CORRESPONDING FIELDS OF TABLE gt_tables_alv
      WHERE domainv       = zonta_obj_oc-domainv
        AND business_proc = zonta_obj_oc-business_proc.
  ENDIF.

  IF lines( gt_tables_alv ) > 0.
    SELECT *
      INTO TABLE lt_col_temp
      FROM zonta_oc_col_all
            FOR ALL ENTRIES IN gt_tables_alv
          WHERE tabname = gt_tables_alv-tabname
            AND alias_tabname = gt_tables_alv-alias_tabname.

    IF sy-subrc = 0.
      IF go_json IS INITIAL.
        CREATE OBJECT go_json.
      ELSE.
        FREE go_json.
        CREATE OBJECT go_json.
      ENDIF.

      IF gv_order IS NOT INITIAL.   "++TRKORR DB
        DATA v_tryoff TYPE c.
        SELECT SINGLE low INTO v_tryoff FROM zonta_oc_param WHERE name = 'SET_TRY_OFF'.
        IF v_tryoff IS NOT INITIAL.
          go_json->set_trkorr( EXPORTING iv_tkorr = gv_order ).  "++TRKORR DB
*          PERFORM send_error_to_screen.
        ELSE.
          TRY.
              go_json->set_trkorr( EXPORTING iv_tkorr = gv_order ).  "++TRKORR DB
            CATCH cx_root INTO gx_text.
              PERFORM send_error_to_screen.
          ENDTRY.
        ENDIF.  "++TRKORR DB
      ENDIF.  "++TRKORR DB

*      PERFORM check_fields_lenght.   --30
      IF v_tryoff IS NOT INITIAL.
        go_json->create_json_ddic( iv_domainv       = zonta_obj_oc-domainv
                                   iv_business_proc = zonta_obj_oc-business_proc ).
      ELSE.
        TRY.
            go_json->create_json_ddic( iv_domainv       = zonta_obj_oc-domainv
                                       iv_business_proc = zonta_obj_oc-business_proc ).
          CATCH cx_root INTO gx_text.
            PERFORM send_error_to_screen.
        ENDTRY.
      ENDIF.

      MESSAGE s006(zon_cl_oc) WITH  zonta_obj_oc-business_proc DISPLAY LIKE 'S'.
    ENDIF.

  ENDIF.

  PERFORM save_ddic_objects.
ENDFORM.                    "generate_structures

*&---------------------------------------------------------------------*
*& Form refresh_tables_columns
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_tables_columns USING p_table.

  IF p_table = 'COL'.
    IF lines( gt_tables_alv ) > 0.
      SELECT *
      FROM zonta_oc_col_all
      INTO CORRESPONDING FIELDS OF TABLE gt_columns_alv
      FOR ALL ENTRIES IN gt_tables_alv
        WHERE tabname = gt_tables_alv-tabname
          AND alias_tabname = gt_tables_alv-alias_tabname.

      SORT gt_columns_alv BY tabname key_field DESCENDING fldname.

      SELECT *
        FROM zonta_oc_col_all
        INTO TABLE gt_ycolumns
      FOR ALL ENTRIES IN gt_tables_alv
        WHERE tabname = gt_tables_alv-tabname
          AND alias_tabname = gt_tables_alv-alias_tabname.

    ENDIF.
  ELSEIF p_table = 'TAB'.
    SELECT *
      FROM zonta_relations
      INTO CORRESPONDING FIELDS OF TABLE gt_tables_alv
      WHERE domainv           = zonta_obj_oc-domainv
        AND business_proc     = zonta_obj_oc-business_proc.
    SORT gt_tables_alv BY sequence levelv tabname.

    SELECT *
      FROM zonta_relations
      INTO TABLE gt_yrelations
      WHERE domainv           = zonta_obj_oc-domainv
        AND business_proc     = zonta_obj_oc-business_proc.
  ELSEIF p_table = 'VAR'.
    SELECT *
      FROM zonta_oc_variant
      INTO TABLE gt_variantd
         WHERE domainv         = zonta_obj_oc-domainv
         AND business_proc     = zonta_obj_oc-business_proc.
    SORT gt_variantd BY variant.
    DELETE ADJACENT DUPLICATES FROM gt_variant COMPARING variant.
    IF lines( gt_variantd ) > 0.
      gv_variantd_exist = abap_true.
    ENDIF.
    SELECT *
      FROM zonta_oc_franges
      INTO TABLE gt_variant
      WHERE domainv            = zonta_obj_oc-domainv
        AND business_proc      = zonta_obj_oc-business_proc
        AND variant            = space.
  ENDIF.

ENDFORM.                    "refresh_tables_columns
*&---------------------------------------------------------------------*
*& Form get_defaults_execute
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_defaults_execute .
  DATA: ls_param TYPE zonta_oc_param,
        lt_param TYPE STANDARD TABLE OF zonta_oc_param.

  SELECT *
    INTO TABLE lt_param
    FROM zonta_oc_param.

  CLEAR both.
  READ TABLE lt_param INTO ls_param WITH KEY name = 'USE_ALIAS'.
  IF sy-subrc = 0 AND ls_param-low = 'X'.
    alias = 'X'.
    CLEAR name.
    CLEAR both_tl.
  ELSE.
    name = 'X'.
    CLEAR alias.
    CLEAR both_tl.
  ENDIF.

  READ TABLE lt_param INTO ls_param WITH KEY name = c_transmission.
  IF sy-subrc = 0.
    CASE ls_param-low.
      WHEN c_kdoc.
        kdoc = 'X'.
        CLEAR table.
        CLEAR both.
      WHEN c_table .
        table = 'X'.
        CLEAR kdoc.
        CLEAR both.
      WHEN c_both.
        both = 'X'.
        CLEAR kdoc.
        CLEAR table.
    ENDCASE.
  ENDIF.


  READ TABLE lt_param INTO ls_param WITH KEY name = c_destination.
  IF sy-subrc = 0.
    gv_endpoint = ls_param-low.
  ENDIF.

  READ TABLE lt_param INTO ls_param WITH KEY name = c_proc_log.
  IF sy-subrc = 0.
    prlog = 'X'.
  ENDIF.

  SELECT *
    INTO TABLE gt_vardyn
    FROM zonta_oc_vardyn.
ENDFORM.                    "get_defaults_execute
*&---------------------------------------------------------------------*
*& Form get_column_information
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_column_information .

  IF go_cust IS INITIAL.
    CREATE OBJECT go_cust
      EXPORTING
        iv_domainv       = zonta_obj_oc-domainv
        iv_business_proc = zonta_obj_oc-business_proc.
  ENDIF.


  CALL METHOD go_cust->fill_info_field_new
    EXPORTING
      it_tables       = gt_tables[]
      it_columns      = gt_columns_alv[]
    IMPORTING
      et_columns      = gt_columns[]
      et_existing_rel = gt_ex_rel[]
      et_existing_col = gt_ex_col[].

  gt_col_info[] = gt_columns[].

ENDFORM.                    "get_column_information
*&---------------------------------------------------------------------*
*& Form execute_process
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM execute_process USING p_batch TYPE boolean.
  DATA: lv_size    TYPE zonde_oc_num30,
        lv_records TYPE zonde_oc_num30.

  IF zonta_oc_variant-variant IS NOT INITIAL.
    gv_variant = zonta_oc_variant-variant.
  ENDIF.

  IF name = abap_true.
    CLEAR gv_alias.
    CLEAR gv_bothtl.
    gv_fieldname = abap_true.
  ELSEIF alias = abap_true.
    CLEAR gv_fieldname.
    CLEAR gv_bothtl.
    gv_alias = abap_true.
  ELSE.
    CLEAR gv_alias.
    CLEAR gv_fieldname.
    gv_bothtl = abap_true.
  ENDIF.

  IF zonta_obj_oc-domainv = c_any.
    IF gv_tablen IS INITIAL.
      MESSAGE i014(zon_cl_oc).
* Execute ANY table process
    ELSE.
      CLEAR: gt_columns_any_alv[].
      CLEAR: gt_columns_any[].
      CLEAR: gv_edita, gv_tablea.
      CALL SCREEN 700.
    ENDIF.
  ELSE.

    DATA v_tryoff TYPE c.
    SELECT SINGLE low INTO v_tryoff FROM zonta_oc_param WHERE name = 'SET_TRY_OFF'.
    IF both = abap_true.
      IF v_tryoff IS NOT INITIAL.
        IF go_json IS BOUND.
          CLEAR go_json.
        ENDIF.
        CREATE OBJECT go_json.

        CALL METHOD go_json->get_relation
          EXPORTING
            iv_domainv       = zonta_obj_oc-domainv
            iv_business_proc = zonta_obj_oc-business_proc
            iv_kdoc          = abap_true
            iv_table         = abap_true
            iv_dest          = gv_endpoint
            iv_batch         = p_batch
            iv_fieldname     = gv_fieldname
            iv_bothnames     = gv_bothtl
            iv_alias         = gv_alias
            iv_variant       = gv_variant
          IMPORTING
            ev_sizet         = lv_size
            ev_recordst      = lv_records
          EXCEPTIONS
            not_data_found   = 1
            OTHERS           = 2.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.
*        PERFORM send_error_to_screen.
      ELSE.
        TRY.
            IF go_json IS BOUND.
              CLEAR go_json.
            ENDIF.
            CREATE OBJECT go_json.

            CALL METHOD go_json->get_relation
              EXPORTING
                iv_domainv       = zonta_obj_oc-domainv
                iv_business_proc = zonta_obj_oc-business_proc
                iv_kdoc          = abap_true
                iv_table         = abap_true
                iv_dest          = gv_endpoint
                iv_alias         = gv_alias
                iv_batch         = p_batch
                iv_fieldname     = gv_fieldname
                iv_bothnames     = gv_bothtl
                iv_variant       = gv_variant
              IMPORTING
                ev_sizet         = lv_size
                ev_recordst      = lv_records
              EXCEPTIONS
                not_data_found   = 1
                OTHERS           = 2.
            IF sy-subrc <> 0.
* Implement suitable error handling here
            ENDIF.
          CATCH cx_root INTO gx_text.
            PERFORM send_error_to_screen.
        ENDTRY.   "NEWV
      ENDIF.   "NEWV
    ELSE.
      IF v_tryoff IS NOT INITIAL.
        IF go_json IS BOUND.
          CLEAR go_json.
        ENDIF.
        CREATE OBJECT go_json.

        CALL METHOD go_json->get_relation
          EXPORTING
            iv_domainv       = zonta_obj_oc-domainv
            iv_business_proc = zonta_obj_oc-business_proc
            iv_kdoc          = kdoc
            iv_table         = table
            iv_dest          = gv_endpoint
            iv_batch         = p_batch
            iv_alias         = gv_alias
            iv_fieldname     = gv_fieldname
            iv_bothnames     = gv_bothtl
            iv_variant       = gv_variant
          IMPORTING
            ev_sizet         = lv_size
            ev_recordst      = lv_records
          EXCEPTIONS
            not_data_found   = 1
            OTHERS           = 2.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.
*        PERFORM send_error_to_screen.
      ELSE.
        TRY.
            IF go_json IS BOUND.
              CLEAR go_json.
            ENDIF.
            CREATE OBJECT go_json.

            CALL METHOD go_json->get_relation
              EXPORTING
                iv_domainv       = zonta_obj_oc-domainv
                iv_business_proc = zonta_obj_oc-business_proc
                iv_kdoc          = kdoc
                iv_table         = table
                iv_dest          = gv_endpoint
                iv_alias         = gv_alias
                iv_batch         = p_batch
                iv_fieldname     = gv_fieldname
                iv_bothnames     = gv_bothtl
                iv_variant       = gv_variant
              IMPORTING
                ev_sizet         = lv_size
                ev_recordst      = lv_records
              EXCEPTIONS
                not_data_found   = 1
                OTHERS           = 2.
            IF sy-subrc <> 0.
* Implement suitable error handling here
            ENDIF.
          CATCH cx_root INTO gx_text.
            PERFORM send_error_to_screen.
        ENDTRY.   "NEWV
      ENDIF.
    ENDIF.
  ENDIF.

  gv_size = lv_size.
  gv_records = lv_records.
  IF go_json IS NOT INITIAL.
    FREE go_json.
  ENDIF.


ENDFORM.                    "execute_process

*&---------------------------------------------------------------------*
*& Form execute_process_class
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM execute_process_class USING p_batch TYPE boolean.
  DATA: lv_size    TYPE zonde_oc_num30,
        lv_records TYPE zonde_oc_num30.
  DATA: lv_class TYPE string,
        lo_descr TYPE REF TO cl_abap_objectdescr,
        lo_obj   TYPE REF TO object.
  DATA: lo_iface  TYPE REF TO zonif_code,
        lv_entity TYPE zonde_process.

  DATA: lx_create TYPE REF TO cx_sy_create_object_error,
        lx_cast   TYPE REF TO  cx_sy_move_cast_error.

  DATA lv_msg_cx TYPE string.

  IF name = abap_true.
    CLEAR gv_alias.
    CLEAR gv_bothtl.
    gv_fieldname = abap_true.
  ELSEIF alias = abap_true.
    CLEAR gv_fieldname.
    CLEAR gv_bothtl.
    gv_alias = abap_true.
  ELSE.
    CLEAR gv_alias.
    CLEAR gv_fieldname.
    gv_bothtl = abap_true.
  ENDIF.

  lv_class = zonta_obj_oc-class_name.
  lv_entity = zonta_obj_oc-business_proc.


  DATA v_tryoff TYPE c.
  SELECT SINGLE low INTO v_tryoff FROM zonta_oc_param WHERE name = 'SET_TRY_OFF'.
  IF v_tryoff IS NOT INITIAL.

    lo_descr ?= cl_abap_objectdescr=>describe_by_name( lv_class ).

    CREATE OBJECT lo_obj TYPE (lv_class).
    lo_iface ?= lo_obj.
    CALL METHOD lo_iface->send_data
      EXPORTING
        iv_data   = zonta_obj_oc
        iv_entity = lv_entity
        iv_dest   = gv_endpoint.
  ELSE.
    TRY.
        lo_descr ?= cl_abap_objectdescr=>describe_by_name( lv_class ).

        CREATE OBJECT lo_obj TYPE (lv_class).
        lo_iface ?= lo_obj.
        CALL METHOD lo_iface->send_data
          EXPORTING
            iv_data   = zonta_obj_oc
            iv_entity = lv_entity
            iv_dest   = gv_endpoint.

*      CATCH cx_sy_create_object_error INTO DATA(lx_create).
      CATCH cx_sy_create_object_error INTO lx_create.
        lv_msg_cx = lx_create->get_text( ).
        MESSAGE lv_msg_cx TYPE 'E'.

*      CATCH cx_sy_move_cast_error INTO DATA(lx_cast).
      CATCH cx_sy_move_cast_error INTO lx_cast.
        lv_msg_cx = lx_cast->get_text( ).
        MESSAGE lv_msg_cx TYPE 'E'.
    ENDTRY.
  ENDIF.


  gv_size = lv_size.
  gv_records = lv_records.
  IF go_json IS NOT INITIAL.
    FREE go_json.
  ENDIF.


ENDFORM.                    "execute_process_class

*&---------------------------------------------------------------------*
*& Form start
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM start .

  DATA: event  TYPE cntl_simple_event,
        events TYPE cntl_simple_events.

  IF  g_application IS INITIAL.
    CREATE OBJECT g_application.
  ENDIF.


  IF container IS INITIAL.
    CREATE OBJECT container
      EXPORTING
        container_name = 'CONTAINER'.
    CREATE OBJECT splitter
      EXPORTING
        parent      = container
        orientation = 1.
    left = splitter->top_left_container.
    right = splitter->bottom_right_container.

    CREATE OBJECT tree_right
      EXPORTING
        node_selection_mode         = cl_simple_tree_model=>node_sel_mode_single
      EXCEPTIONS
        illegal_node_selection_mode = 1.

    CREATE OBJECT tree_left
      EXPORTING
        node_selection_mode         = cl_simple_tree_model=>node_sel_mode_single
      EXCEPTIONS
        illegal_node_selection_mode = 1.

    CALL METHOD tree_right->create_tree_control
      EXPORTING
        parent                       = right
      EXCEPTIONS
        lifetime_error               = 1
        cntl_system_error            = 2
        create_error                 = 3
        failed                       = 4
        tree_control_already_created = 5.
    IF sy-subrc <> 0.
*    MESSAGE a001.
    ENDIF.

    CALL METHOD tree_left->create_tree_control
      EXPORTING
        parent                       = left
      EXCEPTIONS
        lifetime_error               = 1
        cntl_system_error            = 2
        create_error                 = 3
        failed                       = 4
        tree_control_already_created = 5.
    IF sy-subrc <> 0.
*    MESSAGE a001.
    ENDIF.

* Definition of drag drop behaviour
    CREATE OBJECT behaviour_left.
    CALL METHOD behaviour_left->add
      EXPORTING
        ##NO_TEXT
        flavor     = 'Tree_move'
        dragsrc    = 'X'
        droptarget = ' '
        effect     = cl_dragdrop=>copy.
    CALL METHOD behaviour_left->add
      EXPORTING
        ##NO_TEXT
        flavor     = 'Tree_copy'
        dragsrc    = 'X'
        droptarget = ' '
        effect     = cl_dragdrop=>copy.

    CALL METHOD behaviour_left->get_handle
      IMPORTING
        handle = handle_tree_left.

* Drag Drop behaviour of tree control nodes are defined in the node
* structure
    PERFORM fill_tree_all CHANGING handle_tree_left node_itab_left.

    CALL METHOD tree_left->add_nodes
      EXPORTING
        node_table = node_itab_left.
*                   table_structure_name = 'NODE_STR'.

    CREATE OBJECT behaviour_right.

    CALL METHOD behaviour_right->add
      EXPORTING
        ##NO_TEXT
        flavor     = 'Tree_copy'
        dragsrc    = ' '
        droptarget = 'X'
        effect     = cl_dragdrop=>copy.
    CALL METHOD behaviour_right->add
      EXPORTING
        ##NO_TEXT
        flavor     = 'Tree_move'
        dragsrc    = ' '
        droptarget = 'X'
        effect     = cl_dragdrop=>copy.
    CALL METHOD behaviour_right->get_handle
      IMPORTING
        handle = handle_tree_right.

    PERFORM fill_tree_selected CHANGING handle_tree_right node_itab_right.
    CALL METHOD tree_right->add_nodes
      EXPORTING
        node_table = node_itab_right.
*                   table_structure_name = 'NODE_STR'.

* registration of drag and drop events
    DATA dragdrop TYPE REF TO lcl_dragdrop_receiver.
    CREATE OBJECT dragdrop.

************++
* define the events which will be passed to the backend
    " node double click
    event-eventid = cl_simple_tree_model=>eventid_node_double_click.
    event-appl_event = 'X'.              " process PAI if event occurs
    APPEND event TO events.

    CALL METHOD tree_left->set_registered_events
      EXPORTING
        events                    = events
      EXCEPTIONS
        illegal_event_combination = 1
        unknown_event             = 2.
    IF sy-subrc <> 0.
*    MESSAGE a001.
    ENDIF.


    CALL METHOD tree_right->set_registered_events
      EXPORTING
        events                    = events
      EXCEPTIONS
        illegal_event_combination = 1
        unknown_event             = 2.
    IF sy-subrc <> 0.
*    MESSAGE a001.
    ENDIF.

* assign event handlers in the application class to each desired event
    SET HANDLER g_application->handle_node_double_click FOR tree_left.
    SET HANDLER g_application->handle_node_double_click_back FOR tree_right.

***********+
    CALL METHOD tree_left->expand_node
    ##NO_TEXT
      EXPORTING
        node_key = 'Root'.
    CALL METHOD tree_right->expand_node
    ##NO_TEXT
      EXPORTING
        node_key = 'Root'.
  ELSE.
    DATA: update_nodes TYPE  treemsunot.

    CLEAR update_nodes[].

  ENDIF.

ENDFORM.                    "start
*&---------------------------------------------------------------------*
*& Form fill_tree_all
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- HANDLE_TREE_LEFT
*&      <-- NODE_ITAB_LEFT
*&---------------------------------------------------------------------*
FORM fill_tree_all CHANGING handle_tree TYPE i
                            node_itab LIKE node_itab_left.

  CONSTANTS: lc_child TYPE string     VALUE 'Child_',
             lc_root  TYPE tm_nodekey VALUE 'Root',
             lc_par1  TYPE c          VALUE '(',
             lc_par2  TYPE c          VALUE ')'.

  DATA: node TYPE treemsnodt. "mtreesnode.
  DATA: lt_tables_rel TYPE zontt_relations,
        lt_columns    TYPE zontt_col_all,
        lv_parent     TYPE tm_nodekey,
        ls_tables_alv LIKE LINE OF gt_tables_alv,
        ls_tables_rel LIKE LINE OF lt_tables_rel.

  CLEAR gt_col_info[].
  CLEAR node_itab[].

*  MOVE-CORRESPONDING gt_tables_alv[] TO lt_tables_rel[].
  CLEAR lt_tables_rel[].
  LOOP AT gt_tables_alv INTO ls_tables_alv.
    CLEAR ls_tables_rel.
    MOVE-CORRESPONDING ls_tables_alv TO ls_tables_rel.
    APPEND ls_tables_rel TO lt_tables_rel.
  ENDLOOP.

  SORT lt_tables_rel BY tabname.
  DELETE ADJACENT DUPLICATES FROM lt_tables_rel COMPARING tabname.


  CALL METHOD go_cust->fill_info_field_new
    EXPORTING
      it_tables       = lt_tables_rel[]
      it_columns      = gt_columns_alv[]
    IMPORTING
      et_columns      = lt_columns[]
      et_existing_rel = gt_ex_rel[]
      et_existing_col = gt_ex_col[].

  SORT gt_ex_rel BY tabname.

  gt_col_info[] = lt_columns[].

* node table of the left tree
  CLEAR node.
  node-node_key = lc_root.
  node-isfolder = 'X'.
  node-text = 'Available Fields'(m01).
  node-dragdropid = ' '.
  APPEND node TO node_itab.

  SORT lt_tables_rel BY sequence tabname.
  SORT lt_columns BY tabname fldname.

  DATA: ls_tables  LIKE LINE OF lt_tables_rel,
        ls_columns LIKE LINE OF lt_columns.

  LOOP AT lt_tables_rel INTO ls_tables.

    CLEAR node.
*    node-node_key = |{ lc_child }{ ls_tables-tabname }|.
    CONCATENATE lc_child ls_tables-tabname INTO node-node_key.

    node-relatkey = lc_root.
    node-isfolder = 'X'.
    node-relatship = cl_simple_tree_model=>relat_last_child.
*    node-text = |{ ls_tables-tabname } { ls_tables-description_table }|.
    CONCATENATE ls_tables-tabname ls_tables-description_table INTO node-text SEPARATED BY space.

    node-dragdropid = handle_tree.
    APPEND node TO node_itab.
    lv_parent = node-node_key.

    SORT lt_columns BY tabname positionf ASCENDING.
    LOOP AT lt_columns INTO ls_columns WHERE tabname = ls_tables-tabname.
      CLEAR node.
*      node-node_key = |{ lv_parent }{ ls_columns-fldname }|.
      CONCATENATE lv_parent ls_columns-fldname INTO node-node_key.

      node-relatkey = lv_parent.
      node-isfolder = ' '.
      node-relatship = cl_simple_tree_model=>relat_last_child.
*      node-text = |{ ls_columns-description_field }{ lc_par1 } { ls_columns-fldname }{ lc_par2 }|.
      CONCATENATE ls_columns-description_field lc_par1 ls_columns-fldname lc_par2 INTO node-text.

      node-dragdropid = handle_tree.
      APPEND node TO node_itab.
    ENDLOOP.
  ENDLOOP.


ENDFORM.                    "fill_tree_all

*&---------------------------------------------------------------------*
*& Form fill_tree_selected
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- HANDLE_TREE_LEFT
*&      <-- NODE_ITAB_LEFT
*&---------------------------------------------------------------------*
FORM fill_tree_selected CHANGING handle_tree TYPE i
                                 node_itab LIKE node_itab_left.

  CONSTANTS: lc_child TYPE string     VALUE 'Child_',
             lc_root  TYPE tm_nodekey VALUE 'Root',
             lc_par1  TYPE c          VALUE '(',
             lc_par2  TYPE c          VALUE ')'.

  DATA: node TYPE treemsnodt. "mtreesnode.
  DATA: lt_tables_rel TYPE zontt_relations,
        lt_columns    TYPE zontt_col_all,
        lv_parent     TYPE tm_nodekey,
        ls_tables     LIKE LINE OF lt_tables_rel,
        ls_columns    LIKE LINE OF gt_columns_alv,
        ls_tables_alv LIKE LINE OF gt_tables_alv,
        ls_tables_rel LIKE LINE OF lt_tables_rel,
        ls_columns_ex LIKE LINE OF gt_ex_col,
        ls_col_info   LIKE LINE OF gt_col_info.

  FIELD-SYMBOLS: <fs_col> LIKE LINE OF gt_columns_alv.

  CLEAR node_itab[].

*  MOVE-CORRESPONDING gt_tables_alv[] TO lt_tables_rel[].
  CLEAR lt_tables_rel[].
  LOOP AT gt_tables_alv INTO ls_tables_alv.
    CLEAR ls_tables_rel.
    MOVE-CORRESPONDING ls_tables_alv TO ls_tables_rel.
    APPEND ls_tables_rel TO lt_tables_rel.
  ENDLOOP.

  SORT lt_tables_rel BY tabname.
  DELETE ADJACENT DUPLICATES FROM lt_tables_rel COMPARING tabname.
  SORT gt_ex_rel BY tabname.

* node table of the left tree
  CLEAR node.
  node-node_key = lc_root.
  node-isfolder = 'X'.
  node-text = 'Selected Fields'(m02).
  node-dragdropid = ' '.
  APPEND node TO node_itab.

  SORT lt_tables_rel BY sequence tabname.
  SORT gt_columns_alv BY tabname fldname.


  LOOP AT lt_tables_rel INTO ls_tables.
    CLEAR node.
*    node-node_key = |{ lc_child }{ ls_tables-tabname }|.
    CONCATENATE lc_child ls_tables-tabname INTO node-node_key.

    node-relatkey = lc_root.
    node-isfolder = 'X'.
    node-relatship = cl_simple_tree_model=>relat_last_child.
*    node-text = |{ ls_tables-tabname } { ls_tables-description_table }|.
    CONCATENATE ls_tables-tabname ls_tables-description_table INTO node-text SEPARATED BY space.

    node-dragdropid = handle_tree.
*    IF NOT line_exists( node_itab[ node_key = node-node_key relatkey = lc_root ] ).
    READ TABLE node_itab TRANSPORTING NO FIELDS WITH KEY node_key = node-node_key relatkey = lc_root.
    IF sy-subrc NE 0.
      APPEND node TO node_itab.
      lv_parent = node-node_key.
    ENDIF.

*    IF line_exists( gt_columns_alv[ tabname = ls_tables-tabname ] ).
    READ TABLE gt_columns_alv TRANSPORTING NO FIELDS WITH KEY tabname = ls_tables-tabname.
    IF sy-subrc = 0.
*      SORT gt_columns_alv BY tabname positionf ASCENDING.
      LOOP AT gt_columns_alv INTO ls_columns WHERE tabname = ls_tables-tabname.
        CLEAR node.
*        node-node_key = |{ lv_parent }{ ls_columns-fldname }|.
        CONCATENATE lv_parent ls_columns-fldname INTO node-node_key.

        node-relatkey = lv_parent.
        node-isfolder = ' '.
        node-relatship = cl_simple_tree_model=>relat_last_child.
*        node-text = |{ ls_columns-description_field }{ lc_par1 } { ls_columns-fldname } { lc_par2 }|.
        CONCATENATE ls_columns-description_field lc_par1 ls_columns-fldname lc_par2 INTO node-text.

        node-dragdropid = handle_tree.
*        IF NOT line_exists( node_itab[ node_key = node-node_key relatkey = lv_parent ] ).
        READ TABLE node_itab TRANSPORTING NO FIELDS WITH KEY node_key = node-node_key relatkey = lv_parent.
        IF sy-subrc NE 0.
          APPEND node TO node_itab.
        ENDIF.
      ENDLOOP.
*      SORT gt_col_info BY tabname positionf ASCENDING.
      LOOP AT gt_col_info INTO ls_col_info WHERE tabname = ls_tables-tabname AND key_field = 'X'.
        READ TABLE gt_columns_alv INTO ls_columns WITH KEY tabname = ls_tables-tabname fldname = ls_col_info-fldname BINARY SEARCH.
        IF sy-subrc NE 0.
          CLEAR node.
*          node-node_key = |{ lv_parent }{ ls_columns-fldname }|.
          CONCATENATE lv_parent ls_columns-fldname INTO node-node_key.

          node-relatkey = lv_parent.
          node-isfolder = ' '.
          node-relatship = cl_simple_tree_model=>relat_last_child.
*          node-text = |{ ls_columns-description_field }{ lc_par1 } { ls_columns-fldname } { lc_par2 }|.
          CONCATENATE ls_columns-description_field lc_par1 ls_columns-fldname lc_par2 INTO node-text.

          node-dragdropid = handle_tree.
*          IF NOT line_exists( node_itab[ node_key = node-node_key relatkey = lv_parent ] ).
          READ TABLE node_itab TRANSPORTING NO FIELDS WITH KEY node_key = node-node_key relatkey = lv_parent.
          IF sy-subrc NE 0.
            APPEND node TO node_itab.
            APPEND INITIAL LINE TO gt_columns_alv ASSIGNING <fs_col>.
            MOVE-CORRESPONDING ls_col_info TO <fs_col>.
          ENDIF.
        ENDIF.
      ENDLOOP.

    ELSE.
* It will copy all columns from existing entity
      READ TABLE gt_ex_col TRANSPORTING NO FIELDS WITH KEY tabname = ls_tables-tabname.
      IF sy-subrc = 0.
        LOOP AT gt_ex_col INTO ls_columns_ex WHERE tabname = ls_tables-tabname.
          CLEAR node.
*        node-node_key = |{ lv_parent }{ ls_columns-fldname }|.
          CONCATENATE lv_parent ls_columns_ex-fldname INTO node-node_key.

          node-relatkey = lv_parent.
          node-isfolder = ' '.
          node-relatship = cl_simple_tree_model=>relat_last_child.
*        node-text = |{ ls_columns-description_field }{ lc_par1 } { ls_columns-fldname } { lc_par2 }|.
          CONCATENATE ls_columns_ex-description_field lc_par1 ls_columns_ex-fldname lc_par2 INTO node-text.

          node-dragdropid = handle_tree.
*        IF NOT line_exists( node_itab[ node_key = node-node_key relatkey = lv_parent ] ).
          READ TABLE node_itab TRANSPORTING NO FIELDS WITH KEY  node_key = node-node_key relatkey = lv_parent.
          IF sy-subrc NE 0.
            APPEND node TO node_itab.
            APPEND INITIAL LINE TO gt_columns_alv ASSIGNING <fs_col>.
            MOVE-CORRESPONDING ls_columns_ex TO <fs_col>.
          ENDIF.
        ENDLOOP.

      ELSE.
*      SORT gt_col_info BY tabname positionf ASCENDING.
        LOOP AT gt_col_info INTO ls_col_info WHERE ( tabname = ls_tables-tabname AND key_field = 'X' )
                                                OR ( tabname = ls_tables-tabname AND fldname = c_mandt ).
          CLEAR node.
*        node-node_key = |{ lv_parent }{ ls_col_info-fldname }|.
          CONCATENATE lv_parent ls_col_info-fldname INTO node-node_key.

          node-relatkey = lv_parent.
          node-isfolder = ' '.
          node-relatship = cl_simple_tree_model=>relat_last_child.
*        node-text = |{ ls_col_info-description_field }{ lc_par1 } { ls_col_info-fldname } { lc_par2 }|.
          CONCATENATE ls_col_info-description_field lc_par1 ls_col_info-fldname lc_par2 INTO node-text.

          node-dragdropid = handle_tree.
*        IF NOT line_exists( node_itab[ node_key = node-node_key relatkey = lv_parent ] ).
          READ TABLE node_itab TRANSPORTING NO FIELDS WITH KEY  node_key = node-node_key relatkey = lv_parent.
          IF sy-subrc NE 0.
            APPEND node TO node_itab.
            APPEND INITIAL LINE TO gt_columns_alv ASSIGNING <fs_col>.
            MOVE-CORRESPONDING ls_col_info TO <fs_col>.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.

  ENDLOOP.


ENDFORM.                    "fill_tree_selected

*&---------------------------------------------------------------------*
*&      Form  ADD_NODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_NEW_NODE  text
*      <--P_NEW_NODES  text
*      <--P_NODE_ITAB_LEFT  text
*----------------------------------------------------------------------*
FORM add_node CHANGING node_key
                       new_node TYPE treemsnodt"node_str
                       new_nodes LIKE node_itab_left
                       node_itab_left LIKE node_itab_left.

  FIELD-SYMBOLS: <fs_col> LIKE LINE OF gt_columns_alv.

  CONSTANTS: lc_guion TYPE c VALUE '_',
             lc_par1  TYPE c VALUE '(',
             lc_par2  TYPE c VALUE ')'.

  DATA: lv_tabname  TYPE tabname,
        lv_fldname  TYPE fieldname,
        lv_child    TYPE string,
        lv_tmp      TYPE string,
        ls_col_info LIKE LINE OF gt_col_info.

  SORT gt_col_info BY tabname fldname.
  READ TABLE node_itab_right TRANSPORTING NO FIELDS WITH KEY node_key = new_node-node_key.
  IF sy-subrc NE 0.
    APPEND new_node TO new_nodes.
    APPEND new_node TO node_itab_right.

    SPLIT new_node-relatkey AT lc_guion INTO lv_child lv_tabname.
    lv_tmp = new_node-node_key.
    REPLACE new_node-relatkey WITH '' INTO lv_tmp.
    CONDENSE lv_tmp.
    lv_fldname = lv_tmp.

    READ TABLE gt_col_info INTO ls_col_info WITH KEY tabname = lv_tabname fldname =  lv_fldname BINARY SEARCH.
    IF sy-subrc = 0.
      APPEND INITIAL LINE TO gt_columns_alv ASSIGNING <fs_col>.
      MOVE-CORRESPONDING ls_col_info TO <fs_col>.
    ENDIF.
  ENDIF.

ENDFORM.                    " ADD_NODE


*&---------------------------------------------------------------------*
*&      Form  ADD_NODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_NEW_NODE  text
*      <--P_NEW_NODES  text
*      <--P_NODE_ITAB_LEFT  text
*----------------------------------------------------------------------*
FORM remove_node CHANGING node_key
                       del_node TYPE treemsnodt"node_str
                       del_nodes LIKE node_itab_right
                       node_itab_right LIKE node_itab_right.

  FIELD-SYMBOLS: <fs_col> LIKE LINE OF gt_columns_alv.

  CONSTANTS: lc_guion TYPE c VALUE '_',
             lc_par1  TYPE c VALUE '(',
             lc_par2  TYPE c VALUE ')'.

  DATA: lv_tabname  TYPE tabname,
        lv_fldname  TYPE fieldname,
        lv_child    TYPE string,
        lv_tmp      TYPE string,
        ls_col_info LIKE LINE OF gt_col_info.

  SORT gt_col_info BY tabname fldname.
  READ TABLE node_itab_right TRANSPORTING NO FIELDS WITH KEY node_key = del_node-node_key.
  IF sy-subrc NE 0.
    APPEND del_node TO del_nodes.

    SPLIT del_node-relatkey AT lc_guion INTO lv_child lv_tabname.
    lv_tmp = del_node-node_key.
    REPLACE del_node-relatkey WITH '' INTO lv_tmp.
    CONDENSE lv_tmp.
    lv_fldname = lv_tmp.

    IF lv_fldname NE c_mandt.
      READ TABLE gt_columns_alv ASSIGNING <fs_col> WITH KEY tabname = lv_tabname fldname =  lv_fldname.
      IF sy-subrc = 0 AND <fs_col>-key_field IS INITIAL.
        DELETE gt_columns_alv INDEX sy-tabix.
      ENDIF.
    ENDIF.
  ENDIF.


ENDFORM.                    " REMOVE_NODE

*&---------------------------------------------------------------------*
*& Form handle_error
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM handle_error  USING   p_process.

  CASE p_process.
    WHEN 'MAIN'.
      MESSAGE e000(zon_cl_oc) WITH  zonta_obj_oc-business_proc DISPLAY LIKE 'E'.
    WHEN 'TABLES'.
      MESSAGE e001(zon_cl_oc) WITH  zonta_obj_oc-business_proc DISPLAY LIKE 'E'.
    WHEN 'COLUMNS'.
      MESSAGE e002(zon_cl_oc) WITH  zonta_obj_oc-business_proc DISPLAY LIKE 'E'.
  ENDCASE.


ENDFORM.                    "handle_error
*&---------------------------------------------------------------------*
*& Form clean_create
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM clean_create .
  CLEAR: "zonta_obj_oc,
         gt_tables_alv[],
         gt_columns_alv[],
         gt_filters_alv[],
         gv_new.

  IF lo_alv_tables IS NOT INITIAL.
    FREE lo_alv_columns.
    FREE lo_alv_tables.
  ENDIF.

ENDFORM.                    "clean_create
*&---------------------------------------------------------------------*
*& Form delete_businessp
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM delete_businessp .

  DATA: lv_error      TYPE boolean,
        lt_relt       TYPE STANDARD TABLE OF zonta_relations,
        ls_tables_alv LIKE LINE OF gt_tables_alv,
        lv_related    TYPE boolean,
        lv_answer     TYPE c.

  DATA: lt_e071    TYPE STANDARD TABLE OF e071,
        lt_e071k   TYPE STANDARD TABLE OF e071k,
        ls_request TYPE trwbo_request,
        lv_order   TYPE e071-trkorr,
        lv_task    TYPE e071-trkorr.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      text_question  = text-t13
    IMPORTING
      answer         = lv_answer
    EXCEPTIONS
      text_not_found = 1
      OTHERS         = 2.
  IF sy-subrc <> 0.
  ENDIF.


  IF lv_answer = '1'.
    IF go_json IS INITIAL.
      CREATE OBJECT go_json.
    ENDIF.

    " Let user choose request
    CALL FUNCTION 'TRINT_ORDER_CHOICE'
      EXPORTING
        wi_order_type          = 'K'
        wi_task_type           = 'S'
        wi_category            = 'SYST'
      IMPORTING
        we_order               = lv_order
        we_task                = lv_task
      TABLES
        wt_e071                = lt_e071
        wt_e071k               = lt_e071k
      EXCEPTIONS
        no_correction_selected = 1
        display_mode           = 2
        object_append_error    = 3
        recursive_call         = 4
        wrong_order_type       = 5
        OTHERS                 = 6.
    IF sy-subrc = 0.
      go_json->set_trkorr( iv_tkorr = lv_task ).
    ENDIF.

    SELECT *
      INTO TABLE lt_relt
      FROM zonta_relations
      WHERE domainv = zonta_obj_oc-domainv
       AND  business_proc = zonta_obj_oc-business_proc.
    IF sy-subrc = 0.
      DATA v_tryoff TYPE c.
      SELECT SINGLE low INTO v_tryoff FROM zonta_oc_param WHERE name = 'SET_TRY_OFF'.
      IF v_tryoff IS NOT INITIAL.
        CALL METHOD go_json->delete_json_ddic
          EXPORTING
            iv_domainv       = zonta_obj_oc-domainv
            iv_business_proc = zonta_obj_oc-business_proc
            iv_delete_entity = abap_true.
*        PERFORM send_error_to_screen.
      ELSE.
        TRY.
            CALL METHOD go_json->delete_json_ddic
              EXPORTING
                iv_domainv       = zonta_obj_oc-domainv
                iv_business_proc = zonta_obj_oc-business_proc
                iv_delete_entity = abap_true.
          CATCH cx_root INTO gx_text.
            PERFORM send_error_to_screen.
        ENDTRY.
      ENDIF.
    ENDIF.


* Check if there are other Entities using the tables
    REFRESH gt_col_alld.
    PERFORM check_related_entity CHANGING lv_related.
    SORT gt_common_ent BY tabname alias_tabname.
    LOOP AT gt_tables_alv INTO ls_tables_alv.
      READ TABLE  gt_common_ent TRANSPORTING NO FIELDS WITH KEY tabname = ls_tables_alv-tabname
                                                                alias_tabname = ls_tables_alv-alias_tabname BINARY SEARCH.
      IF sy-subrc NE 0.
        SELECT * APPENDING TABLE gt_col_alld
          FROM zonta_oc_col_all
         WHERE tabname = ls_tables_alv-tabname
           AND alias_tabname = ls_tables_alv-alias_tabname.
      ENDIF.
    ENDLOOP.

    PERFORM save_deleted_entity_into_tr.

    lv_error = abap_false.


* Check if there are other Entities using the tables
*    PERFORM check_related_entity CHANGING lv_related.
*    SORT gt_common_ent BY tabname alias_tabname.
    LOOP AT gt_tables_alv INTO ls_tables_alv.
      READ TABLE  gt_common_ent TRANSPORTING NO FIELDS WITH KEY tabname = ls_tables_alv-tabname
                                                                alias_tabname = ls_tables_alv-alias_tabname BINARY SEARCH.
      IF sy-subrc NE 0.
        DELETE FROM zonta_oc_conv    WHERE tabname = ls_tables_alv-tabname
                                 AND alias_tabname = ls_tables_alv-alias_tabname.  "March 2026
        DELETE FROM zonta_oc_col_all WHERE tabname = ls_tables_alv-tabname
                                       AND alias_tabname = ls_tables_alv-alias_tabname.
        IF sy-subrc = 0.
          COMMIT WORK.
        ELSE.
          lv_error = abap_true.
        ENDIF.
      ENDIF.
    ENDLOOP.



*  CHECK lv_error = abap_false.
    DELETE FROM zonta_relations WHERE domainv = zonta_obj_oc-domainv
                            AND business_proc = zonta_obj_oc-business_proc.

    DELETE FROM zonta_obj_oc WHERE domainv = zonta_obj_oc-domainv
                            AND business_proc = zonta_obj_oc-business_proc.

    DELETE FROM zonta_oc_franges WHERE domainv = zonta_obj_oc-domainv
                             AND business_proc = zonta_obj_oc-business_proc.

    DELETE FROM zonta_oc_filters WHERE domainv = zonta_obj_oc-domainv
                             AND business_proc = zonta_obj_oc-business_proc.

* Delete authorization if exists
    DELETE FROM zonta_oc_auth WHERE id = zonta_obj_oc-id.
    DELETE FROM zonta_oc_ddic WHERE id = zonta_obj_oc-id.
    COMMIT WORK.

* Save deleted entries into transport request
*    PERFORM save_deleted_entity_into_tr.

    CLEAR zonta_obj_oc.
    SELECT *
      INTO TABLE gt_obj_oc
      FROM zonta_obj_oc.

    PERFORM refresh_grid_display.
  ENDIF.


ENDFORM.                    "delete_businessp
*&---------------------------------------------------------------------*
*& Form refresh_colums_after_change
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_colums_after_change .

  DATA: so_tables   TYPE RANGE OF tabname.

  DATA: lwr_tables TYPE selopt,
        ls_tables  LIKE LINE OF gt_tables_alv.
*  so_tables = value #( FOR sl_tables IN gt_tables_alv (   SIGN = 'I'
*                                                        OPTION = 'EQ'
*                                                           LOW = sl_tables-tabname ) ).



  LOOP AT gt_tables_alv INTO ls_tables.
    lwr_tables-sign    =   'I'.
    lwr_tables-option  =   'EQ'.
    lwr_tables-low     =   ls_tables-tabname.
    APPEND lwr_tables TO so_tables.
  ENDLOOP.

  DELETE gt_columns_alv WHERE tabname NOT IN so_tables[].

ENDFORM.                    "refresh_colums_after_change
*&---------------------------------------------------------------------*
*& Form generate_key_columns
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM generate_key_columns .
  DATA: lt_tables_rel TYPE zontt_relations,
        lt_columns    TYPE zontt_col_all,
        lv_parent     TYPE tm_nodekey,
        ls_tables_alv LIKE LINE OF gt_tables_alv,
        ls_tables_rel LIKE LINE OF lt_tables_rel.

  LOOP AT gt_tables_alv INTO ls_tables_alv.
    CLEAR ls_tables_rel.
    MOVE-CORRESPONDING ls_tables_alv TO ls_tables_rel.
    APPEND ls_tables_rel TO lt_tables_rel.
  ENDLOOP.

  SORT lt_tables_rel BY tabname.
  DELETE ADJACENT DUPLICATES FROM lt_tables_rel COMPARING tabname.

  SORT lt_tables_rel  BY sequence tabname.
  SORT gt_columns_alv BY tabname fldname.
  SORT gt_ex_col      BY tabname fldname.


  DATA: ls_tables   LIKE LINE OF lt_tables_rel,
        ls_col_info LIKE LINE OF gt_col_info,
        ls_columns  LIKE LINE OF gt_columns_alv,
        lv_col_ok   TYPE zabap_boolean.

  FIELD-SYMBOLS: <fs_col> LIKE LINE OF gt_columns_alv.

  LOOP AT lt_tables_rel INTO ls_tables.

    lv_col_ok = abap_false.
    READ TABLE gt_ex_rel TRANSPORTING NO FIELDS WITH KEY tabname = ls_tables-tabname.
    IF sy-subrc = 0.
      LOOP AT gt_ex_col INTO gs_ex_col WHERE tabname = ls_tables-tabname.
        APPEND INITIAL LINE TO gt_columns_alv ASSIGNING <fs_col>.
        MOVE-CORRESPONDING gs_ex_col TO <fs_col>.
*        gs_ex_col-domainv = zonta_obj_oc-domainv.
*        gs_ex_col-business_proc = zonta_obj_oc-business_proc.
        lv_col_ok = abap_true.
      ENDLOOP.
    ELSE.
      lv_col_ok = abap_false.
    ENDIF.

    IF lv_col_ok = abap_false.
*    IF line_exists( gt_columns_alv[ tabname = ls_tables-tabname ] ).
      READ TABLE gt_columns_alv TRANSPORTING NO FIELDS WITH KEY tabname = ls_tables-tabname.
      IF sy-subrc = 0.
        LOOP AT gt_col_info INTO ls_col_info WHERE ( tabname = ls_tables-tabname AND key_field = 'X' )
                                                OR ( tabname = ls_tables-tabname AND fldname = c_mandt ).
          READ TABLE gt_columns_alv INTO ls_columns WITH KEY tabname = ls_tables-tabname fldname = ls_col_info-fldname BINARY SEARCH.
          IF sy-subrc NE 0.
            APPEND INITIAL LINE TO gt_columns_alv ASSIGNING <fs_col>.
            MOVE-CORRESPONDING ls_col_info TO <fs_col>.
          ENDIF.
        ENDLOOP.
      ELSE.
        LOOP AT gt_col_info INTO ls_col_info WHERE tabname = ls_tables-tabname AND key_field = 'X'.
          APPEND INITIAL LINE TO gt_columns_alv ASSIGNING <fs_col>.
          MOVE-CORRESPONDING ls_col_info TO <fs_col>.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDLOOP.

* add parent relation tables
  DATA: ls_tablesa LIKE LINE OF gt_tables_alv.
  LOOP AT gt_tables_alv INTO ls_tablesa WHERE parent_relation IS NOT INITIAL.
*    IF NOT line_exists( gt_columns_alv[ tabname = ls_tablesa-parent_relation fldname = ls_tablesa-field_main ] ).
    READ TABLE gt_columns_alv TRANSPORTING NO FIELDS WITH KEY tabname = ls_tablesa-parent_relation fldname = ls_tablesa-field_main.
    IF sy-subrc NE 0.
      READ TABLE gt_col_info INTO ls_col_info WITH KEY  tabname = ls_tablesa-parent_relation
                                                        fldname = ls_tablesa-field_main.
      IF sy-subrc = 0.
        APPEND INITIAL LINE TO gt_columns_alv ASSIGNING <fs_col>.
        MOVE-CORRESPONDING ls_col_info TO <fs_col>.
      ENDIF.
    ENDIF.
  ENDLOOP.

  SORT gt_columns_alv BY tabname fldname.
  DELETE ADJACENT DUPLICATES FROM gt_columns_alv COMPARING tabname fldname.
  LOOP AT gt_columns_alv ASSIGNING <fs_col> WHERE fldname = c_mandt.
    <fs_col>-key_field = c_x.
  ENDLOOP.

ENDFORM.                    "generate_key_columns
*&---------------------------------------------------------------------*
*& Form add_logo
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM add_logo .

  CALL METHOD cl_ssf_xsf_utilities=>get_bds_graphic_as_bmp
    EXPORTING
      p_object  = 'GRAPHICS'
      p_name    = 'LOGO_OC1' "IMAGE NAME - Image name from SE78
      p_id      = 'BMAP'
      p_btype   = 'BCOL'  "(BMON = black&white, BCOL = colour)
    RECEIVING
      p_bmp     = l_graphic_xstr
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.


  graphic_size = xstrlen( l_graphic_xstr ).
  CHECK graphic_size > 0.

  l_graphic_conv = graphic_size.
  l_graphic_offs = 0.

  WHILE l_graphic_conv > 255.
    graphic_table-line = l_graphic_xstr+l_graphic_offs(255).
    APPEND graphic_table.
    l_graphic_offs = l_graphic_offs + 255.
    l_graphic_conv = l_graphic_conv - 255.
  ENDWHILE.

  graphic_table-line = l_graphic_xstr+l_graphic_offs(l_graphic_conv).
  APPEND graphic_table.

  CALL FUNCTION 'DP_CREATE_URL'
    EXPORTING
      type     = 'image'                                    "#EC NOTEXT
      subtype  = cndp_sap_tab_unknown " 'X-UNKNOWN'
      size     = graphic_size
      lifetime = cndp_lifetime_transaction  "'T'
    TABLES
      data     = graphic_table
    CHANGING
      url      = graphic_url
    EXCEPTIONS
      OTHERS   = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    EXIT.
  ENDIF.

  CREATE OBJECT h_pic_container
    EXPORTING
      container_name = 'CUSTOM'.
  CREATE OBJECT h_picture
    EXPORTING
      parent = h_pic_container.

  CALL METHOD h_picture->load_picture_from_url
    EXPORTING
      url    = graphic_url
    IMPORTING
      result = g_result.



ENDFORM.                    "add_logo


*&---------------------------------------------------------------------*
*& Form validations_before_saving.
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM validations_before_saving.


ENDFORM.                    "validations_before_saving
*&---------------------------------------------------------------------*
*& Form call_filters_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_filters_screen .

  DATA: lt_tables_tmp  TYPE zontt_relations,
        lt_columns_tmp TYPE zontt_col_all,
        lv_nochanges   TYPE boolean.

  DATA: ls_tables_alv  LIKE LINE OF gt_tables_alv,
        ls_tables_tmp  LIKE LINE OF lt_tables_tmp,
        ls_columns_alv LIKE LINE OF gt_columns_alv,
        ls_columns_tmp LIKE LINE OF lt_columns_tmp.

*MOVE-CORRESPONDING gt_tables_alv[] TO lt_tables_tmp[].
  LOOP AT gt_tables_alv INTO ls_tables_alv.
    CLEAR ls_tables_tmp.
    MOVE-CORRESPONDING ls_tables_alv TO ls_tables_tmp.
    APPEND ls_tables_tmp TO lt_tables_tmp.
  ENDLOOP.

*    MOVE-CORRESPONDING gt_columns_alv[] TO lt_columns_tmp[].
  LOOP AT gt_columns_alv INTO ls_columns_alv.
    CLEAR ls_columns_tmp.
    MOVE-CORRESPONDING ls_columns_alv TO ls_columns_tmp.
    APPEND ls_columns_tmp TO lt_columns_tmp.
  ENDLOOP.

  FREE go_cust.
  IF go_cust IS INITIAL.
    CREATE OBJECT go_cust
      EXPORTING
        iv_domainv       = zonta_obj_oc-domainv
        iv_business_proc = zonta_obj_oc-business_proc.
  ENDIF.
  CALL METHOD go_cust->show_filter_options_new
    EXPORTING
      it_relations = lt_tables_tmp[]
      it_columns   = lt_columns_tmp[]
      it_ranges    = gt_franges[]
    IMPORTING
      ev_nochanges = lv_nochanges
      et_ranges    = gt_franges_new[]
      et_filters   = gt_filters_alv[].

  IF lv_nochanges = abap_false.
    gt_franges[] = gt_franges_new[].
*    IF lines( gt_franges_new ) > 0.
    DELETE FROM zonta_oc_franges WHERE domainv = zonta_obj_oc-domainv
                             AND business_proc = zonta_obj_oc-business_proc.
    MODIFY zonta_oc_franges FROM TABLE gt_franges_new.
    IF sy-subrc = 0.
      COMMIT WORK.
    ENDIF.
    DELETE FROM zonta_oc_filters WHERE domainv = zonta_obj_oc-domainv
                             AND business_proc = zonta_obj_oc-business_proc.
    MODIFY zonta_oc_filters FROM TABLE gt_filters_alv.
    IF sy-subrc = 0.
      COMMIT WORK.
    ENDIF.

*    ENDIF.

  ENDIF.

ENDFORM.                    "call_filters_screen
*&---------------------------------------------------------------------*
*& Form init_filters
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init_filters .

  SELECT *
    INTO TABLE gt_filters
    FROM zonta_oc_filters
    WHERE domainv       = zonta_obj_oc-domainv
      AND business_proc = zonta_obj_oc-business_proc
      AND variant       = space.

  SELECT *
    INTO TABLE gt_franges
    FROM zonta_oc_franges
    WHERE domainv       = zonta_obj_oc-domainv
      AND business_proc = zonta_obj_oc-business_proc
      AND variant       = space.
ENDFORM.                    "init_filters
*&---------------------------------------------------------------------*
*&      Form  CALL_SCREEN300
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM call_screen300 .
  IF zonta_obj_oc-domainv IS INITIAL.
    MESSAGE e007(zon_cl_oc) DISPLAY LIKE 'I'.
  ELSE.
*    CALL SCREEN 300.
    PERFORM call_screen_300.
  ENDIF.
ENDFORM.                    "call_screen300
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_log .
  CALL TRANSACTION 'ZONT_OC_LOG'..
ENDFORM.                    "display_log
*&---------------------------------------------------------------------*
*&      Form  VALIDATE_CREATE_BUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM validate_create_bus .

  DATA: ls_obj_oc_tmp TYPE zonta_obj_oc.

  SELECT SINGLE *
    INTO ls_obj_oc_tmp
  FROM zonta_obj_oc
    WHERE domainv       = zonta_obj_oc-domainv
      AND business_proc = zonta_obj_oc-business_proc.
  IF sy-subrc = 0.
    MESSAGE s008(zon_cl_oc) WITH  zonta_obj_oc-business_proc DISPLAY LIKE 'E'.
  ELSE.

    IF zonta_obj_oc-domainv IS INITIAL
    OR zonta_obj_oc-business_proc IS INITIAL.
      MESSAGE i004(zon_cl_oc).
    ELSE.
      zonta_obj_oc-erdat = sy-datum.
      zonta_obj_oc-ernam = sy-uname.
      gv_columnss = gv_tabless = gv_mains = abap_true.
      gv_mode-text = co_display.
      gv_mode-icon_id = '@10@'.
      gv_option = co_change.
*      CALL SCREEN 300.
      PERFORM call_screen_300.
    ENDIF.
  ENDIF.
ENDFORM.                    "validate_create_bus
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_SM37
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_sm37 .
  CALL TRANSACTION 'SM37'.
ENDFORM.                    "display_sm37
*&---------------------------------------------------------------------*
*&      Form  PRINT_LOG_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM print_log_screen .
  DATA: lo_out     TYPE REF TO lcl_output_list,
        lv_message TYPE string.

  IF lo_out IS INITIAL.
    CREATE OBJECT lo_out.
  ENDIF.


  lo_out->write( EXPORTING i_line = 'ONE CONNECT EXECUTION LOG' ).
  lo_out->write( ' ' ).
  lo_out->write( 'Business Process' ).

  DATA: ls_tables LIKE LINE OF gt_tables_alv,
        lt_temp   TYPE STANDARD TABLE OF st_tables_alv.

  lt_temp[] = gt_tables_alv[].

  SORT lt_temp BY tabname.
  DELETE ADJACENT DUPLICATES FROM lt_temp COMPARING tabname.

  LOOP AT lt_temp INTO ls_tables.
    lo_out->write_tab( EXPORTING i_tab = ls_tables ).
  ENDLOOP.


  lo_out->write( ' ' ).
  lo_out->write( ' ' ).
  CONCATENATE 'Total Size Sent' gv_size INTO lv_message SEPARATED BY space.
  lo_out->write( lv_message ).
  CONCATENATE 'Total Number of requests' gv_records INTO lv_message SEPARATED BY space.
  lo_out->write( lv_message ).

  IF gv_records IS INITIAL.
    lv_message = '***ERROR WHILE SENDING, NO RECORDS WERE SENT***'.
    lo_out->write( lv_message ).
  ENDIF.

  lo_out->write( ' ' ).
  lo_out->write( ' ' ).
  lo_out->write( '**********Please validate complete log in Menu: Execution-Display log************' ).
  lo_out->display( ).



ENDFORM.                    "print_log_screen
*&---------------------------------------------------------------------*
*&      Form  LOAD_EXCEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM load_excel .
  DATA: lv_begr   TYPE i VALUE 1,
        lv_begc   TYPE i VALUE 1,
        lv_endc   TYPE i VALUE 13,
        lv_entity TYPE zonta_obj_oc-business_proc, "CECHAVARRIA 13/08/2025
        lv_endr   TYPE i VALUE 10000.

  DATA: gt_out     TYPE TABLE OF zonst_oc_excel_tableline.
  DATA: lv_field TYPE char15,
        ls_rec   TYPE ty_rec.
  DATA: lt_wb    TYPE TABLE OF zonst_oc_excel_tableline,
        lt_row   TYPE TABLE OF zonst_oc_excel_tableline,
        ls_wb    TYPE zonst_oc_excel_tableline,
        ls_out   TYPE zonst_oc_excel_tableline,
        ls_row   TYPE zonst_oc_excel_tableline,
        lv_tabrw TYPE sy-tabix,
        lv_exit  TYPE c.

  FIELD-SYMBOLS <fs_field> TYPE any.
  CLEAR: gt_recs[], gt_out[].

  CALL FUNCTION 'ZONFM_OC_READ_EXCEL'
    EXPORTING
      filename                = gv_file
      i_begin_col             = lv_begc
      i_begin_row             = lv_begr
      i_end_col               = lv_endc
      i_end_row               = lv_endr
      sheet                   = gv_workb
    TABLES
      output_int              = gt_out
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.
  IF sy-subrc EQ 0.
    IF lines( gt_out ) = 0.
      MESSAGE e024(zon_cl_oc) DISPLAY LIKE 'I'.
      CALL SCREEN 100.
    ENDIF.

    CHECK gt_out[] IS NOT INITIAL.

* DB insert 06/11
    IF r_customizing = abap_true.
      DELETE gt_out WHERE col > 12.
    ELSEIF r_columns = abap_true.
      DELETE gt_out WHERE col > 7.
    ELSE.
      DELETE gt_out WHERE col > 8.
    ENDIF.
* DB insert 06/11

    DELETE gt_out WHERE row EQ '0001'.
    lt_wb[]  = gt_out[].
    lt_row[] = gt_out[].
    SORT lt_wb BY pestania.
    DELETE ADJACENT DUPLICATES FROM lt_wb COMPARING pestania.


    SORT lt_row BY pestania row.
*    DELETE lt_row WHERE value NE 'X' AND col NE '0001'.
    DELETE ADJACENT DUPLICATES FROM lt_row COMPARING pestania row.

    LOOP AT lt_wb INTO ls_wb.
      READ TABLE lt_row TRANSPORTING NO FIELDS WITH KEY pestania = ls_wb-pestania.
      IF sy-subrc EQ 0.
        lv_tabrw = sy-tabix.
        LOOP AT lt_row INTO ls_row FROM lv_tabrw.
          IF ls_row-pestania EQ ls_wb-pestania.
            READ TABLE gt_out TRANSPORTING NO FIELDS WITH KEY pestania = ls_row-pestania
                                                             row = ls_row-row.
            IF sy-subrc EQ 0.
              lv_tabrw = sy-tabix.
              LOOP AT gt_out INTO ls_out FROM lv_tabrw.
                IF ls_out-row EQ ls_row-row.
                  ls_rec-workb = ls_row-pestania.
                  ls_rec-row  = ls_row-row.
                  CONCATENATE 'LS_REC-F' ls_out-col INTO lv_field.
                  ASSIGN (lv_field) TO <fs_field> .
                  <fs_field> = ls_out-value.
                  lv_exit = ' '.
                ELSE.
                  lv_exit = 'X'.
                  APPEND ls_rec TO gt_recs.
                  CLEAR ls_rec.
                  EXIT.
                ENDIF.
              ENDLOOP.
              IF lv_exit = ' '.
                APPEND ls_rec TO gt_recs.
                CLEAR ls_rec.
              ENDIF.
            ENDIF.
          ELSE.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
  ENDIF.

*BEGIN CECHAVARRIA 13/08/2025
  IF gv_new_excel = abap_true AND r_customizing = abap_true.  "++DB filt
    READ TABLE gt_recs INTO ls_rec INDEX 1.
    IF sy-subrc EQ 0.
      SELECT SINGLE business_proc
        FROM zonta_obj_oc
         INTO lv_entity
        WHERE business_proc = ls_rec-f0002.

      IF sy-subrc EQ 0.
        CLEAR gt_recs[].
        MESSAGE e039(zon_cl_oc) WITH  ls_rec-f0002 DISPLAY LIKE 'E'.
      ENDIF.
    ENDIF.
  ENDIF.
  CLEAR ls_rec.
*END CECHAVARRIA 13/08/2025
ENDFORM.                    "load_excel
*&---------------------------------------------------------------------*
*&      Form  CALL_SCREEN600
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM call_screen600 .
  CALL SCREEN 600 STARTING AT 2 15
       ENDING AT 120 25.
ENDFORM.                    "call_screen600

*&---------------------------------------------------------------------*
*&      Form  CALL_SCREEN602
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM call_screen602 .
  CALL SCREEN 602 STARTING AT 26 6
       ENDING AT 115 10.
ENDFORM.                    "call_screen602

*&---------------------------------------------------------------------*
*&      Form  CALL_SCREEN603
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM call_screen603 .
  gv_cloned_domain = zonta_obj_oc-domainv.
  CALL SCREEN 603 STARTING AT 26 6
       ENDING AT 120 27.
ENDFORM.                    "call_screen603
*&---------------------------------------------------------------------*
*&      Form  LOAD_CUSTOMIZING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM load_customizing .

  DATA: ls_rec       TYPE ty_rec,
        ls_relations TYPE zonta_relations,
        lt_relations TYPE STANDARD TABLE OF zonta_relations,
        lt_cust      TYPE STANDARD TABLE OF zonta_relations,
        lt_obj       TYPE STANDARD TABLE OF zonta_obj_oc,
        lt_obj_new   TYPE STANDARD TABLE OF zonta_obj_oc,
        ls_obj       TYPE zonta_obj_oc,
        ls_cust      TYPE zonta_relations,
        lv_id        TYPE zonta_obj_oc-id,
        lv_ind       TYPE i,
        lv_messs     TYPE char100,
        lv_error     TYPE boolean,
        lv_error1    TYPE boolean,
        lt_dfies_tab TYPE TABLE OF   dfies,
        ls_dfies_tab TYPE  dfies.

  FIELD-SYMBOLS: <fs_rel> TYPE zonta_relations.

  LOOP AT gt_recs INTO ls_rec.
    lv_ind = sy-tabix.
    ls_relations-mandt = sy-mandt.
    MOVE ls_rec-f0001 TO ls_relations-domainv.
    MOVE ls_rec-f0002 TO ls_relations-business_proc.
    MOVE ls_rec-f0003 TO ls_relations-tabname.
    MOVE ls_rec-f0004 TO ls_relations-field_main.
    MOVE ls_rec-f0005 TO ls_relations-field_sec.
    MOVE ls_rec-f0006 TO ls_relations-parent_relation.
    MOVE ls_rec-f0007 TO ls_relations-join_type.
    MOVE ls_rec-f0008 TO ls_relations-sequence.
    MOVE ls_rec-f0009 TO ls_relations-subsequence.
    MOVE ls_rec-f0010 TO ls_relations-levelv.
    MOVE ls_rec-f0011 TO ls_relations-alias_tabname.
    MOVE ls_rec-f0012 TO ls_relations-description_table.
**VALIDAR TABLA

    CLEAR lt_dfies_tab[].
    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname        = ls_relations-tabname
      TABLES
        dfies_tab      = lt_dfies_tab
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.


** 01.JUL.25 FRG VALIDACION QUE LA TABLA EXISTA INICIA
    IF sy-subrc <> 0.
*   Aktion abgebrochen
      CONCATENATE 'Table' ls_relations-tabname 'Not Found' INTO lv_messs SEPARATED BY space.
      MESSAGE lv_messs TYPE 'I'.
      EXIT.
    ELSE.
      IF lv_ind = 1.
        IF ls_relations-field_main IS NOT INITIAL.
          READ TABLE lt_dfies_tab INTO ls_dfies_tab WITH KEY fieldname = ls_relations-field_main.
          IF sy-subrc <> 0.
            CONCATENATE 'The Field' ls_relations-field_main  'for Table' ls_relations-tabname 'Not Found'INTO lv_messs SEPARATED BY space.
            MESSAGE lv_messs TYPE 'A'.
            EXIT.
          ENDIF.
        ENDIF.
      ELSE.
        READ TABLE lt_dfies_tab INTO ls_dfies_tab WITH KEY fieldname = ls_relations-field_sec.
        IF sy-subrc <> 0.
          CONCATENATE 'The Field' ls_relations-field_sec  'for Table' ls_relations-tabname 'Not Found'INTO lv_messs SEPARATED BY space.
          MESSAGE lv_messs TYPE 'A'.
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.
** 01.JUL.25 FRG VALIDACION QUE LA TABLA EXISTA INICIA
    APPEND ls_relations TO lt_relations.
  ENDLOOP.


  lt_cust[] = lt_relations[].
  SORT lt_cust BY domainv business_proc.
  DELETE ADJACENT DUPLICATES FROM lt_cust COMPARING domainv business_proc.
  LOOP AT lt_cust INTO ls_cust WHERE  domainv IS INITIAL OR business_proc IS INITIAL.
    lv_error = abap_true.
    EXIT.
  ENDLOOP.

* DB added 06/11
*****  IF lines( lt_relations ) > 0 AND lv_error = abap_false.
*****    SELECT tabname
*****      INTO TABLE @DATA(lt_tabnames)
*****      FROM dd02l
*****      FOR ALL ENTRIES IN @lt_relations
*****      WHERE tabname = @lt_relations-tabname
*****         OR tabname = @lt_relations-parent_relation.
*****    SELECT tabname
*****      APPENDING TABLE @lt_tabnames
*****      FROM dd03l
*****      FOR ALL ENTRIES IN @lt_relations
*****      WHERE tabname = @lt_relations-tabname
*****         OR tabname = @lt_relations-parent_relation.
*****    SORT lt_tabnames BY tabname.
*****    DELETE ADJACENT DUPLICATES FROM lt_tabnames COMPARING tabname.
*****    LOOP AT lt_relations INTO ls_relations.
*****      READ TABLE lt_tabnames TRANSPORTING NO FIELDS WITH KEY tabname = ls_relations-tabname BINARY SEARCH.
*****      IF sy-subrc = 0.
*****        IF ls_relations-parent_relation IS NOT INITIAL.
*****          READ TABLE lt_tabnames TRANSPORTING NO FIELDS WITH KEY tabname = ls_relations-parent_relation BINARY SEARCH.
*****          IF sy-subrc NE 0.
*****            lv_error1 = abap_true.
*****            MESSAGE e050(zon_cl_oc) WITH ls_relations-parent_relation  DISPLAY LIKE 'I'.
*****            EXIT.
*****          ENDIF.
*****        ENDIF.
*****      ELSE.
*****        lv_error1 = abap_true.
*****        MESSAGE e050(zon_cl_oc) WITH ls_relations-tabname  DISPLAY LIKE 'I'.
*****        EXIT.
*****      ENDIF.
*****    ENDLOOP.
*****  ENDIF.
* End of DB added 06/11
  CHECK lv_error1 = abap_false.

  IF lv_error = abap_true.
    MESSAGE e009(zon_cl_oc)  DISPLAY LIKE 'I'.
  ELSE.
    IF lines( lt_cust ) > 0.
      SELECT *
      INTO TABLE lt_obj
      FROM zonta_obj_oc
        FOR ALL ENTRIES IN lt_cust
      WHERE domainv = lt_cust-domainv
        AND business_proc = lt_cust-business_proc.
      SORT lt_obj BY domainv business_proc.
    ENDIF.

*    SELECT MAX( id )
*     INTO lv_id
*     FROM zonta_obj_oc.
    PERFORM get_next_range USING c_rentity CHANGING lv_id.

    IF lv_id = 0 OR lv_id IS INITIAL.
      lv_id = 1.
*    ELSE.
*      lv_id = lv_id + 1.
    ENDIF.

* First, validate entry in Main customizing table ZONTA_OBJ_OC
    LOOP AT lt_cust INTO ls_cust.
      READ TABLE lt_obj INTO ls_obj WITH KEY domainv = ls_cust-domainv business_proc = ls_cust-business_proc BINARY SEARCH.
* Already exist
      IF sy-subrc = 0.
*    We do not need to do something on this  zonta_obj_oc table
        LOOP AT lt_relations ASSIGNING <fs_rel> WHERE domainv = ls_cust-domainv AND business_proc = ls_cust-business_proc.
          <fs_rel>-id = ls_cust-id.
        ENDLOOP.
* Create the entry first
      ELSE.


        ls_obj-mandt         = sy-mandt.
        ls_obj-id            = lv_id.
        ls_obj-domainv       = ls_cust-domainv.
        ls_obj-business_proc = ls_cust-business_proc.
        ls_obj-erdat         = sy-datum.
        ls_obj-ernam         = sy-uname.
        ls_obj-no_registros  = '100'.
        ls_obj-log_type      = c_slg1.
        APPEND ls_obj TO lt_obj_new.

        LOOP AT lt_relations ASSIGNING <fs_rel> WHERE domainv = ls_cust-domainv AND business_proc = ls_cust-business_proc.
          <fs_rel>-id = lv_id.
        ENDLOOP.
        lv_id = lv_id + 1.
      ENDIF.
    ENDLOOP.

    PERFORM check_entity_name_excel TABLES lt_obj_new lt_relations.  "DB NAME



    MODIFY zonta_obj_oc FROM TABLE lt_obj_new.
    IF sy-subrc = 0.
      COMMIT WORK.
    ELSE.
      lv_error = abap_true.
    ENDIF.

    IF lv_error = abap_true.
      MESSAGE e010(zon_cl_oc)  DISPLAY LIKE 'I'.
* Now, add the entries in table ZONTA_RELATIONS
    ELSE.

      FIELD-SYMBOLS: <fs_sel> TYPE zonta_relations.
      DATA: ls_relt TYPE zonta_relations.
      LOOP AT lt_relations ASSIGNING <fs_rel> WHERE sequence = 1.
        READ TABLE lt_relations INTO ls_relt WITH KEY domainv = <fs_rel>-domainv
                                                      business_proc = <fs_rel>-business_proc
                                                      sequence = 2.
        IF sy-subrc = 0.
          <fs_rel>-field_main = ls_relt-field_sec.
        ENDIF.
      ENDLOOP.



      MODIFY zonta_relations FROM TABLE lt_relations.
      IF sy-subrc = 0.
        COMMIT WORK.
      ELSE.
        lv_error = abap_true.
      ENDIF.
    ENDIF.

  ENDIF.

  IF lv_error = abap_false.
    MESSAGE s011(zon_cl_oc)  DISPLAY LIKE 'I'.
  ENDIF.
ENDFORM.                    "load_customizing

*&---------------------------------------------------------------------*
*&      Form  LOAD_COLUMNS_OK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM load_columns .

  CONSTANTS: c_x      TYPE c VALUE 'X',
             c_mandt  TYPE c LENGTH 5 VALUE 'MANDT',
             c_mandtl TYPE c LENGTH 5 VALUE 'mandt',
             c_999    TYPE zonde_oc_level VALUE '999'.


  DATA: ls_rec           TYPE ty_rec,
        ls_relations     TYPE zonta_relations,
        lt_relations     TYPE STANDARD TABLE OF zonta_relations,
        lt_relations_all TYPE STANDARD TABLE OF zonta_relations,
        lt_tables        TYPE STANDARD TABLE OF zonta_relations,
        lt_rel_u         TYPE STANDARD TABLE OF zonta_relations,
        lt_columns       TYPE STANDARD TABLE OF zonta_oc_col_all,
        lt_columns_tmp   TYPE STANDARD TABLE OF zonta_oc_col_all,
        lt_col_gral      TYPE STANDARD TABLE OF zonta_oc_col_all,
        lt_col_gral2     TYPE STANDARD TABLE OF zonta_oc_col_all,
        lt_col_gral_all  TYPE STANDARD TABLE OF zonta_oc_col_all,
        lt_columns_save  TYPE STANDARD TABLE OF zonta_oc_col_all,
        lt_keys_save     TYPE STANDARD TABLE OF zonta_oc_col_all,
        lt_columns_t     TYPE STANDARD TABLE OF zonta_oc_col_all,
        lt_columns_or    TYPE STANDARD TABLE OF zonta_oc_col_all,
        lt_col_un        TYPE STANDARD TABLE OF zonta_oc_col_all,
        ls_col_un        TYPE zonta_oc_col_all,
        lt_obj           TYPE STANDARD TABLE OF zonta_obj_oc,
        lt_keys          TYPE STANDARD TABLE OF zonta_oc_col_all,
        lt_fields        TYPE STANDARD TABLE OF zonta_oc_col_all,
        lt_reserved      TYPE STANDARD TABLE OF zonta_oc_reserv,
        lt_ex_col_all    TYPE STANDARD TABLE OF zonta_oc_col_all,
        lt_ex_col        TYPE STANDARD TABLE OF zonta_oc_col_all,
        lt_ex_rel_all    TYPE STANDARD TABLE OF zonta_relations,
        lt_ex_rel        TYPE STANDARD TABLE OF zonta_relations,
        lt_ex_rel_allt   TYPE STANDARD TABLE OF zonta_relations,
        lt_entities      TYPE STANDARD TABLE OF zonta_obj_oc,
        ls_ex_rel_all    TYPE zonta_relations,
        ls_filters       TYPE zonta_oc_filters,
        ls_reserved      TYPE zonta_oc_reserv,
        ls_rel           TYPE zonta_relations,
        ls_keys          TYPE zonta_oc_col_all,
        ls_fields        TYPE zonta_oc_col_all,
        ls_col_gral      TYPE zonta_oc_col_all,
        ls_obj           TYPE zonta_obj_oc,
        ls_columns       TYPE zonta_oc_col_all,
        ls_columns_or    TYPE zonta_oc_col_all,
        ls_cust          TYPE zonta_relations,
        lv_id            TYPE zonta_obj_oc-id,
        lv_error         TYPE boolean,
        lv_error_empty   TYPE boolean,
        lv_err_no_rel    TYPE boolean,
        lv_load          TYPE boolean,
        lv_id_col        TYPE zonta_oc_col_all-id_column,
        lv_load_global   TYPE boolean,
        lv_popup         TYPE boolean,
        lv_ind           TYPE i,
        lv_len           TYPE i,
        lv_answer        TYPE c.

  FIELD-SYMBOLS: <fs_col>     TYPE zonta_oc_col_all,
                 <fs_rel>     TYPE zonta_relations,
                 <fs_col_alv> LIKE LINE OF gt_columns_alv.


  LOOP AT gt_recs INTO ls_rec.
    ls_columns-mandt = sy-mandt.
*    MOVE ls_rec-f0001 TO ls_columns-domainv.
*    MOVE ls_rec-f0002 TO ls_columns-business_proc.
    MOVE ls_rec-f0001 TO ls_columns-tabname.
    MOVE ls_rec-f0002 TO ls_columns-alias_tabname.
    MOVE ls_rec-f0003 TO ls_columns-fldname.
    lv_len = strlen( ls_rec-f0004 ).
    IF ls_rec-f0004 CA '0123456789' or  ls_rec-f0004 IS INITIAL.
*      lv_fldname+0(1) = c_undersc.
      clear ls_columns-alias_fldname.

    else.
      MOVE ls_rec-f0004 TO ls_columns-alias_fldname.
    ENDIF.

    MOVE ls_rec-f0005 TO ls_columns-key_field.
    MOVE ls_rec-f0006 TO ls_columns-selection_field.
    MOVE ls_rec-f0007 TO ls_columns-description_field.
    APPEND ls_columns TO lt_columns.
  ENDLOOP.


  SELECT *
    INTO TABLE lt_reserved
    FROM zonta_oc_reserv.

  lt_col_un[] = lt_columns[].
***  SORT lt_col_un BY tabname alias_tabname. "domainv business_proc tabname.
  SORT lt_col_un BY tabname alias_tabname KEY_FIELD DESCENDING. "domainv business_proc tabname.
  DELETE ADJACENT DUPLICATES FROM lt_col_un COMPARING tabname alias_tabname. "domainv business_proc tabname.

  LOOP AT lt_col_un INTO ls_col_un.
    APPEND INITIAL LINE TO lt_relations ASSIGNING <fs_rel>.
    MOVE-CORRESPONDING ls_col_un TO <fs_rel>.
  ENDLOOP.


  IF lines( lt_col_un ) > 0.
*    SELECT *
*      FROM zonta_relations
*      INTO TABLE lt_relations
*      FOR ALL ENTRIES IN lt_col_un
*      WHERE
*           tabname = lt_col_un-tabname
*       AND alias_tabname = lt_col_un-alias_tabname.
    SORT lt_relations BY domainv business_proc tabname.
    lt_relations_all[] = lt_relations[].
    gt_tables[] = lt_relations[].

    IF go_cust IS INITIAL.
      CREATE OBJECT go_cust
        EXPORTING
          iv_domainv       = zonta_obj_oc-domainv
          iv_business_proc = zonta_obj_oc-business_proc.
    ENDIF.

    CALL METHOD go_cust->fill_info_field_new
      EXPORTING
        it_tables       = lt_relations[]
        it_columns      = gt_columns_alv[]
      IMPORTING
        et_columns      = lt_col_gral[]
        et_existing_rel = gt_ex_rel[]
        et_existing_col = gt_ex_col[].

    lt_ex_col_all[] = gt_ex_col[].
    lt_ex_rel_all[] = gt_ex_rel[].

    lt_ex_col[] = gt_ex_col[].
    lt_ex_rel[] = gt_ex_rel[].

    gt_columns[] = lt_col_gral[].
    lt_col_gral_all[] = lt_col_gral[].
    lt_tables[] = lt_relations_all[].
    SORT lt_tables BY tabname.
    DELETE ADJACENT DUPLICATES FROM lt_tables COMPARING tabname.

    CALL METHOD go_cust->get_table_keys_new
      EXPORTING
        it_tables = lt_tables[]
      IMPORTING
        et_keys   = lt_keys[]
        et_fields = lt_fields[].
    SORT lt_keys BY tabname fldname.
    SORT lt_fields BY tabname fldname.
  ENDIF.

  SORT lt_columns BY tabname fldname.
  SORT lt_col_gral BY tabname fldname.

  IF zonta_obj_oc-domainv = c_any.
    LOOP AT lt_columns INTO ls_columns.
      APPEND INITIAL LINE TO lt_columns_save ASSIGNING <fs_col>.
      MOVE-CORRESPONDING ls_columns TO <fs_col>.
    ENDLOOP.
  ELSE.

    lt_rel_u[] = lt_relations[].
    SORT lt_rel_u BY domainv business_proc tabname.
    DELETE ADJACENT DUPLICATES FROM lt_rel_u COMPARING domainv business_proc tabname.


    LOOP AT lt_rel_u INTO ls_relations.
      CLEAR lt_relations[].
      APPEND ls_relations TO lt_relations.

      CLEAR go_cust.
      CREATE OBJECT go_cust
        EXPORTING
          iv_domainv       = ls_relations-domainv
          iv_business_proc = ls_relations-business_proc.

      CALL METHOD go_cust->fill_info_field_new
        EXPORTING
          it_tables       = lt_relations[]
          it_columns      = gt_columns_alv[]
          iv_alias        = abap_true
        IMPORTING
          et_columns      = lt_col_gral[]
          et_existing_rel = gt_ex_rel[]
          et_existing_col = gt_ex_col[].

      SORT lt_col_gral BY tabname fldname.
      append LINES OF lt_col_gral[] to lt_col_gral2[].
      SORT lt_col_gral2 BY tabname fldname.
      delete ADJACENT DUPLICATES FROM lt_col_gral2 COMPARING tabname fldname.

      IF lines( gt_ex_col ) > 0.
        LOOP AT gt_ex_col INTO gs_ex_col.
          APPEND INITIAL LINE TO lt_columns_save ASSIGNING <fs_col>.
          MOVE-CORRESPONDING gs_ex_col TO <fs_col>.
*          <fs_col>-domainv = ls_relations-domainv.
*          <fs_col>-business_proc = ls_relations-business_proc.

          SORT lt_columns BY tabname alias_tabname fldname. "domainv business_proc tabname fldname.
          READ TABLE lt_columns INTO ls_columns_or WITH KEY
*                                                            domainv       = <fs_col>-domainv
*                                                            business_proc = <fs_col>-business_proc
                                                            tabname       = <fs_col>-tabname
                                                            alias_tabname = <fs_col>-alias_tabname
                                                            fldname       = <fs_col>-fldname BINARY SEARCH.
          IF sy-subrc = 0.
            DELETE lt_columns WHERE
*                                    domainv = ls_columns_or-domainv
*                                AND business_proc = ls_columns_or-business_proc
                                    tabname       = ls_columns_or-tabname
                                AND alias_tabname = ls_columns_or-alias_tabname
                                AND fldname       = ls_columns_or-fldname.
            DELETE lt_ex_col_all WHERE
*                                    domainv = ls_columns_or-domainv
*                                AND business_proc = ls_columns_or-business_proc
                                    tabname       = ls_columns_or-tabname
                                AND alias_tabname = ls_columns_or-alias_tabname
                                AND fldname       = ls_columns_or-fldname..
          ENDIF.
        ENDLOOP.
      ELSE.
        LOOP AT lt_keys INTO ls_keys WHERE tabname = ls_relations-tabname.
          APPEND INITIAL LINE TO lt_columns_save ASSIGNING <fs_col>.
          READ TABLE lt_columns INTO ls_columns WITH KEY tabname = ls_relations-tabname fldname = ls_keys-fldname BINARY SEARCH.
          IF sy-subrc = 0.
            lv_ind = sy-tabix.
            MOVE-CORRESPONDING ls_columns TO <fs_col>.
            READ TABLE lt_reserved INTO ls_reserved WITH KEY name = <fs_col>-alias_fldname.
            IF sy-subrc = 0.
              CONCATENATE <fs_col>-alias_fldname c_guion INTO <fs_col>-alias_fldname.
            ENDIF.
            DELETE lt_columns INDEX lv_ind.
          ELSE.
*            <fs_col>-domainv = ls_relations-domainv.
*            <fs_col>-business_proc = ls_relations-business_proc.
            <fs_col>-tabname = ls_keys-tabname.
            <fs_col>-tabname = ls_keys-tabname.
            <fs_col>-fldname = ls_keys-fldname.
          ENDIF.
          IF  <fs_col>-fldname EQ c_mandt
          OR  <fs_col>-fldname EQ c_mandtl.
            CLEAR <fs_col>-key_field.
            CLEAR <fs_col>-selection_field.
          ELSE.
            <fs_col>-key_field       = c_x.
            <fs_col>-selection_field = c_x.
          ENDIF.
          IF <fs_col>-description_field IS INITIAL.
            READ TABLE lt_fields INTO ls_fields WITH KEY tabname = <fs_col>-tabname fldname = <fs_col>-fldname BINARY SEARCH.
            IF sy-subrc = 0.
              <fs_col>-description_field = ls_fields-description_field.
            ENDIF.
          ENDIF.
          IF <fs_col>-alias_fldname IS INITIAL.
            READ TABLE lt_col_gral INTO ls_col_gral WITH KEY tabname = <fs_col>-tabname fldname = <fs_col>-fldname BINARY SEARCH.
            IF sy-subrc = 0.
              <fs_col>-alias_fldname = ls_col_gral-alias_fldname.
            ENDIF.
          ENDIF.
          IF <fs_col>-alias_fldname IS INITIAL.
            READ TABLE lt_col_gral2 INTO ls_col_gral WITH KEY tabname = <fs_col>-tabname fldname = <fs_col>-fldname BINARY SEARCH.
            IF sy-subrc = 0.
              <fs_col>-alias_fldname = ls_col_gral-alias_fldname.
            ENDIF.
          ENDIF.
          <fs_col>-mandt = sy-mandt.
          <fs_col>-positionf = ls_keys-positionf.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

*    lt_ex_rel_allt[] = lt_ex_rel_all[].
*    REFRESH lt_ex_rel_all.
*    LOOP AT lt_relations INTO ls_relations.
*      LOOP AT lt_ex_rel_allt INTO ls_ex_rel_all WHERE tabname = ls_relations-tabname
*                                                AND alias_tabname = ls_relations-alias_tabname.
*        IF ls_ex_rel_all-domainv NE ls_relations-domainv
*        OR ls_ex_rel_all-business_proc NE ls_relations-business_proc.
*          APPEND INITIAL LINE TO lt_ex_rel_all ASSIGNING <fs_rel>.
*          MOVE-CORRESPONDING ls_ex_rel_all TO <fs_rel>.
*        ENDIF.
*      ENDLOOP.
*    ENDLOOP.

*    IF lines( gt_ex_col ) = 0.
    CLEAR: lv_load_global,
           lv_popup.
    lt_ex_col_all[] = lt_ex_col[].
    lt_ex_rel_all[] = lt_ex_rel[].
    SORT lt_ex_col_all BY tabname alias_tabname fldname. "domainv business_proc tabname fldname.
*    SORT lt_ex_col_all BY tabname.
    SORT lt_columns_save BY tabname alias_tabname tabname fldname. "domainv business_proc tabname fldname.

    lt_columns_tmp[] = lt_columns[].
    SORT lt_columns_tmp BY tabname alias_tabname.
    DELETE ADJACENT DUPLICATES FROM lt_columns_tmp COMPARING tabname alias_tabname.
    SORT lt_ex_rel_all BY tabname alias_tabname.
    LOOP AT lt_columns_tmp INTO ls_columns.
      READ TABLE lt_ex_rel_all ASSIGNING <fs_rel> WITH KEY tabname = ls_columns-tabname
                                                        alias_tabname = ls_columns-alias_tabname.
      IF sy-subrc = 0.
        <fs_rel>-id = c_999.
      ENDIF.
    ENDLOOP.
    DELETE lt_ex_rel_all WHERE id = c_999.

    SORT lt_ex_rel_all BY tabname..
    lt_relations[] = lt_relations_all[].
    LOOP AT lt_columns INTO ls_columns.
      lv_load = abap_false.
*      READ TABLE lt_ex_col_all TRANSPORTING NO FIELDS WITH KEY tabname = ls_columns-tabname BINARY SEARCH.
      READ TABLE lt_ex_rel_all  ASSIGNING <fs_rel> WITH KEY tabname = ls_columns-tabname BINARY SEARCH.
      IF sy-subrc = 0.
        READ TABLE lt_ex_col_all TRANSPORTING NO FIELDS WITH KEY     tabname = ls_columns-tabname
                                                               alias_tabname = ls_columns-alias_tabname
                                                                     fldname = ls_columns-fldname BINARY SEARCH.
        IF sy-subrc NE 0.
          IF lv_popup = abap_true.
            lv_load = lv_load_global.
          ELSE.
            CALL FUNCTION 'POPUP_TO_DECIDE'
              EXPORTING
                textline1    = text-t11
                textline2    = text-t12
                text_option1 = text-g02
                text_option2 = text-g03
                titel        = text-g04
              IMPORTING
                answer       = lv_answer.
            IF lv_answer = '1'.
              lv_load = abap_true.
              <fs_rel>-levelv = c_999.
              lv_popup = abap_true.
            ELSE.
              lv_load = abap_false.
            ENDIF.
            lv_load_global = lv_load.
            lv_popup = abap_true.
          ENDIF.
        ELSE.
          lv_load = abap_true.
        ENDIF.
      ELSE.
        lv_load = abap_true.
      ENDIF.
      IF lv_load = abap_true.
        READ TABLE lt_columns_save TRANSPORTING NO FIELDS WITH KEY tabname = ls_columns-tabname
                                                                   alias_tabname = ls_columns-alias_tabname
                                                                   fldname = ls_columns-fldname BINARY SEARCH.
        IF sy-subrc NE 0.
          READ TABLE lt_reserved INTO ls_reserved WITH KEY name = ls_columns-alias_fldname.
          IF sy-subrc = 0.
            CONCATENATE ls_columns-alias_fldname c_guion INTO ls_columns-alias_fldname.
          ENDIF.
          READ TABLE lt_relations INTO ls_relations WITH KEY tabname = ls_columns-tabname
                                                           alias_tabname = ls_columns-alias_tabname BINARY SEARCH.
          IF sy-subrc = 0.
            APPEND INITIAL LINE TO lt_columns_save ASSIGNING <fs_col>.
            MOVE-CORRESPONDING ls_columns TO <fs_col>.
            READ TABLE lt_keys INTO ls_keys WITH KEY tabname = ls_columns-tabname fldname = ls_columns-fldname BINARY SEARCH.
            IF sy-subrc NE 0.
              CLEAR <fs_col>-key_field.
            ENDIF.
*            READ TABLE lt_col_gral INTO ls_col_gral WITH KEY tabname = ls_columns-tabname fldname = ls_columns-fldname.
            READ TABLE gt_col_info INTO gs_col_info WITH KEY tabname = ls_columns-tabname fldname = ls_columns-fldname.
            IF sy-subrc EQ 0.
              <fs_col>-positionf = gs_col_info-positionf.
            ELSE.
              CLEAR gs_col_info.
            ENDIF.


            IF <fs_col>-description_field IS INITIAL.
              READ TABLE lt_fields INTO ls_fields WITH KEY tabname = ls_columns-tabname fldname = ls_columns-fldname BINARY SEARCH.
              IF sy-subrc = 0.
                <fs_col>-description_field = ls_fields-description_field.
              ENDIF.
            ENDIF.
            IF <fs_col>-alias_fldname IS INITIAL.
              READ TABLE lt_col_gral INTO ls_col_gral WITH KEY tabname = <fs_col>-tabname fldname = <fs_col>-fldname BINARY SEARCH.
              IF sy-subrc = 0.
                <fs_col>-alias_fldname = ls_col_gral-alias_fldname.
              ENDIF.
            ENDIF.
            IF <fs_col>-alias_fldname IS INITIAL.
              READ TABLE lt_col_gral2 INTO ls_col_gral WITH KEY tabname = <fs_col>-tabname fldname = <fs_col>-fldname BINARY SEARCH.
              IF sy-subrc = 0.
                <fs_col>-alias_fldname = ls_col_gral-alias_fldname.
              ENDIF.
            ENDIF.
            <fs_col>-mandt = sy-mandt.
          ELSE.
            lv_err_no_rel = abap_true.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

    PERFORM add_secondary_keys TABLES lt_columns_save[].



* Remove entries which do not exist in this environment
    SORT lt_col_gral_all BY tabname fldname.
    LOOP AT lt_columns_save ASSIGNING <fs_col>.
      READ TABLE lt_col_gral_all INTO ls_col_gral WITH KEY tabname = <fs_col>-tabname fldname = <fs_col>-fldname BINARY SEARCH.
      IF sy-subrc NE 0.
        DELETE lt_columns_save WHERE tabname = <fs_col>-tabname AND fldname = <fs_col>-fldname.
      ENDIF.
    ENDLOOP.

    PERFORM validate_alias_table TABLES lt_columns_save.
    PERFORM check_alias_fldname TABLES lt_columns_save[].
*    ENDIF.  ""
  ENDIF.



  lt_columns_t[] = lt_columns_save[].
  SORT lt_columns_t BY tabname alias_tabname.
  DELETE ADJACENT DUPLICATES FROM lt_columns_t COMPARING tabname alias_tabname.
  IF lines( lt_columns_t ) > 0.
    SELECT *
      INTO TABLE lt_columns_or
      FROM zonta_oc_col_all
      FOR ALL ENTRIES IN lt_columns_t
      WHERE tabname = lt_columns_t-tabname
        AND alias_tabname = lt_columns_t-alias_tabname.
  ENDIF.
  SORT lt_columns_or BY tabname alias_tabname fldname.
  LOOP AT lt_columns_save ASSIGNING <fs_col>.
    READ TABLE lt_columns_or INTO ls_columns WITH KEY tabname = <fs_col>-tabname
                                                   alias_tabname = <fs_col>-alias_tabname BINARY SEARCH.
    IF sy-subrc = 0.
      <fs_col>-id_column = ls_columns-id_column.
    ELSE.
      READ TABLE lt_columns_save INTO ls_columns WITH KEY tabname = <fs_col>-tabname
                                                    alias_tabname = <fs_col>-alias_tabname .
      IF sy-subrc = 0 AND ls_columns-id_column IS NOT INITIAL.
        <fs_col>-id_column = ls_columns-id_column.
      ELSE.
        PERFORM get_next_range USING c_rcol_all CHANGING lv_id_col.
        <fs_col>-id_column = lv_id_col.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF lv_error_empty = abap_true.
    MESSAGE e009(zon_cl_oc)  DISPLAY LIKE 'I'.
  ELSEIF lines( lt_columns_save ) > 0.

    PERFORM check_position_columns TABLES lt_columns_save[].
    lt_columns_t[] = lt_columns_save[].
    SORT lt_columns_t BY tabname alias_tabname.
    DELETE ADJACENT DUPLICATES FROM lt_columns_t COMPARING tabname alias_tabname.

    LOOP AT lt_columns_t INTO ls_columns.
      DELETE FROM zonta_oc_col_all WHERE tabname = ls_columns-tabname
                                     AND alias_tabname = ls_columns-alias_tabname.
    ENDLOOP.

    MODIFY zonta_oc_col_all FROM TABLE lt_columns_save.
    IF sy-subrc = 0.
      COMMIT WORK.
    ELSE.
      lv_error = abap_true.
    ENDIF.
  ENDIF.

  IF lv_error = abap_false AND lines( lt_columns_save ) > 0.
    MESSAGE s013(zon_cl_oc)  DISPLAY LIKE 'I'.

** Need to check the regeeration
*    SORT lt_columns_t BY tabname alias_tabname.
*    DELETE ADJACENT DUPLICATES FROM lt_columns_t COMPARING tabname alias_tabname.
*    LOOP AT lt_columns_t INTO ls_columns.
*      zonta_obj_oc-domainv       = ls_columns-domainv.
*      zonta_obj_oc-business_proc = ls_columns-business_proc.
*      PERFORM regenerate.
*    ENDLOOP.

*    IF lv_load_global = abap_true.
*      DELETE lt_ex_rel_all WHERE levelv NE c_999.
*      gt_regen[]  = lt_ex_rel_all[].
*
*      LOOP AT  lt_columns_save INTO ls_columns.
*        APPEND INITIAL LINE TO gt_columns_alv ASSIGNING <fs_col_alv>.
*        MOVE-CORRESPONDING ls_columns TO <fs_col_alv>.
*      ENDLOOP.
*
*      PERFORM save_cus_existing_entities.
*    ENDIF.
  ENDIF.



ENDFORM.                    "load_columns

*&---------------------------------------------------------------------*
*& Form validate_alias_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_COLUMNS_SAVE
*&---------------------------------------------------------------------*
FORM validate_alias_table  TABLES   pt_columns STRUCTURE zonta_oc_col_all.

  DATA:
    ls_tmptab  TYPE zonta_oc_col_all,
    ls_tmpcol  TYPE zonta_oc_col_all,
    lv_index   TYPE n,
    lv_changed TYPE boolean.

  DATA: lt_tmpcol TYPE STANDARD TABLE OF zonta_oc_col_all,
        lt_tmptab TYPE STANDARD TABLE OF zonta_oc_col_all.

  FIELD-SYMBOLS: <fs_col>   TYPE zonta_oc_col_all.

  CONSTANTS: c_guion TYPE c VALUE '_'.
  DATA: lv_first  TYPE string,
        lv_second TYPE string.

  TYPES: BEGIN OF st_table,
           data TYPE c LENGTH 255,
         END OF st_table.

  DATA:
    lt_tab TYPE STANDARD TABLE OF st_table,
    ls_tab TYPE st_table.

  lv_changed = abap_false.

* Validation for same alias in table
  lt_tmptab[] = pt_columns[].
  SORT lt_tmptab BY tabname.
  DELETE ADJACENT DUPLICATES FROM lt_tmptab COMPARING tabname.
  lt_tmpcol[] = pt_columns[].
  SORT lt_tmpcol BY tabname.

* Validate no numbers at first place and also no spaces
  LOOP AT pt_columns ASSIGNING <fs_col>.
    IF <fs_col>-alias_fldname+0(1) CO '0123456789'.
      SHIFT <fs_col>-alias_fldname BY 1 PLACES.
      lv_changed = abap_true.
    ENDIF.

    CLEAR lv_second.
    CLEAR lt_tab[].

    IF NOT <fs_col>-alias_fldname IS INITIAL AND <fs_col>-alias_fldname CS space.
      SPLIT <fs_col>-alias_fldname AT space INTO TABLE lt_tab.

      LOOP AT lt_tab INTO ls_tab.
        CONCATENATE lv_second ls_tab-data INTO lv_second SEPARATED BY '_'.
      ENDLOOP.
    ENDIF.
    SHIFT lv_second BY 1 PLACES .
    IF <fs_col>-alias_fldname NE lv_second.
      <fs_col>-alias_fldname = lv_second.
      lv_changed = abap_true.
    ENDIF.
  ENDLOOP.


  SORT pt_columns BY fldname.
* Validate no empty alias
  LOOP AT pt_columns ASSIGNING <fs_col> WHERE alias_fldname IS INITIAL.
    READ TABLE pt_columns INTO ls_tmpcol WITH KEY fldname = <fs_col>-fldname BINARY SEARCH.
    IF sy-subrc = 0.
      <fs_col>-alias_fldname = ls_tmpcol-alias_fldname.
    ELSE.
      <fs_col>-alias_fldname = <fs_col>-fldname.
    ENDIF.
    lv_changed = abap_true.
  ENDLOOP.

  LOOP AT lt_tmptab INTO ls_tmptab.
    lt_tmpcol[] = pt_columns[].
    SORT lt_tmpcol BY tabname.
    DELETE lt_tmpcol WHERE tabname NE ls_tmptab-tabname.
    LOOP AT lt_tmpcol INTO ls_tmpcol WHERE tabname = ls_tmptab-tabname.
      lv_index = 1.
      LOOP AT pt_columns ASSIGNING <fs_col> WHERE tabname       =  ls_tmpcol-tabname
                                              AND alias_fldname =  ls_tmpcol-alias_fldname
                                              AND fldname       NE ls_tmpcol-fldname.
        CONCATENATE <fs_col>-alias_fldname lv_index INTO <fs_col>-alias_fldname.
        lv_index = lv_index + 1.
        lv_changed = abap_true.
        DELETE lt_tmpcol WHERE tabname       = <fs_col>-tabname
                           AND alias_tabname = <fs_col>-alias_tabname
                           AND fldname       = <fs_col>-fldname.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.

  IF lv_changed = abap_true.
    MESSAGE i015(zon_cl_oc).
  ENDIF.
ENDFORM.                    "validate_alias_table


*&---------------------------------------------------------------------*
*& Form call_parametert
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM call_parametert .
  CALL TRANSACTION 'ZONT_OC_PARAM'.
ENDFORM.                    "call_parametert


*&---------------------------------------------------------------------*
*& Form update_screen_700
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_screen_700 .
ENDFORM.                    "update_screen_700
*&---------------------------------------------------------------------*
*& Form mark_all_columns
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM mark_all_columns .
  FIELD-SYMBOLS: <fs_cola> LIKE LINE OF gt_columns_any_alv.

  LOOP AT gt_columns_any_alv ASSIGNING <fs_cola>.
    <fs_cola>-json = c_x.
  ENDLOOP.
  PERFORM update_grid_fin USING lo_alv_col_any.
ENDFORM.                    "mark_all_columns
*&---------------------------------------------------------------------*
*& Form unmark_all_columns
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM unmark_all_columns .
  FIELD-SYMBOLS: <fs_cola> LIKE LINE OF gt_columns_any_alv.

  LOOP AT gt_columns_any_alv ASSIGNING <fs_cola> WHERE key_field NE c_x.
    CLEAR <fs_cola>-json .
  ENDLOOP.

  PERFORM update_grid USING lo_alv_col_any.
ENDFORM.                    "unmark_all_columns
*&---------------------------------------------------------------------*
*& Form get_columns_sort
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- GT_COLUMNS_ALV
*&---------------------------------------------------------------------*
FORM get_columns_sort  CHANGING p_gt_columns_alv.

ENDFORM.                    "get_columns_sort
*&---------------------------------------------------------------------*
*& Form check_changes
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_changes .

  DATA: ls_yrelations  LIKE LINE OF gt_yrelations,
        ls_xrelations  LIKE LINE OF gt_tables_alv,
        ls_ycolumns    LIKE LINE OF gt_ycolumns,
        ls_xcolumns    LIKE LINE OF gt_columns_alv,
        lt_ycolumns_ex TYPE STANDARD TABLE OF zonta_oc_col_all,
        lt_xcolumns_ex TYPE STANDARD TABLE OF st_columns_alv,
        lt_regen       TYPE STANDARD TABLE OF zonta_relations,
        lv_xrel        TYPE i,
        lv_yrel        TYPE i,
        lv_xcol        TYPE i,
        lv_ycol        TYPE i.

  FIELD-SYMBOLS: <fs_regen> LIKE LINE OF gt_regen.

  gv_changes_rel    = abap_false.
  gv_changes_col    = abap_false.
  gv_changes_col_ex = abap_false.


  IF lines( gt_yrelations ) NE lines( gt_tables_alv ).
    gv_changes_rel = abap_true.
  ENDIF.


  LOOP AT gt_yrelations INTO ls_yrelations.
    READ TABLE gt_tables_alv INTO ls_xrelations WITH KEY tabname    = ls_yrelations-tabname
                                                         field_main = ls_yrelations-field_main
                                                         field_sec  = ls_yrelations-field_sec.
    IF sy-subrc = 0.
      IF ls_yrelations-tabname           NE ls_xrelations-tabname
      OR ls_yrelations-alias_tabname     NE ls_xrelations-alias_tabname
      OR ls_yrelations-description_table NE ls_xrelations-description_table
      OR ls_yrelations-field_main        NE ls_xrelations-field_main
      OR ls_yrelations-field_sec         NE ls_xrelations-field_sec
      OR ls_yrelations-parent_relation   NE ls_xrelations-parent_relation
      OR ls_yrelations-join_type         NE ls_xrelations-join_type
      OR ls_yrelations-sequence          NE ls_xrelations-sequence
      OR ls_yrelations-subsequence       NE ls_xrelations-subsequence
      OR ls_yrelations-levelv            NE ls_xrelations-levelv.
        gv_changes_rel = abap_true.
        EXIT.
      ENDIF.
    ELSE.
      gv_changes_rel = abap_true.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF gv_changes_rel = abap_false.
    DESCRIBE TABLE gt_yrelations LINES lv_yrel.
    DESCRIBE TABLE gt_tables_alv LINES lv_xrel.
    IF lv_yrel NE lv_xrel.
      gv_changes_rel = abap_true.
    ENDIF.
  ENDIF.

  IF gv_changes_rel = abap_false.
    IF lines( gt_ycolumns ) NE lines( gt_columns_alv ).
      gv_changes_col = abap_true.
    ENDIF.


    LOOP AT gt_ycolumns INTO ls_ycolumns.
      READ TABLE gt_columns_alv INTO ls_xcolumns WITH KEY tabname  = ls_ycolumns-tabname
                                                          fldname  = ls_ycolumns-fldname.
      IF sy-subrc = 0.
        IF  ls_ycolumns-alias_fldname     NE ls_xcolumns-alias_fldname
         OR ls_ycolumns-key_field         NE ls_xcolumns-key_field
         OR ls_ycolumns-selection_field   NE ls_xcolumns-selection_field
         OR ls_ycolumns-description_field NE ls_xcolumns-description_field.
          gv_changes_col = abap_true.
          EXIT.
        ENDIF.
      ELSE.
        gv_changes_col = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF gv_changes_col = abap_false.
      DESCRIBE TABLE gt_ycolumns LINES lv_ycol.
      DESCRIBE TABLE gt_columns_alv LINES lv_xcol.
      IF lv_ycol NE lv_xcol.
        gv_changes_col = abap_true.
      ENDIF.
    ENDIF.

  ENDIF.


  LOOP AT gt_ex_rel INTO gs_ex_rel.
    LOOP AT gt_ex_col INTO ls_ycolumns WHERE tabname = gs_ex_rel-tabname.
      READ TABLE gt_columns_alv INTO ls_xcolumns WITH KEY tabname = ls_ycolumns-tabname
                                                          fldname = ls_ycolumns-fldname.
      IF sy-subrc = 0.
        IF  ls_ycolumns-alias_fldname     NE ls_xcolumns-alias_fldname
         OR ls_ycolumns-key_field         NE ls_xcolumns-key_field
         OR ls_ycolumns-selection_field   NE ls_xcolumns-selection_field.

          IF ( ls_ycolumns-fldname = 'MANDT'
            OR ls_ycolumns-fldname = 'mandt' ).
          ELSE.
*         OR ls_ycolumns-description_field NE ls_xcolumns-description_field.
            APPEND INITIAL LINE TO lt_regen ASSIGNING <fs_regen>.
            MOVE-CORRESPONDING gs_ex_rel TO <fs_regen>.
            gv_changes_col_ex = abap_true.
            EXIT.
          ENDIF.
        ENDIF.
      ELSE.
        APPEND INITIAL LINE TO lt_regen ASSIGNING <fs_regen>.
        MOVE-CORRESPONDING gs_ex_rel TO <fs_regen>.
        gv_changes_col_ex = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF gv_changes_col_ex = abap_false.
      lt_ycolumns_ex[] = gt_ex_col[].
      lt_xcolumns_ex[] = gt_columns_alv[].
      SORT lt_ycolumns_ex BY tabname fldname.
      SORT lt_xcolumns_ex BY tabname fldname.
      DELETE  lt_ycolumns_ex WHERE tabname NE gs_ex_rel-tabname.
      DELETE  lt_xcolumns_ex WHERE tabname NE gs_ex_rel-tabname.
      DESCRIBE TABLE lt_ycolumns_ex LINES lv_ycol.
      DESCRIBE TABLE lt_xcolumns_ex LINES lv_xcol.
      IF lv_ycol NE lv_xcol.
        APPEND INITIAL LINE TO lt_regen ASSIGNING <fs_regen>.
        MOVE-CORRESPONDING gs_ex_rel TO <fs_regen>.
        gv_changes_col_ex = abap_true.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF lines( lt_regen ) > 0.
    SELECT *
      INTO TABLE gt_regen
      FROM zonta_relations
      FOR ALL ENTRIES IN lt_regen
      WHERE tabname       = lt_regen-tabname
        AND alias_tabname = lt_regen-alias_tabname.
  ENDIF.
ENDFORM.                    "check_changes
*&---------------------------------------------------------------------*
*& Form save_cus_existing_entities
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_cus_existing_entities .

  TYPES: BEGIN OF st_data,
           source_domain TYPE zonde_domain,
           source_entity TYPE zonde_process,
           target_domain TYPE zonde_domain,
           target_entity TYPE zonde_process,
           source_st     TYPE ddobjname,
           target_st     TYPE ddobjname,
           regenerate    TYPE boolean,
         END OF st_data.

  DATA: lt_ddic       TYPE STANDARD TABLE OF zonta_oc_ddic,
        lt_regen      TYPE STANDARD TABLE OF zonta_relations,
        lt_data       TYPE STANDARD TABLE OF st_data,
        ls_regen      LIKE LINE OF lt_regen,
        ls_ddic       LIKE LINE OF lt_ddic,
        lv_name       TYPE string,
        lv_original   TYPE string,
        lv_result     TYPE sy-subrc,
        ls_obj_oc_tmp TYPE zonta_obj_oc.

  FIELD-SYMBOLS: <fs_ddic> LIKE LINE OF lt_ddic,
                 <fs_data> LIKE LINE OF lt_data.


  lt_regen[] = gt_regen[].

  DELETE lt_regen WHERE business_proc = zonta_obj_oc-business_proc.

  IF lines( lt_regen ) > 0.
    SELECT *
      INTO TABLE lt_ddic
      FROM zonta_oc_ddic
      FOR ALL ENTRIES IN lt_regen
      WHERE domainv = lt_regen-domainv
        AND business_proc = lt_regen-business_proc.
    DELETE lt_ddic WHERE object_type NE 'TABL'.
    DELETE lt_ddic WHERE object CS 'TABLE'.
    DELETE lt_ddic WHERE object NS 'SSEQ'.
    SORT lt_ddic BY id object.

    LOOP AT lt_regen INTO ls_regen.
      lv_name = 'SSEQ' && ls_regen-sequence.
      LOOP AT lt_ddic INTO ls_ddic WHERE id = ls_regen-id.
        IF ls_ddic-object CS lv_name.
          lv_original = |ZON| && zonta_obj_oc-id && |SSEQ| && ls_regen-sequence.
          APPEND INITIAL LINE TO lt_data ASSIGNING <fs_data>.
          <fs_data>-source_domain = zonta_obj_oc-domainv.
          <fs_data>-source_entity = zonta_obj_oc-business_proc.
          <fs_data>-target_domain = ls_ddic-domainv.
          <fs_data>-target_entity = ls_ddic-business_proc.
          <fs_data>-source_st     = lv_original.
          <fs_data>-target_st     = ls_ddic-object.
          IF ls_ddic-object NS ls_ddic-id.
            <fs_data>-regenerate = abap_true.
          ENDIF.
          EXIT.
**          ENDIF.
        ELSE.
          CONTINUE.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDIF.

  ls_obj_oc_tmp = zonta_obj_oc.
  IF lines( lt_data ) > 0.
    IF  go_json IS BOUND.
      CLEAR  go_json.
      CREATE OBJECT go_json.
    ENDIF.

    LOOP AT lt_data ASSIGNING <fs_data>.
      IF <fs_data>-regenerate = abap_true.
        MESSAGE i115(zon_cl_oc) WITH  <fs_data>-target_entity DISPLAY LIKE 'I'.
      ELSE.
        CALL METHOD go_json->create_json_ddic_for_reg
          EXPORTING
            iv_domainv_source       = <fs_data>-source_domain
            iv_business_proc_source = <fs_data>-source_entity
            iv_domainv_target       = <fs_data>-target_domain
            iv_business_proc_target = <fs_data>-target_entity
            iv_structure_source     = <fs_data>-source_st
            iv_structure_target     = <fs_data>-target_st
          IMPORTING
            ev_subrc                = lv_result.
        IF lv_result NE 0.
          MESSAGE i114(zon_cl_oc) WITH <fs_data>-target_st <fs_data>-target_entity DISPLAY LIKE 'I'.
        ELSE.
          MESSAGE s116(zon_cl_oc) WITH <fs_data>-target_entity <fs_data>-target_st  DISPLAY LIKE 'S'.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDIF.
ENDFORM.                    "save_cus_existing_entities
*&---------------------------------------------------------------------*
*&      Form  LOAD_FILTERS_FROM_EXCEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM load_filters_from_excel .

  TYPES: BEGIN OF field_sel_type,
           tablename   LIKE rsdstabs-prim_tab,
           fieldname   LIKE rsdstabs-prim_fname,
           ldbnode     LIKE ldbn-ldbnode,
           qu_prefix,
           qu_num      LIKE rsdsqfn-numb,
           fieldnumber LIKE sy-tabix,
           text        LIKE rsdstexts-text,
           convert     LIKE rsconvert,
           f4availabl  LIKE dfies-f4availabl,
           checktable  LIKE dfies-checktable,
           valexi      LIKE dfies-valexi,
           at_on       LIKE rsdsevflds-at_on,
           at_on_end   LIKE rsdsevflds-at_on_end,
           f1          LIKE rsdsevflds-f1,
           f4          LIKE rsdsevflds-f4,
           protected,                    " In Variante geschützt
           vtype,                        " Über Variantenvariable versorgt
           fieldsel    LIKE rsdsselopt OCCURS 5,
           reffield    LIKE rsscr-dbfield,
         END OF field_sel_type.

  TYPES: rsds_where_tab LIKE rsdswhere OCCURS 5.

  TYPES: BEGIN OF st_ranges,
           domainv       TYPE zonde_domain,
           business_proc TYPE zonde_process,
           variant       TYPE variant,
           tabname       TYPE tabname,
           counter       TYPE zonde_counter,
           fldname       TYPE zonde_fieldname_long,
           sign          TYPE tvarv_sign,
           opti          TYPE tvarv_opti,
           low           TYPE rsdsselop_,
           high          TYPE rsdsselop_,
         END OF st_ranges.

  DATA: ls_rec         TYPE ty_rec,
        ls_relations   TYPE zonta_relations,
        lt_relations   TYPE STANDARD TABLE OF zonta_relations,
        lt_rel_u       TYPE STANDARD TABLE OF zonta_relations,
        lt_columns     TYPE STANDARD TABLE OF zonta_oc_col_all,
        lt_rangest     TYPE STANDARD TABLE OF st_ranges, "zonta_oc_franges,
        lt_ranges      TYPE STANDARD TABLE OF zonta_oc_franges,
        lt_obj         TYPE STANDARD TABLE OF zonta_obj_oc,
        ls_field_sel   TYPE field_sel_type,
        ls_fieldsel    TYPE rsdsselopt,
        lt_fieldsel    TYPE STANDARD TABLE OF rsdsselopt,
        ls_rangest     TYPE st_ranges, "zonta_oc_franges,
        ls_ranges      TYPE zonta_oc_franges,
        ls_filters     TYPE zonta_oc_filters,
        lt_filters     TYPE STANDARD TABLE OF zonta_oc_filters,
        lt_franges     TYPE STANDARD TABLE OF zonta_oc_franges,
        ls_filters_tmp TYPE zonta_oc_filters,
        ls_franges     TYPE zonta_oc_franges,
        ls_rel         TYPE zonta_relations,
        ls_obj         TYPE zonta_obj_oc,
        ls_cust        TYPE zonta_relations,
        lv_id          TYPE zonta_obj_oc-id,
        lv_error       TYPE boolean,
        lv_error_empty TYPE boolean,
        lv_err_no_rel  TYPE boolean,
        lv_tabname     TYPE zonta_oc_franges-tabname,
        lv_fldname     TYPE zonta_oc_franges-fldname,
        lt_wtab        TYPE rsds_where_tab,
        ls_wtab        TYPE rsdswhere,
        lv_ind         TYPE i,
        lv_subrc       TYPE sy-subrc.

  FIELD-SYMBOLS: <fs_ranges> TYPE zonta_oc_franges.

  LOOP AT gt_recs INTO ls_rec.
    ls_ranges-mandt = sy-mandt.
    MOVE ls_rec-f0001 TO ls_ranges-domainv.
    MOVE ls_rec-f0002 TO ls_ranges-business_proc.
*    MOVE ls_rec-f0003 TO ls_ranges-variant.
    MOVE ls_rec-f0003 TO ls_ranges-tabname.
*    MOVE ls_rec-f0005 TO ls_ranges-counter.
    MOVE ls_rec-f0004 TO ls_ranges-fldname.
    MOVE ls_rec-f0005 TO ls_ranges-sign.
    MOVE ls_rec-f0006 TO ls_ranges-opti.
    MOVE ls_rec-f0007 TO ls_ranges-low.
    MOVE ls_rec-f0008 TO ls_ranges-high.
    APPEND ls_ranges TO lt_ranges.
    MOVE-CORRESPONDING ls_ranges TO ls_rangest.
    APPEND ls_rangest TO lt_rangest.
  ENDLOOP.

  IF lines( lt_rangest ) = 0.
    RETURN.
  ENDIF.

  SELECT *
    INTO TABLE lt_relations
    FROM zonta_relations
    FOR ALL ENTRIES IN lt_ranges
    WHERE domainv       = lt_ranges-domainv
      AND business_proc = lt_ranges-business_proc
      AND tabname       = lt_ranges-tabname.


  SELECT *
    INTO TABLE lt_columns
    FROM zonta_oc_col_all
    FOR ALL ENTRIES IN lt_rangest
    WHERE tabname       = lt_rangest-tabname
      AND fldname       = lt_rangest-fldname.

  CLEAR gt_franges[].
  CLEAR gt_filters[].
  SORT lt_ranges BY domainv business_proc tabname fldname.
  SORT lt_relations BY domainv business_proc tabname.
  SORT lt_columns BY tabname fldname.
  LOOP AT lt_ranges INTO ls_ranges.
    READ TABLE lt_relations TRANSPORTING NO FIELDS WITH KEY domainv = ls_ranges-domainv
                                                            business_proc = ls_ranges-business_proc
                                                            tabname = ls_ranges-tabname BINARY SEARCH.
    IF sy-subrc NE 0.
      MESSAGE i021(zon_cl_oc) WITH ls_ranges-tabname ls_ranges-business_proc.
    ELSE.
      READ TABLE lt_columns TRANSPORTING NO FIELDS WITH KEY tabname = ls_ranges-tabname
                                                            fldname = ls_ranges-fldname BINARY SEARCH.
      IF sy-subrc NE 0.
        MESSAGE i022(zon_cl_oc) WITH ls_ranges-tabname ls_ranges-fldname ls_ranges-business_proc.
      ELSE.
        SORT gt_franges BY domainv business_proc tabname counter DESCENDING.
        READ TABLE gt_franges INTO ls_franges WITH KEY domainv = ls_ranges-domainv
                                                       business_proc = ls_ranges-business_proc
                                                       tabname = ls_ranges-tabname.
*                                                       fldname = ls_ranges-fldname.
        IF sy-subrc = 0.
          ls_ranges-counter = ls_franges-counter + 1.
        ELSE.
          ls_ranges-counter = 1.
        ENDIF.
        APPEND ls_ranges TO gt_franges.
      ENDIF.
    ENDIF.
  ENDLOOP.

  CLEAR ls_field_sel.
  CLEAR ls_fieldsel.
  CLEAR lt_fieldsel[].

  SORT gt_franges BY tabname counter fldname.
  READ TABLE gt_franges INTO ls_ranges INDEX 1.
  lv_tabname = ls_ranges-tabname.
  lv_fldname = ls_ranges-fldname.
  LOOP AT gt_franges INTO ls_ranges.

    IF lv_fldname NE ls_ranges-fldname.
      ls_field_sel-tablename = lv_tabname.
      ls_field_sel-fieldname = lv_fldname.
      ls_field_sel-fieldsel  = lt_fieldsel[].
      PERFORM where_for_one_field IN PROGRAM saplssel IF FOUND USING ls_field_sel
                                  CHANGING lt_wtab
                                           lv_subrc.
      CLEAR ls_field_sel.
      CLEAR ls_fieldsel.
      CLEAR lt_fieldsel[].

      CLEAR ls_filters.
      ls_filters-mandt         = sy-mandt.
      ls_filters-domainv       = ls_ranges-domainv.
      ls_filters-business_proc = ls_ranges-business_proc.
      ls_filters-tabname       = lv_tabname.
      ls_filters-fldname       = lv_fldname.
      READ TABLE lt_wtab INTO ls_wtab INDEX 1.
      IF sy-subrc = 0.
        ls_filters-where_clause = ls_wtab-line.
      ENDIF.
      READ TABLE gt_filters INTO ls_filters_tmp WITH KEY domainv       = ls_filters-domainv
                                                         business_proc = ls_filters-business_proc
                                                         tabname       = ls_filters-tabname.
      IF sy-subrc = 0.
        ls_filters-counter   = ls_filters_tmp-counter + 1.
      ELSE.
        ls_filters-counter = 1.
      ENDIF.
      APPEND ls_filters TO gt_filters.

    ENDIF.
    IF lv_tabname NE ls_ranges-tabname.

    ENDIF.

    lv_tabname = ls_ranges-tabname.
    lv_fldname = ls_ranges-fldname.

    MOVE-CORRESPONDING ls_ranges TO ls_fieldsel.
    ls_fieldsel-option = ls_ranges-opti .
    APPEND ls_fieldsel TO lt_fieldsel[].

  ENDLOOP.
  IF lines( lt_fieldsel ) > 0.
    ls_field_sel-tablename = lv_tabname.
    ls_field_sel-fieldname = lv_fldname.
    ls_field_sel-fieldsel  = lt_fieldsel[].
    PERFORM where_for_one_field IN PROGRAM saplssel IF FOUND USING ls_field_sel
                                CHANGING lt_wtab
                                         lv_subrc.
    CLEAR ls_field_sel.
    CLEAR ls_fieldsel.
    CLEAR lt_fieldsel[].
    CLEAR ls_filters.
    ls_filters-mandt         = sy-mandt.
    ls_filters-domainv       = ls_ranges-domainv.
    ls_filters-business_proc = ls_ranges-business_proc.
    ls_filters-tabname       = lv_tabname.
    ls_filters-fldname       = lv_fldname.
    READ TABLE lt_wtab INTO ls_wtab INDEX 1.
    IF sy-subrc = 0.
      ls_filters-where_clause = ls_wtab-line.
    ENDIF.
    READ TABLE gt_filters INTO ls_filters_tmp WITH KEY domainv       = ls_filters-domainv
                                                       business_proc = ls_filters-business_proc
                                                       tabname       = ls_filters-tabname.
    IF sy-subrc = 0.
      ls_filters-counter   = ls_filters_tmp-counter + 1.
    ELSE.
      ls_filters-counter = 1.
    ENDIF.
    APPEND ls_filters TO gt_filters.
  ENDIF.


  SORT lt_ranges BY domainv business_proc.
  DELETE ADJACENT DUPLICATES FROM lt_ranges COMPARING domainv business_proc.
  LOOP AT lt_ranges INTO ls_ranges.

    DELETE FROM zonta_oc_filters WHERE domainv = ls_ranges-domainv
                                   AND business_proc = ls_ranges-business_proc.
    DELETE FROM zonta_oc_franges WHERE domainv = ls_ranges-domainv
                                   AND business_proc = ls_ranges-business_proc.
  ENDLOOP.

  MODIFY zonta_oc_filters FROM TABLE gt_filters.
  MODIFY zonta_oc_franges FROM TABLE gt_franges.
  IF sy-subrc = 0.
    COMMIT WORK.
    MESSAGE s023(zon_cl_oc)  DISPLAY LIKE 'I'.
  ENDIF.

ENDFORM.                    "load_filters_from_excel
*&---------------------------------------------------------------------*
*&      Form  REGENERATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM regenerate .
  IF NOT zonta_obj_oc-domainv IS INITIAL
 AND NOT zonta_obj_oc-business_proc IS INITIAL.
    PERFORM check_reference_fields.
    PERFORM generate_structures.
  ELSE.
    MESSAGE e007(zon_cl_oc)  DISPLAY LIKE 'I'.
  ENDIF.
ENDFORM.                    "regenerate


*&---------------------------------------------------------------------*
*&      Form  GENERATE_EXT_KEY_COLUMNS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM generate_ext_key_columns .
  FIELD-SYMBOLS: <fs_col> LIKE LINE OF gt_columns_alv.
  DATA: lt_columns       TYPE STANDARD TABLE OF zonta_oc_col_all,
        ls_columns       LIKE LINE OF lt_columns,
        lv_domainv       TYPE zonde_domain,
        lv_business_proc TYPE zonde_process.

  SORT gt_columns_alv BY tabname fldname.
  lt_columns[] = gt_columns[].
  SORT lt_columns BY tabname alias_tabname fldname.
  DELETE lt_columns WHERE seckey_field IS INITIAL.

  LOOP AT lt_columns INTO ls_columns.
    lv_domainv = zonta_obj_oc-domainv.
    lv_business_proc = zonta_obj_oc-business_proc.
    READ TABLE gt_columns_alv TRANSPORTING NO FIELDS WITH KEY tabname = ls_columns-tabname
                                                          fldname = ls_columns-fldname BINARY SEARCH.
    IF sy-subrc NE 0.
      APPEND INITIAL LINE TO gt_columns_alv ASSIGNING  <fs_col>.
      MOVE-CORRESPONDING ls_columns TO <fs_col>.
      SORT gt_columns_alv BY tabname fldname.
    ENDIF.

  ENDLOOP.

  SORT gt_columns_alv BY tabname fldname.
ENDFORM.                    "generate_ext_key_columns
*&---------------------------------------------------------------------*
*&      Form  ADD_SECONDARY_KEYS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_secondary_keys TABLES  p_columns  STRUCTURE zonta_oc_col_all.
  FIELD-SYMBOLS: <fs_col> TYPE zonta_oc_col_all.
  DATA: lt_columns       TYPE STANDARD TABLE OF zonta_oc_col_all,
        ls_columns       LIKE LINE OF lt_columns,
        lv_domainv       TYPE zonde_domain,
        lv_business_proc TYPE zonde_process.

  SORT p_columns BY tabname fldname.
  lt_columns[] = gt_columns[].
  SORT lt_columns BY tabname fldname.
  DELETE lt_columns WHERE seckey_field IS INITIAL.

*  READ TABLE p_columns ASSIGNING <fs_col> INDEX 1.
*  IF sy-subrc = 0.
*    lv_domainv       = <fs_col>-domainv.
*    lv_business_proc = <fs_col>-business_proc.
*  ENDIF.


  LOOP AT lt_columns INTO ls_columns.

    READ TABLE p_columns TRANSPORTING NO FIELDS WITH KEY tabname = ls_columns-tabname
                                                         fldname = ls_columns-fldname BINARY SEARCH.
    IF sy-subrc NE 0.
      APPEND INITIAL LINE TO p_columns ASSIGNING  <fs_col>.
      MOVE-CORRESPONDING ls_columns TO <fs_col>.
*      <fs_col>-domainv = lv_domainv.
*      <fs_col>-business_proc = lv_business_proc.
      SORT p_columns BY tabname fldname.
    ENDIF.

  ENDLOOP.

  SORT p_columns BY tabname fldname.
ENDFORM.                    "add_secondary_keys
*&---------------------------------------------------------------------*
*& Form get_param_information
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_param_information .

  CONSTANTS: c_tag2 TYPE zonta_oc_param-name VALUE 'TAG2',
             c_tag3 TYPE zonta_oc_param-name VALUE 'TAG3',
             c_sys  TYPE zonta_oc_param-name VALUE 'SYSTEM_OPEN'.

  DATA: ls_param TYPE zonta_oc_param.

  SELECT *
    INTO TABLE gt_param
    FROM zonta_oc_param.

  CLEAR: gv_tag2,
  gv_tag2.

  READ TABLE gt_param INTO ls_param WITH KEY name = c_tag2.
  IF sy-subrc = 0.
    gv_tag2 = ls_param-low.
  ENDIF.

  READ TABLE gt_param INTO ls_param WITH KEY name = c_tag3.
  IF sy-subrc = 0.
    gv_tag3 = ls_param-low.
  ENDIF.


  READ TABLE gt_param INTO ls_param WITH KEY name = c_sys.
  IF sy-subrc = 0.
    gv_system = ls_param-low.
  ENDIF.
ENDFORM.                    "get_param_information
*&---------------------------------------------------------------------*
*& Form check_alias_tables
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_alias_tables .

  CONSTANTS: c_guion TYPE c VALUE '_',
             c_al    TYPE c LENGTH 1 VALUE '1'.

  DATA: lv_first  TYPE string,
        lv_second TYPE string.

  TYPES: BEGIN OF st_table,
           data TYPE c LENGTH 255,
         END OF st_table.

  DATA:
    lt_tab TYPE STANDARD TABLE OF st_table,
    ls_tab TYPE st_table.

  FIELD-SYMBOLS: <fs_tables> LIKE LINE OF gt_tables_alv.

  LOOP AT gt_tables_alv ASSIGNING <fs_tables>.
    CLEAR lv_second.
    CLEAR lt_tab[].

    IF NOT <fs_tables>-alias_tabname IS INITIAL AND <fs_tables>-alias_tabname CS space.
      SPLIT <fs_tables>-alias_tabname AT space INTO TABLE lt_tab.

      LOOP AT lt_tab INTO ls_tab.
        CONCATENATE lv_second ls_tab-data INTO lv_second SEPARATED BY '_'.
      ENDLOOP.
    ENDIF.
    <fs_tables>-alias_tabname = lv_second.
    SHIFT <fs_tables>-alias_tabname BY 1 PLACES .

    IF <fs_tables>-alias_tabname = <fs_tables>-tabname.
      <fs_tables>-alias_tabname = |{ <fs_tables>-tabname }{ c_guion }{ c_al }|.
      gv_alias_error = abap_true.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "check_alias_tables
*&---------------------------------------------------------------------*
*& Form get_changes_Data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LO_ALV_TABLES
*&---------------------------------------------------------------------*
FORM get_changes_data  USING p_grid TYPE REF TO cl_gui_alv_grid.

  IF p_grid IS BOUND.

    CALL METHOD p_grid->check_changed_data.
*  IMPORTING
*    e_valid   =
*  CHANGING
*    c_refresh = 'X'
*    .
  ENDIF.

ENDFORM.                    "get_changes_data
*&---------------------------------------------------------------------*
*&      Form  CHECK_RELATED_ENTITY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GV_RELATED  text
*----------------------------------------------------------------------*
FORM check_related_entity  CHANGING p_related TYPE boolean.

  DATA: lt_relations_tmp TYPE STANDARD TABLE OF zonta_relations.

  p_related = abap_false.
  IF lines( gt_tables_alv ) > 0.
  ELSE.
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE gt_tables_alv
      FROM zonta_relations
      WHERE domainv = zonta_obj_oc-domainv
       AND  business_proc = zonta_obj_oc-business_proc.
  ENDIF.

  CLEAR gt_common_ent[].

  IF lines( gt_tables_alv ) > 0.
    SELECT *
      INTO  TABLE gt_common_ent
      FROM  zonta_relations
      FOR ALL ENTRIES IN gt_tables_alv
      WHERE tabname = gt_tables_alv-tabname
        AND alias_tabname = gt_tables_alv-alias_tabname.
    DELETE gt_common_ent WHERE domainv = zonta_obj_oc-domainv AND business_proc = zonta_obj_oc-business_proc.
  ENDIF.

  IF lines( gt_common_ent ) > 0.
    p_related = abap_true.
  ENDIF.
ENDFORM.                    "check_related_entity

*&---------------------------------------------------------------------*
*&      Form  SAVE_COLUMNS_ANY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_columns_any .

  DATA: ls_col_all TYPE zonta_oc_col_all.

  DATA: ls_anyalia     TYPE zonta_oc_anyalia,
        ls_col_alv     LIKE LINE OF gt_columns_any_alv,
        ls_columns_any LIKE LINE OF gt_columns_any,
        lv_id_col      TYPE zonta_oc_col_all-id_column.

  FIELD-SYMBOLS: <fs_cola> LIKE LINE OF gt_columns_any.


  TRANSLATE gv_tablea USING c_guion.

* Check alias not equal to alias
  IF gv_tablen = gv_tablea.
    CONCATENATE gv_tablea '_1' INTO gv_tablea.
  ENDIF.
  ls_anyalia-tabname       = gv_tablen.
  ls_anyalia-alias_tabname = gv_tablea.

  MODIFY zonta_oc_anyalia FROM ls_anyalia.
  IF sy-subrc = 0.
    COMMIT WORK.
  ENDIF.

  SELECT SINGLE *
    INTO ls_col_all
    FROM zonta_oc_col_all
    WHERE tabname = gv_tablen
      AND alias_tabname = gv_tablea.
  IF sy-subrc NE 0.

*    SELECT MAX( id_column )
*      INTO lv_id_col
*      FROM zonta_oc_col_all.
    IF lines( gt_columns_any_alv ) > 0.
      PERFORM get_next_range USING c_rcol_all CHANGING lv_id_col.
    ENDIF.
*    lv_id_col = lv_id_col + 1.

    LOOP AT gt_columns_any_alv INTO ls_col_alv WHERE json = abap_true.
      APPEND INITIAL LINE TO gt_columns_any ASSIGNING <fs_cola>.
      MOVE-CORRESPONDING ls_col_alv TO <fs_cola>.
      <fs_cola>-id_column = lv_id_col.
      <fs_cola>-alias_tabname = gv_tablea.
    ENDLOOP.

    MODIFY zonta_oc_col_all FROM TABLE gt_columns_any.
    IF sy-subrc = 0.
      COMMIT WORK.
    ENDIF.
  ELSE.

    CLEAR gt_columns_any[].
    LOOP AT gt_columns_any_alv INTO ls_col_alv WHERE json = abap_true.
      APPEND INITIAL LINE TO gt_columns_any ASSIGNING <fs_cola>.
      MOVE-CORRESPONDING ls_col_alv TO <fs_cola>.
      <fs_cola>-id_column = ls_col_all-id_column.
      <fs_cola>-alias_tabname = gv_tablea.
    ENDLOOP.

    DELETE FROM zonta_oc_col_all WHERE tabname = gv_tablen AND alias_tabname = gv_tablea.
    MODIFY zonta_oc_col_all FROM TABLE gt_columns_any.
    IF sy-subrc = 0.
      COMMIT WORK.
    ENDIF.
  ENDIF.
ENDFORM.                    "save_columns_any



*&---------------------------------------------------------------------*
*& Form init_alv_col_any
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init_alv_col_any .
  DATA: ls_tab   TYPE zonta_relations,
        lt_tab   TYPE zontt_relations,
        lt_col_a TYPE zontt_col_all,
        ls_col_a TYPE zonta_oc_col_all.

  DATA: ls_columns_any LIKE LINE OF gt_columns_any.
  FIELD-SYMBOLS: <fs_any_alv> LIKE LINE OF gt_columns_any_alv.

  DATA: lt_ex_rel TYPE STANDARD TABLE OF zonta_relations.

  IF go_cust IS INITIAL.
    CREATE OBJECT go_cust.
  ENDIF.

  IF lines( gt_columns_any ) IS INITIAL.
    SELECT *
      INTO TABLE gt_columns_any
      FROM zonta_oc_col_all
      WHERE tabname = gv_tablen.
    SORT gt_columns_any BY id_column tabname fldname.
  ENDIF.

  IF gv_tablea IS INITIAL.
    READ TABLE gt_columns_any INTO ls_columns_any INDEX 1.
    IF sy-subrc = 0.
      gv_tablea = ls_columns_any-alias_tabname.
      DELETE gt_columns_any WHERE alias_tabname NE gv_tablea.
    ENDIF.
  ELSE.
    READ TABLE gt_columns_any INTO ls_columns_any INDEX 1.
    IF sy-subrc = 0.
      IF gv_tablea NE ls_columns_any-alias_tabname.
        CLEAR gt_columns_any_alv[].
      ENDIF.
    ENDIF.
  ENDIF.

  IF gt_columns_any_alv IS INITIAL.

* Validate if table is part of any Entity
    IF gv_tablea IS INITIAL.
      SELECT SINGLE *
        INTO ls_tab
        FROM zonta_relations
        WHERE tabname = gv_tablen.

    ELSE.
      SELECT SINGLE *
        INTO ls_tab
        FROM zonta_relations
        WHERE tabname = gv_tablen
          AND alias_tabname = gv_tablea.
    ENDIF.

    IF ls_tab IS NOT INITIAL.
      gv_tablea = ls_tab-alias_tabname.
      gv_edita  = abap_true. "abap_false.
      gv_option = co_display.

      SELECT  *
        INTO TABLE gt_columns_any
          FROM  zonta_oc_col_all
          WHERE tabname       = gv_tablen
            AND alias_tabname = gv_tablea.

      LOOP AT gt_columns_any INTO ls_columns_any.
        APPEND INITIAL LINE TO gt_columns_any_alv ASSIGNING <fs_any_alv>.
        MOVE-CORRESPONDING ls_columns_any TO <fs_any_alv>.
        <fs_any_alv>-json = c_x.
      ENDLOOP.

    ELSE.

* Validate if the table is already created,
* even not part of an entity
      IF gv_tablea IS INITIAL.
        SELECT  *
          INTO TABLE gt_columns_any
            FROM  zonta_oc_col_all
            WHERE tabname  = gv_tablen.
        IF sy-subrc = 0.
          READ TABLE gt_columns_any INTO ls_columns_any INDEX 1.
          IF sy-subrc = 0.
            gv_tablea = ls_columns_any-alias_tabname.
          ENDIF.
        ENDIF.
      ELSE.
        SELECT  *
          INTO TABLE gt_columns_any
            FROM  zonta_oc_col_all
            WHERE tabname       = gv_tablen
              AND alias_tabname = gv_tablea.
      ENDIF.


      gv_edita  = abap_true.
      gv_option = co_change.

      ls_tab-domainv       = c_any.
      ls_tab-business_proc = c_any.
      ls_tab-tabname       = gv_tablen.
      APPEND ls_tab TO lt_tab.

      CALL METHOD go_cust->fill_info_field_new
        EXPORTING
          it_tables       = lt_tab[]
          iv_any          = abap_true
        IMPORTING
          et_columns      = lt_col_a[]
          et_existing_rel = lt_ex_rel[]
          et_existing_col = gt_ex_col[].

      SORT gt_columns_any BY tabname fldname.
      LOOP AT lt_col_a INTO ls_col_a.
        APPEND INITIAL LINE TO gt_columns_any_alv ASSIGNING <fs_any_alv>.
*        MOVE-CORRESPONDING ls_col_a TO <fs_any_alv>.
        READ TABLE gt_columns_any INTO ls_columns_any
                   WITH KEY tabname = ls_col_a-tabname
                            fldname = ls_col_a-fldname BINARY SEARCH.
        IF sy-subrc = 0.
          <fs_any_alv>-json = c_x.
          MOVE-CORRESPONDING ls_columns_any TO <fs_any_alv>.
        ELSE.
          MOVE-CORRESPONDING ls_col_a TO <fs_any_alv>.
        ENDIF.
        IF ls_col_a-key_field = c_x.
          <fs_any_alv>-json = c_x.
        ENDIF.
      ENDLOOP.
*      ENDIF.
    ENDIF.
  ENDIF.


  IF NOT lo_alv_col_any IS BOUND.
    CREATE OBJECT lo_container_col_any
      EXPORTING
        container_name = 'CONTAINER_COLUMNS_ANY'.

    CREATE OBJECT lo_alv_col_any
      EXPORTING
        i_parent = lo_container_col_any.


    CLEAR gt_fcat_col_any[].
    PERFORM fieldcat USING  gt_columns_any_alv[]
                      CHANGING  gt_fcat_col_any.


    LOOP AT gt_fcat_col_any ASSIGNING <fs_fieldcat>.
      CASE <fs_fieldcat>-fieldname.
        WHEN 'ALIAS_FLDNAME'.
          <fs_fieldcat>-edit = gv_edita.
        WHEN 'KEY_FIELD'.
          <fs_fieldcat>-checkbox = abap_true.
        WHEN 'SELECTION_FIELD'.
          <fs_fieldcat>-edit = gv_edita.
          <fs_fieldcat>-checkbox = abap_true.
          <fs_fieldcat>-coltext  = 'Selection'(007).
        WHEN 'JSON'.
          <fs_fieldcat>-edit = gv_edita.
          <fs_fieldcat>-checkbox = abap_true.
          <fs_fieldcat>-coltext  = 'Include JSON'(008).
        WHEN 'DESCRIPTION_FIELD'.
          <fs_fieldcat>-edit = gv_edita.
      ENDCASE.
    ENDLOOP.

* Layout options-------------------------------------------------------*
    CLEAR gs_alv_layout_ca.
    MOVE abap_true TO: gs_alv_layout_ca-cwidth_opt,
                       gs_alv_layout_ca-zebra,
                       gs_alv_layout_ca-col_opt.
    gs_alv_layout_ca-stylefname = 'CELLTAB'.

    PERFORM exclude_options_alv.
    gt_exclude_col[] = gt_exclude[].


    PERFORM ready_input CHANGING lo_alv_col_any.
    " Initialize Columns grid as empty
    lo_alv_col_any->set_table_for_first_display(
      EXPORTING
*       i_structure_name     = 'ZONST_COLUMNS_ALV'
        is_layout            = gs_alv_layout_ca
        it_toolbar_excluding = gt_exclude_col
      CHANGING
        it_outtab            = gt_columns_any_alv
        it_fieldcatalog      = gt_fcat_col_any
    ).

    CALL METHOD lo_alv_col_any->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_enter
      EXCEPTIONS
        error      = 1
        OTHERS     = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CALL METHOD lo_alv_col_any->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified
      EXCEPTIONS
        error      = 1
        OTHERS     = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    PERFORM register_alv_events_any CHANGING lo_alv_col_any.
  ELSE.
    PERFORM update_grid USING lo_alv_col_any.
  ENDIF.



ENDFORM.                    "init_alv_col_any

*
**&---------------------------------------------------------------------*
**& Form save_deleted_entity_into_tr
**&---------------------------------------------------------------------*
**& text
**&---------------------------------------------------------------------*
**& -->  p1        text
**& <--  p2        text
**&---------------------------------------------------------------------*
*FORM save_deleted_entity_into_tr .
*  CONSTANTS: c_r3tr TYPE c LENGTH 4 VALUE 'R3TR',
*             c_tabu TYPE c LENGTH 4 VALUE 'TABU',
*             c_tabl TYPE c LENGTH 4 VALUE 'TABL',
*             c_ttyp TYPE c LENGTH 4 VALUE 'TTYP',
*             c_k    TYPE c LENGTH 1 VALUE 'K',
*             c_dele TYPE e071-objfunc VALUE 'D'.  " D = delete
*
*  CONSTANTS: c_n    TYPE c LENGTH 1 VALUE 'N',
*             c_a    TYPE c LENGTH 1 VALUE 'A',
*             c_l    TYPE c LENGTH 1 VALUE 'L',
*             c_star TYPE c LENGTH 1 VALUE '*'.
*
*  DATA: lv_id TYPE dd40l-typename.
*
*  DATA: lt_tablet TYPE STANDARD TABLE OF dd40l,
*        ls_tablet TYPE dd40l,
*        lt_struct TYPE STANDARD TABLE OF dd02l,
*        ls_struct TYPE dd02l.
*
*  DATA: ls_tables  LIKE LINE OF gt_tables_alv,
*        ls_columns LIKE LINE OF gt_columns,
*        ls_filters LIKE LINE OF gt_filters,
*        ls_franges LIKE LINE OF gt_franges.
*  DATA: lt_e071_curr TYPE STANDARD TABLE OF e071,
*        lt_e071      TYPE STANDARD TABLE OF e071,
*        lt_e071_val  TYPE STANDARD TABLE OF e071,
*        lt_e071_del  TYPE STANDARD TABLE OF e071,
*        lt_e071k     TYPE STANDARD TABLE OF e071k,
*        lt_e070      TYPE STANDARD TABLE OF e070,
*        ls_e070      TYPE e070,
*        ls_request   TYPE trwbo_request,
*        lv_order     TYPE e071-trkorr,
*        lv_task      TYPE e071-trkorr,
*        lv_pos       TYPE e071-as4pos,
*        lv_post      TYPE e071k-as4pos,
*        lv_error     TYPE boolean.
*
*
*  FIELD-SYMBOLS: <fs_e071>     LIKE LINE OF lt_e071,
*                 <fs_e071_del> LIKE LINE OF lt_e071,
*                 <fs_e071k>    LIKE LINE OF lt_e071k.
*
*
*  IF zonta_obj_oc-domainv IS INITIAL.
*    MESSAGE e007(zon_cl_oc) DISPLAY LIKE 'I'.
*  ELSE.
*
*
*    CALL FUNCTION 'TRINT_ORDER_CHOICE'
*      EXPORTING
*        wi_order_type          = 'K'
*        wi_task_type           = 'S'
*        wi_category            = 'SYST'
*      IMPORTING
*        we_order               = lv_order
*        we_task                = lv_task
*      TABLES
*        wt_e071                = lt_e071
*        wt_e071k               = lt_e071k
*      EXCEPTIONS
*        no_correction_selected = 1
*        display_mode           = 2
*        object_append_error    = 3
*        recursive_call         = 4
*        wrong_order_type       = 5
*        OTHERS                 = 6.
*
*    CHECK sy-subrc = 0.
*    PERFORM save_custom_tables_into_tr
*                                       TABLES lt_e070[]
*                                                lt_e071[]
*                                                lt_e071k[]
*                                                USING c_dele.
*
*
*    lt_e071_val[] = lt_e071[].
*    DELETE lt_e071_val WHERE object = c_tabu.
*    IF lines( lt_e071_val ) > 0.
*      lv_error = abap_false.
*
** Search entries in current transports
*      SELECT *
*        INTO TABLE lt_e071_curr
*        FROM e071
*        FOR ALL ENTRIES IN lt_e071_val
*        WHERE obj_name = lt_e071_val-obj_name.
*
*      IF lines( lt_e071_curr ) > 0.
** Search for Modifiable transports
*        SELECT *
*          INTO TABLE lt_e070
*          FROM e070
*          FOR ALL ENTRIES IN lt_e071_curr
*          WHERE trkorr = lt_e071_curr-trkorr
*            AND trstatus NE 'R'.
*        IF sy-subrc = 0.
** Delete the entries first from previous transport
*          LOOP AT lt_e070 INTO ls_e070.
*            CLEAR lt_e071_del.
*            CLEAR ls_request.
*            LOOP AT lt_e071_curr ASSIGNING <fs_e071> WHERE trkorr = ls_e070-trkorr.
*
*              CALL FUNCTION 'TRINT_DELETE_COMM_OBJECT_KEYS'
*                EXPORTING
*                  is_e071_delete              = <fs_e071>
*                  iv_dialog_flag              = ' '
*                CHANGING
*                  cs_request                  = ls_request
*                EXCEPTIONS
*                  e_bad_target_request        = 1
*                  e_database_access_error     = 2
*                  e_empty_lockkey             = 3
*                  e_wrong_source_client       = 4
*                  n_no_deletion_of_c_objects  = 5
*                  n_no_deletion_of_corr_entry = 6
*                  n_object_entry_doesnt_exist = 7
*                  n_request_already_released  = 8
*                  n_request_from_other_system = 9
*                  r_user_cancelled            = 10
*                  r_user_didnt_confirm        = 11
*                  r_foreign_lock              = 12
*                  w_bigger_lock_in_same_order = 13
*                  w_duplicate_entry           = 14
*                  w_no_authorization          = 15
*                  w_user_not_owner            = 16
*                  OTHERS                      = 17.
*              IF sy-subrc <> 0.
** Implement suitable error handling here
*                lv_error = abap_true.
*                MESSAGE ID syst-msgid TYPE syst-msgty NUMBER syst-msgno WITH syst-msgv1 syst-msgv2 syst-msgv3 syst-msgv4.
*              ENDIF.
*
*            ENDLOOP.
*          ENDLOOP.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*
*    IF lv_error = abap_true.
*      MESSAGE e026(zon_cl_oc) DISPLAY LIKE 'I'.
*    ELSE.
*      CALL FUNCTION 'TR_APPEND_TO_COMM_OBJS_KEYS'
*        EXPORTING
*          wi_trkorr                      = lv_task
*        TABLES
*          wt_e071                        = lt_e071
*          wt_e071k                       = lt_e071k
*        EXCEPTIONS
*          key_char_in_non_char_field     = 1
*          key_check_keysyntax_error      = 2
*          key_inttab_table               = 3
*          key_longer_field_but_no_generc = 4
*          key_missing_key_master_fields  = 5
*          key_missing_key_tablekey       = 6
*          key_non_char_but_no_generic    = 7
*          key_no_key_fields              = 8
*          key_string_longer_char_key     = 9
*          key_table_has_no_fields        = 10
*          key_table_not_activ            = 11
*          key_unallowed_key_function     = 12
*          key_unallowed_key_object       = 13
*          key_unallowed_key_objname      = 14
*          key_unallowed_key_pgmid        = 15
*          key_without_header             = 16
*          ob_check_obj_error             = 17
*          ob_devclass_no_exist           = 18
*          ob_empty_key                   = 19
*          ob_generic_objectname          = 20
*          ob_ill_delivery_transport      = 21
*          ob_ill_lock                    = 22
*          ob_ill_parts_transport         = 23
*          ob_ill_source_system           = 24
*          ob_ill_system_object           = 25
*          ob_ill_target                  = 26
*          ob_inttab_table                = 27
*          ob_local_object                = 28
*          ob_locked_by_other             = 29
*          ob_modif_only_in_modif_order   = 30
*          ob_name_too_long               = 31
*          ob_no_append_of_corr_entry     = 32
*          ob_no_append_of_c_member       = 33
*          ob_no_consolidation_transport  = 34
*          ob_no_original                 = 35
*          ob_no_shared_repairs           = 36
*          ob_no_systemname               = 37
*          ob_no_systemtype               = 38
*          ob_no_tadir                    = 39
*          ob_no_tadir_not_lockable       = 40
*          ob_privat_object               = 41
*          ob_repair_only_in_repair_order = 42
*          ob_reserved_name               = 43
*          ob_syntax_error                = 44
*          ob_table_has_no_fields         = 45
*          ob_table_not_activ             = 46
*          tr_enqueue_failed              = 47
*          tr_errors_in_error_table       = 48
*          tr_ill_korrnum                 = 49
*          tr_lockmod_failed              = 50
*          tr_lock_enqueue_failed         = 51
*          tr_not_owner                   = 52
*          tr_no_systemname               = 53
*          tr_no_systemtype               = 54
*          tr_order_not_exist             = 55
*          tr_order_released              = 56
*          tr_order_update_error          = 57
*          tr_wrong_order_type            = 58
*          ob_invalid_target_system       = 59
*          tr_no_authorization            = 60
*          ob_wrong_tabletyp              = 61
*          ob_wrong_category              = 62
*          ob_system_error                = 63
*          ob_unlocal_objekt_in_local_ord = 64
*          tr_wrong_client                = 65
*          ob_wrong_client                = 66
*          key_wrong_client               = 67
*          OTHERS                         = 68.
*      IF sy-subrc <> 0.
*        MESSAGE ID syst-msgid TYPE syst-msgty NUMBER syst-msgno WITH syst-msgv1 syst-msgv2 syst-msgv3 syst-msgv4.
*      ELSE.
*        MESSAGE s027(zon_cl_oc) WITH zonta_obj_oc-business_proc lv_order DISPLAY LIKE 'S'.
*      ENDIF.
*    ENDIF.
*  ENDIF.
*
*ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_deleted_entity_into_tr  (NO TR_APPEND_TO_COMM_OBJS)
*&---------------------------------------------------------------------*
FORM save_deleted_entity_into_tr .
  CONSTANTS: c_r3tr TYPE c LENGTH 4 VALUE 'R3TR',
             c_tabu TYPE c LENGTH 4 VALUE 'TABU',
             c_d    TYPE e071-objfunc VALUE 'D'.

  DATA: lt_e071      TYPE STANDARD TABLE OF e071,
        lt_e071k     TYPE STANDARD TABLE OF e071k,
        lt_e071_curr TYPE STANDARD TABLE OF e071,
        lt_e071_val  TYPE STANDARD TABLE OF e071,
        lt_e070      TYPE STANDARD TABLE OF e070,
        ls_e070      TYPE e070,
        ls_request   TYPE trwbo_request,
        lv_order     TYPE e071-trkorr,
        lv_task      TYPE e071-trkorr,
        lv_error     TYPE abap_bool.

  FIELD-SYMBOLS: <fs_e071>  LIKE LINE OF lt_e071.

  IF zonta_obj_oc-domainv IS INITIAL.
    MESSAGE e007(zon_cl_oc) DISPLAY LIKE 'I'.
    RETURN.
  ENDIF.

  " Let user choose request
  CALL FUNCTION 'TRINT_ORDER_CHOICE'
    EXPORTING
      wi_order_type          = 'K'
      wi_task_type           = 'S'
      wi_category            = 'SYST'
    IMPORTING
      we_order               = lv_order
      we_task                = lv_task
    TABLES
      wt_e071                = lt_e071
      wt_e071k               = lt_e071k
    EXCEPTIONS
      no_correction_selected = 1
      display_mode           = 2
      object_append_error    = 3
      recursive_call         = 4
      wrong_order_type       = 5
      OTHERS                 = 6.
  CHECK sy-subrc = 0.

  " Build headers+keys (no AS4POS, no LOCKFLAG, no wildcards)
  PERFORM save_custom_tables_into_tr
                                 TABLES lt_e070[]
                                        lt_e071[]
                                        lt_e071k[]
                                 USING  c_d.

  " (Optional) Your cleanup of existing requests kept as-is
  lt_e071_val[] = lt_e071[].
  DELETE lt_e071_val WHERE object = c_tabu.
  IF lines( lt_e071_val ) > 0.
    lv_error = abap_false.

    SELECT *
      INTO TABLE lt_e071_curr
      FROM e071
      FOR ALL ENTRIES IN lt_e071_val
      WHERE obj_name = lt_e071_val-obj_name.

    IF lines( lt_e071_curr ) > 0.
      SELECT *
        INTO TABLE lt_e070
        FROM e070
        FOR ALL ENTRIES IN lt_e071_curr
        WHERE trkorr = lt_e071_curr-trkorr
          AND trstatus NE 'R'.

      IF sy-subrc = 0.
        LOOP AT lt_e070 INTO ls_e070.
          CLEAR ls_request.
          LOOP AT lt_e071_curr ASSIGNING <fs_e071> WHERE trkorr = ls_e070-trkorr.
            CALL FUNCTION 'TRINT_DELETE_COMM_OBJECT_KEYS'
              EXPORTING
                is_e071_delete = <fs_e071>
                iv_dialog_flag = ' '
              CHANGING
                cs_request     = ls_request
              EXCEPTIONS
                OTHERS         = 1.
            IF sy-subrc <> 0.
              lv_error = abap_true.
              MESSAGE ID syst-msgid TYPE syst-msgty NUMBER syst-msgno
                      WITH syst-msgv1 syst-msgv2 syst-msgv3 syst-msgv4.
            ENDIF.
          ENDLOOP.
        ENDLOOP.
      ENDIF.
    ENDIF.
    IF lv_error = abap_true.
      MESSAGE e026(zon_cl_oc) DISPLAY LIKE 'I'.
      RETURN.
    ENDIF.
  ENDIF.

  " IMPORTANT: Make sure AS4POS/LOCKFLAG are initial in both tables
  LOOP AT lt_e071 ASSIGNING <fs_e071>.
    CLEAR: <fs_e071>-as4pos, <fs_e071>-lockflag, <fs_e071>-trkorr.
  ENDLOOP.
  FIELD-SYMBOLS <fs_e071k> TYPE e071k.
  LOOP AT lt_e071k ASSIGNING <fs_e071k>.
    CLEAR: <fs_e071k>-as4pos, <fs_e071k>-trkorr.
  ENDLOOP.

  " Single call: append headers+keys together
  CALL FUNCTION 'TR_APPEND_TO_COMM_OBJS_KEYS'
    EXPORTING
      wi_trkorr           = lv_task
    TABLES
      wt_e071             = lt_e071      "headers (AS4POS initial)
      wt_e071k            = lt_e071k     "keys    (AS4POS initial)
    EXCEPTIONS
      key_without_header  = 16
      tr_order_released   = 56
      tr_order_not_exist  = 55
      tr_not_owner        = 52
      tr_no_authorization = 60
      OTHERS              = 1.
  IF sy-subrc <> 0.
    MESSAGE ID syst-msgid TYPE syst-msgty NUMBER syst-msgno
            WITH syst-msgv1 syst-msgv2 syst-msgv3 syst-msgv4.
  ELSE.
    MESSAGE s027(zon_cl_oc) WITH zonta_obj_oc-business_proc lv_order DISPLAY LIKE 'S'.
  ENDIF.
ENDFORM.                    "save_deleted_entity_into_tr

*&---------------------------------------------------------------------*
*&      Form  ADD_AUTH_VALUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_AUTH_FIEL1  text
*      -->P_LS_AUTH_VAL1  text
*----------------------------------------------------------------------*
FORM add_auth_value  USING    p_fiel TYPE xufield
                              p_val TYPE xuval.

  FIELD-SYMBOLS: <fs_auth> LIKE LINE OF gt_auth_alv.

  IF p_fiel IS NOT INITIAL.
    APPEND INITIAL LINE TO gt_auth_alv ASSIGNING <fs_auth>.
    <fs_auth>-fiel = p_fiel.
    <fs_auth>-val = p_val.
  ENDIF.

ENDFORM.                    "add_auth_value
*&---------------------------------------------------------------------*
*&      Form  COPY_CLASS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM copy_class .
  DATA: lt_rel_tmp  TYPE STANDARD TABLE OF zonta_relations,
        ls_seoclass TYPE seoclass,
        ls_messtab  TYPE bdcmsgcoll.

  SELECT *
    INTO TABLE lt_rel_tmp
    FROM zonta_relations
    WHERE domainv = zonta_obj_oc-domainv
      AND business_proc = zonta_obj_oc-business_proc.
  IF sy-subrc = 0.
* Error message because Entity already created with relations
  ELSE.
    IF zonta_obj_oc-class_name IS INITIAL.
* Send error message to fill the class name
    ELSE.
      SELECT SINGLE *
        INTO ls_seoclass
        FROM seoclass
        WHERE clsname = zonta_obj_oc-class_name.
      IF sy-subrc = 0.
* Class already exsts, request to change the name
      ELSE.

        CLEAR: gt_bdcdata[],
               gt_messtab[].
        PERFORM bdc_dynpro      USING 'SAPLSEOD' '1000'.
        PERFORM bdc_field       USING 'BDC_CURSOR'
                                      'SEOCLASS-CLSNAME'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=WB_COPY'.
        PERFORM bdc_field       USING 'SEOCLASS-CLSNAME'
                                      c_class_sample.
        PERFORM bdc_dynpro      USING 'SAPLSPO4' '0300'.
        PERFORM bdc_field       USING 'BDC_CURSOR'
                                      'SVALD-VALUE(02)'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=FURT'.
        PERFORM bdc_field       USING 'SVALD-VALUE(02)'
                                      zonta_obj_oc-class_name.
        PERFORM bdc_dynpro      USING 'SAPLSEOD' '1000'.
        PERFORM bdc_field       USING 'BDC_CURSOR'
                                      'SEOCLASS-CLSNAME'.
        PERFORM bdc_field       USING 'BDC_OKCODE'
                                      '=WB_BACK'.
        PERFORM bdc_field       USING 'SEOCLASS-CLSNAME'
                                      zonta_obj_oc-class_name.
        PERFORM bdc_transaction USING 'SE24'.
        READ TABLE gt_messtab INTO ls_messtab WITH KEY msgtyp = 'E'.
        IF sy-subrc = 0.
* Send error message
          MESSAGE i032(zon_cl_oc).
        ELSE.
* Send pop up informing to activate and add own code
          MESSAGE i033(zon_cl_oc).
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    "copy_class


*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
FORM bdc_dynpro USING p_program p_dynpro.
  CLEAR gs_bdcdata.
  gs_bdcdata-program  = p_program.
  gs_bdcdata-dynpro   = p_dynpro.
  gs_bdcdata-dynbegin = 'X'.
  APPEND gs_bdcdata TO gt_bdcdata.
ENDFORM.                    "bdc_dynpro

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM bdc_field USING p_fnam p_fval.
  CLEAR gs_bdcdata.
  gs_bdcdata-fnam = p_fnam.
  gs_bdcdata-fval = p_fval.
  APPEND gs_bdcdata TO gt_bdcdata.

ENDFORM.                    "bdc_field



*----------------------------------------------------------------------*
*        Start new transaction according to parameters                 *
*----------------------------------------------------------------------*
FORM bdc_transaction USING tcode.
  DATA: lv_ctumode LIKE ctu_params-dismode VALUE 'E',
        lv_cupdate LIKE ctu_params-updmode VALUE 'L'.
* call transaction using
  REFRESH gt_messtab.
  CALL TRANSACTION tcode USING gt_bdcdata
                   MODE   lv_ctumode
                   UPDATE lv_cupdate
                   MESSAGES INTO gt_messtab.
  REFRESH gt_bdcdata.
ENDFORM.                    "bdc_transaction
*&---------------------------------------------------------------------*
*&      Form  CALL_SCREEN_300
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM call_screen_300 .
  IF gv_entity_type IS INITIAL
  OR gv_entity_type = c_relat.
    CALL SCREEN 300.
  ELSEIF gv_entity_type = c_class.
    CALL SCREEN 380.
  ENDIF.
ENDFORM.                    "call_screen_300
*&---------------------------------------------------------------------*
*&      Form  CHECK_AUTHORIZATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_authorization .
  DATA: ls_auth TYPE zonta_oc_auth.

  SELECT SINGLE *
    INTO ls_auth
    FROM zonta_oc_auth
    WHERE id  = zonta_obj_oc-id.
  IF sy-subrc = 0.
    CALL FUNCTION 'AUTHORITY_CHECK'
      EXPORTING
*       NEW_BUFFERING       = 3
        user                = sy-uname
        object              = ls_auth-objct
        field1              = ls_auth-fiel1
        value1              = ls_auth-val1
        field2              = ls_auth-fiel2
        value2              = ls_auth-val2
        field3              = ls_auth-fiel3
        value3              = ls_auth-val3
        field4              = ls_auth-fiel4
        value4              = ls_auth-val4
        field5              = ls_auth-fiel5
        value5              = ls_auth-val5
        field6              = ls_auth-fiel6
        value6              = ls_auth-val6
        field7              = ls_auth-fiel7
        value7              = ls_auth-val7
        field8              = ls_auth-fiel8
        value8              = ls_auth-val8
        field9              = ls_auth-fiel9
        value9              = ls_auth-val9
        field10             = ls_auth-fiel0
        value10             = ls_auth-val10
      EXCEPTIONS
        user_dont_exist     = 1
        user_is_authorized  = 2
        user_not_authorized = 3
        user_is_locked      = 4
        OTHERS              = 5.
    IF sy-subrc = 2.
      gv_authorization = abap_true.
    ELSE.
      gv_authorization = abap_false.
      MESSAGE i034(zon_cl_oc).
    ENDIF.
  ENDIF.

ENDFORM.                    "check_authorization
*&---------------------------------------------------------------------*
*&      Form  UPDATE_AUTH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_auth .

  DATA: ls_auth_alv LIKE LINE OF gt_auth_alv,
        lv_name     TYPE string,
        lv_index    TYPE sy-tabix.

  FIELD-SYMBOLS: <fs> TYPE any.

  CLEAR gs_auth.
  MOVE-CORRESPONDING zonta_obj_oc TO gs_auth.
  MOVE zonta_oc_auth-objct TO gs_auth-objct.

  " After user input and CHECK_CHANGED_DATA
  CALL METHOD lo_alv_auth->check_changed_data.

*LOOP AT gt_auth_alv INTO ls_auth_alv.
*  READ TABLE lt_auth_alv WITH KEY fiel = ls_auth_alv-fiel TRANSPORTING NO FIELDS.
*  IF sy-subrc = 0.
*    IF ls_auth_alv-val <> ls_auth_alvc-val.
*      APPEND ls-auth_alv TO gt_modified.
*    ENDIF.
*  ENDIF.
*ENDLOOP.

  lv_index = 1.
  LOOP AT gt_auth_alv INTO ls_auth_alv.
    lv_name = 'GS_AUTH-FIEL' && lv_index.
    ASSIGN (lv_name)  TO <fs>.
    <fs> = ls_auth_alv-fiel.
    lv_name = 'GS_AUTH-VAL' && lv_index.
    ASSIGN (lv_name)  TO <fs>.
    <fs> = ls_auth_alv-val.
    lv_index = lv_index + 1.
  ENDLOOP.
ENDFORM.                    "update_auth
*&---------------------------------------------------------------------*
*&      Form  GET_INITIAL_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_OBJ_OC  text
*----------------------------------------------------------------------*
FORM get_initial_data  USING    p_obj_oc TYPE zonta_obj_oc.

  PERFORM clear_tables.
  MOVE-CORRESPONDING p_obj_oc TO zonta_obj_oc.
  zonta_obj_oc-domainv       = p_obj_oc-domainv.
  zonta_obj_oc-business_proc = p_obj_oc-business_proc.
  zonta_obj_oc-type          = p_obj_oc-type.
  zonta_obj_oc-description   = p_obj_oc-description.
  zonta_obj_oc-tag1          = p_obj_oc-domainv.
  zonta_obj_oc-tag2          = gv_tag2.
  zonta_obj_oc-tag3          = gv_tag3.
  PERFORM refresh_tables_columns USING 'TAB'.
  PERFORM refresh_tables_columns USING 'COL'.
  PERFORM refresh_tables_columns USING 'VAR'.
  PERFORM get_column_information.
  PERFORM init_filters.
  PERFORM check_authorization.
  cl_gui_cfw=>set_new_ok_code( new_code = 'SPACE' ).
  IF p_obj_oc-class_name IS INITIAL.
    gv_entity_type = c_relat.
  ELSE.
    gv_entity_type = c_class.
  ENDIF.
  IF  zonta_obj_oc-log_type = c_slg1.
    slg1 = abap_true.
    file = abap_false.
    CLEAR zonta_obj_oc-file_path.
  ELSE.
    file = abap_true.
    slg1 = abap_false.
  ENDIF.

  SELECT SINGLE *
    INTO gs_auth
    FROM zonta_oc_auth
    WHERE id = zonta_obj_oc-id.

  zonta_oc_auth-objct = gs_auth-objct.

  IF zonta_obj_oc-log_type = 'F' AND zonta_obj_oc-file_path IS NOT INITIAL.
    gv_ini = abap_true.
    PERFORM validate_filepath.
  ENDIF.
ENDFORM.                    "get_initial_data
*&---------------------------------------------------------------------*
*& Form SAVE_CUSTOM_TABLES_INTO_TR  (NEW VERSION)
*&---------------------------------------------------------------------*
FORM save_custom_tables_into_tr
                                 TABLES p_e070   STRUCTURE e070
                                        p_e071   STRUCTURE e071
                                        p_e071k  STRUCTURE e071k
                                 USING  p_mode   TYPE e071-objfunc.

  CONSTANTS: c_r3tr TYPE c LENGTH 4 VALUE 'R3TR',
             c_tabu TYPE c LENGTH 4 VALUE 'TABU',
             c_star TYPE c LENGTH 1 VALUE '*'.

  DATA: ls_tables     LIKE LINE OF gt_tables_alv,
        ls_columns    LIKE LINE OF gt_columns,
        ls_filters    LIKE LINE OF gt_filters,
        ls_franges    LIKE LINE OF gt_franges,
        lt_relations  TYPE STANDARD TABLE OF zonta_oc_col_all,
        lt_conv       TYPE STANDARD TABLE OF zonta_oc_conv,
        lt_col_single TYPE STANDARD TABLE OF zonta_oc_col_all,
        lt_ddic       TYPE STANDARD TABLE OF zonta_oc_ddic,
        ls_ddic       LIKE LINE OF lt_ddic,
        ls_conv       TYPE zonta_oc_conv,
        lt_anyalia    TYPE TABLE OF zonta_oc_anyalia,
        lw_anyalia    TYPE zonta_oc_anyalia.

  DATA: lt_e070  TYPE STANDARD TABLE OF e070,
        lt_e071  TYPE STANDARD TABLE OF e071,
        lt_e071k TYPE STANDARD TABLE OF e071k.

  FIELD-SYMBOLS: <fs_e071>  LIKE LINE OF lt_e071,
                 <fs_e071k> LIKE LINE OF lt_e071k.

  "---------------------------
  " Header: ZONTA_OBJ_OC
  "---------------------------
  APPEND INITIAL LINE TO lt_e071 ASSIGNING <fs_e071>.
  <fs_e071>-pgmid    = c_r3tr.
  <fs_e071>-object   = c_tabu.
  <fs_e071>-obj_name = 'ZONTA_OBJ_OC'.
  <fs_e071>-objfunc  = 'K'.
*  <fs_e071>-objfunc  = p_mode.

  " Keys: ZONTA_OBJ_OC
  APPEND INITIAL LINE TO lt_e071k ASSIGNING <fs_e071k>.
  <fs_e071k>-pgmid      = c_r3tr.
  <fs_e071k>-object     = c_tabu.
  <fs_e071k>-objname    = 'ZONTA_OBJ_OC'.
  <fs_e071k>-mastertype = c_tabu.
  <fs_e071k>-mastername = 'ZONTA_OBJ_OC'.
  <fs_e071k>-objfunc    = p_mode.
  CONCATENATE sy-mandt
              zonta_obj_oc-id
              zonta_obj_oc-domainv
              zonta_obj_oc-business_proc
         INTO <fs_e071k>-tabkey RESPECTING BLANKS.
  " NOTE: removed wildcard at +119

  "---------------------------
  " Header: ZONTA_RELATIONS
  "---------------------------
  APPEND INITIAL LINE TO lt_e071 ASSIGNING <fs_e071>.
  <fs_e071>-pgmid    = c_r3tr.
  <fs_e071>-object   = c_tabu.
  <fs_e071>-obj_name = 'ZONTA_RELATIONS'.
  <fs_e071>-objfunc  = 'K'.
*  <fs_e071>-objfunc  = p_mode.

  LOOP AT gt_tables_alv INTO ls_tables.
    APPEND INITIAL LINE TO lt_e071k ASSIGNING <fs_e071k>.
    <fs_e071k>-pgmid      = c_r3tr.
    <fs_e071k>-object     = c_tabu.
    <fs_e071k>-objname    = 'ZONTA_RELATIONS'.
    <fs_e071k>-mastertype = c_tabu.
    <fs_e071k>-mastername = 'ZONTA_RELATIONS'.
    <fs_e071k>-objfunc    = p_mode.
    CONCATENATE sy-mandt
                zonta_obj_oc-id
                zonta_obj_oc-domainv
                zonta_obj_oc-business_proc
                ls_tables-tabname
                ls_tables-field_main
                ls_tables-field_sec
           INTO <fs_e071k>-tabkey RESPECTING BLANKS.
    <fs_e071k>-tabkey+119 = c_star.
  ENDLOOP.

  "---------------------------
  " Header: ZONTA_OC_COL_ALL
  "---------------------------
  IF   p_mode NE 'D'
  OR ( p_mode =  'D' AND lines( gt_col_alld ) > 0 ).
    APPEND INITIAL LINE TO lt_e071 ASSIGNING <fs_e071>.
    <fs_e071>-pgmid    = c_r3tr.
    <fs_e071>-object   = c_tabu.
    <fs_e071>-obj_name = 'ZONTA_OC_COL_ALL'.
    <fs_e071>-objfunc  = 'K'.
*  <fs_e071>-objfunc  = p_mode.
  ENDIF.

  IF lines( gt_tables_alv ) > 0.
    SELECT *
      INTO TABLE  gt_columns
      FROM zonta_oc_col_all
      FOR ALL ENTRIES IN gt_tables_alv
      WHERE tabname       = gt_tables_alv-tabname
        AND alias_tabname = gt_tables_alv-alias_tabname.
    lt_relations[] = gt_columns[].
    SORT lt_relations BY id_column tabname.
    DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING id_column tabname.
  ELSE.
    IF zonta_obj_oc-business_proc = 'ANY'.
      SELECT * INTO TABLE lt_anyalia FROM zonta_oc_anyalia.
      IF sy-subrc = 0.
        SELECT *
          INTO TABLE  gt_columns
          FROM zonta_oc_col_all
          FOR ALL ENTRIES IN lt_anyalia
          WHERE tabname       = lt_anyalia-tabname.
*            AND alias_tabname = lt_anyalia-alias_tabname.
        lt_relations[] = gt_columns[].
        SORT lt_relations BY id_column tabname.
        DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING id_column tabname.
      ENDIF.
    ENDIF.
  ENDIF.

  IF lines( gt_columns ) > 0.

    lt_col_single[] = gt_columns[].
*    SORT lt_col_single BY id_column tabname alias_tabname.
*    DELETE ADJACENT DUPLICATES FROM lt_col_single COMPARING id_column tabname alias_tabname.
    SORT lt_col_single BY id_column tabname alias_tabname fldname.
    DELETE ADJACENT DUPLICATES FROM lt_col_single COMPARING id_column tabname alias_tabname fldname.

    IF p_mode NE 'D'.
      LOOP AT lt_col_single INTO ls_columns.
        APPEND INITIAL LINE TO lt_e071k ASSIGNING <fs_e071k>.
        <fs_e071k>-pgmid      = c_r3tr.
        <fs_e071k>-object     = c_tabu.
        <fs_e071k>-objname    = 'ZONTA_OC_COL_ALL'.
        <fs_e071k>-mastertype = c_tabu.
        <fs_e071k>-mastername = 'ZONTA_OC_COL_ALL'.
        <fs_e071>-objfunc  = 'K'.
*      <fs_e071k>-objfunc    = p_mode.
        CONCATENATE sy-mandt
                    ls_columns-id_column
                    ls_columns-tabname
                    ls_columns-alias_tabname
*                    ls_columns-fldname
               INTO <fs_e071k>-tabkey RESPECTING BLANKS.
        <fs_e071k>-tabkey+119 = c_star."buscame
      ENDLOOP.

    ELSEIF p_mode =  'D' AND lines( gt_col_alld ) > 0 .
      LOOP AT gt_col_alld INTO ls_columns.
        APPEND INITIAL LINE TO lt_e071k ASSIGNING <fs_e071k>.
        <fs_e071k>-pgmid      = c_r3tr.
        <fs_e071k>-object     = c_tabu.
        <fs_e071k>-objname    = 'ZONTA_OC_COL_ALL'.
        <fs_e071k>-mastertype = c_tabu.
        <fs_e071k>-mastername = 'ZONTA_OC_COL_ALL'.
        <fs_e071>-objfunc  = 'K'.
*      <fs_e071k>-objfunc    = p_mode.
        CONCATENATE sy-mandt
                    ls_columns-id_column
                    ls_columns-tabname
                    ls_columns-alias_tabname
*                    ls_columns-fldname
               INTO <fs_e071k>-tabkey RESPECTING BLANKS.
        <fs_e071k>-tabkey+119 = c_star.
      ENDLOOP.
    ENDIF.

    "---------------------------
    " Header & Keys: ZONTA_OC_CONV (only if entries exist)
    "---------------------------
    IF lines( lt_col_single ) > 0.
      SELECT *
        INTO TABLE lt_conv
        FROM zonta_oc_conv
        FOR ALL ENTRIES IN lt_col_single
        WHERE tabname      = lt_col_single-tabname
          AND alias_tabname = lt_col_single-alias_tabname.
      SORT lt_conv BY id_column tabname alias_tabname.
      DELETE ADJACENT DUPLICATES FROM lt_conv COMPARING ALL FIELDS.

      IF lt_conv IS NOT INITIAL.
        APPEND INITIAL LINE TO lt_e071 ASSIGNING <fs_e071>.
        <fs_e071>-pgmid    = c_r3tr.
        <fs_e071>-object   = c_tabu.
        <fs_e071>-obj_name = 'ZONTA_OC_CONV'.
        <fs_e071>-objfunc  = 'K'.
*        <fs_e071>-objfunc  = p_mode.
      ENDIF.

      LOOP AT lt_conv INTO ls_conv.
        APPEND INITIAL LINE TO lt_e071k ASSIGNING <fs_e071k>.
        <fs_e071k>-pgmid      = c_r3tr.
        <fs_e071k>-object     = c_tabu.
        <fs_e071k>-objname    = 'ZONTA_OC_CONV'.
        <fs_e071k>-mastertype = c_tabu.
        <fs_e071k>-mastername = 'ZONTA_OC_CONV'.
        <fs_e071k>-objfunc    = p_mode.
        CONCATENATE sy-mandt
                    ls_conv-id_column
                    ls_conv-tabname
                    ls_conv-alias_tabname
*                    ls_conv-fldname
               INTO <fs_e071k>-tabkey RESPECTING BLANKS.
        <fs_e071k>-tabkey+119 = c_star.
      ENDLOOP.
    ENDIF.
  ENDIF.

  "---------------------------
  " Header: ZONTA_OC_FILTERS (only if gt_filters has entries)
  "---------------------------
  IF lines( gt_filters ) > 0.
    APPEND INITIAL LINE TO lt_e071 ASSIGNING <fs_e071>.
    <fs_e071>-pgmid    = c_r3tr.
    <fs_e071>-object   = c_tabu.
    <fs_e071>-obj_name = 'ZONTA_OC_FILTERS'.
    <fs_e071>-objfunc  = 'K'.
*    <fs_e071>-objfunc  = p_mode.

    LOOP AT gt_filters INTO ls_filters.
      APPEND INITIAL LINE TO lt_e071k ASSIGNING <fs_e071k>.
      <fs_e071k>-pgmid      = c_r3tr.
      <fs_e071k>-object     = c_tabu.
      <fs_e071k>-objname    = 'ZONTA_OC_FILTERS'.
      <fs_e071k>-mastertype = c_tabu.
      <fs_e071k>-mastername = 'ZONTA_OC_FILTERS'.
      <fs_e071k>-objfunc    = p_mode.
      CONCATENATE sy-mandt
                  zonta_obj_oc-domainv
                  zonta_obj_oc-business_proc
                  ls_filters-variant
                  ls_filters-tabname
                  ls_filters-counter
             INTO <fs_e071k>-tabkey RESPECTING BLANKS.
      <fs_e071k>-tabkey+119 = c_star.
    ENDLOOP.
  ENDIF.

  "---------------------------
  " Objects ZONTA_OC_DDIC
  "---------------------------
  SELECT *
    INTO TABLE lt_ddic
    FROM zonta_oc_ddic
    WHERE id = zonta_obj_oc-id
      AND domainv = zonta_obj_oc-domainv
      AND business_proc = zonta_obj_oc-business_proc.
  IF lines( lt_ddic ) > 0.
    APPEND INITIAL LINE TO lt_e071 ASSIGNING <fs_e071>.
    <fs_e071>-pgmid    = c_r3tr.
    <fs_e071>-object   = c_tabu.
    <fs_e071>-obj_name = 'ZONTA_OC_DDIC'.
    <fs_e071>-objfunc  = 'K'.

    LOOP AT lt_ddic INTO ls_ddic.
      APPEND INITIAL LINE TO lt_e071k ASSIGNING <fs_e071k>.
      <fs_e071k>-pgmid      = c_r3tr.
      <fs_e071k>-object     = c_tabu.
      <fs_e071k>-objname    = 'ZONTA_OC_DDIC'.
      <fs_e071k>-mastertype = c_tabu.
      <fs_e071k>-mastername = 'ZONTA_OC_DDIC'.
      <fs_e071k>-objfunc    = p_mode.
      CONCATENATE sy-mandt
                  ls_ddic-id
                  ls_ddic-domainv
                  ls_ddic-business_proc
                  ls_ddic-object
             INTO <fs_e071k>-tabkey RESPECTING BLANKS.
      <fs_e071k>-tabkey+119 = c_star.
    ENDLOOP.
  ENDIF.

  "---------------------------
  " Header: ZONTA_OC_FRANGES (only if gt_franges has entries)
  "---------------------------
  IF lines( gt_franges ) > 0.
    APPEND INITIAL LINE TO lt_e071 ASSIGNING <fs_e071>.
    <fs_e071>-pgmid    = c_r3tr.
    <fs_e071>-object   = c_tabu.
    <fs_e071>-obj_name = 'ZONTA_OC_FRANGES'.
    <fs_e071>-objfunc  = 'K'.
*    <fs_e071>-objfunc  = p_mode.

    LOOP AT gt_franges INTO ls_franges.
      APPEND INITIAL LINE TO lt_e071k ASSIGNING <fs_e071k>.
      <fs_e071k>-pgmid      = c_r3tr.
      <fs_e071k>-object     = c_tabu.
      <fs_e071k>-objname    = 'ZONTA_OC_FRANGES'.
      <fs_e071k>-mastertype = c_tabu.
      <fs_e071k>-mastername = 'ZONTA_OC_FRANGES'.
      <fs_e071k>-objfunc    = p_mode.
      CONCATENATE sy-mandt
                  zonta_obj_oc-domainv
                  zonta_obj_oc-business_proc
                  ls_franges-variant
                  ls_franges-tabname
                  ls_franges-counter
             INTO <fs_e071k>-tabkey RESPECTING BLANKS.
      <fs_e071k>-tabkey+119 = c_star.
    ENDLOOP.
  ENDIF.

  "---------------------------
  " Header: ZONTA_OC_AUTH (only if gs_auth is not initial)
  "---------------------------
  IF gs_auth IS NOT INITIAL.
    APPEND INITIAL LINE TO lt_e071 ASSIGNING <fs_e071>.
    <fs_e071>-pgmid    = c_r3tr.
    <fs_e071>-object   = c_tabu.
    <fs_e071>-obj_name = 'ZONTA_OC_AUTH'.
    <fs_e071>-objfunc  = 'K'.
*    <fs_e071>-objfunc  = p_mode.

    APPEND INITIAL LINE TO lt_e071k ASSIGNING <fs_e071k>.
    <fs_e071k>-pgmid      = c_r3tr.
    <fs_e071k>-object     = c_tabu.
    <fs_e071k>-objname    = 'ZONTA_OC_AUTH'.
    <fs_e071k>-mastertype = c_tabu.
    <fs_e071k>-mastername = 'ZONTA_OC_AUTH'.
    <fs_e071k>-objfunc    = p_mode.
    CONCATENATE sy-mandt
                zonta_obj_oc-id
           INTO <fs_e071k>-tabkey RESPECTING BLANKS.
  ENDIF.

  "---------------------------
  " Header: ZONTA_OC_ANYALIA (only if is ANY Entity)
  "---------------------------
  IF zonta_obj_oc-business_proc = 'ANY'.
    APPEND INITIAL LINE TO lt_e071 ASSIGNING <fs_e071>.
    <fs_e071>-pgmid    = c_r3tr.
    <fs_e071>-object   = c_tabu.
    <fs_e071>-obj_name = 'ZONTA_OC_ANYALIA'.
    <fs_e071>-objfunc  = 'K'.

    SELECT * INTO TABLE lt_anyalia FROM zonta_oc_anyalia.

    LOOP AT lt_anyalia INTO lw_anyalia.
      APPEND INITIAL LINE TO lt_e071k ASSIGNING <fs_e071k>.
      <fs_e071k>-pgmid      = c_r3tr.
      <fs_e071k>-object     = c_tabu.
      <fs_e071k>-objname    = 'ZONTA_OC_ANYALIA'.
      <fs_e071k>-mastertype = c_tabu.
      <fs_e071k>-mastername = 'ZONTA_OC_ANYALIA'.
      <fs_e071k>-objfunc    = 'K'.
*      <fs_e071k>-objfunc    = p_mode.
      CONCATENATE sy-mandt
                  lw_anyalia-tabname
             INTO <fs_e071k>-tabkey RESPECTING BLANKS.
*      <fs_e071k>-tabkey+119 = c_star.
    ENDLOOP.
  ENDIF.



  "Return to caller
*   p_e070[]  = value #( ).
  p_e070[]  = lt_e070[].
  p_e071[]  = lt_e071[].
  p_e071k[] = lt_e071k[].

****
****
****  CONSTANTS: c_r3tr TYPE c LENGTH 4 VALUE 'R3TR',
****             c_tabu TYPE c LENGTH 4 VALUE 'TABU',
****             c_star TYPE c LENGTH 1 VALUE '*'.
****
****  DATA: ls_tables     LIKE LINE OF gt_tables_alv,
****        ls_columns    LIKE LINE OF gt_columns,
****        ls_filters    LIKE LINE OF gt_filters,
****        ls_franges    LIKE LINE OF gt_franges,
****        lt_relations  TYPE STANDARD TABLE OF zonta_oc_col_all,
****        lt_conv       TYPE STANDARD TABLE OF zonta_oc_conv,
****        lt_col_single TYPE STANDARD TABLE OF zonta_oc_col_all,
****        lt_ddic       TYPE STANDARD TABLE OF zonta_oc_ddic,
****        ls_ddic       LIKE LINE OF lt_ddic,
****        ls_conv       TYPE zonta_oc_conv,
****        lt_anyalia    TYPE TABLE OF zonta_oc_anyalia,
****        lw_anyalia    TYPE zonta_oc_anyalia.
****
****  DATA: lt_e070  TYPE STANDARD TABLE OF e070,
****        lt_e071  TYPE STANDARD TABLE OF e071,
****        lt_e071k TYPE STANDARD TABLE OF e071k.
****
****  FIELD-SYMBOLS: <fs_e071>  LIKE LINE OF lt_e071,
****                 <fs_e071k> LIKE LINE OF lt_e071k.
****
****  "---------------------------
****  " Header: ZONTA_OBJ_OC
****  "---------------------------
****  APPEND INITIAL LINE TO lt_e071 ASSIGNING <fs_e071>.
****  <fs_e071>-pgmid    = c_r3tr.
****  <fs_e071>-object   = c_tabu.
****  <fs_e071>-obj_name = 'ZONTA_OBJ_OC'.
****  <fs_e071>-objfunc  = 'K'.
*****  <fs_e071>-objfunc  = p_mode.
****
****  " Keys: ZONTA_OBJ_OC
****  APPEND INITIAL LINE TO lt_e071k ASSIGNING <fs_e071k>.
****  <fs_e071k>-pgmid      = c_r3tr.
****  <fs_e071k>-object     = c_tabu.
****  <fs_e071k>-objname    = 'ZONTA_OBJ_OC'.
****  <fs_e071k>-mastertype = c_tabu.
****  <fs_e071k>-mastername = 'ZONTA_OBJ_OC'.
****  <fs_e071k>-objfunc    = p_mode.
****  CONCATENATE sy-mandt
****              zonta_obj_oc-id
****              zonta_obj_oc-domainv
****              zonta_obj_oc-business_proc
****         INTO <fs_e071k>-tabkey RESPECTING BLANKS.
****  " NOTE: removed wildcard at +119
****
****  "---------------------------
****  " Header: ZONTA_RELATIONS
****  "---------------------------
****  APPEND INITIAL LINE TO lt_e071 ASSIGNING <fs_e071>.
****  <fs_e071>-pgmid    = c_r3tr.
****  <fs_e071>-object   = c_tabu.
****  <fs_e071>-obj_name = 'ZONTA_RELATIONS'.
****  <fs_e071>-objfunc  = 'K'.
*****  <fs_e071>-objfunc  = p_mode.
****
****  LOOP AT gt_tables_alv INTO ls_tables.
****    APPEND INITIAL LINE TO lt_e071k ASSIGNING <fs_e071k>.
****    <fs_e071k>-pgmid      = c_r3tr.
****    <fs_e071k>-object     = c_tabu.
****    <fs_e071k>-objname    = 'ZONTA_RELATIONS'.
****    <fs_e071k>-mastertype = c_tabu.
****    <fs_e071k>-mastername = 'ZONTA_RELATIONS'.
****    <fs_e071k>-objfunc    = p_mode.
****    CONCATENATE sy-mandt
****                zonta_obj_oc-id
****                zonta_obj_oc-domainv
****                zonta_obj_oc-business_proc
****                ls_tables-tabname
****                ls_tables-field_main
****                ls_tables-field_sec
****           INTO <fs_e071k>-tabkey RESPECTING BLANKS.
****    <fs_e071k>-tabkey+119 = c_star."buscame
****  ENDLOOP.
****
****  "---------------------------
****  " Header: ZONTA_OC_COL_ALL
****  "---------------------------
****  IF   p_mode NE 'D'
****  OR ( p_mode =  'D' AND lines( gt_col_alld ) > 0 ).
****    APPEND INITIAL LINE TO lt_e071 ASSIGNING <fs_e071>.
****    <fs_e071>-pgmid    = c_r3tr.
****    <fs_e071>-object   = c_tabu.
****    <fs_e071>-obj_name = 'ZONTA_OC_COL_ALL'.
****    <fs_e071>-objfunc  = 'K'.
*****  <fs_e071>-objfunc  = p_mode.
****  ENDIF.
****
****  IF lines( gt_tables_alv ) > 0.
****    SELECT *
****      INTO TABLE  gt_columns
****      FROM zonta_oc_col_all
****      FOR ALL ENTRIES IN gt_tables_alv
****      WHERE tabname       = gt_tables_alv-tabname
****        AND alias_tabname = gt_tables_alv-alias_tabname.
****    lt_relations[] = gt_columns[].
****    SORT lt_relations BY id_column tabname.
****    DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING id_column tabname.
****  ELSE.
****    IF zonta_obj_oc-business_proc = 'ANY'.
****      SELECT * INTO TABLE lt_anyalia FROM zonta_oc_anyalia.
****      IF sy-subrc = 0.
****        SELECT *
****          INTO TABLE  gt_columns
****          FROM zonta_oc_col_all
****          FOR ALL ENTRIES IN lt_anyalia
****          WHERE tabname       = lt_anyalia-tabname.
*****            AND alias_tabname = lt_anyalia-alias_tabname.
****        lt_relations[] = gt_columns[].
****        SORT lt_relations BY id_column tabname.
****        DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING id_column tabname.
****      ENDIF.
****    ENDIF.
****  ENDIF.
****
****  IF lines( gt_columns ) > 0.
****
****    lt_col_single[] = gt_columns[].
*****    SORT lt_col_single BY id_column tabname alias_tabname.
*****    DELETE ADJACENT DUPLICATES FROM lt_col_single COMPARING id_column tabname alias_tabname.
****    SORT lt_col_single BY id_column tabname alias_tabname fldname.
****    DELETE ADJACENT DUPLICATES FROM lt_col_single COMPARING id_column tabname alias_tabname fldname.
****
****    IF p_mode NE 'D'.
****      LOOP AT lt_col_single INTO ls_columns.
****        APPEND INITIAL LINE TO lt_e071k ASSIGNING <fs_e071k>.
****        <fs_e071k>-pgmid      = c_r3tr.
****        <fs_e071k>-object     = c_tabu.
****        <fs_e071k>-objname    = 'ZONTA_OC_COL_ALL'.
****        <fs_e071k>-mastertype = c_tabu.
****        <fs_e071k>-mastername = 'ZONTA_OC_COL_ALL'.
****        <fs_e071>-objfunc  = 'K'.
*****      <fs_e071k>-objfunc    = p_mode.
****        CONCATENATE sy-mandt
****`                   ls_columns-id_column
****                    ls_columns-tabname
****                    ls_columns-alias_tabname
****                    ls_columns-fldname
****               INTO <fs_e071k>-tabkey RESPECTING BLANKS.
*****        <fs_e071k>-tabkey+119 = c_star."buscame
****      ENDLOOP.
****
****    ELSEIF p_mode =  'D' AND lines( gt_col_alld ) > 0 .
****      LOOP AT gt_col_alld INTO ls_columns.
****        APPEND INITIAL LINE TO lt_e071k ASSIGNING <fs_e071k>.
****        <fs_e071k>-pgmid      = c_r3tr.
****        <fs_e071k>-object     = c_tabu.
****        <fs_e071k>-objname    = 'ZONTA_OC_COL_ALL'.
****        <fs_e071k>-mastertype = c_tabu.
****        <fs_e071k>-mastername = 'ZONTA_OC_COL_ALL'.
****        <fs_e071>-objfunc  = 'K'.
*****      <fs_e071k>-objfunc    = p_mode.
****        CONCATENATE sy-mandt
****                    ls_columns-id_column
****                    ls_columns-tabname
****                    ls_columns-alias_tabname
****                    ls_columns-fldname
****               INTO <fs_e071k>-tabkey RESPECTING BLANKS.
****        <fs_e071k>-tabkey+119 = c_star.
****      ENDLOOP.
****    ENDIF.
****
****    "---------------------------
****    " Header & Keys: ZONTA_OC_CONV (only if entries exist)
****    "---------------------------
****    IF lines( lt_col_single ) > 0.
****      SELECT *
****        INTO TABLE lt_conv
****        FROM zonta_oc_conv
****        FOR ALL ENTRIES IN lt_col_single
****        WHERE tabname      = lt_col_single-tabname
****          AND alias_tabname = lt_col_single-alias_tabname.
****      SORT lt_conv BY id_column tabname alias_tabname.
****      DELETE ADJACENT DUPLICATES FROM lt_conv COMPARING ALL FIELDS.
****
****      IF lt_conv IS NOT INITIAL.
****        APPEND INITIAL LINE TO lt_e071 ASSIGNING <fs_e071>.
****        <fs_e071>-pgmid    = c_r3tr.
****        <fs_e071>-object   = c_tabu.
****        <fs_e071>-obj_name = 'ZONTA_OC_CONV'.
****        <fs_e071>-objfunc  = 'K'.
*****        <fs_e071>-objfunc  = p_mode.
****      ENDIF.
****
****      LOOP AT lt_conv INTO ls_conv.
****        APPEND INITIAL LINE TO lt_e071k ASSIGNING <fs_e071k>.
****        <fs_e071k>-pgmid      = c_r3tr.
****        <fs_e071k>-object     = c_tabu.
****        <fs_e071k>-objname    = 'ZONTA_OC_CONV'.
****        <fs_e071k>-mastertype = c_tabu.
****        <fs_e071k>-mastername = 'ZONTA_OC_CONV'.
****        <fs_e071k>-objfunc    = p_mode.
****        CONCATENATE sy-mandt
****                    ls_conv-id_column
****                    ls_conv-tabname
****                    ls_conv-alias_tabname
****                    ls_conv-fldname
****               INTO <fs_e071k>-tabkey RESPECTING BLANKS.
****        <fs_e071k>-tabkey+119 = c_star.
****      ENDLOOP.
****    ENDIF.
****  ENDIF.
****
****  "---------------------------
****  " Header: ZONTA_OC_FILTERS (only if gt_filters has entries)
****  "---------------------------
****  IF lines( gt_filters ) > 0.
****    APPEND INITIAL LINE TO lt_e071 ASSIGNING <fs_e071>.
****    <fs_e071>-pgmid    = c_r3tr.
****    <fs_e071>-object   = c_tabu.
****    <fs_e071>-obj_name = 'ZONTA_OC_FILTERS'.
****    <fs_e071>-objfunc  = 'K'.
*****    <fs_e071>-objfunc  = p_mode.
****
****    LOOP AT gt_filters INTO ls_filters.
****      APPEND INITIAL LINE TO lt_e071k ASSIGNING <fs_e071k>.
****      <fs_e071k>-pgmid      = c_r3tr.
****      <fs_e071k>-object     = c_tabu.
****      <fs_e071k>-objname    = 'ZONTA_OC_FILTERS'.
****      <fs_e071k>-mastertype = c_tabu.
****      <fs_e071k>-mastername = 'ZONTA_OC_FILTERS'.
****      <fs_e071k>-objfunc    = p_mode.
****      CONCATENATE sy-mandt
****                  zonta_obj_oc-domainv
****                  zonta_obj_oc-business_proc
****                  ls_filters-variant
****                  ls_filters-tabname
****                  ls_filters-counter
****             INTO <fs_e071k>-tabkey RESPECTING BLANKS.
****      <fs_e071k>-tabkey+119 = c_star.
****    ENDLOOP.
****  ENDIF.
****
****  "---------------------------
****  " Objects ZONTA_OC_DDIC
****  "---------------------------
****  SELECT *
****    INTO TABLE lt_ddic
****    FROM zonta_oc_ddic
****    WHERE id = zonta_obj_oc-id
****      AND domainv = zonta_obj_oc-domainv
****      AND business_proc = zonta_obj_oc-business_proc.
****  IF lines( lt_ddic ) > 0.
****    APPEND INITIAL LINE TO lt_e071 ASSIGNING <fs_e071>.
****    <fs_e071>-pgmid    = c_r3tr.
****    <fs_e071>-object   = c_tabu.
****    <fs_e071>-obj_name = 'ZONTA_OC_DDIC'.
****    <fs_e071>-objfunc  = 'K'.
****
****    LOOP AT lt_ddic INTO ls_ddic.
****      APPEND INITIAL LINE TO lt_e071k ASSIGNING <fs_e071k>.
****      <fs_e071k>-pgmid      = c_r3tr.
****      <fs_e071k>-object     = c_tabu.
****      <fs_e071k>-objname    = 'ZONTA_OC_DDIC'.
****      <fs_e071k>-mastertype = c_tabu.
****      <fs_e071k>-mastername = 'ZONTA_OC_DDIC'.
****      <fs_e071k>-objfunc    = p_mode.
****      CONCATENATE sy-mandt
****                  ls_ddic-id
****                  ls_ddic-domainv
****                  ls_ddic-business_proc
****                  ls_ddic-object
****             INTO <fs_e071k>-tabkey RESPECTING BLANKS.
****      <fs_e071k>-tabkey+119 = c_star.
****    ENDLOOP.
****  ENDIF.
****
****  "---------------------------
****  " Header: ZONTA_OC_FRANGES (only if gt_franges has entries)
****  "---------------------------
****  IF lines( gt_franges ) > 0.
****    APPEND INITIAL LINE TO lt_e071 ASSIGNING <fs_e071>.
****    <fs_e071>-pgmid    = c_r3tr.
****    <fs_e071>-object   = c_tabu.
****    <fs_e071>-obj_name = 'ZONTA_OC_FRANGES'.
****    <fs_e071>-objfunc  = 'K'.
*****    <fs_e071>-objfunc  = p_mode.
****
****    LOOP AT gt_franges INTO ls_franges.
****      APPEND INITIAL LINE TO lt_e071k ASSIGNING <fs_e071k>.
****      <fs_e071k>-pgmid      = c_r3tr.
****      <fs_e071k>-object     = c_tabu.
****      <fs_e071k>-objname    = 'ZONTA_OC_FRANGES'.
****      <fs_e071k>-mastertype = c_tabu.
****      <fs_e071k>-mastername = 'ZONTA_OC_FRANGES'.
****      <fs_e071k>-objfunc    = p_mode.
****      CONCATENATE sy-mandt
****                  zonta_obj_oc-domainv
****                  zonta_obj_oc-business_proc
****                  ls_franges-variant
****                  ls_franges-tabname
****                  ls_franges-counter
****             INTO <fs_e071k>-tabkey RESPECTING BLANKS.
****      <fs_e071k>-tabkey+119 = c_star.
****    ENDLOOP.
****  ENDIF.
****
****  "---------------------------
****  " Header: ZONTA_OC_AUTH (only if gs_auth is not initial)
****  "---------------------------
****  IF gs_auth IS NOT INITIAL.
****    APPEND INITIAL LINE TO lt_e071 ASSIGNING <fs_e071>.
****    <fs_e071>-pgmid    = c_r3tr.
****    <fs_e071>-object   = c_tabu.
****    <fs_e071>-obj_name = 'ZONTA_OC_AUTH'.
****    <fs_e071>-objfunc  = 'K'.
*****    <fs_e071>-objfunc  = p_mode.
****
****    APPEND INITIAL LINE TO lt_e071k ASSIGNING <fs_e071k>.
****    <fs_e071k>-pgmid      = c_r3tr.
****    <fs_e071k>-object     = c_tabu.
****    <fs_e071k>-objname    = 'ZONTA_OC_AUTH'.
****    <fs_e071k>-mastertype = c_tabu.
****    <fs_e071k>-mastername = 'ZONTA_OC_AUTH'.
****    <fs_e071k>-objfunc    = p_mode.
****    CONCATENATE sy-mandt
****                zonta_obj_oc-id
****           INTO <fs_e071k>-tabkey RESPECTING BLANKS.
****  ENDIF.
****
****  "---------------------------
****  " Header: ZONTA_OC_ANYALIA (only if is ANY Entity)
****  "---------------------------
****  IF zonta_obj_oc-business_proc = 'ANY'.
****    APPEND INITIAL LINE TO lt_e071 ASSIGNING <fs_e071>.
****    <fs_e071>-pgmid    = c_r3tr.
****    <fs_e071>-object   = c_tabu.
****    <fs_e071>-obj_name = 'ZONTA_OC_ANYALIA'.
****    <fs_e071>-objfunc  = 'K'.
****
****    SELECT * INTO TABLE lt_anyalia FROM zonta_oc_anyalia.
****
****    LOOP AT lt_anyalia INTO lw_anyalia.
****      APPEND INITIAL LINE TO lt_e071k ASSIGNING <fs_e071k>.
****      <fs_e071k>-pgmid      = c_r3tr.
****      <fs_e071k>-object     = c_tabu.
****      <fs_e071k>-objname    = 'ZONTA_OC_ANYALIA'.
****      <fs_e071k>-mastertype = c_tabu.
****      <fs_e071k>-mastername = 'ZONTA_OC_ANYALIA'.
****      <fs_e071k>-objfunc    = 'K'.
*****      <fs_e071k>-objfunc    = p_mode.
****      CONCATENATE sy-mandt
****                  lw_anyalia-tabname
****             INTO <fs_e071k>-tabkey RESPECTING BLANKS.
*****      <fs_e071k>-tabkey+119 = c_star.
****    ENDLOOP.
****  ENDIF.
****
****
****
****  "Return to caller
*****   p_e070[]  = value #( ).
****  p_e070[]  = lt_e070[].
****  p_e071[]  = lt_e071[].
****  p_e071k[] = lt_e071k[].
ENDFORM.                    "save_custom_tables_into_tr

*&---------------------------------------------------------------------*
*& Form get_next_range
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      <-- LV_NEXT
*&---------------------------------------------------------------------*
FORM get_next_range  USING    p_range
                     CHANGING p_next TYPE zonde_id.


*perform get_next_range using 'ZONR_COL_A' changing lv_next.

  DATA: lv_number     TYPE n LENGTH 10,
        lv_returncode TYPE inri-returncode,
        lv_object     TYPE inri-object.

  lv_object = p_range.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = '01'
      object                  = lv_object
      quantity                = '1'
    IMPORTING
      number                  = lv_number
      returncode              = lv_returncode
    EXCEPTIONS
      interval_not_found      = 1
      number_range_not_intern = 2
      object_not_found        = 3
      quantity_is_0           = 4
      quantity_is_not_1       = 5
      interval_overflow       = 6
      buffer_overflow         = 7
      OTHERS                  = 8.

  IF sy-subrc = 0.
    p_next = lv_number.
  ELSE.
    p_next = 0.
    MESSAGE e208(00) WITH 'Please configure Z Range'."CECHAVARRIA 01/07/2025
  ENDIF.


ENDFORM.                    "get_next_range
*&---------------------------------------------------------------------*
*& Form check_entity_name
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_entity_name .


  CONSTANTS: c_guion TYPE c VALUE '_'.
  DATA: lv_first  TYPE string,
        lv_second TYPE string.

  TYPES: BEGIN OF st_table,
           data TYPE c LENGTH 255,
         END OF st_table.

  DATA:
    lt_tab TYPE STANDARD TABLE OF st_table,
    ls_tab TYPE st_table.


  IF zonta_obj_oc-business_proc CS space.
    SPLIT  zonta_obj_oc-business_proc  AT space INTO TABLE lt_tab.
    LOOP AT lt_tab INTO ls_tab.
      CONCATENATE lv_second ls_tab-data INTO lv_second SEPARATED BY '_'.
    ENDLOOP.
    zonta_obj_oc-business_proc  = lv_second.
    SHIFT  zonta_obj_oc-business_proc BY 1 PLACES .
  ENDIF.


ENDFORM.                    "check_entity_name




*&---------------------------------------------------------------------*
*& Form save_entity_into_tr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_entity_into_tr .

  CONSTANTS: c_r3tr TYPE c LENGTH 4 VALUE 'R3TR',
             c_tabu TYPE c LENGTH 4 VALUE 'TABU',
             c_tabl TYPE c LENGTH 4 VALUE 'TABL',
             c_ttyp TYPE c LENGTH 4 VALUE 'TTYP',
             c_k    TYPE c LENGTH 1 VALUE 'K'.

  CONSTANTS: c_n    TYPE c LENGTH 1 VALUE 'N',
             c_a    TYPE c LENGTH 1 VALUE 'A',
             c_l    TYPE c LENGTH 1 VALUE 'L',
             c_star TYPE c LENGTH 1 VALUE '*'.

  DATA: lv_id TYPE dd40l-typename.

  DATA: lt_tablet TYPE STANDARD TABLE OF dd40l,
        ls_tablet TYPE dd40l,
        lt_struct TYPE STANDARD TABLE OF dd02l,
        ls_struct TYPE dd02l.

  DATA: ls_tables      LIKE LINE OF gt_tables_alv,
        ls_columns     LIKE LINE OF gt_columns,
        lt_relations   TYPE STANDARD TABLE OF zonta_oc_col_all,
        ls_relations   TYPE zonta_oc_col_all,
        ls_columns_alv LIKE LINE OF gt_columns_alv.
  DATA: lt_e071_curr TYPE STANDARD TABLE OF e071,
        ls_e071_curr TYPE e071,
        lt_e071      TYPE STANDARD TABLE OF e071,
        lt_e071_val  TYPE STANDARD TABLE OF e071,
        lt_e071_del  TYPE STANDARD TABLE OF e071,
        lt_e071k     TYPE STANDARD TABLE OF e071k,
        lt_e070      TYPE STANDARD TABLE OF e070,
        lt_ddic      TYPE STANDARD TABLE OF zonta_oc_ddic,
        ls_ddic      LIKE LINE OF lt_ddic,
        ls_e070      TYPE e070,
        ls_e071      TYPE e071, "++TRKORR DB
        ls_request   TYPE trwbo_request,
        lv_order     TYPE e071-trkorr,
        lv_task      TYPE e071-trkorr,
        lv_pos       TYPE e071-as4pos,
        lv_post      TYPE e071k-as4pos,
        lv_error     TYPE boolean,
        lv_message   TYPE string,
        lv_subrc     TYPE sy-subrc. "++TRKORR DB

  DATA: lt_tlock_pr   TYPE STANDARD TABLE OF st_tlock,
        lt_tlock      TYPE STANDARD TABLE OF st_tlock,
        lt_objects    TYPE STANDARD TABLE OF e071,   "++TRKORR DB
        lt_col_single TYPE STANDARD TABLE OF zonta_oc_col_all,
        lt_conv       TYPE STANDARD TABLE OF zonta_oc_conv,
        ls_conv       TYPE zonta_oc_conv.

  FIELD-SYMBOLS: <fs_e071>     LIKE LINE OF lt_e071,
                 <fs_e071_del> LIKE LINE OF lt_e071,
                 <fs_e071k>    LIKE LINE OF lt_e071k,
                 <fs_tlock>    TYPE st_tlock.


  IF zonta_obj_oc-domainv IS INITIAL.
    MESSAGE e007(zon_cl_oc) DISPLAY LIKE 'I'.
  ELSE.
* Change position TRKORR DB
    CALL FUNCTION 'TRINT_ORDER_CHOICE'
      EXPORTING
        wi_order_type          = 'K'
        wi_task_type           = 'S'
        wi_category            = 'SYST'
      IMPORTING
        we_order               = lv_order
        we_task                = lv_task
      TABLES
        wt_e071                = lt_e071
        wt_e071k               = lt_e071k
      EXCEPTIONS
        no_correction_selected = 1
        display_mode           = 2
        object_append_error    = 3
        recursive_call         = 4
        wrong_order_type       = 5
        OTHERS                 = 6.
    lv_subrc  = sy-subrc.
    gv_order = lv_task.
* End of TRKORR DB


* First regenerate the Entity
    PERFORM regenerate.
    WAIT UP TO 5 SECONDS.
    DATA v_tryoff TYPE c.
    SELECT SINGLE low INTO v_tryoff FROM zonta_oc_param WHERE name = 'SET_TRY_OFF'.
    IF v_tryoff IS NOT INITIAL.
      CALL METHOD go_json->get_objects  "++TRKORR DB
        IMPORTING
          et_objects = lt_objects[].
    ELSE.
      TRY.

          CALL METHOD go_json->get_objects  "++TRKORR DB
            IMPORTING
              et_objects = lt_objects[].
        CATCH cx_root INTO gx_text.
          PERFORM send_error_to_screen.
      ENDTRY.
    ENDIF.
    CHECK lv_subrc = 0.   "<>TRKORR DB

**    SELECT MAX( as4pos )
**      INTO lv_pos
**      FROM e071
**      WHERE trkorr = lv_task.
**
**
*** Save main customizing
**    SELECT MAX( as4pos )
**      INTO lv_post
**      FROM e071k
**      WHERE trkorr  = lv_task
**        AND pgmid   = c_r3tr
**        AND object  = c_tabu
**        AND objname = 'ZONTA_OBJ_OC'.
**
**    APPEND INITIAL LINE TO lt_e071 ASSIGNING <fs_e071>.
**    lv_pos = lv_pos + 1.
**    <fs_e071>-trkorr      = lv_task.
**    <fs_e071>-as4pos      = lv_pos.
**    <fs_e071>-pgmid       = c_r3tr.
**    <fs_e071>-object      = c_tabu.
**    <fs_e071>-obj_name    = 'ZONTA_OBJ_OC'.
**    <fs_e071>-objfunc     = c_k.
**    <fs_e071>-lockflag    = 'X'.
**
**    APPEND INITIAL LINE TO lt_e071k ASSIGNING <fs_e071k>.
**    lv_post = lv_post + 1.
**    <fs_e071k>-trkorr     = lv_task.
**    <fs_e071k>-as4pos     = lv_post.
**    <fs_e071k>-pgmid      = c_r3tr.
**    <fs_e071k>-object     = c_tabu.
**    <fs_e071k>-objname    = 'ZONTA_OBJ_OC'.
**    <fs_e071k>-mastertype = c_tabu.
**    <fs_e071k>-mastername = 'ZONTA_OBJ_OC'.
**    CONCATENATE sy-mandt zonta_obj_oc-id zonta_obj_oc-domainv zonta_obj_oc-business_proc INTO <fs_e071k>-tabkey
**                RESPECTING BLANKS.
**
*** Save relations
**    SELECT MAX( as4pos )
**      INTO lv_post
**      FROM e071k
**      WHERE trkorr  = lv_task
**        AND pgmid   = c_r3tr
**        AND object  = c_tabu
**        AND objname = 'ZONTA_RELATIONS'.
**
**    APPEND INITIAL LINE TO lt_e071 ASSIGNING <fs_e071>.
**    lv_pos = lv_pos + 1.
**    <fs_e071>-trkorr      = lv_task.
**    <fs_e071>-as4pos      = lv_pos.
**    <fs_e071>-pgmid       = c_r3tr.
**    <fs_e071>-object      = c_tabu.
**    <fs_e071>-obj_name     = 'ZONTA_RELATIONS'.
**    <fs_e071>-objfunc     = c_k.
**    <fs_e071>-lockflag    = 'X'.
**
**    LOOP AT gt_tables_alv INTO ls_tables.
**      APPEND INITIAL LINE TO lt_e071k ASSIGNING <fs_e071k>.
**      lv_post = lv_post + 1.
**      <fs_e071k>-trkorr      = lv_task.
**      <fs_e071k>-as4pos      = lv_post.
**      <fs_e071k>-pgmid      = c_r3tr.
**      <fs_e071k>-object     = c_tabu.
**      <fs_e071k>-objname    = 'ZONTA_RELATIONS'.
**      <fs_e071k>-mastertype = c_tabu.
**      <fs_e071k>-mastername = 'ZONTA_RELATIONS'.
**      CONCATENATE sy-mandt zonta_obj_oc-id zonta_obj_oc-domainv zonta_obj_oc-business_proc
**                  ls_tables-tabname ls_tables-field_main ls_tables-field_sec INTO <fs_e071k>-tabkey
**                  RESPECTING BLANKS.
**      <fs_e071k>-tabkey+119(1) = c_star.
**    ENDLOOP.
**
*** Save columns
**    SELECT MAX( as4pos )
**      INTO lv_post
**      FROM e071k
**      WHERE trkorr  = lv_task
**        AND pgmid   = c_r3tr
**        AND object  = c_tabu
**        AND objname = 'ZONTA_OC_COL_ALL'.
**
**    APPEND INITIAL LINE TO lt_e071 ASSIGNING <fs_e071>.
**    lv_pos = lv_pos + 1.
**    <fs_e071>-trkorr      = lv_task.
**    <fs_e071>-as4pos      = lv_pos.
**    <fs_e071>-pgmid       = c_r3tr.
**    <fs_e071>-object      = c_tabu.
**    <fs_e071>-obj_name    = 'ZONTA_OC_COL_ALL'.
**    <fs_e071>-objfunc     = c_k.
**    <fs_e071>-lockflag    = 'X'.
**
**
**    IF lines( gt_tables_alv ) > 0.
**      SELECT *
**        INTO TABLE  gt_columns
**        FROM zonta_oc_col_all
**        FOR ALL ENTRIES IN gt_tables_alv
**        WHERE tabname       = gt_tables_alv-tabname
**          AND alias_tabname = gt_tables_alv-alias_tabname.
**      lt_relations[] = gt_columns[].
**      SORT lt_relations BY id_column tabname.
**      DELETE ADJACENT DUPLICATES FROM lt_relations COMPARING id_column tabname.
**    ENDIF.
**
**    IF lines( gt_columns ) = 0.
**    ELSE.
**      lt_col_single[] = gt_columns[].
**      SORT lt_col_single BY id_column tabname alias_tabname.
**      DELETE ADJACENT DUPLICATES FROM lt_col_single COMPARING id_column tabname alias_tabname.
**      LOOP AT lt_col_single INTO ls_columns.
**        APPEND INITIAL LINE TO lt_e071k ASSIGNING <fs_e071k>.
**        lv_post = lv_post + 1.
**        <fs_e071k>-trkorr     = lv_task.
**        <fs_e071k>-as4pos     = lv_post.
**        <fs_e071k>-pgmid      = c_r3tr.
**        <fs_e071k>-object     = c_tabu.
**        <fs_e071k>-objname    = 'ZONTA_OC_COL_ALL'.
**        <fs_e071k>-mastertype = c_tabu.
**        <fs_e071k>-mastername = 'ZONTA_OC_COL_ALL'.
**        CONCATENATE sy-mandt ls_columns-id_column ls_columns-tabname
**                    ls_columns-alias_tabname c_star INTO <fs_e071k>-tabkey
**                    RESPECTING BLANKS.
**      ENDLOOP.
**
*** Save conversion table
**      IF lines( lt_col_single ) > 0.
**        SELECT *
**          INTO TABLE lt_conv
**          FROM zonta_oc_conv
**          FOR ALL ENTRIES IN lt_col_single
**          WHERE tabname = lt_col_single-tabname
**            AND alias_tabname = lt_col_single-alias_tabname.
**      ENDIF.
**      SORT lt_conv BY id_column tabname alias_tabname.
***      DELETE ADJACENT DUPLICATES FROM lt_conv COMPARING id_column tabname alias_tabname.
**      DELETE ADJACENT DUPLICATES FROM lt_conv COMPARING ALL FIELDS.
**
***--------------------------------------------------------------------* *
**
*** *** BEGIN OF FIX *** *
*** Add the main object header entry for the ZONTA_OC_CONV table.      *
*** This must be done before adding the individual keys (E071K).       *
***--------------------------------------------------------------------*
**      IF lt_conv IS NOT INITIAL.
**        APPEND INITIAL LINE TO lt_e071 ASSIGNING <fs_e071>.
**        lv_pos = lv_pos + 1.
**        <fs_e071>-trkorr      = lv_task.
**        <fs_e071>-as4pos      = lv_pos.
**        <fs_e071>-pgmid       = c_r3tr.
**        <fs_e071>-object      = c_tabu.
**        <fs_e071>-obj_name    = 'ZONTA_OC_CONV'. "<- The missing object
**        <fs_e071>-objfunc     = c_k.
**        <fs_e071>-lockflag    = 'X'.
**      ENDIF.
***--------------------------------------------------------------------*
*** *** END OF FIX *** *
***--------------------------------------------------------------------*
**
***--------------------------------------------------------------------* *
**
**
**      LOOP AT lt_conv INTO ls_conv.
**        APPEND INITIAL LINE TO lt_e071k ASSIGNING <fs_e071k>.
**        lv_post = lv_post + 1.
**        <fs_e071k>-trkorr     = lv_task.
**        <fs_e071k>-as4pos     = lv_post.
**        <fs_e071k>-pgmid      = c_r3tr.
**        <fs_e071k>-object     = c_tabu.
**        <fs_e071k>-objname    = 'ZONTA_OC_CONV'.
**        <fs_e071k>-mastertype = c_tabu.
**        <fs_e071k>-mastername = 'ZONTA_OC_CONV'.
**        CONCATENATE sy-mandt ls_conv-id_column ls_conv-tabname
**                     ls_conv-alias_tabname ls_conv-fldname INTO <fs_e071k>-tabkey
**                    RESPECTING BLANKS.
**        <fs_e071k>-tabkey+119(1) = c_star.
**      ENDLOOP.
**    ENDIF.

    " Build headers+keys (no AS4POS, no LOCKFLAG, no wildcards)
    PERFORM save_custom_tables_into_tr
                                   TABLES lt_e070[]
                                          lt_e071[]
                                          lt_e071k[]
                                   USING  c_k.

** Begin of insert TRKORR DB
    LOOP AT lt_objects INTO ls_e071.
      APPEND INITIAL LINE TO lt_e071 ASSIGNING <fs_e071>.
      lv_pos = lv_pos + 1.
      MOVE-CORRESPONDING ls_e071 TO <fs_e071>.
      <fs_e071>-trkorr      = lv_task.
      <fs_e071>-as4pos      = lv_pos.
    ENDLOOP.
** End of insert TRKORR DB

    lt_e071_val[] = lt_e071[].
    DELETE lt_e071_val WHERE object = c_tabu.
    IF lines( lt_e071_val ) > 0.
      lv_error = abap_false.

* Search entries in current transports
      SELECT *
        INTO TABLE lt_e071_curr
        FROM e071
        FOR ALL ENTRIES IN lt_e071_val
        WHERE obj_name = lt_e071_val-obj_name
          AND lockflag = 'X'.   "FIXDB2
      DELETE lt_e071_curr WHERE trkorr = lv_task.  "FIXDB

      IF lines( lt_e071_curr ) > 0.
* Search for Modifiable transports
        SELECT *
          INTO TABLE lt_e070
          FROM e070
          FOR ALL ENTRIES IN lt_e071_curr
          WHERE trkorr = lt_e071_curr-trkorr
            AND trstatus NE 'R'.
        IF sy-subrc = 0.
        ENDIF.
      ENDIF.
    ENDIF.

* Check for lock transports
    IF lines( lt_e071_curr ) > 0.
      CLEAR lt_tlock.
      LOOP AT lt_e071_curr INTO ls_e071.
        APPEND INITIAL LINE TO lt_tlock ASSIGNING <fs_tlock>.
        <fs_tlock>-trkorr = ls_e071-trkorr.
      ENDLOOP.

      SORT lt_tlock BY trkorr.
      DELETE ADJACENT DUPLICATES FROM lt_tlock COMPARING trkorr.
      PERFORM unlock_tr_entries TABLES lt_tlock[].
    ENDIF.

    IF lv_error = abap_true.
      MESSAGE e026(zon_cl_oc) DISPLAY LIKE 'I'.
    ELSE.

      WAIT UP TO 5 SECONDS.
      CALL FUNCTION 'TR_APPEND_TO_COMM_OBJS_KEYS'
        EXPORTING
          wi_trkorr                      = lv_task
          wi_suppress_key_check          = ' '  "FIXDB
        TABLES
          wt_e071                        = lt_e071
          wt_e071k                       = lt_e071k
        EXCEPTIONS
          key_char_in_non_char_field     = 1
          key_check_keysyntax_error      = 2
          key_inttab_table               = 3
          key_longer_field_but_no_generc = 4
          key_missing_key_master_fields  = 5
          key_missing_key_tablekey       = 6
          key_non_char_but_no_generic    = 7
          key_no_key_fields              = 8
          key_string_longer_char_key     = 9
          key_table_has_no_fields        = 10
          key_table_not_activ            = 11
          key_unallowed_key_function     = 12
          key_unallowed_key_object       = 13
          key_unallowed_key_objname      = 14
          key_unallowed_key_pgmid        = 15
          key_without_header             = 16
          ob_check_obj_error             = 17
          ob_devclass_no_exist           = 18
          ob_empty_key                   = 19
          ob_generic_objectname          = 20
          ob_ill_delivery_transport      = 21
          ob_ill_lock                    = 22
          ob_ill_parts_transport         = 23
          ob_ill_source_system           = 24
          ob_ill_system_object           = 25
          ob_ill_target                  = 26
          ob_inttab_table                = 27
          ob_local_object                = 28
          ob_locked_by_other             = 29
          ob_modif_only_in_modif_order   = 30
          ob_name_too_long               = 31
          ob_no_append_of_corr_entry     = 32
          ob_no_append_of_c_member       = 33
          ob_no_consolidation_transport  = 34
          ob_no_original                 = 35
          ob_no_shared_repairs           = 36
          ob_no_systemname               = 37
          ob_no_systemtype               = 38
          ob_no_tadir                    = 39
          ob_no_tadir_not_lockable       = 40
          ob_privat_object               = 41
          ob_repair_only_in_repair_order = 42
          ob_reserved_name               = 43
          ob_syntax_error                = 44
          ob_table_has_no_fields         = 45
          ob_table_not_activ             = 46
          tr_enqueue_failed              = 47
          tr_errors_in_error_table       = 48
          tr_ill_korrnum                 = 49
          tr_lockmod_failed              = 50
          tr_lock_enqueue_failed         = 51
          tr_not_owner                   = 52
          tr_no_systemname               = 53
          tr_no_systemtype               = 54
          tr_order_not_exist             = 55
          tr_order_released              = 56
          tr_order_update_error          = 57
          tr_wrong_order_type            = 58
          ob_invalid_target_system       = 59
          tr_no_authorization            = 60
          ob_wrong_tabletyp              = 61
          ob_wrong_category              = 62
          ob_system_error                = 63
          ob_unlocal_objekt_in_local_ord = 64
          tr_wrong_client                = 65
          ob_wrong_client                = 66
          key_wrong_client               = 67
          OTHERS                         = 68.
      IF sy-subrc <> 0.
        MESSAGE ID syst-msgid TYPE syst-msgty NUMBER syst-msgno WITH syst-msgv1 syst-msgv2 syst-msgv3 syst-msgv4.
      ELSE.
* Begin of FIXDB2
* sort and compress original task
        CALL FUNCTION 'TR_SORT_AND_COMPRESS_COMM'
          EXPORTING
            iv_trkorr                      = lv_task
            iv_dialog                      = ' '
          EXCEPTIONS
            trkorr_not_found               = 1
            order_released                 = 2
            error_while_modifying_obj_list = 3
            tr_enqueue_failed              = 4
            no_authorization               = 5
            OTHERS                         = 6.

* Unlock entries from the new transport
        REFRESH lt_tlock.
        APPEND INITIAL LINE TO lt_tlock ASSIGNING <fs_tlock>.
        <fs_tlock>-trkorr = lv_task.
        IF lines( lt_tlock ) > 0.
          PERFORM unlock_tr_entries TABLES lt_tlock[].
        ENDIF.
* End of FIXDB2

        MESSAGE s027(zon_cl_oc) WITH zonta_obj_oc-business_proc lv_order DISPLAY LIKE 'S'.
      ENDIF.
    ENDIF.
  ENDIF.

  CLEAR gv_order. "++TRKORR DB
ENDFORM.                    "save_entity_into_tr



*&---------------------------------------------------------------------*
*& Form update_main_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
*& Form update_main_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_main_screen .
  LOOP AT SCREEN.
    IF screen-group1 = 'MOD'.
      CASE gv_system.
        WHEN 'X'.
          screen-input = '1'.
        WHEN space.
          screen-input = '0'.
      ENDCASE.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "update_main_screen
*&---------------------------------------------------------------------*
*& Form change_owner
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_E070_TRKORR
*&      --> LS_E070_AS4USER
*&---------------------------------------------------------------------*
FORM change_owner  USING    p_trkorr
                            p_user.

  CALL FUNCTION 'TR_CHANGE_USERNAME'
    EXPORTING
      wi_dialog           = ' '
      wi_trkorr           = p_trkorr
      wi_user             = p_user
      wi_start_column     = 30
      wi_start_row        = 10
    EXCEPTIONS
      already_released    = 1
      e070_update_error   = 2
      file_access_error   = 3
      not_exist_e070      = 4
      user_does_not_exist = 5
      tr_enqueue_failed   = 6
      no_authorization    = 7
      wrong_client        = 8
      unallowed_user      = 9
      OTHERS              = 10.
  IF sy-subrc <> 0.

  ENDIF.


ENDFORM.                    "change_owner
*&---------------------------------------------------------------------*
*& Form enqueue_tr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_E070_TRKORR
*&---------------------------------------------------------------------*
FORM enqueue_tr  USING    p_trkorr.
  CALL FUNCTION 'ENQUEUE_E_TRKORR'
    EXPORTING
      trkorr = p_trkorr.
ENDFORM.                    "enqueue_tr
*&---------------------------------------------------------------------*
*& Form dequeue_tr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_E070_TRKORR
*&---------------------------------------------------------------------*
FORM dequeue_tr  USING    p_trkorr.

  CALL FUNCTION 'DEQUEUE_E_TRKORR'
    EXPORTING
      trkorr = p_trkorr.

ENDFORM.                    "dequeue_tr
*&---------------------------------------------------------------------*
*& Form unlock_entries
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_TLOCK[]
*&---------------------------------------------------------------------*
FORM unlock_tr_entries TABLES   p_tlock .

  DATA: ls_tlock   TYPE st_tlock,
        ls_request TYPE trwbo_request,
        ls_h       TYPE trwbo_request_header.

  LOOP AT p_tlock INTO ls_tlock.
* Unlock the entries
    CLEAR ls_request.

    PERFORM enqueue_tr USING ls_tlock-trkorr.
    ls_h-trkorr = ls_tlock-trkorr.
    ls_request-h = ls_h.

    CALL FUNCTION 'TRINT_UNLOCK_REQUEST'
      EXPORTING
        iv_safe_mode           = ' '
      CHANGING
        cs_request             = ls_request
      EXCEPTIONS
        db_access_error        = 1
        object_enqueues        = 2
        no_authority           = 3
        request_not_changeable = 4
        OTHERS                 = 5.
    PERFORM dequeue_tr USING ls_tlock-trkorr.
  ENDLOOP.

ENDFORM.                    "unlock_tr_entries
*&---------------------------------------------------------------------*
*& Form lock_tr_entries
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_TLOCK[]
*&---------------------------------------------------------------------*
FORM lock_tr_entries  TABLES   p_tlock .


  DATA: ls_tlock    TYPE st_tlock,
        lt_messages TYPE ctsgerrmsgs.

  LOOP AT p_tlock INTO ls_tlock.
* Unlock the entries

    PERFORM enqueue_tr USING ls_tlock-trkorr.

    CALL FUNCTION 'TR_LOCK_REQUEST'
      EXPORTING
        iv_trkorr          = ls_tlock-trkorr
        iv_success_message = ' '
        iv_dialog          = ' '
      EXCEPTIONS
        error_occured      = 1
        wrong_call         = 2
        OTHERS             = 3.

    PERFORM dequeue_tr USING ls_tlock-trkorr.
  ENDLOOP.

ENDFORM.                    "lock_tr_entries



*&---------------------------------------------------------------------*
*&      Form  send_error_to_screen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM send_error_to_screen.

  DATA: lo_out        TYPE REF TO if_demo_output,
        lv_text_error TYPE string,
        it_log_ext    TYPE STANDARD TABLE OF zonst_oc_log_ext.

  lo_out = cl_demo_output=>new( ).
  lo_out->begin_section( 'ONE CONNECT EXECUTION LOG' ).

  lo_out->write_data( zonta_obj_oc-business_proc ).

  lo_out->write_data( gx_text->get_text( ) ).
  lo_out->write_data( gx_text->get_longtext( ) ).

  lo_out->display( ).

  lv_text_error = gx_text->get_text( ).

  IF go_json IS BOUND.
    "Log the operation
    go_json->append_slg1_log(
      iv_tabname    = space
      iv_message_v1 = 'ERROR'
      iv_message_v3 = lv_text_error
      iv_mestyp     = 'E' ).
    go_json->return_log_table( IMPORTING et_log_ext = it_log_ext[] ).
    go_json->update_slg1_log( it_log_ext = it_log_ext ).
  ENDIF.

ENDFORM.                    "send_error_to_screen
*&---------------------------------------------------------------------*
*& Form check_fields_lenght
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_fields_lenght .
  DATA: lt_col_temp TYPE STANDARD TABLE OF zonta_oc_col_all,
        ls_col_temp LIKE LINE OF lt_col_temp,
        lv_message  TYPE boolean.

  lv_message = abap_false.
  IF lines( gt_tables_alv ) > 0.
    SELECT *
      INTO TABLE lt_col_temp
      FROM zonta_oc_col_all
            FOR ALL ENTRIES IN gt_tables_alv
          WHERE tabname = gt_tables_alv-tabname
            AND alias_tabname = gt_tables_alv-alias_tabname.
  ENDIF.

  LOOP AT lt_col_temp INTO ls_col_temp.
    IF strlen( ls_col_temp-fldname ) > 27."@VAREX 11.06.26 FRG
      lv_message = abap_true.
    ENDIF.
  ENDLOOP.

  IF lv_message = abap_true.
    MESSAGE w035(zon_cl_oc)  DISPLAY LIKE 'W'.
  ENDIF.
ENDFORM.                    "check_fields_lenght
*&---------------------------------------------------------------------*
*& Form save_ddic_objects
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_ddic_objects .
  DATA:   lt_ddic     TYPE STANDARD TABLE OF zonta_oc_ddic.

  CALL METHOD go_json->get_objects  "++TRKORR DB
    IMPORTING
      et_ddic = lt_ddic[].

  IF lines( lt_ddic ) > 0.
    DELETE zonta_oc_ddic FROM TABLE lt_ddic.
  ENDIF.

  MODIFY zonta_oc_ddic FROM TABLE lt_ddic.
  IF sy-subrc = 0.
    COMMIT WORK.
  ENDIF.
ENDFORM.                    "save_ddic_objects

*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form update_grid_fin
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM update_grid_fin USING p_grid TYPE REF TO cl_gui_alv_grid.
  DATA lv_stable TYPE lvc_s_stbl.

  CHECK p_grid IS BOUND.
*
  CLEAR lv_stable.
  MOVE abap_true TO:
    lv_stable-col,
    lv_stable-row.

  IF gv_option = co_display.
    CALL METHOD p_grid->set_ready_for_input
      EXPORTING
        i_ready_for_input = 0.
  ELSE.
    CALL METHOD p_grid->set_ready_for_input
      EXPORTING
        i_ready_for_input = 1.
  ENDIF.

*  TRY.
  CALL METHOD p_grid->refresh_table_display.
*    CATCH cx_salv_method_not_supported.
  CALL METHOD p_grid->refresh_table_display
    EXPORTING
      i_soft_refresh = 'X'
      is_stable      = lv_stable
    EXCEPTIONS
      OTHERS         = 99.
*  ENDTRY.


  IF gv_alias_error = abap_true.
    CLEAR gv_alias_error.
    MESSAGE i037(zon_cl_oc) DISPLAY LIKE 'I'.
  ENDIF.
ENDFORM.                    "update_grid_fin
*&---------------------------------------------------------------------*
*& Form handle_pass_to_right_tree
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM handle_pass_to_right_tree .
  CONSTANTS: lc_child TYPE string     VALUE 'Child_',
             lc_root  TYPE tm_nodekey VALUE 'Root',
             lc_par1  TYPE c          VALUE '(',
             lc_par2  TYPE c          VALUE ')'.

  DATA: node TYPE treemsnodt. "mtreesnode.
  DATA: lt_tables_rel TYPE zontt_relations,
        lt_columns    TYPE zontt_col_all,
        node_itab     LIKE node_itab_left,
        handle_tree   TYPE i,
        lv_parent     TYPE tm_nodekey,

*        lv_fldname    TYPE fieldname,
        ls_tables_alv LIKE LINE OF gt_tables_alv,
        ls_tables_rel LIKE LINE OF lt_tables_rel,
        ls_col_info   LIKE LINE OF gt_col_info.

  DATA: ls_tables  LIKE LINE OF lt_tables_rel,
        ls_columns LIKE LINE OF lt_columns.

  FIELD-SYMBOLS: <fs_col> LIKE LINE OF gt_columns_alv.

  CLEAR gt_col_info[].
  CLEAR node_itab[].

  CALL METHOD behaviour_right->get_handle
    IMPORTING
      handle = handle_tree.

  CLEAR lt_tables_rel[].
  LOOP AT gt_tables_alv INTO ls_tables_alv.
    CLEAR ls_tables_rel.
    MOVE-CORRESPONDING ls_tables_alv TO ls_tables_rel.
    APPEND ls_tables_rel TO lt_tables_rel.
  ENDLOOP.

  SORT lt_tables_rel BY tabname.
  DELETE ADJACENT DUPLICATES FROM lt_tables_rel COMPARING tabname.

  CALL METHOD go_cust->fill_info_field_new
    EXPORTING
      it_tables       = lt_tables_rel[]
      it_columns      = gt_columns_alv[]
    IMPORTING
      et_columns      = lt_columns[]
      et_existing_rel = gt_ex_rel[]
      et_existing_col = gt_ex_col[].

  SORT gt_ex_rel BY tabname.

  gt_col_info[] = lt_columns[].

* node table of the left tree
  CLEAR node.
  node-node_key = lc_root.
  node-isfolder = 'X'.
  node-text = 'Selected Fields'(m02).
  node-dragdropid = ' '.
  APPEND node TO node_itab.

  SORT lt_tables_rel BY sequence tabname.
  SORT lt_columns BY tabname fldname.
  SORT gt_col_info BY tabname fldname.

  LOOP AT lt_tables_rel INTO ls_tables.

    CLEAR node.
*    node-node_key = |{ lc_child }{ ls_tables-tabname }|.
    CONCATENATE lc_child ls_tables-tabname INTO node-node_key.

    node-relatkey = lc_root.
    node-isfolder = 'X'.
    node-relatship = cl_simple_tree_model=>relat_last_child.
*    node-text = |{ ls_tables-tabname } { ls_tables-description_table }|.
    CONCATENATE ls_tables-tabname ls_tables-description_table INTO node-text SEPARATED BY space.

    node-dragdropid = handle_tree.
    APPEND node TO node_itab.
    lv_parent = node-node_key.

    SORT lt_columns BY tabname positionf ASCENDING.
    LOOP AT lt_columns INTO ls_columns WHERE tabname = ls_tables-tabname.
      CLEAR node.
*      node-node_key = |{ lv_parent }{ ls_columns-fldname }|.
      CONCATENATE lv_parent ls_columns-fldname INTO node-node_key.

      node-relatkey = lv_parent.
      node-isfolder = ' '.
      node-relatship = cl_simple_tree_model=>relat_last_child.
*      node-text = |{ ls_columns-description_field }{ lc_par1 } { ls_columns-fldname }{ lc_par2 }|.
      CONCATENATE ls_columns-description_field lc_par1 ls_columns-fldname lc_par2 INTO node-text.

      node-dragdropid = handle_tree.
      APPEND node TO node_itab.

      READ TABLE gt_col_info
            INTO ls_col_info
        WITH KEY tabname = ls_tables-tabname
                 fldname = ls_columns-fldname BINARY SEARCH.
      IF sy-subrc = 0.
        READ TABLE gt_columns_alv  TRANSPORTING NO FIELDS
                                  WITH KEY tabname = ls_tables-tabname
                                           fldname = ls_columns-fldname.  "DB
        IF sy-subrc NE 0.
          APPEND INITIAL LINE TO gt_columns_alv ASSIGNING <fs_col>.
          MOVE-CORRESPONDING ls_col_info TO <fs_col>.
        ENDIF.
      ENDIF.

    ENDLOOP.
  ENDLOOP.

  node_itab_left[]  = node_itab_right[].
  node_itab_right[] = node_itab[].

  CLEAR: node_itab[].

  " Delete the existing node
  tree_right->delete_node( node_key = lc_root ).

  CALL METHOD tree_right->add_nodes
    EXPORTING
      node_table = node_itab_right.

  CALL METHOD tree_right->expand_node
  ##NO_TEXT
    EXPORTING
      node_key = 'Root'.


**Add only key field in left
  CALL METHOD behaviour_left->get_handle
    IMPORTING
      handle = handle_tree_left.

*  PERFORM fill_tree_selected CHANGING handle_tree_left node_itab_left.

  " Delete the existing node
  tree_left->delete_node( node_key = lc_root ).

  CALL METHOD tree_left->add_nodes
    EXPORTING
      node_table = node_itab_left.

  CALL METHOD tree_left->expand_node
  ##NO_TEXT
    EXPORTING
      node_key = 'Root'.
ENDFORM.                    "handle_pass_to_right_tree
*&---------------------------------------------------------------------*
*& Form check_technical_names
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_COLUMNS_SAVE[]
*&---------------------------------------------------------------------*
FORM check_technical_names TABLES p_save STRUCTURE zonta_oc_col_all.
  CONSTANTS: c_al TYPE c LENGTH 2 VALUE '_1'.

  DATA: lv_value     TYPE zonde_fieldname1,
        lv_technical TYPE zonta_oc_col_all-fldname,
        lv_alias     TYPE c,
        lv_y         TYPE c.
***11.06.26 FRG CAMBIOS VAREX SE CAMBIO LIMITE DE 17 A 25
  FIELD-SYMBOLS: <fs_save> LIKE LINE OF p_save,
                 <fs_conv> LIKE LINE OF gt_converted.

  LOOP AT p_save ASSIGNING <fs_save>.
    CLEAR lv_y.
    IF strlen( <fs_save>-fldname ) > 27.
      lv_y = 'X'.
      APPEND INITIAL LINE TO gt_converted ASSIGNING <fs_conv>.
      MOVE-CORRESPONDING <fs_save> TO <fs_conv>.
      lv_value = <fs_save>-fldname+0(27).
      <fs_conv>-fldname1 = lv_value.
      <fs_conv>-alias_fldname1 = <fs_conv>-alias_fldname.
      <fs_conv>-fldname2 = <fs_save>-fldname+27.
      PERFORM check_length USING lv_alias CHANGING <fs_conv>.
    ENDIF.

    IF strlen( <fs_save>-alias_fldname ) > 27.
      IF lv_y is INITIAL.
        APPEND INITIAL LINE TO gt_converted ASSIGNING <fs_conv>.
        MOVE-CORRESPONDING <fs_save> TO <fs_conv>.
        <fs_conv>-fldname1 = <fs_conv>-fldname.
      endif.
      lv_value = <fs_save>-alias_fldname+0(27).
      <fs_conv>-alias_fldname1 = lv_value.
      <fs_conv>-alias_fldname2 = <fs_save>-alias_fldname+27.
      lv_alias = 'X'.
      PERFORM check_length USING lv_alias CHANGING <fs_conv>.
      CLEAR LV_ALIAS.
    ENDIF.

  ENDLOOP.

  MODIFY zonta_oc_conv FROM TABLE gt_converted.
  IF sy-subrc = 0.
    COMMIT WORK.
  ENDIF.
ENDFORM.                    "check_technical_names
*&---------------------------------------------------------------------*
*& Form check_length
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_VALUE
*&---------------------------------------------------------------------*
FORM check_length  USING p_alias CHANGING p_conv STRUCTURE zonta_oc_conv.


  DATA: ls_converted  TYPE zonta_oc_conv,
        ls_convertedt LIKE LINE OF gt_convertedt,
        ls_col_alv    LIKE LINE OF gt_columns_alv,
        lv_value      TYPE zonde_fieldname1,
        lv_len        TYPE i.

  FIELD-SYMBOLS: <fs_convt> LIKE LINE OF gt_convertedt.

  IF p_alias IS INITIAL.
  SORT gt_convertedt BY tabname fldname1 lenght DESCENDING. "ASCENDING.
  READ TABLE gt_convertedt INTO ls_convertedt WITH KEY tabname = p_conv-tabname
                                                       fldname1 = p_conv-fldname1 BINARY SEARCH.
  IF sy-subrc = 0 AND ls_convertedt-fldname1 = p_conv-fldname1.
    lv_len = ls_convertedt-lenght - 1.
    lv_value = p_conv-fldname+0(lv_len).
    p_conv-fldname1 = lv_value.
    p_conv-fldname2 = p_conv-fldname+lv_len.
    PERFORM check_length USING p_alias CHANGING p_conv.
  ELSE.
    READ TABLE gt_columns_alv INTO ls_col_alv WITH KEY tabname = p_conv-tabname
                                                       fldname = p_conv-fldname1.
    IF sy-subrc = 0.
      lv_len = strlen( ls_col_alv-fldname ) - 1.  "DB
*      lv_len = ls_convertedt-lenght - 1.
      lv_value = p_conv-fldname+0(lv_len).
      p_conv-fldname1 = lv_value.
      p_conv-fldname2 = p_conv-fldname+lv_len.
      PERFORM check_length USING p_alias CHANGING p_conv.
    ELSE.
      APPEND INITIAL LINE TO gt_convertedt ASSIGNING <fs_convt>.
      MOVE-CORRESPONDING p_conv TO <fs_convt>.
      <fs_convt>-field30 = p_conv-fldname+0(27).
      lv_len = strlen( <fs_convt>-fldname1 ).
      <fs_convt>-lenght = lv_len.
      EXIT.
    ENDIF.
  ENDIF.
  ELSE.
    READ TABLE gt_convertedt INTO ls_convertedt WITH KEY tabname = p_conv-tabname
                                                         alias_fldname1 = p_conv-alias_fldname1 BINARY SEARCH.
    IF sy-subrc = 0 AND ls_convertedt-alias_fldname1 = p_conv-alias_fldname1.
      lv_len = ls_convertedt-lenght - 1.
      lv_value = p_conv-alias_fldname+0(lv_len).
      p_conv-alias_fldname1 = lv_value.
      p_conv-alias_fldname2 = p_conv-alias_fldname+lv_len.
      PERFORM check_length USING p_alias CHANGING p_conv.
    ELSE.
      READ TABLE gt_columns_alv INTO ls_col_alv WITH KEY tabname = p_conv-tabname
                                                         alias_fldname = p_conv-alias_fldname1.
      IF sy-subrc = 0.
        lv_len = strlen( ls_col_alv-alias_fldname ) - 1.  "DB
*      lv_len = ls_convertedt-lenght - 1.
        lv_value = p_conv-alias_fldname+0(lv_len).
        p_conv-alias_fldname1 = lv_value.
        p_conv-alias_fldname2 = p_conv-alias_fldname+lv_len.
        PERFORM check_length USING p_alias CHANGING p_conv.
      ELSE.
        APPEND INITIAL LINE TO gt_convertedt ASSIGNING <fs_convt>.
        MOVE-CORRESPONDING p_conv TO <fs_convt>.
        <fs_convt>-field30 = p_conv-alias_fldname+0(27).
        lv_len = strlen( <fs_convt>-alias_fldname1 ).
        <fs_convt>-lenght = lv_len.
        EXIT.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    "check_length
*&---------------------------------------------------------------------*
*& Form check_first_field_main
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_first_field_main .

  CONSTANTS: c_position TYPE dd03l-position VALUE '0002',
             c_node     TYPE string         VALUE '.NODE1'.

  DATA: lv_fldname   TYPE string,
        lt_dfies_tab TYPE TABLE OF   dfies,
        ls_dfies_tab TYPE  dfies.

  FIELD-SYMBOLS: <fs_tables> LIKE LINE OF gt_tables_alv.

  READ TABLE gt_tables_alv ASSIGNING <fs_tables> INDEX 1.
  IF <fs_tables> IS ASSIGNED AND <fs_tables>-field_main IS INITIAL.
    SELECT SINGLE fieldname INTO lv_fldname
      FROM dd03l
      WHERE tabname = <fs_tables>-tabname
         AND position = c_position.
    IF sy-subrc = 0.
      <fs_tables>-field_main = lv_fldname.
    ELSE.
      CALL FUNCTION 'DDIF_FIELDINFO_GET'
        EXPORTING
          tabname        = <fs_tables>-tabname
          langu          = sy-langu
        TABLES
          dfies_tab      = lt_dfies_tab
        EXCEPTIONS
          not_found      = 1
          internal_error = 2
          OTHERS         = 3.
      IF sy-subrc = 0.
        SORT lt_dfies_tab BY position.
        DELETE lt_dfies_tab WHERE fieldname = c_node.
        DELETE lt_dfies_tab WHERE fieldname = c_mandt.
        READ TABLE lt_dfies_tab INTO ls_dfies_tab INDEX 1.
        IF sy-subrc = 0.
          <fs_tables>-field_main = ls_dfies_tab-fieldname.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    "check_first_field_main
*&---------------------------------------------------------------------*
*& Form check_alias_fldname
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_COLUMNS_SAVE[]
*&---------------------------------------------------------------------*
FORM check_alias_fldname  TABLES  p_save STRUCTURE zonta_oc_col_all.
  CONSTANTS: c_al  TYPE c LENGTH 2 VALUE '_1',
             c_new TYPE c LENGTH 2 VALUE '_n'.

  DATA: lv_value     TYPE zonde_fieldname1,
        lv_technical TYPE zonta_oc_col_all-fldname,
        lv_alias     TYPE zonta_oc_col_all-alias_fldname,
        lv_aliasu    TYPE zonta_oc_col_all-alias_fldname,
        lv_aliasl    TYPE zonta_oc_col_all-alias_fldname,
        lv_changed   TYPE boolean_flg,
        lv_same      TYPE boolean_flg,
        lv_alias_ok  TYPE boolean_flg,
        ls_save      LIKE LINE OF p_save,
        ls_save_tmp  LIKE LINE OF p_save,
        lv_subrc     TYPE sy-subrc.

  FIELD-SYMBOLS: <fs_save> LIKE LINE OF p_save.

  lv_changed = abap_false.
  LOOP AT p_save ASSIGNING <fs_save>.
    lv_technical = <fs_save>-fldname.
    TRANSLATE <fs_save>-alias_fldname TO LOWER CASE.
    TRANSLATE lv_technical TO LOWER CASE.
*if alias and field name are = change the alias
    IF lv_technical = <fs_save>-alias_fldname.
      if strlen( <fs_save>-alias_fldname ) < 23.
        <fs_save>-alias_fldname = |{ <fs_save>-alias_fldname }{ c_al }|.
      else.
        <fs_save>-alias_fldname = |{ <fs_save>-alias_fldname(23) }{ c_al }|.
      endif.
    ENDIF.
    lv_alias  = <fs_save>-alias_fldname.
    lv_aliasu = <fs_save>-alias_fldname.
    lv_aliasl = <fs_save>-alias_fldname.
    TRANSLATE lv_aliasu TO UPPER CASE.
    TRANSLATE lv_aliasl TO LOWER CASE.

    lv_subrc = 4.
    LOOP AT p_save INTO ls_save WHERE fldname = lv_aliasu
                                   OR fldname = lv_aliasl.
      lv_subrc = 0.
      if strlen( <fs_save>-alias_fldname ) < 23.
        <fs_save>-alias_fldname = |{ <fs_save>-alias_fldname }{ c_al }|.
      else.
        <fs_save>-alias_fldname = |{ <fs_save>-alias_fldname(23) }{ c_al }|.
      endif.
      EXIT.
    ENDLOOP.

    IF lv_subrc = 0.
      lv_alias_ok = abap_false.
* Review if the same alias is used for same domain
      lv_subrc = 4.
      LOOP AT p_save INTO ls_save_tmp WHERE alias_fldname = lv_aliasu
                                         OR alias_fldname = lv_aliasl.
        lv_subrc = 0.
        EXIT.
      ENDLOOP.
      IF lv_subrc = 0.
        PERFORM check_alias_domain USING <fs_save> ls_save_tmp CHANGING lv_same.
        IF lv_same = abap_true.
          <fs_save>-alias_fldname = lv_alias.
          lv_alias_ok = abap_true.
        ENDIF.
      ENDIF.

      IF lv_alias_ok = abap_false.
        PERFORM get_next_alias TABLES p_save USING lv_alias CHANGING <fs_save>-alias_fldname.
        lv_changed = abap_true.
      ENDIF.
    ENDIF.

  ENDLOOP.

  IF lv_changed = abap_true.
    MESSAGE i015(zon_cl_oc).
  ENDIF.
ENDFORM.                    "check_alias_fldname
*&---------------------------------------------------------------------*
*& Form add_entry_into_tr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> TABNAME
*&      --> LV_KEY
*&      --> LV_TRKORR
*&---------------------------------------------------------------------*
FORM add_entry_into_tr  USING    p_tabname TYPE tabname
                                 p_key     TYPE e071k-tabkey
                                 p_trkorr  TYPE trkorr
                                 p_action  TYPE c.

  DATA: lt_e071  TYPE STANDARD TABLE OF e071,
        lt_e071k TYPE STANDARD TABLE OF e071k,
        ls_e071  TYPE e071,
        ls_e071k TYPE e071k.

  " Fill E071
  ls_e071-pgmid      = 'R3TR'.
  ls_e071-object     = 'TABU'.
  ls_e071-obj_name   = p_tabname.
*  ls_e071-mastertype = 'C'.
  ls_e071-as4pos     = '000000'.
  APPEND ls_e071 TO lt_e071.

  " Fill E071K
  ls_e071k-pgmid      = 'R3TR'.
  ls_e071k-object     = 'TABU'.
  ls_e071k-objname   = p_tabname.
  ls_e071k-mastertype = 'C'.
  ls_e071k-tabkey     = p_key.
  APPEND ls_e071k TO lt_e071k.

  " Append key to transport
  CALL FUNCTION 'TR_APPEND_TO_COMM_OBJS_KEYS'
    EXPORTING
      wi_request = p_trkorr
    TABLES
      wt_e071    = lt_e071
      wt_e071k   = lt_e071k
    EXCEPTIONS
      OTHERS     = 1.

  IF sy-subrc <> 0.
  ENDIF.

ENDFORM.                    "add_entry_into_tr


*&---------------------------------------------------------------------*
*&      Form  append_e071
*&---------------------------------------------------------------------*
*       Appends a header entry to E071
*----------------------------------------------------------------------*
*      -->P_TASK     Transport task (E071-TRKORR)
*      -->P_AS4POS   Last position, will be incremented
*      -->P_PGMID    Program ID (usually 'R3TR')
*      -->P_OBJECT   Object type (e.g., 'TABU')
*      -->P_OBJNAME  Object name (e.g., table name)
*      -->P_MASTER   Master name (optional, default to OBJNAME)
*      -->P_OBJFUNC  'K' = Key entry (insert), 'D' = Delete
*      -->T_E071     Table E071 to append to
*----------------------------------------------------------------------*
FORM append_e071
    TABLES   t_e071     STRUCTURE e071
    USING    p_task     TYPE e071-trkorr
             p_as4pos   TYPE e071-as4pos
             p_pgmid    TYPE e071-pgmid
             p_object   TYPE e071-object
             p_objname  TYPE e071-obj_name
             p_objfunc  TYPE e071-objfunc.

  FIELD-SYMBOLS: <fs_e071>  TYPE e071.

  " Append header
  APPEND INITIAL LINE TO t_e071 ASSIGNING <fs_e071>.
  ADD 1 TO p_as4pos.
  <fs_e071>-trkorr   = p_task.
  <fs_e071>-as4pos   = p_as4pos.
  <fs_e071>-pgmid    = p_pgmid.
  <fs_e071>-object   = p_object.
  <fs_e071>-obj_name = p_objname.
  <fs_e071>-objfunc  = p_objfunc.
  <fs_e071>-lockflag = 'X'.

ENDFORM.                    "append_e071



*&---------------------------------------------------------------------*
*&      Form  append_e071k
*&---------------------------------------------------------------------*
*       Appends line entry  E071K
*----------------------------------------------------------------------*
*      -->P_TASK     Transport task (E071-TRKORR)
*      -->P_AS4POS   Last position, will be incremented
*      -->P_PGMID    Program ID (usually 'R3TR')
*      -->P_OBJECT   Object type (e.g., 'TABU')
*      -->P_OBJNAME  Object name (e.g., table name)
*      -->P_MASTER   Master name (optional, default to OBJNAME)
*      -->P_TABKEY   Fully qualified table key (client + fields)
*      -->P_OBJFUNC  'K' = Key entry (insert), 'D' = Delete
*      -->T_E071K    Table E071K to append to
*----------------------------------------------------------------------*
FORM append_e071k
    TABLES   t_e071k    STRUCTURE e071k
    USING    p_task     TYPE e071-trkorr
             p_as4pos   TYPE e071-as4pos
             p_pgmid    TYPE e071-pgmid
             p_object   TYPE e071-object
             p_objname  TYPE e071-obj_name
             p_master   TYPE e071k-mastername
             p_tabkey   TYPE e071k-tabkey
             p_objfunc  TYPE e071-objfunc.

  FIELD-SYMBOLS: <fs_e071k> TYPE e071k.

  " Append table key
  APPEND INITIAL LINE TO t_e071k ASSIGNING <fs_e071k>.
  ADD 1 TO p_as4pos.
  <fs_e071k>-trkorr      = p_task.
  <fs_e071k>-as4pos      = p_as4pos.
  <fs_e071k>-pgmid       = p_pgmid.
  <fs_e071k>-object      = p_object.
  <fs_e071k>-objname     = p_objname.
  <fs_e071k>-mastertype  = p_object.
  <fs_e071k>-mastername  = p_master.
  <fs_e071k>-objfunc     = p_objfunc.
  <fs_e071k>-tabkey      = p_tabkey(120). " truncate if needed

ENDFORM.                    "append_e071k
*&---------------------------------------------------------------------*
*& Form handle_search
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM handle_search.
  DATA: lt_current_search_selection TYPE treemnotab,
        lv_value_popup              TYPE  kcd_value2,
        lv_value                    TYPE string.

*  CALL FUNCTION 'POPUP_TO_SEARCH_VALUE'
*    EXPORTING
*      textline1      = 'Search one Value'
**     TEXTLINE2      =
*      titel          = 'Search Value'
*      valuelength    = '200'
**     OPTIONTEXT     =
**     OPTIONWAHL     =
*    IMPORTING
**     ACTION         =
*      value          = lv_value_popup
**     OPTIONSWITCH   =
*    EXCEPTIONS
*      titel_too_long = 1
*      OTHERS         = 2.
*
*  IF sy-subrc = 0 AND lv_value_popup IS NOT INITIAL.

  DATA:
    lt_result_expander_node_key TYPE tm_nodekey,
    lt_found_keys               TYPE treemnotab,
    lv_found_key                TYPE tm_nodekey,
    ls_found_node               TYPE treemsnodt,
    lv_result_type              TYPE i,
    lv_node_path_text           TYPE string.
*
*  lv_value = lv_value_popup.
*
*  " 1. Clear previous search selections in the left tree
*  IF lt_current_search_selection IS NOT INITIAL.
*    LOOP AT lt_current_search_selection INTO lv_found_key.
**        tree_left->node_set_selected( node_key = lv_found_key selected = abap_false ).
*    ENDLOOP.
*    CLEAR lt_current_search_selection.
*  ENDIF.

*  " 2. Perform the search on the left tree (assuming this is the main tree for search)
*  TRY.
*
*      tree_left->find(
*        IMPORTING
*          result_type     = lv_result_type                 " Search result
*          result_node_key = lv_found_key                " Search result
*      ).
**        tree_left->find_all(
**          EXPORTING
**            search_string            = lv_value               " Character String
**            pattern_search           = abap_true                 " 'X': Interpret String as Pattern
**            start_node               = 'Root'                " Key of Starting Node
**            stop_at_expander_node    = abap_false                 " 'X': Stop at a Node with EXPANDER Attribute
**          IMPORTING
**            result_type              = lv_result_type                 " Search result
**            result_expander_node_key = lt_result_expander_node_key                 " Search result
**            result_node_key_table    = lt_found_keys
**          EXCEPTIONS
**            start_node_not_found     = 1                " Node with Key START_NODE Does Not Exist
**            OTHERS                   = 2
**        ).
*      IF sy-subrc <> 0.
*        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*      ENDIF.
*
**        IF lt_found_keys IS NOT INITIAL.
*      " Store found keys for clearing later
*      lt_current_search_selection = lt_found_keys.
*
*      " 3. Highlight and ensure visibility of found nodes
**          LOOP AT lt_found_keys INTO lv_found_key.
*      " Select the node
**            tree_left->node_set_selected( node_key = lv_found_key selected = abap_true ).
*
*      " Ensure the node is visible (expands parents if collapsed)
**            tree_left->node_ensure_visible( node_key = lv_found_key ).
*
*      " Optional: Get node properties and path for display in status bar/log
*      tree_left->node_get_properties(
*        EXPORTING
*          node_key   = lv_found_key
*        IMPORTING
*          properties = ls_found_node
*        EXCEPTIONS
*          node_not_found = 1                " Node With Key NODE_KEY Does Not Exist
*          OTHERS         = 2
*      ).
*      IF sy-subrc <> 0.
*        IF sy-msgid IS NOT INITIAL.
*          MESSAGE ID sy-msgid  TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*        ENDIF.
*      ENDIF.
*
*      tree_left->node_get_text(
*        EXPORTING
*          node_key = lv_found_key
*        IMPORTING
*          text     = lv_node_path_text
*        EXCEPTIONS
*          node_not_found = 1                " Node With Key NODE_KEY Does Not Exist
*         OTHERS         = 2
*      ).
*      IF sy-subrc <> 0.
*        CLEAR lv_found_key.
*      ENDIF.
*
**          ENDLOOP.
**          MESSAGE |Search completed. Found { lines( lt_found_keys ) } results.| TYPE 'S'.
*      IF lv_found_key IS INITIAL.
*        MESSAGE |No results found for "{ lv_found_key }".| TYPE 'I'.
*      ELSE.
*        " 3. Highlight and ensure visibility of found nodes
*
*        " Select the node
**      " Expand and select the node
*        tree_left->expand_node( node_key = lv_found_key  ).
*        tree_left->set_selected_node( node_key = lv_found_key ).
*        tree_left->ensure_visible( node_key = lv_found_key ).
*
**        CALL METHOD tree_left->expand_node
**          EXPORTING
**            node_key = lv_found_key.
**
**        tree_left->get_selected_node(
**          IMPORTING
**            node_key                   = lv_found_key                 " Key of Selected Node
**          EXCEPTIONS
**            control_not_existing       = 1                " Tree Control Does Not Exist
**            control_dead               = 2                " Tree Control Has Already Been Destroyed
**            cntl_system_error          = 3                " "
**            failed                     = 4                " General Error
**            single_node_selection_only = 5                " Only Allowed with Single Node Selection
**            OTHERS                     = 6
**        ).
**        IF sy-subrc <> 0.
*** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
***   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
**        ENDIF.
**        MESSAGE |Found: { ls_found_node-text } (Key: { lv_found_key }, Path: { lv_node_path_text })| TYPE 'I'.
*      ENDIF.
*
**      tree_left
*
**cl_simple_tree_model=>find_expander_node_hit
*
*    CATCH cx_root. " Catch generic control framework errors
*      MESSAGE 'An error occurred during search.' TYPE 'E'.
*  ENDTRY.
*
*  " 4. Update the tree display to show selections and expansions
**    tree_left->update_tree_display( ).
*  CALL METHOD cl_gui_cfw=>flush. " Ensure GUI is updated
*
**  ENDIF.

  DATA: lv_text           TYPE string,
*        lv_found_key TYPE tv_nodekey,
*        ls_node like LINE OF treev_node.
        lv_node_key       TYPE tm_nodekey,
        lv_count          TYPE i,
        lt_node_key_table TYPE treemnotab,
        ls_node_key_table TYPE tm_nodekey,
        ls_node           LIKE LINE OF node_itab_left.

  CALL FUNCTION 'POPUP_TO_SEARCH_VALUE'
    EXPORTING
      textline1      = 'Enter field name (case insensitive):'
*     TEXTLINE2      =
      titel          = 'Search Field'
      valuelength    = '30'
*     OPTIONTEXT     =
*     OPTIONWAHL     =
    IMPORTING
*     ACTION         =
      value          = lv_value_popup
*     OPTIONSWITCH   =
    EXCEPTIONS
      titel_too_long = 1
      OTHERS         = 2.

  lv_text = lv_value_popup.
  IF sy-subrc <> 0 OR lv_text IS INITIAL.
    RETURN.
  ENDIF.

  TRANSLATE lv_text TO UPPER CASE.
  CLEAR lv_count.
*  CREATE OBJECT tree_left
*    EXPORTING
*      node_selection_mode         = cl_simple_tree_model=>node_sel_mode_multiple
*    EXCEPTIONS
*      illegal_node_selection_mode = 1.

  tree_left->get_selected_node(
    IMPORTING
      node_key                   =  lv_node_key                    " Key of Selected Node
    EXCEPTIONS
      control_not_existing       = 1                " Tree Control Does Not Exist
      control_dead               = 2                " Tree Control Has Already Been Destroyed
      cntl_system_error          = 3                " "
      failed                     = 4                " General Error
      single_node_selection_only = 5                " Only Allowed with Single Node Selection
      OTHERS                     = 6
  ).
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSEIF lv_node_key  IS INITIAL.
    MESSAGE i130(zon_cl_oc).
    RETURN.
  ENDIF.

*  LOOP AT node_itab_left INTO ls_node WHERE node_key <> 'ROOT'.
  LOOP AT node_itab_left INTO ls_node WHERE relatkey = lv_node_key   .
    IF ls_node-text CS lv_text OR ls_node-text = lv_text.
*      lv_count = lv_count + 1.
*      IF lv_count EQ 1.
      lv_found_key = ls_node-node_key.
*      ENDIF.
*      ls_node_key_table = ls_node-node_key.
      " Expand and select the node
      tree_left->expand_node( node_key = lv_found_key  ).
      tree_left->set_selected_node( node_key = ls_node-node_key ).
      tree_left->ensure_visible( node_key = lv_found_key ).
*      APPEND ls_node_key_table TO lt_node_key_table.
*      CLEAR ls_node_key_table.
*      EXIT.
    ENDIF.
  ENDLOOP.

  IF lv_found_key IS INITIAL.
    MESSAGE i131(zon_cl_oc).
    RETURN.
  ENDIF.

*  " Expand and select the node
*  tree_left->expand_node( node_key = lv_found_key  ).
*  tree_left->set_selected_node( node_key = lv_found_key ).
**  tree_left->select_nodes( node_key_table  = lt_node_key_table ).
*  tree_left->ensure_visible( node_key = lv_found_key ).

ENDFORM.                    "handle_search
*&---------------------------------------------------------------------*
*&      Module  F_VALIDATE_ENTITYNAME  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f_validate_entityname INPUT.
  DATA: lv_entity TYPE zonta_obj_oc-business_proc.

  IF gv_new = abap_true.
    SELECT SINGLE business_proc
      FROM zonta_obj_oc
       INTO lv_entity
      WHERE business_proc = zonta_obj_oc-business_proc.

    IF sy-subrc EQ 0.
      MESSAGE e039(zon_cl_oc) WITH  zonta_obj_oc-business_proc DISPLAY LIKE 'E'.
    ENDIF.
  ENDIF.

ENDMODULE.                    "f_validate_entityname INPUT
*&---------------------------------------------------------------------*
*& Form check_reference_fields
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_reference_fields .
  DATA: ls_tables    LIKE LINE OF gt_tables_alv,
        lt_dfies     TYPE STANDARD TABLE OF dfies,
        lt_dfies_all TYPE STANDARD TABLE OF dfies,
        ls_columns   LIKE LINE OF gt_columns_alv,
        ls_dfies     TYPE dfies,
        ls_dfies_ref TYPE dfies,
        lv_cont      TYPE n.

  FIELD-SYMBOLS: <fs_col> LIKE LINE OF gt_columns_alv.
  FIELD-SYMBOLS: <fs_col2> LIKE LINE OF gt_columns_alv.

  LOOP AT gt_tables_alv INTO ls_tables.
* Validate ref table and ref fied.
    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname   = ls_tables-tabname
      TABLES
        dfies_tab = lt_dfies
      EXCEPTIONS
        OTHERS    = 3.
    lt_dfies_all[] = lt_dfies[].
    SORT lt_dfies_all BY fieldname.
    DELETE lt_dfies WHERE reftable IS INITIAL.
    DELETE lt_dfies WHERE fieldname = '.NODE1'.
    LOOP AT lt_dfies INTO ls_dfies.
      READ TABLE gt_columns_alv INTO ls_columns WITH KEY tabname = ls_tables-tabname
                                                         fldname = ls_dfies-reffield.
      IF sy-subrc NE 0.
* Ref field is not on the columns, we need to add
        APPEND INITIAL LINE TO gt_columns_alv ASSIGNING <fs_col>.
        READ TABLE lt_dfies_all INTO ls_dfies_ref WITH KEY fieldname = ls_dfies-reffield BINARY SEARCH.
        IF sy-subrc = 0.
          MOVE-CORRESPONDING ls_dfies_ref TO <fs_col>.
          <fs_col>-positionf = ls_dfies_ref-position.
          <fs_col>-fldname = ls_dfies_ref-fieldname.
          <fs_col>-description_field = ls_dfies_ref-scrtext_s.
          <fs_col>-alias_fldname = ls_dfies_ref-scrtext_s.
          PERFORM check_alias_for_reference CHANGING <fs_col>-alias_fldname.
          CONDENSE <fs_col>-alias_fldname.
          TRANSLATE <fs_col>-alias_fldname TO LOWER CASE.
          DO 10 TIMES.
            CLEAR lv_cont.
            LOOP AT gt_columns_alv ASSIGNING <fs_col2> WHERE tabname = <fs_col>-tabname AND alias_fldname = <fs_col>-alias_fldname AND fldname NE <fs_col>-fldname.
              ADD 1 TO lv_cont.
            ENDLOOP.
            IF lv_cont IS NOT INITIAL.
              CONCATENATE <fs_col>-alias_fldname lv_cont INTO <fs_col>-alias_fldname.
              CONDENSE <fs_col>-alias_fldname.
            ELSE.
              EXIT.
            ENDIF.
          ENDDO.
          MESSAGE i017(zon_cl_oc) WITH ls_dfies_ref-fieldname text-t14 ls_dfies-fieldname text-t15.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    "check_reference_fields
*&---------------------------------------------------------------------*
*& Form check_alias_for_reference
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <FS_COL>_ALIAS_FLDNAME
*&---------------------------------------------------------------------*
FORM check_alias_for_reference  CHANGING p_alias.
  CONSTANTS: c_dots          TYPE c VALUE ':',
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
             c_perc(1)       TYPE c VALUE '%'.
  DATA: lv_fldname TYPE fieldname.

  lv_fldname = p_alias.

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

  REPLACE ALL OCCURRENCES OF REGEX '[^[:alnum:]]' IN lv_fldname WITH space .
  REPLACE ALL OCCURRENCES OF REGEX '[^[:alnum:]]' IN lv_fldname WITH space .
  REPLACE ALL OCCURRENCES OF REGEX '[^[:alnum:]]' IN lv_fldname WITH space .

  p_alias = lv_fldname.

ENDFORM.                    "check_alias_for_reference
*---------------------------------------------------------------------*
*  FORM get_next_alias
*---------------------------------------------------------------------*
*  Finds the next available alias in p_table.
*  Input : iv_alias (e.g. 'customer_name_1')
*  Output: ev_alias (e.g. 'customer_name_2', 'customer_name_3', etc.)
*---------------------------------------------------------------------*
*FORM get_next_alias
*  TABLES   p_table STRUCTURE zonta_oc_col_all
*  USING    iv_alias TYPE zonta_oc_col_all-alias_fldname
*  CHANGING ev_alias TYPE zonta_oc_col_all-alias_fldname.
*
*  DATA: lv_base   TYPE zonta_oc_col_all-alias_fldname,
*        lv_number TYPE i,
*        lv_next   TYPE zonta_oc_col_all-alias_fldname,
*        lv_temp   TYPE zonta_oc_col_all-alias_fldname,
*        lv_check  TYPE zonta_oc_col_all-alias_fldname,
*        lt_alias  TYPE STANDARD TABLE OF string,
*        lv_offset TYPE i,
*        lv_new_offset TYPE i.
*
*
*  FIELD-SYMBOLS: <lv_alias> TYPE string.
*
*  " Build helper table with aliases in uppercase
*  LOOP AT p_table ASSIGNING FIELD-SYMBOL(<ls_row>).
*    lv_temp = <ls_row>-alias_fldname.
*    TRANSLATE lv_temp TO UPPER CASE.
*    APPEND lv_temp TO lt_alias.
*  ENDLOOP.
*
*  " Find last underscore
*  FIND ALL OCCURRENCES OF '_' IN iv_alias MATCH OFFSET lv_offset.
*  IF sy-subrc = 0.
*    lv_base   = iv_alias+0(lv_offset).
*    lv_new_offset = lv_offset + 1.
*    lv_number = iv_alias+lv_new_offset.
*  ELSE.
*    lv_base   = iv_alias.
*    lv_number = 1.
*  ENDIF.
*
*  lv_next = lv_base && '_' && lv_number.
*
*  DO.
*    lv_check = to_upper( lv_next ).
*
*    READ TABLE lt_alias WITH KEY table_line = lv_check TRANSPORTING NO FIELDS.
*    IF sy-subrc <> 0.
*      " Free alias found
*      ev_alias = lv_next.
*      EXIT.
*    ELSE.
*      " Increment number and rebuild alias
*      lv_number = lv_number + 1.
*      lv_next   = lv_base && '_' && lv_number.
*    ENDIF.
*  ENDDO.
*
*  TRANSLATE ev_alias TO LOWER CASE.
*
*ENDFORM.

*---------------------------------------------------------------------*
*  FORM get_next_alias
*---------------------------------------------------------------------*
*  Finds the next available alias in p_table (case-insensitive).
*  Input : iv_alias (e.g. 'customer_name_1' or 'ITEM')
*  Output: ev_alias (e.g. 'customer_name_2' or 'ITEM_1')
*---------------------------------------------------------------------*
FORM get_next_alias
  TABLES   p_table STRUCTURE zonta_oc_col_all
  USING    iv_alias TYPE zonta_oc_col_all-alias_fldname
  CHANGING ev_alias TYPE zonta_oc_col_all-alias_fldname.

  DATA: lv_base    TYPE zonta_oc_col_all-alias_fldname,
        lv_suffix  TYPE string,
        lv_number  TYPE i,
        lv_next    TYPE zonta_oc_col_all-alias_fldname,
        lv_check   TYPE zonta_oc_col_all-alias_fldname,
        lv_temp    TYPE zonta_oc_col_all-alias_fldname,
        lv_offset  TYPE i,
        lv_new_off TYPE i,
        lt_alias   TYPE STANDARD TABLE OF string.

  FIELD-SYMBOLS: <ls_row> TYPE zonta_oc_col_all.

  " Build helper table with all aliases in uppercase for case-insensitive check
  LOOP AT p_table ASSIGNING <ls_row>.
    lv_temp = <ls_row>-alias_fldname.
    TRANSLATE lv_temp TO UPPER CASE.
    APPEND lv_temp TO lt_alias.
  ENDLOOP.

  " Find last underscore
  FIND ALL OCCURRENCES OF '_' IN iv_alias MATCH OFFSET lv_offset.
  IF sy-subrc = 0.
    " Base = everything before last underscore
    lv_base = iv_alias+0(lv_offset).

    " Suffix = everything after last underscore
    lv_new_off = lv_offset + 1.
    lv_suffix  = iv_alias+lv_new_off.

    " Safe conversion: only if suffix is numeric
    IF lv_suffix CO '0123456789'.
      lv_number = lv_suffix.
    ELSE.
      lv_number = 1.
    ENDIF.
  ELSE.
    " No underscore -> start numbering at 1
    lv_base   = iv_alias.
    lv_number = 1.
  ENDIF.

  lv_next = lv_base && '_' && lv_number.

  DO.

*    IF lv_number NE 1.
*
*    PERFORM check_alias_domain USING <fs_save> ls_save CHANGING lv_same.
*    IF lv_same = abap_false.
*    ENDIF.
*
*    ENDIF.

    lv_check = lv_next.
    TRANSLATE lv_check TO UPPER CASE.

    READ TABLE lt_alias WITH KEY table_line = lv_check TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      " Free alias found
      ev_alias = lv_next.
      EXIT.
    ELSE.
      " Try next number
      lv_number = lv_number + 1.
      lv_next   = lv_base && '_' && lv_number.
    ENDIF.
  ENDDO.

  " Normalize output alias in lower case (optional)
  TRANSLATE ev_alias TO LOWER CASE.


ENDFORM.                    "get_next_alias

*&---------------------------------------------------------------------*
*& Form copy_entity
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM copy_entity .


ENDFORM.                    "copy_entity
*&---------------------------------------------------------------------*
*& Form prepare_celltab_variant
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM prepare_celltab_variant .
  FIELD-SYMBOLS: <fs_alv> LIKE LINE OF gt_variant_alv.

  DATA: lv_index        TYPE sy-tabix.
  DATA: ls_celltab TYPE lvc_s_styl,
        lv_styled  TYPE raw4,
        lv_stylee  TYPE raw4.

  CLEAR: gt_celltab[],
         gt_celltab_all[].

  lv_stylee    = cl_gui_alv_grid=>mc_style_enabled.
  lv_styled    = cl_gui_alv_grid=>mc_style_disabled.


  ls_celltab-style = lv_styled.
  ls_celltab-fieldname = 'FIELDTEXT'.
  INSERT ls_celltab INTO TABLE gt_celltab_all.

  ls_celltab-style = lv_styled.
  ls_celltab-fieldname = 'TABNAME'.
  INSERT ls_celltab INTO TABLE gt_celltab_all.

  ls_celltab-style = lv_stylee.
  ls_celltab-fieldname = 'VTYPE'.
  INSERT ls_celltab INTO TABLE gt_celltab_all.

  ls_celltab-style = lv_stylee.
  ls_celltab-fieldname = 'VTEXT'.
  INSERT ls_celltab INTO TABLE gt_celltab_all.

  LOOP AT gt_variant_alv ASSIGNING <fs_alv>.

    CLEAR <fs_alv>-celltab.
    INSERT LINES OF gt_celltab_all INTO TABLE <fs_alv>-celltab.

  ENDLOOP.


ENDFORM.                    "prepare_celltab_variant

*&---------------------------------------------------------------------*
*& Form fill_variant_fields
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_variant_fields .
  DATA: lv_memory TYPE char25.

  DATA: lt_varold TYPE STANDARD TABLE OF zonta_oc_variant,
        ls_varold TYPE zonta_oc_variant.

  DATA lv_type  TYPE zonta_oc_variant-variant_type.

  CONCATENATE 'ZVARI' sy-uname INTO lv_memory.
  IMPORT gt_cond_tab = gt_cond_tab
         gt_fieltab  = gt_fieldtab
         gt_field_ranges = gt_field_ranges
         gv_variant = gv_variant
         gv_entity  = gv_entity
         gv_domainv = gv_domainv
    FROM MEMORY ID lv_memory.

  IF lines( gt_fieldtab ) > 0 AND zonta_oc_variant-variant IS INITIAL.
*  IF lines( gt_cond_tab ) > 0 AND zonta_oc_variant-variant IS INITIAL..
    gv_variant_old = abap_false.

    zonta_obj_oc-domainv = gv_domainv.
    zonta_obj_oc-business_proc = gv_entity.
    zonta_oc_variant = gv_variant.

    SELECT  * "variant_type
*      INTO TABLE @data(lt_varold)
INTO TABLE lt_varold
      FROM zonta_oc_variant
*      WHERE  domainv            = @zonta_obj_oc-domainv
*         AND business_proc      = @zonta_obj_oc-business_proc
*         AND variant            = @gv_variant .
      WHERE  domainv            = zonta_obj_oc-domainv
         AND business_proc      = zonta_obj_oc-business_proc
         AND variant            = gv_variant .
    IF sy-subrc = 0.
      gv_variant_old = abap_true.
    ENDIF.

*    READ TABLE lt_varold INTO data(ls_varold) INDEX 1.
    READ TABLE lt_varold INTO ls_varold INDEX 1.
*    data(lv_type) = ls_varold-variant_type.
    lv_type = ls_varold-variant_type.

    IF lv_type = 'D'.
      DATA: ls_field_tab TYPE rsdsfields.

      FIELD-SYMBOLS: <fs_var_alv> LIKE LINE OF gt_variant_alv,
                     <fs_var>     LIKE LINE OF  gt_variant_alv,
                     <fs_vari>    LIKE LINE OF gt_variant.

*      LOOP AT gt_fieldtab INTO data(ls_field_tab).
      LOOP AT gt_fieldtab INTO ls_field_tab.
*        READ TABLE gt_variant_alv ASSIGNING field-symbol(<fs_var_alv>) WITH KEY tabname = ls_field_tab-tablename
        READ TABLE gt_variant_alv ASSIGNING <fs_var_alv> WITH KEY tabname = ls_field_tab-tablename
                                                                fieldtext = ls_field_tab-fieldname.
        IF sy-subrc NE 0.
*          APPEND INITIAL LINE TO gt_variant_alv ASSIGNING field-symbol(<fs_var>).
          APPEND INITIAL LINE TO gt_variant_alv ASSIGNING <fs_var>.
          <fs_var>-tabname   = ls_field_tab-tablename.
          <fs_var>-fieldtext = ls_field_tab-fieldname.
          READ TABLE lt_varold INTO ls_varold WITH KEY tabname = ls_field_tab-tablename fieldname = ls_field_tab-fieldname.
          IF sy-subrc = 0.
            MOVE-CORRESPONDING ls_varold TO <fs_var>.
            <fs_var>-fieldtext = ls_varold-fieldname.
            <fs_var>-vname = ls_varold-vdescription.
            <fs_var>-vtext = ls_varold-description.
            <fs_var>-option = ls_varold-opti.
          ENDIF.

*          APPEND INITIAL LINE TO gt_variant ASSIGNING field-symbol(<fs_vari>).
          APPEND INITIAL LINE TO gt_variant ASSIGNING <fs_vari>.
          <fs_vari>-tabname   = ls_field_tab-tablename.
          <fs_vari>-fldname   = ls_field_tab-fieldname.
*          <fs_vari>-fieldtext = ls_varold-fieldname.
        ENDIF.
      ENDLOOP.

*Fixed values
    ELSE.

      LOOP AT gt_fieldtab INTO ls_field_tab.
        READ TABLE gt_variant_alv ASSIGNING <fs_var_alv> WITH KEY tabname = ls_field_tab-tablename
                                                                fieldtext = ls_field_tab-fieldname.
        IF sy-subrc NE 0.
          APPEND INITIAL LINE TO gt_variant_alv ASSIGNING <fs_var>.
          <fs_var>-tabname   = ls_field_tab-tablename.
          <fs_var>-fieldtext = ls_field_tab-fieldname.

          APPEND INITIAL LINE TO gt_variant ASSIGNING <fs_vari>.
          <fs_vari>-tabname   = ls_field_tab-tablename.
          <fs_vari>-fldname   = ls_field_tab-fieldname.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFORM.                    "fill_variant_fields

*&---------------------------------------------------------------------*
*& Form save_variant
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_variant .

  CONSTANTS: c_separator TYPE c VALUE '~'.

  DATA: lv_memory       TYPE char25.
  DATA: lv_tabix     TYPE sy-tabix,
        lv_tabix_tab TYPE sy-tabix.
  DATA lt_filters       TYPE zontt_filters.
  DATA ls_filters       LIKE LINE OF lt_filters.
  DATA lv_counter       TYPE i.
  DATA cond_tab         TYPE rsds_twhere.
  DATA lv_fieldname_complex TYPE string.
  DATA lv_where_string  TYPE string.
*  DATA field_ranges     TYPE rsds_trange.
  DATA ls_field_r       LIKE LINE OF gt_field_ranges.
  DATA lt_ranges        TYPE STANDARD TABLE OF zonta_oc_franges.
  DATA ls_ranges        LIKE LINE OF lt_ranges.

  FIELD-SYMBOLS: <fs_cond_tab>       LIKE LINE OF cond_tab.
  DATA ls_where       LIKE LINE OF <fs_cond_tab>-where_tab.

  FIELD-SYMBOLS: <fs_filters> LIKE LINE OF lt_filters.

  DATA: ls_range_d LIKE LINE OF ls_field_r-frange_t,
        ls_selopt  LIKE LINE OF ls_range_d-selopt_t.

  FIELD-SYMBOLS: <fs_variant> LIKE LINE OF gt_variantd.
  DATA: ls_variant_alv LIKE LINE OF gt_variant_alv.

  CONCATENATE 'ZONT' sy-uname INTO lv_memory.
  IMPORT: zonta_obj_oc FROM MEMORY ID lv_memory.

  CHECK gv_error = abap_false.
  PERFORM validate_variant.
  CHECK gv_error = abap_false.

* Save screen values
  IF gv_screenv = abap_true.

    IF lines( gt_cond_tab ) > 0.
      CLEAR lt_filters[].
      SORT gt_cond_tab BY tablename.


      LOOP AT gt_cond_tab ASSIGNING <fs_cond_tab>.
        ls_filters-domainv = zonta_obj_oc-domainv.
        ls_filters-business_proc = zonta_obj_oc-business_proc.
        ls_filters-tabname = <fs_cond_tab>-tablename.
        ls_filters-variant = zonta_oc_variant-variant.
        lv_counter = 1.

        lv_tabix = 1.
        lv_tabix_tab = 1.

        DATA ls_field_tab LIKE LINE OF gt_fieldtab.

*        LOOP AT gt_fieldtab INTO data(ls_field_tab) WHERE tablename = ls_filters-tabname.
        LOOP AT gt_fieldtab INTO ls_field_tab WHERE tablename = ls_filters-tabname.
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
          READ TABLE gt_fieldtab INTO ls_field_tab INDEX lv_tabix_tab.
          IF  ls_where-line CS ls_field_tab-fieldname.
          ELSE.
            READ TABLE <fs_cond_tab>-where_tab INTO ls_where INDEX lv_tabix.
            IF sy-subrc = 0.
              IF ls_where-line CS ls_field_tab-fieldname .
              ELSE.
*                READ TABLE lt_filters ASSIGNING field-symbol(<fs_filters>) FROM ls_filters.
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
      LOOP AT gt_field_ranges INTO ls_field_r.
        ls_ranges-domainv = zonta_obj_oc-domainv.
        ls_ranges-business_proc = zonta_obj_oc-business_proc.
        ls_ranges-tabname = ls_field_r-tablename.
*        LOOP AT ls_field_r-frange_t INTO data(ls_range_d).
        LOOP AT ls_field_r-frange_t INTO ls_range_d.
          ls_ranges-fldname = ls_range_d-fieldname.

*          LOOP AT ls_range_d-selopt_t INTO data(ls_selopt).
          LOOP AT ls_range_d-selopt_t INTO ls_selopt.
            ls_ranges-counter = lv_counter.
            ls_ranges-sign = ls_selopt-sign.
            ls_ranges-opti = ls_selopt-option.
            ls_ranges-low  = ls_selopt-low.
            ls_ranges-high = ls_selopt-high.
            ls_ranges-variant = zonta_oc_variant-variant.
            APPEND ls_ranges TO lt_ranges.
            lv_counter = lv_counter + 1.
            CLEAR: ls_ranges-sign,
                   ls_ranges-opti,
                   ls_ranges-low,
                   ls_ranges-high.
          ENDLOOP.
        ENDLOOP.
      ENDLOOP.

      IF gv_variant_old = abap_true.
        DELETE FROM zonta_oc_filters WHERE domainv = zonta_obj_oc-domainv
                                       AND business_proc = zonta_obj_oc-business_proc
                                       AND variant = zonta_oc_variant-variant.
        DELETE FROM zonta_oc_franges WHERE domainv = zonta_obj_oc-domainv
                                       AND business_proc = zonta_obj_oc-business_proc
                                       AND variant = zonta_oc_variant-variant.
        DELETE FROM zonta_oc_variant WHERE domainv = zonta_obj_oc-domainv
                                       AND business_proc = zonta_obj_oc-business_proc
                                       AND variant = zonta_oc_variant-variant.
      ENDIF.

      MODIFY zonta_oc_filters FROM TABLE lt_filters.
      MODIFY zonta_oc_franges FROM TABLE lt_ranges.
      IF sy-subrc = 0.
        COMMIT WORK.
        MESSAGE s042(zon_cl_oc).
        gv_variant_exist = abap_true.
      ENDIF.

* Save VARIANT into table
*      APPEND INITIAL LINE TO gt_variantd ASSIGNING field-symbol(<fs_variant>).
      APPEND INITIAL LINE TO gt_variantd ASSIGNING <fs_variant>.
      <fs_variant>-domainv       = zonta_obj_oc-domainv.
      <fs_variant>-business_proc = zonta_obj_oc-business_proc.
      <fs_variant>-id            = zonta_obj_oc-id.
      <fs_variant>-variant       = zonta_oc_variant-variant.
      <fs_variant>-vdescription  = zonta_oc_variant-description.
      <fs_variant>-variant_type  = 'F'.
      <fs_variant>-created_by = sy-uname.
      <fs_variant>-created_on = sy-datum.

      IF lines( gt_variantd ) > 0.
        MODIFY zonta_oc_variant FROM TABLE gt_variantd.
        IF sy-subrc = 0.
          COMMIT WORK.
          MESSAGE s042(zon_cl_oc).
        ENDIF.
      ENDIF.

    ENDIF.
* Dynamic variant save
  ELSE.

*    LOOP AT gt_variant_alv INTO data(ls_variant_alv).
    LOOP AT gt_variant_alv INTO ls_variant_alv.
      IF ls_variant_alv-vtype IS NOT INITIAL.
        APPEND INITIAL LINE TO gt_variantd ASSIGNING <fs_variant>.
        MOVE-CORRESPONDING ls_variant_alv TO <fs_variant>.

        <fs_variant>-domainv       = zonta_obj_oc-domainv.
        <fs_variant>-business_proc = zonta_obj_oc-business_proc.
        <fs_variant>-id            = zonta_obj_oc-id.
        <fs_variant>-variant       = zonta_oc_variant-variant.
        <fs_variant>-vdescription  = zonta_oc_variant-description.
        <fs_variant>-tabname       = ls_variant_alv-tabname.
        <fs_variant>-fieldname     = ls_variant_alv-fieldtext.
        <fs_variant>-variant_type  = 'D'.
*        <fs_variant>-svar          = 'D'.
        <fs_variant>-sapvar        = ls_variant_alv-sapvar.
        <fs_variant>-description   = ls_variant_alv-vtext.
        <fs_variant>-sign          = ls_variant_alv-sign.
        <fs_variant>-opti          = ls_variant_alv-option.
        <fs_variant>-created_by = sy-uname.
        <fs_variant>-created_on = sy-datum.
      ENDIF.
    ENDLOOP.

    IF lines( gt_variantd ) > 0.
      MODIFY zonta_oc_variant FROM TABLE gt_variantd.
      IF sy-subrc = 0.
        COMMIT WORK.
        MESSAGE s042(zon_cl_oc).
        gv_variantd_exist = abap_true.
      ENDIF.
    ENDIF.

  ENDIF.


  gv_variant = zonta_oc_variant-variant.

  CLEAR gt_variantd[].
  CONCATENATE 'ZGVAR' sy-uname INTO lv_memory.
  EXPORT gv_variant = gv_variant TO MEMORY ID lv_memory.
*  ENDIF.

ENDFORM.                    "save_variant
*&---------------------------------------------------------------------*
*& Form fieldcat_varatt
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_VARATT_ALV[]
*&      <-- GT_FCAT_VARATT
*&---------------------------------------------------------------------*
FORM fieldcat_varatt  USING       pt_table     TYPE ANY TABLE
                        CHANGING  pt_fieldcat  TYPE lvc_t_fcat.

  DATA:
    lr_tabdescr TYPE REF TO cl_abap_structdescr,
    lr_data     TYPE REF TO data,
    lt_dfies    TYPE ddfields,
    ls_dfies    TYPE dfies,
    ls_fieldcat TYPE lvc_s_fcat.

  CLEAR pt_fieldcat.

  CREATE DATA lr_data LIKE LINE OF pt_table.
  lr_tabdescr ?= cl_abap_structdescr=>describe_by_data_ref( lr_data ).
  lt_dfies = cl_salv_data_descr=>read_structdescr( lr_tabdescr ).

  LOOP AT lt_dfies INTO ls_dfies.
    CLEAR ls_fieldcat.
    MOVE-CORRESPONDING ls_dfies TO ls_fieldcat.


    CASE ls_fieldcat-fieldname.
      WHEN 'CELLTAB' OR 'VARIABLE'.
        ls_fieldcat-no_out = 'X'.
      WHEN  'SIGN' OR 'OPTION'.
        ls_fieldcat-f4availabl = 'X'.
        ls_fieldcat-outputlen = '5'.
      WHEN OTHERS.
        ls_fieldcat-outputlen = '30'.
    ENDCASE.

    APPEND ls_fieldcat TO pt_fieldcat.
  ENDLOOP.
ENDFORM.                    "fieldcat_varatt
*&---------------------------------------------------------------------*
*& Form prepare_celltab_varatt
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM prepare_celltab_varatt .
  FIELD-SYMBOLS: <fs_alv> LIKE LINE OF gt_varatt.

  DATA: lv_index        TYPE sy-tabix.
  DATA: ls_celltab TYPE lvc_s_styl,
        lv_styled  TYPE raw4,
        lv_stylee  TYPE raw4.

  DATA: ls_vardyn LIKE LINE OF gt_vardyn.

  CLEAR: gt_celltab[],
         gt_celltab_all[].

  lv_stylee    = cl_gui_alv_grid=>mc_style_enabled.
  lv_styled    = cl_gui_alv_grid=>mc_style_disabled.


  ls_celltab-style = lv_styled.
  ls_celltab-fieldname = 'DESCRIPTION'.
  INSERT ls_celltab INTO TABLE gt_celltab_all.
  INSERT ls_celltab INTO TABLE gt_celltab.

  ls_celltab-style = lv_stylee.
  ls_celltab-fieldname = 'OPTION'.
  INSERT ls_celltab INTO TABLE gt_celltab_all.
  ls_celltab-style = lv_styled.
  INSERT ls_celltab INTO TABLE gt_celltab.

  ls_celltab-style = lv_stylee.
  ls_celltab-fieldname = 'SIGN'.
  INSERT ls_celltab INTO TABLE gt_celltab_all.
  INSERT ls_celltab INTO TABLE gt_celltab.


  LOOP AT gt_varatt ASSIGNING <fs_alv>.
    CLEAR <fs_alv>-celltab.
*    READ TABLE gt_vardyn INTO data(ls_vardyn) WITH KEY sapvar = <fs_alv>-variable.
    READ TABLE gt_vardyn INTO ls_vardyn WITH KEY sapvar = <fs_alv>-variable.
    IF sy-subrc = 0 AND ls_vardyn-option_enabled = abap_true.
      INSERT LINES OF gt_celltab_all INTO TABLE <fs_alv>-celltab.
    ELSE.
      INSERT LINES OF gt_celltab INTO TABLE <fs_alv>-celltab.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "prepare_celltab_varatt
*&---------------------------------------------------------------------*
*& Form clear_varatt
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM clear_varatt .
  FIELD-SYMBOLS: <fs_var> LIKE LINE OF gt_varatt.

*  LOOP AT gt_varatt ASSIGNING <fs_var>.
*    CLEAR: <fs_var>-sign,
*           <fs_var>-option.
*  ENDLOOP.
ENDFORM.                    "clear_varatt
*&---------------------------------------------------------------------*
*& Form validate_tvarvc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_VALUE
*&      <-- LV_EXIST
*&---------------------------------------------------------------------*
FORM validate_tvarvc  USING    p_value
                      CHANGING p_exist.

  DATA: lv_name TYPE tvarvc-name.
  DATA ls_tvarvc TYPE tvarvc.

  lv_name = p_value.

  SELECT SINGLE *
*    INTO @data(ls_tvarvc)
    INTO ls_tvarvc
    FROM tvarvc
*    WHERE name = @lv_name.
    WHERE name = lv_name.
  IF sy-subrc = 0.
    p_exist = abap_true.
  ELSE.
    p_exist = abap_false.
  ENDIF.
ENDFORM.                    "validate_tvarvc
*&---------------------------------------------------------------------*
*& Form validate_variant
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM validate_variant .
  DATA: lv_len TYPE i,
        ls_var TYPE zonta_oc_variant.

  DATA ls_var_old TYPE zonta_oc_variant.

  CONCATENATE 'ZONT' sy-uname INTO lv_memory.
  IMPORT: zonta_obj_oc FROM MEMORY ID lv_memory.


  gv_error = abap_false.
  IF zonta_oc_variant-variant IS NOT INITIAL.
    lv_len = strlen( zonta_oc_variant-variant ).
    IF lv_len > 14.
      MESSAGE i044(zon_cl_oc) WITH zonta_oc_variant-variant.
      gv_error = abap_true.
    ELSE.
      SELECT SINGLE *
*        INTO @data(ls_var_old)
        INTO ls_var_old
        FROM zonta_oc_variant
*        WHERE domainv = @zonta_obj_oc-domainv
*          AND business_proc = @zonta_obj_oc-business_proc
*          AND variant = @zonta_oc_variant-variant.
        WHERE domainv = zonta_obj_oc-domainv
          AND business_proc = zonta_obj_oc-business_proc
          AND variant = zonta_oc_variant-variant.
      IF sy-subrc = 0 AND gv_variant IS INITIAL.
        MESSAGE i043(zon_cl_oc) WITH zonta_oc_variant-variant.
        gv_error = abap_true.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    "validate_variant
*&---------------------------------------------------------------------*
*& Form validate_filepath
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM validate_filepath .
  DATA: lt_filelist TYPE STANDARD TABLE OF epsfili,
        lv_dirname  TYPE epsdirnam,
        lv_files    TYPE string,
        lv_file     TYPE authb-filename,
        lv_path     TYPE string,
        lv_line     TYPE string.

  gv_path_error = abap_false.
  IF zonta_obj_oc-log_type = 'F' AND zonta_obj_oc-file_path IS NOT INITIAL.
    lv_dirname = zonta_obj_oc-file_path.
    CALL FUNCTION 'EPS_GET_DIRECTORY_LISTING'
      EXPORTING
        dir_name               = lv_dirname
      TABLES
        dir_list               = lt_filelist
      EXCEPTIONS
        invalid_eps_subdir     = 1
        sapgparam_failed       = 2
        build_directory_failed = 3
        no_authorization       = 4
        read_directory_failed  = 5
        too_many_read_errors   = 6
        empty_directory_list   = 7
        OTHERS                 = 8.

    IF sy-subrc = 0.
      lv_files = lv_dirname && '/' && zonta_obj_oc-business_proc && '.txt'.
      lv_file = lv_files.
      CALL FUNCTION 'AUTHORITY_CHECK_DATASET'
        EXPORTING
          activity         = 'WRITE'  " or 'READ', 'DELETE', 'EXECUTE'
          filename         = lv_file
        EXCEPTIONS
          no_authority     = 1
          activity_unknown = 2
          OTHERS           = 3.
      IF sy-subrc NE 0.
        MESSAGE i048(zon_cl_oc) WITH lv_dirname.
        gv_path_error = abap_true.
      ENDIF.
    ELSE.
      MESSAGE i047(zon_cl_oc) WITH lv_dirname.
      gv_path_error = abap_true.
    ENDIF.


* Check write authority
    IF gv_path_error = abap_false.
      lv_path = zonta_obj_oc-file_path &&
                '/' &&
                zonta_obj_oc-business_proc &&
                '.txt'.
      DATA v_tryoff TYPE c.
      SELECT SINGLE low INTO v_tryoff FROM zonta_oc_param WHERE name = 'SET_TRY_OFF'.
      IF v_tryoff IS NOT INITIAL.
        OPEN DATASET lv_path FOR APPENDING IN TEXT MODE ENCODING DEFAULT.
        IF sy-subrc NE 0.
          OPEN DATASET lv_path FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
        ENDIF.
        IF sy-subrc = 0.
          lv_line = 'Opening file..'.
          TRANSFER lv_line TO lv_path.
          CLOSE DATASET lv_path.
        ELSE.
          MESSAGE i048(zon_cl_oc) WITH lv_path.
          gv_path_error = abap_true.
        ENDIF.
      ELSE.
        TRY.
            OPEN DATASET lv_path FOR APPENDING IN TEXT MODE ENCODING DEFAULT.
            IF sy-subrc NE 0.
              OPEN DATASET lv_path FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
            ENDIF.
            IF sy-subrc = 0.
              lv_line = 'Opening file..'.
              TRANSFER lv_line TO lv_path.
              CLOSE DATASET lv_path.
            ELSE.
              MESSAGE i048(zon_cl_oc) WITH lv_path.
              gv_path_error = abap_true.
            ENDIF.
          CATCH cx_sy_file_open_mode.
            MESSAGE i202(cacsib_edt) WITH lv_path.
        ENDTRY.
      ENDIF.
    ENDIF.

  ENDIF.

  IF gv_path_error = abap_true  AND gv_ini = abap_true.
    MESSAGE i049(zon_cl_oc) WITH lv_path.
  ENDIF.
  gv_ini = abap_false.
ENDFORM.                    "validate_filepath
*&---------------------------------------------------------------------*
*& Form check_alias_domain
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_SAVE>
*&      --> LS_SAVE
*&      <-- LV_SAME
*&---------------------------------------------------------------------*
FORM check_alias_domain  USING    p_save_old TYPE zonta_oc_col_all
                                  p_save_new TYPE zonta_oc_col_all
                         CHANGING p_same TYPE boolean.

  DATA: lt_dfold TYPE STANDARD TABLE OF dfies,
        lt_dfnew TYPE STANDARD TABLE OF dfies,
        ls_dfold TYPE dfies,
        ls_dfnew TYPE dfies,
        lv_fold  TYPE dfies-fieldname,
        lv_fnew  TYPE dfies-fieldname.

  lv_fnew = p_save_new-fldname.
  lv_fold = p_save_old-fldname.

  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname        = p_save_new-tabname
      fieldname      = lv_fnew
    TABLES
      dfies_tab      = lt_dfnew
    EXCEPTIONS
      not_found      = 1
      internal_error = 2
      OTHERS         = 3.

  CALL FUNCTION 'DDIF_FIELDINFO_GET'
    EXPORTING
      tabname        = p_save_old-tabname
      fieldname      = lv_fold
    TABLES
      dfies_tab      = lt_dfold
    EXCEPTIONS
      not_found      = 1
      internal_error = 2
      OTHERS         = 3.

  READ TABLE lt_dfnew INTO ls_dfnew INDEX 1.
  READ TABLE lt_dfold INTO ls_dfold INDEX 1.
  IF ls_dfnew-domname = ls_dfold-domname.
    p_same = abap_true.
  ELSE.
    p_same = abap_false.
  ENDIF.
ENDFORM.                    "check_alias_domain
*&---------------------------------------------------------------------*
*& Form check_entity_name_excel
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_OBJ_NEW
*&      <-- LT_RELATIONS
*&---------------------------------------------------------------------*
FORM check_entity_name_excel  TABLES   pt_obj        STRUCTURE zonta_obj_oc
                                       pt_relations  STRUCTURE zonta_relations.


  CONSTANTS: c_guion TYPE c VALUE '_'.

  DATA: lv_first        TYPE string,
        lv_second       TYPE string,
        lv_entity_wrong TYPE zonde_process.

  FIELD-SYMBOLS: <fs_obj> LIKE LINE OF pt_obj,
                 <fs_rel> LIKE LINE OF pt_relations.

  TYPES: BEGIN OF st_table,
           data TYPE c LENGTH 255,
         END OF st_table.

  DATA:
    lt_tab TYPE STANDARD TABLE OF st_table,
    ls_tab TYPE st_table.

  LOOP AT pt_obj ASSIGNING <fs_obj>.
    IF <fs_obj>-business_proc CS space.
      lv_entity_wrong = <fs_obj>-business_proc.
      SPLIT  <fs_obj>-business_proc  AT space INTO TABLE lt_tab.
      LOOP AT lt_tab INTO ls_tab.
        CONCATENATE lv_second ls_tab-data INTO lv_second SEPARATED BY '_'.
      ENDLOOP.
      <fs_obj>-business_proc  = lv_second.
      SHIFT  <fs_obj>-business_proc BY 1 PLACES .
      LOOP AT pt_relations ASSIGNING <fs_rel> WHERE business_proc = lv_entity_wrong.
        <fs_rel>-business_proc = <fs_obj>-business_proc.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "check_entity_name_excel
*&---------------------------------------------------------------------*
*& Form check_position_columns
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LT_COLUMNS_SAVE[]
*&---------------------------------------------------------------------*
FORM check_position_columns  TABLES p_col STRUCTURE zonta_oc_col_all .

  FIELD-SYMBOLS: <fs_col> LIKE LINE OF p_col.
  DATA ls_columns LIKE LINE OF gt_columns.

*  LOOP AT p_col ASSIGNING field-symbol(<fs_col>) ."WHERE positionf IS INITIAL.
  LOOP AT p_col ASSIGNING <fs_col> ."WHERE positionf IS INITIAL.
*     READ TABLE gt_columns INTO data(ls_columns) WITH KEY tabname = <fs_col>-tabname
    READ TABLE gt_columns INTO ls_columns WITH KEY tabname = <fs_col>-tabname
                                                         fldname = <fs_col>-fldname.
    IF sy-subrc = 0.
      <fs_col>-positionf = ls_columns-positionf.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "check_position_columns

*&---------------------------------------------------------------------*
*& Form download_excel
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM download_excel .

  IF go_cust IS INITIAL.
    CREATE OBJECT go_cust
      EXPORTING
        iv_domainv       = zonta_obj_oc-domainv
        iv_business_proc = zonta_obj_oc-business_proc.
  ENDIF.

  CALL METHOD go_cust->send_excel_metadata
    EXPORTING
      iv_entity = zonta_obj_oc-business_proc
      iv_domain = zonta_obj_oc-domainv
      iv_file   = gv_file.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form write_cell
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LO_SHEET
*&      --> LV_ROW
*&      --> LV_COL
*&      --> <FS_ANY>
*&---------------------------------------------------------------------*
FORM write_cell USING
      po_sheet TYPE ole2_object
      pv_row   TYPE i
      pv_col   TYPE i
      pv_value TYPE any.

  DATA: lo_cell TYPE ole2_object.

  CALL METHOD OF po_sheet 'Cells' = lo_cell
    EXPORTING
      #1 = pv_row
      #2 = pv_col.

  SET PROPERTY OF lo_cell 'Value' = pv_value.

  FREE OBJECT lo_cell.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form clone_entity
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM clone_entity.


  CONSTANTS: c_guion TYPE c VALUE '_'.
  DATA: lv_first  TYPE string,
        lv_second TYPE string,
        lv_id     TYPE zonde_id,
        ls_obj_oc TYPE zonta_obj_oc.

  TYPES: BEGIN OF st_table,
           data TYPE c LENGTH 255,
         END OF st_table.

  DATA:
    lt_tab TYPE STANDARD TABLE OF st_table,
    ls_tab TYPE st_table.


  IF gv_cloned_entity CS space.
    SPLIT gv_cloned_entity  AT space INTO TABLE lt_tab.
    LOOP AT lt_tab INTO ls_tab.
      CONCATENATE lv_second ls_tab-data INTO lv_second SEPARATED BY '_'.
    ENDLOOP.
    gv_cloned_entity  = lv_second.
    SHIFT  gv_cloned_entity BY 1 PLACES .
  ENDIF.


* Check target entity does not exist
  SELECT SINGLE *
  FROM zonta_obj_oc
  WHERE domainv       = zonta_obj_oc-domainv
    AND business_proc = gv_cloned_entity.

  IF sy-subrc = 0.
    MESSAGE e124(zon_cl_oc).
  ELSE.

    PERFORM get_next_range USING c_rentity CHANGING lv_id.
    IF lv_id = 0 OR lv_id IS INITIAL.
      lv_id = 1.
    ENDIF.

* Copy tables
    PERFORM copy_table USING 'ZONTA_OBJ_OC'     zonta_obj_oc-domainv zonta_obj_oc-business_proc gv_cloned_entity lv_id.
    PERFORM copy_table USING 'ZONTA_RELATIONS'  zonta_obj_oc-domainv zonta_obj_oc-business_proc gv_cloned_entity lv_id.
*    PERFORM copy_table USING 'ZONTA_OC_AUTH'    zonta_obj_oc-domainv zonta_obj_oc-business_proc gv_cloned_entity.

    IF cfilter = abap_true.
      PERFORM copy_table USING 'ZONTA_OC_FILTERS' zonta_obj_oc-domainv zonta_obj_oc-business_proc gv_cloned_entity lv_id.
      PERFORM copy_table USING 'ZONTA_OC_FRANGES' zonta_obj_oc-domainv zonta_obj_oc-business_proc gv_cloned_entity lv_id.
    ENDIF.

    IF cvariant = abap_true.
      PERFORM copy_table USING 'ZONTA_OC_VARIANT' zonta_obj_oc-domainv zonta_obj_oc-business_proc gv_cloned_entity lv_id.
    ENDIF.

    COMMIT WORK.

    MESSAGE s132(zon_cl_oc).

    ls_obj_oc = zonta_obj_oc.
    CLEAR zonta_obj_oc.

    PERFORM get_current_data.
    ls_obj_oc-id = lv_id.
    ls_obj_oc-business_proc = gv_cloned_entity.

    PERFORM get_initial_data USING ls_obj_oc.
    PERFORM regenerate.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form copy_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> IV_DOMAIN
*&      --> IV_SOURCE_PROC
*&      --> IV_TARGET_PROC
*&---------------------------------------------------------------------*
FORM copy_table
  USING
    iv_tabname     TYPE tabname
    iv_domain      TYPE zonde_domain
    iv_source_proc TYPE zonde_process
    iv_target_proc TYPE zonde_process
    iv_id          TYPE zonde_id.


  DATA:
    lr_data TYPE REF TO data.

  FIELD-SYMBOLS:
    <lt_table> TYPE STANDARD TABLE,
    <ls_row>   TYPE any,
    <lv_proc>  TYPE any.

* Create dynamic table
  CREATE DATA lr_data TYPE TABLE OF (iv_tabname).
  ASSIGN lr_data->* TO <lt_table>.

* Read source entity
  SELECT *
  INTO TABLE <lt_table>
  FROM (iv_tabname)
  WHERE domainv       = iv_domain
    AND business_proc = iv_source_proc.

  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

* Replace BUSINESS_PROC
  LOOP AT <lt_table> ASSIGNING <ls_row>.

    ASSIGN COMPONENT 'BUSINESS_PROC' OF STRUCTURE <ls_row> TO <lv_proc>.
    IF sy-subrc = 0.
      <lv_proc> = iv_target_proc.
    ENDIF.

    ASSIGN COMPONENT 'ERDAT' OF STRUCTURE <ls_row> TO <lv_proc>.
    IF sy-subrc = 0.
      <lv_proc> = sy-datum.
    ENDIF.

    ASSIGN COMPONENT 'UPDATED_ON' OF STRUCTURE <ls_row> TO <lv_proc>.
    IF sy-subrc = 0.
      <lv_proc> = sy-datum.
    ENDIF.

    ASSIGN COMPONENT 'ERNAM' OF STRUCTURE <ls_row> TO <lv_proc>.
    IF sy-subrc = 0.
      <lv_proc> = sy-uname.
    ENDIF.

    ASSIGN COMPONENT 'UPDATED_BY' OF STRUCTURE <ls_row> TO <lv_proc>.
    IF sy-subrc = 0.
      <lv_proc> = sy-uname.
    ENDIF.

    ASSIGN COMPONENT 'ID' OF STRUCTURE <ls_row> TO <lv_proc>.
    IF sy-subrc = 0.
      <lv_proc> = iv_id.
    ENDIF.

    ASSIGN COMPONENT 'VERSION' OF STRUCTURE <ls_row> TO <lv_proc>.
    IF sy-subrc = 0.
      <lv_proc> = 1.
    ENDIF.

  ENDLOOP.

* Insert new entity records
  INSERT (iv_tabname) FROM TABLE <lt_table>.
ENDFORM.


*&---------------------------------------------------------------------*
*& Form synch_metadata
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM synch_metadata .

  CALL TRANSACTION 'ZONT_OC_SYNCH_META'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form fill_gt_obj_oc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ZONTA_OBJ_OC_DOMAINV
*&---------------------------------------------------------------------*
FORM fill_gt_obj_oc  USING    p_domain p_entity.

  DATA: lr_domain TYPE RANGE OF zonde_domain,
        ls_domain LIKE LINE OF lr_domain.

  IF p_domain IS NOT INITIAL.
    ls_domain-sign   = 'I'.
    ls_domain-option = 'EQ'.
    ls_domain-low    = p_domain.
    APPEND ls_domain TO lr_domain.
  ENDIF.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_obj_oc
    FROM zonta_obj_oc
    WHERE domainv IN lr_domain.
ENDFORM.
