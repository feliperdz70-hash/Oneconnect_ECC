PROCESS BEFORE OUTPUT.

  MODULE CUA_PBO.
  MODULE CLEAR_OKCODE.

*----------------------------------------------------------------------*

PROCESS AFTER INPUT.

  MODULE EXIT AT EXIT-COMMAND.
  CHAIN.
    FIELD: RS38Q-DDICTAB,
           RS38Q-ALIASTAB.
           MODULE USER_COMMAND_0069.
  ENDCHAIN.

*----------------------------------------------------------------------*

PROCESS ON VALUE-REQUEST.

  FIELD RS38Q-DDICTAB MODULE ALIAS_TABLE_F4.
