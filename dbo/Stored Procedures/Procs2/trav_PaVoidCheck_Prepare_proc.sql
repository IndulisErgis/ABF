
CREATE PROCEDURE dbo.trav_PaVoidCheck_Prepare_proc
AS
BEGIN TRY
--PET:http://webfront:801/view.php?id=227706
--PET:http://webfront:801/view.php?id=228242
--PET:http://webfront:801/view.php?id=234984

--list of check entries to process
--CREATE TABLE #VoidCheckList(
--	[PostRun] [pPostRun] NOT NULL, 
--	[Id] [int] NOT NULL, 
--	[BankId] [pBankId], 
--	[BankGlAcct] [pGlAcct] 
--	PRIMARY KEY ([PostRun], [Id])
--)

--detail list/log of the checks processed
--CREATE TABLE #VoidCheckLog (
--    [PostRun] [pPostRun] Not Null, 
--    [Id] [int] Not Null, 
--    [Status] [int] Not Null, --Void process status/Enum: 0=OK, -1=Invalid
--    [EmployeeId] [pEmpID] Null, 
--    [EmployeeName] [nvarchar](36) Null, 
--    [CheckNumber] [pCheckNum] Null, 
--    [VoucherNumber] nvarchar(50) Null,
--    [UseCheckNum] pCheckNum Null, 
--    [CheckDate] datetime Null, 
--    [Type] [tinyint] Null, 
--    [NetPay] [pDec] Null, 
--    [GrossPay] [pDec] Null, 
--    [CheckAmount] [pDec] Null, 
--    [VoucherAmount] [pDec] Null, 
--    [VoidBankId] pBankID Null, 
--    [PaMonth] smallint Null, 
--    PRIMARY KEY ([PostRun], [Id])
--)

	DECLARE @BrYN bit
       
	SELECT @BrYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'BrYn'
       
	IF @BrYn IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END


	--populate the detail list/log of entries to process
	INSERT INTO #VoidCheckLog ([PostRun], [Id], [Status], [EmployeeId], [EmployeeName]
		, [CheckNumber], [VoucherNumber], [UseCheckNum], [CheckDate], [Type]
		, [NetPay], [GrossPay], [CheckAmount], [VoucherAmount]
		, [VoidBankId], [PaMonth])
	SELECT h.[PostRun], h.[Id], 0, h.[EmployeeId], h.[EmployeeName]
		, h.[CheckNumber], h.[VoucherNumber], ISNULL(h.[CheckNumber], '0000000'), h.[CheckDate], h.[Type]
		, h.[NetPay], h.[GrossPay], (h.[NetPay] - ISNULL(d.[VoucherAmount], 0)), ISNULL(d.[VoucherAmount], 0)
		, l.[BankId], h.[PaMonth]
	FROM dbo.tblPaCheckHist h
	INNER JOIN #VoidCheckList l ON h.[PostRun] = l.[PostRun] AND h.[Id] = l.[Id]
	LEFT JOIN (
		SELECT p.[PostRun], p.[CheckId], SUM(p.[CurrentAmount]) AS [VoucherAmount]
		FROM dbo.tblPaCheckHistDistribution p
		INNER JOIN #VoidCheckList l ON p.[PostRun] = l.[PostRun] AND p.[CheckId] = l.[Id]
		WHERE p.[DirectDepositYN] = 1
		GROUP BY p.[PostRun], p.[CheckId]
	) d ON h.[PostRun] = d.[PostRun] AND h.[Id] = d.[CheckId]


	--invalidate entries that cannot be voided in BR
	--(those that do not exist or have been cleared)
	--(excluding those with a 0 check amount since they do not have BR entries)
	IF @BrYn = 1
	BEGIN
		UPDATE #VoidCheckLog SET [Status] = -1
		WHERE #VoidCheckLog.[CheckAmount] <> 0
		AND NOT EXISTS (
			SELECT 1 FROM dbo.tblBrMaster m
			WHERE m.SourceApp = 'PA' 
				AND m.TransType = -1
				AND m.ClearedYn = 0
				AND m.BankID = #VoidCheckLog.VoidBankId
				AND m.TransDate = #VoidCheckLog.CheckDate
				AND ((m.SourceID = #VoidCheckLog.CheckNumber AND m.Reference = #VoidCheckLog.EmployeeId) --full match on check number and employee id
					OR 
					(ISNULL(m.SourceID, 'ACH') = 'ACH' AND m.Reference = 'Payroll' AND #VoidCheckLog.VoucherAmount <> 0)) --match for direct deposit payment
				)
	END


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaVoidCheck_Prepare_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaVoidCheck_Prepare_proc';

