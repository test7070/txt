declare @newTablename nvarchar(max)= '' --�s��ƪ�W��
declare @newTableCoulmns nvarchar(max) = '' --�s��ƪ���� EX: 	noa nvarchar(35),datea nvarchar(10),worker2 nvarchar(50)
declare @newTableKey nvarchar(max) = 'noa' --�s��ƪ�KEY EX: noa
declare @DeleteAndCreate int = 0 ----�Y�w�s�b�O�_���R�� 0=�_ 1=�O
declare @isMultipleYears int = 1 --�O�_�h�~�� 0=�_ 1=�O
declare @bYears int =101 --�}�l�~��
declare @eYears int =105 --����~��
declare @cmd nvarchar(max)
declare @tmp table( ---�N���ͪ���ƪ�
	tablename nvarchar(max),
	isexist int
)
if(ltrim(rtrim(@newTablename)) = '')
begin
	print '�п�J��ƪ�W��!!'
	return
end
if(ltrim(rtrim(@newTableCoulmns)) = '')
begin
	print '�п�J��ƪ����!!'
	return
end
else
begin
	if(@isMultipleYears = 0)
	begin
		insert into @tmp(tablename,isexist)
			select
				@newTablename,
				case when 
					(select count(*) from INFORMATION_SCHEMA.tables where (TABLE_TYPE != 'VIEW') and (TABLE_NAME=@newTablename)) > 0
				then 1 else 0 end
	end
	else
	begin
		if((cast(@bYears as int) =0) or (cast(@eYears as int) =0))
		begin
			print '�п�J��ƪ�~�װ϶�!!'
			return
		end
		else
		begin
			insert into @tmp(tablename,isexist)
				select
					@newTablename,
					case when 
						(select count(*) from INFORMATION_SCHEMA.tables where (TABLE_TYPE != 'VIEW') and (TABLE_NAME=@newTablename)) > 0
					then 1 else 0 end
			declare @addYear int = @bYears
			while(@addYear <= @eYears)
			begin
				declare @t_name nvarchar(max) = @newTablename + RIGHT(REPLICATE('0', 3) + CAST(@addYear as NVARCHAR), 3)
				insert into @tmp(tablename,isexist)
					select
						@t_name,
						case when 
							(select count(*) from INFORMATION_SCHEMA.tables where (TABLE_TYPE != 'VIEW') and (TABLE_NAME=@t_name)) > 0
						then 1 else 0 end
				set @addYear = @addYear+1
			end
		end
	end
	declare @tablename nvarchar(max)
	declare @isexist int
	declare cursor_table cursor for
		select tablename,isexist from @tmp order by tablename
	open cursor_table
	fetch next from cursor_table
	into @tablename,@isexist
	while(@@FETCH_STATUS <> -1)
	begin
		if(@isexist=0 or (@isexist=1 and @DeleteAndCreate=1))
		begin
			if(@isexist=1)
			begin
				set @cmd = 'drop table [' + @tablename + ']'
				execute sp_executesql @cmd
				print @tablename + ' -> ' + @cmd
			end
			set @cmd = 'create table [' + @tablename + '] ( ' + @newTableCoulmns
			if(ltrim(rtrim(@newTableKey)) != '')
			begin
				set @cmd = @cmd+',primary key('+@newTableKey+')'
			end
			set @cmd = @cmd + ')'
			execute sp_executesql @cmd
			print @tablename + ' -> ' + @cmd
		end
		else
		begin
			print @tablename + ' -> �Ӹ�ƪ�w�s�b!!'
		end
		fetch next from cursor_table
		into @tablename,@isexist
	end
	close cursor_table
	deallocate cursor_table
end