declare @tableName nvarchar(max) = '' -----table���W�� �s�W����view���W�٬� view_��ƪ�W�٥[�W�~��
declare @bYear int = 101 ----�_�l�~��
declare @eYear int = 105 ----�פ�~��
declare @DeleteAndCreate int = 0 ----�Y�w�s�b�O�_���R�� 0=�_ 1=�O
declare @eject nvarchar(max) = CHAR(13)+CHAR(10)
declare @cmd nvarchar(max)
------------------------------------------------------
declare @mainStr nvarchar(max) = 'create view [view_' + @tableName + '$$viewYear] as' + @eject
declare @mainCmd nvarchar(max) = REPLACE(@mainStr,'$$viewYear','')
declare @newViewCmd nvarchar(max) = @mainStr
declare @tmp table(
	viewname nvarchar(max),
	data nvarchar(max)
)
declare @addYear int = @bYear
while(@addYear<=@eYear)
begin
	declare @tmpCount int = 0
	declare @thisTableName nvarchar(max) = @tableName+cast(@addYear as nvarchar)
	declare @beforeViewName nvarchar(max) = @tableName+cast(@addYear-1 as nvarchar)

	-------�[�J�e�@�~�� <<Start>>
	if((select count(*) from INFORMATION_SCHEMA.tables where (TABLE_TYPE!='VIEW') and (TABLE_NAME=@beforeViewName)) >0)
	begin
		set @newViewCmd = @newViewCmd+'select ''' + cast((@addYear-1) as nvarchar) + ''' accy,* from ['+@beforeViewName+']' + @eject
		-------�W�[Union All <<Start>>
		if((@addYear != @bYear))
		begin
			set @mainCmd = @mainCmd + 'union all' + @eject
			set @newViewCmd = @newViewCmd + 'union all' + @eject
		end
		-------�W�[Union All <<End>>
		end
	-------�[�J�e�@�~�� <<End>>
	-------�[�J��~�� <<Start>>
	if((select count(*) from INFORMATION_SCHEMA.tables where (TABLE_TYPE!='VIEW') and (TABLE_NAME=@thisTableName)) >0)
	begin
		set @newViewCmd = @newViewCmd+'select ''' + cast((@addYear) as nvarchar) + ''' accy,* from ['+@thisTableName+']' + @eject
		set @mainCmd = @mainCmd + 'select ''' + cast(@addYear as nvarchar) + ''' accy,* from ['+@thisTableName+']' + @eject
	end
	-------�[�J��~�� <<End>>
	if(@newViewCmd != @mainStr)
	begin
		set @newViewCmd = REPLACE(@newViewCmd,'$$viewYear',cast((@addYear) as nvarchar))
		insert into @tmp(viewname,data)
			values('view_'+@thisTableName,@newViewCmd)
	end
	set @newViewCmd = @mainStr
	set @addYear = @addYear+1
end
-------�[�J�D�n��view <<Start>>
insert into @tmp(viewname,data)
	values('view_'+@tableName,@mainCmd)
-------�[�J�D�n��view <<End>>
-------�}�l�s�Wview <<Start>>
declare @viewname nvarchar(max)
declare @data nvarchar(max)
declare cursor_table cursor for
	select viewname,data from @tmp order by viewname
open cursor_table
fetch next from cursor_table
into @viewname,@data
while(@@FETCH_STATUS <> -1)
begin
	if((select count(*) from information_schema.views where TABLE_NAME=@viewname) > 0)
	begin
		if(@DeleteAndCreate = 1)
		begin
			set @cmd = 'drop view [' + @viewname + ']'
			execute sp_executesql @cmd
			print '>>>>>>>>' + @viewname + ' -> ' + @cmd + '<<<<<<<<'
			execute sp_executesql @data
			print @viewname + ' -> ' + @data
		end
		else
		begin
			print @viewname + ' -> �o��view�w�s�b!!'
		end
	end
	else
	begin
		execute sp_executesql @data
		print @viewname + ' -> ' + @data		
	end
	fetch next from cursor_table
	into @viewname,@data
end
close cursor_table
deallocate cursor_table
-------�}�l�s�Wview <<End>>