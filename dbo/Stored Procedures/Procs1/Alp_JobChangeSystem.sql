CREATE Procedure Alp_JobChangeSystem( @SysId int , @JobNum int) as 
BEGIN
--813-ChgJobSysId
UPDATE Alp_tblJmSvcTkt SET Alp_tblJmSvcTkt.SysId = @SysId
WHERE  Alp_tblJmSvcTkt.TicketId=@JobNum;

--814-ChgSysItems
UPDATE Alp_tblArAlpSiteSysItem SET Alp_tblArAlpSiteSysItem.SysId = @SysId
WHERE  Alp_tblArAlpSiteSysItem.TicketId =@JobNum;


END