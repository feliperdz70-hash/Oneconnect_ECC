FUNCTION ZONFM_RS_CONV_EX_2_IN_NO_DD.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(INPUT_EXTERNAL) TYPE  C
*"     VALUE(CONVERT) LIKE  RSCONVLITE STRUCTURE  RSCONVLITE OPTIONAL
*"     REFERENCE(CURRENCY) TYPE  C DEFAULT SPACE
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
*"      INPUT_TOO_LONG
*"      NO_DECIMALS
*"      INVALID_FLOAT
*"      ILLEGAL_TYPE
*"      CONVERSION_EXIT_ERROR
*"--------------------------------------------------------------------

  DATA L_SUBRC LIKE SY-SUBRC.
  DATA L_ERROR LIKE RSCONVERR.
  DATA L_CONVERT LIKE RSCONVERT.
  DATA L_INT TYPE I.
  DATA L_DECIFLAG.
  data l_tcurx like tcurx.

  FIELD-SYMBOLS: <L_INTERNAL>, <output_internal>.
  DATA: BEGIN OF L_EMASK,
          PREFIX(2),
          CONVEXIT LIKE RSCONVERT-CONVEXIT,
        END   OF L_EMASK.

  DESCRIBE FIELD OUTPUT_INTERNAL TYPE          L_CONVERT-TYPE
                                 COMPONENTS    L_INT
                                 LENGTH        L_CONVERT-LENGTH
                                 in byte mode
                                 OUTPUT-LENGTH L_CONVERT-OLENGTH
                                 DECIMALS      L_CONVERT-DECIMALS
                                 EDIT MASK     L_EMASK.
* No convertion for strings, DH 10.8.2001
  if L_CONVERT-TYPE = 'g'.
    output_internal = input_external.
    exit.
  endif.

*  if l_convert-type ne 'C'.
*    describe field output_internal length l_convert-length
*    in byte mode.
*  else.
*    describe field output_internal length l_convert-length
*    in character mode.
*  endif.
  perform ileng_2_cleng in program rsdynss0
                        using    l_CONVERT-TYPE
                                 l_CONVERT-length
                        changing l_CONVERT-clength.
  L_CONVERT-CONVEXIT = L_EMASK-CONVEXIT.
  IF L_CONVERT-TYPE = 'v' OR L_CONVERT-TYPE = 'h'.
    MESSAGE E860 RAISING ILLEGAL_TYPE.
  ELSEIF L_CONVERT-TYPE = 'u'.
    L_CONVERT-TYPE = 'C'.
  ENDIF.

  IF CONVERT-ACTIVE NE SPACE.
    IF L_CONVERT-TYPE = 'P'                      AND
                      L_CONVERT-DECIMALS NE CONVERT-DECIMALS.
      ASSIGN OUTPUT_INTERNAL TO <L_INTERNAL> DECIMALS CONVERT-DECIMALS.
      L_DECIFLAG = 'X'.
    ENDIF.
    MOVE-CORRESPONDING CONVERT TO L_CONVERT.
  ELSE.
    IF L_CONVERT-TYPE = 'I' OR L_CONVERT-TYPE = 's' OR
       L_CONVERT-TYPE = 'F' OR L_CONVERT-TYPE ='8'.
      L_CONVERT-SIGN = 'X'.
    ENDIF.
  ENDIF.

  if currency ne space.
    move currency to l_convert-quan_unit.
    select single * from tcurx into l_tcurx
                               where currkey = currency.
    if sy-subrc eq 0.
     ASSIGN OUTPUT_INTERNAL TO <L_INTERNAL> DECIMALS l_tcurx-currdec.
      l_convert-decimals = l_tcurx-currdec.
      l_deciflag = 'X'.
    ENDIF.
  ENDIF.

  L_INT = STRLEN( INPUT_EXTERNAL ).
  IF L_INT > L_CONVERT-OLENGTH.
    IF L_CONVERT-TYPE NE 'F' OR L_CONVERT-OLENGTH > MAX_FLTP_OLENGTH.
      MESSAGE E861 WITH INPUT_EXTERNAL L_CONVERT-OLENGTH
                   RAISING INPUT_TOO_LONG.
    ELSE.
      L_CONVERT-OLENGTH = L_INT.
    ENDIF.
  ENDIF.

  IF CONVERT-LOWER = SPACE.
    TRANSLATE INPUT_EXTERNAL TO UPPER CASE.
  ENDIF.

  IF L_DECIFLAG = SPACE.
    PERFORM CONVERT_EX_2_IN(RSDYNSS0) USING    L_CONVERT
                                               INPUT_EXTERNAL
                                      CHANGING L_SUBRC L_ERROR
                                               OUTPUT_INTERNAL.
  ELSE.
    PERFORM CONVERT_EX_2_IN(RSDYNSS0) USING    L_CONVERT
                                               INPUT_EXTERNAL
                                      CHANGING L_SUBRC L_ERROR
                                               <L_INTERNAL>.
    IF L_SUBRC = 0  .
      OUTPUT_INTERNAL = <L_INTERNAL>.
    ENDIF.
  ENDIF.

  IF L_SUBRC NE 0.
    PERFORM CONVERT_ERROR USING L_ERROR L_CONVERT L_SUBRC.
  ENDIF.

ENDFUNCTION.
