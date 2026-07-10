*****           Implementation of object type BUS1001006           *****
INCLUDE <object>.
BEGIN_DATA OBJECT. " Do not change.. DATA is generated
* only private members may be inserted into structure private
DATA:
" begin of private,
"   to declare private attributes remove comments and
"   insert private attributes here ...
" end of private,
  BEGIN OF KEY,
      MATERIAL LIKE MARA-MATNR,
  END OF KEY.
END_DATA OBJECT. " Do not change.. DATA is generated

DEFINE bor_ret.
  exit_return &1 space space space space.
END-OF-DEFINITION.

TABLES: moff, tcurm, mara.

begin_method getmissedviews changing container.
DATA:
  getmissedviews LIKE syst-tabix.     "Ergebnisparameter
RANGES: rg_statm FOR moff-statm.
DATA: statuslist LIKE sy-entry.
DATA: o_moff TYPE swc_object.
DATA: it_moff LIKE o_moff OCCURS 50 WITH HEADER LINE.

DATA: BEGIN OF moff_key,
        maintenancestatus   LIKE moff-statm,
        createdon           LIKE moff-ersda,
        plant               LIKE moff-werks,
        salesorganization   LIKE moff-vkorg,
        distributionchannel LIKE moff-vtweg,
        purchorganization   LIKE moff-ekorg,
        valuationarea       LIKE moff-bwkey,
        material            LIKE moff-matnr,
        storagelocation     LIKE moff-lgort,
        whsenumber          LIKE moff-lgnum,
        storagetype         LIKE moff-lgtyp,
      END OF moff_key.

*mhi220596 Sicherstellen, daß das Material derzeit nicht bearbeitet wird
CALL FUNCTION 'ENQUEUE_EMMARAE'
  EXPORTING
*   MODE_MARA    = 'E'
*   MANDT        = SY-MANDT
    matnr        = object-key-material
*   X_MATNR      = ' '
    _scope       = '2'
    _wait        = 'X'
  EXCEPTIONS
    foreign_lock = 1.
*         SYSTEM_FAILURE = 2
*         OTHERS         = 3.
IF sy-subrc NE 0.
*     temp.Ausnahme: Material durch anderen Benutzer gesperrt
  exit_return 1000 object-key-material space space space.
ENDIF.

* Übergabeparameter (gesuchte Status) einlesen
swc_get_element container 'STATUSLIST' statuslist.

* Falls nicht leer, nur die gesuchten Status aus MOFF ermitteln
IF statuslist NE space.
  rg_statm-sign = 'I'. rg_statm-option = 'EQ'.
  CONDENSE statuslist NO-GAPS.
  WHILE statuslist(1) NE space.
    rg_statm-low = statuslist(1). COLLECT rg_statm.
    SHIFT statuslist.
  ENDWHILE.
ENDIF.

* gesuchte Einträge zum Material aus MOFF lesen
SELECT * FROM moff WHERE matnr = object-key-material
                   AND   statm IN rg_statm.
  moff_key-maintenancestatus   = moff-statm.
  moff_key-createdon           = moff-ersda.
  moff_key-plant               = moff-werks.
  moff_key-salesorganization   = moff-vkorg.
  moff_key-distributionchannel = moff-vtweg.
  moff_key-purchorganization   = moff-ekorg.
  moff_key-valuationarea       = moff-bwkey.
  moff_key-material            = moff-matnr.
  moff_key-storagelocation     = moff-lgort.
  moff_key-whsenumber          = moff-lgnum.
  moff_key-storagetype         = moff-lgtyp.

* aus dem Einträgen Objekte vom Typ MOFF erzeugen und sammeln
  swc_create_object it_moff 'MOFF' moff_key.
  APPEND it_moff.
ENDSELECT.

* RETURNwert der Methode belegen
getmissedviews = sy-dbcnt.

* Rückgabeparameter der Methode im Container ablegen
swc_set_table   container 'MissedViews' it_moff.
swc_set_element container result getmissedviews.

*mhi220596 Sperre freigeben
CALL FUNCTION 'DEQUEUE_EMMARAE'
  EXPORTING
*   MODE_MARA = 'E'
*   MANDT  = SY-MANDT
    matnr  = object-key-material
*   X_MATNR   = ' '
*   _SCOPE = '3'
*   _SYNCHRON = ' '
  EXCEPTIONS
    OTHERS = 1.

* Falls keine Treffer: Ausnahme auslösen
IF getmissedviews = 0.
  exit_return 7000 space space space space.
ENDIF.
end_method.

begin_method createviews changing container.
DATA: viewlistline LIKE sy-entry.    "Container-Element
DATA: it_moff LIKE moff OCCURS 50 WITH HEADER LINE.
DATA: o_moff TYPE swc_object.
DATA: BEGIN OF moff_key,
        maintenancestatus   LIKE moff-statm,
        createdon           LIKE moff-ersda,
        plant               LIKE moff-werks,
        salesorganization   LIKE moff-vkorg,
        distributionchannel LIKE moff-vtweg,
        purchorganization   LIKE moff-ekorg,
        valuationarea       LIKE moff-bwkey,
        material            LIKE moff-matnr,
        storagelocation     LIKE moff-lgort,
        whsenumber          LIKE moff-lgnum,
        storagetype         LIKE moff-lgtyp,
      END OF moff_key.

* Materialstamm lesen
SELECT SINGLE * FROM mara WHERE matnr = object-key-material.
* Customizing-Einstellungen lesen
SELECT SINGLE * FROM tcurm.

swc_get_element container 'ViewListLine' o_moff.

* Transaktion ermitteln und ggf. BDC für Org.Ebenen-Durchstieg erweitern
IF o_moff IS INITIAL.  "... wurde eine Vorauswahl getroffen?
*   nein: ... hier MOFF lesen und nacheinander aufrufen
  SELECT * FROM moff INTO TABLE it_moff
                     WHERE matnr = object-key-material.
  LOOP AT it_moff.
    PERFORM create_view USING it_moff.
  ENDLOOP.
ELSE.
*   ja: ... diesen View anlegen
  swc_get_object_key o_moff moff_key.
  SELECT SINGLE * FROM moff WHERE statm = moff_key-maintenancestatus
                            AND   ersda = moff_key-createdon
                            AND   werks = moff_key-plant
                            AND   vkorg = moff_key-salesorganization
                            AND   vtweg = moff_key-distributionchannel
                            AND   ekorg = moff_key-purchorganization
                            AND   bwkey = moff_key-valuationarea
                            AND   matnr = moff_key-material
                            AND   lgort = moff_key-storagelocation
                            AND   lgnum = moff_key-whsenumber
                            AND   lgtyp = moff_key-storagetype.
  IF sy-subrc = 0.
    PERFORM create_view USING moff.
  ELSE.
    MESSAGE ID 'M3' TYPE 'I' NUMBER 307.
  ENDIF.
ENDIF.
end_method.

FORM create_view USING moff STRUCTURE moff.
  SET PARAMETER ID 'MAT' FIELD object-key-material.
*   Verfahren aus MM03oF00/material_pflegen
  SET PARAMETER ID 'WRK' FIELD moff-werks.
  SET PARAMETER ID 'VKO' FIELD moff-vkorg.
  IF moff-statm = 'B' OR moff-statm = 'G'.
    CASE tcurm-bwkrs_cus.
      WHEN '3'.  "bewbukrs.
        SET PARAMETER ID 'BUK' FIELD moff-bwkey.
      WHEN '1'.  "bewwerks.
        SET PARAMETER ID 'WRK' FIELD moff-bwkey.
      WHEN OTHERS.
        SET PARAMETER ID 'BWK' FIELD moff-bwkey.
    ENDCASE.
  ENDIF.
  SET PARAMETER ID 'LAG' FIELD moff-lgort.
  SET PARAMETER ID 'LGN' FIELD moff-lgnum.
  SET PARAMETER ID 'MTA' FIELD moff-mtart.
  SET PARAMETER ID 'MTP' FIELD moff-mbrsh.
  SET PARAMETER ID 'VTW' FIELD moff-vtweg.
  SET PARAMETER ID 'BWT' FIELD ' '.
  SET PARAMETER ID 'LGT' FIELD ' '.

  SET PARAMETER ID 'MXX' FIELD moff-statm.    "Sicht-Popup übergehen
  SET PARAMETER ID 'MM5' FIELD ' '.           "Org-Popup übergehen
  SET PARAMETER ID 'MM6' FIELD ' '.           "Mat.VB durchlaufen-Flag

  CALL TRANSACTION 'MM01' AND SKIP FIRST SCREEN.

ENDFORM.


begin_method savedata changing container.
DATA:
  headdata             LIKE bapimathead,
  clientdata           LIKE bapi_mara,
  clientdatax          LIKE bapi_marax,
  plantdata            LIKE bapi_marc,
  plantdatax           LIKE bapi_marcx,
  forecastparameters   LIKE bapi_mpop,
  forecastparametersx  LIKE bapi_mpopx,
  planningdata         LIKE bapi_mpgd,
  planningdatax        LIKE bapi_mpgdx,
  storagelocationdata  LIKE bapi_mard,
  storagelocationdatax LIKE bapi_mardx,
  valuationdata        LIKE bapi_mbew,
  valuationdatax       LIKE bapi_mbewx,
  warehousenumberdata  LIKE bapi_mlgn,
  warehousenumberdatax LIKE bapi_mlgnx,
  salesdata            LIKE bapi_mvke,
  salesdatax           LIKE bapi_mvkex,
  storagetypedata      LIKE bapi_mlgt,
  storagetypedatax     LIKE bapi_mlgtx,
  return               LIKE bapiret2,
  materialdescription  LIKE bapi_makt OCCURS 0,
  unitsofmeasure       LIKE bapi_marm OCCURS 0,
  unitsofmeasurex      LIKE bapi_marmx OCCURS 0,
  internationalartnos  LIKE bapi_mean OCCURS 0,
  materiallongtext     LIKE bapi_mltx OCCURS 0,
  taxclassifications   LIKE bapi_mlan OCCURS 0,
  returnmessages       LIKE matreturn2 OCCURS 0,
  prtdata              LIKE bapi_mfhm OCCURS 0,
  prtdatax             LIKE bapi_mfhmx OCCURS 0,
  extensionin          LIKE bapiparex OCCURS 0,
  extensioninx         LIKE bapiparexx OCCURS 0
*  clientdatacwm        LIKE /cwm/bapi_mara,
*  clientdatacwmx       LIKE /cwm/bapi_marax
  .
swc_get_element container 'HeadData' headdata.
swc_get_element container 'ClientData' clientdata.
swc_get_element container 'ClientDatax' clientdatax.
swc_get_element container 'PlantData' plantdata.
swc_get_element container 'PlantDatax' plantdatax.
swc_get_element container 'ForecastParameters' forecastparameters.
swc_get_element container 'ForecastParametersx' forecastparametersx.
swc_get_element container 'PlanningData' planningdata.
swc_get_element container 'PlanningDatax' planningdatax.
swc_get_element container 'StorageLocationData' storagelocationdata.
swc_get_element container 'StorageLocationDatax' storagelocationdatax.
swc_get_element container 'ValuationData' valuationdata.
swc_get_element container 'ValuationDatax' valuationdatax.
swc_get_element container 'WarehouseNumberData' warehousenumberdata.
swc_get_element container 'WarehouseNumberDatax' warehousenumberdatax.
swc_get_element container 'SalesData' salesdata.
swc_get_element container 'SalesDatax' salesdatax.
swc_get_element container 'StorageTypeData' storagetypedata.
swc_get_element container 'StorageTypeDatax' storagetypedatax.
swc_get_table container 'MaterialDescription' materialdescription.
swc_get_table container 'UnitSofMeasure' unitsofmeasure.
swc_get_table container 'UnitSofMeasurex' unitsofmeasurex.
swc_get_table container 'InternationalArtNos' internationalartnos.
swc_get_table container 'MaterialLongtext' materiallongtext.
swc_get_table container 'TaxClassifications' taxclassifications.
swc_get_table container 'ReturnMessages' returnmessages.
swc_get_table container 'PRTData' prtdata.
swc_get_table container 'PRTDatax' prtdatax.
swc_get_table container 'ExtensionIn' extensionin.
swc_get_table container 'ExtensionInx' extensioninx.
*swc_get_element container 'ClientDataCWM' clientdatacwm.
*swc_get_element container 'ClientDataCWMx' clientdatacwmx.

CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
  EXPORTING
    storagelocationdatax = storagelocationdatax
    valuationdata        = valuationdata
    valuationdatax       = valuationdatax
    warehousenumberdata  = warehousenumberdata
    warehousenumberdatax = warehousenumberdatax
    salesdata            = salesdata
    salesdatax           = salesdatax
    storagetypedata      = storagetypedata
    storagetypedatax     = storagetypedatax
    storagelocationdata  = storagelocationdata
    headdata             = headdata
    clientdata           = clientdata
    clientdatax          = clientdatax
    plantdata            = plantdata
    plantdatax           = plantdatax
    forecastparameters   = forecastparameters
    forecastparametersx  = forecastparametersx
    planningdata         = planningdata
    planningdatax        = planningdatax
*    clientdatacwm        = clientdatacwm
*    clientdatacwmx       = clientdatacwmx
  IMPORTING
    return               = return
  TABLES
    returnmessages       = returnmessages
    prtdata              = prtdata
    prtdatax             = prtdatax
    extensionin          = extensionin
    extensioninx         = extensioninx
    taxclassifications   = taxclassifications
    materialdescription  = materialdescription
    unitsofmeasure       = unitsofmeasure
    unitsofmeasurex      = unitsofmeasurex
    internationalartnos  = internationalartnos
    materiallongtext     = materiallongtext
  EXCEPTIONS
    OTHERS               = 01.
CASE sy-subrc.
  WHEN 0.            " OK
  WHEN OTHERS.       " to be implemented
ENDCASE.
swc_set_element container 'Return' return.
swc_set_table container 'MaterialDescription' materialdescription.
swc_set_table container 'UnitSofMeasure' unitsofmeasure.
swc_set_table container 'UnitSofMeasurex' unitsofmeasurex.
swc_set_table container 'InternationalArtNos' internationalartnos.
swc_set_table container 'MaterialLongtext' materiallongtext.
swc_set_table container 'TaxClassifications' taxclassifications.
swc_set_table container 'ReturnMessages' returnmessages.
swc_set_table container 'PRTData' prtdata.
swc_set_table container 'PRTDatax' prtdatax.
swc_set_table container 'ExtensionIn' extensionin.
swc_set_table container 'ExtensionInx' extensioninx.
end_method.

begin_method getinternalnumber changing container.
DATA:
  materialtype    LIKE bapimatdoa-matl_type,
  industrysector  LIKE bapimatdoa-ind_sector,
  requirednumbers LIKE bapimatall-req_numbers,
  return          LIKE bapireturn1,
  materialnumber  LIKE bapimatinr OCCURS 0.
swc_get_element container 'MaterialType' materialtype.
swc_get_element container 'IndustrySector' industrysector.
IF sy-subrc <> 0.
  MOVE space TO industrysector.
ENDIF.
swc_get_element container 'RequiredNumbers' requirednumbers.
IF sy-subrc <> 0.
  MOVE 1 TO requirednumbers.
ENDIF.
swc_get_table container 'MaterialNumber' materialnumber.
CALL FUNCTION 'BAPI_STDMATERIAL_GETINTNUMBER'
  EXPORTING
    required_numbers = requirednumbers
    industry_sector  = industrysector
    material_type    = materialtype
  IMPORTING
    return           = return
  TABLES
    material_number  = materialnumber
  EXCEPTIONS
    OTHERS           = 01.
CASE sy-subrc.
  WHEN 0.            " OK
  WHEN OTHERS.       " to be implemented
ENDCASE.
swc_set_element container 'Return' return.
swc_set_table container 'MaterialNumber' materialnumber.
end_method.

begin_method savereplica changing container.
DATA:
  noappllog            LIKE bapie1global_data-no_appl_log,
  nochangedoc          LIKE bapie1global_data-no_change_doc,
  testrun              LIKE bapie1global_data-testrun,
  inpfldcheck          LIKE bapie1global_data-inp_fld_check,
  return               LIKE bapiret2,
  headdata             LIKE bapie1matheader OCCURS 0,
  clientdata           LIKE bapie1mara OCCURS 0,
  clientdatax          LIKE bapie1marax OCCURS 0,
  plantdata            LIKE bapie1marc OCCURS 0,
  plantdatax           LIKE bapie1marcx OCCURS 0,
  forecastparameters   LIKE bapie1mpop OCCURS 0,
  forecastparametersx  LIKE bapie1mpopx OCCURS 0,
  planningdata         LIKE bapie1mpgd OCCURS 0,
  planningdatax        LIKE bapie1mpgdx OCCURS 0,
  storagelocationdata  LIKE bapie1mard OCCURS 0,
  storagelocationdatax LIKE bapie1mardx OCCURS 0,
  valuationdata        LIKE bapie1mbew OCCURS 0,
  valuationdatax       LIKE bapie1mbewx OCCURS 0,
  warehousenumberdata  LIKE bapie1mlgn OCCURS 0,
  warehousenumberdatax LIKE bapie1mlgnx OCCURS 0,
  salesdata            LIKE bapie1mvke OCCURS 0,
  salesdatax           LIKE bapie1mvkex OCCURS 0,
  storagetypedata      LIKE bapie1mlgt OCCURS 0,
  storagetypedatax     LIKE bapie1mlgtx OCCURS 0,
  materialdescription  LIKE bapie1makt OCCURS 0,
  unitsofmeasure       LIKE bapie1marm OCCURS 0,
  unitsofmeasurex      LIKE bapie1marmx OCCURS 0,
  internationalartnos  LIKE bapie1mean OCCURS 0,
  materiallongtext     LIKE bapie1mltx OCCURS 0,
  taxclassifications   LIKE bapie1mlan OCCURS 0,
  prtdata              LIKE bapie1mfhm OCCURS 0,
  prtdatax             LIKE bapie1mfhmx OCCURS 0,
  extensionin          LIKE bapie1parex OCCURS 0,
  extensioninx         LIKE bapie1parexx OCCURS 0,
  forecastvalues       LIKE bapie1mprw OCCURS 0,
  unplndconsumption    LIKE bapie1mveu OCCURS 0,
  totalconsumption     LIKE bapie1mveg OCCURS 0,
  returnmessages       LIKE bapie1ret2 OCCURS 0.
*  clientdatacwmx       LIKE /cwm/bapie1marax OCCURS 0,
*  clientdatacwm        LIKE /cwm/bapie1mara OCCURS 0.

swc_get_element container 'NoApplLog' noappllog.
swc_get_element container 'NoChangeDoc' nochangedoc.
swc_get_element container 'TestRun' testrun.
swc_get_element container 'InpFldCheck' inpfldcheck.
swc_get_table container 'HeadData' headdata.
swc_get_table container 'ClientData' clientdata.
swc_get_table container 'ClientDatax' clientdatax.
swc_get_table container 'PlantData' plantdata.
swc_get_table container 'PlantDatax' plantdatax.
swc_get_table container 'ForeCastParameters' forecastparameters.
swc_get_table container 'ForeCastParametersx' forecastparametersx.
swc_get_table container 'PlanningData' planningdata.
swc_get_table container 'Planningdatax' planningdatax.
swc_get_table container 'Storagelocationdata' storagelocationdata.
swc_get_table container 'Storagelocationdatax' storagelocationdatax.
swc_get_table container 'Valuationdata' valuationdata.
swc_get_table container 'Valuationdatax' valuationdatax.
swc_get_table container 'Warehousenumberdata' warehousenumberdata.
swc_get_table container 'Warehousenumberdatax' warehousenumberdatax.
swc_get_table container 'Salesdata' salesdata.
swc_get_table container 'Salesdatax' salesdatax.
swc_get_table container 'Storagetypedata' storagetypedata.
swc_get_table container 'Storagetypedatax' storagetypedatax.
swc_get_table container 'Materialdescription' materialdescription.
swc_get_table container 'Unitsofmeasure' unitsofmeasure.
swc_get_table container 'Unitsofmeasurex' unitsofmeasurex.
swc_get_table container 'Internationalartnos' internationalartnos.
swc_get_table container 'Materiallongtext' materiallongtext.
swc_get_table container 'Taxclassifications' taxclassifications.
swc_get_table container 'Prtdata' prtdata.
swc_get_table container 'Prtdatax' prtdatax.
swc_get_table container 'Extensionin' extensionin.
swc_get_table container 'Extensioninx' extensioninx.
swc_get_table container 'Forecastvalues' forecastvalues.
swc_get_table container 'Unplndconsumption' unplndconsumption.
swc_get_table container 'Totalconsumption' totalconsumption.
swc_get_table container 'Returnmessages' returnmessages.
*swc_get_table container 'ClientDataCWM' clientdatacwm.
*swc_get_table container 'ClientDataCWMx' clientdatacwmx.

CALL FUNCTION 'BAPI_MATERIAL_SAVEREPLICA'
  EXPORTING
    noappllog            = noappllog
    nochangedoc          = nochangedoc
    testrun              = testrun
    inpfldcheck          = inpfldcheck
  IMPORTING
    return               = return
  TABLES
    taxclassifications   = taxclassifications
    materiallongtext     = materiallongtext
    internationalartnos  = internationalartnos
    unitsofmeasurex      = unitsofmeasurex
    unitsofmeasure       = unitsofmeasure
    materialdescription  = materialdescription
    storagetypedatax     = storagetypedatax
    storagetypedata      = storagetypedata
    returnmessages       = returnmessages
    totalconsumption     = totalconsumption
    unplndconsumption    = unplndconsumption
    forecastvalues       = forecastvalues
    extensioninx         = extensioninx
    extensionin          = extensionin
    prtdatax             = prtdatax
    prtdata              = prtdata
    salesdatax           = salesdatax
    planningdata         = planningdata
    forecastparametersx  = forecastparametersx
    forecastparameters   = forecastparameters
    plantdatax           = plantdatax
    plantdata            = plantdata
    clientdatax          = clientdatax
    clientdata           = clientdata
    headdata             = headdata
    salesdata            = salesdata
    warehousenumberdatax = warehousenumberdatax
    warehousenumberdata  = warehousenumberdata
    valuationdatax       = valuationdatax
    valuationdata        = valuationdata
    storagelocationdatax = storagelocationdatax
    storagelocationdata  = storagelocationdata
    planningdatax        = planningdatax
*    clientdatacwm        = clientdatacwm
*    clientdatacwmx       = clientdatacwmx
  EXCEPTIONS
    OTHERS               = 01.
CASE sy-subrc.
  WHEN 0.            " OK
  WHEN OTHERS.       " to be implemented
ENDCASE.
swc_set_element container 'Return' return.
swc_set_table container 'HeadData' headdata.
swc_set_table container 'ClientData' clientdata.
swc_set_table container 'ClientDatax' clientdatax.
*swc_set_table container 'ClientDataCWM' clientdatacwm.
*swc_set_table container 'ClientDataCWMx' clientdatacwmx.
swc_set_table container 'PlantData' plantdata.
swc_set_table container 'PlantDatax' plantdatax.
swc_set_table container 'ForeCastParameters' forecastparameters.
swc_set_table container 'ForeCastParametersx' forecastparametersx.
swc_set_table container 'PlanningData' planningdata.
swc_set_table container 'Planningdatax' planningdatax.
swc_set_table container 'Storagelocationdata' storagelocationdata.
swc_set_table container 'Storagelocationdatax' storagelocationdatax.
swc_set_table container 'Valuationdata' valuationdata.
swc_set_table container 'Valuationdatax' valuationdatax.
swc_set_table container 'Warehousenumberdata' warehousenumberdata.
swc_set_table container 'Warehousenumberdatax' warehousenumberdatax.
swc_set_table container 'Salesdata' salesdata.
swc_set_table container 'Salesdatax' salesdatax.
swc_set_table container 'Storagetypedata' storagetypedata.
swc_set_table container 'Storagetypedatax' storagetypedatax.
swc_set_table container 'Materialdescription' materialdescription.
swc_set_table container 'Unitsofmeasure' unitsofmeasure.
swc_set_table container 'Unitsofmeasurex' unitsofmeasurex.
swc_set_table container 'Internationalartnos' internationalartnos.
swc_set_table container 'Materiallongtext' materiallongtext.
swc_set_table container 'Taxclassifications' taxclassifications.
swc_set_table container 'Prtdata' prtdata.
swc_set_table container 'Prtdatax' prtdatax.
swc_set_table container 'Extensionin' extensionin.
swc_set_table container 'Extensioninx' extensioninx.
swc_set_table container 'Forecastvalues' forecastvalues.
swc_set_table container 'Unplndconsumption' unplndconsumption.
swc_set_table container 'Totalconsumption' totalconsumption.
swc_set_table container 'Returnmessages' returnmessages.
end_method.


begin_method create changing container.
DATA:
  return           LIKE bapiret1,
  newmaterial      TYPE bapimatall-material,
*  newmaterial_long TYPE bapimatall-material_long,
  newmaterialevg   LIKE bapimgvmatnr,
  materialevg      LIKE bapimgvmatnr.
swc_get_element container 'NewMaterial' newmaterial.
*swc_get_element container 'NewMaterialLong' newmaterial_long.
IF sy-subrc <> 0.
  MOVE space TO newmaterial.
ENDIF.
swc_get_element container 'newmaterialEVG' newmaterialevg.
CALL FUNCTION 'BAPI_STANDARDMATERIAL_CREATE'
  EXPORTING
    newmaterial      = newmaterial
*    newmaterial_long = newmaterial_long
    newmaterial_evg  = newmaterialevg
  IMPORTING
    material_long    = object-key-material
    newmaterial      = newmaterial
*    newmaterial_long = newmaterial_long
    return           = return
    material_evg     = materialevg
    newmaterial_evg  = newmaterialevg
  EXCEPTIONS
    OTHERS           = 01.
CASE sy-subrc.
  WHEN 0.            " OK
  WHEN OTHERS.       " to be implemented
ENDCASE.
swc_set_element container 'Return' return.
swc_set_element container 'NewMaterial' newmaterial.
*swc_set_element container 'NewMaterialLong' newmaterial_long.
swc_set_element container 'newmaterialEVG' newmaterialevg.
swc_set_element container 'materialEVG' materialevg.
end_method.

begin_method materialgetall changing container.
DATA:
  companycode                TYPE bapi0002_1-comp_code,
  valuationarea              TYPE bapi_mbew_ga-val_area,
  valuationtype              TYPE bapi_mbew_ga-val_type,
  plant                      TYPE bapi_marc_ga-plant,
  storagelocation            TYPE bapi_mard_ga-stge_loc,
  salesorganisation          TYPE bapi_mvke_ga-sales_org,
  distributionchannel        TYPE bapi_mvke_ga-distr_chan,
  warehousenumber            TYPE bapi_mlgn_ga-whse_no,
  storagetype                TYPE bapi_mlgt_ga-stge_type,
  lifovaluationlevel         TYPE bapi_myms_ga-lifo_valuation_level,
  clientdata                 LIKE bapi_mara_ga,
  plantdata                  LIKE bapi_marc_ga,
  forecastparameters         LIKE bapi_mpop_ga,
  planningdata               LIKE bapi_mpgd_ga,
  storagelocationdata        LIKE bapi_mard_ga,
  valuationdata              LIKE bapi_mbew_ga,
  warehousenumberdata        LIKE bapi_mlgn_ga,
  salesdata                  LIKE bapi_mvke_ga,
  storagetypedata            LIKE bapi_mlgt_ga,
  productionresourcetooldata LIKE bapi_mfhm_ga,
  lifovaluationdata          LIKE bapi_myms_ga,
  materialdescription        LIKE bapi_makt_ga OCCURS 0,
  unitsofmeasure             LIKE bapi_marm_ga OCCURS 0,
  internationarticlenumbers  LIKE bapi_mean_ga OCCURS 0,
  materialtext               LIKE bapi_mltx_ga OCCURS 0,
  taxclassifications         LIKE bapi_mlan_ga OCCURS 0,
  extensionout               LIKE bapiparex OCCURS 0,
  return                     LIKE bapireturn OCCURS 0,
  material                   TYPE bapi_mara_ga-material,
  materialevg                LIKE bapimgvmatnr,
  kzrfb_all                  LIKE mtcom-kzrfb.
swc_get_element container 'CompanyCode' companycode.
swc_get_element container 'ValuationArea' valuationarea.
swc_get_element container 'ValuationType' valuationtype.
swc_get_element container 'Plant' plant.
swc_get_element container 'StorageLocation' storagelocation.
swc_get_element container 'SalesOrganisation' salesorganisation.
swc_get_element container 'DistributionChannel' distributionchannel.
swc_get_element container 'WarehouseNumber' warehousenumber.
swc_get_element container 'StorageType' storagetype.
swc_get_element container 'LifoValuationLevel' lifovaluationlevel.
swc_get_table container 'Taxclassifications' taxclassifications.
swc_get_table container 'Extensionout' extensionout.
swc_get_table container 'Return' return.
swc_get_element container 'Material' material.
swc_get_element container 'materialEVG' materialevg.
swc_get_element container 'KZRFB_ALL' kzrfb_all.
CALL FUNCTION 'BAPI_MATERIAL_GETALL'
  EXPORTING
    kzrfb_all                  = kzrfb_all
    material_evg               = materialevg
    lifovaluationlevel         = lifovaluationlevel
    storagetype                = storagetype
    warehousenumber            = warehousenumber
    distributionchannel        = distributionchannel
    salesorganisation          = salesorganisation
    storagelocation            = storagelocation
    plant                      = plant
    valuationtype              = valuationtype
    valuationarea              = valuationarea
    companycode                = companycode
    material                   = material
    material_long              = object-key-material
  IMPORTING
    lifovaluationdata          = lifovaluationdata
    productionresourcetooldata = productionresourcetooldata
    storagetypedata            = storagetypedata
    salesdata                  = salesdata
    warehousenumberdata        = warehousenumberdata
    valuationdata              = valuationdata
    storagelocationdata        = storagelocationdata
    planningdata               = planningdata
    forecastparameters         = forecastparameters
    plantdata                  = plantdata
    clientdata                 = clientdata
  TABLES
    return                     = return
    extensionout               = extensionout
    taxclassifications         = taxclassifications
    materialtext               = materialtext
    internationarticlenumbers  = internationarticlenumbers
    unitsofmeasure             = unitsofmeasure
    materialdescription        = materialdescription
  EXCEPTIONS
    OTHERS                     = 01.
CASE sy-subrc.
  WHEN 0.            " OK
  WHEN OTHERS.       " to be implemented
ENDCASE.
swc_set_element container 'ClientData' clientdata.
swc_set_element container 'PlantData' plantdata.
swc_set_element container 'ForecastParameters' forecastparameters.
swc_set_element container 'PlanningData' planningdata.
swc_set_element container 'StorageLocationData' storagelocationdata.
swc_set_element container 'ValuationData' valuationdata.
swc_set_element container 'WarehouseNumberData' warehousenumberdata.
swc_set_element container 'SalesData' salesdata.
swc_set_element container 'StorageTypeData' storagetypedata.
swc_set_element container 'ProductionResourceToolData'
     productionresourcetooldata.
swc_set_element container 'LifoValuationData' lifovaluationdata.
swc_set_table container 'MaterialDescription' materialdescription.
swc_set_table container 'UnitsOfMeasure' unitsofmeasure.
swc_set_table container 'InternationArticleNumbers'
     internationarticlenumbers.
swc_set_table container 'MaterialText' materialtext.
swc_set_table container 'Taxclassifications' taxclassifications.
swc_set_table container 'Extensionout' extensionout.
swc_set_table container 'Return' return.
end_method.

begin_method confirm changing container.
end_method.
