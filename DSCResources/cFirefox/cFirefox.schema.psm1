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
        [ValidateSet('Auto', 'x86', 'x64', 'ARM64')]
        [string]
        $MachineBits = 'Auto',

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

    # Determine os architecture
    $OS = 'win32'; $Arch = 'x86'
    switch ($MachineBits)
    {
        'x86' { $OS = 'win32'; $Arch = 'x86'; break }
        'x64' { $OS = 'win64'; $Arch = 'x64'; break }
        'ARM64' { $OS = 'win64-aarch64'; $Arch = 'AArch64'; break }
        'Auto'
        {
            switch (& { if ($env:PROCESSOR_ARCHITEW6432) { $env:PROCESSOR_ARCHITEW6432 } else { $env:PROCESSOR_ARCHITECTURE } })
            {
                'AMD64'
                {
                    $OS = 'win64'; $Arch = 'x64'; break
                }

                'ARM64'
                {
                    $OS = 'win64-aarch64'; $Arch = 'AArch64'; break
                }
            }
        }
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

    # Validate version string
    [System.Version]$TargetVersion = $null
    if (-not [System.Version]::TryParse(($VersionNumber -replace '[^\d\.]', ''), [ref]$TargetVersion))
    {
        Write-Error -Message 'VersionNumber is not valid format of values.'
        return
    }

    if ($VersionNumber -match 'esr')
    {
        $v1 = $VersionNumber.Substring(0, $VersionNumber.IndexOf('esr'))
        $AppName = ('Mozilla Firefox {0}{1} ({2} {3})' -f $v1, ' ESR', $Arch, $Language)
    }
    else
    {
        # The format of the application name changed from 90.0
        if ($TargetVersion -ge [version]::new(90, 0))
        {
            $AppName = ('Mozilla Firefox ({0} {1})' -f $Arch, $Language)
        }
        else
        {
            $AppName = ('Mozilla Firefox {0} ({1} {2})' -f $VersionNumber, $Arch, $Language)
        }
    }

    if ($Credential)
    {
        cApplication Install
        {
            Name          = $AppName
            Version       = ($TargetVersion.ToString())
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
            Version       = ($TargetVersion.ToString())
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
