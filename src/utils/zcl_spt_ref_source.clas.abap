CLASS zcl_spt_ref_source DEFINITION
  PUBLIC
  CREATE PUBLIC .

*"* public components of class ZCL_SPT_REF_SOURCE
*"* do not include other source files here!!!
  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        !iv_object            TYPE any
        !iv_type              TYPE trobjtype
        !iv_level             TYPE i OPTIONAL
        !iv_only_customer_obj TYPE sap_bool DEFAULT 'X'
      EXCEPTIONS
        error_object
        type_object_not_valid .
    METHODS search_refs
      IMPORTING
        !iv_local TYPE sychar01 OPTIONAL
      EXPORTING
        !et_refs  TYPE zif_spt_ref_data=>tt_list_refs .
    CLASS-METHODS get_internal_name
      IMPORTING
        !iv_object              TYPE any
        !iv_type                TYPE trobjtype
      EXPORTING
        VALUE(ev_internal_name) TYPE any
      EXCEPTIONS
        type_object_not_valid .
  PROTECTED SECTION.
*"* protected components of class ZCL_SPT_REF_SOURCE
*"* do not include other source files here!!!

    DATA mv_object TYPE program .
    DATA mo_compiler TYPE REF TO cl_abap_compiler .
    DATA mv_internal_name TYPE program .
    DATA mv_type TYPE trobjtype .
    DATA mt_scan_refs TYPE scr_glrefs .
    DATA mt_list_refs TYPE zif_spt_ref_data=>tt_list_refs .
    DATA mv_level TYPE i .
    DATA mv_only_customer_obj TYPE sap_bool .

    METHODS build_tag_ref
      IMPORTING
        !iv_tag           TYPE scr_tag
      RETURNING
        VALUE(rv_tag_txt) TYPE string .
    METHODS adapt_refs_list .
    METHODS get_all_refs
      IMPORTING
        !iv_local TYPE sychar01 DEFAULT abap_true .
    METHODS adapt_ref_tag_fu
      IMPORTING
        !iv_ref      TYPE scr_glref
      CHANGING
        !cs_list_ref TYPE zif_spt_ref_data=>ts_list_refs .
    METHODS adapt_ref_tag_ty
      IMPORTING
        !iv_ref      TYPE scr_glref
      CHANGING
        !cs_list_ref TYPE zif_spt_ref_data=>ts_list_refs .
    METHODS adapt_ref_tag_mi
      IMPORTING
        !iv_ref      TYPE scr_glref
      CHANGING
        !cs_list_ref TYPE zif_spt_ref_data=>ts_list_refs .
    METHODS adapt_ref_tag_ic
      IMPORTING
        !iv_ref      TYPE scr_glref
      CHANGING
        !cs_list_ref TYPE zif_spt_ref_data=>ts_list_refs .
    METHODS adapt_ref_tag_pr
      IMPORTING
        !iv_ref      TYPE scr_glref
      CHANGING
        !cs_list_ref TYPE zif_spt_ref_data=>ts_list_refs .
    METHODS adapt_ref_tag_simple
      IMPORTING
        !iv_ref      TYPE scr_glref
      CHANGING
        !cs_list_ref TYPE zif_spt_ref_data=>ts_list_refs .
    METHODS adapt_ref_tag_mn
      IMPORTING
        !iv_ref      TYPE scr_glref
      CHANGING
        !cs_list_ref TYPE zif_spt_ref_data=>ts_list_refs .
  PRIVATE SECTION.
*"* private components of class ZCL_SPT_REF_SOURCE
*"* do not include other source files here!!!
ENDCLASS.



CLASS zcl_spt_ref_source IMPLEMENTATION.


  METHOD adapt_refs_list.
    FIELD-SYMBOLS <ls_scan_refs> LIKE LINE OF mt_scan_refs.
    DATA ls_list_refs TYPE LINE OF zif_spt_ref_data=>tt_list_refs.

    LOOP AT mt_scan_refs ASSIGNING <ls_scan_refs>.
      CLEAR ls_list_refs.
      ls_list_refs-level = mv_level.
      ls_list_refs-type = mv_type.
      ls_list_refs-object = mv_object.
      ls_list_refs-internal_name = mv_internal_name.
      ls_list_refs-fullname_ref = <ls_scan_refs>-full_name.

      CASE <ls_scan_refs>-tag.
        WHEN 'PR'. " Program
          adapt_ref_tag_pr( EXPORTING iv_ref = <ls_scan_refs>
                            CHANGING cs_list_ref = ls_list_refs ).
        WHEN 'FU'. " Function module.
          adapt_ref_tag_fu( EXPORTING iv_ref = <ls_scan_refs>
                            CHANGING cs_list_ref = ls_list_refs ).
        WHEN 'MI'. " Message class
          adapt_ref_tag_mi( EXPORTING iv_ref = <ls_scan_refs>
                            CHANGING cs_list_ref = ls_list_refs ).
        WHEN 'TY'. " Data type
          adapt_ref_tag_ty( EXPORTING iv_ref = <ls_scan_refs>
                          CHANGING cs_list_ref = ls_list_refs ).
        WHEN 'IC'. " Include
          adapt_ref_tag_ic( EXPORTING iv_ref = <ls_scan_refs>
                          CHANGING cs_list_ref = ls_list_refs ).
        WHEN 'MN'. " Individual messages
          adapt_ref_tag_mn( EXPORTING iv_ref = <ls_scan_refs>
                        CHANGING cs_list_ref = ls_list_refs ).
      ENDCASE.

* Si algunos de los campos tipo de referencia o nombre de la referencia
* están en blanco no lo añado porque, o bien, no se ha determinado bien a pesar
* de ser un tag correcto, o bien, el tag no se va a procesar.
      IF ls_list_refs-type_ref IS NOT INITIAL AND ls_list_refs-object_ref IS NOT INITIAL.

* Recupero el nombre interno del objeto referencia. Útil cuando se va a explotar
* dicho objeto para otras cosas: como traducciones.
        CALL METHOD get_internal_name
          EXPORTING
            iv_object             = ls_list_refs-object_ref
            iv_type               = ls_list_refs-type_ref
          IMPORTING
            ev_internal_name      = ls_list_refs-internal_name_ref
          EXCEPTIONS
            type_object_not_valid = 1
            OTHERS                = 2.
        IF sy-subrc <> 0.
          ls_list_refs-internal_name_ref = ls_list_refs-object_ref.
        ENDIF.

* Si el objeto ya esta insertado no lo vuelvo hacer.
* A veces se devuelven referencias duplicadas debido a subobjetos. Ejemplo la clase de mensajes.
* Por cada mensaje que hay en el objeto, se repite la clase de mensajes.
        READ TABLE mt_list_refs TRANSPORTING NO FIELDS WITH KEY type_ref = ls_list_refs-type_ref
                                                                object_ref = ls_list_refs-object_ref.
        IF sy-subrc NE 0.
          IF mv_only_customer_obj = abap_true AND ( ls_list_refs-object_ref CP 'Z*' OR ls_list_refs-object_ref CP 'Y*' ).
            APPEND ls_list_refs TO mt_list_refs.
          ELSEIF mv_only_customer_obj = abap_false.
            APPEND ls_list_refs TO mt_list_refs.
          ENDIF.
        ENDIF.

      ENDIF.

    ENDLOOP.

* Para evitar bucles infitos, borro los objetos cuya referencia sea la misma que la que se busca:
    DELETE mt_list_refs WHERE type_ref = mv_type
                              AND object_ref = mv_object.
  ENDMETHOD.


  METHOD adapt_ref_tag_fu.

* El tag de las funciones requiere una adaptación simple. Por ello al método generico
* para eso.
    CALL METHOD adapt_ref_tag_simple
      EXPORTING
        iv_ref      = iv_ref
      CHANGING
        cs_list_ref = cs_list_ref.

* Tipo de objeto de referecia
    cs_list_ref-type_ref = zif_spt_ref_data=>cs_types-function.

  ENDMETHOD.


  METHOD adapt_ref_tag_ic.
    DATA ld_full_name TYPE string.
    DATA ld_tag TYPE string.

* Los includes que contienen "=" se ignoran, el motivo es que son los includes internos
* de la clases. Que sirven para separar las secciones públicas, privadas, etc..
    IF iv_ref-full_name NS '='.
* Obtengo el tag para buscar en el full name.
      ld_tag = build_tag_ref( iv_ref-tag ).

* Paso el nombre completo al campo de referencia.
      cs_list_ref-object_ref = iv_ref-full_name.

* Elimino el tag del objeto para quede limpio.
      REPLACE ld_tag IN cs_list_ref-object_ref WITH space.
      CONDENSE cs_list_ref-object_ref.

* Tipo de objeto de referecia. Include y programa son lo mismo.
      cs_list_ref-type_ref = zif_spt_ref_data=>cs_types-program.

    ENDIF.

  ENDMETHOD.


  METHOD adapt_ref_tag_mi.

* El tag de los programa requiere una adaptación simple. Por ello al método generico
* para eso.
    CALL METHOD adapt_ref_tag_simple
      EXPORTING
        iv_ref      = iv_ref
      CHANGING
        cs_list_ref = cs_list_ref.

* Tipo de objeto de referecia
    cs_list_ref-type_ref = zif_spt_ref_data=>cs_types-messclas.

  ENDMETHOD.


  METHOD adapt_ref_tag_mn.

    cs_list_ref-object_ref = iv_ref-full_name.

* Quito los tags de separacion entre clase de mensaje y número mensaje
    REPLACE '\MI:' IN cs_list_ref-object_ref WITH space.
    REPLACE '\MN:' IN cs_list_ref-object_ref WITH space.

* Tipo de objeto de referecia
    cs_list_ref-type_ref = zif_spt_ref_data=>cs_types-single_mess.

  ENDMETHOD.


  METHOD adapt_ref_tag_pr.

* El tag de los programa requiere una adaptación simple. Por ello al método generico
* para eso.
    CALL METHOD adapt_ref_tag_simple
      EXPORTING
        iv_ref      = iv_ref
      CHANGING
        cs_list_ref = cs_list_ref.

* Tipo de objeto de referecia
    cs_list_ref-type_ref = zif_spt_ref_data=>cs_types-program.

  ENDMETHOD.


  METHOD adapt_ref_tag_simple.

    DATA ld_full_name TYPE string.
    DATA ld_tag TYPE string.

* El programa hay que mirar que no sea el propio que estamos buscando las
* refs. Si es el mismo no se trata.
    IF iv_ref-full_name NS mv_object.

* Obtengo el tag para buscar en el full name.
      ld_tag = build_tag_ref( iv_ref-tag ).

* Paso el nombre completo al campo de referencia.
      cs_list_ref-object_ref = iv_ref-full_name.

* Elimino el tag del objeto para quede limpio.
      REPLACE ld_tag IN cs_list_ref-object_ref WITH space.
      CONDENSE cs_list_ref-object_ref.


    ENDIF.

  ENDMETHOD.


  METHOD adapt_ref_tag_ty.
    DATA ld_tag TYPE string.
    DATA ld_cont TYPE i.
    DATA ld_symbol TYPE REF TO cl_abap_comp_type.
    DATA ld_tipo TYPE ddtypes-typename.

* Genero el tag para buscar dentro del nombre del objeto.
    ld_tag = build_tag_ref( iv_ref-tag ).

* Busco el número de veces que se repite el tag. Solo interesa aquellos que tienen una vez el tag.
* Si hay más significa que esta el campo seguido del objeto que usa.
* Ejemplo: en el caso de tener MARA-MATNR. El primero tag es la MARA y el segundo tag es del campo.
* Pero justo antes abra un solo con la tabla MARA.
    FIND ALL OCCURRENCES OF REGEX '\\*:' IN iv_ref-full_name MATCH COUNT ld_cont.
    IF ld_cont = 1.

* Aprovecho la adaptación simple del tag para saber el nombre del objeto.
      CALL METHOD adapt_ref_tag_simple
        EXPORTING
          iv_ref      = iv_ref
        CHANGING
          cs_list_ref = cs_list_ref.

* Para saber el tipo de objeto hay que consultar la clase con los atributos del tipo de campos.
      IF iv_ref-symbol IS NOT INITIAL.
        TRY.
            ld_symbol ?= iv_ref-symbol.
            CASE ld_symbol->type_kind.
              WHEN cl_abap_comp_type=>type_kind_interface.
                cs_list_ref-type_ref = zif_spt_ref_data=>cs_types-interface. " Interface
* Para objetos elementos como para clases uso una función de SAP para saber el tipo exacto.
* Ya que si es diccionario el tipo de datos es el mismo para elemento de datos y estructuras.
* Para clases el tipo es el mismo para clases que interfaces.
* Para estructuras y tipos de tabla el tipo informado es el exacto, aún asi lanzo la función para asegurarme.
              WHEN cl_abap_comp_type=>type_kind_elementary
                  OR cl_abap_comp_type=>type_kind_class
                  OR cl_abap_comp_type=>type_kind_structure
                  OR cl_abap_comp_type=>type_kind_table
                  OR cl_abap_comp_type=>type_kind_reference.
* Llamo a una función de SAP que determina que tipo de diccionario es
                ld_tipo = cs_list_ref-object_ref.
                CALL FUNCTION 'INTERN_TYPE_KIND'
                  EXPORTING
                    typename = ld_tipo
                  IMPORTING
                    typekind = cs_list_ref-type_ref.
            ENDCASE.
          CATCH cx_root.
* Se produce una excepción cuando symbolo del objeto es de un método. Aunque por el fullname sea de una clase.
* Se ignora porque esa misma clase se captura por otro tipo de "symbol".
        ENDTRY.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD build_tag_ref.
    CLEAR rv_tag_txt.

    CONCATENATE '\' iv_tag ':' INTO rv_tag_txt.
  ENDMETHOD.


  METHOD constructor.

    mv_object = iv_object.
    mv_type = iv_type.

* El parametro I_LEVEL sirve para llamadas recursivas para encontrar referencias
* del objeto. Este nivel se guardara en la tabla de referencias con formato listado.
    IF iv_level IS SUPPLIED.
      mv_level = iv_level.
    ELSE.
      mv_level = 1.
    ENDIF.

* Parametro para leer solo los objetos de clientes
    mv_only_customer_obj = iv_only_customer_obj.

* Obtengo el nombre interno para poderlo pasar a la clase del compilador. Para programas no es necesario,
* pero para clases si.
* Instancio la clase del compilador pasandole el nombre del objeto
    CALL METHOD get_internal_name
      EXPORTING
        iv_object             = mv_object
        iv_type               = mv_type
      IMPORTING
        ev_internal_name      = mv_internal_name
      EXCEPTIONS
        type_object_not_valid = 1
        OTHERS                = 2.

    IF sy-subrc <> 0.
      RAISE type_object_not_valid.
    ENDIF.


    CREATE OBJECT mo_compiler
      EXPORTING
        p_name             = mv_internal_name
      EXCEPTIONS
        program_name_empty = 1
        OTHERS             = 2.
    IF sy-subrc NE 0.
      RAISE error_object.
    ENDIF.

  ENDMETHOD.


  METHOD get_all_refs.

    CALL METHOD mo_compiler->get_all_refs
      EXPORTING
        p_local    = iv_local
        p_extended = 'X' " Sin esto no se instancia el tipo de objeto, necesario para saber el tipo de objeto real
      IMPORTING
        p_result   = mt_scan_refs.

  ENDMETHOD.


  METHOD get_internal_name.
    DATA ld_class TYPE seoclsname.
    DATA ld_wda TYPE wdy_md_object_name.
    DATA ld_progname TYPE program.
    CASE iv_type.
      WHEN zif_spt_ref_data=>cs_types-program. " Program
* Para el caso de un programa no hay cambos.
        ev_internal_name = iv_object.
      WHEN zif_spt_ref_data=>cs_types-class. " Clase
        ld_class = iv_object.
        ev_internal_name = cl_oo_classname_service=>get_classpool_name( ld_class ).
      WHEN zif_spt_ref_data=>cs_types-interface. " Interface
        ld_class = iv_object.
        ev_internal_name = cl_oo_classname_service=>get_interfacepool_name( ld_class ).
      WHEN zif_spt_ref_data=>cs_types-function. " Function
* Para obtener las referencias de una función hay que navegar al grupo de funciones.
        SELECT SINGLE pname INTO ev_internal_name
               FROM tfdir WHERE funcname = iv_object.
      WHEN zif_spt_ref_data=>cs_types-webdynpro. " Webdynpro componente
        ld_wda = iv_object.
        CALL FUNCTION 'WDY_WB_GET_CLSNAME_WITH_GENERA'
          EXPORTING
            p_component      = ld_wda
          IMPORTING
            p_progname       = ld_progname
          EXCEPTIONS
            not_existing     = 1
            is_interface     = 2
            generation_error = 3
            OTHERS           = 4.
        IF sy-subrc = 0.
          ev_internal_name = ld_progname.
        ENDIF.
      WHEN OTHERS.
        RAISE type_object_not_valid.
    ENDCASE.
  ENDMETHOD.


  METHOD search_refs.

    CLEAR et_refs.

* Primero obtengo las referencias del objeto pasado
    get_all_refs( iv_local ).

* Segundo convierto la tabla de datos en informacion legible, a formato listado.
    adapt_refs_list( ).

* Se devuelven los registros encontrados.
    et_refs = mt_list_refs.

  ENDMETHOD.
ENDCLASS.
