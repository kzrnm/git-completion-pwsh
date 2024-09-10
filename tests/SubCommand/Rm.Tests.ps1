using namespace System.Collections.Generic;
using namespace System.IO;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') -Tag File {
    BeforeAll {
        Set-Variable Command ((Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') | ConvertTo-KebabCase)
        Initialize-Home

        mkdir ($rootPath = "$TestDrive/gitRoot")
        Initialize-FilesRepo $rootPath
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
                    Left     = '--dry-run';
                    Right    = ' --';
                    Expected = '--dry-run' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'dry run'
                },
                @{
                    Left     = '--dry-run';
                    Right    = ' -- --dry-run';
                    Expected = '--dry-run' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'dry run'
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
            ListItemText = '-f';
            ToolTip      = "override the up-to-date check";
        },
        @{
            ListItemText = '-n';
            ToolTip      = "dry run";
        },
        @{
            ListItemText = '-q';
            ToolTip      = "do not list removed files";
        },
        @{
            ListItemText = '-r';
            ToolTip      = "allow recursive removal";
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
                Line     = '--p';
                Expected = @{
                    ListItemText = '--pathspec-from-file=';
                    ToolTip      = "read pathspec from file";
                },
                @{
                    ListItemText = '--pathspec-file-nul';
                    ToolTip      = "with --pathspec-from-file, pathspec elements are separated with NUL character";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-p';
                Expected = @{
                    ListItemText = '--no-pathspec-from-file';
                    ToolTip      = "[NO] read pathspec from file";
                },
                @{
                    ListItemText = '--no-pathspec-file-nul';
                    ToolTip      = "[NO] with --pathspec-from-file, pathspec elements are separated with NUL character";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-c';
                Expected = @{
                    ListItemText = '--no-cached';
                    ToolTip      = "[NO] only remove from the index";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no';
                Expected = @{
                    ListItemText = '--no-dry-run';
                    ToolTip      = "[NO] dry run";
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

    Describe 'File' {
        It '<Line>' -ForEach @(
            @{
                Line     = ' ';
                Expected =
                '.gitignore',
                @{
                    CompletionText = "Aquarion`` Evol/";
                    ListItemText   = "Aquarion Evol/"
                },
                'Dr.Wily', 'Pwsh/' | ConvertTo-Completion -ResultType ProviderItem
            },
            @{
                Line     = 'A ';
                Expected =
                '.gitignore',
                @{
                    CompletionText = "Aquarion`` Evol/";
                    ListItemText   = "Aquarion Evol/"
                },
                'Dr.Wily', 'Pwsh/' | ConvertTo-Completion -ResultType ProviderItem
            },
            @{
                Line     = 'Pws';
                Expected = 'Pwsh/' | ConvertTo-Completion -ResultType ProviderItem
            },
            @{
                Line     = 'Pwsh/';
                Expected = 'Pwsh/OptionLike/-foo.ps1', 'Pwsh/world.ps1' | ConvertTo-Completion -ResultType ProviderItem
            },
            @{
                Line     = 'Pwsh/OptionLike/';
                Expected = 'Pwsh/OptionLike/-foo.ps1' | ConvertTo-Completion -ResultType ProviderItem
            },
            @{
                Line     = 'D';
                Expected = 'Dr.Wily' | ConvertTo-Completion -ResultType ProviderItem
            },
            @{
                Line     = 'Dr D';
                Expected = 'Dr.Wily' | ConvertTo-Completion -ResultType ProviderItem
            },
            @{
                Line     = 'Dr.Wily D';
                Expected = @()
            },
            @{
                Line     = 'Dr.Wily Dr.Wily D';
                Expected = @()
            },
            @{
                Line     = 'Aquarion` Evol';
                Expected = @{
                    CompletionText = "Aquarion`` Evol/";
                    ListItemText   = "Aquarion Evol/"
                } | ConvertTo-Completion -ResultType ProviderItem
            },
            @{
                Line     = 'Aquarion` Evol/';
                Expected = 'Ancient/Soler', 'Evol' |
                ForEach-Object {
                    @{
                        CompletionText = "Aquarion`` Evol/$_";
                        ListItemText   = "Aquarion Evol/$_"
                    }
                } | ConvertTo-Completion -ResultType ProviderItem
            },
            @{
                Line     = 'Aquarion` Evol/Evol Aquarion` Evol/Gepada ';
                Expected =
                '.gitignore',
                @{
                    CompletionText = 'Aquarion` Evol/Ancient/Soler';
                    ListItemText   = 'Aquarion Evol/Ancient/Soler';
                }, 'Dr.Wily', 'Pwsh/' | ConvertTo-Completion -ResultType ProviderItem
            },
            @{
                Line     = 'Aquarion` Evol/Evol Aquarion` Evol/Gepada Aquarion` Evol/Gepard ';
                Expected =
                '.gitignore',
                @{
                    CompletionText = 'Aquarion` Evol/Ancient/Soler';
                    ListItemText   = 'Aquarion Evol/Ancient/Soler';
                }, 'Dr.Wily', 'Pwsh/' | ConvertTo-Completion -ResultType ProviderItem
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'InRight' {
            It '<Left>(cursor)<Right>' -ForEach @(
                @{
                    Left     = ' ';
                    Right    = ' 漢```''帝`　国`'' ';
                    Expected =
                    '.gitignore',
                    @{
                        CompletionText = "Aquarion`` Evol/";
                        ListItemText   = "Aquarion Evol/"
                    },
                    'Dr.Wily',
                    'Pwsh/' | ConvertTo-Completion -ResultType ProviderItem
                },
                @{
                    Left     = 'D';
                    Right    = ' 漢```''帝`　国`'' ';
                    Expected = 'Dr.Wily' | ConvertTo-Completion -ResultType ProviderItem
                }
            ) {
                "git $Command $Left" | Complete-FromLine -Right $Right | Should -BeCompletion $Expected
            }
        }

        Describe 'OptionLikeLeadingDash' {
            BeforeAll {
                Push-Location 'Pwsh/OptionLike'
            }
            AfterAll {
                Pop-Location
            }

            It 'Empty' {
                $Line = ' '
                $Expected = '-foo.ps1' | ConvertTo-Completion -CompletionText './-foo.ps1' -ResultType ProviderItem
                "git $Command $Line" | Complete-FromLine | Should -BeCompletion $Expected
            }

            Describe 'DoubleDash' {
                It 'AfterEmpty' {
                    $Line = '-- '
                    $Expected = '-foo.ps1' | ConvertTo-Completion -ResultType ProviderItem
                    "git $Command $Line" | Complete-FromLine | Should -BeCompletion $Expected
                }

                It 'AfterDash' {
                    $Line = '-- -'
                    $Expected = '-foo.ps1' | ConvertTo-Completion -ResultType ProviderItem
                    "git $Command $Line" | Complete-FromLine | Should -BeCompletion $Expected
                }
    
                It 'Before' {
                    $Line = ' '
                    $Expected = @{
                        CompletionText = './-foo.ps1';
                        ListItemText   = '-foo.ps1';
                    } | ConvertTo-Completion -ResultType ProviderItem
                    "git $Command $Line" | Complete-FromLine -Right ' --' | Should -BeCompletion $Expected
                }
            }

            Describe 'Relative' {
                It 'Current' {
                    $Line = './'
                    $Expected = './-foo.ps1' | ConvertTo-Completion -ResultType ProviderItem
                    "git $Command $Line" | Complete-FromLine | Should -BeCompletion $Expected
                }
                It 'Current2' {
                    $Line = './-'
                    $Expected = './-foo.ps1' | ConvertTo-Completion -ResultType ProviderItem
                    "git $Command $Line" | Complete-FromLine | Should -BeCompletion $Expected
                }
                It 'Parent' {
                    $Line = '../'
                    $Expected = '../OptionLike/-foo.ps1', '../world.ps1'  | ConvertTo-Completion -ResultType ProviderItem
                    "git $Command $Line" | Complete-FromLine | Should -BeCompletion $Expected
                }
                It 'Parent2' {
                    $Line = '../L'
                    $Expected = @()
                    "git $Command $Line" | Complete-FromLine | Should -BeCompletion $Expected
                }
                It 'ParentCurrent' {
                    $Line = '..//./'
                    $Expected = '..//./OptionLike/-foo.ps1', '..//./world.ps1' | ConvertTo-Completion -ResultType ProviderItem
                    "git $Command $Line" | Complete-FromLine | Should -BeCompletion $Expected
                }
                It 'ParentParent' {
                    $Line = '../../'
                    $Expected =
                    '../../.gitignore',
                    @{
                        CompletionText = "../../Aquarion`` Evol/";
                        ListItemText   = "../../Aquarion Evol/"
                    },
                    '../../Dr.Wily', '../../Pwsh/' | ConvertTo-Completion -ResultType ProviderItem
                    "git $Command $Line" | Complete-FromLine | Should -BeCompletion $Expected
                }
            }
        }
    }
}