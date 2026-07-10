*&---------------------------------------------------------------------*
*& Report ZONPG_ONECONNECT_REORG
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zonpg_oneconnect_reorg.



TYPES: BEGIN OF ty_object,
         pgmid    TYPE tadir-pgmid,
         object   TYPE tadir-object,
         obj_name TYPE tadir-obj_name,
       END OF ty_object.

DATA: lt_objects TYPE STANDARD TABLE OF ty_object,
      ls_object  TYPE ty_object,
      lv_file    TYPE string,
      ls_tadir   TYPE tadir.

PARAMETERS: p_sys TYPE tadir-srcsystem OBLIGATORY,  "New Original System
            p_usr TYPE tadir-author    OBLIGATORY.  "Person Responsible

SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_file TYPE  rlgrap-filename  OBLIGATORY.
SELECTION-SCREEN: END OF BLOCK b1.

INITIALIZATION.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  CALL FUNCTION 'F4_FILENAME'
    IMPORTING
      file_name = p_file.

START-OF-SELECTION.

  lv_file = p_file.

* Upload object list
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = lv_file
      filetype                = 'ASC'
    TABLES
      data_tab                = lt_objects
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      OTHERS                  = 6.

  IF sy-subrc <> 0.
    MESSAGE 'Error uploading file' TYPE 'E'.
  ENDIF.

* Process each object
  LOOP AT lt_objects INTO ls_object.


    CALL FUNCTION 'TRINT_TADIR_UPDATE'
      EXPORTING
        pgmid                = ls_object-pgmid
        object               = ls_object-object
        obj_name             = ls_object-obj_name
        author               = p_usr
        srcsystem            = p_sys
      EXCEPTIONS
        object_has_no_tadir  = 1
        object_exists_global = 2
        OTHERS               = 3.

    IF sy-subrc = 0.
      WRITE: / 'Updated:', ls_object-pgmid, ls_object-object, ls_object-obj_name.
    ELSE.
      WRITE: / 'Error:', ls_object-pgmid, ls_object-object, ls_object-obj_name.
    ENDIF.
  ENDLOOP.
