create PROCEDURE dbo.ALP_qryJmSvcTkt_DependentTimecardItemsYN   
(  
 @ID int,  
 @Result bit = 0 output  
)  
As  
SET NOCOUNT ON  
SET @Result = 0  
if exists (SELECT ALP_tblJmTimeCard.TicketId  
  FROM ALP_tblJmTimeCard   
  WHERE ALP_tblJmTimeCard.TicketId = @ID )  
BEGIN  
 SET @Result = 1  
END  
ELSE  
BEGIN  
 SET @Result = 0  
END