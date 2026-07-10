
*---------------------------------------------------------------------*
* INCLUDE ZONIN_OC_ANY_WORKER_F01
*---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form process_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM process_table.


  DATA: lo_data    TYPE REF TO data.
  DATA: lt_chunk   TYPE STANDARD TABLE OF string,
        lv_count   TYPE i VALUE 0,
        lv_lpakage TYPE zonta_oc_param-low,
        lv_pakage  TYPE i,
        lv_alias   TYPE boolean.

  CREATE DATA lo_data TYPE STANDARD TABLE OF (p_table).
  ASSIGN lo_data->* TO <fs_table>.

  IF gt_root_keys IS INITIAL. "OR p_field IS INITIAL.
    RETURN.
  ENDIF.


  SELECT SINGLE low
    INTO lv_lpakage
    FROM zonta_oc_param
    WHERE name = 'BATCH_SPLIT_SELECT'.
  IF sy-subrc = 0.
    lv_pakage = lv_lpakage.
  ELSE.
    lv_pakage = 1000.
  ENDIF.

  CLEAR lv_alias.
  SELECT SINGLE low
    INTO lv_alias
    FROM zonta_oc_param
    WHERE name = 'USE_ALIAS'.
  IF sy-subrc = 0.
    lv_alias = abap_true.
  ENDIF.

  LOOP AT gt_root_keys INTO DATA(lv_key).

    APPEND lv_key TO lt_chunk.
    ADD 1 TO lv_count.

    IF lv_count >= lv_pakage.

      PERFORM select_dynamic_where
        USING    p_table
                 p_field
                 lt_chunk
        CHANGING <fs_table>.

      CLEAR: lt_chunk, lv_count.

    ENDIF.

  ENDLOOP.

* Last Chunk
  IF lt_chunk IS NOT INITIAL.

    PERFORM select_dynamic_where
      USING    p_table
               p_field
               lt_chunk
      CHANGING <fs_table>.

  ENDIF.

* Send
  IF <fs_table> IS NOT INITIAL.

    go_handler->send_json_any_table_ltables(
      EXPORTING
        iv_tabname              = p_table
        iv_aliastablong         = p_alias
        iv_entity_business_proc = 'ANY'
        iv_dest                 = p_dest
        iv_delete               = ''
        iv_update               = 'X'
        iv_alias                = lv_alias
        it_tables_data          = <fs_table> ).

  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form select_dynamic_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM select_dynamic_where
  USING    iv_table TYPE tabname
           iv_field TYPE fieldname
           it_keys  TYPE ANY TABLE
  CHANGING ct_data  TYPE ANY TABLE.

  DATA: lv_where TYPE string,
        lv_key   TYPE string,
        lv_list  TYPE string,
        lv_lines TYPE i.

* Validation
  DESCRIBE TABLE it_keys LINES lv_lines.
  IF lv_lines = 0.
    RETURN.
  ENDIF.

* Clear duplicates
  SORT it_keys.
  DELETE ADJACENT DUPLICATES FROM it_keys.

*---------------------------------------------------------------------*
* # MULTIKEY MODE (NO iv_field)
*---------------------------------------------------------------------*
  IF iv_field IS INITIAL.

    LOOP AT it_keys INTO lv_key.

      IF lv_where IS INITIAL.
        lv_where = lv_key.
      ELSE.
        CONCATENATE lv_where 'OR' lv_key INTO lv_where SEPARATED BY space.
      ENDIF.

    ENDLOOP.

*---------------------------------------------------------------------*
* # SINGLE KEY MODE (IN)
*---------------------------------------------------------------------*
  ELSE.

    LOOP AT it_keys INTO lv_key.

      REPLACE ALL OCCURRENCES OF '''' IN lv_key WITH ''''''.

      IF lv_list IS INITIAL.
        CONCATENATE '''' lv_key '''' INTO lv_list.
      ELSE.
        CONCATENATE lv_list ',''' lv_key '''' INTO lv_list.
      ENDIF.

    ENDLOOP.

    CONCATENATE iv_field 'IN (' lv_list ')' INTO lv_where SEPARATED BY space.

  ENDIF.

*---------------------------------------------------------------------*
* EXECUTE
*---------------------------------------------------------------------*
  TRY.
      SELECT *
        FROM (iv_table)
        APPENDING TABLE ct_data
        WHERE (lv_where).
    CATCH cx_sy_dynamic_osql_semantics INTO DATA(lx_sql).
      MESSAGE lx_sql->get_text( ) TYPE 'E'.
  ENDTRY.

ENDFORM.

****---------------------------------------------------------------------*
**** INCLUDE ZONIN_OC_ANY_WORKER_F01
****---------------------------------------------------------------------*
***
****&---------------------------------------------------------------------*
****& Form process_table
****&---------------------------------------------------------------------*
****& text
****&---------------------------------------------------------------------*
****& -->  p1        text
****& <--  p2        text
****&---------------------------------------------------------------------*
***FORM process_table.
***
***
***  DATA: lo_data       TYPE REF TO data.
***  DATA: lt_chunk      TYPE STANDARD TABLE OF string,
***        lv_count      TYPE i VALUE 0,
***        lv_lpakage    TYPE zonta_oc_param-low,
***        lv_pakage     TYPE i,
***        lv_alias      TYPE boolean,
***        lv_jobname    TYPE btcjob,
***        lv_jobcount   TYPE btcjobcnt,
***        lv_where_line TYPE string,
***        lv_key        LIKE LINE OF gt_root_keys.
***
***  DATA: lv_max_jobs    TYPE i VALUE 5,
***        lv_active_jobs TYPE i VALUE 0,
***        lv_over        TYPE i.
***
***  DATA: lv_total  TYPE i,
***        lv_index  TYPE i,
***        lv_indexc TYPE c LENGTH 12.
***
***  DATA: lv_lines TYPE i.
***
***  DATA: lo_split         TYPE REF TO data,
***        lv_payload_split TYPE c LENGTH 32.
***
***  FIELD-SYMBOLS: <fs_split> TYPE STANDARD TABLE,
***                 <fs_line>  TYPE any.
***
***  CREATE   DATA lo_data TYPE STANDARD TABLE OF (p_table).
***  ASSIGN lo_data->* TO <fs_table>.
***
***  IF gt_root_keys IS INITIAL. "OR p_field IS INITIAL.
***    RETURN.
***  ENDIF.
***
***
***  SELECT SINGLE low
***    INTO lv_lpakage
***    FROM zonta_oc_param
***    WHERE name = 'BATCH_SPLIT_SELECT'.
***  IF sy-subrc = 0.
***    lv_pakage = lv_lpakage.
***  ELSE.
***    lv_pakage = 1000.
***  ENDIF.
***
***  CLEAR lv_alias.
***  SELECT SINGLE low
***    INTO lv_alias
***    FROM zonta_oc_param
***    WHERE name = 'USE_ALIAS'.
***  IF sy-subrc = 0.
***    lv_alias = abap_true.
***  ENDIF.
***
***  LOOP AT gt_root_keys INTO lv_key.
***
***    APPEND lv_key TO lt_chunk.
***    ADD 1 TO lv_count.
***
***    IF lv_count >= lv_pakage.
***
***      PERFORM select_dynamic_where
***        USING    p_table
***                 p_field
***                 lt_chunk
***        CHANGING <fs_table>.
***
***      CLEAR: lt_chunk, lv_count.
***    ENDIF.
***
***  ENDLOOP.
***
**** Last Chunk
***  IF lt_chunk IS NOT INITIAL.
***
***    PERFORM select_dynamic_where
***      USING    p_table
***               p_field
***               lt_chunk
***      CHANGING <fs_table>.
***
***  ENDIF.
***
***
***  IF gv_split = 0.
**** # si no necesita split, manda normal
***    go_handler->send_json_any_table_ltables(
***      EXPORTING
***        iv_tabname              = p_table
***        iv_aliastablong         = p_alias
***        iv_entity_business_proc = 'ANY'
***        iv_dest                 = p_dest
***        iv_delete               = ''
***        iv_update               = 'X'
***        iv_alias                = lv_alias
***        it_tables_data          = <fs_table> ).
***
***  ELSE.
***    DATA: lv_count_split TYPE i,
***          lv_split_no    TYPE i,
***          lv_splitc      TYPE string.
***
***    DESCRIBE TABLE <fs_table> LINES lv_lines.
***
***    IF lv_lines > gv_split.
***
***      WRITE: / 'Split jobs will be generated'.
***      WRITE: / 'Number of records', lv_lines.
***
***      CREATE DATA lo_split TYPE STANDARD TABLE OF (p_table).
***      ASSIGN lo_split->* TO <fs_split>.
***
***      CLEAR: <fs_split>, lv_count_split, lv_split_no.
***
***      LOOP AT <fs_table> ASSIGNING <fs_line>.
***
***        APPEND <fs_line> TO <fs_split>.
***        ADD 1 TO lv_count_split.
***
***        IF lv_count_split >= gv_split.
***
***          ADD 1 TO lv_split_no.
***          lv_splitc = lv_split_no.
***
***          CONCATENATE 'ZOC_S_' p_table '_' lv_splitc INTO  lv_payload_split.
***
***          EXPORT <fs_split>
***            TO DATABASE indx(sw)
***            ID lv_payload_split.
***
***          PERFORM wait_for_jobs_prefix USING 'ZON%' 5.
***
***          CONCATENATE 'ZOC_S_' p_table '_' lv_splitc
***            INTO lv_jobname.
***
***          CALL FUNCTION 'JOB_OPEN'
***            EXPORTING
***              jobname  = lv_jobname
***            IMPORTING
***              jobcount = lv_jobcount.
***
***          SUBMIT zonpg_oc_any_worker_split
***            WITH p_table = p_table
***            WITH p_alias = p_alias
***            WITH p_dest  = p_dest
***            WITH p_payl  = lv_payload_split
***            VIA JOB lv_jobname NUMBER lv_jobcount
***            AND RETURN.
***
***          CALL FUNCTION 'JOB_CLOSE'
***            EXPORTING
***              jobname   = lv_jobname
***              jobcount  = lv_jobcount
***              strtimmed = 'X'.
***
***          CLEAR: <fs_split>, lv_count_split.
***
***        ENDIF.
***
***      ENDLOOP.
***
**** Último chunk: aquí ya quedaron SOLO los registros pendientes
***      IF <fs_split> IS NOT INITIAL.
***
***        ADD 1 TO lv_split_no.
***        lv_splitc = lv_split_no.
***
****        CONCATENATE p_payl '_' lv_splitc INTO lv_payload_split.
***        CONCATENATE 'ZOC_S_' p_table '_' lv_splitc INTO  lv_payload_split.
***
***        EXPORT <fs_split>
***          TO DATABASE indx(sw)
***          ID lv_payload_split.
***
***        PERFORM wait_for_jobs_prefix USING 'ZON%' 5.
***
***        CONCATENATE 'ZOC_S_' p_table '_' lv_splitc
***          INTO lv_jobname.
***
***        CALL FUNCTION 'JOB_OPEN'
***          EXPORTING
***            jobname  = lv_jobname
***          IMPORTING
***            jobcount = lv_jobcount.
***
***        SUBMIT zonpg_oc_any_worker_split
***          WITH p_table = p_table
***          WITH p_alias = p_alias
***          WITH p_dest  = p_dest
***          WITH p_payl  = lv_payload_split
***          VIA JOB lv_jobname NUMBER lv_jobcount
***          AND RETURN.
***
***        CALL FUNCTION 'JOB_CLOSE'
***          EXPORTING
***            jobname   = lv_jobname
***            jobcount  = lv_jobcount
***            strtimmed = 'X'.
***
***        CLEAR: <fs_split>, lv_count_split.
***
***      ENDIF.
***
***    ENDIF.
***
***
***  ENDIF.
***
*****
*****  IF lines( <fs_table> ) > gv_split.
*****
*****
****** JOB
*****    CONCATENATE 'ZOC_ANY_' lv_table '_' lv_payloadid+27(5)
*****      INTO lv_jobname.
*****
*****    IF sy-batch = abap_true.
*****
*****      CALL FUNCTION 'JOB_OPEN'
*****        EXPORTING
*****          jobname  = lv_jobname
*****        IMPORTING
*****          jobcount = lv_jobcount.
*****
*****      SUBMIT zonpg_oc_any_worker_split
*****        WITH p_table = lv_table
*****        WITH p_field = lv_field_to_use
*****        WITH p_alias = p_alias
*****        WITH p_dest  = p_dest
*****        WITH p_payl  = lv_payloadid
*****        WITH p_uali  = lv_ali
*****        VIA JOB lv_jobname NUMBER lv_jobcount
*****        AND RETURN.
*****
*****      CALL FUNCTION 'JOB_CLOSE'
*****        EXPORTING
*****          jobname   = lv_jobname
*****          jobcount  = lv_jobcount
*****          strtimmed = 'X'.
*****
****** Progress
*****      lv_percent = lv_index * 100 / lv_total.
*****
*****      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
*****        EXPORTING
*****          percentage = lv_percent
*****          text       = |Launching { lv_table } ({ lv_index }/{ lv_total })|.
*****
*****      ADD 1 TO lv_active_jobs.
*****
*****      IF lv_active_jobs >= lv_max_jobs.
*****
*****        PERFORM wait_for_jobs USING lv_payloadid
*****                                   lv_max_jobs.
*****
*****        CLEAR lv_active_jobs.
*****
*****      ENDIF.
*****
*****
*****      MESSAGE |All jobs launched successfully ({ lv_total })| TYPE 'S'.
*****
*****    ELSE.
****** Send
*****      IF <fs_table> IS NOT INITIAL.
*****
*****        go_handler->send_json_any_table_ltables(
*****          EXPORTING
*****            iv_tabname              = p_table
*****            iv_aliastablong         = p_alias
*****            iv_entity_business_proc = 'ANY'
*****            iv_dest                 = p_dest
*****            iv_delete               = ''
*****            iv_update               = 'X'
*****            iv_alias                = lv_alias
*****            it_tables_data          = <fs_table> ).
*****
*****      ENDIF.
*****    ENDIF.
***
***ENDFORM.
***
****&---------------------------------------------------------------------*
****& Form select_dynamic_table
****&---------------------------------------------------------------------*
****& text
****&---------------------------------------------------------------------*
****& -->  p1        text
****& <--  p2        text
****&---------------------------------------------------------------------*
***FORM select_dynamic_where
***  USING    iv_table TYPE tabname
***           iv_field TYPE fieldname
***           it_keys  TYPE ANY TABLE
***  CHANGING ct_data  TYPE ANY TABLE.
***
***  DATA: lv_where TYPE string,
***        lv_key   TYPE string,
***        lv_list  TYPE string,
***        lv_lines TYPE i.
***
**** Validation
***  DESCRIBE TABLE it_keys LINES lv_lines.
***  IF lv_lines = 0.
***    RETURN.
***  ENDIF.
***
**** Clear duplicates
***  SORT it_keys.
***  DELETE ADJACENT DUPLICATES FROM it_keys.
***
****---------------------------------------------------------------------*
**** # MULTIKEY MODE (NO iv_field)
****---------------------------------------------------------------------*
***  IF iv_field IS INITIAL.
***
***    LOOP AT it_keys INTO lv_key.
***
***      IF lv_where IS INITIAL.
***        lv_where = lv_key.
***      ELSE.
***        CONCATENATE lv_where 'OR' lv_key INTO lv_where SEPARATED BY space.
***      ENDIF.
***
***    ENDLOOP.
***
****---------------------------------------------------------------------*
**** # SINGLE KEY MODE (IN)
****---------------------------------------------------------------------*
***  ELSE.
***
***    LOOP AT it_keys INTO lv_key.
***
***      REPLACE ALL OCCURRENCES OF '''' IN lv_key WITH ''''''.
***
***      IF lv_list IS INITIAL.
***        CONCATENATE '''' lv_key '''' INTO lv_list.
***      ELSE.
***        CONCATENATE lv_list ',''' lv_key '''' INTO lv_list.
***      ENDIF.
***
***    ENDLOOP.
***
***    CONCATENATE iv_field 'IN (' lv_list ')' INTO lv_where SEPARATED BY space.
***
***  ENDIF.
***
****---------------------------------------------------------------------*
**** EXECUTE
****---------------------------------------------------------------------*
***  TRY.
***      SELECT *
***        FROM (iv_table)
***        APPENDING TABLE ct_data
***        WHERE (lv_where).
***    CATCH cx_sy_dynamic_osql_semantics INTO DATA(lx_sql).
***      MESSAGE lx_sql->get_text( ) TYPE 'E'.
***  ENDTRY.
***
***ENDFORM.
****&---------------------------------------------------------------------*
****&      Form  WAIT_FOR_JOBS_PREFIX
****&---------------------------------------------------------------------*
****       text
****----------------------------------------------------------------------*
****      -->P_0259   text
****      -->P_5      text
****----------------------------------------------------------------------*
***FORM wait_for_jobs_prefix
***  USING iv_prefix TYPE btcjob
***        iv_max    TYPE i.
***
***  DATA: lv_running TYPE i.
***
***  DO.
***
***    SELECT COUNT(*)
***      INTO lv_running
***      FROM tbtco
***      WHERE jobname LIKE iv_prefix
***        AND status  = 'R'. "Running
***
***    IF lv_running < iv_max.
***      EXIT.
***    ENDIF.
***
***    WAIT UP TO 5 SECONDS.
***
***  ENDDO.
***
***ENDFORM.
