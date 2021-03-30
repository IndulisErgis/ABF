

CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateTrackingStaging]	
@Ticketid int,
@BoDate datetime=null,
@StagedDate datetime=null,
@BinNumber varchar(10)=null,
@RevisedBy varchar(20)=null
AS
Update ALP_tbljmsvctkt set BoDate=@BoDate,StagedDate=@StagedDate,BinNumber=@BinNumber,RevisedBy=@RevisedBy,RevisedDate=CONVERT(VARCHAR(10),GETDATE(),101) where ticketid=@Ticketid