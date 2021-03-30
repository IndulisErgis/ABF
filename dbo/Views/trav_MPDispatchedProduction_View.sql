
CREATE VIEW [dbo].[trav_MPDispatchedProduction_View]
AS

Select 3 as [TimeType], LaborTypeId as Resource, LSeqNo as [SeqNo], o.OrderNo, r.ReleaseNo, req.ReqId, QtyProducedEst as [EstQty], 
QtyScrappedEst as [EstScrap], LeadTime, OperationId, CustId as Customer, o.AssemblyID as [FinishedGood], LaborSetupEst as [SetupTime], LaborEst as [RunTime], 
s.TransId, RequiredDate from tblMpTimeSum s
LEFT JOIN tblMpRequirements  req ON req.TransId  = s.TransId
Left Join tblMpOrderReleases r on req.ReleaseId = r.Id 
Left Join tblMpOrder o on o.OrderNo=r.OrderNo
UNION
Select 2 as [TimeType], MachineGroupId as Resource, MSeqNo as [SeqNo],o.OrderNo, r.ReleaseNo, req.ReqId, QtyProducedEst as [EstQty], 
QtyScrappedEst as [EstScrap], LeadTime, OperationId, CustId as Customer, o.AssemblyID as [FinishedGood], MachineSetupEst as [SetupTime], MachineRunEst as [RunTime], 
s.TransId, RequiredDate from tblMpTimeSum s
LEFT JOIN tblMpRequirements  req ON req.TransId  = s.TransId
Left Join tblMpOrderReleases r on req.ReleaseId = r.Id 
Left Join tblMpOrder o on o.OrderNo=r.OrderNo
UNION
Select 1 as [TimeType], WorkCenterId as Resource, WSeqNo as [SeqNo], o.OrderNo as [Order],r.ReleaseNo, req.ReqId, QtyProducedEst as [EstQty], 
QtyScrappedEst as [EstScrap], LeadTime, OperationId as [OperationID], CustId as [CustomerID], o.AssemblyId as [FinishedGood], MachineSetupEst as [SetupTime], MachineRunEst as [RunTime], 
s.TransId, RequiredDate from tblMpTimeSum s
LEFT JOIN tblMpRequirements  req ON req.TransId  = s.TransId
Left Join tblMpOrderReleases r on req.ReleaseId = r.Id 
Left Join tblMpOrder o on o.OrderNo=r.OrderNo
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_MPDispatchedProduction_View';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_MPDispatchedProduction_View';

