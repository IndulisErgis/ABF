Create procedure Alp_QMUserDepartment_SP 
                (@status char(1),@username varchar(30),@deptId int,@oldDeptId int) as
                begin
                if @status='A' begin 
                insert into ALP_tblArAlpQMUserDepartment (Username,DeptId)values(@username,@deptId)
                end
                if @status='M' begin 
                update ALP_tblArAlpQMUserDepartment set DeptId=@deptId where Username=@username and DeptId =@oldDeptId
                end
                if @status='D' begin 
                delete from ALP_tblArAlpQMUserDepartment where Username=@username and DeptId =@deptId
                end
                end