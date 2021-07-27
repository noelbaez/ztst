report ztestnb_docx2.

types: begin of t_table,
         name       type string,
         last_name  type string,
         birth_date type string,
       end of t_table.


types: begin of ty_replace,
         source type xstring,
         target type xstring,
       end of ty_replace.

data: lt_patterns type table of string.
data: lt_replace  type table of ty_replace.

data: lt_table        type table of t_table,
      ls_table        type t_table,
      lv_length       type i,
*      lt_data_tab     type standard table of x255,
      lt_data_tab     type solix_tab,
      lv_docx         type xstring,
      lr_docx         type ref to cl_docx_document,
      lv_str          type string,
      lr_main         type ref to cl_docx_maindocumentpart,
      lr_custom       type ref to cl_oxml_customxmlpart,
      lv_table_string type string,
      lv_custom_xml   type xstring.

parameters : p_file   type string default 'C:\Temp\Tableconlogo.docx' lower case obligatory.
*parameters : p_output type string default 'C:\Temp\Table_result.docx' lower case obligatory.
*parameters : p_print as checkbox default ''.
parameters : p_local radiobutton group gr1 DEFAULT 'X'.
parameters : p_mime radiobutton group gr1.

start-of-selection.
split p_file at '.' into data(field1) data(field2).
data(p_file2) = |{ field1 }2.docx|.

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

  do 15 times.

* 1ST PART - PREPARE DATA FOR MAPPING
    ls_table-name = 'James'.
    ls_table-last_name = 'Bond'.
    ls_table-birth_date = '13.04.1968'.
    append ls_table to lt_table.

    ls_table-name = 'Pavol'.
    ls_table-last_name = 'Olejar'.
    ls_table-birth_date = '27.01.1985'.
    append ls_table to lt_table.

  enddo.

  loop at lt_table into ls_table.
    concatenate lv_table_string
                '<DATA>'
                '<NAME>' ls_table-name '</NAME>'
                '<LAST_NAME>' ls_table-last_name '</LAST_NAME>'
                '<DATE>' ls_table-birth_date '</DATE>'
                '</DATA>'
           into lv_table_string.
  endloop.

  concatenate '<?xml version="1.0" encoding="utf-8"?>'
          '<data xmlns="http://www.sap.com/SAPForm/0.5">'
          '<TABLE>'
          lv_table_string
          '</TABLE>'
          '</data>'
  into data(lv_custom).

* 2ND STEP - CREATE CUSTOM XML
  try.
      lv_custom_xml = cl_bcs_convert=>string_to_xstring( lv_custom ).
    catch cx_bcs. " BCS: General Exceptions
  endtry.

*  call function 'SCMS_STRING_TO_XSTRING'
*    exporting
*      text   = lv_custom
*    importing
*      buffer = lv_custom_xml.

* 3RD STEP - READ WORD DOCUMENT
  case abap_true.
    when p_local.
      call method cl_gui_frontend_services=>gui_upload
        exporting
          filename   = p_file
          filetype   = 'BIN'
        importing
          filelength = lv_length
        changing
          data_tab   = lt_data_tab.

      cl_bcs_convert=>solix_to_xstring(
        exporting
          it_solix   =  lt_data_tab
          iv_size    =  lv_length
        receiving
          ev_xstring = lv_docx
      ).

    when p_mime.
      "Load document from repository
      data gv_url type string.
      gv_url = 'r3mime:/sap/public/Tableconlogo.docx'.

      data docx type xstring.
      cl_fxs_url_data_fetcher=>fetch(
        exporting
          iv_url          = gv_url
*    iv_nocache      = abap_false
        importing
          ev_content      = lv_docx
          ev_content_type = data(ev_ctype)
          ev_error        = data(ev_error)
      ).

    when others.
  endcase.

*  call function 'SCMS_BINARY_TO_XSTRING'
*    exporting
*      input_length = lv_length
*    importing
*      buffer       = lv_docx
*    tables
*      binary_tab   = lt_data_tab.

  call method cl_docx_document=>load_document
    exporting
      iv_data = lv_docx
    receiving
      rr_doc  = lr_docx.

  check lr_docx is bound.

  "Change document. Caso error por imagenes
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

  lv_docx = lr_docx->get_package_data( ).

* 4TH STEP - MERGE CUSTOM XML FILE AND DOC
  try.
      call method zcl_docx_form=>merge_data
*    CALL METHOD zcl_docx_form=>merge_data
        exporting
          im_formtemplate_data = lv_docx
          im_customxml_data    = lv_custom_xml
          im_delete_sdt_tags   = 'Y'
        receiving
          re_merged_data       = lv_docx.

    catch cx_root into data(oerror).
      message oerror type 'I'.
      exit.
  endtry.

* 5TH STEp - SAVE RESULT
  lv_length  = xstrlen( lv_docx ).
  call function 'SCMS_XSTRING_TO_BINARY'
    exporting
      buffer     = lv_docx
    tables
      binary_tab = lt_data_tab.

  call method cl_gui_frontend_services=>gui_download
    exporting
      bin_filesize      = lv_length
      filename          = p_file2
      filetype          = 'BIN'
      confirm_overwrite = ''
    changing
      data_tab          = lt_data_tab.

*  if p_print = abap_true.
*    try.
*
*        cl_docx_form=>print_docx(
*          exporting
*            im_docx_data = lv_docx
*            im_printer   = 'ZLOC'
**        im_copies    =                  " Spool: Output Device
**        im_name      = 'DOCx'           " Number of copies
**        im_suffix1   =                  " Spool request: Name
**        im_suffix2   =                  " Spool request: Suffix 1
**        im_newid     =                  " Spool request: Suffix 2
**        im_immed     = space            " Print immediately or later
**        im_delete    = space            " Print immediately or later
**        im_final     = space            " Delete spool request automatically
**        im_lifetime  = '8'              " Spool request completed
**        im_title     =                  " Title of a spool request
**        im_receiver  =                  " Title of a spool request
**        im_division  =                  " Spool: Recipient of spool request
**        im_auth      =                  " Department
**        im_coverpage =                  " Value for authorization check
**      importing
**        ex_spoolid   =                  " Spool request number
**        ex_numpages  =                  " Natural number
**        ex_errstring =
*        ).
*      catch cx_docx_print_error into oerror. " print error
*        message oerror type 'I'.
*    endtry.
*  endif.
