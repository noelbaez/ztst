*&----------------------------------------------------------------------------------------------------*
*& Report  ZPWM_007
*&----------------------------------------------------------------------------------------------------*
*&Autor: Latcapital Solutions
*&Documentacion: Se requiere la creaciÛn de una transacciÛn para ser accesada desde los dispositivos
*&mÛviles, la cual permita la visualizaciÛn del inventario en dos modalidades:
*&1.- VisualizaciÛn por SU-UA: En esta, la entrada ser· la etiqueta y devolver· los datos del contenido
*&de la misma.
*&2.- VisualizaciÛn por UbicaciÛn: En esta opciÛn, la entrada es la ubicaciÛn y devolver· los datos de
*&cada uno de los pallets en la ubicaciÛn, asÌ como el total de los mismos.
*&----------------------------------------------------------------------------------------------------*

REPORT  ztesnb_wm007.

TABLES: lrf_wkqu, lein, lagp, lqua, makt, mch1.

DATA: BEGIN OF it_ubicaciones OCCURS 0.
        INCLUDE STRUCTURE lqua.
DATA: END OF it_ubicaciones.

DATA: answer        TYPE c,
      valido        TYPE i,
      leidos        TYPE i,
      c_item        TYPE i,
      ubicacion(15) TYPE c.

DATA: lgnum     LIKE lrf_wkqu-lgnum.
DATA: message01 TYPE string.
*&---------------------------------------------------------------------*
*Validaciones Iniciales
*Layout usuario
*&---------------------------------------------------------------------*
CLEAR lrf_wkqu.
SELECT SINGLE * FROM lrf_wkqu
  INTO lrf_wkqu
WHERE bname EQ sy-uname.

IF lrf_wkqu IS NOT INITIAL.
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
      CLEAR: lein, lagp.
    WHEN 'BACK'.
      CLEAR: lagp, lein.
      PERFORM confirmar_salida.
    WHEN 'CANCEL'.
      PERFORM confirmar_salida.
    WHEN 'ENTER'.
      IF lein-lenum EQ space AND lagp-lgpla EQ space.
        MESSAGE 'Debe ingresar un valor.' TYPE 'S' DISPLAY LIKE 'E'.
      ELSE.
        IF lein-lenum NE space AND lagp-lgpla NE space.
          MESSAGE 'Ingrese solo un valor, UA o Ubicación' TYPE 'S' DISPLAY LIKE 'E'.
        ELSE.
          IF lein-lenum NE space.
            CLEAR valido.
            PERFORM valida_storage CHANGING valido.
            IF valido IS NOT INITIAL.
              CLEAR lgnum.
              PERFORM valida_almacen CHANGING lgnum.
              IF lgnum IS NOT INITIAL.
                PERFORM busca_data_storage_unit.
                LEAVE TO SCREEN '0003'.
              ELSE.
                CLEAR message01.
                CONCATENATE 'Perfil no existe para usuario' sy-uname
                INTO message01 SEPARATED BY space.

                MESSAGE message01 TYPE 'S' DISPLAY LIKE 'E'.
              ENDIF.
            ELSE.
              MESSAGE 'UA no existe' TYPE 'S' DISPLAY LIKE 'E'.
            ENDIF.
          ELSEIF lagp-lgpla NE space.
            CLEAR valido.
            PERFORM valida_bin CHANGING valido.
            IF valido IS NOT INITIAL.
              PERFORM busca_data_ubicacion.
              LEAVE TO SCREEN '0005'.
            ELSE.
              MESSAGE 'Ubicación no existe' TYPE 'S' DISPLAY LIKE 'E'.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
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
  LEAVE PROGRAM.
ENDFORM.                    " CONFIRMAR_SALIDA
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0002  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0002 INPUT.

  CASE sy-ucomm.
    WHEN 'CLEAR'.
      CLEAR: lein, lagp.
    WHEN 'BACK'.
      CLEAR: lagp, lein.
      PERFORM confirmar_salida.
    WHEN 'CANCEL'.
      PERFORM confirmar_salida.
    WHEN 'ENTER'.
      IF lein-lenum EQ space AND lagp-lgpla EQ space.
        MESSAGE 'Debe ingresar un valor.' TYPE 'S' DISPLAY LIKE 'E'.
      ELSE.
        IF lein-lenum NE space AND lagp-lgpla NE space.
          MESSAGE 'Ingrese solo un valor, UA o Ubicación' TYPE 'S' DISPLAY LIKE 'E'.
        ELSE.
          IF lein-lenum NE space.
            CLEAR valido.
            PERFORM valida_storage CHANGING valido.
            IF valido IS NOT INITIAL.
              PERFORM valida_almacen CHANGING lgnum.
              IF lgnum IS NOT INITIAL.
                PERFORM busca_data_storage_unit.
                LEAVE TO SCREEN '0004'.
              ELSE.
                CLEAR message01.
                CONCATENATE 'Perfil no existe para usuario' sy-uname
                INTO message01 SEPARATED BY space.

                MESSAGE message01 TYPE 'S' DISPLAY LIKE 'E'.
              ENDIF.
            ELSE.
              MESSAGE 'UA no existe' TYPE 'S' DISPLAY LIKE 'E'.
            ENDIF.
          ELSEIF lagp-lgpla NE space.
            CLEAR valido.
            PERFORM valida_bin CHANGING valido.
            IF valido IS NOT INITIAL.
              PERFORM busca_data_ubicacion.
              LEAVE TO SCREEN '0006'.
            ELSE.
              MESSAGE 'Ubicación no existe' TYPE 'S' DISPLAY LIKE 'E'.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
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
  SET TITLEBAR  '0001'.

  PERFORM control_next_prev.

ENDMODULE.                 " STATUS_2  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  VALIDA_STORAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_VALIDO  text
*----------------------------------------------------------------------*
FORM valida_storage  CHANGING p_valido.
  DATA: lenum TYPE lenum.

  lenum = lein-lenum.

  CALL FUNCTION 'CONVERSION_EXIT_LENUM_INPUT'
    EXPORTING
      input  = lenum
    IMPORTING
      output = lenum.

  CLEAR lein-lenum.
  SELECT SINGLE lenum FROM lein
    INTO lein-lenum
  WHERE lenum EQ lenum.

  IF lein-lenum IS NOT INITIAL.
    p_valido = '1'.
  ENDIF.

ENDFORM.                    " VALIDA_STORAGE
*&---------------------------------------------------------------------*
*&      Form  VALIDA_ALMACEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LGNUM  text
*----------------------------------------------------------------------*
FORM valida_almacen  CHANGING p_lgnum.
  DATA: lgnum TYPE lgnum.

  SELECT SINGLE lgnum FROM lrf_wkqu
    INTO lgnum
  WHERE bname EQ sy-uname
    AND statu EQ 'X'.

  IF lgnum IS NOT INITIAL.
    p_lgnum = lgnum.
  ENDIF.

ENDFORM.                    " VALIDA_ALMACEN
*&---------------------------------------------------------------------*
*&      Form  BUSCA_DATA_STORAGE_UNIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM busca_data_storage_unit .

  CLEAR lqua.
  SELECT SINGLE * FROM lqua
    INTO lqua
  WHERE lenum EQ lein-lenum
    AND lgnum EQ lgnum.

  CLEAR makt-maktx.
  PERFORM busca_descripcion_mat CHANGING makt-maktx.
  PERFORM busca_lote_proveedor.

ENDFORM.                    " BUSCA_DATA_STORAGE_UNIT
*&---------------------------------------------------------------------*
*&      Form  OUTPUT_SU_UA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM output_su_ua .

  CALL FUNCTION 'CONVERSION_EXIT_LENUM_OUTPUT'
    EXPORTING
      input  = lein-lenum
    IMPORTING
      output = lein-lenum.

ENDFORM.                    " OUTPUT_SU_UA
*&---------------------------------------------------------------------*
*&      Form  VALIDA_BIN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_VALIDO  text
*----------------------------------------------------------------------*
FORM valida_bin  CHANGING p_valido.
  DATA: lgpla TYPE lgpla.

  SELECT SINGLE lgpla FROM lagp
    INTO lgpla
  WHERE lgpla EQ lagp-lgpla
    AND lgnum EQ lrf_wkqu-lgnum.

  IF lgpla IS NOT INITIAL.
    p_valido = '1'.
  ENDIF.

ENDFORM.                    " VALIDA_BIN
*&---------------------------------------------------------------------*
*&      Form  BUSCA_DATA_UBICACION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM busca_data_ubicacion .

  CLEAR lagp-anzqu.
  SELECT SUM( anzqu ) FROM lagp
    INTO lagp-anzqu
  WHERE lgnum EQ lrf_wkqu-lgnum
    AND lgpla EQ lagp-lgpla.
*----------------------------------------------------------------------*
*Busca data general
*----------------------------------------------------------------------*
  REFRESH it_ubicaciones.
  CLEAR:  it_ubicaciones, lqua, makt-maktx, mch1-licha, leidos.

  IF lagp-anzqu NE 0.
    REFRESH it_ubicaciones.
    CLEAR   it_ubicaciones.
    SELECT * FROM lqua
      INTO TABLE it_ubicaciones
    WHERE lgnum EQ lrf_wkqu-lgnum
      AND lgpla EQ lagp-lgpla.

    SORT it_ubicaciones ASCENDING.
    READ TABLE it_ubicaciones INDEX 1.
    IF sy-subrc EQ 0.
      CLEAR lqua.
      MOVE-CORRESPONDING it_ubicaciones TO lqua.
      leidos = 1.
    ENDIF.

    CLEAR makt-maktx.
    PERFORM busca_descripcion_mat CHANGING makt-maktx.
    PERFORM busca_lote_proveedor.
  ELSE.
    MESSAGE 'No existen datos de Stock para la Ubicación' TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE TO SCREEN sy-dynnr.
  ENDIF.

ENDFORM.                    " BUSCA_DATA_UBICACION
*&---------------------------------------------------------------------*
*&      Form  BUSCA_DESCRIPCION_MAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_MAKT_MAKTX  text
*----------------------------------------------------------------------*
FORM busca_descripcion_mat  CHANGING p_makt_maktx.

  IF lqua IS NOT INITIAL.
    SELECT SINGLE maktx FROM makt
      INTO p_makt_maktx
    WHERE matnr EQ lqua-matnr
      AND spras EQ sy-langu.
  ENDIF.

ENDFORM.                    " BUSCA_DESCRIPCION_MAT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0005  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0005 INPUT.

  CASE sy-ucomm.
    WHEN 'NEXT_V'.
      CLEAR c_item.
      DESCRIBE TABLE it_ubicaciones LINES c_item.
      IF leidos < c_item AND leidos <> 0.
        leidos = leidos + 1.
        READ TABLE it_ubicaciones INDEX leidos.
        CLEAR lqua.
        MOVE-CORRESPONDING it_ubicaciones TO lqua.

        CLEAR makt-maktx.
        PERFORM busca_descripcion_mat CHANGING makt-maktx.
        PERFORM busca_lote_proveedor.
      ENDIF.
    WHEN 'PREV_V'.
      IF leidos > 0.
        leidos = leidos - 1.
      ENDIF.
      READ TABLE it_ubicaciones INDEX leidos.
      CLEAR lqua.
      MOVE-CORRESPONDING it_ubicaciones TO lqua.

      CLEAR makt-maktx.
      PERFORM busca_descripcion_mat CHANGING makt-maktx.
      PERFORM busca_lote_proveedor.
    WHEN 'BACK'.
      CLEAR: lagp, lein.
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
    WHEN 'NEXT_V'.
      CLEAR c_item.
      DESCRIBE TABLE it_ubicaciones LINES c_item.
      IF leidos < c_item AND leidos <> 0.
        leidos = leidos + 1.
        READ TABLE it_ubicaciones INDEX leidos.
        CLEAR lqua.
        MOVE-CORRESPONDING it_ubicaciones TO lqua.

        CLEAR makt-maktx.
        PERFORM busca_descripcion_mat CHANGING makt-maktx.
        PERFORM busca_lote_proveedor.
      ENDIF.
    WHEN 'PREV_V'.
      IF leidos > 0.
        leidos = leidos - 1.
      ENDIF.
      READ TABLE it_ubicaciones INDEX leidos.
      CLEAR lqua.
      MOVE-CORRESPONDING it_ubicaciones TO lqua.

      CLEAR makt-maktx.
      PERFORM busca_descripcion_mat CHANGING makt-maktx.
      PERFORM busca_lote_proveedor.
    WHEN 'BACK'.
      CLEAR: lagp, lein.
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
    WHEN 'BACK'.
      PERFORM output_su_ua.
      CLEAR: lagp, lein.
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
    WHEN 'BACK'.
      PERFORM output_su_ua.
      CLEAR: lagp, lein.
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
*&      Form  CONTROL_NEXT_PREV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM control_next_prev .

  IF lagp-anzqu > 1.
    IF leidos = 1.
      LOOP AT SCREEN.
        IF screen-name EQ 'RLMOB-PPGUP'.
          screen-invisible = 1.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    ELSEIF leidos = lagp-anzqu.
      LOOP AT SCREEN.
        IF screen-name EQ 'RLMOB-PPGDN'.
          screen-invisible = 1.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

  IF lagp-anzqu EQ 1 OR lagp-anzqu = 0.
    LOOP AT SCREEN.
      IF screen-name EQ 'RLMOB-PPGUP'
        OR screen-name EQ 'RLMOB-PPGDN'.
        screen-invisible = 1.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

*Ubicacion Texto dinamico
  LOOP AT SCREEN.
    IF screen-name = 'UBICACION'.
      IF sy-dynnr EQ '0005' OR sy-dynnr EQ '0006'.
        READ TABLE it_ubicaciones WITH KEY lqnum = lqua-lqnum.
        IF it_ubicaciones-gesme NE 0.
          ubicacion = 'Ubicación'.
        ELSE.
          ubicacion = 'En tránsito a'.
          MOVE it_ubicaciones-einme TO lqua-gesme.
        ENDIF.
      ELSEIF sy-dynnr EQ '0003' OR sy-dynnr EQ '0004'.
        IF lqua-gesme EQ 0.
          MOVE lqua-einme TO lqua-gesme.
        ENDIF.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDFORM.                    " CONTROL_NEXT_PREV
