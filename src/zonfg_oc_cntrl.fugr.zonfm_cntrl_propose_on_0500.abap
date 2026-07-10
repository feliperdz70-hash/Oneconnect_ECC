FUNCTION ZONFM_CNTRL_PROPOSE_ON_0500 .
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_DBJT) TYPE  AQTDBJT
*"     REFERENCE(I_TNAME) TYPE  AQS_TNAME
*"  EXPORTING
*"     REFERENCE(E_TNAME1) TYPE  AQS_TNAME
*"     REFERENCE(E_TNAME2) TYPE  AQS_TNAME
*"  EXCEPTIONS
*"      CANCELLED
*"--------------------------------------------------------------------

  gt_dbjt   = it_dbjt.
  g_tname_l = i_tname.

  call screen '0500' starting at 10 10.

  e_tname1 = g_tname_l.
  e_tname2 = g_tname_r.

ENDFUNCTION.
