REPORT ztestnb_xml01.

DATA:
  l_prot_version TYPE string,
  l_check_id     TYPE string,
  l_msg_id       TYPE string,
  l_msg_text     TYPE string,
  l_creator      TYPE string,

  BEGIN OF ls_arguments,
    argument TYPE string,
  END OF ls_arguments,
  lt_arguments LIKE TABLE OF ls_arguments.

DATA l_xml TYPE xstring.

START-OF-SELECTION.

  l_prot_version = '2.1'.
  l_check_id     = '123456678'.
  l_msg_id       = '003'.
  l_msg_text     = 'Test'.
  l_creator      = 'Hello'.
  ls_arguments-argument = '2.2'. APPEND ls_arguments TO lt_arguments.
  ls_arguments-argument = '2.1'. APPEND ls_arguments TO lt_arguments.

*  LT_ARGUMENTS = VALUE #( ( `SADF` ) ).
*  APPEND `2.2` TO lt_arguments.
*  APPEND `2.1` TO lt_arguments.

  TRY.
      CALL TRANSFORMATION ztest01
            SOURCE     protocol_version = l_prot_version
                       check_id         = l_check_id
                       message_id       = l_msg_id
                       message_text     = l_msg_text
                       t_arguments      = lt_arguments
                       creator          = l_creator
                       xmlns            = 'http://www.sap.com/SAPForm/0.5'
            RESULT XML  l_xml
            .

      cl_demo_output=>display_xml( l_xml ).

    CATCH cx_st_error.
*     Your error handling comes here...
  ENDTRY.

  TRY.
      CALL TRANSFORMATION ztest01
            SOURCE XML l_xml
            RESULT     protocol_version = l_prot_version
                       check_id         = l_check_id
                       message_id       = l_msg_id
                       message_text     = l_msg_text
                       t_arguments      = lt_arguments
                       creator          = l_creator.

      cl_demo_output=>display_xml( l_xml ).

    CATCH cx_st_error.
*     Your error handling comes here...
  ENDTRY.

  BREAK-POINT.
