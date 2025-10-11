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

        $ErrorActionPreference = 'SilentlyContinue'
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
                    Left     = '--ff';
                    Right    = ' --';
                    Expected = '--ff' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'allow fast-forward'
                },
                @{
                    Left     = '--ff';
                    Right    = ' -- --all';
                    Expected = '--ff' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'allow fast-forward'
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
            ToolTip      = "edit the commit message";
        },
        @{
            ListItemText = '-m';
            ToolTip      = "select mainline parent";
        },
        @{
            ListItemText = '-n';
            ToolTip      = "don't automatically commit";
        },
        @{
            ListItemText = '-s';
            ToolTip      = "add a Signed-off-by trailer";
        },
        @{
            ListItemText = '-S';
            ToolTip      = "GPG sign commit";
        },
        @{
            ListItemText = '-x';
            ToolTip      = "append commit name";
        },
        @{
            ListItemText = '-X';
            ToolTip      = "option for merge strategy";
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
                Line     = '--e';
                Expected = @{
                    ListItemText = '--edit';
                    ToolTip      = "edit the commit message";
                },
                @{
                    ListItemText = '--empty=';
                    ToolTip      = "how to handle commits that become empty";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--f';
                Expected = @{
                    ListItemText = '--ff';
                    ToolTip      = "allow fast-forward";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-e';
                Expected = @{
                    ListItemText = '--no-edit';
                    ToolTip      = "[NO] edit the commit message";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-f';
                Expected = @{
                    ListItemText = '--no-ff';
                    ToolTip      = "[NO] allow fast-forward";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no';
                Expected = @{
                    ListItemText = '--no-commit';
                    ToolTip      = "don't automatically commit";
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


    Describe 'InProgress' {
        BeforeAll {
            git cherry-pick HEAD~ 2>$null
        }
        AfterAll {
            git cherry-pick --abort 2>$null
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '';
                    Expected = @{
                        ListItemText = '--abort'
                        ToolTip      = 'cancel revert or cherry-pick sequence';
                    },
                    @{
                        ListItemText = '--continue'
                        ToolTip      = 'resume revert or cherry-pick sequence';
                    },
                    @{
                        ListItemText = '--quit'
                        ToolTip      = 'end revert or cherry-pick sequence';
                    },
                    @{
                        ListItemText = '--skip'
                        ToolTip      = 'skip current commit and continue';
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '-';
                    Expected = @{
                        ListItemText = '--abort'
                        ToolTip      = 'cancel revert or cherry-pick sequence';
                    },
                    @{
                        ListItemText = '--continue'
                        ToolTip      = 'resume revert or cherry-pick sequence';
                    },
                    @{
                        ListItemText = '--quit'
                        ToolTip      = 'end revert or cherry-pick sequence';
                    },
                    @{
                        ListItemText = '--skip'
                        ToolTip      = 'skip current commit and continue';
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--';
                    Expected = @{
                        ListItemText = '--abort'
                        ToolTip      = 'cancel revert or cherry-pick sequence';
                    },
                    @{
                        ListItemText = '--continue'
                        ToolTip      = 'resume revert or cherry-pick sequence';
                    },
                    @{
                        ListItemText = '--quit'
                        ToolTip      = 'end revert or cherry-pick sequence';
                    },
                    @{
                        ListItemText = '--skip'
                        ToolTip      = 'skip current commit and continue';
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--c';
                    Expected = @{
                        ListItemText = '--continue'
                        ToolTip      = 'resume revert or cherry-pick sequence';
                    } | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
}