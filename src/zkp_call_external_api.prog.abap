*&---------------------------------------------------------------------*
*& Report ZKP_CALL_EXTERNAL_API
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zkp_call_external_api.

*General Data Declarations.
CONSTANTS: lc_apikey TYPE string VALUE 'dcfd011de7e5009c34093d8bebc5266a'.

PARAMETERS: p_city TYPE string DEFAULT 'Budapest'.
PARAMETERS: p_land TYPE string DEFAULT 'HU'.


DATA: lo_http_client   TYPE REF TO if_http_client,
      lo_rest_client   TYPE REF TO cl_rest_http_client,
      lv_body          TYPE string,
      http_status      TYPE string,
      lv_error_message TYPE string,
      lt_errors        TYPE TABLE OF string,
      lv_url           TYPE string.

TRANSLATE p_city TO LOWER CASE.
TRANSLATE p_city TO LOWER CASE.
*lv_url = |https://api.openweathermap.org/data/2.5/weather?q={ p_city }&appid={ lc_apikey }|.
lv_url = |https://api.openweathermap.org/geo/1.0/direct?q={ p_city },{ p_land }&limit=5&appid={ lc_apikey }|.

*Creation of New IF_HTTP_Client Object
cl_http_client=>create_by_url(
EXPORTING
  url                = lv_url
  "proxy_host         = "Proxy
  "proxy_service      = "Port
  "sap_username       = "Username
  "sap_client         = "Client
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

*lo_http_client->request->set_method( if_http_request=>co_request_method_post ).
*lo_http_client->authenticate( username = 'MY_SAP_USER' password = 'secret' ).
*lo_http_client->propertytype_accept_cookie = if_http_client=>co_enabled.
*lo_http_client->request->set_header_field( name  = if_http_form_fields_sap=>sap_client value = '100' ).
"lo_http_client->request->set_version( if_http_request=>co_protocol_version_1_0 ).

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
  DATA: lv_response      TYPE string,
        lv_status_reason TYPE string,
        lv_status_code   TYPE i,
        lv_value         TYPE string,
        lv_lat           TYPE p DECIMALS 4,
        lv_lon           TYPE p DECIMALS 4,
        lr_data          TYPE REF TO data,
        lv_cityname      TYPE zkpcity,
        lv_countrycode   TYPE zkpcountrycode,
        lv_zlat          TYPE zkplat,
        lv_zlong         TYPE zkplon.

  lo_http_client->response->get_status( IMPORTING code = lv_status_code reason = lv_status_reason ).
  lv_response = lo_http_client->response->get_cdata( ).

  WRITE: / 'HTTP status code: ', lv_status_code.
  WRITE: / 'HTTP status reason: ', lv_status_reason.
*  WRITE: / 'Response: ', lv_response, /.

  lr_data = /ui2/cl_json=>generate( json = lv_response ).
  " (>= SAP_UI 751) To use /ui2/cl_data_access, it is necessary to implement SAP Note 2526405 "/UI2/CL_JSON Corrections".
  /ui2/cl_data_access=>create( ir_data = lr_data iv_component = `[1]-name`)->value( IMPORTING ev_data = lv_value ).
  /ui2/cl_data_access=>create( ir_data = lr_data iv_component = `[1]-lat`)->value( IMPORTING ev_data = lv_lat ).
  /ui2/cl_data_access=>create( ir_data = lr_data iv_component = `[1]-lon`)->value( IMPORTING ev_data = lv_lon ).
  WRITE: / 'City: ', lv_value.
  WRITE: / 'Lat: ', lv_lat.
  WRITE: / 'Lon: ', lv_lon.
  TRY.
      lv_cityname = to_lower( val = CONV zkpcity( p_city ) ).
      lv_countrycode = to_lower( val = CONV zkpcountrycode( p_land ) ).
    CATCH cx_sy_strg_par_val.
  ENDTRY.
  lv_zlat = CONV #( lv_lat ).
  lv_zlong = CONV #( lv_lon ).
  IF lv_cityname IS NOT INITIAL AND lv_countrycode IS NOT INITIAL AND lv_zlat IS NOT INITIAL AND lv_zlong IS NOT INITIAL.
    SELECT SINGLE * FROM zkp_weat_towns INTO @DATA(ls_dummy) WHERE city = @lv_cityname AND country = @lv_countrycode.

    IF ls_dummy IS INITIAL.
      CALL FUNCTION 'ENQUEUE_EZ_WEATTOWNS'
        EXPORTING
          mode_zkp_weat_towns = 'E'
          mandt               = sy-mandt
          city                = lv_cityname
          country             = lv_countrycode
*         X_CITY              = ' '
*         X_COUNTRY           = ' '
*         _SCOPE              = '2'
*         _WAIT               = ' '
*         _COLLECT            = ' '
*   EXCEPTIONS
*         FOREIGN_LOCK        = 1
*         SYSTEM_FAILURE      = 2
*         OTHERS              = 3
        .
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
      ls_dummy = VALUE #( mandt = sy-mandt city = lv_cityname country = lv_countrycode latitude = lv_zlat longitude = lv_zlong ).

      INSERT zkp_weat_towns FROM ls_dummy.
      IF sy-subrc = 0.
        COMMIT WORK.
      ELSE.
        ROLLBACK WORK.
      ENDIF.

      CALL FUNCTION 'DEQUEUE_EZ_WEATTOWNS'
        EXPORTING
          mode_zkp_weat_towns = 'E'
          mandt               = sy-mandt
          city                = lv_cityname
          country             = lv_countrycode
*         X_CITY              = ' '
*         X_COUNTRY           = ' '
*         _SCOPE              = '3'
*         _SYNCHRON           = ' '
*         _COLLECT            = ' '
        .
    ENDIF.
  ENDIF.
ENDIF.

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
