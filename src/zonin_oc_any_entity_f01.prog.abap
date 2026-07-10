*---------------------------------------------------------------------*
* INCLUDE ZONIN_OC_ANY_ENTITY_F01
*---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form init
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init.

  DATA: lv_wait    TYPE zonta_oc_param-low,
        lv_lpakage TYPE zonta_oc_param-low.

  CREATE OBJECT go_handler.

  SELECT SINGLE low
    INTO gv_alias
    FROM zonta_oc_param
    WHERE name = 'USE_ALIAS'.


  SELECT SINGLE low
    INTO lv_wait
    FROM zonta_oc_param
    WHERE name = 'BATCH_WAIT_JOBS'.
  gv_wait = lv_wait.
  IF gv_wait = 0.
    gv_wait = 900.
  ENDIF.

  SELECT SINGLE low
    INTO lv_lpakage
    FROM zonta_oc_param
    WHERE name = 'BATCH_SPLIT_SELECT'.
  IF sy-subrc = 0.
    gv_pakage = lv_lpakage.
  ELSE.
    gv_pakage = 1000.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_driver_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_driver_table.

  SELECT SINGLE *
    INTO gs_driver_rel
    FROM zonta_relations
    WHERE domainv       = p_domain
      AND business_proc = p_entity
      AND sequence      = '01'.

  IF sy-subrc = 0.
    gv_driver_table = gs_driver_rel-tabname.
    gv_main_key     = gs_driver_rel-field_main.
  ELSE.
    MESSAGE 'Driver table not found' TYPE 'E'.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_free_selections
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_free_selections.

  DATA: selid        TYPE rsdynsel-selid,
        lt_cond_tab  TYPE rsds_twhere,
        ls_cond_tab  TYPE rsds_where,
        ls_where_tab TYPE rsdswhere.

  DATA: table_tab       TYPE TABLE OF rsdstabs,
        lt_fieldtab     TYPE STANDARD TABLE OF rsdsfields,
        lt_field_ranges TYPE rsds_trange,
        lv_generic      TYPE boolean.

  FIELD-SYMBOLS: <fs_table_tab> TYPE rsdstabs,
                 <fs_range>     TYPE rsds_range,
                 <fs_frange>    TYPE rsds_frange,
                 <fs_selopt>    TYPE rsdsselopt.

  CLEAR gv_where.

  APPEND INITIAL LINE TO table_tab ASSIGNING <fs_table_tab>.
  <fs_table_tab>-prim_tab = gv_driver_table.

  CALL FUNCTION 'FREE_SELECTIONS_INIT'
    EXPORTING
      kind                     = 'T'
    IMPORTING
      selection_id             = selid
    TABLES
      tables_tab               = table_tab
    EXCEPTIONS
      fields_incomplete        = 1
      fields_no_join           = 2
      field_not_found          = 3
      no_tables                = 4
      table_not_found          = 5
      expression_not_supported = 6
      incorrect_expression     = 7
      illegal_kind             = 8
      area_not_found           = 9
      inconsistent_area        = 10
      kind_f_no_fields_left    = 11
      kind_f_no_fields         = 12
      too_many_fields          = 13
      dup_field                = 14
      field_no_type            = 15
      field_ill_type           = 16
      dup_event_field          = 17
      node_not_in_ldb          = 18
      area_no_field            = 19
      OTHERS                   = 20.
  IF sy-subrc <> 0.
    MESSAGE 'Not possible to get the selections' TYPE 'E'.
  ENDIF.


  CALL FUNCTION 'FREE_SELECTIONS_DIALOG'
    EXPORTING
      selection_id    = selid
    IMPORTING
      where_clauses   = lt_cond_tab
      field_ranges    = gt_field_ranges
    TABLES
      fields_tab      = lt_fieldtab
    EXCEPTIONS
      internal_error  = 1
      no_action       = 2
      selid_not_found = 3
      illegal_status  = 4
      OTHERS          = 5.
  IF sy-subrc <> 0.
    MESSAGE 'Not possible to get the selections' TYPE 'E'.
  ENDIF.


* Convert where
  lv_generic = abap_false.
  IF gt_field_ranges IS NOT INITIAL.
    LOOP AT gt_field_ranges ASSIGNING <fs_range>.
      LOOP AT <fs_range>-frange_t ASSIGNING <fs_frange>.
        LOOP AT <fs_frange>-selopt_t ASSIGNING <fs_selopt>.
          IF <fs_selopt>-low = '*' AND <fs_selopt>-high IS INITIAL.
            CLEAR gv_where.
            lv_generic = abap_true.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
  ENDIF.

  IF lv_generic = abap_false.
    LOOP AT lt_cond_tab INTO ls_cond_tab.
      LOOP AT ls_cond_tab-where_tab INTO ls_where_tab.
        CONCATENATE gv_where ls_where_tab-line INTO gv_where SEPARATED BY space.
      ENDLOOP.
    ENDLOOP.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_root_keys
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_root_keys.

  DATA: lt_dd03p TYPE STANDARD TABLE OF dd03p,
        ls_dd03p TYPE dd03p.

  DATA: lv_block  TYPE string,
        lv_block1 TYPE string,
        lv_value  TYPE string.

  FIELD-SYMBOLS: <fs_table> TYPE STANDARD TABLE,
                 <fs_line>  TYPE any,
                 <fs_key>   TYPE any.

  DATA: lo_data TYPE REF TO data.

  CREATE DATA lo_data TYPE STANDARD TABLE OF (gv_driver_table).
  ASSIGN lo_data->* TO <fs_table>.

  SELECT *
    FROM (gv_driver_table)
    INTO TABLE <fs_table>
    WHERE (gv_where).

  IF <fs_table> IS INITIAL.
    MESSAGE 'No data found in driver table' TYPE 'I'.
    RETURN.
  ENDIF.


  CALL FUNCTION 'DDIF_TABL_GET'
    EXPORTING
      name          = gv_driver_table
    TABLES
      dd03p_tab     = lt_dd03p
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.
  IF sy-subrc = 0.
    DELETE lt_dd03p WHERE keyflag IS INITIAL.
    DELETE lt_dd03p WHERE fieldname = 'MANDT'.
  ENDIF.

  gt_dd03p[] = lt_dd03p[].

  IF lines( lt_dd03p ) = 1.
    LOOP AT <fs_table> ASSIGNING <fs_line>.
      ASSIGN COMPONENT gv_main_key OF STRUCTURE <fs_line> TO <fs_key>.
      IF <fs_key> IS ASSIGNED AND <fs_key> IS NOT INITIAL.
        APPEND <fs_key> TO gt_root_keys.
      ENDIF.
    ENDLOOP.
    gv_driver_multi = abap_false.
  ELSE.

    gv_driver_multi = abap_true.
    LOOP AT <fs_table> ASSIGNING <fs_line>.
      CLEAR lv_block.
      LOOP AT lt_dd03p INTO ls_dd03p.
        ASSIGN COMPONENT ls_dd03p-fieldname OF STRUCTURE <fs_line> TO <fs_key>.
        IF <fs_key> IS ASSIGNED.
          lv_value = <fs_key>.
          REPLACE ALL OCCURRENCES OF '''' IN lv_value WITH ''''''.
          IF lv_block IS INITIAL.
            CONCATENATE ls_dd03p-fieldname ' = ' ' ''' lv_value ''''
              INTO lv_block.
          ELSE.
            CONCATENATE lv_block 'AND' ls_dd03p-fieldname INTO lv_block1 SEPARATED BY space.
            CONCATENATE lv_block1 ' = ' ' ''' lv_value ''''  INTO lv_block.
            CLEAR lv_block1.
          ENDIF.
        ENDIF.
      ENDLOOP.

      IF lv_block IS NOT INITIAL.
        CONCATENATE '(' lv_block ')' INTO lv_block.
        APPEND lv_block TO gt_root_keys.
      ENDIF.

    ENDLOOP.
  ENDIF.

  SORT gt_root_keys.
  DELETE ADJACENT DUPLICATES FROM gt_root_keys.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form process_tables
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_tables.

  FIELD-SYMBOLS: <fs_access> TYPE st_access.

  DATA: lv_table      TYPE tabname,
        lv_field      TYPE zonde_fieldm,
        lv_sec        TYPE zonde_fieldm,
        lv_percent    TYPE p DECIMALS 2,
        lv_alias      TYPE zonde_aliastab,
        lv_payloadid  TYPE char32,
        lv_jobname    TYPE btcjob,
        lv_jobcount   TYPE btcjobcnt,
        lv_count      TYPE i,
        lv_where_line TYPE string.

  DATA: lv_max_jobs    TYPE i VALUE 5,
        lv_active_jobs TYPE i VALUE 0.

  DATA: lv_total    TYPE i,
        lv_index    TYPE i,
        lv_is_multi TYPE boolean,
        lv_val      TYPE string.

  DATA: lt_keys_to_use  TYPE STANDARD TABLE OF string,
        lv_field_to_use TYPE zonde_fieldm,
        lv_lines        TYPE i,
        lv_key          TYPE string.

  DATA: lo_join   TYPE REF TO data,
        lt_fields TYPE STANDARD TABLE OF zonta_relations.

  DATA: lv_where TYPE string,
        lv_part  TYPE string.

  FIELD-SYMBOLS:
    <fs_tablej>     TYPE STANDARD TABLE,
    <fs_line>       TYPE any,
    <fs_value>      TYPE any,
    <fs_table_keys> TYPE ty_table_keys.

  DATA: lt_keys TYPE STANDARD TABLE OF string.

  gt_root_keys_base = gt_root_keys.

  IF gt_root_keys IS INITIAL.
    MESSAGE 'No root keys found - nothing to process' TYPE 'I'.
    RETURN.
  ENDIF.

  CALL FUNCTION 'GUID_CREATE'
    IMPORTING
      ev_guid_32 = lv_payloadid.

  DESCRIBE TABLE gt_access LINES lv_total.

  SORT gt_access BY sequence.

  LOOP AT gt_access ASSIGNING <fs_access>.

    ADD 1 TO lv_index.

    lv_table = <fs_access>-tabname.
    lv_field = <fs_access>-field_main.
    lv_sec   = <fs_access>-field_sec.
    lv_alias = <fs_access>-alias_tabname.

    IF lv_field IS INITIAL.
      CONTINUE.
    ENDIF.

    CLEAR lt_keys_to_use.

    CASE <fs_access>-access.

* DIRECT
      WHEN c_direct.

        gt_root_keys = gt_root_keys_base.
        lt_keys_to_use = gt_root_keys.

* PREKEY
      WHEN c_prekey.

        PERFORM get_prekeys
          USING    <fs_access>-parent_relation
                   <fs_access>-field_main
          CHANGING lt_keys_to_use.

* JOIN
      WHEN c_join.

        CLEAR: lt_keys, lt_fields.
        SELECT *
         INTO TABLE lt_fields
         FROM zonta_relations
         WHERE domainv       = p_domain
           AND business_proc = p_entity
           AND tabname       = lv_table.

        PERFORM get_join_keys
          USING    <fs_access>-parent_relation
                   lt_fields
          CHANGING lt_keys.

        IF lt_keys IS INITIAL.
          CONTINUE.
        ENDIF.

        CREATE DATA lo_join TYPE STANDARD TABLE OF (<fs_access>-tabname).
        ASSIGN lo_join->* TO <fs_tablej>.

        DESCRIBE TABLE lt_fields LINES lv_lines.
        CLEAR lt_chunk.

        IF lv_lines = 1.
          lv_is_multi = abap_false.
          CLEAR lt_chunk.
          LOOP AT lt_keys INTO lv_where_line.
            APPEND lv_where_line TO lt_chunk.
            ADD 1 TO lv_count.
            IF lv_count >= gv_pakage.
              PERFORM select_dynamic_where
                USING    lv_table
                        <fs_access>-field_sec
                         lt_chunk
                CHANGING <fs_tablej>.
              CLEAR: lt_chunk, lv_count.
            ENDIF.
          ENDLOOP.

          IF lt_chunk IS NOT INITIAL.
            PERFORM select_dynamic_where
              USING    lv_table
                      <fs_access>-field_sec
                       lt_chunk
              CHANGING <fs_tablej>.
          ENDIF.

          CLEAR lt_keys_to_use.

          LOOP AT <fs_tablej> ASSIGNING <fs_line>.
            ASSIGN COMPONENT <fs_access>-field_sec
              OF STRUCTURE <fs_line> TO <fs_value>.
            IF <fs_value> IS ASSIGNED AND <fs_value> IS NOT INITIAL.
              lv_key = <fs_value>.
              CONDENSE lv_key.
              APPEND lv_key TO lt_keys_to_use.
            ENDIF.
          ENDLOOP.

          SORT lt_keys_to_use.
          DELETE ADJACENT DUPLICATES FROM lt_keys_to_use.

        ELSE.
          lv_is_multi = abap_true.
          CLEAR lt_chunk.
          LOOP AT lt_keys INTO lv_where_line.
            APPEND lv_where_line TO lt_chunk.
            ADD 1 TO lv_count.
            IF lv_count >= gv_pakage.
              PERFORM select_dynamic_where
                USING    lv_table
                         ''
                         lt_chunk
                CHANGING <fs_tablej>.
              CLEAR: lt_chunk, lv_count.
            ENDIF.
          ENDLOOP.

          IF lt_chunk IS NOT INITIAL.
            PERFORM select_dynamic_where
              USING    lv_table
                       ''
                       lt_chunk
              CHANGING <fs_tablej>.
          ENDIF.

          CLEAR lt_keys_to_use.

          LOOP AT <fs_tablej> ASSIGNING <fs_line>.
            lv_where = ''.
            LOOP AT lt_fields ASSIGNING FIELD-SYMBOL(<fs_rel>).
              ASSIGN COMPONENT <fs_rel>-field_sec
                OF STRUCTURE <fs_line> TO <fs_value>.
              IF <fs_value> IS ASSIGNED AND <fs_value> IS NOT INITIAL.
                lv_val = <fs_value>.
                CONDENSE lv_val.
                lv_part = |{ <fs_rel>-field_main } = '{ lv_val }'|.

                IF lv_where IS INITIAL.
                  lv_where = lv_part.
                ELSE.
                  CONCATENATE lv_where 'AND' lv_part INTO lv_where SEPARATED BY space.
                ENDIF.
              ENDIF.
            ENDLOOP.

            IF lv_where IS NOT INITIAL.
              CONCATENATE '(' lv_where ')' INTO lv_where.
              APPEND lv_where TO lt_keys_to_use.
            ENDIF.
          ENDLOOP.

          SORT lt_keys_to_use.
          DELETE ADJACENT DUPLICATES FROM lt_keys_to_use.

        ENDIF.

      WHEN OTHERS.
        CONTINUE.

    ENDCASE.

    IF lt_keys_to_use IS INITIAL.
      CONTINUE.
    ENDIF.

    gt_root_keys = lt_keys_to_use.

* Determine field for worker if needed
    CASE <fs_access>-access.
      WHEN c_direct.
        IF gv_driver_multi = abap_true.
          CLEAR lv_field_to_use.
          lv_is_multi = abap_true.
        ELSE.
          lv_field_to_use = <fs_access>-field_main.
        ENDIF.

      WHEN c_join.
        lv_field_to_use = <fs_access>-field_sec.
        IF lines( lt_fields ) > 1.
          CLEAR lv_field_to_use.
        ENDIF.
      WHEN OTHERS.
        lv_field_to_use = <fs_access>-field_main.
    ENDCASE.

* Export payload
    EXPORT gt_root_keys
      TO DATABASE indx(st)
      ID lv_payloadid.

* Save data into cache table
    APPEND INITIAL LINE TO gt_table_keys ASSIGNING <fs_table_keys>.
    <fs_table_keys>-tabname = lv_table.
    <fs_table_keys>-keys = gt_root_keys.
    <fs_table_keys>-is_multi = lv_is_multi.


* JOB
    CONCATENATE 'ZOC_ANY_' lv_table '_' lv_payloadid+27(5)
      INTO lv_jobname.

    IF sy-batch = abap_true.

      CALL FUNCTION 'JOB_OPEN'
        EXPORTING
          jobname  = lv_jobname
        IMPORTING
          jobcount = lv_jobcount.

      SUBMIT zonpg_oc_any_worker
        WITH p_table = lv_table
        WITH p_field = lv_field_to_use
        WITH p_alias = lv_alias
        WITH p_dest  = p_dest
        WITH p_payl  = lv_payloadid
        VIA JOB lv_jobname NUMBER lv_jobcount
        AND RETURN.

      CALL FUNCTION 'JOB_CLOSE'
        EXPORTING
          jobname   = lv_jobname
          jobcount  = lv_jobcount
          strtimmed = 'X'.

    ELSE.

      SUBMIT zonpg_oc_any_worker
        WITH p_table = lv_table
        WITH p_field = lv_field_to_use
        WITH p_alias = lv_alias
        WITH p_dest  = p_dest
        WITH p_payl  = lv_payloadid
        AND RETURN.

    ENDIF.

* Progress
    lv_percent = lv_index * 100 / lv_total.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = lv_percent
        text       = |Launching { lv_table } ({ lv_index }/{ lv_total })|.

    ADD 1 TO lv_active_jobs.

    IF lv_active_jobs >= lv_max_jobs.

      PERFORM wait_for_jobs USING lv_payloadid
                                 lv_max_jobs.

      CLEAR lv_active_jobs.

    ENDIF.

  ENDLOOP.

  MESSAGE |All jobs launched successfully ({ lv_total })| TYPE 'S'.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form define_access_keys
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM define_access_keys.

  DATA: lv_count  TYPE i,
        lt_access TYPE STANDARD TABLE OF st_access.

  DATA: lt_dd03p TYPE STANDARD TABLE OF dd03p,
        ls_dd03p TYPE dd03p,
        lv_equal TYPE boolean.

  FIELD-SYMBOLS: <fs_access> TYPE st_access.

  SELECT tabname field_main field_sec parent_relation
         join_type sequence subsequence levelv alias_tabname
    INTO TABLE gt_access
    FROM zonta_relations
    WHERE domainv = p_domain
      AND business_proc = p_entity.

  SORT gt_access BY sequence subsequence.
  lt_access[] = gt_access[].
  DELETE ADJACENT DUPLICATES FROM gt_access COMPARING tabname.


  LOOP AT gt_access ASSIGNING <fs_access>.

    IF <fs_access>-sequence = 1.

      CALL FUNCTION 'DDIF_TABL_GET'
        EXPORTING
          name          = <fs_access>-tabname
        TABLES
          dd03p_tab     = gt_dd03p
        EXCEPTIONS
          illegal_input = 1
          OTHERS        = 2.
      IF sy-subrc = 0.
        DELETE gt_dd03p WHERE keyflag IS INITIAL.
        DELETE gt_dd03p WHERE fieldname = 'MANDT'.
      ENDIF.

    ENDIF.

*DIRECT, same key
    IF (  <fs_access>-field_main = gv_main_key
    AND   <fs_access>-sequence = 1 )

  OR ( <fs_access>-field_main = gv_main_key
       AND <fs_access>-field_sec  = gv_main_key
       AND <fs_access>-parent_relation = gv_driver_table ).

      CALL FUNCTION 'DDIF_TABL_GET'
        EXPORTING
          name          = <fs_access>-tabname
        TABLES
          dd03p_tab     = lt_dd03p
        EXCEPTIONS
          illegal_input = 1
          OTHERS        = 2.
      IF sy-subrc = 0.
        DELETE lt_dd03p WHERE keyflag IS INITIAL.
        DELETE lt_dd03p WHERE fieldname = 'MANDT'.
      ENDIF.

      lv_equal = abap_true.
      LOOP AT gt_dd03p INTO ls_dd03p.
        READ TABLE lt_dd03p TRANSPORTING NO FIELDS WITH KEY fieldname = ls_dd03p-fieldname.
        IF sy-subrc NE 0.
          lv_equal = abap_false.
          EXIT.
        ENDIF.
      ENDLOOP.
      IF lv_equal = abap_true.
        <fs_access>-access = c_direct.
      ELSE.
        <fs_access>-access = c_join.
      ENDIF.

* JOIN
    ELSEIF <fs_access>-parent_relation = gv_driver_table
         AND <fs_access>-field_sec IS NOT INITIAL
         AND <fs_access>-field_sec <> gv_main_key.
      <fs_access>-access = c_join.

* PREKEY , same parent table and different key
    ELSEIF <fs_access>-parent_relation = gv_driver_table.
*      <fs_access>-access = c_prekey.
      <fs_access>-access = c_join.

* MULTIKEY - several rows to same table
    ELSE.
      <fs_access>-access = c_join.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form wait_for_jobs
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_PAYLOADID
*&---------------------------------------------------------------------*
FORM wait_for_jobs USING iv_payloadid TYPE char32
                         iv_max       TYPE i.

  DATA: lv_running TYPE i,
        lv_jobn    TYPE tbtco-jobname.

  CONCATENATE 'ZOC_ANY' '%' INTO lv_jobn.

  DO.
    SELECT COUNT(*)
      INTO lv_running
      FROM tbtco
      WHERE jobname LIKE  lv_jobn
        AND status = 'R'.

    IF lv_running < iv_max.
      EXIT.
    ENDIF.

    WAIT UP TO gv_wait SECONDS.

  ENDDO.
ENDFORM.

*-----------------------------------------------------------*
*& Form f4_domain
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_domain.
  TYPES: BEGIN OF st_domain,
           domainv     TYPE zonde_domain,
           description TYPE zonde_description,
         END OF st_domain.

  DATA: lt_ret  TYPE TABLE OF ddshretval,
        lt_data TYPE TABLE OF st_domain,
        ls_data TYPE st_domain,
        ls_ret  TYPE ddshretval,
        lv_dynp TYPE help_info-dynprofld.

  SELECT domainv description
    INTO TABLE lt_data
    FROM zonta_domains
     WHERE spras = sy-langu.

  lv_dynp = 'P_DOMAIN'.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield    = 'DOMAINV'
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = lv_dynp
      value_org   = 'S'
    TABLES
      value_tab   = lt_data
      return_tab  = lt_ret.

  READ TABLE lt_ret INTO ls_ret INDEX 1.
  p_domain = ls_ret-fieldval.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form f4_entity
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_entity.

  TYPES: BEGIN OF st_entity,
           domainv TYPE zonde_domain,
           entity  TYPE zonde_process,
         END OF st_entity.

  DATA: lt_ret  TYPE TABLE OF ddshretval,
        lt_data TYPE TABLE OF st_entity,
        ls_data TYPE st_entity,
        lv_dynp TYPE help_info-dynprofld,
        ls_ret  TYPE ddshretval.

  SELECT domainv business_proc AS entity
    INTO TABLE lt_data
    FROM zonta_obj_oc
     WHERE domainv = p_domain.

  lv_dynp = 'P_ENTITY'.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield    = 'BUSINESS_PROC'
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = lv_dynp
      value_org   = 'S'
    TABLES
      value_tab   = lt_data
      return_tab  = lt_ret.

  READ TABLE lt_ret INTO ls_ret INDEX 1.
  p_entity = ls_ret-fieldval.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_prekeys
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_ACCESS>_PARENT_RELATION
*&      --> <FS_ACCESS>_FIELD_MAIN
*&      <-- LT_KEYS_TO_USE
*&---------------------------------------------------------------------*
FORM get_prekeys
  USING    iv_parent TYPE tabname
           iv_field  TYPE zonde_fieldm
  CHANGING ct_keys   TYPE STANDARD TABLE.

  FIELD-SYMBOLS: <fs_keys> TYPE STANDARD TABLE.

  DATA: lo_data TYPE REF TO data.

  FIELD-SYMBOLS: <fs_line>  TYPE any,
                 <fs_value> TYPE any.

  CREATE DATA lo_data TYPE STANDARD TABLE OF (iv_parent).
  ASSIGN lo_data->* TO <fs_keys>.

  PERFORM get_parent_data
    USING    iv_parent
    CHANGING <fs_keys>.

  LOOP AT <fs_keys> ASSIGNING <fs_line>.

    ASSIGN COMPONENT iv_field OF STRUCTURE <fs_line> TO <fs_value>.

    IF <fs_value> IS ASSIGNED AND <fs_value> IS NOT INITIAL.
      APPEND <fs_value> TO ct_keys.
    ENDIF.

  ENDLOOP.

  SORT ct_keys.
  DELETE ADJACENT DUPLICATES FROM ct_keys.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_dynamic_where
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IV_PARENT
*&      --> GV_MAIN_KEY
*&      --> GT_ROOT_KEYS
*&      <-- <FS_KEYS>
*&---------------------------------------------------------------------*
FORM select_dynamic_where
  USING    iv_table TYPE tabname
           iv_field TYPE zonde_fieldm
           it_keys  TYPE STANDARD TABLE
  CHANGING ct_data  TYPE STANDARD TABLE.

  DATA: lv_where TYPE string,
        lv_line  TYPE string,
        lv_key   TYPE string,
        lv_list  TYPE string,
        lv_lines TYPE i.

  FIELD-SYMBOLS: <fs_key> TYPE any.

  DESCRIBE TABLE it_keys LINES lv_lines.
  IF lv_lines = 0 OR iv_table IS INITIAL.
    RETURN.
  ENDIF.

  SORT it_keys.
  DELETE ADJACENT DUPLICATES FROM it_keys.

* Single mode
  IF iv_field IS NOT INITIAL.

    LOOP AT it_keys ASSIGNING <fs_key>.

      lv_key = <fs_key>.
      REPLACE ALL OCCURRENCES OF '''' IN lv_key WITH ''''''.

      IF lv_list IS INITIAL.
        CONCATENATE '''' lv_key '''' INTO lv_list.
      ELSE.
        CONCATENATE lv_list ',' '''' lv_key '''' INTO lv_list.
      ENDIF.

    ENDLOOP.

    lv_where = |{ iv_field } IN ( { lv_list } )|.

* Multikey mode
  ELSE.

    LOOP AT it_keys INTO lv_line.

      IF lv_where IS INITIAL.
        lv_where = lv_line.
      ELSE.
        CONCATENATE lv_where 'OR' lv_line INTO lv_where SEPARATED BY space.
      ENDIF.

    ENDLOOP.

  ENDIF.

* Execute select
  TRY.
      SELECT *
        FROM (iv_table)
        APPENDING TABLE ct_data
        WHERE (lv_where).

    CATCH cx_sy_dynamic_osql_semantics INTO DATA(lx_sql).
      MESSAGE lx_sql->get_text( ) TYPE 'E'.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form select_multikey_where
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IV_TABLE
*&      --> IT_FIELDS
*&      --> IT_PARENT_DATA
*&      <-- CT_DATA
*&---------------------------------------------------------------------*
FORM select_multikey_where
  USING    iv_table       TYPE tabname
           it_fields      TYPE tt_relations
           it_parent_data TYPE STANDARD TABLE
  CHANGING ct_data        TYPE STANDARD TABLE.


  FIELD-SYMBOLS: <fs_parent> TYPE any,
                 <fs_value1> TYPE any,
                 <fs_value2> TYPE any,
                 <fs_field>  LIKE LINE OF it_fields.

  DATA: lv_where TYPE string,
        lv_block TYPE string,
        lv_key1  TYPE string,
        lv_key2  TYPE string.

  DATA: lt_group   TYPE STANDARD TABLE OF string,
        lv_current TYPE string.

  IF it_parent_data IS INITIAL OR it_fields IS INITIAL.
    RETURN.
  ENDIF.

* We assume 2 fields max (common case)
  READ TABLE it_fields INDEX 1 ASSIGNING <fs_field>.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  DATA(lv_field1) = <fs_field>-field_main.
  DATA(lv_field1_parent) = <fs_field>-field_sec.

  READ TABLE it_fields INDEX 2 ASSIGNING <fs_field>.
  IF sy-subrc = 0.
    DATA(lv_field2) = <fs_field>-field_main.
    DATA(lv_field2_parent) = <fs_field>-field_sec.
  ENDIF.

* Build grouped WHERE
  LOOP AT it_parent_data ASSIGNING <fs_parent>.

    CLEAR: lv_key1, lv_key2.

    ASSIGN COMPONENT lv_field1_parent OF STRUCTURE <fs_parent> TO <fs_value1>.
    IF <fs_value1> IS ASSIGNED.
      lv_key1 = <fs_value1>.
    ENDIF.

    IF lv_field2 IS NOT INITIAL.
      ASSIGN COMPONENT lv_field2_parent OF STRUCTURE <fs_parent> TO <fs_value2>.
      IF <fs_value2> IS ASSIGNED.
        lv_key2 = <fs_value2>.
      ENDIF.
    ENDIF.

    IF lv_key1 IS INITIAL.
      CONTINUE.
    ENDIF.

    REPLACE ALL OCCURRENCES OF '''' IN lv_key1 WITH ''''''.
    REPLACE ALL OCCURRENCES OF '''' IN lv_key2 WITH ''''''.

* Build grouping logic
    IF lv_field2 IS INITIAL.

* Single key case
      IF lv_where IS INITIAL.
        CONCATENATE lv_field1 ' = ''' lv_key1 ''''
          INTO lv_where.
      ELSE.
        CONCATENATE lv_where ' OR '
                    lv_field1 ' = ''' lv_key1 ''''
          INTO lv_where SEPARATED BY space.
      ENDIF.

    ELSE.

* Two key optimized: A = X AND B IN (...)
      CONCATENATE lv_field1 ' = ''' lv_key1 ''' AND '
                  lv_field2 ' = ''' lv_key2 ''''
        INTO lv_block.

      IF lv_where IS INITIAL.
        CONCATENATE '(' lv_block ')' INTO lv_where.
      ELSE.
        CONCATENATE lv_where ' OR (' lv_block ')'
          INTO lv_where SEPARATED BY space.
      ENDIF.

    ENDIF.

  ENDLOOP.

  IF lv_where IS INITIAL.
    RETURN.
  ENDIF.

  TRY.

      SELECT *
        FROM (iv_table)
        APPENDING TABLE ct_data
        WHERE (lv_where).

    CATCH cx_sy_dynamic_osql_semantics INTO DATA(lx_sql).
      MESSAGE lx_sql->get_text( ) TYPE 'E'.

  ENDTRY.

ENDFORM.

**&---------------------------------------------------------------------*
**& Form get_join_keys
**&---------------------------------------------------------------------*
**& text
**&---------------------------------------------------------------------*
**&      --> IV_PARENT
**&      --> IV_FIELD_MAIN
**&      --> IV_FIELD_SEC
**&      <-- CT_KEYS
**&---------------------------------------------------------------------*
FORM get_join_keys
  USING    iv_parent     TYPE tabname
           it_relations  TYPE tt_relations
  CHANGING ct_keys       TYPE STANDARD TABLE.


  DATA: lo_parent_data TYPE REF TO data,
        lv_block       TYPE string,
        lv_block1      TYPE string,
        lv_value       TYPE string,
        lv_lines       TYPE i.

  FIELD-SYMBOLS:
    <fs_parent> TYPE STANDARD TABLE,
    <fs_line>   TYPE any,
    <fs_value>  TYPE any,
    <fs_field>  TYPE any,
    <fs_rel>    TYPE zonta_relations.

* Get parent data
  CREATE DATA lo_parent_data TYPE STANDARD TABLE OF (iv_parent).
  ASSIGN lo_parent_data->* TO <fs_parent>.

  PERFORM get_parent_data
    USING    iv_parent
    CHANGING <fs_parent>.

  IF <fs_parent> IS INITIAL OR it_relations IS INITIAL.
    RETURN.
  ENDIF.

* Determine if single or multi key
  DESCRIBE TABLE it_relations LINES lv_lines.

* Single key
  IF lv_lines = 1.

    READ TABLE it_relations ASSIGNING <fs_rel> INDEX 1.
    IF <fs_rel> IS ASSIGNED.

* Get needed keys
      LOOP AT <fs_parent> ASSIGNING <fs_line>.
        ASSIGN COMPONENT <fs_rel>-field_main
          OF STRUCTURE <fs_line> TO <fs_value>.
        IF <fs_value> IS ASSIGNED AND <fs_value> IS NOT INITIAL.
          APPEND <fs_value> TO ct_keys.
        ENDIF.
      ENDLOOP.

      SORT ct_keys.
      DELETE ADJACENT DUPLICATES FROM ct_keys.
    ENDIF.

*Multikey
  ELSE.

    LOOP AT <fs_parent> ASSIGNING <fs_line>.

      CLEAR lv_block.

      LOOP AT it_relations ASSIGNING <fs_rel>.

        ASSIGN COMPONENT <fs_rel>-field_main  "sec
          OF STRUCTURE <fs_line> TO <fs_field>.

        IF <fs_field> IS ASSIGNED. "AND <fs_field> IS NOT INITIAL.

          lv_value = <fs_field>.
          REPLACE ALL OCCURRENCES OF '''' IN lv_value WITH ''''''.

          IF lv_block IS INITIAL.
*            CONCATENATE <fs_rel>-field_main ' = ' ' ''' lv_value ''''
            CONCATENATE <fs_rel>-field_sec ' = ' ' ''' lv_value ''''
              INTO lv_block.
          ELSE.
*            CONCATENATE lv_block 'AND' <fs_rel>-field_main INTO lv_block1 SEPARATED BY space.
            CONCATENATE lv_block 'AND' <fs_rel>-field_sec INTO lv_block1 SEPARATED BY space.
            CONCATENATE lv_block1 ' = ' ' ''' lv_value ''''  INTO lv_block.
            CLEAR lv_block1.
          ENDIF.

        ENDIF.

      ENDLOOP.

      IF lv_block IS NOT INITIAL.
        CONCATENATE '(' lv_block ')' INTO lv_block.
        APPEND lv_block TO ct_keys.
      ENDIF.

    ENDLOOP.

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form select_dynamic_chunk
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IV_TABLE
*&      --> IV_FIELD
*&      --> LT_CHUNK
*&      <-- CT_DATA
*&---------------------------------------------------------------------*
FORM select_dynamic_chunk
  USING    iv_table TYPE tabname
           iv_field TYPE zonde_fieldm
           it_keys  TYPE STANDARD TABLE
  CHANGING ct_data  TYPE STANDARD TABLE.



  DATA: lv_where TYPE string,
        lv_list  TYPE string,
        lv_key   TYPE string.

  FIELD-SYMBOLS: <fs_key> TYPE any.

  LOOP AT it_keys ASSIGNING <fs_key>.

    lv_key = <fs_key>.
    REPLACE ALL OCCURRENCES OF '''' IN lv_key WITH ''''''.

    IF lv_list IS INITIAL.
      CONCATENATE '''' lv_key '''' INTO lv_list.
    ELSE.
      CONCATENATE lv_list ',''' lv_key '''' INTO lv_list.
    ENDIF.

  ENDLOOP.

  IF lv_list IS INITIAL.
    RETURN.
  ENDIF.

  CONCATENATE iv_field ' IN (' lv_list ')' INTO lv_where SEPARATED BY space.

  TRY.

      SELECT *
        FROM (iv_table)
        APPENDING TABLE ct_data
        WHERE (lv_where).

    CATCH cx_sy_dynamic_osql_semantics INTO DATA(lx_sql).
      MESSAGE lx_sql->get_text( ) TYPE 'E'.

  ENDTRY.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_parent_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IV_PARENT
*&      <-- CT_DATA
*&---------------------------------------------------------------------*

FORM get_parent_data
  USING    iv_parent TYPE tabname
  CHANGING ct_data   TYPE STANDARD TABLE.


  DATA: ls_cache      TYPE ty_table_keys,
        lo_data       TYPE REF TO data,
        lv_where_line TYPE string,
        lv_count      TYPE i.

  FIELD-SYMBOLS: <fs_parent> TYPE STANDARD TABLE.

  READ TABLE gt_table_keys INTO ls_cache
       WITH KEY tabname = iv_parent.
  IF sy-subrc = 0.
    CREATE DATA lo_data TYPE STANDARD TABLE OF (iv_parent).
    ASSIGN lo_data->* TO <fs_parent>.

    IF ls_cache-is_multi = abap_true.
      CLEAR lt_chunk.

      LOOP AT ls_cache-keys INTO lv_where_line.

        APPEND lv_where_line TO lt_chunk.
        ADD 1 TO lv_count.

        IF lv_count >= gv_pakage.

          PERFORM select_dynamic_where
            USING    iv_parent
                     ' '
                     lt_chunk
            CHANGING <fs_parent>.

          CLEAR: lt_chunk, lv_count.

        ENDIF.

      ENDLOOP.

      IF lt_chunk IS NOT INITIAL.
        PERFORM select_dynamic_where
          USING    iv_parent
                   ' '"gv_main_key
                   lt_chunk
          CHANGING <fs_parent>.
      ENDIF.

      CLEAR lt_chunk.

    ELSE.

      CLEAR lt_chunk.

      LOOP AT ls_cache-keys INTO lv_where_line.

        APPEND lv_where_line TO lt_chunk.
        ADD 1 TO lv_count.

        IF lv_count >= gv_pakage.

          PERFORM select_dynamic_where
           USING    iv_parent
                    gv_main_key
                    lt_chunk
           CHANGING <fs_parent>.

          CLEAR: lt_chunk, lv_count.

        ENDIF.

      ENDLOOP.

      IF lt_chunk IS NOT INITIAL.
        PERFORM select_dynamic_where
         USING    iv_parent
                  gv_main_key
                  lt_chunk
         CHANGING <fs_parent>.
      ENDIF.
    ENDIF.

    ct_data[] = <fs_parent>.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form launch_executor_job
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_PAYLOADID
*&---------------------------------------------------------------------*

FORM launch_executor_job USING iv_payload TYPE char32.

  DATA: lv_jobname  TYPE btcjob,
        lv_jobcount TYPE btcjobcnt.

  CONCATENATE 'ZOC_EXEC_' iv_payload+27(5) INTO lv_jobname.

  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      jobname  = lv_jobname
    IMPORTING
      jobcount = lv_jobcount.

  SUBMIT zonpg_oc_any_entity
    WITH p_domain = p_domain
    WITH p_entity = p_entity
    WITH p_payl   = iv_payload
    VIA JOB lv_jobname NUMBER lv_jobcount
    AND RETURN.

  CALL FUNCTION 'JOB_CLOSE'
    EXPORTING
      jobname   = lv_jobname
      jobcount  = lv_jobcount
      strtimmed = 'X'.

  MESSAGE 'Job launched in background' TYPE 'I'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form load_free_selections
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM load_free_selections .

  IMPORT gt_field_ranges gv_where
    FROM DATABASE indx(st)
    ID p_payl.

ENDFORM.
