


-- qryAlpEI_FillComboBox_sp 'PRODUCTLINE'

CREATE procedure [dbo].[ALP_qry_AlpFillComboBox_sp]
@ComboType varchar(25) = null
as
BEGIN
	IF @ComboType = 'PRODUCTLINE'
		SELECT DISTINCT ProductLine AS ProductLine 
			FROM tblInItem IT LEFT OUTER JOIN tblInItemLoc ITL 
				on IT.ItemID = ITL.ItemID ORDER BY ProductLine
	ELSE IF @ComboType = 'CATEGORY'
		SELECT DISTINCT UsrFld2 AS Category 
			FROM tblInItem IT LEFT OUTER JOIN tblInItemLoc ITL 
				on IT.ItemID = ITL.ItemID ORDER BY UsrFld2
	ELSE IF @ComboType = 'MANUFACTURER'
		SELECT DISTINCT UsrFld1 AS Manufacturer 
			FROM tblInItem IT LEFT OUTER JOIN tblInItemLoc ITL 
				on IT.ItemID = ITL.ItemID ORDER BY UsrFld1
	ELSE IF @ComboType = 'LOCATION'
		select DISTINCT LocID FROM tblInLoc ORDER BY LocID

END