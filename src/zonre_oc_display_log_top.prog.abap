*&---------------------------------------------------------------------*
*&  Include  ZONRE_ONI_DISPLAY_LOG_TOP
*&---------------------------------------------------------------------*


TABLES: zonst_oc_log_ext,
        zonst_oc_log_ext_alv.

DATA: gt_log        TYPE STANDARD TABLE OF zonst_oc_log_ext_alv,
      gv_numc(10)   TYPE n,
      gt_key        TYPE zon_oc_trsdsselopt,
      gt_header     TYPE balhdr_t,
      gt_aux        TYPE balhdr_t,
      gt_log_handle TYPE bal_t_logh,
      gt_msg_handle TYPE bal_t_msgh,
      gt_lock       TYPE balhdr_t.

CLASS lcl_handle_events DEFINITION DEFERRED.

DATA: ls_key TYPE rsdsselopt.
DATA: ob_table        TYPE REF TO cl_salv_table.
DATA: gr_events TYPE REF TO lcl_handle_events.

CONSTANTS: c_i      TYPE char1  VALUE 'I',
           c_eq     TYPE char2  VALUE 'EQ',
           c_x      TYPE char1  VALUE 'X',
           c_green  TYPE icon_d VALUE '@08@',
           c_yellow TYPE icon_d VALUE '@09@',
           c_red    TYPE icon_d VALUE '@0A@',
           c_w      TYPE c      VALUE 'W',
           c_e      TYPE c      VALUE 'E',
           c_s      TYPE c      VALUE 'S'.
