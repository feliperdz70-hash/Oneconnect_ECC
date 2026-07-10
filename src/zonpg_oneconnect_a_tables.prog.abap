*&---------------------------------------------------------------------*
*& Report ZONPG_ONECONNECT_A_TABLES
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zonpg_oneconnect_a_tables.

TYPES: BEGIN OF ty_object,
         tabname TYPE tabname,
       END OF ty_object,
       BEGIN OF ty_alv,
         process TYPE char30,
         tabname TYPE tabname,
         status  TYPE char1,
         message TYPE char100,
       END OF ty_alv.

CONSTANTS: c_comi VALUE '''',
           c_per  VALUE '%'.

DATA: it_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat TYPE slis_fieldcat_alv.

DATA: lt_objects     TYPE STANDARD TABLE OF ty_object,
      ls_object      TYPE ty_object,
      lv_file        TYPE string,
      lv_alias       TYPE tabname,
      ls_anyalia     TYPE zonta_oc_anyalia,
      gt_columns_all TYPE TABLE OF zonta_oc_col_all,
      lw_col_all     TYPE zonta_oc_col_all,
      lv_table       TYPE zonde_id,
      lv_number      TYPE n LENGTH 10,
      lv_returncode  TYPE inri-returncode,
      lt_dfies       TYPE TABLE OF dfies,
      lw_dfies       TYPE dfies,
      lt_where       TYPE rsds_where_tab,
      lw_where       TYPE rsdswhere,
      lv_cond        TYPE char10,
      lw_alv         TYPE ty_alv,
      lt_alv         TYPE TABLE OF ty_alv,
      r_size         TYPE zonde_oc_num30,
      r_records      TYPE zonde_oc_num30,
      v_size         TYPE char30,
      v_records      TYPE char30.


SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_file TYPE  rlgrap-filename  OBLIGATORY,
              p_one  RADIOBUTTON GROUP 1 DEFAULT 'X',
              p_tow  RADIOBUTTON GROUP 1.
SELECTION-SCREEN: END OF BLOCK b1.

INITIALIZATION.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  CALL FUNCTION 'F4_FILENAME'
    IMPORTING
      file_name = p_file.

START-OF-SELECTION.
***PREPARE TABLE FOR ANY
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
    IF p_one IS NOT INITIAL.
***validate if the table exist at ZONTA_OC_ANYALIA
      SELECT SINGLE tabname INTO lv_alias
        FROM zonta_oc_anyalia
        WHERE tabname = ls_object-tabname.
      IF sy-subrc NE 0.
        ls_anyalia-tabname        = ls_object-tabname.
        ls_anyalia-alias_tabname  = ls_object-tabname.
        MODIFY zonta_oc_anyalia FROM ls_anyalia.
        lw_alv-process  = 'Set Table'.
        lw_alv-tabname  = ls_object-tabname.
        lw_alv-status   = 'S'.
        lw_alv-message   = 'Table Created for ANY Entity'.
        APPEND lw_alv TO lt_alv.
        CLEAR lw_alv.
      ELSE.
        lw_alv-process  = 'Set Table'.
        lw_alv-tabname  = ls_object-tabname.
        lw_alv-status   = 'E'.
        lw_alv-message   = 'Table Already Exit'.
        APPEND lw_alv TO lt_alv.
        CLEAR lw_alv.
      ENDIF.

***validate if the columns exist at ZONTA_OC_COL_ALL
      SELECT * INTO TABLE gt_columns_all
        FROM zonta_oc_col_all
        WHERE tabname  = ls_object-tabname.
      IF sy-subrc NE 0.
        CLEAR lv_number.
        CALL FUNCTION 'NUMBER_GET_NEXT'
          EXPORTING
            nr_range_nr             = '01'
            object                  = 'ZONR_COL_A'
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
          LV_table = lv_number.
          CALL FUNCTION 'DDIF_FIELDINFO_GET'
            EXPORTING
              tabname        = ls_object-tabname
            TABLES
              dfies_tab      = lt_dfies
            EXCEPTIONS
              not_found      = 1
              internal_error = 2
              OTHERS         = 3.
          IF sy-subrc = 0.
            LOOP AT lt_dfies INTO lw_dfies.
              lw_col_all-mandt               =  sy-mandt.
              lw_col_all-id_column           =  lv_table.
              lw_col_all-tabname             =  lw_dfies-tabname.
              lw_col_all-fldname             =  lw_dfies-fieldname.
              CONCATENATE lw_col_all-fldname '1' INTO lw_col_all-alias_fldname.
              lw_col_all-key_field           =  lw_dfies-keyflag.
              lw_col_all-description_field   =  lw_dfies-scrtext_s.
              lw_col_all-positionf           =  lw_dfies-position.
              MODIFY zonta_oc_col_all FROM lw_col_all.
              CLEAR lw_col_all.
            ENDLOOP.
            lw_alv-process  = 'Set Table'.
            lw_alv-tabname  = ls_object-tabname.
            lw_alv-status   = 'S'.
            lw_alv-message   = 'Fields Created for ANY Entity'.
            APPEND lw_alv TO lt_alv.
            CLEAR lw_alv.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
**EXCECUTE SEND DATA TO OneConnect.
      CLEAR: lt_where, lw_where.
      CONCATENATE c_comi c_per c_comi INTO lv_cond.
      CONDENSE lv_cond.
      CONCATENATE ' ( KNUMH LIKE ' lv_cond  '  )' INTO lw_where SEPARATED BY space.
      APPEND lw_where TO lt_where.
      DATA lv_knumh TYPE knumh.
      SELECT SINGLE knumh INTO lv_knumh FROM (ls_object-tabname).
      IF sy-subrc = 0.
        CALL FUNCTION 'ZONFM_OC_PRICE_EVENT'
          EXPORTING
            i_table   = ls_object-tabname
            i_where   = lt_where
          IMPORTING
            r_size    = r_size
            r_records = r_records.
        MOVE :
            r_size    TO v_size,
            r_records TO v_records.
            SHIFT v_size    LEFT DELETING LEADING '0'.
            SHIFT v_records LEFT DELETING LEADING '0'.


        lw_alv-process  = 'Send Table Data'.
        lw_alv-tabname  = ls_object-tabname.
        lw_alv-status   = 'S'.

        CONCATENATE 'Data Sent: RECORDS:' v_records 'SIZE' v_size INTO lw_alv-message SEPARATED BY space.
        APPEND lw_alv TO lt_alv.
        CLEAR lw_alv.
      ELSE.

        lw_alv-process  = 'Send Table Data'.
        lw_alv-tabname  = ls_object-tabname.
        lw_alv-status   = 'E'.
        lw_alv-message   = 'Table is Empty'.
        APPEND lw_alv TO lt_alv.
        CLEAR lw_alv.
      ENDIF.
    ENDIF.
  ENDLOOP.

**set catalog
  wa_fieldcat-fieldname  = 'PROCESS'.
  wa_fieldcat-seltext_m  = 'PROCESS'.
  APPEND wa_fieldcat TO it_fieldcat.
  wa_fieldcat-fieldname  = 'TABNAME'.
  wa_fieldcat-seltext_m  = 'TABLE NAME'.
  APPEND wa_fieldcat TO it_fieldcat.
  wa_fieldcat-fieldname  = 'STATUS'.
  wa_fieldcat-seltext_m  = 'STATUS'.
  APPEND wa_fieldcat TO it_fieldcat.
  wa_fieldcat-fieldname  = 'MESSAGE'.
  wa_fieldcat-seltext_m  = 'MESSAGE'.
  APPEND wa_fieldcat TO it_fieldcat.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      it_fieldcat   = it_fieldcat
    TABLES
      t_outtab      = lt_alv
    EXCEPTIONS
      program_error = 1
      OTHERS        = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
