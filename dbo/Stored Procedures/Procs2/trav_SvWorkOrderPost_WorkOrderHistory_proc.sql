
CREATE PROCEDURE dbo.trav_SvWorkOrderPost_WorkOrderHistory_proc
AS
BEGIN TRY

	DECLARE @PostRun pPostRun ,@ActivityStatusEnable bit 

	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @ActivityStatusEnable = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ActivityStatusEnable'

	IF @PostRun IS NULL 
	BEGIN
		RAISERROR(90025,16,1)
	END

	--append WorkOrders
	INSERT INTO tblSvHistoryWorkOrder ([PostRun],ID, [WorkOrderNo], [OrderDate],[CustID],[SiteID],[Attention],[Address1] ,[Address2],[City]
      ,[Region],[Country],[PostalCode],[TerrId] ,[Phone1],[Phone2],[Phone3],[Email],[Internet],[Rep1Id],[Rep1Pct],[Rep2Id],[Rep2Pct],
	  [Rep1CommRate] ,[Rep2CommRate],[BillingType],[BillableYN] ,[CustomerPoNumber],[PODate],[OriginalWorkOrder],[BillByWorkOrder]
      ,[FixedPrice],[BillingFormat],[ProjectID],[PhaseID] ,[TaskID],[BillVia],[ProjectCustID], [CF] ) 

	SELECT @PostRun,wo.[ID], [WorkOrderNo], wo.[OrderDate],wo.[CustID],[SiteID],[Attention],[Address1] ,[Address2],[City]
      ,[Region],[Country],[PostalCode],[TerrId] ,[Phone1],[Phone2],[Phone3],[Email],[Internet],wo.[Rep1Id], wo.[Rep1Pct],wo.[Rep2Id],wo.[Rep2Pct]
	  ,wo.[Rep1CommRate] ,wo.[Rep2CommRate],wo.[BillingType],ISNULL(b.[BillableYN],0),[CustomerPoNumber],[PODate],[OriginalWorkOrder],[BillByWorkOrder]
      ,[FixedPrice],[BillingFormat],p.ProjectName [ProjectID],d.[PhaseId] ,d.[TaskID],wo.BillVia,p.CustId, wo.[CF] 
	FROM (tblSvWorkOrder wo
	INNER JOIN  #CompletedWorkorder c ON wo.ID = c.WorkOrderID)
	LEFT JOIN tblSvBillingType b ON wo.BillingType =b.BillingType
	LEFT JOIN tblPcProjectDetail d ON wo.ProjectDetailID = d.Id
	LEFT JOIN tblPcProject p ON d.ProjectId = p.Id

	--append Dispatch
	INSERT INTO tblSvHistoryWorkOrderDispatch ([ID],[WorkOrderID],[DispatchNo],[Description],[EquipmentID],[EquipmentDescription],
	[BillingType],[BillableYN],[BillToID],[RequestedDate] ,[RequestedAMPM],[RequestedTechID],[CancelledYN],[EstTravel],[SchedApproved]
	,[EntryDate],[Counter],[LocID],[SourceId],[PostRun],[Priority],[CF],StatusDescription,StatusID)
	
	SELECT w.ID, w.[WorkOrderID],[DispatchNo],w.[Description],[EquipmentID],[EquipmentDescription],
	w.[BillingType],[BillableYN], [BillToID],[RequestedDate] ,[RequestedAMPM],[RequestedTechID],[CancelledYN],[EstTravel],[SchedApproved]
	,[EntryDate],[Counter],[LocID],[SourceId],PostRun,w.[Priority],w.[CF], CASE WHEN @ActivityStatusEnable =1 THEN s.[Description] ELSE NULL END,w.StatusID
	FROM tblSvWorkOrderDispatch w
	LEFT JOIN tblSvBillingType b ON w.BillingType =b.BillingType
	LEFT JOIN dbo.tblSvActivityStatus s ON w.StatusID = s.ID
	INNER JOIN  #CompletedWorkorder c ON w.WorkOrderID = c.WorkOrderID
	
	--append DispatchCoverage

	INSERT INTO tblSvHistoryWorkOrderDispatchCoverage ([ID] ,[DispatchID] ,[CoveredByType] ,[CoveredById],[Description],[CoverageType]
																,[BillingType],[StartDate],[EndDate],[ContractNo] ,[CF])
    SELECT dc.[ID] ,dc.[DispatchID] ,dc.[CoveredByType] ,dc.[CoveredById],CASE WHEN dc.[CoveredByType] =0 THEN w.[Descr] ELSE h.[Description] END
	,CASE WHEN dc.[CoveredByType] =0 THEN w.[CoverageType] ELSE det.CoverageType END CoverageType, CASE WHEN dc.[CoveredByType] =0 THEN w.[BillingTypeDflt] ELSE h.BillingTypeDflt END BillingType
																,CASE WHEN dc.[CoveredByType] =0 THEN w.[StartDate] ELSE h.[StartDate] END,CASE WHEN dc.[CoveredByType] =0 THEN w.[EndDate] ELSE h.[EndDate] END,
																CASE WHEN dc.[CoveredByType] =0 THEN NULL ELSE h.[ContractNo] END ContractNo ,dc.[CF]
	FROM 	tblSvWorkOrderDispatchCoverage dc
	INNER JOIN  tblSvWorkOrderDispatch d ON dc.DispatchID = d.ID 
	INNER JOIN  #CompletedWorkorder c ON c.WorkOrderID = d.WorkOrderID
	LEFT JOIN tblSvEquipmentWarranty w ON dc.CoveredById = w.ID AND dc.CoveredByType =0
	LEFT JOIN tblSvServiceContractDetail det on det.ID = dc.CoveredById AND dc.CoveredByType =1
	LEFT JOIN tblSvServiceContractHeader h	on det.ContractID =h.ID 



	--append WorkToDo
	INSERT INTO tblSvHistoryWorkOrderDispatchWorkToDo ([DispatchID],[WorkOrderID],[WorkToDoID],[GroupID],[Description],[EstimatedTime]
      ,[SkillLevel] ,[CF])

	SELECT [DispatchID],w.[WorkOrderID],[WorkToDoID],[GroupID],[Description],[EstimatedTime]  ,[SkillLevel] ,[CF]
	FROM tblSvWorkOrderDispatchWorkToDo w
	INNER JOIN  #CompletedWorkorder c ON w.WorkOrderID = c.WorkOrderID

	--append Activity
	INSERT INTO tblSvHistoryWorkOrderActivity ( [DispatchID],[WorkOrderID],[ActivityType],[ActivityDateTime],[TechID],[Duration], [EntryDate],[EnteredBy],[Notes],[CF],StatusDescription)

	SELECT [DispatchID],wa.[WorkOrderID],[ActivityType],[ActivityDateTime],[TechID],[Duration], [EntryDate],[EnteredBy],[Notes],wa.[CF], CASE WHEN @ActivityStatusEnable =1 THEN s.[Description] ELSE NULL END
	FROM tblSvWorkOrderActivity wa
	INNER JOIN  #CompletedWorkorder c ON wa.WorkOrderID = c.WorkOrderID
	LEFT JOIN dbo.tblSvActivityStatus s ON wa.ActivityType = s.ID

	--append  Referrel
	INSERT INTO tblSvHistoryWorkOrderReferral([ID],[CustID],[CompanyName] ,[ContactName] ,[Address1],[Address2] ,[City],[Region],[Country] ,[PostalCode],[Phone]
		,[Fax],[Email] ,[Internet] ,[Notes],[CF])

	SELECT r.[ID],[CustID],[CompanyName] ,[ContactName] ,[Address1],[Address2] ,[City],[Region],[Country] ,[PostalCode],[Phone]
		,[Fax],[Email] ,[Internet] ,[Notes],r.[CF]
	FROM tblSvWorkOrderReferral r
	INNER JOIN  #CompletedWorkorder c ON r.ID = c.WorkOrderID


	--append Work Order Transactions

	INSERT INTO tblSvHistoryWorkOrderTrans ([ID],[DispatchID],[WorkOrderID],[TransType],[ResourceID],[LaborCode],[Description],[LocID],[EntryDate] 
		,[TransDate],[FiscalYear],[FiscalPeriod],[AdditionalDescription],[QtyEstimated] ,[QtyUsed],[Unit],[UnitCost],[UnitPrice],[CostExt]
		,[PriceExt],[TaxClass],[GLAcctCredit],[GLAcctDebit],[GLAcctSales],[HistSeqNum] ,[QtySeqNum_Cmtd],[QtySeqNum],[LinkSeqNum],[EntryNum],[CF])

	SELECT [ID],[DispatchID],wt.[WorkOrderID],[TransType],[ResourceID],[LaborCode],[Description],[LocID],[EntryDate] 
		,[TransDate],[FiscalYear],[FiscalPeriod],[AdditionalDescription],[QtyEstimated] ,[QtyUsed],[Unit],[UnitCost],[UnitPrice],[CostExt]
		,[PriceExt],[TaxClass],[GLAcctCredit],[GLAcctDebit],[GLAcctSales],[HistSeqNum] ,[QtySeqNum_Cmtd],[QtySeqNum],[LinkSeqNum],[EntryNum],[CF]
	FROM tblSvWorkOrderTrans wt
	INNER JOIN  #CompletedWorkorder c ON wt.WorkOrderID = c.WorkOrderID


	INSERT INTO tblSvHistoryWorkOrderTransExt ([TransID] ,[LotNum],[ExtLocA],[ExtLocB],[QtyEstimated],[QtyUsed] ,[UnitCost],[HistSeqNum]
		,[QtySeqNum_Cmtd],[QtySeqNum_Ext],[QtySeqNum],[Cmnt],[CF])

	SELECT [TransID] ,[LotNum],[ExtLocA],[ExtLocB],e.[QtyEstimated],e.[QtyUsed] ,e.[UnitCost],e.[HistSeqNum]
		,e.[QtySeqNum_Cmtd],e.[QtySeqNum_Ext],e.[QtySeqNum],[Cmnt],e.[CF]
	FROM tblSvWorkOrderTransExt e
	INNER JOIN tblSvWorkOrderTrans wt ON e.TransID = wt.ID
	INNER JOIN  #CompletedWorkorder c ON wt.WorkOrderID = c.WorkOrderID


	INSERT INTO tblSvHistoryWorkOrderTransSer ([TransID],[SerNum] ,[LotNum] ,[ExtLocA],[ExtLocB],[UnitCost]
      ,[UnitCostACV],[UnitPrice] ,[HistSeqNum] ,[Cmnt], [CF])
	 
	SELECT [TransID],[SerNum] ,[LotNum] ,[ExtLocA],[ExtLocB],s.[UnitCost]
      ,[UnitCostACV],s.[UnitPrice] ,s.[HistSeqNum] ,[Cmnt], s.[CF]
	FROM tblSvWorkOrderTransSer s
	INNER JOIN tblSvWorkOrderTrans wt ON s.TransID = wt.ID
	INNER JOIN  #CompletedWorkorder c ON wt.WorkOrderID = c.WorkOrderID

	



END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvWorkOrderPost_WorkOrderHistory_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvWorkOrderPost_WorkOrderHistory_proc';

