class ZCL_IM_ONIM_HRBAS00INFTY definition
  public
  final
  create public .

public section.

  interfaces IF_EX_HRBAS00INFTY .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_ONIM_HRBAS00INFTY IMPLEMENTATION.


  method IF_EX_HRBAS00INFTY~AFTER_INPUT.
  endmethod.


  method IF_EX_HRBAS00INFTY~BEFORE_OUTPUT.
  endmethod.


  method IF_EX_HRBAS00INFTY~BEFORE_UPDATE.
  endmethod.


  METHOD if_ex_hrbas00infty~in_update.

    FIELD-SYMBOLS: <fs_new_image> TYPE aft_image.

    IF NOT new_image IS INITIAL.
      LOOP AT new_image ASSIGNING <fs_new_image>.
        CALL FUNCTION 'ZONFM_ONE_CONNECT_ORG' IN UPDATE TASK
          EXPORTING
            is_new_image = <fs_new_image>
            iv_update    = abap_true
            iv_delete    = abap_false.
      ENDLOOP.
    ELSE.
      LOOP AT old_image ASSIGNING <fs_new_image>.
        CALL FUNCTION 'ZONFM_ONE_CONNECT_ORG'
          EXPORTING
            is_new_image = <fs_new_image>
            iv_update    = abap_false
            iv_delete    = abap_true.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
