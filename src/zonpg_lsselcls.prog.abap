*----------------------------------------------------------------------*
*   INCLUDE LSSELCLS                                                   *
*----------------------------------------------------------------------*
CLASS LCL_MY_EVENT_HANDLER DEFINITION.

  public section.
    data: selected_ucomm like sy-ucomm.
    methods on_function_selected
               for event function_selected of cl_gui_toolbar
                 importing fcode.
    methods NODE_DOUBLE_CLICK
             for event NODE_DOUBLE_CLICK of cl_gui_simple_tree
               importing node_key.

endclass.
class lcl_my_event_handler implementation.

  method on_function_selected.

break bpinst.
  if fcode = 'TAKE'.
     selected_ucomm = fcode.
     perform add_fields.
  elseif fcode = 'REVERT'.
     selected_ucomm = fcode.
     perform delete_selected_fields.
  elseif fcode = 'SAVEV'.
    break bpinst.
  endif.
  endmethod.
  method node_double_click.

    perform delete_or_add using node_key.
  endmethod.

ENDCLASS.
*----------------------------------------------------------------------*
*       CLASS lcl_helper DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
class lcl_helper definition.
  public section.
    type-pools abap.
    types escape_char type c length 1.

    class-methods:  sap_to_sql_patte
                    importing
                       sap_pattern type clike
                    exporting
                       sql_pattern type string
                       escape_needed type abap_bool
                    exceptions closing_escape,

                    class_constructor,

                    sql_to_sap_patte
                     importing
                        sql_pattern type clike
                        escape      type escape_char
                     exporting
                        sap_pattern type string
                        escape_needed type abap_bool
                     exceptions closing_escape,

                     is_operator importing lexem type string
                     returning value(is_operator) type abap_bool.
  private section.
    constants: sapanysingle   type c  value '+',
               sapanysequence type c  value '*',

               sapescape      type c  value '#',

               sqlanysingle   type c  value '_',
               sqlanysequence type c  value '%'.
    constants stringspace type string value ` `.

    class-data is_nuc type abap_bool value abap_true.
endclass.                    "lcl_helper DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_helper IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
class lcl_helper implementation.

   method class_constructor.
    if cl_abap_char_utilities=>charsize > 1.
      is_nuc = abap_false.
    endif.
  endmethod.

  method sap_to_sql_patte.
    data last_pos type i.     " last position without trailing blanks
    data input_maxpos type i." last position with trailing blanks
    data curr_pos type i value 0.
    data continue_off type i.
    data charlen type i.
    data ftype type c length 1.

    clear sql_pattern.
    clear escape_needed.

    describe field sap_pattern type ftype.

    if ftype ne 'g'.
      describe field sap_pattern length input_maxpos in character mode.
    else.
      input_maxpos = strlen( sap_pattern ).
    endif.
    input_maxpos = input_maxpos - 1.
    last_pos = numofchar( sap_pattern ) - 1.

    while curr_pos <= last_pos.
      continue_off = 1.
      charlen = charlen( sap_pattern+curr_pos ).
      if charlen > 1.
* surrogate character : copy charlen surrogate
        concatenate sql_pattern sap_pattern+curr_pos(charlen) into sql_pattern.
        add 1 to continue_off.
        add continue_off to curr_pos.
        continue.
      endif.
      case sap_pattern+curr_pos(1).
        when sapanysingle.
          concatenate sql_pattern sqlanysingle into sql_pattern.
        when sapanysequence.
          concatenate sql_pattern sqlanysequence into sql_pattern.
        when sapescape.
          data next_char type c.
          data next_char_pos type i.
          data next_char_len type i.

          next_char_pos = curr_pos + 1.
          if next_char_pos <= input_maxpos and
             charlen( sap_pattern+next_char_pos ) > 1.
* next character is surrogate pair => copy surrogate pair
            next_char_len = charlen( sap_pattern+next_char_pos ).
            concatenate sql_pattern sap_pattern+next_char_pos(next_char_len) into sql_pattern.
            curr_pos = curr_pos + 1 + next_char_len. " escape and next multibyte char processed
            continue.
          endif.

          if curr_pos < last_pos.
* character after escape is normal
            next_char_pos = curr_pos + 1.
            continue_off = continue_off + 1.
* Character after escape is sqlMeta or sapEscape
            next_char = sap_pattern+next_char_pos(1).
            if  next_char = sqlanysingle or
                next_char = sqlanysequence or
                next_char = sapescape.
              escape_needed = abap_true.
              concatenate sql_pattern sapescape into sql_pattern.
            endif.
            concatenate sql_pattern next_char into sql_pattern.
          else.
            if last_pos < input_maxpos.
              concatenate sql_pattern stringspace into sql_pattern.
            else.
              raise closing_escape.
            endif.
          endif.
        when sqlanysingle or
             sqlanysequence.
          escape_needed = abap_true.
          concatenate sql_pattern sapescape sap_pattern+curr_pos(1) into sql_pattern.
        when others.
          concatenate sql_pattern sap_pattern+curr_pos(1) into sql_pattern respecting blanks.
      endcase.

      curr_pos = curr_pos + continue_off.
    endwhile.

  endmethod.                    "sap_to_sql_patte_uc

  method sql_to_sap_patte.
    data: curr_pos type i value 0,
          last_pos type i,
          input_maxpos type i.
    data: charlen type i,
          continue_off type i.
    data ftype type c length 1.

    describe field sql_pattern type ftype.
    if ftype <> 'g'.
      describe field sql_pattern length input_maxpos in character mode.
    else.
      input_maxpos = strlen( sql_pattern ).
    endif.
    subtract 1 from input_maxpos.
    last_pos = strlen( sql_pattern ) - 1.
    while curr_pos <= last_pos.
      continue_off = 1.
      charlen = charlen( sql_pattern ).
      if is_nuc = abap_true and charlen > 1.
        concatenate sap_pattern sql_pattern+curr_pos(charlen) into sap_pattern.
        add 1 to continue_off.
        add continue_off to curr_pos.
        continue.
      endif.
      case sql_pattern+curr_pos(1).
        when sqlanysingle.
          concatenate sap_pattern sapanysingle into sap_pattern.
        when sqlanysequence.
          concatenate sap_pattern sapanysequence into sap_pattern.
        when escape.
          data next_char type c.
          data next_char_pos type i.
          data next_char_len type i.

          next_char_pos = curr_pos + 1.
          next_char_len = charlen( sql_pattern+next_char_pos ).
          if is_nuc = abap_true and next_char_len > 1.
* next character is multibyte => copy charlen bytes
            concatenate sap_pattern sql_pattern+next_char_pos(next_char_len) into sap_pattern.
            curr_pos = curr_pos + 1 + next_char_len. " escape and next multibyte char processed
            continue.
          endif.
          if curr_pos < last_pos.
* character after escape is single byte
            next_char_pos = curr_pos + 1.
            add 1 to continue_off.
* Character after escape is sqlMeta or sapEscape
            next_char = sql_pattern+next_char_pos(1).
            if  next_char = sapanysingle or
                next_char = sapanysequence or
                next_char = escape.
              escape_needed = abap_true.
              concatenate sap_pattern sapescape into sap_pattern.
            endif.
            concatenate sap_pattern next_char into sap_pattern.
          else.
            if last_pos < input_maxpos.
              concatenate sap_pattern stringspace into sap_pattern.
            else.
              raise closing_escape.
            endif.
          endif.
        when sapanysingle or
             sapanysequence.
          escape_needed = abap_true.
          concatenate sap_pattern sapescape sql_pattern+curr_pos(1) into sap_pattern.
        when others.
          concatenate sap_pattern sql_pattern+curr_pos(1) into sap_pattern respecting blanks.
      endcase.

      curr_pos = curr_pos + continue_off.
    endwhile.
  endmethod.                    "sql_to_sap_patte

  method is_operator.
    case lexem.
    when '='
     or 'EQ'
     or 'BETWEEN'
     or 'LIKE'
     or '<'
     or 'LT'
     or '>'
     or 'GT'
     or '<='
     or 'LE'
     or '>='
     or 'GE'
     or '<>'
     or '><'
     or 'NE'.
      is_operator = abap_true.
     when others.
      is_operator = abap_false.
  endcase.
  endmethod.
endclass.                    "lcl_helper IMPLEMENTATION
