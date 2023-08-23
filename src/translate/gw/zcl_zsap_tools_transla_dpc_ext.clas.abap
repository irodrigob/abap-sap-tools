CLASS zcl_zsap_tools_transla_dpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_zsap_tools_transla_dpc
  CREATE PUBLIC .

  PUBLIC SECTION.
  PROTECTED SECTION.
    METHODS languagesset_get_entityset REDEFINITION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_zsap_tools_transla_dpc_ext IMPLEMENTATION.
  METHOD languagesset_get_entityset.

    DATA(lo_translate) = NEW zcl_spt_translate_tool(  ).

    DATA(lt_languages) = lo_translate->get_languages(  ).

    et_entityset = CORRESPONDING #( lt_languages ).

    TRY.
        et_entityset[ r3_lang = sy-langu ]-is_system_language = abap_true.
      CATCH cx_sy_itab_line_not_found.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
