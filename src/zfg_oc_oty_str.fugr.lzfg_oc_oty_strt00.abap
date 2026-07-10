*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZONTA_OC_OTY_STR................................*
DATA:  BEGIN OF STATUS_ZONTA_OC_OTY_STR              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZONTA_OC_OTY_STR              .
CONTROLS: TCTRL_ZONTA_OC_OTY_STR
            TYPE TABLEVIEW USING SCREEN '9001'.
*.........table declarations:.................................*
TABLES: *ZONTA_OC_OTY_STR              .
TABLES: ZONTA_OC_OTY_STR               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
