program vct;

uses
  Forms,
  main in 'main.pas' {Form1},
  utils in 'utils.pas',
  setting in 'setting.pas' {Form2},
  yuv in 'yuv.pas' {Form3};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
