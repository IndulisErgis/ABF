      
CREATE proc    [dbo].[ALP_qryJmSvcTktItem_Update_sp]          
( @TicketItemId   int out ,          
 @TicketId  int,          
 @ResolutionId  int,          
 @ResDesc  text,          
 @CauseId  int,          
 @CauseDesc  text,          
 @SelectFromInvYn  bit,          
 @ItemNotInListYn  bit,          
 @ItemId  varchar(24),          
 @KitRef  int,          
 @Desc  varchar(255),          
 @TreatAsPartYN  bit,          
 @PrintOnInvoice  bit,          
 @WhseID  varchar(10),          
 @QtyAdded  pDec,          
 @QtyRemoved   pDec,          
 @QtyServiced   pDec,          
 @SerNum  varchar(35),          
 @EquipLoc  varchar(30),          
 @WarrExpDate  datetime,          
 @CopyToYN   bit,          
 @UnitPrice   pDec,          
 @UnitCost   pDec,          
 @UnitPts   float,          
 @Comments   text,          
 @Zone   varchar(5),          
 @ItemType   varchar(50),          
 @KittedYN  bit,          
 @SysItemId   int,          
 @PanelYN   bit,          
 @Uom   varchar(5),          
 @PartPulledDate  datetime,          
 @CosOffset   varchar(40),          
 @UnitHrs   pDec,          
 @AlpVendorKitYn   bit,          
 @AlpVendorKitComponentYn   bit,          
 @ts  timestamp out,          
 @QtySeqNum_Cmtd   int,          
 @QtySeqNum_InUse   int,          
 @LineNumber  varchar(50),          
 @KitNestLevel   smallint,          
 @NonContractItem   bit,    
 --Below @ModifiedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017    
 @ModifiedBy varchar(50)        
 ,@PhaseId int=null,@BinNumber varchar(10)=null,@StagedDate datetime=null,    
 @BODate datetime=null --aded by NSK on 12 Aug 2016 for bug id 514 and 522            
,@ExtSalePrice pDec=0 -- Added by NSK on 21 Mar 2019 for bug id 902          
)As          
BEGIN          
          
 UPDATE  dbo.ALP_tblJmSvcTktItem    SET            
     ResolutionId = @ResolutionId          
     ,ResDesc = @ResDesc          
     ,CauseId = @CauseId          
     ,CauseDesc = @CauseDesc          
     ,SelectFromInvYn = @SelectFromInvYn          
     ,ItemNotInListYn = @ItemNotInListYn          
     ,ItemId = @ItemId          
     ,KitRef = @KitRef          
     ,[Desc] = @Desc          
     ,TreatAsPartYN = @TreatAsPartYN          
     ,PrintOnInvoice = @PrintOnInvoice          
     ,WhseID = @WhseID          
     ,QtyAdded = @QtyAdded          
     ,QtyRemoved = @QtyRemoved          
     ,QtyServiced = @QtyServiced          
     ,SerNum = @SerNum          
     ,EquipLoc = @EquipLoc          
     ,WarrExpDate = @WarrExpDate          
     ,CopyToYN = @CopyToYN          
     ,UnitPrice = @UnitPrice          
     ,UnitCost = @UnitCost          
     ,UnitPts = @UnitPts          
     ,Comments = @Comments          
     ,Zone = @Zone          
     ,ItemType = @ItemType          
     ,KittedYN = @KittedYN          
     ,SysItemId = @SysItemId          
     ,PanelYN = @PanelYN          
     ,Uom = @Uom          
     ,PartPulledDate = @PartPulledDate          
     ,CosOffset = @CosOffset          
     ,UnitHrs = @UnitHrs          
     ,AlpVendorKitYn = @AlpVendorKitYn          
     ,AlpVendorKitComponentYn = @AlpVendorKitComponentYn          
     ,QtySeqNum_Cmtd = @QtySeqNum_Cmtd          
     ,QtySeqNum_InUse = @QtySeqNum_InUse          
     ,LineNumber = @LineNumber          
     ,KitNestLevel = @KitNestLevel          
     ,NonContractItem=@NonContractItem          
     ,ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE()        
     ,PhaseId=@PhaseId,BinNumber=@BinNumber,StagedDate=@StagedDate,BODate=@BODate--aded by NSK on 12 Aug 2016 for bug id 514 and 522                
     ,ExtSalePrice=@ExtSalePrice-- Added by NSK on 21 Mar 2019 for bug id 902 
     ,ExtSalePriceFlg=0-- Added by NSK on 21 Mar 2019 for bug id 902   
   WHERE  TicketItemId=@TicketItemId          
   --and ts=@Ts;          
          
  SELECT @Ts=ts FROM ALP_tblJmSvcTktItem WHERE TicketItemId=@TicketItemId;          
END