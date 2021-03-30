
/* formerly qryIn-R751B-ReorderWorksheet  Takes WhseID as param*/
/****** Object:  StoredProcedure [dbo].[ALP_R_AR_In_R751B_ReorderWorksheet]    Script Date: 01/08/2013 19:08:59 ******/
CREATE PROCEDURE [dbo].[ALP_R_AR_In_R751B_ReorderWorksheet] 
(
@WhseID varchar(10),
@VendorID varchar(10),
@MFG varchar(12),
--Added CATG filter - 04/04/18 - ER
@CATG varchar (12)
) 
AS
BEGIN
SET NOCOUNT ON;
SELECT 
IL.LocId,
II.ItemId,
II.Descr, 
[708].Available, 
[708].OnOrder,
IL.QtyOrderPoint, 
IL.QtyOrderMin,
IL.Eoq,
--Newest ReorderQty Formula devised by Bob - 10/13/17 - ER
CASE 
	WHEN IL.QtyOrderMin>(IL.QtyOnHandMax-[708].Available-[708].OnOrder)
	THEN IL.QtyOrderMin
	ELSE (IL.QtyOnHandMax-[708].Available-[708].OnOrder)
	END AS ReorderQty,
--New ReorderQty Formula devised by Bob - 7/19/16 - ER
--CASE 
--	WHEN IL.QtyOrderMin>(IL.QtyOnHandMax+(CASE WHEN IL.QtyOrderPoint=-1 THEN 0 ELSE IL.QtyOrderPoint END)-[708].Available-[708].OnOrder)
--	THEN IL.QtyOrderMin
--	ELSE (IL.QtyOnHandMax+(CASE WHEN IL.QtyOrderPoint=-1 THEN 0 ELSE IL.QtyOrderPoint END)-[708].Available-[708].OnOrder)
--	END AS ReorderQty,
--Older ReorderQty Formula
--CASE 
--	WHEN (IL.QtyOrderPoint-[708].Available+IL.QtyOrderMin-[708].OnOrder)>(IL.QtyOrderPoint-[708].Available+IL.Eoq-[708].OnOrder)
--	THEN (IL.QtyOrderPoint-[708].Available-[708].OnOrder)
--	ELSE (IL.QtyOrderPoint-[708].Available+IL.Eoq-[708].OnOrder)
--	END AS ReorderQty,
IL.QtySafetyStock, 
II.ItemType, 
IL.QtyOnHandMax,  
[708].OnHand, 
[708].InUse, 
[708].InStock, 
[708].Committed, 
[708].VendorID,
[708].Name,
[708].MFG

FROM 
	(	ALP_tblInItem_view AS II 
		INNER JOIN ALP_tblInItemLocation_view AS IL
		ON II.ItemId = IL.ItemId 
		INNER JOIN ufxALP_R_AR_In_Q708_QtyAll() as [708] 
			ON ((IL.ItemId = [708].ItemId) AND (IL.LocId = [708].LocId))
	)

WHERE	
		(@WhseID='<ALL>' OR IL.LocId=@WhseID)	AND
		(@VendorID='<ALL>' OR [708].VendorID=@VendorID)	AND
		(@MFG ='<ALL>' OR [708].MFG = @MFG) AND
		(@CATG='<ALL>'OR II.AlpCATG = @CATG) AND
		   II.ItemType<>3 AND 
			((IL.QtyOnHandMax+(CASE WHEN IL.QtyOrderPoint=-1 THEN 0 ELSE IL.QtyOrderPoint END)-[708].Available-[708].OnOrder)>0)
		      AND II.KittedYN=0 AND II.ItemStatus=1 AND
		   --Replaced UsrFld2 with ALPCATG 01/08/16 - ER   
		   (II.AlpCATG<>'Labor' OR II.AlpCATG<>'non-part' OR II.AlpCATG<>'Tools')
		   --Added condition to not appear on report until lower than order point 03/15/17 - ER
		   --Changed to addition symbol 04/04/18 - ER
		   AND ([708].Available+[708].OnOrder)!> IL.QtyOrderPoint
		
ORDER BY II.ItemId 

END