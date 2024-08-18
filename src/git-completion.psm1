$ErrorActionPreference = 'Continue'

Get-ChildItem -Recurse "$PSScriptRoot" | Where-Object { $_.Extension -eq '.ps1' } | ForEach-Object { . $_ }

Register-ArgumentCompleter -Native -CommandName git -ScriptBlock {
    param($wordToComplete, $CommandAst, $CursorPosition)
    
    $Words = ($CommandAst.CommandElements | Select-Object -ExpandProperty Extent | Select-Object -ExpandProperty Text)

    $cw = $CommandAst.CommandElements.Count
    $pr = $Words[$Words.Count - 1]
    $cr = ''

    for ($i = 1; $i -lt $CommandAst.CommandElements.Count; $i++) {
        $extent = $CommandAst.CommandElements[$i].Extent

        if ($CursorPosition -lt $extent.StartOffset) {
            # The cursor is within whitespace between the previous and current words.
            $pr = $commandAst.CommandElements[$i - 1].Extent.Text
            $cw = $i
            break
        }
        elseif ($CursorPosition -le $extent.EndOffset) {
            $cr = $extent.Text
            $pr = $commandAst.CommandElements[$i - 1].Extent.Text
            $cw = $i
            break
        }
    }

    $WordPosition = $cw
    $CurrentWord = $cr
    $PreviousWord = $pr

    return (
        Complete-Git `
            -CursorPosition $CursorPosition `
            -Words $Words `
            -WordPosition $WordPosition `
            -CurrentWord $CurrentWord `
            -PreviousWord $PreviousWord `
    )
}
