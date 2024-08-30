using namespace System.Collections.Generic;
using namespace System.IO;

BeforeAll {
    . "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))tests/_TestInitialize.ps1"
}

Describe 'Mergetool' {
    BeforeAll {
        Initialize-Home

        mkdir ($rootPath = "$TestDrive/gitRoot")
        mkdir ($remotePath = "$TestDrive/gitRemote")

        Push-Location $remotePath
        git init --initial-branch=main
        "Initial" | Out-File 'initial.txt'
        "echo hello" | Out-File 'hello.sh'
        git update-index --add --chmod=+x hello.sh
        git add -A
        git commit -m "initial"
        Pop-Location

        Push-Location $rootPath
        git init --initial-branch=main

        git remote add origin "$remotePath"
        git remote add ordinary "$remotePath"
        git remote add grm "$remotePath"

        git config set remotes.default "origin grm"
        git config set remotes.ors "origin ordinary"

        git pull origin main
        git fetch ordinary
        git fetch grm
        mkdir Pwsh
        "echo world" | Out-File 'Pwsh/world.ps1'
        git add -A
        git commit -m "World"
    }

    AfterAll {
        Restore-Home
        Pop-Location
    }

    It 'ShortOptions' {
        $expected = @(
            @{
                CompletionText = '-g';
                ListItemText   = '-g';
                ResultType     = 'ParameterName';
                ToolTip        = "--gui"
            },
            @{
                CompletionText = '-O';
                ListItemText   = '-O';
                ResultType     = 'ParameterName';
                ToolTip        = "Process files in the order specified"
            },
            @{
                CompletionText = '-y';
                ListItemText   = '-y';
                ResultType     = 'ParameterName';
                ToolTip        = "Don’t prompt before each invocation of the merge resolution program"
            },
            @{
                CompletionText = '-h';
                ListItemText   = '-h';
                ResultType     = 'ParameterName';
                ToolTip        = "show help";
            }
        )
        "git mergetool -" | Complete-FromLine | Should -BeCompletion $expected
    }

    Describe 'Options' {
        It '<Line>' -ForEach @(
            @{
                Line     = '--';
                Expected = '--tool=', '--prompt', '--no-prompt', '--gui', '--no-gui' | ForEach-Object { 
                    @{
                        CompletionText = "$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterName';
                        ToolTip        = "$_"
                    }
                }
            },
            @{
                Line     = '--no-';
                Expected = '--no-prompt', '--no-gui' | ForEach-Object { 
                    @{
                        CompletionText = "$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterName';
                        ToolTip        = "$_"
                    }
                }
            }
        ) {
            "git mergetool $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'OptionValue' {
        It '<Line>' -ForEach @(
            @{
                Line     = '--tool=t';
                Expected = 'tkdiff', 'tortoisemerge' | ForEach-Object {
                    @{
                        CompletionText = "--tool=$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--tool=v';
                Expected = 'vimdiff' | ForEach-Object {
                    @{
                        CompletionText = "--tool=$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--tool t';
                Expected = 'tkdiff', 'tortoisemerge' | ForEach-Object {
                    @{
                        CompletionText = "$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--tool v';
                Expected = 'vimdiff' | ForEach-Object {
                    @{
                        CompletionText = "$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            }
        ) {
            "git mergetool $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }
}