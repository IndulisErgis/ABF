
CREATE PROCEDURE  [dbo].[trav_MpProductionHistoryDetailView_proc]     
  @PostRun pPostRun,
  @ReleaseId int,
  @HistType smallint
 As      
 /*    
--@HistType    
Production  = 1    
Components  = 2    
Process   = 3    
By-Product  = 4    
Subcontracted   = 5    
SubAssembly     = 6    
--REQUIREMENT TYPE    
Production  = 0    
Components  = 3 or 4    
Process   = 1    
By-Product  = 5    
Subcontracted   = 6    
SubAssembly     = 2    
*/    
SET NOCOUNT ON    
BEGIN TRY    
    
if(@HistType IN (1,2,4,6))   
  
	BEGIN      
		SELECT    m.TransDate,m.ComponentId,i.Descr,m.LocId, m.Qty, m.ActualScrap, m.UOM, m.GlPeriod, m.FiscalYear,  
		m.VarianceCode,m.SubAssemblyTranType, m.Notes ,r.ReqId  
		FROM         dbo.tblMpHistoryMatlDtl AS m INNER JOIN    
					  dbo.tblMpHistoryRequirements AS r ON m.PostRun = r.PostRun AND  r.TransId = m.TransId     
					  AND r.[Type] IN(0,2,3,4,5)   LEFT OUTER JOIN  
					  dbo.tblInItem i ON m.ComponentId = i.ItemId  
		WHERE r.PostRun=@PostRun AND r.ReleaseId =@ReleaseId     
		AND  (  
		(@HistType=1 AND  r.[Type]=0)    
		OR    
		(@HistType=2 And (r.[Type]=3 OR r.[Type]=4))    
		OR    
		(@HistType=4 And r.[Type]=5)    
		OR  
		(@HistType=6 And r.[Type]=2))  
	END        
    
Else if(@HistType=3)    
	BEGIN    
			SELECT   d.TransDate, s.OperationId, s.LaborTypeId, (d.LaborSetup/d.LaborSetupIn) AS ActLaborSetUp,    
					 (d.Labor/d.LaborIn) AS ActLaborRun, s.MachineGroupId, (d.MachineSetup/d.MachineSetupIn) AS ActMachineSetup,     
					 (d.MachineRun/d.MachineRunIn) AS ActMachineRun , s.WorkCenterId, d.EmployeeId, d.QtyProduced,     
					  d.QtyScrapped, d.VarianceCode, r.ReqId    
			FROM     dbo.tblMpHistoryRequirements AS r INNER JOIN    
					 dbo.tblMpHistoryTimeDtl AS d ON r.PostRun = d.PostRun AND r.TransId = d.TransId AND r.[Type]=1 INNER JOIN    
					 dbo.tblMpHistoryTimeSum AS s ON r.PostRun = s.PostRun AND d.TransId = s.TransId    
					 WHERE r.PostRun=@PostRun AND r.ReleaseId =@ReleaseId     
	END       
    
Else if(@HistType=5)    
	BEGIN    
		  SELECT     d.TransDate, d.QtySent, d.QtyReceived, d.QtyScrapped, d.VendorId, d.VendorDocNo, d.UnitCost,     
		  d.GlPeriod, d.FiscalYear, d.Notes, r.ReqId    
		  FROM         dbo.tblMpHistoryRequirements AS r INNER JOIN    
					   dbo.tblMpHistorySubContractDtl AS d ON r.PostRun = d.PostRun AND r.TransId = d.TransId AND r.[Type]=6    
					   WHERE r.PostRun=@PostRun AND r.ReleaseId =@ReleaseId                            
	END    
  
END TRY    
BEGIN CATCH    
 EXEC dbo.trav_RaiseError_proc    
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpProductionHistoryDetailView_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpProductionHistoryDetailView_proc';

