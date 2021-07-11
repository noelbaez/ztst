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
           tt_demo TYPE TABLE OF ty_demo WITH EMPTY KEY,

           BEGIN OF ty_company,
             bukrs TYPE STRING,
             butxt TYPE STRING,
           END OF ty_company,
           tt_company TYPE TABLE OF ty_company WITH EMPTY KEY.

    TYPES: BEGIN OF ty_demo_deep,
             f1        TYPE string,
             f2        TYPE string,
             f3        TYPE string,
             items     TYPE tt_demo,
             companies TYPE tt_company,
           END OF ty_demo_deep.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_TEST IMPLEMENTATION.
ENDCLASS.
