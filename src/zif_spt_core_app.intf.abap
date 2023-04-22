INTERFACE zif_spt_core_app
  PUBLIC .
  TYPES: BEGIN OF ts_apps_type,
           app           TYPE zif_spt_core_data=>tv_app,
           app_desc      TYPE string,
           service       TYPE string,
           frontend_page TYPE string,
           icon          TYPE string,
           url_help      TYPE string,
         END OF ts_apps_type.
  TYPES: tt_apps_type TYPE STANDARD TABLE OF ts_apps_type WITH EMPTY KEY.

  "! <p class="shorttext synchronized">Devuelve el tipo de aplicación</p>
  "! @parameter es_app | <p class="shorttext synchronized">Aplicación</p>
  METHODS get_app_type
    EXPORTING
      es_app TYPE ts_apps_type.

ENDINTERFACE.
