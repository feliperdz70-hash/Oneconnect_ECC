PROCESS BEFORE OUTPUT.
  MODULE status_0300.
  module initialize_0300.

*
PROCESS AFTER INPUT.
  module dynp_exit_0300 at exit-command.
  FIELD: g_dyn_0300-tname MODULE check_for_table_addition_0300.

  MODULE pai_0300.

PROCESS ON VALUE-REQUEST.
  FIELD: g_dyn_0300-tname MODULE F4_tname_0300.


