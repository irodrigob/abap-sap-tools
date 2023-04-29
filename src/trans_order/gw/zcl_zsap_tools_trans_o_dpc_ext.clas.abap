CLASS zcl_zsap_tools_trans_o_dpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_zsap_tools_trans_o_dpc
  CREATE PUBLIC .

  PUBLIC SECTION.
  PROTECTED SECTION.
    METHODS getusersordersse_get_entityset REDEFINITION.
    METHODS getsystemstransp_get_entityset REDEFINITION.
    METHODS dotransportcopys_get_entityset REDEFINITION.
    METHODS orderset_update_entity REDEFINITION.
    METHODS systemsuserset_get_entityset REDEFINITION.
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


  METHOD getusersordersse_get_entityset.

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
    IMPORTING
      et_orders            = DATA(lt_orders) ).

    et_entityset = CORRESPONDING #( lt_orders ).

  ENDMETHOD.
  METHOD orderset_update_entity.

    io_data_provider->read_entry_data( IMPORTING es_data = er_entity ).

    DATA(message_container) = /iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

    DATA(ls_return) = NEW zcl_spt_apps_trans_order( )->update_order( iv_order  = CONV #( it_key_tab[ name = 'orderTask' ]-value )
                                                     is_data   = VALUE #( description = er_entity-description
                                                                          user = er_entity-user ) ).

    IF ls_return-type = zif_spt_core_data=>cs_message-type_error.
      message_container->add_message_text_only(
        EXPORTING
          iv_msg_type               = ls_return-type
          iv_msg_text               = CONV #( ls_return-message ) ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = message_container.
    ENDIF.
  ENDMETHOD.

  METHOD systemsuserset_get_entityset.

    et_entityset = NEW zcl_spt_apps_trans_order_md(  )->get_system_users( ).

  ENDMETHOD.

ENDCLASS.
