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
                CompletionText = '-a';
                ListItemText   = '-a';
                ResultType     = 'ParameterName';
                ToolTip        = "treat all files as text.";
            },
            @{
                CompletionText = '-B';
                ListItemText   = '-B';
                ResultType     = 'ParameterName';
                ToolTip        = "detect complete rewrites.";
            },
            @{
                CompletionText = '-C';
                ListItemText   = '-C';
                ResultType     = 'ParameterName';
                ToolTip        = "detect copies.";
            },
            @{
                CompletionText = '-l';
                ListItemText   = '-l';
                ResultType     = 'ParameterName';
                ToolTip        = "limit rename attempts up to <n> paths.";
            },
            @{
                CompletionText = '-M';
                ListItemText   = '-M';
                ResultType     = 'ParameterName';
                ToolTip        = "detect renames.";
            },
            @{
                CompletionText = '-O';
                ListItemText   = '-O';
                ResultType     = 'ParameterName';
                ToolTip        = "reorder diffs according to the <file>.";
            },
            @{
                CompletionText = '-p';
                ListItemText   = '-p';
                ResultType     = 'ParameterName';
                ToolTip        = "output patch format.";
            },
            @{
                CompletionText = '-R';
                ListItemText   = '-R';
                ResultType     = 'ParameterName';
                ToolTip        = "swap input file pairs.";
            },
            @{
                CompletionText = '-S';
                ListItemText   = '-S';
                ResultType     = 'ParameterName';
                ToolTip        = "find filepair whose only one side contains the string.";
            },
            @{
                CompletionText = '-u';
                ListItemText   = '-u';
                ResultType     = 'ParameterName';
                ToolTip        = "synonym for -p.";
            },
            @{
                CompletionText = '-z';
                ListItemText   = '-z';
                ResultType     = 'ParameterName';
                ToolTip        = "output diff-raw with lines terminated with NUL.";
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

    Describe 'DoubleDash' {
        It '<Line>' -ForEach @(
            @{
                Line     = 'src -- -';
                Expected = @()
            },
            @{
                Line     = 'src -- ';
                Expected = @()
            },
            @{
                Line     = '-- ';
                Expected = @()
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'Options' {
        It '<Line>' -ForEach @(
            @{
                Line     = '--b';
                Expected = '--base', '--binary', '--break-rewrites' | ForEach-Object { 
                    @{
                        CompletionText = "$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterName';
                        ToolTip        = "$_"
                    }
                }
            },
            @{
                Line     = '--no-p';
                Expected = '--no-prefix', '--no-patch' | ForEach-Object { 
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
                Line     = '--color-moved-ws i';
                Expected = 'ignore-space-at-eol', 'ignore-space-change', 'ignore-all-space' | ForEach-Object {
                    @{
                        CompletionText = "$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--color-moved-ws ';
                Expected = 'no', 'ignore-space-at-eol', 'ignore-space-change', 'ignore-all-space', 'allow-indentation-change' | ForEach-Object {
                    @{
                        CompletionText = "$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--color-moved-ws=i';
                Expected = 'ignore-space-at-eol', 'ignore-space-change', 'ignore-all-space' | ForEach-Object {
                    @{
                        CompletionText = "--color-moved-ws=$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--color-moved-ws=';
                Expected = 'no', 'ignore-space-at-eol', 'ignore-space-change', 'ignore-all-space', 'allow-indentation-change' | ForEach-Object {
                    @{
                        CompletionText = "--color-moved-ws=$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--color-moved=d';
                Expected = 'default', 'dimmed-zebra'  | ForEach-Object {
                    @{
                        CompletionText = "--color-moved=$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--color-moved=';
                Expected = 'no', 'default', 'plain', 'blocks', 'zebra', 'dimmed-zebra' | ForEach-Object {
                    @{
                        CompletionText = "--color-moved=$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--ws-error-highlight d';
                Expected = 'default' | ForEach-Object {
                    @{
                        CompletionText = "$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--ws-error-highlight ';
                Expected = 'context', 'old', 'new', 'all', 'default' | ForEach-Object {
                    @{
                        CompletionText = "$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--ws-error-highlight=d';
                Expected = 'default' | ForEach-Object {
                    @{
                        CompletionText = "--ws-error-highlight=$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--ws-error-highlight=';
                Expected = 'context', 'old', 'new', 'all', 'default' | ForEach-Object {
                    @{
                        CompletionText = "--ws-error-highlight=$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--submodule=d';
                Expected = 'diff' | ForEach-Object {
                    @{
                        CompletionText = "--submodule=$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--submodule=';
                Expected = 'diff', 'log', 'short' | ForEach-Object {
                    @{
                        CompletionText = "--submodule=$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--diff-algorithm m';
                Expected = 'myers', 'minimal' | ForEach-Object {
                    @{
                        CompletionText = "$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--diff-algorithm ';
                Expected = 'myers', 'minimal', 'patience', 'histogram' | ForEach-Object {
                    @{
                        CompletionText = "$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--diff-algorithm=m';
                Expected = 'myers', 'minimal' | ForEach-Object {
                    @{
                        CompletionText = "--diff-algorithm=$_";
                        ListItemText   = "$_";
                        ResultType     = 'ParameterValue';
                        ToolTip        = "$_";
                    }
                }
            },
            @{
                Line     = '--diff-algorithm=';
                Expected = 'myers', 'minimal', 'patience', 'histogram' | ForEach-Object {
                    @{
                        CompletionText = "--diff-algorithm=$_";
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