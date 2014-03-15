declare @newTablename nvarchar(max)= 'workhs' --新資料表名稱
declare @newTableCoulmns nvarchar(max) = '' --新資料表欄位 EX: 	noa nvarchar(35),datea nvarchar(10),worker2 nvarchar(50)
declare @newTableKey nvarchar(max) = 'noa,noq' --新資料表KEY EX: noa
declare @isMultipleYears int = 1 --是否多年度 0=否 1=是
declare @bYears int =101 --開始年度
declare @eYears int =105 --中止年度
declare @cmd nvarchar(max)
declare @tmp table( ---將產生的資料表
	tablename nvarchar(max),
	isexist int
)
if(ltrim(rtrim(@newTablename)) = '')
begin
	print '請輸入資料表名稱!!'
	return
end
if(ltrim(rtrim(@newTableCoulmns)) = '')
begin
	print '請輸入資料表欄位!!'
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
			print '請輸入資料表年度區間!!'
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
		if(@isexist=0)
		begin
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
			print @tablename + ' -> 該資料表已存在!!'
		end
		fetch next from cursor_table
		into @tablename,@isexist
	end
	close cursor_table
	deallocate cursor_table
end
