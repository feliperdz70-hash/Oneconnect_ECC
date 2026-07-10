class ZONCL_IM_ONIM_LE_SHIPMENT definition
  public
  final
  create public .

public section.

  interfaces IF_EX_BADI_LE_SHIPMENT .
protected section.
private section.
ENDCLASS.



CLASS ZONCL_IM_ONIM_LE_SHIPMENT IMPLEMENTATION.


  method IF_EX_BADI_LE_SHIPMENT~AT_SAVE.
  endmethod.


  method IF_EX_BADI_LE_SHIPMENT~BEFORE_UPDATE.
  endmethod.


  METHOD if_ex_badi_le_shipment~in_update.
    DATA: ls_vttk                   TYPE vttk,
          ls_vttk_old               TYPE vttk,
          lt_icdtxt_zonconnshipment TYPE STANDARD TABLE OF  cdtxt,
          lv_change_ind             TYPE cdhdr-change_ind,
          lv_upd_vttk               TYPE cdpos-chngind.

    DATA:   da_objectid TYPE cdhdr-objectid.

    READ TABLE im_shipments_in_update-db_vttk_ins
               INDEX 1
               INTO ls_vttk.
    IF sy-subrc NE 0.
      READ TABLE im_shipments_in_update-db_vttk_upd
              INDEX 1
              INTO ls_vttk.
      IF sy-subrc NE 0.
        READ TABLE im_shipments_in_update-db_vttk_del
                INDEX 1
                INTO ls_vttk.
        IF sy-subrc EQ 0.
          lv_change_ind = 'D'.
        ENDIF.
      ELSE.
        lv_change_ind = 'U'.
      ENDIF.
    ELSE.
      lv_change_ind = 'I'.
    ENDIF.

    IF sy-subrc EQ 0.
      da_objectid = ls_vttk-tknum.
      lv_upd_vttk = lv_change_ind.

      SELECT SINGLE *
             INTO ls_vttk_old
             FROM vttk
             WHERE tknum EQ ls_vttk-tknum.

      IF ls_vttk EQ ls_vttk_old.
        CLEAR ls_vttk_old.
      ENDIF.

      CALL FUNCTION 'ZONCONNSHIPMENT_WRITE_DOCUMENT' IN UPDATE TASK
        EXPORTING
          objectid                = da_objectid
          tcode                   = sy-tcode
          utime                   = sy-uzeit
          udate                   = sy-datum
          username                = sy-uname
          object_change_indicator = lv_change_ind
          n_vttk                  = ls_vttk
          o_vttk                  = ls_vttk_old
          upd_vttk                = lv_upd_vttk
        TABLES
          icdtxt_zonconnshipment  = lt_icdtxt_zonconnshipment.

    ENDIF.
  ENDMETHOD.
ENDCLASS.
