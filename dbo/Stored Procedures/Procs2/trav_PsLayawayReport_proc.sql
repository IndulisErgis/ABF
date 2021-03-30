
--PET:http://webfront:801/view.php?id=246488

CREATE PROCEDURE dbo.trav_PsLayawayReport_proc
@AgingDate datetime

AS
BEGIN TRY
	SET NOCOUNT ON

	CREATE TABLE #tmpDaysDiffList
	(
		ID bigint NOT NULL, 
		DaysDiff int, 
		PRIMARY KEY CLUSTERED (ID)
	)

	INSERT INTO #tmpDaysDiffList (ID, DaysDiff) 
	SELECT h.ID, DATEDIFF(DD, h.DueDate, @AgingDate) 
	FROM dbo.tblPsTransHeader h INNER JOIN #tmpLayawayList tmp ON h.ID = tmp.ID 

	--header data
	SELECT h.ID AS HeaderID, h.TransIDPrefix + RIGHT(CAST(100000000 + h.TransID AS varchar),8) AS TransID
		, h.TransDate, h.DueDate, h.SoldToID AS CustomerID, c.CustomerName, c.Phone, c.Country
		, d.TotalDue, d.TotalPayment, d.NetDue, d.Aging1, d.Aging2, d.Aging3, d.Aging4 
	FROM dbo.tblPsTransHeader h 
		INNER JOIN #tmpLayawayList tmp ON h.ID = tmp.ID 
		LEFT JOIN 
		(
			SELECT HeaderID, Name AS CustomerName, Phone, Country FROM dbo.tblPsTransContact WHERE [Type] = 0
		) c 
			ON h.ID = c.HeaderID 
		LEFT JOIN 
		(
			SELECT HeaderID
				, SUM(ISNULL(CASE dtl.LineType WHEN -1 THEN 0 ELSE SIGN(dtl.LineType) * dtl.ExtPrice END, 0)) AS TotalDue
				, SUM(ISNULL(CASE dtl.LineType WHEN -1 THEN SIGN(dtl.LineType) * dtl.ExtPrice ELSE 0 END, 0)) AS TotalPayment
				, SUM(CASE WHEN diff.DaysDiff <= 30 THEN ISNULL(SIGN(dtl.LineType) * dtl.ExtPrice, 0) ELSE 0 END) AS NetDue
				, SUM(CASE WHEN diff.DaysDiff BETWEEN 31 AND 60 THEN ISNULL(SIGN(dtl.LineType) * dtl.ExtPrice, 0) ELSE 0 END) AS Aging1
				, SUM(CASE WHEN diff.DaysDiff BETWEEN 61 AND 90 THEN ISNULL(SIGN(dtl.LineType) * dtl.ExtPrice, 0) ELSE 0 END) AS Aging2
				, SUM(CASE WHEN diff.DaysDiff BETWEEN 91 AND 120 THEN ISNULL(SIGN(dtl.LineType) * dtl.ExtPrice, 0) ELSE 0 END) AS Aging3
				, SUM(CASE WHEN diff.DaysDiff > 120 THEN ISNULL(SIGN(dtl.LineType) * dtl.ExtPrice, 0) ELSE 0 END) AS Aging4 
			FROM dbo.tblPsTransDetail dtl 
				INNER JOIN #tmpDaysDiffList diff ON dtl.HeaderID = diff.ID 
			GROUP BY HeaderID
		) d ON h.ID = d.HeaderID

	--detail data
	SELECT HeaderID, d.ID AS DetailID, ParentID, EntryNum, LineSeq, LineType
		, CASE LineType 
			WHEN 1 THEN 10 
			WHEN 2 THEN 20 
			WHEN 3 THEN 30 
			WHEN 4 THEN 40 
			WHEN 5 THEN 50 
			WHEN -3 THEN 60 
			WHEN -2 THEN 70 
			WHEN -1 THEN 80 
			WHEN -4 THEN 90 
			WHEN -5 THEN 100 
			END AS SortByLineType
		, ItemID, Descr, Qty, Unit, ExtPrice 
	FROM dbo.tblPsTransDetail d INNER JOIN #tmpLayawayList tmp ON d.HeaderID = tmp.ID
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsLayawayReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsLayawayReport_proc';

