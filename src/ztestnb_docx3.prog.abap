*&---------------------------------------------------------------------*
*& Report ZTESTNB_DOCX3
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report ztestnb_docx3.

data gv_url type string.
data: begin of ls_data,
        soldtoname type string,
        soldtoid   type string,
        soldto     type string,
        sold-to     type string,
      end of ls_data.

"5.Fetch
"Load document from repository
gv_url = 'r3mime:/sap/public/Template1.docx'.

data docx type xstring.

cl_fxs_url_data_fetcher=>fetch(
  exporting
    iv_url          = gv_url
*    iv_nocache      = abap_false
  importing
    ev_content      = docx
    ev_content_type = data(ctype)
    ev_error        = data(oerror)
).

"6. Generate custom XML
ls_data-soldtoname = 'JOHN DEMO'.
ls_data-soldtoid = '123'.
ls_data-soldto   = 'MARY JAMES'.
ls_data-sold-to   = 'MARY JAMES 2'.

data texts type xstring.
data texts2 type string.

try.
    call transformation zxml_gen
    source ofrc = ls_data
    result xml texts.


    call transformation zxml_gen
    source ofrc = ls_data
    result xml texts2.

  catch cx_root.

endtry.

"7 CREATE stylesheet
try.
    cl_xsl_docx=>generate_transform(
      exporting
        im_formtemplate_data = docx
        im_type              = 'W'
        im_delete_sdt_tags   = 'N'              " Y:Delete ContentControl; N:Keep them; R:Make them read-only.
      receiving
        re_xslt_tab          = data(lt_xslttab)                 " O2: Oxygen Page Table
    ).
  catch cx_root.
*  catch cx_transformation_error. " General Error When Performing CALL TRANSFORMATION
*  catch cx_merge_parts.          " Merge exceptions of parts of the package
endtry.

"8 Merge data

"Create name or transformation
data ls_xslattr type  o2xsltattr.
clear ls_xslattr-xsltdesc.
try.
    ls_xslattr-xsltdesc = cl_system_uuid=>create_uuid_c26_static( ).

  catch cx_root.
endtry.
concatenate 'XSLT' ls_xslattr-xsltdesc into ls_xslattr-xsltdesc.

ls_xslattr-devclass = '$TMP'.
ls_xslattr-author = sy-uname.

call function 'XSLT_MAINTENANCE'
  exporting
    i_operation               = 'CREA_ACT'
    i_xslt_attributes         = ls_xslattr
    i_xslt_source             = lt_xslttab
*   I_TRANSPORT_REQUEST       =
    i_gen_flag                = abap_true
    i_suppress_corr_insert    = abap_true
    i_suppress_tree_placement = abap_true
*   I_SUPPRESS_LOAD_GEN       =
*   I_PREPARE_WORKING_AREA    = ABAP_TRUE
* IMPORTING
*   E_STATE                   =
*   E_XSLT_ATTRIBUTES         =
*   E_XSLT_SOURCE             =
*   E_ERROR_LIST              =
*   E_TRANSPORT_REQUEST       =
* CHANGING
*   C_CHECKLIST               =
 EXCEPTIONS
*   INVALID_NAME              = 1
*   NOT_EXISTING              = 2
*   LOCK_FAILURE              = 3
*   PERMISSION_FAILURE        = 4
*   ERROR_OCCURED             = 5
*   SYNTAX_ERRORS             = 6
*   CANCELLED                 = 7
*   DATA_MISSING              = 8
*   VERSION_NOT_FOUND         = 9
   OTHERS                    = 10
  .
if sy-subrc <> 0.
* Implement suitable error handling here
endif.

"Generate final doc
data xslt_name type string.
xslt_name = ls_xslattr-xsltdesc.

try.

    cl_xsl_docx=>generate_docx(
      exporting
        im_xslt_name         = xslt_name
        im_customxml_data    = texts
*    im_language          =                  " Language Key
*    im_country           =                  " Country Key
        im_formtemplate_data = docx
      receiving
        re_docx              = data(lv_docx)
    ).
  catch cx_root.

endtry.

  data(lv_size) = xstrlen( lv_docx ).
data(lt_binary) = cl_bcs_convert=>xstring_to_solix( lv_docx ).
data lv_filename type string.
data lv_path type string.
data lv_fullpath type string.

cl_gui_frontend_services=>file_save_dialog(
*  exporting
*    window_title              =                  " Window Title
*    default_extension         =                  " Default Extension
*    default_file_name         =                  " Default File Name
*    with_encoding             =
*    file_filter               =                  " File Type Filter Table
*    initial_directory         =                  " Initial Directory
*    prompt_on_overwrite       = 'X'
  changing
    filename                  = lv_filename
    path                      = lv_path                  " Path to File
    fullpath                  = lv_fullpath                 " Path + File Name
*    user_action               =                  " User Action (C Class Const ACTION_OK, ACTION_OVERWRITE etc)
*    file_encoding             =
*  exceptions
*    cntl_error                = 1                " Control error
*    error_no_gui              = 2                " No GUI available
*    not_supported_by_gui      = 3                " GUI does not support this
*    invalid_default_file_name = 4                " Invalid default file name
*    others                    = 5
).
if sy-subrc <> 0.
* message id sy-msgid type sy-msgty number sy-msgno
*   with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
endif.

check lv_fullpath is not initial.
cl_gui_frontend_services=>gui_download(
  exporting
    bin_filesize              = lv_size                     " File length for binary files
    filename                  =  lv_fullpath                    " Name of file
    filetype                  = 'BIN'                " File type (ASCII, binary ...)
*    append                    = space                " Character Field of Length 1
*    write_field_separator     = space                " Separate Columns by Tabs in Case of ASCII Download
*    header                    = '00'                 " Byte Chain Written to Beginning of File in Binary Mode
*    trunc_trailing_blanks     = space                " Do not Write Blank at the End of Char Fields
*    write_lf                  = 'X'                  " Insert CR/LF at End of Line in Case of Char Download
*    col_select                = space                " Copy Only Selected Columns of the Table
*    col_select_mask           = space                " Vector Containing an 'X' for the Column To Be Copied
*    dat_mode                  = space                " Numeric and date fields are in DAT format in WS_DOWNLOAD
*    confirm_overwrite         = space                " Overwrite File Only After Confirmation
*    no_auth_check             = space                " Switch off Check for Access Rights
*    codepage                  =                      " Character Representation for Output
*    ignore_cerr               = abap_true            " Ignore character set conversion errors?
*    replacement               = '#'                  " Replacement Character for Non-Convertible Characters
*    write_bom                 = space                " If set, writes a Unicode byte order mark
*    trunc_trailing_blanks_eol = 'X'                  " Remove Trailing Blanks in Last Column
*    wk1_n_format              = space
*    wk1_n_size                = space
*    wk1_t_format              = space
*    wk1_t_size                = space
*    show_transfer_status      = 'X'                  " Enables suppression of transfer status message
*    fieldnames                =                      " Table Field Names
*    write_lf_after_last_line  = 'X'                  " Writes a CR/LF after final data record
*    virus_scan_profile        = '/SCET/GUI_DOWNLOAD' " Virus Scan Profile
*  importing
*    filelength                =                      " Number of bytes transferred
  changing
    data_tab                  =  lt_binary                    " Transfer table
*  exceptions
*    file_write_error          = 1                    " Cannot write to file
*    no_batch                  = 2                    " Cannot execute front-end function in background
*    gui_refuse_filetransfer   = 3                    " Incorrect Front End
*    invalid_type              = 4                    " Invalid value for parameter FILETYPE
*    no_authority              = 5                    " No Download Authorization
*    unknown_error             = 6                    " Unknown error
*    header_not_allowed        = 7                    " Invalid header
*    separator_not_allowed     = 8                    " Invalid separator
*    filesize_not_allowed      = 9                    " Invalid file size
*    header_too_long           = 10                   " Header information currently restricted to 1023 bytes
*    dp_error_create           = 11                   " Cannot create DataProvider
*    dp_error_send             = 12                   " Error Sending Data with DataProvider
*    dp_error_write            = 13                   " Error Writing Data with DataProvider
*    unknown_dp_error          = 14                   " Error when calling data provider
*    access_denied             = 15                   " Access to file denied.
*    dp_out_of_memory          = 16                   " Not enough memory in data provider
*    disk_full                 = 17                   " Storage medium is full.
*    dp_timeout                = 18                   " Data provider timeout
*    file_not_found            = 19                   " Could not find file
*    dataprovider_exception    = 20                   " General Exception Error in DataProvider
*    control_flush_error       = 21                   " Error in Control Framework
*    not_supported_by_gui      = 22                   " GUI does not support this
*    error_no_gui              = 23                   " GUI not available
*    others                    = 24
).
if sy-subrc <> 0.
* message id sy-msgid type sy-msgty number sy-msgno
*   with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
endif.
*catch cx_transformation_error. " General Error When Performing CALL TRANSFORMATION
*catch cx_openxml_not_found.    " Part not found
*catch cx_openxml_format.       " Packaging Error - Invalid Content
