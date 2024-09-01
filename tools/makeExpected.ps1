param(
    [CmdletBinding(DefaultParameterSetName = 'Raw')]
    [Parameter(ValueFromRemainingArguments)][string[]]$Line,
    [Parameter(Mandatory, ParameterSetName = 'Text')]
    [switch]$Text,
    [Parameter(ParameterSetName = 'Raw')]
    [switch]$Raw
)

Import-Module "$PSScriptRoot/../src/git-completion.psd1" -Force

$result = (Complete-Git -Words $Line)

if ($Raw) { return $result }
if ($Text) { return $result | ForEach-Object ListItemText }

'Expected = ' + (($result | ForEach-Object {
            if ($_.ListItemText -ne $_.ToolTip) {
                '@{',
                # "CompletionText='$($_.CompletionText)';",
                "ListItemText='$($_.ListItemText)';",
                # "ResultType='$($_.ResultType)';",
                "ToolTip=`"$($_.ToolTip)`";",
                '}' -join "`n"
            }
            else {
                "'$($_.ListItemText)'"
            }
        }) -join ",`n"
) + '|ConvertTo-Completion -ResultType ParameterName'