*----------------------------------------------------------------------*
***INCLUDE ZONPG_ONECONNECT_CUST_EXE_PBO.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  DATA: lt_exclude1 TYPE ui_functions.

  CLEAR  lt_exclude1[].
  IF gv_system = space.
    APPEND 'CREATE'   TO lt_exclude1.
    APPEND 'CHANGE'   TO lt_exclude1.
    APPEND 'DELETE'   TO lt_exclude1.
    APPEND 'GENERATE' TO lt_exclude1.
    APPEND 'UPLOAD'   TO lt_exclude1.
  ENDIF.

  SET PF-STATUS 'PF100'
         EXCLUDING lt_exclude1.

ENDMODULE.                    "status_0100 OUTPUT
*&---------------------------------------------------------------------*
*& Module FILL_LIST OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE fill_list OUTPUT.
  PERFORM init_list.
  PERFORM add_logo.
  PERFORM get_param_information.
  PERFORM update_main_screen.
ENDMODULE.                    "fill_list OUTPUT
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS 'PF200'.
  PERFORM clean_create.
ENDMODULE.                    "status_0200 OUTPUT
*&---------------------------------------------------------------------*
*& Module STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0300 OUTPUT.

  DATA: lt_exclude TYPE ui_functions.

  CLEAR  lt_exclude[].
  IF gv_option = co_display.
    APPEND 'JOIN'      TO lt_exclude.
    APPEND 'COLUMNS'   TO lt_exclude.
    APPEND 'FILTERS'   TO lt_exclude.
    APPEND 'SAVE_DATA' TO lt_exclude.
    APPEND 'CODE'      TO lt_exclude.
  ENDIF.

  IF gv_entity_type = c_relat.
    APPEND 'CODE'      TO lt_exclude.
  ENDIF.

  SET PF-STATUS 'PF300'
         EXCLUDING lt_exclude.

  IF go_cust IS INITIAL.
    CREATE OBJECT go_cust
      EXPORTING
        iv_domainv       = zonta_obj_oc-domainv
        iv_business_proc = zonta_obj_oc-business_proc.
  ENDIF.


ENDMODULE.                    "status_0300 OUTPUT
*&---------------------------------------------------------------------*
*& Module UPDATE_SCREEN OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE update_screen OUTPUT.

  IF NOT zonta_obj_oc-tag1 IS INITIAL.
    zonta_obj_oc-domainv = zonta_obj_oc-tag1.
  ENDIF.

  LOOP AT SCREEN.

    IF screen-group2 = 'FIL'.
      IF file = abap_true.
        screen-active = 1.
      ELSE.
        screen-active = 0.
      ENDIF.
    ENDIF.

    IF screen-group1 = 'SAM'.
      CASE gv_option.
        WHEN co_change.
          screen-input = '1'.
        WHEN co_display.
          screen-input = '0'.
      ENDCASE.
      MODIFY SCREEN.
    ENDIF.
    IF gv_new = abap_true.
      IF screen-name = 'ZONTA_OBJ_OC-BUSINESS_PROC' OR
         screen-name = 'ZONTA_OBJ_OC-TAG1'          OR
         screen-name = 'ZONTA_OBJ_OC-DOMAINV'.
        screen-active = 1.
        screen-input = 1.
        screen-required = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.


ENDMODULE.                    "update_screen OUTPUT
*&---------------------------------------------------------------------*
*& Module INIT_ALV_INFO_TAB OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_alv_info_tab OUTPUT.

  DATA: lv_edit TYPE boolean.
  DATA: lv_height TYPE i,
        lv_width  TYPE i.
  FIELD-SYMBOLS: <fs_fcat> LIKE LINE OF gt_fcat_tables,
                 <fs_taba> LIKE LINE OF gt_tables_alv.

  IF gv_option = co_display.
    lv_edit = abap_false.
  ELSE.
    lv_edit = abap_true.
  ENDIF.


  IF NOT lo_alv_tables IS BOUND.
    CREATE OBJECT lo_container_tables
      EXPORTING
        container_name = 'CONTAINER_TABLES'.

*lv_height = 150.
*lv_width = 200.
*  CALL METHOD lo_container_tables->set_size
*    EXPORTING
*      height = lv_height
*      width  = lv_width.

    CREATE OBJECT lo_alv_tables
      EXPORTING
        i_parent = lo_container_tables.

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

    IF gt_ex_rel IS INITIAL.
      IF lines( gt_yrelations ) > 0.
        SELECT *
          FROM zonta_relations
          INTO TABLE gt_ex_rel
          FOR ALL ENTRIES IN gt_yrelations
          WHERE NOT ( domainv      = zonta_obj_oc-domainv
            AND business_proc      = zonta_obj_oc-business_proc )
            AND tabname            = gt_yrelations-tabname
            AND alias_tabname      = gt_yrelations-alias_tabname.
      ENDIF.
    ENDIF.
    SORT gt_ex_rel BY tabname.
    DELETE ADJACENT DUPLICATES FROM gt_ex_rel COMPARING tabname.
    LOOP AT gt_ex_rel INTO gs_ex_rel.
      READ TABLE gt_tables_alv ASSIGNING <fs_taba> WITH KEY tabname = gs_ex_rel-tabname
                                                            alias_tabname = gs_ex_rel-alias_tabname.
      IF sy-subrc = 0.
        <fs_taba>-icon_id = '@5D@'.
        mes1 = 'Warning! Some tables already exist in'.
        mes2 = 'different Entity, be careful while changing'.
      ELSE.
        CLEAR <fs_taba>-icon_id.
        CLEAR: mes1, mes2.
      ENDIF.
    ENDLOOP.
    IF NOT mes1 IS INITIAL.
      MESSAGE i018(zon_cl_oc) DISPLAY LIKE 'W'.
    ENDIF.

* Prepare fieldcat for Tables and columns
    PERFORM fieldcat USING  gt_tables_alv[]
                      CHANGING  gt_fcat_tables.

    READ TABLE gt_fcat_tables ASSIGNING <fs_fcat> WITH KEY fieldname = 'ICON_ID'.
    IF sy-subrc = 0.
      <fs_fcat>-icon = c_x.
    ENDIF.

    PERFORM prepare_celltab_tables.

* Layout options-------------------------------------------------------*
    CLEAR gs_alv_layout_t.
    MOVE abap_true TO: gs_alv_layout_t-cwidth_opt,
                       gs_alv_layout_t-zebra,
                       gs_alv_layout_t-col_opt.
    gs_alv_layout_t-stylefname = 'CELLTAB'.

    gt_exclude_col[] = gt_exclude[].
    PERFORM exclude_options_alv.
    gs_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row .
    APPEND gs_exclude TO gt_exclude.


    " Display Relations ALV grid
    PERFORM ready_input CHANGING lo_alv_tables.

    CREATE OBJECT lo_event_handler.
    SET HANDLER lo_event_handler->on_user_command FOR lo_alv_tables.

    SORT gt_tables_alv BY sequence levelv tabname.
    lo_alv_tables->set_table_for_first_display(
      EXPORTING
        i_structure_name = 'ZONST_TABLES_ALV'
        is_layout        = gs_alv_layout_t
        it_toolbar_excluding = gt_exclude
      CHANGING
        it_outtab        = gt_tables_alv
        it_fieldcatalog  = gt_fcat_tables
    ).

    CALL METHOD lo_alv_tables->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_enter
      EXCEPTIONS
        error      = 1
        OTHERS     = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CALL METHOD lo_alv_tables->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified
      EXCEPTIONS
        error      = 1
        OTHERS     = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    PERFORM register_alv_events CHANGING lo_alv_tables.

  ELSE.
    PERFORM get_changes_data USING lo_alv_tables.
    PERFORM prepare_celltab_tables.

    IF gt_ex_rel IS INITIAL.
      IF lines( gt_tables_alv ) > 0.
        SELECT *
          FROM zonta_relations
          INTO TABLE gt_ex_rel
          FOR ALL ENTRIES IN gt_tables_alv
          WHERE NOT ( domainv      = zonta_obj_oc-domainv
            AND business_proc      = zonta_obj_oc-business_proc )
            AND tabname            = gt_tables_alv-tabname
            AND alias_tabname      = gt_tables_alv-alias_tabname.

      ENDIF.
    ENDIF.
    SORT gt_ex_rel BY tabname.
    DELETE ADJACENT DUPLICATES FROM gt_ex_rel COMPARING tabname.
    LOOP AT gt_ex_rel INTO gs_ex_rel.
      READ TABLE gt_tables_alv ASSIGNING <fs_taba> WITH KEY tabname = gs_ex_rel-tabname
                                                            alias_tabname = gs_ex_rel-alias_tabname.

      IF sy-subrc = 0.
        <fs_taba>-icon_id = '@5D@'.
        mes1 = 'Warning! Some tables already exist in'.
        mes2 = 'different Entity, be careful while changing'.
      ELSE.
        CLEAR <fs_taba>-icon_id.
        CLEAR: mes1, mes2.
      ENDIF.
    ENDLOOP.
    IF NOT mes1 IS INITIAL.
      MESSAGE i018(zon_cl_oc) DISPLAY LIKE 'W'.
    ENDIF.

    SORT gt_tables_alv BY sequence levelv tabname.
    PERFORM update_grid USING lo_alv_tables.
  ENDIF.


ENDMODULE.                    "init_alv_info_tab OUTPUT

*&---------------------------------------------------------------------*
*& Module INIT_ALV_INFO_COL OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_alv_info_col OUTPUT.
  FIELD-SYMBOLS: <fs_fieldcat> LIKE LINE OF gt_fcat_columns .


  SORT gt_columns_alv BY tabname fldname.
  IF gv_option = co_display.
    lv_edit = abap_false.
  ELSE.
    lv_edit = abap_true.
  ENDIF.

  CHECK lines( gt_tables_alv ) > 0.
  IF NOT lo_alv_columns IS BOUND.
    CREATE OBJECT lo_container_columns
      EXPORTING
        container_name = 'CONTAINER_COLUMNS'.

    CREATE OBJECT lo_alv_columns
      EXPORTING
        i_parent = lo_container_columns.

    IF gv_new = abap_true AND lines( gt_columns_alv ) > 0.
    ELSE.
      SELECT *
        FROM zonta_oc_col_all
        INTO CORRESPONDING FIELDS OF TABLE gt_columns_alv
        FOR ALL ENTRIES IN gt_tables_alv
        WHERE tabname       = gt_tables_alv-tabname
          AND alias_tabname = gt_tables_alv-alias_tabname.
      SORT gt_columns_alv BY tabname key_field DESCENDING fldname.
    ENDIF.

    SELECT *
      FROM zonta_oc_col_all
      INTO TABLE gt_ycolumns
            FOR ALL ENTRIES IN gt_tables_alv
      WHERE tabname = gt_tables_alv-tabname
        AND alias_tabname = gt_tables_alv-alias_tabname.


    PERFORM fieldcat USING  gt_columns_alv[]
                      CHANGING  gt_fcat_columns.


    LOOP AT gt_fcat_columns ASSIGNING <fs_fieldcat>.
      CASE <fs_fieldcat>-fieldname.
        WHEN 'KEY_FIELD'.
          <fs_fieldcat>-checkbox = abap_true.
        WHEN 'SELECTION_FIELD'.
          <fs_fieldcat>-checkbox = abap_true.
          <fs_fieldcat>-coltext  = 'Selection'(007).
      ENDCASE.
    ENDLOOP.

* Layout options-------------------------------------------------------*
    CLEAR gs_alv_layout_c.
    MOVE abap_true TO: gs_alv_layout_c-cwidth_opt,
                       gs_alv_layout_c-zebra,
                       gs_alv_layout_c-col_opt.
    gs_alv_layout_c-stylefname = 'CELLTAB'.

    PERFORM exclude_options_alv.
    gt_exclude_col[] = gt_exclude[].

    CALL METHOD lo_alv_columns->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_enter
      EXCEPTIONS
        error      = 1
        OTHERS     = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CALL METHOD lo_alv_columns->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified
      EXCEPTIONS
        error      = 1
        OTHERS     = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    PERFORM prepare_celltab_columns.

    PERFORM ready_input CHANGING lo_alv_columns.
    PERFORM get_columns_sort CHANGING gt_columns_alv.
    " Initialize Columns grid as empty
    lo_alv_columns->set_table_for_first_display(
      EXPORTING
*        i_structure_name     = 'ZONST_COLUMNS_ALV'
        is_layout            = gs_alv_layout_c
        it_toolbar_excluding = gt_exclude_col
      CHANGING
        it_outtab            = gt_columns_alv
        it_fieldcatalog      = gt_fcat_columns
    ).

    PERFORM register_alv_events CHANGING lo_alv_columns.

    DATA: lo_event_receiver TYPE REF TO lcl_grid_event_receiver_col.


    CREATE OBJECT lo_event_receiver.

    SET HANDLER lo_event_receiver->handle_user_command FOR lo_alv_columns.
    SET HANDLER lo_event_receiver->handle_toolbar FOR lo_alv_columns.

    CALL METHOD lo_alv_columns->set_toolbar_interactive.
  ELSE.
    PERFORM prepare_celltab_columns.
    PERFORM update_grid USING lo_alv_columns.
  ENDIF.


ENDMODULE.                    "init_alv_info_col OUTPUT
*&---------------------------------------------------------------------*
*& Module STATUS_0400 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0400 OUTPUT.


  SET PF-STATUS 'PF400'.
  LOOP AT SCREEN.
    IF screen-name = 'GV_TABLEN'
    OR screen-name = 'GV_TABLENF'
    OR screen-name = 'GV_TABLEA'
    OR screen-name = 'GV_TABLEAF'.
      IF zonta_obj_oc-domainv = c_any.
        screen-active = 1.
      ELSE.
        screen-active = 0.
      ENDIF.
    ELSEIF ( screen-name = 'KDOC'
          OR screen-name = 'BOTH').
      IF zonta_obj_oc-domainv = c_any.
        screen-active = 0.
      ELSE.
        screen-active = 1.
      ENDIF.
    ENDIF.

    IF NOT zonta_obj_oc-class_name IS INITIAL.
      IF screen-group1 = 'REL'
      OR screen-group2 = 'REL'.
        screen-active = 0.
      ELSE.
        screen-active = 1.
      ENDIF.
    ENDIF.

    IF screen-group1 = 'VAR'.
      IF gv_variant_exist  = abap_true
      OR gv_variantd_exist = abap_true.
        screen-active = 1.
      ELSE.
        screen-active = 0.
      ENDIF.
    ENDIF.

    MODIFY SCREEN.
  ENDLOOP.
ENDMODULE.                    "status_0400 OUTPUT
*&---------------------------------------------------------------------*
*& Module STATUS_0500 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0500 OUTPUT.
  SET PF-STATUS 'PF500'.
  PERFORM start.

ENDMODULE.                    "status_0500 OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0600  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0600 OUTPUT.
  SET PF-STATUS 'PF601'.
ENDMODULE.                 " STATUS_0600  OUTPUT


*&---------------------------------------------------------------------*
*& Module INIT_ALV_COL_ANY OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_alv_col_any OUTPUT.
  PERFORM init_alv_col_any.
ENDMODULE.                    "init_alv_colany OUTPUT
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  STATUS_0700  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0700 OUTPUT.
  SET PF-STATUS 'PF700'.
  PERFORM update_screen_700.
ENDMODULE.                 " STATUS_0700  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0800  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0800 OUTPUT.
  SET PF-STATUS 'PF800'.
ENDMODULE.                    "status_0800 OUTPUT
*&---------------------------------------------------------------------*
*&      Module  INIT_ALV_INFO_AUTH  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE init_alv_info_auth OUTPUT.

  DATA: ls_auth TYPE zonta_oc_auth,
        ls_tobj TYPE tobj.

  FIELD-SYMBOLS: <fs_fcat_auth> LIKE LINE OF gt_fcat_auth.

  CLEAR ls_auth.
  CLEAR ls_tobj.

  IF gv_option = co_display.
    lv_edit = abap_false.
  ELSE.
    lv_edit = abap_true.
  ENDIF.


  IF NOT lo_alv_auth IS BOUND.
    CREATE OBJECT lo_container_auth
      EXPORTING
        container_name = 'CONTAINER_AUTH'.

    CREATE OBJECT lo_alv_auth
      EXPORTING
        i_parent = lo_container_auth.

    CLEAR gt_auth_alv.
    SELECT SINGLE *
      INTO ls_auth
      FROM zonta_oc_auth
       WHERE id     = zonta_obj_oc-id.
    IF sy-subrc = 0.
      PERFORM add_auth_value USING ls_auth-fiel1 ls_auth-val1.
      PERFORM add_auth_value USING ls_auth-fiel2 ls_auth-val2.
      PERFORM add_auth_value USING ls_auth-fiel3 ls_auth-val3.
      PERFORM add_auth_value USING ls_auth-fiel4 ls_auth-val4.
      PERFORM add_auth_value USING ls_auth-fiel5 ls_auth-val5.
      PERFORM add_auth_value USING ls_auth-fiel6 ls_auth-val6.
      PERFORM add_auth_value USING ls_auth-fiel7 ls_auth-val7.
      PERFORM add_auth_value USING ls_auth-fiel8 ls_auth-val8.
      PERFORM add_auth_value USING ls_auth-fiel9 ls_auth-val9.
      PERFORM add_auth_value USING ls_auth-fiel0 ls_auth-val10.
    ENDIF.
    IF lines( gt_auth_alv ) = 0.
      SELECT SINGLE *
        INTO ls_tobj
        FROM tobj
        WHERE objct = zonta_oc_auth-objct.
      IF sy-subrc  = 0.
        PERFORM add_auth_value USING ls_tobj-fiel1 space.
        PERFORM add_auth_value USING ls_tobj-fiel2 space.
        PERFORM add_auth_value USING ls_tobj-fiel3 space.
        PERFORM add_auth_value USING ls_tobj-fiel4 space.
        PERFORM add_auth_value USING ls_tobj-fiel5 space.
        PERFORM add_auth_value USING ls_tobj-fiel6 space.
        PERFORM add_auth_value USING ls_tobj-fiel7 space.
        PERFORM add_auth_value USING ls_tobj-fiel8 space.
        PERFORM add_auth_value USING ls_tobj-fiel9 space.
        PERFORM add_auth_value USING ls_tobj-fiel0 space.
      ENDIF.
    ENDIF.


* Prepare fieldcat
    PERFORM fieldcat USING  gt_auth_alv[]
                      CHANGING  gt_fcat_auth.

    LOOP AT gt_fcat_auth ASSIGNING <fs_fcat_auth>.
      IF <fs_fcat_auth>-fieldname = 'FIEL'.
        <fs_fcat_auth>-outputlen = '10'.
      ELSEIF  <fs_fcat_auth>-fieldname = 'VAL'.
        <fs_fcat_auth>-outputlen = '40'.
      ENDIF.
    ENDLOOP.

    PERFORM prepare_celltab_auth.

* Layout options-------------------------------------------------------*
    CLEAR gs_alv_layout_t.
    MOVE abap_true TO: gs_alv_layout_t-cwidth_opt,
                       gs_alv_layout_t-zebra,
                       gs_alv_layout_t-col_opt,
                       gs_alv_layout_t-no_toolbar.
    gs_alv_layout_t-stylefname = 'CELLTAB'.

*    PERFORM exclude_options_alv.
*    gs_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row .
*    APPEND gs_exclude TO gt_exclude.


    " Display Relations ALV grid
    PERFORM ready_input CHANGING lo_alv_auth.

    CREATE OBJECT lo_event_handler.
    SET HANDLER lo_event_handler->on_user_command FOR lo_alv_auth.

    lo_alv_auth->set_table_for_first_display(
      EXPORTING
        i_structure_name = 'ZONST_AUTH_ALV'
        is_layout        = gs_alv_layout_t
*        it_toolbar_excluding = gt_exclude
      CHANGING
        it_outtab        = gt_auth_alv
        it_fieldcatalog  = gt_fcat_auth
    ).

    CALL METHOD lo_alv_auth->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_enter
      EXCEPTIONS
        error      = 1
        OTHERS     = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CALL METHOD lo_alv_auth->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified
      EXCEPTIONS
        error      = 1
        OTHERS     = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    PERFORM register_alv_events CHANGING lo_alv_auth.

  ELSE.
    PERFORM get_changes_data USING lo_alv_auth.
    PERFORM prepare_celltab_auth.
    PERFORM update_grid USING lo_alv_auth.
  ENDIF.


ENDMODULE.                    "init_alv_info_auth OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0900  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0900 OUTPUT.
  SET PF-STATUS 'PF900'.
ENDMODULE.                    "status_0900 OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0380  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0380 OUTPUT.
  DATA: lt_excluden TYPE ui_functions.

  CLEAR  lt_excluden[].
  IF gv_option = co_display.
    APPEND 'SAVE_DATA' TO lt_excluden.
    APPEND 'CODE'      TO lt_excluden.
  ENDIF.

  SET PF-STATUS 'PF380'
         EXCLUDING lt_excluden.

  IF go_cust IS INITIAL.
    CREATE OBJECT go_cust
      EXPORTING
        iv_domainv       = zonta_obj_oc-domainv
        iv_business_proc = zonta_obj_oc-business_proc.
  ENDIF.

ENDMODULE.                    "status_0380 OUTPUT
*&---------------------------------------------------------------------*
*& Module STATUS_1000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_1000 OUTPUT.
  SET PF-STATUS 'PF1000'.
ENDMODULE.                    "status_1000 OUTPUT
*&---------------------------------------------------------------------*
*& Module INIT_VARIANT_TAB OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_variant_tab OUTPUT.

  TYPES: BEGIN OF ty_varia,
    variant_type TYPE zonta_oc_variant-variant_type,
    vdescription TYPE zonta_oc_variant-vdescription,
    END OF ty_varia.

  DATA ls_varia TYPE ty_varia.

  IF NOT lo_alv_variant IS BOUND.

    IF lines( gt_variant_alv ) = 0.
      SELECT *
        FROM zonta_oc_variant
        INTO CORRESPONDING FIELDS OF TABLE gt_variant_alv
        WHERE domainv            = zonta_obj_oc-domainv
          AND business_proc      = zonta_obj_oc-business_proc
          AND variant            = gv_variant .

      SELECT *
        FROM zonta_oc_variant
        INTO CORRESPONDING FIELDS OF TABLE gt_variant
        WHERE domainv            = zonta_obj_oc-domainv
          AND business_proc      = zonta_obj_oc-business_proc
          AND variant            = gv_variant .
      IF sy-subrc NE 0.
        PERFORM fill_variant_fields.
      ENDIF.
    ENDIF.

    CREATE OBJECT lo_container_variant
      EXPORTING
        container_name = 'CONTAINER'.

    CREATE OBJECT lo_alv_variant
      EXPORTING
        i_parent = lo_container_variant.

* Prepare fieldcat for Variant
    PERFORM fieldcat_variant USING  gt_variant_alv[]
                          CHANGING  gt_fcat_variant.

* Layout options-------------------------------------------------------*
    CLEAR gs_alv_layout_t.
    MOVE abap_true TO: "gs_alv_layout_t-cwidth_opt,
                       gs_alv_layout_t-zebra,
                       gs_alv_layout_t-col_opt.
    gs_alv_layout_t-stylefname = 'CELLTAB'.

    gt_exclude_col[] = gt_exclude[].
    PERFORM exclude_options_alv.
    gs_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row .
    APPEND gs_exclude TO gt_exclude.

*    CREATE OBJECT lo_event_handler.
*    SET HANDLER lo_event_handler->on_user_command FOR lo_alv_variant.

    PERFORM prepare_celltab_variant.

*    SORT gt_variant_alv BY sequence levelv tabname.
    lo_alv_variant->set_table_for_first_display(
      EXPORTING
        i_structure_name = 'ZONST_VARIANT'
        is_layout        = gs_alv_layout_t
        it_toolbar_excluding = gt_exclude
      CHANGING
        it_outtab        = gt_variant_alv
        it_fieldcatalog  = gt_fcat_variant
    ).

    CALL METHOD lo_alv_variant->set_ready_for_input
      EXPORTING
        i_ready_for_input = 1.
    PERFORM register_alv_events_var CHANGING lo_alv_variant.

    IF gv_variant IS NOT INITIAL.
*      SELECT SINGLE variant_type, vdescription
*        INTO @DATA(ls_varia)
*      FROM zonta_oc_variant
*      WHERE domainv            = @gv_domainv
*        AND business_proc      = @gv_entity
*        AND variant            = @gv_variant .
      CLEAR ls_varia.
      SELECT SINGLE variant_type vdescription
        INTO ls_varia
      FROM zonta_oc_variant
      WHERE domainv            = gv_domainv
        AND business_proc      = gv_entity
        AND variant            = gv_variant .

      zonta_oc_variant-variant = gv_variant.
      zonta_oc_variant-variant_type = ls_varia-variant_type.
      zonta_oc_variant-description  = ls_varia-vdescription.
      IF ls_varia-variant_type = 'F'.
        gv_screenv = abap_true.
      ENDIF.
    ENDIF.

  ELSE.
    PERFORM get_changes_data USING lo_alv_variant.
    PERFORM prepare_celltab_variant.


    IF lines( gt_variant_alv ) = 0.
      SELECT *
        FROM zonta_oc_variant
        INTO CORRESPONDING FIELDS OF TABLE gt_variant_alv
        WHERE domainv            = zonta_obj_oc-domainv
          AND business_proc      = zonta_obj_oc-business_proc
          AND variant            = gv_variant .

      SELECT *
        FROM zonta_oc_variant
        INTO CORRESPONDING FIELDS OF TABLE gt_variant
        WHERE domainv            = zonta_obj_oc-domainv
          AND business_proc      = zonta_obj_oc-business_proc
          AND variant            = gv_variant .
      IF sy-subrc NE 0.
        PERFORM fill_variant_fields.

      ENDIF.
    ENDIF.


    SORT gt_variant_alv BY fieldtext.
    gv_option = co_change.
    PERFORM update_grid_fin USING lo_alv_variant.

  ENDIF.
ENDMODULE.                    "init_variant_tab OUTPUT
*&---------------------------------------------------------------------*
*& Module STATUS_0283 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0283 OUTPUT.
  SET PF-STATUS 'PF283'.

ENDMODULE.                    "status_0283 OUTPUT
*&---------------------------------------------------------------------*
*& Module STATUS_0284 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0284 OUTPUT.
  SET PF-STATUS 'PF284'.
ENDMODULE.                    "status_0284 OUTPUT
*&---------------------------------------------------------------------*
*& Module INIT_VARIANTATT OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE init_variantatt OUTPUT.

  DATA: ls_vardyn LIKE LINE OF gt_vardyn.

  FIELD-SYMBOLS: <fs_varatt> LIKE LINE OF gt_varatt.

  IF lines( gt_varatt ) = 0.
    IF lines( gt_vardyn ) = 0.
      SELECT *
        INTO TABLE gt_vardyn
        FROM zonta_oc_vardyn.
    ENDIF.
    LOOP AT gt_vardyn INTO ls_vardyn.
      APPEND INITIAL LINE TO gt_varatt ASSIGNING <fs_varatt>.
      <fs_varatt>-attribute = ls_vardyn-description.
      <fs_varatt>-variable  = ls_vardyn-sapvar.
    ENDLOOP.
  ENDIF.

  IF NOT lo_alv_varatt IS BOUND.


    CREATE OBJECT lo_container_varatt
      EXPORTING
        container_name = 'CONT_ATT'.

    CREATE OBJECT lo_alv_varatt
      EXPORTING
        i_parent = lo_container_varatt.

* Prepare fieldcat for Variant
    PERFORM fieldcat_varatt USING  gt_varatt[]
                          CHANGING  gt_fcat_varatt.

* Layout options-------------------------------------------------------*
    CLEAR gs_alv_layout_t.
    MOVE abap_true TO: "gs_alv_layout_t-cwidth_opt,
                       gs_alv_layout_t-zebra,
                       gs_alv_layout_t-col_opt.
    gs_alv_layout_t-stylefname = 'CELLTAB'.

    gt_exclude_col[] = gt_exclude[].
    PERFORM exclude_options_alv.
    gs_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row .
    APPEND gs_exclude TO gt_exclude.

*    CREATE OBJECT lo_event_handler.
*    SET HANDLER lo_event_handler->on_user_command FOR lo_alv_varatt.

    PERFORM prepare_celltab_varatt.

    SORT gt_varatt BY attribute.
    lo_alv_varatt->set_table_for_first_display(
      EXPORTING
*        i_structure_name = 'ZONST_va'
        is_layout        = gs_alv_layout_t
        it_toolbar_excluding = gt_exclude
      CHANGING
        it_outtab        = gt_varatt
        it_fieldcatalog  = gt_fcat_varatt
    ).

    CALL METHOD lo_alv_varatt->set_ready_for_input
      EXPORTING
        i_ready_for_input = 1.


    PERFORM register_alv_events_varatt CHANGING lo_alv_varatt.

  ELSE.
    PERFORM get_changes_data USING lo_alv_varatt.
    PERFORM prepare_celltab_varatt.


    PERFORM update_grid USING lo_alv_varatt.

  ENDIF.
ENDMODULE.                    "init_variantatt OUTPUT
*&---------------------------------------------------------------------*
*& Module STATUS_0285 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0285 OUTPUT.
  SET PF-STATUS 'PF0285'.
ENDMODULE.                    "status_0285 OUTPUT
*&---------------------------------------------------------------------*
*& Module MODIFY_SCREEN_285 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE modify_screen_285 OUTPUT.

  READ TABLE gt_vardyn INTO ls_vardyn WITH KEY  description = gs_variant_alv-vtext.
  IF sy-subrc = 0 AND ls_vardyn-window NE 'D'.
    LOOP AT SCREEN.
      IF screen-group1 = 'SEC'.
        screen-output = 0.
        screen-active = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
  IF zonta_oc_variant-sign1 IS INITIAL.
    zonta_oc_variant-sign1 = '+'.
  ENDIF.

  IF zonta_oc_variant-sign2 IS INITIAL.
    zonta_oc_variant-sign2 = '+'.
  ENDIF.

ENDMODULE.                    "modify_screen_285 OUTPUT
*&---------------------------------------------------------------------*
*& Module UPDATE_SCREEN_1000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE update_screen_1000 OUTPUT.
  LOOP AT SCREEN.
    IF gv_variant_old = abap_true.
      IF screen-group1 = 'NMO'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDMODULE.                    "update_screen_1000 OUTPUT

*&---------------------------------------------------------------------*
*& Module STATUS_0602 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0602 OUTPUT.
 SET PF-STATUS 'PF602'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0603 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0603 OUTPUT.
 SET PF-STATUS 'PF603'.
ENDMODULE.
