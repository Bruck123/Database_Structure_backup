$Filepath='C:\ITM\Database structure backup' # local directory to save build-scripts to
$DataSource='localhost' # server name and instance
$Databases=@('MSHP_STG','MSHP_DWH','MSHP_JPK') # the database to copy from
$Date = Get-Date -format "yyyyMMdd"
# set "Option Explicit" to catch subtle errors
set-psdebug -strict
$ErrorActionPreference = "stop" # you can opt to stagger on, bleeding, if an error occurs
# Load SMO assembly, and if we're running SQL 2008 DLLs load the SMOExtended and SQLWMIManagement libraries
$ms='Microsoft.SqlServer'
$v = [System.Reflection.Assembly]::LoadWithPartialName( "$ms.SMO")
if ((($v.FullName.Split(','))[1].Split('='))[1].Split('.')[0] -ne '9') {
[System.Reflection.Assembly]::LoadWithPartialName("$ms.SMOExtended") | out-null
   }
$My="$ms.Management.Smo" #
$s = new-object ("$My.Server") $DataSource
if ($s.Version -eq  $null ){Throw "Can't find the instance $Datasource"}
$Filepath=$Filepath+'\'+$Date #redirect to specified daily directory
New-Item -ItemType directory -Force -Path $Filepath
Foreach ($Database in $Databases){
$db= $s.Databases[$Database] 
if ($db.name -ne $Database){Throw "Can't find the database '$Database' in $Datasource"};
$transfer = new-object ("$My.Transfer") $db
$transfer.Options.ScriptBatchTerminator = $true # this only goes to the file
$transfer.Options.ToFileOnly = $true # this only goes to the file
$transfer.Options.Filename = "$($FilePath)\$($Database)_$Date.sql"; 
$transfer.ScriptTransfer()
}