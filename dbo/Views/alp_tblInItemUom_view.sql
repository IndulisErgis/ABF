create view alp_tblInItemUom_view as
  
select ItemId,Uom,ConvFactor,PenaltyType,PenaltyAmt,UPCcode,ts,MinSaleQty,Weight,Cast( CF as nvarchar(max)) as CF
From tblInItemUom