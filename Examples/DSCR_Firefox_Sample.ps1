$output = 'C:\MOF'
Import-Module DSCR_Firefox -force

Configuration DSCR_Firefox_Sample
{
    Import-DscResource -ModuleName DSCR_Firefox

    cFirefox Firefox_Install
    {
        VersionNumber        = '63.0'
        Language             = 'ja'
        MachineBits          = 'x64'
        InstallDirectoryPath = 'C:\Firefox'
    }

    cFirefoxBookmarks Firefox_Bookmark_Google
    {
        Title             = 'Google'
        Link              = 'https://www.google.com/'
        BookmarksLocation = 'BookmarksToolbar'
        FirefoxDirectory  = 'C:\Firefox'
    }

    cFirefoxPrefs Firefox_QuitWarning_Enable
    {
        PrefName         = 'browser.tabs.warnOnClose'
        PrefValue        = $false
        PrefType         = 'pref'
        FirefoxDirectory = 'C:\Firefox'
    }

    cFirefoxPolicy Firefox_BlockAboutConfig_Policy
    {
        PolicyName       = 'BlockAboutConfig'
        PolicyValue      = 'true'
        FirefoxDirectory = 'C:\Firefox'
    }

    cFirefoxBookmarksPolicy Firefox_BookmarksPolicy_GitHub
    {
        Title            = 'GitHub'
        URL              = 'https://github.com/'
        FirefoxDirectory = 'C:\Firefox'
    }

}

DSCR_Firefox_Sample -OutputPath $output -ErrorAction Stop
Start-DscConfiguration -Path $output -Verbose -wait -force
Remove-DscConfigurationDocument -Stage Current, Previous, Pending -Force
