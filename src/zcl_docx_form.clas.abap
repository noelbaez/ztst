class ZCL_DOCX_FORM definition
  public
  final
  create public .

public section.

*"* public components of class ZCL_DOCX_FORM
*"* do not include other source files here!!!
  class-methods UPDATE_TRANSLATION
    importing
      !NEW_DOCX_TEMPL type XSTRING
      !OLD_DOCX_TEMPL type XSTRING
    returning
      value(UPD_DOCX_TEMPL) type XSTRING
    raising
      CX_DOCX_TRANSFORMATION_ERR
      CX_OPENXML_FORMAT
      CX_OPENXML_NOT_FOUND .
  class-methods UPDATE_TRANSLATION_TAGS
    changing
      !DOCX_TEMPLATE type XSTRING
    raising
      CX_DOCX_TRANSFORMATION_ERR
      CX_OPENXML_FORMAT
      CX_OPENXML_NOT_FOUND .
  class-methods MERGE_DATA
    importing
      !IM_FORMTEMPLATE_DATA type XSTRING
      !IM_CUSTOMXML_DATA type XSTRING
      !IM_DEVCLASS type STRING default '$TMP'
      !IM_LANGUAGE type DBSPRAS optional
      !IM_COUNTRY type DBCOUNTRY optional
      !IM_DELETE_SDT_TAGS type C default 'R'
    returning
      value(RE_MERGED_DATA) type XSTRING
    raising
      CX_OPENXML_FORMAT
      CX_OPENXML_NOT_FOUND
      CX_MERGE_PARTS .
  class-methods EXTRACT_TEXTS
    importing
      !DOCUMENT type XSTRING
    returning
      value(TEXTS) type XSTRING
    raising
      CX_DOCX_TRANSFORMATION_ERR
      CX_OPENXML_FORMAT
      CX_OPENXML_NOT_FOUND .
  class-methods CREATE_FORM
    importing
      !FORM_CONTEXT type XSTRING optional
    preferred parameter FORM_CONTEXT
    returning
      value(DOCX) type XSTRING
    raising
      CX_OPENXML_NOT_ALLOWED
      CX_OPENXML_NOT_FOUND
      CX_OPENXML_FORMAT
      CX_DOCX_FORM_NOT_UNICODE .
  class-methods MERGE_TEXTS
    importing
      !DOCUMENT type XSTRING
      !TEXTS type XSTRING
    returning
      value(MERGED_DOCUMENT) type XSTRING
    raising
      CX_DOCX_TRANSFORMATION_ERR
      CX_OPENXML_FORMAT
      CX_OPENXML_NOT_FOUND .
  class-methods REPLACE_XML_DATA_FILE
    importing
      !DOCX type XSTRING
      !XML_DATA type XSTRING
    returning
      value(DOCX_RESULT) type XSTRING
    raising
      CX_OPENXML_NOT_FOUND
      CX_OPENXML_FORMAT
      CX_DOCX_FORM_NOT_FOUND
      CX_DOCX_FORM_NOT_UNICODE .
  class-methods GET_XSD_FILE
    importing
      !DOCX type XSTRING optional
    preferred parameter DOCX
    returning
      value(XSD_FILE) type XSTRING
    raising
      CX_OPENXML_NOT_ALLOWED
      CX_OPENXML_NOT_FOUND
      CX_OPENXML_FORMAT
      CX_DOCX_FORM_NOT_FOUND .
  class-methods INSERT_XSD_FILE
    importing
      !DOCX type XSTRING optional
      !XSD_FILE type XSTRING
    preferred parameter DOCX
    returning
      value(DOCX_RESULT) type XSTRING
    raising
      CX_OPENXML_NOT_ALLOWED
      CX_OPENXML_NOT_FOUND
      CX_OPENXML_FORMAT
      CX_DOCX_FORM_NOT_FOUND
      CX_DOCX_FORM_NOT_UNICODE .
  class-methods CREATE_PDFPREVIEW
    importing
      !IM_DOCX_DATA type XSTRING
    exporting
      !EX_PDF_DATA type XSTRING
      !EX_NUMPAGES type INT4
      !EX_ERRSTRING type STRING
    raising
      CX_DOCX_PDF_PREVIEW_ERR .
  class-methods PRINT_DOCX
    importing
      !IM_DOCX_DATA type XSTRING
      !IM_PRINTER type RSPOPNAME
      !IM_COPIES type RSPOCOPIES optional
      !IM_NAME type RSPO0NAME default 'DOCx'
      !IM_SUFFIX1 type RSPO1NAME optional
      !IM_SUFFIX2 type RSPO2NAME optional
      !IM_NEWID type C optional
      !IM_IMMED type RSPO1DISPO default SPACE
      !IM_DELETE type RSPO2DISPO default SPACE
      !IM_FINAL type RSPOFINAL default SPACE
      !IM_LIFETIME type C default '8'
      !IM_TITLE type RSPOTITLE optional
      !IM_RECEIVER type RSPORECEIV optional
      !IM_DIVISION type RSPODIVISI optional
      !IM_AUTH type RSPOAUTH optional
      !IM_COVERPAGE type C optional
    exporting
      !EX_SPOOLID type RSPOID
      !EX_NUMPAGES type INT4
      !EX_ERRSTRING type STRING
    raising
      CX_DOCX_PRINT_ERROR .
  class-methods RE_MERGE_DOCUMENT
    importing
      !IM_DOCX_NEW_CHANGE type XSTRING
      !IM_DOCX_DOCUMENT type XSTRING
      !IM_COUNTRY type DBCOUNTRY optional
      !IM_LANGUAGE type DBSPRAS optional
    returning
      value(RE_MERGED_DOCUMENT) type XSTRING .
  class-methods SET_SAP_FORM_USER
    importing
      !IM_DOCX type XSTRING
      !IM_USER type STRING default ''
    returning
      value(RE_DOCX) type XSTRING
    raising
      CX_DOCX_TRANSFORMATION_ERR .
protected section.
*"* protected components of class ZCL_DOCX_FORM
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_DOCX_FORM
*"* do not include other source files here!!!

  type-pools ABAP .
  class-methods CONTAINS_CUSTOMXML
    importing
      !NAMESPACE type STRING
      !CUSTOMXML_PROPS type XSTRING
    returning
      value(FOUND) type ABAP_BOOL .
ENDCLASS.



CLASS ZCL_DOCX_FORM IMPLEMENTATION.


method CONTAINS_CUSTOMXML.




CALL TRANSFORMATION DOCX_CONTAINS_CUSTOMXML
                    PARAMETERS namespace_ref = namespace
                    SOURCE XML customxml_props
                    RESULT it = found.



endmethod.


method CREATE_FORM.

  DATA: doc                TYPE REF TO cl_docx_document,
        maindocumentPart   TYPE REF TO cl_docx_Maindocumentpart,
        customXMLPart      TYPE REF TO cl_oxml_customxmlpart,
        customUIPart       TYPE REF TO cl_oxml_customuipart,
        customXMLPropsPart TYPE REF TO cl_oxml_customxmlpropspart,
        docSettingsPart    type  ref to cl_docx_documentsettingspart, "#EC NEEDED
        propertyXML        TYPE XSTRING,
        settingsXML        type xstring,"#EC NEEDED
        resultXML          type xstring,"#EC NEEDED
        xml_data           TYPE XSTRING,"#EC NEEDED
        emptyXML           TYPE XSTRING,"#EC NEEDED
        preGUID            TYPE STRING,
        GUID               TYPE STRING,
        ribbon_ui_str      TYPE STRING,
        ribbon_ui          TYPE XSTRING.

* Custom ribbon UI
define add_str.
    CONCATENATE ribbon_ui_str &1 INTO ribbon_ui_str RESPECTING BLANKS.
end-of-definition.

** custom ribbon - suppress non-XSL:FO compatible Word features
*add_str '<?xml version="1.0" encoding="utf-8"?>'.
*add_str '<customUI xmlns="http://schemas.microsoft.com/office/2006/01/customui">'.
*  add_str '<commands>'.
*    add_str '<command idMso="TabSetTableTools" enabled="false"/>'.
*    add_str '<command idMso="TabSetHeaderAndFooterTools" enabled="false"/>'.
*    add_str '<command idMso="TabSetTextBoxTools" enabled="false"/>'.
*    add_str '<command idMso="ObjectPictureFill" enabled="false"/>'.
*    add_str '<command idMso="ShapeFillGradientGalleryClassic" enabled="false"/>'.
*    add_str '<command idMso="Drawing1GalleryTextures" enabled="false"/>'.
*    add_str '<command idMso="ShapeFillEffectMoreTexturesDialogClassic" enabled="false"/>'.
*    add_str '<command idMso="ShapeFillEffectPatternClassic" enabled="false"/>'.
*    add_str '<command idMso="OutlineLinePatternFill" enabled="false"/>'.
*    add_str '<command idMso="TableDrawTable" enabled="false"/>'.
*    add_str '<command idMso="ConvertTextToTable" enabled="false"/>'.
*    add_str '<command idMso="TableExcelSpreadsheetInsert" enabled="false"/>'.
*    add_str '<command idMso="QuickTablesInsertGallery" enabled="false"/>'.
*    add_str '<command idMso="SaveSelectionToQuickTablesGallery" enabled="false"/>'.
*  add_str '</commands>'.
*  add_str '<ribbon startFromScratch="true">'.
*    add_str '<qat>'.
*      add_str '<documentControls>'.
*        add_str '<button idMso="FileSave"/>'.
*        add_str '<control idMso="Undo"/>'.
*        add_str '<button idMso="RedoOrRepeat"/>'.
*      add_str '</documentControls>'.
*    add_str '</qat>'.
*    add_str '<officeMenu>'.
*      add_str '<button idMso="FileSaveAs"/>'.
*    add_str '</officeMenu>'.
*    add_str '<tabs>'.
*      add_str '<tab id="Home_SAP" label="Home (SAP)">'.
*        add_str '<group id="GroupFont_SAP" label="Font" >'.
*          add_str '<box id="FontBox_SAP" boxStyle="horizontal">'.
*            add_str '<comboBox idMso="Font"/>'.
*            add_str '<comboBox idMso="FontSize"/>'.
*            add_str '<buttonGroup id="IncreaseFontGroup_SAP">'.
*              add_str '<button idMso="FontSizeIncreaseWord"/>'.
*              add_str '<button idMso="FontSizeDecreaseWord"/>'.
*            add_str '</buttonGroup>'.
*          add_str '</box>'.
*          add_str '<box id="DecorationsBox_SAP" boxStyle="horizontal">'.
*            add_str '<buttonGroup id="TextDecorGroup_SAP">'.
*              add_str '<toggleButton idMso="Bold"/>'.
*              add_str '<toggleButton idMso="Italic"/>'.
*              add_str '<toggleButton idMso="Underline"/>'.
*              add_str '<toggleButton idMso="Strikethrough"/>'.
*              add_str '<toggleButton idMso="Subscript"/>'.
*              add_str '<toggleButton idMso="Superscript"/>'.
*              add_str '<gallery idMso="TextHighlightColorPicker"/>'.
*              add_str '<gallery idMso="FontColorPicker"/>'.
*            add_str '</buttonGroup>'.
*          add_str '</box>'.
*
*        add_str '</group>'.
*        add_str '<group id="GroupParagraph_SAP" label="Paragraph">'.
*          add_str '<box id="ItemsAndIndentGroup_SAP" boxStyle="horizontal">'.
*            add_str '<buttonGroup id="ListItemGroup_SAP">'.
*              add_str '<toggleButton idMso="Bullets"/>'.
*              add_str '<toggleButton idMso="Numbering"/>'.
*            add_str '</buttonGroup>'.
*            add_str '<buttonGroup id="IndentGroup_SAP">'.
*              add_str '<button idMso="IndentDecreaseWord"/>'.
*              add_str '<button idMso="IndentIncreaseWord"/>'.
*            add_str '</buttonGroup>'.
*            add_str '<toggleButton idMso="ParagraphMarks"/>'.
*          add_str '</box>'.
*          add_str '<box id="AlignemntAndSpacingGroup_SAP">'.
*            add_str '<buttonGroup id="AlignementGroup_SAP">'.
*              add_str '<toggleButton idMso="AlignLeft"/>'.
*              add_str '<toggleButton idMso="AlignCenter"/>'.
*              add_str '<toggleButton idMso="AlignRight"/>'.
*            add_str '</buttonGroup>'.
*            add_str '<menu idMso="LineSpacingMenu"/>'.
*            add_str '<gallery idMso="ShadingColorPicker"/>'.
*          add_str '</box>'.
*          add_str '<box id="ParagraphDecoration_SAP">'.
*
*            add_str '<splitButton id="TableBordersMenu_SAP">'.
*              add_str '<menu>'.
*                add_str '<toggleButton idMso="BorderBottomWord"/>'.
*                add_str '<toggleButton idMso="BorderTopWord"/>'.
*                add_str '<toggleButton idMso="BorderBottomWord"/>'.
*                add_str '<toggleButton idMso="BorderLeftWord"/>'.
*                add_str '<toggleButton idMso="BorderRigthWord"/>'.
*                add_str '<toggleButton idMso="BorderOutside"/>'.
*                add_str '<toggleButton idMso="BorderNone"/>'.
*              add_str '</menu>'.
*            add_str '</splitButton>'.
*
*          add_str '</box>'.
*        add_str '</group>'.
*        add_str '<group id="Styles_SAP" label="Styles">'.
*          add_str '<gallery idMso="QuickStylesGallery" size="large"/>'.
*        add_str '</group>'.
*        add_str '<group idMso="GroupEditing"/>'.
*      add_str '</tab>'.
*      add_str '<tab id="Insert_SAP" label="Insert">'.
*        add_str '<group id="GroupInsertTables_SAP" label="Tables">'.
*          add_str '<gallery idMso="TableInsertGallery" size="large"/>'.
*          add_str '<separator id="sep1"/>'.
*          add_str '<box id="TableHeader_SAP" boxStyle="vertical">'.
*            add_str '<checkBox idMso="TableStyleHeaderRowWord"/>'.
*            add_str '<checkBox idMso="TableStyleTotalRowWord"/>'.
*            add_str '<checkBox idMso="TableStyleBandedRowsWord"/>'.
*          add_str '</box>'.
*          add_str '<box id="TableTotal_SAP" boxStyle="vertical">'.
*            add_str '<checkBox idMso="TableStylesFirstColumnWord"/>'.
*            add_str '<checkBox idMso="TableStyleLastColumnWord"/>'.
*            add_str '<checkBox idMso="TableStyleBandedColumnsWord"/>'.
*          add_str '</box>'.
*          add_str '<separator id="sep2"/>'.
*          add_str '<gallery idMso="TableStylesGalleryWord"/>'.
*          add_str '<gallery idMso="ShadingColorPicker"/>'.
*          add_str '<splitButton id="TableBordersMenu2_SAP">'.
*            add_str '<menu>'.
*              add_str '<toggleButton idMso="BorderBottomWord"/>'.
*              add_str '<toggleButton idMso="BorderTopWord"/>'.
*              add_str '<toggleButton idMso="BorderBottomWord"/>'.
*              add_str '<toggleButton idMso="BorderLeftWord"/>'.
*              add_str '<toggleButton idMso="BorderRigthWord"/>'.
*              add_str '<toggleButton idMso="BorderOutside"/>'.
*              add_str '<toggleButton idMso="BorderNone"/>'.
*            add_str '</menu>'.
*          add_str '</splitButton>'.
*        add_str '</group>'.
*        add_str '<group id="GroupInsertIllustrations_SAP" label="Illustrations">'.
*          add_str '<button idMso="PictureInsertFromFile" size="large"/>'.
*        add_str '</group>'.
*        add_str '<group id="GroupText_SAP" label="Text">'.
*          add_str '<button idMso="TextBoxInsert"/>'.
*          add_str '<gallery idMso="Drawing1ColorPickerFill"/>'.
*          add_str '<gallery idMso="Drawing1ColorPickerLineStyles"/>'.
*        add_str '</group>'.
*        add_str '<group id="Endnotes_SAP" label="Endnotes">'.
*          add_str '<button idMso="EndnoteInsertWord"/>'.
*          add_str '<splitButton id="EndnoteNext_SAP">'.
*            add_str '<menu>'.
*              add_str '<button idMso="EndnoteNextWord"/>'.
*              add_str '<button idMso="EndnotePreviousWord"/>'.
*            add_str '</menu>'.
*          add_str '</splitButton>'.
*        add_str '</group>'.
*        add_str '<group id="Captions_SAP" label="Captions">'.
*          add_str '<button idMso="CaptionInsert" size="large"/>'.
*        add_str '</group>'.
*      add_str '</tab>'.
*      add_str '<tab id="TabPageLayout_SAP" label ="Page Layout">'.
*        add_str '<group id="GroupPageLayoutSetup_SAP" label="Page Setup">'.
*          add_str '<gallery idMso="PageMarginsGallery"/>'.
*          add_str '<gallery idMso="PageOrientationGallery"/>'.
*          add_str '<gallery idMso="PageSizeGallery"/>'.
*          add_str '<gallery idMso="BreaksGallery"/>'.
*        add_str '</group>'.
*        add_str '<group id="GroupInsertHeader_SAP" label="Header / Footer">'.
*          add_str '<box id="HeaderFooterOptions_SAP" boxStyle="vertical">'.
*            add_str '<checkBox idMso="HeaderFooterDifferentFirstPageWord"/>'.
*            add_str '<checkBox idMso="HeaderFooterDifferentOddEvenPageWord"/>'.
*            add_str '<checkBox idMso="HeaderFooterShowDocumentText"/>'.
*          add_str '</box>'.
*          add_str '<separator id="sep3"/>'.
*          add_str '<gallery idMso="PageNumbersInHeaderInsertGallery" label="Header-Pagenumbers"/>'.
*          add_str '<gallery idMso="PageNambersInFooterInsertGallery" label="Footer-Pagenumbers"/>'.
*        add_str '</group>'.
*        add_str '<group idMso="GroupParagraphLayout"/>'.
*      add_str '</tab>'.
*      add_str '<tab id="TabView_SAP" label="View">'.
*        add_str '<group idMso="GroupDocumentViews"/>'.
*        add_str '<group idMso="GroupViewShowHide"/>'.
*        add_str '<group idMso="GroupZoom"/>'.
*        add_str '<group idMso="GroupWindow"/>'.
*        add_str '<group id="GroupXML_SAP" label="Translation">'.
*        add_str ' <toggleButton idMso="XmlStructure"/>'.
*        add_str '</group>'.
*      add_str '</tab>'.
*    add_str '</tabs>'.
*  add_str '</ribbon>'.
*add_str '</customUI>'.




* create docx document instance
  doc = cl_docx_document=>create_document( ).


* insert customXML file
  IF form_context IS NOT INITIAL.

* get the maindocument part
  maindocumentPart = DOC->GET_MAINDOCUMENTPART( ).

* add a customXML part
    customXMLPart = MAINDOCUMENTPART->ADD_CUSTOMXMLPART( ).

* insert xml data
    customXMLPart->feed_data( form_context ).

* add customXML properties part

    customXMLPropsPart = customXMLPart->ADD_CUSTOMXMLPROPSPART( ).


* create GUID string
    preGUID = CL_OPENXML_HELPER=>create_guid_string( ).

* enclose with {...} brackets
    CONCATENATE '{' preGUID '}' INTO GUID.

* create custom XML property content
    CALL TRANSFORMATION DOCX_CREATE_CUSTOMPROPSCONTENT
    PARAMETERS GUID = GUID
    SOURCE XML form_context
    RESULT XML propertyXML.

    customXMLPropsPart->feed_data( propertyXML ).
** create customUI part
*   customuipart = doc->add_customuipart( ).
** get ribbon ui data
*   ribbon_ui = customuipart->get_data( ).
*
*   ribbon_ui = cl_openxml_helper=>string_to_xstring( ribbon_ui_str ).
**set ribbon UI data
*   customuipart->feed_data( ribbon_ui ).

  ENDIF.

** get document settings part
*  docSettingsPart = maindocumentPart->GET_DOCUMENTSETTINGSPART( ).
*
** get XML data
*  settingsXML = docSettingsPart->get_data( ).
*
** create GUID string
*    GUID = CL_OPENXML_HELPER=>create_guid_string( ).
*
*
** create custom XML property content
*    CALL TRANSFORMATION DOCX_CREATE_DOCUMENT_GUID
*    PARAMETERS GUID = GUID
*    SOURCE XML settingsXML
*    RESULT XML resultXML.
*
** set XML data
*  docSettingsPart->feed_data( resultXML ).


  docx = doc->get_package_data( ).


ENDMETHOD.


METHOD CREATE_PDFPREVIEW.
*  DATA: docx_allowed TYPE c.
*  CALL FUNCTION 'RSPO_OP_ALLOW_DOCX'
*    IMPORTING
*      docx_allowed = docx_allowed.
*
*  IF docx_allowed = ''.
*    RAISE EXCEPTION TYPE cx_docx_pdf_preview_err.
*  ENDIF.

* Spool Cleanup
*  CALL FUNCTION 'RSPO_DOCXPS_CREATEPDF'
*    EXPORTING
*      docxdoc  = im_docx_data
*    IMPORTING
*      pdfdoc   = ex_pdf_data
*      numpages = ex_numpages
*      errmsg   = ex_errstring
*    EXCEPTIONS
*      failure  = 1
*      OTHERS   = 2.
*  IF sy-subrc <> 0.
*    RAISE EXCEPTION TYPE cx_docx_pdf_preview_err.
*  ENDIF.

ENDMETHOD.


METHOD EXTRACT_TEXTS.
  DATA:   conv               TYPE REF TO cl_xsl_docx_fo_conv,
          merged_parts       TYPE xstring,
          texts_in_xliff                  TYPE xstring.

  IF document IS NOT INITIAL.
    CREATE OBJECT conv.

    TRY.
        CALL METHOD conv->merge_parts_xstring
          EXPORTING
            im_input  = document
          RECEIVING
            re_output = merged_parts.
      CATCH cx_merge_parts.
        RAISE EXCEPTION TYPE cx_docx_transformation_err.
    ENDTRY.

    TRY.
        CALL TRANSFORMATION docx_tr_extract
          SOURCE XML merged_parts
          RESULT XML texts_in_xliff.
      CATCH cx_transformation_error.
        RAISE EXCEPTION TYPE cx_docx_transformation_err.
    ENDTRY.
  ENDIF.
  texts = texts_in_xliff.

ENDMETHOD.


method GET_XSD_FILE.

DATA:   doc                TYPE REF TO cl_docx_document,
        maindocumentPart   TYPE REF TO cl_docx_Maindocumentpart,
        customXMLPart      TYPE REF TO cl_oxml_customxmlpart,
        propertyXML        TYPE XSTRING,
        customXMLPropsPart type ref to cl_oxml_customxmlpropspart,
        customXMLpartColl  type REF TO cl_openxml_partcollection,
        part               type ref to cl_openxml_part.

data:   num_of_customxml_files type i,
        found                  type abap_bool.



* load the document
    doc = cl_docx_document=>load_document( docx ).
* get the maindocument part
    maindocumentPart = DOC->GET_MAINDOCUMENTPART( ).

* get collection of customXML parts
    customXMLpartColl = maindocumentPart->get_customxmlparts( ).

* get number of customXML parts
    num_of_customxml_files = customXMLpartColl->get_count( ).

if num_of_customxml_files = 0.
  num_of_customxml_files = 1.
endif.

    found = abap_false.
    do num_of_customxml_files times.
* get customXML part
      part = customXMLpartColl->get_part( sy-index - 1 ).
* downcast
      customXMLPart ?= part.
* get customXML properties part
      customXMLPropsPart = customXMLPart->GET_CUSTOMXMLPROPSPART( ).
* get properties content
      propertyXML = customXMLPropsPart->get_data( ).
* check namespace reference
      If contains_customXML( namespace = 'http://www.sap.com/SAPForm/0.5'  customxml_props = propertyXML ) = abap_true
        and contains_customXML( namespace = 'http://www.w3.org/2001/XMLSchema'  customxml_props = propertyXML ) = abap_true.

        found = abap_true.
* replace schema file
        xsd_file = customXMLPart->get_data( ).
      endif.
    enddo.

    if found = abap_false.
      raise EXCEPTION TYPE cx_docx_form_not_found.
    endif.


endmethod.


method INSERT_XSD_FILE.

DATA:   doc                TYPE REF TO cl_docx_document,
        maindocumentPart   TYPE REF TO cl_docx_Maindocumentpart,
        customXMLPart      TYPE REF TO cl_oxml_customxmlpart,
        settingsPart       type ref to CL_DOCX_DOCUMENTSETTINGSPART,
        propertyXML        TYPE XSTRING,
        settingsXML        type xstring,
        mod_settingsXML    type xstring,
        customXMLPropsPart TYPE REF TO cl_oxml_customxmlpropspart,
        customXMLpartColl  type REF TO cl_openxml_partcollection,
        part               type ref to cl_openxml_part.

data:   num_of_customxml_files type i,
        preGUID                type string,
        GUID                   type string,
        found                  type abap_bool.

if cl_abap_char_utilities=>charsize = 1 or cl_abap_char_utilities=>charsize = 2.

  if docx is not initial.
* load the document
    doc = cl_docx_document=>load_document( docx ).

* get the maindocument part
    maindocumentPart = DOC->GET_MAINDOCUMENTPART( ).

* get collection of customXML parts
    customXMLpartColl = maindocumentPart->get_customxmlparts( ).

* get number of customXML parts
    num_of_customxml_files = customXMLpartColl->get_count( ).



        found = abap_false.
        do num_of_customxml_files times.
* get customXML part
          part = customXMLpartColl->get_part( sy-index - 1 ).
* downcast
          customXMLPart ?= part.
* get customXML properties part
          customXMLPropsPart = customXMLPart->GET_CUSTOMXMLPROPSPART( ).
* get properties content
          propertyXML = customXMLPropsPart->get_data( ).
* check namespace reference
          If contains_customXML( namespace = 'http://www.sap.com/SAPForm/0.5'  customxml_props = propertyXML ) = abap_true
          and contains_customXML( namespace = 'http://www.w3.org/2001/XMLSchema'  customxml_props = propertyXML ) = abap_true.

            found = abap_true.
* replace schema file
            customXMLPart->feed_data( xsd_file  ).


* create GUID string
            preGUID = CL_OPENXML_HELPER=>create_guid_string( ).

* enclose with {...} brackets
            CONCATENATE '{' preGUID '}' INTO GUID.

* create custom XML property content
            CALL TRANSFORMATION DOCX_CREATE_CUSTOMPROPSCONTENT
            PARAMETERS GUID = GUID
            SOURCE XML xsd_file
            RESULT XML propertyXML.

* replace properties file
            customXMLPropsPart->feed_data( propertyXML ).
          endif.

        enddo.

  if num_of_customxml_files = 0 or found = abap_false.
* no XSD customXML files in docx package -> create customXML part
* add a customXML part
        customXMLPart = MAINDOCUMENTPART->ADD_CUSTOMXMLPART( ).

* insert xml data
        customXMLPart->feed_data( xsd_file ).

* add customXML properties part
        customXMLPropsPart = customXMLPart->ADD_CUSTOMXMLPROPSPART( ).

* create GUID string
        preGUID = CL_OPENXML_HELPER=>create_guid_string( ).

* enclose with {...} brackets
        CONCATENATE '{' preGUID '}' INTO GUID.

* create custom XML property content
        CALL TRANSFORMATION DOCX_CREATE_CUSTOMPROPSCONTENT
        PARAMETERS GUID = GUID
        SOURCE XML xsd_file
        RESULT XML propertyXML.

        customXMLPropsPart->feed_data( propertyXML ).

  endif.


* set document state to "Changed"
* ===============================
* get document settings part
        settingsPart = maindocumentpart->GET_DOCUMENTSETTINGSPART( ).
*          catch CX_OPENXML_FORMAT.    "
*          catch CX_OPENXML_NOT_FOUND.    "

* settings XML
        settingsXML = settingsPart->GET_DATA( ).

* change doc state to "Changed"
        call transformation docx_set_documentstate
        parameters state = 'Changed' "#EC NOTEXT
        source xml settingsXML
        result xml mod_settingsXML .

        settingspart->FEED_DATA( mod_settingsxml ).

        docx_result = doc->get_package_data( ).


  else.
    docx_result = create_form( xsd_file ).
  endif.


else.
  RAISE EXCEPTION TYPE CX_DOCX_FORM_NOT_UNICODE.
endif.



endmethod.


METHOD merge_data.

  DATA: docx        TYPE REF TO cl_docx_document,
        xslt_name   TYPE string,
        ls_xsltattr TYPE o2xsltattr,
        lt_xslttab  TYPE o2pageline_table.

* Generate the docx.XSLT
  TRY.
      CALL METHOD cl_xsl_docx=>generate_transform
        EXPORTING
          im_formtemplate_data = im_formtemplate_data
          im_type              = 'W'
          im_delete_sdt_tags   = im_delete_sdt_tags
        RECEIVING
          re_xslt_tab          = lt_xslttab.
    CATCH cx_root.
  ENDTRY.
* Create name for the transformation
  CLEAR ls_xsltattr-xsltdesc.
  TRY.
      ls_xsltattr-xsltdesc = cl_system_uuid=>create_uuid_c26_static( ).
    CATCH cx_root.
  ENDTRY.
  CONCATENATE 'Z' ls_xsltattr-xsltdesc INTO ls_xsltattr-xsltdesc.

  ls_xsltattr-devclass = im_devclass.
  ls_xsltattr-author = sy-uname.

  CALL FUNCTION 'XSLT_MAINTENANCE'
    EXPORTING
      i_operation               = 'CREA_ACT'                "#EC NOTEXT
      i_xslt_attributes         = ls_xsltattr
      i_xslt_source             = lt_xslttab
      i_gen_flag                = abap_true
      i_suppress_corr_insert    = abap_true
      i_suppress_tree_placement = abap_true
    EXCEPTIONS
      invalid_name              = 1
      not_existing              = 2
      lock_failure              = 3
      permission_failure        = 4
      error_occured             = 5
      syntax_errors             = 6
      cancelled                 = 7
      data_missing              = 8
      version_not_found         = 9
      OTHERS                    = 10.

  IF sy-subrc <> 0.
    CALL FUNCTION 'XSLT_MAINTENANCE'
      EXPORTING
        i_operation               = 'MODI_ACT'              "#EC NOTEXT
        i_xslt_attributes         = ls_xsltattr
        i_xslt_source             = lt_xslttab
        i_gen_flag                = abap_true
        i_suppress_corr_insert    = abap_true
        i_suppress_tree_placement = abap_true
      EXCEPTIONS
        invalid_name              = 1
        not_existing              = 2
        lock_failure              = 3
        permission_failure        = 4
        error_occured             = 5
        syntax_errors             = 6
        cancelled                 = 7
        data_missing              = 8
        version_not_found         = 9
        OTHERS                    = 10.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE cx_docx_transformation_err.
    ENDIF.
  ENDIF.

* Generate the final docx
  xslt_name = ls_xsltattr-xsltdesc.
  TRY.
      CALL METHOD cl_xsl_docx=>generate_docx
        EXPORTING
          im_xslt_name         = xslt_name
          im_customxml_data    = im_customxml_data
          im_language          = im_language
          im_country           = im_country
          im_formtemplate_data = im_formtemplate_data
        RECEIVING
          re_docx              = re_merged_data.
    CATCH cx_root.
  ENDTRY.

* Delete the transformation since it is not needed any more.
  CALL FUNCTION 'XSLT_MAINTENANCE'
    EXPORTING
      i_operation               = 'DELETE'                  "#EC NOTEXT
      i_xslt_attributes         = ls_xsltattr
      i_gen_flag                = abap_true
      i_suppress_corr_insert    = abap_true
      i_suppress_tree_placement = abap_true
    EXCEPTIONS
      OTHERS                    = 1.

  IF sy-subrc <> 0.
    RAISE EXCEPTION TYPE cx_docx_transformation_err.
  ENDIF.

ENDMETHOD.


METHOD MERGE_TEXTS.

  DATA:   doc                TYPE REF TO cl_docx_document,
          part               TYPE REF TO cl_openxml_part,
          maindocumentpart   TYPE REF TO cl_docx_maindocumentpart,
          headerpart         TYPE REF TO cl_docx_headerpart,
          footerpart         TYPE REF TO cl_docx_footerpart,
          headerpartcoll     TYPE REF TO cl_openxml_partcollection,
          footerpartcoll     TYPE REF TO cl_openxml_partcollection.

  DATA:   maindocpart_content TYPE xstring,
          headerpart_xml      TYPE xstring,
          footerpart_xml      TYPE xstring.

  DATA: merged        TYPE xstring,
        tmp           TYPE xstring,
        sep1          TYPE xstring,
        sep2          TYPE xstring,
        texts_cut     TYPE xstring,
        document_cut  TYPE xstring,
        outer_counter TYPE i.

  IF document IS NOT INITIAL.
* load the document
    doc = cl_docx_document=>load_document( document ).

* get the maindocument part
    maindocumentpart = doc->get_maindocumentpart( ).

* get the document.xml
    CALL METHOD maindocumentpart->get_data
      RECEIVING
        rv_data = maindocpart_content.


    sep1 = '3F3E'. " '?>'
    sep2 = '3C2F773A646F63756D656E743E'. " '</w:document>'
    SPLIT texts AT sep1 INTO tmp texts_cut IN BYTE MODE.
    SPLIT maindocpart_content AT sep2 INTO document_cut tmp IN BYTE MODE.
    CONCATENATE document_cut texts_cut sep2 INTO tmp IN BYTE MODE.

    TRY.
        CALL TRANSFORMATION docx_tr_merge
          SOURCE XML tmp
          RESULT XML merged.
      CATCH cx_transformation_error.
        RAISE EXCEPTION TYPE cx_docx_transformation_err.
    ENDTRY.

* feed the document with new data

    CALL METHOD maindocumentpart->feed_data
      EXPORTING
        iv_data = merged.


* get header parts
    headerpartcoll = maindocumentpart->get_headerparts( ).
*    catch CX_OPENXML_FORMAT.  "

    outer_counter = 0.
    DO headerpartcoll->get_count( ) TIMES.
      CLEAR tmp.
      part = headerpartcoll->get_part( outer_counter ).
      headerpart ?= part.

* get the header<x>.xml
      CALL METHOD headerpart->get_data
        RECEIVING
          rv_data = headerpart_xml.

      sep1 = '3F3E'. " '?>'
      sep2 = '3C2F773A6864723E'. " '</w:hdr>'
      SPLIT texts AT sep1 INTO tmp texts_cut IN BYTE MODE.
      SPLIT headerpart_xml AT sep2 INTO document_cut tmp IN BYTE MODE.
      CONCATENATE document_cut texts_cut sep2 INTO tmp IN BYTE MODE.

      TRY.
          CALL TRANSFORMATION docx_tr_merge
            SOURCE XML tmp
            RESULT XML merged.
        CATCH cx_transformation_error.
          RAISE EXCEPTION TYPE cx_docx_transformation_err.
      ENDTRY.

*   feed the document with new data
      CALL METHOD headerpart->feed_data
        EXPORTING
          iv_data = merged.

      outer_counter = outer_counter + 1 .
    ENDDO.

* get footer parts
    footerpartcoll = maindocumentpart->get_footerparts( ).
*    catch CX_OPENXML_FORMAT.  "

    outer_counter = 0.
    DO footerpartcoll->get_count( ) TIMES.
      CLEAR tmp.
      part = footerpartcoll->get_part( outer_counter ).
      footerpart ?= part.

* get the header<x>.xml
      CALL METHOD footerpart->get_data
        RECEIVING
          rv_data = footerpart_xml.

      sep1 = '3F3E'. " '?>'
      sep2 = '3C2F773A6674723E'. " '</w:ftr>'
      SPLIT texts AT sep1 INTO tmp texts_cut IN BYTE MODE.
      SPLIT footerpart_xml AT sep2 INTO document_cut tmp IN BYTE MODE.
      CONCATENATE document_cut texts_cut sep2 INTO tmp IN BYTE MODE.

      TRY.
          CALL TRANSFORMATION docx_tr_merge
            SOURCE XML tmp
            RESULT XML merged.
        CATCH cx_transformation_error.
          RAISE EXCEPTION TYPE cx_docx_transformation_err.
      ENDTRY.

*   feed the document with new data
      CALL METHOD footerpart->feed_data
        EXPORTING
          iv_data = merged.

      outer_counter = outer_counter + 1 .
    ENDDO.



* pack document into zip file
    merged_document = doc->get_package_data( ).
  ENDIF.

ENDMETHOD.


METHOD PRINT_DOCX.
* Spool Cleanup
*  CALL FUNCTION 'RSPO_DOCXPS_PRINT'
*    EXPORTING
*      docxdoc      = im_docx_data
*      printer      = im_printer
*      copies       = im_copies
*      name         = im_name
*      suffix1      = im_suffix1
*      suffix2      = im_suffix2
*      newid        = im_newid
*      immed        = im_immed
*      delete       = im_delete
*      final        = im_final
*      lifetime     = im_lifetime
*      title        = im_title
*      receiver     = im_receiver
*      division     = im_division
*      auth         = im_auth
*      coverpage    = im_coverpage
*      printoptions = im_printoptions
*    IMPORTING
*      spoolid      = ex_spoolid
*      numpages     = ex_numpages
*      errmsg       = ex_errstring
*    EXCEPTIONS
*      failure      = 1
*      OTHERS       = 2.
*  IF sy-subrc <> 0.
*    RAISE EXCEPTION TYPE cx_docx_print_error.
*  ENDIF.

ENDMETHOD.


METHOD REPLACE_XML_DATA_FILE.

  DATA:   doc                TYPE REF TO cl_docx_document,
          maindocumentpart   TYPE REF TO cl_docx_maindocumentpart,
          customxmlpart      TYPE REF TO cl_oxml_customxmlpart,
          propertyxml        TYPE xstring,
          customxmlpropspart TYPE REF TO cl_oxml_customxmlpropspart,
          customxmlpartcoll  TYPE REF TO cl_openxml_partcollection,
          part               TYPE REF TO cl_openxml_part.

  DATA:   num_of_customxml_files TYPE i,
          preguid                TYPE string,
          guid                   TYPE string,
          found                  TYPE abap_bool.

  IF cl_abap_char_utilities=>charsize = 1 OR cl_abap_char_utilities=>charsize = 2.

    IF docx IS NOT INITIAL.
* load the document

      doc = cl_docx_document=>load_document( docx ).

* get the maindocument part
      TRY.
          maindocumentpart = doc->get_maindocumentpart( ).
        CATCH cx_root.
      ENDTRY.
      TRY.
* get collection of customXML parts
          customxmlpartcoll = maindocumentpart->get_customxmlparts( ).
        CATCH cx_root.
      ENDTRY.
* get number of customXML parts
      num_of_customxml_files = customxmlpartcoll->get_count( ).

      found = abap_false.
      DO num_of_customxml_files TIMES.
* get customXML part
        part = customxmlpartcoll->get_part( sy-index - 1 ).
* downcast
        customxmlpart ?= part.
        TRY.
* get customXML properties part
            customxmlpropspart = customxmlpart->get_customxmlpropspart( ).
          CATCH cx_root.
        ENDTRY.
        TRY.
* get properties content
            propertyxml = customxmlpropspart->get_data( ).
          CATCH cx_root.
        ENDTRY.
* check namespace reference
        IF contains_customxml( namespace = 'http://www.sap.com/SAPForm/0.5'  customxml_props = propertyxml ) = abap_true
          AND contains_customxml( namespace = 'http://www.w3.org/2001/XMLSchema'  customxml_props = propertyxml ) = abap_false.

          found = abap_true.

* replace xml data file
          customxmlpart->feed_data( xml_data  ).

* create GUID string
          preguid = cl_openxml_helper=>create_guid_string( ).

* enclose with {...} brackets
          CONCATENATE '{' preguid '}' INTO guid.

* create custom XML property content
          CALL TRANSFORMATION docx_create_custompropscontent
            PARAMETERS guid = guid
            SOURCE XML xml_data
            RESULT XML propertyxml.

* replace properties file
          customxmlpropspart->feed_data( propertyxml ).

        ENDIF.
* create zip file
        docx_result = doc->get_package_data( ).
      ENDDO.

      IF found = abap_true.
* create zip file
        docx_result = doc->get_package_data( ).
      ELSE.
        RAISE EXCEPTION TYPE cx_docx_form_not_found.
      ENDIF.

    ELSE.
      RAISE EXCEPTION TYPE cx_docx_form_not_found.
    ENDIF.


  ELSE.
    RAISE EXCEPTION TYPE cx_docx_form_not_unicode.
  ENDIF.



ENDMETHOD.


METHOD RE_MERGE_DOCUMENT.
  DATA:
        doc                TYPE REF TO cl_docx_document,
        maindocumentpart   TYPE REF TO cl_docx_maindocumentpart,
        customxmlpart      TYPE REF TO cl_oxml_customxmlpart,
        propertyxml        TYPE xstring,
        customxmlpropspart TYPE REF TO cl_oxml_customxmlpropspart,
        customxmlpartcoll  TYPE REF TO cl_openxml_partcollection,
        part               TYPE REF TO cl_openxml_part,
        customxml_data TYPE xstring.

  DATA: num_of_customxml_files TYPE i,
        found                  TYPE abap_bool.


  IF im_docx_document IS NOT INITIAL.
**Get the XML file first
* load the document
    TRY.
        doc = cl_docx_document=>load_document( im_docx_document ).
      CATCH cx_root.
    ENDTRY.
    TRY.
* get the maindocument part

        maindocumentpart = doc->get_maindocumentpart( ).
      CATCH cx_root.
    ENDTRY.
    TRY.
* get collection of customXML parts
        customxmlpartcoll = maindocumentpart->get_customxmlparts( ).
      CATCH cx_root.
    ENDTRY.
* get number of customXML parts
    num_of_customxml_files = customxmlpartcoll->get_count( ).

    found = abap_false.
    DO num_of_customxml_files TIMES.
* get customXML part
      part = customxmlpartcoll->get_part( sy-index - 1 ).
* downcast
      customxmlpart ?= part.
      TRY.
* get customXML properties part
          customxmlpropspart = customxmlpart->get_customxmlpropspart( ).
        CATCH cx_root.
      ENDTRY.
      TRY.
* get properties content
          propertyxml = customxmlpropspart->get_data( ).
        CATCH cx_root.
      ENDTRY.
* check namespace reference
      IF contains_customxml( namespace = 'http://www.sap.com/SAPForm/0.5'  customxml_props = propertyxml ) = abap_true
        AND contains_customxml( namespace = 'http://www.w3.org/2001/XMLSchema'  customxml_props = propertyxml ) = abap_false.

        found = abap_true.
        TRY.
* replace xml data file
            customxml_data = customxmlpart->get_data( ) .
          CATCH cx_root.
        ENDTRY.
        EXIT.
      ENDIF.
    ENDDO.
  ENDIF.
  TRY.
      re_merged_document = cl_docx_form=>merge_data( im_formtemplate_data = im_docx_new_change
             im_customxml_data    = customxml_data
             im_country = im_country
             im_language = im_language ).
    CATCH cx_root.
  ENDTRY.
ENDMETHOD.


METHOD SET_SAP_FORM_USER.
  DATA:
  l_document           TYPE REF TO cl_docx_document,
  l_maindocumentpart   TYPE REF TO cl_docx_maindocumentpart,
  l_settingspart       TYPE REF TO cl_docx_documentsettingspart,
  l_settings TYPE xstring,
  l_re_settings TYPE xstring.

  TRY.
      l_document = cl_docx_document=>load_document( im_docx ).
    CATCH cx_openxml_format .
      CLEAR re_docx.
      RETURN.
  ENDTRY.

* get the maindocument part
  TRY.
      l_maindocumentpart = l_document->get_maindocumentpart( ).
    CATCH cx_openxml_not_found .
      CLEAR re_docx.
      RETURN.
    CATCH cx_openxml_format .
      CLEAR re_docx.
      RETURN.
  ENDTRY.
* get document settings part
  TRY.
      l_settingspart = l_maindocumentpart->get_documentsettingspart( ).
    CATCH cx_openxml_not_found .
      CLEAR re_docx.
      RETURN.
    CATCH cx_openxml_format .
      CLEAR re_docx.
      RETURN.
  ENDTRY.
* settings XML data
  l_settings = l_settingspart->get_data( ).

* change SAP form user according to the input im_user
  TRY.
      CALL TRANSFORMATION docx_set_sap_form_user
      PARAMETERS user = im_user
      SOURCE XML l_settings
      RESULT XML l_re_settings .
    CATCH cx_transformation_error.
      RAISE EXCEPTION TYPE cx_docx_transformation_err.
  ENDTRY.
  l_settingspart->feed_data( l_re_settings ).

  TRY.
      re_docx = l_document->get_package_data( ).
    CATCH cx_openxml_format .
      CLEAR re_docx.
  ENDTRY.
ENDMETHOD.


METHOD UPDATE_TRANSLATION.

  DATA ex_texts TYPE xstring.

* It is used when the layout changes in formbuilder.???
* extract texts from old_template
  TRY.
      CALL METHOD cl_docx_form=>extract_texts
        EXPORTING
          document = old_docx_templ
        RECEIVING
          texts    = ex_texts.
    CATCH cx_docx_transformation_err .
    CATCH cx_openxml_format .
    CATCH cx_openxml_not_found .
  ENDTRY.

* merge extracted texts into new docx template
  TRY.
      CALL METHOD cl_docx_form=>merge_texts
        EXPORTING
          document        = new_docx_templ
          texts           = ex_texts
        RECEIVING
          merged_document = upd_docx_templ.
    CATCH cx_docx_transformation_err .
    CATCH cx_openxml_format .
    CATCH cx_openxml_not_found .
  ENDTRY.


ENDMETHOD.


method UPDATE_TRANSLATION_TAGS.

  DATA:   doc                TYPE REF TO cl_docx_document,
          part               type ref to cl_openxml_part,
          maindocumentPart   TYPE REF TO cl_docx_Maindocumentpart,
          headerpart         type ref to cl_docx_headerpart,
          footerpart         type ref to CL_DOCX_FOOTERPART,
          headerpartcoll     type ref to cl_openxml_partcollection,
          footerpartcoll     type ref to cl_openxml_partcollection.

  data: t                   type xstring,
        maindocpart_xml     type xstring,
        headerpart_xml      type xstring,
        footerpart_xml      type xstring.

  data: outer_counter type i.

if docx_template is not initial.
* load the document
  doc = cl_docx_document=>load_document( docx_template ).

* get the maindocument part
    maindocumentPart = DOC->GET_MAINDOCUMENTPART( ).

* get the document.xml
    CALL METHOD maindocumentpart->GET_DATA
      RECEIVING
        RV_DATA = maindocpart_xml
        .


* create unique <w:customXml> tags for translation relevant texts
  try.
      call transformation docx_tr_update_tags
        source xml maindocpart_xml
        result xml t.
    catch cx_transformation_error.
      raise exception type cx_docx_transformation_err.
  endtry.

* feed the document with new data

  CALL METHOD maindocumentpart->FEED_DATA
    EXPORTING
      IV_DATA = t
      .


* get header parts
  headerpartcoll = maindocumentpart->GET_HEADERPARTS( ).
*    catch CX_OPENXML_FORMAT.  "

  outer_counter = 0.
  do headerpartcoll->GET_COUNT( ) times.
    part = headerpartcoll->GET_PART( outer_counter ).
    headerpart ?= part.

* get the header<x>.xml
    CALL METHOD headerpart->GET_DATA
      RECEIVING
        RV_DATA = headerpart_xml
        .

* create unique <w:customXml> tags for translation relevant texts
  try.
      call transformation docx_tr_update_tags
        source xml headerpart_xml
        result xml t.
    catch cx_transformation_error.
      raise exception type cx_docx_transformation_err.
  endtry.

* feed the document with new data

  CALL METHOD headerpart->FEED_DATA
    EXPORTING
      IV_DATA = t
      .

    outer_counter = outer_counter + 1 .
  enddo.

* get footer parts
  footerpartcoll = maindocumentpart->GET_FOOTERPARTS( ).
*    catch CX_OPENXML_FORMAT.  "

  outer_counter = 0.
  do footerpartcoll->GET_COUNT( ) times.
    part = footerpartcoll->GET_PART( outer_counter ).
    footerpart ?= part.

* get the footer<x>.xml
    CALL METHOD footerpart->GET_DATA
      RECEIVING
        RV_DATA = footerpart_xml
        .

* create unique <w:customXml> tags for translation relevant texts
  try.
      call transformation docx_tr_update_tags
        source xml footerpart_xml
        result xml t.
    catch cx_transformation_error.
      raise exception type cx_docx_transformation_err.
  endtry.

* feed the document with new data

  CALL METHOD footerpart->FEED_DATA
    EXPORTING
      IV_DATA = t
      .

    outer_counter = outer_counter + 1 .
  enddo.


* build the package
  docx_template = doc->get_package_data( ).

endif.

endmethod.
ENDCLASS.
