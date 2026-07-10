FUNCTION-POOL RSSYSTDB MESSAGE-ID DB.

TABLES: TRDIR.                         " Reihenfolge wichtig !
TABLES D020T.
TABLES DD01L.

TYPE-POOLS SYDB0.

INCLUDE zonpg_RSDBCOM1.
* Equates für HEAD-FLAG1
INCLUDE zonpg_RSDBCSTY.
* Beschreibt jeweils ein Bild
DATA G_SSCR LIKE RSSCR OCCURS 20 WITH HEADER LINE.
* Bildspezifische Daten
DATA: BEGIN OF GL_SCREEN,
        NUMBER LIKE SY-DYNNR,
        TYPE,
        SELOPTS,           " any SELECT-OPTIONS ?
        PARAMS,            " any PARAMETERS ?
        ANY_OBJECT,        " any object to be displayed ?
        IX LIKE SY-TABIX,            " Index in SSCR des Indexparameters
        IX_SIMPLE,                   " Einzelsuchhilfe
        VAL_REQ,                     " VALUE-REQUEST ?
        HLP_REQ,                     " HELP-REQUEST  ?
        LAST_SSCR LIKE G_SSCR,       " gemerkte SSCR-Zeile
        MAX_POS TYPE I,
        NESTING_LEVEL TYPE I,
        NOINT,
      END   OF GL_SCREEN.
* Letzte Zeile: Hängt ab von Schachtelungstiefe
DATA: LAST_LINE LIKE SY-INDEX.
* Struktur für die global gültigen Daten (soll mal alles enthalten)
DATA: BEGIN OF GLOBAL,
        PROG LIKE SY-REPID,
*        LDBPG LIKE SY-LDBPG,
        FIRST_SCREEN LIKE SY-DYNNR,
        DYNSEL_ACTIVE,     " DYNAMIC SELECTIONS ?
        HASH(10) TYPE N,
      END   OF GLOBAL.
* Positionen
DATA: BEGIN OF POS,
        LOW         TYPE I,                 " absolut,
        HIGH        TYPE I,                 " absolut,
        TOTEXT      TYPE I,                 " absolut,
        LAST        TYPE I,                 " absolut,
      END   OF POS.
* Zeile für OK-Code
CONSTANTS OK_CODE_LINE LIKE D021S-LINE VALUE 255.
* Einrücken für Rahmen
CONSTANTS: FRAME_MARGIN TYPE I VALUE 2.     " Einrücken für Rahmen
DATA: FIRST_FRAME TYPE I.              " Nr des ersten Rahmens
DATA: FRAME_DEPTH TYPE I.              "aktuelle Schachtelungstiefe

* Schachtelungstiefen der schmalen Rahmenblöcke
DATA: BEGIN OF NESTING OCCURS 5,
        NUMB LIKE RSSCR-NUMB,
        DEPTH TYPE I,
        LEVEL TYPE I,
      END   OF NESTING.
* Struktur der lokalen Blocktabelle (CLEANUP_SSCR)
TYPES: BEGIN OF BL_LINE_TYPE,
          NUMB LIKE RSSCR-NUMB,
          CURR_DEPTH TYPE I,
          MAX_DEPTH  TYPE I,
          SSCRIX LIKE SY-TABIX,
          NON_EMPTY,
        END   OF BL_LINE_TYPE.
TYPES: BL_TYPE TYPE BL_LINE_TYPE OCCURS 5.
* Konstanten fuer die Generierung der Dynprosourcen
CONSTANTS: SCRN_BEGIN LIKE SY-INDEX VALUE  0,
           SCRN_END   LIKE SY-INDEX VALUE 200,
           MAX_TEXT_LENGTH TYPE I VALUE 30,
           max_radio_text_length type i value 34,
           TO_LENGTH TYPE I VALUE 5,
           OPT_PUSH_LENGTH TYPE I VALUE 2,
           INTERNAL_OPT_PUSH_LENGTH TYPE I VALUE 40,
           PUSH_LENGTH TYPE I VALUE 3,
           INTERNAL_PUSH_LENGTH TYPE I VALUE 40.

* Der aktuelle Eintrag aus der Tabelle g_sscr liegt innerhalb
* einer SELECTION-SCREEN BEGIN OF ... END OF LINE Anweisung
DATA  INLINE.
data last_name like rsscr-name.
*
* Mindestens ein Feld aus Tabelle g_sscr, das zwischen BEGIN OF und
* END OF LINE liegt wurde auch in die Tabelle f aufgenommen
DATA  ANY_FIELD.
* Tabelle der Help-Request-Parameter + Texte
DATA: BEGIN OF HELP_TAB OCCURS 10,
        NAME(30),                             " Feldname
        NAME_FOR_MOD LIKE RSSCR-NAME,        " Name für Modul
      END OF   HELP_TAB.
* Tabelle der Parameter mit VALUE CHECK (Prueftabelle)
DATA: BEGIN OF PAR_CHECKTAB OCCURS 0,
        NAME LIKE RSSCR-NAME,
        CHECKTAB LIKE DFIES-CHECKTABLE,
      END   OF PAR_CHECKTAB.
* Tabelle der Parameter mit VALUE CHECK (Festwerte)
DATA: BEGIN OF PAR_FIXVAL OCCURS 0,
        NAME LIKE RSSCR-NAME,
        DD07V LIKE DD07V OCCURS 0,
      END   OF PAR_FIXVAL.

*
* Tabelle der für dynamische Selektionen vorgesehenen Tabellen
DATA: BEGIN OF DYNSEL_TABLES OCCURS 5,
        TABLENAME LIKE RSDSTABS-PRIM_TAB,
      END   OF DYNSEL_TABLES.
* Tabelle für Radiobuttons
DATA: BEGIN OF RADIO_GROUPS OCCURS 5,
        GROUP LIKE RSSCR-MATCHCODE,
        AUTH  LIKE D021S-AUTH,
        PARAMS LIKE RSSCR-NAME OCCURS 5,
      END   OF RADIO_GROUPS.
* Anfangszeilen der Blöcke
DATA: BEGIN OF BLOCKLINES OCCURS 10,
        BLOCKNUM TYPE SYDB0_BLOCKNUM,
        FIELD_TABIX LIKE SY-TABIX,
        NARROW,
      END   OF BLOCKLINES.

* Tabelle der FIELD-Anweisungen für einen Block.
DATA: BEGIN OF BLOCK_T OCCURS 20.
        INCLUDE STRUCTURE T.
DATA: END   OF BLOCK_T.

* Blockreferenzen: Feldeigenschaften nur einmal besorgen!
DATA: BEGIN OF BLOCK_REF OCCURS 10,
        BLOCK_NAME_ORI LIKE RSSCR-NAME,
        NUMBER_ORI     LIKE RSSCR-NUMB,
        F              LIKE D021S OCCURS 20,
      END   OF BLOCK_REF.

* Kontrollfeld: Stellt Überlappungen fest
DATA SUPPLIED(130).

* ENTRYPOINT:
*             1:
*                  Einstieg in GEN_SEL_SCREEN,
*                  Aufruf aus GEN_SELECTION_SCREEN(RSDBRUNT),
*                  'im-Fluge-Generierung' und GENERATE REPORT,
*                  keine MESSAGE A..., kein Sammeln der Fehlermeldungen,
*                  aber Returncode 16.
*             2:
*                  Einstieg in GENERATE_ALL_SCREENS,
*                  Aufruf aus RSDBGENA ...
*                  Sammeln der Fehlermeldungen in GEN_MESSAGE
DATA: ENTRYPOINT TYPE I.
* Globaler Returncode
DATA: EXITFLAG.                        " Keine A-Message aber EXIT
data: begin of comfipar occurs 0,
        fieldname like d021s-fnam,
        parname   like rsscr-name,
        kind      like rsscr-kind,
      end of comfipar.
* Struktur GEN_MESSAGE für Meldungen bei Generierung
* per RSDBGENA ...
INCLUDE zonpg_RSDBCOM3.

types: begin of ts_props_for_field,
        fieldname type d021s-fnam,
        proplist type PROP_LIST,
       end of ts_props_for_field.

types tt_props_for_fields type hashed table of ts_props_for_field
        with unique key fieldname.

constants: scrp_ostyle_default type scrpostyle value '00'.

* Um UNPACK zu vermeiden.
FIELD-SYMBOLS <F-GRP4> TYPE N.
* Konstante für Contextmenu
constants: ctxmenu(11) value '%_SSCR_%_S_'.

class CL_ABAP_CHAR_UTILITIES definition load.
*-----------------------------------------------------------------

************************************************************************
*                       Unterprogramme                                *
************************************************************************

*-----------------------------------------------------------------*
* Diese Routine generiert das Selektionsbild des Reports neu.     *
* Es findet keine Pruefung statt, ob eine Generierung noetig ist. *
* Die muss der Aufrufer leisten.                                  *
*-----------------------------------------------------------------*

FORM GENERATE_SEL_SCREEN " TABLES P_SSCR STRUCTURE RSSCR
                         USING    VALUE(P_DYNNR) LIKE SY-DYNNR
                                  P_TYPE LIKE D020S-TYPE
                                  P_NESTING_LEVEL TYPE I
                                  P_NOINT TYPE C
                                  P_SUBRC LIKE SY-SUBRC.

  DATA TABIX LIKE SY-TABIX.
  DATA SUBRC LIKE SY-SUBRC.
  DATA HEXNULL TYPE X.

  FIELD-SYMBOLS <F>.

  P_SUBRC = 0.

* Initialisieren, da mehrfacher Aufruf möglich
  PERFORM INITIALIZE_1_SCREEN_DATA.

  GL_SCREEN-NUMBER = P_DYNNR.

  ASSIGN F-DIDX TO <F-DIDX> TYPE 'X'.

  KEY-PROGRAM = GLOBAL-PROG.
  KEY-SCREEN = P_DYNNR.
  if key-program(2) eq 'AQ' and key-program+4(1) = '='.
* Hilfsprogramm für ADHOC-Query, Bild der LDB als Subscreen
    p_type = 'J'.
  endif.
  PERFORM FILL_D020S USING P_DYNNR P_TYPE.
  IF NOT P_TYPE IS INITIAL.
    SCR_RUNT_INFO-TYPE = P_TYPE.
    GL_SCREEN-TYPE = P_TYPE.
  ENDIF.

* Kommmentare in die Ablauflogik, bevor g_sscr modifiziert wird.
  REFRESH T. CLEAR T.
  PERFORM GEN_COMMENT.

  GL_SCREEN-NESTING_LEVEL = P_NESTING_LEVEL.

  PERFORM CLEANUP_SSCR TABLES G_SSCR USING SPACE.

  IF P_TYPE = 'J'.
    PERFORM PREPARE_SUBSCREEN USING P_NOINT.
  ENDIF.

* Aufbau der Dynpro_Source
  PERFORM CHECK_DYNPRO_EXISTS USING 'TERMINATE'.
  IF EXITFLAG NE SPACE.
    P_SUBRC = 4.
    EXIT.
  ENDIF.
  PERFORM GEN_SELECTION_SCREEN.  " TABLES P_SSCR.
* Generierung ueber RSDBGENB: Fehler in den Angaben
  IF EXITFLAG = 'X'.
    P_SUBRC = 4.
    EXIT.
  ENDIF.
* Abspeicherung der Dynprosource
* Beim Update ist vorheriges Löschen obsolet
    delete dynpro key.
    EXPORT DYNPRO D020S F T M ID KEY.

* Dynprogenerierung
    if sy-batch is initial.
      PERFORM GENERATE_DYNPRO USING KEY.
      SUBRC = SY-SUBRC.
    else.
      subrc = 0.
    endif.
    PERFORM ERROR_AND_LOG USING SUBRC KEY.
    IF SUBRC NE 0.
      P_SUBRC = 4.
      EXIT.
    ENDIF.

* Im Fehlerfall: lieber nichts mehr tun
* Generierung ueber RSDBGENA: Fehler in den Angaben
  IF EXITFLAG = 'X'.
    P_SUBRC = 4.
    EXIT.
  ENDIF.

ENDFORM.                               " GENERATE_SEL_SCREEN


*----------------------------------------------------------------------*
* Generierung der Selektionsbilder bei GENERATE REPORT und im Fluge   *
* zur Laufzeit (in eigenem Rollbereich). Wird aus
* GEN_SELECTION_SCREEN(RSDBSPGS) gerufen.                              *
*----------------------------------------------------------------------*
FORM GEN_SEL_SCREEN TABLES   P_SSCR STRUCTURE RSSCR
                    USING    VALUE(P_REPID) LIKE SY-REPID
                             P_ENTRYPOINT TYPE I
                             VALUE(P_HEAD) LIKE RHEAD
                    CHANGING P_DYNNR LIKE D020S-DNUM
                             P_SUBRC LIKE SY-SUBRC.

  DATA L_SUBRC LIKE SY-SUBRC.
  DATA L_LINE  LIKE SY-TABIX VALUE 1.
  DATA L_STANDARD.
  DATA L_STANDARD_DONE.
  DATA L_TYPE LIKE D020S-TYPE.
  DATA L_ERROR.
  DATA L_TFILL LIKE SY-TFILL.
  DATA L_HASH(16) TYPE P.
  DATA L_FLAG1 TYPE X.            " HEAD-FLAG1
  DATA L_HEAD LIKE RHEAD OCCURS 1.
  DATA L_NESTING_LEVEL TYPE I.
  DATA L_NOINT.
  DATA L_HASH_PROG TYPE I.

  RANGES L_NUMBERS FOR SY-DYNNR.

  FIELD-SYMBOLS <L_F>.

* Fehlerbehandlung
  ENTRYPOINT = P_ENTRYPOINT.
* Keine Dynprogenerierung, wenn in TRDIR kein Eintrag vorhanden ist.
  SELECT SINGLE * FROM TRDIR WHERE NAME = P_REPID.
  IF SY-SUBRC NE 0.
    P_SUBRC = 16.
    EXIT.
  ENDIF.
* Initialisiere die globalen Daten
  PERFORM INITIALIZE_GLOBAL_DATA.
* Compute hash number of program name
  PERFORM HASH_STRING(RSDBSPGS) USING    P_REPID
                                CHANGING L_HASH_PROG.
  GLOBAL-HASH = L_HASH_PROG.
* HEXNULL-Zeile in SSCR entfernen und sortieren!
  PERFORM SHAPE_SSCR_SIMPLE(RSDBRUNT) TABLES P_SSCR.

  DESCRIBE TABLE P_SSCR LINES L_TFILL.
  SCREEN_INFO-LINES = L_TFILL.
  PERFORM HASH_SSCR(RSDBSPGS) TABLES   P_SSCR
                              CHANGING L_HASH.
  SCREEN_INFO-HASH = L_HASH.

  PERFORM ISOLATE_DYNS_TABLES TABLES P_SSCR.

  PERFORM RESOLVE_BLOCK_REFS(RSDBSPBL) TABLES P_SSCR.

* Aufruf der Dynprogenerierung.
  MOVE: P_REPID TO GLOBAL-PROG.

* Präpariere l_numbers für DEL_SCREENS
  MOVE: 'E'  TO L_NUMBERS-SIGN,
        'EQ' TO L_NUMBERS-OPTION.
*
  IF P_REPID NE P_HEAD-PGNAME.
    LOAD REPORT P_REPID PART 'HEAD' INTO L_HEAD.
    IF SY-SUBRC NE 0.
      P_SUBRC = 16.
      EXIT.
    ENDIF.
    READ TABLE L_HEAD INDEX 1 INTO P_HEAD.
  ENDIF.
  L_FLAG1 = P_HEAD-FLAG1.

  DO.
    PERFORM ISOLATE_SCREENS TABLES   P_SSCR G_SSCR
                            CHANGING GL_SCREEN-NUMBER
                                     L_TYPE
                                     L_LINE
                                     L_STANDARD
                                     L_NESTING_LEVEL
                                     L_NOINT
                                     L_SUBRC.
    IF L_SUBRC NE 0.
      EXIT.
    ENDIF.
    CHECK NOT
      ( GL_SCREEN-NUMBER = '1000' AND L_FLAG1 Z PGHD_F1_S1000 ).

    PERFORM GENERATE_SEL_SCREEN    " TABLES P_SSCR
                                USING    GL_SCREEN-NUMBER
                                         L_TYPE
                                         L_NESTING_LEVEL
                                         L_NOINT
                                         L_SUBRC.
    CASE L_SUBRC.
      WHEN 0.
        MOVE GL_SCREEN-NUMBER TO L_NUMBERS-LOW.
        APPEND L_NUMBERS.
*       APPEND GL_SCREEN-NUMBER TO SCR_OK.
      WHEN 1.           " leeres Bild
      WHEN 4.           " Fehler. Nummer in GL_SCREEN-NUMBER
        L_ERROR = 'X'.
        IF P_ENTRYPOINT NE 2.
          EXIT.
        ENDIF.
    ENDCASE.
  ENDDO.

* Setzen des Returncodes
  IF L_ERROR = SPACE.
    P_SUBRC = 0.
    PERFORM DEL_SEL_SCREENS(RSDBSPGS) TABLES L_NUMBERS
                                      USING  P_REPID.
  ELSE.
    P_SUBRC = 16.
    P_DYNNR = GL_SCREEN-NUMBER.
  ENDIF.

ENDFORM.                                     " GEN_SEL_SCREEN

*----------------------------------------------------------------------*
* Generierung der Selektionsbilder                                    *
* wird aus RSDBGENA gerufen                                            *
*----------------------------------------------------------------------*
FORM GEN_SEL_SCREEN_4_RSDBGENA TABLES   P_SSCR STRUCTURE RSSCR
                               USING    VALUE(P_REPID) LIKE SY-REPID
                                        P_HEAD LIKE RHEAD
                               CHANGING P_SUBRC LIKE SY-SUBRC
                                        P_MESSTAB TYPE SCR_MESS_T_TYPE.

  PERFORM GEN_SEL_SCREEN TABLES   P_SSCR
                         USING    P_REPID 2 P_HEAD
                         CHANGING GEN_MESSAGE-DYNNR P_SUBRC.

  MOVE: MESSTAB TO P_MESSTAB.

ENDFORM.                               "  GEN_SEL_SCREEN_4_RSDBGENA
* Holt aus globaler SSCR (P_SSCR_IN) den Teil heraus (P_SSCR_OUT),
* der zu einem Bild gehört.
* Setzt bei P_LINE (In) auf und liefert in P_LINE (Out) die
* erste nicht mehr zu diesem Bild gehörige Zeilennummer zurück
* P_SUBRC: 0: noch Bild gefunden.
*          1: keins mehr da.
* Verlässt sich darauf, dass Eintraege zu einem Bild hintereinander
* liegen.
FORM ISOLATE_SCREENS TABLES   P_SSCR_IN  STRUCTURE RSSCR
                              P_SSCR_OUT STRUCTURE RSSCR
                     CHANGING P_DYNNR LIKE SY-DYNNR
                              P_TYPE  LIKE D020S-TYPE
                              P_LINE LIKE SY-TABIX
                              P_STANDARD TYPE C
                              P_NESTING_LEVEL TYPE I
                              P_NOINT TYPE C
                              P_SUBRC LIKE SY-SUBRC.

  DATA L_TABIX LIKE SY-TABIX.
  DATA L_PLINE_SET.

  REFRESH P_SSCR_OUT.
  P_TYPE = 'S'.

  LOOP AT P_SSCR_IN FROM P_LINE INTO P_SSCR_OUT.
    L_TABIX = SY-TABIX.
    IF L_TABIX = P_LINE.         " Erste Zeile: BEGIN OF SCREEN ?
      IF P_SSCR_OUT-KIND = 'R' AND P_SSCR_OUT-APPENDAGE = 'A'.
        P_DYNNR = P_SSCR_OUT-NAME+4(4).
        IF P_SSCR_OUT-MISCELL(1) NE SPACE.
          P_TYPE = P_SSCR_OUT-MISCELL(1).
        ENDIF.
        P_STANDARD = SPACE.
        IF P_SSCR_OUT-MISCELL = 'J'.
          P_NESTING_LEVEL = P_SSCR_OUT-OFFSET.
          IF P_SSCR_OUT-FLAG1 O SSCR_F1_NOIN.
            P_NOINT = 'X'.
          ELSE.
            CLEAR P_NOINT.
          ENDIF.
        ENDIF.
        CONTINUE.
      ELSE.
        P_DYNNR = '1000'.
        P_STANDARD = 'X'.
      ENDIF.
    ELSEIF P_SSCR_OUT-KIND = 'R'.
*     Standardbild wird gerade erzeugt, Nächstes Bild
      IF P_STANDARD NE SPACE.
        P_LINE = L_TABIX.
        L_PLINE_SET = 'X'.
        EXIT.
      ENDIF.
      P_LINE = L_TABIX + 1.
      L_PLINE_SET = 'X'.
      EXIT.
    ENDIF.
    APPEND P_SSCR_OUT.
  ENDLOOP.

  IF L_TABIX = 0.
    P_SUBRC = 1.
  ELSE.
    P_SUBRC = 0.
    IF L_PLINE_SET = SPACE.
      P_LINE = L_TABIX + 1.
    ENDIF.
  ENDIF.

ENDFORM.                                " ISOLATE_SCREENS
* Bricht ab bzw. stellt Protokolltext in interne Tabelle
FORM ERROR_AND_LOG USING SUBRC P_KEY STRUCTURE KEY.

  CHECK ENTRYPOINT = 2.

  MOVE: 'OK'        TO GEN_MESSAGE-CODE,
        KEY-SCREEN  TO GEN_MESSAGE-DYNNR.
  IF SUBRC NE 0.
    MOVE 'NOTOK'    TO GEN_MESSAGE-CODE. " Fehler in der Generierung
    MOVE: DYNPRO_MESSAGE TO GEN_MESSAGE-MESSAGE,
          DYNPRO_LINE    TO GEN_MESSAGE-DYNPRO_LINE,
          DYNPRO_WORD    TO GEN_MESSAGE-DYNPRO_WORD.
  ENDIF.
  APPEND GEN_MESSAGE TO MESSTAB.

ENDFORM.                               "  ERROR_AND_LOG

FORM PREPARE_SUBSCREEN USING P_NOINT TYPE C.

  DATA L_INT TYPE I.

  GL_SCREEN-NOINT = P_NOINT.

  IF P_NOINT IS INITIAL.
    SUBTRACT FRAME_MARGIN FROM: FRAME-LENGTH, FRAME-LAST_POS_PLUS_1.

    L_INT = GL_SCREEN-NESTING_LEVEL * FRAME_MARGIN.

    SUBTRACT L_INT FROM: FRAME-MAX_LENG_SELOPT,
                         FRAME-TEXT_LENGTH, POS-LOW,
                         POS-TOTEXT, POS-HIGH, POS-LAST.
    L_INT = L_INT * 2.
    SUBTRACT L_INT FROM: FRAME-LENGTH, FRAME-LAST_POS_PLUS_1.
  ELSE.
    FRAME-LENGTH = POS-TOTEXT + 1 + PUSH_LENGTH + 1
                   - INITCOLN.
    FRAME-LAST_POS_PLUS_1 = INITCOLN + FRAME-LENGTH - 1.
    L_INT = GL_SCREEN-NESTING_LEVEL * FRAME_MARGIN.

    SUBTRACT L_INT FROM: FRAME-TEXT_LENGTH, POS-LOW, POS-TOTEXT,
                         POS-HIGH, POS-LAST,
                         FRAME-LAST_POS_PLUS_1,
                         FRAME-LENGTH.
   ENDIF.

  FRAME-MAX_LENG_PARAM = FRAME-LAST_POS_PLUS_1 - POS-LOW - 1.
  IF FRAME-MAX_LENG_PARAM > MAX_LENG_PARAM.
    FRAME-MAX_LENG_PARAM = MAX_LENG_PARAM.
  ENDIF.

ENDFORM.                                        " PREPARE_SUBSCREEN

* Initialisierung globaler Daten bei jedem Neueinstieg
FORM INITIALIZE_GLOBAL_DATA.

  CLEAR: EXITFLAG,
         GLOBAL,
         MESSTAB.

  REFRESH: BLOCK_REF, DYNSEL_TABLES.

  ASSIGN F-GRP4 TO <F-GRP4> TYPE 'N'.

ENDFORM.                               " INITIALIZE_GLOBAL_DATA.
* Initialisiert alles für ein Bild.
FORM INITIALIZE_1_SCREEN_DATA.

  CLEAR SCR_RUNT_INFO.
  MOVE '%_' TO SCR_RUNT_INFO-PREFIX.
  MOVE 'N' TO: SCR_RUNT_INFO-SELOPTS.
  MOVE GLOBAL-DYNSEL_ACTIVE TO SCR_RUNT_INFO-DYNSEL.
  MOVE VERSION      TO SCR_RUNT_INFO-VERSION.
  MOVE '%'          TO SCR_RUNT_INFO-TYPE.
  MOVE GLOBAL-HASH  TO SCR_RUNT_INFO-HASH.
  MOVE '_%_%_%_%_%_%_' TO SCR_RUNT_INFO-UNUSED.

  CLEAR: GL_SCREEN,
         ANY_FIELD,
         CURLINE,
         CURCOLN,
         INITCOLN,
         INLINE,
         FRAME,
         FRAME_DEPTH,
         FIRST_FRAME,
         GEN_MESSAGE,
         SUPPLIED.

  REFRESH: RADIO_GROUPS, FRAME, F, T, M, NESTING,
           BLOCK_T, BLOCKLINES, HELP_TAB, PAR_CHECKTAB, PAR_FIXVAL,
           comfipar.

  MOVE '101' TO : CURAUTH, CURLANF.

  POS-LOW  =  INITCOLN + 2 +
              MAX_TEXT_LENGTH + 1 +
              OPT_PUSH_LENGTH + 1.
  POS-TOTEXT =  POS-LOW +
              MAX_LENG_SELOPT + 1.
  POS-HIGH =  POS-LOW +
              MAX_LENG_SELOPT + 1 +
              TO_LENGTH + 1.
*  POS-LAST  = POS-HIGH +
*              MAX_LENG_SELOPT + 1 +
*              PUSH_LENGTH + 1 + 1.
  pos-last   = 120.
  FRAME-LENGTH = POS-LAST +  FRAME_MARGIN.
  FRAME-LAST_POS_PLUS_1 = POS-LAST + 1.
  MOVE MAX_TEXT_LENGTH TO FRAME-TEXT_LENGTH.
  MOVE MAX_LENG_SELOPT TO FRAME-MAX_LENG_SELOPT.
  MOVE MAX_LENG_PARAM  TO FRAME-MAX_LENG_PARAM.
  LAST_LINE       = SCRN_END - 1.

ENDFORM.
* Versorgt Dynpro-Header
FORM FILL_D020S USING P_DYNNR LIKE SY-DYNNR
                      P_TYPE  LIKE D020S-TYPE.

* Voruebergehend
  constants MILI_KSCRPOS type x value '08'.



  CLEAR D020S.
  MOVE GLOBAL-PROG TO D020S-PROG.
  MOVE P_DYNNR TO: D020S-DNUM, D020S-FNUM.
  MOVE P_TYPE TO D020S-TYPE.
  MOVE SCRN_END TO D020S-NOLI.
  MOVE POS-LAST TO D020S-NOCO.
  MOVE 'G' TO D020S-CUAN.
* Komprimierung, Rel. >= 3.0, keep Scroll Position
  D020S-MILI = MILI_COMPR + MILI_GE30 + MILI_KSCRPOS.

  MOVE SY-LANGU TO D020S-SPRA.
  CALL FUNCTION 'RS_DYNPRO_RELEASE_SET'
       EXPORTING
*            DYNPRO_RELEASE   = '4.02'
             dynpro_release   = '6.10'
       CHANGING
            DYNPRO_HEADER    = D020S
       EXCEPTIONS
            RELEASE_TOO_LOW  = 1
            RELEASE_TOO_HIGH = 2
            OTHERS           = 3.

  SCREEN_INFO-DYNNR = GL_SCREEN-NUMBER.
  d020s-cupo = screen_info.
ENDFORM.
* Löscht unsinnige Folgen von SSCR-Zeilen, z.B. END OF LINE
* unmittelbar hinter BEGIN OF LINE
FORM CLEANUP_SSCR TABLES P_SSCR STRUCTURE RSSCR
                  USING  P_SECOND_TIME.

  DATA L_BEG_TABIX LIKE SY-TABIX.
  DATA L_TABIX LIKE SY-TABIX.
  DATA L_ANY_FIELD.
  DATA L_DEPTH TYPE I.

  DATA: L_BLOCKS TYPE BL_TYPE.
  DATA: L_BL_LINE TYPE BL_LINE_TYPE.
  DATA: L_BL_LINE_2 TYPE BL_LINE_TYPE.

  DATA: BEGIN OF L_LINES OCCURS 10,
          TABIX LIKE SY-TABIX,
        END OF L_LINES.

  DATA: BEGIN OF L_SSCR OCCURS 50.
          INCLUDE STRUCTURE RSSCR.
  DATA: END   OF L_SSCR.
  DATA: L_CURR TYPE I.

  LOOP AT P_SSCR.
    L_TABIX = SY-TABIX.
* Vorsichtsmassnahme
    IF P_SSCR-FLAG2 O SSCR_F2_REFR AND GL_SCREEN-NUMBER NE '1000'.
      SET BIT BIT_SSCR_F2_REFR OF P_SSCR-FLAG2 TO 0.
      MODIFY P_SSCR TRANSPORTING FLAG2.
    ENDIF.
    CASE P_SSCR-KIND.
      WHEN 'L'.                                    " LINE
        CASE P_SSCR-APPENDAGE.
          WHEN 'A'.                                " BEGIN OF LINE
            MOVE SY-TABIX TO L_BEG_TABIX.
            CLEAR L_ANY_FIELD.
          WHEN 'E'.                                " END OF LINE
            IF L_ANY_FIELD = SPACE.
              WHILE L_BEG_TABIX LE L_TABIX.
                MOVE L_BEG_TABIX TO L_LINES-TABIX.
                APPEND L_LINES.
                ADD 1 TO L_BEG_TABIX.
              ENDWHILE.
            ENDIF.
        ENDCASE.
      WHEN 'P'.
        IF P_SSCR-FLAG1 Z SSCR_F1_NODI.            " Parameter
          MOVE 'X' TO L_ANY_FIELD.
          IF P_SSCR-FLAG1 O SSCR_F1_IXST AND L_DEPTH > 0.
            L_CURR = L_BL_LINE-CURR_DEPTH + 1.
            IF L_CURR > L_BL_LINE-MAX_DEPTH.
             L_BL_LINE-MAX_DEPTH = L_CURR.
            ENDIF.
            LOOP AT L_BLOCKS INTO L_BL_LINE_2.
              L_CURR = L_BL_LINE_2-CURR_DEPTH + 1.
                IF L_CURR > L_BL_LINE_2-MAX_DEPTH.
                  L_BL_LINE_2-MAX_DEPTH = L_CURR.
                  MODIFY L_BLOCKS FROM L_BL_LINE_2.
                ENDIF.
            ENDLOOP.
            APPEND P_SSCR TO L_SSCR.
          ENDIF.

          PERFORM SET_NON_EMPTY USING L_BL_LINE L_BLOCKS P_SECOND_TIME.
        ENDIF.
      WHEN 'S'.                                    " Select-Option
        IF P_SSCR-FLAG1 Z SSCR_F1_NODI.            " Parameter
          MOVE 'X' TO L_ANY_FIELD.
          PERFORM SET_NON_EMPTY USING L_BL_LINE L_BLOCKS P_SECOND_TIME.
        ENDIF.
      WHEN 'C'.                                    " Comment
        MOVE 'X' TO L_ANY_FIELD.
        PERFORM SET_NON_EMPTY USING L_BL_LINE L_BLOCKS P_SECOND_TIME.
      WHEN 'F'.                                    " Comment for field
        MOVE 'X' TO L_ANY_FIELD.
        PERFORM SET_NON_EMPTY USING L_BL_LINE L_BLOCKS P_SECOND_TIME.
      WHEN 'U'.                                    " ULINE
        MOVE 'X' TO L_ANY_FIELD.
        PERFORM SET_NON_EMPTY USING L_BL_LINE L_BLOCKS P_SECOND_TIME.
      WHEN 'H'.                                    " Pushbutton
        MOVE 'X' TO L_ANY_FIELD.
        PERFORM SET_NON_EMPTY USING L_BL_LINE L_BLOCKS P_SECOND_TIME.
      WHEN 'K'.                                    " Block
        IF P_SSCR-NAME+2(3) NE '%__'.     " Nur Rahmen wichtig
          CASE P_SSCR-APPENDAGE.
            WHEN 'A'.                        " BEGIN OF BLOCK
              IF L_DEPTH > 0.
                APPEND L_BL_LINE TO L_BLOCKS.
                LOOP AT L_BLOCKS INTO L_BL_LINE.
                  ADD 1 TO L_BL_LINE-CURR_DEPTH.
                  IF L_BL_LINE-CURR_DEPTH > L_BL_LINE-MAX_DEPTH.
                    L_BL_LINE-MAX_DEPTH = L_BL_LINE-CURR_DEPTH.
                  ENDIF.
                  MODIFY L_BLOCKS FROM L_BL_LINE.
                ENDLOOP.
              ELSE.
                CHECK P_SSCR-FLAG1 O SSCR_F1_NOIN
                      AND P_SSCR-FLAG1 Z SSCR_F1_SUBS.
              ENDIF.
              CLEAR L_BL_LINE.
              MOVE: P_SSCR-NUMB TO L_BL_LINE-NUMB,
                    L_TABIX TO     L_BL_LINE-SSCRIX.
              IF P_SSCR-FLAG1 O SSCR_F1_SUBS.
                PERFORM SET_NON_EMPTY
                        USING L_BL_LINE L_BLOCKS P_SECOND_TIME.
              ENDIF.
              L_DEPTH = L_DEPTH + 1.
            WHEN 'E'.                        " END OF BLOCK
              CHECK P_SSCR-NAME+2(3) NE '%__' AND L_DEPTH > 0.
              L_DEPTH = L_DEPTH - 1.
              IF P_SECOND_TIME = SPACE.
                IF L_BL_LINE-NON_EMPTY NE SPACE.
                  READ TABLE P_SSCR INDEX L_BL_LINE-SSCRIX INTO L_SSCR.
                  APPEND L_SSCR.
                  APPEND P_SSCR TO L_SSCR.
                ELSE.
                  MOVE: L_BL_LINE-SSCRIX TO L_LINES-TABIX.
                  APPEND L_LINES.
                  MOVE: L_TABIX TO L_LINES-TABIX.
                  APPEND L_LINES.
                ENDIF.
              ELSE.
                  MOVE: L_BL_LINE-NUMB TO NESTING-NUMB,
                        L_BL_LINE-MAX_DEPTH TO NESTING-DEPTH.
                  APPEND NESTING.
              ENDIF.
              CHECK L_DEPTH > 0.
              LOOP AT L_BLOCKS INTO L_BL_LINE.
                SUBTRACT 1 FROM L_BL_LINE-CURR_DEPTH.
                MODIFY L_BLOCKS FROM L_BL_LINE.
              ENDLOOP.
              READ TABLE L_BLOCKS INDEX L_DEPTH INTO L_BL_LINE.
              DELETE L_BLOCKS INDEX L_DEPTH.
          ENDCASE.
        ENDIF.
    ENDCASE.
  ENDLOOP.

  IF P_SECOND_TIME = SPACE.
    SORT L_LINES BY TABIX DESCENDING.
    LOOP AT L_LINES.
      DELETE P_SSCR INDEX L_LINES-TABIX.
    ENDLOOP.
    DESCRIBE TABLE L_SSCR LINES SY-TFILL.
    IF SY-TFILL NE 0.
      SORT L_SSCR BY NUMB.
      PERFORM CLEANUP_SSCR TABLES L_SSCR USING 'X'.
    ENDIF.
  ELSE.
    SORT NESTING BY NUMB.
  ENDIF.
ENDFORM.                                  " CLEANUP_SSCR.

FORM SET_NON_EMPTY USING P_BL_LINE TYPE BL_LINE_TYPE
                         P_BLOCKS TYPE BL_TYPE
                         P_SECOND_TIME.
  DATA L_BL_LINE TYPE BL_LINE_TYPE.

  CHECK P_BL_LINE-NON_EMPTY = SPACE AND P_SECOND_TIME = SPACE.

  MOVE 'X' TO P_BL_LINE-NON_EMPTY.

  LOOP AT P_BLOCKS INTO L_BL_LINE WHERE NON_EMPTY = SPACE.
    MOVE 'X' TO L_BL_LINE-NON_EMPTY.
    MODIFY P_BLOCKS FROM L_BL_LINE.
  ENDLOOP.
ENDFORM.                                 " SET_NON_EMPTY

*----------------------------------------------------------------------*
*               Generierung des Selektionsbildes 1000                 *
*----------------------------------------------------------------------*

FORM GEN_SELECTION_SCREEN." TABLES P_SSCR STRUCTURE RSSCR.

  DATA LINE    LIKE CURLINE.         " Hilfsfeld
  DATA L_TABIX LIKE SY-TABIX.
  data l_dyns.

  if D020S-TYPE NE 'J' and d020s-type ne 'W' and
     GLOBAL-DYNSEL_ACTIVE eq 'X'.
    clear g_sscr.
    g_sscr-name = '%B%_TAAA'.
    g_sscr-kind = 'K'.
    g_sscr-dbfield = '%_SUB%_CONTAINER'.
    g_sscr-appendage = 'A'.
    g_sscr-flag1 = sscr_f1_subs.
    g_sscr-length = 10. insert g_sscr index 1.
    g_sscr-appendage = 'E'.
    g_sscr-miscell = '%_FREESEL_%'.
    g_sscr-length = 0. insert g_sscr index 2.
  endif.
* Aus der Tabelle g_sscr wird die Tabelle F ( Feldeigenschaften )
* aufgebaut.
  clear last_name.
  LOOP AT G_SSCR.

    L_TABIX = SY-TABIX.
*   Bild zu groß ?
    IF          CURLINE EQ LAST_LINE AND INLINE LE SPACE
            AND (
                         G_SSCR-KIND NE 'C'
                     AND G_SSCR-KIND NE 'F'
                     AND G_SSCR-KIND NE 'U'
                     AND G_SSCR-KIND NE 'D'
                  OR G_SSCR-APPENDAGE = '1'
                )
       OR CURLINE GT LAST_LINE.

      IF G_SSCR-KIND NE 'L' AND G_SSCR-KIND NE 'B' AND
         G_SSCR-KIND NE 'O' AND G_SSCR-FLAG1 Z SSCR_F1_NODI.
            PERFORM SCREEN_TOO_LARGE.
            EXIT.
      ENDIF.
    ENDIF.

    CLEAR F.

    CASE G_SSCR-KIND.

*     Ein/Ausgabefelder
      WHEN 'P'.
        PERFORM GEN_SCREEN_P USING L_TABIX. " PARAMETERS
      WHEN 'S'.
        PERFORM GEN_SCREEN_S.          " SELECT-OPTIONS
*     Texte
      WHEN 'C'.
        PERFORM GEN_SCREEN_C.          " Kommentar
      WHEN 'F'.
        PERFORM GEN_SCREEN_F using l_tabix. " Kommentar fuer Feld
      WHEN 'U'.
        PERFORM GEN_SCREEN_U.          " ULINE
      WHEN 'K'.
        PERFORM GEN_SCREEN_K.          " Block
      WHEN 'H'.
        PERFORM GEN_SCREEN_H.          " Pushbutton
*     Bilddesign, es wird kein Feld generiert
      WHEN 'B'.
        CURCOLN = 2 + INITCOLN.        " Leerzeilen
        CURLINE = CURLINE + G_SSCR-APPENDAGE.
        CLEAR SUPPLIED.
      WHEN 'O'.
        CASE G_SSCR-OFFSET.
          WHEN 1000.                   " POS_LOW
            CURCOLN = POS-LOW.
          WHEN 2000.                   " POS_HIGH
            CURCOLN = POS-HIGH.
          when 3000.
            curcoln = pos-low - 3.
          WHEN 0.                      " Kein Offset
          WHEN OTHERS.
            CURCOLN = G_SSCR-OFFSET + 1    " Position angegeben
                      + INITCOLN.
        ENDCASE.
      WHEN 'L'.
        CASE G_SSCR-APPENDAGE.
*                         Begin of Line
          WHEN 'A'.
            MOVE 'X' TO INLINE.
            MOVE SPACE TO ANY_FIELD.
            CURCOLN = 2 + INITCOLN.
            ADD 1 TO CURLINE.
            CLEAR SUPPLIED.
*                         end of Line
          WHEN 'E'.
            MOVE SPACE TO INLINE.
            IF ANY_FIELD = SPACE.
              SUBTRACT 1 FROM CURLINE.
            ENDIF.
            CURCOLN = 2 + INITCOLN.
        ENDCASE.
    ENDCASE.

    IF EXITFLAG NE SPACE.
      EXIT.
    ENDIF.

    MOVE G_SSCR TO GL_SCREEN-LAST_SSCR.
    last_name = g_sscr-name.
  ENDLOOP.

  IF EXITFLAG NE SPACE.
    EXIT.
  ENDIF.

* Generiere Dummyfeld
  PERFORM GEN_RUNTIME_INFO USING CURLINE.

  CLEAR F.
  F-FNAM = 'SSCRFIELDS-UCOMM'.
  F-FLG1 = FLG1_FIELD + FLG1_DDIC.
  F-FLG2 = FLG2_FUNC.
  F-LINE = OK_CODE_LINE.
  F-COLN = 5.
  F-LTYP = 'O'.
  F-LENG = 70.
  <F-DIDX> = 70.
  F-TYPE = 'CHAR'.
  APPEND F.

* sort f by line coln.
* sort with regard to relative positions (e.g. Pushbuttons for Tabstrips
  CALL FUNCTION 'RS_SCRP_SORT_FIELDLIST'
*   EXPORTING
*     COMPRESS_RELATIVE_POSITIONS       = ' '
    TABLES
      f                                 = f.
  sort comfipar by fieldname.
  perform adjust_res1.
  D020S-BZMX = CURLINE + 1.
  D020S-BZBR = GL_SCREEN-MAX_POS.

* PBO-Module
  PERFORM GEN_PBO.

* PAI-Module
  CLEAR T.
  PERFORM GEN_PAI.
  PERFORM GEN_END_MODULES.
  PERFORM GEN_VALUE_MODULES.
  PERFORM GEN_HELP_MODULES.

ENDFORM.

*----------------------------------------------------------------------*
* Generiert Parameter und zugehoeriges Textfeld                       *
*----------------------------------------------------------------------*
FORM GEN_SCREEN_P USING TABIX.

  DATA L_F LIKE F.
  DATA L_SUBRC LIKE SY-SUBRC.
  DATA L_TABIX LIKE SY-TABIX.
  DATA L_LENGTH TYPE I.             " Textlänge
  DATA L_PLENGTH TYPE I.            " Vis. Länge des Parameters.
  DATA L_COLN LIKE D021S-COLN.
  data l_flag_left_right.
  data l_radio(4).
  data l_ucomm(20).
  field-symbols <L_F> structure d021s_res1 default f-res1.

  IF G_SSCR-FLAG1 O SSCR_F1_NODI.
    IF INLINE = SPACE.
*       Der Parameter liegt nicht zwischen BEGIN und END OF LINE.
      CURCOLN = 2 + INITCOLN.
    ENDIF.
    EXIT.
  ELSEIF G_SSCR-FLAG1 O SSCR_F1_IXST.   " AS INDEX STRUCTURE
* Es existiert mindestens ein PARAMETER
    MOVE 'X' TO GL_SCREEN-PARAMS.
    PERFORM SCREEN_P_AS_IX_STR USING TABIX.
    EXIT.
  ENDIF.

  IF INLINE = SPACE.
    ADD 1 TO CURLINE.
    CLEAR SUPPLIED.
  ENDIF.
* VALUE-REQUEST
  IF G_SSCR-FLAG2 O SSCR_F2_VRLO.
    MOVE 'X' TO GL_SCREEN-VAL_REQ.
  ENDIF.
* HELP-REQUEST
  IF G_SSCR-FLAG2 O SSCR_F2_HRLO.
    MOVE G_SSCR-NAME TO: HELP_TAB-NAME, HELP_TAB-NAME_FOR_MOD.
    APPEND HELP_TAB.
    MOVE 'X' TO GL_SCREEN-HLP_REQ.
  ENDIF.
* Es existiert mindestens ein PARAMETER
  MOVE 'X' TO GL_SCREEN-PARAMS.
* Radiobuttons
  IF G_SSCR-FLAG1 O SSCR_F1_RADI.
    if not g_sscr-matchcode+4(1) is initial.   " User-Command
      if g_sscr-matchcode+4(3) = '%UC'.
        l_radio = g_sscr-matchcode(4).
        l_ucomm = g_sscr-matchcode+7.
      elseif g_sscr-matchcode+3(3) = '%UC'.
        l_radio = g_sscr-matchcode(3).
        l_ucomm = g_sscr-matchcode+6.
      elseif g_sscr-matchcode+2(3) = '%UC'.
        l_radio = g_sscr-matchcode(2).
        l_ucomm = g_sscr-matchcode+5.
      elseif g_sscr-matchcode+1(3) = '%UC'.
        l_radio = g_sscr-matchcode(1).
        l_ucomm = g_sscr-matchcode+4.
      endif.
    else.
      l_radio = g_sscr-matchcode.
    endif.
    READ TABLE RADIO_GROUPS WITH KEY group = l_radio
                                     BINARY SEARCH.
    L_TABIX = SY-TABIX.
    IF SY-SUBRC = 0.
      APPEND G_SSCR-NAME TO RADIO_GROUPS-PARAMS.
      MODIFY RADIO_GROUPS INDEX L_TABIX.
    ELSE.
      MOVE: L_radio TO RADIO_GROUPS-GROUP,
            CURAUTH TO RADIO_GROUPS-AUTH.
      REFRESH RADIO_GROUPS-PARAMS.
      APPEND G_SSCR-NAME TO RADIO_GROUPS-PARAMS.
      INSERT RADIO_GROUPS INDEX L_TABIX.
      ADD 1 TO CURAUTH.
    ENDIF.
    CLEAR G_SSCR-MATCHCODE.
*  elseif g_sscr-matchcode(3) = '%UC'.
*       g_sscr-appendage = 'C'.
ENDIF.

  CLEAR F.
* Besorge Beschreibung des Parameters.
  MOVE G_SSCR-NAME TO F-FNAM.
  PERFORM FIELD_ATTRIBUTES CHANGING F.
* Listbox?
  if g_sscr-flag2 o sscr_f2_libo.
     F-DIDX+1(1) = g_sscr-offset.
     F-RES1 = RES1_DROPLIST.
     if not g_sscr-matchcode(1) is initial.   " User-Command
        l_ucomm = g_sscr-matchcode+3.
     endif.
     CLEAR G_SSCR-MATCHCODE.
  elseif g_sscr-matchcode(3) = '%UC'.
    g_sscr-appendage = 'C'.
  endif.
* Falls erst Text generiert werden muß: Rette F
  IF F-FILL NE 'C'.
    L_PLENGTH = F-DIDX+1(1).
    <l_f>-funccode = l_ucomm.
    IF INLINE = SPACE AND G_SSCR-APPENDAGE NE 'C' AND G_SSCR-FLAG1 Z
    SSCR_F1_RADI.
      L_F = F.
      l_flag_left_right = 'L'.
      CLEAR F.
    ENDIF.
  ELSE.
    L_PLENGTH = 1.
    G_SSCR-APPENDAGE = 'C'.
  ENDIF.

  if g_sscr-appendage = 'C'.
    if g_sscr-matchcode(3) = '%UC'.
      <l_f>-FUNCCODE = g_sscr-matchcode+3.
    endif.
  endif.

  IF INLINE = SPACE.
*   BEGIN/END OF LINE nicht aktiv
*   Bestimme mögliche Länge für Text.
    IF G_SSCR-APPENDAGE = 'C'.
      L_LENGTH = MAX_TEXT_LENGTH.
    ELSEif l_radio is initial.
      L_LENGTH = FRAME-TEXT_LENGTH + OPT_PUSH_LENGTH + 1.
      IF L_LENGTH > MAX_TEXT_LENGTH.
        L_LENGTH = MAX_TEXT_LENGTH.
      ENDIF.
    else.
      L_LENGTH = FRAME-TEXT_LENGTH + OPT_PUSH_LENGTH + 2.
      IF L_LENGTH > max_radio_text_length.
        L_LENGTH = max_radio_text_length.
      ENDIF.
    ENDIF.
    CURCOLN = 2 + INITCOLN.
    IF G_SSCR-APPENDAGE = 'C'.                    " CHECKBOX
      F-COLN = CURCOLN.
      F-LINE = CURLINE.
*     Generiere Parameterfeld
      MOVE: 'C'         TO F-FILL,
            CURAUTH     TO F-AUTH.
      MOVE 'PAR' TO F-GRP3.
      l_flag_left_right = 'R'.
      PERFORM ADD_OBJECT TABLES F CHANGING L_SUBRC.
      CHECK L_SUBRC = 0.
*     APPEND F.
      CLEAR F.
      ADD: 1 TO CURAUTH,
           2 TO CURCOLN.
      CLEAR F-FILL.
    elseif G_SSCR-FLAG1 O SSCR_F1_RADI. " MM
      IF F-DIDX+1(1) > FRAME-MAX_LENG_PARAM.
        F-DIDX+1(1) = FRAME-MAX_LENG_PARAM.
        L_PLENGTH = FRAME-MAX_LENG_PARAM.
      ENDIF.

      IF F-LENG > F-DIDX+1(1).
       IF F-FLG1 Z FLG1_ROLL.
         ADD FLG1_ROLL TO F-FLG1.
       ENDIF.
      ENDIF.

      F-COLN = CURCOLN.
      F-LINE = CURLINE.
      MOVE 'PAR' TO F-GRP3.

      MOVE: 'A'               TO F-FILL,
            RADIO_GROUPS-AUTH TO F-AUTH.

      PERFORM ADD_OBJECT TABLES F CHANGING L_SUBRC.
      CHECK L_SUBRC = 0.
      ADD: "1 TO CURAUTH,
           2 TO CURCOLN.
      CLEAR F.

    ENDIF.
    CONCATENATE '%_' G_SSCR-NAME '_%_APP_%-TEXT' INTO F-FNAM.
    perform text_attributes_new using    l_length
                                     l_flag_left_right
                            CHANGING F.
    clear l_flag_left_right.
    <F-GRP4> = G_SSCR-NUMB MOD 1000.
    MOVE 'TXT' TO F-GRP3.
    PERFORM ADD_OBJECT TABLES F CHANGING L_SUBRC.
    CHECK L_SUBRC = 0.
*   APPEND F.
    IF G_SSCR-FLAG2 O SSCR_F2_HRLO.
      MOVE F-FNAM      TO HELP_TAB-NAME.
      MOVE G_SSCR-NAME TO HELP_TAB-NAME_FOR_MOD.
      APPEND HELP_TAB.
    ENDIF.
    CLEAR F.
    IF G_SSCR-APPENDAGE = 'C'.
      CURCOLN = CURCOLN + L_LENGTH + 1.
    ELSE.
      CURCOLN = CURCOLN + FRAME-TEXT_LENGTH + OPT_PUSH_LENGTH + 1 + 1.
    ENDIF.
    MOVE L_F TO F.
    IF G_SSCR-APPENDAGE NE 'C' or G_SSCR-FLAG1 Z SSCR_F1_RADI.
    " Keine Checkbox: Normalfall MM
      IF F-DIDX+1(1) > FRAME-MAX_LENG_PARAM.
        F-DIDX+1(1) = FRAME-MAX_LENG_PARAM.
        L_PLENGTH = FRAME-MAX_LENG_PARAM.
      ENDIF.
    ENDIF.
  ELSE.                                 " BEGIN/END OF LINE
    PERFORM ADJUST_OLENGTH USING    CURCOLN CURLINE
                           CHANGING G_SSCR L_PLENGTH L_SUBRC.
    IF L_SUBRC NE 0.
      EXIT.
    ENDIF.
    F-DIDX+1(1) = L_PLENGTH.
  ENDIF.
* Normalfall (g_sscr-APPENDAGE NE 'C') oder BEGIN/END OF LINE
  IF INLINE NE SPACE OR
    ( G_SSCR-APPENDAGE NE 'C' and G_SSCR-FLAG1 Z  SSCR_F1_RADI ).
*   Generiere Parameterfeld
    CASE G_SSCR-APPENDAGE.
      WHEN 'C'.                      "AS CHECKBOX
        MOVE: 'C'         TO F-FILL,
              CURAUTH     TO F-AUTH.
        ADD 1 TO CURAUTH.
        if <l_f>-FUNCCODE is initial and
           not g_sscr-matchcode is initial.
          <l_f>-FUNCCODE = g_sscr-matchcode.
        endif.
    ENDCASE.
    IF G_SSCR-FLAG1 O SSCR_F1_RADI.
      MOVE: 'A'               TO F-FILL,
            RADIO_GROUPS-AUTH TO F-AUTH.
    ENDIF.

    IF F-LENG > F-DIDX+1(1).
      IF F-FLG1 Z FLG1_ROLL.
        ADD FLG1_ROLL TO F-FLG1.
      ENDIF.
    ENDIF.

    F-COLN = CURCOLN.
    F-LINE = CURLINE.
    MOVE 'PAR' TO F-GRP3.
    PERFORM ADD_OBJECT TABLES F CHANGING L_SUBRC.
    CHECK L_SUBRC = 0.
*   APPEND F.
    CLEAR F.
  ENDIF.
  IF INLINE <> SPACE.
*   BEGIN/END OF LINE aktiv
    CURCOLN = CURCOLN + L_PLENGTH + 1.
    MOVE 'X' TO ANY_FIELD.
  ENDIF.
ENDFORM.                               "GEN_SCREEN_P

*----------------------------------------------------------------------*
* Generiert die SELECT-OPTION-Zeile                                   *
*----------------------------------------------------------------------*
FORM GEN_SCREEN_S.

  DATA L_F LIKE F.
  DATA L_SUBRC LIKE SY-SUBRC.
  data l_props_for_label type PROP_LIST.
  field-symbols <l_f_res1> structure d021s_res1 default f-res1.


  IF G_SSCR-FLAG1 O SSCR_F1_NODI.      "NO-DISPLAY
    CURCOLN = 2 + INITCOLN.  EXIT.
  ENDIF.

* Sonst: Es existiert mindestens eine SELECT-OPTION.
  MOVE 'X' TO GL_SCREEN-SELOPTS.
* Kennzeichen für Laufzeit
  SCR_RUNT_INFO-SELOPTS = 'S'.
* VALUE-REQUEST
  IF G_SSCR-FLAG2 O SSCR_F2_VRLO OR G_SSCR-FLAG2 O SSCR_F2_VRHI.
    MOVE 'X' TO GL_SCREEN-VAL_REQ.
  ENDIF.
* HELP-REQUEST
  IF G_SSCR-FLAG2 O SSCR_F2_HRLO OR G_SSCR-FLAG2 O SSCR_F2_HRHI.
    MOVE 'X' TO GL_SCREEN-HLP_REQ.
  ENDIF.
* Besorge "Von"-Feld-Info ( Intervalluntergrenze )
  PERFORM FIELD_NAME USING SPACE 'LOW' G_SSCR-NAME CHANGING F-FNAM.
  PERFORM FIELD_ATTRIBUTES CHANGING F.
  MOVE F TO L_F.
* generiere Textfeld
  CLEAR F.
  if inline = space.
    ADD 1 TO CURLINE.
    CLEAR SUPPLIED.
    CURCOLN = 2 + INITCOLN.
    CONCATENATE '%_' G_SSCR-NAME '_%_APP_%-TEXT' INTO F-FNAM.
    PERFORM TEXT_ATTRIBUTES_new USING    FRAME-TEXT_LENGTH
                                     'L'
                                     CHANGING F.
*   UNPACK G_SSCR-NUMB TO F-GRP4.
    <F-GRP4> = G_SSCR-NUMB MOD 1000.
    MOVE 'TXT' TO F-GRP3.
    concatenate ctxmenu g_sscr-name into <l_f_res1>-ctmenustat.
    PERFORM ADD_OBJECT TABLES F CHANGING L_SUBRC.
    CHECK L_SUBRC = 0.
*   get property list for textfield
    CALL FUNCTION 'RS_SCRP_PROP_ADD_TO_PROP_LIST'
      EXPORTING
        P_TEXTFIELD                  = f-fnam
*       P_TOOLTIPTEXT_TEXTELEM       =
*       P_TOOLTIPTEXT_VARIABLE       =
      CHANGING
        p_prop_list                  = l_props_for_label.

*   APPEND F.
    CLEAR F.
    CURCOLN = CURCOLN + FRAME-TEXT_LENGTH + 1.
    PERFORM GEN_OPTION_PUSH.
    CURCOLN = CURCOLN + OPT_PUSH_LENGTH + 1.
  else.
    MOVE 'X' TO ANY_FIELD.
    PERFORM GEN_OPTION_PUSH.
    CURCOLN = CURCOLN + OPT_PUSH_LENGTH + 1.
  endif.

*  PERFORM GEN_OPTION_PUSH.
*  CURCOLN = CURCOLN + OPT_PUSH_LENGTH + 1.

* generiere "Von"-Feld ( Intervalluntergrenze )
  MOVE L_F TO F.
  F-COLN = CURCOLN.
  F-LINE = CURLINE.
  MOVE 'LOW' TO F-GRP3.
  concatenate ctxmenu g_sscr-name into <l_f_res1>-ctmenustat.
  PERFORM ADD_OBJECT TABLES F CHANGING L_SUBRC.
  CHECK L_SUBRC = 0.

  CLEAR F.

  if inline eq space.
    CURCOLN = POS-TOTEXT.
  else.
    curcoln = curcoln + MAX_LENG_SELOPT + 1.
  endif.

* Generiere HIGH-Feld, falls erwünscht.
  IF     G_SSCR-FLAG1 Z SSCR_F1_NOIN.     " Kein NO INTERVALS
*    and frame-no_intervals = space.      " Kein NO INTERVALS für Block
* generiere "Bis"-Feld ( Text 'bis' )
    CONCATENATE '%_' G_SSCR-NAME '_%_APP_%-TO_TEXT' INTO F-FNAM.
    perform text_attributes_new using    to_length
                                     'L'
                                     changing f.
    f-leng = to_length.
*   UNPACK G_SSCR-NUMB TO F-GRP4.
    <F-GRP4> = G_SSCR-NUMB MOD 1000.
*   F-FLG2 = F-FLG2 BIT-OR FLG2_RIGHT.  " sieht in Proportionalschrift
*                                       " auch nicht besser aus.
    MOVE 'TOT' TO F-GRP3.
    concatenate ctxmenu g_sscr-name into <l_f_res1>-ctmenustat.
*   IF NOT ( GLOBAL-PROG = 'KSTESTM5' AND G_SSCR-NAME = 'HUGO' ).
    PERFORM ADD_OBJECT TABLES F CHANGING L_SUBRC.

    CHECK L_SUBRC = 0.
*   ENDIF.
*   APPEND F.
    CLEAR F.
    CURCOLN = CURCOLN + TO_LENGTH + 1.

    MOVE L_F TO F.
    PERFORM FIELD_NAME USING SPACE 'HIGH' G_SSCR-NAME CHANGING F-FNAM.
    F-COLN = CURCOLN.
    F-LINE = CURLINE.
    IF F-FLG2 O FLG2_SPA_GPA .           " Memory-id
      SUBTRACT FLG2_SPA_GPA FROM F-FLG2.
      CLEAR F-PAID.
    ENDIF.
    IF F-FLG3 O FLG3_OBLIGATORY.         " Obligatorische Eingabe
      SUBTRACT FLG3_OBLIGATORY FROM F-FLG3.
    ENDIF.
    IF G_SSCR-FLAG2 Z SSCR_F2_VRHI AND F-FMB2 O FMB2_COMBO.
      F-FMB2 = F-FMB2 - FMB2_COMBO - FMB2_CMB_FORCE.
    ELSEIF G_SSCR-FLAG2 O SSCR_F2_VRHI AND F-FMB2 Z FMB2_COMBO.
      F-FMB2 = F-FMB2 + FMB2_COMBO + FMB2_CMB_FORCE.
    ENDIF.

    MOVE 'HGH' TO F-GRP3.
    concatenate ctxmenu g_sscr-name into <l_f_res1>-ctmenustat.
    PERFORM ADD_OBJECT TABLES F CHANGING L_SUBRC.
    CHECK L_SUBRC = 0.
*  property list for LOW field
    if not l_props_for_label is initial.
      call function 'RS_SCRP_PROP_WRITE'
        exporting
          p_prog                = key-program
          p_dnum                = key-screen
          p_dynprofield         = f
          p_prop_list           = l_props_for_label
        changing
          p_properties          = m[]
       exceptions
*         PARAMLIST_ERROR       = 1
*         PROPLIST_ERROR        = 2
         OTHERS                = 1.
      if sy-subrc <> 0.
        if entrypoint = 2. " Call from RSDBGENA. Tolerate error otherwise
          perform fill_gen_message using 'GPROP' curline curcoln g_sscr.
          clear exitflag. "do not exit
        endif.
      endif.
    endif.
    CLEAR F.

    CURCOLN = CURCOLN + FRAME-MAX_LENG_SELOPT + 1.
  ENDIF.

* Generiere Pushbutton und MORE-Knopf
  IF G_SSCR-NOSELSET EQ SPACE.
    PERFORM GEN_PUSHBUTTON USING PUSH_LENGTH.
    MOVE 'VPU' TO F-GRP3.
    IF D020S-TYPE EQ 'J'.
*     CONCATENATE F-DMAC GL_SCREEN-NUMBER GLOBAL-HASH INTO F-DMAC.
      CONCATENATE <l_f_res1>-funccode GL_SCREEN-NUMBER GLOBAL-HASH
                  INTO <l_f_res1>-funccode.
    ENDIF.
    concatenate ctxmenu g_sscr-name into <l_f_res1>-ctmenustat.
    PERFORM ADD_OBJECT TABLES F CHANGING L_SUBRC.
    CHECK L_SUBRC = 0.
*   APPEND F.
    CLEAR F.
  ENDIF.
ENDFORM.                               " GEN_SCREEN_S

* PARAMETER AS INDEX STRUCTURE, gerufen von SCREEN_P
FORM SCREEN_P_AS_IX_STR USING TABIX.

  DATA L_LINE TYPE I.
  DATA L_LENG TYPE I.         " Länge des Suchstrings
  DATA L_MAX  TYPE I.
  data: l_d021s_res1 like d021s_res1.

  CONSTANTS lc_flg1_ddicmod(1) TYPE x VALUE '10'.

  FIELD-SYMBOLS <L_F>.

  IF G_SSCR-MATCHCODE NE SPACE.
    SELECT SINGLE ISSIMPLE INTO GL_SCREEN-IX_SIMPLE FROM DD30L WHERE
             SHLPNAME = G_SSCR-MATCHCODE            AND
             AS4LOCAL = 'A'.
  ENDIF.

  L_LINE = LAST_LINE - 1.
* Pushed auf Stack
  PERFORM PUSH_FRAME USING 'X' SPACE.

  F-FILL = 'R'.                          " Rahmen

  F-AUTH = CURAUTH.                      " Graphische Gruppennr.
  ADD 1 TO CURAUTH.

  ADD 1 TO CURLINE.
  CLEAR SUPPLIED.
*
  CURCOLN = 2 + INITCOLN - FRAME_MARGIN.

  PERFORM TEXT_ATTRIBUTES USING    FRAME-LENGTH
                          CHANGING F.
  L_MAX = F-COLN + F-LENG.
  IF L_MAX > GL_SCREEN-MAX_POS.
    GL_SCREEN-MAX_POS = L_MAX.
  ENDIF.

  IF GL_SCREEN-IX_SIMPLE EQ SPACE.
      <F-DIDX> = 5.                        " Rahmenhoehe
  ELSE.
      <F-DIDX> = 4.                        " ohne ID, Einzelsuchhilfe
  ENDIF.
  F-FNAM = 'SSCRTEXTS-FRAME_TEXT'.
  IF F-FLG1 Z FLG1_DDIC.
    ADD FLG1_DDIC TO F-FLG1.
  ENDIF.
  IF f-flg1 Z lc_flg1_ddicmod.
    ADD lc_flg1_ddicmod TO f-flg1.
  ENDIF.

  F-GRP3 = 'IXS'.
* UNPACK G_SSCR-NUMB TO F-GRP4.
  <F-GRP4> = G_SSCR-NUMB MOD 1000.

  APPEND F.
  CLEAR F.
  IF GL_SCREEN-IX_SIMPLE = SPACE.
    ADD 1 TO CURLINE.
    CLEAR SUPPLIED.

* Generiere Hotkey-Text
    CURCOLN = 2 + INITCOLN. "+ FRAME_MARGIN. " Anfang innerhalb Rahmen 2
    PERFORM TEXT_ATTRIBUTES USING    FRAME-TEXT_LENGTH
                            CHANGING F.
    F-FNAM = 'SSCRTEXTS-MCID_TEXT'.
    IF F-FLG1 Z FLG1_DDIC.
      ADD FLG1_DDIC TO F-FLG1.
    ENDIF.
    F-GRP3 = 'IXS'.
* UNPACK G_SSCR-NUMB TO F-GRP4.
    <F-GRP4> = G_SSCR-NUMB MOD 1000.
    l_d021s_res1-labelleft = 'X'.
    f-res1 = l_d021s_res1.
    APPEND F.
    CLEAR F.

* Generiere Feld für Suchhilfe-Hotkey
* Nach Textfeld + Combobutton
* CURCOLN = CURCOLN + FRAME-TEXT_LENGTH + 1.
* CURCOLN = CURCOLN + OPT_PUSH_LENGTH + 1.
    CURCOLN = POS-LOW.

    PERFORM TEXT_ATTRIBUTES USING    1
                            CHANGING F.
    IF F-FMB1 O FMB1_JUST_OUT.
      SUBTRACT FMB1_JUST_OUT FROM F-FMB1.
    ENDIF.
    MOVE SPACE TO F-STXT+1.
    PERFORM CD_FIELD_NAME USING SPACE  G_SSCR-NAME '-' 'HOTKEY'
                          CHANGING F-FNAM.
    IF F-FMB2 Z FMB2_COMBO.
      F-FMB2 = F-FMB2 + FMB2_COMBO + FMB2_CMB_FORCE.
    ENDIF.
    IF F-FLG1 Z FLG1_FIELD.
      ADD FLG1_FIELD TO F-FLG1.
    ENDIF.
    IF F-FLG2 O FLG2_LETT.
      SUBTRACT FLG2_LETT FROM F-FLG2.
    ENDIF.
    IF F-FMB1 O FMB1_PROTECTED.
      SUBTRACT FMB1_PROTECTED FROM F-FMB1.
    ENDIF.
    F-GRP3 = 'IXS'.
* UNPACK G_SSCR-NUMB TO F-GRP4.
    <F-GRP4> = G_SSCR-NUMB MOD 1000.

    APPEND F.
    CLEAR F.

* Generiere Textfeld für MCID
    CURCOLN = CURCOLN + 1 + 1.       " Nach Eingabefeld
    L_LENG = FRAME-LENGTH - 2 * FRAME_MARGIN - FRAME-TEXT_LENGTH - 1
                                              - OPT_PUSH_LENGTH - 3.
    IF L_LENG > 60.
      L_LENG = 60.
    ENDIF.
    PERFORM TEXT_ATTRIBUTES USING    L_LENG
                            CHANGING F.
    IF F-LENG > 60.
      <F-DIDX> = 60.
    ELSE.
      <F-DIDX> = L_LENG.
    ENDIF.
    MOVE 'SSCRTEXTS-TEXT_MCID' TO F-FNAM.
    IF F-FMB1 O FMB1_JUST_OUT.
      SUBTRACT FMB1_JUST_OUT FROM F-FMB1.
    ENDIF.
    IF F-FLG1 Z FLG1_DDIC.
      ADD FLG1_DDIC TO F-FLG1.
    ENDIF.
    IF F-FLG2 Z FLG2_LETT.
      ADD FLG2_LETT TO F-FLG2.
    ENDIF.
    IF F-FMB2 Z FMB2_COMBO.
      F-FMB2 = F-FMB2 + FMB2_COMBO + FMB2_CMB_FORCE.
    ENDIF.
    F-GRP3 = 'IXS'.
* UNPACK G_SSCR-NUMB TO F-GRP4.
    <F-GRP4> = G_SSCR-NUMB MOD 1000.

    APPEND F.
    CLEAR F.
  ENDIF.
  ADD 1 TO CURLINE.
  CLEAR SUPPLIED.

* Generiere Suchstring-Text
  CURCOLN = 2 + INITCOLN. "+ FRAME_MARGIN.   " Anfang innerhalb Rahmen 2
  PERFORM TEXT_ATTRIBUTES USING    FRAME-TEXT_LENGTH
                          CHANGING F.
  F-FNAM = 'SSCRTEXTS-STRNG_TEXT'.
  IF F-FLG1 Z FLG1_DDIC.
    ADD FLG1_DDIC TO F-FLG1.
  ENDIF.
  F-GRP3 = 'IXS'.
* UNPACK G_SSCR-NUMB TO F-GRP4.
  <F-GRP4> = G_SSCR-NUMB MOD 1000.
  l_d021s_res1-labelleft = 'X'.
  f-res1 = l_d021s_res1.

  APPEND F.
  CLEAR F.
* Nach Text + SELOPT-Pushbutton
* CURCOLN = CURCOLN + FRAME-TEXT_LENGTH + OPT_PUSH_LENGTH + 1 + 1.
  CURCOLN = POS-LOW.

* Generiere Suchstring-Feld
  L_LENG = FRAME-LENGTH - 2 * FRAME_MARGIN - FRAME-TEXT_LENGTH - 1
                                            - OPT_PUSH_LENGTH - 1.
  PERFORM TEXT_ATTRIBUTES USING    L_LENG
                          CHANGING F.
  IF F-FMB1 O FMB1_JUST_OUT.
    SUBTRACT FMB1_JUST_OUT FROM F-FMB1.
  ENDIF.
  IF F-FLG1 Z FLG1_FIELD.
    ADD FLG1_FIELD TO F-FLG1.
  ENDIF.
  IF F-FLG2 O FLG2_LETT.
    SUBTRACT FLG2_LETT FROM F-FLG2.
  ENDIF.
  IF F-FMB1 O FMB1_PROTECTED.
    SUBTRACT FMB1_PROTECTED FROM F-FMB1.
  ENDIF.
  <F-GRP4> = G_SSCR-NUMB MOD 1000.
*
  IF L_LENG > 80.
    <F-DIDX> = 80.
  ELSE.
    <F-DIDX> = L_LENG.
  ENDIF.
  F-LENG = 80.

  IF F-LENG > <F-DIDX>.
    IF F-FLG1 Z FLG1_ROLL.
      ADD FLG1_ROLL TO F-FLG1.
    ENDIF.
  ENDIF.

  MOVE SPACE TO F-STXT+F-LENG.
  PERFORM CD_FIELD_NAME USING SPACE  G_SSCR-NAME '-' 'STRING'
                        CHANGING F-FNAM.
  IF F-FMB2 Z FMB2_COMBO.
    F-FMB2 = F-FMB2 + FMB2_COMBO + FMB2_CMB_FORCE.
  ENDIF.
  F-GRP3 = 'IXS'.

  APPEND F.
  CLEAR F.

* Generiere Text 'Komplexe Suche'
  ADD 1 TO CURLINE.
  CLEAR SUPPLIED.
  CURCOLN = 2 + INITCOLN. "+ FRAME_MARGIN.   " Anfang innerhalb Rahmen 2
  PERFORM GEN_SEARCH_PUSH.

  IF CURLINE GE L_LINE.
    PERFORM SCREEN_TOO_LARGE.
  ENDIF.

  GL_SCREEN-IX = TABIX.
  ADD 1 TO CURLINE.
  CLEAR SUPPLIED.

  PERFORM POP_FRAME.

ENDFORM.                          " SCREEN_P_AS_IX_STR.
* Pushbutton für Selektionsoption.
FORM GEN_OPTION_PUSH.

  field-symbols <l_f_res1> structure d021s_res1 default f-res1.
* UNPACK G_SSCR-NUMB TO F-GRP4.
*   if sy-uname ne 'BINDEWALD'.
*  <F-GRP4> = G_SSCR-NUMB MOD 1000.
*  CONCATENATE '%_' G_SSCR-NAME '_%_APP_%-OPTI_PUSH' INTO F-FNAM.
*
*  F-LENG = INTERNAL_OPT_PUSH_LENGTH.
*  PERFORM TEXT_ATTRIBUTES USING    F-LENG
*                          CHANGING F.
*  F-DIDX = OPT_PUSH_LENGTH.
*  F-FILL = 'P'.
*  F-AUTH = CURAUTH.
*  ADD 1 TO CURAUTH.
**  F-DMAC+1(1) = '&'.
*  <l_f_res1>-funccode = '&'.
**  F-DMAC+2(3) = F-GRP4.
*  <l_f_res1>-funccode+1(3) = F-GRP4.
*  concatenate ctxmenu g_sscr-name into <l_f_res1>-ctmenustat.
*  IF D020S-TYPE EQ 'J'.
**    CONCATENATE F-DMAC GL_SCREEN-NUMBER GLOBAL-HASH INTO F-DMAC.
*    CONCATENATE <l_f_res1>-funccode GL_SCREEN-NUMBER GLOBAL-HASH
*                INTO <l_f_res1>-funccode.
*  ENDIF.
*  MOVE 'OPU' TO F-GRP3.
**  if sy-uname = 'BINDEWALD'.
**    f-leng = 2.
**    f-fill = 'U'.
**    f-flg1 = f-flg2 = f-flg3 = '00'.
**    f-type = f-ityp = space.
**    f-fmb1 = fmb1_protected.
**  endif.
*  else.
  <F-GRP4> = G_SSCR-NUMB MOD 1000.
  MOVE 'OPU' TO F-GRP3.
  CONCATENATE '%_' G_SSCR-NAME '_%_APP_%-OPTI_PUSH' INTO F-FNAM.

  F-LENG = opt_push_length.
  PERFORM TEXT_ATTRIBUTES USING    F-LENG
                          CHANGING F.
*  F-FLG1 = F-FLG1 BIT-OR FLG1_ROLL.
  ADD FMB1_NO_DITCH TO F-FMB1.
   concatenate ctxmenu g_sscr-name into <l_f_res1>-ctmenustat.
  f-fmb1 = '32'.
  f-ityp = 'C'.
*  f-DIDX+1(1) = 2.
  f-leng = internal_opt_push_length.
  clear f-flg2.
*  endif.
  APPEND F.
  CLEAR F.
ENDFORM.                               " GEN_OPTION_PUSH.

* generiert Pushbutton
FORM GEN_PUSHBUTTON USING LENG.

* UNPACK G_SSCR-NUMB TO F-GRP4.
  <F-GRP4> = G_SSCR-NUMB MOD 1000.
  CONCATENATE '%_' G_SSCR-NAME '_%_APP_%-VALU_PUSH' INTO F-FNAM.
  F-LENG = INTERNAL_PUSH_LENGTH.
  F-DIDX = PUSH_LENGTH.

  PERFORM FSET_BUTTON_ATTRIBUTES.

ENDFORM.                               " GEN_PUSHBUTTON

* Eigenschaften des Wertemengenbuttons.
FORM FSET_BUTTON_ATTRIBUTES.
  FIELD-SYMBOLS <l_f_res1> structure d021s_res1 default f-res1.
  PERFORM TEXT_ATTRIBUTES USING    F-LENG
                          CHANGING F.
  F-DIDX = 3.
  F-FILL = 'P'.
  F-AUTH = CURAUTH.
  ADD 1 TO CURAUTH.
*  F-DMAC+1(1) = '%'.
   <L_F_RES1>-FUNCCODE = '%'.
*  F-DMAC+2(3) = F-GRP4.
   <L_F_RES1>-FUNCCODE+1(3) = F-GRP4.
ENDFORM.                               " BUTTON_ATTRIBUTES.
* SEARCH-Button
FORM GEN_SEARCH_PUSH.
  CONSTANTS lc_flg1_ddicmod(1) TYPE x VALUE '10'.


  field-symbols <l_f_res1> structure d021s_res1 default f-res1.
  <F-GRP4> = G_SSCR-NUMB MOD 1000.
  F-FNAM = 'SSCRFIELDS-SEARCH_BTN'.

  F-LENG = INTERNAL_PUSH_LENGTH + MAX_TEXT_LENGTH.
  PERFORM TEXT_ATTRIBUTES USING    F-LENG
                          CHANGING F.
  F-FLG1 = F-FLG1 BIT-OR lc_flg1_ddicmod.
  F-DIDX = PUSH_LENGTH + MAX_TEXT_LENGTH - 15.
  F-FILL = 'P'.
  F-AUTH = CURAUTH.
  ADD 1 TO CURAUTH.
*  F-DMAC+1 = 'CXSP'.
  <l_f_res1>-funccode = 'CXSP'.
  MOVE 'IXS' TO F-GRP3.
  APPEND F.
  CLEAR F.

ENDFORM.                               " GEN_SEARCH_PUSH.

*----------------------------------------------------------------------*
* Generiert Kommentar   ( SELECTION-SCREEN COMMENT )                  *
*----------------------------------------------------------------------*
FORM GEN_SCREEN_C.

  DATA: BEGIN OF L_NAME,
          PREFIX LIKE RSSCR-NAME,
          UNDERSCORE VALUE '_',
          SUFFIX(4) TYPE N,
        END   OF L_NAME.
  DATA L_SUBRC LIKE SY-SUBRC.
  DATA: L_OLENGTH LIKE RSSCR-OLENGTH.
*
  IF ( INLINE = SPACE AND G_SSCR-APPENDAGE = '1' )
       OR CURLINE = 0 OR CURLINE < FRAME-FIRST_LINE OR
       (  GL_SCREEN-LAST_SSCR-KIND = 'L' OR
                       GL_SCREEN-LAST_SSCR-KIND = 'K' )
          AND GL_SCREEN-LAST_SSCR-APPENDAGE = 'E'      OR
              GL_SCREEN-LAST_SSCR-KIND = 'P'
          AND GL_SCREEN-LAST_SSCR-FLAG1 O SSCR_F1_IXST.
    ADD 1 TO CURLINE.
    CLEAR SUPPLIED.
  ENDIF.
  CASE G_SSCR-OFFSET.
    WHEN 1000.                   " POS_LOW
      CURCOLN = POS-LOW.
    WHEN 2000.                   " POS_HIGH
      CURCOLN = POS-HIGH.
    WHEN 0.                      " Kein Offset
    WHEN OTHERS.
      CURCOLN = G_SSCR-OFFSET + 1 + INITCOLN.
  ENDCASE.
  IF G_SSCR-NAME(2) EQ '%C'.    " TEXT-xxx ?
    MOVE G_SSCR-NAME      TO L_NAME-PREFIX.
    IF G_SSCR-LENGTH < 1000.
      MOVE GL_SCREEN-NUMBER TO L_NAME-SUFFIX.
    ELSE.
      L_NAME-SUFFIX = G_SSCR-LENGTH DIV 1000.
      G_SSCR-LENGTH = G_SSCR-LENGTH MOD 1000.
    ENDIF.
    F-FNAM = L_NAME.
  ELSE.                          " Feld
    MOVE G_SSCR-NAME TO F-FNAM.
  ENDIF.
* Position zu gross?
  IF NOT G_SSCR-LENGTH IS INITIAL AND G_SSCR-LENGTH < G_SSCR-OLENGTH.
     L_OLENGTH = G_SSCR-LENGTH.             "visible length
  ELSE.
     L_OLENGTH = G_SSCR-OLENGTH.
  ENDIF.
  PERFORM ADJUST_OLENGTH USING    CURCOLN CURLINE
                         CHANGING G_SSCR L_OLENGTH L_SUBRC.
  IF L_SUBRC NE 0.
    EXIT.
  ENDIF.
  PERFORM TEXT_ATTRIBUTES USING    L_OLENGTH
                          CHANGING F.
*  IF NOT G_SSCR-LENGTH IS INITIAL AND G_SSCR-LENGTH < G_SSCR-OLENGTH.
  IF L_oLENGTH < G_SSCR-OLENGTH.
     F-FLG1 = F-FLG1 BIT-OR FLG1_ROLL.
     F-LENG = G_SSCR-OLENGTH.
  ENDIF.
  ADD FMB1_NO_DITCH TO F-FMB1.

  MOVE 'COM' TO F-GRP3.

  PERFORM ADD_OBJECT TABLES F CHANGING L_SUBRC.
  CHECK L_SUBRC = 0.
* APPEND F.
  CLEAR F.
  MOVE 'X' TO ANY_FIELD.
  CURCOLN = CURCOLN + G_SSCR-OLENGTH + 1.

ENDFORM.                               "GEN_SCREEN_C

*----------------------------------------------------------------------*
* Generiert Kommentar zu einem bestimmten Feld                        *
* ( SELECTION-SCREEN COMMENT ... FOR FIELD ...                        *
*----------------------------------------------------------------------*
FORM GEN_SCREEN_F using value(index).

  DATA L_SSCR LIKE G_SSCR.
  DATA L_SUBRC LIKE SY-SUBRC.
  DATA L_INT TYPE I.
  data l_flag_left_right.
  DATA: BEGIN OF L_NAME,
          PREFIX LIKE RSSCR-NAME,
          UNDERSCORE VALUE '_',
          SUFFIX(4) TYPE N,
        END   OF L_NAME.
  DATA: L_OLENGTH LIKE RSSCR-OLENGTH.
  IF INLINE = SPACE AND G_SSCR-APPENDAGE = '1'
       OR CURLINE = 0 OR CURLINE < FRAME-FIRST_LINE OR
        ( GL_SCREEN-LAST_SSCR-KIND = 'L' OR
                         GL_SCREEN-LAST_SSCR-KIND = 'K' )
          AND GL_SCREEN-LAST_SSCR-APPENDAGE = 'E'      OR
              GL_SCREEN-LAST_SSCR-KIND = 'P'
          AND GL_SCREEN-LAST_SSCR-FLAG1 O SSCR_F1_IXST.
    ADD 1 TO CURLINE.
    CLEAR SUPPLIED.
  ENDIF.

  CASE G_SSCR-OFFSET.
    WHEN 1000.                   " POS_LOW
      CURCOLN = POS-LOW.
    WHEN 2000.                   " POS_HIGH
      CURCOLN = POS-HIGH.
    WHEN 0.                      " Kein Offset
    WHEN OTHERS.
      CURCOLN = G_SSCR-OFFSET + 1 + INITCOLN.
  ENDCASE.
  IF G_SSCR-NAME(2) = '%F'.         " COMMENT ... TEXT-xxx
    MOVE G_SSCR-NAME      TO L_NAME-PREFIX.
    IF G_SSCR-LENGTH < 1000.
      MOVE GL_SCREEN-NUMBER TO L_NAME-SUFFIX.
    ELSE.
      L_NAME-SUFFIX = G_SSCR-LENGTH DIV 1000.
      G_SSCR-LENGTH = G_SSCR-LENGTH MOD 1000.
    ENDIF.
    F-FNAM = L_NAME.
    MOVE G_SSCR-MISCELL TO L_SSCR-NAME.
  ELSE.                           " COMMENT ... HUGO
    MOVE G_SSCR-NAME TO F-FNAM.
    MOVE G_SSCR-MISCELL TO L_SSCR-NAME.
  ENDIF.
  IF NOT G_SSCR-LENGTH IS INITIAL AND G_SSCR-LENGTH < G_SSCR-OLENGTH.
     L_OLENGTH = G_SSCR-LENGTH.             "visible length
  ELSE.
     L_OLENGTH = G_SSCR-OLENGTH.
  ENDIF.

  PERFORM ADJUST_OLENGTH USING    CURCOLN CURLINE
                         CHANGING G_SSCR L_OLENGTH L_SUBRC.
  IF L_SUBRC NE 0.
    EXIT.
  ENDIF.
  PERFORM TEXT_ATTRIBUTES USING    L_OLENGTH
                          CHANGING F.
*  IF NOT G_SSCR-LENGTH IS INITIAL AND G_SSCR-LENGTH < G_SSCR-OLENGTH.
  IF l_OLENGTH < G_SSCR-OLENGTH.
     F-FLG1 = F-FLG1 BIT-OR FLG1_ROLL.
     F-LENG = G_SSCR-OLENGTH.
  ENDIF.
  ADD FMB1_NO_DITCH TO F-FMB1.


  PERFORM READ_SSCR_LINE USING L_SSCR-NAME CHANGING L_SSCR L_SUBRC.
  IF L_SUBRC = 0.
    <F-GRP4> = L_SSCR-NUMB MOD 1000.
    IF L_SSCR-KIND = 'P' AND L_SSCR-FLAG2 O SSCR_F2_HRLO      OR
       L_SSCR-KIND = 'S' AND L_SSCR-FLAG2 O SSCR_F2_HR.
      MOVE F-FNAM      TO HELP_TAB-NAME.
      MOVE L_SSCR-NAME TO HELP_TAB-NAME_FOR_MOD.
      APPEND HELP_TAB.
    ENDIF.
    if l_sscr-kind eq 'P'.
      comfipar-fieldname = f-fnam.
      comfipar-parname   = l_sscr-name.
      comfipar-kind      = l_sscr-kind.
      append comfipar.
    endif.
    if l_sscr-kind eq 'S'.
      comfipar-fieldname = f-fnam.
      comfipar-parname   = l_sscr-name.
      comfipar-kind      = l_sscr-kind.
      append comfipar.
    endif.
  ENDIF.
  MOVE 'COF' TO F-GRP3.

  if inline ne space.
    data for_field type rsscr-name.
    for_field = g_sscr-miscell.
    perform augment_comment using    index
                                         for_field
                                changing f.
  endif.


  PERFORM ADD_OBJECT TABLES F CHANGING L_SUBRC.
  CHECK L_SUBRC = 0.
* APPEND F.
  CLEAR F.
  MOVE 'X' TO ANY_FIELD.
  CURCOLN = CURCOLN + G_SSCR-OLENGTH + 1.

ENDFORM.                               " GEN_SCREEN_F

*----------------------------------------------------------------------*
* Generiert Strichzeile ( SELECTION-SCREEN ULINE )                    *
*----------------------------------------------------------------------*
FORM GEN_SCREEN_U.

  DATA L_SUBRC LIKE SY-SUBRC.

  IF G_SSCR-APPENDAGE = '1' OR CURLINE = 0
                            OR CURLINE < FRAME-FIRST_LINE OR
         ( GL_SCREEN-LAST_SSCR-KIND = 'L' OR
                      GL_SCREEN-LAST_SSCR-KIND = 'K' )
          AND GL_SCREEN-LAST_SSCR-APPENDAGE = 'E'      OR
              GL_SCREEN-LAST_SSCR-KIND = 'P'
          AND GL_SCREEN-LAST_SSCR-FLAG1 O SSCR_F1_IXST.
    ADD 1 TO CURLINE.
    CLEAR SUPPLIED.
  ENDIF.
  MOVE G_SSCR-NAME TO F-FNAM.
  CASE G_SSCR-OFFSET.
    WHEN 1000.                   " POS_LOW
      CURCOLN = POS-LOW.
    WHEN 2000.                   " POS_HIGH
      CURCOLN = POS-HIGH.
    WHEN 0.                      " Kein Offset
    WHEN OTHERS.
      CURCOLN = G_SSCR-OFFSET + 1 + INITCOLN.
  ENDCASE.

  PERFORM ADJUST_OLENGTH USING    CURCOLN CURLINE
                         CHANGING G_SSCR G_SSCR-OLENGTH L_SUBRC.
  IF L_SUBRC NE 0.
    EXIT.
  ENDIF.

  PERFORM TEXT_ATTRIBUTES USING    G_SSCR-OLENGTH
                          CHANGING F.
  F-FLG1 = FLG1_TEXT.
  F-FMB1 = FMB1_PROTECTED.
  F-STXT = SY-ULINE.
  IF G_SSCR-DB = 'X'.
    MOVE '_' TO F-FNAM+8.
    MOVE G_SSCR-DBFIELD TO F-FNAM+9.
  ENDIF.
  IF F-FMB1 Z FMB1_NO_DITCH.
    ADD FMB1_NO_DITCH TO F-FMB1.
  ENDIF.
  IF G_SSCR-OLENGTH GE 79 AND F-FMB1 Z FMB1_FIXFONT.
    ADD FMB1_FIXFONT TO F-FMB1.
  ENDIF.

  MOVE 'ULI' TO F-GRP3.
  PERFORM ADD_OBJECT TABLES F CHANGING L_SUBRC.
  CHECK L_SUBRC = 0.
* APPEND F.
  CLEAR F.
  MOVE 'X' TO ANY_FIELD.
  CURCOLN = CURCOLN + G_SSCR-OLENGTH + 1.

ENDFORM.                          " GEN_SCREEN_U
* Blöcke
FORM GEN_SCREEN_K.

  DATA: L_NOIN.
  DATA: L_FRAME.
  DATA L_MAX TYPE I.

  DATA: BEGIN OF L_BL_NAME,
          PREFIX(2) VALUE '%B',
          TEXTNUM(3),
          CURRNUM(3) TYPE N,
          MIDFIX(7) VALUE '_BLOCK_',
          SUFFIX(4) TYPE N,
        END   OF L_BL_NAME.

  CASE G_SSCR-APPENDAGE.
    WHEN 'A'.
*   BEGIN OF BLOCK
      IF G_SSCR-FLAG1 O SSCR_F1_NOIN.
*     NO INTERVAL bei select-options
         L_NOIN = 'X'.
      ENDIF.
      IF G_SSCR-NAME+2(3) NE '%__'.
*     mit Rahmen?
         L_FRAME = 'X'.
      ENDIF.
      PERFORM PUSH_FRAME USING L_FRAME L_NOIN.
      CHECK L_FRAME NE SPACE.
      CLEAR F.
      IF G_SSCR-NAME+2(3) = '%_T'.
        PERFORM GEN_TABSTRIP.
        EXIT.
      ENDIF.
      F-FILL = 'R'.
      F-AUTH = CURAUTH.
      ADD 1 TO CURAUTH.
      ADD 1 TO CURLINE.
      CLEAR SUPPLIED.
      CURCOLN = INITCOLN + 2 - FRAME_MARGIN.
      PERFORM TEXT_ATTRIBUTES USING    FRAME-LENGTH
                              CHANGING F.

      IF G_SSCR-NAME+2(3) = '%_F'.
*     Kein Titel
        IF F-FLG1 O FLG1_FIELD.
          SUBTRACT FLG1_FIELD FROM F-FLG1.
        ENDIF.
        F-FNAM = G_SSCR-NAME.
      ELSE.
        IF G_SSCR-NAME(1) EQ '%'.    " TEXT-xxx ?
          L_BL_NAME-TEXTNUM = G_SSCR-NAME+2(3).
          IF G_SSCR-OFFSET = 0.
            L_BL_NAME-CURRNUM = G_SSCR-NUMB MOD 1000.
            L_BL_NAME-SUFFIX =  GL_SCREEN-NUMBER.
          ELSE.
            L_BL_NAME-CURRNUM = G_SSCR-OFFSET MOD 1000.
            L_BL_NAME-SUFFIX =  G_SSCR-OFFSET DIV 1000.
          ENDIF.
          F-FNAM = L_BL_NAME.
        ELSE.
          MOVE G_SSCR-NAME TO F-FNAM.
        ENDIF.
      ENDIF.
      L_MAX = F-COLN + F-LENG.
      IF L_MAX > GL_SCREEN-MAX_POS.
        GL_SCREEN-MAX_POS = L_MAX.
      ENDIF.
* Bestimme Zeile für Rahmen
      DESCRIBE TABLE F LINES SY-TFILL.
      FRAME-TABIX = SY-TFILL + 1.
      MOVE 'BLK' TO F-GRP3.
      APPEND F.
      CLEAR F.

      FRAME-FIRST_LINE = CURLINE + 1.

    WHEN 'E'.                      " END   OF BLOCK.
      IF NOT FRAME-TAB IS INITIAL.
       PERFORM END_OF_TABSTRIP.
       EXIT.
      ENDIF.
      CLEAR FRAME-TAB.
      IF G_SSCR-NAME+2(3) EQ '%__'.
        PERFORM POP_FRAME.
        EXIT.
      ENDIF.

      READ TABLE F INDEX FRAME-TABIX.
      CHECK SY-SUBRC = 0.
      <F-DIDX> = CURLINE - F-LINE + 2.
      IF <F-DIDX> GT 2.
        MODIFY F INDEX FRAME-TABIX.
        ADD 1 TO CURLINE.
        CLEAR SUPPLIED.
      ELSE.
        DELETE F INDEX FRAME-TABIX.
        SUBTRACT 1 FROM CURLINE.
      ENDIF.
      CLEAR F.

      PERFORM POP_FRAME.

  ENDCASE.

ENDFORM.                            " GEN_SCREEN_K.
* PUSHBUTTON
FORM GEN_SCREEN_H.
  field-symbols <l_f_res1> structure d021s_res1 default f-res1.
  DATA: BEGIN OF L_NAME,
          PREFIX LIKE RSSCR-NAME,
          UNDERSCORE VALUE '_',
          SUFFIX(4) TYPE N,
        END   OF L_NAME.
  DATA L_SUBRC LIKE SY-SUBRC.
  DATA TEMP_OLENGTH LIKE RSSCR-OLENGTH.
*
  IF G_SSCR-MISCELL(1) EQ 'T'.
   PERFORM GEN_TAB.
   EXIT.
  ENDIF.

  IF ( INLINE = SPACE AND G_SSCR-APPENDAGE = '1' )
       OR CURLINE = 0 OR CURLINE < FRAME-FIRST_LINE OR
       ( GL_SCREEN-LAST_SSCR-KIND = 'L' OR
                    GL_SCREEN-LAST_SSCR-KIND = 'K' )
          AND GL_SCREEN-LAST_SSCR-APPENDAGE = 'E'      OR
              GL_SCREEN-LAST_SSCR-KIND = 'P'
          AND GL_SCREEN-LAST_SSCR-FLAG1 O SSCR_F1_IXST.
    ADD 1 TO CURLINE.
    CLEAR SUPPLIED.
  ENDIF.
  CASE G_SSCR-OFFSET.
    WHEN 1000.                   " POS_LOW
      CURCOLN = POS-LOW.
    WHEN 2000.                   " POS_HIGH
      CURCOLN = POS-HIGH.
    WHEN 0.                      " Kein Offset
    WHEN OTHERS.
      CURCOLN = G_SSCR-OFFSET + 1 + INITCOLN.
  ENDCASE.

  IF G_SSCR-FLAG1 IS INITIAL.
      TEMP_OLENGTH = G_SSCR-OLENGTH.
  ELSE.
      TEMP_OLENGTH = G_SSCR-FLAG1.
  ENDIF.

  PERFORM ADJUST_OLENGTH USING    CURCOLN CURLINE
                         CHANGING G_SSCR TEMP_OLENGTH L_SUBRC.
  IF L_SUBRC NE 0.
    EXIT.
  ENDIF.

  PERFORM TEXT_ATTRIBUTES USING    G_SSCR-OLENGTH
                          CHANGING F.
*  if sy-uname = 'KSCHMIDT'.
*     f-leng = 83.
*  endif.

  F-DIDX+1(1) = TEMP_OLENGTH.

  ADD FMB1_NO_DITCH TO F-FMB1.
  F-FILL = 'P'.
  F-AUTH = CURAUTH.
  ADD 1 TO CURAUTH.
   <l_f_res1>-funccode = G_SSCR-MATCHCODE.
*  F-DMAC+1 = G_SSCR-MATCHCODE.
  IF G_SSCR-NAME(1) EQ '%'.
    MOVE G_SSCR-NAME      TO L_NAME-PREFIX.
    IF G_SSCR-LENGTH = 0.
      MOVE GL_SCREEN-NUMBER TO L_NAME-SUFFIX.
    ELSE.
      L_NAME-SUFFIX = G_SSCR-LENGTH DIV 1000.
    ENDIF.
    F-FNAM = L_NAME.
  ELSE.
    MOVE G_SSCR-NAME TO F-FNAM.
  ENDIF.
  MOVE 'PBU' TO F-GRP3.
  PERFORM ADD_OBJECT TABLES F CHANGING L_SUBRC.
  CHECK L_SUBRC = 0.
* APPEND F.
  CLEAR F.
  MOVE 'X' TO ANY_FIELD.
  MOVE 'X' TO GL_SCREEN-ANY_OBJECT.

  CURCOLN = CURCOLN + TEMP_OLENGTH + 1.


ENDFORM.                            " GEN_SCREEN_H
* Liest g_sscr-Zeile mit Key p_key
FORM READ_SSCR_LINE USING P_KEY CHANGING P_SSCR P_SUBRC.

  LOCAL G_SSCR.

  READ TABLE G_SSCR WITH KEY P_KEY.
  P_SUBRC = SY-SUBRC.
  CHECK P_SUBRC = 0.
  P_SSCR = G_SSCR.

ENDFORM.

* Pusht Frame-Stack
FORM PUSH_FRAME USING P_FRAME P_NOIN.

  APPEND FRAME.

  MOVE P_FRAME TO FRAME-FRAME.

  IF P_FRAME NE SPACE.
    ADD FRAME_MARGIN TO INITCOLN.
    SUBTRACT 1 FROM LAST_LINE.
    FRAME-TEXT_LENGTH = FRAME-TEXT_LENGTH - FRAME_MARGIN.
    IF P_NOIN NE SPACE AND FRAME-NARROW EQ SPACE. " breit -> schmal
      FRAME-NARROW = 'X'.
      IF FIRST_FRAME = 0.
        FIRST_FRAME = FRAME_DEPTH + 1.
      ENDIF.
*     IF GL_SCREEN-TYPE = 'J' AND GL_SCREEN-NOINT IS INITIAL.
*       SUBTRACT 2 FROM: FRAME-TEXT_LENGTH, POS-LOW, POS-TOTEXT,
*                        POS-HIGH, POS-LAST,
*                        FRAME-LAST_POS_PLUS_1,
*                        FRAME-LENGTH.
*     ENDIF.
    ENDIF.
    IF FRAME-NARROW NE SPACE AND GL_SCREEN-NOINT IS INITIAL. " schmal
      CLEAR NESTING.
      READ TABLE NESTING WITH KEY G_SSCR-NUMB BINARY SEARCH.
      FRAME-LENGTH = POS-TOTEXT + 1 + PUSH_LENGTH + 1
                     - INITCOLN + 2 * NESTING-DEPTH.
*     IF GL_SCREEN-TYPE = 'J'.
*       SUBTRACT 2 FROM: FRAME-LENGTH,
*     ENDIF.
      FRAME-LAST_POS_PLUS_1 = INITCOLN + FRAME-LENGTH - 1.
      FRAME-MAX_LENG_SELOPT = FRAME-MAX_LENG_SELOPT - FRAME_MARGIN.
    ELSE.
      IF FIRST_FRAME = 0.                         " breit -> breit
        FIRST_FRAME = FRAME_DEPTH + 1.
        IF GL_SCREEN-TYPE = 'J'.
          FRAME-MAX_LENG_SELOPT = FRAME-MAX_LENG_SELOPT - FRAME_MARGIN.
        ENDIF.
      ELSE.
        FRAME-MAX_LENG_SELOPT = FRAME-MAX_LENG_SELOPT - FRAME_MARGIN.
        IF NOT GL_SCREEN-NOINT IS INITIAL
                    AND FRAME-NARROW NE SPACE.
          POS-TOTEXT = POS-TOTEXT - FRAME_MARGIN.
        ENDIF.
      ENDIF.
      FRAME-LENGTH = FRAME-LENGTH - 2 * FRAME_MARGIN.
      SUBTRACT FRAME_MARGIN FROM FRAME-LAST_POS_PLUS_1.
    ENDIF.
  ENDIF.

  FRAME-MAX_LENG_PARAM = FRAME-LAST_POS_PLUS_1 - POS-LOW - 1.
  IF FRAME-MAX_LENG_PARAM > MAX_LENG_PARAM.
    FRAME-MAX_LENG_PARAM = MAX_LENG_PARAM.
  ENDIF.

*  move-corresponding frame to frinfo.
  ADD 1 TO FRAME_DEPTH.

ENDFORM.                          " PUSH_FRAME
* Popt Frame-Stack
FORM POP_FRAME.

  DATA L_NARROW LIKE FRAME-NARROW.

  IF FRAME-FRAME NE SPACE.
    SUBTRACT FRAME_MARGIN FROM INITCOLN.
    ADD 1 TO LAST_LINE.
  ENDIF.

  IF FRAME_DEPTH = FIRST_FRAME.
    FIRST_FRAME = 0.
  ENDIF.

  L_NARROW = FRAME-NARROW.

  READ TABLE FRAME INDEX FRAME_DEPTH.
  DELETE FRAME INDEX FRAME_DEPTH.

  IF NOT L_NARROW IS INITIAL.
    IF NOT GL_SCREEN-NOINT IS INITIAL.
      POS-TOTEXT = POS-TOTEXT + FRAME_MARGIN.
*    ELSEIF GL_SCREEN-TYPE = 'J' AND FRAME-NARROW IS INITIAL.
*      ADD 2 TO: POS-LOW, POS-TOTEXT, POS-HIGH, POS-LAST.
    ENDIF.
  ENDIF.

  SUBTRACT 1 FROM FRAME_DEPTH.

ENDFORM.                           " POP_FRAME

*----------------------------------------------------------------------*
*   Generiert Kommentare in Ablaufsteuereung                           *
*----------------------------------------------------------------------*
FORM GEN_COMMENT.

  D020T-PROG = GLOBAL-PROG.
  D020T-DYNR = GL_SCREEN-NUMBER.
  SCREEN_INFO-DYNNR = GL_SCREEN-NUMBER.
  D020T-LANG = D020S-SPRA.
  D020T-DTXT = SCREEN_INFO.
  UPDATE D020T.
  IF SY-SUBRC NE 0.
    INSERT D020T.
  ENDIF.
  delete from d020t where prog = global-prog
                    and   dynr = GL_SCREEN-NUMBER
                    and   lang ne D020S-SPRA.

ENDFORM.
* Fehlerfall: Bild zu groß
FORM SCREEN_TOO_LARGE.
  CLEAR G_SSCR.
  PERFORM FILL_GEN_MESSAGE USING 'SIZE'
                                     0       0
                                     G_SSCR.

ENDFORM.                            " SCREEN_TOO_LARGE.
* Generiert Dummyfeld für Laufzeit
FORM GEN_RUNTIME_INFO USING LINE.

  CLEAR F.
  F-FNAM = SCR_RUNT_INFO.
  F-COLN = INITCOLN + 2.
  F-LINE = LINE + 1.
  F-LENG = 1.
  F-TYPE = 'CHAR'.
  F-ITYP = 'C'.
  F-FLG1 = FLG1_TEXT.
*  F-FMB1 = FMB1_INACTIVE.
  F-STXT = '-'.
  F-GRP4 = 'SRI'.                      " SCREEN RUNTIME INFO
  APPEND F.
  CLEAR F.

ENDFORM.                               " GEN_RUNTIME_INFO

*----------------------------------------------------------------------*
*   Die Routine generiert die Aufrufe aller PBO-Module                 *
*----------------------------------------------------------------------*
FORM GEN_PBO.

  DATA L_TABS.

  MOVE 'PROCESS BEFORE OUTPUT.' TO T-LINE.
  APPEND T. CLEAR T. APPEND T.
  IF D020S-TYPE NE 'J'.
    MOVE 'MODULE %_INIT_PBO.' TO T-LINE.
  ELSE.
    MOVE 'MODULE %_INIT_PBO_J.' TO T-LINE.
  ENDIF.
  APPEND T. CLEAR T. APPEND T.
* if sy-uname ne 'BINDEWALD' or global-prog ne 'BITEST01'.
*  if sy-saprl < '50A'.
*    MOVE 'MODULE PBO_REPORT.' TO T-LINE.
*  else.
    MOVE 'MODULE %_PBO_REPORT.' TO T-LINE.
*  endif.
  APPEND T. CLEAR T. APPEND T.

* if d020s-type ne 'J'.
    MOVE 'MODULE %_PF_STATUS.' TO T-LINE.
    APPEND T. CLEAR T. APPEND T.
* endif.

  LOOP AT G_SSCR WHERE FLAG1 Z SSCR_F1_NODI.   " NO-DISPLAY
*                AND   FLAG2 Z SSCR_F2_REFR.   " Just reference
    IF G_SSCR-KIND = 'S'.
      PERFORM PBO_MODULE USING G_SSCR-NAME.
    ELSEIF G_SSCR-KIND = 'P' AND G_SSCR-FLAG1 O SSCR_F1_IXST.
*      AS INDEX STRUCTURE
      PERFORM PBO_MODULE USING 'LDB_SEARCH'.
    ELSEIF G_SSCR-KIND = 'P' AND G_SSCR-FLAG2 O SSCR_F2_DYN.
*      Dynamischer Bezug
      PERFORM PBO_MODULE USING G_SSCR-NAME.
    ELSEIF G_SSCR-KIND = 'K' AND G_SSCR-NAME+2(3) = '%_T'
      AND G_SSCR-APPENDAGE = 'E' AND L_TABS NE SPACE.
        CLEAR L_TABS.
      PERFORM CALL_SUBSCREEN_PBO USING G_SSCR.
    ELSEIF G_SSCR-KIND = 'H' AND G_SSCR-MISCELL = 'T'             OR
           G_SSCR-KIND = 'K' AND G_SSCR-NAME+2(3) = '%_T'
      AND G_SSCR-APPENDAGE = 'A' AND G_SSCR-FLAG1 O SSCR_F1_SUBS.
      L_TABS = 'X'.
    ENDIF.
  ENDLOOP.

  MOVE 'MODULE %_END_OF_PBO.' TO T-LINE.
  APPEND T. CLEAR T. APPEND T.

ENDFORM.

*----------------------------------------------------------------------*
*   Die Routine generiert aufrufe aller PAI-Module                     *
*   ausser END_OF_SCREEN                                               *
*----------------------------------------------------------------------*
FORM GEN_PAI.

  DATA L_TABS.

  SORT: PAR_CHECKTAB BY NAME,
        PAR_FIXVAL BY NAME.

  MOVE 'PROCESS AFTER INPUT.' TO T-LINE.
  APPEND T. CLEAR T. APPEND T.

  if gl_screen-type ne 'J'.
    MOVE 'MODULE %_BACK AT EXIT-COMMAND.' TO T-LINE+2.
    APPEND T. CLEAR T. APPEND T.
  endif.

  IF D020S-TYPE NE 'J'.
    MOVE 'MODULE %_INIT_PAI.' TO T-LINE+2.
  ELSE.
    MOVE 'MODULE %_INIT_PAI_J.' TO T-LINE+2.
  ENDIF.
  APPEND T. CLEAR T. APPEND T.

  LOOP AT G_SSCR WHERE FLAG1 Z SSCR_F1_NODI.   " NO-DISPLAY
*                AND   FLAG2 Z SSCR_F2_REFR.   " Just reference
    CASE G_SSCR-KIND.
      WHEN 'S'.
        PERFORM PAI_MODULE USING G_SSCR-NAME.
      WHEN 'P'.
        IF G_SSCR-FLAG1 O SSCR_F1_IXST.   " AS INDEX STRUCTURE
          PERFORM PAI_LDBINDEX.
        ELSEIF G_SSCR-FLAG1 O SSCR_F1_RADI. " Radiobutton
          PERFORM PAI_RADIO USING G_SSCR.
        ELSE.                             " Kein AS INDEX STRUCTURE
          PERFORM PAI_FIELDS USING G_SSCR-NAME.
        ENDIF.
      WHEN 'K'.                     " Block
        CASE G_SSCR-APPENDAGE.
          WHEN 'A'.                 " BEGIN OF BLOCK
            IF G_SSCR-OFFSET = 0.
              UNPACK G_SSCR-NUMB TO BLOCKLINES-BLOCKNUM.
            ELSE.
              UNPACK G_SSCR-OFFSET TO BLOCKLINES-BLOCKNUM.
            ENDIF.
            DESCRIBE TABLE BLOCK_T LINES SY-TFILL.
            BLOCKLINES-FIELD_TABIX = SY-TFILL + 1.
            IF   BLOCKLINES-NARROW = SPACE AND
                 G_SSCR-FLAG1 O SSCR_F1_NOIN AND
                 G_SSCR-NAME+2(3) NE '%__'.
              MOVE 'X' TO BLOCKLINES-NARROW.
            ENDIF.
            INSERT BLOCKLINES INDEX 1.
            IF G_SSCR-NAME(5) = '%B%_T' AND G_SSCR-FLAG1 O SSCR_F1_SUBS.
              L_TABS = 'X'.
            ENDIF.
          WHEN 'E'.                 " END OF BLOCk
            PERFORM PAI_BLOCK USING L_TABS.
            CLEAR L_TABS.
        ENDCASE.
      WHEN 'H'.                     " Pushbutton.
        IF G_SSCR-MISCELL = 'T'.
          L_TABS = 'X'.
        ENDIF.
    ENDCASE.
  ENDLOOP.

ENDFORM.

*----------------------------------------------------------------------*
*   Die Routine generiert den END_OF_SCREEN Aufruf                     *
*----------------------------------------------------------------------*
FORM GEN_END_MODULES.

  MOVE 'CHAIN.' TO T-LINE.
  APPEND T.
  MOVE '  FIELD' TO T-LINE.
  LOOP AT BLOCK_T.
    APPEND BLOCK_T TO T.
  ENDLOOP.

*  if sy-uname ne 'BINDEWALD' or global-prog ne 'BITEST01'.
*  if sy-saprl < '50A'.
*    MOVE '  MODULE END_OF_SCREEN.' TO T-LINE.
*  else.
    MOVE '  MODULE %_END_OF_SCREEN.' TO T-LINE.
*  endif.
  APPEND T.
* Module OK_CODE_1000
  MOVE '  MODULE %_OK_CODE_1000.' TO T-LINE.
  APPEND T.
  MOVE 'ENDCHAIN.' TO T-LINE.
  APPEND T.

ENDFORM.
*----------------------------------------------------------------------*
*   Die Routine generiert die Module ON VALUE REQUEST                  *
*----------------------------------------------------------------------*
FORM GEN_VALUE_MODULES.

  DATA L_MODULENAME(30).

  CHECK GL_SCREEN-IX NE 0 OR GL_SCREEN-VAL_REQ NE SPACE.

  CLEAR T-LINE. APPEND T.

  MOVE 'PROCESS ON VALUE-REQUEST.' TO T-LINE. APPEND T.

  IF GL_SCREEN-IX NE 0.
    READ TABLE G_SSCR INDEX GL_SCREEN-IX.
    IF GL_SCREEN-IX_SIMPLE EQ SPACE.
      MOVE '  FIELD SSCRTEXTS-TEXT_MCID MODULE %_SP_SPIDTX_VALUES.'
               TO T-LINE.
      APPEND T.
      MOVE '  FIELD' TO T-LINE.
      PERFORM CD_FIELD_NAME USING SPACE G_SSCR-NAME '-' 'HOTKEY'
                            CHANGING T-LINE+8(64).
      MOVE 'MODULE %_SP_SPID_VALUES.' TO T-LINE+24.
      CONDENSE T-LINE+8.
      APPEND T.
    ENDIF.
    MOVE '  FIELD' TO T-LINE.
    PERFORM CD_FIELD_NAME USING SPACE G_SSCR-NAME '-' 'STRING'
                          CHANGING T-LINE+8(64).
    MOVE 'MODULE %_SP_STRING_VALUES.' TO T-LINE+24.
    CONDENSE T-LINE+8.
    APPEND T.

  ENDIF.

  IF GL_SCREEN-VAL_REQ NE SPACE.

    MOVE '  FIELD' TO T-LINE.

    LOOP AT G_SSCR.
      CHECK
          ( G_SSCR-FLAG2 O SSCR_F2_VRLO OR G_SSCR-FLAG2 O SSCR_F2_VRHI )
        AND ( G_SSCR-KIND = 'S' OR G_SSCR-KIND = 'P' )
        AND   G_SSCR-FLAG1 Z SSCR_F1_NODI.  " Vorsichtshalber.
      CASE G_SSCR-KIND.
        WHEN 'S'.
          IF G_SSCR-FLAG2 O SSCR_F2_VRLO.
            PERFORM CD_FIELD_NAME USING '%_' G_SSCR-NAME '-'
                                        'LOW_VAL'
                            CHANGING L_MODULENAME.
            PERFORM FIELD_NAME USING SPACE 'LOW' G_SSCR-NAME
                               CHANGING T-LINE+8(64).
            MOVE 'MODULE' TO T-LINE+23.
            MOVE L_MODULENAME TO T-LINE+30.
            MOVE '.' TO T-LINE+62.
            CONDENSE T-LINE+8.
            APPEND T.
          ENDIF.
          IF G_SSCR-FLAG2 O SSCR_F2_VRHI AND
             G_SSCR-FLAG1 Z SSCR_F1_NOIN.
            PERFORM CD_FIELD_NAME USING '%_' G_SSCR-NAME '-'
                                        'HIGH_VAL'
                            CHANGING L_MODULENAME.
            PERFORM FIELD_NAME USING SPACE 'HIGH' G_SSCR-NAME
                               CHANGING T-LINE+8(64).
            MOVE 'MODULE' TO T-LINE+23.
            MOVE L_MODULENAME TO T-LINE+30.
            MOVE '.' TO T-LINE+62.
            CONDENSE T-LINE+8.
            APPEND T.
          ENDIF.
        WHEN 'P'.
          IF G_SSCR-FLAG2 O SSCR_F2_VRLO.
            PERFORM CD_FIELD_NAME USING '%_' G_SSCR-NAME '_' 'VAL'
                                  CHANGING L_MODULENAME.
            MOVE G_SSCR-NAME TO T-LINE+8.
            MOVE 'MODULE' TO T-LINE+23.
            MOVE L_MODULENAME TO T-LINE+30.
            MOVE '.' TO T-LINE+54.
            CONDENSE T-LINE+8.
            APPEND T.
        ENDIF.
      ENDCASE.
    ENDLOOP.

  ENDIF.

ENDFORM.                       " GEN_VALUE_MODULES
*----------------------------------------------------------------------*
*   Die Routine generiert die Module ON HELP-REQUEST                   *
*----------------------------------------------------------------------*
FORM GEN_HELP_MODULES.

  DATA L_MODULENAME(50).
  data is_comfipar type c length 1.

  CHECK GL_SCREEN-HLP_REQ NE SPACE.

  CLEAR T-LINE. APPEND T.

  MOVE 'PROCESS ON HELP-REQUEST.' TO T-LINE. APPEND T.

  MOVE '  FIELD' TO T-LINE.

  LOOP AT G_SSCR.
    CHECK
        ( G_SSCR-FLAG2 O SSCR_F2_HRLO OR G_SSCR-FLAG2 O SSCR_F2_HRHI )
      AND  G_SSCR-KIND = 'S'
      AND   G_SSCR-FLAG1 Z SSCR_F1_NODI. " Vorsichtshalber.
    IF G_SSCR-FLAG2 O SSCR_F2_HR.
      CONCATENATE 'MODULE'
                  ' %_' G_SSCR-NAME '_HLP.' INTO L_MODULENAME.
      perform is_comfipar  using g_sscr-name
                           changing is_comfipar.
      if is_comfipar is initial.
        CONCATENATE '%_' G_SSCR-NAME '_%_APP_%-TEXT' INTO T-LINE+8.
        MOVE L_MODULENAME TO T-LINE+35.
        APPEND T.
      endif.
      CONCATENATE G_SSCR-NAME '-LOW' INTO T-LINE+8.
      MOVE L_MODULENAME TO T-LINE+35.
      APPEND T.
      IF G_SSCR-FLAG1 Z SSCR_F1_NOIN.      " Kein NO INTERVALS
        CONCATENATE '%_' G_SSCR-NAME '_%_APP_%-TO_TEXT' INTO T-LINE+8.
        MOVE L_MODULENAME TO T-LINE+35.
        APPEND T.
        CONCATENATE G_SSCR-NAME '-HIGH' INTO T-LINE+8.
        MOVE L_MODULENAME TO T-LINE+35.
        APPEND T.
      ENDIF.
    ELSE.
    IF G_SSCR-FLAG2 O SSCR_F2_HRLO.
      PERFORM CD_FIELD_NAME USING '%_' G_SSCR-NAME '-'
                                  'LOW_HLP'
                      CHANGING L_MODULENAME.
      PERFORM FIELD_NAME USING SPACE 'LOW' G_SSCR-NAME
                         CHANGING T-LINE+8(64).
      MOVE 'MODULE' TO T-LINE+23.
      MOVE L_MODULENAME TO T-LINE+30.
      MOVE '.' TO T-LINE+62.
      CONDENSE T-LINE+8.
      APPEND T.
    ENDIF.
    IF G_SSCR-FLAG2 O SSCR_F2_HRHI AND
       G_SSCR-FLAG1 Z SSCR_F1_NOIN.
      PERFORM CD_FIELD_NAME USING '%_' G_SSCR-NAME '-'
                                  'HIGH_HLP'
                      CHANGING L_MODULENAME.
      PERFORM FIELD_NAME USING SPACE 'HIGH' G_SSCR-NAME
                         CHANGING T-LINE+8(64).
      MOVE 'MODULE' TO T-LINE+23.
      MOVE L_MODULENAME TO T-LINE+30.
      MOVE '.' TO T-LINE+62.
      CONDENSE T-LINE+8.
      APPEND T.
    ENDIF.
    ENDIF.
  ENDLOOP.

  LOOP AT HELP_TAB.
    CONCATENATE '%_' HELP_TAB-NAME_FOR_MOD '_HLP' INTO L_MODULENAME.
    MOVE HELP_TAB-NAME TO T-LINE+8.
    MOVE 'MODULE' TO T-LINE+39.
    MOVE L_MODULENAME TO T-LINE+46.
    MOVE '.' TO T-LINE+70.
    CONDENSE T-LINE+8.
    APPEND T.
  ENDLOOP.

ENDFORM.                       " GEN_HELP_MODULES
form is_comfipar using selname type rsscr-name
                 changing is_comfipar.
  clear is_comfipar.
  read table comfipar with key parname = selname kind = 'S' transporting no fields.
  if sy-subrc = 0.
    is_comfipar = 'X'.
  endif.
endform.
*----------------------------------------------------------------------*
*   Die Routine generiert die FIELD Anweisung zu dem Parameter NAME    *
*----------------------------------------------------------------------*
FORM PAI_FIELDS USING NAME.
  IF G_SSCR-FLAG2 O SSCR_F2_VCHK.
    PERFORM GEN_FOREIGN_CHECK.
  ENDIF.
* if sy-uname ne 'BINDEWALD' or global-prog ne 'BITEST01'.
*  if sy-saprl < '50A'.
*  MOVE 'FIELD            MODULE' TO T-LINE.
*  MOVE '!'                     TO T-LINE+6(1).
*  MOVE NAME                    TO T-LINE+7(8).
*  MOVE '!'                     TO T-LINE+24(1).
*  MOVE NAME                    TO T-LINE+25.
*  MOVE '.'                     TO T-LINE+34.
*  CONDENSE T-LINE.
*  APPEND T.
*  MOVE SPACE TO T.
*  APPEND T.
*  MOVE '  FIELD ' TO BLOCK_T-LINE.
*  MOVE NAME TO BLOCK_T-LINE+8(8).
*  MOVE '.' TO BLOCK_T-LINE+17.
*  CONDENSE BLOCK_T-LINE+2.
*  APPEND BLOCK_T.
*  else.
  MOVE 'FIELD            MODULE' TO T-LINE.
  MOVE '!'                     TO T-LINE+6(1).
  MOVE NAME                    TO T-LINE+7(8).
  MOVE '%_'                     TO T-LINE+24(2).
  MOVE NAME                    TO T-LINE+26.
  MOVE '.'                     TO T-LINE+35.
  CONDENSE T-LINE.
  APPEND T.
  MOVE SPACE TO T.
  APPEND T.
  MOVE '  FIELD ' TO BLOCK_T-LINE.
  MOVE NAME TO BLOCK_T-LINE+8(8).
  MOVE '.' TO BLOCK_T-LINE+17.
  CONDENSE BLOCK_T-LINE+2.
  APPEND BLOCK_T.
*  endif.

ENDFORM.                        "  PAI_FIELDS

*----------------------------------------------------------------------*
*   Die Routine generiert die FIELD Anweisung zu den Matchcodefeldern  *
*----------------------------------------------------------------------*
FORM PAI_LDBINDEX.

  MOVE 'CHAIN.' TO T-LINE. APPEND T.

  PERFORM GEN_IX_FIELD_STATEMENTS.
*  if sy-uname ne 'BINDEWALD' or global-prog ne 'BITEST01'.
* if sy-saprl < '50A'.
*    MOVE '  MODULE LDB_SEARCH.' TO T-LINE. APPEND T.
*  else.
    MOVE '  MODULE %_LDB_SEARCH.' TO T-LINE. APPEND T.
*  endif.

  MOVE 'ENDCHAIN.' TO T-LINE. APPEND T.
  CLEAR T-LINE. APPEND T.

ENDFORM.                               "pai_ldbindex
* Generiert Chain für RADIOBUTTON-Gruppe
FORM PAI_RADIO USING P_SSCR STRUCTURE RSSCR.

  DATA L_TABIX LIKE SY-TABIX.

  DATA: BEGIN OF L_MODULE,
          PREFIX(29) VALUE '    MODULE RADIOBUTTON_GROUP_',
          MIDFIX LIKE RSSCR-MATCHCODE,
          SUFFIX VALUE '.',
        END   OF L_MODULE.

  DATA: BEGIN OF j_MODULE,
          PREFIX(31) VALUE '    MODULE %_RADIOBUTTON_GROUP_',
          MIDFIX LIKE RSSCR-MATCHCODE,
          SUFFIX VALUE '.',
        END   OF j_MODULE.

  DATA: BEGIN OF L_FIELD,
          PREFIX(8) VALUE '  FIELD ',
          MIDFIX LIKE RSSCR-NAME,
          SUFFIX VALUE '.',
        END   OF L_FIELD.
   data l_radio(4).
    if not g_sscr-matchcode+4(1) is initial.   " User-Command
      if g_sscr-matchcode+4(3) = '%UC'.
        l_radio = g_sscr-matchcode(4).
      elseif g_sscr-matchcode+3(3) = '%UC'.
        l_radio = g_sscr-matchcode(3).
      elseif g_sscr-matchcode+2(3) = '%UC'.
        l_radio = g_sscr-matchcode(2).
      elseif g_sscr-matchcode+1(3) = '%UC'.
        l_radio = g_sscr-matchcode(1).
      endif.
    else.
      l_radio = g_sscr-matchcode.
    endif.

  READ TABLE RADIO_GROUPS WITH KEY group = l_radio
                                BINARY SEARCH.
  CHECK SY-SUBRC = 0.
  L_TABIX = SY-TABIX.

  MOVE 'CHAIN.' TO T-LINE. APPEND T.

  LOOP AT RADIO_GROUPS-PARAMS INTO L_FIELD-MIDFIX.
    MOVE L_FIELD TO T-LINE. APPEND T.
    APPEND T TO BLOCK_T.
  ENDLOOP.

*  if sy-uname ne 'BINDEWALD' or global-prog ne 'BITEST01'.
* if sy-saprl < '50A'.
*    MOVE P_SSCR-MATCHCODE TO L_MODULE-MIDFIX.
*    MOVE L_MODULE TO T-LINE. APPEND T.
*  else.
    MOVE l_radio TO j_MODULE-MIDFIX.
    MOVE j_MODULE TO T-LINE. APPEND t.
*  endif.
  MOVE 'ENDCHAIN.' TO T-LINE. APPEND T.
  CLEAR T-LINE. APPEND T.

  DELETE RADIO_GROUPS INDEX L_TABIX.

ENDFORM.                                   " PAI_RADIO
* Generiert PAI-Anweisungen für einen Block
FORM PAI_BLOCK USING P_TABS.

  DATA: BEGIN OF MODULE_STMT_NEW,
          PREFIX(17) VALUE '    MODULE BLOCK_',
          MIDFIX TYPE SYDB0_BLOCKNUM,
          SUFFIX(1) VALUE '.',
        END   OF MODULE_STMT_NEW.

  DATA: BEGIN OF l_MODULE_STMT_NEW,
          PREFIX(19) VALUE '    MODULE %_BLOCK_',
          MIDFIX TYPE SYDB0_BLOCKNUM,
          SUFFIX(1) VALUE '.',
        END   OF l_MODULE_STMT_NEW.


  DATA L_FIRST VALUE 'X'.

  READ TABLE BLOCKLINES INDEX 1.
  CHECK SY-SUBRC = 0.
  DELETE BLOCKLINES INDEX 1.
  APPEND T.
  CLEAR T.
  LOOP AT BLOCK_T FROM BLOCKLINES-FIELD_TABIX.
    IF L_FIRST = 'X'.
      L_FIRST = SPACE.
      MOVE 'CHAIN.' TO T-LINE.
      APPEND T. CLEAR T.
    ENDIF.
    APPEND BLOCK_T TO T.
  ENDLOOP.
  IF L_FIRST = SPACE.
*    if sy-uname ne 'BINDEWALD' or global-prog ne 'BITEST01'.
*   if sy-saprl < '50A'.
*      MOVE BLOCKLINES-BLOCKNUM TO MODULE_STMT_NEW-MIDFIX.
*      MOVE MODULE_STMT_NEW TO T-LINE.
*      APPEND T. CLEAR T.
*    else.
      MOVE BLOCKLINES-BLOCKNUM TO l_MODULE_STMT_NEW-MIDFIX.
      MOVE l_MODULE_STMT_NEW TO T-LINE.
      APPEND T. CLEAR T.
*    endif.
    MOVE 'ENDCHAIN.' TO T-LINE.
    APPEND T. CLEAR T. APPEND T.
  ENDIF.

  CLEAR BLOCKLINES.
  IF G_SSCR-NAME+2(3) = '%_T' AND P_TABS NE SPACE.
    PERFORM CALL_SUBSCREEN_PAI USING G_SSCR.
  ENDIF.

ENDFORM.                             " PAI_BLOCK.
* Generiert FIELD-Anweisungen für alle Teile des Indexparameters
FORM GEN_IX_FIELD_STATEMENTS.

  DATA FIELDNAME(30).

  MOVE '  FIELD' TO T-LINE.
  IF GL_SCREEN-IX_SIMPLE EQ SPACE.
    PERFORM CD_FIELD_NAME USING SPACE  G_SSCR-NAME '-' 'HOTKEY'
                          CHANGING T-LINE+10(20).
    MOVE '.' TO T-LINE+25.
    APPEND T.
    APPEND T TO BLOCK_T.
  ENDIF.
  PERFORM CD_FIELD_NAME USING SPACE  G_SSCR-NAME '-' 'STRING'
                        CHANGING T-LINE+10(20).
  MOVE '.' TO T-LINE+25.
  APPEND T.
  APPEND T TO BLOCK_T.

ENDFORM.                                  " GEN_IX_FIELD_STATEMENTS.

*----------------------------------------------------------------------*
*   Die Routine generiert den PBO-Modul zu dem Uebergabeparameter      *
*   PM_NAME                                                            *
*----------------------------------------------------------------------*
FORM PBO_MODULE USING PM_NAME.

* if sy-uname ne 'BINDEWALD' or global-prog ne 'BITEST01'.
* if sy-saprl < '50A'.
*  MOVE: '!' TO T-LINE,
*        PM_NAME TO T-LINE+1,
*        '.'     TO T-LINE+20.
*  CONDENSE T-LINE NO-GAPS.
* else.
  concatenate '%_' PM_NAME '.' into t-line .
* endif.
  SHIFT T-LINE RIGHT BY 7 PLACES.
  MOVE 'MODULE' TO T-LINE(6).
  APPEND T.

  CLEAR T.
  APPEND T.

ENDFORM.

* Generiert CALL SUBSCREEN PBO
FORM CALL_SUBSCREEN_PBO USING G_SSCR LIKE RSSCR.

  DATA: L_NAME(100), L_NAME_P(100), L_NAME_D(100).

  CONCATENATE '%_SUBSCREEN_' G_SSCR-DBFIELD INTO L_NAME.
  CONCATENATE G_SSCR-DBFIELD '-PROG' INTO L_NAME_P.
  CONCATENATE G_SSCR-DBFIELD '-DYNNR.' INTO L_NAME_D.
  CONCATENATE '  CALL SUBSCREEN' L_NAME INTO T-LINE SEPARATED BY SPACE.
  APPEND T. CLEAR T.
  if g_sscr-name+5(3) ne 'AAA'.
    CONCATENATE  'INCLUDING' L_NAME_P
        L_NAME_D INTO T-LINE+2 SEPARATED BY SPACE.
  else.
    CONCATENATE  'INCLUDING' '''SAPLSSEL'''
        '''2001''' '.' INTO T-LINE+2 SEPARATED BY SPACE.
  endif.
  APPEND T. CLEAR T.
  APPEND T.

ENDFORM.                      "CALL_SUBSCREEN_PBO
*----------------------------------------------------------------------*
*   Die Routine generiert die Kette der PAI_Module zu dem Uebergabe-   *
*   parameter PM_NAME.                                                 *
*----------------------------------------------------------------------*
FORM PAI_MODULE USING PM_NAME.
  data l_line(50).
  T-LINE = 'CHAIN.'.
  APPEND T.
  PERFORM FIELD_NAME USING SPACE 'LOW' PM_NAME CHANGING T-LINE.
  MOVE '.' TO T-LINE+70(1).
  CONDENSE T-LINE NO-GAPS.
  SHIFT T-LINE RIGHT BY 9 PLACES.
  MOVE 'FIELD' TO T-LINE+2(5).
  APPEND T.
  APPEND T TO BLOCK_T.

  IF   G_SSCR-FLAG1 Z SSCR_F1_NOIN.      " Kein NO INTERVALS
*      blocklines-no_intervals = space.  " Kein NO INTERVALS für Block
    PERFORM FIELD_NAME USING SPACE 'HIGH' PM_NAME CHANGING T-LINE.
    MOVE '.' TO T-LINE+70(1).
    CONDENSE T-LINE NO-GAPS.
    SHIFT T-LINE RIGHT BY 9 PLACES.
    MOVE 'FIELD' TO T-LINE+2(5).
    APPEND T.
    APPEND T TO BLOCK_T.
  ENDIF.                               " Kein 'NO INTERVALS

*  if sy-uname ne 'BINDEWALD' or global-prog ne 'BITEST01'.
* if sy-saprl < '50A'.
*  MOVE: '  MODULE' TO T-LINE,
*        '!' TO T-LINE+9(1),
*        PM_NAME  TO T-LINE+10,
*        '.' TO T-LINE+50.
*  CONDENSE T-LINE+2.
*  else.
    concatenate '%_' pm_name '.' into l_line.
    concatenate '  MODULE' l_line into t-line separated by space.
*  endif.
  APPEND T.
  MOVE 'ENDCHAIN.' TO T-LINE.
  APPEND T.

  CLEAR T.
  APPEND T.

ENDFORM.
*-----------------------------------------------------------------------
* Generiert CALL SUBSCREEN PAI
FORM CALL_SUBSCREEN_PAI USING G_SSCR LIKE RSSCR.

  DATA: L_NAME(100).

  CONCATENATE '%_SUBSCREEN_' G_SSCR-DBFIELD INTO L_NAME.
  CONCATENATE '  CALL SUBSCREEN'   L_NAME '.' INTO T-LINE
    SEPARATED BY SPACE.
  APPEND T. CLEAR T.
  APPEND T.

ENDFORM.                      "CALL_SUBSCREEN_PBO
*----------------------------------------------------------------------*
*   Die Routine generiert Fremschluesselpruefungen.                    *
*   wird vorlauefig nicht genutzt.                                     *
*----------------------------------------------------------------------*
FORM GEN_FOREIGN_CHECK.

  DATA L_TEXT LIKE RSDSWHERE OCCURS 0 WITH HEADER LINE.

  READ TABLE PAR_CHECKTAB WITH KEY G_SSCR-NAME BINARY SEARCH.
  IF SY-SUBRC = 0.
    CONCATENATE 'FIELD' G_SSCR-NAME INTO T SEPARATED BY SPACE.
    APPEND T.
    CLEAR T.
    PERFORM BUILD_DYNP_SELECT(RSDBSPF4) TABLES   L_TEXT
                                        USING    G_SSCR-NAME
                                                 G_SSCR-DBFIELD.
    APPEND LINES OF L_TEXT TO T.
    APPEND T.
    EXIT.
  ENDIF.

  READ TABLE PAR_FIXVAL WITH KEY G_SSCR-NAME BINARY SEARCH.
  IF SY-SUBRC = 0.
    CONCATENATE 'FIELD' G_SSCR-NAME INTO T SEPARATED BY SPACE.
    APPEND T.
    CLEAR T.
    PERFORM BUILD_VALUES TABLES   L_TEXT
                         USING    PAR_FIXVAL-DD07V.
    APPEND LINES OF L_TEXT TO T.
    APPEND T.
  ENDIF.

ENDFORM.
* Baut VALUES-Zusatz auf.
FORM BUILD_VALUES TABLES   P_TEXT STRUCTURE RSDSWHERE
                  USING    P_DD07V LIKE PAR_FIXVAL-DD07V.

  DATA L_TEXT LIKE RSDSWHERE-LINE.
  DATA L_HELP LIKE RSDSWHERE-LINE.
  DATA L_HELP_2 LIKE RSDSWHERE-LINE.
  DATA L_HELP_3(2) VALUE ','.
  DATA L_TFILL LIKE SY-TFILL.
  FIELD-SYMBOLS <L_DD07V> LIKE DD07V.

  DESCRIBE TABLE P_DD07V LINES L_TFILL.
  L_TEXT = '  VALUES ('.
  LOOP AT P_DD07V ASSIGNING <L_DD07V>.
    IF SY-TABIX = L_TFILL.
      L_HELP_3 = ').'.
    ENDIF.
    IF <L_DD07V>-DOMVALUE_H IS INITIAL.
      IF <L_DD07V>-DOMVALUE_L IS INITIAL.
        CONCATENATE ''' ''' L_HELP_3 INTO L_TEXT+10.
      ELSE.
        CONCATENATE '''' <L_DD07V>-DOMVALUE_L '''' L_HELP_3
                                                   INTO L_TEXT+10.
      ENDIF.
    ELSE.
      IF <L_DD07V>-DOMVALUE_L IS INITIAL.
        L_HELP = ''' '''.
      ELSE.
        CONCATENATE '''' <L_DD07V>-DOMVALUE_L '''' INTO L_HELP.
      ENDIF.
      CONCATENATE '''' <L_DD07V>-DOMVALUE_H '''' INTO L_HELP_2.
      CONCATENATE 'BETWEEN' L_HELP 'AND' L_HELP_2 L_HELP_3
                  INTO L_TEXT+10 SEPARATED BY SPACE.
    ENDIF.
    APPEND L_TEXT TO P_TEXT.
    CLEAR L_TEXT.
  ENDLOOP.

ENDFORM.

FORM CHECK_DYNPRO_EXISTS USING ORDER.

  DATA BEGIN OF LOCAL_D020S.
          INCLUDE STRUCTURE D020S.
  DATA   END OF LOCAL_D020S.

  CLEAR EXITFLAG.

  SELECT SINGLE * INTO LOCAL_D020S FROM D020S
         WHERE PROG = GLOBAL-PROG
         AND   DNUM = GL_SCREEN-NUMBER.

  CHECK SY-SUBRC = 0 AND LOCAL_D020S-TYPE NE 'S'
                     AND LOCAL_D020S-TYPE NE 'W'
                     AND LOCAL_D020S-TYPE NE 'J'.

  IF ORDER = 'RETURN'.
    MOVE 'X' TO EXITFLAG.
    EXIT.
  ENDIF.

  CLEAR G_SSCR.
  PERFORM FILL_GEN_MESSAGE USING 'EXIST'
                                 0       0
                                 G_SSCR.
  EXIT.

ENDFORM.
* Löst die SSCR-Einträge vom Typ D raus
FORM ISOLATE_DYNS_TABLES TABLES P_SSCR STRUCTURE RSSCR.

  GLOBAL-DYNSEL_ACTIVE = 'N'.

  LOOP AT P_SSCR WHERE KIND = 'D'.
    MOVE P_SSCR-DBFIELD TO DYNSEL_TABLES-TABLENAME.
    APPEND DYNSEL_TABLES.
    MOVE 'X' TO: GLOBAL-DYNSEL_ACTIVE.
    DELETE P_SSCR.
  ENDLOOP.

ENDFORM.                                " ISOLATE_DYNS_TABLES
*---------------------------------------------------------------------*
*  Eingabefelder zu Parameter und SELECT-OPTIONS                      *
*---------------------------------------------------------------------*
FORM FIELD_ATTRIBUTES CHANGING P_D021S LIKE D021S.

  DATA SUBRC LIKE SY-SUBRC.
  DATA L_GRP4(3) TYPE N.
  field-symbols <d021s_res1> type d021s_res1.
  P_D021S-COLN = CURCOLN.
  P_D021S-LINE = CURLINE.
  P_D021S-DIDX = 0.

  L_GRP4 = G_SSCR-NUMB MOD 1000.
  MOVE L_GRP4 TO P_D021S-GRP4.

* ABAP-Typ umsetzen in Screenpaintertyp
  IF G_SSCR-KIND = 'C' OR G_SSCR-KIND = 'U'.
    P_D021S-ITYP = 'C'.
    P_D021S-TYPE = 'CHAR'.
  ELSE.
    P_D021S-ITYP = G_SSCR-TYPE.
    P_D021S-TYPE = G_SSCR-DTYP.
  ENDIF.

  P_D021S-LENG = G_SSCR-OLENGTH.
  if g_sscr-type = 'g'.
    P_D021S-LENG = 255.
  endif.

  PERFORM SET_DIDX USING P_D021S G_SSCR.

  IF G_SSCR-GROUP1 NE SPACE.
    MOVE G_SSCR-GROUP1 TO P_D021S-GRP1.
  ENDIF.
  P_D021S-FLG1 = FLG1_FIELD.
  IF G_SSCR-DB = 'X'.
    P_D021S-GRP2 = 'DBS'.
  ENDIF.
  IF G_SSCR-LOWER GT SPACE.            " Groß-Kleinschreibung
    P_D021S-FLG2 = FLG2_LETT.
  ENDIF.
  IF G_SSCR-MATCHCODE GT SPACE.        " Matchcode
    MOVE G_SSCR-MATCHCODE TO P_D021S-DMAC.
  ENDIF.
  P_D021S-FLG3 = FLG3_OUT.

  IF G_SSCR-SPAGPA GT SPACE.           " Memory-id
    ADD FLG2_SPA_GPA TO P_D021S-FLG2.
    MOVE G_SSCR-SPAGPA TO P_D021S-PAID.
  ENDIF.
  IF G_SSCR-APPENDAGE = 'O'.           " Obligatorische Eingabe
    P_D021S-FLG3 = FLG3_OBLIGATORY + FLG3_OUT.
  ENDIF.
* VALUE-REQUEST
  IF G_SSCR-FLAG2 O SSCR_F2_VRLO AND P_D021S-FMB2 Z FMB2_COMBO.
    P_D021S-FMB2 = P_D021S-FMB2 + FMB2_COMBO + FMB2_CMB_FORCE.
  ENDIF.
* Freie Abgrenzungen/Dynamische Objekte: FixFont
  if global-prog = 'SAPLSSEL' and g_sscr-kind = 'S'  or
     g_sscr-flag2 o SSCR_F2_DYN.
    P_D021S-FMB1 = P_D021S-FMB1 bit-or FMB1_FIXFONT.
  endif.
* Eigenschaften aus dem Data Dictionary
  SUBRC = 4.

  IF G_SSCR-KIND = 'S' OR G_SSCR-FLAG1 Z SSCR_F1_RADI.
    IF G_SSCR-DBFIELD NE SPACE AND G_SSCR-DBFIELD(6) NE '%_DCB%'.
       PERFORM GET_DD_ATTRIBUTES CHANGING P_D021S SUBRC.
    ELSE.
       PERFORM DATA_DESCRIPTION USING G_SSCR P_D021S.
    ENDIF.
  ENDIF.

  IF ( P_D021S-ITYP = 'P' OR "packed
       P_D021S-ITYP = 'I' OR P_D021S-ITYP = 's' or P_D021S-ITYP = '8' or "integer 2/4/8
       p_d021s-ityp = 'a' or p_d021s-ityp = 'e' ) "decfloat 16/34
      AND  G_SSCR-OLENGTH > 1.
    IF SUBRC NE 0.
      ADD FLG3_VRZ TO P_D021S-FLG3.
    ENDIF.
  ENDIF.

  IF   ( P_D021S-ITYP = 'P' "packed
         OR P_D021S-ITYP = 'I' OR P_D021S-ITYP = 's' OR P_D021S-ITYP = '8' OR P_D021S-ITYP = 'b' "integer 1/2/4/8
         OR P_D021S-ITYP = 'N' )
      AND  G_SSCR-OLENGTH > 1 AND P_D021S-UCNV = SPACE.
    ADD FLG2_RIGHT TO P_D021S-FLG2.
  ENDIF.

* Set outputstyle for decfloat fields
  if  ( p_d021s-ityp = 'a' or p_d021s-ityp = 'e' ).
    if subrc ne 0.
      assign p_d021s-res1 to <d021s_res1> casting.
      <d021s_res1>-outputstyle = scrp_ostyle_default.
    endif.
  endif.

  IF P_D021S-UCNV = SPACE.
    MOVE G_SSCR-MISCELL TO P_D021S-UCNV.
  ENDIF.

  PERFORM FIELD_TEXT USING
                  P_D021S-LENG P_D021S-ITYP P_D021S-ADEZ P_D021S-FLG3
         CHANGING P_D021S-STXT.

  IF P_D021S-LENG > P_D021S-DIDX+1(1).
    IF P_D021S-FLG1 Z FLG1_ROLL.
      ADD FLG1_ROLL TO P_D021S-FLG1.
    ENDIF.
  ENDIF.
ENDFORM.                            " FIELD_ATTRIBUTES
* Setzt visualisierte Länge.
FORM SET_DIDX USING P_F LIKE F P_SSCR LIKE RSSCR.

  DATA L_MAX_LENG TYPE I.
  CASE P_SSCR-KIND.
    WHEN 'S'.
      IF   FRAME-NARROW EQ SPACE      AND     " Breiter Rahmen
           P_SSCR-FLAG1 Z SSCR_F1_NOIN        " Kein NO INTERVALS
       OR GL_SCREEN-NOINT NE SPACE.
        L_MAX_LENG = FRAME-MAX_LENG_SELOPT.
      ELSE.
        L_MAX_LENG = MAX_LENG_SELOPT.     " NO INTERVALS
      ENDIF.
      IF NOT P_SSCR-OFFSET IS INITIAL AND P_SSCR-OFFSET < L_MAX_LENG.
         L_MAX_LENG = P_SSCR-OFFSET.
      ENDIF.
      IF P_F-LENG > L_MAX_LENG.
        P_F-DIDX+1(1) = L_MAX_LENG.
        IF P_F-LENG > MAX_ILENG_SELOPT.
          P_F-LENG = MAX_ILENG_SELOPT.
        ENDIF.
      ELSE.
        P_F-DIDX+1(1) = P_F-LENG.
      ENDIF.
    WHEN 'P'.
      IF NOT P_SSCR-OFFSET IS INITIAL AND
                  P_SSCR-OFFSET < MAX_LENG_PARAM.
         L_MAX_LENG = P_SSCR-OFFSET.
      ELSE.
         L_MAX_LENG = MAX_LENG_PARAM.
      ENDIF.
      IF P_F-LENG > L_MAX_LENG.
        P_F-DIDX+1(1) = L_MAX_LENG.
        IF P_F-LENG > MAX_ILENG_PARAM.
          P_F-LENG = MAX_ILENG_PARAM.
        ENDIF.
      ELSE.
        P_F-DIDX+1(1) = P_F-LENG.
      ENDIF.
  ENDCASE.

ENDFORM.                                             " SET_DIDX

*----------------------------------------------------------------------*
*   Die Routine generiert die Text-Felder:                             *
*              KONTO-$$TEST, KONTO-$$BIS, KONTO-$$MORE                 *
*----------------------------------------------------------------------*
FORM TEXT_ATTRIBUTES USING P_LENG
                     CHANGING P_D021S LIKE D021S.

  P_D021S-COLN = CURCOLN.
  P_D021S-LINE = CURLINE.
  P_D021S-DIDX = 0.
  P_D021S-LENG = P_LENG.
*   Bis solche Felder nicht mehr automatisch scrollbar sind
*  P_D021S-DIDX+1(1) = P_D021S-LENG.
  P_D021S-DIDX+1(1) = P_LENG.
  P_D021S-TYPE = 'CHAR'.
  P_D021S-ITYP = 'C'.
  P_D021S-FLG1 = FLG1_FIELD.
  P_D021S-FLG3 = FLG3_OUT.
  P_D021S-FMB1 = FMB1_PROTECTED.
  P_D021S-FMB1 = P_D021S-FMB1 + FMB1_JUST_OUT.
  P_D021S-FLG2 = FLG2_LETT.
  IF G_SSCR-DB = 'X'.
    MOVE 'DBS' TO P_D021S-GRP2.
  ENDIF.
  IF G_SSCR-GROUP1 NE SPACE.
    MOVE G_SSCR-GROUP1 TO P_D021S-GRP1.
  ENDIF.
ENDFORM.
form text_attributes_new using p_leng
                               p_left_or_right
                     CHANGING P_D021S LIKE D021S.

 field-symbols : <l_d021s_res1> structure d021s_res1 default p_d021s-res1.

  P_D021S-COLN = CURCOLN.
  P_D021S-LINE = CURLINE.
  P_D021S-DIDX = 0.
* defined length 30, visual length is set to current textlen in frame
  P_D021S-LENG = max_text_length.
*   Bis solche Felder nicht mehr automatisch scrollbar sind
*  P_D021S-DIDX+1(1) = P_D021S-LENG.
  P_D021S-DIDX+1(1) = P_LENG.
  P_D021S-TYPE = 'CHAR'.
  P_D021S-ITYP = 'C'.
  P_D021S-FLG1 = FLG1_FIELD.
  P_D021S-FLG3 = FLG3_OUT.
  P_D021S-FMB1 = FMB1_PROTECTED.
  P_D021S-FMB1 = P_D021S-FMB1 + FMB1_JUST_OUT.
  P_D021S-FLG2 = FLG2_LETT.
  IF G_SSCR-DB = 'X'.
    MOVE 'DBS' TO P_D021S-GRP2.
  ENDIF.
  IF G_SSCR-GROUP1 NE SPACE.
    MOVE G_SSCR-GROUP1 TO P_D021S-GRP1.
  ENDIF.
  if p_left_or_right eq 'L'.
     <l_d021s_res1>-labelleft = 'X'.
  else.
     <l_d021s_res1>-labelright = 'X'.
  endif.

ENDFORM.


*------ Feldname------------------------------------------------------*
FORM FIELD_NAME USING PREFIX SEL_APPENDAGE SEL_NAME SCR_NAME.

  DATA NAME LIKE D021S-FNAM.

  IF PREFIX = '%_'.
    MOVE: PREFIX   TO NAME,
          SEL_NAME TO NAME+2.
  ELSE.
    MOVE: SEL_NAME TO NAME.
  ENDIF.

  IF SEL_APPENDAGE NE SPACE.
    MOVE: '-' TO NAME+10,
          SEL_APPENDAGE TO NAME+11.
  ENDIF.

  CONDENSE NAME NO-GAPS.

  MOVE NAME TO SCR_NAME.

ENDFORM.
*------ Feldname------------------------------------------------------*
FORM CD_FIELD_NAME USING PREFIX SEL_NAME FILLER SEL_APPENDAGE
                   changing SCR_NAME.

  DATA NAME LIKE D021S-FNAM.

  IF PREFIX = '%_'.
    MOVE: PREFIX   TO NAME,
          SEL_NAME TO NAME+2.
  ELSE.
    MOVE: SEL_NAME TO NAME.
  ENDIF.

  MOVE: FILLER TO NAME+10,
        SEL_APPENDAGE TO NAME+11.

  CONDENSE NAME NO-GAPS.

  MOVE NAME TO SCR_NAME.

ENDFORM.


* Besorgt Eigenschaften von Nicht-DD-Feldern
FORM DATA_DESCRIPTION USING SSCR STRUCTURE RSSCR
                            F    STRUCTURE D021S.

  DATA:BEGIN OF DESC,
         NAME(6) VALUE '%_DCB%',
         ODEC(2) TYPE N,
         UNUSED(13),
        END OF DESC.

  DATA P TYPE I.
  DATA L_MAX_LENG TYPE I.

  MOVE SSCR-DBFIELD TO DESC.

  IF SSCR-TYPE = '1' OR SSCR-TYPE = '2'.
    F-LENG = 8. F-DIDX+1(1) = 8. EXIT.
  ENDIF.
  CHECK SSCR-TYPE = 'P' OR SSCR-TYPE = 'I' OR SSCR-TYPE = 'b' OR  SSCR-TYPE = '8'.

  CASE SSCR-TYPE.
    WHEN 'P'.
      P = ( 2 * SSCR-LENGTH - 1 - DESC-ODEC ) MOD 3.
      IF P = 0.
        P = ( 2 * SSCR-LENGTH - 1 - DESC-ODEC ) DIV 3 - 1.
      ELSE.
        P = ( 2 * SSCR-LENGTH - 1 - DESC-ODEC ) DIV 3.
      ENDIF.

      IF P > 0.
        ADD P TO:  F-LENG.
      ENDIF.
    WHEN 'I'.
      F-LENG = 14.
    WHEN '8'.
      F-LENG = 26.
    WHEN 'b'.
      F-LENG = 3.
  ENDCASE.

  IF SSCR-KIND = 'P'.
    L_MAX_LENG = MAX_LENG_PARAM.
  ELSE.
    L_MAX_LENG = MAX_LENG_SELOPT.
  ENDIF.

  IF F-LENG LE L_MAX_LENG.
    F-DIDX+1(1) = F-LENG.
  ELSE.
    F-DIDX+1(1) = L_MAX_LENG.
  ENDIF.

  CHECK DESC-ODEC > 0.

  P = SSCR-OLENGTH - 1.
  CHECK P > DESC-ODEC.

  MOVE DESC-ODEC TO F-ADEZ.

ENDFORM.

FORM ADJUST_OLENGTH USING    VALUE(P_COLN) LIKE CURCOLN
                             P_LINE LIKE CURLINE
                    CHANGING P_SSCR    LIKE RSSCR
                             P_OLENGTH LIKE RSSCR-OLENGTH
                             P_SUBRC   LIKE SY-SUBRC.

  DATA L_INT TYPE I.

  P_SUBRC = 0.
* Position zu gross?
  IF P_COLN GE FRAME-LAST_POS_PLUS_1.
    CASE P_SSCR-KIND.
      WHEN 'F'.
        SHIFT P_SSCR-DBFIELD BY 2 PLACES.
        REPLACE '-COM' WITH SPACE INTO P_SSCR-DBFIELD.
    ENDCASE.
    P_COLN = P_COLN - 1.
    PERFORM FILL_GEN_MESSAGE USING 'POS'
                                   P_LINE P_COLN
                                   P_SSCR.
    P_SUBRC = 1.
    EXIT.
  ENDIF.
  L_INT = P_COLN + P_OLENGTH + 1.
  IF L_INT > FRAME-LAST_POS_PLUS_1.
    P_OLENGTH = FRAME-LAST_POS_PLUS_1 - P_COLN - 1.
    IF P_OLENGTH LE 0.
      P_OLENGTH = L_INT - P_COLN - 1.
      PERFORM FILL_GEN_MESSAGE USING 'POS'
                                     P_LINE  P_COLN
                                     P_SSCR.
      P_SUBRC = 1.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.                                   " ADJUST_OLENGTH

FORM GENERATE_DYNPRO USING KEY.

  GENERATE DYNPRO D020S F T M ID KEY
           MESSAGE DYNPRO_MESSAGE
           LINE    DYNPRO_LINE
           WORD    DYNPRO_WORD.


ENDFORM.

*------ Eigenschaften aus dem Data Dictionary-------------------------*
FORM GET_DD_ATTRIBUTES CHANGING P_D021S LIKE D021S
                                P_SUBRC LIKE SY-SUBRC.

  DATA FNAME LIKE RSSCR-DBFIELD.
  DATA FDPOS TYPE I.
  DATA L_FLAG_X.
  DATA L_FLAG_SPACE.
  DATA L_SUBRC LIKE SY-SUBRC.
  DATA L_TABLENAME TYPE DDOBJNAME.
  DATA L_TABLENAME2 TYPE DDOBJNAME.
  data l_rollname type rollname.
  DATA: BEGIN OF L_DD07V OCCURS 10.
    INCLUDE STRUCTURE DD07V.
  DATA: END   OF L_DD07V.
  DATA L_OBJTYPE LIKE DD02L-TABCLASS.

  DATA: L_DTELINFO LIKE DTELINFO.

  data outputstyle type outputstyle.
  data ampmenabled type scrpampmenabled.

  FIELD-SYMBOLS <L_TABNAME>.
  FIELD-SYMBOLS <L_FIELDNAME>.

  P_SUBRC = 4.
  IF G_SSCR-FLAG2 Z SSCR_F2_DYN.
    FNAME = G_SSCR-DBFIELD.
  ELSE.
    FNAME = 'RSDSINTERN-SELOPT'.
  ENDIF.
  IF FNAME CA '-'.
    FDPOS = SY-FDPOS + 1.
    ASSIGN FNAME(SY-FDPOS) TO <L_TABNAME>.
    ASSIGN FNAME+FDPOS(*) TO <L_FIELDNAME>.

    CALL FUNCTION 'C_DD_READ_FIELD'
         EXPORTING  I_TYPE = 'X'
                    I_TABNAME =  <L_TABNAME>
                    I_FIELDNAME = <L_FIELDNAME>
                    I_LANGUAGE = SY-LANGU
         IMPORTING  E_DFIES = DFIES
         EXCEPTIONS NO_TEXT = 2
                    OTHERS = 99.

    CHECK SY-SUBRC = 0 OR SY-SUBRC = 2.   " 2: Texte nicht gefunden
    l_rollname = dfies-rollname.
  ELSEIF G_SSCR-KIND = 'P'.
    L_TABLENAME = G_SSCR-DBFIELD.
    CALL FUNCTION 'DDIF_NAMETAB_GET'
         EXPORTING
              TABNAME     = L_TABLENAME
              ALL_TYPES   = 'X'
         IMPORTING
              DTELINFO_WA = L_DTELINFO
              DDOBJTYPE   = L_OBJTYPE
         EXCEPTIONS
              NOT_FOUND   = 1
              OTHERS      = 2.
    l_rollname = l_tablename.
    CHECK SY-SUBRC = 0 AND L_OBJTYPE = 'DTEL'.
    CLEAR DFIES.
    MOVE-CORRESPONDING L_DTELINFO TO DFIES.
    MOVE: L_DTELINFO-DTYP        TO DFIES-DATATYPE,
          L_DTELINFO-DBLENGTH    TO DFIES-INTLEN,
          L_DTELINFO-EXLENGTH    TO DFIES-OUTPUTLEN,
          L_DTELINFO-REFNAME     TO DFIES-DOMNAME.

  ELSE.
    L_TABLENAME2 = G_SSCR-DBFIELD.
    l_rollname = l_tablename2.
    CALL FUNCTION 'DDIF_NAMETAB_GET'
         EXPORTING
              TABNAME     = L_TABLENAME2
              ALL_TYPES   = 'X'
         IMPORTING
              DTELINFO_WA = L_DTELINFO
              DDOBJTYPE   = L_OBJTYPE
         EXCEPTIONS
              NOT_FOUND   = 1
              OTHERS      = 2.

    CHECK SY-SUBRC = 0 AND L_OBJTYPE = 'DTEL'.
      IF ( L_DTELINFO-VALEXI NE SPACE OR
       L_DTELINFO-F4AVAILABL NE SPACE                          OR
       G_SSCR-TYPE = 'D' OR G_SSCR-TYPE = 'T'                )
                     AND
       P_D021S-FMB2 Z FMB2_COMBO.
       P_D021S-FMB2 = P_D021S-FMB2 + FMB2_COMBO + FMB2_CMB_FORCE.
       IF G_SSCR-FLAG2 Z SSCR_F2_VRHI.
          ADD SSCR_F2_VRHI TO G_SSCR-FLAG2.
       ENDIF.
      ENDIF.
      if l_dtelinfo-exid = 'P' and l_dtelinfo-sign is initial.
        p_subrc = 0.
      endif.
       perform set_bidi_flags using l_rollname
                      changing p_d021s.
       perform set_outputstyle using l_rollname
                               changing p_d021s
                                      outputstyle.

       perform set_timeformat using l_rollname
                              changing p_d021s
                                  ampmenabled.

      if ampmenabled is not initial.
         move l_dtelinfo-exlength+1(1)  to p_d021s-leng.
         perform set_didx using p_d021s g_sscr.
      endif.
    EXIT.
  ENDIF.

  P_SUBRC = 0.
  perform set_bidi_flags using l_rollname
                         changing p_d021s.
  perform set_outputstyle using l_rollname
                          changing p_d021s
                                   outputstyle.

  perform set_timeformat using l_rollname
                         changing p_d021s
                                  ampmenabled.
  if ampmenabled is not initial.
    move dfies-outputlen to p_d021s-leng.
    perform set_didx using p_d021s g_sscr.
  endif.


  MOVE DFIES-DATATYPE TO P_D021S-TYPE.

  MOVE DFIES-CONVEXIT TO P_D021S-UCNV.
  MOVE DFIES-DECIMALS TO P_D021S-ADEZ.
  IF DFIES-DECIMALS > 0 OR DFIES-CONVEXIT NE SPACE.
    if dfies-outputlen < 256.
      MOVE DFIES-OUTPUTLEN TO P_D021S-LENG.
    else.
      P_D021S-LENG = 255.
    endif.
      PERFORM SET_DIDX USING P_D021S G_SSCR.
  ENDIF.

  IF G_SSCR-TYPE = 'X'.
    if dfies-intlen < 128.
     P_D021S-LENG = DFIES-INTLEN * 2.
    else.
      P_D021S-LENG = 254.
      if p_d021s-type = 'LRAW'.
        p_d021s-type = 'RAW'.
      endif.
    endif.
    PERFORM SET_DIDX USING P_D021S G_SSCR.
  ENDIF.

  IF DFIES-SIGN NE SPACE.
    ADD FLG3_VRZ TO P_D021S-FLG3.
  ENDIF.

  IF DFIES-MASK NE SPACE.
    MOVE DFIES-MASK    TO P_D021S-STXT.
    MOVE DFIES-MASKLEN TO P_D021S-LENG.
  ENDIF.

  IF DFIES-DATATYPE = 'CURR' OR DFIES-DATATYPE = 'QUAN'.
    CONCATENATE DFIES-REFTABLE '-' DFIES-REFFIELD INTO P_D021S-WNAM.
    CLEAR: P_D021S-AGLT, P_D021S-ADEZ.
  ENDIF.

  if ( p_d021s-ityp = 'a' or  p_d021s-ityp = 'e'  ) and
     ( outputstyle = '07' or outputstyle = '08' ) and
     dfies-reftable is not initial.
     concatenate dfies-reftable '-' dfies-reffield into p_d021s-wnam.
     clear: p_d021s-aglt, p_d021s-adez.
  endif.

  IF ( P_D021S-FNAM CS '-LOW' OR
       P_D021S-FNAM CS '-HIGH' OR G_SSCR-KIND = 'P' )
     AND DFIES-LOWERCASE NE SPACE AND P_D021S-FLG2 Z FLG2_LETT.
    ADD FLG2_LETT TO P_D021S-FLG2.
  ENDIF.

  IF ( DFIES-CHECKTABLE NE SPACE OR DFIES-VALEXI NE SPACE OR
       DFIES-F4AVAILABL NE SPACE                          OR
       G_SSCR-TYPE = 'D' OR G_SSCR-TYPE = 'T'                )
                     AND
       P_D021S-FMB2 Z FMB2_COMBO.
    P_D021S-FMB2 = P_D021S-FMB2 + FMB2_COMBO + FMB2_CMB_FORCE.
    IF G_SSCR-FLAG2 Z SSCR_F2_VRHI.
      ADD SSCR_F2_VRHI TO G_SSCR-FLAG2.
    ENDIF.
  ENDIF.

  IF DFIES-KEYFLAG NE SPACE AND P_D021S-FMB2 Z FMB2_COMBO.
* Schlüsselfeld einer Wertetabelle?
    SELECT * FROM DD01L
           WHERE DOMNAME EQ DFIES-DOMNAME
             AND AS4LOCAL EQ 'A'.
      IF DD01L-ENTITYTAB EQ <L_TABNAME>.
        P_D021S-FMB2 = P_D021S-FMB2 + FMB2_COMBO + FMB2_CMB_FORCE.
        IF G_SSCR-FLAG2 Z SSCR_F2_VRHI.
          ADD SSCR_F2_VRHI TO G_SSCR-FLAG2.
        ENDIF.
      ENDIF.
      EXIT.
    ENDSELECT.
  ENDIF.

  CHECK G_SSCR-KIND = 'P'.

  IF G_SSCR-FLAG2 O SSCR_F2_VCHK AND NOT DFIES-CHECKTABLE IS INITIAL.
    MOVE: G_SSCR-NAME TO PAR_CHECKTAB-NAME,
          DFIES-CHECKTABLE TO PAR_CHECKTAB-CHECKTAB.
    APPEND PAR_CHECKTAB.
  ENDIF.

  IF DFIES-VALEXI NE SPACE.
* Festwerte
      PERFORM VALEXI USING DFIES-DOMNAME
                           DFIES-DATATYPE
                     CHANGING P_D021S .

  ENDIF.

ENDFORM.                         " GET_DD_ATTRIBUTES

FORM set_bidi_flags USING    rollname TYPE rollname
                    CHANGING p_d021s  TYPE d021s.
  FIELD-SYMBOLS <d021s_res1> TYPE d021s_res1.
  DATA: l_ltrflddis TYPE ddltrflddi,
        l_bidictrlc TYPE ddbidictrl.

  SELECT SINGLE ltrflddis  bidictrlc FROM  dd04l
    INTO (l_ltrflddis, l_bidictrlc)
    WHERE rollname = rollname AND
  as4local = 'A' AND
  as4vers  = '0000'.

  IF sy-subrc <> 0. RETURN. ENDIF.

  ASSIGN p_d021s-res1 TO <d021s_res1> CASTING.

  <d021s_res1>-ltr      = l_ltrflddis.
  <d021s_res1>-bidictrl = l_bidictrlc.

ENDFORM.                    "set_bidi_flags
form set_outputstyle using    rollname type rollname
                     changing p_d021s  type d021s
                              outputstyle type outputstyle.
  data dominfo type dd01v.

  field-symbols <d021s_res1> type d021s_res1.

  if p_d021s-ityp <> 'a' and p_d021s-ityp <> 'e'.
    return.
  endif.

  assign p_d021s-res1 to <d021s_res1> casting.

* rollname empty : direct type spec
* info in DFIES
  if rollname is initial.
    <d021s_res1>-outputstyle = outputstyle  = dfies-outputstyle.
    return.
  endif.

  data rc type i.
  perform get_dominfo using rollname
                      changing dominfo
                               rc.
  if rc <> 0. return. endif.

  <d021s_res1>-outputstyle =  outputstyle = dominfo-outputstyle.

endform.

form set_timeformat using rollname type rollname
                          changing p_d021s type d021s
                                   ampmenabled type scrpampmenabled.
  data dominfo type dd01v.

  field-symbols <d021s_res1> type d021s_res1.

  if p_d021s-ityp <> 'T'.
    return.
  endif.

  assign p_d021s-res1 to <d021s_res1> casting.
* rollname empty : direct type spec
* info in DFIES
  if rollname is initial.
    <d021s_res1>-ampmenabled = ampmenabled = dfies-ampmformat.
    return.
  endif.

  data rc type i.
  perform get_dominfo using rollname
                      changing dominfo
                               rc.
  if rc <> 0. return. endif.

  <d021s_res1>-ampmenabled = ampmenabled = dominfo-ampmformat.

endform.

form get_dominfo using    rollname type rollname
                 changing dominfo  type dd01v
                          rc       type i.

 data domname type domname.
 select single domname from  dd04l
     into domname
     where rollname = rollname and
      as4local = 'A' and
      as4vers  = '0000'.

  if sy-subrc <> 0. rc = 1. return. endif.

  call function 'DDIF_DOMA_GET'
    exporting
      name                = domname
    importing
      dd01v_wa            = dominfo
    exceptions
      others              = 1.
  if sy-subrc <> 0. rc = 1.  return. endif.

  rc = 0.

endform.
FORM VALEXI USING    P_DOMNAME LIKE DFIES-DOMNAME
                     P_DATATYPE LIKE DFIES-DATATYPE
            CHANGING P_D021S LIKE D021S.

  DATA L_FLAG_X.
  DATA L_FLAG_SPACE.
  DATA L_SUBRC LIKE SY-SUBRC.
  DATA: BEGIN OF L_DD07V OCCURS 10.
    INCLUDE STRUCTURE DD07V.
  DATA: END   OF L_DD07V.
  DATA: NO_CB, NO_DLB VALUE 'X'.

    IF (  G_SSCR-LENGTH = CL_ABAP_CHAR_UTILITIES=>charsize AND
          G_SSCR-OLENGTH = 1 AND P_DATATYPE = 'CHAR' ) OR
      G_SSCR-FLAG2 O SSCR_F2_VCHK.
      CALL FUNCTION 'DD_DOMVALUES_GET'
           EXPORTING
                DOMNAME        =  P_DOMNAME
           IMPORTING
                RC             = L_SUBRC
           TABLES
                DD07V_TAB      =  L_DD07V
           EXCEPTIONS
                WRONG_TEXTFLAG = 1
                OTHERS         = 2.
    ENDIF.

    IF SY-SUBRC = 0 AND L_SUBRC = 0.
    sort l_dd07v by valpos.
    DESCRIBE TABLE L_DD07V LINES SY-TFILL.
    IF SY-TFILL NE 2 OR NOT (
       G_SSCR-LENGTH = CL_ABAP_CHAR_UTILITIES=>charsize AND
       G_SSCR-OLENGTH = 1 AND P_DATATYPE = 'CHAR' and g_sscr-flag2 z sscr_f2_libo ).
      NO_CB = 'X'.
    ENDIF.
*      if g_sscr-length = 1 and
*            g_sscr-olength = 1 and p_datatype = 'CHAR'.
        LOOP AT L_DD07V.
          IF NOT L_DD07V-DOMVALUE_H IS INITIAL.
            NO_DLB = 'X'.
            EXIT.
          ENDIF.
          CHECK NO_CB IS INITIAL.
          CASE L_DD07V-DOMVALUE_L.
            WHEN SPACE.
              MOVE 'X' TO L_FLAG_SPACE.
            WHEN 'X'.
              MOVE 'X' TO L_FLAG_X.
            WHEN OTHERS.
              CLEAR: L_FLAG_X, L_FLAG_SPACE.
              EXIT.
          ENDCASE.
        ENDLOOP.
        IF L_FLAG_SPACE NE SPACE AND L_FLAG_X NE SPACE.
          MOVE 'C' TO P_D021S-FILL.
          P_D021S-FMB2 = P_D021S-FMB2 - FMB2_COMBO - FMB2_CMB_FORCE.
          EXIT.
        ENDIF.
*      endif.
      IF  G_SSCR-FLAG2 O SSCR_F2_VCHK AND P_D021S-FILL NE 'C'.
        MOVE: G_SSCR-NAME TO PAR_FIXVAL-NAME,
              L_DD07V[]   TO PAR_FIXVAL-DD07V.
        APPEND PAR_FIXVAL.
      ENDIF.
      IF NO_DLB IS INITIAL.
        P_D021S-DIDX = P_D021S-DIDX + 2.
        P_D021S-RES1 = RES1_DROPLIST.
      ENDIF.
    ENDIF.
ENDFORM.
*------ Feldmaske ----------------------------------------------------*
FORM FIELD_TEXT USING LENGTH P_TYPE ADEZ SIGNFLG TEXT.
  DATA: MASK(79) VALUE '_____________________________________________',
        OFFSET TYPE I.

  DATA USED TYPE I.

  TEXT = MASK.

  CHECK ( P_TYPE = 'P' OR P_TYPE = 'I' OR P_TYPE = 's' OR P_TYPE = '8' ) AND LENGTH > 1.

  IF SIGNFLG O FLG3_VRZ.
    USED = 1.
    OFFSET = LENGTH - 1.
    WRITE 'V' TO TEXT+OFFSET(1).
  ENDIF.

ENDFORM.

FORM FILL_GEN_MESSAGE USING P_CODE TYPE C
                            P_LINE LIKE CURLINE
                            P_COLN LIKE CURCOLN
                            P_SSCR LIKE RSSCR.

  EXITFLAG = 'X'.

  CHECK ENTRYPOINT = 2.            " RSDBGENA

  CLEAR GEN_MESSAGE.
  GEN_MESSAGE-DYNNR = GL_SCREEN-NUMBER.
  GEN_MESSAGE-DYNPRO_FRAME_END = FRAME-LAST_POS_PLUS_1
                                 - FRAME_MARGIN - 1.
  MOVE: P_CODE      TO GEN_MESSAGE-CODE,
        CURLINE     TO GEN_MESSAGE-DYNPRO_LINE,
        P_SSCR      TO GEN_MESSAGE-SSCR.
  GEN_MESSAGE-DYNPRO_COLN = P_COLN.
  APPEND GEN_MESSAGE TO MESSTAB.

ENDFORM.                               " FILL_GEN_MESSAGE.

FORM ADD_OBJECT TABLES   P_F STRUCTURE D021S
                CHANGING P_SUBRC LIKE SY-SUBRC.

  DATA L_OFFSET TYPE I.
  DATA L_LENGTH TYPE I.
  DATA L_MAX TYPE I.

  FIELD-SYMBOLS <L_F>.

  CHECK P_F-FILL NE 'R'.    " Vorläufig: Rahmen ignorieren

  L_MAX = P_F-COLN + P_F-DIDX+1(1).
  IF L_MAX > GL_SCREEN-MAX_POS.
    GL_SCREEN-MAX_POS = L_MAX.
  ENDIF.

  L_LENGTH = P_F-DIDX+1(1).
  CHECK L_LENGTH > 0.
  ASSIGN SUPPLIED+P_F-COLN(L_LENGTH) TO <L_F>.
  IF <L_F> NE SPACE.
    P_SUBRC = 1.
    PERFORM FILL_GEN_MESSAGE USING 'OVRLP' CURLINE CURCOLN G_SSCR.
  ELSE.
    P_SUBRC = 0.
    APPEND P_F.
    TRANSLATE <L_F> USING ' X'.
  ENDIF.

ENDFORM.                                   " ADD_OBJECT
*&---------------------------------------------------------------------*
*&      Form  GEN_TABSTRIP
*&---------------------------------------------------------------------*
FORM GEN_TABSTRIP.

  FRAME-TAB = G_SSCR-DBFIELD.
  F-FILL = 'I'.
  CLEAR SUPPLIED.
  IF G_SSCR-FLAG1 Z SSCR_F1_SUBS.
    CURCOLN = INITCOLN + 2 - FRAME_MARGIN.
    ADD 1 TO CURLINE.
  ELSE.
    CURCOLN = INITCOLN - FRAME_MARGIN + 1.
    FRAME-TABS = 'S'.
  ENDIF.
  <F-DIDX> = G_SSCR-LENGTH + 3.
  CONCATENATE 'TABSTRIP_' G_SSCR-DBFIELD INTO F-FNAM.
  F-FLG1 = FLG1_TOP_TAB.
*      f-flg2 = flg2_vrsz bit-or flg2_hrsz.
  F-LENG = FRAME-LENGTH.
  F-COLN = CURCOLN.
  F-LINE = CURLINE.
  F-LTYP = 'J'.
  F-LANF = CURLANF.
  F-LBLK = 1.
  F-LREP = 1.
*      f-aglt = g_sscr-length + 3.
*      f-adez = 7.
* Bestimme Zeile für Rahmen
  DESCRIBE TABLE F LINES SY-TFILL.
  FRAME-TABIX = SY-TFILL + 1.
  MOVE 'TST' TO F-GRP3.
  IF G_SSCR-DB = 'X'.
     MOVE 'DBS' TO F-GRP2.
  ENDIF.
  IF G_SSCR-GROUP1 NE SPACE.
    MOVE G_SSCR-GROUP1 TO F-GRP1.
  ENDIF.
  <F-GRP4> = G_SSCR-NUMB MOD 1000.
  APPEND F.
  CLEAR F.

  FRAME-FIRST_LINE = CURLINE + 1.
  CURCOLN = 0.

ENDFORM.                    " GEN_TABSTRIP
*-----------------------------------------------------------------------
FORM GEN_TAB.
  DATA: BEGIN OF L_NAME,
          PREFIX LIKE RSSCR-NAME,
          UNDERSCORE VALUE '_',
          SUFFIX(4) TYPE N,
        END   OF L_NAME.
  DATA L_SUBRC LIKE SY-SUBRC.
*
  field-symbols <l_f_res1> structure d021s_res1 default f-res1.
  CURCOLN = CURCOLN + 1.
  F-COLN = CURCOLN.

  PERFORM TEXT_ATTRIBUTES USING    G_SSCR-OLENGTH
                          CHANGING F.
  CONCATENATE '%_SUBSCREEN_' FRAME-TAB INTO F-WNAM.
  F-LTYP = 'I'.
  F-LANF = CURLANF.
  F-LBLK = 1.
  F-LREP = 1.
  F-LINE = 1.
  ADD FMB1_NO_DITCH TO F-FMB1.
  F-FILL = 'P'.
  F-AUTH = CURAUTH.
  ADD 1 TO CURAUTH.
  <l_f_res1>-funccode = G_SSCR-MATCHCODE.
*  F-DMAC+1 = G_SSCR-MATCHCODE.
  IF G_SSCR-NAME(1) EQ '%'.
    MOVE G_SSCR-NAME      TO L_NAME-PREFIX.
    MOVE GL_SCREEN-NUMBER TO L_NAME-SUFFIX.
    F-FNAM = L_NAME.
  ELSE.
    MOVE G_SSCR-NAME TO F-FNAM.
  ENDIF.
  MOVE 'TAB' TO F-GRP3.
  APPEND F.
  CLEAR F.
  MOVE 'X' TO: GL_SCREEN-ANY_OBJECT, FRAME-TABS.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  END_OF_TABSTRIP
*&---------------------------------------------------------------------*
FORM END_OF_TABSTRIP.

  DATA L_F LIKE F.
  FIELD-SYMBOLS <L_DIDX> TYPE X.

  IF FRAME-TABS IS INITIAL.
    DELETE F INDEX FRAME-TABIX.
    SUBTRACT 1 FROM CURLINE.
    CLEAR FRAME-TAB.
    PERFORM POP_FRAME.
    CLEAR F.
    EXIT.
  ENDIF.

   CONCATENATE '%_SUBSCREEN_' FRAME-TAB INTO F-FNAM.
   F-FILL = 'B'.
   READ TABLE F INTO L_F INDEX FRAME-TABIX.
   CHECK SY-SUBRC = 0.
   ASSIGN L_F-DIDX TO <L_DIDX>.
   <F-DIDX> = <L_DIDX> - 3.
*   F-FLG2 = L_F-FLG2.
   F-FLG2 = flg2_hrsc + flg2_vsc.
   F-LENG = L_F-LENG - 2.

   if g_sscr-miscell = '%_FREESEL_%'.
     f-leng = f-leng + 4.
   endif.

   F-COLN = L_F-COLN + 1.
   F-AUTH = CURAUTH.
   ADD 1 TO CURAUTH.
   IF FRAME-TABS = 'S'.
     DELETE F INDEX FRAME-TABIX.
     F-LINE = CURLINE + 1.
     CURLINE = CURLINE + <L_DIDX> - 3.
   ELSE.
     F-LANF = L_F-LANF.
     F-LBLK = L_F-LBLK.
     F-LREP = L_F-LREP.
     F-LTYP = 'I'.
     F-LINE = CURLINE + 2.
     CURLINE = CURLINE + <L_DIDX> - 1.
   ENDIF.
   APPEND F.
   CLEAR F.
   CLEAR FRAME-TAB.
   PERFORM POP_FRAME.
   CURCOLN = INITCOLN + 2 - FRAME_MARGIN.
   ADD 1 TO CURLANF.
ENDFORM.                    " END_OF_TABSTRIP
*&---------------------------------------------------------------------*
*&      Form  ADJUST_RES1
*&---------------------------------------------------------------------*
form adjust_res1.

  data: l_tabix like sy-tabix,
        l_old_f like d021s.
*  data: l_coln_diff like d021s-coln.
  field-symbols <res1_new> structure d021s_res1 default f-res1.
  field-symbols <res1_old> structure d021s_res1 default l_old_f-res1.

  data: lt_sel_op_proplist type prop_list.
  data: ls_comfipar like line of comfipar.
  data: ld_sel_op type d021s-fnam.
  data: lt_dynsource type hashed table of d021s with unique key fnam.
  data: ls_d021s type d021s.
  data: ls_sscr type rsscr.
  data: ld_curcoln(2) type p,
        ld_curline(2) type p.

  lt_dynsource = f[].

  loop at f.
    l_tabix = sy-tabix.
    if l_old_f-line ne f-line.
      clear l_old_f.
    endif.
    if f-grp3 eq 'COF' or f-grp3 eq 'PAR'.
      case f-grp3.
        when 'COF'.

          if l_old_f-grp3 eq 'PAR'.
            read table comfipar with key fieldname = f-fnam
                                         parname   = L_OLD_F-FNAM
                                         binary search transporting
                                         no fields.
            if sy-subrc eq 0.
              <res1_new>-labelright = 'X'.
              modify f transporting res1.
              l_old_f = f.
              continue.
            endif.
          endif.
* Comment for a select-option
          read table comfipar with key fieldname = f-fnam binary search
            into ls_comfipar.
          if sy-subrc = 0 and ls_comfipar-kind = 'S'.
            perform field_name using space 'HIGH' ls_comfipar-parname changing ld_sel_op.

            read table lt_dynsource with table key fnam = ld_sel_op into ls_d021s.
              if sy-subrc = 0.
                if f-line eq ls_d021s-line.
                  CALL FUNCTION 'RS_SCRP_PROP_ADD_TO_PROP_LIST'
                    EXPORTING
                      P_TEXTFIELD                  = f-fnam
*                     P_TOOLTIPTEXT_TEXTELEM       =
*                     P_TOOLTIPTEXT_VARIABLE       =
                    CHANGING
                      p_prop_list                  = lt_sel_op_proplist.


                  if not lt_sel_op_proplist is initial.
                    CALL FUNCTION 'RS_SCRP_PROP_WRITE'
                      EXPORTING
                        p_prog                = key-program
                        p_dnum                = key-screen
                        p_dynprofield         = ls_d021s
                        p_prop_list           = lt_sel_op_proplist
                      changing
                        p_properties          = m[]
                      EXCEPTIONS
*                       PARAMLIST_ERROR       = 1
*                       PROPLIST_ERROR        = 2
                        OTHERS                = 1.
                    IF sy-subrc <> 0.
                      if  entrypoint = 2. " Call from RSDBGENA. Tolerate error otherwise
                        move ls_d021s-line to ld_curcoln.
                        move ls_d021s-coln to ld_curline.
                        read table  g_sscr with key name = ls_comfipar-parname into ls_sscr.
                        perform fill_gen_message using 'GPROP' ld_curcoln ld_curline ls_sscr.
                        clear exitflag. " do not exit
                      endif.
                    ENDIF.
                  endif.
                  if f-coln < ls_d021s-coln.
                    <res1_new>-labelleft = 'X'.
                  else.
                    <res1_new>-labelright = 'X'.
                  endif.
                  modify f transporting res1.
               endif.
              else. " No HIGH field/ but LOW Field should exist
                perform field_name using space 'LOW' ls_comfipar-parname changing ld_sel_op.
                read table lt_dynsource with table key fnam = ld_sel_op into ls_d021s.
                if sy-subrc = 0.
                  if f-coln < ls_d021s-coln.
                    <res1_new>-labelleft = 'X'.
                  else.
                    <res1_new>-labelright = 'X'.
                  endif.
                  modify f transporting res1.
                endif.
              endif.
          endif.
        when 'PAR'.
          if l_old_f-grp3 eq 'COF'.
            read table comfipar with key fieldname = l_old_f-fnam
                                         parname   = f-fnam
                                         binary search transporting
                                         no fields.
            if sy-subrc eq 0.
              l_tabix = l_tabix - 1.
              <res1_old>-labelleft = 'X'.
               if f-fill = 'C' or f-fill = 'A'.
                 l_old_f-leng = f-coln - l_old_f-coln.
                 l_old_f-didx+1(1) = l_old_f-leng - 1.
*                l_coln_diff = f-coln - l_old_f-coln.
*                if (  l_coln_diff gt 2 ).
*                  l_old_f-leng = f-coln - l_old_f-coln - 1.
*                else.
*                  l_old_f-leng = f-coln - l_old_f-coln.
*                 endif.
              endif.
              modify f from l_old_f index l_tabix
                     transporting res1 leng didx.
            endif.
          endif.
      endcase.
    endif.
    l_old_f = f.
  endloop.

endform.                          "ADJUST_RES1
*&---------------------------------------------------------------------*
*&      Form  GEN_SCREEN_SUB
*&---------------------------------------------------------------------*
FORM GEN_SCREEN_SUB.
 clear f.
 f-fnam = 'SUBSCREEN_CONTAINER'.
 f-fill = 'B'.
 f-didx+1(1) = 10.
 F-FLG1 = 00.
 f-flg2 = 00.
 f-flg3 = 80.
 f-leng = frame-length.
 f-line = 01.
 f-type = 'CHAR'.
 f-ityp = 'C'.
 f-aglt = 46.
 f-lanf = curlanf.
 f-lblk = 1.
 f-lrep = 1.
 f-coln = initcoln.

 append f. clear f.
 add 10 to curline.
ENDFORM.                    " GEN_SCREEN_SUB

form augment_comment using index_comment type sytabix
                           for_field type rsscr-name
                     changing dynp_field type d021s.

  data found_left type c.
  data found_right type c.
  data ind type sytabix.
  data wa_sscr type rsscr.

  data left_sel type rsscr-name.
  data right_sel type rsscr-name.

  field-symbols <d021s_res1> type d021s_res1.

  assign dynp_field-res1 to <d021s_res1> casting.
* Search for Radiobutton up to BEGIN OF LINE
* accept only one radiobutton between comment an BOL
  ind = index_comment - 1.
  do.
    read table g_sscr index ind into wa_sscr.
    if wa_sscr-kind = 'L' and wa_sscr-appendage = 'A'.
      exit.
    elseif wa_sscr-kind = 'O'.
* accept selection-screen position.
      ind = ind - 1.
      continue.
    elseif wa_sscr-kind = 'P' and
           ( wa_sscr-flag1 o sscr_f1_radi or
             wa_sscr-appendage = 'C' ). " checkbox or radiobutton
      if found_left = 'X'.
        return.
      else.
        found_left = 'X'.
        left_sel = wa_sscr-name.
        ind = ind - 1.
      endif.
    else.
      return.
    endif.
  enddo.

  if found_left is initial.  return.  endif.

* Search for Parameter or Select-Option until EOL
* accept only one of these until EOL
  ind = index_comment + 1.

  do.
    read table g_sscr index ind into wa_sscr.
    if wa_sscr-kind = 'L' and wa_sscr-appendage = 'E'.
      exit.
    elseif wa_sscr-kind = 'O'.
* accept selection-screen position.
      ind = ind + 1.
      continue.
    elseif ( wa_sscr-kind = 'P' and wa_sscr-flag1 z sscr_f1_radi
        and  wa_sscr-appendage ne 'C' ) or wa_sscr-kind = 'S'.
      data iscb type abap_bool.
* accept Parameters (not CB or RB!) and Select-options
* if the parameter is No-DISPLAY ignore it
      if wa_sscr-flag1 o sscr_f1_nodi. ind = ind + 1. continue. endif.
      if  right_sel is initial.
         perform is_automatic_checkbox using   wa_sscr
                                    changing iscb.
         if iscb = abap_true. return. endif.
         right_sel = wa_sscr-name.
      endif.
      found_right = abap_true.
      ind = ind + 1.
      continue.
    else.
      return.
    endif.
  enddo.
  if found_right is initial. return. endif.
* For which parameters is the FOR FIELD addition ?
* augment comment with "missing" Label left or right
  if left_sel = for_field.
    <d021s_res1>-labelleft = 'X'.
  elseif right_sel = for_field.
    <d021s_res1>-labelright  = 'X'.
  endif.
endform.                    "augment_comment

*&--------------------------------------------------------------------*
*&      Form  is_automatic_checkbox
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->P_SSCR     text
*      -->IS_CHECKBOXtext
*---------------------------------------------------------------------*
form is_automatic_checkbox using p_sscr type rsscr
                           changing is_checkbox type abap_bool.

  data fname like rsscr-dbfield.
  data fdpos type i.
  data fixed_values type  ddfixvalues.
  data num_values type sytabix.

  is_checkbox = abap_false.

  if p_sscr-kind ne 'P' or
     not ( p_sscr-length = cl_abap_char_utilities=>charsize and
           p_sscr-olength = 1 and p_sscr-dtyp = 'CHAR' ).

    return.
  endif.

  fname = p_sscr-dbfield.

  data l_tabname type ddobjname.
  data l_lfieldname type dfies-lfieldname.
  if fname ca '-'.
    fdpos = sy-fdpos + 1.
    move fname(sy-fdpos) to l_tabname.
    move fname+fdpos(*) to l_lfieldname.
  else.
    move fname to l_tabname.
  endif.


* get fixed_values
  call function 'DDIF_FIELDINFO_GET'
    exporting
      tabname              = l_tabname
      lfieldname            = l_lfieldname
      all_types            = 'X'
    tables
      fixed_values         = fixed_values
   exceptions
      others               = 1.
  if sy-subrc <> 0.
    return.
  endif.

  describe table fixed_values lines num_values.
  if num_values ne 2. return. endif.

  data value type ddfixvalue.
  data: found_x type abap_bool value abap_false,
        found_space type abap_bool value abap_false.

  loop at fixed_values into value.
    if value-high is not initial. return.  endif.
    case value-low.
      when 'X'.
        found_x = abap_true.
      when space.
        found_space = abap_true.
     endcase.
  endloop.

  if found_x = abap_true and found_space = abap_true.
    is_checkbox = abap_true.
  endif.


endform.                    "is_automatic_checkbox
