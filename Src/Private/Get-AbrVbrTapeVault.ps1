
function Get-AbrVbrTapeVault {
    <#
    .SYNOPSIS
        Used by As Built Report to retrieve Veeam Tape Vault Information
    .DESCRIPTION
        Documents the configuration of Veeam VBR in Word/HTML/Text formats using PScribo.
    .NOTES
        Version:        0.8.0
        Author:         Jonathan Colon
        Twitter:        @jcolonfzenpr
        Github:         rebelinux
        Credits:        Iain Brighton (@iainbrighton) - PScribo module

    .LINK
        https://github.com/AsBuiltReport/AsBuiltReport.Veeam.VBR
    #>
    [CmdletBinding()]
    param (

    )

    begin {
        Write-PscriboMessage "Discovering Veeam VBR Tape Vault information from $System."
    }

    process {
        try {
            if (Get-VBRInstalledLicense | Where-Object {$_.Edition -in @("EnterprisePlus","Enterprise") -and $_.Status -ne "Expired"}) {
                if ((Get-VBRTapeVault).count -gt 0) {
                    Section -Style Heading3 'Tape Vaults' {
                        $OutObj = @()
                        try {
                            $TapeObjs = Get-VBRTapeVault
                            foreach ($TapeObj in $TapeObjs) {
                                try {
                                    Write-PscriboMessage "Discovered $($TapeObj.Name) Type Vault."
                                    $inObj = [ordered] @{
                                        'Name' = $TapeObj.Name
                                        'Description' = $TapeObj.Description
                                        'Automatic Protect' = ConvertTo-TextYN $TapeObj.Protect
                                        'Location' = ConvertTo-EmptyToFiller (Get-VBRLocation -Object $TapeObj -ErrorAction SilentlyContinue)
                                    }
                                    $OutObj += [pscustomobject]$inobj
                                }
                                catch {
                                    Write-PscriboMessage -IsWarning "Tape Vaults $($TapeObj.Name) Table: $($_.Exception.Message)"
                                }
                            }

                            if ($HealthCheck.Tape.BestPractice) {
                                $OutObj | Where-Object { $Null -like $_.'Description' } | Set-Style -Style Warning -Property 'Description'
                                $OutObj | Where-Object { $_.'Description' -match "Created by" } | Set-Style -Style Warning -Property 'Description'
                            }

                            $TableParams = @{
                                Name = "Tape Vault - $VeeamBackupServer"
                                List = $false
                                ColumnWidths = 32, 32, 16, 20
                            }

                            if ($Report.ShowTableCaptions) {
                                $TableParams['Caption'] = "- $($TableParams.Name)"
                            }
                            $OutObj | Table @TableParams
                            if ($HealthCheck.Tape.BestPractice) {
                                if ($OutObj | Where-Object { $_.'Description' -match 'Created by' -or $Null -like $_.'Description'}) {
                                    Paragraph "Health Check:" -Bold -Underline
                                    BlankLine
                                    Paragraph {
                                        Text "Best Practice:" -Bold
                                        Text "It is a general rule of good practice to establish well-defined descriptions. This helps to speed up the fault identification process, as well as enabling better documentation of the environment."
                                    }
                                }
                            }
                        }
                        catch {
                            Write-PscriboMessage -IsWarning "Tape Vaults Section: $($_.Exception.Message)"
                        }
                    }
                }
            }
        }
        catch {
            Write-PscriboMessage -IsWarning "Tape Vaults Document: $($_.Exception.Message)"
        }
    }
    end {}

}