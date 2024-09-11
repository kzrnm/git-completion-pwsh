# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Collections.Generic;
using namespace System.IO;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') -Tag Remote {
    BeforeAll {
        Set-Variable Command ((Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') | ConvertTo-KebabCase)
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

    Describe 'DoubleDash' {
        Describe 'InRight' {
            It '<Left>(cursor)<Right>' -ForEach @(
                @{
                    Left     = '--quiet';
                    Right    = ' --';
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'do not print remote URL'
                },
                @{
                    Left     = '--quiet';
                    Right    = ' -- --quiet';
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'do not print remote URL'
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
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    It 'ShortOptions' {
        $Expected = @{
            ListItemText = '-b';
            ToolTip      = "limit to branches";
        },
        @{
            ListItemText = '-o';
            ToolTip      = "option to transmit";
        },
        @{
            ListItemText = '-q';
            ToolTip      = "do not print remote URL";
        },
        @{
            ListItemText = '-t';
            ToolTip      = "limit to tags";
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
                Line     = '--r';
                Expected = @{
                    ListItemText = '--refs';
                    ToolTip      = "do not show peeled tags";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--s';
                Expected = @{
                    ListItemText = '--sort=';
                    ToolTip      = "field name to sort on";
                },
                @{
                    ListItemText = '--symref';
                    ToolTip      = "show underlying ref in addition to the object pointed by it";
                },
                @{
                    ListItemText = '--server-option=';
                    ToolTip      = "option to transmit";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-s';
                Expected = @{
                    ListItemText = '--no-sort';
                    ToolTip      = "[NO] field name to sort on";
                },
                @{
                    ListItemText = '--no-symref';
                    ToolTip      = "[NO] show underlying ref in addition to the object pointed by it";
                },
                @{
                    ListItemText = '--no-server-option';
                    ToolTip      = "[NO] option to transmit";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-q';
                Expected = @{
                    ListItemText = '--no-quiet';
                    ToolTip      = "[NO] do not print remote URL";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no';
                Expected = @{
                    ListItemText = '--no-quiet';
                    ToolTip      = "[NO] do not print remote URL";
                },
                @{
                    CompletionText = '--no-';
                    ListItemText   = '--no-...';
                    ResultType     = 'Text';
                } | ConvertTo-Completion -ResultType ParameterName
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'Remote' {
        It '<Line>' -ForEach @(
            @{
                Line     = ' ';
                Expected = 'grm', 'ordinary', 'origin' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '-- ';
                Expected = 'grm', 'ordinary', 'origin' | ConvertTo-Completion -ResultType ParameterValue
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }
}