// Sentinel has `using System.DateTime;` but doesn't reference any type from it.
// al-runner still needs the namespace to exist, so we register it via a
// zero-field placeholder codeunit.
namespace System.DateTime;

codeunit 684 "Date-Time Dialog"
{
}
