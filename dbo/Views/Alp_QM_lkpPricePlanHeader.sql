CREATE view Alp_QM_lkpPricePlanHeader as
            
		  select * ,   PricePlanAdjBase =Case   WHEN DfltAdjBase =0 THEN 'No Base'          
												WHEN DfltAdjBase =1 THEN 'Installed Price'          
												WHEN DfltAdjBase =3 THEN 'Base Price'       
												WHEN DfltAdjBase =4 THEN 'List Price'      
												WHEN DfltAdjBase =5 THEN 'Standard Cost' 
										END   ,
						PricePlanAdjType =Case  WHEN DfltAdjType =0 THEN 'FixedPrice'
												WHEN DfltAdjType =1 THEN 'Percent'
												WHEN DfltAdjType =2 THEN 'Margin'
										End 
		  from   Alp_tblJmPricePlanGenHeader where  InactiveYN=0