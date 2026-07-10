FUNCTION ZONFM_RS_DS_INT_INFO_2_MEM.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(P_MEMKEY) LIKE  RSVAMEMKEY STRUCTURE  RSVAMEMKEY
*"--------------------------------------------------------------------

  EXPORT SELID_INFO TABS_AND_JOINS QUFIELDS LAST_SELID
    TO MEMORY ID P_MEMKEY.

ENDFUNCTION.
