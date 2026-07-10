FUNCTION ZONFM_RS_ESCAPE_QUOTES.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  CHANGING
*"     REFERENCE(VALUE) TYPE  CLIKE
*"  EXCEPTIONS
*"      PARAMETER_TOO_SHORT
*"--------------------------------------------------------------------

replace all occurrences of substring '''' in value with ''''''.
if sy-subrc = 2.
  raise parameter_too_short.
endif.

endfunction.
