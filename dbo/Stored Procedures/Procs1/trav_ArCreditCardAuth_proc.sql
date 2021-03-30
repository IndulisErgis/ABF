
CREATE PROCEDURE [dbo].[trav_ArCreditCardAuth_proc]

@optPrint tinyint = 1 -- 0-Authorization Needed; 1-Authorized; 2-All

AS
BEGIN TRY

	SELECT COALESCE(InvcTransID, CAST(r.RcptHeaderID AS nvarchar))  AS TransId, c.CustName, r.CustId,
		r.CcHolder, r.PmtMethodId, r.CcNum, r.CcExpire, CAST(r.PmtAmt/r.ExchRate AS Decimal(28,10)) PmtAmt, r.CcAuth, 
		CASE WHEN InvcTransID IS NULL THEN 0
			 WHEN InvcAppID = 'AR' THEN 1 
			 WHEN InvcAppID = 'SO' THEN 2 
		END AS CashRcptType --0;Cash Receipt;1;AR Trans;2;SO Trans
	FROM dbo.tblArCashRcptHeader r 
		INNER JOIN dbo.tblArCust c ON r.CustId = c.CustId 
		INNER JOIN dbo.tblArPmtMethod p ON r.PmtMethodId = p.PmtMethodId
		INNER JOIN #tmpCashReceiptList t ON r.RcptHeaderID = t.RcptHeaderID
	WHERE p.PmtType = 3 
		AND ((@optPrint = 2) OR (@optPrint = 0 AND (r.CcAuth IS NULL OR r.CcAuth = '')) OR (@optPrint = 1 AND (r.CcAuth IS NOT NULL AND r.CcAuth <> ''))) 		

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCreditCardAuth_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCreditCardAuth_proc';

