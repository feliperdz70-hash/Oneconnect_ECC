class ZCL_IM_ONIM_HRPAD00INFTY definition
  public
  final
  create public .

public section.

  interfaces IF_EX_HRPAD00INFTY .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_ONIM_HRPAD00INFTY IMPLEMENTATION.


  METHOD if_ex_hrpad00infty~after_input.
    IF sy-ucomm EQ 'UPD'.
      CALL FUNCTION 'ZONFM_ONE_CONNECT_HCM' IN UPDATE TASK
        EXPORTING
          is_new_innnn = new_innnn
          iv_tclas     = tclas
          iv_update    = abap_true
          iv_delete    = abap_false.
    ENDIF.
  ENDMETHOD.


  method IF_EX_HRPAD00INFTY~BEFORE_OUTPUT.
  endmethod.


  METHOD if_ex_hrpad00infty~in_update.
    DATA: ls_new_innnn TYPE  prelp,
          lv_tclas     TYPE  tclas.

    FIELD-SYMBOLS: <fs_new_image> TYPE psoper.

    CASE ipspar-actio.
      WHEN 'DEL'.
        lv_tclas = ipspar-tclas.

        LOOP AT new_image ASSIGNING <fs_new_image>.

          MOVE-CORRESPONDING <fs_new_image> TO ls_new_innnn.

          CALL FUNCTION 'ZONFM_ONE_CONNECT_HCM'
            EXPORTING
              is_new_innnn = ls_new_innnn
              iv_tclas     = lv_tclas
              iv_update    = abap_false
              iv_delete    = abap_true.
        ENDLOOP.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
