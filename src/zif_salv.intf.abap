interface ZIF_SALV
  public .


  types:
    begin of ty_header,
      typ(1),"T-Title, space=normal
      row       type i,
      col       type i,
      label     type string,
      text      type string,
      tooltip   type string,
      addrow(1),"add row after
      logo      type string,
    end of ty_header .
  types:
    tt_header type table of ty_header .
  types:
    begin of ty_colattr,
      colname type lvc_fname,
      stext   type scrtext_s,
      mtext   type scrtext_m,
      ltext   type scrtext_l,
      currcol type lvc_cfname,
      color   type lvc_s_colo,
    end of   ty_colattr .
  types:
    tt_colattr type table of ty_colattr .

  data OSALV type ref to CL_SALV_TABLE .

  methods DISPLAY_DATA
    importing
      !LS_KEY type SALV_S_LAYOUT_KEY optional
      !L_VARI type SLIS_VARI optional
      !LT_COLATTR type TT_COLATTR optional
      !LT_HEADER type TT_HEADER optional
      !OHANDLER type ref to ZIF_SALV_HANDLER optional
      !L_TITLE type LVC_TITLE optional
      !L_REPORT type SYREPID optional
      !L_STATUS type SYPFKEY optional
    changing
      !C_DATA type TABLE .
  methods SET_COLTEXTS
    importing
      !LT_COLATTR type TT_COLATTR .
  methods BUILD_HEADER
    importing
      !IT_HEADER type TT_HEADER
    changing
      !LR_CONTENT type ref to CL_SALV_FORM_ELEMENT .
endinterface.
