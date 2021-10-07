*&-------------------------------------------------------------------------------------------------------------*
*& Report  ZPWM_006
*&-------------------------------------------------------------------------------------------------------------*
*&Autor: Latcapital Solutions
*&Fecha: 03 de Septiembre 2014
*&Documentacion: En el proceso est·ndar, la generaciÛn de Ordenes de Transporte se derivan de un documento
*&creado a nivel AdministraciÛn de Inventario (IM), el cual determinara la cantidad de materiales a mover
*&asÌ como las estrategias que se predeterminaron como origen y destino, de manera que el personal operativo
*&recibe dichas OTs y se dedica a la ejecuciÛn de las mismas en el almacÈn.
*&
*&Sin embargo, existen escenarios donde es necesario mover materiales de un lugar a otro, sin tener una
*&estrategia predeterminada, ni un documento de traspaso que origine dicho movimiento. Estos casos de excepciÛn
*&ocurren cuando se requiere mover debido a un mantenimiento, o a un reacomodo del almacÈn.
*&Para cubrir este escenario, se requiere un desarrollo que en modo no visible, cree una orden de transporte
*&y la confirme, basado en los datos que el usuario proporcione, dichos datos son el numero de Pallet y la
*&ubicaciÛn destino.
*&-------------------------------------------------------------------------------------------------------------*
REPORT  ztesnb_wm006.

TABLES: lrf_wkqu, lein, lagp, lqua, makt, mch1, rl03t,
        ltap, mara, rlmob, mcha, t301.

DATA: BEGIN OF it_ubicaciones OCCURS 0.
        INCLUDE STRUCTURE lqua.
DATA: END OF it_ubicaciones.

DATA: valido       TYPE i.
DATA: message01    TYPE string,
      longitud     TYPE i,
      cantidad(13) TYPE p.

DATA: lgnum      LIKE lrf_wkqu-lgnum,
      ua_destino LIKE lagp-lgpla,
      verif      LIKE lagp-verif,
      ua         LIKE lqua-lenum,
      lgtypa     LIKE lagp-lgtyp,
      lgtypb     LIKE lagp-lgtyp.

DATA: segundo_es    TYPE c.
DATA: c_xchpf       LIKE mara-xchpf.

DATA: ean_128(128) TYPE c,
      licha        LIKE mch1-licha,
      material     LIKE mara-matnr.
*&---------------------------------------------------------------------*
*Validaciones Iniciales
*Layout usuario
*&---------------------------------------------------------------------*
PERFORM valida_perfil.
*&---------------------------------------------------------------------*
*&      Module  STATUS_MAINMENU  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_mainmenu OUTPUT.
  SET PF-STATUS '0001'.
  SET TITLEBAR  '0001'.
ENDMODULE.                 " STATUS_MAINMENU  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0001 INPUT.

  CASE sy-ucomm.
    WHEN 'CLEAR'.
      CLEAR: lagp, lein, lqua, rlmob-cmatnr, cantidad, rl03t-anfme,ltap,
      ean_128.
    WHEN 'ENTER'.
      MESSAGE 'Pulse F5 o F6 para continuar' TYPE 'S'.
    WHEN 'BACK'.
      CLEAR: lagp, lein, lqua, rlmob-cmatnr, cantidad, rl03t-anfme,ltap,
      ua_destino.
      PERFORM confirmar_salida.
    WHEN 'CANCEL'.
      PERFORM confirmar_salida.
    WHEN 'TOTAL'.
      CLEAR segundo_es.
      PERFORM valida_primer_escenario.
    WHEN 'PART'.
      PERFORM valida_segundo_escenario.
    WHEN 'SALIR'.
      PERFORM confirmar_salida.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0001  INPUT
*&---------------------------------------------------------------------*
*&      Form  CONFIRMAR_SALIDA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM confirmar_salida .
*  LEAVE PROGRAM.
  LEAVE TO TRANSACTION 'LM01'.
ENDFORM.                    " CONFIRMAR_SALIDA
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0002  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0002 INPUT.

  CASE sy-ucomm.
    WHEN 'ENTER'.
      MESSAGE 'Pulse F5 o F6 para continuar' TYPE 'S'.
    WHEN 'CLEAR'.
      CLEAR: lagp, lein, lqua, rlmob-cmatnr, cantidad, rl03t-anfme,ltap,
      ean_128.
    WHEN 'BACK'.
      CLEAR: lagp, lein, lqua, rlmob-cmatnr, cantidad, rl03t-anfme,ltap,
    ua_destino.
      PERFORM confirmar_salida.
    WHEN 'CANCEL'.
      PERFORM confirmar_salida.
    WHEN 'TOTAL'.
      CLEAR segundo_es.
      PERFORM valida_primer_escenario.
    WHEN 'PART'.
      PERFORM valida_segundo_escenario.
    WHEN 'SALIR'.
      PERFORM confirmar_salida.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0002  INPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_2  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_2 OUTPUT.
  SET PF-STATUS '0002'.
  SET TITLEBAR  '0002'.
ENDMODULE.                 " STATUS_2  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0005  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0005 INPUT.

  CASE sy-ucomm.
    WHEN 'BACK'.
      CLEAR: lagp, lein, lqua.
      LEAVE TO SCREEN '0001'.
    WHEN 'CANCEL'.
      PERFORM confirmar_salida.
    WHEN 'SALIR'.
      PERFORM confirmar_salida.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0005  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0006  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0006 INPUT.

  CASE sy-ucomm.
    WHEN 'BACK'.
      CLEAR: lagp, lein, lqua.
      LEAVE TO SCREEN '0002'.
    WHEN 'CANCEL'.
      PERFORM confirmar_salida.
    WHEN 'SALIR'.
      PERFORM confirmar_salida.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0006  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0003  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0003 INPUT.

  CASE sy-ucomm.
    WHEN 'ENTER' OR 'REIN' OR 'GRABAR'.
      PERFORM crea_orden_transporte.
    WHEN 'BACK'.
      CLEAR: lagp, lein, lqua, ua_destino.
      LEAVE TO SCREEN '0001'.
    WHEN 'CANCEL'.
      PERFORM confirmar_salida.
    WHEN 'SALIR'.
      PERFORM confirmar_salida.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0003  INPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0004  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0004 INPUT.

  CASE sy-ucomm.
    WHEN 'ENTER' OR 'REIN' OR 'GRABAR'.
      PERFORM crea_orden_transporte.
    WHEN 'BACK'.
      CLEAR: lagp, lein, lqua, ua_destino.
      LEAVE TO SCREEN '0002'.
    WHEN 'CANCEL'.
      PERFORM confirmar_salida.
    WHEN 'SALIR'.
      PERFORM confirmar_salida.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0004  INPUT
*&---------------------------------------------------------------------*
*&      Form  BUSCA_LOTE_PROVEEDOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM busca_lote_proveedor .
  DATA: material LIKE mara-matnr,
        longitud TYPE i.

  MOVE lqua-matnr TO material.

  longitud = strlen( material ).

  IF longitud < 18.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = material
      IMPORTING
        output = material.
  ENDIF.

  CLEAR mch1-licha.
  SELECT SINGLE licha FROM mch1
    INTO mch1-licha
  WHERE charg EQ lqua-charg
    AND matnr EQ lqua-matnr.


ENDFORM.                    " BUSCA_LOTE_PROVEEDOR
*&---------------------------------------------------------------------*
*&      Form  VALIDA_ALMACEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LGNUM  text
*----------------------------------------------------------------------*
FORM valida_almacen  CHANGING p_lgnum.

  SELECT SINGLE * FROM lrf_wkqu
    INTO lrf_wkqu
  WHERE bname EQ sy-uname
    AND statu EQ 'X'.

  IF lrf_wkqu-lgnum IS NOT INITIAL.
    p_lgnum = lrf_wkqu-lgnum.
  ENDIF.

ENDFORM.                    " VALIDA_ALMACEN
*&---------------------------------------------------------------------*
*&      Form  VALIDA_PERFIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_VALIDO  text
*----------------------------------------------------------------------*
FORM valida_perfil.

  CLEAR lgnum.
  PERFORM valida_almacen CHANGING lgnum.

  IF lgnum IS NOT INITIAL.
    IF lrf_wkqu-devty EQ '8X40'.
      CALL SCREEN '0001'.
    ELSEIF lrf_wkqu-devty EQ '16X20'.
      CALL SCREEN '0002'.
    ENDIF.
  ELSE.
    CLEAR message01.
    CONCATENATE 'Perfil no existe para usuario' sy-uname
    INTO message01 SEPARATED BY space.

    MESSAGE message01 TYPE 'S' DISPLAY LIKE 'E'.

  ENDIF.

ENDFORM.                    " VALIDA_PERFIL
*&---------------------------------------------------------------------*
*&      Form  VALIDA_PRIMER_ESCENARIO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM valida_primer_escenario .

*Validacion Primer Escenario (Por Unidad de Almacen):
  IF lqua-lenum EQ space OR lagp-lgpla EQ space.
    MESSAGE 'Debe completar UA y Ubic Destino' TYPE 'S' DISPLAY LIKE 'E'.
  ELSE.
    IF lqua-matnr   NE space
    OR rlmob-cmatnr NE space
    OR lqua-charg   NE space
    OR lein-statu   NE space
    OR rl03t-anfme  NE space
    OR lqua-meins   NE space
    OR ltap-vlpla   NE space
    OR ltap-nlpla   NE space.

      MESSAGE 'Sólo llenar valores para un tipo de OT' TYPE 'S' DISPLAY LIKE 'E'.
    ELSE.
      PERFORM busca_data.
      IF lrf_wkqu-devty EQ '8X40'.
        LEAVE TO SCREEN '0003'.
      ELSEIF lrf_wkqu-devty EQ '16X20'.
        LEAVE TO SCREEN '0004'.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " VALIDA_PRIMER_ESCENARIO
*&---------------------------------------------------------------------*
*&      Form  VALIDA_SEGUNDO_ESCENARIO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM valida_segundo_escenario .

  PERFORM valida_sujeto_lote.

*Validacion Segundo Escenario (Sin Unidad de Almacen):
  IF lqua-lenum NE space OR lagp-lgpla NE space.
    MESSAGE 'Sólo llenar valores para un tipo de OT' TYPE 'S' DISPLAY LIKE 'E'.
  ELSEIF lqua-matnr EQ space AND rlmob-cmatnr EQ space.
    MESSAGE 'Debe colocar el Material o EAN11' TYPE 'S' DISPLAY LIKE 'E'.
  ELSEIF lqua-charg EQ space AND c_xchpf NE space.
    MESSAGE 'Debe colocar el Lote' TYPE 'S' DISPLAY LIKE 'E'.
  ELSEIF rl03t-anfme EQ space.
    MESSAGE 'Debe colocar la Cantidad' TYPE 'S' DISPLAY LIKE 'E'.
  ELSEIF lqua-meins EQ space.
    MESSAGE 'Debe colocar la Unidad de Medida' TYPE 'S' DISPLAY LIKE 'E'.
  ELSEIF ltap-vlpla EQ space.
    MESSAGE 'Debe colocar la Ubic. Orig.' TYPE 'S' DISPLAY LIKE 'E'.
  ELSEIF ltap-nlpla EQ space.
    MESSAGE 'Debe colocar la Ubic. Dest.' TYPE 'S' DISPLAY LIKE 'E'.
  ELSE.
    segundo_es = 'X'.
    PERFORM busca_data.

  ENDIF.

ENDFORM.                    " VALIDA_SEGUNDO_ESCENARIO
*&---------------------------------------------------------------------*
*&      Form  BUSCA_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM busca_data .
  DATA: mat03 TYPE matnr.

*Busca Datos Almacen
  IF segundo_es NE 'X'.
    SELECT SINGLE  * FROM lqua
      INTO lqua
    WHERE lenum EQ lqua-lenum.

    SELECT SINGLE * FROM lagp
      INTO lagp
    WHERE lgnum EQ lqua-lenum
      AND lgpla EQ lagp-lgpla.

    CLEAR verif.
    MOVE  lagp-verif TO verif.
    CLEAR lagp-verif.

  ELSE.
    MOVE lqua-matnr TO mat03.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = mat03
      IMPORTING
        output = mat03
*   EXCEPTIONS
*       LENGTH_ERROR       = 1
*       OTHERS = 2
      .
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    SELECT SINGLE  * FROM lqua
      INTO lqua
    WHERE lgnum EQ lrf_wkqu-lgnum
      AND matnr EQ mat03
      AND charg EQ lqua-charg
      AND lgpla EQ ltap-vlpla.

    IF sy-subrc NE 0.
      MESSAGE 'No existen datos para combinación (Material, Centro, No.Almacen, UA destino.)' TYPE 'S' DISPLAY LIKE 'E'.
      EXIT.
    ENDIF.
    PERFORM crea_orden_transporte.
*Busca Descripcion Material
    CLEAR makt-maktx.
    PERFORM busca_descripcion_mat USING    lqua-matnr
                                  CHANGING makt-maktx.
  ENDIF.

ENDFORM.                    " BUSCA_DATA
*&---------------------------------------------------------------------*
*&      Form  VALIDA_BIN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_VALIDO  text
*----------------------------------------------------------------------*
FORM valida_bin  CHANGING p_valido.
  DATA: lgpla TYPE lgpla.

  SELECT SINGLE * FROM lagp
    INTO lagp
  WHERE lgpla EQ lagp-lgpla
    AND lgnum EQ lrf_wkqu-lgnum.

  IF sy-subrc EQ 0.
    ua_destino = lagp-lgpla.
    p_valido   = '1'.
  ENDIF.

ENDFORM.                    " VALIDA_BIN
*&---------------------------------------------------------------------*
*&      Form  CREA_ORDEN_TRANSPORTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM crea_orden_transporte .
  DATA: lv_bwlvs LIKE ltak-bwlvs,
        ot       LIKE ltak-tanum,
        confirma TYPE c.

  lv_bwlvs = '950'.

  CLEAR ot.
  IF segundo_es NE 'X'.
    confirma = 'X'.

    CALL FUNCTION 'L_TO_CREATE_SINGLE'
      EXPORTING
        i_lgnum               = lqua-lgnum
        i_bwlvs               = lv_bwlvs
        i_bestq               = ltap-bestq
        i_matnr               = lqua-matnr
        i_werks               = lqua-werks
        i_lgort               = lqua-lgort
        i_charg               = lqua-charg
        i_anfme               = lqua-gesme
        i_altme               = lqua-meins
        i_vfdat               = lqua-vfdat
        i_vlqnr               = lqua-lqnum
        i_vltyp               = lqua-lgtyp
        i_vlpla               = lqua-lgpla
        i_nltyp               = lagp-lgtyp
        i_nlpla               = ua_destino
        i_squit               = confirma
        i_commit_work         = 'X'
        i_update_task         = 'X'
        i_bname               = sy-uname
      IMPORTING
        e_tanum               = ot
      EXCEPTIONS
        no_to_created         = 1
        bwlvs_wrong           = 2
        betyp_wrong           = 3
        benum_missing         = 4
        betyp_missing         = 5
        foreign_lock          = 6
        vltyp_wrong           = 7
        vlpla_wrong           = 8
        vltyp_missing         = 9
        nltyp_wrong           = 10
        nlpla_wrong           = 11
        nltyp_missing         = 12
        rltyp_wrong           = 13
        rlpla_wrong           = 14
        rltyp_missing         = 15
        squit_forbidden       = 16
        manual_to_forbidden   = 17
        letyp_wrong           = 18
        vlpla_missing         = 19
        nlpla_missing         = 20
        sobkz_wrong           = 21
        sobkz_missing         = 22
        sonum_missing         = 23
        bestq_wrong           = 24
        lgber_wrong           = 25
        xfeld_wrong           = 26
        date_wrong            = 27
        drukz_wrong           = 28
        ldest_wrong           = 29
        update_without_commit = 30
        no_authority          = 31
        material_not_found    = 32
        lenum_wrong           = 33
        OTHERS                = 34.

  ELSE.
    CALL FUNCTION 'L_TO_CREATE_SINGLE'
      EXPORTING
        i_lgnum               = lqua-lgnum
        i_bwlvs               = lv_bwlvs    "Clase de Mov.
        i_bestq               = ltap-bestq  "Status
        i_matnr               = lqua-matnr  "Material
        i_werks               = lqua-werks  "Centro
        i_lgort               = lqua-lgort  "Almacen
        i_charg               = lqua-charg  "Lote
        i_anfme               = rl03t-anfme "Cantidad
        i_altme               = lqua-meins  "UM
        i_vfdat               = lqua-vfdat  "Fecha
        i_vlqnr               = lqua-lqnum
        i_vlpla               = ltap-vlpla  "Origen
        i_vltyp               = lgtypa      "Tipo Almacen Origen
        i_nlpla               = ltap-nlpla  "Destino
        i_nltyp               = lgtypb      "Tipo Almacen Destino
        i_commit_work         = 'X'
        i_update_task         = 'X'
        i_bname               = sy-uname
      IMPORTING
        e_tanum               = ot
      EXCEPTIONS
        no_to_created         = 1
        bwlvs_wrong           = 2
        betyp_wrong           = 3
        benum_missing         = 4
        betyp_missing         = 5
        foreign_lock          = 6
        vltyp_wrong           = 7
        vlpla_wrong           = 8
        vltyp_missing         = 9
        nltyp_wrong           = 10
        nlpla_wrong           = 11
        nltyp_missing         = 12
        rltyp_wrong           = 13
        rlpla_wrong           = 14
        rltyp_missing         = 15
        squit_forbidden       = 16
        manual_to_forbidden   = 17
        letyp_wrong           = 18
        vlpla_missing         = 19
        nlpla_missing         = 20
        sobkz_wrong           = 21
        sobkz_missing         = 22
        sonum_missing         = 23
        bestq_wrong           = 24
        lgber_wrong           = 25
        xfeld_wrong           = 26
        date_wrong            = 27
        drukz_wrong           = 28
        ldest_wrong           = 29
        update_without_commit = 30
        no_authority          = 31
        material_not_found    = 32
        lenum_wrong           = 33
        OTHERS                = 34.

  ENDIF.

  IF sy-subrc EQ 0.
* Implement suitable error handling here
    IF segundo_es EQ 'X'.
      SET PARAMETER ID 'INP_100' FIELD ot.
      LEAVE TO TRANSACTION 'LM03'.
    ELSE.
      CLEAR: lagp, lein, lqua, ltap, ua_destino.
      CLEAR message01.
      CONCATENATE 'OT' ot 'Creada' INTO message01 SEPARATED BY space.
      MESSAGE message01 TYPE 'S'.
      LEAVE TO TRANSACTION 'ZWMOT'.
    ENDIF.
  ELSE.
    CLEAR: lqua-lenum, lagp-lgpla.
    MESSAGE 'Se ha producido un error al crear la OT' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

ENDFORM.                    " CREA_ORDEN_TRANSPORTE
*&---------------------------------------------------------------------*
*&      Module  CHECK_UA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_ua INPUT.

  IF segundo_es NE 'X'.
*&---------------------------------------------------------------------*
*Validamos Longitud del UA
*&---------------------------------------------------------------------*
    MOVE lqua-lenum TO ua.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = ua
      IMPORTING
        output = ua.

    longitud = strlen( ua ).

    IF longitud <> 10.
      CLEAR lqua-lenum.
      MESSAGE 'UA debe ser de 10 números' TYPE 'E'.
    ELSE.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = ua
        IMPORTING
          output = ua.

      SELECT SINGLE lenum FROM lqua
        INTO lqua-lenum
      WHERE lenum EQ ua.

      IF sy-subrc EQ 0.
*&---------------------------------------------------------------------*
*Validamos el status
*&---------------------------------------------------------------------*
        SELECT SINGLE statu FROM lein
          INTO lein-statu
        WHERE lenum EQ ua.

        IF lein-statu NE space.
          CLEAR lqua-lenum.
          MESSAGE 'UA en tránsito o proceso, no se puede mover' TYPE 'E'.
        ENDIF.
      ELSE.
        CLEAR: message01, lqua-lenum.
        CONCATENATE 'Pallet' ua 'no existe' INTO message01 SEPARATED BY space.
        MESSAGE message01 TYPE 'E'.
      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.                 " CHECK_UA  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_VERIF  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_verif INPUT.

  IF lagp-verif IS NOT INITIAL.
    IF lagp-verif <> ua_destino.
      CLEAR lagp-verif.
      MESSAGE 'Ubicación o Verificación Incorrecta. Corregir.' TYPE 'E'.
    ENDIF.
  ELSE.
    MESSAGE 'Falta Valor de Verificación' TYPE  'E'.
  ENDIF.

ENDMODULE.                 " CHECK_VERIF  INPUT
*&---------------------------------------------------------------------*
*&      Form  BUSCA_DESCRIPCION_MAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LQUA_MATNR  text
*      <--P_MAKT_MAKTX  text
*----------------------------------------------------------------------*
FORM busca_descripcion_mat  USING    p_lqua_matnr
                            CHANGING p_makt_maktx.

  SELECT SINGLE maktx FROM makt
    INTO p_makt_maktx
  WHERE matnr EQ p_lqua_matnr
    AND spras EQ sy-langu.

ENDFORM.                    " BUSCA_DESCRIPCION_MAT
*&---------------------------------------------------------------------*
*&      Module  BUSCA_UM  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE busca_um INPUT.

  rl03t-anfme = cantidad.

*UM Material
  SELECT SINGLE meins FROM mara
    INTO lqua-meins
  WHERE matnr EQ lqua-matnr.

ENDMODULE.                 " BUSCA_UM  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_UB  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_ub INPUT.

*Valida Ubicacion
  CLEAR valido.
  PERFORM valida_bin CHANGING valido.
  IF valido IS INITIAL.
    CLEAR lagp-lgpla.
    MESSAGE 'Ubicación no existe' TYPE 'E'.
  ENDIF.

ENDMODULE.                 " CHECK_UB  INPUT
*&---------------------------------------------------------------------*
*&      Module  CHECK_EAN11  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_ean11 INPUT.
  DATA: mat02 TYPE matnr.

*Si se ha colocado un codigo EAN11
  SELECT SINGLE matnr FROM mara
    INTO lqua-matnr
  WHERE ean11 = lqua-matnr.

  IF sy-subrc NE 0.
    SELECT SINGLE matnr FROM mean
    INTO lqua-matnr
  WHERE ean11 = lqua-matnr.

    IF sy-subrc NE 0.
*Busca si es un material SAP
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
        EXPORTING
          input  = lqua-matnr
        IMPORTING
          output = mat02.

      SELECT SINGLE matnr FROM mara
        INTO lqua-matnr
      WHERE matnr = mat02.

      IF sy-subrc NE 0.
        CLEAR lqua-matnr.
        MESSAGE 'No se existe Material para EAN11.' TYPE 'E'.
      ELSE.
        CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
          EXPORTING
            input  = lqua-matnr
          IMPORTING
            output = lqua-matnr.
      ENDIF.
    ENDIF.
  ELSE.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        input  = lqua-matnr
      IMPORTING
        output = lqua-matnr.
  ENDIF.
ENDMODULE.                 " CHECK_EAN11  INPUT
*&---------------------------------------------------------------------*
*&      Module  DESCOMPONER_EAN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE descomponer_ean INPUT.
  DATA: ean_material(100) TYPE c.

  DATA: ean11(18) TYPE c,
        ean14(14) TYPE c,
        ean13(13) TYPE c,
        ean(18)   TYPE c,
        mensaje   TYPE string,
        mat       TYPE matnr.

  CLEAR ean11.
  MOVE  ean_128 TO ean11.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = ean11
    IMPORTING
      output = ean11.

  IF lqua-matnr NE ean11.
*----------------------------------------------------------------------*
*Validamos el Material por el EAN (Que exista)
*----------------------------------------------------------------------*
    MOVE lqua-matnr TO material.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = lqua-matnr
      IMPORTING
        output = mat
*     EXCEPTIONS
*       LENGTH_ERROR       = 1
*       OTHERS = 2
      .
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    SELECT SINGLE matnr
        FROM mara
    INTO lqua-matnr
    WHERE matnr EQ mat
      AND ean11 EQ ean11.

    IF sy-subrc NE 0.
      SELECT SINGLE matnr
        FROM mean
      INTO lqua-matnr
      WHERE matnr EQ mat
        AND ean11 EQ ean11.
    ELSE.
      CLEAR mensaje.
      CONCATENATE 'EAN' ean11 'No existe.' INTO mensaje SEPARATED BY space.
      MESSAGE mensaje TYPE 'E'.
    ENDIF.
  ENDIF.

*Buscamos el Lote del Proveedor
  IF lqua-charg IS NOT INITIAL.
    SELECT SINGLE licha FROM mcha
    INTO mcha-licha
    WHERE matnr EQ lqua-matnr.
  ENDIF.

ENDMODULE.                 " DESCOMPONER_EAN  INPUT
**&---------------------------------------------------------------------*
**&      Module  CHECK_TYP  INPUT
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
*MODULE check_typ INPUT.
*  DATA: mensaje02 TYPE string.
*
*  IF ltap-vlpla NE space.
*    SELECT SINGLE * FROM t301
*      INTO t301
*     WHERE lgnum EQ ltap-vlpla
*       AND lgtyp EQ lagp-lgtyp.
*
*    IF sy-subrc NE 0.
*      CONCATENATE 'El tipo de almacén no existe para la Ubicación Proc.' ltap-vlpla
*      INTO mensaje02 SEPARATED BY space.
*
*      MESSAGE mensaje02 TYPE 'E'.
*    ENDIF.
*  ELSE.
*    SELECT SINGLE * FROM t301
*      INTO t301
*    WHERE lgtyp EQ lagp-lgtyp.
*
*    IF sy-subrc NE 0.
*      CONCATENATE 'El tipo de almacén' lagp-lgtyp 'no existe.'
*      INTO mensaje02 SEPARATED BY space.
*
*      MESSAGE mensaje02 TYPE 'E'.
*    ENDIF.
*  ENDIF.
*
*ENDMODULE.                 " CHECK_TYP  INPUT
*&---------------------------------------------------------------------*
*&      Module  BUSCA_ALMACEN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE busca_almacen INPUT.
  DATA: ubi_destino LIKE lagp-lgpla.
*----------------------------------------------------------------------*
*Valida la Ubicacion Origen
*----------------------------------------------------------------------*
  SELECT SINGLE lgpla FROM lagp
  INTO ubi_destino
  WHERE lgpla EQ ltap-vlpla.

  IF sy-subrc NE 0.
    MESSAGE 'La Ubicacion Origen no existe.' TYPE 'E'.
    CLEAR ltap-vlpla.
  ELSE.
*----------------------------------------------------------------------*
*Buscamos el Tipo de Almacen
*----------------------------------------------------------------------*
    CLEAR: lgtypa, lagp-lgtyp.
    SELECT SINGLE lgtyp FROM lagp
    INTO lgtypa
    WHERE lgpla EQ ltap-vlpla.

    IF sy-subrc EQ 0.
      MOVE lgtypa TO lagp-lgtyp.
    ENDIF.
  ENDIF.

ENDMODULE.                 " BUSCA_ALMACEN  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDA_DESTINO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE valida_destino INPUT.

  CLEAR lgtypb.
  SELECT SINGLE lgtyp FROM lagp
  INTO lgtypb
  WHERE lgpla EQ ltap-nlpla.

  IF sy-subrc NE 0.
    MESSAGE 'La Ubicacion Destino no existe.' TYPE 'E'.
    CLEAR ltap-nlpla.
  ENDIF.

ENDMODULE.                 " VALIDA_DESTINO  INPUT
*&---------------------------------------------------------------------*
*&      Form  VALIDA_SUJETO_LOTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_C_XCHPF  text
*----------------------------------------------------------------------*
FORM valida_sujeto_lote.

*Validamos si el material esta sujeto a lote antes
  SELECT SINGLE xchpf FROM mara
    INTO c_xchpf
  WHERE matnr EQ lqua-matnr.

  IF sy-subrc NE 0.
    SELECT SINGLE xchpf FROM mara
      INTO c_xchpf
    WHERE ean11 EQ rlmob-cmatnr.
  ENDIF.

ENDFORM.
