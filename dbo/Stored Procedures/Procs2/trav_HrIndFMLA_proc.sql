CREATE PROCEDURE [dbo].[trav_HrIndFMLA_proc]
@ActiveAsOfDate DATE,
@DeptIDFrom pDeptID,
@DeptIDThru pDeptID,
@Status TINYINT,
@NotificationFrom DATE,
@NotificationThru DATE,
@ExpectedReturnFrom DATE,
@ExpectedReturnThru DATE,
@LeaveFrom DATE,
@LeaveThru DATE,
@MedicalDueFrom DATE,
@MedicalDueThru DATE

AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #IndPositionID (IndId [dbo].[pEmpID], PositionID [bigint])
	INSERT INTO #IndPositionID EXEC [trav_HrIndEffectivePosition_proc] @ActiveAsOfDate

	CREATE TABLE #IndStatus (IndId [dbo].[pEmpID] NOT NULL, StatusID BIGINT NULL,[IndStatus] TINYINT NULL)
	INSERT INTO #IndStatus EXEC [trav_HrIndEffectiveStatus_proc] @ActiveAsOfDate, @Status

	SELECT * INTO #TempFMLA FROM(
	SELECT DISTINCT ind.IndId, (ind.LastName + ', ' + ind.FirstName + ' ' + ind.MiddleInit) AS Name, ind.Address1, ind.Address2,
	ind.City, ind.[State], ind.ZipCode, ind.HomePhone, (CASE WHEN ts.IndStatus = 1 THEN 'Active' ELSE 'Inactive' END) AS IndividualStatus
	FROM tblHrIndGenInfo ind
	INNER JOIN #IndividualList il ON il.IndId = ind.IndId
	INNER JOIN tblHrIndPosition ip ON ip.IndId = il.IndId
	INNER JOIN tblHrIndStatus s ON il.IndId = s.IndId
	INNER JOIN #IndPositionID tpos ON tpos.IndId = ip.IndId AND tpos.PositionID = ip.ID
	INNER JOIN #IndStatus ts ON tpos.IndId = ts.IndId
	INNER JOIN tblHrIndFMLA fm ON ip.IndId = fm.IndId
	INNER JOIN dbo.tblHrPosition p ON p.ID = ip.PositionID
	LEFT JOIN dbo.tblPaDept d ON p.Department = d.Id
	WHERE 
	((@DeptIDFrom IS NULL) OR (@DeptIDThru IS NULL) OR (p.Department BETWEEN @DeptIDFrom AND @DeptIDThru))
	AND ((@NotificationFrom IS NULL OR @NotificationFrom <= fm.NotifyDate)
		AND (@NotificationThru IS NULL OR @NotificationThru >= fm.NotifyDate)) 
	AND ((@ExpectedReturnFrom IS NULL OR @ExpectedReturnFrom <= fm.ExpReturnDate)
		AND (@ExpectedReturnThru IS NULL OR @ExpectedReturnThru >= fm.ExpReturnDate)) 
	AND ((@LeaveFrom IS NULL OR @LeaveFrom <= fm.LeaveBegDate) 
		AND (@LeaveThru IS NULL OR @LeaveThru >= fm.LeaveBegDate)) 
	AND ((@MedicalDueFrom IS NULL OR @MedicalDueFrom <= fm.MedReCertDate) 
		AND (@MedicalDueThru IS NULL OR @MedicalDueThru >= fm.MedReCertDate))
		)ds

	SELECT * FROM #TempFMLA

	SELECT ind.IndId, fm.NotifyDate, fm.ERResponseDate, fm.DesigNoticeDate, fm.LeaveBegDate, tclt.[Description] AS LeaveType,
	fm.ExpDate, fm.ExpReturnDate, tcl.[Description] AS LeaveReason, tcloc.[Description] AS Location, fm.MedCertDueDate, 
	fm.MedCertRecDate, fm.MedReCertDate, tcs.[Description] AS FMLAStatus, tcd.[Description] AS DeliveryMethod, 
	fm.DeliveryCmnt, fm.Intermittent, fm.MedCertReq, fm.WorkRelated, fm.FMLAHrsPerWeek, fm.FMLANote 
	FROM tblHrIndGenInfo ind
	INNER JOIN #TempFMLA tf ON tf.IndId = ind.IndId
	INNER JOIN tblHrIndFMLA fm ON tf.IndId = fm.IndId
	LEFT JOIN tblHrTypeCode tclt ON tclt.ID = fm.LeaveTypeCodeID
	LEFT JOIN tblHrTypeCode tcl ON tcl.ID = fm.LeaveReasonTypeCodeID
	LEFT JOIN tblHrTypeCode tcloc ON tcloc.ID = fm.LocationTypeCodeID
	LEFT JOIN tblHrTypeCode tcs ON tcs.ID = fm.FMLAStatusTypeCodeID
	LEFT JOIN tblHrTypeCode tcd ON tcd.ID =fm.DeliveryMethodTypeCodeID

END TRY

BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HrIndFMLA_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HrIndFMLA_proc';

