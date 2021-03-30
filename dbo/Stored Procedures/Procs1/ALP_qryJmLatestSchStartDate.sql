

CREATE PROCEDURE [dbo].[ALP_qryJmLatestSchStartDate] 
@ID int

As
SET NOCOUNT ON
 Select MAX(StartDate) as LatestStartDate from ALP_tblJmTimeCard 
 WHERE ALP_tblJmTimeCard.TicketId = @ID