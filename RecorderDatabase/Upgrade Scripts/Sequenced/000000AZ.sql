/****** Changes to display the Review Status ******/

DELETE FROM SETTING WHERE [NAME] = 'Competency'

GO

INSERT INTO SETTING ([Name],[Data]) VALUES ('Competency','3')

GO


UPDATE DETERMINER_ROLE SET VALIDATION_COMPETENCY = 4 WHERE DETERMINER_ROLE_KEY = 'NBNSYS0000000001'
 
UPDATE DETERMINER_ROLE SET VALIDATION_COMPETENCY = 3 WHERE DETERMINER_ROLE_KEY = 'NBNSYS0000000004'

GO

INSERT INTO DETERMINER_ROLE (DETERMINER_ROLE_KEY,SHORT_NAME,LONG_NAME,VALIDATION_COMPETENCY,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA,CUSTODIAN,HIDE)
VALUES ('NBNSYS0000000005','Reviewer','Reviewer',6,'TESTDATA00000001',getdate(),1,'NBNSYS00',0)


GO

/****** Object:  UserDefinedFunction [dbo].[ufn_ReturnReviewStatus]    Script Date: 01/28/2017 15:07:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



GO
/****** Object:  UserDefinedFunction [dbo].[ufn_ReturnReviewStatus]    Script Date: 01/29/2017 17:30:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[ufn_ReturnReviewStatus] 
(@TOCCKey char(16))
RETURNS char(1)

AS
BEGIN

DECLARE @ReviewVDS Int
DECLARE @ReviewVDE Int
DECLARE @ReviewPreferred  bit
DECLARE @ReviewVerified int
DECLARE @ReviewTLIKey char(16) 
DECLARE @ReturnString varchar(30) 
DECLARE @LatestVDS Int
DECLARE @LatestVDE Int
DECLARE @LatestPreferred bit
DECLARE @LatestVerified int
DECLARE @LatestTLIKey char(16)

DECLARE @PreferredVDS Int
DECLARE @PreferredVDE Int
DECLARE @PreferredPreferred bit
DECLARE @PreferredVerified int
DECLARE @PreferredTLIKey char(16)

DECLARE @Competency Int 

SET @Competency = (SELECT CAST([DATA] AS integer) FROM SETTING WHERE [NAME] = 'Competency')

SET @ReturnString = '0'

If @Competency <> 0

BEGIN  
  select @ReviewVDS = VAGUE_DATE_START, 
       @ReviewVDE = VAGUE_DATE_END,
       @ReviewTLIKey = TAXON_LIST_ITEM_KEY,
       @ReviewPreferred = PREFERRED,
       @ReviewVerified = DT.VERIFIED 
       From TAXON_DETERMINATION
       INNER JOIN DETERMINATION_TYPE DT ON DT.DETERMINATION_TYPE_KEY = TAXON_DETERMINATION.DETERMINATION_TYPE_KEY     
       WHERE cast(TAXON_DETERMINATION.VAGUE_DATE_START as varchar(10)) + cast(TAXON_DETERMINATION.VAGUE_DATE_END as varchar(10))+ TAXON_DETERMINATION.TAXON_DETERMINATION_KEY
        =
       (select max(cast(tdet.VAGUE_DATE_START as varchar(10)) + cast(tdet.VAGUE_DATE_END as varchar(10))+ tdet.TAXON_DETERMINATION_KEY)
       From TAXON_DETERMINATION tdet inneR join 
       DETERMINER_ROLE DR on DR.DETERMINER_ROLE_KEY = tdet.DETERMINER_ROLE_KEY
       WHERE tdet.TAXON_OCCURRENCE_KEY = @TOCCKey AND DR.VALIDATION_COMPETENCY >= @Competency ) 

 
  select @LatestVDS = VAGUE_DATE_START, 
       @LatestVDE = VAGUE_DATE_END,
       @LatestTLIKey = TAXON_LIST_ITEM_KEY,
       @LatestPreferred = PREFERRED,
       @LatestVerified = DT.VERIFIED 
       From TAXON_DETERMINATION
       INNER JOIN DETERMINATION_TYPE DT ON DT.DETERMINATION_TYPE_KEY = TAXON_DETERMINATION.DETERMINATION_TYPE_KEY     
       WHERE cast(TAXON_DETERMINATION.VAGUE_DATE_START as varchar(10)) + cast(TAXON_DETERMINATION.VAGUE_DATE_END as varchar(10))+ TAXON_DETERMINATION.TAXON_DETERMINATION_KEY
        =
       (select max(cast(tdet.VAGUE_DATE_START as varchar(10)) + cast(tdet.VAGUE_DATE_END as varchar(10))+ tdet.TAXON_DETERMINATION_KEY)
       From TAXON_DETERMINATION tdet inneR join 
       DETERMINER_ROLE DR on DR.DETERMINER_ROLE_KEY = tdet.DETERMINER_ROLE_KEY
       WHERE tdet.TAXON_OCCURRENCE_KEY = @TOCCKey ) 

  select @PreferredVDS = VAGUE_DATE_START, 
       @PreferredVDE = VAGUE_DATE_END,
       @PreferredTLIKey = TAXON_LIST_ITEM_KEY,
       @PreferredPreferred = PREFERRED,
       @PreferredVerified = DT.VERIFIED 
       From TAXON_DETERMINATION
       INNER JOIN DETERMINATION_TYPE DT ON DT.DETERMINATION_TYPE_KEY = TAXON_DETERMINATION.DETERMINATION_TYPE_KEY     
       WHERE cast(TAXON_DETERMINATION.VAGUE_DATE_START as varchar(10)) + cast(TAXON_DETERMINATION.VAGUE_DATE_END as varchar(10))+ TAXON_DETERMINATION.TAXON_DETERMINATION_KEY
        =
       (select max(cast(tdet.VAGUE_DATE_START as varchar(10)) + cast(tdet.VAGUE_DATE_END as varchar(10))+ tdet.TAXON_DETERMINATION_KEY)
       From TAXON_DETERMINATION tdet inneR join 
       DETERMINER_ROLE DR on DR.DETERMINER_ROLE_KEY = tdet.DETERMINER_ROLE_KEY
       WHERE tdet.TAXON_OCCURRENCE_KEY = @TOCCKey AND TDET.PREFERRED = 1 ) 

   SET @ReturnString = '3' 
   IF  @LatestVDE > ISNUll(@ReviewVDS,0) Set @ReturnString = '1'
   ELSE IF
    (@PreferredTLIKey <> ISNULL(@ReviewTLIKey,'')) OR
    (@PreferredVerified <> @ReviewVerified AND  @ReviewVerified = 1) OR
    (@PreferredVerified <> @ReviewVerified AND  @PreferredVerified = 1) 
     SET @ReturnString = '2'
 END
 Return @ReturnString

END

GO

GRANT EXECUTE ON [dbo].[ufn_ReturnReviewStatus] TO PUBLIC

GO

/****** Object:  UserDefinedFunction [dbo].[ufn_GetIndividualFull]    Script Date: 01/23/2017 22:02:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[ufn_GetIndividualFull](@NameKey char(16))
RETURNS varchar(100)
--
--	DESCRIPTION
--	Function to return a formatted string of an individuals title, forename, initials and surname.
--	Given a Name_Key
--	PARAMETERS
--	NAME			DESCRIPTION
--	@NameKey	
--	AUTHOR:	Mike Weideli
--	CREATED: January 2017
--  
AS
BEGIN
Declare @ReturnString varchar(100)
--****************************************************************************************************

SET @ReturnString = (SELECT ISNULL(I.Forename + ' ','') +  I.Surname + ISNULL(' ' + I.Title ,'') +
 isnull(' ' +I.initials,'')  FROM INDIVIDUAL I WHERE I.Name_Key = @NameKey) 

RETURN @ReturnString
--****************************************************************************************************

END

GO

GRANT EXECUTE ON  [dbo].[ufn_GetIndividualFull] TO PUBLIC


GO

/****** Object:  View [dbo].[LC_REVIEW_DETAILS]    Script Date: 01/23/2017 22:50:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[LC_REVIEW_DETAILS]
AS
SELECT     dbo.LCReturnVagueDateShort(dbo.TAXON_DETERMINATION.VAGUE_DATE_START, dbo.TAXON_DETERMINATION.VAGUE_DATE_END, 
                      dbo.TAXON_DETERMINATION.VAGUE_DATE_TYPE) AS Expr1, dbo.TAXON_DETERMINATION.TAXON_LIST_ITEM_KEY, dbo.TAXON_DETERMINATION.PREFERRED, 
                      DT.Verified, DT.SHORT_NAME, dbo.ufn_GetIndividualFull(dbo.TAXON_DETERMINATION.DETERMINER) AS Reviewer
FROM         dbo.TAXON_DETERMINATION INNER JOIN
                      dbo.DETERMINATION_TYPE AS DT ON DT.DETERMINATION_TYPE_KEY = dbo.TAXON_DETERMINATION.DETERMINATION_TYPE_KEY
WHERE     (CAST(dbo.TAXON_DETERMINATION.VAGUE_DATE_START AS varchar(10)) + CAST(dbo.TAXON_DETERMINATION.VAGUE_DATE_END AS varchar(10)) 
                      + dbo.TAXON_DETERMINATION.TAXON_DETERMINATION_KEY =
                          (SELECT     MAX(CAST(tdet.VAGUE_DATE_START AS varchar(10)) + CAST(tdet.VAGUE_DATE_END AS varchar(10)) + tdet.TAXON_DETERMINATION_KEY) 
                                                   AS Expr1
                            FROM          dbo.TAXON_DETERMINATION AS tdet INNER JOIN
                                                   dbo.DETERMINER_ROLE AS DR ON DR.DETERMINER_ROLE_KEY = tdet.DETERMINER_ROLE_KEY
                            WHERE      (tdet.TAXON_OCCURRENCE_KEY = Taxon_Determination.Taxon_Occurrence_Key) AND (DR.VALIDATION_COMPETENCY = 9)))

GO


GRANT SELECT ON [dbo].[LC_REVIEW_DETAILS] tO PUBLIC 


GO
/****** Object:  UserDefinedFunction [dbo].[ufn_ReturnReviewStatusText]    Script Date: 01/28/2017 15:17:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[ufn_ReturnReviewStatusText] 
(@StatusCode char(1))
RETURNS varchar(30)

AS
BEGIN
declare @ReviewStatus varchar(30)  
  Set @ReviewStatus = (select case @StatusCode
    when  '0' then ''
    When '1' then 'Not Reviewed'
    When '2' then 'Review Unallocated'
  else
    'Review Complete'
  end)        

  RETURN @ReviewStatus

END

GO

Grant Execute ON [dbo].[ufn_ReturnReviewStatusText] TO PUBLIC

Go 

DELETE FROM IW_TABLE_RULE_RELATED_TABLE WHERE IW_TABLE_RULE_KEY = 'SYSTEM01000000A0'

DELETE FROM IW_TABLE_RULE_RELATED_FIELD WHERE IW_TABLE_RULE_KEY = 'SYSTEM01000000A0'

DELETE FROM IW_TABLE_RULE_OUTPUT_FIELD WHERE IW_TABLE_RULE_KEY = 'SYSTEM0100000007'AND IW_OUTPUT_FIELD_KEY = 'SYSTEM010000001B'
DELETE FROM IW_TABLE_RULE_OUTPUT_FIELD WHERE IW_TABLE_RULE_KEY = 'SYSTEM01000000A0'
DELETE FROM IW_TABLE_RULE_OUTPUT_FIELD WHERE IW_TABLE_RULE_KEY = 'SYSTEM0100000007'AND IW_OUTPUT_FIELD_KEY = 'SYSTEM01000000I0'

DELETE FROM IW_OUTPUT_FIELD WHERE IW_OUTPUT_FIELD_KEY = 'SYSTEM01000000A0'
DELETE FROM IW_OUTPUT_FIELD WHERE IW_OUTPUT_FIELD_KEY = 'SYSTEM01000000B0'
DELETE FROM IW_OUTPUT_FIELD WHERE IW_OUTPUT_FIELD_KEY = 'SYSTEM01000000C0'
DELETE FROM IW_OUTPUT_FIELD WHERE IW_OUTPUT_FIELD_KEY = 'SYSTEM01000000D0'
DELETE FROM IW_OUTPUT_FIELD WHERE IW_OUTPUT_FIELD_KEY = 'SYSTEM01000000E0'
DELETE FROM IW_OUTPUT_FIELD WHERE IW_OUTPUT_FIELD_KEY = 'SYSTEM01000000F0'
DELETE FROM IW_OUTPUT_FIELD WHERE IW_OUTPUT_FIELD_KEY = 'SYSTEM01000000G0'
DELETE FROM IW_OUTPUT_FIELD WHERE IW_OUTPUT_FIELD_KEY = 'SYSTEM01000000H0'
DELETE FROM IW_OUTPUT_FIELD WHERE IW_OUTPUT_FIELD_KEY = 'SYSTEM01000000I0'
DELETE FROM IW_OUTPUT_FIELD WHERE IW_OUTPUT_FIELD_KEY = 'SYSTEM01000000B1'
DELETE FROM IW_OUTPUT_FIELD WHERE IW_OUTPUT_FIELD_KEY = 'SYSTEM01000000B2'

DELETE FROM IW_TABLE_RULE WHERE IW_TABLE_RULE_KEY = 'SYSTEM01000000A0'

DELETE FROM IW_COLUMN_TYPE_RELATIONSHIP WHERE IW_COLUMN_TYPE_KEY = 'SYSTEM01000000A0'
DELETE FROM IW_COLUMN_TYPE_RELATIONSHIP WHERE RELATED_IW_COLUMN_TYPE_KEY = 'SYSTEM01000000A0'

DELETE FROM IW_COLUMN_TYPE_PATTERN WHERE IW_COLUMN_TYPE_KEY = 'SYSTEM01000000A0'
DELETE FROM IW_COLUMN_TYPE_PATTERN WHERE IW_COLUMN_TYPE_KEY = 'SYSTEM01000000B0'
DELETE FROM IW_COLUMN_TYPE_PATTERN WHERE IW_COLUMN_TYPE_KEY = 'SYSTEM01000000C0'
DELETE FROM IW_COLUMN_TYPE_PATTERN WHERE IW_COLUMN_TYPE_KEY = 'SYSTEM01000000D0'
DELETE FROM IW_COLUMN_TYPE_PATTERN WHERE IW_COLUMN_TYPE_KEY = 'SYSTEM01000000E0'
DELETE FROM IW_COLUMN_TYPE_PATTERN WHERE IW_COLUMN_TYPE_KEY = 'SYSTEM01000000F0'
DELETE FROM IW_COLUMN_TYPE_PATTERN WHERE IW_COLUMN_TYPE_KEY = 'SYSTEM01000000G0'


DELETE FROM IW_COLUMN_TYPE_MATCH_RULE WHERE IW_COLUMN_TYPE_KEY = 'SYSTEM01000000A0'
DELETE FROM IW_COLUMN_TYPE_MATCH_RULE WHERE IW_COLUMN_TYPE_KEY = 'SYSTEM01000000C0'
DELETE FROM IW_COLUMN_TYPE_MATCH_RULE WHERE IW_COLUMN_TYPE_KEY = 'SYSTEM01000000D0'
DELETE FROM IW_COLUMN_TYPE_MATCH_RULE WHERE IW_COLUMN_TYPE_KEY = 'SYSTEM01000000F0'

DELETE FROM Iw_COLUMN_TYPE WHERE IW_COLUMN_TYPE_KEY = 'SYSTEM01000000A0'
DELETE FROM Iw_COLUMN_TYPE WHERE IW_COLUMN_TYPE_KEY = 'SYSTEM01000000B0'
DELETE FROM Iw_COLUMN_TYPE WHERE IW_COLUMN_TYPE_KEY = 'SYSTEM01000000C0'
DELETE FROM Iw_COLUMN_TYPE WHERE IW_COLUMN_TYPE_KEY = 'SYSTEM01000000D0'
DELETE FROM Iw_COLUMN_TYPE WHERE IW_COLUMN_TYPE_KEY = 'SYSTEM01000000E0'
DELETE FROM Iw_COLUMN_TYPE WHERE IW_COLUMN_TYPE_KEY = 'SYSTEM01000000F0'
DELETE FROM Iw_COLUMN_TYPE WHERE IW_COLUMN_TYPE_KEY = 'SYSTEM01000000G0'

GO

INSERT INTO IW_COLUMN_TYPE (IW_COLUMN_TYPE_KEY,CLASS_NAME,ITEM_NAME,REQUIRED,COMMONLY_USED,SEQUENCE,
PARSER_CLASS_NAME,MAXIMUM_LENGTH,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000A0','TColumnType','Reviewer Name',0,1,6,'TDeterminerParser',100,'TESTDATA00000001',getDate(),1)

INSERT INTO Iw_COLUMN_TYPE (IW_COLUMN_TYPE_KEY,CLASS_NAME,ITEM_NAME,REQUIRED,COMMONLY_USED,
PARSER_CLASS_NAME,MAXIMUM_LENGTH,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000B0','TColumnType','Review Date',0,1,'TDeterminationDateParser',100,'TESTDATA00000001',getDate(),1)


INSERT INTO Iw_COLUMN_TYPE (IW_COLUMN_TYPE_KEY,CLASS_NAME,ITEM_NAME,REQUIRED,COMMONLY_USED,
PARSER_CLASS_NAME,MAXIMUM_LENGTH,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000C0','TColumnType','Review Type',0,0,'TTextParser',21,'TESTDATA00000001',getDate(),1)

INSERT INTO Iw_COLUMN_TYPE (IW_COLUMN_TYPE_KEY,CLASS_NAME,ITEM_NAME,REQUIRED,COMMONLY_USED,
PARSER_CLASS_NAME,MAXIMUM_LENGTH,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000D0','TColumnType','Reviewer Role',0,0,'TTextParser',20,'TESTDATA00000001',getDate(),1)

INSERT INTO Iw_COLUMN_TYPE (IW_COLUMN_TYPE_KEY,CLASS_NAME,ITEM_NAME,REQUIRED,COMMONLY_USED,
PARSER_CLASS_NAME,MAXIMUM_LENGTH,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000E0','TColumnType','Reviewer Reference',0,0,'TTextParser',500,'TESTDATA00000001',getDate(),1)

INSERT INTO Iw_COLUMN_TYPE (IW_COLUMN_TYPE_KEY,CLASS_NAME,ITEM_NAME,REQUIRED,COMMONLY_USED,
PARSER_CLASS_NAME,MAXIMUM_LENGTH,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000F0','TColumnType','Reviewer Species',0,0,'TTextParser',100,'TESTDATA00000001',getDate(),1)

INSERT INTO Iw_COLUMN_TYPE (IW_COLUMN_TYPE_KEY,CLASS_NAME,ITEM_NAME,REQUIRED,COMMONLY_USED,
PARSER_CLASS_NAME,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000G0','TColumnType','Review Preferred',0,0,'TBooleanParser','TESTDATA00000001',getDate(),1)

GO

INSERT INTO IW_COLUMN_TYPE_MATCH_RULE (IW_COLUMN_TYPE_KEY,IW_MATCH_RULE_KEY,FIELD_INDEX,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000A0','SYSTEM0100000000',0,'TESTDATA00000001',getDate(),1)

INSERT INTO IW_COLUMN_TYPE_MATCH_RULE (IW_COLUMN_TYPE_KEY,IW_MATCH_RULE_KEY,FIELD_INDEX,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000C0','SYSTEM010000000D',0,'TESTDATA00000001',getDate(),1)

INSERT INTO IW_COLUMN_TYPE_MATCH_RULE (IW_COLUMN_TYPE_KEY,IW_MATCH_RULE_KEY,FIELD_INDEX,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000D0','SYSTEM010000000C',0,'TESTDATA00000001',getDate(),1)

INSERT INTO IW_COLUMN_TYPE_MATCH_RULE (IW_COLUMN_TYPE_KEY,IW_MATCH_RULE_KEY,FIELD_INDEX,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000F0','SYSTEM0100000001',0,'TESTDATA00000001',getDate(),1)

GO

INSERT INTO IW_COLUMN_TYPE_PATTERN (IW_COLUMN_TYPE_KEY,PATTERN,EXCLUDE_MATCH,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000A0','Reviewer',0,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_COLUMN_TYPE_PATTERN (IW_COLUMN_TYPE_KEY,PATTERN,EXCLUDE_MATCH,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000A0','Reviewer Name',0,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_COLUMN_TYPE_PATTERN (IW_COLUMN_TYPE_KEY,PATTERN,EXCLUDE_MATCH,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000B0','Review Date',0,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_COLUMN_TYPE_PATTERN (IW_COLUMN_TYPE_KEY,PATTERN,EXCLUDE_MATCH,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000B0','Reviewer Date',0,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_COLUMN_TYPE_PATTERN (IW_COLUMN_TYPE_KEY,PATTERN,EXCLUDE_MATCH,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000C0','Review Type',0,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_COLUMN_TYPE_PATTERN (IW_COLUMN_TYPE_KEY,PATTERN,EXCLUDE_MATCH,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000C0','Reviewer Type',0,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_COLUMN_TYPE_PATTERN (IW_COLUMN_TYPE_KEY,PATTERN,EXCLUDE_MATCH,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000D0','Review Role',0,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_COLUMN_TYPE_PATTERN (IW_COLUMN_TYPE_KEY,PATTERN,EXCLUDE_MATCH,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000D0','Reviewer Role',0,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_COLUMN_TYPE_PATTERN (IW_COLUMN_TYPE_KEY,PATTERN,EXCLUDE_MATCH,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000E0','Review Comment',0,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_COLUMN_TYPE_PATTERN (IW_COLUMN_TYPE_KEY,PATTERN,EXCLUDE_MATCH,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000E0','Reviewer Comment',0,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_COLUMN_TYPE_PATTERN (IW_COLUMN_TYPE_KEY,PATTERN,EXCLUDE_MATCH,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000F0','Review Species',0,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_COLUMN_TYPE_PATTERN (IW_COLUMN_TYPE_KEY,PATTERN,EXCLUDE_MATCH,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000F0','Review Taxon',0,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_COLUMN_TYPE_PATTERN (IW_COLUMN_TYPE_KEY,PATTERN,EXCLUDE_MATCH,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000F0','Reviewer Species',0,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_COLUMN_TYPE_PATTERN (IW_COLUMN_TYPE_KEY,PATTERN,EXCLUDE_MATCH,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000G0','Review Preferred',0,'TESTDATA00000001', getdate(),1)

GO

INSERT INTO IW_COLUMN_TYPE_RELATIONSHIP (IW_COLUMN_TYPE_KEY,RELATED_IW_COLUMN_TYPE_KEY,RELATIONSHIP_TYPE,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000A0','SYSTEM01000000B0',3,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_COLUMN_TYPE_RELATIONSHIP (IW_COLUMN_TYPE_KEY,RELATED_IW_COLUMN_TYPE_KEY,RELATIONSHIP_TYPE,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000A0','SYSTEM01000000C0',3,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_COLUMN_TYPE_RELATIONSHIP (IW_COLUMN_TYPE_KEY,RELATED_IW_COLUMN_TYPE_KEY,RELATIONSHIP_TYPE,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000A0','SYSTEM01000000D0',3,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_COLUMN_TYPE_RELATIONSHIP (IW_COLUMN_TYPE_KEY,RELATED_IW_COLUMN_TYPE_KEY,RELATIONSHIP_TYPE,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000A0','SYSTEM01000000E0',3,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_COLUMN_TYPE_RELATIONSHIP (IW_COLUMN_TYPE_KEY,RELATED_IW_COLUMN_TYPE_KEY,RELATIONSHIP_TYPE,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000A0','SYSTEM01000000F0',3,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_COLUMN_TYPE_RELATIONSHIP (IW_COLUMN_TYPE_KEY,RELATED_IW_COLUMN_TYPE_KEY,RELATIONSHIP_TYPE,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000A0','SYSTEM01000000G0',3,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_COLUMN_TYPE_RELATIONSHIP (IW_COLUMN_TYPE_KEY,RELATED_IW_COLUMN_TYPE_KEY,RELATIONSHIP_TYPE,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000C0','SYSTEM01000000A0',0,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_COLUMN_TYPE_RELATIONSHIP (IW_COLUMN_TYPE_KEY,RELATED_IW_COLUMN_TYPE_KEY,RELATIONSHIP_TYPE,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000D0','SYSTEM01000000A0',0,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_COLUMN_TYPE_RELATIONSHIP (IW_COLUMN_TYPE_KEY,RELATED_IW_COLUMN_TYPE_KEY,RELATIONSHIP_TYPE,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000E0','SYSTEM01000000A0',0,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_COLUMN_TYPE_RELATIONSHIP (IW_COLUMN_TYPE_KEY,RELATED_IW_COLUMN_TYPE_KEY,RELATIONSHIP_TYPE,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000F0','SYSTEM01000000A0',0,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_COLUMN_TYPE_RELATIONSHIP (IW_COLUMN_TYPE_KEY,RELATED_IW_COLUMN_TYPE_KEY,RELATIONSHIP_TYPE,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000G0','SYSTEM01000000A0',0,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_COLUMN_TYPE_RELATIONSHIP (IW_COLUMN_TYPE_KEY,RELATED_IW_COLUMN_TYPE_KEY,RELATIONSHIP_TYPE,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000B0','SYSTEM01000000A0',0,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_COLUMN_TYPE_RELATIONSHIP (IW_COLUMN_TYPE_KEY,RELATED_IW_COLUMN_TYPE_KEY,RELATIONSHIP_TYPE,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000B0','SYSTEM010000000Z',2,'TESTDATA00000001', getdate(),1)

GO

INSERT INTO IW_TABLE_RULE (IW_TABLE_RULE_KEY,SEQUENCE,TABLE_NAME,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000A0',20,'Taxon_Determination','TESTDATA00000001', getdate(),1)

GO

INSERT INTO IW_OUTPUT_FIELD (IW_OUTPUT_FIELD_KEY,NAME,DATA_TYPE,IW_COLUMN_TYPE_KEY,SOURCE_FIELD_NAME,GENERATING_CLASS_NAME,GENERATOR_FIELD_INDEX,
ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES('SYSTEM01000000A0','Determiner','CHAR(16)',NULL,NULL,'TReviewerFieldGenerator',0,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_OUTPUT_FIELD (IW_OUTPUT_FIELD_KEY,NAME,DATA_TYPE,IW_COLUMN_TYPE_KEY,SOURCE_FIELD_NAME,GENERATING_CLASS_NAME,GENERATOR_FIELD_INDEX,
ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES('SYSTEM01000000B0','Vague_Date_Start','INT',NULL,NULL,'TReviewDateFieldGenerator',0,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_OUTPUT_FIELD (IW_OUTPUT_FIELD_KEY,NAME,DATA_TYPE,IW_COLUMN_TYPE_KEY,SOURCE_FIELD_NAME,GENERATING_CLASS_NAME,GENERATOR_FIELD_INDEX,
ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES('SYSTEM01000000B1','Vague_Date_End','INT',NULL,NULL,'TReviewDateFieldGenerator',1,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_OUTPUT_FIELD (IW_OUTPUT_FIELD_KEY,NAME,DATA_TYPE,IW_COLUMN_TYPE_KEY,SOURCE_FIELD_NAME,GENERATING_CLASS_NAME,GENERATOR_FIELD_INDEX,
ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES('SYSTEM01000000B2','Vague_Date_Type','VARCHAR(2)',NULL,NULL,'TReviewDateFieldGenerator',2,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_OUTPUT_FIELD (IW_OUTPUT_FIELD_KEY,NAME,DATA_TYPE,IW_COLUMN_TYPE_KEY,SOURCE_FIELD_NAME,GENERATING_CLASS_NAME,GENERATOR_FIELD_INDEX,
ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES('SYSTEM01000000C0','Determination_Type_Key','CHAR(16)',NULL,NULL,'TReviewTypeFieldGenerator',0,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_OUTPUT_FIELD (IW_OUTPUT_FIELD_KEY,NAME,DATA_TYPE,IW_COLUMN_TYPE_KEY,SOURCE_FIELD_NAME,GENERATING_CLASS_NAME,GENERATOR_FIELD_INDEX,
ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES('SYSTEM01000000D0','Determiner_Role_Key','CHAR(16)',NULL,NULL,'TReviewerRoleFieldGenerator',0,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_OUTPUT_FIELD (IW_OUTPUT_FIELD_KEY,NAME,DATA_TYPE,IW_COLUMN_TYPE_KEY,SOURCE_FIELD_NAME,GENERATING_CLASS_NAME,GENERATOR_FIELD_INDEX,
ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES('SYSTEM01000000E0','Comment','TEXT','SYSTEM01000000E0','data',null,null,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_OUTPUT_FIELD (IW_OUTPUT_FIELD_KEY,NAME,DATA_TYPE,IW_COLUMN_TYPE_KEY,SOURCE_FIELD_NAME,GENERATING_CLASS_NAME,GENERATOR_FIELD_INDEX,
ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES('SYSTEM01000000F0','Taxon_List_Item_Key','CHAR(16)',null,null,'TReviewSpeciesFieldGenerator',0,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_OUTPUT_FIELD (IW_OUTPUT_FIELD_KEY,NAME,DATA_TYPE,IW_COLUMN_TYPE_KEY,SOURCE_FIELD_NAME,GENERATING_CLASS_NAME,GENERATOR_FIELD_INDEX,
ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES('SYSTEM01000000G0','Preferred','BIT','SYSTEM01000000G0','boolean',null,null,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_OUTPUT_FIELD (IW_OUTPUT_FIELD_KEY,NAME,DATA_TYPE,IW_COLUMN_TYPE_KEY,SOURCE_FIELD_NAME,GENERATING_CLASS_NAME,GENERATOR_FIELD_INDEX,
ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES('SYSTEM01000000H0','Taxon_Determination_Key','CHAR(16)',null,null,'TKeyFieldGenerator',0,'TESTDATA00000001', getdate(),1)

INSERT INTO IW_OUTPUT_FIELD (IW_OUTPUT_FIELD_KEY,NAME,DATA_TYPE,IW_COLUMN_TYPE_KEY,SOURCE_FIELD_NAME,GENERATING_CLASS_NAME,GENERATOR_FIELD_INDEX,
ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES('SYSTEM01000000I0','Preferred','BIT',null,null,'TDeterminerPreferredFieldGenerator',0,'TESTDATA00000001', getdate(),1)

GO

INSERT INTO IW_TABLE_RULE_OUTPUT_FIELD (IW_TABLE_RULE_KEY,IW_OUTPUT_FIELD_KEY,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM0100000007','SYSTEM01000000I0','TESTDATA00000001', getdate(),1)

INSERT INTO IW_TABLE_RULE_OUTPUT_FIELD (IW_TABLE_RULE_KEY,IW_OUTPUT_FIELD_KEY,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000A0','SYSTEM010000000D','TESTDATA00000001', getdate(),1)

INSERT INTO IW_TABLE_RULE_OUTPUT_FIELD (IW_TABLE_RULE_KEY,IW_OUTPUT_FIELD_KEY,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000A0','SYSTEM010000001A','TESTDATA00000001', getdate(),1)
 
INSERT INTO IW_TABLE_RULE_OUTPUT_FIELD (IW_TABLE_RULE_KEY,IW_OUTPUT_FIELD_KEY,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000A0','SYSTEM010000001F','TESTDATA00000001', getdate(),1)

INSERT INTO IW_TABLE_RULE_OUTPUT_FIELD (IW_TABLE_RULE_KEY,IW_OUTPUT_FIELD_KEY,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000A0','SYSTEM0100000024','TESTDATA00000001', getdate(),1)

INSERT INTO IW_TABLE_RULE_OUTPUT_FIELD (IW_TABLE_RULE_KEY,IW_OUTPUT_FIELD_KEY,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000A0','SYSTEM01000000A0','TESTDATA00000001', getdate(),1)

INSERT INTO IW_TABLE_RULE_OUTPUT_FIELD (IW_TABLE_RULE_KEY,IW_OUTPUT_FIELD_KEY,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000A0','SYSTEM01000000B0','TESTDATA00000001', getdate(),1)

INSERT INTO IW_TABLE_RULE_OUTPUT_FIELD (IW_TABLE_RULE_KEY,IW_OUTPUT_FIELD_KEY,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000A0','SYSTEM01000000B1','TESTDATA00000001', getdate(),1)

INSERT INTO IW_TABLE_RULE_OUTPUT_FIELD (IW_TABLE_RULE_KEY,IW_OUTPUT_FIELD_KEY,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000A0','SYSTEM01000000B2','TESTDATA00000001', getdate(),1)

INSERT INTO IW_TABLE_RULE_OUTPUT_FIELD (IW_TABLE_RULE_KEY,IW_OUTPUT_FIELD_KEY,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000A0','SYSTEM01000000C0','TESTDATA00000001', getdate(),1)

INSERT INTO IW_TABLE_RULE_OUTPUT_FIELD (IW_TABLE_RULE_KEY,IW_OUTPUT_FIELD_KEY,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000A0','SYSTEM01000000D0','TESTDATA00000001', getdate(),1)

INSERT INTO IW_TABLE_RULE_OUTPUT_FIELD (IW_TABLE_RULE_KEY,IW_OUTPUT_FIELD_KEY,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000A0','SYSTEM01000000E0','TESTDATA00000001', getdate(),1)

INSERT INTO IW_TABLE_RULE_OUTPUT_FIELD (IW_TABLE_RULE_KEY,IW_OUTPUT_FIELD_KEY,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000A0','SYSTEM01000000F0','TESTDATA00000001', getdate(),1)

INSERT INTO IW_TABLE_RULE_OUTPUT_FIELD (IW_TABLE_RULE_KEY,IW_OUTPUT_FIELD_KEY,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000A0','SYSTEM01000000G0','TESTDATA00000001', getdate(),1)

INSERT INTO IW_TABLE_RULE_OUTPUT_FIELD (IW_TABLE_RULE_KEY,IW_OUTPUT_FIELD_KEY,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000A0','SYSTEM01000000H0','TESTDATA00000001', getdate(),1)

INSERT INTO IW_TABLE_RULE_RELATED_FIELD (IW_TABLE_RULE_KEY,IW_COLUMN_TYPE_KEY,RELATIONSHIP,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000A0','SYSTEM01000000A0',2,'TESTDATA00000001', getdate(),1)

GO

INSERT INTO IW_TABLE_RULE_RELATED_TABLE(IW_TABLE_RULE_KEY,TABLE_NAME,RELATIONSHIP,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('SYSTEM01000000A0','Taxon_Occurrence',1,'TESTDATA00000001', getdate(),1)

GO

INSERT INTO REPORT_JOIN (REPORT_JOIN_KEY,JOIN_SQL,ENTERED_BY,ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES('LCA0002300000501','FROM #REPORT_OUTPUT LEFT JOIN REVIEW_VIEW ON REVIEW_VIEW.TAXON_OCCURRENCE_KEY = #REPORT_OUTPUT.OCCURRENCE_KEY',
'TESTDATA00000001',getdate(),1)


INSERT INTO REPORT_ATTRIBUTE (REPORT_ATTRIBUTE_KEY,ITEM_NAME,ITEM_GROUP,SOURCE_TABLE,ATTRIBUTE_SQL,REPORT_JOIN_KEY,ENTERED_BY,
ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('LCA0002300000500','Review Status','Taxon\Observations\Determination','OBSERVATION','#REPORT_OUTPUT.[Review Status] = [dbo].[ufn_ReturnReviewStatusText]([dbo].[ufn_ReturnReviewStatus](TAXON_OCCURRENCE.TAXON_OCCURRENCE_KEY))',
'NBNSYS0000000016','TESTDATA00000001',getdate(),1)


INSERT INTO REPORT_ATTRIBUTE (REPORT_ATTRIBUTE_KEY,ITEM_NAME,ITEM_GROUP,SOURCE_TABLE,ATTRIBUTE_SQL,REPORT_JOIN_KEY,ENTERED_BY,
ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('LCA0002300000501','Reviewer','Taxon\Observations\Determination','OBSERVATION','#REPORT_OUTPUT.[Reviewer] =  REVIEW_VIEW.Reviewer',
'LCA0002300000501','TESTDATA00000001',getdate(),1)


INSERT INTO REPORT_ATTRIBUTE (REPORT_ATTRIBUTE_KEY,ITEM_NAME,ITEM_GROUP,SOURCE_TABLE,ATTRIBUTE_SQL,REPORT_JOIN_KEY,ENTERED_BY,
ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('LCA0002300000502','Reviewer Role','Taxon\Observations\Determination','OBSERVATION','#REPORT_OUTPUT.[Reviewer Role] =  REVIEW_VIEW.Reviewer_Role',
'LCA0002300000501','TESTDATA00000001',getdate(),1)

INSERT INTO REPORT_ATTRIBUTE (REPORT_ATTRIBUTE_KEY,ITEM_NAME,ITEM_GROUP,SOURCE_TABLE,ATTRIBUTE_SQL,REPORT_JOIN_KEY,ENTERED_BY,
ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('LCA0002300000503','Review Type','Taxon\Observations\Determination','OBSERVATION','#REPORT_OUTPUT.[Review Type] =  REVIEW_VIEW.Review_Type',
'LCA0002300000501','TESTDATA00000001',getdate(),1)

INSERT INTO REPORT_ATTRIBUTE (REPORT_ATTRIBUTE_KEY,ITEM_NAME,ITEM_GROUP,SOURCE_TABLE,ATTRIBUTE_SQL,REPORT_JOIN_KEY,ENTERED_BY,
ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('LCA0002300000504','Review Date','Taxon\Observations\Determination','OBSERVATION','#REPORT_OUTPUT.[Review Date] =  REVIEW_VIEW.Review_Date',
'LCA0002300000501','TESTDATA00000001',getdate(),1)

INSERT INTO REPORT_ATTRIBUTE (REPORT_ATTRIBUTE_KEY,ITEM_NAME,ITEM_GROUP,SOURCE_TABLE,ATTRIBUTE_SQL,REPORT_JOIN_KEY,ENTERED_BY,
ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('LCA0002300000505','Review Comment','Taxon\Observations\Determination','OBSERVATION','#REPORT_OUTPUT.[Review Comment] =  REVIEW_VIEW.Review_Comment',
'LCA0002300000501','TESTDATA00000001',getdate(),1)


INSERT INTO REPORT_ATTRIBUTE (REPORT_ATTRIBUTE_KEY,ITEM_NAME,ITEM_GROUP,SOURCE_TABLE,ATTRIBUTE_SQL,REPORT_JOIN_KEY,ENTERED_BY,
ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('LCA0002300000506','Review Species','Taxon\Observations\Determination','OBSERVATION','#REPORT_OUTPUT.[Review Species] =  REVIEW_VIEW.Review_Species',
'LCA0002300000501','TESTDATA00000001',getdate(),1)

GO

INSERT INTO REPORT_FIELD (REPORT_FIELD_KEY,ENTERED_BY,REPORT_ATTRIBUTE_KEY,FIELD_ITEM_NAME,FIELD_TYPE,FIELD_SIZE,
ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('LCA0002300000500','NBNSYS000000001','LCA0002300000500', 'Review Status','varchar',30,getdate(),1)


INSERT INTO REPORT_FIELD (REPORT_FIELD_KEY,ENTERED_BY,REPORT_ATTRIBUTE_KEY,FIELD_ITEM_NAME,FIELD_TYPE,FIELD_SIZE,
ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('LCA0002300000501','NBNSYS000000001','LCA0002300000501', 'Reviewer','varchar',30,getdate(),1)

INSERT INTO REPORT_FIELD (REPORT_FIELD_KEY,ENTERED_BY,REPORT_ATTRIBUTE_KEY,FIELD_ITEM_NAME,FIELD_TYPE,FIELD_SIZE,
ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('LCA0002300000502','NBNSYS000000001','LCA0002300000502', 'Reviewer Role','varchar',20,getdate(),1)

INSERT INTO REPORT_FIELD (REPORT_FIELD_KEY,ENTERED_BY,REPORT_ATTRIBUTE_KEY,FIELD_ITEM_NAME,FIELD_TYPE,FIELD_SIZE,
ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('LCA0002300000503','NBNSYS000000001','LCA0002300000503', 'Review Type','varchar',20,getdate(),1)

INSERT INTO REPORT_FIELD (REPORT_FIELD_KEY,ENTERED_BY,REPORT_ATTRIBUTE_KEY,FIELD_ITEM_NAME,FIELD_TYPE,FIELD_SIZE,
ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('LCA0002300000504','NBNSYS000000001','LCA0002300000504', 'Review Date','varchar',30,getdate(),1)

INSERT INTO REPORT_FIELD (REPORT_FIELD_KEY,ENTERED_BY,REPORT_ATTRIBUTE_KEY,FIELD_ITEM_NAME,FIELD_TYPE,
ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('LCA0002300000505','NBNSYS000000001','LCA0002300000505', 'Review Comment','text',getdate(),1)

INSERT INTO REPORT_FIELD (REPORT_FIELD_KEY,ENTERED_BY,REPORT_ATTRIBUTE_KEY,FIELD_ITEM_NAME,FIELD_TYPE,FIELD_SIZE,
ENTRY_DATE,SYSTEM_SUPPLIED_DATA)
VALUES ('LCA0002300000506','NBNSYS000000001','LCA0002300000506', 'Review Species','varchar',200,getdate(),1)

GO

INSERT INTO USABLE_TABLE(USABLE_TABLE_KEY,TABLE_NAME,LINK_TABLE,LINK,APPLY_TO,JOIN_ORDER)
VALUES ('LCA0002300000500','REVIEW_STATUS','Taxon_Occurrence','REVIEW_STATUS.Taxon_Occurrence_Key = Taxon_Occurrence.Taxon_Occurrence_Key',
'T',15)

INSERT INTO USABLE_FIELD(USABLE_FIELD_KEY,TABLE_NAME,FIELD_NAME,FIELD_DESCRIPTION,FIELD_TYPE,APPLY_TO,
SELECTABLE,SORTABLE,FILTERABLE,CALCULATION_SQL)
VALUES ('LCA0002300000500','REVIEW_STATUS','Review_Status','Review Status','TEXT','T',0,0,1,
'Review_Status.Review_Status')
 


GO


/****** Object:  View [dbo].[REVIEW_VIEW]    Script Date: 01/28/2017 21:30:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[REVIEW_VIEW]
AS
SELECT     TDET.TAXON_OCCURRENCE_KEY, dbo.ufn_GetIndividualFull(TDET.DETERMINER) AS Reviewer, dbo.LCReturnVagueDateShort(TDET.VAGUE_DATE_START, 
                      TDET.VAGUE_DATE_END, TDET.VAGUE_DATE_TYPE) AS Review_Date, DT.SHORT_NAME AS Review_Type, DR.SHORT_NAME AS Reviewer_Role, 
                      dbo.ufn_RtfToPlaintext(TDET.COMMENT) AS Review_comment, dbo.LCRecNameWithAttribute(TDET.TAXON_LIST_ITEM_KEY, 0) AS Review_Species

FROM         dbo.TAXON_DETERMINATION AS TDET INNER JOIN
                      dbo.DETERMINATION_TYPE AS DT ON DT.DETERMINATION_TYPE_KEY = TDET.DETERMINATION_TYPE_KEY INNER JOIN
                      dbo.DETERMINER_ROLE AS DR ON DR.DETERMINER_ROLE_KEY = TDET.DETERMINER_ROLE_KEY
WHERE     (CAST(TDET.VAGUE_DATE_START AS varchar(10)) + CAST(TDET.VAGUE_DATE_END AS varchar(10)) + TDET.TAXON_DETERMINATION_KEY =
                          (SELECT     MAX(CAST(tdet2.VAGUE_DATE_START AS varchar(10)) + CAST(tdet2.VAGUE_DATE_END AS varchar(10)) + tdet2.TAXON_DETERMINATION_KEY) 
                                                   AS Expr1
                            FROM          dbo.TAXON_DETERMINATION AS tdet2 INNER JOIN
                                                   dbo.DETERMINER_ROLE AS DR2 ON DR2.DETERMINER_ROLE_KEY = tdet2.DETERMINER_ROLE_KEY
                            WHERE      tdet2.Taxon_Occurrence_key = tdet.TAXON_OCCURRENCE_KEY AND (DR2.VALIDATION_COMPETENCY >=
                                                       (SELECT     CAST(DATA AS integer) AS Expr1
                                                         FROM          dbo.SETTING
                                                         WHERE      (NAME = 'Competency')))))
GO

GRANT SELECT ON [dbo].[REVIEW_VIEW] TO PUBLIC

GO

/****** Object:  View [dbo].[REVIEW_STATUS]    Script Date: 01/30/2017 11:07:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[REVIEW_STATUS]
AS
SELECT     TAXON_OCCURRENCE_KEY, dbo.ufn_ReturnReviewStatusText(dbo.ufn_ReturnReviewStatus(TAXON_OCCURRENCE_KEY)) AS Review_Status
FROM         dbo.TAXON_OCCURRENCE

GO

GRANT SELECT ON [dbo].[REVIEW_STATUS] TO PUBLIC

