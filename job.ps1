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

    # output to log only
    # Invoke-Sqlcmd -QueryTimeout 1800 -ConnectionString $cfg.cs -InputFile $cfg.sql |
    #     Select-Object * -ExcludeProperty RowError,RowState,Table,ItemArray,HasErrors |
    #     Format-Table -Property * -AutoSize |
    #     Out-String -Width 4096

    $dt = Invoke-Sqlcmd -QueryTimeout 1800 -ConnectionString $cfg.cs -InputFile $cfg.sql -OutputAs DataTables
    if (($dt | Measure-Object).count -gt 0) {

        # csv
        $dt |
        Select-Object $dt.Columns.ColumnName |
        Export-Csv $file -NoTypeInformation

        # unquoted csv
        # ConvertTo-Csv -NoTypeInformation |
        # # if no header row allowed
        # # Select-Object -Skip 1 |
        # ForEach-Object{ "$($_ -replace '"', '')" } |
        # Set-Content $file

        # excel
        # # Import-Module ImportExcel
        # Export-Excel $file -TableStyle Medium6 -AutoSize -NoNumberConversion *

        l "Use Data"

        # send file vial email using msgraph
        Send-FileViaEmail $file $cfg -useGraph

        #send file using ftp
        # Import-Module WinSCP
        # $securepass = ConvertTo-SecureString $cfg.ftp.pass -AsPlainText -Force
        # $credential = New-Object pscredential ($cfg.ftp.user, $securepass)
        # $sessionOption = New-WinSCPSessionOption -HostName $cfg.ftp.host -Credential $credential -Protocol Ftp -FtpSecure Explicit
        # New-WinSCPSession -SessionOption $sessionOption
        # Send-WinSCPItem $file
        # Remove-WinSCPSession

    }
    else {
        "No data available"
    }
    l "Cleanup"    ; Clear-Files $cfg
    l "End"
    "`n`n"

}

#run main, output to screen and log
& { main } *>&1 | Tee-Object -Append ("{0:yyyyMMdd}.log" -f (get-date))