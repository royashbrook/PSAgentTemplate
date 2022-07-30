#remove ansi color coding
# see: https://stackoverflow.com/questions/69063656/
$PSStyle.OutputRendering = [System.Management.Automation.OutputRendering]::Host;

#set location to script path
Set-Location $PSScriptRoot

#define main
function main {

    #import modules
    Import-Module Add-PrefixForLogging
    Import-Module Clear-Files
    Import-Module Send-FileViaEmail
    Import-Module SqlServer -Cmdlet "Invoke-Sqlcmd"

    #get config, set primary output file name
    $cfg = Get-Content settings.json -Raw | ConvertFrom-Json
    $file = $cfg.file_format -f (get-date)

    #main logic
    "`n`n"
    l "Start"
    l "Cleanup"; Clear-Files $cfg

    l "Get Data"
    $sqlargs = $cfg.sql | ConvertTo-Json | ConvertFrom-Json -AsHashtable
    $dt = Invoke-Sqlcmd @sqlargs
    $rc = ($dt | Measure-Object).count

    #exit if no data
    if ($rc -eq 0) {
        l "No data available"
        return
    }

    l "Data Found. Formatting File."
    $dt |
        Select-Object $dt.Columns.ColumnName |
        Export-Csv $file -NoTypeInformation
            
    l "Use Data"
    Send-FileViaEmail $file $cfg

    l "End"

}
    
#run main, output to screen and log
& { main } *>&1 | Tee-Object -Append ("{0:yyyyMMdd}.log" -f (get-date))
