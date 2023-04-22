CLASS zcl_spt_user DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: BEGIN OF ts_user_info,
             username      TYPE syuname,
             username_desc TYPE string,
           END OF ts_user_info.
    "! <p class="shorttext synchronized">CONSTRUCTOR</p>
    "! @parameter iv_user | <p class="shorttext synchronized">Usuario</p>
    METHODS constructor
      IMPORTING
        iv_user TYPE syuname DEFAULT sy-uname.

    "! <p class="shorttext synchronized">Obtiene datos del usuario</p>
    "! @parameter es_user_info | <p class="shorttext synchronized">Datos del usuario</p>
    METHODS get_user_info
      EXPORTING es_user_info TYPE ts_user_info.


  PROTECTED SECTION.
    DATA mv_user TYPE syuname.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_spt_user IMPLEMENTATION.
  METHOD constructor.
    mv_user = iv_user.
  ENDMETHOD.

  METHOD get_user_info.
     clear: es_user_info.

     es_user_info-username = mv_user.

     SELECT single d~name_text INTO @es_user_info-username_desc
         FROM usr21 AS a
      LEFT OUTER JOIN adrp AS d ON
          d~persnumber = a~persnumber
         WHERE a~bname = @mv_user.

  ENDMETHOD.

ENDCLASS.
