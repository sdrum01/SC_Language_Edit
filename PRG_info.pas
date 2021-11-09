// procedure info zeigt ein Infofenster an

unit PRG_info;

interface
 uses windows, dialogs, SysUtils, Forms;

 function GetBuildInfo(const AFilename:String; var V1,V2,V3,V4:Word):Boolean;
 function BuildInfo(Application:String): String ;
 procedure info(text : string);

implementation
uses MainUnit;


function GetBuildInfo(const AFilename:String; var V1,V2,V3,V4:Word):Boolean;
var
   VerInfoSize  : Integer;
   VerValueSize : DWord;
   Dummy        : DWord;
   VerInfo      : Pointer;
   VerValue     : PVSFixedFileInfo;
begin
  VerInfoSize:=GetFileVersionInfoSize(PChar(AFilename),Dummy);
  Result:=False;
  if VerInfoSize<>0 then begin
    GetMem(VerInfo,VerInfoSize);
    try
      if GetFileVersionInfo(PChar(AFilename),0,VerInfoSize,VerInfo) then begin
        if VerQueryValue(VerInfo,'\',Pointer(VerValue),VerValueSize) then
         with VerValue^ do begin
          V1:=dwFileVersionMS shr 16;
          V2:=dwFileVersionMS and $FFFF;
          V3:=dwFileVersionLS shr 16;
          V4:=dwFileVersionLS and $FFFF;
        end;
        Result:=True;
      end;
    finally
      FreeMem(VerInfo,VerInfoSize);
    end;
  end;
end; {Peter Haas}

function BuildInfo(Application:String): String ;
var
v1,v2,v3,v4 : word;
begin
 GetBuildInfo(Application, v1,v2,v3,v4);
 Result:= Format('%d.%d.%d.%d',[V1,V2,V3,V4]);
end;

procedure info(text : String);
var s, Date: String;
begin
s:= BuildInfo(Application.ExeName);
 Date := DateToStr(FileDateToDateTime(FileAge(Application.ExeName)));
 ShowMessage(MainForm.Caption+#10#13+#10#13+'Build: '+ s +#10#13+
 'CompileDate: '+Date +#10#13+'von Dirk Hanisch'+#10#13+#10#13+
 Text);
end;




end.

 