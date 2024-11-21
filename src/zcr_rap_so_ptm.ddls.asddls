@EndUserText.label: 'Root Projection View RAP for Sales Order'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@ObjectModel.semanticKey: ['SalesOrder'] //Bold Key
define root view entity ZCR_RAP_SO_PTM
  provider contract transactional_query
  as projection on ZR_RAP_SO_PTM
{
      @EndUserText.label: 'Sales Order'
  key SalesOrder,
      @EndUserText.label: 'Order Date'
      OrderDate,
      @EndUserText.label: 'Order Note'
      Note,
      @EndUserText.label: 'Sold To Party'
      SoldToParty,
      @EndUserText.label: 'Not Available'
      NotAvailable,
      @EndUserText.label: 'Currency'
      Currency,
      @EndUserText.label: 'Tax Amout'
      @Semantics.amount.currencyCode : 'Currency'
      TaxAmount,
      @EndUserText.label: 'Lifecycle Status'
      LifecycleStatus,
      @EndUserText.label: 'Billing Status'
      BillingStatus,
      @EndUserText.label: 'Delivery Status'
      DeliveryStatus,
      DeliveryStatusCriticality,                    //Color of DeliveryStatus field
      @EndUserText.label: 'Payment Method'
      PaymentMethod,
      @EndUserText.label: 'Payment Term'
      PaymentTerm,
      @Semantics.systemDateTime.createdAt: true
      CreatedAt,
      @Semantics.user.createdBy: true
      CreatedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,
      @Semantics.user.lastChangedBy: true
      LastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      /* Associations */
      _SalesOrderItems : redirected to composition child ZC_RAP_SO_I_PTM
}
