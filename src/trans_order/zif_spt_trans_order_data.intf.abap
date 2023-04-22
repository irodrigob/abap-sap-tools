INTERFACE zif_spt_trans_order_data
  PUBLIC .
  TYPES: tt_orders TYPE STANDARD TABLE OF trkorr WITH DEFAULT KEY.
  TYPES: tt_orders_data TYPE STANDARD TABLE OF trwbo_request WITH DEFAULT KEY.

*  CONSTANTS: BEGIN OF cs_orders_type,
*               transport_copies TYPE trfunction VALUE 'T',
*               workbench        TYPE trfunction VALUE 'K',
*               customizing      TYPE trfunction VALUE 'W',
*             END OF cs_orders_type.
  CONSTANTS: BEGIN OF cs_orders,
               BEGIN OF type,
                 transport_copies TYPE trfunction VALUE 'T',
                 workbench        TYPE trfunction VALUE 'K',
                 customizing      TYPE trfunction VALUE 'W',
               END OF type,
               BEGIN OF status,
                 changeable TYPE trstatus VALUE 'D',
                 released   TYPE trstatus VALUE 'R',
               END OF status,
             END OF cs_orders.
  CONSTANTS: BEGIN OF cs_message,
               id TYPE symsgid VALUE 'ZSPT_TRANS_ORDER',
             END OF cs_message.
ENDINTERFACE.
