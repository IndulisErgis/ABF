CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateAddItems]                 
@QtyAdded pDec,                
@UnitPrice pDec,                
@UnitCost pDec,                
@UnitPts float,                
@UnitHrs pDec,                
@EquipLoc varchar(30),                
@PartPulledDate datetime,                
@TicketItemId int,          
--Below @ModifiedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017          
@ModifiedBy varchar(50),                
@TreatAsPartYN bit,                
@NonContractItem bit,                
@ResDesc  text,                
@CauseId  int,                
@CauseDesc  text,                
@SerNum  varchar(35),                
@PanelYN   bit,                
@CopyToYN   bit,                
@Uom   varchar(5),                
@Comments   text,                
@WhseID  varchar(10),                
@Desc varchar(255)                
,@PhaseId int=null,@BinNumber varchar(10)=null,@StagedDate datetime=null,          
@BODate datetime=null --aded by NSK on 12 Aug 2016 for bug id 514 and 522          
,@Zone varchar(5) -- added by NSK on 11 Jun 2018 for bug id 735    
,@HoldInvCommitted bit -- added by NSK on 25 Oct 2018 for bug id 868               
AS                
update ALP_tblJmSvcTktItem set QtyAdded=@QtyAdded,UnitPrice=@UnitPrice,UnitCost=@UnitCost,UnitPts=@UnitPts,                
UnitHrs=@UnitHrs,EquipLoc=@EquipLoc,PartPulledDate=@PartPulledDate,ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE(),                
TreatAsPartYN=@TreatAsPartYN,NonContractItem=@NonContractItem,                
ResDesc=@ResDesc, CauseId=@CauseId,CauseDesc=@CauseDesc,SerNum=@SerNum,                
PanelYN=@PanelYN,CopyToYN=@CopyToYN,Uom=@Uom,Comments=@Comments,WhseID=@WhseID,[Desc]=@Desc              
,PhaseId=@PhaseId,BinNumber=@BinNumber,StagedDate=@StagedDate,BODate=@BODate--aded by NSK on 12 Aug 2016 for bug id 514 and 522                  
,Zone=@Zone -- added by NSK on 11 Jun 2018 for bug id 735        
,ExtSalePrice=@UnitPrice-- added by NSK on 25 Mar 2019 for bug id 902     
,HoldInvCommitted=@HoldInvCommitted -- added by NSK on 25 Oct 2018 for bug id 868        
where ticketitemid=@TicketItemId