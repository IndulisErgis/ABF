
CREATE PROCEDURE dbo.trav_PcBillingHistoryView_proc 
@FiscalYear smallint = 2010,
@FiscalPeriod smallint = 5
AS
BEGIN TRY
SET NOCOUNT ON

	SELECT d.CustId, d.CustName, d.ProjectName, d.ProjectManager, d.Rep1Id, d.Rep2Id, d.PhaseId, d.TaskId , d.LastDateBilled, t.ProjectDetailId, d.[Status],
		ISNULL(PrTDAmount,0) AS PrTDAmount, ISNULL(PrTDWriteUD,0) AS PrTDWriteUD, ISNULL(YTDAmount,0) AS YTDAmount, 
		ISNULL(PTDAmount,0) AS PTDAmount, ISNULL(YTDWriteUD,0) AS YTDWriteUD, ISNULL(PTDWriteUD,0) AS PTDWriteUD, 
		ISNULL(DepositAmount,0) AS DepositAmount, ISNULL(DepositAppliedAmount,0) AS DepositAppliedAmount, ISNULL(DepositBalance,0) AS DepositBalance
	FROM #tmpProjectDetailList t INNER JOIN dbo.trav_PcProjectTask_view d ON t.ProjectDetailId = d.Id
		LEFT JOIN
		(
		SELECT ProjectDetailId, SUM(BilledAmount) AS PrTDAmount, SUM(WriteUD) AS PrTDWriteUD,
			SUM(CASE WHEN FiscalYear = @FiscalYear THEN BilledAmount ELSE 0 END) AS YTDAmount, 
			SUM(CASE WHEN FiscalYear = @FiscalYear AND FiscalPeriod = @FiscalPeriod THEN BilledAmount ELSE 0 END) AS PTDAmount, 
			SUM(CASE WHEN FiscalYear = @FiscalYear THEN WriteUD ELSE 0 END) AS YTDWriteUD, 
			SUM(CASE WHEN FiscalYear = @FiscalYear AND FiscalPeriod = @FiscalPeriod THEN WriteUD ELSE 0 END) AS PTDWriteUD,
			SUM(DepositAmount) AS DepositAmount, SUM(DepositAppliedAmount) AS DepositAppliedAmount, 
			SUM(DepositAmount) - SUM(DepositAppliedAmount) AS DepositBalance
		FROM
		(
		SELECT a.ProjectDetailId, ISNULL(l.FiscalYear,a.FiscalYear) AS FiscalYear, ISNULL(l.GLPeriod,a.FiscalPeriod) AS FiscalPeriod, 
			CASE WHEN a.[Type] BETWEEN 0 AND 3 THEN a.ExtIncomeBilled WHEN a.[Type] = 6 THEN a.ExtIncome WHEN a.[Type] = 7 THEN -a.ExtIncome ELSE 0 END AS BilledAmount, 
			CASE WHEN a.[Type] BETWEEN 0 AND 3 THEN a.ExtIncomeBilled - a.ExtIncome ELSE 0 END AS WriteUD,
			CASE WHEN a.[Type] = 4 THEN a.ExtIncome ELSE 0 END DepositAmount,
			CASE WHEN a.[Type] = 5 THEN a.ExtIncome ELSE 0 END DepositAppliedAmount
		FROM #tmpProjectDetailList t INNER JOIN  dbo.tblPcProjectDetail d ON t.ProjectDetailId = d.Id
			INNER JOIN dbo.tblPcActivity a ON d.Id = a.ProjectDetailId 
			LEFT JOIN dbo.tblArHistDetail h ON a.Id = h.TransHistId 
			LEFT JOIN dbo.tblArHistHeader l ON h.PostRun = l.PostRun AND h.TransID = l.TransId
		WHERE ((d.FixedFee = 0 AND a.[Type] BETWEEN 0 AND 3 AND a.[Status] = 4) OR --Non fixed fee billing
			(d.FixedFee = 1 AND a.[Type] = 6 AND (a.[Status] = 2 OR a.[Status] = 5)) OR --Fixed fee billing
			(a.[Type] IN (4,5,7) AND a.[Status] = 2)) AND ISNULL(l.VoidYn,0) = 0--Deposit, Deposit applied, Credit memo
		) AS BillingDetail 
		GROUP BY ProjectDetailId
		) AS b ON t.ProjectDetailId = b.ProjectDetailId
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcBillingHistoryView_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcBillingHistoryView_proc';

