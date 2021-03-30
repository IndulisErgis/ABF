CREATE PROCEDURE [dbo].[ALP_qryJm110d00DocDel_sp]  
/* RecordSource for Document Delivery  subform of Control Center */  
(  
 @CCcustID pcustID = null  
)  
AS  
SELECT  FormId AS 'Document', 
	Method = CASE WHEN DeliveryType = 1 THEN 'Email'
		 WHEN DeliveryType = 2 THEN 'Fax' ELSE 'Unknown' END, 
	DeliveryName AS 'DisplayName', 
	DeliveryDestination AS 'DeliverTo', DeliveryNote AS 'Subject', 
	AttachmentFormat = CASE WHEN EmailAttachmentFormat = 3 THEN 'PDF'
		 WHEN EmailAttachmentFormat = 1 THEN 'Image' ELSE 'Unknown' END
FROM         tblSmDocumentDelivery
WHERE     (ContactType = 0) AND (ContactId = @CCcustID)
ORDER BY FormId, DeliveryDestination