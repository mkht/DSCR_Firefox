DSCR_Firefox
====

DSC Resource for managing Firefox

----
## Installation
You can install from [PowerShell Gallery](https://www.powershellgallery.com/packages/DSCR_Firefox/).
```Powershell
Install-Module -Name DSCR_Firefox
```

## Dependencies
* [DSCR_Application](https://github.com/mkht/DSCR_Application)
* [DSCR_FileContent](https://github.com/mkht/DSCR_FileContent)

----
## Resources
|||
|:---:|:---:|
|[cFirefox](#cfirefox)||
|[cFirefoxBookmarks](#cfirefoxbookmarks)|[cFirefoxPrefs](#cfirefoxprefs)|
|[cFirefoxPolicy](#cfirefoxpolicy)|[cFirefoxBookmarksPolicy](#cfirefoxbookmarkspolicy)|

----
## **cFirefox**
Install Firefox

### Properties
+ [string] **VersionNumber** (Require):
    + The version of the Firefox you wish install. e.g) `61.0`

+ [string] **Language** (Optional):
    + Language of the Firefox.
    + The default is `en-US`

+ [string] **MachineBits** (Optional):
    + Specify the machine's operating system bit number.
    + The default is `x86`. (`x86` or `x64`)

+ [string] **InstallerPath** (Optional):
    + The path of the Firefox installer file.
    + If this value is not specified, The Installer will be downloaded from Mozilla. (https://ftp.mozilla.org/pub/firefox/releases/)
    + Please use if you want to use self-customized installer or if the target machine is not connected to the Internet.

+ [string] **InstallDirectoryName** (Optional):
    + The name of the directory where the Firefox will be installed.
    + If this value is specified then `InstallDirectoryPath` will be ignored.

+ [string] **InstallDirectoryPath** (Optional):
    + The full path of the directory to install the Firefox.
    + If the both `InstallDirectoryPath` and `InstallDirectoryName` not specified, the Firefox will be installed in the system's program files directory.

+ [bool] **QuickLaunchShortcut** (Optional):
    + Create a shortcut for the Firefox in the QuickLaunch directory.
    + The default is `$false`

+ [bool] **DesktopShortcut** (Optional):
    + Create a shortcut for the Firefox on the all user's desktop.
    + The default is `$true`

+ [bool] **TaskbarShortcut** (Optional):
    + Create a shortcut for the Firefox on the taskbar.
    + The default is `$false`

+ [bool] **MaintenanceService** (Optional):
    + Specify whether the MozillaMaintenance service will be installed or not
    + The default is `$true`

+ [bool] **StartMenuShortcuts** (Optional):
    + Create shortcuts for the application in the Start Menu.
    + The default is `$true`

+ [string] **StartMenuDirectoryName** (Optional):
    + The directory name to use for the StartMenu folder
    + The default is `Mozilla Firefox`

+ [bool] **OptionalExtensions** (Optional):
    + Set this option to `$false` to opt-out installation of any optional extensions.
    + The default is `$true`
    + This option can be used in Firefox 60 or later.

+ [PSCredential] **Credential** (Optional):
    + The credential for access to the installer on a remote source if needed.
    + :warning: If you want to run the installation as specific user, you need to use `PsDscRunAsCredential` standard property.


### Examples
+ **Example 1**: Install Firefox 63.0 x64 japanese
```Powershell
Configuration Example1
{
    Import-DscResource -ModuleName DSCR_Firefox
    cFirefox Firefox53
    {
        VersionNumber = "63.0"
        Language = "ja"
        Machinebits = "x64"
    }
}
```

+ **Example 2**: Install Firefox 60.0 ESR without MozillaMaintenance service
```Powershell
Configuration Example2
{
    Import-DscResource -ModuleName DSCR_Firefox
    cFirefox Firefox60ESR
    {
        VersionNumber = "60.0esr"
        MaintenanceService = $false
    }
}
```

----
## **cFirefoxBookmarks**
Manage bookmarks.

### Properties
+ [string] **Title** (Require):
    + The title of the bookmark.

+ [string] **Link** (Require):
    + The URL of the bookmark.

+ [string] **Type** (Optional):
    + Specify the type of the item.
    + `Link` / `Separator` / `Folder`
    + The default is `Link`

+ [string] **BookmarksLocation** (Optional):
    + The location of the bookmark
    + `BookmarksMenu` / `BookmarksToolbar` / `BookmarksFolder-(FolderId)`
    + The default is `BookmarksMenu`

+ [int] **Position** (Optional):
    + The position of the bookmark. The smaller is placed above. (1-99)
    + The default is `1`

+ [string] **IconUrl** (Optional):
    + The URL of the bookmark's icon.

+ [string] **IconData** (Optional):
    + The data of the bookmark's icon.
    + You can use data URI scheme.

+ [int] **FolderId** (Optional):
    + The ID of the folder.
    + This value only respect when the item type is `Folder`.
    + The default is `1`

+ [string] **FirefoxDirectory** (Optional):
    + Specify the directory of the Firefox installed.
    + The default is `"C:\Program Files\Mozilla Firefox"`

### Examples
**Example 1**: Bookmark to Google
```Powershell
Configuration Example1
{
    Import-DscResource -ModuleName DSCR_Firefox
    cFireFoxBookmarks FireFox_Bookmark_Google
    {
        Title = 'Google'
        Link = 'https://www.google.com/'
    }
}
```

----
## **cFirefoxPrefs**
 Manage preferences.

### Properties
+ [string] **PrefName** (Require):
    + The name of the preference.

+ [string] **PrefValue** (Require):
    + The value of the preference.

+ [string] **PrefType** (Optional):
    + The type of the preference.
    + `pref` / `defaultPref` / `lockPref` / `cleanPref` / `LocalizablePreferences`
    + The default is `pref`

|Type|detail|
|:------:|:------|
|pref|The user can temporarily change the setting, but the changed value will be lost when exit Firefox|
|defaultPref|The user can change the setting, and the changed value will be saved even after Firefox exits.|
|lockPref|The user can not change the setting.|
|cleanPref|Delete setting value|

+ [string] **FirefoxDirectory** (Optional):
    + Specify the directory of the Firefox installed.
    + The default is `"C:\Program Files\Mozilla Firefox"`

### Examples
**Example 1**: Disable Firefox update
```Powershell
Configuration Example1
{
    Import-DscResource -ModuleName DSCR_Firefox
    cFireFoxPrefs FireFox_Update_Disable
    {
        PrefName = 'app.update.enabled'
        PrefValue = $false
        PrefType = 'lockPref'
    }
}
```

----
## **cFirefoxPolicy**
The DSC Resource for configuring [Firefox Enterprise Policies](https://wiki.mozilla.org/Firefox/EnterprisePolicies)  
This resource can be used only in Firefox 60 or later

### Properties
+ [string] **Ensure** (Optional):
    + Whether to set or delete policies
    + The default is `Present`  [`Present` | `Absent`]

+ [string] **PolicyName** (Require):
    + The NAME of the policy
    + Please refer to [the document](https://github.com/mozilla/policy-templates/blob/master/README.md) for possible values

+ [string] **PolicyValue** (Require):
    + The value of the policies
    + The value of this parameter must be a JSON formatted string

+ [string] **FirefoxDirectory** (Optional):
    + Specify the directory of the Firefox installed.
    + The default is `"C:\Program Files\Mozilla Firefox"`

### Examples
**Example 1**: To configure the policy that removes access to about:addons
```Powershell
Configuration Example1
{
    Import-DscResource -ModuleName DSCR_Firefox
    cFireFoxPolicy FireFox_BlockAboutAddons
    {
        PolicyName = 'BlockAboutAddons'
        PolicyValue = $true
    }
}
```

**Example 2**: To configure the policy that sets the default homepage
```Powershell
Configuration Example2
{
    Import-DscResource -ModuleName DSCR_Firefox
    cFireFoxPolicy FireFox_Homepage
    {
        PolicyName = 'Homepage'
        PolicyValue = @'
        {
            "URL": "http://example.com/",
            "Locked": true,
            "Additional": ["http://example.org/", "http://example.edu/"]
        }
'@
    }
}
```

----
## **cFirefoxBookmarksPolicy**
The DSC Resource for configuring Bookmarks  
The difference with *cFirefoxBookmarks* is set as policy, so you can enforce settings to the end-users  
This resource can be used only in Firefox 60 or later

### Properties
+ [string] **Ensure** (Optional):
    + Whether to create or delete bookmarks
    + The default is `Present`  [`Present` | `Absent`]

+ [string] **Title** (Require):
    + The name of the bookmark

+ [string] **URL** (Require):
    + The URL of the bookmark.

+ [string] **Favicon** (Optional):
    + The URL of the bookmark's icon.

+ [string] **Placement** (Optional):
    + Whether to place bookmarks in menu or toolbar.
    + The default is `toolbar`  [`toolbar` | `menu`]

+ [string] **Folder** (Optional):
    + If a Folder is specified, it is automatically created and bookmarks with the same folder name are grouped together.

+ [string] **FirefoxDirectory** (Optional):
    + Specify the directory of the Firefox installed.
    + The default is `"C:\Program Files\Mozilla Firefox"`

### Examples
**Example 1**: Create bookmark
```Powershell
Configuration Example1
{
    Import-DscResource -ModuleName DSCR_Firefox
    cFireFoxBookmarksPolicy FireFox_BookmarksPolicy
    {
        Title   = 'Example1'
        URL     = 'https://www.example.com/'
        Favicon = 'https://www.example.com/favicon.ico'
    }
}
```

----
## ChangeLog
### 1.1.0
 + Add the dependent modules to [DSCR_FileContent](https://github.com/mkht/DSCR_FileContent).
 + Remove the dependent modules [DSCR_IniFile](https://github.com/mkht/DSCR_IniFile) and [DSCR_JsonFile](https://github.com/mkht/DSCR_JsonFile).

### 1.0.1
 + Remove unnecessary files in the published package

### 1.0.0
 + [cFirefox] Add the `Credential` property

### 0.9.0
+ Add new resource `cFirefoxPolicy`
+ Add new resource `cFirefoxBookmarksPolicy`

### 0.8.0
 + [cFirefox] Now you can specify the ESR version of Firefox. e.g) `VersionNumber = "60.0esr"`
 + [cFirefox] Add the `OptionalExtensions` param to opt-out installation of any optional extensions. (This option can be used in Firefox 60 or later)
 + [cFirefox] Add `StartMenuShortcuts` and `StartMenuDirectoryName` params.
 + [cFirefox] Add the `InstallerPath` param for offline installation.
 + [cFirefox] Change the download source URL of the installer to `https://ftp.mozilla.org/`

### 0.7.1
 + Fix issue [#7](https://github.com/mkht/DSCR_Firefox/issues/7) `cFirefoxPrefs` was not loaded some systems.

### 0.7.0
 + Add module dependency ([DSCR_Application](https://github.com/mkht/DSCR_Application))
 + Remove module dependency (xPSDesiredStateConfiguration)
 + Fix issue that the Download process runs even if FireFox has already been installed [#4](https://github.com/mkht/DSCR_Firefox/issues/4)
