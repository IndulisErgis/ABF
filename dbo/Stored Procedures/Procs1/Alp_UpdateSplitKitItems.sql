CREATE procedure [dbo].[Alp_UpdateSplitKitItems]
 @PartPulledDate datetime ,
  @PhaseId int=null,
  @StagedDate datetime=null,
  @BODate datetime=null,
  @BinNumber varchar(10)=null,
  @TicketItemId int,
  @ModifiedBy varchar(50)
  ,@HoldInvCommitted bit -- added by NSK on 21 Oct 2020 for bug id 985 
 as
update ALP_tblJmSvcTktItem set PartPulledDate=@PartPulledDate,
	PhaseId=@PhaseId,StagedDate=@StagedDate,BODate=@BODate,BinNumber=@BinNumber
   ,ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE()
   ,HoldInvCommitted=@HoldInvCommitted -- added by NSK on 21 Oct 2020 for bug id 985  
where ticketitemid=@TicketItemId