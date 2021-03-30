
CREATE PROCEDURE [dbo].[trav_ArShipToAddressReport_proc]

AS
SET NOCOUNT ON
BEGIN TRY

	SELECT a.CustId, a.PostalCode, a.ShiptoId, a.ShiptoName, a.Addr1, a.Addr2, a.City, a.Region, a.Country, a.IntlPrefix, a.Phone, a.Fax, a.Attn, 
		   a.ShipVia, a.TaxLocID, a.TerrId, a.DistCode, s.PostalCodeMask, a.Email, a.Internet, s.IntlPrefixMask, s.PhoneMask, s.Name AS CountryName 
		FROM dbo.tblArShipTo AS a INNER JOIN dbo.#tmpCountryList AS s ON a.Country = s.Country
			 INNER JOIN #tmpShipToAddress AS t ON a.CustId = t.CustId AND a.ShiptoId = t.ShiptoId
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArShipToAddressReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArShipToAddressReport_proc';

