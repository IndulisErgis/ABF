
CREATE VIEW dbo.pvtMpWorkRemaining
AS

SELECT o.OrderNo AS 'Order No', o.ReleaseNo AS 'Release No', r.ReqId AS 'Req ID', s.OperationId AS 'Operation ID'
	, s.OperSupervisor AS 'Supervisor', s.WorkCenterID AS 'Work Center ID', s.LaborSetupTypeId AS 'Labor Setup Type ID'
	, s.LaborSetupEst AS 'Est Labor Setup Time'
	, CASE WHEN d.LaborSetup IS NULL THEN s.LaborSetupEst ELSE s.LaborSetupEst - d.LaborSetup END AS 'Remaining Labor Setup Time'
	, s.LaborTypeID AS 'Labor Run Type ID', (s.LaborEst) AS 'Est Labor Run Time'
	, CASE WHEN d.Labor IS NULL THEN s.LaborEst ELSE s.LaborEst - d.Labor END AS 'Remaining Labor Run Time'
	, s.MachineGroupID, s.MachineSetupEst AS 'Est Machine Setup Time'
	, CASE WHEN d.MachineSetup IS NULL THEN s.MachineSetupEst ELSE s.MachineSetupEst - d.MachineSetup END AS 'Remaining Machine Setup Time'
	, s.MachineRunEst AS 'Est Machine Run Time'
	, CASE WHEN d.MachineRun IS NULL THEN s.MachineRunEst ELSE s.MachineRunEst - d.MachineRun END AS 'Remaining Machine Run Time'
	, s.QtyProducedEst AS 'Est Qty Produced', s.QtyScrappedEst AS 'Est Qty Scrapped' 
FROM dbo.tblMpTimeSum s 
	LEFT JOIN 
			(
				SELECT TransId, SUM(CASE WHEN LaborIn = '60' THEN Labor ELSE Labor * 60 END) AS Labor
					, SUM(CASE WHEN LaborSetupIn = '60' THEN LaborSetup ELSE LaborSetup * 60 END) AS LaborSetup
					, SUM(CASE WHEN MachineSetupIn = '60' THEN MachineSetup ELSE MachineSetup * 60 END) AS MachineSetup
					, SUM(CASE WHEN MachineRunIn = '60' THEN MachineRun ELSE MachineRun * 60 END) AS MachineRun 
				FROM dbo.tblMpTimeDtl 
				GROUP BY TransId
			) d 
		ON d.TransId = s.TransId 
	INNER JOIN dbo.tblMpRequirements r ON s.TransId = r.TransId 
	INNER JOIN dbo.tblMpOrderReleases o ON o.Id = r.ReleaseId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtMpWorkRemaining';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtMpWorkRemaining';

