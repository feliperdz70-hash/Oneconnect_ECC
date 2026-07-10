*&---------------------------------------------------------------------*
*& Report ZONPG_REGENERATE_ALL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zonpg_regenerate_all.

TABLES: zonta_obj_oc.

DATA: gt_entities TYPE STANDARD TABLE OF zonta_obj_oc,
      gt_ddic_or  TYPE STANDARD TABLE OF zonta_oc_ddic,
      gs_entity   TYPE zonta_obj_oc,
      gx_text     TYPE REF TO cx_root,
      go_json     TYPE REF TO zoncl_fetch_data,
      gt_ddic     TYPE STANDARD TABLE OF zonta_oc_ddic.

DATA: gv_order TYPE e071-trkorr,
      gv_task  TYPE e071-trkorr,
      gt_e071  TYPE STANDARD TABLE OF e071,
      gt_e071k TYPE STANDARD TABLE OF e071k.

SELECT-OPTIONS:
          s_domain FOR zonta_obj_oc-domainv,
          s_entity FOR zonta_obj_oc-business_proc.

INCLUDE zonpg_regenerate_all_f01.


START-OF-SELECTION.
  PERFORM process_data.

END-OF-SELECTION.
