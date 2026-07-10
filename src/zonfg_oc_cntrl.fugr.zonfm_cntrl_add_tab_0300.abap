FUNCTION ZONFM_CNTRL_ADD_TAB_0300.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     REFERENCE(E_TAB) TYPE  AQ_SEGNAME
*"  EXCEPTIONS
*"      CANCELLED
*"--------------------------------------------------------------------

  call screen 300 starting at 5 5.

  e_tab = g_dyn_0300-tname.

ENDFUNCTION.
