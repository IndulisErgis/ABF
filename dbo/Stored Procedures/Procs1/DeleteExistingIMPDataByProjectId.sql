Create procedure DeleteExistingIMPDataByProjectId (@importProjectId int)as 
		  begin
		DELETE I FROM  Alp_tblIMPItem I INNER JOIN Alp_tblIMPMain M ON I.ImportMainId = M.ImportMainId WHERE M.ImportProjectId = @importProjectId
		DELETE  FROM Alp_tblIMPMain WHERE Alp_tblIMPMain.ImportProjectId =@importProjectId
		DELETE  FROM Alp_tblIMPProject WHERE Alp_tblIMPProject.ImportProjectId = @importProjectId
		end