using namespace System.Management.Automation;
using namespace System.IO;

function dequote {
    param (
        [Parameter(Position = 0, ValueFromPipeline)]
        [string]
        $Text
    )

    process {
        $Text -creplace '(["''`\s])', '`$1'
    }
}

function completeFile {
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
    $left = $Current.Substring(0, $lx + 1) | dequote

    Get-ChildItem "$Current*" | ForEach-Object {
        $name = $_.Name | dequote
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