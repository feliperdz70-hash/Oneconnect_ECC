FUNCTION ZONFM_FREE_SELECTIONS_RANGE2EX.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(FIELD_RANGES) TYPE  RSDS_TRANGE
*"  EXPORTING
*"     VALUE(EXPRESSIONS) TYPE  RSDS_TEXPR
*"--------------------------------------------------------------------

  PERFORM TRANGE_2_TEXPR USING    FIELD_RANGES
                         CHANGING EXPRESSIONS.

ENDFUNCTION.
