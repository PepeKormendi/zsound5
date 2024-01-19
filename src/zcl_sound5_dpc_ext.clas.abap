"! <p class="shorttext synchronized" lang="en">Music Libary 5</p>
class ZCL_SOUND5_DPC_EXT definition
  public
  inheriting from ZCL_SOUND5_DPC
  create public .

public section.
protected section.

  methods ARTISTS_GET_ENTITY
    redefinition .
  methods ARTISTS_GET_ENTITYSET
    redefinition .
  methods MUSICS_GET_ENTITY
    redefinition .
  methods MUSICS_GET_ENTITYSET
    redefinition .
  methods MUSICS_CREATE_ENTITY
    redefinition .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_SOUND5_DPC_EXT IMPLEMENTATION.


  METHOD musics_get_entityset.
    DATA:
      artist_selopt TYPE rsdsselopt_t.

    LOOP AT it_filter_select_options ASSIGNING FIELD-SYMBOL(<filter>).
      CASE <filter>-property.
        WHEN 'Artist'.
          artist_selopt = VALUE #( FOR selopt IN <filter>-select_options
            ( sign = selopt-sign option = selopt-option low = selopt-low high = selopt-high )
          ).
      ENDCASE.
    ENDLOOP.
    DATA(artists) = VALUE rsdsselopt_t( FOR keyline IN it_key_tab ( sign = 'I' option = 'EQ' low = keyline-value ) ).

    SELECT * FROM zmusiclib5 INTO CORRESPONDING FIELDS OF TABLE et_entityset
      WHERE artist_id IN artists .

  ENDMETHOD.


  METHOD artists_get_entity.
    DATA(artistId) = CONV numc10(  it_key_tab[  name = 'Id' ]-value ).
    SELECT SINGLE * FROM zartists5 INTO CORRESPONDING FIELDS OF er_entity
    WHERE id = artistid.
  ENDMETHOD.


  METHOD artists_get_entityset.
    DATA:
      artist_selopt TYPE rsdsselopt_t.

    LOOP AT it_filter_select_options ASSIGNING FIELD-SYMBOL(<filter>).
      CASE <filter>-property.
        WHEN 'srtist_id' or 'Id'.
          artist_selopt = VALUE #( FOR selopt IN <filter>-select_options
            ( sign = selopt-sign option = selopt-option low = selopt-low high = selopt-high )
          ).
      ENDCASE.
    ENDLOOP.

    SELECT * FROM zartists5 INTO CORRESPONDING FIELDS OF TABLE et_entityset
      WHERE id IN artist_selopt.
  ENDMETHOD.


  METHOD musics_get_entity.
    DATA(trackId) = CONV numc10(  it_key_tab[  name = 'Id' ]-value ).
    SELECT SINGLE * FROM zmusiclib5 INTO CORRESPONDING FIELDS OF er_entity
    WHERE id = trackId.
  ENDMETHOD.


  METHOD musics_create_entity.

    DATA: ls_music TYPE zcl_sound5_mpc=>ts_music.
    io_data_provider->read_entry_data( IMPORTING es_data = ls_music ).

    ls_music-artist_id = it_key_tab[ 1 ]-value.
    SELECT SINGLE name FROM zartists5 INTO ls_music-artist WHERE id = ls_music-artist_id.
    SELECT SINGLE MAX( id ) FROM zmusiclib5 INTO @DATA(lv_maxi_id).
    ls_music-id = lv_maxi_id + 1.
    MODIFY zmusiclib5 FROM ls_music.
    WRITE:'manóba'.
*    TRY.
*        CALL METHOD super->musics_create_entity
*          EXPORTING
*            iv_entity_name          =
*            iv_entity_set_name      =
*            iv_source_name          =
*            it_key_tab              =
*            io_tech_request_context =
*            it_navigation_path      =
*            io_data_provider        =
*          IMPORTING
*            er_entity               =.
*      CATCH /iwbep/cx_mgw_busi_exception.
*      CATCH /iwbep/cx_mgw_tech_exception.
*    ENDTRY.
  ENDMETHOD.
ENDCLASS.
