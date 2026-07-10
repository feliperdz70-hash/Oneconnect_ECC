REPORT ZONPG_RSDBRUNT MESSAGE-ID DB.

************************************************************************
*                       Datendeklaration                               *
************************************************************************

TABLES: TRDIR,
        TUVID,
        RSVUVINT,
        VARID,
        DFIES,
        SSCRTEXTS,                             "Textfelder auf Sel.bild
        SSCRFIELDS.                            "E/A-Felder auf Sel.bild
*
TABLES: RSJOBINFO. "formerly contained in SYSINI
*
include <icon>.


DATA %_RKEY LIKE RSVARKEY.                                        "#EC *

CONSTANTS CV_SUBTY_VIA_SELSCR TYPE X VALUE '04'.

* Gemeinsame Daten mit RSSYSTDB
INCLUDE zonpg_RSDBCOM2.
* TYPE-POOLS RSDS + COMMON PART mit SAPDBxyz
INCLUDE ZONPG_RSDBCOM4.
*INCLUDE RSDBCOM4.
* Für Optioneneinschränkungen
TYPE-POOLS SSCR.
* Für Screen-Verwaltung
TYPE-POOLS SYDB0.
* Für Suchhilfe
TYPE-POOLS SYLDB.
* Fuer Tabstrip
TYPE-POOLS CXTAB.
DATA: G_FCODE LIKE SY-UCOMM,
      G_PROG  LIKE SY-REPID,
      G_DYNNR LIKE SY-DYNNR.
* SUBTY-Equates
INCLUDE zonpg_RSDBCSTY.

* Optionen-equates
INCLUDE ZONPG_RSDBCOPT.
*INCLUDE RSDBCOPT.

* Optionen-equates
INCLUDE <FIESEL>.

*---------------------- Selektionsbilder ------------------------------*

* GET/SET CURSOR
DATA: begin of cursor,
         FIELD LIKE SCREEN-NAME,
         prog type syrepid,
         dynnr type sydynnr,
     end of cursor.

* Phasen beim SUBMIT und CALL SELECTION-SCREEN
*  0:  noch keine Kontrolle bekommen
*  1:  vor Selektionsbild
*  2:  auf Selektionsbild, vor und während INITIALIZATION
*  3:  auf Selektionsbild, nach INITIALIZATION
* 50:  auf Selektionsbild bei CALL SELECTION-SCREEN
* 99: nach Starten des Reports
DATA PHASE TYPE I.
DATA SUBMIT_PHASE TYPE I.    " Zum Retten bei CALL vom Standardbild aus
* Save G_SUBTY of Submit screen
data submit_subty like sy-subty.
* Auf Mehrfachselektionsbild ?
DATA COMPLEX_SELECTION.
* Kopie von SY-SUBTY
DATA G_SUBTY LIKE SY-SUBTY.
* Kennzeichen: Modus wurde per Transaktion (nicht SUBMIT) gerufen
DATA G_transaction(1) TYPE c value 'X'.
* wie oft wird bei dunklem SUBMIT DCI durchlaufen?
data g_dark_times type i.
DATA NO_VARIUCOMM .
* Tabelle der zu übergebenden tiefen Objekte
DATA: BEGIN OF DEEP_PARS OCCURS 5,
        NAME LIKE RSSCR-NAME,
      END   OF DEEP_PARS.
* Vorbereitungen CALL SELECTION-SCREEN:
* Verwaltung der Informationen über verschiedene Bilder.
* COMMON PART mit allen RSDBSP...
INCLUDE ZONPG_RSDBC1XX.
*INCLUDE RSDBC1XX.
* Definition von:
*  SCREEN_PROGS
*  SCREENS
*  SCR_STACK
*  CURRENT_SCREEN
*  CURRENT_SCR
*  RESTORE
*  MEMONUM
*  VARISCREENS
*  VSCREENS
*  VSCR_T
*  CURR_VSCR
*  DYNS
*  DYNS_TABS
*  DYNS_FIELDS

* Kennzeichen: Neuer CALL SELECTION-SCREEN
* Initialisierung mit X wegen CALL TRANSACTION/CALL DIALOG etc.
DATA NEW_CALL VALUE 'X'.   " X: CALL DIALOG/TRANSACTION
                           " C: CALL SEL.-SCREEN, P: ALS POPUP,
                           " S: SUBMIT
DATA NEW_CALL_VARIANT LIKE SY-SLSET.
* Vorläufig: Liste der abweichenden Variantenprogramme
DATA: BEGIN OF VPROGS OCCURS 0,
        PROGRAM  LIKE SY-CPROG,
        VARIPROG LIKE SY-CPROG,
      END   OF VPROGS.
* Alle F3-relevanten Programme
data f3progs type standard table of sy-repid initial size 0.
data f3progs_old type standard table of sy-repid initial size 0.
* Flag: Selektionsbilder gerade neugeneriert wegen Version
DATA VERSION_NEW_GEN.
* Programmname der gerade geladenen SSCR
DATA LAST_SSCR_PROG LIKE SY-REPID.
* Flag: Es gab einen FILL_RESTRICT-Aufruf, d.h. RSDBSPRE ist geladen
DATA RESTRICT_FLAG.
*
DATA G_SELOPTS TYPE SYDB0_SELOPTS. " Globales Feld für FILL_RSSELINT
DATA G_PARAMS  TYPE SYDB0_PARAMS.  " Globales Feld für FILL_PARAM_TEXT
* Optionen-Ikonen
DATA: BEGIN OF OPTI_ICONS OCCURS 30.
        INCLUDE STRUCTURE RSOPTIICON.
DATA: END   OF OPTI_ICONS.
* Ikonen für MORE
DATA: BEGIN OF VALU_ICONS,
        GREY  LIKE RSSELINT-OPTI_PUSH,
        GREEN LIKE RSSELINT-OPTI_PUSH,
      END   OF VALU_ICONS.

DATA: BEGIN OF RSSELID,
        NUMB(3) TYPE N,
        NAME LIKE RSSCR-NAME,
      END   OF RSSELID.

* Teilt IM/EXPORT_VARIANT_STATIC mit, welche übergebenen Objekte
* im/exportiert werden sollen.
  DATA: BEGIN OF IMEX,
          VARI,
          DYNS,
        END   OF IMEX.
* I: Irrelevant (keine unsichtbaren Objekte)
* F: Nur wenige sichtbar
* A: Alle sichtbar
* Wie war Stand bei 'Ausführen?
* Dieser Stand wird nach F3 wiederhergestellt
DATA ALL_SELECTIONS_FOR_F3.
* Gewünschtes Verhalten (über FBs bei INITIALIZATION)
DATA ALL_SELECTIONS_VIA_FB.
* Bei AT SELECTION-SCREEN ausgeblendete SPA/GPA-Felder.
* Muessen nicht gestackt werden, da Anwendung zwischen
* SET_PF_STATUS und SHOW_TAB nicht die Kontrolle bekommt.
DATA NO_SPAGPA LIKE RSSCR-NAME OCCURS 0.
* Laufzeit-Info-Struktur
DATA BEGIN OF SUBMIT_INFO.
  INCLUDE STRUCTURE RSSUBINFO.
DATA END   OF SUBMIT_INFO.
data flag_suppress_gpa.
DATA WWW_SUBMIT.
* Submit-Modus (früher %_SUBMODE)
* SPACE: normal
* 'Vx' : Variantenpflege
* 'Jx' : Jobeinplanung
* 'I ' : SUBMIT nach F3 auf Grundliste
*DATA SCREEN_PROGS-SUBMODE(2).
* Submit-Modus: Kopie für Selektionsbild-Status
* SPACE: normal
* 'VC' : Varianten anlegen
* 'VU' : Varianten ändern
* 'Jx' : Jobeinplanung
* 'I ' : SUBMIT nach F3 auf Grundliste
*DATA SCREEN_PROGS-STATUS_SUBMODE(2).
* Zeigt auf die 'richtige' SSCRFIELDS bzw. SSCRTEXTS
FIELD-SYMBOLS <SSCRFIELDS> STRUCTURE SSCRFIELDS DEFAULT SSCRFIELDS.
FIELD-SYMBOLS <SSCRTEXTS> STRUCTURE SSCRTEXTS DEFAULT SSCRTEXTS.

*--------------- Daten für Selektionsbilder: Ende ---------------------*

*---------------------- Freie Aufrufe --------------------------------*

TYPES: BEGIN OF LDB_STACK_LINE,
         LDBPG   LIKE SY-LDBPG,
         SUBMIT,
         CALLBACK LIKE LDBCB OCCURS 0,
         DYN_SEL TYPE RSDS_TYPE,
         DYNS_FIELDS LIKE RSDSFIELDS OCCURS 0,
         DYNS_NODES LIKE RSDFSNODES OCCURS 0,
         SELECT_FIELDS TYPE RSFS_FIELDS,
       END   OF LDB_STACK_LINE.
DATA CURR_LDB TYPE LDB_STACK_LINE.
DATA LDB_STACK TYPE LDB_STACK_LINE OCCURS 0.
constants query_is_dynnr type sydynnr value '9999'.
*---------------------- Freie Aufrufe: Ende ---------------------------*


*--------------- Daten für REJECT -------------------------------------*
DATA: BEGIN OF %_LDB_STRUC OCCURS 100.                            "#EC *
        INCLUDE STRUCTURE RSLDBSTRUC.
*       DATA CHILD  LIKE RSIXFTAB-TABLENAME.
*       DATA PARENT LIKE RSIXFTAB-TABLENAME.
DATA: END   OF %_LDB_STRUC.
*--------------- Daten für REJECT: Ende -------------------------------*

* Key für Memory: F3 auf Grundliste
DATA: MEMKEY LIKE RSVAMEMKEY.
* Startdynpro bei SUBMIT: für F3 auf Grundliste
DATA: SUBMIT_SCREEN LIKE SY-DYNNR.

* Schalter: Es gibt SELECT-OPTIONS AS DATABASE SELECTION
DATA SELOPTS_AS_DB_SEL.
* Daten für Kontextmenue
data: begin of context_struc,
        program like sy-repid,
        dynnr   like sy-dynnr,
        name    like rsscr-name,
     end of context_struc.

************************************************************************
*                       Unterprogramme                                 *
************************************************************************

*---------------------------------------------------------------------*
*    Ueberprueft Eingabe, z.B. gueltige Intervallgrenzen ...          *
* Wird aus %_INIT-MOVE (sysend.rs1) gerufen                           *
*---------------------------------------------------------------------*
FORM %_SELC_CHECK USING LOW HIGH SIGN OPTION.                     "#EC *

  DATA L_TYPE.

  DESCRIBE FIELD LOW TYPE L_TYPE.

* Keine Eingabe ?
  IF HIGH IS INITIAL AND LOW IS INITIAL AND OPTION = SPACE.
    OPTION = 'EQ'.
*   EXIT.
  ENDIF.
* Falsche Optionen
  IF OPTION NE SPACE AND
     OPTION NE 'EQ'  AND
     OPTION NE 'BT'  AND
     OPTION NE 'CP'  AND
     OPTION NE 'LE'  AND
     OPTION NE 'GE'  AND
     OPTION NE 'LT'  AND
     OPTION NE 'GT'  AND
     OPTION NE 'NP'  AND
     OPTION NE 'NB'  AND
     OPTION NE 'NE'.
     IF SY-SUBTY Z CV_SUBTY_VIA_SELSCR.
       ADD CV_SUBTY_VIA_SELSCR TO SY-SUBTY.
     ENDIF.
     MESSAGE E669 with option space.
   ENDIF.

* Falsche Intervallgrenzen
  IF ( NOT HIGH IS INITIAL OR OPTION = 'BT' OR OPTION = 'NB' )
     AND LOW > HIGH AND RSVUVINT-NO_INT_CHK = SPACE.
    IF SY-SUBTY Z CV_SUBTY_VIA_SELSCR.
      ADD CV_SUBTY_VIA_SELSCR TO SY-SUBTY.
    ENDIF.
    MESSAGE E650.
  ENDIF.

* Nur INCL oder EXCL erlaubt
  IF SIGN NE 'I' AND SIGN NE 'E' AND SIGN NE SPACE.
    IF SY-SUBTY Z CV_SUBTY_VIA_SELSCR.
      ADD CV_SUBTY_VIA_SELSCR TO SY-SUBTY.
    ENDIF.
    MESSAGE E656 with sign space.
  ENDIF.
  IF SIGN = SPACE.
    SIGN = 'I'.
  ENDIF.

* Eingabe-Kombinationen
  CASE OPTION.
    WHEN SPACE.
      IF HIGH IS INITIAL.
        IF L_TYPE = 'C' AND ( LOW CA '*+' ).
          OPTION = 'CP'.
        ELSE.
          OPTION = 'EQ'.
        ENDIF.
      ELSE.
        OPTION = 'BT'.
      ENDIF.
    WHEN 'EQ'.
      IF NOT HIGH IS INITIAL.
        IF SY-SUBTY Z CV_SUBTY_VIA_SELSCR.
          ADD CV_SUBTY_VIA_SELSCR TO SY-SUBTY.
        ENDIF.
        MESSAGE E664.
      ENDIF.
    WHEN 'NE'.
      IF NOT HIGH IS INITIAL.
        IF SY-SUBTY Z CV_SUBTY_VIA_SELSCR.
          ADD CV_SUBTY_VIA_SELSCR TO SY-SUBTY.
        ENDIF.
        MESSAGE E664.
      ENDIF.
    WHEN 'BT'.
      IF LOW IS INITIAL AND HIGH IS INITIAL.
        IF SY-SUBTY Z CV_SUBTY_VIA_SELSCR.
          ADD CV_SUBTY_VIA_SELSCR TO SY-SUBTY.
        ENDIF.
        MESSAGE E665.
      ENDIF.
    WHEN 'NB'.
      IF LOW IS INITIAL AND HIGH IS INITIAL.
        IF SY-SUBTY Z CV_SUBTY_VIA_SELSCR.
          ADD CV_SUBTY_VIA_SELSCR TO SY-SUBTY.
        ENDIF.
        MESSAGE E665.
      ENDIF.
    WHEN 'LE'.
      IF NOT LOW IS INITIAL AND NOT HIGH IS INITIAL.
        IF SY-SUBTY Z CV_SUBTY_VIA_SELSCR.
          ADD CV_SUBTY_VIA_SELSCR TO SY-SUBTY.
        ENDIF.
        MESSAGE E666.
      ENDIF.
      IF NOT HIGH IS INITIAL.
        LOW = HIGH.
        CLEAR HIGH.
      ENDIF.
    WHEN 'LT'.
      IF NOT LOW IS INITIAL AND NOT HIGH IS INITIAL.
        IF SY-SUBTY Z CV_SUBTY_VIA_SELSCR.
          ADD CV_SUBTY_VIA_SELSCR TO SY-SUBTY.
        ENDIF.
        MESSAGE E666.
      ENDIF.
      IF NOT HIGH IS INITIAL.
        LOW = HIGH.
        CLEAR HIGH.
      ENDIF.
    WHEN 'GE'.
      IF NOT LOW IS INITIAL AND NOT HIGH IS INITIAL.
        IF SY-SUBTY Z CV_SUBTY_VIA_SELSCR.
          ADD CV_SUBTY_VIA_SELSCR TO SY-SUBTY.
        ENDIF.
        MESSAGE E667.
      ENDIF.
      IF NOT HIGH IS INITIAL.
        LOW = HIGH.
        CLEAR HIGH.
      ENDIF.
    WHEN 'GT'.
      IF NOT LOW IS INITIAL AND NOT HIGH IS INITIAL.
        IF SY-SUBTY Z CV_SUBTY_VIA_SELSCR.
          ADD CV_SUBTY_VIA_SELSCR TO SY-SUBTY.
        ENDIF.
        MESSAGE E667.
      ENDIF.
      IF NOT HIGH IS INITIAL.
        LOW = HIGH.
        CLEAR HIGH.
      ENDIF.
    WHEN 'CP'.
      IF NOT HIGH IS INITIAL.
        IF SY-SUBTY Z CV_SUBTY_VIA_SELSCR.
          ADD CV_SUBTY_VIA_SELSCR TO SY-SUBTY.
        ENDIF.
        MESSAGE E670.
      ENDIF.
      IF LOW NA '*+' OR L_TYPE NE 'C'.
        IF SY-SUBTY Z CV_SUBTY_VIA_SELSCR.
          ADD CV_SUBTY_VIA_SELSCR TO SY-SUBTY.
        ENDIF.
        MESSAGE E668.
      ENDIF.
    WHEN 'NP'.
      IF NOT HIGH IS INITIAL.
        IF SY-SUBTY Z CV_SUBTY_VIA_SELSCR.
          ADD CV_SUBTY_VIA_SELSCR TO SY-SUBTY.
        ENDIF.
        MESSAGE E670.
      ENDIF.
      IF LOW NA '*+' OR L_TYPE NE 'C'.
        IF SY-SUBTY Z CV_SUBTY_VIA_SELSCR.
          ADD CV_SUBTY_VIA_SELSCR TO SY-SUBTY.
        ENDIF.
        MESSAGE E668.
      ENDIF.
  ENDCASE.
ENDFORM.                               "%_SELC_CHECK
*---------------------------------------------------------------------*
* Setzt grob Defaultwerte für SIGN und OPTION, falls SPACE            *
* Wird bei PBO gerufen.                                               *
*---------------------------------------------------------------------*
FORM HAVE_MERCY USING    P_LOW P_HIGH p_text type sydb0_selopts-text
                CHANGING P_SIGN LIKE RSPARAMS-SIGN
                         P_OPTION LIKE RSPARAMS-OPTION
                         P_SUBRC LIKE SY-SUBRC.

  DATA L_TYPE.

  P_SUBRC = 0.
  DESCRIBE FIELD P_LOW TYPE L_TYPE.

* Nur INCL oder EXCL erlaubt
  IF P_SIGN NE 'I' AND P_SIGN NE 'E' AND P_SIGN NE SPACE.
    IF SY-SUBTY Z CV_SUBTY_VIA_SELSCR.
      ADD CV_SUBTY_VIA_SELSCR TO SY-SUBTY.
    ENDIF.
    MESSAGE E656 with p_sign p_text.
  ENDIF.
  IF P_SIGN = SPACE.
    P_SIGN = 'I'.
    P_SUBRC = 1.
  ENDIF.

* Falsche Optionen
  IF P_OPTION NE SPACE AND
     P_OPTION NE 'EQ'  AND
     P_OPTION NE 'BT'  AND
     P_OPTION NE 'CP'  AND
     P_OPTION NE 'LE'  AND
     P_OPTION NE 'GE'  AND
     P_OPTION NE 'LT'  AND
     P_OPTION NE 'GT'  AND
     P_OPTION NE 'NP'  AND
     P_OPTION NE 'NB'  AND
     P_OPTION NE 'NE'.
     IF SY-SUBTY Z CV_SUBTY_VIA_SELSCR.
       ADD CV_SUBTY_VIA_SELSCR TO SY-SUBTY.
     ENDIF.
     MESSAGE E669 with p_option p_text.
   ENDIF.

  CHECK P_OPTION = SPACE.

  IF P_HIGH IS INITIAL.
    IF L_TYPE = 'C' AND P_LOW CA '*+'.
      P_OPTION = 'CP'.
    ELSE.
      P_OPTION = 'EQ'.
    ENDIF.
  ELSE.
    P_OPTION = 'BT'.
  ENDIF.
  P_SUBRC = 1.

ENDFORM.                               " HAVE_MERCY
*---------------------------------------------------------------------*
*    Ueberprueft Eingabe, z.B. gueltige Intervallgrenzen ...          *
*    Setzt ggfls. OPTION                                              *
*                                                                     *
*    Strategie:                                                       *
*                                                                     *
*    Ist OPTION noch nicht gesetzt, so setze Standard                 *
*                                                                     *
*    Ist OPTION schon gesetzt, so prüfe, ob Kombination               *
*       zulässig ist. Falls nein, korrigiere gemäß Standard.          *
*       Nur wenn auch das nicht geht: Fehlermeldung.                  *
*                                                                     *
*---------------------------------------------------------------------*
FORM %_SELC_CHECK_PAI USING    P_MESSAGE                          "#EC *
                               P_SELOPTS TYPE SYDB0_SELOPTS
                      CHANGING LOW HIGH OPTION SIGN
                               P_SUBRC LIKE SY-SUBRC.

  DATA L_TYPE.
  DATA: L_NOINT_CHECK.

  P_SUBRC = 0.
  IF P_SELOPTS-NOINT_CHECK NE SPACE OR RSVUVINT-NO_INT_CHK NE SPACE.
     L_NOINT_CHECK = 'X'.
  ENDIF.
  DESCRIBE FIELD LOW TYPE L_TYPE.

  IF SIGN = SPACE.
    IF P_SELOPTS-SG_MAIN NE 'E'.
      MOVE 'I' TO SIGN.
    ELSE.
      MOVE 'E' TO SIGN.
    ENDIF.
  ENDIF.
* Option noch nicht gesetzt
  IF OPTION EQ SPACE.
* Keine Eingabe ?
    IF LOW IS INITIAL AND HIGH IS INITIAL.
      EXIT.
    ENDIF.
* beide ungleich initial ?
    IF NOT LOW IS INITIAL AND NOT HIGH IS INITIAL.
*     Zulässiges Intervall ?
      IF LOW > HIGH AND L_NOINT_CHECK = SPACE.
        IF P_MESSAGE = SPACE.
          P_SUBRC = 4.
          EXIT.
        ENDIF.
        IF DYNS-SELSCREEN_FLAG = SPACE.
          IF SY-SUBTY Z CV_SUBTY_VIA_SELSCR.
            ADD CV_SUBTY_VIA_SELSCR TO SY-SUBTY.
          ENDIF.
          MESSAGE E650.
        ELSE.
          PERFORM ADJUST_MESSAGE IN PROGRAM (DYNS-PROGRAM) USING '650'.
        ENDIF.
      ENDIF.
      MOVE 'BT' TO OPTION.
      EXIT.
    ENDIF.
* LOW initial ?
    IF LOW IS INITIAL.
*     Zulässiges Intervall ?
      IF LOW LE HIGH.
        MOVE 'BT' TO OPTION.
        EXIT.
      ENDIF.
      IF DYNS-SELSCREEN_FLAG = SPACE.
        IF SY-SUBTY Z CV_SUBTY_VIA_SELSCR.
          ADD CV_SUBTY_VIA_SELSCR TO SY-SUBTY.
        ENDIF.
        MESSAGE E650.
      ELSE.
        PERFORM ADJUST_MESSAGE IN PROGRAM (DYNS-PROGRAM) USING '650'.
      ENDIF.
    ENDIF.
* HIGH initial
    IF L_TYPE = 'C' AND ( LOW CA '*+' ).
      OPTION = 'CP'.
    ELSE.
      OPTION = 'EQ'.
    ENDIF.
    IF P_SELOPTS-JUST_INTERVALS NE SPACE AND LOW LE HIGH.
      OPTION = 'BT'.
    ENDIF.
    EXIT.
  ENDIF.

* Option schon gesetzt

* LOW und HIGH initial
  IF HIGH IS INITIAL AND LOW IS INITIAL.
* Alles bis auf CP / NP erlaubt.
    IF OPTION = 'CP' OR OPTION = 'NP' OR OPTION = 'BT'.
      MOVE 'EQ' TO OPTION.
    ELSEIF OPTION = 'NB'.
      MOVE 'NE' TO OPTION.
    ENDIF.
    EXIT.
  ENDIF.
* beide ungleich initial ?
    IF NOT LOW IS INITIAL AND NOT HIGH IS INITIAL.
*     Zulässiges Intervall ?
      IF LOW > HIGH AND L_NOINT_CHECK = SPACE.
        IF P_MESSAGE = SPACE.
          P_SUBRC = 4.
          EXIT.
        ENDIF.
        IF DYNS-SELSCREEN_FLAG = SPACE.
          IF SY-SUBTY Z CV_SUBTY_VIA_SELSCR.
            ADD CV_SUBTY_VIA_SELSCR TO SY-SUBTY.
          ENDIF.
          MESSAGE E650.
        ELSE.
          PERFORM ADJUST_MESSAGE IN PROGRAM (DYNS-PROGRAM) USING '650'.
        ENDIF.
      ENDIF.
      IF OPTION NE 'NB'.
        MOVE 'BT' TO OPTION.
      ENDIF.
      EXIT.
    ENDIF.

* LOW initial
  IF LOW IS INITIAL.
*     Zulässiges Intervall ?
      IF LOW LE HIGH.
        IF OPTION NE 'NB'.
          MOVE 'BT' TO OPTION.
        ENDIF.
        EXIT.
      ENDIF.
*   In allen anderen Fällen steht der Wert in LOW
    MOVE HIGH TO LOW.
    CLEAR HIGH.
    IF L_TYPE = 'C' AND ( LOW CA '*+' ).
      OPTION = 'CP'.
    ELSE.
      OPTION = 'EQ'.
    ENDIF.
    EXIT.
  ENDIF.
* HIGH initial
* Intervall ?
  IF OPTION = 'BT' OR OPTION = 'NB'.
*   Zulässiges Intervall ?
    IF LOW LE HIGH.
      EXIT.
    ENDIF.
*   Sonst schalte auf Standard um
    IF L_TYPE = 'C' AND ( LOW CA '*+' ).
      OPTION = 'CP'.
    ELSE.
      OPTION = 'EQ'.
    ENDIF.
    EXIT.
  ENDIF.
* Maske ?
  IF OPTION = 'CP' OR OPTION = 'NP'.
* Auch maskierte Eingabe ?
    IF LOW NA '*+' OR L_TYPE NE 'C'.
      OPTION = 'EQ'.
      EXIT.
    ENDIF.
  ENDIF.
ENDFORM.                               "%_SELC_CHECK_PAI

*---------------------------------------------------------------------*
*    Setzt die Menge der zulässigen Optionen gemäß LOW und HIGH       *
*                                                                     *
*    Es wird vorausgesetzt, daß LOW und HIGH konsistent sind,         *
*    d.h. daß alles vorher durch %_SELC_CHECK_PAI gelaufen ist.       *
*                                                                     *
*    Mögliche Werte für OPTION_SET:                                   *
*                                                                     *
*     ALL:  Alle Optionen zulässig                                    *
*     INT:  Intervall: Nur BT/NB                                      *
*     NOI:  No Interval: alles auser BT/NB                            *
*     NOP:  No Pattern: alles außer CP/NP                             *
*     NIP:  No Interval or Pattern: alles außer CP/NP/BT/NB           *
*     INI:  initial value: Like NIP                                   *
*                                                                     *
*---------------------------------------------------------------------*
FORM %_SET_OPTION_SET USING    LOW HIGH                           "#EC *
                               P_TYPE LIKE RSSCR-TYPE
                               P_SSCR LIKE RSSCR
                               P_SCREEN_HIGH LIKE SCREEN
                      CHANGING OPTION_SET.

    IF LOW IS INITIAL AND HIGH IS INITIAL.
      MOVE 'INI' TO OPTION_SET.
      EXIT.
    ENDIF.
* beide ungleich initial ?
    IF NOT LOW IS INITIAL AND NOT HIGH IS INITIAL.
      MOVE 'INT' TO OPTION_SET.
      EXIT.
    ENDIF.
* LOW initial ? Dann muß HIGH GE LOW sein (sonst hat %_SELC_CHECK_PAI
* HIGH nach LOW transportiert )
    IF LOW IS INITIAL.
      IF P_TYPE = 'C' AND HIGH CA '*+'.
        MOVE 'ALL' TO OPTION_SET.
      ELSE.
        MOVE 'NOP' TO OPTION_SET.
      ENDIF.
      EXIT.
    ENDIF.
* HIGH initial
* Intervall möglich ?
    IF LOW LE HIGH AND
             P_SSCR-FLAG1 Z SSCR_F1_NOIN  AND  " High-Feld da
             P_SCREEN_HIGH-INVISIBLE = '0'.
      IF P_TYPE = 'C' AND LOW CA '*+'.
        MOVE 'ALL' TO OPTION_SET.
      ELSE.
        MOVE 'NOP' TO OPTION_SET.
      ENDIF.
      EXIT.
    ENDIF.
* Kein Intervall möglich
    IF P_TYPE = 'C' AND LOW CA '*+'.
      MOVE 'NOI' TO OPTION_SET.
    ELSE.
      MOVE 'NIP' TO OPTION_SET.
    ENDIF.
    EXIT.
ENDFORM.

*--------- Selection Screen 1000: Show --------------------------------*
FORM %_SHOW_TAB TABLES SELTAB                                     "#EC *
                USING P_SIGN   LIKE RSPARAMS-SIGN
                      P_OPTION LIKE RSPARAMS-OPTION
                      P_LOW
                      P_HIGH
                      P_DESC STRUCTURE RSSELINT
                      P_SUBRC LIKE SY-SUBRC.

  IF DYNS-SELSCREEN_FLAG = SPACE.
    PERFORM %_SHOW_TAB_PART_2
       TABLES   SELTAB
       CHANGING P_SIGN P_OPTION P_LOW P_HIGH
                P_DESC P_SUBRC.
  ELSE.
    PERFORM ADJUST_SELOP_PBO IN PROGRAM (DYNS-PROGRAM)
                TABLES SELTAB
                USING  P_SIGN P_OPTION P_LOW P_HIGH P_DESC P_SUBRC.
  ENDIF.

ENDFORM.                               " SHOW_TAB_NEW
* Macht die eigentliche Arbeit
FORM %_SHOW_TAB_PART_2 TABLES SELTAB                              "#EC *
                CHANGING P_SIGN   LIKE RSPARAMS-SIGN
                         P_OPTION LIKE RSPARAMS-OPTION
                         P_LOW
                         P_HIGH
                         P_DESC STRUCTURE RSSELINT
*                        P_SELOPTS TYPE SYDB0_SELOPTS_T
                         P_SUBRC LIKE SY-SUBRC.

  DATA TFILL LIKE SY-TFILL.
  DATA L_SUBRC LIKE SY-SUBRC.
  DATA L_TABIX LIKE SY-TABIX.
  DATA L_NUM3(3) TYPE N.
  DATA FIELDNAME(15) VALUE '%_'.
  DATA L_SELOPTS TYPE SYDB0_SELOPTS.
  DATA L_VARI LIKE RVARI.
  DATA L_INITIAL_LOW.
  DATA L_INITIAL_HIGH.

  DESCRIBE TABLE SELTAB LINES TFILL.

  READ TABLE CURRENT_SCREEN-SELOPTS WITH KEY P_DESC-NAME BINARY SEARCH
       INTO L_SELOPTS.
  CHECK SY-SUBRC = 0.
  L_TABIX = SY-TABIX.

  PERFORM CHECK_FIRST_LINE  TABLES   SELTAB
                            USING    L_SELOPTS-SSCR
                            CHANGING P_SIGN
                                     P_OPTION
                                     P_LOW
                                     P_HIGH
                                     L_SELOPTS.

  MODIFY CURRENT_SCREEN-SELOPTS FROM L_SELOPTS INDEX L_TABIX.

  IF TFILL GE L_SELOPTS-DISPLAYED_LINE.
    READ TABLE SELTAB INDEX L_SELOPTS-DISPLAYED_LINE.
  ELSE.
    CLEAR: P_SIGN, P_OPTION, P_LOW, P_HIGH.
  ENDIF.

  IF L_SELOPTS-SSCR-SPAGPA NE SPACE AND P_LOW IS INITIAL.
    IF TFILL GE L_SELOPTS-DISPLAYED_LINE.
      SET PARAMETER ID L_SELOPTS-SSCR-SPAGPA FIELD P_LOW.
    ELSEIF SY-SLSET NE SPACE AND
          ( SY-SUBCS = 'T' OR
           SY-BATCH = SPACE AND SY-SUBTY O CV_SUBTY_VIA_SELSCR ).
      READ TABLE CURRENT_SCREEN-INVISIBLE WITH KEY L_SELOPTS-NUMB
              BINARY SEARCH
              TRANSPORTING NO FIELDS.
      IF SY-SUBRC NE 0.
        READ TABLE NO_SPAGPA
                WITH KEY P_DESC-NAME
                BINARY SEARCH
                TRANSPORTING NO FIELDS.
      ENDIF.
      IF SY-SUBRC NE 0.
        READ TABLE CURR_VSCR-VARI WITH KEY P_DESC-NAME
                                  INTO L_VARI TRANSPORTING XFLAG1.
        IF SY-SUBRC = 0.
          IF L_VARI-XFLAG1 Z VARI_F1_NOSPAGPA.
            GET PARAMETER ID L_SELOPTS-SSCR-SPAGPA FIELD P_LOW.
          ELSE.
            SET PARAMETER ID L_SELOPTS-SSCR-SPAGPA FIELD P_LOW.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF L_SELOPTS-SSCR-FLAG2 O SSCR_F2_DYN.
    PERFORM SET_OPTI_PUSH_DYN_SELECTION
                          USING    P_SIGN P_OPTION P_LOW P_HIGH
                                   L_SELOPTS-NUMB L_SELOPTS-SSCR-TYPE
                          CHANGING P_DESC-OPTI_PUSH.
  ELSE.
    PERFORM SET_OPTI_PUSH USING    P_SIGN P_OPTION P_LOW P_HIGH
                                   L_SELOPTS-NUMB
                          CHANGING P_DESC-OPTI_PUSH.
  ENDIF.
  IF TFILL > 1 OR ( TFILL = 1 AND L_SELOPTS-DISPLAYED_LINE = 2 ).
    MOVE VALU_ICONS-GREEN TO P_DESC-VALU_PUSH.
  ELSE.
    MOVE VALU_ICONS-GREY  TO P_DESC-VALU_PUSH.
  ENDIF.

  IF L_SELOPTS-SSCR-FLAG2 O SSCR_F2_DYN.
    PERFORM SHOW_DYN_OBJECT USING:
                    P_LOW  L_SELOPTS-NAME 'S' L_INITIAL_LOW,
                    P_HIGH L_SELOPTS-NAME 'S' L_INITIAL_HIGH.
    IF ( P_OPTION = 'EQ' AND P_SIGN = 'I'
                         AND NOT L_INITIAL_LOW IS INITIAL )    OR
       ( P_OPTION = 'BT' AND P_SIGN = 'I'
                         AND NOT L_INITIAL_HIGH IS INITIAL ).
      PERFORM SUPPLY_ICONS(RSDYNSS0) TABLES   OPTI_ICONS
                                     USING    P_SIGN
                                              P_OPTION
                                     CHANGING P_DESC-OPTI_PUSH.
      DELETE CURRENT_SCR-OPTI_PUSH_OFF WHERE NUMB = L_SELOPTS-NUMB.
    ENDIF.
  ENDIF.

  IF DYNS-SELSCREEN_FLAG NE SPACE.
    PERFORM DISPLAY_SELOPT IN PROGRAM (DYNS-PROGRAM)
                  USING P_SIGN P_OPTION P_LOW P_HIGH P_DESC P_SUBRC.
  ENDIF.

ENDFORM.                               "%_SHOW_TAB_PART_2
* Verhackstuecke dynamische Parameter
FORM %_SHOW_DYN_PARM USING P_PARAM LIKE RSDYNPAR-PARAM            "#EC *
                           P_NAME  LIKE RSSCR-NAME.

  DATA L_INITIAL.

  PERFORM SHOW_DYN_OBJECT USING P_PARAM P_NAME 'P' L_INITIAL.

ENDFORM.
* Zeige dynamisches Objekt an
FORM SHOW_DYN_OBJECT USING P_INPUT TYPE C
                           P_NAME  LIKE RSSCR-NAME
                           P_KIND  LIKE RSSCR-KIND
                           P_INITIAL LIKE RSSCR-KIND.

  FIELD-SYMBOLS <L_DYNREF> TYPE SYDB0_DYNREF.

  DATA L_LENG TYPE I.
  DATA L_INT  TYPE I.
  DATA L_TIME TYPE T.
  DATA L_FDPOS LIKE SY-FDPOS.
  DATA: L_MAX_LENG TYPE I,
        L_TABIX LIKE SY-TABIX.

  READ TABLE SCREEN_PROGS-DYNREF WITH KEY P_NAME BINARY SEARCH
       ASSIGNING <L_DYNREF>.
  L_TABIX = SY-TABIX.
  if sy-subrc ne 0 or <l_dynref>-reffield = 'RSDSINTERN-SELOPT'
                   or <l_dynref>-reffield = 'RSDYNPAR-PARAM'
                   or flag_query_active eq 'A'.

    PERFORM CREATE_DYNREF USING P_NAME P_KIND .
    READ TABLE SCREEN_PROGS-DYNREF INDEX L_TABIX
         ASSIGNING <L_DYNREF>.
  ENDIF.
  IF <L_DYNREF>-CONVERT-DYNPTYPE = 'CURR' OR
     <L_DYNREF>-CONVERT-DYNPTYPE = 'QUAN'.
    PERFORM SET_CURR_QUAN_DECI(RSDBSPDD)
                               USING    CURRENT_SCREEN-PROGRAM
                                        <L_DYNREF>-CONVERT-DYNPTYPE
                                        <L_DYNREF>-CURR_REF
                               CHANGING <L_DYNREF>-CONVERT-DECIMALS
*                                        <L_DYNREF>-CONVERT-DDDECIMALS
                                        <L_DYNREF>-CONVERT-QUAN_UNIT.
  ENDIF.
  PERFORM CONVERT_WH_2_EX(RSDYNSS0) USING <L_DYNREF>-CONVERT
                                          P_INPUT
                                 CHANGING P_INPUT P_INITIAL.
  IF NOT P_INITIAL IS INITIAL.
    CASE <L_DYNREF>-CONVERT-TYPE.
      WHEN 'T'.
        WRITE L_TIME TO P_INPUT.
      WHEN OTHERS.
        CLEAR P_INPUT.
    ENDCASE.
  ELSEIF <L_DYNREF>-CONVERT-TYPE = 'P' OR
     <L_DYNREF>-CONVERT-TYPE = 'I' OR
     <L_DYNREF>-CONVERT-TYPE = 's' OR
     <L_DYNREF>-CONVERT-TYPE = 'b' OR
     <L_DYNREF>-CONVERT-TYPE = 'F' OR
     <L_DYNREF>-CONVERT-TYPE = 'a' OR
     <L_DYNREF>-CONVERT-TYPE = 'e'.
    IF P_INPUT CN ' '.
      L_FDPOS = SY-FDPOS.
      L_LENG = <L_DYNREF>-CONVERT-OLENGTH - L_FDPOS.
      IF P_KIND = 'P'.
        L_MAX_LENG = MAX_LENG_PARAM.
      ELSE.
        L_MAX_LENG = MAX_LENG_SELOPT.
      ENDIF.
      IF L_LENG LE L_MAX_LENG.
        L_INT = <L_DYNREF>-CONVERT-OLENGTH - L_MAX_LENG.
        SHIFT P_INPUT BY L_INT PLACES.
      ELSE.
        SHIFT P_INPUT BY L_FDPOS PLACES.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
* Setzt Symbol in Optionen-Pushbutton.
FORM SET_OPTI_PUSH USING    P_SIGN   LIKE RSPARAMS-SIGN
                            P_OPTION LIKE RSPARAMS-OPTION
                            P_LOW
                            P_HIGH
                            P_NUMB   TYPE SYDB0_SSCR_NUMB
                   CHANGING P_OPTI_PUSH LIKE RSSELINT-OPTI_PUSH.

  DATA L_TYPE.
  DATA L_OOFF TYPE SYDB0_OPTI_OFF.

  DESCRIBE FIELD P_LOW TYPE L_TYPE.

  CASE P_OPTION.
    WHEN SPACE.
      CLEAR P_OPTI_PUSH.
      MOVE P_NUMB TO L_OOFF-NUMB.
      APPEND L_OOFF TO CURRENT_SCR-OPTI_PUSH_OFF.
      EXIT.
    WHEN 'EQ'.
      IF P_SIGN = 'I' AND NOT P_LOW IS INITIAL
                      AND NOT ( L_TYPE = 'C' AND P_LOW CA '*+' ).
        CLEAR P_OPTI_PUSH.
        MOVE P_NUMB TO L_OOFF-NUMB.
        APPEND L_OOFF TO CURRENT_SCR-OPTI_PUSH_OFF.
        EXIT.
      ENDIF.
    WHEN 'BT'.
      IF P_SIGN = 'I' AND NOT P_HIGH IS INITIAL.
        CLEAR P_OPTI_PUSH.
        MOVE P_NUMB TO L_OOFF-NUMB.
        APPEND L_OOFF TO CURRENT_SCR-OPTI_PUSH_OFF.
        EXIT.
      ENDIF.
  ENDCASE.

  PERFORM SUPPLY_ICONS(RSDYNSS0) TABLES   OPTI_ICONS
                                 USING    P_SIGN
                                          P_OPTION
                                 CHANGING P_OPTI_PUSH.

ENDFORM.                             " SET_OPTI_PUSH

* Setzt Symbol in Optionen-Pushbutton.
FORM SET_OPTI_PUSH_DYN_SELECTION USING  P_SIGN   LIKE RSPARAMS-SIGN
                                        P_OPTION LIKE RSPARAMS-OPTION
                                        P_LOW
                                        P_HIGH
                                        P_NUMB   TYPE SYDB0_SSCR_NUMB
                                        P_TYPE   TYPE RSSCR_TYPE
                   CHANGING P_OPTI_PUSH LIKE RSSELINT-OPTI_PUSH.

  DATA L_OOFF TYPE SYDB0_OPTI_OFF.

  CASE P_OPTION.
    WHEN SPACE.
      CLEAR P_OPTI_PUSH.
      MOVE P_NUMB TO L_OOFF-NUMB.
      APPEND L_OOFF TO CURRENT_SCR-OPTI_PUSH_OFF.
      EXIT.
    WHEN 'EQ'.
      IF P_SIGN = 'I' AND NOT P_LOW IS INITIAL
                      AND NOT ( P_TYPE = 'C' AND P_LOW CA '*+' ).
        CLEAR P_OPTI_PUSH.
        MOVE P_NUMB TO L_OOFF-NUMB.
        APPEND L_OOFF TO CURRENT_SCR-OPTI_PUSH_OFF.
        EXIT.
      ENDIF.
    WHEN 'BT'.
      IF P_SIGN = 'I' AND NOT P_HIGH IS INITIAL.
        CLEAR P_OPTI_PUSH.
        MOVE P_NUMB TO L_OOFF-NUMB.
        APPEND L_OOFF TO CURRENT_SCR-OPTI_PUSH_OFF.
        EXIT.
      ENDIF.
  ENDCASE.

  PERFORM SUPPLY_ICONS(RSDYNSS0) TABLES   OPTI_ICONS
                                 USING    P_SIGN
                                          P_OPTION
                                 CHANGING P_OPTI_PUSH.

ENDFORM.                             " SET_OPTI_PUSH_DYN_SELECTION

* Prüft, ob 1. Zeile angezeigt werden kann.
* Stellt ggfls. erste anzeigbare Zeile in Zeile 1.
* Verläßt sich darauf, daß 1.Zeile in Kopfzeile steht.
* P_LINE:  0:     1.Zeile nicht anzeigbar
*          sonst: Nummer der anzuzeigenden Zeile
FORM CHECK_FIRST_LINE  TABLES   P_SELTAB
                       USING    P_SSCR STRUCTURE RSSCR
                       CHANGING P_SIGN   LIKE RSPARAMS-SIGN
                                P_OPTION LIKE RSPARAMS-OPTION
                                P_LOW
                                P_HIGH
                                P_SELOPTS TYPE SYDB0_SELOPTS.

  DATA L_FLAG.
  DATA L_ADDY_FLAG.
  DATA L_SUBRC LIKE SY-SUBRC.
  DATA L_TABIX LIKE SY-TABIX.
  DATA L_TFILL LIKE SY-TFILL.
  DATA L_OPTIONS TYPE SYDB0_XOPTIONS.
  DATA L_1_OPTION TYPE SYDB0_XOPTIONS.
  DATA L_ADDY_OPTIONS TYPE SYDB0_XOPTIONS.
  DATA L_SELOPT_NO_INPUT TYPE SYDB0_SELNOIN.

  DATA L_MAIN_REASON.       " S: wg. SG, O: wg. OP
  DATA L_ADDY_REASON.       " S: wg. SG, O: wg. OP , N: wg. NOEX

  FIELD-SYMBOLS <L_F>.

  DESCRIBE TABLE P_SELTAB LINES L_TFILL.
  P_SELOPTS-DISPLAYED_LINE = 1.
* Kein Sonderfall ?
  IF NOT ( (      P_SSCR-FLAG1 O SSCR_F1_NOIN
              OR P_SELOPTS-SCREEN_HIGH-INVISIBLE = '1'
              OR P_SELOPTS-X_MAIN_OPTIONS NE '0000'
              OR P_SELOPTS-SG_MAIN NE SPACE                )
          AND P_SELOPTS-SCREEN_LOW-INVISIBLE  NE '1' ).
    IF L_TFILL > 0.
      READ TABLE P_SELTAB INDEX 1.
      PERFORM HAVE_MERCY USING    P_LOW P_HIGH p_selopts-text
                         CHANGING P_SIGN P_OPTION L_SUBRC.
      IF L_SUBRC NE 0.
        MODIFY P_SELTAB INDEX 1.
      ENDIF.
    ENDIF.
    EXIT.
  ENDIF.

  P_SELOPTS-DISPLAYED_LINE = L_TFILL + 1.

  L_OPTIONS = P_SELOPTS-X_MAIN_OPTIONS.
  L_ADDY_OPTIONS = P_SELOPTS-X_ADDY_OPTIONS.

  IF P_SSCR-FLAG1 Z SSCR_F1_NOIN.
    IF L_OPTIONS O OPTION_BT_NB.
      if P_SSCR-FLAG1 O SSCR_F1_NOEX or p_selopts-sg_addy = 'N'.
        L_SELOPT_NO_INPUT-HIGH = 'I'.
      else.
        L_SELOPT_NO_INPUT-HIGH = 'X'.
      ENDIF.
    ENDIF.
  ELSE.
*   Vorsichtshalber, falls auf Exception bei FB nicht reagiert wurde
    L_OPTIONS = L_OPTIONS BIT-OR OPTION_BT_NB.
    IF L_OPTIONS O OPTION_NONE.
      L_SELOPT_NO_INPUT-LOW = 'X'.
    ENDIF.
  ENDIF.
* NO-EXTENSION, aber mehrere Zeilen?
  IF ( P_SSCR-FLAG1 O SSCR_F1_NOEX or p_selopts-sg_addy = 'N' )
                                   AND L_TFILL > 1 AND
*   Kompatibilität
    ( P_SSCR-FLAG1 O SSCR_F1_NOIN   OR
      P_SELOPTS-SG_MAIN NE SPACE    OR
      L_OPTIONS NE '0000'               ).
    MESSAGE A763 WITH P_SELOPTS-TEXT.
  ENDIF.

  IF P_SELOPTS-SCREEN_HIGH-INVISIBLE = '1'.
    L_OPTIONS = L_OPTIONS BIT-OR OPTION_BT_NB.
    IF L_OPTIONS O OPTION_NONE.
      L_SELOPT_NO_INPUT-LOW = 'X'.
      L_ADDY_OPTIONS = L_ADDY_OPTIONS BIT-OR OPTION_BT_NB.
      IF L_TFILL > 0.
        IF P_SSCR-FLAG1 O SSCR_F1_NOEX OR      " NO-EXTENSION
           p_selopts-sg_addy = 'N'    or
          L_ADDY_OPTIONS = OPTION_NONE.   " ==> Zeile nicht anzeigbar!
          MESSAGE A761 WITH P_SELOPTS-TEXT.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF L_ADDY_OPTIONS = OPTION_NONE.
    L_SELOPT_NO_INPUT-VPUSH = 'X'.
  ENDIF.

  IF p_selopts-sg_addy = 'N'.
    L_SELOPT_NO_INPUT-VPUSH = 'I'.
  ENDIF.

  IF NOT L_SELOPT_NO_INPUT IS INITIAL.
    MOVE P_SELOPTS-NUMB TO L_SELOPT_NO_INPUT-NUMB.
    APPEND L_SELOPT_NO_INPUT TO CURRENT_SCR-SELOPT_NO_INPUT.
  ENDIF.

  IF P_SELOPTS-SG_ADDY NE SPACE OR L_ADDY_OPTIONS NE '0000'.
    L_ADDY_FLAG = 'X'.
  ENDIF.

  LOOP AT P_SELTAB.
    L_TABIX = SY-TABIX.
    CLEAR L_1_OPTION.
    CLEAR: L_MAIN_REASON, L_ADDY_REASON.
    PERFORM HAVE_MERCY USING    P_LOW P_HIGH p_selopts-text
                       CHANGING P_SIGN P_OPTION L_SUBRC.
    IF L_SUBRC NE 0.
      MODIFY P_SELTAB.
    ENDIF.
*   Vorzeichen für Hauptbild O.K.?
    IF P_SELOPTS-SG_MAIN = SPACE OR P_SELOPTS-SG_MAIN = P_SIGN.
      OX P_OPTION L_1_OPTION.
      IF L_OPTIONS Z L_1_OPTION.   " Option auf Hauptbild erlaubt
        IF L_FLAG = SPACE.
          P_SELOPTS-DISPLAYED_LINE = L_TABIX.
          L_FLAG = 'X'.        " auf Hauptbild anzeigbar
        ENDIF.
        IF NOT L_ADDY_FLAG IS INITIAL.  " Restr. auf Wertemengenbild?
          CONTINUE.                  " Dann alle Zeilen testen!
        ELSE.                        " Sonst: fertig.
          EXIT.
        ENDIF.
      ELSE.
        L_MAIN_REASON = 'O'.
      ENDIF.
    ELSE.
      L_MAIN_REASON = 'S'.
    ENDIF.
*   Testen, ob auf Wertemengenbild erlaubt.
*   Wegen Vorzeichen nicht?
    IF P_SELOPTS-SG_ADDY NE SPACE AND P_SELOPTS-SG_ADDY NE P_SIGN and
       P_SELOPTS-SG_ADDY NE 'N'.
      L_ADDY_REASON = 'S'.
      EXIT.
    ELSEIF P_SSCR-FLAG1 O SSCR_F1_NOEX or P_SELOPTS-SG_ADDY = 'N'.
      L_ADDY_REASON = 'N'.
      EXIT.
    ENDIF.
    IF L_1_OPTION IS INITIAL.             " Noch nicht gesetzt.
      OX P_OPTION L_1_OPTION.
    ENDIF.
    IF L_ADDY_OPTIONS O L_1_OPTION.   " Option auf Zweitbild verboten
      L_ADDY_REASON = 'O'.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF L_ADDY_REASON NE SPACE.      " Nicht anzeigbare Zeile
    CASE L_MAIN_REASON.
      WHEN 'S'.                  " wg. Vorzeichen.
        CASE L_ADDY_REASON.
          WHEN 'S'.
            MESSAGE A768 WITH P_SELOPTS-TEXT P_SIGN.
          WHEN 'N'.
            MESSAGE A769 WITH P_SELOPTS-TEXT P_SIGN.
          WHEN 'O'.
            IF ( P_OPTION = 'BT' OR P_OPTION = 'NB' )        AND
               NOT P_SELOPTS-X_ADDY_OPTIONS O OPTION_BT_NB   AND
               P_SELOPTS-SCREEN_HIGH-INVISIBLE = '1'.
              MESSAGE A770 WITH P_SELOPTS-TEXT P_SIGN P_OPTION.
            ELSE.
              MESSAGE A771 WITH P_SELOPTS-TEXT P_SIGN P_OPTION.
            ENDIF.
        ENDCASE.
      WHEN 'O'.                  " wg. Option
        IF ( P_OPTION = 'BT' OR P_OPTION = 'NB' )      AND
           P_SELOPTS-SCREEN_HIGH-INVISIBLE = '1'.
          MESSAGE A773 WITH P_SELOPTS-TEXT P_OPTION.
        ELSE.
          CASE L_ADDY_REASON.
            WHEN 'N'.
              MESSAGE A772 WITH P_SELOPTS-TEXT P_OPTION.
            WHEN 'O'.
              MESSAGE A774 WITH P_SELOPTS-TEXT P_OPTION.
          ENDCASE.
        ENDIF.
    ENDCASE.
    MESSAGE A762 WITH P_SELOPTS-TEXT.
  ENDIF.

  IF L_FLAG EQ SPACE.
    CLEAR: P_SIGN, P_OPTION, P_LOW, P_HIGH.
  ENDIF.

ENDFORM.
* Initialisierung PAI: setzt Feldnamen und Zeile des Cursors
* Anschließend enthält bei SELECT-OPTIONS %_SSCR-Kopfzeile
* Eintrag der ausgewählten SELECT-OPTION
FORM %_INIT_PAI.                                                  "#EC *

  DATA SUBRC LIKE SY-SUBRC.
  DATA L_KIND LIKE RSSCR-KIND.
  DATA L_BLOCKS TYPE SYDB0_BLOCKS.
  DATA L_PROG LIKE SY-REPID.

  IF CURRENT_SCR-MODE EQ 'S'.
    IF G_SUBTY  Z CV_SUBTY_VIA_SELSCR and g_dark_times < 2
                               OR
       SY-BATCH NE SPACE AND <SSCRFIELDS>-UCOMM = SPACE.
      IF SCREEN_PROGS-SUBMODE(1) NE 'J'.
        MOVE 'ONLI' TO <SSCRFIELDS>-UCOMM.
        MOVE 'ONLI' TO SY-UCOMM.
      ELSE.
        MOVE 'JOBS' TO <SSCRFIELDS>-UCOMM.
        MOVE 'JOBS' TO SY-UCOMM.
      ENDIF.
    ENDIF.
    clear g_dark_times.
    perform dark_submit(sapmssyd) using 0 if found.
    IF SY-SUBTY Z CV_SUBTY_VIA_SELSCR.
      ADD CV_SUBTY_VIA_SELSCR TO SY-SUBTY.
    ENDIF.
  ENDIF.
  perform is_sel_specific_ucomm using    <SSCRFIELDS>-UCOMM
                                changing current_scr-spec_ucomm.
  PERFORM %_SELECTED_FIELD CHANGING CURRENT_SCR-PICK-FIELD
                                    CURRENT_SCR-PICK-NUMB
                                    L_KIND SUBRC.
  IF SUBRC EQ 0.
    CURRENT_SCR-FIELD_FOUND = 'X'.
  ELSE.
    CLEAR CURRENT_SCR-FIELD_FOUND.
  ENDIF.
  if current_scr-program ne last_sscr_prog.
    if screen_progs-program ne current_scr-program.
      READ TABLE SCREEN_PROGS WITH KEY current_scr-program
           BINARY SEARCH.
    endif.
    %_sscr[] = screen_progs-sscr.
    last_sscr_prog = current_scr-program.
  endif.

  if current_scr-program ne current_screen-program or
     current_scr-dynnr ne current_screen-dynnr.
    READ TABLE SCREENS WITH KEY PROGRAM = current_scr-program
                              DYNNR   = current_scr-dynnr
                              BINARY SEARCH
               INTO CURRENT_SCREEN.
  endif.


  current_scr-reset_ucomm = <SSCRFIELDS>-UCOMM.
*  IF  (  <SSCRFIELDS>-UCOMM = 'OPTI' OR <SSCRFIELDS>-UCOMM = 'DELS'
*                                    OR <SSCRFIELDS>-UCOMM = 'DELA'
*                                    OR <SSCRFIELDS>-UCOMM = fdelline
*                                    OR <SSCRFIELDS>-UCOMM = fdelall
*                                    OR ( <SSCRFIELDS>-UCOMM(1) = '%'
*                              and not <SSCRFIELDS>-UCOMM(2) = '%_' )
*                                    OR <SSCRFIELDS>-UCOMM(1) = '&' ).
  if not current_scr-spec_ucomm is initial.
    IF  SUBRC NE 0.
* There is at least one subscreen
      IF NOT CURRENT_SCR-LAST_SUBSCREEN_PROGRAM IS INITIAL.
        SUBRC = 0.
* Then maybe the OK-Code can be handled by one of tthe subscreens
        CLEAR: <SSCRFIELDS>-UCOMM, SY-UCOMM.
      else.
* Should not happen because these are not specific ucomms
        if <SSCRFIELDS>-UCOMM(2) = '%_' "Bindewald.
          or <SSCRFIELDS>-UCOMM(4) eq '%_GC'.
          CLEAR SY-UCOMM.
          CLEAR <SSCRFIELDS>-UCOMM.
          subrc = 0.
        endif.
      ENDIF.
* Field found but the wrong type.
    ELSEif L_KIND NE 'S'.
      subrc = 4.
    ENDIF.

    CASE SUBRC.
      WHEN 0.
*        CURRENT_SCR-UCOMM = <SSCRFIELDS>-UCOMM.
      WHEN 4 .
        SET SCREEN SY-DYNNR.
        MESSAGE S655.
      WHEN 12.
        SET SCREEN SY-DYNNR.
        MESSAGE S652.
    ENDCASE.
*  ELSE.
*    CURRENT_SCR-UCOMM = <SSCRFIELDS>-UCOMM.
  ENDIF.
  IF NOT CURRENT_SCREEN-TABBLOCKS IS INITIAL.
    PERFORM FILL_TAB_BLOCKS.
  ENDIF.
  PERFORM INIT_BLOCKS_PAI(RSDBSPBL) CHANGING CURRENT_SCREEN-BLOCKS.
* Hinweis 26573
  if flag_suppress_gpa ne space.
    clear flag_suppress_gpa.
    system-call reset-gpa.
  endif.
* Hinweis 26573
ENDFORM.                           " %_INIT_PAI
FORM INIT_PAI_J USING P_PROG LIKE SY-REPID
                      P_SWITCH TYPE C.

  DATA SUBRC LIKE SY-SUBRC.
  DATA L_KIND LIKE RSSCR-KIND.
  DATA L_BLOCKS TYPE SYDB0_BLOCKS.
  DATA L_PROG LIKE SY-REPID.

  PERFORM SWITCH_TO_SUBSCREEN_PAI USING P_PROG.

  current_scr-spec_ucomm = parent_scr-spec_ucomm.

  case PARENT_SCR-FIELD_FOUND.
    when space.        " Noch nicht gefunden.
      PERFORM %_SELECTED_FIELD CHANGING CURRENT_SCR-PICK-FIELD
                                        CURRENT_SCR-PICK-NUMB
                                        L_KIND SUBRC.
      if subrc = 0.
        current_scr-field_found = 'X'.
      endif.
      if not current_scr-spec_ucomm is initial.
        IF  SUBRC NE 0.
          clear: <SSCRFIELDS>-UCOMM, SY-UCOMM.
          subrc = 0.
        elseif L_KIND NE 'S'.
          subrc = 4.
        ENDIF.
        CASE SUBRC.
          WHEN 0.
          WHEN 4 .
            MESSAGE S655.
          WHEN 12.
            MESSAGE S652.
        ENDCASE.
      ELSE.
        CURRENT_SCR-RESET_UCOMM = <SSCRFIELDS>-UCOMM.
      ENDif.
  when 'X' or 'A'.   " found in some ancestor
    current_scr-field_found = 'A'.
  when 'Y'.          " found and handled
* Field found in ancestor.
    current_scr-field_found = 'Y'.
  ENDcase.
*  current_scr-ucomm = <SSCRFIELDS>-UCOMM.
  PERFORM INIT_BLOCKS_PAI(RSDBSPBL) CHANGING CURRENT_SCREEN-BLOCKS.
  append parent_scr to ancestors_scr.
ENDFORM.                           " INIT_PAI_J

form is_sel_specific_ucomm using p_ucomm like sy-ucomm
                           changing p_specific type sychar01.
  IF     p_ucoMM = 'OPTI'   OR p_ucomm = 'DELS'
         OR p_UCOMM = 'DELA'   OR p_UCOMM = fdelall
         OR p_UCOMM = fdelline
         OR ( p_UCOMM(1) = '%' and  not p_UCOMM(2) = '%_' )
         OR p_UCOMM(1) = '&'.
    p_specific = 'X'.
  else.
    clear p_specific.
  endif.
endform.
* Wird jedesmal bei DCI gerufen. Findet heraus, ob dunkles Bild
* doch gesendet wird
form dci.
  data l_prog like sy-repid.
  check current_scr-mode = 'S' and
        g_subty z CV_SUBTY_VIA_SELSCR and sy-dynnr = current_scr-dynnr.
  system-call kernel_info 'DYNPRO_PROGRAM' l_prog.
  check l_prog = current_scr-program.
  add 1 to g_dark_times.
endform.
*------------ Besorgen (ggfls. modifizierte) Feldeigenschaften --------*
* wird aus RSDYNS00 gerufen.                                           *
FORM GET_LOW_HIGH_SCREEN USING    P_SELNAME
                         CHANGING P_SCREEN_LOW  LIKE SCREEN
                                  P_SCREEN_HIGH LIKE SCREEN.

  DATA L_SELOPTS TYPE SYDB0_SELOPTS.

  READ TABLE CURRENT_SCREEN-SELOPTS WITH KEY P_SELNAME BINARY SEARCH
       INTO L_SELOPTS TRANSPORTING SCREEN_LOW SCREEN_HIGH.
  CHECK SY-SUBRC = 0.

  P_SCREEN_LOW  = L_SELOPTS-SCREEN_LOW.
  P_SCREEN_HIGH = L_SELOPTS-SCREEN_HIGH.

ENDFORM.                             "  GET_LOW_HIGH_SCREEN.
* Versorgt RSCONVERT-Struktur in SELNUM für Wertemengenbild
* P_TABIX: Index in CURRENT_SCREEN-SELNUM
FORM FILL_CONVERT USING P_TABIX LIKE SY-TABIX
                        P_SSCR LIKE RSSCR
                  CHANGING P_SELNUM TYPE SYDB0_SELNUM.

  DATA L_SUBRC LIKE SY-SUBRC.

  IF P_SELNUM-INITIALIZED = SPACE.
    MOVE 'X' TO P_SELNUM-INITIALIZED.
    MOVE: P_SSCR-TYPE       TO P_SELNUM-CONVERT-TYPE,
          P_SSCR-LENGTH     TO P_SELNUM-CONVERT-LENGTH,
          P_SSCR-OLENGTH    TO P_SELNUM-CONVERT-OLENGTH,
          P_SSCR-MISCELL(5) TO P_SELNUM-CONVERT-CONVEXIT.
    perform ileng_2_cleng in program rsdynss0
                          using    p_selnum-convert-type
                                   p_selnum-convert-length
                          changing p_selnum-convert-clength.

    IF P_SSCR-DBFIELD NE SPACE AND P_SSCR-DBFIELD(5) NE '%_DCB'.
* DDIC-Bezug
      MOVE  P_SSCR-MISCELL+5(2) TO P_SELNUM-CONVERT-DECIMALS.
      IF P_SSCR-FLAG2 O SSCR_F2_SIGN.
        MOVE 'X' TO P_SELNUM-CONVERT-SIGN.
      ENDIF.
    ELSE.
      PERFORM SET_SIGN_AND_OLENGTH USING P_SSCR
                                         P_SELNUM-CONVERT-OLENGTH
                                         P_SELNUM-CONVERT-SIGN.
      IF P_SSCR-DBFIELD(5) = '%_DCB'.
        MOVE  P_SSCR-DBFIELD+6(2) TO P_SELNUM-CONVERT-DECIMALS.
      ENDIF.
    ENDIF.
* Currency/Mengenfeld ?
    IF P_SSCR-TYPE = 'P'.
      PERFORM GET_CURR_QUAN(RSDBSPDD) USING    P_SSCR-DBFIELD
                                      CHANGING P_SELNUM-REFFIELD
                                               P_SELNUM-CONVERT-DYNPTYPE
                                               L_SUBRC.
    ENDIF.
* Decflot
    IF P_SSCR-TYPE = 'a' OR P_SSCR-TYPE = 'e'.
      PERFORM GET_OUTPUTSTYLE_DECFLOT(RSDBSPDD) USING    P_SSCR-DBFIELD
                                                CHANGING P_SELNUM-CONVERT-OUTPUTSTYLE.
    ENDIF.
* Groß-/Kleinschreibung ?
    IF P_SSCR-FLAG1 O SSCR_F1_LOWC.
      MOVE 'X' TO P_SELNUM-CONVERT-LOWER.
    ENDIF.

    MODIFY CURRENT_SCREEN-SELNUM FROM P_SELNUM INDEX P_TABIX.

  ENDIF.

  IF P_SELNUM-CONVERT-DYNPTYPE = 'CURR' OR
     P_SELNUM-CONVERT-DYNPTYPE = 'QUAN'.
    PERFORM SET_CURR_QUAN_DECI(RSDBSPDD)
                               USING    CURRENT_SCREEN-PROGRAM
                                        P_SELNUM-CONVERT-DYNPTYPE
                                        P_SELNUM-REFFIELD
                               CHANGING P_SELNUM-CONVERT-DECIMALS
*                                        P_SELNUM-CONVERT-DDDECIMALS
                                        P_SELNUM-CONVERT-QUAN_UNIT.
  ENDIF.

ENDFORM.                                 "   FILL_CONVERT
* Setzt für programminterne Select-Options Vorz. + Ausgabelänge
FORM SET_SIGN_AND_OLENGTH USING P_SSCR STRUCTURE RSSCR
                                P_OLENGTH LIKE RSCONVERT-OLENGTH
                                P_SIGN    LIKE RSCONVERT-SIGN.

  DATA:BEGIN OF L_DESC,
         NAME(6) VALUE '%_DCB%',
         ODEC(2) TYPE N,
         UNUSED(13),
        END OF L_DESC.

  DATA L_INT TYPE I.

  CHECK  P_SSCR-TYPE = 'I' OR P_SSCR-TYPE = 'P' OR
         P_SSCR-TYPE = 's' OR P_SSCR-TYPE = 'b' OR
         P_SSCR-TYPE = 'a' OR P_SSCR-TYPE = 'e' OR
         P_SSCR-TYPE = '8'.

  CASE P_SSCR-TYPE.
    WHEN 'P'.
      MOVE P_SSCR-DBFIELD TO L_DESC.

      L_INT = ( 2 * P_SSCR-LENGTH - 1 - L_DESC-ODEC ) MOD 3.
      IF L_INT = 0.
        L_INT = ( 2 * P_SSCR-LENGTH - 1 - L_DESC-ODEC ) DIV 3 - 1.
      ELSE.
        L_INT = ( 2 * P_SSCR-LENGTH - 1 - L_DESC-ODEC ) DIV 3.
      ENDIF.

      IF L_INT > 0.
        ADD L_INT TO:  P_OLENGTH.
      ENDIF.
    WHEN '8'.
      P_OLENGTH = 26.
    WHEN 'I'.
      P_OLENGTH = 14.
    WHEN 'b'.
      P_OLENGTH = 3.
  ENDCASE.

  CHECK P_SSCR-TYPE NE 'b'.
  MOVE 'X' TO P_SIGN.

ENDFORM.                            " SET_SIGN_AND_OLENGTH

*--------- Selection Screen 1000: Update ------------------------------*
FORM %_UPD_TAB_PART_1 TABLES SELTAB                               "#EC *
             USING P_SIGN   LIKE RSPARAMS-SIGN
                   P_OPTION LIKE RSPARAMS-OPTION
                   P_LOW P_HIGH
                   P_DESC STRUCTURE RSSELINT
                   P_SUBRC LIKE SY-SUBRC.

  FIELD-SYMBOLS <L_SELOPTS> TYPE SYDB0_SELOPTS.

  IF DYNS-SELSCREEN_FLAG = SPACE.
    READ TABLE CURRENT_SCREEN-SELOPTS WITH KEY P_DESC-NAME BINARY SEARCH
         ASSIGNING <L_SELOPTS>.
    check sy-subrc = 0.
    IF <L_SELOPTS>-SSCR-FLAG2 Z SSCR_F2_DYN.
      PERFORM %_UPD_TAB_PART_2
                TABLES   SELTAB
                USING    CURRENT_SCR-PICK-FIELD
                CHANGING P_SIGN P_OPTION P_LOW P_HIGH P_DESC P_SUBRC.
    ELSE.
      PERFORM UPD_DYN_TURK TABLES SELTAB
                           USING  P_DESC 0 P_SUBRC.
    ENDIF.
  ELSE.
    PERFORM ADJUST_SELOP_PAI IN PROGRAM (DYNS-PROGRAM)
                 TABLES SELTAB
                 USING P_SIGN P_OPTION P_LOW P_HIGH
                       CURRENT_SCR-PICK-FIELD P_DESC P_SUBRC.
  ENDIF.

ENDFORM.                         " %_UPD_TAB_PART_1
* Macht eigentliche Arbeit
FORM %_UPD_TAB_PART_2 TABLES SELTAB                               "#EC *
                      USING    P_PICKFIELD LIKE RSSCR-NAME
                      CHANGING P_SIGN P_OPTION P_LOW P_HIGH
                               P_DESC STRUCTURE RSSELINT
                               P_SUBRC LIKE SY-SUBRC.

  DATA: SUBRC  LIKE SY-SUBRC.
  DATA: L_TABIX LIKE SY-TABIX.
  DATA: LINCNT LIKE SY-TFILL.
  DATA: SAVE_OPTION(2).
  DATA: SAVE_TITLE LIKE SY-TITLE.
  DATA: SAVE_PFKEY LIKE SY-PFKEY.
  DATA SELECTED.             " zeile ausgewählt ?
  DATA JUST_DISPLAY.         " Optionen nur im Anzeigemodus ?
  DATA OPTION_SET(3).
  DATA L_WARNING LIKE SY-SUBRC.
  DATA L_UCOMM   LIKE SY-UCOMM.
  DATA L_TYPE.
  DATA L_LOW(45).
  DATA L_HIGH(45).
  DATA L_SELOPTS TYPE SYDB0_SELOPTS.
  DATA L_FORCE_POPUP.        " Bei Optionenbild auf jeden Fall Popup!
  DATA L_SELOPT_NO_INPUT TYPE SYDB0_SELNOIN.
  DATA L_OPTION LIKE RALDB-OPTION.

  MOVE <SSCRFIELDS>-UCOMM TO L_UCOMM.

  DESCRIBE FIELD P_LOW TYPE L_TYPE.

  DESCRIBE TABLE SELTAB LINES LINCNT.

  READ TABLE CURRENT_SCREEN-SELOPTS WITH KEY P_DESC-NAME BINARY SEARCH
       INTO L_SELOPTS.
  check sy-subrc = 0.
  L_TABIX = SY-TABIX.
  if l_selopts-displayed_line <= 0.
    l_selopts-displayed_line = 1.
  endif.

* Prüfe, ob ausgewählte Zeile prozessiert wird.
  IF L_UCOMM          = 'OPTI' OR L_UCOMM  = 'DELS'
                    OR L_UCOMM             = 'DELA'
                    OR L_UCOMM             = fdelall
                    OR L_UCOMM             = fdelline
                    OR ( L_UCOMM(1)          = '%' and not
                         L_UCOMM(2)          = '%_' )
                    OR L_UCOMM(1)          = '&'.
    IF P_PICKFIELD = P_DESC-NAME.
      MOVE 'X' TO SELECTED.
    ENDIF.
    IF L_UCOMM(1)          = '&'.
      L_UCOMM          = 'OPTI'.
    ENDIF.
  ENDIF.
* OPTI auf Zeile, in der nichts erlaubt ist?
  IF SELECTED NE SPACE AND L_UCOMM = 'OPTI'.
    READ TABLE CURRENT_SCR-SELOPT_NO_INPUT WITH KEY L_SELOPTS-NUMB
                   INTO L_SELOPT_NO_INPUT BINARY SEARCH.
    IF SY-SUBRC = 0 AND L_SELOPT_NO_INPUT-LOW NE SPACE
     OR L_SELOPTS-SCREEN_LOW-INPUT NE '1' AND
        L_SELOPTS-SCREEN_HIGH-INPUT NE '1' AND
        LINCNT = 0.
      MESSAGE I759 WITH L_SELOPTS-TEXT.
      EXIT.
    ENDIF.
  ENDIF.

* Feld OPTION ist nicht auf dem Screen
  IF L_SELOPTS-DISPLAYED_LINE LE LINCNT.
    IF L_SELOPTS-SSCR-FLAG2 Z SSCR_F2_DYN.
      PERFORM GET_OLD_OPTION TABLES SELTAB
            USING L_SELOPTS-DISPLAYED_LINE P_OPTION SAVE_OPTION
                  P_LOW P_HIGH L_TYPE L_WARNING.
      MOVE SAVE_OPTION TO P_OPTION.
    ELSE.
      PERFORM GET_OLD_OPTION_DYN TABLES SELTAB
                                 USING  L_SELOPTS-NAME
                                        L_SELOPTS-DISPLAYED_LINE
                                        P_OPTION
                                        P_LOW P_HIGH
                                        L_TYPE
                                        L_WARNING.
    ENDIF.
  ELSE.
    CLEAR P_OPTION.
  ENDIF.

  IF L_TYPE = 'T'.
    IF P_LOW = SPACE.
      CLEAR P_LOW.
    ENDIF.
    IF P_HIGH = SPACE.
      CLEAR P_HIGH.
    ENDIF.
  ENDIF.

* Leere Zeile, nicht für Optionen ausgewählt
  IF P_LOW IS INITIAL AND P_HIGH IS INITIAL.
    IF L_SELOPTS-DISPLAYED_LINE GT LINCNT.
      IF SELECTED = SPACE OR
         L_UCOMM NE 'OPTI' AND L_UCOMM NE 'DELS' AND L_UCOMM NE 'DELA'
         and l_ucomm ne fdelall and l_ucomm ne fdelline.
        EXIT.
      ENDIF.
    ENDIF.
  ENDIF.

  IF SELECTED = SPACE OR ( L_UCOMM NE 'DELS' AND L_UCOMM NE 'DELA'
    and l_ucomm ne fdelall and l_ucomm ne fdelline ).
    PERFORM %_SELC_CHECK_PAI USING 'X' L_SELOPTS
                             CHANGING P_LOW P_HIGH P_OPTION P_SIGN
                                      SUBRC.
  ENDIF.

  IF L_WARNING > 0         AND
           ( SELECTED = SPACE OR ( L_UCOMM(1)          = '%'
             and not L_UCOMM(2)          = '%_'   ) ).
    CASE L_WARNING.
      WHEN 1.                  " Jetzt initial, vorher nicht.
        SELECTED = 'X'.
        L_UCOMM = 'DELS'.
        P_OPTION = SPACE.
      WHEN 2.                  " Jetzt maskiert, vorher nicht
        IF L_SELOPTS-X_MAIN_OPTIONS Z OPTION_CP.   "  CP erlaubt
          P_OPTION = 'CP'.
        ENDIF.
    ENDCASE.
  ENDIF.

* Sonderregelungen, falls Restriktionen da sind.
* Aber nur, wenn nicht alles ausgeblendet wurde.
  IF L_SELOPTS-X_MAIN_OPTIONS NE '00' AND
     L_SELOPTS-SCREEN_LOW-INVISIBLE NE '1'.
    IF P_OPTION NE SPACE OR L_UCOMM = 'OPTI'.
      IF L_SELOPTS-JUST_INTERVALS NE SPACE       AND
         P_OPTION NE 'BT' AND P_OPTION NE 'NB'.
        IF P_OPTION NE SPACE.
          MESSAGE E757 WITH L_SELOPTS-TEXT.
        ELSE.
          MESSAGE E758 WITH L_SELOPTS-TEXT.
        ENDIF.
      ELSEIF L_SELOPTS-JUST_PATTERNS NE SPACE       AND
         P_OPTION NE 'CP' AND P_OPTION NE 'NP'.
        IF P_OPTION NE SPACE.
          MESSAGE E760 WITH L_SELOPTS-TEXT.
        ELSE.
          MESSAGE E764 WITH L_SELOPTS-TEXT.
        ENDIF.
      ELSEIF L_SELOPTS-JUST_INT_OR_PATT NE SPACE       AND
         P_OPTION NE 'CP' AND P_OPTION NE 'NP'       AND
         P_OPTION NE 'BT' AND P_OPTION NE 'NB'.
        IF P_OPTION NE SPACE.
          MESSAGE E765 WITH L_SELOPTS-TEXT.
        ELSE.
          MESSAGE E766 WITH L_SELOPTS-TEXT.
        ENDIF.
      ENDIF.
    ENDIF.

    IF P_OPTION = 'EQ' AND L_SELOPTS-X_MAIN_OPTIONS O OPTION_EQ.
      L_UCOMM = 'OPTI'.
      P_OPTION = SPACE.
      SELECTED = 'X'.
      L_FORCE_POPUP = 'X'.
    ENDIF.

    IF P_OPTION = 'CP' AND L_SELOPTS-X_MAIN_OPTIONS O OPTION_CP   OR
       P_OPTION = 'BT' AND L_SELOPTS-X_MAIN_OPTIONS O OPTION_BT.
      L_UCOMM = 'OPTI'.
      P_OPTION = SPACE.
      SELECTED = 'X'.
      L_FORCE_POPUP = 'X'.
    ENDIF.

    IF L_SELOPTS-SG_MAIN NE SPACE AND P_SIGN NE L_SELOPTS-SG_MAIN
       AND P_SIGN NE SPACE.
      L_UCOMM = 'OPTI'.
      P_SIGN   = SPACE.
      SELECTED = 'X'.
      L_FORCE_POPUP = 'X'.
    ENDIF.

  ENDIF.

  IF SELECTED NE SPACE.
    CASE L_UCOMM.
      WHEN 'DELS' or fdelline.          " Löschen Zeile
        PERFORM CHECK_SELOPT_DISPLAY USING    CURRENT_SCREEN-INACTIVE
                                              L_SELOPTS
                                     CHANGING JUST_DISPLAY.
        IF JUST_DISPLAY NE SPACE.
          CLEAR: <SSCRFIELDS>-UCOMM, SY-UCOMM.
          MESSAGE I789 WITH L_SELOPTS-TEXT.
          EXIT.
        ENDIF.
        PERFORM DELETE_LINE  TABLES   SELTAB
                             USING    L_TABIX
                                      LINCNT
                                      P_SIGN
                                      P_OPTION
                                      P_LOW
                                      P_HIGH
                                      L_SELOPTS
                                      CURRENT_SCREEN-SELOPTS.
        IF CURRENT_SCR-MODE EQ 'J' and <sscrfields>-ucomm eq 'DELS'.
           CURRENT_SCR-RESET_UCOMM = '%_RESET'.
        ENDIF.
        EXIT.
      WHEN 'DELA' or fdelall.          " Löschen alle Zeilen
        PERFORM CHECK_SELOPT_DISPLAY USING    CURRENT_SCREEN-INACTIVE
                                              L_SELOPTS
                                     CHANGING JUST_DISPLAY.
        IF JUST_DISPLAY NE SPACE.
          CLEAR: <SSCRFIELDS>-UCOMM, SY-UCOMM.
          MESSAGE I789 WITH L_SELOPTS-TEXT.
          EXIT.
        ENDIF.
        REFRESH SELTAB.
        CLEAR: P_LOW, P_HIGH, P_SIGN, P_OPTION.
        MOVE VALU_ICONS-GREY  TO P_DESC-VALU_PUSH.
        IF L_SELOPTS-SSCR-SPAGPA NE SPACE.
          SET PARAMETER ID L_SELOPTS-SSCR-SPAGPA FIELD P_LOW.
        ENDIF.
        L_SELOPTS-DISPLAYED_LINE = 1.
        MODIFY CURRENT_SCREEN-SELOPTS FROM L_SELOPTS INDEX L_TABIX.
        IF CURRENT_SCR-MODE EQ 'J'.
           CURRENT_SCR-RESET_UCOMM = '%_RESET'.
        ENDIF.
        EXIT.
      WHEN 'OPTI'.          " Optionen
        IF L_WARNING NE 1.
          PERFORM %_SET_OPTION_SET USING    P_LOW P_HIGH
                                            L_TYPE L_SELOPTS-SSCR
                                            L_SELOPTS-SCREEN_HIGH
                                   CHANGING OPTION_SET.
        ELSE.
          OPTION_SET = 'INI'.
          L_FORCE_POPUP = 'X'.
        ENDIF.
        IF OPTION_SET = 'INI' AND L_SELOPTS-DISPLAYED_LINE GT LINCNT.
          L_FORCE_POPUP = 'X'.
        ENDIF.
        MOVE SY-TITLE TO SAVE_TITLE.
        MOVE SY-PFKEY TO SAVE_PFKEY.
        PERFORM CHECK_SELOPT_DISPLAY USING    CURRENT_SCREEN-INACTIVE
                                              L_SELOPTS
                                     CHANGING JUST_DISPLAY.

        CLEAR L_LOW.
        CLEAR L_HIGH.
        WRITE P_LOW  TO L_LOW(L_SELOPTS-SCREEN_LOW-LENGTH).
        WRITE P_HIGH TO L_HIGH(L_SELOPTS-SCREEN_HIGH-LENGTH).
        CALL FUNCTION 'RS_SET_SELECT_OPTIONS_OPTIONS'
             EXPORTING SELCNAME     = P_DESC-NAME
                       SELCTEXT     = P_DESC-TEXT
                       SIGN         = P_SIGN
                       OPTION       = P_OPTION
                       LOW          = L_LOW
                       HIGH         = L_HIGH
                       OLENGTH      = L_SELOPTS-SCREEN_LOW-LENGTH
                       OLENGTH_HIGH = L_SELOPTS-SCREEN_HIGH-LENGTH
                       OPTION_SET   = OPTION_SET
                       X_OPTIONS    = L_SELOPTS-X_MAIN_OPTIONS
                       SIGNS_RESTRICTION = L_SELOPTS-SG_MAIN
                       JUST_DISPLAY = JUST_DISPLAY
                       FORCE_LIST   = L_FORCE_POPUP
             IMPORTING SIGN   = P_SIGN
                       OPTION = P_OPTION
             EXCEPTIONS NOT_EXECUTED = 4
                        DELETE_LINE  = 8.
        MOVE SY-SUBRC TO SUBRC.
        IF CURRENT_SCR-MODE NE 'J'.
          SET TITLEBAR '%_T' WITH SAVE_TITLE.  "#EC *
          PERFORM SET_GUI_STATUS USING SAVE_PFKEY.
        ELSE.
          CURRENT_SCR-RESET_UCOMM = '%_RESET'.
        ENDIF.
        CASE SUBRC.
          WHEN 0.
          WHEN 4.
            IF L_SELOPTS-DISPLAYED_LINE > LINCNT.
              CLEAR: P_LOW, P_HIGH, P_SIGN, P_OPTION.
            ENDIF.
            EXIT.
          WHEN 8.
            PERFORM DELETE_LINE  TABLES   SELTAB
                                 USING    L_TABIX
                                          LINCNT
                                          P_SIGN
                                          P_OPTION
                                          P_LOW
                                          P_HIGH
                                          L_SELOPTS
                                          CURRENT_SCREEN-SELOPTS.
            EXIT.
        ENDCASE.
        IF P_LOW IS INITIAL AND NOT P_HIGH IS INITIAL
           AND P_OPTION NE 'BT' AND P_OPTION NE 'NB'.
          MOVE P_HIGH TO P_LOW.
          CLEAR P_HIGH.
        ENDIF.
    ENDCASE.
  ENDIF.

  IF L_SELOPTS-SSCR-FLAG2 O SSCR_F2_DYN.
    PERFORM UPD_DYN_TURK TABLES SELTAB
                         USING  P_DESC 1 P_SUBRC.
  ENDIF.

  IF L_SELOPTS-DISPLAYED_LINE GT LINCNT.
    APPEND SELTAB.
  ELSE.
    MODIFY SELTAB INDEX L_SELOPTS-DISPLAYED_LINE.
  ENDIF.

ENDFORM.                               "%_UPD_TAB_PART_2

FORM GET_OLD_OPTION TABLES SELTAB
                    USING READINDEX OPTION OLD_OPTION
                          P_LOW P_HIGH P_TYPE P_SUBRC.
  LOCAL SELTAB.
  LOCAL OPTION.
  LOCAL P_LOW.
  LOCAL P_HIGH.

  DATA L_SUBRC LIKE SY-SUBRC.

  IF P_LOW IS INITIAL AND P_HIGH IS INITIAL.
    L_SUBRC = 1.
  ELSEIF P_TYPE = 'C' AND
         P_LOW CA '*+' AND P_HIGH IS INITIAL.
    L_SUBRC = 2.
  ENDIF.

  READ TABLE SELTAB INDEX READINDEX.
  MOVE OPTION TO OLD_OPTION.

  P_SUBRC = 0.

  CASE L_SUBRC.
    WHEN 1.                          " Jetzt initial
      IF NOT ( P_LOW IS INITIAL AND P_HIGH IS INITIAL ). " Vorher nicht
        P_SUBRC = 1.
      ENDIF.
    WHEN 2.                          " Jetzt Maskierungszeichen
      IF P_LOW NA '*+' OR P_TYPE NE 'C'.    " Vorher nicht
        P_SUBRC = 2.
      ENDIF.
  ENDCASE.

ENDFORM.               " GET_OLD_OPTION

FORM GET_OLD_OPTION_DYN TABLES P_SEL  STRUCTURE RSDSSELOPT
                        USING  P_NAME LIKE RSSCR-NAME
                               P_READINDEX TYPE I
                               P_OPTION  LIKE RSDSSELOPT-OPTION
                               P_LOW P_HIGH
                               P_TYPE LIKE RSSCR-TYPE
                               P_SUBRC LIKE SY-SUBRC.

  DATA: L_SEL LIKE RSDSSELOPT.

  DATA:    L_INT_LOW  TYPE I,
           L_INT_HIGH TYPE I,
           L_IN8_LOW  TYPE I,
           L_IN8_HIGH TYPE I,
           L_FLT_LOW  TYPE F,
           L_FLT_HIGH TYPE F,
           l_dfl16_low  type decfloat16,
           l_dfl16_high type decfloat16,
           l_dfl34_low  type decfloat34,
           l_dfl34_high type decfloat34,
           L_CIN_LOW  LIKE RSDSSELOPT-LOW,
           L_CIN_HIGH LIKE RSDSSELOPT-HIGH.

  DATA L_SUBRC LIKE SY-SUBRC.

  FIELD-SYMBOLS: <L_LOW_INTERNAL>, <L_HIGH_INTERNAL>,
                 <L_DYNREF> TYPE SYDB0_DYNREF.

  IF P_LOW IS INITIAL AND P_HIGH IS INITIAL.
    L_SUBRC = 1.
  ELSEIF P_TYPE = 'C' AND P_LOW CA '*+' AND P_HIGH IS INITIAL.
    L_SUBRC = 2.
  ENDIF.

  READ TABLE P_SEL INTO L_SEL INDEX P_READINDEX.
  MOVE L_SEL-OPTION TO P_OPTION.

  READ TABLE SCREEN_PROGS-DYNREF WITH KEY NAME = P_NAME
       BINARY SEARCH ASSIGNING <L_DYNREF>.
  IF SY-SUBRC NE 0.
    ASSIGN: P_SEL-LOW  TO <L_LOW_INTERNAL>,
            P_SEL-HIGH TO <L_HIGH_INTERNAL>.
  ELSE.
    IF <L_DYNREF>-CONVERT-TYPE EQ 'I' OR
       <L_DYNREF>-CONVERT-TYPE EQ 's' OR
       <L_DYNREF>-CONVERT-TYPE EQ 'b'.
      ASSIGN: L_INT_LOW  TO <L_LOW_INTERNAL>,
              L_INT_HIGH TO <L_HIGH_INTERNAL>.
    ELSEIF <L_DYNREF>-CONVERT-TYPE = '8'.
      ASSIGN: L_IN8_LOW  TO <L_LOW_INTERNAL>,
              L_IN8_HIGH TO <L_HIGH_INTERNAL>.
    ELSEIF <L_DYNREF>-CONVERT-TYPE = 'F'.
      ASSIGN: L_FLT_LOW  TO <L_LOW_INTERNAL>,
              L_FLT_HIGH TO <L_HIGH_INTERNAL>.
    elseif <L_DYNREF>-CONVERT-TYPE = 'a'.
      assign l_dfl16_low to <L_LOW_INTERNAL>.
      assign l_dfl16_high to <L_HIGH_INTERNAL>.
    elseif <L_DYNREF>-CONVERT-TYPE = 'e'.
      assign l_dfl34_low to <L_LOW_INTERNAL>.
      assign l_dfl34_high to <L_HIGH_INTERNAL>.
    ELSE.
      IF <L_DYNREF>-CONVERT-TYPE NE 'P'.
       ASSIGN: L_CIN_LOW(<L_DYNREF>-CONVERT-cLENGTH) TO <L_LOW_INTERNAL>
                   TYPE <L_DYNREF>-CONVERT-TYPE.
      ASSIGN L_CIN_HIGH(<L_DYNREF>-CONVERT-cLENGTH) TO <L_HIGH_INTERNAL>
                   TYPE <L_DYNREF>-CONVERT-TYPE.
      ELSE.
       ASSIGN: L_CIN_LOW(<L_DYNREF>-CONVERT-clENGTH) TO <L_LOW_INTERNAL>
                      TYPE     <L_DYNREF>-CONVERT-TYPE
                      DECIMALS <L_DYNREF>-CONVERT-DECIMALS.
      ASSIGN L_CIN_HIGH(<L_DYNREF>-CONVERT-cLENGTH) TO <L_HIGH_INTERNAL>
                      TYPE     <L_DYNREF>-CONVERT-TYPE
                      DECIMALS <L_DYNREF>-CONVERT-DECIMALS.
      ENDIF.
    ENDIF.
  ENDIF.

  MOVE: L_SEL-LOW  TO <L_LOW_INTERNAL>,
        L_SEL-HIGH TO <L_HIGH_INTERNAL>.

  P_SUBRC = 0.

  CASE L_SUBRC.
    WHEN 1.                          " Jetzt initial
      IF NOT ( <L_LOW_INTERNAL> IS INITIAL AND
               <L_HIGH_INTERNAL> IS INITIAL ). " Vorher nicht
        P_SUBRC = 1.
      ENDIF.
    WHEN 2.                          " Jetzt Maskierungszeichen
      IF P_TYPE NE 'C' or <L_LOW_INTERNAL> NA '*+'.    " Vorher nicht
        P_SUBRC = 2.
      ENDIF.
  ENDCASE.

ENDFORM.               " GET_OLD_OPTION_DYN

FORM %_UPD_DYN_PARM USING P_PARAM LIKE RSDYNPAR-PARAM             "#EC *
                          P_NAME  LIKE RSSCR-NAME.

  DATA L_INT TYPE I.
  DATA L_FLT TYPE F.
  DATA L_TIME TYPE T.
  DATA L_DATE TYPE D.
  DATA L_SUBRC LIKE SY-SUBRC.
  DATA L_CONVERR LIKE RSCONVERR.
  DATA L_INITIAL.

  FIELD-SYMBOLS <L_DYNREF> TYPE SYDB0_DYNREF.

  FIELD-SYMBOLS <L_PARAM>.
  DATA: L_PARAM TYPE RSDYNPAR-PARAM.

  READ TABLE SCREEN_PROGS-DYNREF WITH KEY P_NAME BINARY SEARCH
       ASSIGNING <L_DYNREF>.
  CHECK SY-SUBRC = 0.

  IF <L_DYNREF>-CONVERT-DYNPTYPE = 'CURR' OR
     <L_DYNREF>-CONVERT-DYNPTYPE = 'QUAN'.
    PERFORM SET_CURR_QUAN_DECI(RSDBSPDD)
                               USING    CURRENT_SCREEN-PROGRAM
                                        <L_DYNREF>-CONVERT-DYNPTYPE
                                        <L_DYNREF>-CURR_REF
                               CHANGING <L_DYNREF>-CONVERT-DECIMALS
*                                        <L_DYNREF>-CONVERT-DDDECIMALS
                                        <L_DYNREF>-CONVERT-QUAN_UNIT.
  ENDIF.

  IF ( <L_DYNREF>-CONVERT-TYPE = 'P' OR
       <L_DYNREF>-CONVERT-TYPE = 'a' OR
       <L_DYNREF>-CONVERT-TYPE = 'e' ) AND
     <L_DYNREF>-CONVERT-OLENGTH GT <L_DYNREF>-CONVERT-WHERE_LENG.
     ASSIGN P_PARAM(<L_DYNREF>-CONVERT-WHERE_LENG) TO <L_PARAM>.
    PERFORM CONVERT_EX_2_WH(RSDYNSS0) USING    <L_DYNREF>-CONVERT
                                               P_PARAM
                                      CHANGING L_SUBRC
                                               L_CONVERR
                                               <L_PARAM>
                                               L_INITIAL.
    IF L_INITIAL IS INITIAL.
      CLEAR L_PARAM.
      MOVE <L_PARAM> TO L_PARAM.
      MOVE L_PARAM TO P_PARAM.
    ENDIF.
  ELSE.
    PERFORM CONVERT_EX_2_WH(RSDYNSS0) USING    <L_DYNREF>-CONVERT
                                             P_PARAM
                                    CHANGING L_SUBRC
                                             L_CONVERR
                                             P_PARAM
                                             L_INITIAL.
  ENDIF.

  IF L_SUBRC NE 0.
    PERFORM CONVERT_ERROR_E(RSDYNSS0)
            USING L_CONVERR <L_DYNREF>-CONVERT L_SUBRC.
  ENDIF.

  IF NOT L_INITIAL IS INITIAL.
    CASE <L_DYNREF>-CONVERT-TYPE.
      WHEN 'T'.
        MOVE L_TIME TO P_PARAM.
      WHEN 'D'.
        MOVE L_DATE TO P_PARAM.
      WHEN OTHERS.
        CLEAR P_PARAM.
    ENDCASE.
  ENDIF.

ENDFORM.                                " UPD_DYN_PARM
* Türkt Dinge für UPD_TAB_PART_2 bei dynamischem Bezug
FORM UPD_DYN_TURK TABLES P_SEL STRUCTURE RSDSSELOPT
                  USING  P_DESC STRUCTURE RSSELINT
                         P_MODE TYPE I
                         P_SUBRC LIKE SY-SUBRC.

  FIELD-SYMBOLS: <L_LOW_INTERNAL>, <L_HIGH_INTERNAL>,
                 <L_EX_LOW>, <L_EX_HIGH>,
                 <L_WH_LOW>, <L_WH_HIGH>,
                 <L_DYNREF> TYPE SYDB0_DYNREF.

  STATICS: L_INT_LOW  TYPE I,
           L_INT_HIGH TYPE I,
           L_IN8_LOW  TYPE I,
           L_IN8_HIGH TYPE I,
           L_FLT_LOW  TYPE F,
           L_FLT_HIGH TYPE F,
           l_dfl16_low  type decfloat16,
           l_dfl16_high type decfloat16,
           l_dfl34_low  type decfloat34,
           l_dfl34_high type decfloat34,
           L_CEX_LOW  LIKE RSDSSELOPT-LOW,
           L_CEX_HIGH LIKE RSDSSELOPT-HIGH,
           L_CWH_LOW  LIKE RSDSSELOPT-LOW,
           L_CWH_HIGH LIKE RSDSSELOPT-HIGH,
           L_CIN_LOW  LIKE RSDSSELOPT-LOW,
           L_CIN_HIGH LIKE RSDSSELOPT-HIGH,
           L_NAME LIKE RSSELINT-NAME.

  DATA: L_ERROR LIKE RSCONVERR,
        L_SUBRC LIKE SY-SUBRC,
        L_TIME TYPE T,
        L_DATE TYPE D.

  IF P_MODE = 1.               " alte Werte abholen
    IF L_NAME = P_DESC-NAME AND L_CEX_LOW  = P_SEL-LOW AND
                                L_CEX_HIGH = P_SEL-HIGH.
      MOVE: L_CWH_LOW  TO P_SEL-LOW,
            L_CWH_HIGH TO P_SEL-HIGH.
      EXIT.
    ENDIF.
  ENDIF.

  READ TABLE SCREEN_PROGS-DYNREF WITH KEY NAME = P_DESC-NAME
       BINARY SEARCH ASSIGNING <L_DYNREF>.
  IF SY-SUBRC NE 0.
    CHECK P_MODE = 0.
    MOVE: P_DESC-NAME      TO  L_NAME.
    MOVE  P_SEL-LOW        TO: L_CEX_LOW,  L_CWH_LOW.
    MOVE  P_SEL-HIGH       TO: L_CEX_HIGH, L_CWH_HIGH.
    PERFORM %_UPD_TAB_PART_2
              TABLES   P_SEL
              USING    CURRENT_SCR-PICK-FIELD
              CHANGING P_SEL-SIGN P_SEL-OPTION
                       P_SEL-LOW P_SEL-HIGH P_DESC P_SUBRC.
    EXIT.
  ENDIF.

  CLEAR: L_CWH_LOW, L_CWH_HIGH.
  ASSIGN P_SEL-HIGH(<L_DYNREF>-CONVERT-OLENGTH) TO <L_EX_HIGH>.
  ASSIGN P_SEL-LOW(<L_DYNREF>-CONVERT-OLENGTH) TO <L_EX_LOW>.
  ASSIGN L_CWH_HIGH(<L_DYNREF>-CONVERT-WHERE_LENG) TO <L_WH_HIGH>.
  ASSIGN L_CWH_LOW(<L_DYNREF>-CONVERT-WHERE_LENG) TO <L_WH_LOW>.

  IF <L_DYNREF>-CONVERT-LOWER IS INITIAL.
    TRANSLATE <L_EX_LOW> TO UPPER CASE.
    TRANSLATE <L_EX_HIGH> TO UPPER CASE.
  ENDIF.

  IF <L_DYNREF>-CONVERT-DYNPTYPE = 'CURR' OR
     <L_DYNREF>-CONVERT-DYNPTYPE = 'QUAN'.
    PERFORM SET_CURR_QUAN_DECI(RSDBSPDD)
                               USING    CURRENT_SCREEN-PROGRAM
                                        <L_DYNREF>-CONVERT-DYNPTYPE
                                        <L_DYNREF>-CURR_REF
                               CHANGING <L_DYNREF>-CONVERT-DECIMALS
*                                        <L_DYNREF>-CONVERT-DDDECIMALS
                                        <L_DYNREF>-CONVERT-QUAN_UNIT.
  ENDIF.

  IF <L_DYNREF>-CONVERT-TYPE EQ 'I' OR
     <L_DYNREF>-CONVERT-TYPE EQ 's' OR
     <L_DYNREF>-CONVERT-TYPE EQ 'b'.
    ASSIGN: L_INT_LOW  TO <L_LOW_INTERNAL>,
            L_INT_HIGH TO <L_HIGH_INTERNAL>.
  ELSEIF <L_DYNREF>-CONVERT-TYPE = '8'.
    ASSIGN: L_IN8_LOW  TO <L_LOW_INTERNAL>,
            L_IN8_HIGH TO <L_HIGH_INTERNAL>.
  ELSEIF <L_DYNREF>-CONVERT-TYPE = 'F'.
    ASSIGN: L_FLT_LOW  TO <L_LOW_INTERNAL>,
            L_FLT_HIGH TO <L_HIGH_INTERNAL>.
  elseif <L_DYNREF>-CONVERT-TYPE = 'a'.
    assign l_dfl16_low to <L_LOW_INTERNAL>.
    assign l_dfl16_high to <L_HIGH_INTERNAL>.
  elseif <L_DYNREF>-CONVERT-TYPE = 'e'.
    assign l_dfl34_low to <L_LOW_INTERNAL>.
    assign l_dfl34_high to <L_HIGH_INTERNAL>.
  ELSE.
    IF <L_DYNREF>-CONVERT-TYPE NE 'P'.
      ASSIGN: L_CIN_LOW(<L_DYNREF>-CONVERT-cLENGTH)  TO <L_LOW_INTERNAL>
                 TYPE <L_DYNREF>-CONVERT-TYPE.
      ASSIGN L_CIN_HIGH(<L_DYNREF>-CONVERT-cLENGTH) TO <L_HIGH_INTERNAL>
                 TYPE <L_DYNREF>-CONVERT-TYPE.
    ELSE.
      IF <L_DYNREF>-CONVERT-cLENGTH > 8.
        class cl_abap_char_utilities definition load.
        if cl_abap_char_utilities=>charsize > 1.
          <L_DYNREF>-CONVERT-cLENGTH = 8.
        endif.
      ENDIF.
      ASSIGN: L_CIN_LOW(<L_DYNREF>-CONVERT-cLENGTH)  TO <L_LOW_INTERNAL>
                    TYPE     <L_DYNREF>-CONVERT-TYPE
                    DECIMALS <L_DYNREF>-CONVERT-DECIMALS.
      ASSIGN L_CIN_HIGH(<L_DYNREF>-CONVERT-cLENGTH) TO <L_HIGH_INTERNAL>
                    TYPE     <L_DYNREF>-CONVERT-TYPE
                    DECIMALS <L_DYNREF>-CONVERT-DECIMALS.
    ENDIF.
  ENDIF.
  PERFORM CONVERT_EX_2_IN(RSDYNSS0) USING    <L_DYNREF>-CONVERT
                                             <L_EX_LOW>
                                    CHANGING L_SUBRC
                                             L_ERROR
                                             <L_LOW_INTERNAL>.
  IF L_SUBRC NE 0.
    PERFORM CONVERT_ERROR_E(RSDYNSS0)
            USING L_ERROR <L_DYNREF>-CONVERT L_SUBRC.
  ENDIF.
  MOVE <L_LOW_INTERNAL> TO <L_WH_LOW>.
  PERFORM CONVERT_EX_2_IN(RSDYNSS0) USING    <L_DYNREF>-CONVERT
                                             <L_EX_HIGH>
                                    CHANGING L_SUBRC
                                             L_ERROR
                                             <L_HIGH_INTERNAL>.
  IF L_SUBRC NE 0.
    PERFORM CONVERT_ERROR_E(RSDYNSS0)
            USING L_ERROR <L_DYNREF>-CONVERT L_SUBRC.
  ENDIF.
  MOVE <L_HIGH_INTERNAL> TO <L_WH_HIGH>.
  MOVE: P_DESC-NAME      TO  L_NAME,
        <L_EX_LOW>       TO L_CEX_LOW,
        <L_EX_HIGH>      TO L_CEX_HIGH,
        <L_WH_LOW>       TO L_CWH_LOW,
        <L_WH_HIGH>      TO L_CWH_HIGH.

  IF P_MODE = 0.
    PERFORM %_UPD_TAB_PART_2
              TABLES   P_SEL
              USING    CURRENT_SCR-PICK-FIELD
              CHANGING P_SEL-SIGN P_SEL-OPTION
                     <L_LOW_INTERNAL> <L_HIGH_INTERNAL> P_DESC P_SUBRC.
  ELSE.
    MOVE: L_CWH_LOW  TO P_SEL-LOW,
          L_CWH_HIGH TO P_SEL-HIGH.
  ENDIF.

ENDFORM.
* SELECT-OPTION nur zur Anzeige?
FORM CHECK_SELOPT_DISPLAY USING    P_INACTIVE TYPE SYDB0_RSSELID_T
                                   P_SELOPTS TYPE SYDB0_SELOPTS
                          CHANGING P_JUST_DISPLAY.

  CLEAR P_JUST_DISPLAY.

  READ TABLE P_INACTIVE WITH KEY P_SELOPTS-NUMB BINARY SEARCH
       TRANSPORTING NO FIELDS.
  IF SY-SUBRC = 0.
    MOVE 'X' TO P_JUST_DISPLAY.
  ENDIF.
  IF P_JUST_DISPLAY = SPACE          AND
       P_SELOPTS-SCREEN_LOW-INPUT NE '1' AND
       P_SELOPTS-SCREEN_HIGH-INPUT NE '1'.
    MOVE 'X' TO P_JUST_DISPLAY.
  ENDIF.

ENDFORM.
* Zeile löschen
*  P_LINE:    Zu löschende Zeile
*  P_SELOPTS_IX: Index in SELOPTS. Zeile muß in Kopfzeile stehen!
*  P_TFILL: Zeilenzahl in P_SELTAB
FORM DELETE_LINE  TABLES   P_SELTAB
                  USING    P_SELOPTS_IX LIKE SY-TABIX
                  CHANGING P_TFILL LIKE SY-TFILL
                           P_SIGN   LIKE RSPARAMS-SIGN
                           P_OPTION LIKE RSPARAMS-OPTION
                           P_LOW
                           P_HIGH
                           P_SELOPTS TYPE SYDB0_SELOPTS
                           P_SELOPTS_T TYPE SYDB0_SELOPTS_T.

  IF P_SELOPTS-DISPLAYED_LINE LE P_TFILL.
    DELETE P_SELTAB INDEX P_SELOPTS-DISPLAYED_LINE.
  ENDIF.
  IF P_TFILL LE 1.
    CLEAR: P_LOW, P_HIGH, P_SIGN, P_OPTION.
    IF P_SELOPTS-SSCR-SPAGPA NE SPACE.
      SET PARAMETER ID P_SELOPTS-SSCR-SPAGPA FIELD P_LOW.
    ENDIF.
    P_SELOPTS-DISPLAYED_LINE = 1.
    MODIFY P_SELOPTS_T FROM P_SELOPTS INDEX P_SELOPTS_IX.
  ELSE.
    PERFORM CHECK_FIRST_LINE  TABLES   P_SELTAB
                              USING    P_SELOPTS-SSCR
                              CHANGING P_SIGN
                                       P_OPTION
                                       P_LOW
                                       P_HIGH
                                       P_SELOPTS.
    MODIFY P_SELOPTS_T INDEX P_SELOPTS_IX FROM P_SELOPTS.
*   P_LINE = P_SELOPTS-DISPLAYED_LINE.
    READ TABLE P_SELTAB INDEX P_SELOPTS-DISPLAYED_LINE.
  ENDIF.

  SUBTRACT 1 FROM P_TFILL.

ENDFORM.                                " DELETE_LINE
* Lädt SSCR mit evtl. Neugenerierung
FORM LOAD_SSCR TABLES   P_SSCR STRUCTURE RSSCR
               USING value(P_REPORT) LIKE RSVAR-REPORT
               CHANGING P_SUBRC  LIKE SY-SUBRC.

  DATA: L_MESSAGE_GEN(40), L_WORD(10), L_LINE TYPE I.

  LOAD REPORT P_REPORT PART 'SSCR' INTO P_SSCR.
  P_SUBRC = SY-SUBRC.
  IF P_SUBRC NE 0.
    GENERATE REPORT P_REPORT MESSAGE L_MESSAGE_GEN
                             LINE L_LINE WORD L_WORD.
    P_SUBRC = SY-SUBRC.
    IF P_SUBRC NE 0.
      SY-MSGV1 = L_MESSAGE_GEN.
    ELSE.
      LOAD REPORT P_REPORT PART 'SSCR' INTO P_SSCR.
      P_SUBRC = SY-SUBRC.
    ENDIF.
  ENDIF.

* Sortiert und entfernt Hexnull-Zeile
  PERFORM SHAPE_SSCR TABLES P_SSCR.

ENDFORM.                               " LOAD_SSCR
* Loescht Hexnullzeile aus SSCR und sortiert nach Nummer
* Löst Blockreferenzen auf
FORM SHAPE_SSCR TABLES P_SSCR STRUCTURE RSSCR.

  DATA L_HEX_NULL TYPE X.
  FIELD-SYMBOLS <L_F> TYPE X.

  SORT P_SSCR BY NUMB.
* HEXNULL-Zeile in SSCR
  ASSIGN P_SSCR(1) TO <L_F> TYPE 'X'.
  LOOP AT P_SSCR.
    IF P_SSCR-NUMB > 0.
      EXIT.
    ENDIF.
    IF <L_F> = L_HEX_NULL.
      DELETE P_SSCR.
    ENDIF.
  ENDLOOP.

  PERFORM RESOLVE_BLOCK_REFS(RSDBSPBL) TABLES P_SSCR.

ENDFORM.                                          " SHAPE_SSCR
* Loescht Hexnullzeile aus SSCR und sortiert nach Nummer
* Löst Referenzen nicht auf
FORM SHAPE_SSCR_SIMPLE TABLES P_SSCR STRUCTURE RSSCR.

  DATA L_HEX_NULL TYPE X.
  FIELD-SYMBOLS <L_F> TYPE X.

  SORT P_SSCR BY NUMB.
* HEXNULL-Zeile in SSCR
  ASSIGN P_SSCR(1) TO <L_F> TYPE 'X'.
  LOOP AT P_SSCR.
    IF P_SSCR-NUMB > 0.
      EXIT.
    ENDIF.
    IF <L_F> = L_HEX_NULL.
      DELETE P_SSCR.
    ENDIF.
  ENDLOOP.

ENDFORM.                                          " SHAPE_SSCR
*---------------------- %_SELECTED_FIELD --------------------------*
* Dynpro 1000: Name der selektierten SELECT-OPTION
*                   bzw. Parameter                 ==> PICKFIELD
* SUBRC: 0   alles O.K.
*        4   ausgewähltes Feld keine SELECT-OPTION / Parameter
*        12  interner Fehler: SELECT-OPTION / Parameter nicht in SSCR

FORM %_SELECTED_FIELD CHANGING P_FIELD LIKE RSSCR-NAME            "#EC *
                               P_NUMB  TYPE SYDB0_SSCR_NUMB
                               P_KIND LIKE RSSCR-KIND
                               SUBRC   LIKE SY-SUBRC.

  DATA: NAME(30).
  DATA: L_KIND.
  DATA L_SELNUM TYPE SYDB0_SELNUM.
  DATA L_SELOPTS TYPE SYDB0_SELOPTS.
  DATA L_PARAMS  TYPE SYDB0_PARAMS.

  FIELD-SYMBOLS <P>.

  CLEAR: P_FIELD, P_NUMB.
  SUBRC = 0.

  IF ( <SSCRFIELDS>-UCOMM(1) = '%' and not
      <SSCRFIELDS>-UCOMM(2) = '%_' )
      OR  <SSCRFIELDS>-UCOMM(1) = '&'.
    IF      CURRENT_SCR-MODE = 'J' AND
             NOT ( <SSCRFIELDS>-UCOMM+4(4) EQ CURRENT_SCREEN-DYNNR AND
                      <SSCRFIELDS>-UCOMM+8(10) EQ SCREEN_PROGS-HASH )
        OR
            CURRENT_SCR-MODE NE 'J' AND
                  NOT <SSCRFIELDS>-UCOMM+4(4) IS INITIAL.
      SUBRC = 4.
      EXIT.
    ENDIF.
    READ TABLE CURRENT_SCREEN-SELNUM WITH KEY <SSCRFIELDS>-UCOMM+1(3)
                   BINARY SEARCH INTO L_SELNUM.
    IF SY-SUBRC NE 0.
      SUBRC = 4.
      EXIT.
    ENDIF.
    READ TABLE CURRENT_SCREEN-SELOPTS INDEX L_SELNUM-SELTABIX
               INTO L_SELOPTS.
    IF SY-SUBRC NE 0.
      SUBRC = 12.
      EXIT.
    ENDIF.
    MOVE L_SELOPTS-NAME TO P_FIELD.
    MOVE L_SELNUM-NUMB TO P_NUMB.
    MOVE 'S'         TO P_KIND.
    EXIT.
  ENDIF.

  if <sscrfields>-ucomm = fdelline or <sscrfields>-ucomm = fdelall.
    name = context_struc-name.
    l_kind = 'S'.
  else.
    GET CURSOR FIELD NAME.
    IF NAME CP '*-LOW' OR NAME CP '*-HIGH'.
      ASSIGN NAME(SY-FDPOS) TO <P>.
      NAME = <P>.
      L_KIND = 'S'.
    ELSEIF NAME CP '*_%_APP_%-TEXT' OR NAME CP '*_%_APP_%-TO_TEXT'.
      IF NAME(2) = '%_'.
        ASSIGN NAME(SY-FDPOS) TO <P>.
        SHIFT <P> BY 2 PLACES.
        NAME = <P>.
      ELSE.
        SUBRC = 4.
        EXIT.
      ENDIF.
    ELSE.
      L_KIND = 'P'.
    ENDIF.
  endif.

  IF L_KIND NE 'P'.
    READ TABLE CURRENT_SCREEN-SELOPTS WITH KEY NAME(8) BINARY SEARCH
               INTO L_SELOPTS.
    IF SY-SUBRC NE 0.
      IF L_KIND = 'S'.
        SUBRC = 4.
        EXIT.
      ENDIF.
      READ TABLE CURRENT_SCREEN-PARAMS WITH KEY NAME(8) BINARY SEARCH
                 INTO L_PARAMS.
      IF SY-SUBRC NE 0.
        SUBRC = 4.
        EXIT.
      ENDIF.
      L_KIND = 'P'.
    ELSE.
      L_KIND = 'S'.
    ENDIF.
  ELSE.
    READ TABLE CURRENT_SCREEN-PARAMS WITH KEY NAME(8) BINARY SEARCH
         INTO L_PARAMS.
    IF SY-SUBRC NE 0.
      SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.
  IF L_SELOPTS-SSCR-KIND <> L_KIND.
    SUBRC = 4.
    EXIT.
  ENDIF.

  MOVE NAME TO P_FIELD.
  MOVE L_KIND TO P_KIND.
  IF L_KIND = 'S'.
    MOVE L_SELOPTS-NUMB TO P_NUMB.
  ELSE.
    MOVE L_PARAMS-NUMB TO P_NUMB.
  ENDIF.

ENDFORM.                               "%_SELECTED_FIELD
*
* Wird aus ablogdb.c per RSYEX gerufen (Noch vor dem INIT-Aufruf
* in SAPDBxyz). Stellt sicher, daß RSDBRUNT immer zur
* Hauptprogrammgruppe gehört.
FORM INIT_%_INIT.

  FIELD-SYMBOLS <L_F>.
  DATA L_SUBRC LIKE SY-SUBRC.
  DATA L_TABIX LIKE SY-TABIX.
  DATA L_SCR_NAME LIKE RSSCR-NAME VALUE '%_SC'.
  DATA L_HEAD LIKE RHEAD OCCURS 1 WITH HEADER LINE.
  DATA L_FLAG1 TYPE X.
  DATA L_FLAG.

  PHASE = 1.

  LAST_SSCR_PROG = SY-CPROG.

  PERFORM SHAPE_SSCR TABLES %_SSCR.

  PERFORM %_INIT-GET  IN PROGRAM (SY-CPROG) IF FOUND.

  PERFORM %_INIT_DYN_NODES IN PROGRAM (SY-CPROG) IF FOUND.

  PERFORM INIT_1_PROG USING    SY-CPROG SY-LDBPG 'S'
                      CHANGING L_SUBRC.

  if sy-subcs = 'A'.    " A: SUBMIT, B/T: CALL TRANSACTION
    clear g_transaction.
  endif.

  SYSTEM-CALL SUBMODE INTO SCREEN_PROGS-SUBMODE.
  ASSIGN SY-SLSET(1) TO <L_F> TYPE 'X'.
  IF <L_F> IS INITIAL.
    MOVE SPACE TO: SY-SLSET, %_RKEY-VARIANT.
  ENDIF.
  ASSIGN SCREEN_PROGS-SUBMODE(1) TO <L_F> TYPE 'X'.
  IF <L_F> IS INITIAL.
    MOVE SPACE TO: SCREEN_PROGS-SUBMODE.
  ENDIF.

  IF SCREEN_PROGS-SUBMODE CN '0123456789'.
    MOVE SCREEN_PROGS-SUBMODE TO SCREEN_PROGS-STATUS_SUBMODE.
  ENDIF.

  IF SCREEN_PROGS-SUBMODE = 'W3'.
    CLEAR SCREEN_PROGS-SUBMODE.
    WWW_SUBMIT = 'x'.
  ENDIF.

  IF SCREEN_PROGS-SUBMODE = 'VR' OR SCREEN_PROGS-SUBMODE = 'VS'.
    TRANSLATE SCREEN_PROGS-SUBMODE USING 'RCSU'.
    IMPORT TITLEBAR TO SCREEN_PROGS-TITLE
                            FROM MEMORY ID '%%RWTITLE%%'.
    SCREEN_PROGS-REPORT_WRITER = 'X'.
  ENDIF.

  IF SCREEN_PROGS-SUBMODE NE SPACE.
    MODIFY SCREEN_PROGS INDEX 1
      TRANSPORTING SUBMODE STATUS_SUBMODE REPORT_WRITER TITLE.
  ENDIF.

  LOOP AT %_SSCR WHERE KIND = 'S' AND
              FLAG1 O SSCR_F1_REDB AND DB NE 'X'.
                                     " AS DATABASE SELECTION ?
    SELOPTS_AS_DB_SEL = 'X'.
    EXIT.
  ENDLOOP.

  IF SCREEN_PROGS-SUBMODE(1) = 'V'.
* Variantenpflege
    IMPORT VARISCREENS FROM MEMORY ID '%_SCRNR_%'.
    L_SUBRC = SY-SUBRC.
    IF L_SUBRC = 0.
      READ TABLE VARISCREENS INDEX 1.
      L_SUBRC = SY-SUBRC.
      IF L_SUBRC = 0.
        IF VARISCREENS-DYNNR = '*'.
*       Für alle Selektionsbilder
          L_SUBRC = 1.
        ELSE.
*       nur für bestimmte Selektionsbilder
          IF VARISCREENS-DYNNR NE '1000'.
            READ TABLE VARISCREENS WITH KEY '1000'
                       TRANSPORTING NO FIELDS.
            L_TABIX = SY-TABIX.
            IF SY-SUBRC = 0.
              DELETE VARISCREENS INDEX L_TABIX.
              CLEAR VARISCREENS.
              VARISCREENS-DYNNR = '1000'.
              INSERT VARISCREENS INDEX 1.
            else.
              read table variscreens with key kind = space.
              l_tabix = sy-tabix.
              if sy-subrc eq 0.
                 DELETE VARISCREENS INDEX L_TABIX.
*                 CLEAR VARISCREENS.
                 INSERT VARISCREENS INDEX 1.
              else.
                read table variscreens with key kind = 'W'.
                l_tabix = sy-tabix.
                if sy-subrc eq 0.
                  DELETE VARISCREENS INDEX L_TABIX.
*                  CLEAR VARISCREENS.
                  INSERT VARISCREENS INDEX 1.
                endif.
              endif.
            ENDIF.
          ENDIF.
          SY-DYNNR = VARISCREENS-DYNNR.
          LOOP AT VARISCREENS FROM 2.
            APPEND VARISCREENS-DYNNR TO VSCREENS.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.
    IF L_SUBRC NE 0.
      REFRESH VARISCREENS.
      CLEAR VARISCREENS.
      LOAD REPORT SY-CPROG PART 'HEAD' INTO L_HEAD.
      READ TABLE L_HEAD INDEX 1 TRANSPORTING FLAG1.
      IF SY-SUBRC = 0.
        L_FLAG1 = L_HEAD-FLAG1.
* Dynpro 1000 ?
        IF L_FLAG1 O PGHD_F1_S1000.
          VARISCREENS-DYNNR = '1000'.
          APPEND VARISCREENS.
          L_FLAG = 'X'.
        ENDIF.
* Anderes Bild?
        IF L_FLAG1 O PGHD_F1_ADDSC.
          LOOP AT %_SSCR WHERE KIND = 'R' AND APPENDAGE = 'A'.
            case %_SSCR-MISCELL.
              when 'W' or 'J'.
                VARISCREENS-KIND = %_SSCR-MISCELL.
              when others.
                CLEAR VARISCREENS-KIND.
            ENDcase.
            IF L_FLAG = SPACE and variscreens-kind ne 'J'.
              L_FLAG = 'X'.
              clear variscreens-kind.
            endif.
            VARISCREENS-DYNNR = %_SSCR-NAME+4(*).
            APPEND VARISCREENS.
            IF SY-TABIX = 1.
              SY-DYNNR = VARISCREENS-DYNNR.
            ELSE.
              APPEND VARISCREENS-DYNNR TO VSCREENS.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.
    VSCR_INDEX = 1.
    DESCRIBE TABLE VARISCREENS LINES VSCR_TFILL.
    SORT VSCREENS BY DYNNR.
  ELSEIF SY-DYNNR = '0000' OR SY-DYNNR IS INITIAL.
    SY-DYNNR = '1000'.
  ELSEIF SY-DYNNR NE '1000'.      " SUBMIT ... USING SELECTION-SCREEN ..
    MOVE SY-DYNNR TO L_SCR_NAME+4.
    READ TABLE %_SSCR WITH KEY NAME      = L_SCR_NAME
                               KIND      = 'R'
                               APPENDAGE = 'A'.
    IF SY-SUBRC NE 0.
      MESSAGE A037 WITH SY-CPROG SY-DYNNR.
    ENDIF.
  ENDIF.


  SUBMIT_SCREEN = SY-DYNNR.

  IF SY-SUBTY Z SUBTY_NO_SELSCREEN.
    PERFORM PUSH_SCREEN USING SY-CPROG SY-LDBPG SY-DYNNR
                              <SSCRFIELDS>-UCOMM 'S'.
    NEW_CALL = 'S'.
    if sy-subty z CV_SUBTY_VIA_SELSCR.
      perform dark_submit(sapmssyd) using 1 if found.
    endif.
  ENDIF.

  CURR_LDB-LDBPG = SY-LDBPG.
  CURR_LDB-SUBMIT = 'X'.

  PERFORM PUSH_SP(RSDBSPMC) USING SY-LDBPG IF FOUND.

ENDFORM.                                " INIT_%_INIT
* Initialisierung fuer ein Programm.
* Lädt Texte der Kommentare aus Programm und Ldb.
* Aktuelle Information in der Kopfzeile
FORM INIT_1_PROG USING    VALUE(P_PROG)  LIKE SY-REPID
                          VALUE(P_LDBPG) LIKE SY-LDBPG
                          P_NEW_CALL
                 CHANGING P_SUBRC LIKE SY-SUBRC.

  DATA L_TABIX LIKE SY-TABIX.
  DATA L_SUBRC LIKE SY-SUBRC.
  DATA L_HEAD LIKE RHEAD OCCURS 0 WITH HEADER LINE.
  DATA L_FLAG1 TYPE X.

  READ TABLE SCREEN_PROGS WITH KEY P_PROG
       BINARY SEARCH.
  L_TABIX = SY-TABIX.
  P_SUBRC = SY-SUBRC.
* Programm noch nicht initialisiert
  IF SY-SUBRC = 0 AND LAST_SSCR_PROG NE P_PROG.
    %_SSCR[] = SCREEN_PROGS-SSCR[].
    LAST_SSCR_PROG = P_PROG.
  ENDIF.

  CHECK P_SUBRC NE 0.

  CLEAR SCREEN_PROGS.
  MOVE P_PROG  TO: SCREEN_PROGS-PROGRAM, SCREEN_PROGS-VARIPROG.
  MOVE P_LDBPG TO SCREEN_PROGS-LDBPG.

  IF LAST_SSCR_PROG NE P_PROG.
    PERFORM LOAD_SSCR TABLES   %_SSCR
                      USING    P_PROG
                      CHANGING L_SUBRC.
    IF L_SUBRC NE 0.
      MESSAGE A266 WITH p_prog.
    ENDIF.
    LAST_SSCR_PROG = P_PROG.
  ENDIF.
  SCREEN_PROGS-SSCR[] = %_SSCR[].

  READ TABLE VPROGS WITH KEY P_PROG BINARY SEARCH
             TRANSPORTING VARIPROG.
  IF SY-SUBRC = 0.
    SCREEN_PROGS-VARIPROG = VPROGS-VARIPROG.
  ENDIF.

  IF P_NEW_CALL NE 'S' OR SY-SUBTY Z SUBTY_NO_SELSCREEN.
    PERFORM %_INIT_SCR_TEXTS IN PROGRAM (P_PROG)
            CHANGING SCREEN_PROGS-TITLE IF FOUND.
    IF SCREEN_PROGS-TITLE = SPACE OR SCREEN_PROGS-TITLE = '?...'.
      SCREEN_PROGS-TITLE = P_PROG.
    ENDIF.
    PERFORM PROG_HAS_VARI
         USING SCREEN_PROGS-VARIPROG CHANGING SCREEN_PROGS-ANY_VARIANTS.
  ELSE.
    LOAD REPORT P_PROG PART 'HEAD' INTO L_HEAD.
    IF SY-SUBRC = 0.
      READ TABLE L_HEAD INDEX 1 TRANSPORTING FLAG1.
      IF SY-SUBRC = 0.
        L_FLAG1 = L_HEAD-FLAG1.
        IF L_FLAG1 O PGHD_F1_ADDSC OR L_FLAG1 O PGHD_F1_S1000.
          PERFORM PROG_HAS_VARI USING SCREEN_PROGS-VARIPROG
                                CHANGING SCREEN_PROGS-ANY_VARIANTS.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
  IF SCREEN_PROGS-SUBMODE EQ SPACE AND P_PROG EQ 'SAPLSVAR'
     AND SY-DYNNR EQ '0102'.
     SYSTEM-CALL SUBMODE INTO SCREEN_PROGS-SUBMODE.
     SCREEN_PROGS-STATUS_SUBMODE = SCREEN_PROGS-SUBMODE.
  ENDIF.
  INSERT SCREEN_PROGS INDEX L_TABIX.

  read table f3progs_old with key
       table_line = p_prog
       binary search
       transporting no fields.
  l_tabix = sy-tabix.
  if sy-subrc ne 0.
    PERFORM %_INIT-MOVE IN PROGRAM (P_PROG).   " ????
  endif.
  IF P_NEW_CALL EQ 'S' or flag_query_active eq 'A'.
    PERFORM INIT IN PROGRAM (SY-LDBPG) IF FOUND.
  ENDIF.

ENDFORM.                                   " INIT_1_PROG
* Setzt SCREEN_PROGS-VARIPROG im voraus. Soll später durch eine
* reguläre Lösung (FB oder Zusatz zu CALL SELECTION-SCREEN)
* ersetzt werden
FORM %_SET_VARIPROG USING    P_PROGRAM  LIKE SY-CPROG             "#EC *
                             P_VARIPROG LIKE SY-CPROG
                    CHANGING P_SUBRC LIKE SY-SUBRC.

  DATA L_TABIX LIKE SY-TABIX.

  READ TABLE SCREEN_PROGS WITH KEY P_PROGRAM BINARY SEARCH
             TRANSPORTING NO FIELDS.
  IF SY-SUBRC = 0.
    P_SUBRC = 1.
    EXIT.
  ENDIF.

  READ TABLE VPROGS WITH KEY P_PROGRAM BINARY SEARCH
             TRANSPORTING NO FIELDS.
  IF SY-SUBRC = 0.
    P_SUBRC = 2.
    EXIT.
  ENDIF.
  L_TABIX = SY-TABIX.
  MOVE: P_PROGRAM   TO VPROGS-PROGRAM,
        P_VARIPROG  TO VPROGS-VARIPROG.
  INSERT VPROGS INDEX L_TABIX.
  P_SUBRC = 0.

ENDFORM.                                       " %_SET_VARIPROG
* prüft, ob Programm überhaupt eine Variante hat.
FORM PROG_HAS_VARI USING    P_PROG LIKE SY-CPROG
                   CHANGING P_FLAG LIKE SCREEN_PROGS-ANY_VARIANTS.

  CLEAR P_FLAG.
  DATA: L_MANDT LIKE SY-MANDT VALUE '000'.
  SELECT REPORT INTO VARID-REPORT FROM VARID
                           UP TO 1 ROWS
                           WHERE REPORT     = P_PROG
                           AND   ENVIRONMNT = 'A'
                           AND   TRANSPORT NE 'N'
                           AND   TRANSPORT NE 'X'.
    P_FLAG = 'X'.
  ENDSELECT.
  CHECK P_FLAG EQ SPACE.
  SELECT REPORT INTO VARID-REPORT FROM VARID CLIENT SPECIFIED
                           UP TO 1 ROWS
                           WHERE MANDT = L_MANDT
                           AND  REPORT     = P_PROG
                           AND ( VARIANT LIKE 'CUS&%' OR
                                 VARIANT LIKE 'SAP&%' )
                           AND   ENVIRONMNT = 'A'
                           AND   TRANSPORT NE 'N'
                           AND   TRANSPORT NE 'X'.
  P_FLAG = 'X'.
  ENDSELECT.

ENDFORM.
* Programmname umswitchen für Varianten
FORM FILL_VPROGS USING P_PROG LIKE SY-REPID P_VARIPROG LIKE SY-REPID
                       P_SUBRC LIKE SY-SUBRC.
  DATA L_TABIX LIKE SY-TABIX.

  READ TABLE VPROGS WITH KEY PROGRAM = P_PROG
                             VARIPROG = P_VARIPROG BINARY SEARCH.
  L_TABIX = SY-TABIX.
  IF SY-SUBRC EQ 0.
     P_SUBRC = 4.
     EXIT.
  ELSE.
    MOVE: P_PROG      TO VPROGS-PROGRAM,
          P_VARIPROG  TO VPROGS-VARIPROG.
    INSERT VPROGS INDEX L_TABIX.
    CURR_VSCR-PROGRAM = P_VARIPROG.
  ENDIF.
  READ TABLE SCREEN_PROGS WITH KEY PROGRAM = P_PROG BINARY SEARCH
       TRANSPORTING NO FIELDS.
  CHECK SY-SUBRC = 0.
  L_TABIX = SY-TABIX.
*  SCREEN_PROGS-ANY_VARIANTS = 'X'.
  SCREEN_PROGS-ANY_VARIANTS = CURRENT_SCREEN-ANY_VARIANTS = 'X'.
  SCREEN_PROGS-VARIPROG = P_VARIPROG.
  MODIFY SCREEN_PROGS INDEX L_TABIX TRANSPORTING VARIPROG ANY_VARIANTS.

ENDFORM.
* Externer Aufruf: für irgendein Programm wird neue Variante geladen.
* Voraussetzung: das Programm selbst muß bereits geladen sein. ??
FORM NEW_VARI_EXT TABLES P_VARI STRUCTURE RVARI
                         P_VARIVDAT STRUCTURE RSVARIVDAT
                         P_VARIDYN  STRUCTURE RSVARIDYN
                         P_VDATDYN  STRUCTURE RSVDATDYN
                  USING  P_PROG LIKE SY-CPROG
                         P_VARIANT LIKE SY-SLSET.

  DATA L_SUBRC LIKE SY-SUBRC.
  DATA L_SUBRC_2 LIKE SY-SUBRC.
  DATA L_SCREEN_PROGS LIKE SCREEN_PROGS.
  DATA L_LDB LIKE TRDIR-LDBNAME.
  DATA L_LDBPG LIKE SY-LDBPG.

  READ TABLE SCREEN_PROGS WITH KEY P_PROG BINARY SEARCH
             INTO L_SCREEN_PROGS.
  L_SUBRC = SY-SUBRC.
  IF SY-SUBRC NE 0.
    SELECT SINGLE LDBNAME INTO L_LDB FROM TRDIR WHERE NAME = P_PROG.
    IF L_LDB NE SPACE AND L_LDB NE 'D$S' AND L_LDB NE '$$S'
       AND L_LDB NE '__S'.
      CALL FUNCTION 'LDB_CONVERT_LDBNAME_2_DBPROG'
           EXPORTING
                LDB_NAME                  = L_LDB
                FLAG_EXISTENCE_CHECK      = SPACE
           IMPORTING
                DB_NAME                   = L_LDBPG
           EXCEPTIONS
                OTHERS                    = 1.
    ENDIF.
    PERFORM INIT_1_PROG USING    P_PROG L_LDBPG SPACE
                        CHANGING L_SUBRC_2.
  ENDIF.

  PERFORM NEW_VARI(RSDBSPVA) USING    P_PROG
                                      P_VARIANT
                                      P_VARI[]
                                      P_VARIVDAT[]
                                      P_VARIDYN[]
                                      P_VDATDYN[]
                             CHANGING SCREENS
                                      CURRENT_SCREEN
                                      SCR_STACK
                                      CURRENT_SCR.

ENDFORM.                                  " NEW_VARI_EXT
* tu so als ob Variantenpflege waere
form set_submode using p_submode like screen_progs-submode
                       p_report  type syrepid.
  data l_tabix type sytabix.
  data l_submode like screen_progs-submode.
  read table screen_progs with key p_report binary search
                            transporting no fields.
  check sy-subrc = 0.
  l_tabix = sy-tabix.
  L_SUBMODE = screen_progs-submode.
  screen_progs-submode = p_submode.
  modify screen_progs index l_tabix transporting submode.
  if screen_progs-program ne p_report.
    screen_progs-submode = l_submode.
  endif.
endform.
* Setzt <SSCRFIELDS> und <SSCRTEXTS>
FORM TAKE_SSCR_WAS USING P_SSCRFIELDS LIKE SSCRFIELDS
                         P_SSCRTEXTS  LIKE SSCRTEXTS.
  ASSIGN P_SSCRFIELDS TO <SSCRFIELDS>.
  ASSIGN P_SSCRTEXTS  TO <SSCRTEXTS>.
ENDFORM.                                    " TAKE_SSCR_WAS
* Initialisierung fuer ein Bild. Stellt CURRENT_SCREEN-Tabellen her.
* Wird bei SUBMIT aus INIT_INIT gerufen,
* sonst einmal pro Bild.
* Ob der Aufruf erfolgen soll oder nicht, muss der Aufrufer
* entscheiden
FORM INIT_1_SCREEN USING VALUE(P_PROG)  LIKE SY-REPID
                         VALUE(P_DYNNR) LIKE SY-DYNNR
                         VALUE(P_LDBPG) LIKE SY-LDBPG
                         P_NEW_CALL     LIKE NEW_CALL.

  FIELD-SYMBOLS: <L_F>,
                 <L_TEXT>,
                 <l_dynref> type sydb0_dynref.

  DATA L_HEX_NULL TYPE X.
  DATA L_SUBRC LIKE SY-SUBRC.
  DATA L_TABIX LIKE SY-TABIX.
  DATA L_FIRST_TABIX LIKE SY-TABIX.
  DATA L_FIRST LIKE SY-TABIX.
  DATA L_LAST  LIKE SY-TABIX.
  DATA L_FNAME(200).
  DATA L_PROGS_TABIX LIKE SY-TABIX.
  DATA L_SSCR        LIKE RSSCR.
  DATA L_TEXTS       LIKE RSSELTEXTS.
  DATA: L_NAME TYPE SYDB0_TABBLOCK.
  DATA: BEGIN OF L_FORMNAME_0,
          PREFIX(7) VALUE '%_LINK_',
          SUFFIX LIKE RSSCR-NAME,
        END OF L_FORMNAME_0.
  DATA: L_UPD_TITLE.
  DATA: L_FCODE_NAME TYPE SYDB0_TABS.
  DATA: L_FLAG_FIRST.
  data l_dynnr(4) type n.
  data l_flag_dynsub.
  data l_modtext type sydb0_modtext.
  data l_modtext_tab type sydb0_modtext occurs 0 .

  CLEAR CURRENT_SCREEN.
  CURRENT_SCREEN-PROGRAM = P_PROG.
  CURRENT_SCREEN-DYNNR   = P_DYNNR.
  L_FIRST = P_DYNNR * 1000.
  L_LAST  = L_FIRST + 999.

  IF SCREEN_PROGS-PROGRAM NE P_PROG.
    READ TABLE SCREEN_PROGS WITH KEY P_PROG BINARY SEARCH.
  ELSE.
    READ TABLE SCREEN_PROGS WITH KEY P_PROG BINARY SEARCH
         TRANSPORTING NO FIELDS.
  ENDIF.
  L_PROGS_TABIX = SY-TABIX.

  LOOP AT %_SSCR
          WHERE NUMB GE L_FIRST
          AND   FLAG1 Z SSCR_F1_NODI.
    L_TABIX = SY-TABIX.
    IF %_SSCR-NUMB > L_LAST.
      EXIT.
    ENDIF.
    IF L_FIRST_TABIX = 0.
      L_FIRST_TABIX = L_TABIX.
    ENDIF.
    CASE %_SSCR-KIND.
      WHEN 'S'.
        CLEAR G_SELOPTS.
        MOVE L_TABIX     TO G_SELOPTS-SSCRIX.
        MOVE %_SSCR-NAME TO G_SELOPTS-NAME.
        G_SELOPTS-NUMB = %_SSCR-NUMB MOD 1000.
        READ TABLE SCREEN_PROGS-DYNREF WITH KEY %_SSCR-NAME BINARY
            SEARCH ASSIGNING <L_DYNREF>.
        IF SY-SUBRC = 0.
          G_SELOPTS-TEXT = <L_DYNREF>-SELTEXT.
        ELSE.
          READ TABLE SCREEN_PROGS-TEXTS WITH KEY %_SSCR-NAME
               INTO L_TEXTS
               BINARY SEARCH TRANSPORTING TEXT.
          IF SY-SUBRC = 0.
            G_SELOPTS-TEXT = L_TEXTS-TEXT.
            L_SUBRC = 0.
          ELSE.
            IF %_SSCR-DB NE 'X'.
              ASSIGN P_PROG TO <L_F>.
            ELSE.
              ASSIGN P_LDBPG TO <L_F>.
            ENDIF.
           PERFORM GET_SEL_TEXT USING    'S' G_SELOPTS-NAME <L_F> %_SSCR
                                 CHANGING G_SELOPTS-TEXT L_SUBRC.
          ENDIF.
        ENDIF.
        MOVE %_SSCR      TO G_SELOPTS-SSCR.
        IF %_SSCR-SPAGPA NE SPACE.
          SELECT SINGLE * FROM TUVID
                          WHERE PARAMID = %_SSCR-SPAGPA.
          IF SY-SUBRC = 0.
            MOVE 'X' TO: G_SELOPTS-VUV, CURRENT_SCREEN-ANY_VUVS.
          ENDIF.
        ENDIF.
        MOVE G_SELOPTS-NAME TO L_FORMNAME_0-SUFFIX.
        PERFORM (L_FORMNAME_0) IN PROGRAM (P_PROG)
                 USING 'RSDBRUNT' 'FILL_RSSELINT' L_SUBRC IF FOUND.
        APPEND G_SELOPTS TO CURRENT_SCREEN-SELOPTS.
      WHEN 'P'.
        CLEAR G_PARAMS.
        MOVE %_SSCR-NAME   TO G_PARAMS-NAME.
        G_PARAMS-NUMB = %_SSCR-NUMB MOD 1000.
        READ TABLE SCREEN_PROGS-DYNREF WITH KEY %_SSCR-NAME BINARY
          SEARCH ASSIGNING <L_DYNREF>.
        IF SY-SUBRC = 0.
          G_PARAMS-TEXT = <L_DYNREF>-SELTEXT.
        ELSE.
          READ TABLE SCREEN_PROGS-TEXTS WITH KEY %_SSCR-NAME
               INTO L_TEXTS
               BINARY SEARCH TRANSPORTING TEXT.
          IF SY-SUBRC = 0.
            G_PARAMS-TEXT = L_TEXTS-TEXT.
            L_SUBRC = 0.
          ELSEIF G_PARAMS-SSCR-FLAG1 Z SSCR_F1_IXST.
            IF %_SSCR-DB NE 'X'.
              ASSIGN P_PROG TO <L_F>.
            ELSE.
              ASSIGN P_LDBPG TO <L_F>.
            ENDIF.
            PERFORM GET_SEL_TEXT USING    'S' G_PARAMS-NAME <L_F> %_SSCR
                                 CHANGING G_PARAMS-TEXT L_SUBRC.
          ENDIF.
        ENDIF.
        MOVE %_SSCR        TO G_PARAMS-SSCR.
        IF %_SSCR-SPAGPA NE SPACE.
          SELECT SINGLE * FROM TUVID
                          WHERE PARAMID = %_SSCR-SPAGPA.
          IF SY-SUBRC = 0.
            MOVE 'X' TO: G_PARAMS-VUV, CURRENT_SCREEN-ANY_VUVS.
          ENDIF.
        ENDIF.
        IF G_PARAMS-SSCR-FLAG1 Z SSCR_F1_IXST.
          MOVE G_PARAMS-NAME TO L_FORMNAME_0-SUFFIX.
          PERFORM (L_FORMNAME_0) IN PROGRAM (P_PROG)
                   USING 'RSDBRUNT' 'FILL_PARAM_TEXT' L_SUBRC IF FOUND.
        ELSE.
          PERFORM %_IX_TEXTS(RSDBSPMC) USING    G_PARAMS-NAME   "#EC *
                                       CHANGING <SSCRTEXTS>.
        ENDIF.
        APPEND G_PARAMS TO CURRENT_SCREEN-PARAMS.
      WHEN 'F'.                    " COMMENT FOR FIELD
        l_modtext-index = l_tabix.
        CHECK %_SSCR-NAME+2(3) = '%_S'.
        READ TABLE %_SSCR INTO L_SSCR
                      WITH KEY NAME = %_SSCR-MISCELL
                      TRANSPORTING kind DB DBFIELD.
        l_modtext-name = %_sscr-miscell.
        IF L_SSCR-DB NE 'X'.
          ASSIGN P_PROG TO <L_F>.
        ELSE.
          ASSIGN P_LDBPG TO <L_F>.
        ENDIF.
        IF %_SSCR-LENGTH < 1000.
          L_DYNNR = p_dynnr.
        ELSE.
          L_dynnr = %_SSCR-LENGTH DIV 1000.
        ENDIF.
        CONCATENATE '(' P_PROG ')' %_SSCR-NAME '_' l_DYNNR INTO L_FNAME.
        ASSIGN (L_FNAME) TO <L_TEXT>.
        CHECK SY-SUBRC = 0.
        READ TABLE SCREEN_PROGS-TEXTS WITH KEY NAME = %_SSCR-MISCELL
             INTO L_TEXTS
             BINARY SEARCH TRANSPORTING TEXT.
        IF SY-SUBRC = 0.
          <L_TEXT> = L_TEXTS-TEXT.
          L_SUBRC = 0.
        ELSE.
          L_SSCR-NAME = %_SSCR-MISCELL.
          PERFORM GET_SEL_TEXT USING    'S' L_SSCR-NAME <L_F> L_SSCR
                               CHANGING <L_TEXT> L_SUBRC.
        ENDIF.
        l_modtext-text = <l_text>.
        append l_modtext to l_modtext_tab.
      WHEN 'R'.                    " BEGIN/END OF SCREEN
        CHECK %_SSCR-APPENDAGE = 'A' AND %_SSCR-DBFIELD NE SPACE.
        IF %_SSCR-DBFIELD(5) = 'TEXT-'.
          CURRENT_SCREEN-TITLETYPE = 'T'.
          IF %_SSCR-DB NE 'X'.
            ASSIGN P_PROG TO <L_F>.
          ELSE.
            ASSIGN P_LDBPG TO <L_F>.
          ENDIF.
          PERFORM GET_SEL_TEXT USING    'I' %_SSCR-DBFIELD+5(3) <L_F>
                                        %_SSCR
                               CHANGING CURRENT_SCREEN-TITLE L_SUBRC.
          IF SY-SUBRC NE 0.
            CURRENT_SCREEN-TITLE = %_SSCR-DBFIELD.
          ENDIF.
        ELSE.
          CURRENT_SCREEN-TITLETYPE = 'F'.
        ENDIF.
      WHEN 'K'.
        CHECK %_SSCR-NAME(5) EQ '%B%_T'.
        CASE %_SSCR-APPENDAGE.
          WHEN 'A'.
            L_FLAG_FIRST = 'X'.
            L_FCODE_NAME-NAME = %_SSCR-DBFIELD.
            L_NAME-NAME = %_SSCR-DBFIELD.
            APPEND L_NAME TO CURRENT_SCREEN-TABBLOCKS.
          WHEN 'E'.
            CLEAR: L_FCODE_NAME-NAME, L_FLAG_FIRST.
       ENDCASE.
      WHEN 'H'.
        CHECK NOT L_FCODE_NAME-NAME IS INITIAL AND
             %_SSCR-MISCELL EQ 'T'.
        L_FCODE_NAME-FCODE = %_SSCR-MATCHCODE.
        UNPACK %_SSCR-LENGTH TO L_FCODE_NAME-DYNNR.
        IF NOT %_SSCR-DBFIELD IS INITIAL.
          L_FCODE_NAME-PROGRAM = %_SSCR-DBFIELD.
        ELSE.
          MOVE P_PROG TO L_FCODE_NAME-PROGRAM.
        ENDIF.
        APPEND L_FCODE_NAME TO CURRENT_SCREEN-TABS.
        IF NOT L_FLAG_FIRST IS INITIAL AND NOT %_SSCR-LENGTH IS INITIAL.
          PERFORM FILL_TABINFO USING L_FCODE_NAME-PROGRAM
                                     L_FCODE_NAME-NAME
                                     %_SSCR-MATCHCODE
                                     L_FCODE_NAME-DYNNR.
        ENDIF.
        CLEAR L_FLAG_FIRST.
    ENDCASE.
  ENDLOOP.
  SORT CURRENT_SCREEN-TABBLOCKS.
  SORT CURRENT_SCREEN-TABS BY FCODE.
  sort l_modtext_tab by name.
  current_screen-modtext[] = l_modtext_tab[].
*  modify screen_progs index l_progs_tabix transporting modtext.
  IF SCREEN_PROGS-TITLE = SPACE.
    PERFORM %_INIT_SCR_TEXTS IN PROGRAM (P_PROG)
              CHANGING SCREEN_PROGS-TITLE IF FOUND.
    IF SCREEN_PROGS-TITLE = SPACE OR SCREEN_PROGS-TITLE = '?...'.
      SCREEN_PROGS-TITLE = P_PROG.
    ENDIF.
    L_UPD_TITLE = 'X'.
  ENDIF.
  IF NOT L_UPD_TITLE IS INITIAL.
    MODIFY SCREEN_PROGS INDEX L_PROGS_TABIX TRANSPORTING TITLE.
  ENDIF.
  IF P_NEW_CALL = 'J'.
     CURRENT_SCREEN-TYPE = 'J'.
     if  current_screen-program = 'SAPLSSEL' and
* Auf Subscreen von SSEL,
    ( DYNS-TABS ne SPACE OR SCREEN_PROGS-LDBPG ne  SPACE )
*    freie Abgrenzungen aktiv oder logische Datenbank im Spiel
    and flag_query_active eq space.
*   aber nicht query.
     CURRENT_SCREEN-TYPE = 'J'.
    perform set_flag_for_rsdbrunt in program saplssel
                   using current_screen-dyns_sub
                         current_screen-program.
    endif.
  ENDIF.
  IF CURRENT_SCREEN-TITLETYPE = SPACE.
    CURRENT_SCREEN-TITLE = SCREEN_PROGS-TITLE.
  ENDIF.
  READ TABLE NOINTS WITH KEY PROGRAM = P_PROG BINARY SEARCH
             TRANSPORTING SELOPTS.
  IF SY-SUBRC EQ 0.
     PERFORM SCREEN_NOINT_CHECK USING    NOINTS-SELOPTS
                                CHANGING CURRENT_SCREEN.
  ENDIF.

  SORT CURRENT_SCREEN-PARAMS  BY NAME.
  SORT CURRENT_SCREEN-SELOPTS BY NAME.
  PERFORM FILL_SELNUM USING    CURRENT_SCREEN-SELOPTS
                      CHANGING CURRENT_SCREEN-SELNUM.
  PERFORM FILL_BLOCKS(RSDBSPBL) TABLES    %_SSCR
                                USING     L_FIRST_TABIX
                                CHANGING  CURRENT_SCREEN-BLOCKS
                                          CURRENT_SCREEN-FUNC_KEYS.
* Versorge Tabelle SELECT_FIELDS für Feldselektion
  IF P_NEW_CALL = 'S'.
    PERFORM %_INIT_FSEL IN PROGRAM (P_PROG) IF FOUND.
  ENDIF.

* baue INACTIVE + INVISIBLE auf
  IF CURR_VSCR-VARIANT NE SPACE.
    PERFORM FILL_INACTIVE_INVISIBLE(RSDBSPVA)
                              USING    CURR_VSCR-VARI
                                       SCREEN_PROGS-SUBMODE
                              CHANGING CURRENT_SCREEN.
    CURRENT_SCREEN-ANY_VARIANTS = 'X'.
  ELSEIF SCREEN_PROGS-ANY_VARIANTS NE SPACE AND ( SY-BATCH IS INITIAL OR SY-BINPT IS NOT INITIAL )
                                                AND CURRENT_SCREEN-ANY_VARIANTS IS INITIAL.
    CALL FUNCTION 'RS_VARIANT_FOR_ONE_SCREEN'
         EXPORTING
              PROGRAM        = SCREEN_PROGS-VARIPROG
              DYNNR          = P_DYNNR
         IMPORTING
              VARIANT_EXISTS = CURRENT_SCREEN-ANY_VARIANTS
         EXCEPTIONS
              OTHERS         = 1.
  ENDIF.

ENDFORM.                                " INIT_1_SCREEN
*Fülle SCREEN_PROGS-dynref, besorge Texte
FORM CREATE_DYNREF USING P_NAME LIKE RSSCR-NAME
                         P_KIND LIKE RSSCR-KIND.

 DATA: L_FLAG_FIRSTTIME VALUE 'X',
       L_UPD_DYNREF,
       L_TEXTS LIKE RSSELTEXTS,
       L_SUBRC LIKE SY-SUBRC,
       L_DBFIELD LIKE RSSCR-DBFIELD,
       L_DYNNR(4) type n,
       L_TABIX LIKE SY-TABIX.
 DATA: BEGIN OF L_FORMNAME_0,
         PREFIX(7) VALUE '%_LINK_',
         SUFFIX LIKE RSSCR-NAME,
       END OF L_FORMNAME_0.
 DATA: L_FLAG_DDIC.

 DATA: BEGIN OF L_TEXT_TAB OCCURS 0,
         LINE(200).
 DATA: END   OF L_TEXT_TAB.

 FIELD-SYMBOLS: <L_F> LIKE SY-REPID,
                <L_SELOPTS> TYPE SYDB0_SELOPTS,
                <L_COMMENT>,
                <L_PARAMS> TYPE SYDB0_PARAMS.

 LOOP AT %_SSCR WHERE ( NAME = P_NAME AND KIND = P_KIND ) OR
         ( KIND = 'F' AND MISCELL = P_NAME ).
   CASE %_SSCR-KIND.
   WHEN 'S'.
      IF L_FLAG_FIRSTTIME EQ 'X'.
        CLEAR L_FLAG_FIRSTTIME.
        READ TABLE SCREEN_PROGS-TEXTS WITH KEY %_SSCR-NAME
             INTO L_TEXTS
             BINARY SEARCH TRANSPORTING TEXT.
        IF SY-SUBRC = 0.
          G_SELOPTS-TEXT = L_TEXTS-TEXT.
          L_SUBRC = 0.
        ELSE.
          IF %_SSCR-DB NE 'X'.
            ASSIGN CURRENT_SCREEN-PROGRAM TO <L_F>.
          ELSE.
            ASSIGN SCREEN_PROGS-LDBPG TO <L_F>.
          ENDIF.
          PERFORM GET_SEL_TEXT USING    'S' %_SSCR-NAME <L_F> %_SSCR
                               CHANGING G_SELOPTS-TEXT L_SUBRC.
        ENDIF.
        IF L_SUBRC NE 0 .
          PERFORM GET_REFFIELD
                  USING %_SSCR L_UPD_DYNREF L_TEXTS-TEXT SPACE.
        ELSE.
          PERFORM GET_REFFIELD
                  USING %_SSCR L_UPD_DYNREF G_SELOPTS-TEXT 'X'.
        ENDIF.
        MODIFY %_SSCR.
        L_DBFIELD = %_SSCR-DBFIELD.
        IF L_SUBRC NE 0 AND NOT L_TEXTS-TEXT IS INITIAL.
          L_FLAG_DDIC = 'X'.
          CLEAR G_SELOPTS.
          G_SELOPTS-TEXT = L_TEXTS-TEXT.
          MOVE %_SSCR-NAME TO: G_SELOPTS-NAME, L_FORMNAME_0-SUFFIX.
          PERFORM (L_FORMNAME_0) IN PROGRAM (CURRENT_SCREEN-PROGRAM)
                  USING 'RSDBRUNT' 'FILL_RSSELINT' L_SUBRC IF FOUND.
       ELSE.
          L_TEXTS-TEXT = G_SELOPTS-TEXT.
       ENDIF.
      ELSE.
        %_SSCR-DBFIELD = L_DBFIELD.
        MODIFY %_SSCR.
      ENDIF.
      L_DYNNR = %_SSCR-NUMB DIV 1000.
      CHECK L_DYNNR = CURRENT_SCREEN-DYNNR.
      READ TABLE CURRENT_SCREEN-SELOPTS
                WITH KEY NAME = P_NAME BINARY SEARCH
                ASSIGNING <L_SELOPTS>.
      CHECK SY-SUBRC = 0.
      <L_SELOPTS>-SSCR = %_SSCR.
      IF L_FLAG_DDIC = 'X'.
         <L_SELOPTS>-TEXT = L_TEXTS-TEXT.
      ENDIF.
     WHEN 'P'.
      IF L_FLAG_FIRSTTIME EQ 'X'.
        CLEAR L_FLAG_FIRSTTIME.
        READ TABLE SCREEN_PROGS-TEXTS WITH KEY %_SSCR-NAME
             INTO L_TEXTS
             BINARY SEARCH TRANSPORTING TEXT.
        IF SY-SUBRC = 0.
          G_PARAMS-TEXT = L_TEXTS-TEXT.
          L_SUBRC = 0.
        ELSE.
          IF %_SSCR-DB NE 'X'.
            ASSIGN CURRENT_SCREEN-PROGRAM TO <L_F>.
          ELSE.
            ASSIGN SCREEN_PROGS-LDBPG TO <L_F>.
          ENDIF.
          PERFORM GET_SEL_TEXT USING    'S' %_SSCR-NAME <L_F> %_SSCR
                               CHANGING G_PARAMS-TEXT L_SUBRC.
        ENDIF.
        IF L_SUBRC NE 0.
          PERFORM GET_REFFIELD
                  USING %_SSCR L_UPD_DYNREF L_TEXTS-TEXT SPACE.
        ELSE.
          PERFORM GET_REFFIELD
                  USING %_SSCR L_UPD_DYNREF G_PARAMS-TEXT 'X'.
        ENDIF.
        MODIFY %_SSCR.
        L_DBFIELD = %_SSCR-DBFIELD.
        IF L_SUBRC NE 0 AND NOT L_TEXTS-TEXT IS INITIAL.
          L_FLAG_DDIC = 'X'.
          CLEAR G_PARAMS.
          G_PARAMS-TEXT = L_TEXTS-TEXT.
          MOVE %_SSCR-NAME TO: G_PARAMS-NAME, L_FORMNAME_0-SUFFIX.
          PERFORM (L_FORMNAME_0) IN PROGRAM (CURRENT_SCREEN-PROGRAM)
              USING 'RSDBRUNT' 'FILL_PARAM_TEXT' L_SUBRC IF FOUND.
         ELSE.
          L_TEXTS-TEXT = G_PARAMS-TEXT.
        ENDIF.
      ELSE.
        %_SSCR-DBFIELD = L_DBFIELD.
        MODIFY %_SSCR.
      ENDIF.
      L_DYNNR = %_SSCR-NUMB DIV 1000.
      CHECK L_DYNNR = CURRENT_SCREEN-DYNNR.
      READ TABLE CURRENT_SCREEN-PARAMS
                WITH KEY NAME = P_NAME BINARY SEARCH
                    ASSIGNING <L_PARAMS>.
      CHECK SY-SUBRC = 0.
      <L_PARAMS>-SSCR = %_SSCR.
      IF L_FLAG_DDIC = 'X'.
          <L_PARAMS>-TEXT = L_TEXTS-TEXT.
       ENDIF.
   WHEN 'F'.
     CHECK %_SSCR-NAME+2(3) = '%_S'.
     CLEAR L_TEXT_TAB.
     IF %_SSCR-LENGTH < 1000.
       L_DYNNR = %_SSCR-NUMB DIV 1000.
     ELSE.
       L_dynnr = %_SSCR-LENGTH DIV 1000.
     ENDIF.
     CONCATENATE '(' CURRENT_SCREEN-PROGRAM ')' %_SSCR-NAME '_' L_DYNNR
         INTO L_TEXT_TAB-LINE.
     APPEND L_TEXT_TAB.
   ENDCASE.
 ENDLOOP.

 READ TABLE SCREEN_PROGS WITH KEY PROGRAM = SCREEN_PROGS-PROGRAM
      BINARY SEARCH TRANSPORTING NO FIELDS.
 L_TABIX = SY-TABIX.
 IF SY-SUBRC EQ 0.
   SCREEN_PROGS-SSCR = %_SSCR[].
   MODIFY SCREEN_PROGS INDEX L_TABIX TRANSPORTING SSCR.
 ENDIF.
 LOOP AT L_TEXT_TAB.
   ASSIGN (L_TEXT_TAB-LINE) TO <L_COMMENT>.
   CHECK SY-SUBRC EQ 0.
   MOVE L_TEXTS-TEXT TO <L_COMMENT>.
 ENDLOOP.
ENDFORM.
* Besorgt DDIC-Referenzfeld
FORM GET_REFFIELD USING P_SSCR LIKE RSSCR
                        P_NEW  TYPE C
                        P_TEXT TYPE C
                        P_TEXT_INSERT.      " Nimm übergebenen Text

  DATA: L_DYNTABIX LIKE SY-TABIX,
        L_TABIX LIKE SY-TABIX,
        L_FIELDNAME(200),
        L_DYNREF    TYPE SYDB0_DYNREF,
        L_SUBRC LIKE SY-SUBRC,
        l_situation.
  FIELD-SYMBOLS: <L_F>.

  READ TABLE SCREEN_PROGS-DYNREF INTO L_DYNREF
       WITH KEY NAME = P_SSCR-NAME BINARY SEARCH
       TRANSPORTING fieldname REFFIELD SELTEXT.
  L_DYNTABIX = SY-TABIX.
  IF SY-SUBRC NE 0 or l_dynref-reffield = 'RSDSINTERN-SELOPT'
                   or l_dynref-reffield = 'RSDYNPAR-PARAM'
                   or flag_query_active eq 'A'.

    if sy-subrc ne 0 .
      l_situation = 'N'.
      l_dynref-fieldname = p_sscr-dbfield.
    elseif l_dynref-reffield = 'RSDSINTERN-SELOPT' or
           l_dynref-reffield = 'RSDYNPAR-PARAM'.
      l_situation = 'O'.
    else.
      l_situation = 'C'.
    endif.
    P_NEW = 'X'.
    IF P_SSCR-DB EQ SPACE.
      CONCATENATE '(' SCREEN_PROGS-PROGRAM ')' l_dynref-fieldname
          INTO L_FIELDNAME.
    ELSE.
      CONCATENATE '(' SCREEN_PROGS-LDBPG ')' l_dynref-fieldname
          INTO L_FIELDNAME.
    ENDIF.
    ASSIGN (L_FIELDNAME) TO <L_F>.
    IF SY-SUBRC NE 0.
      IF P_SSCR-KIND = 'S'.
        P_SSCR-DBFIELD = 'RSDSINTERN-SELOPT'.
      ELSE.
        P_SSCR-DBFIELD = 'RSDYNPAR-PARAM'.
      ENDIF.
    ELSE.
      P_SSCR-DBFIELD = <L_F>.
      IF P_SSCR-DBFIELD(3) = 'SY-'.
        SHIFT P_SSCR-DBFIELD RIGHT BY 2 PLACES.
        P_SSCR-DBFIELD(4) = 'SYST'.
      ENDIF.
    ENDIF.
    L_DYNREF-KIND = P_SSCR-KIND.
    PERFORM GET_REF_PROPERTIES(RSDBSPDD) CHANGING P_SSCR
                                                  L_DYNREF-CONVERT
                                                  L_DYNREF-CURR_REF
                                                  L_DYNREF-F4
                                                  L_DYNREF-SELTEXT
                                                  L_SUBRC.
    IF L_SUBRC NE 0.
      IF P_SSCR-KIND = 'S'.
        P_SSCR-DBFIELD = 'RSDSINTERN-SELOPT'.
      ELSE.
        P_SSCR-DBFIELD = 'RSDYNPAR-PARAM'.
      ENDIF.
      PERFORM GET_REF_PROPERTIES(RSDBSPDD) CHANGING P_SSCR
                                                  L_DYNREF-CONVERT
                                                  L_DYNREF-CURR_REF
                                                  L_DYNREF-F4
                                                  L_DYNREF-SELTEXT
                                                  L_SUBRC.
    ELSE.
       MOVE-CORRESPONDING L_DYNREF-CONVERT TO P_SSCR.
       P_SSCR-DTYP = L_DYNREF-CONVERT-DYNPTYPE.
    ENDIF.
    L_DYNREF-NAME = P_SSCR-NAME.
    L_DYNREF-REFFIELD = P_SSCR-DBFIELD.
    IF P_TEXT_INSERT IS INITIAL.
      P_TEXT = L_DYNREF-SELTEXT.
    ELSE.
      L_DYNREF-SELTEXT = P_TEXT.
    ENDIF.
    if l_situation = 'N'.
      insert l_dynref into SCREEN_PROGS-DYNREF index l_dyntabix.
    else.
      modify SCREEN_PROGS-DYNREF from l_dynref index l_dyntabix.
    endif.
    READ TABLE SCREEN_PROGS WITH KEY SCREEN_PROGS-PROGRAM
                         BINARY SEARCH
                         TRANSPORTING NO FIELDS.
    L_TABIX = SY-TABIX.
    IF SY-SUBRC = 0.
      MODIFY SCREEN_PROGS INDEX L_TABIX TRANSPORTING DYNREF.
    ENDIF.
  ELSE.
    P_SSCR-DBFIELD = L_DYNREF-REFFIELD.
    P_TEXT = L_DYNREF-SELTEXT.
    MOVE-CORRESPONDING L_DYNREF-CONVERT TO P_SSCR.
    P_SSCR-DTYP = L_DYNREF-CONVERT-DYNPTYPE.
  ENDIF.
ENDFORM.
* Merkt sich die abgeänderten Texte (SELECTION_TEXTS_MODIFY)
FORM MODIFIED_SELTEXTS USING P_PROGRAM LIKE SY-REPID
                             P_TEXTS LIKE SCREEN_PROGS-TEXTS.

  DATA L_TABIX LIKE SY-TABIX.

  READ TABLE SCREEN_PROGS WITH KEY P_PROGRAM BINARY SEARCH
                       TRANSPORTING TEXTS.
  CHECK SY-SUBRC = 0.
  L_TABIX = SY-TABIX.
  SCREEN_PROGS-TEXTS = P_TEXTS.
  SORT SCREEN_PROGS-TEXTS BY NAME.
  MODIFY SCREEN_PROGS INDEX L_TABIX TRANSPORTING TEXTS.

ENDFORM.
* Füllt CURRENT_SCREEN-SELNUM. Wird separat aufgerufen, da
* CURRENT_SCREEN-SELNUM Index in CURRENT_SCREEN-SELOPTS enthält, d.h.
* CURRENT_SCREEN-SELOPTS muss erst sortiert werden!
FORM FILL_SELNUM USING    P_SELOPTS TYPE SYDB0_SELOPTS_T
                 CHANGING P_SELNUM  TYPE SYDB0_SELNUM_T.

  DATA L_SELOPTS TYPE SYDB0_SELOPTS.
  DATA L_SELNUM  TYPE SYDB0_SELNUM.
  DATA L_TABIX LIKE SY-TABIX.

  LOOP AT P_SELOPTS INTO L_SELOPTS.
    L_SELNUM-SELTABIX = SY-TABIX.
    L_SELNUM-NUMB = L_SELOPTS-NUMB.
    APPEND L_SELNUM TO P_SELNUM.
  ENDLOOP.

  SORT P_SELNUM BY NUMB.

ENDFORM.

* Wird als letzte Routine aus Modul %_INIT_PBO gerufen
* Jedesmal bei PBO
FORM %_PBO_MODIFY_SCREEN.                                         "#EC *


  CASE SCREEN_PROGS-SUBMODE.
    WHEN 'VC' OR 'VU'.
      SY-PFKEY =  '%_VC'.
    WHEN 'JA'.
      SY-PFKEY = '%_JA'.
    WHEN 'JB'.
      SY-PFKEY = '%_JB'.
  ENDCASE.

  IF <SSCRFIELDS>-UCOMM = 'GET'.
    CLEAR: SSCRFIELDS-UCOMM, <SSCRFIELDS>-UCOMM, SY-UCOMM.
    SYSTEM-CALL SUPPRESS-GPA.
    flag_suppress_gpa = 'X'.
  ENDIF.

  REFRESH CURRENT_SCR-OPTI_PUSH_OFF.
  REFRESH CURRENT_SCR-SELOPT_NO_INPUT.
  CLEAR: CURRENT_SCR-LAST_SUBSCREEN_PROGRAM,
         CURRENT_SCR-LAST_SUBSCREEN_DYNNR.
  IF CURSOR-FIELD ne SPACE and
     cursor-prog = current_screen-program and
     cursor-dynnr = current_screen-dynnr.
    SET CURSOR FIELD CURSOR-FIELD.
  ENDIF.

ENDFORM.                               "%_PBO_MODIFY_SCREEN
* Exportiert Inhalte für F3 auf Grundliste
* Wird auch aus FB RS_INT_EXPORT_SELPARS_2_MEM gerufen.
FORM EXPORT_VAR_2_MEM USING P_REPORT LIKE SY-REPID.

  data l_memkey like memkey.

  MOVE: SY-CPROG TO MEMKEY-REPORT,
        SY-SLSET TO MEMKEY-VARIANT,
        'S'      TO MEMKEY-KIND.
  SYSTEM-CALL INTERNAL MODE INTO MEMKEY-INT_MODE.
  PERFORM EXPORT_VAR_TO_MEM_STATIC(RSDBSPVD)
                                   TABLES DYNS_FIELDS
                                          DYNS_NODES
                                   USING  CURR_VSCR-VARI
                                          CURR_VSCR-VARIVDAT
                                          MEMKEY
                                          DYNS
                                          CURRENT_SCR-ALL_SELECTIONS
                                          f3progs.
  CLEAR MEMKEY-KIND.
  PERFORM %_EXPORT_VAR_TO_MEM IN PROGRAM (P_REPORT) USING MEMKEY
                              IF FOUND.

  l_memkey = memkey.
  loop at f3progs into l_memkey-report.
    PERFORM %_EXPORT_VAR_TO_MEM IN PROGRAM (l_memkey-report) USING
           l_MEMKEY IF FOUND.
  endloop.

ENDFORM.
* EXPORT der Selektionstabelle bei SUBMIT WITH SELECTION-TABLE
* Wird aus submit.rs1 gerufen
FORM EXPORT_SELTAB_2_MEM TABLES P_SELTAB type standard table
                         USING  P_AND_RETURN.

  data l_seltab_l type table of rsparamsl_255.
  data l_seltab_l_line type rsparamsl_255.
  data l_seltab   type table of rsparams.

  field-symbols <param> type rsparams.
  assign p_seltab to <param> casting.

  data len type i.
  data rs_params_lo_len type i.
  data typ_inf type c.

  describe field l_seltab_l_line length rs_params_lo_len in character mode.
  describe field p_seltab length len in character mode type typ_inf.

  if len = rs_params_lo_len and typ_inf = 'u'.
    l_seltab_l  = p_seltab[].
  else.
    l_seltab    = p_seltab[].
  endif.

  DATA L_KEY(18).
  PERFORM SET_ST_FS_MEMKEY USING    '%_SELT_%'
                                    P_AND_RETURN
                           CHANGING L_KEY.
  IF DEEP_PARS[] IS INITIAL.
    export %_seltab   from l_seltab
           %_seltab_l from l_seltab_l
      to memory id l_key.
  else.
    export %_seltab   from l_seltab
           %_seltab_l from l_seltab_l
           deep_pars
                                  TO MEMORY ID L_KEY.
    REFRESH DEEP_PARS.
  ENDIF.

ENDFORM.                               " EXPORT_SELTAB_2_MEM
* EXPORT der freien Abgrenzungen bei SUBMIT WITH FREE SEL.
* Wird aus submit.rs1 gerufen
FORM EXPORT_FREESEL_2_MEM USING P_TEXPR TYPE RSDS_TEXPR
                                P_AND_RETURN.

  DATA L_KEY(18).
  PERFORM SET_ST_FS_MEMKEY USING    '%_SELT_%'
                                    P_AND_RETURN
                           CHANGING L_KEY.
  IF DEEP_PARS[] IS INITIAL.
    EXPORT %_TEXPR FROM P_TEXPR TO MEMORY ID L_KEY.
  ELSE.
    EXPORT %_TEXPR FROM P_TEXPR DEEP_PARS
                                TO MEMORY ID L_KEY.
    REFRESH DEEP_PARS.
  ENDIF.

ENDFORM.                               " EXPORT_FREESEL_2_MEM
* EXPORT von SELTAB und TEXPR
* Wird aus submit.rs1 gerufen
FORM EXPORT_ST_FS_2_MEM TABLES P_SELTAB type standard table
                        USING  P_TEXPR TYPE RSDS_TEXPR P_AND_RETURN.

  data l_seltab_l type table of rsparamsl_255.
  data l_seltab_l_line type rsparamsl_255.
  data l_seltab   type table of rsparams.

  field-symbols <param> type rsparams.
  assign p_seltab to <param> casting.

  data len type i.
  data rs_params_lo_len type i.
  data typ_inf type c.

  describe field l_seltab_l_line length rs_params_lo_len in character mode.
  describe field p_seltab length len in character mode type typ_inf.

  if len = rs_params_lo_len and typ_inf = 'u'.
    l_seltab_l  = p_seltab[].
  else.
    l_seltab    = p_seltab[].
  endif.

  DATA L_KEY(18).
  PERFORM SET_ST_FS_MEMKEY USING    '%_SELT_%'
                                    P_AND_RETURN
                           CHANGING L_KEY.
  IF DEEP_PARS[] IS INITIAL.
    EXPORT %_SELTAB FROM l_SELTAB
           %_seltab_l from l_seltab_l
           %_texpr from p_texpr to memory id l_key.
  else.
    export %_seltab from l_seltab
           %_seltab_l from l_seltab_l
           %_TEXPR FROM P_TEXPR
           DEEP_PARS
           TO MEMORY ID L_KEY.
    REFRESH DEEP_PARS.
  ENDIF.

ENDFORM.                               " EXPORT_ST_FS_2_MEM
* EXPORT von DEEP_PARS und TEXPR
* Wird aus submit.rs1 gerufen
FORM EXPORT_DP_FS_2_MEM USING  P_TEXPR TYPE RSDS_TEXPR P_AND_RETURN.

  DATA L_KEY(18).

  PERFORM SET_ST_FS_MEMKEY USING    '%_SELT_%'
                                    P_AND_RETURN
                           CHANGING L_KEY.
  EXPORT DEEP_PARS
         %_TEXPR FROM P_TEXPR TO MEMORY ID L_KEY.
  REFRESH DEEP_PARS.

ENDFORM.                               " EXPORT_DP_FS_2_MEM
* EXPORT von DEEP_PARS
* Wird aus submit.rs1 gerufen
FORM EXPORT_DEEP_2_MEM USING P_AND_RETURN.

  DATA L_KEY(18).

  PERFORM SET_ST_FS_MEMKEY USING    '%_SELT_%'
                                    P_AND_RETURN
                           CHANGING L_KEY.
  EXPORT DEEP_PARS TO MEMORY ID L_KEY.
  REFRESH DEEP_PARS.

ENDFORM.                               " EXPORT_DEEP_2_MEM
* Setze Memory-Key
* Wird auch direkt aus submit.rs1 aufgerufen
FORM SET_ST_FS_MEMKEY USING    P_PREFIX
                               P_AND_RETURN
                      CHANGING P_KEY.

  DATA: BEGIN OF L_KEY,
          PREFIX(8),
          MODE(10) TYPE N,
        END   OF L_KEY.
  data l_called.

  SYSTEM-CALL INTERNAL MODE INTO L_KEY-MODE.
  system-call kernel_info 'IS_MODE_CALLED_TECH' l_called.
  IF P_AND_RETURN NE SPACE OR l_called is initial or
*    submit and return oder Modus 0
*       ( submit_info-mode_norml is initial and
*         submit_info-mode_vari is initial and
*         submit_info-mode_job is initial ) or
*        kein Submit
*         sy-subcs = 'T'.
*        über Transaktion gerufen

          not g_transaction is initial.
    ADD 1 TO L_KEY-MODE.
  ENDIF.
  L_KEY-PREFIX = P_PREFIX.
  MOVE L_KEY TO P_KEY.

ENDFORM.                                  " SET_ST_FS_MEMKEY

* EXPORT der Selektionstabelle bei SUBMIT WITH SELECTION-TABLE
* P_SUBRC: 0: Beide da
*          1: Nur SELTAB
*          2: Nur TEXPR
*          3: beide leer
*          4: Cluster nicht da
FORM IMPORT_SELTAB_FROM_MEM CHANGING P_SUBRC LIKE SY-SUBRC.

  DATA: BEGIN OF L_KEY,
          PREFIX(8) VALUE '%_SELT_%',
          MODE(10) TYPE N,
        END   OF L_KEY.

  data l_seltab   type  rsparams occurs 20.
  data l_seltab_l like rsparamsl_255 occurs 20.
  DATA L_TFILL   LIKE SY-TFILL.
  DATA L_TFILL_2 LIKE SY-TFILL.

  SYSTEM-CALL INTERNAL MODE INTO L_KEY-MODE.

  import  %_seltab   to l_seltab
          %_seltab_l to l_seltab_l
          %_texpr    to dyn_sel-texpr
          deep_pars
          from memory id l_key.
  P_SUBRC = SY-SUBRC.

  IF P_SUBRC = 0.
    FREE MEMORY ID L_KEY.
  ELSEif not l_key-mode is initial.
    subtract 1 from l_key-mode.

    import  %_seltab   to l_seltab
            %_seltab_l to l_seltab_l
            %_texpr    to dyn_sel-texpr
            deep_pars
          from memory id l_key.
    p_subrc = sy-subrc.

    if p_subrc eq 0.
      FREE MEMORY ID L_KEY.
    else.
      P_SUBRC = 4.
      EXIT.
    ENDIF.
  else.
    P_SUBRC = 4.
    EXIT.
  ENDIF.

  l_tfill = nmax( val1 = lines( l_seltab ) val2 = lines( l_seltab_l ) ).
  DESCRIBE TABLE DYN_SEL-TEXPR LINES L_TFILL_2.
  IF L_TFILL = 0.
    ADD 2 TO P_SUBRC.
  ELSE.
    if lines( l_seltab ) > 0.
      call function 'SELTAB_2_SELOPTS'
        exporting
          program                     = sy-cprog
        tables
          seltab                      = l_seltab
          p_sscr                      = %_sscr
        exceptions
          error_message               = 1
          others                      = 0.
    else.
      call function 'SELTAB_2_SELOPTS_255'
        exporting
          program                     = sy-cprog
        tables
          seltab                      = l_seltab_l
          p_sscr                      = %_sscr
        exceptions
          error_message               = 1
          others                      = 0.
    endif.
    if sy-subrc = 1.
      MESSAGE id sy-msgid TYPE 'A' NUMBER sy-msgno
         WITH
              sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
  endif.

  IF NOT DEEP_PARS[] IS INITIAL.
    PERFORM IMPORT_DEEP_OBJECTS.
  ENDIF.
  IF L_TFILL_2 = 0.
    ADD 1 TO P_SUBRC.
  ELSE.
    PERFORM FILL_DYNS_FIELDS_FROM_TEXPR(RSDBSPDS) TABLES DYNS_FIELDS
                                                  USING  DYN_SEL-TEXPR.
  ENDIF.

ENDFORM.                             " IMPORT_SELTAB_FROM_MEM
*  Nimmt Namen der tiefen Objekte entgegen
* Aufruf aus submit.rs1
FORM DEEP_PARS USING P_NAME LIKE RSSCR-NAME.
  APPEND P_NAME TO DEEP_PARS.
ENDFORM.                                      " DEEP_PARS
* Importiert die tiefen Übergabeparameter
FORM IMPORT_DEEP_OBJECTS.

  DATA L_CDIR LIKE CDIR OCCURS 5 WITH HEADER LINE.
  DATA: BEGIN OF L_KEY,
          PREFIX(8) VALUE '%_DEEP_%',
          MODE(10) TYPE N,
        END   OF L_KEY,
        L_SSCR LIKE RSSCR,
        L_NODI_IXST TYPE X,
        L_SUBRC LIKE SY-SUBRC.

  L_NODI_IXST = SSCR_F1_NODI + SSCR_F1_IXST.

  SYSTEM-CALL INTERNAL MODE INTO L_KEY-MODE.

  LOOP AT DEEP_PARS.
    READ TABLE SCREEN_PROGS-SSCR WITH KEY DEEP_PARS-NAME INTO L_SSCR
         TRANSPORTING FLAG1.
    CHECK SY-SUBRC = 0.
    IF L_SSCR-FLAG1 Z L_NODI_IXST.
      MESSAGE A036 WITH DEEP_PARS-NAME.
    ENDIF.
  ENDLOOP.
  PERFORM %_IMPORT_VAR_FROM_MEM IN PROGRAM (SY-CPROG)
                                USING L_KEY L_SUBRC.
ENDFORM.
* Wird jedesmal zu Beginn von PBO gerufen
* Bekommt Programmname des aktuellen Screens.
FORM INIT_PBO USING P_PROG LIKE SY-REPID
                    P_LDBPG LIKE SY-LDBPG.

  DATA L_SUBRC LIKE SY-SUBRC.
  DATA L_TYPE.
  DATA L_SCREEN TYPE SYDB0_SCREEN.
  data l_ucomm type syucomm.

* Zweiteilung nötig, da aus ablogdb.c nur %_INIT_PBO_FIRST
* gerufen wird, falls kein Sel.-bild existiert

* CALL SELECTION-SCREEN oder SUBMIT
  IF NEW_CALL NE SPACE.
    PERFORM GET_MORE_ICONS.
*   Programm noch nicht initialisiert
    IF NEW_CALL = 'S'.                       " SUBMIT
      PERFORM CHECK_SCR_VERSION USING P_PROG
                                CHANGING L_TYPE.
      PERFORM %_INIT_PBO_FIRST.
    ELSE.
      l_ucomm = <sscrfields>-ucomm.
      PERFORM INIT_1_PROG USING    P_PROG P_LDBPG NEW_CALL
                          CHANGING L_SUBRC.
      IF P_PROG NE CURRENT_SCREEN-PROGRAM.
        PERFORM %_LINK_%_SSCR_WAS_% IN PROGRAM (P_PROG)
                USING 'RSDBRUNT' 'TAKE_SSCR_WAS'        IF FOUND.
      ENDIF.
      IF VERSION_NEW_GEN = SPACE.
        PERFORM PUSH_SCREEN USING P_PROG P_LDBPG SY-DYNNR
                                              l_ucomm NEW_CALL.
      ELSE.
        CLEAR VERSION_NEW_GEN.
      ENDIF.
*     Neues Programm ?
      IF screen_progs-hash is initial.
        PERFORM CHECK_SCR_VERSION USING P_PROG
                                CHANGING L_TYPE.
      ENDIF.
      PHASE = 50.
      G_SUBTY = SY-SUBTY = CV_SUBTY_VIA_SELSCR.
      IF NEW_CALL = 'P'.     " Popup
        CURRENT_SCR-POPUP = 'X'.
      ENDIF.
    ENDIF.
    PERFORM %_INIT_PBO_LAST.
    CLEAR NEW_CALL.
  ELSEIF SY-DYNNR NE CURRENT_SCR-DYNNR OR P_PROG NE CURRENT_SCR-PROGRAM.
    MESSAGE A035 WITH P_PROG SY-DYNNR.
  ENDIF.                            " IF NEW_CALL NE SPACE

* AB hier immer bei PBO
* Nur SUBMIT:
  IF CURRENT_SCR-MODE   EQ 'S'.
*   Dunkler SUBMIT, aber nicht ueber Transaktionscodee
*   Entscheidung: zu 3.0 keine Unterdrueckung von SPA/GPAA
*   Entscheidung(18.9.95): zu 3.0 doch Unterdrueckung von SPA/GPAA
    IF SY-SUBCS NE 'T' AND
                        ( SY-BATCH NE SPACE OR SY-SUBTY Z CV_SUBTY_VIA_SELSCR ).
      IF  SY-SUBTY Z CV_SUBTY_VIA_SELSCR.
        SUPPRESS DIALOG.
      ENDIF.
      SYSTEM-CALL SUPPRESS-GPA.
      clear flag_suppress_gpa.
    ENDIF.
  ENDIF.

  "vh after suppress dialog
  perform VH_USER_CONTEXT.

* Select-Options-Fcodes wieder excludieren
  IF NOT CURRENT_SCR-SELOPTS_INSIDE IS INITIAL.
    PERFORM INSERT_INTO_EXCL(RSDBRUNT) USING:
                                 'OPTI ', 'DELS', 'DELA', 'SCRH'.
    CLEAR CURRENT_SCR-SELOPTS_INSIDE.
  ENDIF.
* ALLS/FEWS-Fcodes wieder excludieren
  IF NOT CURRENT_SCR-invisibles_INSIDE IS INITIAL.
    PERFORM INSERT_INTO_EXCL(RSDBRUNT) USING:
                                 'ALLS ', 'FEWS'.
    CLEAR CURRENT_SCR-invisibles_INSIDE.
  ENDIF.
* SUBMIT oder CALL
  PERFORM %_PBO_MODIFY_SCREEN.

  IF P_LDBPG NE SPACE.
    PERFORM PBO IN PROGRAM (P_LDBPG).
  ENDIF.

ENDFORM.                                         " INIT_PBO
* Wird jedesmal zu Beginn von PBO gerufen (Subscreens)
* Bekommt Programmname des aktuellen Screens.
FORM INIT_PBO_J USING P_PROG LIKE SY-REPID
                      P_LDBPG LIKE SY-LDBPG
                      P_SWITCH TYPE C.

  DATA: l_SCREEN TYPE SYDB0_SCREEN,
        l_subrc like sy-subrc,
        l_ucomm like sy-ucomm.

* P_SWITCH: bei Subscreens J, spaeter vielleicht auch mal was anneres

  PERFORM GET_MORE_ICONS.
  READ TABLE SCREENS WITH KEY PROGRAM = P_PROG
                           DYNNR   = SY-DYNNR
                           INTO L_SCREEN
                           BINARY SEARCH
            TRANSPORTING TYPE.
  IF SY-SUBRC = 0 AND L_SCREEN-TYPE NE 'J'.
    MESSAGE A035 WITH P_PROG SY-DYNNR.
  ENDIF.
  PERFORM SWITCH_TO_SUBSCREEN USING P_PROG P_LDBPG SY-DYNNR.

  PERFORM %_PBO_MODIFY_SCREEN.

  IF P_LDBPG NE SPACE.
    PERFORM PBO IN PROGRAM (P_LDBPG).
  ENDIF.
  if flag_query_active eq 'A' and screen_progs-dynsel ne space
    and dyns-initialized eq space and sy-dynnr ne query_is_dynnr.
*Freie Abgrenzungen für Querysubscreen.
    PERFORM DYNS_INIT(RSDBSPDS) TABLES   %_SSCR
                                     DYNS_NODES
                                     DYNS_FIELDS
                            CHANGING DYN_SEL-TEXPR
                                     DYNS-TABS
                                     DYNS-FIELDS_SELECTED
                                     DYNS-ACTIVE_SELECTIONS
                                     GL_VARIDYN
                                     L_SUBRC.
    l_ucomm = 'DYNS'.
    dyns-tabs = 'X'.
    PERFORM DYNS_DIALOG(RSDBSPDS) TABLES %_SSCR
                 using 'X'
                 CHANGING l_ucomm.
*   elseif flag_query_active eq 'A' and sy-dynnr eq query_is_dynnr
*     and dyns-query_initialized eq space.
*     perform initialize_query_infoset.
   endif.
ENDFORM.                                         " INIT_PBO_J
* Wird bei SUBMIT einmal ganz am Anfang von PBO gerufen
FORM %_INIT_PBO_FIRST.                                            "#EC *

  DATA L_TFILL LIKE SY-TFILL.
  DATA L_TABIX LIKE SY-TABIX.
  DATA L_SUBRC LIKE SY-SUBRC.
  DATA L_SUBRC_2 LIKE SY-SUBRC.
  DATA L_SECU LIKE TRDIR-SECU.
  DATA L_SSET LIKE TRDIR-SSET.
  DATA L_SELOPT LIKE RSSCR-NAME.    " Dummy
  DATA L_SUBC LIKE TRDIR-SUBC.
  DATA L_PARAMS TYPE SYDB0_PARAMS.
  DATA L_SELTAB_DONE.
  DATA L_MEMKEY LIKE RSVAMEMKEY.
  DATA L_MANDT LIKE SY-MANDT.
  DATA L_HEAD LIKE RHEAD OCCURS 0 WITH HEADER LINE.
  DATA L_FLAG1 TYPE X.

  DATA: BEGIN OF L_FORMNAME_0,
          PREFIX(7) VALUE '%_LINK_',
          SUFFIX(8),
        END OF L_FORMNAME_0.

  DATA L_DYNS_FIELDS LIKE RSDSFIELDS OCCURS 1 WITH HEADER LINE.
  DATA L_TEXPR TYPE RSDS_TEXPR.
  DATA L_IMEX LIKE IMEX VALUE 'X '.
  DATA L_VARI LIKE CURR_VSCR-VARI.
  DATA L_VARIVDAT LIKE CURR_VSCR-VARIVDAT.
  DATA L_VARIDYN  LIKE GL_VARIDYN.
  DATA L_VDATDYN  LIKE GL_VDATDYN.
  DATA L_TITLE LIKE SY-TITLE.

  FIELD-SYMBOLS <L_F>.

  PHASE = 2.

  G_SUBTY = SY-SUBTY.

  READ TABLE SCREEN_PROGS WITH KEY SY-CPROG BINARY SEARCH
                           TRANSPORTING ANY_VARIANTS.
  L_TABIX = SY-TABIX.
  IF SY-SUBTY O SUBTY_FOREIGN_VARIS.
    IMPORT %_VARIPROG TO %_RKEY-REPORT FROM MEMORY ID '%_VARIPROG_%'.
    SELECT SINGLE SUBC INTO L_SUBC FROM TRDIR
                                    WHERE NAME = %_RKEY-REPORT.
    IF SY-SUBRC NE 0 OR L_SUBC NE '1'.
       NO_VARIUCOMM = 'X'.
    ENDIF.
  ELSE.
    MOVE SY-CPROG TO %_RKEY-REPORT.
  ENDIF.

  IF SY-SUBTY Z SUBTY_NO_SELSCREEN.
    PERFORM PROG_HAS_VARI USING    %_RKEY-REPORT
                          CHANGING SCREEN_PROGS-ANY_VARIANTS.
    IF SCREEN_PROGS-ANY_VARIANTS NE SPACE AND ( SY-BATCH IS INITIAL OR SY-BINPT IS NOT INITIAL )
                                          and CURRENT_SCREEN-ANY_VARIANTS IS INITIAL.
      CALL FUNCTION 'RS_VARIANT_FOR_ONE_SCREEN'
           EXPORTING
                PROGRAM        = %_RKEY-REPORT
                DYNNR          = SY-DYNNR
           IMPORTING
                VARIANT_EXISTS = CURRENT_SCREEN-ANY_VARIANTS
           EXCEPTIONS
                OTHERS         = 1.
    ENDIF.
  ELSE.
    LOAD REPORT SY-CPROG PART 'HEAD' INTO L_HEAD.
    READ TABLE L_HEAD INDEX 1 TRANSPORTING FLAG1.
    IF SY-SUBRC = 0.
      L_FLAG1 = L_HEAD-FLAG1.
      IF L_FLAG1 O PGHD_F1_ADDSC OR L_FLAG1 O PGHD_F1_S1000.
        PERFORM PROG_HAS_VARI USING    %_RKEY-REPORT
                          CHANGING SCREEN_PROGS-ANY_VARIANTS.
      ENDIF.
    ENDIF.
  ENDIF.

  MOVE %_RKEY-REPORT TO SCREEN_PROGS-VARIPROG.
  MODIFY SCREEN_PROGS INDEX L_TABIX
                   TRANSPORTING VARIPROG ANY_VARIANTS.

  MOVE SY-SLSET TO %_RKEY-VARIANT.

  IF SCREEN_PROGS-SUBMODE(1) = SPACE.
    PERFORM %_INIT_AUTH_SUBMIT IN PROGRAM (SY-CPROG)
            USING  L_SECU L_SSET IF FOUND.
    PERFORM %_AUTH_SUBMIT USING %_RKEY-VARIANT L_SECU L_SSET.
  ENDIF.
  PERFORM PROVIDE_SUBMIT_INFO_01.
* PROZESSIERE INITIALIZATION
  L_TITLE = SY-TITLE.
  SYSTEM-CALL INITIALIZATION.
* Kennzeichen: INITIALIZATION vorbei
  PHASE = 3.
* SET TITLEBAR bei INITIALIZATION?
  IF SY-TITLE  NE L_TITLE.
    CURRENT_SCREEN-TITLE = SY-TITLE.
  ENDIF.
  IF SCREEN_PROGS-SUBMODE(1) = 'J'.
    IMPORT RSJOBINFO FROM MEMORY ID '%_JOBINFO'.
    EXPORT SPACE TO MEMORY ID '%_JOBINFO'.
  ENDIF.
  L_SUBRC = 0.

*  perform submit_dyn_objects using
*   sy-cprog CURRENT_SCREEN-dynnr sy-ldbpg.

*   Interne Variante aus MEMORY ?
  IF SCREEN_PROGS-SUBMODE CO '0123456789'.
    MOVE-CORRESPONDING %_RKEY TO L_MEMKEY.
    MOVE SCREEN_PROGS-SUBMODE TO L_MEMKEY-INT_MODE.
    CLEAR: SCREEN_PROGS-SUBMODE, SCREEN_PROGS-STATUS_SUBMODE.
    PERFORM %_IMPORT_VAR_FROM_MEM IN PROGRAM (SY-CPROG)
                                  USING L_MEMKEY L_SUBRC.
    MOVE 'S' TO L_MEMKEY-KIND.
    PERFORM IMPORT_VAR_FROM_MEM_STATIC(RSDBSPVD)
                             TABLES   DYNS_FIELDS
                                      DYNS_NODES
                             CHANGING L_VARI
                                      L_VARIVDAT
                                      L_MEMKEY
                                      DYNS
                                      ALL_SELECTIONS_FOR_F3
                                      f3progs
                                      L_SUBRC.
    clear l_memkey-kind.
    loop at f3progs into l_memkey-report.
      PERFORM %_IMPORT_VAR_FROM_MEM IN PROGRAM (l_memkey-report)
                                    USING L_MEMKEY L_SUBRC.
    endloop.
    f3progs_old = f3progs.
    clear f3progs.
    PERFORM SUBMIT_VARI_INFO(RSDBSPVA) USING L_VARI L_VARIVDAT
                                             L_VARIDYN L_VDATDYN 'I'.
    L_SUBRC = 0.
  ELSEIF %_RKEY-VARIANT NE SPACE.
*     Importiert Variante
*     0: Variante aktuell                                              *
*     2: Veraltet, aber reparabel                                      *
*     4: Variante nicht vorhanden                                      *
*     6: Variante vorhanden, aber nicht diesem Bild zugeordnet         *
*     8: Nicht reparabel, da sich Art, Typ oder Länge geändert hat.    *
    PERFORM IMPORT_VARI(RSDBSPVA) USING    SY-CPROG %_RKEY-REPORT
*                                           SY-DYNNR
                                           %_RKEY-VARIANT 'S'
                                  CHANGING L_SUBRC.
    IF L_SUBRC LE 2.
      IF SCREEN_PROGS-SUBMODE NE 'VC'.
        SYSTEM-CALL SUPPRESS-GPA.
        flag_suppress_gpa = 'X'.
      ENDIF.
    ENDIF.

    PERFORM HANDLE_SUBTY_WITH_SELTAB CHANGING L_SUBRC_2.
    L_SELTAB_DONE = 'X'.

    PERFORM DYNS_INIT(RSDBSPDS) TABLES    %_SSCR
                                          DYNS_NODES
                                          DYNS_FIELDS
                                CHANGING  DYN_SEL-TEXPR
                                          DYNS-TABS
                                          DYNS-FIELDS_SELECTED
                                          DYNS-ACTIVE_SELECTIONS
                                          GL_VARIDYN
                                          L_SUBRC_2.
    IF L_SUBRC_2 = 0.
      PERFORM DELETE_FROM_EXCL USING 'DYNS'
                    CHANGING CURRENT_SCR.
    ENDIF.
    CASE L_SUBRC.
* 4:     Variante nicht vorhanden ==> Abbruch
* 8:     Variante veraltet        ==> Abbruch
      WHEN 0.          " Alles O.K.
        MOVE %_RKEY-VARIANT TO SY-SLSET.
      WHEN 4 OR 6.     " Variante nicht vorhanden
        IF SCREEN_PROGS-SUBMODE(1) = 'V'.
          MOVE %_RKEY-VARIANT TO SY-SLSET.  " Variantenpflege
          PERFORM SUBMIT_VARI_INFO(RSDBSPVA)
                 USING L_VARI L_VARIVDAT L_VARIDYN L_VDATDYN
                       SCREEN_PROGS-SUBMODE.
          L_SUBRC = 0.                   " In diesem Fall erlaubt
        ENDIF.
    ENDCASE.
    IF SCREEN_PROGS-SUBMODE(1) = 'V' AND L_SUBRC = 0.
        PERFORM FILL_VARI_COMP(RSDBSPVA) TABLES   %_SSCR
                                         USING    SY-CPROG
                                                  DYN_SEL-TEXPR 'OLD'.
    ENDIF.
  ENDIF.
  MODIFY SCREEN_PROGS INDEX L_TABIX
                   TRANSPORTING SUBMODE STATUS_SUBMODE.

  IF L_SUBRC = 0.
    IF L_SELTAB_DONE = SPACE.
      PERFORM HANDLE_SUBTY_WITH_SELTAB CHANGING L_SUBRC.
      IF L_SUBRC = 0 OR L_SUBRC = 2.    " TEXPR da
        PERFORM DYNS_INIT(RSDBSPDS) TABLES    %_SSCR
                                              DYNS_NODES
                                              DYNS_FIELDS
                                    CHANGING  DYN_SEL-TEXPR
                                              DYNS-TABS
                                              DYNS-FIELDS_SELECTED
                                              DYNS-ACTIVE_SELECTIONS
                                              GL_VARIDYN
                                              L_SUBRC_2.
        IF L_SUBRC_2 = 0.
          PERFORM DELETE_FROM_EXCL USING 'DYNS'
                        CHANGING CURRENT_SCR.
        ENDIF.
      ENDIF.
    ENDIF.
* Dunkler SUBMIT VIA JOB
    IF SCREEN_PROGS-SUBMODE(1) = 'J'.
      IF SCREEN_PROGS-SUBMODE = 'JA'.
        IF SY-SUBTY O CV_SUBTY_VIA_SELSCR.
          SUBTRACT CV_SUBTY_VIA_SELSCR FROM SY-SUBTY.
        ENDIF.
* Setze richtigen OK-Code
        <SSCRFIELDS>-UCOMM = 'JOBS'.
        SY-UCOMM = 'JOBS'.
      ENDIF.          " IF SCREEN_PROGS-submode = 'JA'
      IF SY-SUBTY O SUBTY_NO_SELSCREEN.  " Kein Selektionsbild
        PERFORM SUBMIT_JOB(RSDBSPJS) TABLES DYNS_FIELDS
                                     USING  SY-CPROG G_SUBTY SPACE.
      ENDIF.
    ENDIF.          " IF SCREEN_PROGS-submode(1) = 'J'
  ELSE.
* ABBRUCH !!!
    PERFORM %_VARIANT_PROBLEMS(RSDBSPVA) USING %_RKEY L_SUBRC.    "#EC *
* Vorsichtshalber
    IF SY-SUBTY Z CV_SUBTY_VIA_SELSCR.
      ADD CV_SUBTY_VIA_SELSCR TO SY-SUBTY.
    ENDIF.
    CLEAR <SSCRFIELDS>-UCOMM.
    CLEAR SY-UCOMM.
  ENDIF.
ENDFORM.                     "  %_INIT_PBO_FIRST

* Füllt außerdem Tabelle SELNUM, da die Routine einmal gerufen wird,
* und zwar nach allen %_SEL_TEXT_NEW
FORM %_INIT_PBO_LAST.                                             "#EC *

  DATA TITLE LIKE SY-TITLE.
  DATA L_SUBRC LIKE SY-SUBRC.
  DATA L_FCODE LIKE SSCRFIELDS-UCOMM.
  DATA L_SELNUM TYPE SYDB0_SELNUM.
  DATA L_DYNNR LIKE SY-DYNNR.
  DATA L_HEAD  LIKE RHEAD.       " Dummy
  DATA L_ANY_SELOPTS.
  DATA L_INDEX(4).
  DATA L_TFILL(4).
  data: l_text type string,
        l_length type i.

  if new_call = 'S'.
    system-call set_kernel_info 'LIST_TO_MEMORY' space.
  endif.

  IF SCREEN_PROGS-SUBMODE(1) = 'V'.
    IF  SCREEN_PROGS-REPORT_WRITER = SPACE.
      IF VSCR_TFILL <= 1.
        select single text from RSMPTEXTS into l_text
                where progname = 'RSSYSTDB'
                  and sprsl    = sy-langu
                  and obj_type = 'T'
                  and obj_code = '%_W'.
        if sy-subrc = 0.
          replace '&1' in l_text with sy-cprog.
          replace '&2' in l_text with sy-slset.
          l_length = strlen( l_text ).
        endif.
        if l_length > 70.
          SET TITLEBAR '%_V2' WITH SY-SLSET.  "#EC * " Variantenpflege
        else.
          SET TITLEBAR '%_V' WITH SY-CPROG SY-SLSET.  "#EC * " Variantenpflege
        endif.
      ELSE.
        WRITE VSCR_INDEX TO L_INDEX NO-SIGN LEFT-JUSTIFIED.
        WRITE VSCR_TFILL TO L_TFILL NO-SIGN LEFT-JUSTIFIED.
        select single text from RSMPTEXTS into l_text
                where progname = 'RSSYSTDB'
                  and sprsl    = sy-langu
                  and obj_type = 'T'
                  and obj_code = '%_W'.
        if sy-subrc = 0.
          replace '&1' in l_text with sy-cprog.
          replace '&2' in l_text with sy-slset.
          replace '&3' in l_text with l_index.
          replace '&4' in l_text with l_tfill.
          l_length = strlen( l_text ).
        endif.
        if l_length > 70.
          SET TITLEBAR '%_W2' WITH SY-SLSET L_INDEX L_TFILL.  "#EC *
        else.
          SET TITLEBAR '%_W' WITH SY-CPROG SY-SLSET L_INDEX L_TFILL.  "#EC *
        endif.
      ENDIF.
    ELSE.
      SET TITLEBAR '%_T' WITH SCREEN_PROGS-TITLE.  "#EC *
    ENDIF.
  ELSE.
* !!!!
*IF NOT ( CURRENT_SCREEN-PROGRAM = 'KSTESTTAB'
*                 AND CURRENT_SCREEN-DYNNR = '0012' ).
* !!!!
    TITLE = CURRENT_SCREEN-TITLE.
    IF SCREEN_PROGS-SUBMODE = 'JA'.
   SET TITLEBAR '%_A' WITH CURRENT_SCREEN-TITLE. "#EC * " fehlerhafte Einplanung
    ELSEIF SCREEN_PROGS-SUBMODE = 'JB'.
   SET TITLEBAR '%_B' WITH CURRENT_SCREEN-TITLE. "#EC * " korrekte Einplanung
    ELSEIF CURRENT_SCREEN-TITLETYPE NE 'F'.
      SET TITLEBAR '%_T' WITH TITLE.  "#EC * " Programmstart
    ENDIF.
  ENDIF.
* !!!!
*ENDIF.
* !!!!

  IF SCREEN_PROGS-DYNSEL = 'X' AND DYNS-INITIALIZED = SPACE.
    PERFORM DYNS_INIT(RSDBSPDS) TABLES   %_SSCR
                                         DYNS_NODES
                                         DYNS_FIELDS
                                CHANGING DYN_SEL-TEXPR
                                         DYNS-TABS
                                         DYNS-FIELDS_SELECTED
                                         DYNS-ACTIVE_SELECTIONS
                                         GL_VARIDYN
                                         L_SUBRC.
    IF L_SUBRC = 0.
      PERFORM DELETE_FROM_EXCL USING 'DYNS'
                    CHANGING CURRENT_SCR.
    ENDIF.
  ENDIF.

  DESCRIBE TABLE CURRENT_SCR-EXCL LINES SY-TFILL.
  IF SY-TFILL = 0.
    PERFORM FILL_EXCL_TAB.
  ENDIF.

  IF ALL_SELECTIONS_FOR_F3 NE SPACE AND CURRENT_SCR-MODE = 'S'.
                                      " F3 von Grundliste?
     PERFORM HANDLE_INVISIBLES USING ALL_SELECTIONS_FOR_F3.
     current_scr-all_selections = ALL_SELECTIONS_FOR_F3.
  ELSEIF ALL_SELECTIONS_VIA_FB NE SPACE.
    PERFORM HANDLE_INVISIBLES USING ALL_SELECTIONS_VIA_FB.
  ELSE.
    PERFORM HANDLE_INVISIBLES USING CURRENT_SCR-ALL_SELECTIONS.
  ENDIF.

ENDFORM.                         " %_INIT_PBO_LAST
* Wird ganz am Ende von PBO gerufen (jedesmal)
FORM %_END_OF_PBO.                                                "#EC *

* Damit SHOW_TAB bereits auf die Feldeigenschaften zugreifen kann,
* wurde MODIFY_SCREEN-Aufruf nach SET_PF_STATUS vorverlegt.
* Hier werden jetzt nur noch die Manipulationen vorgenommen, die
* erst nach SHOW_TAB möglich sind: Optionen-Button ein/aus
* PERFORM MODIFY_SCREEN.

  DATA L_TITLE LIKE SY-TITLE.
  DATA L_TABIX LIKE SY-TABIX.
  data l_tabix_2 like sy-tabix.
  DATA L_SUBRC LIKE SY-SUBRC.
  DATA L_VARI LIKE RVARI.
  DATA: L_SELNUM TYPE SYDB0_SELNUM.
  DATA: L_SELOPTS TYPE SYDB0_SELOPTS.
  DATA: BEGIN OF L_FORMNAME_0,
          PREFIX(7) VALUE '%_LINK_',
          SUFFIX LIKE RSSCR-NAME,
        END OF L_FORMNAME_0.
  DATA L_SELOPT_NO_INPUT TYPE SYDB0_SELNOIN.
  data l_flag.
  data l_modtext type sydb0_modtext.
  data l_text type rsseltexts.
  DATA L_FNAME(200).

  FIELD-SYMBOLS: <L_DYNREF> TYPE SYDB0_DYNREF, <l_text>.

  SORT CURRENT_SCR-OPTI_PUSH_OFF BY NUMB.
  SORT CURRENT_SCR-SELOPT_NO_INPUT BY NUMB.

  LOOP AT SCREEN.
    IF SCREEN-GROUP3 = 'OPU'.      " OPTI_PUSH
      READ TABLE CURRENT_SCR-OPTI_PUSH_OFF WITH KEY SCREEN-GROUP4
           BINARY SEARCH TRANSPORTING NO FIELDS.
      IF SY-SUBRC = 0.
        SCREEN-ACTIVE    = '0'.
        MODIFY SCREEN.
        CONTINUE.
      ENDIF.
    ENDIF.
    IF SCREEN-GROUP3 = 'LOW' OR SCREEN-GROUP3 = 'HGH'.
   READ TABLE CURRENT_SCREEN-SELNUM WITH KEY SCREEN-GROUP4 BINARY SEARCH
           INTO L_SELNUM TRANSPORTING SELTABIX.
      CHECK SY-SUBRC = 0.
      READ TABLE CURRENT_SCREEN-SELOPTS INDEX L_SELNUM-SELTABIX
           INTO L_SELOPTS.
      CHECK SY-SUBRC = 0.
      IF L_SELOPTS-SSCR-FLAG2 O SSCR_F2_DYN.
        READ TABLE SCREEN_PROGS-DYNREF WITH KEY NAME = L_SELOPTS-NAME
             BINARY SEARCH ASSIGNING <L_DYNREF>.
        CHECK SY-SUBRC = 0.
        SCREEN-LENGTH = <L_DYNREF>-CONVERT-OLENGTH.
        IF NOT <L_DYNREF>-F4 IS INITIAL.
          SCREEN-VALUE_HELP = '1'.
        ENDIF.
        MODIFY SCREEN.
        IF SCREEN-GROUP3 = 'LOW'.
          MOVE SCREEN TO L_SELOPTS-SCREEN_LOW.
        ELSE.
          MOVE SCREEN TO L_SELOPTS-SCREEN_HIGH.
        ENDIF.
        MODIFY CURRENT_SCREEN-SELOPTS
            INDEX L_SELNUM-SELTABIX FROM L_SELOPTS
            TRANSPORTING SCREEN_LOW SCREEN_HIGH.
      ENDIF.
    ENDIF.
    IF SCREEN-GROUP3 = 'LOW'.
      READ TABLE CURRENT_SCR-SELOPT_NO_INPUT WITH KEY SCREEN-GROUP4
                   INTO L_SELOPT_NO_INPUT BINARY SEARCH.
      IF SY-SUBRC = 0 AND L_SELOPT_NO_INPUT-LOW NE SPACE.
        SCREEN-INPUT = '0'.
        MODIFY SCREEN.
        CONTINUE.
      ENDIF.
    ENDIF.
    IF SCREEN-GROUP3 = 'HGH' or screen-group3 = 'TOT'.
      READ TABLE CURRENT_SCR-SELOPT_NO_INPUT WITH KEY SCREEN-GROUP4
                   INTO L_SELOPT_NO_INPUT BINARY SEARCH.
      IF SY-SUBRC = 0 AND L_SELOPT_NO_INPUT-HIGH NE SPACE.
        case L_SELOPT_NO_INPUT-HIGH.
          when 'I'.
            SCREEN-active = '0'.
          when others.
            if screen-group3 ne 'HGH'.
              continue.
            endif.
            SCREEN-INPUT = '0'.
        endcase.
        MODIFY SCREEN.
        CONTINUE.
      ENDIF.
    ENDIF.
    IF SCREEN-GROUP3 = 'VPU'.
      READ TABLE CURRENT_SCR-SELOPT_NO_INPUT WITH KEY SCREEN-GROUP4
                   INTO L_SELOPT_NO_INPUT BINARY SEARCH.
      IF SY-SUBRC = 0 AND L_SELOPT_NO_INPUT-VPUSH NE SPACE.
        case L_SELOPT_NO_INPUT-vpush.
          when 'I'.
            SCREEN-active = '0'.
          when others.
            SCREEN-INPUT = '0'.
        endcase.
        MODIFY SCREEN.
        CONTINUE.
      ENDIF.
    ENDIF.
    IF SCREEN-GROUP3 = 'PAR'.
      READ TABLE SCREEN_PROGS-DYNREF WITH KEY NAME = SCREEN-NAME
           BINARY SEARCH ASSIGNING <L_DYNREF>.
      CHECK SY-SUBRC = 0.
      SCREEN-LENGTH = <L_DYNREF>-CONVERT-OLENGTH.
      IF NOT <L_DYNREF>-F4 IS INITIAL.
        SCREEN-VALUE_HELP = '1'.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

  IF CURRENT_SCREEN-TITLETYPE = 'F' AND VSCR_TFILL LE 1.
    PERFORM %_SELSCREEN_TITLE_% IN PROGRAM (CURRENT_SCREEN-PROGRAM)
                              USING    CURRENT_SCREEN-DYNNR
                              CHANGING L_TITLE
                              IF FOUND.
    SET TITLEBAR '%_T' WITH L_TITLE.      "#EC *
  ENDIF.

* SPA/GPA-Handling bei Varianten
  IF SY-SLSET NE SPACE AND SCREEN_PROGS-SUBMODE NE 'VC' AND
          ( SY-SUBCS = 'T' OR
           SY-BATCH = SPACE AND SY-SUBTY O CV_SUBTY_VIA_SELSCR ).
    LOOP AT CURRENT_SCREEN-PARAMS INTO G_PARAMS
              WHERE SSCR-SPAGPA NE SPACE.
      READ TABLE CURR_VSCR-VARI WITH KEY G_PARAMS-NAME
                                INTO L_VARI TRANSPORTING INVISIBLE XFLAG1.
      IF SY-SUBRC = 0.
        READ TABLE CURRENT_SCREEN-INVISIBLE WITH KEY G_PARAMS-NUMB
                BINARY SEARCH
                TRANSPORTING NO FIELDS.
*        CHECK SY-SUBRC NE 0.
        IF SY-SUBRC EQ 0 AND L_VARI-INVISIBLE IS INITIAL.
          CONTINUE.
        ENDIF.
        READ TABLE NO_SPAGPA
                  WITH KEY G_PARAMS-NAME
                  BINARY SEARCH
                  TRANSPORTING NO FIELDS.
        CHECK SY-SUBRC NE 0.
        MOVE G_PARAMS-NAME TO L_FORMNAME_0-SUFFIX.
        IF L_VARI-XFLAG1 Z VARI_F1_NOSPAGPA.
          L_SUBRC = 0.
        ELSE.
          L_SUBRC = 4.
        ENDIF.
        PERFORM (L_FORMNAME_0) IN PROGRAM (CURRENT_SCREEN-PROGRAM)
               USING 'RSDBRUNT' 'PARAM_GPA' L_SUBRC IF FOUND.
      ENDIF.
    ENDLOOP.
  ENDIF.

  READ TABLE SCREEN_PROGS WITH KEY CURRENT_SCREEN-PROGRAM BINARY SEARCH
                 TRANSPORTING AFTER_FIRST_PBO .
  L_TABIX = SY-TABIX.
  IF SY-SUBRC = 0 AND SCREEN_PROGS-AFTER_FIRST_PBO EQ SPACE.
"$$
    MOVE 'X' TO SCREEN_PROGS-AFTER_FIRST_PBO.
    MODIFY SCREEN_PROGS INDEX L_TABIX TRANSPORTING AFTER_FIRST_PBO.
  ENDIF.
  clear l_flag.
  loop at current_screen-modtext into l_modtext.
    l_tabix_2 = sy-tabix.
    read table screen_progs-texts
          with key name = l_modtext-name
          into l_text binary search transporting text.
    check sy-subrc = 0 and l_text-text ne l_modtext-text.
    read table %_sscr index l_modtext-index.
    check sy-subrc eq 0.
    CONCATENATE '(' current_screen-program ')' %_SSCR-NAME
               '_' current_screen-DYNNR INTO L_FNAME.
    ASSIGN (L_FNAME) TO <L_TEXT>.
    CHECK SY-SUBRC = 0.
    <l_text> = l_text-text.
    l_modtext-text = l_text-text.
    modify current_screen-modtext index l_tabix_2 from l_modtext
         transporting text.
    l_flag = 'X'.
  endloop.
  if l_flag ne space.
    clear l_flag.
*    modify current_screen index l_tabix transporting modtext.
  endif.
* Bei Subscreens: Zurueck zum Rahmen!
  IF CURRENT_SCR-MODE = 'J'.
    PERFORM RETURN_FROM_SUBSCREEN.
  ELSE.
    IF NOT CURRENT_SCR-SELOPTS_INSIDE IS INITIAL.
      PERFORM DELETE_FROM_EXCL USING 'OPTI' CHANGING CURRENT_SCR.
      PERFORM DELETE_FROM_EXCL USING 'DELS' CHANGING CURRENT_SCR.
      PERFORM DELETE_FROM_EXCL USING 'DELA' CHANGING CURRENT_SCR.
      PERFORM DELETE_FROM_EXCL USING 'SCRH' CHANGING CURRENT_SCR.
      l_flag = 'X'.
    endif.
    IF NOT CURRENT_SCR-invisibles_INSIDE IS INITIAL
      or not current_screen-any_invisibles is initial.
      PERFORM HANDLE_INVISIBLES USING CURRENT_SCR-ALL_SELECTIONS.
      l_flag = 'X'.
    endif.
    if not l_flag is initial.
      PERFORM SET_GUI_STATUS USING CURRENT_SCR-STATUS.
    endif.
    if current_scr-mode = 'S'.
      clear f3progs_old.
    endif.
  ENDIF.

* Drag&Relate support: Flag will be interpreted at CTL_OUTPUT.
* Should not be set earlier
  perform set_is_selscreen in program sapfspor
          USING 'X' if found.

ENDFORM.                               "  %_END_OF_PBO
* Versorgt SPA/GPA-Parameter
FORM PARAM_GPA USING P_PARAM P_TEXT P_SUBRC.

  CHECK P_PARAM IS INITIAL.
  IF P_SUBRC = 0.
    GET PARAMETER ID G_PARAMS-SSCR-SPAGPA FIELD P_PARAM.
  ELSE.
    SET PARAMETER ID G_PARAMS-SSCR-SPAGPA FIELD P_PARAM.
  ENDIF.

ENDFORM.
* Setzt bzw. interpretiert Feldeigenschaften
* Wird aus SET_PF_STATUS gerufen (früher aus %_END_OF_PBO)
* Dies ist nach AT SELECTION-SCREEN OUTPUT, aber vor den
* SHOW_TAB-Aufrufen. Damit sind alle vom Anwendungsprogramm bzw. der
* logischen Datenbank vorgenommenen Feldmanipulationen aktiv,
* und SHOW_TAB kann z.B. erkennen, ob das HIGH-Feld ausgeblendet wurde
FORM MODIFY_SCREEN.

  DATA L_TABIX LIKE SY-TABIX.
  DATA L_SELNUM  TYPE SYDB0_SELNUM.
  DATA L_SELOPTS TYPE SYDB0_SELOPTS.
  DATA L_PARAMS  TYPE SYDB0_PARAMS.
  data l_text like smp_dyntxt-quickinfo.

* Tabelle der zu exkludierenden 'bis'-Felder
  DATA: BEGIN OF L_TO_TEXT_OFF OCCURS 5,
          GROUP4 LIKE D021S-GRP4,
        END   OF L_TO_TEXT_OFF.

  REFRESH NO_SPAGPA.
  SORT CURRENT_SCREEN-NOINTERVALS BY NUMB.

  if flag_query_active eq 'A' ."and sy-dynnr eq query_is_dynnr.
* Query activ, ausgeblendete Felder besorgen
    perform get_invisibles in program saplaq_adhoc
                           using sy-dynnr
                                 current_screen-selopts
                                 current_screen-params
                           changing current_screen-invisible.
  endif.
  LOOP AT SCREEN.

    if screen-group4 = 'SRI'.
      screen-active = '0'.
      modify screen.
      continue.
    endif.

* Ist Feld laut Variante unsichtbar oder ist Query aktiv??
    IF CURRENT_SCR-ALL_SELECTIONS = 'F' or flag_query_active eq 'A'.
      READ TABLE CURRENT_SCREEN-INVISIBLE
                          WITH KEY SCREEN-GROUP4 BINARY SEARCH
                          TRANSPORTING NO FIELDS.
      IF SY-SUBRC EQ 0.
        SCREEN-ACTIVE    = '0'. MODIFY SCREEN. CONTINUE.
      ENDIF.
    ENDIF.

    CHECK    SCREEN-GROUP4 NE SPACE
         AND SCREEN-GROUP4 CO ' 0123456789'.
    IF SCREEN_PROGS-SUBMODE = 'JA'.
      SCREEN-INPUT = '0'. MODIFY SCREEN.
    ELSEIF CURRENT_SCREEN-ANY_INACTIVES NE SPACE AND
              SCREEN-GROUP3 NE 'OPU' AND SCREEN-GROUP3 NE 'VPU'.
      READ TABLE CURRENT_SCREEN-INACTIVE
                          WITH KEY SCREEN-GROUP4 BINARY SEARCH
                          TRANSPORTING NO FIELDS.
      IF SY-SUBRC = 0.
        SCREEN-INPUT = '0'. MODIFY SCREEN.
      ENDIF.
    ENDIF.

    IF SCREEN-GROUP3 = 'HGH' AND SCREEN-INVISIBLE = '1' . " HIGH
      MOVE SCREEN-GROUP4 TO L_TO_TEXT_OFF-GROUP4.
      APPEND L_TO_TEXT_OFF.
    ELSEIF SCREEN-GROUP3 = 'HGH' AND SCREEN-INVISIBLE = '0' AND
           NOT CURRENT_SCREEN-NOINTERVALS IS INITIAL.
      READ TABLE CURRENT_SCREEN-NOINTERVALS
                          WITH KEY SCREEN-GROUP4 BINARY SEARCH
                          TRANSPORTING NO FIELDS.
      IF SY-SUBRC EQ 0.
       MOVE SCREEN-GROUP4 TO L_TO_TEXT_OFF-GROUP4.
       APPEND L_TO_TEXT_OFF.
       SCREEN-ACTIVE = '0'. MODIFY SCREEN.
      ENDIF.
    ELSEIF SCREEN-GROUP3 = 'LOW' OR SCREEN-GROUP3 = 'PAR'.
      READ TABLE CURRENT_SCREEN-OBLIGATORY
                          WITH KEY SCREEN-GROUP4 BINARY SEARCH
                          TRANSPORTING NO FIELDS.
      IF SY-SUBRC EQ 0.
       SCREEN-REQUIRED = '1'. MODIFY SCREEN.
      ENDIF.
      IF SY-SLSET NE SPACE AND SCREEN_PROGS-SUBMODE NE 'VC' AND
          ( SY-SUBCS = 'T' OR
           SY-BATCH = SPACE AND SY-SUBTY O CV_SUBTY_VIA_SELSCR ) AND
         SCREEN-GROUP3 = 'PAR' AND SCREEN-INVISIBLE = '1'.
        READ TABLE CURRENT_SCREEN-PARAMS
             WITH KEY NAME = SCREEN-NAME
             INTO L_PARAMS
             BINARY SEARCH.
        IF SY-SUBRC = 0 AND NOT L_PARAMS-SSCR-SPAGPA IS INITIAL.
          APPEND L_PARAMS-NAME TO NO_SPAGPA.
        ENDIF.
      ENDIF.
    ENDIF.

    CHECK SCREEN-GROUP3 = 'LOW' OR SCREEN-GROUP3 = 'HGH'.

 READ TABLE CURRENT_SCREEN-SELNUM WITH KEY SCREEN-GROUP4 BINARY SEARCH
         INTO L_SELNUM TRANSPORTING SELTABIX.
    CHECK SY-SUBRC = 0.
    READ TABLE CURRENT_SCREEN-SELOPTS INDEX L_SELNUM-SELTABIX
         INTO L_SELOPTS.
    CHECK SY-SUBRC = 0.
    IF SCREEN-GROUP3 = 'LOW'.
      MOVE SCREEN TO L_SELOPTS-SCREEN_LOW.
      IF SY-SLSET NE SPACE AND SCREEN_PROGS-SUBMODE NE 'VC' AND
          ( SY-SUBCS = 'T' OR
            SY-BATCH = SPACE AND SY-SUBTY O CV_SUBTY_VIA_SELSCR ) AND
            SCREEN-INVISIBLE = '1' AND
            NOT L_SELOPTS-SSCR-SPAGPA IS INITIAL.
        APPEND L_SELOPTS-NAME TO NO_SPAGPA.
      ENDIF.
    ELSE.
      MOVE SCREEN TO L_SELOPTS-SCREEN_HIGH.
    ENDIF.
 MODIFY CURRENT_SCREEN-SELOPTS INDEX L_SELNUM-SELTABIX FROM L_SELOPTS.

  ENDLOOP.

  SORT NO_SPAGPA.

  READ TABLE L_TO_TEXT_OFF INDEX 1.
  L_TABIX = 1.
  IF SY-SUBRC = 0.
    LOOP AT SCREEN.
      CHECK SCREEN-GROUP3 = 'TOT' AND
            SCREEN-GROUP4 = L_TO_TEXT_OFF-GROUP4.
      SCREEN-ACTIVE = '0'.
      MODIFY SCREEN.
      ADD 1 TO L_TABIX.
      READ TABLE L_TO_TEXT_OFF INDEX L_TABIX.
      IF SY-SUBRC NE 0.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF SCREEN_PROGS-DYNSEL = 'X'.
    perform set_quickinfo(saplssel) changing l_text.
    PERFORM SET_SSCRTEXTS_DYNSEL(RSDBSPDS) using l_text
        CHANGING <SSCRTEXTS>-DYNSEL.
  ENDIF.

* RESTRICT
  IF RESTRICT_FLAG NE SPACE.
    PERFORM RESTRICT_SCREEN_FROM_PROG(RSDBSPRE)
                                    TABLES   %_SSCR
                                    CHANGING CURRENT_SCREEN.
  ENDIF.

ENDFORM.                               "  MODIFY_SCREEN
* Paßt Bild 1000 (SUBMIT) an Varianten an
* Überprüft, ob Dynproversion stimmt
FORM CHECK_SCR_VERSION USING P_PROG LIKE SY-REPID
                             CHANGING P_TYPE LIKE SCR_RUNT_INFO-TYPE.

  DATA L_GEN_FLAG value 'X'.
  DATA L_DYNNR LIKE D020S-DNUM.
  DATA L_SUBRC LIKE SY-SUBRC.
  DATA L_TABIX LIKE SY-TABIX.
  DATA L_HEAD  LIKE RHEAD.       " Dummy

* Besorge Informationen über Selektionsbilder
* aus Namen des Dummyfeldes mit GROUP4 = 'SRI'.
* Überprüfe Versionsnummer des Dynpros
  CLEAR: SCR_RUNT_INFO-VERSION.
  MOVE 'N' TO SCR_RUNT_INFO-SELOPTS.

  LOOP AT SCREEN.
    CHECK SCREEN-GROUP4 = 'SRI'.    " SCREEN RUNTIME INFO
    MOVE SCREEN-NAME TO SCR_RUNT_INFO.
    IF SCR_RUNT_INFO-VERSION = VERSION.
      MOVE SPACE TO L_GEN_FLAG.
    ENDIF.
    EXIT.
  ENDLOOP.
* Eigentlich müßte die gesamte Initialisierung bei Neugenerierung
* wiederholt werden. Lohnt sich aber nicht

  IF L_GEN_FLAG NE SPACE and sy-batch is initial.
    PERFORM GEN_SEL_SCREEN(ZONPG_RSSYSTDB) TABLES   %_SSCR
*                                               1: Liefert Returncode.
                                     USING     P_PROG   1 L_HEAD
                            CHANGING L_DYNNR L_SUBRC.
    IF L_SUBRC NE 0.
      MESSAGE A006 WITH SY-CPROG L_DYNNR.
    ENDIF.
    COMMIT WORK.
    VERSION_NEW_GEN = 'X'.
    SET SCREEN SY-DYNNR. LEAVE SCREEN.
   ENDIF.

  READ TABLE SCREEN_PROGS WITH KEY P_PROG BINARY SEARCH
                       TRANSPORTING NO FIELDS.
  L_TABIX = SY-TABIX.
  IF SCR_RUNT_INFO-DYNSEL = 'X'.
    MOVE SCR_RUNT_INFO-DYNSEL TO SCREEN_PROGS-DYNSEL.
  ELSE.
    CLEAR SCREEN_PROGS-DYNSEL.
  ENDIF.
  MOVE SCR_RUNT_INFO-HASH TO SCREEN_PROGS-HASH.
  MODIFY SCREEN_PROGS INDEX L_TABIX TRANSPORTING DYNSEL HASH.

  P_TYPE = SCR_RUNT_INFO-TYPE.

ENDFORM.                                      " CHECK_SCR_VERSION.
* Wird bei CALL SELECTION-SCREEN zuerst gerufen.
* Setzt Kennzeichen. Dadurch kann als erstes bei PBO PUSH_SCREEN
* aufgerufen werden.
FORM NEW_CALL USING P_X_FROM P_Y_FROM
                    P_X_TO   P_Y_TO
                    P_VARIANT.

  DATA L_INT TYPE I.

  L_INT = P_X_FROM + P_Y_FROM + P_X_TO + P_Y_TO.

  IF L_INT = 0.
    NEW_CALL = 'C'.
  ELSE.
    NEW_CALL = 'P'.
  ENDIF.

  NEW_CALL_VARIANT = P_VARIANT.

*  CURRENT_SCR-UCOMM = <SSCRFIELDS>-UCOMM.

ENDFORM.
* Setzt aktuelles Bild als CURRENT_SCREEN.
* Pusht SCREEN_STACK
* Rettet bisheriges CURRENT_SCREEN.
FORM PUSH_SCREEN USING   VALUE(P_PROG)  LIKE SY-REPID
                         VALUE(P_LDBPG) LIKE SY-LDBPG
                         VALUE(P_DYNNR) LIKE SY-DYNNR
                         p_ucomm        type syucomm
                         P_NEW_CALL     LIKE NEW_CALL.

  DATA L_TABIX LIKE SY-TABIX.
  DATA L_TFILL LIKE SY-TFILL.
  DATA L_SUBRC LIKE SY-SUBRC.
  DATA L_INT TYPE I.
  DATA L_ANY_SELOPTS.
  data l_invisibles_inside.
  data l_scr type sydb0_scr_stack_line.

  IF NOT CURRENT_SCR-program IS INITIAL or
     not current_scr-last_subscreen_program is initial.
    IF CURRENT_SCR-MODE EQ 'J'.
      loop at ancestors_scr into l_scr.
*      APPEND PARENT_SCR TO SCR_STACK.
        append l_scr to scr_stack.
      endloop.
    ENDIF.
    CURRENT_SCR-UCOMM = p_UCOMM.
    APPEND CURRENT_SCR TO SCR_STACK.
    L_TFILL = SY-TABIX.
    IF CURRENT_SCR-MODE   EQ 'S'.
      SUBMIT_PHASE = PHASE.
      submit_subty = g_subty.
    ENDIF.
    l_invisibles_inside = current_scr-invisibles_inside.
    CLEAR: CURRENT_SCR, ancestors_scr.
  ENDIF.

* Neues Bild?
  IF P_PROG NE CURRENT_SCREEN-PROGRAM
    OR P_DYNNR NE CURRENT_SCREEN-DYNNR.
    IF NEW_CALL_VARIANT = SPACE.
      PERFORM SET_CURR_VSCR(RSDBSPVA) USING    P_PROG
                                               P_DYNNR
                                      CHANGING CURR_VSCR
                                               L_SUBRC.
    ELSE.
      CLEAR CURR_VSCR-VARIANT.
    ENDIF.
    IF CURRENT_SCREEN-PROGRAM NE SPACE AND
                         NOT CURRENT_SCREEN-DYNNR IS INITIAL.
      READ TABLE SCREENS WITH KEY PROGRAM = CURRENT_SCREEN-PROGRAM
                                  DYNNR   = CURRENT_SCREEN-DYNNR
                                  BINARY SEARCH
                 TRANSPORTING NO FIELDS.
      L_TABIX = SY-TABIX.
      IF SY-SUBRC NE 0.
        INSERT CURRENT_SCREEN INTO SCREENS INDEX L_TABIX.
      ELSE.
        MODIFY SCREENS FROM CURRENT_SCREEN INDEX L_TABIX TRANSPORTING
        SELOPTS.
      ENDIF.
    ENDIF.
    READ TABLE SCREENS WITH KEY PROGRAM = P_PROG
                                DYNNR   = P_DYNNR
                                BINARY SEARCH
               INTO CURRENT_SCREEN.
    L_TABIX = SY-TABIX.
    IF SY-SUBRC NE 0.
      PERFORM INIT_1_SCREEN USING P_PROG P_DYNNR P_LDBPG P_NEW_CALL.
    ENDIF.
  ENDIF.

  MOVE P_PROG TO:  CURRENT_SCR-PROGRAM.
  MOVE P_DYNNR TO: CURRENT_SCR-DYNNR.
  MOVE SY-SLSET TO CURRENT_SCR-PREV_SLSET.
  CURRENT_SCR-MODE   = P_NEW_CALL.
  IF SCREEN_PROGS-PROGRAM NE P_PROG.
    READ TABLE SCREEN_PROGS WITH KEY P_PROG BINARY SEARCH.
  ENDIF.
  IF CURR_VSCR-VARIANT NE SPACE.
    IF NOT ( SCREEN_PROGS-SUBMODE = 'I' AND P_NEW_CALL = 'S' ).
      SY-SLSET = CURR_VSCR-VARIANT.
    ENDIF.
    IF CURRENT_SCREEN-ANY_INVISIBLES NE SPACE or
         not l_invisibles_inside is initial.
      MOVE 'F' TO CURRENT_SCR-ALL_SELECTIONS.
    ENDIF.
  ELSEIF P_NEW_CALL NE 'S'.
    CLEAR SY-SLSET.
  ENDIF.
  SY-UCOMM = <SSCRFIELDS>-UCOMM.

  IF P_NEW_CALL NE 'S'.
    PERFORM FILL_EXCL_TAB.
     if sy-dynnr eq '0102' and p_prog eq 'SAPLSVAR'.
         perform adjust_excl_tab using space
                                   screen_progs-submode
                             changing current_scr-excl.
      endif.
"$$
"$$
"$$
"$$
  ENDIF.

  PERFORM PUSH_RESTORE(RSDBSPVA) USING CURRENT_SCR-PROGRAM L_TFILL.

  IF NEW_CALL_VARIANT NE SPACE.
    PERFORM IMPORT_VARI(RSDBSPVA) USING    P_PROG P_PROG
"$$
                                           NEW_CALL_VARIANT P_NEW_CALL
                                  CHANGING L_SUBRC.
    SY-SLSET = NEW_CALL_VARIANT.
  ENDIF.
  IF current_screen-PROGRAM ne 'SAPLSSEL' and dyns-selscreen_flag = 'X'.
    clear dyns-selscreen_flag.
  endif.


ENDFORM.                             " PUSH_SCREEN
* Popt SCREEN_STACK
* Restauriert vorheriges CURRENT_SCREEN.
FORM POP_SCREEN.

  DATA L_TABIX LIKE SY-TABIX.
  DATA L_TFILL LIKE SY-TFILL.
  DATA L_INT   TYPE I.
  DATA L_SUBRC LIKE SY-SUBRC.
  DATA L_SUBRC_2 LIKE SY-SUBRC.
  DATA L_VARI_PROGS LIKE SY-CPROG OCCURS 5 WITH HEADER LINE.
  DATA L_RESTORE LIKE RESTORE.
  data l_scr type sydb0_scr_stack_line.

  CASE <SSCRFIELDS>-UCOMM.
    WHEN 'CCAN' OR 'CEND' OR 'CBAC'.
      L_SUBRC = 4.
      IF VSCR_INDEX > 1.
        VSCR_INDEX = 1.
      ENDIF.
    WHEN 'NEXT' OR 'PREV'.
      IF NOT VSCREENS[] IS INITIAL AND CURRENT_SCREEN-PROGRAM NE
        'SAPLSVAR' AND CURRENT_SCREEN-DYNNR NE '0102'.
        READ TABLE VSCREENS WITH KEY DYNNR = CURRENT_SCREEN-DYNNR
                                     BINARY SEARCH
                   TRANSPORTING NO FIELDS.
        L_TABIX = SY-TABIX.
        IF SY-SUBRC = 0.
          DELETE VSCREENS INDEX L_TABIX.
        ENDIF.
      ENDIF.
      IF <SSCRFIELDS>-UCOMM = 'NEXT'.
        L_SUBRC = 1.
        IF VSCR_INDEX < VSCR_TFILL.
          ADD 1 TO VSCR_INDEX.
        ELSE.
          VSCR_INDEX = 1.
        ENDIF.
      ELSE.
        L_SUBRC = 2.
        IF VSCR_INDEX > 1.
          SUBTRACT 1 FROM VSCR_INDEX.
        ELSE.
          VSCR_INDEX = VSCR_TFILL.
        ENDIF.
      ENDIF.
    WHEN OTHERS.
      L_SUBRC = 0.
      IF VSCR_INDEX > 1.
        VSCR_INDEX = 1.
      ENDIF.
      CLEAR <SSCRFIELDS>-UCOMM.
  ENDCASE.

  DESCRIBE TABLE SCR_STACK LINES L_TFILL.

  IF L_SUBRC EQ 4.                        " Abbruch
    PERFORM RESTORE_VARIS(RSDBSPVA) CHANGING SCREENS
                                          CURRENT_SCREEN
                                          SCR_STACK
                                          CURRENT_SCR.
    SY-SLSET = CURRENT_SCR-PREV_SLSET.
  ELSE.
    IF L_TFILL > 0.
      PERFORM DRAG_RESTORE_DOWN(RSDBSPVA) USING CURRENT_SCR-PROGRAM
                                                L_TFILL.
    ELSE.
      REFRESH RESTORE.
    ENDIF.
  ENDIF.

  READ TABLE SCREENS WITH KEY PROGRAM = CURRENT_SCREEN-PROGRAM
                              DYNNR   = CURRENT_SCREEN-DYNNR
                              BINARY SEARCH
             TRANSPORTING NO FIELDS.
  L_TABIX = SY-TABIX.
  IF SY-SUBRC NE 0.
    INSERT CURRENT_SCREEN INTO SCREENS INDEX L_TABIX.
  ENDIF.

  IF L_TFILL > 0.
    READ TABLE SCR_STACK INTO CURRENT_SCR INDEX L_TFILL.
    DELETE SCR_STACK INDEX L_TFILL.
    clear ancestors_scr.
    IF CURRENT_SCR-MODE   EQ 'S'.
      PHASE = SUBMIT_PHASE.
      CLEAR   SUBMIT_PHASE.
      g_subty = submit_subty.
      clear     submit_subty.
    ELSEIF CURRENT_SCR-MODE EQ 'J'.
      do current_scr-ancestors times.
        L_TFILL = L_TFILL - 1.
        READ TABLE SCR_STACK INDEX L_TFILL INTO l_SCR.
        DELETE SCR_STACK INDEX L_TFILL.
        append l_scr to ancestors_scr.
      enddo.
      read table ancestors_scr into parent_scr index 1.
    ENDIF.
    if not current_scr-program is initial.
      IF CURRENT_SCR-PROGRAM NE CURRENT_SCREEN-PROGRAM OR
         CURRENT_SCR-DYNNR   NE CURRENT_SCREEN-DYNNR.
        IF CURRENT_SCR-PROGRAM NE CURRENT_SCREEN-PROGRAM.
          READ TABLE SCREEN_PROGS
               WITH KEY CURRENT_SCR-PROGRAM BINARY SEARCH.
          IF SY-SUBRC NE 0.
            MESSAGE A802.
          ENDIF.
          LAST_SSCR_PROG = CURRENT_SCR-PROGRAM.
          %_SSCR[] = SCREEN_PROGS-SSCR.
          PERFORM %_LINK_%_SSCR_WAS_%
              IN PROGRAM (CURRENT_SCR-PROGRAM)
              USING 'RSDBRUNT' 'TAKE_SSCR_WAS'        IF FOUND.
        ENDIF.
        READ TABLE SCREENS WITH KEY
                           PROGRAM = CURRENT_SCR-PROGRAM
                           DYNNR   = CURRENT_SCR-DYNNR
                           BINARY SEARCH
                           INTO CURRENT_SCREEN.
        IF SY-SUBRC NE 0.
          MESSAGE A802.
        ENDIF.
        PERFORM SET_CURR_VSCR(RSDBSPVA) USING    CURRENT_SCREEN-PROGRAM
                                                 CURRENT_SCREEN-DYNNR
                                        CHANGING CURR_VSCR
                                                 L_SUBRC_2.
        SY-SLSET = CURR_VSCR-VARIANT.
        PERFORM ADJUST_EXCL_TAB USING
          CURRENT_SCR-ALL_SELECTIONS SCREEN_PROGS-STATUS_SUBMODE
                                CHANGING CURRENT_SCR-EXCL.
      ENDIF.
      <SSCRFIELDS>-UCOMM = SY-UCOMM = CURRENT_SCR-UCOMM.
    else.
      CLEAR: CURRENT_SCREEN, <SSCRFIELDS>-UCOMM, SY-UCOMM,
             LAST_SSCR_PROG.
    endif.
  ELSE.
    CLEAR: CURRENT_SCR, CURRENT_SCREEN, <SSCRFIELDS>-UCOMM, SY-UCOMM,
           LAST_SSCR_PROG.
    PHASE = 99.
  ENDIF.

  SY-SUBRC = L_SUBRC.
  if current_screen-program = 'SAPLSSEL' and dyns-selscreen_flag = ' '.
    dyns-selscreen_flag = 'X'.
    perform take_sscr in program saplssel
                         tables %_sscr.
  endif.

ENDFORM.                             " Pop_SCREEN
* Gibt <SSCRFIELDS>-UCOMM zurück
FORM GET_UCOMM CHANGING P_UCOMM LIKE SSCRFIELDS-UCOMM.
  P_UCOMM = <SSCRFIELDS>-UCOMM.
ENDFORM.                                        " GET_UCOMM
* Setzt <SSCRFIELDS>-UCOMM
FORM SET_UCOMM USING P_UCOMM LIKE SSCRFIELDS-UCOMM.
  <SSCRFIELDS>-UCOMM = SY-UCOMM = P_UCOMM.
ENDFORM.                                        " SET_UCOMM
* SELTAB + FREE SELECTIONS
FORM HANDLE_SUBTY_WITH_SELTAB CHANGING P_SUBRC LIKE SY-SUBRC.

  IF SY-SUBTY O SUBTY_WITH_SELTAB.
    PERFORM IMPORT_SELTAB_FROM_MEM CHANGING P_SUBRC.
*   IF P_SUBRC >= 2.        " SELTAB nicht da
*     SYSTEM-CALL IMPORT SELECTIONS.    " WITH ...
*   ENDIF.
  ELSE.
    P_SUBRC = 4.
*   SYSTEM-CALL IMPORT SELECTIONS.    " WITH ...
  ENDIF.
  SYSTEM-CALL IMPORT SELECTIONS.    " WITH ...
ENDFORM.
* Besorge MORE-Ikonen
FORM GET_MORE_ICONS.

  DATA L_QUICK LIKE ICONT-QUICKINFO.

  CHECK VALU_ICONS-GREY IS INITIAL.

  MOVE 'Complex selections'(280) TO L_QUICK.
  CALL FUNCTION 'ICON_CREATE'
       EXPORTING
            NAME                  = 'ICON_ENTER_MORE'
            TEXT                  = ' '
            INFO                  = L_QUICK
       IMPORTING
            RESULT                = VALU_ICONS-GREY
       EXCEPTIONS
            ICON_NOT_FOUND        = 01
            OUTPUTFIELD_TOO_SHORT = 02.

  MOVE 'Complex selections (active)'(281) TO L_QUICK.
  CALL FUNCTION 'ICON_CREATE'
       EXPORTING
            NAME                  = 'ICON_DISPLAY_MORE'
            TEXT                  = ' '
            INFO                  = L_QUICK
       IMPORTING
            RESULT                = VALU_ICONS-GREEN
       EXCEPTIONS
            ICON_NOT_FOUND        = 01
            OUTPUTFIELD_TOO_SHORT = 02.

ENDFORM.
* Versorgt Textfelder für Indexselektion
* Wird einmal aus %_INIT_PBO (sysend.rs) gerufen
FORM %_IX_TEXTS USING P_IXFNAME.                                  "#EC *

  PERFORM %_IX_TEXTS(RSDBSPMC) USING    P_IXFNAME
                               CHANGING <SSCRTEXTS>.

ENDFORM.                           " %_IX_TEXTS
* Versorgt RSSELINT für Select-Options
* Schnittstelle: G_SELOPTS
FORM FILL_RSSELINT TABLES P_SELOPT
                   USING  P_SIGN P_OPTION P_LOW P_HIGH
                          P_DESC STRUCTURE RSSELINT P_SUBRC.

  MOVE G_SELOPTS-NAME TO P_DESC-NAME.
  MOVE G_SELOPTS-TEXT TO P_DESC-TEXT.
  MOVE TEXT-216 TO P_DESC-TO_TEXT.

ENDFORM.
* Versorgt Parameter-Text aus G_PARAMS-TEXT
* Schnittstelle: G_PARAMS
FORM FILL_PARAM_TEXT USING P_PARAM P_TEXT P_SUBRC.

  MOVE G_PARAMS-TEXT TO P_TEXT.

ENDFORM.
* Selektionstexte
FORM GET_SEL_TEXT USING    P_ID
                           P_NAME
                           P_PROG LIKE SY-REPID
                           P_SSCR LIKE RSSCR
                  CHANGING P_TEXT
                           P_SUBRC LIKE SY-SUBRC.

  DATA: BEGIN OF L_TEXTKEY,
          ID(1),
          NAME LIKE RSSCR-NAME,
        END   OF L_TEXTKEY.


  MOVE P_ID   TO L_TEXTKEY-ID.
  MOVE P_NAME TO L_TEXTKEY-NAME.

  SYSTEM-CALL INIT-TEXT P_TEXT USING L_TEXTKEY  PROGRAM P_PROG.
  P_SUBRC = SY-SUBRC.

  IF P_ID = 'S' AND P_TEXT = '%_DDIC' and p_sscr-flag2 z sscr_f2_dyn.
* No dynref get DDIC text as always
    PERFORM GET_DD_TEXT(RSDBSPDD) USING P_SSCR CHANGING P_TEXT.
* dynref : handle text in get_ref_field
  elseif P_ID = 'S' AND P_TEXT = '%_DDIC' and p_sscr-flag2 o sscr_f2_dyn.
     p_subrc = 1.
     return.
  ENDIF.

ENDFORM.

*----------------------------------------------------------------------*
*                       OK-Code Module                                 *
*----------------------------------------------------------------------*

* Wird bei PAI auf Selektionsbild gerufen
FORM %_OK_CODE_1000.                                              "#EC *

  DATA L_SELNUM(3) TYPE N.
  DATA L_SELNAME(8).
  DATA L_SUBRC LIKE SY-SUBRC.
  DATA L_FCODE(4).
  DATA L_TABIX LIKE SY-TABIX.
  DATA L_JUST_DISPLAY.
  DATA L_TABS TYPE SYDB0_TABS.
  data l_flag.

  DATA L_SPFLAG.
  data l_cursor_field like screen-name.

  FIELD-SYMBOLS <L_TEXT>.

  CLEAR SY-SUBRC.

  GET CURSOR FIELD l_CURSOR_FIELD.
  if l_cursor_field ne space.
    cursor-field = l_CURSOR_FIELD.
    cursor-prog = current_screen-program.
    cursor-dynnr = current_screen-dynnr.
  endif.

  IF CURRENT_SCR-MODE EQ 'J'.
     PERFORM OK_CODE_J.
     EXIT.
  ENDIF.
  IF <SSCRFIELDS>-UCOMM = 'VBAC'.
     PERFORM BACK_1000_V(RSDBSPVA) TABLES %_SSCR
                                   USING    SCREEN_PROGS-STATUS_SUBMODE
                                            DYN_SEL-TEXPR
                                            %_RKEY
                                   CHANGING <SSCRFIELDS>-UCOMM.
  ENDIF.

  CASE <SSCRFIELDS>-UCOMM(4).
    WHEN SPACE.
      SET SCREEN SY-DYNNR.
    WHEN 'ONLI'.                 " Ausführen
      PERFORM %_START_REPORT USING G_SUBTY.
    WHEN 'PRIN'.                 " Drucken
      MOVE 'RSDBRUNT' TO SY-CALLR.
      CALL FUNCTION 'PRINT_REPORT'
           EXPORTING REPORT = SY-CPROG
           IMPORTING STATUS = <SSCRFIELDS>-UCOMM.
      SY-UCOMM = <SSCRFIELDS>-UCOMM.
      IF <SSCRFIELDS>-UCOMM = 'PRIN'.
        PERFORM %_START_REPORT USING G_SUBTY.
      ENDIF.
    WHEN 'ALLS'.
      PERFORM HANDLE_INVISIBLES USING 'A'.
      SET SCREEN SY-DYNNR.
    WHEN 'FEWS'.
      PERFORM HANDLE_INVISIBLES USING 'F'.
      SET SCREEN SY-DYNNR.
    WHEN 'JOBS'. PERFORM SUBMIT_JOB(RSDBSPJS) TABLES DYNS_FIELDS
                                          USING  SY-CPROG G_SUBTY SPACE.
    WHEN 'SJOB'. PERFORM SUBMIT_JOB(RSDBSPJS) TABLES DYNS_FIELDS
                                          USING  SY-CPROG G_SUBTY 'X'.
    " Varianten
    WHEN 'GET ' OR 'VDEL' OR 'VSHO' OR 'SAVE' OR 'SPOS' OR
         'SALE' OR 'GOON' OR 'VATT' OR 'PREV' OR 'NEXT' OR 'RWCV'.
      if SCREEN_PROGS-VARIPROG ne 'SAPLSSEL' .
        %_RKEY-REPORT = SCREEN_PROGS-VARIPROG.
      endif.
      IF <SSCRFIELDS>-UCOMM = 'NEXT' OR <SSCRFIELDS>-UCOMM = 'PREV'.
        CLEAR CURSOR.
      ENDIF.
      PERFORM OK_CODE_1000(RSDBSPVA) TABLES   %_SSCR
                                     USING    DYN_SEL-TEXPR
                                     CHANGING <SSCRFIELDS>-UCOMM
                                              %_RKEY.
      EXIT.
    WHEN 'DYNS'.             " Dynamische Selektion

      perform get_dyn_screen_active in program saplssel
                using l_flag.
      if l_flag eq space.
        PERFORM DYNS_DIALOG(RSDBSPDS) TABLES   %_SSCR
                                      using 'X'
                                      CHANGING <SSCRFIELDS>-UCOMM.
      endif.

    WHEN 'LVUV'.             " Liste Benutzervariable
      PERFORM EXECUTE_LVUV(RSDBSPUV) USING CURRENT_SCREEN.
    WHEN 'CRET'.             " Zurück von CALL SEL-SCREEN
      CLEAR: SY-UCOMM.
      CLEAR: <SSCRFIELDS>-UCOMM.
      SET SCREEN 0.
      LEAVE SCREEN.
    when 'INTV'.
*       set screen 100. leave screen.
    WHEN 'CXSP'.             " Complex Search Pattern
      PERFORM COMPLEX_SP(RSDBSPMC).
        CLEAR: SY-UCOMM.
        CLEAR: <SSCRFIELDS>-UCOMM.
    WHEN OTHERS.
      IF <SSCRFIELDS>-UCOMM(1) = '%' and not
         <SSCRFIELDS>-UCOMM(2) = '%_'  and
         <sscrfields>-ucomm+4(4) is initial.
        PERFORM MULTIPLE_SELECTIONS USING CURRENT_SCREEN-PROGRAM.
        CLEAR: SY-UCOMM.
        CLEAR: <SSCRFIELDS>-UCOMM.
      ELSE.
        READ TABLE CURRENT_SCREEN-TABS
             WITH KEY FCODE = <SSCRFIELDS>-UCOMM
             BINARY SEARCH INTO L_TABS.
         IF SY-SUBRC EQ 0.
           PERFORM SUPPLY_TAB_INFO USING L_TABS.
         ENDIF.
      ENDIF.
  ENDCASE.
  CLEAR: SY-UCOMM.
  CLEAR: <SSCRFIELDS>-UCOMM.
ENDFORM.                                "%_OK_CODE_1000
* EXIT-Commands auf Selektionsbild
FORM %_BACK_1000.                                                 "#EC *
  data l_spflag.
* SUBTY-Handling, da bei EXIT-COMMAND INIT_PAI nict durchlaufen wird
* G_SUBTY = SY-SUBTY.
  IF SY-SUBTY Z CV_SUBTY_VIA_SELSCR.
    ADD CV_SUBTY_VIA_SELSCR TO SY-SUBTY.
  ENDIF.
* AT SELECTION-SCREEN ON EXIT-COMMAND
  PERFORM %_SEL_SCREEN_%_EXCOM_% IN PROGRAM (CURRENT_SCREEN-PROGRAM)
          IF FOUND.
  CASE <SSCRFIELDS>-UCOMM.
*    WHEN 'VSHO'.
*      PERFORM %_OK_CODE_1000.
*      SET SCREEN SY-DYNNR.
*    WHEN 'VDEL'.
*      PERFORM %_OK_CODE_1000.
*      SET SCREEN SY-DYNNR.
    WHEN 'GET' or 'VSHO' or 'VDEL'.
      %_RKEY-REPORT = SCREEN_PROGS-VARIPROG.
      PERFORM OK_CODE_1000(RSDBSPVA) TABLES   %_SSCR
                                     USING    DYN_SEL-TEXPR
                                     CHANGING <SSCRFIELDS>-UCOMM
                                              %_RKEY.
*      PERFORM %_OK_CODE_1000.
*      SET SCREEN SY-DYNNR.
      IF <SSCRFIELDS>-UCOMM EQ 'GET'.
*       CLEAR : <SSCRFIELDS>-UCOMM, SY-UCOMM.
        if current_scr-mode = 'J'.
          perform return_from_subscreen_pai.
        endif.
        LEAVE SCREEN.
      ENDIF.
      CLEAR : <SSCRFIELDS>-UCOMM, SY-UCOMM.
    WHEN 'SCRH' OR 'DOCU'.
      IF SY-SUBTY Z SUBTY_NO_SELSCREEN AND SY-SUBTY O SUBTY_TO_SAPSPOOL.
        L_SPFLAG = 'X'.
        SUBTRACT SUBTY_TO_SAPSPOOL FROM SY-SUBTY.
      ENDIF.
      IF <SSCRFIELDS>-UCOMM(4) = 'SCRH'.
        CALL FUNCTION 'RS_HELP_SELSCREEN'
            EXPORTING   SCREEN   = '1000'
                      SITUATION = SCREEN_PROGS-SUBMODE
            EXCEPTIONS ERROR_MESSAGE   = 8
                       OTHERS          = 8.
      ELSE.
        CALL FUNCTION 'DSYS_SHOW_FOR_F1HELP'
             EXPORTING
                  DOKCLASS           = 'RE'
                  DOKNAME            = CURRENT_SCR-PROGRAM
                  SHORT_TEXT         = 'X'
             EXCEPTIONS
                  OTHERS             = 1.
      ENDIF.
      IF L_SPFLAG NE SPACE.
        ADD SUBTY_TO_SAPSPOOL TO SY-SUBTY.
      ENDIF.
      if current_scr-mode = 'J'.
        perform return_from_subscreen_pai.
      endif.
*      PERFORM %_OK_CODE_1000.
*      SET SCREEN SY-DYNNR.
    WHEN 'DCAN' OR 'DEND'.
      PERFORM %_SEL_SCREEN IN PROGRAM (CURRENT_SCREEN-PROGRAM) IF FOUND.
    WHEN 'CCAN' OR 'CEND' OR 'CBAC'.
      IF CURRENT_SCR-MODE = 'X'.
        PERFORM POP_SCREEN.
      ENDIF.
      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN 'UCAN'.
      PERFORM BACK_1000(RSDBSPUV) CHANGING <SSCRFIELDS>-UCOMM.
    WHEN OTHERS.
      IF SCREEN_PROGS-SUBMODE(1) = 'V'.
        PERFORM BACK_1000_V(RSDBSPVA) TABLES %_SSCR
                                   USING    SCREEN_PROGS-STATUS_SUBMODE
                                               DYN_SEL-TEXPR
*                                              DYNS_TEXPR_OLD
                                               %_RKEY
                                      CHANGING <SSCRFIELDS>-UCOMM.
        EXIT.
      ENDIF.
      IF SCREEN_PROGS-SUBMODE(1) = 'J'.
        RSJOBINFO-JOBSUBRC = 4.
        EXPORT RSJOBINFO-JOBSUBRC TO MEMORY ID '%_JOBINFO'.
      ENDIF.
      LEAVE PROGRAM.
  ENDCASE.
ENDFORM.

* Wird am Ende der Selektionsbildverarbeitung gerufen,
* wenn SY-UCOMM = 'ONLI' oder SY-UCOMM = 'PRIN'.
* Aufruf aus %_OK_CODE_1000 (<REPINI>)
FORM %_START_REPORT USING P_SUBTY LIKE SY-SUBTY.                  "#EC *

  DATA MODE(10) TYPE N.
  DATA L_SUBRC LIKE SY-SUBRC.
  data l_prog type sy-repid.
  CONSTANTS L_WWW_MODE_SET TYPE I VALUE 1.
  CONSTANTS L_WWW_STATE_TEMP TYPE I VALUE 99.

  system-call set_kernel_info 'LIST_TO_MEMORY' submit_info-list_2_mem.

  IF P_SUBTY O CV_SUBTY_VIA_SELSCR AND
     ( SY-BATCH = SPACE OR SY-BINPT NE SPACE ).
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
"$$
    PERFORM EXPORT_VAR_2_MEM USING SY-CPROG.
"$$
"$$
    data skip_selscr type c length 1.
    import skip_selscr = skip_selscr from memory id  '%_NO_RET_TO_SELSCR_%'.

    data sp type syldb_sp.
    data selopts type standard table of rsparams.
    data selopts_255 type standard table of rsparamsl_255.
    data dyn_sels type rsds_trange.
    if skip_selscr is not initial.
      skip_selscr = 'L'.

      call function 'RS_REFRESH_FROM_SELECTOPTIONS'
        exporting
         curr_report         = memkey-report    " Programm für den Sel. angezeigt werden sollen
        importing
         sp                  = sp    " Programm für den Sel. angezeigt werden sollen
       tables
        selection_table     = selopts    " Tabelle mit Ranges-Struktur die Sel. enthält.
        selection_table_255 = selopts_255
       exceptions
        others              = 0.

       call function 'RS_REFRESH_FROM_DYNAMICAL_SEL'
         exporting
           curr_report        = memkey-report      " Reportname
           mode_write_or_move = 'M'    " Parameter für Brepi_dyn
         importing
           p_trange           = dyn_sels    " Muß(!) Typ RSDS_TRANGE haben!
         exceptions
           others             = 0.

         export skip_selscr = skip_selscr
                selopts     = selopts
                selopts_255 = selopts_255
                sp      = sp
                dyn_sels = dyn_sels
               to memory id  '%_NO_RET_TO_SELSCR_%'.
    endif.

"$$
  ELSE.
    CLEAR MEMKEY.
  ENDIF.
* Übernahme reportspezifische SELECT-OPTIONS in WHERE-Klauseln
* Muß nach EXPORT_VAR_TO_MEM_STATIC erfolgen.
  IF SELOPTS_AS_DB_SEL NE SPACE.
    CALL FUNCTION 'RS_DS_INT_AS_DB_SELECTION'
         EXPORTING
              SELECTION_ID    = DYNS-SELID
              PROGRAM         = SY-CPROG
         IMPORTING
              WHERE_CLAUSES   = DYN_SEL-CLAUSES
              FIELD_RANGES    = DYN_SEL-TRANGE
         TABLES
              P_SSCR          = %_SSCR
         EXCEPTIONS
              OTHERS = 0.
  ENDIF.

  PERFORM POP_SCREEN.
  IF NOT WWW_SUBMIT IS INITIAL.
     SYSTEM-CALL WEBRFC MODE L_WWW_MODE_SET STATE L_WWW_STATE_TEMP.
     CLEAR WWW_SUBMIT.
  ENDIF.
  CLEAR: <SSCRFIELDS>-UCOMM, SY-UCOMM.
  PHASE = 99.
  SET SCREEN 0. LEAVE SCREEN.     " Geht zum Glück auch in ext. PERF.
ENDFORM.                                " %_START_REPORT.
* Aufruf 'Mehrfachselektion' + Vorbereitung.
FORM MULTIPLE_SELECTIONS USING P_PROG LIKE SY-REPID.

  DATA L_TABIX LIKE SY-TABIX.
  DATA L_JUST_DISPLAY.
  DATA L_SELNUM TYPE SYDB0_SELNUM.
  DATA L_SELOPTS TYPE SYDB0_SELOPTS.
  DATA: L_NOINT_CHECK.
  DATA L_SPFLAG.
  DATA: L_DYNS_SCREEN_SAVE.

  FIELD-SYMBOLS: <L_CONVERT> LIKE RSCONVERT,
                 <L_DYNREF> TYPE SYDB0_DYNREF.

  READ TABLE CURRENT_SCREEN-SELNUM INTO L_SELNUM
                  WITH KEY <SSCRFIELDS>-UCOMM+1(3) BINARY SEARCH.

  CHECK SY-SUBRC = 0.
  L_TABIX = SY-TABIX.
  READ TABLE CURRENT_SCREEN-SELOPTS INTO L_SELOPTS
             INDEX L_SELNUM-SELTABIX.
  CHECK SY-SUBRC = 0.
  IF L_SELOPTS-NOINT_CHECK NE SPACE OR RSVUVINT-NO_INT_CHK NE SPACE.
     L_NOINT_CHECK = 'X'.
  ENDIF.
  PERFORM CHECK_SELOPT_DISPLAY USING    CURRENT_SCREEN-INACTIVE
                                        L_SELOPTS
                               CHANGING l_JUST_DISPLAY.
  READ TABLE CURRENT_SCREEN-NOINTERVALS WITH KEY L_SELNUM-NUMB
        BINARY SEARCH TRANSPORTING NO FIELDS.
  IF SY-SUBRC = 0.
* Über Variante High-Feld ausgeblendet
    L_SELOPTS-SCREEN_HIGH-INVISIBLE = '0'.
  ENDIF.
  if not DYNS-SELSCREEN_FLAG is initial.    " Free Selections?
    L_DYNS_SCREEN_SAVE = DYNS-SELSCREEN_FLAG.
    CLEAR DYNS-SELSCREEN_FLAG.
    perform complex_selections_2 in program saplssel
            using l_selopts.
    DYNS-SELSCREEN_FLAG = L_DYNS_SCREEN_SAVE.
    exit.
  ENDIF.
  IF L_SELOPTS-SSCR-FLAG2 Z SSCR_F2_DYN.
    PERFORM FILL_CONVERT USING L_TABIX L_SELOPTS-SSCR
                         CHANGING L_SELNUM.
    ASSIGN L_SELNUM-CONVERT TO <L_CONVERT>.
  ELSE.
    READ TABLE SCREEN_PROGS-DYNREF WITH KEY NAME = L_SELOPTS-NAME
         BINARY SEARCH
         ASSIGNING <L_DYNREF>.
    IF SY-SUBRC = 0.
      ASSIGN <L_DYNREF>-CONVERT TO <L_CONVERT>.
    ELSE.
      ASSIGN L_SELNUM-CONVERT TO <L_CONVERT>.
    ENDIF.
  ENDIF.

  COMPLEX_SELECTION = 'X'.

  IF SY-SUBTY Z SUBTY_NO_SELSCREEN AND SY-SUBTY O SUBTY_TO_SAPSPOOL.
    L_SPFLAG = 'X'.
    SUBTRACT SUBTY_TO_SAPSPOOL FROM SY-SUBTY.
  ENDIF.

  export sscrindex = L_SELOPTS-SSCRIX to memory id '%_COMPL_SSCRINDX'.

  CALL FUNCTION 'RS_COMPLEX_SELECTION'
       EXPORTING
            P_SSCR         = L_SELOPTS-SSCR
            P_REPORT       = P_PROG
            P_SCREEN_LOW   = L_SELOPTS-SCREEN_LOW
            P_SCREEN_HIGH  = L_SELOPTS-SCREEN_HIGH
            P_SSCR_INDEX   = L_SELOPTS-SSCRIX
            P_JUST_DISPLAY = L_JUST_DISPLAY
            P_NO_INT_CHK   = L_NOINT_CHECK
            P_CONVERT      = <L_CONVERT>
            OPTIONS             = L_SELOPTS-X_ADDY_OPTIONS
            SIGNS_RESTRICTION   = L_SELOPTS-SG_ADDY
            P_FREE_SELECTIONS   = DYNS-SELSCREEN_FLAG
       EXCEPTIONS
            CANCELLED      = 1
            OTHERS         = 1.

  IF L_SPFLAG NE SPACE.
    ADD SUBTY_TO_SAPSPOOL TO SY-SUBTY.
  ENDIF.
  IF SY-SUBRC NE 0 AND L_JUST_DISPLAY = SPACE.
    MESSAGE S781.
  ENDIF.

  free MEMORY ID '%_COMPL_SSCRINDX'.

  CLEAR COMPLEX_SELECTION.

ENDFORM.

* Ruft Funktionsbaustein zur SUBMIT-Berechtigungsprüfung auf
* Wird aus %_INIT_PBO_FIRST gerufen
FORM %_AUTH_SUBMIT USING P_VARIANT P_SECU P_SSET.                 "#EC *

* check sy-uname ne 'SAPSYS'.
* Wozu dient die Abfrage auf den Benutzer SAPSYS ??? Da wir das nicht
* wissen, erfolgt auch weiterhin eine Spezialbehandlung für diese
* Userid.
  IF SY-UNAME = 'SAPSYS'.
    CALL FUNCTION 'RSAU_WRITE_SUBMIT_AUDIT_LOG'
         EXPORTING
              PROGNAME           = SY-CPROG
              SUBMIT_OK          = 'X'
         EXCEPTIONS
              OTHERS             = 1.
    EXIT.
  ENDIF.

  CALL FUNCTION 'RS_ABAPSUBMIT_AUTH_INTERN'
         EXPORTING
               PROGNAME    = SY-CPROG
               SECU        = P_SECU
               SSET        = P_SSET
               VARIANT     = P_VARIANT
         EXCEPTIONS
               NO_SUBMIT_AUTH     = 1
               CUSTOMER_EXCEPTION = 2
               OTHERS             = 10.
  CASE SY-SUBRC.
    WHEN 0.
      CALL FUNCTION 'RSAU_WRITE_SUBMIT_AUDIT_LOG'
           EXPORTING
                PROGNAME           = SY-CPROG
                SUBMIT_OK          = 'X'
           EXCEPTIONS
                OTHERS             = 1.

    WHEN 1. "no_submit_auth
      CALL FUNCTION 'RSAU_WRITE_SUBMIT_AUDIT_LOG'
           EXPORTING
                PROGNAME           = SY-CPROG
                NO_SUBMIT_AUTH     = 'X'
           EXCEPTIONS
                OTHERS             = 1.

      MESSAGE A645 WITH P_SECU SY-CPROG.
    WHEN 2. "customer_exception
      CALL FUNCTION 'RSAU_WRITE_SUBMIT_AUDIT_LOG'
           EXPORTING
                PROGNAME           = SY-CPROG
                CUSTOMER_EXCEPTION = 'X'
           EXCEPTIONS
                OTHERS             = 1.

      MESSAGE ID SY-MSGID TYPE 'A' NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDCASE.

ENDFORM.
* Wird jedesmal bei PBO gerufen:
* Nach AT SELECTION-SCREEN OUTPUT, vor den SHOW_TAB-Aufrufen.
FORM SET_PF_STATUS.

  " eigener Status fuer 1000 gesetzt ?
  IF CURRENT_SCR-MODE NE 'J'.
  IF CURRENT_SCR-STATUS = SPACE.
    CURRENT_SCR-GUI_PROG = CURRENT_SCR-PROGRAM.
    IF CURRENT_SCR-MODE   EQ 'S'.
      CASE SCREEN_PROGS-SUBMODE.
        WHEN 'VC'.
          CURRENT_SCR-STATUS = '%_VC'.
        WHEN 'VU'.
          CURRENT_SCR-STATUS = '%_VC'.
        WHEN 'JA'.
          CURRENT_SCR-STATUS = '%_JA'.
        WHEN 'JB'.
          CURRENT_SCR-STATUS = '%_JB'.
        WHEN OTHERS.
          IF NOT SY-PFKEY IS INITIAL.
            CURRENT_SCR-STATUS = SY-PFKEY.
          ELSE.
            CURRENT_SCR-STATUS = '%_00'.
          ENDIF.
      ENDCASE.
    ELSEIF SCREEN_PROGS-SUBMODE(1) NE 'V'.
      IF CURRENT_SCR-POPUP = SPACE.
        CURRENT_SCR-STATUS = '%_CS'.
      ELSE.
        CURRENT_SCR-STATUS = '%_CSP'.
      ENDIF.
    ELSE.
      IF CURRENT_SCR-POPUP = SPACE.
        CURRENT_SCR-STATUS = '%_VC'.
      ELSE.
        CURRENT_SCR-STATUS = '%_VCP'.
      ENDIF.
    ENDIF.
  ENDIF.
  PERFORM SET_GUI_STATUS USING CURRENT_SCR-STATUS.
  ENDIF.
  PERFORM SET_ACTIVE_TAB.
  PERFORM MODIFY_SCREEN.
ENDFORM.                               "SET_PF_STATUS

* Cleart die bei REJECT '<Tab>' überhüpften Tabellen mit Hexnullen.
FORM %_CLEAR_REJ_TABS USING CURRTAB REJTAB.                       "#EC *

  DATA L_REJTAB(10).
  DATA L_LENGTH LIKE SY-FLENG.

  FIELD-SYMBOLS <F>.
  CHECK SY-LDBPG NE SPACE.

  L_REJTAB = REJTAB.

  DESCRIBE TABLE %_LDB_STRUC LINES SY-TFILL.
  IF SY-TFILL = 0.
    PERFORM %_INIT_LDB_STRUC IN PROGRAM (SY-LDBPG) TABLES %_LDB_STRUC
            IF FOUND.
    SORT %_LDB_STRUC BY CHILD.
  ENDIF.

  CHECK REJTAB NE CURRTAB.
  MOVE CURRTAB TO %_LDB_STRUC-CHILD.
  DO.
    ASSIGN TABLE FIELD (%_LDB_STRUC-CHILD) TO <F>.
    IF SY-SUBRC = 0.
      CLEAR <F> WITH NULL.
    ENDIF.
    READ TABLE %_LDB_STRUC WITH KEY %_LDB_STRUC-CHILD BINARY SEARCH.
    IF SY-SUBRC NE 0.
      EXIT.
    ENDIF.
    IF %_LDB_STRUC-PARENT = SPACE OR %_LDB_STRUC-PARENT = REJTAB.
      EXIT.
    ENDIF.
    MOVE %_LDB_STRUC-PARENT TO %_LDB_STRUC-CHILD.
  ENDDO.

  DESCRIBE FIELD REJTAB LENGTH L_LENGTH in character mode.
  IF L_LENGTH > 10.
    L_LENGTH = 10.
  ENDIF.
  ASSIGN REJTAB(L_LENGTH) TO <F>.

  IF L_REJTAB NE <F>. " Feld wurde verändert (d.h. WA wurde angegeben)
    REJTAB = L_REJTAB.   " ==> richtiger Inhalt in RABAX
  ENDIF.

ENDFORM.                 " %_CLEAR_REJ_TABS

FORM %_LDB_CALLBACK USING P_NODENAME                              "#EC *
                          P_NODE_WA
                          P_G_OR_L
                          P_SELECTED.

  DATA L_CALLBACK LIKE LDBCB.

  READ TABLE CURR_LDB-CALLBACK INTO L_CALLBACK
       WITH KEY P_NODENAME BINARY SEARCH.
  CHECK SY-SUBRC = 0.
  IF P_G_OR_L = 'L'.
    CHECK L_CALLBACK-GET_LATE NE SPACE.
  ELSE.
    CHECK L_CALLBACK-GET NE SPACE.
  ENDIF.

  PERFORM (L_CALLBACK-CB_FORM) IN PROGRAM (L_CALLBACK-CB_PROG)
            USING P_NODENAME P_NODE_WA P_G_OR_L P_SELECTED.

ENDFORM.

FORM PUSH_LDB TABLES P_CALLBACK STRUCTURE LDBCB
              USING  P_LDBPG    LIKE SY-LDBPG
                     P_SUBRC LIKE SY-SUBRC.

  IF CURR_LDB-LDBPG = P_LDBPG.
    P_SUBRC = 1.
    EXIT.
  ENDIF.

  READ TABLE LDB_STACK WITH KEY P_LDBPG
                       TRANSPORTING NO FIELDS.
  IF SY-SUBRC = 0.
    P_SUBRC = 1.
    EXIT.
  ENDIF.

  IF NOT CURR_LDB IS INITIAL OR NOT DYN_SEL IS INITIAL.
    CURR_LDB-DYN_SEL     = DYN_SEL.
    CURR_LDB-DYNS_FIELDS = DYNS_FIELDS[].
    CURR_LDB-SELECT_FIELDS = SELECT_FIELDS.
    INSERT CURR_LDB INTO LDB_STACK INDEX 1.
  ENDIF.
  CLEAR CURR_LDB.
  CURR_LDB-LDBPG = P_LDBPG.
  CURR_LDB-CALLBACK = P_CALLBACK[].
  SORT CURR_LDB-CALLBACK BY LDBNODE.

  PERFORM PUSH_SP(RSDBSPMC) USING P_LDBPG.

ENDFORM.

* Wird aus %_ROOT (sysend.rs1) gerufen
FORM POP_LDB.

  IF NOT CURR_LDB-LDBPG IS INITIAL.
    PERFORM POP_LDB(SAPLSSEL) USING CURR_LDB-LDBPG IF FOUND.
  ENDIF.

  READ TABLE LDB_STACK INTO CURR_LDB INDEX 1.
  IF SY-SUBRC NE 0.
    IF CURR_LDB-SUBMIT IS INITIAL.  " Nach LDB_PROCESS: alle Spuren weg
      CLEAR: DYN_SEL, DYNS_FIELDS[].
    ENDIF.
    CLEAR: CURR_LDB.
  ELSE.
    DYN_SEL       = CURR_LDB-DYN_SEL.
    DYNS_FIELDS[] = CURR_LDB-DYNS_FIELDS.
    SELECT_FIELDS = CURR_LDB-SELECT_FIELDS.
    DELETE LDB_STACK INDEX 1.
  ENDIF.

  PERFORM POP_SP(RSDBSPMC).

ENDFORM.


FORM %_RETURN_TO_SELSCREEN.                                       "#EC *

  IF MEMKEY-REPORT NE SPACE.
    data skip_selscr type c length 1.
    import skip_selscr = skip_selscr from memory id  '%_NO_RET_TO_SELSCR_%'.

    if not ( submit_info-via_selscr = 'X' and submit_info-list_2_mem = 'X' and
             skip_selscr is not initial ).
    SUBMIT (MEMKEY-REPORT) VIA SELECTION-SCREEN
                      %_INTERNAL_%_SUBMODE_% MEMKEY-INT_MODE
                      USING SELECTION-SCREEN SUBMIT_SCREEN
                      USING SELECTION-SET MEMKEY-VARIANT.
   else.
     leave program.
   endif.
  ENDIF.

ENDFORM.
* Wird aus RS_SUBMIT_MODE gerufen; besorgt Laufzeitinformationen
FORM %_GET_SUBMIT_INFO USING P_SUB_INFO STRUCTURE RSSUBINFO.      "#EC *
  PERFORM PROVIDE_SUBMIT_INFO_02.
  P_SUB_INFO = SUBMIT_INFO.
ENDFORM.
* Wird aus %_INIT_PBO_FIRST gerufen. Setzt Teile von SUBMIT_INFO
FORM PROVIDE_SUBMIT_INFO_01.

  DATA L_VIASELSCRN TYPE X VALUE '04'.

  CLEAR SUBMIT_INFO.

  CASE SCREEN_PROGS-SUBMODE(1).
    WHEN 'V'.
      MOVE 'X' TO SUBMIT_INFO-MODE_VARI.
    WHEN 'J'.
      MOVE 'X' TO SUBMIT_INFO-MODE_JOB.
    WHEN OTHERS.                           " Blank oder Ziffer
      MOVE 'X' TO SUBMIT_INFO-MODE_NORML.
  ENDCASE.

  IF SY-SUBTY O L_VIASELSCRN.
    MOVE 'X' TO SUBMIT_INFO-VIA_SELSCR.
  ENDIF.

  SYSTEM-CALL KERNEL_INFO 'LIST_TO_MEMORY'  SUBMIT_INFO-LIST_2_MEM.
  SYSTEM-CALL KERNEL_INFO 'IS_MODE_CALLED'  SUBMIT_INFO-MODE_CALLD.

ENDFORM.                    " PROVIDE_SUBMIT_INFO_01

* Wird aus %_INIT_PAI gerufen. Setzt Teile von SUBMIT_INFO
FORM PROVIDE_SUBMIT_INFO_02.

  CLEAR: SUBMIT_INFO-SELPARNAME, SUBMIT_INFO-SELS_HIDDN.

  IF CURRENT_SCR-ALL_SELECTIONS = 'F'.
    SUBMIT_INFO-SELS_HIDDN = 'X'.
  ENDIF.

  CASE <SSCRFIELDS>-UCOMM.
    WHEN 'DELS'.
      SUBMIT_INFO-SELPARNAME = CURRENT_SCR-PICK-FIELD.
    WHEN 'DELA'.
      SUBMIT_INFO-SELPARNAME = CURRENT_SCR-PICK-FIELD.
    when fdelline.
      SUBMIT_INFO-SELPARNAME = context_struc-name.
    when fdelall.
      SUBMIT_INFO-SELPARNAME = context_struc-name.
    WHEN 'OPTI'.
      SUBMIT_INFO-SELPARNAME = CURRENT_SCR-PICK-FIELD.
    WHEN OTHERS.
      IF <SSCRFIELDS>-UCOMM(1) = '%' and not
         <SSCRFIELDS>-UCOMM(2) = '%_' .
        SUBMIT_INFO-SELPARNAME = CURRENT_SCR-PICK-FIELD.
      ENDIF.
  ENDCASE.
  IF NOT WWW_SUBMIT IS INITIAL.
     SUBMIT_INFO-WWW_ACTIVE = 'X'.
  ELSE.
   SYSTEM-CALL KERNEL_INFO 'CALLED_FROM_WWW' SUBMIT_INFO-WWW_ACTIVE.
  ENDIF.
ENDFORM.                    " PROVIDE_SUBMIT_INFO_02
* Wird aus RS_SET_SELSCREEN_STATUS gerufen: eigener PF-Status
FORM SET_USER_STATUS TABLES P_EXCLUDE
                     USING P_STATUS LIKE SY-PFKEY
                           P_PROG   LIKE SY-REPID.

  DATA L_ANY_SELOPTS.
  DATA L_TABIX LIKE SY-TABIX.
  DATA L_FCODE LIKE RSEXFCODE-FCODE.

  check current_scr-mode ne 'J'.
  current_scr-usr_excl = p_exclude[].
  SORT CURRENT_SCR-USR_EXCL.

  PERFORM FILL_EXCL_TAB.
  PERFORM ADJUST_EXCL_TAB USING
    CURRENT_SCR-ALL_SELECTIONS SCREEN_PROGS-STATUS_SUBMODE
                          CHANGING CURRENT_SCR-EXCL.


  IF CURRENT_SCR-STATUS EQ SPACE.
    IF NOT ( P_STATUS EQ SY-PFKEY AND
             ( P_STATUS EQ 'STLI' OR
               P_STATUS EQ 'INLI' OR
               P_STATUS EQ 'PICK' )
*            No status set so far and the status to set is the
*            standard list status - In this case don't change
*            CURRENT_SCR-STATUS
           ).
*     This is NOT the condition above - change CURRENT_SCR-STATUS
      CURRENT_SCR-STATUS = P_STATUS.
    ENDIF.
  ELSE.
    CURRENT_SCR-STATUS = P_STATUS.
  ENDIF.
  IF P_PROG = SPACE.
    CURRENT_SCR-GUI_PROG = CURRENT_SCR-PROGRAM.
  ELSE.
    CURRENT_SCR-GUI_PROG = P_PROG.
  ENDIF.

  CLEAR CURRENT_SCR-STATUS_FB.
  CURRENT_SCR-STATUS_SET = 'X'.

  CHECK PHASE BETWEEN 2 AND 98 AND COMPLEX_SELECTION = SPACE.
  PERFORM SET_GUI_STATUS USING CURRENT_SCR-STATUS.

ENDFORM.                                  " SET_USER_STATUS
* Wird aus RS_EXTERNAL_SELSCREEN_STATUS gerufen:
*  eigener PF-Status, extern definiert
FORM SET_EXTERNAL_USER_STATUS USING P_FB LIKE RS38L-NAME.

  DATA L_ANY_SELOPTS.

  CURRENT_SCR-STATUS_FB = P_FB.
  IF CURRENT_SCR-STATUS_SET NE SPACE.  " Bereits eigener Status
    PERFORM FILL_EXCL_TAB.
    PERFORM ADJUST_EXCL_TAB USING
      CURRENT_SCR-ALL_SELECTIONS SCREEN_PROGS-STATUS_SUBMODE
                            CHANGING CURRENT_SCR-EXCL.
    CLEAR CURRENT_SCR-STATUS_SET.
  ENDIF.

  CHECK PHASE BETWEEN 3 AND 98 AND COMPLEX_SELECTION = SPACE.
  PERFORM SET_GUI_STATUS USING CURRENT_SCR-STATUS.

ENDFORM.                                  " SET_EXTERNAL_USER_STATUS
* PF-Status
FORM SET_GUI_STATUS USING P_PFKEY LIKE SY-PFKEY.

  DATA L_SUBRC LIKE SY-SUBRC VALUE 1.
  DATA L_EXCL LIKE RSEXFCODE OCCURS 10 WITH HEADER LINE.
  data l_submode.

  IF CURRENT_SCR-STATUS_FB NE SPACE.
    LOOP AT CURRENT_SCR-EXCL INTO L_EXCL.
      APPEND L_EXCL.
    ENDLOOP.
    if SCREEN_PROGS-SUBMODE(1) co 'VJ'.
      l_submode = SCREEN_PROGS-SUBMODE(1).
    endif.
    CALL FUNCTION CURRENT_SCR-STATUS_FB
         EXPORTING P_SUBMIT_MODE   = l_SUBMODE
         TABLES    P_EXCLUDE       = L_EXCL
         EXCEPTIONS NO_ACTION      = 01.
    L_SUBRC = SY-SUBRC.
  ENDIF.

  IF L_SUBRC NE 0.
    SET PF-STATUS P_PFKEY OF PROGRAM CURRENT_SCR-GUI_PROG
                          EXCLUDING CURRENT_SCR-EXCL.
  ENDIF.

ENDFORM.                              "  SET_GUI_STATUS
* Liefert Inhalte der dynamischen Drucktastentexte zurück,
* z.Zt. nur SSCRTEXTS-DYNSEL
FORM GET_DYNAMIC_KEY_TEXTS CHANGING P_DYNSEL.
  P_DYNSEL = <SSCRTEXTS>-DYNSEL.
ENDFORM.
* Initialisierung der Tabelle CURRENT_SCR-EXCL
FORM FILL_EXCL_TAB.
  constants fallback_langu type sy-langu value 'E'.
  DATA L_OFFSET(1) TYPE N.
  DATA L_FCODE LIKE RSEXFCODE-FCODE VALUE 'FC0 '.

  FIELD-SYMBOLS <L_FUNC_KEYS>.

  REFRESH CURRENT_SCR-EXCL.
  DESCRIBE TABLE CURRENT_SCREEN-SELOPTS LINES SY-TFILL.
  IF SY-TFILL = 0.
    APPEND 'OPTI' TO CURRENT_SCR-EXCL.
    APPEND 'DELS' TO CURRENT_SCR-EXCL.
    APPEND 'DELA' TO CURRENT_SCR-EXCL.
    APPEND 'SCRH' TO CURRENT_SCR-EXCL.
  ENDIF.

  CALL FUNCTION 'DOKU_OBJECT_EXIST'
       EXPORTING
            DOKCLASS         = 'RE'
*           DOKLANGU         = SY-LANGU
            DOKNAME          = CURRENT_SCREEN-PROGRAM
       EXCEPTIONS
            OTHERS           = 1.
  IF SY-SUBRC <> 0.
*  Is there a documentation in English ?
    if sy-langu <> fallback_langu.
     CALL FUNCTION 'DOKU_OBJECT_EXIST'
        EXPORTING
             DOKCLASS         = 'RE'
             DOKLANGU         = fallback_langu
             DOKNAME          = CURRENT_SCREEN-PROGRAM
        EXCEPTIONS
             OTHERS           = 1.
    endif.
    if sy-subrc <> 0.
     APPEND 'DOCU' TO CURRENT_SCR-EXCL.
    endif.
  ENDIF.

  DO 5 TIMES.
    L_OFFSET = SY-INDEX - 1.
    ASSIGN CURRENT_SCREEN-FUNC_KEYS+L_OFFSET(1) TO <L_FUNC_KEYS>.
    CHECK <L_FUNC_KEYS> EQ SPACE.
    ADD 1 TO L_OFFSET.
    MOVE L_OFFSET TO L_FCODE+3(1).
    APPEND L_FCODE TO CURRENT_SCR-EXCL.
  ENDDO.

* Erstmal: kein Ein- und Ausblenden
  APPEND 'ALLS' TO CURRENT_SCR-EXCL.
  APPEND 'FEWS' TO CURRENT_SCR-EXCL.

* Benutzervariablen?
  IF CURRENT_SCREEN-ANY_VUVS = SPACE.
    APPEND 'LVUV' TO CURRENT_SCR-EXCL.
  ENDIF.

  IF CURRENT_SCR-MODE = 'S'.

                                           " Nicht normaler submit.
    IF SCREEN_PROGS-SUBMODE NE SPACE                           AND
                       SCREEN_PROGS-SUBMODE NE 'I'             AND
                       SCREEN_PROGS-SUBMODE CN '0123456789I'.
      APPEND 'ONLI' TO CURRENT_SCR-EXCL.
      APPEND 'PRIN' TO CURRENT_SCR-EXCL.
      APPEND 'SJOB' TO CURRENT_SCR-EXCL.
    ENDIF.

    IF SCREEN_PROGS-SUBMODE(1) NE 'V'.           " Nicht Variantenpflege
      APPEND 'SAVE' TO CURRENT_SCR-EXCL.
      APPEND 'VATT' TO CURRENT_SCR-EXCL.
      APPEND 'GOON' TO CURRENT_SCR-EXCL.
      APPEND 'LIST' TO CURRENT_SCR-EXCL.
    ENDIF.

* Nicht SUBMIT VIA JOB oder Fehlerfall bei SUBMIT VIA JOB
    IF SCREEN_PROGS-SUBMODE(1) NE 'J' OR SCREEN_PROGS-SUBMODE = 'JA'.
      APPEND 'JOBS' TO CURRENT_SCR-EXCL.
    ENDIF.

* Ungültiges Variantenprogramm?
    IF NO_VARIUCOMM = 'X'.
      APPEND 'GET ' TO CURRENT_SCR-EXCL.
      APPEND 'VSHO' TO CURRENT_SCR-EXCL.
      APPEND 'VDEL' TO CURRENT_SCR-EXCL.
      APPEND 'SPOS' TO CURRENT_SCR-EXCL.
    ENDIF.

  ELSE.

    APPEND 'ONLI' TO CURRENT_SCR-EXCL.
    APPEND 'PRIN' TO CURRENT_SCR-EXCL.
    APPEND 'SJOB' TO CURRENT_SCR-EXCL.

  ENDIF.

* Variantenbilderreigen?
  IF VSCR_TFILL < 2.
    APPEND 'PREV' TO CURRENT_SCR-EXCL.
    APPEND 'NEXT' TO CURRENT_SCR-EXCL.
  ENDIF.

* Variantenbilderreigen?
  DESCRIBE TABLE VSCREENS LINES SY-TFILL.
  CASE SY-TFILL.
    WHEN 0.
    WHEN 1.
      READ TABLE VSCREENS INDEX 1.
      if sy-dynnr eq '0102' and current_screen-program eq 'SAPLSVAR'.
          read table variscreens index vscr_index.
          if variscreens-dynnr ne vscreens-dynnr.
            APPEND 'GOON' TO CURRENT_SCR-EXCL.
          endif.
      elseIF VSCREENS-DYNNR NE CURRENT_SCREEN-DYNNR.
         APPEND 'GOON' TO CURRENT_SCR-EXCL.
      ENDIF.
    WHEN OTHERS.
      APPEND 'GOON' TO CURRENT_SCR-EXCL.
  ENDCASE.

* Dynamische Selektionen ?
  IF DYNS-TABS = SPACE OR SCREEN_PROGS-LDBPG = SPACE.
    APPEND 'DYNS' TO CURRENT_SCR-EXCL.
  ENDIF.

* Varianten ?
  IF CURRENT_SCREEN-ANY_VARIANTS = SPACE.
    APPEND 'GET ' TO CURRENT_SCR-EXCL.
    APPEND 'VDEL' TO CURRENT_SCR-EXCL.
    APPEND 'VSHO' TO CURRENT_SCR-EXCL.
  ENDIF.

  SORT CURRENT_SCR-EXCL.

ENDFORM.                                   " FILL_EXCL_TAB
* Anpassung der EXCLUDE-Tabellen an Benutzerwunsch.
FORM ADJUST_EXCL_TAB USING    P_SWITCH
  P_V_SWITCH LIKE SCREEN_PROGS-SUBMODE
                     CHANGING P_EXCL_T LIKE CURRENT_SCR-EXCL.

  DATA L_TABIX LIKE SY-TABIX.

  DATA: BEGIN OF L_IN_EXCL OCCURS 5,
          FCODE like RSEXFCODE-fcode,
        END   OF L_IN_EXCL.

  DATA: BEGIN OF L_OUT_OF_EXCL OCCURS 5,
          FCODE like RSEXFCODE-fcode,
        END   OF L_OUT_OF_EXCL.

  data l_fcode like RSEXFCODE-fcode.

  CHECK PHASE GE 3.

  CASE P_SWITCH.
    WHEN 'I' OR SPACE.              " keine unsichtbaren Objekte
      APPEND 'ALLS' TO L_IN_EXCL.
      APPEND 'FEWS' TO L_IN_EXCL.
    WHEN 'F'.                       " wenige auf Bild
      APPEND 'ALLS' TO L_OUT_OF_EXCL.
      APPEND 'FEWS' TO L_IN_EXCL.
    WHEN 'A'.                      " alle auf Bild
      APPEND 'FEWS' TO L_OUT_OF_EXCL.
      APPEND 'ALLS' TO L_IN_EXCL.
  ENDCASE.

  CASE P_V_SWITCH.
    WHEN 'VU'.
      APPEND 'SAVE' TO L_OUT_OF_EXCL.
      APPEND 'VATT' TO L_OUT_OF_EXCL.
      APPEND 'GOON' TO L_IN_EXCL.
    WHEN 'VC'.
      DESCRIBE TABLE VSCREENS LINES SY-TFILL.
      CASE SY-TFILL.
        WHEN 0.
          APPEND 'GOON' TO L_OUT_OF_EXCL.
        WHEN 1.
          READ TABLE VSCREENS INDEX 1.
          IF VSCREENS-DYNNR EQ CURRENT_SCREEN-DYNNR.
            APPEND 'GOON' TO L_OUT_OF_EXCL.
          ENDIF.
      ENDCASE.
      APPEND 'SAVE' TO L_IN_EXCL.
      APPEND 'VATT' TO L_IN_EXCL.
  ENDCASE.

  IF CURRENT_SCREEN-ANY_VARIANTS = SPACE.
    APPEND 'GET ' TO L_IN_EXCL.
    APPEND 'VDEL' TO L_IN_EXCL.
    APPEND 'VSHO' TO L_IN_EXCL.
  ELSE.
    APPEND 'GET ' TO L_OUT_OF_EXCL.
    APPEND 'VDEL' TO L_OUT_OF_EXCL.
    APPEND 'VSHO' TO L_OUT_OF_EXCL.
  ENDIF.


  LOOP AT L_OUT_OF_EXCL.
    READ TABLE P_EXCL_T WITH KEY L_OUT_OF_EXCL-FCODE BINARY SEARCH
         TRANSPORTING NO FIELDS.
    L_TABIX = SY-TABIX.
    IF SY-SUBRC = 0.
      DELETE P_EXCL_T INDEX L_TABIX.
    ENDIF.
  ENDLOOP.

  LOOP AT L_IN_EXCL.
    READ TABLE P_EXCL_T WITH KEY L_IN_EXCL-FCODE BINARY SEARCH
         TRANSPORTING NO FIELDS.
    L_TABIX = SY-TABIX.
    IF SY-SUBRC NE 0.
      INSERT L_IN_EXCL-FCODE INTO P_EXCL_T INDEX L_TABIX.
    ENDIF.
  ENDLOOP.
  loop at current_scr-usr_excl into l_fcode.
    READ TABLE p_EXCL_t WITH KEY L_FCODE
         BINARY SEARCH TRANSPORTING NO FIELDS.
    L_TABIX = SY-TABIX.
    IF SY-SUBRC NE 0.
      INSERT L_FCODE INTO p_excl_t
                             INDEX L_TABIX.
    ENDIF.

  endloop.

ENDFORM.                                " ADJUST_EXCL_TABS
* Löscht einen Eintrag aus der Exclude-Tabelle, falls er nicht
* explizit gwünscht wird.
FORM DELETE_FROM_EXCL USING P_FCODE LIKE RSEXFCODE-FCODE
                      CHANGING P_STACK_ENTRY TYPE SYDB0_SCR_STACK_LINE.

  DATA L_TABIX LIKE SY-TABIX.

  READ TABLE P_STACK_ENTRY-USR_EXCL WITH KEY P_FCODE BINARY SEARCH
       TRANSPORTING NO FIELDS.
  CHECK SY-SUBRC NE 0.

  READ TABLE P_STACK_ENTRY-EXCL WITH KEY P_FCODE BINARY SEARCH
       TRANSPORTING NO FIELDS.
  L_TABIX = SY-TABIX.
  CHECK SY-SUBRC = 0.
  DELETE P_STACK_ENTRY-EXCL INDEX L_TABIX.

ENDFORM.                            " DELETE_FROM_EXCL
* Fügt einen Eintrag in die Exclude-Tabelle ein
FORM INSERT_INTO_EXCL USING P_FCODE LIKE RSEXFCODE-FCODE.

  DATA L_TABIX LIKE SY-TABIX.

  READ TABLE CURRENT_SCR-EXCL WITH KEY P_FCODE BINARY SEARCH
       TRANSPORTING NO FIELDS.
  L_TABIX = SY-TABIX.
  CHECK SY-SUBRC NE 0.
  INSERT P_FCODE INTO CURRENT_SCR-EXCL INDEX L_TABIX.

ENDFORM.                            " INSERT_INTO_EXCL
* Ein-/Ausblenden der INVISIBLES
FORM HANDLE_INVISIBLES USING P_ACTION LIKE CURRENT_SCR-ALL_SELECTIONS.

  IF CURRENT_SCREEN-ANY_INVISIBLES NE SPACE or
    not current_scr-invisibles_inside is initial.
    CURRENT_SCR-ALL_SELECTIONS = P_ACTION.
  ENDIF.

  PERFORM ADJUST_EXCL_TAB USING    P_ACTION
                                   SCREEN_PROGS-STATUS_SUBMODE
                          CHANGING CURRENT_SCR-EXCL.

ENDFORM.
* Ein-/Ausblenden der INVISIBLES aus FBs
FORM HANDLE_INVISIBLES_VIA_FB USING    P_FCODE
                              CHANGING P_SUBRC LIKE SY-SUBRC.

* Nicht auf Selektionsbild ?
  IF PHASE < 2 OR PHASE GE 99.
    P_SUBRC = 1.
    EXIT.
  ENDIF.

  IF CURRENT_SCR-ALL_SELECTIONS = SPACE.
    ALL_SELECTIONS_VIA_FB = P_FCODE.
    EXIT.
  ENDIF.

  P_SUBRC = 0.
  PERFORM HANDLE_INVISIBLES USING P_FCODE.

ENDFORM.
* set submit info www
FORM SET_WWW_SUBMIT USING P_VALUE LIKE WWW_SUBMIT.
   WWW_SUBMIT = P_VALUE.
ENDFORM.
*Besorgt Selektionsbildversion für FB RS_SELSCREEN_VERSION
FORM SELSCREEN_VERSION CHANGING P_VERSION LIKE TRDIR-TYPE
                                P_SUBRC   LIKE SY-SUBRC.

  CLEAR: P_VERSION, P_SUBRC.

  LOOP AT %_SSCR WHERE KIND = 'V'.
    MOVE %_SSCR-NAME+2(3) TO P_VERSION.
    EXIT.
  ENDLOOP.

ENDFORM.

************************************************************************
*           Restriktionen                                              *
************************************************************************
FORM FILL_RESTRICT USING    P_PROG     LIKE SY-REPID
                            P_RESTRICT TYPE SSCR_RESTRICT
                            P_DB      LIKE SPACE
                            P_FREESEL LIKE SPACE
                   CHANGING P_SUBRC LIKE SY-SUBRC
                            P_SELOPT LIKE RSSCR-NAME.

  DATA L_SUBRC   LIKE SY-SUBRC.
  DATA L_SSCR LIKE RSSCR OCCURS 20 WITH HEADER LINE.

  P_SUBRC = 0.
  RESTRICT_FLAG = 'X'.

  PERFORM FILL_RESTRICT(RSDBSPRE) USING    P_PROG
                                           P_RESTRICT
                                           P_DB P_FREESEL
                                  CHANGING P_SUBRC
                                           P_SELOPT.
  IF P_PROG = CURRENT_SCREEN-PROGRAM.
    IF LAST_SSCR_PROG = P_PROG.
      PERFORM RESTRICT_SCREEN_FROM_PROG(RSDBSPRE)
                                     TABLES   %_SSCR
                                     CHANGING CURRENT_SCREEN.
    ELSE.
      PERFORM LOAD_SSCR TABLES L_SSCR USING P_PROG CHANGING L_SUBRC.
      CHECK L_SUBRC = 0.
      PERFORM RESTRICT_SCREEN_FROM_PROG(RSDBSPRE)
                                     TABLES   L_SSCR
                                     CHANGING CURRENT_SCREEN.
    ENDIF.
  ENDIF.

ENDFORM.                               " FILL_RESTRICT
************************************************************************
*          Keine Intervallprüfung
************************************************************************
FORM FILL_NOINTS TABLES P_SELOPTS STRUCTURE RSLDBSELOP
                 USING  P_PROGRAM LIKE SY-REPID.

  DATA: L_TABIX LIKE SY-TABIX,
        L_SCREEN TYPE SYDB0_SCREEN.

  READ TABLE NOINTS WITH KEY P_PROGRAM BINARY SEARCH
                    TRANSPORTING NO FIELDS.
  L_TABIX = SY-TABIX.
  NOINTS-SELOPTS = P_SELOPTS[].
  SORT NOINTS-SELOPTS BY NAME.
  IF SY-SUBRC EQ 0.
    MODIFY NOINTS INDEX L_TABIX TRANSPORTING SELOPTS.
  ELSE.
    NOINTS-PROGRAM = P_PROGRAM.
    INSERT NOINTS INDEX L_TABIX.
  ENDIF.
  LOOP AT SCREENS INTO L_SCREEN WHERE PROGRAM = P_PROGRAM.
     PERFORM SCREEN_NOINT_CHECK USING    NOINTS-SELOPTS
                                CHANGING L_SCREEN.
     MODIFY SCREENS FROM L_SCREEN TRANSPORTING SELOPTS.
  ENDLOOP.
  CHECK CURRENT_SCREEN-PROGRAM = P_PROGRAM.
     PERFORM SCREEN_NOINT_CHECK USING    NOINTS-SELOPTS
                                CHANGING CURRENT_SCREEN.
ENDFORM.
************************************************************************
*   Versorgt Tabelle SCREENS mit NOINT_CHECK-Info
************************************************************************
FORM SCREEN_NOINT_CHECK USING    P_SELOPTS LIKE NOINTS-SELOPTS
                        CHANGING P_SCREEN TYPE SYDB0_SCREEN.

 FIELD-SYMBOLS: <L_SELOPT> TYPE SYDB0_SELOPTS,
                <L_NAME>   TYPE RSLDBSELOP.
 LOOP AT P_SCREEN-SELOPTS ASSIGNING <L_SELOPT>.
   READ TABLE P_SELOPTS WITH KEY NAME = <L_SELOPT>-NAME BINARY SEARCH
        ASSIGNING <L_NAME>.
   IF SY-SUBRC = 0 AND <L_SELOPT>-NOINT_CHECK = SPACE.
       <L_SELOPT>-NOINT_CHECK = 'X'.
   ELSEIF SY-SUBRC NE 0 AND <L_SELOPT>-NOINT_CHECK = 'X'.
       <L_SELOPT>-NOINT_CHECK = SPACE.
   ENDIF.
 ENDLOOP.
ENDFORM.
************************************************************************
*           Dynprogenerierung                                          *
************************************************************************

* Wird bei der Generierung aus abgen.c gerufen
* Programmname sitzt in SY-CPROG
FORM GEN_SELECTION_SCREEN.

  IF SY-CPROG = 'VER07449'.
    " VERIFICATION OF ERROR HANDLING DURING ABAP COMPILATION
    PERFORM CALLBACK_SCREEN_GEN IN PROGRAM ('VER07448') IF FOUND.
  ENDIF.
  PERFORM GEN_SELECTION_SCREEN(RSDBSPGS) USING SY-CPROG.

ENDFORM.
* Wird bei der Generierung aus abgen.c gerufen
* Programmname sitzt in SY-CPROG
FORM GEN_SELECTION_SCREEN_NO_CHECK.

  IF SY-CPROG = 'VER07449'.
    " VERIFICATION OF ERROR HANDLING DURING ABAP COMPILATION
    PERFORM CALLBACK_SCREEN_GEN IN PROGRAM ('VER07448') IF FOUND.
  ENDIF.
  PERFORM GEN_SELECTION_SCREEN_NO_CHECK(RSDBSPGS) USING SY-CPROG.

ENDFORM.                      " GEN_SELECTION_SCREEN_NO_CHECK

*----------------------------------------------------------------------*
*                       Varianten                                      *
*----------------------------------------------------------------------*
* Wird aus %_IMPORT_SELC (sysend.rs) gerufen.
* Besorgt das Versorgen der Variablen in Varianten
FORM %_VARIVAR_% USING P_RKEY LIKE RSVARKEY.                      "#EC *

  DATA L_SCREEN_PROGS LIKE SCREEN_PROGS.

  IF SCREEN_PROGS-variprog = P_RKEY-REPORT.
    PERFORM VARIVAR(RSDBSPVA) USING  DYN_SEL
                                     SCREEN_PROGS CURR_VSCR-VARI
                                     CURR_VSCR-VARIVDAT
*B30K013234 Begin
                                     GL_VARIDYN
                                     GL_VDATDYN
*B30K013234 End
                                     P_RKEY.
  ELSE.
    READ TABLE SCREEN_PROGS INTO L_SCREEN_PROGS
         WITH KEY P_RKEY-REPORT BINARY SEARCH
         TRANSPORTING SSCR.
    check sy-subrc = 0.
    PERFORM VARIVAR(RSDBSPVA) USING  DYN_SEL
                                     L_SCREEN_PROGS CURR_VSCR-VARI
                                     CURR_VSCR-VARIVDAT
*B30K013234 Begin
                                     GL_VARIDYN
                                     GL_VDATDYN
*B30K013234 End
                                                        P_RKEY.
  ENDIF.

ENDFORM.                                " %_VARIVAR_%

* --------------- Blockverwaltung ------------------------------------ *
* Holt am Ende eines Blocks nach, was sonst in Einzelmodulen abläuft.
* Wird aus rsyn (sysend.rs1) aufgerufen
FORM END_OF_BLOCK USING P_BLOCKNUM TYPE SYDB0_BLOCKNUM.

  PERFORM END_OF_BLOCK(RSDBSPBL) USING P_BLOCKNUM
                                       CURRENT_SCREEN-BLOCKS.

ENDFORM.                                    " END_OF_BLOCK

* ------------------- VUV -------------------------------------------- *
* Manipuliert SSCRFIELDS-UCOMM für VUV
FORM SET_THINGS_FOR_VUV USING P_VUVINT LIKE RSVUVINT.

  MOVE P_VUVINT TO RSVUVINT.

ENDFORM.

* ------------------- F4 --------------------------------------------- *
* Wird aus ab_shelp bzw. ab_shelp_c gerufen.
* SY-TABIX enthält Zeilennummer in %_SSCR
* Achtung: keine Wiederaufsetzlogik programmiert
FORM F4_SELTAB.

  PERFORM F4_SELTAB(RSDBSPF4).

ENDFORM.

*----------------------------------------------------------------------*
*                       Drucken, Spool ...                             *
*----------------------------------------------------------------------*

FORM %_SPOOL_STATISTIK.                                           "#EC *
  CALL FUNCTION 'SPOOL_STATISTIC'.
ENDFORM.

FORM %_%_COVER_PAGE.                                              "#EC *
  CALL FUNCTION  'COVER_PAGE'.
ENDFORM.

* Wird aus ablogdb.c (ab_logdb) gerufen,
* wenn SUBMIT TO SAP-SPOOL gesagt wurde.
FORM %_PRINT_REPORT_%.                                            "#EC *
  DATA FLAG TYPE X VALUE '01'.
  DATA NO_DIALOG.
    IF SY-SUBTY O FLAG.
      NO_DIALOG = 'X'.
    ENDIF.
    MOVE 'SUB' TO SY-CALLR.
    CALL FUNCTION  'PRINT_REPORT'
           EXPORTING REPORT    = SY-CPROG
                     NO_DIALOG = NO_DIALOG.
*          IMPORTING STATUS    = <SSCRFIELDS>-UCOMM.
*   SY-UCOMM = <SSCRFIELDS>-UCOMM.
ENDFORM.                                " %_PRINT_REPORT.
*----------------------------------------------------------------------*
*                       Matchcode,....                                 *
*----------------------------------------------------------------------*

* 21.02.1996: Verlagerung der Matchcoderoutinen in RSDBSPMC.
* Die hier verbliebenen Routinen werden direkt aus der RSYN aufgerufen

*
* PBO-Routine Indexselektion: Lesen der Texte, ggfls. Initialisierung
* gerufen aus Modul LDB_INDEX OUTPUT
*
FORM SEARCH_PBO USING P_S TYPE SYLDB_SP.

  PERFORM SEARCH_PBO(RSDBSPMC) CHANGING P_S <SSCRTEXTS> <SSCRFIELDS>.

ENDFORM.                               "  SEARCH_PBO


*----------------------------------------------------------------------*
*    %_INDEX
*    called by %_root in program SY-LDBPG (e.g. SAPDBKDF),
*    which is generated at END-OF-REPORT (cf. subrouti.rs)
*----------------------------------------------------------------------*
FORM SP TABLES KEYTAB
               IX_FIELDS STRUCTURE RSSPFIELDS
               IX_TABLES STRUCTURE RSSPTABS
             USING
               VALUE(P_S) TYPE SYLDB_SP
               VALUE(P_LDB).

  PERFORM SP(RSDBSPMC) TABLES   KEYTAB IX_FIELDS IX_TABLES
                       USING    P_S P_LDB
                       CHANGING <SSCRTEXTS>.

ENDFORM.                               " SP

*----------------------------------------------------------------------*
*    %_CHECK_INDEX
*      wird aus dem Modul LDB_INDEX des Reports gerufen,
*      jedesmal bei PAI. Eingabebereit sind alle Indexfelder
*----------------------------------------------------------------------*
FORM CHECK_SEARCH USING P_S TYPE SYLDB_SP P_GET.

  PERFORM CHECK_SEARCH(RSDBSPMC) USING    P_S
                                 CHANGING <SSCRTEXTS>.

ENDFORM.                                "CHECK_SEARCH
FORM %_CHECK_SEARCH USING P_S TYPE SYLDB_SP.                      "#EC *

  PERFORM CHECK_SEARCH(RSDBSPMC) USING    P_S
                                 CHANGING <SSCRTEXTS>.

ENDFORM.                                "CHECK_SEARCH

* Wird aus %_SUPPLY_IX_GLOBAL_TABS(SAPDBxyz) gerufen
* Setzt SUPPLIED-Felder in %_IX_TABLES, %_IX_FIELDS
FORM SUPPLY_IX_TABS TABLES P_IX_TABLES STRUCTURE RSMCTABS
                           P_IX_FIELDS STRUCTURE RSMCFIELDS
                    USING  P_GET TYPE C
                    CHANGING P_IX_EVENTS TYPE C.

  PERFORM SUPPLY_IX_TABS(RSDBSPMC) TABLES   P_IX_TABLES
                                            P_IX_FIELDS
                                   USING    P_GET
                                   CHANGING P_IX_EVENTS.

ENDFORM.                 " SUPPLY_IX_TABS


*----------------------------------------------------------------------*
* %_MC_VALUES: F4 auf Indexfeld
* Setzt P_NAME und zugehörige Textfelder SSCRFIELDS-...
* entsprechend ausgewählter Zeile.
* FIELD:  'NAME_TEXT' oder 'NAME'
* Gerufen aus den Modulen %_IX_NAMETX_VALUES, %_IX_NAME_VALUES
* (aus RSYN heraus)
*----------------------------------------------------------------------*
FORM SEARCH_VALUES USING P_FIELD P_S TYPE SYLDB_SP.

  PERFORM SEARCH_VALUES(RSDBSPMC) USING  P_FIELD
                                CHANGING P_S <SSCRTEXTS>.

ENDFORM.                                   "  SEARCH_VALUES

* Freie Abgrenzungen: Initialisierung. Stellt sicher, daß
* RSDBSPDS zu RSDBRUNT geladen wird.
FORM DYNS_SET_STATUS USING P_STATUS P_PROG LIKE SY-REPID.
  break bpinst.
  PERFORM DYNS_SET_STATUS(zonpg_RSDBSPDS) USING P_STATUS P_PROG.
ENDFORM.                                        " DYNS_SET_STATUS.
*&---------------------------------------------------------------------*
*&      Form  SWITCH_TO_SUBSCREEN
*&---------------------------------------------------------------------*
FORM SWITCH_TO_SUBSCREEN USING    P_PROG  LIKE SY-REPID
                                  P_LDBPG LIKE SY-LDBPG
                                  P_DYNNR LIKE SY-DYNNR.
  DATA: L_TABIX LIKE SY-TABIX,
        L_SUBRC LIKE SY-SUBRC,
        L_TYPE LIKE D020S-TYPE,
        L_NO_SELOPTS,
        l_invisibles.
 statics: l_flag_first value 'X',
           l_prog like sy-repid.

* Rette Stackeintrag
  PARENT_SCR = CURRENT_SCR.
  PARENT_NO_SPAGPA = NO_SPAGPA.
  APPEND PARENT_NO_SPAGPA TO NO_SPAGPA_STACK.
* Setze CURRENT_SCR auf Subscreen
  CLEAR CURRENT_SCR.
  MOVE P_PROG TO:  CURRENT_SCR-PROGRAM.
  MOVE P_DYNNR TO: CURRENT_SCR-DYNNR.
  MOVE 'J' TO CURRENT_SCR-MODE.
  current_scr-ancestors = parent_scr-ancestors + 1.
* Rette CURRENT_SCREEN
  IF NOT CURRENT_SCREEN IS INITIAL.
    move current_screen to current_scr-parentscreen.
* Hier fehlt vielleicht noch was
    READ TABLE SCREENS WITH KEY PROGRAM = CURRENT_SCREEN-PROGRAM
                                DYNNR   = CURRENT_SCREEN-DYNNR
                                BINARY SEARCH TRANSPORTING NO FIELDS.
    L_TABIX = SY-TABIX.
    IF SY-SUBRC NE 0.
      INSERT CURRENT_SCREEN INTO SCREENS INDEX L_TABIX.
    else.
      modify screens from current_screen index l_tabix transporting
             selopts.
    ENDIF.
    IF CURRENT_SCREEN-SELOPTS IS INITIAL.
      L_NO_SELOPTS = 'X'.
    ENDIF.
    l_invisibles = current_screen-any_invisibles.
  ENDIF.
* Lade Programm
  IF P_PROG NE CURRENT_SCREEN-PROGRAM.
    PERFORM INIT_1_PROG USING    P_PROG P_LDBPG 'J'
                        CHANGING L_SUBRC.
*    IF L_SUBRC NE 0.
    if screen_progs-hash is initial.
      PERFORM CHECK_SCR_VERSION USING P_PROG
                              CHANGING L_TYPE.
    ENDIF.
    PERFORM %_LINK_%_SSCR_WAS_% IN PROGRAM (P_PROG)
            USING 'RSDBRUNT' 'TAKE_SSCR_WAS'        IF FOUND.
    if parent_scr-mode = 'S'.
      read table f3progs
           with key table_line = p_prog binary search
           transporting no fields.
      l_tabix = sy-tabix.
      if sy-subrc ne 0.
        insert p_prog into f3progs index l_tabix.
      endif.
    endif.
  ENDIF.
  PERFORM SET_CURR_VSCR(RSDBSPVA) USING    p_PROG
                                           p_DYNNR
                                  CHANGING CURR_VSCR
                                            L_SUBRC.

  if flag_query_active eq 'A' and p_prog ne l_prog.
    sy-ldbpg = p_ldbpg.
    CURR_LDB-LDBPG = p_LDBPG.
    PERFORM SET_SP_for_query(RSDBSPMC)
            USING p_prog
                  p_dynnr
                  p_LDBPG
            IF FOUND.
    clear l_flag_first.
    l_prog = p_prog.
  endif.
"$$
* Setzt CURRENT_SCREEN auf Subscreen
  READ TABLE SCREENS WITH KEY PROGRAM = P_PROG
                              DYNNR   = P_DYNNR
                              BINARY SEARCH
               INTO CURRENT_SCREEN.
  IF SY-SUBRC NE 0.
    PERFORM INIT_1_SCREEN USING P_PROG
                                P_DYNNR
                                P_LDBPG
                               'J'.
  endif.
* Jetzt Subscreen
  READ TABLE SCREENS WITH KEY PROGRAM = CURRENT_SCREEN-PROGRAM
                              DYNNR   = CURRENT_SCREEN-DYNNR
                              BINARY SEARCH TRANSPORTING NO FIELDS.
  IF SY-SUBRC NE 0.
    L_TABIX = SY-TABIX.
    INSERT CURRENT_SCREEN INTO SCREENS INDEX L_TABIX.
  ENDIF.
  if not current_screen-any_invisibles is initial.
    if  parent_scr-all_selections cn ' I'.
      move parent_scr-all_selections to current_scr-all_selections.
    elseif l_invisibles is initial.
      parent_scr-all_selections = 'F'.
      current_scr-all_selections = 'F'.
    endif.
    parent_scr-invisibles_inside = 'X'.
  endif.

  IF NOT L_NO_SELOPTS IS INITIAL AND NOT
    CURRENT_SCREEN-SELOPTS IS INITIAL.
    PARENT_SCR-SELOPTS_INSIDE = 'X'.
  ENDIF.

  if not current_screen-dyns_sub is initial.
    perform dyns_set_status in program rsdbspds
      using 'Y' 'SAPLSSEL' .
*    perform init_screen in program saplssel
*          changing current_screen l_subrc.
    PERFORM MODIFY_CURR_SCREEN in program saplssel
                  tables %_sscr
                  CHANGING current_SCREEN-SELOPTS.
  elseif sy-tcode eq 'BMBC'.
   data lv_charx.
   import  lv_charx from memory id 'BMBC_FREE_SEL'.
   if lv_charx eq '1'.
      perform dyns_set_status in program rsdbspds
      using 'Y' 'SAPLSSEL' .
   endif.
  endif.
  append parent_scr to ancestors_scr.

ENDFORM.                    " SWITCH_TO_SUBSCREEN
*&---------------------------------------------------------------------*
*&      Form  SWITCH_TO_SUBSCREEN_PAI
*&---------------------------------------------------------------------*
FORM SWITCH_TO_SUBSCREEN_PAI USING P_PROG LIKE SY-REPID.

  DATA: L_SUBRC LIKE SY-SUBRC, L_TABIX LIKE SY-TABIX.
* Rette Stackeintrag
  PARENT_SCR = CURRENT_SCR.
* Setze CURRENT_SCR auf Subscreen
  CLEAR CURRENT_SCR.
  MOVE P_PROG TO:  CURRENT_SCR-PROGRAM.
  MOVE SY-DYNNR TO: CURRENT_SCR-DYNNR.
  MOVE 'J' TO CURRENT_SCR-MODE.
  current_scr-ancestors = parent_scr-ancestors + 1.
  IF PARENT_SCR-PROGRAM IS INITIAL.
    if parent_scr-reset_ucomm is initial.
      call 'DYNP_OKCODE_GET' id 'FCODE' field parent_scr-reset_ucomm.
    endif.
    CURRENT_SCR-RESET_UCOMM = parent_scr-reset_UCOMM.
  ELSE.
* Rette CURRENT_SCREEN
    move current_screen to current_scr-parentscreen.
    CURRENT_SCR-RESET_UCOMM = parent_scr-reset_UCOMM.
  ENDIF.
* Lade Programm
  IF P_PROG NE CURRENT_SCREEN-PROGRAM.
    PERFORM INIT_1_PROG USING    P_PROG SPACE 'J'
                        CHANGING L_SUBRC.
    PERFORM %_LINK_%_SSCR_WAS_% IN PROGRAM (P_PROG)
            USING 'RSDBRUNT' 'TAKE_SSCR_WAS'        IF FOUND.
  ENDIF.
  MOVE PARENT_SCR-RESET_UCOMM TO: SY-UCOMM, <SSCRFIELDS>-UCOMM.
  read table screens with key
                      PROGRAM = P_PROG
                      DYNNR   = SY-DYNNR
                      BINARY SEARCH
                      INTO CURRENT_SCREEN.
  if not current_screen-dyns_sub is initial .
    perform dyns_set_status in program rsdbspds
      using 'Y' 'SAPLSSEL' .
    PERFORM MODIFY_CURR_SCREEN in program saplssel
                  tables %_sscr
                  CHANGING current_SCREEN-SELOPTS.
   elseif sy-tcode eq 'BMBC'.
     data lv_charx.
     import  lv_charx from memory id 'BMBC_FREE_SEL'.
     if lv_charx eq '1'.
        perform dyns_set_status in program rsdbspds
        using 'Y' 'SAPLSSEL' .
     endif.
   endif.
 IF SCREEN_PROGS-SUBMODE EQ 'VC' OR SCREEN_PROGS-SUBMODE EQ 'VU'.
   READ TABLE VSCREENS WITH KEY DYNNR = SY-DYNNR.
   L_TABIX = SY-TABIX.
   IF SY-SUBRC = 0.
     DELETE VSCREENS INDEX L_TABIX.
   ENDIF.
 ENDIF.
ENDFORM.                    " SWITCH_TO_SUBSCREEN

* Zurueck vom Subscreen zum Rahmenbild.
FORM RETURN_FROM_SUBSCREEN.

  DATA: L_TABIX LIKE SY-TABIX, L_SUBRC LIKE SY-SUBRC.
  FIELD-SYMBOLS <L_SCREEN> TYPE SYDB0_SCREEN.

  read table ancestors_scr index current_scr-ancestors into parent_scr.
  delete ancestors_scr index current_scr-ancestors.

  read table NO_SPAGPA_STACK index current_scr-ancestors
       into parent_NO_SPAGPA.
  delete NO_SPAGPA_STACK index current_scr-ancestors.
  NO_SPAGPA = PARENT_NO_SPAGPA.

  READ TABLE screens WITH KEY
                       PROGRAM = CURRENT_SCREEN-PROGRAM
                       DYNNR   = CURRENT_SCREEN-DYNNR
                       BINARY SEARCH
                       ASSIGNING <L_SCREEN>.
  L_TABIX = SY-TABIX.
  IF SY-SUBRC NE 0.
    INSERT CURRENT_SCREEN INTO screENS INDEX L_TABIX.
  ELSE.
    <L_SCREEN>-SELOPTS = CURRENT_SCREEN-SELOPTS.
  ENDIF.
* Lade Programm
  IF PARENT_SCR-PROGRAM NE CURRENT_SCREEN-PROGRAM
      AND NOT PARENT_SCR-PROGRAM IS INITIAL.
    PERFORM INIT_1_PROG USING    PARENT_SCR-PROGRAM SPACE SPACE
                        CHANGING L_SUBRC.
    PERFORM %_LINK_%_SSCR_WAS_% IN PROGRAM (PARENT_SCR-PROGRAM)
            USING 'RSDBRUNT' 'TAKE_SSCR_WAS'        IF FOUND.
  ENDIF.
  PARENT_SCR-LAST_SUBSCREEN_PROGRAM = CURRENT_SCREEN-PROGRAM.
  PARENT_SCR-LAST_SUBSCREEN_DYNNR = CURRENT_SCREEN-DYNNR.
  IF NOT PARENT_SCR-PROGRAM IS INITIAL.
    current_screen = current_scr-parentscreen.
    PERFORM SET_CURR_VSCR(RSDBSPVA) USING    CURRENT_SCREEN-PROGRAM
                                             CURRENT_SCREEN-DYNNR
                                    CHANGING CURR_VSCR
                                             L_SUBRC.
  ELSE.
      CLEAR: CURRENT_SCREEN, curr_vscr.
  ENDIF.

  CURRENT_SCR = PARENT_SCR.
  CLEAR PARENT_SCR.
  if dyns-selscreen_flag eq 'Y'.
    clear dyns-selscreen_flag.
  endif.
ENDFORM.                                 " RETURN_FROM_SUBSCREEN
************************************************************************
FORM RETURN_FROM_SUBSCREEN_PAI.

  DATA L_SUBRC LIKE SY-SUBRC.
  read table ancestors_scr index current_scr-ancestors into parent_scr.
  delete ancestors_scr index current_scr-ancestors.
* Lade Programm
  IF PARENT_SCR-PROGRAM NE CURRENT_SCREEN-PROGRAM AND
      NOT PARENT_SCR-PROGRAM IS INITIAL.
    PERFORM INIT_1_PROG USING    PARENT_SCR-PROGRAM SPACE SPACE
                        CHANGING L_SUBRC.
    PERFORM %_LINK_%_SSCR_WAS_% IN PROGRAM (PARENT_SCR-PROGRAM)
            USING 'RSDBRUNT' 'TAKE_SSCR_WAS'        IF FOUND.
  ENDIF.
* E-Message with change of fcode?
  if <SSCRFIELDS>-UCOMM ne current_scr-ucomm.
    current_scr-reset_ucomm = <SSCRFIELDS>-UCOMM.
    perform is_sel_specific_ucomm using    <SSCRFIELDS>-UCOMM
                                  changing current_scr-spec_ucomm.
  endif.
* feld in genau diesem Screen?
  case current_scr-field_found.
    when 'X'.    " found in this screen
*Field specific OK-Code handled in subscreen
     parent_scr-field_found = 'Y'.
     if not current_scr-spec_ucomm is initial.
     CLEAR:  <SSCRFIELDS>-UCOMM,
            PARENT_SCR-RESET_UCOMM,
            parent_scr-spec_ucomm.
     endif.
   when 'Y' or 'A'.  " handled or in ancestor
     PARENT_SCR-RESET_UCOMM = SY-UCOMM.
     MOVE CURRENT_SCR-RESET_UCOMM TO : <SSCRFIELDS>-UCOMM.
   when others.     " SPACE: not found yet.
     if not current_scr-spec_ucomm is initial.
*  Still a chance
       if parent_scr-mode = 'J' or
          current_scr-program ne parent_scr-last_subscreen_program or
          current_scr-dynnr   ne parent_scr-last_subscreen_dynnr   or
          parent_scr-spec_ucomm is initial.
*         PARENT_SCR-RESET_UCOMM = SY-UCOMM.
         MOVE CURRENT_SCR-RESET_UCOMM TO : <SSCRFIELDS>-UCOMM,
                                           PARENT_SCR-RESET_UCOMM.
         clear parent_scr-field_found.
      else.     " Last chance over
        MESSAGE S655.
        PARENT_SCR-RESET_UCOMM = <SSCRFIELDS>-UCOMM.
        MOVE CURRENT_SCR-RESET_UCOMM TO : <SSCRFIELDS>-UCOMM, SY-UCOMM.
      endif.
   endif.
 endcase.

  SY-UCOMM = <SSCRFIELDS>-UCOMM.

  current_screen = current_scr-parentscreen.
   IF not ( parent_scr-program is initial and
            parent_scr-last_subscreen_program = current_scr-program and
            parent_scr-last_subscreen_dynnr   = current_scr-dynnr ).
    CURRENT_SCR = PARENT_SCR.
  ELSE.
    CLEAR CURRENT_SCR.
  ENDIF.
  read table ancestors_scr index current_scr-ancestors into parent_scr.
  if sy-subrc ne 0.
    CLEAR: PARENT_SCR.
  endif.
  if dyns-selscreen_flag eq 'Y'.
    clear dyns-selscreen_flag.
  endif.
  PERFORM CLEAR_LAST_BLOCKNUM(RSDBSPBL).
ENDFORM.                                 " RETURN_FROM_SUBSCREEN

*&---------------------------------------------------------------------*
*&      Form  OK_CODE_J
*&---------------------------------------------------------------------*
FORM OK_CODE_J.

  IF <SSCRFIELDS>-UCOMM(1) = '%' and not
    <SSCRFIELDS>-UCOMM(2) = '%_' .
    IF <SSCRFIELDS>-UCOMM+4(4) EQ CURRENT_SCREEN-DYNNR AND
      <SSCRFIELDS>-UCOMM+8(10) EQ SCREEN_PROGS-HASH.
      PERFORM MULTIPLE_SELECTIONS USING CURRENT_SCREEN-PROGRAM.
       CURRENT_SCR-RESET_UCOMM = '%_RESET'.
    ENDIF.
  elseif <SSCRFIELDS>-UCOMM = 'CXSP'
     and flag_query_active = 'A'.  " Complex Search Pattern
    PERFORM COMPLEX_SP(RSDBSPMC).
    CLEAR: SY-UCOMM.
    CLEAR: <SSCRFIELDS>-UCOMM.
  ENDIF.
  PERFORM RETURN_FROM_SUBSCREEN_PAI.
ENDFORM.                    " OK_CODE_J
*&---------------------------------------------------------------------*
*&      Form  FILL_TABINFO
*&---------------------------------------------------------------------*
FORM FILL_TABINFO USING P_PROG LIKE SY-REPID
                        P_BLOCKNAME
                        P_FCODE
                        P_DYNNR LIKE SY-DYNNR.

 DATA: L_LINE(30),
       L_SUBRC LIKE SY-SUBRC.
 CONCATENATE '%_LINKB_' P_BLOCKNAME INTO L_LINE.
 G_FCODE = P_FCODE.
 G_PROG =  P_PROG.
 G_DYNNR = P_DYNNR.
 PERFORM (L_LINE) IN PROGRAM (current_screen-program) USING 'RSDBRUNT'
       'GET_TAB_WA' L_SUBRC IF FOUND.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_TAB_WA
*&---------------------------------------------------------------------*
FORM GET_TAB_WA USING P_NAME TYPE SYDB0_TABS-NAME
                      P_TABINFO TYPE SELTABINFO
                      P_TABSTRIP TYPE CXTAB_TABSTRIP
                      P_SUBC LIKE SY-SUBRC.

  P_TABINFO-PROG = G_PROG. CLEAR G_PROG.
  P_TABINFO-DYNNR = G_DYNNR. CLEAR G_DYNNR.
  P_TABINFO-ACTIVETAB = G_FCODE. CLEAR G_FCODE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FILL_TAB_BLOCKS
*&---------------------------------------------------------------------*
FORM FILL_TAB_BLOCKS.
  DATA: L_TABBLOCKS TYPE SYDB0_TABBLOCK.
  DATA: L_LINE(30),
        L_SUBRC LIKE SY-SUBRC.

 CLEAR CURRENT_SCR-TAB_2_SCREEN.
 LOOP AT CURRENT_SCREEN-TABBLOCKS INTO L_TABBLOCKS.
   CONCATENATE '%_LINKB_' L_TABBLOCKS-NAME INTO L_LINE.
   PERFORM (L_LINE) IN PROGRAM (CURRENT_SCREEN-PROGRAM) USING
        'RSDBRUNT' 'GET_TAB_CONTENT' L_SUBRC IF FOUND.
 ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_TAB_CONTENT
*&---------------------------------------------------------------------*
FORM GET_TAB_CONTENT USING P_NAME TYPE SYDB0_TABS-NAME
                           P_TABINFO TYPE SELTABINFO
                           P_TABSTRIP TYPE CXTAB_TABSTRIP
                           P_SUBC LIKE SY-SUBRC.

  DATA: L_TAB_2_SCREEN TYPE SYDB0_TAB_2_SCREEN.

  L_TAB_2_SCREEN-PROG = P_TABINFO-PROG.
  L_TAB_2_SCREEN-DYNNR = P_TABINFO-DYNNR.
  L_TAB_2_SCREEN-NAME = P_NAME.
  APPEND L_TAB_2_SCREEN TO CURRENT_SCR-TAB_2_SCREEN.




ENDFORM.                    " FILL_TAB_BLOCKS
************************************************************************
FORM SUPPLY_TAB_INFO USING P_TABS TYPE SYDB0_TABS.

 DATA: L_SUBRC LIKE SY-SUBRC, L_LINE(30).
 G_FCODE = P_TABS-FCODE.
 G_DYNNR = P_TABS-DYNNR.
 G_PROG = P_TABS-PROGRAM.
 CONCATENATE '%_LINKB_' P_TABS-NAME INTO L_LINE.
 PERFORM (L_LINE) IN PROGRAM (CURRENT_SCREEN-PROGRAM) USING 'RSDBRUNT'
       'SWITCH_SUBSCREEN' L_SUBRC IF FOUND.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_TABS_WA
*&---------------------------------------------------------------------*
FORM SWITCH_SUBSCREEN USING P_NAME TYPE SYDB0_TABS-NAME
                            P_TABINFO TYPE SELTABINFO
                            P_TABSTRIP TYPE CXTAB_TABSTRIP
                            P_SUBC LIKE SY-SUBRC.

  DATA: L_TAB_2_SCREEN TYPE SYDB0_TAB_2_SCREEN.
  P_TABINFO-ACTIVETAB = G_FCODE.
  CHECK NOT ( G_DYNNR = '0000' OR G_DYNNR IS INITIAL  ) OR
        NOT G_PROG IS INITIAL .
  READ TABLE CURRENT_SCR-TAB_2_SCREEN INTO L_TAB_2_SCREEN WITH KEY
    NAME = P_NAME.
  CHECK SY-SUBRC = 0.
  IF L_TAB_2_SCREEN-PROG EQ P_TABINFO-PROG AND L_TAB_2_SCREEN-DYNNR
    EQ P_TABINFO-DYNNR.
* Struktur wurde explizit veraendert
    P_TABINFO-PROG = G_PROG.
    IF NOT ( G_DYNNR = '0000' OR G_DYNNR IS INITIAL  ).
      P_TABINFO-DYNNR = G_DYNNR.
    ENDIF.
  ENDIF.

ENDFORM.                    " FILL_TAB_BLOCKS
************************************************************************
FORM SET_ACTIVE_TAB.

  DATA: L_TABBLOCKS TYPE SYDB0_TABBLOCK,
        L_LINE(30),
        L_SUBRC LIKE SY-SUBRC.

  LOOP AT CURRENT_SCREEN-TABBLOCKS INTO L_TABBLOCKS.
    CONCATENATE '%_LINKB_' L_TABBLOCKS-NAME INTO L_LINE.
 PERFORM (L_LINE) IN PROGRAM (CURRENT_SCREEN-PROGRAM) USING 'RSDBRUNT'
       'SUPPLY_ACTIVE_TAB' L_SUBRC IF FOUND.

  ENDLOOP.
ENDFORM.                             "set_active_tab.
************************************************************************

************************************************************************
FORM SUPPLY_ACTIVE_TAB USING P_NAME TYPE SYDB0_TABS-NAME
                             P_TABINFO TYPE SELTABINFO
                             P_TABSTRIP TYPE CXTAB_TABSTRIP
                             P_SUBC LIKE SY-SUBRC.

  P_TABSTRIP-ACTIVETAB = P_TABINFO-ACTIVETAB.

ENDFORM.                               "SUPPLY_ACTIVE_TAB
* Called at F1/4 via RSDBSPF4
form set_things_for_sub using p_dynnr type sydynnr.
  data l_program type syrepid.
  data l_prog like screen_progs.
  data l_subrc type sysubrc.

  system-call kernel_info 'DYNPRO_PROGRAM' l_program.
  check l_program ne last_sscr_prog.
  read table screen_progs with key program = l_program
       into l_prog
       binary search
       transporting sscr.
  check sy-subrc = 0.
  last_sscr_prog = l_program.
  %_sscr[] = l_prog-sscr.
  if l_program = 'SAPLSSEL'.
    perform is_selscreen_subscreen in program saplssel
                                   using p_dynnr l_subrc.
    check l_subrc = 0.
    perform take_sscr in program saplssel
                         tables %_sscr.
  endif.
endform.                                     "set_things_for_sub.
*&---------------------------------------------------------------------*
*&      Form  FILL_MENU
*&---------------------------------------------------------------------*
*FORM FILL_MENU.
*
*      call method menu->add_function
*        exporting
*           FCODE = 'ctm1'
*           icon  = icon_okay
*           text = 'ctmenu item1'.
*
*ENDFORM.                    " FILL_MENU
form %_ctxmenu using   p_menu type ref to cl_ctmenu   "#EC *
                       p_prog like sy-repid
                       p_dynnr like sy-dynnr
                       p_name  type c.

  constants c_context type cua_status value '%_CTX_00'.
  data: l_screens type sydb0_screen,
        l_selopts type sydb0_selopts.
  data l_numb(10) type n.
  data l_hash_prog type i.
  data l_sscr_numb(4).
  data l_fcode like sy-ucomm.
  data l_name like rsscr-name.
  data l_screen_name(13).
  data l_subrc like sy-subrc value is initial.

  l_name = p_name+11(8).
  concatenate l_name '-LOW' into l_screen_name.
*  call method cl_ctmenu=>load_gui_status
*              exporting program = 'RSSYSTDB'
*                        status  = c_context
*                        menu    = p_menu
*              exceptions others = 1.

  read table screens with key program = p_prog
                                dynnr = p_dynnr into l_screens.
  if sy-subrc ne 0.
    read table current_screen-selopts
          with key name = l_name into l_selopts.
  else.
    read table l_screens-selopts
          with key name = l_name into l_selopts.
  endif.
  if current_screen-type eq 'J' or l_screens-type eq 'J'.
    data l_proginfo like screen_progs.
    if screen_progs-program = p_prog.
       l_proginfo-hash = screen_progs-hash.
     else.
      read table screen_progs with key program = p_prog into l_proginfo
        transporting hash.
      l_subrc = sy-subrc.
    endif.
    if l_subrc = 0.
      l_hash_prog = l_proginfo-hash.
    else.
      perform hash_string(rsdbspgs) using    p_prog
                                    changing l_hash_prog.
    endif.

    l_numb = l_hash_prog.
  endif.
  context_struc-program = p_prog.
  context_struc-dynnr   = p_dynnr.
  context_struc-name    = l_name.
  l_selopts-numb = l_selopts-numb mod 1000.
  unpack l_selopts-numb to l_sscr_numb.
* Optionenbutton
  if l_numb is initial.
      concatenate '&' l_sscr_numb+1(3) into l_fcode.
  else.
      concatenate '&' l_sscr_numb+1(3) p_dynnr l_numb into l_fcode.
  endif.
  perform add_menu_entry using p_menu text-001 l_fcode.
  if l_selopts-sscr-flag1 z SSCR_F1_NOEX and l_selopts-sg_addy ne 'N'.
    if l_numb is initial .
         concatenate '%' l_sscr_numb+1(3) into l_fcode.
    else.
        concatenate '%' l_sscr_numb+1(3) p_dynnr l_numb into l_fcode.
    endif.
    perform add_menu_entry using p_menu text-280 l_fcode.
  endif.
  if l_selopts-screen_low-input eq '1' and
     l_selopts-screen_low-active = '1'.
*   Zeile löschen
    perform add_menu_entry using p_menu text-002 fdelline.
*   Selektion ganz löschen
    perform add_menu_entry using p_menu text-003 fdelall.

  endif.
endform.                 "%_ctxmenu
************************************************************************
form add_menu_entry using p_menu type ref to cl_ctmenu
                          p_text type c
                          p_fcode like sy-ucomm.

  call method p_menu->add_function
              exporting
                 fcode = p_fcode
                 text  = p_text.


endform.                 "add_menu_entry
************************************************************************
form set_query_active using p_flag.
* Query aktiv , füllen von Invsibles und inactive.
 flag_query_active = p_flag.

endform.     "set_query_active

form set_things_4_sub_v tables p_sscr structure rsscr
                        using  p_prog type sy-repid
                               p_screen_progs like screen_progs.

  p_sscr[]       = %_sscr[].
  p_prog         = last_sscr_prog.
  p_screen_progs = screen_progs.


endform.


form restore_things_from_sub_v tables p_sscr structure rsscr
                               using  p_prog type sy-repid
                                      p_screen_progs like screen_progs.
"$$

  %_sscr[]       = p_sscr[].
  last_sscr_prog = p_prog.
  screen_progs   = p_screen_progs.

endform.

FORM reset_dynref. "#EC *
  DATA l_dynref LIKE LINE OF screen_progs-dynref.
  DATA wa_screen_progs LIKE screen_progs.
  DATA wa_sscr TYPE rsscr.
  DATA l_ix TYPE sytabix.

  wa_screen_progs-sscr = screen_progs-sscr.

  LOOP AT screen_progs-dynref INTO l_dynref.
    READ TABLE wa_screen_progs-sscr WITH KEY name = l_dynref-name
      TRANSPORTING NO FIELDS.
    IF sy-subrc NE 0. CONTINUE. ENDIF.
    l_ix = sy-tabix.
    wa_sscr-dbfield = l_dynref-fieldname.
    MODIFY wa_screen_progs-sscr FROM wa_sscr INDEX l_ix
      TRANSPORTING dbfield.
  ENDLOOP.

  read table screen_progs with key program = screen_progs-program
   transporting no fields.
  l_ix = sy-tabix.
  modify screen_progs from wa_screen_progs index l_ix transporting
    dynref sscr.
ENDFORM.

FORM VH_USER_CONTEXT.
  data vh_EXCL LIKE RSEXFCODE OCCURS 5. " vh EXCLUDE-Tabelle
  data vh_func LIKE RSEXFCODE-fcode.
  data v type i.
  " check suppress dialog on main screen
  call 'DYNP_GET_STATUS'
    id 'FUNCTION' field 7
    id 'VALUE'    field v.                                "#EC CI_CCALL

  if sy-subrc = 0 and v = 0.
    " write dev trace
    call 'DYNP_SET_STATUS'
      id 'FUNCTION' field 46
      id 'VALUE'    field 1
      ID 'TEXT'     field '  call get_sel_screen_excluding interface'. "#EC CI_CCALL

    PERFORM GET_SEL_SCREEN_EXCLUDING IN PROGRAM SDYNCONTEXT IF FOUND
                                  CHANGING vh_excl.

    SORT CURRENT_SCR-EXCL.

    loop at vh_excl into vh_func.
      PERFORM INSERT_INTO_EXCL(RSDBRUNT) USING vh_func.
    endloop.
  endif.
ENDFORM.

form get_current_sscr_prog CHANGING p_prog.
" called from RS_SUPPORT_VARIANTS to enable reset of the program on end of the call
   clear p_prog.
   p_prog = SCREEN_PROGS-program.
ENDFORM.

form set_current_sscr_prog using value(p_prog).
"set program from RS_SUPPORT_VARIANTS to ensure correct program is used for variant selection
   check p_prog is not initial.

   READ TABLE SCREEN_PROGS WITH KEY p_prog
           BINARY SEARCH.
   if sy-subrc = 0.
    %_sscr[] = screen_progs-sscr.
   endif.
ENDFORM.
