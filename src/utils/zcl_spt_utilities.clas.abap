CLASS zcl_spt_utilities DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    "! <p class="shorttext synchronized">Rellena el retorn de mensajes</p>
    "! @parameter iv_type | <p class="shorttext synchronized">Tipo</p>
    "! @parameter iv_id | <p class="shorttext synchronized">Id mensaje</p>
    "! @parameter iv_number | <p class="shorttext synchronized">Numero</p>
    "! @parameter iv_message_v1 | <p class="shorttext synchronized">Variable mensaje 1</p>
    "! @parameter iv_message_v2 | <p class="shorttext synchronized">Variable mensaje 2</p>
    "! @parameter iv_message_v3 | <p class="shorttext synchronized">Variable mensaje 2</p>
    "! @parameter iv_message_v4 | <p class="shorttext synchronized">Variable mensaje 4</p>
    "! @parameter iv_langu | <p class="shorttext synchronized">Idioma</p>
    "! @parameter rs_return | <p class="shorttext synchronized">Retorno</p>
    CLASS-METHODS fill_return
      IMPORTING
        !iv_type         TYPE any DEFAULT zcl_spt_core_data=>cs_message-type_success
        !iv_id           TYPE any
        !iv_number       TYPE any
        !iv_message_v1   TYPE any OPTIONAL
        !iv_message_v2   TYPE any OPTIONAL
        !iv_message_v3   TYPE any OPTIONAL
        !iv_message_v4   TYPE any OPTIONAL
        !iv_langu        TYPE sylangu DEFAULT sy-langu
      RETURNING
        VALUE(rs_return) TYPE zcl_spt_core_data=>ts_return .
    "! <p class="shorttext synchronized">Convierte el idioma en formato ISO en formato SAP</p>
    "! @parameter iv_isolangu | <p class="shorttext synchronized">Idioma ISO</p>
    "! @parameter rv_langu | <p class="shorttext synchronized">Idioma SAP</p>
    CLASS-METHODS convert_iso_langu_2_sap
      IMPORTING
                !iv_isolangu    TYPE laiso
      RETURNING VALUE(rv_langu) TYPE sylangu.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_spt_utilities IMPLEMENTATION.
  METHOD fill_return.
    DATA ls_bapiret2 TYPE bapiret2.

    CLEAR rs_return.

    DATA(lv_langu) = iv_langu.

    " Para las clases de la herramienta miro si el mensaje esta traducido al idioma pasado por
    " parámetro en caso de no estarlo se leera en el idioma de la aplicación
    IF iv_id CP 'ZSPT*'.
      SELECT SINGLE @abap_true INTO @DATA(lv_existe)
             FROM t100
             WHERE sprsl = @lv_langu
                   AND arbgb = @iv_id.
      IF sy-subrc NE 0.
        lv_langu = zcl_spt_core_data=>cv_default_langu.
      ENDIF.

    ENDIF.

    ls_bapiret2-type = iv_type.
    ls_bapiret2-id = iv_id.
    ls_bapiret2-number = iv_number.
    ls_bapiret2-message_v1 = iv_message_v1.
    ls_bapiret2-message_v2 = iv_message_v2.
    ls_bapiret2-message_v3 = iv_message_v3.
    ls_bapiret2-message_v4 = iv_message_v4.

    CALL FUNCTION 'BAPI_MESSAGE_GETDETAIL'
      EXPORTING
        id         = ls_bapiret2-id
        number     = ls_bapiret2-number
        language   = lv_langu
        textformat = 'ASC'
        message_v1 = ls_bapiret2-message_v1
        message_v2 = ls_bapiret2-message_v2
        message_v3 = ls_bapiret2-message_v3
        message_v4 = ls_bapiret2-message_v4
      IMPORTING
        message    = ls_bapiret2-message.

    rs_return-type = iv_type.
    rs_return-message = ls_bapiret2-message.
  ENDMETHOD.

  METHOD convert_iso_langu_2_sap.

    CALL FUNCTION 'CONVERSION_EXIT_ISOLA_INPUT'
      EXPORTING
        input            = iv_isolangu
      IMPORTING
        output           = rv_langu
      EXCEPTIONS
        unknown_language = 1
        OTHERS           = 2.
    IF sy-subrc NE 0.
      rv_langu = sy-langu.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
