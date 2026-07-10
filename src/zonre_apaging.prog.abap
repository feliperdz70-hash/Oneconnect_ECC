
*Code listing for: ZAP_AGING
*Description: Account Payable Aging
*&---------------------------------------------------------------------*
*& Report ZAP_AGING
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zap_aging.
TYPE-POOLS: slis.

TABLES: lfa1,
        bsik,
        bkpf,
        lfb1,
        t001s,
        faede.

DATA temp_amt LIKE bsik-dmbtr.

TYPES: BEGIN OF g_type_aging,
         lifnr     LIKE bsik-lifnr,
         name1     LIKE kna1-name1,
         ktokk     LIKE lfa1-ktokk,
         bldat     LIKE bsik-bldat,
         blart     LIKE bsik-blart,
         belnr     LIKE bseg-belnr,
         xblnr     LIKE bsik-xblnr,
         umskz     LIKE bsik-umskz,
         zterm     LIKE knb1-zterm,
         sname     LIKE t001s-sname,
         hkont     LIKE bsik-hkont,
         netdt     LIKE faede-netdt,
         zdisc_amt LIKE bsik-skfbt,
         amt_inv   LIKE bseg-dmbtr,
         amt_inv0  LIKE bseg-dmbtr,
         amt_inv1  LIKE bseg-dmbtr,
         amt_inv2  LIKE bseg-dmbtr,
         amt_inv3  LIKE bseg-dmbtr,
         amt_inv4  LIKE bseg-dmbtr,
         amt_inv5  LIKE bseg-dmbtr,
       END OF g_type_aging.
DATA: g_aging TYPE g_type_aging OCCURS 0 WITH HEADER LINE.

TYPES: BEGIN OF g_type_agings,
         name1     LIKE kna1-name1,
         lifnr     LIKE bsik-lifnr,
         zdisc_amt LIKE bsik-skfbt,
         amt_inv   LIKE bseg-dmbtr,
         amt_inv0  LIKE bseg-dmbtr,
         amt_inv1  LIKE bseg-dmbtr,
         amt_inv2  LIKE bseg-dmbtr,
         amt_inv3  LIKE bseg-dmbtr,
         amt_inv4  LIKE bseg-dmbtr,
         amt_inv5  LIKE bseg-dmbtr,
       END OF g_type_agings.
DATA: g_agings TYPE g_type_agings OCCURS 0 WITH HEADER LINE.

DATA: wa_fieldtab TYPE slis_fieldcat_alv,
      fieldtab    TYPE slis_t_fieldcat_alv,
*       P_F2CODE       LIKE SY-UCOMM     VALUE  '&ETA',
      p_f2code    LIKE sy-ucomm     VALUE  'ZSLS'.
DATA: g_repid   LIKE sy-repid,
      g_save(1) TYPE c,
      g_variant LIKE disvariant.
DATA : layout      TYPE slis_layout_alv,
       gs_print    TYPE slis_print_alv,
       gt_sort     TYPE slis_t_sortinfo_alv,
       gt_sp_group TYPE slis_t_sp_group_alv.

* Ranges Labels
DATA: lbl1(12) TYPE c,
      lbl2(12) TYPE c,
      lbl3(12) TYPE c,
      lbl4(12) TYPE c,
      lbl5(12) TYPE c.

* invoice amount per each range
DATA: amt_inv_range0 LIKE bsik-dmbtr,
      amt_inv_range1 LIKE bsik-dmbtr,
      amt_inv_range2 LIKE bsik-dmbtr,
      amt_inv_range3 LIKE bsik-dmbtr,
      amt_inv_range4 LIKE bsik-dmbtr,
      amt_inv_range5 LIKE bsik-dmbtr,
      amt_inv        LIKE bsik-dmbtr.

DATA days_range LIKE sy-tabix.
DATA: ddays LIKE sy-tabix.
DATA due_date LIKE bsik-bldat.

DATA: xkred LIKE vf_kred OCCURS 10 WITH HEADER LINE.
DATA: xbsik LIKE bsik OCCURS 10 WITH HEADER LINE.
DATA: xbsak LIKE bsak OCCURS 10 WITH HEADER LINE.
DATA: x001s LIKE t001s OCCURS 10 WITH HEADER LINE.
DATA: zdisc_amt LIKE bsik-skfbt.
DATA: w_tabix LIKE sy-tabix.

*-----------------------  SELECTION-SCREEN  ---------------------------*
SELECTION-SCREEN BEGIN OF BLOCK frame1 WITH FRAME TITLE TEXT-100.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 01(28) TEXT-101.
    SELECT-OPTIONS vendor FOR bsik-lifnr.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 01(28) TEXT-102.
    SELECT-OPTIONS CoCd FOR bsik-Bukrs.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 01(28) TEXT-103.
    SELECT-OPTIONS s_busab FOR lfb1-busab.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 01(28) TEXT-104.
    SELECT-OPTIONS s_ktokk FOR lfa1-ktokk.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 01(28) TEXT-105.
    SELECT-OPTIONS s_hkont FOR bsik-hkont.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK frame1.

*        Block Frame2 - Line items selection
SELECTION-SCREEN BEGIN OF BLOCK frame2 WITH FRAME TITLE TEXT-200.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 01(28) TEXT-201.
    SELECTION-SCREEN POSITION POS_LOW.
    PARAMETERS: zdate LIKE bsik-budat OBLIGATORY DEFAULT sy-datum.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK frame2.

*        Block Frame3 - Further Selection
SELECTION-SCREEN BEGIN OF BLOCK frame3 WITH FRAME TITLE TEXT-300.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 01(28) TEXT-301.
    SELECTION-SCREEN POSITION POS_LOW.
    PARAMETERS: DispDet LIKE bsik-xnetb DEFAULT 'X'.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 01(28) TEXT-302.
    SELECT-OPTIONS DocDate FOR bsik-bldat NO-EXTENSION.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 01(28) TEXT-303.
    SELECT-OPTIONS PostDate FOR bsik-budat NO-EXTENSION.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 01(28) TEXT-304.
    SELECT-OPTIONS SpecGL FOR bsik-umskz.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 01(28) TEXT-305.
    SELECTION-SCREEN POSITION POS_LOW.
    PARAMETERS: PartPay LIKE bsik-xnetb DEFAULT 'X'.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 01(28) TEXT-306.
    SELECTION-SCREEN POSITION POS_LOW.
    PARAMETERS: p_duedt AS CHECKBOX DEFAULT 'X'.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK frame3.

*        Block Frame3 - Output Control
SELECTION-SCREEN BEGIN OF BLOCK frame4 WITH FRAME TITLE TEXT-400.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN COMMENT 01(28) TEXT-401.
    SELECTION-SCREEN POSITION POS_LOW.
    PARAMETERS: zdays1 LIKE rfpdo1-allgrogr DEFAULT '030'.
    PARAMETERS: zdays2 LIKE rfpdo1-allgrogr DEFAULT '060'.
    PARAMETERS: zdays3 LIKE rfpdo1-allgrogr DEFAULT '090'.
    PARAMETERS: zdays4 LIKE rfpdo1-allgrogr DEFAULT '120'.
  SELECTION-SCREEN END OF LINE.
  SKIP 1.
  PARAMETER p_ONE RADIOBUTTON GROUP 1 DEFAULT 'X'.
  PARAMETER p_alv RADIOBUTTON GROUP 1 .
  DATA tempdays(3) TYPE n.
SELECTION-SCREEN END OF BLOCK frame4.

SELECTION-SCREEN: BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_vari LIKE disvariant-variant.
SELECTION-SCREEN: END OF BLOCK b2.

* OAV BEGIN
PARAMETERS p_fm TYPE c NO-DISPLAY.
* OAV END

*-------------------------  INITIALIZATION   --------------------------*
INITIALIZATION.

  g_repid = sy-repid.
  PERFORM print_build.
  PERFORM sort_build      USING gt_sort[].
  PERFORM sp_group_build  USING gt_sp_group[].
  PERFORM alv_init.

************************************************************************
*******                START  OF  SELECTION                      *******
************************************************************************
START-OF-SELECTION.

  CONCATENATE 'To' zdays1 INTO lbl1 SEPARATED BY space.
  tempdays = zdays1 + 1.
  CONCATENATE tempdays 'to' zdays2 INTO lbl2 SEPARATED BY space.
  tempdays = zdays2 + 1.
  CONCATENATE tempdays 'to' zdays3 INTO lbl3 SEPARATED BY space.
  tempdays = zdays3 + 1.
  CONCATENATE tempdays 'to' zdays4 INTO lbl4 SEPARATED BY space.
  tempdays = zdays4 + 1.
  CONCATENATE 'From' tempdays INTO lbl5 SEPARATED BY space.

  PERFORM initialize_fieldcat1.
  PERFORM a_initialize.
  PERFORM b_get_documents.

END-OF-SELECTION.

* OAV BEGIN
*  PERFORM BUILD_LAYOUT USING LAYOUT.
*  PERFORM ALV_GRID_DISPLAY.
  IF p_fm IS INITIAL.
    PERFORM build_layout USING layout.
    PERFORM alv_grid_display.
  ELSE.
    DATA v_mem TYPE char20.
    CONCATENATE 'ZAPAGIN' sy-datlo INTO v_mem SEPARATED BY '-'.
    IF DispDet EQ 'X'.
      EXPORT g_aging FROM g_aging TO MEMORY ID v_mem.
    ELSE.
      EXPORT g_agings FROM g_agings TO MEMORY ID v_mem.
    ENDIF.
  ENDIF.
* OAV END

*---------------------------------------------------------------------*
*       FORM SORT_BUILD                                               *
*---------------------------------------------------------------------*
FORM sort_build USING e06_lt_sort TYPE slis_t_sortinfo_alv.

  DATA: ls_sort TYPE slis_sortinfo_alv.

  ls_sort-spos      = 1.
  ls_sort-fieldname = 'LIFNR'.
  ls_sort-up        = 'X'.
  ls_sort-subtot    = 'X'.
  ls_sort-expa      = '1'.           " enables expansion/compression
  ls_sort-group     = '*'.           " page break
  APPEND ls_sort TO e06_lt_sort.

  ls_sort-spos      = 2.
  ls_sort-fieldname = 'NETDT'.
  ls_sort-up        = 'X'.
  ls_sort-subtot    = ' '.
  ls_sort-group     = 'UL'.
  APPEND ls_sort TO e06_lt_sort.

ENDFORM. "SORT_BUILD

*---------------------------------------------------------------------*
*       FORM SP_GROUP_BUILD                                           *
*---------------------------------------------------------------------*
FORM sp_group_build USING e07_lt_sp_group TYPE slis_t_sp_group_alv.

  DATA: ls_sp_group TYPE slis_sp_group_alv.

  CLEAR  ls_sp_group.
  ls_sp_group-sp_group = 'A'.
  ls_sp_group-text     = 'LIFNR'.
  APPEND ls_sp_group TO e07_lt_sp_group.
  CLEAR  ls_sp_group.
  ls_sp_group-sp_group = 'A'.
  ls_sp_group-text     = 'NAME1'.
  APPEND ls_sp_group TO e07_lt_sp_group.

ENDFORM. "SP_GROUP_BUILD

*&---------------------------------------------------------------------*
*&      Form  ALV_INIT
*&---------------------------------------------------------------------*
FORM alv_init .

* Set Options: save variants userspecific or general
  CLEAR p_vari.
  g_save = 'A'.
  PERFORM variant_init.
* Get default variant
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save     = g_save
    CHANGING
      cs_variant = g_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 0.
    p_vari = g_variant-variant.
  ENDIF.

ENDFORM. " ALV_INIT

*&---------------------------------------------------------------------*
*&      Form  variant_init
*&---------------------------------------------------------------------*
FORM variant_init .

  CLEAR g_variant.
  g_variant-report = g_repid.

ENDFORM. " variant_init

*&---------------------------------------------------------------------*
*&      Form PRINT_BUILD                                               *
*&---------------------------------------------------------------------*
FORM print_build.

  gs_print-no_coverpage       = 'X'.
  gs_print-no_print_listinfos = 'X'.

ENDFORM.

*---------------------------------------------------------------------*
*      Form  INITIALIZE_FIELDCAT1
*---------------------------------------------------------------------*
FORM initialize_fieldcat1.

  IF DispDet EQ 'X'.
    CLEAR wa_fieldtab.
    wa_fieldtab-tabname      = 'G_AGING'.
    wa_fieldtab-fix_column   = ' '.
    wa_fieldtab-fieldname    = 'LIFNR'.
    wa_fieldtab-seltext_l    = 'Vendor'.
    wa_fieldtab-no_zero      = 'X'.
    wa_fieldtab-hotspot      = 'X'.
    wa_fieldtab-emphasize    = 'X'.
    wa_fieldtab-sp_group     = 'A'.
    APPEND wa_fieldtab TO fieldtab.

    CLEAR wa_fieldtab.
    wa_fieldtab-tabname      = 'G_AGING'.
    wa_fieldtab-fieldname    = 'NAME1'.
    wa_fieldtab-seltext_l    = 'Vendor Name'.
    wa_fieldtab-sp_group     = 'A'.
    APPEND wa_fieldtab TO fieldtab.

    CLEAR wa_fieldtab.
    wa_fieldtab-tabname      = 'G_AGING'.
    wa_fieldtab-fieldname    = 'BLDAT'.
    wa_fieldtab-seltext_l    = 'Invoice Date'.
    wa_fieldtab-outputlen    = '14'.
    APPEND wa_fieldtab TO fieldtab.

    CLEAR wa_fieldtab.
    wa_fieldtab-tabname      = 'G_AGING'.
    wa_fieldtab-fieldname    = 'BLART'.
    wa_fieldtab-seltext_l    = 'DT'.
    APPEND wa_fieldtab TO fieldtab.

    CLEAR wa_fieldtab.
    wa_fieldtab-tabname      = 'G_AGING'.
    wa_fieldtab-fieldname    = 'BELNR'.
    wa_fieldtab-seltext_l    = 'Document Num.'.
    wa_fieldtab-outputlen    = '10'.
    APPEND wa_fieldtab TO fieldtab.

    CLEAR wa_fieldtab.
    wa_fieldtab-tabname      = 'G_AGING'.
    wa_fieldtab-fieldname    = 'XBLNR'.
    wa_fieldtab-seltext_l    = 'Reference'.
    APPEND wa_fieldtab TO fieldtab.

    CLEAR wa_fieldtab.
    wa_fieldtab-tabname      = 'G_AGING'.
    wa_fieldtab-fieldname    = 'UMSKZ'.
    wa_fieldtab-seltext_l    = 'SG'.
    APPEND wa_fieldtab TO fieldtab.

    CLEAR wa_fieldtab.
    wa_fieldtab-tabname      = 'G_AGING'.
    wa_fieldtab-fieldname    = 'ZTERM'.
    wa_fieldtab-seltext_l    = 'Term'.
    APPEND wa_fieldtab TO fieldtab.

    CLEAR wa_fieldtab.
    wa_fieldtab-tabname      = 'G_AGING'.
    wa_fieldtab-fieldname    = 'SNAME'.
    wa_fieldtab-seltext_l    = 'Accounting Clerk'.
    APPEND wa_fieldtab TO fieldtab.

    CLEAR wa_fieldtab.
    wa_fieldtab-tabname      = 'G_AGING'.
    wa_fieldtab-fieldname    = 'HKONT'.
    wa_fieldtab-seltext_l    = 'GL Account'.
    wa_fieldtab-no_zero      = 'X'.
    APPEND wa_fieldtab TO fieldtab.

    CLEAR wa_fieldtab.
    wa_fieldtab-tabname      = 'G_AGING'.
    wa_fieldtab-fieldname    = 'NETDT'.
    wa_fieldtab-ref_tabname  = 'FAEDE'.
    wa_fieldtab-seltext_l    = 'Due Date'.
    APPEND wa_fieldtab TO fieldtab.

    CLEAR wa_fieldtab.
    wa_fieldtab-tabname       = 'G_AGING'.
    wa_fieldtab-fieldname     = 'ZDISC_AMT'.
    wa_fieldtab-seltext_l     = 'Discount Amt'.
    wa_fieldtab-outputlen     = '15'.
    wa_fieldtab-do_sum        = 'X'.
    APPEND wa_fieldtab TO fieldtab.

    CLEAR wa_fieldtab.
    wa_fieldtab-tabname       = 'G_AGING'.
    wa_fieldtab-fieldname     = 'AMT_INV'.
    wa_fieldtab-seltext_l     = 'Invoice Amount'.
    wa_fieldtab-outputlen     = '15'.
    wa_fieldtab-do_sum        = 'X'.
    APPEND wa_fieldtab TO fieldtab.

    CLEAR wa_fieldtab.
    wa_fieldtab-tabname      = 'G_AGING'.
    wa_fieldtab-fieldname    = 'AMT_INV0'.
    wa_fieldtab-seltext_l    = 'Not yet due'.
    wa_fieldtab-do_sum       = 'X'.
    APPEND wa_fieldtab TO fieldtab.

    CLEAR wa_fieldtab.
    wa_fieldtab-tabname      = 'G_AGING'.
    wa_fieldtab-fieldname    = 'AMT_INV1'.
    wa_fieldtab-seltext_l    = lbl1.
    wa_fieldtab-do_sum        = 'X'.
    APPEND wa_fieldtab TO fieldtab.

    CLEAR wa_fieldtab.
    wa_fieldtab-tabname      = 'G_AGING'.
    wa_fieldtab-fieldname    = 'AMT_INV2'.
    wa_fieldtab-seltext_l    = lbl2.
    wa_fieldtab-do_sum        = 'X'.
    APPEND wa_fieldtab TO fieldtab.

    CLEAR wa_fieldtab.
    wa_fieldtab-tabname      = 'G_AGING'.
    wa_fieldtab-fieldname    = 'AMT_INV3'.
    wa_fieldtab-seltext_l    = lbl3.
    wa_fieldtab-do_sum        = 'X'.
    APPEND wa_fieldtab TO fieldtab.

    CLEAR wa_fieldtab.
    wa_fieldtab-tabname      = 'G_AGING'.
    wa_fieldtab-fieldname    = 'AMT_INV4'.
    wa_fieldtab-seltext_l    = lbl4.
    wa_fieldtab-do_sum        = 'X'.
    APPEND wa_fieldtab TO fieldtab.

    CLEAR wa_fieldtab.
    wa_fieldtab-tabname      = 'G_AGING'.
    wa_fieldtab-fieldname    = 'AMT_INV5'.
    wa_fieldtab-seltext_l    = lbl5.
    wa_fieldtab-do_sum        = 'X'.
    APPEND wa_fieldtab TO fieldtab.
  ELSE.
    CLEAR wa_fieldtab.
    wa_fieldtab-tabname      = 'G_AGINGS'.
    wa_fieldtab-fix_column   = 'X'.
    wa_fieldtab-fieldname    = 'LIFNR'.
    wa_fieldtab-seltext_l    = 'Vendor'.
    wa_fieldtab-no_zero      = 'X'.
    wa_fieldtab-hotspot      = 'X'.
    wa_fieldtab-emphasize    = 'X'.
    APPEND wa_fieldtab TO fieldtab.

    CLEAR wa_fieldtab.
    wa_fieldtab-tabname      = 'G_AGINGS'.
    wa_fieldtab-fieldname    = 'NAME1'.
    wa_fieldtab-seltext_l    = 'Vendor Name'.
    APPEND wa_fieldtab TO fieldtab.

    CLEAR wa_fieldtab.
    wa_fieldtab-tabname       = 'G_AGINGS'.
    wa_fieldtab-fieldname     = 'ZDISC_AMT'.
    wa_fieldtab-ref_tabname   = 'BSEG'.
    wa_fieldtab-ref_fieldname = 'DMBTR'.
    wa_fieldtab-seltext_l     = 'Discount Amt'.
    wa_fieldtab-outputlen     = '13'.
    APPEND wa_fieldtab TO fieldtab.

    CLEAR wa_fieldtab.
    wa_fieldtab-tabname       = 'G_AGINGS'.
    wa_fieldtab-fieldname     = 'AMT_INV'.
    wa_fieldtab-ref_tabname   = 'BSEG'.
    wa_fieldtab-ref_fieldname = 'DMBTR'.
    wa_fieldtab-seltext_l     = 'Total Customer'.
    APPEND wa_fieldtab TO fieldtab.

    CLEAR wa_fieldtab.
    wa_fieldtab-tabname      = 'G_AGINGS'.
    wa_fieldtab-fieldname    = 'AMT_INV0'.
    wa_fieldtab-seltext_l    = 'Not yet due'.
    APPEND wa_fieldtab TO fieldtab.

    CLEAR wa_fieldtab.
    wa_fieldtab-tabname      = 'G_AGINGS'.
    wa_fieldtab-fieldname    = 'AMT_INV1'.
    wa_fieldtab-seltext_l    = lbl1.
    APPEND wa_fieldtab TO fieldtab.

    CLEAR wa_fieldtab.
    wa_fieldtab-tabname      = 'G_AGINGS'.
    wa_fieldtab-fieldname    = 'AMT_INV2'.
    wa_fieldtab-seltext_l    = lbl2.
    APPEND wa_fieldtab TO fieldtab.

    CLEAR wa_fieldtab.
    wa_fieldtab-tabname      = 'G_AGINGS'.
    wa_fieldtab-fieldname    = 'AMT_INV3'.
    wa_fieldtab-seltext_l    = lbl3.
    APPEND wa_fieldtab TO fieldtab.

    CLEAR wa_fieldtab.
    wa_fieldtab-tabname      = 'G_AGINGS'.
    wa_fieldtab-fieldname    = 'AMT_INV4'.
    wa_fieldtab-seltext_l    = lbl4.
    APPEND wa_fieldtab TO fieldtab.

    CLEAR wa_fieldtab.
    wa_fieldtab-tabname      = 'G_AGINGS'.
    wa_fieldtab-fieldname    = 'AMT_INV5'.
    wa_fieldtab-seltext_l    = lbl5.
    APPEND wa_fieldtab TO fieldtab.
  ENDIF.

ENDFORM. " initialize_fieldcat1

*---------------------------------------------------------------------*
*       FORM A_INITIALIZE                                             *
*---------------------------------------------------------------------*
FORM a_initialize.

  SELECT * FROM t001s INTO TABLE x001s.

  SELECT * FROM vf_kred INTO TABLE xkred WHERE lifnr IN vendor
                                         AND   bukrs IN cocd
                                         AND   busab IN s_busab
                                         AND   ktokk IN s_ktokk.
  SORT xkred BY lifnr bukrs.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM B_GET_DOCUMENTS                                          *
*---------------------------------------------------------------------*
FORM b_get_documents.

  LOOP AT xkred.

*   Get accounting clerk and telephone number
    CLEAR x001s.
    IF xkred-busab GT space.
      READ TABLE x001s WITH KEY bukrs = xkred-bukrs
                                busab = xkred-busab.
    ENDIF.

    REFRESH xbsik.  CLEAR xbsik.
    REFRESH xbsak.  CLEAR xbsak.
    SELECT * FROM bsik INTO TABLE xbsik
                       WHERE lifnr EQ xkred-lifnr
                       AND   budat LE Zdate
                       AND   bukrs EQ xkred-bukrs
                       AND   bldat IN DocDate
                       AND   budat IN PostDate
                       AND   hkont IN s_hkont
                       AND   umskz IN SpecGL.
    SELECT * FROM bsak INTO TABLE xbsak
                       WHERE lifnr EQ xkred-lifnr
                       AND   augdt GT Zdate
                       AND   bukrs EQ xkred-bukrs
                       AND   bldat IN DocDate
                       AND   budat LE Zdate
                       AND   hkont IN s_hkont
                       AND   umskz IN SpecGL.
    IF NOT xbsak[] IS INITIAL.
      APPEND LINES OF xbsak TO xbsik.
    ENDIF.
    SORT xbsik BY lifnr budat belnr buzei.

    LOOP AT xbsik.

*     initialize the invoice amount with each invoice
      amt_inv        = 0.
      amt_inv_range0 = 0.
      amt_inv_range1 = 0.
      amt_inv_range2 = 0.
      amt_inv_range3 = 0.
      amt_inv_range4 = 0.
      amt_inv_range5 = 0.

*     Update to have the partial payment in the same range as invoice
      due_date = xbsik-bldat.
      CLEAR faede.
      MOVE-CORRESPONDING xbsik TO faede.
      faede-koart = 'K'.
      CALL FUNCTION 'DETERMINE_DUE_DATE'
        EXPORTING
          i_faede = faede
        IMPORTING
          e_faede = faede
        EXCEPTIONS
          OTHERS  = 1.
*     If requested, use due date instead of invoice date
      IF sy-subrc EQ 0.
        IF p_duedt EQ 'X'.
          due_date   = faede-netdt.
        ENDIF.
      ENDIF.

*     Update to have the partial payment in the same range as invoice
      IF PartPay = 'X'.
        IF xbsik-shkzg = 'S' AND xbsik-rebzg <> ''.
          SELECT * FROM bkpf WHERE belnr = xbsik-rebzg
                             AND   bukrs = xbsik-bukrs
                             AND   gjahr = xbsik-rebzj.
            IF sy-subrc = 0 AND sy-dbcnt = 1.
              IF p_duedt EQ 'X'.
                days_range = zdate - due_date.
              ELSE.
                days_range = zdate - bkpf-bldat.
              ENDIF.
            ELSE.
              days_range = zdate - due_date.
            ENDIF.
          ENDSELECT.
          IF sy-subrc GT 0.
            days_range = zdate - due_date.
          ENDIF.
        ELSE.
          days_range = zdate - due_date.
        ENDIF.
      ELSE.
        days_range = zdate - due_date.
      ENDIF.

*     Discount amount
      zdisc_amt = 0.
      ddays     = sy-datum - xbsik-zfbdt.
      IF ddays LE xbsik-zbd1t.
        zdisc_amt = xbsik-zbd1p * ( xbsik-skfbt / 100 ).
      ELSEIF ddays LE xbsik-zbd2t.
        zdisc_amt = xbsik-zbd2p * ( xbsik-skfbt / 100 ).
      ENDIF.

*     assign the invoice amount to right column
      IF     days_range LE 0    AND xbsik-shkzg EQ 'S'.
        days_range     = 0.
        amt_inv_range0 = - xbsik-dmbtr.

      ELSEIF days_range LE 0      AND
             xbsik-shkzg EQ 'H'.
        days_range     = 0.
        amt_inv_range0 = xbsik-dmbtr.

      ELSEIF days_range <= zdays1 AND xbsik-shkzg = 'H'.
        amt_inv_range1 = xbsik-dmbtr.

      ELSEIF days_range <= zdays1 AND
             xbsik-shkzg = 'S'.
        amt_inv_range1 = ( -1 ) * xbsik-dmbtr.

      ELSEIF days_range > zdays1 AND
             days_range <= zdays2 AND
             xbsik-shkzg = 'H'.
        amt_inv_range2 = xbsik-dmbtr.

      ELSEIF days_range > zdays1  AND
             days_range <= zdays2 AND
             xbsik-shkzg = 'S'.
        amt_inv_range2 = ( -1 ) * xbsik-dmbtr.

      ELSEIF days_range > zdays2  AND
             days_range <= zdays3 AND
             xbsik-shkzg = 'H'.
        amt_inv_range3 = xbsik-dmbtr.

      ELSEIF days_range > zdays2  AND
             days_range <= zdays3 AND
             xbsik-shkzg = 'S'.
        amt_inv_range3 = ( -1 ) * xbsik-dmbtr.

      ELSEIF days_range > zdays3 AND
             days_range <= zdays4 AND
             xbsik-shkzg = 'H'.
        amt_inv_range4 = xbsik-dmbtr.

      ELSEIF days_range > zdays3 AND
             days_range <= zdays4 AND
             xbsik-shkzg = 'S'.
        amt_inv_range4 = ( -1 ) * xbsik-dmbtr.

      ELSEIF days_range > zdays4 AND xbsik-shkzg = 'H'.
        amt_inv_range5 = xbsik-dmbtr.

      ELSEIF days_range > zdays4 AND xbsik-shkzg = 'S'.
        amt_inv_range5 = ( -1 ) * xbsik-dmbtr.

      ENDIF.

      amt_inv = amt_inv_range0 + amt_inv_range1 + amt_inv_range2 +
                amt_inv_range3 + amt_inv_range4 + amt_inv_range5.

      IF DispDet EQ 'X'.
        g_aging-name1       = xkred-name1.
        g_aging-lifnr       = xbsik-lifnr.
        g_aging-ktokk       = xkred-ktokk.
        g_aging-bldat       = xbsik-bldat.
        g_aging-blart       = xbsik-blart.
        g_aging-belnr       = xbsik-belnr.
        g_aging-xblnr       = xbsik-xblnr.
        g_aging-umskz       = xbsik-umskz.
        g_aging-zterm       = xbsik-zterm.
        g_aging-sname       = x001s-sname.
        g_aging-hkont       = xbsik-hkont.
        g_aging-netdt       = faede-netdt.
        g_aging-zdisc_amt   = zdisc_amt.
        g_aging-amt_inv     = amt_inv.
        g_aging-amt_inv0    = amt_inv_range0.
        g_aging-amt_inv1    = amt_inv_range1.
        g_aging-amt_inv2    = amt_inv_range2.
        g_aging-amt_inv3    = amt_inv_range3.
        g_aging-amt_inv4    = amt_inv_range4.
        g_aging-amt_inv5    = amt_inv_range5.
        APPEND g_aging.  CLEAR g_aging.
      ELSE.
        g_agings-name1       = xkred-name1.
        g_agings-lifnr       = xbsik-lifnr.
        g_agings-zdisc_amt   = zdisc_amt.
        g_agings-amt_inv     = amt_inv.
        g_agings-amt_inv0    = amt_inv_range0.
        g_agings-amt_inv1    = amt_inv_range1.
        g_agings-amt_inv2    = amt_inv_range2.
        g_agings-amt_inv3    = amt_inv_range3.
        g_agings-amt_inv4    = amt_inv_range4.
        g_agings-amt_inv5    = amt_inv_range5.
        COLLECT g_agings.  CLEAR g_agings.
      ENDIF.

    ENDLOOP.

  ENDLOOP.

  SORT g_aging  BY name1 lifnr.
  SORT g_agings BY name1 lifnr.

ENDFORM.

*---------------------------------------------------------------------*
*      Form  BUILD_LAYOUT
*---------------------------------------------------------------------*
FORM build_layout USING p_layout TYPE slis_layout_alv.

  p_layout-no_sumchoice        = ' '.           " no choice for summing up
  p_layout-no_totalline        = ' '.           " no total line
  p_layout-no_subchoice        = ' '.           " no choice for subtotals
  p_layout-no_subtotals        = ' '.           " no subtotals possible

ENDFORM. " BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  ALV_GRID_DISPLAY
*&---------------------------------------------------------------------*
FORM alv_grid_display .

  IF DispDet EQ 'X'.
    IF p_alv IS NOT INITIAL.
      IF g_variant-variant EQ space.
        g_variant-variant = '/ZDEFAULT'.
      ENDIF.
      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
          i_callback_program      = g_repid
          i_callback_user_command = 'ALV_USER_COMMANDS'
          is_layout               = layout
          i_save                  = g_save
          is_variant              = g_variant
          it_fieldcat             = fieldtab[]
          it_sort                 = gt_sort[]
          it_special_groups       = gt_sp_group[]
        TABLES
          t_outtab                = g_aging
        EXCEPTIONS
          program_error           = 1
          OTHERS                  = 2.

      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ELSE.
****SEND DATA THROUGH ONE CONNECT
      DATA: ME     TYPE REF TO zoncl_fetch_data_v2,
            i_apag TYPE TABLE OF zonta_apaging,
            w_apag TYPE  zonta_apaging,
            w_aging LIKE LINE OF g_aging,
            i_where TYPE ZONTTRSDSWHERE,
            w_where TYPE ZONTRSDSWHERE.

      CREATE OBJECT ME.
      move ' ( LIFNR NE ''999'' ) ' to w_where.
      APPEND w_where to i_where.
      LOOP AT  g_aging INTO w_aging.
        w_apag-lifnr    =   w_aging-lifnr.
        w_apag-belnr    =   w_aging-belnr.
        w_apag-xblnr    =   w_aging-xblnr.
        w_apag-bldat    =   w_aging-bldat.
        w_apag-name1    =   w_aging-name1.
        w_apag-ktokk    =   w_aging-ktokk.
        w_apag-blart    =   w_aging-blart.
        w_apag-umskz    =   w_aging-umskz.
        w_apag-zterm    =   w_aging-zterm.
        w_apag-sname    =   w_aging-sname.
        w_apag-hkont    =   w_aging-hkont.
        w_apag-netdt    =   w_aging-netdt.
        w_apag-zdisc_amt    =   w_aging-zdisc_amt.
        w_apag-amt_inv    =   w_aging-amt_inv.
        w_apag-amt_inv0    =   w_aging-amt_inv0.
        w_apag-amt_inv1    =   w_aging-amt_inv1.
        w_apag-amt_inv2    =   w_aging-amt_inv2.
        w_apag-amt_inv3    =   w_aging-amt_inv3.
        w_apag-amt_inv4    =   w_aging-amt_inv4.
        w_apag-amt_inv5    =   w_aging-amt_inv5.
        APPEND w_apag TO i_apag.
        CLEAR w_apag.
      ENDLOOP.
      DELETE FROM zonta_apaging.
      COMMIT WORK AND WAIT.
      MODIFY zonta_apaging FROM TABLE i_apag.
      COMMIT WORK AND WAIT.

CALL METHOD me->send_json_any_table
  EXPORTING
    iv_tabname   = 'ZONTA_APAGING'
    iv_update    = 'X'
    iv_delete    = ''
    it_where     = I_WHERE
    iv_alias     = ''
    iv_dest      = 'ONIBEX_DEMO'.

    ENDIF.
  ENDIF.

ENDFORM. " ALV_GRID_DISPLAY

*---------------------------------------------------------------------*
*       FORM alv_user_commands                                         *
*---------------------------------------------------------------------*
FORM alv_user_commands USING r_ucomm LIKE sy-ucomm
                         rs_selfield TYPE slis_selfield.

  DATA: lt_seltab TYPE STANDARD TABLE OF rsparams WITH HEADER LINE.

  CASE r_ucomm.
    WHEN  '&IC1'.
      READ TABLE g_aging INTO g_aging INDEX rs_selfield-tabindex.

      lt_seltab-selname = 'KD_LIFNR'.
      lt_seltab-sign    = 'I'.
      lt_seltab-option  = 'EQ'.
      lt_seltab-low     = g_aging-lifnr.
      APPEND lt_seltab.
      IF NOT CoCd-low IS INITIAL.
        lt_seltab-selname = 'KD_BUKRS'.
        lt_seltab-sign    = 'I'.
        lt_seltab-option  = 'EQ'.
        lt_seltab-low     = CoCd-low.
        APPEND lt_seltab.
      ENDIF.
      lt_seltab-selname = 'X_OPSEL'.
      lt_seltab-sign    = 'I'.
      lt_seltab-option  = 'EQ'.
      lt_seltab-low     = 'X'.
      APPEND lt_seltab.
*      lt_seltab-selname = 'PA_STIDA'.
*      lt_seltab-sign    = 'I'.
*      lt_seltab-option  = 'EQ'.
*      lt_seltab-low     = dd_stida.
*      APPEND lt_seltab.
      lt_seltab-selname = 'X_NORM'.
      lt_seltab-sign    = 'I'.
      lt_seltab-option  = 'EQ'.
      lt_seltab-low     = 'X'.
      APPEND lt_seltab.
      lt_seltab-selname = 'X_SHBV'.
      lt_seltab-sign    = 'I'.
      lt_seltab-option  = 'EQ'.
      lt_seltab-low     = 'X'.
      APPEND lt_seltab.
      lt_seltab-selname = 'PA_GRID'.
      lt_seltab-sign    = 'I'.
      lt_seltab-option  = 'EQ'.
      lt_seltab-low     = 'Y'.
      APPEND lt_seltab.

      SUBMIT rfitemap WITH SELECTION-TABLE lt_seltab
                      AND  RETURN.
  ENDCASE.

ENDFORM. "alv_user_commands
