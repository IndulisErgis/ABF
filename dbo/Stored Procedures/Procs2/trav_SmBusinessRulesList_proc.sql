
CREATE PROCEDURE [dbo].[trav_SmBusinessRulesList_proc]

@PrintBy Tinyint = 0, -- 0-Application; 1-Group Configuration; 2-Role
@RptLang nvarchar(3) = 'ENG'

AS
SET NOCOUNT ON
BEGIN TRY

	DECLARE @sql nvarchar (max)	
	
	CREATE TABLE #tmp
	(	
		GroupValue nvarchar(max),
		GroupDescription nvarchar(max), 
		Caption nvarchar(255), 
		ConfigValue nvarchar(max), 
		GroupDisplaySeq smallint,
		ValueList nvarchar(max), 
		SubGroupCaption nvarchar(max),
		SubGroupDisplaySeq nvarchar(max),
		RecType smallint, 
		AppId nvarchar(10)
	)
	
	IF @PrintBy = 0 -- Application	
	BEGIN
		INSERT INTO #tmp ( GroupValue, GroupDescription, Caption, ConfigValue, GroupDisplaySeq,
				ValueList, SubGroupCaption, SubGroupDisplaySeq, RecType, AppId )
			SELECT c.AppId AS [GroupValue], i.[Description] AS GroupDescription, p.Caption, v.ConfigValue, c.DispSeq AS GroupDisplaySeq, 
			l.Caption ValueList, gp.Caption AS SubGroupCaption, g.DispSeq AS SubGroupDisplaySeq, c.RecType, c.AppId
			FROM #tmpSmConfig c 
			INNER JOIN dbo.tblSmConfigValue v ON v.ConfigRef = c.ConfigRef 
			INNER JOIN #tmpSysCaption p ON c.CaptionId = p.ObjectId  -- Business rules captions
			INNER JOIN #tmpSmConfig g ON c.CTConfigRef = g.ConfigRef 
			INNER JOIN #tmpSysCaption gp ON g.CaptionId = gp.ObjectId -- Group captions
			INNER JOIN ( SELECT a.AppID, s.[Description], a.Notes, s.ClientProgYn
						 FROM   dbo.tblSmApp_Installed AS a 
							INNER JOIN #tmpSmApp AS s ON a.AppID = s.AppID
					   ) i ON c.AppId = i.AppId       
			LEFT JOIN #tmpSysCaption l ON c.ValueListId = l.ObjectId
			INNER JOIN #tmpBusinessRuleList tmp ON tmp.ConfigRef = c.ConfigRef 
			WHERE ISNULL(v.RoleId,'') = '' AND c.RecType < 2048 -- Only include actual business rules 
				AND p.[LangId] = @RptLang AND gp.[LangId] = @RptLang AND (l.ObjectId IS NULL OR (l.ObjectId IS NOT NULL AND l.[LangId] = @RptLang 
				AND (c.RecType IN (1024,1029,1030) OR (c.RecType NOT IN (1024,1029,1030) AND c.AppId = l.AppId))))
			ORDER BY c.AppId,g.DispSeq, c.DispSeq	
	END

	ELSE IF @PrintBy = 1  -- Group Configuration
	BEGIN	
		INSERT INTO #tmp ( GroupValue, GroupDescription, Caption, ConfigValue, GroupDisplaySeq,
				ValueList, SubGroupCaption, SubGroupDisplaySeq, RecType, AppId )
			SELECT CAST(gcc.Caption AS nvarchar) AS [GroupValue], gcc.Caption AS GroupDescription, 
				CASE WHEN c.RecType = 1 OR c.RecType = 6 THEN c.AppId + ' - ' + CAST(p.Caption AS nvarchar) ELSE i.[Description] END AS Caption, 
				v.ConfigValue, c.DispSeq AS GroupDisplaySeq, l.Caption ValueList, gp.Caption AS SubGroupCaption, 
				CAST(gp.Caption AS nvarchar) AS SubGroupDisplaySeq, 
				c.RecType, c.AppId
			FROM #tmpSmConfig c 
			INNER JOIN dbo.tblSmConfigValue v ON v.ConfigRef = c.ConfigRef 
			INNER JOIN #tmpSysCaption p ON c.CaptionId = p.ObjectId  -- Business rules captions
			INNER JOIN #tmpSmConfig g ON c.CTConfigRef = g.ConfigRef 
			INNER JOIN #tmpSysCaption gp ON g.CaptionId = gp.ObjectId -- Group captions
			INNER JOIN #tmpSmConfig gc ON c.OptConfigRef = gc.ConfigRef -- Group configuration
			INNER JOIN #tmpSysCaption gcc ON gc.CaptionId = gcc.ObjectId
			INNER JOIN ( SELECT a.AppID, s.[Description], a.Notes, s.ClientProgYn
						 FROM   dbo.tblSmApp_Installed AS a 
							INNER JOIN #tmpSmApp AS s ON a.AppID = s.AppID
					   ) i ON c.AppId = i.AppId       
			LEFT JOIN #tmpSysCaption l ON c.ValueListId = l.ObjectId
			INNER JOIN #tmpBusinessRuleList tmp ON tmp.ConfigRef = c.ConfigRef 
			WHERE  	ISNULL(v.RoleId,'') = '' AND c.RecType < 2048 -- Only include actual business rules 
				AND gp.[LangId] = @RptLang AND (l.ObjectId IS NULL OR (l.ObjectId IS NOT NULL AND l.[LangId] = @RptLang 
				AND (c.RecType IN (1024,1029,1030) OR (c.RecType NOT IN (1024,1029,1030) AND c.AppId = l.AppId))))
				AND c.OptConfigRef <> 0 AND gcc.[LangId] = @RptLang AND p.[LangId] = @RptLang
			ORDER BY CAST(gcc.Caption AS nvarchar),CAST(gp.Caption AS nvarchar), i.[Description]
	END

	ELSE IF @PrintBy = 2  -- Role
	BEGIN
		INSERT INTO #tmp ( GroupValue, GroupDescription, Caption, ConfigValue, GroupDisplaySeq,
				ValueList, SubGroupCaption, SubGroupDisplaySeq, RecType, AppId )
			SELECT ISNULL(v.RoleId,'') AS [GroupValue], ISNULL(v.RoleId,'public') AS GroupDescription, 
				c.AppID + ' - ' + CAST(p.Caption AS nvarchar) AS Caption, v.ConfigValue, c.DispSeq AS GroupDisplaySeq, l.Caption ValueList, 
				gp.Caption AS SubGroupCaption, CAST(gp.Caption AS nvarchar) AS SubGroupDisplaySeq, c.RecType, c.AppId
			FROM #tmpSmConfig c 
			INNER JOIN dbo.tblSmConfigValue v ON v.ConfigRef = c.ConfigRef 
			INNER JOIN #tmpSysCaption p ON c.CaptionId = p.ObjectId  -- Business rules captions
			INNER JOIN #tmpSmConfig g ON c.CTConfigRef = g.ConfigRef 
			INNER JOIN #tmpSysCaption gp ON g.CaptionId = gp.ObjectId -- Group captions		
			INNER JOIN ( SELECT a.AppID, s.[Description], a.Notes, s.ClientProgYn
						 FROM dbo.tblSmApp_Installed AS a 
							INNER JOIN  #tmpSmApp AS s ON a.AppID = s.AppID 
					   ) i ON c.AppId = i.AppId
			LEFT JOIN #tmpSysCaption l ON c.ValueListId = l.ObjectId
			INNER JOIN #tmpBusinessRuleList tmp ON tmp.ConfigRef = c.ConfigRef 
			WHERE c.RoleConfigYn = 1 AND c.RecType < 2048 -- Only include actual business rules 
				AND p.[LangId] = @RptLang AND gp.[LangId] = @RptLang AND (l.ObjectId IS NULL OR (l.ObjectId IS NOT NULL AND l.[LangId] = @RptLang 
				AND (c.RecType IN (1024,1029,1030) OR (c.RecType NOT IN (1024,1029,1030) AND c.AppId = l.AppId))))
			ORDER BY v.RoleId, CAST(gp.Caption AS nvarchar), c.AppID + ' - ' + CAST(p.Caption AS nvarchar)
	END
	
	SET @sql = ''
	
	SET @sql = @sql + 'SELECT GroupValue, GroupDescription, Caption, 
		CASE 
			WHEN ValueList = ''0;No;1;Yes'' THEN 
					CASE 
						WHEN ConfigValue = ''0'' THEN ''No'' 
						WHEN ConfigValue = ''1'' THEN  ''Yes'' 
					END 
			WHEN ValueList = ''0;No;1;Single;2;Multiple'' THEN 
					CASE 
						WHEN ConfigValue = ''0'' THEN ''No'' 
						WHEN ConfigValue = ''1'' THEN ''Single'' 
						WHEN ConfigValue = ''2'' THEN  ''Multiple'' 
					END
			WHEN ValueList = ''1;All;2;Partial;0;None'' THEN
					CASE 
						WHEN ConfigValue = ''0'' THEN ''None'' 
						WHEN ConfigValue = ''1'' THEN ''All'' 
						WHEN ConfigValue = ''2'' THEN ''Partial'' 
					END

			WHEN ValueList = ''0;None;1;All;2;Partial'' THEN
					CASE 
						WHEN ConfigValue = ''0'' THEN ''None'' 
						WHEN ConfigValue = ''1'' THEN ''All'' 
						WHEN ConfigValue = ''2'' THEN ''Partial'' 
					END		
			WHEN ValueList = ''0;Highest;1;Lowest'' THEN 
					CASE 
						WHEN ConfigValue = ''0'' THEN ''Highest'' 
						WHEN ConfigValue = ''1'' THEN ''Lowest'' 
					END			
			WHEN ValueList = ''1;Average;2;Last;3;Base;4;Standard'' THEN
					CASE 
						WHEN ConfigValue = ''1'' THEN ''Average'' 
						WHEN ConfigValue = ''2'' THEN ''Last'' 
						WHEN ConfigValue = ''3'' THEN ''Base'' 
						WHEN ConfigValue = ''4'' THEN ''Standard'' 				
					END	
			WHEN ValueList = ''0;FIFO;1;LIFO;2;Average Cost;3;Standard Cost'' THEN
					CASE 
						WHEN ConfigValue = ''0'' THEN ''FIFO'' 				
						WHEN ConfigValue = ''1'' THEN ''LIFO'' 
						WHEN ConfigValue = ''2'' THEN ''Average Cost'' 
						WHEN ConfigValue = ''3'' THEN ''Standard Cost'' 
					END	
			WHEN ValueList = ''1;Specific Item;2;General'' THEN
					CASE 
						WHEN ConfigValue = ''1'' THEN ''Specific Item'' 
						WHEN ConfigValue = ''2'' THEN ''General'' 
					END		
			WHEN ValueList = ''0;Single Level;1;All Levels'' THEN
					CASE 
						WHEN ConfigValue = ''0'' THEN ''Single Level'' 
						WHEN ConfigValue = ''1'' THEN ''All Levels'' 
					END			
			WHEN ValueList = ''1;Hours;60;Minutes;3600;Seconds'' THEN
					CASE 
						WHEN ConfigValue = ''1'' THEN ''Hours'' 				
						WHEN ConfigValue = ''60'' THEN ''Minutes'' 
						WHEN ConfigValue = ''3600'' THEN ''Seconds'' 
					END	
			WHEN ValueList = ''3600;Secs;60;Mins;1;Hrs'' THEN
					CASE 
						WHEN ConfigValue = ''1'' THEN ''Hrs'' 				
						WHEN ConfigValue = ''60'' THEN ''Mins'' 
						WHEN ConfigValue = ''3600'' THEN ''Secs'' 
					END			
			WHEN ValueList = ''F;First;L;Last'' THEN
					CASE 
						WHEN ConfigValue = ''F'' THEN ''First'' 				
						WHEN ConfigValue = ''L'' THEN ''Last'' 
					END			
			WHEN ValueList = ''H;Home;W;Worked'' THEN
					CASE 
						WHEN ConfigValue = ''H'' THEN ''Home'' 				
						WHEN ConfigValue = ''W'' THEN ''Worked'' 
					END			
			WHEN ValueList = ''0;None;1;Requisitions;2;Purchase Order;3;Choice'' THEN
					CASE 
						WHEN ConfigValue = ''0'' THEN ''None'' 				
						WHEN ConfigValue = ''1'' THEN ''Requisitions'' 
						WHEN ConfigValue = ''2'' THEN ''Purchase Order'' 
						WHEN ConfigValue = ''3'' THEN ''Choice'' 
					END			
			WHEN ValueList = ''1;Item ID/Serial No;2;Tag Number'' THEN
					CASE 
						WHEN ConfigValue = ''1'' THEN ''Item ID/Serial No'' 				
						WHEN ConfigValue = ''2'' THEN ''Tag Number'' 
					END			
			WHEN ValueList = ''0;Snapshot;1;Image;2;RTF;3;PDF'' THEN 
					CASE 
						WHEN ConfigValue = ''0'' THEN ''Snapshot'' 				
						WHEN ConfigValue = ''1'' THEN ''Image'' 
						WHEN ConfigValue = ''2'' THEN ''RTF'' 
						WHEN ConfigValue = ''3'' THEN ''PDF'' 
					END			
			WHEN ValueList = ''0;None;1;All;2;Last Four Digits'' THEN
					CASE 
						WHEN ConfigValue = ''0'' THEN ''None'' 				
						WHEN ConfigValue = ''1'' THEN ''All'' 
						WHEN ConfigValue = ''2'' THEN ''Last Four Digits'' 
					END				
			WHEN ValueList = ''0;Sold-To;1;Bill-To'' THEN
					CASE 
						WHEN ConfigValue = ''0'' THEN ''Sold-To'' 				
						WHEN ConfigValue = ''1'' THEN ''Bill-To'' 
					END				
			WHEN ValueList = ''0;Location From;1;Location To'' THEN
					CASE 
						WHEN ConfigValue = ''0'' THEN ''Location From'' 				
						WHEN ConfigValue = ''1'' THEN ''Location To'' 
					END			
			WHEN ValueList = ''0;None;1;Detail;2;Summary'' THEN
					CASE 
						WHEN ConfigValue = ''0'' THEN ''None'' 				
						WHEN ConfigValue = ''1'' THEN ''Detail'' 
						WHEN ConfigValue = ''2'' THEN ''Summary'' 
					END			
			ELSE ConfigValue 
		END AS ConfigValue, 		
		GroupDisplaySeq, ValueList, SubGroupCaption, SubGroupDisplaySeq, RecType, AppId 
	FROM #tmp' 

	IF @sql <> '' EXECUTE (@sql)

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SmBusinessRulesList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SmBusinessRulesList_proc';

