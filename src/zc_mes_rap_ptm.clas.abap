CLASS zc_mes_rap_ptm DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_abap_behv_message .
    INTERFACES if_t100_dyn_msg .
    INTERFACES if_t100_message .

    METHODS constructor
      IMPORTING im_textid    TYPE scx_t100key OPTIONAL
                im_serverity TYPE if_abap_behv_message=>t_severity OPTIONAL
                im_fieldname TYPE char72 OPTIONAL.

    CONSTANTS:
      BEGIN OF c_notavailable_s,
        msgid TYPE symsgid VALUE 'ZMC_RAP_PTM',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF c_notavailable_s,

      BEGIN OF c_issuewarning_w,
        msgid TYPE symsgid VALUE 'ZMC_RAP_PTM',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF c_issuewarning_w,

      BEGIN OF c_validfname_e,
        msgid TYPE symsgid VALUE 'ZMC_RAP_PTM',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE 'FIELDNAME',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF c_validfname_e,

      BEGIN OF c_setadmitted_s,
        msgid TYPE symsgid VALUE 'ZMC_RAP_PTM',
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF c_setadmitted_s.

    DATA: !fieldname TYPE char72.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS ZC_MES_RAP_PTM IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor( ).

    me->if_t100_message~t100key         = im_textid.
    me->if_abap_behv_message~m_severity = im_serverity.

    IF im_fieldname IS NOT INITIAL.
      me->fieldname = im_fieldname.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
