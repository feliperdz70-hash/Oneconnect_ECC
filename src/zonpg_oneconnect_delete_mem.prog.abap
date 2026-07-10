*&---------------------------------------------------------------------*
*& Report ZONPG_ONECONNECT_DELETE_MEM
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zonpg_oneconnect_delete_mem.

DATA: lt_batch  TYPE STANDARD TABLE OF zonta_oc_batch,
      lt_tbtco  TYPE STANDARD TABLE OF tbtco,
      ls_tbtco  TYPE tbtco,
      lv_lines  TYPE i,
      lv_linesx TYPE string,
      lv_text   TYPE string,
      lv_answer TYPE c,
      lv_update TYPE boolean.

FIELD-SYMBOLS: <fs_batch> LIKE LINE OF lt_batch.

SELECTION-SCREEN: BEGIN OF BLOCK blk1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: r_memory RADIOBUTTON GROUP gp1 DEFAULT 'X',
              r_delete RADIOBUTTON GROUP gp1.
SELECTION-SCREEN: END OF BLOCK blk1.


SELECTION-SCREEN: BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-002.
  SELECT-OPTIONS: s_date FOR sy-datum.
  PARAMETERS: p_all AS CHECKBOX.
SELECTION-SCREEN: END OF BLOCK bl1.



REFRESH lt_batch[].
REFRESH lt_tbtco[].


IF r_memory = abap_true.

  SELECT *
    INTO TABLE lt_batch
    FROM zonta_oc_batch
    WHERE memory_deleted = abap_false.

  IF sy-subrc = 0.
    SELECT *
      INTO TABLE lt_tbtco
      FROM tbtco
      FOR ALL ENTRIES IN lt_batch
      WHERE jobname  = lt_batch-parent_jobname
        "AND jobcount = lt_batch-parent_jobcount
        AND status  NE 'F'
        AND periodic = abap_true.
  ENDIF.

  SORT lt_tbtco BY jobname lastchdate lastchtime.
  LOOP AT lt_batch ASSIGNING <fs_batch>.
    READ TABLE lt_tbtco INTO ls_tbtco WITH KEY jobname  = <fs_batch>-parent_jobname
                                               lastchdate = <fs_batch>-created_on
                                               lastchtime = <fs_batch>-created_at BINARY SEARCH.
    IF sy-subrc NE 0.
      lv_update = abap_true.
      DELETE FROM DATABASE zontconnectbatch(sc) ID <fs_batch>-execid.
      IF sy-subrc = 0.
        <fs_batch>-memory_deleted = abap_true.
        <fs_batch>-status = 'F'.
      ELSE.
        IF <fs_batch>-periodic = abap_false.
          <fs_batch>-memory_deleted = abap_true.
          <fs_batch>-status = 'F'.
        ELSE.
          <fs_batch>-status = 'E'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF lv_update = abap_true.
    MODIFY zonta_oc_batch FROM TABLE lt_batch.
    IF sy-subrc = 0.
      COMMIT WORK.
      MESSAGE s017(zon_cl_oc) WITH TEXT-t04.
    ENDIF.
  ELSE.
    MESSAGE s017(zon_cl_oc) WITH TEXT-t05.
  ENDIF.

* Delete old records
ELSE.
  SELECT *
    INTO TABLE lt_batch
    FROM zonta_oc_batch
    WHERE created_on IN s_date[].

  IF p_all IS  INITIAL.
    DELETE lt_batch WHERE memory_deleted = abap_false.
  ENDIF.

  DESCRIBE TABLE lt_batch LINES lv_lines.
  lv_linesx = lv_lines.
  CONCATENATE lv_linesx TEXT-t01 TEXT-t02   INTO lv_text SEPARATED BY space.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      text_question  = lv_text
      text_button_1  = TEXT-c01
      icon_button_1  = ' '
      text_button_2  = TEXT-c02
      icon_button_2  = ' '
    IMPORTING
      answer         = lv_answer
    EXCEPTIONS
      text_not_found = 1
      OTHERS         = 2.


  IF lv_answer = '1'.
    DELETE  zonta_oc_batch FROM TABLE lt_batch.
    IF sy-subrc = 0.
      MESSAGE s017(zon_cl_oc) WITH TEXT-t03.
    ENDIF.
  ENDIF.

ENDIF.
