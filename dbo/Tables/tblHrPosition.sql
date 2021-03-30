CREATE TABLE [dbo].[tblHrPosition] (
    [ID]                               BIGINT           NOT NULL,
    [Description]                      NVARCHAR (50)    NOT NULL,
    [JobTypeCodeID]                    BIGINT           NULL,
    [Department]                       [dbo].[pDeptID]  NULL,
    [MinEdLevelTypeCodeID]             BIGINT           NULL,
    [CountyDirectCareStatusTypeCodeID] BIGINT           NULL,
    [PositionHoursBudgeted]            [dbo].[pDecimal] CONSTRAINT [DF_tblHrPosition_PositionHoursBudgeted] DEFAULT ((0)) NOT NULL,
    [SalaryBudgeted]                   [dbo].[pDecimal] CONSTRAINT [DF_tblHrPosition_SalaryBudgeted] DEFAULT ((0)) NOT NULL,
    [SupervisorPositionID]             BIGINT           NULL,
    [WageHourExemptStatusTypeCodeID]   BIGINT           NULL,
    [WorkersCompensationTypeCodeID]    BIGINT           NULL,
    [DriversLicenseRequired]           BIT              CONSTRAINT [DF_tblHrPosition_DriversLicenseRequired] DEFAULT ((0)) NOT NULL,
    [ProfessionalLicenseRequired]      BIT              CONSTRAINT [DF_tblHrPosition_ProfessionalLicenseRequired] DEFAULT ((0)) NOT NULL,
    [EducationalTranscriptRequired]    BIT              CONSTRAINT [DF_tblHrPosition_EducationalTranscriptRequired] DEFAULT ((0)) NOT NULL,
    [PositionTypeCodeID]               BIGINT           NULL,
    [PositionCaseTypeCodeID]           BIGINT           NULL,
    [PositionActiveDate]               DATETIME         NULL,
    [PositionInactiveDate]             DATETIME         NULL,
    [DivisionTypeCodeID]               BIGINT           NULL,
    [ProgramTypeCodeID]                BIGINT           NULL,
    [LocationTypeCodeID]               BIGINT           NULL,
    [SpecialStatus]                    BIT              CONSTRAINT [DF_tblHrPosition_SpecialStatus] DEFAULT ((0)) NOT NULL,
    [CheckSort]                        NVARCHAR (10)    NULL,
    [AdjustToMinimum]                  BIT              CONSTRAINT [DF_tblHrPosition_AdjustToMinimum] DEFAULT ((0)) NOT NULL,
    [PayPeriodsPerYear]                SMALLINT         NOT NULL,
    [GroupCode]                        TINYINT          NOT NULL,
    [DefaultEarningCode]               [dbo].[pCode]    NULL,
    [LeavePlanID]                      BIGINT           NULL,
    [CF]                               XML              NULL,
    [ts]                               ROWVERSION       NULL,
    CONSTRAINT [PK_tblHrPosition] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblHrPosition_Description]
    ON [dbo].[tblHrPosition]([Description] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrPosition';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrPosition';

