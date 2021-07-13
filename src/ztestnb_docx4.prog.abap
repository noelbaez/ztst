*&---------------------------------------------------------------------*
*& Report ZTESTNB_DOCX4
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report ztestnb_docx4.
data: x type xstring value '7B32384130303932422D433530432D343037452D413934372D3730453734303438314331437D',
      y type xstring value '7B7B32384130303932422D433530432D343037452D413934372D3730453734303438314331437D7D'.

parameters p_file type string lower case default 'c:\temp\blank.docx'.

start-of-selection.
  data: lv_content  type xstring,
        lo_document type ref to cl_docx_document.

  perform get_doc_binary using p_file changing lv_content.

  lo_document = cl_docx_document=>load_document( lv_content ).
  check lo_document is not initial.
  data(lo_core_part) = lo_document->get_corepropertiespart( ).
  data(lv_core_data) = lo_core_part->get_data( ).
  data(lo_main_part) = lo_document->get_maindocumentpart( ).

  data(lo_main_data) = lo_main_part->get_data( ). "Get main Document data
  replace x in lo_main_data with y in byte mode.
  lo_main_part->feed_data( lo_main_data ). "set main Document data

  data(lo_image_parts) = lo_main_part->get_imageparts( ).
  data(lv_image_count) = lo_image_parts->get_count( ).
  do lv_image_count times.
    data(lo_image_part) = lo_image_parts->get_part( sy-index - 1 ).
    data(lv_image_data) = lo_image_part->get_data( ).
  enddo.
  data(lo_header_parts) = lo_main_part->get_headerparts( ).
  data(lv_header_count) = lo_header_parts->get_count( ).
  do lv_header_count times.
    data(lo_header_part) = lo_header_parts->get_part( sy-index - 1 ).
    data(lv_header_data) = lo_header_part->get_data( ).
  enddo.

  data(modified_doc) = lo_document->get_package_data( ).
  PERFORM save_doc_binary using p_file modified_doc.
*&---------------------------------------------------------------------*
*& Form GET_DOC_BINARY
*&---------------------------------------------------------------------*
form get_doc_binary  using    p_file
                     changing lv_docx.

  data: lv_length type i,
*        lv_docx         type xstring,
       lt_data_tab     type standard table of x255.

  call method cl_gui_frontend_services=>gui_upload
    exporting
      filename   = p_file
      filetype   = 'BIN'
    importing
      filelength = lv_length
    changing
      data_tab   = lt_data_tab.

  call function 'SCMS_BINARY_TO_XSTRING'
    exporting
      input_length = lv_length
    importing
      buffer       = lv_docx
    tables
      binary_tab   = lt_data_tab.
endform.
*&---------------------------------------------------------------------*
*& Form SAVE_DOC_BINARY
*&---------------------------------------------------------------------*
form save_doc_binary  using    p_file
                               p_modified_doc.
* 5TH STEp - SAVE RESULT
  data(lv_length)  = xstrlen( p_modified_doc ).
  data lt_data_tab     type standard table of x255.

  call function 'SCMS_XSTRING_TO_BINARY'
    exporting
      buffer     = p_modified_doc
    tables
      binary_tab = lt_data_tab.

  call method cl_gui_frontend_services=>gui_download
    exporting
      bin_filesize      = lv_length
      filename          = 'C:\temp\Table_result2.docx'
      filetype          = 'BIN'
      confirm_overwrite = ''
    changing
      data_tab          = lt_data_tab.
endform.
