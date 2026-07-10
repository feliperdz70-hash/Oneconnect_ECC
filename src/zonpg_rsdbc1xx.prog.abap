***INCLUDE RSDBC1R0.

TYPE-POOLS: RSDS, SYDB0.

* Zwischengespeicherte RESTRICT-Informationen
DATA BEGIN OF COMMON PART %_RUNT_XX_%.
* Tabelle der bereits initialisierten Programme
  DATA: BEGIN OF SCREEN_PROGS OCCURS 5,
          PROGRAM  LIKE SY-REPID,
          LDBPG    LIKE SY-LDBPG,         " Datenbankprogramm
          VARIPROG LIKE SY-REPID,         " Variantenprogramm
          AFTER_FIRST_PBO,                " Erstes PBO vorbei
          RESTRICT_SET,                   " Einmal Restriktionen gesetzt
          TITLE   LIKE SY-TITLE,          " Standardtitel
          ANY_VARIANTS,
          SUBMODE(2),
          STATUS_SUBMODE(2),
          DYNSEL,
          REPORT_WRITER,         " SPEZIALVARIANTENPFLEGE REPORTWRITER.
          SSCR LIKE RSSCR OCCURS 0,
          DYNREF TYPE SYDB0_DYNREF OCCURS 0,
          TEXTS  LIKE RSSELTEXTS OCCURS 0,
*          modtext type sydb0_modtext occurs 0,
          HASH(10),
        END   OF SCREEN_PROGS.
* Beschreibung der Bilder + Stack
  DATA SCREENS TYPE SYDB0_SCREEN_T.
  DATA SCR_STACK TYPE SYDB0_SCR_STACK.
  DATA CURRENT_SCREEN TYPE SYDB0_SCREEN.
  DATA CURRENT_SCR TYPE SYDB0_SCR_STACK_LINE.
  DATA PARENT_SCR TYPE SYDB0_SCR_STACK_LINE.
  DATA PARENT_NO_SPAGPA LIKE RSSCR-NAME OCCURS 0.
  DATA NO_SPAGPA_STACK LIKE PARENT_NO_SPAGPA OCCURS 0 .
  data ancestors_scr type SYDB0_SCR_STACK.
* Was muß bei 'Abbrechen' auf Level x restauriert werden?
DATA: BEGIN OF RESTORE OCCURS 5,
          LEVEL TYPE I,
          PROGRAM LIKE SY-REPID,
          VARIANT LIKE SY-SLSET,         " Variante
          DYNS_FIELDS LIKE RSDSFIELDS OCCURS 10,
          TEXPR TYPE RSDS_TEXPR,
          VARIDYN LIKE RSVARIDYN OCCURS 0,
          VDATDYN LIKE RSVDATDYN OCCURS 0,
          VSCR_T TYPE SYDB0_VSCR_T,
          MEMKEY LIKE RSVAMEMKEY,
          ORIGINAL,
      END   OF RESTORE.
* Laufende Nummer für Bildstack-Memory-IDs
  DATA MEMONUM(8) TYPE N.
* Variantenpflege: Bildverwaltung.
  DATA: VARISCREENS LIKE RSDYNNR OCCURS 5 WITH HEADER LINE,
        VSCR_TFILL TYPE I,
        VSCR_INDEX TYPE I.
  DATA: BEGIN OF VSCREENS OCCURS 5,
          DYNNR LIKE SY-DYNNR,
        END   OF VSCREENS.
  DATA: VSCR_T TYPE SYDB0_VSCR_T,
        CURR_VSCR TYPE SYDB0_VSCR.
* --------- Daten für dynamische Selektion --------------------------- *
  DATA: BEGIN OF DYNS,
          PROGRAM LIKE SY-REPID,          " Programm des dyn. Bildes
          SELSCREEN_FLAG,                 " 'dynamisches' Selektionsbild
          INITIALIZED,                    " bereits initialisiert ?
          query_initialized,              " Aufruf für Query infoset
          FIELDS_SELECTED,                " bereits Felder ausgewählt ?
          TABS,                           " DYNS_TABS nicht leer ?
          ACTIVE_SELECTIONS TYPE I,       " Abgrenzungen aktiv ?
          SELID LIKE RSDYNSEL-SELID,      " Von INIT gelieferte SELID
          VARIS,                          " Variablen?
        END   OF DYNS.
* Free_selections-Knoten
  DATA: DYNS_NODES LIKE RSDFSNODES OCCURS 0 WITH HEADER LINE.
* Tabelle der selektierten Felder
  DATA: BEGIN OF DYNS_FIELDS OCCURS 10 .
          INCLUDE STRUCTURE RSDSFIELDS.
  DATA: END   OF DYNS_FIELDS.

DATA: GL_VARIDYN LIKE RSVARIDYN OCCURS 0.
DATA: GL_VDATDYN LIKE RSVDATDYN OCCURS 0.

DATA: BEGIN OF NOINTS OCCURS 0,
        PROGRAM LIKE SY-REPID,
        SELOPTS LIKE RSLDBSELOP OCCURS 0,
      END   OF NOINTS.
DATA END   OF COMMON PART %_RUNT_XX_%.
data  FLAG_QUERY_ACTIVE.

constants: fdelline like sy-ucomm value 'DELSCTX',
           fdelall  like sy-ucomm value 'DELACTX',
           ftext    like sy-ucomm value 'SWITCHTEXT'.
