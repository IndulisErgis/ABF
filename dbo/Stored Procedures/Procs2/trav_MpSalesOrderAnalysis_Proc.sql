-- PET:http://problemtrackingsystem.osas.com/view.php?id=265152
CREATE PROCEDURE [dbo].[trav_MpSalesOrderAnalysis_Proc]  

@ReportFlag tinyint = 1--Report option flag (0=generates production orders, 1/2=returns resultset of what would be generated (1 by AssemblyId, 2 by SO Trans/order no)

AS
SET NOCOUNT ON
BEGIN TRY

	SELECT CASE WHEN @ReportFlag = 1 THEN a.AssemblyId Else h.TransId END SortBy,
		h.TransDate AS OrderDate, COALESCE(d.ReqShipDate, h.ReqShipDate) AS ProdDate, h.TransId AS SOTransId,
		h.CustId, h.CustPONum AS PurchaseOrder, a.AssemblyId,a.RevisionNo, d.LocId, d.UnitsBase AS UOMBase,
		d.QtyOrdSell * CASE WHEN ISNULL(d.ConversionFactor, 0) = 0 THEN 1 ELSE d.ConversionFactor END AS QtyRequired,
		ISNULL(b.Qty,0) AS QtyOnOrder, a.[Description],
		CASE WHEN d.QtyOrdSell * CASE WHEN ISNULL(d.ConversionFactor, 0) = 0 THEN 1 ELSE d.ConversionFactor END > ISNULL(b.Qty,0) 
			THEN d.QtyOrdSell * CASE WHEN ISNULL(d.ConversionFactor, 0) = 0 THEN 1 ELSE d.ConversionFactor END - ISNULL(b.Qty,0) ELSE 0 END AS QtyProduce
	FROM #tmpSalesOrderAnalysis t INNER JOIN dbo.tblSoTransDetail d ON t.TransId = d.TransID AND t.EntryNum = d.EntryNum
		INNER JOIN dbo.tblSoTransHeader h ON d.TransID = h.TransId
		INNER JOIN dbo.tblMbAssemblyHeader a ON d.ItemId = a.AssemblyId 
		LEFT JOIN 
			(SELECT OrderNo, AssemblyId, CustId, SUM(tmp.Qty * CASE WHEN ISNULL(u.ConvFactor, 0) = 0 THEN 1 ELSE u.ConvFactor END) Qty 
					, SalesOrder
             FROM ( SELECT o.OrderNo, o.AssemblyId, r.CustId, r.Qty, r.UOM, r.SalesOrder
                    FROM dbo.tblMpOrder o INNER JOIN dbo.tblMpOrderReleases r ON o.OrderNo = r.OrderNo
                    UNION ALL
                    SELECT OrderNo, AssemblyId, CustId, Qty, UOM, SalesOrder
                    FROM dbo.tblMpHistoryOrderReleases
                   ) tmp 
				LEFT JOIN dbo.tblInItemUOM u ON tmp.AssemblyId = u.ItemId AND tmp.UOM = u.UOM 
             GROUP BY OrderNo, AssemblyId, CustId, SalesOrder
            ) b ON h.TransId = b.SalesOrder AND d.ItemId = b.AssemblyId AND h.CustId = b.CustId
     WHERE a.DfltRevYn = 1
END TRY
BEGIN CATCH
     EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpSalesOrderAnalysis_Proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpSalesOrderAnalysis_Proc';

