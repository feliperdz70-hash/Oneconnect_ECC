function ZONFM_RS_DS_CONV_IN_2_EX.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(INPUT) TYPE  C
*"     REFERENCE(DESCR) TYPE  RSCONVERT OPTIONAL
*"     REFERENCE(TABLE_FIELD) TYPE  TABFIELD OPTIONAL
*"     REFERENCE(CHECK_INPUT) TYPE  SYCHAR01 OPTIONAL
*"  EXPORTING
*"     REFERENCE(OUTPUT)
*"  EXCEPTIONS
*"      CONVERSION_ERROR
*"--------------------------------------------------------------------
  data: begin of l_conv_fb_output,
          prefix(16) value 'CONVERSION_EXIT_',
          midfix(5),
          suffix(7) value '_OUTPUT',
        end   of l_conv_fb_output.

  data l_length type i.
  data l_ctx_dd type context_free_sel_dd_info.
  data l_convert like rsconvert.
  data l_date like sy-datum.
  data l_time like sy-uzeit.
  data l_flag_error.
  l_convert = descr.

  if not table_field-tabname is initial.
    supply tablename = table_field-tabname
           fieldname = table_field-fieldname
             to context l_ctx_dd.
    demand  convert     = l_convert
      from context l_ctx_dd.
  endif.

  if descr-quan_unit is not initial.
    l_convert-quan_unit = descr-quan_unit.
  endif.

  TRY.
     perform CONVERT_WH_2_EX in program rsdynss0
                             using l_convert
                                   input
                             changing output
                                      l_flag_error.
  CATCH CX_ROOT.
    if not check_input is initial.
      raise conversion_error.
    else.
      move input to output.
    endif.
  ENDTRY.

  if not check_input is initial.
    if not table_field-tabname is initial.
      CALL FUNCTION 'ZONFM_RS_CHECK_CONV_EX_2_IN'
        EXPORTING
          INPUT_EXTERNAL                     = output
          TABLE_FIELD                        = table_field
       EXCEPTIONS
         OTHERS                             = 1.
      IF SY-SUBRC <> 0.
        raise conversion_error.
      ENDIF.
    else.
      CALL FUNCTION 'ZONFM_RS_CHECK_CONV_EX2INNODD'
        EXPORTING
          INPUT_EXTERNAL                     = output
          DESCR                              = descr
         EXCEPTIONS
           OTHERS                             = 1.
      IF SY-SUBRC <> 0.
          raise conversion_error.
      ENDIF.
    endif.
  endif.

*
*  if l_convert-convexit ne space.
** Konvertierungsexit vorhanden
*    move l_convert-convexit to l_conv_fb_output-midfix.
*    condense l_conv_fb_output no-gaps.
*    call function l_conv_fb_output
*         exporting
*              input  = input
*         importing
*              output = output.
*    exit.
*  endif.
*  if l_convert-sign ne space.
*    if l_convert-dynptype ne 'QUAN'.
*      case l_convert-type.
*        when 'N'.
*          if input is initial.
*            describe field output length l_length in character mode.
*            clear output.
*            subtract 1 from l_length.
*            output+l_length(1) = '0'.
*          else.
*            write input to output no-zero.
*          endif.
*        when others.
*          write input to output.
*      endcase.
*    else.
*      write input to output unit l_convert-quan_unit.
*    endif.
*  elseif l_convert-type eq 'D'.
*    move input(8) to l_date.
*    write l_date to output mm/dd/yyyy.
*  elseif l_convert-type eq 'T'.
*    move input(8) to l_time.
*    write l_time to output.
*  elseif l_convert-type eq 'P'.
*     perform CONVERT_WH_2_EX in program rsdynss0
*                             using l_convert
*                                   input
*                             changing output
*                                      l_flag_error.
*  else.
*    if l_convert-dynptype ne 'QUAN'.
*      case l_convert-type.
*        when 'N'.
*          if input is initial.
*            describe field output length l_length in character mode.
*            clear output.
*            subtract 1 from l_length.
*            output+l_length(1) = '0'.
*          else.
*            write input to output no-zero no-sign.
*          endif.
*        when others.
*          write input to output no-sign.
*      endcase.
*    else.
*      write input to output unit l_convert-quan_unit
*                                         no-sign.
*    endif.
*  endif.

endfunction.
