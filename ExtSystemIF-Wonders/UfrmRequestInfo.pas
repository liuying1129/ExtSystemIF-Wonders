unit UfrmRequestInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, Uni, ComCtrls, StrUtils,DB, ADODB;

type
  TfrmRequestInfo = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    BitBtn4: TBitBtn;
    LabeledEdit1: TLabeledEdit;
    Label1: TLabel;
    BitBtn1: TBitBtn;
    RadioGroup1: TRadioGroup;
    LabeledEdit2: TLabeledEdit;
    LabeledEdit3: TLabeledEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

//var
function  frmRequestInfo: TfrmRequestInfo;

implementation

uses UfrmMain;

var
  ffrmRequestInfo: TfrmRequestInfo;
  
{$R *.dfm}

function  frmRequestInfo: TfrmRequestInfo;
begin
  if ffrmRequestInfo=nil then ffrmRequestInfo:=TfrmRequestInfo.Create(application.mainform);
  result:=ffrmRequestInfo;
end;

procedure TfrmRequestInfo.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  action:=cafree;
  if ffrmRequestInfo=self then ffrmRequestInfo:=nil;
end;

procedure TfrmRequestInfo.BitBtn4Click(Sender: TObject);
var
  UniStoredProc4:TUniStoredProc;

  ADOTemp22:TADOQuery;
begin
  UniStoredProc4:=TUniStoredProc.Create(nil);
  UniStoredProc4.Connection:=frmMain.UniConnection1;
  UniStoredProc4.Close;
  UniStoredProc4.Params.Clear;
  UniStoredProc4.StoredProcName:='usp_yjjk_yjjghuishou';//病人报告回收
  UniStoredProc4.Params.Add;
  UniStoredProc4.Params[0].Name:='orgcode';
  UniStoredProc4.Params[0].DataType:=ftString;
  UniStoredProc4.Params[0].ParamType:=ptInput;
  UniStoredProc4.ParamByName('orgcode').Value:=OrgCode;

  UniStoredProc4.Params.Add;
  UniStoredProc4.Params[1].Name:='syscode';
  UniStoredProc4.Params[1].DataType:=ftstring;
  UniStoredProc4.Params[1].ParamType:=ptinput;
  UniStoredProc4.ParamByName('syscode').Value:='LIS';

  UniStoredProc4.Params.Add;
  UniStoredProc4.Params[2].Name:='applyno';
  UniStoredProc4.Params[2].DataType:=ftstring;
  UniStoredProc4.Params[2].ParamType:=ptinput;
  UniStoredProc4.ParamByName('applyno').Value:=LabeledEdit1.Text;

  UniStoredProc4.Params.Add;
  UniStoredProc4.Params[3].Name:='tolab';
  UniStoredProc4.Params[3].DataType:=ftstring;
  UniStoredProc4.Params[3].ParamType:=ptinput;
  UniStoredProc4.ParamByName('tolab').Value:='';

  UniStoredProc4.Params.Add;
  UniStoredProc4.Params[4].Name:='result';//必需
  UniStoredProc4.Params[4].DataType:=ftCursor;
  UniStoredProc4.Params[4].ParamType:=ptOutput;
  try
    UniStoredProc4.Open;
    if UniStoredProc4.FieldByName('confirm').AsString<>'T' then
      MessageDlg('病人报告回收失败:'+UniStoredProc4.FieldByName('errdesc').AsString,mtError,[mbOK],0)
    else MessageDlg('病人报告回收成功',mtInformation,[mbOK],0);
  except
    on E:Exception do
    begin
      MessageDlg('病人报告回收(usp_yjjk_yjjghuishou)执行出错:'+E.Message,mtError,[mbOK],0);
    end;
  end;
  UniStoredProc4.Free;
    
  //执行该语句是为了回收报告后可以再次发布
  ADOTemp22:=TADOQuery.Create(nil);
  ADOTemp22.Connection:=frmMain.ADOConnection1;
  ADOTemp22.Close;
  ADOTemp22.SQL.Clear;
  ADOTemp22.SQL.Text:='update Chk_Con set Weight=null where unid='+LabeledEdit1.Text;
  ADOTemp22.ExecSQL;
  ADOTemp22.Free;
end;

procedure TfrmRequestInfo.BitBtn1Click(Sender: TObject);
var
  UniStoredProc1:TUniStoredProc;
begin
  UniStoredProc1:=TUniStoredProc.Create(nil);
  UniStoredProc1.Connection:=frmMain.UniConnection1;
  UniStoredProc1.Close;
  UniStoredProc1.Params.Clear;
  UniStoredProc1.StoredProcName:='usp_yjjk_yjqr';//医技确认执行病人收费项目
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
  UniStoredProc1.Params[2].Name:='patid';
  UniStoredProc1.Params[2].DataType:=ftstring;
  UniStoredProc1.Params[2].ParamType:=ptinput;
  UniStoredProc1.ParamByName('patid').Value:='';

  UniStoredProc1.Params.Add;
  UniStoredProc1.Params[3].Name:='curno';
  UniStoredProc1.Params[3].DataType:=ftstring;
  UniStoredProc1.Params[3].ParamType:=ptinput;
  UniStoredProc1.ParamByName('curno').Value:=LabeledEdit2.Text;

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
  UniStoredProc1.ParamByName('logno').Value:='LIS1';//必需

  UniStoredProc1.Params.Add;
  UniStoredProc1.Params[9].Name:='applyno';
  UniStoredProc1.Params[9].DataType:=ftstring;
  UniStoredProc1.Params[9].ParamType:=ptinput;
  UniStoredProc1.ParamByName('applyno').Value:=LabeledEdit3.Text;

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
  UniStoredProc1.ParamByName('xmstatus').Value:=3;//3表示撤销操作

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
  UniStoredProc1.Params[19].Name:='result';//必需
  UniStoredProc1.Params[19].DataType:=ftCursor;
  UniStoredProc1.Params[19].ParamType:=ptOutput;
  try
    UniStoredProc1.Open;
    if UniStoredProc1.FieldByName('confirm').AsString<>'T' then
      MessageDlg('撤销失败:'+UniStoredProc1.FieldByName('errdesc').AsString,mtError,[mbOK],0)
    else MessageDlg('撤销成功',mtInformation,[mbOK],0);
  except
    on E:Exception do
    begin
      MessageDlg('撤销(usp_yjjk_yjqr)执行出错:'+E.Message,mtError,[mbOK],0);
    end;
  end;

  UniStoredProc1.Free;
end;

initialization
  ffrmRequestInfo:=nil;

end.
