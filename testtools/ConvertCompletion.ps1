function ConvertTo-Completion {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        $TextOrObject,
        [Parameter(Mandatory)]
        [System.Management.Automation.CompletionResultType]
        $ResultType,
        [string]
        $CompletionText = '',
        [string]
        $ToolTip = ''
    )

    process {
        if ($TextOrObject -is [string]) {
            $Object = @{
                CompletionText = $TextOrObject;
                ListItemText   = $TextOrObject;
                ResultType     = $ResultType;
                ToolTip        = $TextOrObject;
            }

            if ($CompletionText) {
                $Object.CompletionText = $CompletionText
            }
            if ($ToolTip) {
                $Object.ToolTip = $ToolTip
            }
        }
        else {
            $Object = $TextOrObject

            if (!$Object.ResultType) {
                $Object.ResultType = $ResultType
            }

            if (!$Object.CompletionText) {
                if ($CompletionText) {
                    $Object.CompletionText = $CompletionText
                }
                else {
                    $Object.CompletionText = $TextOrObject.ListItemText
                }
            }

            if (!$Object.ToolTip) {
                if ($ToolTip) {
                    $Object.ToolTip = $ToolTip
                }
                else {
                    $Object.ToolTip = $TextOrObject.ListItemText
                }
            }
        }

        $Object
    }
}