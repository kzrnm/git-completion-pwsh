# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Collections.Generic;
using namespace System.IO;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') {
    BeforeAll {
        Set-Variable Command ((Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') | ConvertTo-KebabCase)
        Initialize-Home

        mkdir ($rootPath = "$TestDrive/gitRoot")
        Initialize-FilesRepo $rootPath
        Push-Location $rootPath

        $ErrorActionPreference = 'SilentlyContinue'
        git sparse-checkout add Pwsh 'Aquarion Evol' 2>$null
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
        "git $Command -" | Complete-FromLine | Should -BeCompletion $expected
    }

    Describe 'Subcommands' {
        It '<Line>' -ForEach @(
            @{
                Line     = '';
                Expected = @{
                    ListItemText = 'list';
                    ToolTip      = "describe the directories or patterns";
                },
                @{
                    ListItemText = 'init';
                    ToolTip      = "like set with no specified paths (deprecated)";
                },
                @{
                    ListItemText = 'set';
                    ToolTip      = "enable the necessary sparse-checkout config settings";
                },
                @{
                    ListItemText = 'add';
                    ToolTip      = "update the sparse-checkout file to include additional directories";
                },
                @{
                    ListItemText = 'reapply';
                    ToolTip      = "reapply the sparsity pattern rules to paths in the working tree";
                },
                @{
                    ListItemText = 'clean';
                    ToolTip      = "opportunistically remove files outside of the sparse-checkout definition";
                },
                @{
                    ListItemText = 'disable';
                    ToolTip      = "disable the core.sparseCheckout config setting";
                },
                @{
                    ListItemText = 'check-rules';
                    ToolTip      = "check whether sparsity rules match one or more paths";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = 'l';
                Expected = @{
                    ListItemText = 'list';
                    ToolTip      = "describe the directories or patterns";
                } | ConvertTo-Completion -ResultType ParameterName
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'init' {
        BeforeAll {
            Set-Variable Subcommand 'init'
        }
        Describe 'DoubleDash' {
            Describe 'InRight' {
                It '<Left>(cursor)<Right>' -ForEach @(
                    @{
                        Left     = '--cone';
                        Right    = ' --';
                        Expected = '--cone' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'initialize the sparse-checkout in cone mode'
                    },
                    @{
                        Left     = '--cone';
                        Right    = ' -- --all';
                        Expected = '--cone' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'initialize the sparse-checkout in cone mode'
                    }
                ) {
                    "git $Command $Subcommand $Left" | Complete-FromLine -Right $Right | Should -BeCompletion $Expected
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
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected = @{
                        ListItemText = '--cone';
                        ToolTip      = "initialize the sparse-checkout in cone mode";
                    },
                    @{
                        ListItemText = '--sparse-index';
                        ToolTip      = "toggle the use of a sparse index";
                    },
                    @{
                        ListItemText = '--no-cone';
                        ToolTip      = "[NO] initialize the sparse-checkout in cone mode";
                    },
                    @{
                        CompletionText = '--no-';
                        ListItemText   = '--no-...';
                        ResultType     = 'Text';
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--c';
                    Expected = @{
                        ListItemText = '--cone';
                        ToolTip      = "initialize the sparse-checkout in cone mode";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no-';
                    Expected = @{
                        ListItemText = '--no-cone';
                        ToolTip      = "[NO] initialize the sparse-checkout in cone mode";
                    },
                    @{
                        ListItemText = '--no-sparse-index';
                        ToolTip      = "[NO] toggle the use of a sparse index";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no';
                    Expected = @{
                        ListItemText = '--no-cone';
                        ToolTip      = "[NO] initialize the sparse-checkout in cone mode";
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

    Describe 'set' {
        BeforeAll {
            Set-Variable Subcommand 'set'
        }
        Describe 'DoubleDash' {
            Describe 'InRight' {
                It '<Left>(cursor)<Right>' -ForEach @(
                    @{
                        Left     = '--cone';
                        Right    = ' --';
                        Expected = '--cone' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'initialize the sparse-checkout in cone mode'
                    },
                    @{
                        Left     = '--cone';
                        Right    = ' -- --all';
                        Expected = '--cone' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'initialize the sparse-checkout in cone mode'
                    }
                ) {
                    "git $Command $Subcommand $Left" | Complete-FromLine -Right $Right | Should -BeCompletion $Expected
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
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected = @{
                        ListItemText = '--cone';
                        ToolTip      = "initialize the sparse-checkout in cone mode";
                    },
                    @{
                        ListItemText = '--sparse-index';
                        ToolTip      = "toggle the use of a sparse index";
                    },
                    @{
                        ListItemText = '--skip-checks';
                        ToolTip      = "skip some sanity checks on the given paths that might give false positives";
                    },
                    @{
                        ListItemText = '--stdin';
                        ToolTip      = "read patterns from standard in";
                    },
                    @{
                        ListItemText = '--no-cone';
                        ToolTip      = "[NO] initialize the sparse-checkout in cone mode";
                    },
                    @{
                        CompletionText = '--no-';
                        ListItemText   = '--no-...';
                        ResultType     = 'Text';
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--c';
                    Expected = @{
                        ListItemText = '--cone';
                        ToolTip      = "initialize the sparse-checkout in cone mode";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no-';
                    Expected = @{
                        ListItemText = '--no-cone';
                        ToolTip      = "[NO] initialize the sparse-checkout in cone mode";
                    },
                    @{
                        ListItemText = '--no-sparse-index';
                        ToolTip      = "[NO] toggle the use of a sparse index";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no';
                    Expected = @{
                        ListItemText = '--no-cone';
                        ToolTip      = "[NO] initialize the sparse-checkout in cone mode";
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

    Describe 'check-rules' {
        BeforeAll {
            Set-Variable Subcommand 'check-rules'
        }
        Describe 'DoubleDash' {
            Describe 'InRight' {
                It '<Left>(cursor)<Right>' -ForEach @(
                    @{
                        Left     = '--cone';
                        Right    = ' --';
                        Expected = '--cone' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'when used with --rules-file interpret patterns as cone mode patterns'
                    },
                    @{
                        Left     = '--cone';
                        Right    = ' -- --all';
                        Expected = '--cone' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'when used with --rules-file interpret patterns as cone mode patterns'
                    }
                ) {
                    "git $Command $Subcommand $Left" | Complete-FromLine -Right $Right | Should -BeCompletion $Expected
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
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected = @{
                        ListItemText = '--cone';
                        ToolTip      = "when used with --rules-file interpret patterns as cone mode patterns";
                    },
                    @{
                        ListItemText = '--rules-file=';
                        ToolTip      = "use patterns in <file> instead of the current ones.";
                    },
                    @{
                        ListItemText = '--no-cone';
                        ToolTip      = "[NO] when used with --rules-file interpret patterns as cone mode patterns";
                    },
                    @{
                        CompletionText = '--no-';
                        ListItemText   = '--no-...';
                        ResultType     = 'Text';
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--c';
                    Expected = @{
                        ListItemText = '--cone';
                        ToolTip      = "when used with --rules-file interpret patterns as cone mode patterns";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no-';
                    Expected = @{
                        ListItemText = '--no-cone';
                        ToolTip      = "[NO] when used with --rules-file interpret patterns as cone mode patterns";
                    },
                    @{
                        ListItemText = '--no-rules-file';
                        ToolTip      = "[NO] use patterns in <file> instead of the current ones.";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no';
                    Expected = @{
                        ListItemText = '--no-cone';
                        ToolTip      = "[NO] when used with --rules-file interpret patterns as cone mode patterns";
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

    Describe 'Path:<Subcommand>' -ForEach @('add', 'set' | ForEach-Object { @{Subcommand = $_ } }) {
        BeforeEach {
            if ($Config) {
                $Config | Get-Member -MemberType NoteProperty | ForEach-Object {
                    git config set ($_.Name) $Config.($_.Name)
                }
            }
            if ($Path) {
                Push-Location $Path
            }
        }
        AfterEach {
            if ($Path) {
                Pop-Location
            }
            if ($Config) {
                $Config | Get-Member -MemberType NoteProperty | ForEach-Object {
                    git config unset ($_.Name)
                }
            }
        }

        Describe 'Cone' {
            Describe '<Line> at <Path>' -ForEach @(
                @{
                    Line     = '';
                    Path     = '';
                    Expected = @{
                        CompletionText = 'Aquarion` Evol/';
                        ListItemText   = 'Aquarion Evol/';
                    },
                    'Pwsh/' | ConvertTo-Completion -ResultType ProviderItem
                },
                @{
                    Line     = 'P';
                    Path     = '';
                    Expected = 'Pwsh/' | ConvertTo-Completion -ResultType ProviderItem
                },
                @{
                    Line     = '';
                    Path     = 'Pwsh';
                    Expected =
                    'OptionLike/' | ConvertTo-Completion -ResultType ProviderItem
                },
                @{
                    Line     = 'O';
                    Path     = 'Pwsh';
                    Expected =
                    'OptionLike/' | ConvertTo-Completion -ResultType ProviderItem
                }
            ) {
                It '<Config>:<Option>' -ForEach @(
                    @{
                        Option = '';
                    },
                    @{
                        Config = [PSCustomObject]@{
                            'core.sparseCheckout'     = 'true';
                            'core.sparseCheckoutCone' = 'false';
                        }
                        Option = '--cone ';
                    },
                    @{
                        Config = [PSCustomObject]@{
                            'core.sparseCheckout'     = 'true';
                            'core.sparseCheckoutCone' = 'true';
                        }
                        Option = '';
                    },
                    @{
                        Config = [PSCustomObject]@{
                            'core.sparseCheckout'     = 'false';
                            'core.sparseCheckoutCone' = 'false';
                        }
                        Option = '';
                    }
                ) {
                    "git $Command $Subcommand $Option $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
        }

        Describe 'NoCone' {
            Describe '<Line> at <Path>' -ForEach @(
                @{
                    Line     = '';
                    Path     = '';
                    Expected = if (!$IsCoreCLR -or $IsWindows) {
                        '/.gitignore',
                        @{
                            CompletionText = '/Aquarion` Evol/Ancient/Soler';
                            ListItemText   = '/Aquarion Evol/Ancient/Soler';
                        },
                        @{
                            CompletionText = '/Aquarion` Evol/Evol';
                            ListItemText   = '/Aquarion Evol/Evol';
                        },
                        '/Dr.Wily', '/Pwsh/OptionLike/-foo.ps1', '/Pwsh/world.ps1' | ConvertTo-Completion -ResultType ProviderItem
                    }
                    else {
                        @{
                            CompletionText = '/Aquarion` Evol/Ancient/Soler';
                            ListItemText   = '/Aquarion Evol/Ancient/Soler';
                        },
                        @{
                            CompletionText = '/Aquarion` Evol/Evol';
                            ListItemText   = '/Aquarion Evol/Evol';
                        },
                        '/Dr.Wily', '/Pwsh/OptionLike/-foo.ps1', '/Pwsh/world.ps1' | ConvertTo-Completion -ResultType ProviderItem
                    }
                },
                @{
                    Line     = '';
                    Path     = 'Pwsh';
                    Expected =
                    '/Pwsh/OptionLike/-foo.ps1',
                    '/Pwsh/world.ps1' | ConvertTo-Completion -ResultType ProviderItem
                },
                @{
                    Line     = '/Pwsh/world';
                    Path     = '';
                    Expected = '/Pwsh/world.ps1' | ConvertTo-Completion -ResultType ProviderItem
                },
                @{
                    Line     = '/Pwsh/world';
                    Path     = 'Pwsh';
                    Expected = '/Pwsh/world.ps1' | ConvertTo-Completion -ResultType ProviderItem
                }
            ) {
                It '<Config>:<Option>' -ForEach @(
                    @{
                        Option = '--no-cone ';
                    },
                    @{
                        Config = [PSCustomObject]@{
                            'core.sparseCheckout'     = 'true';
                            'core.sparseCheckoutCone' = 'false';
                        }
                        Option = '';
                    }
                ) {
                    "git $Command $Subcommand $Option $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
        }
    }
}