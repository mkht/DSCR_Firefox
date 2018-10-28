Configuration cFirefoxBookmarksPolicy
{
    # help about Firefox Policy Engine
    # https://github.com/mozilla/policy-templates
    param
    (
        [Parameter(Mandatory = $false)]
        [ValidateSet('Ensure', 'Absent')]
        [string] $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $Title,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $URL,

        [Parameter(Mandatory = $false)]
        [string] $Favicon,

        [Parameter(Mandatory = $false)]
        [ValidateSet('toolbar', 'menu')]
        [string] $Placement,

        [Parameter(Mandatory = $false)]
        [string] $Folder,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string] $FirefoxDirectory = "C:\Program Files\Mozilla Firefox"
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName DSCR_FileContent

    $MozPolicyPath = Join-Path $FirefoxDirectory "\distribution\policies.json"

    $BookmarksPolicyParam = @{
        Title = $Title
        URL   = $URL
    }

    if ($Favicon) {
        $BookmarksPolicyParam.Add('Favicon', $Favicon)
    }

    if ($Placement) {
        $BookmarksPolicyParam.Add('Placement', $Placement)
    }

    if ($Folder) {
        $BookmarksPolicyParam.Add('Folder', $Folder)
    }

    $FormattedPolicyValue = ConvertTo-Json -InputObject $BookmarksPolicyParam -Compress

    Script Test_FirefoxDirectory {
        GetScript  = {
        }
        TestScript = {
            if (-not (Test-Path (Join-Path $using:FirefoxDirectory 'Firefox.exe') -PathType Leaf)) {
                Write-Warning ('"FireFox.exe" does not exist in "{0}". Please confirm FirefoxDirectory' -f $using:FirefoxDirectory)
            }
            $true
        }
        SetScript  = {
        }
    }

    JsonFile BookmarksPolicy {
        Ensure = $Ensure
        Path   = $MozPolicyPath
        Key    = "policies/Bookmarks"
        Value  = $FormattedPolicyValue
        Mode   = 'ArrayElement'
    }
}
