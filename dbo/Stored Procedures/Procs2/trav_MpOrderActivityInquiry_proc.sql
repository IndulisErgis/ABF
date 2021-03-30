
CREATE procedure  [dbo].[trav_MpOrderActivityInquiry_proc]     
 (@ReleaseId int,@TransType int)    
 As      
 /*    
--@TransType    
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
    
if(@TransType IN (1,2,4,6))  
 
	BEGIN      
		SELECT d.TransDate, d.ComponentId, i.Descr,d.LocId, (ISNULL(s.EstQtyRequired,0)* ISNULL(su.ConvFactor,1))/ISNULL(du.ConvFactor,1) AS EstQty, (ISNULL(s.EstScrap,0)* ISNULL(su.ConvFactor,1))/ISNULL(du.ConvFactor,1) AS EstScrap, d.Qty AS ActualQty,d.ActualScrap AS ActualScrap, d.UOM, d.GlPeriod, d.FiscalYear,  
			   d.VarianceCode,d.SubAssemblyTranType, d.Notes    
		FROM dbo.tblMpMatlDtl AS d 
			 INNER JOIN dbo.tblMpRequirements AS r ON  r.TransId = d.TransId AND r.[Type] IN(0,2,3,4,5)
			 INNER JOIN dbo.tblMpMatlSum AS s ON r.TransId = s.TransId
			 LEFT  JOIN dbo.tblInItemUom AS su ON s.ComponentId = su.ItemId AND s.UOM = su.Uom
			 LEFT  JOIN dbo.tblInItemUom AS du ON s.ComponentId = du.ItemId AND s.UOM = du.Uom
			 LEFT  JOIN dbo.tblInItem i ON d.ComponentId = i.ItemId
		WHERE r.ReleaseId =@ReleaseId     
			  AND ((@TransType=1 AND  r.[Type]=0)    
						OR    
				   (@TransType=2 And (r.[Type]=3 OR r.[Type]=4))    
						OR    
				   (@TransType=4 And r.[Type]=5)    
						OR  
				   (@TransType=6 And r.[Type]=2))  
	END        
    
Else if(@TransType=3)
    
	BEGIN    
		SELECT d.TransDate, s.OperationId, s.LaborTypeId, (d.LaborSetup/d.LaborSetupIn) AS ActLaborSetUp,    
			   (d.Labor/d.LaborIn) AS ActLaborRun, s.MachineGroupId, (d.MachineSetup/d.MachineSetupIn) AS ActMachineSetup,     
		       (d.MachineRun/d.MachineRunIn) AS ActMachineRun , s.WorkCenterId, d.EmployeeId, d.QtyProduced,     
			   d.QtyScrapped, d.VarianceCode, r.ReqId    
		FROM dbo.tblMpRequirements AS r 
			 INNER JOIN dbo.tblMpTimeDtl AS d ON r.TransId = d.TransId AND r.[Type]=1 
			 INNER JOIN dbo.tblMpTimeSum AS s ON d.TransId = s.TransId    
		WHERE r.ReleaseId =@ReleaseId     
	END       
    
Else if(@TransType=5) 
   
	BEGIN    
		SELECT d.TransDate, d.QtySent, d.QtyReceived, d.QtyScrapped, d.VendorId, d.VendorDocNo, d.UnitCost,     
		       d.GlPeriod, d.FiscalYear, d.Notes, r.ReqId    
		FROM dbo.tblMpRequirements AS r 
		     INNER JOIN dbo.tblMpSubContractDtl AS d ON r.TransId = d.TransId AND r.[Type]=6    
		WHERE r.ReleaseId =@ReleaseId                            
	END    
  
END TRY    
BEGIN CATCH    
 EXEC dbo.trav_RaiseError_proc    
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpOrderActivityInquiry_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpOrderActivityInquiry_proc';

