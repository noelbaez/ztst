report ztestnb_conv.
parameters : str   type string default '{28A0092B-C50C-407E-A947-70E740481C1C}'.
parameters : xstr1(200) type x.

data :
  x    type xstring value '7B32384130303932422D433530432D343037452D413934372D3730453734303438314331437D',
  y    type xstring value '7B7B32384130303932422D433530432D343037452D413934372D3730453734303438314331437D7D',
  xstr type xstring,
  strc type string.

if str is not initial.
  " converting string to xstring *
  call function 'SCMS_STRING_TO_XSTRING'
    exporting
      text   = str
    importing
      buffer = xstr.

  write :/ 'string:', str.
  write :/ 'xstring:',xstr.

*  replace all occurrences of x in xstr with y in byte mode.
  uline.

  " converting xstring to string *
  call method cl_abap_conv_in_ce=>create
    exporting
      input = xstr    " input buffer (x, xstring)
    receiving
      conv  = data(lr_conv).

  lr_conv->read(
  importing  data    = strc ).    " data object to be read

  write :/ 'xstring:', xstr.
  write :/ 'string:',strc.
endif.

if xstr1 is not initial.
  xstr = xstr1.
  cl_bcs_convert=>xstring_to_string(
    exporting
      iv_xstr   = xstr
      iv_cp     = 1100                " SAP character set identification
    receiving
      rv_string = strc
  ).

  write :/ 'xstring:', xstr.
  write :/ 'string:',strc.

endif.
