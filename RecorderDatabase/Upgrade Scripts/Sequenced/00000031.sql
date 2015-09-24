/**************************************************************************/
/* Script to create Report attributes for all designations                */
/**************************************************************************/


/* Create a mapping table so that all new keys created are consistent for */
/* all users, at least for system supplied designations                   */ 

DECLARE @keys TABLE (
	taxon_designation_type_key CHAR(16) PRIMARY KEY,
	report_where_key CHAR(16),
	report_attribute_key CHAR(16),
	report_field_key CHAR(16)
)
 
INSERT INTO @keys VALUES ('EHSSYS0000000001','NBNSYS0000000002','NBNSYS0000000089','NBNSYS0000000097')
INSERT INTO @keys VALUES ('NBNSYS0000000001','NBNSYS0000000003','NBNSYS000000008A','NBNSYS0000000098')
INSERT INTO @keys VALUES ('NBNSYS0000000002','NBNSYS0000000004','NBNSYS000000008B','NBNSYS0000000099')
INSERT INTO @keys VALUES ('NBNSYS0000000003','NBNSYS0000000005','NBNSYS000000008C','NBNSYS000000009A')
INSERT INTO @keys VALUES ('NBNSYS0000000004','NBNSYS0000000006','NBNSYS000000008D','NBNSYS000000009B')
INSERT INTO @keys VALUES ('NBNSYS0000000005','NBNSYS0000000007','NBNSYS000000008E','NBNSYS000000009C')
INSERT INTO @keys VALUES ('NBNSYS0000000006','NBNSYS0000000008','NBNSYS000000008F','NBNSYS000000009D')
INSERT INTO @keys VALUES ('NBNSYS0000000007','NBNSYS0000000009','NBNSYS000000008G','NBNSYS000000009E')
INSERT INTO @keys VALUES ('NBNSYS0000000008','NBNSYS000000000A','NBNSYS000000008H','NBNSYS000000009F')
INSERT INTO @keys VALUES ('NBNSYS0000000009','NBNSYS000000000B','NBNSYS000000008I','NBNSYS000000009G')
INSERT INTO @keys VALUES ('NBNSYS0000000010','NBNSYS000000000C','NBNSYS000000008J','NBNSYS000000009H')
INSERT INTO @keys VALUES ('NBNSYS0000000011','NBNSYS000000000D','NBNSYS000000008K','NBNSYS000000009I')
INSERT INTO @keys VALUES ('NBNSYS0000000012','NBNSYS000000000E','NBNSYS000000008L','NBNSYS000000009J')
INSERT INTO @keys VALUES ('NBNSYS0000000013','NBNSYS000000000F','NBNSYS000000008M','NBNSYS000000009K')
INSERT INTO @keys VALUES ('NBNSYS0000000014','NBNSYS000000000G','NBNSYS000000008N','NBNSYS000000009L')
INSERT INTO @keys VALUES ('NBNSYS0000000015','NBNSYS000000000H','NBNSYS000000008O','NBNSYS000000009M')
INSERT INTO @keys VALUES ('NBNSYS0000000016','NBNSYS000000000I','NBNSYS000000008P','NBNSYS000000009N')
INSERT INTO @keys VALUES ('NBNSYS0000000017','NBNSYS000000000J','NBNSYS000000008Q','NBNSYS000000009O')
INSERT INTO @keys VALUES ('NBNSYS0000000018','NBNSYS000000000K','NBNSYS000000008R','NBNSYS000000009P')
INSERT INTO @keys VALUES ('NBNSYS0000000019','NBNSYS000000000L','NBNSYS000000008S','NBNSYS000000009Q')
INSERT INTO @keys VALUES ('NBNSYS0000000022','NBNSYS000000000M','NBNSYS000000008T','NBNSYS000000009R')
INSERT INTO @keys VALUES ('NBNSYS0000000027','NBNSYS000000000N','NBNSYS000000008U','NBNSYS000000009S')
INSERT INTO @keys VALUES ('NBNSYS0000000028','NBNSYS000000000O','NBNSYS000000008V','NBNSYS000000009T')
INSERT INTO @keys VALUES ('NBNSYS0000000031','NBNSYS000000000P','NBNSYS000000008W','NBNSYS000000009U')
INSERT INTO @keys VALUES ('NBNSYS0000000032','NBNSYS000000000Q','NBNSYS000000008X','NBNSYS000000009V')
INSERT INTO @keys VALUES ('NBNSYS0000000033','NBNSYS000000000R','NBNSYS000000008Y','NBNSYS000000009W')
INSERT INTO @keys VALUES ('NBNSYS0000000034','NBNSYS000000000S','NBNSYS000000008Z','NBNSYS000000009X')
INSERT INTO @keys VALUES ('NBNSYS0000000035','NBNSYS000000000T','NBNSYS0000000090','NBNSYS000000009Y')
INSERT INTO @keys VALUES ('NBNSYS0000000036','NBNSYS000000000U','NBNSYS0000000091','NBNSYS000000009Z')
INSERT INTO @keys VALUES ('NBNSYS0000000037','NBNSYS000000000V','NBNSYS0000000092','NBNSYS00000000A0')
INSERT INTO @keys VALUES ('NBNSYS0000000038','NBNSYS000000000W','NBNSYS0000000093','NBNSYS00000000A1')
INSERT INTO @keys VALUES ('NBNSYS0000000039','NBNSYS000000000X','NBNSYS0000000094','NBNSYS00000000A2')
INSERT INTO @keys VALUES ('NBNSYS0000000040','NBNSYS000000000Y','NBNSYS0000000095','NBNSYS00000000A3')
INSERT INTO @keys VALUES ('NBNSYS0000000041','NBNSYS000000000Z','NBNSYS0000000096','NBNSYS00000000A4')
INSERT INTO @keys VALUES ('NBNSYS0000000042','NBNSYS0000000010','NBNSYS0000000097','NBNSYS00000000A5')
INSERT INTO @keys VALUES ('NBNSYS0000000043','NBNSYS0000000011','NBNSYS0000000098','NBNSYS00000000A6')
INSERT INTO @keys VALUES ('NBNSYS0000000044','NBNSYS0000000012','NBNSYS0000000099','NBNSYS00000000A7')
INSERT INTO @keys VALUES ('NBNSYS0000000045','NBNSYS0000000013','NBNSYS000000009A','NBNSYS00000000A8')
INSERT INTO @keys VALUES ('NBNSYS0000000046','NBNSYS0000000014','NBNSYS000000009B','NBNSYS00000000A9')
INSERT INTO @keys VALUES ('NBNSYS0000000047','NBNSYS0000000015','NBNSYS000000009C','NBNSYS00000000AA')
INSERT INTO @keys VALUES ('NBNSYS0000000051','NBNSYS0000000016','NBNSYS000000009D','NBNSYS00000000AB')
INSERT INTO @keys VALUES ('NBNSYS0000000052','NBNSYS0000000017','NBNSYS000000009E','NBNSYS00000000AC')
INSERT INTO @keys VALUES ('NBNSYS0000000053','NBNSYS0000000018','NBNSYS000000009F','NBNSYS00000000AD')
INSERT INTO @keys VALUES ('NBNSYS0000000054','NBNSYS0000000019','NBNSYS000000009G','NBNSYS00000000AE')
INSERT INTO @keys VALUES ('NBNSYS0000000055','NBNSYS000000001A','NBNSYS000000009H','NBNSYS00000000AF')
INSERT INTO @keys VALUES ('NBNSYS0000000056','NBNSYS000000001B','NBNSYS000000009I','NBNSYS00000000AG')
INSERT INTO @keys VALUES ('NBNSYS0000000057','NBNSYS000000001C','NBNSYS000000009J','NBNSYS00000000AH')
INSERT INTO @keys VALUES ('NBNSYS0000000058','NBNSYS000000001D','NBNSYS000000009K','NBNSYS00000000AI')
INSERT INTO @keys VALUES ('NBNSYS0000000059','NBNSYS000000001E','NBNSYS000000009L','NBNSYS00000000AJ')
INSERT INTO @keys VALUES ('NBNSYS0000000060','NBNSYS000000001F','NBNSYS000000009M','NBNSYS00000000AK')
INSERT INTO @keys VALUES ('NBNSYS0000000061','NBNSYS000000001G','NBNSYS000000009N','NBNSYS00000000AL')
INSERT INTO @keys VALUES ('NBNSYS0000000062','NBNSYS000000001H','NBNSYS000000009O','NBNSYS00000000AM')
INSERT INTO @keys VALUES ('NBNSYS0000000063','NBNSYS000000001I','NBNSYS000000009P','NBNSYS00000000AN')
INSERT INTO @keys VALUES ('NBNSYS0000000064','NBNSYS000000001J','NBNSYS000000009Q','NBNSYS00000000AO')
INSERT INTO @keys VALUES ('NBNSYS0000000065','NBNSYS000000001K','NBNSYS000000009R','NBNSYS00000000AP')
INSERT INTO @keys VALUES ('NBNSYS0000000066','NBNSYS000000001L','NBNSYS000000009S','NBNSYS00000000AQ')
INSERT INTO @keys VALUES ('NBNSYS0000000067','NBNSYS000000001M','NBNSYS000000009T','NBNSYS00000000AR')
INSERT INTO @keys VALUES ('NBNSYS0000000068','NBNSYS000000001N','NBNSYS000000009U','NBNSYS00000000AS')
INSERT INTO @keys VALUES ('NBNSYS0000000075','NBNSYS000000001O','NBNSYS000000009V','NBNSYS00000000AT')
INSERT INTO @keys VALUES ('NBNSYS0000000076','NBNSYS000000001P','NBNSYS000000009W','NBNSYS00000000AU')
INSERT INTO @keys VALUES ('NBNSYS0000000077','NBNSYS000000001Q','NBNSYS000000009X','NBNSYS00000000AV')
INSERT INTO @keys VALUES ('NBNSYS0000000078','NBNSYS000000001R','NBNSYS000000009Y','NBNSYS00000000AW')
INSERT INTO @keys VALUES ('NBNSYS0000000079','NBNSYS000000001S','NBNSYS000000009Z','NBNSYS00000000AX')
INSERT INTO @keys VALUES ('NBNSYS0000000080','NBNSYS000000001T','NBNSYS00000000A0','NBNSYS00000000AY')
INSERT INTO @keys VALUES ('NBNSYS0000000081','NBNSYS000000001U','NBNSYS00000000A1','NBNSYS00000000AZ')
INSERT INTO @keys VALUES ('NBNSYS0000000082','NBNSYS000000001V','NBNSYS00000000A2','NBNSYS00000000B0')
INSERT INTO @keys VALUES ('NBNSYS0000000083','NBNSYS000000001W','NBNSYS00000000A3','NBNSYS00000000B1')
INSERT INTO @keys VALUES ('NBNSYS0000000084','NBNSYS000000001X','NBNSYS00000000A4','NBNSYS00000000B2')
INSERT INTO @keys VALUES ('NBNSYS0000000085','NBNSYS000000001Y','NBNSYS00000000A5','NBNSYS00000000B3')
INSERT INTO @keys VALUES ('NBNSYS0000000086','NBNSYS000000001Z','NBNSYS00000000A6','NBNSYS00000000B4')
INSERT INTO @keys VALUES ('NBNSYS0000000087','NBNSYS0000000020','NBNSYS00000000A7','NBNSYS00000000B5')
INSERT INTO @keys VALUES ('NBNSYS0000000088','NBNSYS0000000021','NBNSYS00000000A8','NBNSYS00000000B6')
INSERT INTO @keys VALUES ('NBNSYS0000000089','NBNSYS0000000022','NBNSYS00000000A9','NBNSYS00000000B7')
INSERT INTO @keys VALUES ('NBNSYS0000000090','NBNSYS0000000023','NBNSYS00000000AA','NBNSYS00000000B8')
INSERT INTO @keys VALUES ('NBNSYS0000000091','NBNSYS0000000024','NBNSYS00000000AB','NBNSYS00000000B9')
INSERT INTO @keys VALUES ('NBNSYS0000000095','NBNSYS0000000025','NBNSYS00000000AC','NBNSYS00000000BA')
INSERT INTO @keys VALUES ('NBNSYS0000000096','NBNSYS0000000026','NBNSYS00000000AD','NBNSYS00000000BB')
INSERT INTO @keys VALUES ('NBNSYS0000000097','NBNSYS0000000027','NBNSYS00000000AE','NBNSYS00000000BC')
INSERT INTO @keys VALUES ('NBNSYS0000000099','NBNSYS0000000028','NBNSYS00000000AF','NBNSYS00000000BD')
INSERT INTO @keys VALUES ('NBNSYS0000000100','NBNSYS0000000029','NBNSYS00000000AG','NBNSYS00000000BE')
INSERT INTO @keys VALUES ('NBNSYS0000000101','NBNSYS000000002A','NBNSYS00000000AH','NBNSYS00000000BF')
INSERT INTO @keys VALUES ('NBNSYS0000000102','NBNSYS000000002B','NBNSYS00000000AI','NBNSYS00000000BG')
INSERT INTO @keys VALUES ('NBNSYS0000000103','NBNSYS000000002C','NBNSYS00000000AJ','NBNSYS00000000BH')
INSERT INTO @keys VALUES ('NBNSYS0000000104','NBNSYS000000002D','NBNSYS00000000AK','NBNSYS00000000BI')
INSERT INTO @keys VALUES ('NBNSYS0000000105','NBNSYS000000002E','NBNSYS00000000AL','NBNSYS00000000BJ')
INSERT INTO @keys VALUES ('NBNSYS0000000107','NBNSYS000000002F','NBNSYS00000000AM','NBNSYS00000000BK')
INSERT INTO @keys VALUES ('NBNSYS0000000112','NBNSYS000000002G','NBNSYS00000000AN','NBNSYS00000000BL')
INSERT INTO @keys VALUES ('NBNSYS0000000118','NBNSYS000000002H','NBNSYS00000000AO','NBNSYS00000000BM')
INSERT INTO @keys VALUES ('NBNSYS0000000119','NBNSYS000000002I','NBNSYS00000000AP','NBNSYS00000000BN')
INSERT INTO @keys VALUES ('NBNSYS0000000120','NBNSYS000000002J','NBNSYS00000000AQ','NBNSYS00000000BO')
INSERT INTO @keys VALUES ('NBNSYS0000000122','NBNSYS000000002K','NBNSYS00000000AR','NBNSYS00000000BP')
INSERT INTO @keys VALUES ('NBNSYS0000000123','NBNSYS000000002L','NBNSYS00000000AS','NBNSYS00000000BQ')
INSERT INTO @keys VALUES ('NBNSYS0000000124','NBNSYS000000002M','NBNSYS00000000AT','NBNSYS00000000BR')
INSERT INTO @keys VALUES ('NBNSYS0000000125','NBNSYS000000002N','NBNSYS00000000AU','NBNSYS00000000BS')
INSERT INTO @keys VALUES ('NBNSYS0000000127','NBNSYS000000002O','NBNSYS00000000AV','NBNSYS00000000BT')
INSERT INTO @keys VALUES ('NBNSYS0000000128','NBNSYS000000002P','NBNSYS00000000AW','NBNSYS00000000BU')
INSERT INTO @keys VALUES ('NBNSYS0000000129','NBNSYS000000002Q','NBNSYS00000000AX','NBNSYS00000000BV')
INSERT INTO @keys VALUES ('NBNSYS0000000130','NBNSYS000000002R','NBNSYS00000000AY','NBNSYS00000000BW')
INSERT INTO @keys VALUES ('NBNSYS0000000132','NBNSYS000000002S','NBNSYS00000000AZ','NBNSYS00000000BX')
INSERT INTO @keys VALUES ('NBNSYS0100000001','NBNSYS000000002T','NBNSYS00000000B0','NBNSYS00000000BY')
INSERT INTO @keys VALUES ('NBNSYS0100000003','NBNSYS000000002U','NBNSYS00000000B1','NBNSYS00000000BZ')
INSERT INTO @keys VALUES ('NBNSYS0100000004','NBNSYS000000002V','NBNSYS00000000B2','NBNSYS00000000C0')
INSERT INTO @keys VALUES ('NBNSYS0100000005','NBNSYS000000002W','NBNSYS00000000B3','NBNSYS00000000C1')
INSERT INTO @keys VALUES ('NBNSYS0100000006','NBNSYS000000002X','NBNSYS00000000B4','NBNSYS00000000C2')
INSERT INTO @keys VALUES ('NBNSYS0100000007','NBNSYS000000002Y','NBNSYS00000000B5','NBNSYS00000000C3')
INSERT INTO @keys VALUES ('NBNSYS0100000008','NBNSYS000000002Z','NBNSYS00000000B6','NBNSYS00000000C4')
INSERT INTO @keys VALUES ('NBNSYS0100000009','NBNSYS0000000030','NBNSYS00000000B7','NBNSYS00000000C5')
INSERT INTO @keys VALUES ('NBNSYS0100000010','NBNSYS0000000031','NBNSYS00000000B8','NBNSYS00000000C6')
INSERT INTO @keys VALUES ('NBNSYS0100000011','NBNSYS0000000032','NBNSYS00000000B9','NBNSYS00000000C7')

DELETE FROM @Keys WHERE taxon_designation_type_key like 'NBNSYS00000001%'

INSERT INTO Report_Join (Report_Join_Key, Join_SQL, System_Supplied_Data)
VALUES ('NBNSYS000000003A', 'FROM #Report_Output
LEFT JOIN Index_Taxon_Name ITN 
    ON (ITN.Taxon_List_Item_Key = #Report_Output.LIST_ITEM_KEY 
    AND ITN.System_Supplied_Data=1
    AND #REPORT_OUTPUT.Type=''T'')
LEFT JOIN Index_Taxon_Name ITN2 ON ITN.Recommended_Taxon_List_Item_Key=ITN2.Recommended_Taxon_List_Item_Key
LEFT JOIN Taxon_Designation TD ON TD.Taxon_List_Item_Key=ITN2.Taxon_List_Item_Key', 1)

DECLARE @Key CHAR(16),
	@ItemName VARCHAR(40),
	@WhereKey CHAR(16),
	@AttrKey CHAR(16),
	@FieldKey CHAR(16)

DECLARE csr CURSOR FOR 
	SELECT Taxon_Designation_Type_Key, Short_Name 
	FROM Taxon_Designation_Type

OPEN csr

WHILE (1=1)
BEGIN
  FETCH NEXT FROM csr INTO @Key, @ItemName
  
  IF @@FETCH_STATUS<>0
	BREAK

  -- if system supplied, look up keys, else generate new ones
  IF EXISTS(SELECT 1 FROM @keys WHERE taxon_designation_type_key=@key)
    SELECT @WhereKey=report_where_key, @AttrKey=report_attribute_key, @fieldkey=report_field_key
    FROM @keys WHERE taxon_designation_type_key=@key
  ELSE BEGIN
    EXEC spNextKey 'Report_Where', @WhereKey OUTPUT
    EXEC spNextKey 'Report_Attribute', @AttrKey OUTPUT
    EXEC spNextKey 'Report_Field', @FieldKey OUTPUT
  END

  INSERT INTO Report_Where (Report_Where_Key, Where_SQL, System_Supplied_Data)
  VALUES (@WhereKey, 'TD.Taxon_Designation_Type_Key=''' + @Key + '''', 1)

  INSERT INTO Report_Attribute (Report_Attribute_Key, Item_Group, Source_Table, Item_Name, Attribute_SQL, Report_Join_Key, Report_Where_Key, System_Supplied_Data)
  VALUES (@AttrKey, 'Taxon\Statuses', 'TAXON', @ItemName, 
	'#REPORT_OUTPUT.[' + @ItemName + '] = ''Yes''',
	'NBNSYS000000003A', @WhereKey, 1)

  INSERT INTO Report_Field (Report_Field_Key, Report_Attribute_Key, Field_Item_Name, Field_Type, Field_Size, System_Supplied_Data)
  VALUES (@FieldKey, @AttrKey, @ItemName, 'text', 3, 1)

END

CLOSE csr

DEALLOCATE csr

DELETE FROM Last_Key WHERE Table_Name IN ('Report_Attribute', 'Report_Field', 'Report_Where')
