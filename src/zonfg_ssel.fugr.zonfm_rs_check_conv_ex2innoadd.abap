FUNCTION ZONFM_RS_CHECK_CONV_EX2INNOADD.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(INPUT_EXTERNAL) TYPE  C
*"     REFERENCE(QUERY) OPTIONAL
*"     VALUE(DESCR) TYPE  RSCONVERT
*"  EXPORTING
*"     VALUE(INPUT_I_FORMAT) TYPE  C
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

  DATA L_SUBRC LIKE SY-SUBRC.
  DATA L_ERROR LIKE RSCONVERR.
  DATA L_OLENGTH LIKE RSCONVERT-OLENGTH.

  DATA L_CTX_DD TYPE CONTEXT_FREE_SEL_DD_INFO.
  DATA L_MSG    LIKE SYMSG OCCURS 0.

  DATA:    L_INT_LOW  TYPE I,
           L_FLT_LOW  TYPE F,
           L_df16_low type decfloat16,
           L_df34_low type decfloat34,
           l_int8    type p LENGTH 8 DECIMALS 0, " int8,
           l_utcl    type t, " utcl,
           L_CIN_LOW(255).

  FIELD-SYMBOLS <L_FIELD>.

  if descr-clength = 0.
    perform ileng_2_cleng in program rsdynss0
                          using    descr-TYPE
                                   descr-length
                          changing descr-clength.
  endif.

  if descr-clength > 255.
    descr-clength = 255.
  endif.
* Bastle Outputfield
  IF descr-TYPE EQ 'I' OR
* Integer
     descr-TYPE EQ 's' OR
*    2 Byte Integer mit Vorzeichen
     descr-TYPE EQ 'b'.
*    1 Byte Integer ohne Vorzeichen
    ASSIGN: L_INT_LOW  TO <L_FIELD>.
  ELSEIF descr-TYPE = 'F'.
* Float
    ASSIGN: L_FLT_LOW  TO <L_FIELD>.
  ELSEIF descr-TYPE = 'a'.
*   DECFLOAT16
    ASSIGN: L_DF16_LOW  TO <L_FIELD>.
  ELSEIF descr-TYPE = 'e'.
*   DECFLOAT34
    ASSIGN: L_DF34_LOW  TO <L_FIELD>.
  ELSEIF descr-TYPE = '8'.
*   INT8
    ASSIGN: L_INT8  TO <L_FIELD>.
  ELSEIF descr-TYPE = 'p'.
*   UTCL
    ASSIGN: L_UTCL  TO <L_FIELD>.
  ELSE.
    IF descr-TYPE NE 'P'.
      ASSIGN: L_CIN_LOW(descr-cLENGTH)  TO <L_FIELD>
                 TYPE descr-TYPE.
    ELSE.
      IF descr-cLENGTH > 8.
        if cl_abap_char_utilities=>charsize > 1.
          descr-cLENGTH = 8.
        endif.
      ENDIF.
      ASSIGN: L_CIN_LOW(descr-cLENGTH)  TO <L_FIELD>
                    TYPE     descr-TYPE
                    DECIMALS descr-DECIMALS.
    ENDIF.
  ENDIF.

  L_OLENGTH = STRLEN( INPUT_EXTERNAL ).
  IF L_OLENGTH > descr-OLENGTH.
    IF descr-TYPE NE 'F'
           OR descr-OLENGTH > MAX_FLTP_OLENGTH.
      MESSAGE E861 WITH INPUT_EXTERNAL descr-OLENGTH
                   RAISING INPUT_TOO_LONG.
    ELSE.
      descr-OLENGTH = L_OLENGTH.
    ENDIF.
  ENDIF.

  IF descr-LOWER = SPACE.
    TRANSLATE INPUT_EXTERNAL TO UPPER CASE.
  ENDIF.

  PERFORM CONVERT_EX_2_IN(RSDYNSS0) USING    descr
                                             INPUT_EXTERNAL
                                    CHANGING L_SUBRC L_ERROR
                                             <L_FIELD>.
  if query is initial.
    INPUT_I_FORMAT = <L_FIELD>.
  else.
    move <l_field> to input_i_format(descr-where_leng).
  endif.
  IF L_SUBRC NE 0.
    PERFORM CONVERT_ERROR USING L_ERROR descr L_SUBRC.
  ENDIF.

ENDFUNCTION.
