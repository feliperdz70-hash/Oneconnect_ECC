FUNCTION ZONFM_ONE_CONNECT_CURSOR_UPDAT.
*"----------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_DEST) TYPE  RFCDEST
*"     VALUE(IV_JSON) TYPE  STRING
*"  EXPORTING
*"     VALUE(EV_RETURN) TYPE  STRING
*"     VALUE(EV_SIZE) TYPE  ZONDE_OC_NUM30
*"     VALUE(EV_RECORDS) TYPE  ZONDE_OC_NUM30
*"     VALUE(EV_RESPONSE) TYPE  STRING
*"----------------------------------------------------------------------
  DATA: lo_send_data TYPE REF TO zoncl_oc_any_handler.

  CREATE OBJECT lo_send_data.

  lo_send_data->send_json_http_con_opencursor(
    EXPORTING
      iv_dest     = iv_dest
      iv_json     = iv_json
    IMPORTING
      ev_return   = ev_return
      ev_size     = ev_size
      ev_records  = ev_records
      ev_response = ev_response
  ).

*  CALL FUNCTION 'RFC_CONNECTION_CLOSE'
*    EXPORTING
*      destination          = 'NONE'
**      taskname             = 'OPEN_CUR'
*    EXCEPTIONS
*      destination_not_open = 1
*      OTHERS               = 2.
*  IF sy-subrc <> 0.
** Implement suitable error handling here
*  ENDIF.
ENDFUNCTION.
