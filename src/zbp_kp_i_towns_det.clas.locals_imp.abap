CLASS lhc_zkp_i_towns_det DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES tt_travel_update TYPE TABLE FOR UPDATE zkp_i_towns_det.
    METHODS calculateurl FOR DETERMINE ON MODIFY
      IMPORTING keys FOR town~calculateurl.

    METHODS validatecity FOR VALIDATE ON SAVE
      IMPORTING keys FOR town~validatecity.

ENDCLASS.

CLASS lhc_zkp_i_towns_det IMPLEMENTATION.

  METHOD calculateurl.

    READ ENTITIES OF zkp_i_towns_det IN LOCAL MODE
      ENTITY town
        FIELDS ( city url  )
        WITH CORRESPONDING #( keys )
      RESULT DATA(towns)
      FAILED DATA(read_failed).

    DELETE towns WHERE city IS INITIAL.
    DELETE towns WHERE url IS NOT INITIAL.
    CHECK  towns IS NOT INITIAL.

    MODIFY ENTITIES OF zkp_i_towns_det IN LOCAL MODE
      ENTITY town
        UPDATE FIELDS ( url )
        WITH VALUE #( FOR town IN towns ( %tky     = town-%tky
                                           url     = |https://hu.wikipedia.org/wiki/{ to_mixed(  val =  town-city ) } | ) )
    REPORTED DATA(update_reported).
    reported = CORRESPONDING #( DEEP update_reported ).


  ENDMETHOD.

  METHOD validatecity.
    READ ENTITY zkp_i_towns_det\\town FROM VALUE #(
      FOR <root_key> IN keys ( %key-city    = <root_key>-city
                               %key-country    = <root_key>-country
                              %control = VALUE #( city = if_abap_behv=>mk-on
                                                  country = if_abap_behv=>mk-on ) ) )
      RESULT DATA(lt_town).
    LOOP AT lt_town ASSIGNING FIELD-SYMBOL(<ls_town>).
      <ls_town>-city = to_upper( val = <ls_town>-city ).
      <ls_town>-country = to_upper( val = <ls_town>-country ).
    ENDLOOP.
    SELECT FROM zkp_towns_det FIELDS city, country
      FOR ALL ENTRIES IN @lt_town
      WHERE city = @lt_town-city
      AND country = @lt_town-country
      INTO TABLE @DATA(lt_towns_db).
    IF lt_towns_db IS NOT INITIAL.
      APPEND VALUE #(  city    = lt_towns_db[ 1 ]-city
                       country = lt_towns_db[ 1 ]-country ) TO failed-town.
      APPEND VALUE #(  city    = lt_towns_db[ 1 ]-city
                       country = lt_towns_db[ 1 ]-country
                      %msg     = new_message( id       = 'ZKP_MSG1'
                                              number   = '000'
                                              severity = if_abap_behv_message=>severity-error )
                      %element-city    = if_abap_behv=>mk-on
                      %element-country = if_abap_behv=>mk-on ) TO reported-town.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
