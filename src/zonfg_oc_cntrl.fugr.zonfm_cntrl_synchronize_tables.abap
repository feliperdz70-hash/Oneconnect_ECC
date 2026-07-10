FUNCTION ZONFM_CNTRL_SYNCHRONIZE_TABLES.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"--------------------------------------------------------------------

  if g_MODE = aqqis_c_mode-display.
    exit.
  endif.

  if not g_join_data is initial.
    g_join_data->GET_INFO( IMPORTING  E_SGNAME       = g_sgname
                                      E_ACTWORKSPACE = act_workspace
                                      E_HEADSG       = headsg
                                      E_MAXSG_TINDX  = maxsg_tindx
                                      E_MODE         = g_mode
                                      ET_DBDP        = dbdp[]
                                      ET_DBPA        = dbpa[]
                                      ET_DBWR        = dbwr[]
                                      ET_DBAR        = dbar[]
                                      ET_DBFT        = dbft[]
                                      ET_SGTEXT      = sgtext[]
                                      ET_EXDBFI      = exdbfi[]
                                      ET_TTAB        = ttab[]
                                      ET_DBZL        = dbzl[]
                                      ET_CLOGSG      = clogsg[]
                                      ET_DBSA        = dbsa[]
                                      ET_DBOB        = dbob[]
                                      ET_DBOS        = dbos[]
                                      ET_DBIF        = dbif[]
                                      ET_DBSF        = dbsf[]
                                      ET_DBSG        = dbsg[]
                                      ET_DBAN        = dban[]
                                      ET_DBJT        = dbjt[]
                                      ET_DBJC        = dbjc[]
                                      ET_DBZT        = dbzt[]
                                      ET_DBZC        = dbzc[] ).
  endif.

ENDFUNCTION.
