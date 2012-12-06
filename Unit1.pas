//Карпушкин Александр 
// Реализовал все функции

//ВОЛОСУНОВ Михаил
//Реализовал интерфейс игры, визуализация, алгоритмы функций.

unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Menus, ComCtrls, Gauges, ImgList, jpeg;

type TMatrix=array of array of char;   //���� � �������
     TPoints=array of TPoint;
     TWords=array of string;
     TMPoints=array of TPoints;        //���������� ���� ����� - MPoints[i]

type
  TForm1 = class(TForm)
    StatusBar1: TStatusBar;
    ListBox2: TListBox;
    Image1: TImage;
    ListBox1: TListBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    procedure UndoSelection;                       //������ ������
    function CutWords(W:TWords; Str:string):TWords;  //���������� ����� ������������ �� Str
    function WordExists(var W:TWords; Str:string):boolean;  //����������� ����� � �������
    procedure FindWords(var M:TMatrix; var W:TWords; D:TWords; var MP:TMPoints; P:TPoints; x,y,xl,yl,max:integer; r:string); //����� ���� ���� ������������ � ����� Desk[x,y] (M - �����, W - ��� ��������� �����, D - ������� �������, MP - ���������� ���� ���� �� W)
    function AroundLetters(x,y:integer):boolean; //���� �� ����� �����
    procedure CreateAlphabet(x,y:integer; w,h:integer);    //�������� �������� �� Panel
    procedure PDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure P2Down(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PUP(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DestroyDesk;
    procedure CreateDesk;
    procedure DrawDesk;
    procedure NewGame;
    procedure NextStep;    //��� ���������
    function PosExists(var P:TPoints; x,y:integer):boolean; //����������� ������� x,y � P
    procedure LoadGame(FileName:string);
    procedure AddWord(Str:String; Player:byte);       //��������� �����
    procedure SetText(S1,S2:string; P,I:integer);
    procedure SetFirstWord(len:integer);              //������ ��������� ����� (������� �� ��������)
    procedure FindAllWords(var W:TWords; var MP:TMPoints; max:integer);   //����� ���� ���� ����� max �� �����
    function  FindPanelByPos(x,y:integer):TPanel;
    procedure SelectWord(var W:TWords; MP:TMPoints; index:integer);
    procedure ListBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormShow(Sender: TObject);
    procedure ListBox2DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ListBox1Click(Sender: TObject);
    procedure ListBox2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  G:TGauge;
  Dictionary,Exclusions:TWords;
  Desk:TMatrix;
  Points:TPoints;
  Coords:TPoints;
  SelPan:TPanel;
  S1,S2,maxlen,xn,yn:integer;
implementation

{$R *.dfm}

//���������� ������ ��������
procedure TForm1.CreateAlphabet(x,y:integer; w,h:integer);
const
str='������������������������������� ';
var
ind,i,j:integer;
begin
ind:=0;
for i:=0 to 1 do begin
 for j:=0 to 15 do begin
 inc(ind,1);
  with TPanel.Create(Self) do begin
   Left:=j*w+x;
   Top:=i*h+y;
   Caption:=AnsiUpperCase(str[ind]);
   //������ ������
   font.Size:=15;
   //���� ���� � ��������
   font.Color:=clwhite;
   //���� ���� ��������
   color:=clblack;
   Width:=w;
   Height:=h;
   OnMouseDown:=PDown;
   OnMouseUp:=PUP;
   Tag:=1;
   Parent:=Form1;
  end;
 end;
end;
end;

procedure TForm1.PDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 (Sender as TPanel).Color:=clred;
 (Sender as TPanel).Font.Color:=clyellow;
end;

procedure TForm1.P2Down(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
P1,P2:TPoint;
i,j:integer;
begin
 i:=((Sender as TPanel).Left-118) div 33;
 j:=((Sender as TPanel).top-30) div 33;
  if SelPan=nil then begin
   if (AroundLetters(i,j)=true) and (Desk[i,j]=' ') then begin
     SelPan:=(Sender as TPanel);
     SelPan.color:=clblue;
     xn:=i;
     yn:=j;
   end;
  end else begin
 if (Desk[i,j]<>' ') and (SelPan.Caption<>' ') then begin
  if Length(Coords)=0 then begin
     (Sender as TPanel).Color:=clred;
     SetLength(Coords,Length(Coords)+1);
     Coords[High(Coords)]:=Point(i,j);
  end else begin
     P1:=Point(i,j);
     P2:=Coords[High(Coords)];
    if ((Abs(P1.X-P2.X)=1) and (P1.Y-P2.Y=0)) or ((Abs(P1.Y-P2.Y)=1) and (P1.X-P2.X=0)) then begin
     (Sender as TPanel).Color:=clred;
     SetLength(Coords,Length(Coords)+1);
     Coords[High(Coords)]:=Point(i,j);
    end else begin
     UndoSelection;
     Desk[xn,yn]:=' ';
    end;
   end;
  end else begin
   UndoSelection;
   Desk[xn,yn]:=' ';
  end;
 end;
end;



procedure TForm1.UndoSelection;
var
i:integer;
begin
for i:=0 to High(Coords) do FindPanelByPos(33*Coords[i].X+118,33*Coords[i].Y+30).Color:=clblack;
if SelPan<>nil then begin
 SelPan.Caption:=' ';
 //���� ����� ��������� �������
 SelPan.Color:=clblack;
 SelPan:=nil;
 SetLength(Coords,0);
end;
end;

procedure TForm1.PUP(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
//���� ���� ������ ����� ���������
 (Sender as TPanel).Color:=clblack;
 //���� ������ ����� ���������
 (Sender as TPanel).Font.Color:=clwhite;
if SelPan<>nil then begin
SelPan.Caption:=AnsiLowerCase((Sender as TPanel).Caption);
Desk[xn,yn]:=SelPan.Caption[1];
end;
end;

procedure LoadDictionary;
var
l,i:integer;
begin
 AssignFile(input,'dictionary.dat');
 Reset(input);
 readln(l);
  SetLength(Dictionary,l);
  for i:=0 to l-1 do begin
   Readln(Dictionary[i]);
  end;
  CloseFile(input);
end;



procedure TForm1.LoadGame(FileName:string);
var
str,ex:string;
x,y,i,c1,c2:integer;
begin
S1:=0;
S2:=0;
 AssignFile(input,FileName);
 Reset(input);
 Listbox1.Clear;
Listbox2.Clear;
Readln(ex);
 Readln(c1);
 for i:=0 to c1-1 do begin
  Readln(str);
  AddWord(Str,0);
 end;
  Readln(c2);
 for i:=0 to c2-1 do begin
  Readln(str);
  AddWord(Str,1);
 end;
 SetLength(Desk,5,5);
 for y:=0 to High(Desk) do begin
  for x:=0 to High(Desk) do begin
    Readln(Desk[x,y]);
  end;
 end;
 CloseFile(input);
 DestroyDesk;
 CreateDesk;
 SelPan:=nil;
 SetLength(Exclusions,Length(Exclusions)+1);
 Exclusions[High(Exclusions)]:=ex;
 CreateAlphabet(22,240,25,25);
 SetText('���� '+inttostr(S1)+'\'+inttostr(S2),'',0,1);
 DrawDesk;
 maxlen:=4;
end;

procedure InitDesk;
var
x,y:integer;
begin
 SetLength(Desk,5,5);
 for y:=0 to High(Desk) do
  for x:=0 to High(Desk) do
  Desk[x,y]:=' ';
end;

function TForm1.WordExists(var W:TWords; Str:string):boolean;   //����� �����
var
i:integer;
begin
 for i:=0 to High(W) do begin
  if W[i]=str then begin
    Result:=true;
    exit;
  end;
 end;
Result:=false;
end;

function TForm1.PosExists(var P:TPoints; x,y:integer):boolean;   //���������� �������
var
i:integer;
begin
  for i:=0 to High(P) do begin
  if (P[i].x=x) and (P[i].y=y) then begin
   Result:=true;
   exit;
  end;
 end;
Result:=false;
end;

function ExitDesk(x,y:integer):boolean;  //����� �� ������� ����
begin
Result:=true;
 if (x>=0) and (x<=High(Desk)) and (y>=0) and (y<=High(Desk)) then Result:=false;
end;

function WordExcl(Str:string):boolean;
var
i:integer;
begin
 for i:=0 to High(Exclusions) do begin
  if Exclusions[i]=str then begin
   Result:=true;
   exit;
  end;
 end;
Result:=false;
end;

function TForm1.CutWords(W:TWords; Str:string):TWords;
var
R:TWords;
i:integer;
begin
SetLength(R,0);
for i:=0 to High(W) do begin
 if Copy(W[i],1,Length(Str))=Str then begin
  SetLength(R,Length(R)+1);
  R[High(R)]:=W[i];
 end;
end;
 Result:=R;
end;

procedure TForm1.FindWords(var M:TMatrix; var W:TWords; D:TWords; var MP:TMPoints; P:TPoints; x,y,xl,yl,max:integer; r:string); //����� ���� ���� ������������ � M[x,y] //M - ������� ����  W - ��������� �����  P - ���������� �������  x,y - ������� ����������  r - ������� �����
begin
if (length(r)>=max) or (M[x,y]=' ') or (Length(D)=0) then exit;
r:=r+M[x,y];
SetLength(P,Length(P)+1);
P[High(P)]:=Point(x,y);
 if (PosExists(P,xl,yl)=true) and (WordExcl(r)=false) and (WordExists(D,r)=true) then begin //���� ����� ���� � �������,���� ������������ ������� (xl,yl), �� ����������,  �� ���������
  SetLength(W,Length(W)+1);
  SetLength(Mp,Length(MP)+1);
  W[High(W)]:=r;
  MP[High(MP)]:=P;
  end;
D:=CutWords(D,r); //������� �������� �����
 if (ExitDesk(x-1,y)=false) and (PosExists(P,x-1,y)=false) and (M[x-1,y]<>'') then FindWords(M,W,D,MP,P,x-1,y,xl,yl,max,r);
  if (ExitDesk(x+1,y)=false) and (PosExists(P,x+1,y)=false) and (M[x+1,y]<>'') then FindWords(M,W,D,MP,P,x+1,y,xl,yl,max,r);
   if (ExitDesk(x,y-1)=false) and (PosExists(P,x,y-1)=false) and (M[x,y-1]<>'') then FindWords(M,W,D,MP,P,x,y-1,xl,yl,max,r);
    if (ExitDesk(x,y+1)=false) and (PosExists(P,x,y+1)=false) and (M[x,y+1]<>'') then FindWords(M,W,D,MP,P,x,y+1,xl,yl,max,r);
end;

function GetBetterWord(var W:TWords):integer;
var
i,j,best:integer;
R:TWords;
begin
Randomize;
SetLength(R,0);
best:=1;
 for i:=0 to High(W) do begin
  if Length(W[i])>best then begin
   best:=Length(W[i]);
  end;
 end;
 for i:=0 to High(W) do begin
  if Length(W[i])=best then begin
   SetLength(R,Length(R)+1);
   R[High(R)]:=W[i];
  end;
 end;
if Length(R)=0 then begin
 Result:=-1;
 exit;
end;
 j:=Random(Length(R));
 for i:=0 to High(W) do begin
  if R[j]=W[i] then begin
   Result:=i;
   exit;
  end;
 end;
end;

function TForm1.AroundLetters(x,y:integer):boolean;
begin
 if ((ExitDesk(x+1,y)=false) and (Desk[x+1,y]<>' ')) or
    ((ExitDesk(x-1,y)=false) and (Desk[x-1,y]<>' ')) or
    ((ExitDesk(x,y+1)=false) and (Desk[x,y+1]<>' ')) or
    ((ExitDesk(x,y-1)=false) and (Desk[x,y-1]<>' ')) then Result:=true else Result:=false;
end;

function MaxVal:integer;
var
x,y,s:integer;
begin
s:=0;
 for y:=0 to High(Desk) do
  for x:=0 to High(Desk) do
   if (Desk[x,y]=' ') and (Form1.AroundLetters(x,y)=true) then s:=s+1;
 Result:=s;
end;

procedure TForm1.FindAllWords(var W:TWords; var MP:TMPoints; max:integer);
var
r:string;
i:char;
x,y,m,n:integer;
P:TPoints;
begin
SetLength(P,0);
SetLength(MP,0);
SetLength(W,0);
G.MaxValue:=MaxVal;
G.Visible:=true;
for y:=0 to High(Desk) do begin
 for x:=0 to High(Desk) do begin
  if (Desk[x,y]=' ') and (AroundLetters(x,y)=true) then begin //����� ���������� �������
  G.Progress:=G.Progress+1;
   for i:='�' to '�' do begin  //���������� ��� ����� �� ���� ������� � ���� ��� ����� � ������� �����
    Desk[x,y]:=i;
    for m:=0 to High(Desk) do begin
     for n:=0 to High(Desk) do begin
      if (Desk[n,m]<>' ') then FindWords(Desk,W,Dictionary,MP,P,n,m,x,y,max,r);
     end;
    end;
    Desk[x,y]:=' ';
   end;
  end;
 end;
end;
G.Progress:=0;
G.Visible:=false;
end;

procedure TForm1.CreateDesk;
var
x,y:integer;
begin
 for y:=0 to High(Desk) do begin
  for x:=0 to High(Desk) do begin
   with TPanel.Create(self) do begin
    Name:='P'+inttostr(5*y+x);
    Caption:=' ';
    Width:=33;
    Height:=33;
    Left:=118+x*33;
    Top:=30+y*33;
    //������ ���� �������
    Font.Size:=15;
    //���� ���� �������
    Font.Color:=clwhite;
    OnMouseDown:=P2Down;
    //���� �������
    Color:=clblack;
    Parent:=Form1;
   end;
  end;
 end;
end;

procedure TForm1.DestroyDesk;    //��������� ��� ������
var
flag:boolean;
i:integer;
begin
repeat
flag:=true;
 for i:=0 to ComponentCount-1 do begin
  if (Components[i] is TPanel) then begin
   TPanel(Components[i]).Free;
   flag:=false;
   break;
  end;
 end;
until flag=true;
end;

procedure TForm1.DrawDesk;
var
x,y:integer;
begin
 for y:=0 to High(Desk) do begin
  for x:=0 to High(Desk) do begin
   TPanel(FindComponent('P'+inttostr(5*y+x))).Caption:=Desk[x,y];
  end;
 end;
end;

function TForm1.FindPanelByPos(x,y:integer):TPanel;
var
i:integer;
begin
 for i:=0 to ComponentCount-1 do begin
  if (TPanel(Components[i]).left=x) and (TPanel(Components[i]).top=y) then begin
   Result:=TPanel(Components[i]);
   exit;
  end;
 end;
 Result:=nil;
end;

procedure TForm1.SelectWord(var W:TWords; MP:TMPoints; index:integer);
var
P:TPanel;
i:integer;
begin
for i:=0 to High(MP[index]) do begin  //����� ������ � ������������ 33*MP[index][i].X+118,33*MP[index][i].Y+30 � �������� �� ������
 P:=FindPanelByPos(33*MP[index][i].X+118,33*MP[index][i].Y+30);
 P.Color:=clred;
 P.Caption:=W[index][i+1];
 Desk[MP[index][i].X,MP[index][i].Y]:=W[index][i+1];
 sleep(150);
 application.ProcessMessages;
end;
 sleep(500);
 application.ProcessMessages;
 for i:=0 to High(MP[index]) do begin //����� �������
  P:=FindPanelByPos(33*MP[index][i].X+118,33*MP[index][i].Y+30);
  //
  P.Color:=clblack;//silver;
 end;
end;

procedure TForm1.NewGame;
begin
S1:=0;
S2:=0;
SelPan:=nil;
 Listbox1.Clear;
 Listbox2.Clear;
maxlen:=4;
G.Free;
G:=TGauge.Create(Self);
 with G do begin
  Left:=55;
  top:=4;
  Width:=Statusbar1.Panels[0].Width-56;
  height:=StatusBar1.Height - Top-1;
  ForeColor:=clblue;
  Visible:=false;
  Parent:=Statusbar1;
 end;

 SetText('���� 0\0','',0,1);
 LoadDictionary;
 InitDesk;
 DestroyDesk;
 CreateDesk;
 CreateAlphabet(8,230,24,24);
 SetFirstWord(5);
 DrawDesk;

end;

procedure TForm1.AddWord(Str:String; Player:byte);
begin
 case Player of
 0: begin
     Listbox1.items.add(' '+Str+'   '+inttostr(Length(Str)));
     S1:=S1+Length(Str);
    end;
 1: begin
     Listbox2.items.add(' '+Str+'   '+inttostr(Length(Str)));
     S2:=S2+Length(Str);
    end;
 end;
  SetLength(Exclusions,Length(Exclusions)+1);
  Exclusions[High(Exclusions)]:=Str;
end;

procedure TForm1.SetFirstWord(len:integer);   //��������� ������� ����� ����� len
var
i,j:integer;
R:TWords;
begin
Randomize;
 for i:=0 to High(Dictionary) do begin   //�������� ����� ����� len
  if Length(Dictionary[i])=len then begin  //� ������� � ������
   SetLength(R,Length(R)+1);
   R[High(R)]:=Dictionary[i];
  end;
 end;
 j:=Random(Length(R));        //�������� ��������� ����� �� ���������
 for i:=0 to High(Desk) do    // � ����� ��� �� �����
  Desk[i,2]:=R[j][i+1];
 SetLength(Exclusions,Length(Exclusions)+1); //������� � ����������
 Exclusions[High(Exclusions)]:=R[j];
end;

procedure TForm1.SetText(S1,S2:string; P,I:integer); //������� ����� S1, � ����� ����� ����� P ����� S2 � Satusbar.panels[i]
begin
 StatusBar1.Panels[I].text:=S1;
 Application.ProcessMessages;
 if P<>0 then begin
  Sleep(P);
  StatusBar1.Panels[I].text:=S2;
  Application.ProcessMessages;
 end;
end;

procedure TForm1.NextStep;
var
MP:TMPoints;       //���������� ���� �����
W:TWords;          //��������� �����
i:integer;         //������ ���������� ���������� �����
begin
SetText('�����...','',0,0);
 FindAllWords(W,MP,maxlen);  //����� ���� ����
 i:=GetBetterWord(W);        //������� ����� ����������
if i<>-1 then begin          //���� ��� ����������, ��
SetText('�����.','',0,0);
  SelectWord(W,MP,i);        //���������� ���
  AddWord(W[i],0);           //��������� � Listbox1 ����� W[i]
 SetText('��� ���.','',0,0);
 SetText('���� '+inttostr(S2)+'\'+inttostr(S1),'',0,1);
end else SetText('�� ����.','��� ���.',1500,0);
end;


procedure TForm1.ListBox1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
With ( Control As TListBox ).Canvas Do Begin
Font.Color:=clyellow;
FillRect(Rect);
TextOut(Rect.Left, Rect.Top, ( Control As TListBox ).Items[Index]+'                                                                                                   ');
end;
( Control As TListBox ).Canvas.Refresh;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
NewGame;
end;

procedure TForm1.ListBox2DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
With ( Control As TListBox ).Canvas Do Begin
 Font.Color:=clyellow;
FillRect(Rect);
TextOut(Rect.Left, Rect.Top, ( Control As TListBox ).Items[Index]+'                                                                                                   ');
end;
( Control As TListBox ).Canvas.Refresh;
end;

procedure TForm1.ListBox1Click(Sender: TObject);
begin
Listbox2.ItemIndex:=Listbox1.ItemIndex;
end;

procedure TForm1.ListBox2Click(Sender: TObject);
begin
Listbox1.ItemIndex:=Listbox2.ItemIndex;
end;


procedure TForm1.Button1Click(Sender: TObject);
begin
NewGame;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
UndoSelection;
NextStep;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
i:integer;
w1,p,w2:boolean;
r,m:string;
begin
 if (Length(Coords)>0) then begin
  for i:=0 to High(Coords) do r:=r+Desk[Coords[i].x,Coords[i].y];
  w1:=WordExists(Dictionary,r);
  p:=PosExists(Coords,xn,yn);
  w2:=WordExcl(r);
  if (w1=true) and (p=true) and (w2=false) then begin
     AddWord(r,1)
  end else begin
   if w1=false then Showmessage('�� ���� ������ �����.') else
   if p=false then Showmessage('������������ ����.')     else
   if w2=true then Showmessage('��� ����� ���� ��� ������������.');
   Desk[xn,yn]:=' ';
   UndoSelection;
   DrawDesk;
   exit;
  end;
  UndoSelection;
  DrawDesk;
  application.ProcessMessages;
  sleep(200);
  NextStep;
 end;

end;




end.
