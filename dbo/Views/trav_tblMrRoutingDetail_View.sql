CREATE VIEW [dbo].[trav_tblMrRoutingDetail_View]
AS
SELECT t.[BillMethod]
, t.[BillRate]
, t.[Descr]
, t.[Id]
, t.[LaborRate]
, t.[LaborRunTime]
, t.[LaborRunTimeIn]
, t.[LaborSetup]
, t.[LaborSetupIn]
, t.[LaborTypeID]
, t.[MachineGroupID]
, t.[MachineRate]
, t.[MachRunTime]
, t.[MachRunTimeIn]
, t.[MachSetup]
, t.[MachSetupIn]
, t.[MGID]
, t.[MoveTime]
, t.[MoveTimeIn]
, t.[Notes]
, t.[OperationID]
, t.[OverlapFactor]
, t.[OverlapYn]
, t.[QueueTime]
, t.[QueueTimeIn]
, t.[ReqEmployees]
, t.[RoutingId]
, t.[RtgUserDef01]
, t.[RtgUserDef02]
, t.[SeqNo]
, t.[SetupLaborTypeID]
, t.[Step]
, t.[WaitTime]
, t.[WaitTimeIn]
, t.[WorkCenterID]
, e.[cf_Routing 1]
, e.[cf_Routing 2]
 FROM dbo.[tblMrRoutingDetail] t
 LEFT JOIN
 ( SELECT pvt.[Id]
	, Cast(pvt.[Routing 1] As nvarchar(50)) AS [cf_Routing 1]
	, Cast(pvt.[Routing 2] As float) AS [cf_Routing 2]
	 FROM
		 ( SELECT t.[Id], [Name], [Value]
		 FROM
			 ( SELECT t.[Id]
			 , e.props.value('./Name[1]', 'NVARCHAR(max)') as [Name]
			 , e.props.value('./Value[1]', 'NVARCHAR(max)') as [Value]
			 FROM dbo.[tblMrRoutingDetail] t
			 CROSS APPLY t.CF.nodes('/ArrayOfEntityPropertyOfString/EntityPropertyOfString') as e(props)
			 WHERE (e.props.exist('Name') = 1) AND (e.props.exist('Value') = 1)
		 ) t
	 ) tmp
	 PIVOT (Max([Value]) FOR [Name] IN ([Routing 1], [Routing 2])) AS pvt
) e on  t.[Id] = e.[Id]