FUNCTION ZONFM_RSAQ_CNTRL_SEARCH_0400 .
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_TNAME) TYPE  AQS_TNAME
*"  EXPORTING
*"     REFERENCE(ES_SEARCH) TYPE  AQSSEARCH
*"  EXCEPTIONS
*"      NOT_FOUND
*"      CANCELLED
*"--------------------------------------------------------------------

  g_tname_l = i_tname.

  call screen 0400 starting at 10 3.

  if not g_dyn_0400-rad_searchtext is initial.
    ES_SEARCH-ART        = 'X'.
    ES_SEARCH-SEARCHTEXT = g_dyn_0400-searchtext.
  elseif not g_dyn_0400-rad_searchdom is initial.
    ES_SEARCH-ART        = 'D'.
    ES_SEARCH-SEARCHDOM  = g_dyn_0400-searchdom.
  elseif not g_dyn_0400-rad_searchtype is initial.
    ES_SEARCH-ART        = 'T'.
    ES_SEARCH-SEARCHTYPE = rs38q-dtype.
    ES_SEARCH-CLENG      = rs38q-cleng.
    ES_SEARCH-DECNUMB    = rs38q-decnumb.
  endif.

ENDFUNCTION.
