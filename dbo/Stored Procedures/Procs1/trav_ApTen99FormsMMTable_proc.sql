-- MOD: Add BankAccount filter
--PET:http://webfront:801/view.php?id=240607
CREATE PROCEDURE dbo.trav_ApTen99FormsMMTable_proc
@Year  Smallint = 2009

AS
SET NOCOUNT ON
DECLARE @StartDate datetime, @EndDate datetime

BEGIN TRY

    DELETE dbo.tblApTen99MMHeader

	DELETE dbo.tblApTen99Edit




	SET @StartDate = CAST(@year AS nvarchar) + '0101';
	SET @EndDate = CAST(@year + 1 AS nvarchar) + '0101';

    CREATE TABLE #ApTen99FormsRptSum (VendorID pVendorID,  TotalTen99Pmt pDecimal)

	INSERT INTO #ApTen99FormsRptSum(VendorID, TotalTen99Pmt)
	SELECT t.VendorId,
	       SUM(CASE WHEN ([h].[Ten99Amt] IS NOT NULL)
	                THEN  [h].[Ten99Amt]
	                WHEN ([c].[Ten99InvoiceYN] = 1)
	                THEN ([c].[GrossAmtDue] - [c].[DiscAmt])
		            ELSE 0 END) AS [TotalTen99Pmt]
	FROM #tmpVendorList t INNER JOIN dbo.tblApCheckHist c ON t.VendorId = c.VendorID
	LEFT JOIN [dbo].[tblApPaymentHistDetailTen99] [h]
	       ON ([h].[ID] = [c].[Counter])
	INNER JOIN #tmpBankAcctList b on  b.BankId = c.BankId 
	WHERE ((c.Ten99InvoiceYN = 1) OR (h.ID IS NOT NULL)) AND c.VoidYn = 0 AND c.CheckDate >= @StartDate AND c.CheckDate < @EndDate
	GROUP BY t.VendorId
	HAVING Sum(c.GrossAmtDue - c.DiscAmt) > 0
	
	INSERT INTO dbo.tblApTen99Edit (VendorID,[Name],Addr1,Addr2,City,Region,PostalCode,Ten99FormCode,AcctNo,
		Ten99RecipientID,Ten99FieldIndicator,Ten99ForeignAddrYN,SecondTINNotYN,Amount,NameControl,PayToName, FATCAFilingYN)
	SELECT v.VendorID,v.[Name],v.Addr1,v.Addr2,v.City,v.Region,v.PostalCode,v.Ten99FormCode,v.VendorID,
		v.Ten99RecipientID,v.Ten99FieldIndicator,v.Ten99ForeignAddrYN,v.SecondTINNotYN,
		t.TotalTen99Pmt,NULL,CASE WHEN v.[Name] <> v.PayToName THEN v.PayToName ELSE NULL END PayToName, 0
	FROM dbo.tblApVendor v INNER JOIN dbo.tblApTen99FieldIndic f ON v.Ten99FieldIndicator = f.IndicatorId  
		INNER JOIN #ApTen99FormsRptSum t ON v.VendorID = t.VendorID
	WHERE v.Ten99FormCode <> '0' AND t.TotalTen99Pmt >= f.Limit
	
	SELECT VendorID,[Name],Addr1,Addr2,City,Region,PostalCode,Ten99FormCode,AcctNo,
		Ten99RecipientID,Ten99FieldIndicator,Ten99ForeignAddrYN,SecondTINNotYN,Amount,NameControl,PayToName 
	FROM dbo.tblApTen99Edit

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApTen99FormsMMTable_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApTen99FormsMMTable_proc';

