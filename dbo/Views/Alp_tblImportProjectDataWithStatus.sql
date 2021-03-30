
CREATE view Alp_tblImportProjectDataWithStatus as  
SELECT P.ImportProjectId,p.Source_Id, P.CreatedBy, P.CreatedDate, sum(m.Source_PartCnt) AS QuoteStatus  FROM   ALP_tblIMPProject P INNER JOIN ALP_tblIMPMain M 
          ON P.ImportProjectId = M.ImportProjectId  
		     GROUP BY P.ImportProjectId, p.Source_Id,P.CreatedBy, P.CreatedDate