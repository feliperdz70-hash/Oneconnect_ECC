PROCESS BEFORE OUTPUT.
  module initialize_0200.
  module set_status_0200.
  module set_mode_0200.

  LOOP AT gt_dd07t INTO gs_dd07t WITH CONTROL priorities_tab.
    MODULE priorities.
  ENDLOOP.


PROCESS AFTER INPUT.
  LOOP AT gt_dd07t.
    MODULE modify_table_control.
  ENDLOOP.
  module dynp_exit_0200 at exit-command.
  module pai_0200.
