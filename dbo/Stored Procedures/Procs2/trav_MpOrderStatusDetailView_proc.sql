
CREATE PROCEDURE  [dbo].[trav_MpOrderStatusDetailView_proc]  
	@ReleaseId int,  
	@TransType smallint,
	@TimeUnit smallint = 1
AS  
SET NOCOUNT ON  
BEGIN TRY
/*
--@TransType
Production		= 1
Components		= 2
Process			= 3
By-Product		= 4
Subcontracted   = 5
SubAssembly     = 6
--REQUIREMENT TYPE
Production		= 0
Components		= 3 or 4
Process			= 1
By-Product		= 5
Subcontracted   = 6
SubAssembly     = 2
*/
	IF @TransType IN (1,2,4)--1(Production),2(Components),4(By-Product)
	BEGIN
		--Production(Requirement Type = 0),Components(Requirement Type = 3 or 4),By-Product(Requirement Type = 5)
		SELECT  r.ReqId,s.ComponentId,i.Descr,s.UOM,s.LocId,s.CostGroupId,s.Notes,s.EstQtyRequired,s.EstScrap,
		(ISNULL(d.ActualQty,0)/ISNULL(su.ConvFactor,1))  AS ActualQty,
		(ISNULL(d.ActualScrap,0)/ISNULL(su.ConvFactor,1)) AS ActualScrap 
		FROM dbo.tblMpRequirements r
		INNER JOIN dbo.tblMpMatlSum s 
		ON r.TransId = s.TransId AND r.[Type] IN (0,3,4,5)
	    LEFT JOIN
        (
			SELECT dt.TransId,SUM(dt.Qty * ISNULL(du.ConvFactor,1))  AS ActualQty,
			SUM(dt.ActualScrap * ISNULL(du.ConvFactor,1)) AS ActualScrap 
			FROM dbo.tblMpMatlDtl dt
			LEFT JOIN dbo.tblInItemUom du 
			ON dt.ComponentId = du.ItemId AND dt.UOM = du.Uom	
			GROUP BY dt.TransId
        ) d 
		ON s.TransId = d.TransId 
		LEFT JOIN dbo.tblInItemUom su
		ON s.ComponentId = su.ItemId AND s.UOM = su.Uom 
		LEFT JOIN dbo.tblInItem i 
		ON s.ComponentId = i.ItemId 
		WHERE r.ReleaseId = @ReleaseId AND (
			(@TransType = 1 AND  r.[Type] = 0) --Production
		 OR (@TransType = 2 AND (r.[Type] = 3 OR r.[Type] = 4))--Components
		 OR (@TransType = 4 AND  r.[Type] = 5)) --By-Product
		ORDER BY r.ReqId  
	END
	ELSE IF @TransType = 3
	BEGIN
		--Process(Requirement Type = 1)
		SELECT r.ReqId,s.OperationId,s.LaborTypeId,s.MachineGroupId,s.WorkCenterId,
		(s.LaborSetupEst*(@TimeUnit/60.0))AS LaborSetupEst,ISNULL(d.LaborSetupAct, 0) AS LaborSetupAct,
		(s.LaborEst*(@TimeUnit/60.0))AS LaborEst,ISNULL(d.LaborAct, 0) AS LaborAct,
		(s.MachineSetupEst*(@TimeUnit/60.0))AS MachineSetupEst,ISNULL(d.MachineSetupAct, 0) AS MachineSetupAct,
		(s.MachineRunEst*(@TimeUnit/60.0))AS MachineRunEst,ISNULL(d.MachineRunAct, 0) AS MachineRunAct, s.LaborSetupTypeId
		FROM dbo.tblMpRequirements r
		INNER JOIN dbo.tblMpTimeSum s 
		ON r.TransId = s.TransId AND r.[Type] = 1
		LEFT JOIN 
		(			
			 SELECT TransId,(SUM(LaborSetup/ LaborSetupIn) *@TimeUnit)  AS LaborSetupAct,
			 (SUM(Labor/LaborIn)*@TimeUnit) AS LaborAct,
			 (SUM(MachineSetup/MachineSetupIn)*@TimeUnit) AS MachineSetupAct,
			 (SUM(MachineRun/MachineRunIn)*@TimeUnit) AS MachineRunAct
			 FROM dbo.tblMpTimeDtl  
			 GROUP BY TransId
		) d 
		ON s.TransId = d.TransId 
		WHERE r.ReleaseId = @ReleaseId 
		ORDER BY r.ReqId 
	END
	ELSE IF @TransType = 5
	BEGIN 
		--Subcontracted(Requirement Type = 6)
        SELECT r.TransId,r.ReqId,s.OperationId,o.Descr,s.DefaultVendorId,s.EstPerPieceCost,s.Notes,
        ISNULL(d.QtySent,0) AS QtySent, ISNULL(d.QtyReceived,0) AS QtyReceived,ISNULL(d.QtyScrapped,0) AS QtyScrapped  
        FROM dbo.tblMpRequirements r
        INNER JOIN dbo.tblMpSubContractSum s 
        ON r.TransId = s.TransId AND r.[Type] = 6
        LEFT JOIN
        (
            SELECT TransId, SUM(QtySent) AS QtySent, 
            SUM(QtyReceived) AS QtyReceived,SUM(QtyScrapped) AS QtyScrapped   
            FROM dbo.tblMpSubContractDtl 
            GROUP BY TransId
        ) d
        ON s.TransId = d.TransId 
        LEFT JOIN dbo.tblMrOperations o 
        ON s.OperationID = o.OperationId 
		WHERE r.ReleaseId =@ReleaseId	
		ORDER BY r.ReqId 
	END
	ELSE IF @TransType = 6  
	BEGIN
		--SubAssembly(Requirement Type = 2)	
		SELECT r.ReqId,s.ComponentId,ISNULL(d.Qty,0) AS Qty,d.SubAssemblyTranType,s.UOM 
		FROM dbo.tblMpRequirements r
		INNER JOIN dbo.tblMpMatlSum s 
		ON r.TransId = s.TransId AND r.[Type] = 2
		LEFT JOIN
		(
			SELECT TransId,SubAssemblyTranType,SUM(Qty) AS Qty
		    FROM dbo.tblMpMatlDtl
		    GROUP BY TransId,SubAssemblyTranType
		 ) d
		 ON s.TransId = d.TransId
		WHERE r.ReleaseId = @ReleaseId
		ORDER BY r.ReqId 
	END
	
END TRY  
BEGIN CATCH  
 EXEC dbo.trav_RaiseError_proc  
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpOrderStatusDetailView_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpOrderStatusDetailView_proc';

