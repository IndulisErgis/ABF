
CREATE PROCEDURE [dbo].[trav_SoOrderDetailInqury_proc]
@PostRun pPostRun, 
@TransId pTransId

AS
BEGIN TRY
	SET NOCOUNT ON

	SELECT d.TransID, d.EntryNum, d.ItemJob, d.LocId, d.ItemId, d.JobId, d.PhaseId, d.JobCompleteYN, d.ItemType, d.Descr, d.AddnlDescr
		, d.CatId, d.TaxClass, d.AcctCode, d.GLAcctSales, d.GLAcctCOGS, d.GLAcctInv
		, SIGN(h.TransType) * d.QtyOrdSell AS QtyOrdSell
		, d.UnitsSell, d.UnitsBase
		, SIGN(h.TransType) * d.QtyShipSell AS QtyShipSell
		, SIGN(h.TransType) * d.QtyShipBase AS QtyShipBase
		, SIGN(h.TransType) * d.QtyBackordSell AS QtyBackordSell
		, d.PriceID, d.UnitPriceSell, d.UnitPriceSellFgn, d.UnitCostSell, d.UnitCostSellFgn
		, SIGN(h.TransType) * d.PriceExt AS PriceExt
		, SIGN(h.TransType) * d.PriceExtFgn AS PriceExtFgn
		, SIGN(h.TransType) * d.CostExtFgn AS CostExtFgn
		, SIGN(h.TransType) * d.CostExt AS CostExt
		, d.PromoID, ISNULL(d.ReqShipDate,h.ReqShipDate) AS ReqShipDate, d.ActShipDate, d.EffectiveRate
		, SIGN(h.TransType) * d.OrigOrderQty AS OrigOrderQty
		, d.BinNum, d.ConversionFactor, d.LottedYN, d.Rep1Id, d.Rep1Pct, d.Rep1CommRate, d.Rep2Id, d.Rep2Pct, d.Rep2CommRate
		, d.UnitCommBasis, d.UnitCommBasisFgn, d.PriceAdjType, d.PriceAdjPct, d.PriceAdjAmt, d.PriceAdjAmtFgn, d.[Status]
		, SIGN(h.TransType) * d.TotQtyOrdSell AS TotQtyOrdSell
		, d.ResCode, d.UnitPriceSellBasis, d.UnitPriceSellBasisFgn, d.BOLNum
		, SIGN(h.TransType) * d.TotQtyShipSell AS TotQtyShipSell
		, d.LineSeq
		, CASE WHEN l.DestType = 2 THEN l.DestId WHEN l.DestType = 1 THEN 'POREQ' WHEN ISNULL(l.DestType, 0) = 0 THEN NULL END AS PoLink, d.CustomerPartNumber as CustomerPartNumber
	FROM dbo.tblSoTransDetail d 
		LEFT JOIN dbo.tblSoTransHeader h ON d.TransID = h.TransId 
		LEFT JOIN dbo.tblSmTransLink l ON d.LinkSeqNum = l.SeqNum 
	WHERE @PostRun IS NULL AND d.TransId = @TransId AND d.GrpId IS NULL AND d.[Status] <> 1

	UNION ALL

	SELECT d.TransID, d.EntryNum, d.ItemJob, d.WhseId, d.PartId, d.JobId, d.PhaseId, d.JobCompleteYN, d.PartType, d.[Desc], d.AddnlDesc
		, d.CatId, d.TaxClass, d.AcctCode, d.GLAcctSales, d.GLAcctCOGS, d.GLAcctInv
		, SIGN(h.TransType) * d.QtyOrdSell AS QtyOrdSell
		, d.UnitsSell, d.UnitsBase
		, SIGN(h.TransType) * d.QtyShipSell AS QtyShipSell
		, SIGN(h.TransType) * d.QtyShipBase AS QtyShipBase
		, SIGN(h.TransType) * d.QtyBackordSell AS QtyBackordSell
		, d.PriceID, d.UnitPriceSell, d.UnitPriceSellFgn, d.UnitCostSell, d.UnitCostSellFgn
		, SIGN(h.TransType) * d.PriceExt AS PriceExt
		, SIGN(h.TransType) * d.PriceExtFgn AS PriceExtFgn
		, SIGN(h.TransType) * d.CostExtFgn AS CostExtFgn
		, SIGN(h.TransType) * d.CostExt AS CostExt
		, PromoID, ISNULL(d.ReqShipDate,h.ReqShipDate) AS ReqShipDate, d.ActShipDate, EffectiveRate
		, SIGN(h.TransType) * d.OrigOrderQty AS OrigOrderQty
		, BinNum, ConversionFactor, LottedYN, d.Rep1Id, d.Rep1Pct, d.Rep1CommRate, d.Rep2Id, d.Rep2Pct, d.Rep2CommRate
		, d.UnitCommBasis, d.UnitCommBasisFgn, d.PriceAdjType, d.PriceAdjPct, d.PriceAdjAmt, d.PriceAdjAmtFgn, d.[Status]
		, SIGN(h.TransType) * d.TotQtyOrdSell AS TotQtyOrdSell
		, d.ResCode, d.UnitPriceSellBasis, d.UnitPriceSellBasisFgn, d.BOLNum
		, SIGN(h.TransType) * d.TotQtyShipSell AS TotQtyShipSell
		, d.LineSeq, NULL AS PoLink ,d.CustomerPartNumber as CustomerPartNumber
	FROM dbo.tblArHistDetail d 
		LEFT JOIN dbo.tblArHistHeader h ON d.TransID = h.TransId AND d.PostRun = h.PostRun 
	WHERE @PostRun IS NOT NULL AND d.PostRun = @PostRun AND d.TransId = @TransId AND d.GrpId IS NULL AND d.EntryNum > 0 
	ORDER BY d.LineSeq

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoOrderDetailInqury_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoOrderDetailInqury_proc';

