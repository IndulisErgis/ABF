
CREATE PROCEDURE dbo.trav_PoPrintPurchaseRequest_proc
@TransId pTransId = NULL, --set for printing online 
@PrintAdditionalDescription bit = 0, --set for printing additional descriptions
@PrintAllInBase as bit = 1,        --option to print all in base currency
@CurrID  pCurrency = 'USD',
@BaseCurrencyId pCurrency = 'USD'

AS
SET NOCOUNT ON 
BEGIN TRY

	CREATE TABLE #TempProject
	( 
		TransId pTransId NOT NULL,
		EntryNum int NOT NULL,
		ProjId nvarchar(10) NULL,
		PhaseId nvarchar(10) NULL,
		TaskId nvarchar(10) NULL,
		PRIMARY KEY CLUSTERED ([TransId], [EntryNum])
	)
	
	--direct project
	INSERT INTO #TempProject(TransId, EntryNum, ProjId, PhaseId, TaskId)
	SELECT d.TransID, d.EntryNum, p.ProjectName, j.PhaseId, j.TaskId
	FROM dbo.tblpoTransHeader l 
	INNER JOIN dbo.tblPoTransDetail d (NOLOCK) ON l.TransId = d.TransID 
	INNER JOIN dbo.tblPcProjectDetail j ON d.ProjectDetailId = j.Id 
	INNER JOIN dbo.tblPcProject p ON j.ProjectId = p.Id
	WHERE  l.TransId = @TransId	
		
	--project link		
	INSERT INTO #TempProject(TransId, EntryNum, ProjId, PhaseId, TaskId)
	SELECT d.TransID, d.EntryNum, p.ProjectName, j.PhaseId, j.TaskId
	FROM dbo.tblpoTransHeader l  
	INNER JOIN dbo.tblPoTransDetail d (NOLOCK) ON l.TransId = d.TransID 
	INNER JOIN dbo.tblSmTransLink k ON d.LinkSeqNum = k.SeqNum 
	INNER JOIN dbo.tblPcTrans t ON k.SourceId = t.Id
	INNER JOIN dbo.tblPcProjectDetail j ON t.ProjectDetailId = j.Id 
	INNER JOIN dbo.tblPcProject p ON j.ProjectId = p.Id	
	WHERE k.TransLinkType = 0 AND l.TransId = @TransId	 AND k.SourceType = 3 AND k.DestType = 2 --Link between Project and PO order		
		AND k.SourceStatus <> 2 AND k.DestStatus <> 2 --link is not broken

	SELECT v.VendorID,v.Name,v.Contact,v.Addr1,v.Addr2,v.City,v.Region,v.Country,v.PostalCode
		, v.Phone,v.FAX,c.[Desc] AS TermsCodeDesc,g.ReportMethod,h.TransId,h.BatchId,h.TransType 
		, h.TransDate,h.TaxGrpID,h.ReqShipDate AS ReqShipDateHdr,h.LocId AS LocIdHdr,h.ShipToID
		, h.ShipToName,h.ShipToAddr1,h.ShipToAddr2,h.ShipToCity,h.ShipToRegion,h.ShipToCountry
		, h.ShipToPostalCode,h.ShipToAttn,h.ShipVia,h.HdrRef
		, Req.RequestedBy 
		, h.FOB,h.Notes,h.CurrencyID,h.ExchRate 
		, h.PrintStatus
        , h.MemoTaxLocID1 + ' SALES TAX' AS MemoTaxLocID1
		, h.MemoTaxLocID2 + ' SALES TAX' AS MemoTaxLocID2
		, h.MemoTaxLocID3 + ' SALES TAX' AS MemoTaxLocID3
		, h.MemoTaxLocID4 + ' SALES TAX' AS MemoTaxLocID4
		, h.MemoTaxLocID5 + ' SALES TAX' AS MemoTaxLocID5
		, CASE WHEN @PrintAllInBase = 1 THEN @BaseCurrencyId ELSE h.CurrencyID END AS ReportCurrencyID
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
		, d.EntryNum,d.QtyOrd 		
		, CASE WHEN @PrintAllInBase = 1 THEN d.UnitCost ELSE d.UnitCostFgn end UnitCostFgn
		, CASE WHEN @PrintAllInBase = 1 THEN d.ExtCost ELSE d.ExtCostFgn end ExtCost
		, d.ItemId,d.ItemType,p.ProjID,p.PhaseId,p.TaskID
	    , d.LocId AS LocIdDtl,d.UnitsBase,d.Units
		, h.TransId + ISNULL(d.LocId,'') TransLocId,ISNULL(d.Descr,'') Descr
		, CASE WHEN @PrintAdditionalDescription = 1 THEN ISNULL(d.AddnlDescr,'') ELSE '' END AddnlDescr  
		, ISNULL(d.LineSeq, d.EntryNum)LineSeq
		,ISNULL(d.ReqShipDate,h.ReqShipDate) AS ReqShipDateDtl, h.DropShipYn, ISNULL(CountofLocId, 0) CountofLocId 
		, total.GrandTotal
		, ExCost.ExtCostFooter
		, v.OurAcctNum, v.Memo, d.GLDesc, d.CustID, d.ProjName
		, Req.ApprovedBy
	FROM  dbo.tblPoTransHeader h 
	LEFT JOIN dbo.tblApVendor v (NOLOCK) ON h.VendorId = v.VendorID 
	LEFT JOIN dbo.tblApTermsCode c (NOLOCK) ON h.TermsCode = c.TermsCode 
	LEFT JOIN dbo.tblSmTaxGroup g (NOLOCK) ON h.TaxGrpID = g.TaxGrpID 
	INNER JOIN dbo.tblPoTransDetail d (NOLOCK) ON h.TransId = d.TransID	
	LEFT JOIN #TempProject p ON d.TransID = p.TransId AND d.EntryNum = p.EntryNum
    LEFT JOIN
    (
		SELECT dd.TransID,  dd.LocId, 
			CASE WHEN @PrintAllInBase  = 1 THEN Sum(ExtCost) ELSE Sum(ExtCostFgn) END  AS  ExtCostFooter
		FROM dbo.tblPoTransDetail dd 
		INNER JOIN  tblPoTransHeader tl
		ON dd.TransID = tl.TransID
		WHERE dd.TransID =  tl.TransID Group by dd.TransID,  dd.LocId
	)ExCost
    ON ExCost.TransID = h.TransID and ExCost.LocId = d.LocId

	LEFT JOIN (
		SELECT  cnt.TransID, Min(Entrynum)Entrynum, count (*) AS CountofLocId
		FROM
		(
			SELECT  det.TransID,  min(det.Entrynum) Entrynum,  det.TransID + det.LocId AS TransIDLocId
			FROM dbo.tblPoTransDetail det  
			INNER JOIN  tblPoTransHeader t ON det.TransID = t.TransID 
			GROUP BY det.TransID, det.TransID + det.LocId
		) cnt
		GROUP BY cnt.TransID
	) CL
	ON CL.TransID =h.TransID 

	LEFT JOIN (
		SELECT TransId,
			CASE WHEN @PrintAllInBase = 1  
				 THEN SUM(MemoTaxable + MemoFreight + MemoNonTaxable + MemoSalesTax + MemoMisc -  MemoPrepaid) 
				 ELSE SUM(MemoTaxableFgn + MemoFreightFgn + MemoNonTaxableFgn + MemoSalesTaxFgn + MemoMiscFgn -  MemoPrepaidFgn) END GrandTotal
		FROM dbo.tblPoTransHeader 
		GROUP BY TransID
	) total 
	ON h.TransID = total.TransId 

	LEFT JOIN (
		SELECT tr.TransId , RequestedBy , ApprovedBy
		FROM tblPoTransRequest tr 
	) Req
	ON h.TransId = Req.TransId
	WHERE  h.TransId = @TransId	
	ORDER BY d.LineSeq

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoPrintPurchaseRequest_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoPrintPurchaseRequest_proc';

