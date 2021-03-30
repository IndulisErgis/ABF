
CREATE VIEW [dbo].[trav_DSViewBuilder_view]
AS
	--PET:http://webfront:801/view.php?id=228219
	
	SELECT cfe.EntityName, m.FieldName
	, case m.FieldType 
		when 'Number' then 'float' 
		when 'Date' then 'datetime' 
		when 'YesNo' then 'bit' 
		else 'nvarchar' + Case when ISNULL(m.FieldLength, 0) = 0 Then '(max)' else '(' + CAST(m.FieldLength as nvarchar) + ')' End
		end as FType
	FROM (SELECT t.Id, t.FieldName
				 , e.def.value('./FieldType[1]', 'NVARCHAR(max)') as [FieldType]
				 , e.def.value('./MaxLength[1]', 'int') as [FieldLength]
				 FROM dbo.tblSmCustomField t
				 CROSS APPLY t.Definition.nodes('/CustomField') as e(def)) as m
	INNER JOIN dbo.tblSmCustomFieldEntity cfe on cfe.FieldId = m.Id
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_DSViewBuilder_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_DSViewBuilder_view';

