Configuration cFirefoxBookmarks
{
    # help about bookmarks
    # https://www.mozilla.jp/business/faq/tech/customize-defaults/#faq2
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Title,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
         $Link,

        [Parameter()]
        [ValidateRange(1, 99)]
        [int]
         $Position = 1,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
         $BookmarksLocation = 'BookmarksMenu', # BookmarksMenu / BookmarksToolbar / BookmarksFolder-(FolderId)

        [Parameter()]
        [ValidateSet('link', 'separator', 'folder')]
        [string]
         $Type = 'link',

        [Parameter()]
        [string]
        $IconUrl,

        [Parameter()]
        [string]
        $IconData,

        [Parameter()]
        [int]
        $FolderId = 1,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $FirefoxDirectory = 'C:\Program Files\Mozilla Firefox'
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName DSCR_FileContent

    $MozIniPath = Join-Path $FirefoxDirectory '\distribution\distribution.ini'

    $Global = @{
        id      = 'DSC-Customized'
        version = '1.0'
        about   = 'DSC-Customized'
    }

    Script Test_FireFoxDirectory
    {
        GetScript  = {
        }
        TestScript = {
            if (-not (Test-Path (Join-Path $using:FirefoxDirectory 'FireFox.exe') -PathType Leaf))
            {
                Write-Warning ('"FireFox.exe" does not exist in "{0}". Please confirm FireFoxDirectory' -f $using:FirefoxDirectory)
            }
            $true
        }
        SetScript  = {
        }
    }

    IniFile Global_Id
    {
        Ensure   = 'Present'
        Path     = $MozIniPath
        Key      = 'id'
        Value    = $Global.id
        Section  = 'Global'
        Encoding = 'UTF8'
    }

    IniFile Global_version
    {
        Ensure   = 'Present'
        Path     = $MozIniPath
        Key      = 'version'
        Value    = $Global.version
        Section  = 'Global'
        Encoding = 'UTF8'
    }

    IniFile Global_about
    {
        Ensure   = 'Present'
        Path     = $MozIniPath
        Key      = 'about'
        Value    = $Global.about
        Section  = 'Global'
        Encoding = 'UTF8'
    }

    IniFile Global_bookmarks
    {
        Ensure   = 'Present'
        Path     = $MozIniPath
        Key      = 'bookmarks.initialized.pref'
        Value    = 'distribution.ini.boomkarks.initialized'
        Section  = 'Global'
        Encoding = 'UTF8'
    }

    if ($Type -eq 'link')
    {
        IniFile Bookmarks_Title
        {
            Ensure   = 'Present'
            Path     = $MozIniPath
            Key      = ("item.$Position.title")
            Value    = $Title
            Section  = $BookmarksLocation
            Encoding = 'UTF8'
        }
        IniFile Bookmarks_Link
        {
            Ensure   = 'Present'
            Path     = $MozIniPath
            Key      = ("item.$Position.link")
            Value    = $Link
            Section  = $BookmarksLocation
            Encoding = 'UTF8'
        }
        if ($IconUrl)
        {
            IniFile Bookmarks_Icon
            {
                Ensure   = 'Present'
                Path     = $MozIniPath
                Key      = ("item.$Position.icon")
                Value    = $IconUrl
                Section  = $BookmarksLocation
                Encoding = 'UTF8'
            }
        }
        if ($IconData)
        {
            IniFile Bookmarks_IconData
            {
                Ensure   = 'Present'
                Path     = $MozIniPath
                Key      = ("item.$Position.iconData")
                Value    = $IconData
                Section  = $BookmarksLocation
                Encoding = 'UTF8'
            }
        }
    }

    if ($Type -eq 'separator')
    {
        IniFile Bookmarks_Separator
        {
            Ensure   = 'Present'
            Path     = $MozIniPath
            Key      = ("item.$Position.type")
            Value    = $Type
            Section  = $BookmarksLocation
            Encoding = 'UTF8'
        }
    }

    if ($Type -eq 'folder')
    {
        IniFile Bookmarks_Folder
        {
            Ensure   = 'Present'
            Path     = $MozIniPath
            Key      = ("item.$Position.type")
            Value    = $Type
            Section  = $BookmarksLocation
            Encoding = 'UTF8'
        }
        IniFile Bookmarks_Title
        {
            Ensure   = 'Present'
            Path     = $MozIniPath
            Key      = ("item.$Position.title")
            Value    = $Title
            Section  = $BookmarksLocation
            Encoding = 'UTF8'
        }
        IniFile Bookmarks_FolderId
        {
            Ensure   = 'Present'
            Path     = $MozIniPath
            Key      = ("item.$Position.folderId")
            Value    = $FolderId
            Section  = $BookmarksLocation
            Encoding = 'UTF8'
        }
    }
}
