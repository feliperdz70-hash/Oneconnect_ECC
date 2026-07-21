function ZONFM_RSAQ_DJ_DEFINE_ALIASTAB.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(SGNAME_INPUT) TYPE  AQS_SGNAME
*"     VALUE(ACT_WORKSPACE_INPUT) TYPE  AQS_WSID
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
*"     REFERENCE(MAXSG_TINDX_INPUT) LIKE  AQADEF-TINDX
*"     REFERENCE(MODE_INPUT) TYPE  I
*"--------------------------------------------------------------------

* copy parameters to global storage
* importing...
  sgname = sgname_input.
  act_workspace = act_workspace_input.
* tables ...
  clogsg[] = clogsg_input[].
  dbsa[] = dbsa_input[].
  dbob[] = dbob_input[].
  dbos[] = dbos_input[].
  dbif[] = dbif_input[].
  dbsf[] = dbsf_input[].
  dbsg[] = dbsg_input[].
  dban[] = dban_input[].
  dbjt[] = dbjt_input[].
  dbjc[] = dbjc_input[].
  dbzt[] = dbzt_input[].
  dbzc[] = dbzc_input[].
  dbzl[] = dbzl_input[].
  dbdp[] = dbdp_input[].
  dbpa[] = dbpa_input[].
  dbwr[] = dbwr_input[].
  dbar[] = dbar_input[].
  dbft[] = dbft_input[].
  sgtext[] = sgtext_input[].
  exdbfi[] = exdbfi_input[].
  ttab[]   = ttab_input[].
* changing                             "
  headsg = headsg_input.
  maxsg_tindx = maxsg_tindx_input.
  mode = mode_input.

** call inner form routine (in LAQJDF33)
  perform define_aliastables.

* Copy global storage to parameters
*  Tables...
  clogsg_input[] = clogsg[].           "< we donnot modify these
  dbsa_input[] = dbsa[].               "<
  dbob_input[] = dbob[].               "<
  dbos_input[] = dbos[].               "<
  dbif_input[] = dbif[].               "<
  dbsf_input[] = dbsf[].               "<
  dbsg_input[] = dbsg[].
  dban_input[] = dban[].
  dbjt_input[] = dbjt[].
  dbjc_input[] = dbjc[].
  dbzt_input[] = dbzt[].               "<
  dbzc_input[] = dbzc[].               "<
  dbzl_input[] = dbzl[].               "<
  dbdp_input[] = dbdp[].               "<
  dbpa_input[] = dbpa[].               "<
  dbwr_input[] = dbwr[].               "<
  dbar_input[] = dbar[].               "<
  dbft_input[] = dbft[].               "<
  sgtext_input[] = sgtext[].
  exdbfi_input[] = exdbfi[].
  ttab_input[] = ttab[].
* changing...
  headsg_input = headsg.
  maxsg_tindx_input = maxsg_tindx.
  mode_input = mode.
endfunction.
