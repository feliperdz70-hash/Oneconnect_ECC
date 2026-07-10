PROCESS BEFORE OUTPUT.
  MODULE STATUS_0500.
  module initialize_0500.
*
PROCESS AFTER INPUT.
  module dynp_exit_0500 at exit-command.
  CHAIN.
    FIELD: RS38Q-DBJOLTAB, RS38Q-DBJORTAB.
    MODULE check_tab_4_join_proposal_0500.
  ENDCHAIN.
  module pai_0500.

process on value-request.
  field rs38q-dbjoltab module f4_ltab_0500.
  field rs38q-dbjortab module f4_rtab_0500.


