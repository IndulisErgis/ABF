
CREATE PROCEDURE [dbo].[ALP_qryJmUpdateRecJobCreateBy]
@CreateBy varchar(50),
@RevisedBy varchar(50),
@RevisedDate datetime,
@TicketId int
--MAH 05/02/2017 - increased size of the CreateBy, RevisedBy parameters, from 16 to 50 
As
SET NOCOUNT ON
Update ALP_tblJmSvcTkt set CreateBy=@CreateBy,RevisedBy=@RevisedBy,RevisedDate=@RevisedDate
WHERE TicketId = @TicketId