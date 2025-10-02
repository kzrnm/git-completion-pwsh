# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Management.Automation;

function filterCompletionResult {
    param (
        [Parameter(ValueFromPipeline)]
        [CompletionResult]
        $Completion,
        [Parameter(Position = 0)]
        [string]
        $Current = ''
    )

    process {
        if ($Completion.ListItemText.StartsWith($Current)) {
            $Completion
        }
    }
}

# Generates completion reply, appending a space to possible completion words,
# if necessary.
# It accepts 1 to 4 arguments:
# 1: List of possible completion words.
# 2: A prefix to be added to each possible completion word (optional).
# 3: Generate possible completion matches for this word (optional).
# 4: A suffix to be appended to each possible completion word (optional).
function gitcomp {
    [OutputType([CompletionResult[]])]
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        $Current,
        [string]$Prefix = '',
        [string]$Suffix = '',
        [scriptblock]
        $DescriptionBuilder = $null,
        [Parameter(ValueFromPipeline)]
        [string]
        $Candidate
    )

    begin {
        switch -Wildcard ($Current) {
            '*=' { $Type = -1 }
            '--no-*' { $Type = 1 }
            Default { $Type = 0 }
        }

        function buildDescription {
            param (
                [Parameter(Position = 0)]
                [string]
                $Candidate
            )
            $desc = $null
            if ($DescriptionBuilder) {
                $desc = [string]$DescriptionBuilder.InvokeWithContext(
                    $null,
                    [psvariable]::new('_', $Candidate),
                    @($Candidate)
                )
            }
            if (!$desc) {
                $desc = "$c"
            }
            return $desc
        }
    }

    process {
        $cw = "$Candidate$Suffix"
        $c = "$Prefix$cw"

        switch ($Type) {
            -1 {  }
            1 { 
                if ($cw.StartsWith($Current)) {
                    [CompletionResult]::new(
                        $c,
                        $c,
                        'ParameterName',
                        (buildDescription $Candidate)
                    )
                }
            }
            Default {
                if ($Candidate -eq '--') {
                    if ('--no-'.StartsWith($Current)) {
                        [CompletionResult]::new(
                            "--no-",
                            "--no-...$Suffix",
                            'Text',
                            "--no-...$Suffix"
                        )
                    }
                    $Type = -1
                }
                else {
                    if ($cw.StartsWith($Current)) {
                        [CompletionResult]::new(
                            $c,
                            $c,
                            'ParameterName',
                            (buildDescription $Candidate)
                        )
                    }
                }
            }
        }   
    }
}

function buildWords {
    [CmdletBinding(PositionalBinding)]
    param($CommandAst, $CursorPosition)

    $ws = [System.Collections.Generic.List[string]]::new($CommandAst.CommandElements.Count + 2)

    $CurrentIndex = 0

    for ($i = 0; $i -lt $CommandAst.CommandElements.Count; $i++) {
        $cmd = $CommandAst.CommandElements[$i]
        $extent = $cmd.Extent
        $text = $cmd.Value
        if ($text -isnot [string]) {
            $text = $extent.Text
        }

        if (!$CurrentIndex -and ($CursorPosition -le $extent.EndOffset)) {
            $CurrentIndex = $i
            if ($CursorPosition -le $extent.StartOffset) {
                $ws.Add('')
            }
        }
        $ws.Add($text)
    }

    if (!$CurrentIndex) {
        $CurrentIndex = $ws.Count
        $ws.Add('')
    }

    return $ws.ToArray(), $CurrentIndex
}
