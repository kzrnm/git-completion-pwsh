param(
    [CmdletBinding(DefaultParameterSetName = 'Raw')]
    [Parameter(ValueFromRemainingArguments)][string[]]$Line,
    [Parameter(Mandatory, ParameterSetName = 'Text')]
    [switch]$Text,
    [Parameter(ParameterSetName = 'Raw')]
    [switch]$Raw
)

$result = (Complete-Git -Words $Line)

if ($Raw) { return $result }
if ($Text) { return $result | ForEach-Object ListItemText }

($result | ForEach-Object {
    '@{',
    "CompletionText='$($_.CompletionText)';",
    "ListItemText='$($_.ListItemText)';",
    "ResultType='$($_.ResultType)';",
    "ToolTip=`"$($_.ToolTip)`";",
    '}' -join "`n"
}) -join ",`n"