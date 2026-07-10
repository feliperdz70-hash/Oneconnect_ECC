PROCESS BEFORE OUTPUT.
  CALL SUBSCREEN sa_300_m INCLUDING sy-repid '0301'.
  CALL SUBSCREEN sa_300_t INCLUDING sy-repid '0302'.
  CALL SUBSCREEN sa_300_c INCLUDING sy-repid '0303'.

  MODULE status_0300.
  MODULE update_screen.
  MODULE init_alv_info_tab.
  MODULE init_alv_info_col.

PROCESS AFTER INPUT.

  CALL SUBSCREEN sa_300_m.
  CALL SUBSCREEN sa_300_t.
  CALL SUBSCREEN sa_300_c.

*MODULE alv_changes.
*BEGIN CECHAVARRIA 13/08/2025
  FIELD zonta_obj_oc-business_proc MODULE f_validate_entityname.
*END CECHAVARRIA 13/08/2025

  MODULE user_command_0300.

PROCESS ON VALUE-REQUEST.
  FIELD zonta_obj_oc-tag1 MODULE f4_tag1.
  FIELD zonta_obj_oc-tag5 MODULE f4_tag5.
