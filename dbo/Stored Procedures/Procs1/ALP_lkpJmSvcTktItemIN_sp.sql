
CREATE PROCEDURE dbo.ALP_lkpJmSvcTktItemIN_sp
	@LocId pLocId
As
SET NOCOUNT ON
SELECT [ALP_tblInItem_view].[ItemId], [ALP_tblInItem_view].[Descr], [ALP_tblInItemLocation_view].[AlpDfltPts], [ALP_tblInItem_view].[ItemType], [ALP_tblInItemLocation_view].[GLAcctCode], 
	[ALP_tblInItemLocation_view].[LocId], [ALP_tblInItem_view].[AlpServiceType] 
	FROM ALP_tblInItem_view INNER JOIN ALP_tblInItemLocation_view ON [ALP_tblInItem_view].[ItemId]=[ALP_tblInItemLocation_view].[ItemId] 
	WHERE ((([ALP_tblInItemLocation_view].[LocId])= @LocId) And (([ALP_tblInItem_view].[AlpServiceType]) Is Null Or ([ALP_tblInItem_view].[AlpServiceType])=1 Or ([ALP_tblInItem_view].[AlpServiceType])=2)) 
	ORDER BY [ALP_tblInItem_view].[ItemId]