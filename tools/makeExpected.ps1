param(
    [CmdletBinding(DefaultParameterSetName = 'Raw')]
    [Parameter(Mandatory, Position = 0)][string]$Line,
    [Parameter(Mandatory, ParameterSetName = 'Text')]
    [switch]$Text,
    [Parameter(ParameterSetName = 'Raw')]
    [switch]$Raw
)

. "$PSScriptRoot/../tests/_TestInitialize.ps1"
$result = "$Line" | Complete-FromLine

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