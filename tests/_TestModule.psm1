#Requires -Module Pester, git-completion

function Initialize-Home {
    $script:envHOMEBak = $env:HOME
    $env:GIT_COMPLETION_SHOW_ALL = ''
    $env:GIT_COMPLETION_SHOW_ALL_COMMANDS = ''

    mkdir ($env:HOME = "$TestDrive/home")
    "[user]`nemail = Kitazato@example.com`nname = 1000yen" | Out-File "$env:HOME/.gitconfig" -Encoding ascii
}
function Restore-Home {
    $env:HOME = $script:envHOMEBak
}

function Complete-FromLine {
    [OutputType([System.Management.Automation.CompletionResult[]])]
    param (
        [string][Parameter(ValueFromPipeline)] $line
    )

    return (Complete-Words ($line -split '\s+'))
}


function Complete-Words {
    [OutputType([System.Management.Automation.CompletionResult[]])]
    param (
        [Parameter(Mandatory)][AllowEmptyCollection()][AllowEmptyString()][string[]]$Words
    )

    return (Complete-Git -Words $Words)
}

function buildFailedMessage {
    [OutputType([string[]])]
    param (
        [Parameter(Mandatory)] $ActualValue,
        [Parameter(Mandatory)][hashtable[]] $ExpectedValue
    )

    if ($ActualValue.Count -ne $ExpectedValue.Count) {
        "Expected collection with size $($ExpectedValue.Count), but got collection with size $($ActualValue.Count)."
    }

    $Length = [math]::Min($ExpectedValue.Length, $ActualValue.Length)
    for ($i = 0; $i -lt $Length ; $i++) {
        $a = [System.Management.Automation.CompletionResult]$ActualValue[$i]
        $e = $ExpectedValue[$i]

        if (
            ($a.CompletionText -ne $e.CompletionText) -or 
            ($a.ListItemText -ne $e.ListItemText) -or 
            ($a.ToolTip -ne $e.ToolTip) -or 
            ($a.ResultType -ne [System.Management.Automation.CompletionResultType]$e.ResultType)
        ) {
            $head = "At index:$i,expected"
            $second = "but got"
            $second = ' ' * ($head.Length - $second.Length) + $second

            "$head $([PSCustomObject]@{
                    CompletionText = $e.CompletionText;
                    ListItemText   = $e.ListItemText;
                    ResultType     = $e.ResultType;
                    ToolTip        = $e.ToolTip;
                })"
            "$second $([PSCustomObject]@{
                    CompletionText = $a.CompletionText;
                    ListItemText   = $a.ListItemText;
                    ResultType     = $a.ResultType;
                    ToolTip        = $a.ToolTip;
                })"
        }
    }
}

function Should-BeCompletion {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Scope = 'Function')]
    param(
        $ActualValue,
        [hashtable[]] $ExpectedValue,
        [string] $Because
    ) 
    <#
    .SYNOPSIS
        Asserts if collection equals expected completion
    #>

    $message = @(buildFailedMessage -ActualValue $ActualValue -ExpectedValue $ExpectedValue)

    if ($message) {
        if ($Because) {
            $message += "because $Because"
        }
        return [PSCustomObject]@{
            Succeeded      = $false
            FailureMessage = $message -join "`n"
        }
    }

    return [PSCustomObject]@{
        Succeeded      = $true
        FailureMessage = $null
    }
}

Add-ShouldOperator -Name BeCompletion `
    -Test ${function:Should-BeCompletion} `
    -SupportsArrayInput

Export-ModuleMember -Function Complete-FromLine, Complete-Words, Initialize-Home, Restore-Home
