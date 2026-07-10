*----------------------------------------------------------------------*
***INCLUDE LZONFG_TABLE_CTRLO06.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PRIORITIES  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE priorities OUTPUT.
  DESCRIBE TABLE gt_dd07t LINES sy-dbcnt.

  priorities_tab-current_line = sy-loopc.
  priorities_tab-lines        = sy-dbcnt.

  dd07t-valpos = gs_dd07t-valpos.
  dd07t-ddtext = gs_dd07t-ddtext.

  CLEAR gs_dd07t.


ENDMODULE.
