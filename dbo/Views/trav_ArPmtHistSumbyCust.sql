
CREATE VIEW [dbo].[trav_ArPmtHistSumbyCust]
AS
	SELECT p.CustId, p.FiscalYear, p.SumHistPeriod, p.CurrencyId    --dody
		, CAST(SUM(p.PmtAmt) AS float) TotPmts
		, CAST(SUM(p.PmtAmtFgn) AS float) TotPmtsFgn
		, CAST(SUM(p.DiffDisc) AS float) TotDisc
		, CAST(SUM(p.DiffDiscFgn) AS float) TotDiscFgn
		, CAST(SUM(CASE WHEN p.PmtAmt > 0 THEN 1 ELSE 0 END) AS int) NumPmt
		, CAST(SUM(CASE WHEN p.PmtDate > h.InvcDate THEN DATEDIFF(dy, h.InvcDate, p.PmtDate) ELSE 0 END) AS int) TotDaysToPay
		FROM dbo.tblArHistPmt p 
		LEFT JOIN (SELECT CustId, InvcNum, MAX(InvcDate) invcdate FROM dbo.tblArHistHeader WHERE TransType = 1
			GROUP BY Custid,InvcNum) h	ON p.CustId = h.CustId AND p.InvcNum = h.InvcNum
		INNER JOIN dbo.tblArCust c on c.Custid=p.CustID
	WHERE C.CcCompYn = 0
	GROUP BY p.CustId, p.FiscalYear, p.SumHistPeriod, p.CurrencyId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ArPmtHistSumbyCust';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ArPmtHistSumbyCust';

