
CREATE PROCEDURE [dbo].[trav_WMTransferPost_Clear_proc] 
AS  
BEGIN TRY  

--Temp table #PostTransList(Created from BL)- Contains postable TranKey 
--CREATE TABLE #PostTransList( TransId nvarchar(10) NOT NULL PRIMARY KEY CLUSTERED ([TransId]))

Delete dbo.tblWmTransferRcpt
	From dbo.tblWmTransferPick p
    Inner Join #PostTransList t on  p.TranKey = t.TransId 
    Inner Join dbo.tblWmTransfer x on x.[Status] = 2  --Completed
                                              AND t.TransId  = x.TranKey 
	Where dbo.tblWmTransferRcpt.TranPickKey = p.TranPickKey

Delete dbo.tblWmTransferPick
	From #PostTransList t
    Inner Join dbo.tblWmTransfer x on x.[Status] = 2  --Completed
                                              AND t.TransId = x.TranKey 
	Where dbo.tblWmTransferPick.TranKey = t.TransId

Delete dbo.tblWmTransfer
	From #PostTransList t
	Where dbo.tblWmTransfer.[Status] = 2 --Completed
	          AND dbo.tblWmTransfer.TranKey = t.TransId
	
--Remove completed Pick entries that no longer tie to an source transaction
DELETE dbo.tblWmPick
	WHERE [Status] = 2 --completed
		AND [SourceId] = 4 --WM Transfer
		AND	[EntryNum] NOT IN (SELECT [TranKey] FROM dbo.tblWmTransfer)

--Remove completed Receipt entries that no longer tie to an source transaction
DELETE dbo.tblWmRcpt
WHERE [Status] = 2 --completed
	AND [Source] = 1 --WM Transfer
	AND	[EntryNum] NOT IN (SELECT [TranPickKey] FROM dbo.tblWmTransferPick)				
	
END TRY  
BEGIN CATCH  
 EXEC dbo.trav_RaiseError_proc  
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMTransferPost_Clear_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMTransferPost_Clear_proc';

