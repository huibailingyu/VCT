program vct;

uses
  Forms,
  main in 'main.pas' {Form1},
  utils in 'utils.pas',
  setting in 'setting.pas' {Form2},
  yuv in 'yuv.pas' {Form3},
  info in 'info.pas' {Form4},
  mbdata in 'mbdata.pas' {Form5},
  video1 in 'video1.pas' {Form6},
  video2 in 'video2.pas' {Form7};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TForm4, Form4);
  Application.CreateForm(TForm5, Form5);
  Application.CreateForm(TForm6, Form6);
  Application.CreateForm(TForm7, Form7);
  Application.Run;
end.
