CREATE PROCEDURE [dbo].[ALP_R_AP_R303_FindPOinHistory]
(
	@PONum varchar(10),
	@VendorID varchar(10),
	@InvoiceNum varchar(15),
	@StartDate dateTime
)
AS
set nocount on
SELECT 
	CASE 
	WHEN PHH.PONum IS NULL 
	THEN '<none>' ELSE PHH.PONum 
	END AS PONum, 
	PHH.VendorId, 
	PHH.InvoiceNum, 
	PHH.InvoiceDate, 
	PHH.Subtotal, 
	PHD.PartId, 
	PHD.Qty, 
	PHD.Units, 
	PHD.UnitCost, 
	PHD.ExtCost
	
FROM tblApHistHeader AS PHH
	INNER JOIN tblApHistDetail AS PHD 
		ON	(PHH.PostRun = PHD.PostRun) 
		AND 
			(PHH.TransId = PHD.TransID) 
		AND 
			(PHH.InvoiceNum = PHD.InvoiceNum)

WHERE 
		PHH.InvoiceDate > @StartDate
		AND 
		(
			((PHH.PONum Like '%' + @PONum + '%') OR (@PONum ='<ALL>'))
		AND 
			((PHH.VendorId Like '%' + @VendorID + '%') OR (@VendorID ='<ALL>'))
		AND 
			((PHH.InvoiceNum Like '%' + @InvoiceNum + '%') OR (@InvoiceNum ='<ALL>'))
)