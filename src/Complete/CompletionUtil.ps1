using namespace System.Management.Automation;

function completeList {
    [CmdletBinding(PositionalBinding = $false, DefaultParameterSetName = 'Default')]
    [OutputType([CompletionResult[]])]
    param(
        [AllowEmptyString()]
        [string]
        $Current,
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
        [Parameter(HelpMessage = 'Escape space')]
        [switch]
        $IsPath,
        [Parameter(ValueFromPipeline)]
        [string]
        $Candidate
    )

    process {
        if ($RemovePrefix -and $Current.StartsWith($Prefix)) {
            $Current = $Current.Substring($Prefix.Length)
        }
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

            if ($IsPath) {
                $Candidate -replace '(\s)', '`$1'
            }
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

function filterCompletionResult {
    [OutputType([CompletionResult[]])]
    param (
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]
        $Current,
        [Parameter(ValueFromPipeline)]
        $Completion
    )

    process {
        if (($Completion -is [CompletionResult]) -and $Completion.ListItemText.StartsWith($Current)) {
            return $Completion
        }
        elseif (($Completion -is [string]) -and $Completion.StartsWith($Current)) {
            return $Completion
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
