
CREATE PROCEDURE dbo.trav_PcOhAllocPost_UpdateActivity_proc
@Overwrite bit,
@TransDate datetime,
@FiscalYear smallint,
@FiscalPeriod smallint
AS
BEGIN TRY

	IF @Overwrite = 1 --update transaction date, fiscal year, fiscal period if overwrite option is yes
	BEGIN
		UPDATE dbo.tblPcPrepareOverhead SET TransDate = ISNULL(@TransDate, TransDate),
			FiscalYear = ISNULL(@FiscalYear,FiscalYear), FiscalPeriod = ISNULL(@FiscalPeriod,FiscalPeriod)
		FROM dbo.tblPcPrepareOverhead INNER JOIN #PostTransList t ON dbo.tblPcPrepareOverhead.Id = t.TransId
	END
	
	--accumulate posted overhead
	UPDATE dbo.tblPcActivity SET OverheadPosted = OverheadPosted + o.CurrOH
	FROM dbo.tblPcActivity INNER JOIN dbo.tblPcPrepareOverhead o ON dbo.tblPcActivity.Id = o.ActivityId
		INNER JOIN #PostTransList t ON o.Id = t.TransId
		
	--create activity records with unposted status for overhead
	INSERT INTO dbo.tblPcActivity(ProjectDetailId, [Source], [Type], ExtCost, [Description], ActivityDate, Reference,
		DistCode, GLAcctWIP, GLAcctPayrollClearing, GLAcctIncome, GLAcctCost, GLAcctAdjustments, GLAcctFixedFeeBilling, 
		GLAcctOverheadContra, GLAcctAccruedIncome, TaxClass, FiscalPeriod, FiscalYear, [Status])
	SELECT p.ProjectDetailId, 2, p.[Type], p.CurrOH, 'Overhead allocation', p.TransDate, 'OH', d.DistCode, 
		c.GLAcctWIP, c.GLAcctPayrollClearing, c.GLAcctIncome, c.GLAcctCost, c.GLAcctAdjustments, c.GLAcctFixedFeeBilling,
		c.GLAcctOverheadContra, c.GLAcctAccruedIncome, d.TaxClass, p.FiscalPeriod, p.FiscalYear, 1
	FROM
	(SELECT a.ProjectDetailId, a.[Type], o.TransDate, o.FiscalYear, o.FiscalPeriod, SUM(o.CurrOH) AS CurrOH
	FROM dbo.tblPcPrepareOverhead o INNER JOIN dbo.tblPcActivity a ON o.ActivityId = a.Id 
		INNER JOIN #PostTransList t ON o.Id = t.TransId
	GROUP BY a.ProjectDetailId, a.[Type], o.TransDate, o.FiscalYear, o.FiscalPeriod) p INNER JOIN dbo.tblPcProjectDetail d ON p.ProjectDetailId = d.Id 
		INNER JOIN dbo.tblPcDistCode c ON d.DistCode = c.DistCode
	
	--get id of overhead activity record
	INSERT INTO #tmpOverhead(OverheadId, ActivityId)
	SELECT o.Id, MAX(v.Id)
	FROM dbo.tblPcPrepareOverhead o INNER JOIN #PostTransList t ON o.Id = t.TransId 
		INNER JOIN dbo.tblPcActivity a ON o.ActivityId = a.Id 
		INNER JOIN dbo.tblPcActivity v ON a.ProjectDetailId = v.ProjectDetailId AND a.[Type] = v.[Type] AND 
			o.TransDate = v.ActivityDate AND o.FiscalYear = v.FiscalYear AND o.FiscalPeriod = v.FiscalPeriod
	WHERE v.[Source] = 2 AND v.[Status] = 1
	GROUP BY o.Id
	
	--update status of overhead activity record to posted
	UPDATE dbo.tblPcActivity SET [Status] = 2
	WHERE [Source] = 2 AND [Status] = 1
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcOhAllocPost_UpdateActivity_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcOhAllocPost_UpdateActivity_proc';

