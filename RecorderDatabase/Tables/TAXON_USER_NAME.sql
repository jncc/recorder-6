/*********************************************************************\
  Object:  Table [dbo].[TAXON_USER_NAME]  Script Date: 06/02/2002 
 
  Script to change the ITEM_NAME column type of TAXON_USER_NAME table
  from a CHAR 60 to a VARCHAR 60. 
\*********************************************************************/

BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
ALTER TABLE dbo.TAXON_USER_NAME
	DROP CONSTRAINT FK_TAXON_USER_NAME_TAXON_LIST_ITEM
GO
COMMIT
BEGIN TRANSACTION
ALTER TABLE dbo.TAXON_USER_NAME
	DROP CONSTRAINT DF_TAXON_USER_NAME_ENTRY_DATE
GO
CREATE TABLE dbo.Tmp_TAXON_USER_NAME
	(
	TAXON_USER_NAME_KEY char(16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	TAXON_LIST_ITEM_KEY char(16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	ITEM_NAME varchar(60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	PREFERRED bit NULL,
	[LANGUAGE] char(2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	ENTERED_BY char(16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	ENTRY_DATE datetime NOT NULL,
	CHANGED_BY char(16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	CHANGED_DATE datetime NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Tmp_TAXON_USER_NAME ADD CONSTRAINT
	DF_TAXON_USER_NAME_ENTRY_DATE DEFAULT (getdate()) FOR ENTRY_DATE
GO
IF EXISTS(SELECT * FROM dbo.TAXON_USER_NAME)
	 EXEC('INSERT INTO dbo.Tmp_TAXON_USER_NAME (TAXON_USER_NAME_KEY, TAXON_LIST_ITEM_KEY, ITEM_NAME, PREFERRED, [LANGUAGE], ENTERED_BY, ENTRY_DATE, CHANGED_BY, CHANGED_DATE)
		SELECT TAXON_USER_NAME_KEY, TAXON_LIST_ITEM_KEY, CONVERT(varchar(60), ITEM_NAME), PREFERRED, [LANGUAGE], ENTERED_BY, ENTRY_DATE, CHANGED_BY, CHANGED_DATE FROM dbo.TAXON_USER_NAME TABLOCKX')
GO
DROP TABLE dbo.TAXON_USER_NAME
GO
EXECUTE sp_rename N'dbo.Tmp_TAXON_USER_NAME', N'TAXON_USER_NAME', 'OBJECT'
GO
ALTER TABLE dbo.TAXON_USER_NAME ADD CONSTRAINT
	PK_TAXON_USER_NAME PRIMARY KEY CLUSTERED 
	(
	TAXON_USER_NAME_KEY
	) ON [PRIMARY]

GO
ALTER TABLE dbo.TAXON_USER_NAME WITH NOCHECK ADD CONSTRAINT
	FK_TAXON_USER_NAME_TAXON_LIST_ITEM FOREIGN KEY
	(
	TAXON_LIST_ITEM_KEY
	) REFERENCES dbo.TAXON_LIST_ITEM
	(
	TAXON_LIST_ITEM_KEY
	)
GO
GRANT SELECT ON dbo.TAXON_USER_NAME TO R2k_ReadOnly  AS dbo
GRANT SELECT ON dbo.TAXON_USER_NAME TO R2k_RecordCardsOnly  AS dbo
GRANT SELECT ON dbo.TAXON_USER_NAME TO R2k_AddOnly  AS dbo
GRANT INSERT ON dbo.TAXON_USER_NAME TO R2k_AddOnly  AS dbo
GRANT SELECT ON dbo.TAXON_USER_NAME TO R2k_FullEdit  AS dbo
GRANT UPDATE ON dbo.TAXON_USER_NAME TO R2k_FullEdit  AS dbo
GRANT INSERT ON dbo.TAXON_USER_NAME TO R2k_FullEdit  AS dbo
GRANT DELETE ON dbo.TAXON_USER_NAME TO R2k_FullEdit  AS dbo
GRANT SELECT ON dbo.TAXON_USER_NAME TO R2k_Administrator  AS dbo
GRANT UPDATE ON dbo.TAXON_USER_NAME TO R2k_Administrator  AS dbo
GRANT INSERT ON dbo.TAXON_USER_NAME TO R2k_Administrator  AS dbo
GRANT DELETE ON dbo.TAXON_USER_NAME TO R2k_Administrator  AS dbo
GO

COMMIT