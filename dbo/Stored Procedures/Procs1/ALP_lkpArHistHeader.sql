  CREATE Procedure dbo.ALP_lkpArHistHeader
	(@InvcNum varchar(15))
AS
SELECT TransID,CustID FROM ALP_tblArHistHeader_view WHERE InvcNum=@InvcNum