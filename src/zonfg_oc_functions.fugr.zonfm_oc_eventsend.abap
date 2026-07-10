FUNCTION zonfm_oc_eventsend.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(OBJECT) LIKE  NAST STRUCTURE  NAST
*"     REFERENCE(I_DELETION) TYPE  BOOLEAN OPTIONAL
*"  EXCEPTIONS
*"      ERROR_MESSAGE_RECEIVED
*"      DATA_NOT_RELEVANT_FOR_SENDING
*"----------------------------------------------------------------------

  DATA: lo_json_automatic TYPE REF TO zoncl_fetch_data.
  DATA: sender TYPE sibflporb,
        event  TYPE sibfevent.

  CREATE OBJECT lo_json_automatic.

  lo_json_automatic->send_output_type( i_object = object ).

ENDFUNCTION.
