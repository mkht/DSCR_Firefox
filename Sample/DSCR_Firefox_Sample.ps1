$output = 'C:\MOF'
Import-Module DSCR_Firefox -force

Configuration DSCR_Firefox_Sample
{

    Import-DscResource -ModuleName DSCR_Firefox

    cFireFox FireFox_Install
    {
        VersionNumber        = '54.0.1'
        Language             = 'ja'
        MachineBits          = 'x86'
        InstallDirectoryPath = 'C:\FireFox'
    }

    cFireFoxBookmarks FireFox_Bookmark_Google
    {
        Title            = 'Google'
        Link             = 'https://www.google.com/'
        FirefoxDirectory = 'C:\FireFox'
    }

    cFireFoxPrefs FireFox_Update_Disable
    {
        PrefName         = 'app.update.enabled'
        PrefValue        = $false
        PrefType         = 'lockPref'
        FirefoxDirectory = 'C:\FireFox'
    }

}

DSCR_Firefox_Sample -OutputPath $output -ErrorAction Stop
Start-DscConfiguration -Path $output -Verbose -wait -force
Remove-DscConfigurationDocument -Stage Current, Previous, Pending -Force