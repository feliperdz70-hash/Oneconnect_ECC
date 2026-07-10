class ZONCL_VARIANTS definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ty_f4tab,
             vtype   TYPE s_class,
             sign    TYPE twfsa-sign,
             opti    TYPE twfsa-opt,
             descr   TYPE char50, " LENGTH 50,
*             celltab TYPE lvc_t_styl,
             runt_fb TYPE  rs38l_fnam,
           END OF ty_f4tab .
*    TYPES: BEGIN OF ty_variant,
*             option TYPE raldb_opti_f4,
*             sign   TYPE raldb_sign,
**             sapvar TYPE rs38l_fnam,
*             val1   TYPE zonde_offset1,
*             sign1  TYPE zonde_sign,
*             val2   TYPE zonde_offset2,
*             sign2  TYPE zonde_sign,
*           END OF ty_variant.
*                                            cs_variant  TYPE ty_variant oPTIONAL
*                                            ct_variant  TYPE tt_variant OPTIONAL.
  types TY_VARIANT type ZONTA_OC_VAR_IT .
  types:
    tt_RSVARIVAR TYPE STANDARD TABLE OF rsvarivar .
  types:
    tt_variant   TYPE STANDARD TABLE OF zonta_oc_var_it .
  types:
    tt_f4tab      TYPE STANDARD TABLE OF ty_f4tab .
  types:
    tt_rsintrange TYPE STANDARD TABLE OF rsintrange WITH DEFAULT KEY .

  class-methods GET_TYPES
    importing
      !IV_TYPE type CHAR01 default ''
      !IV_ALV type BOOLEAN_FLG default ''
    exporting
      !ET_VALUES type TT_F4TAB
      !ES_VALUE type DDSHRETVAL .
  class-methods GET_FUNCTIONS_BY_TYPE
    importing
      !IV_TYPE type CHAR01
      !IV_KIND type RSSCR_KIND
    exporting
      !ET_VALUES type TT_RSVARIVAR .
  class-methods GET_VALUES
    importing
      !IV_TYPE type CHAR01 default ''
      !IS_VARIVAR type RSVARIVAR optional
    preferred parameter IV_TYPE
    changing
      !CT_INTRANGE type TT_RSINTRANGE optional .
  class-methods UPDATE_VARIANT
    importing
      !IV_SIGN type RALDB_SIGN
      !IV_OPTION type RALDB_OPTI_F4
      !IT_INTRANGE type TT_RSINTRANGE
      !IV_VAR_V_UUID type ZONTA_OC_VAR_IT-VAR_V_UUID
    changing
      !CT_VAR_IT type TT_VARIANT optional .
  class-methods SAVE_VARIANT_DB
    importing
      value(IT_COND_TAB) type RSDS_TWHERE
      value(IT_FIELDTAB) type RSDSFIELDS_T
      value(IT_FIELD_RANGES) type RSDS_TRANGE
      value(IT_VARIANT_POS) type ZONTA_TT_VAR_IT
      !IS_OBJ_OC type ZONTA_OBJ_OC
      !IS_VARIANT type ZONTA_OC_VARIANT
      !IV_SAVE type BOOLEAN
      value(IT_VARIANT_VALUES) type ZONTA_TT_VARIANT
    exporting
      !EV_VARIANT_EXISTS type BOOLEAN
    returning
      value(RS_SUCCESS) type BOOLEAN .
  class-methods GET_VARIANT_VALUES
    importing
      !IS_VARIANT type ZONTA_OC_VARIANT
    exporting
      !ET_RANGE type ZONST_OC_RSPARAMS
      !ET_WHERE type RSDS_TWHERE
    changing
      !ET_WHERE_ALL type RSDS_TWHERE
      !ET_RANGE_ALL type ZONTT_OC_RSPARAMS_TT .
  PROTECTED SECTION.
private section.

  types:
    TT_ZONTA_OC_VAR_IT type table of zonta_oc_var_it .

  class-methods GET_FUNC_DATE
    exporting
      !ET_VALUES type TT_RSVARIVAR .
  class-methods GET_FUNC_TIME
    exporting
      !ET_VALUES type TT_RSVARIVAR .
  class-methods POPUP_F4
    importing
      !IV_FNAME type DFIES-FIELDNAME
    exporting
      !ES_VALUE type DDSHRETVAL
    changing
      !CT_TABLE type ANY TABLE .
  class-methods IS_VALID_VARIANT
    importing
      value(IS_OBJ_OC) type ZONTA_OBJ_OC
      !IV_VARIANT type VARIANT
    exporting
      !EV_VARIANT_OLD type VARIANT
    returning
      value(RS_VALID) type BOOLEAN .
ENDCLASS.



CLASS ZONCL_VARIANTS IMPLEMENTATION.


  METHOD get_functions_by_type.

    CASE iv_type.

      WHEN 'T'.

      WHEN 'D' OR 'X'.

        get_func_date( IMPORTING et_values = et_values ).

      WHEN 'Z' OR 'Y'.

        get_func_time( IMPORTING et_values = et_values ).

    ENDCASE.

    IF iv_kind = 'P'.
      DELETE et_values WHERE vtype NE 'F'.
    ENDIF.

  ENDMETHOD.


  METHOD get_func_date.

    CALL FUNCTION 'RS_VARI_V_INIT'
      TABLES
        p_varivar = et_values.

  ENDMETHOD.


  METHOD get_func_time.

    CALL FUNCTION 'RS_VARI_V_INIT_TIME'
      TABLES
        p_varivar = et_values.

  ENDMETHOD.


  METHOD get_types.

    DATA ls_f4tab TYPE ty_f4tab.

    ls_f4tab-vtype = 'T'.
    ls_f4tab-descr = TEXT-195.
    INSERT  ls_f4tab INTO TABLE et_values.
    CLEAR ls_f4tab.

    CASE iv_type.

      WHEN 'D'.

        ls_f4tab-vtype = 'D'.
        ls_f4tab-descr = TEXT-196.
        INSERT  ls_f4tab INTO TABLE et_values.
        CLEAR ls_f4tab.
*
        ls_f4tab-vtype = 'X'.
        ls_f4tab-descr = TEXT-236.
        INSERT  ls_f4tab INTO TABLE et_values.
        CLEAR ls_f4tab.

      WHEN 'B'.
        ls_f4tab-vtype = 'B'.
        ls_f4tab-descr = TEXT-197.
        INSERT  ls_f4tab INTO TABLE et_values.
        CLEAR ls_f4tab.

      WHEN 'T'.

        ls_f4tab-vtype = 'Z'.
        ls_f4tab-descr = TEXT-235.
        INSERT  ls_f4tab INTO TABLE et_values.
        CLEAR ls_f4tab.
*
        ls_f4tab-vtype = 'Y'.
        ls_f4tab-descr = TEXT-237.
        INSERT  ls_f4tab INTO TABLE et_values.
        CLEAR ls_f4tab.

    ENDCASE.

    IF iv_alv = 'X'.
      popup_f4( EXPORTING iv_fname = 'VTYPE'
                IMPORTING es_value = es_value
                 CHANGING ct_table = et_values ).
    ENDIF.

  ENDMETHOD.


  METHOD get_values.

    CASE iv_type.

      WHEN 'D'.

        CALL FUNCTION 'RS_VARI_V_SAVE'
          EXPORTING
            p_varivar  = is_varivar
          TABLES
            p_intrange = ct_INTRANGE
          EXCEPTIONS
            no_action  = 1.

      WHEN 'Z'.

        CALL FUNCTION 'RS_TIME_INPUT'
          EXPORTING
            p_varivar  = is_varivar
          TABLES
            p_intrange = ct_INTRANGE
          EXCEPTIONS
            no_action  = 1.

    ENDCASE.

  ENDMETHOD.


  METHOD get_variant_values.



    DATA: lv_varname      TYPE tvarvc-name,
          lt_range        TYPE zonst_oc_rsparams,
          lt_where_tmp    TYPE rsds_twhere,
          lt_where_whole  TYPE rsds_twhere,
          lt_variant_pos  TYPE STANDARD TABLE OF zonta_oc_var_it,
          lt_range_whole  TYPE zontt_oc_rsparams_tt,
          lt_ranges_where TYPE zontt_oc_rsparams_tt,
          lo_interpreter  TYPE REF TO zoncl_dynamic_interpreter.

*---------------------------------------------------------------------*
* Get Variant Positions
*---------------------------------------------------------------------*
    SELECT *
      FROM zonta_oc_var_it
      INTO TABLE lt_variant_pos
      WHERE var_v_uuid = is_variant-var_v_uuid.

    CREATE OBJECT lo_interpreter.
*---------------------------------------------------------------------*
* Dynamic Variant (Date/Time Type)
*---------------------------------------------------------------------*
    IF is_variant-vtype = 'D'.

      lv_varname = is_variant-description.

      CALL METHOD lo_interpreter->get_dynamic_datetime
        EXPORTING
          is_variant     = is_variant
          it_variant_pos = lt_variant_pos
        IMPORTING
          et_where       = lt_where_tmp
          et_range       = lt_range
        CHANGING
          et_where_all   = lt_where_whole
          et_range_all   = lt_range_whole.

      et_where_all = lt_where_whole.
      et_range_all = lt_range_whole.
*---------------------------------------------------------------------*
* TVARV / Variable-Based Variant
*---------------------------------------------------------------------*
    ELSE.

      lv_varname = is_variant-description.

      CALL METHOD lo_interpreter->get_dynamic_variable
        EXPORTING
          iv_varname   = lv_varname
          iv_tabname   = is_variant-tabname
          iv_fieldname = is_variant-fieldname
        IMPORTING
          et_range     = lt_range
          et_where     = lt_where_tmp
        CHANGING
          et_where_all = lt_where_whole
          et_range_all = lt_range_whole.

      et_range_all   = lt_range_whole.
      lt_ranges_where = et_range_all.

    ENDIF.

*---------------------------------------------------------------------*
* Return WHERE
*---------------------------------------------------------------------*
    et_where = lt_where_whole.


  ENDMETHOD.


  METHOD IS_VALID_VARIANT.

    DATA: lv_len       TYPE i,
          ls_var       TYPE zonta_oc_variant,
          zonta_obj_oc TYPE zonta_obj_oc,
          lv_memory    TYPE char20.

    IF is_obj_oc IS INITIAL.
      CONCATENATE 'ZONT' sy-uname INTO lv_memory.
      IMPORT: zonta_obj_oc = zonta_obj_oc FROM MEMORY ID lv_memory.
      is_obj_oc = zonta_obj_oc.
    ENDIF.

    rs_valid = abap_true.
    IF iv_variant IS NOT INITIAL.
      lv_len = strlen( iv_variant ).
      IF lv_len > 14.
        MESSAGE i044(zon_cl_oc) WITH iv_variant.
        rs_valid = abap_false.
      ELSE.
        SELECT SINGLE *
          INTO @DATA(ls_var_old)
          FROM zonta_oc_variant
          WHERE domainv       = @is_obj_oc-domainv
            AND business_proc = @is_obj_oc-business_proc
            AND variant       = @iv_variant.
        IF sy-subrc = 0.
          MESSAGE i043(zon_cl_oc) WITH iv_variant.
          ev_variant_old = ls_var_old-variant.
          rs_valid = abap_false.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD popup_f4.

    DATA lt_return   TYPE STANDARD TABLE OF ddshretval.

    DATA lt_field TYPE STANDARD TABLE OF dfies.

    FIELD-SYMBOLS: <fs_itab> TYPE STANDARD TABLE.

    ASSIGN ct_table TO <fs_itab>.

    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname        = 'ZONST_VARIANT_VTYPE'
      TABLES
        dfies_tab      = lt_field
      EXCEPTIONS
        not_found      = 1
        internal_error = 2
        OTHERS         = 3.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield        = iv_fname
        value_org       = 'S'
      TABLES
        value_tab       = <fs_itab>
        field_tab       = lt_field
        return_tab      = lt_return
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2
        OTHERS          = 3.

    IF sy-subrc <> 0.
**         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ELSE.
      es_value = VALUE #( lt_return[ 1  ] OPTIONAL ).
    ENDIF.

  ENDMETHOD.


METHOD save_variant_db.

  CONSTANTS: c_separator TYPE c VALUE '~'.

  DATA: lv_memory            TYPE char25,
        lv_tabix             TYPE sy-tabix,
        lv_tabix_tab         TYPE sy-tabix,
        lv_counter           TYPE i,
        lv_fieldname_complex TYPE string,
        lv_where_string      TYPE string,
        lv_variant_old       TYPE variant,
        lv_valid             TYPE boolean,
        zonta_obj_oc         TYPE zonta_obj_oc.

  DATA: lt_filters   TYPE zontt_filters,
        ls_filters   LIKE LINE OF lt_filters,
        lt_ranges    TYPE STANDARD TABLE OF zonta_oc_franges,
        ls_ranges    LIKE LINE OF lt_ranges,
        lt_variantd  TYPE STANDARD TABLE OF zonta_oc_variant.

  DATA: ls_field_r LIKE LINE OF it_field_ranges.

  FIELD-SYMBOLS: <fs_cond_tab> LIKE LINE OF it_cond_tab.
  DATA ls_where LIKE LINE OF <fs_cond_tab>-where_tab.

*---------------------------------------------------------------------*
* Get Object
*---------------------------------------------------------------------*
  IF is_obj_oc IS INITIAL.
    CONCATENATE 'ZONT' sy-uname INTO lv_memory.
    IMPORT zonta_obj_oc = zonta_obj_oc FROM MEMORY ID lv_memory.
  ELSE.
    zonta_obj_oc = is_obj_oc.
  ENDIF.

*---------------------------------------------------------------------*
* Validate Variant
*---------------------------------------------------------------------*
  CALL METHOD zoncl_variants=>is_valid_variant
    EXPORTING
      is_obj_oc      = zonta_obj_oc
      iv_variant     = is_variant-variant
    IMPORTING
      ev_variant_old = lv_variant_old
    RECEIVING
      rs_valid       = lv_valid.

  CHECK lv_valid = abap_true.

*---------------------------------------------------------------------*
* STATIC VARIANT SAVE
*---------------------------------------------------------------------*
  IF iv_save = abap_true.

    IF lines( it_cond_tab ) > 0.

      CLEAR lt_filters.
      SORT it_cond_tab BY tablename.

*------------------------------------------------------------------*
* Build Filters
*------------------------------------------------------------------*
      LOOP AT it_cond_tab ASSIGNING <fs_cond_tab>.

        ls_filters-domainv       = zonta_obj_oc-domainv.
        ls_filters-business_proc = zonta_obj_oc-business_proc.
        ls_filters-tabname       = <fs_cond_tab>-tablename.
        ls_filters-variant       = is_variant-variant.

        lv_counter   = 1.
        lv_tabix     = 1.
        lv_tabix_tab = 1.

        LOOP AT it_fieldtab INTO DATA(ls_field_tab)
             WHERE tablename = ls_filters-tabname.

          DO.
            READ TABLE <fs_cond_tab>-where_tab INTO ls_where INDEX lv_tabix.
            IF sy-subrc = 0 AND
               ls_where-line CS ls_field_tab-fieldname.

              ls_filters-counter = lv_counter.
              ls_filters-fldname = ls_field_tab-fieldname.

              lv_fieldname_complex =
                |{ ls_filters-tabname }{ c_separator }{ ls_field_tab-fieldname }|.

              lv_where_string = ls_where-line.

              REPLACE ALL OCCURRENCES OF ls_field_tab-fieldname
                IN lv_where_string
                WITH lv_fieldname_complex.

              ls_filters-where_clause = lv_where_string.

              APPEND ls_filters TO lt_filters.

              lv_counter = lv_counter + 1.
              lv_tabix   = lv_tabix + 1.

            ELSE.
              EXIT.
            ENDIF.
          ENDDO.

*------------------------------------------------------------------*
* Multi-line condition handling
*------------------------------------------------------------------*
          lv_tabix_tab = lv_tabix_tab + 1.

          READ TABLE it_fieldtab INTO ls_field_tab INDEX lv_tabix_tab.
          IF sy-subrc = 0.

            READ TABLE <fs_cond_tab>-where_tab INTO ls_where INDEX lv_tabix.
            IF sy-subrc = 0 AND
               ls_where-line CS ls_field_tab-fieldname.
            ELSE.
              READ TABLE lt_filters ASSIGNING FIELD-SYMBOL(<fs_filters>)
                   FROM ls_filters.
              IF sy-subrc = 0.
                CONCATENATE <fs_filters>-where_clause
                            ls_where-line
                       INTO <fs_filters>-where_clause
                       SEPARATED BY space.
              ENDIF.
              lv_tabix = lv_tabix + 1.
            ENDIF.

          ENDIF.

        ENDLOOP.
      ENDLOOP.

*------------------------------------------------------------------*
* Build Ranges
*------------------------------------------------------------------*
      lv_counter = 1.

      LOOP AT it_field_ranges INTO ls_field_r.

        ls_ranges-domainv       = zonta_obj_oc-domainv.
        ls_ranges-business_proc = zonta_obj_oc-business_proc.
        ls_ranges-tabname       = ls_field_r-tablename.

        LOOP AT ls_field_r-frange_t INTO DATA(ls_range_d).

          ls_ranges-fldname = ls_range_d-fieldname.

          LOOP AT ls_range_d-selopt_t INTO DATA(ls_selopt).

            ls_ranges-counter = lv_counter.
            ls_ranges-sign    = ls_selopt-sign.
            ls_ranges-opti    = ls_selopt-option.
            ls_ranges-low     = ls_selopt-low.
            ls_ranges-high    = ls_selopt-high.
            ls_ranges-variant = is_variant-variant.

            APPEND ls_ranges TO lt_ranges.

            lv_counter = lv_counter + 1.

          ENDLOOP.
        ENDLOOP.
      ENDLOOP.

*------------------------------------------------------------------*
* Delete Old Variant If Exists
*------------------------------------------------------------------*
      IF lv_variant_old = abap_true.

        DELETE FROM zonta_oc_filters
          WHERE domainv       = zonta_obj_oc-domainv
            AND business_proc = zonta_obj_oc-business_proc
            AND variant       = is_variant-variant.

        DELETE FROM zonta_oc_franges
          WHERE domainv       = zonta_obj_oc-domainv
            AND business_proc = zonta_obj_oc-business_proc
            AND variant       = is_variant-variant.

        DELETE FROM zonta_oc_variant
          WHERE domainv       = zonta_obj_oc-domainv
            AND business_proc = zonta_obj_oc-business_proc
            AND variant       = is_variant-variant.

        DELETE FROM zonta_oc_var_it
          WHERE var_v_uuid = is_variant-var_v_uuid.

      ENDIF.

*------------------------------------------------------------------*
* Save DB Tables
*------------------------------------------------------------------*
      MODIFY zonta_oc_filters FROM TABLE lt_filters.
      MODIFY zonta_oc_franges FROM TABLE lt_ranges.

      IF sy-subrc = 0.
        COMMIT WORK.
        MESSAGE s042(zon_cl_oc).
        ev_variant_exists = abap_true.
      ENDIF.

*------------------------------------------------------------------*
* Save Variant Header
*------------------------------------------------------------------*
      APPEND INITIAL LINE TO lt_variantd ASSIGNING FIELD-SYMBOL(<fs_variant>).

      <fs_variant>-domainv       = zonta_obj_oc-domainv.
      <fs_variant>-business_proc = zonta_obj_oc-business_proc.
      <fs_variant>-id            = zonta_obj_oc-id.
      <fs_variant>-variant       = is_variant-variant.
      <fs_variant>-vdescription  = is_variant-description.
      <fs_variant>-variant_type  = 'F'.
      <fs_variant>-created_by    = sy-uname.
      <fs_variant>-created_on    = sy-datum.

      MODIFY zonta_oc_variant FROM TABLE lt_variantd.

      IF sy-subrc = 0.
        COMMIT WORK.
        MESSAGE s042(zon_cl_oc).
      ENDIF.

*------------------------------------------------------------------*
* Save Variant Positions
*------------------------------------------------------------------*
      IF lines( it_variant_pos ) > 0.
        MODIFY zonta_oc_var_it FROM TABLE it_variant_pos.
      ENDIF.

    ENDIF.

*---------------------------------------------------------------------*
* DYNAMIC VARIANT SAVE
*---------------------------------------------------------------------*
  ELSE.

    IF lines( it_variant_values ) > 0.

      MODIFY zonta_oc_variant FROM TABLE it_variant_values.

      IF sy-subrc = 0.
        COMMIT WORK.
        MESSAGE s042(zon_cl_oc).
        ev_variant_exists = abap_true.
      ENDIF.

    ENDIF.

    IF lines( it_variant_pos ) > 0.
      MODIFY zonta_oc_var_it FROM TABLE it_variant_pos.
    ENDIF.

  ENDIF.

ENDMETHOD.


  METHOD update_variant.

    DATA ls_RSINTRANGE TYPE rsintrange.

    DATA ls_variant  TYPE ty_variant.

    DELETE ct_var_it WHERE var_v_uuid = iv_var_v_uuid.

    LOOP AT it_intrange INTO ls_RSINTRANGE.
*    READ TABLE it_intrange INTO ls_RSINTRANGE INDEX 1.
*    IF sy-subrc NE 0.
*      RETURN.
*    ENDIF.
      CLEAR ls_variant.

      MOVE-CORRESPONDING ls_RSINTRANGE TO ls_variant.
      ls_variant-var_v_uuid = iv_var_v_uuid.
      TRY.
          ls_variant-var_v_pos_uuid = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error.
      ENDTRY.
      ls_variant-opti = ls_RSINTRANGE-option.
      IF ls_RSINTRANGE-sign IS INITIAL.
        ls_variant-sign = iv_sign.
      ENDIF.
      IF ls_RSINTRANGE-option IS INITIAL.
        ls_variant-opti = iv_option.
      ENDIF.


*      IF ls_variant-val1 < 0.
*        ls_variant-sign1 = '-'.
*        ls_variant-val1 = cs_variant-val1 * -1.
*      ELSE.
*        ls_variant-sign1 = '+'.
*      ENDIF.
*
*      IF ls_RSINTRANGE-high IS NOT INITIAL.
*        IF ls_variant-option IS INITIAL.
*          ls_variant-option = 'BT'.
*        ENDIF.
*        ls_variant-val2 = ls_RSINTRANGE-high.
*        IF cs_variant-val2 < 0.
*          ls_variant-sign2 = '-'.
*          ls_variant-val2 = cs_variant-val2 * -1.
*        ELSE.
*          ls_variant-sign2 = '+'.
*        ENDIF.
*      ELSE.
*        CLEAR: ls_variant-val2, ls_variant-sign2.
*        IF ls_variant-option IS INITIAL.
*          ls_variant-option = 'EQ'.
*        ENDIF.
*      ENDIF.

      APPEND ls_variant TO ct_var_it.

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
