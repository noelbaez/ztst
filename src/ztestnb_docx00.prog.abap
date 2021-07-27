report ztestnb_docx00.
include ole2incl.
data gs_word type ole2_object.
data gs_docs type ole2_object.
data gs_doc  type ole2_object.
data gs_actdoc  type ole2_object.
data gs_selection type ole2_object.

parameters: p_file(100) lower case default 'c:\temp\Table_result.docx'.
*parameters: p_file2(100) lower case default 'c:\temp\Template4.docx'.

start-of-selection.
  get run time field data(t1).
  "Test with open -----
  create object gs_word 'WORD.APPLICATION'.
  set property of gs_word 'Visible' = '0' .

  call method of gs_word 'Documents' = gs_doc.
  call method of gs_doc 'Open' = gs_doc
  exporting #1 = p_file
  .
  "Export
*CALL METHOD OF gs_doc 'SaveAs' EXPORTING #1 = 'C:\temp\Testa.pdf' #2 = 17.
  call method of gs_doc 'ExportAsFixedFormat' exporting #1 = 'c:\temp\Table_result.pdf' #2 = '17'.

  "Print
*CALL METHOD OF gs_word 'ActiveDocument' = gs_actdoc.
**CALL METHOD OF gs_actdoc 'PrintOut' .
*call method of gs_word 'ActiveDocument' = gs_doc.
*call method of gs_doc 'PrintOut' .

*  call method of gs_word 'Close'.
  call method of gs_word 'Quit'.

end-of-selection.

  free object: gs_word, gs_docs, gs_doc, gs_actdoc, gs_selection.
  get run time field data(t2).
  t2 = t2 - t1.
  message s000(fb) with 'Execution time'  t2  'microseconds'.
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
