

Create procedure [dbo].[ALP_qryAlpEI_GetCompInfo_sp]
(
	@CompID pCompID
)
As

SELECT CompID, Name, Country, Addr1, Addr2, City, Region, PostalCode,Phone  
FROM SYS.dbo.tblSmCompInfo where CompID = @CompID