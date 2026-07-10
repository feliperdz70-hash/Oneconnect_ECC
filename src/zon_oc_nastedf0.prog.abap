*&---------------------------------------------------------------------*
*&  Include           ZON_NASTEDF0
*&---------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM JSON_SEND                                                *
*---------------------------------------------------------------------*
*       entry-point used from program RSNASTED for medium 'A'         *
*---------------------------------------------------------------------*
*  -->  US_SCREEN for use in future                                   *
*  <--  RC      returncode                                            *
*---------------------------------------------------------------------*
FORM json_send   USING rc
                       us_screen.                           "#EC CALLED

  CALL FUNCTION 'ZONFM_OC_EVENTSEND'
    EXPORTING
      object                        = nast
    EXCEPTIONS
      error_message_received        = 1
      data_not_relevant_for_sending = 2
      OTHERS                        = 3.
  IF sy-subrc =  0.
    rc = 0.
  ENDIF.


  PERFORM fill_nast_protocol.


ENDFORM.
