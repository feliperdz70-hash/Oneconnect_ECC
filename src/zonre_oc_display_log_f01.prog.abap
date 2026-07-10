*----------------------------------------------------------------------*
***INCLUDE ZONRE_ONI_DISPLAY_LOG_F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  LOG_SEARCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM log_search .


  DATA: ls_param            TYPE bal_s_lfil,
        lt_object           TYPE bal_r_logn,
        ls_object           TYPE bal_s_logn,
        lt_subo             TYPE bal_r_sub,
        ls_subo             TYPE bal_s_sub,
        lt_date             TYPE bal_r_date,
        ls_date             TYPE bal_s_date,
        ls_header           TYPE balhdr,
        l_s_display_profile TYPE bal_s_prof,
        l_s_fcat            TYPE bal_s_fcat,
        lv_tz               TYPE ttzz-tzone,
        lv_conteo           TYPE i.

  lv_conteo = 3000.

  ls_object-sign   = c_i.
  ls_object-option = c_eq.
  ls_object-low    = p_obje.
  APPEND ls_object TO lt_object.

  ls_subo-sign     = c_i.
  ls_subo-option   = c_eq.
  ls_subo-low      = p_subo.
  APPEND ls_subo TO lt_subo.

  lt_date[] = s_date[].

  ls_param-object    = lt_object[].
  ls_param-subobject = lt_subo[].
  ls_param-aldate    = lt_date[].

  CALL FUNCTION 'BAL_DB_SEARCH'
    EXPORTING
      i_s_log_filter     = ls_param
    IMPORTING
      e_t_log_header     = gt_header
    EXCEPTIONS
      log_not_found      = 1
      no_filter_criteria = 2
      OTHERS             = 3.
  IF sy-subrc = 0.
*    * Get standard display profile
    CALL FUNCTION 'BAL_DSP_PROFILE_SINGLE_LOG_GET'
      IMPORTING
        e_s_display_profile = l_s_display_profile.


    DATA: lwa_hea LIKE LINE OF gt_header.
    LOOP AT gt_header INTO lwa_hea.
      APPEND lwa_hea TO gt_aux.
      PERFORM ogr_log.
      CLEAR gt_aux.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  OGR_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->
*  <--
*----------------------------------------------------------------------*

FORM ogr_log.
  DATA: lt_handle  TYPE bal_t_logh,
        lv_msg     TYPE  bal_s_msg,
        lv_txt_msg TYPE  c,
        lv_guid    TYPE balloghndl,
        ls_log_ext TYPE zonst_oc_log_extu,
        ls_log     TYPE zonst_oc_log_ext_alv,
        ls_log_h   TYPE bal_s_log.

  CLEAR: gt_msg_handle,gt_log_handle.

  CALL FUNCTION 'BAL_DB_LOAD'
    EXPORTING
      i_t_log_header     = gt_aux
    IMPORTING
      e_t_log_handle     = gt_log_handle[]
      e_t_msg_handle     = gt_msg_handle[]
      e_t_locked         = gt_lock[]
    EXCEPTIONS
      no_logs_specified  = 1
      log_not_found      = 2
      log_already_loaded = 3
      OTHERS             = 4.
  IF sy-subrc = 0.

    lt_handle[] = gt_log_handle[].

    DATA: ls_msg LIKE LINE OF gt_msg_handle.
    LOOP AT gt_msg_handle INTO ls_msg.
      CLEAR: ls_log, ls_log_ext.

      CALL FUNCTION 'BAL_LOG_HDR_READ'
        EXPORTING
          i_log_handle  = ls_msg-log_handle
          i_langu       = sy-langu
        IMPORTING
          e_s_log       = ls_log_h
        EXCEPTIONS
          log_not_found = 1
          OTHERS        = 2.

      ls_log-date  = ls_log_h-aldate.
      ls_log-time  = ls_log_h-altime.
      ls_log-user  = ls_log_h-aluser.
      ls_log-code  = ls_log_h-altcode.
      ls_log-prog  = ls_log_h-alprog.

      CALL FUNCTION 'BAL_LOG_MSG_READ'
        EXPORTING
          i_s_msg_handle = ls_msg
        IMPORTING
          e_s_msg        = lv_msg
          e_txt_msg      = lv_txt_msg.

      ls_log-mestyp  = lv_msg-msgty.
      ls_log-tabname = lv_msg-msgv1.
      ls_log-key     =  lv_msg-msgv2.
      ls_log-type    = lv_msg-msgty.
      ls_log-id      = lv_msg-msgid.
      ls_log-number  = lv_msg-msgno.


      ls_log_ext = lv_msg-context-value.
      MOVE-CORRESPONDING ls_log_ext TO ls_log.

      CALL FUNCTION 'FORMAT_MESSAGE'
        EXPORTING
          id        = lv_msg-msgid
          lang      = sy-langu
          no        = lv_msg-msgno
          v1        = lv_msg-msgv1
          v2        = lv_msg-msgv2
          v3        = lv_msg-msgv3
          v4        = lv_msg-msgv4
        IMPORTING
          msg       = ls_log-message
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
      IF sy-subrc <> 0.
        CLEAR ls_log-message.
      ENDIF.

      IF NOT ls_log_ext-comments IS INITIAL.
        ls_log-message = ls_log_ext-comments.
      ENDIF.

      CASE ls_log-type.
        WHEN c_s.
          ls_log-icon = c_green.
        WHEN c_w.
          ls_log-icon = c_yellow.
        WHEN c_e.
          ls_log-icon = c_red.
      ENDCASE.

      APPEND ls_log TO gt_log.
      CLEAR ls_log.
    ENDLOOP.

  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

FORM display_alv.

  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv,
        ls_layout   TYPE slis_layout_alv,
        ls_variant  TYPE disvariant.

*---------------------------------------------------------------------*
* Fieldcatalog from DDIC structure
*---------------------------------------------------------------------*
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_structure_name       = 'ZONST_OC_LOG_EXT_ALV'
      i_inclname             = sy-repid
    CHANGING
      ct_fieldcat            = lt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

*---------------------------------------------------------------------*
* Adjust ICON column manually
*---------------------------------------------------------------------*
  LOOP AT lt_fieldcat ASSIGNING FIELD-SYMBOL(<fs_fc>).
    IF <fs_fc>-fieldname = 'ICON'.
      <fs_fc>-icon = 'X'.
      <fs_fc>-seltext_l = 'Status'.
    ENDIF.
  ENDLOOP.

*---------------------------------------------------------------------*
* Layout
*---------------------------------------------------------------------*
  ls_layout-colwidth_optimize = 'X'.
  ls_layout-zebra             = 'X'.

*---------------------------------------------------------------------*
* Variant
*---------------------------------------------------------------------*
  ls_variant-report = sy-repid.

*---------------------------------------------------------------------*
* Display ALV
*---------------------------------------------------------------------*
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = sy-repid
      i_callback_user_command = 'USER_COMMANDN'
      is_layout               = ls_layout
      it_fieldcat             = lt_fieldcat
      i_save                  = 'A'
      is_variant              = ls_variant
    TABLES
      t_outtab                = gt_log
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  USER_COMMANDN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--R_UCOMM  text
*----------------------------------------------------------------------*

FORM user_commandn USING r_ucomm     LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.

  CASE r_ucomm.

    WHEN 'DELETE_BATCH_ITEM'.

      DELETE gt_log INDEX rs_selfield-tabindex.
      rs_selfield-refresh = 'X'.

  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_SUBOBJECTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_P_SUBO  text
*----------------------------------------------------------------------*
FORM get_subobjects  CHANGING p_subo.

  TYPES: BEGIN OF ty_val,
           domainv TYPE zonde_domain,
         END OF ty_val.

  DATA:
    lt_values TYPE STANDARD TABLE OF ty_val,
    lt_return TYPE STANDARD TABLE OF ddshretval.

  SELECT domainv
    FROM zonta_domains
    INTO TABLE lt_values
    WHERE spras = sy-langu.

    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    SORT lt_values BY domainv.
    DELETE ADJACENT DUPLICATES FROM lt_values.


    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield        = 'SUBO'
        value_org       = 'S'
      TABLES
        value_tab       = lt_values
        return_tab      = lt_return
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2
        OTHERS          = 3.

    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    DATA: ls_return LIKE LINE OF lt_return.
    READ TABLE lt_return INTO ls_return INDEX 1.
    p_subo = ls_return-fieldval.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_ENTITY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_P_entity  text
*----------------------------------------------------------------------*
FORM get_entity  CHANGING p_entity.

  TYPES: BEGIN OF ty_val,
           entity TYPE zonta_obj_oc-business_proc,
         END OF ty_val.

  DATA:
    lt_values TYPE STANDARD TABLE OF ty_val,
    lt_return TYPE STANDARD TABLE OF ddshretval.

  SELECT business_proc AS entity
    FROM zonta_obj_oc
    INTO TABLE lt_values
    WHERE domainv = p_subo.

    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    SORT lt_values BY entity.
    DELETE ADJACENT DUPLICATES FROM lt_values.


    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield        = 'ENTITY'
        value_org       = 'S'
      TABLES
        value_tab       = lt_values
        return_tab      = lt_return
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2
        OTHERS          = 3.

    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    DATA: ls_return LIKE LINE OF lt_return.
    READ TABLE lt_return INTO ls_return INDEX 1.
    p_entity = ls_return-fieldval.


ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_TABNAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_S_TABN_LOW  text
*----------------------------------------------------------------------*
FORM get_tabname  CHANGING p_tabname.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_SALV_FUNCTION
*&---------------------------------------------------------------------*
FORM user_command  USING    i_function TYPE salv_de_function.
  BREAK-POINT.
*
* IF i_function = 'EPAL'.
*    PERFORM unpal_printers.
*  ELSE.
*    PERFORM show_info.
*  ENDIF.
ENDFORM.
