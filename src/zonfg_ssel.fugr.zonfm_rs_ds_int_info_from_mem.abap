FUNCTION ZONFM_RS_DS_INT_INFO_FROM_MEM.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(P_MEMKEY) LIKE  RSVAMEMKEY STRUCTURE  RSVAMEMKEY
*"--------------------------------------------------------------------

  IMPORT SELID_INFO TABS_AND_JOINS QUFIELDS LAST_SELID
    FROM MEMORY ID P_MEMKEY.
  FREE MEMORY ID P_MEMKEY.

ENDFUNCTION.
