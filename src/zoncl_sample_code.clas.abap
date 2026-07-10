class ZONCL_SAMPLE_CODE definition
  public
  final
  create public .

public section.

  interfaces ZONIF_CODE .
protected section.
private section.
ENDCLASS.



CLASS ZONCL_SAMPLE_CODE IMPLEMENTATION.


  METHOD zonif_code~send_data.
    TYPES: BEGIN OF ty_data,
             vbeln TYPE vbak-vbeln,
             matnr TYPE vbap-matnr,
           END OF ty_data.

    DATA: lo_send     TYPE REF TO zoncl_fetch_data_v2,
          lt_data     TYPE STANDARD TABLE OF ty_data,
          lt_fieldcat TYPE slis_t_fieldcat_alv,
          lt_where    TYPE rsds_where_tab.

    FIELD-SYMBOLS: <fs_fieldcat> TYPE LINE OF slis_t_fieldcat_alv.

*** Fill Structure Data Info as Catalog
    APPEND INITIAL LINE TO lt_fieldcat ASSIGNING <fs_fieldcat>.
    <fs_fieldcat>-fieldname      = 'VBELN'.
    <fs_fieldcat>-tabname        = 'VBAK'.
    <fs_fieldcat>-seltext_l      = 'Sales Document'.
    <fs_fieldcat>-col_pos        = 1.
    <fs_fieldcat>-key            = abap_true. " Mark as true to add field on Section Parameter
    <fs_fieldcat>-datatype       = 'CHAR'.
    <fs_fieldcat>-offset         = 6.
    <fs_fieldcat>-ddic_outputlen = 10.
    <fs_fieldcat>-inttype        = 'C'.
    <fs_fieldcat>-intlen         = 20.

    APPEND INITIAL LINE TO lt_fieldcat ASSIGNING <fs_fieldcat>.
    <fs_fieldcat>-fieldname      = 'MATNR'.
    <fs_fieldcat>-tabname        = 'VBAP'.
    <fs_fieldcat>-seltext_l      = 'Material'.
    <fs_fieldcat>-col_pos        = 2.
    <fs_fieldcat>-key            = abap_false.
    <fs_fieldcat>-datatype       = 'CHAR'.
    <fs_fieldcat>-offset         = 38.
    <fs_fieldcat>-ddic_outputlen = 18.
    <fs_fieldcat>-inttype        = 'C'.
    <fs_fieldcat>-intlen         = 36.

*** Fill Select Parameters and filters
    zonif_code~set_where_code(
       EXPORTING
         it_fieldcat = lt_fieldcat
       RECEIVING
         r_where     = lt_where ).

*** Implement your own query
    SELECT a~vbeln
           b~matnr
           INTO TABLE lt_data
           FROM vbak AS a
           INNER JOIN vbap AS b
           ON a~vbeln EQ b~vbeln
           WHERE (lt_where).


*** Send Data
    IF sy-subrc EQ 0.
      CREATE OBJECT lo_send.

      CALL METHOD lo_send->send_json_code
        EXPORTING
          it_data     = lt_data
          iv_tabname  = 'SALES_SAMPLE_DATA'
          iv_update   = abap_true
          it_fieldcat = lt_fieldcat
          iv_entity   = iv_entity
          iv_dest     = iv_dest
          iv_ent_data = iv_data.
    ENDIF.
  ENDMETHOD.


  METHOD zonif_code~set_where_code.
    DATA selid          TYPE rsdynsel-selid.
    DATA field_tab      TYPE TABLE OF rsdsfields.
    DATA field_tab_excl TYPE TABLE OF rsdsfields.
    DATA table_tab      TYPE TABLE OF rsdstabs.
    DATA cond_tab       TYPE rsds_twhere.
    DATA lv_title       TYPE sy-title.
    DATA: lv_join       TYPE string.
    DATA: ls_cond_tab TYPE LINE OF rsds_twhere,
          lv_lines    TYPE sy-tabix,
          lv_sequence TYPE string,
          lv_tabname  TYPE  ddobjname.
    DATA: lt_dfies_tab_cat TYPE STANDARD TABLE OF dfies,
          lt_fieldcat      TYPE slis_t_fieldcat_alv.

    FIELD-SYMBOLS: <fs_table_tab>      TYPE rsdstabs,
                   <fs_dfies_tab_cat>  TYPE dfies,
                   <fs_field_tab_excl> TYPE rsdsfields,
                   <fs_cond_tab>       TYPE LINE OF rsds_twhere,
                   <fs_where_tab>      TYPE LINE OF  rsds_where_tab,
                   <fs_where>          TYPE LINE OF rsds_where_tab,
                   <fs_where_tab_line> TYPE LINE OF rsds_where_tab,
                   <fs_filter>         TYPE zonta_oc_filters,
                   <fs_fieldcat>       TYPE LINE OF slis_t_fieldcat_alv.

    lt_fieldcat = it_fieldcat .

    DELETE lt_fieldcat WHERE key NE abap_true.

    SORT lt_fieldcat BY tabname.

    DELETE ADJACENT DUPLICATES FROM lt_fieldcat COMPARING tabname.

    LOOP AT lt_fieldcat ASSIGNING <fs_fieldcat> .

      APPEND INITIAL LINE TO table_tab ASSIGNING <fs_table_tab>.
      <fs_table_tab>-prim_tab = <fs_fieldcat>-tabname.

      lv_tabname = <fs_fieldcat>-tabname.

      CALL FUNCTION 'DDIF_FIELDINFO_GET'
        EXPORTING
          tabname        = lv_tabname
        TABLES
          dfies_tab      = lt_dfies_tab_cat
        EXCEPTIONS
          not_found      = 1
          internal_error = 2
          OTHERS         = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      LOOP AT lt_dfies_tab_cat ASSIGNING <fs_dfies_tab_cat>.

        READ TABLE lt_fieldcat    WITH KEY tabname    = <fs_dfies_tab_cat>-tabname
                                           fieldname  = <fs_dfies_tab_cat>-fieldname
                                       TRANSPORTING NO FIELDS.
        IF sy-subrc NE 0.
          APPEND INITIAL LINE TO field_tab_excl ASSIGNING <fs_field_tab_excl>.
          <fs_field_tab_excl>-tablename = <fs_dfies_tab_cat>-tabname.
          <fs_field_tab_excl>-fieldname = <fs_dfies_tab_cat>-fieldname.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    CALL FUNCTION 'FREE_SELECTIONS_INIT'
      EXPORTING
        kind                  = 'T'
      IMPORTING
        selection_id          = selid
      TABLES
        tables_tab            = table_tab
        tabfields_not_display = field_tab_excl
*       fields_not_selected   = field_tab_excl
      EXCEPTIONS
        OTHERS                = 4.
    IF sy-subrc <> 0.
      MESSAGE 'Error in initialization' TYPE 'I' DISPLAY LIKE 'E'.
      LEAVE PROGRAM.
    ENDIF.

    lv_title = 'SALES_SAMPLE_DATA'.

    CALL FUNCTION 'FREE_SELECTIONS_DIALOG'
      EXPORTING
        selection_id  = selid
        title         = lv_title
        as_window     = ' '
      IMPORTING
        where_clauses = cond_tab
      TABLES
        fields_tab    = field_tab
      EXCEPTIONS
        OTHERS        = 4.
    IF sy-subrc <> 0.
      MESSAGE 'No free selection created' TYPE 'I'.
      LEAVE PROGRAM.
    ENDIF.

    IF NOT cond_tab IS INITIAL.
      LOOP AT cond_tab ASSIGNING <fs_cond_tab>.
        LOOP AT <fs_cond_tab>-where_tab ASSIGNING <fs_where_tab>.
          SHIFT <fs_where_tab>-line LEFT DELETING LEADING space.
          APPEND INITIAL LINE TO r_where ASSIGNING <fs_where>.
          REPLACE '( ' WITH '( a~' INTO <fs_where_tab>-line.
          <fs_where>-line = <fs_where_tab>-line.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
