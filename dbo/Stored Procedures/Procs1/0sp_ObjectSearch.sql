

create proc dbo.[0sp_ObjectSearch]
@SearchFor varchar(255),
@DbId varchar(255) = Null
as 

/*	This procedure searches through all the objects within a given database 
	and lists any that contain the given search phrase.

	The search phrase may contain any valid SQL wild card characters.

	The current database will be searched if the optional @DbId parameter is omitted.

	Note: sp_MsObjsearch is a Microsoft provided version that provides greater detail and flexability.
*/

Set nocount on

declare @sql varchar(8000)

Select @DbId = quotename(coalesce(@DbId, DB_Name()))

Select @Sql = 'Select xtype, Name From (Select o.xtype, o.name from ' + @DbId + '.dbo.sysobjects o inner join ' + @DbId + '.dbo.syscomments c on o.id = c.id 
		where patindex(''%' + @SearchFor + '%'', c.text) <> 0
		group by o.xtype, o.name
		) t1
	Union 
	Select xtype, Name From (select o.xtype, o.name from ' + @DbId + '.dbo.sysobjects o inner join ' + @DbId + '.dbo.syscolumns c on o.id = c.id 
		where c.name like ''%' + @SearchFor + '%''
		Group by o.xtype, o.name
		) t2
	Order by xtype, name'

execute( @sql)