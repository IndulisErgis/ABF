CREATE TABLE [dbo].[tblHrLifeInsSub] (
    [ID]                     BIGINT           NOT NULL,
    [LifeInsID]              BIGINT           NOT NULL,
    [MaxAge]                 INT              CONSTRAINT [DF_tblHrLifeInsSub_MaxAge] DEFAULT ((0)) NOT NULL,
    [SelfSEmployerAmount]    [dbo].[pDecimal] CONSTRAINT [DF_tblHrLifeInsSub_SelfSEmployerAmount] DEFAULT ((0)) NOT NULL,
    [SelfSEmployeeAmount]    [dbo].[pDecimal] CONSTRAINT [DF_tblHrLifeInsSub_SelfSEmployeeAmount] DEFAULT ((0)) NOT NULL,
    [SelfNSEmployerAmount]   [dbo].[pDecimal] CONSTRAINT [DF_tblHrLifeInsSub_SelfNSEmployerAmount] DEFAULT ((0)) NOT NULL,
    [SelfNSEmployeeAmount]   [dbo].[pDecimal] CONSTRAINT [DF_tblHrLifeInsSub_SelfNSEmployeeAmount] DEFAULT ((0)) NOT NULL,
    [SpouseSEmployerAmount]  [dbo].[pDecimal] CONSTRAINT [DF_tblHrLifeInsSub_SpoueSEmployerAmount] DEFAULT ((0)) NOT NULL,
    [SpouseSEmployeeAmount]  [dbo].[pDecimal] CONSTRAINT [DF_tblHrLifeInsSub_SpouseSEmployeeAmount] DEFAULT ((0)) NOT NULL,
    [SpouseNSEmployerAmount] [dbo].[pDecimal] CONSTRAINT [DF_tblHrLifeInsSub_SpouseNSEmployerAmount] DEFAULT ((0)) NOT NULL,
    [SpouseNSEmployeeAmount] [dbo].[pDecimal] CONSTRAINT [DF_tblHrLifeInsSub_SpouseNSEmployeeAmount] DEFAULT ((0)) NOT NULL,
    [ChildSEmployerAmount]   [dbo].[pDecimal] CONSTRAINT [DF_tblHrLifeInsSub_ChildSEmployerAmount] DEFAULT ((0)) NOT NULL,
    [ChildSEmployeeAmount]   [dbo].[pDecimal] CONSTRAINT [DF_tblHrLifeInsSub_ChildSEmployeeAmount] DEFAULT ((0)) NOT NULL,
    [ChildNSEmployerAmount]  [dbo].[pDecimal] CONSTRAINT [DF_tblHrLifeInsSub_ChildNSEmployerAmount] DEFAULT ((0)) NOT NULL,
    [ChildNSEmployeeAmount]  [dbo].[pDecimal] CONSTRAINT [DF_tblHrLifeInsSub_ChildNSEmployeeAmount] DEFAULT ((0)) NOT NULL,
    [CF]                     XML              NULL,
    [ts]                     ROWVERSION       NULL,
    CONSTRAINT [PK_tblHrLifeInsSub] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblHrLifeInsSub_LifeInsIDMaxAge]
    ON [dbo].[tblHrLifeInsSub]([LifeInsID] ASC, [MaxAge] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrLifeInsSub';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrLifeInsSub';

