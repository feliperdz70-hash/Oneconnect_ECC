class ZCL_IM_ONIM_WORKORDER_UPD definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_WORKORDER_UPDATE .
protected section.
private section.
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
* El evento se dispara desde IN_UPDATE.
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
* Publica el evento BOR BUS2005 de la orden de producción tras la
* grabación (CO01 = creación, CO02 = modificación).
*
* Este método se ejecuta DENTRO de la update task, después del cambio de
* número temporal por el definitivo, por lo que IT_HEADER ya trae el
* AUFNR real también en la creación.
*
* La publicación se delega en ZONFM_BUS2005_FROM_BADI, registrada con
* IN BACKGROUND TASK (tRFC): se ejecuta DESPUÉS de que la verbalización
* confirme, así que la orden ya está en AFKO y el envío de One Connect
* no viaja dentro de la LUW de la orden. Nunca usar IN UPDATE TASK aquí:
* ya estamos en la verbalización y anidar otra cancela la actualización.
*----------------------------------------------------------------------*

    DATA: v_aufnr  TYPE sweinstcou-objkey,
          w_header LIKE LINE OF it_header.

    LOOP AT it_header INTO w_header.

*     Sólo órdenes de producción: esta BAdI también entrega grafos (20),
*     órdenes de mantenimiento (30) y de proceso (40).
      CHECK w_header-autyp = '10'.
      CHECK w_header-aufnr IS NOT INITIAL.
      CHECK w_header-aufnr(1) <> '%'.

      MOVE w_header-aufnr TO v_aufnr.

*     tRFC: se registra ahora y se ejecuta después del commit de la
*     verbalización, cuando la orden ya está confirmada en AFKO.
      CALL FUNCTION 'ZONFM_BUS2005_FROM_BADI'
        IN BACKGROUND TASK
        EXPORTING
          objkey = v_aufnr.

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
ENDCLASS.
