*&---------------------------------------------------------------------*
*& Include ZONPG_ONECONNECT_CUS_EXE_TOP             - Module Pool      ZONPG_ONECONNECT_CUST_EXE
*&---------------------------------------------------------------------*
PROGRAM zonpg_oneconnect_cust_exe.

TABLES: rsvar,                    " new RALDB structure
        rsvardesc,                " Report, Variante, Dynnr
        zonta_oc_variant.


INCLUDE <icon>.
TYPE-POOLS: rsds.

CLASS lcl_grid_event_receiver DEFINITION DEFERRED.
CLASS lcl_event_handler       DEFINITION DEFERRED.
CLASS lcl_event_handler_any   DEFINITION DEFERRED.
CLASS lcl_application         DEFINITION DEFERRED.

CONSTANTS: c_true         TYPE flag   VALUE 'X', " use discouraged
           co_true        TYPE flag   VALUE 'X', " for oo-naming convention
           c_false        TYPE flag   VALUE ' ', " use discouraged
           co_false       TYPE flag   VALUE ' ', "follows oo-naming convention
           c_on           TYPE flag   VALUE '1',
           c_off          TYPE flag   VALUE '0',
           co_display     TYPE string VALUE 'Display',
           co_change      TYPE string VALUE 'Change',
           c_tables       TYPE string VALUE 'ZONST_TABLES_ALV',
           c_any          TYPE zonde_domain VALUE 'ANY',
           c_x            TYPE c      VALUE 'X',
           c_guion        TYPE c      VALUE '_',
           c_mandt        TYPE string VALUE 'MANDT',
           c_table        TYPE zonde_oc_transmedium VALUE 'T',
           c_kdoc         TYPE zonde_oc_transmedium VALUE 'K',
           c_both         TYPE zonde_oc_transmedium VALUE 'B',
           c_transmission TYPE string VALUE 'TRANSMISSION_MEDIUM',
           c_destination  TYPE string VALUE 'RFC_DESTINATION',
           c_proc_log     TYPE string VALUE 'PROCESS_LOG',
           c_slg1         TYPE zonde_oc_log_type VALUE 'S',
           c_file         TYPE zonde_oc_log_type VALUE 'F',
           c_class_sample TYPE c LENGTH 20 VALUE 'ZONCL_SAMPLE_CODE',
           c_class        TYPE c LENGTH 5  VALUE 'CLASS',
           c_relat        TYPE c LENGTH 5  VALUE 'RELAT',
           c_rentity      TYPE nriv-object VALUE 'ZONR_ENTIT',
           c_rcol_all     TYPE nriv-object VALUE 'ZONR_COL_A'.


TYPES: BEGIN OF st_tables_alv,
         celltab TYPE lvc_t_styl.
         INCLUDE STRUCTURE zonst_tables_alv.
TYPES END OF st_tables_alv.

TYPES: BEGIN OF st_columns_alv,
         celltab   TYPE lvc_t_styl,
         positionf TYPE tabfdpos.
         INCLUDE STRUCTURE zonst_columns_alv.
TYPES END OF st_columns_alv.

TYPES: BEGIN OF st_columns_any,
         celltab TYPE lvc_t_styl,
         json    TYPE zonde_keyflag.
         INCLUDE STRUCTURE zonst_columns_alv.
TYPES END OF st_columns_any.

TYPES: BEGIN OF st_auth_alv,
         celltab TYPE lvc_t_styl,
         fiel    TYPE  xufield,
         val     TYPE xuval.
TYPES END OF st_auth_alv.

*TYPES: BEGIN OF st_variant_alv,
*         celltab TYPE lvc_t_styl.
*         INCLUDE STRUCTURE zonst_oc_variant.
*TYPES END OF st_variant_alv.


DATA: BEGIN OF saveinfo OCCURS 20,
*        name        LIKE rvari-name,
*        numb        LIKE rvari-numb,
*        protected   LIKE rvari-protected,
        tabname    TYPE tabname,
        fieldtext  LIKE rsvar-fieldtext,
*        kind        LIKE rvari-kind,
        type       LIKE rvari-type,
        vtype      TYPE zonde_oc_rsvarsvar, "rvari-vtype,
        vname      LIKE rvari-vname,
        option     TYPE raldb_opti_f4,
        sign       TYPE raldb_sign,
        sapvar     TYPE zonde_oc_sapvar,
        val1       TYPE zonde_offset1,
        sign1      TYPE zonde_sign,
        val2       TYPE zonde_offset2,
        sign2      TYPE zonde_sign,
        created_by TYPE ernam,
        created_on TYPE vari_vdate,

      END OF saveinfo.
TYPES: BEGIN OF st_variant_alv .
         INCLUDE STRUCTURE saveinfo.
TYPES:   vopti LIKE rsoptiicon-icon.
TYPES:  vtext LIKE rsvava-vtext.
TYPES:   celltab TYPE lvc_t_styl.
TYPES: END OF st_variant_alv.

TYPES: BEGIN OF st_tlock,
         object TYPE trobjtype,
         key    TYPE trobj_name,
         hikey  TYPE c LENGTH 120, "lockarg,
         lokey  TYPE c LENGTH 120, "lockarg,
         trkorr TYPE trkorr,
       END OF st_tlock.

TYPES: BEGIN OF st_converted.
         INCLUDE TYPE zonta_oc_conv.
TYPES:   field30 TYPE zonde_fieldname1,
         lenght  TYPE i,
       END OF st_converted.


TYPES: BEGIN OF st_varatt,
         celltab   TYPE lvc_t_styl,
         sign      TYPE raldb_sign,
         option    TYPE raldb_opti_f4,
         attribute TYPE zonde_descriptions,
         variable  TYPE zonde_oc_sapvar,
       END OF st_varatt.



DATA: gt_columns_alv     TYPE TABLE OF st_columns_alv,
      gt_columns_any_alv TYPE TABLE OF st_columns_any,
      gt_tables_alv      TYPE TABLE OF st_tables_alv,
      gt_filters_alv     TYPE TABLE OF zonta_oc_filters,
      gt_auth_alv        TYPE TABLE OF st_auth_alv,
      gs_auth            TYPE zonta_oc_auth,
      gt_ycolumns        TYPE TABLE OF zonta_oc_col_all,
      gt_yrelations      TYPE TABLE OF zonta_relations,
      gt_regen           TYPE TABLE OF zonta_relations,
      gt_vardyn          TYPE STANDARD TABLE OF zonta_oc_vardyn,
      gt_col_alld        TYPE STANDARD TABLE OF zonta_oc_col_all,
      gt_varatt          TYPE TABLE OF st_varatt,
      gs_varatt          TYPE st_varatt,
      gv_xxstring        TYPE string,
      gv_yystring        TYPE string,
      gv_xxval           TYPE n LENGTH 3,
      gv_xxsign          TYPE raldb_sign,
      gv_yyval           TYPE n LENGTH 3,
      gv_yysign          TYPE raldb_sign,
      gv_screenv         TYPE c.


TABLES: zonta_obj_oc,
        zonta_oc_auth.

DATA : pb_mic LIKE icons-l4,
       pb_tic LIKE icons-l4,
       pb_cic LIKE icons-l4.


DATA: gv_okcode         TYPE sy-ucomm,
      gv_mode           TYPE smp_dyntxt,
      gv_option         TYPE string,
      gv_subscreen_300  TYPE string,
      gv_mains          TYPE boolean,
      gv_tabless        TYPE boolean,
      gv_columnss       TYPE boolean,
      gv_screen         TYPE sy-dynnr,
      gv_order          TYPE e071-trkorr, "++TRKORR DB
      gv_variant        TYPE variant,
      gv_variant_old    TYPE boolean,
      gv_variantd_exist TYPE boolean,
      gv_variant_exist  TYPE boolean,
      gx_text           TYPE REF TO cx_root.



DATA: g_grid0100        TYPE REF TO cl_gui_alv_grid,
      events0100        TYPE REF TO lcl_grid_event_receiver,
      lo_event_handler  TYPE REF TO lcl_event_handler,
      lo_event_handlera TYPE REF TO lcl_event_handler_any,
      g_container0100   TYPE REF TO cl_gui_custom_container.


DATA: gt_obj_oc  TYPE STANDARD TABLE OF zonta_obj_oc,
      gt_domains TYPE STANDARD TABLE OF zonta_domains.


DATA: gt_tables        TYPE STANDARD TABLE OF zonta_relations,
      gt_common_ent    TYPE STANDARD TABLE OF zonta_relations,
      gt_columns       TYPE STANDARD TABLE OF zonta_oc_col_all,
      gt_ex_rel        TYPE STANDARD TABLE OF zonta_relations,
      gt_ex_col        TYPE STANDARD TABLE OF zonta_oc_col_all,
      gt_columns_any   TYPE STANDARD TABLE OF zonta_oc_col_all,
      gs_col_info      TYPE zonta_oc_columns,
      gt_col_info      TYPE zontt_col_all,
      gt_relations     TYPE STANDARD TABLE OF zonta_relations,
      gt_filters       TYPE STANDARD TABLE OF zonta_oc_filters,
      gt_franges       TYPE STANDARD TABLE OF zonta_oc_franges,
      gt_filters_new   TYPE STANDARD TABLE OF zonta_oc_filters,
      gt_franges_new   TYPE STANDARD TABLE OF zonta_oc_franges,
      gt_variant       TYPE STANDARD TABLE OF zonta_oc_franges,
      gt_variantd      TYPE STANDARD TABLE OF zonta_oc_variant,
      gt_variant_alv   TYPE STANDARD TABLE OF st_variant_alv,
      gt_cond_tab      TYPE rsds_twhere,
      gt_field_ranges  TYPE rsds_trange,
      gt_fieldtab      TYPE STANDARD TABLE OF rsdsfields,
      gt_fcat_tables   TYPE lvc_t_fcat,
      gt_fcat_variant  TYPE lvc_t_fcat,
      gt_fcat_columns  TYPE lvc_t_fcat,
      gt_fcat_col_any  TYPE lvc_t_fcat,
      gt_fcat_varatt   TYPE lvc_t_fcat,
      gt_fcat_auth     TYPE lvc_t_fcat,
      gt_selected_rows TYPE lvc_t_row,
      gs_variant_alv   LIKE LINE OF gt_variant_alv,
      gs_alv_layout_t  TYPE lvc_s_layo,
      gs_cell_type_t   TYPE lvc_s_styl,
      gs_alv_layout_c  TYPE lvc_s_layo,
      gs_alv_layout_ca TYPE lvc_s_layo,
      gs_cell_type_c   TYPE lvc_s_styl,
      gt_celltab       TYPE lvc_t_styl,
      gt_celltab_all   TYPE lvc_t_styl,
      gs_ex_rel        LIKE LINE OF gt_ex_rel,
      gs_ex_col        LIKE LINE OF gt_ex_col,
      gs_exclude       TYPE ui_func,
      gt_exclude       TYPE ui_functions,
      gt_exclude_col   TYPE ui_functions,
      gt_param         TYPE STANDARD TABLE OF zonta_oc_param,
      gt_converted     TYPE STANDARD TABLE OF zonta_oc_conv,
      gt_convertedt    TYPE STANDARD TABLE OF st_converted.

DATA: lo_container_tables  TYPE REF TO cl_gui_custom_container,
      lo_alv_tables        TYPE REF TO cl_gui_alv_grid,
      lo_container_columns TYPE REF TO cl_gui_custom_container,
      lo_alv_columns       TYPE REF TO cl_gui_alv_grid,
      lo_container_col_any TYPE REF TO cl_gui_custom_container,
      lo_alv_col_any       TYPE REF TO cl_gui_alv_grid,
      lo_container_auth    TYPE REF TO cl_gui_custom_container,
      lo_alv_auth          TYPE REF TO cl_gui_alv_grid,
      lo_container_variant TYPE REF TO cl_gui_custom_container,
      lo_alv_variant       TYPE REF TO cl_gui_alv_grid,
      lo_container_varatt  TYPE REF TO cl_gui_custom_container,
      lo_alv_varatt        TYPE REF TO cl_gui_alv_grid.


DATA:
  gt_clogsg TYPE STANDARD TABLE OF aqclsg,
  gt_dbsa   TYPE STANDARD TABLE OF aqdbsa,
  gt_dbob  	TYPE STANDARD TABLE OF aqdbob,
  gt_dbos   TYPE STANDARD TABLE OF aqdbos,
  gt_dbif   TYPE STANDARD TABLE OF aqdbif,
  gt_dbsf   TYPE STANDARD TABLE OF aqdbsf,
  gt_dbsg   TYPE STANDARD TABLE OF aqdbsg,
  gt_dban   TYPE STANDARD TABLE OF aqdban,
  gt_dbjt   TYPE STANDARD TABLE OF aqdbjt,
  gt_dbjc   TYPE STANDARD TABLE OF aqdbjc,
  gt_dbzt   TYPE STANDARD TABLE OF aqdbzt,
  gt_dbzc   TYPE STANDARD TABLE OF aqdbzc,
  gt_dbzl   TYPE STANDARD TABLE OF aqdbzl,
  gt_dbdp   TYPE STANDARD TABLE OF aqdbdp,
  gt_dbpa   TYPE STANDARD TABLE OF aqdbpa,
  gt_dbwr   TYPE STANDARD TABLE OF aqdbwr,
  gt_dbar   TYPE STANDARD TABLE OF aqdbar,
  gt_dbft   TYPE STANDARD TABLE OF aqdbft,
  gt_sgtext TYPE STANDARD TABLE OF aqtxsg,
  gt_exdbfi TYPE aqq_t_exdbfi,
  gt_ttab   TYPE aqq_t_ttab,
  gt_join   TYPE aqq_t_join.

DATA:
  gv_headsg LIKE  aqhdsg,
  gv_maxsg  TYPE  aqs_tindx.

DATA: gv_size       TYPE zonde_oc_num30,
      gv_records    TYPE zonde_oc_num30,
      gv_error      TYPE boolean,
      gv_path_error TYPE boolean,
      gv_ini        TYPE boolean.

DATA: go_cust TYPE REF TO zoncl_oc_customizing,
      go_json TYPE REF TO zoncl_fetch_data. "_v2.  "NEWV

DATA: gv_endpoint TYPE rfcdest,
      alias       TYPE boolean,
      both_tl     TYPE boolean,
      name        TYPE boolean,
      slg1        TYPE boolean,
      file        TYPE boolean,
      table       TYPE boolean,
      kdoc        TYPE boolean,
      both        TYPE boolean,
      prlog       TYPE boolean.


DATA node_itab_left    TYPE treemsnota.
DATA deleted_node_itab TYPE treemsnota.
DATA node_itab_right   TYPE treemsnota.
DATA node TYPE treemsnodt.

DATA container TYPE REF TO cl_gui_custom_container.
DATA splitter TYPE REF TO cl_gui_easy_splitter_container.
DATA right TYPE REF TO cl_gui_container.
DATA left  TYPE REF TO cl_gui_container.

DATA tree_right TYPE REF TO cl_simple_tree_model.
DATA tree_left TYPE REF TO cl_simple_tree_model.

DATA behaviour_left TYPE REF TO cl_dragdrop.
DATA behaviour_right TYPE REF TO cl_dragdrop.

DATA handle_tree_left TYPE i.
DATA handle_tree_right TYPE i.

DATA: g_application TYPE REF TO lcl_application.

DATA: g_event(30),
      g_node_key(30) TYPE c.


DATA picture TYPE REF TO cl_gui_picture.
* Definition of Control Framework
CLASS cl_gui_cfw DEFINITION LOAD.

CONSTANTS: cntl_true  TYPE i VALUE 1,
           cntl_false TYPE i VALUE 0.
DATA:h_picture       TYPE REF TO cl_gui_picture,
     h_pic_container TYPE REF TO cl_gui_custom_container.

DATA: graphic_url(255),
      graphic_refresh(1),
      g_result LIKE cntl_true.

DATA: BEGIN OF graphic_table OCCURS 0,
        line(255) TYPE x,
      END OF graphic_table.

DATA: graphic_size TYPE i.


DATA: g_stxbmaps TYPE stxbitmaps,
      l_bytecnt  TYPE i,
      l_content  TYPE  STANDARD TABLE OF bapiconten INITIAL SIZE 0.


DATA: l_graphic_xstr TYPE xstring,
      l_graphic_conv TYPE i,
      l_graphic_offs TYPE i.


DATA:
  gv_file       TYPE rlgrap-filename,
  gv_workb      TYPE char50,
  gv_endr       TYPE i,
  r_customizing TYPE c,
  r_columns     TYPE c.


TYPES: BEGIN OF ty_rec,
         workb TYPE string,
         row   TYPE string,
         f0001 TYPE string,
         f0002 TYPE string,
         f0003 TYPE string,
         f0004 TYPE string,
         f0005 TYPE string,
         f0006 TYPE string,
         f0007 TYPE string,
         f0008 TYPE string,
         f0009 TYPE string,
         f0010 TYPE string,
         f0011 TYPE string,
         f0012 TYPE string,

       END OF ty_rec,

       tt_rec TYPE TABLE OF ty_rec,

       BEGIN OF ty_rep,
         workb         TYPE char20,
         rown          TYPE char5,
         tabname       TYPE tabname,
         fldname       TYPE fieldname,
         alias_fldname TYPE zonde_aliasfld,
       END OF ty_rep,
       tt_rep TYPE TABLE OF ty_rep.

DATA: gt_recs TYPE tt_rec,
      gt_rep  TYPE tt_rep.

DATA: gv_tablen         TYPE tabname,
      gv_tablenf        TYPE string,
      gv_tablea         TYPE tabname,
      gv_tableaf        TYPE string,
      gv_new            TYPE boolean,
      gv_new_excel      TYPE boolean, "CECHAVARRIA 29/07/2025
      gv_edita          TYPE boolean,
      gv_changes_rel    TYPE boolean,
      gv_changes_col    TYPE boolean,
      gv_changes_col_ex TYPE boolean,
      gv_alias          TYPE boolean,
      gv_fieldname      TYPE boolean,
      gv_bothtl         TYPE boolean,
      gv_tag2           TYPE zonde_tag2,
      gv_tag3           TYPE zonde_tag3,
      gv_system         TYPE boolean,
      gv_entity_type    TYPE c LENGTH 10,
      gv_cloned_entity  TYPE zonde_process,
      gv_cloned_domain  TYPE zonde_domain,
      gv_authorization  TYPE boolean,
      gv_alias_error    TYPE boolean,
      gv_index_v        TYPE sy-tabix,
      gv_entity         TYPE zonta_obj_oc-business_proc,
      gv_domainv        TYPE zonta_obj_oc-domainv.

DATA: mes1 TYPE string,
      mes2 TYPE string,
      cfilter  TYPE c,
      cvariant TYPE c.

DATA: gt_bdcdata TYPE STANDARD TABLE OF bdcdata,
      gs_bdcdata TYPE bdcdata,
      gt_messtab TYPE STANDARD TABLE OF bdcmsgcoll,
      gs_messtab TYPE bdcmsgcoll.

TYPES: BEGIN OF onf4_event_parameters_type.
TYPES: c_fieldname     TYPE lvc_fname.
TYPES: cs_row_no       TYPE lvc_s_roid.
TYPES: cr_event_data   TYPE REF TO cl_alv_event_data.
TYPES: ct_bad_cells    TYPE lvc_t_modi.
TYPES: c_display       TYPE char01.
TYPES: END OF onf4_event_parameters_type.

DATA: f4_params       TYPE onf4_event_parameters_type.
DATA: alv_container_7 TYPE REF TO cl_gui_custom_container,
      grid7           TYPE REF TO cl_gui_alv_grid,
      alv_layout      TYPE lvc_s_layo,
      alv_layout_attr TYPE lvc_s_layo.

DATA: alv_f4cat     TYPE lvc_t_fcat WITH HEADER LINE,
      alv_f4cat_dyn TYPE lvc_t_fcat WITH HEADER LINE.



DATA: save_okcode(4).


DATA: BEGIN OF attr_outtab_dyn OCCURS 0.  "with header line
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
DATA: END OF attr_outtab_dyn.

DATA: BEGIN OF f4tab OCCURS 3,
        vtype   TYPE s_class,
        sign    TYPE twfsa-sign,
        opti    TYPE twfsa-opt,
        descr   TYPE c LENGTH 50,
        celltab TYPE lvc_t_styl,
        runt_fb TYPE  rs38l_fnam,
      END OF f4tab.
