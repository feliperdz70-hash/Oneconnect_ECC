FUNCTION ZONFM_RSAQ_CNTRL_SCALE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     REFERENCE(E_X) TYPE  AQQPROZ
*"     REFERENCE(E_Y) TYPE  AQQPROZ
*"  EXCEPTIONS
*"      CANCELLED
*"--------------------------------------------------------------------

  call screen 100 starting at 5 5.

  e_x = g_dyn_0100-ea_x.
  e_y = g_dyn_0100-ea_y.

ENDFUNCTION.
