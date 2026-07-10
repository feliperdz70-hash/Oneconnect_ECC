FUNCTION ZONFM_RS_CHECK_VARIABLE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(VALUE) TYPE  CLIKE
*"  EXCEPTIONS
*"      INVALID_NAME
*"--------------------------------------------------------------------

  TRY.
      cl_abap_dyn_prg=>check_variable_name( value ).
    CATCH cx_abap_invalid_name.
      RAISE invalid_name.
  ENDTRY.

ENDFUNCTION.
