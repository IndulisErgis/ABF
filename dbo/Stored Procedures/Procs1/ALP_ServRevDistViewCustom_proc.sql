 CREATE PROCEDURE [dbo].[ALP_ServRevDistViewCustom_proc] 
 (@Where nvarchar(1000)= NULL)
AS  
SET NOCOUNT ON;
DECLARE @str nvarchar(2000) = NULL  
BEGIN TRY  
	SET @str = ' SELECT LEFT(InvoiceDate,7) as InvcMonth, 
	h.GLAccount, g.[Desc] as GLAcctDescription,  
	h.ForYear,  h.ForPeriod,  h.Amount,  
    h.FromYear, h.FromPeriod, h.InvoiceDate, h.RunId  
		FROM #TransList t  
		INNER JOIN dbo.ALP_tblArAlpServRevDist h ON t.RunId = h.RunId 
		inner join tblGlAcctHdr g ON h.GLAccount = g.AcctId  ' 
		+ CASE WHEN @Where IS NULL THEN ' '
		WHEN @Where = '' THEN ' '
		WHEN @Where = ' ' THEN ' '
		ELSE ' WHERE ' + @Where
		END 
 execute (@str)
  
 SELECT d.RunId,   
 NextBillDate,  
 NewNextBillDate,  
 BatchCode,  
 InvoiceDate,  
 GLYear,  
 GLPeriod,  
 CustomerIdFrom,  
 CustomerIdTo,  
 BranchFrom,  
 BranchTo,  
 ClassFrom,  
 ClassTo,  
 GroupFrom,  
 GroupTo,  
 CreatedDate  
 FROM #TransList t  
  INNER JOIN dbo.ALP_tblArAlpRecBillRun d  ON t.RunId = d.RunId  
   
 SELECT d.RunId,   
 NextBillDate,  
 NewNextBillDate,  
 BatchCode,  
 InvoiceDate,  
 GLYear,  
 GLPeriod,  
 CustomerIdFrom,  
 CustomerIdTo,  
 BranchFrom,  
 BranchTo,  
 ClassFrom,  
 ClassTo,  
 GroupFrom,  
 GroupTo,  
 CreatedDate  
 FROM #TransList t  
  INNER JOIN dbo.ALP_tblArAlpRecBillRun d  ON t.RunId = d.RunId  

END TRY  
BEGIN CATCH  
 EXEC dbo.trav_RaiseError_proc  
END CATCH