    program Project1;

uses
  Forms,
  windows,
  Unit1 in 'Unit1.pas' {Form1},
  Unit2 in 'Unit2.pas' {Form2};

{$R *.res}

begin
//��������� � ���'�� �����-��������
form2:=Tform2.Create(nil);
//���������� �����-�������� �� ������
form2.Show;
//���������� �����-��������
form2.Repaint;
//������ ����� � 2 �������
sleep(3000);
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  form2.free;
  Application.Run;
end.
