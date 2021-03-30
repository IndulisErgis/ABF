
CREATE procedure [dbo].[ALP_qry_AlpGetBaseAmount_sp]
	@ItemID		varchar(24),
	@LocationID	varchar(10)= null,
	@PricePlanBasis	int
As
Begin 
	/*
		Created by NP for EFI#1889 on 05/01/2010
	*/
IF @LocationID = '0' or @LocationID IS NULL
	BEGIN
		IF @PricePlanBasis = 0
			BEGIN 
				Select 0 as BaseAmount 
			End
		ELSE IF @PricePlanBasis = 1
			BEGIN
				SELECT  
					coalesce(AlpInstalledPrice,0) as BaseAmount 
				FROM 
					--tblSmItem  
					ALP_tblSmItem_view
				WHERE 
					ItemCode =@ItemID
			END
		ELSE IF @PricePlanBasis = 2 or @PricePlanBasis = 3 or @PricePlanBasis = 4
			BEGIN
				SELECT  
					coalesce(UnitPrice,0) as BaseAmount 
				FROM 
					tblSmItem  
				WHERE 
					ItemCode =@ItemID
			END
		ELSE 
	
			BEGIN
				SELECT  
					coalesce(AlpInstalledPrice,0) as BaseAmount
				FROM 
					--tblSmItem  
					ALP_tblSmItem_view
				WHERE 
					ItemCode =@ItemID
			END
	END
ELSE
	BEGIN 
		IF @PricePlanBasis = 0
			BEGIN 
				Select 0 as BaseAmount 
			End
		ELSE IF @PricePlanBasis = 1
			BEGIN
				SELECT  
					coalesce(AlpInstalledPrice  ,0) as BaseAmount 
				FROM 
					ALP_tblInItemLoc_view 
				WHERE 
					AlpItemID =@ItemID  and AlpLocID = @LocationID 
				--FROM 
				--	tblInItemLoc 
				--WHERE 
				--	ItemID =@ItemID  and LocID = @LocationID 
			END
		ELSE IF @PricePlanBasis = 2
			BEGIN
				SELECT  
					coalesce(PriceAvg,0) as BaseAmount 
				FROM 
					tblInItemLocUomPrice inner join tblInItem 
				ON 	
					tblInItemLocUomPrice.ItemId = tblInItem.ItemId and tblInItem.UomBase = tblInItemLocUomPrice.UOM
				WHERE 
					tblInItem.ItemID =@ItemID  and LocID = @LocationID 
			END
		ELSE IF @PricePlanBasis = 3
			BEGIN
				SELECT  
					coalesce(PriceBase,0) as BaseAmount 
				FROM 
					tblInItemLocUomPrice inner join tblInItem 
				ON 	
					tblInItemLocUomPrice.ItemId = tblInItem.ItemId and tblInItem.UomBase = tblInItemLocUomPrice.UOM
				WHERE 
					tblInItem.ItemID =@ItemID  and LocID = @LocationID 
			END
		ELSE IF @PricePlanBasis = 4
			BEGIN
				SELECT  
					coalesce(PriceList,0) as BaseAmount 
				FROM 
					tblInItemLocUomPrice inner join tblInItem 
				ON 	
					tblInItemLocUomPrice.ItemId = tblInItem.ItemId and tblInItem.UomBase = tblInItemLocUomPrice.UOM
				WHERE 
					tblInItem.ItemID =@ItemID  and LocID = @LocationID 
			END
		ELSE
			BEGIN
				SELECT  
					coalesce(AlpInstalledPrice,0) as BaseAmount 
				FROM 
					ALP_tblInItemLoc_view 
				WHERE 
					AlpItemID =@ItemID  and AlpLocID = @LocationID 
				--FROM 
				--	tblInInventoryLoc 
				--WHERE 
				--	ItemID =@ItemID  and LocID = @LocationID 
			END
	END
END