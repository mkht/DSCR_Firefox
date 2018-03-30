Configuration cFirefox
{
    param
    (
        [string]
        [ValidateNotNullOrEmpty()]
        $VersionNumber,
        [string]
        $Language = "en-US",
        [string]
        $OS = "win",
        [ValidateSet("x86", "x64")]
        [string]
        $MachineBits = "x86",
        [string]
        $LocalPath = "$env:SystemDrive\Windows\temp\DtlDownloads\Firefox Setup " + $VersionNumber + ".exe",
        [string]
        $InstallDirectoryName,
        [string]
        $InstallDirectoryPath,
        [bool]
        $QuickLaunchShortcut = $false,
        [bool]
        $DesktopShortcut = $true,
        [bool]
        $TaskbarShortcut = $false,
        [bool]
        $MaintenanceService = $true
    )

    Import-DscResource -ModuleName DSCR_Application

    if ($MachineBits -eq "x64") {
        $OS += "64"
    }

    $IniPath = "$env:SystemDrive\Windows\temp\DtlDownloads\Configuration.ini"
    [string[]]$IniContent = @(
        "[Install]",
        ("QuickLaunchShortcut=" + $QuickLaunchShortcut.ToString().toLower()),
        ("DesktopShortcut=" + $DesktopShortcut.ToString().toLower()),
        ("TaskbarShortcut=" + $TaskbarShortcut.ToString().toLower()),
        ("MaintenanceService=" + $MaintenanceService.ToString().toLower())
    )
    if ($InstallDirectoryName) {
        $IniContent += ("InstallDirectoryName=" + $InstallDirectoryName)
    }
    if ($InstallDirectoryPath) {
        $IniContent += ("InstallDirectoryPath=" + $InstallDirectoryPath)
    }

    cApplication Install
    {
        Name      = "Mozilla Firefox " + $VersionNumber + " (" + $MachineBits + " " + $Language + ")"
        InstallerPath = "https://download.mozilla.org/?product=firefox-" + $VersionNumber + "&os=" + $OS + "&lang=" + $Language
        Arguments = "-ms /INI=$IniPath"
        PreAction = {
            $parent = (split-path -Path $using:IniPath -Parent)
            if (-not (Test-Path -Path $parent)) {
                New-Item -Path $parent -ItemType Directory -Force | Out-Null
            }
            $using:IniContent -join "`r`n" | Out-File -FilePath $using:IniPath -Encoding ascii -Force
        }
        NoRestart = $true
    }

}