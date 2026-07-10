*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZONFG_ONECONNECT
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZONFG_ONECONNECT   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
