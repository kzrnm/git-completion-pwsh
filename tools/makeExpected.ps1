param(
    [CmdletBinding(DefaultParameterSetName = 'Split')]
    [Parameter(ValueFromRemainingArguments, ParameterSetName = 'Split')]
    [string[]]$Line,
    [Parameter(Mandatory, ParameterSetName = 'String')]
    [string]$Current
)

Import-Module "$PSScriptRoot/../src/git-completion.psd1" -Force

$result = if ($PSCmdlet.ParameterSetName -eq 'Split') {
    Complete-Git -Words $Line
}
else {
    . "$PSScriptRoot/run.ps1" $Current
}
'Expected = ' + (($result | ForEach-Object {
            if ($_.ListItemText -ne $_.ToolTip) {
                '@{',
                # "CompletionText='$($_.CompletionText)';",
                "ListItemText='$($_.ListItemText)';",
                # "ResultType='$($_.ResultType)';",
                "ToolTip=`"$($_.ToolTip)`";",
                '}' -join "`n"
            }
            elseif ($_.ListItemText -eq '--no-...') {
                
                '@{',
                "CompletionText='--no-';",
                "ListItemText='--no-...';",
                "ResultType='Text';",
                '}' -join "`n"
            }
            else {
                "'$($_.ListItemText)'"
            }
        }) -join ",`n"
) + '|ConvertTo-Completion -ResultType ParameterName'