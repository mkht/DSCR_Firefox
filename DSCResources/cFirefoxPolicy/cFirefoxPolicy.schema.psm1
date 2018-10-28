Configuration cFirefoxPolicy
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
        [string] $PolicyName,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string] $PolicyValue,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string] $FirefoxDirectory = "C:\Program Files\Mozilla Firefox"
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName DSCR_FileContent

    $MozPolicyPath = Join-Path $FirefoxDirectory "\distribution\policies.json"

    $FormattedPolicyValue = & {
        if ([float]::TryParse($PolicyValue, [ref]$null)) {$PolicyValue}
        elseif ([bool]::TryParse($PolicyValue, [ref]$null)) {$PolicyValue.toLower()}
        else {
            [string]$tmp =
            if($PolicyValue.Trim() -notmatch '^[\[{"].+[\]}"]$'){
                '"' + $PolicyValue.Trim() + '"'
            }
            else{
                $PolicyValue.Trim()
            }

            try {
                ConvertFrom-Json -InputObject $tmp -ErrorAction Stop >$null
                $tmp
            }
            catch {
                throw [System.ArgumentException]::new('The PolicyValue should be valid JSON formatted string.')
            }
        }
    }

    Script Test_FirefoxDirectory
    {
        GetScript = {
        }
        TestScript = {
            if(-not (Test-Path (Join-Path $using:FirefoxDirectory 'Firefox.exe') -PathType Leaf)){
                Write-Warning ('"FireFox.exe" does not exist in "{0}". Please confirm FirefoxDirectory' -f $using:FirefoxDirectory)
            }
            $true
        }
        SetScript = {
        }
    }

    JsonFile FirefoxPolicy
    {
        Ensure  = $Ensure
        Path    = $MozPolicyPath
        Key     = "policies/$PolicyName"
        Value   = $FormattedPolicyValue
    }
}