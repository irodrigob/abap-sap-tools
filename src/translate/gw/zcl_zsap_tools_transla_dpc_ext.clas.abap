CLASS zcl_zsap_tools_transla_dpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_zsap_tools_transla_dpc
  CREATE PUBLIC .

  PUBLIC SECTION.
  PROTECTED SECTION.
    METHODS languagesset_get_entityset REDEFINITION.
    METHODS selectableobject_get_entityset REDEFINITION.
    METHODS objectstextset_get_entityset REDEFINITION.
  PRIVATE SECTION.
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

  METHOD objectstextset_get_entityset.
    DATA lt_tlang TYPE lxe_tt_lxeisolang.

    DATA(lo_translate) = NEW zcl_spt_translate_tool(  ).

    DATA(message_container) = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

    DATA(lv_object) = VALUE trobjtype( it_filter_select_options[ property = 'object' ]-select_options[ 1 ]-low ).
    DATA(lv_obj_name) = VALUE sobj_name( it_filter_select_options[ property = 'objectName' ]-select_options[ 1 ]-low ).

    IF lo_translate->check_obj_2_trans( EXPORTING iv_object  = lv_object
                                                  iv_obj_name = lv_obj_name ).

      DATA(lv_errors) = abap_false.
      DATA(lt_languages) = lo_translate->get_languages(  ).

      " Se convierte y valida que exista el idioma de original
      ASSIGN lt_languages[ language = it_filter_select_options[ property = 'oLang' ]-select_options[ 1 ]-low ] TO FIELD-SYMBOL(<ls_language>).
      IF sy-subrc = 0.
        DATA(lv_olang) = <ls_language>-lxe_language.
      ELSE.
        lv_errors = abap_true.
        message_container->add_messages_from_bapi(
          EXPORTING
            it_bapi_messages          =  VALUE #( ( lo_translate->fill_return( i_number = '003'
                                                                               i_id = 'LXE_TRANS'
                                                                               i_type = 'E'
                                                                               i_message_v1 = it_filter_select_options[ property = 'oLang' ]-select_options[ 1 ]-low ) ) ) ).
      ENDIF.

      LOOP AT it_filter_select_options[ property = 'tLang' ]-select_options ASSIGNING FIELD-SYMBOL(<ls_tlang>).
        ASSIGN lt_languages[ language = <ls_tlang>-low ] TO <ls_language>.
        IF sy-subrc = 0.
          INSERT <ls_language>-lxe_language INTO TABLE lt_tlang.
        ELSE.
          lv_errors = abap_true.
          message_container->add_messages_from_bapi(
            EXPORTING
              it_bapi_messages          =  VALUE #( ( lo_translate->fill_return( i_number = '003'
                                                                                 i_id = 'LXE_TRANS'
                                                                                 i_type = 'E'
                                                                                 i_message_v1 = <ls_tlang>-low ) ) ) ).
        ENDIF.
      ENDLOOP.


      IF lv_errors = abap_true.
        RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
          EXPORTING
            message_container = message_container.
      ELSE.

        " La orden es opcional
        IF line_exists( it_filter_select_options[ property = 'order' ] ).
          DATA(lv_trkorr) = VALUE trkorr( it_filter_select_options[ property = 'order' ]-select_options[ 1 ]-low ).
        ENDIF.

        " Lo mismo con el nivel de profundidad en la traducción, por defecto será 1.
        DATA(lv_depth_refs) = 1.
        IF line_exists( it_filter_select_options[ property = 'depthRefs' ] ).
          lv_depth_refs = VALUE int1( it_filter_select_options[ property = 'depthRefs' ]-select_options[ 1 ]-low ).
        ENDIF.

      ENDIF.

      lo_translate->set_params_selscreen(
        EXPORTING
          iv_olang      = lv_olang
          it_tlang      = lt_tlang
          iv_trkorr     = lv_trkorr
          iv_depth_refs = lv_depth_refs ).

    ELSE.

      message_container->add_messages_from_bapi(
        EXPORTING
          it_bapi_messages          =  VALUE #( ( lo_translate->fill_return( i_number = '004'
                                                                             i_type = 'E'
                                                                             i_message_v1 = lv_object
                                                                             i_message_v2 = lv_obj_name ) ) ) ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = message_container.

    ENDIF.

    "it_filter_select_options[ property = 'object' ]-select_options[ 1 ]-low
    "it_filter_select_options[ property = 'objectName' ]-select_options[ 1 ]-low
    "it_filter_select_options[ property = 'oLang' ]-select_options[ 1 ]-low
    "it_filter_select_options[ property = 'tLang' ]-select_options[ 1 ]-low
    "it_filter_select_options[ property = 'order' ]-select_options[ 1 ]-low
    "it_filter_select_options[ property = 'depthRefs' ]-select_options[ 1 ]-low

  ENDMETHOD.

ENDCLASS.
