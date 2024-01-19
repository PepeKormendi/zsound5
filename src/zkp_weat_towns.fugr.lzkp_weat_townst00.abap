*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZKP_WEAT_TOWNS..................................*
DATA:  BEGIN OF STATUS_ZKP_WEAT_TOWNS                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZKP_WEAT_TOWNS                .
CONTROLS: TCTRL_ZKP_WEAT_TOWNS
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZKP_WEAT_TOWNS                .
TABLES: ZKP_WEAT_TOWNS                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
