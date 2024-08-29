using namespace System.Management.Automation;

function Complete-FilePath {
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
    $left = $Current.Substring(0, $lx + 1) -creplace '([`\s])', '`$1'

    Get-ChildItem "$Current*" | ForEach-Object {
        $name = $_.Name -creplace '([`\s])', '`$1'
        if ($_ -is [System.IO.DirectoryInfo]) {
            [CompletionResult]::new(
                "${Prefix}${left}${name}/",
                $_.Name + '/',
                'ProviderContainer',
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