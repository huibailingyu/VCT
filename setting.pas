unit setting;

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, StdCtrls, ExtCtrls, Buttons,
  FileCtrl, Controls, inifiles;

type
  TForm2 = class(TForm)
    LabeledEdit1: TLabeledEdit;
    SpeedButton1: TSpeedButton;
    RadioGroup1: TRadioGroup;
    CheckBox1: TCheckBox;
    ComboBox1: TComboBox;
    CheckBox2: TCheckBox;
    BitBtn1: TBitBtn;
    procedure SpeedButton1Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

uses main;

{$R *.dfm}

procedure TForm2.BitBtn1Click(Sender: TObject);
var
  ini_filename, m : string;
  ini_file: TInifile;
begin
  if (LabeledEdit1.Text <> Form1.outfolder) OR
     (RadioGroup1.Items[RadioGroup1.ItemIndex] <> Form1.extension) OR
     (CheckBox1.Checked) OR
     (CheckBox2.Checked) then
  begin
    if NOT DirectoryExists(LabeledEdit1.Text) then
      SpeedButton1Click(Self);
    Form1.outfolder := LabeledEdit1.Text;
    Form1.extension := RadioGroup1.Items[RadioGroup1.ItemIndex];
    Form1.use_segment_mode := CheckBox1.Checked;
    if Form1.use_segment_mode then
      m := '1'
    else
      m := '0';

    ini_filename := ExtractFilePath(paramstr(0)) + 'setting.ini';
    ini_file := TInifile.Create(ini_filename);
    ini_file.WriteString('setting', 'outfolder', Form1.outfolder);
    ini_file.WriteString('setting', 'extension', Form1.extension);
    ini_file.WriteString('setting', 'use_segment_mode', m);
    ini_file.Free;
  end;
  Form2.Hide;
end;

procedure TForm2.FormShow(Sender: TObject);
var
  i : integer;
begin
  LabeledEdit1.Text := Form1.outfolder;
  for i := 0 to RadioGroup1.Items.Count - 1 do
    if RadioGroup1.Items[i] = Form1.extension then
    begin
      RadioGroup1.ItemIndex := i;
      break;
    end;
  CheckBox1.Checked := Form1.use_segment_mode;
end;

procedure TForm2.SpeedButton1Click(Sender: TObject);
var
  Root, Caption, Directory:String;
begin
  Root := '';
  Caption := 'Please Select Output Folder:';
  Directory := LabeledEdit1.Text;
  if SelectDirectory(Caption, Root, Directory) then
  begin
    if Directory <> '' then
    begin
      if Directory[Length(Directory)] <> '\' then
        Directory := Directory + '\';
      LabeledEdit1.Text := Directory;
    end
    else
      Application.MessageBox('Do not select folder', 'System Information', MB_OK + MB_ICONERROR);
  end;
end;

end.
