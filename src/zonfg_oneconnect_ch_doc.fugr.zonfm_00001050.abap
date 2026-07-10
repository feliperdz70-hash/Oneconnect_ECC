FUNCTION zonfm_00001050 .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_XVBUP) LIKE  OFIWA-XVBUP OPTIONAL
*"  TABLES
*"      T_BKP1 STRUCTURE  BKP1
*"      T_BKPF STRUCTURE  BKPF
*"      T_BSEC STRUCTURE  BSEC
*"      T_BSED STRUCTURE  BSED
*"      T_BSEG STRUCTURE  BSEG
*"      T_BSET STRUCTURE  BSET
*"      T_BSEU STRUCTURE  BSEU
*"----------------------------------------------------------------------
  DATA:  vl_objectid1 TYPE cdhdr-objectid,
         ls_bkpf      TYPE bkpf,
         ls_bkpf_old  TYPE bkpf,
         l_tcode      TYPE cdhdr-tcode ,
         l_utime      TYPE cdhdr-utime,
         l_udate      TYPE cdhdr-udate,
         l_username   TYPE cdhdr-username.


  RETURN.

  READ TABLE t_bkpf INDEX 1 INTO ls_bkpf.

  vl_objectid1 = sy-mandt       &&
                 ls_bkpf-bukrs  &&
                 ls_bkpf-belnr  &&
                 ls_bkpf-gjahr .

  l_tcode      = sy-tcode.
  l_utime      = sy-uzeit.
  l_udate      = sy-datum.
  l_username   = sy-uname..

  CALL FUNCTION 'BELEG_WRITE_DOCUMENT' IN UPDATE TASK
    EXPORTING
      objectid                = vl_objectid1
      tcode                   = l_tcode
      utime                   = l_utime
      udate                   = l_udate
      username                = sy-uname
      object_change_indicator = 'I'
      n_bkpf                  = ls_bkpf
      o_bkpf                  = ls_bkpf_old
      upd_bkpf                = 'I'.

ENDFUNCTION.
