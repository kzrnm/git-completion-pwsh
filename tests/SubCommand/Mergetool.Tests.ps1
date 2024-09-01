using namespace System.Collections.Generic;
using namespace System.IO;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

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

    Describe 'DoubleDash' {
        Describe 'InRight' {
            It '<Left>(cursor) <Right>' -ForEach @(
                @{
                    Left     = '--gui';
                    Right    = @('--');
                    Expected = '--gui' | ConvertTo-Completion -ResultType ParameterName -ToolTip '--gui'
                },
                @{
                    Left     = '--gui';
                    Right    = @('-- --all');
                    Expected = '--gui' | ConvertTo-Completion -ResultType ParameterName -ToolTip '--gui'
                }
            ) {
                "git $Command $Left" | Complete-FromLine -Right $Right | Should -BeCompletion $Expected
            }
        }

        It '<Line>' -ForEach @(
            @{
                Line     = 'src -- -';
                Expected = @()
            },
            @{
                Line     = 'src -- --';
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

    It 'ShortOptions' {
        $expected = @{
            ListItemText = '-g';
            ToolTip      = "--gui"
        },
        @{
            ListItemText = '-O';
            ToolTip      = "Process files in the order specified"
        },
        @{
            ListItemText = '-y';
            ToolTip      = "Don’t prompt before each invocation of the merge resolution program"
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
                Line     = '--';
                Expected = '--tool=', '--prompt', '--no-prompt', '--gui', '--no-gui' | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-';
                Expected = '--no-prompt', '--no-gui' | ConvertTo-Completion -ResultType ParameterName
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
                    "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "--tool=$_"
                }
            },
            @{
                Line     = '--tool=v';
                Expected = 'vimdiff' | ForEach-Object {
                    "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "--tool=$_"
                }
            },
            @{
                Line     = '--tool t';
                Expected = 'tkdiff', 'tortoisemerge' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--tool v';
                Expected = 'vimdiff' | ConvertTo-Completion -ResultType ParameterValue
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }
}