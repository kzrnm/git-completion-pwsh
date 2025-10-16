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
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip '--quiet'
                },
                @{
                    Left     = '--quiet';
                    Right    = ' -- --all';
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip '--quiet'
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

        Describe-Revlist {
            "git $Command -- $Line" | Complete-FromLine | Should -BeCompletion $expected
            "git $Command -q -- $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    It 'ShortOptions' {
        $expected = @{
            ListItemText = '-a';
            ToolTip      = "treat all files as text";
        },
        @{
            ListItemText = '-b';
            ToolTip      = "ignore changes in amount of whitespace";
        },
        @{
            ListItemText = '-B';
            ToolTip      = "break complete rewrite changes into pairs of delete and create";
        },
        @{
            ListItemText = '-C';
            ToolTip      = "detect copies";
        },
        @{
            ListItemText = '-D';
            ToolTip      = "omit the preimage for deletes";
        },
        @{
            ListItemText = '-G';
            ToolTip      = "look for differences that change the number of occurrences of the specified regex";
        },
        @{
            ListItemText = '-I';
            ToolTip      = "ignore changes whose all lines match <regex>";
        },
        @{
            ListItemText = '-l';
            ToolTip      = "prevent rename/copy detection if the number of rename/copy targets exceeds given limit";
        },
        @{
            ListItemText = '-M';
            ToolTip      = "detect renames";
        },
        @{
            ListItemText = '-O';
            ToolTip      = "control the order in which files appear in the output";
        },
        @{
            ListItemText = '-p';
            ToolTip      = "generate patch";
        },
        @{
            ListItemText = '-R';
            ToolTip      = "swap two inputs, reverse the diff";
        },
        @{
            ListItemText = '-s';
            ToolTip      = "suppress diff output";
        },
        @{
            ListItemText = '-S';
            ToolTip      = "look for differences that change the number of occurrences of the specified string";
        },
        @{
            ListItemText = '-u';
            ToolTip      = "generate patch";
        },
        @{
            ListItemText = '-U';
            ToolTip      = "generate diffs with <n> lines context";
        },
        @{
            ListItemText = '-w';
            ToolTip      = "ignore whitespace when comparing lines";
        },
        @{
            ListItemText = '-W';
            ToolTip      = "generate diffs with <n> lines context";
        },
        @{
            ListItemText = '-X';
            ToolTip      = "output the distribution of relative amount of changes for each sub-directory";
        },
        @{
            ListItemText = '-z';
            ToolTip      = "do not munge pathnames and use NULs as output field terminators in --raw or --numstat";
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
                Expected = '--raw', '--relative' | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--cr';
                Expected = '--creation-factor=' | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-d';
                Expected = '--no-dual-color' | ConvertTo-Completion -ResultType ParameterName
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe-Revlist
}