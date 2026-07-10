*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZONTA_DATAPRODC.................................*
DATA:  BEGIN OF STATUS_ZONTA_DATAPRODC               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZONTA_DATAPRODC               .
CONTROLS: TCTRL_ZONTA_DATAPRODC
            TYPE TABLEVIEW USING SCREEN '9001'.
*.........table declarations:.................................*
TABLES: *ZONTA_DATAPRODC               .
TABLES: ZONTA_DATAPRODC                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
