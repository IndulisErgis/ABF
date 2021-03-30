 CREATE PROCEDURE DeleteExportedProject
 @pImpProjectid varchar(max)  AS 
 BEGIN
 declare @sql varchar(300)
  
	SET	@sql= 'DELETE FROM Alp_tblIMPItem where ImportMainId in(  
		SELECT ImportMainId from ALP_tblIMPMain where ImportProjectId in ('+ @pImpProjectid +'))'
	exec( @sql);	
	SET	@sql= 'DELETE FROM Alp_tblIMPMain WHERE ImportProjectId in ('+ @pImpProjectid + ')'
	exec( @sql);
	SET	@sql= 'DELETE FROM ALP_tblIMPProject WHERE ImportProjectId in('+  @pImpProjectid+')'
	exec( @sql);
 END