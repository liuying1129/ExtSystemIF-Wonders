unit UfrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, DB, DBAccess, Uni,Inifiles, 
  Buttons,OracleUniProvider, ADODB,StrUtils,ShlObj,ActiveX,ComObj,
  CoolTrayIcon, Menus, Dialogs;

type
  TfrmMain = class(TForm)
    UniConnection1: TUniConnection;
    Panel1: TPanel;
    ADOConnection1: TADOConnection;
    Timer1: TTimer;
    Memo1: TMemo;
    LYTray1: TCoolTrayIcon;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure N3Click(Sender: TObject);
  private
    { Private declarations }
    function MakeAdoDBConn:boolean;
    function MakeUniDBConn:boolean;
    function ExecSQLCmd(AConnectionString:string;ASQL:string):integer;
  public
    { Public declarations }
  end;

const
  OrgCode='80441041';

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure RequestForm2Lis(const AAdoconnstr,ARequestJSON,CurrentWorkGroup:PChar);stdcall;external 'Request2Lis.dll';
function UnicodeToChinese(const AUnicodeStr:PChar):PChar;stdcall;external 'LYFunction.dll';
procedure WriteLog(const ALogStr: Pchar);stdcall;external 'LYFunction.dll';
function DeCryptStr(aStr: Pchar; aKey: Pchar): Pchar;stdcall;external 'LYFunction.dll';//解密
function ShowOptionForm(const pCaption,pTabSheetCaption,pItemInfo,pInifile:Pchar):boolean;stdcall;external 'OptionSetForm.dll';
function GetMaxCheckID(const AWorkGroup,APreDate,APreCheckID:PChar):PChar;stdcall;external 'LYFunction.dll';

const
  CryptStr='lc';

var  
  hnd:integer;

procedure OperateLinkFile(ExePathAndName:string; LinkFileName: widestring;
  LinkFilePos:integer;AddorDelete: boolean);
VAR
  tmpobject:IUnknown;
  tmpSLink:IShellLink;
  tmpPFile:IPersistFile;
  PIDL:PItemIDList;
  LinkFilePath:array[0..MAX_PATH]of char;
  StartupFilename:string;
begin
  case LinkFilePos of
    1:SHGetSpecialFolderLocation(0,CSIDL_BITBUCKET,pidl);
    2:SHGetSpecialFolderLocation(0,CSIDL_CONTROLS,pidl);
    3:SHGetSpecialFolderLocation(0,CSIDL_DESKTOP,pidl);
    4:SHGetSpecialFolderLocation(0,CSIDL_DESKTOPDIRECTORY,pidl);
    5:SHGetSpecialFolderLocation(0,CSIDL_DRIVES,pidl);
    6:SHGetSpecialFolderLocation(0,CSIDL_FONTS,pidl);
    7:SHGetSpecialFolderLocation(0,CSIDL_NETHOOD,pidl);
    8:SHGetSpecialFolderLocation(0,CSIDL_NETWORK,pidl);
    9:SHGetSpecialFolderLocation(0,CSIDL_PERSONAL,pidl);
    10:SHGetSpecialFolderLocation(0,CSIDL_PRINTERS,pidl);
    11:SHGetSpecialFolderLocation(0,CSIDL_PROGRAMS,pidl);
    12:SHGetSpecialFolderLocation(0,CSIDL_RECENT,pidl);
    13:SHGetSpecialFolderLocation(0,CSIDL_SENDTO,pidl);
    14:SHGetSpecialFolderLocation(0,CSIDL_STARTMENU,pidl);
    15:SHGetSpecialFolderLocation(0,CSIDL_STARTUP,pidl);
    16:SHGetSpecialFolderLocation(0,CSIDL_TEMPLATES,pidl);
  end;
  shgetpathfromidlist(pidl,LinkFilePath);
  linkfilename:=LinkFilePath+LinkFileName;
  if AddorDelete then
  begin
    if not fileexists(linkfilename) then
    begin
      startupfilename:=ExePathAndName;
      tmpobject:=createcomobject(CLSID_ShellLink);
      tmpSLink:=tmpobject as ishelllink;
      tmpPfile:=tmpobject as IPersistFile;
      tmpslink.SetPath(pchar(startupfilename));
      tmpslink.SetWorkingDirectory(pchar(extractfilepath(startupfilename)));
      tmppfile.save(pwchar(linkfilename),false);
    end;
  end else
  begin
    if fileexists(linkfilename) then deletefile(linkfilename);
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  OperateLinkFile(application.ExeName,'\'+ChangeFileExt(ExtractFileName(Application.ExeName),'.lnk'),15,true);

  lytray1.Hint:='回传检验结果服务 - 对接万达HIS';

  MakeUniDBConn;
  MakeAdoDBConn;

  Timer1.Enabled:=true;
end;

function TfrmMain.MakeAdoDBConn: boolean;
var
  newconnstr,ss: string;
  Ini: tinifile;
  userid, password, datasource, initialcatalog: string;{, provider}
  ifIntegrated:boolean;//是否集成登录模式

  pInStr,pDeStr:Pchar;
  i:integer;
  Label labReadIni;
begin
  result:=false;

  labReadIni:
  Ini := tinifile.Create(ChangeFileExt(Application.ExeName,'.ini'));
  datasource := Ini.ReadString('连接LIS数据库', '服务器', '');
  initialcatalog := Ini.ReadString('连接LIS数据库', '数据库', '');
  ifIntegrated:=ini.ReadBool('连接LIS数据库','集成登录模式',false);
  userid := Ini.ReadString('连接LIS数据库', '用户', '');
  password := Ini.ReadString('连接LIS数据库', '口令', '107DFC967CDCFAAF');
  Ini.Free;
  //======解密password
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
  //Persist Security Info,表示ADO在数据库连接成功后是否保存密码信息
  //ADO缺省为True,ADO.net缺省为False
  //程序中会传ADOConnection信息给TADOLYQuery,故设置为True
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
    ss:='服务器'+#2+'Edit'+#2+#2+'0'+#2+#2+#3+
        '数据库'+#2+'Edit'+#2+#2+'0'+#2+#2+#3+
        '集成登录模式'+#2+'CheckListBox'+#2+#2+'0'+#2+'启用该模式,则用户及口令无需填写'+#2+#3+
        '用户'+#2+'Edit'+#2+#2+'0'+#2+#2+#3+
        '口令'+#2+'Edit'+#2+#2+'0'+#2+#2+'1';
    if ShowOptionForm('连接LIS数据库','连接LIS数据库',Pchar(ss),Pchar(ChangeFileExt(Application.ExeName,'.ini'))) then
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
  provider := Ini.ReadString('连接HIS数据库', '数据提供者', '');
  datasource := Ini.ReadString('连接HIS数据库', '服务器', '');
  userid := Ini.ReadString('连接HIS数据库', '用户', '');
  password := Ini.ReadString('连接HIS数据库', '口令', '107DFC967CDCFAAF');
  Ini.Free;
  //======解密password
  pInStr:=pchar(password);
  pDeStr:=DeCryptStr(pInStr,Pchar(CryptStr));
  setlength(password,length(pDeStr));
  for i :=1  to length(pDeStr) do password[i]:=pDeStr[i-1];
  //==========

  //Provider Name为Oracle时,Server属性格式:Host IP:Port:SID,如10.195.252.13:1521:kthis1
  //Oracle的默认Port为1521
  //查询Oracle SID:select instance_name from V$instance;
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
    ss:='数据提供者'+#2+'Edit'+#2+#2+'0'+#2+#2+#3+
        '服务器'+#2+'Edit'+#2+#2+'0'+#2+#2+#3+
        '用户'+#2+'Edit'+#2+#2+'0'+#2+#2+#3+
        '口令'+#2+'Edit'+#2+#2+'0'+#2+#2+'1';
    if ShowOptionForm('连接HIS数据库','连接HIS数据库',Pchar(ss),Pchar(ChangeFileExt(Application.ExeName,'.ini'))) then
      goto labReadIni else application.Terminate;
  end;
end;

procedure TfrmMain.Timer1Timer(Sender: TObject);
var
  UniStoredProc1,UniStoredProc2:TUniStoredProc;
  ADOTemp22,ADOTemp33:TADOQuery;

  ifCompleted,i:Integer;
begin
  (Sender as TTimer).Enabled:=false;

  if length(memo1.Lines.Text)>=60000 then memo1.Lines.Clear;//memo只能接受64K个字符
  Memo1.Lines.Add(DateTimeToStr(now));//用于观测服务程序是否死掉

  ADOTemp22:=TADOQuery.Create(nil);
  ADOTemp22.Connection:=ADOConnection1;
  ADOTemp22.Close;
  ADOTemp22.SQL.Clear;
  //万达HIS扫码的检验单特征:chk_con.His_MzOrZy的值不为空(等于0或1)                                                                                                     防呆,不处理7天前审核的检验单    不处理田季导入的HIS病人
  ADOTemp22.SQL.Text:='select * from view_Chk_Con_All cc where isnull(cc.Weight,'''')='''' and isnull(cc.report_doctor,'''')<>'''' and isnull(cc.His_MzOrZy,'''')<>'''' and Audit_Date>GETDATE()-7 and isnull(TjWaiKe,'''')='''' ';
  ADOTemp22.Open;
  while not ADOTemp22.Eof do
  begin
    ifCompleted:=ADOTemp22.fieldbyname('ifCompleted').AsInteger;
    
    ADOTemp33:=TADOQuery.Create(nil);
    ADOTemp33.Connection:=ADOConnection1;
    ADOTemp33.Close;
    ADOTemp33.SQL.Clear;
    ADOTemp33.SQL.Text:='select *,'+
    	                'isnull(dbo.uf_Reference_Value_B1(cv.min_value,cv.max_value),'''')+isnull(dbo.uf_Reference_Value_B2(cv.min_value,cv.max_value),'''') as REF_RANGE,'+
                    	'case dbo.uf_ValueAlarm(cv.itemid,cv.Min_value,cv.Max_value,cv.itemvalue) when 1 then ''L'' WHEN 2 THEN ''H'' ELSE ''N'' END as RESULT_STATE_DESC '+
                      ' from '+
                      ifThen(ifCompleted=1,'chk_valu_bak','chk_valu')+
                      ' cv where cv.pkUnid='+ADOTemp22.fieldbyname('unid').AsString+
                      ' and cv.issure=1 and ltrim(rtrim(isnull(cv.itemvalue,'''')))<>'''' and isnull(cv.Surem1,'''')<>'''' ';
    ADOTemp33.Open;

    if ADOTemp33.RecordCount>0 then
    begin
      Memo1.Lines.Add('报告发布:【'+ADOTemp22.fieldbyname('unid').AsString+'】'+ADOTemp22.fieldbyname('patientname').AsString);
      WriteLog(PChar('报告发布:【'+ADOTemp22.fieldbyname('unid').AsString+'】'+ADOTemp22.fieldbyname('patientname').AsString));
      
      UniStoredProc1:=TUniStoredProc.Create(nil);
      UniStoredProc1.Connection:=UniConnection1;
      UniStoredProc1.Close;
      UniStoredProc1.Params.Clear;
      UniStoredProc1.StoredProcName:='usp_yjjk_jcbrfb';//病人信息发布
      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[0].Name:='orgcode';
      UniStoredProc1.Params[0].DataType:=ftString;
      UniStoredProc1.Params[0].ParamType:=ptInput;
      UniStoredProc1.ParamByName('orgcode').Value:=OrgCode;

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[1].Name:='repno';
      UniStoredProc1.Params[1].DataType:=ftstring;
      UniStoredProc1.Params[1].ParamType:=ptinput;
      UniStoredProc1.ParamByName('repno').Value:='';

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[2].Name:='syscode';
      UniStoredProc1.Params[2].DataType:=ftstring;
      UniStoredProc1.Params[2].ParamType:=ptinput;
      UniStoredProc1.ParamByName('syscode').Value:='LIS';

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[3].Name:='applyno';
      UniStoredProc1.Params[3].DataType:=ftInteger;
      UniStoredProc1.Params[3].ParamType:=ptinput;
      UniStoredProc1.ParamByName('applyno').Value:=ADOTemp22.fieldbyname('unid').AsInteger;

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[4].Name:='techno';
      UniStoredProc1.Params[4].DataType:=ftstring;
      UniStoredProc1.Params[4].ParamType:=ptinput;
      UniStoredProc1.ParamByName('techno').Value:='0';

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[5].Name:='instid';
      UniStoredProc1.Params[5].DataType:=ftstring;
      UniStoredProc1.Params[5].ParamType:=ptinput;
      UniStoredProc1.ParamByName('instid').Value:='';

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[6].Name:='instname';
      UniStoredProc1.Params[6].DataType:=ftstring;
      UniStoredProc1.Params[6].ParamType:=ptinput;
      UniStoredProc1.ParamByName('instname').Value:='';

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[7].Name:='bglx';
      UniStoredProc1.Params[7].DataType:=ftstring;
      UniStoredProc1.Params[7].ParamType:=ptinput;
      UniStoredProc1.ParamByName('bglx').Value:='';

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[8].Name:='bglxm';
      UniStoredProc1.Params[8].DataType:=ftstring;
      UniStoredProc1.Params[8].ParamType:=ptinput;
      UniStoredProc1.ParamByName('bglxm').Value:='';

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[9].Name:='brlx';
      UniStoredProc1.Params[9].DataType:=ftstring;
      UniStoredProc1.Params[9].ParamType:=ptinput;
      UniStoredProc1.ParamByName('brlx').Value:=ADOTemp22.fieldbyname('His_MzOrZy').AsString;

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[10].Name:='patientid';
      UniStoredProc1.Params[10].DataType:=ftstring;
      UniStoredProc1.Params[10].ParamType:=ptinput;
      UniStoredProc1.ParamByName('patientid').Value:='';

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[11].Name:='cureno';
      UniStoredProc1.Params[11].DataType:=ftstring;
      UniStoredProc1.Params[11].ParamType:=ptinput;
      UniStoredProc1.ParamByName('cureno').Value:=ADOTemp22.fieldbyname('His_Unid').AsString;

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[12].Name:='times';
      UniStoredProc1.Params[12].DataType:=ftstring;
      UniStoredProc1.Params[12].ParamType:=ptinput;
      UniStoredProc1.ParamByName('times').Value:='0';

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[13].Name:='yexh';
      UniStoredProc1.Params[13].DataType:=ftstring;
      UniStoredProc1.Params[13].ParamType:=ptinput;
      UniStoredProc1.ParamByName('yexh').Value:='0';

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[14].Name:='hospno';
      UniStoredProc1.Params[14].DataType:=ftstring;
      UniStoredProc1.Params[14].ParamType:=ptinput;
      UniStoredProc1.ParamByName('hospno').Value:=ADOTemp22.fieldbyname('His_Unid').AsString;

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[15].Name:='cardno';
      UniStoredProc1.Params[15].DataType:=ftstring;
      UniStoredProc1.Params[15].ParamType:=ptinput;
      UniStoredProc1.ParamByName('cardno').Value:='';

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[16].Name:='patname';
      UniStoredProc1.Params[16].DataType:=ftstring;
      UniStoredProc1.Params[16].ParamType:=ptinput;
      UniStoredProc1.ParamByName('patname').Value:=ADOTemp22.fieldbyname('patientname').AsString;

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[17].Name:='sex';
      UniStoredProc1.Params[17].DataType:=ftstring;
      UniStoredProc1.Params[17].ParamType:=ptinput;
      UniStoredProc1.ParamByName('sex').Value:=ADOTemp22.fieldbyname('sex').AsString;

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[18].Name:='age';
      UniStoredProc1.Params[18].DataType:=ftstring;
      UniStoredProc1.Params[18].ParamType:=ptinput;
      UniStoredProc1.ParamByName('age').Value:=ADOTemp22.fieldbyname('age').AsString;

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[19].Name:='applydept';
      UniStoredProc1.Params[19].DataType:=ftstring;
      UniStoredProc1.Params[19].ParamType:=ptinput;
      UniStoredProc1.ParamByName('applydept').Value:='';

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[20].Name:='applydeptname';
      UniStoredProc1.Params[20].DataType:=ftstring;
      UniStoredProc1.Params[20].ParamType:=ptinput;
      UniStoredProc1.ParamByName('applydeptname').Value:='';

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[21].Name:='ward';
      UniStoredProc1.Params[21].DataType:=ftstring;
      UniStoredProc1.Params[21].ParamType:=ptinput;
      UniStoredProc1.ParamByName('ward').Value:='';

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[22].Name:='wardname';
      UniStoredProc1.Params[22].DataType:=ftstring;
      UniStoredProc1.Params[22].ParamType:=ptinput;
      UniStoredProc1.ParamByName('wardname').Value:='';

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[23].Name:='bedno';
      UniStoredProc1.Params[23].DataType:=ftstring;
      UniStoredProc1.Params[23].ParamType:=ptinput;
      UniStoredProc1.ParamByName('bedno').Value:='';

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[24].Name:='applytime';
      UniStoredProc1.Params[24].DataType:=ftstring;
      UniStoredProc1.Params[24].ParamType:=ptinput;
      UniStoredProc1.ParamByName('applytime').Value:='';

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[25].Name:='applydoctorcode';
      UniStoredProc1.Params[25].DataType:=ftstring;
      UniStoredProc1.Params[25].ParamType:=ptinput;
      UniStoredProc1.ParamByName('applydoctorcode').Value:='';

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[26].Name:='applydoctorname';
      UniStoredProc1.Params[26].DataType:=ftstring;
      UniStoredProc1.Params[26].ParamType:=ptinput;
      UniStoredProc1.ParamByName('applydoctorname').Value:='';

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[27].Name:='receivetime';
      UniStoredProc1.Params[27].DataType:=ftstring;
      UniStoredProc1.Params[27].ParamType:=ptinput;
      UniStoredProc1.ParamByName('receivetime').Value:='';

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[28].Name:='execdeptcode';
      UniStoredProc1.Params[28].DataType:=ftstring;
      UniStoredProc1.Params[28].ParamType:=ptinput;
      UniStoredProc1.ParamByName('execdeptcode').Value:='';

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[29].Name:='execdeptname';
      UniStoredProc1.Params[29].DataType:=ftstring;
      UniStoredProc1.Params[29].ParamType:=ptinput;
      UniStoredProc1.ParamByName('execdeptname').Value:='';

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[30].Name:='execdoctorcode';
      UniStoredProc1.Params[30].DataType:=ftInteger;
      UniStoredProc1.Params[30].ParamType:=ptinput;
      UniStoredProc1.ParamByName('execdoctorcode').Value:=0;

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[31].Name:='execdoctorname';
      UniStoredProc1.Params[31].DataType:=ftstring;
      UniStoredProc1.Params[31].ParamType:=ptinput;
      UniStoredProc1.ParamByName('execdoctorname').Value:='';

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[32].Name:='reporttime';
      UniStoredProc1.Params[32].DataType:=ftstring;
      UniStoredProc1.Params[32].ParamType:=ptinput;
      UniStoredProc1.ParamByName('reporttime').Value:='';

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[33].Name:='verifydoctorcode';
      UniStoredProc1.Params[33].DataType:=ftInteger;
      UniStoredProc1.Params[33].ParamType:=ptinput;
      UniStoredProc1.ParamByName('verifydoctorcode').Value:=0;

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[34].Name:='verifydoctorname';
      UniStoredProc1.Params[34].DataType:=ftstring;
      UniStoredProc1.Params[34].ParamType:=ptinput;
      UniStoredProc1.ParamByName('verifydoctorname').Value:='';

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[35].Name:='sampledesc';
      UniStoredProc1.Params[35].DataType:=ftstring;
      UniStoredProc1.Params[35].ParamType:=ptinput;
      UniStoredProc1.ParamByName('sampledesc').Value:='';

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[36].Name:='comment';
      UniStoredProc1.Params[36].DataType:=ftstring;
      UniStoredProc1.Params[36].ParamType:=ptinput;
      UniStoredProc1.ParamByName('comment').Value:='';

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[37].Name:='sampletime';
      UniStoredProc1.Params[37].DataType:=ftstring;
      UniStoredProc1.Params[37].ParamType:=ptinput;
      UniStoredProc1.ParamByName('sampletime').Value:='';

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[38].Name:='wjbz';
      UniStoredProc1.Params[38].DataType:=ftstring;
      UniStoredProc1.Params[38].ParamType:=ptinput;
      UniStoredProc1.ParamByName('wjbz').Value:='';

      UniStoredProc1.Params.Add;
      UniStoredProc1.Params[39].Name:='result';//必需
      UniStoredProc1.Params[39].DataType:=ftCursor;
      UniStoredProc1.Params[39].ParamType:=ptOutput;
      try
        UniStoredProc1.Open;
        if UniStoredProc1.FieldByName('confirm').AsString<>'T' then
        begin
          Memo1.Lines.Add(ADOTemp22.fieldbyname('unid').AsString+'【'+ADOTemp22.fieldbyname('patientname').AsString+'】病人信息发布失败:'+UniStoredProc1.FieldByName('errdesc').AsString);
          WriteLog(PChar(ADOTemp22.fieldbyname('unid').AsString+'【'+ADOTemp22.fieldbyname('patientname').AsString+'】病人信息发布失败:'+UniStoredProc1.FieldByName('errdesc').AsString));
        end else ExecSQLCmd(ADOConnection1.ConnectionString,'update '+ifThen(ifCompleted=1,'chk_con_bak','chk_con')+' set Weight=''已发布'' where Unid='+ADOTemp22.fieldbyname('unid').AsString);
      except
        on E:Exception do
        begin
          Memo1.Lines.Add(ADOTemp22.fieldbyname('unid').AsString+'【'+ADOTemp22.fieldbyname('patientname').AsString+'】病人信息发布(usp_yjjk_jcbrfb)执行出错:'+E.Message);
          WriteLog(PChar(ADOTemp22.fieldbyname('unid').AsString+'【'+ADOTemp22.fieldbyname('patientname').AsString+'】病人信息发布(usp_yjjk_jcbrfb)执行出错:'+E.Message));
        end;
      end;
      UniStoredProc1.Free;
    end;

    i:=0;
    while not ADOTemp33.Eof do
    begin
      inc(i);
      
      UniStoredProc2:=TUniStoredProc.Create(nil);
      UniStoredProc2.Connection:=UniConnection1;
      UniStoredProc2.Close;
      UniStoredProc2.Params.Clear;
      UniStoredProc2.StoredProcName:='usp_yjjk_yjjgfb';//病人结果发布
      UniStoredProc2.Params.Add;
      UniStoredProc2.Params[0].Name:='orgcode';
      UniStoredProc2.Params[0].DataType:=ftString;
      UniStoredProc2.Params[0].ParamType:=ptInput;
      UniStoredProc2.ParamByName('orgcode').Value:=OrgCode;

      UniStoredProc2.Params.Add;
      UniStoredProc2.Params[1].Name:='syscode';
      UniStoredProc2.Params[1].DataType:=ftstring;
      UniStoredProc2.Params[1].ParamType:=ptinput;
      UniStoredProc2.ParamByName('syscode').Value:='LIS';

      UniStoredProc2.Params.Add;
      UniStoredProc2.Params[2].Name:='brlx';
      UniStoredProc2.Params[2].DataType:=ftstring;
      UniStoredProc2.Params[2].ParamType:=ptinput;
      UniStoredProc2.ParamByName('brlx').Value:=ADOTemp22.fieldbyname('His_MzOrZy').AsString;

      UniStoredProc2.Params.Add;
      UniStoredProc2.Params[3].Name:='patid';
      UniStoredProc2.Params[3].DataType:=ftstring;
      UniStoredProc2.Params[3].ParamType:=ptinput;
      UniStoredProc2.ParamByName('patid').Value:='';

      UniStoredProc2.Params.Add;
      UniStoredProc2.Params[4].Name:='cureno';
      UniStoredProc2.Params[4].DataType:=ftstring;
      UniStoredProc2.Params[4].ParamType:=ptinput;
      UniStoredProc2.ParamByName('cureno').Value:=ADOTemp22.fieldbyname('His_Unid').AsString;

      UniStoredProc2.Params.Add;
      UniStoredProc2.Params[5].Name:='times';
      UniStoredProc2.Params[5].DataType:=ftstring;
      UniStoredProc2.Params[5].ParamType:=ptinput;
      UniStoredProc2.ParamByName('times').Value:='0';

      UniStoredProc2.Params.Add;
      UniStoredProc2.Params[6].Name:='yexh';
      UniStoredProc2.Params[6].DataType:=ftstring;
      UniStoredProc2.Params[6].ParamType:=ptinput;
      UniStoredProc2.ParamByName('yexh').Value:='0';

      UniStoredProc2.Params.Add;
      UniStoredProc2.Params[7].Name:='applyno';
      UniStoredProc2.Params[7].DataType:=ftstring;
      UniStoredProc2.Params[7].ParamType:=ptinput;
      UniStoredProc2.ParamByName('applyno').Value:=ADOTemp22.fieldbyname('unid').AsInteger;

      UniStoredProc2.Params.Add;
      UniStoredProc2.Params[8].Name:='hisxxh';
      UniStoredProc2.Params[8].DataType:=ftstring;
      UniStoredProc2.Params[8].ParamType:=ptinput;
      UniStoredProc2.ParamByName('hisxxh').Value:='LIS1';

      UniStoredProc2.Params.Add;
      UniStoredProc2.Params[9].Name:='bglx';
      UniStoredProc2.Params[9].DataType:=ftstring;
      UniStoredProc2.Params[9].ParamType:=ptinput;
      UniStoredProc2.ParamByName('bglx').Value:='';

      UniStoredProc2.Params.Add;
      UniStoredProc2.Params[10].Name:='bglxmc';
      UniStoredProc2.Params[10].DataType:=ftstring;
      UniStoredProc2.Params[10].ParamType:=ptinput;
      UniStoredProc2.ParamByName('bglxmc').Value:='';

      UniStoredProc2.Params.Add;
      UniStoredProc2.Params[11].Name:='xmdm';
      UniStoredProc2.Params[11].DataType:=ftstring;
      UniStoredProc2.Params[11].ParamType:=ptinput;
      UniStoredProc2.ParamByName('xmdm').Value:='';

      UniStoredProc2.Params.Add;
      UniStoredProc2.Params[12].Name:='xmmc';
      UniStoredProc2.Params[12].DataType:=ftstring;
      UniStoredProc2.Params[12].ParamType:=ptinput;
      UniStoredProc2.ParamByName('xmmc').Value:=ADOTemp33.fieldbyname('Name').AsString;

      UniStoredProc2.Params.Add;
      UniStoredProc2.Params[13].Name:='xmjg';
      UniStoredProc2.Params[13].DataType:=ftstring;
      UniStoredProc2.Params[13].ParamType:=ptinput;
      UniStoredProc2.ParamByName('xmjg').Value:=ADOTemp33.fieldbyname('itemvalue').AsString;

      UniStoredProc2.Params.Add;
      UniStoredProc2.Params[14].Name:='jyksdm';
      UniStoredProc2.Params[14].DataType:=ftstring;
      UniStoredProc2.Params[14].ParamType:=ptinput;
      UniStoredProc2.ParamByName('jyksdm').Value:='';

      UniStoredProc2.Params.Add;
      UniStoredProc2.Params[15].Name:='jyysdm';
      UniStoredProc2.Params[15].DataType:=ftstring;
      UniStoredProc2.Params[15].ParamType:=ptinput;
      UniStoredProc2.ParamByName('jyysdm').Value:='';

      UniStoredProc2.Params.Add;
      UniStoredProc2.Params[16].Name:='shysdm';
      UniStoredProc2.Params[16].DataType:=ftstring;
      UniStoredProc2.Params[16].ParamType:=ptinput;
      UniStoredProc2.ParamByName('shysdm').Value:='';

      UniStoredProc2.Params.Add;
      UniStoredProc2.Params[17].Name:='bgsj';
      UniStoredProc2.Params[17].DataType:=ftstring;
      UniStoredProc2.Params[17].ParamType:=ptinput;
      UniStoredProc2.ParamByName('bgsj').Value:=FormatDateTime('YYYY-MM-DD hh:nn:ss',ADOTemp22.fieldbyname('Audit_Date').AsDateTime);

      UniStoredProc2.Params.Add;
      UniStoredProc2.Params[18].Name:='xmdw';
      UniStoredProc2.Params[18].DataType:=ftstring;
      UniStoredProc2.Params[18].ParamType:=ptinput;
      UniStoredProc2.ParamByName('xmdw').Value:=ADOTemp33.fieldbyname('Unit').AsString;

      UniStoredProc2.Params.Add;
      UniStoredProc2.Params[19].Name:='jglx';
      UniStoredProc2.Params[19].DataType:=ftstring;
      UniStoredProc2.Params[19].ParamType:=ptinput;
      UniStoredProc2.ParamByName('jglx').Value:='';

      UniStoredProc2.Params.Add;
      UniStoredProc2.Params[20].Name:='jgckz';
      UniStoredProc2.Params[20].DataType:=ftstring;
      UniStoredProc2.Params[20].ParamType:=ptinput;
      UniStoredProc2.ParamByName('jgckz').Value:=ADOTemp33.fieldbyname('REF_RANGE').AsString;

      UniStoredProc2.Params.Add;
      UniStoredProc2.Params[21].Name:='gdbz';
      UniStoredProc2.Params[21].DataType:=ftstring;
      UniStoredProc2.Params[21].ParamType:=ptinput;
      UniStoredProc2.ParamByName('gdbz').Value:=ADOTemp33.fieldbyname('RESULT_STATE_DESC').AsString;

      UniStoredProc2.Params.Add;
      UniStoredProc2.Params[22].Name:='dyxh';
      UniStoredProc2.Params[22].DataType:=ftstring;
      UniStoredProc2.Params[22].ParamType:=ptinput;
      UniStoredProc2.ParamByName('dyxh').Value:='K0'+IntToStr(i);//一张报告单的打印序号不能重复

      UniStoredProc2.Params.Add;
      UniStoredProc2.Params[23].Name:='jcbw';
      UniStoredProc2.Params[23].DataType:=ftstring;
      UniStoredProc2.Params[23].ParamType:=ptinput;
      UniStoredProc2.ParamByName('jcbw').Value:=ADOTemp22.fieldbyname('flagetype').AsString;

      UniStoredProc2.Params.Add;
      UniStoredProc2.Params[24].Name:='hisapplyno';
      UniStoredProc2.Params[24].DataType:=ftstring;
      UniStoredProc2.Params[24].ParamType:=ptinput;
      UniStoredProc2.ParamByName('hisapplyno').Value:=ADOTemp33.fieldbyname('Surem1').AsString;

      UniStoredProc2.Params.Add;
      UniStoredProc2.Params[25].Name:='tolab';
      UniStoredProc2.Params[25].DataType:=ftstring;
      UniStoredProc2.Params[25].ParamType:=ptinput;
      UniStoredProc2.ParamByName('tolab').Value:='';
    
      UniStoredProc2.Params.Add;
      UniStoredProc2.Params[26].Name:='result';//必需
      UniStoredProc2.Params[26].DataType:=ftCursor;
      UniStoredProc2.Params[26].ParamType:=ptOutput;
      try
        UniStoredProc2.Open;
        if UniStoredProc2.FieldByName('confirm').AsString<>'T' then
        begin
          Memo1.Lines.Add(ADOTemp33.fieldbyname('valueid').AsString+'【'+ADOTemp22.fieldbyname('patientname').AsString+'】病人结果发布失败:'+UniStoredProc2.FieldByName('errdesc').AsString);
          WriteLog(PChar(ADOTemp33.fieldbyname('valueid').AsString+'【'+ADOTemp22.fieldbyname('patientname').AsString+'】病人结果发布失败:'+UniStoredProc2.FieldByName('errdesc').AsString));
        end;
      except
        on E:Exception do
        begin
          Memo1.Lines.Add(ADOTemp33.fieldbyname('valueid').AsString+'【'+ADOTemp22.fieldbyname('patientname').AsString+'】病人结果发布(usp_yjjk_yjjgfb)执行出错:'+E.Message);
          WriteLog(PChar(ADOTemp33.fieldbyname('valueid').AsString+'【'+ADOTemp22.fieldbyname('patientname').AsString+'】病人结果发布(usp_yjjk_yjjgfb)执行出错:'+E.Message));
        end;
      end;
      UniStoredProc2.Free;

      ADOTemp33.Next;
    end;
    ADOTemp33.Free;

    ADOTemp22.Next;
  end;
  ADOTemp22.Free;

  (Sender as TTimer).Enabled:=true;
end;

function TfrmMain.ExecSQLCmd(AConnectionString:string;ASQL:string):integer;
var
  Conn:TADOConnection;
  Qry:TAdoQuery;
begin
  Conn:=TADOConnection.Create(nil);
  Conn.LoginPrompt:=false;
  Conn.ConnectionString:=AConnectionString;
  Qry:=TAdoQuery.Create(nil);
  Qry.Connection:=Conn;
  Qry.Close;
  Qry.SQL.Clear;
  Qry.SQL.Text:=ASQL;
  Try
    Result:=Qry.ExecSQL;
  except
    on E:Exception do
    begin
      Memo1.Lines.Add('函数ExecSQLCmd失败:'+E.Message+'。错误的SQL:'+ASQL);
      WriteLog(PChar('函数ExecSQLCmd失败:'+E.Message+'。错误的SQL:'+ASQL));
      Result:=-1;
    end;
  end;
  Qry.Free;
  Conn.Free;
end;

procedure TfrmMain.N1Click(Sender: TObject);
begin
  LYTray1.ShowMainForm;
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  action:=caNone;
  LYTray1.HideMainForm;
end;

procedure TfrmMain.N3Click(Sender: TObject);
begin
  if (MessageDlg('退出后将不再回传检验结果,确定退出吗？', mtWarning, [mbYes, mbNo], 0) <> mrYes) then exit;
  application.Terminate;
end;

initialization
    hnd := CreateMutex(nil, True, Pchar(ExtractFileName(Application.ExeName)));
    if GetLastError = ERROR_ALREADY_EXISTS then
    begin
        MessageBox(application.Handle,pchar('该程序已在运行中！'),
                    '系统提示',MB_OK+MB_ICONinformation);   
        Halt;
    end;

finalization
    if hnd <> 0 then CloseHandle(hnd);

end.
