
Create View dbo.trav_ArOrgInvcInfo_view
AS
--MOD:Finance Charge Enhancements

--Note: Since records for a customer must be in either base or the customers currency 
--		we are able to properly sum the foreign amounts

--return the most current invoice record with the total balance due
Select o.Counter, o.CustId, o.InvcNum, o.DistCode, o.TransDate
	, tmp.BalDue, tmp.BalDueFgn, CurrencyId, ExchRate
	, o.DiscDueDate , tmp.BalDiscAmt, tmp.BalDiscAmtFgn
	From dbo.tblArOpenInvoice o
	Inner Join --isolate the last invoice record created on the latest date
	(Select c.CustId, c.InvcNum, Max(c.[Counter]) Counter
		, d.BalDue, d.BalDueFgn, d.BalDiscAmt, d.BalDiscAmtFgn
		From dbo.tblArOpenInvoice c 
		Inner Join --capture the balance due and the latest date for each invoice
		(Select CustId, InvcNum
			, Max(Case When RecType > 0 Then TransDate Else Null End) MaxTransDate
			, SUM(CASE WHEN RecType > 0 THEN Amt ELSE -Amt END) BalDue
			, SUM(CASE WHEN RecType > 0 THEN AmtFgn ELSE -AmtFgn END) BalDueFgn
			, SUM(CASE WHEN RecType > 0 THEN DiscAmt ELSE -DiscAmt END) BalDiscAmt
			, SUM(CASE WHEN RecType > 0 THEN DiscAmtFgn ELSE -DiscAmtFgn END) BalDiscAmtFgn
			From dbo.tblArOpenInvoice 
			Group By CustId, InvcNum) d
		on c.CustId = d.CustId and c.InvcNum = d.InvcNum And c.TransDate = d.MaxTransDate
		Where c.RecType > 0 And c.[Status] <> 4 --limit to unpaid invoice records
		Group by c.CustId, c.InvcNum, d.BalDue, d.BalDueFgn, d.BalDiscAmt, d.BalDiscAmtFgn
	) tmp
	on o.[Counter] = tmp.[Counter]
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ArOrgInvcInfo_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ArOrgInvcInfo_view';

