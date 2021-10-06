#strict
Set-StrictMode -Version Latest

#define main
function main {

    #set location to script path
    Set-Location $PSScriptRoot

    #import modules
    Import-Module Add-PrefixForLogging
    Import-Module Clear-Files
    Import-Module Send-FileViaEmail
    Import-Module ImportExcel
    Import-Module SqlServer

    #get config, set primary output file name
    $cfg = Get-Content settings.json -Raw | ConvertFrom-Json
    $file = $cfg.file_format -f (get-date)

    #main logic
    "`n`n"
    l "Start"
    l "Get Data"
        $dt = Invoke-Sqlcmd -QueryTimeout 1800 -ConnectionString $cfg.cs -InputFile $cfg.sql -OutputAs DataTables
        if (($dt | Measure-Object).count -gt 0) {
            $dt |
            Select-Object $dt.Columns.ColumnName |
            Export-Excel $file -TableStyle Medium6 -AutoSize -NoNumberConversion *
        }
        else {
            "No data available"
        }
    l "Use Data"
        Send-FileViaEmail $file $cfg -useGraph
    l "Cleanup"    ; Clear-Files $cfg
    l "End"
    "`n`n"

}

#run main, output to screen and log
& { main } *>&1 | Tee-Object -Append ("{0:yyyyMMdd}.log" -f (get-date))