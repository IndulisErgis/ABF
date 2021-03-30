
CREATE PROCEDURE [dbo].[tsmPcMigrationStep2]

AS
BEGIN TRY
SET NOCOUNT ON
	--Billable fixed fee project, status is not closed
	--Reverse GL entries need to be entered due to design change in 11.

	--WIP account and Income account
	--History records that are not fixed fee adjustment, has non-zero income, status is INP
	SELECT 'Fixed billable project posted income' AS [Description], h.TransHistId, h.CustId, h.ProjId, NULL AS PhaseId, NULL AS TaskId, h.ExtFinalInc, h.GLAcctWIP, h.GLAcctSales AS GLAcctIncome
	FROM dbo.tblJcTransHistory h INNER JOIN dbo.tblJcProject p ON h.CustId = p.CustId AND h.ProjId = p.ProjId
	WHERE p.[Status] = 1 AND p.FixedFee = 1 AND p.ClosedYn = 0 AND h.PhaseId IS NULL AND h.[Source] <> 'TF'
		AND h.ExtFinalInc <> 0 AND h.[Status] = 'INP'
	UNION ALL
	SELECT 'Fixed billable project posted income' AS [Description], h.TransHistId, h.CustId, h.ProjId, h.PhaseId, NULL AS TaskId,h.ExtFinalInc, h.GLAcctWIP, h.GLAcctSales
	FROM dbo.tblJcTransHistory h INNER JOIN dbo.tblJcProjPhase p 
		ON h.CustId = p.CustId AND h.ProjId = p.ProjId AND h.PhaseId = p.PhaseId
	WHERE p.[Status] = 1 AND p.FixedFee = 1 AND p.ClosedYn = 0 AND h.PhaseId IS NOT NULL AND h.TaskId IS NULL 
		AND h.[Source] <> 'TF' AND h.ExtFinalInc <> 0 AND h.[Status] = 'INP'
	UNION ALL
	SELECT 'Fixed billable project posted income' AS [Description], h.TransHistId, h.CustId, h.ProjId, h.PhaseId, h.TaskId, h.ExtFinalInc, h.GLAcctWIP, h.GLAcctSales
	FROM dbo.tblJcTransHistory h INNER JOIN dbo.tblJcProjTask p 
		ON h.CustId = p.CustId AND h.ProjId = p.ProjId AND h.PhaseId = p.PhaseId AND h.TaskId = p.TaskId
		INNER JOIN dbo.tblJcProjPhase s ON p.CustId = s.CustId AND p.ProjId = s.ProjId AND p.PhaseId = s.PhaseId
	WHERE p.[Status] = 1 AND s.FixedFee = 1 AND p.ClosedYn = 0 AND h.TaskId IS NOT NULL 
		AND h.[Source] <> 'TF' AND h.ExtFinalInc <> 0 AND h.[Status] = 'INP'

	--Fixed Fee account and Income account
	--History records that are not fixed fee adjustment, has non-zero income, status is BIL
	SELECT 'Fixed billable project billed income' AS [Description], h.TransHistId, h.CustId, h.ProjId, NULL AS PhaseId, NULL AS TaskId, h.ExtFinalInc, h.GLAcctDeferred AS GLAcctFixedFeeBilling, h.GLAcctSales AS GLAcctIncome
	FROM dbo.tblJcTransHistory h INNER JOIN dbo.tblJcProject p ON h.CustId = p.CustId AND h.ProjId = p.ProjId
	WHERE p.[Status] = 1 AND p.FixedFee = 1 AND p.ClosedYn = 0 AND h.PhaseId IS NULL AND h.[Source] <> 'TF'
		AND h.ExtFinalInc <> 0 AND h.[Status] = 'BIL'
	UNION ALL
	SELECT 'Fixed billable project billed income' AS [Description], h.TransHistId, h.CustId, h.ProjId, h.PhaseId, NULL AS TaskId, h.ExtFinalInc, h.GLAcctDeferred, h.GLAcctSales
	FROM dbo.tblJcTransHistory h INNER JOIN dbo.tblJcProjPhase p 
		ON h.CustId = p.CustId AND h.ProjId = p.ProjId AND h.PhaseId = p.PhaseId
	WHERE p.[Status] = 1 AND p.FixedFee = 1 AND p.ClosedYn = 0 AND h.PhaseId IS NOT NULL AND h.TaskId IS NULL 
		AND h.[Source] <> 'TF' AND h.ExtFinalInc <> 0 AND h.[Status] = 'BIL'
	UNION ALL
	SELECT 'Fixed billable project billed income' AS [Description], h.TransHistId, h.CustId, h.ProjId, h.PhaseId, h.TaskId,h.ExtFinalInc, h.GLAcctDeferred, h.GLAcctSales
	FROM dbo.tblJcTransHistory h INNER JOIN dbo.tblJcProjTask p 
		ON h.CustId = p.CustId AND h.ProjId = p.ProjId AND h.PhaseId = p.PhaseId AND h.TaskId = p.TaskId
		INNER JOIN dbo.tblJcProjPhase s ON p.CustId = s.CustId AND p.ProjId = s.ProjId AND p.PhaseId = s.PhaseId
	WHERE p.[Status] = 1 AND s.FixedFee = 1 AND p.ClosedYn = 0 AND h.TaskId IS NOT NULL 
		AND h.[Source] <> 'TF' AND h.ExtFinalInc <> 0 AND h.[Status] = 'BIL'
		
	--Fixed Fee acount and Adjustment account
	--History records that are fixed fee adjustment, has non-zero adjustment, status is BIL
	SELECT 'Fixed billable project posted fixed fee adjustment' AS [Description], h.TransHistId, h.CustId, h.ProjId, NULL AS PhaseId, NULL AS TaskId, h.ExtFinalInc, h.GLAcctDeferred AS GLAcctFixedFeeBilling, h.GLAcctAdjust
	FROM dbo.tblJcTransHistory h INNER JOIN dbo.tblJcProject p ON h.CustId = p.CustId AND h.ProjId = p.ProjId
	WHERE p.[Status] = 1 AND p.FixedFee = 1 AND p.ClosedYn = 0 AND h.PhaseId IS NULL AND h.[Source] = 'TF'
		AND h.ExtFinalInc <> 0 AND h.[Status] = 'BIL'
	UNION ALL
	SELECT 'Fixed billable project posted fixed fee adjustment' AS [Description], h.TransHistId, h.CustId, h.ProjId, h.PhaseId, NULL AS TaskId, h.ExtFinalInc, h.GLAcctDeferred, h.GLAcctAdjust
	FROM dbo.tblJcTransHistory h INNER JOIN dbo.tblJcProjPhase p 
		ON h.CustId = p.CustId AND h.ProjId = p.ProjId AND h.PhaseId = p.PhaseId
	WHERE p.[Status] = 1 AND p.FixedFee = 1 AND p.ClosedYn = 0 AND h.PhaseId IS NOT NULL AND h.TaskId IS NULL 
		AND h.[Source] = 'TF' AND h.ExtFinalInc <> 0 AND h.[Status] = 'BIL'
	UNION ALL
	SELECT 'Fixed billable project posted fixed fee adjustment' AS [Description], h.TransHistId, h.CustId, h.ProjId, h.PhaseId, h.TaskId, h.ExtFinalInc, h.GLAcctDeferred, h.GLAcctAdjust
	FROM dbo.tblJcTransHistory h INNER JOIN dbo.tblJcProjTask p 
		ON h.CustId = p.CustId AND h.ProjId = p.ProjId AND h.PhaseId = p.PhaseId AND h.TaskId = p.TaskId
		INNER JOIN dbo.tblJcProjPhase s ON p.CustId = s.CustId AND p.ProjId = s.ProjId AND p.PhaseId = s.PhaseId
	WHERE p.[Status] = 1 AND s.FixedFee = 1 AND p.ClosedYn = 0 AND h.TaskId IS NOT NULL 
		AND h.[Source] = 'TF' AND h.ExtFinalInc <> 0 AND h.[Status] = 'BIL'
		
	--Fixed Fee account and Income account
	--Fixed fee billed
	SELECT 'Fixed billable project billed fixed fee' AS [Description], p.CustId, p.ProjId, NULL AS PhaseId, p.PTDBilled, d.DeferredGLAcct AS GLAcctFixedFeeBilling, d.SalesGLAcct AS GLAcctIncome
	FROM dbo.tblJcProject p INNER JOIN dbo.tblJcDistCode d ON p.DistCode = d.DistCode 
	WHERE p.[Status] = 1 AND p.FixedFee = 1 AND p.ClosedYn = 0 AND p.BilltoPhaseYn = 0 AND p.PTDBilled <> 0
	UNION ALL
	SELECT 'Fixed billable project billed fixed fee' AS [Description], p.CustId, p.ProjId, p.PhaseId, p.PTDBilled, d.DeferredGLAcct AS GLAcctFixedFeeBilling, d.SalesGLAcct AS GLAcctIncome
	FROM dbo.tblJcProjPhase p INNER JOIN dbo.tblJcDistCode d ON p.DistCode = d.DistCode 
		INNER JOIN dbo.tblJcProject j ON p.CustId = j.CustId AND p.ProjId = j.ProjId
	WHERE p.[Status] = 1 AND p.FixedFee = 1 AND p.ClosedYn = 0 AND j.BilltoPhaseYn = 0 AND p.PTDBilled <> 0

	       
	--PO posted activity check    
	--WIP account and Income account
	--History records that are from PO, has non-zero income, status is INP, PO invoice is posted
	SELECT 'Billable project posted income from PO invoice' AS [Description], h.TransHistId, h.CustId, h.ProjId, NULL AS PhaseId, NULL AS TaskId, h.ExtFinalInc, h.GLAcctWIP, h.GLAcctSales AS GLAcctIncome
	FROM dbo.tblJcTransHistory h INNER JOIN dbo.tblJcProject p ON h.CustId = p.CustId AND h.ProjId = p.ProjId 
		INNER JOIN dbo.tblPoTransInvoice i ON h.TransHistId = i.TransHistId
	WHERE p.[Status] = 1 AND h.PhaseId IS NULL AND h.[Source] = 'PO' AND h.ExtFinalInc <> 0 AND h.[Status] = 'INP'
	UNION ALL
	SELECT 'Billable project posted income from PO invoice' AS [Description], h.TransHistId, h.CustId, h.ProjId, h.PhaseId, NULL AS TaskId,h.ExtFinalInc, h.GLAcctWIP, h.GLAcctSales
	FROM dbo.tblJcTransHistory h INNER JOIN dbo.tblJcProjPhase p ON h.CustId = p.CustId AND h.ProjId = p.ProjId AND h.PhaseId = p.PhaseId
		INNER JOIN dbo.tblPoTransInvoice i ON h.TransHistId = i.TransHistId
	WHERE p.[Status] = 1 AND h.PhaseId IS NOT NULL AND h.TaskId IS NULL AND h.[Source] = 'PO' AND h.ExtFinalInc <> 0 AND h.[Status] = 'INP'
	UNION ALL
	SELECT 'Billable project posted income from PO invoice' AS [Description], h.TransHistId, h.CustId, h.ProjId, h.PhaseId, h.TaskId, h.ExtFinalInc, h.GLAcctWIP, h.GLAcctSales
	FROM dbo.tblJcTransHistory h INNER JOIN dbo.tblJcProjTask p ON h.CustId = p.CustId AND h.ProjId = p.ProjId AND h.PhaseId = p.PhaseId AND h.TaskId = p.TaskId
		INNER JOIN dbo.tblJcProjPhase s ON p.CustId = s.CustId AND p.ProjId = s.ProjId AND p.PhaseId = s.PhaseId
		INNER JOIN dbo.tblPoTransInvoice i ON h.TransHistId = i.TransHistId
	WHERE p.[Status] = 1 AND h.TaskId IS NOT NULL AND h.[Source] = 'PO' AND h.ExtFinalInc <> 0 AND h.[Status] = 'INP'
	UNION ALL 
	--Landed cost
	SELECT 'Billable project posted income from PO landed cost' AS [Description], h.TransHistId, h.CustId, h.ProjId, NULL AS PhaseId, NULL AS TaskId, h.ExtFinalInc, h.GLAcctWIP, h.GLAcctSales AS GLAcctIncome
	FROM dbo.tblJcTransHistory h INNER JOIN dbo.tblJcProject p ON h.CustId = p.CustId AND h.ProjId = p.ProjId 
		INNER JOIN dbo.tblPoTransDetail d ON h.TransHistId = d.TransHistIdLandedCost
	WHERE p.[Status] = 1 AND h.PhaseId IS NULL AND h.[Source] = 'PO' AND h.ExtFinalInc <> 0 AND h.[Status] = 'INP'
	UNION ALL
	SELECT 'Billable project posted income from PO landed cost' AS [Description], h.TransHistId, h.CustId, h.ProjId, h.PhaseId, NULL AS TaskId,h.ExtFinalInc, h.GLAcctWIP, h.GLAcctSales
	FROM dbo.tblJcTransHistory h INNER JOIN dbo.tblJcProjPhase p ON h.CustId = p.CustId AND h.ProjId = p.ProjId AND h.PhaseId = p.PhaseId
		INNER JOIN dbo.tblPoTransDetail d ON h.TransHistId = d.TransHistIdLandedCost
	WHERE p.[Status] = 1 AND h.PhaseId IS NOT NULL AND h.TaskId IS NULL AND h.[Source] = 'PO' AND h.ExtFinalInc <> 0 AND h.[Status] = 'INP'
	UNION ALL
	SELECT 'Billable project posted income from PO landed cost' AS [Description], h.TransHistId, h.CustId, h.ProjId, h.PhaseId, h.TaskId, h.ExtFinalInc, h.GLAcctWIP, h.GLAcctSales
	FROM dbo.tblJcTransHistory h INNER JOIN dbo.tblJcProjTask p ON h.CustId = p.CustId AND h.ProjId = p.ProjId AND h.PhaseId = p.PhaseId AND h.TaskId = p.TaskId
		INNER JOIN dbo.tblJcProjPhase s ON p.CustId = s.CustId AND p.ProjId = s.ProjId AND p.PhaseId = s.PhaseId
		INNER JOIN dbo.tblPoTransDetail d ON h.TransHistId = d.TransHistIdLandedCost
	WHERE p.[Status] = 1 AND h.TaskId IS NOT NULL AND h.[Source] = 'PO' AND h.ExtFinalInc <> 0 AND h.[Status] = 'INP'

	--Cost account, default credit account(business rule)
	--History records that are from PO, has non-zero income, status is INP, PO invoice is posted
	--non job costing project
	SELECT 'Non job costing project posted cost from PO invoice' AS [Description], h.TransHistId, h.CustId, h.ProjId, NULL AS PhaseId, NULL AS TaskId, h.ExtCost, h.GlAcctCos
	FROM dbo.tblJcTransHistory h INNER JOIN dbo.tblJcProject p ON h.CustId = p.CustId AND h.ProjId = p.ProjId 
		INNER JOIN dbo.tblPoTransInvoice i ON h.TransHistId = i.TransHistId
	WHERE p.[Status] <> 2 AND h.PhaseId IS NULL AND h.[Source] = 'PO' AND h.ExtCost <> 0 AND h.[Status] = 'INP'
	UNION ALL
	SELECT 'Non job costing project posted cost from PO invoice' AS [Description], h.TransHistId, h.CustId, h.ProjId, h.PhaseId, NULL AS TaskId,h.ExtCost, h.GlAcctCos
	FROM dbo.tblJcTransHistory h INNER JOIN dbo.tblJcProjPhase p ON h.CustId = p.CustId AND h.ProjId = p.ProjId AND h.PhaseId = p.PhaseId
		INNER JOIN dbo.tblPoTransInvoice i ON h.TransHistId = i.TransHistId
	WHERE p.[Status] <> 2 AND h.PhaseId IS NOT NULL AND h.TaskId IS NULL AND h.[Source] = 'PO' AND h.ExtCost <> 0 AND h.[Status] = 'INP'
	UNION ALL
	SELECT 'Non job costing project posted cost from PO invoice' AS [Description], h.TransHistId, h.CustId, h.ProjId, h.PhaseId, h.TaskId, h.ExtCost, h.GlAcctCos
	FROM dbo.tblJcTransHistory h INNER JOIN dbo.tblJcProjTask p ON h.CustId = p.CustId AND h.ProjId = p.ProjId AND h.PhaseId = p.PhaseId AND h.TaskId = p.TaskId
		INNER JOIN dbo.tblJcProjPhase s ON p.CustId = s.CustId AND p.ProjId = s.ProjId AND p.PhaseId = s.PhaseId
		INNER JOIN dbo.tblPoTransInvoice i ON h.TransHistId = i.TransHistId
	WHERE p.[Status] <> 2 AND h.TaskId IS NOT NULL AND h.[Source] = 'PO' AND h.ExtCost <> 0 AND h.[Status] = 'INP'
	UNION ALL 
	--Landed cost
	SELECT 'Non job costing project posted cost from PO landed cost' AS [Description], h.TransHistId, h.CustId, h.ProjId, NULL AS PhaseId, NULL AS TaskId, h.ExtCost, h.GlAcctCos
	FROM dbo.tblJcTransHistory h INNER JOIN dbo.tblJcProject p ON h.CustId = p.CustId AND h.ProjId = p.ProjId 
		INNER JOIN dbo.tblPoTransDetail d ON h.TransHistId = d.TransHistIdLandedCost
	WHERE p.[Status] <> 2 AND h.PhaseId IS NULL AND h.[Source] = 'PO' AND h.ExtCost <> 0 AND h.[Status] = 'INP'
	UNION ALL
	SELECT 'Non job costing project posted cost from PO landed cost' AS [Description], h.TransHistId, h.CustId, h.ProjId, h.PhaseId, NULL AS TaskId,h.ExtCost, h.GlAcctCos
	FROM dbo.tblJcTransHistory h INNER JOIN dbo.tblJcProjPhase p ON h.CustId = p.CustId AND h.ProjId = p.ProjId AND h.PhaseId = p.PhaseId
		INNER JOIN dbo.tblPoTransDetail d ON h.TransHistId = d.TransHistIdLandedCost
	WHERE p.[Status] <> 2 AND h.PhaseId IS NOT NULL AND h.TaskId IS NULL AND h.[Source] = 'PO' AND h.ExtCost <> 0 AND h.[Status] = 'INP'
	UNION ALL
	SELECT 'Non job costing project posted cost from PO landed cost' AS [Description], h.TransHistId, h.CustId, h.ProjId, h.PhaseId, h.TaskId, h.ExtCost, h.GlAcctCos
	FROM dbo.tblJcTransHistory h INNER JOIN dbo.tblJcProjTask p ON h.CustId = p.CustId AND h.ProjId = p.ProjId AND h.PhaseId = p.PhaseId AND h.TaskId = p.TaskId
		INNER JOIN dbo.tblJcProjPhase s ON p.CustId = s.CustId AND p.ProjId = s.ProjId AND p.PhaseId = s.PhaseId
		INNER JOIN dbo.tblPoTransDetail d ON h.TransHistId = d.TransHistIdLandedCost
	WHERE p.[Status] <> 2 AND h.TaskId IS NOT NULL AND h.[Source] = 'PO' AND h.ExtCost <> 0 AND h.[Status] = 'INP'
		
	--Wip account, default credit account(business rule)
	--History records that are from PO, has non-zero income, status is INP, PO invoice is posted
	--job costing project
	SELECT 'Job costing project posted cost from PO invoice' AS [Description], h.TransHistId, h.CustId, h.ProjId, NULL AS PhaseId, NULL AS TaskId, h.ExtCost, h.GLAcctWIP
	FROM dbo.tblJcTransHistory h INNER JOIN dbo.tblJcProject p ON h.CustId = p.CustId AND h.ProjId = p.ProjId 
		INNER JOIN dbo.tblPoTransInvoice i ON h.TransHistId = i.TransHistId
	WHERE p.[Status] = 2 AND h.PhaseId IS NULL AND h.[Source] = 'PO' AND h.ExtCost <> 0 AND h.[Status] = 'INP'
	UNION ALL
	SELECT 'Job costing project posted cost from PO invoice' AS [Description], h.TransHistId, h.CustId, h.ProjId, h.PhaseId, NULL AS TaskId,h.ExtCost, h.GLAcctWIP
	FROM dbo.tblJcTransHistory h INNER JOIN dbo.tblJcProjPhase p ON h.CustId = p.CustId AND h.ProjId = p.ProjId AND h.PhaseId = p.PhaseId
		INNER JOIN dbo.tblPoTransInvoice i ON h.TransHistId = i.TransHistId
	WHERE p.[Status] = 2 AND h.PhaseId IS NOT NULL AND h.TaskId IS NULL AND h.[Source] = 'PO' AND h.ExtCost <> 0 AND h.[Status] = 'INP'
	UNION ALL
	SELECT 'Job costing project posted cost from PO invoice' AS [Description], h.TransHistId, h.CustId, h.ProjId, h.PhaseId, h.TaskId, h.ExtCost, h.GLAcctWIP
	FROM dbo.tblJcTransHistory h INNER JOIN dbo.tblJcProjTask p ON h.CustId = p.CustId AND h.ProjId = p.ProjId AND h.PhaseId = p.PhaseId AND h.TaskId = p.TaskId
		INNER JOIN dbo.tblJcProjPhase s ON p.CustId = s.CustId AND p.ProjId = s.ProjId AND p.PhaseId = s.PhaseId
		INNER JOIN dbo.tblPoTransInvoice i ON h.TransHistId = i.TransHistId
	WHERE p.[Status] = 2 AND h.TaskId IS NOT NULL AND h.[Source] = 'PO' AND h.ExtCost <> 0 AND h.[Status] = 'INP'
	UNION ALL 
	--Landed cost
	SELECT 'Job costing project posted cost from PO landed cost' AS [Description], h.TransHistId, h.CustId, h.ProjId, NULL AS PhaseId, NULL AS TaskId, h.ExtCost, h.GLAcctWIP
	FROM dbo.tblJcTransHistory h INNER JOIN dbo.tblJcProject p ON h.CustId = p.CustId AND h.ProjId = p.ProjId 
		INNER JOIN dbo.tblPoTransDetail d ON h.TransHistId = d.TransHistIdLandedCost
	WHERE p.[Status] = 2 AND h.PhaseId IS NULL AND h.[Source] = 'PO' AND h.ExtCost <> 0 AND h.[Status] = 'INP'
	UNION ALL
	SELECT 'Job costing project posted cost from PO landed cost' AS [Description], h.TransHistId, h.CustId, h.ProjId, h.PhaseId, NULL AS TaskId,h.ExtCost, h.GLAcctWIP
	FROM dbo.tblJcTransHistory h INNER JOIN dbo.tblJcProjPhase p ON h.CustId = p.CustId AND h.ProjId = p.ProjId AND h.PhaseId = p.PhaseId
		INNER JOIN dbo.tblPoTransDetail d ON h.TransHistId = d.TransHistIdLandedCost
	WHERE p.[Status] = 2 AND h.PhaseId IS NOT NULL AND h.TaskId IS NULL AND h.[Source] = 'PO' AND h.ExtCost <> 0 AND h.[Status] = 'INP'
	UNION ALL
	SELECT 'Job costing project posted cost from PO landed cost' AS [Description], h.TransHistId, h.CustId, h.ProjId, h.PhaseId, h.TaskId, h.ExtCost, h.GLAcctWIP
	FROM dbo.tblJcTransHistory h INNER JOIN dbo.tblJcProjTask p ON h.CustId = p.CustId AND h.ProjId = p.ProjId AND h.PhaseId = p.PhaseId AND h.TaskId = p.TaskId
		INNER JOIN dbo.tblJcProjPhase s ON p.CustId = s.CustId AND p.ProjId = s.ProjId AND p.PhaseId = s.PhaseId
		INNER JOIN dbo.tblPoTransDetail d ON h.TransHistId = d.TransHistIdLandedCost
	WHERE p.[Status] = 2 AND h.TaskId IS NOT NULL AND h.[Source] = 'PO' AND h.ExtCost <> 0 AND h.[Status] = 'INP'

	--Accrual cost
	DECLARE @ConfigValue nvarchar(255) 
	EXEC dbo.glbSmGetSingleConfigValue_sp 'PO',null,'AccrualYn',@ConfigValue out 

	IF @ConfigValue = '1'
	BEGIN
		SELECT 'Project accrual cost from PO' AS [Description], j.TransHistId, j.CustId, j.ProjId, NULL AS PhaseId, NULL AS TaskId, r.TotalAccrualCost - ISNULL(i.TotalUnAccrualCost,0) AS AccrualCost
		FROM dbo.tblPoTransDetail d INNER JOIN dbo.tblJcTransHistory j ON d.TransHistId = j.TransHistId AND j.Status = 'UNP' 
			INNER JOIN dbo.tblJcProject p ON j.CustId = p.CustId AND j.ProjId = p.ProjId 
		INNER JOIN 
		(SELECT TransId, EntryNum, SUM(ExtCost) AS TotalAccrualCost
		FROM dbo.tblPoTransLotRcpt
		WHERE Status = 1
		GROUP BY TransId, EntryNum) r ON d.TransId = r.TransId AND d.EntryNum = r.EntryNum
		LEFT JOIN 
		(SELECT TransId, EntryNum, SUM(ExtCost) AS TotalUnAccrualCost
		FROM dbo.tblPoTransInvoice  
		WHERE Status = 1
		GROUP BY TransId, EntryNum) i ON d.TransId = i.TransId AND d.EntryNum = i.EntryNum 
		WHERE j.PhaseId IS NULL
		UNION ALL
		SELECT 'Project accrual cost from PO' AS [Description], j.TransHistId, j.CustId, j.ProjId, j.PhaseId, NULL AS TaskId, r.TotalAccrualCost - ISNULL(i.TotalUnAccrualCost,0) AS AccrualCost
		FROM dbo.tblPoTransDetail d INNER JOIN dbo.tblJcTransHistory j ON d.TransHistId = j.TransHistId AND j.Status = 'UNP' 
			INNER JOIN dbo.tblJcProjPhase p ON j.CustId = p.CustId AND j.ProjId = p.ProjId AND j.PhaseId = p.PhaseId
		INNER JOIN 
		(SELECT TransId, EntryNum, SUM(ExtCost) AS TotalAccrualCost
		FROM dbo.tblPoTransLotRcpt
		WHERE Status = 1
		GROUP BY TransId, EntryNum) r ON d.TransId = r.TransId AND d.EntryNum = r.EntryNum
		LEFT JOIN 
		(SELECT TransId, EntryNum, SUM(ExtCost) AS TotalUnAccrualCost
		FROM dbo.tblPoTransInvoice  
		WHERE Status = 1
		GROUP BY TransId, EntryNum) i ON d.TransId = i.TransId AND d.EntryNum = i.EntryNum 
		WHERE j.PhaseId IS NOT NULL
		UNION ALL
		SELECT 'Project accrual cost from PO' AS [Description], j.TransHistId, j.CustId, j.ProjId, j.PhaseId, j.TaskId, r.TotalAccrualCost - ISNULL(i.TotalUnAccrualCost,0) AS AccrualCost
		FROM dbo.tblPoTransDetail d INNER JOIN dbo.tblJcTransHistory j ON d.TransHistId = j.TransHistId AND j.Status = 'UNP' 
			INNER JOIN dbo.tblJcProjTask p ON j.CustId = p.CustId AND j.ProjId = p.ProjId AND j.PhaseId = p.PhaseId AND j.TaskId = p.TaskId
		INNER JOIN 
		(SELECT TransId, EntryNum, SUM(ExtCost) AS TotalAccrualCost
		FROM dbo.tblPoTransLotRcpt
		WHERE Status = 1
		GROUP BY TransId, EntryNum) r ON d.TransId = r.TransId AND d.EntryNum = r.EntryNum
		LEFT JOIN 
		(SELECT TransId, EntryNum, SUM(ExtCost) AS TotalUnAccrualCost
		FROM dbo.tblPoTransInvoice  
		WHERE Status = 1
		GROUP BY TransId, EntryNum) i ON d.TransId = i.TransId AND d.EntryNum = i.EntryNum 
		WHERE j.TaskId IS NOT NULL
	END
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'tsmPcMigrationStep2';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'tsmPcMigrationStep2';

