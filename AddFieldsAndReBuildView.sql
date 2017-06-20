declare @alterTable nvarchar(max) = '' ----��ƪ�W��
declare @addCoulmns nvarchar(max) = '' --�ק�@���u��@��(���W�ٻP��ƫ��A�H1�Ӫťդ��j)--EX: 'post nvarchar(50),transtyle nvarchar(15)'
declare @isAlter int = 0 ------0=�s�W 1=�ק� 2=���W��(�榡��:  �¦W��->�s�W��)
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
------------------�ק��ƪ�<<Start>>--------------------------
declare cursor_table cursor for
	select
		a.tablea
	from @tmp a
	order by tablea
open cursor_table
fetch next from cursor_table
into @table_name
while(@@FETCH_STATUS <> -1)
begin
	if(@isAlter=0)
	begin
		set @cmd = 'alter table ['+@table_name+'] add ' + @addCoulmns
	end
	else if(@isAlter=1)
	begin
		declare @ext nvarchar(max) = rtrim(ltrim(substring(@addCoulmns,charindex(' ',@addCoulmns)+1,len(@addCoulmns))))
		declare @field_name nvarchar(max) =  rtrim(ltrim(substring(@addCoulmns,0,charindex(' ',@addCoulmns))))
		if(len(@ext)=0 or len(@field_name)=0)
		begin
			print '�ק�����g���~!!'
			return
		end
		if(lower(@ext)='bit')
		begin
			set @cmd = 'update ['+@table_name+'] set ['+@field_name+']=0'
			print '[' + @table_name + '] -> ' + @cmd
			execute sp_executesql @cmd
		end
		set @cmd = 'alter table ['+@table_name+'] alter column ' + @addCoulmns
	end
	else if(@isAlter=2)
	begin
		declare @oldname nvarchar(max) = substring(@addCoulmns,0,charindex('->',@addCoulmns))
		declare @newname nvarchar(max) = substring(@addCoulmns,charindex('->',@addCoulmns)+2,len(@addCoulmns))
		set @cmd = 'execute sp_rename '''+@table_name+'.'+@oldname+''', '''+@newname+''', ''COLUMN'';'
	end
	execute sp_executesql @cmd
	print '[' + @table_name + '] -> ' + @cmd
	fetch next from cursor_table
	into @table_name
end
close cursor_table
deallocate cursor_table
------------------�ק��ƪ�<<End>>--------------------------
------------------���ءy�����z��ƪ�<<Start>>-------------------------
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
------------------���ءy�����z��ƪ�<<End>>-------------------------