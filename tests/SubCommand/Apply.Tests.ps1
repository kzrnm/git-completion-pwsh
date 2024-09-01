using namespace System.Collections.Generic;
using namespace System.IO;

. "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') {
    BeforeAll {
        Set-Variable Command ((Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') | ConvertTo-KebabCase)
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
        $expected = @{
            ListItemText = '-3';
            ToolTip      = "attempt three-way merge, fall back on normal patch if that fails";
        },
        @{
            ListItemText = '-C';
            ToolTip      = "ensure at least <n> lines of context match";
        },
        @{
            ListItemText = '-N';
            ToolTip      = 'mark new files with `git add --intent-to-add`';
        },
        @{
            ListItemText = '-p';
            ToolTip      = "remove <num> leading slashes from traditional diff paths";
        },
        @{
            ListItemText = '-q';
            ToolTip      = "be more quiet";
        },
        @{
            ListItemText = '-R';
            ToolTip      = "apply the patch in reverse";
        },
        @{
            ListItemText = '-v';
            ToolTip      = "be more verbose";
        },
        @{
            ListItemText = '-z';
            ToolTip      = "paths are separated with NUL character";
        },
        @{
            ListItemText = '-h';
            ToolTip      = "show help";
        } | ConvertTo-Completion -ResultType ParameterName
        "git $Command -" | Complete-FromLine | Should -BeCompletion $expected
    }

    Describe 'Options' {
        It '<Line>' -ForEach @(
            @{
                Line     = '--al';
                Expected = @{
                    ListItemText = '--allow-overlap';
                    ToolTip      = "allow overlapping hunks";
                },
                @{
                    ListItemText = '--allow-empty';
                    ToolTip      = "don't return error for empty patches";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--q';
                Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip "be more quiet"
            },
            @{
                Line     = '--no-al';
                Expected = @{
                    ListItemText = '--no-allow-overlap';
                    ToolTip      = "[NO] allow overlapping hunks";
                },
                @{
                    ListItemText = '--no-allow-empty';
                    ToolTip      = "[NO] don't return error for empty patches";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no';
                Expected = @{
                    ListItemText = '--no-add';
                    ToolTip      = "ignore additions made by the patch"
                },
                @{
                    CompletionText = '--no-';
                    ListItemText   = '--no-...';
                    ResultType     = 'Text'
                } | ConvertTo-Completion -ResultType ParameterName
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
                    "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "--whitespace=$_"
                }
            },
            @{
                Line     = '--whitespace ';
                Expected = 'nowarn', 'warn', 'error', 'error-all', 'fix' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--whitespace=w';
                Expected = 'warn' | ForEach-Object {
                    "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "--whitespace=$_"
                }
            },
            @{
                Line     = '--whitespace w';
                Expected = 'warn' | ConvertTo-Completion -ResultType ParameterValue
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }
}