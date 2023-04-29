CLASS zcl_spt_apps_trans_order DEFINITION
  PUBLIC
  INHERITING FROM zcl_spt_apps_base
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: BEGIN OF ts_user_orders,
             order             TYPE trkorr,
             order_desc        TYPE string,
             order_user        TYPE uname,
             order_status      TYPE trstatus,
             order_status_desc TYPE val_text,
             order_type        TYPE trfunction,
             order_type_desc   TYPE val_text,
             task              TYPE trkorr,
             task_desc         TYPE string,
             task_user         TYPE uname,
             task_status       TYPE trstatus,
             task_status_desc  TYPE val_text,
             task_type         TYPE trfunction,
             task_type_desc    TYPE val_text,
           END OF ts_user_orders.
    TYPES: tt_user_orders TYPE STANDARD TABLE OF ts_user_orders WITH EMPTY KEY.
    TYPES: BEGIN OF ts_systems_transport,
             system_name TYPE sysname,
             system_desc TYPE string,
           END OF ts_systems_transport.
    TYPES: BEGIN OF ts_update_order,
             user        TYPE tr_as4user,
             description TYPE as4text,
           END OF ts_update_order.
    TYPES: tt_systems_transport TYPE STANDARD TABLE OF ts_systems_transport WITH EMPTY KEY.
    TYPES: BEGIN OF ts_release_multiple_orders,
             order       TYPE trkorr,
             status      TYPE trstatus,
             status_desc TYPE val_text.
        INCLUDE TYPE zif_spt_core_data=>ts_return.
    TYPES:
           END OF ts_release_multiple_orders.
    TYPES: tt_release_multiple_orders TYPE STANDARD TABLE OF ts_release_multiple_orders WITH EMPTY KEY.
    METHODS zif_spt_core_app~get_app_type REDEFINITION.


    "! <p class="shorttext synchronized">Devuelve las ordenes de un usuario </p>
    "! @parameter iv_langu | <p class="shorttext synchronized">Idioma</p>
    METHODS constructor
      IMPORTING iv_langu TYPE sylangu DEFAULT sy-langu.
    "! <p class="shorttext synchronized">Devuelve las ordenes de un usuario </p>
    "! @parameter iv_username | <p class="shorttext synchronized">Usuario</p>
    "! @parameter iv_type_workbench | <p class="shorttext synchronized">Ordenes workbench</p>
    "! @parameter iv_type_customizing | <p class="shorttext synchronized">Ordenes customizing</p>
    "! @parameter iv_type_transport | <p class="shorttext synchronized">Transporte de copias</p>
    "! @parameter iv_status_modif | <p class="shorttext synchronized">Status modificable</p>
    "! @parameter iv_status_release | <p class="shorttext synchronized">Status liberadas</p>
    "! @parameter iv_release_from_data | <p class="shorttext synchronized">Ordenes liberadas desde</p>
    "! @parameter iv_release_from_to | <p class="shorttext synchronized">Ordenes liberadas desde</p>
    "! @parameter et_orders | <p class="shorttext synchronized">Ordenes</p>
    METHODS get_user_orders
      IMPORTING
        !iv_username          TYPE syuname DEFAULT sy-uname
        !iv_type_workbench    TYPE sap_bool DEFAULT abap_true
        !iv_type_customizing  TYPE sap_bool DEFAULT abap_true
        !iv_type_transport    TYPE sap_bool DEFAULT abap_true
        !iv_status_modif      TYPE sap_bool DEFAULT abap_true
        !iv_status_release    TYPE sap_bool DEFAULT abap_false
        !iv_release_from_data TYPE sy-datum OPTIONAL
        !iv_release_from_to   TYPE sy-datum OPTIONAL
      EXPORTING
        et_orders             TYPE tt_user_orders.
    "! <p class="shorttext synchronized">Sistemas de transporte</p>
    "! @parameter rt_systems | <p class="shorttext synchronized">Sistemas</p>
    METHODS get_systems_transport
      RETURNING VALUE(rt_systems) TYPE tt_systems_transport.
    "! <p class="shorttext synchronized">Hacer transporte de copia</p>
    "! @parameter it_orders | <p class="shorttext synchronized">Ordenes</p>
    "! @parameter iv_system | <p class="shorttext synchronized">Sistema</p>
    "! @parameter iv_description | <p class="shorttext synchronized">Descripción</p>
    "! @parameter iv_release_order_new_task | <p class="shorttext synchronized">Liberar la orden/tarea en nueva tarea</p>
    "! @parameter et_return | <p class="shorttext synchronized">Retorno del proceso</p>
    "! @parameter ev_order | <p class="shorttext synchronized">Orden creada</p>
    METHODS do_transport_copy
      IMPORTING
        it_orders                 TYPE zcl_spt_trans_order_data=>tt_orders
        iv_system                 TYPE sysname
        iv_description            TYPE string
        iv_release_order_new_task TYPE sap_bool DEFAULT abap_true
      EXPORTING
        et_return                 TYPE zif_spt_core_data=>tt_return
        ev_order                  TYPE trkorr.
    "! <p class="shorttext synchronized">Liberación de una orden/tarea</p>
    "! @parameter iv_order | <p class="shorttext synchronized">Orden/tarea</p>
    "! @parameter iv_without_locking | <p class="shorttext synchronized">Sin bloqueo de objetos</p>
    "! @parameter es_return | <p class="shorttext synchronized">Resultado del proceso</p>
    "! @parameter ev_status | <p class="shorttext synchronized">Status al liberar</p>
    "! @parameter ev_status_desc | <p class="shorttext synchronized">Descripción del status</p>
    METHODS release_order
      IMPORTING
                iv_without_locking TYPE sap_bool DEFAULT abap_false
                iv_order           TYPE trkorr
      EXPORTING es_return          TYPE zif_spt_core_data=>ts_return
                ev_status          TYPE trstatus
                ev_status_desc     TYPE val_text.
    "! <p class="shorttext synchronized">Liberación de multiples ordenes/tareas</p>
    "! @parameter it_order | <p class="shorttext synchronized">Lista de ordenes/tareas</p>
    "! @parameter iv_without_locking | <p class="shorttext synchronized">Sin bloqueo de objetos</p>
    "! @parameter et_return | <p class="shorttext synchronized">Resultado del proceso</p>
    METHODS release_multiple_orders
      IMPORTING
                iv_without_locking TYPE sap_bool DEFAULT abap_false
                it_orders          TYPE zcl_spt_trans_order_data=>tt_orders
      RETURNING VALUE(et_return)   TYPE tt_release_multiple_orders.
    "! <p class="shorttext synchronized">Actualiza los datos de una orden/tarea</p>
    "! @parameter iv_order | <p class="shorttext synchronized">Orden/tarea</p>
    "! @parameter is_data | <p class="shorttext synchronized">Valores</p>
    "! @parameter rs_return | <p class="shorttext synchronized">Resultado del proceso</p>
    METHODS update_order
      IMPORTING
                iv_order         TYPE trkorr
                is_data          TYPE ts_update_order
      RETURNING VALUE(rs_return) TYPE zif_spt_core_data=>ts_return.
    "! <p class="shorttext synchronized">Cambio del usuario de la orden</p>
    "! @parameter iv_user | <p class="shorttext synchronized">Usuario</p>
    "! @parameter iv_order | <p class="shorttext synchronized">Orden</p>
    "! @parameter rs_return | <p class="shorttext synchronized">Resultado del proceso</p>
    METHODS change_user_order
      IMPORTING
        iv_user          TYPE tr_as4user
        iv_order         TYPE trkorr
      RETURNING
        VALUE(rs_return) TYPE zif_spt_core_data=>ts_return.
  PROTECTED SECTION.

    DATA mt_orders_data TYPE zcl_spt_trans_order_data=>tt_orders_data.
    DATA mo_handle_badi_transport_copy TYPE REF TO zspt_badi_transport_copy.
    DATA mo_order_md TYPE REF TO zcl_spt_apps_trans_order_md.

    "! <p class="shorttext synchronized">Parámetros de selección</p>
    "! @parameter iv_username | <p class="shorttext synchronized">Usuario</p>
    "! @parameter iv_type_workbench | <p class="shorttext synchronized">Ordenes workbench</p>
    "! @parameter iv_type_customizing | <p class="shorttext synchronized">Ordenes customizing</p>
    "! @parameter iv_type_transport | <p class="shorttext synchronized">Transporte de copias</p>
    "! @parameter iv_status_modif | <p class="shorttext synchronized">Status modificable</p>
    "! @parameter iv_status_release | <p class="shorttext synchronized">Status liberadas</p>
    "! @parameter iv_release_from_data | <p class="shorttext synchronized">Ordenes liberadas desde</p>
    "! @parameter iv_release_from_to | <p class="shorttext synchronized">Ordenes liberadas desde</p>
    "! @parameter et_orders | <p class="shorttext synchronized">Ordenes</p>
    METHODS fill_selections_orders
      IMPORTING
        iv_type_workbench    TYPE sap_bool DEFAULT abap_true
        iv_type_customizing  TYPE sap_bool DEFAULT abap_true
        iv_type_transport    TYPE sap_bool DEFAULT abap_true
        iv_status_modif      TYPE sap_bool DEFAULT abap_true
        iv_status_release    TYPE sap_bool DEFAULT abap_false
        iv_release_from_data TYPE sy-datum OPTIONAL
        iv_release_from_to   TYPE sy-datum OPTIONAL
      RETURNING
        VALUE(rt_selections) TYPE trwbo_selections.

    "! <p class="shorttext synchronized">Creación de orden de transporte</p>
    "! @parameter iv_type | <p class="shorttext synchronized">Tipo de orden</p>
    "! @parameter iv_system | <p class="shorttext synchronized">Sistema</p>
    "! @parameter iv_description | <p class="shorttext synchronized">Descripción</p>
    "! @parameter iv_user | <p class="shorttext synchronized">Usuario</p>
    "! @parameter es_return | <p class="shorttext synchronized">Retorno de la creación</p>
    "! @parameter ev_order | <p class="shorttext synchronized">Orden creada</p>
    METHODS create_order
      IMPORTING
        iv_type        TYPE trfunction
        iv_description TYPE string
        iv_system      TYPE sysname OPTIONAL
        iv_user        TYPE syuname DEFAULT sy-uname
      EXPORTING
        es_return      TYPE zif_spt_core_data=>ts_return
        ev_order       TYPE trkorr.
    "! <p class="shorttext synchronized">Copia el contenido de unas ordenes a otra orden</p>
    "! @parameter it_from_orders | <p class="shorttext synchronized">Ordenes origen</p>
    "! @parameter iv_to_order | <p class="shorttext synchronized">Orden destino</p>
    METHODS copy_content_orders_2_order
      IMPORTING
        it_from_orders TYPE zcl_spt_trans_order_data=>tt_orders
        iv_to_order    TYPE trkorr
      EXPORTING
        et_return      TYPE zif_spt_core_data=>tt_return.
    "! <p class="shorttext synchronized">Verifica si hay objetos inactivos en las ordenes</p>
    "! @parameter it_orders | <p class="shorttext synchronized">Ordenes origen</p>
    "! @parameter et_return | <p class="shorttext synchronized">Resultado del proceso</p>
    METHODS check_inactive_objects
      IMPORTING
        it_orders TYPE zcl_spt_trans_order_data=>tt_orders
      EXPORTING
        et_return TYPE zif_spt_core_data=>tt_return.
    "! <p class="shorttext synchronized">Lectura de datos de una orden</p>
    "! @parameter iv_order | <p class="shorttext synchronized">Orden</p>
    "! @parameter rs_data | <p class="shorttext synchronized">Datos del orden</p>
    METHODS read_request
      IMPORTING
                iv_order       TYPE trkorr
      RETURNING
                VALUE(rs_data) TYPE trwbo_request
      RAISING   zcx_spt_trans_order.

    "! <p class="shorttext synchronized">Lectura de los datos de las ordenes</p>
    "! @parameter it_orders | <p class="shorttext synchronized">Ordenes</p>
    "! @parameter rt_return | <p class="shorttext synchronized">Resultado del proceso</p>
    METHODS get_orders_info
      IMPORTING
                it_orders        TYPE zcl_spt_trans_order_data=>tt_orders
      RETURNING VALUE(rt_return) TYPE zif_spt_core_data=>tt_return.
    "! <p class="shorttext synchronized">Llama al método antes de liberar </p>
    "! @parameter iv_order | <p class="shorttext synchronized">Orden</p>
    "! @parameter cs_return | <p class="shorttext synchronized">Resultado del proceso</p>
    METHODS call_badi_before_release_order
      IMPORTING
        iv_order  TYPE trkorr
      CHANGING
        cs_return TYPE zif_spt_core_data=>ts_return.
    "! <p class="shorttext synchronized">Instancia la BADI de transporte de copias</p>
    METHODS instance_badi_transport_copy.



  PRIVATE SECTION.


ENDCLASS.



CLASS zcl_spt_apps_trans_order IMPLEMENTATION.


  METHOD call_badi_before_release_order.

    " Si la BADI esta instancia leo los datos de la orden y se la paso al método
    IF mo_handle_badi_transport_copy IS BOUND.

      TRY.
          DATA(ls_data) = read_request( iv_order ).

        CATCH zcx_spt_trans_order INTO DATA(lo_excep).
      ENDTRY.

      LOOP AT mo_handle_badi_transport_copy->imps ASSIGNING FIELD-SYMBOL(<ls_imps>).
        TRY.
            <ls_imps>->before_release_order( EXPORTING
                  iv_order      = iv_order
                  is_order_data = ls_data
                CHANGING
                  cs_return     = cs_return ).

            " Si se devuelve algun error se para la llamada a las BADI
            IF cs_return-type = zif_spt_core_data=>cs_message-type_error.
              EXIT.
            ENDIF.
          CATCH cx_root.
        ENDTRY.
      ENDLOOP.

    ENDIF.
  ENDMETHOD.


  METHOD change_user_order.
    DATA ls_header TYPE trwbo_request_header.

    CALL FUNCTION 'TR_CHANGE_USERNAME'
      EXPORTING
        wi_dialog           = abap_false
        wi_trkorr           = iv_order
        wi_user             = iv_user
      IMPORTING
        es_request_header   = ls_header
      EXCEPTIONS
        already_released    = 1
        e070_update_error   = 2
        file_access_error   = 3
        not_exist_e070      = 4
        user_does_not_exist = 5
        tr_enqueue_failed   = 6
        no_authorization    = 7
        wrong_client        = 8
        unallowed_user      = 9
        OTHERS              = 10.
    IF sy-subrc <> 0.
      rs_return = VALUE #( type = zif_spt_core_data=>cs_message-type_error
                                   message = zcl_spt_utilities=>fill_return( iv_type = zif_spt_core_data=>cs_message-type_error
                                                                             iv_id = sy-msgid
                                                                             iv_number = sy-msgno
                                                                             iv_message_v1 = sy-msgv1
                                                                             iv_message_v2 = sy-msgv2
                                                                             iv_message_v3 = sy-msgv3
                                                                             iv_message_v4 = sy-msgv4
                                                                             iv_langu      = mv_langu )-message ).
    ELSE.
      rs_return = VALUE #( type = zif_spt_core_data=>cs_message-type_success
                           message = zcl_spt_utilities=>fill_return( iv_type = zif_spt_core_data=>cs_message-type_success
                                                                     iv_id = zcl_spt_trans_order_data=>cs_message-id
                                                                     iv_number = '005'
                                                                     iv_message_v1 = iv_user
                                                                     iv_message_v2 = iv_order
                                                                     iv_langu  = mv_langu )-message ).
    ENDIF.

  ENDMETHOD.


  METHOD check_inactive_objects.
    DATA lt_log TYPE STANDARD TABLE OF sprot_u.


    " Solo procesan las ordenes/tareas que tengan objetos
    LOOP AT it_orders ASSIGNING FIELD-SYMBOL(<ls_orders>).

      TRY.

          " Si la tengo en la tabla global uso sus valores, en caso contrario los busco.
          READ TABLE mt_orders_data INTO DATA(ls_order_data) WITH KEY h-trkorr = <ls_orders>.
          IF sy-subrc NE 0.
            ls_order_data = read_request( <ls_orders> ).
          ENDIF.

          DATA(ls_e070) = CORRESPONDING e070( ls_order_data-h ).

          CALL FUNCTION 'TRINT_CHECK_INACTIVE_OBJECTS'
            EXPORTING
              is_e070 = ls_e070
              it_e071 = ls_order_data-objects
            TABLES
              et_log  = lt_log[].

          " Los mensajes de tipo A y E son errores y se devuelven
          LOOP AT lt_log ASSIGNING FIELD-SYMBOL(<ls_log>) WHERE ( severity = zif_spt_core_data=>cs_message-type_error
                                                                  OR severity = zif_spt_core_data=>cs_message-type_anormal ).
            INSERT zcl_spt_utilities=>fill_return( iv_type = <ls_log>-severity
                                                   iv_id = <ls_log>-ag
                                                   iv_number = <ls_log>-msgnr
                                                   iv_message_v1 = <ls_log>-var1
                                                   iv_message_v2 = <ls_log>-var2
                                                   iv_message_v3 = <ls_log>-var3
                                                   iv_message_v4 = <ls_log>-var4
                                                   iv_langu      = <ls_log>-langu ) INTO TABLE et_return.
          ENDLOOP.

        CATCH zcx_spt_trans_order INTO DATA(lo_excep).
          INSERT zcl_spt_utilities=>fill_return( iv_type = zif_spt_core_data=>cs_message-type_error
                                                 iv_id = lo_excep->if_t100_message~t100key-msgid
                                                 iv_number = lo_excep->if_t100_message~t100key-msgno
                                                 iv_message_v1 = lo_excep->mv_msgv1
                                                 iv_langu      = mv_langu ) INTO TABLE et_return.
      ENDTRY.

    ENDLOOP.

  ENDMETHOD.


  METHOD copy_content_orders_2_order.
    CLEAR: et_return.
    LOOP AT it_from_orders ASSIGNING FIELD-SYMBOL(<ls_orders>).
      CALL FUNCTION 'TR_COPY_COMM'
        EXPORTING
          wi_dialog                = space
          wi_trkorr_from           = <ls_orders>
          wi_trkorr_to             = iv_to_order
          wi_without_documentation = abap_true
        EXCEPTIONS
          OTHERS                   = 1.
      IF sy-subrc NE 0.
        INSERT VALUE #( type = zif_spt_core_data=>cs_message-type_error
                        message = zcl_spt_utilities=>fill_return( iv_type = zif_spt_core_data=>cs_message-type_error
                                                                  iv_id = sy-msgid
                                                                  iv_number = sy-msgno
                                                                  iv_message_v1 = sy-msgv1
                                                                  iv_message_v2 = sy-msgv2
                                                                  iv_message_v3 = sy-msgv3
                                                                  iv_message_v4 = sy-msgv4
                                                                  iv_langu      = mv_langu )-message ) INTO TABLE et_return.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD create_order.

    CLEAR: es_return.

    DATA(lv_order_text) = CONV e07t-as4text( iv_description ).

    CALL FUNCTION 'TRINT_INSERT_NEW_COMM'
      EXPORTING
        wi_kurztext   = lv_order_text
        wi_trfunction = iv_type
        iv_username   = sy-uname
        iv_tarsystem  = iv_system
        wi_client     = sy-mandt
      IMPORTING
        we_trkorr     = ev_order
      EXCEPTIONS
        OTHERS        = 1.
    IF sy-subrc = 0.
      es_return = VALUE #( type = zif_spt_core_data=>cs_message-type_success
                                 message = zcl_spt_utilities=>fill_return( iv_type = zif_spt_core_data=>cs_message-type_success
                                                                           iv_id = zcl_spt_trans_order_data=>cs_message-id
                                                                           iv_number = '002'
                                                                           iv_message_v1 = ev_order
                                                                           iv_langu      = mv_langu )-message ).
    ELSE.

      es_return = VALUE #( type = zif_spt_core_data=>cs_message-type_error
                           message = zcl_spt_utilities=>fill_return( iv_type = zif_spt_core_data=>cs_message-type_error
                                                          iv_id = sy-msgid
                                                          iv_number = sy-msgno
                                                          iv_message_v1 = sy-msgv1
                                                          iv_message_v2 = sy-msgv2
                                                          iv_message_v3 = sy-msgv3
                                                          iv_message_v4 = sy-msgv4
                                                          iv_langu      = mv_langu )-message  ) .


    ENDIF.

  ENDMETHOD.


  METHOD do_transport_copy.
    DATA ls_return_release_rfc TYPE bapiret2.
    DATA ls_return_release TYPE zif_spt_core_data=>ts_return .

    IF it_orders IS NOT INITIAL.

      instance_badi_transport_copy( ).

      " Lectura del contenido de las ordenes
      et_return = get_orders_info( it_orders ).

      IF et_return IS INITIAL.

        " Se chequean que no haya ningun objeto inactivo de las ordenes pasadas. Ya que si hay alguno no se podrá
        " liberar la orden y se quedaría colgada.
        check_inactive_objects( EXPORTING it_orders = it_orders
                                IMPORTING et_return = et_return ).

        " Si no hay errores se continua el proceso.
        IF et_return IS INITIAL.

          " Se crea la orden donde se pondrán los objetos
          create_order( EXPORTING iv_type = zcl_spt_trans_order_data=>cs_orders-type-transport_copies
                                  iv_description = iv_description
                                  iv_system = iv_system
                        IMPORTING es_return = DATA(ls_return_created)
                                  ev_order = ev_order ).

          IF ls_return_created-type NE zif_spt_core_data=>cs_message-type_error.
            " Se pasa el contenido de las ordenes pasadas a la nueva orden
            copy_content_orders_2_order( EXPORTING it_from_orders = it_orders
                                                     iv_to_order = ev_order
                                         IMPORTING et_return = et_return ).
            IF et_return IS INITIAL.

              IF iv_release_order_new_task = abap_true.

                CALL FUNCTION 'ZSPT_RELEASE_ORDER' DESTINATION 'NONE'
                  EXPORTING
                    iv_order           = ev_order
                    iv_without_locking = abap_true
                    iv_langu           = mv_langu
                  IMPORTING
                    es_return          = ls_return_release_rfc.

                ls_return_release = VALUE #( type = ls_return_release_rfc-type
                                             message = ls_return_release_rfc-message ).

              ELSE.

                " Se libera la orden
                release_order( EXPORTING iv_without_locking = abap_true " Evitamos el error de objetos de bloqueo por transporte de copias
                                         iv_order = ev_order
                               IMPORTING es_return = ls_return_release ).

              ENDIF.

              " Si hay un error añado el mensaje de la orden creada para que se sepa cual ha sido
              " la orden creada y se puede tratar para arreglar el error
              IF ls_return_release-type = zif_spt_core_data=>cs_message-type_error.
                INSERT ls_return_created INTO TABLE et_return.
                INSERT ls_return_release INTO TABLE et_return.
              ELSE.
                " Si no hay errores pongo el mensaje genérico de transporte de copias realizado.
                INSERT VALUE #( type = zif_spt_core_data=>cs_message-type_success
                                message = zcl_spt_utilities=>fill_return( iv_type = zif_spt_core_data=>cs_message-type_success
                                                                        iv_id = zcl_spt_trans_order_data=>cs_message-id
                                                                        iv_number = '004'
                                                                        iv_message_v1 = ev_order
                                                                        iv_langu      = mv_langu )-message ) INTO TABLE et_return.
              ENDIF.



            ENDIF.
          ELSE.
            INSERT ls_return_created INTO TABLE et_return.
          ENDIF.

        ENDIF.

      ELSE.
        INSERT VALUE #( type = zif_spt_core_data=>cs_message-type_error
                        message = zcl_spt_utilities=>fill_return( iv_type = zif_spt_core_data=>cs_message-type_success
                                                                          iv_id = zcl_spt_trans_order_data=>cs_message-id
                                                                          iv_number = '003'
                                                                          iv_langu      = mv_langu )-message ) INTO TABLE et_return.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD fill_selections_orders.
    DATA ls_selection TYPE trwbo_selection .

    CLEAR rt_selections.

    IF iv_type_workbench = abap_true.
      ls_selection-reqfunctions(1)     = sctsc_type_workbench.
    ENDIF.
    IF iv_type_customizing = abap_true.
      ls_selection-reqfunctions+1(1)   = sctsc_type_customizing.
    ENDIF.
    IF iv_type_transport = abap_true.
      ls_selection-reqfunctions+2(1)   = sctsc_type_transport.
    ENDIF.
    CONDENSE ls_selection-reqfunctions NO-GAPS.

    " Types of assigned tasks
    ls_selection-taskfunctions      = sctsc_types_tasks.

    " Status para ordenes modificables
    IF iv_status_modif = abap_true.
      ls_selection-taskstatus(1)     = sctsc_state_protected.
      ls_selection-taskstatus+1(1)   = sctsc_state_changeable.
    ENDIF.

    "   Free tasks are handled like tasks in requests
    ls_selection-singletasks         = 'X'.
    ls_selection-freetasks_f         = ls_selection-taskfunctions.
    ls_selection-freetasks_s         = ls_selection-taskstatus.


    " Esta opción hace que las tareas que sean pertenezcan a las ordenes que se leen primero. Si no se pone
    " llega a ocurrir que te lea tareas de customizing ( y posteriomente su orden) aún que le hayas indicado que no
    " quieres ordenes de custo.
    ls_selection-connect_req_task_conditions = abap_true.


    IF iv_status_modif = abap_true AND iv_status_release = abap_false.
      ls_selection-reqstatus(1)   = sctsc_state_protected.
      ls_selection-reqstatus+1(1) = sctsc_state_changeable.
      ls_selection-reqstatus+2(1) = sctsc_state_export_started.
      INSERT ls_selection INTO TABLE rt_selections.

    ELSEIF iv_status_modif = abap_false AND iv_status_release = abap_true.
      ls_selection-reqstatus(1)   = sctsc_state_released.
      ls_selection-reqstatus+1(1) = sctsc_state_export_started.

      INSERT ls_selection INTO TABLE rt_selections.

    ELSEIF iv_status_modif = abap_true AND iv_status_release = abap_true.
      IF iv_release_from_data IS INITIAL AND iv_release_from_to IS INITIAL.
        ls_selection-reqstatus      = sctsc_states_all.
      ELSE.
        ls_selection-reqstatus(1)   = sctsc_state_protected.
        ls_selection-reqstatus+1(1) = sctsc_state_changeable.
        ls_selection-reqstatus+2(1) = sctsc_state_export_started.
        ls_selection-freetasks_s    = ls_selection-reqstatus.
        INSERT ls_selection INTO TABLE rt_selections.

        ls_selection-taskstatus     = sctsc_state_released.
        ls_selection-reqstatus      = sctsc_state_released.
        ls_selection-freetasks_s    = ls_selection-reqstatus.
        ls_selection-fromdate = iv_release_from_data.
        ls_selection-todate = iv_release_from_to.
        INSERT ls_selection INTO TABLE rt_selections.

      ENDIF.
    ENDIF.



  ENDMETHOD.


  METHOD get_orders_info.

    CLEAR: mt_orders_data, rt_return.

    LOOP AT it_orders ASSIGNING FIELD-SYMBOL(<ls_orders>).

      TRY.
          DATA(ls_data) = read_request( <ls_orders> ).

          INSERT ls_data INTO TABLE mt_orders_data.

        CATCH zcx_spt_trans_order INTO DATA(lo_excep).
          INSERT zcl_spt_utilities=>fill_return( iv_type = zif_spt_core_data=>cs_message-type_error
                                                 iv_id = lo_excep->if_t100_message~t100key-msgid
                                                 iv_number = lo_excep->if_t100_message~t100key-msgno
                                                 iv_message_v1 = lo_excep->mv_msgv1
                                                 iv_langu      = mv_langu ) INTO TABLE rt_return.
      ENDTRY.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_systems_transport.
    DATA lv_version TYPE tcevers-version.

    CLEAR rt_systems.

* Version activa del sistema de transporte
    CALL FUNCTION 'TR_GET_CONFIG_VERSION'
      IMPORTING
        ev_active_version       = lv_version
      EXCEPTIONS
        no_active_version_found = 1.

    IF sy-subrc = 0.
      SELECT sysname AS system_name ddtext AS system_desc INTO TABLE rt_systems
              FROM  tcesystt
               WHERE version = lv_version
               AND   spras  = mv_langu.
      IF sy-subrc NE 0.
        " Si no hay en el idioma global busco en el de logon
        SELECT sysname AS system_name ddtext AS system_desc INTO TABLE rt_systems
                      FROM  tcesystt
                       WHERE version = lv_version
                       AND   spras  = sy-langu.
        IF sy-subrc NE 0.
          " Si no hay busco directamente el codig, y la descripcion será el mismo codigo
          SELECT sysname AS system_name sysname AS system_desc INTO TABLE rt_systems
                        FROM  tcesyst
                         WHERE version = lv_version.
        ENDIF.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD get_user_orders.
    DATA lt_request TYPE trwbo_request_headers.
    DATA lt_request_aux TYPE trwbo_request_headers.

    " relleno de los datos de seleccion
    DATA(lt_selections) = fill_selections_orders( EXPORTING iv_type_workbench = iv_type_workbench
                                                     iv_type_customizing = iv_type_customizing
                                                     iv_type_transport = iv_type_transport
                                                     iv_status_modif = iv_status_modif
                                                     iv_status_release = iv_status_release
                                                     iv_release_from_data = iv_release_from_data
                                                     iv_release_from_to = iv_release_from_to ).

    LOOP AT lt_selections ASSIGNING FIELD-SYMBOL(<ls_selection>).
      " Lectura de las ordenes
      CALL FUNCTION 'TRINT_SELECT_REQUESTS'
        EXPORTING
          iv_username_pattern  = iv_username
          is_selection         = <ls_selection>
          iv_complete_projects = 'X'
        IMPORTING
          et_requests          = lt_request_aux.
      INSERT LINES OF lt_request_aux INTO TABLE lt_request.
      CLEAR lt_request_aux.
    ENDLOOP.

    SORT lt_request BY trkorr ASCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_request.

    SORT lt_request BY trfunction as4date DESCENDING as4time DESCENDING.

    " Sacamos las padres para ir obteniendo los hijos
    LOOP AT lt_request ASSIGNING FIELD-SYMBOL(<ls_request>)
                                 WHERE strkorr IS INITIAL.

      " Relleno los campos base de la orden
      DATA(ls_orders) = VALUE ts_user_orders( order = <ls_request>-trkorr
                                              order_user = <ls_request>-as4user
                                              order_desc = <ls_request>-as4text
                                              order_type = <ls_request>-trfunction ).
      TRY.
          ls_orders-order_type_desc =  mo_order_md->get_function_desc( <ls_request>-trfunction ).
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.

      ls_orders-order_status = SWITCH #( <ls_request>-trstatus
                                             WHEN sctsc_state_protected OR sctsc_state_changeable THEN sctsc_state_changeable
                                             WHEN sctsc_state_released OR sctsc_state_export_started THEN sctsc_state_released ).
      TRY.
          ls_orders-order_status_desc =  mo_order_md->get_status_desc( ls_orders-order_status ).
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.

      " Ahora las tareas de la orden
      LOOP AT lt_request ASSIGNING FIELD-SYMBOL(<ls_tasks>) WHERE strkorr = <ls_request>-trkorr.
        INSERT ls_orders INTO TABLE et_orders ASSIGNING FIELD-SYMBOL(<ls_orders>).
        <ls_orders>-task = <ls_tasks>-trkorr.
        <ls_orders>-task_desc = <ls_tasks>-as4text.
        <ls_orders>-task_user = <ls_tasks>-as4user.
        <ls_orders>-task_type = <ls_tasks>-trfunction.
        <ls_orders>-task_status = SWITCH #( <ls_tasks>-trstatus
                                             WHEN sctsc_state_protected OR sctsc_state_changeable THEN sctsc_state_changeable
                                             WHEN sctsc_state_released OR sctsc_state_export_started THEN sctsc_state_released ).

        TRY.
            <ls_orders>-task_status_desc = mo_order_md->get_status_desc( <ls_orders>-task_status ).
          CATCH cx_sy_itab_line_not_found.
        ENDTRY.

        TRY.
            <ls_orders>-task_type_desc = mo_order_md->get_function_desc( <ls_tasks>-trfunction ).
          CATCH cx_sy_itab_line_not_found.
        ENDTRY.

      ENDLOOP.
      IF sy-subrc NE 0.
        INSERT ls_orders INTO TABLE et_orders.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD instance_badi_transport_copy.

    TRY.
        IF mo_handle_badi_transport_copy IS NOT BOUND.
          GET BADI mo_handle_badi_transport_copy.
        ENDIF.
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.


  METHOD read_request.

    rs_data-h-trkorr = iv_order.

    CALL FUNCTION 'TR_READ_REQUEST'
      EXPORTING
        iv_read_e070       = 'X'
        iv_read_e07t       = 'X'
        iv_read_e070c      = 'X'
        iv_read_e070m      = 'X'
        iv_read_objs_keys  = 'X'
        iv_read_attributes = 'X'
      CHANGING
        cs_request         = rs_data
      EXCEPTIONS
        OTHERS             = 1.
    IF sy-subrc NE 0.
      DATA(lv_message) = zcl_spt_utilities=>fill_return( iv_type = zif_spt_core_data=>cs_message-type_error
                                                                 iv_id = zcl_spt_trans_order_data=>cs_message-id
                                                                 iv_number = '009'
                                                                 iv_message_v1 = iv_order
                                                                 iv_langu      = mv_langu )-message.

      RAISE EXCEPTION TYPE zcx_spt_trans_order
        EXPORTING
          textid   = zcx_spt_trans_order=>message_other_class
          mv_msgv1 = lv_message.
    ENDIF.

  ENDMETHOD.


  METHOD release_order.

    CLEAR: es_return, ev_status, ev_status_desc.

    instance_badi_transport_copy(  ).


    call_badi_before_release_order( EXPORTING iv_order = iv_order
                                    CHANGING cs_return = es_return ).

    IF es_return IS INITIAL.
      CALL FUNCTION 'TRINT_RELEASE_REQUEST'
        EXPORTING
          iv_trkorr                   = iv_order
          iv_dialog                   = abap_false
          iv_as_background_job        = abap_false
          iv_success_message          = abap_false
          iv_without_objects_check    = abap_false
          iv_without_locking          = iv_without_locking " Evitamos el error de objetos de bloqueo por transporte de copias
          iv_display_export_log       = abap_false
        EXCEPTIONS
          cts_initialization_failure  = 1
          enqueue_failed              = 2
          no_authorization            = 3
          invalid_request             = 4
          request_already_released    = 5
          repeat_too_early            = 6
          object_lock_error           = 7
          object_check_error          = 8
          docu_missing                = 9
          db_access_error             = 10
          action_aborted_by_user      = 11
          export_failed               = 12
          execute_objects_check       = 13
          release_in_bg_mode          = 14
          release_in_bg_mode_w_objchk = 15
          error_in_export_methods     = 16
          object_lang_error           = 17.
      IF sy-subrc = 0.
        es_return = VALUE #( type = zif_spt_core_data=>cs_message-type_success
                              message = zcl_spt_utilities=>fill_return( iv_type = zif_spt_core_data=>cs_message-type_success
                                                                        iv_id = zcl_spt_trans_order_data=>cs_message-id
                                                                        iv_number = '001'
                                                                        iv_message_v1 = iv_order
                                                                        iv_langu      = mv_langu )-message ).

        " Si se quiere el status del resultado de liberar lo busco en la E070 y busco su descripción
        IF ev_status IS SUPPLIED.
          SELECT SINGLE trstatus INTO ev_status
                 FROM e070
                 WHERE trkorr = iv_order.
          IF sy-subrc = 0.
            ev_status_desc = mo_order_md->get_status_desc( ev_status ).
          ENDIF.
        ENDIF.

      ELSE.
        DATA(lv_msgno) = sy-msgno.
        DATA(lv_msgid) = sy-msgid.
        DATA(lv_msgv1) = sy-msgv1.
        DATA(lv_msgv2) = sy-msgv2.
        DATA(lv_msgv3) = sy-msgv3.
        DATA(lv_msgv4) = sy-msgv4.

        es_return = VALUE #( type = zif_spt_core_data=>cs_message-type_error
                             message = zcl_spt_utilities=>fill_return( iv_type = zif_spt_core_data=>cs_message-type_error
                                                                       iv_id = sy-msgid
                                                                       iv_number = sy-msgno
                                                                       iv_message_v1 = sy-msgv1
                                                                       iv_message_v2 = sy-msgv2
                                                                       iv_message_v3 = sy-msgv3
                                                                       iv_message_v4 = sy-msgv4
                                                                       iv_langu      = mv_langu )-message ).
        " Para los mensajes estándar si no hay texto mensaje y el idioma global difiere al idioma
        " de conexión entonces saco el mensae en el idioma de logon.
        IF es_return-message IS INITIAL AND mv_langu NE sy-langu.
          es_return = VALUE #( type = zif_spt_core_data=>cs_message-type_error
                              message = zcl_spt_utilities=>fill_return( iv_type = zif_spt_core_data=>cs_message-type_error
                                                                        iv_id = lv_msgid
                                                                        iv_number = lv_msgno
                                                                        iv_message_v1 = lv_msgv1
                                                                        iv_message_v2 = lv_msgv2
                                                                        iv_message_v3 = lv_msgv3
                                                                        iv_message_v4 = lv_msgv4
                                                                        iv_langu      = mv_langu )-message ).
        ENDIF.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD update_order.
    DATA ls_e070 TYPE e070.
    DATA ls_e07t TYPE e07t.

    CLEAR: rs_return.

    TRY.

        " Primero leemos los datos de la orden
        DATA(ls_data) = read_request( iv_order ).

        " Si el usuario que viene por parámetro no es tán blanco y es diferente al que tiene lo modifico.
        DATA(lv_user_changed) = abap_false.
        IF is_data-user IS NOT INITIAL AND is_data-user NE ls_data-h-as4user.
          lv_user_changed = abap_true.
          DATA(ls_return_change) = change_user_order( iv_user  = is_data-user
                                         iv_order = iv_order ).

          IF ls_return_change-type = zif_spt_core_data=>cs_message-type_error.
            rs_return = ls_return_change.
            EXIT.
          ENDIF.
        ENDIF.

        " Datos cabecera
        ls_e070 = ls_data-h.

        " Descripción
        ls_e07t-trkorr = ls_e070-trkorr.
        ls_e07t-langu = mv_langu.
        ls_e07t-as4text = ls_data-h-as4text.

        DATA(lv_change_header) = abap_false.

        " Si viene descripción y es distinta a la que tiene
        IF is_data-description IS NOT INITIAL AND is_data-description NE ls_data-h-as4text.
          lv_change_header = abap_true.
          ls_e07t-as4text = is_data-description.
        ENDIF.

        IF lv_change_header = abap_true.
          CALL FUNCTION 'TRINT_UPDATE_COMM_HEADER'
            EXPORTING
              wi_e070     = ls_e070
              wi_e07t     = ls_e07t
              wi_sel_e070 = abap_false
              wi_sel_e07t = abap_true
            EXCEPTIONS
              OTHERS      = 1.
          IF sy-subrc = 0.
            rs_return = VALUE #( type = zif_spt_core_data=>cs_message-type_success
                        message = zcl_spt_utilities=>fill_return( iv_id = zcl_spt_trans_order_data=>cs_message-id
                                                                  iv_number = '007'
                                                                  iv_message_v1 = iv_order
                                                                  iv_langu  = mv_langu )-message ).
          ELSE.
            rs_return = VALUE #( type = zif_spt_core_data=>cs_message-type_error
                                   message = zcl_spt_utilities=>fill_return( iv_id = zcl_spt_trans_order_data=>cs_message-id
                                                                             iv_number = '006'
                                                                             iv_message_v1 = iv_order
                                                                             iv_langu  = mv_langu )-message ).
          ENDIF.
        ENDIF.

        " Si no se modifica la cabecera pero si el usuario devuelvo el resultado del cambio de usuario
        IF lv_change_header = abap_false AND lv_user_changed = abap_true.
          rs_return = ls_return_change.
        ELSEIF lv_change_header = abap_false AND lv_user_changed = abap_false.
          rs_return = VALUE #( type = zif_spt_core_data=>cs_message-type_success
                          message = zcl_spt_utilities=>fill_return( iv_id = zcl_spt_trans_order_data=>cs_message-id
                                                                    iv_number = '008'
                                                                    iv_message_v1 = iv_order
                                                                    iv_langu  = mv_langu )-message ).
        ENDIF.



      CATCH zcx_spt_trans_order INTO DATA(lo_excep).
        rs_return = zcl_spt_utilities=>fill_return( iv_type = zif_spt_core_data=>cs_message-type_error
                                                iv_id = lo_excep->if_t100_message~t100key-msgid
                                                iv_number = lo_excep->if_t100_message~t100key-msgno
                                                iv_message_v1 = lo_excep->mv_msgv1 ).
    ENDTRY.
  ENDMETHOD.


  METHOD zif_spt_core_app~get_app_type.
    CLEAR: es_app.

    es_app-app = 'TRANS_ORDER'.
    es_app-app_desc = 'Transport order'(t01).
    es_app-service = '/ZSAP_TOOLS_TRANS_ORDER_SRV'.
    es_app-frontend_page = '/transportOrder'.
    es_app-icon = 'shipping-status'.
    es_app-url_help = 'https://github.com/irodrigob/abap-sap-tools-trans-order/wiki'.
  ENDMETHOD.
  METHOD release_multiple_orders.

    CLEAR: et_return.

    IF it_orders IS NOT INITIAL.

      " Buscamos las ordenes/tareas filtrando las que no esten liberadas. En el caso de ordenes se aprovecha
      " para buscar sus tareas
      DATA(lt_r_trkorr) = VALUE zcl_spt_trans_order_data=>tt_r_orders( FOR <wa> IN it_orders ( sign = 'I' option = 'EQ' low = <wa> ) ).
      SELECT trkorr, strkorr
             FROM e070
             WHERE trstatus NE @zcl_spt_trans_order_data=>cs_orders-status-released
                   AND trstatus NE @zcl_spt_trans_order_data=>cs_orders-status-released_repaired
                   AND trkorr IN @lt_r_trkorr
      UNION
      SELECT trkorr, strkorr
             FROM e070
             WHERE trstatus NE @zcl_spt_trans_order_data=>cs_orders-status-released
                   AND trstatus NE @zcl_spt_trans_order_data=>cs_orders-status-released_repaired
                   AND strkorr IN @lt_r_trkorr
            INTO TABLE @DATA(lt_orders).
      IF sy-subrc = 0.

        " Primero se libera las tareas
        LOOP AT lt_orders ASSIGNING FIELD-SYMBOL(<ls_orders>) WHERE strkorr IS NOT INITIAL.
          INSERT VALUE #( order = <ls_orders>-trkorr ) INTO TABLE et_return ASSIGNING FIELD-SYMBOL(<ls_return>).
          release_order( EXPORTING iv_without_locking = iv_without_locking
                                    iv_order           = <ls_orders>-trkorr
                         IMPORTING es_return = DATA(ls_return_order)
                                   ev_status = <ls_return>-status
                                   ev_status_desc = <ls_return>-status_desc ).

          <ls_return> = CORRESPONDING #( BASE ( <ls_return> ) ls_return_order ).
        ENDLOOP.

        " Segundo las ordenes
        LOOP AT lt_orders ASSIGNING <ls_orders> WHERE strkorr IS INITIAL.
          INSERT VALUE #( order = <ls_orders>-trkorr ) INTO TABLE et_return ASSIGNING <ls_return>.
          release_order( EXPORTING iv_without_locking = iv_without_locking
                                   iv_order           = <ls_orders>-trkorr
                         IMPORTING es_return = DATA(ls_return_task)
                                   ev_status = <ls_return>-status
                                   ev_status_desc = <ls_return>-status_desc ).

          <ls_return> = CORRESPONDING #( BASE ( <ls_return> ) ls_return_task ).
        ENDLOOP.

      ELSE.
        INSERT VALUE #( type = zif_spt_core_data=>cs_message-type_error
                                      message = zcl_spt_utilities=>fill_return( iv_id = zcl_spt_trans_order_data=>cs_message-id
                                                                                iv_number = '010'
                                                                                iv_langu = mv_langu )-message ) INTO TABLE et_return.
      ENDIF.
    ELSE.
      INSERT VALUE #( type = zif_spt_core_data=>cs_message-type_error
                                       message = zcl_spt_utilities=>fill_return( iv_id = zcl_spt_trans_order_data=>cs_message-id
                                                                                 iv_number = '010'
                                                                                 iv_langu = mv_langu )-message ) INTO TABLE et_return.
    ENDIF.
  ENDMETHOD.

  METHOD constructor.
    super->constructor( iv_langu = iv_langu ).

    mo_order_md = NEW #( iv_langu = iv_langu ).
  ENDMETHOD.

ENDCLASS.