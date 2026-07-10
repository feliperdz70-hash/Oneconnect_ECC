*&---------------------------------------------------------------------*
*& Report  ZONPG_MM_OPEN_PERIODOS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT ZONPG_MM_OPEN_PERIODOS.
*REPORT z_open_periods.

PARAMETERS:
  p_bukrs  TYPE t001-bukrs DEFAULT '0001',
  p_poper  TYPE i           DEFAULT 5,
  p_gjahr  TYPE i           DEFAULT 2018,
  p_poper2 TYPE i           DEFAULT 4,
  p_gjahr2 TYPE i           DEFAULT 2026.

START-OF-SELECTION.

  DATA: lv_period TYPE i,
        lv_year   TYPE i.

  lv_period = p_poper.
  lv_year   = p_gjahr.

  WHILE ( lv_year < p_gjahr2 ) OR
        ( lv_year = p_gjahr2 AND lv_period <= p_poper2 ).
SUBMIT rmmmperi
  WITH i_vbukr = p_bukrs    " From company code
  WITH i_bbukr = p_bukrs    " To company code
  WITH i_lfmon = lv_period  " Period
  WITH i_lfgja = lv_year    " Fiscal year
  WITH i_xcomp = 'X'        " Check and close period
  AND RETURN.

    WRITE: / 'Período abierto:', lv_period, '/', lv_year.

    lv_period = lv_period + 1.
    IF lv_period > 12.
      lv_period = 1.
      lv_year   = lv_year + 1.
    ENDIF.

  ENDWHILE.

  WRITE: / '✅ Proceso completado hasta', p_poper2, '/', p_gjahr2.
