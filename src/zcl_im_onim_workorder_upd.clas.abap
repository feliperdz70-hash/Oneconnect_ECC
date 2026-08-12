class ZCL_IM_ONIM_WORKORDER_UPD definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_WORKORDER_UPDATE .
protected section.
private section.

* Tipo de objeto BOR y evento que se publican para la orden de producción.
* BUS2005 = orden de producción (clave AUFNR). Si se trabaja con un subtipo
* delegado propio (como ZBUS2075 para la orden interna) o con otro evento,
* sólo hay que cambiar estas constantes: la lógica no depende de ellas.
  constants C_OBJTYPE type SWETYPECOU-OBJTYPE value 'BUS2005' .
  constants C_EVENT type SWETYPECOU-EVENT value 'CHANGED' .
* Clase de orden (AUFK-AUTYP): 10 = orden de producción (CO01 / CO02)
  constants C_AUTYP_PRODORD type AUFTYP value '10' .

  methods RAISE_EVENT
    importing
      !IV_AUFNR type AUFNR .
ENDCLASS.



CLASS ZCL_IM_ONIM_WORKORDER_UPD IMPLEMENTATION.


  method IF_EX_WORKORDER_UPDATE~ARCHIVE_OBJECTS.
  endmethod.


  method IF_EX_WORKORDER_UPDATE~AT_DELETION_FROM_DATABASE.
  endmethod.


  method IF_EX_WORKORDER_UPDATE~AT_RELEASE.
*  break-POINT.
  endmethod.


  METHOD if_ex_workorder_update~at_save.
*----------------------------------------------------------------------*
* No se lanza el evento aquí a propósito.
*
* AT_SAVE se ejecuta en diálogo ANTES de la actualización: en una
* creación con CO01 la orden todavía trabaja con un número temporal
* (%00000000001), el definitivo se asigna después (ver NUMBER_SWITCH).
* Además, la grabación aún puede fallar, con lo que se publicaría un
* evento de una orden que nunca llegó a existir.
*
* El evento se dispara en IN_UPDATE, que ya se ejecuta en la update task
* con el número definitivo.
*----------------------------------------------------------------------*
  ENDMETHOD.


  METHOD if_ex_workorder_update~before_update.
* TYPE-POOLS: swc.

  ENDMETHOD.


  method IF_EX_WORKORDER_UPDATE~CMTS_CHECK.
  endmethod.


  method IF_EX_WORKORDER_UPDATE~INITIALIZE.
  endmethod.


  METHOD if_ex_workorder_update~in_update.
*----------------------------------------------------------------------*
* Dispara el evento BOR de la orden de producción tras la grabación
* (CO01 = creación, CO02 = modificación).
*
* Este método se ejecuta DENTRO de la update task, es decir después del
* cambio de número temporal por el definitivo, por lo que IT_HEADER ya
* trae el AUFNR real también en la creación.
*
* Al ejecutarse en la misma LUW que la actualización de la orden, el
* evento sólo se persiste si la grabación se confirma. Por ese motivo
* aquí NO se debe hacer COMMIT WORK.
*----------------------------------------------------------------------*
    DATA: lt_aufnr TYPE STANDARD TABLE OF aufnr WITH DEFAULT KEY,
          lv_aufnr TYPE aufnr.

    FIELD-SYMBOLS: <ls_header> TYPE any,
                   <lv_value>  TYPE any.

*   Los campos de la cabecera se leen de forma dinámica para no depender
*   de la estructura concreta de COBAI_T_HEADER, que varía según release.
    LOOP AT it_header ASSIGNING <ls_header>.

      ASSIGN COMPONENT 'AUFNR' OF STRUCTURE <ls_header> TO <lv_value>.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      lv_aufnr = <lv_value>.

*     Números temporales de la creación: nunca deben publicarse.
      IF lv_aufnr IS INITIAL
      OR lv_aufnr(1) = '%'
      OR lv_aufnr(1) = '$'.
        CONTINUE.
      ENDIF.

*     Sólo órdenes de producción. Esta BAdI también se llama para
*     órdenes de mantenimiento, de proceso, etc.
*     El IF va anidado a propósito: si el ASSIGN falla el field-symbol
*     queda sin asignar, y leerlo en la misma condición dependería del
*     orden de evaluación (un GETWA_NOT_ASSIGNED aquí cancelaría la
*     actualización de la orden y la dejaría en SM13).
      ASSIGN COMPONENT 'AUTYP' OF STRUCTURE <ls_header> TO <lv_value>.
      IF sy-subrc = 0.
        IF <lv_value> <> c_autyp_prodord.
          CONTINUE.
        ENDIF.
      ENDIF.

      APPEND lv_aufnr TO lt_aufnr.

    ENDLOOP.

*   Una misma orden puede venir repetida (p.ej. órdenes colectivas):
*   se envía un único evento por orden.
    SORT lt_aufnr.
    DELETE ADJACENT DUPLICATES FROM lt_aufnr.

    LOOP AT lt_aufnr INTO lv_aufnr.
      me->raise_event( iv_aufnr = lv_aufnr ).
    ENDLOOP.

  ENDMETHOD.


  method IF_EX_WORKORDER_UPDATE~NUMBER_SWITCH.
*----------------------------------------------------------------------*
* Aquí SAP sustituye el número temporal de la creación (I_AUFNR_OLD,
* %00000000001) por el definitivo (I_AUFNR_NEW). Se ejecuta sólo en la
* creación y todavía en diálogo.
*
* Es la alternativa a IN_UPDATE cuando se necesita distinguir creación
* de modificación: en ese caso el evento debe registrarse con
* SWE_EVENT_CREATE_IN_UPD_TASK para que sólo se publique si la orden se
* graba realmente.
*----------------------------------------------------------------------*
  endmethod.


  method IF_EX_WORKORDER_UPDATE~REORG_STATUS_ACTIVATE.
  endmethod.


  method IF_EX_WORKORDER_UPDATE~REORG_STATUS_ACT_CHECK.
  endmethod.


  method IF_EX_WORKORDER_UPDATE~REORG_STATUS_REVOKE.
  endmethod.


  METHOD raise_event.
*----------------------------------------------------------------------*
* Publicación del evento BOR. Se llama desde IN_UPDATE, o sea que ya
* estamos en la update task: se usa SWE_EVENT_CREATE (no la variante
* IN_UPD_TASK) igual que en la BAdI de movimientos de mercancía.
*----------------------------------------------------------------------*
    DATA: lv_objkey TYPE sweinstcou-objkey.

    lv_objkey = iv_aufnr.

    CALL FUNCTION 'SWE_EVENT_CREATE'
      EXPORTING
        objtype           = c_objtype
        objkey            = lv_objkey
        event             = c_event
      EXCEPTIONS
        objtype_not_found = 1
        OTHERS            = 2.

    IF sy-subrc <> 0.
*     El error no se propaga: un fallo al crear el evento no debe
*     cancelar la actualización de la orden (registro en SM13).
*     Para analizarlo, activar la traza de eventos con SWELS y
*     revisarla en SWEL.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
