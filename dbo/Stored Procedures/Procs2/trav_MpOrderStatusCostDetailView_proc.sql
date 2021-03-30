
CREATE PROCEDURE [dbo].[trav_MpOrderStatusCostDetailView_proc]
 @ReleaseId int 
AS
SET NOCOUNT ON

BEGIN TRY

	Create Table #TempCosts  
	(   
		ReqId  int ,
		Reference nvarchar(50),  
		MatlCostEst pDecimal default(0),  
		MatlCostAct pDecimal default(0),  
		TimeCostEst pDecimal default(0),  
		TimeCostAct pDecimal default(0),  
		SubContractCostEst pDecimal default(0),  
		SubContractCostAct pDecimal default(0)  
	)  
  
	--Costs (Materials Est)  
	INSERT INTO #TempCosts(ReqId, Reference, MatlCostEst)  
	SELECT r.ReqId, s.ComponentId, ISNULL(SUM(CASE WHEN s.ComponentType = 5   
		THEN -(ISNULL(s.EstQtyRequired * s.UnitCost, 0)) --reverse sign for byproducts  
		ELSE ISNULL(s.EstQtyRequired * s.UnitCost, 0)  
	    END), 0)  
	FROM dbo.tblMpRequirements r
		INNER JOIN dbo.tblMpMatlSum s   
		ON r.TransId = s.TransId  and s.ComponentType in (4, 5)  
	WHERE r.ReleaseId = @ReleaseId 
	GROUP BY r.ReqId, s.ComponentId  
  
	--Costs (Materials Act)  
	INSERT INTO #TempCosts(ReqId, Reference, MatlCostAct)  
	SELECT  r.ReqId,  d.ComponentId, 	ISNULL(SUM( CASE s.ComponentType   
            WHEN 2 THEN --Subassembly  
               CASE d.SubAssemblyTranType  
               WHEN 2 THEN 0 --assembled get cost from components used  
               WHEN 1 THEN d.Qty * d.UnitCost --cost pulled from stock  
               WHEN -1 THEN -d.Qty * d.UnitCost --cost moved to stock (credit)  
               END  
            WHEN 3 THEN d.Qty * d.UnitCost      --Stocked subassembly  
            WHEN 4 THEN d.Qty * d.UnitCost   --Material  
            WHEN 5 THEN -d.Qty * d.UnitCost     --ByProduct (credit)  
            END ),0)  
	FROM dbo.tblMpRequirements r
		INNER JOIN dbo.tblMpMatlSum s 
		ON r.TransId = s.TransId  And s.ComponentType in (2, 3, 4, 5) 
		INNER JOIN dbo.tblMpMatlDtl d 
		ON s.TransId = d.TransId  
	WHERE r.ReleaseId = @ReleaseId 
	GROUP BY r.ReqId, d.ComponentId  	

  
	--Costs (Time Est)  
	INSERT INTO #TempCosts( ReqId, Reference, TimeCostEst)  
	SELECT  r.ReqId, LaborTypeId + N'/' + MachineGroupId,   
		 ISNULL(SUM( ((1 + (LaborPctOvhd / 100.0)) * (((LaborSetupEst / 60.0)* HourlyRateLbrSetup) + ((LaborEst / 60.0) * HourlyRateLbr))) 
		 + ((1 + (MachPctOvhd / 100.0)) * (((MachineSetupEst / 60.0) + (MachineRunEst / 60.0)) * HourlyCostFactorMach))  
		 + FlatAmtOvhd  
		 + (PerPieceOvhd * QtyProducedEst)), 0)  
	FROM dbo.tblMpRequirements r
		INNER JOIN dbo.tblMpTimeSum s                        
	    ON r.TransId = s.TransId  
	WHERE r.ReleaseId = @ReleaseId                  
    GROUP BY  r.ReqId, LaborTypeId, MachineGroupId     

  
	--Costs (Time Act)  
	INSERT INTO #TempCosts(ReqId, Reference, TimeCostAct)  
	SELECT r.ReqId, LaborTypeId + N'/' + MachineGroupId  
		 , ISNULL(SUM( ((1 + (LaborPctOvhd / 100.0)) * (((LaborSetup / LaborSetupIn)* HourlyRateLbrSetup) + ((Labor / LaborIn)* HourlyRateLbr)) ) 
		 + ((1 + (MachPctOvhd / 100.0)) * (((MachineSetup / MachineSetupIn) + (MachineRun / MachineRunIn)) * HourlyCostFactorMach))  
		 + (PerPieceOvhd *(d.QtyProduced+d.QtyScrapped)))	 + MIN(FlatAmtOvhd) , 0)  --Apply FlatAmtOvhd only once - PET:239363
	 FROM dbo.tblMpRequirements r
		 INNER JOIN dbo.tblMpTimeSum s 
	     ON r.TransId = s.TransId   
		 INNER JOIN dbo.tblMpTimeDtl d 
		 ON s.TransId = d.TransId  
	 WHERE r.ReleaseId = @ReleaseId 
	 GROUP BY r.ReqId, LaborTypeId, MachineGroupId  	

  
	--Costs (Subcontract Est)  
	INSERT INTO #TempCosts(ReqId, Reference, SubContractCostEst)  
	SELECT  r.ReqId, s.[Description], ISNULL(SUM(EstQtyRequired * EstPerPieceCost), 0)  
    FROM dbo.tblMpRequirements r
		INNER JOIN dbo.tblMpSubContractSum s
		ON r.TransId = s.TransId  
	 WHERE r.ReleaseId = @ReleaseId 
	 GROUP BY r.ReqId, s.[Description]  
	  
	--Costs (Subcontract Act)  
	INSERT INTO #TempCosts(ReqId, Reference, SubContractCostAct)  
	SELECT r.ReqId, VendorId, ISNULL(SUM(QtyReceived * UnitCost), 0)   
    FROM dbo.tblMpRequirements r
		INNER JOIN dbo.tblMpSubContractSum s   
		ON r.TransId = s.TransId  
		INNER JOIN dbo.tblMpSubContractDtl d 
		ON s.TransId = d.TransId  
	 WHERE r.ReleaseId = @ReleaseId 
	 GROUP BY r.ReqId, VendorId  
	  
	 --Total
	SELECT ReqId, Reference  
		, SUM(MatlCostEst) MatlCostEst, SUM(MatlCostAct) MatlCostAct  
		, SUM(TimeCostEst) TimeCostEst, SUM(TimeCostAct) TimeCostAct  
		, SUM(SubContractCostEst) SubContractCostEst, SUM(SubContractCostAct) SubContractCostAct  
		, SUM(MatlCostEst + TimeCostEst + SubContractCostEst) TotCostEst  
		, SUM(MatlCostAct + TimeCostAct + SubContractCostAct) TotCostAct  
		, CASE WHEN SUM(MatlCostEst + TimeCostEst + SubContractCostEst) <> 0  
		THEN (SUM(MatlCostAct + TimeCostAct + SubContractCostAct) / SUM(MatlCostEst + TimeCostEst + SubContractCostEst)) * 100.0
		ELSE 100.0
		END TotCostPct  
	 FROM #TempCosts  
	 GROUP BY ReqId, Reference  
	 ORDER BY ReqId 
  
END TRY
BEGIN CATCH
      EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpOrderStatusCostDetailView_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpOrderStatusCostDetailView_proc';

