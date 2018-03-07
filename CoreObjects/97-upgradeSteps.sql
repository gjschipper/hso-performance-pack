-- !!!!!!!!!! MODIFY @AXDB TO THE RIGHT DATABASE NAME !!!!!!!!!!
USE DBAtools

DECLARE @AXDB nvarchar(max)
SET @AXDB = 'AX_DATABASE' 

SELECT 'Creating SQL Jobs for AX database: ' + name AS ACTIVITY
FROM master.dbo.sysdatabases
where name = @AXDB

IF @@ROWCOUNT < 1
BEGIN
  RAISERROR ('Modify @AXDB to the right database name!', 16, 1)
  return
END
ELSE
BEGIN

DECLARE @JobName nvarchar(max)
DECLARE @StepName1 nvarchar(max)
DECLARE @StepName2 nvarchar(max)
DECLARE @NL AS CHAR(2) = CHAR(13) + CHAR(10)

-- DELETE STEP IN JOB 'HSO - Export AOS Registry'
SET		@JobName = 'HSO - Export AOS Registry'
EXEC msdb.dbo.sp_delete_jobstep @job_name=@JobName, @step_id=1

-- CREATE NEW STEP IN JOB 'HSO - Export AOS Registry'
DECLARE @mycommand nvarchar(max)
set @mycommand = 'strSQLInstance = "' + @@SERVERNAME + '"
strAXDataBase = "' + @AXDB + '"

Const HKLM          = &H80000002
Const adInteger     = 3
Const adVarWChar    = 202
Const adlongVarWChar= 203
Const adParamInput  = &H0001
Const adCmdText     = &H0001
const REG_SZ        = 1
const REG_EXPAND_SZ = 2
const REG_BINARY    = 3
const REG_DWORD     = 4
const REG_MULTI_SZ  = 7

Dim objConnection
Dim objRecordset
Dim objCommandReg

Dim prmReg1
Dim prmReg2
Dim prmReg3
Dim prmReg4
Dim prmReg5
Dim prmReg6
Dim prmReg7
Dim prmReg8

Dim strAOS
Dim strRecordset'

set @mycommand += '
strRecordset = "SELECT SUBSTRING(SERVERID,(CHARINDEX(''@'',SERVERID)+1), (LEN(SERVERID)-CHARINDEX(''@'',SERVERID)))FROM SYSSERVERCONFIG"
Set objConnection=CreateObject("ADODB.Connection") 
Set objRecordset=CreateObject("ADODB.Recordset")
set objCommandReg=CreateObject("ADODB.command")
objConnection.Provider="SQLOLEDB"
objConnection.Properties("Data Source").Value = strSQLInstance
objConnection.Properties("Initial Catalog").Value = strAXDatabase
objConnection.Properties("Integrated Security").Value = "SSPI"
objConnection.Open
objCommandReg.ActiveConnection=objConnection
objCommandReg.CommandType=adCmdText
objCommandReg.CommandText="INSERT INTO DBAtools..AOS_REGISTRY VALUES (?,?,?,?,?,?,?,?)"
Set prmReg1=objCommandReg.CreateParameter ("", adVarWChar,adParamInput,255)
Set prmReg2=objCommandReg.CreateParameter ("", adVarWChar,adParamInput,5)
Set prmReg3=objCommandReg.CreateParameter ("", adVarWChar,adParamInput,255)
Set prmReg4=objCommandReg.CreateParameter ("", adVarWChar,adParamInput,25)
Set prmReg5=objCommandReg.CreateParameter ("", adVarWChar,adParamInput,255)
Set prmReg6=objCommandReg.CreateParameter ("", adVarWChar,adParamInput,1)
Set prmReg7=objCommandReg.CreateParameter ("", adVarWChar,adParamInput,255)
Set prmReg8=objCommandReg.CreateParameter ("", adVarWChar,adParamInput,8000)
objCommandReg.Parameters.Append prmReg1
objCommandReg.Parameters.Append prmReg2
objCommandReg.Parameters.Append prmReg3
objCommandReg.Parameters.Append prmReg4
objCommandReg.Parameters.Append prmReg5
objCommandReg.Parameters.Append prmReg6
objCommandReg.Parameters.Append prmReg7
objCommandReg.Parameters.Append prmReg8
objConnection.Execute "SET DATEFORMAT MDY"
objConnection.Execute "DELETE FROM DBAtools..AOS_REGISTRY WHERE AOS_INSTANCE_NAME = ''" & strAXDataBase & "''"
objRecordset.Open strRecordset, objConnection'

set @mycommand += '
Do While Not objRecordset.EOF
	strAOS =  objRecordset.Fields(0) 
	On Error Resume Next
	Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strAOS & "\root\cimv2")
	if Err.Number <> 0 then
		set objWMIService = nothing
		err.clear
	Else
		Set objWMIService = Nothing
		AOSreg(strAOS)
	end IF
	on error goto 0
	objRecordset.MoveNext 
Loop

Set objConnection=nothing
Set objRecordset=nothing
Set objCommandReg=nothing

Sub AOSreg(strAOS)
 Const HKLM = &H80000002
 Set ObjReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & StrAOS & "\root\default:StdRegProv")
 StrKeyPath = "System\CurrentControlSet\Services\Dynamics Server"
 ObjReg.EnumKey HKLM, StrKeyPath, ArrVersions
 For Each StrVersion In ArrVersions
  ObjReg.EnumKey HKLM, StrKeyPath & "\" & StrVersion, ArrInstances
   If IsArray(ArrInstances) Then
    For Each StrInstance In ArrInstances 
     objReg.GetStringValue HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance, "InstanceName", strInstanceName 
     objReg.GetStringValue HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance, "Current", strCurrentConfig 
     objReg.GetStringValue HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance, "ProductVersion", strProductVersion 
     ObjReg.EnumKey HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance, ArrConfigs
    For Each StrConfig In ArrConfigs
     If StrConfig = StrCurrentConfig Then
      strActive = "Y"
     Else
      strActive = "N"
     End if
ObjReg.EnumValues HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance & "\" & StrConfig, ArrValueNames,  ArrValueTypes
For I=0 To UBound(arrValueNames) 
StrValueName = arrValueNames(I)           
Select Case arrValueTypes(I)
Case REG_SZ
 objReg.GetStringValue HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance & "\" & StrConfig, strValueName, strValue
Case REG_EXPAND_SZ
 objReg.GetExpandedStringValue HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance & "\" & StrConfig, strValueName, strValue
Case REG_BINARY
 objReg.GetBinaryValue  HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance & "\" & StrConfig, strValueName, strValue
Case REG_DWORD
 objReg.GetDWORDValue HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance & "\" & StrConfig, strValueName, strValue
Case REG_MULTI_SZ
 objReg.GetMultiStringValue  HKLM, StrKeyPath & "\" & StrVersion & "\" & StrInstance & "\" & StrConfig, strValueName, strValue
End Select        
 prmReg1.value=StrAOS
 prmReg2.value=StrVersion
 prmReg3.value=strInstanceName
 prmReg4.value=StrProductVersion
 prmReg5.value=StrConfig
 prmReg6.value=strActive
 prmReg7.value=StrValueName
 prmReg8.value=StrValue
 objCommandReg.Execute
 Next
Next
Next
End If
Next
End Sub'

EXEC	msdb.dbo.sp_add_jobstep @job_name=@JobName, @step_name = @JobName, @step_id=1, @on_success_action=1, @database_name=N'VBScript', @subsystem=N'ActiveScripting', 
		@command=@mycommand
END