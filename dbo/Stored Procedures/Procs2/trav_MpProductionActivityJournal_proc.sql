
CREATE PROCEDURE dbo.trav_MpProductionActivityJournal_proc
@SortBy tinyint = 0,  -- 0 = Order Number / Release Number, 1 = Fiscal Year / Period
@DfltUnitOfTime smallint = 1 -- 1 = Hours, 60 = Minutes, 3600 = Seconds
AS
BEGIN TRY
	SET NOCOUNT ON

	/*
	Created the temp table to avoid overflow from mismatched type conversion & calculations.
	*/
	CREATE TABLE #temp
	(
		[GrpId1] nvarchar(255), 
		[GrpId2] nvarchar(255), 
		[OrderNo] pTransID NOT NULL, 
		[ReleaseNo] int NOT NULL, 
		[ReqId] int NOT NULL, 
		[Source] nvarchar(2) NOT NULL, 
		[Reference] pDescription NULL, 
		[GLAccountDebit] pGlAcct, 
		[GLAccountCredit] pGlAcct, 
		[FiscalPeriod] smallint NOT NULL, 
		[FiscalYear] smallint NOT NULL, 
		[TransDate] datetime NOT NULL, 
		[Qty] pDecimal NULL, 
		[QtyType] tinyint, 
		[UnitCost] pDecimal NULL, 
		[ExtCost] pDecimal
	)

	INSERT INTO #temp (GrpId1, GrpId2, OrderNo, ReleaseNo, ReqId, Source, Reference, GLAccountDebit, GLAccountCredit
		, FiscalPeriod, FiscalYear, TransDate, Qty, QtyType, UnitCost, ExtCost) 
	SELECT CASE @SortBy 
			WHEN 0 THEN g.OrderNo + RIGHT(REPLICATE('0',10) + CAST(g.ReleaseNo AS nvarchar), 10) 
			WHEN 1 THEN CAST(RIGHT('0000' + LTRIM(STR(g.FiscalYear)), 4) 
				+ RIGHT('000' + LTRIM(STR(g.GlPeriod)), 3) AS nvarchar)
			END AS GrpId1
		, CASE @SortBy 
			WHEN 0 THEN RIGHT(REPLICATE('0',10) + CAST(g.ReqId AS nvarchar), 10) 
			WHEN 1 THEN g.OrderNo + RIGHT(REPLICATE('0',10) + CAST(g.ReleaseNo AS nvarchar), 10) 
			END AS GrpId2
		, g.OrderNo, g.ReleaseNo, g.ReqId, g.Source
		, CASE WHEN g.Source = 0 THEN r.Description 
			WHEN Source IN(2, 3, 6, 7, 8, 9, 10) THEN t.EmployeeId 
			WHEN g.Source = 4 THEN s.VendorId 
			WHEN g.Source = 5 THEN m.ComponentId 
			ELSE NULL END AS Reference
		, g.GLAccountDebit, g.GLAccountCredit, g.GlPeriod AS FiscalPeriod, g.FiscalYear, g.TransDate
		, CASE WHEN g.Source = 2 
				THEN (t.MachineSetup / (CASE WHEN t.MachineSetupIn = 0 THEN 1 ELSE t.MachineSetupIn END) + 
					t.MachineRun / (CASE WHEN t.MachineRunIn = 0 THEN 1 ELSE t.MachineRunIn END)) * @DfltUnitOfTime 
			WHEN g.Source = 3
					THEN t.Labor / (CASE WHEN t.LaborIn = 0 THEN 1 ELSE t.LaborIn END) * @DfltUnitOfTime 
			WHEN g.Source = 10
					THEN t.LaborSetup / (CASE WHEN t.LaborSetupIn = 0 THEN 1 ELSE t.LaborSetupIn END) * @DfltUnitOfTime 
			WHEN g.Source = 4 THEN s.QtyReceived 
			WHEN g.Source IN (0, 5) THEN m.Qty 
			ELSE NULL END AS Qty
		, CASE WHEN g.Source IN(2, 3, 6, 7, 8, 9, 10) THEN 0 ELSE 1 END AS QtyType -- used for precision formatting on report (0 = Hours precision, 1 = Quantities precision)
		, CASE WHEN 
			(
				CASE WHEN g.Source = 2 
						THEN (t.MachineSetup / (CASE WHEN t.MachineSetupIn = 0 THEN 1 ELSE t.MachineSetupIn END) + 
							t.MachineRun / (CASE WHEN t.MachineRunIn = 0 THEN 1 ELSE t.MachineRunIn END)) * @DfltUnitOfTime 
					WHEN g.Source = 3
						THEN t.Labor / (CASE WHEN t.LaborIn = 0 THEN 1 ELSE t.LaborIn END) * @DfltUnitOfTime 
					WHEN g.Source = 10
						THEN t.LaborSetup / (CASE WHEN t.LaborSetupIn = 0 THEN 1 ELSE t.LaborSetupIn END) * @DfltUnitOfTime 
					WHEN g.Source = 4 THEN s.QtyReceived 
					WHEN g.Source IN (0, 5) THEN m.Qty 
					ELSE 0 END
			) <> 0 THEN g.Amount / 
					(
						CASE WHEN g.Source = 2 
								THEN (t.MachineSetup / (CASE WHEN t.MachineSetupIn = 0 THEN 1 ELSE t.MachineSetupIn END) + 
									t.MachineRun / (CASE WHEN t.MachineRunIn = 0 THEN 1 ELSE t.MachineRunIn END)) * @DfltUnitOfTime 
							WHEN g.Source = 3
									THEN t.Labor / (CASE WHEN t.LaborIn = 0 THEN 1 ELSE t.LaborIn END) * @DfltUnitOfTime 
							WHEN g.Source = 10
									THEN t.LaborSetup / (CASE WHEN t.LaborSetupIn = 0 THEN 1 ELSE t.LaborSetupIn END) * @DfltUnitOfTime 
							WHEN g.Source = 4 THEN s.QtyReceived 
							WHEN g.Source IN (0, 5) THEN m.Qty 
							ELSE NULL END
					) 
			END AS UnitCost
		, g.Amount AS ExtCost 
	FROM #tmpProductionActivity a 
		INNER JOIN dbo.tblMpGlTrans g ON g.EntryNum = a.EntryNum 
		LEFT JOIN dbo.tblMpMatlDtl m ON m.TransId = g.TransId AND m.SeqNo = g.SeqNo 
		LEFT JOIN dbo.tblMpRequirements r ON r.TransId = m.TransId
		LEFT JOIN dbo.tblMpTimeDtl t ON t.TransId = g.TransId AND t.SeqNo = g.SeqNo 
		LEFT JOIN dbo.tblMpSubContractDtl s ON s.TransId = g.TransId AND s.SeqNo = g.SeqNo

	SELECT * FROM #temp

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpProductionActivityJournal_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpProductionActivityJournal_proc';

