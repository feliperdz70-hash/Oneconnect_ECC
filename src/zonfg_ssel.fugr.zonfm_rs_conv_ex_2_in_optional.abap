FUNCTION ZONFM_RS_CONV_EX_2_IN_OPTIONAL.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(INPUT_EXTERNAL) TYPE  C
*"     VALUE(TABLE_FIELD) LIKE  TABFIELD STRUCTURE  TABFIELD
*"     REFERENCE(CURRENCY) OPTIONAL
*"  EXPORTING
*"     VALUE(OUTPUT_INTERNAL)
*"  EXCEPTIONS
*"      INPUT_NOT_NUMERICAL
*"      TOO_MANY_DECIMALS
*"      MORE_THAN_ONE_SIGN
*"      ILL_THOUSAND_SEPARATOR_DIST
*"      TOO_MANY_DIGITS
*"      SIGN_FOR_UNSIGNED
*"      TOO_LARGE
*"      TOO_SMALL
*"      INVALID_DATE_FORMAT
*"      INVALID_DATE
*"      INVALID_TIME_FORMAT
*"      INVALID_TIME
*"      INVALID_HEX_DIGIT
*"      UNEXPECTED_ERROR
*"      INVALID_FIELDNAME
*"      FIELD_AND_DESCR_INCOMPATIBLE
*"      INPUT_TOO_LONG
*"      NO_DECIMALS
*"      INVALID_FLOAT
*"      CONVERSION_EXIT_ERROR
*"--------------------------------------------------------------------

  data l_subrc like sy-subrc.
  data l_error like rsconverr.
  data l_convert like rsconvert.
  data l_type like rsconvert-type.
  data l_length like rsconvert-length.
  data l_olength like rsconvert-olength.
  data l_tcurx like tcurx.
  data l_ctx_dd type context_free_sel_dd_info.
  data l_msg    like symsg occurs 0.
  data l_diff type i.
  data: l_packed(16) type p.
  field-symbols: <l_f> type any.

  supply tablename = table_field-tabname
         fieldname = table_field-fieldname
            to context l_ctx_dd.
  demand convert     = l_convert
         from context l_ctx_dd
         messages into l_msg.
  if sy-subrc ne 0.
    raise invalid_fieldname.
  endif.

  if currency is not initial.
    l_convert-dddecimals = l_convert-decimals.
  else.
    l_convert-decimals = 2.
  endif.
  if currency ne space.
    select single * from tcurx into l_tcurx
                               where currkey = currency.
    if sy-subrc eq 0.
      l_convert-decimals = l_tcurx-currdec.
    else.
      l_convert-decimals = 2.
    endif.
  endif.

  describe field output_internal type l_type
                length l_length in byte mode.

* No convertion for strings, DH 10.8.2001
  if l_type = 'g'.
    output_internal = input_external.
    exit.
  endif.

  if l_type        ne l_convert-type ."   OR
*     L_LENGTH      NE L_CONVERT-LENGTH.
    message e862 with l_type l_length l_convert-type l_convert-length
       raising field_and_descr_incompatible.
  endif.

  if l_convert-type co 'IsPbF8'.
    if input_external cn ' '.
      l_olength = strlen( input_external+sy-fdpos ).
    endif.
  else.
    l_olength = strlen( input_external ).
  endif.
  if l_olength > l_convert-olength.
    if l_convert-type ne 'F'
           or l_convert-olength > max_fltp_olength.
      message e861 with input_external l_convert-olength
                   raising input_too_long.
    else.
      l_convert-olength = l_olength.
    endif.
  endif.

  if l_convert-lower = space.
    translate input_external to upper case.
  endif.
  if currency ne space and l_convert-decimals = 0.
    assign l_packed to <l_f> decimals l_convert-dddecimals.
    perform convert_ex_2_in(rsdynss0) using    l_convert
                                               input_external
                                      changing l_subrc l_error
                                               <l_f>.

    output_internal = <l_f> / ( 10 ** l_convert-dddecimals ).
  else.
    perform convert_ex_2_in(rsdynss0) using    l_convert
                                               input_external
                                      changing l_subrc l_error
                                               output_internal.

  endif.
  if l_subrc ne 0.
    perform convert_error using l_error l_convert l_subrc.
  endif.

endfunction.
