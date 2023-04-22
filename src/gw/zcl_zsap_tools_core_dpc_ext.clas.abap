CLASS zcl_zsap_tools_core_dpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_zsap_tools_core_dpc
  CREATE PUBLIC .

  PUBLIC SECTION.
  PROTECTED SECTION.
    METHODS getuserinfoset_get_entity REDEFINITION.
    METHODS getappslistset_get_entityset REDEFINITION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_zsap_tools_core_dpc_ext IMPLEMENTATION.
  METHOD getuserinfoset_get_entity.

    CLEAR: er_entity.

    DATA(lo_user) = NEW zcl_spt_user( CONV #( it_key_tab[ name = 'username' ]-value ) ).
    lo_user->get_user_info(  IMPORTING es_user_info = DATA(ls_user_info) ).
    er_entity = CORRESPONDING #( ls_user_info ).
  ENDMETHOD.

  METHOD getappslistset_get_entityset.

    CLEAR: et_entityset.

    TRY.

        DATA(lv_langu) = sy-langu.
        ASSIGN it_filter_select_options[ property = 'langu' ]-select_options[ 1 ] TO FIELD-SYMBOL(<ls_select_options>).
        IF sy-subrc = 0.
          CALL FUNCTION 'CONVERSION_EXIT_ISOLA_INPUT'
            EXPORTING
              input            = <ls_select_options>-low
            IMPORTING
              output           = lv_langu
            EXCEPTIONS
              unknown_language = 1
              OTHERS           = 2.
          IF sy-subrc NE 0.
            lv_langu = sy-langu.
          ENDIF.
        ENDIF.

        zcl_spt_apps_base=>get_apps_list_static( EXPORTING iv_langu = lv_langu
                                                 IMPORTING et_app_list = DATA(lt_app_list) ).

        et_entityset = CORRESPONDING #( lt_app_list ).

      CATCH cx_root.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
