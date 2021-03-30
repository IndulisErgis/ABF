
CREATE procedure Alp_QmUserHierarchy @pUsername varchar(30)  
        as  
          
        select UserName,RoleID,SalesRepID,Supervisor,AlpSalesRepDtls from alp_tblqmu where Supervisor=@pUsername  
        union  
        select UserName,RoleID,SalesRepID,Supervisor,AlpSalesRepDtls from alp_tblqmu where   supervisor in (  
        select UserName         from alp_tblqmu where Supervisor=@pUsername  
        )  
  union  
  select UserName,RoleID,SalesRepID,Supervisor,AlpSalesRepDtls from alp_tblqmu where UserName=@pUsername  
        order by RoleID desc 


update alp_tblqmu set SalesRepID=''where SalesRepID is null 
alter table alp_tblqmu alter column   SalesRepId varchar(3) not null