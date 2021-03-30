
CREATE PROCEDURE dbo.pvtMpProductionCostAnalysis_sp
AS
BEGIN TRY
	SET NOCOUNT ON

CREATE TABLE #TempCosts
(
	OrderNo pTransID, 
	ReleaseNo nvarchar (3), 
	ReqId nvarchar (4), 
	Reference nvarchar (50), 
	MatlCostEst pDecimal DEFAULT (0), 
	MatlCostAct pDecimal DEFAULT (0), 
	TimeCostEst pDecimal DEFAULT (0), 
	TimeCostAct pDecimal DEFAULT (0), 
	SubcontractCostEst pDecimal DEFAULT (0), 
	SubcontractCostAct pDecimal DEFAULT (0)
)

-- Costs (Materials Est)
INSERT INTO #TempCosts(OrderNo, ReleaseNo, ReqId, Reference, MatlCostEst) 
SELECT o.OrderNo, o.ReleaseNo, r.ReqId, s.ComponentId
	, ISNULL(SUM(CASE WHEN s.ComponentType = 5 
		THEN -(ISNULL(s.EstQtyRequired * s.UnitCost, 0)) -- reverse sign for byproducts
		ELSE ISNULL(s.EstQtyRequired * s.UnitCost, 0) END), 0) 
FROM dbo.tblMpOrderReleases o 
	INNER JOIN dbo.tblMpRequirements r ON o.Id = r.ReleaseId 
	INNER JOIN dbo.tblMpMatlSum s ON r.TransId = s.TransId 
WHERE s.ComponentType IN (4, 5) 
GROUP BY o.OrderNo, o.ReleaseNo, r.ReqId, s.ComponentId

-- Costs (Materials Act)
INSERT INTO #TempCosts(OrderNo, ReleaseNo, ReqId, Reference, MatlCostAct) 
SELECT o.OrderNo, o.ReleaseNo, r.ReqId, d.ComponentId
	, ISNULL(SUM(CASE WHEN s.ComponentType = 5 
		THEN -(ISNULL(d.Qty * d.UnitCost, 0)) -- reverse sign for byproducts
		ELSE ISNULL(d.Qty * d.UnitCost, 0) 
		END), 0) 
FROM dbo.tblMpOrderReleases o 
	INNER JOIN dbo.tblMpRequirements r ON o.Id = r.ReleaseId 
	INNER JOIN dbo.tblMpMatlSum s ON r.TransId = s.TransId 
	INNER JOIN dbo.tblMpMatlDtl d ON s.TransId = d.TransId 
WHERE s.ComponentType IN (2, 3, 4, 5) 
GROUP BY o.OrderNo, o.ReleaseNo, r.ReqId, d.ComponentId

-- Costs (Time Est)
INSERT INTO #TempCosts(OrderNo, ReleaseNo, ReqId, Reference, TimeCostEst) 
SELECT o.OrderNo, o.ReleaseNo, r.ReqId, LaborTypeId + '/' + MachineGroupId
	, ISNULL(SUM(((1 + (LaborPctOvhd / 100.0)) * (CAST((LaborSetupEst / CAST(60 AS decimal(2,0))) 
		* HourlyRateLbrSetup AS decimal(10, 2)) + CAST((LaborEst / CAST(60 AS decimal(2,0))) 
		* HourlyRateLbr AS decimal(10,2)))) + ((1 + (MachPctOvhd / 100.0)) 
		* (CAST((MachineSetupEst /  CAST(60 AS decimal(2,0))) * HourlyCostFactorMach AS decimal(10, 2)) 
		+ CAST(((MachineRunEst / CAST(60 AS decimal(2,0))) * HourlyCostFactorMach) AS decimal(10, 2)))) 
		+ FlatAmtOvhd + (PerPieceOvhd * QtyProducedEst)), 0) 
FROM dbo.tblMpOrderReleases o 
	INNER JOIN dbo.tblMpRequirements r ON o.Id = r.ReleaseId 
	INNER JOIN dbo.tblMpTimeSum s ON r.TransId = s.TransId 
GROUP BY o.OrderNo, o.ReleaseNo, r.ReqId, LaborTypeId, MachineGroupId

-- Costs (Time Act)
INSERT INTO #TempCosts(OrderNo, ReleaseNo, ReqId, Reference, TimeCostAct) 
SELECT o.OrderNo, o.ReleaseNo, r.ReqId, LaborTypeId + '/' + MachineGroupId
	, ISNULL(SUM( ((1 + (LaborPctOvhd / 100.0)) * (((LaborSetup / LaborSetupIn)* HourlyRateLbrSetup) + ((Labor / LaborIn) 
	* HourlyRateLbr))) + ((1 + (MachPctOvhd / 100.0)) 
	* (((MachineSetup / MachineSetupIn) + (MachineRun / MachineRunIn)) * HourlyCostFactorMach)) 
	+ FlatAmtOvhd + (PerPieceOvhd * QtyProducedEst)), 0) 
FROM dbo.tblMpOrderReleases o 
	INNER JOIN dbo.tblMpRequirements r ON o.Id = r.ReleaseId 
	INNER JOIN dbo.tblMpTimeSum s ON r.TransId = s.TransId 
	INNER JOIN dbo.tblMpTimeDtl d ON s.TransId = d.TransId 
GROUP BY o.OrderNo, o.ReleaseNo, r.ReqId, LaborTypeId, MachineGroupId

-- Costs (Subcontract Est)
INSERT INTO #TempCosts(OrderNo, ReleaseNo, ReqId, Reference, SubcontractCostEst) 
SELECT o.OrderNo, o.ReleaseNo, r.ReqId, s.Description, ISNULL(SUM(EstQtyRequired * EstPerPieceCost), 0) 
FROM dbo.tblMpOrderReleases o 
	INNER JOIN dbo.tblMpRequirements r ON o.Id = r.ReleaseId 
	INNER JOIN dbo.tblMpSubContractSum s ON r.TransId = s.TransId 
GROUP BY o.OrderNo, o.ReleaseNo, r.ReqId, s.Description

-- Costs (Subcontract Act)
INSERT INTO #TempCosts(OrderNo, ReleaseNo, ReqId, Reference, SubcontractCostAct) 
SELECT o.OrderNo, o.ReleaseNo, r.ReqId, VendorId, ISNULL(SUM(QtyReceived * UnitCost), 0) 
FROM dbo.tblMpOrderReleases o 
	INNER JOIN dbo.tblMpRequirements r ON o.Id = r.ReleaseId 
	INNER JOIN dbo.tblMpSubContractSum s ON r.TransId = s.TransId 
	INNER JOIN dbo.tblMpSubContractDtl d ON s.TransId = d.TransId 
GROUP BY o.OrderNo, o.ReleaseNo, r.ReqId, VendorId

SELECT OrderNo, ReleaseNo, ReqId, RIGHT(REPLICATE('0',10) + CAST(ReqId AS nvarchar), 10) AS ReqIdSort, Reference
	, SUM(MatlCostEst) MatlCostEst, SUM(MatlCostAct) AS MatlCostAct
	, SUM(TimeCostEst) TimeCostEst, SUM(TimeCostAct) AS TimeCostAct
	, SUM(SubcontractCostEst) SubcontractCostEst, SUM(SubcontractCostAct) AS SubcontractCostAct
	, CAST(SUM(MatlCostEst + TimeCostEst + SubcontractCostEst) AS float) AS TotCostEst
	, CAST(SUM(MatlCostAct + TimeCostAct + SubcontractCostAct) AS float) AS TotCostAct
	, CASE WHEN SUM(MatlCostEst + TimeCostEst + SubcontractCostEst) <> 0
		THEN CAST((SUM(MatlCostAct + TimeCostAct + SubcontractCostAct) 
			/ SUM(MatlCostEst + TimeCostEst + SubcontractCostEst)) * 100 AS float) 
		ELSE CAST(100 AS float) 
		END AS TotCostPct 
FROM #TempCosts 
GROUP BY OrderNo, ReleaseNo, ReqId, Reference 

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'pvtMpProductionCostAnalysis_sp';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'pvtMpProductionCostAnalysis_sp';

