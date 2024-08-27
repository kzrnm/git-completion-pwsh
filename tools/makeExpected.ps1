param(
    [Parameter(Mandatory, Position = 0)][string]$line,
    [switch]$Raw
)

. "$PSScriptRoot/../tests/_TestInitialize.ps1"
$result = "$line" | Complete-FromLine

if ($Raw) { return $result }

($result | ForEach-Object {
    '@{',
    "CompletionText='$($_.CompletionText)';",
    "ListItemText='$($_.ListItemText)';",
    "ResultType='$($_.ResultType)';",
    "ToolTip=`"$($_.ToolTip)`";",
    '}' -join "`n"
}) -join ",`n"