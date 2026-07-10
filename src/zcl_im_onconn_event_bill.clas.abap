class ZCL_IM_ONCONN_EVENT_BILL definition
  public
  final
  create public .

public section.

  interfaces IF_EX_SD_CIN_LV60AU02 .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_ONCONN_EVENT_BILL IMPLEMENTATION.


  METHOD if_ex_sd_cin_lv60au02~excise_invoice_create.
    DATA: ls_vbrk               TYPE vbrk,
          ls_vbrk_old           TYPE vbrk,
          lt_icdtxt_zonconnbill TYPE STANDARD TABLE OF  cdtxt,
          lv_change_ind         TYPE cdhdr-change_ind,
          lv_upd_vbrk           TYPE cdpos-chngind,
          lv_vbtyp              TYPE vbrk-vbtyp,
          lv_vbtyp_s            TYPE vbrk-vbtyp,
          lv_vbtyp_o            TYPE vbrk-vbtyp.

    DATA:   da_objectid TYPE cdhdr-objectid.

    CASE sy-tcode.
      WHEN 'VF01'.
        lv_vbtyp = 'M'.
        lv_change_ind = 'I'.
        lv_vbtyp_o    = 'O'.
      WHEN 'VF11'.
        lv_vbtyp   = 'N'.
        lv_vbtyp_s = 'S'.
        lv_vbtyp_o = 'O'.
        lv_change_ind = 'I'.
      WHEN OTHERS.
        lv_vbtyp = 'M'.
        lv_change_ind = 'U'.
    ENDCASE.

    READ TABLE xvbrk WITH KEY vbtyp = lv_vbtyp
                     INTO ls_vbrk.
    IF sy-subrc NE 0.
      READ TABLE xvbrk WITH KEY vbtyp = lv_vbtyp_s
                     INTO ls_vbrk.
      IF sy-subrc NE 0.
        READ TABLE xvbrk WITH KEY vbtyp = lv_vbtyp_o
                     INTO ls_vbrk.
      ENDIF.
    ENDIF.

    da_objectid = ls_vbrk-vbeln.

    lv_upd_vbrk = lv_change_ind.

    SELECT SINGLE *
           INTO ls_vbrk_old
           FROM vbrk
           WHERE vbeln EQ ls_vbrk-vbeln.

    IF ls_vbrk EQ ls_vbrk_old.
      CLEAR ls_vbrk_old.
    ENDIF.

    CALL FUNCTION 'ZONCONNBILL_WRITE_DOCUMENT' IN UPDATE TASK
      EXPORTING
        objectid                = da_objectid
        tcode                   = sy-tcode
        utime                   = sy-uzeit
        udate                   = sy-datum
        username                = sy-uname
        object_change_indicator = lv_change_ind
        n_vbrk                  = ls_vbrk
        o_vbrk                  = ls_vbrk_old
        upd_vbrk                = lv_upd_vbrk
      TABLES
        icdtxt_zonconnbill      = lt_icdtxt_zonconnbill.

    IF sy-tcode EQ 'VF11'.

      lv_vbtyp      = 'M'.
      lv_change_ind = 'U'.

      READ TABLE xvbrk WITH KEY vbtyp = lv_vbtyp
                       INTO ls_vbrk.
      IF sy-subrc NE 0.
        READ TABLE xvbrk WITH KEY vbtyp = lv_vbtyp_o
                       INTO ls_vbrk.
      ENDIF.

      da_objectid = ls_vbrk-vbeln.

      lv_upd_vbrk = lv_change_ind.

      SELECT SINGLE *
             INTO ls_vbrk_old
             FROM vbrk
             WHERE vbeln EQ ls_vbrk-vbeln.

      IF ls_vbrk EQ ls_vbrk_old.
        CLEAR ls_vbrk_old.
      ENDIF.

      CALL FUNCTION 'ZONCONNBILL_WRITE_DOCUMENT' IN UPDATE TASK
        EXPORTING
          objectid                = da_objectid
          tcode                   = sy-tcode
          utime                   = sy-uzeit
          udate                   = sy-datum
          username                = sy-uname
          object_change_indicator = lv_change_ind
          n_vbrk                  = ls_vbrk
          o_vbrk                  = ls_vbrk_old
          upd_vbrk                = lv_upd_vbrk
        TABLES
          icdtxt_zonconnbill      = lt_icdtxt_zonconnbill.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
