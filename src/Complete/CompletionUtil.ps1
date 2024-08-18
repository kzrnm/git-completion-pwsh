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
            "ParameterName",
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
        [System.Management.Automation.CompletionResult]
        [Parameter(ValueFromPipeline)]
        $Completion
    )

    process {
        if ($Completion.CompletionText.StartsWith($Current)) {
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
        [Parameter(ValueFromRemainingArguments)]
        [string[]]
        $Candidates
    )

    switch -Wildcard ($Current) {
        '*=' {  
            return @()
        }
        '--no-*' {
            return ($Candidates | ForEach-Object {
                    if ($_ -ne '--') {
                        $c = "$_$Suffix"
                        if ($c.StartsWith($Current)) {
                            $c = "$Prefix$c"
                            [System.Management.Automation.CompletionResult]::new(
                                $c,
                                $c,
                                'Text',
                                $c
                            )
                        }
                    }
                })
        }
        Default {
            foreach ($_ in $Candidates) {
                if ($_ -eq '--') {
                    if ('--no-'.StartsWith($Current)) {
                        [System.Management.Automation.CompletionResult]::new(
                            "--no-",
                            "--no-...$Suffix",
                            'Text',
                            $c
                        )
                    }
                    break
                }
                else {
                    $c = "$_$Suffix"
                    if ($c.StartsWith($Current)) {
                        $c = "$Prefix$c"
                        [System.Management.Automation.CompletionResult]::new(
                            $c,
                            $c,
                            'Text',
                            $c
                        )
                    }
                }
            }
        }
    }

    return
}
