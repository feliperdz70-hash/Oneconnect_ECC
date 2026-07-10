FUNCTION ZONFM_FREE_SELECTIONS_INIT.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(KIND) DEFAULT 'T'
*"     VALUE(EXPRESSIONS) TYPE  RSDS_TEXPR OPTIONAL
*"     VALUE(FIELD_RANGES_INT) TYPE  RSDS_TRANGE OPTIONAL
*"     VALUE(FIELD_GROUPS_KEY) LIKE  RSDSQCAT STRUCTURE  RSDSQCAT
*"         OPTIONAL
*"     VALUE(RESTRICTION) TYPE  SSCR_RESTRICT_DS OPTIONAL
*"     VALUE(ALV) OPTIONAL
*"     VALUE(CURR_QUAN_PROG) LIKE  SY-REPID DEFAULT SY-CPROG
*"     VALUE(CURR_QUAN_RELATION) TYPE  SSCR_CURR_QUAN_T OPTIONAL
*"  EXPORTING
*"     VALUE(SELECTION_ID) LIKE  RSDYNSEL-SELID
*"     VALUE(WHERE_CLAUSES) TYPE  RSDS_TWHERE
*"     VALUE(EXPRESSIONS) TYPE  RSDS_TEXPR
*"     VALUE(FIELD_RANGES) TYPE  RSDS_TRANGE
*"     VALUE(NUMBER_OF_ACTIVE_FIELDS) LIKE  SY-TFILL
*"  TABLES
*"      TABLES_TAB STRUCTURE  RSDSTABS OPTIONAL
*"      TABFIELDS_NOT_DISPLAY STRUCTURE  RSDSFIELDS OPTIONAL
*"      FIELDS_TAB STRUCTURE  RSDSFIELDS OPTIONAL
*"      FIELD_DESC STRUCTURE  FLDCONVERT OPTIONAL
*"      FIELD_TEXTS STRUCTURE  RSDSTEXTS OPTIONAL
*"      EVENTS STRUCTURE  RSDSEVENTS OPTIONAL
*"      EVENT_FIELDS STRUCTURE  RSDSEVFLDS OPTIONAL
*"      FIELDS_NOT_SELECTED STRUCTURE  RSDSFIELDS OPTIONAL
*"      NO_INT_CHECK STRUCTURE  RSDSTABS OPTIONAL
*"      ALV_QINFO STRUCTURE  LVC_S_QINF OPTIONAL
*"  EXCEPTIONS
*"      FIELDS_INCOMPLETE
*"      FIELDS_NO_JOIN
*"      FIELD_NOT_FOUND
*"      NO_TABLES
*"      TABLE_NOT_FOUND
*"      EXPRESSION_NOT_SUPPORTED
*"      INCORRECT_EXPRESSION
*"      ILLEGAL_KIND
*"      AREA_NOT_FOUND
*"      INCONSISTENT_AREA
*"      KIND_F_NO_FIELDS_LEFT
*"      KIND_F_NO_FIELDS
*"      TOO_MANY_FIELDS
*"      DUP_FIELD
*"      FIELD_NO_TYPE
*"      FIELD_ILL_TYPE
*"      DUP_EVENT_FIELD
*"      NODE_NOT_IN_LDB
*"      AREA_NO_FIELD
*"--------------------------------------------------------------------

  DATA L_INT TYPE I.
  DATA L_SUBRC LIKE SY-SUBRC.
  DATA L_TABIX  LIKE SY-TABIX.
  DATA L_FIELD_SEL_T LIKE CURRENT_INFO-FIELD_SEL.
  DATA L_ANY_JOINS.
  DATA L_NODES TYPE NODE_T_TYPE.
  DATA L_CLIENT_POS LIKE SY-TABIX.
  data l_curr_quan type sscr_curr_quan.

  DATA: BEGIN OF L_TABS OCCURS 10,
          TABLENAME LIKE RSDSTABS-PRIM_TAB,
        END   OF L_TABS.

  DATA: BEGIN OF L_KEY,
          SELID LIKE RSDYNSEL-SELID,
          TABLENAME LIKE RSDSTABS-PRIM_TAB,
        END   OF L_KEY.

  DATA: BEGIN OF L_JOINS OCCURS 10,
          TABLENAME LIKE RSDSTABS-PRIM_TAB,
        END   OF L_JOINS.

  DATA: BEGIN OF L_EXPR_FI_INDICES OCCURS 10.
          INCLUDE STRUCTURE EXPR_FI_INDICES.
  DATA: END   OF L_EXPR_FI_INDICES.

  DATA L_CURRTAB TYPE TABS_TYPE.
  DATA L_N_T TYPE N_2_T_LINE_TYPE.
*
  DATA: lt_range TYPE rsds_trange.
  DATA: ls_range LIKE LINE OF lt_range,
        ls_frange LIKE LINE OF ls_range-frange_t.
  DATA  L_FRANGE LIKE LINE OF L_FIELD_SEL_T.
  DATA: it_dfies TYPE TABLE OF dfies WITH HEADER LINE,
        L_TABFIELDS_NOT_DISPLAY TYPE RSDSFIELDS.

  FIELD-SYMBOLS: <L_FRANGE> LIKE LINE OF L_FIELD_SEL_T.
* -------------------------------------------------------------------- *
  refresh: field_desc_g, field_tab_g, f_not_selected, t_not_display.
  clear: p_red, p_yellow, p_green, p_light, p_light5.
  CLEAR CURRENT_INFO.
  IF NOT FIELD_GROUPS_KEY IS INITIAL.
    CURRENT_INFO-KIND = 'G'.
*   Sachgebiet
    CURRENT_INFO-QU_KEY = FIELD_GROUPS_KEY.
    IF FIELD_GROUPS_KEY-DBNA NE SPACE.
* Zunächst: alle Knoten
      PERFORM FILL_NOTA USING    FIELD_GROUPS_KEY-DBNA
                        CHANGING L_NODES
                                 CURRENT_INFO-NOTA.
    ENDIF.
  ELSEIF KIND NE 'T' AND KIND NE 'F'.
    RAISE ILLEGAL_KIND.
  ELSE.
    CURRENT_INFO-KIND = KIND.
  ENDIF.

  IF KIND = 'T' AND TABFIELDS_NOT_DISPLAY IS REQUESTED.
    T_NOT_DISPLAY[] = TABFIELDS_NOT_DISPLAY[].
  ENDIF.

  IF KIND = 'F'.
* DDIC + nicht DDIC Felder
    DESCRIBE TABLE FIELDS_TAB LINES SY-TFILL.
    field_tab_g[] = fields_tab[].
    field_desc_g[] = field_desc[].
    f_not_selected[] = fields_not_selected[].
    IF SY-TFILL = 0 AND ALV IS INITIAL.
      RAISE KIND_F_NO_FIELDS.
    ENDIF.
  ENDIF.
  if not alv is initial.
    refresh g_alv_qinfo.
    class IF_SALV_C_TOOLTIP definition load.
    if IF_SALV_C_TOOLTIP=>TYPE_EXCEPTION = '1'.
      g_alv_qinfo[] = alv_qinfo[].
    endif.
    perform fill_alv_parameters using expressions
                                      alv.
  endif.

  DESCRIBE TABLE TABLES_TAB LINES SY-TFILL.
  IF SY-TFILL = 0.
    CASE KIND.
      WHEN 'F'.
*       Tables_Tab aufbauen
        CLEAR TABLES_TAB.
        LOOP AT FIELDS_TAB.
          MOVE FIELDS_TAB-TABLENAME TO TABLES_TAB-PRIM_TAB.
          COLLECT TABLES_TAB.
        ENDLOOP.
      WHEN 'G'.
        PERFORM QU_AREA_TABLES TABLES   TABLES_TAB
                               USING    FIELD_GROUPS_KEY
                               CHANGING L_SUBRC.
        CASE L_SUBRC.
          WHEN 0.
          WHEN 1.               " Sachgebiet nicht da
            RAISE AREA_NOT_FOUND.
          WHEN 2.               " Inkonsistentes Sachgebiet
            RAISE INCONSISTENT_AREA.
          WHEN 4.               " Feld nicht in DDIC
            RAISE FIELD_NOT_FOUND.
          WHEN 8.               " Feld nicht in DDIC
            RAISE AREA_NO_FIELD.
        ENDCASE.
      WHEN OTHERS.
        RAISE NO_TABLES.
    ENDCASE.
  ENDIF.

  LOOP AT TABLES_TAB.
    CLEAR L_TABS.
    IF TABLES_TAB-SEC_TAB = SPACE.
      IF FIELD_GROUPS_KEY-DBNA EQ SPACE.
        MOVE TABLES_TAB-PRIM_TAB TO L_TABS-TABLENAME.
      ELSE.
        READ TABLE CURRENT_INFO-NOTA                        "#EC *
               WITH KEY LDBNODE = TABLES_TAB-PRIM_TAB
               INTO L_N_T
               BINARY SEARCH.
        IF SY-SUBRC = 0.
          MOVE L_N_T-STRUCTURE TO L_TABS-TABLENAME.
          COLLECT L_N_T-LDBNODE INTO L_NODES.
        ELSE.
          RAISE NODE_NOT_IN_LDB.
        ENDIF.
      ENDIF.
      IF TABLES_TAB-PRIM_FNAME NE SPACE OR
               TABLES_TAB-SEC_FNAME NE SPACE.
        RAISE FIELDS_NO_JOIN.
      ENDIF.
    ELSE.
      READ TABLE L_JOINS WITH KEY
             tablename = TABLES_TAB-PRIM_TAB BINARY SEARCH.
      IF SY-SUBRC NE 0.
        L_TABIX = SY-TABIX.
        MOVE: L_TABS-TABLENAME TO L_JOINS-TABLENAME.
        INSERT L_JOINS INDEX L_TABIX.
        MOVE 'X' TO L_ANY_JOINS.
      ENDIF.

      CLEAR L_INT.
      IF TABLES_TAB-PRIM_FNAME NE SPACE.
        ADD 1 TO L_INT.
      ENDIF.
      IF TABLES_TAB-SEC_FNAME NE SPACE.
        ADD 2 TO L_INT.
      ENDIF.

      IF FIELD_GROUPS_KEY-DBNA EQ SPACE.
        MOVE TABLES_TAB-SEC_TAB TO L_TABS-TABLENAME.
      ELSE.
        READ TABLE CURRENT_INFO-NOTA                      "#EC *
               WITH KEY LDBNODE = TABLES_TAB-SEC_TAB
               INTO L_N_T
               BINARY SEARCH.
        IF SY-SUBRC = 0.
          MOVE L_N_T-STRUCTURE TO L_TABS-TABLENAME.
          COLLECT L_N_T-LDBNODE INTO L_NODES.
        ELSE.
          RAISE NODE_NOT_IN_LDB.
        ENDIF.
      ENDIF.
      CASE L_INT.
        WHEN 1.                  " nur PRIM_FNAME ungleich SPACE
          RAISE FIELDS_INCOMPLETE.
        WHEN 2.                  " nur SEC_FNAME ungleich SPACE
          PERFORM CHECK_FIELD_IN_DDIC USING
                     L_TABS-TABLENAME TABLES_TAB-SEC_FNAME L_SUBRC.
          IF L_SUBRC NE 0.
            RAISE FIELD_NOT_FOUND.
          ENDIF.
        WHEN 3.                  " zwei Feldnamen angegeben.
          PERFORM CHECK_FIELD_IN_DDIC USING
                     L_TABS-TABLENAME   TABLES_TAB-SEC_FNAME L_SUBRC.
          IF L_SUBRC NE 0.
            RAISE FIELD_NOT_FOUND.
          ENDIF.
      ENDCASE.
    ENDIF.
    IF NOT L_TABS-TABLENAME IS INITIAL.
      PERFORM CHECK_TAB_IN_DDIC USING L_TABS-TABLENAME
                                CHANGING L_CLIENT_POS L_SUBRC.
    ENDIF.
    IF L_SUBRC NE 0.
      RAISE TABLE_NOT_FOUND.
    ENDIF.
    COLLECT L_TABS.

    IF KIND = 'T'.
      REFRESH IT_DFIES.
      CALL FUNCTION 'DDIF_NAMETAB_GET'
        EXPORTING
          TABNAME           = TABLES_TAB-PRIM_TAB
        TABLES
          DFIES_TAB         = IT_DFIES
        EXCEPTIONS
          NOT_FOUND         = 1
          OTHERS            = 2.

      LOOP AT IT_DFIES.
        IF IT_DFIES-INTTYPE = 'g' OR IT_DFIES-INTTYPE = 'y'.
          L_TABFIELDS_NOT_DISPLAY-TABLENAME = IT_DFIES-TABNAME.
          L_TABFIELDS_NOT_DISPLAY-FIELDNAME = IT_DFIES-FIELDNAME.
          APPEND L_TABFIELDS_NOT_DISPLAY TO T_NOT_DISPLAY.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

  ADD 1 TO LAST_SELID-INIT-NUMBER.
  SELECTION_ID = LAST_SELID-INIT.
  MOVE SELECTION_ID TO: L_KEY-SELID.

  LOOP AT FIELDS_TAB WHERE TABLENAME NE SPACE.
     PERFORM CHECK_FIELD_IN_DDIC USING
                  FIELDS_TAB-TABLENAME FIELDS_TAB-FIELDNAME L_SUBRC.
     IF L_SUBRC NE 0.
       RAISE FIELD_NOT_FOUND.
     ENDIF.
  ENDLOOP.

  IF FIELD_GROUPS_KEY-DBNA EQ SPACE.
    LOOP AT L_TABS.
      L_TABIX = SY-TABIX.
      READ TABLE CURRENT_INFO-TABS INTO L_CURRTAB
           WITH KEY tablename = L_TABS-TABLENAME.
      CHECK SY-SUBRC NE 0.

      MOVE: L_TABIX TO L_CURRTAB-NUMBER,
            L_TABS-TABLENAME TO L_CURRTAB-TABLENAME.
      READ TABLE FIELDS_TAB WITH KEY tablename = L_TABS-TABLENAME.
      IF SY-SUBRC = 0.
        MOVE 'X' TO L_CURRTAB-SELECTED.
      ELSE.
        CLEAR L_CURRTAB-SELECTED.
      ENDIF.
      APPEND L_CURRTAB TO CURRENT_INFO-TABS.
    ENDLOOP.
*    SORT CURRENT_INFO-TABS BY TABLENAME.
  ELSE.
    LOOP AT CURRENT_INFO-NOTA INTO L_N_T.
      READ TABLE L_NODES WITH KEY table_line = L_N_T-LDBNODE
           TRANSPORTING NO FIELDS.
      IF SY-SUBRC NE 0.
        DELETE CURRENT_INFO-NOTA.
      ENDIF.
    ENDLOOP.
  ENDIF.

  SORT L_TABS BY TABLENAME.
  sort l_nodes.

  CURRENT_INFO-TEXTS = FIELD_TEXTS[].
  SORT CURRENT_INFO-TEXTS BY TABLENAME FIELDNAME.

  CURRENT_INFO-EVENTS = EVENTS[].
  CURRENT_INFO-EVENT_FIELDS = EVENT_FIELDS[].
  SORT CURRENT_INFO-EVENT_FIELDS BY TABLENAME FIELDNAME.

  CURRENT_INFO-RESTRICT = RESTRICTION.
  CURRENT_INFO-CURR_QUAN_PROG = CURR_QUAN_PROG.

  DELETE ADJACENT DUPLICATES FROM CURRENT_INFO-EVENT_FIELDS
                  COMPARING TABLENAME FIELDNAME.
  IF SY-SUBRC = 0.
    RAISE DUP_EVENT_FIELD.
  ENDIF.

* Feld in keiner Tabelle
  LOOP AT FIELDS_TAB.
    IF FIELDS_TAB-TABLENAME = SPACE.
      IF KIND NE 'F'.
        RAISE FIELD_NOT_FOUND.
      ENDIF.
      clear l_tabix.
      PERFORM HANDLE_NON_DD_FIELD TABLES FIELD_DESC
                               using l_tabix
                               CHANGING FIELDS_TAB
                                        L_FIELD_SEL_T
                                        L_SUBRC.
      CASE L_SUBRC.
        WHEN 0.
        WHEN 10.
          MODIFY FIELDS_TAB.
        WHEN 1.
          RAISE DUP_FIELD.
        WHEN 2.
          RAISE FIELD_NO_TYPE.
        WHEN 3.
          RAISE FIELD_ILL_TYPE.
      ENDCASE.
      CONTINUE.
    ENDIF.
    READ TABLE L_TABS WITH KEY
              tablename = FIELDS_TAB-TABLENAME BINARY SEARCH.
    IF SY-SUBRC NE 0.
      DELETE FIELDS_TAB.
    ENDIF.

    REFRESH IT_DFIES.
    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        TABNAME              = FIELDS_TAB-TABLENAME
        FIELDNAME            = FIELDS_TAB-FIELDNAME
      TABLES
        DFIES_TAB            = IT_DFIES
      EXCEPTIONS
        NOT_FOUND            = 1
        INTERNAL_ERROR       = 2
        OTHERS               = 3.

    READ TABLE IT_DFIES INDEX 1.
    IF IT_DFIES-INTTYPE = 'g' OR IT_DFIES-INTTYPE = 'y'.
      RAISE FIELD_ILL_TYPE.
    ENDIF.
  ENDLOOP.

  CLEAR TABS_AND_JOINS.
  MOVE LAST_SELID-INIT TO TABS_AND_JOINS-SELID.
  LOOP AT TABLES_TAB.
    MOVE-CORRESPONDING TABLES_TAB TO TABS_AND_JOINS.
    COLLECT TABS_AND_JOINS.
  ENDLOOP.

  SORT TABS_AND_JOINS BY SELID PRIM_TAB SEC_TAB.

  MOVE: SELECTION_ID TO CURRENT_INFO-SELID,
        L_ANY_JOINS TO CURRENT_INFO-ANY_JOINS.

  IF CURRENT_INFO-KIND = 'G'.
* Importiert Query-Sachgebiet nach vollem Key
* P_SUBRC:  1: Sachgebiet nicht da
*           2: Inkonsistentes Sachgebiet
*           4: Feld nicht in Dictionary
*           8: Kein Sachgebietsfeld in einer ausgewählten Tabelle
    PERFORM QU_IMPORT_AREA TABLES   L_TABS
                                    FIELDS_TAB
                           USING    FIELD_GROUPS_KEY
                           CHANGING L_NODES
                                    CURRENT_INFO-GROUPS
                                    L_SUBRC.

    CASE L_SUBRC.
      WHEN 0.
      WHEN 1.               " Sachgebiet nicht da
        RAISE AREA_NOT_FOUND.
      WHEN 2.               " Inkonsistentes Sachgebiet
        RAISE INCONSISTENT_AREA.
      WHEN 4.               " Feld nicht in DDIC
        RAISE FIELD_NOT_FOUND.
      WHEN 8.               " Feld nicht in DDIC
        RAISE AREA_NO_FIELD.
    ENDCASE.
  ENDIF.

  IF FIELD_RANGES_INT IS NOT SUPPLIED.
    PERFORM BUILD_FIELD_SEL TABLES L_EXPR_FI_INDICES
                          USING    EXPRESSIONS
                          CHANGING L_FIELD_SEL_T
                                   L_SUBRC.
    CASE L_SUBRC.
      WHEN 0.
      WHEN 4.               " Nicht unterstützter Ausdruck
        RAISE EXPRESSION_NOT_SUPPORTED.
      WHEN 8.               " Inkorrekter Ausdruck
        RAISE INCORRECT_EXPRESSION.
    ENDCASE.
  ELSE.
*    CLEAR L_FIELD_SEL_T. REFRESH L_FIELD_SEL_T.
    LOOP AT FIELD_RANGES_INT INTO LS_RANGE.
      IF LS_RANGE-TABLENAME = 'RSDS_DUMMY'.     " ALV or 'F'
        CLEAR LS_RANGE-TABLENAME.
      ENDIF.
      LOOP AT ls_range-FRANGE_T INTO LS_FRANGE.
        READ table L_FIELD_SEL_T assigning <l_frange>
                  with key TABLENAME = LS_RANGE-TABLENAME
                           FIELDNAME = LS_FRANGE-FIELDNAME.
        if sy-subrc = 0.
         <l_frange>-FIELDSEL  = LS_FRANGE-SELOPT_T.
        else.
          L_FRANGE-TABLENAME = LS_RANGE-TABLENAME.
          L_FRANGE-FIELDNAME = LS_FRANGE-FIELDNAME.
          L_FRANGE-FIELDSEL  = LS_FRANGE-SELOPT_T.
          insert L_FRANGE into table L_FIELD_SEL_T.
        endif.
      ENDLOOP.
    ENDLOOP.
  ENDIF.

* Löscht veraltete Einträge aus FIELDS_TAB
  PERFORM CLEANUP_P_FIELDS TABLES   FIELDS_TAB L_EXPR_FI_INDICES
                           USING    CURRENT_INFO-KIND
                           CHANGING L_FIELD_SEL_T
                                    EXPRESSIONS.

  DESCRIBE TABLE FIELDS_TAB LINES SY-TFILL.
  IF SY-TFILL = 0.
    IF CURRENT_INFO-KIND = 'F'.
      RAISE KIND_F_NO_FIELDS_LEFT.
    ENDIF.
  ELSEIF SY-TFILL > MAX_FIELDS.
    RAISE TOO_MANY_FIELDS.
  ENDIF.

  DESCRIBE TABLE L_FIELD_SEL_T LINES NUMBER_OF_ACTIVE_FIELDS.
  MOVE NUMBER_OF_ACTIVE_FIELDS TO CURRENT_INFO-ACTNUM.

  PERFORM SORT_AND_FILL_FIELD_SEL TABLES   FIELDS_TAB
                                  USING    CURRENT_INFO-KIND
                                           L_FIELD_SEL_T
                                  CHANGING CURRENT_INFO-FIELD_SEL.

  IF WHERE_CLAUSES IS REQUESTED.
    PERFORM GEN_WHERE_CLAUSES USING    CURRENT_INFO
                              CHANGING WHERE_CLAUSES
                                       L_SUBRC.
  ENDIF.

  IF FIELD_RANGES IS REQUESTED.
    PERFORM BUILD_TRANGE USING    CURRENT_INFO-FIELD_SEL
                                  CURRENT_INFO-ANY_JOINS
                         CHANGING FIELD_RANGES.
  ENDIF.
  loop at curr_quan_relation into l_curr_quan.
*   prüfen ob alle Felder auch vorhanden.
  endloop.
  current_info-curr_quan_relation = curr_quan_relation.
  current_info-no_int_check   =  NO_INT_CHECK[].
  APPEND CURRENT_INFO TO SELID_INFO.
  SORT SELID_INFO BY SELID.


ENDFUNCTION.
