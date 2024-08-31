#Requires -Module Pester, git-completion

$ErrorActionPreference = 'Continue'

function Convert-ToKebabCase {
    param (
        [Parameter(ValueFromPipeline)]
        [string]$Text
    )
    process {
        ($Text -creplace '(?!^)([A-Z])', '-$1').ToLowerInvariant()
    }
}

function Initialize-Home {
    $script:GitCompletionSettings = @{
        IgnoreCase         = $false;
        ShowAllCommand     = $false;
        ShowAllOptions     = $false;
        AdditionalCommands = @();
        ExcludeCommands    = @();
    }

    $script:envHOMEBak = $env:HOME
    $env:GIT_COMPLETION_SHOW_ALL = ''
    $env:GIT_COMPLETION_SHOW_ALL_COMMANDS = ''

    mkdir ($env:HOME = "$TestDrive/home")
    "[user]`nemail = Kitazato@example.com`nname = 1000yen" | Out-File "$env:HOME/.gitconfig" -Encoding ascii
}
function Restore-Home {
    $env:HOME = $script:envHOMEBak

    $script:GitCompletionSettings = @{
        IgnoreCase         = $false;
        ShowAllCommand     = $false;
        ShowAllOptions     = $false;
        AdditionalCommands = @();
        ExcludeCommands    = @();
    }
}

function Initialize-SimpleRepo {
    [CmdletBinding(PositionalBinding)]
    param(
        $rootPath
    )

    Push-Location $rootPath
    git init --initial-branch=main
    git commit -m "initial" --allow-empty
    "echo world" | Out-File 'world.ps1'
    git add -A 2>$null
    git commit -m "World"
    Pop-Location
}
function Initialize-Remote {
    [CmdletBinding(PositionalBinding)]
    param(
        $rootPath,
        $remotePath
    )

    Push-Location $remotePath
    git init --initial-branch=main
    "Initial" | Out-File 'initial.txt'
    "echo hello" | Out-File 'hello.sh'
    git update-index --add --chmod=+x hello.sh
    git add -A 2>$null
    git commit -m "initial"
    git tag initial
    Pop-Location

    Push-Location $rootPath
    git init --initial-branch=main

    git remote add origin "$remotePath"
    git remote add ordinary "$remotePath"
    git remote add grm "$remotePath"

    git config set remotes.default "origin grm"
    git config set remotes.ors "origin ordinary"

    git pull origin main 2>$null
    git fetch ordinary 2>$null
    git fetch grm 2>$null
    mkdir Pwsh
    "echo world" | Out-File 'Pwsh/world.ps1'
    git add -A 2>$null
    git commit -m "World"
    Pop-Location
}

function Complete-FromLine {
    [OutputType([System.Management.Automation.CompletionResult[]])]
    param (
        [string][Parameter(ValueFromPipeline)] $line
    )

    return (Complete-Git -Words ($line -split '\s+'))
}

function writeObjectLine {
    param(
        [Parameter(Position = 0)]$Completion,
        [string] $Prefix = '',
        [string] $Suffix = ''
    )

    "$Prefix$(if($Completion){[PSCustomObject]@{
        CompletionText = $Completion.CompletionText;
        ListItemText   = $Completion.ListItemText;
        ResultType     = $Completion.ResultType;
        ToolTip        = $Completion.ToolTip;
    }})$Suffix"
}

function buildFailedMessage {
    [OutputType([string[]])]
    param (
        $ActualValue,
        [hashtable[]] $ExpectedValue
    )

    if (!$ActualValue) {
        if (!$ExpectedValue) {
            return @()
        }
        "The expected collection is not empty, but the resulting collection is empty."
        "Expected:"
        foreach ($e in $ExpectedValue) {
            writeObjectLine $e -Suffix ','
        }
        return
    }
    elseif ($null -eq $ExpectedValue) {
        "The expected collection is null."
    }

    if ($ActualValue.Count -ne $ExpectedValue.Count) {
        "The expected collection with size $($ExpectedValue.Count), but the resulting collection with size $($ActualValue.Count)."
    }

    $Length = [math]::Max($ExpectedValue.Length, $ActualValue.Length)
    for ($i = 0; $i -lt $Length ; $i++) {
        $a = [System.Management.Automation.CompletionResult]$ActualValue[$i]
        $e = $ExpectedValue[$i]

        if (
            ($a.CompletionText -ne $e.CompletionText) -or 
            ($a.ListItemText -ne $e.ListItemText) -or 
            ($a.ToolTip -ne $e.ToolTip) -or 
            ($a.ResultType -ne [System.Management.Automation.CompletionResultType]$e.ResultType)
        ) {
            $head = "At index:$i,expected "
            $second = "but actual "
            $second = ' ' * ($head.Length - $second.Length) + $second

            writeObjectLine $e -Prefix $head
            writeObjectLine $a -Prefix $second
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

Export-ModuleMember -Function Complete-FromLine, Initialize-Home, Restore-Home,
Convert-ToKebabCase,
testRevList,
Initialize-Remote, Initialize-SimpleRepo
