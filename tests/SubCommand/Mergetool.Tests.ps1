using namespace System.Collections.Generic;
using namespace System.IO;

BeforeAll {
    . "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))tests/_TestInitialize.ps1"
}

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') {
    BeforeAll {
        Set-Variable Command ((Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') | Convert-ToKebabCase)
        Initialize-Home

        mkdir ($rootPath = "$TestDrive/gitRoot")
        Initialize-SimpleRepo $rootPath
        Push-Location $rootPath
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
        "git $Command -" | Complete-FromLine | Should -BeCompletion $expected
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
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
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
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }
}