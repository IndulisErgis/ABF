Create view Alp_tblJmPricePlanGenHeader_view
as
SELECT '<none>'as PriceId,'<none>' as [Description] ,0 as DfltAdjBase , 0 as DfltAdjType,0 as DfltAdjAmt
FROM Alp_tblJmPricePlanGenHeader
UNION SELECT Alp_tblJmPricePlanGenHeader.PriceId, Alp_tblJmPricePlanGenHeader.[Desc], Alp_tblJmPricePlanGenHeader.DfltAdjBase, Alp_tblJmPricePlanGenHeader.DfltAdjType,
 Alp_tblJmPricePlanGenHeader.DfltAdjAmt
FROM Alp_tblJmPricePlanGenHeader
WHERE (((Alp_tblJmPricePlanGenHeader.InactiveYN)=0))