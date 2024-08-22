function completeList {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([System.Management.Automation.CompletionResult[]])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]
        $Current,
        [string]
        $Suffix = '',
        [scriptblock]
        $DescriptionBuilder = $null,
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]
        $Candidates
    )
    $Candidates |
    Where-Object {
        if (-not $Current) {
            return $true
        }
        $_.StartsWith($Current)
    } |
    ForEach-Object {
        $desc = $null
        if ($DescriptionBuilder) {
            $desc = $DescriptionBuilder.Invoke($_)
        }
        if (-not $desc) {
            $desc = "$_"
        }

        [System.Management.Automation.CompletionResult]::new(
            "$_$Suffix",
            "$_",
            'ParameterName',
            $desc
        )
    }
}

function filterCompletionResult {
    [OutputType([System.Management.Automation.CompletionResult[]])]
    param (
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]
        $Current,
        [Parameter(ValueFromPipeline)]
        $Completion
    )

    process {
        if (($Completion -is [System.Management.Automation.CompletionResult]) -and $Completion.ListItemText.StartsWith($Current)) {
            return $Completion
        }
        elseif (($Completion -is [string]) -and $Completion.StartsWith($Current)) {
            return $Completion
        }
    }
}

# Generates completion reply, appending a space to possible completion words,
# if necessary.
# It accepts 1 to 4 arguments:
# 1: List of possible completion words.
# 2: A prefix to be added to each possible completion word (optional).
# 3: Generate possible completion matches for this word (optional).
# 4: A suffix to be appended to each possible completion word (optional).
function gitcomp {
    [OutputType([System.Management.Automation.CompletionResult[]])]
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        $Current,
        [string]$Prefix = '',
        [string]$Suffix = '',
        [scriptblock]
        $DescriptionBuilder = $null,
        [Parameter(ValueFromPipeline)]
        [string]
        $Candidate
    )

    begin {
        switch -Wildcard ($Current) {
            '*=' { $Type = -1 }
            '--no-*' { $Type = 1 }
            Default { $Type = 0 }
        }
    }

    process {
        $desc = $null
        if ($DescriptionBuilder) {
            $desc = $DescriptionBuilder.InvokeWithContext(
                $null,
                @([psvariable]::new('_', $Candidate)),
                @($Candidate)
            )
        }
        
        $cw = "$Candidate$Suffix"
        $c = "$Prefix$cw"
        if (-not $desc) {
            $desc = "$c"
        }

        switch ($Type) {
            -1 {  }
            1 { 
                if ($cw.StartsWith($Current)) {
                    [System.Management.Automation.CompletionResult]::new(
                        $c,
                        $c,
                        'ParameterName',
                        $desc
                    )
                }
            }
            Default {
                if ($Candidate -eq '--') {
                    if ('--no-'.StartsWith($Current)) {
                        [System.Management.Automation.CompletionResult]::new(
                            "--no-",
                            "--no-...$Suffix",
                            'Text',
                            "--no-...$Suffix"
                        )
                    }
                    $Type = = -1
                }
                else {
                    if ($cw.StartsWith($Current)) {
                        [System.Management.Automation.CompletionResult]::new(
                            $c,
                            $c,
                            'ParameterName',
                            $desc
                        )
                    }
                }
            }
        }   
    }
}
