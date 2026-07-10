function ZONFM_RS_DS_CHECK_INITIAL.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(INPUT)
*"     VALUE(TABLE_FIELD) TYPE  TABFIELD OPTIONAL
*"     VALUE(FIELDTYPE) OPTIONAL
*"  EXPORTING
*"     VALUE(ANSWER)
*"  EXCEPTIONS
*"      DESCRIPTION_EMPTY
*"--------------------------------------------------------------------
  data l_type .
  data : l_inttype_1(45), l_inttype(45).
  data l_time_date(45).
  data l_hex(45) value '00'.
  constants l_space value ' '.
  data l_ctx_dd type context_free_sel_dd_info.
  data: begin of l_splittab occurs 0,
          part like rsdynpar-param,
        end   of l_splittab.
  data l_tfill like sy-tfill.
  data l_convert like rsconvert.

  answer = 'N'.
  if not fieldtype is initial.
    l_convert-type = fieldtype.
  else.
    supply tablename = table_field-tabname
           fieldname = table_field-fieldname
             to context l_ctx_dd.
    demand  convert     = l_convert
      from context l_ctx_dd.
  endif.
  if l_convert-type is initial.
    message e107 with 'RS_DS_CHECK_INITIAL' raising description_empty.
"#EC *
  endif.
  move: '0' to l_inttype_1+44(1), '0' to l_inttype+43(1).

  case l_convert-type.
   when 'C' or 'p'.
      if input eq space.
        answer = 'Y'.
      endif.
    when 'T' .
      move '000000' to l_time_date.
      if input eq  l_time_date.
        answer = 'Y'.
      endif.
    when 'D'.
      move '00000000' to l_time_date.
      if input eq  l_time_date.
        answer = 'Y'.
      endif.
    when 'P'.
      split input at '.' into table l_splittab.
      describe table l_splittab lines l_tfill.
      if l_tfill le 2.
        loop at l_splittab.
          if l_splittab-part co '0 '.
            add 1 to l_tfill.
          endif.
        endloop.
        if l_tfill eq 4 or l_tfill eq 2.
          answer = 'Y'.
        endif.
      endif.
    when 'I' or 's' or 'b' or '8'.
      if input = l_inttype_1 or input = l_inttype.
        answer = 'Y'.
      endif.
    when 'X'.
      if input eq l_hex.
        answer = 'Y'.
      endif.
    when 'F'.
      move '0.0000000000000000E+00' to l_inttype+23.
      if input eq l_inttype.
        answer = 'Y'.
      endif.
   when 'N'.
      if input ca '0' and input co '0 '.
        answer = 'Y'.
      endif.
  endcase.
endfunction.
