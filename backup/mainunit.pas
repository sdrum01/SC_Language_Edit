unit MainUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Grids, Menus, types;

type

  { TForm1 }

  TForm1 = class(TForm)
    B_help: TButton;
    Button_merge: TButton;
    Button3: TButton;
    Button_save: TButton;
    CB_empty: TCheckBox;
    Edit_search: TEdit;
    Edit_src: TEdit;
    Edit_dst: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    MainMenu1: TMainMenu;
    MenuFile: TMenuItem;
    MenuFile_OpenSrc: TMenuItem;
    MenuFile_OpenDst: TMenuItem;
    MenuFile_SaveDst: TMenuItem;
    MenuFile_ExportSrc: TMenuItem;
    MenuFile_ImportCsv: TMenuItem;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    OpenDialog1: TOpenDialog;
    Label_wait: TStaticText;
    SaveDialog1: TSaveDialog;
    StringGrid1: TStringGrid;
    procedure Button_mergeClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);

    procedure Button_saveClick(Sender: TObject);
    procedure B_helpClick(Sender: TObject);
    procedure CB_emptyChange(Sender: TObject);
    //procedure Edit_dstChange(Sender: TObject);

    procedure Edit_dstClick(Sender: TObject);
    procedure Edit_searchKeyPress(Sender: TObject; var Key: char);
    procedure Edit_srcClick(Sender: TObject);

    procedure chooseSource();
    procedure chooseDestination();

    procedure FormCreate(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
    procedure FormResize(Sender: TObject);
    procedure load_source(filename: string);
    procedure load_destination(filename: string);
    procedure MenuFile_ExportSrcClick(Sender: TObject);
    procedure MenuFile_ImportCsvClick(Sender: TObject);


    procedure saveDestination();

    procedure MenuFile_OpenDstClick(Sender: TObject);
    procedure MenuFile_OpenSrcClick(Sender: TObject);
    procedure MenuFile_SaveDstClick(Sender: TObject);

    procedure merge;

    procedure StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);

    procedure sourceToCsv(FileName:string);
    procedure csvToDestination(FileName:string);

    procedure exportSource();

    procedure exportFile(FileName:string);
    procedure importCSV();


    procedure Clear_translation;
    procedure Clear_all;
    procedure search_in_list(s : string);
    procedure filter;
    procedure StringGrid1EndDrag(Sender, Target: TObject; X, Y: Integer);

    procedure StringGrid1KeyPress(Sender: TObject; var Key: char);
    procedure StringGrid1MouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);



  private
    { private declarations }
  public
    { public declarations }
  end;



var
  Form1: TForm1;
  key_languagefile_dst : string;
  //arr_lines : array of integer;




implementation

//uses PRG_info;

{$R *.lfm}

uses
  resource, versiontypes, versionresource;

 FUNCTION resourceVersionInfo: STRING;

 (* Unlike most of AboutText (below), this takes significant activity at run-    *)
 (* time to extract version/release/build numbers from resource information      *)
 (* appended to the binary.                                                      *)

 VAR     Stream: TResourceStream;
         vr: TVersionResource;
         fi: TVersionFixedInfo;
         eol : string;
 BEGIN
   RESULT:= '';
   eol := '';
   TRY

 (* This raises an exception if version info has not been incorporated into the  *)
 (* binary (Lazarus Project -> Project Options -> Version Info -> Version        *)
 (* numbering).                                                                  *)

     Stream:= TResourceStream.CreateFromID(HINSTANCE, 1, PChar(RT_VERSION));
     TRY
       vr:= TVersionResource.Create;
       TRY
         vr.SetCustomRawDataStream(Stream);
         fi:= vr.FixedInfo;
         {
         RESULT := 'Version ' + IntToStr(fi.FileVersion[0]) + '.' + IntToStr(fi.FileVersion[1]) +
                ' release ' + IntToStr(fi.FileVersion[2]) + ' build ' + IntToStr(fi.FileVersion[3]) + eol;
         }
         RESULT := 'Version ' + IntToStr(fi.FileVersion[0]) + '.' + IntToStr(fi.FileVersion[1])+ '.' +
         IntToStr(fi.FileVersion[2]) + '.'+ IntToStr(fi.FileVersion[3]);
         vr.SetCustomRawDataStream(nil)
       FINALLY
         vr.Free
       END
     FINALLY
       Stream.Free
     END
   EXCEPT
   END
 END { resourceVersionInfo } ;

function Split(Delimiter: char; Str: string): TStringList;
var
  ListOfStrings: TStringList;
  i: integer;
  s_temp: string;
  alreadyfound : boolean;
begin
  ListOfStrings := TStringList.Create;
  alreadyfound := false;
  s_temp := '';
  if (Str <> '') then
  begin
    for i := 0 to length(Str) do
    begin
      if (i < length(Str)) then
      begin
        if ((Delimiter = Str[i]) and (alreadyfound = false)) then
        begin
          ListOfStrings.Add(trim(s_temp));
          alreadyfound := true;
          s_temp := '';
        end
        else
        begin
          // ListOfStrings.Add(trim(s_temp));
          // wenn das letzte Zeichen der Trenner ist, nicht übernehmen


          s_temp += Str[i];
        end;

      end
      else
      begin
        if (Delimiter <> Str[i]) then
        s_temp += Str[i];
        ListOfStrings.Add(trim(s_temp));
        s_temp := '';
      end;



    end;
  end;
  Result := ListOfStrings;
end;


{ TForm1 }


procedure TForm1.load_source(filename: string);
var
  //dst:TIniFile;
  F1: TextFile;
  s, actual_key, subkey, value: string;
  row: TStringList;
  i,i1: integer;
begin

  Clear_all;
  label_wait.Visible:= true;
  Application.ProcessMessages;
  actual_key := '';
  subkey := '';
  value := '';

  //SetLength(arr_lines, 0); // IndexListe dargestellten Werten

  row := TStringList.Create;
  i := 0;
  i1 := 0;
  if FileExists(filename) then

  begin
    StringGrid1.BeginUpdate;
    try
      AssignFile(F1, filename);
      Reset(F1);
      while not EOF(F1) do
      begin
        Inc(i);
        ReadLn(F1, s);
        s := trim(s);
        if (copy(s,1,1) = '[') and (copy(s,length(s),1) = ']') then
        // jetzt haben wir den Schlüssel
        begin
          actual_key := copy(s,2,length(s)-2);
          // Trenner ohne Inhalt
          inc(i1);
          StringGrid1.RowCount := i1+1;
          StringGrid1.Cells[4,i1] := format('%.5d',[i1]);
        end;
        if (Pos('=',s) > 0) then
        begin
          row := Split('=', s);
          try
             if(row.Count > 0) then subkey := row[0] else subkey := '';
             if(row.Count > 1) then value := row[1] else value := '';
             // ausgefüllte Zeilen
             inc(i1);
             StringGrid1.RowCount := i1+1;
             StringGrid1.Cells[0,i1] := actual_key;
             StringGrid1.Cells[1,i1] := subkey;
             StringGrid1.Cells[2,i1] := value;
             StringGrid1.Cells[4,i1] := format('%.5d',[i1]);

             // IndexListe dargestellten Werten füllen (zum Springen der Felder mit Enter)
             // SetLength(arr_lines, length(arr_lines)+1);
             // arr_lines[length(arr_lines)-1] := i1; // Zeilennummer merken als Index
          finally
          end;


        end;

      end;
      CloseFile(F1);
    except
      on E: Exception do
        ShowMessage(E.Message);
    end;
  StringGrid1.EndUpdate(true);
  end
  else
    begin

      ShowMessage('File not Found: ' + filename);
      label_wait.Visible:= false;
    end;
  row.Free;

  label_wait.Visible:= false;
end;


procedure TForm1.load_destination(filename: string);
var
  F1: TextFile;
  s, actual_key, subkey, value, key_src, subkey_src, value_src: string;
  row: TStringList;
  i,i1: integer;
begin
  Clear_translation;
  label_wait.Visible:= true;
  Application.ProcessMessages;
  if FileExists(filename) then
  begin
    StringGrid1.BeginUpdate;
    try
      AssignFile(F1, filename);
      Reset(F1);
      i := 0;
      i1 := 0;
      while not EOF(F1) do
      begin
        Inc(i);
        ReadLn(F1, s);
        s := trim(s);
        // Erste Zeile ist immer der Key des Files und darf nicht übersetzt werden
        if(i = 1)and(s <> '')then
        begin
          key_languagefile_dst := s;
          //StringGrid1.Cells[3,0] := s;
        end;
        if (copy(s,1,1) = '[') and (copy(s,length(s),1) = ']') then
        // jetzt haben wir den Schlüssel
        begin
          actual_key := copy(s,2,length(s)-2);
        end;
        subkey := '';
        value := '';

        if (Pos('=',s) > 0) then
        begin
          row := Split('=', s);
          try
             if(row.Count > 0) then subkey := row[0];
             if(row.Count > 1) then value := row[1];

             // durchlaufen des Grid und suchen des Wertes
             for i1 := 1 to StringGrid1.RowCount-1 do
             begin

                key_src := StringGrid1.Cells[0,i1];
                subkey_src := StringGrid1.Cells[1,i1];
                value_src := StringGrid1.Cells[2,i1];

                if ((key_src = actual_key) and (subkey_src = subkey))then
                begin
                   StringGrid1.Cells[3,i1] := value;
                end;
             end;
          finally
          end;
        end;

      end;
      CloseFile(F1);
      Button_save.Enabled := true;
    except
      on E: Exception do
        ShowMessage(E.Message);
    end;
    StringGrid1.EndUpdate(true);
  end
  else
    begin
      label_wait.Visible:= false;
      ShowMessage('File not Found: ' + filename);
    end;
  row.Free;
  label_wait.Visible:= false;
end;

procedure TForm1.MenuFile_ExportSrcClick(Sender: TObject);
begin
  exportSource();
end;

procedure TForm1.MenuFile_ImportCsvClick(Sender: TObject);
begin
  importCSV();
end;

procedure TForm1.MenuFile_SaveDstClick(Sender: TObject);
begin
  saveDestination();
end;


procedure TForm1.MenuFile_OpenDstClick(Sender: TObject);
begin
  chooseDestination();
end;


procedure TForm1.MenuFile_OpenSrcClick(Sender: TObject);
begin
  chooseSource();
end;

procedure TForm1.merge;
var
  value_src, value_dst: string;
  i1: integer;
begin
  label_wait.Visible:= true;
  Application.ProcessMessages;
  StringGrid1.BeginUpdate;
  for i1 := 1 to StringGrid1.RowCount-1 do
    begin
      value_src := StringGrid1.Cells[2,i1];
      value_dst := StringGrid1.Cells[3,i1];
      if ((value_src <> '') and (value_dst = ''))then
      begin
        StringGrid1.Cells[3,i1] := value_src;
      end;
    end;
  StringGrid1.EndUpdate(true);
  label_wait.Visible:= false;
end;



procedure TForm1.StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
var
  value_src, value_dst: string;
begin
  //SetLength(arr_emptyvalues,0); // Liste mit zu ändernden Werten löschen
  if (aCol = 3) and (aRow > 0) then
  begin
    value_dst := StringGrid1.Cells[3,aRow];
    value_src := StringGrid1.Cells[2,aRow];
    if (value_dst = '') and (value_src <> '') then
    begin
      with TStringGrid(Sender).Canvas do
      begin
         Brush.Color:= clRed;
         FillRect(aRect);
         //SetLength(arr_emptyvalues, SizeOf(arr_emptyvalues)+1); // Liste mit zu ändernden Werten neu
         //arr_emptyvalues[SizeOf(arr_emptyvalues)-1] := aRow;
         //TextOut(aRect.Left+2,aRect.top+2,StringGrid1.Cells[aCol,aRow]);
      end;
    end;
    if (value_dst = value_src) and (value_src <> '')then
    begin
      with TStringGrid(Sender).Canvas do
      begin
         Brush.Color:= clYellow;
         FillRect(aRect);
         //Pen.Color := clGreen;
         TextOut(aRect.Left+3,aRect.top,StringGrid1.Cells[aCol,aRow]);
         //SetLength(arr_emptyvalues, SizeOf(arr_emptyvalues)+1); // Liste mit zu ändernden Werten neu
         //arr_emptyvalues[SizeOf(arr_emptyvalues)-1] := aRow;
      end;
    end;
  end;


end;

procedure TForm1.exportFile(FileName:string);
var i1 : integer;
  key, key_bak, subkey, value : string;
  F1:textfile;
begin
  //If Not FileExists(FileName) then
  //begin
  label_wait.Visible:= true;
  Application.ProcessMessages;
  try
      AssignFile(F1,FileName);
      ReWrite(F1);
      CloseFile(F1);
  finally
      //CloseFile(F1);
  end;
  //end;
  try
    AssignFile(F1,FileName);
    Append(F1);
    //WriteLn(F1,#13#10+DateToStr(now)+'-'+TimeToStr(now)+ #$9);
    key_bak := '';
    // Key der Textdatei global drüberschreiben
    WriteLn(F1,key_languagefile_dst);
    //WriteLn(F1,'');

    for i1 := 1 to StringGrid1.RowCount-1 do
    begin
      key := StringGrid1.Cells[0,i1];
      subkey := StringGrid1.Cells[1,i1];
      value := StringGrid1.Cells[3,i1];
      if((key_bak <> key) and (key <> '')) then
      begin
        WriteLn(F1,'['+key+']');
      end;
      if(subkey <> '') then
      begin
        WriteLn(F1,subkey+'='+value);
      end else
      begin
        WriteLn(F1,'');
      end;

      key_bak := key;

    end;
    CloseFile(F1);
    ShowMessage('Export File saved as '+ FileName);
  except
    on E: Exception do ShowMessage(E.Message);
  end;
  label_wait.Visible:= false;
end;

// Export entries in Source Stringlist as CSV File in Format
// [KEY]
// subkey=myvalue
//
// ID;Text;Context
// KEY_subkey;myvalue;KEY

procedure TForm1.sourceToCsv(FileName:string);
var i1 : integer;
  key, subkey, value : string;
  F1:textfile;
begin
  label_wait.Visible:= true;
  Application.ProcessMessages;
  try
      AssignFile(F1,FileName);
      ReWrite(F1);
      CloseFile(F1);
  finally
      //
  end;

  try
    AssignFile(F1,FileName);
    Append(F1);

    WriteLn(F1,'ID;Text;Key;Subkey');

    for i1 := 1 to StringGrid1.RowCount-1 do
    begin

      key := StringGrid1.Cells[0,i1];
      subkey := StringGrid1.Cells[1,i1];
      value := StringGrid1.Cells[2,i1];
      value := StringReplace(value, '"', '''',[rfReplaceAll, rfIgnoreCase]);

      if(subkey <> '') then
      begin
        WriteLn(F1,key+'_'+subkey+';"'+value+'";'+key+';'+subkey);
      end;
    end;
    CloseFile(F1);
    ShowMessage('Export File saved as '+ FileName);
  except
    on E: Exception do ShowMessage(E.Message);
  end;
  label_wait.Visible:= false;
end;


procedure Split(Delimiter: Char; Str: string; ListOfStrings: TStrings) ;
begin
   ListOfStrings.Clear;
   ListOfStrings.Delimiter       := Delimiter;
   ListOfStrings.StrictDelimiter := True; // Requires D2006 or newer.
   ListOfStrings.DelimitedText   := Str;
end;

// Import entries in translated Destination CSV into the Dest.Stringlist

procedure TForm1.csvToDestination(FileName:string);
var
  F1: TextFile;
  //csvList: TStringList;
  s, subkey, value, key_src, subkey_src, value_src, csvID, csvText, csvKey, csvSubkey: string;
  row: TStringList;
  i,i1: integer;
begin

  Clear_translation;
  label_wait.Visible:= true;
  Application.ProcessMessages;
  if FileExists(filename) then
  begin
    StringGrid1.BeginUpdate;
    try
      AssignFile(F1, filename);
      Reset(F1);
      i := 0;
      i1 := 0;
      while not EOF(F1) do
      begin
        Inc(i);
        ReadLn(F1, s);
        s := trim(s);

        row := TStringList.Create;
        try
          row.Delimiter:= ';';
          row.DelimitedText := s;
          //Split(';', s, row);

          try
            csvID := '';
            csvText := '';
            csvKey := '';
            csvSubKey := '';

            csvID := row[0];
            csvText := row[1];
            csvKey := row[2];
            csvSubKey := row[3];

              try

                 // durchlaufen des Grid und suchen des Wertes
                 for i1 := 1 to StringGrid1.RowCount-1 do
                 begin

                    key_src := StringGrid1.Cells[0,i1];
                    subkey_src := StringGrid1.Cells[1,i1];
                    value_src := StringGrid1.Cells[2,i1];

                    if ((key_src = csvKey) and (subkey_src = csvSubkey))then
                    begin
                       StringGrid1.Cells[3,i1] := csvText;
                    end;

                 end;

              except
                on E: Exception do ShowMessage(E.Message);
              end;
          finally

          end;

        finally
          row.Free;
        end;

         ////




      end;
      CloseFile(F1);
      Button_save.Enabled := true;
    except
      on E: Exception do
        ShowMessage(E.Message);
    end;
    StringGrid1.EndUpdate(true);
  end
  else
    begin
      label_wait.Visible:= false;
      ShowMessage('File not Found: ' + filename);
    end;

  label_wait.Visible:= false;
end;




procedure TForm1.Button_mergeClick(Sender: TObject);
begin
  merge;
end;


procedure TForm1.Clear_translation;
var i1 : integer;
begin
   for i1 := 1 to StringGrid1.RowCount-1 do
   begin
       StringGrid1.Cells[3,i1] := '';
   end;
end;

procedure TForm1.Clear_all;

begin
   StringGrid1.RowCount:= 1;
end;

// Choose Destinationfile per Savedialog
procedure TForm1.saveDestination();
begin
  If (FileExists(Edit_dst.Text)) then
  begin
    {
    new_filename := ExtractFilePath(Edit_dst.Text)+'\'+ChangeFileExt(ExtractFileName(Edit_dst.Text), '')+'_new'+ExtractFileExt(Edit_dst.Text);
    if(fileExists(new_filename))then
    begin
      if MessageDlg('File already exists:' + new_filename + ' Overwrite?',
      mtConfirmation, [mbNo, mbYes], 0) = mrYes then ExportFile(new_filename);
    end else
    begin
         ExportFile(new_filename);
    end;
    }
    SaveDialog1.InitialDir := ExtractFilePath(Edit_dst.Text);
    SaveDialog1.FileName := ChangeFileExt(ExtractFileName(Edit_dst.Text), '')+'_translated'+ExtractFileExt(Edit_dst.Text);
    if SaveDialog1.Execute then
    begin
      if(fileExists(SaveDialog1.FileName))then
      begin
        if MessageDlg('File already exists:' + SaveDialog1.FileName + ' Overwrite?',
        mtConfirmation, [mbNo, mbYes], 0) = mrYes then ExportFile(SaveDialog1.FileName);
      end else
      begin
        ExportFile(SaveDialog1.FileName);
      end;
    end;
  end;
end;

// Choose CSV-Exportfile per SafeDialog
procedure TForm1.exportSource();
begin
  If (FileExists(Edit_src.Text)) then
  begin
    SaveDialog1.InitialDir := ExtractFilePath(Edit_src.Text);
    SaveDialog1.FileName := ChangeFileExt(ExtractFileName(Edit_src.Text), '')+'_export.csv';
    if SaveDialog1.Execute then
    begin
      if(fileExists(SaveDialog1.FileName))then
      begin
        if MessageDlg('File already exists:' + SaveDialog1.FileName + ' Overwrite?',
        mtConfirmation, [mbNo, mbYes], 0) = mrYes then sourceToCSV(SaveDialog1.FileName);
      end else
      begin
        sourceToCSV(SaveDialog1.FileName);
      end;
    end;
  end;
end;

// Choose CSV-Exportfile per SafeDialog
procedure TForm1.importCSV();
begin
  If (FileExists(Edit_src.Text)) then
  begin
    //OpenDialog1.InitialDir := ExtractFilePath(Edit_src.Text);
    OpenDialog1.DefaultExt:= 'csv';
    if OpenDialog1.Execute then
    begin
       csvToDestination(OpenDialog1.FileName);
    end;
  end;
end;


procedure TForm1.Button_saveClick(Sender: TObject);
begin
  saveDestination();
end;

procedure TForm1.B_helpClick(Sender: TObject);
begin
  ShowMessage('Safecontrol Language Edit '+ #10#13 +resourceVersionInfo+ #10#13 + 'Gunnebo Markersdorf 2016 (D.H.)');
end;

procedure TForm1.CB_emptyChange(Sender: TObject);
begin
  filter;
end;






procedure TForm1.filter;
var i1 :integer;
begin
  Label_wait.Visible:= true;
  Application.ProcessMessages;
  // Indexliste löschen
  // SetLength(arr_lines, 0);

  StringGrid1.BeginUpdate;
  for i1 := 1 to StringGrid1.RowCount-1 do
    begin
      if(CB_empty.Checked = true)then
      begin
        if ((StringGrid1.Cells[3,i1] = '') and (StringGrid1.Cells[2,i1] <> '') )
        or ((StringGrid1.Cells[3,i1] = StringGrid1.Cells[2,i1]) and (StringGrid1.Cells[2,i1] <> '') )
        then
        begin
          StringGrid1.RowHeights[i1] := 17;
          // wird dargestellt, also rein in die Indexliste
          // SetLength(arr_lines, length(arr_lines)+1);
          // arr_lines[length(arr_lines)-1] := i1; // Zeilennummer merken als Index
        end else
        begin
          StringGrid1.RowHeights[i1] := 0;
        end;
      end else
      begin
        StringGrid1.RowHeights[i1] := 17;
        // SetLength(arr_lines, length(arr_lines)+1);
        // arr_lines[length(arr_lines)-1] := i1; // Zeilennummer merken als Index
      end;


    end;
  StringGrid1.EndUpdate(true);
  Label_wait.Visible:= false;
end;

procedure TForm1.StringGrid1EndDrag(Sender, Target: TObject; X, Y: Integer);
begin

end;


procedure TForm1.StringGrid1KeyPress(Sender: TObject; var Key: char);
begin
  {
  If (char(Key) = #13) and (StringGrid1.Selection.Left = 3) then
  begin

    with StringGrid1 do
    begin

        if Row < RowCount -1 then
        begin //Nächste Zeile
            Row := Row +1;
            Col := 2;
        end else
        begin //Geh wieder an den Anfang des Grids
            Row := 1;
            Col := 2;
        end;
    end;
  end;
  }
end;


procedure TForm1.StringGrid1MouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin

  if StringGrid1.Col <> 3 then
  begin
    // 20er Sprünge wenn nicht ein editierbares Feld gewählt
    if (WheelDelta < 0) and (StringGrid1.Row < StringGrid1.RowCount) then
      StringGrid1.Row := StringGrid1.Row + 19;
    if (WheelDelta > 0) and (StringGrid1.Row > 0) then
      StringGrid1.Row := StringGrid1.Row - 19;
  end;


end;


procedure TForm1.Edit_srcClick(Sender: TObject);
begin
  chooseSource();
end;



procedure TForm1.chooseSource();
begin
 Label_wait.Visible:= true;
  Application.ProcessMessages;
  If OpenDialog1.Execute then
  begin
    Edit_src.Text:= OpenDialog1.FileName;
    load_source(Edit_src.Text);
  end;
  Label_wait.Visible:= false;

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  key_languagefile_dst := '';
end;

procedure TForm1.FormDropFiles(Sender: TObject; const FileNames: array of String
  );
//var
  //intI: integer = 0;
begin

  //for intI := 0 to high(filenames) do
  //  listbox1.Items.Add(filenames[intI]);
  If not FIleExists(Edit_src.Text) then
  begin
       Edit_src.Text := filenames[0];
       Label_wait.Visible:= true;
       Application.ProcessMessages;
       load_source(Edit_src.Text);
       Label_wait.Visible:= false;
  end else
  begin
       If not FIleExists(Edit_dst.Text) then
       begin
         Edit_dst.Text := filenames[0];
         Label_wait.Visible:= true;
         Application.ProcessMessages;
         Load_destination(Edit_dst.Text);
         Label_wait.Visible:= false;
       end;
  end;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  StringGrid1.Height:= Form1.Height - 55;
  StringGrid1.Width:= Form1.width - 15;
end;

procedure TForm1.Edit_dstClick(Sender: TObject);
begin
  chooseDestination();
end;

procedure TForm1.chooseDestination();
begin
  Label_wait.Visible:= true;
  Application.ProcessMessages;
  If OpenDialog1.Execute then
  begin
    Edit_dst.Text:= OpenDialog1.FileName;
    Load_destination(Edit_dst.Text);
  end;
  Label_wait.Visible:= false;

end;

procedure TForm1.Edit_searchKeyPress(Sender: TObject; var Key: char);
begin
  If Key = #13 then
    begin
      search_in_list(Edit_Search.Text);
    end;
end;



procedure TForm1.Button3Click(Sender: TObject);
begin
  search_in_list(Edit_Search.Text);
end;

procedure TForm1.search_in_list(s : string);
var i1 : integer;
  key, subkey, val1, val2: string;
begin
  Label_wait.Visible:= true;
  Application.ProcessMessages;
  CB_empty.Checked:= false;

  // Indexliste löschen
  // SetLength(arr_lines, 0);

  StringGrid1.BeginUpdate;
  for i1 := 1 to StringGrid1.RowCount-1 do
  begin

    if (s <> '')then
    begin
      key := AnsiLowerCase(StringGrid1.Cells[0,i1]);
      subkey := AnsiLowerCase(StringGrid1.Cells[1,i1]);
      val1 := AnsiLowerCase(StringGrid1.Cells[2,i1]);
      val2 := AnsiLowerCase(StringGrid1.Cells[3,i1]);
      s := AnsiLowerCase(s);
      if (pos(s, key   ) > 0)
      or (pos(s, subkey) > 0)
      or (pos(s, val1) > 0)
      or (pos(s, val2) > 0)

      then
      begin
        StringGrid1.RowHeights[i1] := 17;
        // Indexliste
        // SetLength(arr_lines, length(arr_lines)+1);
        // arr_lines[length(arr_lines)-1] := i1; // Zeilennummer merken als Index
      end else
      begin
        StringGrid1.RowHeights[i1] := 0;
      end;
    end else // Wenn Suchbegriff leer, wird eh alles dargestellt
    begin
      StringGrid1.RowHeights[i1] := 17;
      // Indexliste
      // SetLength(arr_lines, length(arr_lines)+1);
      // arr_lines[length(arr_lines)-1] := i1; // Zeilennummer merken als Index
    end;


  end;
  StringGrid1.EndUpdate(true);
  Label_wait.Visible:= false;
end;




end.

