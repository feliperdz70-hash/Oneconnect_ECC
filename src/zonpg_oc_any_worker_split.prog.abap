*&---------------------------------------------------------------------*
*& Report  ZONPG_OC_ANY_WORKER_SPLIT
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zonpg_oc_any_worker_split.


PARAMETERS:
  p_table  TYPE tabname,
  p_field  TYPE fieldname,
  p_alias  TYPE zonde_aliastab,
  p_payl   TYPE char32,
  p_dest   TYPE rfcdest,
  p_access TYPE c,
  p_uali   type c.

DATA: lo_data    TYPE REF TO data.
FIELD-SYMBOLS: <fs_split> TYPE STANDARD TABLE.
DATA:
      go_handler   TYPE REF TO zoncl_oc_any_handler.


CREATE DATA lo_data TYPE STANDARD TABLE OF (p_table).
ASSIGN lo_data->* TO <fs_split>.

* Obtain the data
IMPORT <fs_split>
  FROM DATABASE indx(sw)
  ID p_payl.


* Crear handler
CREATE OBJECT go_handler.



go_handler->send_json_any_table_ltables(
  EXPORTING
    iv_tabname              = p_table
    iv_aliastablong         = p_alias
    iv_entity_business_proc = 'ANY'
    iv_dest                 = p_dest
    iv_delete               = ''
    iv_update               = 'X'
    iv_alias                = p_uali
    it_tables_data          = <fs_split> ).
