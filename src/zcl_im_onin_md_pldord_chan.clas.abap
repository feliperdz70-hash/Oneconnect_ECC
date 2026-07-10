class ZCL_IM_ONIN_MD_PLDORD_CHAN definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_MD_PLDORD_CHANGE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_ONIN_MD_PLDORD_CHAN IMPLEMENTATION.


  method IF_EX_MD_PLDORD_CHANGE~CHANGE_BEFORE_SAVE_MAN.
    BREAK-POINT.
  endmethod.


  method IF_EX_MD_PLDORD_CHANGE~CHANGE_BEFORE_SAVE_MRP.
    BREAK-POINT.
  endmethod.
ENDCLASS.
