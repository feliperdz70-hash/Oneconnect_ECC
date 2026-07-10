class ZONCL_DYNAMIC_COMBINER definition
  public
  final
  create public .

public section.

  class-methods COMBINE_NON_INITIAL_FIELDS
    importing
      !IS_SOURCE1 type ref to DATA
      !IS_SOURCE2 type ref to DATA
    exporting
      !ES_TARGET type ref to DATA .
protected section.
private section.
ENDCLASS.



CLASS ZONCL_DYNAMIC_COMBINER IMPLEMENTATION.


  method COMBINE_NON_INITIAL_FIELDS.
        DATA: lo_descr_struct1 TYPE REF TO cl_abap_structdescr,
          lo_descr_struct2 TYPE REF TO cl_abap_structdescr,
          lt_components1   TYPE cl_abap_structdescr=>component_table,
          lt_components2   TYPE cl_abap_structdescr=>component_table,
          ls_component     TYPE cl_abap_structdescr=>component,
          lv_value_source1 TYPE REF TO data,
          lv_value_source2 TYPE REF TO data,
          lv_value_target  TYPE REF TO data,
          lv_initial_value TYPE REF TO data, " To hold the initial value for comparison
*          lv_type_descr    TYPE REF TO cl_abap_typedescr.
          lv_type_descr    TYPE REF TO cl_abap_elemdescr.

    FIELD-SYMBOLS: <fs_source1_struct> TYPE any,
                   <fs_source2_struct> TYPE any,
                   <fs_target_struct>  TYPE any,
                   <fs_value_source1>  TYPE any,
                   <fs_value_source2>  TYPE any,
                   <fs_value_target>   TYPE any,
                   <fs_initial_value>  TYPE any.


    " 1. Get RTTI description for source structures
    lo_descr_struct1 ?= cl_abap_typedescr=>describe_by_data_ref( is_source1 ).
    lo_descr_struct2 ?= cl_abap_typedescr=>describe_by_data_ref( is_source2 ).

    " Ensure structures have the same definition
    IF lo_descr_struct1->get_relative_name( ) NE lo_descr_struct2->get_relative_name( ).
      " Handle error: Structures are not identical.
      " For simplicity, we'll proceed assuming they are the same
      " but in a real scenario, you'd raise an exception or handle it.
      " You might also want to compare component tables explicitly.
    ENDIF.

    " Assign structures to field symbols
    ASSIGN is_source1->* TO <fs_source1_struct>.
    ASSIGN is_source2->* TO <fs_source2_struct>.

    " Create the target structure dynamically based on source1's description
    CREATE DATA es_target TYPE HANDLE lo_descr_struct1.
    ASSIGN es_target->* TO <fs_target_struct>.

    " Initialize target structure
    CLEAR <fs_target_struct>.

    " Get components of the structure
    lt_components1 = lo_descr_struct1->get_components( ).

    " 2. Iterate through each component (field)
    LOOP AT lt_components1 INTO ls_component.

      " Assign field values dynamically using component name
      ASSIGN COMPONENT ls_component-name OF STRUCTURE <fs_source1_struct> TO <fs_value_source1>.
      ASSIGN COMPONENT ls_component-name OF STRUCTURE <fs_source2_struct> TO <fs_value_source2>.
      ASSIGN COMPONENT ls_component-name OF STRUCTURE <fs_target_struct> TO <fs_value_target>.

      IF <fs_value_source1> IS ASSIGNED AND <fs_value_source2> IS ASSIGNED AND <fs_value_target> IS ASSIGNED.
        " Get the type description of the current component
*        lv_type_descr = cl_abap_typedescr=>describe_by_data( <fs_value_source1> ).
lv_type_descr ?= cl_abap_typedescr=>describe_by_data( <fs_value_source1> ). " <-- Change here
        " Create an initial value for comparison (specific to the component's type)
        CREATE DATA lv_initial_value TYPE HANDLE lv_type_descr.
        ASSIGN lv_initial_value->* TO <fs_initial_value>.
        CLEAR <fs_initial_value>. " This sets it to the type's initial value (space, 0, '00000000', etc.)

        " Check if source1 value is not initial
        IF <fs_value_source1> NE <fs_initial_value>.
          <fs_value_target> = <fs_value_source1>.
        " If source1 value IS initial, check if source2 value is not initial
        ELSEIF <fs_value_source2> NE <fs_initial_value>.
          <fs_value_target> = <fs_value_source2>.
        ENDIF.
      ENDIF.
    ENDLOOP.

  endmethod.
ENDCLASS.
