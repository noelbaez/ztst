REPORT ztestnb_xml02.

DATA l_xml TYPE xstring.

START-OF-SELECTION.

  DATA ls_data TYPE zcl_test=>ty_demo.
  DATA lt_data TYPE zcl_test=>tt_demo.

  DO 15 TIMES.
    ls_data-name = |JOHN{ sy-index }|.
    ls_data-last_name = |MENDEZ{ sy-index }|.
    ls_data-date = sy-datum.
    APPEND ls_data TO lt_data.
  ENDDO.

  TRY.
      CALL TRANSFORMATION ztest02
            SOURCE data = lt_data
                  xmlns = 'http://www.sap.com/SAPForm/0.5'
            RESULT XML  l_xml
            .

      cl_demo_output=>display_xml( l_xml ).

    CATCH cx_st_error.
*     Your error handling comes here...
  ENDTRY.

 clear lt_data.
  TRY.
      CALL TRANSFORMATION ztest02
            SOURCE XML l_xml
            RESULT data = lt_data
             .

      cl_demo_output=>display_xml( l_xml ).

    CATCH cx_st_error.
*     Your error handling comes here...
  ENDTRY.
