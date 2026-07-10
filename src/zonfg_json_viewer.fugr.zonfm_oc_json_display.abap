FUNCTION ZONFM_OC_JSON_DISPLAY.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_JSON) TYPE  STRING
*"     VALUE(IV_CAPTION) TYPE  STRING DEFAULT 'JSON Viewer'
*"     VALUE(IV_WIDTH) TYPE  I DEFAULT 700
*"     VALUE(IV_HEIGHT) TYPE  I DEFAULT 500
*"----------------------------------------------------------------------
  " Guardar parámetros en variables del fgroup (TOP include)
  gv_json     = iv_json.
  gv_caption  = iv_caption.
  gv_width    = iv_width.
  gv_height   = iv_height.
  gv_pbo_done = abap_false.

  " CALL SCREEN vive aquí dentro del fgroup — esto sí es válido
  CALL SCREEN 900.


ENDFUNCTION.
