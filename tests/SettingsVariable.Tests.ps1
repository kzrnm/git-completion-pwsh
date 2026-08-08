Describe 'GitCompletionSettings' {
    BeforeAll {
        Get-ChildItem Env:\GIT_COMPLETION* | Rename-Item -NewName { "Back" + $_.Name }

        function Import-GitCompletion {
            param ([switch]$Packed)
            if ($Packed) {
                Import-Module "$PSScriptRoot/../${env:Module}/${env:Module}.psd1" -Force
            }
            else {
                Import-Module "$PSScriptRoot/../src/git-completion.psd1" -Force
            }
        }
    }
    AfterAll {
        Remove-Item Env:\GIT_COMPLETION*
        Get-ChildItem Env:\BackGIT_COMPLETION* | Rename-Item -NewName { $_.Name.Substring(4) }
    }

    BeforeEach {
        Get-Module git-completion, TestModule | Remove-Module -Force
        Remove-Variable "GitCompletionSettings" -Force -ErrorAction SilentlyContinue
        'git-completion' -in (Get-Module).Name | Should-BeFalse
        (Get-Variable GitCompletionSettings0 -ErrorAction SilentlyContinue) | Should-BeNull
    }
    It 'Default' {
        Import-GitCompletion -Packed:([bool]$env:TestPackedModule)
        $GitCompletionSettings.psobject.Properties | ForEach-Object { Set-Variable 'h' @{} } { $h[$_.name] = $_.Value } { 
            $h
        } | Should-BeEquivalent @{
            ShowAllCommand     = $false;
            ShowAllOptions     = $false;
            IgnoreCase         = $false;
            CheckoutNoGuess    = $false;
            AdditionalCommands = @();
            ExcludeCommands    = @();
        }
    }

    It 'EnvironmentVariable' {
        $env:GIT_COMPLETION_SHOW_ALL = 1
        $env:GIT_COMPLETION_SHOW_ALL_COMMANDS = 1
        $env:GIT_COMPLETION_IGNORE_CASE = 1
        $env:GIT_COMPLETION_CHECKOUT_NO_GUESS = 1
        Import-GitCompletion -Packed:([bool]$env:TestPackedModule)
        $GitCompletionSettings.psobject.Properties | ForEach-Object { Set-Variable 'h' @{} } { $h[$_.name] = $_.Value } { 
            $h
        } | Should-BeEquivalent @{
            ShowAllCommand     = $true;
            ShowAllOptions     = $true;
            IgnoreCase         = $true;
            CheckoutNoGuess    = $true;
            AdditionalCommands = @();
            ExcludeCommands    = @();
        }
    }

    It 'EnvironmentVariable=0' {
        $env:GIT_COMPLETION_SHOW_ALL = 0
        $env:GIT_COMPLETION_SHOW_ALL_COMMANDS = 0
        $env:GIT_COMPLETION_IGNORE_CASE = 0
        $env:GIT_COMPLETION_CHECKOUT_NO_GUESS = 0
        Import-GitCompletion -Packed:([bool]$env:TestPackedModule)
        $GitCompletionSettings.psobject.Properties | ForEach-Object { Set-Variable 'h' @{} } { $h[$_.name] = $_.Value } { 
            $h
        } | Should-BeEquivalent @{
            ShowAllCommand     = $false;
            ShowAllOptions     = $false;
            IgnoreCase         = $false;
            CheckoutNoGuess    = $false;
            AdditionalCommands = @();
            ExcludeCommands    = @();
        }
    }

    It 'Preset' {
        $global:GitCompletionSettings = @{
            ShowAllCommand     = 0;
            ShowAllOptions     = 0;
            AdditionalCommands = @("ls-files");
            ExcludeCommands    = @("shortlog");
        }
        $env:GIT_COMPLETION_SHOW_ALL = 1
        $env:GIT_COMPLETION_SHOW_ALL_COMMANDS = 1
        $env:GIT_COMPLETION_IGNORE_CASE = 1
        $env:GIT_COMPLETION_CHECKOUT_NO_GUESS = 1
        Import-GitCompletion -Packed:([bool]$env:TestPackedModule)
        $GitCompletionSettings.psobject.Properties | ForEach-Object { Set-Variable 'h' @{} } { $h[$_.name] = $_.Value } { 
            $h
        } | Should-BeEquivalent @{
            ShowAllCommand     = $false;
            ShowAllOptions     = $false;
            IgnoreCase         = $true;
            CheckoutNoGuess    = $true;
            AdditionalCommands = @("ls-files");
            ExcludeCommands    = @("shortlog");
        }
    }
}
