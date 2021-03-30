Create PROCEDURE dbo.ALP_stpChkDupArAlpReplaceQtySiteSysItem      
(
 @SysItemId int,      
 @TicketID int       
)      
AS      
SELECT *
FROM ALP_tblArAlpReplaceQtySiteSysItem  
WHERE SysItemId=@SysItemId and TicketID= @TicketID