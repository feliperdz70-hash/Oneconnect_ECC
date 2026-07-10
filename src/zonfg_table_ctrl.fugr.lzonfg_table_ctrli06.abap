*----------------------------------------------------------------------*
***INCLUDE LZONFG_TABLE_CTRLI06.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  MODIFY_TABLE_CONTROL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_table_control INPUT.
  READ TABLE gt_dd07t INTO gs_dd07t INDEX priorities_tab-current_line.

  IF sy-subrc = 0.
    MODIFY gt_dd07t FROM gs_dd07t INDEX priorities_tab-current_line.
  ENDIF.

ENDMODULE.
