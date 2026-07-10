interface ZONIF_CODE
  public .


  class-methods SEND_DATA
    importing
      !IV_DATA type ZONTA_OBJ_OC
      !IV_ENTITY type ZONDE_PROCESS
      !IV_DEST type RFCDEST
      !IV_WHERE type ZONDE_WHERE optional .
  class-methods SET_WHERE_CODE
    importing
      !IT_FIELDCAT type SLIS_T_FIELDCAT_ALV
    returning
      value(R_WHERE) type RSDS_WHERE_TAB .
endinterface.
