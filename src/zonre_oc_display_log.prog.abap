*&---------------------------------------------------------------------*
*& Report ZONRE_ONI_DISPLAY_LOG                                        *
*&         Reporte Log One Connect                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
*&        ONIBEX                                                       *
*&        January 2023                                                 *
*&---------------------------------------------------------------------*
REPORT zonre_oc_display_log.


INCLUDE zonre_oc_display_log_top.
INCLUDE zonre_oc_display_log_sel.
INCLUDE zonre_oc_display_log_class.
INCLUDE zonre_oc_display_log_f01.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_subo.
  PERFORM get_subobjects CHANGING p_subo.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_tabn-low.
  PERFORM get_tabname CHANGING s_tabn-low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_tabn-high.
  PERFORM get_tabname CHANGING s_tabn-high.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_entity.
  PERFORM get_entity CHANGING p_entity.

START-OF-SELECTION.
  FIELD-SYMBOLS: <fs_key> LIKE LINE OF gt_key.

  PERFORM log_search.
  SORT gt_log BY date time user code prog process cdobjcl mestyp tabname key type id number.

  IF NOT p_entity IS INITIAL.
    DELETE gt_log WHERE process NE p_entity.
  ENDIF.

  IF NOT s_key IS INITIAL.
*    MOVE-CORRESPONDING s_key[] TO gt_key[].
    LOOP AT s_key.
      MOVE-CORRESPONDING s_key TO ls_key.
      APPEND ls_key TO gt_key.
    ENDLOOP.


    LOOP AT gt_key ASSIGNING <fs_key>.
      gv_numc = <fs_key>-low.
      <fs_key>-low = gv_numc.
    ENDLOOP.
    DELETE gt_log WHERE key NOT IN gt_key[].
  ENDIF.

  IF NOT s_tabn IS INITIAL.
    DELETE gt_log WHERE tabname NOT IN s_tabn[].
  ENDIF.

  IF NOT s_date IS INITIAL.
    DELETE gt_log WHERE date NOT IN s_date[].
  ENDIF.

  IF NOT s_prog IS INITIAL.
    DELETE gt_log WHERE prog NOT IN s_prog[].
  ENDIF.

  IF NOT s_user IS INITIAL.
    DELETE gt_log WHERE user NOT IN s_user[].
  ENDIF.

  IF NOT s_code IS INITIAL.
    DELETE gt_log WHERE code NOT IN s_code[].
  ENDIF.

  IF p_al = c_x.
  ELSEIF p_er = c_x.
    DELETE gt_log WHERE type NE c_e.
  ELSEIF p_wa = c_x.
    DELETE gt_log WHERE type NE c_w.
  ELSEIF p_su = c_x.
    DELETE gt_log WHERE type NE c_s.
  ENDIF.

  IF gt_log IS INITIAL.
    MESSAGE i006(zon_cl_dl).
  ELSE.
    PERFORM display_alv.
  ENDIF.

AT USER-COMMAND.
  CASE sy-ucomm.
    WHEN '&REFRESH'.
*      SELECT * FROM zmylog INTO TABLE gt_log.
      BREAK-POINT.
      ob_table->refresh( ).
  ENDCASE.

END-OF-SELECTION.
