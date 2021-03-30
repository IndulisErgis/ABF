CREATE TABLE [dbo].[ALP_tblJmSchedulerDefaults] (
    [StartWork]         INT           NULL,
    [EndWork]           INT           NULL,
    [LoadData]          SMALLINT      NULL,
    [Increment]         TINYINT       NULL,
    [TimeBarLength]     SMALLINT      NULL,
    [TimeType]          INT           NULL,
    [TimeTypeColor]     INT           NULL,
    [TimeTypeForeColor] INT           NULL,
    [BackColor]         INT           NULL,
    [BarTextAlign]      TINYINT       NULL,
    [BarTextInfo]       TINYINT       NULL,
    [ListBackColor]     INT           NULL,
    [WeekendColor]      INT           NULL,
    [NonWorkColor]      INT           NULL,
    [Scale]             TINYINT       NULL,
    [SelectedTabColor]  INT           NULL,
    [TabColor]          INT           NULL,
    [PrintTitle]        VARCHAR (255) NULL,
    [AdjustOnMove]      BIT           CONSTRAINT [DF_tblJmSchedulerDefaults_AdjustOnMove] DEFAULT (0) NULL,
    [DisplayOnly]       BIT           CONSTRAINT [DF_tblJmSchedulerDefaults_DisplayOnly] DEFAULT (0) NULL,
    [Ruler3D]           BIT           CONSTRAINT [DF_tblJmSchedulerDefaults_Ruler3D] DEFAULT (0) NULL,
    [RulerSplit]        BIT           CONSTRAINT [DF_tblJmSchedulerDefaults_RulerSplit] DEFAULT (0) NULL,
    [TextIntoView]      BIT           CONSTRAINT [DF_tblJmSchedulerDefaults_TextIntoView] DEFAULT (0) NULL,
    [TimeLines]         BIT           CONSTRAINT [DF_tblJmSchedulerDefaults_TimeLines] DEFAULT (0) NULL,
    [SnapToGrid]        BIT           CONSTRAINT [DF_tblJmSchedulerDefaults_SnapToGrid] DEFAULT (0) NULL,
    [VertReposition]    BIT           CONSTRAINT [DF_tblJmSchedulerDefaults_VertReposition] DEFAULT (0) NULL,
    [ShowWeekends]      BIT           CONSTRAINT [DF_tblJmSchedulerDefaults_ShowWeekends] DEFAULT (0) NULL,
    [PrintColorBars]    BIT           CONSTRAINT [DF_tblJmSchedulerDefaults_PrintColorBars] DEFAULT (0) NULL,
    [PrintWeekendColor] BIT           CONSTRAINT [DF_tblJmSchedulerDefaults_PrintWeekendColor] DEFAULT (0) NULL,
    [PrintListColumns]  BIT           CONSTRAINT [DF_tblJmSchedulerDefaults_PrintListColumns] DEFAULT (0) NULL,
    [Tab3D]             BIT           CONSTRAINT [DF_tblJmSchedulerDefaults_Tab3D] DEFAULT (0) NULL,
    [ShowTimecardsYn]   BIT           CONSTRAINT [DF_tblJmSchedulerDefaults_ShowTimecardsYn] DEFAULT (0) NULL,
    [ts]                ROWVERSION    NULL,
    [TimeBarDialog]     BIT           CONSTRAINT [DF_tblJmSchedulerDefaults_TimeBarDialog] DEFAULT ((0)) NULL,
    [RulerDivision]     INT           NULL,
    [HeaderHeight]      INT           NULL,
    [TimeDistance]      INT           NULL,
    [LoadDaysAfter]     SMALLINT      CONSTRAINT [DF_tblJmSchedulerDefaults_LoadDaysAfter] DEFAULT ((14)) NULL
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblJmSchedulerDefaults] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblJmSchedulerDefaults] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblJmSchedulerDefaults] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblJmSchedulerDefaults] TO PUBLIC
    AS [dbo];

