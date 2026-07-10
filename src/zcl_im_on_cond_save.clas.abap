class ZCL_IM_ON_COND_SAVE definition
  public
  final
  create public .

public section.

  interfaces IF_EX_SD_COND_SAVE_A .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_ON_COND_SAVE IMPLEMENTATION.


  METHOD if_ex_sd_cond_save_a~condition_save_exit.
    DATA: w_ct     LIKE LINE OF ct_time,
          v_tabla  TYPE tabname,
          i_where  TYPE rsds_where_tab,
          w_where  TYPE rsdswhere,
          lv_knumh TYPE string.

    CONSTANTS: lc_comilla TYPE c LENGTH 1 VALUE ''''.

    LOOP AT ct_time INTO w_ct.
      CONCATENATE 'A' w_ct-kotabnr INTO v_tabla.
      CONCATENATE lc_comilla w_ct-knumh lc_comilla  INTO lv_knumh.
      CONDENSE lv_knumh.

      IF sy-tabix = 1.
        CONCATENATE ' ( KNUMH EQ ' lV_knumh ' )' INTO w_where SEPARATED BY space.
      ELSE.
        CONCATENATE ' AND ( KNUMH EQ' lV_knumh ' )' INTO w_where SEPARATED BY space.
      ENDIF.
      APPEND w_where TO i_where.
    ENDLOOP.

    CALL FUNCTION 'ZONFM_OC_PRICE_EVENT'
      STARTING NEW TASK 'PRECIOS'
      EXPORTING
        i_table = v_tabla
        i_where = i_where
        i_knumh = w_ct-knumh.
  ENDMETHOD.
ENDCLASS.
