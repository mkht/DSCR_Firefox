Configuration cFirefoxBookmarks
{
    # help about bookmarks
    # https://www.mozilla.jp/business/faq/tech/customize-defaults/#faq2
    param
    (

        [ValidateRange(1, 99)]
        [int] $Position = 1,

        [ValidateNotNullOrEmpty()]
        [string] $BookmarksLocation = 'BookmarksMenu',  # BookmarksMenu / BookmarksToolbar / BookmarksFolder-(FolderId)

        [ValidateNotNullOrEmpty()]
        [string] $Title,

        [ValidateSet('link', 'separator', 'folder')]
        [string] $Type = 'link',

        [ValidateNotNullOrEmpty()]
        [string] $Link,

        [string] $IconUrl,

        [string] $IconData,

        [int] $FolderId = 1,

        [ValidateNotNullOrEmpty()]
        [string] $FirefoxDirectory = "C:\Program Files\Mozilla Firefox"
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName DSCR_IniFile

    $MozIniPath = Join-Path $FirefoxDirectory "\distribution\distribution.ini"

    $Global = @{
        id      = 'DSC-Customized'
        version = '1.0'
        about   = 'DSC-Customized'
    }

    Script Check_FireFoxDirectory
    {
        GetScript = {
        }
        TestScript = {
            if(-not (Test-Path (Join-Path $using:FirefoxDirectory 'FireFox.exe') -PathType Leaf)){
                Write-Warning ('"FireFox.exe" does not exist in "{0}". Please confirm FireFoxDirectory' -f $using:FirefoxDirectory)
            }
            $true
        }
        SetScript = {
        }
    }

    cIniFile Global_Id
    {
        Ensure = 'Present'
        Path = $MozIniPath
        Key = 'id'
        Value = $Global.id
        Section = 'Global'
        Encoding = 'UTF8'
    }
    cIniFile Global_version
    {
        Ensure = 'Present'
        Path = $MozIniPath
        Key = 'version'
        Value = $Global.version
        Section = 'Global'
        Encoding = 'UTF8'
    }
    cIniFile Global_about
    {
        Ensure = 'Present'
        Path = $MozIniPath
        Key = 'about'
        Value = $Global.about
        Section = 'Global'
        Encoding = 'UTF8'
    }
    cIniFile Global_bookmarks
    {
        Ensure = 'Present'
        Path = $MozIniPath
        Key = 'bookmarks.initialized.pref'
        Value = 'distribution.ini.boomkarks.initialized'
        Section = 'Global'
        Encoding = 'UTF8'
    }

    if ($Type -eq 'link') {
        cIniFile Bookmarks_Title
        {
            Ensure = 'Present'
            Path = $MozIniPath
            Key = ("item.$Position.title")
            Value = $Title
            Section = $BookmarksLocation
            Encoding = 'UTF8'
        }
        cIniFile Bookmarks_Link
        {
            Ensure = 'Present'
            Path = $MozIniPath
            Key = ("item.$Position.link")
            Value = $Link
            Section = $BookmarksLocation
            Encoding = 'UTF8'
        }
        if ($IconUrl) {
            cIniFile Bookmarks_Icon
            {
                Ensure = 'Present'
                Path = $MozIniPath
                Key = ("item.$Position.icon")
                Value = $IconUrl
                Section = $BookmarksLocation
                Encoding = 'UTF8'
            }
        }
        if ($IconData) {
            cIniFile Bookmarks_IconData
            {
                Ensure = 'Present'
                Path = $MozIniPath
                Key = ("item.$Position.iconData")
                Value = $IconData
                Section = $BookmarksLocation
                Encoding = 'UTF8'
            }
        }
    }

    if ($Type -eq 'separator') {
        cIniFile Bookmarks_Separator
        {
            Ensure = 'Present'
            Path = $MozIniPath
            Key = ("item.$Position.type")
            Value = $Type
            Section = $BookmarksLocation
            Encoding = 'UTF8'
        }
    }

    if ($Type -eq 'folder') {
        cIniFile Bookmarks_Folder
        {
            Ensure = 'Present'
            Path = $MozIniPath
            Key = ("item.$Position.type")
            Value = $Type
            Section = $BookmarksLocation
            Encoding = 'UTF8'
        }
        cIniFile Bookmarks_Title
        {
            Ensure = 'Present'
            Path = $MozIniPath
            Key = ("item.$Position.title")
            Value = $Title
            Section = $BookmarksLocation
            Encoding = 'UTF8'
        }
        cIniFile Bookmarks_FolderId
        {
            Ensure = 'Present'
            Path = $MozIniPath
            Key = ("item.$Position.folderId")
            Value = $FolderId
            Section = $BookmarksLocation
            Encoding = 'UTF8'
        }
    }
}