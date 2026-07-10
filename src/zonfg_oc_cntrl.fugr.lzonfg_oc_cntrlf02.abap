*----------------------------------------------------------------------*
***INCLUDE LAQJD_CNTRLF02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  initialize_0200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM initialize_0200 .

*  data: l_main_container type ref to cl_gui_custom_container.

  if g_join_cntrl is initial.

    CREATE OBJECT g_join_data  EXPORTING  i_sgname        = g_sgname
                                          i_actworkspace  = act_workspace
                                          i_headsg        = headsg
                                          i_maxsg_tindx   = maxsg_tindx
                                          i_mode          = g_mode
                                          i_caller_id     = g_caller_id
                                          IT_CLOGSG       = clogsg[]
                                          IT_DBSA         = dbsa[]
                                          IT_DBOB         = dbob[]
                                          IT_DBOS         = dbos[]
                                          IT_DBIF         = dbif[]
                                          IT_DBSF         = dbsf[]
                                          IT_DBSG         = dbsg[]
                                          IT_DBAN         = dban[]
                                          IT_DBJT         = dbjt[]
                                          IT_DBJC         = dbjc[]
                                          IT_DBZT         = dbzt[]
                                          IT_DBZC         = dbzc[]
                                          IT_DBZL         = dbzl[]
                                          IT_DBDP         = dbdp[]
                                          IT_DBPA         = dbpa[]
                                          IT_DBWR         = dbwr[]
                                          IT_DBAR         = dbar[]
                                          IT_DBFT         = dbft[]
                                          IT_SGTEXT       = sgtext[]
                                          IT_EXDBFI       = exdbfi[]
                                          IT_TTAB         = ttab[]
                                          .
    create object g_main_container exporting container_name       = 'MAIN_CONTAINER'.
    create object g_join_cntrl     exporting i_r_container_parent = g_main_container
                                              i_join_data_r       = g_join_data
                                              i_mode              = g_mode.
  endif.

ENDFORM.                    " initialize_0200

*&---------------------------------------------------------------------*
*&      Form  set_mode_0200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_mode_0200 .
  if not g_join_cntrl is initial.
    g_join_cntrl->set_mode( i_mode = g_mode ).
  endif.
ENDFORM.                    " set_mode_0200
*&---------------------------------------------------------------------*
*&      Form  pai_0400
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pai_0400 .

* Prüfungen der Eingaben
  if g_dyn_0400-rad_searchtext <> space and g_dyn_0400-searchtext = space.
    set cursor field 'G_DYN_0400-SEARCHTEXT'.
*   Es wurden keine Suchbegriffe eingegeben
    message e029(aqqis_cntrl).
  endif.

  if g_dyn_0400-rad_searchdom <> space and g_dyn_0400-searchdom = space.
    set cursor field 'G_DYN_0400-SEARCHDOM'.
*   Es wurden keine Suchbegriffe eingegeben
    message e029(aqqis_cntrl).
  endif.

  if g_dyn_0400-rad_searchtype <> space and rs38q-dtype = space.
    set cursor field 'RS38Q-DTYPE'.
*   Es wurden keine Suchbegriffe eingegeben
    message e029(aqqis_cntrl).
  endif.

  if rs38q-cleng <> space.
    unpack rs38q-cleng to rs38q-cleng.
  endif.

  if rs38q-decnumb <> space  and
     rs38q-dtype   <> 'CURR' and
     rs38q-dtype   <> 'DEC'  and
     rs38q-dtype   <> 'FLTP' and
     rs38q-dtype   <> 'QUAN'.
    rs38q-decnumb = space.
  endif.

  if rs38q-cleng = space and rs38q-decnumb <> space.
    set cursor field 'RS38Q-CLENG'.
*   Bitte geben Sie eine Zeichenzahl an
    message e030(aqqis_cntrl).
  endif.

  if rs38q-decnumb <> space.
    unpack rs38q-decnumb to rs38q-decnumb.
  endif.

  case ok_code.
    when aqqis_c_ok_weit.
      set screen 0. leave screen.
    when others.
  endcase.

ENDFORM.                    " pai_0400
*&---------------------------------------------------------------------*
*&      Form  f4_ltab_0500
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f4_ltab_0500 .

  perform init_ltab.

  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = rs38q-dbjotab
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'RS38Q-DBJOLTAB'
      value_org       = 'S'
    TABLES
      value_tab       = f4_t_0500l
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  if sy-subrc ne 0.
  endif.

ENDFORM.                    " f4_ltab_0500
