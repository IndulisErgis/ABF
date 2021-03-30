
CREATE VIEW dbo.trav_MbAssemblyId_view
AS

SELECT r.AssemblyId, r.RevisionNo, r.[Description], r.CF FROM dbo.tblMbAssemblyHeader r
INNER JOIN
(
	SELECT AssemblyId,
	(
		SELECT TOP (1) RevisionNo FROM dbo.tblMbAssemblyHeader s
		WHERE AssemblyId = h.AssemblyId ORDER BY ISNULL(DfltRevYn, 0) DESC, RevisionNo
	)
	AS RevisionNo FROM dbo.tblMbAssemblyHeader h GROUP BY AssemblyId
) lst
ON r.AssemblyId = lst.AssemblyId AND r.RevisionNo = lst.RevisionNo
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_MbAssemblyId_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_MbAssemblyId_view';

