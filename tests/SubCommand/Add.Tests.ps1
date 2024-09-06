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
                    Left     = '--verbose';
                    Right    = ' --';
                    Expected = '--verbose' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'be verbose'
                },
                @{
                    Left     = '--verbose';
                    Right    = ' -- --verbose';
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
            ListItemText = '-A';
            ToolTip      = "add changes from all tracked and untracked files";
        },
        @{
            ListItemText = '-e';
            ToolTip      = "edit current diff and apply";
        },
        @{
            ListItemText = '-f';
            ToolTip      = "allow adding otherwise ignored files";
        },
        @{
            ListItemText = '-i';
            ToolTip      = "interactive picking";
        },
        @{
            ListItemText = '-n';
            ToolTip      = "dry run";
        },
        @{
            ListItemText = '-N';
            ToolTip      = "record only the fact that the path will be added later";
        },
        @{
            ListItemText = '-p';
            ToolTip      = "select hunks interactively";
        },
        @{
            ListItemText = '-u';
            ToolTip      = "update tracked files";
        },
        @{
            ListItemText = '-v';
            ToolTip      = "be verbose";
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
                Line     = '--v';
                Expected = @{
                    ListItemText = '--verbose';
                    ToolTip      = "be verbose";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-al';
                Expected = @{
                    ListItemText = '--no-all';
                    ToolTip      = "[NO] add changes from all tracked and untracked files";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no';
                Expected = @{
                    ListItemText = '--no-dry-run';
                    ToolTip      = "[NO] dry run"
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
        It '<Line>' -ForEach @(
            @{
                Line     = '--chmod=';
                Expected = '+x', '-x' | ForEach-Object {
                    "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "--chmod=$_"
                }
            },
            @{
                Line     = '--chmod ';
                Expected = '+x', '-x' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--chmod=+';
                Expected = '+x' | ForEach-Object {
                    "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "--chmod=$_"
                }
            },
            @{
                Line     = '--chmod +';
                Expected = '+x' | ConvertTo-Completion -ResultType ParameterValue
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'File' {
        It '<Line>' -ForEach @(
            @{
                Line     = ' ';
                Expected = (
                    ('Evol', 'Gepada', 'Gepard' |
                    ForEach-Object {
                        @{
                            CompletionText = "Aquarion`` Evol/$_";
                            ListItemText   = "Aquarion Evol/$_"
                        }
                    }) + @(
                        'Deava', 'Dr.Wily', 'Pwsh/L1/L2/🏪.ps1', 'Pwsh/OptionLike/-foo.ps1', 'test.config', @{
                            CompletionText = '漢```''帝`　国`''';
                            ListItemText   = '漢`''帝　国''';
                        }
                    ) | ConvertTo-Completion -ResultType ProviderItem
                )
            },
            @{
                Line     = 'A ';
                Expected = (
                    ('Evol', 'Gepada', 'Gepard' |
                    ForEach-Object {
                        @{
                            CompletionText = "Aquarion`` Evol/$_";
                            ListItemText   = "Aquarion Evol/$_"
                        }
                    }) + @(
                        'Deava', 'Dr.Wily', 'Pwsh/L1/L2/🏪.ps1', 'Pwsh/OptionLike/-foo.ps1', 'test.config', @{
                            CompletionText = '漢```''帝`　国`''';
                            ListItemText   = '漢`''帝　国''';
                        }
                    ) | ConvertTo-Completion -ResultType ProviderItem
                )
            },
            @{
                Line     = 'Pws';
                Expected = 'Pwsh/L1/L2/🏪.ps1', 'Pwsh/OptionLike/-foo.ps1' | ConvertTo-Completion -ResultType ProviderItem
            },
            @{
                Line     = 'Pwsh/';
                Expected = 'Pwsh/L1/L2/🏪.ps1', 'Pwsh/OptionLike/-foo.ps1' | ConvertTo-Completion -ResultType ProviderItem
            },
            @{
                Line     = 'Pwsh/L1/';
                Expected = 'Pwsh/L1/L2/🏪.ps1' | ConvertTo-Completion -ResultType ProviderItem
            },
            @{
                Line     = 'Pwsh/L1/L2/';
                Expected = 'Pwsh/L1/L2/🏪.ps1' | ConvertTo-Completion -ResultType ProviderItem
            },
            @{
                Line     = 'Pwsh/OptionLike/';
                Expected = 'Pwsh/OptionLike/-foo.ps1' | ConvertTo-Completion -ResultType ProviderItem
            },
            @{
                Line     = 'D';
                Expected = 'Deava', 'Dr.Wily' | ConvertTo-Completion -ResultType ProviderItem
            },
            @{
                Line     = 'Dr D';
                Expected = 'Deava', 'Dr.Wily' | ConvertTo-Completion -ResultType ProviderItem
            },
            @{
                Line     = 'Dr.Wily D';
                Expected = 'Deava' | ConvertTo-Completion -ResultType ProviderItem
            },
            @{
                Line     = 'Dr.Wily Dr.Wily D';
                Expected = 'Deava' | ConvertTo-Completion -ResultType ProviderItem
            },
            @{
                Line     = '--chmod Dr.Wily --pathspec-from-file Dr.Wily D';
                Expected = 'Deava' | ConvertTo-Completion -ResultType ProviderItem
            },
            @{
                Line     = '--update D';
                Expected = 'Dr.Wily' | ConvertTo-Completion -ResultType ProviderItem
            },
            @{
                Line     = '-u D';
                Expected = 'Dr.Wily' | ConvertTo-Completion -ResultType ProviderItem
            },
            @{
                Line     = '漢```''帝`　国`'' ';
                Expected = (
                    ('Evol', 'Gepada', 'Gepard' |
                    ForEach-Object {
                        @{
                            CompletionText = "Aquarion`` Evol/$_";
                            ListItemText   = "Aquarion Evol/$_"
                        }
                    }) + @('Deava', 'Dr.Wily', 'Pwsh/L1/L2/🏪.ps1', 'Pwsh/OptionLike/-foo.ps1', 'test.config')
                ) | ConvertTo-Completion -ResultType ProviderItem
            },
            @{
                Line     = 'Aquarion` Evol';
                Expected = 'Evol', 'Gepada', 'Gepard' |
                ForEach-Object {
                    @{
                        CompletionText = "Aquarion`` Evol/$_";
                        ListItemText   = "Aquarion Evol/$_"
                    }
                } | ConvertTo-Completion -ResultType ProviderItem
            },
            @{
                Line     = 'Aquarion` Evol/';
                Expected = 'Evol', 'Gepada', 'Gepard' |
                ForEach-Object {
                    @{
                        CompletionText = "Aquarion`` Evol/$_";
                        ListItemText   = "Aquarion Evol/$_"
                    }
                } | ConvertTo-Completion -ResultType ProviderItem
            },
            @{
                Line     = 'Aquarion` Evol/Evol Aquarion` Evol/Gepada ';
                Expected = @{
                    CompletionText = 'Aquarion` Evol/Gepard';
                    ListItemText   = 'Aquarion Evol/Gepard';
                }, 'Deava', 'Dr.Wily', 'Pwsh/L1/L2/🏪.ps1', 'Pwsh/OptionLike/-foo.ps1', 'test.config', @{
                    CompletionText = '漢```''帝`　国`''';
                    ListItemText   = '漢`''帝　国''';
                } | ConvertTo-Completion -ResultType ProviderItem
            },
            @{
                Line     = 'Aquarion` Evol/Evol Aquarion` Evol/Gepada Aquarion` Evol/Gepard ';
                Expected = 'Deava', 'Dr.Wily', 'Pwsh/L1/L2/🏪.ps1', 'Pwsh/OptionLike/-foo.ps1', 'test.config', @{
                    CompletionText = '漢```''帝`　国`''';
                    ListItemText   = '漢`''帝　国''';
                } | ConvertTo-Completion -ResultType ProviderItem
            },
            @{
                Line     = '--update ';
                Expected = @{
                    CompletionText = "Aquarion`` Evol/Evol";
                    ListItemText   = "Aquarion Evol/Evol"
                },
                'Dr.Wily' | ConvertTo-Completion -ResultType ProviderItem
            }
            @{
                Line     = '-u ';
                Expected = @{
                    CompletionText = "Aquarion`` Evol/Evol";
                    ListItemText   = "Aquarion Evol/Evol"
                },
                'Dr.Wily' | ConvertTo-Completion -ResultType ProviderItem
            }
            @{
                Line     = '--update Aquarion` Evol/';
                Expected = 'Evol' |
                ForEach-Object {
                    @{
                        CompletionText = "Aquarion`` Evol/$_";
                        ListItemText   = "Aquarion Evol/$_"
                    }
                } | ConvertTo-Completion -ResultType ProviderItem
            }
            @{
                Line     = '-u Aquarion` Evol/';
                Expected = 'Evol' |
                ForEach-Object {
                    @{
                        CompletionText = "Aquarion`` Evol/$_";
                        ListItemText   = "Aquarion Evol/$_"
                    }
                } | ConvertTo-Completion -ResultType ProviderItem
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'InRight' {
            It '<Left>(cursor)<Right>' -ForEach @(
                @{
                    Left     = ' ';
                    Right    = ' 漢```''帝`　国`'' ';
                    Expected = (
                        ('Evol', 'Gepada', 'Gepard' |
                        ForEach-Object {
                            @{
                                CompletionText = "Aquarion`` Evol/$_";
                                ListItemText   = "Aquarion Evol/$_"
                            }
                        }) + @('Deava', 'Dr.Wily', 'Pwsh/L1/L2/🏪.ps1', 'Pwsh/OptionLike/-foo.ps1', 'test.config')
                    ) | ConvertTo-Completion -ResultType ProviderItem
                },
                @{
                    Left     = 'De';
                    Right    = ' 漢```''帝`　国`'' ';
                    Expected = 'Deava' | ConvertTo-Completion -ResultType ProviderItem
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
                    $Expected = '../L1/L2/🏪.ps1', '../OptionLike/-foo.ps1' | ConvertTo-Completion -ResultType ProviderItem
                    "git $Command $Line" | Complete-FromLine | Should -BeCompletion $Expected
                }
                It 'Parent2' {
                    $Line = '../L'
                    $Expected = '../L1/L2/🏪.ps1' | ConvertTo-Completion -ResultType ProviderItem
                    "git $Command $Line" | Complete-FromLine | Should -BeCompletion $Expected
                }
                It 'ParentCurrent' {
                    $Line = '..//./'
                    $Expected = '..//./L1/L2/🏪.ps1', '..//./OptionLike/-foo.ps1' | ConvertTo-Completion -ResultType ProviderItem
                    "git $Command $Line" | Complete-FromLine | Should -BeCompletion $Expected
                }
                It 'ParentParent' {
                    $Line = '../../'
                    $Expected = (
                        ('Evol', 'Gepada', 'Gepard' |
                        ForEach-Object {
                            @{
                                CompletionText = "../../Aquarion`` Evol/$_";
                                ListItemText   = "../../Aquarion Evol/$_"
                            }
                        }) + @(
                            '../../Deava', '../../Dr.Wily', '../../Pwsh/L1/L2/🏪.ps1', '../../Pwsh/OptionLike/-foo.ps1', '../../test.config', @{
                                CompletionText = '../../漢```''帝`　国`''';
                                ListItemText   = '../../漢`''帝　国''';
                            }
                        ) | ConvertTo-Completion -ResultType ProviderItem
                    )
                    "git $Command $Line" | Complete-FromLine | Should -BeCompletion $Expected
                }
            }
        }
    }
}