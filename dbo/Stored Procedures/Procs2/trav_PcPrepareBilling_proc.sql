
CREATE PROCEDURE dbo.trav_PcPrepareBilling_proc
@BatchId pBatchId
AS
BEGIN TRY

	--Populate table tblPcWIPHeader with project detail record that meet filter critera 
	--and do not already exist in table tblPcWIPHeader
	INSERT INTO dbo.tblPcWIPHeader(BatchId, ProjectDetailId, FixedFeeAmtAvail, FixedFeeAmtApply, DepositAmt, DepositAmtAvail, DepositAmtApply,
		CustId, ProjectName, PhaseId, TaskId, FixedFee, FixedFeeAmt, ProjectDetailDescription, SiteID)
	SELECT @BatchId, d.Id, 0, 0, 0, 0, 0, p.CustId, p.ProjectName, d.PhaseId, d.TaskId, d.FixedFee, d.FixedFeeAmt, d.[Description], s.SiteID
	FROM #tmpProjectDetailList t 
	INNER JOIN dbo.tblPcProjectDetail d ON t.Id = d.Id 
	INNER JOIN dbo.trav_PcProject_view p ON d.ProjectId = p.Id
	LEFT JOIN dbo.tblPcProjectDetailSiteInfo s ON s.ProjectDetailID =  p.ProjectDetailID
	LEFT JOIN dbo.tblPcWIPHeader h ON d.Id = h.ProjectDetailId
	WHERE h.Id IS NULL

	UPDATE dbo.tblPcWIPHeader SET FixedFeeAmtAvail = d.FixedFeeAmt - ISNULL(f.TotalFixedFeeBilled,0),
		FixedFeeAmtApply = d.FixedFeeAmt - ISNULL(f.TotalFixedFeeBilled,0)
	FROM dbo.tblPcWIPHeader INNER JOIN dbo.tblPcProjectDetail d ON dbo.tblPcWIPHeader.ProjectDetailId = d.Id 
		LEFT JOIN (SELECT d.Id, SUM(a.ExtIncome) AS TotalFixedFeeBilled
			FROM dbo.tblPcWIPHeader h INNER JOIN dbo.tblPcProjectDetail d ON h.ProjectDetailId = d.Id
				INNER JOIN dbo.tblPcActivity a ON d.Id = a.ProjectDetailId 
			WHERE d.FixedFee = 1 AND a.[Type] = 6 --fixed fee billing
			GROUP BY d.Id) f on d.Id = f.Id
	WHERE dbo.tblPcWIPHeader.BatchId = @BatchId AND d.FixedFee = 1
	
	UPDATE dbo.tblPcWIPHeader SET DepositAmt = ISNULL(d.TotalDeposit,0), 
		DepositAmtAvail = ISNULL(CASE WHEN d.TotalDepositAvail > 0 THEN d.TotalDepositAvail ELSE 0 END,0)
	FROM dbo.tblPcWIPHeader LEFT JOIN (	SELECT d.Id, SUM(CASE WHEN a.[Type] = 4 AND a.BillOnHold = 0 THEN a.ExtIncome WHEN a.[Type] = 5 THEN -a.ExtIncome END) AS TotalDepositAvail,
			SUM(CASE a.[Type] WHEN 4 THEN a.ExtIncome ELSE 0 END) AS TotalDeposit
		FROM dbo.tblPcWIPHeader h INNER JOIN dbo.tblPcProjectDetail d ON h.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcActivity a ON d.Id = a.ProjectDetailId 
		WHERE a.[Type] IN (4,5) --deposit, deposit applied
		GROUP BY d.Id) d ON dbo.tblPcWIPHeader.ProjectDetailId = d.Id
	WHERE dbo.tblPcWIPHeader.BatchId = @BatchId

	EXEC dbo.trav_PcPrepareBilling_RefreshActivity_proc @BatchId
		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcPrepareBilling_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcPrepareBilling_proc';

