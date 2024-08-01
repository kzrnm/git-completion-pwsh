function completeList {
    [OutputType([System.Management.Automation.CompletionResult[]])]
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]
        $Candidates
    )
    $Candidates |
    Where-Object {
        if (-not $script:CurrentWord) {
            return $true
        }
        elseif ($_ -is [System.Management.Automation.CompletionResult]) {
            $name = $_.ListItemText
        }
        else {
            $name = $_
        }
        $name.StartsWith($script:CurrentWord)
    } |
    ForEach-Object { 
        [System.Management.Automation.CompletionResult]::new(
            "$_",
            "$_",
            "ParameterName",
            "$_"
        )
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
        [string]$Current = $null,
        [string]$Prefix = '',
        [string]$Suffix = '',
        [Parameter(ValueFromRemainingArguments)]
        [string[]]
        $Candidates
    )

    if (-not $Current) {
        $Current = $script:CurrentWord
    }

    switch -Wildcard ($Current) {
        '*=' {  
            return @()
        }
        '--no-*' {
            return ($Candidates | ForEach-Object {
                    if ($_ -ne '--') {
                        $c = "$_$Suffix"
                        if ($c -like "$Current*") {
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
                    if ('--no-' -like "$Current*") {
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
                    if ($c -like "$Current*") {
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
