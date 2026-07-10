*&---------------------------------------------------------------------*
*& Report ZONPG_OC_ANY_UI
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zonpg_oc_any_ui.


INCLUDE zonin_oc_any_entity_top.
INCLUDE zonin_oc_any_entity_f01.



AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_domain.
  PERFORM f4_domain.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_entity.
  PERFORM f4_entity.

START-OF-SELECTION.

  DATA lv_payloadid TYPE char32.

  PERFORM init.
  PERFORM get_driver_table.
  PERFORM get_free_selections.

  IF lines( gt_field_ranges ) > 0.


    CALL FUNCTION 'GUID_CREATE'
      IMPORTING
        ev_guid_32 = lv_payloadid.

    EXPORT gt_field_ranges gv_where
      TO DATABASE indx(st)
      ID lv_payloadid.

* Send executor program in background
    PERFORM launch_executor_job USING lv_payloadid.

  ENDIF.
