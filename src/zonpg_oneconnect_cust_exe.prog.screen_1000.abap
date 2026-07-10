
PROCESS BEFORE OUTPUT.
  MODULE status_1000.
  MODULE init_variant_tab.
  MODULE update_screen_1000.

PROCESS AFTER INPUT.
  FIELD zonta_oc_variant-variant MODULE validate_variant.
  MODULE user_command_1000.
