*----------------------------------------------------------------------*
***INCLUDE ZONPG_ONECONNECT_CUST_EXE_PAI.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  gv_okcode = sy-ucomm.

  IF ( gv_okcode EQ 'DISPLAY'
   OR  gv_okcode EQ 'CHANGE'
   OR  gv_okcode EQ 'DELETE'
   OR  gv_okcode EQ 'EXECUTE' ).
    IF zonta_obj_oc-domainv IS INITIAL.
      MESSAGE e007(zon_cl_oc) DISPLAY LIKE 'I'.
    ENDIF.
  ENDIF.

  CASE gv_okcode.
    WHEN 'BACK' OR 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'DISPLAY'.
      gv_columnss = gv_tabless = gv_mains = abap_true.
      gv_mode-text = co_change.
      gv_mode-icon_id = '@0Z@'.
      gv_option = co_display.
      PERFORM call_screen300.
    WHEN 'CREATE'.
      gv_new = abap_true.
      gv_option = co_change.
      CLEAR zonta_obj_oc.
      PERFORM clear_tables.
      gv_authorization = abap_true.
      PERFORM refresh_tables_columns USING 'TAB'.
      PERFORM refresh_tables_columns USING 'COL'.
      zonta_obj_oc-tag2 = gv_tag2.
      zonta_obj_oc-tag3 = gv_tag3.
      zonta_obj_oc-log_type = c_slg1.
*      CALL SCREEN 300.
      PERFORM call_screen_300.
    WHEN 'CHANGE'.
      gv_columnss = gv_tabless = gv_mains = abap_true.
      gv_mode-text = co_display.
      gv_mode-icon_id = '@10@'.
      gv_option = co_change.
      IF gv_authorization = abap_true.
        PERFORM call_screen300.
      ELSE.
        MESSAGE i034(zon_cl_oc).
      ENDIF.
    WHEN 'DELETE'.
      IF gv_authorization = abap_true.
        PERFORM delete_businessp.
      ELSE.
        MESSAGE i034(zon_cl_oc).
      ENDIF.
    WHEN 'EXECUTE'.
      PERFORM get_defaults_execute.
      CALL SCREEN 400 STARTING AT 5 15
           ENDING AT 85 30.
    WHEN 'DISP_LOG'.
      PERFORM display_log.
    WHEN 'DISP_SM37'.
      PERFORM display_sm37.
    WHEN 'DISP_PAR'.
      PERFORM call_parametert.
    WHEN 'UPLOAD'.
      gv_new_excel  = abap_true. "CECHAVARRIA 29/07/2025
      PERFORM call_screen600.
    WHEN 'DOWNLOAD'.
      IF zonta_obj_oc-domainv IS INITIAL.
        MESSAGE e007(zon_cl_oc) DISPLAY LIKE 'I'.
      ELSE.
        PERFORM call_screen602.
      ENDIF.
    WHEN 'GENERATE'.
      PERFORM regenerate.
    WHEN 'TRANSPORT'.
      PERFORM  save_entity_into_tr.
    WHEN 'CLONE'.
      gv_new = abap_true.
      gv_authorization = abap_true.
      PERFORM call_screen603.
     WHEN 'SYNCH'.
      PERFORM synch_metadata.
  ENDCASE.
ENDMODULE.                    "user_command_0100 INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
  CASE sy-ucomm.
    WHEN 'OK'.
      PERFORM validate_create_bus.
    WHEN 'CANCEL'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                    "user_command_0200 INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_DOMAIN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_domain_empty INPUT.

  IF zonta_obj_oc-domainv IS INITIAL.
    CLEAR gt_obj_oc[].

    SELECT *
      INTO TABLE gt_obj_oc
      FROM zonta_obj_oc.
    PERFORM refresh_grid_display.
    CLEAR zonta_obj_oc-business_proc.
  ENDIF.


ENDMODULE.                    "check_domain_empty INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_DOMAIN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_domain INPUT.

*  IF zonta_obj_oc-domainv IS INITIAL AND zonta_obj_oc-business_proc is INITIAL .
  IF zonta_obj_oc-business_proc IS INITIAL.
    CLEAR gt_obj_oc[].
    SELECT *
      INTO TABLE gt_obj_oc
      FROM zonta_obj_oc
      WHERE domainv = zonta_obj_oc-domainv.
    PERFORM refresh_grid_display.
  ENDIF.

ENDMODULE.                    "check_domain INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.

  IF lo_alv_tables IS BOUND.
    lo_alv_tables->check_changed_data( ).
  ENDIF.
  IF lo_alv_columns IS BOUND.
    lo_alv_columns->check_changed_data( ).
  ENDIF.

  gv_okcode = sy-ucomm.

  CASE gv_okcode.
    WHEN 'BACK'.
      FREE go_cust.
      CALL SCREEN 100.
    WHEN 'EXIT'.
      FREE go_cust.
      IF lo_container_tables IS NOT INITIAL.
        CALL METHOD lo_container_tables->free.
      endif.
      IF lo_container_columns IS NOT INITIAL.
        CALL METHOD lo_container_columns->free.
      ENDIF.
      LEAVE PROGRAM.
    WHEN 'DISP_CHG'.
      PERFORM switch_mode.

    WHEN 'SAVE_DATA'.
      PERFORM save_customizing.
      IF gv_path_error = abap_false.
        PERFORM clear_tables.
        PERFORM refresh_tables_columns USING 'TAB'.
        PERFORM refresh_tables_columns USING 'COL'.
        IF go_json IS NOT INITIAL.
          FREE go_json.
        ENDIF.
        LEAVE TO TRANSACTION  'ZONT_ONECM'.
      ELSE.
        gv_path_error = abap_false.
      ENDIF.

    WHEN 'FILTERS'.
      PERFORM call_filters_screen.
*    WHEN 'GENERATE'.
*      PERFORM generate_structures.
    WHEN 'PB_M'.
      gv_subscreen_300  =  301.
      IF gv_mains = abap_true.
        gv_mains = abap_false.
      ELSE.
        gv_mains = abap_true.
      ENDIF.
      PERFORM decide_screen.
      CALL SCREEN gv_screen.

    WHEN 'PB_T'.
      gv_subscreen_300 =  302.
      IF gv_tabless = abap_true.
        gv_tabless = abap_false.
      ELSE.
        gv_tabless = abap_true.
      ENDIF.
      PERFORM decide_screen.
      CALL SCREEN gv_screen.
    WHEN 'PB_C'.
      gv_subscreen_300 =  303.
      IF gv_columnss = abap_true.
        gv_columnss = abap_false.
      ELSE.
        gv_columnss = abap_true.
      ENDIF.
      PERFORM decide_screen.
      CALL SCREEN gv_screen.
    WHEN 'JOIN'.
      PERFORM call_join_tables.
    WHEN 'COLUMNS'.
      CALL SCREEN 500.
    WHEN 'CODE'.
      CALL SCREEN 900 STARTING AT 20 5 ENDING AT 80 10.
    WHEN 'AUTH_VAL'.
      IF zonta_oc_auth-objct IS INITIAL.
        CLEAR sy-ucomm.
        MESSAGE e030(zon_cl_oc) DISPLAY LIKE 'I'.
      ELSE.
        CALL SCREEN 800 STARTING AT 20 5 ENDING AT 55 20.
      ENDIF.
    WHEN 'LOG'.
      IF file = abap_true.
      ENDIF.
  ENDCASE.
ENDMODULE.                    "user_command_0300 INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0400  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0400 INPUT.
  DATA: lv_memory TYPE char20.

  CASE sy-ucomm.
    WHEN 'EXECUTE'.
      IF zonta_obj_oc-class_name IS INITIAL.
        ZONCL_OC_BASE_HANDLER=>gv_cancelled = abap_false.
        CONCATENATE 'ZONT' sy-uname INTO lv_memory.
        EXPORT: zonta_obj_oc TO MEMORY ID lv_memory.
        PERFORM execute_process USING abap_false.
      ELSE.
        ZONCL_OC_BASE_HANDLER=>gv_cancelled = abap_false.
        PERFORM execute_process_class USING abap_false.
      ENDIF.
      CLEAR: gv_tablen, gv_tablea, gv_variant.
      CLEAR zonta_oc_variant-variant.
      SET SCREEN 0.
*      LEAVE TO SCREEN 0.
    WHEN 'EXECUTEBK'.
      IF zonta_obj_oc-class_name IS INITIAL.
        ZONCL_OC_BASE_HANDLER=>gv_cancelled = abap_false.
        PERFORM execute_process USING abap_true.
      ELSE.
        ZONCL_OC_BASE_HANDLER=>gv_cancelled = abap_false.
        PERFORM execute_process_class USING abap_true.
      ENDIF.
      CLEAR: gv_tablen, gv_tablea, gv_variant.
      CLEAR zonta_oc_variant-variant.
*      LEAVE TO SCREEN 0.
    WHEN 'CANCEL'.
      CLEAR: gv_tablen, gv_tablea, gv_variant.
      CLEAR zonta_oc_variant-variant.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                    "user_command_0400 INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0500 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK'.
      CLEAR tree_left.
      left->free( ).
      CLEAR left.
      CLEAR tree_right.
      right->free( ).
      CLEAR right.
      container->free( ).
      CLEAR container.

      LEAVE TO SCREEN 300.
*BEGIN CECHAVARRIA 18/07/2025
    WHEN 'PASS_TO_CO'.
      PERFORM handle_pass_to_right_tree.
    WHEN 'SEARCH'.
      PERFORM handle_search.
*         when others.
*      CALL METHOD cl_gui_cfw=>dispatch.
*END CECHAVARRIA 18/07/2025
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.                    "user_command_0500 INPUT


*&---------------------------------------------------------------------*
*&      Module  OUTPUT_TYPE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE output_type INPUT.

ENDMODULE.                    "output_type INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_SELOP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_selop INPUT.

ENDMODULE.                    "check_selop INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0600  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0600 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK'.
      LEAVE TO SCREEN 300.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'OPTI'.
*      PERFORM SHOW_OPTION_ICONS.
    WHEN 'MORE'.
*      PERFORM SHOW_COMPLEX.
  ENDCASE.
ENDMODULE.                    "user_command_0600 INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0600  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0601 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'CANCEL'.
      LEAVE TO SCREEN 0."CALL SCREEN 100.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'EXECUTE'.
      PERFORM load_excel.
      IF r_customizing = abap_true.
        PERFORM load_customizing.
        CLEAR zonta_obj_oc.
        SELECT *
          INTO TABLE gt_obj_oc
          FROM zonta_obj_oc.
        PERFORM refresh_grid_display.
        LEAVE TO SCREEN 0. "CALL SCREEN 100.
      ELSEIF r_columns = abap_true.
        PERFORM load_columns.
        LEAVE TO SCREEN 0. "CALL SCREEN 100.
      ELSE.
        PERFORM load_filters_from_excel.
        LEAVE TO SCREEN 0. "CALL SCREEN 100.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_0600  INPUT
*&---------------------------------------------------------------------*
*&      Module  OPEN_FILE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE open_file INPUT.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      field_name = 'GV_FILE'
    IMPORTING
      file_name  = gv_file.
ENDMODULE.                    "open_file INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0700  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0700 INPUT.

  IF lo_alv_col_any IS BOUND.
    lo_alv_col_any->check_changed_data( ).
  ENDIF.

  IF alias = abap_true.
    gv_fieldname = abap_false.
  ELSE.
    gv_fieldname = abap_true.
  ENDIF.

  CASE sy-ucomm.
    WHEN 'BACK' OR 'CANCEL'.
      IF lo_alv_col_any IS NOT INITIAL.
        CALL METHOD lo_alv_col_any->free.
        CALL METHOD lo_container_col_any->free.
      ENDIF.
      CLEAR: gv_tablen,
             gv_tablea.
      CLEAR: gt_columns_any_alv,
             gt_columns_any,
             lo_alv_col_any,
             lo_container_col_any.
      CALL SCREEN 100.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'MARK_ALL'.
      PERFORM mark_all_columns.
    WHEN 'DES_ALL'.
      PERFORM unmark_all_columns.
    WHEN 'EXECUTE'.
      PERFORM save_columns_any.
      IF go_json IS INITIAL.
        CREATE OBJECT go_json.
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


      IF go_json IS BOUND.
        CLEAR go_json.
      ENDIF.
      CREATE OBJECT go_json.
      TRY.
          CALL METHOD go_json->send_json_any_table
            EXPORTING
              iv_tabname   = gv_tablen
              iv_aliastab  = gv_tablea "CECHAVARRIA 09/07/2025
              iv_update    = abap_true
              iv_delete    = abap_false
              iv_fieldname = gv_fieldname
              iv_alias     = gv_alias
              iv_dest      = gv_endpoint
              iv_bothnames = gv_bothtl.
          FREE go_json.
        CATCH cx_root INTO gx_text.
          DATA lv_error TYPE string.
*          DATA(lv_error) = gx_text->get_text( )."CECHAVARRIA 25/08/2025
          lv_error = gx_text->get_text( ). "CECHAVARRIA 25/08/2025
*          WRITE: / 'Error:', gx_text->get_text( ).
          WRITE: / 'Error:', lv_error.
      ENDTRY.


  ENDCASE.
ENDMODULE.                    "user_command_0700 INPUT
*&---------------------------------------------------------------------*
*&      Module  ALV_CHANGES  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE alv_changes INPUT.
* CALL METHOD lo_container_columns->free.
  DATA: lv_valid TYPE c.
  CALL METHOD lo_alv_columns->check_changed_data
    IMPORTING
      e_valid = lv_valid.
  CALL METHOD lo_alv_tables->check_changed_data.
ENDMODULE.                    "alv_changes INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0800  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0800 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
      IF lo_alv_auth IS NOT INITIAL.
        FREE lo_alv_auth.
      ENDIF.

      CLEAR: gt_auth_alv[].
      CLEAR: gs_auth.

      PERFORM call_screen_300.
    WHEN 'OK'.
      PERFORM update_auth.
      FREE lo_alv_auth.
      PERFORM call_screen_300.
  ENDCASE.
ENDMODULE.                    "user_command_0800 INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0900  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0900 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
      PERFORM call_screen_300.
    WHEN 'COPYC'.
      PERFORM copy_class.
      PERFORM call_screen_300.
  ENDCASE.
ENDMODULE.                    "user_command_0900 INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1000 INPUT.

  DATA: lt_style TYPE lvc_t_styl,
        ls_style TYPE lvc_s_styl.

  FIELD-SYMBOLS: <fs_variant> LIKE LINE OF gt_variant_alv.
*                 <fs_fcat>    LIKE LINE OF gt_fcat_variant.


  CASE sy-ucomm.
    WHEN 'SCREEN'.
      IF gv_screenv = abap_true.
        CLEAR gt_varatt.
        lo_alv_variant->set_ready_for_input( i_ready_for_input = 0 ).
        CALL METHOD lo_alv_variant->refresh_table_display.
      ELSE.
        lo_alv_variant->set_ready_for_input( i_ready_for_input = 1 ).
        CALL METHOD lo_alv_variant->refresh_table_display.
      ENDIF.
    WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
      LEAVE TO SCREEN 0.
    WHEN 'SAVE'.
      IF zonta_oc_variant-variant IS INITIAL.
        MESSAGE i040(zon_cl_oc).
      ELSE.
        PERFORM save_variant.
      ENDIF.
      IF gv_error = abap_false.
        LEAVE TO SCREEN 0.
      ENDIF.
    WHEN 'EXECUTE'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                    "user_command_1000 INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0283  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0283 INPUT.
  DATA: l_line     LIKE sy-tabix,
        e_valid(1).

  save_okcode = sy-ucomm.

  CASE save_okcode.
    WHEN 'CANCEL' OR 'BACK' OR 'EXIT'.
      SET SCREEN 0.
    WHEN 'SAVE'.
    WHEN 'OK'.
  ENDCASE.

  CALL METHOD grid7->check_changed_data
    IMPORTING
      e_valid = e_valid.
  CHECK  e_valid = 'X'.


***     clear grid1.
**
**     field-symbols:
**       <l_save_attr_outtab>     like gt_variant_alv[].
**    ASSIGN ('SAVE_ATTR_OUTTAB') to <l_save_attr_outtab>.
**    if sy-subrc = 0.
**      gt_variant_alv[] = <l_save_attr_outtab>.
**    endif.
**
**    field-symbols <m_itab> type lvc_t_modi.
**    assign f4_params-cr_event_data->m_data->* to <m_itab>.
**    if sy-subrc = 0.
**      clear <m_itab>.
**    endif.
**      set screen 0. leave screen.
**    when choose.
**      CLEAR L_LINE.
**      call method cl_gui_cfw=>flush.
**      CALL METHOD grid7->GET_CURRENT_CELL
**        IMPORTING
**          E_ROW     = l_line.
**      perform get_selected_F4 using L_LINE.
**    when 'VALU'.
**      data: temp_outtab like line of attr_outtab.
**      data: ls_row_id    type lvc_s_row.
**
**      if tvarv_p[] is initial or tvarv_s[] is initial.
**        perform fill_tvarv_f4_tables.
**      endif.
**      read table attr_outtab into temp_outtab
**          index f4_params-cs_row_no-row_id.
**      move-corresponding temp_outtab to varivar.
**      clear l_line.
**      call method grid7->get_current_cell
**        importing
**          e_row = l_line.
**      perform show_value(saplsvar) using l_line.
**
**      ls_row_id-index = l_line.                       "Neue Position
**      call method  grid7->set_current_cell_via_id
**                           exporting is_row_id    = ls_row_id.
**      alv_stable-row = 'X'.
**      alv_stable-col = 'X'.
**      call method grid7->refresh_table_display
**        exporting
**          is_stable = alv_stable.
**    when others.
**      CALL METHOD CL_GUI_CFW=>DISPATCH.
**  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0283  INPUT
*&---------------------------------------------------------------------*
*&      Module  VARINAME_HELP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE variname_help INPUT.

ENDMODULE.                    "variname_help INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0284  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0284 INPUT.

  FIELD-SYMBOLS: <fs_alv>    LIKE LINE OF gt_variant_alv.


  CASE sy-ucomm.
    WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
      CLEAR gs_varatt.
      CLEAR gs_variant_alv.
      CLEAR gv_index_v.
      SET SCREEN 0.
    WHEN 'OK'.

      LOOP AT gt_varatt ASSIGNING <fs_varatt> WHERE sign IS NOT INITIAL.
        gs_variant_alv-sign   = <fs_varatt>-sign.
        gs_variant_alv-option = <fs_varatt>-option.
        gs_variant_alv-vtext  = <fs_varatt>-attribute.
        gs_variant_alv-sapvar = <fs_varatt>-variable.
        EXIT.
      ENDLOOP.

      READ TABLE gt_variant_alv ASSIGNING <fs_alv> INDEX gv_index_v.
      IF <fs_alv> IS ASSIGNED.
        IF <fs_alv>-sign IS INITIAL.
          <fs_alv>-sign   = gs_variant_alv-sign.
        ENDIF.
        IF <fs_alv>-option IS INITIAL.
          <fs_alv>-option = gs_variant_alv-option.
        ENDIF.
        IF <fs_alv>-vtext IS INITIAL.
          <fs_alv>-vtext  = gs_variant_alv-vtext.
        ENDIF.
        IF <fs_alv>-sapvar IS INITIAL.
          READ TABLE gt_vardyn INTO ls_vardyn WITH KEY description = <fs_alv>-vtext.
          IF sy-subrc = 0.
            <fs_alv>-sapvar = ls_vardyn-sapvar.
          ENDIF.
        ENDIF.
      ENDIF.

      READ TABLE gt_vardyn INTO ls_vardyn WITH KEY sapvar = <fs_alv>-sapvar
                                                 description = <fs_alv>-vtext.
      IF sy-subrc = 0 AND ( ls_vardyn-window = 'D' OR ls_vardyn-window = 'S' ).
*        CALL SCREEN 285 STARTING AT 10 5
*                        ENDING AT 60 20.
        CALL SCREEN 285 STARTING AT 25 07
                ENDING AT 65 14.
        SET SCREEN 0.
      ELSE.
        SET SCREEN 0.
      ENDIF.
  ENDCASE.
ENDMODULE.                    "user_command_0284 INPUT
*&---------------------------------------------------------------------*
*&      Module  F4_VARIANT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_variant INPUT.

  TYPES: BEGIN OF st_vari,
           variant     TYPE variant,
           description TYPE zonde_vdesc,
         END OF st_vari.

  DATA: lt_return TYPE TABLE OF ddshretval,
        lt_dynpro TYPE TABLE OF dynpread,
        lt_values TYPE TABLE OF st_vari,
        ls_vari   TYPE st_vari,
        lv_repid  TYPE sy-repid,
        lv_dynnr  TYPE sy-dynnr.

  SELECT variant vdescription
   INTO TABLE lt_values
   FROM zonta_oc_variant
    WHERE domainv       = zonta_obj_oc-domainv
      AND business_proc = zonta_obj_oc-business_proc.
  SORT lt_values BY variant.
  DELETE ADJACENT DUPLICATES FROM lt_values COMPARING variant.

  "Call F4 popup
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'VARIANT'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'ZONTA_OC_VARIANT-VARIANT'
      value_org       = 'S'
    TABLES
      value_tab       = lt_values
      return_tab      = lt_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
ENDMODULE.                    "f4_variant INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0285  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0285 INPUT.

  CASE sy-ucomm.
    WHEN 'OK'.
      READ TABLE gt_variant_alv ASSIGNING <fs_variant> INDEX gv_index_v.
      IF sy-subrc = 0.
        <fs_variant>-val1 = zonta_oc_variant-val1.
        <fs_variant>-sign1 = zonta_oc_variant-sign1.

        IF zonta_oc_variant-val2 IS NOT INITIAL.
          <fs_variant>-val2 = zonta_oc_variant-val2.
          <fs_variant>-sign2 = zonta_oc_variant-sign2.
        ENDIF.
      ENDIF.
      LEAVE TO SCREEN 0.
    WHEN 'CANCEL' OR 'BACK' OR 'EXIT'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                    "user_command_0285 INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDATE_VARIANT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_variant INPUT.
  PERFORM validate_variant.
ENDMODULE.                    "validate_variant INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_FILEPATH  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_filepath INPUT.
  PERFORM validate_filepath.
ENDMODULE.                    "check_filepath INPUT
*&---------------------------------------------------------------------*
*&      Module  CHANGE_INPUT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE change_input INPUT.

  IF slg1 = abap_true.
    zonta_obj_oc-log_type = 'S'.
    CLEAR zonta_obj_oc-file_path.
  ELSE.
    zonta_obj_oc-log_type = 'F'.
  ENDIF.
ENDMODULE.                    "change_input INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0602  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0602 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'CANCEL'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'EXECUTE'.
      IF gv_file IS INITIAL.
        MESSAGE i031(zon_cl_oc) DISPLAY LIKE 'I'.
      ELSE.
        PERFORM download_excel.
        LEAVE TO SCREEN 0.
      ENDIF.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  OPEN_FILE_DOWNLOAD  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE open_file_download INPUT.
  DATA: lv_path TYPE string,
        lv_file TYPE string,
        lv_full TYPE string,
        lv_rc   TYPE i.

  cl_gui_frontend_services=>file_save_dialog(
    EXPORTING
      window_title      = 'Save Excel file'
      default_extension = 'xlsx'
      default_file_name = 'OneConnect_Metadata.xlsx'
      file_filter       = 'Excel (*.xlsx)|*.xlsx|All (*.*)|*.*|'
    CHANGING
      filename          = lv_file
      path              = lv_path
      fullpath          = lv_full
      user_action       = lv_rc
  ).

  IF lv_rc <> cl_gui_frontend_services=>action_ok.
    RETURN. "User cancelled
  ENDIF.

  gv_file = lv_full.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0603  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0603 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'CANCEL'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'CLONB'.
      PERFORM clone_entity.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_TAG1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_tag1 INPUT.

  TYPES: BEGIN OF st_domain,
           domainv     TYPE zonde_domain,
           description TYPE zonde_description,
         END OF st_domain.

  DATA: lt_ret  TYPE TABLE OF ddshretval,
        lt_data TYPE TABLE OF st_domain,
        ls_data TYPE st_domain.

  SELECT domainv description
    INTO TABLE lt_data
    FROM zonta_domains
     WHERE spras = sy-langu.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield    = 'DOMAIN'
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = 'ZONTA_OBJ_OC-TAG1'
      value_org   = 'S'
    TABLES
      value_tab   = lt_data
      return_tab  = lt_ret.



ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_TAG5  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_tag5 INPUT.

  TYPES: BEGIN OF st_datap,
           process_prefix TYPE zonde_procpref,
           mmodule        TYPE zonde_module,
           smodule        TYPE zonde_smodule,
           e2e            TYPE zonde_e2e,
           lob            TYPE zonde_lob,
           solution_pg    TYPE zonde_solpg,
           submodule_name TYPE zonde_submname,
         END OF st_datap.

  DATA: lt_ret5  TYPE TABLE OF ddshretval,
        lt_data5 TYPE TABLE OF st_datap,
        ls_data5 TYPE st_datap.

  SELECT process_prefix
         mmodule
         smodule
         e2e
         lob
         solution_pg
         submodule_name
    INTO TABLE lt_data5
    FROM zonta_dataprodc
    WHERE spras = sy-langu.
  IF sy-subrc NE 0.
    SELECT process_prefix
         mmodule
         smodule
         e2e
         lob
         solution_pg
         submodule_name
    INTO TABLE lt_data5
    FROM zonta_dataprodc.
  ENDIF.


  SORT lt_data5 BY process_prefix.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield    = 'PROCESS_PREFIX'
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = 'ZONTA_OBJ_OC-TAG5'
      value_org   = 'S'
    TABLES
      value_tab   = lt_data5
      return_tab  = lt_ret5.

ENDMODULE.
