@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'town comp'
define root view entity ZKP_I_TOWNS_DET
  as select from zkp_towns_det as Town
  association [0..*] to zkp_weat_pred5 as _Prediction on  $projection.City    = _Prediction.city
                                                      and $projection.Country = _Prediction.country

  association [0..*] to zkp_weat_fact  as _WeatFacts  on  $projection.City    = _WeatFacts.city
                                                      and $projection.Country = _WeatFacts.country
{
  key city                  as City,
  key country               as Country,
      latitude              as Latitude,
      longitude             as Longitude,
      url                   as Url,
      mayor                 as Mayor,
      population            as Population,
      created_by            as CreatedBy,
      created_at            as CreatedAt,
      last_changed_by       as LastChangedBy,
      last_changed_at       as LastChangedAt,
      local_last_changed_at as LocalLastChangedAt,

      _Prediction,
      _WeatFacts
}
