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

    process {
        if ($RemovePrefix -and $Current.StartsWith($Prefix)) {
            $Current = $Current.Substring($Prefix.Length)
        }

        if ((!$Current) -or $File.StartsWith($Current)) {
            if ($BaseDir -and !$BaseDir.EndsWith('/')) {
                $BaseDir += '/'
            }
            $fullPath = (Resolve-Path "${BaseDir}${File}").Path

            $ListItem = "$File$Suffix"
            $Completion = "$Prefix$File$Suffix"

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

function completeFilteredFiles {
    [CmdletBinding()]
    [OutputType([CompletionResult[]])]
    param (
        [Parameter(ValueFromPipeline)]
        [AllowEmptyCollection()]
        [string]
        $Candidate,
        [string]
        $Prefix = '',
        [string[]]
        $Exclude = @(),
        [switch]
        $LeadingDash
    )
    begin {
        $ex = [HashSet[string]]::new($Exclude.Length)
        foreach ($e in $Exclude) {
            $ex.Add($ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($e)) | Out-Null
        }
    }

    process {
        if (!$ex.Contains($ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Candidate))) {
            $Completion = ($Prefix + $_)
            if (!$LeadingDash -and ($_.StartsWith('-')) -and ($Prefix -eq '')) {
                $Completion = "./$Completion"
            }
            [CompletionResult]::new(
                ($Completion | escapeSpecialChar),
                $_,
                'ProviderItem',
                $_
            )
        }
    }
}
