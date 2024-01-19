@EndUserText.label: 'projection'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@UI: {
 headerInfo: { typeName: 'Town', typeNamePlural: 'Towns', title: { type: #STANDARD, value: 'City' } } }
define root view entity ZC_WEAT_TOWNS
  as projection on ZI_WEAT_TOWNS
{

      @UI.facet: [ { id:              'Town',
                     purpose:         #STANDARD,
                     type:            #IDENTIFICATION_REFERENCE,
                     label:           'Town',
                     position:        10 } ]
      @UI: {
          lineItem:       [ { position: 10, importance: #HIGH, label: 'Town' } ],
          identification: [ { position: 10, label: 'Town' } ] }
      @Search.defaultSearchElement: true
  key City,
      @UI: {
              lineItem:       [ { position: 20, importance: #HIGH, label: 'Country' } ],
              identification: [ { position: 20, label: 'Country' } ] }
  key Country,
      CityUpper,
      CountryUpper,
      @UI: {
              lineItem:       [ { position: 30, importance: #HIGH, label: 'Latitude' } ],
              identification: [ { position: 30, label: 'Latitude' } ] }
      Latitude,
      @UI: {
        lineItem:       [ { position: 40, importance: #HIGH, label: 'Longitude' } ],
        identification: [ { position: 40, label: 'Longitude' } ] }
      Longitude,

      /* Associations */
      _Prediction,
      _TownDetail,
      _WeatFacts
}
