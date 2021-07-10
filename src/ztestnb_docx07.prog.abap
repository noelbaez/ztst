REPORT ztestnb_DOCX07.

INCLUDE ole2incl.
DATA gs_word TYPE ole2_object.
DATA gs_docs TYPE ole2_object.
DATA gs_doc  TYPE ole2_object.
DATA gs_actdoc  TYPE ole2_object.
DATA gs_selection TYPE ole2_object.

PARAMETERS: p_file(100) LOWER CASE DEFAULT 'c:\temp\Formato1.docx' OBLIGATORY.
START-OF-SELECTION.
split p_file at '.' into data(filename) data(extension).

"Test with open -----
CREATE OBJECT gs_word 'WORD.APPLICATION'.
SET PROPERTY OF gs_word 'Visible' = '0' .
CALL METHOD OF gs_word 'Documents' = gs_doc.

CALL METHOD OF gs_doc 'Open' = gs_doc EXPORTING #1 = p_file.

"Export
*CALL METHOD OF gs_doc 'SaveAs' EXPORTING #1 = 'C:\temp\Testa.pdf' #2 = 17.
filename = |{ filename }.pdf|.
CALL METHOD OF gs_doc 'ExportAsFixedFormat' EXPORTING #1 = filename  #2 = '17'.

"Print
*CALL METHOD OF gs_word 'ActiveDocument' = gs_actdoc.
*CALL METHOD OF gs_actdoc 'PrintOut' .
*CALL METHOD OF gs_word 'ActiveDocument' = gs_doc.
*CALL METHOD OF gs_doc 'PrintOut' .

CALL METHOD OF gs_word 'Quit'.

END-OF-SELECTION.

  FREE OBJECT: gs_word, gs_docs, gs_doc, gs_actdoc, gs_selection.

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
