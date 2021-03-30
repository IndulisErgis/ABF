
create proc KSI_DropOrphanUsers 
AS
declare @db nvarchar(50)
select @db=DB_NAME() 

set nocount on
-- Written by: Nathan Kovac  
-- Create procedure to drop all users from a database


-- Create local variables needed
declare @CNT int
declare @name char(128)
declare @sid  varbinary(85)
declare @cmd nchar(4000)
declare @c int
declare @hexnum char(100)

-- Build and execute command to determine if DBO is not mapped to login
  set @cmd = 'select @cnt = count(*) from master..syslogins l right join [' + 
             rtrim(@db) + ']..sysusers u on l.sid = u.sid' + 
             ' where l.sid is null and u.name = ''DBO'''
  exec sp_executesql @cmd,N'@cnt int out',@cnt out

-- if DB is not mapped to login that exists map DBO to SA
  if @cnt = 1
  begin
    print 'exec [' + @db + ']..sp_changedbowner ''SA'''  
    exec sp_changedbowner 'SA'
  end -- if @cnt = 1


-- drop table if it already exists
if (select object_id('tempdb..##orphans')) is not null
	drop table ##orphans

-- Create table to hold orphan users
create table ##orphans (orphan varchar(128))

-- Build and execute command to get list of all orphan users (Windows and SQL Server)
-- for current database being processed
set @cmd = 'insert into ##orphans select u.name from master..syslogins l right join [' + 
          rtrim(@db) + ']..sysusers u on l.sid = u.sid ' + 
          'where l.sid is null and issqlrole <> 1 and isapprole <> 1 ' +  
          'and (u.name <> ''INFORMATION_SCHEMA'' and u.name <> ''sys'' and u.name <> ''dbo'' and u.name <> ''guest'' ' +  
          'and u.name <> ''system_function_schema'')'
exec (@cmd)


-- Are there orphans
select @cnt = count(*) from ##orphans

WHILE @cnt > 0 
BEGIN
  
-- get top orphan
  select top 1 @name= orphan from ##orphans

-- delete top orphan
  delete from ##orphans where orphan = @name

-- Build command to drop user from database.
    set @cmd = 'exec [' + rtrim(@db) + ']..sp_revokedbaccess ''' + rtrim(@name) + ''''
    print @cmd
    exec (@cmd)

   
-- are there orphans left
    select @cnt = count(*) from ##orphans  
  end --  WHILE @cnt > 0

-- Remove temporary table
drop table ##orphans