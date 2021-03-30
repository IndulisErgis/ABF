
CREATE PROCEDURE [dbo].[trav_MpCostVariance_Proc]   
@SortBy tinyint = 0,  -- 0 = assembly - 1 = Order/release
@PrintExceptions bit  = 0,
@CriticalVar pDecimal,
@RollupCostYn bit = 0, --option flag for "rolling up" the finished goods cost (needed if using standard costing)
@DateFrom datetime = null, --finish date from
@DateThru datetime = null, --finish date thru
@CompIdFrom nvarchar(24) = null, --component id from
@CompIdThru nvarchar(24) = null, --component id thru
@IncludeMaterials bit = 1,
@IncludeByproducts bit = 1,
@IncludeMachineLaborTime bit = 1,
@IncludeSubcontracted bit = 1,
@IncludeSubassemblies bit = 1
AS
SET NOCOUNT ON

BEGIN TRY

      CREATE TABLE #OrderInfo
      (     PostRun pPostRun NULL,
            ReleaseId int NULL,
            SortBy pItemId NULL,
            OrderNo pTransId NULL,
            ReleaseNo int NULL,
            CustId pCustId NULL,
            AssemblyId pItemId NULL,
            DateCompleted datetime NULL,
            PlannedQty pDecimal NULL,
            StdUnitCost pDecimal NULL,
            ActualQty pDecimal NULL,
            ScrappedQty pDecimal NULL,
            ActUnitCost pDecimal NULL,
            TotalCost pDecimal NULL
      )

      -- for subreport Material
      CREATE TABLE #tmpMaterial
      (     PostRun pPostRun NULL,
            ReleaseId int NULL,
            ReqId nvarchar(4) NULL,
            ComponentId pItemId NULL,
            ComponentType tinyint NULL,
            CostGroupId nvarchar(6) NULL,
            EstQty pDecimal NULL,
            EstScrap pDecimal NULL,
            EstUnitCost pDecimal NULL,
            ActQty pDecimal NULL,
            ActScrap pDecimal NULL,
            ActUnitCost pDecimal NULL,
            EstCost pDecimal NULL, 
            ActCost pDecimal NULL, 
            QtyVariance pDecimal NULL, 
            ScrapVariance pDecimal NULL,
            CostVariancePct pDecimal NULL
      )
      
      --for Cost Variance Byproduct subreport   
      CREATE TABLE #tmpCostVarByproduct
      (     PostRun pPostRun Null,
            ReleaseId int NULL,
            ReqId nvarchar(4) Null,
            ComponentId pItemId Null,
            ComponentType tinyint Null,
            CostGroupId nvarchar(6) Null,
            EstQty pDecimal Null,
            EstScrap pDecimal Null,
            EstUnitCost pDecimal Null,
            ActQty pDecimal Null,
            ActScrap pDecimal Null,
            ActUnitCost pDecimal Null,
            EstCost pDecimal Null, 
            ActCost pDecimal Null, 
            QtyVariance pDecimal Null, 
            CostVariancePct pDecimal Null
      )

      --for Cost Variance Routing subreport     
      CREATE TABLE #tmpCostVarRouting
      (     PostRun pPostRun Null,
            ReleaseId int NULL,
            ReqId nvarchar(4) Null,
            LaborTypeId nvarchar(10) Null,
            LaborSetupTypeId nvarchar(10) Null,
            MachineGroupId nvarchar(10) Null,
            PlannedLaborSetupCost pDecimal Null,
            PlannedLaborCost pDecimal Null,
            PlannedMachSetupCost pDecimal Null,
            PlannedMachCost pDecimal Null,
            ActMachSetupCost pDecimal Null,
            ActMachCost pDecimal Null,
            ActLaborSetupCost pDecimal Null,  
            ActlaborCost pDecimal Null,
            CostVariancePct pDecimal Null
      )

      --for Cost Variance Subcontract subreport 
      CREATE TABLE #tmpSubcontract
      (     PostRun pPostRun Null,
            ReleaseId int NULL,
            ReqId nvarchar(4) Null,
            VendorId pVendorId Null,
            CostGroupId nvarchar(6) Null,
            EstQty pDecimal Null,
            EstUnitCost pDecimal Null,
            ActQty pDecimal Null,
            ActUnitCost pDecimal Null,
            EstCost pDecimal Null, 
            ActCost pDecimal Null, 
            QtyVariance pDecimal Null, 
            CostVariancePct pDecimal Null
      )

      --for Cost Variance SubAssembly subreport 
      CREATE TABLE #tmpSubAssembly
      (     PostRun pPostRun Null,
            ReleaseId int NULL,
            ReqId nvarchar(4) Null,
            ComponentId pItemId Null,
            ComponentType tinyint Null,
            CostGroupId nvarchar(6) Null,
            EstQty pDecimal Null,
            EstScrap pDecimal Null,
            EstUnitCost pDecimal Null,
            ActQty pDecimal Null,
            ActScrap pDecimal Null,
            ActUnitCost pDecimal Null,
            EstCost pDecimal Null, 
            ActCost pDecimal Null, 
            QtyVariance pDecimal Null, 
            ScrapVariance pDecimal Null,
            CostVariancePct pDecimal Null
      )

	INSERT INTO #OrderInfo ( SortBy, PostRun, ReleaseId, OrderNo, ReleaseNo, CustId, AssemblyId, DateCompleted
		, PlannedQty, StdUnitCost, ActualQty, ScrappedQty, ActUnitCost )
	SELECT CASE WHEN @SortBy = 0 THEN o.AssemblyId ELSE o.OrderNo + RIGHT(REPLICATE('0',10) + CAST(o.ReleaseNo AS nvarchar), 10) END SortBy
		  , o.PostRun, o.ReleaseId, o.OrderNo, o.ReleaseNo, o.CustId, o.AssemblyId, m.DateCompleted
		  , (s.EstQtyRequired * s.ConvFactor) AS PlannedQty, (s.UnitCost / s.ConvFactor) AS StdUnitCost, ISNULL(m.QtyCompleted,0) AS ActualQty
		  , ISNULL(m.QtyScrapped,0) AS ScrappedQty,  ISNULL(m.AvgUnitCost,0) AS ActUnitCost
	FROM #tmpCostVariance t INNER JOIN dbo.tblMpHistoryOrderReleases o ON t.postRun = o.PostRun AND t.ReleaseId = o.ReleaseId
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
		
      --if using standard costing - must "rollup" the component cost instead of using unit costs from finished goods
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
                                                       INNER JOIN dbo.tblMpHistoryTimeSum s ON o.PostRun = s.PostRun AND r.TransId = s.TransId
                                                       INNER JOIN dbo.tblMpHistoryTimeDtl d ON s.PostRun = d.PostRun AND s.TransId = d.TransId
                                                 GROUP BY s.PostRun, s.TransId
                                                   ) AS calc ON s1.PostRun = calc.PostRun AND s1.TransId = calc.TransId
                              GROUP BY r.PostRun, r.ReleaseId
                           ) AS tmp ON #OrderInfo.PostRun = tmp.PostRun AND #OrderInfo.ReleaseId = tmp.ReleaseId

	  UPDATE #OrderInfo SET ActUnitCost = CASE WHEN ActualQty + ScrappedQty = 0 THEN 0 ELSE TotalCost / (ActualQty + ScrappedQty) END
	END

    SELECT SortBy, PostRun, OrderNo, ReleaseNo, CustId, AssemblyId, DateCompleted, PlannedQty, ReleaseId  
			,StdUnitCost AS StandardUnitCost, ActualQty, ScrappedQty, ActUnitCost AS ActualUnitCost
            , COALESCE((ActualQty * ActUnitCost), 0) AS TotalActual 
            , COALESCE((PlannedQty * StdUnitCost), 0) AS TotalPlanned
            , CASE WHEN COALESCE(StdUnitCost, 0) <> 0 
                  THEN (COALESCE(ActUnitCost, 0) - COALESCE(StdUnitCost, 0) ) * 100 / COALESCE(StdUnitCost, 0) ELSE 0 END CostVariancePct
	FROM #OrderInfo
	WHERE @PrintExceptions = 0 OR 
		( CASE WHEN COALESCE(StdUnitCost, 0) <> 0 THEN ABS((COALESCE(ActUnitCost, 0) - COALESCE(StdUnitCost, 0) ) * 100 / COALESCE(StdUnitCost, 0)) 
			ELSE 0 END >= COALESCE(@CriticalVar, 0))
                  
      -- Subreport Material   
      INSERT INTO #tmpMaterial (PostRun, ReleaseId, ReqId, ComponentId, ComponentType, CostGroupId, EstQty, EstScrap
            , ActQty, ActScrap, EstCost, ActCost, QtyVariance, ScrapVariance, CostVariancePct )
            
            SELECT s.PostRun, o.ReleaseId, r.ReqId, s.ComponentId, s.ComponentType, s.CostGroupID
                  , (s.EstQtyRequired * s.ConvFactor) AS EstQty, (s.EstScrap * s.ConvFactor)AS EstScrap
                  , d.Qty, d.ActualScrap, ISNULL((s.EstQtyRequired * s.UnitCost), 0), d.ExtCost
                  , CASE WHEN ISNULL((s.EstQtyRequired * s.ConvFactor), 0) <> 0 
                        THEN (ISNULL(d.Qty, 0) - ISNULL((s.EstQtyRequired * s.ConvFactor), 0)) * 100.0 / (ISNULL((s.EstQtyRequired * s.ConvFactor), 0)) 
                        ELSE 0 END QtyVariance
                  , CASE WHEN ISNULL((s.EstScrap * s.ConvFactor), 0) <> 0 
                        THEN (ISNULL(d.ActualScrap, 0) - ISNULL((s.EstScrap * s.ConvFactor), 0)) * 100.0 / (ISNULL((s.EstScrap * s.ConvFactor), 0)) 
                        ELSE 0 END ScrapVariance
                  , CASE WHEN ISNULL((s.EstQtyRequired * s.UnitCost), 0) <> 0 
                        THEN (ISNULL(d.ExtCost, 0) - ISNULL((s.EstQtyRequired * s.UnitCost), 0)) * 100.0 / ISNULL((s.EstQtyRequired * s.UnitCost), 0)
                        ELSE 0 END CostVariancePct
            FROM dbo.tblMpHistoryMatlSum s 
                  INNER JOIN ( SELECT PostRun, TransId
                                          , SUM(Qty * ConvFactor) Qty
                                          , SUM(ActualScrap * ConvFactor) ActualScrap
                                          , SUM(Qty * UnitCost) ExtCost
                                    FROM dbo.tblMpHistoryMatlDtl
                                    GROUP BY PostRun, TransId 
                                 ) AS d ON s.PostRun = d.PostRun AND s.TransId = d.TransId
                  LEFT JOIN dbo.tblMpHistoryRequirements r ON r.PostRun = s.PostRun AND r.TransId = s.TransId
                  LEFT JOIN dbo.tblMpHistoryOrderReleases o ON o.PostRun = r.PostRun AND o.ReleaseId = r.ReleaseId
            WHERE @IncludeMaterials = 1 AND (s.ComponentType = 3 OR s.ComponentType = 4) --stocked or material
				AND (@CompIdFrom IS NULL OR s.ComponentID >= @CompIdFrom)
		AND (@CompIdThru IS NULL OR s.ComponentID <= @CompIdThru)
		
      SELECT PostRun, ReleaseId, ComponentId, CostGroupId
            , EstQty AS PlannedQty, EstScrap AS EstimatedScrap , ActQty AS ActualQty
            , ActScrap AS ActualScrap, EstCost AS EstimatedCost, ActCost AS ActualCost
            , QtyVariance , ScrapVariance , CostVariancePct
            FROM #tmpMaterial 
            WHERE @PrintExceptions = 0 OR  (ABS(QtyVariance) >= ISNULL(@CriticalVar, 0) AND ABS(ScrapVariance) >= ISNULL(@CriticalVar, 0)
                  AND ABS(CostVariancePct) >= ISNULL(@CriticalVar, 0))
                  
	--Cost Variance Byproduct subreport       
	INSERT INTO #tmpCostVarByproduct (PostRun, ReleaseId, ReqId, ComponentId, ComponentType, CostGroupId, EstQty, EstScrap
            , ActQty, ActScrap, EstCost, ActCost, QtyVariance, CostVariancePct )
	SELECT s.PostRun, o.ReleaseId, r.ReqId, s.ComponentId, s.ComponentType, s.CostGroupID
		  , (s.EstQtyRequired * s.ConvFactor) AS EstQty, (s.EstScrap * s.ConvFactor) AS  EstScrap
		  , d.Qty, d.ActualScrap, ISNULL((s.EstQtyRequired * s.UnitCost), 0), d.ExtCost
		  , CASE WHEN ISNULL((s.EstQtyRequired * s.ConvFactor), 0) <> 0 
				THEN (ISNULL(d.Qty, 0) - ISNULL((s.EstQtyRequired * s.ConvFactor), 0)) * 100.0 / (ISNULL((s.EstQtyRequired * s.ConvFactor), 0))
				ELSE 0 END QtyVariance
		  , CASE WHEN ISNULL((s.EstQtyRequired * s.UnitCost), 0) <> 0 
				THEN (ISNULL(d.ExtCost, 0) - ISNULL((s.EstQtyRequired * s.UnitCost), 0)) * 100.0 / ISNULL((s.EstQtyRequired * s.UnitCost), 0) 
				ELSE 0 END CostVariancePct
	FROM dbo.tblMpHistoryMatlSum s 
		  INNER JOIN ( SELECT PostRun, TransId
                                          , SUM(Qty * ConvFactor) Qty
                                          , SUM(ActualScrap * ConvFactor) ActualScrap
                                          , SUM(Qty * UnitCost) ExtCost
                                    FROM dbo.tblMpHistoryMatlDtl
                                    GROUP BY PostRun, TransId
							) AS  d ON s.PostRun = d.PostRun AND s.TransId = d.TransId
		  LEFT JOIN dbo.tblMpHistoryRequirements r ON r.PostRun = s.PostRun AND r.TransId = s.TransId
		  LEFT JOIN dbo.tblMpHistoryOrderReleases o ON o.PostRun = r.PostRun AND o.ReleaseId = r.ReleaseId
	WHERE @IncludeByproducts = 1 AND (s.ComponentType = 5) --Byproducts
		AND (@CompIdFrom IS NULL OR s.ComponentID >= @CompIdFrom)
		AND (@CompIdThru IS NULL OR s.ComponentID <= @CompIdThru)
		
	SELECT PostRun, ReleaseId, ComponentId, CostGroupId, EstQty AS PlannedQty, ActQty AS ActualQty
		, EstCost AS EstimatedValue, ActCost AS ActualValue, QtyVariance, CostVariancePct
	FROM #tmpCostVarByproduct 
	WHERE @PrintExceptions = 0 OR (ABS(QtyVariance) >= ISNULL(@CriticalVar, 0) AND ABS(CostVariancePct) >= ISNULL(@CriticalVar, 0))
            
      --for Cost Variance Routing subreport           
      INSERT INTO #tmpCostVarRouting (PostRun, ReleaseId, ReqId, LaborTypeId, LaborSetupTypeId, MachineGroupId
            , PlannedLaborSetupCost, PlannedLaborCost, PlannedMachSetupCost
            , PlannedMachCost, ActMachSetupCost, ActMachCost, ActLaborSetupCost, ActLaborCost, CostVariancePct)
            SELECT s2.PostRun, o.ReleaseId, r.ReqId, s2.LaborTypeId, s2.LaborSetupTypeId, s2.MachineGroupId
                  , ((s2.LaborSetupEst * s2.HourlyRateLbrSetup) / 60.0) PlannedLaborSetupCost
                  , ((s2.LaborEst * s2.HourlyRateLbr) / 60.0) PlannedLaborCost
                  , ((s2.MachineSetupEst * s2.HourlyCostFactorMach) / 60.0) PlannedMachSetupCost
                  , ((s2.MachineRunEst * s2.HourlyCostFactorMach) / 60.0) PlannedMachCost
                  , ((ISNULL(d1.MachineSetup, 0)) * s2.HourlyCostFactorMach) ActMachSetupCost
                  , ((ISNULL(d1.MachineRun, 0)) * s2.HourlyCostFactorMach) ActMachCost
                  , ((ISNULL(d1.LaborSetup, 0)) * s2.HourlyRateLbrSetup) ActLaborSetupCost
                  , ((ISNULL(d1.Labor, 0)) * s2.HourlyRateLbr) ActLaborCost
                  , CASE WHEN (((ISNULL(s2.MachineRunEst, 0) + ISNULL(s2.MachineSetupEst, 0)) * ISNULL(s2.HourlyCostFactorMach, 0))
                        + ((ISNULL(s2.LaborEst, 0)* ISNULL(s2.HourlyRateLbr, 0)) + (ISNULL(s2.LaborSetupEst, 0) * ISNULL(s2.HourlyRateLbrSetup, 0)))) <> 0 
                        THEN ((
                        ( ((ISNULL(d1.MachineRun, 0) + ISNULL(d1.MachineSetup, 0)) * ISNULL(s2.HourlyCostFactorMach, 0))
                              + ((ISNULL(d1.Labor, 0)* ISNULL(s2.HourlyRateLbr, 0)) + (ISNULL(d1.LaborSetup, 0) * ISNULL(s2.HourlyRateLbrSetup, 0))) )
                        - (( ((ISNULL(s2.MachineRunEst, 0) + ISNULL(s2.MachineSetupEst, 0)) * ISNULL(s2.HourlyCostFactorMach, 0)) 
                              + ((ISNULL(s2.LaborEst, 0)* ISNULL(s2.HourlyRateLbr, 0)) + (ISNULL(s2.LaborSetupEst, 0) * ISNULL(s2.HourlyRateLbrSetup, 0))) ) / 60.0)
                        ) * 100.0) 
                        / (( ((ISNULL(s2.MachineRunEst, 0) + ISNULL(s2.MachineSetupEst, 0)) * ISNULL(s2.HourlyCostFactorMach, 0)) 
                              + ((ISNULL(s2.LaborEst, 0)* ISNULL(s2.HourlyRateLbr, 0)) + (ISNULL(s2.LaborSetupEst, 0)* ISNULL(s2.HourlyRateLbrSetup, 0)))  ) / 60.0)                      
                        ELSE 0 END CostVariancePct
            FROM dbo.tblMpHistoryTimeSum s2
                  LEFT JOIN ( SELECT d.PostRun, d.TransId
                                          , SUM(d.MachineSetup / CASE WHEN ISNULL(d.MachineSetupIn, 0) = 0 THEN 1 ELSE d.MachineSetupIn END) MachineSetup
                                          , SUM(d.MachineRun / CASE WHEN ISNULL(d.MachineRunIn, 0) = 0 THEN 1 ELSE d.MachineRunIn END) MachineRun
                                          , SUM(d.LaborSetup / CASE WHEN ISNULL(d.LaborSetupIn, 0) = 0 THEN 1 ELSE d.LaborSetupIn END) LaborSetup
                                          , SUM(d.Labor / CASE WHEN ISNULL(d.LaborIn, 0) = 0 THEN 1 Else d.LaborIn End) Labor
                                    FROM dbo.tblMpHistoryTimeDtl d 
                                    GROUP BY d.PostRun, d.TransId 
                               ) AS d1 ON s2.PostRun = d1.PostRun AND s2.TransId = d1.TransId
                  LEFT JOIN dbo.tblMpHistoryRequirements r ON r.PostRun = s2.PostRun AND r.TransId = s2.TransId
                  LEFT JOIN dbo.tblMpHistoryOrderReleases o ON o.PostRun = r.PostRun AND o.ReleaseId = r.ReleaseId
		WHERE @IncludeMachineLaborTime = 1
		
      SELECT PostRun, ReleaseId, LaborTypeId, LaborSetupTypeId, MachineGroupId
            , PlannedLaborSetupCost AS EstimatedLaborSetupCost, PlannedLaborCost AS EstimatedLaborCost
            , PlannedMachSetupCost AS EstimatedMachSetupCost, PlannedMachCost AS EstimatedMachCost
            , ActMachSetupCost AS ActualMachSetupCost, ActMachCost AS ActualMachCost, ActLaborSetupCost AS ActualLaborSetupCost
            , ActlaborCost AS ActualLaborCost, CostVariancePct
      FROM #tmpCostVarRouting
      WHERE @PrintExceptions = 0 OR ABS(CostVariancePct) >= ISNULL(@CriticalVar, 0)
      
      --Cost Variance Subcontract subreport     
      Insert into #tmpSubcontract (PostRun, ReleaseId, ReqId, VendorId, CostGroupId
            , EstQty, EstUnitCost, ActQty, ActUnitCost, EstCost, ActCost, QtyVariance, CostVariancePct )
            Select s.PostRun, o.ReleaseId, r.ReqId, s.DefaultVendorID, s.CostGroupID
                  , (s.EstQtyRequired) EstQty, (s.EstPerPieceCost) EstUnitCost
                  , d.Qty, Case When d.Qty <> 0 Then (d.ExtCost / d.Qty) Else 0.0 End 
                  , isnull((s.EstQtyRequired * s.EstPerPieceCost), 0), d.ExtCost
                  , Case WHEN isnull((s.EstQtyRequired), 0) <> 0 
                        Then (isnull(d.Qty, 0) - isnull((s.EstQtyRequired), 0)) * 100.0 / (isnull((s.EstQtyRequired), 0)) 
                        Else 0 End QtyVariance
                  , Case WHEN isnull((s.EstQtyRequired * s.EstPerPieceCost), 0) <> 0 
                        Then (isnull(d.ExtCost, 0) - isnull((s.EstQtyRequired * s.EstPerPieceCost), 0)) * 100.0 / isnull((s.EstQtyRequired * s.EstPerPieceCost), 0) 
                        Else 0 end CostVariancePct
            From dbo.tblMpHistorySubContractSum s 
                  inner join ( Select d2.PostRun, d2.TransId
                                          , Sum(d2.QtySent) Qty
                                          , Sum(d2.QtySent * d2.UnitCost) ExtCost
                                    From dbo.tblMpHistorySubContractDtl d2
                                    Group By d2.PostRun, d2.TransId 
                                ) AS d on s.PostRun = d.PostRun and s.TransId = d.TransId
                  LEFT JOIN dbo.tblMpHistoryRequirements r ON r.PostRun = s.PostRun AND r.TransId = s.TransId
                  LEFT JOIN dbo.tblMpHistoryOrderReleases o ON o.PostRun = r.PostRun AND o.ReleaseId = r.ReleaseId
		WHERE @IncludeSubcontracted = 1
		
      Select PostRun, ReleaseId, VendorId, CostGroupId, EstQty AS EstimatedQty, ActQty AS ActualQty
            , EstCost AS EstimatedCost, ActCost AS ActualCost, QtyVariance, CostVariancePct
            From #tmpSubcontract 
            WHERE @PrintExceptions = 0 OR (ABS(QtyVariance) >= isnull(@CriticalVar, 0)
                  and ABS(CostVariancePct) >= isnull(@CriticalVar, 0))
      
      -- Cost Variance SubAssembly subreport
      Insert into #tmpSubAssembly (PostRun, ReleaseId, ReqId, ComponentId, ComponentType, CostGroupId
            , EstQty, EstScrap, ActQty, ActScrap, EstCost, ActCost, QtyVariance, ScrapVariance, CostVariancePct)
      Select s.PostRun, o.ReleaseId, r.ReqId, s.ComponentId, s.ComponentType, s.CostGroupID
            , (s.EstQtyRequired * s.ConvFactor) EstQty
            , (s.EstScrap * s.ConvFactor) EstScrap
            , d.Qty, d.ActualScrap, isnull((s.EstQtyRequired * s.UnitCost), 0)
            , d.ExtCost
            , Case WHEN isnull((s.EstQtyRequired * s.ConvFactor), 0) <> 0 
                  Then (isnull(d.Qty, 0) - isnull((s.EstQtyRequired * s.ConvFactor), 0)) * 100.0 / (isnull((s.EstQtyRequired * s.ConvFactor), 0)) 
                  Else 0 End QtyVariance
            , Case WHEN isnull((s.EstScrap * s.ConvFactor), 0) <> 0 
                  Then (isnull(d.ActualScrap, 0) - isnull((s.EstScrap * s.ConvFactor), 0)) * 100.0 / (isnull((s.EstScrap * s.ConvFactor), 0)) 
                  Else 0 End ScrapVariance
            , Case WHEN isnull((s.EstQtyRequired * s.UnitCost), 0) <> 0 
                  Then (isnull(d.ExtCost, 0) - isnull((s.EstQtyRequired * s.UnitCost), 0)) * 100.0 / isnull((s.EstQtyRequired * s.UnitCost), 0) 
                  Else 0 end CostVariancePct
      From dbo.tblMpHistoryMatlSum s 
            inner join ( SELECT PostRun, TransId
                                          , SUM(Qty * ConvFactor) Qty
                                          , SUM(ActualScrap * ConvFactor) ActualScrap
                                          , SUM(Qty * UnitCost) ExtCost
                                    FROM dbo.tblMpHistoryMatlDtl
                                    GROUP BY PostRun, TransId
                        ) AS d on s.PostRun = d.PostRun and s.TransId = d.TransId
                  LEFT JOIN dbo.tblMpHistoryRequirements r ON r.PostRun = s.PostRun AND r.TransId = s.TransId
                  LEFT JOIN dbo.tblMpHistoryOrderReleases o ON o.PostRun = r.PostRun AND o.ReleaseId = r.ReleaseId
      Where @IncludeSubassemblies = 1 AND (s.ComponentType = 2) --subassemblies
			AND (@CompIdFrom IS NULL OR s.ComponentID >= @CompIdFrom)
			AND (@CompIdThru IS NULL OR s.ComponentID <= @CompIdThru)
	Select PostRun, ReleaseId, ComponentId, CostGroupId, EstQty AS PlannedQty, EstScrap AS EstimatedScrap,ActQty AS ActualQty
		, ActScrap AS ActualScrap, EstCost AS EstimatedCost, ActCost AS ActualCost, QtyVariance, ScrapVariance, CostVariancePct
	From #tmpSubAssembly 
	WHERE @PrintExceptions = 0 OR (ABS(QtyVariance) >= isnull(@CriticalVar, 0) AND ABS(ScrapVariance) >= isnull(@CriticalVar, 0) 
		   AND ABS(CostVariancePct) >= isnull(@CriticalVar, 0))
                              
END TRY
BEGIN CATCH
      EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpCostVariance_Proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpCostVariance_Proc';

