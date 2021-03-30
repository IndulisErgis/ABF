
CREATE PROCEDURE dbo.trav_MbFindParents_proc
@ParentId int, -- top level component grouping id
@IndLevel int, -- current outdention level
@ComponentId pItemID, -- component id to find the parents of
@LocId pLocID, -- location id for the given component (includes all locations if NULL)
@ComponentRevision nvarchar(3), 
@MaxIndentationLevel int -- max levels to outdent(recurse) list of parent assemblies

AS
/* procedure can recurse upon itself to find all parent assemblies */
SET NOCOUNT ON
BEGIN TRY

	DECLARE @curParents cursor
	DECLARE @tmpIndLevel int
	DECLARE @AssemblyId pItemID
	DECLARE @RevisionNo nvarchar(3)
	DECLARE @CompSeq int
	DECLARE @HeaderId int
	DECLARE @DetailId int

	-- requires a temp table with a minimum of the following fields
	/*
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
	*/

	-- setup a cursor of all parents for the given component
	SET @curParents = CURSOR FOR
	SELECT d.HeaderId, d.Id, h.AssemblyId, h.RevisionNo, Sequence AS CompSeq 
	FROM dbo.tblMbAssemblyDetail d 
		INNER JOIN dbo.tblMbAssemblyHeader h ON d.HeaderId = h.Id 
		LEFT JOIN 
		(
			SELECT Id, AssemblyId, RevisionNo 
			FROM dbo.tblMbAssemblyHeader WHERE DfltRevYn <> 0
		) r ON d.ComponentId = r.AssemblyId 
	WHERE ComponentId = @ComponentId AND (LocId = @LocId OR @LocId IS NULL) 
		AND (@ComponentRevision IS NULL OR ISNULL(CompRevisionNo, r.RevisionNo) = @ComponentRevision)
	FOR READ ONLY

	OPEN @curParents
	IF @@CURSOR_ROWS <> 0
	BEGIN
		FETCH NEXT FROM @curParents INTO @HeaderId, @DetailId, @AssemblyId, @RevisionNo, @CompSeq
		WHILE @@FETCH_STATUS = 0
		BEGIN
			-- insert each assembly
			INSERT INTO #ParentInfo (HeaderId, DetailId, ParentId, IndLevel, ComponentId, LocId, AssemblyId, ComponentRevisionNo, CompSeq)
			VALUES (@HeaderId, @DetailId, @ParentId, @IndLevel, @ComponentId, @LocId, @AssemblyId, @RevisionNo, @CompSeq)

			-- increment the indentation level for the next level of parents
			SELECT @tmpIndLevel = @IndLevel + 1

			-- recurse to find additional parents
			IF @tmpIndLevel < @MaxIndentationLevel
			BEGIN
				EXEC dbo.trav_MbFindParents_proc @ParentId, @tmpIndLevel, @AssemblyId, NULL, @RevisionNo, @MaxIndentationLevel
			END

			FETCH NEXT FROM @curParents INTO @HeaderId, @DetailId, @AssemblyId, @RevisionNo, @CompSeq
		END
		CLOSE @curParents
	END
	DEALLOCATE @curParents

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MbFindParents_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MbFindParents_proc';

