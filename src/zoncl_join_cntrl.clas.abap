class ZONCL_JOIN_CNTRL definition
  public
  create public .

*"* public components of class ZONCL_JOIN_CNTRL
*"* do not include other source files here!!!
public section.
  type-pools ICON .

  data GT_TPOS type AQQ_T_TPOS .
  data GT_JOIN type AQQ_T_JOIN .

  methods CHECK_CONDITIONS
    exporting
      !E_TNAME type AQS_TNAME
      !E_ADJUST type BOOLEAN
      !E_TJOIN type AQQ_T_JOIN
    exceptions
      NOT_RIGHT
      ZERO_TABLES
      ONLY_ONE_TABLE .
  methods CONSTRUCTOR
    importing
      !I_R_CONTAINER_PARENT type ref to CL_GUI_CUSTOM_CONTAINER
      !I_JOIN_DATA_R type ref to CL_QUERY_JOIN_DATA
      !I_MODE type AQQIS_MODE .
  methods HANDLE_FCODE
    importing
      !I_FCODE type SYUCOMM
      !IR_TABLE type ref to IF_AQQGRAPHIC_TABLE optional
      !IR_LINK type ref to IF_AQQGRAPHIC_LINK optional
      !I_ROWINDEX type INT2 optional .
  methods SET_MODE
    importing
      !I_MODE type AQQIS_MODE .
  methods SYNCHRONIZE_POSITIONS
    importing
      !IV_NO_CANCEL_ON_ERROR type BOOLEAN optional
    exceptions
      NO_DATA_ON_CONTROL .
  methods GET_TPOS
    exporting
      !ET_TPOS type AQQ_T_TPOS
      !ET_JOIN type AQQ_T_JOIN .
protected section.
*"* protected components of class ZONCL_JOIN_CNTRL1
*"* do not include other source files here!!!
private section.

*"* private components of class ZONCL_JOIN_CNTRL
*"* do not include other source files here!!!
  data P_MODE type AQQIS_MODE .
  data PT_TFIELD type AQQ_T_TFIELD .
  data PT_TPOS type AQQ_T_TPOS .
  data PT_JOIN type AQQ_T_JOIN .
  data P_R_JOIN_CNTRL type ref to IF_GUI_AQQGRAPHIC .
  data P_T_TOBJ_JOIN type AQQ_T_TOBJ_JOIN .
  data P_T_LINKS_JOIN type AQQ_T_LINKS_JOIN .
  data P_JOIN_DATA_R type ref to CL_QUERY_JOIN_DATA .
  data P_DEFAULT_LINKSTYLE type AQQ_STYLE .
  data PT_TABLEPOS type AQQ_T_TABLEPOS .
  data PS_SEARCH type AQSSEARCH .
  data P_START_TABIX type SYTABIX .
  data P_SEARCH_OBJ type ref to IF_AQQGRAPHIC_TABLE .
  data P_TAB_STARTX type I value 50 ##NO_TEXT.
  data P_TAB_STARTY type I value 50 ##NO_TEXT.
  data P_TAB_WIDTH type I value 250 ##NO_TEXT.
  data P_TAB_HEIGHT type I value 200 ##NO_TEXT.

  methods ABS_2_REL
    importing
      !IS_TABLEPOS type AQSTABPOS
    exporting
      !ES_TPOS type AQQ_S_TPOS .
  methods ADD_LINKS_TO_JOIN .
  methods ADD_TABLES_TO_JOIN .
  methods ADD_TFIELD
    importing
      !I_TNAME type AQS_TNAME
    exceptions
      EXISTING .
  methods ADD_TOBJECT .
  methods ADD_TPOS
    importing
      !I_TNAME type AQS_TNAME
    exceptions
      EXISTING .
  methods ALIASTABLE .
  methods CHECK .
  methods CHECK_REMOVE_TOBJECT
    importing
      !I_TNAME type AQS_TNAME
    exceptions
      ONLY_ONE_TABLE
      TABLE_IS_USED
      NO_REMOVE_IN_QUICKVIEW .
  methods CNT_MARKED_LINES_PER_TAB
    importing
      !IR_TABLE type ref to IF_AQQGRAPHIC_TABLE
    returning
      value(E_LINES_MARKED) type I .
  methods CNT_MARKED_TABS
    returning
      value(E_MARKED_TABS) type I .
  methods CNVT_FNAME_ONE_2_TWO
    importing
      !I_FNAME type AQS_FNAME
    exporting
      !E_TNAME type AQS_TNAME
      !E_FNAME type AQS_FNAME .
  methods CNVT_TABLES_TO_NEW
    importing
      !I_FIRST_TABLE_APOS type FLAG .
  methods CNVT_TABLE_TO_OLD .
  methods CNVT_TABLE_TO_OLD_DBJC .
  methods CNVT_TABLE_TO_OLD_DBJT .
  methods CREATE_LINK
    importing
      !IR_TABL type ref to IF_AQQGRAPHIC_TABLE
      !IR_TABR type ref to IF_AQQGRAPHIC_TABLE
      !I_ROWL type SYTABIX
      !I_ROWR type SYTABIX .
  methods CREATE_LINKS
    importing
      !IT_JOIN type AQQ_T_JOIN .
  methods DISPLAY_DDIC
    importing
      !IR_TABLE type ref to IF_AQQGRAPHIC_TABLE .
  methods EXECUTE_JOIN_MODIFICATION
    importing
      !IS_JOIN type AQQ_S_JOIN
      !IR_LINK type ref to IF_AQQGRAPHIC_LINK .
  methods FETCH_OUTERFLAG_TEXT
    importing
      !IR_TABL type ref to IF_AQQGRAPHIC_TABLE
      !IR_TABR type ref to IF_AQQGRAPHIC_TABLE
    returning
      value(R_TEXT) type AQQ_TEXT .
  methods FIELDDOCU
    importing
      !IR_TABLE type ref to IF_AQQGRAPHIC_TABLE
      !I_ROW type AQQ_ROWNR .
  methods FIELDREFERENCE
    importing
      !IR_TABLE type ref to IF_AQQGRAPHIC_TABLE
      !I_ROW type AQQ_ROWNR .
  methods FILL_TABLE_FIELDS
    importing
      !IS_DBJT type AQDBJT
    exporting
      !ES_TOBJ_JOIN type AQSTOBJJOI .
  methods FORCE_JOINTYPE
    importing
      !I_CHANGE_OLD type BOOLEAN
    changing
      !CS_JOIN type AQQ_S_JOIN
    exceptions
      INCONSISTENT .
  methods GET_SELECTED_TABLE
    exporting
      !E_TNAME type AQS_TNAME
    exceptions
      NO_TABLE_SELECTED
      SEVERAL_TABLES_SELECTED .
  methods GET_TAB
    importing
      !I_TABNAME type AQS_TNAME
    exporting
      !ET_TAB type AQQIS_T_TAB .
  methods HANDLE_LINK_CHANGED
    importing
      !I_R_LINK type ref to IF_AQQGRAPHIC_LINK
      !I_R_TAB_NEW type ref to IF_AQQGRAPHIC_TABLE
      !I_ROW_KEPT type AQQ_ROWNR
      !I_ROW_NEW type AQQ_ROWNR
      !I_R_TAB_KEPT type ref to IF_AQQGRAPHIC_TABLE
      !I_SUCC_CHANGED type BOOLEAN
    returning
      value(R_OK) type BOOLEAN .
  methods INIT
    importing
      !I_R_CONTAINER_PARENT type ref to CL_GUI_CONTAINER .
  methods INIT_JOIN_CNTRL
    importing
      !I_R_CONTAINER_PARENT type ref to CL_GUI_CONTAINER .
  methods IS_VALID_LINK
    importing
      !I_R_SUCCTAB type ref to IF_AQQGRAPHIC_TABLE
      !I_R_PREDTAB type ref to IF_AQQGRAPHIC_TABLE
      !I_SUCCROW type AQQ_ROWNR
      !I_PREDROW type AQQ_ROWNR
    exporting
      !E_VALID type BOOLEAN
      !E_TNAME1 type AQS_TNAME
      !E_TNAME2 type AQS_TNAME
      !E_FNAME1 type AQS_FNAME
      !E_FNAME2 type AQS_FNAME .
  methods JOIN_MODIFICATION
    importing
      !I_JOIN_TYP type AQQIS_JOIN_TYP
      !IR_LINK type ref to IF_AQQGRAPHIC_LINK .
  methods NAVIGATOR .
  methods ON_CONDITION .
  methods ON_HANDLE_CTXMNUREQ
    for event CTXMNUREQUEST of IF_GUI_AQQGRAPHIC
    importing
      !R_TABLE
      !ROWINDEX
      !R_LINK
      !BACKGROUND
      !R_CTXMNU .
  methods ON_HANDLE_CTXMNUSEL
    for event CTXMNUFCODESEL of IF_GUI_AQQGRAPHIC
    importing
      !R_TABLE
      !ROWINDEX
      !R_LINK
      !BACKGROUND
      !FCODE .
  methods ON_HANDLE_LINK_CREATED
    for event LINK_CREATED of IF_GUI_AQQGRAPHIC
    importing
      !R_NEWLINK
      !R_SUCCTAB
      !SUCC_ROW
      !R_PREDTAB
      !PRED_ROW
      !R_DOIT .
  methods ON_HANDLE_OBJDBLCLICK
    for event OBJECT_DOUBLE_CLICK of IF_GUI_AQQGRAPHIC
    importing
      !R_LINK
      !R_TABLE
      !ROW .
  methods ON_HANDLE_PRED_CHANGED
    for event LINK_PRED_CHANGED of IF_GUI_AQQGRAPHIC
    importing
      !R_LINK
      !R_PREDTAB
      !PREDROW
      !R_DOIT .
  methods ON_HANDLE_SUCC_CHANGED
    for event LINK_SUCC_CHANGED of IF_GUI_AQQGRAPHIC
    importing
      !R_LINK
      !R_SUCCTAB
      !SUCCROW
      !R_DOIT .
  methods PRINT_CONTROL .
  methods PROPOSE_ON_CONDITION
    importing
      !I_TABNAMEL type AQS_TNAME
      !I_TABNAMER type AQS_TNAME
    exceptions
      NO_JOINS_FOUND
      NO_FURTHER_JOINS_FOUND
      JOIN_ADDITION_INVALID .
  methods PROPOSE_ON_CONDITION_ADD_LINK
    importing
      !IS_JOIN type AQQ_S_JOIN .
  methods RECREATE_LINKS .
  methods REDUCE_DISTANCE .
  methods REFERENZFIELD
    importing
      !IS_TAB type AQQ_S_TAB
      !I_TNAME type AQS_TNAME .
  methods REL_2_ABS
    importing
      !IS_DBJT type AQDBJT
    exporting
      !ES_TPOS_ABS type AQSTPOSABS .
  methods REMOVE_LINK
    importing
      !IR_LINK type ref to IF_AQQGRAPHIC_LINK
      !R_DOIT type ref to CL_AQQGRAPHIC_DOIT optional .
  methods REMOVE_TOBJECT .
  methods REORDER_JOINS
    importing
      !IT_TPOS_NEW type AQQ_T_TPOS
      !IT_TPOS_OLD type AQQ_T_TPOS
    exporting
      !E_FORCED type BOOLEAN
    exceptions
      REORDER_INVALID .
  methods SAVE_AS_JPG .
  methods SCALE .
  methods SEARCH .
  methods SEARCH_DOMAIN_IN_TABOBJ
    importing
      !IS_SEARCH type AQSSEARCH
      !IT_TAB type AQQ_T_TAB
      !I_START_TABIX type SYTABIX
      !I_TNAME type AQS_TNAME
    exporting
      !E_FOUND type BOOLEAN
      !E_ROW type SYTABIX
      !ES_TOBJ_JOIN type AQSTOBJJOI .
  methods SEARCH_IN_TABOBJ
    importing
      !IS_SEARCH type AQSSEARCH
      !IT_TAB type AQQ_T_TAB
      !I_START_TABIX type SYTABIX
      !I_TNAME type AQS_TNAME
    exporting
      !E_FOUND type BOOLEAN
      !E_ROW type SYTABIX
      !ES_TOBJ_JOIN type AQSTOBJJOI .
  methods SEARCH_NEXT .
  methods SEARCH_TEXT_IN_TABOBJ
    importing
      !IS_SEARCH type AQSSEARCH
      !IT_TAB type AQQ_T_TAB
      !I_START_TABIX type SYTABIX
      !I_TNAME type AQS_TNAME
    exporting
      !E_FOUND type BOOLEAN
      !E_ROW type SYTABIX
      !ES_TOBJ_JOIN type AQSTOBJJOI .
  methods SEARCH_TYPE_IN_TABOBJ
    importing
      !IS_SEARCH type AQSSEARCH
      !IT_TAB type AQQ_T_TAB
      !I_START_TABIX type SYTABIX
      !I_TNAME type AQS_TNAME
    exporting
      !E_FOUND type BOOLEAN
      !E_ROW type SYTABIX
      !ES_TOBJ_JOIN type AQSTOBJJOI .
  methods SEND_TABLES_TO_CNTRL
    importing
      !I_T_TOBJ_JOIN type AQQ_T_TOBJ_JOIN .
  methods SET_CELL_PROPERTIES
    importing
      !I_S_TOBJ_JOIN type AQSTOBJJOI .
  methods SET_CHANGED
    importing
      !I_CHANGED type FLAG .
  methods SKALIERUNG_POPUP
    exporting
      !E_SCALEX type I
      !E_SCALEY type I
    exceptions
      CANCELLED .
  methods SYNCHRONIZE_CONTROL_DATA
    importing
      !IT_TPOS type AQQ_T_TPOS .
  methods TEST_JOIN_VALIDITY
    importing
      !IS_JOIN type AQQ_S_JOIN
    exporting
      !E_TABNAME1 type AQS_TNAME
      !E_TABNAME2 type AQS_TNAME
      !E_TABNAME3 type AQS_TNAME
    exceptions
      MODE_INVALID
      JOIN_TYPE_INVALID_LEFT
      JOIN_TYPE_INVALID_RIGHT
      JOIN_TYPE_INVALID_SIDE
      JOIN_TYPE_INVALID_TWICE
      JOIN_TYPE_INCONSISTENT
      TAB_NOT_FOUND
      FIELD_NOT_FOUND
      FIELDS_INVALID .
  methods ZOOMIN .
  methods ZOOMOUT .
ENDCLASS.



CLASS ZONCL_JOIN_CNTRL IMPLEMENTATION.


method ABS_2_REL .

  field-symbols: <tobj_join> type AQSTOBJJOI.

  read table p_t_tobj_join assigning <tobj_join> with key tabref = is_tablepos-r_table.
  check sy-subrc = 0.

*--- rel
  es_tpos-tabname   = <tobj_join>-tname.
  es_tpos-xpos      = is_tablepos-leftpos.
  es_tpos-ypos      = is_tablepos-toppos.
  es_tpos-width     = is_tablepos-rightpos - is_tablepos-leftpos.
  es_tpos-height    = is_tablepos-bottompos - is_tablepos-toppos.

endmethod.                                                  "ABS_2_REL


method ADD_LINKS_TO_JOIN .

  data: lt_join type aqq_t_join,
        l_row_l type sytabix,
        l_row_r type sytabix.

  field-symbols: <join> type aqq_s_join,
                 <tobj_join_l> type AQSTOBJJOI,
                 <tobj_join_r> type AQSTOBJJOI,
                 <fobj_join_l> type AQSFOBJJOI,
                 <fobj_join_r> type AQSFOBJJOI.

  lt_join[] = pt_join[].

  loop at lt_join assigning <join>.
    read table p_t_tobj_join assigning <tobj_join_l> with key tname = <join>-tabnamel.
    read table <tobj_join_l>-fobj assigning <fobj_join_l> with key fname = <join>-colnamel.
    l_row_l = sy-tabix.
    read table p_t_tobj_join assigning <tobj_join_r> with key tname = <join>-tabnamer.
    read table <tobj_join_r>-fobj assigning <fobj_join_r> with key fname = <join>-colnamer.
    l_row_r = sy-tabix.

    CREATE_LINK( EXPORTING IR_TABL = <tobj_join_l>-tabref
                           IR_TABR = <tobj_join_r>-tabref
                           I_ROWL  = l_row_l
                           I_ROWR  = l_row_r ).

  endloop.

  p_r_join_cntrl->send_data_to_frontend( ).

endmethod.                    "ADD_LINKS_TO_JOIN


method ADD_TABLES_TO_JOIN .

  data: lt_dbjt       type aqtdbjt,
        lt_dbjc       type aqtdbjc,
        ls_tobj_join  type aqstobjjoi.

  field-symbols: <dbjt>    type aqdbjt.

  p_join_data_r->get_info( importing et_dbjt   = lt_dbjt
                                     et_dbjc   = lt_dbjc ).

  loop at lt_dbjt assigning <dbjt>.
    if <dbjt>-left_vz is initial.
      <dbjt>-left_vz  = p_tab_startx.
    endif.
    if <dbjt>-top_vz is initial.
      <dbjt>-top_vz = p_tab_starty.
    endif.
    <dbjt>-width_vz  = p_tab_width.
    <dbjt>-height_vz = p_tab_height.

    fill_table_fields( exporting is_dbjt      = <dbjt>
                       importing es_tobj_join = ls_tobj_join ).

    append ls_tobj_join to p_t_tobj_join.
  endloop.

  send_tables_to_cntrl( exporting i_t_tobj_join = p_t_tobj_join ).
  p_r_join_cntrl->send_data_to_frontend( ).

endmethod.                    "ADD_TABLES_TO_JOIN


method ADD_TFIELD .

  data: lt_tfield  type aqq_t_tfield,
        ls_tfield  type aqstfield,
        lt_tab     type aqq_t_tab.

  field-symbols: <tab> type aqq_s_tab.

  lt_tfield[] = pt_tfield[].

  READ TABLE lt_TFIELD WITH KEY TABNAME = i_tname TRANSPORTING NO FIELDS.
  if sy-subrc eq 0.
*    raise existing.
    message I016(zon_cl_oc) DISPLAY LIKE 'I'.
  endif.

  GET_TAB( EXPORTING I_TABNAME = i_tname
           IMPORTING ET_TAB    = lt_tab ).

  loop at lt_tab assigning <tab>.
    ls_tfield-tabname = i_tname.
    ls_tfield-colname = <tab>-feld.
    if <tab>-key = aqqis_c_true.
      ls_tfield-iskey = 1.
    else.
      ls_tfield-iskey = 0.
    endif.
    append ls_tfield to lt_tfield.
  endloop.

  pt_tfield[] = lt_tfield[].
endmethod.                    "ADD_TFIELD


method ADD_TOBJECT .

  data: l_tab_new     type AQ_SEGNAME,
        lt_dbjt       type aqtdbjt,
        lt_ttab       type aqq_t_ttab,
        ls_tobj_join  type AQSTOBJJOI,
        lt_tobj_join  type aqq_t_tobj_join.

  field-symbols: <dbjt> type aqdbjt.

  if P_MODE = aqqis_c_mode-display.
*   Funktion nur im Änderungsmodus unterstützt
    message s005(aqqis_cntrl).
    exit.
  endif.

*--- Popup: welche Tabelle eingefügt werden soll
*    Die Abfrage, ob Tabelle schon auf dem Control existiert, erfolgt in der
*    Dynprologik
  CALL FUNCTION 'ZONFM_RSAQ_CNTRL_ADD_TAB_0300' "'RSAQ_CNTRL_ADD_TAB_0300' ONEC
    IMPORTING
      E_TAB     = l_tab_new
    EXCEPTIONS
      cancelled = 1
      others    = 99.

  if sy-subrc ne 0.
*   Aktion abgebrochen
    message s001(aqqis_cntrl).
    exit.
  else.
    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname              = l_tab_new
*       FIELDNAME            = ' '
*       LANGU                = SY-LANGU
*       LFIELDNAME           = ' '
*       ALL_TYPES            = ' '
*       GROUP_NAMES          = ' '
*       UCLEN                =
*       DO_NOT_WRITE         = ' '
*     IMPORTING
*       X030L_WA             =
*       DDOBJTYPE            =
*       DFIES_WA             =
*       LINES_DESCR          =
*     TABLES
*       DFIES_TAB            =
*       FIXED_VALUES         =
     EXCEPTIONS
       NOT_FOUND            = 1
       INTERNAL_ERROR       = 2
       OTHERS               = 3.

** 01.JUL.25 FRG VALIDACION QUE LA TABLA EXISTA INICIA
    IF sy-subrc <> 0.
*   Aktion abgebrochen
    message 'Table Not Found' TYPE 'I'.
    exit.
    ENDIF.
** 01.JUL.25 FRG VALIDACION QUE LA TABLA EXISTA INICIA

  endif.


* ttab Aufbauen
  CALL FUNCTION 'RSAQ_CNTRL_BUILD_TTAB'
    EXPORTING
      I_TAB   = l_tab_new
    IMPORTING
      ET_TTAB = lt_ttab.
  p_join_data_r->SET_INFO( EXPORTING IT_TTAB   = lt_ttab ).

* validate table is part of BUS procedure



* setzen Änderungsflag
  SET_CHANGED( EXPORTING I_CHANGED = aqqis_c_changed-updated ).

* Füllen von pt_tfield
  add_tfield( i_tname = l_tab_new ).

* Positionen neue Tabelle bestimmen - Füllen von pt_tpos
  add_tpos( exporting i_tname  = l_tab_new ).

* pt_tpos, pt_tfield, pt_join -> dbjc, dbjt
  cnvt_table_to_old( ).

* Tabelle ans Frontend senden
  p_join_data_r->get_info( importing et_dbjt = lt_dbjt ).
  read table lt_dbjt assigning <dbjt> with key table = l_tab_new.
  if sy-subrc = 0.

    fill_table_fields( exporting is_dbjt      = <dbjt>
                       importing es_tobj_join = ls_tobj_join ).
    append ls_tobj_join to lt_tobj_join.
    append ls_tobj_join to p_t_tobj_join.

    send_tables_to_cntrl( exporting i_t_tobj_join = lt_tobj_join ).
    p_r_join_cntrl->send_data_to_frontend( ).
  endif.

* Links
* Vorschläge on-Bedingung
  data: lt_tpos    type aqq_t_tpos,
        ls_tposr   type aqq_s_tpos,
        ls_tposl   type aqq_s_tpos,
        l_lin_tpos type i.

  lt_tpos[] = pt_tpos[].
  describe table lt_tpos lines l_lin_tpos.
  check l_lin_tpos >= 2.
  read table lt_tpos into ls_tposr index l_lin_tpos.
  l_lin_tpos = l_lin_tpos - 1.
  read table lt_tpos into ls_tposl index l_lin_tpos.

  propose_on_condition( exporting  i_tabnamel             = ls_tposl-tabname
                                   i_tabnamer             = ls_tposr-tabname
                        exceptions no_joins_found         = 1
                                   no_further_joins_found = 2
                                   join_addition_invalid  = 3 ).
  if     sy-subrc = 1.
*   Keine Verknüpfungen gefunden
    message s002(aqqis_cntrl).
    exit.
  elseif sy-subrc = 2.
*   Keine weiteren Verknüpfungen gefunden
    message s003(aqqis_cntrl).
    exit.
  elseif sy-subrc = 3.
*   Verknüpfungen lassen sich nicht als Left-outer Bedingung einfügen
    message s004(aqqis_cntrl).
    exit.
  endif.

  p_r_join_cntrl->send_data_to_frontend( ).

endmethod.                    "ADD_TOBJECT


method ADD_TPOS .

  data: lt_tablepos   type aqq_t_tablepos,
        lt_tpos       type aqq_t_tpos,
        ls_tpos_last  type aqq_s_tpos,
        ls_tpos_new   type aqq_s_tpos,
        l_cnt_tpos    type i.

*--- lesen Tabellenpositionen
  lt_tablepos = p_r_join_cntrl->get_position_of_objects( ).

  lt_tpos[] = pt_tpos[].
  describe table lt_tpos lines l_cnt_tpos.

* schon Einträge vorhanden - sprich Tabellen auf dem Control
  if l_cnt_tpos > 0.
    read table lt_tpos transporting no fields with key tabname = i_tname.
    if sy-subrc = 0.
*      raise existing.
    endif.

    sort lt_tpos by xpos.

    read table lt_tpos into ls_tpos_last index l_cnt_tpos.
    ls_tpos_new          = ls_tpos_last.
    ls_tpos_new-tabname  = i_tname.
    ls_tpos_new-xpos     = ls_tpos_last-xpos + ls_tpos_last-width + 50.
    ls_tpos_new-width    = p_tab_width.
    ls_tpos_new-height   = p_tab_height.
*    XPOS
*    YPOS
*    WIDTH
*    HEIGHT
    append ls_tpos_new to lt_tpos.

* erste Tabelle auf dem Control
  else.
    ls_tpos_new-tabname  = i_tname.
    ls_tpos_new-xpos     = p_tab_startx.
    ls_tpos_new-ypos     = p_tab_starty.
    ls_tpos_new-width    = p_tab_width.
    ls_tpos_new-height   = p_tab_height.
    append ls_tpos_new to lt_tpos.
  endif.

  pt_tpos[] = lt_tpos[].

endmethod.                    "POS_NEW_TABLE


method ALIASTABLE .

  data:  l_sgname       type AQS_SGNAME,
         l_actworkspace type AQS_WSID,
         l_headsg       type AQHDSG,
         l_maxsg_tindx  type AQS_TINDX,
         l_mode         type i,
         lt_clogsg      type AQTCLSG,
         lt_dbsa        type AQTDBSA,
         lt_dbob        type AQTDBOB,
         lt_dbos        type AQTDBOS,
         lt_dbif        type AQTDBIF,
         lt_dbsf        type AQTDBSF,
         lt_dbsg        type AQTDBSG,
         lt_dban        type AQTDBAN,
         lt_dbjt        type AQTDBJT,
         lt_dbjc        type AQTDBJC,
         lt_dbzt        type AQTDBZT,
         lt_dbzc        type AQTDBZC,
         lt_dbzl        type AQTDBZL,
         lt_dbdp        type AQTDBDP_stdkey,
         lt_dbpa        type AQTDBPA,
         lt_dbwr        type AQTDBWR,
         lt_dbar        type AQTDBAR,
         lt_dbft        type AQTDBFT,
         lt_sgtext      type AQTTXSG,
         lt_exdbfi      type aqq_t_exdbfi,
         lt_ttab        type aqq_t_ttab.

  p_join_data_r->GET_INFO( IMPORTING  e_sgname        = l_sgname
                                      e_actworkspace  = l_actworkspace
                                      e_headsg        = l_headsg
                                      e_maxsg_tindx   = l_maxsg_tindx
                                      e_mode          = l_mode
                                      ET_DBDP         = lt_dbdp
                                      ET_DBPA         = lt_dbpa
                                      ET_DBWR         = lt_dbwr
                                      ET_DBAR         = lt_dbar
                                      ET_DBFT         = lt_dbft
                                      ET_SGTEXT       = lt_sgtext
                                      ET_EXDBFI       = lt_exdbfi
                                      ET_TTAB         = lt_ttab
                                      ET_DBZL         = lt_dbzl
                                      ET_CLOGSG       = lt_clogsg
                                      ET_DBSA         = lt_dbsa
                                      ET_DBOB         = lt_dbob
                                      ET_DBOS         = lt_dbos
                                      ET_DBIF         = lt_dbif
                                      ET_DBSF         = lt_dbsf
                                      ET_DBSG         = lt_dbsg
                                      ET_DBAN         = lt_dban
                                      ET_DBJT         = lt_dbjt
                                      ET_DBJC         = lt_dbjc
                                      ET_DBZT         = lt_dbzt
                                      ET_DBZC         = lt_dbzc ).
* MS38OF81
* check_ddic_interface
  CALL FUNCTION 'RSAQ_DJ_DEFINE_ALIASTABLES'
    EXPORTING
      SGNAME_INPUT        = l_sgname
      ACT_WORKSPACE_INPUT = l_actworkspace
    TABLES
      CLOGSG_INPUT        = lt_clogsg
      DBSA_INPUT          = lt_dbsa
      DBOB_INPUT          = lt_dbob
      DBOS_INPUT          = lt_dbos
      DBIF_INPUT          = lt_dbif
      DBSF_INPUT          = lt_dbsf
      DBSG_INPUT          = lt_dbsg
      DBAN_INPUT          = lt_dban
      DBJT_INPUT          = lt_dbjt
      DBJC_INPUT          = lt_dbjc
      DBZT_INPUT          = lt_dbzt
      DBZC_INPUT          = lt_dbzc
      DBZL_INPUT          = lt_dbzl
      DBDP_INPUT          = lt_dbdp
      DBPA_INPUT          = lt_dbpa
      DBWR_INPUT          = lt_dbwr
      DBAR_INPUT          = lt_dbar
      DBFT_INPUT          = lt_dbft
      SGTEXT_INPUT        = lt_sgtext
      EXDBFI_INPUT        = lt_exdbfi
      TTAB_INPUT          = lt_ttab
    CHANGING
      HEADSG_INPUT        = l_headsg
      MAXSG_TINDX_INPUT   = l_maxsg_tindx
      MODE_INPUT          = l_mode.

  p_join_data_r->SET_INFO( EXPORTING  I_SGNAME       = l_sgname
                                      I_ACTWORKSPACE = l_actworkspace
                                      I_HEADSG       = l_headsg
                                      I_MAXSG_TINDX  = l_maxsg_tindx
                                      I_MODE         = l_mode
                                      IT_DBDP        = lt_dbdp
                                      IT_DBPA        = lt_dbpa
                                      IT_DBWR        = lt_dbwr
                                      IT_DBAR        = lt_dbar
                                      IT_DBFT        = lt_dbft
                                      IT_SGTEXT      = lt_sgtext
                                      IT_EXDBFI      = lt_exdbfi
                                      IT_TTAB        = lt_ttab
                                      IT_DBZL        = lt_dbzl
                                      IT_CLOGSG      = lt_clogsg
                                      IT_DBSA        = lt_dbsa
                                      IT_DBOB        = lt_dbob
                                      IT_DBOS        = lt_dbos
                                      IT_DBIF        = lt_dbif
                                      IT_DBSF        = lt_dbsf
                                      IT_DBSG        = lt_dbsg
                                      IT_DBAN        = lt_dban
                                      IT_DBJT        = lt_dbjt
                                      IT_DBJC        = lt_dbjc
                                      IT_DBZT        = lt_dbzt
                                      IT_DBZC        = lt_dbzc ).

endmethod.                    "ALIASTABLE


method CHECK .

  data: l_tname type aqs_tname.

  CHECK_CONDITIONS( importing  e_tname        = l_tname
                    EXCEPTIONS NOT_RIGHT      = 1
                               ZERO_TABLES    = 2
                               ONLY_ONE_TABLE = 3 ).

  if     sy-subrc = 0.
*   Die definierten Join-Bedingungen sind korrekt
    message s015(aqqis_cntrl).
  elseif SY-SUBRC = 1.
*   Tabelle &1 muß rechte Tabelle in einem Join sein
    message s016(aqqis_cntrl) with l_tname.
  elseif sy-subrc = 2.
*   Es ist keine Tabelle vorhanden
    message s012(aqqis_cntrl).
  elseif sy-subrc = 3.
*   Es ist nur eine Tabelle vorhanden
    message s013(aqqis_cntrl).
  endif.

endmethod.                    "CHECK


METHOD check_conditions .

  DATA: l_lin_tpos   TYPE i,
        ls_tpos      TYPE aqq_s_tpos,
        ls_join      TYPE aqq_s_join,
        lv_index     TYPE i,
        lv_xpos      TYPE aqq_s_tpos-xpos,
        lv_lines     TYPE i,
        lv_adjust    TYPE boolean,
        lv_not_right TYPE boolean.

  FIELD-SYMBOLS:<fs_tpos> TYPE aqq_s_tpos,
                <fs_join> TYPE aqq_s_join.

  DESCRIBE TABLE pt_tpos LINES l_lin_tpos.

  IF     l_lin_tpos = 0.
    RAISE zero_tables.
  ELSEIF l_lin_tpos = 1.
    RAISE only_one_table.
  ENDIF.

  lv_not_right = abap_false.
  lv_adjust = abap_false.

  SORT pt_tpos BY xpos.

* Delete for OneConnect
  LOOP AT pt_tpos FROM 2 INTO ls_tpos.
    READ TABLE pt_join INTO ls_join WITH KEY tabnamer = ls_tpos-tabname.
    IF sy-subrc NE 0 .
      e_tname = ls_tpos-tabname.
*      RAISE NOT_RIGHT.
      lv_not_right = abap_true.
    ENDIF.
  ENDLOOP.

  IF lv_not_right = abap_true.

    DESCRIBE TABLE pt_tpos LINES lv_lines.
    lv_adjust = abap_false.


    DO lv_lines TIMES.
      LOOP AT pt_tpos FROM 2 ASSIGNING <fs_tpos>.
        lv_index = sy-tabix.
        READ TABLE pt_join INTO ls_join WITH KEY tabnamer = <fs_tpos>-tabname.
        IF sy-subrc NE 0 .
          lv_index = lv_index + 1.
          READ TABLE pt_tpos INTO ls_tpos INDEX lv_index.
          IF sy-subrc = 0.
            lv_xpos = ls_tpos-xpos + 400.
            <fs_tpos>-xpos = lv_xpos.

            READ TABLE pt_join ASSIGNING <fs_join> WITH KEY tabnamel =  <fs_tpos>-tabname.
            IF sy-subrc = 0.
              <fs_join>-tabnamer = <fs_tpos>-tabname.
*            <fs_join>-colnamer = <fs_tpos>-colnamer.
              <fs_join>-tabnamel = ls_tpos-tabname.
              lv_adjust = abap_true.
            ELSE.
              e_tname = ls_tpos-tabname.
              RAISE not_right.
            ENDIF.

          ELSE.
            e_tname = ls_tpos-tabname.
            RAISE not_right.
          ENDIF.
        ENDIF.
      ENDLOOP.
      SORT pt_tpos BY xpos.
    ENDDO.

  ENDIF.

  e_adjust = lv_adjust.
  gt_tpos[] = pt_tpos[].

  IF lv_adjust = abap_true.
    gt_join[] = pt_join[].
    e_tjoin = pt_join[].
  ENDIF.


ENDMETHOD.                    "CHECK_CONDITIONS


method CHECK_REMOVE_TOBJECT .

  data: lt_dbjt      type aqtdbjt,
        lt_dbsf      type aqtdbsf,
        ls_headsg    type aqhdsg,    "note 1639058
        l_cnt_dbjt   type i,
        l_caller_id  type c.

  p_join_data_r->get_info( importing et_dbjt     = lt_dbjt
                                     et_dbsf     = lt_dbsf
                                     e_headsg    = ls_headsg
                                     e_caller_id = l_caller_id ).

  describe table lt_dbjt lines l_cnt_dbjt.

  if l_cnt_dbjt = 1.
    raise only_one_table.
  endif.

  "<<< note 1639058
  if i_tname eq ls_headsg-tstruc.
    message e535(aq).
  endif.
  ">>> note 1639058

  READ TABLE lt_dbsf WITH KEY sgna = i_tname
                              addy = space
                     transporting no fields.
  IF sy-subrc = 0.
    IF ( l_caller_id <> 'Q' ).
      raise table_is_used.
    ELSE.
      raise no_remove_in_quickview.
    ENDIF.
  ENDIF.

endmethod.                    "CHECK_REMOVE_TOBJECT


method CNT_MARKED_LINES_PER_TAB .

  data: l_t_objects    type aqq_t_objects,
        l_lines_marked type i.

  l_t_objects = p_r_join_cntrl->get_selected_objects( ).

  loop at l_t_objects transporting no fields where r_table  eq ir_table
                                             and   rowindex ne 0.
    l_lines_marked = l_lines_marked + 1.
  endloop.

  e_lines_marked = l_lines_marked.

endmethod.


method CNT_MARKED_TABS .

  data: l_t_objects    type aqq_t_objects,
        l_lin_objects  type i.

  l_t_objects = p_r_join_cntrl->get_selected_objects( ).
* Tabelle
  loop at l_t_objects transporting no fields where not r_table is initial
                                             and       rowindex = 0.
    l_lin_objects = l_lin_objects + 1.
  endloop.

  e_marked_tabs = l_lin_objects.
endmethod.


method CNVT_FNAME_ONE_2_TWO .

  split i_fname at '-' into e_tname e_fname.
  if sy-subrc ne 0.
    e_fname = i_fname.
  endif.

endmethod.                    "CNVT_FNAME_ONE_2_TWO


method CNVT_TABLES_TO_NEW .

  data: lt_dbjt   type aqtdbjt,
        ls_dbjt   type aqdbjt,
        lt_dbjc   type aqtdbjc,
        ls_dbjc   type aqdbjc,
        lt_tpos   type aqq_t_tpos,
        ls_tpos   type aqq_s_tpos,
        lt_tfield type aqq_t_tfield,
        ls_tfield type aqstfield,
        lt_join   type aqq_t_join,
        ls_join   type aqq_s_join,
        l_tabix   type sytabix.

  p_join_data_r->get_info( importing et_dbjt = lt_dbjt
                                     et_dbjc = lt_dbjc ).
* set tables & fields.
* set tfields table, load table infos.

  loop at lt_dbjt into ls_dbjt.
    l_tabix = sy-tabix.

    ls_tfield-tabname = ls_dbjt-table.
* set positions in tpos.
    clear ls_tpos.
    ls_tpos-tabname = ls_dbjt-table.

*   ls_dbjt-left_vz    => können auch negative Werte enthalten, ohne _vz
*   ls_dbjt-top_vz        sind nur positive Werte möglich
*   ls_dbjt-width_vz
*   ls_dbjt-heigth_vz
    if ls_dbjt-left_vz    is initial and
       ls_dbjt-top_vz     is initial and
       ls_dbjt-width_vz   is initial and
       ls_dbjt-height_vz  is initial.

      if ( i_first_table_apos = aqqis_c_true and sy-tabix = 1 ).
        ls_tpos-xpos = 50.
        ls_tpos-ypos = 50.
        if  not ( ls_dbjt-width is initial ).
          ls_tpos-width  = ls_dbjt-width_vz  = ls_dbjt-width.
          ls_tpos-height = ls_dbjt-height_vz = ls_dbjt-height.
        endif.
        append ls_tpos to lt_tpos.
      else.
        if  not ( ls_dbjt-top is initial ).
          ls_tpos-xpos = ls_dbjt-left_vz = ls_dbjt-left.
          ls_tpos-ypos = ls_dbjt-top_vz  = ls_dbjt-top.
        endif.
        if  not ( ls_dbjt-width is initial ).
          ls_tpos-width  = ls_dbjt-width_vz  = ls_dbjt-width.
          ls_tpos-height = ls_dbjt-height_vz = ls_dbjt-height.
        endif.
        append ls_tpos to lt_tpos.
      endif.
      modify lt_dbjt from ls_dbjt index l_tabix.
      P_JOIN_DATA_R->set_info( exporting it_dbjt = lt_dbjt ).
    else.

      if ( i_first_table_apos = aqqis_c_true and sy-tabix = 1 ).
        ls_tpos-xpos = 50.
        ls_tpos-ypos = 50.
        if  not ( ls_dbjt-width_vz is initial ).
          ls_tpos-width  = ls_dbjt-width_vz.
          ls_tpos-height = ls_dbjt-height_vz.
        endif.
        append ls_tpos to lt_tpos.
      else.
        if  not ( ls_dbjt-top_vz is initial ).
          ls_tpos-xpos = ls_dbjt-left_vz.
          ls_tpos-ypos = ls_dbjt-top_vz.
        endif.
        if  not ( ls_dbjt-width_vz is initial ).
          ls_tpos-width  = ls_dbjt-width_vz.
          ls_tpos-height = ls_dbjt-height_vz.
        endif.
        append ls_tpos to lt_tpos.
      endif.

    endif.

* get object tabobj with fieldinfos for fields of table.
*  (like former ltab/rtab, (= includes Dictionary & type information)
*  but now: for all tables in join!
*  tabstore stores these objects and manages them.
    data:   lt_ltab         type aqqis_t_tab,
            ls_ltab         type aqqis_s_tab.

    get_tab( exporting i_tabname  = ls_dbjt-table
             importing et_tab     = lt_ltab ).

    loop at lt_ltab into ls_ltab.
      ls_tfield-colname = ls_ltab-feld.
      if ( ls_ltab-key = aqqis_c_true ).
        ls_tfield-iskey = 1.
      else.
        ls_tfield-iskey = 0.
      endif.
      append ls_tfield to lt_tfield.
    endloop.
  endloop.

* joins:
  ls_join-op   = aqqis_c_join_typ-inner.

  loop at lt_dbjc into ls_dbjc.
* we look only for join-conditions:
    if ls_dbjc-jind is initial.
      continue.
    endif.

    read table lt_dbjt transporting no fields with key table =  ls_dbjc-rtable.
    if sy-subrc <> 0 or sy-tabix = 1.
      ls_dbjt-outerflag = aqqis_c_join-inner.
    else.

      data: l_i type i.
      l_i = sy-tabix - 1.
      read table lt_dbjt into ls_dbjt index l_i.
    endif.

* the table is used in a left outer join if the PRECEDING table
* of the right table
* has marked an 'L' in dbjt.
    if ( ls_dbjt-outerflag <> aqqis_c_join-left_outer ).
      ls_join-type = aqqis_c_join_typ-inner.
    else.
      ls_join-type = aqqis_c_join_typ-left_outer.
    endif.
* set tables
    ls_join-tabnamer = ls_dbjc-rtable.
    ls_join-tabnamel = ls_dbjc-ltable.

* determine colnames!
    ls_join-colnamel = ls_dbjc-lname.
    shift ls_join-colnamel up to '-'. shift ls_join-colnamel.
    ls_join-colnamer = ls_dbjc-rname.
    shift ls_join-colnamer up to '-'. shift ls_join-colnamer.

    append ls_join to lt_join.
  endloop.

  pt_join[]   = lt_join[].
  pt_tpos[]   = lt_tpos[].
  pt_tfield[] = lt_tfield[].
endmethod.                    "CNVT_TABLES_TO_NEW


method CNVT_TABLE_TO_OLD .

  CNVT_TABLE_TO_OLD_dbjt( ).
  cnvt_table_to_old_dbjc( ).

endmethod.                    "CNVT_TABLE_TO_OLD


method CNVT_TABLE_TO_OLD_DBJC .

  DATA: l_CNT     TYPE I VALUE 0,
        ls_JOIN   TYPE AQq_s_JOIN,
        lt_join   type aqq_t_join,
        ls_dbjc   type aqdbjc,
        lt_dbjc   type aqtdbjc.

  lt_join[]   = pt_join[].

* clear table dbjc:
  REFRESH lt_DBJC.
* add all tables:
  LOOP AT lt_JOIN INTO ls_JOIN.
    CLEAR ls_DBJC.
    ls_DBJC-RTABLE = ls_JOIN-TABNAMER.
    ls_DBJC-LTABLE = ls_JOIN-TABNAMEL.
    COLLECT ls_DBJC INTO lt_DBJC.
  ENDLOOP.

* add all the joins:
* copy all join-conditions. generate index.
  SORT lt_JOIN BY TABNAMEL TABNAMER COLNAMEL.
  LOOP AT lt_JOIN INTO ls_JOIN.
    AT NEW TABNAMEL.
      l_CNT = 0.
    ENDAT.

    l_CNT = l_CNT + 1.
    WRITE l_CNT TO ls_DBJC-JIND(2).
    ls_DBJC-LTABLE = ls_JOIN-TABNAMEL.
    CONCATENATE ls_DBJC-LTABLE '-' ls_JOIN-COLNAMEL INTO ls_DBJC-LNAME.
    ls_DBJC-RTABLE = ls_JOIN-TABNAMER.
    CONCATENATE ls_DBJC-RTABLE '-' ls_JOIN-COLNAMER INTO ls_DBJC-RNAME.
    APPEND ls_DBJC TO lt_DBJC.
  ENDLOOP.
* copy all join-conditions. generate index.

  p_join_data_r->set_info( exporting it_dbjc = lt_dbjc ).

endmethod.


method CNVT_TABLE_TO_OLD_DBJT .

  DATA: l_ANZ     TYPE INT4,
        l_O       TYPE INT4,
        l_CNT     TYPE I VALUE 0,
        ls_JOIN   TYPE AQq_s_JOIN,
        lt_join   type aqq_t_join,
        ls_DBJT   type aqdbjt,
        lt_dbjt   type aqtdbjt,
        ls_tpos   type aqq_s_tpos,
        lt_tpos   type aqq_t_tpos.

  lt_tpos[]   = pt_tpos[].
  lt_join[]   = pt_join[].

  REFRESH lt_DBJT.

  SORT lt_TPOS BY XPOS.
  DESCRIBE TABLE lt_TPOS LINES l_ANZ.

  LOOP AT lt_TPOS INTO ls_TPOS.
    l_O = SY-TABIX + 1.
    ls_DBJT-TABLE     = ls_TPOS-TABNAME.
    ls_DBJT-OUTERFLAG = ' '.
*    ls_dbjt-top       = ls_tpos-ypos.
*    ls_dbjt-left      = ls_tpos-xpos.
*    ls_dbjt-width     = ls_tpos-width.
*    ls_dbjt-height    = ls_tpos-height.
    ls_dbjt-top_vz       = ls_tpos-ypos.
    ls_dbjt-left_vz      = ls_tpos-xpos.
    ls_dbjt-width_vz     = ls_tpos-width.
    ls_dbjt-height_vz    = ls_tpos-height.

    IF l_O <= l_ANZ.
      READ TABLE lt_TPOS INTO ls_TPOS INDEX l_O.
      READ TABLE lt_JOIN INTO ls_JOIN WITH KEY TABNAMER = ls_TPOS. " next table is:
      IF ls_JOIN-TYPE = '1'.
        ls_DBJT-OUTERFLAG = aqqis_c_join-left_outer.
      ELSE.
        ls_DBJT-OUTERFLAG = aqqis_c_join-inner.
      ENDIF.
    ENDIF.
    APPEND ls_DBJT TO lt_DBJT.
  ENDLOOP.

* clear flag in last join.
  DESCRIBE TABLE lt_DBJT LINES l_CNT.
  READ TABLE lt_DBJT INTO ls_DBJT INDEX l_CNT.
  IF l_CNT > 0 .
    CLEAR: ls_DBJT-OUTERFLAG.
    MODIFY lt_DBJT FROM ls_DBJT INDEX l_CNT.
  ENDIF.

  p_join_data_r->set_info( exporting it_dbjt = lt_dbjt ).

endmethod.


method CONSTRUCTOR .
* change/display mode
  p_mode        = i_mode.

  p_join_data_r = i_join_data_r.

  init( i_r_container_parent = i_r_container_parent ).


endmethod.


method CREATE_LINK .

  data: l_r_link       type ref to if_aqqgraphic_link,
        l_s_link       type     AQSLINKJOI,
        l_text         type     aqq_text,
        l_rowl         type     int2,
        l_rowr         type     int2.

  field-symbols: <tobj_join_l> type AQSTOBJJOI,
                 <tobj_join_r> type AQSTOBJJOI,
                 <fobj_join_l> type AQSFOBJJOI,
                 <fobj_join_r> type AQSFOBJJOI.

  l_rowl = i_rowl.
  l_rowr = i_rowr.

  l_r_link = p_r_join_cntrl->get_new_link( ).

  l_r_link->set_attributes( exporting i_moveable     = aqqis_c_true
*                                     I_SELECTABLE   = aqqis_C_TRUE
                                      i_editable     = aqqis_c_false
*                                     I_MOUSEOVER    = aqqis_C_TRUE
*                                     I_ELBOWLINK    = aqqis_C_FALSE
*                                     I_ANGLELINK    = aqqis_C_TRUE
*                                     I_BUNCHLINK    = aqqis_C_FALSE
*                                     I_SIMPLELINK   = aqqis_C_FALSE
*                                     I_DESMERGELINK = aqqis_C_TRUE
  ).

  l_r_link->set_status( ).

  l_text = FETCH_OUTERFLAG_TEXT( ir_tabl  = ir_tabl
                                 ir_tabr  = ir_tabr ).

  l_r_link->set_properties( exporting i_linkstyle = p_default_linkstyle
                                      i_text      = l_text ).

*   set left and right table of link
  l_r_link->set_predecessor( exporting i_r_table  = ir_tabl
                                       i_rowindex = l_rowl ) .
  l_r_link->set_successor( exporting i_r_table  = ir_tabr
                                     i_rowindex = l_rowr ) .

  read table p_t_tobj_join assigning <tobj_join_l> with key tabref = ir_tabl.
  read table <tobj_join_l>-fobj assigning <fobj_join_l> index i_rowl.
  read table p_t_tobj_join assigning <tobj_join_r> with key tabref = ir_tabr.
  read table <tobj_join_r>-fobj assigning <fobj_join_r> index i_rowr.

*   add link to attribute
  clear l_s_link.
  l_s_link-tnameleft   = <tobj_join_l>-tname.
  concatenate <tobj_join_l>-tname '-' <fobj_join_l>-fname into l_s_link-fnameleft.
  l_s_link-tnameright  = <tobj_join_r>-tname.
  concatenate <tobj_join_r>-tname '-' <fobj_join_r>-fname into l_s_link-fnameright.
  l_s_link-linkref      = l_r_link.

  append l_s_link to p_t_links_join.

*   add link to control
  p_r_join_cntrl->add_link( i_r_link = l_r_link ).

endmethod.


method CREATE_LINKS .

  data: l_tabref_left  type ref to if_aqqgraphic_table,
        l_tabref_right type ref to if_aqqgraphic_table,
        l_tabix_left   type        sytabix,
        l_tabix_right  type        sytabix,
        l_tname_left   type        AQS_TNAME,
        l_tname_right  type        AQS_TNAME,
        l_s_tobj_join  type        AQSTOBJJOI,
        l_r_link       type ref to if_aqqgraphic_link,
        lt_join        type        aqq_t_join.

  field-symbols: <join> type aqq_s_join.

  lt_join[] = it_join[].
*  p_join_data_r->get_info( importing et_dbjc = lt_dbjc ).

  loop at lt_join assigning <join>.
    check not <join>-tabnamel is initial and not <join>-tabnamer is initial.

* 1. Seite
    read table p_t_tobj_join into l_s_tobj_join with key tname = <join>-tabnamel.
    check sy-subrc = 0.
    read table l_s_tobj_join-fobj with key fname = <join>-colnamel transporting no fields.
    check sy-subrc = 0.

    l_tname_left  = l_s_tobj_join-tname.
    l_tabix_left  = sy-tabix.
    l_tabref_left = l_s_tobj_join-tabref.

* 2. Seite
    read table p_t_tobj_join into l_s_tobj_join with key tname = <join>-tabnamer.
    check sy-subrc = 0.
    read table l_s_tobj_join-fobj with key fname = <join>-colnamer transporting no fields.
    check sy-subrc = 0.

    l_tname_right  = l_s_tobj_join-tname.
    l_tabix_right  = sy-tabix.
    l_tabref_right = l_s_tobj_join-tabref.

*   create link object
    create_link( exporting ir_tabl = l_tabref_left
                           ir_tabr = l_tabref_right
                           i_rowl  = l_tabix_left
                           i_rowr  = l_tabix_right ).
  endloop.
endmethod.


method DISPLAY_DDIC .

  data: l_s_tobj_join type aqstobjjoi,
        l_s_fobj      type aqsfobjjoi,
        lt_tab        type aqq_t_tab,
        l_ref         type flag,
        ls_exdbfi     type aqsexdbfi,
        lt_exdbfi     type aqq_t_exdbfi,
        l_objname     type ddobjname,
        l_objtype     type ddeutype,
        lt_dban       type aqtdban.

  field-symbols: <dban> type aqdban,
                 <tab>  type aqq_s_tab.

  if not ir_table is initial.
    read table p_t_tobj_join into l_s_tobj_join with key tabref = ir_table.
    check sy-subrc = 0.

    get_tab( exporting i_tabname = l_s_tobj_join-tname
             importing et_tab    = lt_tab ).

    read table lt_tab assigning <tab> with key feld = l_s_fobj-fname.

    p_join_data_r->get_info( importing et_dban = lt_dban ).

    l_objname = l_s_tobj_join-tname.

    read table lt_dban assigning <dban> with key alias = l_objname.
    if sy-subrc = 0.
      l_objname = <dban>-table.
    endif.

    l_objtype = 'T'.
    call function 'RS_DD_SHOW'
      exporting
        objname                    = l_objname
        objtype                    = l_objtype
*         POPUP                      = ' '
*         SECNAME                    =
*         MONITOR_ACTIVATE           = 'X'
*       IMPORTING
*         FCODE                      =
     exceptions
       object_not_found           = 1
       object_not_specified       = 2
       permission_failure         = 3
       type_not_valid             = 4.

  endif.

endmethod.                    "DISPLAY_DDIC


method EXECUTE_JOIN_MODIFICATION .

  data: ls_join type aqq_s_join,
        l_text  type aqq_text.

  field-symbols: <links_join> type aqslinkjoi.

* Text für den link
  case is_join-type.
    when aqqis_c_join_typ-inner.
    when aqqis_c_join_typ-left_outer.
      l_text = text-013.  "left outer join
    when others.
  endcase.

* pt_join aktualisieren
  loop at pt_join into ls_join where tabnamer = is_join-tabnamer.
    ls_join-type = is_join-type.
    modify pt_join from ls_join.
  endloop.

* aktuellen link ans frontend senden
  loop at p_t_links_join assigning <links_join> where tnameleft  = is_join-tabnamel
                                                  and tnameright = is_join-tabnamer.

    <links_join>-linkref->set_properties( i_linkstyle = p_default_linkstyle
                                          i_text      = l_text ).
    p_r_join_cntrl->add_link( i_r_link = <links_join>-linkref ).
  endloop.
  p_r_join_cntrl->send_data_to_frontend( ).

* Tabellen konvertieren
  cnvt_table_to_old( ).

endmethod.                    "EXECUTE_JOIN_MODIFICATION


method FETCH_OUTERFLAG_TEXT .

  field-symbols: <tobj_join_l> type AQSTOBJJOI,
                 <tobj_join_r> type AQSTOBJJOI,
                 <join>        type aqq_s_join.

  read table p_t_tobj_join assigning <tobj_join_l> with key tabref = ir_tabl.
  read table p_t_tobj_join assigning <tobj_join_r> with key tabref = ir_tabr.

  read table pt_join assigning <join> with key TABNAMEL = <tobj_join_l>-tname
                                               TABNAMER = <tobj_join_r>-tname.

  if     <join>-type = aqqis_c_join_typ-inner.

  elseif <join>-type = aqqis_c_join_typ-left_outer.
    r_text = text-013.
  endif.

endmethod.                    "FETCH_OUTERFLAG_TEXT


method FIELDDOCU .
  data: l_s_tobj_join  type aqstobjjoi,
        l_s_fobj       type aqsfobjjoi,
        lt_tab         type aqq_t_tab,
        ls_exdbfi      type aqsexdbfi,
        lt_exdbfi      type aqq_t_exdbfi.

  data: lr_table       type ref to if_aqqgraphic_table.
  data: l_t_objects    type aqq_t_objects,
        l_lin_objects  type i,
        l_lines_marked type i,
        l_row          type sytabix.

  field-symbols: <tab>       type aqq_s_tab.
  field-symbols: <objects>   type aqsobjects.
  field-symbols: <lines>     type aqsobjects.

  if ir_table is initial.

    if cnt_marked_tabs( ) = 0.
*     Kein Objekt markiert.
      message s006(aqqis_cntrl).
      exit.
    elseif cnt_marked_tabs( ) > 1.
*     Mehrere Objekte markiert
      message s007(aqqis_cntrl).
      exit.
    endif.

    l_t_objects = p_r_join_cntrl->get_selected_objects( ).
    read table l_t_objects assigning <objects> with key rowindex = 0.
    if sy-subrc = 0.
      lr_table = <objects>-r_table.
    endif.

    if cnt_marked_lines_per_tab( lr_table ) = 0.
*     Keine Tabellenzeile markiert
      message s033(aqqis_cntrl).
      exit.
    elseif cnt_marked_lines_per_tab( lr_table ) > 1.
*     Mehr ale eine Tabellenzeile markiert
      message s034(aqqis_cntrl).
      exit.
    endif.

    loop at l_t_objects assigning <lines> where rowindex ne 0.
    endloop.
    if sy-subrc = 0.
      l_row = <lines>-rowindex.
    endif.
  else.
    lr_table = ir_table.
    l_row    = i_row.
  endif.

  if not lr_table is initial.
    read table p_t_tobj_join into l_s_tobj_join with key tabref = lr_table.
    check sy-subrc = 0.

    read table l_s_tobj_join-fobj into l_s_fobj index l_row.
    check sy-subrc = 0.

    get_tab( exporting i_tabname = l_s_tobj_join-tname
             importing et_tab    = lt_tab ).

    read table lt_tab assigning <tab> with key feld = l_s_fobj-fname.

    call function 'RSAQ_CNTRL_BUILD_EXDBFI'
      exporting
        i_tab     = l_s_tobj_join-tname
      importing
        et_exdbfi = lt_exdbfi.

    read table lt_exdbfi into ls_exdbfi with key ddic-fieldname = <tab>-feld.

    call function 'RSAQ_CNTRL_FIELD_DOCU'
      exporting
        is_exdbfi = ls_exdbfi.
  endif.

endmethod.                    "FIELDDOCU


method FIELDREFERENCE .

  data: l_s_tobj_join type aqstobjjoi,
        l_s_fobj      type aqsfobjjoi,
        lt_tab        type aqq_t_tab,
        ls_exdbfi     type aqsexdbfi,
        lt_exdbfi     type aqq_t_exdbfi.

  data: lr_table       type ref to if_aqqgraphic_table.
  data: l_t_objects    type aqq_t_objects,
        l_lin_objects  type i,
        l_lines_marked type i,
        l_row          type sytabix.

  field-symbols: <tab>       type aqq_s_tab.
  field-symbols: <objects>   type aqsobjects.
  field-symbols: <lines>     type aqsobjects.

  if ir_table is initial.
    if cnt_marked_tabs( ) = 0.
*     Kein Objekt markiert.
      message s006(aqqis_cntrl).
      exit.
    elseif cnt_marked_tabs( ) > 1.
*     Mehrere Objekte markiert
      message s007(aqqis_cntrl).
      exit.
    endif.

    l_t_objects = p_r_join_cntrl->get_selected_objects( ).
    read table l_t_objects assigning <objects> with key rowindex = 0.
    if sy-subrc = 0.
      lr_table = <objects>-r_table.
    endif.

    if cnt_marked_lines_per_tab( lr_table ) = 0.
*     Keine Tabellenzeile markiert
      message s033(aqqis_cntrl).
      exit.
    elseif cnt_marked_lines_per_tab( lr_table ) > 1.
*     Mehr ale eine Tabellenzeile markiert
      message s034(aqqis_cntrl).
      exit.
    endif.

    loop at l_t_objects assigning <lines> where rowindex ne 0.
    endloop.
    if sy-subrc = 0.
      l_row = <lines>-rowindex.
    endif.
  else.
    lr_table = ir_table.
    l_row    = i_row.
  endif.

  if not lr_table is initial.
    read table p_t_tobj_join into l_s_tobj_join with key tabref = lr_table.
    check sy-subrc = 0.

    read table l_s_tobj_join-fobj into l_s_fobj index l_row.
    check sy-subrc = 0.

    get_tab( exporting i_tabname = l_s_tobj_join-tname
             importing et_tab    = lt_tab ).

    read table lt_tab assigning <tab> with key feld = l_s_fobj-fname.

    referenzfield( is_tab  = <tab>
                   i_tname = l_s_tobj_join-tname ).

  endif.
endmethod.                    "FIELDREFERENCE


method FILL_TABLE_FIELDS .

  data: lt_ttab       type aqq_t_ttab,
        l_s_tobj_join type AQSTOBJJOI,
        l_s_fobj_join type AQSFOBJJOI,
        ls_tpos_abs   type AQSTPOSABS,
        lt_tab        type aqq_t_tab.

  field-symbols: <ttab>    type aqq_s_ttab,
                 <tab>     type aqq_s_tab.

  p_join_data_r->get_info( importing et_ttab   = lt_ttab ).

  GET_TAB( EXPORTING I_TABNAME = is_dbjt-table
           IMPORTING ET_TAB    = lt_tab ).

  clear: l_s_tobj_join.
* Tabellenname
  l_s_tobj_join-tname   = is_dbjt-table.

* Tabellenreferenz
  l_s_tobj_join-tabref  = p_r_join_cntrl->get_new_table( ).

* Titel, tooltip
  read table lt_ttab assigning <ttab> with key DDIC-TABNAME  = is_dbjt-table.
  if sy-subrc = 0.
    concatenate is_dbjt-table ':' <ttab>-DDIC-DDTEXT into l_s_tobj_join-title separated by space.
  else.
    l_s_tobj_join-title = is_dbjt-table.
  endif.
  l_s_tobj_join-tooltip = l_s_tobj_join-title.

* Positionen
  REL_2_ABS( EXPORTING IS_DBJT     = is_dbjt
             IMPORTING ES_TPOS_ABS = ls_tpos_abs ).
  move-corresponding ls_tpos_abs to l_s_tobj_join-tpos.

*--- Felder, tiefe Struktur
  loop at lt_tab assigning <tab>.
    clear: l_s_fobj_join.
    if <tab>-KEY = aqqis_c_true.
      l_s_fobj_join-keyicon = icon_foreign_key.             "1. Spalte
    endif.
    l_s_fobj_join-fname = <tab>-feld.                       "2. Spalte
    l_s_fobj_join-txtlg = <tab>-ftext.                      "3. Spalte
    append l_s_fobj_join to l_s_tobj_join-fobj[].
  endloop.

  es_tobj_join = l_s_tobj_join.
endmethod.                    "FILL_TABLE_FIELDS


method FORCE_JOINTYPE .

* change_old = 'X' : new jointype is used to CHANGE Data of other Joins linking table!
* change_old = ' ' : jointype of new join is set back.

  DATA: l_WA_JOIN TYPE aqq_s_join.
  IF i_CHANGE_OLD = aqqis_c_true.
    LOOP AT pt_JOIN INTO l_WA_JOIN WHERE TABNAMER = cs_JOIN-TABNAMER.
      l_WA_JOIN-TYPE = cs_JOIN-TYPE.
      MODIFY pt_JOIN FROM l_WA_JOIN.
    ENDLOOP.
  ELSE.                              " change new jointype backwards:
    LOOP AT pt_JOIN INTO l_WA_JOIN WHERE   TABNAMER =  cs_JOIN-TABNAMER
                                   AND (   TABNAMEL <> cs_JOIN-TABNAMEL
                                        OR COLNAMER <> cs_JOIN-COLNAMER
                                        OR COLNAMEL <> cs_JOIN-COLNAMEL ).

      cs_JOIN-TYPE = l_WA_JOIN-TYPE.
      EXIT.
    ENDLOOP.

    IF SY-SUBRC <> 0.
      RAISE INCONSISTENT.
    ENDIF.
  ENDIF.
endmethod.                    "FORCE_JOINTYPE


method GET_SELECTED_TABLE .

  data:   lt_objects    type aqq_t_objects,
          l_lin_objects type i,
          lt_dbjt       type aqtdbjt.

  field-symbols: <objects>   type AQSOBJECTS,
                 <tobj_join> type AQSTOBJJOI.

  p_join_data_r->get_info( importing et_dbjt = lt_dbjt ).

  lt_objects = p_r_join_cntrl->get_selected_objects( ).

* wenn nur ein Objekt auf dem Control markiert ist, dann wird der Name dieser
* Tabelle in die obere dropdown-Box gestellt - sind mehrere Objekte markiert oder
* gar keins, dann bleibt dieses Feld inital
  loop at lt_objects transporting no fields where not r_table is initial.
    l_lin_objects = l_lin_objects + 1.
  endloop.

  if     l_lin_objects = 0.
    raise NO_TABLE_SELECTED.
  elseif l_lin_objects = 1.
    read table lt_objects assigning <objects> index 1.
    read table p_t_tobj_join assigning <tobj_join> with key tabref = <objects>-r_table.
    e_tname = <tobj_join>-tname.
  else.
    raise SEVERAL_TABLES_SELECTED.
  endif.

endmethod.                    "GET_SELECTED_TABLE


method GET_TAB .

  data: l_tabname type aqs_tname,
        lt_dban   type aqtdban.

  field-symbols: <dban> type aqdban.

  p_join_data_r->get_info( importing et_dban = lt_dban ).
  read table lt_dban assigning <dban> with key alias = i_tabname.
  if sy-subrc = 0.
    l_tabname = <dban>-table.
  else.
    l_tabname = i_tabname.
  endif.
  perform fill_join_tab in program saplaqjd tables et_tab
                                            using  l_tabname.

endmethod.


  METHOD get_tpos.
    et_tpos[] = gt_tpos[].
    et_join[] = gt_join[].
  ENDMETHOD.


method HANDLE_FCODE .

  synchronize_positions( exporting  iv_no_cancel_on_error = abap_true  "note 2114455
                         exceptions no_data_on_control = 1 ).
  CALL FUNCTION 'RSAQ_CNTRL_SYNCHRONIZE_TABLES'.

  case i_fcode.
    when aqqis_c_ok_altb.       "Aliastabelle
      aliastable( ).

    when aqqis_c_ok_check.      "Verküpfungsbedingungen prüfen
      check( ).

    when aqqis_c_ok_ddic.       "Absprung ins DDic
      display_ddic( ir_table ).

    when aqqis_c_ok_f_jpg.      "jpg
      save_as_jpg( ).

    when aqqis_c_ok_f_ldel.     "Link löschen
      remove_link( ir_link = ir_link ).

    when aqqis_c_ok_F_NAVI.     "Navigator
      navigator( ).

    when aqqis_c_ok_f_print.    "Control drucken
      print_control( ).

    when aqqis_c_ok_f_tdel.     "Tabelle löschen
      remove_tobject( ).

    when aqqis_c_ok_f_scale.    "Skalierung
      scale( ).

    when aqqis_c_ok_F_ZOOMIN.   "zoom in
      zoomin( ).

    when aqqis_c_ok_f_zoomout.  "zoom out
      zoomout( ).

    when aqqis_c_ok_fdoc.       "Felddokumentation
      FIELDDOCU( ir_table = ir_table
                 i_row    = i_rowindex ).

    when aqqis_c_ok_fref.       "Referenzfeld
      FIELDREFERENCE( ir_table = ir_table
                      i_row    = i_rowindex ).

    when aqqis_c_ok_jpro.       "Joinbedingung vorschlagen
      on_condition( ).

    when aqqis_c_ok_lijoin.     "inner join
      join_modification( ir_link    = ir_link
                         i_join_typ = aqqis_c_join_typ-inner ).

    when aqqis_c_ok_lojoin.     "outer join
      join_modification( ir_link    = ir_link
                         i_join_typ = aqqis_c_join_typ-left_outer ).

    when aqqis_c_ok_such.       "suchen
      search( ).

    when aqqis_c_ok_sucw.       "weiter suchen
      search_next( ).

    when aqqis_c_ok_tins.       "Tabelle einfügen
      add_tobject( ).

    when others.
  endcase.

endmethod.                    "HANDLE_FCODE


method HANDLE_LINK_CHANGED .

  data: ls_link      type AQSLINKJOI,
        lt_join_sav  type aqq_t_join,
        ls_join      type aqq_s_join,
        l_tname_new  type aqs_tname,
        l_tname_kept type aqs_tname,
        l_fname_new  type aqs_fname,
        l_fname_kept type aqs_fname,
        l_link_index type sytabix,
        l_fname_akt_r type aqs_fname,
        l_tname_akt_r type aqs_tname,
        l_fname_akt_l type aqs_fname,
        l_tname_akt_l type aqs_fname.

  field-symbols: <tobj_join_new>  type AQSTOBJJOI,
                 <tobj_join_kept> type AQSTOBJJOI,
                 <fobj_join_new>  type AQSFOBJJOI,
                 <fobj_join_kept> type AQSFOBJJOI,
                 <join>           type aqq_s_join.

  read table p_t_links_join into ls_link with key linkref = i_r_link.
  check sy-subrc = 0.
  l_link_index   = sy-tabix.

* betroffene Felder holen
* ursprünglicher link
  split ls_link-fnameleft  at '-' into l_tname_akt_l l_fname_akt_l.
  split ls_link-fnameright at '-' into l_tname_akt_r l_fname_akt_r.

* neues Ende
  read table p_t_tobj_join assigning <tobj_join_new> with key tabref = i_r_tab_new.
  read table <tobj_join_new>-fobj assigning <fobj_join_new> index i_row_new.
  l_tname_new = <tobj_join_new>-tname.
  concatenate l_tname_new '-' <fobj_join_new>-fname into l_fname_new.

* altes Ende
  read table p_t_tobj_join assigning <tobj_join_kept> with key tabref = i_r_tab_kept.
  read table <tobj_join_kept>-fobj assigning <fobj_join_kept> index i_row_kept.
  l_tname_kept = <tobj_join_kept>-tname.
  concatenate l_tname_kept '-' <fobj_join_kept>-fname into l_fname_kept.

* vorhandenen Link aus Datentabelle löschen, sofern vorhanden
* wenn is_valid_link auf false prüft, wird der eben gelöschte link wieder in die
* Datentabelle eingefügt
  lt_join_sav[] = pt_join[].
  read table pt_join[] with key tabnamel = l_tname_akt_l
                                colnamel = l_fname_akt_l
                                tabnamer = l_tname_akt_r
                                colnamer = l_fname_akt_r
                                transporting no fields.
  if sy-subrc = 0.
    delete pt_join index sy-tabix.
  else.
    read table pt_join[] with key tabnamel = l_tname_akt_r
                                  colnamel = l_fname_akt_r
                                  tabnamer = l_tname_akt_l
                                  colnamer = l_fname_akt_l
                                  transporting no fields.
    if sy-subrc = 0.
      delete pt_join index sy-tabix.
    endif.
  endif.


* check new link
  if i_succ_changed = aqqis_c_true.
    is_valid_link( exporting i_r_succtab = i_r_tab_new
                             i_succrow   = i_row_new
                             i_r_predtab = i_r_tab_kept
                             i_predrow   = i_row_kept
                   importing e_valid     = r_ok ).
  else.
    is_valid_link( exporting i_r_succtab = i_r_tab_kept
                             i_succrow   = i_row_kept
                             i_r_predtab = i_r_tab_new
                             i_predrow   = i_row_new
                   importing e_valid     = r_ok ).
  endif.

  if r_ok = aqqis_c_true.
* p_t_links_join
    if l_fname_kept = ls_link-fnameleft.
      ls_link-fnameright = l_fname_new.
      ls_link-tnameright = l_tname_new.
      modify p_t_links_join from ls_link index l_link_index transporting fnameright tnameright.

      read table pt_join assigning <join> with key tabnamer = l_tname_new
                                                   tabnamel = l_tname_kept.
      if sy-subrc = 0.
        ls_join-type = <join>-type.
      endif.
      ls_join-tabnamer = l_tname_new.
      ls_join-colnamer = <fobj_join_new>-fname.
      ls_join-tabnamel = l_tname_kept.
      ls_join-colnamel = <fobj_join_kept>-fname.
      append ls_join to pt_join.
    elseif l_fname_kept = ls_link-fnameright.
      read table pt_join assigning <join> with key tabnamel = l_tname_new
                                                   tabnamer = l_tname_kept.
      if sy-subrc = 0.
        ls_join-type = <join>-type.
      endif.
      ls_link-fnameleft = l_fname_new.
      ls_link-tnameleft = l_tname_new.
      modify p_t_links_join from ls_link index l_link_index transporting fnameleft tnameleft.

      ls_join-tabnamel = l_tname_new.
      ls_join-colnamel = <fobj_join_new>-fname.
      ls_join-tabnamer = l_tname_kept.
      ls_join-colnamer = <fobj_join_kept>-fname.
      append ls_join to pt_join.
    endif.

    set_changed( exporting i_changed = aqqis_c_changed-updated ).

    CNVT_TABLE_TO_OLD( ).

  else.
    pt_join[] = lt_join_sav[].
*   Die Felder &1 und &2 können nicht verknüpft werden
    message s022(aqqis_cntrl) with l_fname_kept l_fname_new.
  endif.
endmethod.                    "HANDLE_LINK_CHANGED


method INIT .

  data: l_headsg type AQHDSG.

*--- Aufbau pt_join,
*           pt_tpos,
*           pt_tfield
*    so wie im alten Control
  CNVT_TABLES_TO_NEW( EXPORTING I_FIRST_TABLE_APOS = aqqis_c_false ).

*--- Umstellung altes Koordinatensystem -> neues Koordinatensystem
  P_JOIN_DATA_R->get_info( IMPORTING E_HEADSG = l_headsg ).
  if l_headsg-control = aqqis_c_false.
    reduce_distance( ).
    l_headsg-control = aqqis_c_true.
    P_JOIN_DATA_R->set_info( EXPORTING I_HEADSG = l_headsg ).
  endif.

*--- Aufbau GUI-Komponenten neues Control
  init_join_cntrl( i_r_container_parent = i_r_container_parent ).
  add_tables_to_join( ).

  add_links_to_join( ).

endmethod.                    "INIT


method INIT_JOIN_CNTRL .

  data: l_s_event      type  cntl_simple_event,
        l_t_event      type  cntl_simple_events,
        l_s_ctxmnu_use type  aqqis_s_ctxmnu_use,
        l_on           type  boolean.

  define m_append_event.
    l_s_event-eventid = aqqis_c_event-&1.
    append l_s_event to l_t_event.
  end-of-definition.

*--- create Control p_r_join_ctrl
  m_append_event:
*                 objectdoubleclick,       "Doppelklick
*                 contextmenusel,          "Kontextmenueintrag selektiert
                  contextmenureq,
*                 leftbuttondown,          "linke Maustaste gedrückt
*                 leftbuttonup,            "linke Maustaste loslassen
                  leftbuttondoubleclick,   "Linke Maustaste Doppelklick
*                 linkleftbuttondblclk,    "Link: linke Maust. Doppelklick
*                 linkrightbuttondown,     "Link: rechte Maust. gedrückt
*                 linktextchanged,         "Link: Textänderung
*                 PREDROPROWOBJECT,
                  prechangedstobject,      "neues Zielobject möglich
                  prechangesrcobject,      "neues Quellobject möglich?
*                 dstobjectchanged,        "Link: neues Zielobject
*                 srcobjectchanged,        "Link: neues Quellobject
                  newlink,                 "Neuer Link
                  checkboxclick.           "Checkbox
*                 newtable.                "Neue Tabelle

*--- contextmenue
  l_s_ctxmnu_use-table       = aqqis_c_true.
  l_s_ctxmnu_use-link        = aqqis_c_true.
  l_s_ctxmnu_use-background  = aqqis_c_true.

  cl_gui_aqqgraphic_netplan=>get_netplan_object( exporting i_r_parent     = i_r_container_parent
                                                           i_t_events     = l_t_event
                                                           i_s_ctxmnu_use = l_s_ctxmnu_use
                                                 importing e_r_netplan    = p_r_join_cntrl ).

*--- set handler
  set handler: on_handle_ctxmnureq     for p_r_join_cntrl,
               on_handle_ctxmnusel     for p_r_join_cntrl,
*              on_handle_CHECKBOXCLICK for p_r_join_cntrl,
               on_handle_succ_changed  for p_r_join_cntrl,
               on_handle_pred_changed  for p_r_join_cntrl,
               on_handle_link_created  for p_r_join_cntrl,
               on_handle_objdblclick   for p_r_join_cntrl.
*              on_handle_drop          for p_r_join_cntrl.

* set active mode to create links by Drag&drop
  p_r_join_cntrl->set_activemode( exporting  i_mode           = aqqis_c_cntrlmode-createlinkbydd
                                  exceptions wrong_activemode = 1
                                             others           = 2 ).
  if sy-subrc <> 0.
*   fatal error &1 &2 &3 &4
    message a008(aqqis_cntrl) with 'INIT_JOIN_CNTRL' 'SET_ACTIVEMODE'.
  endif.

* backgroundcolor: switch between display and change
  if     p_mode = aqqis_c_mode-display.
    l_on = aqqis_c_true.
  elseif p_mode = aqqis_c_mode-maint.
    l_on = aqqis_c_false.
  endif.
  p_r_join_cntrl->set_displayonly( exporting  i_on              = l_on
*                                             I_CHANGEBACKCOLOR = AQQIS_C_TRUE
                                   exceptions wrong_inputvalue  = 1
                                              others            = 2 ).
  if sy-subrc <> 0.
    message a008(aqqis_cntrl) with 'INIT_JOIN_CNTRL' 'SET_DISPLAYONLY'.
  endif.


  p_default_linkstyle = p_r_join_cntrl->create_new_link_style( i_arrowstart = aqqis_c_false
                                                               i_arrowend   = aqqis_c_false
                                                               i_width      = 30
                                                               i_color      = aqqis_c_defval-linkcolor ).
* Personalisierung
  data: l_r_pers type ref to cl_query_join_pers.
  l_r_pers = cl_query_join_pers=>factory( ).

  p_r_join_cntrl->set_zoom( exporting i_zoom     = l_r_pers->p_s_data-zoom
                                      i_autozoom = aqqis_c_false ).

  p_r_join_cntrl->set_navigation_visible( exporting i_visible = l_r_pers->p_s_data-navvisible ) .

endmethod.                    "INIT_JOIN_CNTRL


method IS_VALID_LINK .

  data: lt_tab1  type aqq_t_tab,
        lt_tab2  type aqq_t_tab,
        l_fname1 type aqs_fname,
        l_fname2 type aqs_fname.

  field-symbols: <tobj_join1> type AQSTOBJJOI,
                 <tobj_join2> type AQSTOBJJOI,
                 <fobj_join1> type AQSFOBJJOI,
                 <fobj_join2> type AQSFOBJJOI,
                 <join>       type aqq_s_join,
                 <tab1>       type aqq_s_tab,
                 <tab2>       type aqq_s_tab.

  e_valid = aqqis_c_true.

*--- DDIC-Eigenschaften
  read table p_t_tobj_join with key tabref = i_r_succtab assigning <tobj_join1>.
  check sy-subrc = 0.
  read table <tobj_join1>-fobj assigning <fobj_join1> index i_succrow.
  check sy-subrc = 0.

  read table p_t_tobj_join with key tabref = i_r_predtab assigning <tobj_join2>.
  check sy-subrc = 0.
  read table <tobj_join2>-fobj assigning <fobj_join2> index i_predrow.
  check sy-subrc = 0.

  e_tname1 = <tobj_join1>-tname.
  e_tname2 = <tobj_join2>-tname.
  e_fname1 = <fobj_join1>-fname.
  e_fname2 = <fobj_join2>-fname.

  GET_TAB( EXPORTING I_TABNAME = <tobj_join1>-tname
           IMPORTING ET_TAB    = lt_tab1 ).

  GET_TAB( EXPORTING I_TABNAME = <tobj_join2>-tname
           IMPORTING ET_TAB    = lt_tab2 ).

* Felder derselben Tabelle verlinken
  if <tobj_join1>-tname = <tobj_join2>-tname.
    e_valid = aqqis_c_false.
    exit.
  endif.

* Prüfen technische Eingenschaften
  read table lt_tab1 assigning <tab1> with key feld = <fobj_join1>-fname.
  read table lt_tab2 assigning <tab2> with key feld = <fobj_join2>-fname.

  if <tab1>-dleng ne <tab2>-dleng or
     <tab1>-dtype ne <tab2>-dtype or
     <tab1>-ddec  ne <tab2>-ddec.
    e_valid = aqqis_c_false.
    exit.
  endif.

* Prüfen, ob dieser link schon existiert
  concatenate <tobj_join1>-tname '-' <fobj_join1>-fname into l_fname1.
  concatenate <tobj_join2>-tname '-' <fobj_join2>-fname into l_fname2.
  read table p_t_links_join with key tnameleft  = <tobj_join1>-tname
                                     fnameleft  = l_fname1
                                     tnameright = <tobj_join2>-tname
                                     fnameright = l_fname2
                                     transporting no fields.
  if sy-subrc = 0.
    e_valid = aqqis_c_false.
    exit.
  endif.
  read table p_t_links_join with key tnameleft  = <tobj_join2>-tname
                                     fnameleft  = l_fname2
                                     tnameright = <tobj_join1>-tname
                                     fnameright = l_fname1
                                     transporting no fields.
  if sy-subrc = 0.
    e_valid = aqqis_c_false.
    exit.
  endif.

*---
*   unzulässig:
*   tab1-f1---     tab2-f1
*   tab1-f2   \    tab2-f2
*   tab1-f3    \   tab2-f3
*   tab1-f4------- tab2-f4
  loop at pt_join assigning <join> where tabnamel = <tobj_join1>-tname
                                     and colnamel = <fobj_join1>-fname.
    if <join>-tabnamer = <tobj_join2>-tname.
      e_valid = aqqis_c_false.
      exit.
    endif.
  endloop.

  loop at pt_join assigning <join> where tabnamel = <tobj_join2>-tname
                                     and colnamel = <fobj_join2>-fname.
    if <join>-tabnamer = <tobj_join1>-tname.
      e_valid = aqqis_c_false.
      exit.
    endif.
  endloop.

  loop at pt_join assigning <join> where tabnamer = <tobj_join1>-tname
                                     and colnamer = <fobj_join1>-fname.
    if <join>-tabnamel = <tobj_join2>-tname.
      e_valid = aqqis_c_false.
      exit.
    endif.
  endloop.

  loop at pt_join assigning <join> where tabnamer = <tobj_join2>-tname
                                     and colnamer = <fobj_join2>-fname.
    if <join>-tabnamel = <tobj_join1>-tname.
      e_valid = aqqis_c_false.
      exit.
    endif.
  endloop.

endmethod.                    "IS_VALID_LINK


method JOIN_MODIFICATION .

  data: ls_join  type aqq_s_join,
        l_fnamel type aqs_fname,
        l_fnamer type aqs_fname,
        l_fname  type aqs_fname,
        l_tab1   type aqs_tname,
        l_tab2   type aqs_tname,
        l_tab3   type aqs_tname.

  field-symbols: <links_join> type AQSLINKJOI.

  read table p_t_links_join assigning <links_join> with key linkref = ir_link.

  l_fname = <links_join>-fnameleft.
  CNVT_FNAME_ONE_2_TWO( EXPORTING I_FNAME = l_fname
                        IMPORTING E_FNAME = l_fnamel ).
  l_fname = <links_join>-fnameright.
  CNVT_FNAME_ONE_2_TWO( EXPORTING I_FNAME = l_fname
                        IMPORTING E_FNAME = l_fnamer ).

  read table pt_join into ls_join with key tabnamel = <links_join>-tnameleft
                                           colnamel = l_fnamel
                                           tabnamer = <links_join>-tnameright
                                           colnamer = l_fnamer.

  ls_join-type = i_join_typ.
  TEST_JOIN_VALIDITY( EXPORTING  IS_JOIN                 = ls_join
                      importing  e_tabname1              = l_tab1
                                 e_tabname2              = l_tab2
                                 e_tabname3              = l_tab3
                      EXCEPTIONS MODE_INVALID            = 1
                                 JOIN_TYPE_INVALID_LEFT  = 2
                                 JOIN_TYPE_INVALID_RIGHT = 2
                                 JOIN_TYPE_INVALID_SIDE  = 2
                                 JOIN_TYPE_INVALID_TWICE = 3
                                 JOIN_TYPE_INCONSISTENT  = 4 ).

  case sy-subrc.
    when 2.
*     Illegale Left-outer-join-Kette zwischen Tabellen &1 &2 &3
      message s020(aqqis_cntrl) with l_tab1 l_tab2 l_tab3.
      exit.
    when 3.
*     &1 kann nicht mit zwei Tabellen durch Left-outer-Join verbunden werden
      message s021(aqqis_cntrl) with l_tab2.
      exit.
    when 4.
*     on modification this means force the join-type for all joins
      execute_join_modification( is_join = ls_join
                                 ir_link = ir_link ).
      SET_CHANGED( EXPORTING I_CHANGED = aqqis_c_changed-updated ).
      exit.
    when others.
  endcase.

  execute_join_modification( is_join = ls_join
                             ir_link = ir_link ).
  SET_CHANGED( EXPORTING I_CHANGED = aqqis_c_changed-updated ).

endmethod.                    "JOIN_MODIFICATION


method NAVIGATOR .

  data: l_r_pers type ref to cl_query_join_pers.

  l_r_pers = cl_query_join_pers=>factory( ).

  if     l_r_pers->p_s_data-navvisible = aqqis_c_false.
    p_r_join_cntrl->set_navigation_visible( exporting i_visible = aqqis_c_true ).
    l_r_pers->p_s_data-navvisible = aqqis_c_true.
  elseif l_r_pers->p_s_data-navvisible = aqqis_c_true.
    p_r_join_cntrl->set_navigation_visible( exporting i_visible = aqqis_c_false ).
    l_r_pers->p_s_data-navvisible = aqqis_c_false.
  endif.

endmethod.                    "NAVIGATOR


method ON_CONDITION .

  data: l_lin_tpos    type i,
        l_tname1      type aqs_tname,
        l_tname2      type aqs_tname,
        l_tname_dummy type aqs_tname,
        lt_dbjt       type aqtdbjt,
        ls_tpos1      type aqq_s_tpos,
        ls_tpos2      type aqq_s_tpos.

  field-symbols: <tobj_join1> type AQSTOBJJOI,
                 <tobj_join2> type AQSTOBJJOI.

  if P_MODE = aqqis_c_mode-display.
*   Funktion nur im Änderungsmodus unterstützt
    message s005(aqqis_cntrl).
    exit.
  endif.

  DESCRIBE TABLE pt_TPOS LINES l_lin_tpos.
  if     l_lin_tpos <= 0.
*   Es ist keine Tabelle vorhanden
    message s012(aqqis_cntrl).
    exit.

  elseif l_lin_tpos = 1.
*   Es ist nur eine Tabelle vorhanden
    message s013(aqqis_cntrl).
    exit.

  elseif l_lin_tpos = 2.
    read table pt_tpos into ls_tpos1 index 1.
    read table pt_tpos into ls_tpos2 index 2.
    propose_on_condition( exporting  i_tabnamel             = ls_tpos1-tabname
                                     i_tabnamer             = ls_tpos2-tabname
                          exceptions no_joins_found         = 1
                                     no_further_joins_found = 2
                                     join_addition_invalid  = 3 ).

* mehr als 2 Tabellen auf dem Control
  else.
    get_selected_table( importing  e_tname                 = l_tname1
                        exceptions no_table_selected       = 1
                                   several_tables_selected = 2 ).

* Popup: Angabe beider Tabellen, für die die Vorschläge gemacht werden sollen
    p_join_data_r->get_info( importing et_dbjt = lt_dbjt ).
    CALL FUNCTION 'RSAQ_CNTRL_PROPOSE_ON_0500'
      EXPORTING
        it_dbjt   = lt_dbjt
        i_tname   = l_tname1
      IMPORTING
        e_tname1  = l_tname1
        e_tname2  = l_tname2
      EXCEPTIONS
        cancelled = 1.
    if sy-subrc ne 0.
*     Aktion abgebrochen
      message s001(aqqis_cntrl).
      exit.
    endif.

* Positionen von rechter und linker Tabelle bestimmen, ggf. tauschen
* damit rechts auch wirklich rechts ist und links auch wirklich links
* reads müssen gutgehen
    read table p_t_tobj_join assigning <tobj_join1> with key tname = l_tname1.
    read table p_t_tobj_join assigning <tobj_join2> with key tname = l_tname2.
    if <tobj_join1>-tpos-leftpos < <tobj_join2>-tpos-leftpos.
    else.
      l_tname_dummy = l_tname1.
      l_tname1      = l_tname2.
      l_tname2      = l_tname_dummy.
    endif.

* Vorschläge on-Bedingung
    propose_on_condition( exporting  i_tabnamel             = l_tname1
                                     i_tabnamer             = l_tname2
                          exceptions no_joins_found         = 1
                                     no_further_joins_found = 2
                                     join_addition_invalid  = 3 ).
  endif.

  if     sy-subrc = 1.
*   Keine Verknüpfungen gefunden
    message s002(aqqis_cntrl).
    exit.
  elseif sy-subrc = 2.
*   Keine weiteren Verknüpfungen gefunden
    message s003(aqqis_cntrl).
    exit.
  elseif sy-subrc = 3.
*   Verknüpfungen lassen sich nicht als Left-outer Bedingung einfügen
    message s004(aqqis_cntrl).
    exit.
  endif.

  p_r_join_cntrl->send_data_to_frontend( ).

endmethod.                    "ON_CONDITION


method ON_HANDLE_CTXMNUREQ .
* durch die Paramter  R_TABLE
*                     ROWINDEX
*                     R_LINK
*                     BACKGROUND
* erhält man das Objekt, auf dem das Kontextmenue gerufen wurde.

  data: l_submnu      type ref to cl_ctmenu,
        l_laymnu      type ref to cl_ctmenu,
        l_fcode       type        ui_func,
        l_t_fcode     type        ui_functions.
  data: l_s_tobj_join type        aqstobjjoi.

*--- table objects
  if not r_table is initial.
*    read table p_t_tobj_join with key tabref = r_table
*               into l_s_tobj_join.
    if rowindex <= 0.
      l_fcode = aqqis_c_ok_ddic.
      append l_fcode to l_t_fcode.
      r_ctxmnu->add_function( exporting fcode = l_fcode
                                        text  = text-015 ).     " Absprung ins Dictionary

      l_fcode = aqqis_c_ok_f_tdel.
      append l_fcode to l_t_fcode.
      r_ctxmnu->add_function( exporting fcode = l_fcode
                                        text  = text-001 ).     " Objekt löschen

    else.
      l_fcode = aqqis_c_ok_fdoc.
      append l_fcode to l_t_fcode.
      r_ctxmnu->add_function( exporting fcode = l_fcode
                                        text  = text-016 ).     " Felddokumentation

      l_fcode = aqqis_c_ok_fref.
      append l_fcode to l_t_fcode.
      r_ctxmnu->add_function( exporting fcode = l_fcode
                                        text  = text-017 ).     " Referenzfeld
    endif.

*    if is_left_outer( r_table ) = aqqis_c_true.
*      l_fcode = aqqis_c_ok_lijoin.
*      append l_fcode to l_t_fcode.
*      r_ctxmnu->add_function( EXPORTING FCODE = l_fcode
*                                        TEXT  = text-002 ).   " inner join
**      change_link_text( ir_table = r_table
**                        i_outer  = aqqis_c_false ).
*    else.
*      l_fcode = aqqis_c_ok_lojoin.
*      append l_fcode to l_t_fcode.
*      r_ctxmnu->add_function( EXPORTING FCODE = l_fcode
*                                        TEXT  = text-003 ).   " left outer join
**      change_link_text( ir_table = r_table
**                        i_outer  = aqqis_c_true ).
*    endif.

  endif.

*--- link objects
  if not r_link is initial.
    data: l_fnamel type aqs_fname,
          l_fnamer type aqs_fname,
          l_fname  type aqs_fname.

    field-symbols: <links_join> type aqslinkjoi,
                   <join>       type aqq_s_join.

    read table p_t_links_join assigning <links_join> with key linkref = r_link.

    l_fname = <links_join>-fnameleft.
    cnvt_fname_one_2_two( exporting i_fname = l_fname
                          importing e_fname = l_fnamel ).
    l_fname = <links_join>-fnameright.
    cnvt_fname_one_2_two( exporting i_fname = l_fname
                          importing e_fname = l_fnamer ).

    read table pt_join assigning <join> with key tabnamel = <links_join>-tnameleft
                                                 colnamel = l_fnamel
                                                 tabnamer = <links_join>-tnameright
                                                 colnamer = l_fnamer.
    if     <join>-type = aqqis_c_join_typ-inner.
      l_fcode = aqqis_c_ok_lojoin.
      append l_fcode to l_t_fcode.
      r_ctxmnu->add_function( exporting fcode = l_fcode
                                        text  = text-003 ).   " left outer join
    elseif <join>-type = aqqis_c_join_typ-left_outer.
      l_fcode = aqqis_c_ok_lijoin.
      append l_fcode to l_t_fcode.
      r_ctxmnu->add_function( exporting fcode = l_fcode
                                        text  = text-002 ).   " inner join
    endif.

    l_fcode = aqqis_c_ok_f_ldel.
    append l_fcode to l_t_fcode.
    r_ctxmnu->add_function( exporting fcode = l_fcode
                                      text  = text-014 ).   " Link löschen
  endif.

*--- on background
  if background = aqqis_c_true.
    l_fcode = aqqis_c_ok_f_zoomin.
    append l_fcode to l_t_fcode.
    r_ctxmnu->add_function( exporting fcode = l_fcode
                                      text  = text-004 ).   " Zoom in

    l_fcode = aqqis_c_ok_f_zoomout.
    append l_fcode to l_t_fcode.
    r_ctxmnu->add_function( exporting fcode = l_fcode
                                      text  = text-005 ).   " Zoom out

*    l_fcode = aqqis_c_ok_F_fit.
*    append l_fcode to l_t_fcode.
*    r_ctxmnu->add_function( EXPORTING FCODE = l_fcode
*                                      TEXT  = text-006 ).   " autoarrange

    l_fcode = aqqis_c_ok_f_navi.
    append l_fcode to l_t_fcode.
    r_ctxmnu->add_function( exporting fcode = l_fcode
                                      text  = text-007 ).   " Navigation ein/aus

*    l_fcode = aqqis_c_ok_F_link.
*    append l_fcode to l_t_fcode.
*    r_ctxmnu->add_function( EXPORTING FCODE = l_fcode
*                                      TEXT  = text-008 ).   " Linkpflege

    l_fcode = aqqis_c_ok_f_scale.
    append l_fcode to l_t_fcode.
    r_ctxmnu->add_function( exporting fcode = l_fcode
                                      text  = text-012 ).   " Navigation ein/aus

  endif.

  if not r_table is initial.
  else.
    if p_mode = aqqis_c_mode-display.
      r_ctxmnu->disable_functions( exporting fcodes = l_t_fcode ).
    endif.
  endif.
endmethod.                    "ON_HANDLE_CTXMNUREQ


method ON_HANDLE_CTXMNUSEL .

  data: l_fcode_ui type ui_func.

  l_fcode_ui = fcode.
  handle_fcode( exporting i_fcode    = l_fcode_ui
                          ir_table   = r_table
                          i_rowindex = rowindex
                          ir_link    = r_link  ).

endmethod.                    "


method ON_HANDLE_LINK_CREATED .

  data: l_valid  type        boolean,
        l_tname1 type        aqs_tname,
        l_tname2 type        aqs_tname,
        l_fname1 type        aqs_fname,
        l_fname2 type        aqs_fname,
        l_fnamel type        aqs_fname,
        l_fnamer type        aqs_fname,
        ls_link  type        aqslinkjoi,
        ls_join  type        aqq_s_join,
        l_text   type        aqq_text,
        lr_tabl  type ref to if_aqqgraphic_table,
        lr_tabr  type ref to if_aqqgraphic_table,
        l_r_link type ref to if_aqqgraphic_link.

  field-symbols: <tpos1>     type aqq_s_tpos,
                 <tpos2>     type aqq_s_tpos,
                 <join>      type aqq_s_join,
                 <tobj_join> type aqstobjjoi.

  if p_mode = aqqis_c_mode-display.
*   Funktion nur im Änderungsmodus unterstützt
    r_doit->o_ok = aqqis_c_false.
    message s005(aqqis_cntrl).
    exit.
  endif.

* setzen Änderungsflag
  set_changed( exporting i_changed = aqqis_c_changed-updated ).
*>>>
  data: ls_join_n     type aqq_s_join,
        l_tab1        type aqs_tname,
        l_tab2        type aqs_tname,
        l_tab3        type aqs_tname,
        l_check       type boolean,
        ls_join_check type aqq_s_join.

  field-symbols: <tobj_join_1> type aqstobjjoi,
                 <tobj_join_2> type aqstobjjoi,
                 <fobj_join_1> type aqsfobjjoi,
                 <fobj_join_2> type aqsfobjjoi.

  read table p_t_tobj_join assigning <tobj_join_1> with key tabref = r_predtab.
  ls_join_n-tabnamel = <tobj_join_1>-tname.
  read table <tobj_join_1>-fobj assigning <fobj_join_1> index pred_row.
  ls_join_n-colnamel = <fobj_join_1>-fname.

  read table p_t_tobj_join assigning <tobj_join_2> with key tabref = r_succtab.
  ls_join_n-tabnamer = <tobj_join_2>-tname.
  read table <tobj_join_2>-fobj assigning <fobj_join_2> index succ_row.
  ls_join_n-colnamer = <fobj_join_2>-fname.

* check if join already exists between these two tables.
  read table pt_join into ls_join_check with key tabnamel = ls_join_n-tabnamel
                                                 tabnamer = ls_join_n-tabnamer.
  if sy-subrc = 0.
    ls_join_n-type = ls_join_check-type.
  else.
    read table pt_join into ls_join_check with key tabnamel = ls_join_n-tabnamer
                                                   tabnamer = ls_join_n-tabnamel.
    if sy-subrc = 0.
      ls_join_n-type = ls_join_check-type.
    else.
      ls_join_n-type = aqqis_c_join_typ-inner.
    endif.
  endif.

  test_join_validity( exporting  is_join                 = ls_join_n
                      importing  e_tabname1              = l_tab1
                                 e_tabname2              = l_tab2
                                 e_tabname3              = l_tab3
                      exceptions mode_invalid            = 1
                                 join_type_invalid_left  = 2
                                 join_type_invalid_right = 2
                                 join_type_invalid_side  = 2
                                 join_type_invalid_twice = 3
                                 join_type_inconsistent  = 4
                                 others                  = 99 ).
  case sy-subrc.
    when 0.
    when 2.
      r_doit->o_ok = aqqis_c_false.
*     Illegale Left-outer-join-Kette zwischen Tabellen &1 &2 &3
      message s020(aqqis_cntrl) with l_tab1 l_tab2 l_tab3.
      exit.
    when 3.
      r_doit->o_ok = aqqis_c_false.
*     &1 kann nicht mit zwei Tabellen durch Left-outer-Join verbunden werden
      message s021(aqqis_cntrl) with l_tab2.
      exit.
    when 4.
      r_doit->o_ok = aqqis_c_false.
*     on modification this means force the join-type for all joins
      execute_join_modification( is_join = ls_join
                                 ir_link = r_newlink ).
      set_changed( exporting i_changed = aqqis_c_changed-updated ).
*     Ein (Left-Outer) Join kann hier nicht definiert werden.
      message s036(aqqis_cntrl).
      exit.
    when others.
      r_doit->o_ok = aqqis_c_false.
*     Illegale Join-Bedingungen
      message s035(aqqis_cntrl).
      exit.
  endcase.
*<<<
  synchronize_positions( exporting  iv_no_cancel_on_error = abap_true  "note 2114455
                         exceptions no_data_on_control = 1 ).

* check if link is valid
  is_valid_link( exporting i_r_succtab = r_succtab
                           i_succrow   = succ_row
                           i_r_predtab = r_predtab
                           i_predrow   = pred_row
                 importing e_valid     = l_valid
                           e_tname1    = l_tname1
                           e_tname2    = l_tname2
                           e_fname1    = l_fname1
                           e_fname2    = l_fname2 ).

  if l_valid = aqqis_c_true.

    l_r_link = r_newlink.

* p_t_links_join ergänzen
    read table pt_tpos assigning <tpos1> with key tabname = l_tname1.
    read table pt_tpos assigning <tpos2> with key tabname = l_tname2.

    if <tpos1>-xpos < <tpos2>-xpos.
      ls_link-tnameleft  = l_tname1.
      concatenate l_tname1 '-' l_fname1 into ls_link-fnameleft.
      ls_link-tnameright = l_tname2.
      concatenate l_tname2 '-' l_fname2 into ls_link-fnameright.
      l_fnamel = l_fname1.
      l_fnamer = l_fname2.
    else.
      ls_link-tnameleft  = l_tname2.
      concatenate l_tname2 '-' l_fname2 into ls_link-fnameleft.
      ls_link-tnameright = l_tname1.
      concatenate l_tname1 '-' l_fname1 into ls_link-fnameright.
      l_fnamel = l_fname2.
      l_fnamer = l_fname1.
    endif.
    ls_link-linkref = l_r_link.
    append ls_link to p_t_links_join.

* pt_join ergänzen
    read table pt_join assigning <join> with key tabnamel = ls_link-tnameleft
                                                 tabnamer = ls_link-tnameright.
    if sy-subrc = 0.
      ls_join-type = <join>-type.
    else.
      ls_join-type = aqqis_c_join_typ-inner.
    endif.

    ls_join-tabnamel = ls_link-tnameleft.
    ls_join-colnamel = l_fnamel.
    ls_join-tabnamer = ls_link-tnameright.
    ls_join-colnamer = l_fnamer.
    append ls_join to pt_join.

* Text des links besorgen
    read table p_t_tobj_join assigning <tobj_join> with key tabref = r_succtab.
    if <tobj_join>-tname = ls_join-tabnamel.
      lr_tabl = r_succtab.
      lr_tabr = r_predtab.
    else.
      lr_tabr = r_succtab.
      lr_tabl = r_predtab.
    endif.
    l_text = fetch_outerflag_text( ir_tabl = lr_tabl
                                   ir_tabr = lr_tabr ).

    l_r_link->set_attributes( exporting i_moveable     = aqqis_c_true
*                                       I_SELECTABLE   = aqqis_C_TRUE
                                        i_editable     = aqqis_c_false
*                                       I_MOUSEOVER    = aqqis_C_TRUE
*                                       I_ELBOWLINK    = aqqis_C_FALSE
*                                       I_ANGLELINK    = aqqis_C_TRUE
*                                       I_BUNCHLINK    = aqqis_C_FALSE
*                                       I_SIMPLELINK   = aqqis_C_FALSE
*                                       I_DESMERGELINK = aqqis_C_TRUE
    ).

    l_r_link->set_status( ).

    l_r_link->set_properties( exporting i_linkstyle = p_default_linkstyle
                                        i_text      = l_text ).
  else.
    r_doit->o_ok = aqqis_c_false.
    concatenate l_tname2 '-' l_fname2 into l_fname2.
    concatenate l_tname1 '-' l_fname1 into l_fname1.
*   Die Felder &1 &2 können nicht verknüpft werden
    message s022(aqqis_cntrl) with l_fname1 l_fname2.
    exit.
  endif.

  cnvt_table_to_old_dbjc( ).

endmethod.                    "ON_HANDLE_LINK_CREATED


method ON_HANDLE_OBJDBLCLICK .

  data: l_s_tobj_join type AQSTOBJJOI,
        l_s_fobj      type AQSFOBJJOI,
        lt_tab        type aqq_t_tab,
        l_ref         type flag,
        ls_exdbfi     type AQSEXDBFI,
        lt_exdbfi     type aqq_t_exdbfi.

  field-symbols: <tab> type aqq_s_tab.

  if not r_table is initial.
    read table p_t_tobj_join into l_s_tobj_join with key tabref = r_table.
    check sy-subrc = 0.

    read table l_s_tobj_join-fobj into l_s_fobj index row.
    check sy-subrc = 0.

    GET_TAB( EXPORTING I_TABNAME = l_s_tobj_join-tname
             IMPORTING ET_TAB    = lt_tab ).

    read table lt_tab assigning <tab> with key feld = l_s_fobj-fname.
    if sy-subrc = 0.
*--- Referenzfeld
*      break rueger.
      if l_ref = aqqis_c_true.
        referenzfield( is_tab  = <tab>
                       i_tname = l_s_tobj_join-tname ).

*--- Felddokumentation
      elseif l_ref = aqqis_c_false.
        CALL FUNCTION 'RSAQ_CNTRL_BUILD_EXDBFI'
          EXPORTING
            I_TAB     = l_s_tobj_join-tname
          IMPORTING
            et_exdbfi = lt_exdbfi.

        read table lt_exdbfi into ls_exdbfi with key DDIC-FIELDNAME = <tab>-feld.

        CALL FUNCTION 'RSAQ_CNTRL_FIELD_DOCU'
          EXPORTING
            IS_exdbfi = ls_exdbfi.
*--- DDic Absprung
      else.
        data: l_OBJNAME type DDOBJNAME,
              l_OBJTYPE type ddeutype,
              lt_dban   type aqtdban.
        field-symbols: <dban> type aqdban.

        p_join_data_r->get_info( importing et_dban = lt_dban ).

        l_objname = l_s_tobj_join-tname.
        read table lt_dban assigning <dban> with key alias = l_objname.
        if sy-subrc = 0.
          l_objname = <dban>-table.
        endif.

        l_objtype = 'T'.
        CALL FUNCTION 'RS_DD_SHOW'
          EXPORTING
            OBJNAME                    = l_objname
            OBJTYPE                    = l_objtype
*         POPUP                      = ' '
*         SECNAME                    =
*         MONITOR_ACTIVATE           = 'X'
*       IMPORTING
*         FCODE                      =
         EXCEPTIONS
           OBJECT_NOT_FOUND           = 1
           OBJECT_NOT_SPECIFIED       = 2
           PERMISSION_FAILURE         = 3
           TYPE_NOT_VALID             = 4.

        IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.
      endif.

    endif.
  endif.

endmethod.                    "ON_HANDLE_OBJDBLCLICK


method ON_HANDLE_PRED_CHANGED .

  data: l_r_succ      type ref to if_aqqgraphic_table,
        l_succrow     type        aqq_rownr .

  if P_MODE = aqqis_c_mode-display.
*   Funktion nur im Änderungsmodus unterstützt
    r_doit->o_ok = aqqis_c_false.
    message s005(aqqis_cntrl).
    exit.
  endif.

* setzen Änderungsflag
  SET_CHANGED( EXPORTING I_CHANGED = aqqis_c_changed-updated ).

  synchronize_positions( exporting  iv_no_cancel_on_error = abap_true  "note 2114455
                         exceptions no_data_on_control = 1 ).

  r_link->get_successor( importing e_r_table   = l_r_succ
                                   e_rowindex  = l_succrow ).

* o_ok = ' '  -> change not possible
* o_ok = 'X'  -> link can be changed
  r_doit->o_ok = handle_link_changed( i_r_link       = r_link
                                      i_r_tab_new    = r_predtab
                                      i_row_new      = predrow
                                      i_r_tab_kept   = l_r_succ
                                      i_row_kept     = l_succrow
                                      i_succ_changed = aqqis_c_false ).

endmethod.                    "ON_HANDLE_PRED_CHANGED


method ON_HANDLE_SUCC_CHANGED .

  data: l_r_pred   type ref to if_aqqgraphic_table,
        l_predrow  type        aqq_rownr .

  if P_MODE = aqqis_c_mode-display.
*   Funktion nur im Änderungsmodus unterstützt
    r_doit->o_ok = aqqis_c_false.
    message s005(aqqis_cntrl).
    exit.
  endif.

* setzen Änderungsflag
  SET_CHANGED( EXPORTING I_CHANGED = aqqis_c_changed-updated ).

  synchronize_positions( exporting  iv_no_cancel_on_error = abap_true  "note 2114455
                         exceptions no_data_on_control = 1 ).

  r_link->get_predecessor( importing e_r_table   = l_r_pred
                                     e_rowindex  = l_predrow ).

* o_ok = ' '  -> change not possible
* o_ok = 'X'  -> link can be changed
  r_doit->o_ok = handle_link_changed( i_r_link       = r_link
                                      i_r_tab_new    = r_succtab
                                      i_row_new      = succrow
                                      i_r_tab_kept   = l_r_pred
                                      i_row_kept     = l_predrow
                                      i_succ_changed = aqqis_c_true ).
endmethod.                    "ON_HANDLE_SUCC_CHANGED


method PRINT_CONTROL .

  call method p_r_join_cntrl->print.

endmethod.


method PROPOSE_ON_CONDITION .

* >>> Y7AK099946
  types: begin of ty_forkey.
         include type dd05m.
  types: is_key TYPE flag,
         end of ty_forkey.
* <<< Y7AK099946
  data: l_join_found type flag value ' ',
        l_tabname    type tname,
        l_state      type objstate,     " (like ddrefstruc-state, )
        lt_head      type standard table of dd08v,
        ls_fkey      type dd05m,
        lt_fkey      type standard table of dd05m,
        lt_hdum      type standard table of dd08v,
        lt_fdum      type standard table of dd05m,
        ls_join      type aqq_s_join,
        lt_join      type aqq_t_join,
        ls_headsg    type aqhdsg,
* >>> Y7AK099946
        lt_tfield    type aqq_t_tfield,
        lt_forkey    type table of ty_forkey,
        ls_forkey    type ty_forkey.
* <<< Y7AK099946

  lt_join[] = pt_join[].
  lt_tfield[] = pt_tfield[].                                "Y7AK099946

  sort lt_tfield by tabname colname iskey.                  "Y7AK099946

  p_join_data_r->get_info( importing e_headsg = ls_headsg ).

* Fremdschlüsselbeziehungen auswerten
  ls_join-op   = aqqis_c_join_operator-eq.
  ls_join-type = aqqis_c_join_typ-inner.

* Fremdschlüsselbeziehungen LTAB -> RTAB
  l_tabname = i_tabnamel.
  call function 'DD_TBFK_GET'
    exporting
      tabl_name   = l_tabname
    importing
      got_state   = l_state
    tables
      dd05m_tab_a = lt_fkey
      dd05m_tab_n = lt_fdum
      dd08v_tab_a = lt_head
      dd08v_tab_n = lt_hdum
    exceptions
      others      = 1.

* >>> Y7AK099946
  delete lt_fkey where datatype   eq 'CLNT'
                    or fortable   ne i_tabnamel
                    or checktable ne i_tabnamer.

  clear lt_forkey.

  loop at lt_fkey into ls_fkey.
    clear ls_forkey.
    move-corresponding ls_fkey to ls_forkey.
    read table lt_tfield with key tabname = i_tabnamel
                                  colname = ls_fkey-forkey
                                  iskey   = '1'
                                  binary search
                                  transporting no fields.
    if sy-subrc eq 0.
      ls_forkey-is_key = 'X'.
    else.
      clear ls_forkey-is_key.
    endif.

    append ls_forkey to lt_forkey.
  endloop.

  sort lt_forkey by is_key descending.

  loop at lt_forkey into ls_forkey.
* <<< Y7AK099946
    ls_join-op       = aqqis_c_join_operator-eq.
    ls_join-type     = aqqis_c_join_typ-inner.
    ls_join-tabnamel = i_tabnamel.
    ls_join-colnamel = ls_forkey-forkey.                    "Y7AK099946
    ls_join-tabnamer = i_tabnamer.
    ls_join-colnamer = ls_forkey-checkfield.                "Y7AK099946

    read table lt_join with key tabnamel = ls_join-tabnamel
                                colnamel = ls_join-colnamel
                                tabnamer = ls_join-tabnamer
                                transporting no fields.
    if sy-subrc <> 0.
      read table lt_join with key tabnamer = ls_join-tabnamel
                                  colnamer = ls_join-colnamel
                                  tabnamel = ls_join-tabnamer
                                  transporting no fields.

      if sy-subrc <> 0.
        read table lt_join with key tabnamel = ls_join-tabnamel
                                    tabnamer = ls_join-tabnamer
                                    colnamer = ls_join-colnamer
                                    transporting no fields.
        if sy-subrc <> 0.
          read table lt_join with key tabnamer = ls_join-tabnamel
                                      tabnamel = ls_join-tabnamer
                                      colnamel = ls_join-colnamer
                                      transporting no fields.
          if sy-subrc <> 0.
            test_join_validity( exporting  is_join                 = ls_join
                                exceptions mode_invalid            = 1
                                           join_type_invalid_left  = 2
                                           join_type_invalid_right = 2
                                           join_type_invalid_side  = 2
                                           join_type_invalid_twice = 2
                                           join_type_inconsistent  = 3
                                           tab_not_found           = 4
                                           field_not_found         = 4 ).
            if sy-subrc = 2.
              raise join_addition_invalid.
            endif.
            if ( sy-subrc = 3 ).
              force_jointype( exporting  i_change_old = aqqis_c_false
                              changing   cs_join      = ls_join
                              exceptions inconsistent = 1 ).
              test_join_validity( exporting  is_join                 = ls_join
                                  exceptions join_type_invalid_left  = 2
                                             join_type_invalid_right = 2
                                             join_type_invalid_side  = 2
                                             join_type_invalid_twice = 2 ).
              if sy-subrc <> 0.
                raise join_addition_invalid.
              endif.
            endif.

            append: ls_join to lt_join,
                    ls_join to pt_join.
            l_join_found = aqqis_c_true.
            ls_headsg-state = aqqis_c_changed-updated.
            propose_on_condition_add_link( exporting is_join = ls_join ).
          endif.
        endif.
      endif.
    endif.
  endloop.

* Fremdschlüsselbeziehungen LTAB <- RTAB
  l_tabname = i_tabnamer.
  call function 'DD_TBFK_GET'
    exporting
      tabl_name   = l_tabname
    importing
      got_state   = l_state
    tables
      dd05m_tab_a = lt_fkey
      dd05m_tab_n = lt_fdum
      dd08v_tab_a = lt_head
      dd08v_tab_n = lt_hdum
    exceptions
      others      = 1.

* >>> Y7AK099946
  delete lt_fkey where datatype   eq 'CLNT'
                    or fortable   ne i_tabnamer
                    or checktable ne i_tabnamel.

  clear lt_forkey.

  loop at lt_fkey into ls_fkey.
    clear ls_forkey.
    move-corresponding ls_fkey to ls_forkey.
    read table lt_tfield with key tabname = i_tabnamel
                                  colname = ls_fkey-forkey
                                  iskey   = '1'
                                  binary search
                                  transporting no fields.
    if sy-subrc eq 0.
      ls_forkey-is_key = 'X'.
    else.
      clear ls_forkey-is_key.
    endif.

    append ls_forkey to lt_forkey.
  endloop.

  sort lt_forkey by is_key descending.

  loop at lt_forkey into ls_forkey.
* <<< Y7AK099946
    ls_join-tabnamel = i_tabnamel.
    ls_join-colnamel = ls_forkey-checkfield.                "Y7AK099946
    ls_join-tabnamer = i_tabnamer.
    ls_join-colnamer = ls_forkey-forkey.                    "Y7AK099946

    read table lt_join with key tabnamel = ls_join-tabnamel
                                colnamel = ls_join-colnamel
                                tabnamer = ls_join-tabnamer
                                transporting no fields.
    if sy-subrc <> 0.
      read table lt_join with key tabnamer = ls_join-tabnamel
                                  colnamer = ls_join-colnamel
                                  tabnamel = ls_join-tabnamer
                                  transporting no fields.

      if sy-subrc <> 0.
        read table lt_join with key tabnamel = ls_join-tabnamel
                                    tabnamer = ls_join-tabnamer
                                    colnamer = ls_join-colnamer
                                    transporting no fields.
        if sy-subrc <> 0.
          read table lt_join with key tabnamer = ls_join-tabnamel
                                      tabnamel = ls_join-tabnamer
                                      colnamel = ls_join-colnamer
                                      transporting no fields.
          if sy-subrc <> 0.
            test_join_validity( exporting  is_join                 = ls_join
                                exceptions mode_invalid            = 1
                                           join_type_invalid_left  = 2
                                           join_type_invalid_right = 2
                                           join_type_invalid_side  = 2
                                           join_type_invalid_twice = 2
                                           join_type_inconsistent  = 3
                                           tab_not_found           = 4
                                           field_not_found         = 4
                                           fields_invalid          = 5 ).
            if sy-subrc = 2.
              raise join_addition_invalid.
            endif.
            if sy-subrc = 3.
              force_jointype( exporting  i_change_old = aqqis_c_false
                              changing   cs_join      = ls_join
                              exceptions inconsistent = 1 ).
              test_join_validity( exporting  is_join                 = ls_join
                                  exceptions join_type_invalid_left  = 2
                                             join_type_invalid_right = 2
                                             join_type_invalid_side  = 2
                                             join_type_invalid_twice = 2 ).
              if sy-subrc <> 0.
                raise join_addition_invalid.
              endif.
            endif.
            if sy-subrc = 5.
              continue.
            endif.

            append: ls_join to lt_join,
                    ls_join to pt_join.
            l_join_found = aqqis_c_true.
            ls_headsg-state = aqqis_c_changed-updated.
            propose_on_condition_add_link( exporting is_join = ls_join ).
          endif.
        endif.
      endif.
    endif.
  endloop.

  if l_join_found = aqqis_c_true.                 " Fremdschlüsselbeziehungen gef.
    p_join_data_r->set_info( exporting i_headsg = ls_headsg ).
    cnvt_table_to_old( ).
    exit.
  endif.

* Standardvorschläge über Domänenbeziehungen
  data: lt_ltab  type aqq_t_tab,
        ls_ltab  type aqq_s_tab,
        lt_rtab  type aqq_t_tab,
        ls_rtab  type aqq_s_tab.

  get_tab( exporting i_tabname = i_tabnamel
           importing et_tab    = lt_ltab ).
  get_tab( exporting i_tabname = i_tabnamer
           importing et_tab    = lt_rtab ).

  loop at lt_ltab into ls_ltab where key <> space.
*    check not ls_ltab-dom is initial.
    loop at lt_rtab into ls_rtab where dom = ls_ltab-dom.
      ls_join-tabnamel = i_tabnamel.
      ls_join-colnamel = ls_ltab-feld.
      ls_join-tabnamer = i_tabnamer.
      ls_join-colnamer = ls_rtab-feld.

      read table lt_join with key tabnamel = ls_join-tabnamel
                                  colnamel = ls_join-colnamel
                                  tabnamer = ls_join-tabnamer
                                  transporting no fields.
      if sy-subrc <> 0.
        read table lt_join with key tabnamer = ls_join-tabnamel
                                    colnamer = ls_join-colnamel
                                    tabnamel = ls_join-tabnamer
                                    transporting no fields.
        if sy-subrc <> 0.
          read table lt_join with key tabnamel = ls_join-tabnamel
                                      tabnamer = ls_join-tabnamer
                                      colnamer = ls_join-colnamer
                                      transporting no fields.
          if sy-subrc <> 0.
            read table lt_join with key tabnamer = ls_join-tabnamel
                                        tabnamel = ls_join-tabnamer
                                        colnamel = ls_join-colnamer
                                        transporting no fields.
            if sy-subrc <> 0.
              test_join_validity( exporting  is_join                 = ls_join
                                  exceptions mode_invalid            = 1
                                             join_type_invalid_left  = 2
                                             join_type_invalid_right = 2
                                             join_type_invalid_side  = 2
                                             join_type_invalid_twice = 2
                                             join_type_inconsistent  = 3
                                             tab_not_found           = 4
                                             field_not_found         = 4
                                             fields_invalid          = 5 ).
              if sy-subrc = 2.
                raise join_addition_invalid.
              endif.
              if sy-subrc = 3.
                force_jointype( exporting  i_change_old = aqqis_c_false
                                changing   cs_join      = ls_join
                                exceptions inconsistent = 1 ).
                test_join_validity( exporting  is_join                 = ls_join
                                    exceptions join_type_invalid_left  = 2
                                               join_type_invalid_right = 2
                                               join_type_invalid_side  = 2
                                               join_type_invalid_twice = 2 ).
                if sy-subrc <> 0.
                  raise join_addition_invalid.
                endif.
              endif.
              if sy-subrc = 5.
                continue.
              endif.

              append: ls_join to lt_join,
                      ls_join to pt_join.
              l_join_found = aqqis_c_true.
              ls_headsg-state = aqqis_c_changed-updated.
              propose_on_condition_add_link( exporting is_join = ls_join ).
            endif.
          endif.
        endif.
      endif.
    endloop.
  endloop.

  loop at lt_rtab into ls_rtab where key <> space.
*    check not ls_rtab-dom is initial.
    loop at lt_ltab into ls_ltab where dom = ls_rtab-dom.
*      DBJC-JIND   = SPACE.
      ls_join-tabnamel = i_tabnamel.
      ls_join-colnamel = ls_ltab-feld.
      ls_join-tabnamer = i_tabnamer.
      ls_join-colnamer = ls_rtab-feld.

      read table lt_join with key tabnamel = ls_join-tabnamel
                                  colnamel = ls_join-colnamel
                                  tabnamer = ls_join-tabnamer
                                  transporting no fields.
      if sy-subrc <> 0.
        read table lt_join with key tabnamer = ls_join-tabnamel
                                    colnamer = ls_join-colnamel
                                    tabnamel = ls_join-tabnamer
                                    transporting no fields.
        if sy-subrc <> 0.
          read table lt_join with key tabnamel = ls_join-tabnamel
                                      tabnamer = ls_join-tabnamer
                                      colnamer = ls_join-colnamer
                                      transporting no fields.
          if sy-subrc <> 0.
            read table lt_join with key tabnamer = ls_join-tabnamel
                                        tabnamel = ls_join-tabnamer
                                        colnamel = ls_join-colnamer
                                        transporting no fields.
            if sy-subrc <> 0.
              test_join_validity( exporting  is_join                 = ls_join
                                  exceptions mode_invalid            = 1
                                             join_type_invalid_left  = 2
                                             join_type_invalid_right = 2
                                             join_type_invalid_side  = 2
                                             join_type_invalid_twice = 2
                                             join_type_inconsistent  = 3
                                             tab_not_found           = 4
                                             field_not_found         = 4
                                             fields_invalid          = 5 ).
              if sy-subrc = 2.
                raise join_addition_invalid.
              endif.
              if sy-subrc = 3.
                force_jointype( exporting  i_change_old = aqqis_c_false
                                changing   cs_join      = ls_join
                                exceptions inconsistent = 1 ).
                test_join_validity( exporting  is_join                 = ls_join
                                    exceptions join_type_invalid_left  = 2
                                               join_type_invalid_right = 2
                                               join_type_invalid_side  = 2
                                               join_type_invalid_twice = 2 ).
                if sy-subrc <> 0.
                  raise join_addition_invalid.
                endif.
              endif.
              if sy-subrc = 5.
                continue.
              endif.

              append: ls_join to lt_join,
                      ls_join to pt_join.
              l_join_found = aqqis_c_true.
              ls_headsg-state = aqqis_c_changed-updated.
              propose_on_condition_add_link( exporting is_join = ls_join ).
            endif.
          endif.
        endif.
      endif.
    endloop.
  endloop.

  if l_join_found = aqqis_c_false.
    read table lt_join with key tabnamer = i_tabnamer
                                tabnamel = i_tabnamel
                                transporting no fields.
    if sy-subrc = 0.
      raise no_further_joins_found.
    endif.

    read table lt_join with key tabnamer = i_tabnamel
                                tabnamel = i_tabnamer
                                transporting no fields.
    if sy-subrc = 0.
      raise no_further_joins_found.
    endif.

    raise no_joins_found.
  endif.

  p_join_data_r->set_info( exporting i_headsg = ls_headsg ).
  cnvt_table_to_old( ).

endmethod.                    "PROPOSE_ON_CONDITION


method PROPOSE_ON_CONDITION_ADD_LINK .

  data: l_tabix_l    type sytabix,
        l_tabix_r    type sytabix.

  field-symbols: <tobj_join_l> type AQSTOBJJOI,
                 <tobj_join_r> type AQSTOBJJOI,
                 <fobj_join_l> type AQSFOBJJOI,
                 <fobj_join_r> type AQSFOBJJOI.

  read table p_t_tobj_join assigning <tobj_join_l> with key tname = is_join-tabnamel.
  read table <tobj_join_l>-fobj assigning <fobj_join_l> with key fname = is_join-colnamel.
  l_tabix_l = sy-tabix.
  read table p_t_tobj_join assigning <tobj_join_r> with key tname = is_join-tabnamer.
  read table <tobj_join_r>-fobj assigning <fobj_join_r> with key fname = is_join-colnamer.
  l_tabix_r = sy-tabix.
  CREATE_LINK( EXPORTING IR_TABL = <tobj_join_l>-tabref
                         IR_TABR = <tobj_join_r>-tabref
                         I_ROWL  = l_tabix_l
                         I_ROWR  = l_tabix_r ).
endmethod.


method RECREATE_LINKS .

  data: ls_join  type aqq_s_join,
        l_fnamel type aqs_fname,
        l_fnamer type aqs_fname,
        l_text   type aqq_text.

  field-symbols: <links_join> type AQSLINKJOI.

* Links
  loop at pt_join into ls_join.
    case ls_join-type.
      when aqqis_c_join_typ-inner.
      when aqqis_c_join_typ-left_outer.
        l_text = text-013.  "left outer join
      when others.
    endcase.

    concatenate ls_join-tabnamel '-' ls_join-colnamel into l_fnamel.
    concatenate ls_join-tabnamer '-' ls_join-colnamer into l_fnamer.
    read table p_t_links_join assigning <links_join> with key fnameleft  = l_fnamel
                                                              fnameright = l_fnamer.
    <links_join>-linkref->set_properties( i_linkstyle = p_default_linkstyle
                                          i_text      = l_text ).
    p_r_join_cntrl->add_link( i_r_link = <links_join>-linkref ).
  endloop.
  p_r_join_cntrl->send_data_to_frontend( ).
endmethod.                    "RECREATE_LINKS


method REDUCE_DISTANCE .

  data: lt_tpos     type aqq_t_tpos,
        l_tabwidth  type i,
        l_tabheight type i,
        l_tabix     type sytabix,
        l_x1        type int4,
        l_x2        type int4,
        l_y1        type int4,
        l_y2        type int4,
        l_distx     type int4,
        l_disty     type int4.

  field-symbols: <tpos1> type aqq_s_tpos,
                 <tpos2> type aqq_s_tpos.

  l_tabwidth  = '400'.
  l_tabheight = '100'.

  lt_tpos[]   = pt_tpos[].

* x-Richtung
  sort lt_tpos by xpos.
  read table lt_tpos assigning <tpos1> index 1.
  check sy-subrc = 0.
  if <tpos1>-xpos > 100.
    l_distx = <tpos1>-xpos - 50.
    loop at lt_tpos assigning <tpos1>.
      <tpos1>-xpos = <tpos1>-xpos - l_distx.
    endloop.
  endif.

  loop at lt_tpos assigning <tpos1>.
    l_tabix = sy-tabix + 1.
    read table lt_tpos assigning <tpos2> index l_tabix.
    if sy-subrc ne 0.
      exit.
    endif.

    do.
      l_x1       = <tpos1>-xpos + l_tabwidth + 50.
      l_x2       = <tpos2>-xpos - 100.
      if l_x2 < l_x1.
        exit.
      endif.
      <tpos2>-xpos = <tpos2>-xpos - 100.
    enddo.
  endloop.

* y-Richtung
  sort lt_tpos by ypos.
  read table lt_tpos assigning <tpos1> index 1.
  check sy-subrc = 0.
  if <tpos1>-ypos > 100.
    l_disty = <tpos1>-ypos - 50.
    loop at lt_tpos assigning <tpos1>.
      <tpos1>-ypos = <tpos1>-ypos - l_disty.
    endloop.
  endif.

  loop at lt_tpos assigning <tpos1>.
    l_tabix = sy-tabix + 1.
    read table lt_tpos assigning <tpos2> index l_tabix.
    if sy-subrc ne 0.
      exit.
    endif.

    do.
      l_y1       = <tpos1>-ypos + l_tabheight + 50.
      l_y2       = <tpos2>-ypos - 100.
      if l_y2 < l_y1.
        exit.
      endif.
      <tpos2>-ypos = <tpos2>-ypos - 100.
    enddo.
  endloop.

  pt_tpos[] = lt_tpos[].

  cnvt_table_to_old( ).
endmethod.                    "REDUCE_DISTANCE


method REFERENZFIELD .

  data:   l_feldname type AQS_FNAME,
          l_refname  type aqs_fname,
          ls_exdbfi  type AQSEXDBFI,
          lt_exdbfi  type aqq_t_exdbfi.

  CALL FUNCTION 'RSAQ_CNTRL_BUILD_EXDBFI'
    EXPORTING
      I_TAB     = i_tname
    IMPORTING
      et_exdbfi = lt_exdbfi.

  read table lt_exdbfi into ls_exdbfi with key DDIC-FIELDNAME = is_tab-feld.

  IF ls_exdbfi-info-curry = 'F' OR ls_exdbfi-info-curry = 'M'.
    CONCATENATE ls_exdbfi-ddic-reftable '-' ls_exdbfi-ddic-reffield
                INTO l_refname.
*   Referenzfeld: &1
    message i027(aqqis_cntrl) with l_refname.
  ELSE.
    CONCATENATE ls_exdbfi-ddic-tabname '-' ls_exdbfi-ddic-fieldname
                INTO l_feldname.
*   &1 besitzt kein Referenzfeld
    message i028(aqqis_cntrl) with l_feldname.
  ENDIF.
endmethod.


method REL_2_ABS .

  data: ls_tobj_join type AQSTOBJJOI.

  read table p_t_tobj_join into ls_tobj_join with key tname = is_dbjt-table.

*--- abs
  es_tpos_abs-TNAME     = is_dbjt-table.
  es_tpos_abs-R_TABLE   = ls_tobj_join-tabref.
*  es_tpos_abs-LEFTPOS   = is_dbjt-left.
*  es_tpos_abs-TOPPOS    = is_dbjt-top.
*  es_tpos_abs-RIGHTPOS  = is_dbjt-left + is_dbjt-width.
*  es_tpos_abs-BOTTOMPOS = is_dbjt-top + is_dbjt-height.
  es_tpos_abs-LEFTPOS   = is_dbjt-left_vz.
  es_tpos_abs-TOPPOS    = is_dbjt-top_vz.
  es_tpos_abs-RIGHTPOS  = is_dbjt-left_vz + is_dbjt-width_vz.
  es_tpos_abs-BOTTOMPOS = is_dbjt-top_vz + is_dbjt-height_vz.

endmethod.                                                  "REL_2_ABS


method REMOVE_LINK .

  data: l_s_link type AQSLINKJOI,
        l_index  type sytabix,
        lt_join  type aqq_t_join,
        l_tnamel type aqs_tname,
        l_tnamer type aqs_tname,
        l_fnamel type aqs_fname,
        l_fnamer type aqs_fname.

* removes a link from control and iset
  if P_MODE = aqqis_c_mode-display.
*   Funktion nur im Änderungsmodus unterstützt
    if not r_doit is initial.
      r_doit->o_ok = aqqis_c_false.
    endif.
    message s005(aqqis_cntrl).
    exit.
  endif.

  lt_join[] = pt_join[].

* setzen Änderungsflag
  SET_CHANGED( EXPORTING I_CHANGED = aqqis_c_changed-updated ).

  check not ir_link is initial.

  read table p_t_links_join with key linkref = ir_link into l_s_link.
  if sy-subrc = 0.
    l_index = sy-tabix.

*   delete from control
    p_r_join_cntrl->delete_objects( exporting i_r_link  = ir_link ).
    delete p_t_links_join index l_index.

    cnvt_fname_one_2_two( exporting i_fname = l_s_link-FNAMELEFT
                          importing e_tname = l_tnamel
                                    e_fname = l_fnamel ).

    cnvt_fname_one_2_two( exporting i_fname = l_s_link-FNAMEright
                          importing e_tname = l_tnamer
                                    e_fname = l_fnamer ).

* Datentabelle
    DELETE TABLE lt_JOIN WITH TABLE KEY TABNAMEL = l_tnamel
                                        TABNAMER = l_tnamer
                                        COLNAMEL = l_fnamel
                                        COLNAMER = l_fnamer.

    DELETE TABLE lt_JOIN WITH TABLE KEY TABNAMEL = l_tnamel
                                        TABNAMER = l_tnamer
                                        COLNAMEL = l_fnamel
                                        COLNAMER = l_fnamer.
  endif.

  pt_join[] = lt_join[].
  CNVT_TABLE_TO_OLD( ).

endmethod.                    "REMOVE_LINK


method REMOVE_TOBJECT .

  data: l_t_objects   type aqq_t_objects,
        l_lin_objects type i,
        lt_del_links  type aqq_t_links,
        ls_link       type aqslinks,
        lt_dban       type aqtdban,
        lt_dbsg       type aqtdbsg.

  field-symbols: <objects>   type AQSOBJECTS,
                 <tobj_join> type AQSTOBJJOI,
                 <link>      type AQSLINKJOI.

  if P_MODE = aqqis_c_mode-display.
*   Funktion nur im Änderungsmodus unterstützt
    message s005(aqqis_cntrl).
    exit.
  endif.

  l_t_objects = p_r_join_cntrl->get_selected_objects( ).
  loop at l_t_objects transporting no fields where not r_table is initial
                                             and   rowindex = 0.
    l_lin_objects = l_lin_objects + 1.
  endloop.

  if l_lin_objects = 0.
*   Kein Objekt markiert.
    message s006(aqqis_cntrl).
    exit.
  elseif l_lin_objects > 1.
*   Mehrere Objekte markiert
    message s007(aqqis_cntrl).
    exit.
  endif.

  read table l_t_objects assigning <objects> index 1.
  read table p_t_tobj_join assigning <tobj_join> with key tabref = <objects>-R_TABLE.
  if sy-subrc ne 0.
*   fatal error
    message a008(aqqis_cntrl) with 'CL_QUERY_JOIN_CNTRL' 'REMOVE_TOBJECT'.
  endif.

  check_remove_tobject( exporting  i_tname                = <tobj_join>-tname
                        exceptions only_one_table         = 1
                                   TABLE_IS_USED          = 2
                                   NO_REMOVE_IN_QUICKVIEW = 3 ).
  if     sy-subrc = 1.
*   Es dürfen nicht alle Tabellen gelöscht werden
    message s009(aqqis_cntrl).
    exit.
  elseif sy-subrc = 2.
*   Tabelle &1 wird noch verwendet
    message s010(aqqis_cntrl) with <tobj_join>-tname.
    exit.
  elseif sy-subrc = 3.
*   Tabellen des Joins können im QuickViewer nicht mehr gelöscht werden
    message s011(aqqis_cntrl).
    exit.
  endif.

  SET_CHANGED( EXPORTING I_CHANGED = aqqis_c_changed-updated ).

* Löschen Datentabellen
*   beim Löschen müssen folgende Tabellen berücksichtigt werden
*   dbjt   - verwendete Tabellen
*   dbsg   - Struktur logische DB -> Baum
*            Join                 -> alle Jointabellen
*            HR-DB                -> Infotypen
*            wird parallel zur dbjt gehalten
*   dbsf   - Felder aus Sachgebiet
*            hier muß geprüft werden, ob noch Felder verwendet werden
*            falls ja, wird das Löschen abgelehnt
*            wird in cl_query_join_cntrl geprüft
*   dban   - Aliasnamen, also ggf.
*   dbjc   - Tabellen-Join-Bedingung

  DELETE pt_JOIN   WHERE TABNAMEL = <tobj_join>-tname.
  DELETE pt_JOIN   WHERE TABNAMER = <tobj_join>-tname.
  DELETE pt_TPOS   WHERE TABNAME  = <tobj_join>-tname.
  DELETE pt_TFIELD WHERE TABNAME  = <tobj_join>-tname.
  p_join_data_r->get_info( importing et_dban = lt_dban
                                     et_dbsg = lt_dbsg ).
  loop at lt_dbsg transporting no fields where name = <tobj_join>-tname.
    delete lt_dbsg index sy-tabix.
  endloop.
* Löschen Alias-Beziehung
*  loop at lt_dban transporting no fields where alias = <tobj_join>-tname.
*    delete lt_dban index sy-tabix.
*  endloop.
  p_join_data_r->set_info( exporting it_dban = lt_dban
                                     it_dbsg = lt_dbsg ).

* Löschen Frontend-Komponenten
  loop at p_t_links_join assigning <link> where tnameleft  = <tobj_join>-tname
                                             or tnameright = <tobj_join>-tname.
    ls_link-r_link = <link>-linkref .
    append ls_link to lt_del_links.
  endloop.

  p_r_join_cntrl->delete_objects( exporting i_r_table  = <tobj_join>-tabref ).
  p_r_join_cntrl->delete_objects( exporting i_t_link   = lt_del_links ).

  delete p_t_links_join where TNAMELEFT  = <tobj_join>-tname.
  delete p_t_links_join where tnameright = <tobj_join>-tname.
  delete p_t_tobj_join  where tabref      = <objects>-r_table.

  CNVT_TABLE_TO_OLD( ).

endmethod.                    "REMOVE_TOBJECT


method REORDER_JOINS .
* user wants to fix table positions at new positions,
* we reorder all the joins, check for (now) illegal jointypes,
* correct them and rebuild joins at the frontend.
* if we are operationg on a functional area,
* we also check that the FIRST table has not switched order.

* the following statements are currently not implemented by the ABAP
* SQL interface:
*
* I)        T1 ----LO------T2              r.h.s. table can be
*                          T2                     linked to only one
*                T3---LO---T2                     table to left
*                                                 via LO join.
*
* II)    T1---LO---T2---LO---T3            r.h.s. table of a LO join
*                                                 cannot be l.h.s table
*                                                 of another l.o. join.

  data: ls_first_tpos type        aqq_s_tpos,
        ls_tpos_new   type        aqq_s_tpos,     "note 1639058
        lt_save_tpos  type        aqq_t_tpos,
        lt_tpos       type        aqq_t_tpos,
        lt_join       type        aqq_t_join,
        ls_join       type        aqq_s_join,
        l_p           type        int4,
        l_l           type        int4,
        l_r           type        int4,
        l_wa_join2    type        aqq_s_join.

  lt_save_tpos[] = it_tpos_old[].
  lt_tpos[]      = it_tpos_new[].
  lt_join[]      = pt_join[].

  sort lt_save_tpos by xpos.
  read table lt_save_tpos into ls_first_tpos index 1.

  sort lt_tpos by xpos.
  "<<< note 1639058
  read table lt_tpos into ls_tpos_new index 1.

  if ls_first_tpos-tabname ne ls_tpos_new-tabname.
    "<<< note 2114455
    message e535(aq) raising reorder_invalid.
    ">>> note 2114455
  endif.
  ">>> note 1639058

  loop at lt_join into ls_join.
    l_p = sy-tabix.
    read table lt_tpos with key tabname = ls_join-tabnamel
                                transporting no fields.
    l_l = sy-tabix.
    read table lt_tpos with key tabname = ls_join-tabnamer
                                transporting no fields.
    l_r = sy-tabix.
    if ( l_l > l_r ).      " join has to be reversed.
      l_wa_join2       = ls_join.
      ls_join-tabnamer = l_wa_join2-tabnamel.
      ls_join-tabnamel = l_wa_join2-tabnamer.
      ls_join-colnamer = l_wa_join2-colnamel.
      ls_join-colnamel = l_wa_join2-colnamer.
      modify lt_join from ls_join index l_p.
    endif.
  endloop.

* by rearranging tables, the user might have created an
* illegal join-situation II): * T1--LO1--T2--LO---T3
*                                (join)    (wa_join2)
*
* all these joins (wa-join2) are reset to inner joins.
  data: l_forced type flag.

  l_forced = aqqis_c_false.

  sort lt_join by tabnamel tabnamer.
  loop at lt_join into ls_join where type = aqqis_c_join_typ-left_outer.
    loop at lt_join into l_wa_join2 where tabnamel = ls_join-tabnamer
                                      and type     = aqqis_c_join_typ-left_outer.
      l_wa_join2-type = aqqis_c_join_typ-inner.
      modify lt_join from l_wa_join2 index sy-tabix.
      l_forced = aqqis_c_true.
    endloop.
  endloop.

* he might have created inconsistent joins.
* these are corrected here.
  data: l_ok type flag.

  loop at lt_join into ls_join where type = aqqis_c_join_typ-left_outer.
*   recheck this, since state is changed in loop!
    read table lt_join with key tabnamel = ls_join-tabnamer
                                type     = aqqis_c_join_typ-left_outer
                                transporting no fields.
    if sy-subrc <> 0.
      l_ok = aqqis_c_true.
      loop at lt_join into l_wa_join2 where tabnamer = ls_join-tabnamer
                                        and type     = aqqis_c_join_typ-inner.
*       (normal joins leading into this table.)
        read table lt_join with key tabnamer = l_wa_join2-tabnamel
                                    type     = aqqis_c_join_typ-left_outer
                                    transporting no fields.
        if sy-subrc = 0.          " one of these is right table of other
          l_ok = aqqis_c_false.   " left outer join!
        endif.
      endloop.

      if l_ok = aqqis_c_true.     " we can change all these ...
        loop at lt_join into l_wa_join2 where tabnamer = ls_join-tabnamer
                                          and type     = aqqis_c_join_typ-inner.
          l_wa_join2-type = aqqis_c_join_typ-left_outer.
          modify lt_join from l_wa_join2 index sy-tabix.
          l_forced = aqqis_c_true.
        endloop.
      else.
        ls_join-type = aqqis_c_join_typ-inner.
        modify pt_join from ls_join.    "#EC *
        l_forced = aqqis_c_true.
      endif.
    else.
      ls_join-type = aqqis_c_join_typ-inner.
      modify pt_join from ls_join.      "#EC *
      l_forced = aqqis_c_true.
    endif.
  endloop.

* now we check for illegal join situation 1:
* e.g. T1--T2 was reset to inner join by above procedure:
* i.e.
*               T1 ---(join)------------ T2
*                                        T2
*                    T3------LO----------T2
*                        (wa_join2)
* These joins (wa_join2)  MUST be reset to inner joins too.
*
  loop at lt_join into ls_join where type = aqqis_c_join_typ-inner.
    loop at lt_join into l_wa_join2 where tabnamer = ls_join-tabnamer.
      if l_wa_join2-type = aqqis_c_join_typ-left_outer.
        l_wa_join2-type = aqqis_c_join_typ-inner.
        modify lt_join from l_wa_join2.
        l_forced = aqqis_c_true.
      endif.
    endloop.
  endloop.

  data: l_index type i.
  loop at lt_join into ls_join where type = aqqis_c_join_typ-left_outer.
    l_index = sy-tabix.
    loop at lt_join into l_wa_join2 where tabnamer = ls_join-tabnamer.
      if l_wa_join2-tabnamel <> ls_join-tabnamel.
        l_wa_join2-type = aqqis_c_join_typ-inner.
        ls_join-type = aqqis_c_join_typ-inner.
        modify lt_join from l_wa_join2.
        modify lt_join from ls_join index l_index.
        l_forced = aqqis_c_true.
      endif.
    endloop.
  endloop.

  if l_forced = aqqis_c_true.
*   Beachten Sie die Änderung von Join-Typen
    message i017(aqqis_cntrl).
  endif.
  e_forced = l_forced.

  pt_join[] = lt_join[].

endmethod.                    "REORDER_JOINS


method SAVE_AS_JPG .

  data:   l_filename           type rlgrap-filename,
          l_file               type string,
          l_path               type string,
          l_fullpath           type string,
          l_useraction         type i.

  call method cl_gui_frontend_services=>file_save_dialog
    exporting
*         WINDOW_TITLE         =
      default_extension    = 'jpg'
*         DEFAULT_FILE_NAME    =
      file_filter          = '*.jpg'
*         INITIAL_DIRECTORY    =
    changing
      filename             = l_file
      path                 = l_path
      fullpath             = l_fullpath
      user_action          = l_useraction
    exceptions
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      others               = 4.

  if sy-subrc = 0.

    if l_useraction = 0.
      l_filename = l_fullpath.

      p_r_join_cntrl->save_as_jpg( exporting i_filename = l_filename ).
*     Die Datei &1 wurde erfolgreich gesichert
      message s018(aqqis_cntrl) with l_fullpath.
    elseif l_useraction = 9.
*     Aktion abgebrochen
      message s001(aqqis_cntrl).
    endif.

  else.
*   interner Fehler beim Erzeugen einer jpg-Datei aufgetreten
    message s019(aqqis_cntrl).
  endif.

endmethod.                    "SAVE_AS_JPG


method SCALE .

  data: l_scalex       type i,
        l_scaley       type i,
        l_x1           type i,                "von der ersten Tabelle x-Position (links)
        l_y1           type i,                "von der ersten Tabelle y-Position (top)
                                              "die neuen Positionen aller weiteren Tabellen (ab sy-tabix 2)
                                              "werden relative zur ersten berechnet
        l_tabix        type sy-tabix,
        ls_tobj_join   type AQSTOBJJOI,
        lt_tobj_join   type aqq_t_tobj_join,
        lt_dbjt        type aqtdbjt,
        lt_tpos        type aqq_t_tpos,
        lt_links_join  type aqq_t_links_join,
        lt_join        type aqq_t_join.

  field-symbols: <tobj_join>  type AQSTOBJJOI,
                 <links_join> type AQSLINKJOI,
                 <tpos>       type aqq_s_tpos,
                 <dbjt>       type aqdbjt.

*break rueger.
*--- besorgen der Skalierungsfaktoren -> Popup
  SKALIERUNG_POPUP( IMPORTING  E_SCALEX  = l_scalex
                               E_SCALEY  = l_scaley
                    EXCEPTIONS CANCELLED = 1 ).
  if sy-subrc ne 0.
*   Aktion abgebrochen
    message s001(aqqis_cntrl).
    exit.
  endif.

* setzen Änderungsflag
  SET_CHANGED( EXPORTING I_CHANGED = aqqis_c_changed-updated ).

  lt_tpos[] = pt_tpos[].

* Positionen tpos, dbjt
  loop at lt_tpos assigning <tpos>.
    l_tabix = sy-tabix.

    if l_tabix = 1.
      l_x1 = <tpos>-xpos.
      l_y1 = <tpos>-ypos.
    else.

* Skalierungsfaktor berücksichtigen
      <tpos>-ypos = ( ( <tpos>-ypos - l_y1 ) * l_scaley / 100 ) + l_y1.
      <tpos>-xpos = ( ( <tpos>-xpos - l_x1 ) * l_scalex / 100 ) + l_x1.
    endif.
  endloop.
  pt_tpos[] = lt_tpos[].
  CNVT_TABLE_TO_OLD_dbjt( ).


  p_join_data_r->get_info( importing et_dbjt = lt_dbjt ).
  loop at lt_dbjt assigning <dbjt>.
* Tabelle löschen
    read table p_t_tobj_join assigning <tobj_join> with key tname = <dbjt>-table.
    check sy-subrc = 0.
    l_tabix = sy-tabix.
    p_r_join_cntrl->delete_objects( i_r_table = <tobj_join>-tabref ).

* Tabelle neu aufbauen
    clear: ls_tobj_join.
    FILL_TABLE_FIELDS( EXPORTING IS_DBJT       = <dbjt>
                       IMPORTING ES_TOBJ_JOIN  = ls_tobj_join ).

    append ls_tobj_join to lt_tobj_join.
    modify p_t_tobj_join from ls_tobj_join index l_tabix.
  endloop.

*--- Tabellen an das Control senden
  send_tables_to_cntrl( exporting i_t_tobj_join = lt_tobj_join ).

*--- alle links löschen
  lt_links_join[] = p_t_links_join[].
  lt_join[]       = pt_join[].
  loop at lt_links_join assigning <links_join>.
    REMOVE_LINK( EXPORTING IR_LINK = <links_join>-linkref ).
  endloop.
*--- Links anlegen
  pt_join[] = lt_join[].
  create_links( pt_join ).

*--- alles an die Oberfläche senden
  p_r_join_cntrl->send_data_to_frontend( ).

  CNVT_TABLE_TO_OLD_dbjc( ).
endmethod.                    "SCALE


method SEARCH .
  data: l_t_objects   type aqq_t_objects,
        l_lin_objects type i,
        lt_tab        type aqq_t_tab,
        l_tname       type aqs_tname,
        l_row         type sytabix,
        l_found       type boolean,
        l_s_tobj_join type aqstobjjoi.

  field-symbols: <objects>   type aqsobjects,
                 <tobj_join> type aqstobjjoi.

*--- selektierte Objekte holen und prüfen, ob genau ein Objekt markiert ist
  l_t_objects = p_r_join_cntrl->get_selected_objects( ).

  loop at l_t_objects transporting no fields where not r_table  is initial
                                             and       rowindex is initial.
    l_lin_objects = l_lin_objects + 1.
  endloop.

  if l_lin_objects > 1.
*   Mehrere Objekte markiert
    message s007(aqqis_cntrl).
    exit.
  elseif l_lin_objects = 0.
*   Kein Objekt markiert.
    message s006(aqqis_cntrl).
    exit.
  endif.

  read table l_t_objects assigning <objects> index 1.
  read table p_t_tobj_join assigning <tobj_join> with key tabref = <objects>-r_table.
  get_tab( exporting i_tabname = <tobj_join>-tname
           importing et_tab    = lt_tab ).

*--- Suchpopup
  l_tname = <tobj_join>-tname.
  call function 'RSAQ_CNTRL_SEARCH_0400'
    exporting
      i_tname   = l_tname
    importing
      es_search = ps_search
    exceptions
      not_found = 1
      cancelled = 2
      others    = 3.

  if sy-subrc <> 0.
*   Aktion abgebrochen
    message s001(aqqis_cntrl).
    exit.
  endif.

* globale Variable setzen
  p_start_tabix = 1.
  p_search_obj  = <objects>-r_table.

  search_in_tabobj( exporting is_search     = ps_search
                              it_tab        = lt_tab          "Felder der markierten Tabelle
                              i_start_tabix = p_start_tabix
                              i_tname       = l_tname
                    importing e_found       = l_found
                              e_row         = l_row
                              es_tobj_join  = l_s_tobj_join ).

  if     l_found = aqqis_c_true.
*   Treffer - Zeile: &1
*   todo
    message s023(aqqis_cntrl) with l_row.
    <objects>-rowindex = l_row.
    p_r_join_cntrl->set_selected_objects( l_t_objects ).
  elseif l_found = aqqis_c_false.
*   Suchbegriff wurde nicht gefunden
    message s024(aqqis_cntrl).
    exit.
  endif.

endmethod.                    "SEARCH


method SEARCH_DOMAIN_IN_TABOBJ .

  data: l_found     type flag,
        l_tabix     type sytabix,
        l_tabix_end type sytabix.

  field-symbols: <tab>       type aqq_s_tab,
                 <tobj_join> type AQSTOBJJOI.

  l_found = aqqis_c_false.

  loop at it_tab assigning <tab> from i_start_tabix.
    l_tabix       = sy-tabix.
    p_start_tabix = l_tabix + 1.

    if <tab>-dom cs is_search-SEARCHDOM.

      l_found       = aqqis_c_true.

      read table p_t_tobj_join assigning <tobj_join> with key tname = i_tname.
      read table <tobj_join>-fobj transporting no fields with key fname = <tab>-feld.

      e_row        = sy-tabix.
      es_tobj_join = <tobj_join>.
      exit.
    endif.
  endloop.

  if l_found = aqqis_c_false and i_start_tabix > 1.
    l_tabix_end = i_start_tabix - 1.
    loop at it_tab assigning <tab> from 1 to l_tabix_end.
      l_tabix       = sy-tabix.
      p_start_tabix = l_tabix + 1.

      if <tab>-dom cs is_search-SEARCHDOM.

        l_found       = aqqis_c_true.

        read table p_t_tobj_join assigning <tobj_join> with key tname = i_tname.
        read table <tobj_join>-fobj transporting no fields with key fname = <tab>-feld.

        e_row        = sy-tabix.
        es_tobj_join = <tobj_join>.
        exit.
      endif.
    endloop.
  endif.

  e_found = l_found.
endmethod.


method SEARCH_IN_TABOBJ .

  CASE IS_SEARCH-ART.
    WHEN aqqis_c_search-text.
      SEARCH_TEXT_IN_TABOBJ( exporting is_search     = is_search
                                       it_tab        = it_tab
                                       i_start_tabix = i_start_tabix
                                       i_tname       = i_tname
                             importing e_found       = e_found
                                       e_row         = e_row
                                       es_tobj_join  = es_tobj_join ).

    WHEN aqqis_c_search-domain.
      SEARCH_DOMAIN_IN_TABOBJ( exporting is_search     = is_search
                                         it_tab        = it_tab
                                         i_start_tabix = i_start_tabix
                                         i_tname       = i_tname
                               importing e_found       = e_found
                                         e_row         = e_row
                                         es_tobj_join  = es_tobj_join ).
    WHEN aqqis_c_search-stype.
      SEARCH_TYPE_IN_TABOBJ( exporting is_search     = is_search
                                       it_tab        = it_tab
                                       i_start_tabix = i_start_tabix
                                       i_tname       = i_tname
                             importing e_found       = e_found
                                       e_row         = e_row
                                       es_tobj_join  = es_tobj_join ).
  ENDCASE.

endmethod.


method SEARCH_NEXT .

  data: lt_tab         type aqq_t_tab,
        ls_tobj_join   type AQSTOBJJOI,
        lt_objects     type aqq_t_objects,
        lt_objects_sel type aqq_t_objects,
        l_row          type sytabix,
        l_found        type boolean,
        l_lin_objects  type i,
        l_lin_tab      type i.

  field-symbols: <tobj_join> type AQSTOBJJOI,
                 <objects>   type AQSOBJECTS.

  if p_search_obj is initial.
*   Es sind keine Suchbegriffe vorhanden
    message s025(aqqis_cntrl).
    exit.
  endif.

*--- selektierte Objekte holen und prüfen, ob genau ein Objekt markiert ist
  lt_objects = p_r_join_cntrl->get_selected_objects( ).

  loop at lt_objects assigning <objects> where not r_table  is initial
                                         and       rowindex is initial.
    l_lin_objects = l_lin_objects + 1.
    append <objects> to lt_objects_sel.
  endloop.
  p_r_join_cntrl->set_selected_objects( lt_objects_sel ).

  if l_lin_objects > 1.
*   Mehrere Objekte markiert
    message s007(aqqis_cntrl).
    exit.
  elseif l_lin_objects = 0.
*   Kein Objekt markiert
    message s006(aqqis_cntrl).
    exit.
  endif.

  read table lt_objects assigning <objects> index 1.
  read table p_t_tobj_join assigning <tobj_join> with key tabref = p_search_obj.
  if <objects>-r_table ne p_search_obj.
*   Tabelle &1 ist nicht markiert
    message s026(aqqis_cntrl) with <tobj_join>-tname.
    exit.
  endif.

  GET_TAB( EXPORTING I_TABNAME = <tobj_join>-tname
           IMPORTING ET_TAB    = lt_tab ).

*--- wenn mit der Suche am Ende der Tabelle angekommen, wieder von vorne beginnen
  describe table lt_tab lines l_lin_tab.
  if l_lin_tab < p_start_tabix.
    p_start_tabix = 1.
  endif.

  SEARCH_IN_TABOBJ( exporting is_search     = ps_search
                              it_tab        = lt_tab         "Felder der markierten Tabelle
                              i_start_tabix = p_start_tabix
                              i_tname       = <tobj_join>-tname
                    importing e_found       = l_found
                              e_row         = l_row
                              es_tobj_join  = ls_tobj_join ).

  if     l_found = aqqis_c_true.
*   Treffer - Zeile: &1
    message s023(aqqis_cntrl) with l_row.
    <objects>-rowindex = l_row.
    p_r_join_cntrl->set_selected_objects( lt_objects ).
  elseif l_found = aqqis_c_false.
*   Suchbegriff wurde nicht gefunden
    message s024(aqqis_cntrl).
    exit.
  endif.

endmethod.


method SEARCH_TEXT_IN_TABOBJ .

  data: l_found     type flag,
        l_tabix     type sytabix,
        l_tabix_end type sytabix.

  field-symbols: <tab>       type aqq_s_tab,
                 <tobj_join> type AQSTOBJJOI.

  l_found = aqqis_c_false.

  loop at it_tab assigning <tab> from i_start_tabix.
    l_tabix = sy-tabix.
    p_start_tabix = l_tabix + 1.

    if <tab>-feld  cs is_search-SEARCHTEXT or
       <tab>-ftext cs is_search-SEARCHTEXT.

      l_found       = aqqis_c_true.

      read table p_t_tobj_join assigning <tobj_join> with key tname = i_tname.
      read table <tobj_join>-fobj transporting no fields with key fname = <tab>-feld.

      e_row        = sy-tabix.
      es_tobj_join = <tobj_join>.
      exit.
    endif.
  endloop.

  if l_found = aqqis_c_false and i_start_tabix > 1.
    l_tabix_end = i_start_tabix - 1.
    loop at it_tab assigning <tab> from 1 to l_tabix_end.
      l_tabix       = sy-tabix.
      p_start_tabix = l_tabix + 1.

      if <tab>-feld  cs is_search-SEARCHTEXT or
         <tab>-ftext cs is_search-SEARCHTEXT.

        l_found       = aqqis_c_true.

        read table p_t_tobj_join assigning <tobj_join> with key tname = i_tname.
        read table <tobj_join>-fobj transporting no fields with key fname = <tab>-feld.

        e_row        = sy-tabix.
        es_tobj_join = <tobj_join>.
        exit.
      endif.
    endloop.
  endif.
  e_found = l_found.

endmethod.


method SEARCH_TYPE_IN_TABOBJ .

  data: l_found     type flag,
        l_tabix     type sytabix,
        l_tabix_end type sytabix.

  field-symbols: <tab>       type aqq_s_tab,
                 <tobj_join> type AQSTOBJJOI.

  l_found = aqqis_c_false.

  loop at it_tab assigning <tab> from i_start_tabix.
    l_tabix       = sy-tabix.
    p_start_tabix = l_tabix + 1.

    if <tab>-dtype cs is_search-searchtype.
      l_found = aqqis_c_true.

      if is_search-cleng is initial.
      else.
        if not <tab>-dleng = is_search-cleng.
          l_found = aqqis_c_false.
        endif.
      endif.

      if is_search-decnumb is initial.
      else.
        if not <tab>-ddec = is_search-decnumb.
          l_found = aqqis_c_false.
        endif.
      endif.
    endif.

    if l_found = aqqis_c_true.
      read table p_t_tobj_join assigning <tobj_join> with key tname = i_tname.
      read table <tobj_join>-fobj transporting no fields with key fname = <tab>-feld.

      e_row        = sy-tabix.
      es_tobj_join = <tobj_join>.
      exit.
    endif.
  endloop.

  if l_found = aqqis_c_false and i_start_tabix > 1.
    l_tabix_end = i_start_tabix - 1.

    loop at it_tab assigning <tab> from 1 to l_tabix_end.
      l_tabix       = sy-tabix.
      p_start_tabix = l_tabix + 1.

      if <tab>-dtype cs is_search-searchtype.
        l_found = aqqis_c_true.

        if is_search-cleng is initial.
        else.
          if not <tab>-dleng = is_search-cleng.
            l_found = aqqis_c_false.
          endif.
        endif.

        if is_search-decnumb is initial.
        else.
          if not <tab>-ddec = is_search-decnumb.
            l_found = aqqis_c_false.
          endif.
        endif.
      endif.

      if l_found = aqqis_c_true.
        read table p_t_tobj_join assigning <tobj_join> with key tname = i_tname.
        read table <tobj_join>-fobj transporting no fields with key fname = <tab>-feld.

        e_row        = sy-tabix.
        es_tobj_join = <tobj_join>.
        exit.
      endif.
    endloop.
  endif.

  e_found = l_found.
endmethod.


method SEND_TABLES_TO_CNTRL .

  data: l_title      type        aqq_title,
        l_tooltip    type        aqtooltip,
        lt_tobj_join type        aqq_t_tobj_join.

  field-symbols: <tobj_join> type AQSTOBJJOI.

  lt_tobj_join = i_t_tobj_join.
  loop at lt_tobj_join assigning <tobj_join>.

    <tobj_join>-tabref->set_tabledata( exporting i_t_table = <tobj_join>-fobj ) .

    <tobj_join>-tabref->set_table_properties( exporting  i_title           = <tobj_join>-title
                                                         i_tooltip         = <tobj_join>-tooltip
                                                         i_level           = <tobj_join>-objlevel
                                                         i_linecolor       = aqqis_c_defval-linecolor
                                                         i_scrollbarcolor  = aqqis_c_defval-scrollbarcolor
                                                         i_s_position      = <tobj_join>-tpos ).

    <tobj_join>-tabref->set_table_attributes( exporting i_moveable            = aqqis_c_true
                                                        i_resizeable          = aqqis_c_true
                                                        i_autoarranging       = aqqis_c_false
                                                        i_tableconnectable    = aqqis_c_false
                                                        i_allrowsconnectable  = aqqis_c_true
                                                        i_dragdroprows        = aqqis_c_false
                                                        i_selectablerows      = aqqis_c_true
                                                        i_multiselectablerows = aqqis_c_false
                                                        i_tooltip             = aqqis_c_false
                                                        i_vscrollbar          = aqqis_c_true
                                                        I_AUTOCOLWIDTH        = aqqis_c_true
                                                        I_AUTOCOLWIDTH_WH     = aqqis_c_false
                                                        i_hscrollbar          = aqqis_c_true ) .

****************************************************************************************
*
*    Columns
*
****************************************************************************************
*--- set title and tooltip of columns
*--- KEYICON
    clear: l_title, l_tooltip.
    l_tooltip = text-009. " Schlüsselfeld
    <tobj_join>-tabref->set_column_properties(  exporting i_column_nr     = 1
                                                          i_title         = l_title
                                                          i_tooltip       = l_tooltip
                                                          i_visible       = aqqis_c_false ) .

*--- KEYFLAG_ICON
    clear: l_title, l_tooltip.
    l_tooltip = text-009. " Schlüsselfeld
    <tobj_join>-tabref->set_column_properties(  exporting i_column_nr     = 2
                                                          i_title         = l_title
                                                          i_tooltip       = l_tooltip ).

*--- FNAME
    clear: l_title, l_tooltip.
    l_tooltip = l_title = text-010. "technischer Name
    <tobj_join>-tabref->set_column_properties(  exporting i_column_nr     = 3
                                                          i_title         = l_title
                                                          i_tooltip       = l_tooltip ).

*--- TXTLG
    clear: l_title, l_tooltip.
    l_tooltip = l_title = text-011. "Langtext
    <tobj_join>-tabref->set_column_properties(  exporting i_column_nr     = 4
                                                          i_title         = l_title
                                                          i_tooltip       = l_tooltip ).
*--- cells
    set_cell_properties( exporting i_s_tobj_join = <tobj_join> ).

*--- add table to join
    p_r_join_cntrl->add_table( exporting i_r_table =  <tobj_join>-tabref )  .

  endloop.
endmethod.                    "SEND_TABLES_TO_CNTRL


method SET_CELL_PROPERTIES .

  data: l_rowindex   type        int2,
        l_colindex   type        int2,
        l_icon       type        aqicon.

  field-symbols: <fobj> type AQSFOBJJOI.

  loop at i_s_tobj_join-fobj assigning <fobj>.
    clear: l_icon.

    l_rowindex = l_rowindex + 1.

    l_colindex = 2.
    i_s_tobj_join-tabref->set_cell_properties( exporting  i_rowindex    = l_rowindex
                                                          i_colindex    = l_colindex
                                                          i_icon        = <fobj>-KEYICON
                                               exceptions row_not_exist = 1
                                                          others        = 2 ).
  endloop.

endmethod.


method SET_CHANGED .

  data: ls_headsg type aqhdsg.

  p_join_data_r->get_info( importing e_headsg = ls_headsg ).
  ls_headsg-state = i_changed.
  p_join_data_r->set_info( exporting i_headsg = ls_headsg ).

endmethod.                    "SET_CHANGED


method SET_MODE .

  p_mode = i_mode.

endmethod.                    "SET_MODE


method SKALIERUNG_POPUP .

  data: l_scalex       type aqqproz,
        l_scaley       type aqqproz.

  CALL FUNCTION 'RSAQ_CNTRL_SCALE'
    IMPORTING
      E_X       = l_scalex
      E_Y       = l_scaley
    EXCEPTIONS
      cancelled = 1.

  if sy-subrc ne 0.
    raise cancelled.
  else.
    E_SCALEX = l_scalex.
    E_SCALEY = l_scaley.
  endif.

endmethod.


method SYNCHRONIZE_CONTROL_DATA .

  data: ls_links_join_dummy type AQSLINKJOI.

  field-symbols: <tpos>       type aqq_s_tpos,
                 <join>       type aqq_s_join,
                 <tobj_join>  type AQSTOBJJOI,
                 <links_join> type AQSLINKJOI.

* p_t_tobj_join - Tabellenobjekte
  loop at it_tpos assigning <tpos>.
    read table p_t_tobj_join assigning <tobj_join> with key tname = <tpos>-tabname.
    <tobj_join>-tpos-leftpos   = <tpos>-xpos.
    <tobj_join>-tpos-toppos    = <tpos>-ypos.
    <tobj_join>-tpos-rightpos  = <tpos>-xpos + <tpos>-width.
    <tobj_join>-tpos-bottompos = <tpos>-ypos + <tpos>-height.
  endloop.

* p_t_links_join - Linkobjekte
  loop at pt_join assigning <join>.
    read table p_t_links_join with key TNAMELEFT  = <join>-tabnamel
                                       TNAMEright = <join>-tabnamer
                                       transporting no fields.

    if sy-subrc ne 0. " linke und rechte Seite müssen getauscht werden.
      read table p_t_links_join with key TNAMELEFT  = <join>-tabnamer
                                         TNAMEright = <join>-tabnamel
                                         transporting no fields.
      if sy-subrc ne 0.
*       fatal error
        message a008(aqqis_cntrl) with 'CL_QUERY_JOIN_CNTRL' 'SYNCHRONIZE_CONTROL_DATA'.
      endif.
      loop at p_t_links_join assigning <links_join> where tnameleft  = <join>-tabnamer
                                                      and tnameright = <join>-tabnamel.
        ls_links_join_dummy = <links_join>.
        <links_join>-tnameleft  = ls_links_join_dummy-tnameright.
        <links_join>-fnameleft  = ls_links_join_dummy-fnameright.
        <links_join>-tnameright = ls_links_join_dummy-tnameleft.
        <links_join>-fnameright = ls_links_join_dummy-fnameleft.
      endloop.
    endif.
  endloop.

endmethod.                    "SYNCHRONIZE_CONTROL_DATA


method SYNCHRONIZE_POSITIONS .

  data: lt_tablepos       type aqq_t_tablepos,
        ls_tablepos       type aqstabpos,
        l_lin_tablepos    type i,
        lt_tpos           type aqq_t_tpos,
        ls_tpos           type aqq_s_tpos,
        l_forced          type boolean.

*--- Positionen dürfen nur im Änderungsmodus aktualisiert werden
  if P_MODE = aqqis_c_mode-display.
    exit.
  endif.

*--- aktuelle Positionen von dem Control holen
  lt_tablepos = p_r_join_cntrl->get_position_of_objects( ).

  describe table lt_tablepos lines l_lin_tablepos.
  if l_lin_tablepos <= 0.
    raise no_data_on_control.
  endif.

*  if lt_tablepos[] = pt_tablepos[].
*  keine Veränderung
*    exit.  "changed CR 31.10.2002
*            -> Errorhandling: links might have been changed and so
*               reorder_joins should be called
*  endif.

* lt_tpos updaten
  loop at lt_tablepos into ls_tablepos.
    abs_2_rel( exporting is_tablepos = ls_tablepos
               importing es_tpos     = ls_tpos ).
    append ls_tpos to lt_tpos.
  endloop.

* pt_join an die neuen Koordinaten anpassen
  reorder_joins( exporting it_tpos_new = lt_tpos
                           it_tpos_old = pt_tpos
                 importing  e_forced        = l_forced
                 exceptions reorder_invalid = 1 ).  "note 2114455

  "<<< note 2114455
  if sy-subrc = 1.
    if iv_no_cancel_on_error is initial.
      message id sy-msgid type sy-msgty number sy-msgno with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      return.
    else.
      message id sy-msgid type 'S' number sy-msgno with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 display like sy-msgty.
      return.
    endif.
  endif.
  ">>> note 2114455

* Frontendtabellen aktualisieren.
* p_t_tobj_join, p_t_links_join
  synchronize_control_data( it_tpos = lt_tpos ).

* Links neu zeichnen
  if l_forced = aqqis_c_true.
    recreate_links( ).
  endif.

  sort lt_tpos by xpos.
  pt_tpos[]     = lt_tpos[].
  pt_tablepos[] = lt_tablepos[].

* dbjt und dbjc aktualisieren
  cnvt_table_to_old( ).

endmethod.                    "SYNCHRONIZE_POSITIONS


method TEST_JOIN_VALIDITY .
* exceptions
*  tab_not_found                   "table not found
*  field_not_found2                "field not found
*
*  fields_invalid                  "fields cannot be combined.
*  join_type_inconsistent          "other join-types between tables have
*                                  "different type, on return
*                                  "l_wa_joins2 contains different type
*                                  "method force_join can be used to set/reset
*                                  "current join.
*  join_type_invalid_loe,          "left outer is defined between other
*                                  "tables
*
* join_type_invalid_twice:
*   making join lo would lead to:     T1-(join)LO--T2
*    (illegal #1)                                  T2
*                                         T3-------T2

  data: l_wx_join2      type aqq_s_join,
        ls_join         type aqq_s_join,
        ls_tpos         type aqq_s_tpos,
        l_join_reversed type flag.

* check whether fields are present.
*  IF MOVE_MODE <> 'X'.
*    RAISE MODE_INVALID.
*  ENDIF.
  ls_join = is_join.

  read table pt_tfield with table key tabname = ls_join-tabnamel
                                      colname = ls_join-colnamel
                                      transporting no fields.
  if sy-subrc <> 0.
    raise tab_not_found.
  endif.

  read table pt_tfield with table key tabname = ls_join-tabnamer
                                      colname = ls_join-colnamer
                                      transporting no fields.
  if sy-subrc <> 0.
    raise tab_not_found.
  endif.

  data: lt_ltab  type aqq_t_tab,
        ls_ltab  type aqq_s_tab,
        lt_rtab  type aqq_t_tab,
        ls_rtab  type aqq_s_tab.

  get_tab( exporting i_tabname = ls_join-tabnamel
           importing et_tab    = lt_ltab ).
  get_tab( exporting i_tabname = ls_join-tabnamer
           importing et_tab    = lt_rtab ).

* check whether fields can be combined.
  read table lt_ltab into ls_ltab with key feld = ls_join-colnamel.
  if sy-subrc <> 0.
    raise field_not_found.
  endif.

  read table lt_rtab into ls_rtab with key feld = ls_join-colnamer.
  if sy-subrc <> 0.
    raise field_not_found.
  endif.

  if ls_ltab-dtype <> ls_rtab-dtype or
     ls_ltab-dleng <> ls_rtab-dleng or
     ls_ltab-ddec  <> ls_rtab-ddec.
    raise fields_invalid.
  endif.


  data l_wx_join type aqq_s_join.
* check whether join-definition has to be reversed.
  read table pt_tpos into ls_tpos with key tabname = ls_join-tabnamel.
  data l_xl type i.
  l_xl = ls_tpos-xpos.
  read table pt_tpos into ls_tpos with key tabname = ls_join-tabnamer.
  clear l_join_reversed.
  if ( l_xl > ls_tpos-xpos ).
* reverse join.
    l_wx_join = ls_join.
    ls_join-tabnamel = l_wx_join-tabnamer.
    ls_join-tabnamer = l_wx_join-tabnamel.
    ls_join-colnamel = l_wx_join-colnamer.
    ls_join-colnamer = l_wx_join-colnamel.
    l_join_reversed  = aqqis_c_true.
* set flag join_reversed.
  endif.

  if ls_join-type = aqqis_c_join_typ-left_outer.
*check whether join-type left_outer is illegal here.
* it is illegal if:
* II: Join-Jain T1---LO---T2---LO---T3 would be created.

* IIa)   left table is already right table of other left outer join.
    read table pt_join into l_wx_join with key tabnamer = ls_join-tabnamel
                                               type     = aqqis_c_join_typ-left_outer.
    if sy-subrc = 0.
      e_tabname2 = ls_join-tabnamel.
      e_tabname3 = ls_join-tabnamer.
      e_tabname1 = l_wx_join-tabnamel.
      raise join_type_invalid_left.
    endif.

* IIb)  or :  right table is left table of other left-outer join.
    read table pt_join into l_wx_join with key tabnamel = ls_join-tabnamer
                                               type     = aqqis_c_join_typ-left_outer.
    if sy-subrc = 0.
      e_tabname1 = ls_join-tabnamel.
      e_tabname2 = ls_join-tabnamer.
      e_tabname3 = l_wx_join-tabnamer.
      raise join_type_invalid_right.
    endif.

*   or :    a join which would be forced would lead to an error:
*          == is a join with right table tabnamer defined
*             between a table with a left outer join?
    loop at pt_join into l_wx_join where tabnamer = ls_join-tabnamer.
      loop at pt_join into l_wx_join2 where tabnamer = l_wx_join-tabnamel
                                        and type     = aqqis_c_join_typ-left_outer.
        e_tabname1 = l_wx_join2-tabnamel.
        e_tabname2 = l_wx_join2-tabnamer.
        e_tabname3 = l_wx_join-tabnamer.
        raise join_type_invalid_side.
      endloop.
    endloop.

*   or I)  a join which would be forced would lead to an error:
*         new join is type left_outer , but r.h.s. table is
*         connected to more than one table.
    loop at pt_join into l_wx_join where tabnamer = ls_join-tabnamer.
      if l_wx_join-tabnamel <> ls_join-tabnamel.
        e_tabname1 = ls_join-tabnamel.
        e_tabname2 = ls_join-tabnamer.
        e_tabname3 = l_wx_join-tabnamel.
        raise join_type_invalid_twice.
      endif.
    endloop.
  endif.                             "new join is left outer".

* is the type of the joins between the tables inconsistent?
* = Are there other joins towards the right table of different type?
  loop at pt_join into l_wx_join where tabnamer = ls_join-tabnamer.
    if ( not (     l_wx_join-tabnamel = ls_join-tabnamel
               and l_wx_join-colnamel = ls_join-colnamel
               and l_wx_join-colnamer = ls_join-colnamer ) ). "not same join!
      if l_wx_join-type <> ls_join-type.
        raise join_type_inconsistent.
      endif.
    endif.
  endloop.
endmethod.                    "TEST_JOIN_VALIDITY


method ZOOMIN .

  data: l_zoom   type i,
        l_r_pers type ref to cl_query_join_pers.

  l_r_pers = cl_query_join_pers=>factory( ).

  set_changed( exporting i_changed = aqqis_c_false ).

  l_zoom = p_r_join_cntrl->get_zoom( ).
  add 10 to l_zoom.

  p_r_join_cntrl->set_zoom( exporting i_zoom     = l_zoom
                                      i_autozoom = aqqis_c_false ).
  l_r_pers->p_s_data-zoom = l_zoom.

* Zoom: &1 %
  message s014(aqqis_cntrl) with l_zoom.

endmethod.


method ZOOMOUT .

  data: l_zoom   type i,
        l_r_pers type ref to cl_query_join_pers.

  l_r_pers = cl_query_join_pers=>factory( ).

  set_changed( exporting i_changed = aqqis_c_false ).

  l_zoom = p_r_join_cntrl->get_zoom( ).
  subtract 10 from l_zoom.

  p_r_join_cntrl->set_zoom( exporting i_zoom     = l_zoom
                                      i_autozoom = aqqis_c_false ).
  l_r_pers->p_s_data-zoom = l_zoom.

* Zoom: &1 %
  message s014(aqqis_cntrl) with l_zoom.

endmethod.
ENDCLASS.
