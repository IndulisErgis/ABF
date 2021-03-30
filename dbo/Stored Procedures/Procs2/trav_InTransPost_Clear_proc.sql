
CREATE PROCEDURE dbo.trav_InTransPost_Clear_proc
AS
BEGIN TRY
	--PONewOrder = 11 
	--POGoodsRcvd = 12 
	--POInvoice = 14 
	--POMiscDebit = 15
	--SONewOrder = 21
	--SOVerifyOrder = 23
	--SOInvoice = 24
	--SOMiscCredit = 25
	--Increase = 31
	--Decrease = 32
	UPDATE dbo.tblInQty SET Qty = 0  
	FROM dbo.tblInQty INNER JOIN dbo.tblInTrans t ON dbo.tblInQty.SeqNum = t.QtySeqNum 
		INNER JOIN #PostTransList p ON t.TransId = p.TransId
	WHERE t.TransType IN (11,21)

	DELETE FROM dbo.tblInTransLot
		WHERE TransId IN (SELECT TransId FROM #PostTransList)

	DELETE FROM dbo.tblInTransSer
		WHERE TransId IN (SELECT TransId FROM #PostTransList)

	DELETE FROM dbo.tblInTrans
		WHERE TransId IN (SELECT TransId FROM #PostTransList)

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InTransPost_Clear_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InTransPost_Clear_proc';

