*&---------------------------------------------------------------------*
*& Report ZONRE_ENVIO_EJEC_ZM
*&---------------------------------------------------------------------*
*& Selecciona los interlocutores con funcion de interlocutor ZM en las
*& organizaciones de ventas indicadas (por defecto 5900 y 1000), genera
*& la lista de ejecutivos (nro. de personal) y los distribuye mediante
*& el programa estandar RHALEINI (equivalente a la transaccion PFAL).
*&
*& El nro. de personal del ejecutivo se toma del campo KNVP-PERNR de la
*& funcion de interlocutor. Si se informa una variante de RHALEINI/PFAL
*& (P_VARI) los parametros de distribucion (sistema receptor, tipo de
*& mensaje, infotipos, etc.) se toman de dicha variante; en caso
*& contrario RHALEINI usa el modelo de distribucion ALE para determinar
*& el/los sistema(s) receptor(es) y el tipo de mensaje HRMD_A.
*&---------------------------------------------------------------------*
REPORT zonre_envio_ejec_zm.

TABLES: knvp.

TYPES: BEGIN OF ty_ejec,
         pernr TYPE knvp-pernr,
         kunnr TYPE knvp-kunnr,
         vkorg TYPE knvp-vkorg,
         vtweg TYPE knvp-vtweg,
         spart TYPE knvp-spart,
         parvw TYPE knvp-parvw,
       END OF ty_ejec.

DATA: gt_knvp TYPE STANDARD TABLE OF ty_ejec,
      gt_ejec TYPE STANDARD TABLE OF ty_ejec,
      gs_ejec TYPE ty_ejec.

DATA: gr_objid TYPE RANGE OF hrobjid,
      gs_objid LIKE LINE OF gr_objid.

DATA: go_alv TYPE REF TO cl_salv_table,
      gx_msg TYPE REF TO cx_root,
      gv_msg TYPE string.

*&---------------------------------------------------------------------*
*& Selection screen
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: so_vkorg FOR knvp-vkorg.
PARAMETERS:     p_parvw TYPE knvp-parvw DEFAULT 'ZM' OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
PARAMETERS: p_plvar  TYPE plvar      DEFAULT '01' OBLIGATORY,
            p_otype  TYPE otype      DEFAULT 'P'  OBLIGATORY,
            p_rcvsys TYPE logsys,
            p_vari   TYPE raldb_vari.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-003.
PARAMETERS: p_list AS CHECKBOX DEFAULT 'X',
            p_send AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK b3.

*&---------------------------------------------------------------------*
INITIALIZATION.
  so_vkorg-sign   = 'I'.
  so_vkorg-option = 'EQ'.
  so_vkorg-low    = '5900'.
  APPEND so_vkorg.
  so_vkorg-low    = '1000'.
  APPEND so_vkorg.

*&---------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM f_select_partners.

  IF gt_ejec IS INITIAL.
    MESSAGE 'No se encontraron interlocutores para los criterios indicados' TYPE 'I'.
    RETURN.
  ENDIF.

  IF p_list = abap_true AND sy-batch IS INITIAL.
    PERFORM f_display_list.
  ENDIF.

  IF p_send = abap_true.
    PERFORM f_build_range.
    PERFORM f_send_rhaleini.
  ENDIF.

*&---------------------------------------------------------------------*
*& Form F_SELECT_PARTNERS
*&---------------------------------------------------------------------*
*& Lee los interlocutores ZM de las organizaciones de venta indicadas
*& y deja en GT_EJEC los ejecutivos con nro. de personal, sin repetir.
*&---------------------------------------------------------------------*
FORM f_select_partners.

  SELECT pernr kunnr vkorg vtweg spart parvw
    FROM knvp
    INTO TABLE gt_knvp
   WHERE vkorg IN so_vkorg
     AND parvw =  p_parvw.

  LOOP AT gt_knvp INTO gs_ejec.
    IF gs_ejec-pernr IS INITIAL.
      CONTINUE.
    ENDIF.
    APPEND gs_ejec TO gt_ejec.
  ENDLOOP.

  SORT gt_ejec BY pernr.
  DELETE ADJACENT DUPLICATES FROM gt_ejec COMPARING pernr.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_DISPLAY_LIST
*&---------------------------------------------------------------------*
*& Muestra la lista de ejecutivos seleccionados en ALV.
*&---------------------------------------------------------------------*
FORM f_display_list.

  TRY.
      cl_salv_table=>factory(
        IMPORTING r_salv_table = go_alv
        CHANGING  t_table      = gt_ejec ).

      go_alv->get_functions( )->set_all( abap_true ).
      go_alv->get_columns( )->set_optimize( abap_true ).
      go_alv->display( ).

    CATCH cx_salv_msg INTO gx_msg.
      gv_msg = gx_msg->get_text( ).
      MESSAGE gv_msg TYPE 'I'.
  ENDTRY.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_BUILD_RANGE
*&---------------------------------------------------------------------*
*& Construye el rango de object IDs (nro. de personal) para RHALEINI.
*&---------------------------------------------------------------------*
FORM f_build_range.

  CLEAR gr_objid.
  LOOP AT gt_ejec INTO gs_ejec.
    gs_objid-sign   = 'I'.
    gs_objid-option = 'EQ'.
    gs_objid-low    = gs_ejec-pernr.
    APPEND gs_objid TO gr_objid.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form F_SEND_RHALEINI
*&---------------------------------------------------------------------*
*& Lanza la distribucion de los ejecutivos via RHALEINI (PFAL).
*&---------------------------------------------------------------------*
FORM f_send_rhaleini.

  IF gr_objid IS INITIAL.
    MESSAGE 'No hay ejecutivos con nro. de personal para distribuir' TYPE 'I'.
    RETURN.
  ENDIF.

  IF p_vari IS NOT INITIAL.
*   Los parametros de distribucion (sistema receptor, tipo de mensaje,
*   infotipos, etc.) se toman de la variante indicada de RHALEINI/PFAL.
    SUBMIT rhaleini
      USING SELECTION-SET p_vari
      WITH pchobjid IN gr_objid
      AND RETURN.
  ELSE.
*   Sin variante: se envian los objetos indicados; el receptor y el tipo
*   de mensaje (HRMD_A) los resuelve el modelo de distribucion ALE.
    SUBMIT rhaleini
      WITH pchplvar =  p_plvar
      WITH pchotype =  p_otype
      WITH pchobjid IN gr_objid
      AND RETURN.
  ENDIF.

  gv_msg = |Distribucion lanzada para { lines( gt_ejec ) } ejecutivo(s) via RHALEINI|.
  MESSAGE gv_msg TYPE 'I'.

ENDFORM.
