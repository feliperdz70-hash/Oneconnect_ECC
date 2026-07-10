class ZONCL_QUEUE_MANAGER definition
  public
  create public .

public section.

  interfaces BI_EVENT_HANDLER_STATIC .
protected section.
private section.

  types:
    BEGIN OF ty_payload_struct,
          bo_type TYPE BOROBJTYPE,
          payload_struct TYPE REF TO CL_ABAP_STRUCTDESCR,
          END OF ty_payload_struct .

  class-data SR_PAYLOAD_STRUCT type ref to CL_ABAP_STRUCTDESCR .
  class-data:
    ST_PAYLOAD_STRUCT TYPE STANDARD TABLE OF ty_payload_struct .
ENDCLASS.



CLASS ZONCL_QUEUE_MANAGER IMPLEMENTATION.


  METHOD bi_event_handler_static~on_event.
    DATA: lo_json_automatic TYPE REF TO zoncl_fetch_data, "_v2,
          lt_attr_names     TYPE swfdnamtab,
          lx_text           TYPE REF TO cx_root.


    CREATE OBJECT lo_json_automatic.

    lt_attr_names = event_container->list_names( ).

*    DO.
*
*    ENDDO.

    CASE sender-typeid.

      WHEN 'CL_BILLOFMATERIAL_EVENT'.

*        event_container->get( EXPORTING name       =                  " Name of the Component Whose Value Is to Be Read
*  IMPORTING
*    value      =                  " Copy of the Current Value of the Component
*    unit       =                  " Unit of the Component
*    returncode =                  " Errors Occurred (If Asked -> No RAISE)
*        ).
*CATCH cx_swf_cnt_elem_not_found.     " Name Entered Is Unknown
*CATCH cx_swf_cnt_elem_type_conflict. " Value Not Type Compatible to Current Parameter
*CATCH cx_swf_cnt_unit_type_conflict. " Unit Not Type Compatible to the Current Parameter
*CATCH cx_swf_cnt_container.          " Exception in the Container Service
    ENDCASE.

    TRY.
        lo_json_automatic->send_event_automatic( is_sender = sender
                                                 i_event  = event ).
      CATCH cx_root INTO lx_text.
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
