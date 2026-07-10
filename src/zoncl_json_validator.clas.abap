class ZONCL_JSON_VALIDATOR definition
  public
  final
  create public .

public section.

  class-methods VALIDATE_MESSAGE
    importing
      !IV_JSON_STRING type STRING
    exporting
      !EV_IS_VALID type ABAP_BOOL
      !EV_ERROR_MESSAGE type STRING .
protected section.
private section.
ENDCLASS.



CLASS ZONCL_JSON_VALIDATOR IMPLEMENTATION.


  METHOD validate_message.



*  ZONTT_METADATA_FIELDS,  ZONS_FIELD_METADATA.
*
*      ZONTT_TABLE_METADATA
*ZONS_PROPERTIES
*ZONS_BODY
*ZONS_ONECONNECT

    TYPES: BEGIN OF ty_body,
             table TYPE string,
             data  TYPE REF TO data,
           END OF ty_body,

           BEGIN OF ty_oneconnect,
             properties TYPE zons_properties,
             metadata   TYPE zontt_table_metadata,
             body       TYPE ty_body,
           END OF ty_oneconnect,

           BEGIN OF ty_oneconnects,
             oneconnect TYPE ty_oneconnect,
           END OF ty_oneconnects.

    DATA: ls_oneconnect_msg TYPE zons_oneconnect_root.
*    DATA: ls_oneconnect_msg TYPE ty_oneconnects.
    DATA: lo_metadata_descript TYPE REF TO cl_abap_structdescr.
    DATA: lt_metadata_fields TYPE HASHED TABLE OF string WITH UNIQUE KEY table_line.
    DATA: lv_body_table_name TYPE string.
    DATA: lr_body_data       TYPE REF TO data.
    DATA: lo_body_descr      TYPE REF TO cl_abap_structdescr.
    DATA: lt_body_fields     TYPE HASHED TABLE OF string WITH UNIQUE KEY table_line.
    DATA: ls_field_metadata  TYPE zons_field_metadata.
    DATA: lt_components      TYPE cl_abap_structdescr=>component_table,
          ls_component       TYPE LINE OF cl_abap_structdescr=>component_table.
    DATA: lv_fieldname_meta TYPE string,
          lv_fieldname_body TYPE string.

    FIELD-SYMBOLS: <ls_data>           TYPE data,
                   <fs_metadata_entry> TYPE zons_table_metadata.

    ev_is_valid = abap_true.
    ev_error_message = ''.

*    DATA(lr_data) = /ui2/cl_json=>generate(
*      EXPORTING
*        json = iv_json_string
*    ).

    zoncl_ui2_cl_json=>deserialize(
      EXPORTING
        json         = iv_json_string
        pretty_name  = zoncl_ui2_cl_json=>pretty_mode-camel_case
        assoc_arrays = abap_true
      CHANGING
        data         = ls_oneconnect_msg
    ).


*    /ui2/cl_json=>deserialize(
*      EXPORTING
*        json         = ls_oneconnect_msg-oneconnect-body-data
*        pretty_name  = zoncl_ui2_cl_json=>pretty_mode-camel_case
*        assoc_arrays = abap_true
*      CHANGING
*        data         = ls_oneconnect_msg
*    ).
    READ TABLE ls_oneconnect_msg-oneconnect-metadata ASSIGNING <fs_metadata_entry>
      WITH KEY table = ls_oneconnect_msg-oneconnect-body-table.

    IF sy-subrc <> 0.
      ev_is_valid = abap_false.
      ev_error_message = |La tabla '{ ls_oneconnect_msg-oneconnect-body-table }' del body no se encuentra en el metadata.|.
      RETURN.
    ENDIF.


    LOOP AT <fs_metadata_entry>-metadata INTO ls_field_metadata.
      INSERT ls_field_metadata-fieldname INTO TABLE lt_metadata_fields.
    ENDLOOP.

*    " 4. Iterar sobre cada fila de datos del body para validar
*    LOOP AT ls_oneconnect_msg-oneconnect-body-data INTO DATA(lv_json_row_string).
*      " Para cada fila (string JSON), lo deserializamos dinámicamente
*      TRY.
*          /ui2/cl_json=>deserialize(
*            EXPORTING
*              json = lv_json_row_string
*            CHANGING
*              data = lr_body_data
*          ).
*        CATCH cx_root INTO DATA(lx_json).
*          ev_is_valid = abap_false.
*          ev_error_message = |Error al deserializar una fila del body: { lx_json->get_text( ) }|.
*          RETURN.
*      ENDTRY.

    " Assign the data reference to a field symbol
*    ASSIGN ls_oneconnect_msg-oneconnect-body-data->* TO <ls_data>.

    lo_body_descr ?= cl_abap_structdescr=>describe_by_data_ref( <ls_data> ).


    CLEAR lt_body_fields.

    lt_components =  lo_body_descr->get_components( ).

*    LOOP AT lo_body_descr->get_components( ) INTO data(ls_component).
    LOOP AT lt_components INTO ls_component.
      INSERT ls_component-name INTO TABLE lt_body_fields.
    ENDLOOP.


    LOOP AT lt_metadata_fields INTO lv_fieldname_meta.
      READ TABLE lt_body_fields TRANSPORTING NO FIELDS WITH KEY table_line = lv_fieldname_meta.
      IF sy-subrc <> 0.
        ev_is_valid = abap_false.
        ev_error_message = |Campo '{ lv_fieldname_meta }' del metadata no se encuentra en la fila del body.|.
        RETURN.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_body_fields INTO lv_fieldname_body.
      READ TABLE lt_metadata_fields TRANSPORTING NO FIELDS WITH KEY table_line = lv_fieldname_body.
      IF sy-subrc <> 0.
        ev_is_valid = abap_false.
        ev_error_message = |Campo extra '{ lv_fieldname_body }' en la fila del body que no está en el metadata.|.
        RETURN.
      ENDIF.
    ENDLOOP.

    " Aquí podrías añadir una validación extra para los tipos 'C' y 'P'
    " Tendrías que leer el valor de cada campo y verificar su tipo.
    " Ej: IF ls_field_metadata-type = 'C' AND ...

*    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
