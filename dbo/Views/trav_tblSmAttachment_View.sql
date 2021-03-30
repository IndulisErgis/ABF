CREATE VIEW [dbo].[trav_tblSmAttachment_View]
AS
SELECT t.[Comment]
, t.[Description]
, t.[Document]
, t.[DocumentName]
, t.[EnteredBy]
, t.[EntryDate]
, t.[ExpireDate]
, t.[FileName]
, t.[Id]
, t.[Keywords]
, t.[LinkKey]
, t.[LinkType]
, t.[Priority]
, t.[Status]
, e.[cf_CallBackDate]
 FROM dbo.[tblSmAttachment] t
 LEFT JOIN
 ( SELECT pvt.[Id]
	, Cast(pvt.[CallBackDate] As datetime) AS [cf_CallBackDate]
	 FROM
		 ( SELECT t.[Id], [Name], [Value]
		 FROM
			 ( SELECT t.[Id]
			 , e.props.value('./Name[1]', 'NVARCHAR(max)') as [Name]
			 , e.props.value('./Value[1]', 'NVARCHAR(max)') as [Value]
			 FROM dbo.[tblSmAttachment] t
			 CROSS APPLY t.CF.nodes('/ArrayOfEntityPropertyOfString/EntityPropertyOfString') as e(props)
			 WHERE (e.props.exist('Name') = 1) AND (e.props.exist('Value') = 1)
		 ) t
	 ) tmp
	 PIVOT (Max([Value]) FOR [Name] IN ([CallBackDate])) AS pvt
) e on  t.[Id] = e.[Id]