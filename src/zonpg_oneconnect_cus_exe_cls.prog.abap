*&---------------------------------------------------------------------*
*& Include          ZONPG_ONECONNECT_CUS_EXE_CLS
*&---------------------------------------------------------------------*
*//////////////////////////////////////////////////////////////////////*
*    handles only grid/toolbar events
*//////////////////////////////////////////////////////////////////////*
CLASS lcl_grid_event_receiver DEFINITION.

  PUBLIC SECTION.

    METHODS:
      handle_double_click FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING e_row e_column es_row_no,

      handle_user_command FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm ,

      data_changed FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING er_data_changed,

      handle_context_menu_request
        FOR EVENT context_menu_request
        OF cl_gui_alv_grid
        IMPORTING e_object  ,

      handle_toolbar      FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object e_interactive.

ENDCLASS.                    "lcl_grid_event_receiver DEFINITION



*----------------------------------------------------------------------*
*       CLASS lcl_grid_event_receiver_col DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_grid_event_receiver_col DEFINITION.

  PUBLIC SECTION.

    METHODS:
      handle_double_click FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING e_row e_column es_row_no,

      handle_user_command FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm ,

      data_changed FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING er_data_changed,

      handle_context_menu_request
        FOR EVENT context_menu_request
        OF cl_gui_alv_grid
        IMPORTING e_object  ,

      handle_toolbar      FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object e_interactive.


ENDCLASS.                    "lcl_grid_event_receiver_col DEFINITION
*//////////////////////////////////////////////////////////////////////
*---------------------------------------------------------------------*
*       CLASS lcl_treeobject DEFINITION
*---------------------------------------------------------------------*
*       Definition of Data Container                                  *
*---------------------------------------------------------------------*
CLASS lcl_drag_object DEFINITION.
  PUBLIC SECTION.
    DATA text TYPE STANDARD TABLE OF mtreesnode-text.
ENDCLASS.                    "lcl_drag_object DEFINITION

*//////////////////////////////////////////////////////////////////////
*---------------------------------------------------------------------*
*       CLASS lcl_application DEFINITION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*

CLASS lcl_application DEFINITION.

  PUBLIC SECTION.
    METHODS:
      handle_node_double_click
        FOR EVENT node_double_click
        OF cl_simple_tree_model
        IMPORTING node_key,
      handle_node_double_click_back
        FOR EVENT node_double_click
        OF cl_simple_tree_model
        IMPORTING node_key.
ENDCLASS.                    "lcl_application DEFINITION


*---------------------------------------------------------------------*
*       CLASS dragdrop_receiver DEFINITION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
CLASS lcl_dragdrop_receiver DEFINITION.
  PUBLIC SECTION.
    METHODS:
      flavor_select FOR EVENT on_drop_get_flavor OF cl_gui_simple_tree
        IMPORTING node_key flavors drag_drop_object,
      left_drag FOR EVENT on_drag_multiple OF cl_gui_simple_tree
        IMPORTING node_key_table drag_drop_object,
      right_drop FOR EVENT on_drop OF cl_gui_simple_tree
        IMPORTING node_key drag_drop_object,
      drop_complete FOR EVENT on_drop_complete_multiple OF
        cl_gui_simple_tree
        IMPORTING node_key_table drag_drop_object.

ENDCLASS.                    "lcl_dragdrop_receiver DEFINITION

************************************************************************

*
*CLASS lcl_application_f4 DEFINITION.
*
*  PUBLIC SECTION.
*
*    METHODS: on_f4 FOR EVENT onf4 OF cl_gui_alv_grid
*      IMPORTING e_fieldname
*                es_row_no
*                er_event_data
*                et_bad_cells
*                e_display.
*
**    methods: on_double_click for event double_click of cl_gui_alv_grid
**                    importing es_row_no.
*
*    METHODS: on_f4_dyn FOR EVENT onf4 OF cl_gui_alv_grid
*      IMPORTING e_fieldname
*                es_row_no
*                er_event_data
*                et_bad_cells
*                e_display.
*
*    METHODS: on_double_click FOR EVENT double_click OF cl_gui_alv_grid
*      IMPORTING es_row_no.
*
*    METHODS: on_double_click_dyn FOR EVENT double_click OF cl_gui_alv_grid
*      IMPORTING es_row_no.
*
*    METHODS:     hotspot_click        FOR EVENT hotspot_click
*      OF cl_gui_alv_grid
*      IMPORTING e_row_id
*                e_column_id
*                es_row_no.
*  PRIVATE SECTION.
*
*ENDCLASS.                    "lcl_application_f4 DEFINITION


*//////////////////////////////////////////////////////////////////////
CLASS lcl_grid_event_receiver IMPLEMENTATION.
*//////////////////////////////////////////////////////////////////////*

*----------------------------------------------------------------------*
  METHOD handle_double_click.

    DATA: ls_obj_oc TYPE zonta_obj_oc.

    CLEAR zonta_obj_oc.
    gv_authorization = abap_true.
    READ TABLE gt_obj_oc INTO ls_obj_oc INDEX e_row.
    IF sy-subrc = 0.
      PERFORM get_initial_data USING ls_obj_oc.
    ENDIF.

  ENDMETHOD.                    "handle_double_click
*----------------------------------------------------------------------*

  METHOD data_changed.
  ENDMETHOD.                    "data_changed

*----------------------------------------------------------------------*
  METHOD handle_user_command .

    DATA: l_sel_row TYPE i,
          ls_obj_oc TYPE zonta_obj_oc.

    g_grid0100->get_current_cell( IMPORTING e_row  = l_sel_row ).
    CLEAR zonta_obj_oc.
    gv_authorization = abap_true.
    READ TABLE gt_obj_oc INTO ls_obj_oc INDEX l_sel_row.
    IF sy-subrc = 0.
      PERFORM get_initial_data USING ls_obj_oc.
    ENDIF.

  ENDMETHOD.                    "handle_user_command
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
  METHOD handle_context_menu_request.
  ENDMETHOD.                    "handle_context_menu_request
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
  METHOD handle_toolbar.

  ENDMETHOD.                    "handle_toolbar
*----------------------------------------------------------------------*


ENDCLASS.                    "lcl_grid_event_receiver IMPLEMENTATION



*//////////////////////////////////////////////////////////////////////
CLASS lcl_grid_event_receiver_col IMPLEMENTATION.
*//////////////////////////////////////////////////////////////////////*

*----------------------------------------------------------------------*
  METHOD handle_double_click.
  ENDMETHOD.                    "handle_double_click
*----------------------------------------------------------------------*

  METHOD data_changed.
  ENDMETHOD.                    "data_changed

*----------------------------------------------------------------------*
  METHOD handle_user_command .
    CONSTANTS: c_999 TYPE i VALUE '9999'.
    DATA: lt_rows    TYPE lvc_t_row,
          ls_rows    LIKE LINE OF lt_rows,
          lv_delete  TYPE boolean,
          lv_message TYPE boolean.

    FIELD-SYMBOLS: <fs_col> LIKE LINE OF gt_columns_alv.

    IF e_ucomm = 'DELETE'.
      CALL METHOD lo_alv_columns->check_changed_data.
      CALL METHOD lo_alv_columns->get_selected_rows
        IMPORTING
          et_index_rows = lt_rows.
      lv_message = abap_false.
      LOOP AT lt_rows INTO ls_rows.
        READ TABLE gt_columns_alv ASSIGNING <fs_col> INDEX ls_rows-index.
        IF   sy-subrc = 0.
          lv_delete = abap_false.
          CASE <fs_col>-key_field.
            WHEN abap_false.
              IF <fs_col>-fldname NE c_mandt .
                lv_delete = abap_true.
              ELSE.
                lv_message = abap_true.
              ENDIF.
            WHEN abap_true.
              lv_message = abap_true.
          ENDCASE.

          IF lv_delete = abap_true.
            <fs_col>-positionf = c_999.
          ENDIF.
          CLEAR lv_delete.
        ENDIF.
      ENDLOOP.

      IF lv_message = abap_true.
        MESSAGE i025(zon_cl_oc).
      ENDIF.

      DELETE gt_columns_alv WHERE positionf = c_999.

      PERFORM update_grid USING lo_alv_columns.
      CALL METHOD cl_gui_cfw=>flush.
    ENDIF.

  ENDMETHOD.                    "handle_user_command
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
  METHOD handle_context_menu_request.
  ENDMETHOD.                    "handle_context_menu_request
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
  METHOD handle_toolbar.
*   by using event parameter E_OBJECT.
    DATA: ls_toolbar  TYPE stb_button.
*....................................................................

    CLEAR ls_toolbar.
    MOVE 3 TO ls_toolbar-butn_type.
    APPEND ls_toolbar TO e_object->mt_toolbar.
* append an icon to show booking table
    CLEAR ls_toolbar.
    MOVE 'DELETE' TO ls_toolbar-function.
    MOVE   icon_delete_row    TO ls_toolbar-icon.
    MOVE 'Delete' TO ls_toolbar-quickinfo.
*    MOVE 'Detail'(112) TO ls_toolbar-text.
    MOVE ' ' TO ls_toolbar-disabled.
    APPEND ls_toolbar TO e_object->mt_toolbar.
  ENDMETHOD.                    "handle_toolbar
*----------------------------------------------------------------------*

ENDCLASS.                    "lcl_grid_event_receiver_col IMPLEMENTATION



*----------------------------------------------------------------------*
*       CLASS lcl_event_handler DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_event_handler_var DEFINITION.


  PUBLIC SECTION.
    METHODS: on_user_command FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm.
    METHODS: on_data_changed FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING er_data_changed,
      on_data_changed_finished FOR EVENT data_changed_finished OF cl_gui_alv_grid.
    METHODS: on_f4 FOR EVENT onf4 OF cl_gui_alv_grid
      IMPORTING sender
                e_fieldname
                e_fieldvalue
                es_row_no
                er_event_data
                et_bad_cells
                e_display.

ENDCLASS.                    "lcl_event_handler DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_event_handler DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_event_handler_varatt DEFINITION.


  PUBLIC SECTION.
    METHODS: on_user_command FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm.
    METHODS: on_data_changed FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING er_data_changed,
      on_data_changed_finished FOR EVENT data_changed_finished OF cl_gui_alv_grid.
    METHODS: on_f4 FOR EVENT onf4 OF cl_gui_alv_grid
      IMPORTING sender
                e_fieldname
                e_fieldvalue
                es_row_no
                er_event_data
                et_bad_cells
                e_display.

ENDCLASS.                    "lcl_event_handler DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_event_handler DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION.


  PUBLIC SECTION.
    METHODS: on_user_command FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm.
    METHODS: on_data_changed FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING er_data_changed,
      on_data_changed_finished FOR EVENT data_changed_finished OF cl_gui_alv_grid.


ENDCLASS.                    "lcl_event_handler DEFINITION
*----------------------------------------------------------------------*
*       CLASS lcl_event_handler IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.
  METHOD on_user_command.
    CASE e_ucomm.
      WHEN '&IC1'. " Standard function code for a row double-click
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.                    "on_user_command

  METHOD on_data_changed.
    CONSTANTS: c_fiel  TYPE c LENGTH 4 VALUE 'FIEL',
               c_guion TYPE c LENGTH 1 VALUE '_',
               c_al    TYPE c LENGTH 1 VALUE '1'.

    DATA: ls_tables_alv  LIKE LINE OF gt_tables_alv,
          ls_columns_alv LIKE LINE OF gt_columns_alv,
          ls_columns     LIKE LINE OF gt_columns,
          lv_fieldname   TYPE string,
          lv_fldname     TYPE zonta_oc_columns-fldname,
          ls_row_c       LIKE LINE OF gt_columns_alv,
          lv_alias       TYPE zonta_oc_columns-alias_fldname,
          lv_tabname     TYPE tabname,
          lv_value       TYPE string,
          lv_index       TYPE i,
          lv_error       TYPE zabap_boolean.

    DATA: lt_matches  TYPE match_result_tab,
          lv_specials TYPE string.

    FIELD-SYMBOLS: <fs_row_c>    LIKE LINE OF gt_columns_alv,
                   <fs_row_t>    LIKE LINE OF gt_tables_alv,
                   <fs_field>    TYPE any,
                   <fs_tab>      LIKE LINE OF gt_tables,
                   <fs_auth_alv> LIKE LINE OF gt_auth_alv.

    " Process changes made by user
    DATA: ls_good_cells LIKE LINE OF er_data_changed->mt_good_cells,
          ls_del_cells  LIKE LINE OF er_data_changed->mt_deleted_rows,
          ls_row_t      LIKE LINE OF gt_tables_alv,
          lv_force      TYPE boolean_flg,
          lv_message15  TYPE boolean_flg.


    lv_message15 = abap_false.
    IF er_data_changed IS NOT INITIAL.
*      IF line_exists( er_data_changed->mt_fieldcatalog[ tabname    = c_tables ] ).
      READ TABLE er_data_changed->mt_fieldcatalog TRANSPORTING NO FIELDS WITH KEY tabname = c_tables.
      IF sy-subrc = 0.
        LOOP AT er_data_changed->mt_good_cells INTO ls_good_cells.
          lv_fieldname = ls_good_cells-fieldname.
          lv_value = ls_good_cells-value.
          lv_index = ls_good_cells-row_id.

          READ TABLE gt_tables_alv INDEX lv_index INTO ls_row_t.
          IF sy-subrc = 0.
            lv_tabname = ls_row_t-tabname.
            LOOP AT gt_tables_alv ASSIGNING <fs_row_t> WHERE tabname = lv_tabname.
              ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_row_t> TO <fs_field>.
              IF sy-subrc = 0.
                IF lv_tabname = lv_value.
                  lv_value = |{ lv_value }{ c_guion }{ c_al }|.
                ENDIF.
                <fs_field> = lv_value.
              ENDIF.
              READ TABLE gt_ex_rel INTO gs_ex_rel WITH KEY tabname = lv_tabname.
              IF sy-subrc = 0.
                IF gs_ex_rel-alias_tabname NE <fs_row_t>-alias_tabname.
                  CLEAR <fs_row_t>-icon_id.
                  DELETE TABLE gt_ex_rel FROM gs_ex_rel.
                ENDIF.
              ENDIF.
            ENDLOOP.
          ENDIF.

        ENDLOOP.

      ELSE.
* Updating auth fields
        READ TABLE er_data_changed->mt_fieldcatalog TRANSPORTING NO FIELDS WITH KEY fieldname = c_fiel.
        IF sy-subrc = 0.
          LOOP AT er_data_changed->mt_good_cells INTO ls_good_cells.
            READ TABLE gt_auth_alv ASSIGNING <fs_auth_alv> INDEX ls_good_cells-row_id.
            IF sy-subrc = 0.
              <fs_auth_alv>-val = ls_good_cells-value.
            ENDIF.
          ENDLOOP.
* Change on columns
        ELSE.
          SORT gt_ex_col BY fldname.
          SORT gt_columns BY tabname fldname.
          LOOP AT er_data_changed->mt_good_cells INTO ls_good_cells.
            CLEAR lv_error.
            lv_force = abap_false.

            lv_fieldname = ls_good_cells-fieldname.
            lv_value = ls_good_cells-value.
            TRANSLATE lv_value TO LOWER CASE.
            lv_index = ls_good_cells-row_id.

            READ TABLE gt_columns_alv INDEX lv_index INTO ls_row_c.
            IF sy-subrc = 0.
              lv_fldname = ls_row_c-fldname.
              lv_tabname = ls_row_c-tabname.

              CASE lv_fieldname.
                WHEN 'ALIAS_FLDNAME'.
* Begin of DB 06/11
                  " Allow A-Z, a-z, 0-9, space, and underscore _
*                    FIND ALL OCCURRENCES OF REGEX `[^A-Za-z0-9 _]` IN lv_value  RESULTS lt_matches.
                  REPLACE ALL OCCURRENCES OF REGEX `[^A-Za-z0-9 _]` IN lv_value WITH ''.
                  IF sy-subrc = 0.
                    lv_force = abap_true.
                  ENDIF.
* End of DB 06/11

                  READ TABLE gt_ex_col INTO gs_ex_col WITH KEY fldname = lv_fldname.
                  IF sy-subrc = 0.
*                    MESSAGE i019(zon_cl_oc) WITH lv_fldname. "lv_value.  "--DB 06/11
                    LOOP AT gt_columns_alv ASSIGNING <fs_row_c> WHERE tabname = lv_tabname
                                                                  AND fldname = lv_fldname.
                      lv_alias = <fs_row_c>-alias_fldname.
                      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_row_c> TO <fs_field>.
                      IF sy-subrc = 0.
                        <fs_field> = lv_alias.
                      ENDIF.
                    ENDLOOP.

                  ELSE.
                    LOOP AT gt_columns_alv ASSIGNING <fs_row_c> WHERE alias_fldname = lv_value AND fldname NE lv_fldname.
                      MESSAGE i020(zon_cl_oc) WITH lv_value. "<ls_row_c>-alias_fldname.
                      lv_error = abap_true.
                      EXIT.
                    ENDLOOP.
                    IF lv_error = abap_false.
                      LOOP AT gt_columns_alv ASSIGNING <fs_row_c> WHERE fldname = lv_fldname.
                        ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_row_c> TO <fs_field>.
                        IF sy-subrc = 0.
                          <fs_field> = lv_value.
                        ENDIF.
                      ENDLOOP.
                    ELSE.
                      LOOP AT gt_columns_alv ASSIGNING <fs_row_c> WHERE tabname = lv_tabname
                                                                   AND fldname = lv_fldname.
                        lv_alias = <fs_row_c>-alias_fldname.
                        ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_row_c> TO <fs_field>.
                        IF sy-subrc = 0.
                          <fs_field> = lv_alias.
                        ENDIF.
                      ENDLOOP.

                    ENDIF.
                  ENDIF.
                WHEN OTHERS.
                  LOOP AT gt_columns_alv ASSIGNING <fs_row_c> WHERE tabname = lv_tabname AND fldname = lv_fldname.
                    ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_row_c> TO <fs_field>.
                    IF sy-subrc = 0.
                      <fs_field> = lv_value.
                    ENDIF.
                  ENDLOOP.
              ENDCASE.

            ENDIF.

            IF lv_force = abap_true.
              CALL METHOD er_data_changed->modify_cell
                EXPORTING
                  i_row_id    = ls_good_cells-row_id
                  i_fieldname = ls_good_cells-fieldname
                  i_value     = lv_value.
              lv_message15 = abap_true.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.


      IF lv_message15 = abap_true.
        MESSAGE i015(zon_cl_oc).
      ENDIF.

      CLEAR gt_tables[].
      LOOP AT gt_tables_alv ASSIGNING <fs_row_t>.
        APPEND INITIAL LINE TO gt_tables ASSIGNING <fs_tab>.
        MOVE-CORRESPONDING <fs_row_t> TO <fs_tab>.
      ENDLOOP.

      PERFORM prepare_celltab_columns.
      PERFORM update_grid USING lo_alv_tables.
      PERFORM update_grid USING lo_alv_columns.
    ENDIF.
  ENDMETHOD.                    "on_data_changed

  METHOD on_data_changed_finished.

    PERFORM check_alias_tables.
    PERFORM update_grid_fin USING lo_alv_tables.
    PERFORM update_grid_fin USING lo_alv_columns.
  ENDMETHOD.                    "on_data_changed_finished

ENDCLASS.                    "lcl_event_handler IMPLEMENTATION


*----------------------------------------------------------------------*
*       CLASS lcl_event_handler_var IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_event_handler_var IMPLEMENTATION.
  METHOD on_user_command.
    CASE e_ucomm.
      WHEN '&IC1'. " Standard function code for a row double-click
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.                    "on_user_command

  METHOD on_data_changed.
    " Process changes made by user
    DATA: ls_good_cells LIKE LINE OF er_data_changed->mt_good_cells,
          ls_del_cells  LIKE LINE OF er_data_changed->mt_deleted_rows,
          ls_row_t      LIKE LINE OF gt_variant_alv.

    DATA: lv_fieldname TYPE string,
          lv_fldname   TYPE zonta_oc_columns-fldname,
          ls_row_c     LIKE LINE OF gt_columns_alv,
          lv_alias     TYPE zonta_oc_columns-alias_fldname,
          lv_tabname   TYPE tabname,
          lv_value     TYPE string,
          lv_index     TYPE i,
          lv_error     TYPE zabap_boolean,
          lv_exist     TYPE zabap_boolean.

    FIELD-SYMBOLS: <fs_var> LIKE LINE OF gt_variant_alv.

    IF er_data_changed IS NOT INITIAL.
*      IF line_exists( er_data_changed->mt_fieldcatalog[ tabname    = c_tables ] ).
*      READ TABLE er_data_changed->mt_fieldcatalog TRANSPORTING NO FIELDS WITH KEY tabname = c_tables.
*      IF sy-subrc = 0.
      LOOP AT er_data_changed->mt_good_cells INTO ls_good_cells.
        lv_fieldname = ls_good_cells-fieldname.
        lv_value = ls_good_cells-value.
        lv_index = ls_good_cells-row_id.
        gv_index_v = lv_index.

        READ TABLE gt_variant_alv INDEX lv_index ASSIGNING <fs_var>.
        IF sy-subrc = 0.
          IF lv_fieldname = 'VTYPE'.
            <fs_var>-vtype = lv_value.
          ELSEIF lv_fieldname = 'VTEXT'.
            IF lv_value IS NOT INITIAL.
              PERFORM validate_tvarvc USING lv_value CHANGING lv_exist.
              IF lv_exist = abap_true.
                <fs_var>-vtext = lv_value.
              ELSE.
                MESSAGE i041(zon_cl_oc) DISPLAY LIKE 'I'.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
*      ENDIF.
    ENDIF.

    PERFORM update_grid USING lo_alv_variant.
  ENDMETHOD.                    "on_data_changed

  METHOD on_data_changed_finished.
    gv_option = co_change.
    PERFORM update_grid_fin USING lo_alv_variant.
  ENDMETHOD.                    "on_data_changed_finished

  METHOD on_f4.

    CONSTANTS: c_date TYPE c VALUE 'D'.
    DATA: ls_f4 TYPE ddshretval,
          lt_f4 TYPE TABLE OF ddshretval.

    DATA: lt_fcat      TYPE lvc_t_fcat,
          ls_fieldcat  TYPE lvc_s_fcat,
          lv_tabname   TYPE dd03v-tabname,
          lv_fieldname TYPE dd03v-fieldname,
          lv_help_valu TYPE help_info-fldvalue,
          lt_bad_cell  TYPE lvc_t_modi,
          lv_dat       TYPE REF TO data.

    DATA: lt_fieldinfo TYPE STANDARD TABLE OF dfies,
          ls_fieldinfo TYPE dfies.

    FIELD-SYMBOLS: <fs_field_value> TYPE any,
                   <fs_dat>         TYPE any.

    FIELD-SYMBOLS: <itab> TYPE lvc_t_modi.
    DATA: ls_modi TYPE lvc_s_modi.

    DATA ls_variant_alv TYPE st_variant_alv.

    CALL METHOD sender->get_frontend_fieldcatalog
      IMPORTING
        et_fieldcatalog = lt_fcat.

*     READ TABLE gt_variant_alv INDEX es_row_no-row_id INTO DATA(ls_variant_alv).
    READ TABLE gt_variant_alv INDEX es_row_no-row_id INTO ls_variant_alv.
    CREATE DATA lv_dat LIKE LINE OF gt_variant_alv.
    ASSIGN lv_dat->* TO <fs_dat>.
    <fs_dat> = ls_variant_alv.

    READ TABLE lt_fcat
       WITH KEY fieldname = e_fieldname INTO ls_fieldcat.
    MOVE ls_fieldcat-ref_table TO lv_tabname.
    MOVE ls_fieldcat-fieldname TO lv_fieldname.
    ASSIGN COMPONENT ls_fieldcat-fieldname
                   OF STRUCTURE ls_variant_alv
                   TO <fs_field_value>.
    IF <fs_field_value> IS ASSIGNED.
      WRITE <fs_field_value> TO lv_help_valu.
    ENDIF.

    gv_index_v = es_row_no-row_id.
    PERFORM f4_set IN PROGRAM bcalv_f4
                 USING sender
                       lt_fcat
                       lt_bad_cell
                       es_row_no-row_id
                       <fs_dat>.

    IF lv_fieldname = 'VTEXT'.
      lv_fieldname = 'VTYPE'.
      IF ls_variant_alv-vtype IS NOT INITIAL
      AND ls_variant_alv-vtype NE 'T'.
        CALL SCREEN 284 STARTING AT 20 5
                    ENDING AT 60 50.
        er_event_data->m_event_handled = abap_true.
        PERFORM update_grid USING lo_alv_variant.
      ENDIF.
*      er_event_data->m_value         = ls_return-fieldval.

* VTYPE
    ELSE.
      DATA ls_fieldtab TYPE rsdsfields.
*      READ TABLE gt_fieldtab INTO data(ls_fieldtab) INDEX es_row_no-row_id.
      READ TABLE gt_fieldtab INTO ls_fieldtab INDEX es_row_no-row_id.
      IF sy-subrc = 0.
        CALL FUNCTION 'DDIF_FIELDINFO_GET'
          EXPORTING
            tabname        = ls_fieldtab-tablename
            fieldname      = ls_fieldtab-fieldname
            all_types      = 'X'
          TABLES
            dfies_tab      = lt_fieldinfo
          EXCEPTIONS
            not_found      = 1
            internal_error = 2
            OTHERS         = 3.

        READ TABLE lt_fieldinfo INTO ls_fieldinfo INDEX 1.
        IF sy-subrc = 0 AND ls_fieldinfo-inttype = c_date.
          CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
            EXPORTING
              tabname          = 'ZONST_OC_VAR'
              fieldname        = 'SVAR'
              display          = e_display
              callback_program = 'BCALV_F4'
              value            = lv_help_valu
              callback_form    = 'F4'
            TABLES
              return_tab       = lt_f4.
        ELSE.
          CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
            EXPORTING
              tabname          = 'ZONST_OC_VAR'
              fieldname        = 'SVARS'
              display          = e_display
              callback_program = 'BCALV_F4'
              value            = lv_help_valu
              callback_form    = 'F4'
            TABLES
              return_tab       = lt_f4.
        ENDIF.

        ASSIGN er_event_data->m_data->* TO <itab>.

        READ TABLE lt_f4 INTO ls_f4 INDEX 1.
        IF NOT ls_f4 IS INITIAL.
          ls_modi-row_id    = es_row_no-row_id.
          ls_modi-fieldname = 'VTYPE'.
          ls_modi-value     = ls_f4-fieldval.
          APPEND ls_modi TO <itab>.
          er_event_data->m_event_handled = abap_true.
*          er_event_data->m_value         = ls_f4-fieldval.
          lv_fieldname = 'VTYPE'.

          er_event_data->m_event_handled = abap_true.
*          er_event_data->m_value         = ls_f4-fieldval.
          FIELD-SYMBOLS: <fs_variant> TYPE st_variant_alv.
*          READ TABLE gt_variant_alv INDEX es_row_no-row_id ASSIGNING field-symbol(<fs_variant>).
          READ TABLE gt_variant_alv INDEX es_row_no-row_id ASSIGNING <fs_variant>.
          IF sy-subrc = 0.
            <fs_variant>-vtype = ls_f4-fieldval.
          ENDIF.

        ENDIF.
      ENDIF.
    ENDIF.


  ENDMETHOD.                    "on_f4
ENDCLASS.                    "lcl_event_handler_Var IMPLEMENTATION


*----------------------------------------------------------------------*
*       CLASS lcl_event_handler_varatt IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_event_handler_varatt IMPLEMENTATION.
  METHOD on_user_command.
    CASE e_ucomm.
      WHEN '&IC1'. " Standard function code for a row double-click
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.                    "on_user_command

  METHOD on_data_changed.
    " Process changes made by user
    DATA: ls_good_cells LIKE LINE OF er_data_changed->mt_good_cells,
          ls_del_cells  LIKE LINE OF er_data_changed->mt_deleted_rows,
          ls_row_t      LIKE LINE OF gt_varatt.

    DATA: lv_fieldname TYPE string,
          lv_fldname   TYPE zonta_oc_columns-fldname,
          ls_row_c     LIKE LINE OF gt_varatt,
          lv_tabname   TYPE tabname,
          lv_value     TYPE string,
          lv_index     TYPE i,
          lv_error     TYPE zabap_boolean.

    FIELD-SYMBOLS: <fs_var>     LIKE LINE OF gt_varatt,
                   <fs_variant> LIKE LINE OF gt_variant_alv.

    IF er_data_changed IS NOT INITIAL.
      LOOP AT er_data_changed->mt_good_cells INTO ls_good_cells.
        lv_fieldname = ls_good_cells-fieldname.
        lv_value = ls_good_cells-value.
        lv_index = ls_good_cells-row_id.

        IF lv_fieldname = 'SIGN'.
          FIELD-SYMBOLS: <fs_varatt> TYPE st_varatt.
*          LOOP AT gt_varatt ASSIGNING field-symbol(<fs_varatt>).
          LOOP AT gt_varatt ASSIGNING <fs_varatt>.
            CLEAR: <fs_varatt>-sign,
                   <fs_varatt>-option.
          ENDLOOP.
        ENDIF.

        READ TABLE gt_varatt INDEX lv_index ASSIGNING <fs_var>.
        IF sy-subrc = 0.
          IF lv_fieldname = 'SIGN'.
            <fs_var>-sign = lv_value.
          ELSEIF lv_fieldname = 'OPTION'.
            <fs_var>-option = lv_value.
          ENDIF.
        ENDIF.

      ENDLOOP.


      IF <fs_var> IS ASSIGNED.
*        IF lv_fieldname = 'SIGN'.
*          LOOP AT gt_variant_alv ASSIGNING <fs_variant>.
*            CLEAR: <fs_variant>-option,
*                   <fs_variant>-sign.
*          ENDLOOP.
*        ENDIF.
        READ TABLE gt_variant_alv INDEX gv_index_v ASSIGNING <fs_variant>.
        IF sy-subrc = 0.
          <fs_variant>-option = <fs_var>-option.
          <fs_variant>-sign   = <fs_var>-sign.
        ENDIF.
      ENDIF.
    ENDIF.

    PERFORM update_grid USING lo_alv_varatt.
    PERFORM update_grid USING lo_alv_variant.
  ENDMETHOD.                    "on_data_changed

  METHOD on_data_changed_finished.
    gv_option = co_change.
    PERFORM update_grid_fin USING lo_alv_varatt.
  ENDMETHOD.                    "on_data_changed_finished

  METHOD on_f4.

    CONSTANTS: c_date TYPE c VALUE 'D'.
    DATA: ls_f4 TYPE ddshretval,
          lt_f4 TYPE TABLE OF ddshretval.

    DATA: lt_fcat      TYPE lvc_t_fcat,
          ls_fieldcat  TYPE lvc_s_fcat,
          lv_tabname   TYPE dd03v-tabname,
          lv_fieldname TYPE dd03v-fieldname,
          lv_help_valu TYPE help_info-fldvalue,
          lt_bad_cell  TYPE lvc_t_modi,
          lv_dat       TYPE REF TO data.

    DATA: lt_fieldinfo TYPE STANDARD TABLE OF dfies,
          ls_fieldinfo TYPE dfies.

    FIELD-SYMBOLS: <fs_field_value> TYPE any,
                   <fs_dat>         TYPE any,
                   <fs_var>         LIKE LINE OF gt_variant_alv.

    FIELD-SYMBOLS: <itab> TYPE lvc_t_modi.
    DATA: ls_modi TYPE lvc_s_modi.

    CALL METHOD sender->get_frontend_fieldcatalog
      IMPORTING
        et_fieldcatalog = lt_fcat.

*    READ TABLE gt_variant_alv INDEX es_row_no-row_id INTO gs_variant_alv.
    READ TABLE gt_varatt INDEX es_row_no-row_id INTO gs_varatt.
    CREATE DATA lv_dat LIKE LINE OF gt_varatt.
    ASSIGN lv_dat->* TO <fs_dat>.
    <fs_dat> = gs_varatt..

    READ TABLE lt_fcat
       WITH KEY fieldname = e_fieldname INTO ls_fieldcat.
    MOVE ls_fieldcat-ref_table TO lv_tabname.
    MOVE ls_fieldcat-fieldname TO lv_fieldname.
    ASSIGN COMPONENT ls_fieldcat-fieldname
                   OF STRUCTURE gs_varatt
                   TO <fs_field_value>.
    IF <fs_field_value> IS ASSIGNED.
      WRITE <fs_field_value> TO lv_help_valu.
    ENDIF.

    PERFORM f4_set IN PROGRAM bcalv_f4
                 USING sender
                       lt_fcat
                       lt_bad_cell
                       es_row_no-row_id
                       <fs_dat>.

    IF lv_fieldname = 'SIGN'.

      CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
        EXPORTING
          tabname          = 'ZONST_OC_VAR'
          fieldname        = 'SIGN'
          display          = e_display
          callback_program = 'BCALV_F4'
          value            = lv_help_valu
          callback_form    = 'F4'
        TABLES
          return_tab       = lt_f4.

      ASSIGN er_event_data->m_data->* TO <itab>.

      READ TABLE lt_f4 INTO ls_f4 INDEX 1.
      IF NOT ls_f4 IS INITIAL.
*        PERFORM clear_varatt.

        ls_modi-row_id    = es_row_no-row_id.
        ls_modi-fieldname = 'SIGN'.
        ls_modi-value     = ls_f4-fieldval.
        APPEND ls_modi TO <itab>.
        gs_variant_alv-sign = ls_f4-fieldval.
        gs_variant_alv-vtext = gs_varatt-attribute.

        READ TABLE gt_variant_alv ASSIGNING <fs_var> INDEX gv_index_v.
        IF sy-subrc = 0.
          DATA ls_vardyn TYPE zonta_oc_vardyn.
*          <fs_var>-option = gs_variant_alv-option.
          <fs_var>-sign = gs_variant_alv-sign.
          <fs_var>-vtext = gs_variant_alv-vtext.
*          READ TABLE gt_vardyn INTO data(ls_vardyn) WITH KEY description = <fs_var>-vtext.
          READ TABLE gt_vardyn INTO ls_vardyn WITH KEY description = <fs_var>-vtext.
          IF sy-subrc = 0.
            <fs_var>-sapvar = ls_vardyn-sapvar.
          ENDIF.
        ENDIF.

        er_event_data->m_event_handled = abap_true.
*        er_event_data->m_value         = ls_f4-fieldval.

      ENDIF.
*OPTI
    ELSE.


      CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
        EXPORTING
          tabname          = 'ZONST_OC_VAR'
          fieldname        = 'OPTI'
          display          = e_display
          callback_program = 'BCALV_F4'
          value            = lv_help_valu
          callback_form    = 'F4'
        TABLES
          return_tab       = lt_f4.

      ASSIGN er_event_data->m_data->* TO <itab>.

      READ TABLE lt_f4 INTO ls_f4 INDEX 1.
      IF NOT ls_f4 IS INITIAL.
*        PERFORM clear_varatt.

        ls_modi-row_id    = es_row_no-row_id.
        ls_modi-fieldname = 'OPTION'.
        ls_modi-value     = ls_f4-fieldval.
        APPEND ls_modi TO <itab>.
        gs_variant_alv-option = ls_f4-fieldval.
        gs_variant_alv-vtext = gs_varatt-attribute.

        READ TABLE gt_variant_alv ASSIGNING <fs_var> INDEX gv_index_v.
        IF sy-subrc = 0.
          <fs_var>-option = gs_variant_alv-option.
*          <fs_var>-sign = gs_variant_alv-sign.
          <fs_var>-vtext = gs_variant_alv-vtext.
          READ TABLE gt_vardyn INTO ls_vardyn WITH KEY description = <fs_var>-vtext.
          IF sy-subrc = 0.
            <fs_var>-sapvar = ls_vardyn-sapvar.
          ENDIF.
        ENDIF.

        er_event_data->m_event_handled = abap_true.
*        er_event_data->m_value         = ls_return-fieldval.
      ENDIF.

    ENDIF.
    er_event_data->m_event_handled = 'X'.
*    perform update_grid using lo_alv_variant.
  ENDMETHOD.                    "on_f4
ENDCLASS.                    "lcl_event_handler_Varatt IMPLEMENTATION


*----------------------------------------------------------------------*
*       CLASS lcl_event_handler_any DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_event_handler_any DEFINITION.


  PUBLIC SECTION.
    METHODS: on_user_command FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm.
    METHODS: on_data_changed FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING er_data_changed.


ENDCLASS.                    "lcl_event_handler_any DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_event_handler_any IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_event_handler_any IMPLEMENTATION.
  METHOD on_user_command.
    CASE e_ucomm.
      WHEN '&IC1'. " Standard function code for a row double-click
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.                    "on_user_command

  METHOD on_data_changed.
    CONSTANTS: c_fiel  TYPE c LENGTH 4 VALUE 'FIEL'.

    DATA:
      lv_fieldname TYPE string,
      lv_fldname   TYPE zonta_oc_columns-fldname,
      lv_value     TYPE string,
      lv_index     TYPE i,
      lv_error     TYPE zabap_boolean.
*
    FIELD-SYMBOLS: <fs_row_c>    LIKE LINE OF gt_columns_alv,
                   <fs_row_t>    LIKE LINE OF gt_tables_alv,
                   <fs_field>    TYPE any,
                   <fs_tab>      LIKE LINE OF gt_tables,
                   <fs_auth_alv> LIKE LINE OF gt_auth_alv.

    " Process changes made by user
    DATA: ls_good_cells LIKE LINE OF er_data_changed->mt_good_cells,
          ls_del_cells  LIKE LINE OF er_data_changed->mt_deleted_rows,
          ls_row_t      LIKE LINE OF gt_tables_alv.


    IF er_data_changed IS NOT INITIAL.
*      IF line_exists( er_data_changed->mt_fieldcatalog[ tabname    = c_tables ] ).
*      READ TABLE er_data_changed->mt_fieldcatalog TRANSPORTING NO FIELDS WITH KEY tabname = c_tables.
*      IF sy-subrc = 0.
*        LOOP AT er_data_changed->mt_good_cells INTO ls_good_cells.
*          lv_fieldname = ls_good_cells-fieldname.
*          lv_value = ls_good_cells-value.
*          lv_index = ls_good_cells-row_id.
*        ENDLOOP.
*      ENDIF.
*      PERFORM update_grid USING lo_alv_col_any.

    ENDIF.
  ENDMETHOD.                    "on_data_changed
ENDCLASS.                    "lcl_event_handler_any IMPLEMENTATION

*---------------------------------------------------------------------*
*       CLASS DRAGDROP_RECEIVER IMPLEMENTATION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
CLASS lcl_dragdrop_receiver IMPLEMENTATION.
  METHOD flavor_select.
    ##NO_TEXT
    IF node_key <> 'Root'.
      ##NO_TEXT
      SEARCH flavors FOR 'Tree_move'.
      IF sy-subrc = 0.
        CALL METHOD drag_drop_object->set_flavor
            ##NO_TEXT

          EXPORTING
            newflavor = 'Tree_move'.
      ELSE.
        CALL METHOD drag_drop_object->abort.
      ENDIF.
    ELSE.
      ##NO_TEXT
      SEARCH flavors FOR 'Tree_copy'.
      IF sy-subrc = 0.
        CALL METHOD drag_drop_object->set_flavor
            ##NO_TEXT

          EXPORTING
            newflavor = 'Tree_copy'.
      ELSE.
        CALL METHOD drag_drop_object->abort.
      ENDIF.
    ENDIF.

  ENDMETHOD.                    "flavor_select
  METHOD left_drag.
    DATA drag_object TYPE REF TO lcl_drag_object.
    DATA node_key TYPE node_str-node_key.
    CREATE OBJECT drag_object.
    LOOP AT node_key_table INTO node_key.
      READ TABLE node_itab_left WITH KEY node_key = node_key
                           INTO node.

      APPEND node-text TO drag_object->text.
    ENDLOOP.
    drag_drop_object->object = drag_object.
  ENDMETHOD.                    "left_drag

  METHOD right_drop.
    DATA drag_object TYPE REF TO lcl_drag_object.
    DATA new_nodes LIKE node_itab_right. "TYPE TREEMSNOTA
    DATA new_node TYPE treemsnodt. "node_str.
    CATCH SYSTEM-EXCEPTIONS move_cast_error = 1.
      drag_object ?= drag_drop_object->object.
    ENDCATCH.
    IF sy-subrc = 1.
      CALL METHOD drag_drop_object->abort.
      EXIT.
    ENDIF.
    LOOP AT drag_object->text INTO new_node-text.
      PERFORM add_node CHANGING node_key new_node new_nodes
                                node_itab_left.
    ENDLOOP.
    CALL METHOD tree_right->add_nodes
      EXPORTING
        node_table = new_nodes.
  ENDMETHOD.                    "right_drop

  METHOD drop_complete.

  ENDMETHOD.                    "drop_complete
ENDCLASS.                    "lcl_dragdrop_receiver IMPLEMENTATION



*---------------------------------------------------------------------*
*       CLASS LCL_APPLICATION IMPLEMENTATION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
CLASS lcl_application IMPLEMENTATION.

  METHOD handle_node_double_click.
    DATA new_nodes LIKE node_itab_right.
    DATA new_node TYPE treemsnodt.
    DATA: ls_node_left  LIKE LINE OF node_itab_left,
          ls_node_right LIKE LINE OF node_itab_right.

    g_event = 'NODE_DOUBLE_CLICK'.
    g_node_key = node_key.

*new_node-text = node_key.
    READ TABLE node_itab_left INTO ls_node_left WITH KEY node_key = node_key.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING ls_node_left TO new_node.
    ENDIF.

    READ TABLE node_itab_right INTO ls_node_right WITH KEY node_key = node_key.
    IF sy-subrc NE 0.
      PERFORM add_node CHANGING node_key new_node new_nodes
                                node_itab_left.
      CALL METHOD tree_right->add_nodes
        EXPORTING
          node_table = new_nodes.
    ENDIF.
  ENDMETHOD.                    "handle_node_double_click


  METHOD handle_node_double_click_back.

    DATA: event  TYPE cntl_simple_event,
          events TYPE cntl_simple_events.

    DATA del_nodes LIKE node_itab_right.
    DATA del_node TYPE treemsnodt.
    DATA: ls_node_right LIKE LINE OF node_itab_right.

    g_event = 'NODE_DOUBLE_CLICK'.
    g_node_key = node_key.

*new_node-text = node_key.
    READ TABLE node_itab_right INTO ls_node_right WITH KEY node_key = node_key.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING ls_node_right TO del_node.
    ENDIF.

    PERFORM remove_node CHANGING node_key del_node del_nodes
                              deleted_node_itab.

    CLEAR tree_left.
    left->free( ).
    CLEAR left.
    CLEAR tree_right.
    right->free( ).
    CLEAR right.
    container->free( ).
    CLEAR container.


  ENDMETHOD.                    "handle_node_double_click_back

ENDCLASS.                    "lcl_application IMPLEMENTATION


*----------------------------------------------------------------------*
*       CLASS lcl_output_list DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_output_list DEFINITION.

  PUBLIC SECTION.
    METHODS write IMPORTING i_line TYPE string."clike.
    METHODS display.
    METHODS write_tab IMPORTING i_tab TYPE st_tables_alv.

  PRIVATE SECTION.
    DATA: BEGIN OF t_output,
            line TYPE string,
          END OF t_output.
    DATA output LIKE STANDARD TABLE OF t_output.

ENDCLASS.                    "lcl_output_list DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_output_list IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_output_list IMPLEMENTATION.

  METHOD write.
*    APPEND VALUE #( line = i_line ) TO output.
    DATA: line LIKE LINE OF output.
    line-line = i_line.
    APPEND line TO output.
  ENDMETHOD.                    "write


  METHOD write_tab.

    CONSTANTS: c_star TYPE c VALUE '*'.

    DATA: lv_line TYPE string.
    DATA: line LIKE LINE OF output.
    DATA: tab TYPE c VALUE cl_abap_char_utilities=>horizontal_tab.

    CONCATENATE c_star i_tab-alias_tabname INTO lv_line SEPARATED BY space.
    line-line = lv_line.
    APPEND line TO output.
*    APPEND VALUE #( line = lv_line ) TO output.
  ENDMETHOD.                    "write_tab

  METHOD display.

    DATA: alv    TYPE REF TO cl_salv_table,
          bummer TYPE REF TO cx_salv_msg.

    TRY.
        cl_salv_table=>factory( IMPORTING r_salv_table = alv
                                CHANGING  t_table      = output ).
      CATCH cx_salv_msg INTO bummer.
        MESSAGE bummer TYPE 'E'.
    ENDTRY.
    alv->display( ).
  ENDMETHOD.                    "display

ENDCLASS.                    "lcl_output_list IMPLEMENTATION

*
*CLASS lcl_application_f4 IMPLEMENTATION.
*  METHOD on_f4.
*
** Save event parameter as global attributes of this class
** (maybe solved differently if you use a function module!)
*
*    IF e_fieldname EQ 'VTEXT'.
*      FIELD-SYMBOLS: <l_attr_outtab> LIKE LINE OF gt_variant_alv.
*      READ TABLE gt_variant_alv ASSIGNING <l_attr_outtab> INDEX es_row_no-row_id.
*      IF sy-subrc = 0 AND <l_attr_outtab>-varis IS INITIAL.
*
*        MESSAGE s122(sldbv) DISPLAY LIKE 'W'.
*        er_event_data->m_event_handled = 'X'.
*        RETURN.
*      ENDIF.
*    ENDIF.
*
*    f4_params-c_fieldname = e_fieldname.
*    f4_params-cs_row_no = es_row_no.
*    f4_params-cr_event_data = er_event_data.
*    f4_params-ct_bad_cells = et_bad_cells.
*    f4_params-c_display = e_display.
*
*    FIELD-SYMBOLS:
*       <l_save_attr_outtab>     LIKE gt_variant_alv[].
*
*    ASSIGN ('SAVE_ATTR_OUTTAB') TO <l_save_attr_outtab>.
*    IF sy-subrc = 0.
*      <l_save_attr_outtab> = gt_variant_alv[].
*    ENDIF.
*
*    CALL SCREEN 283 STARTING AT 10 10.
*    IF er_event_data IS NOT INITIAL.
*      er_event_data->m_event_handled = 'X'.
*    ENDIF.
**    set screen 0. leave screen.
*  ENDMETHOD.                                                "on_f4
**---------------------------------------------------------------------
*  METHOD on_double_click.
*    CLEAR save_okcode.
**     perform get_selected_f4 using es_row_no-row_id.  "OJO
*  ENDMETHOD.                    "on_double_click
**---------------------------------------------------------------------
*  METHOD on_double_click_dyn.
**     perform get_selected_f4_dyn using es_row_no-row_id.  "OJO
*  ENDMETHOD.                    "on_double_click_dyn
**---------------------------------------------------------------------
*  METHOD on_f4_dyn.
** Save event parameter as global attributes of this class
** (maybe solved differently if you use a function module!)
*    f4_params-c_fieldname = e_fieldname.
*    f4_params-cs_row_no = es_row_no.
*    f4_params-cr_event_data = er_event_data.
*    f4_params-ct_bad_cells = et_bad_cells.
*    f4_params-c_display = e_display.
*
*    FIELD-SYMBOLS: <l_save_attr_outtab_dyn> LIKE attr_outtab_dyn[].
*    ASSIGN ('SAVE_ATTR_OUTTAB_DYN') TO <l_save_attr_outtab_dyn>.
*    IF sy-subrc = 0.
*      <l_save_attr_outtab_dyn> = attr_outtab_dyn[].
*    ENDIF.
*
*    CALL SCREEN 284 STARTING AT 10 10.
*
*    er_event_data->m_event_handled = 'X'.
**    set screen 0. leave screen.
*  ENDMETHOD.                                                "on_f4
**-------------------------------------------------------------------
*  METHOD hotspot_click.
**  perform write_complex_type_alv using es_row_no-row_id.   "OJO
*  ENDMETHOD.                    "hotspot_click
*
**=====================================================
*
*ENDCLASS.                    "lcl_application_f4 IMPLEMENTATION
