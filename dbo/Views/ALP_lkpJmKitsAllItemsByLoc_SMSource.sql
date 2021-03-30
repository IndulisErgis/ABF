CREATE View [dbo].[ALP_lkpJmKitsAllItemsByLoc_SMSource] as  
               
SELECT     TOP 100 PERCENT S.ItemCode + '**********' AS ItemIdLocId, S.ItemCode AS ItemId, A.AlpKittedYN AS KittedYN, 
			'**********' AS LocId, CAST(1 AS tinyint) AS ItemLocStatus,   
            S.Units AS Uom, [Desc]as Descr, S.Units AS UomDflt, A.AlpVendorKitYn  
FROM         dbo.tblSmItem S INNER JOIN 
dbo.ALP_tblSMItem A ON S.ItemCode = A.AlpItemcode  
GROUP BY S.ItemCode + '**********', S.ItemCode, A.AlpKittedYN, A.AlpVendorKitYn, S.Units, S.[Desc], S.Units  
ORDER BY S.ItemCode