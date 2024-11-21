@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View RAP for Sales Order Item'
define view entity ZI_RAP_SO_I_PTM
  as select from zdb_rap_so_i_ptm
  association to parent ZR_RAP_SO_PTM as _SalesOrder 
  on $projection.SalesOrder = _SalesOrder.SalesOrder
{
  key so_nr                 as SalesOrder,
  key so_it_pos             as ItemLine,
      it_note               as ItemNote,
      product_id            as Product,
      quantity              as Quantity,
      quantity_unit         as QuantityUnit,
      @EndUserText.label: 'Unit Price'
      @Semantics.amount.currencyCode : 'CurrencyCode'
      price                 as Price,
      currency_code         as CurrencyCode,
      draft_uuid            as DraftUuid,
      created_at            as CreatedAt,
      created_by            as CreatedBy,
      last_changed_at       as LastChangedAt,
      last_changed_by       as LastChangedBy,
      local_last_changed_at as LocalLastChangedAt,
      _SalesOrder
}
