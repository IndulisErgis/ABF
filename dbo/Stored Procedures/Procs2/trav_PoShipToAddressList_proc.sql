
CREATE PROCEDURE [dbo].[trav_PoShipToAddressList_proc]

AS
SET NOCOUNT ON
BEGIN TRY

	SELECT  s.ShiptoId, ShiptoName, Addr1, Addr2, City, Region, Country, PostalCode, IntlPrefix, Phone, Fax, Attn, ShipVia, 
			TaxLocID, DistCode, Email, Internet, ts, CF
	FROM dbo.tblPoShipTo s INNER JOIN #tmpShipToList t ON s.ShiptoId = t.ShiptoId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoShipToAddressList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoShipToAddressList_proc';

