*&---------------------------------------------------------------------*
*& Report ZONPG_OC_ANY_WORKER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zonpg_oc_any_worker.


INCLUDE zonin_oc_any_worker_top.
INCLUDE zonin_oc_any_worker_f01.


START-OF-SELECTION.

  DATA: lv_low TYPE zonta_oc_param-low.

* Crear handler
  CREATE OBJECT go_handler.


* Obtain the keys
  IMPORT gt_root_keys
    FROM DATABASE indx(st)
    ID p_payl.

  IF sy-subrc <> 0 OR gt_root_keys IS INITIAL.
    MESSAGE 'No root keys received in worker' TYPE 'E'.
  ENDIF.

  SELECT SINGLE low
    INTO lv_low
    FROM zonta_oc_param
    WHERE name = 'BATCH_SPLIT_OVERSIZE_TABLES'.
  IF sy-subrc = 0.
    gv_split = lv_low.
  ELSE.
    CLEAR gv_split.
  ENDIF.

* Execute main logic
  PERFORM process_table.
