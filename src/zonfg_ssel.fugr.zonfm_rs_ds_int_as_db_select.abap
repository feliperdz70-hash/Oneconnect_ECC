FUNCTION ZONFM_RS_DS_INT_AS_DB_SELECT.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(SELECTION_ID) LIKE  RSDYNSEL-SELID
*"     VALUE(PROGRAM) LIKE  SY-REPID
*"  EXPORTING
*"     VALUE(WHERE_CLAUSES) TYPE  RSDS_TWHERE
*"     VALUE(FIELD_RANGES) TYPE  RSDS_TRANGE
*"  TABLES
*"      P_SSCR STRUCTURE  RSSCR
*"  EXCEPTIONS
*"      INTERNAL_ERROR
*"      SELID_NOT_FOUND
*"--------------------------------------------------------------------

  DATA L_SUBRC LIKE SY-SUBRC.

  clear g_flag_show_sels.
  READ TABLE SELID_INFO WITH KEY selid = SELECTION_ID
                        BINARY SEARCH
                        INTO CURRENT_INFO.

  IF SY-SUBRC NE 0.
    RAISE SELID_NOT_FOUND.
  ENDIF.

  PERFORM APPEND_FIELD_SEL TABLES P_SSCR
                           USING PROGRAM.

  IF WHERE_CLAUSES IS REQUESTED.
    PERFORM GEN_WHERE_CLAUSES USING    CURRENT_INFO
                              CHANGING WHERE_CLAUSES L_SUBRC.
  ENDIF.

  CHECK FIELD_RANGES IS REQUESTED.
  PERFORM BUILD_TRANGE USING    CURRENT_INFO-FIELD_SEL
                                CURRENT_INFO-ANY_JOINS
                       CHANGING FIELD_RANGES.

ENDFUNCTION.
