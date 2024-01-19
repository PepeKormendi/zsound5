*&---------------------------------------------------------------------*
*& Report ZKP_CALL_WEATHERPREDICT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zkp_call_weatherpredict.

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

DATA: ls_predict TYPE zkp_weat_pred5.
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

DATA: lv_iterator TYPE i,
      lv_cnt      TYPE i,
      lv_parse    TYPE string.


SELECT * FROM zkp_weat_towns INTO TABLE @DATA(lt_towns).

LOOP AT lt_towns ASSIGNING FIELD-SYMBOL(<ls_town>).
  CLEAR: ls_predict, lv_long, lv_lat, lv_temp, lv_response, lv_cnt, lv_status_code, lv_status_reason, lv_wind, lv_time10.
  lv_long = condense( val = <ls_town>-longitude ).
  lv_lat = condense( val = <ls_town>-latitude ).
  lv_url = |https://api.openweathermap.org/data/2.5/forecast?lat={ lv_lat }&lon={ lv_long }&units=metric&lang=en&appid={ lc_apikey }|.
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
        ls_predict = VALUE #( mandt = sy-mandt city = to_upper( val = <ls_town>-city ) country = to_upper( val = <ls_town>-country ) ).
      CATCH cx_sy_strg_par_val.
    ENDTRY.

    GET TIME STAMP FIELD ls_predict-timestamp.
    CONVERT TIME STAMP ls_predict-timestamp TIME ZONE 'UTC+1'
      INTO DATE ls_predict-act_date TIME ls_predict-act_time.

    CLEAR lv_iterator.
    /ui2/cl_data_access=>create( ir_data = lr_data iv_component = |cnt| )->value( IMPORTING ev_data = lv_cnt ).
    DO lv_cnt TIMES.
      lv_iterator = lv_iterator + 1.




      /ui2/cl_data_access=>create( ir_data = lr_data iv_component = |list[{ lv_iterator }]-weather[1]-main| )->value( IMPORTING ev_data = ls_predict-main ).
      /ui2/cl_data_access=>create( ir_data = lr_data iv_component = |list[{ lv_iterator }]-weather[1]-icon| )->value( IMPORTING ev_data = ls_predict-icon ).
      /ui2/cl_data_access=>create( ir_data = lr_data iv_component = |list[{ lv_iterator }]-main-temp|  )->value( IMPORTING ev_data = lv_temp ).
      ls_predict-tempar = lv_temp.
      CLEAR lv_temp.
      /ui2/cl_data_access=>create( ir_data = lr_data iv_component = |list[{ lv_iterator }]-main-feels_like| )->value( IMPORTING ev_data = lv_temp ).
      ls_predict-feels = lv_temp.
      CLEAR lv_temp.
      /ui2/cl_data_access=>create( ir_data = lr_data iv_component = |list[{ lv_iterator }]-main-temp_min| )->value( IMPORTING ev_data = lv_temp ).
      ls_predict-tempmin = lv_temp.
      CLEAR lv_temp.
      /ui2/cl_data_access=>create( ir_data = lr_data iv_component = |list[{ lv_iterator }]-main-temp_max| )->value( IMPORTING ev_data = lv_temp ).
      ls_predict-tempmax = lv_temp.
      CLEAR lv_temp.
      /ui2/cl_data_access=>create( ir_data = lr_data iv_component = |list[{ lv_iterator }]-main-humidity| )->value( IMPORTING ev_data = ls_predict-humidity ).
      /ui2/cl_data_access=>create( ir_data = lr_data iv_component = |list[{ lv_iterator }]-wind-speed| )->value( IMPORTING ev_data = lv_wind ).
      ls_predict-windspeed = lv_wind.
      /ui2/cl_data_access=>create( ir_data = lr_data iv_component = |list[{ lv_iterator }]-clouds-all| )->value( IMPORTING ev_data = ls_predict-clouds ).

      /ui2/cl_data_access=>create( ir_data = lr_data iv_component = |list[{ lv_iterator }]-dt| )->value( IMPORTING ev_data = lv_time10 ).
      zkp_rest_helper=>convert_unix_to_timestamp( EXPORTING iv_unix_ts = lv_time10 IMPORTING ev_date = ls_predict-act_pred_date ev_time = ls_predict-act_pred_time RECEIVING rv_timestamp = ls_predict-pred_tmp ).
      CLEAR lv_time10.


      IF ls_predict-city IS NOT INITIAL AND ls_predict-country IS NOT INITIAL AND ls_predict-timestamp IS NOT INITIAL AND ls_predict-pred_tmp IS NOT INITIAL.

        CALL FUNCTION 'ENQUEUE_EZ_WEATPREDICT'
          EXPORTING
            mode_zkp_weat_pred5 = 'E'
            mandt               = sy-mandt
            city                = ls_predict-city
            country             = ls_predict-country
            timestamp           = ls_predict-timestamp
            pred_tmp            = ls_predict-pred_tmp
          EXCEPTIONS
            foreign_lock        = 1
            system_failure      = 2
            OTHERS              = 3.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ELSE.

          INSERT zkp_weat_pred5 FROM ls_predict.
          IF sy-subrc = 0.
            COMMIT WORK.
          ELSE.
            ROLLBACK WORK.
          ENDIF.

          CALL FUNCTION 'DEQUEUE_EZ_WEATPREDICT'
            EXPORTING
              mode_zkp_weat_pred5 = 'E'
              mandt               = sy-mandt
              city                = ls_predict-city
              country             = ls_predict-country
              timestamp           = ls_predict-timestamp
              pred_tmp            = ls_predict-pred_tmp.

        ENDIF.
      ENDIF.
    ENDDO.
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
