FUNCTION ZONFM_RS_CHECK_CONV_EX_2_IN.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(INPUT_EXTERNAL) TYPE  C
*"     VALUE(TABLE_FIELD) LIKE  TABFIELD STRUCTURE  TABFIELD
*"     REFERENCE(QUERY) OPTIONAL
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
*"----------------------------------------------------------------------

  DATA L_SUBRC LIKE SY-SUBRC.
  DATA L_ERROR LIKE RSCONVERR.
  DATA L_CONVERT LIKE RSCONVERT.
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

* Feld im DDIC, besorge Feldinformationen
  SUPPLY TABLENAME = TABLE_FIELD-TABNAME
         FIELDNAME = TABLE_FIELD-FIELDNAME
            TO CONTEXT L_CTX_DD.
  DEMAND CONVERT     = L_CONVERT
         FROM CONTEXT L_CTX_DD
         MESSAGES INTO L_MSG.
  IF SY-SUBRC NE 0.
    RAISE INVALID_FIELDNAME.
  ENDIF.

  if l_convert-clength > 255.
    l_convert-clength = 255.
  endif.
* Bastle Outputfield
  IF L_CONVERT-TYPE EQ 'I' OR
* Integer
     L_CONVERT-TYPE EQ 's' OR
*    2 Byte Integer mit Vorzeichen
     L_CONVERT-TYPE EQ 'b'.
*    1 Byte Integer ohne Vorzeichen
    ASSIGN: L_INT_LOW  TO <L_FIELD>.
  ELSEIF L_CONVERT-TYPE = 'F'.
* Float
    ASSIGN: L_FLT_LOW  TO <L_FIELD>.
  ELSEIF L_CONVERT-TYPE = 'a'.
*   DECFLOAT16
    ASSIGN: L_DF16_LOW  TO <L_FIELD>.
  ELSEIF L_CONVERT-TYPE = 'e'.
*   DECFLOAT34
    ASSIGN: L_DF34_LOW  TO <L_FIELD>.
  ELSEIF L_CONVERT-TYPE = '8'.
*   INT8
    ASSIGN: L_INT8  TO <L_FIELD>.
  ELSEIF L_CONVERT-TYPE = 'p'.
*   UTCL
    ASSIGN: L_UTCL  TO <L_FIELD>.
  ELSE.
    IF L_CONVERT-TYPE NE 'P'.
      ASSIGN: L_CIN_LOW(L_CONVERT-cLENGTH)  TO <L_FIELD>
                 TYPE L_CONVERT-TYPE.
    ELSE.
      IF L_CONVERT-cLENGTH > 8.
        class cl_abap_char_utilities definition load.
        if cl_abap_char_utilities=>charsize > 1.
          L_CONVERT-cLENGTH = 8.
        endif.
      ENDIF.
      ASSIGN: L_CIN_LOW(L_CONVERT-cLENGTH)  TO <L_FIELD>
                    TYPE     L_CONVERT-TYPE
                    DECIMALS L_CONVERT-DECIMALS.
    ENDIF.
  ENDIF.

  L_OLENGTH = STRLEN( INPUT_EXTERNAL ).
  IF L_OLENGTH > L_CONVERT-OLENGTH.
    IF L_CONVERT-TYPE NE 'F'
           OR L_CONVERT-OLENGTH > MAX_FLTP_OLENGTH.
      MESSAGE E861 WITH INPUT_EXTERNAL L_CONVERT-OLENGTH
                   RAISING INPUT_TOO_LONG.
    ELSE.
      L_CONVERT-OLENGTH = L_OLENGTH.
    ENDIF.
  ENDIF.

  IF L_CONVERT-LOWER = SPACE.
    TRANSLATE INPUT_EXTERNAL TO UPPER CASE.
  ENDIF.

  PERFORM CONVERT_EX_2_IN(RSDYNSS0) USING    L_CONVERT
                                             INPUT_EXTERNAL
                                    CHANGING L_SUBRC L_ERROR
                                             <L_FIELD>.
  if query is initial.
    INPUT_I_FORMAT = <L_FIELD>.
  else.
    move <l_field> to input_i_format(l_convert-where_leng).
  endif.
  IF L_SUBRC NE 0.
    PERFORM CONVERT_ERROR USING L_ERROR L_CONVERT L_SUBRC.
  ENDIF.

ENDFUNCTION.
