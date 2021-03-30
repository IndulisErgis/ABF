
CREATE VIEW dbo.pvtPaCheckHistory
AS

SELECT c.PaYear, c.PaMonth, c.EmployeeId, c.CheckNumber, c.CheckDate
	, CASE WHEN c.Type = 0 THEN 'Check' ELSE 'Manual' END AS [Type]
	, c.GrossPay, c.NetPay, c.HoursWorked
	, CAST(c.VoucherNumber AS nvarchar (11)) AS VoucherNumber
	, (c.[NetPay] - ISNULL(dd.[DirectDepositAmount], 0)) AS [NetCheckAmount]
	, ISNULL(dd.DirectDepositAmount, 0.00) AS DirectDepositAmount 
FROM dbo.tblPaCheckHist c 
	LEFT JOIN 
			(
				SELECT PostRun, CheckId, SUM(CurrentAmount) AS DirectDepositAmount 
				FROM dbo.tblPaCheckHistDistribution 
				WHERE DirectDepositYN = 1 
				GROUP BY PostRun, CheckId
			) dd 
		ON c.PostRun = dd.PostRun AND c.Id = dd.CheckId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPaCheckHistory';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPaCheckHistory';

