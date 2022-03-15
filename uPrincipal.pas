unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.StdCtrls, Vcl.Grids,
  Vcl.DBGrids, FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.VCLUI.Wait,
  Vcl.Buttons, Vcl.ComCtrls, REST.Types, Data.Bind.Components,
  Data.Bind.ObjectScope, REST.Client, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP, IdAuthentication, Vcl.ExtCtrls,
  udbModulo, System.NetEncoding, System.JSON;

procedure validarEncabezadoCSV(sListaEncabezado, sListaColumna,
  sListaErrores: TStringList; I: Integer; qryprincipal: TFDQuery;
  var ivalidador: Integer; var sListaCodEncabezado: TStringList);
procedure validadorDetallesCSV(sListaEncabezado, sListaColumna,
  sListaErrores: TStringList; I: Integer; qrysecundario: TFDQuery;
  var ivalidador: Integer; var sListaCodDetalles: TStringList);

procedure ParseJsonValor(sResultadoPost: String; var scode: string);

function validarCodigos(sListaCodEncabezado, sListaCodDetalles
  : TStringList): Boolean;

type
  TfmPrincipal = class(TForm)
    odCargarArchivo: TOpenDialog;
    dbgEncabezado: TDBGrid;
    dsEncabezado: TDataSource;
    dbgDetalles: TDBGrid;
    dsDetalles: TDataSource;
    qrDetalles: TFDQuery;
    qrEncabezado: TFDQuery;
    sbtnSalir: TSpeedButton;
    sbtnAyuda: TSpeedButton;
    sbtnCargarService: TSpeedButton;
    sbtnEncabezado: TSpeedButton;
    sbtnDetalles: TSpeedButton;
    GroupBox4: TGroupBox;
    sbtnAceptar: TSpeedButton;
    GroupBox3: TGroupBox;
    lblEmpresaNit: TLabel;
    lblEmpresaId: TLabel;
    edtNit: TEdit;
    edtId: TEdit;
    GroupBox2: TGroupBox;
    lblContraseña: TLabel;
    lblUsuario: TLabel;
    edtContraseña: TEdit;
    edtUsuario: TEdit;
    gpArchivos: TGroupBox;
    idService: TIdHTTP;
    GroupBox1: TGroupBox;
    edturl: TEdit;
    url: TLabel;
    pbProgreso: TProgressBar;
    SpeedButton1: TSpeedButton;
    mErrores: TMemo;
    CheckBox1: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sbtnSalirClick(Sender: TObject);
    procedure sbtnEncabezadoClick(Sender: TObject);
    procedure sbtnDetallesClick(Sender: TObject);
    procedure sbtnAyudaClick(Sender: TObject);
    procedure edtContraseñaChange(Sender: TObject);
    procedure sbtnAceptarClick(Sender: TObject);
    procedure sbtnCargarServiceClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    sUsuario, sContraseña, sNit, sId, surl, scomprobante: String;
    iProcesos, iNumEncabezados, iNumDetalles: Integer;
    sListaCodEncabezado: TStringList;
    sListaCodDetalles: TStringList;

  end;

var
  fmPrincipal: TfmPrincipal;

implementation

{$R *.dfm}

procedure ParseJsonValor(sResultadoPost: String; var scode: string);
var
  JSonObject: TJSONObject;
  Jcode: TJSONValue;
begin
  JSonObject := TJSONObject.Create;
  JSonObject := TJSONObject.ParseJSONValue(sResultadoPost) as TJSONObject;
  Jcode := JSonObject.FindValue('error');
  if Assigned(Jcode) then
  begin
    scode := 'Error al subir comprobante:';
  end
  else
    scode := 'Comprobante cargado correctamente:';

  JSonObject.Free;
end;

function validarCodigos(sListaCodEncabezado, sListaCodDetalles
  : TStringList): Boolean;
begin
  if sListaCodEncabezado.Text = sListaCodDetalles.Text then
  begin
    Result := True;
  end
  else
  begin
    Result := False;
  end;

end;

procedure validadorDetallesCSV(sListaEncabezado, sListaColumna,
  sListaErrores: TStringList; I: Integer; qrysecundario: TFDQuery;
  var ivalidador: Integer; var sListaCodDetalles: TStringList);
var
  inumero: Integer;
begin
  if sListaColumna.Count = 11 then
  begin
    if I = 0 then
    begin
      if (sListaColumna[0] <> 'COMNUM') or (sListaColumna[1] <> 'TIPCOMID') or
        (sListaColumna[2] <> 'COMCONS') or (sListaColumna[3] <> 'PLACUECOD') or
        (sListaColumna[4] <> 'COMTIPOMOV') or (sListaColumna[5] <> 'COMVAL') or
        (sListaColumna[6] <> 'COMNITDET') or (sListaColumna[7] <> 'COMVALRET')
        or (sListaColumna[8] <> 'COMCONDET') or (sListaColumna[9] <> 'CENCOSID')
        or (sListaColumna[10] <> 'COMDOCSOP') then
      begin
        sListaErrores.Add('Error: Encabezados del archivo no válido' +
          sLineBreak);
        ivalidador := ivalidador + 1;
      end;
    end
    // Validamos el contenido de cada columna del archivo
    else
    begin
      // ShowMessage(sListaColumna.Text);
      // Validamos si COMNUM es de tipo numérico
      if TryStrToInt(sListaColumna[0], inumero) = False then
      begin
        sListaErrores.Add('Error: No es un valor numérico, Celda: ' +
          sListaColumna[0] + ' /Columna: COMNUM' + sLineBreak);
        ivalidador := ivalidador + 1;
      end;
      // Validamos que TIPCOMID TENGA 3 LETRAS
      if Length(sListaColumna[1]) <> 3 then
      begin
        sListaErrores.Add('Error: No contiene 3 letras, Celda: ' + sListaColumna
          [1] + ' /Columna: TIPCOMID' + sLineBreak);
        ivalidador := ivalidador + 1;
      end;
      // Validamos que COMCONS sea numérico
      if TryStrToInt(sListaColumna[2], inumero) = False then
      begin
        sListaErrores.Add('Error: No es un valor numérico, Celda: ' +
          sListaColumna[2] + ' /Columna: COMCONS' + sLineBreak);
        ivalidador := ivalidador + 1;
      end;
      // Validamos que PLACUECOD sea numérico
      if TryStrToInt(sListaColumna[3], inumero) = False then
      begin
        sListaErrores.Add('Error: No es un valor numérico, Celda: ' +
          sListaColumna[3] + ' /Columna: PLACUECOD' + sLineBreak);
        ivalidador := ivalidador + 1;
      end;
      // Validamos que COMTIPOMOV sea D o C
      if (sListaColumna[4] <> 'D') and (sListaColumna[4] <> 'C') then
      begin
        sListaErrores.Add('Error: Debe ser D o C, Celda: ' + sListaColumna[4] +
          ' /Columna: COMTIPOMOV' + sLineBreak);
        ivalidador := ivalidador + 1;
      end;
      // Validamos que COMVAL sea numérico
      if TryStrToInt(sListaColumna[5], inumero) = False then
      begin
        sListaErrores.Add('Error: No es un valor numérico, Celda: ' +
          sListaColumna[5] + ' /Columna: COMVAL' + sLineBreak);
        ivalidador := ivalidador + 1;
      end;
      // Validamos que COMNNITDET sea numérico
      if TryStrToInt(sListaColumna[6], inumero) = False then
      begin
        sListaErrores.Add('Error: No es un valor numérico, Celda: ' +
          sListaColumna[6] + ' /Columna: COMNNITDET' + sLineBreak);
        ivalidador := ivalidador + 1;
      end;
      // Validamos que COMCONDET tenga maximo 80 carácteres y solo texto
      if Length(sListaColumna[8]) > 80 then
      begin
        sListaErrores.Add
          ('Error: El texto no debe ser superior a 80 carácteres, Celda: ' +
          sListaColumna[8] + ' /Columna: COMDONDET' + sLineBreak);
        ivalidador := ivalidador + 1;
      end;
      // Validamos que CENCOSID sea numérico
      if TryStrToInt(sListaColumna[9], inumero) = False then
      begin
        sListaErrores.Add('Error: No es un valor numérico, Celda: ' +
          sListaColumna[9] + ' /Columna: CENCOSID' + sLineBreak);
        ivalidador := ivalidador + 1;
      end;
      // Validamos que COMDOCSOP sea numérico o vacío
      if TryStrToInt(sListaColumna[10], inumero) = False then
      begin
        sListaErrores.Add
          ('Error: No es un valor numérico o una celda vacía, Celda: ' +
          sListaColumna[10] + ' /Columna: COMDOCSOP' + sLineBreak);
        ivalidador := ivalidador + 1;
      end;
      // Llenamos la lista con los códigos del archivo detalles para luego compararlos con
      // los códigos de Encabezado
      if ivalidador = 0 then
      begin
        // Insertamos los datos en la base de datos de detalle
        qrysecundario.Close;
        qrysecundario.SQL.Clear;
        qrysecundario.SQL.Add('INSERT INTO ');
        qrysecundario.SQL.Add('COMPROBANTE_DETALLE');
        qrysecundario.SQL.Add
          ('(COMNUM,TIPCOMID,COMCONS,PLACUECOD,COMTIPOMOV,COMVAL,COMNITDET,COMVALRET,COMCONDET,CENCOSID,COMDOCSOP)');
        qrysecundario.SQL.Add('VALUES');
        qrysecundario.SQL.Add
          ('(:COMNUM, :TIPCOMID, :COMCONS, :PLACUECOD, :COMTIPOMOV, :COMVAL, :COMNITDET, :COMVALRET, :COMCONDET, :CENCOSID, :COMDOCSOP)');
        qrysecundario.ParamByName('COMNUM').AsString := sListaColumna[0];
        qrysecundario.ParamByName('TIPCOMID').AsString := sListaColumna[1];
        qrysecundario.ParamByName('COMCONS').AsString := sListaColumna[2];
        qrysecundario.ParamByName('PLACUECOD').AsString := sListaColumna[3];
        qrysecundario.ParamByName('COMTIPOMOV').AsString := sListaColumna[4];
        qrysecundario.ParamByName('COMVAL').AsString := sListaColumna[5];
        qrysecundario.ParamByName('COMNITDET').AsString := sListaColumna[6];
        qrysecundario.ParamByName('COMVALRET').AsString := sListaColumna[7];
        qrysecundario.ParamByName('COMCONDET').AsString := sListaColumna[8];
        qrysecundario.ParamByName('CENCOSID').AsString := sListaColumna[9];
        qrysecundario.ParamByName('COMDOCSOP').AsString := sListaColumna[10];
        qrysecundario.ExecSQL;
        sListaCodDetalles.Add(sListaColumna[0]);
      end;
    end;
  end
  else
  begin
    sListaErrores.Add('Error: Cada fila debe tener 11 celdas /Fila:' +
      IntToStr(I + 1) + '' + sLineBreak);
    ivalidador := ivalidador + 1;
  end;
end;

procedure validarEncabezadoCSV(sListaEncabezado, sListaColumna,
  sListaErrores: TStringList; I: Integer; qryprincipal: TFDQuery;
  var ivalidador: Integer; var sListaCodEncabezado: TStringList);
var
  J, inumero: Integer;
  dfecha: TDateTime;

begin
  if sListaColumna.Count = 8 then
  begin
    if I = 0 then
    begin
      sListaColumna.Text := UpperCase(sListaColumna.Text);
      if (sListaColumna[0] <> 'COMNUM') or (sListaColumna[1] <> 'COMFEC') or
        (sListaColumna[2] <> 'COMCON') or (sListaColumna[3] <> 'COMPERAGNO') or
        (sListaColumna[4] <> 'COMPERMES') or (sListaColumna[5] <> 'COMULTCOS')
        or (sListaColumna[6] <> 'COMANU') or (sListaColumna[7] <> 'TIPCOMID')
      then
      begin
        sListaErrores.Add('Error: Encabezados del archivo no válido' +
          sLineBreak);
        ivalidador := ivalidador + 1;
      end;
    end
    // Validamos el contenido de cada columna del archivo
    else
    begin
      // ShowMessage(sListaColumna.Text);
      // Validamos si COMNUM es de tipo numérico
      if TryStrToInt(sListaColumna[0], inumero) = False then
      begin
        sListaErrores.Add('Error: No es un valor numérico, Celda: ' +
          sListaColumna[0] + ' /Columna: COMNUM' + sLineBreak);
        ivalidador := ivalidador + 1;
      end;
      // Validamos si COMFEC esta en un formato fecha válido
      if TryStrToDate(sListaColumna[1], dfecha) = False then
      begin
        sListaErrores.Add
          ('Error: El formato de fecha debe ser válido dd/mm/yyyy, Celda: ' +
          sListaColumna[1] + ' /Columna: COMFEC' + sLineBreak);
        ivalidador := ivalidador + 1;
      end;

      // Validamos que COMCON tenga máximo 80 carácteres y solo texto
      if Length(sListaColumna[2]) > 80 then
      begin
        sListaErrores.Add
          ('Error: El texto no debe ser superior a 80 carácteres, Celda: ' +
          sListaColumna[2] + ' /Columna: COMCON' + sLineBreak);
        ivalidador := ivalidador + 1;
      end;
      // Validamos que COMPERAGNO sea un número de 4 dígitos
      if (TryStrToInt(sListaColumna[3], inumero) = False) or
        (Length(sListaColumna[3]) > 4) then
      begin
        sListaErrores.Add
          ('Error: Debe ser un valor numérico de 4 dígitos, Celda: ' +
          sListaColumna[3] + ' /Columna: COMPERAGNO' + sLineBreak);
        ivalidador := ivalidador + 1;
      end;
      // Validamos que COMPERMES sea número de 2 dígitos y no sea mayor a 12
      if TryStrToInt(sListaColumna[4], inumero) then
      begin
        if (StrToInt(sListaColumna[4]) <= 12) and
          (StrToInt(sListaColumna[4]) > 0) then
        begin
          if (Length(sListaColumna[4]) <> 2) then
          begin
           sListaColumna[4] := sListaColumna[4].PadLeft(2,'0');
          end;
        end
        else
        begin
          sListaErrores.Add
            ('Error: Debe ser un valor numérico de 2 dígitos y menor a 12, Celda: '
            + sListaColumna[4] + ' /Columna: COMPERMES' + sLineBreak);
          ivalidador := ivalidador + 1;
        end;
      end
      else
      begin
        sListaErrores.Add
          ('Error: Debe ser un valor numérico de 2 dígitos y menor a 12, Celda: '
          + sListaColumna[4] + ' /Columna: COMPERMES' + sLineBreak);
        ivalidador := ivalidador + 1;
      end;
      // Validamos que COMULTCOS sea mayor que 0
      if (TryStrToInt(sListaColumna[5], inumero) = False) or
        (StrToInt(sListaColumna[5]) <= 0) then
      begin
        sListaErrores.Add
          ('Error: Debe ser un valor numérico mayor que 0, Celda: ' +
          sListaColumna[5] + ' /Columna: COMULTCOS' + sLineBreak);
        ivalidador := ivalidador + 1;
      end;
      // Validamos que COMANU sea 0 ó 1
      if TryStrToInt(sListaColumna[6], inumero) then
      begin
        if (StrToInt(sListaColumna[6]) <> 0) and
          (StrToInt(sListaColumna[6]) <> 1) then
        begin
          sListaErrores.Add
            ('Error: Debe ser un valor numérico tipo 0 o 1, Celda: ' +
            sListaColumna[6] + ' /Columna: COMANU' + sLineBreak);
          ivalidador := ivalidador + 1;
        end;
      end
      else
      begin
        sListaErrores.Add
          ('Error: Debe ser un valor numérico tipo 0 o 1, Celda: ' +
          sListaColumna[6] + ' /Columna: COMANU' + sLineBreak);
        ivalidador := ivalidador + 1;
      end;
      // Validamos que TIPCOMID TENGA 3 LETRAS
      if Length(sListaColumna[7]) <> 3 then
      begin
        sListaErrores.Add('Error: No contiene 3 letras, Celda: ' + sListaColumna
          [7] + ' /Columna: TIPCOMID' + sLineBreak);
        ivalidador := ivalidador + 1;
      end;
      // Llenamos una lista con los códigos y la cantidad que debe tener el archivo detalle
      // para luego validar esta lista con la cantidad de códigos de detalles
      if ivalidador = 0 then
      begin
        // Insertamos los datos en la base de datos
        qryprincipal.Close;
        qryprincipal.SQL.Clear;
        qryprincipal.SQL.Add('INSERT OR REPLACE INTO');
        qryprincipal.SQL.Add('COMPROBANTE_ENCABEZADO');
        qryprincipal.SQL.Add
          ('(COMNUM,COMFEC,COMCON,COMPERAGNO,COMPERMES,COMULTCOS,COMANU,TIPCOMID)');
        qryprincipal.SQL.Add('VALUES');
        qryprincipal.SQL.Add
          ('(:COMNUM, :COMFEC, :COMCON, :COMPERAGNO, :COMPERMES, :COMULTCOS, :COMANU, :TIPCOMID)');
        qryprincipal.ParamByName('COMNUM').AsString := sListaColumna[0];
        qryprincipal.ParamByName('COMFEC').AsDate :=
          StrToDate(sListaColumna[1]);
        qryprincipal.ParamByName('COMCON').AsString := sListaColumna[2];
        qryprincipal.ParamByName('COMPERAGNO').AsString := sListaColumna[3];
        qryprincipal.ParamByName('COMPERMES').AsString := sListaColumna[4];
        qryprincipal.ParamByName('COMULTCOS').AsString := sListaColumna[5];
        qryprincipal.ParamByName('COMANU').AsString := sListaColumna[6];
        qryprincipal.ParamByName('TIPCOMID').AsString := sListaColumna[7];
        qryprincipal.ExecSQL;
        for J := 0 to StrToInt(sListaColumna[5]) - 1 do
        begin
          sListaCodEncabezado.Add(sListaColumna[0]);
        end;
      end;
    end;
  end
  else
  begin
    sListaErrores.Add('Error: Cada fila debe tener 8 celdas /Fila:' +
      IntToStr(I + 1) + '' + sLineBreak);
    ivalidador := ivalidador + 1;
  end;
end;


procedure TfmPrincipal.edtContraseñaChange(Sender: TObject);
begin
  edtContraseña.PasswordChar := #149;
end;

procedure TfmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  sListaCodEncabezado.Free;
  sListaCodDetalles.Free;
end;

procedure TfmPrincipal.FormCreate(Sender: TObject);
begin

  sListaCodEncabezado := TStringList.Create;
  sListaCodDetalles := TStringList.Create;
  Left := (Screen.Width - Width) div 2;
  Top := (Screen.Height - Height) div 2;
end;

procedure TfmPrincipal.sbtnSalirClick(Sender: TObject);
begin
  fmPrincipal.Close;
end;

procedure TfmPrincipal.SpeedButton1Click(Sender: TObject);
begin
  Application.Minimize;
end;

procedure TfmPrincipal.sbtnAceptarClick(Sender: TObject);
begin
  sUsuario := edtUsuario.Text;
  sContraseña := edtContraseña.Text;
  sId := edtId.Text;
  sNit := edtNit.Text;
  surl := edturl.Text;
  if (sUsuario = '') or (sContraseña = '') or (sId = '') or (sNit = '') or
    (surl = '') then
  begin
    Application.MessageBox('Se deben llenar todos los campos', 'Información',
      MB_OK + MB_ICONERROR);
    CheckBox1.Checked := False;
  end
  else
  begin
    CheckBox1.Checked := True;
    { Application.MessageBox('Se han cargado los datos correctamente',
      'Información', MB_OK + MB_ICONINFORMATION); }
  end;

end;

procedure TfmPrincipal.sbtnAyudaClick(Sender: TObject);
begin
  Application.MessageBox('Archivo Encabezado:' + sLineBreak +
    '1. COMNUM : Numérico' + sLineBreak + '2. COMFEC : Formato fecha DD/MM/YYYY'
    + sLineBreak + '3. COMCON : Texto máximo de 80 carácteres' + sLineBreak +
    '4. COMPERAGNO : Año, ejemplo: 2022' + sLineBreak +
    '5. COMPERMES : Mes, ejemplo: 03' + sLineBreak + '6. COMULTCOS : Numérico' +
    sLineBreak + '7. COMANU : 1 o 0' + sLineBreak + '8. TIPCOMID : 3 LETRAS' +
    sLineBreak + '' + sLineBreak + 'Archivo Detalle:' + sLineBreak +
    '1. COMNUM : Tipo Numérico Entero' + sLineBreak + '2. TIPCOMID : 3 LETRAS' +
    sLineBreak + '3. COMCONS : Numérico' + sLineBreak +
    '4. PLACUECOD : Numérico' + sLineBreak + '5. COMTIPOMOV : D o C' +
    sLineBreak + '6. COMVAL : Numérico' + sLineBreak + '7. COMNITDET : Numérico'
    + sLineBreak + '8. COMVALRET : Numérico' + sLineBreak +
    '9. COMCONDET : Texto máximo de 80 carácteres' + sLineBreak +
    '10. CENCOSID : Numérico' + sLineBreak + '11. COMDOCSOP : Numérico',
    'Ayuda', MB_OK + MB_ICONQUESTION);
end;

procedure TfmPrincipal.sbtnCargarServiceClick(Sender: TObject);
var
  qryRegistros, qrycargue: TFDQuery;
  sldatosEnc, sldatosDet: TStringList;
  scomnum, scomfec, scomcon, scomperagno, scompermes, scomultcos,
    scomanu: string;
  stipcomid, scomcons, splacuecod, scomtipomov, scomval, scomnitdet, scomvalret,
    scomcondet, scencosid, scomdocsop: String;
  sResultadoPost: String;
  sbase64, scode: String;
begin

  if (sUsuario = '') or (sContraseña = '') or (sId = '') or (sNit = '') or
    (surl = '') then
  begin
    Application.MessageBox
      ('Se deben llenar todos los campos de datos, Usuario, Contraseña, Nit, Id, url',
      'Información', MB_OK + MB_ICONERROR);
  end
  else
  begin
    sbase64 := TNetEncoding.Base64.Encode(sUsuario + ':' + sContraseña + ':' +
      sId + ':' + sNit);
    sldatosEnc := TStringList.Create;
    sldatosDet := TStringList.Create;
    qryRegistros := TFDQuery.Create(nil);
    qryRegistros.Connection := udbModulo.dbModulo.fdConexion;
    qryRegistros.SQL.Clear;
    qryRegistros.SQL.Add('SELECT * FROM COMPROBANTE_ENCABEZADO');
    qryRegistros.Open;
    qryRegistros.First;
    mErrores.Clear;
    mErrores.Lines.Add('Resultados archivo Encabezados:');
    try
      try
        while not qryRegistros.Eof do
        begin
          sldatosEnc.Clear;
          scomnum := qryRegistros.FieldByName('COMNUM').AsString;
          scomfec := qryRegistros.FieldByName('COMFEC').AsString;
          scomcon := qryRegistros.FieldByName('COMCON').AsString;
          scomperagno := qryRegistros.FieldByName('COMPERAGNO').AsString;
          scompermes := qryRegistros.FieldByName('COMPERMES').AsString;
          scomultcos := qryRegistros.FieldByName('COMULTCOS').AsString;
          scomanu := qryRegistros.FieldByName('COMANU').AsString;
          stipcomid := qryRegistros.FieldByName('TIPCOMID').AsString;
          sldatosEnc.Add('api=' + '');
          sldatosEnc.Add('usuario=' + sUsuario);
          sldatosEnc.Add('clave=' + sContraseña);
          sldatosEnc.Add('EmpresaId=' + sId);
          sldatosEnc.Add('ComNum=' + scomnum);
          sldatosEnc.Add('TipComId=' + stipcomid);
          sldatosEnc.Add('ComFec=' + scomfec);
          sldatosEnc.Add('ComNit=' + sNit);
          sldatosEnc.Add('ComCon=' + scomcon);
          sldatosEnc.Add('ComPerAgno=' + scomperagno);
          sldatosEnc.Add('ComPerMes=' + scompermes);
          sldatosEnc.Add('ComUltCons=' + scomultcos);
          sldatosEnc.Add('ComAnu=' + scomanu);
          idService.Request.ContentType := 'application/x-www-form-urlencoded';
          idService.Request.CustomHeaders.Values['Authorization'] := sbase64;

          sResultadoPost :=
            idService.Post(surl + '/crear_encabezado_comprobante2', sldatosEnc);
          // Miramos si el Json trae un error o se subio correctamente
          ParseJsonValor(sResultadoPost, scode);
          mErrores.Lines.Add(scode + ' -> Comnum: ' + scomnum);
          mErrores.Lines.Add('');
          pbProgreso.Position := pbProgreso.Position + 1;
          qryRegistros.Next;
        end;
        mErrores.Lines.Add('Resultados archivo Detalles:');
        qryRegistros.Close;
        qryRegistros.SQL.Clear;
        qryRegistros.SQL.Add('SELECT * FROM COMPROBANTE_DETALLE');
        qryRegistros.Open;
        qryRegistros.First;
        while not qryRegistros.Eof do
        begin
          sldatosDet.Clear;
          scomnum := qryRegistros.FieldByName('COMNUM').AsString;
          stipcomid := qryRegistros.FieldByName('TIPCOMID').AsString;
          scomcons := qryRegistros.FieldByName('COMCONS').AsString;
          splacuecod := qryRegistros.FieldByName('PLACUECOD').AsString;
          scomtipomov := qryRegistros.FieldByName('COMTIPOMOV').AsString;
          scomval := qryRegistros.FieldByName('COMVAL').AsString;
          scomnitdet := qryRegistros.FieldByName('COMNITDET').AsString;
          scomvalret := qryRegistros.FieldByName('COMVALRET').AsString;
          scomcondet := qryRegistros.FieldByName('COMCONDET').AsString;
          scencosid := qryRegistros.FieldByName('CENCOSID').AsString;
          scomdocsop := qryRegistros.FieldByName('COMDOCSOP').AsString;
          sldatosDet.Add('api=' + '');
          sldatosDet.Add('usuario=' + sUsuario);
          sldatosDet.Add('clave=' + sContraseña);
          sldatosDet.Add('EmpresaId=' + sId);
          sldatosDet.Add('EmpresaNit=' + sNit);
          sldatosDet.Add('ComNum=' + scomnum);
          sldatosDet.Add('TipComId=' + stipcomid);
          sldatosDet.Add('ComCons=' + scomcons);
          sldatosDet.Add('PlaCueCod=' + splacuecod);
          sldatosDet.Add('ComTipMov=' + scomtipomov);
          sldatosDet.Add('ComVal=' + scomval);
          sldatosDet.Add('ComNitDet=' + scomnitdet);
          sldatosDet.Add('ComValRet=' + scomvalret);
          sldatosDet.Add('ComConDet=' + scomcondet);
          sldatosDet.Add('CenCosId=' + scencosid);
          sldatosDet.Add('ComDocSop=' + scomdocsop);
          idService.Request.ContentType := 'application/x-www-form-urlencoded';
          idService.Request.CustomHeaders.Values['Authorization'] := sbase64;
          sResultadoPost := idService.Post(surl + '/crear_detalle_comprobante',
            sldatosDet);
          // Miramos si el Json trae un error o se subio correctamente
          ParseJsonValor(sResultadoPost, scode);
          mErrores.Lines.Add(scode + ' -> Comnum: ' + scomnum + ', Comcons:' +
            scomcons);
          mErrores.Lines.Add('');
          pbProgreso.Position := pbProgreso.Position + 1;
          qryRegistros.Next;
        end;
      except
        pbProgreso.Position := 0;
        raise Exception.Create('Error no se ha cargado correctamente');
      end;
    finally
      qryRegistros.Close;
      qryRegistros.Free;
      sldatosEnc.Free;
      sldatosDet.Free;
    end;
    qrycargue := TFDQuery.Create(nil);
    qrycargue.Connection := udbModulo.dbModulo.fdConexion;;
    qrycargue.SQL.Clear;
    qrycargue.Close;
    qrycargue.SQL.Add('INSERT INTO');
    qrycargue.SQL.Add('LOG_CARGUE');
    qrycargue.SQL.Add('(COMNUM, FECHA)');
    qrycargue.SQL.Add('SELECT');
    qrycargue.SQL.Add
      ('ce.COMNUM, DATETIME(''now'',''localtime'') FROM COMPROBANTE_ENCABEZADO ce');
    qrycargue.ExecSQL;

    qrycargue.SQL.Clear;
    qrycargue.Close;
    qrycargue.SQL.Add('INSERT INTO');
    qrycargue.SQL.Add
      ('LOG_ENCABEZADO (CODIGOLOG,COMNUM,COMFEC,COMCON,COMPERAGNO,COMPERMES,COMULTCOS,COMANU,TIPCOMID)');
    qrycargue.SQL.Add('SELECT');
    qrycargue.SQL.Add
      ('lg.CODIGOLOG, ce.COMNUM, ce.COMFEC, ce.COMCON, ce.COMPERAGNO, ce.COMPERMES, ce.COMULTCOS, ce.COMANU, ce.TIPCOMID');
    qrycargue.SQL.Add('FROM');
    qrycargue.SQL.Add('COMPROBANTE_ENCABEZADO ce, LOG_CARGUE lg');
    qrycargue.SQL.Add('WHERE');
    qrycargue.SQL.Add('ce.COMNUM = lg.COMNUM ');
    qrycargue.ExecSQL;

    qrycargue.SQL.Clear;
    qrycargue.Close;
    qrycargue.SQL.Add('INSERT INTO');
    qrycargue.SQL.Add
      ('LOG_DETALLE (CODIGOLOG,COMNUM,COMCONS,TIPCOMID,PLACUECOD,COMTIPOMOV,COMVAL,COMNITDET,COMVALRET,COMCONDET,CENCOSID,COMDOCSOP)');
    qrycargue.SQL.Add('SELECT');
    qrycargue.SQL.Add
      ('lg.CODIGOLOG, le.COMNUM, cd.COMCONS, cd.TIPCOMID, cd.PLACUECOD, cd.COMTIPOMOV, cd.COMVAL, cd.COMNITDET, cd.COMVALRET, cd.COMCONDET, cd.CENCOSID, cd.COMDOCSOP');
    qrycargue.SQL.Add('FROM');
    qrycargue.SQL.Add
      ('COMPROBANTE_DETALLE cd, LOG_CARGUE lg, LOG_ENCABEZADO le');
    qrycargue.SQL.Add('WHERE');
    qrycargue.SQL.Add('le.COMNUM = lg.COMNUM ');
    qrycargue.SQL.Add('AND');
    qrycargue.SQL.Add('cd.COMNUM = lg.COMNUM ');
    qrycargue.ExecSQL;
    qrycargue.Free;

    Application.MessageBox('Se han procesado los datos', 'Información',
      MB_OK + MB_ICONINFORMATION);
    pbProgreso.Position := 0;
  end;

end;

procedure TfmPrincipal.sbtnDetallesClick(Sender: TObject);
var
  odCargarDetalles: TOpenDialog;
  sListaEncabezado, sListaColumna, sListaErrores: TStringList;
  sNombreArchivo: String;
  I, ivalidador: Integer;
  qrysecundario: TFDQuery;
begin
  odCargarDetalles := TOpenDialog.Create(Application);
  odCargarDetalles.Filter := 'Tipo de formato csv|*.csv';
  if odCargarDetalles.Execute then
  begin
    sListaEncabezado := TStringList.Create;
    sListaColumna := TStringList.Create;
    sListaErrores := TStringList.Create;
    qrysecundario := TFDQuery.Create(nil);
    qrysecundario.Connection := udbModulo.dbModulo.fdConexion;;
    sListaEncabezado.Clear;
    sListaColumna.Clear;
    sListaErrores.Clear;
    qrysecundario.Close;
    qrysecundario.SQL.Add('DELETE FROM COMPROBANTE_DETALLE');
    qrysecundario.ExecSQL;
    sNombreArchivo := odCargarDetalles.FileName;
    sListaEncabezado.LoadFromFile(sNombreArchivo, TEncoding.UTF8);
    ivalidador := 0;
    sListaCodDetalles.Clear;
    // Limpiamos el memo de errores
    mErrores.Clear;
    iNumDetalles := sListaEncabezado.Count;
    // Se crearon las variables iNumDetalles y iNumEncabezados publicas para poder
    // sumarlas y tener el total de veces que se realizara el proceso del web service
    // de esta manera poderle poner un Max a la barra de progreso que ira aumentando con
    // cada ciclo hasta llegar a ese max, restamos 2 ya que es el encabezado de cada documento
    iProcesos := iNumEncabezados + iNumDetalles - 2;
    pbProgreso.Max := iProcesos;
    // Recorremos la lista de datos del csv de detalles
    for I := 0 to iNumDetalles - 1 do
    begin
      ExtractStrings([';'], [], Pchar(sListaEncabezado[I]), sListaColumna);
      sListaColumna.Text := UpperCase(sListaColumna.Text);
      // Validamos una sola vez los encabezados del archivo
      validadorDetallesCSV(sListaEncabezado, sListaColumna, sListaErrores, I,
        qrysecundario, ivalidador, sListaCodDetalles);
      sListaColumna.Clear;
    end;
    if ivalidador = 0 then
    begin
      sListaCodDetalles.Sort; // ordenamos la lista de códigos
      // Validamos si los códigos del archivo detalle cumplen con la cantidad de códigos
      // Que dice el archivo encabezado
      if validarCodigos(sListaCodEncabezado, sListaCodDetalles) then
      begin
        qrDetalles.Close;
        qrDetalles.Open;
        sbtnDetalles.Enabled := False;
        sbtnCargarService.Enabled := True;
        Application.MessageBox('Se ha importado el archivo correctamente',
          'Información', MB_OK + MB_ICONINFORMATION);
      end
      else
      begin
        Application.MessageBox
          ('La cantidad de códigos no coinciden entre los dos archivos',
          'Error', MB_OK + MB_ICONERROR);

      end;
    end
    else
    begin
      mErrores.Lines.Add(sListaErrores.Text);
      Application.MessageBox('Error al cargar el archivo', 'Error',
        MB_OK + MB_ICONINFORMATION);
      sbtnCargarService.Enabled := False;
      qrDetalles.Close;
      qrDetalles.Open;
    end;
    sListaEncabezado.Free;
    sListaColumna.Free;
    sListaErrores.Free;
    odCargarDetalles.Free;
    qrysecundario.Free;
  end
  else
  begin
    Application.MessageBox('No se cargó ningún archivo', 'Información',
      MB_OK + MB_ICONINFORMATION);
  end;
end;

procedure TfmPrincipal.sbtnEncabezadoClick(Sender: TObject);
var
  qryprincipal: TFDQuery;
  odCargarEncabezado: TOpenDialog;
  sListaEncabezado, sListaColumna, sListaErrores: TStringList;
  sNombreArchivo: String;
  I, ivalidador: Integer;
begin
  odCargarEncabezado := TOpenDialog.Create(Application);
  odCargarEncabezado.Filter := 'Tipo de formato csv|*.csv';
  if odCargarEncabezado.Execute then
  begin
    qryprincipal := TFDQuery.Create(nil);
    qryprincipal.Connection := udbModulo.dbModulo.fdConexion;;
    sListaEncabezado := TStringList.Create;
    sListaColumna := TStringList.Create;
    sListaErrores := TStringList.Create;
    sListaEncabezado.Clear;
    sListaColumna.Clear;
    sListaErrores.Clear;
    qryprincipal.Close;
    qryprincipal.SQL.Add('DELETE FROM COMPROBANTE_ENCABEZADO');
    qryprincipal.ExecSQL;
    sNombreArchivo := odCargarEncabezado.FileName;
    // Se carga la ruta del archivo
    sListaEncabezado.LoadFromFile(sNombreArchivo, TEncoding.UTF8);
    // Se carga el archivo csv a la Lista
    // Recorremos la lista completo para hacer las validaciones, extraemos cada fila del archivo en sListaColumna mediante su posición
    ivalidador := 0;
    sListaCodEncabezado.Clear;
    // Limpiamos el memo de errores
    mErrores.Clear;
    iNumEncabezados := sListaEncabezado.Count;
    for I := 0 to iNumEncabezados - 1 do
    begin
      ExtractStrings([';'], [], Pchar(sListaEncabezado[I]), sListaColumna);
      // Validamos una sola vez los encabezados del archivo
      validarEncabezadoCSV(sListaEncabezado, sListaColumna, sListaErrores, I,
        qryprincipal, ivalidador, sListaCodEncabezado);
      sListaColumna.Clear;
    end;
    if ivalidador = 0 then
    begin
      qrEncabezado.Close;
      qrEncabezado.Open;
      sbtnDetalles.Enabled := True;
      sbtnCargarService.Enabled := False;
      Application.MessageBox('Se ha importado el archivo correctamente',
        'Información', MB_OK + MB_ICONINFORMATION);
      sListaCodEncabezado.Sort;
      sListaCodDetalles.Sort;

    end
    else
    begin
      mErrores.Lines.Add(sListaErrores.Text);
      Application.MessageBox('Error al cargar el archivo', 'Error',
        MB_OK + MB_ICONINFORMATION);
      qrEncabezado.Close;
      qrEncabezado.Open;
    end;
    sListaEncabezado.Free;
    sListaColumna.Free;
    sListaErrores.Free;
    odCargarEncabezado.Free;
    qryprincipal.Free;
  end
  else
  begin
    Application.MessageBox('No se cargó ningún archivo', 'Información',
      MB_OK + MB_ICONINFORMATION);
  end;

end;

end.
