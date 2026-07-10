*&---------------------------------------------------------------------*
*& Report  ZONPG_CONVERT_COLUMNS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zonpg_convert_columns.

TABLES: zonta_obj_oc.

SELECT-OPTIONS:
s_dom FOR zonta_obj_oc-domainv,
s_bus FOR zonta_obj_oc-business_proc.

DATA: gt_relations   TYPE STANDARD TABLE OF zonta_relations,
      gt_columns_old TYPE STANDARD TABLE OF zonta_oc_columns,
      gt_columns_new TYPE STANDARD TABLE OF zonta_oc_col_all,
      gt_columns_nal TYPE STANDARD TABLE OF zonta_oc_col_all.

DATA: ls_relations LIKE LINE OF gt_relations,
      ls_col_old   LIKE LINE OF gt_columns_old,
      ls_col_new   LIKE LINE OF gt_columns_new,
      lv_id_col    LIKE zonta_oc_col_all-id_column.

FIELD-SYMBOLS: <fs_col> LIKE LINE OF gt_columns_new.

*DELETE FROM zonta_oc_col_all WHERE tabname NE ' '.
SELECT *
  INTO TABLE gt_relations
  FROM zonta_relations
  WHERE domainv IN s_dom
    AND business_proc IN s_bus.

IF sy-subrc = 0.
  SORT gt_relations BY tabname alias_tabname.
  DELETE ADJACENT DUPLICATES FROM gt_relations COMPARING tabname alias_tabname.

  SELECT *
    INTO TABLE gt_columns_old
    FROM zonta_oc_columns
    FOR ALL ENTRIES IN gt_relations
    WHERE domainv = gt_relations-domainv
      AND business_proc = gt_relations-business_proc.
ENDIF.

SELECT MAX( id_column )
  INTO lv_id_col
  FROM zonta_oc_col_all.

lv_id_col = lv_id_col + 1.

LOOP AT gt_relations INTO ls_relations.
  LOOP AT gt_columns_old INTO ls_col_old WHERE domainv = ls_relations-domainv
                                           AND business_proc = ls_relations-business_proc
                                           AND tabname = ls_relations-tabname.
    APPEND INITIAL LINE TO gt_columns_new ASSIGNING <fs_col>.
    MOVE-CORRESPONDING ls_col_old TO <fs_col>.
    <fs_col>-alias_tabname = ls_relations-alias_tabname.
    <fs_col>-id_column = lv_id_col.
  ENDLOOP.

  lv_id_col = lv_id_col + 1.
ENDLOOP.

gt_columns_nal[] = gt_columns_new[].
SORT gt_columns_nal BY tabname alias_tabname.
DELETE ADJACENT DUPLICATES FROM gt_columns_nal COMPARING tabname alias_tabname.

LOOP AT gt_columns_nal INTO ls_col_new.
  DELETE FROM zonta_oc_col_all WHERE tabname = ls_col_new-tabname
                            AND alias_tabname = ls_col_new-alias_tabname.
ENDLOOP.
*DELETE FROM zonta_oc_col_all WHERE tabname NE ' '.

MODIFY zonta_oc_col_all FROM TABLE gt_columns_new.
IF sy-subrc = 0.
  COMMIT WORK.
  MESSAGE e028(zon_cl_oc) DISPLAY LIKE 'I'.
ELSE.
  MESSAGE e029(zon_cl_oc) DISPLAY LIKE 'I'.
ENDIF.
