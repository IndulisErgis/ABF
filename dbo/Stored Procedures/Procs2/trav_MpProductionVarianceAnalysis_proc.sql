
CREATE PROCEDURE [dbo].[trav_MpProductionVarianceAnalysis_proc] 
@ExceptionsOnly bit = 0,
@VariancePct pDecimal = 0,
@RollupCostYn bit = 0, -- option flag for "rolling up" the finished goods cost (needed if using standard costing)
@DateFrom datetime = null, --activity date from
@DateThru datetime = null --activity date thru
AS
SET NOCOUNT ON
BEGIN TRY

CREATE TABLE #OrderInfo
(
	PostRun pPostRun NULL, 
	ReleaseId int NULL,
	OrderNo pTransID NULL, 
	ReleaseNo int NULL, 
	CustId pCustID NULL, 
	AssemblyId pItemID NULL, 
	DateCompleted datetime NULL, 
	PlannedQty pDecimal NULL, 
	StdUnitCost pDecimal NULL, 
	ActualQty pDecimal NULL, 
	ScrappedQty pDecimal NULL, 
	ActUnitCost pDecimal NULL, 
	TotalCost pDecimal NULL
)

INSERT INTO #OrderInfo(PostRun, OrderNo, ReleaseNo, CustId, AssemblyId, DateCompleted
	, PlannedQty, StdUnitCost, ActualQty, ScrappedQty, ActUnitCost, ReleaseId) 
SELECT o.PostRun, o.OrderNo, o.ReleaseNo, o.CustId, o.AssemblyId, m.DateCompleted
	, (s.EstQtyRequired * s.ConvFactor) AS PlannedQty, (s.UnitCost / s.ConvFactor) AS StdUnitCost
	, ISNULL(m.QtyCompleted,0), ISNULL(m.QtyScrapped,0), ISNULL(m.AvgUnitCost ,0), o.ReleaseId
FROM #tmpProductionVarianceAnalysis t INNER JOIN dbo.tblMpHistoryOrderReleases o ON t.PostRun = o.PostRun AND t.ReleaseId = o.ReleaseId
	INNER JOIN dbo.tblMpHistoryRequirements r ON o.PostRun = r.PostRun AND o.ReleaseId = r.ReleaseId 
	INNER JOIN dbo.tblMpHistoryMatlSum s ON r.PostRun = s.PostRun and r.TransId = s.TransId
	LEFT JOIN (SELECT PostRun, TransId, MAX(TransDate) AS DateCompleted,  SUM(Qty * ConvFactor) AS QtyCompleted,
				SUM(ActualScrap * ConvFactor) AS QtyScrapped,
				CASE WHEN SUM(Qty * ConvFactor) + SUM(ActualScrap * ConvFactor) = 0 THEN 0 
					ELSE SUM((Qty + ActualScrap) * UnitCost)/(SUM(Qty * ConvFactor) + SUM(ActualScrap * ConvFactor)) END AS AvgUnitCost
				FROM dbo.tblMpHistoryMatlDtl
				GROUP BY PostRun, TransId) m ON r.PostRun = m.PostRun AND r.TransId = m.TransId
WHERE r.[Type] = 0 -- main assembly activity only 
		AND (@DateFrom IS NULL OR m.DateCompleted >= @DateFrom)
		AND (@DateThru IS NULL OR m.DateCompleted <= @DateThru)
		
-- if using standard costing - must "rollup" the component cost instead of using unit costs from finished goods
IF @RollupCostYn = 1
BEGIN
      --calculate material costs
	  UPDATE #OrderInfo SET TotalCost = ISNULL(TotalCost, 0) + ISNULL(tmp.MatlCost, 0)
			FROM #OrderInfo 
			INNER JOIN ( SELECT s.PostRun, o.ReleaseId 
									, SUM( CASE s.ComponentType 
												WHEN 0 THEN 0 --Main Assembly
												WHEN 2 THEN --Subassembly
													  CASE d.SubAssemblyTranType
															WHEN 2 THEN 0 --assembled get cost from components used
															WHEN 1 THEN d.Qty * d.UnitCost --cost pulled from stock
															WHEN -1 THEN -d.Qty * d.UnitCost --cost moved to stock (credit)
													  END
												WHEN 3 THEN d.Qty * d.UnitCost      --Stocked subassembly
												WHEN 4 THEN d.Qty * d.UnitCost   --Material
												WHEN 5 THEN -d.Qty * d.UnitCost     --ByProduct (credit)
											 END ) MatlCost
							  FROM #OrderInfo o 
									INNER JOIN dbo.tblMpHistoryRequirements r ON r.PostRun = o.PostRun AND r.ReleaseId = o.ReleaseId
									INNER JOIN dbo.tblMpHistoryMatlSum s ON r.PostRun = s.PostRun AND r.TransId = s.TransId
									INNER JOIN dbo.tblMpHistoryMatlDtl d ON s.PostRun = d.PostRun AND s.TransId = d.TransId
							  GROUP BY s.PostRun, o.ReleaseId
						) tmp ON #OrderInfo.PostRun = tmp.PostRun AND #OrderInfo.ReleaseId = tmp.ReleaseId  
						

      --calcualte subcontracted costs
      UPDATE #OrderInfo SET TotalCost = ISNULL(TotalCost, 0) + ISNULL(tmp.SubConCost, 0)
      FROM #OrderInfo
            INNER JOIN ( SELECT s.PostRun, o.ReleaseId, SUM(d.QtyReceived * d.UnitCost) AS SubConCost
                              FROM #OrderInfo o 
                                    INNER JOIN dbo.tblMpHistoryRequirements r ON o.PostRun = r.PostRun AND o.ReleaseId = r.ReleaseId
                                    INNER JOIN dbo.tblMpHistorySubContractSum s ON r.PostRun = s.PostRun AND r.TransId = s.TransId
                                    INNER JOIN dbo.tblMpHistorySubContractDtl d ON s.PostRun = d.PostRun AND s.TransId = d.TransId
                              GROUP BY s.PostRun, o.ReleaseId
                           ) AS tmp ON #OrderInfo.PostRun = tmp.PostRun AND #OrderInfo.ReleaseId = tmp.ReleaseId

      --calculate process costs
      UPDATE #OrderInfo SET TotalCost = ISNULL(TotalCost, 0) + ISNULL(tmp.ProcessCost, 0)
            FROM #OrderInfo
            INNER JOIN ( SELECT r.PostRun, r.ReleaseId
                                    , SUM(calc.Labor + calc.LaborSetup + calc.Machine
                                    + COALESCE((calc.Labor + calc.LaborSetup) * (s1.LaborPctOvhd / 100.0), 0) --labor overhead
                                    + COALESCE(calc.Machine * (s1.MachPctOvhd / 100.0), 0) --machine overhead
                                    + COALESCE(calc.TotQty * s1.perPieceOvhd, 0) --per piece overhead
                                    + COALESCE(s1.FlatAmtOvhd, 0.0)) ProcessCost --flat amount overhead
                              FROM dbo.tblMpHistoryRequirements r INNER JOIN dbo.tblMpHistoryTimeSum s1 ON r.PostRun = s1.PostRun AND r.TransId = s1.TransId
                                    INNER JOIN ( SELECT s.PostRun, s.TransId
                                                            , SUM(COALESCE(d.QtyProduced + d.QtyScrapped, 0)) TotQty
                                                            , SUM(COALESCE((d.Labor / d.LaborIn * s.HourlyRateLbr) + ((d.QtyProduced + d.QtyScrapped) * s.PerPieceCostLbr), 0)) Labor
                                                            , SUM(COALESCE((d.LaborSetup / d.LaborSetupIn * s.HourlyRateLbrSetup), 0)) LaborSetup
                                                            , SUM(COALESCE((d.MachineSetup / d.MachineSetupIn * s.HourlyCostFactorMach) + (d.MachineRun / d.MachineRunIn * s.HourlyCostFactorMach), 0)) Machine
                                                 FROM #OrderInfo o
                                                       INNER JOIN dbo.tblMpHistoryRequirements r ON o.PostRun = r.PostRun AND o.ReleaseId = r.ReleaseId 
                                                       INNER JOIN dbo.tblMpHistoryTimeSum s ON r.PostRun = s.PostRun AND r.TransId = s.TransId
                                                       INNER JOIN dbo.tblMpHistoryTimeDtl d ON s.PostRun = d.PostRun AND s.TransId = d.TransId
                                                 GROUP BY s.PostRun, s.TransId
                                                   ) AS calc ON s1.PostRun = calc.PostRun AND s1.TransId = calc.TransId
                              GROUP BY r.PostRun, r.ReleaseId
                           ) AS tmp ON #OrderInfo.PostRun = tmp.PostRun AND #OrderInfo.ReleaseId = tmp.ReleaseId

	UPDATE #OrderInfo SET ActUnitCost = CASE WHEN ActualQty + ScrappedQty = 0 THEN 0 
		ELSE TotalCost / (ActualQty + ScrappedQty) END
END

SELECT PostRun, ReleaseId, OrderNo, ReleaseNo, CustId, AssemblyId
	, DateCompleted, PlannedQty, ActualQty, StdUnitCost, ActUnitCost
	, COALESCE((ActualQty * StdUnitCost), 0)  AS TotalStandard
	, COALESCE((ActualQty * ActUnitCost), 0)  AS TotalActual
	, CASE WHEN COALESCE(COALESCE(StdUnitCost, 0) , 0) <> 0 
		THEN (COALESCE(ActUnitCost, 0)  
			- COALESCE(StdUnitCost, 0) ) * 100 
			/ COALESCE(StdUnitCost, 0)  
		ELSE 0 
		END AS CostVariancePct 
FROM #OrderInfo 
WHERE @ExceptionsOnly = 0 OR (CASE WHEN COALESCE(COALESCE(StdUnitCost, 0) , 0) <> 0 
		THEN ABS((COALESCE(ActUnitCost, 0)  
			- COALESCE(StdUnitCost, 0) ) * 100 
			/ COALESCE(StdUnitCost, 0) ) 
		ELSE 0 
		END >= COALESCE(@VariancePct, 0)) 

-- create a temp table to calculate the totals by cost group
CREATE TABLE #Temp
(
	PostRun pPostRun, 
	ReleaseId int NULL,
	CostGroupId nvarchar(6) NULL, 
	PlannedCost pDecimal, 
	ActualCost pDecimal
)

-- insert material records (reverse sign for byproducts/exclude requirement 0001 as it's the main assembly/perform inline UOM conversion)
INSERT INTO #Temp(PostRun, ReleaseId, CostGroupId, PlannedCost, ActualCost) 
SELECT s.PostRun, o.ReleaseId, s.CostGroupId
	, CASE WHEN s.ComponentType = 5 THEN -1 ELSE 1 END * s.EstQtyRequired * s.UnitCost AS PlannedCost
	, CASE WHEN s.ComponentType = 5 THEN -1 ELSE 1 END * ISNULL(t.ActualCost, 0) AS ActualCost 
FROM #tmpProductionVarianceAnalysis p INNER JOIN dbo.tblMpHistoryOrderReleases o ON p.PostRun = o.PostRun AND p.ReleaseId = o.ReleaseId 
	INNER JOIN dbo.tblMpHistoryRequirements r ON o.PostRun = r.PostRun AND o.ReleaseId = r.ReleaseId 
	INNER JOIN dbo.tblMpHistoryMatlSum s ON r.PostRun = s.PostRun AND r.TransId = s.TransId
	LEFT JOIN 
		(
			SELECT PostRun, TransId, SUM(Qty * UnitCost) AS ActualCost 
			FROM dbo.tblMpHistoryMatlDtl
			GROUP BY PostRun, TransId
		) t ON s.PostRun = t.PostRun AND s.TransId = t.TransId 
WHERE r.[Type] <> 0 -- exclude main assembly activity 

-- insert subcontracted records
INSERT INTO #Temp(PostRun, ReleaseId, CostGroupId, PlannedCost, ActualCost) 
SELECT s.PostRun, o.ReleaseId, s.CostGroupId
	, ISNULL(s.EstQtyRequired * s.EstPerPieceCost, 0) AS PlannedCost
	, SUM(ISNULL(d.QtySent * d.UnitCost, 0)) AS ActualCost 
FROM #tmpProductionVarianceAnalysis t INNER JOIN dbo.tblMpHistoryOrderReleases o ON t.PostRun = o.PostRun AND t.ReleaseId = o.ReleaseId 
	INNER JOIN dbo.tblMpHistoryRequirements r ON o.PostRun = r.PostRun AND o.ReleaseId = r.ReleaseId 
	INNER JOIN dbo.tblMpHistorySubContractSum s ON r.PostRun = s.PostRun AND r.TransId = s.TransId
	LEFT JOIN dbo.tblMpHistorySubContractDtl d ON s.PostRun = d.PostRun AND s.TransId = d.TransId
WHERE (@DateFrom IS NULL OR d.TransDate >= @DateFrom)
		AND (@DateThru IS NULL OR d.TransDate <= @DateThru)
GROUP BY s.PostRun, o.ReleaseId, s.CostGroupId, s.EstQtyRequired, s.EstPerPieceCost

-- insert time/routing records (Overhead for Work Center, Labor Setup & Run, & Machine Setup & Run)
INSERT INTO #Temp(PostRun, ReleaseId, CostGroupId, PlannedCost, ActualCost) 
SELECT o.PostRun, o.ReleaseId, s.WorkCenterCostGroupId
	, ISNULL(((s.FlatAmtOvhd + s.PerPieceOvhd * QtyProducedEst) + ((s2.PlannedMachCost * s.MachPctOvhd) 
		+ ((s2.PlannedLaborCost + (s.PerPieceCostLbr * QtyProducedEst)) 
		* s.LaborPctOvhd)) / 100.0), 0) AS PlannedCost
	, ISNULL(((s.FlatAmtOvhd + s.PerPieceOvhd * QtyProducedEst) + ((s2.ActMachCost * s.MachPctOvhd) 
		+ ((s2.ActLaborCost + (s.PerPieceCostLbr * QtyProducedEst)) 
		* s.LaborPctOvhd)) / 100.0), 0) AS ActCost 
FROM #tmpProductionVarianceAnalysis t INNER JOIN dbo.tblMpHistoryOrderReleases o ON t.PostRun = o.PostRun AND t.ReleaseId = o.ReleaseId
	INNER JOIN dbo.tblMpHistoryRequirements r ON o.PostRun = r.PostRun AND o.ReleaseId = r.ReleaseId 
	INNER JOIN dbo.tblMpHistoryTimeSum s ON r.PostRun = s.PostRun AND r.TransId = s.TransId
	INNER JOIN 
		(
			SELECT r.PostRun, r.TransId
				, ISNULL((s.MachineSetupEst + s.MachineRunEst) 
					* (s.HourlyCostFactorMach / 60), 0) AS PlannedMachCost
				, ISNULL((ISNULL(d.ActMachSetup + d.ActMachRun, 0)) 
					* s.HourlyCostFactorMach, 0) AS ActMachCost
				, ISNULL(((s.LaborEst* (s.HourlyRateLbr / 60.0)) + (s.LaborSetupEst 
					* (s.HourlyRateLbrSetup / 60.0))), 0) AS PlannedLaborCost
				, ISNULL((d.ActLabor* s.HourlyRateLbr) + (d.ActLaborSetup* s.HourlyRateLbrSetup), 0)  AS ActLaborCost 
			FROM dbo.tblMpHistoryRequirements r	INNER JOIN dbo.tblMpHistoryTimeSum s ON r.PostRun = s.PostRun AND r.TransId = s.TransId
				LEFT JOIN 
					(
						SELECT PostRun, TransId
							, ISNULL(MachineSetup / CASE WHEN ISNULL(MachineSetupIn, 0) = 0 THEN 1 
								ELSE MachineSetupIn END, 0) AS ActMachSetup
							, ISNULL(MachineRun / CASE WHEN ISNULL(MachineRunIn, 0) = 0 THEN 1 
								ELSE MachineRunIn END, 0) AS ActMachRun
							, ISNULL(Labor / CASE WHEN ISNULL(LaborIn, 0) = 0 THEN 1 
								ELSE LaborIn END, 0) AS ActLabor
							, ISNULL(LaborSetup / CASE WHEN ISNULL(LaborSetupIn, 0) = 0 THEN 1 
								ELSE LaborSetupIn END, 0) AS ActLaborSetup 
						FROM dbo.tblMpHistoryTimeDtl
					) d ON s.PostRun = d.PostRun AND s.TransId = d.TransId 

		) s2 
		ON s.PostRun = s2.PostRun AND s.TransId = s2.TransId


-- insert time/routing records (Machine Setup & Run)
INSERT INTO #Temp(PostRun, ReleaseId, CostGroupId, PlannedCost, ActualCost) 
SELECT o.PostRun, o.ReleaseId, s.MachineCostGroupId
	, ISNULL(s2.PlannedMachCost, 0) AS PlannedCost
	, ISNULL(s2.ActMachCost, 0) AS ActCost 
FROM #tmpProductionVarianceAnalysis t INNER JOIN dbo.tblMpHistoryOrderReleases o ON t.PostRun = o.PostRun AND t.ReleaseId = o.ReleaseId
	INNER JOIN dbo.tblMpHistoryRequirements r ON o.PostRun = r.PostRun AND o.ReleaseId = r.ReleaseId 
	INNER JOIN dbo.tblMpHistoryTimeSum s ON r.PostRun = s.PostRun AND r.TransId = s.TransId
	INNER JOIN 
		(
			SELECT r.PostRun, r.TransId
				, ISNULL((s.MachineSetupEst + s.MachineRunEst) 
					* (s.HourlyCostFactorMach / 60.0), 0) AS PlannedMachCost
				, ISNULL((ISNULL(d.ActMachSetup + d.ActMachRun, 0)) 
					* s.HourlyCostFactorMach, 0) AS ActMachCost 
			FROM dbo.tblMpHistoryRequirements r	INNER JOIN dbo.tblMpHistoryTimeSum s ON r.PostRun = s.PostRun AND r.TransId = s.TransId
				LEFT JOIN 
					(
						SELECT PostRun, TransId
							, ISNULL(MachineSetup / CASE WHEN ISNULL(MachineSetupIn, 0) = 0 THEN 1 
								ELSE MachineSetupIn END, 0) ActMachSetup
							, ISNULL(MachineRun / CASE WHEN ISNULL(MachineRunIn, 0) = 0 THEN 1 
								ELSE MachineRunIn END, 0) ActMachRun 
						FROM dbo.tblMpHistoryTimeDtl
					) d ON s.PostRun = d.PostRun AND s.TransId = d.TransId 
		) s2 
		ON s.PostRun = s2.PostRun AND s.TransId = s2.TransId

-- insert time/routing records (Labor Setup & Run)
INSERT INTO #Temp(PostRun, ReleaseId, CostGroupId, PlannedCost, ActualCost) 
SELECT o.PostRun, o.ReleaseId, s.LaborCostGroupId
	, ISNULL(s2.PlannedLaborCost + (s.PerPieceCostLbr 
		* QtyProducedEst), 0) AS PlannedCost
	, ISNULL(s2.ActLaborCost + (s.PerPieceCostLbr 
		* QtyProducedEst), 0) AS ActCost 
FROM #tmpProductionVarianceAnalysis t INNER JOIN dbo.tblMpHistoryOrderReleases o ON t.PostRun = o.PostRun AND t.ReleaseId = o.ReleaseId
	INNER JOIN dbo.tblMpHistoryRequirements r ON o.PostRun = r.PostRun AND o.ReleaseId = r.ReleaseId 
	INNER JOIN dbo.tblMpHistoryTimeSum s ON r.PostRun = s.PostRun AND r.TransId = s.TransId
	INNER JOIN 
		(
			SELECT r.PostRun, r.TransId
				, ISNULL(((s.LaborEst* (s.HourlyRateLbr / 60.0)) + (s.LaborSetupEst
					* (s.HourlyRateLbrSetup / 60.0))), 0) AS PlannedLaborCost
				, ISNULL((d.ActLabor* s.HourlyRateLbr) + (d.ActLaborSetup* s.HourlyRateLbrSetup), 0)
					 AS ActLaborCost
			FROM dbo.tblMpHistoryRequirements r	INNER JOIN dbo.tblMpHistoryTimeSum s ON r.PostRun = s.PostRun AND r.TransId = s.TransId
				LEFT JOIN 
					(
						SELECT PostRun, TransId
							, ISNULL(Labor / CASE WHEN ISNULL(LaborIn, 0) = 0 THEN 1 
								ELSE LaborIn END, 0) AS ActLabor
							, ISNULL(LaborSetup / CASE WHEN ISNULL(LaborSetupIn, 0) = 0 THEN 1 
								ELSE LaborSetupIn END, 0) AS ActLaborSetup 
						FROM dbo.tblMpHistoryTimeDtl
					) d ON s.PostRun = d.PostRun AND s.TransId = d.TransId 
		) s2 
		ON s.PostRun = s2.PostRun AND s.TransId = s2.TransId

SELECT PostRun, ReleaseId, CostGroupId
	, SUM(PlannedCost) AS PlannedCost, SUM(ActualCost) AS ActualCost
	, CASE WHEN COALESCE(SUM(PlannedCost), 0) <> 0 
		THEN (SUM(ActualCost) - SUM(PlannedCost)) * 100.0 
			/ SUM(PlannedCost) 
		ELSE 0 END AS VariancePct 
INTO #TempSum 
FROM #Temp 
GROUP BY PostRun, ReleaseId, CostGroupId

SELECT PostRun, ReleaseId, CostGroupId, PlannedCost, ActualCost, VariancePct 
FROM #TempSum 
WHERE @ExceptionsOnly = 0 OR (ABS(VariancePct) >= COALESCE(@VariancePct, 0)) 

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpProductionVarianceAnalysis_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpProductionVarianceAnalysis_proc';

