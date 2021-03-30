
CREATE PROCEDURE [dbo].[trav_PaEmployee_proc]
@groupCode tinyint,
@IncludeSalaried bit = 1,
@TransCutoffDate datetime = NULL,
@PaYear smallint = NULL
AS
BEGIN TRY
	SET NOCOUNT ON

    SELECT  *
    FROM    ( 
               --Select only active SALARIED employees in a group from tblPaEmployee table(When @IncludeSalaried = 0 this query will return zero record)
               SELECT   p.[EmployeeId]  FROM  [dbo].[tblPaEmployee] p
                        INNER JOIN [dbo].[tblSmEmployee] s ON p.EmployeeId = s.EmployeeId
              WHERE     p.[GroupCode] = @groupCode
                        AND s.[Status] = 0
                        AND p.EmployeeType = 1
                        AND @IncludeSalaried = 1
              UNION
              --Select ALL active employees in a group with valid(posted and within cutoff date) earn transactions.
              SELECT DISTINCT p.[EmployeeId] AS [EmployeeId] FROM  [dbo].[tblPaEmployee] p
                        INNER JOIN [dbo].[tblSmEmployee] s ON p.EmployeeId = s.EmployeeId
                        INNER JOIN [dbo].[tblPaTransEarn] t ON t.EmployeeId = p.EmployeeId
              WHERE     p.[GroupCode] = @groupCode
                        AND s.[Status] = 0
                        AND t.PostedYn = 1
						AND t.PaYear = @PaYear
                        AND t.TransDate <= @TransCutoffDate
            ) e
    ORDER BY EmployeeId ASC

END TRY
BEGIN CATCH
	EXEC [dbo].[trav_RaiseError_proc]
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaEmployee_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaEmployee_proc';

