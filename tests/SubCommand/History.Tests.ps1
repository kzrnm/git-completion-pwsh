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

    It 'ShortOptions' {
        $expected = @{
            ListItemText = '-h';
            ToolTip      = "show help";
        } | ConvertTo-Completion -ResultType ParameterName
        "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
    }

    Describe 'Subcommands' {
        It '<Line>' -ForEach @(
            @{
                Line     = '';
                Expected = @{
                    ListItemText = 'drop';
                    ToolTip      = 'Remove the specified commit from the history';
                }, @{
                    ListItemText = 'fixup';
                    ToolTip      = 'Apply the currently staged changes to the specified commit';
                }, @{
                    ListItemText = 'reword';
                    ToolTip      = 'Rewrite the commit message of the specified commit';
                },
                @{
                    ListItemText = 'split';
                    ToolTip      = 'Interactively split up <commit> into two commits by choosing hunks introduced by it that will be moved into the new split-out commit';
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = 'f';
                Expected = @{
                    ListItemText = 'fixup';
                    ToolTip      = 'Apply the currently staged changes to the specified commit';
                } | ConvertTo-Completion -ResultType ParameterName
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'SubcommandCommon' -ForEach @('drop', 'fixup', 'reword', 'split') {
        BeforeAll {
            Set-Variable Subcommand $_
        }

        Describe 'DoubleDash' {
            Describe 'InRight' {
                It '<Left>(cursor)<Right>' -ForEach @(
                    @{
                        Left     = '--dry-run';
                        Right    = ' --';
                        Expected = '--dry-run' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'perform a dry-run without updating any refs'
                    },
                    @{
                        Left     = '--dry-run';
                        Right    = ' -- --all';
                        Expected = '--dry-run' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'perform a dry-run without updating any refs'
                    }
                ) {
                    "git $Command $Subcommand $Left" | Complete-FromLine -Right $Right | Should -BeCompletion $Expected
                }
            }
        }

        Describe-Revlist -Ref {
            "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'Subcommand' {
        Describe 'drop' {
            BeforeAll {
                Set-Variable Subcommand 'drop'
            }
            It 'ShortOptions' {
                $Expected = @{
                    ListItemText = '-n';
                    ToolTip      = "perform a dry-run without updating any refs";
                }, @{
                    ListItemText = '-h';
                    ToolTip      = "show help";
                } | ConvertTo-Completion -ResultType ParameterName
                "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
            }

            Describe 'Options' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = '--';
                        Expected = @{
                            ListItemText = '--update-refs=';
                            ToolTip      = "control which refs should be updated";
                        }, @{
                            ListItemText = '--dry-run';
                            ToolTip      = "perform a dry-run without updating any refs";
                        }, @{
                            ListItemText = '--empty=';
                            ToolTip      = "how to handle descendants that become empty";
                        }, @{
                            ListItemText = '--no-dry-run';
                            ToolTip      = "[NO] perform a dry-run without updating any refs";
                        } | ConvertTo-Completion -ResultType ParameterName
                    },
                    @{
                        Line     = '--d';
                        Expected = @{
                            ListItemText = '--dry-run';
                            ToolTip      = "perform a dry-run without updating any refs";
                        } | ConvertTo-Completion -ResultType ParameterName
                    },
                    @{
                        Line     = '--no';
                        Expected = @{
                            ListItemText = '--no-dry-run';
                            ToolTip      = "[NO] perform a dry-run without updating any refs";
                        } | ConvertTo-Completion -ResultType ParameterName
                    }
                ) {
                    "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }

            Describe 'OptionValue' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = '--update-refs=';
                        Expected = @{
                            ListItemText = 'branches';
                            ToolTip      = "(default) all local branches that point to commits which are descendants of the original commit will be rewritten";
                        }, @{
                            ListItemText = 'head';
                            ToolTip      = "only the current HEAD reference will be rewritten";
                        } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--update-refs=$_" }
                    },
                    @{
                        Line     = '--update-refs=h';
                        Expected = @{
                            ListItemText = 'head';
                            ToolTip      = "only the current HEAD reference will be rewritten";
                        } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--update-refs=$_" }
                    },
                    @{
                        Line     = '--empty=';
                        Expected = @{
                            ListItemText = 'drop';
                            ToolTip      = "(default) empty commits are removed from the rewritten history";
                        }, @{
                            ListItemText = 'keep';
                            ToolTip      = "empty commits are retained in the rewritten history as-is";
                        }, @{
                            ListItemText = 'abort';
                            ToolTip      = "the command stops with an error if any commit would become empty";
                        } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--empty=$_" }
                    },
                    @{
                        Line     = '--empty=k';
                        Expected = @{
                            ListItemText = 'keep';
                            ToolTip      = "empty commits are retained in the rewritten history as-is";
                        } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--empty=$_" }
                    }
                ) {
                    "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
        }
    
        Describe 'fixup' {
            BeforeAll {
                Set-Variable Subcommand 'fixup'
            }
            It 'ShortOptions' {
                $Expected = @{
                    ListItemText = '-n';
                    ToolTip      = "perform a dry-run without updating any refs";
                }, @{
                    ListItemText = '-h';
                    ToolTip      = "show help";
                } | ConvertTo-Completion -ResultType ParameterName
                "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
            }

            Describe 'Options' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = '--';
                        Expected = @{
                            ListItemText = '--update-refs=';
                            ToolTip      = "control which refs should be updated";
                        }, @{
                            ListItemText = '--dry-run';
                            ToolTip      = "perform a dry-run without updating any refs";
                        }, @{
                            ListItemText = '--reedit-message';
                            ToolTip      = "open an editor to modify the commit message";
                        }, @{
                            ListItemText = '--empty=';
                            ToolTip      = "how to handle commits that become empty";
                        }, @{
                            ListItemText = '--no-dry-run';
                            ToolTip      = "[NO] perform a dry-run without updating any refs";
                        }, @{
                            CompletionText = '--no-';
                            ListItemText   = '--no-...';
                            ResultType     = 'Text';
                            ToolTip        = '--no-...';
                        } | ConvertTo-Completion -ResultType ParameterName
                    },
                    @{
                        Line     = '--d';
                        Expected = @{
                            ListItemText = '--dry-run';
                            ToolTip      = "perform a dry-run without updating any refs";
                        } | ConvertTo-Completion -ResultType ParameterName
                    },
                    @{
                        Line     = '--no';
                        Expected = @{
                            ListItemText = '--no-dry-run';
                            ToolTip      = "[NO] perform a dry-run without updating any refs";
                        }, @{
                            CompletionText = '--no-';
                            ListItemText   = '--no-...';
                            ResultType     = 'Text';
                            ToolTip        = '--no-...';
                        } | ConvertTo-Completion -ResultType ParameterName
                    },
                    @{
                        Line     = '--no-';
                        Expected = @{
                            ListItemText = '--no-dry-run';
                            ToolTip      = "[NO] perform a dry-run without updating any refs";
                        }, @{
                            ListItemText = '--no-reedit-message';
                            ToolTip      = "[NO] open an editor to modify the commit message";
                        } | ConvertTo-Completion -ResultType ParameterName
                    }
                ) {
                    "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }

            Describe 'OptionValue' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = '--update-refs=';
                        Expected = @{
                            ListItemText = 'branches';
                            ToolTip      = "(default) all local branches that point to commits which are descendants of the original commit will be rewritten";
                        }, @{
                            ListItemText = 'head';
                            ToolTip      = "only the current HEAD reference will be rewritten";
                        } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--update-refs=$_" }
                    },
                    @{
                        Line     = '--update-refs=h';
                        Expected = @{
                            ListItemText = 'head';
                            ToolTip      = "only the current HEAD reference will be rewritten";
                        } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--update-refs=$_" }
                    },
                    @{
                        Line     = '--empty=';
                        Expected = @{
                            ListItemText = 'drop';
                            ToolTip      = "(default) empty commits are removed from the rewritten history";
                        }, @{
                            ListItemText = 'keep';
                            ToolTip      = "empty commits are retained in the rewritten history as-is";
                        }, @{
                            ListItemText = 'abort';
                            ToolTip      = "the command stops with an error if any commit would become empty";
                        } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--empty=$_" }
                    },
                    @{
                        Line     = '--empty=k';
                        Expected = @{
                            ListItemText = 'keep';
                            ToolTip      = "empty commits are retained in the rewritten history as-is";
                        } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--empty=$_" }
                    }
                ) {
                    "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
        }
    
        Describe 'reword' {
            BeforeAll {
                Set-Variable Subcommand 'reword'
            }
            It 'ShortOptions' {
                $Expected = @{
                    ListItemText = '-n';
                    ToolTip      = "perform a dry-run without updating any refs";
                }, @{
                    ListItemText = '-h';
                    ToolTip      = "show help";
                } | ConvertTo-Completion -ResultType ParameterName
                "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
            }

            Describe 'Options' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = '--';
                        Expected = @{
                            ListItemText = '--update-refs=';
                            ToolTip      = "control which refs should be updated";
                        }, @{
                            ListItemText = '--dry-run';
                            ToolTip      = "perform a dry-run without updating any refs";
                        }, @{
                            ListItemText = '--no-dry-run';
                            ToolTip      = "[NO] perform a dry-run without updating any refs";
                        } | ConvertTo-Completion -ResultType ParameterName
                    },
                    @{
                        Line     = '--d';
                        Expected = @{
                            ListItemText = '--dry-run';
                            ToolTip      = "perform a dry-run without updating any refs";
                        } | ConvertTo-Completion -ResultType ParameterName
                    },
                    @{
                        Line     = '--no';
                        Expected = @{
                            ListItemText = '--no-dry-run';
                            ToolTip      = "[NO] perform a dry-run without updating any refs";
                        } | ConvertTo-Completion -ResultType ParameterName
                    }
                ) {
                    "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }

            Describe 'OptionValue' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = '--update-refs=';
                        Expected = @{
                            ListItemText = 'branches';
                            ToolTip      = "(default) all local branches that point to commits which are descendants of the original commit will be rewritten";
                        }, @{
                            ListItemText = 'head';
                            ToolTip      = "only the current HEAD reference will be rewritten";
                        } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--update-refs=$_" }
                    },
                    @{
                        Line     = '--update-refs=h';
                        Expected = @{
                            ListItemText = 'head';
                            ToolTip      = "only the current HEAD reference will be rewritten";
                        } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--update-refs=$_" }
                    }
                ) {
                    "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
        }

        Describe 'split' {
            BeforeAll {
                Set-Variable Subcommand 'split'
            }
            It 'ShortOptions' {
                $Expected = @{
                    ListItemText = '-n';
                    ToolTip      = "perform a dry-run without updating any refs";
                }, @{
                    ListItemText = '-h';
                    ToolTip      = "show help";
                } | ConvertTo-Completion -ResultType ParameterName
                "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
            }

            Describe 'Options' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = '--';
                        Expected = @{
                            ListItemText = '--update-refs=';
                            ToolTip      = "control ref update behavior";
                        }, @{
                            ListItemText = '--dry-run';
                            ToolTip      = "perform a dry-run without updating any refs";
                        }, @{
                            ListItemText = '--no-dry-run';
                            ToolTip      = "[NO] perform a dry-run without updating any refs";
                        } | ConvertTo-Completion -ResultType ParameterName
                    },
                    @{
                        Line     = '--d';
                        Expected = @{
                            ListItemText = '--dry-run';
                            ToolTip      = "perform a dry-run without updating any refs";
                        } | ConvertTo-Completion -ResultType ParameterName
                    },
                    @{
                        Line     = '--no';
                        Expected = @{
                            ListItemText = '--no-dry-run';
                            ToolTip      = "[NO] perform a dry-run without updating any refs";
                        } | ConvertTo-Completion -ResultType ParameterName
                    }
                ) {
                    "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }

            Describe 'OptionValue' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = '--update-refs=';
                        Expected = @{
                            ListItemText = 'branches';
                            ToolTip      = "(default) all local branches that point to commits which are descendants of the original commit will be rewritten";
                        }, @{
                            ListItemText = 'head';
                            ToolTip      = "only the current HEAD reference will be rewritten";
                        } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--update-refs=$_" }
                    },
                    @{
                        Line     = '--update-refs=h';
                        Expected = @{
                            ListItemText = 'head';
                            ToolTip      = "only the current HEAD reference will be rewritten";
                        } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--update-refs=$_" }
                    }
                ) {
                    "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }

            It 'File:<Line>' -ForEach @(
                @{
                    Line     = '';
                    Expected = '.gitignore', 'hello.sh', 'initial.txt', 'Pwsh/world.ps1' | ConvertTo-Completion -ResultType ProviderItem;
                },
                @{
                    Line     = '';
                    Expected = '.gitignore', 'hello.sh', 'initial.txt', 'Pwsh/world.ps1' | ConvertTo-Completion -ResultType ProviderItem;
                }
            ) {
                "git $Command $Subcommand HEAD -- $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
}