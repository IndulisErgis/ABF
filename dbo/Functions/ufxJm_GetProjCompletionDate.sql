
CREATE function dbo.ufxJm_GetProjCompletionDate
(
	@ProjectID varchar(10)
)
returns datetime
AS
BEGIN
declare @ProjCompletionDate datetime
SET @ProjCompletionDate = null
IF dbo.ufxJm_GetProjStatus(@ProjectID) = 'Completed'
BEGIN
	SET @ProjCompletionDate = 
		(SELECT Max(ST.CompleteDate)   
	   	FROM dbo.tblJmSvcTkt ST
	   	WHERE  ST.ProjectID = @ProjectID
			AND ST.Status IN ('Completed','Closed')	)
END
RETURN @ProjCompletionDate
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ufxJm_GetProjCompletionDate] TO [JMCommissions]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ufxJm_GetProjCompletionDate] TO PUBLIC
    AS [dbo];

