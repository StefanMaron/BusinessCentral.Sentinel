// `EvaluationCompanyInProd.Codeunit.al` carries `using Microsoft.Foundation.Company;`
// alongside `using System.Environment.Configuration;`. al-runner rejects the
// `using` if the namespace is not declared anywhere, so we register it with a
// placeholder codeunit that is never referenced.
namespace Microsoft.Foundation.Company;

codeunit 79 "Company Triggers"
{
}
