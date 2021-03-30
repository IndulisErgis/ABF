
CREATE VIEW [dbo].[trav_PaEmployeeLeave_view]
AS
--consolidated cross-tab of employee leave amounts
--	includes leave history and unposted checks

SELECT 0 AS [RecType], h.[Id] AS [HistLeaveId], NULL AS [CheckId]
	, h.[EmployeeId], h.[PaYear], h.[PaMonth], h.[LeaveCodeId]
	, CASE WHEN h.[From] = 'BG' 
		THEN h.[AdjustmentAmount]
		ELSE 0
		END AS [Beginning]

	, CASE WHEN h.[From] <> 'BG'
			AND (h.[From] = 'AJ' 
				OR ((h.[From] <> 'VC' AND h.[AdjustmentAmount] > 0) 
				OR (h.[From] = 'VC' AND h.[AdjustmentAmount] < 0)) )
		THEN h.[AdjustmentAmount] 
		ELSE 0 
		END AS [EarnedYTD]

	, CASE WHEN h.[From] <> 'BG'
			AND NOT (h.[From] = 'AJ' 
				OR ((h.[From] <> 'VC' AND h.[AdjustmentAmount] > 0) 
				OR (h.[From] = 'VC' AND h.[AdjustmentAmount] < 0)) )
		THEN -h.[AdjustmentAmount] 
		ELSE 0
		END AS [UsedYTD]
	, 0 AS [UsedPending]
	, 0 AS [EarnedPending]
From [dbo].[tblPaEmpHistLeave] h

UNION ALL
			
SELECT 1 AS [RecType], NULL AS [HistLeaveId], e.[CheckId]
	, c.[EmployeeId], c.[PaYear], NULL AS [PaMonth], e.[LeaveCodeId]
	, 0 AS [Beginning]
	, 0 AS [EarnedYTD]
	, 0 AS [UsedYTD]
	, e.[HoursWorked] AS [UsedPending]
	, 0 AS [EarnedPending]
FROM [dbo].[tblPaCheckEarn] e
INNER JOIN [dbo].[tblPaCheck] c ON e.[CheckId] = c.[Id]
WHERE e.[LeaveCodeId] IS NOT NULL

UNION ALL

SELECT 2 AS [RecType], NULL AS [HistLeaveId], l.[CheckId]
	, c.[EmployeeId], c.[PaYear], NULL AS [PaMonth], l.[LeaveCodeId]
	, 0 AS [Beginning]
	, 0 AS [EarnedYTD]
	, 0 AS [UsedYTD]
	, 0 AS [UsedPending]
	, l.[HoursAccrued] AS [EarnedPending]
FROM [dbo].[tblPaCheckLeave] l
INNER JOIN [dbo].[tblPaCheck] c ON l.[CheckId] = c.[Id]
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_PaEmployeeLeave_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_PaEmployeeLeave_view';

