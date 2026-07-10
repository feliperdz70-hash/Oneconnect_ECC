class ZCL_IM_ONIM_BADI_SCD_SAVE definition
  public
  final
  create public .

public section.

  interfaces IF_EX_BADI_SCD_SAVE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_ONIM_BADI_SCD_SAVE IMPLEMENTATION.


 METHOD if_ex_badi_scd_save~at_save.
   DATA:  vl_objectid1 TYPE cdhdr-objectid,
          ls_vfkk      TYPE vfkk,
          ls_vfkk_old  TYPE vfkk,
          l_tcode      TYPE cdhdr-tcode ,
          l_utime      TYPE cdhdr-utime,
          l_udate      TYPE cdhdr-udate,
          l_username   TYPE cdhdr-username,
          lt_cdtxt     TYPE STANDARD TABLE OF cdtxt,
          l_upd_vfkk   TYPE cdpos-chngind,
          l_change_ind TYPE cdhdr-change_ind,
          ls_scdd      TYPE v54a0_scdd .

   READ TABLE i_scd_tab INDEX 1 INTO ls_scdd.

   vl_objectid1 = ls_scdd-fknum  .

   l_tcode      = sy-tcode.
   l_utime      = sy-uzeit.
   l_udate      = sy-datum.
   l_username   = sy-uname.

   IF ls_scdd-change EQ abap_false.
     l_upd_vfkk   = 'I'.
     l_change_ind = 'I'.
   ELSE.
     l_upd_vfkk   = 'U'.
     l_change_ind = 'U'.
   ENDIF.

   ls_vfkk     = ls_scdd-x-vfkk.
   ls_vfkk_old = ls_scdd-y-vfkk.

   CALL FUNCTION 'ZONCONNGASTTRNS_WRITE_DOCUMENT' IN UPDATE TASK
     EXPORTING
       objectid                = vl_objectid1
       tcode                   = l_tcode
       utime                   = l_utime
       udate                   = l_udate
       username                = l_username
       object_change_indicator = l_change_ind
       n_vfkk                  = ls_vfkk
       o_vfkk                  = ls_vfkk_old
       upd_vfkk                = l_upd_vfkk
     TABLES
       icdtxt_zonconngasttrns  = lt_cdtxt.

 ENDMETHOD.


method IF_EX_BADI_SCD_SAVE~BEFORE_UPDATE.
endmethod.


method IF_EX_BADI_SCD_SAVE~CHECK_COMPLETE.
endmethod.
ENDCLASS.
