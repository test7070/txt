declare @alterTable nvarchar(max) = '' ----資料表名稱
declare @addCoulmns nvarchar(max) = '' ----EX: 'post nvarchar(50),transtyle nvarchar(15)'
declare @cmd nvarchar(max)
declare @table_name nvarchar(max)
declare @tmp table(
	idno int identity(0,1),
	tablea nvarchar(max)
)
insert into @tmp
	select
		a.table_name
	from INFORMATION_SCHEMA.tables a
	where (patindex(@alterTable+'[0-9][0-9][ 0-9]',a.TABLE_NAME) > 0)
			 or (patindex(@alterTable+'[0-9][0-9][ 0-9]_[0-9]',a.TABLE_NAME) > 0)
			 or (a.TABLE_NAME=@alterTable)
------------------修改資料表<<Start>>--------------------------
declare cursor_table cursor for
	select tablea from @tmp order by tablea
open cursor_table
fetch next from cursor_table
into @table_name
while(@@FETCH_STATUS <> -1)
begin
	set @cmd = 'alter table ['+@table_name+'] add ' + @addCoulmns
	execute sp_executesql @cmd
	print '[' + @table_name + '] -> ' + @cmd
	fetch next from cursor_table
	into @table_name
end
close cursor_table
deallocate cursor_table
------------------修改資料表<<End>>--------------------------
------------------重建『相關』資料表<<Start>>-------------------------
declare @n int
declare @name nvarchar(max)
declare @definition nvarchar(max)
declare @t_deli nvarchar(max)
declare cursor_table cursor for
	select
		row_number()over(order by lower(a.table_name) asc),a.table_name,a.view_definition
	from INFORMATION_SCHEMA.VIEWS a
	where (lower(a.table_name) in (select lower(aa.view_name) from INFORMATION_SCHEMA.VIEW_TABLE_USAGE aa where lower(TABLE_NAME) in (select lower(tablea) from @tmp)))
	order by lower(a.table_name) asc
open cursor_table
fetch next from cursor_table
into @n,@name,@definition
while(@@FETCH_STATUS <> -1)
begin		
	set @definition = REPLACE(@definition,CHAR(10),'/**a**/')
	set @definition = REPLACE(@definition,CHAR(13),'/**b**/')
	set @definition = REPLACE(@definition,CHAR(32)+CHAR(32),'/**c**/')
	set @definition = rtrim(LTRIM(@definition))

	if(@definition like 'CREATE%' or @definition like '%**/CREATE%')
	begin
		if(charindex('**/CREATE',@definition) > 0)
		begin
			set @t_deli =substring(@definition,charindex('**/CREATE',@definition),3)
			set @cmd = substring(@definition,0,charindex('**/CREATE',@definition)+3)+'ALTER'+substring(@definition,charindex('**/CREATE',@definition)+9,len(@definition))
		end
		else
		begin
			set @cmd = 'ALTER'+substring(@definition,7,len(@definition))
		end
		set @cmd = REPLACE(@cmd,'/**a**/',CHAR(10))
		set @cmd = REPLACE(@cmd,'/**b**/',CHAR(13))
		set @cmd = REPLACE(@cmd,'/**c**/',CHAR(32)+CHAR(32))
		print right('000'+CAST(@n as nvarchar),3)+'  '+@cmd
		execute sp_executesql @cmd
	end
	fetch next from cursor_table
	into @n,@name,@definition
end
close cursor_table
deallocate cursor_table
------------------重建『相關』資料表<<End>>-------------------------