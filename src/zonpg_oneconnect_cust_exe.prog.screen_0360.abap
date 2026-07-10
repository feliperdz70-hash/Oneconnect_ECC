PROCESS BEFORE OUTPUT.
  CALL SUBSCREEN sa_300_c INCLUDING sy-repid '0303'.

  MODULE status_0300.
  MODULE update_screen.
  MODULE init_alv_info_col.

PROCESS AFTER INPUT.
  CALL SUBSCREEN sa_300_c.

  MODULE user_command_0300.

PROCESS ON VALUE-REQUEST.
  FIELD zonta_obj_oc-tag1 MODULE f4_tag1.
  FIELD zonta_obj_oc-tag5 MODULE f4_tag5.
