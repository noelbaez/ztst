**
**&---------------------------------------------------------------------*
**& Report  ZTEST_RIC
**&
**&---------------------------------------------------------------------*
**&
**&
**&---------------------------------------------------------------------*
REPORT ztest_ric.

PARAMETERS:
  pa_file  TYPE string OBLIGATORY.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_file.
  PERFORM ayuda_file.

START-OF-SELECTION.

  DATA:
     gt_file_content TYPE solix_tab,
     gv_extension    TYPE sdbad-funct,
     gv_filename     TYPE sdbah-actid,
     gv_file_length  TYPE int4,
     go_custom_cont  TYPE REF TO cl_gui_custom_container,
     go_html_viewer  TYPE REF TO cl_gui_html_viewer.

START-OF-SELECTION.
  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = pa_file
      filetype                = 'BIN'
    IMPORTING
      filelength              = gv_file_length
    CHANGING
      data_tab                = gt_file_content
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      not_supported_by_gui    = 17
      error_no_gui            = 18
      OTHERS                  = 19.
  IF sy-subrc NE 0.
    MESSAGE 'Error upload' TYPE 'E'.
  ENDIF.

  DATA:

   lv_long_filename TYPE dbmsgora-filename.

  lv_long_filename = pa_file.
  CALL FUNCTION 'SPLIT_FILENAME'
    EXPORTING
      long_filename  = lv_long_filename
    IMPORTING
      pure_filename  = gv_filename
      pure_extension = gv_extension.

  CALL SCREEN 2000  STARTING AT 5 5.



*&---------------------------------------------------------------------*
*&      Form  P_AYUDA_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ayuda_file.

  DATA: f_titulo TYPE string.
  DATA: fs_filetable TYPE file_table,
        ft_filetable TYPE STANDARD TABLE OF file_table.
  DATA: f_rc TYPE i.

  f_titulo = text-001.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title      = f_titulo
      default_extension = '*.*'
      initial_directory = 'U:\'
    CHANGING
      file_table        = ft_filetable
      rc                = f_rc.

  READ TABLE ft_filetable INDEX 1 INTO fs_filetable.
  IF sy-subrc EQ 0.
    pa_file = fs_filetable-filename.
  ENDIF.

ENDFORM.                    " P_AYUDA_FILE

*&---------------------------------------------------------------------*
*&      Module  STATUS_2000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_2000 OUTPUT.
  SET PF-STATUS 'POPUP'.
*  SET TITLEBAR 'xxx'.

  PERFORM visualizar_doc.

ENDMODULE.                 " STATUS_2000  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2000 INPUT.

  IF sy-ucomm EQ 'OK'.

    IF go_html_viewer IS NOT INITIAL.
      CALL METHOD go_html_viewer->free
        EXCEPTIONS
          cntl_error        = 1
          cntl_system_error = 2
          OTHERS            = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.

    IF go_custom_cont IS NOT INITIAL.
      CALL METHOD go_custom_cont->free
        EXCEPTIONS
          cntl_error        = 1
          cntl_system_error = 2
          OTHERS            = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.

    FREE: go_custom_cont, go_html_viewer.

    LEAVE TO SCREEN 0.
  ENDIF.

ENDMODULE.                 " USER_COMMAND_2000  INPUT

*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_LS_SELFIELD  text
*----------------------------------------------------------------------*
FORM visualizar_doc.

  CASE gv_extension.
    WHEN 'PDF'
      OR 'JPG'
      OR 'PNG'
      OR 'TXT'
      OR 'CSV'.

      PERFORM html_viewer.

    WHEN 'DOCX' OR 'DOC'
      OR 'XLSX' OR 'XLS'
      OR 'PPTX' OR 'PPT'.

      PERFORM ole2_viewer.
*      PERFORM ole2_viewer_2.

    WHEN OTHERS.
      MESSAGE text-001 TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
  ENDCASE.


ENDFORM.                    " VISUALIZAR_DOC



*&---------------------------------------------------------------------*
*&      Form  HTML_VIEWER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_FILE_LENGHT  text
*      -->P_LV_EXTENSION  text
*      -->P_LT_FILE_CONTENT  text
*----------------------------------------------------------------------*
FORM html_viewer.


  DATA:
     lv_url     TYPE w3url,
     lv_type    TYPE text10,
     lv_subtype TYPE text10.

  CASE gv_extension.
    WHEN 'PDF'.

      lv_type    = 'BIN'.
      lv_subtype = 'PDF'.

    WHEN 'JPG'.

      lv_type    = 'BIN'.
      lv_subtype = 'JPG'.

    WHEN 'PNG'.

      lv_type    = 'BIN'.
      lv_subtype = 'PNG'.

    WHEN 'TXT' OR 'CSV'.

      lv_type    = 'ASC'.
      lv_subtype = 'TXT'.

    WHEN 'OTHERS'.
      MESSAGE 'Extensión no soportada' TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
  ENDCASE.


  CHECK go_custom_cont IS INITIAL.

  CREATE OBJECT go_custom_cont
    EXPORTING
*      parent                      =
      container_name              = 'CUSTOM_CONT'
*      style                       =
*      lifetime                    = lifetime_default
      repid                       = sy-repid
      dynnr                       = sy-dynnr
*      no_autodef_progid_dynnr     =
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CREATE OBJECT go_html_viewer
    EXPORTING
*      shellstyle         =
      parent             = go_custom_cont
*      lifetime           = LIFETIME_DEFAULT
*      saphtmlp           =
*      uiflag             =
*      end_session_with_browser = 0
*      name               =
*      saphttp            =
*      query_table_disabled = ''
    EXCEPTIONS
      cntl_error         = 1
      cntl_install_error = 2
      dp_install_error   = 3
      dp_error           = 4
      OTHERS             = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  CALL METHOD go_html_viewer->load_data
    EXPORTING
*      url                    =
        type                   = lv_type
        subtype                = lv_subtype
        size                   = gv_file_length
*      encoding               =
*      charset                =
*      i_tidyt                =
*      language               =
*      needfiltering          = 0
    IMPORTING
      assigned_url           = lv_url
    CHANGING
      data_table             = gt_file_content
*      iscontentchanged       =
    EXCEPTIONS
      dp_invalid_parameter   = 1
      dp_error_general       = 2
      cntl_error             = 3
      html_syntax_notcorrect = 4
      OTHERS                 = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL METHOD go_html_viewer->show_url
    EXPORTING
      url                    = lv_url
*      frame                  =
      in_place               = ' X'
    EXCEPTIONS
      cntl_error             = 1
      cnht_error_not_allowed = 2
      cnht_error_parameter   = 3
      dp_error_general       = 4
      OTHERS                 = 5
          .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " HTML_VIEWER


*&---------------------------------------------------------------------*
*&      Form  OLE2_VIEWER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_FILE_LENGHT  text
*      -->P_LV_EXTENSION  text
*      -->P_LT_FILE_CONTENT  text
*----------------------------------------------------------------------*
FORM ole2_viewer.

  DATA :
    lv_app_name  TYPE char3,
    lv_doc_type  TYPE text20,
    ole          TYPE REF TO i_oi_container_control,
    lo_doc_proxy TYPE REF TO i_oi_document_proxy,
    lo_error     TYPE REF TO i_oi_error,
    ls_retcode   TYPE soi_ret_string.

  CASE gv_extension.
    WHEN 'DOC' OR 'DOCX'.

      lv_app_name = 'Doc'.
      lv_doc_type = 'Word.Document.12'.

    WHEN 'XLS' OR 'XLSX' OR 'CSV'.

      lv_app_name = 'Xls'.
      lv_doc_type = 'Excel.Sheet.12'.

    WHEN 'PPT' OR 'PPTX'.

      lv_doc_type = 'PowerPoint.Slide.12'.

    WHEN 'OTHERS'.
      MESSAGE 'Extensión no soportada' TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
  ENDCASE.

  CREATE OBJECT go_custom_cont
    EXPORTING
      container_name              = 'CUSTOM_CONT'
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.

  c_oi_container_control_creator=>get_container_control(
  IMPORTING
    control = ole
    retcode = ls_retcode ).

  c_oi_errors=>raise_message( 'E' ).

  ole->init_control(
 EXPORTING r3_application_name = lv_app_name
  inplace_enabled = 'X'
  inplace_scroll_documents = 'X'
  parent = go_custom_cont
  register_on_close_event = 'X'
  register_on_custom_event = 'X'
 IMPORTING retcode = ls_retcode  ).

  c_oi_errors=>raise_message( 'E' ).

  ole->get_document_proxy(
  EXPORTING document_type = lv_doc_type
   document_format = 'OLE'
  IMPORTING document_proxy = lo_doc_proxy
   retcode = ls_retcode ).

  IF ls_retcode NE c_oi_errors=>ret_ok.
    EXIT.
  ENDIF.

* This is NOT WORKITNG, returns DOCUMENT_NO_VIEW_DATA_AVAILA
*  DATA:
*    lv_error    TYPE REF TO i_oi_error,
*    lv_retcode  TYPE  soi_ret_string.
*  CALL METHOD lo_doc_proxy->view_document_from_table
*    EXPORTING
*      document_size  = gv_file_length
*      document_table = gt_file_content
*      document_title = gv_filename
**      no_flush       = 'X'
*      open_inplace   = 'X'
**      startup_macro  = ''
*    IMPORTING
*      error          = lv_error
*      retcode        = lv_retcode.

* This is working
  CALL METHOD lo_doc_proxy->open_document_from_table
    EXPORTING
      document_size    = gv_file_length
      document_table   = gt_file_content
      document_title   = gv_filename
      open_inplace     = 'X'
      open_readonly    = 'X'
      protect_document = 'X'.

*--------------------------------------------------------------------*
* Other attempts
*--------------------------------------------------------------------*
*  DATA:
*   lv_url TYPE char255,
*   document_viewer  TYPE REF TO i_oi_document_viewer.
*
*  CALL METHOD c_oi_container_control_creator=>get_document_viewer
*    IMPORTING
*      viewer = document_viewer.
*
*  CALL METHOD document_viewer->init_viewer
*    EXPORTING
*      parent = go_custom_cont.
*
*  CALL FUNCTION 'DP_CREATE_URL'
*    EXPORTING
*      type    = 'application'
*      subtype = 'x-oleobject'
*      size    = gv_file_lenght
*    TABLES
*      data    = gt_file_content
*    CHANGING
*      url     = lv_url.
*
*  CALL METHOD document_viewer->view_document_from_url
*    EXPORTING
*      document_url = lv_url
*      show_inplace = 'X'.
*
** CALL METHOD  document_viewer->view_document_from_table
**   EXPORTING
**     show_inplace         = 'X'
**     type                 = 'application'
**     subtype              = 'x-oleobject'
**     size                 =  gv_file_lenght
**   changing
**     document_table       = gt_file_content
**   EXCEPTIONS
**     dp_invalid_parameter = 1
**     dp_error_general     = 2
**     cntl_error           = 3
**     not_initialized      = 4
**     invalid_parameter    = 5
**     others               = 6
**         .
** IF sy-subrc <> 0.
***  MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
***             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
** ENDIF.


ENDFORM.                    " OLE2_VIEWER
