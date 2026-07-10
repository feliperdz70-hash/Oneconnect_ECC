class ZONCL_DYNAMIC_INTERPRETER definition
  public
  final
  create public .

public section.

  types TT_VARIANT_POST type ZONTT_OC_VAR_IT .

  methods GET_DYNAMIC_DATE
    importing
      !IV_TABNAME type TABNAME
      !IV_FIELDNAME type ZONDE_FIELDM
      !IV_VARNAME type ZONDE_OC_SAPVAR
      !IV_VTYPE type ZONDE_OC_RSVARSVAR
      !IV_OFFSET1 type ZONDE_OFFSET1 optional
      !IV_OFFSET2 type ZONDE_OFFSET2 optional
      !IV_SIGN1 type ZONDE_SIGN default '+'
      !IV_SIGN2 type ZONDE_SIGN default '+'
    exporting
      !ET_RANGE type ZONST_OC_RSPARAMS
      !ET_WHERE type RSDS_TWHERE
      !ES_RANGE type ZONST_OC_DATE
    changing
      !ET_WHERE_ALL type RSDS_TWHERE optional
      !ET_RANGE_ALL type ZONTT_OC_RSPARAMS_TT optional .
  methods GET_DYNAMIC_VARIABLE
    importing
      !IV_VARNAME type TVARVC-NAME
      !IV_TABNAME type TABNAME
      !IV_FIELDNAME type ZONDE_FIELDM
    exporting
      !ET_RANGE type ZONST_OC_RSPARAMS
      !ET_WHERE type RSDS_TWHERE
    changing
      !ET_WHERE_ALL type RSDS_TWHERE optional
      !ET_RANGE_ALL type ZONTT_OC_RSPARAMS_TT optional .
  methods JOIN_WHERE_CONDITIONS
    importing
      !IT_WHERE type RSDS_TWHERE
      !IT_RANGE type ZONST_OC_RSPARAMS optional
    changing
      !ET_WHERE_ALL type RSDS_TWHERE
      !ET_RANGE_ALL type ZONTT_OC_RSPARAMS_TT optional .
  methods GET_DYNAMIC_DATETIME
    importing
      !IS_VARIANT type ZONTA_OC_VARIANT
      !IT_VARIANT_POS type TT_VARIANT_POST optional
    exporting
      !ET_RANGE type ZONST_OC_RSPARAMS
      !ET_WHERE type RSDS_TWHERE
    changing
      !ET_WHERE_ALL type RSDS_TWHERE optional
      !ET_RANGE_ALL type ZONTT_OC_RSPARAMS_TT optional .
protected section.
private section.
ENDCLASS.



CLASS ZONCL_DYNAMIC_INTERPRETER IMPLEMENTATION.


METHOD get_dynamic_date.

  DATA: lv_today    TYPE sy-datum, "VALUE sy-datum,
        lv_first    TYPE sy-datum,
        lv_last     TYPE sy-datum,
        lv_year(4)  TYPE c,
        lv_month(2) TYPE c,
        lv_off1     TYPE i,
        lv_off2     TYPE i.
  DATA: lv_timestamp     TYPE timestamp,
        lv_timestamp_utc TYPE timestamp.


  DATA: ls_range  TYPE zonst_oc_rsparams,
        ls_where  TYPE rsdswhere,
        lt_where  TYPE rsds_where_tab,
        ls_wheref TYPE rsds_where.

data lv_low type tvarvc-low.

  CLEAR: es_range, et_where.

  "--- decide base date depending on iv_vtype
  CASE iv_vtype.
    WHEN 'D'.  " Local date
      " Convert UTC to local user date
      GET TIME STAMP FIELD lv_timestamp_utc.        " current UTC timestamp
      CONVERT TIME STAMP lv_timestamp_utc TIME ZONE sy-zonlo INTO DATE lv_today.
    WHEN 'X'.  " System date (can differ in some setups)
      lv_today = sy-datum.  " same here, but could be replaced with system UTC date if required
    WHEN 'T'.  " Table variable
      " For T you would read from TVARVC instead of using sy-datum
*      SELECT SINGLE low INTO @DATA(lv_low)
      SELECT SINGLE low INTO lv_low
        FROM tvarvc
*        WHERE name = @iv_varname.
        WHERE name = iv_varname.
      lv_today = lv_low.
    WHEN OTHERS.
      lv_today = sy-datum.
  ENDCASE.

  "--- normalize offsets with signs
  IF iv_sign1 = '-'.
    lv_off1 = - iv_offset1.
  ELSE.
    lv_off1 = iv_offset1.
  ENDIF.

  IF iv_sign2 = '-'.
    lv_off2 = - iv_offset2.
  ELSE.
    lv_off2 = iv_offset2.
  ENDIF.

  CASE iv_varname.

    WHEN 'RS_VARI_V_TODAY'.                        " Current Date (+/- days)
      es_range-date_from = lv_today + lv_off1.
      es_range-date_to   = lv_today + lv_off1.

    WHEN 'RS_VARI_V_TODAY_XWD'.                    " Today +/- Workdays
      " Workday logic skipped, treat as calendar days
      es_range-date_from = lv_today + lv_off1.
      es_range-date_to   = lv_today + lv_off1.

*    WHEN 'RS_VARI_V_WDAYS_UP_TO_NOW'.              " From month start to today DB VarFIX
*      lv_year  = lv_today(4).
*      lv_month = lv_today+4(2).
*      CONCATENATE lv_year lv_month '01' INTO lv_first.
*      es_range-date_from = lv_first.
*      es_range-date_to   = lv_today.
    WHEN 'RS_VARI_V_WDAYS_UP_TO_NOW'.              " Today - offset to today
      es_range-date_from = lv_today + lv_off1.
      es_range-date_to   = lv_today.

    WHEN 'RS_VARI_V_ACTUAL_MONTH'.                 " Current Month
      lv_year  = lv_today(4).
      lv_month = lv_today+4(2).
      CONCATENATE lv_year lv_month '01' INTO lv_first.

      CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
        EXPORTING
          day_in            = lv_first
        IMPORTING
          last_day_of_month = lv_last.

      es_range-date_from = lv_first.
      es_range-date_to   = lv_last.

    WHEN 'RS_VARI_V_LAST_MONTH'.                   " Previous Month
      lv_year  = lv_today(4).
      lv_month = lv_today+4(2).

      " shift one month back
      CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
        EXPORTING
          date      = lv_today
          days      = 0
          months    = 1
          signum    = '-'
          years     = 0
        IMPORTING
          calc_date = lv_first.


      lv_year  = lv_first(4).
      lv_month = lv_first+4(2).
      CONCATENATE lv_year lv_month '01' INTO lv_first.

      CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
        EXPORTING
          day_in            = lv_first
        IMPORTING
          last_day_of_month = lv_last.

      es_range-date_from = lv_first.
      es_range-date_to   = lv_last.

    WHEN 'RS_VARI_V_NEXT_MONTH'.                   " Next Month
      CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
        EXPORTING
          date      = lv_today
          days      = 0
          months    = 1
          signum    = '+'
          years     = 0
        IMPORTING
          calc_date = lv_first.


      lv_year  = lv_first(4).
      lv_month = lv_first+4(2).
      CONCATENATE lv_year lv_month '01' INTO lv_first.

      CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
        EXPORTING
          day_in            = lv_first
        IMPORTING
          last_day_of_month = lv_last.

      es_range-date_from = lv_first.
      es_range-date_to   = lv_last.

    WHEN 'RS_VARI_V_ACTUAL_YEAR'.                  " Current Year
      lv_year = lv_today(4).
      CONCATENATE lv_year '0101' INTO lv_first.
      CONCATENATE lv_year '1231' INTO lv_last.

      es_range-date_from = lv_first.
      es_range-date_to   = lv_last.

    WHEN 'RS_VARI_V_DYNDATE_FROM_TO'.              " Current date -xxx / +yyy
      es_range-date_from = lv_today + lv_off1.
      es_range-date_to   = lv_today + lv_off2.

    WHEN OTHERS.
      CLEAR es_range.
  ENDCASE.


  "--- also fill ET_RANGE (RSparams-style)
  CLEAR ls_range.
  ls_range-tabname = iv_tabname.
  ls_range-selname = iv_fieldname.
  ls_range-kind    = 'S'.
  ls_range-sign    = 'I'.
  ls_range-option  = 'BT'.
  ls_range-low     = es_range-date_from.
  ls_range-high    = es_range-date_to.
*  APPEND ls_range TO et_range.

  "--- also fill ET_WHERE (RSDS_TWHERE-style)
  CLEAR ls_where.
  ls_where-line = '('.
  APPEND ls_where TO lt_where.

*  CLEAR ls_where.
*  ls_where-line = |{ iv_fieldname } BETWEEN '{ es_range-date_from }' AND '{ es_range-date_to }'|.
*  APPEND ls_where TO lt_where.

  CLEAR ls_where.
  ls_where-line = |{ iv_tabname }{ '~' }{ iv_fieldname } BETWEEN '{ es_range-date_from }' AND '{ es_range-date_to }'|.
  APPEND ls_where TO lt_where.


  CLEAR ls_where.
  ls_where-line = ')'.
  APPEND ls_where TO lt_where.

  CLEAR ls_wheref.
  ls_wheref-tablename = iv_tabname.
  ls_wheref-where_tab = lt_where.
  APPEND ls_wheref TO et_where.


  CALL METHOD me->join_where_conditions
    EXPORTING
      it_where     = et_where
      it_range     = ls_range
    CHANGING
      et_where_all = et_where_all
      et_range_all = et_range_all.


ENDMETHOD.


  METHOD get_dynamic_datetime.

    DATA: lv_timestamp     TYPE timestamp,
          lv_timestamp_utc TYPE timestamp.

    DATA: lv_today    TYPE sy-datum.

    DATA: ls_range  TYPE zonst_oc_rsparams,
          ls_where  TYPE rsdswhere,
          lt_where  TYPE rsds_where_tab,
          ls_wheref TYPE rsds_where.

    CLEAR: et_where.

*    "--- decide base date depending on iv_vtype
*    CASE is_variant-vtype.
*      WHEN 'D'.  " Local date
*        " Convert UTC to local user date
*        GET TIME STAMP FIELD lv_timestamp_utc.        " current UTC timestamp
*        CONVERT TIME STAMP lv_timestamp_utc TIME ZONE sy-zonlo INTO DATE lv_today.
*      WHEN 'X'.  " System date (can differ in some setups)
*        lv_today = sy-datum.  " same here, but could be replaced with system UTC date if required
*      WHEN 'T'.  " Table variable
*        " For T you would read from TVARVC instead of using sy-datum
*        SELECT SINGLE low INTO @DATA(lv_low)
*          FROM tvarvc
*          WHERE name = @is_variant-sapvar.
*        lv_today = lv_low.
*      WHEN OTHERS.
*        lv_today = sy-datum.
*    ENDCASE.

**********************************************************************
    CLEAR ls_range.

    DATA lv_date TYPE rsdatrange-low.
    DATA lv_time TYPE sy-uzeit.
    DATA lt_datrange TYPE STANDARD TABLE OF rsdatrange.
    DATA lt_timerange TYPE STANDARD TABLE OF rstimerange.
    DATA ls_datrange TYPE rsdatrange.
    DATA ls_timerange TYPE rstimerange.

    DATA lv_sys(1).
    DATA lt_intrange TYPE STANDARD TABLE OF rsintrange.
    DATA ls_intrange TYPE rsintrange.

    DATA ls_var_pos TYPE zonta_oc_var_it.

    LOOP AT it_variant_pos INTO ls_var_pos.
      MOVE-CORRESPONDING ls_var_pos TO ls_intrange.
      ls_intrange-option = ls_var_pos-opti.
      APPEND ls_intrange TO lt_intrange.
    ENDLOOP.
*    IF is_variant-val1 IS NOT INITIAL.
*      ls_intrange-sign = 'I'.
*      IF is_variant-val2 IS NOT INITIAL.
*        ls_intrange-option  = 'BT'.
*      ELSE.
*        ls_intrange-option  = 'EQ'.
*      ENDIF.
*      ls_intrange-low = is_variant-val1.
*      IF is_variant-sign1 = '-'.
*        ls_intrange-low = ls_intrange-low * -1.
*      ENDIF.
*      ls_intrange-high = is_variant-val2.
*      IF is_variant-sign2 = '-'.
*        ls_intrange-high = ls_intrange-high * -1.
*      ENDIF.
*      APPEND ls_intrange TO lt_intrange.
*    ENDIF.

    IF is_variant-vtype EQ 'X' OR is_variant-vtype EQ 'Y'.
      lv_sys = 'X'.
    ELSE.
      CLEAR lv_sys.
    ENDIF.

    IF is_variant-vtype = 'D' OR is_variant-vtype EQ 'X'. " DATE

      TRY.

          " VTYPE F (ONE LOW)
          CALL FUNCTION is_variant-sapvar
            EXPORTING
              systime    = lv_sys
            IMPORTING
              p_date     = lv_date
            TABLES
              p_intrange = lt_intrange
            EXCEPTIONS
              OTHERS     = 4.

          ls_range-low = lv_date.
*      ls_range-high = '00000000'.

        CATCH cx_root.

          " VTYPE S (LOW - HIGH)
          CALL FUNCTION is_variant-sapvar
            EXPORTING
              systime    = lv_sys
            TABLES
              p_datetab  = lt_datrange
              p_intrange = lt_intrange
            EXCEPTIONS
              OTHERS     = 4.

          READ TABLE lt_datrange INTO ls_datrange INDEX 1.
          IF sy-subrc EQ 0.
            ls_range-low  = ls_datrange-low.
            ls_range-high  = ls_datrange-high.
          ENDIF.

      ENDTRY.

    ELSEIF is_variant-vtype = 'Z' OR is_variant-vtype = 'Y'. " TIME

      TRY.

          " VTYPE F (ONE LOW)
          CALL FUNCTION is_variant-sapvar
            EXPORTING
              systime    = lv_sys
            IMPORTING
              p_time     = lv_time
            TABLES
              p_intrange = lt_intrange
            EXCEPTIONS
              OTHERS     = 4.

          ls_range-low = lv_time.
*      ls_range-high = '000000'.

        CATCH cx_root.
          " VTYPE S (LOW - HIGH)
          CALL FUNCTION is_variant-sapvar
            EXPORTING
              systime    = lv_sys
            TABLES
              p_datetab  = lt_timerange
              p_intrange = lt_intrange
            EXCEPTIONS
              OTHERS     = 4.

          READ TABLE lt_timerange INTO ls_timerange INDEX 1.
          IF sy-subrc EQ 0.
            ls_range-low = ls_timerange-low.
            ls_range-high  = ls_timerange-high.
          ENDIF.

      ENDTRY.

    ENDIF.

    "--- also fill ET_RANGE (RSparams-style)
    ls_range-option  = is_variant-opti.
    ls_range-sign    = is_variant-sign.

    ls_range-tabname = is_variant-tabname.
    ls_range-selname = is_variant-fieldname.
    ls_range-kind    = 'S'.
*    ls_range-sign    = 'I'.
    IF ls_range-high IS NOT INITIAL AND ls_range-option IS INITIAL.
*      ls_range-option  = 'EQ'.
*    ELSE.
      ls_range-option  = 'BT'.
    ENDIF.
    IF ls_range-low IS NOT INITIAL AND ls_range-option IS INITIAL.
      ls_range-option  = 'EQ'.
    ENDIF.
*  APPEND ls_range TO et_range.

    "--- also fill ET_WHERE (RSDS_TWHERE-style)
    CLEAR ls_where.
    ls_where-line = '('.
    APPEND ls_where TO lt_where.

*  CLEAR ls_where.
*  ls_where-line = |{ iv_fieldname } BETWEEN '{ es_range-date_from }' AND '{ es_range-date_to }'|.
*  APPEND ls_where TO lt_where.

    CLEAR ls_where.
    IF ls_range-option EQ 'BT'.
      ls_where-line = |{ is_variant-tabname }{ '~' }{ is_variant-fieldname } BETWEEN '{ ls_range-low }' AND '{ ls_range-high }'|.
    ELSE.
      ls_where-line = |{ is_variant-tabname }{ '~' }{ is_variant-fieldname } { ls_range-option } '{ ls_range-low }'|.
    ENDIF.

    APPEND ls_where TO lt_where.


    CLEAR ls_where.
    ls_where-line = ')'.
    APPEND ls_where TO lt_where.

    CLEAR ls_wheref.
    ls_wheref-tablename = is_variant-tabname.
    ls_wheref-where_tab = lt_where.
    APPEND ls_wheref TO et_where.


    CALL METHOD me->join_where_conditions
      EXPORTING
        it_where     = et_where
        it_range     = ls_range
      CHANGING
        et_where_all = et_where_all
        et_range_all = et_range_all.


  ENDMETHOD.


METHOD get_dynamic_variable.


  DATA: lt_tvarvc TYPE STANDARD TABLE OF tvarvc,
        ls_tvarvc TYPE tvarvc,
        ls_range  TYPE zonst_oc_rsparams,
        ls_where  TYPE rsdswhere,
        lt_where  TYPE rsds_where_tab,
        ls_wheref LIKE LINE OF et_where,
        lv_field  TYPE string,
        lt_group  TYPE rsds_where_tab,
        ls_tmp    TYPE rsdswhere,
        lv_idx    TYPE i.

  CLEAR: et_range, et_where, lt_where.

  " 1. Fetch all entries for the variable
  SELECT *
    FROM tvarvc
    INTO TABLE lt_tvarvc
    WHERE name = iv_varname.

  SORT lt_tvarvc BY name.

  LOOP AT lt_tvarvc INTO ls_tvarvc.

    " --- Fill RSparams (range style)
    CLEAR ls_range.
    ls_range-selname = iv_varname.
    ls_range-kind    = ls_tvarvc-type.   " 'P' or 'S'
    ls_range-sign    = ls_tvarvc-sign.   " valid only for S
    ls_range-option  = ls_tvarvc-opti.   " valid only for S
    ls_range-low     = ls_tvarvc-low.
    ls_range-high    = ls_tvarvc-high.

    " Normalize Parameters (P → always EQ/I)
    IF ls_tvarvc-type = 'P'.
      ls_range-sign   = 'I'.
      ls_range-option = 'EQ'.
    ENDIF.

*    APPEND ls_range TO et_range.

    " --- Flush previous group if field changes
    IF lv_field IS NOT INITIAL AND lv_field <> iv_fieldname.
      IF lt_group IS NOT INITIAL.
        " Output the group with OR logic
        CLEAR ls_where.
        ls_where-line = '('.
        APPEND ls_where TO lt_where.

        CLEAR lv_idx.
        LOOP AT lt_group INTO ls_tmp.
          lv_idx = lv_idx + 1.

**11.04.26 frg no poner 'OR' INICIA
*          ls_where = ls_tmp. " first condition as-is

          IF lv_idx = 1.
            ls_where = ls_tmp. " first condition as-is
          ELSE.
            CLEAR ls_where.
            ls_where-line = |OR { ls_tmp-line }|.
          ENDIF.
**11.04.26 frg no poner 'OR' TERMINA
          APPEND ls_where TO lt_where.
        ENDLOOP.

        CLEAR ls_where.
        ls_where-line = ')'.
        APPEND ls_where TO lt_where.

        CLEAR lt_group.
      ENDIF.
    ENDIF.

    " --- Build condition for this TVARVC entry
    CLEAR ls_where.

    IF ls_tvarvc-type = 'P'.
      " Parameter → always EQ LOW
      ls_where-line = |{ iv_fieldname } EQ '{ ls_tvarvc-low }'|.
    ELSE.
      CASE ls_tvarvc-opti.
        WHEN 'EQ'. ls_where-line = |{ iv_fieldname } EQ '{ ls_tvarvc-low }'|.
        WHEN 'NE'. ls_where-line = |{ iv_fieldname } NE '{ ls_tvarvc-low }'|.
        WHEN 'GT'. ls_where-line = |{ iv_fieldname } GT '{ ls_tvarvc-low }'|.
        WHEN 'LT'. ls_where-line = |{ iv_fieldname } LT '{ ls_tvarvc-low }'|.
        WHEN 'GE'. ls_where-line = |{ iv_fieldname } GE '{ ls_tvarvc-low }'|.
        WHEN 'LE'. ls_where-line = |{ iv_fieldname } LE '{ ls_tvarvc-low }'|.
        WHEN 'BT'. ls_where-line = |{ iv_fieldname } BETWEEN '{ ls_tvarvc-low }' AND '{ ls_tvarvc-high }'|.
        WHEN 'NB'. ls_where-line = |NOT ( { iv_fieldname } BETWEEN '{ ls_tvarvc-low }' AND '{ ls_tvarvc-high }' )|.
        WHEN 'CP'. ls_where-line = |{ iv_fieldname } LIKE '{ ls_tvarvc-low }'|.
        WHEN 'NP'. ls_where-line = |{ iv_fieldname } NOT LIKE '{ ls_tvarvc-low }'|.
      ENDCASE.
    ENDIF.

    " --- SIGN = E (exclude)
    IF ls_tvarvc-sign = 'E'.
      ls_where-line = |NOT ( { ls_where-line } )|.
    ENDIF.

    APPEND ls_where TO lt_group.
    lv_field = iv_fieldname.

    " --- At end of varname group
    AT END OF name.
      IF lt_group IS NOT INITIAL.
        " Output the group with OR logic
        CLEAR ls_where.
        ls_where-line = '('.
        APPEND ls_where TO lt_where.

        CLEAR lv_idx.
        LOOP AT lt_group INTO ls_tmp.
          lv_idx = lv_idx + 1.
**11.04.26 frg no poner 'OR' INICIA
**          ls_where = ls_tmp.

          IF lv_idx = 1.
            ls_where = ls_tmp.
          ELSE.
            CLEAR ls_where.
            ls_where-line = |OR { ls_tmp-line }|.
          ENDIF.
**11.04.26 frg no poner 'OR' TERMINA
          APPEND ls_where TO lt_where.
        ENDLOOP.

        CLEAR ls_where.
        ls_where-line = ')'.
        APPEND ls_where TO lt_where.

        CLEAR lt_group.
      ENDIF.
    ENDAT.

  ENDLOOP.

  " --- Assign WHERE table to export
  CLEAR ls_wheref.
  ls_wheref-tablename = iv_tabname.
  ls_wheref-where_tab = lt_where.
  APPEND ls_wheref TO et_where.

  " --- Merge with global WHERE accumulator
  CALL METHOD me->join_where_conditions
    EXPORTING
      it_where     = et_where
      it_range     = ls_range
    CHANGING
      et_where_all = et_where_all
      et_range_all = et_range_all.

ENDMETHOD.


**METHOD get_dynamic_variable.
**
**  DATA: lt_tvarvc TYPE STANDARD TABLE OF tvarvc,
**        ls_tvarvc TYPE tvarvc,
**        ls_range  TYPE rsparams,
**        ls_where  TYPE rsdswhere,
**        lt_where  TYPE rsds_where_tab,
**        ls_wheref LIKE LINE OF et_where,
**        lv_field  TYPE string,
**        lt_group  TYPE rsds_where_tab,
**        ls_tmp    TYPE rsdswhere,
**        lv_idx    TYPE i.
**
**  CLEAR: et_range, et_where, lt_where.
**
**  " 1. Fetch all entries for the variable
**  SELECT *
**    FROM tvarvc
**    INTO TABLE lt_tvarvc
**    WHERE name = iv_varname.
**
**  SORT lt_tvarvc BY name.
**
**  LOOP AT lt_tvarvc INTO ls_tvarvc.
**
**    " --- Fill RSparams (range style)
**    CLEAR ls_range.
**    ls_range-selname = iv_varname.
**    ls_range-kind    = ls_tvarvc-type.
**    ls_range-sign    = ls_tvarvc-sign.
**    ls_range-option  = ls_tvarvc-opti.
**    ls_range-low     = ls_tvarvc-low.
**    ls_range-high    = ls_tvarvc-high.
**    APPEND ls_range TO et_range.
**
**    " --- Flush previous group if field changes
**    IF lv_field IS NOT INITIAL AND lv_field <> iv_fieldname.
**      IF lt_group IS NOT INITIAL.
**        " Output the group with OR logic
**        CLEAR ls_where.
**        ls_where-line = '('.
**        APPEND ls_where TO lt_where.
**
**        CLEAR lv_idx.
**        LOOP AT lt_group INTO ls_tmp.
**          lv_idx = lv_idx + 1.
**          IF lv_idx = 1.
**            ls_where = ls_tmp. " first condition as-is
**          ELSE.
**            CLEAR ls_where.
**            ls_where-line = |OR { ls_tmp-line }|.
**          ENDIF.
**          APPEND ls_where TO lt_where.
**        ENDLOOP.
**
**        CLEAR ls_where.
**        ls_where-line = ')'.
**        APPEND ls_where TO lt_where.
**
**        CLEAR lt_group.
**      ENDIF.
**    ENDIF.
**
**    " --- Build condition for this TVARVC entry
**    CLEAR ls_where.
**    CASE ls_tvarvc-opti.
**      WHEN 'EQ'. ls_where-line = |{ iv_fieldname } EQ '{ ls_tvarvc-low }'|.
**      WHEN 'NE'. ls_where-line = |{ iv_fieldname } NE '{ ls_tvarvc-low }'|.
**      WHEN 'GT'. ls_where-line = |{ iv_fieldname } GT '{ ls_tvarvc-low }'|.
**      WHEN 'LT'. ls_where-line = |{ iv_fieldname } LT '{ ls_tvarvc-low }'|.
**      WHEN 'GE'. ls_where-line = |{ iv_fieldname } GE '{ ls_tvarvc-low }'|.
**      WHEN 'LE'. ls_where-line = |{ iv_fieldname } LE '{ ls_tvarvc-low }'|.
**      WHEN 'BT'. ls_where-line = |{ iv_fieldname } BETWEEN '{ ls_tvarvc-low }' AND '{ ls_tvarvc-high }'|.
**      WHEN 'NB'. ls_where-line = |NOT ( { iv_fieldname } BETWEEN '{ ls_tvarvc-low }' AND '{ ls_tvarvc-high }' )|.
**      WHEN 'CP'. ls_where-line = |{ iv_fieldname } LIKE '{ ls_tvarvc-low }'|.
**      WHEN 'NP'. ls_where-line = |{ iv_fieldname } NOT LIKE '{ ls_tvarvc-low }'|.
**    ENDCASE.
**
**    " --- SIGN = E
**    IF ls_tvarvc-sign = 'E'.
**      ls_where-line = |NOT ( { ls_where-line } )|.
**    ENDIF.
**
**    APPEND ls_where TO lt_group.
**    lv_field = iv_fieldname.
**
**    " --- At end of varname group
**    AT END OF name.
**      IF lt_group IS NOT INITIAL.
**        " Output the group with OR logic
**        CLEAR ls_where.
**        ls_where-line = '('.
**        APPEND ls_where TO lt_where.
**
**        CLEAR lv_idx.
**        LOOP AT lt_group INTO ls_tmp.
**          lv_idx = lv_idx + 1.
**          IF lv_idx = 1.
**            ls_where = ls_tmp.
**          ELSE.
**            CLEAR ls_where.
**            ls_where-line = |OR { ls_tmp-line }|.
**          ENDIF.
**          APPEND ls_where TO lt_where.
**        ENDLOOP.
**
**        CLEAR ls_where.
**        ls_where-line = ')'.
**        APPEND ls_where TO lt_where.
**
**        CLEAR lt_group.
**      ENDIF.
**    ENDAT.
**
**  ENDLOOP.
**
**  " --- Assign WHERE table to export
**  CLEAR ls_wheref.
**  ls_wheref-tablename = iv_tabname.
**  ls_wheref-where_tab = lt_where.
**  APPEND ls_wheref TO et_where.
**
**
**  CALL METHOD me->join_where_conditions
**    IMPORTING
**      it_where     = et_where
**    CHANGING
**      et_where_all = et_where_all.
**
**
**ENDMETHOD.


*  METHOD get_dynamic_variable.
*    TYPES: BEGIN OF rsds_where,
*             tablename TYPE rsdstabs-prim_tab,
*             where_tab TYPE rsds_where_tab,
*           END OF rsds_where.
*
*    DATA(lv_first) = abap_true.
*
*    DATA: lt_tvarvc TYPE STANDARD TABLE OF tvarvc,
*          ls_tvarvc TYPE tvarvc,
*          ls_range  TYPE rsparams,
*          ls_where  TYPE rsdswhere,
*          lt_where  TYPE rsds_where_tab,
*          lt_wheref LIKE LINE OF et_where,
*          lv_prefix TYPE char5.
*
*    CLEAR et_range.
*
*    " 1. Fetch all entries for the variable
*    SELECT *
*      FROM tvarvc
*      INTO TABLE lt_tvarvc
*      WHERE name = iv_varname.
*
*    LOOP AT lt_tvarvc INTO ls_tvarvc.
*
*      CLEAR ls_range.
*      ls_range-selname = iv_varname.     " variable name
*      ls_range-kind    = ls_tvarvc-type. " 'P' or 'S'
*      ls_range-sign    = ls_tvarvc-sign. " usually 'I'
*      ls_range-option  = ls_tvarvc-opti. " EQ, BT, CP, etc.
*      ls_range-low     = ls_tvarvc-low.
*      ls_range-high    = ls_tvarvc-high.
*
*      APPEND ls_range TO et_range.
*
*      CLEAR ls_where.
*
*      " Opening parenthesis before the first condition
*      IF lv_first = abap_true.
*        lv_prefix = '('.
*        lv_first = abap_false.
*      ELSE.
*        lv_prefix = ' AND '.
*      ENDIF.
*
*      " Build WHERE line based on type/sign/option
*      CASE ls_tvarvc-opti.
*
*        WHEN 'EQ'.
*          ls_where-line = |{ lv_prefix } { iv_fieldname } EQ '{ ls_tvarvc-low }'|.
*
*        WHEN 'NE'.
*          ls_where-line = |{ lv_prefix } { iv_fieldname } NE '{ ls_tvarvc-low }'|.
*
*        WHEN 'GT'.
*          ls_where-line = |{ lv_prefix } { iv_fieldname } GT '{ ls_tvarvc-low }'|.
*
*        WHEN 'LT'.
*          ls_where-line = |{ lv_prefix } { iv_fieldname } LT '{ ls_tvarvc-low }'|.
*
*        WHEN 'GE'.
*          ls_where-line = |{ lv_prefix } { iv_fieldname } GE '{ ls_tvarvc-low }'|.
*
*        WHEN 'LE'.
*          ls_where-line = |{ lv_prefix } { iv_fieldname } LE '{ ls_tvarvc-low }'|.
*
*        WHEN 'BT'.
*          ls_where-line = |{ lv_prefix } { iv_fieldname } BETWEEN '{ ls_tvarvc-low }' AND '{ ls_tvarvc-high }'|.
*
*        WHEN 'NB'.
*          ls_where-line = |{ lv_prefix }  NOT ( { iv_fieldname } BETWEEN '{ ls_tvarvc-low }' AND '{ ls_tvarvc-high }' )|.
*
*        WHEN 'CP'.
*          ls_where-line = |{ lv_prefix } { iv_fieldname } LIKE '{ ls_tvarvc-low }'|.
*
*        WHEN 'NP'.
*          ls_where-line = |{ lv_prefix } { iv_fieldname } NOT LIKE '{ ls_tvarvc-low }'|.
*
*      ENDCASE.
*
*      " Handle SIGN = E (exclude)
*      IF ls_tvarvc-sign = 'E'.
*        ls_where-line = |{ lv_prefix } NOT ( { ls_where-line } )|.
*      ENDIF.
*
*      APPEND ls_where TO lt_where.
*
*    ENDLOOP.
*
*    " Closing parenthesis after the last condition
*    IF lt_where IS NOT INITIAL.
*      CLEAR ls_where.
*      ls_where-line = ')'.
*      APPEND ls_where TO lt_where.
*    ENDIF.
*
*    lt_wheref-tablename = iv_tabname.
*    lt_wheref-where_tab = lt_where[].
*    APPEND lt_wheref TO et_where[].
*  ENDMETHOD.


METHOD join_where_conditions.
  " IMPORTING  it_where     TYPE rsds_twhere      " new blocks
  " CHANGING   et_where_all TYPE rsds_twhere      " accumulated

  DATA: ls_newblk TYPE rsds_where,
        ls_exist  TYPE rsds_where,
        lt_all    TYPE rsds_where_tab,
        ls_line   TYPE rsdswhere,
        lv_first  TYPE abap_bool.

  DATA ls_rsdswhere TYPE rsdswhere.
  data ls_rsds_where type rsds_where.

  LOOP AT it_where INTO ls_newblk.

    " Look for existing block for same table
    READ TABLE et_where_all INTO ls_exist
         WITH KEY tablename = ls_newblk-tablename.

    IF sy-subrc = 0.
      " --- Merge with existing block ---
      CLEAR lt_all.

      " Outer open
      ls_line-line = '('.
      APPEND ls_line TO lt_all.

      lv_first = abap_true.

      " Existing conditions
      LOOP AT ls_exist-where_tab INTO ls_line.
        IF ls_line-line = '(' OR ls_line-line = ')'.
          CONTINUE.
        ENDIF.
        CLEAR ls_rsdswhere.
        IF lv_first = abap_true.
*          APPEND VALUE rsdswhere( line = |( { ls_line-line } )| ) TO lt_all.
          ls_rsdswhere-line = ls_line-line.
          APPEND ls_rsdswhere TO lt_all.
          lv_first = abap_false.
        ELSE.
*          APPEND VALUE rsdswhere( line = |AND ( { ls_line-line } )| ) TO lt_all.
          ls_rsdswhere-line = ls_line-line.
          APPEND ls_rsdswhere TO lt_all.
        ENDIF.
      ENDLOOP.

      " New conditions
      LOOP AT ls_newblk-where_tab INTO ls_line.
        IF ls_line-line = '(' OR ls_line-line = ')'.
          CONTINUE.
        ENDIF.
        CLEAR ls_rsdswhere.
        IF lv_first = abap_true.
*          APPEND value rsdswhere( LINE = |( { ls_line-line } )| ) TO lt_all.
          ls_rsdswhere-line = ls_line-line.
          APPEND ls_rsdswhere TO lt_all.
          lv_first = abap_false.
        ELSE.
*          APPEND value rsdswhere( LINE = |AND ( { ls_line-line } )| ) TO lt_all.
          ls_rsdswhere-line = ls_line-line.
          APPEND ls_rsdswhere TO lt_all.
        ENDIF.
      ENDLOOP.

      " Outer close
      CLEAR ls_rsdswhere.
*      APPEND value rsdswhere( LINE = ')' ) TO lt_all.
      ls_rsdswhere-line = ')'.
      APPEND ls_rsdswhere TO lt_all.

      " Update the existing entry
      CLEAR ls_rsds_where.
      ls_rsds_where-tablename = ls_newblk-tablename.
      ls_rsds_where-where_tab = lt_all.
*      MODIFY et_where_all FROM value rsds_where(
*               tablename = ls_newblk-tablename
*               where_tab = lt_all )
*             TRANSPORTING where_tab
*             WHERE tablename = ls_newblk-tablename.
      MODIFY et_where_all FROM ls_rsds_where
             TRANSPORTING where_tab
             WHERE tablename = ls_newblk-tablename.

    ELSE.
      " First time → just add as-is
      APPEND ls_newblk TO et_where_all.
    ENDIF.

  ENDLOOP.


  " --- merge RANGE logic ---
  IF it_range IS NOT INITIAL.
    APPEND it_range TO et_range_all.
  ENDIF.
ENDMETHOD.
ENDCLASS.
