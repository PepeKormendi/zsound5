*&---------------------------------------------------------------------*
*& Report ZKP_CALL_WEATHERPRESENT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zkp_call_weatherpresent.

*General Data Declarations.
CONSTANTS: lc_apikey TYPE string VALUE 'dcfd011de7e5009c34093d8bebc5266a'.

*PARAMETERS: p_city TYPE string DEFAULT 'Budapest'.
*PARAMETERS: p_land TYPE string DEFAULT 'HU'.

DATA: lo_http_client   TYPE REF TO if_http_client,
      lo_rest_client   TYPE REF TO cl_rest_http_client,
      lv_body          TYPE string,
      http_status      TYPE string,
      lv_error_message TYPE string,
      lt_errors        TYPE TABLE OF string,
      lv_url           TYPE string.

DATA: lv_long TYPE string,
      lv_lat  TYPE string.

DATA: ls_present TYPE zkp_weat_fact.
DATA: lv_response      TYPE string,
      lv_status_reason TYPE string,
      lv_status_code   TYPE i,
      lv_value         TYPE string,
      lv_temp          TYPE p DECIMALS 2,
      lv_wind          TYPE p DECIMALS 4,
      lv_time10        TYPE string,
      lr_data          TYPE REF TO data,
      lv_cityname      TYPE zkpcity,
      lv_countrycode   TYPE zkpcountrycode,
      lv_zlat          TYPE zkplat,
      lv_zlong         TYPE zkplon.


SELECT * FROM zkp_weat_towns INTO TABLE @DATA(lt_towns).

LOOP AT lt_towns ASSIGNING FIELD-SYMBOL(<ls_town>).
  CLEAR: ls_present, lv_long, lv_lat, lv_temp, lv_response, lv_status_code, lv_status_reason, lv_wind, lv_time10.
  lv_long = condense( val = <ls_town>-longitude ).
  lv_lat = condense( val = <ls_town>-latitude ).
  lv_url = |https://api.openweathermap.org/data/2.5/weather?lat={ lv_lat }&lon={ lv_long }&units=metric&lang=en&appid={ lc_apikey }|.
*Creation of New IF_HTTP_Client Object
  cl_http_client=>create_by_url(
  EXPORTING
    url                = lv_url
  IMPORTING
    client             = lo_http_client
  EXCEPTIONS
    argument_not_found = 1
    plugin_not_active  = 2
    internal_error     = 3
    ).

  IF sy-subrc IS NOT INITIAL.
    "Error handling
  ENDIF.
*Structure of HTTP Connection and Dispatch of Data
  lo_http_client->send( ).
  IF sy-subrc IS NOT INITIAL.
    PERFORM handle_http_exception.
  ENDIF.
*Receipt of HTTP Response
  lo_http_client->receive(
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state = 2
      http_processing_failed = 3
   ).
  IF sy-subrc IS NOT INITIAL.
    PERFORM handle_http_exception.
  ELSE.

    lo_http_client->response->get_status( IMPORTING code = lv_status_code reason = lv_status_reason ).
    lv_response = lo_http_client->response->get_cdata( ).
    lr_data = /ui2/cl_json=>generate( json = lv_response ).
    TRY.
        ls_present = VALUE #( mandt = sy-mandt city = to_upper( val = <ls_town>-city ) country = to_upper( val = <ls_town>-country ) ).
      CATCH cx_sy_strg_par_val.
    ENDTRY.

    GET TIME STAMP FIELD ls_present-timestamp.
    CONVERT TIME STAMP ls_present-timestamp TIME ZONE 'UTC+1'
        INTO DATE ls_present-act_date TIME ls_present-act_time.


    /ui2/cl_data_access=>create( ir_data = lr_data iv_component = `weather[1]-main`)->value( IMPORTING ev_data = ls_present-main ).
    /ui2/cl_data_access=>create( ir_data = lr_data iv_component = `weather[1]-icon`)->value( IMPORTING ev_data = ls_present-icon ).
    /ui2/cl_data_access=>create( ir_data = lr_data iv_component = `main-temp`)->value( IMPORTING ev_data = lv_temp ).
    ls_present-tempar = lv_temp.
    CLEAR lv_temp.
    /ui2/cl_data_access=>create( ir_data = lr_data iv_component = `main-feels_like`)->value( IMPORTING ev_data = lv_temp ).
    ls_present-feels = lv_temp.
    CLEAR lv_temp.
    /ui2/cl_data_access=>create( ir_data = lr_data iv_component = `main-temp_min`)->value( IMPORTING ev_data = lv_temp ).
    ls_present-tempmin = lv_temp.
    CLEAR lv_temp.
    /ui2/cl_data_access=>create( ir_data = lr_data iv_component = `main-temp_max`)->value( IMPORTING ev_data = lv_temp ).
    ls_present-tempmax = lv_temp.
    CLEAR lv_temp.
    /ui2/cl_data_access=>create( ir_data = lr_data iv_component = `main-humidity`)->value( IMPORTING ev_data = ls_present-humidity ).
    /ui2/cl_data_access=>create( ir_data = lr_data iv_component = `wind-speed`)->value( IMPORTING ev_data = lv_wind ).
    ls_present-windspeed = lv_wind.
    /ui2/cl_data_access=>create( ir_data = lr_data iv_component = `clouds-all`)->value( IMPORTING ev_data = ls_present-clouds ).
    /ui2/cl_data_access=>create( ir_data = lr_data iv_component = `sys-sunrise`)->value( IMPORTING ev_data = lv_time10 ).
    zkp_rest_helper=>convert_unix_to_timestamp( EXPORTING iv_unix_ts = lv_time10 IMPORTING ev_time = ls_present-sunrise_time RECEIVING rv_timestamp = ls_present-sunsrise_tmp ).
    CLEAR lv_time10.
    /ui2/cl_data_access=>create( ir_data = lr_data iv_component = `sys-sunset`)->value( IMPORTING ev_data = lv_time10 ).
    zkp_rest_helper=>convert_unix_to_timestamp( EXPORTING iv_unix_ts = lv_time10 IMPORTING ev_time = ls_present-sunset_time RECEIVING rv_timestamp = ls_present-sunset_tmp ).
    CLEAR lv_time10.

    IF <ls_town>-city IS NOT INITIAL AND <ls_town>-country IS NOT INITIAL AND ls_present-timestamp IS NOT INITIAL.
      CALL FUNCTION 'ENQUEUE_EZ_WEATFACT'
        EXPORTING
          mode_zkp_weat_fact = 'E'
          mandt              = sy-mandt
          city               = <ls_town>-city
          country            = <ls_town>-country
          timestamp          = ls_present-timestamp
*         X_CITY             = ' '
*         X_COUNTRY          = ' '
*         X_TIMESTAMP        = ' '
*         _SCOPE             = '2'
*         _WAIT              = ' '
*         _COLLECT           = ' '
        EXCEPTIONS
          foreign_lock       = 1
          system_failure     = 2
          OTHERS             = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here

      ELSE.
        INSERT zkp_weat_fact FROM ls_present.
        IF sy-subrc = 0.
          COMMIT WORK.
        ELSE.
          ROLLBACK WORK.
        ENDIF.

        CALL FUNCTION 'DEQUEUE_EZ_WEATFACT'
          EXPORTING
            mode_zkp_weat_fact = 'E'
            mandt              = sy-mandt
            city               = <ls_town>-city
            country            = <ls_town>-country
            timestamp          = ls_present-timestamp
*           X_CITY             = ' '
*           X_COUNTRY          = ' '
*           X_TIMESTAMP        = ' '
*           _SCOPE             = '3'
*           _SYNCHRON          = ' '
*           _COLLECT           = ' '
          .


      ENDIF.

    ENDIF.
  ENDIF.

ENDLOOP.



*==============================================================
*=== FORMS ====================================================
*==============================================================
FORM handle_http_exception.
  WRITE: / 'Error Number', sy-subrc, /.
  lo_http_client->get_last_error(
    IMPORTING
      message = lv_error_message ).
  SPLIT lv_error_message AT cl_abap_char_utilities=>newline INTO TABLE lt_errors.
  LOOP AT lt_errors INTO lv_error_message.
    WRITE: / lv_error_message.
  ENDLOOP.
  WRITE: / 'Also check transaction SMICM -> Goto -> Trace File -> Display End'.
  RETURN.
ENDFORM.
