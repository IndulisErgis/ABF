CREATE      procedure [dbo].[ALP_qry_AlpKitContentsSearch_sp]     
@JmInYn bit,  
@ItemID varchar(100) = null,  
@LocId varchar(10)  
As    
Begin    
 --mah 08/17/2016 Corrected errors in the SQL syntax 
  
declare @QueryString nvarchar(4000)  
declare @ConditionString nvarchar(4000)  
  
  
SET @QueryString = ''  
SET @ConditionString = ''  
  
SET @ItemID = REPLACE(@ItemID,'''','''''')  
  
if @JmInYn = 0 -- False SM tables   
begin  
 SET @QueryString = 'select isnull(KIS.Qty,0) as Quantity, KIS.UOM as UOM, KIS.ItemID as ItemID,   
  case when (select AlpKittedYN from ALP_tblSmItem_view where ItemCode =  KIS.ItemID)  = 1 then ''K''   
   else   
   case when (select AlpVendorKitYN from ALP_tblSmItem_view where ItemCode =  KIS.ItemID) = 1 then ''V''  
   else null end  
  end as K ,   
  (select [Desc] from ALP_tblSmItem_view where ItemCode =  KIS.ItemID)as ItemDescription,   
  CONVERT(FLOAT,(select ISNULL(UnitCost,0) from ALP_tblSmItem_view where ItemCode =  KIS.ItemID) * ISNULL(KIS.Qty,0)) as ExtraCost,   
  round(CONVERT(NUMERIC(18,2),(select ISNULL(UnitPrice,0) from ALP_tblSmItem_view where ItemCode =  KIS.ItemID) * 
  ISNULL(KIS.Qty,0)),2) as ExtraPrice   
 FROM ALP_tblSmItem_view SIT LEFT OUTER JOIN ALP_tblJmKitItemSm KIS ON SIT.ItemCode = KIS.KitItemID'  
 --==============================================================================================================  
 --ItemID Filter  
 --==============================================================================================================  
 IF LEN(@ItemID) > 0  
 BEGIN  
  SET @ConditionString = @ConditionString + ' KIS.KitItemID = ''' +  @ItemID + ''''  
 END  
end  
else  --True  IN tables   
begin  
  
 SET @QueryString = 'select isnull(KII.Qty,0) as Quantity, KII.UOM as UOM, KII.ItemID as ItemID,   
  case when (select KittedYN from tblInItem where ItemID =  KII.ItemID)  = -1 then ''K''   
   else   
   case when (select AlpVendorKitYN from ALP_tblInItem_view where ItemID =  KII.ItemID) = 1 then ''V''  
   else null end  
  end as K ,   
  (select Descr from tblInItem where ItemID =  KII.ItemID)as ItemDescription,   
  CONVERT(FLOAT,(select ISNULL(case when tblInItemLoc.CostBase <> 0  then tblInItemLoc.CostBase   
   else tblInItemLoc.CostLast end  
   ,0) from tblInItemLoc where  tblInItemLoc.LocId=''' + @LocId + ''' and tblInItemLoc.ItemID =  KII.ItemID) *  ISNULL(KII.Qty,0)) as ExtraCost,   
  ROUND(CONVERT(NUMERIC(18,2),(select ISNULL(AlpInstalledPrice,0) from tblInItemLoc where  tblInItemLoc.LocId=''' 
  + @LocId + ''' and ItemID =  KII.ItemID) * ISNULL(KII.Qty,0)),2) as ExtraPrice   
 FROM tblInItem IT LEFT OUTER JOIN ALP_tblInItemLocation_view ITL ON IT.ItemID = ITL.AlpItemID  
 LEFT OUTER JOIN ALP_tblJmKitItemIn KII ON IT.ItemID = KII.KitItemID'  
 --==============================================================================================================  
 --ItemID Filter  
 --==============================================================================================================  
 IF LEN(@ItemID) > 0  
 BEGIN  
  SET @ConditionString = @ConditionString + ' IT.ItemID = ''' +  @ItemID + ''''  
 END   
end  
--==============================================================================================================  
--Final Query  
--==============================================================================================================  
IF (LEN(@ConditionString) > 0)  
 SET @QueryString = @QueryString + ' WHERE ' + @ConditionString  
PRINT @QueryString  
EXEC SP_EXECUTESQL @QueryString  
end