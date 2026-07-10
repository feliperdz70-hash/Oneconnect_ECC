* Routinen zur Behandlung freier Abgrenzungen auf Selektionsbildern
* Alle Routinen werden aus RSDBRUNT oder RSDBSPxx gerufen
REPORT ZONPG_RSDBSPDS MESSAGE-ID DB.

* DYNS-Zeugs im COMMON PART
INCLUDE RSDBCOM4.

* SUBTY-Equates
INCLUDE RSDBCSTY.

* Gesharet mit RSDBRUNT
INCLUDE RSDBC1XX.

* Ikonen
INCLUDE <ICON>.

* -------------------------------------------------------------------- *

FORM FILL_DYNS_FIELDS_FROM_TEXPR TABLES P_FIELDS STRUCTURE RSDSFIELDS
                                 USING  P_TEXPR TYPE RSDS_TEXPR.

  DATA L_EXPR TYPE RSDS_EXPR.
  DATA L_RSDSEXPR LIKE RSDSEXPR.

  REFRESH P_FIELDS.

  LOOP AT P_TEXPR INTO L_EXPR.
    MOVE L_EXPR-TABLENAME TO P_FIELDS-TABLENAME.
    LOOP AT L_EXPR-EXPR_TAB INTO L_RSDSEXPR WHERE FIELDNAME NE SPACE.
      MOVE L_RSDSEXPR-FIELDNAME TO P_FIELDS-FIELDNAME.
      COLLECT P_FIELDS.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                          "  FILL_DYNS_FIELDS_FROM_TEXPR
* Besorgt die Inhalte der dynamischen Abgrenzungen.
FORM BREPI_DYN  TABLES P_DESC   STRUCTURE RSDYNBREPI
                       P_VALUES STRUCTURE RSSELDYN
                USING  P_M_OR_W
                       P_LDBNAME LIKE TRDIR-LDBNAME.

  DATA L_EDIT.

  DATA: L_LDBNAME(2).
  DATA: L_NODES LIKE NODE2STRUC OCCURS 0 WITH HEADER LINE.

  L_LDBNAME = P_LDBNAME(2).
  REFRESH: P_DESC, P_VALUES.

  DESCRIBE TABLE DYNS_FIELDS LINES SY-TFILL.
  CHECK SY-TFILL > 0.

  IF P_M_OR_W = 'W'.
    L_EDIT = 'X'.
  ENDIF.
  IF L_LDBNAME(2) NE 'D$' AND P_LDBNAME NE '$$'
                      AND P_LDBNAME NE SPACE
                     AND P_LDBNAME NE '__'.
      SELECT LDBNAME LDBNODE STRUCTURE
               INTO CORRESPONDING FIELDS OF TABLE L_NODES
               FROM LDBN
               WHERE LDBNAME = P_LDBNAME
               AND ( TYPE    = 'S' OR TYPE = 'T' )
               ORDER BY PRIMARY KEY.

  ENDIF.
  IF DYN_SEL-TRANGE[] IS NOT INITIAL AND DYN_SEL-TEXPR IS INITIAL.
    CALL FUNCTION 'FREE_SELECTIONS_RANGE_2_EX'
         EXPORTING
              FIELD_RANGES = DYN_SEL-TRANGE
         IMPORTING
              EXPRESSIONS  = DYN_SEL-TEXPR
         EXCEPTIONS
              OTHERS       = 1.
  ENDIF.

  CALL FUNCTION 'RS_DS_INT_BREPI'
       EXPORTING
            P_TEXPR    = DYN_SEL-TEXPR
            P_EDIT     = L_EDIT
       TABLES
            P_FIELDS   = DYNS_FIELDS
            P_VALUES   = P_VALUES
            P_DESC     = P_DESC
            P_NODES_TO_STRUCT = L_NODES
       EXCEPTIONS
            others = 0.
*           EXP_FIELD_NOT_IN_FIELD_TAB = 01
*           EXPRESSION_NOT_SUPPORTED   = 02
*           INCORRECT_EXPRESSION       = 03
*           EXP_FIELD_NOT_IN_TABLE     = 04.

ENDFORM.
* Text für Drucktaste
FORM SET_SSCRTEXTS_DYNSEL using p_quick like smp_dyntxt-quickinfo
                          CHANGING P_TEXT LIKE SSCRTEXTS-DYNSEL.

  DATA L_TEXT LIKE SMP_DYNTXT.

  MOVE: ICON_FENCING TO L_TEXT-ICON_ID,
        'Free selections'(270) TO L_TEXT-TEXT.
                                                       "#EC *
  if p_quick ne space.
* anderer Tooltip
     l_text-quickinfo = p_quick.
  endif.
  IF DYNS-ACTIVE_SELECTIONS > 0.
    WRITE DYNS-ACTIVE_SELECTIONS TO L_TEXT-ICON_TEXT(2).
    MOVE 'active'(271) TO L_TEXT-ICON_TEXT+3.           "#EC *
  ENDIF.
  P_TEXT = L_TEXT.

ENDFORM.                      " SET_SSCRTEXTS_DYNSEL
* ----------- Dynamische Selektionen --------------------------------- *
FORM DYNS_SET_STATUS USING P_STATUS P_PROG LIKE SY-REPID.

  DYNS-SELSCREEN_FLAG = P_STATUS.
  DYNS-PROGRAM        = P_PROG.

ENDFORM.                                        " DYNS_SET_STATUS.
* Dialog für dynamische Selektionen
FORM DYNS_DIALOG TABLES P_SSCR STRUCTURE RSSCR
                 using p_flag
                 CHANGING P_FCODE LIKE SSCRFIELDS-UCOMM.

  DATA: L_TITLE LIKE SY-TITLE.
  DATA: L_SUBRC LIKE SY-SUBRC.

  DATA L_VARIDYN LIKE GL_VARIDYN.
  data: l_window, l_return.
  DATA L_SPFLAG.
  data l_sub.
  IF DYNS-TABS = SPACE.
    PERFORM DYNS_INIT TABLES   P_SSCR
                               DYNS_NODES
                               DYNS_FIELDS
                      CHANGING DYN_SEL-TEXPR
                               DYNS-TABS
                               DYNS-FIELDS_SELECTED
                               DYNS-ACTIVE_SELECTIONS
                               L_VARIDYN
                               L_SUBRC.
    CASE L_SUBRC.
      WHEN 0.
      WHEN 1.
        MESSAGE E722.           " Should not occur
      WHEN OTHERS.
        MESSAGE E723.
    ENDCASE.
  ENDIF.

* save title
  MOVE SY-TITLE TO L_TITLE.
  l_window = space.
  CASE P_FCODE.
    WHEN 'DYNS'.
      IF SY-SUBTY Z SUBTY_NO_SELSCREEN AND SY-SUBTY O SUBTY_TO_SAPSPOOL.
        L_SPFLAG = 'X'.
        SUBTRACT SUBTY_TO_SAPSPOOL FROM SY-SUBTY.
      ENDIF.
      l_sub = 'X'.
      CALL FUNCTION 'FREE_SELECTIONS_DIALOG'             "#EC *
              EXPORTING
                SELECTION_ID            = DYNS-SELID
                TITLE                   = SY-TITLE
                AS_WINDOW               = l_window
*               FRAME_TEXT              = 'Test !!!!!!!!!!!!!'
*               STATUS                  = 1
                NO_INTERVALS            = 'X'
                as_subscreen            = l_sub
              IMPORTING
                WHERE_CLAUSES           = DYN_SEL-CLAUSES
                EXPRESSIONS             = DYN_SEL-TEXPR
                FIELD_RANGES            = DYN_SEL-TRANGE
                NUMBER_OF_ACTIVE_FIELDS = DYNS-ACTIVE_SELECTIONS
              TABLES
                FIELDS_TAB              = DYNS_FIELDS
              EXCEPTIONS
                INTERNAL_ERROR          = 10
                NO_ACTION               = 02
                SELID_NOT_FOUND         = 10
*               ERROR_MESSAGE           = 10
                OTHERS                  = 10.
      L_SUBRC = SY-SUBRC.
      IF L_SPFLAG NE SPACE.
        ADD SUBTY_TO_SAPSPOOL TO SY-SUBTY.
      ENDIF.
      check p_flag eq space.
      SET SCREEN SY-DYNNR.
      SET TITLEBAR '%_T' WITH L_TITLE.  "#EC *
*
      IF L_SUBRC NE 0.
        CASE L_SUBRC.
          WHEN 1.                        " NO_TABLES/FIELDS_SELECTED
            REFRESH DYN_SEL-CLAUSES.
            DYNS-ACTIVE_SELECTIONS = 0.
            MESSAGE S724.
          WHEN 2.                        " NO_ACTION
            MESSAGE S737.
          WHEN OTHERS.                   " Interner Fehler
            MESSAGE S732.
        ENDCASE.
        EXIT.
      ENDIF.

      DESCRIBE TABLE DYNS_FIELDS LINES SY-TFILL.
      IF SY-TFILL > 0.
        DYNS-FIELDS_SELECTED = 'X'.
      ELSE.
        DYNS-FIELDS_SELECTED = SPACE.
      ENDIF.

  ENDCASE.

  CLEAR: SY-UCOMM, P_FCODE.

ENDFORM.                               " DYNS_DIALOG.
* Initialisierung dynamische Selektionen
* P_SUBRC: 0   O.K.
*          1   Keine 'D'-Zeilen in %_SSCR
*          2   Exception in RS_DS_INT_INIT_LDB
FORM DYNS_INIT TABLES    P_SSCR STRUCTURE RSSCR
                         P_NODES STRUCTURE RSDFSNODES
                         P_FIELDS   STRUCTURE RSDSFIELDS
               CHANGING  P_TEXPR TYPE RSDS_TEXPR
                         P_TABS            LIKE DYNS-TABS
                         P_FIELDS_SELECTED LIKE DYNS-FIELDS_SELECTED
                         P_SELACTIVE LIKE DYNS-ACTIVE_SELECTIONS
                         P_VARIDYN LIKE GL_VARIDYN
                         P_SUBRC LIKE SY-SUBRC.

  P_SUBRC = 0.

  DESCRIBE TABLE P_NODES LINES SY-TFILL.
  IF SY-TFILL = 0.
    P_TABS = SPACE.
    P_SUBRC = 1.
    LOOP AT P_SSCR WHERE KIND = 'D'.
      MOVE P_SSCR-DBFIELD TO P_NODES-LDBNODE.
      APPEND P_NODES.
      P_SUBRC = 0.
    ENDLOOP.
  ENDIF.

  DYNS-INITIALIZED = 'X'.

  CHECK P_SUBRC = 0.
  if flag_query_active eq space.
     CALL FUNCTION 'RS_DS_INT_INIT_LDB'                    "#EC *
            EXPORTING    P_TEXPR          = P_TEXPR
                         P_SUBMODE        = SCREEN_PROGS-SUBMODE
            IMPORTING
                         P_TWHERE         = DYN_SEL-CLAUSES
                         P_SELID          = DYNS-SELID
                         P_TEXPR          = P_TEXPR
                         P_ACTNUM         = P_SELACTIVE
                         P_TRANGE         = DYN_SEL-TRANGE
            TABLES       P_NODES          = P_NODES
                         P_FIELDS         = P_FIELDS
                         P_VARIDYN        = P_VARIDYN
            EXCEPTIONS   TABLE_NOT_FOUND  = 3
                         NO_TABLES        = 4
                         OTHERS           = 5.

  else.
     CALL FUNCTION 'RS_DS_INT_INIT_LDB'                    "#EC *
            EXPORTING   P_TEXPR          = P_TEXPR
                        P_SUBMODE        = SCREEN_PROGS-SUBMODE
                        p_ldbpg          = screen_progs-ldbpg
            IMPORTING    P_TWHERE         = DYN_SEL-CLAUSES
                         P_SELID          = DYNS-SELID
                         P_TEXPR          = P_TEXPR
                         P_ACTNUM         = P_SELACTIVE
                         P_TRANGE         = DYN_SEL-TRANGE
            TABLES       P_NODES          = P_NODES
                         P_FIELDS         = P_FIELDS
                         P_VARIDYN        = P_VARIDYN
            EXCEPTIONS   TABLE_NOT_FOUND  = 3
                         NO_TABLES        = 4
                         OTHERS           = 5.

  endif.

  IF SY-SUBRC NE 0.
    P_SUBRC = 2.
    REFRESH: P_NODES, P_FIELDS, P_TEXPR.
  ENDIF.

  DESCRIBE TABLE P_FIELDS LINES SY-TFILL.
  IF SY-TFILL > 0.
    P_FIELDS_SELECTED = 'X'.
  ELSE.
    P_FIELDS_SELECTED = SPACE.
  ENDIF.

  DESCRIBE TABLE P_NODES LINES SY-TFILL.
  IF SY-TFILL > 0.
    P_TABS = 'X'.
  ELSE.
    P_TABS = SPACE.
  ENDIF.

ENDFORM.                                " DYNS_INIT

* Routinen zum Prozessieren des Selektionsbildes
* (FREE_SELECTIONS_DIALOG)
FORM LINK_CURR_SCREEN USING    P_PROG LIKE SY-REPID
                               P_FORM LIKE SY-XFORM
                      CHANGING P_SUBRC LIKE SY-SUBRC.
  PERFORM (P_FORM) IN PROGRAM (P_PROG) CHANGING CURRENT_SCREEN P_SUBRC.
ENDFORM.                                        " LINK_CURR_SCREEN
***********************************************************************
form get_dyns tables p_dyns_fields structure rsdsfields
              using  p_dyn_sel-clauses type RSDS_TWHERE
                     p_dyn_sel-texpr type rsds_texpr
                     p_dyn_sel-trange type RSDS_TRANGE
                     p_DYNS-ACTIVE_SELECTIONS like sy-tfill.

 dyns_fields[] = p_dyns_fields[].
 dyn_sel-clauses = p_dyn_sel-clauses.
 dyn_sel-texpr = p_dyn_sel-texpr.
 dyn_sel-trange = p_dyn_sel-trange.
 DYNS-ACTIVE_SELECTIONS = p_DYNS-ACTIVE_SELECTIONS.
endform.                              "get_dyns
***********************************************************************
form set_query_active using p_flag.
  flag_query_active = p_flag.
endform.
