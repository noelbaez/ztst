class ZCL_DOCX_UTIL definition
  public
  final
  create public .

public section.

  class-data GO_CCONTROL type ref to I_OI_CONTAINER_CONTROL .
  class-data GO_DOC_PROXY type ref to I_OI_DOCUMENT_PROXY .

  class-methods CONV_DOCX2PDF_OLE
    importing
      !I_PATH_DOCX type STRING
      !I_PATH_PDF type STRING optional
    exporting
      !E_PDF_LENGTH type I
      !E_PDF_STREAM type XSTRING .
  class-methods PRINT_DOCX_OLE
    importing
      !I_PATH_DOCX type STRING .
  class-methods PRINT_DOCX_PROXY
    importing
      !I_PATH_MIME type STRING optional
      !I_PATH_DOCX type STRING optional
      !I_COPIES type I default 1 .
  class-methods GET_DOCX
    importing
      !I_PATH_MIME type STRING
      !I_PATH_DOCX type STRING
    exporting
      !ET_DATA_TAB type SOLIX_TAB
      !E_XSTRING type XSTRING .
  class-methods MERGE_DOCX_AND_CUSTOMXML
    importing
      !I_DOCX type XSTRING
      !I_CUSTOMXML type XSTRING
    returning
      value(E_DOCX) type XSTRING
    raising
      CX_OPENXML_FORMAT
      CX_OPENXML_NOT_FOUND
      CX_MERGE_PARTS .
  class-methods FIX_DOCX_PICTURES
    changing
      !LR_DOCX type ref to CL_DOCX_DOCUMENT .
protected section.
private section.

  class-data GS_WORD type OLE2_OBJECT .
  class-data GS_DOC type OLE2_OBJECT .
  class-data GS_DOCS type OLE2_OBJECT .
  class-data GS_SELECTION type OLE2_OBJECT .
ENDCLASS.



CLASS ZCL_DOCX_UTIL IMPLEMENTATION.


  method CONV_DOCX2PDF_OLE.
*    if gs_word is initial.
    create object gs_word 'WORD.APPLICATION'.
*    endif.

    set property of gs_word 'Visible' = '0' .
    call method of gs_word 'Documents' = gs_doc.

    call method of gs_doc 'Open' = gs_doc
    exporting #1 = i_path_docx
    .

    if i_path_pdf is initial.
      split i_path_docx at '.' into data(filename) data(extension).
      data(l_path_pdf) = |{ filename }.pdf|.
    else.
      l_path_pdf = i_path_pdf.
    endif.

    "Export
*CALL METHOD OF gs_doc 'SaveAs' EXPORTING #1 = 'C:\temp\Testa.pdf' #2 = 17.
    call method of gs_doc 'ExportAsFixedFormat' exporting #1 = l_path_pdf #2 = '17'.
    call method of gs_word 'Quit'.

    if e_pdf_stream is requested.
      data it_solix type solix_tab.
      data lv_length type i.
      cl_gui_frontend_services=>gui_upload(
        exporting
          filename                = l_path_pdf
          filetype                = 'BIN'            " File Type (ASCII, Binary)
        importing
          filelength              =  lv_length                 " File Length
        changing
          data_tab                =  it_solix                " Transfer table for file contents
        exceptions
          others                  = 19
      ).
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
          with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        exit.
      endif.

      e_pdf_stream = cl_bcs_convert=>solix_to_xstring( it_solix = it_solix iv_size = lv_length ).
      e_pdf_length = lv_length.
    endif.
  endmethod.


  method fix_docx_pictures.
    types: begin of ty_replace,
             source type xstring,
             target type xstring,
           end of ty_replace.

    data: lt_patterns type table of string.
    data: lt_replace  type table of ty_replace.

    "Fix error pics en docs.
    append `{28A0092B-C50C-407E-A947-70E740481C1C}` to lt_patterns.
    append `{96DAC541-7B7A-43D3-8B79-37D633B846F1}` to lt_patterns.

    loop at lt_patterns assigning field-symbol(<fp>).
      append initial line to lt_replace assigning field-symbol(<frep>).
      try.
          <frep>-source = cl_bcs_convert=>string_to_xstring( <fp> ).
          <frep>-target = cl_bcs_convert=>string_to_xstring( |\{{ <fp> }\}| ).
        catch cx_bcs.
      endtry.
    endloop.

    try.
        data(lo_main_part) = lr_docx->get_maindocumentpart( ).
        data(lv_document) = lo_main_part->get_data( ).
        data(lv_replaces) = lines( lt_replace ).
        loop at lt_replace assigning <frep>.
          replace all occurrences of <frep>-source in lv_document with <frep>-target in byte mode.
*  replace x in lv_document with y in byte mode.
          if sy-subrc eq 0.
            data(xchanged) = abap_true.
          endif.
        endloop.
        if xchanged = abap_true.
          lo_main_part->feed_data( lv_document ).
        else.
          data(lo_header_parts) = lo_main_part->get_headerparts( ).
          data(lv_header_count) = lo_header_parts->get_count( ).
          do lv_header_count times.
            data(lo_header_part) = lo_header_parts->get_part( sy-index - 1 ).
            data(lv_header_data) = lo_header_part->get_data( ).
            loop at lt_replace assigning <frep>.
              replace all occurrences of <frep>-source in lv_header_data with <frep>-target in byte mode.
              if sy-subrc eq 0.
                xchanged = abap_true.
              endif.
            endloop.
            if xchanged = abap_true.
              lo_header_part->feed_data( lv_header_data ).
            endif.
          enddo.
        endif.
      catch cx_openxml_format cx_openxml_not_found.
    endtry.

  endmethod.


  method get_docx.
    data lt_data_tab type solix_tab.
    if i_path_docx is not initial.
      "1)
      call method cl_gui_frontend_services=>gui_upload
        exporting
          filename   = i_path_docx
          filetype   = 'BIN'
        importing
          filelength = data(lv_length)
        changing
          data_tab   = lt_data_tab.

      if et_data_tab is requested.
        et_data_tab = lt_data_tab.
      endif.
      if e_xstring is requested.
        e_xstring = cl_bcs_convert=>solix_to_xstring( it_solix = lt_data_tab iv_size = lv_length ).
      endif.

    elseif i_path_mime is not initial.
      "2)
      "Load document from repository
      cl_fxs_url_data_fetcher=>fetch(
        exporting
          iv_url          = i_path_mime
*    iv_nocache      = abap_false
        importing
          ev_content      = data(lv_stream)
          ev_content_type = data(ev_ctype)
          ev_error        = data(ev_error)
      ).

      if e_xstring is requested.
        e_xstring = lv_stream.
      endif.
      if et_data_tab is requested.
*        lv_length = xstrlen( lv_stream ).
        et_data_tab = cl_bcs_convert=>xstring_to_solix( iv_xstring = lv_stream  ).
      endif.
    endif.

  endmethod.


  method merge_docx_and_customxml.
    try.
        call method zcl_docx_form=>merge_data
          exporting
            im_formtemplate_data = i_docx
            im_customxml_data    = i_customxml
            im_delete_sdt_tags   = 'Y'
          receiving
            re_merged_data       = e_docx.
      catch cx_root into data(oerror).
        message oerror type 'I'.
    endtry.
  endmethod.


  method PRINT_DOCX_OLE.
    create object gs_word 'WORD.APPLICATION'.
    set property of gs_word 'Visible' = '0' .
    call method of gs_word 'Documents' = gs_doc.

    call method of gs_doc 'Open' = gs_doc exporting #1 = i_path_docx.

    "Print
    call method of gs_word 'ActiveDocument' = gs_doc.
    call method of gs_doc 'PrintOut' .

    call method of gs_word 'Quit'.
  endmethod.


  method print_docx_proxy.

    submit zprg_print_docx_proxy
        with p_local = i_path_docx
        with p_mime  = i_path_mime
        with p_copies = i_copies
*            with p_xlocal = abap_true
*            with p_xmime  = abap_false
            and return.

*    data go_ccontrol  type ref to i_oi_container_control.
*    data go_doc_proxy  type ref to i_oi_document_proxy.
*
**    data error type i_o_error.
*    data retcode type soi_ret_string.
*
*    if go_ccontrol is initial.
*      c_oi_container_control_creator=>get_container_control(
*        importing control = go_ccontrol
*       error = data(error)
**       retcode = data(retcode)
*       ).
*
**      c_oi_errors=>raise_message( 'E' ).
*
*      go_ccontrol->init_control(
*      exporting r3_application_name = 'Doc'
*      inplace_enabled = 'X'
**    inplace_scroll_documents = ''
*      parent =  cl_gui_container=>screen0
**    inplace_show_toolbars = ''
**    register_on_close_event = 'X'
**    register_on_custom_event = 'X'
**    importing retcode = retcode
*      ).
*    endif.
*
**    c_oi_errors=>raise_message( 'E' ).
*
*    if go_doc_proxy is initial.
*      go_ccontrol->get_document_proxy(
**    exporting document_type = 'WORD.APPLICATION'
**    exporting document_type = soi_doctype_word_document "'Word.Document.12'
*      exporting document_type = 'Word.Document.12'
*      document_format = 'OLE'
*      importing document_proxy = go_doc_proxy
**      retcode = retcode
*      ).
*    endif.
*
**    if retcode ne c_oi_errors=>ret_ok.
**      exit.
**    endif.
*
*    data: data_tab type solix_tab.
*
*    if i_path_docx is not initial.
*      "1)
*      call method cl_gui_frontend_services=>gui_upload
*        exporting
*          filename   = i_path_docx
*          filetype   = 'BIN'
*        importing
*          filelength = data(lv_length)
*        changing
*          data_tab   = data_tab.
*
*    elseif i_path_mime is not initial.
*      "2)
*      "Load document from repository
*
*      cl_fxs_url_data_fetcher=>fetch(
*        exporting
*          iv_url          = i_path_mime
**    iv_nocache      = abap_false
*        importing
*          ev_content      = data(lv_stream)
*          ev_content_type = data(ev_ctype)
*          ev_error        = data(ev_error)
*      ).
*      lv_length = xstrlen( lv_stream ).
*      data_tab = cl_bcs_convert=>xstring_to_solix( iv_xstring = lv_stream  ).
*    endif.
*
**    data doc_url(200).
**    call function 'DP_CREATE_URL'
**      exporting
**        type    = 'application'
**        subtype = 'x-oleobject'
**        size    = lv_length
**      tables
**        data    = data_tab
**      changing
**        url     = doc_url.
*
**    call function 'DP_SYNC_URLS'
**      exceptions
**        cntl_error         = 1
**        cntl_system_error  = 2
**        dp_create_error    = 3
**        data_source_error  = 4
**        dp_send_data_error = 5
**        general_error      = 6
**        others             = 7.
*
**   doc_url = p_local.
**
**    lo_doc_proxy->view_document(
**      exporting
***        document_title = ' '
**        document_url   = doc_url
***        no_flush       = ' '
**        open_inplace   = 'X'
***        startup_macro  = ''
***        user_info      =
**      importing
**        error          = data(error)
**        retcode        = data(retcode)
**    ).
*
*    go_doc_proxy->open_document_from_table(
*      exporting
*        document_size    = lv_length
*        document_table   = data_tab
**    document_title   = ' '
**    no_flush         = ' '
*    open_inplace     = 'X'
**    open_readonly    = ' '
**    protect_document = ' '
**    onsave_macro     = ' '              " OnSave Macro Name
**    startup_macro    = ''
*      importing
*        error            = error
*        retcode          = retcode
*    ).
*
**    go_doc_proxy->open_document(
**      exporting
***        document_title   = ' '
**        document_url     = doc_url
***        no_flush         = ' '
**        open_inplace     = 'X'
**        open_readonly    = 'X'
**        protect_document = 'X'
***        onsave_macro     = ' '              " OnSave Macro Name
***        startup_macro    = ''
***        user_info        =
***      importing
***        error            =
***        retcode          =
**    ).
**      exporting
**        document_size    = lv_length
**        document_table   = lt_data_tab
***    document_title   = ' '
***    no_flush         = ' '
**    open_inplace     = 'X'
***    open_readonly    = ' '
***    protect_document = ' '
***    onsave_macro     = ' '              " OnSave Macro Name
***    startup_macro    = ''
**      importing
**        error            = data(error)
**        retcode          = data(retcode)
**    ).
*
*    go_doc_proxy->print_document(
*      exporting
*        no_flush    = ' '
*        prompt_user = ' '
*      importing
*        error       = error
*        retcode     = retcode
*    ).

  endmethod.
ENDCLASS.
