*&---------------------------------------------------------------------*
*& Include          ZONIN_OC_SYNCH_METADATA_TOP
*&---------------------------------------------------------------------*
TABLES: zonta_obj_oc.


SELECT-OPTIONS: s_dom FOR zonta_obj_oc-domainv,
                s_ent FOR zonta_obj_oc-business_proc .

PARAMETERS: p_file RADIOBUTTON GROUP grp1 DEFAULT 'X',
            p_prev RADIOBUTTON GROUP grp1,
            p_send RADIOBUTTON GROUP grp1.

PARAMETERS: p_dest TYPE rfcdest.

DATA: gt_entities TYPE STANDARD TABLE OF zonta_obj_oc,
      go_cust     TYPE REF TO zoncl_oc_customizing,
      gs_entities TYPE zonta_obj_oc,
      gv_json     TYPE string,
      gv_file     TYPE filename.
