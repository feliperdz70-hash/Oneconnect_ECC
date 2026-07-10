class ZONCL_JSON_SAVE_LOG definition
  public
  final
  create public .

public section.

  class-methods LOG_JSON_DATA
    importing
      !IV_JSON_STRING type STRING .
  class-methods ADD_MESSAGE
    importing
      !MESSAGE type STRING .
  class-methods GET_PARAMETER_ACTIVE_LOG
    importing
      !IV_NAME_PARAMETER type ZONTA_OC_PARAM-NAME
      !IV_TYPE type ZONTA_OC_PARAM-TYPE
    exporting
      !ES_PARAMETER type ZONTA_OC_PARAM .
protected section.
private section.
ENDCLASS.



CLASS ZONCL_JSON_SAVE_LOG IMPLEMENTATION.


  METHOD add_message.
*    log->add_text( xco_cp=>string( message ) ).
  ENDMETHOD.


  METHOD get_parameter_active_log.

    SELECT SINGLE *
       INTO es_parameter
       FROM zonta_oc_param
       WHERE name EQ iv_name_parameter
         AND type EQ iv_type.
*             AND numb EQ 1.

    IF sy-subrc NE 0.
      CLEAR es_parameter.
    ENDIF.
  ENDMETHOD.


  METHOD log_json_data.

*    DATA: lo_log              TYPE REF TO if_xco_cp_bal_log.
*
*    " Create an instance of the application log
*    " The exception cx_bali_runtime_error propagates if it cannot be created
*    lo_log =  xco_cp_bal=>for->database( )->log->create(
*          iv_object      = zoncl_rapevent_factory=>gc_log_object
*          iv_subobject   = zoncl_rapevent_factory=>gc_jsonlog_subobject
*          iv_external_id = 'SENJSON'
*        ).
*
*    " Add Json with text free
*    add_message( log     = lo_log
*                 message = iv_json_string ).



  ENDMETHOD.
ENDCLASS.
