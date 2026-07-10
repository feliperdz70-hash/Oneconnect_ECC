FUNCTION zonfm_oc_price_event.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_TABLE) TYPE  TABNAME OPTIONAL
*"     VALUE(I_WHERE) TYPE  RSDS_WHERE_TAB OPTIONAL
*"     VALUE(I_KNUMH) TYPE  KNUMH OPTIONAL
*"  EXPORTING
*"     REFERENCE(R_SIZE) TYPE  ZONDE_OC_NUM30
*"     REFERENCE(R_RECORDS) TYPE  ZONDE_OC_NUM30
*"----------------------------------------------------------------------
  WAIT UP TO 5 SECONDS.
  DATA: i_konp  TYPE TABLE OF konp,
        w_konp  TYPE konp,
        i_konh  TYPE TABLE OF konh,
        w_konh  TYPE konh,
        me      TYPE REF TO zoncl_fetch_data,
        w_where TYPE rsdswhere,
        v_dest  TYPE rfcdest.

  DATA:
    is_sender TYPE  sibflporb,
    i_event   TYPE  sibfevent,
    iv_uuid   TYPE  uuid.

  SELECT SINGLE low FROM zonta_oc_param INTO v_dest WHERE name = 'RFC_DESTINATION'.
  CREATE OBJECT me.

  CALL METHOD me->send_json_any_table_price
    EXPORTING
      iv_tabname   = i_table
      iv_update    = 'X'
      iv_delete    = ''
      it_where     = i_where
      iv_alias     = ''
      iv_fieldname = 'X'
      iv_dest      = v_dest
      iv_knumh     = i_knumh
    IMPORTING
      r_size       = R_sIZE
      r_records    = r_records.

  CALL METHOD me->send_json_any_table_price
    EXPORTING
      iv_tabname   = 'KONH'
      iv_update    = 'X'
      iv_delete    = ''
      it_where     = i_where
      iv_alias     = ''
      iv_fieldname = 'X'
      iv_dest      = v_dest.

  CALL METHOD me->send_json_any_table_price
    EXPORTING
      iv_tabname   = 'KONP'
      iv_update    = 'X'
      iv_delete    = ''
      it_where     = i_where
      iv_alias     = ''
      iv_fieldname = 'X'
      iv_dest      = v_dest.

ENDFUNCTION.
