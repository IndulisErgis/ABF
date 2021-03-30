
CREATE PROCEDURE [dbo].[trav_TpAccountInformationView_proc]
@CustId pCustId -- =NULL

AS
BEGIN TRY
	SET NOCOUNT ON

SELECT p.[LastSaleInvc], p.[LastSaleDate], p.[CreditLimit], p.[TermsCode], p.[CurAmtDue], p.[NewFinch], p.[UnpaidFinch],
  p.[BalAge1], p.[BalAge2], p.[BalAge3], p.[BalAge4], p.[UnapplCredit],
  (p.[CurAmtDue] + p.[NewFinch] + p.[UnpaidFinch] + p.[BalAge1] + p.[BalAge2] + p.[BalAge3] + p.[BalAge4] - p.[UnapplCredit]) AS TotalDue
    FROM dbo.trav_tblArCust_view p
    where CustId = ISNULL(@CustId, CustId)
                              ORDER BY CustId Desc


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_TpAccountInformationView_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_TpAccountInformationView_proc';

