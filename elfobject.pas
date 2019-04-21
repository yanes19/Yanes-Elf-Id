unit ElfObject;

{$mode objfpc}{$H+}

interface

uses
  Classes,SysUtils,strutils;

type
 ByteArray = array of byte ;
 TElfSection = record
   s_Num : integer ;
   s_name   : string ;
   s_type   : String ;
   s_flags  : Int64 ;
   s_addr   : Int64 ;
   s_offset : Int64 ;
   s_Size   : Int64 ;
   s_link   : Int32 ;
   s_info   : Int32 ;
   s_addralign : Int64 ;
   s_entsize   : Int64 ;


 end;

function GetEntryPoint(ElfHdr : array of Byte):Int64;
function GetProgramHeaderTable(ElfHdr : array of Byte):Int64;
function GetSectionHdrTable(ElfHdr : array of Byte):Int64;
function ProgramHdrEntrySize(ElfHdr : array of Byte):integer ;
function ProgramHdrEntriesCount(ElfHdr : array of Byte):integer ;
function GetSectionHdrEntrySize(ElfHdr : array of Byte):integer ;
function GetSectionHdrEntriesCount(ElfHdr : array of Byte):integer ;
function GetSectionHdrStrIndex(ElfHdr : array of Byte):integer ;

function GetABI(ElfHdr : array of Byte):string ;
function GetMachineType(ElfHdr : array of Byte):string ;
function GetELFType(ElfHdr : array of Byte):string ;
function GetVersion(ElfHdr : array of Byte):string;

function TryReadASCII(Data: array of Byte): String ;
function readSection32(InFile :string;sectionNum :integer): TElfSection ;

function readSection64(InFile :string;sectionNum :integer): TElfSection ; //*****
function DumpSection(SecOffset,SecSize : Integer;var elffile : file):ByteArray ;

function GeSectionType(SectionType : int64):string ;
function GeSectionFlags(SectionFlags : int64):string ;


implementation


function GetEntryPoint(ElfHdr : array of Byte):Int64;
Type
Pint32 = ^int32;
var
  int64Ptr : PInt64; addrss :Pint32;
begin
   case ElfHdr[4] of
   1 :
   begin
     //new(addrss);
     addrss := @ElfHdr[24];
     result := addrss^ ;
   end;

   2 :
    begin
      GetMem(int64Ptr,SizeOf(Int64));
      int64Ptr^ := ElfHdr[24];
      result := PInt64(@ElfHdr[24])^ ;
    end;
  end;
end;

function GetProgramHeaderTable(ElfHdr : array of Byte):Int64;
Type
  Pint32 = ^int32;
  var
    int64Ptr : PInt64; addrss :Pint32;
begin
  case ElfHdr[4] of
   1 :
   begin
     //new(addrss);
     addrss := @ElfHdr[28];
     result := addrss^ ;
   end;

   2 :
    begin
      GetMem(int64Ptr,SizeOf(Int64));
      int64Ptr^ := ElfHdr[32];
      result := PInt64(@ElfHdr[32])^ ;
    end;
  end;
end;
function GetSectionHdrTable(ElfHdr : array of Byte):Int64;
Type
  Pint32 = ^int32;
  var
    int64Ptr : PInt64; addrss :Pint32;
begin
  case ElfHdr[4] of
   1 :
   begin
     //new(addrss);
     addrss := @ElfHdr[32];
     result := addrss^ ;
   end;

   2 :
    begin
      GetMem(int64Ptr,SizeOf(Int64));
      int64Ptr^ := ElfHdr[40];
      result := PInt64(@ElfHdr[40])^ ;
    end;
  end;
end;

function ProgramHdrEntrySize(ElfHdr : array of Byte):integer ;
Type
  Pint = ^int16;
  var
  addrss :Pint;
begin
  if ElfHdr[4] = 1 then
    begin
      addrss := @ElfHdr[42];
      result := addrss^ ;
    end;
  if ElfHdr[4] = 2 then
    begin
      addrss := @ElfHdr[54];
      result := addrss^ ;
    end;
end;

function ProgramHdrEntriesCount(ElfHdr : array of Byte):integer ;
Type
  Pint = ^int16;
  var
  addrss :Pint;
begin
  if ElfHdr[4] = 1 then
    begin
      addrss := @ElfHdr[44];
      result := addrss^ ;
    end;
  if ElfHdr[4] = 2 then
    begin
      addrss := @ElfHdr[56];
      result := addrss^ ;
    end;
end;

function GetSectionHdrEntrySize(ElfHdr : array of Byte):integer ;
Type
  Pint = ^int16;
  var
  addrss :Pint;
begin
  if ElfHdr[4] = 1 then
    begin
      addrss := @ElfHdr[46];
      result := addrss^ ;
    end;
  if ElfHdr[4] = 2 then
    begin
      addrss := @ElfHdr[58];
      result := addrss^ ;
    end;
end;

function GetSectionHdrEntriesCount(ElfHdr : array of Byte):integer ;
Type
  Pint = ^int16;
  var
  addrss :Pint;
begin
  if ElfHdr[4] = 1 then
    begin
      addrss := @ElfHdr[48];
      result := addrss^ ;
    end;
  if ElfHdr[4] = 2 then
    begin
      addrss := @ElfHdr[60];
      result := addrss^ ;
    end;
end;

function GetSectionHdrStrIndex(ElfHdr : array of Byte):integer ;
Type
  Pint = ^int16;
  var
  addrss :Pint;
begin
  if ElfHdr[4] = 1 then
    begin
      addrss := @ElfHdr[50];
      result := addrss^ ;
    end;
  if ElfHdr[4] = 2 then
    begin
      addrss := @ElfHdr[62];
      result := addrss^ ;
    end;
end;
function GetABI(ElfHdr : array of Byte):string ;
begin
  Case ElfHdr[7] of
  0 : Result := 'System V';
  1 : Result := 'HP-UX';
  2 : Result := 'NetBSD';
  3 : Result := 'Linux';
  6 : Result := 'Solaris';
  7 : Result := 'AIX';
  8 : Result := 'IRIX';
  9 : Result := 'FreeBSD';
  $0c : Result := 'OpenBSD';
  end;

end;

function GetMachineType(ElfHdr : array of Byte):string ;
begin
  Case ElfHdr[18] of
  $2  : Result := 'SPARC';
  $3  : Result := 'intel x86';
  $8  : Result := 'MIPS';
  $14 : Result := 'PowerPC';
  $28 : Result := 'ARM';
  $2A : Result := 'SuperH';
  $32 : Result := 'IA-64';
  $3E : Result := 'x86-64';
  $B7 : Result := 'AArch64';
  end;
end;
function GetELFType(ElfHdr : array of Byte):string ;
begin
  Case ElfHdr[$10] of
  1 : Result := 'Relocatable';
  2 : Result := 'Executable';
  3 : Result := 'Shared';
  4 : Result := 'Core dump';
  end;
end;

function GetVersion(ElfHdr : array of Byte):string; // TODO : read the non "1" version properly
begin
  if ElfHdr[$14] = 1 then Result := '1 (Orginal ELF version)'
    else Result := IntToStr(ElfHdr[$14]);
end;

 function readSection32(InFile :string;sectionNum :integer): TElfSection ;
 Type
  Pint16 = ^int16;
  Pint32 = ^int32;
 var
    SecData : TElfSection;
    ELFFile: file;
    Elf_Ehdr: array [0..64] of Byte;
    buff : array [0..7] of byte;
    buffer,SecHdr: array [0..255] of byte ;
    shstrndx_Off ,addrss: int64 ;
    i,j :integer ;
    s,secName :string ;
    int64Ptr : PInt64;
    offset :  Pint16;
    offset32 :Pint32 ;
 begin
   try
    AssignFile(ELFFile, InFile);
    Reset(ELFFile, 1  );

  except
    on E : Exception do
    begin
      s :=' Error encountered: '+E.Message;
      Exit;
    end;
  end;
  try
   BlockRead(ELFFile, Elf_Ehdr, 64);
   for i := 0 to SizeOf(Elf_Ehdr)-1 do
   s := s + IntToHex(Elf_Ehdr[i],2)+' ' ;
   s := s + sLineBreak + 'SectionHdrTable : '+Inttostr(GetSectionHdrTable(Elf_Ehdr))+
                 sLineBreak + 'i =  : ' +Inttostr(i)+
                 sLineBreak + inttostr(FilePos(ELFFile));

   //Getting an offset to the  to shstrndx section.
   Seek(ELFFile,GetSectionHdrTable(Elf_Ehdr)+
     (GetSectionHdrEntrySize(Elf_Ehdr)*GetSectionHdrStrIndex(Elf_Ehdr)) );
   s := s + sLineBreak + 'FilePos#1 sh_StrIndx sectionEntry :  ' + inttostr(FilePos(ELFFile))+ sLineBreak;
   Seek(ELFFile,FilePos(ELFFile) + 16); // seeking to whr the address is stored .
   BlockRead(ELFFile, buff, sizeof(buff));

   for i := Low(buff) to High(buff) do s := s + IntToHex(buff[i],2)+' ' ;
    shstrndx_Off := Pint32(@buff[0])^ ;
    s := s + sLineBreak + 'shstrndx_Off:  '+inttostr(shstrndx_Off)+ sLineBreak ;
    // Now ready , Let's read section #2
    //First caching the section hdr entry into "SecHdr" array.//ToDo : extend size.
    if sectionNum = 0 then addrss := GetSectionHdrTable(Elf_Ehdr) else
    addrss := GetSectionHdrTable(Elf_Ehdr)+(GetSectionHdrEntrySize(Elf_Ehdr))* sectionNum; //*2
    seek(ELFFile,addrss);
    s := s + sLineBreak + 'addrss  :  ' + inttostr(addrss)+ sLineBreak;
    BlockRead(ELFFile, SecHdr, sizeof(SecHdr));

     s := s + sLineBreak + 'FilePos#2  :  ' + inttostr(FilePos(ELFFile))+ sLineBreak;
     for i := Low(SecHdr) to High(SecHdr) do s := s + IntToHex(SecHdr[i],2)+' ' ;

     //Getting section name from e_shstrndx section
     offset32 := @SecHdr[0];
     addrss := shstrndx_Off+offset32^;
     seek(ELFFile,addrss);
     BlockRead(ELFFile,Buffer, sizeof(Buffer));
     with SecData do
     begin
     s_Num := sectionNum ;
     s_name := strpas(@Buffer[0]);
     //secName := strpas(@Buffer[0]);
     //Now Getting section type.
     offset32 := @SecHdr[4];
     s_type := GeSectionType(offset32^) ;
     //Now getting address :
     offset32 := @SecHdr[12];
     s_addr := offset32^;
     //Next, it's offset :
     offset32 := @SecHdr[16];
     s_offset := offset32^;
     //Section size :
     offset32 := @SecHdr[20];
     s_Size := offset32^;
     //Section flags :
     offset32 := @SecHdr[8];         //ToDo: flags may be merged , implement this!
     s_flags := offset32^ ; //GeSectionFlags(offset32^);
     //Section Link :
     offset32 := @SecHdr[24];
     s_link := offset32^ ;
     //Section info :
     offset32 := @SecHdr[28];
     s_info := offset32^ ;
     //Section align :
     offset32 := @SecHdr[32];
     s_addralign := offset32^;
     //Section entsize :
     offset32 := @SecHdr[36];
     s_entsize := offset32^;
     end;
    //}



  finally

  result := SecData;
  end;
 end;

 function GeSectionType(SectionType : int64):string ;
begin
  Case SectionType of
  0 : Result := 'NULL';
  1 : Result := 'PROGBITS';
  2 : Result := 'SYMTAB';
  3 : Result := 'STRTAB';
  4 : Result := 'RELA';
  5 : Result := 'HASH';
  6 : Result := 'DYNAMIC';
  7 : Result := 'NOTE';
  8 : Result := 'NOBITS';
  9 : Result := 'REL';
  10 : Result := 'SHLIB';
  // TO BE CONTINUED ...
  end;
end;

  function GeSectionFlags(SectionFlags : int64):string ;
begin
  Case SectionFlags of
  0 : Result := 'NULL';
  1 : Result := 'WRITE';
  2 : Result := 'ALLOC';
  4 : Result := 'EXECINSTR';
  $10 : Result := 'MERGE';
  $20 : Result := 'STRINGS';
  $40 : Result := 'INFO_LINK';
  $80 : Result := 'LINK_ORDER';

  // TO BE CONTINUED ...
  end;
end;

 function TryReadASCII(Data: array of Byte): String ;
var i :integer ;
  strData : string ;
begin
  for i :=0 to SizeOf(Data)-1 do
  begin
    if (Data[i]> 29) and (Data[i]< 127) then
     strData := strData + Chr(Data[i]);
  end;
  result := strData ;
end ;


 function readSection64(InFile :string;sectionNum :integer): TElfSection ;
 Type
  Pint16 = ^int16;
  Pint32 = ^int32;
 var
    SecData : TElfSection;
    ELFFile: file;
    Elf_Ehdr,SecHdr: array [0..63] of Byte;
    buff : array [0..7] of byte;
    buffer: array [0..255] of byte ;
    shstrndx_Off ,addrss: int64 ;
    i,j :integer ;
    s,secName :string ;
    int64Ptr : PInt64;
    offset :  Pint16;
    offset32 :Pint32 ;
 begin
   try
    AssignFile(ELFFile, InFile);
    Reset(ELFFile, 1  );

  except
    on E : Exception do
    begin
      s :=' Error encountered: '+E.Message;  // this message to return on Error .
      Exit;
    end;
  end;
  try
   BlockRead(ELFFile, Elf_Ehdr, 64);
   for i := 0 to SizeOf(Elf_Ehdr)-1 do
   s := s + IntToHex(Elf_Ehdr[i],2)+' ' ;
   s := s + sLineBreak + 'SectionHdrTable  : '+Inttostr(GetSectionHdrTable(Elf_Ehdr))+
                 sLineBreak + 'i =  : ' +Inttostr(i)+
                 sLineBreak + inttostr(FilePos(ELFFile));

   //Reset(ELFFile, 1 );

   Seek(ELFFile,GetSectionHdrTable(Elf_Ehdr)+
     (GetSectionHdrEntrySize(Elf_Ehdr)*GetSectionHdrStrIndex(Elf_Ehdr)) );
   s := s + sLineBreak + 'FilePos (beginning of sh_strndx):  ' + inttostr(FilePos(ELFFile))+ sLineBreak;
   Seek(ELFFile,FilePos(ELFFile) + 24);
   BlockRead(ELFFile, buff, sizeof(buff));

   for i := Low(buff) to High(buff) do s := s + IntToHex(buff[i],2)+' ' ;
    shstrndx_Off := PInt64(@buff[0])^ ;
    s := s + sLineBreak + 'shstrndx_Off:  '+inttostr(shstrndx_Off)+ sLineBreak ;
    // Now ready , Let's read section #2
    //First caching the section hdr entry into "SecHdr" array.//ToDo : extend size. (done to :256, check if sufficent !)===> currently erronous try 64 !
    if sectionNum = 0 then addrss := GetSectionHdrTable(Elf_Ehdr) else
    addrss := GetSectionHdrTable(Elf_Ehdr)+(GetSectionHdrEntrySize(Elf_Ehdr))* sectionNum; //*2
    seek(ELFFile,addrss);
    BlockRead(ELFFile, SecHdr, sizeof(SecHdr));
    s := s + sLineBreak + 'FilePos  :  ' + inttostr(FilePos(ELFFile))+ sLineBreak;
    for i := Low(SecHdr) to High(SecHdr) do s := s + IntToHex(SecHdr[i],2)+' ' ;
    //Getting section name from e_shstrndx section
    offset32 := @SecHdr[0];
     addrss := shstrndx_Off+offset32^;

     seek(ELFFile,addrss);
     BlockRead(ELFFile,Buffer, sizeof(Buffer));
     with SecData do
     begin
     s_Num := sectionNum ;
     //secName := strpas(@Buffer[0]);
     s_name := strpas(@Buffer[0]);
     //Now Getting section type.
     offset32 := @SecHdr[4];
     s_type := GeSectionType(offset32^) ;
     //Now getting address :
     int64Ptr := @SecHdr[16];
     s_addr := int64Ptr^;
     //Next, it's offset :
     int64Ptr := @SecHdr[24];
     s_offset := int64Ptr^;
     //Section size :
     int64Ptr := @SecHdr[32];
     s_Size := int64Ptr^;
     //Section flags :
     int64Ptr := @SecHdr[8];         //ToDo: flags may be merged , implement this!
     s_flags := int64Ptr^ ;//GeSectionFlags(int64Ptr^);    // For now let's return as int64 ;)  !
     //Section Link :
     offset32 := @SecHdr[40];
     s_link := offset32^ ;
     //Section info :
     offset32 := @SecHdr[44];
     s_info := offset32^ ;
     //Section align :
     int64Ptr := @SecHdr[48];
     s_addralign := int64Ptr^;
     //Section entsize :
     int64Ptr := @SecHdr[56];
     s_entsize := int64Ptr^;
     end;
  finally
  //Rmember to close all open files .
  result := SecData;
  end;
 end;
 function DumpSection(SecOffset,SecSize : Integer;var elffile : file):ByteArray ;
 var buffer : array of byte ;
 begin
  Setlength(buffer,sizeof(Byte)*SecSize);
  //fillchar(buffer,SecSize-1,0);
  seek(elffile,SecOffset);
  BlockRead(elffile,buffer[0],SecSize );
  //for i := min(buffer) to max(buffer) do
  result := buffer ;
 end;



end.

