CREATE Procedure ALP_ForceSiteCapitalization(@pNormalizeName bit, @pNormalizeAddress bit) as
Begin
	IF(@pNormalizeName=1)
	BEGIN
		update alp_tblaralpsite set SiteName =upper(SiteName),AlpFirstName=upper(SiteName)
	END
	IF(@pNormalizeAddress=1)
	BEGIN
		update alp_tblaralpsite set  
		Addr1 =upper(Addr1), Addr2 =upper(Addr2),City =upper(City)
	END
END