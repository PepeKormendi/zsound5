@AbapCatalog.sqlViewName: 'ZIMUSIC5'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Music'
define view ZI_Music5
  as select from zmusiclib5
{
  key id     as Id,
      artist as Artist,
      title  as Title,
      genre  as Genre,
      lyrics as Lyrics,
      url    as Url
}
