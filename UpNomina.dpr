program UpNomina;

uses
  Vcl.Forms,
  uPrincipal in 'uPrincipal.pas' {Form1},
  udbModulo in 'udbModulo.pas' {dbModulo: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TdbModulo, dbModulo);
  Application.Run;
end.
