*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZONTA_OC_FETCH_R................................*
DATA:  BEGIN OF STATUS_ZONTA_OC_FETCH_R              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZONTA_OC_FETCH_R              .
CONTROLS: TCTRL_ZONTA_OC_FETCH_R
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZONTA_OC_FETCH_R              .
TABLES: ZONTA_OC_FETCH_R               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
