INTERFACE zif_spt_ex_badi_transport_copy
  PUBLIC .
  INTERFACES: if_badi_interface.

  "! <p class="shorttext synchronized">Proceso previo a la liberación de la orden</p>
  "! @parameter iv_order | <p class="shorttext synchronized">Orden</p>
  "! @parameter is_order_data | <p class="shorttext synchronized">Datos de la orden</p>
  "! @parameter cs_return | <p class="shorttext synchronized">Resultado del proceso</p>
  METHODS before_release_order
    IMPORTING
      iv_order      TYPE trkorr
      is_order_data TYPE trwbo_request
    CHANGING
      cs_return     TYPE zif_spt_core_data=>ts_return.
  "! <p class="shorttext synchronized">Modificación de los usuarios del sistema</p>
  "! @parameter ct_system_user | <p class="shorttext synchronized">Lista de usuarios del sistema</p>
  METHODS change_system_user
    CHANGING ct_system_user TYPE zcl_spt_apps_trans_order_md=>tt_username_list.
ENDINTERFACE.
