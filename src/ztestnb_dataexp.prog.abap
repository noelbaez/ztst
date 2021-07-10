*&---------------------------------------------------------------------*
*& Report ZTESTNB_DATAEXP
*&---------------------------------------------------------------------*
report ztestnb_datae.
*CONSTANTS c_buk TYPE bkpf-bukrs VALUE 'D001'.

include ztestnb_datae_sel.

start-of-selection.

  case abap_true.
    when p_export.
      select * from usr01 into table @data(it_usr01). perform export_data using it_usr01 'usr01'.

    when p_import.
*      perform import_data using 'usr01' it_usr01.  modify usr01 from table it_usr01.


    when others.
  endcase.

  include ztestnb_datae_f01.
