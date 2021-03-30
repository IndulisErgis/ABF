CREATE PROCEDURE [dbo].[ALP_stpSISiteRecBillDelete]
-- Updated for TRAV11 by Josh Gillespie on 04/26/2013
	@RecBillId int
AS
BEGIN
	DELETE FROM [dbo].[ALP_tblArAlpSiteRecBill]
	WHERE	[RecBillId] = @RecBillId
	RETURN 0
END