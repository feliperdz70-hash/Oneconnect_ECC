PROCESS BEFORE OUTPUT.
  MODULE status_0400.
  module initialize_0400.

PROCESS AFTER INPUT.
  module dynp_exit_0400 at exit-command.

  FIELD rs38q-CLENG   VALUES ('   ', BETWEEN '001' AND '999').
  FIELD rs38q-DECNUMB VALUES ('  ',  BETWEEN '01'  AND '30').

  chain.
     field: g_dyn_0400-rad_searchtext,
            g_dyn_0400-searchtext,
            g_dyn_0400-rad_searchdom,
            g_dyn_0400-searchdom,
            g_dyn_0400-rad_searchtype,
            rs38q-dtype,
            rs38q-cleng,
            rs38q-decnumb,
            g_dyn_0400-rad_searchline,
            g_dyn_0400-rad_searchcur,
            g_dyn_0400-rad_searchfir.
     MODULE pai_0400.
  endchain.

PROCESS ON VALUE-REQUEST.
  FIELD g_dyn_0400-searchdom MODULE F4_DOMAIN_0400.

