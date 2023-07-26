CLASS zcx_spt_trans_order DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_t100_dyn_msg .
    INTERFACES if_t100_message .

    CONSTANTS:
      BEGIN OF message_other_class,
        msgid TYPE symsgid VALUE 'ZSPT_TRANS_ORDER',
        msgno TYPE symsgno VALUE '000',
        attr1 TYPE scx_attrname VALUE 'MV_MSGV1',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF message_other_class .
    DATA mv_msgv1 TYPE string .
    DATA mv_msgv2 TYPE string .
    DATA mv_msgv3 TYPE string .
    DATA mv_msgv4 TYPE string .

    METHODS constructor
      IMPORTING
        !textid   LIKE if_t100_message=>t100key OPTIONAL
        !previous LIKE previous OPTIONAL
        !mv_msgv1 TYPE string OPTIONAL
        !mv_msgv2 TYPE string OPTIONAL
        !mv_msgv3 TYPE string OPTIONAL
        !mv_msgv4 TYPE string OPTIONAL .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcx_spt_trans_order IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous.
    me->mv_msgv1 = mv_msgv1 .
    me->mv_msgv2 = mv_msgv2 .
    me->mv_msgv3 = mv_msgv3 .
    me->mv_msgv4 = mv_msgv4 .
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
