*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZONTA_DOMAINS...................................*
DATA:  BEGIN OF STATUS_ZONTA_DOMAINS                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZONTA_DOMAINS                 .
CONTROLS: TCTRL_ZONTA_DOMAINS
            TYPE TABLEVIEW USING SCREEN '9001'.
*...processing: ZONTA_OBJ_OC....................................*
DATA:  BEGIN OF STATUS_ZONTA_OBJ_OC                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZONTA_OBJ_OC                  .
CONTROLS: TCTRL_ZONTA_OBJ_OC
            TYPE TABLEVIEW USING SCREEN '9002'.
*...processing: ZONTA_OC_ANYALIA................................*
DATA:  BEGIN OF STATUS_ZONTA_OC_ANYALIA              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZONTA_OC_ANYALIA              .
CONTROLS: TCTRL_ZONTA_OC_ANYALIA
            TYPE TABLEVIEW USING SCREEN '9009'.
*...processing: ZONTA_OC_AUTH...................................*
DATA:  BEGIN OF STATUS_ZONTA_OC_AUTH                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZONTA_OC_AUTH                 .
CONTROLS: TCTRL_ZONTA_OC_AUTH
            TYPE TABLEVIEW USING SCREEN '9023'.
*...processing: ZONTA_OC_COLUMNS................................*
DATA:  BEGIN OF STATUS_ZONTA_OC_COLUMNS              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZONTA_OC_COLUMNS              .
CONTROLS: TCTRL_ZONTA_OC_COLUMNS
            TYPE TABLEVIEW USING SCREEN '9005'.
*...processing: ZONTA_OC_COL_ALL................................*
DATA:  BEGIN OF STATUS_ZONTA_OC_COL_ALL              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZONTA_OC_COL_ALL              .
CONTROLS: TCTRL_ZONTA_OC_COL_ALL
            TYPE TABLEVIEW USING SCREEN '9021'.
*...processing: ZONTA_OC_CONV...................................*
DATA:  BEGIN OF STATUS_ZONTA_OC_CONV                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZONTA_OC_CONV                 .
CONTROLS: TCTRL_ZONTA_OC_CONV
            TYPE TABLEVIEW USING SCREEN '9025'.
*...processing: ZONTA_OC_DDIC...................................*
DATA:  BEGIN OF STATUS_ZONTA_OC_DDIC                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZONTA_OC_DDIC                 .
CONTROLS: TCTRL_ZONTA_OC_DDIC
            TYPE TABLEVIEW USING SCREEN '9024'.
*...processing: ZONTA_OC_ENDP...................................*
DATA:  BEGIN OF STATUS_ZONTA_OC_ENDP                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZONTA_OC_ENDP                 .
CONTROLS: TCTRL_ZONTA_OC_ENDP
            TYPE TABLEVIEW USING SCREEN '9020'.
*...processing: ZONTA_OC_EVENTS.................................*
DATA:  BEGIN OF STATUS_ZONTA_OC_EVENTS               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZONTA_OC_EVENTS               .
CONTROLS: TCTRL_ZONTA_OC_EVENTS
            TYPE TABLEVIEW USING SCREEN '9008'.
*...processing: ZONTA_OC_EVT_CON................................*
DATA:  BEGIN OF STATUS_ZONTA_OC_EVT_CON              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZONTA_OC_EVT_CON              .
CONTROLS: TCTRL_ZONTA_OC_EVT_CON
            TYPE TABLEVIEW USING SCREEN '9022'.
*...processing: ZONTA_OC_PARAM..................................*
DATA:  BEGIN OF STATUS_ZONTA_OC_PARAM                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZONTA_OC_PARAM                .
CONTROLS: TCTRL_ZONTA_OC_PARAM
            TYPE TABLEVIEW USING SCREEN '9004'.
*...processing: ZONTA_OC_RESERV.................................*
DATA:  BEGIN OF STATUS_ZONTA_OC_RESERV               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZONTA_OC_RESERV               .
CONTROLS: TCTRL_ZONTA_OC_RESERV
            TYPE TABLEVIEW USING SCREEN '9006'.
*...processing: ZONTA_OC_VARDYN.................................*
DATA:  BEGIN OF STATUS_ZONTA_OC_VARDYN               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZONTA_OC_VARDYN               .
CONTROLS: TCTRL_ZONTA_OC_VARDYN
            TYPE TABLEVIEW USING SCREEN '9026'.
*...processing: ZONTA_OC_VARIANT................................*
DATA:  BEGIN OF STATUS_ZONTA_OC_VARIANT              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZONTA_OC_VARIANT              .
CONTROLS: TCTRL_ZONTA_OC_VARIANT
            TYPE TABLEVIEW USING SCREEN '9027'.
*...processing: ZONTA_RELATIONS.................................*
DATA:  BEGIN OF STATUS_ZONTA_RELATIONS               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZONTA_RELATIONS               .
CONTROLS: TCTRL_ZONTA_RELATIONS
            TYPE TABLEVIEW USING SCREEN '9003'.
*.........table declarations:.................................*
TABLES: *ZONTA_DOMAINS                 .
TABLES: *ZONTA_OBJ_OC                  .
TABLES: *ZONTA_OC_ANYALIA              .
TABLES: *ZONTA_OC_AUTH                 .
TABLES: *ZONTA_OC_COLUMNS              .
TABLES: *ZONTA_OC_COL_ALL              .
TABLES: *ZONTA_OC_CONV                 .
TABLES: *ZONTA_OC_DDIC                 .
TABLES: *ZONTA_OC_ENDP                 .
TABLES: *ZONTA_OC_EVENTS               .
TABLES: *ZONTA_OC_EVT_CON              .
TABLES: *ZONTA_OC_PARAM                .
TABLES: *ZONTA_OC_RESERV               .
TABLES: *ZONTA_OC_VARDYN               .
TABLES: *ZONTA_OC_VARIANT              .
TABLES: *ZONTA_RELATIONS               .
TABLES: ZONTA_DOMAINS                  .
TABLES: ZONTA_OBJ_OC                   .
TABLES: ZONTA_OC_ANYALIA               .
TABLES: ZONTA_OC_AUTH                  .
TABLES: ZONTA_OC_COLUMNS               .
TABLES: ZONTA_OC_COL_ALL               .
TABLES: ZONTA_OC_CONV                  .
TABLES: ZONTA_OC_DDIC                  .
TABLES: ZONTA_OC_ENDP                  .
TABLES: ZONTA_OC_EVENTS                .
TABLES: ZONTA_OC_EVT_CON               .
TABLES: ZONTA_OC_PARAM                 .
TABLES: ZONTA_OC_RESERV                .
TABLES: ZONTA_OC_VARDYN                .
TABLES: ZONTA_OC_VARIANT               .
TABLES: ZONTA_RELATIONS                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
