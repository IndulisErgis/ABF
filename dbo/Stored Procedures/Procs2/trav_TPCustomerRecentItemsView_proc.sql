
CREATE PROCEDURE [dbo].[trav_TPCustomerRecentItemsView_proc]
@CustId pCustID,
@CompanyInfoID bigint,
@CustomerGroup varchar(2) = NULL,
@LocId pLocId,
@AllowDiscontinued bit,
@MaxCount smallint = 100

AS
SET NOCOUNT ON

BEGIN TRY

	CREATE TABLE #TPItems
	(
		ItemId pItemId,
		PRIMARY KEY (ItemId)
	) 

	INSERT INTO #TPItems
		SELECT DISTINCT i.[ItemID] FROM [TravPortal].[dbo].[tblTpItemInfo] i
			LEFT JOIN [TravPortal].[dbo].[tblTpSiteItemInfo] s ON i.[ID]=s.[ItemInfoID]
		WHERE i.[CompanyInfoID] = @CompanyInfoID AND i.[Status] = 0 AND (@CustomerGroup IS NULL OR s.[SiteGroup] = @CustomerGroup)

	SELECT TOP(@MaxCount) [TransId], [TransDate], [TransType], [ItemId], [Description], [Uom], [Quantity]
	FROM (
		--Items from SO transaction
		SELECT h.[TransId], h.[InvcDate] AS [TransDate], h.[TransType], d.[ItemId] AS [ItemId], d.[Descr] AS [Description],	d.[UnitsSell] AS [Uom], d.[QtyOrdSell] AS [Quantity]
		FROM [dbo].[tblSoTransDetail] d
			INNER JOIN [dbo].[tblSoTransHeader] h ON d.[TransID] = h.[TransId]
			INNER JOIN [dbo].[tblInItem] i ON d.[ItemId] = i.[ItemId]
			INNER JOIN #TPItems tp ON tp.ItemId = i.ItemId
			INNER JOIN [dbo].[tblInItemLoc] l ON i.[ItemId] = l.[ItemId]
		WHERE h.[CustId] = @CustId AND h.VoidYn = 0 AND h.TransType > 0
			AND l.[LocId] = @LocId AND (l.[ItemLocStatus] = 1 OR (@AllowDiscontinued = 1 AND l.[ItemLocStatus] = 2))

		UNION ALL

		--Items from history
		SELECT d.[TransID], h.[InvcDate] AS [TransDate], h.[TransType], d.[PartId] AS [ItemId], d.[Desc] AS [Description], d.[UnitsSell] AS [Uom], d.[QtyOrdSell] AS [Quantity]
		FROM [dbo].[tblArHistDetail] d
			INNER JOIN [dbo].[tblArHistHeader] h ON h.[PostRun] = d.[PostRun] AND h.[TransId] = d.[TransID]
			INNER JOIN [dbo].[tblInItem] i ON d.[PartId] = i.[ItemId]
			INNER JOIN #TPItems tp ON tp.ItemId = i.ItemId
			INNER JOIN [dbo].[tblInItemLoc] l ON i.[ItemId] = l.[ItemId]
		WHERE h.[CustId] = @CustId AND h.VoidYn = 0 AND h.TransType > 0 AND h.[Source] = 1
			AND l.[LocId] = @LocId AND (l.[ItemLocStatus] = 1 OR (@AllowDiscontinued = 1 AND l.[ItemLocStatus] = 2))
	) t
	ORDER BY [TransDate] DESC

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_TPCustomerRecentItemsView_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_TPCustomerRecentItemsView_proc';

