*----------------------------------------------------------------------*
***INCLUDE LAQJD_CNTRLF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  define_join
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM define_join.

*--- graphical join defintion
  IF g_grafic = c_true.
    IF NOT g_join_data IS INITIAL.
      g_join_data->set_info( EXPORTING i_sgname       = g_sgname
                                       i_actworkspace = act_workspace
                                       i_headsg       = headsg
                                       i_maxsg_tindx  = maxsg_tindx
                                       i_mode         = g_mode
                                       i_caller_id    = g_caller_id
                                       it_dbdp        = dbdp[]
                                       it_dbpa        = dbpa[]
                                       it_dbwr        = dbwr[]
                                       it_dbar        = dbar[]
                                       it_dbft        = dbft[]
                                       it_sgtext      = sgtext[]
                                       it_exdbfi      = exdbfi[]
                                       it_ttab        = ttab[]
                                       it_dbzl        = dbzl[]
                                       it_clogsg      = clogsg[]
                                       it_dbsa        = dbsa[]
                                       it_dbob        = dbob[]
                                       it_dbos        = dbos[]
                                       it_dbif        = dbif[]
                                       it_dbsf        = dbsf[]
                                       it_dbsg        = dbsg[]
                                       it_dban        = dban[]
                                       it_dbjt        = dbjt[]
                                       it_dbjc        = dbjc[]
                                       it_dbzt        = dbzt[]
                                       it_dbzc        = dbzc[] ).
    ENDIF.
    CALL SCREEN '0200'.
*--- step-loop: join definition
  ELSE.
    CALL FUNCTION 'RSAQ_DJ_DEFINE_JOIN'
      EXPORTING
        act_workspace_input = act_workspace
        sgname_input        = g_sgname
        caller_id_input     = g_caller_id
        grafic_input        = ' '
      TABLES
        clogsg_input        = clogsg[]
        dbsa_input          = dbsa[]
        dbob_input          = dbob[]
        dbos_input          = dbos[]
        dbif_input          = dbif[]
        dbsf_input          = dbsf[]
        dbsg_input          = dbsg[]
        dban_input          = dban[]
        dbjt_input          = dbjt[]
        dbjc_input          = dbjc[]
        dbzt_input          = dbzt[]
        dbzc_input          = dbzc[]
        dbzl_input          = dbzl[]
        dbdp_input          = dbdp[]
        dbpa_input          = dbpa[]
        dbwr_input          = dbwr[]
        dbar_input          = dbar[]
        dbft_input          = dbft[]
        sgtext_input        = sgtext[]
        exdbfi_input        = exdbfi[]
        ttab_input          = ttab[]
      CHANGING
        headsg_input        = headsg
        mode_input          = g_mode
        maxsg_tindx_input   = maxsg_tindx
      EXCEPTIONS
        cancelled           = 1
        OTHERS              = 2.

    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDIF.

ENDFORM.                    " define_join

*&---------------------------------------------------------------------*
*&      Form  set_status_0200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_status_0200 .

  DATA: lt_excltab TYPE TABLE OF sy-ucomm,
        ls_excltab TYPE sy-ucomm.

  IF g_caller_id = 'Q'.  "Aufruf Quick-View
    ls_excltab = aqqis_c_ok_next.
    APPEND ls_excltab TO lt_excltab.
  ENDIF.

  SET PF-STATUS '0200' EXCLUDING lt_excltab.

ENDFORM.                    " set_status_0200
*&---------------------------------------------------------------------*
*&      Form  dynp_exit_0200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OK_CODE  text
*----------------------------------------------------------------------*
FORM dynp_exit_0200  USING p_ok_code TYPE syucomm.

  DATA: l_answer  TYPE c,
        l_infoset TYPE sgname.                              "#EC NEEDED

  CASE p_ok_code.
    WHEN aqqis_c_ok_cancel.
      g_canceled = aqqis_c_true.

      PERFORM free_all.
      SET SCREEN 0. LEAVE SCREEN.
      p_ok_code = space.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    " dynp_exit_0200
*&---------------------------------------------------------------------*
*&      Form  pai_0200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pai_0200 .

  DATA: l_rc    TYPE i,
        l_tname TYPE aqs_tname.

  sav_okcode = ok_code.
  CLEAR: ok_code.

  CASE sav_okcode.
*--- back
    WHEN aqqis_c_ok_back.
      g_join_cntrl->synchronize_positions( EXCEPTIONS no_data_on_control = 1 ).
      g_join_cntrl->check_conditions( IMPORTING  e_tname        = l_tname
                                      EXCEPTIONS not_right      = 1
                                                 zero_tables    = 2
                                                 only_one_table = 3 ).
      IF sy-subrc <> 0.
        PERFORM handle_exit_on_error USING sy-subrc  " ->
                                           l_tname   " ->
                                           l_rc.     " <-
        IF l_rc NE 0. EXIT. ENDIF.
      ENDIF.

      PERFORM get_info.
      PERFORM update_dbsg.
      PERFORM free_all.
      SET SCREEN 0. LEAVE SCREEN.

*--- dialogend
    WHEN aqqis_c_ok_dialogend.
      g_join_cntrl->synchronize_positions( EXCEPTIONS no_data_on_control = 1 ).
      g_join_cntrl->check_conditions( IMPORTING  e_tname        = l_tname
                                      EXCEPTIONS not_right      = 1
                                                 zero_tables    = 2
                                                 only_one_table = 3 ).
      IF sy-subrc <> 0.
        PERFORM handle_exit_on_error USING sy-subrc  " ->
                                           l_tname   " ->
                                           l_rc.     " <-
        IF l_rc NE 0. EXIT. ENDIF.
      ENDIF.

      PERFORM get_info.
      PERFORM update_dbsg.
      PERFORM free_all.
      SET SCREEN 0. LEAVE SCREEN.

*--- -> Infoset
    WHEN aqqis_c_ok_next.
      g_join_cntrl->synchronize_positions( EXCEPTIONS no_data_on_control = 1 ).
      PERFORM get_info.
      PERFORM update_dbsg.
      PERFORM free_all.
      SET SCREEN 0. LEAVE SCREEN.

    WHEN OTHERS.
      cl_gui_cfw=>dispatch( IMPORTING return_code = l_rc ).

*--- fcode: toolbar
      IF l_rc = 0.
*--- fcode: GUI-menue
      ELSE.
        g_join_cntrl->handle_fcode( EXPORTING i_fcode = sav_okcode ).
      ENDIF.
  ENDCASE.

ENDFORM.                                                    " pai_0200
*&---------------------------------------------------------------------*
*&      Form  fill_ttab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TTAB[]  text
*----------------------------------------------------------------------*
FORM fill_ttab TABLES pt_ttab TYPE aqq_t_ttab
                      pt_dbjt TYPE aqtdbjt.

  DATA: l_tab   TYPE tname,
        ls_ttab TYPE aqq_s_ttab.                            "#EC NEEDED

  FIELD-SYMBOLS: <dbjt> TYPE aqdbjt.

  LOOP AT pt_dbjt ASSIGNING <dbjt>.

    l_tab = <dbjt>-table.

    CALL FUNCTION 'ZONFM_RSAQ_CNTRL_BUILD_TTAB'
      EXPORTING
        i_tab     = l_tab
      IMPORTING
        e_tabinfo = ls_ttab.

  ENDLOOP.

ENDFORM.                    " fill_ttab
*&---------------------------------------------------------------------*
*&      Form  fill_exdbfi
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_DBJT[]  text
*----------------------------------------------------------------------*
FORM fill_exdbfi  TABLES pt_dbjt TYPE aqtdbjt.

  DATA: l_tab   TYPE tname.

  FIELD-SYMBOLS: <dbjt> TYPE aqdbjt.

  LOOP AT pt_dbjt ASSIGNING <dbjt>.
    l_tab = <dbjt>-table.

    CALL FUNCTION 'ZONFM_RSAQ_CNTRL_BUILD_EXDBFI'
      EXPORTING
        i_tab = l_tab.
* IMPORTING
*   E_RC          =
    .
  ENDLOOP.

ENDFORM.                    " fill_exdbfi
*&---------------------------------------------------------------------*
*&      Form  pai_0100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pai_0100 .

  sav_okcode = ok_code.

  CASE sav_okcode.
    WHEN aqqis_c_ok_weit.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.                                                    " pai_0100
*&---------------------------------------------------------------------*
*&      Form  dynp_exit_0100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OK_CODE  text
*----------------------------------------------------------------------*
FORM dynp_exit_0100  USING p_ok_code.

  CASE p_ok_code.
    WHEN aqqis_c_ok_cancel.
      RAISE cancelled.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    " dynp_exit_0100
*&---------------------------------------------------------------------*
*&      Form  get_info
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_info.
  g_join_data->get_info( IMPORTING e_sgname       = g_sgname
                                   e_actworkspace = act_workspace
                                   e_headsg       = headsg
                                   e_maxsg_tindx  = maxsg_tindx
                                   e_mode         = g_mode
                                   et_dbdp        = dbdp[]
                                   et_dbpa        = dbpa[]
                                   et_dbwr        = dbwr[]
                                   et_dbar        = dbar[]
                                   et_dbft        = dbft[]
                                   et_sgtext      = sgtext[]
                                   et_exdbfi      = exdbfi[]
                                   et_ttab        = ttab[]
                                   et_dbzl        = dbzl[]
                                   et_clogsg      = clogsg[]
                                   et_dbsa        = dbsa[]
                                   et_dbob        = dbob[]
                                   et_dbos        = dbos[]
                                   et_dbif        = dbif[]
                                   et_dbsf        = dbsf[]
                                   et_dbsg        = dbsg[]
                                   et_dban        = dban[]
                                   et_dbjt        = dbjt[]
                                   et_dbjc        = dbjc[]
                                   et_dbzt        = dbzt[]
                                   et_dbzc        = dbzc[] ).

ENDFORM.                    " get_info

*&---------------------------------------------------------------------*
*&      Form  set_status_0300
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_status_0300 .
  SET TITLEBAR '0300'.
  SET PF-STATUS '0300'.
ENDFORM.                    " set_status_0300
*&---------------------------------------------------------------------*
*&      Form  dynp_exit_0300
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OK_CODE  text
*----------------------------------------------------------------------*
FORM dynp_exit_0300  USING    p_ok_code.

  CASE p_ok_code.
    WHEN aqqis_c_ok_cancel.
      CLEAR: g_dyn_0300-tname.
      RAISE cancelled.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    " dynp_exit_0300
*&---------------------------------------------------------------------*
*&      Form  check_for_table_addition_0300
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_for_table_addition_0300 .

  CONDENSE g_dyn_0300-tname NO-GAPS.

  IF g_dyn_0300-tname = space.
    ok_code = aqqis_c_ok_cancel.
    EXIT.
  ENDIF.

* prüfen, ob Tabelle bereits benutzt wird
  READ TABLE dbjt TRANSPORTING NO FIELDS WITH KEY table = g_dyn_0300-tname.
  IF ( sy-subrc = 0 ).
*   Die Tabelle wird bereits verwendet
    MESSAGE e031(aqqis_cntrl).
  ENDIF.

  READ TABLE dbzt TRANSPORTING NO FIELDS WITH KEY tname = g_dyn_0300-tname.
  IF sy-subrc = 0.
*   Die Tabelle wird bereits verwendet
    MESSAGE e031(aqqis_cntrl).
  ENDIF.

*CECHAVARRIA 03/06/2025
  DATA: lv_is_ddic TYPE dd03l-tabname.

*Validate if is dicc or CDS
  SELECT SINGLE tabname
      FROM dd03l
     INTO lv_is_ddic
    WHERE tabname = g_dyn_0300-tname.
  IF sy-subrc EQ 0.
*CECHAVARRIA 03/06/2025

* prüfen, ob Tabelle in DB existiert
    PERFORM check_for_database_table(saplaqjd) USING g_dyn_0300-tname.
*  PERFORM check_for_database_table(saplzonfg_aqjd) USING g_dyn_0300-tname. "ONEC
  ENDIF."CECHAVARRIA 03/06/2025
ENDFORM.                    " check_for_table_addition_0300
*&---------------------------------------------------------------------*
*&      Form  pai_0300
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pai_0300 .
  CASE ok_code.
    WHEN aqqis_c_ok_weit.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                                                    " pai_0300
*&---------------------------------------------------------------------*
*&      Form  f4_tname_0300
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f4_tname_0300 .

  PERFORM f4_dd_table(rsaqddic) USING 'SAPLAQJD_CNTRL'
                                      '0300'
                                      'G_DYN_0300-TNAME'
                              CHANGING g_dyn_0300-tname.

ENDFORM.                    " f4_tname_0300
*&---------------------------------------------------------------------*
*&      Form  initialize_0300
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM initialize_0300 .
  CLEAR: g_dyn_0300-tname,
         ok_code.
ENDFORM.                    " initialize_0300
*&---------------------------------------------------------------------*
*&      Form  set_status_0400
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_status_0400 .
  SET TITLEBAR '0400' WITH g_tname_l.
  SET PF-STATUS '0400'.
ENDFORM.                    " set_status_0400

*---------------------------------------------------------------------*
*  FORM initialize_0400
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
FORM initialize_0400 .
  CLEAR: ok_code,
         g_dyn_0400.
ENDFORM.                    " initialize_0300
*&---------------------------------------------------------------------*
*&      Form  dynp_exit_0400
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OK_CODE  text
*----------------------------------------------------------------------*
FORM dynp_exit_0400  USING    p_ok_code.

  CASE p_ok_code.
    WHEN aqqis_c_ok_cancel.
      CLEAR: g_dyn_0300-tname.
      RAISE cancelled.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    " dynp_exit_0400
*&---------------------------------------------------------------------*
*&      Form  f4_domain_0400
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f4_domain_0400 .

  DATA: lt_dynpfields LIKE dynpread OCCURS 1 WITH HEADER LINE,
        l_domname     LIKE rsedd0-ddobjname,
        l_dyname      TYPE progname,
        l_dynumb      TYPE d020s-dnum.

  lt_dynpfields-fieldname = 'G_DYN_0400-SEARCHDOM'.
  APPEND lt_dynpfields.

  l_dyname = sy-repid.
  l_dynumb = sy-dynnr.
  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = l_dyname    "current running program
      dynumb     = l_dynumb
    TABLES
      dynpfields = lt_dynpfields
    EXCEPTIONS
      OTHERS     = 1.

  IF sy-subrc = 0.
    READ TABLE lt_dynpfields INDEX 1.
    l_domname = lt_dynpfields-fieldvalue.
    CALL FUNCTION 'RS_DD_F4_OBJECT'
      EXPORTING
        objname            = l_domname
        objtype            = 'D'
        suppress_selection = 'X'
      IMPORTING
        selobjname         = l_domname.

    g_dyn_0400-searchdom = l_domname.
  ENDIF.

ENDFORM.                    " f4_domain_0400
*&---------------------------------------------------------------------*
*&      Form  set_status_0500
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_status_0500 .
  SET TITLEBAR '0500'.
  SET PF-STATUS '0500'.
ENDFORM.                    " set_status_0500
*&---------------------------------------------------------------------*
*&      Form  dynp_exit_0500
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OK_CODE  text
*----------------------------------------------------------------------*
FORM dynp_exit_0500  USING    p_ok_code.

  CASE p_ok_code.
    WHEN aqqis_c_ok_cancel.
      RAISE cancelled.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    " dynp_exit_0500
*&---------------------------------------------------------------------*
*&      Form  init_ltab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_ltab .
  FIELD-SYMBOLS: <dbjt> TYPE aqdbjt.

  LOOP AT gt_dbjt ASSIGNING <dbjt>.
    f4_s_0500-tname     = <dbjt>-table.
    f4_s_0500-txt_tname = <dbjt>-table.
    COLLECT f4_s_0500 INTO f4_t_0500l.
  ENDLOOP.
ENDFORM.                    " init_ltab

*---------------------------------------------------------------------*
*  FORM init_rtab
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
FORM init_rtab .
  FIELD-SYMBOLS: <dbjt> TYPE aqdbjt.

  LOOP AT gt_dbjt ASSIGNING <dbjt>.
    f4_s_0500-tname     = <dbjt>-table.
    f4_s_0500-txt_tname = <dbjt>-table.
    COLLECT f4_s_0500 INTO f4_t_0500r.
  ENDLOOP.
ENDFORM.                    " init_ltab

*&---------------------------------------------------------------------*
*&      Form  initialize_0500
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM initialize_0500 .
  rs38q-dbjoltab = g_tname_l.
ENDFORM.                    " initialize_0500
*&---------------------------------------------------------------------*
*&      Form  pai_0500
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pai_0500 .

  g_tname_l = rs38q-dbjoltab.
  g_tname_r = rs38q-dbjortab.

  CASE ok_code.
    WHEN aqqis_c_ok_weit.
      SET SCREEN 0. LEAVE SCREEN.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.                                                    " pai_0500
*&---------------------------------------------------------------------*
*&      Form  check_tab_4_join_proposal_0500
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_tab_4_join_proposal_0500 .
  IF rs38q-dbjoltab EQ rs38q-dbjortab.
*   Die Tabellen müssen unterschiedlich sein
    MESSAGE e032(aqqis_cntrl).
  ENDIF.
ENDFORM.                    " check_tab_4_join_proposal_0500
*&---------------------------------------------------------------------*
*&      Form  update_dbsg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_dbsg.
  DATA: l_anz_dbjt  TYPE i,              " Anzahl Einträge in DBJT
        l_nummer(3) TYPE n,              " temp. Sortierschlüssel in DBGR
        l_subrc     LIKE sy-subrc.

* DBSG korrigieren (Sortierschlüssel eintragen)
  LOOP AT dbjt.
    l_nummer = sy-tabix.
    READ TABLE dbsg WITH KEY name = dbjt-table.
    IF sy-subrc = 0.
      dbsg-parent = l_nummer.
      MODIFY dbsg INDEX sy-tabix.
    ELSE.
      dbsg-name   = dbjt-table.
      dbsg-parent = l_nummer.
      dbsg-tindx  = '00000'.
      APPEND dbsg.
    ENDIF.
  ENDLOOP.

* perform aqjd_copyback.  " read_tab_infos expects updated dbsg! !!!
  LOOP AT dbsg.
    IF dbsg-parent = space.
      PERFORM sgtext_loeschen " in program (sy-cprog) " (sapms38o)
                              USING dbsg-tindx.
      DELETE dbsg.
    ELSEIF dbsg-tindx = '00000'.
      PERFORM read_tab_infos " in program (sy-cprog) " > in laqjdf81
                               USING dbsg-name l_subrc.
* Note: Read_tab_infos reads dict. structure into ttab if necessary.
*       it uses dbsg
      PERFORM sgtext_eintragen " in program (sy-cprog) " (sapms38o)
                               USING dbsg-tindx ttab-ddic-ddtext 40.
*      call function 'RSAQ_INSERT_INFOSET_TEXT'
*        EXPORTING
*          text      = ttab-ddic-ddtext
*          maxl      = 40
*        IMPORTING
*          tindx     = dbsg-tindx
*        TABLES
*          sgtext    = sgtext
*        CHANGING
*          max_tindx = maxsg_tindx.

      MODIFY dbsg.
    ENDIF.
  ENDLOOP.
  SORT dbsg BY parent.

* Sortierschlüssel aus DBSG entfernen
  LOOP AT dbsg.
    dbsg-parent = space.
    MODIFY dbsg.
  ENDLOOP.

* DBJT OUTERFLAG ergänzen (zuletzt space)
  DESCRIBE TABLE dbjt LINES l_anz_dbjt.
  LOOP AT dbjt.
    IF sy-tabix = l_anz_dbjt.
      dbjt-outerflag = space.
      MODIFY dbjt.
    ELSEIF dbjt-outerflag = space.
      dbjt-outerflag = 'I'.
      MODIFY dbjt.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " update_dbsg
*&---------------------------------------------------------------------*
*&      Form  free_all
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM free_all.

  IF NOT g_main_container IS INITIAL.
    g_main_container->free( ).
  ENDIF.

  IF NOT g_join_data IS INITIAL.
    FREE: g_join_data.
  ENDIF.

  IF NOT g_join_cntrl IS INITIAL.
    FREE: g_join_cntrl.
  ENDIF.

* we store user data in all the free methods
  DATA: l_r_pers TYPE REF TO cl_query_join_pers.
  l_r_pers =  cl_query_join_pers=>factory( ).
  l_r_pers->save( ).
  FREE: l_r_pers.

ENDFORM.                    " free_all
*&---------------------------------------------------------------------*
*&      Form  initialize_0100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM initialize_0100 .
  g_dyn_0100-ea_x = '100'.
  g_dyn_0100-ea_y = '100'.
ENDFORM.                    " initialize_0100
*&---------------------------------------------------------------------*
*&      Form  f4_rtab_0500
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f4_rtab_0500 .

  PERFORM init_rtab.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = rs38q-dbjotab
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'RS38Q-DBJORTAB'
      value_org       = 'S'
    TABLES
      value_tab       = f4_t_0500r
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc NE 0.
  ENDIF.

ENDFORM.                    " f4_rtab_0500
*&---------------------------------------------------------------------*
*&      Form  handle_exit_on_error
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SY_SUBRC  text
*----------------------------------------------------------------------*
FORM handle_exit_on_error  USING    p_sy_subrc TYPE sy-subrc
                                    p_tname    TYPE aqs_tname
                                    p_rc       TYPE sy-subrc.
  DATA: l_text(72) TYPE c,
        l_antwort  TYPE c,
        l_rc       TYPE sy-subrc.

  IF     p_sy_subrc = 1.
    IF sy-tcode = 'SQVI'.
*     Illegale Join-Bedingungen
      MESSAGE e035(aqqis_cntrl).
    ENDIF.
*   Tabelle &1 muß rechte Tabelle in einem Join sein
    MESSAGE s016(aqqis_cntrl) WITH p_tname INTO l_text.
  ELSEIF p_sy_subrc = 2.
*   Es ist keine Tabelle vorhanden
    MESSAGE s012(aqqis_cntrl) INTO l_text.
  ELSEIF p_sy_subrc = 3.
*   Es ist nur eine Tabelle vorhanden
    MESSAGE s013(aqqis_cntrl) INTO l_text.
  ENDIF.

  "ONEC
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      defaultoption = 'Y'
      textline1     = l_text
      textline2     = 'Finish the customizing of tables?'(212) "'Joinbearbeitung beenden?'(212)
      titel         = 'OneConnect Customizing Tables'(210) "'Tabellen-Join'(210)
    IMPORTING
      answer        = l_antwort.

  IF l_antwort = 'Y' OR l_antwort = 'J'.
    l_rc = 0.
*   g_canceled = aqqis_c_true.
  ELSE.
    l_rc = 4.
  ENDIF.

  p_rc = l_rc.

ENDFORM.                    " handle_exit_on_error
