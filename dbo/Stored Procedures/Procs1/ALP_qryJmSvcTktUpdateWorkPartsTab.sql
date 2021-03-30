

-- modified 2/26/14 by Shanthakumar
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateWorkPartsTab]	
	@Bodate datetime,
	@StagedDate datetime,
	@BinNumber varchar(10),
	@PriceId varchar(10),
	@PartsPrice pDec,
	@PartsOhPct numeric(20,10),
	@Ticketid int,
	@RevisedBy varchar(20)=null,
	@ModifiedBy varchar(16),
--Revised date and Modified date added by NSK on 8th Apr 2014(GetDate() was used to fetch the date earlier)
@RevisedDate datetime,
@ModifiedDate datetime

AS
update ALP_tbljmsvctkt 
	set Bodate=@Bodate,stagedDate=@StagedDate,binnumber=@BinNumber,
	priceid=@PriceId,PartsPrice=@PartsPrice,PartsOhPct=@PartsOhPct,
	RevisedBy=@RevisedBy,
	RevisedDate=@RevisedDate ,
	ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate
where ticketid=@Ticketid