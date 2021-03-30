
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateLaborTab]	
@RegHrs float,
@OutofRegHrs float,
@HolHrs float,
@LabPriceTotal pDec,
@RepPlanId int,
@TicketId int,
--Below @RevisedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017
@RevisedBy varchar(50)=null,
--Below @ModifiedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017
@ModifiedBy varchar(50),
--Revised date and Modified date added by NSK on 8th Apr 2014(GetDate() was used to fetch the date earlier)
@RevisedDate datetime,
@ModifiedDate datetime

AS
update dbo.ALP_tblJmSvcTkt set RegHrs =@RegHrs ,OutofRegHrs=@OutofRegHrs, HolHrs =@HolHrs,LabPriceTotal=@LabPriceTotal ,RepPlanId=@RepPlanId,RevisedBy=@RevisedBy,RevisedDate=@RevisedDate
,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate
 where TicketId=@TicketId