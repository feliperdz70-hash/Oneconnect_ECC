FUNCTION ZONFM_OC_READ_EXCEL.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(FILENAME) TYPE  RLGRAP-FILENAME
*"     REFERENCE(I_BEGIN_COL) TYPE  I
*"     REFERENCE(I_BEGIN_ROW) TYPE  I
*"     REFERENCE(I_END_COL) TYPE  I
*"     REFERENCE(I_END_ROW) TYPE  I
*"     REFERENCE(SHEET) TYPE  CHAR50
*"  TABLES
*"      OUTPUT_INT STRUCTURE  ZONST_OC_EXCEL_TABLELINE
*"----------------------------------------------------------------------

  DATA lo_gui TYPE REF TO cl_gui_frontend_services.

* Variables Locales
  DATA: l_excel  TYPE ole2_object,
        l_book  TYPE ole2_object,
        l_sheet   TYPE ole2_object,
        l_cont   TYPE i,
        l_celli  TYPE ole2_object,
        l_cellf  TYPE ole2_object,
        l_cell   TYPE ole2_object,
        lt_table TYPE TABLE OF ty_s_senderline.

  DATA: ld_separator          TYPE  c.

  DATA: ld_rc                 TYPE i.

  DATA: intern                LIKE alsmex_tabline OCCURS 0
                                                  WITH HEADER LINE.

  DATA: lf_pestania(50).


* Se verifica que las filas y columnas sean coherentes
  IF i_begin_row > i_end_row.
    RAISE inconsistent_parameters.
  ENDIF.
  IF i_begin_col > i_end_col.
    RAISE inconsistent_parameters.
  ENDIF.


* Abrimos el Excel
  IF l_excel-header = space OR l_excel-handle = -1.
    CREATE OBJECT l_excel 'Excel.Application'.
  ENDIF.
  CALL METHOD OF l_excel 'Workbooks' = l_book.
  CALL METHOD OF l_book 'Open'
    EXPORTING
      #1 = filename.


* Se identifica el separador de campos
  CLASS cl_abap_char_utilities DEFINITION LOAD.
  ld_separator = cl_abap_char_utilities=>horizontal_tab.

  data: lv_proc type c.
  lv_proc = ' '.
* Recorremos las sheets del Excel
  DO.

*-- Incrementamos el Contador para ir de sheet en sheet
    ADD 1 TO l_cont.

*-- Limpiamos los objetos
    FREE OBJECT: l_cell, l_celli, l_cellf, l_sheet.
    CLEAR lt_table[].

*-- Leemos la sheet
    CALL METHOD OF l_excel 'Worksheets' = l_sheet
      EXPORTING
      #1 = l_cont.

*-- Si no existe la sheet Salimos del Bucle
    IF NOT sy-subrc IS INITIAL.
      EXIT.
    ENDIF.

*   Tomamos el nombre de la pestaña
    GET PROPERTY OF l_sheet 'NAME' = lf_pestania.
    IF sheet EQ lf_pestania.
*      CONTINUE.
      lv_proc = 'X'.
      EXIT.
      COMMIT WORK AND WAIT.
    ELSE.
      lv_proc = ' '.
    ENDIF.
  ENDDO.

  IF lv_proc EQ 'X'.
*-- Recogemos la Primera Celda
    CALL METHOD OF l_sheet 'Cells' = l_celli
      EXPORTING
      #1 = i_begin_row
      #2 = i_begin_col.
    COMMIT WORK AND WAIT.


*-- Recogemos la Ultima Celda
    CALL METHOD OF l_sheet 'Cells' = l_cellf
      EXPORTING
      #1 = i_end_row
      #2 = i_end_col.
    COMMIT WORK AND WAIT.

*-- Recogemos las celdas comprendidas entre la Primera y la Ultima
*-- y lo copiamos a la memoria intermedia
    CALL METHOD OF l_sheet 'RANGE' = l_cell
      EXPORTING
      #1 = l_celli
      #2 = l_cellf.
    COMMIT WORK AND WAIT.
    CALL METHOD OF l_cell 'SELECT'.
    COMMIT WORK AND WAIT.
    CALL METHOD OF l_cell 'COPY'.

    CREATE OBJECT lo_gui.


*-- Recogemos los Valores del portapapeles
    CALL METHOD lo_gui->clipboard_import
*    CALL METHOD cl_gui_frontend_services=>clipboard_import
      IMPORTING
        data                 = lt_table
      EXCEPTIONS
        cntl_error           = 1
        error_no_gui         = 2
        not_supported_by_gui = 3
        OTHERS               = 4.

    IF sy-subrc <> 0.
      MESSAGE a037(alsmex).
    ENDIF.

*-- Limpiamos los valores en blanco
*    SORT lt_table.
    DELETE lt_table WHERE line EQ space.
    CLEAR: sy-subrc.

*-- Recogemos los datos a la tabla de Salida
    CHECK NOT lt_table[] IS INITIAL.


    PERFORM separated_to_intern_convert TABLES lt_table intern
                                        USING  ld_separator.

*   Se vuelca el contenido de la sheet tratada en la tabla con la
*   identificación de la pestaña.
    LOOP AT intern.
      CLEAR output_int.
      output_int-pestania = lf_pestania.
      MOVE-CORRESPONDING intern TO output_int.
      APPEND output_int.
    ENDLOOP.

*   borramos el portapapeles
    REFRESH lt_table.
    CALL METHOD cl_gui_frontend_services=>clipboard_export
      IMPORTING
        data       = lt_table
      CHANGING
        rc         = ld_rc
      EXCEPTIONS
        cntl_error = 1
*       ERROR_NO_GUI         = 2
*       NOT_SUPPORTED_BY_GUI = 3
        OTHERS     = 4.

*  ENDDO.
  ENDIF.
* Cerramos el Excel
  CALL METHOD OF l_excel 'QUIT'.


*-- Limpiamos los objetos
  FREE OBJECT l_book.
  FREE OBJECT l_sheet.

  FREE OBJECT l_excel.
  FREE OBJECT l_celli.
  FREE OBJECT l_cellf.
  FREE OBJECT l_cell.

  SORT output_int BY pestania row col .



ENDFUNCTION.
