"Name: \PR:SAPMKAUF\FO:SICHERN\SE:END\EI
ENHANCEMENT 0 ZONEI_INTERNAL_ORDER.
* TYPE-POOLS: swc.
    DATA: lv_event  TYPE swo_event,
          lv_objkey TYPE SWEINSTCOU-OBJKEY,
          lw_hdr TYPE CAUFVDB.
*   break frgdev9.
    " 1. Verificar si es una CREACIÓN (C_AUFK_OLD está vacío en creación)
      " 2. Asignar los valores del evento

      lv_objkey = coas-aufnr. " El número de Orden Interna es la clave
      lv_event  = 'CREATED_Z'.       " Su evento validado

      " 3. Llamar la Función de Módulo para Disparar el Evento en Update Task
      " CRUCIAL: Esto asegura que el evento se dispare solo si la Orden Interna se graba exitosamente.
      CALL FUNCTION 'SWE_EVENT_CREATE' "IN UPDATE TASK
        EXPORTING
          objtype           = 'ZBUS2075'  " Su objeto BOR delegado
          objkey            = lv_objkey
          event             = lv_event
*          creator           = sy-uname
        EXCEPTIONS
          objtype_not_found = 1
          OTHERS            = 2.

      IF sy-subrc <> 0.
        " Manejo de error: puede ser ignorado o registrarse en un Log de Aplicación (SLG1).
      ELSE.
        COMMIT WORK AND WAIT.
      ENDIF.

ENDENHANCEMENT.
