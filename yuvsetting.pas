unit yuvsetting;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Mask;

type
  TForm3 = class(TForm)
    ComboBox1: TComboBox;
    Label1: TLabel;
    Button1: TButton;
    MaskEdit1: TMaskEdit;
    Label2: TLabel;
    Label3: TLabel;
    MaskEdit2: TMaskEdit;
    Label4: TLabel;
    MaskEdit3: TMaskEdit;
    Label5: TLabel;
    MaskEdit4: TMaskEdit;
    procedure Button1Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MaskEdit2Change(Sender: TObject);
    procedure MaskEdit3Change(Sender: TObject);
    procedure MaskEdit4Change(Sender: TObject);
    procedure MaskEdit1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    width : array [0..2] of Integer;
    height : array [0..2] of Integer;
    stride : array [0..2] of Integer;
    pix_fmt : Integer;
    ysize : integer;
    uvsize: integer;
    framesize : integer;
    procedure guess_height;
    procedure calculate_value(linesize0, linesize1 : integer);
  end;

var
  Form3: TForm3;

implementation

uses utils;

{$R *.dfm}
procedure TForm3.calculate_value(linesize0, linesize1 : integer);
begin
  stride[0] := linesize0;
  if pix_fmt = YUV420p then begin
    width[1] := width[0] div 2;
    height[1] := height[0] div 2;
    stride[1] := linesize1;
  end
  else if pix_fmt = YUV400p then begin
    width[1] := 0;
    height[1] := 0;
    stride[1] := 0;
  end
  else if pix_fmt = NV12 then begin
    width[1] := width[0];
    height[1] := height[0] div 2;
    stride[1] := linesize1;
  end
  else if pix_fmt = YUV444p then  begin
    width[1] := width[0];
    height[1] := height[0];
    stride[1] := linesize1;
  end
  else begin
    width[1] := width[0] div 2;
    height[1] := height[0] div 2;
    stride[1] := linesize1;
  end;

  width[2] := width[1];
  height[2] := height[1];
  stride[2] := stride[1];
end;

procedure TForm3.guess_height;
var
  i : integer;
  //pair : array[0..4, 0..1] of integer = ((176, 144), (352, 288), (720, 576), (1920, 1080), (2048, 1024));
begin
  height[0] := 0;
  //for I := 0 to 4 do
  //  if width = pair[i,0] then
  //    height := pair[i,1];
  if height[0] = 0 then
    height[0] := width[0];
end;

procedure TForm3.Button1Click(Sender: TObject);
begin
  try
    width[0]  := StrToInt(Trim(MaskEdit1.Text));
    height[0] := StrToInt(Trim(MaskEdit2.Text));
    stride[0] := StrToInt(Trim(MaskEdit3.Text));
    stride[1] := StrToInt(Trim(MaskEdit4.Text));
    calculate_value(stride[0], stride[1]);
  finally

  end;
  ysize := height[0] * stride[0];
  uvsize := height[1] * stride[1];
  framesize := ysize + uvsize + uvsize;
  caption := IntToStr(width[0]) + 'x' + IntToStr(height[0]) + '  ' + IntToStr(stride[0]) + 'x' + IntToStr(stride[1])
end;

procedure TForm3.ComboBox1Change(Sender: TObject);
begin
    pix_fmt := ComboBox1.ItemIndex;
    calculate_value(width[0], width[0] div 2);
    MaskEdit3.Text := IntToStr(stride[0]);
    MaskEdit4.Text := IntToStr(stride[1]);
end;

procedure TForm3.FormCreate(Sender: TObject);
begin
  width[0] := 720;
  height[0] := 360;
  calculate_value(width[0], width[0] div 2);
  pix_fmt := YUV420p;
end;

procedure TForm3.FormShow(Sender: TObject);
begin
  ComboBox1.ItemIndex := pix_fmt;
  MaskEdit1.Text := IntToSTr(width[0]);
  MaskEdit2.Text := IntToSTr(height[0]);
  MaskEdit3.Text := IntToStr(stride[0]);
  MaskEdit4.Text := IntToStr(stride[1]);
end;

procedure TForm3.MaskEdit1Change(Sender: TObject);
begin
  try
    if Trim(MaskEdit1.Text) <> '' then begin
      width[0] := StrToInt(Trim(MaskEdit1.Text));
      guess_height;
      MaskEdit2.Text := IntToStr(height[0]);
      calculate_value(width[0], width[0] div 2);
      MaskEdit3.Text := IntToStr(stride[0]);
      MaskEdit4.Text := IntToStr(stride[1]);
    end;
  finally
  end;
end;

procedure TForm3.MaskEdit2Change(Sender: TObject);
begin
  if Trim(MaskEdit2.Text) <> '' then
    height[0] := StrToInt(Trim(MaskEdit2.Text));
end;

procedure TForm3.MaskEdit3Change(Sender: TObject);
begin
  if Trim(MaskEdit3.Text) <> '' then
    stride[0] := StrToInt(Trim(MaskEdit3.Text));
end;

procedure TForm3.MaskEdit4Change(Sender: TObject);
begin
  if Trim(MaskEdit4.Text) <> '' then
    stride[1] := StrToInt(Trim(MaskEdit4.Text));
  stride[2] := stride[1];
end;

end.
