﻿Configuration cFirefoxPrefs
{
    # help about autoconfig
    # https://www.mozilla.jp/business/faq/tech/setting-management/
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $PrefName,

        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $PrefValue,

        [ValidateSet('pref', 'defaultPref', 'lockPref', 'clearPref', 'LocalizablePreferences')]
        [string] $PrefType = 'pref',

        [ValidatePattern('.+\.cfg$')]
        [string] $CfgFileName = "autoconfig.cfg",

        [ValidateNotNullOrEmpty()]
        [string] $FirefoxDirectory = "C:\Program Files\Mozilla Firefox"
    )

    Import-DscResource -ModuleName DSCR_IniFile

    $MozIniPath = Join-Path $FirefoxDirectory "\distribution\distribution.ini"
    $MozPrefJsPath = Join-Path $FirefoxDirectory "\defaults\pref\autoconfig.js"
    $MozPrefCfgPath = Join-Path $FirefoxDirectory $CfgFileName

    $FormattedPrefValue = & {
        if ([float]::TryParse($PrefValue, [ref]$null)) {$PrefValue}
        elseif ([bool]::TryParse($PrefValue, [ref]$null)) {$PrefValue.toLower()}
        else {"`"$PrefValue`""}
    }

    $PrefLine = if ($PrefType -eq 'clearPref') {
        ('{0}("{1}");' -f $PrefType, $PrefName)
    }
    else {
        ('{0}("{1}", {2});' -f $PrefType, $PrefName, $FormattedPrefValue)
    }

    $Global = @{
        id      = 'DSC-Customized'
        version = '1.0'
        about   = 'DSC-Customized'
    }

    if (($PrefType -eq 'pref') -or ($PrefType -eq 'LocalizablePreferences')) {
        cIniFile Global_Id
        {
            Ensure   = 'Present'
            Path     = $MozIniPath
            Key      = 'id'
            Value    = $Global.id
            Section  = 'Global'
            Encoding = 'UTF8'
        }
        cIniFile Global_version
        {
            Ensure   = 'Present'
            Path     = $MozIniPath
            Key      = 'version'
            Value    = $Global.version
            Section  = 'Global'
            Encoding = 'UTF8'
        }
        cIniFile Global_about
        {
            Ensure   = 'Present'
            Path     = $MozIniPath
            Key      = 'about'
            Value    = $Global.about
            Section  = 'Global'
            Encoding = 'UTF8'
        }
    }

    if ($PrefType -eq 'pref') {
        cIniFile Prefs
        {
            Ensure   = 'Present'
            Path     = $MozIniPath
            Key      = $PrefName
            Value    = $FormattedPrefValue
            Section  = 'Preferences'
            Encoding = 'UTF8'
        }
    }
    elseif ($PrefType -eq 'LocalizablePreferences') {
        cIniFile LocalizedPrefs
        {
            Ensure   = 'Present'
            Path     = $MozIniPath
            Key      = $PrefName
            Value    = $FormattedPrefValue
            Section  = 'LocalizablePreferences'
            Encoding = 'UTF8'
        }
    }
    else {
        File autoconfig_js {
            DestinationPath = $MozPrefJsPath
            Contents        = @"
pref("general.config.filename", "$CfgFileName");
pref("general.config.vendor", "autoconfig");
pref("general.config.obscure_value", 0);
"@
        }

        Script autoconfig_cfg {
            SetScript  = {
                if (-not (Test-Path $using:MozPrefCfgPath)) {
                    New-Item -Path $using:MozPrefCfgPath -ItemType File -Force
                    '//The first line must be a comment' | Out-File $using:MozPrefCfgPath -Encoding utf8
                }
                (gc $using:MozPrefCfgPath) -replace ('(lock|clear|default|)pref\(\s*"{0}"\s*,\s*.+\s*\)\s*;' -f $using:PrefName), '' | Out-File $using:MozPrefCfgPath -Encoding utf8
                $using:PrefLine | Out-File $using:MozPrefCfgPath -Append -Encoding utf8
            }
            TestScript = {
                $RegExp = ('{0}\(\s*"{1}"\s*,\s*{2}\s*\)\s*;' -f $using:PrefType, $using:PrefName, $using:FormattedPrefValue)
                (Test-Path $using:MozPrefCfgPath) -and
                (get-item $using:MozPrefCfgPath | Select-String -Pattern $RegExp)
            }
            GetScript  = {
                $RegExp = ('{0}\(\s*"{1}"\s*,\s*{2}\s*\)\s*;' -f $using:PrefType, $using:PrefName, $using:FormattedPrefValue)
                @{
                    TestScript = $TestScript
                    SetScript  = $SetScript
                    GetScript  = $GetScript
                    Result     = ((Test-Path $using:MozPrefCfgPath) -and (get-item $using:MozPrefCfgPath | Select-String -Pattern $RegExp))
                }
            }
        }
    }
}