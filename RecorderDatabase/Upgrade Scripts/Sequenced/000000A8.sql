Delete FROM Usable_table WHERE Usable_table_key = 'ABABABAB00000117'
Insert INTO Usable_Table (Usable_table_Key,Table_Name,Link_Table,Link,Apply_To,Join_Order)
Values('ABABABAB00000117', 'Survey_Status','Survey','Survey_Status.Survey_Status_Key = Survey.Survey_Status_Key',
'A',4)