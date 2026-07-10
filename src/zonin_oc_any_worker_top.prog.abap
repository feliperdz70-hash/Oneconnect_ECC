*&---------------------------------------------------------------------*
*& Include          ZONIN_OC_ANY_WORKGER_TOP
*&---------------------------------------------------------------------*
PARAMETERS:
  p_table  TYPE tabname,
  p_field  TYPE fieldname,
  p_alias  TYPE zonde_aliastab,
  p_payl   TYPE char32,
  p_dest   TYPE rfcdest,
  p_access TYPE c.


*---------------------------------------------------------------------*
* CONSTANTS
*---------------------------------------------------------------------*
CONSTANTS: c_direct TYPE c VALUE 'D',
           c_join   TYPE c VALUE 'J',
           c_prekey TYPE c VALUE 'P',
           c_root   TYPE c VALUE 'R'.

DATA: gt_root_keys TYPE STANDARD TABLE OF string,
      go_handler   TYPE REF TO zoncl_oc_any_handler,
      gv_split     TYPE i.

FIELD-SYMBOLS: <fs_table> TYPE STANDARD TABLE.
