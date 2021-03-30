CREATE Procedure [dbo].[ALP_ForceCustCapitalization](@pNormalizeName bit, @pNormalizeAddress bit) as
BEGIN


	IF(@pNormalizeName=1)
	BeGIN
		update tblarcust set custname = upper(custname),contact=upper(contact)
		update alp_tblarcust set  alpfirstname =upper(alpfirstname)
	END
	
	IF(@pNormalizeAddress=1)
	BEGIN
		update tblarcust set  addr1=upper(addr1),addr2=upper(addr2),city=upper(city)
	END
END