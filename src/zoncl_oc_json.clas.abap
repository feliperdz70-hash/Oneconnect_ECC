CLASS zoncl_oc_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS set_json
      IMPORTING
        !iv_json TYPE string .
    METHODS show_popup
      IMPORTING
        !iv_immediately TYPE boolean_flg .

    METHODS display IMPORTING
                      !iv_json        TYPE string
                      iv_caption      TYPE c deFAULT 'JSON Viewer'
                      iv_width        TYPE i deFAULT 700
                      iv_height       TYPE i dEFAULT 500
                      !iv_immediately TYPE boolean_flg OPTIONAL.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA gv_json TYPE string .
    DATA go_dialog TYPE REF TO cl_gui_dialogbox_container .
    DATA go_editor TYPE REF TO cl_gui_textedit .
    DATA gv_closed TYPE abap_bool .

    METHODS pretty_print_json IMPORTING iv_json               TYPE string
                              RETURNING VALUE(rv_pretty_json) TYPE string .
    METHODS show_wtextedit .
    METHODS show_wdemo_output .

ENDCLASS.



CLASS ZONCL_OC_JSON IMPLEMENTATION.


  METHOD display.

    " Pretty print
    DATA(lv_pretty) = pretty_print_json( iv_json = iv_json ).

    " Delegar todo al function group — él maneja el CALL SCREEN
    CALL FUNCTION 'ZONFM_OC_JSON_DISPLAY'
      EXPORTING
        iv_json    = lv_pretty
        iv_caption = iv_caption
        iv_width   = iv_width
        iv_height  = iv_height.

  ENDMETHOD.


  METHOD pretty_print_json.

    DATA: lv_indent  TYPE i VALUE 0,
          lv_char    TYPE c LENGTH 1,
          lv_result  TYPE string,
          lv_in_str  TYPE abap_bool VALUE abap_false,
          lv_len     TYPE i,
          lv_i       TYPE i,
          lv_newline TYPE string VALUE cl_abap_char_utilities=>newline,
          lv_spaces  TYPE string.

    lv_len = strlen( iv_json ).

    DO lv_len TIMES.
      lv_i    = sy-index - 1.
      lv_char = iv_json+lv_i(1).

      " Detectar si estamos dentro de un string (no procesar { } , dentro de strings)
      IF lv_char = '"' AND lv_in_str = abap_false.
        lv_in_str = abap_true.
        CONCATENATE lv_result lv_char INTO lv_result.
        CONTINUE.
      ELSEIF lv_char = '"' AND lv_in_str = abap_true.
        lv_in_str = abap_false.
        CONCATENATE lv_result lv_char INTO lv_result.
        CONTINUE.
      ENDIF.

      IF lv_in_str = abap_true.
        CONCATENATE lv_result lv_char INTO lv_result.
        CONTINUE.
      ENDIF.

      CASE lv_char.
        WHEN '{' OR '['.
          lv_indent = lv_indent + 2.
          lv_spaces = repeat( val = ` ` occ = lv_indent ).
          CONCATENATE lv_result lv_char lv_newline lv_spaces INTO lv_result.
        WHEN '}' OR ']'.
          lv_indent = lv_indent - 2.
          lv_spaces = repeat( val = ` ` occ = lv_indent ).
          CONCATENATE lv_result lv_newline lv_spaces lv_char INTO lv_result.
        WHEN ','.
          lv_spaces = repeat( val = ` ` occ = lv_indent ).
          CONCATENATE lv_result lv_char lv_newline lv_spaces INTO lv_result.
        WHEN ':'.
          CONCATENATE lv_result lv_char ` ` INTO lv_result.
        WHEN OTHERS.
          CONCATENATE lv_result lv_char INTO lv_result.
      ENDCASE.
    ENDDO.

    rv_pretty_json = lv_result.

  ENDMETHOD.


  METHOD set_json.

    gv_json = iv_json.

    REPLACE ALL OCCURRENCES OF '</' IN gv_json WITH '<\/'.

  ENDMETHOD.


  METHOD show_popup.

    IF iv_immediately = abap_false.
      show_wdemo_output(  ).
    ELSE.
      show_wtextedit(  ).
    ENDIF.

  ENDMETHOD.


  METHOD show_wdemo_output.

    cl_demo_output=>display_json( json = gv_json ).

  ENDMETHOD.


  METHOD show_wtextedit.

**    DATA: lo_dialog TYPE REF TO cl_gui_dialogbox_container,
**          lo_editor TYPE REF TO cl_gui_textedit,
*    DATA      lv_pretty TYPE string.
*
*    " Indent JSON
*    lv_pretty = me->pretty_print_json( ).
*
*    gv_closed = abap_false.
*
*    " POP UP
*    CREATE OBJECT go_dialog
*      EXPORTING
*        width   = 500
*        height  = 400
*        caption = 'JSON Viewer'.
*
*    SET HANDLER on_close FOR go_dialog.
*
*    CREATE OBJECT go_editor
*      EXPORTING
*        parent = go_dialog.
*
*    go_editor->set_textstream( text = lv_pretty ).
*    go_editor->set_readonly_mode( readonly_mode = 1 ).
*
*    CALL METHOD cl_gui_cfw=>flush.
*
*    WHILE gv_closed = abap_false.
*      cl_gui_cfw=>dispatch( ).   " procesa eventos GUI (incluido on_close)
*    ENDWHILE.
*
*    " Limpieza
*    IF go_dialog IS BOUND.
*      go_dialog->free( ).
*      CLEAR: go_dialog, go_editor.
*    ENDIF.

  ENDMETHOD.
ENDCLASS.
