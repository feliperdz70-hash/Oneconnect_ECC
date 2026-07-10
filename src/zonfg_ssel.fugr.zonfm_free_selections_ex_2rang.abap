FUNCTION ZONFM_FREE_SELECTIONS_EX_2RANG.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(EXPRESSIONS) TYPE  RSDS_TEXPR
*"  EXPORTING
*"     VALUE(FIELD_RANGES) TYPE  RSDS_TRANGE
*"  EXCEPTIONS
*"      EXPRESSION_NOT_SUPPORTED
*"      INCORRECT_EXPRESSION
*"--------------------------------------------------------------------

  DATA L_SUBRC LIKE SY-SUBRC.
  DATA L_EXPR_FI_INDICES LIKE EXPR_FI_INDICES OCCURS 10
                                   WITH HEADER LINE.
  DATA L_FIELD_SEL_T LIKE CURRENT_INFO-FIELD_SEL.
  DATA L_FIELD_SEL   TYPE FIELD_SEL_TYPE.
  DATA L_RANGE TYPE RSDS_RANGE.
  DATA L_FRANGE TYPE RSDS_FRANGE.
  data l_kind like current_info-kind.

  l_kind = current_info-kind.
  clear current_info-kind.

  PERFORM BUILD_FIELD_SEL TABLES   L_EXPR_FI_INDICES
                          USING    EXPRESSIONS
                          CHANGING L_FIELD_SEL_T
                                   L_SUBRC.
  current_info-kind = l_kind.
  CASE L_SUBRC.
    WHEN 0.
    WHEN 4.               " Nicht unterstützter Ausdruck
      RAISE EXPRESSION_NOT_SUPPORTED.
    WHEN 8.               " Inkorrekter Ausdruck
      RAISE INCORRECT_EXPRESSION.
  ENDCASE.

  SORT L_FIELD_SEL_T BY TABLENAME.
  CLEAR FIELD_RANGES.

  LOOP AT L_FIELD_SEL_T INTO L_FIELD_SEL.
    AT NEW TABLENAME.
      MOVE L_FIELD_SEL-TABLENAME TO L_RANGE-TABLENAME.
    ENDAT.
    MOVE L_FIELD_SEL-FIELDNAME TO L_FRANGE-FIELDNAME.
    MOVE L_FIELD_SEL-FIELDSEL TO L_FRANGE-SELOPT_T.
    APPEND L_FRANGE TO L_RANGE-FRANGE_T.
    AT END OF TABLENAME.
      APPEND L_RANGE TO FIELD_RANGES.
      CLEAR: L_RANGE.
    ENDAT.
  ENDLOOP.

ENDFUNCTION.
