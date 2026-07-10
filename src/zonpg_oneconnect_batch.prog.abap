*&---------------------------------------------------------------------*
*& Report ZONPG_ONECONNECT_BATCH
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zonpg_oneconnect_batch.

DATA  gt_where TYPE zonttrsdswhere .
DATA  gt_where_cond_tab TYPE rsds_twhere.
DATA: lt_batch TYPE STANDARD TABLE OF zonta_oc_batch,
      ls_batch TYPE zonta_oc_batch.


DATA: lv_jobname  TYPE tbtco-jobname,
      lv_jobcount TYPE tbtco-jobcount.

DATA: gv_id TYPE char30,
      lv_id TYPE char30.

PARAMETERS:p_execid TYPE zonde_idj,
           p_domain TYPE zonde_domain,
           p_busine TYPE zonde_process,
           p_kdoc   TYPE boolean,
           p_alias  TYPE boolean,
           p_both   TYPE boolean,
           p_table  TYPE boolean,
           p_dest   TYPE rfcdest,
           p_uzeit  TYPE sy-uzeit DEFAULT sy-uzeit,
           p_anytab TYPE boolean,
           p_tabnam TYPE tabname,
           p_var    TYPE variant.

START-OF-SELECTION.


* Get job information|
  CALL FUNCTION 'GET_JOB_RUNTIME_INFO'
    IMPORTING
      jobcount        = lv_jobcount
      jobname         = lv_jobname
    EXCEPTIONS
      no_runtime_info = 1
      OTHERS          = 2.

  gv_id = p_execid.

  IF p_var IS INITIAL.
    TRY.
        IF gv_id+14  = 'C'.
          IMPORT wheret = gt_where_cond_tab FROM DATABASE zontconnectbatch(sc) ID gv_id.
        ELSE.
          IMPORT where = gt_where FROM DATABASE zontconnectbatch(sc) ID gv_id .
        ENDIF.
      CATCH cx_sy_import_mismatch_error.
    ENDTRY.
  ELSE.
    PERFORM get_variant_values.
  ENDIF.



  IF NOT gt_where IS INITIAL OR
     NOT gt_where_cond_tab IS INITIAL.

    CALL FUNCTION 'ZONFM_ONE_CONNECT_BATCH'
      EXPORTING
        iv_domainv        = p_domain
        iv_business_proc  = p_busine
        iv_kdoc           = p_kdoc
        iv_table          = p_table
        iv_dest           = p_dest
        it_where          = gt_where
        iv_any_table      = p_anytab
        iv_tabname        = p_tabnam
        iv_update         = abap_true
        iv_alias          = p_alias
        iv_both           = p_both
        it_where_cond_tab = gt_where_cond_tab.
  ENDIF.



* Delete memory for non periodic jobs

  SELECT *
    INTO TABLE lt_batch
    FROM zonta_oc_batch
    WHERE domainv       = p_domain
      AND business_proc = p_busine
      AND execid        = p_execid.

  IF sy-subrc = 0.
*   Mark the job as finished in the control table
    SORT lt_batch BY created_on DESCENDING created_at DESCENDING.
    READ TABLE lt_batch INTO ls_batch INDEX 1.

    IF ls_batch-periodic = abap_false.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
      DELETE FROM DATABASE zontconnectbatch(sc) ID gv_id.
      IF sy-subrc = 0.
        ls_batch-memory_deleted = abap_true.
      ENDIF.
      ls_batch-status = 'F'.
    ENDIF.

    ls_batch-changed_by = sy-uname.
    ls_batch-changed_on = sy-datum.
    ls_batch-changed_at = sy-uzeit.
    ls_batch-child_jobname = lv_jobname.
    ls_batch-child_jobcount = lv_jobcount.

    MODIFY zonta_oc_batch FROM ls_batch.
    IF sy-subrc = 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
    ENDIF.
  ENDIF.

  INCLUDE zonpg_oneconnect_batch_f01.
