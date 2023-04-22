FUNCTION ZSPT_RELEASE_ORDER.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_ORDER) TYPE  TRKORR
*"     VALUE(IV_WITHOUT_LOCKING) TYPE  SAP_BOOL DEFAULT ABAP_FALSE
*"     VALUE(IV_LANGU) TYPE  SYLANGU DEFAULT SY-LANGU
*"  EXPORTING
*"     VALUE(ES_RETURN) TYPE  BAPIRET2
*"----------------------------------------------------------------------
  CLEAR: es_return.

  DATA(lo_transp_order) = NEW zcl_spt_apps_trans_order( iv_langu = iv_langu ).

  DATA(ls_return) = lo_transp_order->release_order( EXPORTING iv_without_locking = iv_without_locking
                                                              iv_order           = iv_order ).

  es_return-type = ls_return-type.
  es_return-message = ls_return-message.



ENDFUNCTION.
