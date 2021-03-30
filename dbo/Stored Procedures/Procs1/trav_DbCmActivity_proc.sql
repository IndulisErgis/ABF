
--PET:http://webfront:801/view.php?id=240162

CREATE PROCEDURE dbo.trav_DbCmActivity_proc
@UserId pUserID = '', 
@TimeFrame tinyint, -- 0 = Daily, 1 = Weekly, 2 = PTD, 3 = YTD
@WksDate datetime = NULL

AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @NewContacts int, @NewOpportunities int, @ClosedOpportunities int, @OpenOpportunities int
		, @NewTasks int, @CompletedTasks int, @OpenTasks int, @OverdueTasks int
		, @FiscalYear smallint, @Period smallint, @BeginDate datetime

	SELECT @FiscalYear = GlYear, @Period = GlPeriod 
	FROM dbo.tblSmPeriodConversion WHERE @WksDate BETWEEN BegDate AND EndDate

	IF (@TimeFrame = 0)-- Daily
	BEGIN
		SET @BeginDate = @WksDate
	END
	ELSE IF (@TimeFrame = 1)-- Weekly
	BEGIN
		SELECT @BeginDate = DATEADD(dd, -6, @WksDate)
	END
	ELSE IF (@TimeFrame = 2)-- PTD
	BEGIN
		SELECT @BeginDate = BegDate 
		FROM dbo.tblSmPeriodConversion WHERE GlYear = @FiscalYear AND GlPeriod = @Period
	END
	ELSE-- YTD
	BEGIN
		SELECT @BeginDate = MIN(BegDate) 
		FROM dbo.tblSmPeriodConversion WHERE GlYear = @FiscalYear
	END

	--advance @WksDate to the end of the day
	SET @WksDate = DATEADD(SS, -1, (DATEADD(DD, 1, @WksDate)))

	-- New Contacts - number of new contacts added for the time frame
	SELECT @NewContacts = COUNT(ID) 
	FROM dbo.tblCmActivity 
	WHERE [Source] = 1 
		AND EntryDate BETWEEN @BeginDate AND @WksDate 
		AND ((UserID = @UserId) OR (@UserId = ''))

	-- New Opportunities - number of new opportunities created for the time frame based on the Open Date field
	SELECT @NewOpportunities = COUNT(ID) 
	FROM dbo.tblCmOpportunity 
	WHERE OpenDate BETWEEN @BeginDate AND @WksDate 
		AND ((UserID = @UserId) OR (@UserId = ''))

	-- Closed Opportunities - number of closed opportunities created for the time frame based on the Opportunity Close Date field
	SELECT @ClosedOpportunities = COUNT(ID) 
	FROM dbo.tblCmOpportunity 
	WHERE CloseDate BETWEEN @BeginDate AND @WksDate 
		AND ((UserID = @UserId) OR (@UserId = ''))

	-- Open Opportunities - number of open opportunities for the time frame that does not have a value in the Close Date field
	SELECT @OpenOpportunities = COUNT(ID) 
	FROM dbo.tblCmOpportunity 
	WHERE OpenDate BETWEEN @BeginDate AND @WksDate AND ISNULL(CloseDate, '') = '' 
		AND ((UserID = @UserId) OR (@UserId = ''))

	-- New Tasks - number of new tasks for the time frame based on the Entered Date field
	SELECT @NewTasks = COUNT(ID) 
	FROM dbo.tblCmTask 
	WHERE EntryDate BETWEEN @BeginDate AND @WksDate 
		AND ((UserID = @UserId) OR (@UserId = ''))

	-- Completed Tasks - number of completed tasks for the time frame based on the Completed Date field
	SELECT @CompletedTasks = COUNT(ID) 
	FROM dbo.tblCmTask 
	WHERE CompletedDate BETWEEN @BeginDate AND @WksDate 
		AND ((UserID = @UserId) OR (@UserId = ''))

	-- Open Tasks - number of open tasks for the time frame that does not have a value in the Completed Date field
	SELECT @OpenTasks = COUNT(ID) 
	FROM dbo.tblCmTask 
	WHERE EntryDate BETWEEN @BeginDate AND @WksDate AND ISNULL(CompletedDate, '') = '' 
		AND ((UserID = @UserId) OR (@UserId = '')) 

	-- Overdue Tasks - number of overdue tasks for the time frame that is beyond the value in the Due Date field
	SELECT @OverdueTasks = COUNT(ID) 
	FROM dbo.tblCmTask 
	WHERE ActionDate < @BeginDate 
		AND ((UserID = @UserId) OR (@UserId = '')) 

	SELECT @NewContacts AS NewContacts, @NewOpportunities AS NewOpportunities
		, @ClosedOpportunities AS ClosedOpportunities, @OpenOpportunities AS OpenOpportunities
		, @NewTasks AS NewTasks, @CompletedTasks AS CompletedTasks
		, @OpenTasks AS OpenTasks, @OverdueTasks AS OverdueTasks

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbCmActivity_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbCmActivity_proc';

