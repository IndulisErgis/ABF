
CREATE PROCEDURE [trav_MpProcessRequirementsView_proc]
AS
BEGIN TRY
	SET NOCOUNT ON

	CREATE TABLE #tmp
	(
		OrderNo pTransID, 
		ReleaseNo int, 
		ReqType tinyint, 
		ReqId int, 
		ParentId int, 
		TransId int,  
		ParentAssemblyId pItemID, 
		IndLevel int, 
		Step int, 
		QtyReq pDecimal DEFAULT(0), 
		CustId pCustID NULL, 
		SalesOrder nvarchar(8), 
		[Description] pDescription, 
		OperationId nvarchar(10), 
		[Priority] int, 
		ReqSeq int, 
		MachineGroupId nvarchar(10), 
		WorkCenterId nvarchar(10), 
		MachineSetupEst int, 
		MachineRunEst int, 
		HourlyCostFactorMach pDecimal NULL, 
		HourlyRateLbr pDecimal NULL, 
		HourlyRateLbrSetup pDecimal NULL, 
		LaborSetupEst int, 
		LaborEst int, 
		RequiredDate datetime, 
		IssuedYn bit DEFAULT(0), 
		IssuedQty pDecimal DEFAULT(0), 
		IssueCompleteYn bit DEFAULT(0), 
		DefaultVendorId pVendorID NULL, 
		QtySent pDecimal NULL, 
		QtyReceived pDecimal NULL, 
		UnitCost pDecimal NULL,
		RevisionNo nvarchar(3), 
		OperatorCount int
	)

	INSERT INTO #tmp(OrderNo, ReleaseNo, ReqType, ReqId, ParentId, TransId, ParentAssemblyId, IndLevel, Step
		, QtyReq, CustId, SalesOrder, [Description], OperationId, [Priority], ReqSeq
		, MachineGroupId, WorkCenterId, MachineSetupEst, MachineRunEst, HourlyCostFactorMach
		, HourlyRateLbr, HourlyRateLbrSetup, LaborSetupEst, LaborEst, RequiredDate
		, DefaultVendorId, UnitCost,RevisionNo, OperatorCount) 
	SELECT re.OrderNo, re.ReleaseNo, r.[Type] AS ReqType, r.ReqId, r.ParentId, r.TransId, s.ComponentId AS ParentAssemblyId, r.IndLevel
		, r.Step, r.Qty AS QtyReq, re.CustId, re.SalesOrder, r.[Description], ISNULL(m.OperationId, c.OperationId)
		, re.[Priority], r.ReqSeq, m.MachineGroupId, m.WorkCenterId
		, m.MachineSetupEst, m.MachineRunEst, m.HourlyCostFactorMach AS HourlyCostFactorMach
		, m.HourlyRateLbr AS HourlyRateLbr, m.HourlyRateLbrSetup AS HourlyRateLbrSetup
		, m.LaborSetupEst, m.LaborEst, r.EstCompletionDate
		, c.DefaultVendorId, c.EstPerPieceCost, h.RevisionNo, m.OperatorCount
	FROM #tmpOrderReleases t 
		INNER JOIN dbo.tblMpRequirements r ON t.Id = r.ReleaseId 
		INNER JOIN dbo.tblMpOrderReleases re ON r.ReleaseId = re.Id 
		INNER JOIN dbo.tblMpOrder h ON re.OrderNo = h.OrderNo
		LEFT JOIN dbo.tblMpTimeSum m ON r.TransId = m.TransId 
		LEFT JOIN dbo.tblMpSubContractSum c ON r.TransId = c.TransId 
		LEFT JOIN dbo.tblMpMatlSum s ON r.ParentId = s.TransId 
	WHERE r.[Type] IN (1, 6) ORDER BY r.IndLevel

	UPDATE #tmp SET QtySent = q.QtySent, IssuedQty = q.QtyReceived, QtyReceived = q.QtyReceived
		, IssuedYn = 1, IssueCompleteYn = CASE WHEN q.QtyReceived >= t.QtyReq THEN 1 ELSE 0 END 
	FROM #tmp t 
		INNER JOIN 
		(
			SELECT s.TransId, SUM(s.QtySent) AS QtySent, SUM(s.QtyReceived) AS QtyReceived 
			FROM dbo.tblMpSubContractDtl s
				INNER JOIN #tmp t ON s.TransId = t.TransId WHERE t.ReqType = 6
			GROUP BY s.TransId
		) q ON t.TransId = q.TransId

	-- retrieve IssuedYn and IssuedQty
	UPDATE #tmp SET IssuedYn = 1, IssuedQty = g.Qty 
	FROM #tmp t 
		INNER JOIN 
		(
			SELECT s.TransId, SUM(QtyProduced) AS Qty 
			FROM dbo.tblMpTimeDtl s
				INNER JOIN #tmp t ON s.TransId = t.TransId WHERE t.ReqType = 1
			GROUP BY s.TransId
		) g ON t.TransId = g.TransId

	SELECT * FROM #tmp
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpProcessRequirementsView_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpProcessRequirementsView_proc';

