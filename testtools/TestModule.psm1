﻿#Requires -Module Pester

using namespace System.Management.Automation;

$ErrorActionPreference = 'Continue'

. "$PSScriptRoot/ConvertCompletion.ps1"

function ConvertTo-KebabCase {
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
        CheckoutNoGuess    = $false
        AdditionalCommands = @();
        ExcludeCommands    = @();
    }

    $script:envHOMEBak = $env:HOME

    mkdir ($env:HOME = "$TestDrive/home")
    "[user]`nemail = Kitazato@example.com`nname = 1000yen" | Out-File "$env:HOME/.gitconfig" -Encoding ascii
}
function Restore-Home {
    Get-ChildItem "$TestDrive/*" | Remove-Item -Recurse -Force
    $env:HOME = $script:envHOMEBak
}

function Initialize-SimpleRepo {
    [CmdletBinding(PositionalBinding)]
    param(
        $rootPath
    )

    Push-Location $rootPath
    git init --initial-branch=main
    git commit -m "initial" --allow-empty
    mkdir Pwsh | Out-Null
    'Pwsh/ign*' > 'Pwsh/ignored'
    'Pwsh/ign*' | Out-File '.gitignore' -Encoding ascii
    'echo world' > 'Pwsh/world.ps1'
    git add -A 2>$null
    git commit -m "World"
    git config alias.sw "switch"
    git config alias.swf "sw -f"
    git config --file test.config alias.ll "!ls"
    Pop-Location
}
function Initialize-Remote {
    [CmdletBinding(PositionalBinding)]
    param(
        $rootPath,
        $remotePath
    )

    $ProgressPreferenceBak = $global:ProgressPreference
    $global:ProgressPreference = "SilentlyContinue"
    Expand-Archive "$PSScriptRoot/RemoteRepo.zip" -DestinationPath $remotePath
    $global:ProgressPreference = $ProgressPreferenceBak

    Push-Location $rootPath
    git init --initial-branch=main

    git remote add origin "$remotePath"
    git remote add ordinary "$remotePath"
    git remote add grm "$remotePath"

    git config set remotes.default "origin grm"
    git config set remotes.ors "origin ordinary"

    git fetch origin --tags 2>$null
    git fetch ordinary 2>$null
    git fetch grm 2>$null
    git reset origin/develop --hard 2>$null
    git tag initial
    'Pwsh/ign*' > 'Pwsh/ignored'
    Pop-Location
}

function Initialize-FilesRepo {
    [CmdletBinding(PositionalBinding)]
    param(
        $rootPath,
        $remotePath
    )

    if ($remotePath) {
        Initialize-Remote $rootPath $remotePath
    }
    else {
        Initialize-SimpleRepo $rootPath
    }

    Push-Location $rootPath
    New-Item "$TestDrive/gitRoot/Pwsh/OptionLike/-foo.ps1" -ItemType File -Force
    New-Item "$TestDrive/gitRoot/Dr.Wily" -ItemType File
    New-Item "$TestDrive/gitRoot/Aquarion Evol" -ItemType Directory
    New-Item "$TestDrive/gitRoot/Aquarion Evol/Evol" -ItemType File
    New-Item "$TestDrive/gitRoot/Aquarion Evol/Ancient" -ItemType Directory
    New-Item "$TestDrive/gitRoot/Aquarion Evol/Ancient/Soler" -ItemType File
    git add "$TestDrive/gitRoot/Dr.Wily" "$TestDrive/gitRoot/Aquarion Evol/" "$TestDrive/gitRoot/Pwsh/OptionLike/-foo.ps1"
    git commit -m "Start"
    'X' > "$TestDrive/gitRoot/Dr.Wily"
    'LOVE' > "$TestDrive/gitRoot/Aquarion Evol/Evol"
    '-bar' > "$TestDrive/gitRoot/Pwsh/OptionLike/-foo.ps1"

    New-Item "$TestDrive/gitRoot/Pwsh/L1/L2/🏪.ps1" -ItemType File -Force
    New-Item "$TestDrive/gitRoot/漢字" -ItemType Directory
    New-Item "$TestDrive/gitRoot/漢``'帝　国'" -ItemType File
    New-Item "$TestDrive/gitRoot/Deava" -ItemType File
    New-Item "$TestDrive/gitRoot/Aquarion Evol/Gepard" -ItemType File
    New-Item "$TestDrive/gitRoot/Aquarion Evol/Gepada" -ItemType File
    New-Item "$TestDrive/gitRoot/BigInteger/BigInteger.cs" -ItemType File -Force
    New-Item "$TestDrive/gitRoot/BigInteger/BigInteger.csproj" -ItemType File
    New-Item "$TestDrive/gitRoot/BigInteger/BigInteger.csx" -ItemType File
    Pop-Location
}

function Complete-FromLine {
    [OutputType([CompletionResult[]])]
    param (
        [string][Parameter(ValueFromPipeline)] $line,
        [string]$Right = ''
    )

    switch -Wildcard ($line) {
        'gitk *' {
            Set-Alias Complete Complete-Gitk -Scope Local
            break
        }
        'git *' {
            Set-Alias Complete Complete-Git -Scope Local
            break
        }
        Default { throw 'Invalid input' }
    }

    $CommandAst = [System.Management.Automation.Language.Parser]::ParseInput($line + $Right, [ref]$null, [ref]$null).EndBlock.Statements.PipelineElements
    $CursorPosition = $line.Length
    return (Complete -CommandAst $CommandAst -CursorPosition $CursorPosition)
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
        [array] $ExpectedValue
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
        $a = [CompletionResult]$ActualValue[$i]
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
        [array] $ExpectedValue,
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

$script:RemoteCommits = @{
    'HEAD'             = @{
        ListItemText = 'HEAD';
        ToolTip      = '0b399df World';
    };
    'FETCH_HEAD'       = @{
        ListItemText = 'FETCH_HEAD';
        ToolTip      = '0b399df World';
    };
    'initial'          = @{
        ListItemText = 'initial';
        ToolTip      = '0b399df World';
    };
    'main'             = @{
        ListItemText = 'main';
        ToolTip      = '0b399df World';
    };
    'origin/develop'   = @{
        ListItemText = 'origin/develop';
        ToolTip      = '0b399df World';
    };
    'ordinary/develop' = @{
        ListItemText = 'ordinary/develop';
        ToolTip      = '0b399df World';
    };
    'grm/develop'      = @{
        ListItemText = 'grm/develop';
        ToolTip      = '0b399df World';
    };
    'origin/HEAD'   = @{
        ListItemText = 'origin/HEAD';
        ToolTip      = '0b399df World';
    };
    'ordinary/HEAD' = @{
        ListItemText = 'ordinary/HEAD';
        ToolTip      = '0b399df World';
    };
    'grm/HEAD'      = @{
        ListItemText = 'grm/HEAD';
        ToolTip      = '0b399df World';
    };
    'zeta'             = @{
        ListItemText = 'zeta';
        ToolTip      = 'f36f2be Ζ';
    };
}

Add-ShouldOperator -Name BeCompletion `
    -Test ${function:Should-BeCompletion} `
    -SupportsArrayInput

Export-ModuleMember `
    -Function Complete-FromLine, Initialize-Home, Restore-Home, `
    ConvertTo-KebabCase, ConvertTo-Completion, `
    Initialize-Remote, Initialize-SimpleRepo, Initialize-FilesRepo `
    -Variable 'RemoteCommits'
