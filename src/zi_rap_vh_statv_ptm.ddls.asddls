@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help RAP for Delivery Status'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Search.searchable: true
/*+[hideWarning] { "IDS" : [ "KEY_CHECK" ]  } */
define view entity ZI_RAP_VH_STATV_PTM
  as select from zdb_dd07t_f4
{
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
  key valpos,
  
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
      @Search.fuzzinessThreshold: 0.8       //Ti le filter = 80%
      ddtext     as Description,

      @Search.ranking: #LOW
      domvalue_l as Value
}
where
      zdb_dd07t_f4.ddlanguage = abap.lang'E'
