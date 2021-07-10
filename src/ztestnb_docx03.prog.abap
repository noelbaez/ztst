*&---------------------------------------------------------------------*
*& Report ZTESTNB_DOCX03
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report ztestnb_docx03.

data save_ok type sy-ucomm.
data ok_code type sy-ucomm.
type-pools soi.
data gv_url type string.
*data ohtml type ref to cl_gui_html_viewer.
data ocont type ref to cl_gui_custom_container.
data lo_control type ref to i_oi_container_control.
data : lo_doc_proxy type ref to i_oi_document_proxy,
       lo_error     type ref to i_oi_error,
       ls_retcode   type soi_ret_string.
data : lv_error_msg type string.

parameters: p_mime  type string default 'r3mime:/sap/public/invoice1.docx' lower case.
parameters: p_local type string default 'c:\temp\Table_result.docx' lower case.

parameters: p_xmime  radiobutton group gr1 default 'X',
            p_xlocal radiobutton group gr1.

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
  "--
  if ocont is not bound.
    create object ocont
      exporting
*       parent                      = parent " Parent container
        container_name              = 'OCONT' " Name of the Screen CustCtrl Name to Link Container To
*       style                       = style " Windows Style Attributes Applied to this Container
*       lifetime                    = LIFETIME_DEFAULT " Lifetime
*       repid                       = repid " Screen to Which this Container is Linked
*       dynnr                       = dynnr " Report To Which this Container is Linked
*       no_autodef_progid_dynnr     = no_autodef_progid_dynnr " Don't Autodefined Progid and Dynnr?
      exceptions
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        others                      = 6.

    c_oi_container_control_creator=>get_container_control(
    importing control = lo_control
      retcode = ls_retcode
      ).

*    c_oi_errors=>raise_message( 'E' ).

    lo_control->init_control(
    exporting r3_application_name = 'Doc'
    inplace_enabled = 'X'
*    inplace_scroll_documents = ''
    parent =  ocont "cl_gui_container=>screen0
*    inplace_show_toolbars = ''
*    register_on_close_event = 'X'
*    register_on_custom_event = 'X'
*    importing retcode = ls_retcode
    ).

*    c_oi_errors=>raise_message( 'E' ).

    lo_control->get_document_proxy(
*    exporting document_type = 'WORD.APPLICATION'
*    exporting document_type = soi_doctype_word_document "'Word.Document.12'
    exporting document_type = 'Word.Document.12'
    document_format = 'OLE'
    importing document_proxy = lo_doc_proxy
*    retcode = ls_retcode

    ).

*    if ls_retcode ne c_oi_errors=>ret_ok.
*      exit.
*    endif.

    data: "lv_length   type i,
          lt_data_tab type solix_tab.

    case abap_true.
      when p_xlocal.
        "1)
        call method cl_gui_frontend_services=>gui_upload
          exporting
            filename   = p_local
            filetype   = 'BIN'
          importing
            filelength = data(lv_length)
          changing
            data_tab   = lt_data_tab.

      when p_xmime.
        "2)
        "Load document from repository
*      data gv_url type string.
        gv_url = p_mime.

*      data lv_stream type xstring.
        cl_fxs_url_data_fetcher=>fetch(
          exporting
            iv_url          = gv_url
*    iv_nocache      = abap_false
          importing
            ev_content      = data(lv_stream)
            ev_content_type = data(ev_ctype)
            ev_error        = data(ev_error)
        ).
        lv_length = xstrlen( lv_stream ).
        lt_data_tab = cl_bcs_convert=>xstring_to_solix( iv_xstring = lv_stream  ).
        "-----

      when others.
    endcase.

    data doc_url(200).
    call function 'DP_CREATE_URL'
      exporting
        type    = 'application'
        subtype = 'x-oleobject'
        size    = lv_length
      tables
        data    = lt_data_tab
      changing
        url     = doc_url.

*    call function 'DP_SYNC_URLS'
*      exceptions
*        cntl_error         = 1
*        cntl_system_error  = 2
*        dp_create_error    = 3
*        data_source_error  = 4
*        dp_send_data_error = 5
*        general_error      = 6
*        others             = 7.

   doc_url = p_local.
    lo_doc_proxy->view_document(
      exporting
*        document_title = ' '
        document_url   = doc_url
*        no_flush       = ' '
        open_inplace   = 'X'
*        startup_macro  = ''
*        user_info      =
      importing
        error          = data(error)
        retcode        = data(retcode)
    ).

*    lo_doc_proxy->open_document_from_table(
*      exporting
*        document_size    = lv_length
*        document_table   = lt_data_tab
**    document_title   = ' '
**    no_flush         = ' '
*    open_inplace     = 'X'
**    open_readonly    = ' '
**    protect_document = ' '
**    onsave_macro     = ' '              " OnSave Macro Name
**    startup_macro    = ''
*      importing
*        error            = data(error)
*        retcode          = data(retcode)
*    ).

*    lo_doc_proxy->print_document(
*      exporting
*        no_flush    = ' '
*        prompt_user = ' '
*      importing
*        error       = error
*        retcode     = retcode
*    ).
*
*    lo_doc_proxy->save_as(
*      exporting
*        file_name   = 'c:\temp\demo123.pdf'
**    no_flush    = ' '
**    prompt_user = ' '
**  importing
**    error       =
**    retcode     =
*    ).
*    data p_url(200).
*    lo_doc_proxy->open_document(
*    exporting document_url = p_url
**    exporting document_url = 'file://C:/Temp/invoice1.docx'
**    exporting document_url = 'r3mime:/sap/public/Template1.docx'
*    open_inplace = ''
*    open_readonly = 'X'
*    importing retcode = ls_retcode
*    ).
*
*    if ls_retcode ne c_oi_errors=>ret_ok.
*      exit.
*    endif.
  endif.

endmodule.
*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
module exit input.
  set screen 0. leave screen.
endmodule.
