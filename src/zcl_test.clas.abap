CLASS zcl_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_demo,
             name      TYPE string,
             last_name TYPE string,
             date      TYPE string,
           END OF ty_demo,
           tt_demo TYPE TABLE OF ty_demo.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_TEST IMPLEMENTATION.
ENDCLASS.
