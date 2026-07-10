FUNCTION ZONFM_RSAQ_CNTRL_BUILD_TTAB.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_TAB) TYPE  AQS_TNAME
*"  EXPORTING
*"     REFERENCE(E_RC) TYPE  SYSUBRC
*"     REFERENCE(E_TABINFO) TYPE  AQQ_S_TTAB
*"     REFERENCE(ET_TTAB) TYPE  AQQ_T_TTAB
*"--------------------------------------------------------------------

  perform get_tab_info using i_tab
                             e_tabinfo
                             e_rc.
  et_ttab[] = ttab[].

ENDFUNCTION.
