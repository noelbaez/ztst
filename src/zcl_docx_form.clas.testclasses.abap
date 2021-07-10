CLASS cl_tst_docx_form DEFINITION DEFERRED.

CLASS zcl_docx_form DEFINITION LOCAL FRIENDS cl_tst_docx_form.

CLASS cl_tst_docx_form DEFINITION FOR TESTING
  DURATION MEDIUM
  RISK LEVEL HARMLESS
.                                                       "#EC CLAS_FINAL
*?<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
*?<asx:values>
*?<TESTCLASS_OPTIONS>
*?<TEST_CLASS>cl_Tst_Docx_Form
*?</TEST_CLASS>
*?<TEST_MEMBER>f_Cut
*?</TEST_MEMBER>
*?<OBJECT_UNDER_TEST>CL_DOCX_FORM
*?</OBJECT_UNDER_TEST>
*?<OBJECT_IS_LOCAL/>
*?<GENERATE_FIXTURE/>
*?<GENERATE_CLASS_FIXTURE/>
*?<GENERATE_INVOCATION/>
*?<GENERATE_ASSERT_EQUAL/>
*?</TESTCLASS_OPTIONS>
*?</asx:values>
*?</asx:abap>
  PRIVATE SECTION.
* ================
    DATA:
      f_cut TYPE REF TO cl_docx_form.                       "#EC NEEDED

    METHODS: contains_customxml FOR TESTING.
    METHODS: create_form FOR TESTING.
    METHODS: create_pdfpreview FOR TESTING.
    METHODS: extract_texts FOR TESTING.
    METHODS: get_xsd_file FOR TESTING.
    METHODS: insert_xsd_file FOR TESTING.
    METHODS: merge_data FOR TESTING.
    METHODS: merge_texts FOR TESTING.
    METHODS: print_docx FOR TESTING.
    METHODS: replace_xml_data_file FOR TESTING.
    METHODS: update_translation FOR TESTING.
    METHODS: update_translation_tags FOR TESTING.
    METHODS: re_merge_document FOR TESTING.
ENDCLASS.       "cl_Tst_Docx_Form


CLASS cl_tst_docx_form IMPLEMENTATION.
* ======================================


  METHOD contains_customxml.
* ==========================


  ENDMETHOD.       "contains_Customxml


  METHOD create_form.
* ===================


  ENDMETHOD.       "create_Form


  METHOD create_pdfpreview.
* =========================


  ENDMETHOD.       "create_Pdfpreview


  METHOD extract_texts.
* =====================
    DATA: docx                    TYPE xstring.

* MIME url strings
    DATA: gv_url          TYPE string,
          gv_content_type TYPE string,                      "#EC NEEDED
          gv_error        TYPE i.

    gv_url = 'r3mime:/sap/bc/bsp/sap/DOCX_TEST_FORMS/INVOICE_EN.docx'.

    cl_fxs_url_data_fetcher=>fetch( EXPORTING iv_url = gv_url
    IMPORTING ev_content = docx
      ev_content_type = gv_content_type
      ev_error = gv_error ).
    IF gv_error <> 0.
      cl_aunit_assert=>fail( msg = 'Test case INVOICE_EN.docx not found' level = cl_aunit_assert=>tolerable quit = 1 ).
    ENDIF.

    TRY.
        cl_docx_form=>extract_texts( docx ).
      CATCH cx_docx_transformation_err.    "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_DOCX_TRANSFORMATION_ERR. ' quit = 1 ).
      CATCH cx_openxml_not_found.    "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_OPENXML_NOT_FOUND. ' quit = 1 ).
      CATCH cx_openxml_format.    "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_OPENXML_FORMAT. ' quit = 1 ).
    ENDTRY.

  ENDMETHOD.       "extract_Texts


  METHOD get_xsd_file.
* ====================
    DATA: docx           TYPE xstring,
          custom_xsd     TYPE xstring,
          exp_custom_xsd TYPE xstring.

* MIME url strings
    DATA: gv_url          TYPE string,
          gv_content_type TYPE string,                      "#EC NEEDED
          gv_error        TYPE i.

    DATA: nodes_inserted TYPE i,
          nodes_deleted  TYPE i,
          nodes_changed  TYPE i.

    DATA: diff_action  TYPE REF TO cl_xmldiff_action,
          diff_actions TYPE cl_xmldiff_action=>ty_table,
          action_str   TYPE string.                         "#EC NEEDED

    gv_url = 'r3mime:/sap/bc/bsp/sap/DOCX_TEST_FORMS/INVOICE.docx'.

    cl_fxs_url_data_fetcher=>fetch( EXPORTING iv_url = gv_url
    IMPORTING ev_content = docx
      ev_content_type = gv_content_type
      ev_error = gv_error ).
    IF gv_error <> 0.
      cl_aunit_assert=>fail( msg = 'Test case INVOICE.docx not found' level = cl_aunit_assert=>tolerable quit = 1 ).
    ENDIF.

    gv_url = 'r3mime:/sap/bc/bsp/sap/DOCX_TEST_FORMS/INVOICE_CUSTOM_XSD.xml'.
    cl_fxs_url_data_fetcher=>fetch( EXPORTING iv_url = gv_url
    IMPORTING ev_content = exp_custom_xsd
      ev_content_type = gv_content_type
      ev_error = gv_error ).
    IF gv_error <> 0.
      cl_aunit_assert=>fail( msg = 'Test case INVOICE_CUSTOM_XSD.xml not found' level = cl_aunit_assert=>tolerable quit = 1 ).
    ENDIF.

    TRY.
        custom_xsd = cl_docx_form=>get_xsd_file( docx ).
      CATCH cx_openxml_not_allowed.    "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_OPENXML_NOT_ALLOWED. ' quit = 1 ).
      CATCH cx_openxml_not_found.    "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_OPENXML_NOT_FOUND. ' quit = 1 ).
      CATCH cx_openxml_format.    "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_OPENXML_FORMAT. ' quit = 1 ).
      CATCH cx_docx_form_not_found.    "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_DOCX_FORM_NOT_FOUND. ' quit = 1 ).
    ENDTRY.

* compare schemas
* call XML diff tool to compare the xml files.

    TRY.
        cl_xmldiff=>diff(
        EXPORTING
*            iv_oldxml         =
          iv_oldxmlx        = custom_xsd
*            iv_newxml         =
          iv_newxmlx        = exp_custom_xsd
*      iv_match_strength = 2
        IMPORTING
          et_actions        = diff_actions
          ev_nodes_inserted = nodes_inserted
          ev_nodes_deleted  = nodes_deleted
          ev_nodes_changed  = nodes_changed
          ).
      CATCH cx_ixml_parse_error.    " XMLdiff parser error
        cl_aunit_assert=>fail( msg = 'Unexpected exception: cx_ixml_parse_error . ' quit = 1 ).
    ENDTRY.


*     Analyse the differences
    LOOP AT diff_actions INTO diff_action.

      action_str   = diff_action->get_string( ).

    ENDLOOP.

    cl_aunit_assert=>assert_equals( exp = nodes_inserted act = 0 msg = 'nodes_inserted not null' ).
    cl_aunit_assert=>assert_equals( exp = nodes_deleted  act = 0 msg = 'nodes_deleted  not null' ).
    cl_aunit_assert=>assert_equals( exp = nodes_changed  act = 0 msg = 'nodes_changed  not 1' ).


  ENDMETHOD.       "get_Xsd_File


  METHOD insert_xsd_file.
* =======================
    DATA: docx           TYPE xstring,                      "#EC NEEDED
          docx_updt      TYPE xstring,
          custom_xsd     TYPE xstring,
          exp_custom_xsd TYPE xstring.

* MIME url strings
    DATA: gv_url          TYPE string,
          gv_content_type TYPE string,                      "#EC NEEDED
          gv_error        TYPE i.

    DATA: nodes_inserted TYPE i,
          nodes_deleted  TYPE i,
          nodes_changed  TYPE i.

    DATA: diff_action  TYPE REF TO cl_xmldiff_action,
          diff_actions TYPE cl_xmldiff_action=>ty_table,
          action_str   TYPE string.                         "#EC NEEDED

    gv_url = 'r3mime:/sap/bc/bsp/sap/DOCX_TEST_FORMS/INVOICE_CUSTOM_XSD.xml'.

    cl_fxs_url_data_fetcher=>fetch( EXPORTING iv_url = gv_url
    IMPORTING ev_content = exp_custom_xsd
      ev_content_type = gv_content_type
      ev_error = gv_error ).
    IF gv_error <> 0.
      cl_aunit_assert=>fail( msg = 'Test case INVOICE_CUSTOM_XSD.xml not found' level = cl_aunit_assert=>tolerable quit = 1 ).
    ENDIF.

* no docx file
    TRY.
        docx_updt = cl_docx_form=>insert_xsd_file(
*      DOCX        =
            xsd_file    = exp_custom_xsd
        ).
      CATCH cx_openxml_not_allowed.  "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_OPENXML_NOT_ALLOWED. ' quit = 1 ).
      CATCH cx_openxml_not_found.  "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_OPENXML_NOT_FOUND. ' quit = 1 ).
      CATCH cx_openxml_format.  "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_OPENXML_FORMAT. ' quit = 1 ).
      CATCH cx_docx_form_not_found.  "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_DOCX_FORM_NOT_FOUND. ' quit = 1 ).
      CATCH cx_docx_form_not_unicode.  "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_DOCX_FORM_NOT_UNICODE. ' quit = 1 ).
    ENDTRY.

* get xsd file
    TRY.
        custom_xsd = cl_docx_form=>get_xsd_file( docx_updt ).
      CATCH cx_openxml_not_allowed.  "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_OPENXML_NOT_ALLOWED. ' quit = 1 ).
      CATCH cx_openxml_not_found.  "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_OPENXML_NOT_FOUND. ' quit = 1 ).
      CATCH cx_openxml_format.  "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_OPENXML_FORMAT. ' quit = 1 ).
      CATCH cx_docx_form_not_found.  "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_DOCX_FORM_NOT_FOUND. ' quit = 1 ).
    ENDTRY.

* compare schemas
* call XML diff tool to compare the xml files.

    TRY.
        cl_xmldiff=>diff(
        EXPORTING
*            iv_oldxml         =
          iv_oldxmlx        = custom_xsd
*            iv_newxml         =
          iv_newxmlx        = exp_custom_xsd

        IMPORTING
          et_actions        = diff_actions
          ev_nodes_inserted = nodes_inserted
          ev_nodes_deleted  = nodes_deleted
          ev_nodes_changed  = nodes_changed
          ).
      CATCH cx_ixml_parse_error.    " XMLdiff parser error
        cl_aunit_assert=>fail( msg = 'Unexpected exception: cx_ixml_parse_errorerror . ' quit = 1 ).
    ENDTRY.


*     Analyse the differences
    LOOP AT diff_actions INTO diff_action.

      action_str   = diff_action->get_string( ).

    ENDLOOP.

    cl_aunit_assert=>assert_equals( exp = nodes_inserted act = 0 msg = 'nodes_inserted not null' ).
    cl_aunit_assert=>assert_equals( exp = nodes_deleted  act = 0 msg = 'nodes_deleted  not null' ).
    cl_aunit_assert=>assert_equals( exp = nodes_changed  act = 0 msg = 'nodes_changed  not 1' ).


* docx without xsd file
* get docx
    gv_url = 'r3mime:/sap/bc/bsp/sap/DOCX_TEST_FORMS/INVOICE_WITHOUT_XSD.docx'.

    cl_fxs_url_data_fetcher=>fetch( EXPORTING iv_url = gv_url
    IMPORTING ev_content = docx
      ev_content_type = gv_content_type
      ev_error = gv_error ).
    IF gv_error <> 0.
      cl_aunit_assert=>fail( msg = 'Test case INVOICE_WITHOUT_XSD.docx not found' level = cl_aunit_assert=>tolerable quit = 1 ).
    ENDIF.

    TRY.
        docx_updt = cl_docx_form=>insert_xsd_file(
*      DOCX        =
            xsd_file    = exp_custom_xsd
        ).
      CATCH cx_openxml_not_allowed.  "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_OPENXML_NOT_ALLOWED. ' quit = 1 ).
      CATCH cx_openxml_not_found.  "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_OPENXML_NOT_FOUND. ' quit = 1 ).
      CATCH cx_openxml_format.  "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_OPENXML_FORMAT. ' quit = 1 ).
      CATCH cx_docx_form_not_found.  "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_DOCX_FORM_NOT_FOUND. ' quit = 1 ).
      CATCH cx_docx_form_not_unicode.  "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_DOCX_FORM_NOT_UNICODE. ' quit = 1 ).
    ENDTRY.

* get xsd file
    TRY.
        custom_xsd = cl_docx_form=>get_xsd_file( docx_updt ).
      CATCH cx_openxml_not_allowed.  "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_OPENXML_NOT_ALLOWED. ' quit = 1 ).
      CATCH cx_openxml_not_found.  "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_OPENXML_NOT_FOUND. ' quit = 1 ).
      CATCH cx_openxml_format.  "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_OPENXML_FORMAT. ' quit = 1 ).
      CATCH cx_docx_form_not_found.  "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_DOCX_FORM_NOT_FOUND. ' quit = 1 ).
    ENDTRY.

* compare schemas
* call XML diff tool to compare the xml files.

    TRY.
        cl_xmldiff=>diff(
        EXPORTING
*            iv_oldxml         =
          iv_oldxmlx        = custom_xsd
*            iv_newxml         =
          iv_newxmlx        = exp_custom_xsd
*      iv_match_strength = 2
        IMPORTING
          et_actions        = diff_actions
          ev_nodes_inserted = nodes_inserted
          ev_nodes_deleted  = nodes_deleted
          ev_nodes_changed  = nodes_changed
          ).
      CATCH cx_ixml_parse_error.    " XMLdiff parser error
        cl_aunit_assert=>fail( msg = 'Unexpected exception: cx_ixml_parse_error . ' quit = 1 ).
    ENDTRY.


*     Analyse the differences
    LOOP AT diff_actions INTO diff_action.

      action_str   = diff_action->get_string( ).

    ENDLOOP.

    cl_aunit_assert=>assert_equals( exp = nodes_inserted act = 0 msg = 'nodes_inserted not null' ).
    cl_aunit_assert=>assert_equals( exp = nodes_deleted  act = 0 msg = 'nodes_deleted  not null' ).
    cl_aunit_assert=>assert_equals( exp = nodes_changed  act = 0 msg = 'nodes_changed  not 1' ).


* docx with xsd file
* get docx
    gv_url = 'r3mime:/sap/bc/bsp/sap/DOCX_TEST_FORMS/INVOICE.docx'.

    cl_fxs_url_data_fetcher=>fetch( EXPORTING iv_url = gv_url
    IMPORTING ev_content = docx
      ev_content_type = gv_content_type
      ev_error = gv_error ).
    IF gv_error <> 0.
      cl_aunit_assert=>fail( msg = 'Test case INVOICE_WITHOUT_XSD.docx not found' level = cl_aunit_assert=>tolerable quit = 1 ).
    ENDIF.

    TRY.
        docx_updt = cl_docx_form=>insert_xsd_file(
*      DOCX        =
            xsd_file    = exp_custom_xsd
        ).
      CATCH cx_openxml_not_allowed.  "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_OPENXML_NOT_ALLOWED. ' quit = 1 ).
      CATCH cx_openxml_not_found.  "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_OPENXML_NOT_FOUND. ' quit = 1 ).
      CATCH cx_openxml_format.  "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_OPENXML_FORMAT. ' quit = 1 ).
      CATCH cx_docx_form_not_found.  "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_DOCX_FORM_NOT_FOUND. ' quit = 1 ).
      CATCH cx_docx_form_not_unicode.  "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_DOCX_FORM_NOT_UNICODE. ' quit = 1 ).
    ENDTRY.

* get xsd file
    TRY.
        custom_xsd = cl_docx_form=>get_xsd_file( docx_updt ).
      CATCH cx_openxml_not_allowed.  "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_OPENXML_NOT_ALLOWED. ' quit = 1 ).
      CATCH cx_openxml_not_found.  "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_OPENXML_NOT_FOUND. ' quit = 1 ).
      CATCH cx_openxml_format.  "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_OPENXML_FORMAT. ' quit = 1 ).
      CATCH cx_docx_form_not_found.  "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_DOCX_FORM_NOT_FOUND. ' quit = 1 ).
    ENDTRY.

* compare schemas
* call XML diff tool to compare the xml files.

    TRY.
        cl_xmldiff=>diff(
        EXPORTING
*            iv_oldxml         =
          iv_oldxmlx        = custom_xsd
*            iv_newxml         =
          iv_newxmlx        = exp_custom_xsd

        IMPORTING
          et_actions        = diff_actions
          ev_nodes_inserted = nodes_inserted
          ev_nodes_deleted  = nodes_deleted
          ev_nodes_changed  = nodes_changed
          ).
      CATCH cx_ixml_parse_error.    " XMLdiff parser error
        cl_aunit_assert=>fail( msg = 'Unexpected exception: cx_ixml_parse_error . ' quit = 1 ).
    ENDTRY.


*     Analyse the differences
    LOOP AT diff_actions INTO diff_action.

      action_str   = diff_action->get_string( ).

    ENDLOOP.

    cl_aunit_assert=>assert_equals( exp = nodes_inserted act = 0 msg = 'nodes_inserted not null' ).
    cl_aunit_assert=>assert_equals( exp = nodes_deleted  act = 0 msg = 'nodes_deleted  not null' ).
    cl_aunit_assert=>assert_equals( exp = nodes_changed  act = 0 msg = 'nodes_changed  not 1' ).

  ENDMETHOD.       "insert_Xsd_File


  METHOD merge_data.


  ENDMETHOD.       "merge_Data


  METHOD merge_texts.
* ===================
* =====================
    DATA: docx  TYPE xstring,
          texts TYPE xstring.

* MIME url strings
    DATA: gv_url          TYPE string,
          gv_content_type TYPE string,                      "#EC NEEDED
          gv_error        TYPE i.

    gv_url = 'r3mime:/sap/bc/bsp/sap/DOCX_TEST_FORMS/INVOICE_EN.docx'.

    cl_fxs_url_data_fetcher=>fetch( EXPORTING iv_url = gv_url
    IMPORTING ev_content = docx
      ev_content_type = gv_content_type
      ev_error = gv_error ).
    IF gv_error <> 0.
      cl_aunit_assert=>fail( msg = 'Test case INVOICE_EN.docx not found' level = cl_aunit_assert=>tolerable quit = 1 ).
    ENDIF.

    gv_url = 'r3mime:/sap/bc/bsp/sap/DOCX_TEST_FORMS/INVOICE_XLIFF.xml'.

    cl_fxs_url_data_fetcher=>fetch( EXPORTING iv_url = gv_url
    IMPORTING ev_content = texts
      ev_content_type = gv_content_type
      ev_error = gv_error ).
    IF gv_error <> 0.
      cl_aunit_assert=>fail( msg = 'Test case INVOICE_XLIFF.xml not found' level = cl_aunit_assert=>tolerable quit = 1 ).
    ENDIF.

    TRY.
        cl_docx_form=>merge_texts( document = docx texts = texts ).
      CATCH cx_docx_transformation_err.    "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_DOCX_TRANSFORMATION_ERR. ' quit = 1 ).
      CATCH cx_openxml_not_found.    "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_OPENXML_NOT_FOUND. ' quit = 1 ).
      CATCH cx_openxml_format.    "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_OPENXML_FORMAT. ' quit = 1 ).
    ENDTRY.

  ENDMETHOD.       "merge_Texts


  METHOD print_docx.
* ==================


  ENDMETHOD.       "print_Docx


  METHOD replace_xml_data_file.
* =============================
    DATA: docx            TYPE xstring,
          docx_updt       TYPE xstring,
          custom_data     TYPE xstring,
          exp_custom_data TYPE xstring.

* MIME url strings
    DATA: gv_url          TYPE string,
          gv_content_type TYPE string,                      "#EC NEEDED
          gv_error        TYPE i.

    DATA: nodes_inserted TYPE i,
          nodes_deleted  TYPE i,
          nodes_changed  TYPE i.

    DATA: diff_action  TYPE REF TO cl_xmldiff_action,
          diff_actions TYPE cl_xmldiff_action=>ty_table,
          action_str   TYPE string.                         "#EC NEEDED

    DATA: doc                TYPE REF TO cl_docx_document,
          maindocumentpart   TYPE REF TO cl_docx_maindocumentpart,
          customxmlpart      TYPE REF TO cl_oxml_customxmlpart,
          customxmlpartcoll  TYPE REF TO cl_openxml_partcollection,
          propertyxml        TYPE xstring,
          customxmlpropspart TYPE REF TO cl_oxml_customxmlpropspart,
          part               TYPE REF TO cl_openxml_part.

    DATA: found                  TYPE abap_bool,
          num_of_customxml_files TYPE i.

    gv_url = 'r3mime:/sap/bc/bsp/sap/DOCX_TEST_FORMS/INVOICE.docx'.

    cl_fxs_url_data_fetcher=>fetch( EXPORTING iv_url = gv_url
    IMPORTING ev_content = docx
      ev_content_type = gv_content_type
      ev_error = gv_error ).
    IF gv_error <> 0.
      cl_aunit_assert=>fail( msg = 'Test case INVOICE.docx not found' level = cl_aunit_assert=>tolerable quit = 1 ).
    ENDIF.


    gv_url = 'r3mime:/sap/bc/bsp/sap/DOCX_TEST_FORMS/INVOICE_DATA_MODIFIED.xml'.

    cl_fxs_url_data_fetcher=>fetch( EXPORTING iv_url = gv_url
    IMPORTING ev_content = exp_custom_data
      ev_content_type = gv_content_type
      ev_error = gv_error ).

    IF gv_error <> 0.
      cl_aunit_assert=>fail( msg = 'Test case INVOICE_DATA_MODIFIED.xml not found' level = cl_aunit_assert=>tolerable quit = 1 ).
    ENDIF.

    TRY.
        cl_docx_form=>replace_xml_data_file(
        EXPORTING
          docx        = docx
          xml_data    = exp_custom_data
          RECEIVING
          docx_result = docx_updt
          ).
      CATCH cx_openxml_not_found.    "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_OPENXML_NOT_FOUND. ' quit = 1 ).
      CATCH cx_openxml_format.    "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_OPENXML_FORMAT. ' quit = 1 ).
      CATCH cx_docx_form_not_found.    "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_DOCX_FORM_NOT_FOUND. ' quit = 1 ).
      CATCH cx_docx_form_not_unicode.    "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_DOCX_FORM_NOT_UNICODED. ' quit = 1 ).
    ENDTRY.

* get xml data file from updated docx

* load the document
    TRY.
        doc = cl_docx_document=>load_document( docx_updt ).
      CATCH cx_openxml_format.
        cl_aunit_assert=>fail( msg = 'Unexpected exception: cx_openxml_format. ' quit = 1 ).
    ENDTRY.
* get the maindocument part
    TRY.
        maindocumentpart = doc->get_maindocumentpart( ).
      CATCH cx_openxml_format.
        cl_aunit_assert=>fail( msg = 'Unexpected exception: cx_openxml_format. ' quit = 1 ).
      CATCH cx_openxml_not_found.
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_OPENXML_NOT_FOUND. ' quit = 1 ).
    ENDTRY.
* get collection of customXML parts
    TRY.
        customxmlpartcoll = maindocumentpart->get_customxmlparts( ).
      CATCH cx_openxml_format.
        cl_aunit_assert=>fail( msg = 'Unexpected exception: cx_openxml_format. ' quit = 1 ).
      CATCH cx_openxml_not_found.
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_OPENXML_NOT_FOUND. ' quit = 1 ).
    ENDTRY.
* get number of customXML parts
    num_of_customxml_files = customxmlpartcoll->get_count( ).


    found = abap_false.
    DO num_of_customxml_files TIMES.

* get customXML part
      part = customxmlpartcoll->get_part( sy-index - 1 ).
* downcast
      customxmlpart ?= part.
* get customXML properties part
      TRY.
          customxmlpropspart = customxmlpart->get_customxmlpropspart( ).
        CATCH cx_openxml_format.
          cl_aunit_assert=>fail( msg = 'Unexpected exception: cx_openxml_format. ' quit = 1 ).
        CATCH cx_openxml_not_found.
          cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_OPENXML_NOT_FOUND. ' quit = 1 ).
      ENDTRY.
* get properties content
      propertyxml = customxmlpropspart->get_data( ).
* check namespace reference
      IF zcl_docx_form=>contains_customxml( namespace = 'http://www.sap.com/SAPForm/0.5'  customxml_props = propertyxml ) = abap_true
        AND zcl_docx_form=>contains_customxml( namespace = 'http://www.w3.org/2001/XMLSchema'  customxml_props = propertyxml ) = abap_false.
        found = abap_true.
        custom_data = customxmlpart->get_data( ).

      ENDIF.
    ENDDO.

    IF found = abap_false.
      cl_aunit_assert=>fail( msg = 'Data XML file not found ' quit = 1 ).
    ENDIF.

* compare schemas
* call XML diff tool to compare the xml files.

    TRY.
        cl_xmldiff=>diff(
        EXPORTING
*            iv_oldxml         =
          iv_oldxmlx        = custom_data
*            iv_newxml         =
          iv_newxmlx        = exp_custom_data

        IMPORTING
          et_actions        = diff_actions
          ev_nodes_inserted = nodes_inserted
          ev_nodes_deleted  = nodes_deleted
          ev_nodes_changed  = nodes_changed
          ).
      CATCH cx_ixml_parse_error.    " XMLdiff parser error
        cl_aunit_assert=>fail( msg = 'Unexpected exception: cx_ixml_parse_error . ' quit = 1 ).
    ENDTRY.


*     Analyse the differences
    LOOP AT diff_actions INTO diff_action.

      action_str   = diff_action->get_string( ).

    ENDLOOP.

    cl_aunit_assert=>assert_equals( exp = nodes_inserted act = 0 msg = 'nodes_inserted not null' ).
    cl_aunit_assert=>assert_equals( exp = nodes_deleted  act = 0 msg = 'nodes_deleted  not null' ).
    cl_aunit_assert=>assert_equals( exp = nodes_changed  act = 0 msg = 'nodes_changed  not 1' ).


  ENDMETHOD.       "replace_Xml_Data_File


  METHOD update_translation.
* ==========================

    DATA: old_docx TYPE xstring,
          new_docx TYPE xstring.

    DATA: gv_content_type TYPE string,                      "#EC NEEDED
          gv_error        TYPE i,
          gv_url          TYPE string.

* When layout changes, the docx should be updated.
    gv_url = 'r3mime:/sap/bc/bsp/sap/DOCX_TEST_FORMS/INVOICE.docx'.

    cl_fxs_url_data_fetcher=>fetch( EXPORTING iv_url = gv_url
    IMPORTING ev_content = old_docx
      ev_content_type = gv_content_type
      ev_error = gv_error ).
    IF gv_error <> 0.
      cl_aunit_assert=>fail( msg = 'Test case INVOICE.docx not found' level = cl_aunit_assert=>tolerable quit = 1 ).
    ENDIF.

    gv_url = 'r3mime:/sap/bc/bsp/sap/DOCX_TEST_FORMS/INVOICE_SIMPLE.docx'.

    cl_fxs_url_data_fetcher=>fetch( EXPORTING iv_url = gv_url
    IMPORTING ev_content = new_docx
      ev_content_type = gv_content_type
      ev_error = gv_error ).
    IF gv_error <> 0.
      cl_aunit_assert=>fail( msg = 'Test case INVOICE_SIMPLE.docx not found' level = cl_aunit_assert=>tolerable quit = 1 ).
    ENDIF.

    TRY.
        cl_docx_form=>update_translation( new_docx_templ = new_docx old_docx_templ = old_docx ).
      CATCH cx_docx_transformation_err.    "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_DOCX_TRANSFORMATION_ERR. ' quit = 1 ).
      CATCH cx_openxml_not_found.    "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_OPENXML_NOT_FOUND. ' quit = 1 ).
      CATCH cx_openxml_format.    "
        cl_aunit_assert=>fail( msg = 'Unexpected exception: CX_OPENXML_FORMAT. ' quit = 1 ).
    ENDTRY.


  ENDMETHOD.       "update_Translation


  METHOD update_translation_tags.
* ===============================

    DATA: invoice_with_tags    TYPE xstring,
          invoice_without_tags TYPE xstring.

    DATA: gv_content_type TYPE string,                      "#EC NEEDED
          gv_error        TYPE i,
          gv_url          TYPE string.

    DATA: doc_old              TYPE REF TO cl_docx_document,
          maindocumentpart_old TYPE REF TO cl_docx_maindocumentpart,
          document_xstr_old    TYPE xstring.

    DATA: doc_new              TYPE REF TO cl_docx_document,
          maindocumentpart_new TYPE REF TO cl_docx_maindocumentpart,
          document_xstr_new    TYPE xstring.

    DATA: nodes_inserted TYPE i,
          nodes_deleted  TYPE i,
          nodes_changed  TYPE i.

    DATA: diff_action  TYPE REF TO cl_xmldiff_action,
          diff_actions TYPE cl_xmldiff_action=>ty_table.


    DATA: action_str             TYPE string.               "#EC NEEDED


    gv_url = 'r3mime:/sap/bc/bsp/sap/DOCX_TEST_FORMS/INVOICE.docx'.

    cl_fxs_url_data_fetcher=>fetch( EXPORTING iv_url = gv_url
    IMPORTING ev_content = invoice_with_tags
      ev_content_type = gv_content_type
      ev_error = gv_error ).
    IF gv_error <> 0.
      cl_aunit_assert=>fail( msg = 'Test case INVOICE.docx not found' level = cl_aunit_assert=>tolerable quit = 1 ).
    ENDIF.


    gv_url = 'r3mime:/sap/bc/bsp/sap/DOCX_TEST_FORMS/INVOICE_NO_TGS.DOCX'.

    cl_fxs_url_data_fetcher=>fetch( EXPORTING iv_url = gv_url
    IMPORTING ev_content = invoice_without_tags
      ev_content_type = gv_content_type
      ev_error = gv_error ).

    IF gv_error <> 0.
      cl_aunit_assert=>fail( msg = 'Test case INVOICE_NO_TGS.docx not found' level = cl_aunit_assert=>tolerable quit = 1 ).
    ENDIF.


    TRY.
        cl_docx_form=>update_translation_tags(
      CHANGING
          docx_template = invoice_without_tags ).
      CATCH cx_docx_transformation_err.    " XSLT transformation error
        cl_aunit_assert=>fail( msg = 'Unexpected exception: cx_docx_transformation_err. ' quit = 1 ).
      CATCH cx_openxml_format.    " Packaging Error - Invalid Content
        cl_aunit_assert=>fail( msg = 'Unexpected exception: cx_openxml_format. ' quit = 1 ).
      CATCH cx_openxml_not_found.    " Part not found
        cl_aunit_assert=>fail( msg = 'Unexpected exception: cx_openxml_not_found. ' quit = 1 ).
    ENDTRY.

* compare main document parts of invoice with tags and created_invoice_with_tags
    TRY.
        doc_old              = cl_docx_document=>load_document( invoice_with_tags ).
      CATCH cx_openxml_format.
        cl_aunit_assert=>fail( msg = 'Unexpected exception: cx_openxml_format. ' quit = 1 ).
    ENDTRY.

    TRY.
        maindocumentpart_old = doc_old->get_maindocumentpart( ).
      CATCH cx_openxml_format.
        cl_aunit_assert=>fail( msg = 'Unexpected exception: cx_openxml_format. ' quit = 1 ).
      CATCH cx_openxml_not_found.
        cl_aunit_assert=>fail( msg = 'Unexpected exception: cx_openxml_not_found. ' quit = 1 ).
    ENDTRY.
    document_xstr_old    = maindocumentpart_old->get_data( ).

    TRY.
        doc_new              = cl_docx_document=>load_document( invoice_without_tags ).
      CATCH cx_openxml_format.
        cl_aunit_assert=>fail( msg = 'Unexpected exception: cx_openxml_format. ' quit = 1 ).
    ENDTRY.

    TRY.
        maindocumentpart_new = doc_new->get_maindocumentpart( ).
      CATCH cx_openxml_not_found.  " Part not found
        cl_aunit_assert=>fail( msg = 'Unexpected exception: cx_openxml_not_found. ' quit = 1 ).
      CATCH cx_openxml_format.  " Packaging Error - Invalid Content
        cl_aunit_assert=>fail( msg = 'Unexpected exception: cx_openxml_format. ' quit = 1 ).
    ENDTRY.
    document_xstr_new    = maindocumentpart_new->get_data( ).

* call XML diff tool to compare the xml files.

    TRY.
        cl_xmldiff=>diff(
        EXPORTING
*            iv_oldxml         =
          iv_oldxmlx        = document_xstr_old
*            iv_newxml         =
          iv_newxmlx        = document_xstr_new

        IMPORTING
          et_actions        = diff_actions
          ev_nodes_inserted = nodes_inserted
          ev_nodes_deleted  = nodes_deleted
          ev_nodes_changed  = nodes_changed
          ).
      CATCH cx_ixml_parse_error.    " XMLdiff parser error
        cl_aunit_assert=>fail( msg = 'Unexpected exception: cx_ixml_parse_error . ' quit = 1 ).
    ENDTRY.

    cl_aunit_assert=>assert_equals( exp = nodes_inserted act = 0 msg = 'nodes_inserted not null' ).
    cl_aunit_assert=>assert_equals( exp = nodes_deleted  act = 0 msg = 'nodes_deleted  not null' ).
    cl_aunit_assert=>assert_equals( exp = nodes_changed  act = 16 msg = 'nodes_changed  not expected 16' ).

*     Analyse the differences
    LOOP AT diff_actions INTO diff_action.

      action_str   = diff_action->get_string( ).

    ENDLOOP.





  ENDMETHOD.       "update_Translation_Tags

  METHOD re_merge_document.
* ==========================

  ENDMETHOD.       "re_merge_document



ENDCLASS.       "cl_Tst_Docx_Form
