CLASS zcl_spt_translate_utilities DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    "! <p class="shorttext synchronized">Create internal table from some base camps</p>
    CLASS-METHODS create_it_fields_base
      IMPORTING
        !i_base_fields TYPE any
        !i_new_fields  TYPE lvc_t_fcat
      EXPORTING
        !e_table       TYPE REF TO data
        !e_wa          TYPE REF TO data .
    "! <p class="shorttext synchronized">Create internal table from fieldcatalog</p>
    CLASS-METHODS create_it_from_fcat
      IMPORTING
        !i_fields TYPE lvc_t_fcat
      EXPORTING
        !e_table  TYPE REF TO data
        !e_wa     TYPE REF TO data .
    "! <p class="shorttext synchronized">Create internat table from reference some base camps</p>
    CLASS-METHODS create_it_fields_base_ref
      IMPORTING
        !i_base_fields TYPE REF TO data
        !i_new_fields  TYPE lvc_t_fcat
      EXPORTING
        !e_table       TYPE REF TO data
        !e_wa          TYPE REF TO data .
    "! <p class="shorttext synchronized">Get components from fieldcat</p>
    CLASS-METHODS get_component_from_fcat
      IMPORTING
        !i_fcat             TYPE lvc_t_fcat
      RETURNING
        VALUE(r_components) TYPE cl_abap_structdescr=>component_table .
    "! <p class="shorttext synchronized">Pivot table based on another</p>
    CLASS-METHODS pivot_table
      IMPORTING
        !i_pivot_pattern TYPE string
        !i_move_field    TYPE string
        !i_itab_source   TYPE STANDARD TABLE
        !i_pivot_field   TYPE string
      CHANGING
        !c_pivot_table   TYPE STANDARD TABLE .
    "! <p class="shorttext synchronized">Create internal table from name of structure</p>
    CLASS-METHODS create_it_from_struc
      IMPORTING
        !i_struc    TYPE any
      EXPORTING
        !e_table    TYPE REF TO data
        !e_workarea TYPE REF TO data .
    "! <p class="shorttext synchronized">Create work area from name of structure</p>
    CLASS-METHODS create_wa_from_struc
      IMPORTING
        !i_struc    TYPE any
      EXPORTING
        !e_workarea TYPE REF TO data .
  PROTECTED SECTION.
    CLASS-DATA mv_text_type TYPE string VALUE 'TYPE='.    "#EC NOTEXT .
    "! <p class="shorttext synchronized">Gets the name of the pointer data type</p>
    CLASS-METHODS get_name_of_type
      IMPORTING
        !i_absolute_name   TYPE abap_abstypename
      RETURNING
        VALUE(r_name_type) TYPE string .
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_spt_translate_utilities IMPLEMENTATION.
  METHOD create_it_fields_base.
    DATA lo_data TYPE REF TO data.

    GET REFERENCE OF i_base_fields INTO lo_data.

    CALL METHOD create_it_fields_base_ref
      EXPORTING
        i_base_fields = lo_data
        i_new_fields  = i_new_fields
      IMPORTING
        e_table       = e_table
        e_wa          = e_wa.

  ENDMETHOD.


  METHOD create_it_fields_base_ref.

    DATA: le_fcat  TYPE lvc_s_fcat,
          lt_fcat  TYPE lvc_t_fcat,
          tabname  TYPE dd02l-tabname,
          new_line TYPE REF TO data.
    DATA lo_struct_ref TYPE REF TO cl_abap_structdescr.
    DATA ld_name_type TYPE string.
    DATA ld_dataref TYPE REF TO data.
    DATA lt_components TYPE cl_abap_structdescr=>component_table.
    DATA lt_components_new TYPE cl_abap_structdescr=>component_table.
    DATA lo_new_tab  TYPE REF TO cl_abap_tabledescr.
    DATA lo_new_wa TYPE REF TO cl_abap_structdescr.
    DATA lo_data TYPE REF TO data.
    FIELD-SYMBOLS <component> TYPE LINE OF abap_compdescr_tab.
    FIELD-SYMBOLS <table> TYPE STANDARD TABLE.

* Obtengo los componentes del tipo de datos
    lo_struct_ref ?= cl_abap_typedescr=>describe_by_data_ref( i_base_fields ).

* Obtengo los componentes
    lt_components = lo_struct_ref->get_components( ).

* Convierto el fieldcat del campo en componentes
    CALL METHOD get_component_from_fcat
      EXPORTING
        i_fcat       = i_new_fields
      RECEIVING
        r_components = lt_components_new.

* Añado los nuevos componentes a los existentes
    APPEND LINES OF lt_components_new TO lt_components.

* Creo un nuevo tipo de datos con los componentes pasados.
    lo_struct_ref = cl_abap_structdescr=>create( lt_components ).

* Creamos el manejador para la cabecera de la tabla
    CREATE DATA e_wa TYPE HANDLE lo_struct_ref.

* Creo que la nueva tabla interna
    lo_new_tab = cl_abap_tabledescr=>create(
                    p_line_type  = lo_struct_ref
                    p_table_kind = cl_abap_tabledescr=>tablekind_std
                    p_unique     = abap_false ).

* Creamos el manejador de la nueva tabla
    CREATE DATA e_table TYPE HANDLE lo_new_tab.

  ENDMETHOD.


  METHOD create_it_from_fcat.

    DATA: le_fcat  TYPE lvc_s_fcat,
          lt_fcat  TYPE lvc_t_fcat,
          tabname  TYPE dd02l-tabname,
          new_line TYPE REF TO data.
    DATA lo_struct_ref TYPE REF TO cl_abap_structdescr.
    DATA ld_name_type TYPE string.
    DATA ld_dataref TYPE REF TO data.
    DATA lt_components TYPE cl_abap_structdescr=>component_table.
    DATA lo_new_tab  TYPE REF TO cl_abap_tabledescr.
    DATA lo_new_wa TYPE REF TO cl_abap_structdescr.
    DATA lo_data TYPE REF TO data.
    FIELD-SYMBOLS <component> TYPE LINE OF abap_compdescr_tab.
    FIELD-SYMBOLS <table> TYPE STANDARD TABLE.

* Convierto el fieldcat del campo en componentes
    CALL METHOD get_component_from_fcat
      EXPORTING
        i_fcat       = i_fields
      RECEIVING
        r_components = lt_components.

* Creo un nuevo tipo de datos con los componentes pasados.
    lo_struct_ref = cl_abap_structdescr=>create( lt_components ).

* Creamos el manejador para la cabecera de la tabla
    CREATE DATA e_wa TYPE HANDLE lo_struct_ref.

* Creo que la nueva tabla interna
    lo_new_tab = cl_abap_tabledescr=>create(
                    p_line_type  = lo_struct_ref
                    p_table_kind = cl_abap_tabledescr=>tablekind_std
                    p_unique     = abap_false ).

* Creamos el manejador de la nueva tabla
    CREATE DATA e_table TYPE HANDLE lo_new_tab.

  ENDMETHOD.


  METHOD create_it_from_struc.
    DATA lo_error TYPE REF TO cx_sy_table_creation.
    DATA ld_txt_error TYPE string.
    DATA lo_struct_ref TYPE REF TO cl_abap_structdescr.
    DATA lt_components TYPE cl_abap_structdescr=>component_table.
    DATA lo_new_tab  TYPE REF TO cl_abap_tabledescr.
    DATA lo_new_wa TYPE REF TO cl_abap_structdescr.

* Obtengo los componentes del tipo de datos
    lo_struct_ref ?= cl_abap_typedescr=>describe_by_name( i_struc ).

* Obtengo los componentes
    lt_components = lo_struct_ref->get_components( ).

* Creo un nuevo tipo de datos con los componentes pasados.
    lo_new_wa = cl_abap_structdescr=>create( lt_components ).

* Creo que la nueva tabla interna
    TRY.
        lo_new_tab = cl_abap_tabledescr=>create(
                        p_line_type  = lo_new_wa
                        p_table_kind = cl_abap_tabledescr=>tablekind_std
                        p_unique     = abap_false ).

* Creamos el manejador de la nueva tabla
        CREATE DATA e_table TYPE HANDLE lo_new_tab.

* Y su cabecera
        CREATE DATA e_workarea TYPE HANDLE lo_new_wa.


      CATCH cx_sy_table_creation INTO lo_error.
        ld_txt_error = lo_error->get_text( ).
    ENDTRY.


  ENDMETHOD.


  METHOD create_wa_from_struc.
    DATA lo_error TYPE REF TO cx_sy_struct_creation.
    DATA d_txt_error TYPE string.
    DATA lo_struct_ref TYPE REF TO cl_abap_structdescr.
    DATA lt_components TYPE cl_abap_structdescr=>component_table.
    DATA lo_wa TYPE REF TO cl_abap_structdescr.
    FIELD-SYMBOLS <component> TYPE LINE OF abap_compdescr_tab.

* Obtengo los componentes del tipo de datos
    lo_struct_ref ?= cl_abap_typedescr=>describe_by_name( i_struc ).

* Obtengo los componentes
    lt_components = lo_struct_ref->get_components( ).

* Creo un nuevo tipo de datos con los componentes pasados.
    TRY.
        lo_wa = cl_abap_structdescr=>create( lt_components ).

* Creamos el manejador de la nueva tabla
        CREATE DATA e_workarea TYPE HANDLE lo_wa.

      CATCH cx_sy_struct_creation INTO lo_error.
        d_txt_error = lo_error->get_text( ).

    ENDTRY.



  ENDMETHOD.


  METHOD get_component_from_fcat.
    DATA le_component TYPE LINE OF cl_abap_structdescr=>component_table.
    DATA lo_typedescr TYPE REF TO cl_abap_typedescr.
    DATA lo_structdesc TYPE REF TO cl_abap_structdescr.
    DATA ld_type_elem TYPE string.
    DATA ld_dec_elem TYPE i.
    DATA ld_length_elem TYPE i.

    FIELD-SYMBOLS <ls_fcat> TYPE LINE OF lvc_t_fcat.

    CLEAR r_components.

    LOOP AT i_fcat ASSIGNING <ls_fcat>.

      le_component-name = <ls_fcat>-fieldname.

* Obtengo la información del elementos de datos, si esta.
      IF <ls_fcat>-rollname IS NOT INITIAL.
        lo_typedescr = cl_abap_elemdescr=>describe_by_name( <ls_fcat>-rollname ).
        ld_type_elem = lo_typedescr->type_kind.
        ld_dec_elem = lo_typedescr->decimals.
        ld_length_elem = lo_typedescr->length.
      ELSE.
        ld_type_elem = <ls_fcat>-inttype.
        ld_dec_elem = <ls_fcat>-decimals.
        ld_length_elem = <ls_fcat>-intlen.
      ENDIF.

      CASE ld_type_elem.

        WHEN cl_abap_elemdescr=>typekind_char.
          le_component-type = cl_abap_elemdescr=>get_c( p_length   = ld_length_elem ).

        WHEN cl_abap_elemdescr=>typekind_packed.
* Obtengo el tipo de datos segun el componente
          le_component-type = cl_abap_elemdescr=>get_p( p_length   = ld_length_elem
                                                        p_decimals = ld_dec_elem ).

        WHEN cl_abap_elemdescr=>typekind_num.
          le_component-type = cl_abap_elemdescr=>get_n( p_length   = ld_length_elem ).

        WHEN cl_abap_elemdescr=>typekind_date.
          le_component-type = cl_abap_elemdescr=>get_d( ).

        WHEN cl_abap_elemdescr=>typekind_string.
          le_component-type = cl_abap_elemdescr=>get_string( ).

        WHEN cl_abap_elemdescr=>typekind_int.
          le_component-type = cl_abap_elemdescr=>get_i( ).

        WHEN cl_abap_elemdescr=>typekind_struct1. " Estructura diccionario

          le_component-type ?= cl_abap_typedescr=>describe_by_name( <ls_fcat>-rollname ).

        WHEN cl_abap_elemdescr=>typekind_table. " Tabla interna

          le_component-type ?= cl_abap_typedescr=>describe_by_name( <ls_fcat>-rollname ).

*    when cl_abap_elemdescr=>TYPEKIND_struct2.
*    when cl_abap_elemdescr=>TYPEKIND_INT1
*    when cl_abap_elemdescr=>TYPEKIND_CLASS.

      ENDCASE.
      IF le_component IS NOT INITIAL.
        APPEND le_component TO r_components.
        CLEAR le_component.
        FREE lo_typedescr.
      ENDIF.


    ENDLOOP.



*    DATA lo_typedescr  TYPE REF TO cl_abap_elemdescr.
*  DATA le_component TYPE LINE OF cl_abap_structdescr=>component_table.
*
*  FIELD-SYMBOLS <ls_fcat> TYPE LINE OF lvc_t_fcat.
*
*  CLEAR r_components.
*
*  LOOP AT i_fcat ASSIGNING <ls_fcat>.
*
*    le_component-name = <ls_fcat>-fieldname.
*
** Obtengo la información del elementos de datos
*    lo_typedescr ?= cl_abap_elemdescr=>describe_by_name( <ls_fcat>-rollname ).
*
**    TYPE_KIND
*case
** Obtengo el tipo de datos segun el componente
*    le_component-type = cl_abap_elemdescr=>get_p( p_length   = lo_typedescr->length
*                                                  p_decimals = lo_typedescr->decimals ).
*
*    APPEND le_component TO r_components.
*    CLEAR le_component.
*    FREE lo_typedescr.
*
*  ENDLOOP.

  ENDMETHOD.


  METHOD get_name_of_type.
    DATA ld_pos TYPE i.

    CLEAR r_name_type.

* Busco donde empieza el literal TYPE=.
    FIND FIRST OCCURRENCE OF mv_text_type IN i_absolute_name MATCH OFFSET ld_pos.
    IF sy-subrc = 0.

* Obtengo el literal desde la posición donde esta el valor DE TYPE=
      r_name_type = i_absolute_name+ld_pos.

* Eliminio el TYPE= para quedarme con el nombre
      REPLACE ALL OCCURRENCES OF mv_text_type IN r_name_type WITH space.

    ENDIF.


  ENDMETHOD.


  METHOD pivot_table.
    FIELD-SYMBOLS <le_pivot> TYPE any.
    FIELD-SYMBOLS <le_source> TYPE any.
    FIELD-SYMBOLS <le_pivot_field> TYPE any.
    FIELD-SYMBOLS <le_field> TYPE any.
    FIELD-SYMBOLS <le_move_field> TYPE any.
    DATA le_pivot TYPE REF TO data.
    DATA ld_field TYPE string.

* Creo la workarea de la tabla pivote
    CREATE DATA le_pivot LIKE LINE OF c_pivot_table.
    ASSIGN le_pivot->* TO <le_pivot>.

* Recorro la tabla de origen
    LOOP AT i_itab_source ASSIGNING <le_source>.

* Muevo los campos comunes
      MOVE-CORRESPONDING <le_source> TO <le_pivot>.

* Obtengo el valor del campo que se va pivotar
      ASSIGN COMPONENT i_pivot_field OF STRUCTURE <le_source> TO <le_field>.

      IF sy-subrc = 0.

* Creo el campo donde se pondra el valor en la tabla pivote.
        CONCATENATE '<LE_PIVOT>-' i_pivot_pattern <le_field> INTO ld_field.
        ASSIGN (ld_field) TO <le_pivot_field>.

        IF sy-subrc = 0.

* Obtengo el valor del campo que se va mover su valor al del
* campo de la tabla pivote.
          CONCATENATE '<LE_SOURCE>-' i_move_field INTO ld_field.
          ASSIGN (ld_field) TO <le_move_field>.
          IF sy-subrc = 0.

            <le_pivot_field> = <le_move_field>.
            COLLECT <le_pivot> INTO c_pivot_table.
            CLEAR <le_pivot>.

          ENDIF.
        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
