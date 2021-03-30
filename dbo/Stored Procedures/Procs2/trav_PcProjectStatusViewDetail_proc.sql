
CREATE PROCEDURE dbo.trav_PcProjectStatusViewDetail_proc 
@Prec tinyint = 2,
@ProjectDetailId int
AS
BEGIN TRY
DECLARE @typeCounter tinyint
SET NOCOUNT ON

CREATE TABLE #tmpProjectStatus
(
	ProjectDetailId int NOT NULL,
	[Type] tinyint NOT NULL,
	[EstimateAmount] Decimal(28,3) NOT NULL DEFAULT(0),
	[EstimateQty] Decimal(28,3) NOT NULL DEFAULT(0),
	[BilledAmount] Decimal(28,3) NOT NULL DEFAULT(0),
	[ActualQty] Decimal(28,3) NOT NULL DEFAULT(0)
	CONSTRAINT [PK_#tmpProjectStatus] PRIMARY KEY CLUSTERED ([ProjectDetailId],[Type]) ON [PRIMARY] 
)

SET @typeCounter = 0

WHILE @typeCounter < 4
BEGIN
	--Activity type is Time,Material,Expense,Other
	INSERT INTO #tmpProjectStatus(ProjectDetailId, [Type])
	SELECT @ProjectDetailId, @typeCounter
	SET @typeCounter = @typeCounter + 1
END

--Estimate
UPDATE #tmpProjectStatus SET EstimateAmount = e.EstimateAmount, EstimateQty = e.EstimateQty
FROM #tmpProjectStatus INNER JOIN (SELECT d.Id, e.[Type], SUM(CASE d.Billable WHEN 1 THEN ROUND(e.Qty * e.UnitPrice,@Prec)  ELSE 0 END) AS EstimateAmount,
		 SUM(e.Qty) AS EstimateQty
	FROM dbo.tblPcProjectDetail d INNER JOIN dbo.tblPcEstimate e ON d.Id = e.ProjectDetailId
	GROUP BY d.Id, e.[Type]) e ON #tmpProjectStatus.ProjectDetailId = e.Id AND #tmpProjectStatus.[Type] = e.[Type]

--Project to Date income
UPDATE #tmpProjectStatus SET BilledAmount = e.BilledAmount, ActualQty = e.ActualQty
FROM #tmpProjectStatus INNER JOIN (SELECT d.Id, a.[Type], SUM(CASE WHEN d.FixedFee = 1 OR a.[Status] <> 4 THEN 0 ELSE a.ExtIncomeBilled END) AS BilledAmount, SUM(a.Qty) AS ActualQty 
	FROM dbo.tblPcProjectDetail d INNER JOIN 
		(SELECT ProjectDetailId, [Type], ExtIncomeBilled, Qty, [Status] FROM dbo.tblPcActivity WHERE [Type] BETWEEN 0 AND 3 AND [Status] BETWEEN 1 AND 5 --Activity type is Time,Material,Expense,Other, status is unposted,posted,wip,billed,completed
			--back off po invoice
			UNION ALL SELECT ProjectDetailId, [Type], 0, -Qty, [Status] FROM dbo.tblPcActivity WHERE [Source] = 12 AND [Type] BETWEEN 0 AND 3 AND [Status] BETWEEN 1 AND 5) a ON d.Id = a.ProjectDetailId --Activity type is Time,Material,Expense,Other, status is unposted,posted,wip,billed,completed
	WHERE d.Id = @ProjectDetailId GROUP BY d.Id, a.[Type]) e ON #tmpProjectStatus.ProjectDetailId = e.Id AND #tmpProjectStatus.[Type] = e.[Type]

SELECT [Type], EstimateAmount, EstimateQty, BilledAmount, ActualQty
FROM #tmpProjectStatus

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcProjectStatusViewDetail_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcProjectStatusViewDetail_proc';

