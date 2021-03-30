
CREATE PROCEDURE dbo.trav_PsLayawayPost_History_proc
AS
SET NOCOUNT ON
BEGIN TRY
	--TODO: RewardRedemption
	DECLARE @PostRun pPostRun

	--Retrieve global values
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'

	IF @PostRun IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	INSERT INTO dbo.tblPsHistHeader (ID, TransIDPrefix, TransID, TransType, TransDate, SoldToID, BillToID, ShipToID, ShipVia, ShipNum, 
		TaxableYN, TaxExemptID, TaxGroupID, CurrencyID, SalesRepID, DueDate, VoidDate, UserID, HostID, EntryDate, SourceID, 
		Notes, CF, PostRun, DistCode, LocID, GLAcctReceivables, RewardNumber, CompletedDate, PONumber, PODate, ReqShipDate, iCap)
	SELECT h.ID, h.TransIDPrefix, h.TransID, h.TransType, h.TransDate, h.SoldToID, h.BillToID, h.ShipToID, h.ShipVia, h.ShipNum, h.TaxableYN, 
		h.TaxExemptID, h.TaxGroupID, h.CurrencyID, h.SalesRepID, h.DueDate, h.VoidDate, h.UserID, h.HostID, h.EntryDate, h.SourceID, h.Notes, 
		h.CF, @PostRun, t.DistCode, t.LocID, c.GLAcctReceivables, h.RewardNumber, h.CompletedDate, h.PONumber, h.PODate, h.ReqShipDate, iCap
	FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID 
		LEFT JOIN dbo.tblArDistCode c ON t.DistCode = c.DistCode							 

	INSERT INTO dbo.tblPsHistPayment (ID, HeaderID, PmtDate, CustID, PmtType, PmtMethodID, CcNum, CcHolder, CcExpire, CcAuth, CcRef, CheckNum, 
		BankName, BankRoutingCode, BankAcctNum, Amount, AmountBase, CurrencyID, VoidDate, UserID, HostID, EntryDate, Notes, CF, PostRun, LocID, 
		DistCode, GLAcctCash, GLAcct, Response)
	SELECT p.ID, p.HeaderID, p.PmtDate, p.CustID, p.PmtType, p.PmtMethodID, p.CcNum, p.CcHolder, p.CcExpire, p.CcAuth, p.CcRef, p.CheckNum, 
		p.BankName, p.BankRoutingCode, p.BankAcctNum, p.Amount, p.AmountBase, p.CurrencyID, p.VoidDate, p.UserID, p.HostID, p.EntryDate, p.Notes, 
		p.CF, @PostRun, t.LocID, t.DistCode, 
		CASE WHEN p.PmtType IN (1, 2, 6) THEN b.GlCashAcct ELSE m.GLAcctDebit END, --Use the bank gl account for Cash, Check and Direct Debit 
		c.GLAcctReceivables, p.Response
	FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsPayment p ON t.ID = p.HeaderID
		INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID 
		LEFT JOIN dbo.tblPsConfig g ON p.HostID = g.HostID
		LEFT JOIN dbo.tblArPmtMethod m ON p.PmtMethodID = m.PmtMethodID
		LEFT JOIN dbo.tblArDistCode c ON t.DistCode = c.DistCode	
		LEFT JOIN dbo.tblSmBankAcct b ON m.BankId = b.BankId

	INSERT INTO dbo.tblPsHistContact (ID, HeaderID, [Type], Name, Contact, Attn, Address1, Address2, City, Region, Country, PostalCode, Phone, Fax, 
		Email, Internet, CF)
	SELECT c.ID, c.HeaderID, c.[Type], c.Name, c.Contact, c.Attn, c.Address1, c.Address2, c.City, c.Region, c.Country, c.PostalCode, c.Phone, c.Fax, 
		c.Email, c.Internet, c.CF
	FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsTransContact c ON t.ID = c.HeaderID

	INSERT INTO dbo.tblPsHistTax (ID, HeaderID, TaxLocID, TaxClass, TaxLevel, TaxAmt, Taxable, NonTaxable, CF, GLAcctLiability)
	SELECT x.ID, x.HeaderID, x.TaxLocID, x.TaxClass, x.TaxLevel, x.TaxAmt, x.Taxable, x.NonTaxable, x.CF, l.GLAcct
	FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsTransTax x ON t.ID = x.HeaderID 
		LEFT JOIN dbo.tblSmTaxLoc l ON x.TaxLocID = l.TaxLocId

	INSERT INTO dbo.tblPsHistDetail (ID, HeaderID, ParentID, EntryNum, LineSeq, LineType, ItemID, LocID, LotNum, SerNum, Descr, TaxClass, 
		Qty, Unit, ExtPrice, TaxAmount, PromoID, SalesRepID, Notes, CF, GLAcct, GLAcctCOGS, GLAcctInv)
	SELECT d.ID, d.HeaderID, d.ParentID, d.EntryNum, d.LineSeq, d.LineType, d.ItemID, d.LocID, d.LotNum, d.SerNum, d.Descr, d.TaxClass, 
		d.Qty, d.Unit, d.ExtPrice, d.TaxAmount, d.PromoID, d.SalesRepID, d.Notes, d.CF, 
		CASE WHEN l.ItemId IS NOT NULL THEN g.GLAcctSales ELSE c.GLAcctSales END,
		CASE WHEN l.ItemId IS NOT NULL THEN g.GLAcctCogs ELSE c.GLAcctCogs END,
		CASE WHEN l.ItemId IS NOT NULL THEN g.GLAcctInv ELSE c.GLAcctInv END
	FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID 
		INNER JOIN dbo.tblPsTransDetail d ON h.ID = d.HeaderID 
		LEFT JOIN dbo.tblInItemLoc l ON d.ItemId = l.ItemId AND d.LocId = l.LocId
		LEFT JOIN dbo.tblInGLAcct g ON l.GLAcctCode = g.GLAcctCode
		LEFT JOIN dbo.tblPsDistCode c ON t.DistCode = c.DistCode
	WHERE d.LineType = 1 --Line Item
	UNION ALL
	SELECT d.ID, d.HeaderID, d.ParentID, d.EntryNum, d.LineSeq, d.LineType, d.ItemID, d.LocID, d.LotNum, d.SerNum, d.Descr, d.TaxClass, 
		d.Qty, d.Unit, d.ExtPrice, d.TaxAmount, d.PromoID, d.SalesRepID, d.Notes, d.CF, 
		CASE d.LineType WHEN 3 THEN c.GLAcctFreight WHEN 4 THEN c.GLAcctMisc WHEN -2 THEN e.GLAcctCoupon WHEN -3 THEN e.GLAcctDiscount
		WHEN -4 THEN e.GLAcctRounding END, NULL, NULL
	FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID 
		INNER JOIN dbo.tblPsTransDetail d ON h.ID = d.HeaderID 
		LEFT JOIN dbo.tblArDistCode c ON t.DistCode = c.DistCode
		LEFT JOIN dbo.tblPsDistCode e ON t.DistCode = e.DistCode 
	WHERE d.LineType IN (3, 4, -2, -3, -4) --Freight, Misc, Coupon, Discount, RoundingAdjust
	UNION ALL
	SELECT d.ID, d.HeaderID, d.ParentID, d.EntryNum, d.LineSeq, d.LineType, d.ItemID, d.LocID, d.LotNum, d.SerNum, d.Descr, d.TaxClass, 
		d.Qty, d.Unit, d.ExtPrice, d.TaxAmount, d.PromoID, d.SalesRepID, d.Notes, d.CF, NULL, NULL, NULL
	FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsTransDetail d ON t.ID = d.HeaderID 
	WHERE d.LineType IN (2, -1, 5) --Tax, Payment, Reward Accrual

	INSERT INTO dbo.tblPsHistDetailIN (DetailID, EntryDate, ExtCost, QtySeqNum_Cmtd, QtySeqNum, HistSeqNum, HistSeqNumSer, CF)
	SELECT i.DetailID, i.EntryDate, i.ExtCost, i.QtySeqNum_Cmtd, i.QtySeqNum, i.HistSeqNum, i.HistSeqNumSer, i.CF
	FROM #PsCompletedLayawayList t INNER JOIN dbo.tblPsTransDetail d ON t.ID = d.HeaderID 
		INNER JOIN dbo.tblPsTransDetailIN i ON d.ID = i.DetailID
	WHERE d.LineType = 1 --Line Item

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsLayawayPost_History_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsLayawayPost_History_proc';

