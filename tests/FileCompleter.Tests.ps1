BeforeAll {
    . "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))tests/_TestInitialize.ps1"
    . "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))src/Complete/FileCompleter.ps1"
}

Describe 'FileCompleter' {
    BeforeAll {
        New-Item "$TestDrive/Root" -ItemType Directory
        New-Item "$TestDrive/aurora" -ItemType Directory
        New-Item "$TestDrive/aurora/canada" -ItemType File
        New-Item "$TestDrive/uncle" -ItemType File
        New-Item "$TestDrive/aunt" -ItemType File

        New-Item "$TestDrive/Root/漢字" -ItemType Directory
        New-Item "$TestDrive/Root/漢``帝国" -ItemType File
        New-Item "$TestDrive/Root/Deava" -ItemType File
        New-Item "$TestDrive/Root/Aquarion Evol" -ItemType Directory
        New-Item "$TestDrive/Root/Aquarion Evol/Evol" -ItemType File
        New-Item "$TestDrive/Root/Aquarion Evol/Gepard" -ItemType File
        New-Item "$TestDrive/Root/Aquarion Evol/Gepada" -ItemType File
        New-Item "$TestDrive/Root/Aquarion Evol/Ancient" -ItemType Directory

        Push-Location "$TestDrive/Root"
    }

    AfterAll {
        Pop-Location
    }

    It 'Prefix:<Prefix>, Current:<Current>' -ForEach @(
        @{
            Prefix   = '';
            Current  = 'Aquarion Evol';
            Expected = @(
                @{
                    CompletionText = 'Aquarion` Evol/';
                    ListItemText   = 'Aquarion Evol/';
                    ResultType     = 'ProviderContainer';
                    ToolTipOrig    = "TestDrive:/Root/Aquarion Evol";
                }
            )
        },
        @{
            Prefix   = 'Path=';
            Current  = 'Aquarion Evol';
            Expected = @(
                @{
                    CompletionText = 'Path=Aquarion` Evol/';
                    ListItemText   = 'Aquarion Evol/';
                    ResultType     = 'ProviderContainer';
                    ToolTipOrig    = "TestDrive:/Root/Aquarion Evol";
                }
            )
        },
        @{
            Prefix   = '';
            Current  = 'Aquarion Evol/';
            Expected = @(
                @{
                    CompletionText = 'Aquarion` Evol/Ancient/';
                    ListItemText   = 'Ancient/';
                    ResultType     = 'ProviderContainer';
                    ToolTipOrig    = "TestDrive:/Root/Aquarion Evol/Ancient";
                },
                @{
                    CompletionText = 'Aquarion` Evol/Evol';
                    ListItemText   = 'Evol';
                    ResultType     = 'ProviderItem';
                    ToolTipOrig    = "TestDrive:/Root/Aquarion Evol/Evol";
                },
                @{
                    CompletionText = 'Aquarion` Evol/Gepada';
                    ListItemText   = 'Gepada';
                    ResultType     = 'ProviderItem';
                    ToolTipOrig    = "TestDrive:/Root/Aquarion Evol/Gepada";
                },
                @{
                    CompletionText = 'Aquarion` Evol/Gepard';
                    ListItemText   = 'Gepard';
                    ResultType     = 'ProviderItem';
                    ToolTipOrig    = "TestDrive:/Root/Aquarion Evol/Gepard";
                }
            )
        },
        @{
            Prefix   = 'Path=';
            Current  = 'Aquarion Evol/';
            Expected = @(
                @{
                    CompletionText = 'Path=Aquarion` Evol/Ancient/';
                    ListItemText   = 'Ancient/';
                    ResultType     = 'ProviderContainer';
                    ToolTipOrig    = "TestDrive:/Root/Aquarion Evol/Ancient";
                },
                @{
                    CompletionText = 'Path=Aquarion` Evol/Evol';
                    ListItemText   = 'Evol';
                    ResultType     = 'ProviderItem';
                    ToolTipOrig    = "TestDrive:/Root/Aquarion Evol/Evol";
                },
                @{
                    CompletionText = 'Path=Aquarion` Evol/Gepada';
                    ListItemText   = 'Gepada';
                    ResultType     = 'ProviderItem';
                    ToolTipOrig    = "TestDrive:/Root/Aquarion Evol/Gepada";
                },
                @{
                    CompletionText = 'Path=Aquarion` Evol/Gepard';
                    ListItemText   = 'Gepard';
                    ResultType     = 'ProviderItem';
                    ToolTipOrig    = "TestDrive:/Root/Aquarion Evol/Gepard";
                }
            )
        },
        @{
            Prefix   = '';
            Current  = '漢';
            Expected = @(
                @{
                    CompletionText = '漢字/';
                    ListItemText   = '漢字/';
                    ResultType     = 'ProviderContainer';
                    ToolTipOrig    = "TestDrive:/Root/漢字";
                },
                @{
                    CompletionText = '漢``帝国';
                    ListItemText   = '漢`帝国';
                    ResultType     = 'ProviderItem';
                    ToolTipOrig    = "TestDrive:/Root/漢``帝国";
                }
            )
        },
        @{
            Prefix   = 'Path=';
            Current  = '漢';
            Expected = @(
                @{
                    CompletionText = 'Path=漢字/';
                    ListItemText   = '漢字/';
                    ResultType     = 'ProviderContainer';
                    ToolTipOrig    = "TestDrive:/Root/漢字";
                },
                @{
                    CompletionText = 'Path=漢``帝国';
                    ListItemText   = '漢`帝国';
                    ResultType     = 'ProviderItem';
                    ToolTipOrig    = "TestDrive:/Root/漢``帝国";
                }
            )
        },
        @{
            Prefix   = '';
            Current  = '../';
            Expected = @(
                @{
                    CompletionText = '../aurora/';
                    ListItemText   = 'aurora/';
                    ResultType     = 'ProviderContainer';
                    ToolTipOrig    = "TestDrive:/aurora";
                },
                @{
                    CompletionText = '../Root/';
                    ListItemText   = 'Root/';
                    ResultType     = 'ProviderContainer';
                    ToolTipOrig    = "TestDrive:/Root";
                },
                @{
                    CompletionText = '../aunt';
                    ListItemText   = 'aunt';
                    ResultType     = 'ProviderItem';
                    ToolTipOrig    = "TestDrive:/aunt";
                },
                @{
                    CompletionText = '../uncle';
                    ListItemText   = 'uncle';
                    ResultType     = 'ProviderItem';
                    ToolTipOrig    = "TestDrive:/uncle";
                }
            )
        },
        @{
            Prefix   = 'Path=';
            Current  = '../';
            Expected = @(
                @{
                    CompletionText = 'Path=../aurora/';
                    ListItemText   = 'aurora/';
                    ResultType     = 'ProviderContainer';
                    ToolTipOrig    = "TestDrive:/aurora";
                },
                @{
                    CompletionText = 'Path=../Root/';
                    ListItemText   = 'Root/';
                    ResultType     = 'ProviderContainer';
                    ToolTipOrig    = "TestDrive:/Root";
                },
                @{
                    CompletionText = 'Path=../aunt';
                    ListItemText   = 'aunt';
                    ResultType     = 'ProviderItem';
                    ToolTipOrig    = "TestDrive:/aunt";
                },
                @{
                    CompletionText = 'Path=../uncle';
                    ListItemText   = 'uncle';
                    ResultType     = 'ProviderItem';
                    ToolTipOrig    = "TestDrive:/uncle";
                }
            )
        }    
        @{
            Prefix   = '';
            Current  = '';
            Expected = @(
                @{
                    CompletionText = 'Aquarion` Evol/';
                    ListItemText   = 'Aquarion Evol/';
                    ResultType     = 'ProviderContainer';
                    ToolTipOrig    = "TestDrive:/Root/Aquarion Evol";
                },
                @{
                    CompletionText = '漢字/';
                    ListItemText   = '漢字/';
                    ResultType     = 'ProviderContainer';
                    ToolTipOrig    = "TestDrive:/Root/漢字";
                },
                @{
                    CompletionText = 'Deava';
                    ListItemText   = 'Deava';
                    ResultType     = 'ProviderItem';
                    ToolTipOrig    = "TestDrive:/Root/Deava";
                },
                @{
                    CompletionText = '漢``帝国';
                    ListItemText   = '漢`帝国';
                    ResultType     = 'ProviderItem';
                    ToolTipOrig    = "TestDrive:/Root/漢``帝国";
                }
            )
        },
        @{
            Prefix   = 'Path=';
            Current  = '';
            Expected = @(
                @{
                    CompletionText = 'Path=Aquarion` Evol/';
                    ListItemText   = 'Aquarion Evol/';
                    ResultType     = 'ProviderContainer';
                    ToolTipOrig    = "TestDrive:/Root/Aquarion Evol";
                },
                @{
                    CompletionText = 'Path=漢字/';
                    ListItemText   = '漢字/';
                    ResultType     = 'ProviderContainer';
                    ToolTipOrig    = "TestDrive:/Root/漢字";
                },
                @{
                    CompletionText = 'Path=Deava';
                    ListItemText   = 'Deava';
                    ResultType     = 'ProviderItem';
                    ToolTipOrig    = "TestDrive:/Root/Deava";
                },
                @{
                    CompletionText = 'Path=漢``帝国';
                    ListItemText   = '漢`帝国';
                    ResultType     = 'ProviderItem';
                    ToolTipOrig    = "TestDrive:/Root/漢``帝国";
                }
            )
        },
        @{
            Prefix   = '';
            Current  = 'Aquarion Logos';
            Expected = @()
        }
    ) {
        foreach ($e in $Expected) {
            $e.ToolTip = (Get-item ($e.ToolTipOrig -creplace '^TestDrive:', $TestDrive)).FullName
        }
        Complete-FilePath $Current -Prefix $Prefix | Should -BeCompletion $Expected
    }
}