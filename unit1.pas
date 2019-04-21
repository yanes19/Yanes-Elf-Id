unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, RTTICtrls, Forms, Controls, Graphics, Dialogs,
  EditBtn, ExtCtrls, Buttons, ComCtrls, StdCtrls, strutils, BaseUnix, LCLIntf,
  Grids, Menus,

  ElfObject;

type

  { TForm_Main }

  TForm_Main = class(TForm)
    BitBtn_GetELFid: TBitBtn;
    BitBtn_Reset: TBitBtn;
    FileNameEdit1: TFileNameEdit;
    ImageAbout: TImage;
    Label_AboutCopyrights: TLabel;
    Label_AboutDesc: TLabel;
    Label_AboutTitle: TLabel;
    Label_AccessData: TLabel;
    Label_Access: TLabel;
    Label_FileOwnerData: TLabel;
    Label_FileOwner: TLabel;
    Label_FileSizeData: TLabel;
    Label_FileSize: TLabel;
    Label_FileDirData: TLabel;
    Label_FileDir: TLabel;
    Label_FileNameData: TLabel;
    Label_FileName: TLabel;
    Label_SectionHdrEntryCount: TLabel;
    Label_SectionHdrEntrySizeData: TLabel;
    Label_SectionHdrEntrySize: TLabel;
    Label_ProgramHdrEntriesCountData: TLabel;
    Label_ProgramHdrEntrySizeData: TLabel;
    Label_HeaderSizeData: TLabel;
    Label_ProgramHdrEntriesCount: TLabel;
    Label_ProgramHdrEntrySize: TLabel;
    Label_HeaderSize: TLabel;
    Label_MagicComment: TLabel;
    Label_SectionHdrTableData: TLabel;
    Label_SectionHdrTable: TLabel;
    Label_programHeaderTableData: TLabel;
    Label_ProgramHeaderTable: TLabel;
    Label_PEP: TLabel;
    Label_PEPData: TLabel;
    Label_AchitectureData: TLabel;
    Label_EVersionData: TLabel;
    Label_EVersion: TLabel;
    Label_E_MachineData: TLabel;
    Label_E_Machine: TLabel;
    Label_ObjectType_data: TLabel;
    Label_ObjectType: TLabel;
    Label_ABIData: TLabel;
    Label_ABI: TLabel;
    Label_EndiabnessData: TLabel;
    Label_Endianess: TLabel;
    Label_Magic_data: TLabel;
    Label_Achitecture: TLabel;
    Label_Magic: TLabel;
    Label_SectionHdrStrIndex: TLabel;
    Label_SectionHdrEntryCountData: TLabel;
    Label_SectionHdrStrIndexData: TLabel;
    Memo1: TMemo;
    MenuItem_ExportText: TMenuItem;
    MenuItem_ExportHtml: TMenuItem;
    MenuItem_CopySelected: TMenuItem;
    MenuItem_CopyAll: TMenuItem;
    MenuItem_Export: TMenuItem;
    MenuItem_CopyToClpbrd: TMenuItem;
    MenuItem_DumpSection: TMenuItem;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel_Open: TPanel;
    PopupMenu_Sections: TPopupMenu;
    SaveFileDialog: TSaveDialog;
    StatusBar1: TStatusBar;
    StringGrid_Sections: TStringGrid;
    TabSheet1: TTabSheet;
    Tab_Sections: TTabSheet;
    Tab_About: TTabSheet;
    Tab_FileInfos: TTabSheet;
    Tab_ElfHeader: TTabSheet;
    procedure BitBtn_GetELFidClick(Sender: TObject);
    procedure BitBtn_ResetClick(Sender: TObject);
    procedure Edit_MagicCommentClick(Sender: TObject);
    procedure Label_AboutTitleClick(Sender: TObject);
    procedure Label_AboutTitleMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Label_AboutTitleMouseEnter(Sender: TObject);
    procedure Label_AboutTitleMouseLeave(Sender: TObject);
    procedure MenuItem_CopyAllClick(Sender: TObject);
    procedure MenuItem_CopySelectedClick(Sender: TObject);
    procedure MenuItem_DumpSectionClick(Sender: TObject);
    procedure MenuItem_ExportClick(Sender: TObject);
    procedure MenuItem_ExportHtmlClick(Sender: TObject);
    procedure MenuItem_ExportTextClick(Sender: TObject);
    procedure ResizeCol(AGrid: TStringGrid; const ACol: Integer);
    //function TryReadASCII(Data: array of Byte): String ;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form_Main: TForm_Main;

implementation

{$R *.lfm}

{ TForm_Main }

procedure TForm_Main.BitBtn_GetELFidClick(Sender: TObject);
var
  MyFile: file;
  Data: array [0..64] of Byte;
  SectionHdr : array of byte ;
  i : integer ; j : Int64;
  ElfSection : TElfSection;
  info : stat;
begin
  if FileNameEdit1.FileName = '' then
   begin
    ShowMessage('Please provide an ELF object file');
    exit;
   end;
  try
    AssignFile(MyFile, FileNameEdit1.FileName);
    Reset(MyFile, 1  );
  except
    on E : Exception do
    begin
      ShowMessage(' Error encountered: '+E.Message);
      Exit;
    end;
  end;
  BitBtn_ResetClick(nil);
  Label_Magic_data.Caption:='';
  StatusBar1.Panels[0].Text:= FileNameEdit1.FileName;
  try
    BlockRead(MyFile, Data, SizeOf(Data));
    for i := 0 to 3 do
    begin
      Label_Magic_data.Caption:=  Label_Magic_data.Caption + ' ' + IntToHex(Data[i],2);
      if AnsiStartsStr(Label_Magic_data.Caption ,' 7F 45 4C 46') then
       begin
       Label_MagicComment.Caption:= 'Native ELF magic bytes';
       Label_MagicComment.Font.Color:=clGreen;
       end
      else
        begin
          Label_MagicComment.Caption:= 'Invalid ELF file :ELF Magic bytes mismatch ! ' ;
          Label_MagicComment.Font.Color:=clMaroon;
          exit;

        end;
    end;
    if Data[4] = 1 then Label_AchitectureData.Caption:= '32 - Bits Executable';
    if Data[4] = 2 then Label_AchitectureData.Caption:= '64 - Bits Executable';
    if Data[5] = 1 then Label_EndiabnessData.Caption:= 'Little Endian';
    if Data[5] = 2 then Label_EndiabnessData.Caption:= 'Big Endian';
    Label_ABIData.Caption:= GetABI(Data);
    Label_ObjectType_data.Caption:= GetELFType(Data);
    Label_E_MachineData.Caption:= GetMachineType(Data);
    Label_EVersionData.Caption:=  GetVersion(Data);
    Label_PEPData.Caption:= IntToStr(GetEntryPoint(Data)) + '  ('+IntToHex(GetEntryPoint(Data),8) +'h)';
    Label_programHeaderTableData.Caption := IntToStr(GetProgramHeaderTable(Data)) + '  ('+IntToHex(GetProgramHeaderTable(Data),8) +'h)';
    Label_SectionHdrTableData.Caption:=IntToStr(GetSectionHdrTable(Data))+ '  ('+IntToHex(GetSectionHdrTable(Data),8) +'h)';;
    case Data[4] of
    1 : Label_HeaderSizeData.Caption:= '52 Bytes (34h)';
    2 : Label_HeaderSizeData.Caption:= '64 Bytes (40h)';
    end;
    Label_ProgramHdrEntrySizeData.Caption:=IntToStr(ProgramHdrEntrySize(Data)) + '  bytes ';
    Label_ProgramHdrEntriesCountData.Caption:= IntToStr(ProgramHdrEntriesCount(Data));
    Label_SectionHdrEntrySizeData.Caption:=IntToStr(GetSectionHdrEntrySize(Data)) + '  bytes ';
    Label_SectionHdrEntryCountData.Caption:=IntToStr(GetSectionHdrEntriesCount(Data));
    Label_SectionHdrStrIndexData.Caption:= IntToStr(GetSectionHdrStrIndex(Data));
    // implementing FileInfos Tab data .
    Label_FileNameData.Caption:=ExtractFileName(FileNameEdit1.FileName);
    //Label_FileDirData.Caption:=GetFileDescription(FileNameEdit1.FileName);
    Label_FileDirData.Caption:= ExtractShortPathNameUTF8 (FileNameEdit1.FileName);
    i := FileSize(FileNameEdit1.FileName);
    Label_FileSizeData.Caption:=IntToStr(i) + ' Bytes '+
                                '(' + IntToStr(i Div 1024)+ ' kb )';
    if fpstat (FileNameEdit1.FileName,info) =0 then
    Label_FileOwnerData.Caption:='UID = '+ IntToStr(info.st_uid) + '   GID = '+ IntToStr(info.st_gid);
    if fpAccess (FileNameEdit1.FileName,R_OK)=0 then Label_AccessData.Caption:= 'Read,';
    if fpAccess (FileNameEdit1.FileName,W_OK)= 0 then Label_AccessData.Caption :=  Label_AccessData.Caption +' Write,';
    if fpAccess (FileNameEdit1.FileName,X_OK)=0 then Label_AccessData.Caption :=  Label_AccessData.Caption + ' Execute';

  finally
    CloseFile(MyFile);
    //Reading section , Filling stringGrid .

    j := GetSectionHdrEntriesCount(Data);
    for i := 1 to  j do
    begin
      case Data[4] of
    1 : ElfSection := readSection32(FileNameEdit1.FileName,i-1);
    2 : ElfSection := readSection64(FileNameEdit1.FileName,i-1);
    end;

    StringGrid_Sections.RowCount:=StringGrid_Sections.RowCount +1;
    StringGrid_Sections.Rows[i].Append(IntToStr(ElfSection.s_Num));
    StringGrid_Sections.Rows[i].Append(ElfSection.s_name);
    StringGrid_Sections.Rows[i].Append(ElfSection.s_type);
    StringGrid_Sections.Rows[i].Append(IntToStr(ElfSection.s_flags));
    StringGrid_Sections.Rows[i].Append(IntToStr(ElfSection.s_addr));
    StringGrid_Sections.Rows[i].Append(IntToStr(ElfSection.s_offset));
    StringGrid_Sections.Rows[i].Append(IntToStr(ElfSection.s_Size));
    StringGrid_Sections.Rows[i].Append(IntToStr(ElfSection.s_link));
    StringGrid_Sections.Rows[i].Append(IntToStr(ElfSection.s_info));
    StringGrid_Sections.Rows[i].Append(IntToStr(ElfSection.s_addralign));
    StringGrid_Sections.Rows[i].Append(IntToStr(ElfSection.s_entsize));
    end;

    for i := 0 to StringGrid_Sections.ColCount-1 do
    ResizeCol(StringGrid_Sections,i);
    // Testing read sections x32
    //Memo1.Text:=readSection32(FileNameEdit1.FileName,1);
  end;

end;

procedure TForm_Main.BitBtn_ResetClick(Sender: TObject);
var
  i : Integer;
begin
  //Label_AchitectureData.Caption:= '---';
  for i := 0 to ComponentCount-1 do
    if (Components[i] is TLabel) then
      if Pos(':',TLabel(Components[i]).Caption)= 0 then
       TLabel(Components[i]).Caption:= '___';
  StatusBar1.Panels[0].Text:='Ready ..';
  for i := 1 to StringGrid_Sections.RowCount -1 do
  StringGrid_Sections.Rows[i].Clear;
  StringGrid_Sections.RowCount:= 1;


end;

procedure TForm_Main.Edit_MagicCommentClick(Sender: TObject);
begin
  FileNameEdit1.SetFocus;
end;

procedure TForm_Main.Label_AboutTitleClick(Sender: TObject);
begin
  OpenURL('http://yanescodegeek.blogspot.no');
end;

procedure TForm_Main.Label_AboutTitleMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 Label_AboutTitle.Font.Color:= clMaroon;
end;

procedure TForm_Main.Label_AboutTitleMouseEnter(Sender: TObject);
begin
 Label_AboutTitle.Font.Color:= clBlue;
end;

procedure TForm_Main.Label_AboutTitleMouseLeave(Sender: TObject);
begin
  Label_AboutTitle.Font.Color:= clBlack;
end;

procedure TForm_Main.MenuItem_CopyAllClick(Sender: TObject);
begin
  StringGrid_Sections.CopyToClipboard(false);
end;

procedure TForm_Main.MenuItem_CopySelectedClick(Sender: TObject);
begin
  StringGrid_Sections.CopyToClipboard(True);
end;

procedure TForm_Main.MenuItem_DumpSectionClick(Sender: TObject);
var ELFFile, DmpFile: file;
  SecOffset,SecSize ,i: Int64;
  SectionDmp :Array of byte ;
  //s : string ;
begin
  with StringGrid_Sections do
  begin
    SecOffset := StrToInt(rows[row].Strings[5]);
    SecSize :=   StrToInt(rows[row].Strings[6]);
    //ShowMessage('SecOffset : ' +inttostr(SecOffset) + 'SecSize: ' + inttostr(SecSize) );
  end;
  try
    AssignFile(ELFFile, FileNameEdit1.FileName);
    Reset(ELFFile, 1  );

  except
    on E : Exception do
    begin
      ShowMessage(' Error encountered: '+E.Message);
      Exit;
    end;
  end;
  try
    SectionDmp := DumpSection(SecOffset ,SecSize,ELFFile );
    for i := 0 to length(SectionDmp) do
    SaveFileDialog.Title:= 'Save dumped section to :';
    if SaveFileDialog.Execute then
       begin
       AssignFile(DmpFile,SaveFileDialog.FileName);
       Rewrite(DmpFile ,1);
       BlockWrite(DmpFile ,SectionDmp[0],length(SectionDmp));
       Closefile(DmpFile);
       end;
  finally
    //
  end;
end;

procedure TForm_Main.MenuItem_ExportClick(Sender: TObject);
begin

end;

procedure TForm_Main.MenuItem_ExportHtmlClick(Sender: TObject);
     // This procedure is just an early test

  var GridStream :Tmemorystream;
  var stringstrm : TStringStream;
  var Buffer : Array of byte ;
  var i :integer ;
  var strTable :string ;
  var addrss :PByte;
     S:String;
     X:Integer;
begin



   GridStream := TMemoryStream.Create;
   //StringGrid_Sections.SaveToStream(GridStream);
   //GridStream.Position:=0;
   {
   ShowMessage(IntToStr(GridStream.Size));
   GridStream.Seek(0,soBeginning);
   strTable := GridStream.ReadAnsiString;


   ShowMessage(strTable);
   ShowMessage(GridStream.ReadAnsiString);
   }
  X := GridStream.Position;
  GridStream.Position := 0;
  GridStream.Write(X,4);
  StringGrid_Sections.SaveToStream(GridStream);
  GridStream.Position := 0;
 S :=  GridStream.ReadAnsiString;
  ShowMessage(S);
  GridStream.Free;



end;

procedure TForm_Main.MenuItem_ExportTextClick(Sender: TObject);
begin
  SaveFileDialog.Title:= 'Save sections list to :';
  SaveFileDialog.DefaultExt:='csv';
  if SaveFileDialog.Execute then
       begin
       StringGrid_Sections.SaveToCSVFile(SaveFileDialog.FileName);
       end;
end;

procedure TForm_Main.ResizeCol(AGrid: TStringGrid; const ACol: Integer);
const
  MIN_COL_WIDTH = 15;
var
  M, T: Integer;
  X: Integer;
begin
  M:= MIN_COL_WIDTH;
  AGrid.Canvas.Font.Assign(AGrid.Font);
  for X:= 1 to AGrid.RowCount - 1 do begin
    T:= AGrid.Canvas.TextWidth(AGrid.Cells[ACol, X]);
    if T > M then M:= T;
  end;
  AGrid.ColWidths[ACol]:= M + MIN_COL_WIDTH;
end;



end.

