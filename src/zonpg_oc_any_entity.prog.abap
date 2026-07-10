*&---------------------------------------------------------------------*
*& Report ZONPG_OC_ANY_EXECUTOR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zonpg_oc_any_entity.

INCLUDE zonin_oc_any_entity_top.
INCLUDE zonin_oc_any_entity_f01.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_domain.
  PERFORM f4_domain.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_entity.
  PERFORM f4_entity.

*---------------------------------------------------------------------*
* START-OF-SELECTION
*---------------------------------------------------------------------*
START-OF-SELECTION.

* Create object
  PERFORM init.

* Get the main data - sequence 1
  PERFORM get_driver_table.

* Free selections
  IF sy-batch IS INITIAL.
    PERFORM get_free_selections.
  ELSE.
    PERFORM load_free_selections.
  ENDIF.

* Define how to work with all the tables in Entity
  PERFORM define_access_keys.

* Build the main keys for all tables
  PERFORM get_root_keys.

* Process the tables creating jobs
  PERFORM process_tables.
