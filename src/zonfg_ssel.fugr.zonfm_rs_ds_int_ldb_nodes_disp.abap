FUNCTION ZONFM_RS_DS_INT_LDB_NODES_DISP.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(P_LDB) LIKE  RSLDB-LDB
*"  EXCEPTIONS
*"      SAPDB_CANNOT_BE_GENERATED
*"      LDB_NOT_FOUND
*"      NO_FREE_SELECTIONS_NODES
*"--------------------------------------------------------------------

  DATA: L_NODES LIKE RSDFSNODES OCCURS 0 WITH HEADER LINE.
  data: l_fieldcat type SLIS_T_FIELDCAT_ALV ,
         wa_fieldcat type SLIS_FIELDCAT_ALV ,
         l_title type LVC_TITLE.


* Feldbeschreibung der Tabellentabelle (RS_VALUES_BOX)
  DATA BEGIN OF L_FIDESC OCCURS 5.
    INCLUDE STRUCTURE RSVBFIDESC.
  DATA END   OF L_FIDESC.

  CALL FUNCTION 'ZONFM_RS_DS_INT_LDB_NODES'
       EXPORTING
            P_LDB                     = P_LDB
            P_WITH_TEXT               = 'X'
       TABLES
            P_NODES                   = L_NODES
       EXCEPTIONS
            SAPDB_CANNOT_BE_GENERATED = 01
            LDB_NOT_FOUND             = 02.

  CASE SY-SUBRC.
    WHEN 0.
    WHEN 1.
      RAISE SAPDB_CANNOT_BE_GENERATED.
    WHEN 2.
      RAISE LDB_NOT_FOUND.
  ENDCASE.

  IF L_NODES[] IS INITIAL.
    RAISE NO_FREE_SELECTIONS_NODES.
  ENDIF.
*
*  MOVE 'L_NODES-LDBNODE'       TO L_FIDESC-FIELDNAME.
*  MOVE 'Node'(104)             TO L_FIDESC-COL_HEAD.
*  MOVE 1                       TO L_FIDESC-FIELDNUM.
*  MOVE 'X'                     TO L_FIDESC-DISPLAY.
*  MOVE 'X'                     TO L_FIDESC-KEY_FIELD.
*  APPEND L_FIDESC.
*
*  MOVE 'L_NODES-NODETEXT'      TO L_FIDESC-FIELDNAME.
*  MOVE 'Description'(111)      TO L_FIDESC-COL_HEAD.
*  MOVE 2                       TO L_FIDESC-FIELDNUM.
*  MOVE 'X'                     TO L_FIDESC-DISPLAY.
*  MOVE SPACE                   TO L_FIDESC-KEY_FIELD.
*  APPEND L_FIDESC.
*
*  CALL FUNCTION 'RS_VALUES_BOX'
*       EXPORTING
*            COLUMN_HEADING        = 'X'
*  "         CURSOR_FIELD          = 1
*  "         CURSOR_LINE           = 1
*            LEFT_UPPER_COL        = 4
*            LEFT_UPPER_ROW        = 4
*            TITLE                 = 'Nodes for free selections'(110)
*            JUST_DISPLAY          = 'X'
*       TABLES
*            FIELD_DESC            = L_FIDESC
*            VALUE_TAB             = L_NODES
*       EXCEPTIONS
*            OTHERS                = 01.
* Grid erzeugen
* feldkatalog für ALV füllen

       wa_fieldcat-fieldname = 'LDBNODE' .
       wa_fieldcat-seltext_l =  wa_fieldcat-seltext_m =
         wa_fieldcat-seltext_s =  'Knoten'(108).
       wa_fieldcat-key = 'X'.
       wa_fieldcat-outputlen = 20.
       append wa_fieldcat to l_fieldcat.
       clear wa_fieldcat.

       wa_fieldcat-fieldname = 'NODETEXT' .
   wa_fieldcat-seltext_l = wa_fieldcat-seltext_m = 'Beschreibung'(111).
*         wa_fieldcat-seltext_s = 'Beschreibung'(111).
       wa_fieldcat-outputlen = 40.
       append wa_fieldcat to l_fieldcat.

       l_title = 'Nodes for free selections'(110)   .

       call function 'REUSE_ALV_GRID_DISPLAY'
          EXPORTING
                          I_GRID_TITLE                = l_title
                          IT_FIELDCAT                 = l_fieldcat
                          I_SCREEN_START_COLUMN       = 10
                          I_SCREEN_START_LINE         = 10
                          I_SCREEN_END_COLUMN         = 60
                          I_SCREEN_END_LINE           = 18
*                     IMPORTING
*                          E_EXIT_CAUSED_BY_CALLER     =
*                          ES_EXIT_CAUSED_BY_USER      =
                      tables
                           t_outtab                    =  l_nodes
*                     EXCEPTIONS
*                          PROGRAM_ERROR               = 1
*                          OTHERS                      = 2
                           .

ENDFUNCTION.
