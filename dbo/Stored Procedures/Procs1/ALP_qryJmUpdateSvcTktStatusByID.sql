
CREATE Procedure [dbo].[ALP_qryJmUpdateSvcTktStatusByID]
@ID int
AS
--modified to increase Alpine userID length of 50 from 20, mah 05/05/17

DECLARE @UserID varchar(50), @WrkStnID pWrkStnId
EXEC dbo.ALP_currentuser @UserId OUT, @WrkStnId OUT
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
WHERE (((ALP_tblJmSvcTkt.Status)='Scheduled') AND ((ALP_tblJmSvcTkt.PrefDate) Is Not Null) AND ((ALP_tblJmTimeCard.TicketId) Is Null)) --AND ALP_tblJmSvcTkt.TicketId <> @ID
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