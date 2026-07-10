class ZONCL_MB_DOCUMENT_V2 definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_MB_DOCUMENT_BADI .
protected section.
private section.
ENDCLASS.



CLASS ZONCL_MB_DOCUMENT_V2 IMPLEMENTATION.


  method IF_EX_MB_DOCUMENT_BADI~MB_DOCUMENT_BEFORE_UPDATE.
  endmethod.


  METHOD if_ex_mb_document_badi~mb_document_update.
    DATA: ls_mkpf TYPE mkpf.

    DATA: l_objtype TYPE swetypecou-objtype,
          l_objkey  TYPE sweinstcou-objkey,
          l_event   TYPE swetypecou-event.


    l_objtype  = 'ZBUSONEMD'.
    l_event    = 'CREATED'.

    READ TABLE xmkpf INDEX 1 INTO ls_mkpf.

    l_objkey    = ls_mkpf-mblnr && ls_mkpf-mjahr.

*-- raise the event
    CALL FUNCTION 'SWE_EVENT_CREATE'
      EXPORTING
        objtype           = l_objtype
        objkey            = l_objkey
        event             = l_event
      EXCEPTIONS
        objtype_not_found = 1
        OTHERS            = 2.

    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
*            RAISING objtype_not_found.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
