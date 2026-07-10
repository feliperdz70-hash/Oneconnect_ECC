FUNCTION ZONFM_CNTRL_BUILD_EXDBFI.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_TAB) TYPE  AQS_TNAME
*"  EXPORTING
*"     REFERENCE(E_RC) TYPE  SYSUBRC
*"     REFERENCE(ET_EXDBFI) TYPE  AQQ_T_EXDBFI
*"--------------------------------------------------------------------

  perform read_field_infos using i_tab
                                 e_rc.

  et_exdbfi[] = exdbfi[].

ENDFUNCTION.
