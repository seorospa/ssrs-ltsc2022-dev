$config = Get-WmiObject -namespace root\Microsoft\SqlServer\ReportServer\RS_SSRS\v15\Admin -class MSReportServer_ConfigurationSetting
$hasUser =  (Get-LocalUser).Name -Contains $Env:SSRS_USERNAME

if (!$hasUser) {
    Write-Host "Creating admin user..."

    $secpass = ConvertTo-SecureString  -AsPlainText $Env:SSRS_PASSWORD -Force
    New-LocalUser $Env:SSRS_USERNAME -Password $secpass -FullName $Env:SSRS_USERNAME -Description "Local admin $Env:SSRS_USERNAME"
    Add-LocalGroupMember -Group "Administrators" -Member $Env:SSRS_USERNAME
}

if (!$config.IsInitialized) {
    Write-Host "Configuring..."

    (Get-Content '.\Program Files\Microsoft SQL Server Reporting Services\SSRS\ReportServer\rsreportserver.config') -Replace 'RSWindowsNTLM', 'RSWindowsBasic' | Set-Content '.\Program Files\Microsoft SQL Server Reporting Services\SSRS\ReportServer\rsreportserver.config'

    Write-Host "Setting MSSQL"
    $config.SetDatabaseConnection($Env:MSSQL_HOST, $Env:MSSQL_DB, 1, $Env:MSSQL_USER, $Env:MSSQL_PASSWORD)

    Write-Host "Set directories"
    $config.SetVirtualDirectory("ReportServerWebService", "ReportServer", 1033)
    $config.SetVirtualDirectory("ReportServerWebApp", "Reports", 1033)

    $config.ReserveURL("ReportServerWebService", "http://+:80", 1033)
    $config.ReserveURL("ReportServerWebApp", "http://+:80", 1033)

    Write-Host "Restart Service"
    Restart-Service $config.ServiceName

    $config = Get-WmiObject -namespace root\Microsoft\SqlServer\ReportServer\RS_SSRS\v15\Admin -class MSReportServer_ConfigurationSetting

    Write-Host "Initializing"
    $res = $config.InitializeReportServer($config.InstallationID)
    $config.SetServiceState($true, $true, $true)

    $config
    Write-Host $res
}

Write-Host "done!"

Wait-Process -Name RSManagement
