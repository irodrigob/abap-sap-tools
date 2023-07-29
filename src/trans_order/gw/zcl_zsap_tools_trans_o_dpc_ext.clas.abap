CLASS zcl_zsap_tools_trans_o_dpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_zsap_tools_trans_o_dpc
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS /iwbep/if_mgw_appl_srv_runtime~create_deep_entity REDEFINITION.
  PROTECTED SECTION.

    METHODS userordersset_get_entityset REDEFINITION.
    METHODS userordersset_create_entity REDEFINITION.
    METHODS getsystemstransp_get_entityset REDEFINITION.
    METHODS dotransportcopys_get_entityset REDEFINITION.
    METHODS orderset_update_entity REDEFINITION.
    METHODS systemsuserset_get_entityset REDEFINITION.
    METHODS releaseorderset_get_entityset REDEFINITION.
    METHODS orderobjectsset_get_entityset REDEFINITION.
    METHODS deleteordersset_get_entityset REDEFINITION.
    METHODS orderset_delete_entity REDEFINITION.
    METHODS orderobjectsset_delete_entity REDEFINITION.

    METHODS move_objects_entity
      IMPORTING
        !iv_entity_name          TYPE string OPTIONAL
        !iv_entity_set_name      TYPE string OPTIONAL
        !iv_source_name          TYPE string OPTIONAL
        !io_data_provider        TYPE REF TO /iwbep/if_mgw_entry_provider
        !it_key_tab              TYPE /iwbep/t_mgw_name_value_pair OPTIONAL
        !it_navigation_path      TYPE /iwbep/t_mgw_navigation_path OPTIONAL
        !io_expand               TYPE REF TO /iwbep/if_mgw_odata_expand
        !io_tech_request_context TYPE REF TO /iwbep/if_mgw_req_entity_c OPTIONAL
      EXPORTING
        !er_deep_entity          TYPE REF TO data
      RAISING
        /iwbep/cx_mgw_busi_exception
        /iwbep/cx_mgw_tech_exception .

  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_zsap_tools_trans_o_dpc_ext IMPLEMENTATION.


  METHOD dotransportcopys_get_entityset.

    CLEAR: et_entityset.

    DATA(lv_langu) = zcl_spt_utilities=>convert_iso_langu_2_sap( CONV laiso( it_filter_select_options[ property = 'langu' ]-select_options[ 1 ]-low ) ).

    DATA(lo_order) = NEW zcl_spt_apps_trans_order( iv_langu = lv_langu ).

    lo_order->do_transport_copy(
      EXPORTING
        it_orders      = VALUE #( FOR <wa> IN it_filter_select_options[ property = 'order' ]-select_options ( CONV trkorr( <wa>-low ) ) )
        iv_system      = CONV #( it_filter_select_options[ property = 'system' ]-select_options[ 1 ]-low )
        iv_description = it_filter_select_options[ property = 'orderDescription' ]-select_options[ 1 ]-low
      IMPORTING
        et_return      = DATA(lt_return)
        ev_order       = DATA(lv_order) ).

    LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<ls_return>).
      INSERT VALUE #(  order_created = lv_order
                       return-type = <ls_return>-type
                       return-message = <ls_return>-message ) INTO TABLE et_entityset.
    ENDLOOP.
    IF sy-subrc NE 0.
      INSERT VALUE #(  order_created = lv_order ) INTO TABLE et_entityset.
    ENDIF.

  ENDMETHOD.


  METHOD getsystemstransp_get_entityset.
    CLEAR: et_entityset.

    TRY.

        DATA(lv_langu) = zcl_spt_utilities=>convert_iso_langu_2_sap( CONV laiso( it_filter_select_options[ property = 'langu' ]-select_options[ 1 ]-low ) ).

        DATA(lo_order) = NEW zcl_spt_apps_trans_order( iv_langu = lv_langu ).

        et_entityset = CORRESPONDING #( lo_order->get_systems_transport(  ) ).

      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.





  METHOD orderobjectsset_get_entityset.
    CLEAR: et_entityset.

    DATA(lo_order) = NEW zcl_spt_apps_trans_order(  ).

    et_entityset = CORRESPONDING #( lo_order->get_orders_objects( it_orders = VALUE #( FOR <wa> IN it_filter_select_options[ property = 'order' ]-select_options ( CONV trkorr( <wa>-low ) ) ) ) ).

  ENDMETHOD.


  METHOD orderset_update_entity.

    io_data_provider->read_entry_data( IMPORTING es_data = er_entity ).

    DATA(message_container) = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

    DATA(ls_return) = NEW zcl_spt_apps_trans_order( )->update_order( iv_order  = CONV #( it_key_tab[ name = 'orderTask' ]-value )
                                                     is_data   = VALUE #( description = er_entity-description
                                                                          user = er_entity-user ) ).

    IF ls_return-type = zcl_spt_core_data=>cs_message-type_error.
      message_container->add_message_text_only(
        EXPORTING
          iv_msg_type               = ls_return-type
          iv_msg_text               = CONV #( ls_return-message ) ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = message_container.
    ENDIF.
  ENDMETHOD.


  METHOD releaseorderset_get_entityset.

    CLEAR: et_entityset.

    DATA(lo_order) = NEW zcl_spt_apps_trans_order(  ).

    DATA(lt_return) = lo_order->release_multiple_orders( it_orders  = VALUE #( FOR <wa> IN it_filter_select_options[ property = 'order' ]-select_options ( CONV trkorr( <wa>-low ) ) ) ).

    LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<ls_return>).
      INSERT CORRESPONDING #( <ls_return> ) INTO TABLE et_entityset ASSIGNING FIELD-SYMBOL(<ls_entityset>).
      <ls_entityset>-return = CORRESPONDING #( <ls_return> ).
    ENDLOOP.

  ENDMETHOD.


  METHOD systemsuserset_get_entityset.

    et_entityset = NEW zcl_spt_apps_trans_order_md(  )->get_system_users( ).

  ENDMETHOD.


  METHOD deleteordersset_get_entityset.

    " NOTA IRB: Sé que es un servicio de lectura y no de borrado. Pero me permite pasar "n" ordenes a borrar y
    " no tener que lanzar el servicio "n" veces. Esto me permite simplifca la parte frontend.

    CLEAR: et_entityset.

    DATA(lo_order) = NEW zcl_spt_apps_trans_order(  ).

    DATA(lt_return) = lo_order->delete_orders( it_orders  = VALUE #( FOR <wa> IN it_filter_select_options[ property = 'order' ]-select_options ( CONV trkorr( <wa>-low ) ) ) ).

    LOOP AT lt_return ASSIGNING FIELD-SYMBOL(<ls_return>).
      INSERT CORRESPONDING #( <ls_return> ) INTO TABLE et_entityset ASSIGNING FIELD-SYMBOL(<ls_entityset>).
      <ls_entityset>-return = CORRESPONDING #( <ls_return> ).
    ENDLOOP.

  ENDMETHOD.

  METHOD orderset_delete_entity.
    DATA(message_container) = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

    DATA(lt_return) = NEW zcl_spt_apps_trans_order( )->delete_orders( it_orders  = VALUE #( ( it_key_tab[ name = 'orderTask' ]-value ) ) ).

    IF line_exists( lt_return[ type = zcl_spt_core_data=>cs_message-type_error ] ).
      message_container->add_message_text_only(
        EXPORTING
          iv_msg_type               = lt_return[ type = zcl_spt_core_data=>cs_message-type_error ]-type
          iv_msg_text               = CONV #( lt_return[ type = zcl_spt_core_data=>cs_message-type_error ]-message ) ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = message_container.
    ENDIF.
  ENDMETHOD.



  METHOD userordersset_get_entityset.
    CLEAR: et_entityset.

    DATA(lo_order) = NEW zcl_spt_apps_trans_order(  ).

    DATA(lv_user) = sy-uname.
    ASSIGN it_filter_select_options[ property = 'orderUser' ]-select_options[ 1 ] TO FIELD-SYMBOL(<ls_select_options>).
    IF sy-subrc = 0.
      lv_user = <ls_select_options>-low.
    ENDIF.

    lo_order->get_user_orders(
      EXPORTING
        iv_username          = lv_user
      iv_type_workbench    = COND #( WHEN line_exists( it_filter_select_options[ property = 'orderType' ]-select_options[ low = zcl_spt_trans_order_data=>cs_orders-type-workbench ] )
                                     THEN abap_true ELSE abap_false )
      iv_type_customizing  = COND #( WHEN line_exists( it_filter_select_options[ property = 'orderType' ]-select_options[ low = zcl_spt_trans_order_data=>cs_orders-type-customizing ] )
                                     THEN abap_true ELSE abap_false )
      iv_type_transport    = COND #( WHEN line_exists( it_filter_select_options[ property = 'orderType' ]-select_options[ low = zcl_spt_trans_order_data=>cs_orders-type-transport_copies ] )
                                     THEN abap_true ELSE abap_false )
      iv_status_modif      = COND #( WHEN line_exists( it_filter_select_options[ property = 'orderStatus' ]-select_options[ low = zcl_spt_trans_order_data=>cs_orders-status-changeable ] )
                                     THEN abap_true ELSE abap_false )
      iv_status_release    = COND #( WHEN line_exists( it_filter_select_options[ property = 'orderStatus' ]-select_options[ low = zcl_spt_trans_order_data=>cs_orders-status-released ] )
                                     THEN abap_true ELSE abap_false )
      iv_release_from_data =  COND #( WHEN line_exists( it_filter_select_options[ property = 'releaseDateFrom' ] )
                                      THEN it_filter_select_options[ property = 'releaseDateFrom' ]-select_options[ 1 ]-low ELSE sy-datum )
      iv_release_from_to   = sy-datum
      iv_complete_projects =  COND #( WHEN line_exists( it_filter_select_options[ property = 'completeProjects' ] )
                                      THEN it_filter_select_options[ property = 'completeProjects' ]-select_options[ 1 ]-low ELSE abap_true )
    IMPORTING
      et_orders            = DATA(lt_orders) ).

    et_entityset = CORRESPONDING #( lt_orders ).
  ENDMETHOD.

  METHOD userordersset_create_entity.
    io_data_provider->read_entry_data( IMPORTING es_data = er_entity ).

    DATA(message_container) = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).


    NEW zcl_spt_apps_trans_order( )->create_order_and_task( EXPORTING iv_type = er_entity-order_type
                                                                      iv_description = er_entity-order_desc
                                                                      iv_system      = er_entity-order_system
                                                                      iv_user        = COND #( WHEN er_entity-order_user IS INITIAL THEN sy-uname ELSE er_entity-order_user )
                                                            IMPORTING es_return      = DATA(ls_return)
                                                                      et_order_data  = DATA(lt_order_data) ).


    IF ls_return-type = zcl_spt_core_data=>cs_message-type_error.
      message_container->add_message_text_only(
        EXPORTING
          iv_msg_type               = ls_return-type
          iv_msg_text               = CONV #( ls_return-message ) ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = message_container.
    ELSE.
      er_entity = CORRESPONDING #( lt_order_data[ 1 ] ).
    ENDIF.
  ENDMETHOD.

  METHOD orderobjectsset_delete_entity.


    DATA(message_container) = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

    DATA(lt_return) = NEW zcl_spt_apps_trans_order( )->delete_order_objects( it_objects = VALUE #( (  order = it_key_tab[ name = 'order' ]-value
                                                                                                      pgmid = it_key_tab[ name = 'pgmid' ]-value
                                                                                                      object = it_key_tab[ name = 'object' ]-value
                                                                                                      obj_name = it_key_tab[ name = 'objName' ]-value ) ) ).

    IF line_exists( lt_return[ type = zcl_spt_core_data=>cs_message-type_error ] ).
      message_container->add_message_text_only(
        EXPORTING
          iv_msg_type               = lt_return[ type = zcl_spt_core_data=>cs_message-type_error ]-type
          iv_msg_text               = CONV #( lt_return[ type = zcl_spt_core_data=>cs_message-type_error ]-message ) ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = message_container.
    ENDIF.

  ENDMETHOD.

  METHOD /iwbep/if_mgw_appl_srv_runtime~create_deep_entity.

    CASE iv_entity_name.
      WHEN 'moveObjects'.
        move_objects_entity(
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

  METHOD move_objects_entity.
    DATA ls_data TYPE zcl_zsap_tools_trans_o_mpc_ext=>ts_move_objects_deep.

    io_data_provider->read_entry_data( IMPORTING es_data = ls_data ).

    NEW zcl_spt_apps_trans_order( )->move_orders_objects( EXPORTING it_objects  = CONV #( ls_data-orderobjectskeyset )
                                                                    iv_order_to = ls_data-order_to
                                                          IMPORTING et_return   =  DATA(lt_return) ).

    ls_data-returnset = CORRESPONDING #( lt_return ).


    CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
      EXPORTING
        is_data = ls_data
      CHANGING
        cr_data = er_deep_entity.

  ENDMETHOD.

ENDCLASS.
