*&---------------------------------------------------------------------*
*& Include          ZONRE_OC_DISPLAY_LOG_CLASS
*&---------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       CLASS lcl_handle_events DEFINITION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
CLASS lcl_handle_events DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_user_command FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function.
ENDCLASS.                    "lcl_handle_events DEFINITION

*---------------------------------------------------------------------*
*       CLASS lcl_handle_events IMPLEMENTATION
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
CLASS lcl_handle_events IMPLEMENTATION.
  METHOD on_user_command.
    PERFORM user_command USING e_salv_function.
  ENDMETHOD.                    "on_user_command

ENDCLASS.                    "lcl_handle_events IMPLEMENTATION
