function ZONFM_RSAQ_DJ_DEFINE_JOIN_CNT .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(ACT_WORKSPACE_INPUT) TYPE  AQS_WSID DEFAULT SPACE
*"     VALUE(SGNAME_INPUT) TYPE  AQS_SGNAME
*"     VALUE(CALLER_ID_INPUT) TYPE  C
*"     VALUE(GRAFIC_INPUT) LIKE  AQADEF-FLAG DEFAULT 'X'
*"  TABLES
*"      CLOGSG_INPUT STRUCTURE  AQCLSG
*"      DBSA_INPUT STRUCTURE  AQDBSA
*"      DBOB_INPUT STRUCTURE  AQDBOB
*"      DBOS_INPUT STRUCTURE  AQDBOS
*"      DBIF_INPUT STRUCTURE  AQDBIF
*"      DBSF_INPUT STRUCTURE  AQDBSF
*"      DBSG_INPUT STRUCTURE  AQDBSG
*"      DBAN_INPUT STRUCTURE  AQDBAN
*"      DBJT_INPUT STRUCTURE  AQDBJT
*"      DBJC_INPUT STRUCTURE  AQDBJC
*"      DBZT_INPUT STRUCTURE  AQDBZT
*"      DBZC_INPUT STRUCTURE  AQDBZC
*"      DBZL_INPUT STRUCTURE  AQDBZL
*"      DBDP_INPUT STRUCTURE  AQDBDP
*"      DBPA_INPUT STRUCTURE  AQDBPA
*"      DBWR_INPUT STRUCTURE  AQDBWR
*"      DBAR_INPUT STRUCTURE  AQDBAR
*"      DBFT_INPUT STRUCTURE  AQDBFT
*"      SGTEXT_INPUT STRUCTURE  AQTXSG
*"      EXDBFI_INPUT
*"      TTAB_INPUT
*"  CHANGING
*"     REFERENCE(HEADSG_INPUT) LIKE  AQHDSG STRUCTURE  AQHDSG
*"     REFERENCE(MODE_INPUT) TYPE  I
*"     REFERENCE(MAXSG_TINDX_INPUT) TYPE  AQS_TINDX
*"  EXCEPTIONS
*"      CANCELLED
*"----------------------------------------------------------------------
  data: l_lin_dbjt        type i,
        ls_dbjt           type aqdbjt,
        l_headsg_sav      type aqhdsg,
        l_maxsg_tindx_sav type aqs_tindx,
        l_mode_sav        type i,
        lt_clogsg_sav     type aqtclsg,
        lt_dbsa_sav       type aqtdbsa,
        lt_dbob_sav       type aqtdbob,
        lt_dbos_sav       type aqtdbos,
        lt_dbif_sav       type aqtdbif,
        lt_dbsf_sav       type aqtdbsf,
        lt_dbsg_sav       type aqtdbsg,
        lt_dban_sav       type aqtdban,
        lt_dbjt_sav       type aqtdbjt,
        lt_dbjc_sav       type aqtdbjc,
        lt_dbzt_sav       type aqtdbzt,
        lt_dbzc_sav       type aqtdbzc,
        lt_dbzl_sav       type aqtdbzl,
        lt_dbdp_sav       type aqtdbdp_stdkey,
        lt_dbpa_sav       type aqtdbpa,
        lt_dbwr_sav       type aqtdbwr,
        lt_dbar_sav       type aqtdbar,
        lt_dbft_sav       type aqtdbft,
        lt_sgtext_sav     type aqttxsg,
        lt_exdbfi_sav     type aqq_t_exdbfi,
        lt_ttab_sav       type aqq_t_ttab.

  clear: g_canceled.


* copy parameters to global storage
* importing...
  g_caller_id   = caller_id_input.   " S= functional area maintenance, Q= Quickview.
  g_grafic      = grafic_input.
  g_sgname      = sgname_input.
  act_workspace = act_workspace_input.

* tables...
  lt_clogsg_sav[] = clogsg[] = clogsg_input[].
  lt_dbsa_sav[]   = dbsa[]   = dbsa_input[].
  lt_dbob_sav[]   = dbob[]   = dbob_input[].
  lt_dbos_sav[]   = dbos[]   = dbos_input[].
  lt_dbif_sav[]   = dbif[]   = dbif_input[].
  lt_dbsf_sav[]   = dbsf[]   = dbsf_input[].
  lt_dbsg_sav[]   = dbsg[]   = dbsg_input[].
  lt_dban_sav[]   = dban[]   = dban_input[].
  lt_dbjt_sav[]   = dbjt[]   = dbjt_input[].
  lt_dbjc_sav[]   = dbjc[]   = dbjc_input[].
  lt_dbzt_sav[]   = dbzt[]   = dbzt_input[].
  lt_dbzc_sav[]   = dbzc[]   = dbzc_input[].
  lt_dbzl_sav[]   = dbzl[]   = dbzl_input[].
  lt_dbdp_sav[]   = dbdp[]   = dbdp_input[].
  lt_dbpa_sav[]   = dbpa[]   = dbpa_input[].
  lt_dbwr_sav[]   = dbwr[]   = dbwr_input[].
  lt_dbar_sav[]   = dbar[]   = dbar_input[].
  lt_dbft_sav[]   = dbft[]   = dbft_input[].
  lt_sgtext_sav[] = sgtext[] = sgtext_input[].
  lt_exdbfi_sav[] = exdbfi[] = exdbfi_input[].
  lt_ttab_sav[]   = ttab[]   = ttab_input[].

* changing...
  l_headsg_sav      = headsg       = headsg_input.
  l_mode_sav        = g_mode       = mode_input.
  l_maxsg_tindx_sav = maxsg_tindx  = maxsg_tindx_input.

*----
  describe table dbjt lines l_lin_dbjt.
*--- initialer Einstieg: Infoset wird neu angelegt
  if l_lin_dbjt = 0 and g_caller_id = 'S'.
    ls_dbjt-table = headsg-tstruc.
    append ls_dbjt to dbjt.
  endif.

  perform fill_ttab tables ttab[]  " <-
                           dbjt[]. " ->

*  perform fill_exdbfi tables dbjt[].
  perform define_join.
*----

  if g_canceled = aqqis_c_true.     "canceled=X: Don't copy the data
    clogsg_input[] = lt_clogsg_sav[].           "<
    dbsa_input[]   = lt_dbsa_sav[].
    dbob_input[]   = lt_dbob_sav[].
    dbos_input[]   = lt_dbos_sav[].
    dbif_input[]   = lt_dbif_sav[].
    dbsf_input[]   = lt_dbsf_sav[].             "<
    dbsg_input[]   = lt_dbsg_sav[].
    dban_input[]   = lt_dban_sav[].
    dbjt_input[]   = lt_dbjt_sav[].
    dbjc_input[]   = lt_dbjc_sav[].
    dbzt_input[]   = lt_dbzt_sav[].             "<
    dbzc_input[]   = lt_dbzc_sav[].             "<
    dbzl_input[]   = lt_dbzl_sav[].             "<
    dbdp_input[]   = lt_dbdp_sav[].             "<
    dbpa_input[]   = lt_dbpa_sav[].             "<
    dbwr_input[]   = lt_dbwr_sav[].
    dbar_input[]   = lt_dbar_sav[].
    dbft_input[]   = lt_dbft_sav[].
    sgtext_input[] = lt_sgtext_sav[].
    exdbfi_input[] = lt_exdbfi_sav[].
    ttab_input[]   = lt_ttab_sav[].

*   '<' indicates that these tables are (believed to be) left unchanged
*       within this function.
*  changing ...
    headsg_input       = l_headsg_sav.
    mode_input         = l_mode_sav.
    maxsg_tindx_input  = l_maxsg_tindx_sav.

  else.
* Copy global storage back
* tables...
    clogsg_input[] = clogsg[].           "<
    dbsa_input[]   = dbsa[].
    dbob_input[]   = dbob[].
    dbos_input[]   = dbos[].
    dbif_input[]   = dbif[].
    dbsf_input[]   = dbsf[].             "<
    dbsg_input[]   = dbsg[].
    dban_input[]   = dban[].
    dbjt_input[]   = dbjt[].
    dbjc_input[]   = dbjc[].
    dbzt_input[]   = dbzt[].             "<
    dbzc_input[]   = dbzc[].             "<
    dbzl_input[]   = dbzl[].             "<
    dbdp_input[]   = dbdp[].             "<
    dbpa_input[]   = dbpa[].             "<
    dbwr_input[]   = dbwr[].
    dbar_input[]   = dbar[].
    dbft_input[]   = dbft[].
    sgtext_input[] = sgtext[].
    exdbfi_input[] = exdbfi[].
    ttab_input[]   = ttab[].

*   '<' indicates that these tables are (believed to be) left unchanged
*       within this function.
*  changing ...
    headsg_input       = headsg.
    mode_input         = g_mode.
    maxsg_tindx_input  = maxsg_tindx.
  endif.
endfunction.
