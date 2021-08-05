/******* Changes associated with allowing users to not allocate selected names when matching ******/

/****** Object:  UserDefinedFunction [dbo].[ConsolidateRecorder]    Script Date: 02/08/2021 12:44:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER FUNCTION [dbo].[ConsolidateRecorder]
(@SampleKey char(16) )

RETURNS varchar(8000)

/*===========================================================================*\
  Description:	Returns Recorder Names including those held unparsed 

  Parameters:
  @SampleKey - Sample key 
 
  Doesn't return the 'Withheld' or 'Unknown' unless they are the only name held 
 		  
  Created:	January 2013
  Author: MikeWeideli 
\*=========================================================================== */

AS
BEGIN

--****************************************************************************************************
DECLARE @ReturnString varchar(8000)
DECLARE @ItemString varchar(70)
DECLARE @Title char(10)
DECLARE @Initials varchar(8)
DECLARE @Forename varchar(35)
DECLARE @Surname varchar(35)
DECLARE @TempKey varchar(16)
DECLARE @DeletedKey varchar(16)

SET @TempKey = (SELECT [DATA] FROM SETTING WHERE [NAME] = 'TEMPNAME')

SET @DeletedKey = (SELECT [DATA] FROM SETTING WHERE [NAME] = 'UNKNOWNOBS')

 
DECLARE csrEventRecorder CURSOR
FOR
SELECT DISTINCT INDIVIDUAL.TITLE, INDIVIDUAL.INITIALS, INDIVIDUAL.FORENAME, INDIVIDUAL.SURNAME
FROM
(SAMPLE_RECORDER
LEFT JOIN
	(SURVEY_EVENT_RECORDER
	LEFT JOIN
		INDIVIDUAL
	ON SURVEY_EVENT_RECORDER.NAME_KEY = INDIVIDUAL.NAME_KEY)
ON SAMPLE_RECORDER.SE_RECORDER_KEY = SURVEY_EVENT_RECORDER.SE_RECORDER_KEY)
WHERE SAMPLE_RECORDER.SAMPLE_KEY = @SampleKey
AND SURVEY_EVENT_RECORDER.NAME_KEY <> @TEMPKEY AND SURVEY_EVENT_RECORDER.NAME_KEY 
<> @DeletedKey 

OPEN csrEventRecorder

FETCH NEXT FROM csrEventRecorder INTO @Title, @Initials, @Forename, @Surname
IF @@FETCH_STATUS = 0 SELECT @ReturnString = dbo.FormatIndividual(@Title, @Initials, @Forename, @Surname)

WHILE @@FETCH_STATUS = 0
BEGIN
	FETCH NEXT FROM csrEventRecorder INTO @Title, @Initials, @Forename, @Surname
	SELECT @ItemString = dbo.FormatIndividual(@Title, @Initials, @Forename, @Surname)
	IF @@FETCH_STATUS = 0 SELECT @ReturnString = @ReturnString + ',' + @ItemString
END

CLOSE csrEventRecorder
DEALLOCATE csrEventRecorder

SET @ReturnString = ISNULL(@ReturnString + ',','') + (SELECT RECORDERS FROM SAMPLE WHERE 
SAMPLE_KEY = @SampleKey)

If @ReturnString IS NULL 
  SET  @ReturnString = (SELECT DISTINCT INDIVIDUAL.SURNAME
    FROM
    INDIVIDUAL
	WHERE INDIVIDUAL.NAME_KEY = @TEMPKEY)

If @ReturnString IS NULL 
   SET  @ReturnString = (SELECT DISTINCT INDIVIDUAL.SURNAME
    FROM
    INDIVIDUAL
	WHERE INDIVIDUAL.NAME_KEY = @DELETEDKEY)


RETURN @ReturnString

END

GO

/****** Object:  StoredProcedure [dbo].[usp_IWExcludeUnmatched_Names]    Script Date: 02/08/2021 12:50:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*===========================================================================*\
  Description:  Changes matching on any unmatched items to unknown as identified in setting

  Created:  Feb 2021 
  
\*===========================================================================*/
CREATE PROCEDURE [dbo].[usp_IWExcludeUnmatched_Names]
   
AS
   
   Update #Names set Notes = 'Unallocated',
   Match_Key = (SELECT [DATA] FROM SETTING 
   WHERE [NAME] = 'UnknownObs'),
   Match_Value = 'Unallocated'
   WHERE match_key is null

GRANT EXECUTE ON [dbo].[usp_IWExcludeUnmatched_Names] TO PUBLIC

GO

/****** Object:  StoredProcedure [dbo].[usp_SaveUnallocatedNames]    Script Date: 02/08/2021 12:51:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*===========================================================================*\
  Description:  Saves Names which have not been matched and indentifies the first determiner
  ignoring Determiner 'Unknown' unless there is no choice.    
  Created:  Feb 2021 
  
\*===========================================================================*/
CREATE PROCEDURE [dbo].[usp_SaveUnallocatedNames]
 
AS
  DECLARE @ImportValue varchar(100),
  @RecordNo integer,
  @Notes varchar(50)
  IF Object_Id('tempdb..#CT_SYSTEM0100000004') IS NOT NULL BEGIN
  
    TRUNCATE TABLE #CS_00000004A
   
    INSERT INTO #CS_00000004A(Record_No) SELECT DISTINCT 
    Record_No FROM #CT_SYSTEM0100000004 
  
    DECLARE csrNames CURSOR
      FOR
      SELECT DISTINCT Record_No,Name,Notes FROM #CT_SYSTEM0100000004 INNER 
      JOIN #NAMES ON #NAMES.Import_Value = #CT_SYSTEM0100000004.Name
     
       
      OPEN csrNames
            
      FETCH NEXT FROM csrNames  INTO @RecordNo,@ImportValue,@Notes
      
        
      WHILE @@FETCH_STATUS = 0
      BEGIN
	 
        if @notes = 'Unallocated' 
        UPDATE #CS_00000004A SET Observers = isnull(Observers + ',','') + @ImportValue
        WHERE Record_No = @RecordNo 
      
        UPDATE #CS_00000004A SET DETERMINER_KEY = n.MATCH_KEY
             FROM 
             #CS_00000004A as d INNER JOIN             
             #CT_SYSTEM0100000004  AS o ON o.Record_No
             = d.Record_No
             INNER JOIN #Names AS n
             ON n.Import_Value = o.name
             WHERE o.Record_No = @RecordNo AND o.Position=0
             AND N.Match_Key <> (SELECT [DATA[ FROM SETTING 
             WHERE [NAME] ='UnknownObs')
        FETCH NEXT FROM csrNames  INTO @RecordNo,@ImportValue,@Notes
	  END
     CLOSE csrNames
     DEALLOCATE csrNames
   
     UPDATE #CS_00000004A SET DETERMINER_KEY = (SELECT [DATA] FROM SETTING 
             WHERE [NAME] ='UnknownObs') WHERE DETERMINER_KEY IS NULL
    
END   


GRANT EXECUTE ON [dbo].[usp_SaveUnallocatedNames] TO PUBLIC


GO

/****** Object:  StoredProcedure [dbo].[usp_IWMatchRecord_Names]    Script Date: 02/09/2021 19:16:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*===========================================================================*\
  Description:	Populate remembered matches table for future imports.

  Parameters:	<none>

  
  Last revision information Feb 2021:

\*===========================================================================*/
ALTER PROCEDURE [dbo].[usp_IWMatchRecord_Names]
AS
	
    DECLARE @Legacy bit
	Set @Legacy = 0 
    
    
    If NOT EXISTS (SELECT * FROM SETTING WHERE [NAME] = 
     'MatchName' AND [DATA] = 'High') SET @Legacy = 1
    
    -- Update existing items, if they were "rematched"

    DELETE FROM IW_Matched_Names
    FROM  #Names
    INNER JOIN IW_Matched_Names 
    ON IW_Matched_Names.Matched_Value
    =  #Names.Import_Value
    WHERE IW_Matched_Names.Matched_Key <> #NAMES.Match_Key
	
   -- Don't want to retain any matches to UnknownObserver

   DELETE FROM IW_Matched_Names
   WHERE IW_Matched_Names.Matched_Key =
   (SELECT [DATA] FROM SETTING WHERE [NAME] = 'Unknownobs')

  
   If @Legacy = 0 
	-- Add the new ones now.
	-- But only if they are reasonable
	INSERT INTO IW_Matched_Names
	SELECT	DISTINCT Import_Value, Match_Key
	FROM	#Names
	INNER JOIN  INDIVIDUAL I ON I.NAME_KEY = #NAMES.Match_Key
	AND Match_Key IS NOT NULL
	AND		Manual_Match = 1
	AND CHARINDEX(I.Surname,Import_Value) > 0
	AND (I.FORENAME  IS NOT NULL OR I.INITIALS IS NOT NULL) 
        AND NOT EXISTS (SELECT * FROM IW_Matched_Names 
        WHERE Matched_Value = #NAMES.Import_Value)  
    
   Else
    INSERT INTO 	IW_Matched_Names
	SELECT		DISTINCT Import_Value, Match_Key
	FROM		#Names
	WHERE		Manual_Match = 1
	         	AND NOT EXISTS (SELECT * FROM IW_Matched_Names 
                WHERE Matched_Value = #NAMES.Import_Value)

GO                

IF NOT EXISTS (SELECT * FROM SETTING WHERE Name = 'UnknownObs')
  INSERT INTO SETTING (Name,[Data],Data_Default) Values('UnknownObs','NBNSYS0000000004','NBNSYS0000000004')

GO

IF NOT EXISTS (SELECT * FROM SETTING WHERE Name = 'MatchName')
  INSERT INTO SETTING (Name,[Data],Data_Default) Values('MatchName','High','High')

GO

/****** Object:  StoredProcedure [dbo].[usp_IW_Names_Multi_Update]    Script Date: 02/08/2021 13:18:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*===========================================================================*\
  Description:		Updates the #Species table following 
  selction from the notes column 
  Parameters @ImportValue 
			 @MatchCount
			 @MatchKey
             @ManualMatch
             @Remembered
            

  Created:	November 2018 
  Modified: February 2021

\*===========================================================================*/
ALTER PROCEDURE [dbo].[usp_IW_Names_Multi_Update] 
@ImportValue VARCHAR(100),
@MatchCount INT,
@MatchKey CHAR(16),
@ManualMatch BIT,
@Remembered BIT

AS
  UPDATE #NAMES 
  SET Match_Count = @MatchCount,
  Match_Key = @MatchKey,
  Manual_Match = @ManualMatch,
  Remembered = @Remembered,
  Match_Value =  dbo.ufn_GetFormattedName(@MatchKey)
  FROM INDIVIDUAL  I 
  WHERE
  #NAMES.Import_Value = @ImportValue
  AND @MatchKey <>''
  
  If @MatchKey = (SELECT [DATA] FROM SETTING WHERE [NAME] = 'UnknownObs')
    UPDATE #NAMES SET Notes = 'Unallocated'
    WHERE 
    #NAMES.Import_Value = @ImportValue
    
  
  DELETE FROM IW_Matched_Names WHERE Matched_Value =
  @ImportValue and Matched_Key <> @MatchKey  
  
  
GO

/****** Object:  StoredProcedure [dbo].[usp_IWNotes_Names_Select]    Script Date: 02/08/2021 14:08:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*===========================================================================*\
  Description:		Returns details matches where  one or more 
      possible matches is acceptable 

  Parameters: @Key = Import_Value

  Created:	November 2018 
  Changed Feb 2019 to allow for a check on key as well as name 
  Feb 2020 to include unallocated
\*===========================================================================*/
ALTER PROCEDURE [dbo].[usp_IWNotes_Names_Select]
@Key varchar(75)
AS
   
  SELECT I.NAME_KEY AS AKey,[dbo].[FormatIndividualFull](I.Title,I.Initials,I.ForeName,I.Surname)
  AS FullDetails, ISNULL(#NAMES.Match_Key,'') As MatchKey, 1 AS POSSIBLE, I.Surname,I.Forename,I.Initials,I.Title
  FROM INDIVIDUAL I 
  INNER JOIN  #NAMES ON #NAMES.Import_Value = @Key 
  WHERE  (dbo.ufn_CompareNames(#Names.Title,#Names.Forename,#Names.Initials,
  #Names.Surname,I.TITLE,I.ForeName,I.INITIALS,I.Surname) > 7 )
  OR #NAMES.MATCH_KEY = I.NAME_KEY
  UNION SELECT
  I.NAME_KEY AS AKey, '---- ' + [dbo].[FormatIndividualFull](I.Title,I.Initials,I.ForeName,I.Surname)
  AS FullDetails, ISNULL(#NAMES.Match_Key,'') As MatchKey, 0 AS POSSIBLE,    I.Surname AS ASurname,I.Forename,I.Initials,I.Title 
  FROM INDIVIDUAL I 
  INNER JOIN  #NAMES ON #NAMES.Import_Value = @Key 
  WHERE #NAMES.SURNAME = I.SURNAME  
  UNION SELECT
  (SELECT [DATA] FROM SETTING WHERE [NAME] = 'UnknownObs') AS   AKey,
   '---- Unallocated'  AS FullDetails,
   '' As MatchKey, 20 AS POSSIBLE, '','','',''  
   ORDER BY POSSIBLE DESC,I.Forename,I.Initials,I.Title

GO

/****** Object:  StoredProcedure [dbo].[usp_IWMatch_Names]    Script Date: 02/09/2021 13:15:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*===========================================================================*\
  Description:	Populate import table with matched values for unique matched only.

  Parameters:	<none>

  Created:	June 2004

  Last revision information:
  Mike Weideli
  Only matches where there is a good match    
  The previous method could result in spurious matches  
  Feb 2021 - Allow legacy matching 
\*===========================================================================*/
ALTER PROCEDURE [dbo].[usp_IWMatch_Names]
AS
  DECLARE @Legacy bit  
  UPDATE #Names set Title  = dbo.ufn_IWParseImportValue(Import_Value,1)
  UPDATE #Names set Forename  = dbo.ufn_IWParseImportValue(Import_Value,2)
  UPDATE #Names set Initials  = dbo.ufn_IWParseImportValue(Import_Value,3)
  UPDATE #Names set Surname  = dbo.ufn_IWParseImportValue(Import_Value,4)
  
  Set @Legacy = 0 
  If NOT EXISTS (SELECT * FROM SETTING WHERE [NAME] = 
    'MatchName' AND [DATA] = 'High') SET @Legacy = 1
  
  If @Legacy = 0  
  BEGIN
   -- set the match count where enough similarities 
   UPDATE	#Names
   SET	Match_Count = 
		  (SELECT	 Count(*)
		  FROM INDIVIDUAL I 
		  WHERE  
		  dbo.ufn_CompareNames(#Names.Title,#Names.Forename,#Names.Initials,
		  #Names.Surname,I.TITLE,I.ForeName,I.INITIALS,I.Surname) > 7)
		  WHERE Match_Key IS NULL
	
    
    UPDATE #Names
    SET Match_Value = [dbo].[ufn_GetFormattedName](Name_Key),
    Match_Key = Name_Key
    FROM INDIVIDUAL I WHERE
    dbo.ufn_CompareNames(#Names.Title,#Names.Forename,#Names.Initials,
	#Names.Surname,I.TITLE,I.ForeName,I.INITIALS,I.Surname) > 10
	AND Match_Key IS NULL AND Match_Count = 1

 END ELSE
 BEGIN
 -- 'Use legacy match 
	UPDATE	#Names
	SET	Match_Count =  (SELECT Count(*) FROM Individual I
				WHERE	Import_Value = I.Forename + ' ' + I.Surname
				OR	Import_Value = I.Surname + ', ' + I.Forename
				OR	Import_Value = I.Surname + ' ' + I.Forename
				OR	Import_Value = I.Initials + ' ' + I.Surname
				OR	Import_Value = I.Initials + I.Surname
				OR	Import_Value = I.Surname + ', ' + I.Initials
				OR	Import_Value = I.Surname + ' ' + I.Initials
				OR	Import_Value = I.Surname
				)
	 WHERE	Match_Key IS NULL

	-- Now get values and keys for unique matches only.
	UPDATE	#Names
	SET	Match_Key = Name_Key,
		Match_Value = dbo.ufn_GetFormattedName(Name_Key)
	FROM	Individual I
	WHERE	Match_Count = 1
	AND 	Match_Key IS NULL
	AND 	(Import_Value = I.Forename + ' ' + I.Surname
	OR	 Import_Value = I.Surname + ', ' + I.Forename
	OR	 Import_Value = I.Surname + ' ' + I.Forename
	OR	 Import_Value = I.Initials + ' ' + I.Surname
	OR	 Import_Value =I.Initials + I.Surname
	OR	 Import_Value = I.Surname + ', ' + I.Initials
	OR	 Import_Value = I.Surname + ' ' +  I.Initials
	OR	 Import_Value = I.Surname)
 
 
 END
 
 
   
 Exec [dbo].[usp_IWMatch_Names_Notes]

GO

/****** Object:  StoredProcedure [dbo].[usp_IWMatchRemembered_Names]    Script Date: 02/11/2021 19:23:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*===========================================================================*\
  Description:	Populate import table with matched values from previous imports.

  Parameters:	<none>

  Created:	July 2004

  Last revision information:
  Feb 2021 - Not to use remembered mtaches when check matching is set to HIGH  

\*===========================================================================*/
ALTER PROCEDURE [dbo].[usp_IWMatchRemembered_Names]
AS
	DECLARE @Legacy bit
	Set @Legacy = 0 
	If NOT EXISTS (SELECT * FROM SETTING WHERE [NAME] = 
     'MatchName' AND [DATA] = 'High') SET @Legacy = 1
	
	IF @Legacy = 1 
	BEGIN
	-- Update temp table with relevant data.
	UPDATE 	#Names
	SET 	Match_Count = 1, 
		Match_Key = Matched_Key, 
		Match_Value = dbo.ufn_GetFormattedName(Matched_Key), 
		Remembered = 1
	FROM 	IW_Matched_Names 
	JOIN	[Name] ON Name_Key = Matched_Key
	WHERE 	Import_Value = Matched_Value 
	AND 	Match_Key IS NULL AND NAME_KEY <> Import_Value     
	
	
	UPDATE 	#Names
	SET 	Match_Count = 1, 
		Match_Key = I.Name_key,
		Match_Value =  I.NAME_KEY,
		Remembered = 1
	FROM 	Individual I 
	JOIN  #Names On I.Name_Key = #names.import_value 
  	WHERE 	Match_Key IS NULL      

    EXEC [dbo].[usp_IWMatch_Names_Notes]
    
    END
