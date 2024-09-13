// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
using System.Management.Automation;

namespace Kzrnm.GitCompletion;

public sealed class ModuleInitializer : IModuleAssemblyInitializer
{
    public void OnImport()
    {
        using var psinstance = PowerShell.Create(RunspaceMode.CurrentRunspace);
        psinstance
            .AddScript("[Kzrnm.GitCompletion.GitCompletionSettings]$GitCompletionSettings = [Kzrnm.GitCompletion.GitCompletionSettings]::Default")
            .Invoke();
    }
}