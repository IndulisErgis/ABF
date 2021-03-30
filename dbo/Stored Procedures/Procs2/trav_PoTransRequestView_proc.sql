CREATE PROCEDURE [dbo].[trav_PoTransRequestView_proc]
AS
SET NOCOUNT ON;
BEGIN TRY

	SELECT h.TransId, h.VendorId, v.Name AS VendorName, h.OrderedBy, h.TransDate, h.Notes, 
		h.BatchId, h.CurrencyId, h.ReqShipDate, h.ShipToID, h.ShipToName,
		r.RequestedBy, r.RequestedDate, r.[Status],
		s.BudgetPeriod, s.BudgetYear, s.RouteId, s.[Level], s.NotifyDate,
		s.Comments As RequestNotes, u.Username NotifyUserId, u.Name As NotifyUserName,
		((h.MemoTaxable + h.MemoNonTaxable + h.MemoFreight + h.MemoMisc + h.MemoSalesTax) - h.MemoPrepaid) As MemoTotal,
		((h.MemoTaxableFgn + h.MemoNonTaxableFgn + h.MemoFreightFgn + h.MemoMiscFgn + h.MemoSalesTaxFgn) - h.MemoPrepaidFgn) As MemoTotalFgn
	FROM #TransList t
		INNER JOIN dbo.tblPoTransHeader h ON t.TransId = h.TransId
		LEFT JOIN dbo.tblApVendor v ON h.VendorId = v.VendorId
		LEFT JOIN dbo.tblPoTransRequest r ON h.TransId = r.TransId
		LEFT JOIN dbo.tblPoTransRequestStatus s ON h.TransId = s.TransId
		LEFT JOIN dbo.tblPoRequestUser u On s.NotifyUser = u.ID
		
	SELECT d.TransID, d.ItemId, d.LocId, d.QtyOrd, d.Units, ISNULL(d.ProjID, jd.Id) ProjID, 
		ISNULL(d.ProjName, j.ProjectName) ProjName, ISNULL(d.TaskID, tk.TaskId) TaskID, 
		ISNULL(d.TaskName, tk.[Description]) TaskName, ISNULL(d.PhaseID, jd.PhaseId) PhaseID, 
		ISNULL(d.PhaseName, ph.[Description]) PhaseName, d.EntryNum, d.ItemType, d.GLAcct, 
		d.GLDesc, d.Descr, d.GLAcctAccrual, d.UnitCost, d.ExtCost, d.UnitCostFgn, d.ExtCostFgn 
	FROM #TransList t
		INNER JOIN dbo.tblPoTransDetail d  ON t.TransId = d.TransId
		LEFT JOIN dbo.tblPcProjectDetail jd on jd.Id = d.ProjectDetailId
		LEFT JOIN dbo.tblPcProject j on j.Id = jd.ProjectId 
		LEFT JOIN dbo.tblPcPhase ph on ph.PhaseId = jd.PhaseId
		LEFT JOIN dbo.tblPcTask tk on tk.TaskId = jd.TaskId
		
	SELECT h.TransId, ISNULL(CASE WHEN ISNULL(s.[Level], 0) > d.[Level] AND r.Response IS NULL THEN 3 ELSE r.Response END, 0) As Response, r.ResponseDate, 
		r.Comments As ResponseComments, u.Username, u.Name, 
		ISNULL(d.BudgetApproval, 0) As BudgetApproval
	FROM #TransList t
		INNER JOIN dbo.tblPoTransHeader h ON t.TransId = h.TransId
		LEFT JOIN dbo.tblPoTransRequestStatus s ON h.TransId = s.TransId
		LEFT JOIN dbo.tblPoRequestRouteDetail d ON s.RouteId = d.RouteId AND ((
			((h.MemoSalesTax + h.MemoNonTaxable + h.MemoTaxable + h.MemoFreight + h.MemoMisc) - h.MemoPrepaid) >= ISNULL(d.MinAmount, 0)  AND
			(ISNULL(d.MaxAmount, 0) = 0 OR ((h.MemoSalesTax + h.MemoNonTaxable + h.MemoTaxable + h.MemoFreight + h.MemoMisc) - h.MemoPrepaid) <= ISNULL(d.MaxAmount, 0)))
			OR ISNULL(d.BudgetApproval, 0) = 1)
		LEFT JOIN dbo.tblPoTransRequestResponse r ON h.TransId = r.TransId AND d.[Level] = r.[Level]
		LEFT JOIN dbo.tblPoRequestUser u On r.UserId = u.ID OR d.UserId = u.ID
	ORDER BY d.[Level]

	SELECT b.TransID, b.GLAcct, h.[Desc], b.BudgetBalance, b.OrderBalance, 
		b.PendingReq, ISNULL(d.OrderAmt, 0) As CurrentTotal,
		b.BudgetBalance - b.OrderBalance - b.PendingReq - ISNULL(d.OrderAmt, 0) As EstRemainBudget
	FROM #TransList t
		INNER JOIN dbo.tblPoTransRequestBudget b ON t.TransId = b.TransId
		INNER JOIN dbo.tblGlAcctHdr h On b.GLAcct = h.AcctId
		LEFT JOIN (
			SELECT d.TransId, d.GlAcct, SUM(ExtCost) As OrderAmt
			FROM #TransList t
				INNER JOIN dbo.tblPoTransDetail d ON t.TransId = d.TransID
			GROUP BY d.TransID, d.GLAcct) d On b.TransID = d.TransID AND b.GLAcct = d.GLAcct
			
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransRequestView_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransRequestView_proc';

