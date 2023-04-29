CLASS zcl_spt_apps_trans_order_md DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: BEGIN OF ts_username_list,
             user      TYPE syuname,
             user_desc TYPE ad_namtext,
           END OF ts_username_list.
    TYPES: tt_username_list TYPE STANDARD TABLE OF ts_username_list WITH EMPTY KEY.
    "! <p class="shorttext synchronized">CONSTRUCTOR</p>
    "! @parameter iv_langu | <p class="shorttext synchronized">Idioma</p>
    METHODS constructor
      IMPORTING iv_langu TYPE sylangu DEFAULT sy-langu.
    "! <p class="shorttext synchronized">Usuarios del sistema</p>
    "! @parameter rt_users | <p class="shorttext synchronized">Lista de usuarios</p>
    METHODS get_system_users
      RETURNING VALUE(rt_users) TYPE tt_username_list.
    "! <p class="shorttext synchronized">Devuelve la descripción del status de una orden</p>
    "! @parameter iv_status | <p class="shorttext synchronized">Status</p>
    "! @parameter rv_desc | <p class="shorttext synchronized">Descripción</p>
    METHODS get_status_desc
      IMPORTING iv_status      TYPE trstatus
      RETURNING VALUE(rv_desc) TYPE val_text.
    "! <p class="shorttext synchronized">Devuelve la descripción del tipo de orden/tarea</p>
    "! @parameter iv_status | <p class="shorttext synchronized">Status</p>
    "! @parameter rv_desc | <p class="shorttext synchronized">Descripción</p>
    METHODS get_function_desc
      IMPORTING iv_function    TYPE trfunction
      RETURNING VALUE(rv_desc) TYPE val_text.
  PROTECTED SECTION.
    DATA mo_handle_badi_transport_copy TYPE REF TO zspt_badi_transport_copy.
    DATA mt_functions_desc TYPE dd07v_tab.
    DATA mt_status_desc TYPE dd07v_tab.
    DATA mv_langu TYPE sylangu.
    "! <p class="shorttext synchronized">Instancia la BADI de transporte de copias</p>
    METHODS instance_badi_transport_copy.
    "! <p class="shorttext synchronized">Llama a la BADI para cambiar los usuarios del sistema </p>
    "! @parameter ct_users | <p class="shorttext synchronized">Lista de usuarios</p>
    METHODS call_badi_before_release_order
      CHANGING
        ct_system_users TYPE tt_username_list.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_spt_apps_trans_order_md IMPLEMENTATION.


  METHOD get_system_users.

    CLEAR: rt_users.

    instance_badi_transport_copy( ).

    SELECT a~bname AS user,
           CASE WHEN c~name_text IS NULL THEN a~bname
                ELSE c~name_text
           END AS user_desc
           INTO TABLE @rt_users
           FROM usr02 AS a
           INNER JOIN usr21 AS b ON
                a~bname = b~bname
           LEFT OUTER JOIN adrp AS c ON
                b~persnumber = c~persnumber
           WHERE ustyp = 'A' " Usuarios de dialogo
                 AND ( gltgb >= @sy-datum OR gltgb = '00000000' ). " Usuarios activos

    call_badi_before_release_order( CHANGING ct_system_users = rt_users ).

  ENDMETHOD.
  METHOD instance_badi_transport_copy.
    TRY.
        IF mo_handle_badi_transport_copy IS NOT BOUND.
          GET BADI mo_handle_badi_transport_copy.
        ENDIF.
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD call_badi_before_release_order.
    " Si la BADI esta instancia leo los datos de la orden y se la paso al método
    IF mo_handle_badi_transport_copy IS BOUND.


      LOOP AT mo_handle_badi_transport_copy->imps ASSIGNING FIELD-SYMBOL(<ls_imps>).
        TRY.
            <ls_imps>->change_system_user(
                CHANGING
                  ct_system_user     = ct_system_users ).

          CATCH cx_root.
        ENDTRY.
      ENDLOOP.

    ENDIF.
  ENDMETHOD.

  METHOD get_status_desc.
    DATA lt_status_n TYPE dd07v_tab.

    CLEAR: rv_desc.

    IF mt_status_desc IS INITIAL.
      CALL FUNCTION 'DD_DOMA_GET'
        EXPORTING
          domain_name   = 'TRSTATUS'
          langu         = mv_langu
        TABLES
          dd07v_tab_a   = mt_status_desc
          dd07v_tab_n   = lt_status_n
        EXCEPTIONS
          illegal_value = 1
          op_failure    = 2
          OTHERS        = 3.
    ENDIF.

    TRY.
        rv_desc = mt_status_desc[ domvalue_l = iv_status ]-ddtext.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.
  ENDMETHOD.

  METHOD get_function_desc.
    DATA lt_functions_n TYPE dd07v_tab.

    CLEAR: rv_desc.

    IF mt_functions_desc IS INITIAL.
      CALL FUNCTION 'DD_DOMA_GET'
        EXPORTING
          domain_name   = 'TRFUNCTION'
          langu         = mv_langu
        TABLES
          dd07v_tab_a   = mt_functions_desc
          dd07v_tab_n   = lt_functions_n
        EXCEPTIONS
          illegal_value = 1
          op_failure    = 2
          OTHERS        = 3.
    ENDIF.

    TRY.
        rv_desc = mt_functions_desc[ domvalue_l = iv_function ]-ddtext.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.
  ENDMETHOD.

  METHOD constructor.
    mv_langu = iv_langu.
  ENDMETHOD.

ENDCLASS.
