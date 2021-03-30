
CREATE procedure [dbo].[ALP_qry_AlpCalculateItemSalePrice_sp]
	@ItemID		varchar(24),
	@LocationID	varchar(10)= null,
	@PricePlanID	varchar(10) = null
As

Begin 
	/*
		Created by NP for EFI#1889 on 05/01/2010
	*/

IF EXISTS (SELECT 1 FROM ALP_tblJmPricePlanItem INNER JOIN ALP_tblJmPricePlanGenHeader ON ALP_tblJmPricePlanItem.PriceId = ALP_tblJmPricePlanGenHeader.PriceId
				WHERE  		ItemID = @ItemID and 
 						LocID = @LocationID and 
						ALP_tblJmPricePlanGenHeader.PriceID = @PricePlanID  and 
						InactiveYN = 0)
	Begin
		SELECT 
			PriceAdjBase as PricePlanBasis,		
			PriceAdjType as PricePlanType,
			PriceAdjAmt  as PricePlanAmount 
		FROM ALP_tblJmPricePlanItem 
		WHERE 
	  		ItemID = @ItemID and 
 			LocID = @LocationID and 
			PriceID = @PricePlanID 
	End
ELSE
	Begin
		SELECT 
			DfltAdjBase as PricePlanBasis ,	
			DfltAdjType as PricePlanType,
			DfltAdjAmt  as PricePlanAmount  
		FROM   ALP_tblJmPricePlanGenHeader 
		WHERE 
			PriceID = @PricePlanID 
	End
End