CREATE TABLE [dbo].[ALP_tblArAlpQMUserDepartment] (
    [Username] VARCHAR (30) NOT NULL,
    [DeptId]   INT          NOT NULL,
    CONSTRAINT [PK_ALP_tblArAlpQMUserDepartment_1] PRIMARY KEY CLUSTERED ([Username] ASC, [DeptId] ASC)
);

