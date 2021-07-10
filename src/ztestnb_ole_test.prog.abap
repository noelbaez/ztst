REPORT zole_test.

INCLUDE ole2incl.

DATA: gs_word TYPE ole2_object,
gs_docs TYPE ole2_object,
gs_doc TYPE ole2_object,
gs_selection TYPE ole2_object.

PARAMETERS: p_file(100) LOWER CASE DEFAULT 'c:\temp\testA.docx'.

START-OF-SELECTION.

CREATE OBJECT gs_word 'WORD.APPLICATION'.
*SET PROPERTY OF gs_word 'VISIBLE' = '0'.

CALL METHOD OF gs_word 'Documents' = gs_docs.
*CALL METHOD OF gs_docs 'Add' = gs_doc.
*CALL METHOD OF gs_doc 'Activate'.

CALL METHOD OF gs_docs 'Open' = gs_doc EXPORTING #1 = p_file.

** Gets the cursor position
GET PROPERTY OF gs_word 'SELECTION' = gs_selection.

** To display text in 1st page
CALL METHOD OF gs_selection 'TYPETEXT'
EXPORTING
#1 = 'This is the Page One text!'.

** Inserts a page break
CALL METHOD OF gs_selection 'INSERTBREAK'.

** To display text in 2nd page
CALL METHOD OF gs_selection 'TYPETEXT'
EXPORTING
#1 = 'This is the Page Two text!'.

** Save Word document
*Please change the path of the file appropriately
CALL METHOD OF gs_doc 'SaveAs' EXPORTING #1 = 'C:\Temp\TestA_1.PDF' #2 = 17.
CALL METHOD OF gs_doc 'ExportAsFixedFormat' EXPORTING #1 = 'c:\temp\TestA_2.pdf' #2 = '17'.
CALL METHOD OF gs_word 'Quit'.

FREE OBJECT gs_word.
