interface ZONIF_OC_DATA_HANDLER
  public .


  types:
    tty_endpoints TYPE STANDARD TABLE OF zonta_oc_endp .
  types:
    tty_where TYPE STANDARD TABLE OF rsdswhere .

  methods SET_CONTEXT
    importing
      !IV_KDOC type BOOLEAN optional
      !IV_TABLE type BOOLEAN optional
      !IV_DDIC type BOOLEAN optional
      !IV_DEST type RFCDEST optional
      !IV_UPDATE type BOOLEAN optional
      !IV_DELETE type BOOLEAN optional
      !IV_DOMAINV type ZONDE_DOMAIN optional
      !IV_ENTITY type ZONDE_PROCESS optional
      !IV_KEY_QUEUE type STRING optional
      !IV_BATCH type BOOLEAN optional
      !IT_WHERE type TTY_WHERE optional
      !IV_INSTID type STRING optional
      !IV_ANYTABLE type BOOLEAN optional
      !IV_ALIAS type BOOLEAN optional
      !IV_FIELDNAME type BOOLEAN optional
      !IV_TAGDATA type BOOLEAN optional
      !IV_TAGMETADATA type BOOLEAN optional
      !IV_BOTHNAMES type BOOLEAN optional
      !IT_ENDPOINTS type TTY_ENDPOINTS optional
      !IT_WHERE_COND_TAB type RSDS_TWHERE optional .
  methods GET_DATA
    exporting
      !EV_SIZET type ZONDE_OC_NUM30
      !EV_RECORDST type ZONDE_OC_NUM30 .
  methods SEND_DATA .
  methods DELETE_DATA .
  methods COPY_CONTEXT_FROM
    importing
      !IO_SOURCE_TYPE type ref to ZONCL_OC_BASE_HANDLER .
endinterface.
