
CREATE PROCEDURE [dbo].[trav_WMMatReqTransPost_Clear_proc]      
AS      
BEGIN TRY  
SET NOCOUNT ON
--Only material requisition with completed status and its related information should be deleted.  

--Remove the processed filled records  

Delete dbo.tblWmMatReqFilled      
	From #MatReqPostLog l  INNER JOIN dbo.tblWmMatReq h ON h.TranKey=l.TranKey  and h.[Status]=1     
	Where dbo.tblWmMatReqFilled.TranKey = l.TranKey      
	--And dbo.tblWmMatReqFilled.LineNum = l.LineNum        

--Remove the processed request records       
Delete dbo.tblWmMatReqRequest      
	From #MatReqPostLog l INNER JOIN dbo.tblWmMatReq h ON h.TranKey=l.TranKey  and h.[Status]=1       
	Where dbo.tblWmMatReqRequest.TranKey = l.TranKey      
	--And dbo.tblWmMatReqRequest.LineNum = l.LineNum      
  
--Remove any headers that have no remaining detail      
DELETE dbo.tblWmMatReq       
	WHERE TranKey NOT IN (SELECT TranKey FROM dbo.tblWmMatReqRequest)      

--Remove completed Pick entries that no longer tie to an source transaction
DELETE dbo.tblWmPick
	WHERE [Status] = 2 --completed
	AND [SourceId] = 8 --WM Material Req
	AND	[EntryNum] NOT IN (SELECT [TranKey] FROM dbo.tblWmMatReq)

--Remove completed Receipt entries that no longer tie to an source transaction
DELETE dbo.tblWmRcpt
	WHERE [Status] = 2 --completed
	AND [Source] = 8 --WM Material Req Return
	AND	[EntryNum] NOT IN (SELECT [LineNum] FROM dbo.tblWmMatReqRequest)	

END TRY      
BEGIN CATCH      
 EXEC dbo.trav_RaiseError_proc      
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMMatReqTransPost_Clear_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMMatReqTransPost_Clear_proc';

