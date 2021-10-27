# Examples

Default situation is:

- Get Data from SQL into a CSV file
- Email file

This file contains variations on this for additional situations.

# Variations on Input

## Pulling data from a xlsx file

For consistency with managing the files, we use sql files and oledb to pull the data.

```ps1

## Helper Functions
function Read-OleDbData([string]$ConnectionString,[string]$SqlStatement){
    $DataTable = new-object System.Data.DataTable
    $DataAdapter = new-object System.Data.OleDb.OleDbDataAdapter $SqlStatement,$ConnectionString
    $null = $DataAdapter.Fill($DataTable)
    $null = $DataAdapter.Dispose()
    $DataTable.Rows | Select-Object $DataTable.Columns.ColumnName
}
function New-LocalCopy([String]$Source,[PSCredential]$Credential){
    $tempdrive = [Guid]::NewGuid().Guid
    $newdriveargs = @{
        Name = $tempdrive
        PSProvider = "FileSystem"
        Root = split-path $Source
        Credential = $Credential
    }
    New-PSDrive @newdriveargs
    Copy-Item $Source
    Remove-PSDrive $tempdrive
}

#copy the file locally
$sp = ConvertTo-SecureString $cs.pass -AsPlainText -Force
$c = New-Object PSCredential $cs.user, $sp
l ("New-LocalCopy for {0}" -f $cs.path)
$null = New-LocalCopy $cs.path $c

#read the data from the local copy of the file
$ReadDataArgs = @{
    SqlStatement = Get-Content $table.sql -Raw
    ConnectionString = $cs.cs_format -f (Resolve-Path (split-path $cs.path -leaf)).Path
}
$r = Read-OleDbData @ReadDataArgs

```

This method assumes that there are some settings available. Settings.json would have something like the following in it:

```json
"cs": {
        "myxlsx": {
            "cs_type": "xlsx",
            "cs_format": "Provider=Microsoft.ACE.OLEDB.12.0;Data Source='{0}';Extended Properties='Excel 12.0 Xml;HDR=NO;IMEX=1;'",
            "path": "\\\\server\\share\\mysheet.xlsx",
            "user": "user@domain.local",
            "pass": "fancypassword"
        }
    },
"datasets": [{
        "name": "myDataset",
        "csname": "myxlsx",
        "tables": [{
                "name": "myTable1",
                "sql": "myTable1.sql"
            },
            {
                "name": "myTable2",
                "sql": "myTable2.sql"
            }
        ]
    }]
```

SQL files would have oledb compliant sql like:

```sql
select
    ROUND(F1) as [A]
from
    [sheet1$A1:A1]
```

If you want to use something different, I would offer up the excellent [ImportExcel](https://github.com/dfinke/ImportExcel) module. That is what we use for xlsx output by default. We used to use that for input as well, but added some functionality which required a couple of dozen sheets and different ranges and it was easier to just store it in SQL for readability.

# Variations on Output file format

## Output to log only

This is for processes that do something, but don't need to send any information out. This is not for the get data/use data pattern, but more for jobs that modify things on a schedule. Outputting data isn't really required, but in some of our use cases we will do something like, create a set of changes to make in a sql server and select into a #temptable prior to execution, then make the changes and output the #temptable like this so the log can be consulted if there are issues.

```ps1
Invoke-Sqlcmd -QueryTimeout 1800 -ConnectionString $cfg.cs -InputFile $cfg.sql |
    Select-Object * -ExcludeProperty RowError,RowState,Table,ItemArray,HasErrors |
    Format-Table -Property * -AutoSize |
    Out-String -Width 4096
```

## Unquoted CSV

```ps1
ConvertTo-Csv -NoTypeInformation |
    # if no header row allowed
    # Select-Object -Skip 1 |
    ForEach-Object{ "$($_ -replace '"', '')" } |
    Set-Content $file
```

## Xlsx

We use ImportExcel module for this purpose. So that will need to be installed, and the Import line added as below. Assumption is that `$file` below represents a filename like `somefile.xlsx`.

```ps1
Import-Module ImportExcel
Export-Excel \$file -TableStyle Medium6 -AutoSize -NoNumberConversion \*
```

# Variations on sending the data

## Send via FTP (or some variation of FTP)

We use WinSCP for this purpose and so any situation that WinSCP supports, we can support. The module will need to be installed and imported as noted below. Below assumes there is a settings.json file with a ftp section that has a user, pass, host value, as well as a `$file` variable with the name of the file.

```ps1
Import-Module WinSCP
$securepass = ConvertTo-SecureString $cfg.ftp.pass -AsPlainText -Force
$credential = New-Object pscredential ($cfg.ftp.user, \$securepass)
$sessionOption = New-WinSCPSessionOption -HostName $cfg.ftp.host -Credential \$credential -Protocol Ftp -FtpSecure Explicit

New-WinSCPSession -SessionOption \$sessionOption
Send-WinSCPItem \$file
Remove-WinSCPSession
```

# Additional variations


## Sanatize the data after the fact, but before outputting to some formatter

Note: I have only used this in specific instances, so this may not work properly for a random item. I'll update it for a generic next time i actually use it. In this example, we're looking to just replace any non alphanumeric char with a space, then replace all multi spaces with a single space and trim it. Below assumes you already have a `$dt` variable with the default output.

```ps1
$somerecords = $dt | Select-Object $dt.Columns.ColumnName
$dt = foreach($i in (0..($somerecords.count-1)) ){
    foreach($ii in $somerecords[$i].psobject.properties){
        $ii.value = (($ii.value -replace "[^a-za-z0-9]"," ") -replace "\s+"," ").Trim()
    }
}

```