            
CREATE proc    [dbo].[ALP_qryJmSvcTktItem_Insert_sp]                
(                
@TicketItemId   int out ,                
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
,@UnitPriceIsFinalSalePrice bit=null --Added by NSK on 25 Oct 2016 for 556        
,@ExtSalePrice pDec=0 -- Added by NSK on 21 Mar 2019 for bug id 902      
,@HoldInvCommitted bit  --Added by NSK on 08 Nov 2018 for bug id 819     
)As                
BEGIN                
 INSERT INTO ALP_tblJmSvcTktItem                
           (TicketId           ,ResolutionId           ,ResDesc           ,CauseId                
           ,CauseDesc           ,SelectFromInvYn           ,ItemNotInListYn           ,ItemId                
           ,KitRef           ,[Desc]           ,TreatAsPartYN           ,PrintOnInvoice                
           ,WhseID           ,QtyAdded           ,QtyRemoved           ,QtyServiced                
           ,SerNum           ,EquipLoc           ,WarrExpDate           ,CopyToYN                
           ,UnitPrice           ,UnitCost           ,UnitPts           ,Comments                
           ,Zone           ,ItemType           ,KittedYN           ,SysItemId                
           ,PanelYN           ,Uom           ,PartPulledDate           ,CosOffset                
           ,UnitHrs           ,AlpVendorKitYn           ,AlpVendorKitComponentYn                
           ,QtySeqNum_Cmtd           ,QtySeqNum_InUse           ,LineNumber                
           ,KitNestLevel,NonContractItem,ModifiedBy,ModifiedDate              
           ,PhaseId,BinNumber,StagedDate,BODate--added by NSK on 12 Aug 2016 for bug id 514 and 522              
           ,UnitPriceIsFinalSalePrice--Added by NSK on 25 Oct 2016 for 556       
           ,ExtSalePrice-- Added by NSK on 21 Mar 2019 for bug id 902    
            ,HoldInvCommitted --Added by NSK on 08 Nov 2018 for bug id 868      
           )                
     VALUES                
           (@TicketId            ,@ResolutionId             ,@ResDesc             ,@CauseId                  
           ,@CauseDesc             ,@SelectFromInvYn           ,@ItemNotInListYn           ,@ItemId                
           ,@KitRef            ,@Desc            ,@TreatAsPartYN           ,@PrintOnInvoice                
           ,@WhseID           ,@QtyAdded           ,@QtyRemoved           ,@QtyServiced                
           ,@SerNum            ,@EquipLoc            ,@WarrExpDate            ,@CopyToYN                
           ,@UnitPrice           ,@UnitCost           ,@UnitPts            ,@Comments                  
           ,@Zone            ,@ItemType            ,@KittedYN           ,@SysItemId                  
           ,@PanelYN           ,@Uom            ,@PartPulledDate            ,@CosOffset                 
           ,@UnitHrs           ,@AlpVendorKitYn           ,@AlpVendorKitComponentYn                
           ,@QtySeqNum_Cmtd             ,@QtySeqNum_InUse             ,@LineNumber                 
           ,@KitNestLevel,@NonContractItem ,@ModifiedBy,GETDATE()              
           ,@PhaseId,@BinNumber,@StagedDate,@BODate--added by NSK on 12 Aug 2016 for bug id 514 and 522              
           ,@UnitPriceIsFinalSalePrice--Added by NSK on 25 Oct 2016 for 556        
           ,@ExtSalePrice--Added by NSK on 21 Mar 2019 for bug id 902   
           ,coalesce(@HoldInvCommitted, 0)  --Added by NSK on 08 Nov 2018 for bug id 868; changed DMM 20200120 for TOA       
           )                
                   
 set @TicketItemId= SCOPE_IDENTITY();                
 SELECT @Ts=ts FROM ALP_tblJmSvcTktItem WHERE TicketItemId=@TicketItemId                
END