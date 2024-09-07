function ConvertTo-Completion {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        $TextOrObject,
        [Parameter(Mandatory)]
        [System.Management.Automation.CompletionResultType]
        $ResultType,
        $CompletionText = $null,
        $ToolTip = $null
    )

    process {
        if ($TextOrObject -is [string]) {
            $Object = @{
                CompletionText = $TextOrObject;
                ListItemText   = $TextOrObject;
                ResultType     = $ResultType;
                ToolTip        = $TextOrObject;
            }

            if ($CompletionText -is [string]) {
                $Object.CompletionText = $CompletionText
            }
            elseif ($CompletionText -is [scriptblock]) {
                $Object.CompletionText = [string]$CompletionText.InvokeWithContext(
                    $null,
                    [psvariable]::new('_', $TextOrObject),
                    @($TextOrObject)
                )
            }

            if ($ToolTip -is [string]) {
                $Object.ToolTip = $ToolTip
            }
            elseif ($ToolTip -is [scriptblock]) {
                $Object.ToolTip = [string]$ToolTip.InvokeWithContext(
                    $null,
                    [psvariable]::new('_', $TextOrObject),
                    @($TextOrObject)
                )
            }
        }
        else {
            $Object = $TextOrObject

            if (!$Object.ResultType) {
                $Object.ResultType = $ResultType
            }

            if (!$Object.CompletionText) {
                if ($CompletionText -is [string]) {
                    $Object.CompletionText = $CompletionText
                }
                elseif ($CompletionText -is [scriptblock]) {
                    $Object.CompletionText = [string]$CompletionText.InvokeWithContext(
                        $null,
                        [psvariable]::new('_', $TextOrObject.ListItemText),
                        @($TextOrObject.ListItemText)
                    )
                }
                else {
                    $Object.CompletionText = $TextOrObject.ListItemText
                }
            }

            if (!$Object.ToolTip) {
                if ($ToolTip -is [string]) {
                    $Object.ToolTip = $ToolTip
                }
                elseif ($ToolTip -is [scriptblock]) {
                    $Object.ToolTip = [string]$ToolTip.InvokeWithContext(
                        $null,
                        [psvariable]::new('_', $TextOrObject.ListItemText),
                        @($TextOrObject.ListItemText)
                    )
                }
                else {
                    $Object.ToolTip = $TextOrObject.ListItemText
                }
            }
        }

        $Object
    }
}