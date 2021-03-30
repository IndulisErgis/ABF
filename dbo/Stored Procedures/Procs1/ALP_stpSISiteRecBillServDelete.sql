CREATE PROCEDURE [dbo].[ALP_stpSISiteRecBillServDelete]
-- Updated for TRAV11 by Josh Gillespie on 04/26/2013
	@RecBillServId int
AS
	delete from ALP_tblArAlpSiteRecBillServ where RecBillServId = @RecBillServId
RETURN 0