using System;
using System.Collections.Generic;
using System.Text;

namespace Kzrnm.GitCompletion.Completion;
internal interface IDescriptionBuilder
{
    string? Description(string candidate);
}
internal readonly struct EmptyDescriptionBuilder : IDescriptionBuilder
{
    string? IDescriptionBuilder.Description(string candidate) => null;
}