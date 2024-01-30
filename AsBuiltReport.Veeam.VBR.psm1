## Import localisation strings based on UICulture
$importLocalizedDataParams = @{
    BindingVariable = 'localized'
    BaseDirectory   = ($PSScriptRoot + '\Language')
    FileName        = 'AsBuiltReport.Veeam.VBR.Resources.psd1'
}
Import-LocalizedData @importLocalizedDataParams -ErrorAction SilentlyContinue

#Fallback to en-US culture strings
if (-not (Test-Path -Path 'Variable:\localized'))
{
    $importLocalizedDataParams['UICulture'] = 'en-US'
    Import-LocalizedData @importLocalizedDataParams -ErrorAction Stop
}

# Get public and private function definition files and dot source them
$Public = @(Get-ChildItem -Path $PSScriptRoot\Src\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Src\Private\*.ps1 -ErrorAction SilentlyContinue)

foreach ($Module in @($Public + $Private)) {
    try {
        . $Module.FullName
    } catch {
        Write-Error -Message "Failed to import function $($Module.FullName): $_"
    }
}

Export-ModuleMember -Function $Public.BaseName
Export-ModuleMember -Function $Private.BaseName