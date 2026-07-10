*&---------------------------------------------------------------------*
*& Include          ZONFG_SSEL_LSVARTOP
*&---------------------------------------------------------------------*


TABLES:
  tadir,                         " Entwicklungsklasse
  trdir,                         " Reportcatalog
  ldbd,                          " logical databases
  varid,                         " variant properties
  rsvava,                        " Variable data in
  "  variants( sy-datum)
  rsvar,                         " new RALDB structure
  rsvardesc,                     " Report, Variante, Dynnr
  varit,                         " variants texts
  varis,                         " screennr per variant
  dd23t,                         "
  tparat,                        "Texte zu Memory-Ids
  tvaruvn,                                                  "#EC NEEDED
  t000.
DATA  choose LIKE sy-ucomm VALUE 'PICK'.
DATA  g_status LIKE sy-pfkey.
DATA g_no_popup TYPE c LENGTH 1.
DATA g_no_sysenv_check TYPE c LENGTH 1.
*Includes für Icons
INCLUDE <icon>.
* Include für Symbole
INCLUDE <symbol>.
*Equates für SSCR
INCLUDE zonpg_rsdbcom2.
*Typen für dynamische Selektionen, verwendet bei RS_REFRESH_...DYNAMICAL
TYPE-POOLS: rsds, syldb, sydb0.
DATA:  gs_toolbar           TYPE stb_button.

TYPES: BEGIN OF onf4_event_parameters_type.
TYPES: c_fieldname     TYPE lvc_fname.
TYPES: cs_row_no       TYPE lvc_s_roid.
TYPES: cr_event_data   TYPE REF TO cl_alv_event_data.
TYPES: ct_bad_cells    TYPE lvc_t_modi.
TYPES: c_display       TYPE char01.
TYPES: END OF onf4_event_parameters_type.

DATA: f4_params TYPE onf4_event_parameters_type.
DATA: grid7 TYPE REF TO cl_gui_alv_grid,
      grid8 TYPE REF TO cl_gui_alv_grid.
*DATA:  ROW_TABLE  type LVC_T_ROW  WITH HEADER LINE.

* Key um unnoetige Datenbankzugriffe zu vermeiden
DATA: BEGIN OF check_key,
        report  LIKE rsvar-report,
        variant LIKE rsvar-variant.
DATA: END OF check_key.
* key für get_description
*DATA: old_key LIKE check_key.
* CATALOG OF VARIANTS, OLD STRUCTURE. WILL BE DELETED BY FIRST
* CALL OF VARIANTS OUT OF FUNCTIONPOOL SVAR.
* INFORMATION WILL BE TRANSFERED TO VARID AND VARIT.
DATA: varcat LIKE rsvarc OCCURS 20 WITH HEADER LINE.

* TEXT (=> VARIT)
DATA: varcatt LIKE rvart OCCURS 20 WITH HEADER LINE.

* SAVE INFORMATION ABOUT VARIANTS
DATA: BEGIN OF saveinfo OCCURS 20,
        name        LIKE rvari-name,
        numb        LIKE rvari-numb,
        protected   LIKE rvari-protected,
        fieldtext   LIKE rsvar-fieldtext,
        kind        LIKE rvari-kind,
        type        LIKE rvari-type,
        vtype       LIKE rvari-vtype,
        vname       LIKE rvari-vname,
*        appendage I= Matchcode, C=Checkbox etc
        appendage   LIKE rsvar-invisible,
        varis(1),                     " TVARV, FUBAU
*        N= Ausgeblendet von Report,X ausgeblendet in Variante
        invisible,
        user,
        memoryid    LIKE rsscr-spagpa,
*        nur auf einem Bild vorhanden
        global,
        no_import,
        spagpa,
        nointervals,
        obligatory  LIKE rsvar-obligatory,
        radio,
      END OF saveinfo.

DATA: BEGIN OF saveinfo_dyn OCCURS 10,
        tablename LIKE rsdstabs-prim_tab,
        fieldname LIKE rsdstabs-prim_fname,
        fieldtext LIKE rsvar-fieldtext,
        type      LIKE rvari-type,
        vtype     LIKE rvari-vtype,
        vname     LIKE rvari-vname,
        varis(1),
        protected LIKE rvari-protected,
        global(1).
DATA: END   OF saveinfo_dyn.
DATA: saveinfo_sav LIKE saveinfo OCCURS 0 WITH HEADER LINE.
DATA: saveinfo_dyn_sav LIKE saveinfo_dyn OCCURS 0 WITH HEADER LINE.
* key for import of variants from VARI
DATA: BEGIN OF $rkey,
        report  LIKE rsvar-report,
        variant LIKE rsvar-variant,
      END OF   $rkey.

* vari
DATA: l_vari LIKE rvari OCCURS 20 WITH HEADER LINE.
* %_SSCR
DATA selctab LIKE rsscr OCCURS 20 WITH HEADER LINE.

DATA glob_submode(2).
DATA loc_submode(2).
* screenfields
DATA: xcode(4).

DATA: fcode(4) TYPE c,
      func(4)  TYPE c.

DATA: BEGIN OF info OCCURS 20,
        flag,
        olength TYPE x,
        line    LIKE rsvar-infoline,
      END OF info.


DATA: valutab LIKE rsparams OCCURS 40 WITH HEADER LINE.
DATA: valutab_255 LIKE rsparamsl_255 OCCURS 40 WITH HEADER LINE.
* Zur allgemeinen Verwendung
FIELD-SYMBOLS: <f>.

DATA illegal_char.                     " Wrong sign in variant

* copy
DATA: variant2 LIKE rsvar-variant,
      variant1 LIKE rsvar-variant.

*list of parameters and select-options, screenobjects
DATA: l_selop LIKE vanz OCCURS 20 WITH HEADER LINE.
DATA: l_selop_nonv LIKE vanz OCCURS 20 WITH HEADER LINE."nonv = non visi
DATA: l_params LIKE vanz OCCURS 20 WITH HEADER LINE.
DATA: l_params_nonv LIKE vanz OCCURS 20 WITH HEADER LINE.
DATA: screenobjects LIKE vanz OCCURS 20 WITH HEADER LINE.

* list of all variants concerning one report
DATA: BEGIN OF vari_list OCCURS 40,
        markfield   LIKE rsvar-markfield,
        variant     LIKE rsvar-variant,
        text        LIKE rvart-vtext,
        ename       LIKE rsvarc-ename,
        aename      LIKE rsvarc-aename,
        edat        LIKE rsvarc-edat,
        aedat       LIKE rsvarc-aedat,
        protected   LIKE rsvarc-protected,
        environmt   LIKE rsvarc-environmt,
        xflag1      LIKE varid-xflag1,
        JOB_USAGE   type c LENGTH 60,
   END OF vari_list.

*Variablen für das Blättern auf den Dynpros 1303 und 306.
DATA: vari_list_scroll LIKE sy-stepl VALUE '1'.
DATA: save_okcode(4).

* table for  Dynpro 306 (delete variants)
DATA: BEGIN OF h_varilist OCCURS 30,
        markfield LIKE rsvar-markfield,
        flag1     LIKE rsvar-flag1,
        flag2     LIKE rsvar-flag2,
        flag3     LIKE rsvar-flag3,
        variant   LIKE rsvar-variant.
DATA: END OF h_varilist.
CONSTANTS: c_pdlist_width TYPE i VALUE '24',
           c_varilist     TYPE i VALUE '10'.

DATA: cattop LIKE sy-tabix VALUE '3'.  "lines top-of-page in CATALOG.
*data: listtop like sy-tabix value '3'.  "lines top-of-page in Delete
"vari
DATA: print_all_var.                   "alle Varianten drucken
DATA: print_cat_var.                   "Katalog drucken


* Systemumgebung
DATA environment.                      " S: SAP, C: Customer
* Dynpro 320
DATA : text0(59).
*Tables and fields for fitting variants
*table of variants which must be fitted
DATA: BEGIN OF fit_var OCCURS 50,
        variant LIKE rsvar-variant,
        flag(1).                        " flag = 'X' => Variante can't be
DATA: END OF fit_var.                  "fitted.

DATA: BEGIN OF single_options OCCURS 8,
        option(2),
        text(18).
DATA: END OF single_options.

* variants which contain variables
* internal table, per line  select-options and parameters which
* use variables
DATA: BEGIN OF varivar OCCURS 20,
        selname     LIKE rsscr-name,
        seltext     LIKE rsvar-fieldtext,
        kind        LIKE rvari-kind,
        type        LIKE rvari-type,
        vtype       LIKE rsvar-vtype,
        vtext       LIKE rsvava-vtext,
        fb,
        tvarv,
        vname       LIKE rsvar-vname,
        option      LIKE rsvar-option,
        sign(1),
        info_tabix  LIKE sy-tabix,
        dates_tabix LIKE sy-tabix,
        user,
        memoryid    LIKE tpara-paramid,
      END   OF varivar.
DATA: BEGIN OF varivar_dyn OCCURS 20,
        tablename   LIKE rsdstabs-prim_tab,
        fieldname   LIKE rsdstabs-prim_fname,
        kind        LIKE rvari-kind,
        type        LIKE rvari-type,
        vtype       LIKE rsvar-vtype,
        vtext       LIKE rsvava-vtext,
        fb,
        tvarv,
        vname       LIKE rsvar-vname,
        option      LIKE rsvar-option,
        sign(1),
        info_tabix  LIKE sy-tabix,
        dates_tabix LIKE sy-tabix,
      END   OF varivar_dyn.

DATA: varidate_s LIKE rsvarivar OCCURS 20 WITH HEADER LINE.
* Tabelle der möglichen Datumsberechnungen für Variablen in Varianten
* Parameter
DATA: varidate_p LIKE rsvarivar OCCURS 20 WITH HEADER LINE.
DATA: varitime_p LIKE rsvarivar OCCURS 20 WITH HEADER LINE.
DATA: varitime_s LIKE rsvarivar OCCURS 20 WITH HEADER LINE.
* table of possible TVARV-variables (parameters)
DATA: tvarv_p LIKE tvarvc OCCURS 20 WITH HEADER LINE.
* table of possible TVARV-variables (select-options)
DATA: tvarv_s LIKE tvarvc OCCURS 20 WITH HEADER LINE.
* description of fields  VARIDATES
DATA: fidesc_dates LIKE rsvbfidesc OCCURS 5 WITH HEADER LINE.
* description of fields TVARV
DATA: fidesc_tvarv LIKE rsvbfidesc OCCURS 5 WITH HEADER LINE.
* description of fields OPTION
DATA: fidesc_option LIKE rsvbfidesc OCCURS 5 WITH HEADER LINE.
* description of fields OPTION

* Feldtabelle für DYNP_VALUES_READ/UPDATE
DATA dynpfields LIKE dynpread OCCURS 50 WITH HEADER LINE.
*desctab
DATA: desctab LIKE rsbrepi OCCURS 20 WITH HEADER LINE.
*Hilfsfelder für Übergabeparameter
DATA:g_subrc LIKE sy-subrc,
     l_rc    LIKE sy-subrc.
*Hilfsfelder für Sperren
DATA: g_enqsub LIKE sy-subrc.
*Hilfsfeld für mandantenabhängiges Löschen von Varianten
DATA: del_all_var. "=X alle Mandanten, =' ' nur aktueller Mandant
* select variant form list.
DATA: BEGIN OF variant_table OCCURS 30,
        variant       LIKE rsvar-variant,
        text          LIKE varit-vtext,
        envir         LIKE varid-environmnt,
        ename         LIKE varid-ename,
        aename        LIKE varid-aename,
        aedat         LIKE varid-aedat,
        mlangu        LIKE varid-mlangu,
        protected     LIKE varid-protected,
        selscreen(80).                  "<= 20 Bilder
DATA: END OF variant_table.
DATA: BEGIN OF variant_table_disp OCCURS 30,
        variant       LIKE rsvar-variant,
        text          LIKE varit-vtext,
        envir         LIKE varid-environmnt,
        ename         LIKE varid-ename,
        edat          LIKE varid-edat,
        aename        LIKE varid-aename,
        aedat         LIKE varid-aedat,
        mlangu        LIKE varid-mlangu,
        protected     LIKE varid-protected,
        selscreen(80).                  "<= 20 Bilder
DATA: END OF variant_table_disp.
DATA: call_flag.                             "screen 305.
DATA: mode_flag.
* Print variants  screen 308
DATA: print_list LIKE rsrepvar OCCURS 30 WITH HEADER LINE.
* parameters in variables
DATA: BEGIN OF varivdat  OCCURS 5,
        selname LIKE rvari-name.
        INCLUDE STRUCTURE rsintrange.
DATA: END OF varivdat.

DATA: varivdat_work LIKE varivdat OCCURS 10 WITH HEADER LINE.

DATA:exc_subc LIKE sy-subrc.

DATA: BEGIN OF ldb_varivar OCCURS 10,
        markfield LIKE rsvar-markfield,
        vtext     LIKE rsvarivar-text,
        vtype     LIKE rsvar-vtype.
DATA: END OF ldb_varivar.

*generate subroutinepool
DATA: BEGIN OF repdat_tab OCCURS 40,
        line(72),
      END OF repdat_tab.
*Tabelle zur Übergabe der alten Selektionswerte wenn sich
*Parameter oder Select-Options geändert haben.
*Wird von rs_variant_obsolet benötigt.
DATA: old_selections LIKE rsparams OCCURS 20 WITH HEADER LINE.

*Flag für Aufruf aus QUERY und Report-Writer.
*Reportname auf Einstiegsbild nicht sichtbar (not_visible = x)
DATA: not_visible.
*Varianten für Query
DATA: query_sysvar.
*Einstiegsbild mit anderem Titel aufrufen.
DATA: n_title(40).
*F4 Hilfe RS_VARIANT_CATALOG mit anderem Titel aufrufen
*DATA: g_title LIKE sy-title.
*Unterscheidung auf Listdynpro (hauptsächlich 307)
DATA: caller(4).
*sy-subrc Felder für Import und Export.
DATA: exp_subrc LIKE sy-subrc,
      imp_subrc LIKE sy-subrc.
*Tabellen für dynamische Selektionen
DATA: dynsel_desc LIKE rsdynbrepi OCCURS 5 WITH HEADER LINE.
DATA: dyns_fields LIKE rsdsfields OCCURS 5 WITH HEADER LINE.
DATA: dynsel_value LIKE rsseldyn OCCURS 5 WITH HEADER LINE.

*tabellen für matchcodeselection
DATA: BEGIN OF mc_desc OCCURS 5,
        name       LIKE rsscr-name,
        id         LIKE mcparams-mcid,
        object(10),
        s_string   LIKE mcparams-string,
        d_text     LIKE dd23t-mctext,
        from       LIKE vanz-from,
        to         LIKE vanz-to.
DATA: END   OF mc_desc.
*Tabelle für Umsetzung dynamische Selektionen
*flag = space -> umgesetzt
*flag = G     -> Variante z.Z gesperrt
*flag = I     -> Fehler beim Import
DATA: BEGIN OF changed_variants OCCURS 10,
        name LIKE rsvar-variant,
        flag.
DATA: END OF changed_variants.
*Feld für Ikonen auf Dynpros.
DATA: ikon(8).
*Konstanten für Ikonen
CONSTANTS: pop_warning(8)          VALUE '@1A@',
           pop_error(8)            VALUE '@1B@',
           pop_info(8)             VALUE '@19@',
           pop_copy(8)             VALUE '@14@',
*           c_icon_enter_more(15) value 'ICON_ENTER_MORE',
           c_icon_display_more(17) VALUE 'ICON_DISPLAY_MORE'.
DATA: more_icon LIKE rsselint-opti_push.
*Konstanten für Variante ändern, Werte oder Attribute
CONSTANTS: c_val  VALUE 'V'.
* Interne Tabelle für Transport
DATA: BEGIN OF rep_var OCCURS 10,
        markfield.
        INCLUDE STRUCTURE $rkey.
DATA: END   OF rep_var.
DATA: rep_var_cursor LIKE sy-index VALUE 0.

* Tabelle für RS_SELOPT_INFO -> BBS
DATA: defaults LIKE rsparams OCCURS 10 WITH HEADER LINE.
DATA: defaults_255 LIKE rsparamsl_255 OCCURS 10 WITH HEADER LINE.

* Tabelle für Werteanzeige Tvarv.
DATA: tvarvtab LIKE tvarvc OCCURS 10 WITH HEADER LINE.

* SUBTY-Equates
INCLUDE zonpg_rsdbcsty.

* Textfeld für Dynpro 317.
DATA: text(4).
* Konstante für Namenskonvention Systemvariante
CONSTANTS: sys_vname(4) VALUE 'SAP&'.
CONSTANTS: cus_vname(4) VALUE 'CUS&'.
* Flag für Systemvariante gewünscht.
DATA: c_sysvar.
DATA vari_mandt LIKE sy-mandt.
DATA sysvar_mandt LIKE sy-mandt VALUE '000'.
* Check für Systemvariante
DATA: sysvar_flag.
* Flag für Entwicklungsklasse , Werte Y oder N (aus get_devcalss)
DATA: non_local VALUE 'Y'.
DATA: tabix LIKE sy-tabix.
*Strutur für freie Abgrenzungen.
DATA: varidyn LIKE rsvaridyn OCCURS 10 WITH HEADER LINE.
DATA: vdatdyn LIKE rsvdatdyn OCCURS 10 WITH HEADER LINE.
DATA: varivdat_dyn LIKE rsvdatdyn OCCURS 10 WITH HEADER LINE.
DATA: BEGIN OF varivdat_dyn_work OCCURS 10,
        tablename LIKE rsvaridyn-tablename,
        fieldname LIKE rsvaridyn-fieldname.
        INCLUDE STRUCTURE rsintrange.
DATA: END OF varivdat_dyn_work.
CONSTANTS: no_import VALUE space.
* Teilt IM/EXPORT_VARIANT_STATIC mit, welche übergebeneb Objekte
* im/exportiert werden sollen.
DATA: BEGIN OF imex,
        vari,
        dyns,
      END   OF imex.

* Tabelle für Selektionsbildnummern
*DATA: dynnr LIKE rsdynnr OCCURS 10 WITH HEADER LINE.
DATA: BEGIN OF choose_dynnr OCCURS 10,
        markfield.
        INCLUDE STRUCTURE rsdynnr.
DATA: END OF choose_dynnr.
* Sichern vom Selektionsbild, RSVAR_VARIANTT zurücksetzen
*DATA: flag_first.                                           "#EC NEEDED
DATA: flag_protected type sy-uname.                          "#EC NEEDED
DATA: username_protected TYPE sy-uname.                     "#EC NEEDED "no use -> avoid syntax errors
* Daten für CALL SELECTION SCREEN Varianten
DATA: hide_flag.
DATA: line_number LIKE sy-tabix.
DATA: variscreens LIKE rsdynnr OCCURS 10 WITH HEADER LINE.
DATA: variscreens_sav LIKE rsdynnr OCCURS 10 WITH HEADER LINE.
DATA: flag_1000.
DATA: dynnr_tfill LIKE sy-tfill.
DATA: variscreens_tfill LIKE sy-tfill.
DATA: dmore_icon(40).
DATA: BEGIN OF  global_objects OCCURS 10,
        name LIKE rsscr-name,
      END   OF  global_objects.
DATA: BEGIN OF dyn_tab OCCURS 10,
        dbfield LIKE rsscr-dbfield,
      END   OF dyn_tab.
CONSTANTS: c_p_column     TYPE i VALUE 38,
           c_i_column     TYPE i VALUE 41,
           c_n_column     TYPE i VALUE 44,
           c_s_column     TYPE i VALUE 47,
           c_w_column     TYPE i VALUE 50,
           c_m_column     TYPE i VALUE 53,
           c_o_column     TYPE i VALUE 56,
           max_width_attr TYPE i VALUE 77.
CONSTANTS: max_width_selvar TYPE i VALUE 62.
DATA: flag_noimport.
DATA: curr_status(4).
DATA: screen_titles LIKE rsscritle OCCURS 10 WITH HEADER LINE.
RANGES v_range FOR varid-variant OCCURS 10.
DATA: flag_all_screens.
CONSTANTS: c_low                 TYPE i VALUE 34,
           c_high                TYPE i VALUE 62,
           c_to                  TYPE i VALUE 58,
           c_output_length       TYPE i VALUE 24,
           c_display_length      TYPE i VALUE 87,
           c_display_length_attr TYPE i VALUE 104,
           c_display_length_cat  TYPE i VALUE 118,
           c_no                  VALUE '0',
           c_dynnr               LIKE screen-name VALUE 'RSVAR-DYNNR',
           c_icon_more           LIKE screen-name VALUE 'DMORE_ICON',
           c_screen_1000         LIKE sy-dynnr VALUE '1000'.

DATA: belonging_dynnr LIKE rsdynnr OCCURS 10 WITH HEADER LINE.
DATA: prefix(20).
DATA: d_320_text(35).
DATA: old_vari LIKE rsvar-variant.
DATA: l_submode LIKE glob_submode.
DATA: icon_1(40), icon_2(40), icon_3(40), icon_4(40).
DATA: flag_icon_1, flag_icon_2, flag_icon_3, flag_icon_4.
DATA: flag_called_from_selscreen.
DATA: varivar_text LIKE rsvava-vtext.
DATA: varivar_kind LIKE rsscr-kind.
DATA: list_line LIKE sy-lilli.
DATA: mod_line LIKE sy-lilli.
DATA: g_sp TYPE syldb_sp.
DATA: g_range      TYPE rsds_range,
      g_frange     TYPE rsds_frange,
      g_rsdsselopt LIKE rsdsselopt.
DATA: g_ill_char.
DATA: flag_change_variant.
DATA: exit_flag.
DATA: comp_nodi_name LIKE rsscr-name.
DATA: exclude LIKE rsexfcode OCCURS 0 WITH HEADER LINE.
* hidefelder für Attributebild.
DATA: hide(10).
* Feldbeschreibung aufgeklappt oder zugeklappt
DATA: state(4).
DATA: no_display_visible TYPE boolean VALUE 'F'.
DATA: read_line LIKE sy-index.
CONSTANTS: c_collapse(4) VALUE 'COLL',
           c_expand(4)   VALUE 'EXPA',
           c_true        VALUE 'T',
           c_false       VALUE 'F'.
CONSTANTS: cat_line_size TYPE i VALUE '127'.
DATA: g_exporep TYPE sy-repid.
DATA: subscreenprog  LIKE sy-repid,
      subscreendynnr LIKE sy-dynnr.
DATA: g_subc LIKE trdir-subc.
DATA: status_for_subscreens.

* Data for subscreen processing
DATA: BEGIN OF g_subscreen,
        ucomm       TYPE syucomm,
        submode(2),
        total       TYPE i,
        current     TYPE i,
        exclude     TYPE rsexfcode OCCURS 0,
        rkey        TYPE rsvarkey,
        variscreens TYPE rsdynnr OCCURS 0,
        sscr        TYPE rsscr OCCURS 0,
      END   OF g_subscreen.

*CLASS CL_EVENT_RECEIVEr1 DEFINITION DEFERRED.
*CLASS cl_event_receiver2 DEFINITION DEFERRED.
*CLASS cl_event_receiver3 DEFINITION DEFERRED.

*INCLUDE svarselo.
* Daten für ALV-GRID
DATA:
  gt_toolbar_excluding  TYPE ui_functions,
  gt_toolbar_excluding6 TYPE ui_functions,
  grid1                 TYPE REF TO cl_gui_alv_grid,
  grid2                 TYPE REF TO cl_gui_alv_grid,
  alv_fieldcat          TYPE lvc_t_fcat WITH HEADER LINE,
  alv_fieldcat2         TYPE lvc_t_fcat WITH HEADER LINE,
  alv_fieldcat2_DYN     TYPE lvc_t_fcat WITH HEADER LINE,
  grid3                 TYPE REF TO cl_gui_alv_grid,
  grid3_dyn             TYPE REF TO cl_gui_alv_grid,
  alv_fieldcat3         TYPE lvc_t_fcat WITH HEADER LINE,
  alv_fieldcat3_dyn     TYPE lvc_t_fcat WITH HEADER LINE,
  grid4                 TYPE REF TO cl_gui_alv_grid,
  gt_exc_4              TYPE TABLE OF alv_s_qinf,
  grid5                 TYPE REF TO cl_gui_alv_grid,
  gt_exc_5              TYPE TABLE OF alv_s_qinf,
  alv_fieldcat4         TYPE lvc_t_fcat WITH HEADER LINE,
  grid6                 TYPE REF TO cl_gui_alv_grid,
*  event_receiver1       TYPE REF TO CL_EVENT_RECEIVEr1,
*  event_receiver2       TYPE REF TO cl_event_receiver2,
*  event_receiver3       TYPE REF TO cl_event_receiver3,
  selected              VALUE 'X',
  alv_layout            TYPE lvc_s_layo,
  alv_layout_attr       TYPE lvc_s_layo,
  alv_layout_f4         TYPE lvc_s_layo,
  alv_STABLE            TYPE lvc_s_stbl,
  row_table             TYPE lvc_t_row        WITH HEADER LINE,
  alv_container_1       TYPE REF TO cl_gui_custom_container,
  alv_container_2       TYPE REF TO cl_gui_custom_container.
DATA: alv_container_3      TYPE REF TO cl_gui_custom_container.
DATA: alv_container_3_DYN  TYPE REF TO cl_gui_custom_container.
DATA: alv_container_4      TYPE REF TO cl_gui_custom_container.
DATA: alv_container_5      TYPE REF TO cl_gui_custom_container.
DATA: alv_container_6      TYPE REF TO cl_gui_custom_container.

DATA: BEGIN OF v_display OCCURS 10,
        screen LIKE vanz-screennr,
        name   LIKE rvari-name,
        text   LIKE vanz-text,
        kind   LIKE rsparams-kind,
        sign   LIKE rsparams-sign,
        option LIKE rsparams-option,
        low    LIKE rsparamsl_255-low,
        high   LIKE rsparamsl_255-high,
        hint   type text255.
DATA: handle_style         TYPE lvc_t_styl.
DATA: END OF v_display.

DATA: BEGIN OF v_display_dyn OCCURS 10,
        tablename TYPE tldb_text,
        fieldname LIKE rsseldyn-fieldname,
        kind      LIKE rsparams-kind,
        sign      LIKE rsparams-sign,
        option    LIKE rsparams-option,
        low       LIKE rsparams-low,
        high      LIKE rsparams-high.
DATA: END OF v_display_dyn.

* Erweitete Tabelle für Variantenattribute
DATA: BEGIN OF ATTR_outtab OCCURS 0.  "with header line
        INCLUDE STRUCTURE saveinfo.
DATA:   vopti LIKE rsoptiicon-icon.
DATA:  vtext LIKE rsvava-vtext.
DATA: celltab TYPE lvc_t_styl.
*DATA: handle_style         type lvc_t_styl.
DATA: END OF ATTR_outtab.

data: save_attr_outtab like ATTR_outtab[].

DATA: BEGIN OF ATTR_outtab_DYN OCCURS 0.  "with header line
*        include structure SAVEINFO.
DATA: name        LIKE rsdstabs-prim_fname,
      numb        LIKE rvari-numb,
      protected   LIKE rvari-protected,
      fieldtext   LIKE rsvar-fieldtext,
      kind        LIKE rvari-kind,
      type        LIKE rvari-type,
      vtype       LIKE rvari-vtype,
      vname       LIKE rvari-vname,
*        appendage I= Matchcode, C=Checkbox etc
      appendage   LIKE rsvar-invisible,
      varis(1),                     " TVARV, FUBAU
*        N= Ausgeblendet von Report,X ausgeblendet in Variante
      invisible,
      user,
      memoryid    LIKE rsscr-spagpa,
*        nur auf einem Bild vorhanden
      global,
      no_import,
      spagpa,
      nointervals,
      obligatory  LIKE rsvar-obligatory,
      radio.
DATA: tablename LIKE rsdstabs-prim_tab,
      tabletext TYPE tldb_text.
DATA:  vopti LIKE rsoptiicon-icon.
DATA:  vtext LIKE rsvava-vtext.
DATA: celltab TYPE lvc_t_styl.
DATA: END OF ATTR_outtab_DYN.

data: save_ATTR_outtab_DYn like ATTR_outtab_DYN[].

DATA: BEGIN OF tab_screen OCCURS 3,
        markfield LIKE rsvar-markfield,
        dynnr     LIKE rsdynnr-dynnr,
        text      LIKE vanz-text,
        kind      LIKE rsdynnr-kind.
DATA: END OF tab_screen.

DATA: BEGIN OF f4tab OCCURS 3,
        vtype   TYPE s_class,
        sign    TYPE twfsa-sign,
        opti    TYPE twfsa-opt,
        descr   TYPE c LENGTH 50,
        celltab TYPE lvc_t_styl,
        runt_fb TYPE  rs38l_fnam,
      END OF f4tab.

DATA: alv_f4cat     TYPE lvc_t_fcat WITH HEADER LINE,
      alv_f4cat_dyn TYPE lvc_t_fcat WITH HEADER LINE.
DATA: alv_container_7 TYPE REF TO cl_gui_custom_container,
      alv_container_8 TYPE REF TO cl_gui_custom_container.
* DATA: GRID7                TYPE REF TO CL_GUI_ALV_GRID,
*       GRID8                TYPE REF TO CL_GUI_ALV_GRID.

DATA: flag1, flag2, t1, t2, title1, title2.
CONTROLS: screenlist TYPE TABLEVIEW USING SCREEN 0315.
DATA: BEGIN OF choose_dynnr_EXT OCCURS 0.
        INCLUDE STRUCTURE choose_dynnr.
DATA: text(20).
DATA: END OF choose_dynnr_ext.

*CLASS lcl_application_f4 DEFINITION DEFERRED.
*DATA: f4_double     TYPE REF TO lcl_application_f4.
*DATA: f4_double_dyn TYPE REF TO lcl_application_f4.

*INCLUDE lsvarcls.

CONSTANTS: c_search VALUE 'S'.
DATA  g_cli_indep.
DATA:
  g_titlebar     TYPE string,
  g_header_lines TYPE string_table.


**felipe rodz comentado 2da linea
DATA: g_ok_0100      TYPE sy-ucomm.
*      g_ref_settings TYPE REF TO if_svar_settings.
