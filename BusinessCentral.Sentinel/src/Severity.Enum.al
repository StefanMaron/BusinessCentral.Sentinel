namespace STM.BusinessCentral.Sentinel;

enum 71180276 SeveritySESTM
{
    Access = Public;
    Extensible = false;

    value(1; Info)
    {
        Caption = 'Info';
    }
    value(2; Warning)
    {
        Caption = 'Warning';
    }
    value(3; Error)
    {
        Caption = 'Error';
    }
    value(4; Critical)
    {
        Caption = 'Critical';
    }
}