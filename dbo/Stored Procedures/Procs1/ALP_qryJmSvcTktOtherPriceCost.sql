          
          
                        
CREATE PROCEDURE dbo.ALP_qryJmSvcTktOtherPriceCost                        
--EFI# 1063 MAH 10/21/04 - added Uom                        
--EFI# 1549 MAH 11/29/04 - increased Cause Code size                        
--EFI# 1529 MAH 12/20/04 - JM-IN interface                        
--EFI# 1632 MAH 11/02/05 - Kits within Kits                         
--EFI# 1613 MAH 12/23/05 - Split out Other Labor ( ex. EngLabor ) from catchall 'Other' ( misc items )category                        
--TOA Change RAVI 11/03/17 - Use zone column in TOA development           
--TOA Change RAVI 12/27/17-  KitRef column added by Ravi             
@ID int                        
As                        
SET NOCOUNT ON                        
Create Table #SvcTktItems                        
(                        
ResDesc text,                        
CauseCode varchar(15),                        
[Desc] varchar(255),                        
EquipLoc varchar(30),                        
Pts pDec,                        
Hrs pDec,                        
--EFI# 1632 MAH 11/02/05: changed from 1 to 3:                        
KorC varchar(3),                        
TreatAsPartYn varchar(3),                        
Type varchar(10),                        
Uom varchar(5),                        
Qty pDec,                        
Price pDec,                        
Cost pDec,                        
PriceMethod tinyint,                        
TicketItemId int,                        
TicketId int,                        
ItemId pItemId,                        
WhseId varchar(10),                        
PartPulledDate datetime,                         
AlpVendorKitYn bit,                         
AlpVendorKitComponentYn bit,                         
QtySeqNum_Cmtd int,                         
QtySeqNum_InUse int,                        
[Action] varchar(10),                        
LineNumber varchar(50),                        
KitNestLevel int,                        
--Below column commented by NSK on 05 Jan 2015 and added KittedYn  instead of NonContractItem                    
--NonContractItem bit ,                      
KittedYN bit,                    
--UomBase column added by NSK on 27 Aug 2014                      
UomBase varchar(5),                      
--NonContractItem column added by NSK on 05 Jan 2015                    
NonContractItem bit,                   
--PhaseId,BinNumber,StagedDate,BODate added by NSK on 16 Aug 2016 for bug id 514 and 522                      
PhaseId int,BinNumber varchar(10),StagedDate datetime,BODate datetime,Phase varchar(10) ,                  
--Added by NSK on 14 Sep 2016 for bug id 502                
  --start                 
CauseId int,CauseDesc text,Comments text,                
ActionTech varchar(5),ActionDate datetime                
 --end                   
  --Added by NSK on 25 Oct 2016 for bug id 556              
 ,UnitPriceIsFinalSalePrice bit              
 --Added by RAVI on 3 Nov 2017 for use zone in TOA development            
 ,Zone varchar(5) null            
  -- Below columns (SerNum,CopyToYN,WhseID,PanelYN) Added by Ravi on 12 Dec 2017             
 ,SerNum varchar(35)null,CopyToYN bit null, PanelYN bit null          
  --TOA Change RAVI 12/27/17-  KitRef column added by Ravi            
 ,KitRef int null          
  --Below column added by NSK on 15 Mar 2019 for bug id 914        
 ,ResolutionCode varchar(15)       
  --Below column added by NSK on 24 Mar 2019 for bug id 902        
  --start    
 ,ExtSalePrice pDec null    
 ,ExtSalePriceFlg int     
 --end    
 ,HoldInvCommitted bit not null -- Added by NSK on Oct 25 2018 for bug id 868    
      
)                        
--Get current aged customer balances                        
Insert into #SvcTktItems                         
 Exec dbo.ALP_qryJmSvcTktItems @ID                        
--EFI# 1613 MAH 12/23/05 - changed:                        
--SELECT Sum([Price]*[qty]) AS ExtPrice, Sum([Cost]*[qty]) AS ExtCost, #SvcTktItems.TicketId         
SELECT  ExtPrice = SUM(CASE WHEN Type = 'Other' THEN [Price]*[qty]                        
         ELSE 0                        
         END),                        
        ExtCost = SUM(CASE WHEN Type = 'Other' THEN [Cost]*[qty]                   
         ELSE 0                        
         END),                         
 #SvcTktItems.TicketId,                        
        ExtPrice_OtherLabor = SUM(CASE WHEN Type = 'OtherLabor' THEN [Price]*[qty]                        
         ELSE 0                        
         END),                        
        ExtCost_OtherLabor = SUM(CASE WHEN Type = 'OtherLabor' THEN [Cost]*[qty]                        
         ELSE 0                        
         END)            
FROM #SvcTktItems                        
WHERE #SvcTktItems.Type ='Other' OR #SvcTktItems.Type ='OtherLabor'                         
GROUP BY #SvcTktItems.TicketId