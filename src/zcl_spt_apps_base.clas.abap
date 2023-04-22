CLASS zcl_spt_apps_base DEFINITION
  PUBLIC
  CREATE PROTECTED .

  PUBLIC SECTION.

    INTERFACES zif_spt_core_app .

    TYPES:
      BEGIN OF ts_apps,
        app           TYPE zif_spt_core_data=>tv_app,
        app_desc      TYPE string,
        service       TYPE string,
        frontend_page TYPE string,
        ref_app       TYPE REF TO zif_spt_core_app,
        icon          TYPE string,
        url_help      TYPE string,
      END OF ts_apps .
    TYPES:
      tt_apps TYPE STANDARD TABLE OF ts_apps WITH DEFAULT KEY .

    "! <p class="shorttext synchronized">CONSTRUCTOR</p>
    "! @parameter iv_user | <p class="shorttext synchronized">Idioma</p>
    METHODS constructor
      IMPORTING
        !iv_langu TYPE sylangu DEFAULT sy-langu .
    "! <p class="shorttext synchronized">Listado de aplicaciones disponibles</p>
    "! @parameter iv_langu | <p class="shorttext synchronized">Idioma</p>
    "! @parameter et_app_list | <p class="shorttext synchronized">Listado de aplicación</p>
    CLASS-METHODS get_apps_list_static
      IMPORTING
        !iv_langu    TYPE sylangu DEFAULT sy-langu
      EXPORTING
        !et_app_list TYPE tt_apps .
  PROTECTED SECTION.
    DATA mv_langu TYPE sylangu.
    DATA mv_app TYPE zif_spt_core_data=>tv_app.

    "! <p class="shorttext synchronized">Establece la aplicación</p>
    "! @parameter iv_app | <p class="shorttext synchronized">Aplication</p>
    METHODS set_app
      IMPORTING iv_app TYPE zif_spt_core_data=>tv_app.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_spt_apps_base IMPLEMENTATION.


  METHOD constructor.
    mv_langu = iv_langu.
  ENDMETHOD.


  METHOD get_apps_list_static.
    DATA lo_app TYPE REF TO zif_spt_core_app.
    CLEAR: et_app_list.

    SELECT clsname FROM vseoextend INTO TABLE @DATA(lt_classlist)
            WHERE refclsname = 'ZCL_SPT_APPS_BASE'
                  AND version = '1'.
    IF sy-subrc = 0.
      LOOP AT lt_classlist ASSIGNING FIELD-SYMBOL(<ls_classlist>).

        TRY.
            CREATE OBJECT lo_app TYPE (<ls_classlist>-clsname).

            lo_app->get_app_type( IMPORTING es_app = DATA(ls_app) ).

            INSERT CORRESPONDING #( ls_app ) INTO TABLE et_app_list ASSIGNING FIELD-SYMBOL(<ls_app_list>).
            <ls_app_list>-ref_app = lo_app.

          CATCH cx_root.
        ENDTRY.
      ENDLOOP.

    ENDIF.

  ENDMETHOD.


  METHOD set_app.
    mv_app = iv_app.
  ENDMETHOD.
ENDCLASS.
