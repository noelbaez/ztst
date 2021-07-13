report ztestnb_docx.
include ole2incl.
data gs_word type ole2_object.
data gs_docs type ole2_object.
data gs_doc  type ole2_object.
data gs_actdoc  type ole2_object.
data gs_selection type ole2_object.

*parameters: p_file(100) lower case default 'c:\temp\testa.docx'.

"Test with open -----
create object gs_word 'WORD.APPLICATION'.
*create object gs_word 'Word.Document.12'.
set property of gs_word 'Visible' = '0' .
call method of gs_word 'Documents' = gs_doc.

data gv_url type string value 'r3mime:/sap/public/invoice1.docx'.
cl_fxs_url_data_fetcher=>fetch(
  exporting
    iv_url          = gv_url
*    iv_nocache      = abap_false
  importing
    ev_content      = data(lv_stream)
    ev_content_type = data(ev_ctype)
    ev_error        = data(ev_error)
).
data(doc_size) = xstrlen( lv_stream ).
data(doc_table) = cl_bcs_convert=>xstring_to_solix( iv_xstring = lv_stream  ).

data doc_url(200).
call function 'DP_CREATE_URL'
  exporting
    type    = 'application'
    subtype = 'x-oleobject'
    size    = doc_size
  tables
    data    = doc_table
  changing
    url     = doc_url.

 CALL FUNCTION 'DP_SYNC_URLS'
      EXCEPTIONS
        CNTL_ERROR         = 1
        CNTL_SYSTEM_ERROR  = 2
        DP_CREATE_ERROR    = 3
        DATA_SOURCE_ERROR  = 4
        DP_SEND_DATA_ERROR = 5
        GENERAL_ERROR      = 6
        OTHERS             = 7.

*call method of gs_doc 'OpenDocument' = gs_doc
CALL METHOD OF gs_doc 'Open' = gs_doc
exporting #1 = doc_url
*exporting #1 = 'Word.Document.12'
*          #2 = 'OLE'
*          #3 = doc_url
*          #4 = -2
*          #5 = 1
.

"Export
*CALL METHOD OF gs_doc 'SaveAs' EXPORTING #1 = 'C:\temp\Testa.pdf' #2 = 17.
*CALL METHOD OF gs_doc 'ExportAsFixedFormat' EXPORTING #1 = 'c:\temp\testb.pdf' #2 = '17'.

"Print
*CALL METHOD OF gs_word 'ActiveDocument' = gs_actdoc.
*CALL METHOD OF gs_actdoc 'PrintOut' .
call method of gs_word 'ActiveDocument' = gs_doc.
call method of gs_doc 'PrintOut' .

call method of gs_word 'Quit'.

end-of-selection.

  free object: gs_word, gs_docs, gs_doc, gs_actdoc, gs_selection.

  "Test with creation, modification
*CREATE OBJECT gs_word 'WORD.APPLICATION'.
*SET PROPERTY OF gs_word 'VISIBLE' = '0'.
*
*CALL METHOD OF gs_word 'Documents' = gs_docs.
*CALL METHOD OF gs_docs 'Add' = gs_doc.
*CALL METHOD OF gs_doc 'Activate'.
*
*** Gets the cursor position
*GET PROPERTY OF gs_word 'SELECTION' = gs_selection.
*
*** To display text in 1st page
*CALL METHOD OF gs_selection 'TYPETEXT'
*EXPORTING
*#1 = 'This is the Page One text!'.
*
*** Inserts a page break
*CALL METHOD OF gs_selection 'INSERTBREAK'.
*
*** To display text in 2nd page
*CALL METHOD OF gs_selection 'TYPETEXT'
*EXPORTING
*#1 = 'This is the Page Two text!'.
*
*** Save Word document
*CALL METHOD OF gs_doc 'SaveAs' EXPORTING #1 = 'C:\Temp\TestA_1.PDF' #2 = 17.
*CALL METHOD OF gs_doc 'ExportAsFixedFormat' EXPORTING #1 = 'c:\temp\TestA_2.pdf' #2 = '17'.
*CALL METHOD OF gs_word 'Quit'.
*
*FREE OBJECT gs_word.
