/******* Correct an error in the storred procedure. Missing Go  ******/
/****** Object:  StoredProcedure [dbo].[usp_SaveUnallocatedNames]    Script Date: 08/05/2021 15:40:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*===========================================================================*\
  Description:  Saves Names which have not been matched and indentifies the first determiner
  ignoring Determiner 'Unknown' unless there is no choice.    
  Created:  Feb 2021 
  
\*===========================================================================*/
ALTER PROCEDURE [dbo].[usp_SaveUnallocatedNames]
 
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

GO

GRANT EXECUTE ON [dbo].[usp_SaveUnallocatedNames] TO PUBLIC