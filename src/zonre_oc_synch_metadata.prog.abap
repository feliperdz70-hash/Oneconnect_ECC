*&---------------------------------------------------------------------*
*& Report ZONRE_OC_SYNCH_METADATA
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zonre_oc_synch_metadata.

INCLUDE zonin_oc_synch_metadata_top.
INCLUDE zonin_oc_synch_metadata_forms.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-name = 'P_DEST'.
      IF p_send = abap_true.
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_dom-low.
  PERFORM f4_domain USING 'LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_dom-high.
  PERFORM f4_domain USING 'HIGH'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_ent-low.
  PERFORM f4_entity USING 'LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_ent-high.
  PERFORM f4_entity USING 'HIGH'.



START-OF-SELECTION.

  PERFORM do_selection_process.

END-OF-SELECTION.
