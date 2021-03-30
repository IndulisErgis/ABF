
CREATE PROCEDURE [dbo].[trav_FaAssetValueReport_proc]
AS
BEGIN TRY
 	SET NOCOUNT ON
        SELECT [hdr].[AssetID],
               [hdr].[AssetPrefix],
               [hdr].[AssetDescr],
               [hdr].[TagNo],
               [hdr].[Locat1],
               [hdr].[Locat2],
               [hdr].[Locat3],
               [hdr].[AssetStatus],
               [hdr].[TaxClass],
               [hdr].[GLAsset],
               [hdr].[AcquisitionDate],
               [hdr].[Qty],
               [hdr].[InsuredValue],
               [hdr].[InsuredValueDate],
               [hdr].[AssessedValue],
               [hdr].[AssessedValueDate],
               [hdr].[ReplaceCost],
               [hdr].[PlacedInServDate],
               ([hdr].[ReplaceCost] - [hdr].[AssessedValue]) AS [AtRiskAssess],
               ([hdr].[ReplaceCost] - [hdr].[InsuredValue]) AS [AtRiskInsur],
               [dtl].[NetVal]
          FROM [dbo].[tblFaAsset] [hdr]
    INNER JOIN [dbo].[#Filter] [fltr]
            ON ([fltr].[AssetID] = [hdr].[AssetID])
     LEFT JOIN (    SELECT [val].[AssetID],
                           ([val].[BaseCost] - [val].[Expense179] - ISNULL([act].[TotDeprTaken],0) - [val].[CurrDepr]) AS [NetVal]
                      FROM [dbo].[tblFaAssetDepr] [val]
                INNER JOIN [dbo].[tblFaOptionDepr] [key]
                        ON [key].[DeprType] = [val].[DeprcType]
                 LEFT JOIN (  SELECT [DeprID],
                                     SUM([Amount]) AS [TotDeprTaken]
                                FROM [dbo].[tblFaAssetDeprActivity]
                            GROUP BY [DeprID]) [act]
                        ON [act].[DeprID] = [val].[ID]
                     WHERE ([key].[Type] = 1) ) [dtl]
            ON [dtl].[AssetID] = [hdr].[AssetID]
END TRY
BEGIN CATCH
	EXEC [dbo].[trav_RaiseError_proc]
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_FaAssetValueReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_FaAssetValueReport_proc';

