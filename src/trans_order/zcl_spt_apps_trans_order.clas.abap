CLASS zcl_spt_apps_trans_order DEFINITION
  PUBLIC
  INHERITING FROM zcl_spt_apps_base
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ts_objects_key,
        pgmid    TYPE pgmid,
        object   TYPE trobjtype,
        obj_name TYPE trobj_name,
      END OF ts_objects_key .
    TYPES:
      tt_objects_key TYPE STANDARD TABLE OF ts_objects_key WITH EMPTY KEY .
    TYPES:
      BEGIN OF ts_orders_task_data,
        order             TYPE trkorr,
        order_desc        TYPE string,
        order_user        TYPE uname,
        order_status      TYPE trstatus,
        order_status_desc TYPE val_text,
        order_type        TYPE trfunction,
        order_type_desc   TYPE val_text,
        order_has_objects TYPE sap_bool,
        task              TYPE trkorr,
        task_desc         TYPE string,
        task_user         TYPE uname,
        task_status       TYPE trstatus,
        task_status_desc  TYPE val_text,
        task_type         TYPE trfunction,
        task_type_desc    TYPE val_text,
        task_has_objects  TYPE sap_bool,
      END OF ts_orders_task_data .
    TYPES:
      tt_orders_task_data TYPE STANDARD TABLE OF ts_orders_task_data WITH EMPTY KEY .
    TYPES:
      BEGIN OF ts_systems_transport,
        system_name TYPE sysname,
        system_desc TYPE string,
      END OF ts_systems_transport .
    TYPES:
      BEGIN OF ts_update_order,
        user        TYPE tr_as4user,
        description TYPE as4text,
      END OF ts_update_order .
    TYPES:
      tt_systems_transport TYPE STANDARD TABLE OF ts_systems_transport WITH EMPTY KEY .
    TYPES:
      BEGIN OF ts_release_multiple_orders,
        order       TYPE trkorr,
        task        TYPE trkorr,
        status      TYPE trstatus,
        status_desc TYPE val_text.
        INCLUDE TYPE zcl_spt_core_data=>ts_return.
    TYPES:
           END OF ts_release_multiple_orders .
    TYPES:
      tt_release_multiple_orders TYPE STANDARD TABLE OF ts_release_multiple_orders WITH EMPTY KEY .
    TYPES:
      BEGIN OF ts_order_objects,
        order       TYPE trkorr,
        as4pos      TYPE ddposition,
        pgmid       TYPE pgmid,
        object      TYPE trobjtype,
        object_desc TYPE ddtext,
        obj_name    TYPE trobj_name,
        objfunc     TYPE objfunc,
        lockflag    TYPE lockflag,
        gennum      TYPE trgennum,
        lang        TYPE spras,
        activity    TYPE tractivity,
      END OF ts_order_objects .
    TYPES:
      tt_orders_objects TYPE STANDARD TABLE OF ts_order_objects WITH EMPTY KEY .
    TYPES:
      BEGIN OF ts_input_delete_objects,
        order    TYPE trkorr,
        pgmid    TYPE pgmid,
        object   TYPE trobjtype,
        obj_name TYPE trobj_name,
      END OF ts_input_delete_objects .
    TYPES:
      tt_input_delete_objects TYPE STANDARD TABLE OF ts_input_delete_objects WITH DEFAULT KEY .
    TYPES:
      BEGIN OF ts_return_delete_objects.
        INCLUDE TYPE ts_input_delete_objects.
        INCLUDE TYPE zcl_spt_core_data=>ts_return.
    TYPES:
           END OF ts_return_delete_objects .
    TYPES:
      tt_return_delete_objects TYPE STANDARD TABLE OF ts_return_delete_objects WITH DEFAULT KEY .
    TYPES:
      BEGIN OF ts_delete_orders,
        order TYPE trkorr,
        task  TYPE trkorr.
        INCLUDE TYPE zcl_spt_core_data=>ts_return.
    TYPES:
           END OF ts_delete_orders .
    TYPES:
      tt_delete_orders TYPE STANDARD TABLE OF ts_delete_orders WITH EMPTY KEY .
    TYPES:
      BEGIN OF ts_move_objects,
        order TYPE trkorr.
        INCLUDE TYPE ts_objects_key.
    TYPES:
           END OF ts_move_objects .
    TYPES:
      tt_move_objects TYPE STANDARD TABLE OF ts_move_objects WITH EMPTY KEY .

    "! <p class="shorttext synchronized">Devuelve las ordenes de un usuario</p>
    "! @parameter iv_langu | <p class="shorttext synchronized">Idioma</p>
    METHODS constructor
      IMPORTING
        !iv_langu TYPE sylangu DEFAULT sy-langu .
    "! <p class="shorttext synchronized">Devuelve las ordenes de un usuario</p>
    "! @parameter iv_username | <p class="shorttext synchronized">Usuario</p>
    "! @parameter iv_type_workbench | <p class="shorttext synchronized">Ordenes workbench</p>
    "! @parameter iv_type_customizing | <p class="shorttext synchronized">Ordenes customizing</p>
    "! @parameter iv_type_transport | <p class="shorttext synchronized">Transporte de copias</p>
    "! @parameter iv_status_modif | <p class="shorttext synchronized">Status modificable</p>
    "! @parameter iv_status_release | <p class="shorttext synchronized">Status liberadas</p>
    "! @parameter iv_release_from_data | <p class="shorttext synchronized">Ordenes liberadas desde</p>
    "! @parameter iv_release_from_to | <p class="shorttext synchronized">Ordenes liberadas desde</p>
    "! @parameter iv_get_has_objects | <p class="shorttext synchronized">Verificar si tiene objetos</p>
    "! @parameter iv_complete_projects | <p class="shorttext synchronized">Devuelve todas las tareas de las ordenes y las ordenes de la</p>
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
        !iv_get_has_objects   TYPE sap_bool DEFAULT abap_true
        !iv_complete_projects TYPE sap_bool DEFAULT abap_true
      EXPORTING
        !et_orders            TYPE tt_orders_task_data .
    "! <p class="shorttext synchronized">Sistemas de transporte</p>
    "! @parameter rt_systems | <p class="shorttext synchronized">Sistemas</p>
    METHODS get_systems_transport
      RETURNING
        VALUE(rt_systems) TYPE tt_systems_transport .
    "! <p class="shorttext synchronized">Hacer transporte de copia</p>
    "! @parameter it_orders | <p class="shorttext synchronized">Ordenes</p>
    "! @parameter iv_system | <p class="shorttext synchronized">Sistema</p>
    "! @parameter iv_description | <p class="shorttext synchronized">Descripción</p>
    "! @parameter iv_release_order_new_task | <p class="shorttext synchronized">Liberar la orden/tarea en nueva tarea</p>
    "! @parameter et_return | <p class="shorttext synchronized">Retorno del proceso</p>
    "! @parameter ev_order | <p class="shorttext synchronized">Orden creada</p>
    METHODS do_transport_copy
      IMPORTING
        !it_orders                 TYPE zcl_spt_trans_order_data=>tt_orders
        !iv_system                 TYPE sysname
        !iv_description            TYPE string
        !iv_release_order_new_task TYPE sap_bool DEFAULT abap_true
      EXPORTING
        !et_return                 TYPE zcl_spt_core_data=>tt_return
        !ev_order                  TYPE trkorr .
    "! <p class="shorttext synchronized">Liberación de una orden/tarea</p>
    "! @parameter iv_order | <p class="shorttext synchronized">Orden/tarea</p>
    "! @parameter iv_without_locking | <p class="shorttext synchronized">Sin bloqueo de objetos</p>
    "! @parameter es_return | <p class="shorttext synchronized">Resultado del proceso</p>
    "! @parameter ev_status | <p class="shorttext synchronized">Status al liberar</p>
    "! @parameter ev_status_desc | <p class="shorttext synchronized">Descripción del status</p>
    METHODS release_order
      IMPORTING
        !iv_without_locking TYPE sap_bool DEFAULT abap_false
        !iv_order           TYPE trkorr
      EXPORTING
        !es_return          TYPE zcl_spt_core_data=>ts_return
        !ev_status          TYPE trstatus
        !ev_status_desc     TYPE val_text .
    "! <p class="shorttext synchronized">Liberación de multiples ordenes/tareas</p>
    "! @parameter it_order | <p class="shorttext synchronized">Lista de ordenes/tareas</p>
    "! @parameter iv_without_locking | <p class="shorttext synchronized">Sin bloqueo de objetos</p>
    "! @parameter et_return | <p class="shorttext synchronized">Retorno del proceso</p>
    METHODS release_multiple_orders
      IMPORTING
        !iv_without_locking TYPE sap_bool DEFAULT abap_false
        !it_orders          TYPE zcl_spt_trans_order_data=>tt_orders
      RETURNING
        VALUE(et_return)    TYPE tt_release_multiple_orders .
    "! <p class="shorttext synchronized">Actualiza los datos de una orden/tarea</p>
    "! @parameter iv_order | <p class="shorttext synchronized">Orden/tarea</p>
    "! @parameter is_data | <p class="shorttext synchronized">Valores</p>
    "! @parameter rs_return | <p class="shorttext synchronized">Resultado del proceso</p>
    METHODS update_order
      IMPORTING
        !iv_order        TYPE trkorr
        !is_data         TYPE ts_update_order
      RETURNING
        VALUE(rs_return) TYPE zcl_spt_core_data=>ts_return .
    "! <p class="shorttext synchronized">Cambio del usuario de la orden</p>
    "! @parameter iv_user | <p class="shorttext synchronized">Usuario</p>
    "! @parameter iv_order | <p class="shorttext synchronized">Orden/tarea</p>
    "! @parameter rs_return | <p class="shorttext synchronized">Resultado del proceso</p>
    METHODS change_user_order
      IMPORTING
        !iv_user         TYPE tr_as4user
        !iv_order        TYPE trkorr
      RETURNING
        VALUE(rs_return) TYPE zcl_spt_core_data=>ts_return .
    "! <p class="shorttext synchronized">Devuelve los objetos de una orden</p>
    "! @parameter it_order | <p class="shorttext synchronized">Lista de ordenes/tareas</p>
    "! @parameter rt_objects | <p class="shorttext synchronized">Lista de objetos</p>
    METHODS get_orders_objects
      IMPORTING
        !it_orders        TYPE zcl_spt_trans_order_data=>tt_orders
      RETURNING
        VALUE(rt_objects) TYPE tt_orders_objects .
    "! <p class="shorttext synchronized">Borra objetos de una orden</p>
    "! @parameter it_objects | <p class="shorttext synchronized">Objetos</p>
    "! @parameter rt_return | <p class="shorttext synchronized">Retorno del proceso</p>
    METHODS delete_order_objects
      IMPORTING
        !it_objects      TYPE tt_input_delete_objects
      RETURNING
        VALUE(rt_return) TYPE tt_return_delete_objects .
    "! <p class="shorttext synchronized">Borrado de ordenes y tareas</p>
    "! @parameter it_order | <p class="shorttext synchronized">Lista de ordenes/tareas</p>
    "! @parameter et_return | <p class="shorttext synchronized">Resultado del proceso</p>
    METHODS delete_orders
      IMPORTING
        !it_orders       TYPE zcl_spt_trans_order_data=>tt_orders
      RETURNING
        VALUE(rt_return) TYPE tt_delete_orders .
    "! <p class="shorttext synchronized">Creación de orden y su tarea</p>
    "! @parameter iv_type | <p class="shorttext synchronized">Tipo de orden</p>
    "! @parameter iv_system | <p class="shorttext synchronized">Sistema</p>
    "! @parameter iv_description | <p class="shorttext synchronized">Descripción</p>
    "! @parameter iv_user | <p class="shorttext synchronized">Usuario</p>
    "! @parameter iv_user | <p class="shorttext synchronized">Usuario</p>
    "! @parameter it_users | <p class="shorttext synchronized">Usuarios de las tareas</p>
    "! @parameter ev_order | <p class="shorttext synchronized">Orden creada</p>
    METHODS create_order_and_task
      IMPORTING
        !iv_type        TYPE trfunction
        !iv_description TYPE string
        !iv_system      TYPE sysname OPTIONAL
        !iv_user        TYPE syuname DEFAULT sy-uname
        !it_users_task  TYPE zcl_spt_trans_order_data=>tt_users OPTIONAL
      EXPORTING
        !es_return      TYPE zcl_spt_core_data=>ts_return
        !ev_order       TYPE trkorr
        !et_order_data  TYPE tt_orders_task_data .
    "! <p class="shorttext synchronized">Mueve los objetos de varias ordenes a una orden</p>
    "! @parameter it_objects | <p class="shorttext synchronized">Objetos</p>
    "! @parameter iv_order_to | <p class="shorttext synchronized">Orden destino</p>
    "! @parameter et_return | <p class="shorttext synchronized">Retorno del proceso</p>
    METHODS move_orders_objects
      IMPORTING
        !it_objects  TYPE tt_move_objects
        !iv_order_to TYPE trkorr
      EXPORTING
        !et_return   TYPE zcl_spt_core_data=>tt_return .
    "! <p class="shorttext synchronized">Mueve los objetos de una orden a otra</p>
    "! @parameter it_objects | <p class="shorttext synchronized">Objetos</p>
    "! @parameter iv_order_to | <p class="shorttext synchronized">Orden destino</p>
    "! @parameter iv_order_from | <p class="shorttext synchronized">Orden origen</p>
    "! @parameter et_return | <p class="shorttext synchronized">Retorno del proceso</p>
    METHODS move_order_objects
      IMPORTING
        !it_objects    TYPE tt_objects_key
        !iv_order_from TYPE trkorr
        !iv_order_to   TYPE trkorr
      EXPORTING
        !et_return     TYPE zcl_spt_core_data=>tt_return .
    "! <p class="shorttext synchronized">Bloqueos de objetos en la orden</p>
    "! @parameter iv_order | <p class="shorttext synchronized">Orden/tarea</p>
    "! @parameter it_objects | <p class="shorttext synchronized">Objetos</p>
    "! @parameter rt_return | <p class="shorttext synchronized">Retorno del proceso</p>
    METHODS lock_objects
      IMPORTING
        !iv_order        TYPE trkorr
        !it_objects      TYPE tt_objects_key
      RETURNING
        VALUE(rt_return) TYPE zcl_spt_core_data=>tt_return
      RAISING
        zcx_spt_trans_order .

    METHODS zif_spt_core_app~get_app_type
        REDEFINITION .
  PROTECTED SECTION.
    TYPES tt_objects_texts TYPE STANDARD TABLE OF ko100 WITH DEFAULT KEY.
    TYPES: tv_allowed_request_types TYPE c LENGTH 20.
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
    "! @parameter iv_user | <p class="shorttext synchronized">Usuario</p>
    "! @parameter iv_get_order_data | <p class="shorttext synchronized">Se devuelve los datos de la orden creada</p>
    "! @parameter ev_order | <p class="shorttext synchronized">Orden creada</p>
    METHODS create_order
      IMPORTING
        iv_type           TYPE trfunction
        iv_description    TYPE string
        iv_system         TYPE sysname OPTIONAL
        iv_user           TYPE syuname DEFAULT sy-uname
        iv_get_order_data TYPE sap_bool DEFAULT abap_false
      EXPORTING
        es_return         TYPE zcl_spt_core_data=>ts_return
        ev_order          TYPE trkorr
        es_order_data     TYPE ts_orders_task_data.

    "! <p class="shorttext synchronized">Copia el contenido de unas ordenes a otra orden</p>
    "! @parameter it_from_orders | <p class="shorttext synchronized">Ordenes origen</p>
    "! @parameter iv_to_order | <p class="shorttext synchronized">Orden destino</p>
    METHODS copy_content_orders_2_order
      IMPORTING
        it_from_orders TYPE zcl_spt_trans_order_data=>tt_orders
        iv_to_order    TYPE trkorr
      EXPORTING
        et_return      TYPE zcl_spt_core_data=>tt_return.
    "! <p class="shorttext synchronized">Verifica si hay objetos inactivos en las ordenes</p>
    "! @parameter it_orders | <p class="shorttext synchronized">Ordenes origen</p>
    "! @parameter et_return | <p class="shorttext synchronized">Resultado del proceso</p>
    METHODS check_inactive_objects
      IMPORTING
        it_orders TYPE zcl_spt_trans_order_data=>tt_orders
      EXPORTING
        et_return TYPE zcl_spt_core_data=>tt_return.
    "! <p class="shorttext synchronized">Lectura de datos completos de una orden</p>
    "! @parameter iv_order | <p class="shorttext synchronized">Orden</p>
    "! @parameter iv_read_objects | <p class="shorttext synchronized">Obtener objetos de la orden</p>
    "! @parameter rs_data | <p class="shorttext synchronized">Datos del orden</p>
    METHODS read_request_complete
      IMPORTING
                iv_order        TYPE trkorr
                iv_read_objects TYPE sap_bool DEFAULT abap_false
      RETURNING
                VALUE(rs_data)  TYPE trwbo_request
      RAISING   zcx_spt_trans_order.
    "! <p class="shorttext synchronized">Lectura de datos una orden</p>
    "! Solo se devuelve la información de cabecera
    "! @parameter iv_order | <p class="shorttext synchronized">Orden</p>
    "! @parameter rs_data | <p class="shorttext synchronized">Datos del orden</p>
    METHODS read_request
      IMPORTING
                iv_order       TYPE trkorr
      RETURNING
                VALUE(rs_data) TYPE trwbo_request_header

      RAISING   zcx_spt_trans_order.
    "! <p class="shorttext synchronized">Lectura de datos de la orden y sus tareas</p>
    "! Solo se devuelve la información de cabecera
    "! @parameter iv_order | <p class="shorttext synchronized">Orden</p>
    "! @parameter rt_data | <p class="shorttext synchronized">Datos del orden</p>
    METHODS read_request_and_task
      IMPORTING
                iv_order       TYPE trkorr
      RETURNING
                VALUE(rt_data) TYPE trwbo_request_headers
      RAISING   zcx_spt_trans_order.
    "! <p class="shorttext synchronized">Lectura de los datos de las ordenes</p>
    "! @parameter it_orders | <p class="shorttext synchronized">Ordenes</p>
    "! @parameter iv_read_objects | <p class="shorttext synchronized">Obtener objetos de la orden</p>
    "! @parameter rt_return | <p class="shorttext synchronized">Resultado del proceso</p>
    METHODS get_orders_info
      IMPORTING
                it_orders        TYPE zcl_spt_trans_order_data=>tt_orders
                iv_read_objects  TYPE sap_bool DEFAULT abap_false
      RETURNING VALUE(rt_return) TYPE zcl_spt_core_data=>tt_return.
    "! <p class="shorttext synchronized">Llama al método antes de liberar </p>
    "! @parameter iv_order | <p class="shorttext synchronized">Orden</p>
    "! @parameter cs_return | <p class="shorttext synchronized">Resultado del proceso</p>
    METHODS call_badi_before_release_order
      IMPORTING
        iv_order  TYPE trkorr
      CHANGING
        cs_return TYPE zcl_spt_core_data=>ts_return.
    "! <p class="shorttext synchronized">Instancia la BADI de transporte de copias</p>
    METHODS instance_badi_transport_copy.
    "! <p class="shorttext synchronized">Lee los textos de los objetos</p>
    "! @parameter rt_object_text | <p class="shorttext synchronized">Textos de los objetos</p>
    METHODS read_object_texts
      RETURNING
        VALUE(rt_object_text) TYPE tt_objects_texts.
    "! <p class="shorttext synchronized">Borrado de una orden o tarea</p>
    "! @parameter iv_order | <p class="shorttext synchronized">Lista de ordenes/tareas</p>
    "! @parameter es_return | <p class="shorttext synchronized">Resultado del proceso</p>
    "! @parameter et_deleted_task | <p class="shorttext synchronized">Tareas borradas</p>
    METHODS delete_order
      IMPORTING iv_order         TYPE trkorr
      RETURNING VALUE(rt_return) TYPE tt_delete_orders.
    "! <p class="shorttext synchronized">Convierte cabecera de la orden al formato de la aplicacion</p>
    "! @parameter it_request | <p class="shorttext synchronized">Datos de la orden</p>
    "! @parameter iv_get_has_objects | <p class="shorttext synchronized">Verificar si tiene objetos</p>
    "! @parameter rt_order_data | <p class="shorttext synchronized">Datos convertidos</p>
    METHODS convert_req_header
      IMPORTING
        it_request           TYPE trwbo_request_headers
        iv_get_has_objects   TYPE sap_bool DEFAULT abap_true
      RETURNING
        VALUE(rt_order_data) TYPE zcl_spt_apps_trans_order=>tt_orders_task_data.
    "! <p class="shorttext synchronized">Verifica si una orden es modificable</p>
    "! @parameter is_request_header | <p class="shorttext synchronized">Datos de la orden</p>
    "! @parameter iv_allowed_request_types | <p class="shorttext synchronized">Tipos de orden/tarea permitidos</p>
    "! @parameter rs_return | <p class="shorttext synchronized">Resultado del proceso</p>
    METHODS check_request_changeable
      IMPORTING
                is_request_header        TYPE trwbo_request_header
                iv_allowed_request_types TYPE tv_allowed_request_types DEFAULT 'CDFKOPTWS'
      RETURNING VALUE(rs_return)         TYPE zcl_spt_core_data=>ts_return.
    "! <p class="shorttext synchronized">Chequea si una orden esta bloqueada</p>
    "! @parameter iv_order | <p class="shorttext synchronized">Orden</p>
    "! @parameter rs_return | <p class="shorttext synchronized">Resultado</p>
    METHODS check_order_locked
      IMPORTING iv_order         TYPE trkorr
      RETURNING VALUE(rs_return) TYPE zcl_spt_core_data=>ts_return.
    "! <p class="shorttext synchronized">Chequea que todas las ordenes no esten bloqueadas</p>
    "! @parameter it_orders | <p class="shorttext synchronized">Ordenes</p>
    "! @parameter rs_return | <p class="shorttext synchronized">Resultado</p>
    METHODS check_orders_locked
      IMPORTING
        it_orders        TYPE zcl_spt_trans_order_data=>tt_orders
      RETURNING
        VALUE(rs_return) TYPE zcl_spt_core_data=>ts_return.
    "! <p class="shorttext synchronized">Añade los objetos a una orden</p>
    "! @parameter it_e071 | <p class="shorttext synchronized">Objetos</p>
    "! @parameter it_e071k | <p class="shorttext synchronized">Clave</p>
    "! @parameter iv_order | <p class="shorttext synchronized">Orden</p>
    "! @parameter rt_return | <p class="shorttext synchronized">Resultado del proceso</p>
    METHODS add_objects_order
      IMPORTING
        it_e071          TYPE trwbo_t_e071
        it_e071k         TYPE trwbo_t_e071k
        iv_order         TYPE trkorr
      RETURNING
        VALUE(rt_return) TYPE zcl_spt_core_data=>tt_return.
    "! <p class="shorttext synchronized">Actualiza los objetos a una orden</p>
    "! Este método es similar al ADD_OBJECTS_ORDER pero la función usada no verifica
    "! cosas como bloqueos de objetos. Con lo cual es más útil en procesos de mover o copiar objetos.
    "! @parameter it_e071_add | <p class="shorttext synchronized">Objetos a añadir</p>
    "! @parameter it_e071k_add | <p class="shorttext synchronized">Claves a añadir</p>
    "! @parameter iv_order | <p class="shorttext synchronized">Orden</p>
    "! @parameter rt_return | <p class="shorttext synchronized">Resultado del proceso</p>
    METHODS update_objects_orders
      IMPORTING
                it_e071_add      TYPE trwbo_t_e071 OPTIONAL
                it_e071k_add     TYPE trwbo_t_e071k OPTIONAL
                iv_order         TYPE trkorr
      RETURNING
                VALUE(rt_return) TYPE zcl_spt_core_data=>tt_return
      RAISING   zcx_spt_trans_order .
    "! <p class="shorttext synchronized">Borrado objetos todas las tareas de una orden</p>
    "! @parameter it_object | <p class="shorttext synchronized">Objetos</p>
    "! @parameter it_exclude_task | <p class="shorttext synchronized">Exclusión de tareas</p>
    "! @parameter iv_order | <p class="shorttext synchronized">Orden</p>
    METHODS delete_objects_from_all_task
      IMPORTING
        it_objects      TYPE zcl_spt_apps_trans_order=>tt_objects_key
        it_exclude_task TYPE zcl_spt_trans_order_data=>tt_orders OPTIONAL
        iv_order        TYPE e070-strkorr.

  PRIVATE SECTION.





ENDCLASS.



CLASS zcl_spt_apps_trans_order IMPLEMENTATION.


  METHOD add_objects_order.

    CLEAR: rt_return.

    DATA(lt_e071) = it_e071.
    DATA(lt_e071k) = it_e071k.

    CALL FUNCTION 'TR_APPEND_TO_COMM_OBJS_KEYS'
      EXPORTING
        wi_suppress_key_check = 'X'    " Flag whether key syntax check is suppressed
        wi_trkorr             = iv_order
      TABLES
        wt_e071               = lt_e071
        wt_e071k              = lt_e071k
      EXCEPTIONS
        OTHERS                = 68.
    IF sy-subrc = 0.
      INSERT VALUE #( type = zcl_spt_core_data=>cs_message-type_success
                                                   message = zcl_spt_utilities=>fill_return( iv_id = zcl_spt_trans_order_data=>cs_message-id
                                                                                             iv_number = '017'
                                                                                             iv_message_v1 = iv_order
                                                                                             iv_langu      = mv_langu )-message ) INTO TABLE rt_return.
    ELSE.
      INSERT VALUE #( type = zcl_spt_core_data=>cs_message-type_error
                                 message = zcl_spt_utilities=>fill_return( iv_id = sy-msgid
                                                                           iv_number = sy-msgno
                                                                           iv_message_v1 = sy-msgv1
                                                                           iv_message_v2 = sy-msgv2
                                                                           iv_message_v3 = sy-msgv3
                                                                           iv_message_v4 = sy-msgv4
                                                                           iv_langu      = mv_langu )-message ) INTO TABLE rt_return.
    ENDIF.
  ENDMETHOD.


  METHOD call_badi_before_release_order.

    " Si la BADI esta instancia leo los datos de la orden y se la paso al método
    IF mo_handle_badi_transport_copy IS BOUND.

      TRY.
          DATA(ls_data) = read_request_complete( iv_order ).

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
            IF cs_return-type = zcl_spt_core_data=>cs_message-type_error.
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
      rs_return = VALUE #( type = zcl_spt_core_data=>cs_message-type_error
                                   message = zcl_spt_utilities=>fill_return( iv_type = zcl_spt_core_data=>cs_message-type_error
                                                                             iv_id = sy-msgid
                                                                             iv_number = sy-msgno
                                                                             iv_message_v1 = sy-msgv1
                                                                             iv_message_v2 = sy-msgv2
                                                                             iv_message_v3 = sy-msgv3
                                                                             iv_message_v4 = sy-msgv4
                                                                             iv_langu      = mv_langu )-message ).
    ELSE.
      rs_return = VALUE #( type = zcl_spt_core_data=>cs_message-type_success
                           message = zcl_spt_utilities=>fill_return( iv_type = zcl_spt_core_data=>cs_message-type_success
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
            ls_order_data = read_request_complete( iv_order = <ls_orders>
                                                   iv_read_objects = abap_true ).
          ENDIF.

          DATA(ls_e070) = CORRESPONDING e070( ls_order_data-h ).

          CALL FUNCTION 'TRINT_CHECK_INACTIVE_OBJECTS'
            EXPORTING
              is_e070 = ls_e070
              it_e071 = ls_order_data-objects
            TABLES
              et_log  = lt_log[].

          " Los mensajes de tipo A y E son errores y se devuelven
          LOOP AT lt_log ASSIGNING FIELD-SYMBOL(<ls_log>) WHERE ( severity = zcl_spt_core_data=>cs_message-type_error
                                                                  OR severity = zcl_spt_core_data=>cs_message-type_anormal ).
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
          INSERT zcl_spt_utilities=>fill_return( iv_type = zcl_spt_core_data=>cs_message-type_error
                                                 iv_id = lo_excep->if_t100_message~t100key-msgid
                                                 iv_number = lo_excep->if_t100_message~t100key-msgno
                                                 iv_message_v1 = lo_excep->mv_msgv1
                                                 iv_langu      = mv_langu ) INTO TABLE et_return.
      ENDTRY.

    ENDLOOP.

  ENDMETHOD.


  METHOD check_orders_locked.
    CLEAR rs_return.

    LOOP AT it_orders ASSIGNING FIELD-SYMBOL(<ls_orders>).
      DATA(ls_return) = check_order_locked( <ls_orders> ).
      IF ls_return IS NOT INITIAL.
        rs_return = ls_return.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD check_order_locked.
    CLEAR: rs_return.

    CALL FUNCTION 'ENQUEUE_E_TRKORR'
      EXPORTING
        trkorr         = iv_order
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2.
    IF sy-subrc = 0.
      CALL FUNCTION 'DEQUEUE_E_TRKORR'
        EXPORTING
          trkorr = iv_order.
    ELSE.
      rs_return = VALUE #( type = zcl_spt_core_data=>cs_message-type_error
                                    message = zcl_spt_utilities=>fill_return( iv_type = zcl_spt_core_data=>cs_message-type_error
                                                                              iv_id = sy-msgid
                                                                                  iv_number = sy-msgno
                                                                                  iv_message_v1 = sy-msgv1
                                                                              iv_message_v2 = sy-msgv2
                                                                              iv_message_v3 = sy-msgv3
                                                                              iv_message_v4 = sy-msgv4
                                                                              iv_langu      = mv_langu )-message ).
    ENDIF.
  ENDMETHOD.


  METHOD check_request_changeable.

    CLEAR: rs_return.

    CALL FUNCTION 'TRINT_CHECK_REQUEST_CHANGEABLE'
      EXPORTING
        is_request_header         = is_request_header
        iv_action                 = 'CHAN'
        iv_allowed_request_types  = iv_allowed_request_types
      EXCEPTIONS
        user_has_no_authority     = 2
        request_from_other_system = 3
        request_already_released  = 4
        illegal_request_type      = 5
        request_from_other_client = 6
        OTHERS                    = 99.

    IF sy-subrc NE 0.
      rs_return = VALUE #( type = zcl_spt_core_data=>cs_message-type_error
                                        message = zcl_spt_utilities=>fill_return( iv_type = zcl_spt_core_data=>cs_message-type_error
                                                                                  iv_id = sy-msgid
                                                                                  iv_number = sy-msgno
                                                                                  iv_message_v1 = sy-msgv1
                                                                                  iv_message_v2 = sy-msgv2
                                                                                  iv_message_v3 = sy-msgv3
                                                                                  iv_message_v4 = sy-msgv4
                                                                                  iv_langu      = mv_langu )-message ).
    ENDIF.
  ENDMETHOD.


  METHOD constructor.
    super->constructor( iv_langu = iv_langu ).

    mo_order_md = NEW #( iv_langu = iv_langu ).
  ENDMETHOD.


  METHOD convert_req_header.
    IF iv_get_has_objects = abap_true.
      DATA(lt_r_trkorr) = VALUE zcl_spt_trans_order_data=>tt_r_orders( FOR <wa> IN it_request ( sign = 'I' option = 'EQ' low = <wa>-trkorr ) ).
      SELECT trkorr, COUNT( * ) AS obj_numbers INTO TABLE @DATA(lt_order_with_objects)
             FROM e071
             WHERE trkorr IN @lt_r_trkorr
             GROUP BY trkorr
             ORDER BY trkorr.
    ENDIF.

    " Sacamos las padres para ir obteniendo los hijos
    LOOP AT it_request ASSIGNING FIELD-SYMBOL(<ls_request>)
                                 WHERE strkorr IS INITIAL.

      " Relleno los campos base de la orden
      DATA(ls_orders) = VALUE ts_orders_task_data( order = <ls_request>-trkorr
                                              order_user = <ls_request>-as4user
                                              order_desc = <ls_request>-as4text
                                              order_type = <ls_request>-trfunction ).
      TRY.
          ls_orders-order_type_desc =  mo_order_md->get_function_desc( <ls_request>-trfunction ).
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.

      ls_orders-order_status = SWITCH #( <ls_request>-trstatus
                                         WHEN sctsc_state_protected OR sctsc_state_changeable THEN sctsc_state_changeable
                                         ELSE <ls_request>-trstatus ).
      TRY.
          ls_orders-order_status_desc =  mo_order_md->get_status_desc( ls_orders-order_status ).
        CATCH cx_sy_itab_line_not_found.
      ENDTRY.

      IF iv_get_has_objects = abap_true AND line_exists( lt_order_with_objects[ trkorr = <ls_request>-trkorr ] ).
        ls_orders-order_has_objects = abap_true.
      ELSE.
        ls_orders-order_has_objects = abap_false.
      ENDIF.

      " Ahora las tareas de la orden
      LOOP AT it_request ASSIGNING FIELD-SYMBOL(<ls_tasks>) WHERE strkorr = <ls_request>-trkorr.
        INSERT ls_orders INTO TABLE rt_order_data ASSIGNING FIELD-SYMBOL(<ls_orders>).
        <ls_orders>-task = <ls_tasks>-trkorr.
        <ls_orders>-task_desc = <ls_tasks>-as4text.
        <ls_orders>-task_user = <ls_tasks>-as4user.
        <ls_orders>-task_type = <ls_tasks>-trfunction.
        <ls_orders>-task_status = SWITCH #( <ls_tasks>-trstatus
                                             WHEN sctsc_state_protected OR sctsc_state_changeable THEN sctsc_state_changeable
                                             WHEN sctsc_state_released OR sctsc_state_export_started THEN sctsc_state_released ).

        IF iv_get_has_objects = abap_true AND line_exists( lt_order_with_objects[ trkorr = <ls_tasks>-trkorr ] ).
          <ls_orders>-task_has_objects = abap_true.
        ELSE.
          <ls_orders>-task_has_objects = abap_false.
        ENDIF.
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
        INSERT ls_orders INTO TABLE rt_order_data.
      ENDIF.

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
        INSERT VALUE #( type = zcl_spt_core_data=>cs_message-type_error
                        message = zcl_spt_utilities=>fill_return( iv_type = zcl_spt_core_data=>cs_message-type_error
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

    CLEAR: es_return, ev_order, es_order_data.

    DATA(lv_order_text) = CONV e07t-as4text( iv_description ).

    CALL FUNCTION 'TRINT_INSERT_NEW_COMM'
      EXPORTING
        wi_kurztext   = lv_order_text
        wi_trfunction = iv_type
        iv_username   = iv_user
        iv_tarsystem  = iv_system
        wi_client     = sy-mandt
      IMPORTING
        we_trkorr     = ev_order
      EXCEPTIONS
        OTHERS        = 1.
    IF sy-subrc = 0.
      es_return = VALUE #( type = zcl_spt_core_data=>cs_message-type_success
                                 message = zcl_spt_utilities=>fill_return( iv_type = zcl_spt_core_data=>cs_message-type_success
                                                                           iv_id = zcl_spt_trans_order_data=>cs_message-id
                                                                           iv_number = '002'
                                                                           iv_message_v1 = ev_order
                                                                           iv_langu      = mv_langu )-message ).

      IF iv_get_order_data = abap_true.
        DATA(lt_order_data) = convert_req_header( VALUE #( ( read_request( ev_order ) ) ) ).
        es_order_data = lt_order_data[ 1 ].
      ENDIF.
    ELSE.

      es_return = VALUE #( type = zcl_spt_core_data=>cs_message-type_error
                           message = zcl_spt_utilities=>fill_return( iv_type = zcl_spt_core_data=>cs_message-type_error
                                                          iv_id = sy-msgid
                                                          iv_number = sy-msgno
                                                          iv_message_v1 = sy-msgv1
                                                          iv_message_v2 = sy-msgv2
                                                          iv_message_v3 = sy-msgv3
                                                          iv_message_v4 = sy-msgv4
                                                          iv_langu      = mv_langu )-message  ) .


    ENDIF.

  ENDMETHOD.


  METHOD create_order_and_task.
    DATA lt_task TYPE trwbo_request_headers .
    DATA ls_order TYPE trwbo_request_header.
    DATA lt_users TYPE scts_users.

    CLEAR: es_return, ev_order, et_order_data.

    DATA(lv_order_text) = CONV e07t-as4text( iv_description ).

    " Las ordenes de custo y workbench son las unicas que tienen tareas
    IF iv_type = sctsc_type_workbench OR iv_type = sctsc_type_customizing.
      " No añado al usuario de la propia tarea
      lt_users = VALUE #( FOR <wa> IN it_users_task WHERE ( table_line NE iv_user )
                                                    ( user = <wa>
                                                      type = SWITCH #( iv_type
                                                                       WHEN sctsc_type_workbench THEN sctsc_type_unclass_task
                                                                       WHEN sctsc_type_customizing THEN sctsc_type_cust_task ) ) ).

      INSERT VALUE #( user = iv_user
                      type = SWITCH #( iv_type
                                       WHEN sctsc_type_workbench THEN sctsc_type_unclass_task
                                       WHEN sctsc_type_customizing THEN sctsc_type_cust_task ) ) INTO TABLE lt_users.
    ENDIF.

    CALL FUNCTION 'TR_INSERT_REQUEST_WITH_TASKS'
      EXPORTING
        iv_type           = iv_type
        iv_text           = lv_order_text
        iv_owner          = iv_user
        iv_target         = iv_system
        it_users          = lt_users
      IMPORTING
        es_request_header = ls_order
        et_task_headers   = lt_task
      EXCEPTIONS
        insert_failed     = 1
        enqueue_failed    = 2
        OTHERS            = 3.

    IF sy-subrc = 0.
      es_return = VALUE #( type = zcl_spt_core_data=>cs_message-type_success
                                 message = zcl_spt_utilities=>fill_return( iv_type = zcl_spt_core_data=>cs_message-type_success
                                                                           iv_id = zcl_spt_trans_order_data=>cs_message-id
                                                                           iv_number = '002'
                                                                           iv_message_v1 = ev_order
                                                                           iv_langu      = mv_langu )-message ).

      INSERT ls_order INTO TABLE lt_task.

      et_order_data = convert_req_header( lt_task ).

    ELSE.

      es_return = VALUE #( type = zcl_spt_core_data=>cs_message-type_error
                           message = zcl_spt_utilities=>fill_return( iv_type = zcl_spt_core_data=>cs_message-type_error
                                                          iv_id = sy-msgid
                                                          iv_number = sy-msgno
                                                          iv_message_v1 = sy-msgv1
                                                          iv_message_v2 = sy-msgv2
                                                          iv_message_v3 = sy-msgv3
                                                          iv_message_v4 = sy-msgv4
                                                          iv_langu      = mv_langu )-message  ) .


    ENDIF.

  ENDMETHOD.


  METHOD delete_order.
    DATA lt_deleted_task TYPE cts_trkorrs .

    CLEAR: rt_return.

    CALL FUNCTION 'TRINT_DELETE_COMM'
      EXPORTING
        wi_dialog                     = abap_false
        wi_trkorr                     = iv_order
        iv_without_any_checks         = abap_true " Borra da igual si hay tareas liberadas
      IMPORTING
        et_deleted_tasks              = lt_deleted_task
      EXCEPTIONS
        file_access_error             = 1
        order_already_released        = 2
        order_contains_c_member       = 3
        order_contains_locked_entries = 4
        order_is_refered              = 5
        repair_order                  = 6
        user_not_owner                = 7
        delete_was_cancelled          = 8
        objects_free_but_still_locks  = 9
        order_lock_failed             = 10
        wrong_client                  = 11
        project_still_referenced      = 12
        successors_already_released   = 13
        OTHERS                        = 14.

    IF sy-subrc = 0.
      INSERT VALUE #( order = iv_order
                      type = zcl_spt_core_data=>cs_message-type_success
                      message = zcl_spt_utilities=>fill_return( iv_id = zcl_spt_trans_order_data=>cs_message-id
                                                                          iv_number = '013'
                                                                          iv_message_v1 = iv_order
                                                                          iv_langu      = mv_langu )-message  ) INTO TABLE rt_return.

      " Añado las tareas borradas si se esta borrando una orden
      LOOP AT lt_deleted_task ASSIGNING FIELD-SYMBOL(<ls_deleted_task>).
        INSERT VALUE #( order = iv_order
                        task = <ls_deleted_task>-trkorr
                        type = zcl_spt_core_data=>cs_message-type_success
                        message = zcl_spt_utilities=>fill_return( iv_id = zcl_spt_trans_order_data=>cs_message-id
                                                                  iv_number = '014'
                                                                  iv_message_v1 = <ls_deleted_task>-trkorr
                                                                  iv_langu      = mv_langu )-message  ) INTO TABLE rt_return.
      ENDLOOP.

    ELSE.

      DATA(lv_msgno) = sy-msgno.
      DATA(lv_msgid) = sy-msgid.
      DATA(lv_msgv1) = sy-msgv1.
      DATA(lv_msgv2) = sy-msgv2.
      DATA(lv_msgv3) = sy-msgv3.
      DATA(lv_msgv4) = sy-msgv4.

      DATA(lv_message) = zcl_spt_utilities=>fill_return( iv_id = sy-msgid
                                                          iv_number = sy-msgno
                                                          iv_message_v1 = sy-msgv1
                                                          iv_message_v2 = sy-msgv2
                                                          iv_message_v3 = sy-msgv3
                                                          iv_message_v4 = sy-msgv4
                                                          iv_langu      = mv_langu )-message.

      " Para los mensajes estándar si no hay texto mensaje y el idioma global difiere al idioma
      " de conexión entonces saco el mensae en el idioma de logon.
      IF lv_message IS INITIAL AND mv_langu NE sy-langu.
        lv_message = zcl_spt_utilities=>fill_return( iv_id = lv_msgid
                                                     iv_number = lv_msgno
                                                     iv_message_v1 = lv_msgv1
                                                     iv_message_v2 = lv_msgv2
                                                     iv_message_v3 = lv_msgv3
                                                     iv_message_v4 = lv_msgv4
                                                     iv_langu      = sy-langu )-message.
      ENDIF.

      INSERT VALUE #( order = iv_order
                     type = zcl_spt_core_data=>cs_message-type_error
                     message = lv_message  ) INTO TABLE rt_return.
    ENDIF.

  ENDMETHOD.


  METHOD delete_orders.
    DATA lt_deleted_tasks TYPE cts_trkorrs.

    CLEAR: rt_return.

    DATA(lt_r_trkorr) = VALUE zcl_spt_trans_order_data=>tt_r_orders( FOR <wa> IN it_orders ( sign = 'I' option = 'EQ' low = <wa> ) ).
    SELECT trkorr, strkorr
           FROM e070
           WHERE trkorr IN @lt_r_trkorr
    UNION
    SELECT trkorr, strkorr
           FROM e070
           WHERE strkorr IN @lt_r_trkorr
          INTO TABLE @DATA(lt_orders).
    IF sy-subrc = 0.
      " Primero vamos a borrar las ordenes porque la función de SAP ya borra las tareas asociadas a la orden y los objetos de las tareas
      LOOP AT lt_orders ASSIGNING FIELD-SYMBOL(<ls_orders>) WHERE strkorr IS INITIAL.
        DATA(lv_tabix_order) = sy-tabix.

        DATA(lt_return_order) = delete_order( EXPORTING iv_order = <ls_orders>-trkorr ).
        INSERT LINES OF lt_return_order INTO TABLE rt_return.

        " Quito las tareas de la orden porque el método de borrado las devuelve en la tabla
        DELETE lt_orders WHERE strkorr = <ls_orders>-trkorr.
        DELETE lt_orders INDEX lv_tabix_order.

      ENDLOOP.
      " Ahora borramos las tareas
      LOOP AT lt_orders ASSIGNING <ls_orders>.
        DATA(lt_return_task) = delete_order( EXPORTING iv_order = <ls_orders>-trkorr ).
        INSERT LINES OF lt_return_task INTO TABLE rt_return.
      ENDLOOP.
    ELSE.
      INSERT VALUE #( type = zcl_spt_core_data=>cs_message-type_error
                      message = zcl_spt_utilities=>fill_return( iv_id = zcl_spt_trans_order_data=>cs_message-id
                                                                iv_number = '010'
                                                                iv_langu = mv_langu )-message ) INTO TABLE rt_return.
    ENDIF.
  ENDMETHOD.


  METHOD delete_order_objects.

    CLEAR: rt_return.

    LOOP AT it_objects ASSIGNING FIELD-SYMBOL(<ls_objects_dummy>)
                       GROUP BY ( order = <ls_objects_dummy>-order )
                       ASSIGNING FIELD-SYMBOL(<group>).

      DATA(ls_request) = VALUE trwbo_request( h-trkorr = <group>-order ).

      LOOP AT GROUP <group> ASSIGNING FIELD-SYMBOL(<ls_objects>).

        DATA(ls_e071) = VALUE e071( trkorr = <ls_objects>-order
                                    pgmid = <ls_objects>-pgmid
                                    object = <ls_objects>-object
                                    obj_name = <ls_objects>-obj_name ).

        INSERT CORRESPONDING #( <ls_objects> ) INTO TABLE rt_return ASSIGNING FIELD-SYMBOL(<ls_return>).

        CALL FUNCTION 'TR_DELETE_COMM_OBJECT_KEYS'
          EXPORTING
            is_e071_delete              = ls_e071
            iv_dialog_flag              = abap_false
          CHANGING
            cs_request                  = ls_request
          EXCEPTIONS
            e_database_access_error     = 1
            e_empty_lockkey             = 2
            e_bad_target_request        = 3
            e_wrong_source_client       = 4
            n_no_deletion_of_c_objects  = 5
            n_no_deletion_of_corr_entry = 6
            n_object_entry_doesnt_exist = 7
            n_request_already_released  = 8
            n_request_from_other_system = 9
            r_action_aborted_by_user    = 10
            r_foreign_lock              = 11
            w_bigger_lock_in_same_order = 12
            w_duplicate_entry           = 13
            w_no_authorization          = 14
            w_user_not_owner            = 15
            OTHERS                      = 16.

        IF sy-subrc = 0.
          <ls_return>-type = zcl_spt_core_data=>cs_message-type_success.
          <ls_return>-message = zcl_spt_utilities=>fill_return( iv_id = zcl_spt_trans_order_data=>cs_message-id
                                                                iv_number     = '011'
                                                                iv_message_v1 = <ls_objects>-pgmid
                                                                iv_message_v2 = <ls_objects>-object
                                                                iv_message_v3 =  <ls_objects>-obj_name
                                                                iv_langu      = mv_langu )-message.

          CALL FUNCTION 'DB_COMMIT'.
        ELSE.
          <ls_return>-type = zcl_spt_core_data=>cs_message-type_error.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO <ls_return>-message.
        ENDIF.
      ENDLOOP.

    ENDLOOP.
  ENDMETHOD.


  METHOD do_transport_copy.
    DATA ls_return_release_rfc TYPE bapiret2.
    DATA ls_return_release TYPE zcl_spt_core_data=>ts_return .

    IF it_orders IS NOT INITIAL.

      instance_badi_transport_copy( ).

      " Lectura del contenido de las ordenes
      et_return = get_orders_info( EXPORTING it_orders = it_orders
                                             iv_read_objects = abap_true ).

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

          IF ls_return_created-type NE zcl_spt_core_data=>cs_message-type_error.
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
              IF ls_return_release-type = zcl_spt_core_data=>cs_message-type_error.
                INSERT ls_return_created INTO TABLE et_return.
                INSERT ls_return_release INTO TABLE et_return.
              ELSE.
                " Si no hay errores pongo el mensaje genérico de transporte de copias realizado.
                INSERT VALUE #( type = zcl_spt_core_data=>cs_message-type_success
                                message = zcl_spt_utilities=>fill_return( iv_type = zcl_spt_core_data=>cs_message-type_success
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
        INSERT VALUE #( type = zcl_spt_core_data=>cs_message-type_error
                        message = zcl_spt_utilities=>fill_return( iv_type = zcl_spt_core_data=>cs_message-type_success
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
          DATA(ls_data) = read_request_complete( iv_order = <ls_orders>
                                                 iv_read_objects = iv_read_objects ).

          INSERT ls_data INTO TABLE mt_orders_data.

        CATCH zcx_spt_trans_order INTO DATA(lo_excep).
          INSERT zcl_spt_utilities=>fill_return( iv_type = zcl_spt_core_data=>cs_message-type_error
                                                 iv_id = lo_excep->if_t100_message~t100key-msgid
                                                 iv_number = lo_excep->if_t100_message~t100key-msgno
                                                 iv_message_v1 = lo_excep->mv_msgv1
                                                 iv_langu      = mv_langu ) INTO TABLE rt_return.
      ENDTRY.

    ENDLOOP.

  ENDMETHOD.


  METHOD get_orders_objects.

    CLEAR: rt_objects.

    IF it_orders IS INITIAL. EXIT. ENDIF.

    SELECT * INTO TABLE @DATA(lt_e071)
           FROM e071
           FOR ALL ENTRIES IN @it_orders
           WHERE trkorr = @it_orders-table_line.
    IF sy-subrc = 0.

      DATA(lt_objects_texts) = read_object_texts(  ).

      LOOP AT lt_e071 ASSIGNING FIELD-SYMBOL(<ls_e071>).
        INSERT CORRESPONDING #( <ls_e071> ) INTO TABLE rt_objects ASSIGNING FIELD-SYMBOL(<ls_objects>).
        <ls_objects>-order = <ls_e071>-trkorr.
        TRY.
            <ls_objects>-object_desc = lt_objects_texts[ pgmid  = <ls_e071>-pgmid object = <ls_e071>-object ]-text.
          CATCH cx_sy_itab_line_not_found.
            " Si no existe puedes ser porque sea un objeto que hay que hacer directamente por el tipo de objeto. Eso ocurre con las traducciones. Que en
            " PGMID viene 'LANG' y no lo encuentro. En esos casos solo se busca por el tipo de objeto
            TRY.
                <ls_objects>-object_desc = lt_objects_texts[ object = <ls_e071>-object ]-text.
              CATCH cx_sy_itab_line_not_found.
            ENDTRY.
        ENDTRY.
      ENDLOOP.

    ENDIF.
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
          iv_complete_projects = iv_complete_projects
        IMPORTING
          et_requests          = lt_request_aux.
      INSERT LINES OF lt_request_aux INTO TABLE lt_request.
      CLEAR lt_request_aux.
    ENDLOOP.

    SORT lt_request BY trkorr ASCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_request.

    SORT lt_request BY trfunction as4date DESCENDING as4time DESCENDING.

    et_orders = convert_req_header( it_request = lt_request
                                    iv_get_has_objects = iv_get_has_objects ).



  ENDMETHOD.


  METHOD instance_badi_transport_copy.

    TRY.
        IF mo_handle_badi_transport_copy IS NOT BOUND.
          GET BADI mo_handle_badi_transport_copy.
        ENDIF.
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.


  METHOD lock_objects.
    DATA lv_edit TYPE sap_bool.
    DATA lt_messages TYPE ctsgerrmsgs .

    DATA(ls_request) = read_request_complete( iv_order = iv_order
                                              iv_read_objects = abap_true ).


    CLEAR rt_return.

    lv_edit = COND #( WHEN ls_request-h-trfunction CA sctsc_types_tasks THEN abap_true ELSE abap_false ).
    DATA(ls_request_header) = CORRESPONDING trwbo_request_header( ls_request-h ).

    LOOP AT it_objects ASSIGNING FIELD-SYMBOL(<ls_objects>).
      ASSIGN ls_request-objects[ object = <ls_objects>-object
                                 pgmid = <ls_objects>-pgmid
                                 obj_name = <ls_objects>-obj_name ] TO FIELD-SYMBOL(<ls_e071>).
      IF sy-subrc = 0.
        <ls_e071>-lockflag = abap_true.
        CALL FUNCTION 'TRINT_LOCK_OBJECT'
          EXPORTING
            is_request_header = ls_request_header
            iv_edit           = lv_edit
            iv_collect_mode   = 'X'
          CHANGING
            cs_object         = <ls_e071>
            ct_messages       = lt_messages.

        IF lt_messages IS INITIAL.
          INSERT VALUE #( type = zcl_spt_core_data=>cs_message-type_success
                          message = zcl_spt_utilities=>fill_return( iv_id = zcl_spt_trans_order_data=>cs_message-id
                                                                    iv_number = '020'
                                                                    iv_message_v1 = <ls_objects>-pgmid
                                                                    iv_message_v2 = <ls_objects>-object
                                                                    iv_message_v3 = <ls_objects>-obj_name
                                                                    iv_langu      = mv_langu )-message ) INTO TABLE rt_return.
        ELSE.
          LOOP AT lt_messages ASSIGNING FIELD-SYMBOL(<ls_messages>).
            INSERT VALUE #( type = <ls_messages>-msgty
                                   message = zcl_spt_utilities=>fill_return( iv_id = <ls_messages>-msgid
                                                                             iv_number = <ls_messages>-msgno
                                                                             iv_message_v1 = <ls_messages>-msgv1
                                                                             iv_message_v2 = <ls_messages>-msgv2
                                                                             iv_message_v3 = <ls_messages>-msgv3
                                                                             iv_langu      = mv_langu )-message ) INTO TABLE rt_return.
          ENDLOOP.
        ENDIF.
      ELSE.
        INSERT VALUE #( type = zcl_spt_core_data=>cs_message-type_error
                           message = zcl_spt_utilities=>fill_return( iv_id = zcl_spt_trans_order_data=>cs_message-id
                                                                     iv_number = '022'
                                                                     iv_message_v1 = <ls_objects>-pgmid
                                                                     iv_message_v2 = <ls_objects>-object
                                                                     iv_message_v3 = <ls_objects>-obj_name
                                                                     iv_langu      = mv_langu )-message ) INTO TABLE rt_return.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD move_orders_objects.

    CLEAR: et_return.

    TRY.

        DATA(ls_to_order_data) = read_request_complete( EXPORTING iv_order = iv_order_to ).
        DATA(ls_request_header_to) = CORRESPONDING trwbo_request_header( ls_to_order_data-h ).
        ls_request_header_to-clients_filled = abap_true.

        " Se verifica si la orden destino se puede modificar
        DATA(ls_return_check) = check_request_changeable( ls_request_header_to ).
        IF ls_return_check IS INITIAL.
          DATA(ls_return_lock) = check_order_locked( iv_order_to ).
          IF ls_return_lock IS INITIAL.

            DATA(lt_orders_from) = VALUE zcl_spt_trans_order_data=>tt_orders( FOR <wa> IN it_objects ( <wa>-order ) ).
            SORT lt_orders_from.
            DELETE ADJACENT DUPLICATES FROM lt_orders_from COMPARING ALL FIELDS.
            ls_return_lock = check_orders_locked( lt_orders_from ).
            IF ls_return_lock IS INITIAL.

              LOOP AT lt_orders_from ASSIGNING FIELD-SYMBOL(<ls_orders_from>).
                move_order_objects(
                  EXPORTING
                    it_objects    =  VALUE #( FOR <object> IN it_objects WHERE ( order = <ls_orders_from> ) ( object = <object>-object
                                                                                                            obj_name = <object>-obj_name
                                                                                                            pgmid = <object>-pgmid ) )
                    iv_order_from = <ls_orders_from>
                    iv_order_to   = iv_order_to
                  IMPORTING
                    et_return     = DATA(lt_return_move) ).

                INSERT LINES OF lt_return_move INTO TABLE et_return.
              ENDLOOP.

            ELSE.
              INSERT ls_return_lock INTO TABLE et_return.
            ENDIF.

          ELSE.
            INSERT ls_return_lock INTO TABLE et_return.
          ENDIF.

        ELSE.
          INSERT ls_return_check INTO TABLE et_return.
        ENDIF.

      CATCH zcx_spt_trans_order INTO DATA(lo_excep).
        INSERT zcl_spt_utilities=>fill_return( iv_type = zcl_spt_core_data=>cs_message-type_error
                                               iv_id = lo_excep->if_t100_message~t100key-msgid
                                               iv_number = lo_excep->if_t100_message~t100key-msgno
                                               iv_message_v1 = lo_excep->mv_msgv1 ) INTO TABLE et_return.
    ENDTRY.

  ENDMETHOD.


  METHOD move_order_objects.
    DATA lt_e071k TYPE trwbo_t_e071k.
    DATA lt_e071 TYPE trwbo_t_e071.

    DATA(ls_return_lock) = check_order_locked( iv_order_to ).
    IF ls_return_lock IS INITIAL.
      ls_return_lock = check_order_locked( iv_order_from ).
      IF ls_return_lock IS INITIAL.

        DATA(ls_request) = read_request_complete( EXPORTING iv_order = iv_order_from
                                                            iv_read_objects     = abap_true ).

        " Se pasan los a las estructuras para pasarlas a las funciones de sap. Quitando el flag de bloqueo porque el bloqueo es
        " el último paso.
        LOOP AT it_objects ASSIGNING FIELD-SYMBOL(<ls_objects>).
          ASSIGN ls_request-objects[ pgmid = <ls_objects>-pgmid
                                     object = <ls_objects>-object
                                     obj_name = <ls_objects>-obj_name ] TO FIELD-SYMBOL(<ls_e071>).
          IF sy-subrc = 0.
            CLEAR: <ls_e071>-lockflag.
            <ls_e071>-trkorr = iv_order_to.
            INSERT <ls_e071> INTO TABLE lt_e071.

            LOOP AT ls_request-keys ASSIGNING FIELD-SYMBOL(<ls_e071k>) WHERE pgmid = <ls_objects>-pgmid
                                                                             AND object = <ls_objects>-object
                                                                             AND objname = <ls_objects>-obj_name.
              <ls_e071k>-trkorr = iv_order_to.
              INSERT <ls_e071k> INTO TABLE lt_e071k.
            ENDLOOP.
          ENDIF.

        ENDLOOP.

        IF lt_e071 IS NOT INITIAL.

          " Se llama a la función de actualizar para que añade los objetos. La función que se usa no valida el bloqueo
          " en la orden de origen.
          DATA(lt_return_add) = update_objects_orders( it_e071_add  = lt_e071
                                                 it_e071k_add = lt_e071k
                                                 iv_order = iv_order_to ).

          IF line_exists( lt_return_add[ type = zcl_spt_core_data=>cs_message-type_error ] ).
            INSERT LINES OF lt_return_add INTO TABLE et_return.
          ELSE.
            " Se borran los objetos de la orden original y las tareas de las orden principal si la tuviese
            delete_objects_from_all_task( EXPORTING it_objects = it_objects
                                                    iv_order = ls_request-h-strkorr
                                                    it_exclude_task = VALUE #( ( iv_order_from ) ) ).

            DATA(lt_return_delete) = delete_order_objects( it_objects = VALUE #( FOR <wa> IN it_objects ( order = iv_order_from
                                                                                                         pgmid = <wa>-pgmid
                                                                                                         object = <wa>-object
                                                                                                         obj_name = <wa>-obj_name ) ) ).

            IF line_exists( lt_return_delete[ type = zcl_spt_core_data=>cs_message-type_error ] ).
              INSERT VALUE #( type = zcl_spt_core_data=>cs_message-type_error
                              message = zcl_spt_utilities=>fill_return( iv_id = zcl_spt_trans_order_data=>cs_message-id
                                                                        iv_number = '019'
                                                                        iv_message_v1 = iv_order_from
                                                                        iv_message_v2 = iv_order_to
                                                                        iv_langu      = mv_langu )-message ) INTO TABLE et_return.
            ELSE.
              " Finalmente se bloquean los objetos
              DATA(lt_return_lock) = lock_objects( iv_order = iv_order_to
                                                   it_objects  = CORRESPONDING #( lt_e071 ) ).
              IF line_exists( lt_return_lock[ type = zcl_spt_core_data=>cs_message-type_error ] ).
                INSERT LINES OF lt_return_lock INTO TABLE et_return.
              ELSE.
                INSERT VALUE #( type = zcl_spt_core_data=>cs_message-type_success
                                message = zcl_spt_utilities=>fill_return( iv_id = zcl_spt_trans_order_data=>cs_message-id
                                                                        iv_number = '021'
                                                                        iv_message_v1 = iv_order_from
                                                                        iv_message_v2 = iv_order_to
                                                                        iv_langu      = mv_langu )-message ) INTO TABLE et_return.
              ENDIF.
            ENDIF.
          ENDIF.

        ELSE.
          INSERT VALUE #( type = zcl_spt_core_data=>cs_message-type_error
                                              message = zcl_spt_utilities=>fill_return( iv_id = zcl_spt_trans_order_data=>cs_message-id
                                                                                        iv_number = '016'
                                                                                        iv_message_v1 = iv_order_from
                                                                                        iv_langu      = mv_langu )-message ) INTO TABLE et_return.
        ENDIF.

      ELSE.
        INSERT ls_return_lock INTO TABLE et_return.
      ENDIF.

    ELSE.
      INSERT ls_return_lock INTO TABLE et_return.
    ENDIF.
  ENDMETHOD.


  METHOD read_object_texts.
    CALL FUNCTION 'TR_OBJECT_TABLE'
      TABLES
        wt_object_text = rt_object_text[].
  ENDMETHOD.


  METHOD read_request.

    CLEAR: rs_data.

    rs_data-trkorr = iv_order.

    CALL FUNCTION 'TRINT_READ_REQUEST_HEADER'
      EXPORTING
        iv_read_e070  = 'X'
        iv_read_e07t  = 'X'
        iv_read_e070c = 'X'
        iv_read_e070m = 'X'
      CHANGING
        cs_request    = rs_data
      EXCEPTIONS
        OTHERS        = 1.
    IF sy-subrc NE 0.
      DATA(lv_message) = zcl_spt_utilities=>fill_return( iv_type = zcl_spt_core_data=>cs_message-type_error
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


  METHOD read_request_and_task.

    CLEAR: rt_data.

    DATA(ls_order_data) = VALUE trwbo_request_header( trkorr = iv_order ).

    CALL FUNCTION 'TRINT_READ_REQUEST_HEADER'
      EXPORTING
        iv_read_e070  = 'X'
        iv_read_e07t  = 'X'
        iv_read_e070c = 'X'
        iv_read_e070m = 'X'
      CHANGING
        cs_request    = ls_order_data
      EXCEPTIONS
        OTHERS        = 1.
    IF sy-subrc = 0.
      INSERT ls_order_data INTO TABLE rt_data.

      SELECT trkorr INTO TABLE @DATA(lt_task)
             FROM e070
             WHERE strkorr = @iv_order.
      IF sy-subrc = 0.
        rt_data = VALUE #( BASE rt_data FOR <wa> IN lt_task ( read_request( <wa>-trkorr ) ) ).
      ENDIF.

    ELSE.
      DATA(lv_message) = zcl_spt_utilities=>fill_return( iv_type = zcl_spt_core_data=>cs_message-type_error
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


  METHOD read_request_complete.

    CLEAR: rs_data.

    rs_data-h-trkorr = iv_order.

    CALL FUNCTION 'TR_READ_REQUEST'
      EXPORTING
        iv_read_e070       = 'X'
        iv_read_e07t       = 'X'
        iv_read_e070c      = 'X'
        iv_read_e070m      = 'X'
        iv_read_objs_keys  = iv_read_objects
        iv_read_attributes = 'X'
      CHANGING
        cs_request         = rs_data
      EXCEPTIONS
        OTHERS             = 1.
    IF sy-subrc NE 0.
      DATA(lv_message) = zcl_spt_utilities=>fill_return( iv_type = zcl_spt_core_data=>cs_message-type_error
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

        " Leemos las ordenes para ir liberando sus tareas y finalmente las ordenes
        LOOP AT lt_orders ASSIGNING FIELD-SYMBOL(<ls_orders>) WHERE strkorr IS INITIAL.
          DATA(lv_tabix_order) = sy-tabix.

          LOOP AT lt_orders ASSIGNING FIELD-SYMBOL(<ls_task>) WHERE strkorr = <ls_orders>-trkorr.
            DATA(lv_tabix_task) = sy-tabix.

            INSERT VALUE #( task = <ls_task>-trkorr
                            order = <ls_task>-strkorr ) INTO TABLE et_return ASSIGNING FIELD-SYMBOL(<ls_return>).
            release_order( EXPORTING iv_without_locking = iv_without_locking
                                      iv_order           = <ls_task>-trkorr
                           IMPORTING es_return = DATA(ls_return_order)
                                     ev_status = <ls_return>-status
                                     ev_status_desc = <ls_return>-status_desc ).

            <ls_return> = CORRESPONDING #( BASE ( <ls_return> ) ls_return_order ).

            DELETE lt_orders INDEX lv_tabix_task. " Quitamos la tarea para que no se procese de nuevo
          ENDLOOP.


          INSERT VALUE #( order = <ls_orders>-trkorr ) INTO TABLE et_return ASSIGNING <ls_return>.
          release_order( EXPORTING iv_without_locking = iv_without_locking
                                   iv_order           = <ls_orders>-trkorr
                         IMPORTING es_return = DATA(ls_return_task)
                                   ev_status = <ls_return>-status
                                   ev_status_desc = <ls_return>-status_desc ).

          <ls_return> = CORRESPONDING #( BASE ( <ls_return> ) ls_return_task ).

          DELETE lt_orders INDEX lv_tabix_order. " Quitamos la tarea para que no se procese de nuevo
        ENDLOOP.

        " Ahora se liberan las tareas sueltas que quedan
        LOOP AT lt_orders ASSIGNING <ls_orders>.
          INSERT VALUE #( task = <ls_orders>-trkorr
                          order = <ls_orders>-strkorr ) INTO TABLE et_return ASSIGNING <ls_return>.
          release_order( EXPORTING iv_without_locking = iv_without_locking
                                    iv_order          = <ls_orders>-trkorr
                         IMPORTING es_return = ls_return_task
                                   ev_status = <ls_return>-status
                                   ev_status_desc = <ls_return>-status_desc ).

          <ls_return> = CORRESPONDING #( BASE ( <ls_return> ) ls_return_task ).
        ENDLOOP.


      ELSE.
        INSERT VALUE #( type = zcl_spt_core_data=>cs_message-type_error
                                      message = zcl_spt_utilities=>fill_return( iv_id = zcl_spt_trans_order_data=>cs_message-id
                                                                                iv_number = '010'
                                                                                iv_langu = mv_langu )-message ) INTO TABLE et_return.
      ENDIF.
    ELSE.
      INSERT VALUE #( type = zcl_spt_core_data=>cs_message-type_error
                                       message = zcl_spt_utilities=>fill_return( iv_id = zcl_spt_trans_order_data=>cs_message-id
                                                                                 iv_number = '010'
                                                                                 iv_langu = mv_langu )-message ) INTO TABLE et_return.
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
        es_return = VALUE #( type = zcl_spt_core_data=>cs_message-type_success
                              message = zcl_spt_utilities=>fill_return( iv_type = zcl_spt_core_data=>cs_message-type_success
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

*          ev_status = 'R'.
*          ev_status_desc = mo_order_md->get_status_desc( ev_status ).
        ENDIF.

      ELSE.
        DATA(lv_msgno) = sy-msgno.
        DATA(lv_msgid) = sy-msgid.
        DATA(lv_msgv1) = sy-msgv1.
        DATA(lv_msgv2) = sy-msgv2.
        DATA(lv_msgv3) = sy-msgv3.
        DATA(lv_msgv4) = sy-msgv4.

        es_return = VALUE #( type = zcl_spt_core_data=>cs_message-type_error
                             message = zcl_spt_utilities=>fill_return( iv_type = zcl_spt_core_data=>cs_message-type_error
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
          es_return = VALUE #( type = zcl_spt_core_data=>cs_message-type_error
                              message = zcl_spt_utilities=>fill_return( iv_type = zcl_spt_core_data=>cs_message-type_error
                                                                        iv_id = lv_msgid
                                                                        iv_number = lv_msgno
                                                                        iv_message_v1 = lv_msgv1
                                                                        iv_message_v2 = lv_msgv2
                                                                        iv_message_v3 = lv_msgv3
                                                                        iv_message_v4 = lv_msgv4
                                                                        iv_langu      = sy-langu )-message ).
        ENDIF.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD update_objects_orders.

    DATA(ls_request) = read_request_complete( iv_order = iv_order
                                              iv_read_objects = abap_true ).


    IF it_e071_add IS NOT INITIAL.
      INSERT LINES OF it_e071_add INTO TABLE ls_request-objects.
    ENDIF.
    IF it_e071k_add IS NOT INITIAL.
      INSERT LINES OF it_e071k_add INTO TABLE ls_request-keys.
    ENDIF.

    DATA(ls_e070) = CORRESPONDING e070( ls_request-h ).

    CALL FUNCTION 'TRINT_UPDATE_COMM'
      EXPORTING
        wi_trkorr          = iv_order
        wi_e070            = ls_e070
        wi_sel_e071        = 'X'
        wi_sel_e071k       = 'X'
        wi_direct_add_flag = 'X'
      TABLES
        wt_e071            = ls_request-objects
        wt_e071k           = ls_request-keys
      CHANGING
        wt_e071k_str       = ls_request-keys_str
      EXCEPTIONS
        OTHERS             = 1.
    IF sy-subrc = 0.
      INSERT VALUE #( type = zcl_spt_core_data=>cs_message-type_success
                                                   message = zcl_spt_utilities=>fill_return( iv_id = zcl_spt_trans_order_data=>cs_message-id
                                                                                             iv_number = '018'
                                                                                             iv_message_v1 = iv_order
                                                                                             iv_langu      = mv_langu )-message ) INTO TABLE rt_return.
    ELSE.
      INSERT VALUE #( type = zcl_spt_core_data=>cs_message-type_error
                                 message = zcl_spt_utilities=>fill_return(
                                                                           iv_id = sy-msgid
                                                                           iv_number = sy-msgno
                                                                           iv_message_v1 = sy-msgv1
                                                                           iv_message_v2 = sy-msgv2
                                                                           iv_message_v3 = sy-msgv3
                                                                           iv_message_v4 = sy-msgv4
                                                                           iv_langu      = mv_langu )-message ) INTO TABLE rt_return.
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
        IF is_data-user IS NOT INITIAL AND is_data-user NE ls_data-as4user.
          lv_user_changed = abap_true.
          DATA(ls_return_change) = change_user_order( iv_user  = is_data-user
                                         iv_order = iv_order ).

          IF ls_return_change-type = zcl_spt_core_data=>cs_message-type_error.
            rs_return = ls_return_change.
            EXIT.
          ENDIF.
        ENDIF.

        " Datos cabecera
        ls_e070 = CORRESPONDING #( ls_data ).

        " Descripción
        ls_e07t-trkorr = ls_e070-trkorr.
        ls_e07t-langu = mv_langu.
        ls_e07t-as4text = ls_data-as4text.

        DATA(lv_change_header) = abap_false.

        " Si viene descripción y es distinta a la que tiene
        IF is_data-description IS NOT INITIAL AND is_data-description NE ls_data-as4text.
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
            rs_return = VALUE #( type = zcl_spt_core_data=>cs_message-type_success
                        message = zcl_spt_utilities=>fill_return( iv_id = zcl_spt_trans_order_data=>cs_message-id
                                                                  iv_number = '007'
                                                                  iv_message_v1 = iv_order
                                                                  iv_langu  = mv_langu )-message ).
          ELSE.
            rs_return = VALUE #( type = zcl_spt_core_data=>cs_message-type_error
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
          rs_return = VALUE #( type = zcl_spt_core_data=>cs_message-type_success
                          message = zcl_spt_utilities=>fill_return( iv_id = zcl_spt_trans_order_data=>cs_message-id
                                                                    iv_number = '008'
                                                                    iv_message_v1 = iv_order
                                                                    iv_langu  = mv_langu )-message ).
        ENDIF.



      CATCH zcx_spt_trans_order INTO DATA(lo_excep).
        rs_return = zcl_spt_utilities=>fill_return( iv_type = zcl_spt_core_data=>cs_message-type_error
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
    es_app-url_help = 'https://github.com/irodrigob/abap-sap-tools/wiki'.
  ENDMETHOD.

  METHOD delete_objects_from_all_task.
    DATA(lt_r_task_exclude) = VALUE zcl_spt_trans_order_data=>tt_r_orders( FOR <wa> IN it_exclude_task ( sign = 'E' option = 'EQ' low = <wa> ) ).
    SELECT trkorr INTO TABLE @DATA(lt_tasks)
           FROM e070
           WHERE strkorr = @iv_order
                 AND trkorr IN @lt_r_task_exclude.
    IF sy-subrc = 0.

      LOOP AT lt_tasks ASSIGNING FIELD-SYMBOL(<ls_task>).

        DATA(lt_objects) = it_objects.
        TRY.
            " Se leen los datos de la orden para saber sus objetos y para saber si hay alguno que coincida.
            DATA(ls_request) = read_request_complete( EXPORTING iv_order = <ls_task>-trkorr
                                                                 iv_read_objects     = abap_true ).

            LOOP AT lt_objects ASSIGNING FIELD-SYMBOL(<ls_object>).
              DATA(lv_tabix) = sy-tabix.
              IF NOT line_exists( ls_request-objects[ pgmid = <ls_object>-pgmid
                                                      object = <ls_object>-object
                                                      obj_name = <ls_object>-obj_name ] ).
                DELETE lt_objects INDEX lv_tabix.
              ENDIF.
            ENDLOOP.
            IF lt_objects IS NOT INITIAL.
              delete_order_objects( it_objects = VALUE #( FOR <wa1> IN it_objects ( order = <ls_task>-trkorr
                                                                                    pgmid = <wa1>-pgmid
                                                                                    object = <wa1>-object
                                                                                    obj_name = <wa1>-obj_name ) ) ).
            ENDIF.
          CATCH zcx_spt_trans_order .
        ENDTRY.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
