CLASS zcl_spt_translate_tool DEFINITION
  PUBLIC
  CREATE PUBLIC .

*"* public components of class ZTRANSLATE_TOOL
*"* do not include other source files here!!!
  PUBLIC SECTION.
    TYPES: BEGIN OF ts_languages,
             r3_lang           TYPE lxe_t002x-r3_lang,
             lxe_language      TYPE lxe_t002x-language,
             text_lang         TYPE lxe_t002x-text_lang,
             language          TYPE lxe_t002x-langshort,
             lxe_language_sort TYPE lxe_t002x-language,
           END OF ts_languages.
    TYPES: tt_languages TYPE STANDARD TABLE OF ts_languages WITH EMPTY KEY.
    TYPES: BEGIN OF ts_object_transport,
             object   TYPE trobjtype,
             obj_name TYPE sobj_name,
           END OF ts_object_transport.
    TYPES tt_object_transport TYPE STANDARD TABLE OF ts_object_transport WITH EMPTY KEY.
    DATA mv_object TYPE trobjtype READ-ONLY .
    DATA mv_obj_name TYPE sobj_name READ-ONLY .
    CONSTANTS: BEGIN OF cs_fields_itab,
                 txt_lang   TYPE fieldname VALUE 'FIELD_',
                 ctrl_lang  TYPE fieldname VALUE 'UPDKZ_',
                 ppsal_type TYPE fieldname VALUE 'TEXT_PPSAL_TYPE',
               END OF cs_fields_itab.
    CONSTANTS: BEGIN OF cs_text_ppsal_type,
                 without_text     TYPE zspt_e_text_proposal_type VALUE 'WT',
                 ppsal_confirmed  TYPE zspt_e_text_proposal_type VALUE 'PC',
                 ppsal_wo_confirm TYPE zspt_e_text_proposal_type VALUE 'PW',
               END OF cs_text_ppsal_type.
    CONSTANTS mv_struc_main_fields TYPE tabname VALUE 'ZSPT_TRANSLATE_MAIN_FIELDS'. "#EC NOTEXT
    CONSTANTS mc_field_style TYPE fieldname VALUE 'FIELD_STYLE'. "#EC NOTEXT
    CONSTANTS mc_style_wo_trans TYPE raw4 VALUE '0000000F'. "#EC NOTEXT
    CONSTANTS mc_style_prop_wo_conf TYPE raw4 VALUE '0000000C'. "#EC NOTEXT
    CONSTANTS mc_style_prop_conf TYPE raw4 VALUE '0000000E'. "#EC NOTEXT
    CONSTANTS mc_style_text_changed TYPE raw4 VALUE '0000000A'.
    CLASS-METHODS fill_return
      IMPORTING
        i_type          TYPE any DEFAULT zcl_spt_core_data=>cs_message-type_error
        i_number        TYPE any
        i_message_v1    TYPE any OPTIONAL
        i_message_v2    TYPE any OPTIONAL
        i_message_v3    TYPE any OPTIONAL
        i_message_v4    TYPE any OPTIONAL
        i_id            TYPE any OPTIONAL
        iv_langu        TYPE sylangu DEFAULT sy-langu
      RETURNING
        VALUE(r_return) TYPE bapiret2 .                     "#EC NOTEXT

    METHODS constructor .

    METHODS check_obj_2_trans
      IMPORTING
        !iv_object      TYPE trobjtype
        !iv_obj_name    TYPE sobj_name
      RETURNING
        VALUE(rv_exist) TYPE sap_bool .
    METHODS load_object_texts .
    METHODS set_params_selscreen
      IMPORTING
        !iv_olang      TYPE lxeisolang
        !it_tlang      TYPE lxe_tt_lxeisolang
        !iv_trkorr     TYPE trkorr OPTIONAL
        !iv_depth_refs TYPE i DEFAULT 2 .
    METHODS get_data
      RETURNING
        VALUE(ro_data) TYPE REF TO data .
    METHODS set_data
      IMPORTING
        !it_data TYPE REF TO data .
    METHODS get_fcat
      RETURNING
        VALUE(rt_fcat) TYPE lvc_t_fcat .
    METHODS save_data
      RETURNING
        VALUE(rs_return) TYPE bapiret2 .
    METHODS transport_mod_obj
      EXPORTING
        VALUE(es_return) TYPE bapiret2 .
    METHODS get_allowed_objects
      RETURNING
        VALUE(rt_objects) TYPE tr_object_texts .
    METHODS get_tlang
      RETURNING
        VALUE(rt_tlang) TYPE lxe_tt_lxeisolang .
    CLASS-METHODS get_name_field_text
      IMPORTING
        !iv_language        TYPE lxeisolang
      RETURNING
        VALUE(rv_fieldname) TYPE fieldname .
    "! <p class="shorttext synchronized">Devuelve los lenguajes</p>
    METHODS get_languages
      RETURNING VALUE(rt_languages) TYPE tt_languages.
    "! <p class="shorttext synchronized">Verifica que la orden es correcta</p>
    "! @parameter iv_order | <p class="shorttext synchronized">Orden</p>
    "! @parameter rs_return | <p class="shorttext synchronized">Retorno del proceso</p>
    METHODS check_order
      IMPORTING iv_order         TYPE trkorr
      RETURNING VALUE(rs_return) TYPE bapiret2.
    "! <p class="shorttext synchronized">Tarea valida de la orden</p>
    "! @parameter iv_order | <p class="shorttext synchronized">Orden</p>
    "! @parameter ev_task | <p class="shorttext synchronized">Tarea</p>
    "! @parameter es_return | <p class="shorttext synchronized">Retorno del proceso</p>
    METHODS get_task_from_order
      IMPORTING iv_order  TYPE trkorr
      EXPORTING ev_task   TYPE trkorr
                es_return TYPE bapiret2.
    "! <p class="shorttext synchronized">Añade objectos a una tarea</p>
    "! @parameter it_objects | <p class="shorttext synchronized">Objectos</p>
    "! @parameter et_return | <p class="shorttext synchronized">Resultado del proceso</p>
    METHODS add_objects_transp_req
      IMPORTING it_objects TYPE tt_object_transport
      EXPORTING et_return  TYPE zcl_spt_core_data=>tt_return.
    CLASS-METHODS get_name_field_ctrl
      IMPORTING
        i_language         TYPE lxeisolang
      RETURNING
        VALUE(r_fieldname) TYPE fieldname .
    "! <p class="shorttext synchronized">Campo del tipo de propuesta de texto</p>
    "! @parameter iv_language | <p class="shorttext synchronized">Idioma</p>
    "! @parameter rv_fieldname | <p class="shorttext synchronized">Campo</p>
    CLASS-METHODS get_name_field_ppsal_type
      IMPORTING
        iv_language         TYPE lxeisolang
      RETURNING
        VALUE(rv_fieldname) TYPE fieldname .
  PROTECTED SECTION.

*"* protected components of class ZTRANSLATE_TOOL
*"* do not include other source files here!!!
    TYPES:
      BEGIN OF ts_mngt_text,
        object       TYPE trobjtype,
        obj_name     TYPE sobj_name,
        tlang        TYPE lxeisolang,
        oobject      TYPE REF TO zcl_spt_translate_lxe,
        data_changed TYPE sap_bool,
      END OF ts_mngt_text .
    TYPES:
      tt_mngt_text TYPE SORTED TABLE OF ts_mngt_text
                     WITH NON-UNIQUE KEY object obj_name tlang .
    TYPES:
      BEGIN OF ts_main_fields,
        object      TYPE  trobjtype,
        obj_name    TYPE  sobj_name,
        objtype     TYPE  lxeobjtype,
        id_text     TYPE  lxetextkey,
        txt_olang   TYPE  string, "ztranslate_e_olang,
        field_style TYPE  lvc_t_styl,
      END OF ts_main_fields .
    TYPES:
      tt_main_fields TYPE STANDARD TABLE OF ts_main_fields .

    DATA mt_languages TYPE tt_languages .
    DATA mt_tlang TYPE lxe_tt_lxeisolang .
    DATA mv_olang TYPE lxeisolang .
    DATA mo_it_data TYPE REF TO data .
    DATA mo_wa_data TYPE REF TO data .
    DATA mt_fcat TYPE lvc_t_fcat .
    DATA mt_mngt_text TYPE tt_mngt_text .
    DATA mv_trkorr TYPE e070-trkorr .
    DATA mt_components TYPE tt_main_fields .
    DATA mt_object_list TYPE zcl_spt_translate_cmp=>tt_object_list .
    DATA mt_lxe_list TYPE zcl_spt_translate_lxe=>tt_lxe_list .
    DATA mv_depth_refs TYPE i .

    METHODS update_text_object .
    METHODS copy_1_of_read_process_texts .
    METHODS read_process_texts .
    METHODS change_text_fcat
      IMPORTING
        !i_text TYPE any
      CHANGING
        !c_fcat TYPE lvc_s_fcat .
    METHODS get_components
      EXPORTING
        VALUE(e_components) TYPE tt_main_fields .
    METHODS create_it_fcat .



    METHODS get_ref_text_object
      IMPORTING
        !i_object   TYPE trobjtype
        !i_obj_name TYPE sobj_name
        !i_tlang    TYPE lxeisolang
      EXPORTING
        !e_object   TYPE REF TO zcl_spt_translate_lxe .
    METHODS proposal_text
      IMPORTING
        i_tlang        TYPE lxeisolang
        is_texts       TYPE zcl_spt_translate_lxe=>ts_texts
        io_object_text TYPE REF TO zcl_spt_translate_lxe
      CHANGING
        cs_wa          TYPE any .
    METHODS read_languages .
  PRIVATE SECTION.
*"* private components of class ZTRANSLATE_TOOL
*"* do not include other source files here!!!
ENDCLASS.



CLASS zcl_spt_translate_tool IMPLEMENTATION.


  METHOD change_text_fcat.
    c_fcat-scrtext_l = i_text.
    c_fcat-scrtext_s = i_text.
    c_fcat-scrtext_m = i_text.
    c_fcat-reptext = i_text.
  ENDMETHOD.


  METHOD check_obj_2_trans.
    FIELD-SYMBOLS <ls_object_list> LIKE LINE OF mt_object_list.

* Aprovecho para guardar el objeto y el nombre del mismo. Se utilizará
* en otros puntos del programa
    mv_object = iv_object.
    mv_obj_name = iv_obj_name.

    READ TABLE mt_object_list ASSIGNING <ls_object_list> WITH KEY object = iv_object.
    IF sy-subrc = 0.
      rv_exist = <ls_object_list>-ref_class->check_object_exists( iv_pgmid = <ls_object_list>-pgmid
                                                                 iv_object   = iv_object
                                                                 iv_obj_name = iv_obj_name ).
    ENDIF.

  ENDMETHOD.


  METHOD check_order.
    DATA ls_request TYPE trwbo_request_header.

    CLEAR: rs_return.

    ls_request = VALUE #( trkorr = iv_order ).


    CALL FUNCTION 'TRINT_READ_REQUEST_HEADER'
      EXPORTING
        iv_read_e070   = abap_true
      CHANGING
        cs_request     = ls_request
      EXCEPTIONS
        empty_trkorr   = 1
        not_exist_e070 = 2
        OTHERS         = 99.
    IF sy-subrc NE 0.
      rs_return = fill_return( i_type       = 'E'
                               i_number     = sy-msgno
                               i_message_v1 = sy-msgv1
                               i_message_v2 = sy-msgv2
                               i_message_v3 = sy-msgv3
                               i_message_v4 = sy-msgv4
                               i_id         = sy-msgid ).

    ENDIF.
  ENDMETHOD.


  METHOD constructor.

* Carga de los idioma del entorno de traduccion
    read_languages( ).

* Se obtiene por separado los objetos que pueden ser traducidos y las clases que permiten
* traducir dichos objetos.
* El motivo de hacerlo separado es que muchos objetos se traducen de la misma manera: programas, funciones,
* clases, etc.. Por eso de la separacion.

* Obtengo los objetos que: 1) pueden ser traducidos 2) podemos obtener componentes.
    zcl_spt_translate_cmp=>get_objectlist( IMPORTING et_object_list = mt_object_list ).

* Obtengo los objetos cuyo proceso de traduccion esta implementado.
    zcl_spt_translate_lxe=>get_lxelist( IMPORTING et_lxe_list = mt_lxe_list  ).

  ENDMETHOD.


  METHOD copy_1_of_read_process_texts.
    FIELD-SYMBOLS <tbl> TYPE table.
    FIELD-SYMBOLS <wa> TYPE any.
    FIELD-SYMBOLS <field> TYPE any.
    FIELD-SYMBOLS <field_style> TYPE ANY TABLE.
    FIELD-SYMBOLS <ls_tlang> LIKE LINE OF mt_tlang.
    FIELD-SYMBOLS <ls_texts> TYPE zcl_spt_translate_lxe=>ts_texts.
    FIELD-SYMBOLS <ls_lxe_list> LIKE LINE OF mt_lxe_list.
    DATA ls_main_fields TYPE LINE OF tt_main_fields.
    DATA lt_main_fields TYPE tt_main_fields.
    DATA lo_data TYPE REF TO data.
    DATA ls_mngt_text LIKE LINE OF mt_mngt_text.
    DATA ld_tabix TYPE sytabix.
    DATA lt_texts TYPE zcl_spt_translate_lxe=>tt_texts.
    DATA ld_primer_source TYPE sap_bool.
    DATA ld_field_text TYPE fieldname.
    DATA ls_field_style TYPE LINE OF lvc_t_styl.
    DATA ld_tabix_mngt TYPE sytabix.
    DATA ld_text_object TYPE REF TO zcl_spt_translate_lxe.

    ASSIGN mo_it_data->* TO <tbl>.

    CLEAR <tbl>.

    LOOP AT mt_components INTO ls_main_fields.

* En el primer texto informaré tanto el idioma de origen como el destino.
* a partir del segundo idioma de destino solo leerá el de destino.
      ld_primer_source = abap_true.

* Se recorre la tabla de idioma a traducir.
      LOOP AT mt_tlang ASSIGNING <ls_tlang>.
        CLEAR: ls_mngt_text, lt_texts.

* Se recupera el objeto de texto para obtener las traducciones
        CALL METHOD get_ref_text_object
          EXPORTING
            i_object   = ls_main_fields-object
            i_obj_name = ls_main_fields-obj_name
            i_tlang    = <ls_tlang>
          IMPORTING
            e_object   = ld_text_object.


        IF ld_text_object IS BOUND.

* Miro si el objeto ya ha sido instancio previamente. Si no es así, se crea.
          READ TABLE mt_mngt_text INTO ls_mngt_text
                                  WITH TABLE KEY object = ls_main_fields-object
                                                 obj_name = ls_main_fields-obj_name
                                                 tlang = <ls_tlang>.
          IF sy-subrc NE 0.
* Pongo la posicion cero para que se inserte el registro.
            ld_tabix_mngt = 0.
* Se pasa los datos a la tabla que contendrá el objetos de textos en cada
* idioma para cada objeto.
            ls_mngt_text-tlang = <ls_tlang>.
            ls_mngt_text-object = ls_main_fields-object.
            ls_mngt_text-obj_name = ls_main_fields-obj_name.

* Recupero la clase que servirá para traducir el objeto.
            READ TABLE mt_lxe_list ASSIGNING <ls_lxe_list> WITH KEY object = ls_main_fields-object.
            IF sy-subrc = 0.
* Instancio el objeto que hará la traduccion
              CREATE OBJECT ls_mngt_text-oobject TYPE (<ls_lxe_list>-class).

* Valido que el objeto sea valido.
              CALL METHOD ls_mngt_text-oobject->set_check_params
                EXPORTING
                  iv_object        = ls_main_fields-object
                  iv_obj_name      = ls_main_fields-obj_name
                  iv_olang         = mv_olang
                  iv_tlang         = <ls_tlang>
                EXCEPTIONS
                  object_not_valid = 1
                  OTHERS           = 2.
              IF sy-subrc = 0.
* Leo los datos
                ls_mngt_text-oobject->load_text( ).

* Recupero los textos para pasarlos a la tabla de datos
                ls_mngt_text-oobject->get_texts( IMPORTING et_texts = lt_texts ).
              ENDIF.
            ENDIF.
          ELSE.
* Me guardo la posición para despues actualizarla.
            ld_tabix_mngt = sy-tabix.
* Vuelvo a cargar los datos
            ls_mngt_text-oobject->load_text( ).
* Recupero los textos.
            ls_mngt_text-oobject->get_texts( IMPORTING et_texts = lt_texts ).
          ENDIF.

* Solo se tienen en cuanta los objetos con textos.
          IF lt_texts IS NOT INITIAL.

* Recorro la tabla de textos para pasarla a la de datos.
            LOOP AT lt_texts ASSIGNING <ls_texts>.
              ls_main_fields-id_text = <ls_texts>-textkey. " Id del texto
              ls_main_fields-objtype = <ls_texts>-objtype. " Tipo de objeto

              IF ld_primer_source = abap_true.
                ls_main_fields-txt_olang = <ls_texts>-s_text.
              ENDIF.

* Leo si el para el objeto e id de texto esta en la tabla que guarda de manera temporal lo mismo(campos principales) que la
* tabla global dinámica. Esta tabla permite evitar duplicados o más cuando hay varios idiomas a traducir para un mismo objeto.
              READ TABLE lt_main_fields TRANSPORTING NO FIELDS WITH KEY object = ls_main_fields-object
                                                                        obj_name = ls_main_fields-obj_name
                                                                        id_text = ls_main_fields-id_text
                                                                        objtype = ls_main_fields-objtype.
              IF sy-subrc = 0.
* Me guardo la posicion donde se ha encontrado.
                ld_tabix = sy-tabix.
* Los registros de la tabla loca y temporal siempre coinciden porque se añaden los mismos datos.
                READ TABLE <tbl> ASSIGNING <wa> INDEX ld_tabix.
              ELSE.
                CLEAR ld_tabix.
* Reasigno la cabecera para limpiar valores previos.
                ASSIGN mo_wa_data->* TO <wa>.
                APPEND ls_main_fields TO lt_main_fields.
* Paso los datos comunes a la cabecera de la tabla de datos
                MOVE-CORRESPONDING ls_main_fields TO <wa>.
              ENDIF.

* Construyo el campo donde se pondra el texto destino
              ld_field_text = get_name_field_text( <ls_tlang> ).
              ASSIGN COMPONENT ld_field_text OF STRUCTURE <wa> TO <field>.
              IF sy-subrc = 0.
                <field> = <ls_texts>-t_text.
                IF <field> IS INITIAL.
* Recupero la mejor propuesta para el campo
                  CALL METHOD ls_mngt_text-oobject->get_best_text_proposal
                    EXPORTING
                      iv_textkey   = <ls_texts>-textkey
                      iv_objtype   = <ls_texts>-objtype
                    IMPORTING
                      ev_best_text = <field>.
                ENDIF.

* Determino el estilo según el valor del campo
                ASSIGN COMPONENT mc_field_style OF STRUCTURE <wa> TO <field_style>.
                IF sy-subrc = 0.
                  ls_field_style-fieldname = ld_field_text.
* Si no hay texto ni por propuesta ni por origen se pone el color de no hay traduccion
                  IF <field> IS INITIAL.
                    ls_field_style-style = mc_style_wo_trans.
* Si hay texto por la propuesta pero el original no lo tenia, se pone el texto de pdte de confirmacion.
                  ELSEIF <ls_texts>-t_text IS INITIAL.
                    ls_field_style-style = mc_style_prop_wo_conf.
                  ELSE.
* Si el texto esta informado compruebo si el texto esta dentro de las propuestas
* para el texto. Según el resultado el color de la celda varia.
                    IF ls_mngt_text-oobject->is_text_in_proposal( iv_text = <field>
                                                                  iv_textkey = <ls_texts>-textkey
                                                                  iv_objtype = <ls_texts>-objtype ) = abap_true.
                      ls_field_style-style = mc_style_prop_conf.
                    ELSE.
                      ls_field_style-style = mc_style_prop_wo_conf.
                    ENDIF.
                  ENDIF.
                  INSERT ls_field_style INTO TABLE <field_style>.
                  CLEAR ls_field_style.
                ENDIF.
              ENDIF.

* Si el objeto e id de texto no esta en la tabla temporal, muevo los campos principales
* a la cabecera y añado los datos.
              IF ld_tabix IS INITIAL.
                APPEND <wa> TO <tbl>.
                CLEAR <wa>.
              ENDIF.

            ENDLOOP.

* Segun el valor de la variable ld_tabix_mngt se sabe si hay que insertar o modificar.
            IF ld_tabix_mngt IS INITIAL.
              INSERT ls_mngt_text INTO TABLE mt_mngt_text.
            ELSE.
              MODIFY mt_mngt_text FROM ls_mngt_text INDEX ld_tabix_mngt.
            ENDIF.

* Marco para que el texto de origen no se vuelva a pasar porque ya se ha hecho con el primer idioma.
            ld_primer_source = abap_false.

          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.


  METHOD create_it_fcat.
    FIELD-SYMBOLS <ls_dlang> LIKE LINE OF mt_tlang.
    FIELD-SYMBOLS <ls_fcat> TYPE LINE OF lvc_t_fcat.
    DATA ls_fcat TYPE LINE OF lvc_t_fcat.
    DATA lo_main_fields TYPE REF TO data.
    DATA lt_fcat_aux TYPE lvc_t_fcat.
    DATA ld_col_pos TYPE i VALUE 1.

    FREE: mo_it_data, mo_wa_data.

* Se crea el objeto temporal con los campos base.
    CALL METHOD zcl_spt_translate_utilities=>create_wa_from_struc
      EXPORTING
        i_struc    = mv_struc_main_fields
      IMPORTING
        e_workarea = lo_main_fields.

* Recupero el catalogo de la tabla de campos
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name       = mv_struc_main_fields
        i_bypassing_buffer     = 'X'
      CHANGING
        ct_fieldcat            = mt_fcat[]
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.

* Se ajusta el catalogo de campos principal
    LOOP AT mt_fcat ASSIGNING <ls_fcat>.
      CASE <ls_fcat>-fieldname.
        WHEN 'TXT_OLANG'. " Texto origen
* Se pone el texto del idioma de origen
          READ TABLE mt_languages ASSIGNING FIELD-SYMBOL(<ls_languages>) WITH KEY lxe_language = mv_olang.
          IF sy-subrc = 0.
            CALL METHOD change_text_fcat(
              EXPORTING
                i_text = <ls_languages>-text_lang
              CHANGING
                c_fcat = <ls_fcat> ).
          ENDIF.
          <ls_fcat>-col_opt = abap_true.
      ENDCASE.

* Los campos principales son fijos para que se pueden ver en todo momento.
      <ls_fcat>-fix_column = abap_true.
      ADD 1 TO ld_col_pos.
    ENDLOOP.

* Construyo los campos que se añadirán a la tabla base para crear la principal
* Por cada idioma se ponen dos campos: 1) campo con el texto 2) indicador que se ha modificado el campo
    LOOP AT mt_tlang ASSIGNING <ls_dlang>.

* Campo con el texto
      CLEAR ls_fcat.
      ls_fcat-fieldname = get_name_field_text( <ls_dlang> ).
*    ls_fcat-rollname = 'LXEUNITLIN'.
      ls_fcat-inttype = 'C'.
      ls_fcat-intlen = '255'.
      ls_fcat-lowercase = abap_true.
      ls_fcat-edit = abap_true.
      ls_fcat-col_opt = abap_true.
      ls_fcat-col_pos = ld_col_pos.

* Texto del campo
      READ TABLE mt_languages ASSIGNING <ls_languages> WITH KEY lxe_language = <ls_dlang>.
      IF sy-subrc = 0.
        CALL METHOD change_text_fcat(
          EXPORTING
            i_text = <ls_languages>-text_lang
          CHANGING
            c_fcat = ls_fcat ).
      ELSE.
        CALL METHOD change_text_fcat(
          EXPORTING
            i_text = <ls_dlang>
          CHANGING
            c_fcat = ls_fcat ).
      ENDIF.
      APPEND ls_fcat TO lt_fcat_aux.
      ADD 1 TO ld_col_pos.

* Campo de control
      CLEAR ls_fcat.
      ls_fcat-fieldname = get_name_field_ctrl( <ls_dlang> ).
      ls_fcat-rollname = 'SAP_BOOL'.
      ls_fcat-tech = abap_true.
      ls_fcat-col_pos = ld_col_pos.
      APPEND ls_fcat TO lt_fcat_aux.
      ADD 1 TO ld_col_pos.

      " Campo para indicar el tipo de texto en la propuesta.
      INSERT VALUE #( fieldname = get_name_field_ppsal_type( <ls_dlang> )
                      rollname = |ZSPT_E_TEXT_PROPOSAL_TYPE|
                      tech = abap_true
                      col_pos = ld_col_pos ) INTO TABLE lt_fcat_aux.
      ld_col_pos = ld_col_pos + 1.
    ENDLOOP.

* Se añaden los campos de idioma al catalogo de campos principal
    APPEND LINES OF lt_fcat_aux TO mt_fcat.

* Se crea la tabla interna en base a los campos principales + los de idioma
    CALL METHOD zcl_spt_translate_utilities=>create_it_fields_base_ref
      EXPORTING
        i_base_fields = lo_main_fields
        i_new_fields  = lt_fcat_aux
      IMPORTING
        e_table       = mo_it_data
        e_wa          = mo_wa_data.

  ENDMETHOD.


  METHOD fill_return.

    CLEAR r_return.

    r_return-type = i_type.

    r_return-number = i_number.
    r_return-message_v1 = i_message_v1.
    r_return-message_v2 = i_message_v2.
    r_return-message_v3 = i_message_v3.
    r_return-message_v4 = i_message_v4.

    r_return-message = zcl_spt_utilities=>fill_return(
      EXPORTING
        iv_type       = i_type
        iv_id         = COND #( WHEN i_id IS NOT SUPPLIED THEN 'ZSPT_TRANSLATE_TOOL' ELSE i_id )
        iv_number     = i_number
        iv_message_v1 = i_message_v1
        iv_message_v2 = i_message_v2
        iv_message_v3 = i_message_v3
        iv_message_v4 = i_message_v4
        iv_langu = iv_langu )-message.

  ENDMETHOD.


  METHOD get_allowed_objects.
    FIELD-SYMBOLS <ls_object_list> LIKE LINE OF mt_object_list.
    DATA ls_objects TYPE LINE OF tr_object_texts.

    CLEAR rt_objects.
    LOOP AT mt_object_list ASSIGNING <ls_object_list>.
      MOVE-CORRESPONDING <ls_object_list> TO ls_objects.
      APPEND ls_objects TO rt_objects.
      CLEAR ls_objects.
    ENDLOOP.

    SORT rt_objects BY pgmid object.

  ENDMETHOD.


  METHOD get_components.
    FIELD-SYMBOLS <ls_components> TYPE LINE OF zcl_spt_translate_cmp=>tt_components.
    FIELD-SYMBOLS <ls_object_list> LIKE LINE OF mt_object_list.
    DATA ls_main_fields TYPE LINE OF tt_main_fields.
    DATA lt_components TYPE zcl_spt_translate_cmp=>tt_components.


    READ TABLE mt_object_list ASSIGNING <ls_object_list> WITH KEY object = mv_object.
    IF sy-subrc = 0.

* Paso los parámetros para condicionar la búsqueda.
      <ls_object_list>-ref_class->set_params( EXPORTING iv_depth_refs = mv_depth_refs ).

* Obtengo el componentes del objeto a traducir.
      <ls_object_list>-ref_class->get_components( IMPORTING et_components = lt_components ).

* Paso los components al parámetro de salida
      LOOP AT lt_components ASSIGNING <ls_components>.
        MOVE-CORRESPONDING <ls_components> TO ls_main_fields.
        APPEND ls_main_fields TO e_components.
      ENDLOOP.

    ENDIF.

  ENDMETHOD.


  METHOD get_data.
    ro_data = mo_it_data.
  ENDMETHOD.


  METHOD get_fcat.
    rt_fcat = mt_fcat.
  ENDMETHOD.


  METHOD get_languages.
    rt_languages = mt_languages.
  ENDMETHOD.


  METHOD get_name_field_ctrl.
    CONCATENATE cs_fields_itab-ctrl_lang i_language INTO r_fieldname.
    TRANSLATE r_fieldname TO UPPER CASE.
  ENDMETHOD.


  METHOD get_name_field_ppsal_type.
    rv_fieldname = |{ cs_fields_itab-ppsal_type }_{ iv_language }|.
    rv_fieldname = |{ rv_fieldname CASE = UPPER }|.
  ENDMETHOD.


  METHOD get_name_field_text.
    CONCATENATE cs_fields_itab-txt_lang iv_language INTO rv_fieldname.
    TRANSLATE rv_fieldname TO UPPER CASE.
  ENDMETHOD.


  METHOD get_ref_text_object.
    FIELD-SYMBOLS <ls_mngt_text> LIKE LINE OF mt_mngt_text.
    FIELD-SYMBOLS <ls_lxe_list> LIKE LINE OF mt_lxe_list.
    DATA ls_mngt_text LIKE LINE OF mt_mngt_text.

* Miro si el objeto ya ha sido instancio previamente. Si no es así, se crea.
    READ TABLE mt_mngt_text ASSIGNING <ls_mngt_text>
                            WITH TABLE KEY object = i_object
                                           obj_name = i_obj_name
                                           tlang = i_tlang.
    IF sy-subrc NE 0.
* Se pasa los datos a la tabla que contendrá el objetos de textos en cada
* idioma para cada objeto.
      ls_mngt_text-tlang = i_tlang.
      ls_mngt_text-object = i_object.
      ls_mngt_text-obj_name = i_obj_name.

* Recupero la clase que servirá para traducir el objeto.
      READ TABLE mt_lxe_list ASSIGNING <ls_lxe_list> WITH KEY object = i_object.
      IF sy-subrc = 0.
* Instancio el objeto que hará la traduccion
        CREATE OBJECT ls_mngt_text-oobject TYPE (<ls_lxe_list>-class).

* Valido que el objeto sea valido.
        CALL METHOD ls_mngt_text-oobject->set_check_params
          EXPORTING
            iv_object        = i_object
            iv_obj_name      = i_obj_name
            iv_olang         = mv_olang
            iv_tlang         = i_tlang
          EXCEPTIONS
            object_not_valid = 1
            OTHERS           = 2.
        IF sy-subrc = 0.
* Se añade el nuevo registro
          INSERT ls_mngt_text INTO TABLE mt_mngt_text.

* Y se devuelve el objeto.
          e_object = ls_mngt_text-oobject.
        ENDIF.
      ENDIF.
    ELSE.
      e_object = <ls_mngt_text>-oobject.
    ENDIF.

  ENDMETHOD.


  METHOD get_task_from_order.
    DATA lt_req_head TYPE trwbo_request_headers.
    DATA lt_req TYPE trwbo_requests.

    DATA(lv_order) = iv_order.

    CLEAR: es_return, ev_task.

    CALL FUNCTION 'TR_READ_REQUEST_WITH_TASKS'
      EXPORTING
        iv_trkorr          = lv_order
      IMPORTING
        et_request_headers = lt_req_head
        et_requests        = lt_req
      EXCEPTIONS
        invalid_input      = 1
        OTHERS             = 2.
    IF sy-subrc = 0.
      " Se mira si hay alguna tarea valida para el usuario.
      LOOP AT lt_req_head ASSIGNING FIELD-SYMBOL(<ls_req_head>) WHERE trfunction = zcl_spt_trans_order_data=>cs_orders-type-development
                                                        AND trstatus = zcl_spt_trans_order_data=>cs_orders-status-changeable
                                                        AND as4user = sy-uname.
        EXIT.
      ENDLOOP.
      IF sy-subrc = 0.
        ev_task = <ls_req_head>-trkorr.
      ELSE.
        " Se busca la orden. Si la orden no tiene tareas entonces el primer registro que será el de la orden.
        LOOP AT lt_req_head ASSIGNING <ls_req_head> WHERE strkorr IS NOT INITIAL.
          EXIT.
        ENDLOOP.
        IF sy-subrc NE 0.
          ASSIGN lt_req_head[ 1 ] TO <ls_req_head>.
          <ls_req_head>-strkorr = lv_order.
        ENDIF.

        CALL FUNCTION 'TRINT_INSERT_NEW_COMM'
          EXPORTING
            wi_kurztext       = <ls_req_head>-as4text
            wi_trfunction     = zcl_spt_trans_order_data=>cs_orders-type-development
            iv_username       = sy-uname
            wi_strkorr        = <ls_req_head>-strkorr
            wi_client         = sy-mandt
          IMPORTING
            we_trkorr         = ev_task
          EXCEPTIONS
            no_systemname     = 1
            no_systemtype     = 2
            no_authorization  = 3
            db_access_error   = 4
            file_access_error = 5
            enqueue_error     = 6
            number_range_full = 7
            invalid_input     = 8
            OTHERS            = 9.
        IF sy-subrc NE 0.
          es_return = fill_return( i_type       = 'E'
                                i_number     = sy-msgno
                                i_message_v1 = sy-msgv1
                                i_message_v2 = sy-msgv2
                                i_message_v3 = sy-msgv3
                                i_message_v4 = sy-msgv4
                                i_id         = sy-msgid ).
        ENDIF.
      ENDIF.
    ELSE.
      es_return = fill_return( i_type       = 'E'
                                    i_number     = sy-msgno
                                    i_message_v1 = sy-msgv1
                                    i_message_v2 = sy-msgv2
                                    i_message_v3 = sy-msgv3
                                    i_message_v4 = sy-msgv4
                                    i_id         = sy-msgid ).
    ENDIF.

  ENDMETHOD.


  METHOD get_tlang.
    rt_tlang = mt_tlang.
  ENDMETHOD.


  METHOD load_object_texts.
    CLEAR mt_components.

* Se crea la tabla interna en base al catalogo de campos y textos a traduccion
    create_it_fcat( ).

* Componentes del objeto.
    get_components( IMPORTING e_components = mt_components ).

* Lectura y proceso de los textos
    read_process_texts( ).

  ENDMETHOD.


  METHOD proposal_text.
    FIELD-SYMBOLS <field> TYPE any.
    FIELD-SYMBOLS <field_style> TYPE ANY TABLE.
    DATA ld_field_text TYPE fieldname.
    DATA ls_field_style TYPE LINE OF lvc_t_styl.

    ld_field_text = get_name_field_text( i_tlang ).
    ASSIGN COMPONENT ld_field_text OF STRUCTURE cs_wa TO <field>.
    IF sy-subrc = 0.

      ASSIGN COMPONENT get_name_field_ppsal_type( i_tlang ) OF STRUCTURE cs_wa TO FIELD-SYMBOL(<ppsal_type>).

      IF <field> IS INITIAL.
* Recupero la mejor propuesta para el campo
        CALL METHOD io_object_text->get_best_text_proposal
          EXPORTING
            iv_textkey   = is_texts-textkey
            iv_objtype   = is_texts-objtype
          IMPORTING
            ev_best_text = <field>.
      ENDIF.

* Determino el estilo según el valor del campo
      ASSIGN COMPONENT mc_field_style OF STRUCTURE cs_wa TO <field_style>.
      IF sy-subrc = 0.
        ls_field_style-fieldname = ld_field_text.
* Si no hay texto ni por propuesta ni por origen se pone el color de no hay traduccion
        IF <field> IS INITIAL.
          ls_field_style-style = mc_style_wo_trans.
          IF <ppsal_type> IS ASSIGNED.
            <ppsal_type> = cs_text_ppsal_type-without_text.
          ENDIF.
* Si hay texto por la propuesta pero el original no lo tenia, se pone el texto de pdte de confirmacion.
        ELSEIF is_texts-t_text IS INITIAL.
          ls_field_style-style = mc_style_prop_wo_conf.
          IF <ppsal_type> IS ASSIGNED.
            <ppsal_type> = cs_text_ppsal_type-ppsal_wo_confirm.
          ENDIF.
        ELSE.
* Si el texto esta informado compruebo si el texto esta dentro de las propuestas
* para el texto. Según el resultado el color de la celda varia.
          IF io_object_text->is_text_in_proposal( iv_text = <field>
                                                        iv_textkey = is_texts-textkey
                                                        iv_objtype = is_texts-objtype ) = abap_true.
            ls_field_style-style = mc_style_prop_conf.
            IF <ppsal_type> IS ASSIGNED.
              <ppsal_type> = cs_text_ppsal_type-ppsal_confirmed.
            ENDIF.
          ELSE.
            ls_field_style-style = mc_style_prop_wo_conf.
            IF <ppsal_type> IS ASSIGNED.
              <ppsal_type> = cs_text_ppsal_type-ppsal_wo_confirm.
            ENDIF.
          ENDIF.
        ENDIF.
        INSERT ls_field_style INTO TABLE <field_style>.
        CLEAR ls_field_style.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD read_languages.

    SELECT r3_lang language AS lxe_language text_lang langshort AS language INTO CORRESPONDING FIELDS OF TABLE mt_languages
           FROM lxe_t002x
           WHERE is_r3_lang = abap_true
                AND r3_lang NE ''.

    LOOP AT mt_languages ASSIGNING FIELD-SYMBOL(<ls_languages>).
      <ls_languages>-lxe_language_sort = |{ <ls_languages>-lxe_language CASE = UPPER }|.
    ENDLOOP.
  ENDMETHOD.


  METHOD read_process_texts.
    FIELD-SYMBOLS <tbl> TYPE table.
    FIELD-SYMBOLS <wa> TYPE any.
    FIELD-SYMBOLS <field> TYPE any.
    FIELD-SYMBOLS <ls_tlang> LIKE LINE OF mt_tlang.
    FIELD-SYMBOLS <ls_texts> TYPE zcl_spt_translate_lxe=>ts_texts.
    DATA ls_main_fields TYPE LINE OF tt_main_fields.
    DATA lt_main_fields TYPE tt_main_fields.
    DATA lo_data TYPE REF TO data.
    DATA ld_tabix TYPE sytabix.
    DATA lt_texts TYPE zcl_spt_translate_lxe=>tt_texts.
    DATA ld_primer_source TYPE sap_bool.
    DATA ld_field_text TYPE fieldname.
    DATA lo_text_object TYPE REF TO zcl_spt_translate_lxe.

    ASSIGN mo_it_data->* TO <tbl>.

    CLEAR <tbl>.

    LOOP AT mt_components INTO ls_main_fields.

* En el primer texto informaré tanto el idioma de origen como el destino.
* a partir del segundo idioma de destino solo leerá el de destino.
      ld_primer_source = abap_true.

* Se recorre la tabla de idioma a traducir.
      LOOP AT mt_tlang ASSIGNING <ls_tlang>.
        CLEAR: lt_texts.

* Se recupera el objeto de texto para obtener las traducciones
        CALL METHOD get_ref_text_object
          EXPORTING
            i_object   = ls_main_fields-object
            i_obj_name = ls_main_fields-obj_name
            i_tlang    = <ls_tlang>
          IMPORTING
            e_object   = lo_text_object.

        IF lo_text_object IS BOUND.

* Carga de textos y recuperacion de los textos
          lo_text_object->load_text( ).
          lo_text_object->get_texts( IMPORTING et_texts = lt_texts ).

* Solo se tienen en cuanta los objetos con textos.
          IF lt_texts IS NOT INITIAL.

* Recorro la tabla de textos para pasarla a la de datos.
            LOOP AT lt_texts ASSIGNING <ls_texts>.
              ls_main_fields-id_text = <ls_texts>-textkey. " Id del texto
              ls_main_fields-objtype = <ls_texts>-objtype. " Tipo de objeto

              IF ld_primer_source = abap_true.
                ls_main_fields-txt_olang = <ls_texts>-s_text.
              ENDIF.

* Leo si el para el objeto e id de texto esta en la tabla que guarda de manera temporal lo mismo(campos principales) que la
* tabla global dinámica. Esta tabla permite evitar duplicados o más cuando hay varios idiomas a traducir para un mismo objeto.
              READ TABLE lt_main_fields TRANSPORTING NO FIELDS WITH KEY object = ls_main_fields-object
                                                                        obj_name = ls_main_fields-obj_name
                                                                        id_text = ls_main_fields-id_text
                                                                        objtype = ls_main_fields-objtype.
              IF sy-subrc = 0.
* Me guardo la posicion donde se ha encontrado.
                ld_tabix = sy-tabix.
* Los registros de la tabla local y temporal siempre coinciden porque se añaden los mismos datos.
                READ TABLE <tbl> ASSIGNING <wa> INDEX ld_tabix.
              ELSE.
                CLEAR ld_tabix.
* Reasigno la cabecera para limpiar valores previos.
                ASSIGN mo_wa_data->* TO <wa>.
                APPEND ls_main_fields TO lt_main_fields.
* Paso los datos comunes a la cabecera de la tabla de datos
                MOVE-CORRESPONDING ls_main_fields TO <wa>.
              ENDIF.

* Construyo el campo donde se pondra el texto destino
              ld_field_text = get_name_field_text( <ls_tlang> ).
              ASSIGN COMPONENT ld_field_text OF STRUCTURE <wa> TO <field>.
              IF sy-subrc = 0.
                <field> = <ls_texts>-t_text.

* Si el objeto tiene propuesta de textos se rellena los datos con la propuesta del
* texto. Si no hay texto y hay propuesta se pone el de la propuesta.
* Hay objetos que no tienen propuesta de texto como los formularios.
                IF lo_text_object->has_proposed_text( ) = abap_true.
                  CALL METHOD proposal_text
                    EXPORTING
                      i_tlang        = <ls_tlang>
                      is_texts       = <ls_texts>
                      io_object_text = lo_text_object
                    CHANGING
                      cs_wa          = <wa>.
                ELSE.
                  ASSIGN COMPONENT get_name_field_ppsal_type( <ls_tlang> ) OF STRUCTURE <wa> TO FIELD-SYMBOL(<ppsal_type>).
                  <ppsal_type> = cs_text_ppsal_type-without_text.
                ENDIF.

* Si el objeto e id de texto no esta en la tabla temporal, muevo los campos principales
* a la cabecera y añado los datos.
                IF ld_tabix IS INITIAL.
                  APPEND <wa> TO <tbl>.
                  CLEAR <wa>.
                ENDIF.

              ENDIF.

            ENDLOOP.

* Marco para que el texto de origen no se vuelva a pasar porque ya se ha hecho con el primer idioma.
            ld_primer_source = abap_false.

          ENDIF.
        ENDIF.

      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.


  METHOD save_data.
    FIELD-SYMBOLS <ls_mngt_text> TYPE LINE OF tt_mngt_text.


    CLEAR rs_return.

* Primero se actualizan los textos en la tabla interna donde contiene los objetos de textos
* de cada objeto.
    update_text_object( ).

* Se recorre la tabla donde contiene la gestion de los propios textos para grabarla.
* Eso si, solo aquellos que se han modificados.
    LOOP AT mt_mngt_text ASSIGNING <ls_mngt_text> WHERE data_changed = abap_true.

* Solo se graban los datos modificados.
      CALL METHOD <ls_mngt_text>-oobject->save_text
        EXCEPTIONS
          error_save = 1
          OTHERS     = 2.

* Cualquier error se almacena en a estructura de salida y se sale.
      IF sy-subrc NE 0.
        rs_return = fill_return( i_type = 'E'
                                i_number = '006'
                                i_message_v1 = <ls_mngt_text>-object
                                i_message_v2 = <ls_mngt_text>-obj_name ).
        EXIT.
      ENDIF.

    ENDLOOP.

* Si no hay errores en la grabación devuelvo un mensaje indicado del
* éxito de la operación.
    IF rs_return IS INITIAL.
      rs_return = fill_return( i_type = 'S'
                              i_number = '007'
                              i_message_v1 = mv_object
                                i_message_v2 = mv_obj_name ).

* Se vuelven a leer los textos por dos motivos:
* 1) En la SE63, Un campo nuevo en la pantalla de seleccion de un programa que
* referencia al diccionario aparece a traducir. Pero una vez realizada la
* traducción "desaparece".
* 2) Ajuste de estilos en base a las propuestas.
* Sobretodo por el punto 1 y casos parecidos que puedan ocurrir, lo mejor es leer de nuevo
* y refrescar contenido.
      read_process_texts( ).

    ENDIF.

  ENDMETHOD.


  METHOD set_data.
    mo_it_data = it_data.
  ENDMETHOD.


  METHOD set_params_selscreen.

    mv_olang = iv_olang. " Idioma origen
    mt_tlang = it_tlang. " Idioma destino.
    mv_trkorr = iv_trkorr. " Orden de transporte
    " Nivel de búsqueda de objetos a traducir a partir del objeto principal-
    mv_depth_refs = iv_depth_refs.

  ENDMETHOD.


  METHOD transport_mod_obj.
    FIELD-SYMBOLS <ls_mngt_text> TYPE LINE OF tt_mngt_text.

    CLEAR es_return.

    IF mv_trkorr IS NOT INITIAL.

* Solo se transportan los objetos modificados
      LOOP AT mt_mngt_text ASSIGNING <ls_mngt_text> WHERE data_changed = abap_true.
* Una vez grabado en la orden de transporte quito la marca de modificado.
        <ls_mngt_text>-data_changed = abap_false.

* El transporte se realiza desde la propia clase que gestiona los textos.
        CALL METHOD <ls_mngt_text>-oobject->transport_translate
          EXPORTING
            iv_trkorr           = mv_trkorr
          EXCEPTIONS
            error_insert_trkorr = 1
            OTHERS              = 2.
        IF sy-subrc <> 0.
          es_return = fill_return( i_type = 'W'
                                  i_id = sy-msgid
                                  i_number = sy-msgno
                                  i_message_v1 = sy-msgv1
                                  i_message_v2 = sy-msgv2
                                  i_message_v3 = sy-msgv3
                                  i_message_v4 = sy-msgv4  ).
          EXIT.

        ENDIF.
      ENDLOOP.
      IF sy-subrc = 0.
* Si hay datos y no hay errores saco un mensaje informativo de que todo ha ido bien.
        IF es_return IS INITIAL.
          es_return = fill_return( i_type = 'S'
                                  i_number = '008'
                                  i_message_v1 = mv_trkorr ).

* Para evitar que se van acumulando los mismos objetos en la orden, llamo a la funcion
* que ordena y clasifica (elimina duplicados) de la orden/tarea pasada.
* NOTA: Creo que no es necesario porque al hacer pruebas no ha habido duplicado, pero
* lo dejo por si se meten entradas manuales o de otra forma haciendo duplicados.
          CALL FUNCTION 'TR_SORT_AND_COMPRESS_COMM'
            EXPORTING
              iv_trkorr                      = mv_trkorr
            EXCEPTIONS
              trkorr_not_found               = 1
              order_released                 = 2
              error_while_modifying_obj_list = 3
              tr_enqueue_failed              = 4
              no_authorization               = 5
              OTHERS                         = 6.

        ENDIF.
* Si no se han modificados datos también lo aviso.
      ELSE.
        es_return = fill_return( i_type = 'S'
                                i_number = '011' ).

      ENDIF.
    ELSE.
* Si no hay orden se devuelve un mensaje adviertiendolo
      es_return = fill_return( i_type = 'S'
                              i_number = '009' ).
    ENDIF.
  ENDMETHOD.


  METHOD update_text_object.
    FIELD-SYMBOLS <tbl> TYPE ANY TABLE.
    FIELD-SYMBOLS <wa> TYPE any.
    FIELD-SYMBOLS <field> TYPE any.
    FIELD-SYMBOLS <ls_tlang> TYPE any.
    FIELD-SYMBOLS <ls_mngt_text> TYPE LINE OF tt_mngt_text.
    DATA ls_main_fields TYPE ts_main_fields.
    DATA ld_fieldname TYPE fieldname.

    ASSIGN mo_it_data->* TO <tbl>.
    ASSIGN mo_wa_data->* TO <wa>.

    LOOP AT <tbl> ASSIGNING <wa>.

* Paso los datos a una estructura base para poder simplificar el codigo.
      MOVE-CORRESPONDING <wa> TO ls_main_fields.

* Por cada registro leo los lenguajes a traducir para ver cual de ellos ha sido modificado.
      LOOP AT mt_tlang ASSIGNING <ls_tlang>.

* Recupero el campo del control del idioma para ver si se ha modificado.
        ld_fieldname = get_name_field_ctrl( <ls_tlang> ).
        ASSIGN COMPONENT ld_fieldname OF STRUCTURE <wa> TO <field>.
        IF sy-subrc = 0.
          IF <field> = abap_true.

* Quito la marca de campo modificado para que no vuelva a entrar si se cambia otro campo.
            <field> = abap_false.

* Recupero el texto del idioma para informa a la tabla donde están los textos
            ld_fieldname = get_name_field_text( <ls_tlang> ).
            ASSIGN COMPONENT ld_fieldname OF STRUCTURE <wa> TO <field>.
            IF sy-subrc = 0.

* Busqueda de del objeto del texto
              READ TABLE mt_mngt_text ASSIGNING <ls_mngt_text>
                                      WITH TABLE KEY object = ls_main_fields-object
                                                     obj_name = ls_main_fields-obj_name
                                                     tlang = <ls_tlang>.
              IF sy-subrc = 0.

* Indico que los datos se han actualizado para después saber si se han de grabar
                <ls_mngt_text>-data_changed = abap_true.
* Actualizacion
                CALL METHOD <ls_mngt_text>-oobject->set_text
                  EXPORTING
                    iv_id_text         = ls_main_fields-id_text
                    iv_objtype         = ls_main_fields-objtype
                    iv_text            = <field>
                  EXCEPTIONS
                    id_text_dont_exist = 1
                    OTHERS             = 2.

              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.
  METHOD add_objects_transp_req.

    CLEAR: et_return.

    DATA(lv_added_objects) = abap_false.
    LOOP AT mt_tlang ASSIGNING FIELD-SYMBOL(<ls_tlang>).
      ASSIGN mt_languages[ lxe_language = <ls_tlang> ] TO FIELD-SYMBOL(<ls_language>).
      IF sy-subrc = 0.
        LOOP AT it_objects ASSIGNING FIELD-SYMBOL(<ls_object>).


          get_ref_text_object(
            EXPORTING
              i_object   = <ls_object>-object
              i_obj_name = <ls_object>-obj_name
              i_tlang    = <ls_tlang>
            IMPORTING
              e_object   = DATA(lo_object)  ).
          IF lo_object IS BOUND.
            lo_object->transport_translate(
              EXPORTING
                iv_trkorr           = mv_trkorr
              EXCEPTIONS
                error_insert_trkorr = 1
                OTHERS              = 2 ).
            IF sy-subrc = 0.
              lv_added_objects = abap_true.
            ELSE.
              INSERT VALUE #( type = zcl_spt_core_data=>cs_message-type_error
                              message =  fill_return( i_number = sy-msgno
                                                      i_id = sy-msgid
                                                      i_message_v1 = sy-msgv1
                                                      i_message_v2 = sy-msgv2
                                                      i_message_v3 = sy-msgv3
                                                      i_message_v4 = sy-msgv4 )-message ) INTO TABLE et_return.
            ENDIF.
          ELSE.
            INSERT VALUE #( type = zcl_spt_core_data=>cs_message-type_error
                            message =  fill_return( i_number = '009' )-message ) INTO TABLE et_return.
          ENDIF.
        ENDLOOP.
      ELSE.
        INSERT VALUE #( type = zcl_spt_core_data=>cs_message-type_error
                                   message =  fill_return( i_number = '014'
                                                           i_message_v1 = <ls_tlang> )-message ) INTO TABLE et_return.
      ENDIF.
    ENDLOOP.

    " Quito duplicados por si hay mensajes de errores iguales al transportar.
    SORT et_return.
    DELETE ADJACENT DUPLICATES FROM et_return COMPARING ALL FIELDS.

    " Si al menos se añadido un objeto pongo un mensaje generico
    IF lv_added_objects = abap_true.
      INSERT VALUE #( type = zcl_spt_core_data=>cs_message-type_success
                      message =  fill_return( i_number = '008'
                                              i_message_v1 = mv_trkorr )-message ) INTO TABLE et_return.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
