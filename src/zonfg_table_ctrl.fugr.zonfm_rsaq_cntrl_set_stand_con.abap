FUNCTION ZONFM_RSAQ_CNTRL_SET_STAND_CON.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_TABL) TYPE  AQS_TNAME
*"     REFERENCE(I_TABR) TYPE  AQS_TNAME
*"  TABLES
*"      TT_DBJC TYPE  AQTDBJC
*"      TT_DBJC_DELTA TYPE  AQTDBJC
*"      TT_EXDBFI TYPE  AQQ_T_EXDBFI
*"  CHANGING
*"     REFERENCE(C_HEADSG) TYPE  AQHDSG
*"  EXCEPTIONS
*"      NO_CONDITION
*"--------------------------------------------------------------------
  data: l_jind(2)   type n,
        l_tabname   type tname,
        l_state     like ddrefstruc-state,          "#EC NEEDED
        lt_head like dd08v occurs 20 with header line,
        lt_fkey like dd05m occurs 30 with header line,
        lt_hdum like dd08v occurs 20 with header line,
        lt_fdum like dd05m occurs 20 with header line,

        lt_dbjc type aqtdbjc,
        ls_dbjc type aqdbjc,

        lt_ltab type aqqis_t_tab,
        lt_rtab type aqqis_t_tab,
        ls_ltab type aqqis_s_tab,
        ls_rtab type aqqis_s_tab.

  loop at tt_dbjc where jind   <> space
                    and ltable =  i_tabl
                    and rtable =  i_tabr.
    raise no_condition.      " Bedingungen bereits gepflegt
  endloop.

* Standardimplementierung
* Fremdschlüsselbeziehungen auswerten
  l_jind = '00'.

* Fremdschlüsselbeziehungen LTAB -> RTAB
  l_tabname = i_tabl.
  call function 'DD_TBFK_GET'
    EXPORTING
      tabl_name   = l_tabname
    IMPORTING
      got_state   = l_state
    TABLES
      dd05m_tab_a = lt_fkey
      dd05m_tab_n = lt_fdum
      dd08v_tab_a = lt_head
      dd08v_tab_n = lt_hdum
    EXCEPTIONS
      others      = 0.

  loop at lt_fkey where datatype <> 'CLNT'
                    and fortable   = i_tabl
                    and checktable = i_tabr.
    ls_dbjc-jind   = space.
    ls_dbjc-ltable = i_tabl.
    concatenate ls_dbjc-ltable '-' lt_fkey-forkey into ls_dbjc-lname.
    ls_dbjc-rtable = i_tabr.
    concatenate ls_dbjc-rtable '-' lt_fkey-checkfield into ls_dbjc-rname.

    read table tt_dbjc with key ltable = ls_dbjc-ltable
                                lname  = ls_dbjc-lname
                                rtable = ls_dbjc-rtable.
    if sy-subrc <> 0.
      read table tt_dbjc with key ltable = ls_dbjc-ltable
                                  rtable = ls_dbjc-rtable
                                  rname  = ls_dbjc-rname.
      if sy-subrc <> 0.
        ls_dbjc-jind = l_jind.
        append: ls_dbjc to tt_dbjc, ls_dbjc to tt_dbjc_delta.
        c_headsg-state = 'U'.
        l_jind = l_jind + 1.
      endif.
    endif.
  endloop.

* Fremdschlüsselbeziehungen LTAB <- RTAB
  l_tabname = i_tabr.
  call function 'DD_TBFK_GET'
    EXPORTING
      tabl_name   = l_tabname
    IMPORTING
      got_state   = l_state
    TABLES
      dd05m_tab_a = lt_fkey
      dd05m_tab_n = lt_fdum
      dd08v_tab_a = lt_head
      dd08v_tab_n = lt_hdum
    EXCEPTIONS
      others      = 0.

  loop at lt_fkey where datatype <> 'CLNT'
                    and fortable   = i_tabr
                    and checktable = i_tabl.
    ls_dbjc-jind   = space.
    ls_dbjc-ltable = i_tabl.
    concatenate ls_dbjc-ltable '-' lt_fkey-checkfield into ls_dbjc-lname.
    ls_dbjc-rtable = i_tabr.
    concatenate ls_dbjc-rtable '-' lt_fkey-forkey into ls_dbjc-rname.
    read table tt_dbjc with key ltable = ls_dbjc-ltable
                                lname  = ls_dbjc-lname
                                rtable = ls_dbjc-rtable.
    if sy-subrc <> 0.
      read table tt_dbjc with key ltable = ls_dbjc-ltable
                                  rtable = ls_dbjc-rtable
                                  rname  = ls_dbjc-rname.
      if sy-subrc <> 0.
        ls_dbjc-jind = l_jind.
        append: ls_dbjc to tt_dbjc, ls_dbjc to tt_dbjc_delta.
        c_headsg-state = 'U'.
        l_jind = l_jind + 1.
      endif.
    endif.
  endloop.

  if l_jind <> '00'.                     " Fremdschlüsselbeziehungen gef.
    exit.
  endif.

* Standardvorschläge über Domänenbeziehungen
  perform fill_join_tab(saplaqjd) tables lt_ltab using i_tabl.
  perform fill_join_tab(saplaqjd) tables lt_rtab using i_tabr.

  loop at lt_ltab into ls_ltab where key <> space.
    loop at lt_rtab into ls_rtab where dom = ls_ltab-dom.
      ls_dbjc-jind   = space.
      ls_dbjc-ltable = i_tabl.
      concatenate ls_dbjc-ltable '-' ls_ltab-feld into ls_dbjc-lname.
      ls_dbjc-rtable = i_tabr.
      concatenate ls_dbjc-rtable '-' ls_rtab-feld into ls_dbjc-rname.
      read table tt_dbjc with key ltable = ls_dbjc-ltable
                                  lname  = ls_dbjc-lname
                                  rtable = ls_dbjc-rtable.
      if sy-subrc <> 0.
        read table tt_dbjc with key ltable = ls_dbjc-ltable
                                    rtable = ls_dbjc-rtable
                                    rname  = ls_dbjc-rname.
        if sy-subrc <> 0.
          ls_dbjc-jind = l_jind.
          append: ls_dbjc to tt_dbjc, ls_dbjc to tt_dbjc_delta.
          c_headsg-state = 'U'.
          l_jind = l_jind + 1.
        endif.
      endif.
    endloop.
  endloop.
  loop at lt_rtab into ls_rtab where key <> space.
    loop at lt_ltab into ls_ltab where dom = ls_rtab-dom.
      ls_dbjc-jind   = space.
      ls_dbjc-ltable = i_tabl.
      concatenate ls_dbjc-ltable '-' ls_ltab-feld into ls_dbjc-lname.
      ls_dbjc-rtable = i_tabr.
      concatenate ls_dbjc-rtable '-' ls_rtab-feld into ls_dbjc-rname.
      read table tt_dbjc with key ltable = ls_dbjc-ltable
                                  lname  = ls_dbjc-lname
                                  rtable = ls_dbjc-rtable.
      if sy-subrc <> 0.
        read table tt_dbjc with key ltable = ls_dbjc-ltable
                                    rtable = ls_dbjc-rtable
                                    rname  = ls_dbjc-rname.
        if sy-subrc <> 0.
          ls_dbjc-jind = l_jind.
          append: ls_dbjc to tt_dbjc, ls_dbjc to tt_dbjc_delta.
          c_headsg-state = 'U'.
          l_jind = l_jind + 1.
        endif.
      endif.
    endloop.
  endloop.

ENDFUNCTION.
