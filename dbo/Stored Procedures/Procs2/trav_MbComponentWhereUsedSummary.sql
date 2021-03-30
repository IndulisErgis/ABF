
CREATE PROCEDURE dbo.trav_MbComponentWhereUsedSummary
@MaxIndentationLevel int

AS
SET NOCOUNT ON
BEGIN TRY

	DECLARE @curComps cursor
	DECLARE @ParentId int
	DECLARE @ComponentId pItemId
	DECLARE @LocId pLocId

	-- use a temp table with an identity column to dynamically create parent grouping ids
	CREATE TABLE #BuildParentIds
	(
		ParentId int IDENTITY(1, 1) NOT NULL, 
		ComponentId pItemID, 
		LocId pLocID
	)

	-- setup temp table required by the trav_MbFindParents_proc procedure
	CREATE TABLE #ParentInfo
	(
		ListSeq int IDENTITY(1, 1), 
		ParentId int, 
		IndLevel int, 
		ComponentId pItemID, 
		LocId pLocId NULL, 
		AssemblyId pItemID NULL, 
		ComponentRevisionNo nvarchar(3) NULL, 
		CompSeq int NULL, 
		HeaderId int, 
		DetailId int
	)

	-- build the list of parent ids for each component/location combination
	INSERT INTO #BuildParentIds (ComponentId, LocId) 
	SELECT ComponentId, d.LocId 
	FROM dbo.tblMbAssemblyDetail d INNER JOIN #tmpItemLoc l ON l.ItemId = d.ComponentId AND l.LocId = d.LocId 
	GROUP BY ComponentId, d.LocId

	IF @@ROWCOUNT > 0
	BEGIN
		-- if components were found then try to find any parents
		SET @curComps = CURSOR FOR
		SELECT ParentId, ComponentId, LocId FROM #BuildParentIds
		FOR READ ONLY

		OPEN @curComps
		FETCH NEXT FROM @curComps INTO @ParentId, @ComponentId, @LocId
		WHILE @@FETCH_STATUS = 0
		BEGIN
			-- insert each component
			INSERT INTO #ParentInfo (ParentId, IndLevel, ComponentId, LocId, AssemblyId, ComponentRevisionNo, CompSeq)
			VALUES (@ParentId, 0, @ComponentId, @LocId, NULL, NULL, NULL)

			-- call recursive procedure to find all parents
			EXEC dbo.trav_MbFindParents_proc @ParentId, 1, @ComponentId, @LocId, NULL, @MaxIndentationLevel
			FETCH NEXT FROM @curComps INTO @ParentId, @ComponentId, @LocId
		END
		CLOSE @curComps
		DEALLOCATE @curComps
	END

	-- return the resultset
	SELECT w.HeaderId, w.ListSeq, w.ParentId, w.IndLevel, w.ComponentId, w.ComponentRevisionNo AS RevisionNo, w.LocId
		, CASE WHEN w.IndLevel = 0 THEN NULL ELSE d.DetailType END AS ComponentType
		, CASE WHEN w.IndLevel = 0 THEN '+' + UPPER(w.ComponentId) + CASE WHEN i.Descr IS NULL THEN '' ELSE ':' 
			+ i.Descr END ELSE CASE WHEN w.ComponentRevisionNo IS NULL THEN '-' ELSE '+' END + w.AssemblyId 
			+ CASE WHEN h.[Description] IS NULL THEN '' ELSE ':' + h.[Description] END END AS Title 
	FROM #ParentInfo w 
		LEFT JOIN dbo.tblMbAssemblyHeader h ON w.HeaderId = h.Id 
		LEFT JOIN dbo.tblMbAssemblyDetail d ON w.DetailId = d.Id 
		LEFT JOIN dbo.tblInItem i ON (w.ComponentId = i.ItemId) 
	ORDER BY w.ListSeq

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MbComponentWhereUsedSummary';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MbComponentWhereUsedSummary';

