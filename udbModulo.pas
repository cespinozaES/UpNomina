unit udbModulo;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.UI.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.VCLUI.Wait,
  Winapi.Windows, Vcl.Forms;

type
  TdbModulo = class(TDataModule)
    fdConexion: TFDConnection;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dbModulo: TdbModulo;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TdbModulo.DataModuleCreate(Sender: TObject);
begin
 {if FileExists(GetCurrentDir + '\' + 'UpNomina.db') then
 begin
 fdConexion.Close;
 fdConexion.Params.Database := GetCurrentDir + '\' + 'UpNomina.db';
 fdConexion.Open;
 end
 else
 begin
   Application.MessageBox('No se encuentra el archivo a conexion de base de datos',
        'Error', MB_OK + MB_ICONINFORMATION);
 end;}
end;

procedure TdbModulo.DataModuleDestroy(Sender: TObject);
begin
{fdConexion.Close;}
end;

end.
