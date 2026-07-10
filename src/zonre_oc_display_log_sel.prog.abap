
*&---------------------------------------------------------------------*
*& Include          ZONRE_ONI_DISPLAY_LOG_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01.
  PARAMETERS: p_obje TYPE balobj_d  DEFAULT 'ZONI_OC' OBLIGATORY,
              p_subo TYPE balsubobj DEFAULT 'ORDER TO CASH' OBLIGATORY,
              p_entity type zonta_obj_oc-business_proc.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-t02.
  SELECT-OPTIONS: s_date FOR sy-datum,
                  s_tabn FOR zonst_oc_log_ext-tabname,
                  s_key  FOR zonst_oc_log_ext-key,
                  s_user FOR zonst_oc_log_ext_alv-user,
                  s_code FOR zonst_oc_log_ext_alv-code,
                  s_prog FOR zonst_oc_log_ext_alv-prog.
SELECTION-SCREEN END OF BLOCK b2.


SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-t03.
  PARAMETERS: p_er TYPE c RADIOBUTTON GROUP rad,
              p_su TYPE c RADIOBUTTON GROUP rad,
              p_wa TYPE c RADIOBUTTON GROUP rad,
              p_al TYPE c RADIOBUTTON GROUP rad DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK b3.
