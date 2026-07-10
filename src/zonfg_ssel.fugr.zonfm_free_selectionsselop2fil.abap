FUNCTION ZONFM_FREE_SELECTIONSSELOP2FIL.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(T_SELOPT) TYPE  RSELOPTION
*"     REFERENCE(I_TABLE) TYPE  RSDSTABS-PRIM_TAB
*"     REFERENCE(I_FIELDNAME) TYPE  RSDSTABS-PRIM_FNAME
*"  EXPORTING
*"     REFERENCE(E_FILTER) TYPE  STRING
*"--------------------------------------------------------------------

  DATA: lt_rsds_trange      TYPE rsds_trange,
        ls_rsds_trange      TYPE rsds_range,
        lt_frange           TYPE rsds_frange_t,
        ls_frange           TYPE rsds_frange,
        lt_where_clause     TYPE rsds_twhere,
        ls_where_clause     TYPE rsds_where,
        lt_where_tab        TYPE rsds_where_tab,
        ls_where_tab        TYPE rsdswhere,
        lv_sql_where        TYPE string.

* prepare SELECT-OPTIONS for FuBa FREE_SELECTIONS_RANGE_2_WHERE (Field by Field)
  ls_rsds_trange-tablename = i_table.
  ls_frange-fieldname      = i_fieldname.
  ls_frange-selopt_t       = t_selopt.
  CLEAR lt_frange[].
  CLEAR lt_rsds_trange[].
  CLEAR lv_sql_where.
  APPEND ls_frange TO lt_frange.
  ls_rsds_trange-frange_t  = lt_frange.
  APPEND ls_rsds_trange TO lt_rsds_trange.

* Convert Ranges into substrings (SQL-like syntax)
  CALL FUNCTION 'ZONFM_FREE_SELECTIONS_RANGE_2WHERE'
    EXPORTING
      field_ranges  = lt_rsds_trange
    IMPORTING
      where_clauses = lt_where_clause.

  DATA: ls_where_tab_line TYPE string.

* Concatenate substrings (SQL-like syntax) into SQL-like string CORRECTING THE MISSING INDENTATION!
  LOOP AT lt_where_clause INTO ls_where_clause.
    lt_where_tab = ls_where_clause-where_tab.
    LOOP AT lt_where_tab INTO ls_where_tab.
      ls_where_tab_line = ls_where_tab-line.
      SHIFT ls_where_tab_line RIGHT.
      REPLACE ALL OCCURRENCES OF '  ''' IN ls_where_tab_line WITH ''''.
      CONCATENATE lv_sql_where ls_where_tab_line INTO lv_sql_where.
      CONDENSE lv_sql_where.
    ENDLOOP.
  ENDLOOP.

* Leaving only one space between each word.
  CONDENSE lv_sql_where.

* Find and replace literal operands by mathematical ones.
  REPLACE ALL OCCURRENCES OF ` EQ ` IN lv_sql_where WITH ` = ` IN CHARACTER MODE.
  REPLACE ALL OCCURRENCES OF ` GE ` IN lv_sql_where WITH ` >= ` IN CHARACTER MODE.
  REPLACE ALL OCCURRENCES OF ` LE ` IN lv_sql_where WITH ` <= ` IN CHARACTER MODE.
  REPLACE ALL OCCURRENCES OF ` NE ` IN lv_sql_where WITH ` <> ` IN CHARACTER MODE.

* Adding the client handling at the end of the string ONLY IF the table contains the field MANDT!

* Check for the existence of the field MANDT
  SELECT COUNT(*) FROM dd03l WHERE tabname EQ ls_rsds_trange-tablename AND fieldname EQ 'MANDT'.
  IF sy-subrc = 0.
    DATA lv_clt_begin TYPE c LENGTH 15 VALUE ' AND MANDT = '''.
    DATA lv_clt TYPE mandt.
    DATA lv_clt_end TYPE c LENGTH 10 VALUE ''''.
    lv_clt = sy-mandt.
    CONCATENATE lv_sql_where lv_clt_begin lv_clt lv_clt_end INTO lv_sql_where.
  ENDIF.

  e_filter = lv_sql_where.

ENDFUNCTION.
