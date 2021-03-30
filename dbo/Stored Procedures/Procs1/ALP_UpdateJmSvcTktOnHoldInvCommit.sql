          
Create PROCEDURE ALP_UpdateJmSvcTktOnHoldInvCommit       
(          
 @ProjectID varchar(10), 
 @HoldInvCommitted bit 
 )          
AS    
Update ALP_tblJmSvcTkt 
set  HoldInvCommitted=@HoldInvCommitted  
where ProjectID=@ProjectID and (Status<> 'Closed' AND Status <>'Completed' AND Status <>'Canceled')