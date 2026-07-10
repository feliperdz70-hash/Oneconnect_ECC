FUNCTION ZONFM_RS_CONV_EX_2_IN_DTEL.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(INPUT_EXTERNAL) TYPE  C
*"     VALUE(DTEL) LIKE  DD04L-ROLLNAME
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
*"      INVALID_DTEL
*"      FIELD_AND_DTEL_INCOMPATIBLE
*"      INPUT_TOO_LONG
*"      NO_DECIMALS
*"      INVALID_FLOAT
*"      CONVERSION_EXIT_ERROR
*"--------------------------------------------------------------------

  DATA L_SUBRC LIKE SY-SUBRC.
  DATA L_ERROR LIKE RSCONVERR.
  DATA L_CONVERT_DTEL LIKE RSCONVERT.
  DATA L_CONVERT LIKE RSCONVERT.

  PERFORM DTEL_INFO USING DTEL
               CHANGING L_CONVERT_DTEL
                        L_SUBRC.

  IF L_SUBRC <> 0.
    RAISE INVALID_DTEL.
  ENDIF.

  DESCRIBE FIELD OUTPUT_INTERNAL TYPE          L_CONVERT-TYPE
                                 LENGTH        L_CONVERT-LENGTH
                                 in byte mode
                                 OUTPUT-LENGTH L_CONVERT-OLENGTH
                                 DECIMALS      L_CONVERT-DECIMALS.

* No convertion for strings, DH 8.8.2003
  if L_CONVERT-TYPE = 'g'.
    output_internal = input_external.
    exit.
  endif.

*  if l_convert-type ne 'C'.
*    describe field output_internal length l_convert-length
*      in byte mode.
*  else.
*    describe field output_internal length l_convert-length in
*      character mode.
*  endif.
  IF L_CONVERT-TYPE        NE L_CONVERT_DTEL-TYPE              OR
     L_CONVERT-LENGTH      NE L_CONVERT_DTEL-LENGTH            OR
     ( L_CONVERT-DECIMALS    NE L_CONVERT_DTEL-DECIMALS AND
        ( L_CONVERT-TYPE NE 'F' AND L_CONVERT-TYPE NE 'a' AND L_CONVERT-TYPE NE 'e' ) ).
    MESSAGE E862 WITH L_CONVERT-TYPE L_CONVERT-LENGTH
                      L_CONVERT_DTEL-TYPE L_CONVERT_DTEL-LENGTH
       RAISING FIELD_AND_DTEL_INCOMPATIBLE.
  ENDIF.

  L_CONVERT-OLENGTH = STRLEN( INPUT_EXTERNAL ).
  IF L_CONVERT-OLENGTH > L_CONVERT_DTEL-OLENGTH.
    IF L_CONVERT_DTEL-TYPE NE 'F'
           OR L_CONVERT_DTEL-OLENGTH > MAX_FLTP_OLENGTH.
      MESSAGE E861 WITH INPUT_EXTERNAL L_CONVERT_DTEL-OLENGTH
                   RAISING INPUT_TOO_LONG.
    ELSE.
      L_CONVERT_DTEL-OLENGTH = L_CONVERT-OLENGTH.
    ENDIF.
  ENDIF.

  IF L_CONVERT_DTEL-LOWER = SPACE.
    TRANSLATE INPUT_EXTERNAL TO UPPER CASE.
  ENDIF.

  PERFORM CONVERT_EX_2_IN(RSDYNSS0) USING    L_CONVERT_DTEL
                                             INPUT_EXTERNAL
                                    CHANGING L_SUBRC L_ERROR
                                             OUTPUT_INTERNAL.

  IF L_SUBRC NE 0.
    PERFORM CONVERT_ERROR USING L_ERROR L_CONVERT_DTEL L_SUBRC.
  ENDIF.

ENDFUNCTION.
