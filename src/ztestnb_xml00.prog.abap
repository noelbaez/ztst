REPORT ztestnb_xml1.

TYPES: BEGIN OF ty_data,
         name      TYPE string,
         last_name TYPE string,
         date      TYPE string,
       END OF ty_data,
       tt_data TYPE TABLE OF ty_data.

DATA: it_data TYPE tt_data.

START-OF-SELECTION.

  DATA ls_data TYPE ty_data.

  DO 5 TIMES.
    ls_data-name = |John { sy-index }|.
    ls_data-last_name = |Mendez { sy-index }|.
    ls_data-date = sy-datum.
    APPEND ls_data TO it_data.
  ENDDO.

*  cl_demo_output=>display( it_data ).

  DATA l_xml TYPE xstring.
  CALL TRANSFORMATION id
  SOURCE data = it_data
  RESULT XML l_xml.

  cl_demo_output=>display_xml( l_xml ).

  BREAK-POINT.
