*&---------------------------------------------------------------------*
*& Report ZMUSIC_ARTIST_GEN5
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmusic_artist_gen5.

DELETE FROM zmusiclib5.
DELETE FROM zartists5.

DATA : my_musics TYPE STANDARD TABLE OF zmusiclib5.
DATA : my_artists TYPE STANDARD TABLE OF zartists5.


START-OF-SELECTION.

  my_musics = VALUE #(
    (
      id = 1 artist_id = 1 artist = 'Depeche Mode' title = 'Walking in my shoes' genre = 'synthpop'
      lyrics = |You'll stumble in my footsteps. Keep the same appointments I kept |
      url = escape( val = 'https://www.youtube.com/watch?v=Zss48c5zC4A' format = cl_abap_format=>e_uri )
    )

    (
      id = 2 artist_id = 2 artist = 'Einstürzende Neubauten' title = 'Sabrina' genre = 'alternativ'
      lyrics = |It is as black as Malevich's Square. The cold furnace in which we stare. A high pitch on a future scale.It is a starless winternight's tale|
      url = escape( val = 'https://www.youtube.com/watch?v=CnnGYaqjW-A' format = cl_abap_format=>e_uri )
    )

    (
      id = 3 artist_id = 3 artist = 'Paradise Lost' title = 'Faith Divides Us Death Unites Us' genre = 'rock'
      lyrics = |Cannot sleep through darkened skies Cannot dream until it's over|
      url = escape( val = 'https://www.youtube.com/watch?v=9BONcpuDcrc' format = cl_abap_format=>e_uri )
    )

  ).

  my_artists = VALUE #(
  (
    id = 1
    name = 'Depeche Mode'
    year_found = '19800101'
    nationality = 'angol'
    webpage = escape( val = 'https://www.depechemode.com' format = cl_abap_format=>e_uri )
    genre = 'synthpop'
    vocalist = 'Dave Gahan'
  )

  (
    id = 2
    name = 'Einstürzende Neubauten'
    year_found = '19800101'
    nationality = 'német'
    webpage = escape( val = 'https://neubauten.org/en' format = cl_abap_format=>e_uri )
    genre = 'synthpop'
    vocalist = 'Blixa Bargeld'
  )

  (
    id = 3
    name = 'Paradise Lost'
    year_found = '19880101'
    nationality = 'angol'
    webpage = escape( val = 'https://www.paradiselost.co.uk/' format = cl_abap_format=>e_uri )
    genre = 'goth metal'
    vocalist = 'Nick Holmes'
  )

).
  TRY.
      INSERT zmusiclib5 FROM TABLE my_musics.
      CHECK sy-subrc = 0.
      INSERT zartists5 FROM TABLE my_artists.
      CHECK sy-subrc = 0.
      COMMIT WORK.
    CATCH cx_root INTO DATA(ex).
      WRITE ex->get_text( ).
  ENDTRY.
