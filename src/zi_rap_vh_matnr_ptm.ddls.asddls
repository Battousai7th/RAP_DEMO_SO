@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help RAP for Material'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
/*+[hideWarning] { "IDS" : [ "CARDINALITY_CHECK" ]  } */
define view entity ZI_RAP_VH_MATNR_PTM as select from zdb_matnr_f4
  association [0..1] to ZI_RAP_SO_I_PTM as _SalesOrderItems 
  on $projection.Matnr = _SalesOrderItems.Product
{
    key matnr as Matnr,
    mtart,
    @EndUserText.label: 'Quantity'
    @Semantics.quantity.unitOfMeasure : 'QuantityUnit'
    _SalesOrderItems.Quantity,
    @EndUserText.label: 'Quantity Unit'
    _SalesOrderItems.QuantityUnit,
    @Semantics.amount.currencyCode : '_SalesOrderItems.CurrencyCode'
    _SalesOrderItems
}
