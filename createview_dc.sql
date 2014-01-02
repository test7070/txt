	SET QUOTED_IDENTIFIER OFF
	declare @cmd nvarchar(max)
	declare @cmds nvarchar(max)
	declare @cmdt nvarchar(max)
	declare @cmdu nvarchar(max)
	declare @cmdaccy nvarchar(max)
	
	declare @table nvarchar(20)
	declare @tablea nvarchar(20)
	declare @tableas nvarchar(20)
	declare @tableat nvarchar(20)
	declare @tableau nvarchar(20)
	declare @accy nvarchar(20)
	declare @accy2 nvarchar(20)
	
	declare @tmp table(
		tablea nvarchar(20),
		tableas nvarchar(20),
		tableat nvarchar(20),
		tableau nvarchar(20),
		accy nvarchar(20)
	)

--¦³¦~«×
--===================================================================================================
print 'bbm:'
	--trans
	set @table = 'trans'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''

	declare cursor_table cursor for
	select tablea,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	

		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
--===================================================================================================
print 'bbm+bbs:'
	--cng
	set @table = 'cng'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	--ina
	set @table = 'ina'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	--trd
	set @table = 'trd'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	--tre
	set @table = 'tre'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	--ordb
	set @table = 'ordb'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	--ordc
	set @table = 'ordc'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	--orde
	set @table = 'orde'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	
	--transvcce
	set @table = 'transvcce'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	
	--transvcce2tran
	set @table = 'transvcce2tran'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	
	--vcc
	set @table = 'vcc'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	
	--quat
	set @table = 'quat'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	
	declare cursor_table cursor for
	select tablea,tableas,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
			
		fetch next from cursor_table
		into @tablea,@tableas,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
--============================================================================================
print 'bbm+bbs+bbt:'
	----------------------------------------------
	set @table = 'tranorde'
	print space(4)+@table
	delete @tmp
	insert into @tmp(tablea,tableas,tableat,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,@table,@table+'s')
	,replace(TABLE_NAME,@table,@table+'t')
	,replace(TABLE_NAME,@table,'')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like @table+'[0-9][0-9][0-9]'
	
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table)
	begin
		set @cmd = "drop view view_"+@table
		execute sp_executesql @cmd
	end
	set @cmd = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s')
	begin
		set @cmds = "drop view view_"+@table+'s'
		execute sp_executesql @cmds
	end
	set @cmds = ''
	if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'t')
	begin
		set @cmdt = "drop view view_"+@table+'t'
		execute sp_executesql @cmdt
	end
	set @cmdt = ''
	
	declare cursor_table cursor for
	select tablea,tableas,tableat,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@tableas,@tableat,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		--
		set @cmd = @cmd + case when LEN(@cmd)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tablea
		--s
		set @cmds = @cmds + case when LEN(@cmds)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableas
		--t
		set @cmdt = @cmdt + case when LEN(@cmdt)=0 then '' else CHAR(13)+ space(4)+'union all'+CHAR(13) end
			+ space(4)+"select '"+@accy+"' accy,* from "+@tableat
		--accy
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tablea
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+@accy2
		end
		set @cmdaccy = "create view view_"+@table+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy	
		execute sp_executesql @cmdaccy 
		--accys
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'s'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'s'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableas
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'s'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'s'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 
		--accyt
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_'+@table+'t'+@accy)
		begin
			set @cmdaccy = "drop view view_"+@table+'t'+@accy
			execute sp_executesql @cmdaccy
		end
		set @cmdaccy = ''
		set @accy2 = right('000'+CAST(@accy as int)-1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = space(4)+"select '"+@accy2+"' accy,* from "+@table+'t'+@accy2
		end
		set @cmdaccy = @cmdaccy + case when len(@cmdaccy)>0 then CHAR(13)+ space(4)+'union all'+CHAR(13) else '' end +SPACE(4)+"select '"+@accy+"' accy,* from "+@tableat
		set @accy2 = right('000'+CAST(@accy as int)+1,3)
		if exists(select * from @tmp where accy=@accy2)
		begin
			set @cmdaccy = @cmdaccy + CHAR(13)+ space(4)+'union all'+CHAR(13)+space(4)+"select '"+@accy2+"' accy,* from "+@table+'t'+@accy2
		end
		set @cmdaccy = "create view view_"+@table+'t'+@accy+ CHAR(13)+"as" + CHAR(13) + @cmdaccy
		execute sp_executesql @cmdaccy 	
		fetch next from cursor_table
		into @tablea,@tableas,@tableat,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	if LEN(@cmd)>0
	begin
		set @cmd = "create view view_"+@table+ CHAR(13)+"as" + CHAR(13) + @cmd
		execute sp_executesql @cmd
	end
	if LEN(@cmds)>0
	begin
		set @cmds = "create view view_"+@table+'s'+ CHAR(13)+"as" + CHAR(13) + @cmds
		execute sp_executesql @cmds
	end
	if LEN(@cmdt)>0
	begin
		set @cmdt = "create view view_"+@table+'t'+ CHAR(13)+"as" + CHAR(13) + @cmdt
		execute sp_executesql @cmdt
	end
--============================================================================================
print 'other:'
	print 'view_transstatus'
	delete @tmp
	insert into @tmp(tablea,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,'trans','')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like 'trans[0-9][0-9][0-9]'
	
	declare cursor_table cursor for
	select tablea,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_trds'+@accy)
		begin
			
			if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_tres'+@accy)
			begin
				if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_transstatus'+@accy)
				begin
					set @cmd = "drop view view_transstatus"+@accy
					execute sp_executesql @cmd
				end
				set @cmd = "create view view_transstatus"+@accy
				+CHAR(13)+"as"
				+CHAR(13)+SPACE(4)+"select case when b.noa is null then 0 else 1 end istrd"
				+CHAR(13)+SPACE(4)+SPACE(4)+",case when c.noa is null then 0 else 1 end istre"
				+CHAR(13)+SPACE(4)+SPACE(4)+",case when (e.noa is not null) and d.isoutside=0 and f.lock=1 then 1 else 0 end iscarsal"
				+CHAR(13)+SPACE(4)+SPACE(4)+",a.*"
				+CHAR(13)+SPACE(4)+"from "+@tablea+" a"
				+CHAR(13)+SPACE(4)+"left join view_trds"+@accy+" b on a.noa=b.tranno and a.noq=b.trannoq"
				+CHAR(13)+SPACE(4)+"left join view_tres"+@accy+" c on a.noa=c.tranno and a.noq=c.trannoq"
				+CHAR(13)+SPACE(4)+"left join calctypes d on a.calctype = d.noa+d.noq"
				+CHAR(13)+SPACE(4)+"left join carsals e on e.noa=LEFT(a.datea,6) and a.driverno=e.driverno"
				+CHAR(13)+SPACE(4)+"left join carsal f on e.noa=f.noa"
				execute sp_executesql @cmd
			end
		end

		fetch next from cursor_table
		into @tablea,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	--view_tranorde_dc
	print 'view_tranorde_dc'
	delete @tmp
	insert into @tmp(tablea,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,'tranorde','')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like 'tranorde[0-9][0-9][0-9]'
	
	declare cursor_table cursor for
	select tablea,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_tranorde'+@accy)
		begin
			
			if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_transvcce'+@accy)
			begin
				if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_tranorde_dc'+@accy)
				begin
					set @cmd = "drop view view_tranorde_dc"+@accy
					execute sp_executesql @cmd
				end
				set @cmd = "create view view_tranorde_dc"+@accy
				+char(13) + "as" 
				+char(13) + SPACE(4)+"select isnull(b.mount,0) vccecount,a.*" 
				+char(13) + SPACE(4)+"from view_"+@tablea+" a "
				+char(13) + SPACE(4)+"left join ("
				+char(13) + SPACE(4)+SPACE(4)+"select ordeno,SUM(ISNULL(mount,0)) mount"
				+char(13) + SPACE(4)+SPACE(4)+"from view_transvcce"+@accy+" group by ordeno"
				+char(13) + SPACE(4)+") b on a.noa=b.ordeno"
				execute sp_executesql @cmd
			end
		end

		fetch next from cursor_table
		into @tablea,@accy
	end
	close cursor_table
	deallocate cursor_table
	
	--view_tranorde_ef
	print 'view_tranorde_ef'
	delete @tmp
	insert into @tmp(tablea,accy)
	SELECT TABLE_NAME 
	,replace(TABLE_NAME,'tranorde','')
	FROM INFORMATION_SCHEMA.TABLES 
	where TABLE_NAME like 'tranorde[0-9][0-9][0-9]'
	
	declare cursor_table cursor for
	select tablea,accy from @tmp
	open cursor_table
	fetch next from cursor_table
	into @tablea,@accy
	while(@@FETCH_STATUS <> -1)
	begin
		if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_tranorde'+@accy)
		begin
			
			if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_trans'+@accy)
			begin
				if exists(select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME='view_tranorde_ef'+@accy)
				begin
					set @cmd = "drop view view_tranorde_ef"+@accy
					execute sp_executesql @cmd
				end
				set @cmd = "create view view_tranorde_ef"+@accy
				+char(13) + "as" 
				+char(13) + SPACE(4)+"select isnull(b.mount,0) vccecount,a.*" 
				+char(13) + SPACE(4)+"from view_"+@tablea+" a "
				+char(13) + SPACE(4)+"left join ("
				+char(13) + SPACE(4)+SPACE(4)+"select ordeno,SUM(ISNULL(mount,0)) mount"
				+char(13) + SPACE(4)+SPACE(4)+"from view_trans"+@accy+" group by ordeno"
				+char(13) + SPACE(4)+") b on a.noa=b.ordeno"
				execute sp_executesql @cmd
			end
		end

		fetch next from cursor_table
		into @tablea,@accy
	end
	close cursor_table
	deallocate cursor_table
	