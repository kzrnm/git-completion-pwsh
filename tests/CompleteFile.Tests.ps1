. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe 'FileCompleter' {
    BeforeAll {
        . "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))src/Complete/CompleteFile.ps1"

        New-Item "$TestDrive/Root" -ItemType Directory
        New-Item "$TestDrive/aurora" -ItemType Directory
        New-Item "$TestDrive/aurora/canada" -ItemType File
        New-Item "$TestDrive/uncle" -ItemType File
        New-Item "$TestDrive/aunt" -ItemType File

        New-Item "$TestDrive/Root/漢字" -ItemType Directory
        New-Item "$TestDrive/Root/漢``'帝　国'" -ItemType File
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

    It 'Prefix:<Prefix>,Current:<Current>' -ForEach @(
        @{
            Prefix   = '';
            Current  = 'Aquarion Evol';
            Expected = @{
                CompletionText = 'Aquarion` Evol/';
                ListItemText   = 'Aquarion Evol/';
                TestDriveFile  = "TestDrive:/Root/Aquarion Evol";
            } | ConvertTo-Completion -ResultType ProviderItem
        },
        @{
            Prefix   = 'Path=';
            Current  = 'Aquarion Evol';
            Expected = @{
                CompletionText = 'Path=Aquarion` Evol/';
                ListItemText   = 'Aquarion Evol/';
                TestDriveFile  = "TestDrive:/Root/Aquarion Evol";
            } | ConvertTo-Completion -ResultType ProviderItem
        },
        @{
            Prefix   = '';
            Current  = 'Aquarion Evol/';
            Expected = @{
                CompletionText = 'Aquarion` Evol/Ancient/';
                ListItemText   = 'Ancient/';
                TestDriveFile  = "TestDrive:/Root/Aquarion Evol/Ancient";
            },
            @{
                CompletionText = 'Aquarion` Evol/Evol';
                ListItemText   = 'Evol';
                TestDriveFile  = "TestDrive:/Root/Aquarion Evol/Evol";
            },
            @{
                CompletionText = 'Aquarion` Evol/Gepada';
                ListItemText   = 'Gepada';
                TestDriveFile  = "TestDrive:/Root/Aquarion Evol/Gepada";
            },
            @{
                CompletionText = 'Aquarion` Evol/Gepard';
                ListItemText   = 'Gepard';
                TestDriveFile  = "TestDrive:/Root/Aquarion Evol/Gepard";
            } | ConvertTo-Completion -ResultType ProviderItem
        },
        @{
            Prefix   = 'Path=';
            Current  = 'Aquarion Evol/';
            Expected = @{
                CompletionText = 'Path=Aquarion` Evol/Ancient/';
                ListItemText   = 'Ancient/';
                TestDriveFile  = "TestDrive:/Root/Aquarion Evol/Ancient";
            },
            @{
                CompletionText = 'Path=Aquarion` Evol/Evol';
                ListItemText   = 'Evol';
                TestDriveFile  = "TestDrive:/Root/Aquarion Evol/Evol";
            },
            @{
                CompletionText = 'Path=Aquarion` Evol/Gepada';
                ListItemText   = 'Gepada';
                TestDriveFile  = "TestDrive:/Root/Aquarion Evol/Gepada";
            },
            @{
                CompletionText = 'Path=Aquarion` Evol/Gepard';
                ListItemText   = 'Gepard';
                TestDriveFile  = "TestDrive:/Root/Aquarion Evol/Gepard";
            } | ConvertTo-Completion -ResultType ProviderItem
        },
        @{
            Prefix   = '';
            Current  = '漢';
            Expected = @{
                CompletionText = '漢字/';
                ListItemText   = '漢字/';
                TestDriveFile  = "TestDrive:/Root/漢字";
            },
            @{
                CompletionText = '漢```''帝`　国`''';
                ListItemText   = "漢``'帝　国'";
                TestDriveFile  = "TestDrive:/Root/漢``'帝　国'";
            } | ConvertTo-Completion -ResultType ProviderItem
        },
        @{
            Prefix   = 'Path=';
            Current  = '漢';
            Expected = @{
                CompletionText = 'Path=漢字/';
                ListItemText   = '漢字/';
                TestDriveFile  = "TestDrive:/Root/漢字";
            },
            @{
                CompletionText = 'Path=漢```''帝`　国`''';
                ListItemText   = "漢``'帝　国'";
                TestDriveFile  = "TestDrive:/Root/漢``'帝　国'";
            } | ConvertTo-Completion -ResultType ProviderItem
        },
        @{
            Prefix   = '';
            Current  = '../';
            Expected = @{
                CompletionText = '../aurora/';
                ListItemText   = 'aurora/';
                TestDriveFile  = "TestDrive:/aurora";
            },
            @{
                CompletionText = '../Root/';
                ListItemText   = 'Root/';
                TestDriveFile  = "TestDrive:/Root";
            },
            @{
                CompletionText = '../aunt';
                ListItemText   = 'aunt';
                TestDriveFile  = "TestDrive:/aunt";
            },
            @{
                CompletionText = '../uncle';
                ListItemText   = 'uncle';
                TestDriveFile  = "TestDrive:/uncle";
            } | ConvertTo-Completion -ResultType ProviderItem
        },
        @{
            Prefix   = 'Path=';
            Current  = '../';
            Expected = @{
                CompletionText = 'Path=../aurora/';
                ListItemText   = 'aurora/';
                TestDriveFile  = "TestDrive:/aurora";
            },
            @{
                CompletionText = 'Path=../Root/';
                ListItemText   = 'Root/';
                TestDriveFile  = "TestDrive:/Root";
            },
            @{
                CompletionText = 'Path=../aunt';
                ListItemText   = 'aunt';
                TestDriveFile  = "TestDrive:/aunt";
            },
            @{
                CompletionText = 'Path=../uncle';
                ListItemText   = 'uncle';
                TestDriveFile  = "TestDrive:/uncle";
            } | ConvertTo-Completion -ResultType ProviderItem
        }    
        @{
            Prefix   = '';
            Current  = '';
            Expected = @{
                CompletionText = 'Aquarion` Evol/';
                ListItemText   = 'Aquarion Evol/';
                TestDriveFile  = "TestDrive:/Root/Aquarion Evol";
            },
            @{
                CompletionText = '漢字/';
                ListItemText   = '漢字/';
                TestDriveFile  = "TestDrive:/Root/漢字";
            },
            @{
                CompletionText = 'Deava';
                ListItemText   = 'Deava';
                TestDriveFile  = "TestDrive:/Root/Deava";
            },
            @{
                CompletionText = '漢```''帝`　国`''';
                ListItemText   = "漢``'帝　国'";
                TestDriveFile  = "TestDrive:/Root/漢``'帝　国'";
            } | ConvertTo-Completion -ResultType ProviderItem
        },
        @{
            Prefix   = 'Path=';
            Current  = '';
            Expected = @{
                CompletionText = 'Path=Aquarion` Evol/';
                ListItemText   = 'Aquarion Evol/';
                TestDriveFile  = "TestDrive:/Root/Aquarion Evol";
            },
            @{
                CompletionText = 'Path=漢字/';
                ListItemText   = '漢字/';
                TestDriveFile  = "TestDrive:/Root/漢字";
            },
            @{
                CompletionText = 'Path=Deava';
                ListItemText   = 'Deava';
                TestDriveFile  = "TestDrive:/Root/Deava";
            },
            @{
                CompletionText = 'Path=漢```''帝`　国`''';
                ListItemText   = "漢``'帝　国'";
                TestDriveFile  = "TestDrive:/Root/漢``'帝　国'";
            } | ConvertTo-Completion -ResultType ProviderItem
        },
        @{
            Prefix   = '';
            Current  = 'Aquarion Logos';
            Expected = @()
        }
    ) {
        foreach ($e in $Expected) {
            $e.ToolTip = (Get-item ($e.TestDriveFile -creplace '^TestDrive:', $TestDrive)).FullName
        }
        completeCurrentDirectory $Current -Prefix $Prefix | Should -BeCompletion $Expected
    }
}