
CREATE VIEW dbo.ALP_stpJmPricePlanGenHeader AS SELECT TOP 100 PERCENT PriceId, [Desc], DfltAdjBase, DfltAdjType, DfltAdjAmt, InactiveYN FROM dbo.ALP_tblJmPricePlanGenHeader