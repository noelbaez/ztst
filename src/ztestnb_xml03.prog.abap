REPORT ztestnb_xml03.

DATA l_xml TYPE xstring.
PARAMETERS P_ROWS TYPE I DEFAULT 1.

START-OF-SELECTION.

  DATA ls_data TYPE zcl_test=>ty_demo_deep.
  DATA ls_item TYPE zcl_test=>ty_demo.

  ls_data-f1 = 'Field 1'.
  ls_data-f2 = 'Field 2'.
  ls_data-f3 = '15,555'.
  DO P_ROWS TIMES.
    ls_item-name = |JOHN{ sy-index }|.
    ls_item-last_name = |MENDEZ{ sy-index }|.
    ls_item-date = sy-datum.
    APPEND ls_item TO ls_data-items.
  ENDDO.

  SELECT BUKRS BUTXT INTO TABLE LS_DATA-companies
  FROM T001 UP TO P_ROWS ROWS.

  TRY.
      CALL TRANSFORMATION ztest03
            SOURCE data = ls_data
                  xmlns = 'http://www.sap.com/SAPForm/0.5'
            RESULT XML  l_xml
            .

      cl_demo_output=>display_xml( l_xml ).

    CATCH cx_st_error INTO DATA(oerror).
      MESSAGE oerror TYPE 'I'.
      EXIT.
*     Your error handling comes here...
  ENDTRY.

*  CLEAR ls_data.
*  TRY.
*      CALL TRANSFORMATION ztest03
*            SOURCE XML l_xml
*            RESULT data = ls_data
*             .
*
*      cl_demo_output=>display_xml( l_xml ).
*
*    CATCH cx_st_error INTO oerror.
*      MESSAGE oerror TYPE 'I'.
*      EXIT.
**     Your error handling comes here...
*  ENDTRY.
