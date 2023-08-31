CLASS zcl_spt_apps_translate DEFINITION
  PUBLIC
  INHERITING FROM zcl_spt_apps_base
  CREATE PUBLIC .
  PUBLIC SECTION.
  METHODS zif_spt_core_app~get_app_type REDEFINITION.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_SPT_APPS_TRANSLATE IMPLEMENTATION.


  METHOD zif_spt_core_app~get_app_type.
  CLEAR: es_app.

    es_app-app = 'TRANSLATE'.
    es_app-app_desc = 'Translate'(t01).
    es_app-service = '/ZSAP_TOOLS_TRANSLATE_SRV'.
    es_app-frontend_page = '/translate'.
    es_app-icon = 'translate'.
    es_app-url_help = 'https://github.com/irodrigob/abap-sap-tools/wiki'.
  ENDMETHOD.
ENDCLASS.
