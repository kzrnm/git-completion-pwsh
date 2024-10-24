# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Collections.Generic;
using namespace System.IO;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') -Tag Remote, File {
    BeforeAll {
        InModuleScope git-completion {
            Mock gitCommitMessage {
                param([string]$ref)
                if ($ref.StartsWith('^')) {
                    return $null
                }
                if ($ref -ceq 'ORIG_HEAD') {
                    return '20ad91e Start'
                }
                return $RemoteCommits[$ref].ToolTip
            }
        }

        $ErrorActionPreference = 'SilentlyContinue'
        Set-Variable Command ((Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') | ConvertTo-KebabCase)
        Initialize-Home

        mkdir ($rootPath = "$TestDrive/gitRoot")
        mkdir ($remotePath = "$TestDrive/gitRemote")
        Initialize-FilesRepo $rootPath $remotePath
        Push-Location $rootPath
        git stash -u --message 'Aqevol' -- './Aquarion Evol'
        git stash push --message 'others'
        git switch --detach HEAD 2>$null
        git stash push --include-untracked --message 'untracked'
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
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'quiet mode'
                },
                @{
                    Left     = '--quiet';
                    Right    = ' -- --all';
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'quiet mode'
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

    Describe '<Description>' -ForEach @(
        @{
            Subcommand  = 'push';
            Description = 'push';
        },
        @{
            Subcommand  = '';
            Description = '[push]';
        }
    ) {
        It 'ShortOptions' {
            $Expected = @{
                ListItemText = '-a';
                ToolTip      = "include ignore files";
            },
            @{
                ListItemText = '-k';
                ToolTip      = "keep index";
            },
            @{
                ListItemText = '-m';
                ToolTip      = "stash message";
            },
            @{
                ListItemText = '-p';
                ToolTip      = "stash in patch mode";
            },
            @{
                ListItemText = '-q';
                ToolTip      = "quiet mode";
            },
            @{
                ListItemText = '-S';
                ToolTip      = "stash staged changes only";
            },
            @{
                ListItemText = '-u';
                ToolTip      = "include untracked files in stash";
            },
            @{
                ListItemText = '-h';
                ToolTip      = "show help";
            } | ConvertTo-Completion -ResultType ParameterName
            "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--k';
                    Expected = @{
                        ListItemText = '--keep-index';
                        ToolTip      = "keep index"
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--m';
                    Expected = @{
                        ListItemText = '--message=';
                        ToolTip      = "stash message"
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no-m';
                    Expected = @{
                        ListItemText = '--no-message';
                        ToolTip      = "[NO] stash message"
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no';
                    Expected = @{
                        ListItemText = '--no-keep-index';
                        ToolTip      = "[NO] keep index"
                    },
                    @{
                        CompletionText = '--no-';
                        ListItemText   = '--no-...';
                        ResultType     = 'Text'
                    } | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    It 'Subcommands' {
        $Expected = @{
            ListItemText = 'apply';
            ToolTip      = 'apply a single stashed state but do not remove the state';
        },
        @{
            ListItemText = 'clear';
            ToolTip      = 'remove all the stash entries';
        },
        @{
            ListItemText = 'drop';
            ToolTip      = 'remove a single stashed state';
        },
        @{
            ListItemText = 'pop';
            ToolTip      = 'remove a single stashed state and apply it';
        },
        @{
            ListItemText = 'branch';
            ToolTip      = 'creates and checks out a new branch';
        },
        @{
            ListItemText = 'list';
            ToolTip      = 'list the stash entries';
        },
        @{
            ListItemText = 'show';
            ToolTip      = 'show the changes recorded';
        },
        @{
            ListItemText = 'store';
            ToolTip      = 'store a given stash';
        },
        @{
            ListItemText = 'create';
            ToolTip      = 'create a stash entry';
        },
        @{
            ListItemText = 'push';
            ToolTip      = 'save your local modifications to a new stash entry and roll them back to HEAD (default)';
        } | ConvertTo-Completion -ResultType ParameterName
        "git $Command " | Complete-FromLine | Should -BeCompletion $Expected
    }

    Describe 'StashList:<Subcommand>' -ForEach @(
        'show',
        'drop',
        'pop',
        'apply',
        'branch m' | ForEach-Object { @{Subcommand = $_ } }
    ) {
        It '<Line>' -ForEach @(
            @{
                Line     = ' ';
                Expected = @{
                    ListItemText = 'stash@{0}';
                    ToolTip      = "On (no branch): untracked";
                },
                @{
                    ListItemText = 'stash@{1}';
                    ToolTip      = "On main: others";
                },
                @{
                    ListItemText = 'stash@{2}';
                    ToolTip      = "On main: Aqevol";
                } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "'$_'" }
            },
            @{
                Line     = "'stash@{0";
                Expected = @{
                    ListItemText = 'stash@{0}';
                    ToolTip      = "On (no branch): untracked";
                } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "'$_'" }
            }
        ) {
            "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'apply' {
        BeforeAll {
            Set-Variable Subcommand 'apply'
        }
        It 'ShortOptions' {
            $Expected = @{
                ListItemText = '-q';
                ToolTip      = "be quiet, only report errors";
            },
            @{
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
                        ListItemText = '--quiet';
                        ToolTip      = "be quiet, only report errors";
                    },
                    @{
                        ListItemText = '--index';
                        ToolTip      = "attempt to recreate the index";
                    },
                    @{
                        ListItemText = '--no-quiet';
                        ToolTip      = "[NO] be quiet, only report errors";
                    },
                    @{
                        CompletionText = '--no-';
                        ListItemText   = '--no-...';
                        ResultType     = 'Text'
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--i';
                    Expected = @{
                        ListItemText = '--index';
                        ToolTip      = "attempt to recreate the index";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no-';
                    Expected = @{
                        ListItemText = '--no-quiet';
                        ToolTip      = "[NO] be quiet, only report errors";
                    },
                    @{
                        ListItemText = '--no-index';
                        ToolTip      = "[NO] attempt to recreate the index";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no';
                    Expected = @{
                        ListItemText = '--no-quiet';
                        ToolTip      = "[NO] be quiet, only report errors";
                    },
                    @{
                        CompletionText = '--no-';
                        ListItemText   = '--no-...';
                        ResultType     = 'Text'
                    } | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
    Describe 'clear' {
        BeforeAll {
            Set-Variable Subcommand 'clear'
        }
        It 'ShortOptions' {
            $Expected = @{
                ListItemText = '-h';
                ToolTip      = "show help";
            } | ConvertTo-Completion -ResultType ParameterName
            "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected = @()
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
    Describe 'drop' {
        BeforeAll {
            Set-Variable Subcommand 'drop'
        }
        It 'ShortOptions' {
            $Expected = @{
                ListItemText = '-q';
                ToolTip      = "be quiet, only report errors";
            },
            @{
                ListItemText = '-h';
                ToolTip      = "show help";
            } | ConvertTo-Completion -ResultType ParameterName
            "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--q';
                    Expected = @{
                        ListItemText = '--quiet';
                        ToolTip      = "be quiet, only report errors";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--';
                    Expected = @{
                        ListItemText = '--quiet';
                        ToolTip      = "be quiet, only report errors";
                    },
                    @{
                        ListItemText = '--no-quiet';
                        ToolTip      = "[NO] be quiet, only report errors";
                    } | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
    Describe 'pop' {
        BeforeAll {
            Set-Variable Subcommand 'pop'
        }
        It 'ShortOptions' {
            $Expected = @{
                ListItemText = '-q';
                ToolTip      = "be quiet, only report errors";
            },
            @{
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
                        ListItemText = '--quiet';
                        ToolTip      = "be quiet, only report errors";
                    },
                    @{
                        ListItemText = '--index';
                        ToolTip      = "attempt to recreate the index";
                    },
                    @{
                        ListItemText = '--no-quiet';
                        ToolTip      = "[NO] be quiet, only report errors";
                    },
                    @{
                        CompletionText = '--no-';
                        ListItemText   = '--no-...';
                        ResultType     = 'Text';
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--q';
                    Expected = @{
                        ListItemText = '--quiet';
                        ToolTip      = "be quiet, only report errors";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no-';
                    Expected = @{
                        ListItemText = '--no-quiet';
                        ToolTip      = "[NO] be quiet, only report errors";
                    },
                    @{
                        ListItemText = '--no-index';
                        ToolTip      = "[NO] attempt to recreate the index";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no';
                    Expected = @{
                        ListItemText = '--no-quiet';
                        ToolTip      = "[NO] be quiet, only report errors";
                    },
                    @{
                        CompletionText = '--no-';
                        ListItemText   = '--no-...';
                        ResultType     = 'Text';
                    } | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
    Describe 'branch' {
        BeforeAll {
            Set-Variable Subcommand 'branch'
        }
        It 'ShortOptions' {
            $Expected = @{
                ListItemText = '-h';
                ToolTip      = "show help";
            } | ConvertTo-Completion -ResultType ParameterName
            "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected = @()
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'Branch' {
            It '<Line>' -ForEach @(
                @{
                    Line     = "";
                    Expected = @(
                        'HEAD',
                        'FETCH_HEAD',
                        'ORIG_HEAD',
                        'main',
                        'grm/develop',
                        'ordinary/develop',
                        'origin/develop',
                        'initial',
                        'zeta'
                    ) | ForEach-Object { switch ($_) {
                            'ORIG_HEAD' {
                                @{
                                    ListItemText = 'ORIG_HEAD';
                                    ToolTip      = '20ad91e Start';
                                }
                            }
                            Default { $RemoteCommits[$_] }
                        } } | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = "o";
                    Expected = @(
                        'ordinary/develop',
                        'origin/develop'
                    ) | ForEach-Object { switch ($_) {
                            'ORIG_HEAD' {
                                @{
                                    ListItemText = 'ORIG_HEAD';
                                    ToolTip      = '20ad91e Start';
                                }
                            }
                            Default { $RemoteCommits[$_] }
                        } } | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = "^";
                    Expected = @(
                        'HEAD',
                        'FETCH_HEAD',
                        'ORIG_HEAD',
                        'main',
                        'grm/develop',
                        'ordinary/develop',
                        'origin/develop',
                        'initial',
                        'zeta'
                    ) | ForEach-Object { "^$_" } | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = "^o";
                    Expected = @(
                        'ordinary/develop',
                        'origin/develop'
                    ) | ForEach-Object { "^$_" } | ConvertTo-Completion -ResultType ParameterValue
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
    Describe 'list' {
        BeforeAll {
            Set-Variable Subcommand 'list'
        }
        It 'ShortOptions' {
            $Expected = @{
                ListItemText = '-h';
                ToolTip      = "show help";
            } | ConvertTo-Completion -ResultType ParameterName
            "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--bi';
                    Expected = '--bisect', '--binary' | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no-p';
                    Expected = '--no-prefix', '--no-patch' | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
    Describe 'show' {
        BeforeAll {
            Set-Variable Subcommand 'show'
        }
        It 'ShortOptions' {
            $Expected = @{
                ListItemText = '-u';
                ToolTip      = "include untracked files in the stash";
            },
            @{
                ListItemText = '-h';
                ToolTip      = "show help";
            } | ConvertTo-Completion -ResultType ParameterName
            "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--bi';
                    Expected = '--binary' | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no-p';
                    Expected = '--no-prefix', '--no-patch' | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
    Describe 'store' {
        BeforeAll {
            Set-Variable Subcommand 'store'
        }
        It 'ShortOptions' {
            $Expected = @{
                ListItemText = '-m';
                ToolTip      = "stash message";
            },
            @{
                ListItemText = '-q';
                ToolTip      = "be quiet";
            },
            @{
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
                        ListItemText = '--quiet';
                        ToolTip      = "be quiet";
                    },
                    @{
                        ListItemText = '--message=';
                        ToolTip      = "stash message";
                    },
                    @{
                        ListItemText = '--no-quiet';
                        ToolTip      = "[NO] be quiet";
                    },
                    @{
                        CompletionText = '--no-';
                        ListItemText   = '--no-...';
                        ResultType     = 'Text';
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--q';
                    Expected = @{
                        ListItemText = '--quiet';
                        ToolTip      = "be quiet";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no-m';
                    Expected = @{
                        ListItemText = '--no-message';
                        ToolTip      = "[NO] stash message";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no-';
                    Expected = @{
                        ListItemText = '--no-quiet';
                        ToolTip      = "[NO] be quiet";
                    },
                    @{
                        ListItemText = '--no-message';
                        ToolTip      = "[NO] stash message";
                    } | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
    Describe 'create' {
        BeforeAll {
            Set-Variable Subcommand 'create'
        }
        It 'ShortOptions' {
            $Expected = @{
                ListItemText = '-h';
                ToolTip      = "show help";
            } | ConvertTo-Completion -ResultType ParameterName
            "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected = @()
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
}


Describe ((Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') + '-Push') -Tag Remote, File {
    BeforeAll {
        Initialize-Home

        mkdir ($rootPath = "$TestDrive/gitRoot")
        Initialize-FilesRepo $rootPath
        Push-Location $rootPath
        'ax' > "ax"
        git add ax
        git commit -m ax
        'ax2' > "ax"
        'print world' > 'Pwsh/world.ps1'
    }

    AfterAll {
        Restore-Home
        Pop-Location
    }

    Describe 'File' {
        Describe 'stash' {
            It '<Line>' -ForEach @(
                @{
                    Line     = ' ';
                    Expected = (
                        @{
                            ListItemText = 'apply';
                            ToolTip      = 'apply a single stashed state but do not remove the state';
                        },
                        @{
                            ListItemText = 'clear';
                            ToolTip      = 'remove all the stash entries';
                        },
                        @{
                            ListItemText = 'drop';
                            ToolTip      = 'remove a single stashed state';
                        },
                        @{
                            ListItemText = 'pop';
                            ToolTip      = 'remove a single stashed state and apply it';
                        },
                        @{
                            ListItemText = 'branch';
                            ToolTip      = 'creates and checks out a new branch';
                        },
                        @{
                            ListItemText = 'list';
                            ToolTip      = 'list the stash entries';
                        },
                        @{
                            ListItemText = 'show';
                            ToolTip      = 'show the changes recorded';
                        },
                        @{
                            ListItemText = 'store';
                            ToolTip      = 'store a given stash';
                        },
                        @{
                            ListItemText = 'create';
                            ToolTip      = 'create a stash entry';
                        },
                        @{
                            ListItemText = 'push';
                            ToolTip      = 'save your local modifications to a new stash entry and roll them back to HEAD (default)';
                        } | ConvertTo-Completion -ResultType ParameterName
                    ) + (
                        @(
                            @{
                                CompletionText = "Aquarion`` Evol/Evol";
                                ListItemText   = "Aquarion Evol/Evol";
                            },
                            'ax', 'Dr.Wily', 'Pwsh/'
                        ) | ConvertTo-Completion -ResultType ProviderItem
                    )
                },
                @{
                    Line     = 'a';
                    Expected = if ($IsLinux -or $IsMacOS) {
                        @{
                            ListItemText = "apply";
                            ResultType   = 'ParameterName';
                            ToolTip      = "apply a single stashed state but do not remove the state";
                        },
                        @{
                            CompletionText = "Aquarion`` Evol/Evol";
                            ListItemText   = "Aquarion Evol/Evol"
                        },
                        'ax' | ConvertTo-Completion -ResultType ProviderItem 
                    }
                    else {
                        @{
                            ListItemText = "apply";
                            ResultType   = 'ParameterName';
                            ToolTip      = "apply a single stashed state but do not remove the state";
                        },
                        'ax' | ConvertTo-Completion -ResultType ProviderItem 
                    }
                },
                @{
                    Line     = 'Pwsh';
                    Expected = 'Pwsh/' | ConvertTo-Completion -ResultType ProviderItem
                },
                @{
                    Line     = 'Pwsh/';
                    Expected = 'Pwsh/OptionLike/-foo.ps1', 'Pwsh/world.ps1' | ConvertTo-Completion -ResultType ProviderItem
                },
                @{
                    Line     = '-u ';
                    Expected = (
                        @(
                            @{
                                CompletionText = "Aquarion`` Evol/";
                                ListItemText   = "Aquarion Evol/"
                            },
                            'ax', 'Deava', 'Dr.Wily', 'Pwsh/', 'test.config', @{
                                CompletionText = '漢```''帝`　国`''';
                                ListItemText   = '漢`''帝　国''';
                            }
                        ) | ConvertTo-Completion -ResultType ProviderItem
                    )
                },
                @{
                    Line     = '-u Pwsh/';
                    Expected = 'Pwsh/L1/L2/🏪.ps1', 'Pwsh/OptionLike/-foo.ps1', 'Pwsh/world.ps1' | ConvertTo-Completion -ResultType ProviderItem
                }
            ) {
                "git stash $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'stash push' {
            It '<Line>' -ForEach @(
                @{
                    Line     = ' ';
                    Expected = (
                        @(
                            @{
                                CompletionText = "Aquarion`` Evol/Evol";
                                ListItemText   = "Aquarion Evol/Evol"
                            },
                            'ax', 'Dr.Wily', 'Pwsh/'
                        ) | ConvertTo-Completion -ResultType ProviderItem
                    )
                },
                @{
                    Line     = 'a';
                    Expected = if ($IsLinux -or $IsMacOS) {
                        @{
                            CompletionText = "Aquarion`` Evol/Evol";
                            ListItemText   = "Aquarion Evol/Evol"
                        },
                        'ax' | ConvertTo-Completion -ResultType ProviderItem 
                    }
                    else {
                        'ax' | ConvertTo-Completion -ResultType ProviderItem 
                    }
                },
                @{
                    Line     = 'Pwsh';
                    Expected = 'Pwsh/' | ConvertTo-Completion -ResultType ProviderItem
                },
                @{
                    Line     = 'Pwsh/';
                    Expected = 'Pwsh/OptionLike/-foo.ps1', 'Pwsh/world.ps1' | ConvertTo-Completion -ResultType ProviderItem
                },
                @{
                    Line     = '-u ';
                    Expected = (
                        @(
                            @{
                                CompletionText = "Aquarion`` Evol/";
                                ListItemText   = "Aquarion Evol/"
                            },
                            'ax', 'Deava', 'Dr.Wily', 'Pwsh/', 'test.config', @{
                                CompletionText = '漢```''帝`　国`''';
                                ListItemText   = '漢`''帝　国''';
                            }
                        ) | ConvertTo-Completion -ResultType ProviderItem
                    )
                },
                @{
                    Line     = '-u Pwsh/';
                    Expected = 'Pwsh/L1/L2/🏪.ps1', 'Pwsh/OptionLike/-foo.ps1', 'Pwsh/world.ps1' | ConvertTo-Completion -ResultType ProviderItem
                }
            ) {
                "git stash push $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
}