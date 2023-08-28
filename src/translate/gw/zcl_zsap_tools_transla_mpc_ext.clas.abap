CLASS zcl_zsap_tools_transla_mpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_zsap_tools_transla_mpc
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: BEGIN OF ts_objecttranlsate_deep.
        INCLUDE TYPE zcl_zsap_tools_transla_mpc=>ts_objecttranslate.
    TYPES:
      objecttextset TYPE STANDARD TABLE OF zcl_zsap_tools_transla_mpc=>ts_objecttext WITH DEFAULT KEY,
      returnset     TYPE STANDARD TABLE OF zcl_zsap_tools_transla_mpc=>ts_return WITH DEFAULT KEY,
      END OF ts_objecttranlsate_deep.
    METHODS define REDEFINITION.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_zsap_tools_transla_mpc_ext IMPLEMENTATION.
  METHOD define.
    super->define(  ).

    DATA(lo_entity_type) = model->get_entity_type( iv_entity_name = 'objectTranslate' ).
    lo_entity_type->bind_structure( iv_structure_name = 'ZCL_ZSAP_TOOLS_TRANSLA_MPC_EXT=>TS_OBJECTTRANLSATE_DEEP' ).
  ENDMETHOD.

ENDCLASS.
