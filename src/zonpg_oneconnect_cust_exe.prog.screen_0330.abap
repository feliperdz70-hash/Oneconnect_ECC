PROCESS BEFORE OUTPUT.
  CALL SUBSCREEN sa_300_m INCLUDING sy-repid '0301'.

  MODULE status_0300.
  MODULE update_screen.

PROCESS AFTER INPUT.
  CALL SUBSCREEN sa_300_m.

  MODULE user_command_0300.

PROCESS ON VALUE-REQUEST.
  FIELD zonta_obj_oc-tag1 MODULE f4_tag1.
  FIELD zonta_obj_oc-tag5 MODULE f4_tag5.
