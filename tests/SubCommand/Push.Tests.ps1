# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Collections.Generic;

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
                Line     = '-- -';
                Expected = @()
            },
            @{
                Line     = '-- --';
                Expected = @()
            },
            @{
                Line     = 'origin -- -';
                Expected = @()
            },
            @{
                Line     = 'origin -- --';
                Expected = @()
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    It 'ShortOptions' {
        $expected = @{
            ListItemText = '-4';
            ToolTip      = "use IPv4 addresses only";
        },
        @{
            ListItemText = '-6';
            ToolTip      = "use IPv6 addresses only";
        },
        @{
            ListItemText = '-d';
            ToolTip      = "delete refs";
        },
        @{
            ListItemText = '-f';
            ToolTip      = "force updates";
        },
        @{
            ListItemText = '-n';
            ToolTip      = "dry run";
        },
        @{
            ListItemText = '-o';
            ToolTip      = "option to transmit";
        },
        @{
            ListItemText = '-q';
            ToolTip      = "be more quiet";
        },
        @{
            ListItemText = '-u';
            ToolTip      = "set upstream for git pull/status";
        },
        @{
            ListItemText = '-v';
            ToolTip      = "be more verbose";
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
                Line     = '--re';
                Expected = @{
                    ListItemText = '--repo=';
                    ToolTip      = "repository";
                },
                @{
                    ListItemText = '--recurse-submodules=';
                    ToolTip      = "control recursive pushing of submodules";
                },
                @{
                    ListItemText = '--receive-pack=';
                    ToolTip      = "receive pack program";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--re';
                Expected = @{
                    ListItemText = '--repo=';
                    ToolTip      = "repository";
                },
                @{
                    ListItemText = '--recurse-submodules=';
                    ToolTip      = "control recursive pushing of submodules";
                },
                @{
                    ListItemText = '--receive-pack=';
                    ToolTip      = "receive pack program";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-re';
                Expected = @{
                    ListItemText = '--no-repo';
                    ToolTip      = "[NO] repository";
                },
                @{
                    ListItemText = '--no-recurse-submodules';
                    ToolTip      = "[NO] control recursive pushing of submodules";
                },
                @{
                    ListItemText = '--no-receive-pack';
                    ToolTip      = "[NO] receive pack program";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--n';
                Expected = @{
                    ListItemText = '--no-verify';
                    ToolTip      = "bypass pre-push hook";
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
        Describe 'noCompleteRefspec' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--mirror ';
                    Expected = 
                    'grm',
                    'ordinary',
                    'origin' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--mirror or';
                    Expected = 
                    'ordinary',
                    'origin' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--mirror origin ';
                    Expected = @()
                },
                @{
                    Line     = '--all ';
                    Expected = 
                    'grm',
                    'ordinary',
                    'origin' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--all or';
                    Expected = 
                    'ordinary',
                    'origin' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--all origin ';
                    Expected = @()
                }
            ) {
                "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
        It '<Line>' -ForEach @(
            @{
                Line     = '--force-with-lease=';
                Expected = 
                'HEAD',
                'FETCH_HEAD',
                'main',
                'grm/HEAD',
                'grm/develop',
                'ordinary/HEAD',
                'ordinary/develop',
                'origin/HEAD',
                'origin/develop',
                'initial',
                'zeta' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--force-with-lease=$_" }
            },
            @{
                Line     = '--force-with-lease=or';
                Expected = 
                'ordinary/HEAD',
                'ordinary/develop',
                'origin/HEAD',
                'origin/develop' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--force-with-lease=$_" }
            },
            @{
                Line     = '--force-with-lease=ma:';
                Expected = 
                'HEAD',
                'FETCH_HEAD',
                'main',
                'grm/HEAD',
                'grm/develop',
                'ordinary/HEAD',
                'ordinary/develop',
                'origin/HEAD',
                'origin/develop',
                'initial',
                'zeta' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--force-with-lease=ma:$_" }
            },
            @{
                Line     = '--force-with-lease=ma:or';
                Expected = 
                'ordinary/HEAD',
                'ordinary/develop',
                'origin/HEAD',
                'origin/develop' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--force-with-lease=ma:$_" }
            },
            @{
                Line     = '--recurse-submodules ';
                Expected = @{
                    ListItemText = 'check';
                    Tooltip      = 'verify that all submodule commits that changed in the revisions to be pushed are available on at least one remote of the submodule';
                },
                @{
                    ListItemText = 'on-demand';
                    Tooltip      = 'all submodules that changed in the revisions to be pushed will be pushed';
                },
                @{
                    ListItemText = 'only';
                    Tooltip      = 'all submodules will be pushed while the superproject is left unpushed';
                },
                @{
                    ListItemText = 'no';
                    Tooltip      = '(default) no submodules are pushed';
                } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--recurse-submodules c';
                Expected = @{
                    ListItemText = 'check';
                    Tooltip      = 'verify that all submodule commits that changed in the revisions to be pushed are available on at least one remote of the submodule';
                } | ConvertTo-Completion -ResultType ParameterValue -ToolTip "check"
            },
            @{
                Line     = '--recurse-submodules=';
                Expected = @{
                    ListItemText = 'check';
                    Tooltip      = 'verify that all submodule commits that changed in the revisions to be pushed are available on at least one remote of the submodule';
                },
                @{
                    ListItemText = 'on-demand';
                    Tooltip      = 'all submodules that changed in the revisions to be pushed will be pushed';
                },
                @{
                    ListItemText = 'only';
                    Tooltip      = 'all submodules will be pushed while the superproject is left unpushed';
                },
                @{
                    ListItemText = 'no';
                    Tooltip      = '(default) no submodules are pushed';
                } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--recurse-submodules=$_" }
            },
            @{
                Line     = '--recurse-submodules=c';
                Expected = @{
                    ListItemText = 'check';
                    Tooltip      = 'verify that all submodule commits that changed in the revisions to be pushed are available on at least one remote of the submodule';
                } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--recurse-submodules=$_" }
            },
            @{
                Line     = '--repo=';
                Expected = 
                @{
                    CompletionText = '--repo=grm';
                    ListItemText   = 'grm';
                },
                @{
                    CompletionText = '--repo=ordinary';
                    ListItemText   = 'ordinary';
                },
                @{
                    CompletionText = '--repo=origin';
                    ListItemText   = 'origin';
                } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--repo=or';
                Expected = 
                @{
                    CompletionText = '--repo=ordinary';
                    ListItemText   = 'ordinary';
                },
                @{
                    CompletionText = '--repo=origin';
                    ListItemText   = 'origin';
                } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--repo ';
                Expected = 
                'grm',
                'ordinary',
                'origin' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--repo or';
                Expected = 
                'ordinary',
                'origin' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--delete ';
                Expected = 
                'grm',
                'ordinary',
                'origin' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '-d ';
                Expected = 
                'grm',
                'ordinary',
                'origin' | ConvertTo-Completion -ResultType ParameterValue
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'RemoteOrRefspec' {
        Describe '<Line>' -ForEach @(
            @{
                Line     = 'origin ';
                Expected = 
                'HEAD',
                'FETCH_HEAD',
                'main',
                'grm/HEAD',
                'grm/develop',
                'ordinary/HEAD',
                'ordinary/develop',
                'origin/HEAD',
                'origin/develop',
                'initial',
                'zeta' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = 'origin o';
                Expected = 
                'ordinary/HEAD',
                'ordinary/develop',
                'origin/HEAD',
                'origin/develop' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = 'origin ^';
                Expected = 
                'HEAD',
                'FETCH_HEAD',
                'main',
                'grm/HEAD',
                'grm/develop',
                'ordinary/HEAD',
                'ordinary/develop',
                'origin/HEAD',
                'origin/develop',
                'initial',
                'zeta' | ForEach-Object { "^$_" } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = 'origin ^o';
                Expected = 
                'ordinary/HEAD',
                'ordinary/develop',
                'origin/HEAD',
                'origin/develop' | ForEach-Object { "^$_" } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = 'origin +';
                Expected = 
                'HEAD',
                'FETCH_HEAD',
                'main',
                'grm/HEAD',
                'grm/develop',
                'ordinary/HEAD',
                'ordinary/develop',
                'origin/HEAD',
                'origin/develop',
                'initial',
                'zeta' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "+$_" }
            },
            @{
                Line     = 'origin +o';
                Expected = 
                'ordinary/HEAD',
                'ordinary/develop',
                'origin/HEAD',
                'origin/develop' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "+$_" }
            },
            @{
                Line     = 'origin left:';
                Expected = 'HEAD', 'develop' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "left:$_" }
            },
            @{
                Line     = 'origin left:d';
                Expected = 
                'develop' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "left:$_" }
            },
            @{
                Line     = 'or';
                Expected = 
                'ordinary',
                'origin' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '';
                Expected = 
                'grm',
                'ordinary',
                'origin' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = 'origin refs';
                Expected = 
                'refs/heads/main',
                'refs/remotes/grm/HEAD',
                'refs/remotes/grm/develop',
                'refs/remotes/ordinary/HEAD',
                'refs/remotes/ordinary/develop',
                'refs/remotes/origin/HEAD',
                'refs/remotes/origin/develop',
                'refs/tags/initial',
                'refs/tags/zeta' | ForEach-Object { @{
                        ListItemText = $_;
                        ToolTip      = $RemoteCommits[$_ -replace '^refs/[^/]+/', ''].ToolTip;
                    } } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = 'origin refs/h';
                Expected = 
                'refs/heads/main' | ForEach-Object { @{
                        ListItemText = $_;
                        ToolTip      = $RemoteCommits[$_ -replace '^refs/[^/]+/', ''].ToolTip;
                    } } | ConvertTo-Completion -ResultType ParameterValue
            }
        ) {
            
            Describe 'DoubleDash' {
                It '<DoubleDash>' -ForEach @('--', '--quiet --' | ForEach-Object { @{DoubleDash = $_; } }) {
                    "git $Command $DoubleDash $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }

            It '_' {
                "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'Middle' {
        It '<Line>(cursor) <Right>' -ForEach @(
            @{
                Line     = 'o';
                Right    = ' main';
                Expected = 
                'ordinary',
                'origin' | ConvertTo-Completion -ResultType ParameterValue
            }
        ) {
            "git $Command $Line" | Complete-FromLine -Right $Right | Should -BeCompletion $expected
        }
    }

    Describe 'WithSlashRemote' {
        BeforeAll {
            git remote add slash/origin "$TestDrive/gitRemote"
            git fetch slash/origin --quiet
        }

        AfterAll {
            git remote remove slash/origin
        }

        It '<Line>' -ForEach @(
            @{
                Line     = 'slash/origin :d';
                Expected = 
                @{
                    CompletionText = ':develop';
                    ListItemText   = 'develop';
                } | ConvertTo-Completion -ResultType ParameterValue
            }
        ) {
            "git $Command $Line" | Complete-FromLine -Right $Right | Should -BeCompletion $expected
        }
    }
}
