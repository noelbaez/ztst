*&---------------------------------------------------------------------*
*& Include          ZTESTNB_DATAE_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form Exports
*&---------------------------------------------------------------------*
form export_data  using it_itab f_name.
  data lv_xml type xstring.

  data(l_name) =  |{ f_name }.xml|.
  call transformation id
  source data = it_itab
  result xml lv_xml.

  clear it_itab.

  data lr_zip type ref to cl_abap_zip.
  data lv_zip_file type xstring.

  create object lr_zip.

  lr_zip->add(
    exporting
      name           = l_name
      content        = lv_xml
*     compress_level = 6                " Level of Compression
  ).

  data lt_binary_tab type solix_tab.
  lv_zip_file = lr_zip->save( ).
  lt_binary_tab = cl_bcs_convert=>xstring_to_solix( lv_zip_file ).

  data lv_fullpath type string.
  lv_fullpath = |{ p_dir }{ l_name }|.

  cl_gui_frontend_services=>gui_download(
    exporting
      filename                  =  lv_fullpath
      filetype                  = 'BIN'                " File type (ASCII, binary ...)
    changing
      data_tab                  = lt_binary_tab
    exceptions
      file_write_error          = 1                    " Cannot write to file
      no_batch                  = 2                    " Cannot execute front-end function in background
      gui_refuse_filetransfer   = 3                    " Incorrect Front End
      invalid_type              = 4                    " Invalid value for parameter FILETYPE
      no_authority              = 5                    " No Download Authorization
      unknown_error             = 6                    " Unknown error
      header_not_allowed        = 7                    " Invalid header
      separator_not_allowed     = 8                    " Invalid separator
      filesize_not_allowed      = 9                    " Invalid file size
      header_too_long           = 10                   " Header information currently restricted to 1023 bytes
      dp_error_create           = 11                   " Cannot create DataProvider
      dp_error_send             = 12                   " Error Sending Data with DataProvider
      dp_error_write            = 13                   " Error Writing Data with DataProvider
      unknown_dp_error          = 14                   " Error when calling data provider
      access_denied             = 15                   " Access to file denied.
      dp_out_of_memory          = 16                   " Not enough memory in data provider
      disk_full                 = 17                   " Storage medium is full.
      dp_timeout                = 18                   " Data provider timeout
      file_not_found            = 19                   " Could not find file
      dataprovider_exception    = 20                   " General Exception Error in DataProvider
      control_flush_error       = 21                   " Error in Control Framework
      not_supported_by_gui      = 22                   " GUI does not support this
      error_no_gui              = 23                   " GUI not available
      others                    = 24
  ).
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
      with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

endform.

form import_data  using f_fname it_itab.

  data(l_fname) = |{ f_fname }.xml|.

  data lv_filename type string.
  lv_filename = |{ p_dir }{ l_fname }|.
  data lt_binary_tab type solix_tab.

  cl_gui_frontend_services=>gui_upload(
    exporting
      filetype                = 'BIN'
      filename                = lv_filename
    importing
      filelength              =  data(lv_filelength)
    changing
      data_tab                = lt_binary_tab
    exceptions
      file_open_error         = 1                " File does not exist and cannot be opened
      file_read_error         = 2                " Error when reading file
      no_batch                = 3                " Cannot execute front-end function in background
      gui_refuse_filetransfer = 4                " Incorrect front end or error on front end
      invalid_type            = 5                " Incorrect parameter FILETYPE
      no_authority            = 6                " No upload authorization
      unknown_error           = 7                " Unknown error
      bad_data_format         = 8                " Cannot Interpret Data in File
      header_not_allowed      = 9                " Invalid header
      separator_not_allowed   = 10               " Invalid separator
      header_too_long         = 11               " Header information currently restricted to 1023 bytes
      unknown_dp_error        = 12               " Error when calling data provider
      access_denied           = 13               " Access to file denied.
      dp_out_of_memory        = 14               " Not enough memory in data provider
      disk_full               = 15               " Storage medium is full.
      dp_timeout              = 16               " Data provider timeout
      not_supported_by_gui    = 17               " GUI does not support this
      error_no_gui            = 18               " GUI not available
      others                  = 19
  ).
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
      with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

  check lt_binary_tab is not initial.

  data lv_zip_file type xstring.
  lv_zip_file = cl_bcs_convert=>solix_to_xstring(
          it_solix = lt_binary_tab
          iv_size  = lv_filelength ).

  "Decompression
  data lr_zip type ref to cl_abap_zip.
  create object lr_zip.
  lr_zip->load( lv_zip_file ).

  data lv_xml type xstring.
  lr_zip->get(
    exporting
      name                    = l_fname                 " Name (Case-Sensitive)
*      index                   = 0                " Either Name or Index
    importing
      content                 = lv_xml
    exceptions
      zip_index_error         = 1
      zip_decompression_error = 2
      others                  = 3
  ).
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
      with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.


  call transformation id
  source xml lv_xml
  result data = it_itab.

endform.
