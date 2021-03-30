

create procedure dbo.[0sp_FindObject]
@SearchFor varchar(255) = '',
@DbId varchar(255) = Null
As

/*	This procedure searches through all the objects within a given database 
	and lists any that have a name matching the search phrase.

	The search phrase may contain any valid SQL wild card characters.

	The current database will be searched if the optional @DbId parameter is omitted.
*/

set nocount on

declare @sql varchar(255)

Set @sql = ''

Select @DbId = quotename(coalesce(@DbId, DB_Name()))

set @sql = 'Select name from ' + @DbId + '.dbo.sysobjects where name like ''' + @SearchFor + '%'''

execute( @sql)