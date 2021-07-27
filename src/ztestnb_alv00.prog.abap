*&---------------------------------------------------------------------*
*& Report ZTESTNB_ALV00
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report ztestnb_alv00.
*---------------------------------------------------------------------*
*       CLASS lcl_handle_events DEFINITION
*---------------------------------------------------------------------*
class lcl_handle_events definition.
  public section.
    interfaces zif_salv_handler.
    aliases: on_user_command for zif_salv_handler~on_user_command,
             on_double_click for zif_salv_handler~on_double_click.
*    methods: on_user_command for event added_function of cl_salv_events     importing e_salv_function,
*      on_double_click for event double_click of cl_salv_events_table importing row column.
endclass.

*---------------------------------------------------------------------*
*       CLASS lcl_handle_events IMPLEMENTATION
*---------------------------------------------------------------------*
class lcl_handle_events implementation.
  method on_user_command.
    break-point.
    case e_salv_function.
      when 'ZCARGA'.
    endcase.
  endmethod.                    "on_user_command

  method zif_salv_handler~on_double_click.
    break-point.
    case column.
      when 'ICON'.
    endcase.
  endmethod.
endclass.

data oalv type ref to zcl_salv_table.
data ohandler type ref to zif_salv_handler.
data ohandler2 type ref to lcl_handle_events.
data ls_header type zif_salv=>ty_header.
data it_header type zif_salv=>tt_header.
data ls_colattr type zif_salv=>ty_colattr.
data it_colattr type zif_salv=>tt_colattr.

start-of-selection.

  select * from usr01 into table @data(it_usr01).

  ls_header-typ = 'T'.
  ls_header-text = 'Titulo reporte'.
  append ls_header to it_header.
  ls_header-typ = ''.
  ls_header-label = 'Sociedad'.
  ls_header-text  = '1000 SAP AG.'.
  append ls_header to it_header.

  ls_header-typ = ''.
  ls_header-label = 'Periodo'.
  ls_header-text  = '2021.06'.
  ls_header-addrow = 'X'.
  append ls_header to it_header.

  ls_header-typ = ''.
  ls_header-label = 'User'.
  ls_header-text  = 'ABC'.
  ls_header-addrow = ''.
  append ls_header to it_header.


  ls_header-typ = ''.
  ls_header-label = ''.
  ls_header-text  = ''.
  ls_header-logo = 'D001'.
  append ls_header to it_header.

  ls_colattr-colname = 'SPLD'.
  ls_colattr-stext   = 'STEXTS'.
  ls_colattr-mtext   = 'STEXTM'.
  ls_colattr-ltext   = 'STEXTL'.
  data l_color type lvc_s_colo.
  l_color-col = 3.
  ls_colattr-color   =  l_color.
  append ls_colattr to it_colattr.

  create object oalv.
  create object ohandler2.

  call method oalv->zif_salv~display_data
    exporting
      l_title    = 'Users list'
*     ls_key     =
      l_vari     = '/DEFAULT'
      lt_colattr = it_colattr
*     lt_handler = it_handler
      ohandler   = ohandler2
      lt_header  = it_header
*      l_report     = sy-repid
*      l_status     = 'SALV_TABLE_STANDARD'
    changing
      c_data     = it_usr01.

*  oalv->display_data( ).
