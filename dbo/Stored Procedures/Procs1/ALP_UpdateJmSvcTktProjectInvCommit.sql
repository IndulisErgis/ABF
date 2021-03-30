Create PROCEDURE ALP_UpdateJmSvcTktProjectInvCommit        
(         
 @ProjectId varchar(10),
 @HoldProjInvCommitted bit       
)          
AS 
Update ALP_tblJmSvcTktProject
set  HoldProjInvCommitted=@HoldProjInvCommitted
where ProjectId=@ProjectId