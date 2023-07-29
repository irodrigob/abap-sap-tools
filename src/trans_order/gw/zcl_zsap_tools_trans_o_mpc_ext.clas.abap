CLASS zcl_zsap_tools_trans_o_mpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_zsap_tools_trans_o_mpc
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: BEGIN OF ts_move_objects_deep.
        INCLUDE TYPE zcl_zsap_tools_trans_o_mpc=>ts_moveobjects.
    TYPES:
      returnset          TYPE STANDARD TABLE OF zcl_zsap_tools_trans_o_mpc=>ts_return WITH DEFAULT KEY,
      orderobjectskeyset TYPE STANDARD TABLE OF zcl_zsap_tools_trans_o_mpc=>ts_orderobjectskey WITH DEFAULT KEY,
      END OF ts_move_objects_deep.
    METHODS define REDEFINITION.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_zsap_tools_trans_o_mpc_ext IMPLEMENTATION.
  METHOD define.
    super->define(  ).

    data(lo_entity_type) = model->get_entity_type( iv_entity_name = 'moveObjects' ).
    lo_entity_type->bind_structure( iv_structure_name = 'ZCL_ZSAP_TOOLS_TRANS_O_MPC_EXT=>TS_MOVE_OBJECTS_DEEP' ).
  ENDMETHOD.

ENDCLASS.
