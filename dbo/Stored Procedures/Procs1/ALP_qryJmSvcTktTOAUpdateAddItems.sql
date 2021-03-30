CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktTOAUpdateAddItems]             
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
--@TreatAsPartYN bit,            
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
@BODate datetime=null, --aded by NSK on 12 Aug 2016 for bug id 514 and 522              
@Zone varchar(5) --added by NSK on 31 Oct 2017 for TOA app    
AS            
update ALP_tblJmSvcTktItem set QtyAdded=@QtyAdded,UnitPrice=@UnitPrice,UnitCost=@UnitCost,UnitPts=@UnitPts,            
UnitHrs=@UnitHrs,EquipLoc=@EquipLoc,PartPulledDate=@PartPulledDate,ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE(),            
--TreatAsPartYN=@TreatAsPartYN,  
NonContractItem=@NonContractItem,            
ResDesc=@ResDesc, CauseId=@CauseId,CauseDesc=@CauseDesc,SerNum=@SerNum,            
PanelYN=@PanelYN,CopyToYN=@CopyToYN,Uom=@Uom,Comments=@Comments,WhseID=@WhseID,[Desc]=@Desc          
,PhaseId=@PhaseId,BinNumber=@BinNumber,StagedDate=@StagedDate,BODate=@BODate--aded by NSK on 12 Aug 2016 for bug id 514 and 522              
,Zone=@Zone--added by NSK on 31 Oct 2017 for TOA app    
where ticketitemid=@TicketItemId