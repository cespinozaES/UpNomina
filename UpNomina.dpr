program UpNomina;

uses
  Vcl.Forms,
  uPrincipal in 'uPrincipal.pas' {fmPrincipal},
  udbModulo in 'udbModulo.pas' {dbModulo: TDataModule},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Aqua Light Slate');
  Application.CreateForm(TfmPrincipal, fmPrincipal);
  Application.CreateForm(TdbModulo, dbModulo);
  Application.Run;
end.
