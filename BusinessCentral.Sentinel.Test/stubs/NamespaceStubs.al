// Sentinel has `using` directives for a few namespaces it doesn't actually
// import any object from. al-runner requires the namespaces to be declared
// somewhere, so we register them via tiny placeholder codeunits that live in
// the IDs BC itself uses for objects there (not referenced from anywhere else).

namespace System.Environment.Configuration;

codeunit 9176 "Company-Initialize"
{
}
