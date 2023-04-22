INTERFACE zif_spt_core_data
  PUBLIC .
  TYPES: tv_app TYPE c LENGTH 30.
  TYPES: tv_msg_type TYPE c LENGTH 1.

  TYPES: BEGIN OF ts_return,
           type    TYPE tv_msg_type,
           message TYPE string,
         END OF ts_return.
  TYPES tt_return TYPE STANDARD TABLE OF ts_return WITH DEFAULT KEY.
  CONSTANTS cv_default_langu TYPE sylangu VALUE 'E'.
  CONSTANTS: BEGIN OF cs_message,
               type_success TYPE tv_msg_type VALUE 'S',
               type_error   TYPE tv_msg_type VALUE 'E',
               type_warning TYPE tv_msg_type VALUE 'W',
               type_anormal TYPE tv_msg_type VALUE 'A',
             END OF cs_message.

ENDINTERFACE.
