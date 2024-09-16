// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
namespace Kzrnm.GitCompletion.Completion.Completer;
internal interface IDescriptionBuilder
{
    string? Description(string candidate);
}
internal readonly struct EmptyDescriptionBuilder : IDescriptionBuilder
{
    string? IDescriptionBuilder.Description(string candidate) => null;
}