
CREATE PROCEDURE dbo.trav_PoPrintOrders_proc
@TransId pTransId = NULL, --set for printing online 
@PrintAdditionalDescription bit = 0, --set for printing additional descriptions
@chkPoComplete bit =1, --option to print completed line items
@PrintAllInBase as bit = 1,        --option to print all in base currency
@PrintType  tinyint =1, --1=new; 2=lost(already printed) 
@CurrID  pCurrency = 'USD',
@BaseCurrencyId pCurrency = 'USD'


AS
SET NOCOUNT ON 
BEGIN TRY


	CREATE TABLE #Temp
	( 
		TransId pTransId NOT NULL 
		PRIMARY KEY CLUSTERED ([TransId])
	)	

	CREATE TABLE #TempProject
	( 
		TransId pTransId NOT NULL,
		EntryNum int NOT NULL,
		ProjId nvarchar(10) NULL,
		PhaseId nvarchar(10) NULL,
		TaskId nvarchar(10) NULL,
		PRIMARY KEY CLUSTERED ([TransId], [EntryNum])
	)

	IF (ISNULL(@TransId, '') = '')
	BEGIN
INSERT INTO #Temp (TransId)

	SELECT  H.TransId
 FROM #tmpTransactionList H
	WHERE 
	 	(H.TransType=9) 
		AND ((H.PrintStatus=0 And @PrintType=1) Or (H.PrintStatus<>0 And @PrintType=2)) 
                AND (@PrintAllInBase=1 OR H.CurrencyID=@CurrID) 
	   			AND ((@chkPoComplete = 1)--must be printing completed line items OR 
				OR EXISTS (SELECT TOP 1 TransId FROM dbo.tblPoTransDetail d WHERE d.TransID = h.TransId AND H.[PrintStatus] = 0)) 
--must have at least 1 active line item
	ORDER BY H.TransId

	END
	ELSE
	BEGIN
		
		--select only one transaction for online processing
		INSERT INTO #Temp (TransId) 
		SELECT h.TransId
		FROM dbo.tblPoTransHeader h 
		WHERE h.TransId = @TransId
			--AND h.VoidYn = 0 --exclude voids
			AND ((@chkPoComplete = 1) --must be printing completed line items OR 
				OR EXISTS (SELECT TOP 1 TransId FROM dbo.tblPoTransDetail d WHERE d.TransID = h.TransId))
 --must have at least 1 active line item
	END

	--direct project
	INSERT INTO #TempProject(TransId, EntryNum, ProjId, PhaseId, TaskId)
	SELECT d.TransID, d.EntryNum, p.ProjectName, j.PhaseId, j.TaskId
	FROM #Temp l INNER JOIN dbo.tblPoTransDetail d (NOLOCK) ON l.TransId = d.TransID 
		INNER JOIN dbo.tblPcProjectDetail j ON d.ProjectDetailId = j.Id 
		INNER JOIN dbo.tblPcProject p ON j.ProjectId = p.Id
		
	--project link		
	INSERT INTO #TempProject(TransId, EntryNum, ProjId, PhaseId, TaskId)
	SELECT d.TransID, d.EntryNum, p.ProjectName, j.PhaseId, j.TaskId
	FROM #Temp l INNER JOIN dbo.tblPoTransDetail d (NOLOCK) ON l.TransId = d.TransID 
		INNER JOIN dbo.tblSmTransLink k ON d.LinkSeqNum = k.SeqNum 
		INNER JOIN dbo.tblPcTrans t ON k.SourceId = t.Id
		INNER JOIN dbo.tblPcProjectDetail j ON t.ProjectDetailId = j.Id 
		INNER JOIN dbo.tblPcProject p ON j.ProjectId = p.Id	
	WHERE k.TransLinkType = 0 AND k.SourceType = 3 AND k.DestType = 2 --Link between Project and PO order
		AND k.SourceStatus <> 2 AND k.DestStatus <> 2 --link is not broken
		

	SELECT v.VendorID,v.Name,v.Contact,v.Addr1,v.Addr2,v.City,v.Region,v.Country,v.PostalCode,
		v.Phone,v.FAX,c.[Desc] AS TermsCodeDesc,g.ReportMethod,h.TransId,h.BatchId,h.TransType, 
		h.TransDate,h.TaxGrpID,h.ReqShipDate AS ReqShipDateHdr,h.LocId AS LocIdHdr,h.ShipToID,
		h.ShipToName,h.ShipToAddr1,h.ShipToAddr2,h.ShipToCity,h.ShipToRegion,h.ShipToCountry,
		h.ShipToPostalCode,h.ShipToAttn,h.ShipVia,h.OrderedBy,h.FOB,h.Notes,h.CurrencyID,h.ExchRate, 
		h.PrintStatus,
        h.MemoTaxLocID1 + ' SALES TAX' as MemoTaxLocID1,
		h.MemoTaxLocID2 + ' SALES TAX' as MemoTaxLocID2,
		h.MemoTaxLocID3 + ' SALES TAX' as MemoTaxLocID3,
		h.MemoTaxLocID4 + ' SALES TAX' as MemoTaxLocID4,
		h.MemoTaxLocID5 + ' SALES TAX' as MemoTaxLocID5,
		 CASE WHEN @PrintAllInBase = 1 THEN @BaseCurrencyId ELSE h.CurrencyID END AS ReportCurrencyID,
        CASE WHEN @PrintAllInBase = 1 THEN h.MemoTaxable ELSE h.MemoTaxableFgn END AS MemoTaxable,
        CASE WHEN @PrintAllInBase = 1 THEN h.MemoFreight ELSE h.MemoFreightFgn END AS MemoFreight,
		CASE WHEN @PrintAllInBase = 1 THEN h.MemoNonTaxable ELSE h.MemoNonTaxableFgn END AS MemoNonTaxable,
        CASE WHEN @PrintAllInBase = 1 THEN h.MemoSalesTax ELSE h.MemoSalesTaxFgn END AS MemoSalesTax,
        CASE WHEN @PrintAllInBase = 1 THEN h.MemoMisc ELSE h.MemoMiscFgn END AS MemoMisc,
		CASE WHEN @PrintAllInBase = 1 THEN h.MemoDisc ELSE h.MemoDiscFgn END AS MemoDisc,
		CASE WHEN @PrintAllInBase = 1 THEN h.MemoPrepaid ELSE h.MemoPrepaidFgn END AS MemoPrepaid,

        CASE WHEN @PrintAllInBase = 1 THEN h.MemoTaxAmt1 ELSE h.MemoTaxAmt1Fgn END AS MemoTaxAmt1,
        CASE WHEN @PrintAllInBase = 1 THEN h.MemoTaxAmt2 ELSE h.MemoTaxAmt2Fgn END AS MemoTaxAmt2,
        CASE WHEN @PrintAllInBase = 1 THEN h.MemoTaxAmt3 ELSE h.MemoTaxAmt3Fgn END AS MemoTaxAmt3,
        CASE WHEN @PrintAllInBase = 1 THEN h.MemoTaxAmt4 ELSE h.MemoTaxAmt4Fgn END AS MemoTaxAmt4,
        CASE WHEN @PrintAllInBase = 1 THEN h.MemoTaxAmt5 ELSE h.MemoTaxAmt5Fgn END AS MemoTaxAmt5,
		d.EntryNum,d.QtyOrd, 
		--d.UnitCost,d.UnitCostFgn,
		CASE WHEN @PrintAllInBase = 1 THEN d.UnitCost ELSE d.UnitCostFgn end UnitCostFgn,
		CASE WHEN @PrintAllInBase = 1 THEN d.ExtCost ELSE d.ExtCostFgn end ExtCost,
		d.ItemId,d.ItemType,p.ProjID,p.PhaseId,p.TaskID,
	    d.LocId AS LocIdDtl,d.UnitsBase,d.Units,
        
        ISNULL(t.RcptQty,0) AS QtyRcvd,CASE WHEN h.transtype = 9 THEN 0 ELSE 
		CASE WHEN d.QtyOrd - ISNULL(t.RcptQty,0) > 0 THEN d.QtyOrd - ISNULL(t.RcptQty,0) ELSE 0 END END AS BackOrdered,
		h.TransId + ISNULL(d.LocId,'') TransLocId,ISNULL(d.Descr,'') Descr,
		CASE WHEN @PrintAdditionalDescription = 1 THEN ISNULL(d.AddnlDescr,'') else '' end AddnlDescr,  
		ISNULL(d.LineSeq, d.EntryNum)LineSeq,
		ISNULL(d.ReqShipDate,h.ReqShipDate) AS ReqShipDateDtl, h.DropShipYn, ISNULL(CountofLocId, 0) CountofLocId, 
		total.GrandTotal
		, ExCost.ExtCostFooter
		, v.OurAcctNum, v.Memo, d.GLDesc, d.CustID, d.ProjName, h.HdrRef, h.ExpReceiptDate AS ExpReceiptDatehdr, ISNULL(d.ExpReceiptDate,h.ExpReceiptDate) AS ExpReceiptDatedtl 
		FROM #Temp l
		INNER JOIN dbo.tblPoTransHeader h on l.TransId = h.TransId
		LEFT JOIN dbo.tblApVendor v (NOLOCK) ON h.VendorId = v.VendorID 
		INNER JOIN dbo.tblApTermsCode c (NOLOCK) ON h.TermsCode = c.TermsCode 
		INNER JOIN dbo.tblSmTaxGroup g (NOLOCK) ON h.TaxGrpID = g.TaxGrpID 
		INNER JOIN dbo.tblPoTransDetail d (NOLOCK) ON h.TransId = d.TransID
		LEFT JOIN #TempProject p ON d.TransID = p.TransId AND d.EntryNum = p.EntryNum
        Left Join
    	(
	    SELECT dd.TransID,  dd.LocId, 
	    case WHen @PrintAllInBase  = 1 then Sum(ExtCost) else Sum(ExtCostFgn) end  as  ExtCostFooter
	    FROM dbo.tblPoTransDetail dd Inner Join  #Temp tl
		ON dd.TransID = tl.TransID
		WHERE dd.TransID =  tl.TransID Group by dd.TransID,  dd.LocId)ExCost
        on ExCost.TransID = h.TransID and ExCost.LocId = d.LocId

		LEFT JOIN (
		SELECT TransID, EntryNum, CAST(Sum(QtyFilled) AS Float) as RcptQty, 
	    CASE WHEN 1 = 1 THEN Sum(ExtCost) else Sum(ExtCostFgn) end as RcptExtCost
			FROM  dbo.tblPoTransLotRcpt (NOLOCK)
			GROUP BY TransID, EntryNum ) t 
         ON d.TransID = t.TransID AND d.EntryNum = t.EntryNum 
		left Join 		
		(Select  cnt.TransID, Min(Entrynum)Entrynum, count (*) as CountofLocId
		from
		(Select  det.TransID,  min(det.Entrynum) Entrynum,  det.TransID + det.LocId as TransIDLocId from dbo.tblPoTransDetail det  
		Inner Join  #Temp t on det.TransID = t.TransID group by det.TransID, det.TransID + det.LocId) cnt
		group by cnt.TransID) CL
		on CL.TransID =l.TransID 
		Left Join
	    (SELECT TransId,
		CASE WHEN @PrintAllInBase = 1 then 
		SUM(MemoTaxable + MemoFreight + MemoNonTaxable + MemoSalesTax + MemoMisc -  MemoPrepaid) else
		SUM(MemoTaxableFgn + MemoFreightFgn + MemoNonTaxableFgn + MemoSalesTaxFgn + MemoMiscFgn -  MemoPrepaidFgn) end GrandTotal
		from dbo.tblPoTransHeader 
		GROUP BY TransID

		) total on l.TransID = total.TransId 

 ORDER BY d.LineSeq





END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoPrintOrders_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoPrintOrders_proc';

