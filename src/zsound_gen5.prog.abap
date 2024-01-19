*&---------------------------------------------------------------------*
*& Report zsound_gen0
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsound_gen5.

DATA:
  my_musics TYPE STANDARD TABLE OF zmusiclib5.

START-OF-SELECTION.

  my_musics = VALUE #(
    (
      id = 1 artist = 'Kis Grofo' title = 'Mulatasi' genre = 'mulatos'
      lyrics = |Mulatási, mulatási, mulatási\nÉn a bulibáró sálomálomálom\nÉn a bulibáró legyen buli bárhol |
      url = escape( val = 'https://www.youtube.com/watch?v=Gatx849aaUI' format = cl_abap_format=>e_uri )
    )

    (
      id = 2 artist = 'Betli Duo' title = 'Teritett Betli' genre = 'mulatos'
      lyrics = |Ezekkel a sofőrökkel\nbaj van, baj van!\nPláne, hogyha a kocsiban\ncsaj van, csaj van.|
      url = escape( val = 'https://www.youtube.com/watch?v=2dn698vBho0' format = cl_abap_format=>e_uri )
    )

    (
      id = 3 artist = 'Late Night Alumni' title = 'Empty Streets' genre = 'deephouse'
      lyrics = |The city feels clean this time of night just empty streets\nAnd me walking home to clear my head\nI know it came as no surprise|
      url = escape( val = 'https://www.youtube.com/watch?v=E1e3XtQ7D5Q' format = cl_abap_format=>e_uri )
    )

  ).

  TRY.
      INSERT zmusiclib5 FROM TABLE my_musics.
      COMMIT WORK.

    CATCH cx_root INTO DATA(ex).
      WRITE ex->get_text( ).
  ENDTRY.
