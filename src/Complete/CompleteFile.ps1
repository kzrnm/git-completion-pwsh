# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Collections.Generic;
using namespace System.Management.Automation;
using namespace System.IO;

function escapeSpecialChar {
    param (
        [Parameter(Position = 0, ValueFromPipeline)]
        [string]
        $Text
    )

    process {
        $Text -creplace '(["''`\s])', '`$1'
    }
}

function completeLocalFile {
    param (
        [Parameter(ValueFromPipeline)]
        [string]
        $File,
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$Current,
        [string]$Prefix = '',
        [string]$BaseDir = '',
        [switch]
        $RemovePrefix
    )

    begin {
        if ($RemovePrefix -and $Current.StartsWith($Prefix)) {
            $Current = $Current.Substring($Prefix.Length)
        }
    }

    process {
        if ((!$Current) -or $File.StartsWith($Current)) {
            if ($BaseDir -and !$BaseDir.EndsWith('/')) {
                $BaseDir += '/'
            }
            $fullPath = (Resolve-Path "${BaseDir}${File}").Path

            $ListItem = "$File"
            $Completion = "$Prefix$File"

            [CompletionResult]::new(
                "$Completion",
                "$ListItem",
                'ProviderItem',
                $fullPath.TrimEnd([Path]::AltDirectorySeparatorChar, [Path]::DirectorySeparatorChar)
            )
        }
    }
}

function completeCurrentDirectory {
    [CmdletBinding()]
    [OutputType([CompletionResult[]])]
    param (
        [Parameter(Mandatory, Position = 0)]
        [AllowEmptyString()]
        [string]
        $Current,
        [string]
        $Prefix = ''
    )

    $lx = $Current.LastIndexOfAny(@([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar))
    $left = $Current.Substring(0, $lx + 1) | escapeSpecialChar

    Get-ChildItem "$Current*" | ForEach-Object {
        $name = $_.Name | escapeSpecialChar
        if ($_ -is [System.IO.DirectoryInfo]) {
            [CompletionResult]::new(
                "${Prefix}${left}${name}/",
                $_.Name + '/',
                'ProviderItem',
                $_.FullName
            )
        }
        else {
            [CompletionResult]::new(
                "${Prefix}${left}${name}",
                $_.Name,
                'ProviderItem',
                $_.FullName
            )
        }
    }
    return
}

function filterFiles {
    [CmdletBinding()]
    [OutputType([CompletionResult[]])]
    param (
        [Parameter(ValueFromPipeline)]
        [AllowEmptyCollection()]
        [string]
        $Candidate,
        [string[]]
        $Exclude = @()
    )
    begin {
        $ex = [HashSet[string]]::new($Exclude.Length)
        foreach ($e in $Exclude) {
            $ex.Add($ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($e)) > $null
        }
    }

    process {
        if (!$ex.Contains($ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Candidate))) {
            $Candidate
        }
    }
}

function completeFromFileList {
    [CmdletBinding()]
    [OutputType([CompletionResult[]])]
    param (
        [Parameter(ValueFromPipeline)]
        [AllowEmptyCollection()]
        [string]
        $Candidate,
        [string]
        $Prefix = '',
        [switch]
        $LeadingDash
    )
    begin {
        [string]$Prev = ''
    }

    process {
        if (!$Candidate) {}
        elseif (!$Prev) {
            $Prev = $Candidate
        }
        else {
            $CommonPrefixLength = $Prefix.Length
            for ($i = $Prefix.Length; $i -lt $Prev.Length; $i++) {
                if ($Candidate[$i] -cne $Prev[$i]) {
                    break
                }
                elseif ($Candidate[$i] -cin @([Path]::DirectorySeparatorChar, [Path]::AltDirectorySeparatorChar)) {
                    $CommonPrefixLength = $i + 1
                }
            }
            if ($CommonPrefixLength -gt $Prefix.Length) {
                $Prev = $Prev.Substring(0, $CommonPrefixLength)
            }
            else {
                $Completion = $Prev
                if (!$LeadingDash -and ($Prev.StartsWith('-'))) {
                    $Completion = "./$Completion"
                }
                [CompletionResult]::new(
                    ($Completion | escapeSpecialChar),
                    $Prev,
                    'ProviderItem',
                    $Prev
                )
                $Prev = $Candidate
            }
        }
    }

    end {
        if ($Prev) {
            $Completion = $Prev
            if (!$LeadingDash -and ($Prev.StartsWith('-'))) {
                $Completion = "./$Completion"
            }
            [CompletionResult]::new(
                ($Completion | escapeSpecialChar),
                $Prev,
                'ProviderItem',
                $Prev
            )
        }
    }
}
