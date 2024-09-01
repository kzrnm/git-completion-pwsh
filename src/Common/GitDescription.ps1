using namespace System.Collections.Generic;
using namespace System.Management.Automation;

# Options
$__helpCompletion = [System.Management.Automation.CompletionResult]::new(
    '-h',
    '-h',
    'ParameterName',
    'show help'
)

function Write-HostDummy {}

function trimDescription {
    param (
        [Parameter(Mandatory, Position = 0)][AllowEmptyString()][string]$Text
    )

    $removed = [System.Text.StringBuilder]::new($Text.Length)

    while ($Text) {
        if ($Text -cmatch '^(\s+)(.*)') {
            $removed.Append($Matches[1])
            $Text = $Matches[2]
        }
        elseif ($Text.StartsWith('<')) {
            $b = removeLeadingBracket $Text -Begin '<' -End '>'
            $removed.Append($b.Removed)
            $Text = $b.Remaining

            if ($Text.Length -le 1) {
                $removed.Append($Text)
                $Text = ''
            }
        }
        elseif ($Text.StartsWith('[')) {
            $b = removeLeadingBracket $Text -Begin '[' -End ']'
            $removed.Append($b.Removed)
            $Text = $b.Remaining
        }
        elseif ($Text.StartsWith('(+|-)x')) {
            $removed.Append('(+|-)x')
            $Text = $Text.Substring('(+|-)x'.Length)
            continue
        }
        elseif ($Text -ceq '...') {
            $removed.Append($Text)
            $Text = ''
        }
        elseif ($Text -cmatch '^(\(?[\w-]+(\|[\w-]+)+\))(.*)') {
            $removed.Append($Matches[1])
            $Text = $Matches[3]
        }
        else { break }
    }

    # while ($remaining -match '^(\s*(<[^>]+>|?)\.*)(.*)') {
    #     Write-HostParsing $Matches[1] -NoNewline
    #     $remaining = $Matches[4]
    # }

    return [PSCustomObject]@{
        Removed   = $removed.ToString()
        Remaining = $Text
    }
}

function removeLeadingBracket {
    param (
        [Parameter(Mandatory, Position = 0)][string]$Text,
        [char]$Begin = '[',
        [char]$End = ']'
    )

    $removed = [System.Text.StringBuilder]::new($Text.Length)
    $cnt = 0
    for ($i = 0; $i -lt $Text.Length; $i++) {
        $c = $Text[$i]
        if ($c -ceq $Begin) {
            $cnt++
        }

        if ($cnt -eq 0) {
            break
        }
        $removed.Append($c)

        if ($c -ceq $End) {
            $cnt--
        }
    }

    return [PSCustomObject]@{
        Removed   = $removed.ToString()
        Remaining = $Text.Substring($i)
    }
}

function colorBracket {
    param (
        [Parameter(Mandatory, Position = 0)][string]$Text,
        [char]$Begin = '[',
        [char]$End = ']'
    )

    $removed = [System.Text.StringBuilder]::new($Text.Length)
    $colored = [System.Text.StringBuilder]::new($Text.Length)
    $cnt = 0
    for ($i = 0; $i -lt $Text.Length; $i++) {
        $c = $Text[$i]
        if ($c -ceq $Begin) {
            if ($cnt -eq 0) {
                $colored.Append("`e[43m")
            }
            $cnt++
        }

        if ($cnt -eq 0) {
            $removed.Append($c)
        }
        $colored.Append($c)

        if ($c -ceq $End) {
            $cnt--
            if ($cnt -eq 0) {
                $colored.Append("`e[40m")
            }
        }
    }

    return [PSCustomObject]@{
        Removed = $removed.ToString()
        Colored = $colored.ToString()
    }
}

function Convert-ToGitHelpOptions {
    [OutputType([GitHelpOptions])]
    param (
        [Parameter(Position = 0)]
        [string[]]
        $Help,
        [switch] $ShowParser
    )

    if ($ShowParser) {
        Set-Alias Write-HostParsing Write-Host -Scope Local
    }
    else {
        Set-Alias Write-HostParsing Write-HostDummy -Scope Local
    }

    $longDescriptions = [Dictionary[string, string]]::new()
    $shortDescriptions = [Dictionary[string, string]]::new()
    $Prev = $false
    $long = $null
    $short = $null

    function Add-Description {
        param (
            [Parameter(Mandatory, Position = 0)][string]$Description
        )
        if ($long) { $longDescriptions[$long] = $Description }
        if ($short) {
            if ($short -ceq '-NUM') {
                0..9 | ForEach-Object {
                    $shortDescriptions["-$_"] = $Description.Replace('NUM', "$_")
                }
            }
            else {
                $shortDescriptions[$short] = $Description
            }
        }
    }

    foreach ($line in $Help) {
        if ($Prev) {
            Add-Description $line.Trim()
            $Prev = $false
            Write-HostParsing "`e[32m$line`e[0m"
        }
        elseif ($line -match '^(\s+)(-.*)') {
            Write-HostParsing $Matches[1] -NoNewline
            $line = $Matches[2]
            $long = $null
            $short = $null
            if ($line -match '^((-[^-])(,?\s*))?(--\S+)(.*)') {
                $short = $Matches[2]
                if ($short) {
                    Write-HostParsing "`e[35m$($short)`e[0m$($Matches[3])" -NoNewline
                }

                $bLong = colorBracket $Matches[4]
                $long = $bLong.Removed
                $coloredLong = $bLong.Colored

                $remaining = $Matches[5]

                Write-HostParsing "`e[36m$coloredLong`e[0m" -NoNewline
            }
            elseif ($line -match '^-NUM(.*)') {
                $short = '-NUM'
                $remaining = $Matches[1]
                Write-HostParsing "`e[35m-NUM`e[0m" -NoNewline
            }
            elseif ($line -match '^(-\S)(=?\[[^\]]+\])?(.*)') {
                $short = $Matches[1]
                $value = $Matches[2]
                $remaining = $Matches[3]

                Write-HostParsing "`e[35m$short" -NoNewline
                if ($value) { Write-HostDummy "`e[43m$value`e[40m" -NoNewline }
                Write-HostDummy "`e[0m" -NoNewline
            }
            else {
                Write-HostParsing "`e[31m${line}`e[0m"
                continue
            }

            $splitedRemaining = trimDescription $remaining

            $params = $splitedRemaining.Removed
            $desc = $splitedRemaining.Remaining
            Write-HostParsing "$params" -NoNewline

            if ($desc) {
                Write-HostParsing "`e[32m$desc`e[0m"
                Add-Description $desc
            }
            else {
                Write-HostParsing ""
                $Prev = $true
            }
        }
        else {
            Write-HostParsing $line
        }
    }

    return [GitHelpOptions]@{
        Subcommand = '';
        Long       = $longDescriptions;
        Short      = $shortDescriptions;
    }
}

$script:__gitHelpCache = @{}
function Get-GitHelp {
    [OutputType([GitHelp])]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Command,
        [switch] $ShowParser
    )

    $gitHelp = $script:__gitHelpCache[$Command]
    if ($gitHelp) { return $gitHelp }

    $Options = [List[GitHelpOptions]]::new()

    [GitHelpOptions]$opt = Convert-ToGitHelpOptions (Invoke-Expression "git $Command -h 2>&1" -ErrorAction Ignore) -ShowParser:$ShowParser
    if ($Command -ceq 'grep') {
        $v = $null
        if ($opt.Long.TryGetValue('--and', [ref]$v)) {
            $opt.Long['--or'] = $v
            $opt.Long['--not'] = $v
        }
    }
    $Options.Add($opt)

    $Subcommands = (__git $Command --git-completion-helper-all) -split '\s+'
    foreach ($Subcommand in $Subcommands) {
        if ($Subcommand.StartsWith('-')) { continue }
        [GitHelpOptions]$opt = Convert-ToGitHelpOptions (Invoke-Expression "git $Command $Subcommand -h 2>&1" -ErrorAction Ignore) -ShowParser:$ShowParser
        $opt.Subcommand = $Subcommand
        $Options.Add($opt)
    }

    return ($script:__gitHelpCache[$Command] = [GitHelp]::new($Options.ToArray()))
}

function Get-GitShortOptions {
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Command,
        [Parameter(Position = 1)]
        [string]
        $Subcommand = '',
        [switch]$SkipHelp
    )

    $gh = Get-GitHelp $Command
    if ($gh) {
        $gh.ShortOptions($Subcommand)
    }
    if (!$SkipHelp) {
        $__helpCompletion
    }
}

function Get-GitOptionsDescription {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, Position = 0)]
        [AllowEmptyString()]
        [string]$Current,
        [Parameter(Mandatory, Position = 1)]
        [string]
        $Command,
        [Parameter(Position = 2)]
        [string]$Subcommand = ''
    )

    if ($Current.EndsWith('=')) {
        $Current = $Current.TrimEnd('=')
    }
    $gh = Get-GitHelp $Command
    $result = $gh.Description($Subcommand, $Current)

    if ($result) { return $result }

    if ($Current.StartsWith('--no-')) {
        $positive = Get-GitOptionsDescription ('--' + $Current.Substring('--no-'.Length)) $Command $Subcommand
        if ($positive) {
            return "[NO] $positive"
        }
    }
    return $null
}

class GitHelpOptions {
    [string]$Subcommand;
    [Dictionary[string, string]]$Long;
    [Dictionary[string, string]]$Short;

    [CompletionResult[]]$_shortOptionsCache = $null;

    [CompletionResult[]] ShortOptions() {
        if ($null -ne $this._shortOptionsCache) { return $this._shortOptionsCache }

        $ret = $this.Short.GetEnumerator() | ForEach-Object {
            [CompletionResult]::new(
                $_.Key,
                $_.Key,
                'ParameterName',
                $_.Value
            )
        } | Sort-Object ListItemText -CaseSensitive

        if ($null -eq $ret) {
            return ($this._shortOptionsCache = @()) 
        }
        return ($this._shortOptionsCache = $ret)
    }

    [string] Description([string]$key) {
        $value = $null
        $this.Long.TryGetValue($key, [ref]$value) | Out-Null

        return $value
    }
}
class GitHelp {
    [Dictionary[string, GitHelpOptions]]$Options;

    GitHelp([GitHelpOptions[]]$Options) {
        $this.Options = [Dictionary[string, GitHelpOptions]]::new()
        foreach ($opt in $Options) {
            $this.Options[$opt.Subcommand] = $opt
        }
    }

    [CompletionResult[]] ShortOptions([string]$Subcommand) {
        $opt = $null
        if (!$this.Options.TryGetValue($Subcommand, [ref]$opt)) {
            $opt = $this.Options['']
        }
        return $opt.ShortOptions()
    }

    [string] Description([string]$Subcommand, [string]$long) {
        $opt = $null
        if ($this.Options.TryGetValue($Subcommand, [ref]$opt)) {
            $result = $opt.Description($long)
            if ($result) {
                return $result
            }
        }
        return $this.Options[''].Description($long)
    }
}

# Command
$script:__gitCommandDescriptionAll = $null
function Get-GitCommandDescriptionAll {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param ()

    if ($script:__gitCommandDescriptionAll) { return $script:__gitCommandDescriptionAll }

    $t = @{}
    foreach ($line in (git help --verbose --all --no-external-commands --no-aliases)) {
        if ($line -match '\s\s(\S+)\s+(.+)') {
            $t[$Matches[1]] = $Matches[2]
        }
    }
    $script:__gitCommandDescriptionAll = $t
    return $t
}

function Get-GitCommandDescription {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Command
    )

    return (Get-GitCommandDescriptionAll)[$Command]
}