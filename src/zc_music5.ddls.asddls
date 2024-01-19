@AbapCatalog.sqlViewName: 'ZCMUSIC5'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Musics - Consumption'

@Metadata.allowExtensions: true

@OData.publish: true

define view ZC_MUSIC5
  as select from ZI_Music5
{
  key Id,
      Artist,
      Title,
      Genre,
      Lyrics,
      Url,

      @ObjectModel.virtualElement: true
      @ObjectModel.virtualElementCalculatedBy: 'zcl_cronos_visitors_count_cds5'
      cast( 0 as abap.int8 ) as VisitorsCount
}
