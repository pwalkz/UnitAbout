{
  Master About
  Copyright (c) 2026 Peter Walker pwalkz@gmail.com

  This source code is licensed under the MIT License.
  See the LICENSE file in the root directory of this source tree
  for the full license terms.
}

unit mainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ComCtrls, UnitAbout, IniFiles;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnAbout: TButton;
    MemoHeader: TMemo;
    MemoVI: TMemo;
    MemoMIT: TMemo;
    MemoAbout: TMemo;
    PageControl1: TPageControl;
    Panel1: TPanel;
    TabSheet_VersionInfo: TTabSheet;
    TabSheet_MIT_License: TTabSheet;
    TabSheet_AboutInfo: TTabSheet;
    TabSheet_MIT_Header: TTabSheet;
    procedure btnAboutClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    function GetConfigFileName: String;
    procedure LoadConfiguration;
    procedure SaveConfiguration;
    procedure InitInfo;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.btnAboutClick(Sender: TObject);
begin
  AboutForm.ShowModal;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  SaveConfiguration;
end;

procedure TForm1.InitInfo;
var
  Str: string;
begin
  LoadConfiguration;

  // Set the Font Values
  MemoVI.Font.Name := GetUniversalFont();
  MemoVI.Color := clNavy;
  MemoVI.Font.Color := clAqua;
  MemoVI.Font.Style := [fsBold];


  // Add Header
  MemoVI.Clear;
  MemoVI.Lines.Add('------------------------------------');
  Str := ' -- Poject Options | Version Info --';
  MemoVI.Lines.Add(Str);
  MemoVI.Lines.Add('------------------------------------');

  // Add all Version Info Fields F0 to F9
  Str := ReadVersionInfo();
  Str := Trim(Str);
  MemoVI.Lines.Add(Str);

  MemoMIT.Font.Name := GetUniversalFont();

  // Insert function at top of memo
  MemoAbout.Lines.Insert(0, 'function GetAboutStr();');
  // Set the Font Values
  MemoAbout.Font.Name := GetUniversalFont();
  MemoAbout.Text := GetAboutStr();
  MemoAbout.Color := clNavy;
  MemoAbout.Font.Color := clAqua;
  MemoAbout.Font.Style := [fsBold];

  MemoHeader.Font.Name := GetUniversalFont();
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  InitInfo;
end;

{ Helper to get path: AppName.ini in the application directory }
function TForm1.GetConfigFileName: String;
begin
  // Standard location next to the executable
 // Result := ChangeFileExt(Application.ExeName, '.ini');

  // Optional: If you prefer saving in User Config Directory (recommended for modern OS permissions):
   Result := GetAppConfigFile(False,True);  // (Global, SubDir)
end;


procedure TForm1.LoadConfiguration;
var
  Ini: TIniFile;
  SavedLeft, SavedTop, SavedWidth, SavedHeight: Integer;
  IsMaximized: Boolean;
begin
  Ini := TIniFile.Create(GetConfigFileName);
  try
    // Read window bounds (with current form properties as defaults)
    SavedLeft   := Ini.ReadInteger('Window', 'Left', Left);
    SavedTop    := Ini.ReadInteger('Window', 'Top', Top);
    SavedWidth  := Ini.ReadInteger('Window', 'Width', Width);
    SavedHeight := Ini.ReadInteger('Window', 'Height', Height);
    IsMaximized := Ini.ReadBool('Window', 'Maximized', False);

    // Apply Size and Position
    Position := poDesigned; // Ensure Position property doesn't override manual positioning
    SetBounds(SavedLeft, SavedTop, SavedWidth, SavedHeight);

    // Ensure the window is placed inside visible screen bounds (prevents off-screen load)
    if Left < Screen.DesktopLeft then Left := Screen.DesktopLeft;
    if Top < Screen.DesktopTop then Top := Screen.DesktopTop;
    if Left + Width > Screen.DesktopWidth then Left := Screen.DesktopWidth - Width;
    if Top + Height > Screen.DesktopHeight then Top := Screen.DesktopHeight - Height;

    // Restore Window State
    if IsMaximized then
      WindowState := wsMaximized
    else
      WindowState := wsNormal;

  finally
    Ini.Free;
  end;
end;

procedure TForm1.SaveConfiguration;
var
  Ini: TIniFile;
begin
  // Make sure directory exists if saving to AppConfigDir
  ForceDirectories(ExtractFilePath(GetConfigFileName));

  Ini := TIniFile.Create(GetConfigFileName);
  try
    // Save state
    Ini.WriteBool('Window', 'Maximized', WindowState = wsMaximized);

    // Only save normal bounds if not minimized/maximized to retain restore size
    if WindowState = wsNormal then
    begin
      Ini.WriteInteger('Window', 'Left', Left);
      Ini.WriteInteger('Window', 'Top', Top);
      Ini.WriteInteger('Window', 'Width', Width);
      Ini.WriteInteger('Window', 'Height', Height);
    end
    else
    begin
      Ini.WriteInteger('Window', 'Left', RestoredLeft);
      Ini.WriteInteger('Window', 'Top', RestoredTop);
      Ini.WriteInteger('Window', 'Width', RestoredWidth);
      Ini.WriteInteger('Window', 'Height', RestoredHeight);
    end;
  finally
    Ini.Free;
  end;
end;

end.
