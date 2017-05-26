SET QUOTED_IDENTIFIER OFF

declare @tablea nvarchar(MAX)
declare @colum nvarchar(MAX)
declare @cmd nvarchar(MAX)

declare cmds cursor for 
select Table_Name from INFORMATION_SCHEMA.TABLES 
where TABLE_TYPE='BASE TABLE' and TABLE_CATALOG='ST' and Table_Name='vccs103'
order by Table_Name
open cmds
fetch next from cmds
into @tablea
while(@@FETCH_STATUS <> -1)
begin

	declare cmds2 cursor for 
	select b.name from sysobjects as a, syscolumns as b where a.xtype = 'U' and a.id = b.id and a.name=@tablea and isnullable!=0
	open cmds2
	fetch next from cmds2
	into @colum
	while(@@FETCH_STATUS <> -1)
	begin
		EXEC("update "+@tablea+" set "+@colum+"='' where "+@colum+" IS NULL")
		
		fetch next from cmds2
		into @colum
	end
	close cmds2
	deallocate cmds2
	
    fetch next from cmds
	into @tablea
   
end
close cmds
deallocate cmds
