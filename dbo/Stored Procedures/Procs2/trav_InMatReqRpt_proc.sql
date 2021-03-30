
CREATE Procedure [dbo].[trav_InMatReqRpt_proc]
@TransId pTransId = null, --set for printing online 
@SortBy smallint = 1,
@PrecCurr smallint = 2
AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #Temp (TransId pTransId NOT NULL, PRIMARY KEY CLUSTERED ([TransId]))	

	--CREATE TABLE #MatReqHeader( TransId pTransId NOT NULL, PRIMARY KEY CLUSTERED ([TransId]))

	IF (ISNULL(@TransId, '') = '')
	BEGIN
		INSERT INTO #Temp (TransId)
		SELECT  H.TransId FROM #MatReqHeader H
	END
	ELSE
	BEGIN
		INSERT INTO #Temp (TransId) VALUES (@TransId)
     END


	--header
	SELECT  
		h.TransId,h.ReqType,h.ReqNum,h.DatePlaced,h.DateShipped,h.DateNeeded,
		h.SumYear,h.SumPeriod,h.GLPeriod,h.LocID AS HLocId,h.ShipToId,h.ShipVia,
		h.ReqstdBy,h.ReqTotal,h.Notes,
	    s.ShipToName, s.ShipToAddr1, s.ShipToAddr2
		, l.Descr AS Description, l.Addr1, l.Addr2, ISNULL(l.City,'') City, ISNULL(l.Region,'') Region,
		ISNULL(l.Country,'') Country, l.PostalCode, 
         case @SortBy when 1  then Right(replicate('0', 10) + cast(h.TransId as nvarchar), 10)
					  when 2 then  h.ReqNum 
					  when 3 then CONVERT(nvarchar, h.DateNeeded, 112)
					  when 4 then h.LocID end as  SortBy, sm.SumofCostExt
        FROM #Temp ll
		INNER JOIN dbo.tblInMatReqHeader h  on ll.TransId = h.TransId
			INNER JOIN dbo.tblInLoc l ON h.LocID = l.LocId 
			 LEFT JOIN dbo.tblInShipTo s ON s.ShipToId = h.ShipToId 
        Left Join     
		(Select dd.TransId,h.ReqNum,
		sum(cast(ROUND(dd.QtyFilled*dd.CostUnitStd,@PrecCurr) as float)) AS SumofCostExt  
		FROM #Temp t 
		INNER JOIN dbo.tblInMatReqDetail dd 
		 on t.TransId = dd.TransId
		inner Join dbo.tblInMatReqHeader h on dd.TransId = h.TransId 
		group by dd.TransId, h.ReqNum) sm on  sm.TransId =h.TransId  and sm.ReqNum = h.ReqNum
		ORDER BY (case @SortBy when 1  then Right(replicate('0', 10) + cast(h.TransId as nvarchar), 10)
					  when 2 then  h.ReqNum 
					  when 3 then CONVERT(nvarchar, h.DateNeeded, 112)
					  when 4 then h.LocID end)


	--detail
	SELECT d.TransId, d.LineNum,d.ItemId,d.LocId AS DLocID, d.Descr, h.ReqNum, h.DateNeeded,  h.LocID, 
		d.PhaseId,d.ProjId, ISNULL(d.TaskName, '') TaskName,
		d.TaskId,d.Status,ISNULL(d.PhaseName, '') PhaseName,
		ISNULL(d.ProjName, '') ProjName,
		d.CustId,d.UomBase,d.UomSelling,d.ConvFactor,d.ItemType,d.GLAcctNum,d.GLDescr, CostUnitStd as UnitsCalc,
		d.QtyReqstd,d.QtyFilled,d.QtyBkord, cast(ROUND(d.QtyFilled*d.CostUnitStd,@PrecCurr) as float) AS CostExt, 
		d.JOJobId, d.JOPhaseId, d.JOCostCode, d.HistSeqNum,
		case @SortBy when 1  then Right(replicate('0', 10) + cast(h.TransId as nvarchar), 10)
					  when 2 then  h.ReqNum 
					  when 3 then CONVERT(nvarchar, h.DateNeeded, 112)
                      when 4 then h.LocID end as SortBy, 
		ISNULL(lot.LotYN, 0)LottedYn,
		ISNULL(ser.SerLotYN, 0)SerLottedYn  
        FROM #Temp ll
		INNER JOIN dbo.tblInMatReqHeader h  on ll.TransId = h.TransId
		left Join dbo.tblInMatReqDetail d ON ll.TransId = d.TransId
		Left Join 
		(Select l.TransId, l.LineNum,  1 as LotYN from dbo.tblInMatReqLot l
		inner Join dbo.tblInMatReqDetail dd 
		on dd.TransId = l.TransId and dd.LineNum = l.LineNum
		group by   l.TransId, l.LineNum)lot  on d.TransId = lot.TransId and lot.LineNum  = d.LineNum
        Left Join
        (Select s.TransId, s.LineNum,  1 as SerLotYN from  dbo.tblInMatReqSer s
		inner Join dbo.tblInMatReqDetail dd 
		on dd.TransId = s.TransId and dd.LineNum = s.LineNum
        WHERE ISNULL(s.LotNum, '') <> ''
		group by   s.TransId, s.LineNum)ser  on d.TransId = ser.TransId and ser.LineNum  = d.LineNum
        ORDER BY (case @SortBy when 1  then Right(replicate('0', 10) + cast(h.TransId as nvarchar), 10)
					  when 2 then  h.ReqNum 
					  when 3 then CONVERT(nvarchar, h.DateNeeded, 112)
					  when 4 then h.LocID end)


-- lot info
SELECT l.TransId, l.LineNum, l.SeqNum, l.LotNum, l.QtyOrder, l.QtyFilled, l.QtyBkord
	, l.CostUnit, HistSeqNum, Cmnt, QtySeqNum, ROUND(l.QtyFilled * l.CostUnitFgn, @PrecCurr) AS ExtCost  
FROM #Temp t 
INNER JOIN dbo.tblInMatReqLot l on t.TransId = l.TransId
ORDER BY l.LotNum


-- serial info
SELECT s.TransId, s.LineNum, s.SeqNum, s.LotNum, s.SerNum, 1.00 as QtyFilled
	, s.CostUnit, s.HistSeqNum, s.Cmnt, s.QtySeqNum, ROUND(s.CostUnitfgn, @PrecCurr) AS ExtCost  
FROM #Temp t 
INNER JOIN dbo.tblInMatReqSer s on t.TransId = s.TransId ORDER BY s.LotNum, s.SerNum


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InMatReqRpt_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InMatReqRpt_proc';

