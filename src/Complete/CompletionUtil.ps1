using namespace System.Management.Automation;

function completeList {
    [CmdletBinding(PositionalBinding = $false, DefaultParameterSetName = 'Default')]
    [OutputType([CompletionResult[]])]
    param(
        [AllowEmptyString()]
        [string]
        $Current = '',
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(Mandatory, ParameterSetName = 'Prefix')]
        [AllowEmptyString()]
        [string]
        $Prefix = '',
        [string]
        $Suffix = '',
        [scriptblock]
        $DescriptionBuilder = $null,
        [CompletionResultType]
        $ResultType = [CompletionResultType]::ParameterName,
        [Parameter(ParameterSetName = 'Prefix')]
        [switch]
        $RemovePrefix,
        [Parameter(ValueFromPipeline)]
        [string]
        $Candidate
    )

    begin {
        if ($RemovePrefix -and $Current.StartsWith($Prefix)) {
            $Current = $Current.Substring($Prefix.Length)
        }
    }

    process {
        if ((!$Current) -or $Candidate.StartsWith($Current)) {
            $desc = $null
            if ($DescriptionBuilder) {
                $desc = [string]$DescriptionBuilder.InvokeWithContext(
                    $null,
                    [psvariable]::new('_', $Candidate),
                    @($Candidate)
                )
            }
            if (!$desc) {
                $desc = "$Candidate"
            }
            $ListItem = $Candidate

            $Completion = "$Prefix$Candidate$Suffix"

            [CompletionResult]::new(
                "$Completion",
                $ListItem,
                $ResultType,
                $desc
            )
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
    param($wordToComplete, $CommandAst, $CursorPosition, $CommandName)

    $ws = [System.Collections.Generic.List[string]]::new($CommandAst.CommandElements.Count + 2)
    $ws.Add($CommandName)

    $CurrentIndex = 0

    for ($i = 1; $i -lt $CommandAst.CommandElements.Count; $i++) {
        $extent = $CommandAst.CommandElements[$i].Extent
        if ($CurrentIndex) {
            $ws.Add($extent.Text)
        }
        elseif ($CursorPosition -le $extent.EndOffset) {
            $ws.Add($wordToComplete)
            $CurrentIndex = $i
            if ($CursorPosition -lt $extent.StartOffset) {
                $ws.Add($extent.Text)
            }
        }
        else {
            $ws.Add($extent.Text)
        }
    }

    if (!$CurrentIndex) {
        $CurrentIndex = $ws.Count
        $ws.Add('')
    }

    return $ws.ToArray(), $CurrentIndex
}
