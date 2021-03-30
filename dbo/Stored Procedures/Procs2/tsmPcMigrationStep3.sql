
CREATE PROCEDURE [dbo].[tsmPcMigrationStep3]

AS
BEGIN TRY
SET NOCOUNT ON
--Pre-migration requirements
--Post AP project transactions
--Post AR project transactions
--Post IN material requisition project transctions
--check default credit account
--check duplicate customer id and project id including archived projects

--Post-migration
--Prepare overhead allocations if prepared overhead allocations exists in 10.5
--Go to PC Transaction to update link if PO project line items are migrated.

--tblJcBatch to tblSmBatch,todo report status
INSERT INTO dbo.tblSmBatch (FunctionId, BatchId, Descr, CreateDate, [Permanent])
SELECT 'PCTRANS', c.[BatchID], c.[Desc], c.BatchDate, c.StaticYN
FROM dbo.tblJcBatch c LEFT JOIN (SELECT BatchId FROM dbo.tblSmBatch WHERE FunctionId = 'PCTRANS') b on c.BatchId = b.BatchId
WHERE b.BatchId is null

--tblJcBatch to tblSmBatch
if exists(select * from sys.tables t where t.name = 'tblJcBatch')
begin
	EXEC ('INSERT INTO dbo.tblSmBatch (FunctionId, BatchId, Descr, CreateDate, [Permanent])
		SELECT ''PCTRANS'', c.[BatchID], c.[Desc], c.BatchDate, c.StaticYN
		FROM dbo.tblJcBatch c 
		LEFT JOIN (SELECT BatchId FROM dbo.tblSmBatch WHERE FunctionId = ''PCTRANS'') b on c.BatchId = b.BatchId
		WHERE b.BatchId is null'
	)

	EXEC ('INSERT INTO dbo.tblSmBatch (FunctionId, BatchId, Descr, CreateDate, [Permanent])
		SELECT ''PCBilling'', c.[BatchID], c.[Desc], c.BatchDate, c.StaticYN
		FROM dbo.tblJcBatch c 
		LEFT JOIN (SELECT BatchId FROM dbo.tblSmBatch WHERE FunctionId = ''PCBilling'') b on c.BatchId = b.BatchId
		WHERE b.BatchId is null'
	)
end

IF NOT EXISTS(SELECT * FROM dbo.tblSmBatch WHERE FunctionId = 'PCTRANS' AND BatchId = '######')
BEGIN
	INSERT INTO dbo.tblSmBatch (FunctionId, BatchId, Descr, CreateDate, [Permanent])
	VALUES ('PCTRANS', '######', 'Default Batch', GetDate(), 1)
END

IF NOT EXISTS(SELECT * FROM dbo.tblSmBatch WHERE FunctionId = 'PCBilling' AND BatchId = '######')
BEGIN
	INSERT INTO dbo.tblSmBatch (FunctionId, BatchId, Descr, CreateDate, [Permanent])
	VALUES ('PCBilling', '######', 'Default Batch', GetDate(), 1)
END

DELETE dbo.tblSmAttachment WHERE LinkType = 'PCPROJECT'

--Truncate tables first
TRUNCATE TABLE dbo.tblPcActivity
TRUNCATE TABLE dbo.tblPcAdjustment
TRUNCATE TABLE dbo.tblPcDistCode
TRUNCATE TABLE dbo.tblPcEmpRates
TRUNCATE TABLE dbo.tblPcEstimate
TRUNCATE TABLE dbo.tblPcOhAlloc
TRUNCATE TABLE dbo.tblPcPhase
TRUNCATE TABLE dbo.tblPcPrepareOverhead
TRUNCATE TABLE dbo.tblPcProject
TRUNCATE TABLE dbo.tblPcProjectDetail
TRUNCATE TABLE dbo.tblPcRates
TRUNCATE TABLE dbo.tblPcTask
TRUNCATE TABLE dbo.tblPcTimeTicket
TRUNCATE TABLE dbo.tblPcTrans

--tblJcDistCode to tblPcDistCode
INSERT INTO dbo.tblPcDistCode(DistCode, [Description], GLAcctWIP, GLAcctPayrollClearing, GLAcctIncome, GLAcctCost, GLAcctAdjustments, GLAcctFixedFeeBilling, GLAcctOverheadContra, GLAcctAccruedIncome)
SELECT DistCode, [Desc], WIPGLAcct, AccruedGLAcct, SalesGLAcct, COSGLAcct, AdjustGLAcct, DeferredGLAcct, OverHeadGLAcct, SalesGLAcct 
FROM dbo.tblJcDistCode 
WHERE DistCode NOT IN (SELECT DistCode FROM dbo.tblPcDistCode)

--tblJcPhases to tblPcPhase
INSERT INTO dbo.tblPcPhase(PhaseId, [Description])
SELECT PhaseId, PhaseName
FROM dbo.tblJcPhases
WHERE PhaseId NOT IN (SELECT PhaseId FROM dbo.tblPcPhase)

--tblJcTasks to tblPcTask
INSERT INTO dbo.tblPcTask(TaskId, [Description])
SELECT TaskId, TaskName
FROM dbo.tblJcTasks
WHERE TaskId NOT IN (SELECT TaskId FROM dbo.tblPcTask)

--tblJcRates to tblPcRates
INSERT INTO dbo.tblPcRates(RateId, [Description])
SELECT RateId, [Description]
FROM dbo.tblJcRates
WHERE RateId NOT IN (SELECT RateId FROM dbo.tblPcRates)

--tblJcOhAlloc to tblPcOhAlloc
INSERT INTO dbo.tblPcOhAlloc(OhAllCode, [Description], [Hours], [Time], Material, Expense, Other)
SELECT OhAllCode, [Desc], [Hours], [Time], Material, Material, Material
FROM dbo.tblJcOhAlloc
WHERE OhAllCode NOT IN (SELECT OhAllCode FROM dbo.tblPcOhAlloc)

--tblJCEmpRates to tblPcEmpRates
INSERT INTO dbo.tblPcEmpRates(EmpId, RateId, Rate, Cost, EarnCode, DefaultYN)
SELECT j.EmpId, RTRIM(j.RateId), j.Rate, j.Cost, j.EarnCode, j.DefaultYN 
FROM dbo.tblJCEmpRates j LEFT JOIN dbo.tblPcEmpRates p ON j.EmpId = p.EmpId AND j.RateId = p.RateId 
WHERE p.EmpId IS NULL

--tblJcProject to tblPcProject, tblPcProjectDetail, tblPcEstimate
--PrintOption needs to be manually set.
INSERT INTO dbo.tblPcProject(ProjectName, CustId, [Type])
SELECT j.ProjId, j.CustId, 
CASE j.[Status] WHEN 0 THEN 2 WHEN 2 THEN 1 ELSE 0 END
FROM dbo.tblJcProject j LEFT JOIN dbo.tblPcProject p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName 
WHERE p.ProjectName IS NULL

INSERT INTO dbo.tblPcProjectDetail(ProjectId, PhaseId, TaskId, [Description], [Status], BillOnHold, Speculative, Billable, FixedFee, FixedFeeAmt, 
	EstStartDate, EstEndDate, ActStartDate, ActEndDate, DistCode, OhAllCode, TaxClass, MaterialMarkup, OverrideRate, AddnlDesc, LastDateBilled, RateId,
	ExpenseMarkup,OtherMarkup,Rep1Id,Rep2Id,Rep1Pct,Rep2Pct,Rep1CommRate,Rep2CommRate)
SELECT p.Id, NULL, NULL, j.ProjName, CASE ClosedYn WHEN 1 THEN 2 ELSE 0 END [Status], HoldYn, CASE j.Status WHEN 4 THEN 1 ELSE 0 END Speculative,
	CASE WHEN j.Status IN (1,2,4)  THEN 1  ELSE 0 END Billable, j.FixedFee, CASE WHEN j.FeetoPhaseYn = 0 THEN j.FixedFeeAmt ELSE 0 END, j.EstStartDate, j.EstEndDate, j.ActStartDate, j.ActEndDate, 
	j.DistCode, j.OhAllCode, j.TaxClass, j.Markup, j.OverrideRate, j.AddnlDesc, j.LastDateBilled, j.Billinglevel, 0, 0, c.SalesRepId1, c.SalesRepId2,
	ISNULL(c.Rep1PctInvc,0), ISNULL(c.Rep2PctInvc,0), ISNULL(r1.CommRate,0), ISNULL(r2.CommRate,0)
FROM dbo.tblJcProject j INNER JOIN dbo.tblPcProject p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName 
	LEFT JOIN dbo.tblPcProjectDetail d ON p.Id = d.ProjectId AND d.PhaseId IS NULL AND d.TaskId IS NULL 
	LEFT JOIN dbo.tblArCust c ON j.CustId = c.CustId 
	LEFT JOIN dbo.tblArSalesRep r1 ON c.SalesRepId1 = r1.SalesRepID 
	LEFT JOIN dbo.tblArSalesRep r2 ON c.SalesRepId2 = r2.SalesRepID
WHERE d.ProjectId IS NULL

INSERT INTO dbo.tblPcEstimate(ProjectDetailId, [Type], ResourceId, LocId, [Description], Qty, Uom, UnitCost, UnitPrice)
SELECT d.Id, 0, NULL, NULL, NULL, CASE j.TimeEstqty WHEN 0 THEN 1 ELSE j.TimeEstqty END AS Qty, 'HOUR', 
	CASE j.TimeEstqty WHEN 0 THEN j.TimeEstamt ELSE ROUND(j.TimeEstamt/j.TimeEstqty,4) END AS UnitCost, 
	CASE j.TimeEstqty WHEN 0 THEN j.EstTimeIncAmt ELSE ROUND(j.EstTimeIncAmt/j.TimeEstqty,4) END AS UnitPrice
FROM dbo.tblJcProject j INNER JOIN dbo.tblPcProject p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName
	INNER JOIN dbo.tblPcProjectDetail d ON p.Id = d.ProjectId
WHERE j.PhaseYn = 0 AND d.PhaseId IS NULL AND d.TaskId IS NULL AND (j.TimeEstamt <> 0 OR j.TimeEstqty <> 0 OR j.EstTimeIncAmt <> 0)--project with no phases

INSERT INTO dbo.tblPcEstimate(ProjectDetailId, [Type], ResourceId, LocId, [Description], Qty, Uom, UnitCost, UnitPrice)
SELECT d.Id, 1, NULL, NULL, NULL, CASE j.MaterEstqty WHEN 0 THEN 1 ELSE j.MaterEstqty END AS Qty, NULL, 
	CASE j.MaterEstqty WHEN 0 THEN j.MaterEstamt ELSE ROUND(j.MaterEstamt/j.MaterEstqty,4) END AS UnitCost, 
	CASE j.MaterEstqty WHEN 0 THEN j.EstMaterIncAmt ELSE ROUND(j.EstMaterIncAmt/j.MaterEstqty,4) END AS UnitPrice
FROM dbo.tblJcProject j INNER JOIN dbo.tblPcProject p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName
	INNER JOIN dbo.tblPcProjectDetail d ON p.Id = d.ProjectId 
	LEFT JOIN dbo.tblJcProjectItem e ON j.CustId = e.CustId AND j.ProjId = e.ProjId
WHERE j.PhaseYn = 0 AND d.PhaseId IS NULL AND d.TaskId IS NULL AND e.TranKey IS NULL AND (j.MaterEstamt <> 0 OR j.MaterEstqty <> 0 OR j.EstMaterIncAmt <> 0)--project with no phases, no detail estimate

--Add phase id to tblPcTask for phases do not use task
INSERT INTO dbo.tblPcTask(TaskId, [Description])
SELECT DISTINCT p.PhaseId, s.PhaseName
FROM dbo.tblJcProjPhase p LEFT JOIN dbo.tblJcPhases s ON p.PhaseId = s.PhaseId
WHERE p.TaskYn = 0 AND p.PhaseId NOT IN (SELECT TaskId FROM dbo.tblPcTask)

--tblJcProjPhase to tblPcProjectDetail and tblPcEstimate, phases do not use task
INSERT INTO dbo.tblPcProjectDetail(ProjectId, PhaseId, TaskId, [Description], [Status], BillOnHold, Speculative, Billable, FixedFee, FixedFeeAmt, 
	EstStartDate, EstEndDate, ActStartDate, ActEndDate, DistCode, OhAllCode, TaxClass, MaterialMarkup, OverrideRate, AddnlDesc, LastDateBilled, RateId)
SELECT p.Id, j.PhaseId, j.PhaseId, j.PhaseName, CASE ClosedYn WHEN 1 THEN 2 ELSE 0 END [Status], HoldYn, CASE j.Status WHEN 4 THEN 1 ELSE 0 END Speculative,
	CASE WHEN j.Status IN (1,2,4)  THEN 1  ELSE 0 END Billable, j.FixedFee, j.FixedFeeAmt, j.EstStartDate, j.EstEndDate, j.ActStartDate, j.ActEndDate, 
	j.DistCode, j.OhAllCode, j.TaxClass, j.Markup, j.OverrideRate, j.AddnlDesc, j.LastDateBilled, j.Billinglevel
FROM dbo.tblJcProjPhase j INNER JOIN dbo.tblPcProject p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName 
	LEFT JOIN dbo.tblPcProjectDetail d ON p.Id = d.ProjectId AND j.PhaseId = d.PhaseId AND j.PhaseId = d.TaskId
WHERE j.TaskYn = 0 AND d.ProjectId IS NULL

INSERT INTO dbo.tblPcEstimate(ProjectDetailId, [Type], ResourceId, LocId, [Description], Qty, Uom, UnitCost, UnitPrice)
SELECT d.Id, 0, NULL, NULL, NULL, CASE j.TimeEstqty WHEN 0 THEN 1 ELSE j.TimeEstqty END AS Qty, 'HOUR', 
	CASE j.TimeEstqty WHEN 0 THEN j.TimeEstamt ELSE ROUND(j.TimeEstamt/j.TimeEstqty,4) END AS UnitCost, 
	CASE j.TimeEstqty WHEN 0 THEN j.EstTimeIncAmt ELSE ROUND(j.EstTimeIncAmt/j.TimeEstqty,4) END AS UnitPrice
FROM dbo.tblJcProjPhase j INNER JOIN dbo.tblPcProject p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName
	INNER JOIN dbo.tblPcProjectDetail d ON p.Id = d.ProjectId AND j.PhaseId = d.PhaseId AND j.PhaseId = d.TaskId
WHERE j.TaskYn = 0 AND (j.TimeEstamt <> 0 OR j.TimeEstqty <> 0 OR j.EstTimeIncAmt <> 0)

INSERT INTO dbo.tblPcEstimate(ProjectDetailId, [Type], ResourceId, LocId, [Description], Qty, Uom, UnitCost, UnitPrice)
SELECT d.Id, 1, NULL, NULL, NULL, CASE j.MaterEstqty WHEN 0 THEN 1 ELSE j.MaterEstqty END AS Qty, NULL, 
	CASE j.MaterEstqty WHEN 0 THEN j.MaterEstamt ELSE ROUND(j.MaterEstamt/j.MaterEstqty,4) END AS UnitCost, 
	CASE j.MaterEstqty WHEN 0 THEN j.EstMaterIncAmt ELSE ROUND(j.EstMaterIncAmt/j.MaterEstqty,4) END AS UnitPrice
FROM dbo.tblJcProjPhase j INNER JOIN dbo.tblPcProject p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName
	INNER JOIN dbo.tblPcProjectDetail d ON p.Id = d.ProjectId AND j.PhaseId = d.PhaseId AND j.PhaseId = d.TaskId
	LEFT JOIN dbo.tblJcProjectItem e ON j.CustId = e.CustId AND j.ProjId = e.ProjId AND j.PhaseId = e.PhaseId
WHERE j.TaskYn = 0 AND e.TranKey IS NULL AND (j.MaterEstamt <> 0 OR j.MaterEstqty <> 0 OR j.EstMaterIncAmt <> 0) --No detail estimate

--tblJcProjTask to tblPcProjectDetail and tblPcEstimate
INSERT INTO dbo.tblPcProjectDetail(ProjectId, PhaseId, TaskId, [Description], [Status], BillOnHold, Speculative, Billable, FixedFee, FixedFeeAmt, 
	EstStartDate, EstEndDate, ActStartDate, ActEndDate, DistCode, OhAllCode, TaxClass, MaterialMarkup, OverrideRate, AddnlDesc, LastDateBilled, RateId)
SELECT TOP 1 p.Id, j.PhaseId, j.TaskId, j.TaskName, CASE j.ClosedYn WHEN 1 THEN 2 ELSE 0 END [Status], HoldYn, CASE j.Status WHEN 4 THEN 1 ELSE 0 END Speculative,
	CASE WHEN j.Status IN (1,2,4)  THEN 1  ELSE 0 END Billable, s.FixedFee, s.FixedFeeAmt, j.EstStartDate, j.EstEndDate, j.ActStartDate, j.ActEndDate, 
	j.DistCode, j.OhAllCode, s.TaxClass, j.Markup, j.OverrideRate, j.AddnlDesc, j.LastDateBilled, j.Billinglevel
FROM dbo.tblJcProjTask j INNER JOIN dbo.tblPcProject p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName 
	INNER JOIN dbo.tblJcProjPhase s ON j.CustId = s.CustId AND j.ProjId = s.ProjId AND j.PhaseId = s.PhaseId 
	LEFT JOIN dbo.tblPcProjectDetail d ON p.Id = d.ProjectId AND j.PhaseId = d.PhaseId AND j.TaskId = d.TaskId
WHERE d.ProjectId IS NULL

INSERT INTO dbo.tblPcProjectDetail(ProjectId, PhaseId, TaskId, [Description], [Status], BillOnHold, Speculative, Billable, FixedFee, FixedFeeAmt, 
	EstStartDate, EstEndDate, ActStartDate, ActEndDate, DistCode, OhAllCode, TaxClass, MaterialMarkup, OverrideRate, AddnlDesc, LastDateBilled, RateId)
SELECT p.Id, j.PhaseId, j.TaskId, j.TaskName, CASE j.ClosedYn WHEN 1 THEN 2 ELSE 0 END [Status], HoldYn, CASE j.Status WHEN 4 THEN 1 ELSE 0 END Speculative,
	CASE WHEN j.Status IN (1,2,4)  THEN 1  ELSE 0 END Billable, s.FixedFee, 0, j.EstStartDate, j.EstEndDate, j.ActStartDate, j.ActEndDate, 
	j.DistCode, j.OhAllCode, s.TaxClass, j.Markup, j.OverrideRate, j.AddnlDesc, j.LastDateBilled, j.Billinglevel
FROM dbo.tblJcProjTask j INNER JOIN dbo.tblPcProject p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName 
	INNER JOIN dbo.tblJcProjPhase s ON j.CustId = s.CustId AND j.ProjId = s.ProjId AND j.PhaseId = s.PhaseId 
	LEFT JOIN dbo.tblPcProjectDetail d ON p.Id = d.ProjectId AND j.PhaseId = d.PhaseId AND j.TaskId = d.TaskId
WHERE d.ProjectId IS NULL

INSERT INTO dbo.tblPcEstimate(ProjectDetailId, [Type], ResourceId, LocId, [Description], Qty, Uom, UnitCost, UnitPrice)
SELECT d.Id, 0, NULL, NULL, NULL, CASE j.TimeEstqty WHEN 0 THEN 1 ELSE j.TimeEstqty END AS Qty, 'HOUR', 
	CASE j.TimeEstqty WHEN 0 THEN j.TimeEstamt ELSE ROUND(j.TimeEstamt/j.TimeEstqty,4) END AS UnitCost, 
	CASE j.TimeEstqty WHEN 0 THEN j.EstTimeIncAmt ELSE ROUND(j.EstTimeIncAmt/j.TimeEstqty,4) END AS UnitPrice
FROM dbo.tblJcProjTask j INNER JOIN dbo.tblPcProject p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName
	INNER JOIN dbo.tblPcProjectDetail d ON p.Id = d.ProjectId AND j.PhaseId = d.PhaseId AND j.TaskId = d.TaskId
WHERE (j.TimeEstamt <> 0 OR j.TimeEstqty <> 0 OR j.EstTimeIncAmt <> 0)

INSERT INTO dbo.tblPcEstimate(ProjectDetailId, [Type], ResourceId, LocId, [Description], Qty, Uom, UnitCost, UnitPrice)
SELECT d.Id, 1, NULL, NULL, NULL, CASE j.MaterEstqty WHEN 0 THEN 1 ELSE j.MaterEstqty END AS Qty, NULL, 
	CASE j.MaterEstqty WHEN 0 THEN j.MaterEstamt ELSE ROUND(j.MaterEstamt/j.MaterEstqty,4) END AS UnitCost, 
	CASE j.MaterEstqty WHEN 0 THEN j.EstMaterIncAmt ELSE ROUND(j.EstMaterIncAmt/j.MaterEstqty,4) END AS UnitPrice
FROM dbo.tblJcProjTask j INNER JOIN dbo.tblPcProject p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName
	INNER JOIN dbo.tblPcProjectDetail d ON p.Id = d.ProjectId AND j.PhaseId = d.PhaseId AND j.TaskId = d.TaskId
	LEFT JOIN dbo.tblJcProjectItem e ON j.CustId = e.CustId AND j.ProjId = e.ProjId AND j.PhaseId = e.PhaseId AND j.TaskId = e.TaskId
WHERE e.TranKey IS NULL AND (j.MaterEstamt <> 0 OR j.MaterEstqty <> 0 OR j.EstMaterIncAmt <> 0) --No detail estimate

--tblJcProjectItem to tblPcEstimate
INSERT INTO dbo.tblPcEstimate(ProjectDetailId, [Type], ResourceId, LocId, [Description], Qty, Uom, UnitCost, UnitPrice)
SELECT d.Id, 1, j.ItemId, j.LocId, j.Descr, j.QtyEst, j.UOM, j.UnitCost, j.UnitPrice
FROM dbo.tblJcProjectItem j INNER JOIN dbo.tblPcProject p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName
	INNER JOIN dbo.tblPcProjectDetail d ON p.Id = d.ProjectId
WHERE j.PhaseId IS NULL AND d.PhaseId IS NULL AND d.TaskId IS NULL --project with no phases

INSERT INTO dbo.tblPcEstimate(ProjectDetailId, [Type], ResourceId, LocId, [Description], Qty, Uom, UnitCost, UnitPrice)
SELECT d.Id, 1, j.ItemId, j.LocId, j.Descr, j.QtyEst, j.UOM, j.UnitCost, j.UnitPrice
FROM dbo.tblJcProjectItem j INNER JOIN dbo.tblPcProject p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName
	INNER JOIN dbo.tblPcProjectDetail d ON p.Id = d.ProjectId AND j.PhaseId = d.PhaseId AND j.PhaseId = d.TaskId
WHERE j.PhaseId IS NOT NULL AND j.TaskId IS NULL --phase with no tasks 

INSERT INTO dbo.tblPcEstimate(ProjectDetailId, [Type], ResourceId, LocId, [Description], Qty, Uom, UnitCost, UnitPrice)
SELECT d.Id, 1, j.ItemId, j.LocId, j.Descr, j.QtyEst, j.UOM, j.UnitCost, j.UnitPrice
FROM dbo.tblJcProjectItem j INNER JOIN dbo.tblPcProject p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName
	INNER JOIN dbo.tblPcProjectDetail d ON p.Id = d.ProjectId AND j.PhaseId = d.PhaseId AND j.TaskId = d.TaskId
WHERE j.PhaseId IS NOT NULL AND j.TaskId IS NOT NULL --task

--This statement has to be first statement to populate table tblPcActivity
--tblJcTransHistory to tblPcActivity
--Billed or Posted, Fixed Fee Adjustment is excluded
SET IDENTITY_INSERT dbo.tblPcActivity ON 
INSERT INTO dbo.tblPcActivity(ID, ProjectDetailId, [Source], [Type], Qty, ExtCost, ExtIncome, QtyBilled, ExtIncomeBilled, Description, AddnlDesc, ActivityDate, SourceReference, BillingReference, ResourceId, LocId, Reference, DistCode, GLAcctWIP, GLAcctPayrollClearing, GLAcctIncome, 
	GLAcctCost, GLAcctAdjustments, GLAcctFixedFeeBilling, GLAcctOverheadContra, GLAcctAccruedIncome, TaxClass, FiscalPeriod, FiscalYear, OverheadPosted, RateId, Uom, Status, BillOnHold)
SELECT t.TransHistId, p.ProjectDetailId,CASE WHEN t.[Source] = 'TT' THEN 0 WHEN t.[Source] = 'IN' THEN 1 WHEN t.[Source] IN ('TO','MO') THEN 2 WHEN t.[Source] IN ('TH','MH') THEN 3 WHEN t.[Source] = 'AP' THEN 8 ELSE 9 END AS [Source],
	CASE WHEN t.[Type] = 'T' THEN 0 ELSE 1 END AS [Type],t.AntQty,t.ExtCost,t.ExtAntInc,t.Qty,t.ExtFinalInc,NULL,t.AddnlDesc,t.TransDate,t.TransId,t.ArTransId,t.ResourceId,NULL,t.Reference,t.DistCode,t.GLAcctWIP,t.GLAcctAccrued,t.GLAcctSales,t.GLAcctCOS,t.GLAcctAdjust,t.GLAcctDeferred,
	t.GLAcctOverhead,t.GLAcctSales,t.TaxClass,t.IncomePd,t.IncomeYear,t.OH,t.BillingLevel,t.Units,
	CASE WHEN t.[Status] = 'INP' THEN 2 ELSE CASE WHEN p.[Type] = 1 THEN 5 WHEN p.Billable = 0 THEN 2 ELSE 4 END END AS [Status],0
FROM dbo.tblJcTransHistory t INNER JOIN dbo.trav_PcProject_view p ON t.CustId = p.CustId AND t.ProjId = p.ProjectName
WHERE (t.[Status] = 'BIL' OR t.[Status] = 'INP') AND t.[Source] <> 'TF' AND t.PhaseId IS NULL 
UNION ALL
SELECT t.TransHistId, p.Id,CASE WHEN t.[Source] = 'TT' THEN 0 WHEN t.[Source] = 'IN' THEN 1 WHEN t.[Source] IN ('TO','MO') THEN 2 WHEN t.[Source] IN ('TH','MH') THEN 3 WHEN t.[Source] = 'AP' THEN 8 ELSE 9 END AS [Source],
	CASE WHEN t.[Type] = 'T' THEN 0 ELSE 1 END AS [Type],t.AntQty,t.ExtCost,t.ExtAntInc,t.Qty,t.ExtFinalInc,NULL,t.AddnlDesc,t.TransDate,t.TransId,t.ArTransId,t.ResourceId,NULL,t.Reference,t.DistCode,t.GLAcctWIP,t.GLAcctAccrued,t.GLAcctSales,t.GLAcctCOS,t.GLAcctAdjust,t.GLAcctDeferred,
	t.GLAcctOverhead,t.GLAcctSales,t.TaxClass,t.IncomePd,t.IncomeYear,t.OH,t.BillingLevel,t.Units,
	CASE WHEN t.[Status] = 'INP' THEN 2 ELSE CASE WHEN p.[Type] = 1 THEN 5 WHEN p.Billable = 0 THEN 2 ELSE 4 END END AS [Status],0
FROM dbo.tblJcTransHistory t INNER JOIN dbo.trav_PcProjectTask_view p ON t.CustId = p.CustId AND t.ProjId = p.ProjectName AND t.PhaseId = p.PhaseId AND t.PhaseId = p.TaskId
WHERE (t.[Status] = 'BIL' OR t.[Status] = 'INP') AND t.[Source] <> 'TF' AND t.PhaseId IS NOT NULL AND t.TaskId IS NULL
UNION ALL
SELECT t.TransHistId, p.Id,CASE WHEN t.[Source] = 'TT' THEN 0 WHEN t.[Source] = 'IN' THEN 1 WHEN t.[Source] IN ('TO','MO') THEN 2 WHEN t.[Source] IN ('TH','MH') THEN 3 WHEN t.[Source] = 'AP' THEN 8 ELSE 9 END AS [Source],
	CASE WHEN t.[Type] = 'T' THEN 0 ELSE 1 END AS [Type],t.AntQty,t.ExtCost,t.ExtAntInc,t.Qty,t.ExtFinalInc,NULL,t.AddnlDesc,t.TransDate,t.TransId,t.ArTransId,t.ResourceId,NULL,t.Reference,t.DistCode,t.GLAcctWIP,t.GLAcctAccrued,t.GLAcctSales,t.GLAcctCOS,t.GLAcctAdjust,t.GLAcctDeferred,
	t.GLAcctOverhead,t.GLAcctSales,t.TaxClass,t.IncomePd,t.IncomeYear,t.OH,t.BillingLevel,t.Units,
	CASE WHEN t.[Status] = 'INP' THEN 2 ELSE CASE WHEN p.[Type] = 1 THEN 5 WHEN p.Billable = 0 THEN 2 ELSE 4 END END AS [Status],0
FROM dbo.tblJcTransHistory t INNER JOIN dbo.trav_PcProjectTask_view p ON t.CustId = p.CustId AND t.ProjId = p.ProjectName AND t.PhaseId = p.PhaseId AND t.TaskId = p.TaskId
WHERE (t.[Status] = 'BIL' OR t.[Status] = 'INP') AND t.[Source] <> 'TF' AND t.PhaseId IS NOT NULL AND t.TaskId IS NOT NULL
SET IDENTITY_INSERT dbo.tblPcActivity OFF

--tblJcTransHeader and tblJcTransDetail to tblPcTimeTicket
INSERT INTO dbo.tblPcTimeTicket(BatchId, EmployeeId, TransDate, FiscalYear, FiscalPeriod, ProjectDetailId, ActivityId, Qty, UnitCost, Description, AddnlDesc, RateId, BillingRate, Pieces, StateCode, LocalCode, DepartmentId, LaborClass, EarnCode, SUIState, SeqNo)
SELECT h.BatchId,h.EmployeeId,h.TransDate,h.FiscalYear,h.GLPeriod,p.ProjectDetailId,0,d.Qty,d.UnitCost,NULL,d.AddnlDesc,d.BillingRateId,d.BillingRate,d.Pieces,StateCode, StateCode + LocalCode, DepartmentId, LaborClass, EarnCode, SUIState, SeqNo
FROM dbo.tblJcTransHeader h INNER JOIN dbo.tblJcTransDetail d ON h.TransId = d.TransId 
	INNER JOIN dbo.trav_PcProject_view p ON d.CustId = p.CustId AND d.ProjId = p.ProjectName
WHERE d.PhaseId IS NULL
UNION ALL
SELECT h.BatchId,h.EmployeeId,h.TransDate,h.FiscalYear,h.GLPeriod,p.Id,0,d.Qty,d.UnitCost,NULL,d.AddnlDesc,d.BillingRateId,d.BillingRate,d.Pieces,StateCode, StateCode + LocalCode, DepartmentId, LaborClass, EarnCode, SUIState, SeqNo
FROM dbo.tblJcTransHeader h INNER JOIN dbo.tblJcTransDetail d ON h.TransId = d.TransId 
	INNER JOIN dbo.trav_PcProjectTask_view p ON d.CustId = p.CustId AND d.ProjId = p.ProjectName AND d.PhaseId = p.PhaseId AND d.PhaseId = p.TaskId
WHERE d.PhaseId IS NOT NULL AND d.TaskId IS NULL
UNION ALL
SELECT h.BatchId,h.EmployeeId,h.TransDate,h.FiscalYear,h.GLPeriod,p.Id,0,d.Qty,d.UnitCost,NULL,d.AddnlDesc,d.BillingRateId,d.BillingRate,d.Pieces,StateCode, StateCode + LocalCode, DepartmentId, LaborClass, EarnCode, SUIState, SeqNo
FROM dbo.tblJcTransHeader h INNER JOIN dbo.tblJcTransDetail d ON h.TransId = d.TransId 
	INNER JOIN dbo.trav_PcProjectTask_view p ON d.CustId = p.CustId AND d.ProjId = p.ProjectName AND d.PhaseId = p.PhaseId AND d.TaskId = p.TaskId
WHERE d.PhaseId IS NOT NULL AND d.TaskId IS NOT NULL

INSERT INTO dbo.tblPcActivity(ProjectDetailId, [Source], [Type], Qty, ExtCost, ExtIncome, QtyBilled, ExtIncomeBilled, [Description], AddnlDesc, ActivityDate, SourceReference, BillingReference, ResourceId, LocId, Reference, DistCode, GLAcctWIP, GLAcctPayrollClearing, 
	GLAcctIncome, GLAcctCost, GLAcctAdjustments, GLAcctFixedFeeBilling, GLAcctOverheadContra, GLAcctAccruedIncome, TaxClass, FiscalPeriod, FiscalYear, OverheadPosted, RateId, Uom, [Status], BillOnHold, SourceId, GLAcct, LinkSeqNum)
SELECT t.ProjectDetailId,0,0,t.Qty,ROUND(t.Qty * t.UnitCost,2),ROUND(t.Qty * t.BillingRate,2),0,0,t.[Description],t.AddnlDesc,t.TransDate,CAST(t.Id AS nvarchar),NULL,t.EmployeeId,NULL,'Time Ticket',p.DistCode,d.GLAcctWIP,d.GLAcctPayrollClearing,d.GLAcctIncome,
	d.GLAcctCost,d.GLAcctAdjustments,d.GLAcctFixedFeeBilling,d.GLAcctOverheadContra,d.GLAcctAccruedIncome,p.TaxClass,t.FiscalPeriod,t.FiscalYear,0,t.RateId,'HOUR',1,0,NULL,NULL,NULL
FROM dbo.tblPcTimeTicket t INNER JOIN dbo.tblPcProjectDetail p ON t.ProjectDetailId = p.Id 
	INNER JOIN dbo.tblPcDistCode d ON p.DistCode = d.DistCode

UPDATE dbo.tblPcTimeTicket SET ActivityId = a.Id
FROM dbo.tblPcTimeTicket INNER JOIN dbo.tblPcActivity a ON dbo.tblPcTimeTicket.Id = a.SourceReference 
WHERE a.[Source] = 0 AND a.[Status] = 1 --Unposted time ticket

--tblJcTransHistAdj tblPcAdjustment
INSERT INTO dbo.tblPcAdjustment(ProjectDetailId, FiscalPeriod, FiscalYear, TransDate, Type, Description, AddnlDesc, Qty, ExtCost, ExtIncome, Status, IncDec)
SELECT p.ProjectDetailId,t.GLPeriod,t.IncomeYear,t.TransDate,CASE WHEN t.[Type] = 'T' THEN 0 ELSE 1 END AS [Type],NULL,t.AddnlDesc,t.Qty,t.ExtCost,t.ExtFinalInc,
	CASE WHEN t.StatusFlag = 'INP' THEN 0 ELSE 1 END AS [Status],CASE WHEN t.IncDec = 1 THEN 0 ELSE 1 END AS IncDec
FROM dbo.tblJcTransHistAdj t INNER JOIN dbo.trav_PcProject_view p ON t.CustId = p.CustId AND t.ProjId = p.ProjectName
WHERE t.PhaseId IS NULL 
UNION ALL
SELECT p.Id,t.GLPeriod,t.IncomeYear,t.TransDate,CASE WHEN t.[Type] = 'T' THEN 0 ELSE 1 END AS [Type],NULL,t.AddnlDesc,t.Qty,t.ExtCost,t.ExtFinalInc,
	CASE WHEN t.StatusFlag = 'INP' THEN 0 ELSE 1 END AS [Status],CASE WHEN t.IncDec = 1 THEN 0 ELSE 1 END AS IncDec
FROM dbo.tblJcTransHistAdj t INNER JOIN dbo.trav_PcProjectTask_view p ON t.CustId = p.CustId AND t.ProjId = p.ProjectName AND t.PhaseId = p.PhaseId AND t.PhaseId = p.TaskId
WHERE t.PhaseId IS NOT NULL AND t.TaskId IS NULL
UNION ALL
SELECT p.Id,t.GLPeriod,t.IncomeYear,t.TransDate,CASE WHEN t.[Type] = 'T' THEN 0 ELSE 1 END AS [Type],NULL,t.AddnlDesc,t.Qty,t.ExtCost,t.ExtFinalInc,
	CASE WHEN t.StatusFlag = 'INP' THEN 0 ELSE 1 END AS [Status],CASE WHEN t.IncDec = 1 THEN 0 ELSE 1 END AS IncDec
FROM dbo.tblJcTransHistAdj t INNER JOIN dbo.trav_PcProjectTask_view p ON t.CustId = p.CustId AND t.ProjId = p.ProjectName AND t.PhaseId = p.PhaseId AND t.TaskId = p.TaskId
WHERE t.PhaseId IS NOT NULL AND t.TaskId IS NOT NULL

--Remove committed qty of estimates
UPDATE dbo.tblInQty SET Qty = 0
FROM dbo.tblInQty INNER JOIN dbo.tblJcProjectItem e ON dbo.tblInQty.SeqNum = e.QtySeqNum

--tblJcProjComments to tblSmAttachment
INSERT INTO dbo.tblSmAttachment (LinkType, LinkKey, [Status], Priority, [Description], [ExpireDate], EntryDate, EnteredBy, Keywords, Comment, [FileName])
SELECT 'PCPROJECT',p.ProjectDetailId,0,0,NULL,c.ReminderDate,c.EnteredDate,'Converted',c.CustId + ';' + c.ProjId,c.Comment,c.DocumentLink
FROM dbo.tblJcProjComments c INNER JOIN dbo.trav_PcProject_view p ON c.CustId = p.CustId AND c.ProjId = p.ProjectName

--tblJcPhaseComments to tblSmAttachment
INSERT INTO dbo.tblSmAttachment (LinkType, LinkKey, [Status], Priority, [Description], [ExpireDate], EntryDate, EnteredBy, Keywords, Comment, [FileName])
SELECT 'PCPROJECT',p.Id,0,0,NULL,c.ReminderDate,c.EnteredDate,'Converted',c.CustId + ';' + c.ProjId + ';' + c.PhaseId,c.Comment,c.DocumentLink
FROM dbo.tblJcPhaseComments c INNER JOIN dbo.trav_PcProjectTask_view p ON c.CustId = p.CustId AND c.ProjId = p.ProjectName AND c.PhaseId = p.PhaseId AND c.PhaseId = p.TaskId

--tblJcTaskComments to tblSmAttachment
INSERT INTO dbo.tblSmAttachment (LinkType, LinkKey, [Status], Priority, [Description], [ExpireDate], EntryDate, EnteredBy, Keywords, Comment, [FileName])
SELECT 'PCPROJECT',p.Id,0,0,NULL,c.ReminderDate,c.EnteredDate,'Converted',c.CustId + ';' + c.ProjId + ';' + c.PhaseId + ';' + c.TaskId,c.Comment,c.DocumentLink
FROM dbo.tblJcTaskComments c INNER JOIN dbo.trav_PcProjectTask_view p ON c.CustId = p.CustId AND c.ProjId = p.ProjectName AND c.PhaseId = p.PhaseId AND c.TaskId = p.TaskId

--Document link
BEGIN
INSERT INTO dbo.tblSmAttachment (LinkType, LinkKey, [Status], Priority, [Description], [ExpireDate], EntryDate, EnteredBy, Keywords, Comment, [FileName])
SELECT 'PCPROJECT',p.ProjectDetailId,0,0,NULL,NULL,CAST(CONVERT(nvarchar(8), GETDATE(), 112) AS DATETIME),'Converted',j.CustId + ';' + j.ProjId,NULL,j.DocumentLink
FROM dbo.tblJcProject j INNER JOIN dbo.trav_PcProject_view p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName 
WHERE ISNULL(j.DocumentLink,'') <> ''

INSERT INTO dbo.tblSmAttachment (LinkType, LinkKey, [Status], Priority, [Description], [ExpireDate], EntryDate, EnteredBy, Keywords, Comment, [FileName])
SELECT 'PCPROJECT',p.Id,0,0,NULL,NULL,CAST(CONVERT(nvarchar(8), GETDATE(), 112) AS DATETIME),'Converted',j.CustId + ';' + j.ProjId + ';' + j.PhaseId,NULL,j.DocumentLink
FROM dbo.tblJcProjPhase j INNER JOIN dbo.trav_PcProjectTask_view p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName  AND j.PhaseId = p.PhaseId AND j.PhaseId = p.TaskId
WHERE ISNULL(j.DocumentLink,'') <> ''

INSERT INTO dbo.tblSmAttachment (LinkType, LinkKey, [Status], Priority, [Description], [ExpireDate], EntryDate, EnteredBy, Keywords, Comment, [FileName])
SELECT 'PCPROJECT',p.Id,0,0,NULL,NULL,CAST(CONVERT(nvarchar(8), GETDATE(), 112) AS DATETIME),'Converted',j.CustId + ';' + j.ProjId + ';' + j.PhaseId + ';' + j.TaskId,NULL,j.DocumentLink
FROM dbo.tblJcProjTask j INNER JOIN dbo.trav_PcProjectTask_view p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName  AND j.PhaseId = p.PhaseId AND j.TaskId = p.TaskId
WHERE ISNULL(j.DocumentLink,'') <> ''
END

--Deposits
INSERT INTO dbo.tblPcActivity(ProjectDetailId, Source, Type, Qty, ExtCost, ExtIncome, QtyBilled, ExtIncomeBilled, Description, AddnlDesc, ActivityDate, SourceReference, BillingReference, ResourceId, 
	LocId, Reference, DistCode, GLAcctWIP, GLAcctPayrollClearing, GLAcctIncome, GLAcctCost, GLAcctAdjustments, GLAcctFixedFeeBilling, GLAcctOverheadContra, GLAcctAccruedIncome, TaxClass, FiscalPeriod, FiscalYear, OverheadPosted, RateId, Uom, Status, BillOnHold, SourceId, GLAcct)
SELECT p.ProjectDetailId,4,4,0,0,j.DepositAmt,0,0,'Deposit',NULL,CAST(CONVERT(nvarchar(8), GETDATE(), 112) AS DATETIME),'Migration',NULL,j.CustId,NULL,'Deposit',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,MONTH(GETDATE()),YEAR(GETDATE()),0,NULL,NULL,2,0,NULL,NULL
FROM dbo.tblJcProject j INNER JOIN dbo.trav_PcProject_view p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName 
WHERE j.BilltoPhaseYn = 0 AND j.DepositAmt <> 0
UNION ALL 
SELECT p.ProjectDetailId,5,5,0,0,j.DepositApp,0,0,'Applied deposit',NULL,CAST(CONVERT(nvarchar(8), GETDATE(), 112) AS DATETIME),'Migration',NULL,j.CustId,NULL,'Applied Deposit',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,MONTH(GETDATE()),YEAR(GETDATE()),0,NULL,NULL,2,0,NULL,NULL
FROM dbo.tblJcProject j INNER JOIN dbo.trav_PcProject_view p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName 
WHERE j.BilltoPhaseYn = 0 AND j.DepositApp <> 0
UNION ALL
SELECT p.Id,4,4,0,0,j.DepositAmt,0,0,'Deposit',NULL,CAST(CONVERT(nvarchar(8), GETDATE(), 112) AS DATETIME),'Migration',NULL,j.CustId,NULL,'Deposit',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,MONTH(GETDATE()),YEAR(GETDATE()),0,NULL,NULL,2,0,NULL,NULL
FROM dbo.tblJcProjPhase j INNER JOIN dbo.trav_PcProjectTask_view p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName AND j.PhaseId = p.PhaseId AND j.PhaseId = p.TaskId 
WHERE j.DepositAmt <> 0
UNION ALL
SELECT p.Id,5,5,0,0,j.DepositApp,0,0,'Applied deposit',NULL,CAST(CONVERT(nvarchar(8), GETDATE(), 112) AS DATETIME),'Migration',NULL,j.CustId,NULL,'Applied Deposit',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,MONTH(GETDATE()),YEAR(GETDATE()),0,NULL,NULL,2,0,NULL,NULL
FROM dbo.tblJcProjPhase j INNER JOIN dbo.trav_PcProjectTask_view p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName AND j.PhaseId = p.PhaseId AND j.PhaseId = p.TaskId 
WHERE j.DepositApp <> 0

--Fixed Fee Billing
INSERT INTO dbo.tblPcActivity(ProjectDetailId, Source, Type, Qty, ExtCost, ExtIncome, QtyBilled, ExtIncomeBilled, Description, AddnlDesc, ActivityDate, SourceReference, BillingReference, ResourceId, 
	LocId, Reference, DistCode, GLAcctWIP, GLAcctPayrollClearing, GLAcctIncome, GLAcctCost, GLAcctAdjustments, GLAcctFixedFeeBilling, GLAcctOverheadContra, GLAcctAccruedIncome, TaxClass, FiscalPeriod, FiscalYear, OverheadPosted, RateId, Uom, Status, BillOnHold, SourceId, GLAcct)
SELECT p.ProjectDetailId,5,6,0,0,j.PTDBilled,0,0,'Fixed fee billing',NULL,CAST(CONVERT(nvarchar(8), GETDATE(), 112) AS DATETIME),'Migration',NULL,j.CustId,NULL,'Fixed fee billing',d.DistCode,c.GLAcctWIP, c.GLAcctPayrollClearing, c.GLAcctIncome, c.GLAcctCost, c.GLAcctAdjustments, 
	c.GLAcctFixedFeeBilling, c.GLAcctOverheadContra, c.GLAcctAccruedIncome,d.TaxClass,MONTH(GETDATE()),YEAR(GETDATE()),0,NULL,NULL,2,0,NULL,NULL
FROM dbo.tblJcProject j INNER JOIN dbo.trav_PcProject_view p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName 
	INNER JOIN dbo.tblPcProjectDetail d ON p.ProjectDetailId = d.Id 
	LEFT JOIN dbo.tblPcDistCode c ON d.DistCode = c.DistCode
WHERE j.BilltoPhaseYn = 0 AND j.PTDBilled <> 0 AND d.FixedFee = 1
UNION ALL 
SELECT p.Id,5,6,0,0,j.PTDBilled,0,0,'Fixed fee billing',NULL,CAST(CONVERT(nvarchar(8), GETDATE(), 112) AS DATETIME),'Migration',NULL,j.CustId,NULL,'Fixed fee billing',p.DistCode,c.GLAcctWIP, c.GLAcctPayrollClearing, c.GLAcctIncome, c.GLAcctCost, c.GLAcctAdjustments, 
	c.GLAcctFixedFeeBilling, c.GLAcctOverheadContra, c.GLAcctAccruedIncome,p.TaxClass,MONTH(GETDATE()),YEAR(GETDATE()),0,NULL,NULL,2,0,NULL,NULL
FROM dbo.tblJcProjPhase j INNER JOIN dbo.trav_PcProjectTask_view p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName AND j.PhaseId = p.PhaseId AND j.PhaseId = p.TaskId 
	LEFT JOIN dbo.tblPcDistCode c ON p.DistCode = c.DistCode
WHERE j.PTDBilled <> 0 AND p.FixedFee = 1

--Archive projects
--tblJcArcProject to tblPcProject, tblPcProjectDetail, tblPcEstimate
--PrintOption needs to be manually set.
INSERT INTO dbo.tblPcProject(ProjectName, CustId, [Type])
SELECT j.ProjId, j.CustId, 
CASE j.[Status] WHEN 0 THEN 2 WHEN 2 THEN 1 ELSE 0 END
FROM dbo.tblJcArcProject j LEFT JOIN dbo.tblPcProject p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName 
WHERE p.ProjectName IS NULL

INSERT INTO dbo.tblPcProjectDetail(ProjectId, PhaseId, TaskId, [Description], [Status], BillOnHold, Speculative, Billable, FixedFee, FixedFeeAmt, 
	EstStartDate, EstEndDate, ActStartDate, ActEndDate, DistCode, OhAllCode, TaxClass, MaterialMarkup, OverrideRate, AddnlDesc, LastDateBilled, RateId,
	ExpenseMarkup,OtherMarkup,Rep1Id,Rep2Id,Rep1Pct,Rep2Pct,Rep1CommRate,Rep2CommRate)
SELECT p.Id, NULL, NULL, j.ProjName, 2, HoldYn, CASE j.Status WHEN 4 THEN 1 ELSE 0 END Speculative,
	CASE j.Status WHEN 1 THEN 1 WHEN 4 THEN 1 ELSE 0 END Billable, j.FixedFee, CASE WHEN j.FeetoPhaseYn = 0 THEN j.FixedFeeAmt ELSE 0 END, j.EstStartDate, j.EstEndDate, j.ActStartDate, j.ActEndDate, 
	j.DistCode, j.OhAllCode, j.TaxClass, j.Markup, j.OverrideRate, j.AddnlDesc, j.LastDateBilled, j.Billinglevel, 0, 0, c.SalesRepId1, c.SalesRepId2,
	ISNULL(c.Rep1PctInvc,0), ISNULL(c.Rep2PctInvc,0), ISNULL(r1.CommRate,0), ISNULL(r2.CommRate,0)
FROM dbo.tblJcArcProject j INNER JOIN dbo.tblPcProject p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName 
	LEFT JOIN dbo.tblPcProjectDetail d ON p.Id = d.ProjectId AND d.PhaseId IS NULL AND d.TaskId IS NULL 
	LEFT JOIN dbo.tblArCust c ON j.CustId = c.CustId 
	LEFT JOIN dbo.tblArSalesRep r1 ON c.SalesRepId1 = r1.SalesRepID 
	LEFT JOIN dbo.tblArSalesRep r2 ON c.SalesRepId2 = r2.SalesRepID
WHERE d.ProjectId IS NULL

INSERT INTO dbo.tblPcEstimate(ProjectDetailId, [Type], ResourceId, LocId, [Description], Qty, Uom, UnitCost, UnitPrice)
SELECT d.Id, 0, NULL, NULL, NULL, CASE j.TimeEstqty WHEN 0 THEN 1 ELSE j.TimeEstqty END AS Qty, 'HOUR', 
	CASE j.TimeEstqty WHEN 0 THEN j.TimeEstamt ELSE ROUND(j.TimeEstamt/j.TimeEstqty,4) END AS UnitCost, 
	CASE j.TimeEstqty WHEN 0 THEN j.EstTimeIncAmt ELSE ROUND(j.EstTimeIncAmt/j.TimeEstqty,4) END AS UnitPrice
FROM dbo.tblJcArcProject j INNER JOIN dbo.tblPcProject p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName
	INNER JOIN dbo.tblPcProjectDetail d ON p.Id = d.ProjectId
WHERE j.PhaseYn = 0 AND d.PhaseId IS NULL AND d.TaskId IS NULL AND (j.TimeEstamt <> 0 OR j.TimeEstqty <> 0 OR j.EstTimeIncAmt <> 0)--project with no phases

INSERT INTO dbo.tblPcEstimate(ProjectDetailId, [Type], ResourceId, LocId, [Description], Qty, Uom, UnitCost, UnitPrice)
SELECT d.Id, 1, NULL, NULL, NULL, CASE j.MaterEstqty WHEN 0 THEN 1 ELSE j.MaterEstqty END AS Qty, NULL, 
	CASE j.MaterEstqty WHEN 0 THEN j.MaterEstamt ELSE ROUND(j.MaterEstamt/j.MaterEstqty,4) END AS UnitCost, 
	CASE j.MaterEstqty WHEN 0 THEN j.EstMaterIncAmt ELSE ROUND(j.EstMaterIncAmt/j.MaterEstqty,4) END AS UnitPrice
FROM dbo.tblJcArcProject j INNER JOIN dbo.tblPcProject p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName
	INNER JOIN dbo.tblPcProjectDetail d ON p.Id = d.ProjectId 
	LEFT JOIN dbo.tblJcArcProjectItem e ON j.CustId = e.CustId AND j.ProjId = e.ProjId
WHERE j.PhaseYn = 0 AND d.PhaseId IS NULL AND d.TaskId IS NULL AND e.TranKey IS NULL AND (j.MaterEstamt <> 0 OR j.MaterEstqty <> 0 OR j.EstMaterIncAmt <> 0)--project with no phases, no detail estimate

--Add phase id to tblPcTask for phases do not use task
INSERT INTO dbo.tblPcTask(TaskId, [Description])
SELECT DISTINCT p.PhaseId, s.PhaseName
FROM dbo.tblJcArcProjPhase p LEFT JOIN dbo.tblJcPhases s ON p.PhaseId = s.PhaseId
WHERE p.TaskYn = 0 AND p.PhaseId NOT IN (SELECT TaskId FROM dbo.tblPcTask)

--tblJcArcProjPhase to tblPcProjectDetail and tblPcEstimate, phases do not use task
INSERT INTO dbo.tblPcProjectDetail(ProjectId, PhaseId, TaskId, [Description], [Status], BillOnHold, Speculative, Billable, FixedFee, FixedFeeAmt, 
	EstStartDate, EstEndDate, ActStartDate, ActEndDate, DistCode, OhAllCode, TaxClass, MaterialMarkup, OverrideRate, AddnlDesc, LastDateBilled, RateId)
SELECT p.Id, j.PhaseId, j.PhaseId, j.PhaseName, 2, HoldYn, CASE j.Status WHEN 4 THEN 1 ELSE 0 END Speculative,
	CASE j.Status WHEN 1 THEN 1 WHEN 4 THEN 1 ELSE 0 END Billable, j.FixedFee, j.FixedFeeAmt, j.EstStartDate, j.EstEndDate, j.ActStartDate, j.ActEndDate, 
	j.DistCode, j.OhAllCode, j.TaxClass, j.Markup, j.OverrideRate, j.AddnlDesc, j.LastDateBilled, j.Billinglevel
FROM dbo.tblJcArcProjPhase j INNER JOIN dbo.tblPcProject p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName 
	LEFT JOIN dbo.tblPcProjectDetail d ON p.Id = d.ProjectId AND j.PhaseId = d.PhaseId AND j.PhaseId = d.TaskId
WHERE j.TaskYn = 0 AND d.ProjectId IS NULL

INSERT INTO dbo.tblPcEstimate(ProjectDetailId, [Type], ResourceId, LocId, [Description], Qty, Uom, UnitCost, UnitPrice)
SELECT d.Id, 0, NULL, NULL, NULL, CASE j.TimeEstqty WHEN 0 THEN 1 ELSE j.TimeEstqty END AS Qty, 'HOUR', 
	CASE j.TimeEstqty WHEN 0 THEN j.TimeEstamt ELSE ROUND(j.TimeEstamt/j.TimeEstqty,4) END AS UnitCost, 
	CASE j.TimeEstqty WHEN 0 THEN j.EstTimeIncAmt ELSE ROUND(j.EstTimeIncAmt/j.TimeEstqty,4) END AS UnitPrice
FROM dbo.tblJcArcProjPhase j INNER JOIN dbo.tblPcProject p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName
	INNER JOIN dbo.tblPcProjectDetail d ON p.Id = d.ProjectId AND j.PhaseId = d.PhaseId AND j.PhaseId = d.TaskId
WHERE j.TaskYn = 0 AND (j.TimeEstamt <> 0 OR j.TimeEstqty <> 0 OR j.EstTimeIncAmt <> 0)

INSERT INTO dbo.tblPcEstimate(ProjectDetailId, [Type], ResourceId, LocId, [Description], Qty, Uom, UnitCost, UnitPrice)
SELECT d.Id, 1, NULL, NULL, NULL, CASE j.MaterEstqty WHEN 0 THEN 1 ELSE j.MaterEstqty END AS Qty, NULL, 
	CASE j.MaterEstqty WHEN 0 THEN j.MaterEstamt ELSE ROUND(j.MaterEstamt/j.MaterEstqty,4) END AS UnitCost, 
	CASE j.MaterEstqty WHEN 0 THEN j.EstMaterIncAmt ELSE ROUND(j.EstMaterIncAmt/j.MaterEstqty,4) END AS UnitPrice
FROM dbo.tblJcArcProjPhase j INNER JOIN dbo.tblPcProject p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName
	INNER JOIN dbo.tblPcProjectDetail d ON p.Id = d.ProjectId AND j.PhaseId = d.PhaseId AND j.PhaseId = d.TaskId
	LEFT JOIN dbo.tblJcArcProjectItem e ON j.CustId = e.CustId AND j.ProjId = e.ProjId AND j.PhaseId = e.PhaseId
WHERE j.TaskYn = 0 AND e.TranKey IS NULL AND (j.MaterEstamt <> 0 OR j.MaterEstqty <> 0 OR j.EstMaterIncAmt <> 0) --No detail estimate

--tblJcArcProjTask to tblPcProjectDetail and tblPcEstimate
INSERT INTO dbo.tblPcProjectDetail(ProjectId, PhaseId, TaskId, [Description], [Status], BillOnHold, Speculative, Billable, FixedFee, FixedFeeAmt, 
	EstStartDate, EstEndDate, ActStartDate, ActEndDate, DistCode, OhAllCode, TaxClass, MaterialMarkup, OverrideRate, AddnlDesc, LastDateBilled, RateId)
SELECT TOP 1 p.Id, j.PhaseId, j.TaskId, j.TaskName, 2, HoldYn, CASE j.Status WHEN 4 THEN 1 ELSE 0 END Speculative,
	CASE j.Status WHEN 1 THEN 1 WHEN 4 THEN 1 ELSE 0 END Billable, s.FixedFee, s.FixedFeeAmt, j.EstStartDate, j.EstEndDate, j.ActStartDate, j.ActEndDate, 
	j.DistCode, j.OhAllCode, s.TaxClass, j.Markup, j.OverrideRate, j.AddnlDesc, j.LastDateBilled, j.Billinglevel
FROM dbo.tblJcArcProjTask j INNER JOIN dbo.tblPcProject p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName 
	INNER JOIN dbo.tblJcProjPhase s ON j.CustId = s.CustId AND j.ProjId = s.ProjId AND j.PhaseId = s.PhaseId 
	LEFT JOIN dbo.tblPcProjectDetail d ON p.Id = d.ProjectId AND j.PhaseId = d.PhaseId AND j.TaskId = d.TaskId
WHERE d.ProjectId IS NULL

INSERT INTO dbo.tblPcProjectDetail(ProjectId, PhaseId, TaskId, [Description], [Status], BillOnHold, Speculative, Billable, FixedFee, FixedFeeAmt, 
	EstStartDate, EstEndDate, ActStartDate, ActEndDate, DistCode, OhAllCode, TaxClass, MaterialMarkup, OverrideRate, AddnlDesc, LastDateBilled, RateId)
SELECT TOP 1 p.Id, j.PhaseId, j.TaskId, j.TaskName, 2, HoldYn, CASE j.Status WHEN 4 THEN 1 ELSE 0 END Speculative,
	CASE j.Status WHEN 1 THEN 1 WHEN 4 THEN 1 ELSE 0 END Billable, s.FixedFee, 0, j.EstStartDate, j.EstEndDate, j.ActStartDate, j.ActEndDate, 
	j.DistCode, j.OhAllCode, s.TaxClass, j.Markup, j.OverrideRate, j.AddnlDesc, j.LastDateBilled, j.Billinglevel
FROM dbo.tblJcArcProjTask j INNER JOIN dbo.tblPcProject p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName 
	INNER JOIN dbo.tblJcProjPhase s ON j.CustId = s.CustId AND j.ProjId = s.ProjId AND j.PhaseId = s.PhaseId 
	LEFT JOIN dbo.tblPcProjectDetail d ON p.Id = d.ProjectId AND j.PhaseId = d.PhaseId AND j.TaskId = d.TaskId
WHERE d.ProjectId IS NULL

INSERT INTO dbo.tblPcEstimate(ProjectDetailId, [Type], ResourceId, LocId, [Description], Qty, Uom, UnitCost, UnitPrice)
SELECT d.Id, 0, NULL, NULL, NULL, CASE j.TimeEstqty WHEN 0 THEN 1 ELSE j.TimeEstqty END AS Qty, 'HOUR', 
	CASE j.TimeEstqty WHEN 0 THEN j.TimeEstamt ELSE ROUND(j.TimeEstamt/j.TimeEstqty,4) END AS UnitCost, 
	CASE j.TimeEstqty WHEN 0 THEN j.EstTimeIncAmt ELSE ROUND(j.EstTimeIncAmt/j.TimeEstqty,4) END AS UnitPrice
FROM dbo.tblJcArcProjTask j INNER JOIN dbo.tblPcProject p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName
	INNER JOIN dbo.tblPcProjectDetail d ON p.Id = d.ProjectId AND j.PhaseId = d.PhaseId AND j.TaskId = d.TaskId
WHERE (j.TimeEstamt <> 0 OR j.TimeEstqty <> 0 OR j.EstTimeIncAmt <> 0)

INSERT INTO dbo.tblPcEstimate(ProjectDetailId, [Type], ResourceId, LocId, [Description], Qty, Uom, UnitCost, UnitPrice)
SELECT d.Id, 1, NULL, NULL, NULL, CASE j.MaterEstqty WHEN 0 THEN 1 ELSE j.MaterEstqty END AS Qty, NULL, 
	CASE j.MaterEstqty WHEN 0 THEN j.MaterEstamt ELSE ROUND(j.MaterEstamt/j.MaterEstqty,4) END AS UnitCost, 
	CASE j.MaterEstqty WHEN 0 THEN j.EstMaterIncAmt ELSE ROUND(j.EstMaterIncAmt/j.MaterEstqty,4) END AS UnitPrice
FROM dbo.tblJcArcProjTask j INNER JOIN dbo.tblPcProject p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName
	INNER JOIN dbo.tblPcProjectDetail d ON p.Id = d.ProjectId AND j.PhaseId = d.PhaseId AND j.TaskId = d.TaskId
	LEFT JOIN dbo.tblJcArcProjectItem e ON j.CustId = e.CustId AND j.ProjId = e.ProjId AND j.PhaseId = e.PhaseId AND j.TaskId = e.TaskId
WHERE e.TranKey IS NULL AND (j.MaterEstamt <> 0 OR j.MaterEstqty <> 0 OR j.EstMaterIncAmt <> 0) --No detail estimate

--tblJcArcProjectItem to tblPcEstimate
INSERT INTO dbo.tblPcEstimate(ProjectDetailId, [Type], ResourceId, LocId, [Description], Qty, Uom, UnitCost, UnitPrice)
SELECT d.Id, 1, j.ItemId, j.LocId, j.Descr, j.QtyEst, j.UOM, j.UnitCost, j.UnitPrice
FROM dbo.tblJcArcProjectItem j INNER JOIN dbo.tblPcProject p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName
	INNER JOIN dbo.tblPcProjectDetail d ON p.Id = d.ProjectId
WHERE j.PhaseId IS NULL AND d.PhaseId IS NULL AND d.TaskId IS NULL --project with no phases

INSERT INTO dbo.tblPcEstimate(ProjectDetailId, [Type], ResourceId, LocId, [Description], Qty, Uom, UnitCost, UnitPrice)
SELECT d.Id, 1, j.ItemId, j.LocId, j.Descr, j.QtyEst, j.UOM, j.UnitCost, j.UnitPrice
FROM dbo.tblJcArcProjectItem j INNER JOIN dbo.tblPcProject p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName
	INNER JOIN dbo.tblPcProjectDetail d ON p.Id = d.ProjectId AND j.PhaseId = d.PhaseId AND j.PhaseId = d.TaskId
WHERE j.PhaseId IS NOT NULL AND j.TaskId IS NULL --phase with no tasks 

INSERT INTO dbo.tblPcEstimate(ProjectDetailId, [Type], ResourceId, LocId, [Description], Qty, Uom, UnitCost, UnitPrice)
SELECT d.Id, 1, j.ItemId, j.LocId, j.Descr, j.QtyEst, j.UOM, j.UnitCost, j.UnitPrice
FROM dbo.tblJcArcProjectItem j INNER JOIN dbo.tblPcProject p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName
	INNER JOIN dbo.tblPcProjectDetail d ON p.Id = d.ProjectId AND j.PhaseId = d.PhaseId AND j.TaskId = d.TaskId
WHERE j.PhaseId IS NOT NULL AND j.TaskId IS NOT NULL --task

--tblJcArcTransHistory to tblPcActivity
--Billed or Posted, Fixed Fee Adjustment is excluded
INSERT INTO dbo.tblPcActivity(ProjectDetailId, [Source], [Type], Qty, ExtCost, ExtIncome, QtyBilled, ExtIncomeBilled, Description, AddnlDesc, ActivityDate, SourceReference, BillingReference, ResourceId, LocId, Reference, DistCode, GLAcctWIP, GLAcctPayrollClearing, GLAcctIncome, 
	GLAcctCost, GLAcctAdjustments, GLAcctFixedFeeBilling, GLAcctOverheadContra, GLAcctAccruedIncome, TaxClass, FiscalPeriod, FiscalYear, OverheadPosted, RateId, Uom, Status, BillOnHold)
SELECT p.ProjectDetailId,CASE WHEN t.[Source] = 'TT' THEN 0 WHEN t.[Source] = 'IN' THEN 1 WHEN t.[Source] IN ('TO','MO') THEN 2 WHEN t.[Source] IN ('TH','MH') THEN 3 WHEN t.[Source] = 'AP' THEN 8 ELSE 9 END AS [Source],
	CASE WHEN t.[Type] = 'T' THEN 0 ELSE 1 END AS [Type],t.AntQty,t.ExtCost,t.ExtAntInc,t.Qty,t.ExtFinalInc,NULL,t.AddnlDesc,t.TransDate,t.TransId,t.ArTransId,t.ResourceId,NULL,t.Reference,t.DistCode,t.GLAcctWIP,t.GLAcctAccrued,t.GLAcctSales,t.GLAcctCOS,t.GLAcctAdjust,t.GLAcctDeferred,
	t.GLAcctOverhead,t.GLAcctSales,t.TaxClass,t.IncomePd,t.IncomeYear,t.OH,t.BillingLevel,t.Units,CASE WHEN t.[Status] = 'BIL' THEN 4 ELSE 2 END AS [Status],0
FROM dbo.tblJcArcTransHistory t INNER JOIN dbo.trav_PcProject_view p ON t.CustId = p.CustId AND t.ProjId = p.ProjectName
WHERE (t.[Status] = 'BIL' OR t.[Status] = 'INP') AND t.[Source] <> 'TF' AND t.PhaseId IS NULL 
UNION ALL
SELECT p.Id,CASE WHEN t.[Source] = 'TT' THEN 0 WHEN t.[Source] = 'IN' THEN 1 WHEN t.[Source] IN ('TO','MO') THEN 2 WHEN t.[Source] IN ('TH','MH') THEN 3 WHEN t.[Source] = 'AP' THEN 8 ELSE 9 END AS [Source],
	CASE WHEN t.[Type] = 'T' THEN 0 ELSE 1 END AS [Type],t.AntQty,t.ExtCost,t.ExtAntInc,t.Qty,t.ExtFinalInc,NULL,t.AddnlDesc,t.TransDate,t.TransId,t.ArTransId,t.ResourceId,NULL,t.Reference,t.DistCode,t.GLAcctWIP,t.GLAcctAccrued,t.GLAcctSales,t.GLAcctCOS,t.GLAcctAdjust,t.GLAcctDeferred,
	t.GLAcctOverhead,t.GLAcctSales,t.TaxClass,t.IncomePd,t.IncomeYear,t.OH,t.BillingLevel,t.Units,CASE WHEN t.[Status] = 'BIL' THEN 4 ELSE 2 END AS [Status],0
FROM dbo.tblJcArcTransHistory t INNER JOIN dbo.trav_PcProjectTask_view p ON t.CustId = p.CustId AND t.ProjId = p.ProjectName AND t.PhaseId = p.PhaseId AND t.PhaseId = p.TaskId
WHERE (t.[Status] = 'BIL' OR t.[Status] = 'INP') AND t.[Source] <> 'TF' AND t.PhaseId IS NOT NULL AND t.TaskId IS NULL
UNION ALL
SELECT p.Id,CASE WHEN t.[Source] = 'TT' THEN 0 WHEN t.[Source] = 'IN' THEN 1 WHEN t.[Source] IN ('TO','MO') THEN 2 WHEN t.[Source] IN ('TH','MH') THEN 3 WHEN t.[Source] = 'AP' THEN 8 ELSE 9 END AS [Source],
	CASE WHEN t.[Type] = 'T' THEN 0 ELSE 1 END AS [Type],t.AntQty,t.ExtCost,t.ExtAntInc,t.Qty,t.ExtFinalInc,NULL,t.AddnlDesc,t.TransDate,t.TransId,t.ArTransId,t.ResourceId,NULL,t.Reference,t.DistCode,t.GLAcctWIP,t.GLAcctAccrued,t.GLAcctSales,t.GLAcctCOS,t.GLAcctAdjust,t.GLAcctDeferred,
	t.GLAcctOverhead,t.GLAcctSales,t.TaxClass,t.IncomePd,t.IncomeYear,t.OH,t.BillingLevel,t.Units,CASE WHEN t.[Status] = 'BIL' THEN 4 ELSE 2 END AS [Status],0
FROM dbo.tblJcArcTransHistory t INNER JOIN dbo.trav_PcProjectTask_view p ON t.CustId = p.CustId AND t.ProjId = p.ProjectName AND t.PhaseId = p.PhaseId AND t.TaskId = p.TaskId
WHERE (t.[Status] = 'BIL' OR t.[Status] = 'INP') AND t.[Source] <> 'TF' AND t.PhaseId IS NOT NULL AND t.TaskId IS NOT NULL

--tblJcArcProjComments to tblSmAttachment
INSERT INTO dbo.tblSmAttachment (LinkType, LinkKey, [Status], Priority, [Description], [ExpireDate], EntryDate, EnteredBy, Keywords, Comment, [FileName])
SELECT 'PCPROJECT',p.ProjectDetailId,0,0,NULL,c.ReminderDate,c.EnteredDate,'Converted',c.CustId + ';' + c.ProjId,c.Comment,c.DocumentLink
FROM dbo.tblJcArcProjComments c INNER JOIN dbo.trav_PcProject_view p ON c.CustId = p.CustId AND c.ProjId = p.ProjectName

--tblJcArcPhaseComments to tblSmAttachment
INSERT INTO dbo.tblSmAttachment (LinkType, LinkKey, [Status], Priority, [Description], [ExpireDate], EntryDate, EnteredBy, Keywords, Comment, [FileName])
SELECT 'PCPROJECT',p.Id,0,0,NULL,c.ReminderDate,c.EnteredDate,'Converted',c.CustId + ';' + c.ProjId + ';' + c.PhaseId,c.Comment,c.DocumentLink
FROM dbo.tblJcArcPhaseComments c INNER JOIN dbo.trav_PcProjectTask_view p ON c.CustId = p.CustId AND c.ProjId = p.ProjectName AND c.PhaseId = p.PhaseId AND c.PhaseId = p.TaskId

--tblJcArcTaskComments to tblSmAttachment
INSERT INTO dbo.tblSmAttachment (LinkType, LinkKey, [Status], Priority, [Description], [ExpireDate], EntryDate, EnteredBy, Keywords, Comment, [FileName])
SELECT 'PCPROJECT',p.Id,0,0,NULL,c.ReminderDate,c.EnteredDate,'Converted',c.CustId + ';' + c.ProjId + ';' + c.PhaseId + ';' + c.TaskId,c.Comment,c.DocumentLink
FROM dbo.tblJcArcTaskComments c INNER JOIN dbo.trav_PcProjectTask_view p ON c.CustId = p.CustId AND c.ProjId = p.ProjectName AND c.PhaseId = p.PhaseId AND c.TaskId = p.TaskId

--Archive Document link
BEGIN
INSERT INTO dbo.tblSmAttachment (LinkType, LinkKey, [Status], Priority, [Description], [ExpireDate], EntryDate, EnteredBy, Keywords, Comment, [FileName])
SELECT 'PCPROJECT',p.ProjectDetailId,0,0,NULL,NULL,CAST(CONVERT(nvarchar(8), GETDATE(), 112) AS DATETIME),'Converted',j.CustId + ';' + j.ProjId,NULL,j.DocumentLink
FROM dbo.tblJcArcProject j INNER JOIN dbo.trav_PcProject_view p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName 
WHERE ISNULL(j.DocumentLink,'') <> ''

INSERT INTO dbo.tblSmAttachment (LinkType, LinkKey, [Status], Priority, [Description], [ExpireDate], EntryDate, EnteredBy, Keywords, Comment, [FileName])
SELECT 'PCPROJECT',p.Id,0,0,NULL,NULL,CAST(CONVERT(nvarchar(8), GETDATE(), 112) AS DATETIME),'Converted',j.CustId + ';' + j.ProjId + ';' + j.PhaseId,NULL,j.DocumentLink
FROM dbo.tblJcArcProjPhase j INNER JOIN dbo.trav_PcProjectTask_view p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName  AND j.PhaseId = p.PhaseId AND j.PhaseId = p.TaskId
WHERE ISNULL(j.DocumentLink,'') <> ''

INSERT INTO dbo.tblSmAttachment (LinkType, LinkKey, [Status], Priority, [Description], [ExpireDate], EntryDate, EnteredBy, Keywords, Comment, [FileName])
SELECT 'PCPROJECT',p.Id,0,0,NULL,NULL,CAST(CONVERT(nvarchar(8), GETDATE(), 112) AS DATETIME),'Converted',j.CustId + ';' + j.ProjId + ';' + j.PhaseId + ';' + j.TaskId,NULL,j.DocumentLink
FROM dbo.tblJcArcProjTask j INNER JOIN dbo.trav_PcProjectTask_view p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName  AND j.PhaseId = p.PhaseId AND j.TaskId = p.TaskId
WHERE ISNULL(j.DocumentLink,'') <> ''
END

--Archive Deposits
INSERT INTO dbo.tblPcActivity(ProjectDetailId, Source, Type, Qty, ExtCost, ExtIncome, QtyBilled, ExtIncomeBilled, Description, AddnlDesc, ActivityDate, SourceReference, BillingReference, ResourceId, 
	LocId, Reference, DistCode, GLAcctWIP, GLAcctPayrollClearing, GLAcctIncome, GLAcctCost, GLAcctAdjustments, GLAcctFixedFeeBilling, GLAcctOverheadContra, GLAcctAccruedIncome, TaxClass, FiscalPeriod, FiscalYear, OverheadPosted, RateId, Uom, Status, BillOnHold, SourceId, GLAcct)
SELECT p.ProjectDetailId,4,4,0,0,j.DepositAmt,0,0,'Deposit',NULL,CAST(CONVERT(nvarchar(8), GETDATE(), 112) AS DATETIME),'Migration',NULL,j.CustId,NULL,'Deposit',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,MONTH(GETDATE()),YEAR(GETDATE()),0,NULL,NULL,2,0,NULL,NULL
FROM dbo.tblJcArcProject j INNER JOIN dbo.trav_PcProject_view p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName 
WHERE j.BilltoPhaseYn = 0 AND j.DepositAmt <> 0
UNION ALL 
SELECT p.ProjectDetailId,5,5,0,0,j.DepositApp,0,0,'Applied deposit',NULL,CAST(CONVERT(nvarchar(8), GETDATE(), 112) AS DATETIME),'Migration',NULL,j.CustId,NULL,'Applied Deposit',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,MONTH(GETDATE()),YEAR(GETDATE()),0,NULL,NULL,2,0,NULL,NULL
FROM dbo.tblJcArcProject j INNER JOIN dbo.trav_PcProject_view p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName 
WHERE j.BilltoPhaseYn = 0 AND j.DepositApp <> 0
UNION ALL
SELECT p.Id,4,4,0,0,j.DepositAmt,0,0,'Deposit',NULL,CAST(CONVERT(nvarchar(8), GETDATE(), 112) AS DATETIME),'Migration',NULL,j.CustId,NULL,'Deposit',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,MONTH(GETDATE()),YEAR(GETDATE()),0,NULL,NULL,2,0,NULL,NULL
FROM dbo.tblJcArcProjPhase j INNER JOIN dbo.trav_PcProjectTask_view p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName AND j.PhaseId = p.PhaseId AND j.PhaseId = p.TaskId 
WHERE j.DepositAmt <> 0
UNION ALL
SELECT p.Id,5,5,0,0,j.DepositApp,0,0,'Applied deposit',NULL,CAST(CONVERT(nvarchar(8), GETDATE(), 112) AS DATETIME),'Migration',NULL,j.CustId,NULL,'Applied Deposit',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,MONTH(GETDATE()),YEAR(GETDATE()),0,NULL,NULL,2,0,NULL,NULL
FROM dbo.tblJcArcProjPhase j INNER JOIN dbo.trav_PcProjectTask_view p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName AND j.PhaseId = p.PhaseId AND j.PhaseId = p.TaskId 
WHERE j.DepositApp <> 0

--PET:http://webfront:801/view.php?id=236479
--Archive Fixed Fee Billing
INSERT INTO dbo.tblPcActivity(ProjectDetailId, Source, Type, Qty, ExtCost, ExtIncome, QtyBilled, ExtIncomeBilled, Description, AddnlDesc, ActivityDate, SourceReference, BillingReference, ResourceId, 
	LocId, Reference, DistCode, GLAcctWIP, GLAcctPayrollClearing, GLAcctIncome, GLAcctCost, GLAcctAdjustments, GLAcctFixedFeeBilling, GLAcctOverheadContra, GLAcctAccruedIncome, TaxClass, FiscalPeriod, FiscalYear, OverheadPosted, RateId, Uom, Status, BillOnHold, SourceId, GLAcct)
SELECT p.ProjectDetailId,5,6,0,0,j.PTDBilled,0,0,'Fixed fee billing',NULL,CAST(CONVERT(nvarchar(8), GETDATE(), 112) AS DATETIME),'Migration',NULL,j.CustId,NULL,'Fixed fee billing',d.DistCode,c.GLAcctWIP, c.GLAcctPayrollClearing, c.GLAcctIncome, c.GLAcctCost, c.GLAcctAdjustments, 
	c.GLAcctFixedFeeBilling, c.GLAcctOverheadContra, c.GLAcctAccruedIncome,d.TaxClass,MONTH(GETDATE()),YEAR(GETDATE()),0,NULL,NULL,2,0,NULL,NULL
FROM dbo.tblJcArcProject j INNER JOIN dbo.trav_PcProject_view p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName 
	INNER JOIN dbo.tblPcProjectDetail d ON p.ProjectDetailId = d.Id 
	LEFT JOIN dbo.tblPcDistCode c ON d.DistCode = c.DistCode
WHERE j.BilltoPhaseYn = 0 AND j.PTDBilled <> 0 AND d.FixedFee = 1
UNION ALL 
SELECT p.Id,5,6,0,0,j.PTDBilled,0,0,'Fixed fee billing',NULL,CAST(CONVERT(nvarchar(8), GETDATE(), 112) AS DATETIME),'Migration',NULL,j.CustId,NULL,'Fixed fee billing',p.DistCode,c.GLAcctWIP, c.GLAcctPayrollClearing, c.GLAcctIncome, c.GLAcctCost, c.GLAcctAdjustments, 
	c.GLAcctFixedFeeBilling, c.GLAcctOverheadContra, c.GLAcctAccruedIncome,p.TaxClass,MONTH(GETDATE()),YEAR(GETDATE()),0,NULL,NULL,2,0,NULL,NULL
FROM dbo.tblJcArcProjPhase j INNER JOIN dbo.trav_PcProjectTask_view p ON j.CustId = p.CustId AND j.ProjId = p.ProjectName AND j.PhaseId = p.PhaseId AND j.PhaseId = p.TaskId 
	LEFT JOIN dbo.tblPcDistCode c ON p.DistCode = c.DistCode
WHERE j.PTDBilled <> 0 AND p.FixedFee = 1

--PO Transaction with project line item
DELETE dbo.tblSmTransLink WHERE [SourceType] = 3
DELETE 	dbo.tblSmTransID WHERE FunctionID = 'PCTRANS' 
if object_id('tempdb..#tmpPoTrans') is null
BEGIN
	CREATE TABLE #tmpPoTrans(Seqnum int IDENTITY(1,1) NOT NULL, TransId pTransId NOT NULL, EntryNum int NOT NULL)
END
TRUNCATE TABLE #tmpPoTrans
INSERT INTO #tmpPoTrans(TransId,EntryNum)
SELECT TransID, EntryNum
FROM dbo.tblPoTransDetail
WHERE CustID IS NOT NULL AND ProjID IS NOT NULL

if object_id('tempdb..#tmpPoTransRcpt') is null
BEGIN
	CREATE TABLE #tmpPoTransRcpt(RcptSeqnum int IDENTITY(1,1) NOT NULL, ReceiptID Uniqueidentifier NOT NULL)
END
TRUNCATE TABLE #tmpPoTransRcpt
INSERT INTO #tmpPoTransRcpt(ReceiptID)
SELECT r.ReceiptID
FROM dbo.tblPoTransDetail d INNER JOIN dbo.tblPoTransLotRcpt r ON d.TransID = r.TransId AND d.EntryNum = r.EntryNum
WHERE CustID IS NOT NULL AND ProjID IS NOT NULL

--Reset PC related fields
UPDATE dbo.tblPoTransDetail SET ProjectDetailId = NULL, ActivityId = NULL, [Type] = NULL, LinkSeqNum = NULL
WHERE CustID IS NOT NULL AND ProjID IS NOT NULL

UPDATE dbo.tblPoTransLotRcpt SET ActivityId = NULL
FROM dbo.tblPoTransDetail d INNER JOIN dbo.tblPoTransLotRcpt ON d.TransID = dbo.tblPoTransLotRcpt.TransId AND d.EntryNum = dbo.tblPoTransLotRcpt.EntryNum
WHERE CustID IS NOT NULL AND ProjID IS NOT NULL

DECLARE @Seqnum int, @RcptSeqnum int, @GlAcctCredit pGlAcct, @NextId int
SELECT @Seqnum = 1, @RcptSeqnum = 1

DECLARE @ConfigValue nvarchar(255) 
DECLARE @TransactionLink bit
EXEC dbo.glbSmGetSingleConfigValue_sp 'PO',null,'TransactionLink',@ConfigValue out 
SET @TransactionLink = CAST(ISNULL(@ConfigValue,'0') AS bit)

IF @TransactionLink = 1 --Create PO/PC link when business rule Transaction Link is Yes
BEGIN
	EXEC dbo.glbSmGetSingleConfigValue_sp 'JC',null,'CreditAcct',@ConfigValue out 

	SELECT @NextId = NextID FROM dbo.tblSmTransID
	WHERE FunctionID = 'PCTRANS' 

	SET @NextId = ISNULL(@NextId,1)

	WHILE EXISTS(SELECT * FROM #tmpPoTrans WHERE Seqnum = @Seqnum)
	BEGIN
		INSERT INTO dbo.tblPcTrans(Id, ProjectDetailId, ActivityId, TransType, BatchId, TransDate, FiscalYear, FiscalPeriod, ItemId, LocId, Description, AddnlDesc, QtyNeed, QtyFilled, Uom, UnitCost, Markup, GLAcct, TaxClass)
		SELECT @NextId, p.ProjectDetailId,0,0,'######',h.TransDate,YEAR(h.TransDate),MONTH(h.TransDate),d.ItemId,d.LocId,d.Descr,d.AddnlDescr,d.QtyOrd,0,d.Units,d.UnitCost,p.MaterialMarkup,@ConfigValue,d.TaxClass
		FROM #tmpPoTrans t INNER JOIN dbo.tblPoTransDetail d ON t.TransId = d.TransID AND t.EntryNum = d.EntryNum
			INNER JOIN dbo.trav_PcProject_view p ON d.CustID = p.CustId AND d.ProjID = p.ProjectName 
			INNER JOIN dbo.tblPoTransHeader h ON d.TransID = h.TransId 
		WHERE t.Seqnum = @Seqnum AND d.PhaseId IS NULL
		UNION ALL
		SELECT @NextId, p.Id,0,0,'######',h.TransDate,YEAR(h.TransDate),MONTH(h.TransDate),d.ItemId,d.LocId,d.Descr,d.AddnlDescr,d.QtyOrd,0,d.Units,d.UnitCost,p.MaterialMarkup,@ConfigValue,d.TaxClass
		FROM #tmpPoTrans t INNER JOIN dbo.tblPoTransDetail d ON t.TransId = d.TransID AND t.EntryNum = d.EntryNum
			INNER JOIN dbo.trav_PcProjectTask_view p ON d.CustID = p.CustId AND d.ProjID = p.ProjectName AND d.PhaseId = p.PhaseId AND d.PhaseId = p.TaskId
			INNER JOIN dbo.tblPoTransHeader h ON d.TransID = h.TransId 
		WHERE t.Seqnum = @Seqnum AND d.PhaseId IS NOT NULL AND d.TaskID IS NULL
		UNION ALL
		SELECT @NextId, p.Id,0,0,'######',h.TransDate,YEAR(h.TransDate),MONTH(h.TransDate),d.ItemId,d.LocId,d.Descr,d.AddnlDescr,d.QtyOrd,0,d.Units,d.UnitCost,p.MaterialMarkup,@ConfigValue,d.TaxClass
		FROM #tmpPoTrans t INNER JOIN dbo.tblPoTransDetail d ON t.TransId = d.TransID AND t.EntryNum = d.EntryNum
			INNER JOIN dbo.trav_PcProjectTask_view p ON d.CustID = p.CustId AND d.ProjID = p.ProjectName AND d.PhaseId = p.PhaseId AND d.TaskId = p.TaskId
			INNER JOIN dbo.tblPoTransHeader h ON d.TransID = h.TransId 
		WHERE t.Seqnum = @Seqnum AND d.TaskID IS NOT NULL

		INSERT INTO dbo.tblSmTransLink(SourceType, SourceId, DestType, DestId, DropShipYn)
		SELECT 3,@NextId,2, TransId, 1
		FROM #tmpPoTrans 
		WHERE Seqnum = @Seqnum

		UPDATE dbo.tblPoTransDetail SET LinkSeqNum = @@IDENTITY
		FROM dbo.tblPoTransDetail INNER JOIN #tmpPoTrans t ON dbo.tblPoTransDetail.TransID = t.TransId AND dbo.tblPoTransDetail.EntryNum = t.EntryNum
		WHERE t.Seqnum = @Seqnum
		
		UPDATE dbo.tblPoTransHeader SET DropShipYn = 1
		FROM dbo.tblPoTransHeader INNER JOIN #tmpPoTrans t ON dbo.tblPoTransHeader.TransID = t.TransId
		WHERE t.Seqnum = @Seqnum
		
		UPDATE dbo.tblPcTrans SET LinkSeqNum = @@IDENTITY
		WHERE Id = @NextId	
		
		SELECT @Seqnum = @Seqnum + 1, @NextId = @NextId + 1
	END

	IF EXISTS(SELECT * FROM dbo.tblSmTransID WHERE FunctionID = 'PCTRANS') 
		UPDATE dbo.tblSmTransID SET NextId = @NextId
		WHERE FunctionID = 'PCTRANS' 
	ELSE
		INSERT INTO dbo.tblSmTransID(FunctionID, NextID)
		VALUES('PCTRANS',@NextId)
END
ELSE
BEGIN
	WHILE EXISTS(SELECT * FROM #tmpPoTrans WHERE Seqnum = @Seqnum)
	BEGIN	
		--Update project
		UPDATE dbo.tblPoTransDetail SET ProjectDetailId = p.ProjectDetailId, [Type] = 1
		FROM dbo.tblPoTransDetail INNER JOIN #tmpPoTrans t ON dbo.tblPoTransDetail.TransID = t.TransId AND dbo.tblPoTransDetail.EntryNum = t.EntryNum
			INNER JOIN dbo.trav_PcProject_view p ON dbo.tblPoTransDetail.CustID = p.CustId AND dbo.tblPoTransDetail.ProjID = p.ProjectName 
		WHERE t.Seqnum = @Seqnum AND dbo.tblPoTransDetail.PhaseId IS NULL
	
		UPDATE dbo.tblPoTransDetail SET ProjectDetailId = p.Id, [Type] = 1
		FROM dbo.tblPoTransDetail INNER JOIN #tmpPoTrans t ON dbo.tblPoTransDetail.TransID = t.TransId AND dbo.tblPoTransDetail.EntryNum = t.EntryNum
			INNER JOIN dbo.trav_PcProjectTask_view p ON dbo.tblPoTransDetail.CustID = p.CustId AND dbo.tblPoTransDetail.ProjID = p.ProjectName AND dbo.tblPoTransDetail.PhaseId = p.PhaseId AND dbo.tblPoTransDetail.PhaseId = p.TaskId
		WHERE t.Seqnum = @Seqnum AND dbo.tblPoTransDetail.PhaseId IS NOT NULL AND dbo.tblPoTransDetail.TaskID IS NULL
		
		UPDATE dbo.tblPoTransDetail SET ProjectDetailId = p.Id, [Type] = 1
		FROM dbo.tblPoTransDetail INNER JOIN #tmpPoTrans t ON dbo.tblPoTransDetail.TransID = t.TransId AND dbo.tblPoTransDetail.EntryNum = t.EntryNum
			INNER JOIN dbo.trav_PcProjectTask_view p ON dbo.tblPoTransDetail.CustID = p.CustId AND dbo.tblPoTransDetail.ProjID = p.ProjectName AND dbo.tblPoTransDetail.PhaseId = p.PhaseId AND dbo.tblPoTransDetail.TaskId = p.TaskId
		WHERE t.Seqnum = @Seqnum AND dbo.tblPoTransDetail.TaskID IS NOT NULL	
		
		--On order activity
		INSERT INTO dbo.tblPcActivity(ProjectDetailId, [Source], [Type], Qty, ExtCost, ExtIncome, [Description], AddnlDesc, ActivityDate, SourceReference, ResourceId, 
			LocId, Reference, DistCode, GLAcctWIP, GLAcctPayrollClearing, GLAcctIncome, GLAcctCost, GLAcctAdjustments, GLAcctFixedFeeBilling, GLAcctOverheadContra, 
			GLAcctAccruedIncome, TaxClass, FiscalPeriod, FiscalYear, Uom, [Status])
		SELECT d.ProjectDetailId, 9, 1, SIGN(h.TransType) * CASE WHEN d.LineStatus = 0 AND d.QtyOrd > ISNULL(r.QtyRcpt,0) THEN d.QtyOrd - ISNULL(r.QtyRcpt,0) ELSE 0 END,
			SIGN(h.TransType) * ROUND(CASE WHEN d.LineStatus = 0 AND d.QtyOrd > ISNULL(r.QtyRcpt,0) THEN d.QtyOrd - ISNULL(r.QtyRcpt,0) ELSE 0 END * d.UnitCostFgn / h.ExchRate,2),
			SIGN(h.TransType) * ROUND(ROUND(CASE WHEN d.LineStatus = 0 AND d.QtyOrd > ISNULL(r.QtyRcpt,0) THEN d.QtyOrd - ISNULL(r.QtyRcpt,0) ELSE 0 END * d.UnitCostFgn / h.ExchRate,2) * (1 + p.MaterialMarkup / 100),2), 
			d.Descr, d.AddnlDescr, h.TransDate, d.TransID, d.ItemId, d.LocId, h.VendorId, p.DistCode, c.GLAcctWIP, c.GLAcctPayrollClearing, c.GLAcctIncome, c.GLAcctCost, 
			c.GLAcctAdjustments, c.GLAcctFixedFeeBilling, c.GLAcctOverheadContra, c.GLAcctAccruedIncome, d.TaxClass, 0, 0, d.Units, 0
		FROM dbo.tblPoTransDetail d INNER JOIN #tmpPoTrans t ON d.TransID = t.TransId AND d.EntryNum = t.EntryNum
			INNER JOIN dbo.tblPoTransHeader h ON d.TransID = h.TransId 
			INNER JOIN dbo.trav_PcProjectTask_view p ON d.ProjectDetailId = p.Id 
			LEFT JOIN dbo.tblPcDistCode c ON p.DistCode = c.DistCode 
			LEFT JOIN (SELECT  TransId, EntryNum, SUM(QtyFilled) QtyRcpt FROM dbo.tblPoTransLotRcpt GROUP BY TransId, EntryNum) r ON d.TransID = r.TransId AND d.EntryNum = r.EntryNum
		WHERE t.Seqnum = @Seqnum
		
		UPDATE dbo.tblPoTransDetail SET ActivityId = @@IDENTITY
		FROM dbo.tblPoTransDetail INNER JOIN #tmpPoTrans t ON dbo.tblPoTransDetail.TransID = t.TransId AND dbo.tblPoTransDetail.EntryNum = t.EntryNum
		WHERE t.Seqnum = @Seqnum	
	
		SET @Seqnum = @Seqnum + 1
	END
	
	WHILE EXISTS(SELECT * FROM #tmpPoTransRcpt WHERE RcptSeqnum = @RcptSeqnum)
	BEGIN
		--Receipt activity
		INSERT INTO dbo.tblPcActivity(ProjectDetailId, [Source], [Type], Qty, ExtCost, ExtIncome, [Description], AddnlDesc, ActivityDate, SourceReference, ResourceId, 
			LocId, Reference, DistCode, GLAcctWIP, GLAcctPayrollClearing, GLAcctIncome, GLAcctCost, GLAcctAdjustments, GLAcctFixedFeeBilling, GLAcctOverheadContra, 
			GLAcctAccruedIncome, TaxClass, FiscalPeriod, FiscalYear, Uom, [Status])
		SELECT d.ProjectDetailId, 11, 1, SIGN(h.TransType) * r.QtyFilled, SIGN(h.TransType) * r.ExtCost, SIGN(h.TransType) * ROUND(r.ExtCost * (1 + p.MaterialMarkup / 100),2), 
			d.Descr, d.AddnlDescr, e.ReceiptDate, d.TransID, d.ItemId, d.LocId, h.VendorId, p.DistCode, c.GLAcctWIP, c.GLAcctPayrollClearing, c.GLAcctIncome, c.GLAcctCost, 
			c.GLAcctAdjustments, c.GLAcctFixedFeeBilling, c.GLAcctOverheadContra, c.GLAcctAccruedIncome, d.TaxClass, e.GlPeriod, e.FiscalYear, d.Units, 1
		FROM dbo.tblPoTransLotRcpt r INNER JOIN #tmpPoTransRcpt t ON r.ReceiptID = t.ReceiptID
			INNER JOIN dbo.tblPoTransDetail d ON r.TransId = d.TransId AND r.EntryNum = d.EntryNum
			INNER JOIN dbo.tblPoTransHeader h ON d.TransID = h.TransId 
			INNER JOIN dbo.trav_PcProjectTask_view p ON d.ProjectDetailId = p.Id 
			INNER JOIN dbo.tblPoTransReceipt e ON r.TransId = e.TransID AND r.RcptNum = e.ReceiptNum
			LEFT JOIN dbo.tblPcDistCode c ON p.DistCode = c.DistCode 
		WHERE t.RcptSeqnum = @RcptSeqnum
		
		UPDATE dbo.tblPoTransLotRcpt SET ActivityId = @@IDENTITY
		FROM dbo.tblPoTransLotRcpt INNER JOIN #tmpPoTransRcpt t ON dbo.tblPoTransLotRcpt.ReceiptID = t.ReceiptID
		WHERE t.RcptSeqnum = @RcptSeqnum			
		
		SET @RcptSeqnum = @RcptSeqnum + 1
	END
END
--------------------------------
--User Field conversion to Custom Fields
--11/10/2009
--------------------------------
--delete work tables
--drop table #trxfr drop table #tst drop table #intrxfr drop table #bmtrxfr

Declare @curXmlReplace cursor
Declare @textVal nvarchar(max)
Declare @xmlVal nvarchar(max)

--build list of special xml characters
create table #xmlReplace (TextVal nvarchar(max), XMLVal nvarchar(max))
Insert into #xmlReplace(TextVal, XMLVal)
	Select '&', '&amp;'
	union all
	Select '<', '&lt;'
	union all
	Select '>', '&gt;'
	union all
	Select '"', '&quot;'
	union all
	Select '''', '&#39;'

--create work tables
create table #trxfr (
	Id int null, AppId nchar(2), FldNo tinyint, Lang nchar(3), FldCapt nvarchar(15), FldValue nvarchar(12) NULL, UsrFldReq bit default(0),
	FldCaptXML nvarchar(max), FldValueXML nvarchar(max)
	)

create table #tst (
	Ctr int identity(1,1), FldCapt nvarchar(15), UsrFldReq nvarchar(5), FldType nvarchar(12), FldVal nvarchar(12), FldNo int,
	MinVal nvarchar(10), MaxVal nvarchar(10), FldLen nvarchar(2) NULL, DDList nvarchar(max) NULL, AppId nchar(2), Id int NULL
	, FldCaptXML nvarchar(max), FldValXML nvarchar(max)
	)

create table #jctrxfr (
	ProjectDetailId int , UsrFld1 nvarchar(max), FldCapt1 nvarchar(max) NULL, UsrFld2 nvarchar(max), FldCapt2 nvarchar(max) NULL
	)

--build transfer detail table
insert into #trxfr (AppId, FldNo, Lang, FldCapt, FldValue, FldCaptXML, FldValueXML)
select b.AppId, b.FldNo, b.Lang, b.FldCapt, a.FldValue, b.FldCapt, a.FldValue
from dbo.tblSmUsrFld a 
right join dbo.tblSmUsrFldCapt b on a.appid = b.appid and a.fldno = b.fldno 
where b.AppId in ('JC') and b.FldCapt is not null

--replace special XML characters
Set @curXmlReplace = Cursor for Select TextVal, XMLVal From #xmlReplace
Open @curXmlReplace
fetch next from @curXmlReplace into @textVal, @xmlVal
While @@FETCH_STATUS = 0
Begin
	exec sp_ExecuteSQL N'Update #trxfr Set FldCaptXML = Replace(FldCaptXML, @TextVal, @XmlVal), FldValueXML = Replace(FldValueXML, @TextVal, @XmlVal)'
		, N'@TextVal nvarchar(max), @XmlVal nvarchar(max)', @TextVal, @xmlVal
		
	fetch next from @curXmlReplace into @textVal, @xmlVal
End
Close @curXmlReplace


--build transfer sum table
insert into #tst (FldCapt, UsrFldReq, FldType, FldVal, AppId, FldNo, FldCaptXML, FldValXML)
select distinct FldCapt, UsrFldReq, '0', Min(FldValue), AppId, FldNo
	, FldCaptXML, Min(FldValueXML)
from #trxfr group by FldCapt, UsrFldReq, AppId, FldNo, FldCaptXML

update #tst set Id = Ctr + a.id, 
	FldType = case when FldType = '1' then 'Number' else case when FldVal is null then 'Text' else 'List' end end, 
	UsrFldReq = case when UsrFldReq = 0 then 'false' else 'true' end, 
	FldLen = case when FldType = '0' and MinVal is null then '12' else '0' end, 
	MinVal = case when FldType = '1' then '-999999999' else 0 end,
	MaxVal = case when FldType = '1' then '999999999' else 0 end
from (select max(id) as id from dbo.tblSmCustomField) a

update #trxfr set Id = #tst.Id from #trxfr inner join #tst on #trxfr.FldCapt = #tst.FldCapt

declare @str as nvarchar(max), @id as int, @curid as int, @fldvalueXML as nvarchar(max)
set @str = ''
declare abc cursor for
select Id, FldValueXML from #trxfr order by Id
open abc
fetch next from abc into @id, @fldvalueXML
set @curid = @id
while @@fetch_status = 0
begin
		if @id = @curid
		begin
			if @str <> '' 
				select @str = @str + '<string>' + @fldvalueXML + '</string>'
			else
				select @str = '<string>' + @fldvalueXML + '</string>'
			update #tst set DDList = @str where Id = @id
		end
		else
		begin
			set @str = ''
			select @str = '<string>' + @fldvalueXML + '</string>'
			set @curId = @id
		end
		fetch next from abc into @id, @fldvalueXML
end		
close abc
deallocate abc

update #tst set DDList = '<DropDownList>' + DDList + '</DropDownList>' where DDList is not null
update #tst set DDList = '<DropDownList />' where DDList is null

--remove existing custom fields for recreation
delete dbo.tblSmCustomFieldEntity 
	Where EntityName = 'tblPcProjectDetail'
	
--update version 11 custom field tables
insert into dbo.tblSmCustomField (FieldName, [Definition])
select
	t.FldCapt, '<CustomField xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><FieldType>' + 
	t.FldType + '</FieldType><Description>' + t.FldCaptXML + '</Description><Required>' + 
	t.UsrFldReq + '</Required><MaxLength>' + 
	t.FldLen + '</MaxLength><LimitToList>' + Case When t.DDList is null then 'false' else 'true' end + '</LimitToList><MinValue>' +
	t.MinVal + '</MinValue><MaxValue>' +
	t.MaxVal + '</MaxValue>' + 
	t.DDList + '</CustomField>'
from #tst t left join dbo.tblSmCustomField s on t.FldCapt = s.FieldName 
where s.Id IS NULL

insert into dbo.tblSmCustomFieldEntity (FieldId, EntityName)
select b.Id, 'tblPcProjectDetail' 
from #tst a inner join dbo.tblSmCustomField b on a.FldCapt = b.FieldName

--build IN user fields assigned table
insert into #jctrxfr (ProjectDetailId, UsrFld1, UsrFld2)
select p.ProjectDetailId, j.UsrFld1, j.UsrFld2 
from dbo.tblJcProject j inner join dbo.trav_PcProject_view p on j.CustId = p.CustId and j.ProjId = p.ProjectName 
where j.UsrFld1 is not null or j.UsrFld2 is not null
union all
select p.Id, j.UsrFld1, j.UsrFld2 
from dbo.tblJcProjPhase j inner join dbo.trav_PcProjectTask_view p on j.CustId = p.CustId and j.ProjId = p.ProjectName and j.PhaseId = p.PhaseId and j.PhaseId = p.TaskId
where j.UsrFld1 is not null or j.UsrFld2 is not null
union all
select p.Id, j.UsrFld1, j.UsrFld2 
from dbo.tblJcProjTask j inner join dbo.trav_PcProjectTask_view p on j.CustId = p.CustId and j.ProjId = p.ProjectName and j.PhaseId = p.PhaseId and j.TaskId = p.TaskId
where j.UsrFld1 is not null or j.UsrFld2 is not null

--replace special XML characters
Set @curXmlReplace = Cursor for Select TextVal, XMLVal From #xmlReplace
Open @curXmlReplace
fetch next from @curXmlReplace into @textVal, @xmlVal
While @@FETCH_STATUS = 0
Begin
	exec sp_ExecuteSQL N'Update #jctrxfr 
		Set UsrFld1 = Replace(UsrFld1, @TextVal, @XmlVal)
		, UsrFld2 = Replace(UsrFld2, @TextVal, @XmlVal)'
		, N'@TextVal nvarchar(max), @XmlVal nvarchar(max)', @TextVal, @xmlVal
		
	fetch next from @curXmlReplace into @textVal, @xmlVal
End
Close @curXmlReplace

--set field captions
update #jctrxfr set FldCapt1 = FldCaptXML from #tst where AppId = 'JC' and FldNo = 1
update #jctrxfr set FldCapt2 = FldCaptXML from #tst where AppId = 'JC' and FldNo = 2

--update version 11 tables with assigned custom fields
update dbo.tblPcProjectDetail
set CF = 
		'<ArrayOfEntityPropertyOfString xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'
		+ case when a.UsrFld1 is not null then
			+ '<EntityPropertyOfString>'
			+ '<Name>' + a.FldCapt1 + '</Name>'
			+ '<Value>' + a.UsrFld1 + '</Value>'
			+ '</EntityPropertyOfString>'
			else '' end
		+ case when a.UsrFld2 is not null then
			+ '<EntityPropertyOfString>'
			+ '<Name>' + a.FldCapt2 + '</Name>'
			+ '<Value>' + a.UsrFld2 + '</Value>'
			+ '</EntityPropertyOfString>'
			else '' end
		+ '</ArrayOfEntityPropertyOfString>'
from #jctrxfr a 
inner join dbo.tblPcProjectDetail b on a.ProjectDetailId = b.Id

--rebuild views in tables
--mlc: 12/10/09 - skip if the proc doesn't exist (patch for SM executing post process before SPs)
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[trav_DSViewBuilder_Proc]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1) 
BEGIN
	exec dbo.Trav_DSViewBuilder_Proc 'tblPcProjectDetail'
END

drop table #xmlReplace
drop table #trxfr 
drop table #tst 
drop table #jctrxfr 

--Payroll transaction
UPDATE dbo.tblPaTransEarn SET ProjectDetailId = p.ProjectDetailId
FROM dbo.tblPaTransEarn INNER JOIN dbo.trav_PcProject_view p ON dbo.tblPaTransEarn.CustId = p.CustId AND dbo.tblPaTransEarn.ProjId = p.ProjectName
WHERE dbo.tblPaTransEarn.CustId IS NOT NULL AND dbo.tblPaTransEarn.ProjId IS NOT NULL AND dbo.tblPaTransEarn.PhaseId IS NULL

UPDATE dbo.tblPaTransEarn SET ProjectDetailId = p.Id
FROM dbo.tblPaTransEarn INNER JOIN dbo.trav_PcProjectTask_view p ON dbo.tblPaTransEarn.CustId = p.CustId AND dbo.tblPaTransEarn.ProjId = p.ProjectName AND dbo.tblPaTransEarn.PhaseId = p.PhaseId AND dbo.tblPaTransEarn.PhaseId = p.TaskId
WHERE dbo.tblPaTransEarn.CustId IS NOT NULL AND dbo.tblPaTransEarn.ProjId IS NOT NULL AND dbo.tblPaTransEarn.PhaseId IS NOT NULL AND dbo.tblPaTransEarn.TaskId IS NULL

UPDATE dbo.tblPaTransEarn SET ProjectDetailId = p.Id
FROM dbo.tblPaTransEarn INNER JOIN dbo.trav_PcProjectTask_view p ON dbo.tblPaTransEarn.CustId = p.CustId AND dbo.tblPaTransEarn.ProjId = p.ProjectName AND dbo.tblPaTransEarn.PhaseId = p.PhaseId AND dbo.tblPaTransEarn.TaskId = p.TaskId
WHERE dbo.tblPaTransEarn.CustId IS NOT NULL AND dbo.tblPaTransEarn.ProjId IS NOT NULL AND dbo.tblPaTransEarn.PhaseId IS NOT NULL AND dbo.tblPaTransEarn.TaskId IS NOT NULL

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'tsmPcMigrationStep3';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'tsmPcMigrationStep3';

