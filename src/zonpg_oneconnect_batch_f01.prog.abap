*----------------------------------------------------------------------*
***INCLUDE ZONPG_ONECONNECT_BATCH_F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_variant_values
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_variant_values .


  DATA: lo_interpreter TYPE REF TO zoncl_dynamic_interpreter.

  DATA: lt_variant     TYPE STANDARD TABLE OF zonta_oc_variant,
        ls_variant     LIKE LINE OF lt_variant,
        lv_varname     TYPE tvarvc-name,
        lt_range       TYPE zonst_oc_rsparams,
        ls_range       TYPE zonst_oc_date,
        lt_where_tmp   TYPE rsds_twhere,
        lt_where_whole TYPE rsds_twhere,
        lt_range_whole TYPE zontt_oc_rsparams_tt. "zontt_oc_date.

  DATA: lt_filters   TYPE TABLE OF zonta_oc_filters,
*          lt_relations TYPE TABLE OF zonta_relations,
        ls_relations TYPE zonta_relations,
        ls_cond_tab  LIKE LINE OF lt_where_whole,
        lt_where     TYPE rsds_where_tab,
        ls_line      TYPE rsdswhere,
        lv_first     TYPE abap_bool,
        lt_relations TYPE STANDARD TABLE OF zonta_relations,
        ls_cond      TYPE rsds_where.


  SELECT *
    FROM zonta_oc_variant
    INTO TABLE lt_variant
    WHERE domainv       = p_domain
      AND business_proc = p_busine
      AND variant       = p_var.

  READ TABLE lt_variant INTO ls_variant INDEX 1.
  IF sy-subrc = 0 AND ls_variant-variant_type = 'D'.
* Dynamic variant
    CREATE OBJECT lo_interpreter.
    LOOP AT lt_variant INTO ls_variant.
      "TVARVC selection
      IF ls_variant-vtype = 'T'.

        lv_varname = ls_variant-description.

        CALL METHOD lo_interpreter->get_dynamic_variable
          EXPORTING
            iv_varname   = lv_varname
            iv_tabname   = ls_variant-tabname
            iv_fieldname = ls_variant-fieldname
          IMPORTING
            et_range     = lt_range
            et_where     = lt_where_tmp
          CHANGING
            et_where_all = lt_where_whole.

        " DYNAMIC variable
      ELSE.

        CALL METHOD lo_interpreter->get_dynamic_date
          EXPORTING
            iv_tabname   = ls_variant-tabname
            iv_fieldname = ls_variant-fieldname
            iv_varname   = ls_variant-sapvar
            iv_vtype     = ls_variant-vtype
            iv_offset1   = ls_variant-val1
            iv_offset2   = ls_variant-val2
            iv_sign1     = ls_variant-sign1
            iv_sign2     = ls_variant-sign2
          IMPORTING
*           es_range     = lt_range
            et_where     = lt_where_tmp
          CHANGING
            et_where_all = lt_where_whole.
      ENDIF.
    ENDLOOP.

    gt_where_cond_tab[] = lt_where_whole[].
* Variant with values
  ELSE.


    " 1. Get filters
    SELECT *
      INTO TABLE lt_filters
      FROM zonta_oc_filters
      WHERE domainv       = p_domain
        AND business_proc = p_busine
        AND variant       = p_var.

    IF sy-subrc = 0.

      " 2. Get relations
      SELECT *
        INTO TABLE lt_relations
        FROM zonta_relations
        WHERE domainv       = p_domain
          AND business_proc = p_busine.

      " 3. Process filters grouped by TABNAME
      SORT lt_filters BY tabname.
      LOOP AT lt_filters ASSIGNING FIELD-SYMBOL(<fs_filter>)
           GROUP BY ( tabname = <fs_filter>-tabname ).

        CLEAR: lt_where, ls_cond_tab, lv_first.

        " Opening (
        APPEND VALUE rsdswhere( line = '(' ) TO lt_where.

        LOOP AT GROUP <fs_filter> ASSIGNING FIELD-SYMBOL(<fs_group>).

          READ TABLE lt_relations WITH KEY tabname = <fs_group>-tabname
                                  INTO ls_relations.
          IF sy-subrc NE 0.
            CONTINUE.
          ENDIF.

          " Add condition
          IF lv_first = abap_false.
            APPEND VALUE rsdswhere( line = <fs_group>-where_clause ) TO lt_where.
            lv_first = abap_true.
          ELSE.
            " If OR is in clause, keep as-is
            IF <fs_group>-where_clause CS 'OR'.
              APPEND VALUE rsdswhere( line = <fs_group>-where_clause ) TO lt_where.
            ELSE.
              APPEND VALUE rsdswhere( line = 'AND' ) TO lt_where.
              APPEND VALUE rsdswhere( line = <fs_group>-where_clause ) TO lt_where.
            ENDIF.
          ENDIF.

        ENDLOOP.

        " Closing )
        APPEND VALUE rsdswhere( line = ')' ) TO lt_where.

        " Fill GT_COND_TAB row
        ls_cond_tab-tablename = <fs_filter>-tabname.
        ls_cond_tab-where_tab = lt_where.
        APPEND ls_cond_tab TO lt_where_whole.

      ENDLOOP.
    ENDIF.
    gt_where_cond_tab[] = lt_where_whole[].
  ENDIF.



ENDFORM.
