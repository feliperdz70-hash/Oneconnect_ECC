class ZCL_IM_ONIM_WORKORDER_UPD definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_WORKORDER_UPDATE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_ONIM_WORKORDER_UPD IMPLEMENTATION.


  method IF_EX_WORKORDER_UPDATE~ARCHIVE_OBJECTS.
  endmethod.


  method IF_EX_WORKORDER_UPDATE~AT_DELETION_FROM_DATABASE.
  endmethod.


  method IF_EX_WORKORDER_UPDATE~AT_RELEASE.
*  break-POINT.
  endmethod.


  METHOD if_ex_workorder_update~at_save.
*    break frgdev9.

  ENDMETHOD.


  METHOD if_ex_workorder_update~before_update.
* TYPE-POOLS: swc.

  ENDMETHOD.


  method IF_EX_WORKORDER_UPDATE~CMTS_CHECK.
  endmethod.


  method IF_EX_WORKORDER_UPDATE~INITIALIZE.
  endmethod.


  method IF_EX_WORKORDER_UPDATE~IN_UPDATE.
*       break frgdev9.
  endmethod.


  method IF_EX_WORKORDER_UPDATE~NUMBER_SWITCH.
  endmethod.


  method IF_EX_WORKORDER_UPDATE~REORG_STATUS_ACTIVATE.
  endmethod.


  method IF_EX_WORKORDER_UPDATE~REORG_STATUS_ACT_CHECK.
  endmethod.


  method IF_EX_WORKORDER_UPDATE~REORG_STATUS_REVOKE.
  endmethod.
ENDCLASS.
