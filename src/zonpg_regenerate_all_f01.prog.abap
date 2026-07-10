*----------------------------------------------------------------------*
***INCLUDE ZONPG_REGENERATE_ALL_F01.

*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form process_Data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*

FORM process_data.

  DATA: lt_objects TYPE STANDARD TABLE OF e071,
        lv_pos     TYPE e071-as4pos,
        lv_post    TYPE e071k-as4pos,
        ls_e071    LIKE LINE OF gt_e071,
        ls_ddic    LIKE LINE OF gt_ddic,
        lt_ddic_or TYPE STANDARD TABLE OF zonta_oc_ddic.

  FIELD-SYMBOLS: <fs_e071> LIKE LINE OF gt_e071,
                 <fs_ddic> LIKE LINE OF gt_ddic_or.

  SELECT *
  FROM zonta_obj_oc
  INTO TABLE gt_entities
  WHERE domainv IN s_domain[]
    AND business_proc IN s_entity.

  IF sy-subrc = 0.

    " Let user choose request
    CALL FUNCTION 'TRINT_ORDER_CHOICE'
      EXPORTING
        wi_order_type          = 'K'
        wi_task_type           = 'S'
        wi_category            = 'SYST'
      IMPORTING
        we_order               = gv_order
        we_task                = gv_task
      TABLES
        wt_e071                = gt_e071
        wt_e071k               = gt_e071k
      EXCEPTIONS
        no_correction_selected = 1
        display_mode           = 2
        object_append_error    = 3
        recursive_call         = 4
        wrong_order_type       = 5
        OTHERS                 = 6.

    LOOP AT gt_entities INTO gs_entity.

      CLEAR: gt_ddic[].

* Delete structures before saving
      IF go_json IS INITIAL.
        CREATE OBJECT go_json.
      ELSE.
        FREE go_json.
        CREATE OBJECT go_json.
      ENDIF.

      TRY.
          go_json->set_trkorr( EXPORTING iv_tkorr = gv_order ).
        CATCH cx_root INTO gx_text.
      ENDTRY.

      SELECT *
        INTO TABLE gt_ddic_or
        FROM zonta_oc_ddic
        WHERE  id = gs_entity-id
          AND domainv = gs_entity-domainv
          AND business_proc = gs_entity-business_proc.

      TRY.
          CALL METHOD go_json->delete_json_ddic
            EXPORTING
              iv_domainv       = gs_entity-domainv
              iv_business_proc = gs_entity-business_proc.

          go_json->create_json_ddic( iv_domainv       = gs_entity-domainv
                                     iv_business_proc = gs_entity-business_proc ).

          CALL METHOD go_json->get_objects
            IMPORTING
              et_ddic    = gt_ddic[]
              et_objects = lt_objects[].

        CATCH cx_root INTO gx_text.

      ENDTRY.


      LOOP AT lt_objects INTO ls_e071.
        APPEND INITIAL LINE TO gt_e071 ASSIGNING <fs_e071>.
        lv_pos = lv_pos + 1.
        MOVE-CORRESPONDING ls_e071 TO <fs_e071>.
        <fs_e071>-trkorr      = gv_task.
        <fs_e071>-as4pos      = lv_pos.
      ENDLOOP.

      lt_ddic_or[] = gt_ddic_or[].
      REFRESH gt_ddic_or.
      SORT gt_ddic BY object.
      LOOP AT lt_ddic_or INTO ls_ddic.
        READ TABLE gt_ddic TRANSPORTING NO FIELDS WITH KEY object = ls_ddic-object.
        IF sy-subrc NE 0.
          APPEND INITIAL LINE TO gt_ddic_or ASSIGNING <fs_ddic>.
          MOVE-CORRESPONDING ls_ddic TO <fs_ddic>.
        ENDIF.
      ENDLOOP.

      IF lines( gt_ddic_or ) > 0.
        PERFORM save_entries_into_tr TABLES gt_ddic_or[] USING 'D'.
      ENDIF.

      PERFORM save_entries_into_tr TABLES gt_ddic[]    USING 'K'.
      REFRESH gt_e071.

      IF lines( gt_ddic ) > 0.
        DELETE FROM zonta_oc_ddic WHERE id = gs_entity-id.
      ENDIF.

      MODIFY zonta_oc_ddic FROM TABLE gt_ddic.
      IF sy-subrc = 0.
        COMMIT WORK.
      ENDIF.
    ENDLOOP.
  ENDIF.


ENDFORM.

*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form save_old_entries_into_tr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_entries_into_tr  TABLES pt_ddic STRUCTURE zonta_oc_ddic
                           USING p_mode   TYPE e071-objfunc.


  TYPES: BEGIN OF st_tlock,
           object TYPE trobjtype,
           key    TYPE trobj_name,
           hikey  TYPE c LENGTH 120, "lockarg,
           lokey  TYPE c LENGTH 120, "lockarg,
           trkorr TYPE trkorr,
         END OF st_tlock.

  DATA: lt_e071      TYPE STANDARD TABLE OF e071,
        lt_e071k     TYPE STANDARD TABLE OF e071k,
        lt_tlock_pr  TYPE STANDARD TABLE OF st_tlock,
        lt_tlock     TYPE STANDARD TABLE OF st_tlock,
        lt_e071_curr TYPE STANDARD TABLE OF e071,
        lt_e071_val  TYPE STANDARD TABLE OF e071,
        ls_ddic      LIKE LINE OF gt_ddic_or,
        ls_e071      TYPE e071,
        lv_error     TYPE abap_bool,
        lt_e070      TYPE STANDARD TABLE OF e070,
        ls_e070      TYPE e070,
        ls_request   TYPE trwbo_request.



  FIELD-SYMBOLS: <fs_e071>  LIKE LINE OF lt_e071,
                 <fs_e071k> LIKE LINE OF lt_e071k,
                 <fs_tlock> TYPE st_tlock.

  CONSTANTS: c_r3tr TYPE c LENGTH 4 VALUE 'R3TR',
             c_tabu TYPE c LENGTH 4 VALUE 'TABU',
             c_star TYPE c LENGTH 1 VALUE '*'.

  APPEND LINES OF gt_e071 TO lt_e071.
  APPEND INITIAL LINE TO lt_e071 ASSIGNING <fs_e071>.
  <fs_e071>-pgmid    = c_r3tr.
  <fs_e071>-object   = c_tabu.
  <fs_e071>-obj_name = 'ZONTA_OC_DDIC'.
  <fs_e071>-objfunc  = 'K'.

  LOOP AT pt_ddic INTO ls_ddic.
    APPEND INITIAL LINE TO lt_e071k ASSIGNING <fs_e071k>.
    <fs_e071k>-pgmid      = c_r3tr.
    <fs_e071k>-object     = c_tabu.
    <fs_e071k>-objname    = 'ZONTA_OC_DDIC'.
    <fs_e071k>-mastertype = c_tabu.
    <fs_e071k>-mastername = 'ZONTA_OC_DDIC'.
    <fs_e071k>-objfunc    = p_mode.
    CONCATENATE sy-mandt
                ls_ddic-id
                ls_ddic-domainv
                ls_ddic-business_proc
                ls_ddic-object
           INTO <fs_e071k>-tabkey RESPECTING BLANKS.
    <fs_e071k>-tabkey+119 = c_star.
  ENDLOOP.


  lt_e071_val[] = lt_e071[].
  DELETE lt_e071_val WHERE object = c_tabu.
  IF lines( lt_e071_val ) > 0.
    lv_error = abap_false.

* Search entries in current transports
    SELECT *
      INTO TABLE lt_e071_curr
      FROM e071
      FOR ALL ENTRIES IN lt_e071_val
      WHERE obj_name = lt_e071_val-obj_name
        AND lockflag = 'X'.
    DELETE lt_e071_curr WHERE trkorr = gv_task.

    IF lines( lt_e071_curr ) > 0.
* Search for Modifiable transports
      SELECT *
        INTO TABLE lt_e070
        FROM e070
        FOR ALL ENTRIES IN lt_e071_curr
        WHERE trkorr = lt_e071_curr-trkorr
          AND trstatus NE 'R'.
      IF sy-subrc = 0.
      ENDIF.
    ENDIF.
  ENDIF.

* Check for lock transports
  IF lines( lt_e071_curr ) > 0.
    CLEAR lt_tlock.
    LOOP AT lt_e071_curr INTO ls_e071.
      APPEND INITIAL LINE TO lt_tlock ASSIGNING <fs_tlock>.
      <fs_tlock>-trkorr = ls_e071-trkorr.
    ENDLOOP.

    SORT lt_tlock BY trkorr.
    DELETE ADJACENT DUPLICATES FROM lt_tlock COMPARING trkorr.
    PERFORM unlock_tr_entries TABLES lt_tlock[].
  ENDIF.

  IF lv_error = abap_true.
    MESSAGE e026(zon_cl_oc) DISPLAY LIKE 'I'.
  ELSE.

    WAIT UP TO 3 SECONDS.
    CALL FUNCTION 'TR_APPEND_TO_COMM_OBJS_KEYS'
      EXPORTING
        wi_trkorr                      = gv_task
        wi_suppress_key_check          = ' '  "FIXDB
      TABLES
        wt_e071                        = lt_e071
        wt_e071k                       = lt_e071k
      EXCEPTIONS
        key_char_in_non_char_field     = 1
        key_check_keysyntax_error      = 2
        key_inttab_table               = 3
        key_longer_field_but_no_generc = 4
        key_missing_key_master_fields  = 5
        key_missing_key_tablekey       = 6
        key_non_char_but_no_generic    = 7
        key_no_key_fields              = 8
        key_string_longer_char_key     = 9
        key_table_has_no_fields        = 10
        key_table_not_activ            = 11
        key_unallowed_key_function     = 12
        key_unallowed_key_object       = 13
        key_unallowed_key_objname      = 14
        key_unallowed_key_pgmid        = 15
        key_without_header             = 16
        ob_check_obj_error             = 17
        ob_devclass_no_exist           = 18
        ob_empty_key                   = 19
        ob_generic_objectname          = 20
        ob_ill_delivery_transport      = 21
        ob_ill_lock                    = 22
        ob_ill_parts_transport         = 23
        ob_ill_source_system           = 24
        ob_ill_system_object           = 25
        ob_ill_target                  = 26
        ob_inttab_table                = 27
        ob_local_object                = 28
        ob_locked_by_other             = 29
        ob_modif_only_in_modif_order   = 30
        ob_name_too_long               = 31
        ob_no_append_of_corr_entry     = 32
        ob_no_append_of_c_member       = 33
        ob_no_consolidation_transport  = 34
        ob_no_original                 = 35
        ob_no_shared_repairs           = 36
        ob_no_systemname               = 37
        ob_no_systemtype               = 38
        ob_no_tadir                    = 39
        ob_no_tadir_not_lockable       = 40
        ob_privat_object               = 41
        ob_repair_only_in_repair_order = 42
        ob_reserved_name               = 43
        ob_syntax_error                = 44
        ob_table_has_no_fields         = 45
        ob_table_not_activ             = 46
        tr_enqueue_failed              = 47
        tr_errors_in_error_table       = 48
        tr_ill_korrnum                 = 49
        tr_lockmod_failed              = 50
        tr_lock_enqueue_failed         = 51
        tr_not_owner                   = 52
        tr_no_systemname               = 53
        tr_no_systemtype               = 54
        tr_order_not_exist             = 55
        tr_order_released              = 56
        tr_order_update_error          = 57
        tr_wrong_order_type            = 58
        ob_invalid_target_system       = 59
        tr_no_authorization            = 60
        ob_wrong_tabletyp              = 61
        ob_wrong_category              = 62
        ob_system_error                = 63
        ob_unlocal_objekt_in_local_ord = 64
        tr_wrong_client                = 65
        ob_wrong_client                = 66
        key_wrong_client               = 67
        OTHERS                         = 68.
    IF sy-subrc <> 0.
      MESSAGE ID syst-msgid TYPE syst-msgty NUMBER syst-msgno WITH syst-msgv1 syst-msgv2 syst-msgv3 syst-msgv4.
    ELSE.
* sort and compress original task
      CALL FUNCTION 'TR_SORT_AND_COMPRESS_COMM'
        EXPORTING
          iv_trkorr                      = gv_task
          iv_dialog                      = ' '
        EXCEPTIONS
          trkorr_not_found               = 1
          order_released                 = 2
          error_while_modifying_obj_list = 3
          tr_enqueue_failed              = 4
          no_authorization               = 5
          OTHERS                         = 6.

* Unlock entries from the new transport
      REFRESH lt_tlock.
      APPEND INITIAL LINE TO lt_tlock ASSIGNING <fs_tlock>.
      <fs_tlock>-trkorr = gv_task.
      IF lines( lt_tlock ) > 0.
        PERFORM unlock_tr_entries TABLES lt_tlock[].
      ENDIF.

      MESSAGE s027(zon_cl_oc) WITH zonta_obj_oc-business_proc gv_order DISPLAY LIKE 'S'.
    ENDIF.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form unlock_tr_entries
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_TLOCK[]
*&---------------------------------------------------------------------*
FORM unlock_tr_entries TABLES   p_tlock .

  TYPES: BEGIN OF st_tlock,
           object TYPE trobjtype,
           key    TYPE trobj_name,
           hikey  TYPE c LENGTH 120, "lockarg,
           lokey  TYPE c LENGTH 120, "lockarg,
           trkorr TYPE trkorr,
         END OF st_tlock.

  DATA: ls_tlock   TYPE   st_tlock,
        ls_request TYPE trwbo_request,
        ls_h       TYPE trwbo_request_header.

  LOOP AT p_tlock INTO ls_tlock.
* Unlock the entries
    CLEAR ls_request.

    PERFORM enqueue_tr USING ls_tlock-trkorr.
    ls_h-trkorr = ls_tlock-trkorr.
    ls_request-h = ls_h.

    CALL FUNCTION 'TRINT_UNLOCK_REQUEST'
      EXPORTING
        iv_safe_mode           = ' '
      CHANGING
        cs_request             = ls_request
      EXCEPTIONS
        db_access_error        = 1
        object_enqueues        = 2
        no_authority           = 3
        request_not_changeable = 4
        OTHERS                 = 5.
    PERFORM dequeue_tr USING ls_tlock-trkorr.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form dequeue_tr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_TLOCK_TRKORR
*&---------------------------------------------------------------------*
FORM dequeue_tr  USING    p_trkorr.

  CALL FUNCTION 'DEQUEUE_E_TRKORR'
    EXPORTING
      trkorr = p_trkorr.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form enqueue_tr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_TLOCK_TRKORR
*&---------------------------------------------------------------------*
FORM enqueue_tr  USING    p_trkorr.
  CALL FUNCTION 'ENQUEUE_E_TRKORR'
    EXPORTING
      trkorr = p_trkorr.
ENDFORM.
