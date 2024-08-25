using namespace System.Collections.Generic;

param(
    [Parameter(Position = 0, Mandatory)][string]$Command,
    [Parameter(ValueFromRemainingArguments)][string[]]$Subcommands,
    [switch] $NoParser
)

# e.g.
# tools/description.ps1 config
# tools/description.ps1 add

$ErrorActionPreference = 'Stop'
$CamelCommand = $Command -replace '^.', { $_.Value.ToUpper() }

if (-not $Subcommands) {
    $Subcommands = (git $Command --git-completion-helper-all) -split '\s+'
    if ($Subcommands | Where-Object { $_.StartsWith('-') }) {
        $Subcommands = @()
    }
}

function Write-Parser {
    param(
        [Parameter(Mandatory)]$line,
        [switch] $NoNewline
    )
    if (-not $NoParser) {
        Write-Host $line -NoNewline:$NoNewline
    }
}

function Convert-FromGitHelp {
    param (
        [Parameter(Position = 0)]
        [string[]]
        $Help,
        [string]
        $Subcommand = ''
    )

    $ShortToLong = [Dictionary[string, string]]::new()
    $Descriptions = [Dictionary[string, string]]::new()
    $Prev = $null

    foreach ($line in $Help) {
        if ($Prev) {
            $Descriptions[$Prev] = $line.Trim()
            $Prev = $null
            Write-Parser "`e[32m$line`e[0m"
        }
        elseif ($line -match '\s+-') {
            if ($line -match '(-[^-])(,.*)(--\S+)(.*)') {
                $long = $Matches[3].Replace('[no-]', '')
                $remaining = $Matches[4]
                $ShortToLong[$Matches[1]] = $long
                $key = $long
                
                Write-Parser "`e[35m$($Matches[1])`e[0m$($Matches[2])`e[36m$($Matches[3])`e[0m" -NoNewline
            }
            elseif ($line -match '(--\S+)(.*)') {
                $long = $Matches[1].Replace('[no-]', '')
                $remaining = $Matches[2]
                $key = $long
                
                Write-Parser "`e[36m$($Matches[1])`e[0m" -NoNewline
            }
            elseif ($line -match '(-\S)(.*)') {
                $key = $Matches[1]
                $remaining = $Matches[2]
            }
            else {
                throw "!? $line !?"
            }

            while ($remaining -match '^(\s*<[^>]+>\.*)(.*)') {
                Write-Parser $Matches[1] -NoNewline
                $remaining = $Matches[2]
            }

            Write-Parser "`e[32m$remaining`e[0m"
            $desc = $remaining.Trim()
            
            if ($desc) {
                $Descriptions[$key] = $desc
            }
            else {
                $Prev = $key
            }
        }
        else {
            Write-Parser $line
        }
    }
    
    return [PSCustomObject]@{
        Subcommand   = $Subcommand;
        ShortToLong  = $ShortToLong;
        Descriptions = $Descriptions;
    }
}

function buildSwitch {
    param (
        [Parameter(Position = 0)]
        [Dictionary[string, hashtable]]
        $result
    )

    $cases = @()
    foreach ($k in $result.Keys) {
        $v = $result[$k]

        $c = "        '$k' {"

        if ($v.Count -GT 1) {
            $c += '
            switch ($Subcommand) {'
            $vv = $v.Keys | ForEach-Object {
                [PSCustomObject]@{
                    Long = $_;
                    Sub  = $v[$_];
                }
            } | Sort-Object { $_.Sub.Length }
            $c += $vv | Select-Object -SkipLast 1 | ForEach-Object {
                $l = $_.Long.Replace("'", "''")
                $_.Sub | ForEach-Object {
                    "
                '$($_)' { '$l' }"
                }
            }
            $c += $vv | Select-Object -Last 1 | ForEach-Object {
                $l = $_.Long.Replace("'", "''")
                "
                Default { '$l' }"
            }
            $c += '
            }
        }'
        }
        else {
            $l = $v.Keys | Select-Object -First 1
            $c += " '$l' }"
        }
        $cases += $c
    }

    return $cases
}

function buildShortToLong {
    param (
        [Parameter(Position = 0)]
        $Options
    )

    $result = [Dictionary[string, hashtable]]::new()
    foreach ($s in $Options) {
        foreach ($p in $s.ShortToLong.GetEnumerator()) {
            if ($result.ContainsKey($p.Key)) {
                $inner = $result[$p.Key]
                if ($inner.ContainsKey($p.Value)) {
                    $inner[$p.Value] += $s.Subcommand
                }
                else {
                    $inner[$p.Value] = @($s.Subcommand)
                }
            }
            else {
                $result[$p.Key] = @{$p.Value = @($s.Subcommand); }
            }
        }
    }

    return (buildSwitch $result)
}

function buildDescriptions {
    param (
        [Parameter(Position = 0)]
        $Options
    )

    $result = [Dictionary[string, hashtable]]::new()
    foreach ($s in $Options) {
        foreach ($p in $s.Descriptions.GetEnumerator()) {
            if ($result.ContainsKey($p.Key)) {
                $inner = $result[$p.Key]
                if ($inner.ContainsKey($p.Value)) {
                    $inner[$p.Value] += $s.Subcommand
                }
                else {
                    $inner[$p.Value] = @($s.Subcommand)
                }
            }
            else {
                $result[$p.Key] = @{$p.Value = @($s.Subcommand); }
            }
        }
    }

    return (buildSwitch $result)
}

if ($Subcommands) {
    $Options = foreach ($Subcommand in $Subcommands) {
        Convert-FromGitHelp (Invoke-Expression "git $Command $Subcommand -h") -Subcommand $Subcommand
    }
}
else {
    $Options = @(Convert-FromGitHelp (Invoke-Expression "git $Command -h"))
}

if ($Subcommands) {
    $shortArray = '$shortOptions = switch ($Subcommand) {'
    foreach ($s in $Options) {
        $sop = ($s.ShortToLong.Keys | Sort-Object | ForEach-Object { "'$_'" }) -join ', '
        $shortArray += "
        '$($s.Subcommand)' { @($sop) }"
    }
    $shortArray += '
        Default { @() }
    }
    $shortOptions'
}
else {
    $shortArray = ($Options | ForEach-Object ShortToLong | ForEach-Object Keys | Sort-Object | ForEach-Object { "'$_'" }) -join ', '
}

return "using namespace System.Management.Automation;

function Convert-Git${CamelCommand}ShortToLong {
    param(
        [Parameter(Position = 0, Mandatory)][string]`$Short,
        [string]`$Subcommand = ''
    )
    switch(`$Short) {
$((buildShortToLong $Options) -join "`n")
    }
}

function Get-Git${CamelCommand}ShortOptions {
    [CmdletBinding()]
    [OutputType([CompletionResult[]])]
    param(
        [string]`$Subcommand = ''
    )

    $shortArray | ForEach-Object {
        `$long = (Convert-Git${CamelCommand}ShortToLong `$_ -Subcommand `$Subcommand)
        `$desc = (Get-Git${CamelCommand}OptionsDescription `$long)
        if (-not `$desc) {
            `$desc = `$_
        }
        [CompletionResult]::new(
            `$_,
            `$_,
            'ParameterName',
            `$desc
        )
    }
    `$script:__helpCompletion
}

function Get-Git${CamelCommand}OptionsDescription {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Position = 0)]
        [string]`$Current,
        [string]`$Subcommand = ''
    )

    if (`$Current.StartsWith('--no-')) {
        `$positive = Get-Git${CamelCommand}OptionsDescription ('--' + `$Current.Substring('--no-'.Length)) -Subcommand `$Subcommand
        if (`$positive) {
            return `"[NO] `$positive`"
        }
        return `$null
    }

    switch (`$Current) {
$((buildDescriptions $Options) -join "`n")
    }
}
"