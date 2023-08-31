class ZCL_SPT_REF_DDIC definition
  public
  create public .

*"* public components of class ZCL_SPT_REF_DDIC
*"* do not include other source files here!!!
public section.
  type-pools ABAP .

  methods CONSTRUCTOR
    importing
      !IV_OBJECT type ANY
      !IV_TYPE type TROBJTYPE
      !IV_LEVEL type I optional
      !IV_ONLY_CUSTOMER_OBJ type SAP_BOOL default 'X'
    exceptions
      ERROR_OBJECT
      TYPE_OBJECT_NOT_VALID .
  methods SEARCH_REFS
    exporting
      !ET_REFS type zif_spt_ref_data=>TT_LIST_REFS .
protected section.
*"* protected components of class ZCL_SPT_REF_DDIC
*"* do not include other source files here!!!

  data mv_object type DDOBJNAME .
  data mv_type type TROBJTYPE .
  data mv_level type I .
  data mt_list_refs type zif_spt_ref_data=>tt_list_refs .
  data mv_only_customer_obj type SAP_BOOL .

  methods GET_REF_DOMAIN .
  methods GET_REF_ROLLNAME .
  methods GET_REF_SEARCH_HELP .
  methods GET_REF_TABLE_TYPE .
  methods GET_REF_VIEW .
  methods GET_ALL_REFS .
  methods GET_REF_TABLE .
private section.
*"* private components of class ZCL_SPT_REF_DDIC
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_SPT_REF_DDIC IMPLEMENTATION.


method CONSTRUCTOR.

  mv_object = iv_object.
  mv_type = iv_type.
  mv_only_customer_obj = iv_only_customer_obj.

  CASE iv_type.
    WHEN zif_spt_ref_data=>cs_types-table
           OR zif_spt_ref_data=>cs_types-struc
           OR zif_spt_ref_data=>cs_types-dataelem
           OR zif_spt_ref_data=>cs_types-domain
           OR zif_spt_ref_data=>cs_types-tabltype
           OR zif_spt_ref_data=>cs_types-seahlp
           OR zif_spt_ref_data=>cs_types-view.
    WHEN OTHERS.
      RAISE type_object_not_valid.
  ENDCASE.

* El parametro I_LEVEL sirve para llamadas recursivas para encontrar referencias
* del objeto. Este nivel se guardara en la tabla de referencias con formato listado.
  IF iv_level IS SUPPLIED.
    mv_level = iv_level.
  ELSE.
    mv_level = 1.
  ENDIF.


endmethod.


method GET_ALL_REFS.

  CASE mv_type.
    WHEN zif_spt_ref_data=>cs_types-table OR
         zif_spt_ref_data=>cs_types-struc.
      get_ref_table( ).
    WHEN zif_spt_ref_data=>cs_types-view.
      get_ref_view( ).
    WHEN zif_spt_ref_data=>cs_types-dataelem.
      get_ref_rollname( ).
    WHEN zif_spt_ref_data=>cs_types-domain.
      get_ref_domain( ).
    WHEN zif_spt_ref_data=>cs_types-tabltype.
      get_ref_table_type( ).
    WHEN zif_spt_ref_data=>cs_types-seahlp.
      get_ref_search_help( ).
  ENDCASE.

  IF mv_only_customer_obj = abap_true.
    DELETE mt_list_refs WHERE object_ref NP 'Z*' AND object_ref NP 'Y*'.
  ENDIF.

* Elimino duplicados
  SORT mt_list_refs BY type_ref object_ref fullname_ref.
  DELETE ADJACENT DUPLICATES FROM mt_list_refs
         COMPARING type_ref object_ref fullname_ref.

* Elimino aquellos objetos cuyo referencia sea la misma que la buscada. Por ejemplo:
* la tabla de la verificacion de una tabla es la misma que la tabla a buscar, esto se usa
* para tablas de textos.
  DELETE mt_list_refs WHERE type_ref = mv_type
                            AND object_ref = mv_object.


endmethod.


method GET_REF_DOMAIN.

  DATA ls_dd01v TYPE dd01v.
  DATA ls_list_refs TYPE LINE OF zif_spt_ref_data=>tt_list_refs.
  DATA ld_tipo TYPE ddtypes-typename.

  CALL FUNCTION 'DDIF_DOMA_GET'
    EXPORTING
      name          = mv_object
    IMPORTING
      dd01v_wa      = ls_dd01v
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.

  IF sy-subrc = 0.

* Valores base
    ls_list_refs-level = mv_level.
    ls_list_refs-type = mv_type.
    ls_list_refs-object = mv_object.

* Tabla de verificacion
    IF ls_dd01v-entitytab IS NOT INITIAL.
      ls_list_refs-object_ref = ls_dd01v-entitytab.
      ls_list_refs-type_ref = zif_spt_ref_data=>cs_types-table.
      APPEND ls_list_refs TO mt_list_refs.
    ENDIF.

  ENDIF.


endmethod.


method GET_REF_ROLLNAME.

  DATA ls_dd04v TYPE dd04v.
  DATA ls_list_refs TYPE LINE OF zif_spt_ref_data=>tt_list_refs.
  DATA ld_tipo TYPE ddtypes-typename.

  CALL FUNCTION 'DDIF_DTEL_GET'
    EXPORTING
      name          = mv_object
    IMPORTING
      dd04v_wa      = ls_dd04v
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.


  IF sy-subrc = 0.

* Valores base
    ls_list_refs-level = mv_level.
    ls_list_refs-type = mv_type.
    ls_list_refs-object = mv_object.

* Dominio
    IF ls_dd04v-domname IS NOT INITIAL.
      ls_list_refs-object_ref = ls_dd04v-domname.
      ls_list_refs-type_ref = zif_spt_ref_data=>cs_types-domain.
      APPEND ls_list_refs TO mt_list_refs.
    ENDIF.

* Ayuda para búsqueda
    IF ls_dd04v-shlpname IS NOT INITIAL.
      ls_list_refs-object_ref = ls_dd04v-shlpname.
      ls_list_refs-type_ref = zif_spt_ref_data=>cs_types-seahlp.
      APPEND ls_list_refs TO mt_list_refs.
    ENDIF.

  ENDIF.


endmethod.


method GET_REF_SEARCH_HELP.
  FIELD-SYMBOLS <ls_dd31v> TYPE dd31v.
  DATA ls_dd30v TYPE dd30v.
  DATA ls_list_refs TYPE LINE OF zif_spt_ref_data=>tt_list_refs.
  DATA lt_dd31v TYPE STANDARD TABLE OF dd31v.
  DATA ld_tipo TYPE ddtypes-typename.

  CALL FUNCTION 'DDIF_SHLP_GET'
    EXPORTING
      name          = mv_object
    IMPORTING
      dd30v_wa      = ls_dd30v
    TABLES
      dd31v_tab     = lt_dd31v[]
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.

  IF sy-subrc = 0.

* Valores base
    ls_list_refs-level = mv_level.
    ls_list_refs-type = mv_type.
    ls_list_refs-object = mv_object.

* Método de obtencion de datos
* Como puede ser varios tipos de obtencion de datos uso una funcion para que me diga los tipos.
    IF ls_dd30v-selmethod IS NOT INITIAL.
      ld_tipo = ls_list_refs-object_ref = ls_dd30v-selmethod.
      CALL FUNCTION 'INTERN_TYPE_KIND'
        EXPORTING
          typename = ld_tipo
        IMPORTING
          typekind = ls_list_refs-type_ref.
      APPEND ls_list_refs TO mt_list_refs.
    ENDIF.

* Tabla de textos
    IF ls_dd30v-texttab IS NOT INITIAL.
      ls_list_refs-object_ref = ls_dd30v-texttab.
      ls_list_refs-type_ref = zif_spt_ref_data=>cs_types-table.
      APPEND ls_list_refs TO mt_list_refs.
    ENDIF.


* Exit de la ayuda para busqueda
    IF ls_dd30v-selmexit IS NOT INITIAL.
      ls_list_refs-object_ref = ls_dd30v-selmexit.
      ls_list_refs-type_ref = zif_spt_ref_data=>cs_types-function.
      APPEND ls_list_refs TO mt_list_refs.
    ENDIF.


* Ayudas para busquedas incluidas.
    LOOP AT lt_dd31v ASSIGNING <ls_dd31v>.
      ls_list_refs-object_ref = <ls_dd31v>-subshlp.
      ls_list_refs-type_ref = zif_spt_ref_data=>cs_types-seahlp.
      APPEND ls_list_refs TO mt_list_refs.

    ENDLOOP.
  ENDIF.


endmethod.


method GET_REF_TABLE.
  FIELD-SYMBOLS <ls_dd03p> TYPE dd03p.
  DATA ls_list_refs TYPE LINE OF zif_spt_ref_data=>tt_list_refs.
  DATA lt_dd03p TYPE STANDARD TABLE OF dd03p.
  DATA ld_tipo TYPE ddtypes-typename.

  CALL FUNCTION 'DDIF_TABL_GET'
    EXPORTING
      name          = mv_object
    TABLES
      dd03p_tab     = lt_dd03p
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.

  IF sy-subrc = 0.
* Los includes y append se eliminan porque los campos ya vienen en la tabla
    DELETE lt_dd03p WHERE fieldname = '.INCLUDE'.
    DELETE lt_dd03p WHERE fieldname = 'APPEND'.

    LOOP AT lt_dd03p ASSIGNING <ls_dd03p>.

* Valores base
      ls_list_refs-level = mv_level.
      ls_list_refs-type = mv_type.
      ls_list_refs-object = mv_object.

* Elemento de datos/estructura/tipo de tabla
      IF <ls_dd03p>-rollname IS NOT INITIAL
         AND <ls_dd03p>-comptype IS NOT INITIAL. " No sea tipo instalado.
        CASE <ls_dd03p>-comptype.
          WHEN 'E'. " Elemento de datos
            ls_list_refs-type_ref = zif_spt_ref_data=>cs_types-dataelem.
            ls_list_refs-object_ref = <ls_dd03p>-rollname.
          WHEN 'L'. " Tipo tabla
            ls_list_refs-type_ref = zif_spt_ref_data=>cs_types-tabltype.
            ls_list_refs-object_ref = <ls_dd03p>-rollname.
          WHEN 'R'. " Clase o interface
            ls_list_refs-object_ref = <ls_dd03p>-rollname.
            ld_tipo = ls_list_refs-object_ref.
            CALL FUNCTION 'INTERN_TYPE_KIND'
              EXPORTING
                typename = ld_tipo
              IMPORTING
                typekind = ls_list_refs-type_ref.
        ENDCASE.
        IF ls_list_refs-object_ref IS NOT INITIAL.
          APPEND ls_list_refs TO mt_list_refs.
        ENDIF.
      ENDIF.

* Tabla de verificacion
      IF <ls_dd03p>-checktable IS NOT INITIAL.
        ls_list_refs-object_ref = <ls_dd03p>-checktable.
        ls_list_refs-type_ref = zif_spt_ref_data=>cs_types-table.
        APPEND ls_list_refs TO mt_list_refs.
      ENDIF.

* Tabla de dominio
      IF <ls_dd03p>-domname IS NOT INITIAL.
        ls_list_refs-object_ref = <ls_dd03p>-domname.
        ls_list_refs-type_ref = zif_spt_ref_data=>cs_types-domain.
        APPEND ls_list_refs TO mt_list_refs.
      ENDIF.

* Tabla de valores
      IF <ls_dd03p>-entitytab IS NOT INITIAL.
        ls_list_refs-object_ref = <ls_dd03p>-entitytab.
        ls_list_refs-type_ref = zif_spt_ref_data=>cs_types-table.
        APPEND ls_list_refs TO mt_list_refs.
      ENDIF.

* Tabla de referencia
      IF <ls_dd03p>-reftable IS NOT INITIAL.
        ls_list_refs-object_ref = <ls_dd03p>-reftable.
        ls_list_refs-type_ref = zif_spt_ref_data=>cs_types-table.
        APPEND ls_list_refs TO mt_list_refs.
      ENDIF.

* Ayuda de búsqueda
      IF <ls_dd03p>-shlpname IS NOT INITIAL.
        ls_list_refs-object_ref = <ls_dd03p>-shlpname.
        ls_list_refs-type_ref = zif_spt_ref_data=>cs_types-seahlp.
        APPEND ls_list_refs TO mt_list_refs.
      ENDIF.

    ENDLOOP.

  ENDIF.

endmethod.


method GET_REF_TABLE_TYPE.
  DATA ls_dd40v TYPE dd40v.
  DATA ls_list_refs TYPE LINE OF zif_spt_ref_data=>tt_list_refs.
  DATA ld_tipo TYPE ddtypes-typename.

  CALL FUNCTION 'DDIF_TTYP_GET'
    EXPORTING
      name          = mv_object
    IMPORTING
      dd40v_wa      = ls_dd40v
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.

  IF sy-subrc = 0.

* Valores base
    ls_list_refs-level = mv_level.
    ls_list_refs-type = mv_type.
    ls_list_refs-object = mv_object.

* Tipo de datos principal
    IF ls_dd40v-rowtype IS NOT INITIAL.
      ld_tipo = ls_list_refs-object_ref = ls_dd40v-rowtype.
      CALL FUNCTION 'INTERN_TYPE_KIND'
        EXPORTING
          typename = ld_tipo
        IMPORTING
          typekind = ls_list_refs-type_ref.
      APPEND ls_list_refs TO mt_list_refs.
    ENDIF.

* Elemento de datos en caso de que el tipo de tabla sea un ranges
    IF ls_dd40v-range_ctyp IS NOT INITIAL.
      ls_list_refs-object_ref = ls_dd40v-range_ctyp.
      ls_list_refs-type_ref = zif_spt_ref_data=>cs_types-dataelem.
      APPEND ls_list_refs TO mt_list_refs.
    ENDIF.

  ENDIF.


endmethod.


method GET_REF_VIEW.
  FIELD-SYMBOLS <ls_dd26v> TYPE dd26v.
  FIELD-SYMBOLS <ls_dd27p> TYPE dd27p.
  DATA lt_dd26v TYPE STANDARD TABLE OF dd26v.
  DATA lt_dd27p TYPE STANDARD TABLE OF dd27p.
  DATA ls_list_refs TYPE LINE OF zif_spt_ref_data=>tt_list_refs.

  CALL FUNCTION 'DDIF_VIEW_GET'
    EXPORTING
      name          = mv_object
    TABLES
      dd26v_tab     = lt_dd26v[]
      dd27p_tab     = lt_dd27p[]
    EXCEPTIONS
      illegal_input = 1
      OTHERS        = 2.

  IF sy-subrc = 0.

* Valores base
    ls_list_refs-level = mv_level.
    ls_list_refs-type = mv_type.
    ls_list_refs-object = mv_object.

* Leo las tablas que componen la vista
    LOOP AT lt_dd26v ASSIGNING <ls_dd26v>.
      ls_list_refs-object_ref = <ls_dd26v>-tabname.
      ls_list_refs-type_ref = zif_spt_ref_data=>cs_types-table.
      APPEND ls_list_refs TO mt_list_refs.
    ENDLOOP.

* Los campos de las vistas. Si se utiliza dentro de la recursividad, de la tabla
* que se encuentra en la tabla interna se determinan los campos que se añadirán.
* Pero como las referencias no tienen que ser siempre recursivas opto por añadir
* los campos.
    LOOP AT lt_dd27p ASSIGNING <ls_dd27p>.

* Elemento de datos
      IF <ls_dd27p>-rollname IS NOT INITIAL.
        ls_list_refs-object_ref = <ls_dd27p>-rollname.
        ls_list_refs-type_ref = zif_spt_ref_data=>cs_types-dataelem.
        APPEND ls_list_refs TO mt_list_refs.
      ENDIF.

* Dominio
      IF <ls_dd27p>-domname IS NOT INITIAL.
        ls_list_refs-object_ref = <ls_dd27p>-domname.
        ls_list_refs-type_ref = zif_spt_ref_data=>cs_types-domain.
        APPEND ls_list_refs TO mt_list_refs.
      ENDIF.

* Tabla de verificacion
      IF <ls_dd27p>-checktable IS NOT INITIAL.
        ls_list_refs-object_ref = <ls_dd27p>-checktable.
        ls_list_refs-type_ref = zif_spt_ref_data=>cs_types-table.
        APPEND ls_list_refs TO mt_list_refs.
      ENDIF.

* Ayuda para búsqueda
      IF <ls_dd27p>-shlpname IS NOT INITIAL.
        ls_list_refs-object_ref = <ls_dd27p>-shlpname.
        ls_list_refs-type_ref = zif_spt_ref_data=>cs_types-seahlp.
        APPEND ls_list_refs TO mt_list_refs.
      ENDIF.

    ENDLOOP.

  ENDIF.


endmethod.


method SEARCH_REFS.

  CLEAR et_refs.

* Primero obtengo las referencias del objeto pasado
  get_all_refs( ).

* Se devuelven los registros encontrados.
  et_refs = mt_list_refs.
endmethod.
ENDCLASS.
