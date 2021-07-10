*&---------------------------------------------------------------------*
*& Report ZREST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ztestnb_rest00.

DATA oclient TYPE REF TO if_http_client.

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-b01.
PARAMETERS: url TYPE string DEFAULT 'https://jsonplaceholder.typicode.com/users' LOWER CASE.
PARAMETERS: p_get    RADIOBUTTON GROUP gr1.
PARAMETERS: p_post   RADIOBUTTON GROUP gr1.
PARAMETERS: p_update RADIOBUTTON GROUP gr1.
PARAMETERS: p_delete RADIOBUTTON GROUP gr1.
SELECTION-SCREEN END OF BLOCK b01.

START-OF-SELECTION.

  cl_http_client=>create_by_url(
    EXPORTING
      url                =     url
*     proxy_host         =     " Logical destination (specified in function call)
*     proxy_service      =     " Port Number
*     ssl_id             =     " SSL Identity
*     sap_username       =     " ABAP System, User Logon Name
*     sap_client         =     " R/3 System, Client Number from Logon
    IMPORTING
      client             =    oclient " HTTP Client Abstraction
   EXCEPTIONS
     argument_not_found = 1
     plugin_not_active  = 2
     internal_error     = 3
     OTHERS             = 4
  ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    EXIT.
  ENDIF.

  CASE abap_true.
    WHEN p_get.    oclient->request->set_method( 'GET' ).
    WHEN p_post.   oclient->request->set_method( 'POST' ).
    WHEN p_update. oclient->request->set_method( 'PUT' ).
    WHEN p_delete. oclient->request->set_method( 'DELETE' ).
    WHEN OTHERS.
  ENDCASE.
  oclient->request->set_content_type( 'application/json' ).

  oclient->send(
*    EXPORTING
*      timeout                    = CO_TIMEOUT_DEFAULT    " Timeout of Answer Waiting Time
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3
      http_invalid_timeout       = 4
      OTHERS                     = 5
  ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  oclient->receive(
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3
      OTHERS                     = 4
  ).
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    EXIT.
  ENDIF.

  DATA(str) = oclient->response->get_cdata( ).
*get the status of the response
  CALL METHOD oclient->response->get_status
    IMPORTING
      code   = DATA(lv_http_code)
      reason = DATA(lv_http_reason).

  WRITE: / str.
