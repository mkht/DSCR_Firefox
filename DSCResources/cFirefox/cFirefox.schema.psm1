Configuration cFirefox
{
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $VersionNumber,

        [Parameter()]
        [string]
        $Language = 'en-US',

        [Parameter()]
        [ValidateSet('x86', 'x64')]
        [string]
        $MachineBits = 'x86',

        [Parameter()]
        [string]
        $InstallerPath,

        [Parameter()]
        [string]
        $InstallDirectoryName,

        [Parameter()]
        [string]
        $InstallDirectoryPath,

        [Parameter()]
        [bool]
        $QuickLaunchShortcut = $false, #obsoleted

        [Parameter()]
        [bool]
        $DesktopShortcut = $true,

        [Parameter()]
        [bool]
        $TaskbarShortcut = $false,

        [Parameter()]
        [bool]
        $MaintenanceService = $true,

        [Parameter()]
        [bool]
        $StartMenuShortcuts = $true,

        [Parameter()]
        [string]
        $StartMenuDirectoryName = 'Mozilla Firefox',

        [Parameter()]
        [bool]
        $OptionalExtensions = $true, #only Firefox 60+

        [Parameter()]
        [bool]
        $RegisterDefaultAgent = $true, #only Firefox 76+

        [Parameter()]
        [bool]
        $RemoveDistributionDir = $true,

        [Parameter()]
        [PSCredential]
        $Credential
    )

    Import-DscResource -ModuleName DSCR_Application

    if ($MachineBits -eq 'x64')
    {
        $OS = 'win64'
    }
    else
    {
        $OS = 'win32'
    }

    #region Configuration.ini
    # Create a Configuration.ini file for specifying install options.
    # https://firefox-source-docs.mozilla.org/browser/installer/windows/installer/FullConfig.html
    $IniPath = "$env:ProgramData\Microsoft\Windows\PowerShell\Configuration\BuiltinProvCache\DSCR_Firefox\Configuration.ini"
    [string[]]$IniContent = @(
        '[Install]',
        ('QuickLaunchShortcut=' + $QuickLaunchShortcut.ToString().toLower()),
        ('DesktopShortcut=' + $DesktopShortcut.ToString().toLower()),
        ('TaskbarShortcut=' + $TaskbarShortcut.ToString().toLower()),
        ('MaintenanceService=' + $MaintenanceService.ToString().toLower()),
        ('StartMenuShortcuts=' + $StartMenuShortcuts.ToString().toLower()),
        ('StartMenuDirectoryName=' + $StartMenuDirectoryName),
        ('OptionalExtensions=' + $OptionalExtensions.ToString().toLower())
        ('RegisterDefaultAgent=' + $RegisterDefaultAgent.ToString().toLower())
        ('RemoveDistributionDir=' + $RemoveDistributionDir.ToString().toLower())
    )

    if ($InstallDirectoryName)
    {
        $IniContent += ('InstallDirectoryName=' + $InstallDirectoryName)
    }

    if ($InstallDirectoryPath)
    {
        $IniContent += ('InstallDirectoryPath=' + $InstallDirectoryPath)
    }
    #endregion Configuration.ini

    if (-not $InstallerPath)
    {
        # Download an installer from Mozilla
        $InstallerPath = ('https://ftp.mozilla.org/pub/firefox/releases/{0}/{1}/{2}/Firefox%20Setup%20{0}.exe' -f $VersionNumber, $OS, $Language)
    }

    if ($VersionNumber -match 'esr')
    {
        $v1 = $VersionNumber.Substring(0, $VersionNumber.IndexOf('esr'))
        $AppName = ('Mozilla Firefox {0}{1} ({2} {3})' -f $v1, ' ESR', $MachineBits, $Language)
    }
    else
    {
        $AppName = ('Mozilla Firefox {0} ({1} {2})' -f $VersionNumber, $MachineBits, $Language)
    }

    if ($Credential)
    {
        cApplication Install
        {
            Name          = $AppName
            InstallerPath = $InstallerPath
            Arguments     = "-ms /INI=$IniPath"
            PreAction     = {
                $parent = (split-path -Path $using:IniPath -Parent)
                if (-not (Test-Path -Path $parent))
                {
                    New-Item -Path $parent -ItemType Directory -Force | Out-Null
                }
                $using:IniContent -join "`r`n" | Out-File -FilePath $using:IniPath -Encoding ascii -Force
            }
            NoRestart     = $true
            Credential    = $Credential
        }
    }
    else
    {
        cApplication Install
        {
            Name          = $AppName
            InstallerPath = $InstallerPath
            Arguments     = "-ms /INI=$IniPath"
            PreAction     = {
                $parent = (split-path -Path $using:IniPath -Parent)
                if (-not (Test-Path -Path $parent))
                {
                    New-Item -Path $parent -ItemType Directory -Force | Out-Null
                }
                $using:IniContent -join "`r`n" | Out-File -FilePath $using:IniPath -Encoding ascii -Force
            }
            NoRestart     = $true
        }
    }
}
