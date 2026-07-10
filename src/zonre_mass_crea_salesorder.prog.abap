*&---------------------------------------------------------------------*
*& Report  ZMASS_SO_CREATE
*& Creación masiva de Sales Orders via BAPI_SALESORDER_CREATEFROMDAT2
*&---------------------------------------------------------------------*
*& Parámetros:
*&   - Número de órdenes a crear (default: 5000)
*& Datos fijos:
*&   - Tipo de orden  : OR
*&   - Sales Org      : 1000
*&   - Distr. Channel : 10
*&   - Division       : 10
*&   - Cliente        : 0000100009
*&   - Material       : F226 (10 partidas x 1 PC)
*&---------------------------------------------------------------------*
REPORT zmass_so_create
  NO STANDARD PAGE HEADING
  LINE-SIZE 255.

*----------------------------------------------------------------------*
*  TIPOS
*----------------------------------------------------------------------*
TYPES: BEGIN OF ty_result,
         num_orden  TYPE i,
         vbeln      TYPE vbeln_va,
         mensaje    TYPE string,
         status     TYPE char1,   " S=OK  E=Error
       END OF ty_result.

*----------------------------------------------------------------------*
*  PARÁMETROS DE SELECCIÓN
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01.

PARAMETERS:
  p_qty  TYPE i DEFAULT 5000 OBLIGATORY.   " Número de órdenes a crear

SELECTION-SCREEN END OF BLOCK b1.

*----------------------------------------------------------------------*
*  CONSTANTES
*----------------------------------------------------------------------*
CONSTANTS:
  gc_order_type  TYPE auart   VALUE 'TA',
  gc_sales_org   TYPE vkorg   VALUE '1000',
  gc_distr_chan  TYPE vtweg   VALUE '10',
  gc_division    TYPE spart   VALUE '10',
  gc_sold_to     TYPE kunnr   VALUE '0000100009',
  gc_material    TYPE matnr   VALUE 'F226',
  gc_qty         TYPE kwmeng  VALUE '1000',
  gc_uom         TYPE vrkme   VALUE 'ST',
  gc_num_items   TYPE i       VALUE 10.

*----------------------------------------------------------------------*
*  VARIABLES GLOBALES
*----------------------------------------------------------------------*
DATA:
  gt_result    TYPE STANDARD TABLE OF ty_result,
  gv_ok        TYPE i VALUE 0,
  gv_error     TYPE i VALUE 0.

*----------------------------------------------------------------------*
*  INICIO
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_validate_params.
  PERFORM f_create_orders.
*  PERFORM f_display_results.


*----------------------------------------------------------------------*
*  FORM: Validar parámetros
*----------------------------------------------------------------------*
FORM f_validate_params.

  IF p_qty <= 0.
    MESSAGE 'El número de órdenes debe ser mayor a 0.' TYPE 'E'.
  ENDIF.

  WRITE: / 'Iniciando creación de', p_qty, 'Sales Orders...'.
  WRITE: / '----------------------------------------------'.
  SKIP.

ENDFORM.


*----------------------------------------------------------------------*
*  FORM: Crear órdenes masivamente
*----------------------------------------------------------------------*
FORM f_create_orders.

  DATA:
    ls_header        TYPE bapisdhd1,
    ls_header_x      TYPE bapisdhd1x,
    lt_items         TYPE STANDARD TABLE OF bapisditm,
    lt_items_x       TYPE STANDARD TABLE OF bapisditmx,
    lt_SCHED         type STANDARD TABLE OF BAPISCHDL,
    lt_SCHED_x       type STANDARD TABLE OF BAPISCHDLX,
    ls_SCHED         type BAPISCHDL,
    ls_SCHED_x       type BAPISCHDLX,
    lt_partners      TYPE STANDARD TABLE OF bapiparnr,
    lt_return        TYPE STANDARD TABLE OF bapiret2,
    ls_item          TYPE bapisditm,
    ls_item_x        TYPE bapisditmx,
    ls_partner       TYPE bapiparnr,
    ls_return        TYPE bapiret2,
    lv_vbeln         TYPE vbeln_va,
    lv_posnr         TYPE posnr_va,
    lv_orden_num     TYPE i,
    ls_result        TYPE ty_result,
    lv_has_error     TYPE abap_bool,
    lv_msg           TYPE string.

  "---- Cabecera (fija para todas las órdenes) -------------------------
  ls_header-doc_type    = gc_order_type.
  ls_header-sales_org   = gc_sales_org.
  ls_header-distr_chan  = gc_distr_chan.
  ls_header-division    = gc_division.
  ls_header-purch_date  = sy-datum.
  ls_header-PURCH_NO_C  = 'volume test'.


  ls_header_x-doc_type   = abap_true.
  ls_header_x-sales_org  = abap_true.
  ls_header_x-distr_chan = abap_true.
  ls_header_x-division   = abap_true.
  ls_header_x-purch_date = abap_true.
  ls_header_x-PURCH_NO_C = abap_true.

  "---- Interlocutor: Sold-To ------------------------------------------
  CLEAR ls_partner.
  ls_partner-partn_role = 'AG'.
  ls_partner-partn_numb = gc_sold_to.
  APPEND ls_partner TO lt_partners.

  "---- Partidas (10 líneas con F226 x 1 PC) ---------------------------
  DO gc_num_items TIMES.
    lv_posnr = sy-index * 10.          " 10, 20, 30 ... 100

    CLEAR ls_item.
    ls_item-itm_number = lv_posnr.
    ls_item-material   = gc_material.
    ls_item-plant = '1000'.
    ls_item-target_qty = gc_qty.
    ls_item-target_qu = gc_uom.
    ls_item-sales_unit = gc_uom.
    APPEND ls_item TO lt_items.

    CLEAR ls_item_x.
    ls_item_x-itm_number  = lv_posnr.
    ls_item_x-material    = abap_true.
    ls_item_x-plant       = abap_true.
    ls_item_x-target_qty  = abap_true.
    ls_item_x-target_qu   = abap_true.
    ls_item_x-sales_unit  = abap_true.
    APPEND ls_item_x TO lt_items_x.

    CLEAR ls_sched.
    ls_sched-itm_number  = lv_posnr.
    ls_sched-sched_line  = '0001'.
    ls_sched-req_date    = sy-datum.
    ls_sched-req_qty     = gc_qty.
    APPEND ls_sched to lt_sched.

    CLEAR ls_sched_x.
    ls_sched_x-itm_number  = lv_posnr.
    ls_sched_x-sched_line  = '0001'.
    ls_sched_x-req_date    = 'X'.
    ls_sched_x-req_qty     = 'X'.
    APPEND ls_sched_x to lt_sched_x.

  ENDDO.

  "---- Loop principal -------------------------------------------------
  DO p_qty TIMES.
    lv_orden_num = sy-index.

    CLEAR: lv_vbeln, lt_return, ls_result, lv_has_error, lv_msg.

    CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
      EXPORTING
        order_header_in      = ls_header
        order_header_inx     = ls_header_x
      IMPORTING
        salesdocument        = lv_vbeln
      TABLES
        return               = lt_return
        order_items_in       = lt_items
        order_items_inx      = lt_items_x
        ORDER_SCHEDULES_IN   = lt_sched
        ORDER_SCHEDULES_INx  = lt_sched_x
        order_partners       = lt_partners.

    "---- Revisar mensajes de retorno ----------------------------------
    LOOP AT lt_return INTO ls_return
      WHERE type CA 'EAX'.
      lv_has_error = abap_true.
      CONCATENATE lv_msg ls_return-message INTO lv_msg
        SEPARATED BY ' | '.
    ENDLOOP.

    IF lv_has_error = abap_true OR lv_vbeln IS INITIAL.
      "---- Rollback si hubo error ------------------------------------
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      ls_result-num_orden = lv_orden_num.
      ls_result-vbeln     = space.
      ls_result-status    = 'E'.
      ls_result-mensaje   = lv_msg.
      APPEND ls_result TO gt_result.
      ADD 1 TO gv_error.

    ELSE.
      "---- Commit tras cada creación exitosa -------------------------
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.

*      ls_result-num_orden = lv_orden_num.
*      ls_result-vbeln     = lv_vbeln.
*      ls_result-status    = 'S'.
*      ls_result-mensaje   = 'Creada correctamente'.
*      APPEND ls_result TO gt_result.
      ADD 1 TO gv_ok.
    ENDIF.

    "---- Progreso en pantalla cada 100 registros --------------------
**    IF lv_orden_num MOD 100 = 0.
**      WRITE: / 'Procesadas:', lv_orden_num, 'órdenes de', p_qty,
**               '| OK:', gv_ok, '| Errores:', gv_error.
**    ENDIF.

  ENDDO.

ENDFORM.


*----------------------------------------------------------------------*
*  FORM: Mostrar resultados en ALV
*----------------------------------------------------------------------*
FORM f_display_results.

  DATA:
    lt_fieldcat  TYPE slis_t_fieldcat_alv,
    ls_fieldcat  TYPE slis_fieldcat_alv,
    ls_layout    TYPE slis_layout_alv.

  "---- Resumen en lista antes del ALV --------------------------------
  WRITE: / 'Total solicitadas:', p_qty.
  WRITE: / 'Creadas OK       :', gv_ok.
  WRITE: / 'Con error        :', gv_error.
  SKIP.

  "---- Fieldcatalog ALV ---------------------------------------------
  DEFINE add_field.
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname  = &1.
    ls_fieldcat-seltext_m  = &2.
    ls_fieldcat-outputlen  = &3.
    APPEND ls_fieldcat TO lt_fieldcat.
  END-OF-DEFINITION.

  add_field 'NUM_ORDEN' 'Nro.'       8.
  add_field 'STATUS'    'St.'        3.
  add_field 'VBELN'     'Sales Doc'  12.
  add_field 'MENSAJE'   'Mensaje'    80.

  "---- Layout -------------------------------------------------------
  ls_layout-info_fieldname    = 'STATUS'.
  ls_layout-zebra             = abap_true.
  ls_layout-colwidth_optimize = abap_true.

  "---- Llamada ALV -------------------------------------------------
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      it_fieldcat        = lt_fieldcat
      is_layout          = ls_layout
    TABLES
      t_outtab           = gt_result
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.

  IF sy-subrc <> 0.
    "-- Fallback: listado simple si ALV falla
    LOOP AT gt_result INTO DATA(ls_res).
      WRITE: / ls_res-num_orden, ls_res-status, ls_res-vbeln, ls_res-mensaje.
    ENDLOOP.
  ENDIF.

ENDFORM.
