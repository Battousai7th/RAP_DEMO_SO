@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root Interface View RAP for Sales Order'
@ObjectModel.semanticKey: ['SoldToParty']
@ObjectModel.resultSet.sizeCategory: #XS //Drop down list
define root view entity ZR_RAP_SO_PTM
  as select from zdb_rap_so_ptm
  composition [0..*] of ZI_RAP_SO_I_PTM as _SalesOrderItems
{
  key so_nr                 as SalesOrder,
      so_date               as OrderDate,
      note                  as Note,
      sold_to_party         as SoldToParty,
      not_available         as NotAvailable,
      currency              as Currency,
      tax_amount            as TaxAmount,
      lifecycle_status      as LifecycleStatus,
      billing_status        as BillingStatus,
      delivery_status       as DeliveryStatus,
      case delivery_status
        when 'A' then 1 -- 'Not yet processed'      |  1: red colour
        when 'B' then 2 -- 'Partially processed'    |  2: yellow colour
        when 'C' then 3 -- 'Completelly processed'  |  3: green colour
                 else 0 -- 'Not Relevant'           |  0: unknown
      end                   as DeliveryStatusCriticality,           //Color of DeliveryStatus field
      payment_method        as PaymentMethod,
      payment_term          as PaymentTerm,
      created_at            as CreatedAt,
      created_by            as CreatedBy,
      last_changed_at       as LastChangedAt,
      last_changed_by       as LastChangedBy,
      local_last_changed_at as LocalLastChangedAt,
      _SalesOrderItems
}
