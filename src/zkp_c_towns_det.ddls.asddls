@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Concum Town'
@UI: {
 headerInfo: { typeName: 'Town', typeNamePlural: 'Towns', title: { type: #STANDARD, value: 'City' } } }
define root view entity ZKP_C_TOWNS_DET
  as projection on ZKP_I_TOWNS_DET
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
      @UI: {
            lineItem:       [ { position: 30, importance: #HIGH, label: 'Latitude' } ],
            identification: [ { position: 30, label: 'Latitude' } ] }
      Latitude,
      @UI: {
      lineItem:       [ { position: 40, importance: #HIGH, label: 'Longitude' } ],
      identification: [ { position: 40, label: 'Longitude' } ] }
      Longitude,
      @UI: {
//      lineItem:       [ { position: 50, importance: #HIGH, label: 'URL' } ],
      identification: [ { position: 50, label: 'URL', url: 'Url', type: #WITH_URL } ] }
      Url,
      @UI: {
//      lineItem:       [ { position: 60, importance: #HIGH, label: 'Mayor' } ],
      identification: [ { position: 60, label: 'Mayor' } ] }
      Mayor,
      @UI: {
//      lineItem:       [ { position: 70, importance: #HIGH, label: 'Population' } ],
      identification: [ { position: 70, label: 'Population' } ] }
      Population,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      @UI.hidden: true
      LastChangedAt,
      LocalLastChangedAt,

      /* Associations */
      _Prediction,
      _WeatFacts

}
