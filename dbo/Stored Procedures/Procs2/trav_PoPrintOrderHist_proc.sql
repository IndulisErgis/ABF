
CREATE PROCEDURE dbo.trav_PoPrintOrderHist_proc
@PostRun pPostRun = '20091104122350', 
@TransId pTransID = '00000011', 
@PrintAdditionalDescription bit = 0,  
@PrintAllInBase bit = 1

AS
SET NOCOUNT ON
BEGIN TRY
	CREATE TABLE #Temp
	(
		PostRun pPostRun NOT NULL, 
		TransId pTransId NOT NULL
		PRIMARY KEY CLUSTERED ([PostRun], [TransId])
	)

	INSERT INTO #Temp (PostRun, TransId) 
	SELECT h.PostRun, h.TransId 
	FROM dbo.tblPoHistHeader h 
	WHERE h.PostRun = @PostRun AND h.TransId = @TransId

	SELECT v.VendorID, v.Name, v.Contact, v.Addr1, v.Addr2, v.City, v.Region, v.Country, v.PostalCode
		, v.Phone, v.FAX, c.[Desc] AS TermsCodeDesc, g.ReportMethod, h.TransId, h.BatchId, h.TransType
		, h.TransDate, h.TaxGrpID, h.ReqShipDate AS ReqShipDateHdr, h.LocId AS LocIdHdr, h.ShipToID
		, h.ShipToName, h.ShipToAddr1, h.ShipToAddr2, h.ShipToCity, h.ShipToRegion, h.ShipToCountry
		, h.ShipToPostalCode, h.ShipToAttn, h.ShipVia, h.OrderedBy, h.FOB, h.Notes, h.CurrencyID, h.ExchRate
		, h.PrintStatus
		, h.MemoTaxLocID1 + ' SALES TAX' AS MemoTaxLocID1
		, h.MemoTaxLocID2 + ' SALES TAX' AS MemoTaxLocID2
		, h.MemoTaxLocID3 + ' SALES TAX' AS MemoTaxLocID3
		, h.MemoTaxLocID4 + ' SALES TAX' AS MemoTaxLocID4
		, h.MemoTaxLocID5 + ' SALES TAX' AS MemoTaxLocID5
		, CASE WHEN @PrintAllInBase = 1 THEN h.MemoTaxable ELSE h.MemoTaxableFgn END AS MemoTaxable
		, CASE WHEN @PrintAllInBase = 1 THEN h.MemoFreight ELSE h.MemoFreightFgn END AS MemoFreight
		, CASE WHEN @PrintAllInBase = 1 THEN h.MemoNonTaxable ELSE h.MemoNonTaxableFgn END AS MemoNonTaxable
		, CASE WHEN @PrintAllInBase = 1 THEN h.MemoSalesTax ELSE h.MemoSalesTaxFgn END AS MemoSalesTax
		, CASE WHEN @PrintAllInBase = 1 THEN h.MemoMisc ELSE h.MemoMiscFgn END AS MemoMisc
		, CASE WHEN @PrintAllInBase = 1 THEN h.MemoDisc ELSE h.MemoDiscFgn END AS MemoDisc
		, CASE WHEN @PrintAllInBase = 1 THEN h.MemoPrepaid ELSE h.MemoPrepaidFgn END AS MemoPrepaid
		, CASE WHEN @PrintAllInBase = 1 THEN h.MemoTaxAmt1 ELSE h.MemoTaxAmt1Fgn END AS MemoTaxAmt1
		, CASE WHEN @PrintAllInBase = 1 THEN h.MemoTaxAmt2 ELSE h.MemoTaxAmt2Fgn END AS MemoTaxAmt2
		, CASE WHEN @PrintAllInBase = 1 THEN h.MemoTaxAmt3 ELSE h.MemoTaxAmt3Fgn END AS MemoTaxAmt3
		, CASE WHEN @PrintAllInBase = 1 THEN h.MemoTaxAmt4 ELSE h.MemoTaxAmt4Fgn END AS MemoTaxAmt4
		, CASE WHEN @PrintAllInBase = 1 THEN h.MemoTaxAmt5 ELSE h.MemoTaxAmt5Fgn END AS MemoTaxAmt5
		, d.EntryNum, d.QtyOrd
		, CASE WHEN @PrintAllInBase = 1 THEN d.UnitCost ELSE d.UnitCostFgn END AS UnitCostFgn
		, CASE WHEN @PrintAllInBase = 1 THEN d.ExtCost ELSE d.ExtCostFgn END AS ExtCost
		, d.ItemId, d.ItemType, d.ProjID, d.PhaseId, d.TaskID, d.LocId AS LocIdDtl, d.UnitsBase, d.Units
		, ISNULL(t.RcptQty, 0) AS QtyRcvd
		, CASE WHEN h.TransType = 9 THEN 0 ELSE 
			CASE WHEN d.QtyOrd - ISNULL(t.RcptQty, 0) > 0 THEN d.QtyOrd - ISNULL(t.RcptQty, 0) 
				ELSE 0 END END AS BackOrdered
		, h.TransId + ISNULL(d.LocId, '') TransLocId, ISNULL(d.Descr, '') AS Descr
		, CASE WHEN @PrintAdditionalDescription = 1 THEN ISNULL(d.AddnlDescr, '') ELSE '' END AS AddnlDescr
		, ISNULL(d.LineSeq, d.EntryNum) AS LineSeq,ISNULL(d.ReqShipDate,h.ReqShipDate) AS ReqShipDateDtl, h.DropShipYn
		, ISNULL(CountofLocId, 0) AS CountofLocId, total.GrandTotal, ExCost.ExtCostFooter
		, v.OurAcctNum, v.Memo, d.GLDesc, d.CustID, d.ProjName 
	FROM #Temp l 
		INNER JOIN dbo.tblPoHistHeader h ON l.PostRun = h.PostRun AND l.TransId = h.TransId 
		INNER JOIN dbo.tblApVendor v (NOLOCK) ON h.VendorId = v.VendorID 
		INNER JOIN dbo.tblApTermsCode c (NOLOCK) ON h.TermsCode = c.TermsCode 
		INNER JOIN dbo.tblSmTaxGroup g (NOLOCK) ON h.TaxGrpID = g.TaxGrpID 
		INNER JOIN dbo.tblPoHistDetail d (NOLOCK) ON h.PostRun = d.PostRun AND h.TransId = d.TransID 
		LEFT JOIN 
		(
			SELECT dd.PostRun, dd.TransID, dd.LocId
				, CASE WHEN @PrintAllInBase = 1 THEN SUM(ExtCost) ELSE SUM(ExtCostFgn) END AS ExtCostFooter 
			FROM dbo.tblPoHistDetail dd 
				INNER JOIN #Temp tl ON dd.PostRun = tl.PostRun AND dd.TransID = tl.TransID 
			WHERE dd.TransID = tl.TransID 
			GROUP BY dd.PostRun, dd.TransID, dd.LocId
		) ExCost ON ExCost.PostRun = h.PostRun AND ExCost.TransID = h.TransID AND ExCost.LocId = d.LocId 
		LEFT JOIN 
		(
			SELECT rcpt.PostRun, rcpt.TransID, EntryNum, CAST(SUM(QtyFilled) AS float) AS RcptQty
				, CASE WHEN 1 = 1 THEN SUM(ExtCost) ELSE SUM(ExtCostFgn) END AS RcptExtCost 
			FROM dbo.tblPoHistLotRcpt rcpt (NOLOCK) 
				INNER JOIN #Temp tr ON rcpt.PostRun = tr.PostRun AND rcpt.TransID = tr.TransID 
			GROUP BY rcpt.PostRun, rcpt.TransID, EntryNum 
		) t ON d.PostRun = t.PostRun AND d.TransID = t.TransID AND d.EntryNum = t.EntryNum 
		LEFT JOIN 	 
		(
			SELECT cnt.PostRun, cnt.TransID, MIN(Entrynum) AS Entrynum, COUNT(*) AS CountofLocId 
			FROM
			(
				SELECT det.PostRun, det.TransID, MIN(det.Entrynum) AS Entrynum, det.TransID + det.LocId AS TransIDLocId 
				FROM dbo.tblPoHistDetail det 
					INNER JOIN #Temp t ON det.PostRun = t.PostRun AND det.TransID = t.TransID 
				GROUP BY det.PostRun, det.TransID, det.TransID + det.LocId
			) cnt
			GROUP BY cnt.PostRun, cnt.TransID
		) CL ON CL.PostRun =l.PostRun AND CL.TransID =l.TransID 
		LEFT JOIN 
		(
			SELECT hdr.PostRun, hdr.TransId
				, CASE WHEN @PrintAllInBase = 1 
					THEN SUM(MemoTaxable + MemoFreight + MemoNonTaxable + MemoSalesTax + MemoMisc - MemoPrepaid) 
					ELSE SUM(MemoTaxableFgn + MemoFreightFgn + MemoNonTaxableFgn + MemoSalesTaxFgn + MemoMiscFgn 
						- MemoPrepaidFgn) END AS GrandTotal 
			FROM dbo.tblPoHistHeader hdr 
				INNER JOIN #Temp th ON hdr.PostRun = th.PostRun AND hdr.TransID = th.TransID 
			GROUP BY hdr.PostRun, hdr.TransID
		) total ON l.PostRun = total.PostRun AND l.TransID = total.TransId 
	ORDER BY d.LineSeq
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoPrintOrderHist_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoPrintOrderHist_proc';

