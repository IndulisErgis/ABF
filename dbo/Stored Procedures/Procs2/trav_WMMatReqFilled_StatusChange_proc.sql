
CREATE PROCEDURE [dbo].[trav_WMMatReqFilled_StatusChange_proc]  
AS  
BEGIN TRY    
 --Updates status of filled quantity to posted after GL log entries are generated.   
 UPDATE dbo.tblWmMatReqFilled  SET [Status]= 1 FROM #MatReqPostLog t  
   INNER JOIN dbo.tblWmMatReqFilled f ON f.[Status] = 0 AND t.TranKey = f.TranKey and t.LineNum=f.LineNum 
      
END TRY    
BEGIN CATCH    
 EXEC dbo.trav_RaiseError_proc    
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMMatReqFilled_StatusChange_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMMatReqFilled_StatusChange_proc';

