FUNCTION zonfm_rsaq_cntrl_add_tab_0300.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     REFERENCE(E_TAB) TYPE  AQ_SEGNAME
*"  EXCEPTIONS
*"      CANCELLED
*"----------------------------------------------------------------------

  CALL SCREEN 300 STARTING AT 5 5.

  e_tab = g_dyn_0300-tname.

ENDFUNCTION.
