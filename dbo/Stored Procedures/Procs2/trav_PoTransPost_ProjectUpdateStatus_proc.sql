
CREATE PROCEDURE dbo.trav_PoTransPost_ProjectUpdateStatus_proc
AS
SET NOCOUNT ON
BEGIN TRY
	
	CREATE TABLE #TransPost9h 
	(TransID nvarchar(8)) 
	
	--Build a list of completed transactions
	INSERT INTO #TransPost9h 
	SELECT h.TransId 
	FROM #PostTransList b INNER JOIN 
	(tblPoTransHeader h INNER JOIN tblPoTransDetail d ON h.TransId = d.TransID) 
	ON b.TransId = h.TransId 
	GROUP BY h.TransId 
	HAVING MIN(d.LineStatus) = 1 
	
	UPDATE dbo.tblPcActivity SET Status = 2 
	FROM #TransPost9h t INNER JOIN dbo.tblPoTransLotRcpt r ON t.TransID = r.TransId
		INNER JOIN dbo.tblPcActivity ON r.ActivityId = dbo.tblPcActivity.Id  

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_ProjectUpdateStatus_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_ProjectUpdateStatus_proc';

