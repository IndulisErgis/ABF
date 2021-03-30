
CREATE PROCEDURE [dbo].[trav_TpSalesRepCustomerSearch_proc]
@Filter int,
@SearchText nvarchar(500),
@SalesRepId pSalesRep,
@MaxCount int = 100,
@CurrId varchar(10) = null

AS
SET NOCOUNT ON
BEGIN TRY	
	IF @Filter = 2 --CustomerFilterOptions.SalesRepId
	BEGIN
		SELECT [CustId], [CustName], [Contact], [Region], [PostalCode], [Status] FROM (
			SELECT TOP (@MaxCount) * FROM [dbo].[tblArCust]
				WHERE [Status] = 0 AND [CcCompYn] = 0 AND ([CustId] LIKE @SearchText+'%' OR [CustName] LIKE '%'+@SearchText+'%' OR [Contact] LIKE '%'+@SearchText+'%' OR 
				[Region] LIKE @SearchText+'%' OR [PostalCode] LIKE @SearchText+'%') AND ([SalesRepId1] = @SalesRepId OR [SalesRepId2] = @SalesRepId OR
				[SalesRepId1] IN (Select [SecSalesRepId] FROM [dbo].[tblArSalesRepSec] WHERE [SalesRepID] = @SalesRepId) OR
				[SalesRepId2] IN (SELECT [SecSalesRepId] FROM [dbo].[tblArSalesRepSec] WHERE [SalesRepID] = @SalesRepId))) c
			ORDER BY [CustId]
	END
	ELSE --All other values
	BEGIN
		SELECT [CustId], [CustName], [Contact], [Region], [PostalCode], [Status] FROM (
			SELECT TOP (@MaxCount) * FROM [dbo].[tblArCust]
				WHERE [Status] = 0 AND [CcCompYn] = 0 AND ([CustId] LIKE @SearchText+'%' OR [CustName] LIKE '%'+@SearchText+'%' OR [Contact] LIKE '%'+@SearchText+'%' OR
				[Region] LIKE @SearchText+'%' OR [PostalCode] LIKE @SearchText+'%')) c
			ORDER BY CustId
	END
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_TpSalesRepCustomerSearch_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_TpSalesRepCustomerSearch_proc';

