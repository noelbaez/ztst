*&---------------------------------------------------------------------*
*& Report ZTESTNB_DOCX3
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report ztestnb_docx5.

data save_ok type sy-ucomm.
data ok_code type sy-ucomm.

data gv_url type string.
data ohtml type ref to cl_gui_html_viewer.
data ocont type ref to cl_gui_custom_container.

data: begin of ls_data,
        soldtoname type string,
        soldtoid   type string,
        soldto     type string,
        sold-to    type string,
      end of ls_data.

start-of-selection.

  call screen 100.

*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
module status_0100 output.
  set pf-status 'MAIN'.
  set titlebar 'MAIN' with 'Document'(001).
endmodule.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
module user_command_0100 input.

  save_ok = ok_code.
  clear ok_code.

  case save_ok.
    when 'EXIT'. set screen 0. leave screen.
    when others.
  endcase.

endmodule.
*&---------------------------------------------------------------------*
*& Module PBO_0100 OUTPUT
*&---------------------------------------------------------------------*
module pbo_0100 output.

  if ocont is initial.
    create object ocont
      exporting
        container_name = 'OCONT'
      exceptions
        others         = 6.

    create object ohtml
      exporting
        parent = ocont
      exceptions
        others = 5.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
                 with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.

    "5.Fetch
    "Load document from repository
    gv_url = 'r3mime:/sap/public/Invoice1.pdf'.

    data xdoc type xstring.
    cl_fxs_url_data_fetcher=>fetch(
      exporting
        iv_url          = gv_url
*    iv_nocache      = abap_false
      importing
        ev_content      = xdoc
        ev_content_type = data(ctype)
        ev_error        = data(oerror)
    ).

    data(lt_solix) = cl_bcs_convert=>xstring_to_solix( xdoc ).
    data  url(255).

    call method ohtml->load_data
      exporting
        type         = 'application'
        subtype      = 'pdf'
      importing
        assigned_url = url
      changing
        data_table   = lt_solix
      exceptions
        others       = 5.
    if sy-subrc <> 0.
*   Implement suitable error handling here
    endif.

    ohtml->show_data(
      exporting
*        in_place = ''
*        FRAME = 'F'
        url                    = url ).    " URL
  endif.
endmodule.
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
module exit input.
  set screen 0. leave screen.
endmodule.
