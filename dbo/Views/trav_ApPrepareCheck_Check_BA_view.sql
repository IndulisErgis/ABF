
Create View dbo.trav_ApPrepareCheck_Check_BA_view
AS
	SELECT d.Counter, d.VendorID, d.CheckNum, d.CheckAmt, d.DiscTaken, d.DiscLost, d.Ten99Pmt, d.CheckAmtFgn, 
		d.DiscTakenFgn, d.DiscLostFgn, d.Ten99PmtFgn, d.CheckDate, d.GLCashAcct, d.CurrencyId, d.CalcGainLoss, 
		d.GLAccGainLoss, d.GrpID, d.BatchID, d.DeliveryType, d.BankAcctNum, d.RoutingCode, 
		CASE WHEN a.AcctType = 0 AND d.DeliveryType = 1 THEN 1 WHEN a.AcctType = 1 THEN 2 ELSE 0 END AS PmtDeliType, -- 0,Check; 1,EFT; 2,Credit Card
		c.TransmitDate, a.OurAcctNum AS OurBankAcctNum
	FROM dbo.tblApPrepChkCntl c INNER JOIN dbo.tblApPrepChkCheck d  ON c.BatchId = d.BatchId
	INNER JOIN dbo.tblSmBankAcct a  ON c.BankId = a.BankId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ApPrepareCheck_Check_BA_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ApPrepareCheck_Check_BA_view';

