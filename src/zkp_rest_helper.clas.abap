class ZKP_REST_HELPER definition
  public
  create public .

public section.

  class-methods CONVERT_UNIX_TO_TIMESTAMP
    importing
      !IV_UNIX_TS type STRINGVAL
    exporting
      !EV_DATE type DATUM
      !EV_TIME type UZEIT
    returning
      value(RV_TIMESTAMP) type TIMESTAMP .
protected section.
private section.
ENDCLASS.



CLASS ZKP_REST_HELPER IMPLEMENTATION.


  METHOD convert_unix_to_timestamp.
    DATA: lv_timestamp_msec TYPE string,
          lv_date           TYPE datum,
          lv_time           TYPE uzeit.

    DATA: lv_date_loc      TYPE sy-datlo,
          lv_time_loc      TYPE sy-timlo,
          lv_timestamp_loc TYPE timestamp.


    lv_timestamp_msec = iv_unix_ts * 1000.

    cl_pco_utility=>convert_java_timestamp_to_abap(
        EXPORTING
          iv_timestamp = lv_timestamp_msec
        IMPORTING
          ev_date      = lv_date
          ev_time      = lv_time
*     ev_msec      =     " Remaining Milliseconds
      ).
    GET TIME STAMP FIELD DATA(lv_timestamp).
    CONVERT DATE lv_date TIME lv_time INTO TIME STAMP rv_timestamp TIME ZONE 'UTC-1'.

    CONVERT TIME STAMP rv_timestamp TIME ZONE ''
            INTO DATE ev_date TIME ev_time
            DAYLIGHT SAVING TIME DATA(dst).
*    CALL FUNCTION 'TZ_GLOBAL_TO_LOCAL'
*      EXPORTING
**       date_global         = '00000000'
*        timestamp_global    = lv_timestamp
*        timezone            = 'CET'
*        time_global         = '000000'
*      IMPORTING
*        date_local          = lv_date_loc
**       timestamp_local     = lv_timestamp_loc
**       time_local          = lv_time_loc
*      EXCEPTIONS
*        no_parameters       = 1
*        too_many_parameters = 2
*        conversion_error    = 3
*        OTHERS              = 4.
*    IF sy-subrc <> 0.
** Implement suitable error handling here
*    ENDIF.

  ENDMETHOD.
ENDCLASS.
