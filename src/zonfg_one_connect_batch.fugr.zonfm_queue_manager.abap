FUNCTION zonfm_queue_manager.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(EVENT) LIKE  SWETYPECOU-EVENT
*"     VALUE(RECTYPE) LIKE  SWETYPECOU-RECTYPE
*"     VALUE(OBJTYPE) LIKE  SWETYPECOU-OBJTYPE
*"     VALUE(OBJKEY) LIKE  SWEINSTCOU-OBJKEY
*"  TABLES
*"      EVENT_CONTAINER STRUCTURE  SWCONT
*"----------------------------------------------------------------------
  DATA: l_container       TYPE REF TO if_swf_cnt_container.
  DATA: lt_values         TYPE swconttab.
  DATA: l_sender          TYPE sibflporb.
  DATA: l_event           TYPE sibfevent.
  DATA: l_rectype         TYPE swferectyp.
  DATA: l_handler         TYPE sibflporb.
  DATA: lx_text           TYPE REF TO cx_root.

  l_sender-catid  = swfev_objcateg_bor.
  l_sender-typeid = objtype.
  l_sender-instid = objkey.
  l_event         = event.
  l_rectype       = rectype.

  IF objtype = 'ZBUS1011' AND objkey NE ''.
    l_sender-instid = objkey+3.
  ENDIF.

  DATA: lo_json_automatic TYPE REF TO zoncl_fetch_data.  "_v2.

  CREATE OBJECT lo_json_automatic.

*  IF l_event = 'DELETE' OR l_event = 'DELETED'.
*   DO. ENDDO.
*  ENDIF.

  " DELETE CASE
  DATA: ls_cdpos   TYPE cdpos,
        lv_chngind TYPE cdpos-chngind.

  FIELD-SYMBOLS: <fs_fld> TYPE any.

  LOOP AT event_container WHERE element EQ 'CD_CHANGENR'
                             OR element EQ 'CD_OBJECTCLAS'
                             OR element EQ 'CD_OBJECTID'.

    ASSIGN COMPONENT event_container-element+3 OF STRUCTURE ls_cdpos TO <fs_fld>.
    IF sy-subrc EQ 0.
      <fs_fld> = event_container-value.
    ENDIF.

  ENDLOOP.

  IF ls_cdpos IS NOT INITIAL.

    SELECT SINGLE chngind
    INTO lv_chngind
    FROM cdpos
    WHERE objectclas = ls_cdpos-objectclas
      AND objectid = ls_cdpos-objectid
      AND changenr = ls_cdpos-changenr
      AND chngind = 'D'.

    IF sy-subrc EQ 0.
      l_event = 'DELETE'.
      l_sender-instid = ls_cdpos-objectid.
    ENDIF.

  ENDIF.

  TRY.
      lo_json_automatic->send_event_automatic( is_sender = l_sender
                                               i_event  = l_event ).

    CATCH cx_root INTO lx_text.
  ENDTRY.

ENDFUNCTION.
