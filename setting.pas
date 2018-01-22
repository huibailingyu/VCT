unit setting;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, FileCtrl, main;

type
  TForm2 = class(TForm)
    LabeledEdit1: TLabeledEdit;
    SpeedButton1: TSpeedButton;
    RadioGroup1: TRadioGroup;
    CheckBox1: TCheckBox;
    ComboBox1: TComboBox;
    CheckBox2: TCheckBox;
    OpenDialog1: TOpenDialog;
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

{$R *.dfm}

procedure TForm2.BitBtn1Click(Sender: TObject);
begin
  if (LabeledEdit1.Text <> Form1.outfolder) OR
     (RadioGroup1.Items[RadioGroup1.ItemIndex] <> Form1.extension) OR
     (CheckBox1.Checked) OR
     (CheckBox2.Checked) then
  begin
    Form1.outfolder := LabeledEdit1.Text;
    Form1.extension := RadioGroup1.Items[RadioGroup1.ItemIndex];
    Form1.use_segment_mode := CheckBox1.Checked;
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

end;

procedure TForm2.SpeedButton1Click(Sender: TObject);
var
  Root, Caption, Directory:String;
begin
  Root := '';
  Caption := 'Please Select Output Folder:';
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
