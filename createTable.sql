	
	SET QUOTED_IDENTIFIER OFF
	declare @cmd nvarchar(max)
	declare @tablea nvarchar(max)
	declare @tableb nvarchar(max)
	declare @field nvarchar(max)
	declare @primarykey nvarchar(max)
	
	declare @old nvarchar(max)
	declare @new nvarchar(max)
	declare @name nvarchar(max)
	set @old = '102'  --<==================================
	set @new = '103'  --<==================================
	
	declare @listPrimaryKey table(
		tablea nvarchar(max),
		field nvarchar(max)
	)
	insert into @listPrimaryKey
	SELECT OBJECT_NAME([i].[object_id]) AS [TableName], [c].[name] FROM [sys].[indexes] AS [i]  INNER JOIN  [sys].[index_columns] AS [ic]  ON [ic].[index_id] = [i].[index_id]  AND [ic].[object_id] = [i].[object_id]  INNER JOIN  [sys].[columns] AS [c]  ON [c].[column_id] = [ic].[column_id]  AND [c].[object_id] = [i].[object_id] 
	where [i].[type_desc]='CLUSTERED'
	ORDER BY OBJECT_NAME([i].[object_id]), [ic].[key_ordinal]
	
	declare cursor_table cursor for
	select TABLE_NAME
	from INFORMATION_SCHEMA.TABLES
	where TABLE_NAME like '%'+@old and TABLE_TYPE!='view'
	open cursor_table
	fetch next from cursor_table
	into @tablea
	while(@@FETCH_STATUS <> -1)
	begin
		set @tableb = REPLACE(@tablea,@old,@new)
		if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME=@tableb)
		begin
			set @cmd = "SELECT TOP 0 * INTO "+@tableb+" from "+@tablea
			execute sp_executesql @cmd
		end	
		set @primarykey = ''
		declare cursor_table2 cursor for
		select field from @listPrimaryKey where tablea=@tablea
		open cursor_table2
		fetch next from cursor_table2
		into @field
		while(@@FETCH_STATUS <> -1)
		begin
			set @primarykey = @primarykey + case when LEN(@primarykey)>0 then ',' else '' end + @field
		
			fetch next from cursor_table2
			into @field
		end
		close cursor_table2
		deallocate cursor_table2
		
		if(len(@primarykey)>0)
		begin
			-- Return the name of primary key.
			set @name = ''
			SELECT @name = name
			FROM sys.key_constraints
			WHERE type = 'PK' AND OBJECT_NAME(parent_object_id) = @tableb
			
			if(LEN(@name)>0)
			begin
				---- Delete the primary key constraint.
				set @cmd =" alter table "+@tableb+" DROP CONSTRAINT "+ @name
				execute sp_executesql @cmd
			end
			set @cmd="alter table "+@tableb +" add primary key ("+@primarykey+")"
			execute sp_executesql @cmd
		end
		print @tableb
		fetch next from cursor_table
		into @tablea
	end
	close cursor_table
	deallocate cursor_table
	
	