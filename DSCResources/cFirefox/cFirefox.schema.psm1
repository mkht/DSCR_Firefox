Configuration cFirefox
{
    param
    (
        [string]
        [ValidateNotNullOrEmpty()]
        $VersionNumber,
        [string]
        $Language = "en-US",
        [ValidateSet("x86", "x64")]
        [string]
        $MachineBits = "x86",
        [string]
        $InstallerPath,
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
        $MaintenanceService = $true,
        [bool]
        $StartMenuShortcuts = $true,
        [string]
        $StartMenuDirectoryName = 'Mozilla Firefox',
        [bool]
        $OptionalExtensions = $true #only Firefox 60+
    )

    Import-DscResource -ModuleName DSCR_Application

    if ($MachineBits -eq "x64") {
        $OS = "win64"
    }
    else{
        $OS = "win32"
    }

    $IniPath = "$env:SystemDrive\Windows\temp\DtlDownloads\Configuration.ini"
    [string[]]$IniContent = @(
        "[Install]",
        ("QuickLaunchShortcut=" + $QuickLaunchShortcut.ToString().toLower()),
        ("DesktopShortcut=" + $DesktopShortcut.ToString().toLower()),
        ("TaskbarShortcut=" + $TaskbarShortcut.ToString().toLower()),
        ("MaintenanceService=" + $MaintenanceService.ToString().toLower()),
        ("StartMenuShortcuts=" + $StartMenuShortcuts.ToString().toLower()),
        ("StartMenuDirectoryName=" + $StartMenuDirectoryName),
        ("OptionalExtensions=" + $OptionalExtensions.ToString().toLower())
    )
    if ($InstallDirectoryName) {
        $IniContent += ("InstallDirectoryName=" + $InstallDirectoryName)
    }
    if ($InstallDirectoryPath) {
        $IniContent += ("InstallDirectoryPath=" + $InstallDirectoryPath)
    }

    if(-not $InstallerPath){
        $InstallerPath = ("https://ftp.mozilla.org/pub/firefox/releases/{0}/{1}/{2}/Firefox%20Setup%20{0}.exe" -f $VersionNumber, $OS, $Language)
    }

    cApplication Install
    {
        Name      = "Mozilla Firefox " + $VersionNumber + " (" + $MachineBits + " " + $Language + ")"
        InstallerPath = $InstallerPath
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