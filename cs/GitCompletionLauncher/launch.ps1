$path = "${env:TMP}/GitCompletionLauncher/"

mkdir $path -Force
Copy-Item -Force -Recurse "$PSScriptRoot/../../src/*" "$path/"
Copy-Item -Force -Recurse "$PSScriptRoot/../GitCompletionCore/bin/Debug/netstandard2.0/*" "$path/"

if (!(Test-Path "$path/git-completion.psd1")) {
    throw "See launch.ps1"
}

Import-Module "$path/GitCompletionCore.dll" -Force
Import-Module "$path/git-completion.psd1" -Force

"false", "true", "always", "never", "auto" | Complete-List -Current 'a'