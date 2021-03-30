
CREATE Procedure [dbo].[ALP_qryJmUpdateAllSvcTktStatus]  
--@ID int  
--Below @UserID added by NSK on 10 Apr 2015
@UserID varchar(50)
AS  
--Below @UserID renamed as @CurrentUserID by NSK on 10 Apr 2015
--modified to take Alpine userID length of 50 from 20, mah 05/05/17

--Below 2 lines commented by NSK on 13 Apr 2015
--start
--DECLARE @CurrentUserID pUserId, @WrkStnID pWrkStnId  
--EXEC dbo.ALP_currentuser @CurrentUserID OUT, @WrkStnId OUT  
--end
SET NOCOUNT ON  
--Scheduled  
UPDATE ALP_tblJmSvcTkt   
SET ALP_tblJmSvcTkt.Status = 'Scheduled', ALP_tblJmSvcTkt.RevisedDate = GetDate(), ALP_tblJmSvcTkt.RevisedBy = @UserId  
FROM ALP_tblJmSvcTkt INNER JOIN ALP_tblJmTimeCard ON ALP_tblJmSvcTkt.TicketId = ALP_tblJmTimeCard.TicketId   
WHERE (ALP_tblJmSvcTkt.Status='New' Or ALP_tblJmSvcTkt.Status='Targeted') --AND ALP_tblJmSvcTkt.TicketId <> @ID  
--Targeted  
UPDATE ALP_tblJmSvcTkt   
SET ALP_tblJmSvcTkt.Status = 'Targeted', ALP_tblJmSvcTkt.RevisedDate = GetDate(), ALP_tblJmSvcTkt.RevisedBy = @UserId, ALP_tblJmSvcTkt.ReschDate = Null  
FROM ALP_tblJmSvcTkt LEFT JOIN ALP_tblJmTimeCard ON ALP_tblJmSvcTkt.TicketId = ALP_tblJmTimeCard.TicketId   
--Below where condition modified by MAH and NSK on 10 Apr 2015
--start
WHERE ALP_tblJmSvcTkt.Status='Scheduled' AND ALP_tblJmSvcTkt.PrefDate Is Not Null
 AND (ALP_tblJmTimeCard.TicketId Is Null --AND ALP_tblJmSvcTkt.TicketId <> @ID 
 OR  (ALP_tblJmTimeCard.TicketId is not null  AND
 ALP_tblJmSvcTkt.PrefDate > (select MAX(StartDate) from ALP_tblJmTimeCard 
 where ALP_tblJmSvcTkt.TicketId=ALP_tblJmTimeCard.TicketId))) 
 --end 
--New  
UPDATE ALP_tblJmSvcTkt   
SET ALP_tblJmSvcTkt.Status = 'New', ALP_tblJmSvcTkt.RevisedDate = GetDate(), ALP_tblJmSvcTkt.RevisedBy = @UserId, ALP_tblJmSvcTkt.ReschDate = Null  
FROM ALP_tblJmSvcTkt LEFT JOIN ALP_tblJmTimeCard ON ALP_tblJmSvcTkt.TicketId = ALP_tblJmTimeCard.TicketId   
WHERE (((ALP_tblJmSvcTkt.Status)='Scheduled') AND ((ALP_tblJmSvcTkt.PrefDate) Is Null) AND ((ALP_tblJmTimeCard.TicketId) Is Null)) --AND ALP_tblJmSvcTkt.TicketId <> @ID  
--Completed  
UPDATE ALP_tblJmSvcTkt   
SET ALP_tblJmSvcTkt.Status = 'Completed', ALP_tblJmSvcTkt.RevisedDate = GetDate(), ALP_tblJmSvcTkt.RevisedBy = @UserId  
FROM ALP_tblJmSvcTkt LEFT JOIN ALP_tblJmTimeCard ON ALP_tblJmSvcTkt.TicketId = ALP_tblJmTimeCard.TicketId   
WHERE (((ALP_tblJmSvcTkt.Status)='Scheduled') AND ((ALP_tblJmSvcTkt.CompleteDate) Is Not Null) AND ((ALP_tblJmTimeCard.TicketId) Is Null)) --AND ALP_tblJmSvcTkt.TicketId <> @ID  
--Canceled  
UPDATE ALP_tblJmSvcTkt   
SET ALP_tblJmSvcTkt.Status = 'Canceled', ALP_tblJmSvcTkt.RevisedDate = GetDate(), ALP_tblJmSvcTkt.RevisedBy = @UserId  
FROM ALP_tblJmSvcTkt LEFT JOIN ALP_tblJmTimeCard ON ALP_tblJmSvcTkt.TicketId = ALP_tblJmTimeCard.TicketId   
WHERE (((ALP_tblJmSvcTkt.Status)='Scheduled') AND ((ALP_tblJmSvcTkt.CancelDate) Is Not Null) AND ((ALP_tblJmTimeCard.TicketId) Is Null)) --AND ALP_tblJmSvcTkt.TicketId <> @ID  