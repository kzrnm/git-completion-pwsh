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
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'be more quiet'
                },
                @{
                    Left     = '--quiet';
                    Right    = ' -- --all';
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'be more quiet'
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
        $Expected = @{
            ListItemText = '-e';
            ToolTip      = "edit message before committing";
        },
        @{
            ListItemText = '-F';
            ToolTip      = "read message from file";
        },
        @{
            ListItemText = '-m';
            ToolTip      = "merge commit message (for a non-fast-forward merge)";
        },
        @{
            ListItemText = '-n';
            ToolTip      = "do not show a diffstat at the end of the merge";
        },
        @{
            ListItemText = '-q';
            ToolTip      = "be more quiet";
        },
        @{
            ListItemText = '-s';
            ToolTip      = "merge strategy to use";
        },
        @{
            ListItemText = '-S';
            ToolTip      = "GPG sign commit";
        },
        @{
            ListItemText = '-v';
            ToolTip      = "be more verbose";
        },
        @{
            ListItemText = '-X';
            ToolTip      = "option for selected merge strategy";
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
                Line     = '--f';
                Expected = @{
                    ListItemText = '--ff';
                    ToolTip      = "allow fast-forward (default)";
                },
                @{
                    ListItemText = '--ff-only';
                    ToolTip      = "abort if fast-forward is not possible";
                },
                @{
                    ListItemText = '--file';
                    ToolTip      = "read message from file";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-f';
                Expected = @{
                    ListItemText = '--no-ff';
                    ToolTip      = "[NO] allow fast-forward (default)";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no';
                Expected = @{
                    ListItemText = '--no-verify';
                    ToolTip      = "bypass pre-merge-commit and commit-msg hooks";
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
        Describe 'CompleteStrategy' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '-s ';
                    Expected = @(
                        'octopus',
                        'ours',
                        'recursive',
                        'resolve',
                        'subtree'
                    ) | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '-s o';
                    Expected = @(
                        'octopus',
                        'ours'
                    ) | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--strategy ';
                    Expected = @(
                        'octopus',
                        'ours',
                        'recursive',
                        'resolve',
                        'subtree'
                    ) | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--strategy o';
                    Expected = @(
                        'octopus',
                        'ours'
                    ) | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--strategy=o';
                    Expected = @(
                        'octopus',
                        'ours'
                    ) | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--strategy=$_" }
                },
                @{
                    Line     = '--strategy-option ';
                    Expected = @{
                        ListItemText = 'diff-algorithm=';
                        Tooltip      = 'Use a different diff algorithm while merging';
                    },
                    @{
                        ListItemText = 'find-renames';
                        Tooltip      = 'Turn on rename detection';
                    },
                    @{
                        ListItemText = 'find-renames=';
                        Tooltip      = 'Turn on rename detection, optionally setting the similarity threshold';
                    },
                    @{
                        ListItemText = 'histogram';
                        Tooltip      = 'Deprecated synonym for diff-algorithm=histogram';
                    },
                    @{
                        ListItemText = 'ignore-all-space';
                        Tooltip      = 'Ignore whitespace when comparing lines';
                    },
                    @{
                        ListItemText = 'ignore-space-at-eol';
                        Tooltip      = 'Ignore changes in whitespace at EOL';
                    },
                    @{
                        ListItemText = 'ignore-space-change';
                        Tooltip      = 'Ignore changes in amount of whitespace';
                    },
                    @{
                        ListItemText = 'no-renames';
                        Tooltip      = 'Turn off rename detection';
                    },
                    @{
                        ListItemText = 'no-renormalize';
                        Tooltip      = '[NO] runs a virtual check-out and check-in of all three stages';
                    },
                    @{
                        ListItemText = 'ours';
                        Tooltip      = 'favoring our version';
                    },
                    @{
                        ListItemText = 'patience';
                        Tooltip      = 'Deprecated synonym for diff-algorithm=patience';
                    },
                    @{
                        ListItemText = 'rename-threshold=';
                        Tooltip      = 'Deprecated synonym for find-renames=';
                    },
                    @{
                        ListItemText = 'renormalize';
                        Tooltip      = 'runs a virtual check-out and check-in of all three stages';
                    },
                    @{
                        ListItemText = 'subtree';
                        Tooltip      = 'A more advanced form of subtree strategy';
                    },
                    @{
                        ListItemText = 'subtree=';
                        Tooltip      = 'A more advanced form of subtree strategy';
                    },
                    @{
                        ListItemText = 'theirs';
                        Tooltip      = 'opposite of ours';
                    } | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--strategy-option r';
                    Expected = @{
                        ListItemText = 'rename-threshold=';
                        Tooltip      = 'Deprecated synonym for find-renames=';
                    },
                    @{
                        ListItemText = 'renormalize';
                        Tooltip      = 'runs a virtual check-out and check-in of all three stages';
                    } | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--strategy-option=r';
                    Expected = @{
                        ListItemText = 'rename-threshold=';
                        Tooltip      = 'Deprecated synonym for find-renames=';
                    },
                    @{
                        ListItemText = 'renormalize';
                        Tooltip      = 'runs a virtual check-out and check-in of all three stages';
                    } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--strategy-option=$_" }
                }
            ) {
                "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe-Revlist -Ref
}