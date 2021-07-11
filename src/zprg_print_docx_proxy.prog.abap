report zprg_print_docx_proxy.

data save_ok type sy-ucomm.
data ok_code type sy-ucomm.
data error   type ref to i_oi_error.
data retcode type soi_ret_string.

data ocont type ref to cl_gui_custom_container.
data lo_control type ref to i_oi_container_control.
data : lo_doc_proxy type ref to i_oi_document_proxy,
       lo_error     type ref to i_oi_error,
       ls_retcode   type soi_ret_string.
*data : lv_error_msg type string.

parameters: p_mime  type string default 'r3mime:/sap/public/invoice1.docx' lower case.
parameters: p_local type string default 'c:\temp\Table_result.docx' lower case.
parameters: p_copies type i default 1.

start-of-selection.

  if lo_control is not bound.
    c_oi_container_control_creator=>get_container_control(
    importing control = lo_control
*      retcode = ls_retcode
      ).

*    c_oi_errors=>raise_message( 'E' ).

    lo_control->init_control(
    exporting r3_application_name = 'Doc'
    inplace_enabled = 'X'
*    inplace_scroll_documents = ''
    parent = cl_gui_container=>screen0
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

   "Load file
    data: lt_data_tab type solix_tab.

    if p_local is not initial.
      "1)
      call method cl_gui_frontend_services=>gui_upload
        exporting
          filename   = p_local
          filetype   = 'BIN'
        importing
          filelength = data(lv_length)
        changing
          data_tab   = lt_data_tab.

    elseif p_mime is not initial.
      "2)
      "Load document from repository
      cl_fxs_url_data_fetcher=>fetch(
        exporting
          iv_url          = p_mime
*    iv_nocache      = abap_false
        importing
          ev_content      = data(lv_stream)
          ev_content_type = data(ev_ctype)
          ev_error        = data(ev_error)
      ).
      lv_length = xstrlen( lv_stream ).
      lt_data_tab = cl_bcs_convert=>xstring_to_solix( iv_xstring = lv_stream  ).
    endif.

    "Open document (no visible)
    lo_doc_proxy->open_document_from_table(
      exporting
        document_size    = lv_length
        document_table   = lt_data_tab
*    document_title   = ' '
*    no_flush         = ' '
    open_inplace     = 'X'
*    open_readonly    = ' '
*    protect_document = ' '
*    onsave_macro     = ' '              " OnSave Macro Name
*    startup_macro    = ''
      importing
        error            = error
        retcode          = retcode
    ).

    "Print
    do p_copies times.
      lo_doc_proxy->print_document(
        exporting
          no_flush    = ' '
          prompt_user = ' '
        importing
          error       = error
          retcode     = retcode
      ).
    enddo.
*
  endif.
