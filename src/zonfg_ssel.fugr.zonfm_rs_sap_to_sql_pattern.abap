function ZONFM_RS_SAP_TO_SQL_PATTERN.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(SAP_PATTERN) TYPE  CLIKE
*"  CHANGING
*"     REFERENCE(SQL_PATTERN) TYPE  STRING
*"     REFERENCE(ESCAPE_NEEDED) TYPE  ABAP_BOOL
*"  EXCEPTIONS
*"      PATTERN_ERROR
*"--------------------------------------------------------------------

  clear sql_pattern.
  call method lcl_helper=>sap_to_sql_patte
    exporting
      sap_pattern   = sap_pattern
    importing
      sql_pattern   = sql_pattern
      escape_needed = escape_needed
    exceptions
      others        = 1.
  if sy-subrc = 1.
    raise pattern_error.
  endif.

endfunction.
