
CREATE PROCEDURE dbo.[trav_SvServiceOrderPost_GenerateHistory_proc]
AS
BEGIN TRY

	DECLARE @PostDtlYn bit, @PostRun pPostRun, @SourceCode nvarchar(2), @CurrBase pCurrency, @WrkStnDate datetime, @CompId nvarchar(3)
	DECLARE @CountPosted int,@ActivityStatusEnable bit 


	--Retrieve global values
	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @SourceCode = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'SourceCode'
	SELECT @PostDtlYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PostDtlYn'
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @CompId = Cast([Value] AS nvarchar(3)) FROM #GlobalValues WHERE [Key] = 'CompId'
	SELECT @ActivityStatusEnable = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ActivityStatusEnable'

	IF EXISTS(SELECT * FROM #CompletedServiceOrdertable)
	BEGIN

		INSERT INTO dbo.tblSvHistoryWorkOrder(ID, PostRun, WorkOrderNo, OrderDate, CustID, SiteID, Attention, Address1, Address2, City, Region, Country, PostalCode
		, TerrId, Phone1, Phone2, Phone3, Email, Internet, Rep1Id, Rep1Pct, Rep2Id, Rep2Pct, Rep1CommRate, Rep2CommRate, BillingType, BillableYN, CustomerPoNumber, PODate
		, OriginalWorkOrder, BillByWorkOrder, FixedPrice, BillingFormat, ProjectID, PhaseID, TaskID,CF,ProjectCustID,BillVia )
		SELECT w.ID,@PostRun, w.WorkOrderNo, w.OrderDate, w.CustID, w.SiteID, w.Attention, w.Address1, w.Address2, w.City, w.Region, w.Country, w.PostalCode
		, w.TerrId, w.Phone1, w.Phone2, w.Phone3, w.Email, w.Internet, w.Rep1Id, w.Rep1Pct, w.Rep2Id, w.Rep2Pct, w.Rep1CommRate, w.Rep2CommRate, w.BillingType, 0, w.CustomerPoNumber, w.PODate
		, w.OriginalWorkOrder, w.BillByWorkOrder, w.FixedPrice, w.BillingFormat, p.ProjectName, pd.PhaseId, pd.TaskId, w.CF, p.CustId, w.BillVia
		FROM  #CompletedServiceOrdertable t INNER JOIN dbo.tblSvWorkOrder w ON t.WorkOrderID = w.ID
			LEFT JOIN dbo.tblPcProjectDetail pd ON w.ProjectDetailID = pd.Id
			LEFT JOIN dbo.tblPcProject p ON pd.ProjectId = p.Id

		INSERT INTO dbo.tblSvHistoryWorkOrderDispatch (ID, WorkOrderID, DispatchNo, Description, EquipmentID, EquipmentDescription, BillingType, BillableYN
		, BillToID, RequestedDate, RequestedAMPM, RequestedTechID, CancelledYN, EstTravel, SchedApproved, EntryDate, Counter, LocID, SourceId, PostRun,[Priority],CF,StatusID ,StatusDescription) 
		SELECT d.ID, d.WorkOrderID, d.DispatchNo, d.Description,  d.EquipmentID, d.EquipmentDescription, d.BillingType,0
		, d.BillToID, d.RequestedDate, d.RequestedAMPM, d.RequestedTechID, d.CancelledYN,  d.EstTravel, d.SchedApproved, d.EntryDate, d.Counter, d.LocID, d.SourceId, d.PostRun,d.[Priority],d.CF, d.StatusID ,CASE WHEN @ActivityStatusEnable =1 THEN s.[Description] ELSE NULL END
		FROM  #CompletedServiceOrdertable t INNER JOIN dbo.tblSvWorkOrderDispatch d ON t.WorkOrderID = d.WorkOrderID
		LEFT JOIN dbo.tblSvActivityStatus s ON d.StatusID = s.ID
		
		--append DispatchCoverage
		INSERT INTO tblSvHistoryWorkOrderDispatchCoverage ([ID] ,[DispatchID] ,[CoveredByType] ,[CoveredById],[Description],[CoverageType],[BillingType]
															,[StartDate],[EndDate],[ContractNo] ,[CF])
		SELECT dc.[ID] ,dc.[DispatchID] ,dc.[CoveredByType] ,dc.[CoveredById], w.[Descr] , w.[CoverageType] , w.[BillingTypeDflt]  BillingType
				, w.[StartDate], w.[EndDate], NULL ,dc.[CF]
		FROM 	tblSvWorkOrderDispatchCoverage dc
		INNER JOIN  tblSvWorkOrderDispatch d ON dc.DispatchID = d.ID 
		INNER JOIN   #CompletedServiceOrdertable c ON c.WorkOrderID = d.WorkOrderID
		LEFT JOIN tblSvEquipmentWarranty w ON dc.CoveredById = w.ID AND dc.CoveredByType =0



		INSERT INTO tblSvHistoryWorkOrderDispatchWorkToDo ([DispatchID],[WorkOrderID],[WorkToDoID],[GroupID],[Description],[EstimatedTime],[SkillLevel],[CF])
		SELECT t.[DispatchID], t.[WorkOrderID],t.[WorkToDoID],t.[GroupID],t.[Description],t.[EstimatedTime],t.[SkillLevel],t.[CF]
		FROM tblSvWorkOrderDispatchWorkToDo t
		INNER JOIN  #CompletedServiceOrdertable c ON t.WorkOrderID = c.WorkOrderID

		INSERT INTO dbo.tblSvHistoryWorkOrderActivity (DispatchID, WorkOrderID, ActivityType, ActivityDateTime, TechID, EntryDate, EnteredBy, Duration,Notes,CF, StatusDescription)
		SELECT a.DispatchID, a.WorkOrderID, a.ActivityType, a.ActivityDateTime, a.TechID, a.EntryDate, a.EnteredBy, a.Duration,a.Notes,a.CF,CASE WHEN @ActivityStatusEnable =1 THEN s.[Description] ELSE NULL END
		FROM #CompletedServiceOrdertable t INNER JOIN dbo.tblSvWorkOrderActivity a ON t.WorkOrderID = a.WorkOrderID 
		LEFT JOIN dbo.tblSvActivityStatus s ON a.ActivityType = s.ID

		INSERT INTO tblSvHistoryWorkOrderTrans (ID, DispatchID, WorkOrderID, TransType, ResourceID, LaborCode, Description, LocID, EntryDate, TransDate
		, FiscalYear, FiscalPeriod, AdditionalDescription, QtyEstimated, QtyUsed, Unit, UnitCost, UnitPrice, CostExt, PriceExt, TaxClass, GLAcctCredit
		, GLAcctDebit, GLAcctSales, HistSeqNum, QtySeqNum_Cmtd, QtySeqNum, LinkSeqNum, EntryNum,CF)
		SELECT tr.ID, tr.DispatchID, tr.WorkOrderID, tr.TransType, tr.ResourceID, tr.LaborCode, tr.Description, tr.LocID, tr.EntryDate, tr.TransDate
		, tr.FiscalYear, tr.FiscalPeriod, tr.AdditionalDescription, tr.QtyEstimated, tr.QtyUsed, tr.Unit, tr.UnitCost, tr.UnitPrice, tr.CostExt, tr.PriceExt, tr.TaxClass, tr.GLAcctCredit
		, tr.GLAcctDebit, tr.GLAcctSales, tr.HistSeqNum, tr.QtySeqNum_Cmtd, tr.QtySeqNum, tr.LinkSeqNum, tr.EntryNum,CF
		FROM #CompletedServiceOrdertable t INNER JOIN dbo.tblSvWorkOrderTrans tr ON t.WorkOrderID = tr.WorkOrderID

		INSERT INTO tblSvHistoryWorkOrderTransExt ( TransID, LotNum, ExtLocA, ExtLocB, QtyEstimated, QtyUsed, UnitCost, HistSeqNum, QtySeqNum_Cmtd, QtySeqNum_Ext, QtySeqNum, Cmnt,CF)
		SELECT te.TransID, te.LotNum, te.ExtLocA, te.ExtLocB, te.QtyEstimated, te.QtyUsed, te.UnitCost, te.HistSeqNum, te.QtySeqNum_Cmtd, te.QtySeqNum_Ext, te.QtySeqNum, te.Cmnt,te.CF
		FROM #CompletedServiceOrdertable t INNER JOIN dbo.tblSvWorkOrderTrans tr ON t.WorkOrderID = tr.WorkOrderID
			INNER JOIN dbo.tblSvWorkOrderTransExt te on tr.ID = te.TransID

		INSERT INTO tblSvHistoryWorkOrderTransSer(TransID, SerNum, LotNum, ExtLocA, ExtLocB, UnitCost, UnitCostACV, UnitPrice, HistSeqNum, Cmnt,CF)
		SELECT ts.TransID, ts.SerNum, ts.LotNum, ts.ExtLocA, ts.ExtLocB, ts.UnitCost, ts.UnitCostACV, ts.UnitPrice, ts.HistSeqNum, ts.Cmnt,ts.CF
		FROM  #CompletedServiceOrdertable t INNER JOIN dbo.tblSvWorkOrderTrans tr ON t.WorkOrderID = tr.WorkOrderID
			INNER JOIN dbo.tblSvWorkOrderTransSer ts ON tr.ID = ts.TransID
		
	END
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvServiceOrderPost_GenerateHistory_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvServiceOrderPost_GenerateHistory_proc';

