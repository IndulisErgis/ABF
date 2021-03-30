
CREATE PROCEDURE dbo.trav_ArCreditCardList_proc
@PrintOption tinyint = 0, -- 0, All; 1, Expired;
@ExpiredDate datetime = '20090112'
AS
SET NOCOUNT ON
BEGIN TRY

	SELECT c.CustId, CustName, Contact, Phone, ClassId, Country, Descr, p.CcNum, p.CcName, p.CcExpire 
	FROM #tmpCustomerList t INNER JOIN dbo.tblArCust c ON t.CustId = c.CustId
		INNER JOIN dbo.tblArCustPmtMethod p ON c.CustId = p.CustId
	WHERE ISNULL(CcNum, '') <> '' AND (@PrintOption = 0 OR p.CcExpire < @ExpiredDate)

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCreditCardList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCreditCardList_proc';

