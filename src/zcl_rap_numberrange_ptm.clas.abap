CLASS zcl_rap_numberrange_ptm DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_RAP_NUMBERRANGE_PTM IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    DATA: lv_object   TYPE cl_numberrange_objects=>nr_attributes-object,
          lt_interval TYPE cl_numberrange_intervals=>nr_interval,
          ls_interval TYPE cl_numberrange_intervals=>nr_nriv_line.

    lv_object = 'ZNR_RAP_SO'.

*   Set Intervals Data
    ls_interval-nrrangenr  = '03'.
    ls_interval-fromnumber = '3000000000'.
    ls_interval-tonumber   = '3999999999'.
    APPEND ls_interval TO lt_interval.

*   create intervals
    out->write( |Create Intervals for Object: { lv_object } | ).
    TRY.
        CALL METHOD cl_numberrange_intervals=>create
          EXPORTING
            interval  = lt_interval
            object    = lv_object
            subobject = ' '
          IMPORTING
            error     = DATA(lv_error)
            error_inf = DATA(ls_error)
            error_iv  = DATA(lt_error_iv)
            warning   = DATA(lv_warning).
      CATCH cx_number_ranges.
        "Handle exception
    ENDTRY.

*    Getting Numbers for Internal Interval
    TRY.
        CALL METHOD cl_numberrange_runtime=>number_get
          EXPORTING
            nr_range_nr = '03'
            object      = lv_object
          IMPORTING
            number      = DATA(lv_number)
            returncode  = DATA(lv_rcode).
      CATCH cx_number_ranges.
        "Handle exception
    ENDTRY.

    out->write( |Numbers for Interval: { lv_number } | ).

  ENDMETHOD.
ENDCLASS.
