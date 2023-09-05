CLASS zcl_zsap_tools_transla_dpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_zsap_tools_transla_dpc
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS /iwbep/if_mgw_appl_srv_runtime~create_deep_entity REDEFINITION.
  PROTECTED SECTION.
    METHODS languagesset_get_entityset REDEFINITION.
    METHODS selectableobject_get_entityset REDEFINITION.
    METHODS checkobjectset_get_entity REDEFINITION.
    METHODS checkorderset_get_entity REDEFINITION.

  PRIVATE SECTION.
    DATA mo_translate TYPE REF TO zcl_spt_translate_tool.
    METHODS objecttranslate_entity
      IMPORTING
        iv_entity_name          TYPE string
        iv_entity_set_name      TYPE string
        iv_source_name          TYPE string
        io_data_provider        TYPE REF TO /iwbep/if_mgw_entry_provider
        it_key_tab              TYPE /iwbep/t_mgw_name_value_pair
        it_navigation_path      TYPE /iwbep/t_mgw_navigation_path
        io_expand               TYPE REF TO /iwbep/if_mgw_odata_expand
        io_tech_request_context TYPE REF TO /iwbep/if_mgw_req_entity_c
      EXPORTING
        er_deep_entity          TYPE REF TO data
      RAISING
        /iwbep/cx_mgw_busi_exception
        /iwbep/cx_mgw_tech_exception .
    METHODS adapt_objects_text_2_service
      IMPORTING
        it_languages TYPE zcl_spt_translate_tool=>tt_languages
      CHANGING
        cs_data      TYPE zcl_zsap_tools_transla_mpc_ext=>ts_objecttranlsate_deep.
    METHODS get_objecttext
      CHANGING
        cs_data TYPE zcl_zsap_tools_transla_mpc_ext=>ts_objecttranlsate_deep
      RAISING
        /iwbep/cx_mgw_busi_exception
        /iwbep/cx_mgw_tech_exception .
    METHODS save_objecttext
      CHANGING
        cs_data TYPE zcl_zsap_tools_transla_mpc_ext=>ts_objecttranlsate_deep
      RAISING
        /iwbep/cx_mgw_busi_exception
        /iwbep/cx_mgw_tech_exception.
    METHODS convert_and_check_objecttext
      CHANGING
        cs_data TYPE zcl_zsap_tools_transla_mpc_ext=>ts_objecttranlsate_deep
      RAISING
        /iwbep/cx_mgw_busi_exception
        /iwbep/cx_mgw_tech_exception.
    METHODS adapt_objects_service_2_text
      IMPORTING
        it_languages TYPE zcl_spt_translate_tool=>tt_languages
      CHANGING
        cs_data      TYPE zcl_zsap_tools_transla_mpc_ext=>ts_objecttranlsate_deep.
ENDCLASS.



CLASS zcl_zsap_tools_transla_dpc_ext IMPLEMENTATION.
  METHOD languagesset_get_entityset.

    DATA(lo_translate) = NEW zcl_spt_translate_tool(  ).

    DATA(lt_languages) = lo_translate->get_languages(  ).

    et_entityset = CORRESPONDING #( lt_languages ).

    TRY.
        et_entityset[ r3_lang = sy-langu ]-is_system_language = abap_true.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

  ENDMETHOD.

  METHOD selectableobject_get_entityset.
    DATA(lo_translate) = NEW zcl_spt_translate_tool(  ).

    et_entityset = lo_translate->get_allowed_objects(  ).
  ENDMETHOD.



  METHOD /iwbep/if_mgw_appl_srv_runtime~create_deep_entity.
    CASE iv_entity_name.
      WHEN 'objectTranslate'.
        objecttranslate_entity(
          EXPORTING
            iv_entity_name               = iv_entity_name
            iv_entity_set_name           = iv_entity_set_name
            iv_source_name               = iv_source_name
            io_data_provider             = io_data_provider
            it_key_tab                   = it_key_tab
            it_navigation_path           = it_navigation_path
            io_expand                    = io_expand
            io_tech_request_context      = io_tech_request_context
          IMPORTING
            er_deep_entity               = er_deep_entity ).
    ENDCASE.

  ENDMETHOD.


  METHOD objecttranslate_entity.

    DATA ls_data TYPE zcl_zsap_tools_transla_mpc_ext=>ts_objecttranlsate_deep.

    mo_translate = NEW zcl_spt_translate_tool(  ).

    io_data_provider->read_entry_data( IMPORTING es_data = ls_data ).

    convert_and_check_objecttext( CHANGING cs_data = ls_data ).

    CASE ls_data-action.
      WHEN 'GET'.
        get_objecttext( CHANGING cs_data = ls_data ).
      WHEN 'SAVE'.
        save_objecttext( CHANGING cs_data = ls_data ).
    ENDCASE.

    CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
      EXPORTING
        is_data = ls_data
      CHANGING
        cr_data = er_deep_entity.


  ENDMETHOD.


  METHOD adapt_objects_text_2_service.
    FIELD-SYMBOLS <tbl> TYPE STANDARD TABLE.

    DATA(lo_data) = mo_translate->get_data( ).
    DATA(lt_fcat) = mo_translate->get_fcat( ).

    ASSIGN lo_data->* TO <tbl>.

    DATA(lv_col_olang) = lt_fcat[ fieldname = 'TXT_OLANG' ]-reptext.
    SPLIT cs_data-tlang AT '-' INTO TABLE DATA(lt_lang_serv).

    LOOP AT <tbl> ASSIGNING FIELD-SYMBOL(<wa>).

      DATA(ls_main_field) = CORRESPONDING zspt_translate_main_fields( <wa> ).

      " Texto en idioma origen
      INSERT CORRESPONDING #( ls_main_field ) INTO TABLE cs_data-objecttextset ASSIGNING FIELD-SYMBOL(<ls_texts>).
      <ls_texts>-col_olang = lv_col_olang.
      <ls_texts>-lang_olang = it_languages[ language = cs_data-olang ]-lxe_language.

      " Texto idioma destino
      DATA(lv_count) = 1.
      LOOP AT lt_lang_serv ASSIGNING FIELD-SYMBOL(<ls_tlang>).
        ASSIGN it_languages[ language = <ls_tlang> ] TO FIELD-SYMBOL(<ls_language>).
        IF sy-subrc = 0.
          DATA(lv_fieldname) = zcl_spt_translate_tool=>get_name_field_text( <ls_language>-lxe_language ).

          ASSIGN COMPONENT lv_fieldname OF STRUCTURE <wa> TO FIELD-SYMBOL(<txt_tlang>).
          IF sy-subrc = 0.
            ASSIGN lt_fcat[ fieldname = lv_fieldname ] TO FIELD-SYMBOL(<ls_fcat>).
            IF sy-subrc = 0.

              ASSIGN COMPONENT |LANG_TLANG{ lv_count }| OF STRUCTURE <ls_texts> TO FIELD-SYMBOL(<langt_lang>).
              IF sy-subrc = 0.
                <langt_lang> = <ls_language>-lxe_language.
              ENDIF.

              ASSIGN COMPONENT |COL_TLANG{ lv_count }| OF STRUCTURE <ls_texts> TO FIELD-SYMBOL(<col_tlang_serv>).
              IF sy-subrc = 0.
                <col_tlang_serv> = <ls_fcat>-reptext.
              ENDIF.

              ASSIGN COMPONENT |TXT_TLANG{ lv_count }| OF STRUCTURE <ls_texts> TO FIELD-SYMBOL(<txt_tlang_serv>).
              IF sy-subrc = 0.
                <txt_tlang_serv> = <txt_tlang>.
              ENDIF.

              ASSIGN COMPONENT zcl_spt_translate_tool=>get_name_field_ppsal_type( <ls_language>-lxe_language ) OF STRUCTURE <wa> TO FIELD-SYMBOL(<ppsal_type>).
              IF sy-subrc = 0.
                ASSIGN COMPONENT |PPSAL_TYPE_TLANG{ lv_count }| OF STRUCTURE <ls_texts> TO FIELD-SYMBOL(<ppsal_type_tlang>).
                IF sy-subrc = 0.
                  <ppsal_type_tlang> = <ppsal_type>.
                ENDIF.

              ENDIF.

              lv_count = lv_count + 1.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.


    ENDLOOP.

  ENDMETHOD.


  METHOD get_objecttext.

    CLEAR: cs_data-objecttextset.

    adapt_objects_text_2_service( EXPORTING it_languages = mo_translate->get_languages( )
                                  CHANGING cs_data = cs_data ).


  ENDMETHOD.


  METHOD save_objecttext.

    adapt_objects_service_2_text( EXPORTING it_languages = mo_translate->get_languages( )
                                  CHANGING cs_data = cs_data ).

    DATA(ls_return) = mo_translate->save_data( ).

    INSERT VALUE #( type = ls_return-type
                    message = ls_return-message ) INTO TABLE cs_data-returnset.

    IF ls_return-type = 'S'.

      IF cs_data-order IS NOT INITIAL.
        mo_translate->transport_mod_obj(
          IMPORTING
            es_return = ls_return ).

        INSERT VALUE #( type = ls_return-type
                message = ls_return-message ) INTO TABLE cs_data-returnset.
      ENDIF.

      " Cuando se graba se releen los datos para actualizar los estados de las propuestas de textos.
      " Por ello tengo que volcar de nuevo los datos a la tabla del servicio.
      CLEAR cs_data-objecttextset.
      adapt_objects_text_2_service(
        EXPORTING
          it_languages = mo_translate->get_languages( )
        CHANGING
          cs_data      = cs_data ).

    ENDIF.

  ENDMETHOD.


  METHOD convert_and_check_objecttext.
    DATA lt_tlang TYPE lxe_tt_lxeisolang.

    DATA(message_container) = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

    IF mo_translate->check_obj_2_trans( EXPORTING iv_object  = cs_data-object
                                                    iv_obj_name = cs_data-obj_name ).

      DATA(lv_errors) = abap_false.
      DATA(lt_languages) = mo_translate->get_languages(  ).

      " Se convierte y valida que exista el idioma de original
      ASSIGN lt_languages[ language = cs_data-olang ] TO FIELD-SYMBOL(<ls_language>).
      IF sy-subrc = 0.
        DATA(lv_olang) = <ls_language>-lxe_language.
      ELSE.
        lv_errors = abap_true.
        message_container->add_messages_from_bapi(
          EXPORTING
            it_bapi_messages          =  VALUE #( ( mo_translate->fill_return( i_number = '003'
                                                                               i_id = 'LXE_TRANS'
                                                                               i_type = 'E'
                                                                               i_message_v1 = cs_data-olang ) ) ) ).
      ENDIF.

      SPLIT cs_data-tlang AT '-' INTO TABLE DATA(lt_lang_serv).

      LOOP AT lt_lang_serv ASSIGNING FIELD-SYMBOL(<ls_tlang_serv>).
        ASSIGN lt_languages[ language = <ls_tlang_serv> ] TO <ls_language>.
        IF sy-subrc = 0.
          INSERT <ls_language>-lxe_language INTO TABLE lt_tlang.
        ELSE.
          lv_errors = abap_true.
          message_container->add_messages_from_bapi(
            EXPORTING
              it_bapi_messages          =  VALUE #( ( mo_translate->fill_return( i_number = '003'
                                                                                 i_id = 'LXE_TRANS'
                                                                                 i_type = 'E'
                                                                                 i_message_v1 = <ls_tlang_serv> ) ) ) ).
        ENDIF.
      ENDLOOP.

      " La orden es opcional
      IF cs_data-order IS NOT INITIAL.

        mo_translate->get_task_from_order(
          EXPORTING
            iv_order  = cs_data-order
          IMPORTING
            ev_task   = cs_data-order
            es_return = DATA(ls_return_order)
        ).
        IF ls_return_order IS NOT INITIAL.
          lv_errors = abap_true.
          message_container->add_messages_from_bapi(
           EXPORTING
             it_bapi_messages          =  VALUE #( ( ls_return_order ) ) ).
        ENDIF.
      ENDIF.

      " Lo mismo con el nivel de profundidad en la traducción, por defecto será 1.
      DATA(lv_depth_refs) = 1.
      cs_data-depth_refs = COND #( WHEN cs_data-depth_refs IS INITIAL THEN 1 ELSE cs_data-depth_refs ).


      IF lv_errors = abap_true.
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            message_container = message_container.
      ELSE.
        mo_translate->set_params_selscreen(
          EXPORTING
            iv_olang      = lv_olang
            it_tlang      = lt_tlang
            iv_trkorr     = cs_data-order
            iv_depth_refs = CONV #( cs_data-depth_refs ) ).

        mo_translate->load_object_texts( ).

      ENDIF.
    ELSE.

      message_container->add_messages_from_bapi(
        EXPORTING
          it_bapi_messages          =  VALUE #( ( mo_translate->fill_return( i_number = '004'
                                                                             i_type = 'E'
                                                                             i_message_v1 = cs_data-object
                                                                             i_message_v2 = cs_data-obj_name ) ) ) ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = message_container.

    ENDIF.
  ENDMETHOD.


  METHOD adapt_objects_service_2_text.
    FIELD-SYMBOLS <tbl> TYPE STANDARD TABLE.

    DATA(lo_data) = mo_translate->get_data( ).
    ASSIGN lo_data->* TO <tbl>.

    LOOP AT cs_data-objecttextset ASSIGNING FIELD-SYMBOL(<ls_objecttext>).

      READ TABLE <tbl> ASSIGNING FIELD-SYMBOL(<wa>) WITH KEY ('OBJECT') = <ls_objecttext>-object
                                                             ('OBJ_NAME') = <ls_objecttext>-obj_name
                                                             ('OBJTYPE') = <ls_objecttext>-objtype
                                                             ('ID_TEXT') = <ls_objecttext>-id_text.
      IF sy-subrc = 0.
        DATA(lv_count) = 1.
        DO.
          ASSIGN COMPONENT |LANG_TLANG{ lv_count }| OF STRUCTURE <ls_objecttext> TO FIELD-SYMBOL(<lang_tlang_serv>).
          IF sy-subrc = 0.
            IF <lang_tlang_serv> IS INITIAL.
              EXIT.
            ELSE.
              ASSIGN COMPONENT mo_translate->get_name_field_text( CONV #( <lang_tlang_serv> ) ) OF STRUCTURE <wa> TO FIELD-SYMBOL(<field_text>).
              IF sy-subrc = 0.
                ASSIGN COMPONENT |TXT_TLANG{ lv_count }| OF STRUCTURE <ls_objecttext> TO FIELD-SYMBOL(<text_tlang_serv>).
                IF <text_tlang_serv> NE <field_text>.
                  <field_text> = <text_tlang_serv>.

                  ASSIGN COMPONENT mo_translate->get_name_field_ctrl( CONV #( <lang_tlang_serv> ) ) OF STRUCTURE <wa> TO FIELD-SYMBOL(<field_ctrl>).
                  IF sy-subrc = 0.
                    <field_ctrl> = abap_true.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ELSE.
            EXIT.
          ENDIF.

          lv_count = lv_count + 1.
        ENDDO.
      ENDIF.
    ENDLOOP.

    mo_translate->set_data( lo_data ).

  ENDMETHOD.

  METHOD checkobjectset_get_entity.

    DATA(message_container) = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

    mo_translate = NEW #(  ).
    DATA(lv_object) = CONV trobjtype( it_key_tab[ name = 'object' ]-value ).
    DATA(lv_obj_name) = CONV sobj_name( it_key_tab[ name = 'objectName' ]-value ).

    IF mo_translate->check_obj_2_trans( EXPORTING iv_object  = lv_object
                                                      iv_obj_name = lv_obj_name ).
      er_entity-object = lv_object.
      er_entity-obj_name = lv_obj_name.
    ELSE.
      message_container->add_messages_from_bapi(
        EXPORTING
          it_bapi_messages          =  VALUE #( ( mo_translate->fill_return( i_number = '004'
                                                                             i_type = 'E'
                                                                             i_message_v1 = lv_object
                                                                             i_message_v2 = lv_obj_name ) ) ) ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = message_container.

    ENDIF.

  ENDMETHOD.

  METHOD checkorderset_get_entity.

    DATA(message_container) = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

    mo_translate = NEW #(  ).


    DATA(ls_return) = mo_translate->check_order( iv_order = CONV #( it_key_tab[ name = 'order' ]-value ) ).

    IF ls_return IS INITIAL .
      er_entity-order = it_key_tab[ name = 'order' ]-value.
    ELSE.

      message_container->add_messages_from_bapi(
        EXPORTING
          it_bapi_messages          =  VALUE #( ( ls_return ) ) ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = message_container.

    ENDIF.

  ENDMETHOD.

ENDCLASS.
