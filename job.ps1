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
    Import-Module SqlServer -Cmdlet "Invoke-Sqlcmd"

    #get config, set primary output file name
    $cfg = Get-Content settings.json -Raw | ConvertFrom-Json
    $file = $cfg.file_format -f (get-date)

    #main logic
    "`n`n"
    l "Start"
    l "Get Data"

    $sqlargs = $cfg.sql.psobject.Properties | % { $h = @{} } { $h."$($_.Name)" = $_.Value } { $h }
    # if using pwsh, can use below instead
    #$sqlargs = $cfg.sql | ConvertTo-Json | ConvertFrom-Json -AsHashtable
    $dt = Invoke-Sqlcmd @sqlargs
    if (($dt | Measure-Object).count -gt 0) {

        $dt |
        Select-Object $dt.Columns.ColumnName |
        Export-Csv $file -NoTypeInformation
            
        l "Use Data"
        Send-FileViaEmail $file $cfg -useGraph

    }
    else {
        l "No data available"
    }

    l "Cleanup"    ; Clear-Files $cfg
    l "End"
    "`n`n"

}

#run main, output to screen and log
& { main } *>&1 | Tee-Object -Append ("{0:yyyyMMdd}.log" -f (get-date))
