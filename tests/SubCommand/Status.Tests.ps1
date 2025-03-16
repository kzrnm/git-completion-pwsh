using namespace System.Collections.Generic;
using namespace System.IO;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') -Tag Remote, File {
    BeforeAll {
        Set-Variable Command ((Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') | ConvertTo-KebabCase)
        Initialize-Home

        mkdir ($rootPath = "$TestDrive/gitRoot")
        mkdir ($remotePath = "$TestDrive/gitRemote")
        Initialize-FilesRepo $rootPath $remotePath
        Push-Location $rootPath
        'ign*' > 'ignored'
        'ign*' | Out-File '.gitignore' -Encoding ascii -Append
    }

    AfterAll {
        Restore-Home
        Pop-Location
    }

    Describe 'DoubleDash' {
        Describe 'InRight' {
            It '<Left>(cursor)<Right>' -ForEach @(
                @{
                    Left     = '--verbose';
                    Right    = ' --';
                    Expected = '--verbose' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'be verbose'
                },
                @{
                    Left     = '--verbose';
                    Right    = ' -- --all';
                    Expected = '--verbose' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'be verbose'
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
            ToolTip      = "show branch information";
        },
        @{
            ListItemText = '-M';
            ToolTip      = "detect renames, optionally set similarity index";
        },
        @{
            ListItemText = '-s';
            ToolTip      = "show status concisely";
        },
        @{
            ListItemText = '-u';
            ToolTip      = "show untracked files, optional modes: all, normal, no. (Default: all)";
        },
        @{
            ListItemText = '-v';
            ToolTip      = "be verbose";
        },
        @{
            ListItemText = '-z';
            ToolTip      = "terminate entries with NUL";
        },
        @{
            ListItemText = '-h';
            ToolTip      = "show help";
        } | ConvertTo-Completion -ResultType ParameterName
        "git $Command -" | Complete-FromLine | Should -BeCompletion $expected
    }

    Describe 'ShortOptions:-u' {
        It '<Line>' -ForEach @(
            @{
                Line     = '-u';
                Expected =
                'all',
                'no',
                'normal' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "-u$_" }
            },
            @{
                Line     = '-un';
                Expected =
                'no',
                'normal' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "-u$_" }
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'Options' {
        It '<Line>' -ForEach @(
            @{
                Line     = '--l';
                Expected = @{
                    ListItemText = '--long';
                    ToolTip      = "show status in long format (default)";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--r';
                Expected = @{
                    ListItemText = '--renames';
                    ToolTip      = "opposite of --no-renames";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-l';
                Expected = @{
                    ListItemText = '--no-long';
                    ToolTip      = "[NO] show status in long format (default)";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-r';
                Expected = @{
                    ListItemText = '--no-renames';
                    ToolTip      = "do not detect renames";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--n';
                Expected = @{
                    ListItemText = '--null';
                    ToolTip      = "terminate entries with NUL";
                },
                @{
                    ListItemText = '--no-renames';
                    ToolTip      = "do not detect renames";
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
        It '<Line>' -ForEach @(
            @{
                Line     = '--ignore-submodules=';
                Expected =
                'none', 'untracked', 'dirty', 'all' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--ignore-submodules=$_" }
            },
            @{
                Line     = '--ignore-submodules=a';
                Expected =
                'all' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--ignore-submodules=$_" }
            },
            @{
                Line     = '--untracked-files=';
                Expected =
                'all', 'no', 'normal' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--untracked-files=$_" }
            },
            @{
                Line     = '--untracked-files=n';
                Expected =
                'no', 'normal' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--untracked-files=$_" }
            },
            @{
                Line     = '--column=';
                Expected =
                'always', 'never', 'auto', 'column', 'row', 'plain', 'dense', 'nodense' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--column=$_" }
            },
            @{
                Line     = '--column=a';
                Expected =
                'always', 'auto' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--column=$_" }
            },
            @{
                Line     = '--ignored=';
                Expected =
                'traditional', 'matching', 'no' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--ignored=$_" }
            },
            @{
                Line     = '--ignored=n';
                Expected =
                'no' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--ignored=$_" }
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'File' {
        Describe 'Ordinary' {
            Describe 'Config:<_>' -ForEach @('all', 'normal') {
                BeforeAll {
                    git config set status.showUntrackedFiles $_
                }
                AfterAll {
                    git config unset status.showUntrackedFiles
                }
                It '<Line>' -ForEach @(
                    @{
                        Line     = '';
                        Expected =
                        '.gitignore',
                        @{
                            CompletionText = "Aquarion`` Evol/";
                            ListItemText   = "Aquarion Evol/"
                        },
                        'BigInteger/', 'Deava', 'Dr.Wily', 'hello.sh', 'initial.txt', 'Pwsh/',
                        @{
                            CompletionText = '漢```''帝`　国`''';
                            ListItemText   = '漢`''帝　国''';
                        } | ConvertTo-Completion -ResultType ProviderItem
                    },
                    @{
                        Line     = 'Pwsh';
                        Expected = 'Pwsh/' | ConvertTo-Completion -ResultType ProviderItem
                    },
                    @{
                        Line     = 'Pwsh/';
                        Expected =
                        'Pwsh/L1/',
                        'Pwsh/OptionLike/-foo.ps1',
                        'Pwsh/world.ps1' | ConvertTo-Completion -ResultType ProviderItem
                    }
                ) {
                    "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }

            Describe '<Option>' -ForEach @(
                '',
                '-uall',
                '--untracked-files=all',
                '-unormal',
                '--untracked-files=normal' | ForEach-Object { @{Option = $_ } }) {
                It '<Line>' -ForEach @(
                    @{
                        Line     = '';
                        Expected =
                        '.gitignore',
                        @{
                            CompletionText = "Aquarion`` Evol/";
                            ListItemText   = "Aquarion Evol/"
                        },
                        'BigInteger/', 'Deava', 'Dr.Wily', 'hello.sh', 'initial.txt', 'Pwsh/',
                        @{
                            CompletionText = '漢```''帝`　国`''';
                            ListItemText   = '漢`''帝　国''';
                        } | ConvertTo-Completion -ResultType ProviderItem
                    },
                    @{
                        Line     = 'Pwsh';
                        Expected = 'Pwsh/' | ConvertTo-Completion -ResultType ProviderItem
                    },
                    @{
                        Line     = 'Pwsh/';
                        Expected =
                        'Pwsh/L1/',
                        'Pwsh/OptionLike/-foo.ps1',
                        'Pwsh/world.ps1' | ConvertTo-Completion -ResultType ProviderItem
                    }
                ) {
                    "git $Command $Option $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
        }

        Describe 'Ignored' {
            Describe 'Config:<_>' -ForEach @('all', 'normal') {
                BeforeAll {
                    git config set status.showUntrackedFiles $_
                }
                AfterAll {
                    git config unset status.showUntrackedFiles
                }
                It '<Line>' -ForEach @(
                    @{
                        Line     = '';
                        Expected =
                        '.gitignore',
                        @{
                            CompletionText = "Aquarion`` Evol/";
                            ListItemText   = "Aquarion Evol/"
                        },
                        'BigInteger/', 'Deava', 'Dr.Wily', 'hello.sh', 'ignored', 'initial.txt', 'Pwsh/',
                        @{
                            CompletionText = '漢```''帝`　国`''';
                            ListItemText   = '漢`''帝　国''';
                        } | ConvertTo-Completion -ResultType ProviderItem
                    },
                    @{
                        Line     = 'Pwsh';
                        Expected = 'Pwsh/' | ConvertTo-Completion -ResultType ProviderItem
                    },
                    @{
                        Line     = 'Pwsh/';
                        Expected =
                        'Pwsh/ignored',
                        'Pwsh/L1/',
                        'Pwsh/OptionLike/-foo.ps1',
                        'Pwsh/world.ps1' | ConvertTo-Completion -ResultType ProviderItem
                    }
                ) {
                    "git $Command --ignored $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }

            Describe '<Option>' -ForEach @(
                '--ignored',
                '--ignored -uall',
                '--ignored --untracked-files=all',
                '--ignored -unormal',
                '--ignored --untracked-files=normal',
                '-uall --ignored',
                '--untracked-files=all --ignored',
                '-unormal --ignored',
                '--untracked-files=normal --ignored' | ForEach-Object { @{Option = $_ } }) {
                It '<Line>' -ForEach @(
                    @{
                        Line     = '';
                        Expected =
                        '.gitignore',
                        @{
                            CompletionText = "Aquarion`` Evol/";
                            ListItemText   = "Aquarion Evol/"
                        },
                        'BigInteger/', 'Deava', 'Dr.Wily', 'hello.sh', 'ignored', 'initial.txt', 'Pwsh/',
                        @{
                            CompletionText = '漢```''帝`　国`''';
                            ListItemText   = '漢`''帝　国''';
                        } | ConvertTo-Completion -ResultType ProviderItem
                    },
                    @{
                        Line     = 'Pwsh';
                        Expected = 'Pwsh/' | ConvertTo-Completion -ResultType ProviderItem
                    },
                    @{
                        Line     = 'Pwsh/';
                        Expected =
                        'Pwsh/ignored',
                        'Pwsh/L1/',
                        'Pwsh/OptionLike/-foo.ps1',
                        'Pwsh/world.ps1' | ConvertTo-Completion -ResultType ProviderItem
                    }
                ) {
                    "git $Command $Option $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
        }
        Describe 'NoUntracked' {
            Describe 'Config' {
                BeforeAll {
                    git config set status.showUntrackedFiles 'no'
                }
                AfterAll {
                    git config unset status.showUntrackedFiles
                }
                It '<Line>' -ForEach @(
                    @{
                        Line     = '';
                        Expected =
                        '.gitignore',
                        @{
                            CompletionText = "Aquarion`` Evol/";
                            ListItemText   = "Aquarion Evol/"
                        },
                        'Dr.Wily', 'hello.sh', 'initial.txt', 'Pwsh/' | ConvertTo-Completion -ResultType ProviderItem
                    },
                    @{
                        Line     = 'Pwsh';
                        Expected = 'Pwsh/' | ConvertTo-Completion -ResultType ProviderItem
                    },
                    @{
                        Line     = 'Pwsh/';
                        Expected =
                        'Pwsh/OptionLike/-foo.ps1',
                        'Pwsh/world.ps1' | ConvertTo-Completion -ResultType ProviderItem
                    }
                ) {
                    "git $Command $Option $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }

            Describe '<Option>' -ForEach @(
                '-uno',
                '--untracked-files=no' | ForEach-Object { @{Option = $_ } }) {
                It '<Line>' -ForEach @(
                    @{
                        Line     = '';
                        Expected =
                        '.gitignore',
                        @{
                            CompletionText = "Aquarion`` Evol/";
                            ListItemText   = "Aquarion Evol/"
                        },
                        'Dr.Wily', 'hello.sh', 'initial.txt', 'Pwsh/' | ConvertTo-Completion -ResultType ProviderItem
                    },
                    @{
                        Line     = 'Pwsh';
                        Expected = 'Pwsh/' | ConvertTo-Completion -ResultType ProviderItem
                    },
                    @{
                        Line     = 'Pwsh/';
                        Expected =
                        'Pwsh/OptionLike/-foo.ps1',
                        'Pwsh/world.ps1' | ConvertTo-Completion -ResultType ProviderItem
                    }
                ) {
                    "git $Command $Option $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
        }
    }
}