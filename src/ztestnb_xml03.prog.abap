*&---------------------------------------------------------------------*
*& Report  ZCUSTOMXML_SAP
*&
*&---------------------------------------------------------------------*
*& Report demonstrates creation of custom xml file, then reading
*& document and using generated XSLT tramsformation to merge these files
*& Pavol Olejar 23.4.2017
*&---------------------------------------------------------------------*
REPORT zcustomxml_sap.

TYPES: BEGIN OF t_table,
         name       TYPE string,
         last_name  TYPE string,
         birth_date TYPE string,
       END OF t_table.

DATA: lt_table        TYPE TABLE OF t_table,
      ls_table        TYPE t_table,
      lv_length       TYPE i,
      lt_solix     TYPE solix_tab, "sTANDARD TABLE OF x255,
      lv_docx         TYPE xstring,
      lr_docx         TYPE REF TO cl_docx_document,
      lr_main         TYPE REF TO cl_docx_maindocumentpart,
      lr_custom       TYPE REF TO cl_oxml_customxmlpart,
      lv_table_string TYPE string,
      lv_custom_xml   TYPE xstring.

PARAMETERS: p_file type string LOWER CASE MEMORY ID mem.
START-OF-SELECTION.

** 1ST PART - PREPARE DATA FOR MAPPING
*ls_table-name = 'James'.
*ls_table-last_name = 'Bond'.
*ls_table-birth_date = '13.04.1968'.
*APPEND ls_table TO lt_table.
*
*ls_table-name = 'Pavol'.
*ls_table-last_name = 'Olejar'.
*ls_table-birth_date = '27.01.1985'.
*APPEND ls_table TO lt_table.
*
*LOOP AT lt_table INTO ls_table.
*  CONCATENATE lv_table_string
*              '<DATA>'
*              '<NAME>' ls_table-name '</NAME>'
*              '<LAST_NAME>' ls_table-last_name '</LAST_NAME>'
*              '<DATE>' ls_table-birth_date '</DATE>'
*              '</DATA>'
*         INTO lv_table_string.
*ENDLOOP.
*
*CONCATENATE '<?xml version="1.0" encoding="utf-8"?>'
*          '<data xmlns="http://www.sap.com/SAPForm/0.5">'
*          '<TABLE>'
*          lv_table_string
*          '</TABLE>'
*          '</data>'
*INTO DATA(lv_custom).
** 2ND STEP - CREATE CUSTOM XML
*CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
*  EXPORTING
*    text   = lv_custom
*  IMPORTING
*    buffer = lv_custom_xml.

*DATA LT_SOLIX TYPE SOLIX_tAB.
cl_gui_frontend_services=>gui_upload(
  EXPORTING
    filename                = 'C:\Users\jnkel\Desktop\Tests\data.xml'
    filetype                = 'BIN'    " File Type (ASCII, Binary)
*    has_field_separator     = SPACE    " Columns Separated by Tabs in Case of ASCII Upload
*    header_length           = 0    " Length of Header for Binary Data
*    read_by_line            = 'X'    " File Written Line-By-Line to the Internal Table
*    dat_mode                = SPACE    " Numeric and date fields are in DAT format in WS_DOWNLOAD
*    codepage                =     " Character Representation for Output
*    ignore_cerr             = ABAP_TRUE    " Ignore character set conversion errors?
*    replacement             = '#'    " Replacement Character for Non-Convertible Characters
*    virus_scan_profile      =     " Virus Scan Profile
  IMPORTING
    filelength              =   lv_length  " File Length
*    header                  =     " File Header in Case of Binary Upload
  CHANGING
    data_tab                =  lt_solix  " Transfer table for file contents
*    isscanperformed         = SPACE    " File already scanned
  EXCEPTIONS
    OTHERS                  = 19
).


cl_bcs_convert=>solix_to_xstring(
  EXPORTING
    it_solix   = lt_solix    " Input data
    iv_size    = lv_length    " Document size
  RECEIVING
    ev_xstring = lv_custom_xml    " Output data
).

*CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
*  EXPORTING
*    input_length = lv_length
*  IMPORTING
*    buffer       = lv_custom_xml
*  TABLES
*    binary_tab   = lt_solix.

** 2ND STEP - CREATE CUSTOM XML
*CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
*  EXPORTING
*    text   = lv_custom
*  IMPORTING
*    buffer = lv_custom_xml.

* 3RD STEP - READ WORD DOCUMENT
*clear lt_solix.
CALL METHOD cl_gui_frontend_services=>gui_upload
  EXPORTING
    filename   = p_file
    filetype   = 'BIN'
  IMPORTING
    filelength = lv_length
  CHANGING
    data_tab   = lt_solix.

CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
  EXPORTING
    input_length = lv_length
  IMPORTING
    buffer       = lv_docx
  TABLES
    binary_tab   = lt_solix.

CALL METHOD cl_docx_document=>load_document
  EXPORTING
    iv_data = lv_docx
  RECEIVING
    rr_doc  = lr_docx.

CHECK lr_docx IS BOUND.
lv_docx = lr_docx->get_package_data( ).

* 4TH STEP - MERGE CUSTOM XML FILE AND DOC
TRY.
    CALL METHOD zcl_docx_form=>merge_data
      EXPORTING
        im_formtemplate_data = lv_docx
        im_customxml_data    = lv_custom_xml
        im_delete_sdt_tags   = 'Y'
      RECEIVING
        re_merged_data       = lv_docx.
  CATCH cx_root.
ENDTRY.
* 5TH STEp - SAVE RESULT
lv_length  = xstrlen( lv_docx ).
CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
  EXPORTING
    buffer     = lv_docx
  TABLES
    binary_tab = lt_solix.

CALL METHOD cl_gui_frontend_services=>gui_download
  EXPORTING
    bin_filesize      = lv_length
    filename          = 'C:\TEMP\tablesinlogo_result.docx'
    filetype          = 'BIN'
    confirm_overwrite = ' '
  CHANGING
    data_tab          = lt_solix.
