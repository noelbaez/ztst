class ZCL_SALV_TABLE definition
  public
  final
  create public .

public section.

  interfaces ZIF_SALV .

  aliases DISPLAY_DATA
    for ZIF_SALV~DISPLAY_DATA .
  aliases TT_COLATTR
    for ZIF_SALV~TT_COLATTR .
  aliases TT_HEADER
    for ZIF_SALV~TT_HEADER .
  aliases TY_COLATTR
    for ZIF_SALV~TY_COLATTR .
  aliases TY_HEADER
    for ZIF_SALV~TY_HEADER .
protected section.
private section.

  aliases OSALV
    for ZIF_SALV~OSALV .
  aliases BUILD_HEADER
    for ZIF_SALV~BUILD_HEADER .
  aliases SET_TEXTS
    for ZIF_SALV~SET_COLTEXTS .
ENDCLASS.



CLASS ZCL_SALV_TABLE IMPLEMENTATION.


  method zif_salv~build_header.

    data: ogrid type ref to cl_salv_form_layout_grid,
          ologo type ref to cl_salv_form_layout_logo,
          row   type i,
          l_str type string.

    create object ogrid.

    l_str = it_header[ typ = 'T' ]-text. "Titulo reporte

    ogrid->create_header_information(
      row     = 1
      column  = 1
      text    = l_str
      tooltip = l_str ).

    ogrid->add_row( ).

    data(ogrid1) = ogrid->create_grid( row    = 3 column = 1 ).

    loop at it_header into data(ls_header) where typ ne 'T'.
      add 1 to row.
      if ls_header-label <> ''.
        data(olabel) = ogrid1->create_label( row  = row column  = 1 text  = ls_header-label tooltip = ls_header-tooltip ).
        data(otext)  = ogrid1->create_text(  row  = row column  = 2 text =  ls_header-text  ).
        olabel->set_label_for( otext ).
      endif.
      if ls_header-addrow = abap_true.
        ogrid1->add_row( ).
        ADD 2 TO ROW.
      endif.
      if ls_header-logo is not initial.
        create object ologo.
        ologo->set_left_content( ogrid ).
        ologo->set_right_logo( conv #( ls_header-logo ) ).
      endif.
    endloop.

    if ologo is not initial.
      lr_content = ologo.
    else.
      lr_content = ogrid.
    endif.
  endmethod.


  method zif_salv~display_data.
    try.
        cl_salv_table=>factory(
          importing
            r_salv_table   =  osalv
          changing
            t_table        = c_data
        ).
      catch cx_salv_msg.
        exit.
    endtry.

    if lt_header is not initial.
      data: lr_content type ref to cl_salv_form_element.
      build_header(
        exporting
          it_header  = lt_header
        changing
          lr_content =  lr_content
      ).
      osalv->set_top_of_list( lr_content ).
    endif.

    if ohandler is bound.
      data(oevents) = osalv->get_event( ).
      set handler ohandler->on_user_command for oevents.
      set handler ohandler->on_double_click for oevents.
    endif.

    if ls_key is initial.
      osalv->get_layout( )->set_key( value #( report = sy-repid ) ).
    else.
      osalv->get_layout( )->set_key( ls_key ).
    endif.

    if l_vari is not initial.
      osalv->get_layout( )->set_initial_layout( l_vari ).
    endif.

    if lt_colattr is not initial.
      set_texts( lt_colattr = lt_colattr ).
    endif.

    osalv->get_layout( )->set_default( abap_true ).
    osalv->get_layout( )->set_save_restriction( if_salv_c_layout=>restrict_none ).
    osalv->get_functions( )->set_all( abap_true ).

    data(odisplay) = osalv->get_display_settings( ).
    odisplay->set_striped_pattern( cl_salv_display_settings=>true  ).
    if l_title is not initial.
      odisplay->set_list_header( l_title ).
    endif.

    if l_report is not initial and l_status is not initial.
      osalv->set_screen_status(
        exporting
          report        = l_report                 " ABAP Program: Current Master Program
          pfstatus      = l_status                 " Screens, Current GUI Status
*       set_functions = c_functions_none " ALV: Data Element for Constants
      ).
    endif.
    call method osalv->display.
  endmethod.


  method zif_salv~set_coltexts.
    data(ocols) = zif_salv~osalv->get_columns( ).
    data ocol type ref to cl_salv_column_table.

    loop at lt_colattr into data(ls_colattr) where colname <> ''.
      try.
          ocol ?= ocols->get_column( ls_colattr-colname ).
          if ls_colattr-stext <> ''. ocol->set_short_text( ls_colattr-stext ). endif.
          if ls_colattr-mtext <> ''. ocol->set_medium_text( ls_colattr-mtext ). endif.
          if ls_colattr-ltext <> ''. ocol->set_long_text( ls_colattr-ltext ). endif.
          if ls_colattr-currcol <> ''. ocol->set_currency_column( ls_colattr-currcol ). endif.
          if ls_colattr-color is not initial. ocol->set_color( ls_colattr-color ). endif.
        catch cx_salv_not_found cx_salv_data_error.
      endtry.
    endloop.
  endmethod.
ENDCLASS.
