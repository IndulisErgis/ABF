
CREATE PROCEDURE dbo.trav_PcTimeTicketPost_UpdateProject_proc
AS
BEGIN TRY
		
		UPDATE dbo.tblPcProjectDetail SET ActStartDate = t.TransDate
		FROM dbo.tblPcProjectDetail INNER JOIN 
			(SELECT m.ProjectDetailId, MIN(m.TransDate) AS TransDate
			 FROM #PostTransList t INNER JOIN dbo.tblPcTimeTicket m ON t.TransId = m.Id
				INNER JOIN dbo.tblPcProjectDetail d ON m.ProjectDetailId = d.Id 
			 GROUP BY m.ProjectDetailId) t ON dbo.tblPcProjectDetail.Id = t.ProjectDetailId 
		WHERE dbo.tblPcProjectDetail.ActStartDate IS NULL

		UPDATE dbo.tblPcProjectDetail SET ActStartDate = t.TransDate
		FROM dbo.tblPcProjectDetail INNER JOIN 
			(SELECT d.ProjectId, MIN(m.TransDate) AS TransDate
			 FROM #PostTransList t INNER JOIN dbo.tblPcTimeTicket m ON t.TransId = m.Id
				INNER JOIN dbo.tblPcProjectDetail d ON m.ProjectDetailId = d.Id 
				INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id
			 GROUP BY d.ProjectId) t ON dbo.tblPcProjectDetail.ProjectId = t.ProjectId 
		WHERE dbo.tblPcProjectDetail.PhaseId IS NULL AND dbo.tblPcProjectDetail.TaskId IS NULL AND dbo.tblPcProjectDetail.ActStartDate IS NULL		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcTimeTicketPost_UpdateProject_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcTimeTicketPost_UpdateProject_proc';

