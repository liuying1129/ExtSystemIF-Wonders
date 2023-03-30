unit UfrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, DB, DBAccess, Uni, MemDS, Grids, DBGrids,
  Buttons,OracleUniProvider, ADODB,IniFiles,StrUtils, VirtualTable,
  ActnList, DosMove;

type
  TfrmMain = class(TForm)
    UniConnection1: TUniConnection;
    Panel1: TPanel;
    LabeledEdit1: TLabeledEdit;
    ADOConnection1: TADOConnection;
    SpeedButton1: TSpeedButton;
    GroupBox1: TGroupBox;
    DataSource1: TDataSource;
    VirtualTable1: TVirtualTable;
    Panel3: TPanel;
    LabeledEdit2: TLabeledEdit;
    LabeledEdit3: TLabeledEdit;
    LabeledEdit4: TLabeledEdit;
    LabeledEdit7: TLabeledEdit;
    Edit2: TEdit;
    Panel4: TPanel;
    DBGrid1: TDBGrid;
    BitBtn1: TBitBtn;
    Label1: TLabel;
    ActionList1: TActionList;
    Action1: TAction;
    CheckBox1: TCheckBox;
    DosMove1: TDosMove;
    RadioGroup1: TRadioGroup;
    LabeledEdit5: TLabeledEdit;
    LabeledEdit6: TLabeledEdit;
    LabeledEdit9: TLabeledEdit;
    Memo1: TMemo;
    procedure LabeledEdit1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure VirtualTable1AfterOpen(DataSet: TDataSet);
    procedure BitBtn1Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    function MakeAdoDBConn:boolean;
    function MakeUniDBConn:boolean;
    procedure SingleRequestForm2Lis(const WorkGroup,His_Unid,patientname,sex,age,age_unit,deptname,check_doctor,RequestDate:String;const ABarcode,Surem1,checkid,SampleType,pkcombin_id,His_MzOrZy:String);
  public
    { Public declarations }
  end;

const
  OrgCode='80441041';

var
  frmMain: TfrmMain;

implementation

uses superobject, UfrmRequestInfo;

{$R *.dfm}

procedure RequestForm2Lis(const AAdoconnstr,ARequestJSON,CurrentWorkGroup:PChar);stdcall;external 'Request2Lis.dll';
function UnicodeToChinese(const AUnicodeStr:PChar):PChar;stdcall;external 'LYFunction.dll';
procedure WriteLog(const ALogStr: Pchar);stdcall;external 'LYFunction.dll';
function DeCryptStr(aStr: Pchar; aKey: Pchar): Pchar;stdcall;external 'LYFunction.dll';//����
function ShowOptionForm(const pCaption,pTabSheetCaption,pItemInfo,pInifile:Pchar):boolean;stdcall;external 'OptionSetForm.dll';
function GetMaxCheckID(const AWorkGroup,APreDate,APreCheckID:PChar):PChar;stdcall;external 'LYFunction.dll';

const
  CryptStr='lc';
  
procedure TfrmMain.LabeledEdit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  ADOTemp22:TADOQuery;

  i:Integer;

  VTTemp:TVirtualTable;

  ini:TIniFile;

  PreWorkGroup:String;//�ñ�������:�����湤�����һ����¼��������

  PreDate,PreCheckID:String;

  UniStoredProc1,UniStoredProc2:TUniStoredProc;
begin
  if key<>13 then exit;

  if trim((Sender as TLabeledEdit).Text)='' then exit;

  PreWorkGroup:='��һ��������';//��ʼ��Ϊʵ����������ܳ��ֵĹ��������Ƽ���

  (Sender as TLabeledEdit).Enabled:=false;//Ϊ�˷�ֹû��������ɨ����һ������

  UniStoredProc1:=TUniStoredProc.Create(nil);
  UniStoredProc1.Connection:=UniConnection1;
  UniStoredProc1.Close;
  UniStoredProc1.Params.Clear;
  UniStoredProc1.StoredProcName:='usp_yjjk_getbrxx';//ͨ�����סԺ�Ż򿨺Ż�ȡ������Ϣ
  UniStoredProc1.Params.Add;
  UniStoredProc1.Params[0].Name:='orgcode';
  UniStoredProc1.Params[0].DataType:=ftString;
  UniStoredProc1.Params[0].ParamType:=ptInput;
  UniStoredProc1.ParamByName('orgcode').Value:=OrgCode;

  UniStoredProc1.Params.Add;
  UniStoredProc1.Params[1].Name:='brlb';
  UniStoredProc1.Params[1].DataType:=ftstring;
  UniStoredProc1.Params[1].ParamType:=ptinput;
  UniStoredProc1.ParamByName('brlb').Value:=RadioGroup1.ItemIndex;

  UniStoredProc1.Params.Add;
  UniStoredProc1.Params[2].Name:='codetype';
  UniStoredProc1.Params[2].DataType:=ftstring;
  UniStoredProc1.Params[2].ParamType:=ptinput;
  UniStoredProc1.ParamByName('codetype').Value:=ifThen(RadioGroup1.ItemIndex=0,'2','1');

  UniStoredProc1.Params.Add;
  UniStoredProc1.Params[3].Name:='code';
  UniStoredProc1.Params[3].DataType:=ftstring;
  UniStoredProc1.Params[3].ParamType:=ptinput;
  UniStoredProc1.ParamByName('code').Value:=(Sender as TLabeledEdit).Text;

  UniStoredProc1.Params.Add;
  UniStoredProc1.Params[4].Name:='result';//����
  UniStoredProc1.Params[4].DataType:=ftCursor;
  UniStoredProc1.Params[4].ParamType:=ptOutput;
  try
    UniStoredProc1.Open;
  except
    on E:Exception do
    begin
      UniStoredProc1.Free;
      (Sender as TLabeledEdit).Clear;
      (Sender as TLabeledEdit).Enabled:=true;
      if (Sender as TLabeledEdit).CanFocus then (Sender as TLabeledEdit).SetFocus;
      MessageDlg('��ȡ���˻�����Ϣ(usp_yjjk_getbrxx)ִ�г���:'+E.Message,mtError,[mbOK],0);
      exit;
    end;
  end;

  LabeledEdit2.Text:=UniStoredProc1.fieldbyname('PatName').AsString;
  LabeledEdit3.Text:=UniStoredProc1.fieldbyname('Sex').AsString;
  LabeledEdit4.Text:=UniStoredProc1.fieldbyname('Age').AsString;
  Edit2.Text:=UniStoredProc1.fieldbyname('AgeUnit').AsString;
  LabeledEdit7.Text:=(Sender as TLabeledEdit).Text;
  LabeledEdit5.Text:=UniStoredProc1.fieldbyname('CardNo').AsString;
  LabeledEdit6.Text:=UniStoredProc1.fieldbyname('PatientID').AsString;
  LabeledEdit9.Text:=UniStoredProc1.fieldbyname('WardOrReg').AsString;

  (Sender as TLabeledEdit).Clear;

  VirtualTable1.Clear;
  for i:=0 to (DBGrid1.columns.count-1) do DBGrid1.columns[i].readonly:=False;

  //ѡ������ʱ,���Ŷ�Ӧ�Ĳ��˿����ж��������¼
  while not UniStoredProc1.Eof do
  begin
    UniStoredProc2:=TUniStoredProc.Create(nil);
    UniStoredProc2.Connection:=UniConnection1;
    UniStoredProc2.Close;
    UniStoredProc2.Params.Clear;
    UniStoredProc2.StoredProcName:='usp_yjjk_getwzxxm';//��ȡ����δȷ�ϵ�ҽ��
    UniStoredProc2.Params.Add;
    UniStoredProc2.Params[0].Name:='orgcode';
    UniStoredProc2.Params[0].DataType:=ftString;
    UniStoredProc2.Params[0].ParamType:=ptInput;
    UniStoredProc2.ParamByName('orgcode').Value:=OrgCode;

    UniStoredProc2.Params.Add;
    UniStoredProc2.Params[1].Name:='brlb';
    UniStoredProc2.Params[1].DataType:=ftstring;
    UniStoredProc2.Params[1].ParamType:=ptinput;
    UniStoredProc2.ParamByName('brlb').Value:=UniStoredProc1.FieldByName('wardorreg').AsString;

    UniStoredProc2.Params.Add;
    UniStoredProc2.Params[2].Name:='patid';
    UniStoredProc2.Params[2].DataType:=ftstring;
    UniStoredProc2.Params[2].ParamType:=ptinput;
    UniStoredProc2.ParamByName('patid').Value:='';

    UniStoredProc2.Params.Add;
    UniStoredProc2.Params[3].Name:='cureno';
    UniStoredProc2.Params[3].DataType:=ftstring;
    UniStoredProc2.Params[3].ParamType:=ptinput;
    UniStoredProc2.ParamByName('cureno').Value:=UniStoredProc1.FieldByName('cureno').AsString;

    UniStoredProc2.Params.Add;
    UniStoredProc2.Params[4].Name:='times';
    UniStoredProc2.Params[4].DataType:=ftstring;
    UniStoredProc2.Params[4].ParamType:=ptInput;
    UniStoredProc2.ParamByName('times').Value:='0';

    UniStoredProc2.Params.Add;
    UniStoredProc2.Params[5].Name:='yexh';
    UniStoredProc2.Params[5].DataType:=ftstring;
    UniStoredProc2.Params[5].ParamType:=ptinput;
    UniStoredProc2.ParamByName('yexh').Value:='0';

    UniStoredProc2.Params.Add;
    UniStoredProc2.Params[6].Name:='rq1';
    UniStoredProc2.Params[6].DataType:=ftstring;
    UniStoredProc2.Params[6].ParamType:=ptinput;
    UniStoredProc2.ParamByName('rq1').Value:=FormatDateTime('YYYY-MM-DD',Date-30);

    UniStoredProc2.Params.Add;
    UniStoredProc2.Params[7].Name:='rq2';
    UniStoredProc2.Params[7].DataType:=ftstring;
    UniStoredProc2.Params[7].ParamType:=ptinput;
    UniStoredProc2.ParamByName('rq2').Value:=FormatDateTime('YYYY-MM-DD',Date);

    UniStoredProc2.Params.Add;
    UniStoredProc2.Params[8].Name:='result';//����
    UniStoredProc2.Params[8].DataType:=ftCursor;
    UniStoredProc2.Params[8].ParamType:=ptOutput;
    try
      UniStoredProc2.Open;
    except
      on E:Exception do
      begin
        UniStoredProc2.Free;
        MessageDlg('��ȡ����δȷ�ϵ�ҽ��(usp_yjjk_getwzxxm)ִ�г���:'+E.Message,mtError,[mbOK],0);

        UniStoredProc1.Next;
        continue;
      end;
    end;

    while not UniStoredProc2.Eof do
    begin
      if UniStoredProc2.FieldByName('HISXXH').AsString<>'LIS1' then begin UniStoredProc2.Next;continue;end;//��ѯ���������LISҽ��,���ĵ�ͼ���ز�DR��,HISXXH=RIS1
      
      ADOTemp22:=TADOQuery.Create(nil);
      ADOTemp22.Connection:=ADOConnection1;
      ADOTemp22.Close;
      ADOTemp22.SQL.Clear;
      ADOTemp22.SQL.Text:='select ci.Id,ci.Name,ci.dept_DfValue '+
                          'from combinitem ci,HisCombItem hci '+
                          'where ci.Unid=hci.CombUnid and hci.ExtSystemId=''HIS'' '+
                          'and hci.HisItem=:HisItem';
      ADOTemp22.Parameters.ParamByName('HisItem').Value:=UniStoredProc2.fieldbyname('ITEMCODE').AsString;
      ADOTemp22.Open;

      //LIS��û�����Ӧ����Ŀ
      if ADOTemp22.RecordCount<=0 then Memo1.Lines.Add(UniStoredProc2.fieldbyname('ITEMCODE').AsString+'��'+UniStoredProc2.fieldbyname('ITEMNAME').AsString+'����LIS��û�ж���'); 
      
      while not ADOTemp22.Eof do
      begin
        ini:=tinifile.Create(ChangeFileExt(Application.ExeName,'.ini'));
        PreDate:=ini.ReadString(ADOTemp22.FieldByName('dept_DfValue').AsString,'�������','');
        PreCheckID:=ini.ReadString(ADOTemp22.FieldByName('dept_DfValue').AsString,'������','');
        ini.Free;

        VirtualTable1.Append;
        VirtualTable1.FieldByName('�ⲿϵͳΨһ���').AsString:=UniStoredProc1.FieldByName('CureNo').AsString;
        VirtualTable1.FieldByName('�ⲿϵͳ��Ŀ������').AsString:=UniStoredProc2.FieldByName('HISAPPLYNO').AsString;
        VirtualTable1.FieldByName('�������').AsString:=UniStoredProc2.FieldByName('APPLYDEPTNAME').AsString;
        VirtualTable1.FieldByName('����ҽ��').AsString:=UniStoredProc2.FieldByName('APPLYDOCNAME').AsString;
        VirtualTable1.FieldByName('����ʱ��').AsString:=UniStoredProc2.FieldByName('APPLYTIME').AsString;
        VirtualTable1.FieldByName('HIS��Ŀ����').AsString:=UniStoredProc2.FieldByName('ITEMCODE').AsString;
        VirtualTable1.FieldByName('HIS��Ŀ����').AsString:=UniStoredProc2.FieldByName('ITEMNAME').AsString;
        VirtualTable1.FieldByName('LIS��Ŀ����').AsString:=ADOTemp22.FieldByName('Id').AsString;
        VirtualTable1.FieldByName('LIS��Ŀ����').AsString:=ADOTemp22.FieldByName('Name').AsString;
        VirtualTable1.FieldByName('������').AsString:=ADOTemp22.FieldByName('dept_DfValue').AsString;
        VirtualTable1.FieldByName('��������').AsString:=UniStoredProc2.FieldByName('SPECIMENDESC').AsString;
        VirtualTable1.FieldByName('������').AsString:=GetMaxCheckId(PChar(ADOTemp22.FieldByName('dept_DfValue').AsString),PChar(PreDate),PChar(PreCheckID));
        VirtualTable1.Post;

        ADOTemp22.Next;
      end;
      ADOTemp22.Free;

      UniStoredProc2.Next;
    end;
    UniStoredProc2.Free;

    UniStoredProc1.Next;
  end;
  UniStoredProc1.Free;

  for i:=0 to (DBGrid1.columns.count-2) do DBGrid1.columns[i].readonly:=True;//���������1��(������)�ɱ༭

  if CheckBox1.Checked then
  begin
    VTTemp:=TVirtualTable.Create(nil);
    VTTemp.Assign(VirtualTable1);//clone���ݼ�
    VTTemp.Open;
    while not VTTemp.Eof do
    begin
      SingleRequestForm2Lis(
        VTTemp.fieldbyname('������').AsString,
        VTTemp.fieldbyname('�ⲿϵͳΨһ���').AsString,
        LabeledEdit2.Text,
        LabeledEdit3.Text,
        LabeledEdit4.Text,
        Edit2.Text,
        VTTemp.fieldbyname('�������').AsString,
        VTTemp.fieldbyname('����ҽ��').AsString,
        VTTemp.fieldbyname('����ʱ��').AsString,
        LabeledEdit7.Text,
        VTTemp.fieldbyname('�ⲿϵͳ��Ŀ������').AsString,
        VTTemp.fieldbyname('������').AsString,
        VTTemp.fieldbyname('��������').AsString,
        VTTemp.fieldbyname('LIS��Ŀ����').AsString,
        LabeledEdit9.Text
      );

      //���浱ǰ������
      if (trim(VTTemp.fieldbyname('������').AsString)<>'')and(VTTemp.fieldbyname('������').AsString<>PreWorkGroup) then
      begin
        PreWorkGroup:=VTTemp.fieldbyname('������').AsString;
        ini:=tinifile.Create(ChangeFileExt(Application.ExeName,'.ini'));
        ini.WriteString(VTTemp.fieldbyname('������').AsString,'�������',FormatDateTime('YYYY-MM-DD',Date));
        ini.WriteString(VTTemp.fieldbyname('������').AsString,'������',VTTemp.fieldbyname('������').AsString);
        ini.Free;
      end;
      //==============

      VTTemp.Next;
    end;
    VTTemp.Close;
    VTTemp.Free;
  end;

  (Sender as TLabeledEdit).Enabled:=true;
  if (Sender as TLabeledEdit).CanFocus then (Sender as TLabeledEdit).SetFocus;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  MakeUniDBConn;
  MakeAdoDBConn;

  //���������VirtualTable�ֶ�
  VirtualTable1.IndexFieldNames:='������,��������';//�������顢������������
  VirtualTable1.Open;
end;

procedure TfrmMain.SpeedButton1Click(Sender: TObject);
begin
  frmRequestInfo.ShowModal;
end;

function TfrmMain.MakeAdoDBConn: boolean;
var
  newconnstr,ss: string;
  Ini: tinifile;
  userid, password, datasource, initialcatalog: string;{, provider}
  ifIntegrated:boolean;//�Ƿ񼯳ɵ�¼ģʽ

  pInStr,pDeStr:Pchar;
  i:integer;
  Label labReadIni;
begin
  result:=false;

  labReadIni:
  Ini := tinifile.Create(ChangeFileExt(Application.ExeName,'.ini'));
  datasource := Ini.ReadString('����LIS���ݿ�', '������', '');
  initialcatalog := Ini.ReadString('����LIS���ݿ�', '���ݿ�', '');
  ifIntegrated:=ini.ReadBool('����LIS���ݿ�','���ɵ�¼ģʽ',false);
  userid := Ini.ReadString('����LIS���ݿ�', '�û�', '');
  password := Ini.ReadString('����LIS���ݿ�', '����', '107DFC967CDCFAAF');
  Ini.Free;
  //======����password
  pInStr:=pchar(password);
  pDeStr:=DeCryptStr(pInStr,Pchar(CryptStr));
  setlength(password,length(pDeStr));
  for i :=1  to length(pDeStr) do password[i]:=pDeStr[i-1];
  //==========

  newconnstr :='';
  newconnstr := newconnstr + 'user id=' + UserID + ';';
  newconnstr := newconnstr + 'password=' + Password + ';';
  newconnstr := newconnstr + 'data source=' + datasource + ';';
  newconnstr := newconnstr + 'Initial Catalog=' + initialcatalog + ';';
  newconnstr := newconnstr + 'provider=' + 'SQLOLEDB.1' + ';';
  //Persist Security Info,��ʾADO�����ݿ����ӳɹ����Ƿ񱣴�������Ϣ
  //ADOȱʡΪTrue,ADO.netȱʡΪFalse
  //�����лᴫADOConnection��Ϣ��TADOLYQuery,������ΪTrue
  newconnstr := newconnstr + 'Persist Security Info=True;';
  if ifIntegrated then
    newconnstr := newconnstr + 'Integrated Security=SSPI;';
  try
    ADOConnection1.Connected := false;
    ADOConnection1.ConnectionString := newconnstr;
    ADOConnection1.Connected := true;
    result:=true;
  except
  end;
  if not result then
  begin
    ss:='������'+#2+'Edit'+#2+#2+'0'+#2+#2+#3+
        '���ݿ�'+#2+'Edit'+#2+#2+'0'+#2+#2+#3+
        '���ɵ�¼ģʽ'+#2+'CheckListBox'+#2+#2+'0'+#2+'���ø�ģʽ,���û�������������д'+#2+#3+
        '�û�'+#2+'Edit'+#2+#2+'0'+#2+#2+#3+
        '����'+#2+'Edit'+#2+#2+'0'+#2+#2+'1';
    if ShowOptionForm('����LIS���ݿ�','����LIS���ݿ�',Pchar(ss),Pchar(ChangeFileExt(Application.ExeName,'.ini'))) then
      goto labReadIni else application.Terminate;
  end;
end;

function TfrmMain.MakeUniDBConn: boolean;
var
  newconnstr,ss: string;
  Ini: tinifile;
  userid, password, datasource, provider: string;

  pInStr,pDeStr:Pchar;
  i:integer;
  Label labReadIni;
begin
  result:=false;

  labReadIni:
  Ini := tinifile.Create(ChangeFileExt(Application.ExeName,'.ini'));
  provider := Ini.ReadString('����HIS���ݿ�', '�����ṩ��', '');
  datasource := Ini.ReadString('����HIS���ݿ�', '������', '');
  userid := Ini.ReadString('����HIS���ݿ�', '�û�', '');
  password := Ini.ReadString('����HIS���ݿ�', '����', '107DFC967CDCFAAF');
  Ini.Free;
  //======����password
  pInStr:=pchar(password);
  pDeStr:=DeCryptStr(pInStr,Pchar(CryptStr));
  setlength(password,length(pDeStr));
  for i :=1  to length(pDeStr) do password[i]:=pDeStr[i-1];
  //==========

  //Provider NameΪOracleʱ,Server���Ը�ʽ:Host IP:Port:SID,��10.195.252.13:1521:kthis1
  //Oracle��Ĭ��PortΪ1521
  //��ѯOracle SID:select instance_name from V$instance;
  newconnstr :='';
  newconnstr := newconnstr + 'Provider Name=' + provider + ';';
  newconnstr := newconnstr + 'Login Prompt=False;Direct=True;';
  newconnstr := newconnstr + 'Data Source=' + datasource + ';';
  newconnstr := newconnstr + 'User ID=' + userid + ';';
  newconnstr := newconnstr + 'Password=' + password + ';';
  try
    UniConnection1.Connected := false;
    UniConnection1.ConnectString:=newconnstr;
    UniConnection1.Connect;
    result:=true;
  except
  end;
  if not result then
  begin
    ss:='�����ṩ��'+#2+'Edit'+#2+#2+'0'+#2+#2+#3+
        '������'+#2+'Edit'+#2+#2+'0'+#2+#2+#3+
        '�û�'+#2+'Edit'+#2+#2+'0'+#2+#2+#3+
        '����'+#2+'Edit'+#2+#2+'0'+#2+#2+'1';
    if ShowOptionForm('����HIS���ݿ�','����HIS���ݿ�',Pchar(ss),Pchar(ChangeFileExt(Application.ExeName,'.ini'))) then
      goto labReadIni else application.Terminate;
  end;
end;

procedure TfrmMain.VirtualTable1AfterOpen(DataSet: TDataSet);
begin
  if not DataSet.Active then exit;
   
  DBGrid1.Columns[0].Width:=30;//�ⲿϵͳΨһ���,�����˾���Ψһ��
  DBGrid1.Columns[1].Width:=30;//�ⲿϵͳ��Ŀ������
  DBGrid1.Columns[2].Width:=60;//�������
  DBGrid1.Columns[3].Width:=55;//����ҽ��
  DBGrid1.Columns[4].Width:=136;//����ʱ��
  DBGrid1.Columns[5].Width:=77;//HIS��Ŀ����
  DBGrid1.Columns[6].Width:=100;//HIS��Ŀ����
  DBGrid1.Columns[7].Width:=77;//LIS��Ŀ����
  DBGrid1.Columns[8].Width:=100;//LIS��Ŀ����
  DBGrid1.Columns[9].Width:=80;//������
  DBGrid1.Columns[10].Width:=57;//��������
  DBGrid1.Columns[11].Width:=90;//������
end;

procedure TfrmMain.BitBtn1Click(Sender: TObject);
var
  VTTemp:TVirtualTable;
  ini:TIniFile;

  PreWorkGroup:String;//�ñ�������:�����湤�����һ����¼��������
begin
  if not VirtualTable1.Active then exit;
  if VirtualTable1.RecordCount<=0 then exit;

  PreWorkGroup:='��һ��������';//��ʼ��Ϊʵ����������ܳ��ֵĹ��������Ƽ���

  LabeledEdit1.Enabled:=false;//Ϊ�˷�ֹû��������ɨ����һ������
  BitBtn1.Enabled:=false;//Ϊ�˷�ֹû�������ֵ������//������ShortCut,�ʲ���ʹ��(Sender as TBitBtn)

  VTTemp:=TVirtualTable.Create(nil);
  VTTemp.Assign(VirtualTable1);//clone���ݼ�
  VTTemp.Open;
  while not VTTemp.Eof do
  begin
    SingleRequestForm2Lis(
      VTTemp.fieldbyname('������').AsString,
      VTTemp.fieldbyname('�ⲿϵͳΨһ���').AsString,
      LabeledEdit2.Text,
      LabeledEdit3.Text,
      LabeledEdit4.Text,
      Edit2.Text,
      VTTemp.fieldbyname('�������').AsString,
      VTTemp.fieldbyname('����ҽ��').AsString,
      VTTemp.fieldbyname('����ʱ��').AsString,
      LabeledEdit7.Text,
      VTTemp.fieldbyname('�ⲿϵͳ��Ŀ������').AsString,
      VTTemp.fieldbyname('������').AsString,
      VTTemp.fieldbyname('��������').AsString,
      VTTemp.fieldbyname('LIS��Ŀ����').AsString,
      LabeledEdit9.Text
    );

    //���浱ǰ������
    if (trim(VTTemp.fieldbyname('������').AsString)<>'')and(VTTemp.fieldbyname('������').AsString<>PreWorkGroup) then
    begin
      PreWorkGroup:=VTTemp.fieldbyname('������').AsString;
      ini:=tinifile.Create(ChangeFileExt(Application.ExeName,'.ini'));
      ini.WriteString(VTTemp.fieldbyname('������').AsString,'�������',FormatDateTime('YYYY-MM-DD',Date));
      ini.WriteString(VTTemp.fieldbyname('������').AsString,'������',VTTemp.fieldbyname('������').AsString);
      ini.Free;
    end;
    //==============

    VTTemp.Next;
  end;
  VTTemp.Close;
  VTTemp.Free;

  LabeledEdit1.Enabled:=true;
  if LabeledEdit1.CanFocus then LabeledEdit1.SetFocus; 
  BitBtn1.Enabled:=true;//������ShortCut,�ʲ���ʹ��(Sender as TBitBtn)
end;

procedure TfrmMain.SingleRequestForm2Lis(const WorkGroup, His_Unid, patientname, sex,
  age, age_unit, deptname, check_doctor, RequestDate, ABarcode, Surem1,
  checkid, SampleType, pkcombin_id, His_MzOrZy: String);
var
  ObjectYZMZ:ISuperObject;
  ArrayYZMX:ISuperObject;
  ObjectJYYZ:ISuperObject;
  ArrayJYYZ:ISuperObject;
  BigObjectJYYZ:ISuperObject;
  
  UniStoredProc1:TUniStoredProc;
begin
  if trim(WorkGroup)='' then exit;
  if trim(pkcombin_id)='' then exit;

  ArrayYZMX:=SA([]);

  ObjectYZMZ:=SO;
  ObjectYZMZ.S['������'] := checkid;
  ObjectYZMZ.S['LIS�����Ŀ����'] := pkcombin_id;
  ObjectYZMZ.S['�����'] := ABarcode;
  ObjectYZMZ.S['�ⲿϵͳ��Ŀ������'] := Surem1;
  ObjectYZMZ.S['��������'] := SampleType;

  ArrayYZMX.AsArray.Add(ObjectYZMZ);
  ObjectYZMZ:=nil;

  ObjectJYYZ:=SO;
  ObjectJYYZ.S['��������']:=patientname;
  if sex='1' then ObjectJYYZ.S['�����Ա�']:='��'
    else if sex='2' then ObjectJYYZ.S['�����Ա�']:='Ů'
      else ObjectJYYZ.S['�����Ա�']:='δ֪';
  ObjectJYYZ.S['��������']:=age+age_unit;
  ObjectJYYZ.S['�������']:=deptname;
  ObjectJYYZ.S['����ҽ��']:=check_doctor;
  ObjectJYYZ.S['��������']:=RequestDate;
  ObjectJYYZ.S['�ⲿϵͳΨһ���']:=His_Unid;
  ObjectJYYZ.S['�������']:=His_MzOrZy;
  ObjectJYYZ.O['ҽ����ϸ']:=ArrayYZMX;
  ArrayYZMX:=nil;

  ArrayJYYZ:=SA([]);
  ArrayJYYZ.AsArray.Add(ObjectJYYZ);
  ObjectJYYZ:=nil;

  BigObjectJYYZ:=SO;
  BigObjectJYYZ.S['JSON����Դ']:='HIS';
  BigObjectJYYZ.O['����ҽ��']:=ArrayJYYZ;
  ArrayJYYZ:=nil;

  RequestForm2Lis(PChar(AnsiString(ADOConnection1.ConnectionString)),UnicodeToChinese(PChar(AnsiString(BigObjectJYYZ.AsJson))),'');
  BigObjectJYYZ:=nil;

  //ҽ��ȷ��ִ�в����շ���Ŀ begin
  UniStoredProc1:=TUniStoredProc.Create(nil);
  UniStoredProc1.Connection:=UniConnection1;
  UniStoredProc1.Close;
  UniStoredProc1.Params.Clear;
  UniStoredProc1.StoredProcName:='usp_yjjk_yjqr';//ҽ��ȷ��ִ�в����շ���Ŀ
  UniStoredProc1.Params.Add;
  UniStoredProc1.Params[0].Name:='orgcode';
  UniStoredProc1.Params[0].DataType:=ftString;
  UniStoredProc1.Params[0].ParamType:=ptInput;
  UniStoredProc1.ParamByName('orgcode').Value:=OrgCode;

  UniStoredProc1.Params.Add;
  UniStoredProc1.Params[1].Name:='brlb';
  UniStoredProc1.Params[1].DataType:=ftstring;
  UniStoredProc1.Params[1].ParamType:=ptinput;
  UniStoredProc1.ParamByName('brlb').Value:=His_MzOrZy;

  UniStoredProc1.Params.Add;
  UniStoredProc1.Params[2].Name:='patid';
  UniStoredProc1.Params[2].DataType:=ftstring;
  UniStoredProc1.Params[2].ParamType:=ptinput;
  UniStoredProc1.ParamByName('patid').Value:='';

  UniStoredProc1.Params.Add;
  UniStoredProc1.Params[3].Name:='curno';
  UniStoredProc1.Params[3].DataType:=ftstring;
  UniStoredProc1.Params[3].ParamType:=ptinput;
  UniStoredProc1.ParamByName('curno').Value:=His_Unid;

  UniStoredProc1.Params.Add;
  UniStoredProc1.Params[4].Name:='times';
  UniStoredProc1.Params[4].DataType:=ftstring;
  UniStoredProc1.Params[4].ParamType:=ptinput;
  UniStoredProc1.ParamByName('times').Value:='0';

  UniStoredProc1.Params.Add;
  UniStoredProc1.Params[5].Name:='yexh';
  UniStoredProc1.Params[5].DataType:=ftstring;
  UniStoredProc1.Params[5].ParamType:=ptinput;
  UniStoredProc1.ParamByName('yexh').Value:='';

  UniStoredProc1.Params.Add;
  UniStoredProc1.Params[6].Name:='zxksdm';
  UniStoredProc1.Params[6].DataType:=ftstring;
  UniStoredProc1.Params[6].ParamType:=ptinput;
  UniStoredProc1.ParamByName('zxksdm').Value:='';

  UniStoredProc1.Params.Add;
  UniStoredProc1.Params[7].Name:='zxysdm';
  UniStoredProc1.Params[7].DataType:=ftstring;
  UniStoredProc1.Params[7].ParamType:=ptinput;
  UniStoredProc1.ParamByName('zxysdm').Value:='';

  UniStoredProc1.Params.Add;
  UniStoredProc1.Params[8].Name:='logno';
  UniStoredProc1.Params[8].DataType:=ftstring;
  UniStoredProc1.Params[8].ParamType:=ptinput;
  UniStoredProc1.ParamByName('logno').Value:='LIS1';//����

  UniStoredProc1.Params.Add;
  UniStoredProc1.Params[9].Name:='applyno';
  UniStoredProc1.Params[9].DataType:=ftstring;
  UniStoredProc1.Params[9].ParamType:=ptinput;
  UniStoredProc1.ParamByName('applyno').Value:=Surem1;

  UniStoredProc1.Params.Add;
  UniStoredProc1.Params[10].Name:='groupno';
  UniStoredProc1.Params[10].DataType:=ftstring;
  UniStoredProc1.Params[10].ParamType:=ptinput;
  UniStoredProc1.ParamByName('groupno').Value:='';

  UniStoredProc1.Params.Add;
  UniStoredProc1.Params[11].Name:='xmdm';
  UniStoredProc1.Params[11].DataType:=ftstring;
  UniStoredProc1.Params[11].ParamType:=ptinput;
  UniStoredProc1.ParamByName('xmdm').Value:='';

  UniStoredProc1.Params.Add;
  UniStoredProc1.Params[12].Name:='xmdj';
  UniStoredProc1.Params[12].DataType:=ftstring;
  UniStoredProc1.Params[12].ParamType:=ptinput;
  UniStoredProc1.ParamByName('xmdj').Value:=0;

  UniStoredProc1.Params.Add;
  UniStoredProc1.Params[13].Name:='xmsl';
  UniStoredProc1.Params[13].DataType:=ftstring;
  UniStoredProc1.Params[13].ParamType:=ptinput;
  UniStoredProc1.ParamByName('xmsl').Value:=0;

  UniStoredProc1.Params.Add;
  UniStoredProc1.Params[14].Name:='xmlb';
  UniStoredProc1.Params[14].DataType:=ftstring;
  UniStoredProc1.Params[14].ParamType:=ptinput;
  UniStoredProc1.ParamByName('xmlb').Value:='';

  UniStoredProc1.Params.Add;
  UniStoredProc1.Params[15].Name:='xmstatus';
  UniStoredProc1.Params[15].DataType:=ftstring;
  UniStoredProc1.Params[15].ParamType:=ptinput;
  UniStoredProc1.ParamByName('xmstatus').Value:=1;

  UniStoredProc1.Params.Add;
  UniStoredProc1.Params[16].Name:='sfflag';
  UniStoredProc1.Params[16].DataType:=ftstring;
  UniStoredProc1.Params[16].ParamType:=ptinput;
  UniStoredProc1.ParamByName('sfflag').Value:=1;

  UniStoredProc1.Params.Add;
  UniStoredProc1.Params[17].Name:='bgdh';
  UniStoredProc1.Params[17].DataType:=ftstring;
  UniStoredProc1.Params[17].ParamType:=ptinput;
  UniStoredProc1.ParamByName('bgdh').Value:='0';

  UniStoredProc1.Params.Add;
  UniStoredProc1.Params[18].Name:='bglx';
  UniStoredProc1.Params[18].DataType:=ftstring;
  UniStoredProc1.Params[18].ParamType:=ptinput;
  UniStoredProc1.ParamByName('bglx').Value:='';

  UniStoredProc1.Params.Add;
  UniStoredProc1.Params[19].Name:='result';//����
  UniStoredProc1.Params[19].DataType:=ftCursor;
  UniStoredProc1.Params[19].ParamType:=ptOutput;
  try
    UniStoredProc1.Open;
    if UniStoredProc1.FieldByName('confirm').AsString<>'T' then
      MessageDlg('ҽ��ȷ��ִ�в����շ���Ŀʧ��:'+UniStoredProc1.FieldByName('errdesc').AsString,mtError,[mbOK],0);
  except
    on E:Exception do
    begin
      MessageDlg('ҽ��ȷ��ִ�в����շ���Ŀ(usp_yjjk_yjqr)ִ�г���:'+E.Message,mtError,[mbOK],0);
    end;
  end;

  UniStoredProc1.Free;
  //ҽ��ȷ��ִ�в����շ���Ŀ end
end;

procedure TfrmMain.CheckBox1Click(Sender: TObject);
begin
  BitBtn1.Enabled:=not (Sender as TCheckBox).Checked;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
var
  ConfigIni:tinifile;
begin
  ConfigIni:=tinifile.Create(ChangeFileExt(Application.ExeName,'.ini'));

  configini.WriteBool('Interface','ifDirect2LIS',CheckBox1.Checked);{��¼�Ƿ�ɨ���ֱ�ӵ���LIS}
  configini.WriteInteger('Interface','selBRLB',RadioGroup1.ItemIndex);{��¼��������ѡ��}

  configini.Free;
end;

procedure TfrmMain.FormShow(Sender: TObject);
var
  configini:tinifile;
begin
  CONFIGINI:=TINIFILE.Create(ChangeFileExt(Application.ExeName,'.ini'));

  CheckBox1.Checked:=configini.ReadBool('Interface','ifDirect2LIS',false);{��¼�Ƿ�ɨ���ֱ�ӵ���LIS}
  RadioGroup1.ItemIndex:=configini.ReadInteger('Interface','selBRLB',0);{��¼��������ѡ��}

  configini.Free;
  
  BitBtn1.Enabled:=not CheckBox1.Checked;
end;

end.
