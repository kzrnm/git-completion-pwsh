using namespace System.Collections.Generic;
using namespace System.IO;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') {
    BeforeAll {
        Set-Variable Command ((Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') | ConvertTo-KebabCase)
        Initialize-Home
    }

    AfterAll {
        Restore-Home
        Pop-Location
    }

    Describe 'DoubleDash' {
        Describe 'InRight' {
            It '<Left>(cursor)<Right>' -ForEach @(
                @{
                    Left     = '--rerere-autoupdate';
                    Right    = ' --';
                    Expected = '--rerere-autoupdate' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'register clean resolutions in index'
                },
                @{
                    Left     = '--rerere-autoupdate';
                    Right    = ' -- --all';
                    Expected = '--rerere-autoupdate' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'register clean resolutions in index'
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
        $Expected = @{
            ListItemText = '-h';
            ToolTip      = "show help";
        } | ConvertTo-Completion -ResultType ParameterName
        "git $Command -" | Complete-FromLine | Should -BeCompletion $expected
    }

    Describe 'Options' {
        It '<Line>' -ForEach @(
            @{
                Line     = '--';
                Expected = @{
                    ListItemText = '--rerere-autoupdate';
                    ToolTip      = "register clean resolutions in index";
                },
                @{
                    ListItemText = '--no-rerere-autoupdate';
                    ToolTip      = "[NO] register clean resolutions in index";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--r';
                Expected = @{
                    ListItemText = '--rerere-autoupdate';
                    ToolTip      = "register clean resolutions in index";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no';
                Expected = @{
                    ListItemText = '--no-rerere-autoupdate';
                    ToolTip      = "[NO] register clean resolutions in index";
                } | ConvertTo-Completion -ResultType ParameterName
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'Subcommand' {
        It '<Line>' -ForEach @(
            @{
                Line     = '';
                Expected =
                'clear',
                'forget',
                'diff',
                'remaining',
                'status',
                'gc' | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = 'f';
                Expected = 'forget' | ConvertTo-Completion -ResultType ParameterName
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }
}