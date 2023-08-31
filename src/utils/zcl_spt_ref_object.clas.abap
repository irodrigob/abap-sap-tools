CLASS zcl_spt_ref_object DEFINITION
  PUBLIC
  CREATE PUBLIC .

*"* public components of class ZCL_SPT_REF_OBJECT
*"* do not include other source files here!!!
  PUBLIC SECTION.

    METHODS search_refs
      IMPORTING
        !iv_object            TYPE any
        !iv_type              TYPE trobjtype
        !iv_level_depth_max   TYPE i DEFAULT 1
        !iv_only_customer_obj TYPE sap_bool DEFAULT 'X'
      EXPORTING
        !et_refs              TYPE zif_spt_ref_data=>tt_list_refs
      EXCEPTIONS
        type_object_not_valid .
  PROTECTED SECTION.
*"* protected components of class ZCL_SPT_REF_OBJECT
*"* do not include other source files here!!!

    DATA mv_level TYPE sytabix .
    DATA mt_refs TYPE zif_spt_ref_data=>tt_list_refs .
    DATA mv_only_customer_obj TYPE sap_bool .

    METHODS get_refs_child
      IMPORTING
        !is_refs            TYPE zif_spt_ref_data=>ts_list_refs
        !iv_level_depth_max TYPE i .
    METHODS get_all_refs
      IMPORTING
        !iv_object TYPE any
        !iv_type   TYPE trobjtype
      EXPORTING
        !et_refs   TYPE zif_spt_ref_data=>tt_list_refs
      EXCEPTIONS
        type_object_not_valid .
  PRIVATE SECTION.
*"* private components of class ZCL_SPT_REF_OBJECT
*"* do not include other source files here!!!
ENDCLASS.



CLASS zcl_spt_ref_object IMPLEMENTATION.


  METHOD get_all_refs.
    DATA lo_source TYPE REF TO zcl_spt_ref_source.
    DATA lo_ddic TYPE REF TO zcl_spt_ref_ddic.


    CLEAR et_refs.

* Las referencias se separan en codigo fuente y diccionario.
    CASE iv_type.
      WHEN zif_spt_ref_data=>cs_types-program
           OR zif_spt_ref_data=>cs_types-class
           OR zif_spt_ref_data=>cs_types-interface
           OR zif_spt_ref_data=>cs_types-function
           OR zif_spt_ref_data=>cs_types-webdynpro.

        CREATE OBJECT lo_source
          EXPORTING
            iv_object             = iv_object
            iv_type               = iv_type
            iv_level              = mv_level
            iv_only_customer_obj  = mv_only_customer_obj
          EXCEPTIONS
            error_object          = 1
            type_object_not_valid = 2
            OTHERS                = 3.
        IF sy-subrc = 0.

          CALL METHOD lo_source->search_refs
            EXPORTING
              iv_local = abap_true
            IMPORTING
              et_refs  = et_refs.

          FREE lo_source.

        ENDIF.

      WHEN zif_spt_ref_data=>cs_types-table
           OR zif_spt_ref_data=>cs_types-struc
           OR zif_spt_ref_data=>cs_types-dataelem
           OR zif_spt_ref_data=>cs_types-domain
           OR zif_spt_ref_data=>cs_types-tabltype
           OR zif_spt_ref_data=>cs_types-seahlp
           OR zif_spt_ref_data=>cs_types-view.


        CREATE OBJECT lo_ddic
          EXPORTING
            iv_object             = iv_object
            iv_type               = iv_type
            iv_level              = mv_level
            iv_only_customer_obj  = mv_only_customer_obj
          EXCEPTIONS
            error_object          = 1
            type_object_not_valid = 2
            OTHERS                = 3.
        IF sy-subrc = 0.

          CALL METHOD lo_ddic->search_refs
            IMPORTING
              et_refs = et_refs.

          FREE lo_ddic.

        ENDIF.
      WHEN OTHERS.
        RAISE type_object_not_valid.
    ENDCASE.




  ENDMETHOD.


  METHOD get_refs_child.
    FIELD-SYMBOLS <ls_refs> TYPE LINE OF zif_spt_ref_data=>tt_list_refs.
    DATA lt_refs TYPE zif_spt_ref_data=>tt_list_refs.

* Si la referencia que pasan ya esta en la tabla no la vuelvo a buscar
    READ TABLE mt_refs TRANSPORTING NO FIELDS WITH KEY object_ref = is_refs-object_ref
                                                       type_ref = is_refs-type_ref.
    IF sy-subrc NE 0.

* Añado el nivel del padre
      APPEND is_refs TO mt_refs.

* Si el nivel actual es el mismo que el máximo entonces no se procesan los hijos.
      IF mv_level < iv_level_depth_max.

* Incremento el nivel en un uno.
        ADD 1 TO mv_level.

* Busco las referencias del objeto pasado
        CALL METHOD get_all_refs
          EXPORTING
            iv_object             = is_refs-object_ref
            iv_type               = is_refs-type_ref
          IMPORTING
            et_refs               = lt_refs
          EXCEPTIONS
            type_object_not_valid = 1
            OTHERS                = 2.
        IF sy-subrc = 0.

* Con las referencias del primer nivel encuentro las
          LOOP AT lt_refs ASSIGNING <ls_refs>.
            CALL METHOD get_refs_child
              EXPORTING
                is_refs            = <ls_refs>
                iv_level_depth_max = iv_level_depth_max.
          ENDLOOP.

        ENDIF.

* Con los hijos obtenidos resto uno para volver al nivel del padre.
        SUBTRACT 1 FROM mv_level.

      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD search_refs.
    FIELD-SYMBOLS <ls_refs> TYPE LINE OF zif_spt_ref_data=>tt_list_refs.
    DATA lt_refs TYPE zif_spt_ref_data=>tt_list_refs.

    CLEAR: mt_refs.

    mv_level = 1.

    mv_only_customer_obj = iv_only_customer_obj.

* Busco las referencias del objeto principal
    CALL METHOD get_all_refs
      EXPORTING
        iv_object             = iv_object
        iv_type               = iv_type
      IMPORTING
        et_refs               = lt_refs
      EXCEPTIONS
        type_object_not_valid = 1
        OTHERS                = 2.
    IF sy-subrc = 0.

* Con las referencias del primer nivel encuentro las de los hijos
      LOOP AT lt_refs ASSIGNING <ls_refs>.
        CALL METHOD get_refs_child
          EXPORTING
            is_refs            = <ls_refs>
            iv_level_depth_max = iv_level_depth_max.
      ENDLOOP.

    ELSE.
      RAISE type_object_not_valid.
    ENDIF.

    et_refs = mt_refs.

  ENDMETHOD.
ENDCLASS.
