# source: https://docs.datadoghq.com/agent/faq/log4j_mitigation/?_gl=1*1su6kjy*_gcl_au*MTE3NjMxODk0LjE2OTUxMzAwMTM.*_ga*NzI3MDk2MTYuMTY5NTEzMDAxMw..*_ga_KN80RDFSQK*MTcwMjA3MDg1My43LjEuMTcwMjA3MTU3MC4wLjAuMA..*_fplc*QUxCcVQxY1JnblVFellmZGRyOXd1YVltTGV4ZjBiN1ZsdmxKV3ZwYTlCeGk5aWxuMWJ5Z3NleFRYYzR2ZEZoTHRSZ3Y2Zm40RWdIc29obDN0eHowWkY1NmElMkJsalVDOCUyRnR1ZmdUJTJGJTJGbiUyQiUyQnhhbmFtWWlPcFZRNUFWMlI5YyUyRnclM0QlM0Q.&_ga=2.7809330.122035611.1702070854-72709616.1695130013

Param(
    [Parameter(Mandatory=$false)]
    [Switch]$Validate

)

[Reflection.Assembly]::LoadWithPartialName('System.IO.Compression')

$zipfile = "C:\Program Files\Datadog\Datadog Agent\embedded\agent\dist\jmx\jmxfetch.jar"
$files   = "JndiLookup.class"

$stream = New-Object IO.FileStream($zipfile, [IO.FileMode]::Open)
$update_mode   = [IO.Compression.ZipArchiveMode]::Update
$read_mode   = [IO.Compression.ZipArchiveMode]::Read

if ($Validate -eq $true) {
	$mode = $read_mode
} else {
	$mode = $update_mode
}

$zip    = New-Object IO.Compression.ZipArchive($stream, $mode)

if ($Validate -eq $true) {
	$found = New-Object System.Collections.Generic.List[System.Object]
	($zip.Entries | ? { $files -contains $_.Name }) | % { $found.Add($_.Name) }

    if ($found.Count -eq 0) {
        Write-Output "The $zipfile is now safe to run."
    } else {
        Write-Output "Dangerous file still present, something failed during the JNDI cleanup."
    }
} else {
	($zip.Entries | ? { $files -contains $_.Name }) | % { $_.Delete() }
}

$zip.Dispose()
$stream.Close()
$stream.Dispose()
