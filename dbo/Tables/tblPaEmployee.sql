CREATE TABLE [dbo].[tblPaEmployee] (
    [EmployeeId]          [dbo].[pEmpID]  NOT NULL,
    [DepartmentId]        [dbo].[pDeptID] NULL,
    [DfltDeptAllocId]     NVARCHAR (10)   NULL,
    [Sex]                 NCHAR (1)       NULL,
    [EeoClass]            NVARCHAR (1)    NULL,
    [CorporateOfficer]    BIT             CONSTRAINT [DF_tblPaEmployee_CorporateOfficer] DEFAULT ((0)) NOT NULL,
    [SeasonalEmployee]    BIT             CONSTRAINT [DF_tblPaEmployee_SeasonalEmployee] DEFAULT ((0)) NOT NULL,
    [ExemptFromOvertime]  BIT             CONSTRAINT [DF_tblPaEmployee_ExemptFromOvertime] DEFAULT ((0)) NOT NULL,
    [DefaultEarningCode]  [dbo].[pCode]   NULL,
    [CheckSort]           NVARCHAR (10)   NULL,
    [EmployeeStatus]      TINYINT         CONSTRAINT [DF_tblPaEmployee_EmployeeStatus] DEFAULT ((0)) NOT NULL,
    [LaborClass]          NVARCHAR (3)    NULL,
    [EmployeeType]        TINYINT         CONSTRAINT [DF_tblPaEmployee_EmployeeType] DEFAULT ((0)) NOT NULL,
    [AdjustToMinimum]     BIT             CONSTRAINT [DF_tblPaEmployee_AdjustToMinimum] DEFAULT ((0)) NOT NULL,
    [GroupCode]           TINYINT         CONSTRAINT [DF_tblPaEmployee_GroupCode] DEFAULT ((0)) NOT NULL,
    [ParticipatingIn401k] BIT             CONSTRAINT [DF_tblPaEmployee_ParticipatingIn401k] DEFAULT ((0)) NOT NULL,
    [EligibleForPension]  BIT             CONSTRAINT [DF_tblPaEmployee_EligibleForPension] DEFAULT ((0)) NOT NULL,
    [StatutoryEmployee]   BIT             CONSTRAINT [DF_tblPaEmployee_StatutoryEmployee] DEFAULT ((0)) NOT NULL,
    [Deceased]            BIT             CONSTRAINT [DF_tblPaEmployee_Deceased] DEFAULT ((0)) NOT NULL,
    [AdjustedHireDate]    DATETIME        NULL,
    [StartDate]           DATETIME        NULL,
    [TerminationDate]     DATETIME        NULL,
    [LastReviewDate]      DATETIME        NULL,
    [NextReviewDate]      DATETIME        NULL,
    [LastCheckDate]       DATETIME        NULL,
    [Salary]              [dbo].[pDec]    CONSTRAINT [DF_tblPaEmployee_Salary] DEFAULT ((0)) NOT NULL,
    [HourlyRate]          [dbo].[pDec]    CONSTRAINT [DF_tblPaEmployee_HourlyRate] DEFAULT ((0)) NOT NULL,
    [PayPeriodsPerYear]   SMALLINT        CONSTRAINT [DF_tblPaEmployee_PayPeriodsPerYear] DEFAULT ((0)) NOT NULL,
    [OverridePay]         [dbo].[pDec]    CONSTRAINT [DF_tblPaEmployee_OverridePay] DEFAULT ((0)) NOT NULL,
    [PayDistribution]     TINYINT         CONSTRAINT [DF_tblPaEmployee_PayDistribution] DEFAULT ((0)) NOT NULL,
    [SupervisorId]        [dbo].[pEmpID]  NULL,
    [JobTitle]            NVARCHAR (40)   NULL,
    [CF]                  XML             NULL,
    [ts]                  ROWVERSION      NULL,
    [TaxGroupId]          BIGINT          NULL,
    CONSTRAINT [PK_tblPaEmployee] PRIMARY KEY CLUSTERED ([EmployeeId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaEmployee_GroupCode]
    ON [dbo].[tblPaEmployee]([GroupCode] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaEmployee_DepartmentId]
    ON [dbo].[tblPaEmployee]([DepartmentId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaEmployee';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaEmployee';

