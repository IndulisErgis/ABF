Create view alp_tblInItemLocUomPrice_view as
						 select ItemId,LocId,Uom,BrkId,PriceAvg,PriceMin,PriceList,PriceBase,ts,cast(CF as nvarchar(max))as CF FROM tblInItemLocUomPrice