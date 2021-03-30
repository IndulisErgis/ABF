
CREATE PROCEDURE [dbo].[trav_MpEmployeeTimeLog_proc]
@SortBy  TINYINT
AS
	BEGIN TRY
	SET NOCOUNT ON

SELECT 

	CASE @SortBy 

		WHEN 0 THEN CAST(d.EmployeeId AS nvarchar) 
		WHEN 1 THEN CAST(o.OrderNo + ' :' + CAST(o.ReleaseNo AS nvarchar)  AS nvarchar) 
		WHEN 2 THEN CAST(CONVERT(nvarchar(8), d.TransDate, 112) AS nvarchar) END AS GrpId1
		
	, CASE @SortBy 
	
		WHEN 0 THEN CAST(o.OrderNo + ' :' + CAST(o.ReleaseNo AS nvarchar)  AS nvarchar) 
		WHEN 1 THEN CAST(d.EmployeeId AS nvarchar) 
		WHEN 2 THEN CAST(d.EmployeeId AS nvarchar) END AS GrpId2
		
	, CASE @SortBy 
	
		WHEN 0 THEN CAST(CONVERT(nvarchar(8), d.TransDate, 112) AS nvarchar) 
		WHEN 1 THEN CAST(CONVERT(nvarchar(8), d.TransDate, 112) AS nvarchar) 
		WHEN 2 THEN CAST(o.OrderNo + ' :' + CAST(o.ReleaseNo AS nvarchar)  AS nvarchar) END AS GrpId3 
				
	, d.EmployeeId, o.OrderNo, o.ReleaseNo, d.TransDate, r.ReqId
	, CAST(CONVERT(nvarchar(5), d.BeginTime, 108) AS nvarchar) AS BeginTime
	, CAST(CONVERT(nvarchar(5), d.EndTime, 108) AS nvarchar) AS EndTime
	, d.Hours, d.Mins
	, d.VarianceCode, d.PostedPayrollYn 
		
FROM dbo.tblMpTimeSum s 	

	INNER JOIN dbo.tblMpTimeDtl d ON s.TransId = d.TransId 
	INNER JOIN tblMpRequirements r ON r.TransId =s.TransId 
	INNER JOIN tblMpOrderReleases o on r.ReleaseId=o.Id     
	INNER JOIN #tmpEmpTimeLog t ON t.SeqNo = d.SeqNo 

END TRY
BEGIN CATCH
  EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpEmployeeTimeLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MpEmployeeTimeLog_proc';

