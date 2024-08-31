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
        mkdir ($remotePath = "$TestDrive/gitRemote")
        Initialize-Remote $rootPath $remotePath
        Push-Location $rootPath
    }

    AfterAll {
        Restore-Home
        Pop-Location
    }

    It 'ShortOptions' {
        $expected = @(
            @{
                CompletionText = '-d';
                ListItemText   = '-d';
                ResultType     = 'ParameterName';
                ToolTip        = "perform a full-directory diff";
            },
            @{
                CompletionText = '-g';
                ListItemText   = '-g';
                ResultType     = 'ParameterName';
                ToolTip        = 'use `diff.guitool` instead of `diff.tool`';
            },
            @{
                CompletionText = '-t';
                ListItemText   = '-t';
                ResultType     = 'ParameterName';
                ToolTip        = "use the specified diff tool";
            },
            @{
                CompletionText = '-x';
                ListItemText   = '-x';
                ResultType     = 'ParameterName';
                ToolTip        = "specify a custom command for viewing diffs";
            },
            @{
                CompletionText = '-y';
                ListItemText   = '-y';
                ResultType     = 'ParameterName';
                ToolTip        = "do not prompt before launching a diff tool";
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
                Line     = '--t';
                Expected = @(
                    @{
                        CompletionText = "--theirs";
                        ListItemText   = "--theirs";
                        ResultType     = 'ParameterName';
                        ToolTip        = "--theirs"
                    },
                    @{
                        CompletionText = "--text";
                        ListItemText   = "--text";
                        ResultType     = 'ParameterName';
                        ToolTip        = "--text"
                    },
                    @{
                        CompletionText = "--textconv";
                        ListItemText   = "--textconv";
                        ResultType     = 'ParameterName';
                        ToolTip        = "--textconv"
                    },
                    @{
                        CompletionText = "--tool=";
                        ListItemText   = "--tool=";
                        ResultType     = 'ParameterName';
                        ToolTip        = "use the specified diff tool"
                    },
                    @{
                        CompletionText = "--tool-help";
                        ListItemText   = "--tool-help";
                        ResultType     = 'ParameterName';
                        ToolTip        = 'print a list of diff tools that may be used with `--tool`'
                    },
                    @{
                        CompletionText = "--trust-exit-code";
                        ListItemText   = "--trust-exit-code";
                        ResultType     = 'ParameterName';
                        ToolTip        = "make 'git-difftool' exit when an invoked diff tool returns a non-zero exit code"
                    }
                )
            },
            @{
                Line     = '--ind';
                Expected = @(
                    @{
                        CompletionText = "--indent-heuristic";
                        ListItemText   = "--indent-heuristic";
                        ResultType     = 'ParameterName';
                        ToolTip        = "--indent-heuristic"
                    },
                    @{
                        CompletionText = "--index";
                        ListItemText   = "--index";
                        ResultType     = 'ParameterName';
                        ToolTip        = "opposite of --no-index"
                    }
                )
            },
            @{
                Line     = '--no-t';
                Expected = @(
                    @{
                        CompletionText = "--no-textconv";
                        ListItemText   = "--no-textconv";
                        ResultType     = 'ParameterName';
                        ToolTip        = "--no-textconv"
                    },
                    @{
                        CompletionText = "--no-tool";
                        ListItemText   = "--no-tool";
                        ResultType     = 'ParameterName';
                        ToolTip        = "[NO] use the specified diff tool"
                    },
                    @{
                        CompletionText = "--no-tool-help";
                        ListItemText   = "--no-tool-help";
                        ResultType     = 'ParameterName';
                        ToolTip        = '[NO] print a list of diff tools that may be used with `--tool`'
                    },
                    @{
                        CompletionText = "--no-trust-exit-code";
                        ListItemText   = "--no-trust-exit-code";
                        ResultType     = 'ParameterName';
                        ToolTip        = "[NO] make 'git-difftool' exit when an invoked diff tool returns a non-zero exit code"
                    }
                )
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
        It 'No' {
            $expected = @(
                @{
                    CompletionText = "--no-";
                    ListItemText   = "--no-...";
                    ResultType     = 'Text';
                    ToolTip        = "--no-..."
                }
            )
            "git $Command --no" | Complete-FromLine | Select-Object -Last 1 | Should -BeCompletion $expected
        }
    }

    Describe 'OptionValue' {
        It '<Line>' -ForEach @(
            @{
                Line     = '--tool=k';
                Expected = 'kdiff3', 'kompare' | ForEach-Object {
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
                Line     = '--tool k';
                Expected = 'kdiff3', 'kompare' | ForEach-Object {
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

    Describe 'Revlist' {
        . "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))tests/_Revlist.ps1"
    }
}