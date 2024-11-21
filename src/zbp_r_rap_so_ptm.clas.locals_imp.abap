*=========================================================================================*
*                                                                                         *
* Local Handle Class for Sales Order                                                      *
*                                                                                         *
*=========================================================================================*
CLASS lhc_salesorder DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS set_not_available FOR MODIFY
      IMPORTING keys FOR ACTION salesorder~set_not_available RESULT result.             " Instance Action

    METHODS issue_warning FOR MODIFY
      IMPORTING keys FOR ACTION salesorder~issue_warning.                               " Static Action

    METHODS validate_fields FOR VALIDATE ON SAVE
      IMPORTING keys FOR salesorder~validate_fields.                                    " Validation for fields

    METHODS set_value_soldtoparty FOR DETERMINE ON MODIFY
      IMPORTING keys FOR salesorder~set_value_soldtoparty.                              " Determination for fields

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR salesorder RESULT result.           " Feature Control

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE salesorder.                                         " Early Numbering for field

ENDCLASS.

CLASS lhc_salesorder IMPLEMENTATION.

*=============================================================================*
* Instance Action for NotAvailable field                                      *
*=============================================================================*
  METHOD set_not_available.
    DATA: lo_msg TYPE REF TO if_abap_behv_message.      "Khai bao lo_msg

    READ ENTITIES OF zr_rap_so_ptm IN LOCAL MODE
        ENTITY salesorder
        ALL FIELDS WITH
        CORRESPONDING #( keys )
    RESULT DATA(lt_salesorder).

    LOOP AT lt_salesorder ASSIGNING FIELD-SYMBOL(<lfs_salesorder>).
      IF <lfs_salesorder>-notavailable = abap_false.
        <lfs_salesorder>-notavailable = 'X'.
      ENDIF.

      "Update field NotAvailable
      MODIFY ENTITIES OF zr_rap_so_ptm IN LOCAL MODE
          ENTITY salesorder
          UPDATE FIELDS ( notavailable )
          WITH VALUE #( FOR key IN keys ( %tky = key-%tky
                                          notavailable = <lfs_salesorder>-notavailable )  )      "Is Not Available
          FAILED DATA(ls_failed)
          REPORTED DATA(ls_reported)
          MAPPED DATA(ls_mapped).

      IF ls_failed IS INITIAL.
        "Update Result
        result = VALUE #( BASE result (  %tky   = <lfs_salesorder>-%tky
                                         %param = <lfs_salesorder>  )  ).

        "Mapping lo_msg
        lo_msg = NEW zc_mes_rap_ptm( im_textid    = zc_mes_rap_ptm=>c_notavailable_s
                                     im_serverity = if_abap_behv_message=>severity-success ).

        "Output Message
        reported-salesorder = VALUE #( BASE reported-salesorder ( %tky = <lfs_salesorder>-%tky
                                                                  %msg = lo_msg  )  ).
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

*=============================================================================*
* Process Warning Message                                                     *
*=============================================================================*
  METHOD issue_warning.
    DATA: lo_msg TYPE REF TO if_abap_behv_message.

    "Output Message
    lo_msg = NEW zc_mes_rap_ptm( im_textid    = zc_mes_rap_ptm=>c_issuewarning_w
                                 im_serverity = if_abap_behv_message=>severity-warning ).

    APPEND lo_msg TO reported-%other.
  ENDMETHOD.

*=============================================================================*
* Validate Sales Order field                                                  *
*=============================================================================*
  METHOD validate_fields.
    "Read relevant instance data
    READ ENTITIES OF zr_rap_so_ptm IN LOCAL MODE
      ENTITY salesorder
        ALL FIELDS WITH
        CORRESPONDING #( keys )
      RESULT DATA(lt_salesorder).

    LOOP AT lt_salesorder INTO DATA(ls_salesorder).
      " Clear Message
      APPEND VALUE #( %tky        = ls_salesorder-%tky
                      %state_area = 'orderdate'
                    ) TO reported-salesorder.

      APPEND VALUE #( %tky        = ls_salesorder-%tky
                      %state_area = 'currency'
                    ) TO reported-salesorder.

      APPEND VALUE #( %tky        = ls_salesorder-%tky
                      %state_area = 'taxamount'
                    ) TO reported-salesorder.

      IF ls_salesorder-orderdate IS INITIAL.
        " Fill Key error Key
        APPEND VALUE #( %tky = ls_salesorder-%tky ) TO failed-salesorder.

        " Fill Message for required field
        APPEND VALUE #( %tky = ls_salesorder-%tky
                        %msg = NEW zc_mes_rap_ptm( im_textid    = zc_mes_rap_ptm=>c_validfname_e
                                                   im_serverity = if_abap_behv_message=>severity-error
                                                   im_fieldname = 'Order Date'  )           " Dynamic text
                        %element-orderdate = if_abap_behv=>mk-on                            " Link to Error field
                        %state_area        = 'orderdate'                                    " Add State message for Draft
                      ) TO reported-salesorder.
      ENDIF.

      IF ls_salesorder-currency IS INITIAL.
        APPEND VALUE #( %tky = ls_salesorder-%tky ) TO failed-salesorder.
        APPEND VALUE #( %tky = ls_salesorder-%tky
                        %msg = NEW zc_mes_rap_ptm( im_textid    = zc_mes_rap_ptm=>c_validfname_e
                                                   im_serverity = if_abap_behv_message=>severity-error
                                                   im_fieldname = 'Currency Code'  )
                        %element-currency = if_abap_behv=>mk-on
                        %state_area       = 'currency'
                      ) TO reported-salesorder.
      ENDIF.

      IF ls_salesorder-deliverystatus = 'B' AND ls_salesorder-notavailable = 'X'.
        APPEND VALUE #( %tky = ls_salesorder-%tky ) TO failed-salesorder.
        APPEND VALUE #( %tky = ls_salesorder-%tky
                        %msg = NEW zc_mes_rap_ptm( im_textid    = zc_mes_rap_ptm=>c_validfname_e
                                                   im_serverity = if_abap_behv_message=>severity-error
                                                   im_fieldname = 'Tax Amount'  )
                        %element-taxamount = if_abap_behv=>mk-on
                        %state_area        = 'taxamount'
                      ) TO reported-salesorder.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

*=============================================================================*
* Determination for Fields                                                    *
*=============================================================================*
  METHOD set_value_soldtoparty.
    DATA: lv_object    TYPE cl_numberrange_objects=>nr_attributes-object VALUE 'ZNR_RAP_SO',
          lt_salesoder TYPE TABLE FOR UPDATE  zr_rap_so_ptm.

*    Get data need to be set from keys
    lt_salesoder = CORRESPONDING #( keys ).

*    Set Sold_to_Party from Number Interval
    LOOP AT lt_salesoder ASSIGNING FIELD-SYMBOL(<lfs_salesoder>).
      TRY.
          cl_numberrange_runtime=>number_get(
            EXPORTING
              nr_range_nr = '03'
              object      = lv_object
            IMPORTING
              number      = DATA(lv_number)
              returncode  = DATA(lv_rcode) ).
        CATCH cx_number_ranges.
          "handle exception
      ENDTRY.

      SHIFT lv_number LEFT DELETING LEADING '0'.
      <lfs_salesoder>-soldtoparty = lv_number.
    ENDLOOP.

    MODIFY ENTITIES OF zr_rap_so_ptm IN LOCAL MODE
        ENTITY salesorder
        UPDATE FIELDS ( soldtoparty )
        WITH lt_salesoder
        FAILED DATA(ls_failed)
        REPORTED DATA(ls_reported).

    IF ls_failed IS INITIAL.
      reported-salesorder = CORRESPONDING #( ls_reported-salesorder ).
    ENDIF.

  ENDMETHOD.

*=============================================================================*
* Feature Control for Update and Delete                                       *
*=============================================================================*
  METHOD get_instance_features.
    DATA: ls_result LIKE LINE OF result.

    "Read relevant instance data
    READ ENTITIES OF zr_rap_so_ptm IN LOCAL MODE
      ENTITY salesorder
        ALL FIELDS WITH
        CORRESPONDING #( keys )
      RESULT DATA(lt_salesorder).

    "Update Result
    LOOP AT lt_salesorder INTO DATA(ls_salesorder).
      IF ls_salesorder-%is_draft = if_abap_behv=>mk-off.                              " For Active mode
        ls_result-%tky = ls_salesorder-%tky.

        IF ls_salesorder-deliverystatus = 'B'.
          ls_result-%features-%delete = if_abap_behv=>fc-o-disabled.                  " Operation Control
        ELSEIF ls_salesorder-deliverystatus = 'C'.
          ls_result-%delete = if_abap_behv=>fc-o-disabled.
          ls_result-%update = if_abap_behv=>fc-o-disabled.
        ENDIF.

        IF ls_salesorder-notavailable IS NOT INITIAL.
          ls_result-%action-set_not_available = if_abap_behv=>fc-o-disabled.          " Action Control
          IF ls_salesorder-deliverystatus = 'B'.
            ls_result-%field-taxamount = if_abap_behv=>fc-f-mandatory.                " Field Control
          ENDIF.
        ENDIF.

        APPEND ls_result TO result.
        CLEAR ls_result.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

*=============================================================================*
* Early Numbering for Sales Order field                                       *
*=============================================================================*
  METHOD earlynumbering_create.
    DATA: lv_object TYPE cl_numberrange_objects=>nr_attributes-object VALUE 'ZNR_RAP_SO'.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_enity>).
      TRY.
          cl_numberrange_runtime=>number_get(
            EXPORTING
              nr_range_nr = '01'
              object      = lv_object
            IMPORTING
              number      = DATA(lv_number)
              returncode  = DATA(lv_rcode) ).
        CATCH cx_number_ranges.
          "handle exception
      ENDTRY.

      SHIFT lv_number LEFT DELETING LEADING '0'.
      INSERT VALUE #(  %cid       = <lfs_enity>-%cid
                       %is_draft  = <lfs_enity>-%is_draft
                       salesorder = lv_number ) INTO TABLE mapped-salesorder.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

*=========================================================================================*
*                                                                                         *
* Local Handle Class for Sales Order Items                                                *
*                                                                                         *
*=========================================================================================*
CLASS lhc_salesorderitems DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS valid_product FOR VALIDATE ON SAVE
      IMPORTING keys FOR salesorderitems~valid_product.

    METHODS set_admitted FOR MODIFY
      IMPORTING keys FOR ACTION salesorderitems~set_admitted RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR salesorderitems RESULT result.

ENDCLASS.

CLASS lhc_salesorderitems IMPLEMENTATION.

*=============================================================================*
* Validate Product field                                                      *
*=============================================================================*
  METHOD valid_product.
    "Read relevant instance data
    READ ENTITIES OF zr_rap_so_ptm IN LOCAL MODE
      ENTITY salesorderitems
        ALL FIELDS WITH
        CORRESPONDING #( keys )
      RESULT DATA(lt_salesorderitems).

    DELETE lt_salesorderitems WHERE product IS NOT INITIAL.

    LOOP AT lt_salesorderitems INTO DATA(ls_salesorderitems).
      "Fill Key error Key
      APPEND VALUE #( %tky = ls_salesorderitems-%tky ) TO failed-salesorderitems.

      "Fill Message for required field
      APPEND VALUE #( %tky = ls_salesorderitems-%tky
                      %element-product = if_abap_behv=>mk-on
                      %msg = NEW zc_mes_rap_ptm( im_textid    = zc_mes_rap_ptm=>c_validfname_e
                                                 im_serverity = if_abap_behv_message=>severity-error
                                                 im_fieldname = 'Product'  ) ) TO reported-salesorderitems.
    ENDLOOP.
  ENDMETHOD.

*=============================================================================*
* Instance Action for itemnote field                                          *
*=============================================================================*
  METHOD set_admitted.
    DATA: lt_so_items_rap TYPE TABLE FOR UPDATE zi_rap_so_i_ptm.

    "Read relevant instance data
    READ ENTITIES OF zr_rap_so_ptm IN LOCAL MODE
      ENTITY salesorderitems
        ALL FIELDS WITH
        CORRESPONDING #( keys )
      RESULT DATA(lt_salesorderitems).

    LOOP AT lt_salesorderitems ASSIGNING FIELD-SYMBOL(<lfs_salesorderitems>).
      IF <lfs_salesorderitems>-price < 20000.
        <lfs_salesorderitems>-itemnote = 'Admitted'.
      ENDIF.

      "Update Result
      result = VALUE #( BASE result (  %tky   = <lfs_salesorderitems>-%tky
                                       %param = <lfs_salesorderitems>  )  ).

      "Output Message
      reported-salesorder = VALUE #( BASE reported-salesorder ( %tky = <lfs_salesorderitems>-%tky
                                                                %msg = NEW zc_mes_rap_ptm( im_textid    = zc_mes_rap_ptm=>c_setadmitted_s
                                                                                           im_serverity = if_abap_behv_message=>severity-success )  )  ).
    ENDLOOP.

    lt_so_items_rap = CORRESPONDING #( lt_salesorderitems ).

    "Update field NotAvailable
    MODIFY ENTITIES OF zr_rap_so_ptm IN LOCAL MODE
        ENTITY salesorderitems
        UPDATE FIELDS ( itemnote )
        WITH lt_so_items_rap
        FAILED DATA(ls_failed)
        REPORTED DATA(ls_reported)
        MAPPED DATA(ls_mapped).

  ENDMETHOD.

*=============================================================================*
* Operation Control for Update                                                *
*=============================================================================*
  METHOD get_instance_features.
    "Read relevant instance data
    READ ENTITIES OF zr_rap_so_ptm IN LOCAL MODE
      ENTITY salesorderitems
        ALL FIELDS WITH
        CORRESPONDING #( keys )
      RESULT DATA(lt_salesorderitems).

    "Update Result
    result = VALUE #( FOR ls_salesorderitems IN lt_salesorderitems WHERE ( itemnote = 'Admitted' )
                                                                   ( %tky                 = ls_salesorderitems-%tky
                                                                     %delete              = if_abap_behv=>fc-o-disabled
                                                                     %field-itemnote      = if_abap_behv=>fc-f-read_only
                                                                     %action-set_admitted = if_abap_behv=>fc-o-disabled  )  ).

  ENDMETHOD.

ENDCLASS.
