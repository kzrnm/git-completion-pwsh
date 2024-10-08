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
                    Left     = '--list';
                    Right    = ' --';
                    Expected = '--list' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'list supported archive formats'
                },
                @{
                    Left     = '--list';
                    Right    = ' -- --all';
                    Expected = '--list' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'list supported archive formats'
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

        Describe-Revlist -Ref {
            "git $Command -- $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    It 'ShortOptions' {
        $expected = @{
            ListItemText = '-0';
            ToolTip      = "set compression level";
        },
        @{
            ListItemText = '-1';
            ToolTip      = "set compression level";
        },
        @{
            ListItemText = '-2';
            ToolTip      = "set compression level";
        },
        @{
            ListItemText = '-3';
            ToolTip      = "set compression level";
        },
        @{
            ListItemText = '-4';
            ToolTip      = "set compression level";
        },
        @{
            ListItemText = '-5';
            ToolTip      = "set compression level";
        },
        @{
            ListItemText = '-6';
            ToolTip      = "set compression level";
        },
        @{
            ListItemText = '-7';
            ToolTip      = "set compression level";
        },
        @{
            ListItemText = '-8';
            ToolTip      = "set compression level";
        },
        @{
            ListItemText = '-9';
            ToolTip      = "set compression level";
        },
        @{
            ListItemText = '-l';
            ToolTip      = "list supported archive formats";
        },
        @{
            ListItemText = '-o';
            ToolTip      = "write the archive to this file";
        },
        @{
            ListItemText = '-v';
            ToolTip      = "report archived files on stderr";
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
                Line     = '--l';
                Expected = '--list' | ConvertTo-Completion -ResultType ParameterName -ToolTip "list supported archive formats"
            },
            @{
                Line     = '--f';
                Expected = '--format=' | ConvertTo-Completion -ResultType ParameterName -ToolTip "archive format"
            },
            @{
                Line     = '--no-';
                Expected = @{
                    ListItemText = '--no-output';
                    ToolTip      = "[NO] write the archive to this file"
                },
                @{
                    ListItemText = '--no-remote';
                    ToolTip      = "[NO] retrieve the archive from remote repository <repo>"
                },
                @{
                    ListItemText = '--no-exec';
                    ToolTip      = "[NO] path to the remote git-upload-archive command"
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no';
                Expected = @{
                    ListItemText = '--no-output';
                    ToolTip      = "[NO] write the archive to this file"
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
        BeforeAll {
            InModuleScope git-completion {
                Mock gitArchiveList { 
                    return 'tar',
                    'tgz',
                    'tar.gz',
                    'zip'
                }
            }
        }
        It '<Line>' -ForEach @(
            @{
                Line     = '--format=';
                Expected = 'tar', 'tgz', 'tar.gz', 'zip' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--format=$_" }
            },
            @{
                Line     = '--format ';
                Expected = 'tar', 'tgz', 'tar.gz', 'zip' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--format=t';
                Expected = 'tar', 'tgz', 'tar.gz' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--format=$_" }
            },
            @{
                Line     = '--format t';
                Expected = 'tar', 'tgz', 'tar.gz' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--remote=';
                Expected = 'grm', 'ordinary', 'origin' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--remote=$_" }
            },
            @{
                Line     = '--remote ';
                Expected = 'grm', 'ordinary', 'origin' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--remote=o';
                Expected = 'ordinary', 'origin' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--remote=$_" }
            },
            @{
                Line     = '--remote o';
                Expected = 'ordinary', 'origin' | ConvertTo-Completion -ResultType ParameterValue
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe-Revlist
}