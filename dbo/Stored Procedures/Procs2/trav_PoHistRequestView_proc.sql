CREATE PROCEDURE [dbo].[trav_PoHistRequestView_proc]
AS
SET NOCOUNT ON;
BEGIN TRY
	SELECT h.TransId, h.VendorId, v.Name AS VendorName, h.OrderedBy, h.TransDate, h.Notes, 
		h.BatchId, h.CurrencyId, h.ReqShipDate, h.ShipToID, h.ShipToName,
		r.RequestedBy, r.RequestedDate, CASE WHEN resp.Response = 2 THEN 3 ELSE 2 END AS [Status],
		h.BudgetPeriod, h.BudgetYear, h.RouteId,
		h.RequestComments As RequestNotes,
		(h.MemoTaxable + h.MemoNonTaxable + h.MemoFreight + h.MemoMisc + h.MemoSalesTax) As MemoTotal,
		(h.MemoTaxableFgn + h.MemoNonTaxableFgn + h.MemoFreightFgn + h.MemoMiscFgn + h.MemoSalesTaxFgn) As MemoTotalFgn,
		h.HdrRef, h.PostRun
	FROM #TransList t
		INNER JOIN dbo.tblPoHistRequestHeader h ON t.PostRun = h.PostRun AND t.TransId = h.TransId
		LEFT JOIN dbo.tblApVendor v ON h.VendorId = v.VendorId
		LEFT JOIN dbo.tblPoTransRequest r ON h.TransId = r.TransId
		LEFT JOIN dbo.tblPoHistHeader hh ON h.HdrRef = hh.HdrRef
		LEFT JOIN (
			SELECT PostRun, TransId, MAX(Response) AS Response, MAX(ResponseDate) AS ResponseDate 
			FROM dbo.tblPoHistRequestResponse GROUP BY PostRun, TransId
		) resp ON h.PostRun = resp.PostRun AND h.TransId = resp.TransId 
		
	SELECT d.TransID, d.ItemId, d.LocId, d.QtyOrd, d.Units, ISNULL(d.ProjID, jd.Id) ProjID, 
		ISNULL(d.ProjName, j.ProjectName) ProjName, ISNULL(d.TaskID, tk.TaskId) TaskID, 
		ISNULL(d.TaskName, tk.[Description]) TaskName, ISNULL(d.PhaseID, jd.PhaseId) PhaseID, 
		ISNULL(d.PhaseName, ph.[Description]) PhaseName, d.EntryNum, d.ItemType, d.GLAcct, 
		d.GLDesc, d.Descr, d.GLAcctAccrual, d.UnitCost, d.ExtCost, 
		d.UnitCostFgn, d.ExtCostFgn, t.PostRun
	FROM #TransList t
		INNER JOIN dbo.tblPoHistRequestDetail d  ON t.PostRun = d.PostRun AND t.TransId = d.TransId
		LEFT JOIN dbo.tblPcProjectDetail jd on jd.Id = d.ProjectDetailId
		LEFT JOIN dbo.tblPcProject j on j.Id = jd.ProjectId 
		LEFT JOIN dbo.tblPcPhase ph on ph.PhaseId = jd.PhaseId
		LEFT JOIN dbo.tblPcTask tk on tk.TaskId = jd.TaskId
		
	SELECT r.TransId, r.Response, r.ResponseDate, r.Comments As ResponseComments,
		u.Username, u.Name, t.PostRun
	FROM #TransList t
		INNER JOIN dbo.tblPoHistRequestResponse r ON t.PostRun = r.PostRun AND t.TransId = r.TransId
		INNER JOIN dbo.tblPoRequestUser u On r.ResponseUser = u.ID

	SELECT b.TransID, b.GLAcct, h.[Desc], b.BudgetBalance, b.OrderBalance, 
		b.PendingReq, ISNULL(d.OrderAmt, 0) As CurrentTotal,
		b.BudgetBalance - b.OrderBalance - b.PendingReq - ISNULL(d.OrderAmt, 0) As EstRemainBudget, t.PostRun
	FROM #TransList t
		INNER JOIN dbo.tblPoHistRequestBudget b ON t.PostRun = b.PostRun AND t.TransId = b.TransId
		INNER JOIN dbo.tblGlAcctHdr h On b.GLAcct = h.AcctId
		LEFT JOIN (
			SELECT d.PostRun, d.TransId, GlAcct, SUM(ExtCost) As OrderAmt
			FROM #TransList t
				INNER JOIN dbo.tblPoHistRequestDetail d ON t.PostRun = d.PostRun AND t.TransId = d.TransID
			GROUP BY d.PostRun, d.TransID, GLAcct) d On b.PostRun = d.PostRun and b.TransID = d.TransID AND b.GLAcct = d.GLAcct
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoHistRequestView_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoHistRequestView_proc';

