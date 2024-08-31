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
                CompletionText = '-3';
                ListItemText   = '-3';
                ResultType     = 'ParameterName';
                ToolTip        = "attempt three-way merge, fall back on normal patch if that fails";
            },
            @{
                CompletionText = '-C';
                ListItemText   = '-C';
                ResultType     = 'ParameterName';
                ToolTip        = "ensure at least <n> lines of context match";
            },
            @{
                CompletionText = '-N';
                ListItemText   = '-N';
                ResultType     = 'ParameterName';
                ToolTip        = 'mark new files with `git add --intent-to-add`';
            },
            @{
                CompletionText = '-p';
                ListItemText   = '-p';
                ResultType     = 'ParameterName';
                ToolTip        = "remove <num> leading slashes from traditional diff paths";
            },
            @{
                CompletionText = '-q';
                ListItemText   = '-q';
                ResultType     = 'ParameterName';
                ToolTip        = "be more quiet";
            },
            @{
                CompletionText = '-R';
                ListItemText   = '-R';
                ResultType     = 'ParameterName';
                ToolTip        = "apply the patch in reverse";
            },
            @{
                CompletionText = '-v';
                ListItemText   = '-v';
                ResultType     = 'ParameterName';
                ToolTip        = "be more verbose";
            },
            @{
                CompletionText = '-z';
                ListItemText   = '-z';
                ResultType     = 'ParameterName';
                ToolTip        = "paths are separated with NUL character";
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
                Line     = '--al';
                Expected = @(
                    @{
                        CompletionText = '--allow-overlap';
                        ListItemText   = '--allow-overlap';
                        ResultType     = 'ParameterName';
                        ToolTip        = "allow overlapping hunks";
                    },
                    @{
                        CompletionText = '--allow-empty';
                        ListItemText   = '--allow-empty';
                        ResultType     = 'ParameterName';
                        ToolTip        = "don't return error for empty patches";
                    }
                )
            },
            @{
                Line     = '--q';
                Expected = @(
                    @{
                        CompletionText = '--quiet';
                        ListItemText   = '--quiet';
                        ResultType     = 'ParameterName';
                        ToolTip        = "be more quiet";
                    }
                )
            },
            @{
                Line     = '--no-al';
                Expected = @(
                    @{
                        CompletionText = '--no-allow-overlap';
                        ListItemText   = '--no-allow-overlap';
                        ResultType     = 'ParameterName';
                        ToolTip        = "[NO] allow overlapping hunks";
                    },
                    @{
                        CompletionText = '--no-allow-empty';
                        ListItemText   = '--no-allow-empty';
                        ResultType     = 'ParameterName';
                        ToolTip        = "[NO] don't return error for empty patches";
                    }
                )
            },
            @{
                Line     = '--no';
                Expected = @(
                    @{
                        CompletionText = '--no-add';
                        ListItemText   = '--no-add';
                        ResultType     = 'ParameterName';
                        ToolTip        = "ignore additions made by the patch"
                    },
                    @{
                        CompletionText = '--no-';
                        ListItemText   = '--no-...';
                        ResultType     = 'Text';
                        ToolTip        = "--no-...";
                    }
                )
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'OptionValue' {
        It '<Line>' -ForEach @(
            @{
                Line     = '--whitespace=';
                Expected = 'nowarn', 'warn', 'error', 'error-all', 'fix' | ForEach-Object {
                    @{
                        CompletionText = "--whitespace=$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--whitespace ';
                Expected = 'nowarn', 'warn', 'error', 'error-all', 'fix' | ForEach-Object {
                    @{
                        CompletionText = "$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--whitespace=w';
                Expected = 'warn' | ForEach-Object {
                    @{
                        CompletionText = "--whitespace=$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--whitespace w';
                Expected = 'warn' | ForEach-Object {
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