. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe 'FileCompleter' -Tag File {
    BeforeAll {
        . "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))src/Complete/CompleteFile.ps1"

        New-Item "$TestDrive/gitRoot" -ItemType Directory
        New-Item "$TestDrive/aurora" -ItemType Directory
        New-Item "$TestDrive/aurora/canada" -ItemType File
        New-Item "$TestDrive/uncle" -ItemType File
        New-Item "$TestDrive/aunt" -ItemType File

        New-Item "$TestDrive/gitRoot/漢字" -ItemType Directory
        New-Item "$TestDrive/gitRoot/漢``'帝　国'" -ItemType File
        New-Item "$TestDrive/gitRoot/Deava" -ItemType File
        New-Item "$TestDrive/gitRoot/Aquarion Evol" -ItemType Directory
        New-Item "$TestDrive/gitRoot/Aquarion Evol/Evol" -ItemType File
        New-Item "$TestDrive/gitRoot/Aquarion Evol/Gepard" -ItemType File
        New-Item "$TestDrive/gitRoot/Aquarion Evol/Gepada" -ItemType File
        New-Item "$TestDrive/gitRoot/Aquarion Evol/Ancient" -ItemType Directory

        Push-Location "$TestDrive/gitRoot"
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
                TestDriveFile  = "TestDrive:/gitRoot/Aquarion Evol";
            } | ConvertTo-Completion -ResultType ProviderItem
        },
        @{
            Prefix   = 'Path=';
            Current  = 'Aquarion Evol';
            Expected = @{
                CompletionText = 'Path=Aquarion` Evol/';
                ListItemText   = 'Aquarion Evol/';
                TestDriveFile  = "TestDrive:/gitRoot/Aquarion Evol";
            } | ConvertTo-Completion -ResultType ProviderItem
        },
        @{
            Prefix   = '';
            Current  = 'Aquarion Evol/';
            Expected = @{
                CompletionText = 'Aquarion` Evol/Ancient/';
                ListItemText   = 'Ancient/';
                TestDriveFile  = "TestDrive:/gitRoot/Aquarion Evol/Ancient";
            },
            @{
                CompletionText = 'Aquarion` Evol/Evol';
                ListItemText   = 'Evol';
                TestDriveFile  = "TestDrive:/gitRoot/Aquarion Evol/Evol";
            },
            @{
                CompletionText = 'Aquarion` Evol/Gepada';
                ListItemText   = 'Gepada';
                TestDriveFile  = "TestDrive:/gitRoot/Aquarion Evol/Gepada";
            },
            @{
                CompletionText = 'Aquarion` Evol/Gepard';
                ListItemText   = 'Gepard';
                TestDriveFile  = "TestDrive:/gitRoot/Aquarion Evol/Gepard";
            } | ConvertTo-Completion -ResultType ProviderItem
        },
        @{
            Prefix   = 'Path=';
            Current  = 'Aquarion Evol/';
            Expected = @{
                CompletionText = 'Path=Aquarion` Evol/Ancient/';
                ListItemText   = 'Ancient/';
                TestDriveFile  = "TestDrive:/gitRoot/Aquarion Evol/Ancient";
            },
            @{
                CompletionText = 'Path=Aquarion` Evol/Evol';
                ListItemText   = 'Evol';
                TestDriveFile  = "TestDrive:/gitRoot/Aquarion Evol/Evol";
            },
            @{
                CompletionText = 'Path=Aquarion` Evol/Gepada';
                ListItemText   = 'Gepada';
                TestDriveFile  = "TestDrive:/gitRoot/Aquarion Evol/Gepada";
            },
            @{
                CompletionText = 'Path=Aquarion` Evol/Gepard';
                ListItemText   = 'Gepard';
                TestDriveFile  = "TestDrive:/gitRoot/Aquarion Evol/Gepard";
            } | ConvertTo-Completion -ResultType ProviderItem
        },
        @{
            Prefix   = '';
            Current  = '漢';
            Expected = @{
                CompletionText = '漢字/';
                ListItemText   = '漢字/';
                TestDriveFile  = "TestDrive:/gitRoot/漢字";
            },
            @{
                CompletionText = '漢```''帝`　国`''';
                ListItemText   = "漢``'帝　国'";
                TestDriveFile  = "TestDrive:/gitRoot/漢``'帝　国'";
            } | ConvertTo-Completion -ResultType ProviderItem
        },
        @{
            Prefix   = 'Path=';
            Current  = '漢';
            Expected = @{
                CompletionText = 'Path=漢字/';
                ListItemText   = '漢字/';
                TestDriveFile  = "TestDrive:/gitRoot/漢字";
            },
            @{
                CompletionText = 'Path=漢```''帝`　国`''';
                ListItemText   = "漢``'帝　国'";
                TestDriveFile  = "TestDrive:/gitRoot/漢``'帝　国'";
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
                CompletionText = '../gitRoot/';
                ListItemText   = 'gitRoot/';
                TestDriveFile  = "TestDrive:/gitRoot";
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
                CompletionText = 'Path=../gitRoot/';
                ListItemText   = 'gitRoot/';
                TestDriveFile  = "TestDrive:/gitRoot";
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
                TestDriveFile  = "TestDrive:/gitRoot/Aquarion Evol";
            },
            @{
                CompletionText = '漢字/';
                ListItemText   = '漢字/';
                TestDriveFile  = "TestDrive:/gitRoot/漢字";
            },
            @{
                CompletionText = 'Deava';
                ListItemText   = 'Deava';
                TestDriveFile  = "TestDrive:/gitRoot/Deava";
            },
            @{
                CompletionText = '漢```''帝`　国`''';
                ListItemText   = "漢``'帝　国'";
                TestDriveFile  = "TestDrive:/gitRoot/漢``'帝　国'";
            } | ConvertTo-Completion -ResultType ProviderItem
        },
        @{
            Prefix   = 'Path=';
            Current  = '';
            Expected = @{
                CompletionText = 'Path=Aquarion` Evol/';
                ListItemText   = 'Aquarion Evol/';
                TestDriveFile  = "TestDrive:/gitRoot/Aquarion Evol";
            },
            @{
                CompletionText = 'Path=漢字/';
                ListItemText   = '漢字/';
                TestDriveFile  = "TestDrive:/gitRoot/漢字";
            },
            @{
                CompletionText = 'Path=Deava';
                ListItemText   = 'Deava';
                TestDriveFile  = "TestDrive:/gitRoot/Deava";
            },
            @{
                CompletionText = 'Path=漢```''帝`　国`''';
                ListItemText   = "漢``'帝　国'";
                TestDriveFile  = "TestDrive:/gitRoot/漢``'帝　国'";
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