PROCESS BEFORE OUTPUT.

  MODULE CUA_PBO.
  MODULE CLEAR_OKCODE.

*----------------------------------------------------------------------*

PROCESS AFTER INPUT.

  MODULE EXIT AT EXIT-COMMAND.
  FIELD RS38Q-CLENG   VALUES ('   ', BETWEEN '001' AND '999').
  FIELD RS38Q-DECNUMB VALUES ('  ',  BETWEEN '01'  AND '30').
  CHAIN.
    FIELD: RS38Q-SEARCHTEXT,
           RS38Q-SEARCHDOM,
           RS38Q-SEARCHTYPE,
           RS38Q-SEARCH,
           RS38Q-DOMNAME,
           RS38Q-DTYPE,
           RS38Q-CLENG,
           RS38Q-DECNUMB,
           RS38Q-SEARCHLINE,
           RS38Q-SEARCHCUR,
           RS38Q-SEARCHFIR.
           MODULE USER_COMMAND_0060.
  ENDCHAIN.

*----------------------------------------------------------------------*

PROCESS ON VALUE-REQUEST.

  FIELD RS38Q-DOMNAME MODULE F4_DOMAENE.

*----------------------------------------------------------------------*

PROCESS ON HELP-REQUEST.

  FIELD: RS38Q-SEARCHTEXT WITH '1450',           " AQ_MARK
         RS38Q-SEARCHDOM  WITH '1451',           " AQ_MARK
         RS38Q-SEARCHTYPE WITH '1452',           " AQ_MARK
         RS38Q-DOMNAME    WITH '0145'.           " AQ_DOM
