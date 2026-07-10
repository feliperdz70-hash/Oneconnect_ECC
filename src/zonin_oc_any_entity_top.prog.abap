*&---------------------------------------------------------------------*
*& Include          ZONIN_OC_ANY_ENTITY_TOP
*&---------------------------------------------------------------------*

*---------------------------------------------------------------------*
* CONSTANTS
*---------------------------------------------------------------------*
CONSTANTS: c_direct   TYPE c VALUE 'D',
           c_join     TYPE c VALUE 'J',
           c_prekey   TYPE c VALUE 'P',
           c_multikey TYPE c VALUE 'M'.

*---------------------------------------------------------------------*
* PARAMETERS
*---------------------------------------------------------------------*
PARAMETERS:
  p_domain TYPE zonde_domain,
  p_entity TYPE zonde_process OBLIGATORY,
  p_payl   TYPE char32 NO-DISPLAY,
  p_dest   TYPE rfcdest.

*---------------------------------------------------------------------*
* TYPES
*---------------------------------------------------------------------*
TYPES: BEGIN OF st_access,
         tabname         TYPE  tabname,
         field_main      TYPE	 zonde_fieldm,
         field_sec       TYPE  zonde_fields,
         parent_relation TYPE  zonde_parentrel,
         join_type       TYPE  zonde_jointyp,
         sequence        TYPE	 zonde_sequence,
         subsequence     TYPE  zonde_subsequence,
         levelv          TYPE  zonde_oc_level,
         alias_tabname   TYPE  zonde_aliastab,
         access          TYPE c,
       END OF st_access.

TYPES: BEGIN OF ty_key,
         key TYPE string,
       END OF ty_key.

TYPES: BEGIN OF ty_parent_cache,
         tabname TYPE tabname,
         data    TYPE REF TO data,
       END OF ty_parent_cache.

TYPES: tt_string TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

TYPES: BEGIN OF ty_table_keys,
         tabname  TYPE tabname,
         keys     TYPE tt_string,
         is_multi TYPE abap_bool,
       END OF ty_table_keys.

DATA: gt_table_keys TYPE STANDARD TABLE OF ty_table_keys.


TYPES: tt_relations TYPE STANDARD TABLE OF zonta_relations WITH DEFAULT KEY.


*---------------------------------------------------------------------*
* DATA
*---------------------------------------------------------------------*
DATA:
  gt_tables         TYPE STANDARD TABLE OF tabname,
  gs_driver_rel     TYPE zonta_relations,
  gv_driver_table   TYPE tabname,
  gv_driver_multi   TYPE boolean,
  gv_main_key       TYPE zonde_fieldm,
  gt_access         TYPE STANDARD TABLE OF st_access,
  go_handler        TYPE REF TO zoncl_oc_any_handler,
  gt_root_keys      TYPE STANDARD TABLE OF string,
  gt_root_keys_base TYPE STANDARD TABLE OF string,
  gv_alias          TYPE boolean,
  gv_wait           TYPE i,
  gv_pakage         TYPE i,
  gv_where          TYPE string,
  lt_chunk          TYPE STANDARD TABLE OF string,
  gt_field_ranges   TYPE rsds_trange,
  gt_dd03p          TYPE STANDARD TABLE OF dd03p.

DATA: gt_parent_cache TYPE HASHED TABLE OF ty_parent_cache
      WITH UNIQUE KEY tabname.

DATA: gt_parent_data TYPE HASHED TABLE OF REF TO data
      WITH UNIQUE KEY table_line.
