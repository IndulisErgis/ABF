
CREATE PROCEDURE [dbo].[trav_TpOpenInvoiceView_proc]
@CustId pCustId -- =NULL
,@InvcNum pInvoiceNum 

AS
BEGIN TRY
	SET NOCOUNT ON
SELECT * FROM (SELECT p.[CustId], p.[InvcNum], p.[RecType], p.[Status], p.[TransDate], p.[NetDueDate], p.[DiscDueDate], SIGN(p.[RecType]) * p.[AmtFgn] AS [AmtFgn], SIGN(p.[RecType]) * p.[DiscAmtFgn] AS [DiscAmtFgn],
 p.[CheckNum], p.[CustPONum]	FROM dbo.trav_tblArOpenInvoice_view p WHERE p.[Status] <> 4) ds
 where CustId = ISNULL(@CustId, CustId) and InvcNum = @InvcNum
                              ORDER BY CustId Desc

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_TpOpenInvoiceView_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_TpOpenInvoiceView_proc';

