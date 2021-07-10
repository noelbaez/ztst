*&---------------------------------------------------------------------*
*& Include          ZTESTNB_DATAE_SEL
*&---------------------------------------------------------------------*
parameters: p_export radiobutton group gr1 default 'X'.
parameters: p_import radiobutton group gr1.
selection-screen skip.
parameters: p_dir type string default 'C:\Temp\' obligatory lower case.

initialization.

at selection-screen on value-request for p_dir.
  cl_gui_frontend_services=>directory_browse(
    changing
      selected_folder      =  p_dir                 " Folder Selected By User
    exceptions
      cntl_error           = 1                " Control error
      error_no_gui         = 2                " No GUI available
      not_supported_by_gui = 3                " GUI does not support this
      others               = 4
  ).
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
      with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.
