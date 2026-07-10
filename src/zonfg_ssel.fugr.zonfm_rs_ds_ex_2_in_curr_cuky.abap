FUNCTION ZONFM_RS_DS_EX_2_IN_CURR_CUKY.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(SUM) TYPE  C
*"  EXPORTING
*"     REFERENCE(SUM_INTERNAL_FORMAT) TYPE  P
*"  EXCEPTIONS
*"      WRONG_OUTPUT_FIELD_TYPE
*"--------------------------------------------------------------------

data : l_sum type p,
       l_type,
       l_decimals type i.
field-symbols <output> type p .

  describe field sum_internal_format type     l_type
                                     decimals l_decimals.
  if l_type ne 'P' or l_decimals ne 2.
    raise wrong_output_field_type.
  endif.
  l_sum = sum.
  assign l_sum to <output> decimals 2.
  sum_internal_format = <output>.
ENDFUNCTION.
