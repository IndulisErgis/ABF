CREATE PROCEDURE [dbo].[trav_HRIndReviewReport_proc]
@AsOfDate DATE,
@DeptIDFrom pDeptID,
@DeptIDThru pDeptID,
@IndStatus TINYINT,
@NextRevDate DATE,
@NextRevTypeFrom NVARCHAR(50),
@NextRevTypeThru NVARCHAR(50),
@SortBy TINYINT

AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #IndPositionID (IndId [dbo].[pEmpID], PositionID [bigint])
	INSERT INTO #IndPositionID EXEC [trav_HrIndEffectivePosition_proc] @AsOfDate

	CREATE TABLE #IndStatus (IndId [dbo].[pEmpID] NOT NULL, StatusID BIGINT NULL,[IndStatus] TINYINT NULL)
	INSERT INTO #IndStatus EXEC [trav_HrIndEffectiveStatus_proc] @AsOfDate, @IndStatus

	CREATE TABLE #TempSalary ([IndId] [dbo].[pEmpID] NULL,
	[Salary] [dbo].[pDecimal] NULL,[EffectiveDate] DATE NULL)

	INSERT INTO #TempSalary (IndId,EffectiveDate)
	SELECT DISTINCT ins.IndId,MAX(ins.EffectiveDate) AS EffectiveDate		
	FROM dbo.tblHrIndSalary ins
	INNER JOIN dbo.tblHrIndReview inr ON inr.IndId = ins.IndId
	INNER JOIN #IndPositionID inl ON inl.IndId = ins.IndId
	GROUP BY ins.IndId

	UPDATE temp SET Salary = CASE WHEN ins.PayType =1 THEN ins.Salary ELSE ins.HourlyRate END
	FROM #TempSalary temp
	INNER JOIN dbo.tblHrIndSalary ins ON ins.EffectiveDate = temp.EffectiveDate AND ins.IndId = temp.IndId

	CREATE TABLE #TempIndividualReview ([ID] BIGINT NULL, [IndId] [dbo].[pEmpID] NULL, [Name] NVARCHAR(75) NULL, [ManagerName] NVARCHAR(75) NULL, [JobTitle] NVARCHAR(100) NULL,
									[DepartmentName] NVARCHAR(60) NULL, [ReviewDate] DATETIME NULL, [NextReviewDate] DATETIME NULL, [ReviewTypeID] BIGINT NULL,
									[NextReviewTypeID] BIGINT NULL, [ReviewType] NVARCHAR(100) NULL, [NextReviewType] NVARCHAR(100) NULL, [Salary] [dbo].[pDecimal] NULL,
									[SortBy] NVARCHAR(75) NULL, [DepartmentId] [dbo].[pDeptID] NULL)

	INSERT INTO #TempIndividualReview (ID, IndId, Name, ManagerName, JobTitle, DepartmentName, 
	ReviewDate, NextReviewDate, ReviewType, NextReviewType, ReviewTypeID, NextReviewTypeID, Salary, SortBy, DepartmentId) 
	SELECT ds.ID, ds.IndId, ds.Name, ds.ManagerName, ds.JobTitle, ds.DepartmentName, ds.ReviewDate, ds.NextReviewDate, 
	ds.ReviewType, ds.NextReviewType, ds.ReviewTypeID,ds.NextReviewTypeID, ds.Salary, ds.SortBy, ds.DepartmentId FROM (SELECT DISTINCT inr.ID, ind.IndId, (ISNULL(ind.LastName,'') + ', ' + ISNULL(ind.FirstName,'') + ' ' + ISNULL(ind.MiddleInit,'')) AS Name,
	CASE 
	WHEN ind.Manager IS NOT NULL THEN (ISNULL(im.LastName, '') + ', ' + ISNULL(im.FirstName,'') + ' ' + ISNULL(im.MiddleInit, '')) ELSE NULL 
	END AS ManagerName,jt.Description AS JobTitle, de.DepartmentName,
	inr.ReviewDate, ISNULL(inr.NextReviewDate, 
		CASE tc.StandardID 
			WHEN 13 THEN DATEADD(DAY, 15, inr.ReviewDate)
			WHEN 14 THEN DATEADD(DAY, 1, inr.ReviewDate)
			WHEN 15 THEN DATEADD(MONTH, 1, inr.ReviewDate)
			WHEN 16 THEN DATEADD(MONTH, 3, inr.ReviewDate)
			WHEN 17 THEN DATEADD(MONTH, 6, inr.ReviewDate)
			WHEN 18 THEN DATEADD(WEEK, 1, inr.ReviewDate)
			WHEN 19 THEN DATEADD(YEAR, 1, inr.ReviewDate)
			WHEN 65 THEN DATEADD(WEEK, 2, inr.ReviewDate)
		  END) AS NextReviewDate, inr.ReviewTypeID, ISNULL(inr.NextReviewTypeID, inr.ReviewTypeID) AS NextReviewTypeID, rt.Description AS ReviewType, ISNULL(rt2.Description,rt.Description) AS NextReviewType, sal.Salary, 
	CASE @SortBy WHEN 0 THEN ind.IndId WHEN 1 THEN de.Id 
	WHEN 2 THEN (im.LastName + ' ' + im.FirstName + ' ' + im.MiddleInit)
	WHEN 3 THEN rt.Description END AS SortBy,
	de.Id AS DepartmentId
	FROM dbo.tblHrIndGenInfo ind
	INNER JOIN #IndividualList il ON il.IndId = ind.IndId
	INNER JOIN tblHrIndPosition ip ON ip.IndId = ind.IndId
	INNER JOIN tblHrIndStatus s ON ind.IndId = s.IndId
	INNER JOIN #IndPositionID tpos ON tpos.IndId = ip.IndId AND tpos.PositionID = ip.ID
	INNER JOIN #IndStatus ts ON tpos.IndId = ts.IndId
	INNER JOIN dbo.tblHrPosition p ON p.ID = ip.PositionID
	INNER JOIN dbo.tblHrIndReview inr ON inr.IndId = ind.IndId 
	INNER JOIN dbo.tblHrReviewType rt ON inr.ReviewTypeID= rt.ID
	LEFT JOIN dbo.tblHrReviewType rt2 ON inr.NextReviewTypeID= rt2.ID
	LEFT JOIN dbo.tblHrTypeCode tc ON tc.ID = ISNULL(rt2.FrequencyTypeCodeID, rt.FrequencyTypeCodeID)
	LEFT JOIN dbo.tblHrJobTitle jt ON jt.ID = p.JobTypeCodeId
	LEFT JOIN dbo.tblPaDept de ON de.Id = p.Department
	LEFT JOIN dbo.tblHrIndGenInfo im ON im.IndId = ind.Manager
	LEfT JOIN #TempSalary sal ON sal.IndId = ind.IndId
	WHERE (@AsOfDate >= inr.ReviewDate)AND (@DeptIDFrom IS NULL OR @DeptIDThru IS NULL OR (p.Department BETWEEN @DeptIDFrom AND @DeptIDThru))
	AND (@NextRevTypeFrom IS NULL OR ISNULL(rt2.Description,rt.Description) >= @NextRevTypeFrom) AND(@NextRevTypeThru IS NULL OR ISNULL(rt2.Description,rt.Description) <= @NextRevTypeThru)
	) ds WHERE (@NextRevDate IS NULL OR NextReviewDate <= @NextRevDate) 

	SELECT ID, IndId, Name, ManagerName, JobTitle, DepartmentName, ReviewDate, NextReviewDate, ReviewType, 
	NextReviewType, Salary, SortBy, DepartmentId FROM #TempIndividualReview

	SELECT DISTINCT inr.ID, ind.IndId, rtc.Description AS Category,rtc.Weight, 
	irc.Rating, irc.Score, irc.Notes, rt.Description as ReviewType
	FROM #TempIndividualReview ind
	INNER JOIN dbo.tblHrIndReview inr ON inr.ID = ind.ID 
	INNER JOIN dbo.tblHrReviewType rt ON inr.ReviewTypeID= rt.ID
	INNER JOIN dbo.tblHrIndReviewByCategory irc ON inr.ID = irc.ReviewId
	INNER JOIN dbo.tblHrReviewTypeCat rtc ON  irc.ReviewTypeCatID= rtc.ID

	SELECT DISTINCT inr.ID, ind.IndId, rtc.Description AS Category,rtc.Weight, rt.Description as ReviewType
	FROM #TempIndividualReview ind
	INNER JOIN dbo.tblHrIndReview inr ON inr.ID = ind.ID 
	INNER JOIN dbo.tblHrReviewType rt ON ISNULL(inr.NextReviewTypeID, inr.ReviewTypeID) = rt.ID
	INNER JOIN dbo.tblHrReviewTypeCat rtc ON  rt.ID= rtc.ReviewTypeID
END TRY

BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HRIndReviewReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HRIndReviewReport_proc';

