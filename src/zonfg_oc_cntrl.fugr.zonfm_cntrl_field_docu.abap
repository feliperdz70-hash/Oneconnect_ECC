function ZONFM_CNTRL_FIELD_DOCU .
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IS_EXDBFI) TYPE  AQSEXDBFI
*"--------------------------------------------------------------------
  data:   l_feldname    type aqs_fname,
          l_itype       type aqdbsf-type,
          l_oleng       type aqs_leng,
          l_dec         type aqs_dec,
          l_curry       type aqs_flag,
          l_dom         type domname,
          l_dtype       type datatype_d,
          l_bleng       type aqs_leng,
          l_cleng       type aqs_leng,
          l_ileng       type intlen,
          l_dleng       type ddleng.

  concatenate is_exdbfi-ddic-tabname '-' is_exdbfi-ddic-fieldname into l_feldname.
  l_itype    = is_exdbfi-ddic-inttype.
  l_ileng    = is_exdbfi-ddic-intlen.
  l_dom      = is_exdbfi-ddic-domname.
  l_dtype    = is_exdbfi-ddic-datatype.
  l_dleng    = is_exdbfi-ddic-leng.
  l_oleng    = is_exdbfi-ddic-outputlen.
  l_dec      = is_exdbfi-ddic-decimals.
  l_curry    = is_exdbfi-info-curry.

  unpack l_ileng to l_bleng.
  unpack l_dleng to l_cleng.

  call function 'RSAQWFD_SHOW_FIELD_DOCU'
       exporting wfd_fieldname   = l_feldname
                 wfd_type        = l_itype
                 wfd_out_length  = l_oleng
                 wfd_decimals    = l_dec
                 wfd_curry_flag  = l_curry
                 wfd_domname     = l_dom
                 wfd_ddic_type   = l_dtype
                 wfd_byte_length = l_bleng
                 wfd_lenght      = l_cleng
       tables    wfd_dban        = dban
                 wfd_dbsg        = dbsg.

endfunction.
