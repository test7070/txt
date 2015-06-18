declare @n int
declare @name nvarchar(max)
declare @definition nvarchar(max)
declare @cmd nvarchar(max)
declare @t_deli nvarchar(max)
declare cursor_table cursor for
select row_number()over(order by lower(table_name) asc),table_name,view_definition from INFORMATION_SCHEMA.VIEWS order by lower(table_name) asc
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