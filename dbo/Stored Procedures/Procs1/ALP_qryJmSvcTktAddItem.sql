  
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktAddItem]     
 @TicketItemId   int  ,     
 @ResDesc  text,    
 @CauseId  int,    
 @CauseDesc  text,    
 @SerNum  varchar(35),    
 @EquipLoc  varchar(30),    
 @Desc  varchar(255),    
 @Zone   varchar(5),    
 @PanelYN   bit,    
 @TreatAsPartYN  bit,    
 @PartPulledDate  datetime,    
 @CopyToYN   bit,    
 @QtyAdded  pDec,    
 @Uom   varchar(5),    
 @Comments   text,    
 @UnitPrice   pDec,    
 @UnitCost   pDec,    
 @UnitPts   float,    
 @UnitHrs   pDec,    
 @WhseID  varchar(10),     
 --Below @RevisedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017  
 @RevisedBy varchar(50)=null,    
 --Below @ModifiedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017  
 @ModifiedBy varchar(50),  
 @PhaseId int =null,@BinNumber varchar(10)=null,@StagedDate datetime =null,  
 @BODate datetime =null --added by NSK on 23 Aug 2016 for bug id 514 and 522.    
    
AS    
Update ALP_tblJmSvcTktItem set ResDesc=@ResDesc, CauseId=@CauseId,CauseDesc=@CauseDesc,SerNum=@SerNum,EquipLoc=@EquipLoc,    
[Desc]=@Desc,Zone=@Zone,PanelYN=@PanelYN,TreatAsPartYN=@TreatAsPartYN,PartPulledDate=@PartPulledDate,CopyToYN=@CopyToYN,    
QtyAdded=@QtyAdded,Uom=@Uom,Comments=@Comments,UnitPrice=@UnitPrice,UnitCost=@UnitCost,UnitPts=@UnitPts,UnitHrs=@UnitHrs,WhseID=@WhseID,    
ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE(),  
PhaseId=@PhaseId,BinNumber=@BinNumber,StagedDate=@StagedDate,BODate=@BODate --added by NSK on 23 Aug 2016 for bug id 514 and 522.    
 where TicketItemId=@TicketItemId