CREATE PROCEDURE [dbo].[trav_PoPrintOrders_Approval_proc]
	@TransId pTransId = NULL, --set for printing online 
	@PostRun pPostRun = NULL
AS
SET NOCOUNT ON;
BEGIN TRY
	
	IF (ISNULL(@PostRun, '') = '')
	BEGIN
		IF (ISNULL(@TransId, '') = '')
		BEGIN
			SELECT r.TransId, u.Name as ResponseUser, r.ResponseDate, 
			CASE  
				WHEN ISNULL(r.Response, -1) = 0 THEN 'PENDING'
				WHEN ISNULL(r.Response, -1) = 1 THEN 'APPROVED'
				WHEN ISNULL(r.Response, -1) = 2 THEN 'DECLINED'
				WHEN ISNULL(r.Response, -1) = -1 THEN 'SKIPPED'
			END As Response,
				((h.MemoTaxable + h.MemoNonTaxable + h.MemoFreight + h.MemoMisc + h.MemoSalesTax) - h.MemoPrepaid) As MemoTotal, h.PostRun
			FROM #tmpTransactionList l
				INNER JOIN dbo.tblPoTransHeader t On l.TransId = t.TransId
				INNER JOIN dbo.tblPoHistRequestHeader h On t.HdrRef = h.HdrRef
				INNER JOIN dbo.tblPoHistRequestResponse r On r.TransId = h.TransId AND r.PostRun = h.PostRun
				INNER JOIN dbo.tblPoRequestUser u On r.ResponseUser = u.Id
		END
		ELSE
		BEGIN
			SELECT r.TransId, u.Name as ResponseUser, r.ResponseDate, 
			CASE  
				WHEN ISNULL(r.Response, -1) = 0 THEN 'PENDING'
				WHEN ISNULL(r.Response, -1) = 1 THEN 'APPROVED'
				WHEN ISNULL(r.Response, -1) = 2 THEN 'DECLINED'
				WHEN ISNULL(r.Response, -1) = -1 THEN 'SKIPPED'
			END As Response,
				((h.MemoTaxable + h.MemoNonTaxable + h.MemoFreight + h.MemoMisc + h.MemoSalesTax) - h.MemoPrepaid) As MemoTotal, h.PostRun
			FROM dbo.tblPoTransHeader t
				INNER JOIN dbo.tblPoHistRequestHeader h On t.HdrRef = h.HdrRef
				INNER JOIN dbo.tblPoHistRequestResponse r On r.TransId = h.TransId AND r.PostRun = h.PostRun
				INNER JOIN dbo.tblPoRequestUser u On r.ResponseUser = u.Id
			WHERE t.TransId = @TransId

		END
	END
	ELSE
	BEGIN
		SELECT r.TransId, u.Name as ResponseUser, r.ResponseDate, 
			CASE  
				WHEN ISNULL(r.Response, -1) = 0 THEN 'PENDING'
				WHEN ISNULL(r.Response, -1) = 1 THEN 'APPROVED'
				WHEN ISNULL(r.Response, -1) = 2 THEN 'DECLINED'
				WHEN ISNULL(r.Response, -1) = -1 THEN 'SKIPPED'
			END As Response,
				((h.MemoTaxable + h.MemoNonTaxable + h.MemoFreight + h.MemoMisc + h.MemoSalesTax) - h.MemoPrepaid) As MemoTotal, h.PostRun
			FROM dbo.tblPoHistHeader t
				INNER JOIN dbo.tblPoHistRequestHeader h On t.HdrRef = h.HdrRef
				INNER JOIN dbo.tblPoHistRequestResponse r On r.TransId = h.TransId AND r.PostRun = h.PostRun
				INNER JOIN dbo.tblPoRequestUser u On r.ResponseUser = u.Id
			WHERE t.TransId = @TransId AND t.PostRun = @PostRun
	END
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoPrintOrders_Approval_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoPrintOrders_Approval_proc';

