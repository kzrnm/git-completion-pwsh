$ErrorActionPreference = 'Continue'

Get-ChildItem -Recurse "$PSScriptRoot" | Where-Object { $_.Extension -eq '.ps1' } | ForEach-Object { . $_.FullName }

Export-ModuleMember -Variable 'GitCompletionSettings'

Register-ArgumentCompleter -CommandName git -Native -ScriptBlock {
    param($wordToComplete, $CommandAst, $CursorPosition)

    $ws = [System.Collections.Generic.List[string]]::new($CommandAst.CommandElements.Count + 2)
    $ws.Add('git')

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

    return (Complete-Git -Words $ws.ToArray() -CurrentIndex $CurrentIndex)
}
