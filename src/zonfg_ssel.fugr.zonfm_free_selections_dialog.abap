FUNCTION ZONFM_FREE_SELECTIONS_DIALOG.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(SELECTION_ID) LIKE  RSDYNSEL-SELID
*"     VALUE(TITLE) LIKE  SY-TITLE DEFAULT SPACE
*"     VALUE(FRAME_TEXT) LIKE  SY-TITLE DEFAULT SPACE
*"     VALUE(STATUS) TYPE  I OPTIONAL
*"     VALUE(AS_WINDOW) TYPE  C DEFAULT SPACE
*"     VALUE(START_ROW) LIKE  SY-WINY1 DEFAULT 2
*"     VALUE(START_COL) LIKE  SY-WINX1 DEFAULT 2
*"     VALUE(NO_INTERVALS) TYPE  C DEFAULT SPACE
*"     VALUE(JUST_DISPLAY) TYPE  C DEFAULT SPACE
*"     VALUE(PFKEY) LIKE  RSDSPFKEY STRUCTURE  RSDSPFKEY OPTIONAL
*"     VALUE(ALV) TYPE  C DEFAULT SPACE
*"     REFERENCE(TREE_VISIBLE) TYPE  C DEFAULT 'X'
*"     REFERENCE(DIAG_TEXT_1) TYPE  C OPTIONAL
*"     VALUE(DIAG_TEXT_2) TYPE  C OPTIONAL
*"     REFERENCE(WARNING_TITLE) TYPE  C OPTIONAL
*"     REFERENCE(AS_SUBSCREEN) DEFAULT SPACE
*"     VALUE(NO_FRAME) OPTIONAL
*"  EXPORTING
*"     VALUE(WHERE_CLAUSES) TYPE  RSDS_TWHERE
*"     VALUE(EXPRESSIONS) TYPE  RSDS_TEXPR
*"     VALUE(FIELD_RANGES) TYPE  RSDS_TRANGE
*"     VALUE(NUMBER_OF_ACTIVE_FIELDS) LIKE  SY-TFILL
*"  TABLES
*"      FIELDS_TAB STRUCTURE  RSDSFIELDS
*"      FCODE_TAB STRUCTURE  RSDSFCODE OPTIONAL
*"      FIELDS_NOT_SELECTED STRUCTURE  RSDSFIELDS OPTIONAL
*"  EXCEPTIONS
*"      INTERNAL_ERROR
*"      NO_ACTION
*"      SELID_NOT_FOUND
*"      ILLEGAL_STATUS
*"--------------------------------------------------------------------

  DATA L_EXP_PARS TYPE EXP_PARS.

* soll der Tree dargestellt werden
  show_tree = tree_visible.
  if gui_tested is initial.
    perform gui_has_active_x.
  endif.
*  SORT SELID_INFO BY selid. "DB VAR
  READ TABLE SELID_INFO WITH KEY selid = SELECTION_ID
                        BINARY SEARCH
                        INTO CURRENT_INFO.
  IF SY-SUBRC NE 0.
    RAISE SELID_NOT_FOUND.
  ENDIF.

  IF STATUS > MAX_STATUS.
    RAISE ILLEGAL_STATUS.
  ENDIF.
  g_text1 = diag_text_1.
  g_text2 = diag_text_2.
  g_title = warning_title.
  G_FLAG_ALV = ALV.
  GL-TITLE  = TITLE.
  g_noframe = no_frame.

  GL-STATUS = STATUS.
  GL-NO_INTERVALS = NO_INTERVALS.
  GL-JUST_DISPLAY = JUST_DISPLAY.
  IF CURRENT_INFO-KIND = 'F'.
    GL-NO_NFIE = 'X'.
  ELSE.
    CLEAR GL-NO_NFIE.
  ENDIF.
  IF NOT PFKEY IS INITIAL.
     G_PFKEY-PFKEY = PFKEY-PFKEY.
     G_PFKEY-PROGRAM = PFKEY-PROGRAM.
  ELSE.
    CLEAR:  GL-PFKEYPROG, G_PFKEY.
  ENDIF.
  IF FRAME_TEXT NE SPACE.
    MAIN_T = NARROW_T = FRAME_TEXT.
  ELSE.
    MAIN_T = NARROW_T = TEXT-FRM.
  ENDIF.
  last_as_sub = as_sub.
  last_tree_id = tree_id.
  as_sub = as_subscreen.
  if as_subscreen ne space.
     first_call = 'X'.
     g_flag_show_sels = 'X'.
  endif.
  perFORM FILL_COMPare
            using    current_info-field_sel
            CHANGING COMPare_old.
* COMP_OLD = CURRENT_INFO-FIELD_SEL.

  IF AS_WINDOW NE SPACE.
    GL-KIND = 'P'.
    GL-X = START_col.
    GL-Y = START_row.
  ELSE.
    CLEAR: GL-KIND, GL-X, GL-Y.
  ENDIF.

  IF WHERE_CLAUSES IS REQUESTED.
    L_EXP_PARS-TWHERE = 'X'.
  ENDIF.
  IF EXPRESSIONS IS REQUESTED.
    L_EXP_PARS-TEXPR = 'X'.
  ENDIF.
  IF FIELD_RANGES IS REQUESTED.
    L_EXP_PARS-TRANGE = 'X'.
  ENDIF.
  IF NOT FCODE_TAB[] IS INITIAL.
     G_FCODE[] = FCODE_TAB[].
  ELSE.
    CLEAR G_FCODE[].
  ENDIF.
  IF Tree_id NE CURRENT_INFO-SELID or
* save-key wird bei 'Abbrechen ohne Sichern' geputzt
     save_key is initial and not CURRENT_INFO-FIELD_SEL is initial.
*  bei anderer Selid Tree neu erzeugen
     tree_id = current_info-selid.
     clear nodes_tab.
     refresh nodes_tab.
     clear_tables = 'X'.
  else.
* aber vielleicht haben sich die ausgewählten Felder geändert.
     node_key[] = save_key[].
     perform set_expanded_nodes tables node_key.
  endif.
  DESCRIBE TABLE CURRENT_INFO-FIELD_SEL LINES SY-TFILL.
  IF SY-TFILL = 0.

    show_tree = 'X'.
    PERFORM GET_FIELDS_AND_VALUES TABLES FIELDS_TAB
                                  USING  SELECTION_ID
                                         WHERE_CLAUSES
                                         EXPRESSIONS
                                         FIELD_RANGES
                                         L_EXP_PARS.
  ELSE.
    PERFORM MODIFY_CURR_DECIMALS USING CURRENT_INFO-FIELD_SEL.
    PERFORM GET_VALUES_AND_REACT  TABLES FIELDS_TAB
                                  USING  SELECTION_ID
                                         WHERE_CLAUSES
                                         EXPRESSIONS
                                         FIELD_RANGES
                                         L_EXP_PARS.
  ENDIF.

  NUMBER_OF_ACTIVE_FIELDS = CURRENT_INFO-ACTNUM.
  refresh fields_not_selected.
  fields_not_selected[] = f_not_selected[].
  CLEAR G_FLAG_ALV.
  clear g_int_noint.
  if as_sub eq space and docking is not initial.
    call method docking->free.
    clear:  docking, flag_first, tree.
  endif.
  if as_sub is initial.
    as_sub = last_as_sub.
    tree_id = last_tree_id.
  endif.
ENDFUNCTION.
