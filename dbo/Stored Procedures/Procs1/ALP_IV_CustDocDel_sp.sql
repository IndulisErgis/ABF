    
CREATE PROCEDURE [dbo].[ALP_IV_CustDocDel_sp]         
--Created 08/11/16 by MAH        
(        
  @Where nvarchar(1000)= NULL          
  )        
AS            
SET NOCOUNT ON;          
DECLARE @str nvarchar(2000) = NULL            
BEGIN TRY          
SELECT C.CustId, C.CustName, Status = CASE WHEN C.Status = 0 THEN 'Active' ELSE 'Inactive' END, AC.AlpFirstName as FirstName,
--DD.FormId, DD.ContactType, 
DD.FormId AS 'Document', 
Method = CASE WHEN DD.DeliveryType is null THEN ''
		 WHEN DD.DeliveryType = 1 THEN 'Email'
		 WHEN DD.DeliveryType = 2 THEN 'Fax' ELSE '' END, 
DD.DeliveryName AS 'DisplayName', 
DD.DeliveryDestination AS 'DeliverTo', 
DD.DeliveryNote AS 'Subject', 
AttachmentFormat = CASE WHEN DD.EmailAttachmentFormat = 3 THEN 'PDF'
		 WHEN EmailAttachmentFormat = 1 THEN 'Image' ELSE '' END,
DD.DeliveryType,
DD.DeliveryNote,DD.EmailAttachmentFormat, C.AcctType, C.GroupCode INTO #temp
FROM dbo.tblArCust C inner join dbo.ALP_tblArCust AC ON C.CustId = AC.AlpCustId
LEFT OUTER JOIN  dbo.tblSmDocumentDelivery DD ON C.CustId = DD.ContactId
WHERE DD.ContactType = 0 OR DD.ContactType is null  
   
 SET @str =          
'SELECT CustId, CustName, FirstName,  Status, Document, Method, DisplayName, DeliverTo, Subject, AttachmentFormat,GroupCode  
FROM #temp '  + CASE WHEN @Where IS NULL THEN ' '          
  WHEN @Where = '' THEN ' '          
  WHEN @Where = ' ' THEN ' '          
  ELSE ' WHERE ' + @Where          
  END  + ' '         
        
 execute (@str)         
 DROP TABLE #temp        
 END TRY            
BEGIN CATCH          
 DROP TABLE #temp          
 EXEC dbo.trav_RaiseError_proc            
END CATCH