CLASS zcl_zsap_tools_transla_dpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_zsap_tools_transla_dpc
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS /iwbep/if_mgw_appl_srv_runtime~create_deep_entity REDEFINITION.
  PROTECTED SECTION.
    METHODS languagesset_get_entityset REDEFINITION.
    METHODS selectableobject_get_entityset REDEFINITION.

  PRIVATE SECTION.
    METHODS objecttext_entity
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
        io_data  TYPE REF TO data
        it_fcat  TYPE lvc_t_fcat
      EXPORTING
        et_texts TYPE zcl_zsap_tools_transla_mpc=>tt_objecttext.
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
        objecttext_entity(
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


  METHOD objecttext_entity.
    DATA lt_tlang TYPE lxe_tt_lxeisolang.
    DATA ls_data TYPE zcl_zsap_tools_transla_mpc_ext=>ts_objecttranlsate_deep.

    DATA(message_container) = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).
    io_data_provider->read_entry_data( IMPORTING es_data = ls_data ).

    DATA(lo_translate) = NEW zcl_spt_translate_tool(  ).


    IF lo_translate->check_obj_2_trans( EXPORTING iv_object  = ls_data-object
                                                  iv_obj_name = ls_data-obj_name ).

      DATA(lv_errors) = abap_false.
      DATA(lt_languages) = lo_translate->get_languages(  ).

      " Se convierte y valida que exista el idioma de original
      ASSIGN lt_languages[ language = ls_data-olang ] TO FIELD-SYMBOL(<ls_language>).
      IF sy-subrc = 0.
        DATA(lv_olang) = <ls_language>-lxe_language.
      ELSE.
        lv_errors = abap_true.
        message_container->add_messages_from_bapi(
          EXPORTING
            it_bapi_messages          =  VALUE #( ( lo_translate->fill_return( i_number = '003'
                                                                               i_id = 'LXE_TRANS'
                                                                               i_type = 'E'
                                                                               i_message_v1 = ls_data-olang ) ) ) ).
      ENDIF.

      SPLIT ls_data-tlang AT '-' INTO TABLE DATA(lt_lang_serv).

      LOOP AT lt_lang_serv ASSIGNING FIELD-SYMBOL(<ls_tlang_serv>).
        ASSIGN lt_languages[ language = <ls_tlang_serv> ] TO <ls_language>.
        IF sy-subrc = 0.
          INSERT <ls_language>-lxe_language INTO TABLE lt_tlang.
        ELSE.
          lv_errors = abap_true.
          message_container->add_messages_from_bapi(
            EXPORTING
              it_bapi_messages          =  VALUE #( ( lo_translate->fill_return( i_number = '003'
                                                                                 i_id = 'LXE_TRANS'
                                                                                 i_type = 'E'
                                                                                 i_message_v1 = <ls_tlang_serv> ) ) ) ).
        ENDIF.
      ENDLOOP.

      " La orden es opcional
      IF ls_data-order IS NOT INITIAL.

        lo_translate->get_task_from_order(
          EXPORTING
            iv_order  = ls_data-order
          IMPORTING
            ev_task   = ls_data-order
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
      ls_data-depth_refs = COND #( WHEN ls_data-depth_refs IS INITIAL THEN 1 ELSE ls_data-depth_refs ).


      IF lv_errors = abap_true.
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            message_container = message_container.
      ELSE.
        lo_translate->set_params_selscreen(
          EXPORTING
            iv_olang      = lv_olang
            it_tlang      = lt_tlang
            iv_trkorr     = ls_data-order
            iv_depth_refs = CONV #( ls_data-depth_refs ) ).

        lo_translate->load_object_texts( ).
        DATA(lo_data) = lo_translate->get_data( ).
        DATA(lt_fcat) = lo_translate->get_fcat( ).
        adapt_objects_text_2_service( EXPORTING io_data = lo_data
                                                it_fcat = lt_fcat
                                      IMPORTING et_texts = ls_data-objecttextset ).

        CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
          EXPORTING
            is_data = ls_data
          CHANGING
            cr_data = er_deep_entity.

      ENDIF.
    ELSE.

      message_container->add_messages_from_bapi(
        EXPORTING
          it_bapi_messages          =  VALUE #( ( lo_translate->fill_return( i_number = '004'
                                                                             i_type = 'E'
                                                                             i_message_v1 = ls_data-object
                                                                             i_message_v2 = ls_data-obj_name ) ) ) ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = message_container.

    ENDIF.
  ENDMETHOD.


  METHOD adapt_objects_text_2_service.

  ENDMETHOD.

ENDCLASS.
