*&---------------------------------------------------------------------*
*& Report ZONRE_OC_CONFIG_EVENT_CHECK
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zonre_oc_config_event_check.

INTERFACE lif_oc_validator.

  TYPES:BEGIN OF ty_events,
          cdobjectcl  TYPE zonta_oc_events-cdobjectcl,
          objtype     TYPE zonta_oc_events-objtype,
          event       TYPE swc_elem,
          type        TYPE char6,
          swo1        TYPE icon-id,
          swec        TYPE icon-id,
          swetypv     TYPE icon-id,
          bte         TYPE icon-id,
          rap         TYPE icon-id,
          oneconnect  TYPE icon-id,
          description TYPE zonta_oc_events-description,
        END OF ty_events.

ENDINTERFACE.

CLASS lcl_eventhandler DEFINITION.

  PUBLIC SECTION.

    CLASS-METHODS: factory IMPORTING it_table TYPE ANY TABLE.

    CLASS-METHODS: handle_double_click FOR EVENT double_click
    OF cl_gui_alv_grid IMPORTING e_row e_column es_row_no sender.

    CLASS-METHODS: handle_context_menu_request FOR EVENT context_menu_request
        OF cl_gui_alv_grid IMPORTING e_object sender.

    CLASS-METHODS: handle_user_command FOR EVENT user_command
        OF cl_gui_alv_grid IMPORTING e_ucomm sender.

  PRIVATE SECTION.

    CLASS-DATA: gr_table_ref TYPE REF TO data.

    CLASS-METHODS messaga_info IMPORTING iv_title TYPE string
                                         it_text  TYPE string_table.

ENDCLASS.


CLASS lcl_eventhandler IMPLEMENTATION.

  METHOD handle_double_click.

    FIELD-SYMBOLS: <fs_table> TYPE STANDARD TABLE,
                   <fs_line>  TYPE lif_oc_validator=>ty_events.

    ASSIGN gr_table_ref->* TO <fs_table>.

    READ TABLE <fs_table> ASSIGNING <fs_line> INDEX es_row_no-row_id.
    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    CHECK ( e_column EQ 'ONECONNECT' OR e_column EQ 'RAP' ).

    ASSIGN COMPONENT e_column OF STRUCTURE <fs_line> TO FIELD-SYMBOL(<fs_field>).
    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    CHECK <fs_field> EQ icon_red_light.

    CASE e_column.
      WHEN 'ONECONNECT'.
        CALL TRANSACTION 'ZONT_ONECM'.
      WHEN 'RAP'.
        messaga_info( iv_title = |RAP Configuration| it_text = VALUE #( ( |It's necessary to create a class with behavior { <fs_line>-objtype }.| ) ( || ) ) ).
        RETURN.
    ENDCASE.

  ENDMETHOD.

  METHOD handle_context_menu_request.

    DATA: lt_func      TYPE ui_functions.

    " Inactivate all standard functions
    e_object->get_functions( IMPORTING fcodes = DATA(lt_fcodes) ).

    LOOP AT lt_fcodes INTO DATA(ls_fcode).
      APPEND ls_fcode-fcode TO lt_func.
    ENDLOOP.

    e_object->disable_functions( lt_func ).

    " Add new functions
    e_object->add_separator( ).

    e_object->add_function( EXPORTING fcode = 'SWEC' text = 'Add rec. to SWEC' ).

    e_object->add_function( EXPORTING fcode = 'SWE2' text = 'Add rec. to SWE2/SWETYPV' ).

    e_object->add_function( EXPORTING fcode = 'OC' text = 'Add rec. to ONE CONNECT' ).

  ENDMETHOD.                    "handle_context_menu_request

  METHOD handle_user_command.

    DATA: ls_row TYPE lvc_s_row,
          ls_col TYPE lvc_s_col.

    DATA: lt_bdcdata TYPE TABLE OF bdcdata.

    FIELD-SYMBOLS: <fs_table> TYPE STANDARD TABLE,
                   <fs_line>  TYPE lif_oc_validator=>ty_events.

    ASSIGN gr_table_ref->* TO <fs_table>.

    CHECK ( e_ucomm = 'SWEC' OR  e_ucomm = 'SWE2' ).

    sender->get_current_cell( IMPORTING es_row_id = ls_row es_col_id = ls_col ).

    READ TABLE <fs_table> ASSIGNING <fs_line> INDEX ls_row-index.
    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    CASE e_ucomm.
      WHEN 'SWEC'.

        IF NOT ( <fs_line>-type  = 'BOR' OR <fs_line>-type = 'BOR_CL' ).
          RETURN.
        ENDIF.

        IF <fs_line>-swec = icon_green_light.

          messaga_info( iv_title = 'SWEC Configuration' it_text = VALUE #( ( |{ <fs_line>-objtype }, already configured.| ) ( | | ) ) ).
          RETURN.
        ENDIF.

        CLEAR lt_bdcdata.

        APPEND VALUE #( program  = 'SAPLSWEC' dynpro = '0100' dynbegin = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_CURSOR' fval = 'SWEVCDOBJ1-OBJCATEG(01)' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '=NEWL' ) TO lt_bdcdata. " New Entries Code

        APPEND VALUE #( program  = 'SAPLSWEC' dynpro = '0150' dynbegin = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'SWEVCDOBJ1-CDOBJECTCL' fval = 'LSTAR' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'SWEVCDOBJ1-OBJCATEG' fval = SWITCH #( <fs_line>-type WHEN 'BOR' THEN 'BO' ELSE 'CL' ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'SWEVCDOBJ1-OBJTYPE' fval = <fs_line>-objtype )  TO lt_bdcdata.
        APPEND VALUE #( fnam = 'G_EVENT_150'   fval = <fs_line>-event ) TO lt_bdcdata.
        CASE <fs_line>-event.
          WHEN 'CREATED'.
            APPEND VALUE #( fnam = 'G_ON_CREATE_150' fval = abap_true ) TO lt_bdcdata.
          WHEN 'CHANGED'.
            APPEND VALUE #( fnam = 'G_ON_CHANGE_150' fval = abap_true ) TO lt_bdcdata.
            APPEND VALUE #( fnam = 'G_ON_CREATE_150' fval = abap_false ) TO lt_bdcdata.
        ENDCASE.

        " Execute the call
        CALL TRANSACTION 'SWEC' USING lt_bdcdata
                                MODE 'E'  " Display only if error occurs
                                UPDATE 'S'.

      WHEN 'SWE2'.

        IF NOT ( <fs_line>-type  = 'BOR' OR <fs_line>-type = 'BOR_CL' ).
          RETURN.
        ENDIF.

        IF <fs_line>-swetypv = icon_green_light.

          messaga_info( iv_title = 'SWETYPV Configuration' it_text = VALUE #( ( |{ <fs_line>-objtype }, already configured.| ) ( | | ) ) ).
          RETURN.
        ENDIF.

        CLEAR lt_bdcdata.

        APPEND VALUE #( program  = 'SAPLSWF_EVT_TYP' dynpro = '0100' dynbegin = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_CURSOR' fval = 'SWFDVEVTY1-OBJCATEG(01)' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '=NEWL' ) TO lt_bdcdata. " New Entries Code

        APPEND VALUE #( program  = 'SAPLSWF_EVT_TYP'    dynpro = '0150' dynbegin = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'SWFDVEVTY1-OBJCATEG'    fval = SWITCH #( <fs_line>-type WHEN 'BOR' THEN 'BO' ELSE 'CL' ) ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'SWFDVEVTY1-OBJTYPE'     fval = <fs_line>-objtype ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'SWFDVEVTY1-EVENT'       fval = <fs_line>-event )  TO lt_bdcdata.
        APPEND VALUE #( fnam = 'SWFDVEVTY1-RECTYPE'     fval = |ONECONNECT_{ <fs_line>-event }| ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'SWFDVEVTY1-ENABLED'     fval = abap_true ) TO lt_bdcdata.

        IF <fs_line>-type = 'BOR'.
          APPEND VALUE #( fnam = 'SWFDVEVTY1-RECFB'     fval = 'ZONFM_QUEUE_MANAGER' ) TO lt_bdcdata.
        ELSE.
          APPEND VALUE #( fnam = 'SWFDVEVTY1-RECMODE'   fval = 'M' ) TO lt_bdcdata.
          APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '=SWITCH_HANDLER' ) TO lt_bdcdata. " New Entries Code

          APPEND VALUE #( program  = 'SAPLSWF_EVT_TYP'    dynpro = '0150' dynbegin = 'X' ) TO lt_bdcdata.
          APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '/00' ) TO lt_bdcdata. " New Entries Code
          APPEND VALUE #( fnam = 'SWFDVEVTY1-RECCLASS'  fval = 'ZONCL_QUEUE_MANAGER' ) TO lt_bdcdata.
        ENDIF.

        APPEND VALUE #( program  = 'SAPLSWF_EVT_TYP' dynpro = '0150' dynbegin = 'X' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_CURSOR' fval = 'SWFDVEVTY1-OBJCATEG' ) TO lt_bdcdata.
        APPEND VALUE #( fnam = 'BDC_OKCODE' fval = '=SAVE' ) TO lt_bdcdata. " New Entries Code

        " Execute the call
        CALL TRANSACTION 'SWETYPV' USING lt_bdcdata
                                   MODE 'E'  " Display only if error occurs
                                   UPDATE 'S'.

    ENDCASE.

  ENDMETHOD.

  METHOD factory.

    GET REFERENCE OF it_table INTO gr_table_ref.

  ENDMETHOD.

  METHOD messaga_info.

    CALL FUNCTION 'POPUP_TO_INFORM'
      EXPORTING
        titel = iv_title
        txt1  = VALUE #( it_text[ 1 ] OPTIONAL )
        txt2  = VALUE #( it_text[ 2 ] OPTIONAL )
        txt3  = VALUE #( it_text[ 3 ] OPTIONAL )
        txt4  = VALUE #( it_text[ 4 ] OPTIONAL ).

  ENDMETHOD.

ENDCLASS.


CLASS lcl_oc_report DEFINITION CREATE PRIVATE.

  PUBLIC SECTION.

    TYPES: tt_char6 TYPE STANDARD TABLE OF char6.

    CLASS-METHODS: select_data IMPORTING it_type TYPE tt_char6.

    CLASS-METHODS: show_report.

    CLASS-METHODS: show_report_grid.

    CLASS-METHODS: show_console.

  PROTECTED SECTION.

  PRIVATE SECTION.

    TYPES: tt_events TYPE STANDARD TABLE OF lif_oc_validator=>ty_events.

    CONSTANTS: c_bor    TYPE char6 VALUE 'BOR',
               c_bor_cl TYPE char6 VALUE 'BOR_CL',
               c_rap    TYPE char6 VALUE 'RAP',
               c_bte    TYPE char6 VALUE 'BTE'.

    CLASS-DATA: gt_events_rep TYPE tt_events.

ENDCLASS.

CLASS lcl_oc_report IMPLEMENTATION.

  METHOD select_data.

    SELECT *
    INTO TABLE @DATA(lt_events)
    FROM zonta_oc_events.

    CHECK lt_events IS NOT INITIAL.

    " SWO1 - BOR
    SELECT *
    INTO TABLE @DATA(lt_tojtb)
    FROM tojtb
    FOR ALL ENTRIES IN @lt_events
    WHERE name = @lt_events-objtype(10).

    " EVENTS for BOR
    IF lt_tojtb IS NOT INITIAL.

      SELECT lobjtype, verb, verbtype, objtype, editelem, descript, shorttext
      INTO TABLE @DATA(lt_swotlv)
      FROM swotlv
      FOR ALL ENTRIES IN @lt_tojtb
      WHERE lobjtype = @lt_tojtb-name
        AND verbtype = 'E'.

    ENDIF.

    " EVENTS for BOR CLASS
    SELECT *
    INTO TABLE @DATA(lt_seocompo)
    FROM seocompo
    FOR ALL ENTRIES IN @lt_events
    WHERE clsname = @lt_events-objtype(30)
      AND cmptype = '2'.

    " SWEC - Change Documents
    SELECT *
    INTO TABLE @DATA(lt_swevcdobj1)
    FROM swecdobj
    FOR ALL ENTRIES IN @lt_events
    WHERE objtype = @lt_events-objtype.

    " RAP - Class
    SELECT *
    INTO TABLE @DATA(lt_vseoclass)
    FROM vseoclass
    FOR ALL ENTRIES IN @lt_events
    WHERE clsname  LIKE 'Z%'
      AND clsdefint = @lt_events-objtype(30).

    " SWETYPV - Event Type Linkages
    SELECT *
    INTO TABLE @DATA(lt_swfdevtyp)
    FROM swfdevtyp
    FOR ALL ENTRIES IN @lt_events
    WHERE objtype = @lt_events-objtype
      AND ( recclass = 'ZONCL_QUEUE_MANAGER' OR recfb = 'ZONFM_QUEUE_MANAGER' ).

    SELECT *
    INTO TABLE @DATA(lt_swfdevena)
    FROM swfdevena
    FOR ALL ENTRIES IN @lt_events
    WHERE objtype = @lt_events-objtype.

    " BTE - FIBF
    SELECT *
    INTO TABLE @DATA(lt_tbe34)
    FROM tbe34
    FOR ALL ENTRIES IN @lt_events
    WHERE event = @lt_events-objtype(8)
      AND prdkt = 'ZOCBTE'.

    " One Connect
    SELECT *
    INTO TABLE @DATA(lt_obj_oc)
    FROM zonta_obj_oc
    FOR ALL ENTRIES IN @lt_events
    WHERE objtype = @lt_events-objtype.

    DATA ls_events_rep TYPE lif_oc_validator=>ty_events.

    SORT lt_events BY cdobjectcl objtype.

    LOOP AT lt_events INTO DATA(ls_events).

      CLEAR ls_events_rep.
      MOVE-CORRESPONDING ls_events TO ls_events_rep.

      ls_events_rep-type       = COND #( WHEN ls_events-description CP '*BOR*' THEN c_bor
                                         WHEN ls_events-description CP '*RAP*' THEN c_rap
                                         WHEN ls_events-description CP '*BTE*' THEN c_bte
                                         WHEN ls_events-objtype     CP '*BUS*' THEN c_bor ).

      ls_events_rep-type       = COND #( WHEN strlen( ls_events_rep-objtype ) > 10 AND ls_events_rep-type = c_bor THEN c_bor_cl
                                         WHEN ls_events_rep-type IS INITIAL THEN 'ND'
                                         ELSE ls_events_rep-type ).

      CHECK line_exists( it_type[ table_line = ls_events_rep-type ] ).

      ls_events_rep-swo1       = SWITCH #( ls_events_rep-type WHEN c_bor THEN COND #( LET bus = VALUE #( lt_tojtb[ name = ls_events-objtype(10) ]-name OPTIONAL ) IN
                                                                                WHEN bus NE ''                          THEN icon_green_light
                                                                                WHEN strlen( ls_events-objtype ) > 10   THEN icon_yellow_light
                                                                                ELSE icon_red_light )
                                                              ELSE icon_light_out ).

      ls_events_rep-swec = icon_light_out.

      ls_events_rep-oneconnect = COND #( LET objtype = VALUE #( lt_obj_oc[ objtype = ls_events-objtype ]-objtype OPTIONAL ) IN WHEN objtype NE '' THEN icon_green_light ELSE icon_red_light ).

      ls_events_rep-swetypv    = SWITCH #( ls_events_rep-type WHEN c_bor    THEN icon_red_light
                                                              WHEN c_bor_cl THEN icon_red_light
                                                              ELSE icon_light_out ).

      ls_events_rep-bte = SWITCH #( ls_events_rep-type WHEN c_bte THEN COND #( LET event = VALUE #( lt_tbe34[ event = ls_events-objtype(8) ]-event OPTIONAL ) IN
                                                                                WHEN event NE ''                        THEN icon_green_light
                                                                                ELSE icon_red_light )
                                                                  ELSE icon_light_out ).

      ls_events_rep-rap = SWITCH #( ls_events_rep-type WHEN c_rap THEN COND #( LET clsname = VALUE #( lt_vseoclass[ clsdefint = ls_events-objtype(30) ]-clsname OPTIONAL ) IN
                                                                                WHEN clsname NE ''                        THEN icon_green_light
                                                                                ELSE icon_red_light )
                                                                  ELSE icon_light_out ).

      CASE ls_events_rep-type.

        WHEN c_bor.

          LOOP AT lt_swotlv INTO DATA(ls_swotlv) WHERE lobjtype = ls_events-objtype.

            ls_events_rep-swetypv    = COND #( LET objtype = VALUE #( lt_swfdevtyp[ objtype = ls_events-objtype event = ls_swotlv-verb ]-objtype OPTIONAL ) IN
                                                                                 WHEN objtype NE '' THEN icon_green_light
                                                                                 ELSE icon_red_light ).

            ls_events_rep-event = ls_swotlv-verb.

            CLEAR ls_events_rep-swec.

            LOOP AT lt_swevcdobj1 INTO DATA(ls_swevcdobj1) WHERE objtype = ls_events-objtype.

              CASE ls_swotlv-verb.
                WHEN ls_swevcdobj1-event_del OR ls_swevcdobj1-event_ins OR ls_swevcdobj1-event_upd.
                  ls_events_rep-swec  = icon_green_light.
                  EXIT.
              ENDCASE.

            ENDLOOP.

            ls_events_rep-swec  = COND #( WHEN ls_events_rep-swec NE icon_green_light THEN icon_red_light ELSE icon_green_light ).
            APPEND ls_events_rep TO gt_events_rep.

          ENDLOOP.

        WHEN c_bor_cl.

          LOOP AT lt_seocompo INTO DATA(ls_seocompo) WHERE clsname = ls_events-objtype(30).

            ls_events_rep-swetypv    = COND #( LET objtype = VALUE #( lt_swfdevtyp[ objtype = ls_seocompo-clsname event = ls_seocompo-cmpname ]-objtype OPTIONAL ) IN
                                                                                 WHEN objtype NE '' THEN icon_green_light
                                                                                 ELSE icon_red_light ).


            ls_events_rep-event = ls_seocompo-cmpname.
            APPEND ls_events_rep TO gt_events_rep.

          ENDLOOP.

*        WHEN c_bte.
*
*
*
*          APPEND ls_events_rep TO gt_events_rep.

        WHEN OTHERS.
*          ls_events_rep-swec = icon_light_out.
          APPEND ls_events_rep TO gt_events_rep.
      ENDCASE.

    ENDLOOP.

  ENDMETHOD.

  METHOD show_report.

    DATA: lo_column               TYPE REF TO cl_salv_column_table.

    TRY.

        cl_salv_table=>factory( IMPORTING r_salv_table   = DATA(lr_alv)
                                CHANGING  t_table        = gt_events_rep  ).

        DATA(lo_columns) = lr_alv->get_columns( ).
        lo_columns->set_optimize( abap_true ).

        LOOP AT VALUE string_table( ( |SWO1| ) ( |SWEC| ) ( |SWETYPV| ) ( |ONECONNECT| ) ( |BTE| ) ( |TYPE| ) ) INTO DATA(ls_data).

          TRY.
              lo_column ?= lo_columns->get_column( CONV lvc_fname( ls_data ) ).
              lo_column->set_icon( if_salv_c_bool_sap=>true ).
              lo_column->set_long_text( CONV scrtext_l( ls_data ) ).
            CATCH cx_salv_not_found.                    "#EC NO_HANDLER
          ENDTRY.

        ENDLOOP.

        lr_alv->display( ).

      CATCH cx_salv_msg INTO DATA(lr_salv_msg).

        WRITE:/ lr_salv_msg->get_text(  ).

    ENDTRY.

  ENDMETHOD.

  METHOD show_report_grid.

    DATA: lt_fcat   TYPE lvc_t_fcat.
    DATA: lr_tabdescr TYPE REF TO cl_abap_structdescr,
          lr_data     TYPE REF TO data.

    CREATE DATA lr_data LIKE LINE OF gt_events_rep.

    lr_tabdescr ?= cl_abap_structdescr=>describe_by_data_ref( lr_data ).

    DATA(lt_dfies) = cl_salv_data_descr=>read_structdescr( lr_tabdescr ).

    LOOP AT cl_salv_data_descr=>read_structdescr( lr_tabdescr ) INTO DATA(ls_dfies).

      APPEND INITIAL LINE TO lt_fcat ASSIGNING FIELD-SYMBOL(<fs_fcat>).
      MOVE-CORRESPONDING ls_dfies TO <fs_fcat>.
      <fs_fcat>-col_opt = abap_true.

      CASE <fs_fcat>-fieldname.

        WHEN 'SWO1' OR 'SWEC' OR 'SWETYPV' OR 'ONECONNECT' OR 'BTE' OR 'RAP'.
          <fs_fcat>-coltext = <fs_fcat>-fieldname.
          <fs_fcat>-scrtext_s = <fs_fcat>-fieldname.
          <fs_fcat>-scrtext_m = <fs_fcat>-fieldname.
          <fs_fcat>-scrtext_l = <fs_fcat>-fieldname.
          <fs_fcat>-just = 'C'.
      ENDCASE.

    ENDLOOP.

    TRY.

        DATA(ls_layout) = VALUE lvc_s_layo( col_opt = abap_true ).

        DATA(lo_grid) = NEW cl_gui_alv_grid( i_parent = cl_gui_container=>screen0 ).

        lcl_eventhandler=>factory( it_table = gt_events_rep ).
        SET HANDLER: lcl_eventhandler=>handle_double_click          FOR lo_grid,
                     lcl_eventhandler=>handle_context_menu_request  FOR lo_grid,
                     lcl_eventhandler=>handle_user_command          FOR lo_grid.

        lo_grid->set_table_for_first_display( EXPORTING is_layout = ls_layout
                                              CHANGING  it_outtab = gt_events_rep
                                                        it_fieldcatalog = lt_fcat ).

      CATCH cx_root.
        MESSAGE 'Error in ALV creation' TYPE 'E'.
    ENDTRY.

  ENDMETHOD.

  METHOD show_console.

    cl_demo_output=>display( gt_events_rep ).

  ENDMETHOD.

ENDCLASS.

**********************************************************************

TABLES: zonta_oc_events.

DATA: rg_type TYPE STANDARD TABLE OF char6.

SELECT-OPTIONS: s_otype FOR zonta_oc_events-objtype.

PARAMETERS: c_rap    AS CHECKBOX DEFAULT abap_true,
            c_bor    AS CHECKBOX DEFAULT abap_true,
            c_bor_cl AS CHECKBOX DEFAULT abap_true,
            c_bte    AS CHECKBOX DEFAULT abap_true,
            c_nd     AS CHECKBOX DEFAULT abap_true.

START-OF-SELECTION.

  LOOP AT VALUE string_table( ( |C_RAP| ) ( |C_BOR| ) ( |C_BOR_CL| ) ( |C_BTE| ) ( |C_ND| ) ) INTO DATA(ls_type).

    ASSIGN (ls_type) TO FIELD-SYMBOL(<fs_type>).
    IF sy-subrc EQ 0 AND <fs_type> EQ abap_true .
      APPEND ls_type+2 TO rg_type.
    ENDIF.

  ENDLOOP.

  lcl_oc_report=>select_data( it_type = rg_type ).
  IF sy-batch = abap_true.
    lcl_oc_report=>show_console(  ).
  ELSE.
    lcl_oc_report=>show_report_grid(  ).
  ENDIF.


  WRITE: / 'test'.
