
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateBillingTab]	
@PartsItemId varchar(24),
@PartsDesc varchar(35),
@PartsAddlDesc text,
@PartsTaxClass tinyint,
@LaborItemId varchar(24),
@LaborDesc varchar(35),
@LaborAddlDesc text,
@LaborTaxClass  tinyint,
@Batchid varchar(6),
@InvcDate datetime,
@CommentAddlDesc text,
@MailSiteYn bit,
@SendToPrintYn bit,
@InvcNum varchar(15),
@TicketId int,
--Below @RevisedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017
@RevisedBy varchar(50)=null,
--Below @ModifiedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017
@ModifiedBy varchar(50),
--Revised date and Modified date added by NSK on 8th Apr 2014(GetDate() was used to fetch the date earlier)
@RevisedDate datetime,
@ModifiedDate datetime


AS
update ALP_tbljmsvctkt set PartsItemId=@PartsItemId,PartsDesc=@PartsDesc,PartsAddlDesc=@PartsAddlDesc,PartsTaxClass=@PartsTaxClass,
LaborItemId=@LaborItemId,LaborDesc=@LaborDesc,LaborAddlDesc=@LaborAddlDesc,LaborTaxClass=@LaborTaxClass,Batchid=@Batchid ,
InvcDate=@InvcDate,CommentAddlDesc=@CommentAddlDesc ,MailSiteYn=@MailSiteYn,SendToPrintYn=@SendToPrintYn,InvcNum=@InvcNum ,
RevisedBy=@RevisedBy,RevisedDate=@RevisedDate,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate
 where ticketid=@TicketId