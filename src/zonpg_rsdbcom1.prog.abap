
************************************************************************
*                       Datendeklaration                               *
************************************************************************

TABLES: D020S, D021S,                          " Dynproformate
        RSSCR_C,
        DFIES,
*       DD07L,
        T002.                                  " Sprachentabelle

*------------------ Daten fuer Dynprogenerierung ----------------------*

* Gemeinsame Daten mit RSDBRUNT
INCLUDE zonpg_RSDBCOM2.

* Equates fuer Dynprogenerierung
CONSTANTS:
      FMB2_HEX_F0     TYPE X VALUE 'F0',
      FMB1_NO_DITCH   TYPE X VALUE '02',  " keine Gräben
      FMB1_JUST_OUT   TYPE X VALUE '01',  " Output only
      FMB1_FIXFONT    TYPE X VALUE '40',  " Fixfont
      FMB1_PROTECTED  TYPE X VALUE '30',  "geschuetzt
      FMB1_INACTIVE   TYPE X VALUE '34',  "geschuetzt, unsichtbar
      FMB1_HELL       TYPE X VALUE '08',  "hell
      FMB1_HORIZONTAL TYPE X VALUE '80',  "Radiobuttons horiz. (Stepl.)
      FMB2_COMBO      TYPE X VALUE '08',  "Combobox
      FMB2_CMB_FORCE  TYPE X VALUE '10',  "Combobox auch ohne Werth.
      FLG1_FIELD      TYPE X VALUE '80',  "Schablone
      FLG1_TEXT       TYPE X VALUE '00',  "Textfeld
      FLG1_DDIC       TYPE X VALUE '20',  "Feld aus data dictionary
      FLG1_ROLL       TYPE X VALUE '01',  "Scrollbares Feld
      FLG1_TOP_TAB    TYPE X VALUE '08',  "Tabstrips on top
      FLG2_LETT       TYPE X VALUE '02',  "Gross- / Kleinschreibung
      FLG2_FUNC       TYPE X VALUE '10',  "Funktionscode
      FLG2_RIGHT      TYPE X VALUE '20',  "Rechtsbündig
      FLG2_SPA_GPA    TYPE X VALUE '0C',  "set + get Parameter
      FLG2_VRSZ       TYPE X VALUE '20',  "vertical resize
      FLG2_HRSZ       TYPE X VALUE '10',  "horizontal resize
      flg2_hrsc       type x value '80',   "horizontal scrollig
      flg2_vsc        type x value '40',   "vertical scrollig
      FLG3_VRZ        TYPE X VALUE '10',  "Vorzeichen
      FLG3_OUT        TYPE X VALUE '80',  "Ausgabefeld
      FLG3_OBLIGATORY TYPE X VALUE '20',  "Obligatorische Eingabe
      RES1_DROPLIST   LIKE D021S-RES1 VALUE ' DL'.
* Equates für die Bits in D020S-Flags
CONSTANTS:
      MILI_COMPR      TYPE X VALUE '40',   " Komprimierung
      MILI_GE30       TYPE X VALUE '80',   " Release >= 3.0
      MILI_KSCRPOS    TYPE X VALUE '08'.   " Keep Scroll Position

* Hilfsfelder fuer Feldpositionierung auf dem Selektionsbild
DATA: CURLINE(2) TYPE P,
      CURCOLN(2) TYPE P.
* Nummer der graphischen Gruppen
DATA: CURAUTH(3) TYPE N VALUE '101'.
* Containerid
DATA: CURLANF(3) TYPE N VALUE '101'.
* Hilfsfelder für Rahmenbehandlung.
DATA: INITCOLN TYPE I.                 " Initialspalte für Inhalte
* Aktueller Stand der Rahmerei
DATA: BEGIN OF FRAME OCCURS 2,
        TABIX LIKE SY-TABIX,           " Rahmenzeilennummer in F
        FIRST_LINE LIKE SY-INDEX,      " erste Zeile für eig. Inhalte
*       no_intervals,                  " NO INTERVALS
        NARROW,                        " schmaler Block
        FRAME,                         " mit Rahmen
        LENGTH  TYPE I,                " Breite des Rahmens
        LAST_POS_PLUS_1 TYPE I,        " Erste unzulässige abs. Pos.
        TEXT_LENGTH TYPE I,            " Textlänge für SELECT-OPTIONS
        MAX_LENG_SELOPT TYPE I,        " max. Länge    SELECT-OPTIONS
        MAX_LENG_PARAM  TYPE I,        " max. Länge    PARAMETERS
        TAB(20),                       " innerhalb TABSTRIP, Name des
                                       " Blocks
        TABS,                          " Irgendwelche TABS?
      END OF FRAME.
* Wegen Bytedreher auf DEC ...
FIELD-SYMBOLS <F-DIDX>.
*
DATA: BEGIN OF KEY,                      " Dynprokey
        PROGRAM LIKE SY-REPID,
        SCREEN(4),
      END OF KEY.

* Meldungen der Dynprogenerierung
  DATA: DYNPRO_MESSAGE(160),
        DYNPRO_LINE TYPE I,
        DYNPRO_WORD(30).

* Parameter mit Prueftabelle
*DATA: BEGIN OF FOREIGN_CHECK OCCURS 2,
*            PARAM(8),
*            TABLE(5),
*      END OF FOREIGN_CHECK.
