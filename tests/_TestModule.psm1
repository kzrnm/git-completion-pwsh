#Requires -Module Pester, git-completion

function Initialize-Home {
    $script:envHOMEBak = $env:HOME
    
    mkdir ($env:HOME = "$TestDrive/home")
    "[user]
email = Kitazato@example.com
name = 1000yen" > "$env:HOME/.gitconfig"
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

    $WordPosition = $Words.Length
    if ($WordPosition -notmatch '\s$') {
        $WordPosition--
    }
    $CursorPosition = $line.Length
    $CurrentWord = $Words[-1]
    $PreviousWord = $Words[-2]

    return (Complete-Git `
            -CursorPosition $CursorPosition `
            -Words $Words `
            -WordPosition $WordPosition `
            -CurrentWord $CurrentWord `
            -PreviousWord $PreviousWord)
}

function Should-BeCompletion {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Scope='Function')]
    param(
        $ActualValue,
        [hashtable[]] $ExpectedValue,
        [string] $Because
    ) 
    <#
    .SYNOPSIS
        Asserts if collection equals expected completion
    #>

    if ($ActualValue.Count -ne $ExpectedValue.Count) {
        return [PSCustomObject]@{
            Succeeded      = $false
            FailureMessage = "Expected a collection with size $($ExpectedValue.Count), but got collection with size $($ActualValue.Count)$(if($Because) { " because $Because"})."
        }
    }

    $failures = @()

    for ($i = 0; $i -lt $ExpectedValue.Count; $i++) {
        $a = [System.Management.Automation.CompletionResult]$ActualValue[$i]
        $e = [PSCustomObject]$ExpectedValue[$i]

        if (
            ($a.CompletionText -ne $e.CompletionText) -or 
            ($a.ListItemText -ne $e.ListItemText) -or 
            ($a.ToolTip -ne $e.ToolTip) -or 
            ($a.ResultType -ne [System.Management.Automation.CompletionResultType]$e.ResultType)
        ) {
            $failures += [PSCustomObject]@{
                Index    = $i;
                Actual   = [PSCustomObject]@{
                    CompletionText = $a.CompletionText;
                    ListItemText   = $a.ListItemText;
                    ResultType     = $a.ResultType;
                    ToolTip        = $a.ToolTip;
                };
                Expected = $e;
            }
        }
    }

    if ($failures) {
        $message = ($failures | ForEach-Object {
                $i = $_.Index
                $a = $_.Actual
                $e = $_.Expected
                "At index:$i, Expected $e, but got $a"
            }
        ) -join ':'
        return [PSCustomObject]@{
            Succeeded      = $false
            FailureMessage = "$message$(if($Because) { " because $Because"})."
        }
    }

    return [PSCustomObject]@{
        Succeeded      = $true
        FailureMessage = $null
    }
}

Add-ShouldOperator -Name BeCompletion `
    -InternalName 'Should-BeCompletion' `
    -Test ${function:Should-BeCompletion} `
    -SupportsArrayInput

Export-ModuleMember -Function Complete-FromLine, Complete-Words, Initialize-Home, Restore-Home
