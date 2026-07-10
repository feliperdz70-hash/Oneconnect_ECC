class ZONCL_SETGET_CL definition
  public
  final
  create private .

public section.

  methods SET_WHERE
    importing
      !IT_WHERE type ZONTTRSDSWHERE optional
      !IT_WHERE_COND_TAB type RSDS_TWHERE optional .
  methods GET_WHERE
    exporting
      !ET_WHERE_COND_TAB type RSDS_TWHERE
      !ET_WHERE type ZONTTRSDSWHERE .
  class-methods GET_INSTANCE
    returning
      value(RV_INSTANCE) type ref to ZONCL_SETGET_CL .
protected section.
private section.

  data GT_WHERE type ZONTTRSDSWHERE .
  data GT_WHERE_COND_TAB type RSDS_TWHERE .
  class-data GO_INSTANCE type ref to ZONCL_SETGET_CL .
ENDCLASS.



CLASS ZONCL_SETGET_CL IMPLEMENTATION.


  METHOD get_instance.
    IF go_instance IS BOUND.
      rv_instance = go_instance.
    ELSE.
      CREATE OBJECT go_instance.
      rv_instance = go_instance.
    ENDIF.
  ENDMETHOD.


  method GET_WHERE.
    et_where[] = gt_where[].
    et_where_cond_tab[] = gt_where_cond_tab[].
  endmethod.


  method SET_WHERE.
    gt_where[] = it_where[].
    gt_where_cond_tab[] = it_where_cond_tab[].
  endmethod.
ENDCLASS.
