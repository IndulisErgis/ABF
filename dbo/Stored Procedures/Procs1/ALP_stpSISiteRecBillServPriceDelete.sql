CREATE PROCEDURE [dbo].[ALP_stpSISiteRecBillServPriceDelete]
-- Updated for TRAV11 by Josh Gillespie on 04/26/2013
	@RecBillServPriceId int
AS
	delete from ALP_tblArAlpSiteRecBillServPrice where RecBillServPriceId = @RecBillServPriceId