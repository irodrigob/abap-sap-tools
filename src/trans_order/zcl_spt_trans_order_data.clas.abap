CLASS zcl_spt_trans_order_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: tt_orders TYPE STANDARD TABLE OF trkorr WITH DEFAULT KEY.
    TYPES: tt_r_orders TYPE RANGE OF trkorr.
    TYPES: tt_orders_data TYPE STANDARD TABLE OF trwbo_request WITH DEFAULT KEY.
    TYPES: tt_users TYPE STANDARD TABLE OF syuname WITH EMPTY KEY.
    CONSTANTS: BEGIN OF cs_orders,
                 BEGIN OF type,
                   transport_copies TYPE trfunction VALUE 'T',
                   workbench        TYPE trfunction VALUE 'K',
                   customizing      TYPE trfunction VALUE 'W',
                 END OF type,
                 BEGIN OF status,
                   changeable        TYPE trstatus VALUE 'D',
                   released          TYPE trstatus VALUE 'R',
                   released_repaired TYPE trstatus VALUE 'N',
                 END OF status,
               END OF cs_orders.
    CONSTANTS: BEGIN OF cs_message,
                 id TYPE symsgid VALUE 'ZSPT_TRANS_ORDER',
               END OF cs_message.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_spt_trans_order_data IMPLEMENTATION.
ENDCLASS.
