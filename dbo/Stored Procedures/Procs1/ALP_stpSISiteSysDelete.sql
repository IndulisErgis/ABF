CREATE PROCEDURE [dbo].[ALP_stpSISiteSysDelete]
	-- Updated for TRAV11 by Josh Gillespie on 04/26/2013
	@SysId int
AS
	delete from ALP_tblArAlpSiteSys where SysId = @SysId