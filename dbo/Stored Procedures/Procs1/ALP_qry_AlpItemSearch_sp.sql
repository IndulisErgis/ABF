   
/*    
 Created by Sudharson for EFI# 1903 on 08/17/2010    
*/    
CREATE  procedure [dbo].[ALP_qry_AlpItemSearch_sp]    
@JmInYn bit,    
@ProductLineCondition varchar(10) = null,     
@ProductLine varchar(12) = null,     
@CategoryCondition varchar(8) = null,     
@Category varchar(12) = null,     
@ManufacturerCondition varchar(8) = null,     
@Manufacturer varchar(12) = null,     
@DescriptionCondition varchar(8) = null,     
@Description varchar(35) = null,     
@ItemIDCondition varchar(8) = null,     
@ItemID pItemID = null,     
@ItemStatus varchar(12) = null,    
@LocationID pLocID = null    
As      
Begin      
    
    
declare @QueryString nvarchar(4000)    
declare @ConditionString nvarchar(4000)    
    
    
SET @QueryString = ''    
SET @ConditionString = ''    
    
SET @ProductLine = REPLACE(@ProductLine,'''','''''')    
SET @Category = REPLACE(@Category,'''','''''')    
SET @Manufacturer = REPLACE(@Manufacturer,'''','''''')    
SET @Description = REPLACE(@Description,'''','''''')    
SET @ItemID = REPLACE(@ItemID,'''','''''')    
    
if @JmInYn = 0 -- False SM tables     
begin    
    
-- select * from ALP_tblSmItem    
--AlpItemStatus column added by NSK on 28 OCt 2014    
 SET @QueryString = 'select '''' as LocationID, ItemCode as ItemID,     
  case when AlpKittedYN  != 0 then ''K''     
   else     
   case when AlpVendorKitYN  != 0 then ''V''     
   else null end    
  end as K ,     
  [Desc] as ItemDescription,     
  '''' as ProductLine,     
  '''' as Category,    
  '''' as Manufacturer,     
  CONVERT(FLOAT,UnitCost) as Cost,     
  Units as UOM, round(CONVERT(NUMERIC(18,2),isnull(UnitPrice,0)),2) as Price    
  ,AlpItemStatus =         
Case         
 WHEN AlpItemStatus =1 THEN ''Active''        
 WHEN AlpItemStatus =2 THEN ''Discontinued''        
 WHEN AlpItemStatus =3 THEN ''Obsolete''        
END     
 FROM ALP_tblSmItem_view'    
    
 --==============================================================================================================    
 --Description Filter    
 --==============================================================================================================    
 IF LEN(@DescriptionCondition)>0 AND LEN(@Description)>0    
 BEGIN    
  IF @DescriptionCondition ='CONTAINS'    
   SET @ConditionString = @ConditionString + ' [Desc] LIKE ''%' +  @Description + '%'''    
  ELSE IF @DescriptionCondition ='EQUALS'    
   SET @ConditionString = @ConditionString + ' [Desc] = ''' +  @Description + ''''    
 END    
    
 --==============================================================================================================    
 --ItemID Filter    
 --==============================================================================================================    
 IF LEN(@ItemIDCondition)>0 AND LEN(@ItemID)>0    
 BEGIN    
  IF (LEN(@ConditionString)>0)     
   SET @ConditionString = @ConditionString + ' AND '     
  IF @ItemIDCondition ='CONTAINS'    
   SET @ConditionString = @ConditionString + ' ItemCode LIKE ''%' +  @ItemID + '%'''    
  ELSE IF @ItemIDCondition ='EQUALS'    
   SET @ConditionString = @ConditionString + ' ItemCode = ''' +  @ItemID + ''''    
 END    
   
  --==============================================================================================================    
 --ItemStatus Filter  - Added by NSK on 28 Oct 2014 to pass the AlpItemStatus in the where condition for SM  
 --==============================================================================================================    
 IF LEN(@ItemStatus)>0    
 BEGIN    
  IF (LEN(@ConditionString)>0)     
   SET @ConditionString = @ConditionString + ' AND '     
  SET @ConditionString = @ConditionString + ' AlpItemStatus = ''' +  @ItemStatus + ''''    
 END    
    
end    
else  --True  IN tables     
begin    
--AlpItemStatus column added by NSK on 28 OCt 2014   
--IIF(dbo_tblInItemLoc.CostBase <> 0,dbo_tblInItemLoc.CostBase,dbo_tblInItemLoc.CostLast)   as Cost,    
 SET @QueryString = 'select ITL.LocID as LocationID, IT.ItemID,     
  case when IT.KittedYN  != 0 then ''K''     
   else     
   case when IT.AlpVendorKitYN  != 0 then ''V''     
   else null end    
  end as K ,     
  IT.Descr as ItemDescription,     
  IT.ProductLine as ProductLine,     
  IT.UsrFld2 as Category,     
  IT.UsrFld1 as Manufacturer,     
  CONVERT(FLOAT,    
   case when ITL.CostBase <> 0  then ITL.CostBase     
   else ITL.CostLast end    
   ) as Cost,     
  IT.UOMBase as UOM, round(CONVERT(NUMERIC(18,2),isnull(ITL.AlpInstalledPrice,0)),2) as Price,    
ITL.ItemLocStatus,    
AlpItemStatus =      
Case       
 WHEN ITL.ItemLocStatus =1 THEN ''Active''     
 WHEN ITL.ItemLocStatus =2 THEN ''Discontinued''     
 WHEN ITL.ItemLocStatus =3 THEN ''Superseded''   
 WHEN ITL.ItemLocStatus =4 THEN ''Obsolete''      
END         
 FROM ALP_tblInItem_view IT LEFT OUTER JOIN ALP_tblInItemLocation_view ITL    
 on IT.ItemID = ITL.ItemID'    
 -- CONVERT(FLOAT,    
 --  case when ITL.CostBase <> 0  then ITL.CostBase     
 --  else ITL.CostLast end    
 --  ) as Cost,     
 -- UOMBase as UOM, round(CONVERT(NUMERIC(18,2),isnull(ITL.AlpInstalledPrice,0)),2) as Price     
 --FROM ALP_tblInItem_view IT LEFT OUTER JOIN ALP_tblInItemLocation_view ITL    
 --on IT.ItemID = ITL.ItemID'    
    
--CONVERT(FLOAT,ITL.CostLast) as Cost,     
 --==============================================================================================================    
 --ProductLine Filter    
 --==============================================================================================================    
 IF LEN(@ProductLineCondition)>0 AND LEN(@ProductLine)>0    
 BEGIN    
  IF @ProductLineCondition ='CONTAINS'    
   SET @ConditionString = @ConditionString + ' IT.ProductLine LIKE ''%' +  @ProductLine + '%'''    
  ELSE IF @ProductLineCondition ='EQUALS'    
   SET @ConditionString = @ConditionString + ' IT.ProductLine = ''' +  @ProductLine + ''''    
 END    
    
 --==============================================================================================================    
 --Category Filter    
 --==============================================================================================================    
 IF LEN(@CategoryCondition)>0 AND LEN(@Category)>0    
 BEGIN    
  IF (LEN(@ConditionString)>0)     
   SET @ConditionString = @ConditionString + ' AND '     
      
  IF @CategoryCondition ='CONTAINS'    
   SET @ConditionString = @ConditionString + ' IT.UsrFld2 LIKE ''%' +  @Category + '%'''    
  ELSE IF @CategoryCondition ='EQUALS'    
   SET @ConditionString = @ConditionString + ' IT.UsrFld2 = ''' +  @Category + ''''    
 END    
    
 --==============================================================================================================    
 --Manufacturer Filter    
 --==============================================================================================================    
 IF LEN(@ManufacturerCondition)>0 AND LEN(@Manufacturer)>0    
 BEGIN    
  IF (LEN(@ConditionString)>0)     
   SET @ConditionString = @ConditionString + ' AND '     
  IF @ManufacturerCondition ='CONTAINS'    
   SET @ConditionString = @ConditionString + ' IT.UsrFld1 LIKE ''%' +  @Manufacturer + '%'''    
  ELSE IF @ManufacturerCondition ='EQUALS'    
   SET @ConditionString = @ConditionString + ' IT.UsrFld1 = ''' +  @Manufacturer + ''''    
 END    
    
 --==============================================================================================================    
 --Description Filter    
 --==============================================================================================================    
 IF LEN(@DescriptionCondition)>0 AND LEN(@Description)>0    
 BEGIN    
  IF (LEN(@ConditionString)>0)     
   SET @ConditionString = @ConditionString + ' AND '     
  IF @DescriptionCondition ='CONTAINS'    
   SET @ConditionString = @ConditionString + ' IT.Descr LIKE ''%' +  @Description + '%'''    
  ELSE IF @DescriptionCondition ='EQUALS'    
   SET @ConditionString = @ConditionString + ' IT.Descr = ''' +  @Description + ''''    
 END    
    
 --==============================================================================================================    
 --ItemID Filter    
 --==============================================================================================================    
 IF LEN(@ItemIDCondition)>0 AND LEN(@ItemID)>0    
 BEGIN    
  IF (LEN(@ConditionString)>0)     
   SET @ConditionString = @ConditionString + ' AND '     
  IF @ItemIDCondition ='CONTAINS'    
   SET @ConditionString = @ConditionString + ' IT.ItemID LIKE ''%' +  @ItemID + '%'''    
  ELSE IF @ItemIDCondition ='EQUALS'    
   SET @ConditionString = @ConditionString + ' IT.ItemID = ''' +  @ItemID + ''''    
 END    
    
 --==============================================================================================================    
 --ItemStatus Filter    
 --==============================================================================================================    
 IF LEN(@ItemStatus)>0    
 BEGIN    
  IF (LEN(@ConditionString)>0)     
   SET @ConditionString = @ConditionString + ' AND '     
  SET @ConditionString = @ConditionString + ' IT.ItemStatus = ''' +  @ItemStatus + ''''    
 END    
    
 --==============================================================================================================    
 --Location Filter    
 --==============================================================================================================    
 IF LEN(@LocationID)>0    
 BEGIN    
  IF (LEN(@ConditionString)>0)     
   SET @ConditionString = @ConditionString + ' AND '     
  SET @ConditionString = @ConditionString + ' ITL.LocID = ''' +  @LocationID + ''''    
 END    
    
end    
--==============================================================================================================    
--Final Query    
--==============================================================================================================    
IF (LEN(@ConditionString)>0)    
 SET @QueryString = @QueryString + ' WHERE ' + @ConditionString    
PRINT @QueryString    
EXEC SP_EXECUTESQL @QueryString    
end    
    
    
    
/*    
    
select KittedYN, AlpVendorKitYN from ALP_tblInItem order by 1 desc    
select KittedYN, AlpVendorKitYN from ALP_tblInItem order by 2 desc    
    
select distinct ItemStatus from ALP_tblInItem    
select * from ALP_tblInItem    
select distinct KittedYN from ALP_tblInItem    
select distinct AlpKittedYN  from ALP_tblSmItem    
select * from ALP_tblInItemLoc      
    
select * from ALP_tblSmItem    
select InYN, * from ALP_tblArOption    
select InYN, * from ALP_glbArOption    
*/