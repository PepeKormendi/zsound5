@EndUserText.label: 'CompV Towns'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZI_WEAT_TOWNS
  as select from zkp_weat_towns as Towns
  association [0..1] to zkp_towns_det  as _TownDetail on  $projection.CityUpper    = _TownDetail.city
                                                      and $projection.CountryUpper = _TownDetail.country

  association [0..*] to zkp_weat_pred5 as _Prediction on  $projection.CityUpper    = _Prediction.city
                                                      and $projection.CountryUpper = _Prediction.country

  association [0..*] to zkp_weat_fact  as _WeatFacts  on  $projection.CityUpper    = _WeatFacts.city
                                                      and $projection.CountryUpper = _WeatFacts.country

{
  key city             as City,
  key country          as Country,
      UPPER( city )    as CityUpper,
      UPPER( country ) as CountryUpper,
      latitude         as Latitude,
      longitude        as Longitude,
      


      _TownDetail,
      _Prediction,
      _WeatFacts
}
