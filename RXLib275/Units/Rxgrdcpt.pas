{*******************************************************}
{                                                       }
{     Delphi VCL Extensions (RX)                        }
{                                                       }
{     Copyright (c) 1997 Master-Bank                    }
{     Copyright (c) 1998 Ritting Information Systems    }
{                                                       }
{ Patched by Polaris Software                           }
{*******************************************************}

unit RxGrdCpt;

{$I RX.INC}

interface

{$IFDEF WIN32}

uses Windows, Messages, Classes, Graphics, Controls, Forms, Dialogs, Menus,
  RxHook, VclUtils;

type
  THideDirection = (hdLeftToRight, hdRightToLeft);

  TRxCaption = class;
  TRxCaptionList = class;

{ TRxGradientCaption }

  TRxGradientCaption = class(TComponent)
  private
    FActive: Boolean;
    FWindowActive: Boolean;
    FSaveRgn: HRgn;
    FRgnChanged: Boolean;
    FWinHook: TRxWindowHook;
    FStartColor: TColor;
    FCaptions: TRxCaptionList;
    FFont: TFont;
    FDefaultFont: Boolean;
    FPopupMenu: TPopupMenu;
    FClicked: Boolean;
    FHideDirection: THideDirection;
    FGradientInactive: Boolean;
    FGradientActive: Boolean;
    FFontInactiveColor: TColor;
    FFormCaption: string;
    FGradientSteps: Integer;
    FOnActivate: TNotifyEvent;
    FOnDeactivate: TNotifyEvent;
    procedure SetHook;
    procedure ReleaseHook;
    procedure CheckToggleHook;
    function GetActive: Boolean;
    procedure SetActive(Value: Boolean);
    procedure SetStartColor(Value: TColor);
    procedure DrawGradientCaption(DC: HDC);
    procedure CalculateGradientParams(var R: TRect; var Icons: TBorderIcons);
    function GetForm: TForm;
    function GetFormCaption: string;
    procedure SetFormCaption(const Value: string);
    procedure BeforeMessage(Sender: TObject; var Msg: TMessage;
      var Handled: Boolean);
    procedure AfterMessage(Sender: TObject; var Msg: TMessage;
      var Handled: Boolean);
    function CheckMenuPopup(X, Y: Integer): Boolean;
    procedure SetFont(Value: TFont);
    procedure FontChanged(Sender: TObject);
    procedure SetDefaultFont(Value: Boolean);
    procedure SetFontDefault;
    function IsFontStored: Boolean;
    function GetTextWidth: Integer;
    procedure SetCaptions(Value: TRxCaptionList);
    procedure SetGradientActive(Value: Boolean);
    procedure SetGradientInactive(Value: Boolean);
    procedure SetGradientSteps(Value: Integer);
    procedure SetFontInactiveColor(Value: TColor);
    procedure SetHideDirection(Value: THideDirection);
    procedure SetPopupMenu(Value: TPopupMenu);
  protected
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
{$IFDEF RX_D4}
    function IsRightToLeft: Boolean;
{$ENDIF}
    property Form: TForm read GetForm;
    property TextWidth: Integer read GetTextWidth;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure MoveCaption(FromIndex, ToIndex: Integer);
    procedure Update;
    procedure Clear;
  published
    property Active: Boolean read GetActive write SetActive default True;
    property Captions: TRxCaptionList read FCaptions write SetCaptions;
    property DefaultFont: Boolean read FDefaultFont write SetDefaultFont default True;
    property FormCaption: string read GetFormCaption write SetFormCaption;
    property FontInactiveColor: TColor read FFontInactiveColor
      write SetFontInactiveColor default clInactiveCaptionText;
    property Font: TFont read FFont write SetFont stored IsFontStored;
    property GradientActive: Boolean read FGradientActive
      write SetGradientActive default True;
    property GradientInactive: Boolean read FGradientInactive
      write SetGradientInactive default False;
    property GradientSteps: Integer read FGradientSteps write SetGradientSteps
      default 64;
    property HideDirection: THideDirection read FHideDirection
      write SetHideDirection default hdLeftToRight;
    property PopupMenu: TPopupMenu read FPopupMenu write SetPopupMenu;
    property StartColor: TColor read FStartColor write SetStartColor
      default clWindowText;
    property OnActivate: TNotifyEvent read FOnActivate write FOnActivate;
    property OnDeactivate: TNotifyEvent read FOnDeactivate write FOnDeactivate;
  end;

{ TRxCaptionList }

  TRxCaptionList = class(TCollection)
  private
    FParent: TRxGradientCaption;
    function GetCaption(Index: Integer): TRxCaption;
    procedure SetCaption(Index: Integer; Value: TRxCaption);
  protected
{$IFDEF RX_D3}
    function GetOwner: TPersistent; override;
{$ENDIF}
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AParent: TRxGradientCaption);
    function Add: TRxCaption;
    procedure RestoreDefaults;
    property Parent: TRxGradientCaption read FParent;
    property Items[Index: Integer]: TRxCaption read GetCaption write SetCaption; default;
  end;

{ TRxCaption }

  TRxCaption = class(TCollectionItem)
  private
    FCaption: string;
    FFont: TFont;
    FParentFont: Boolean;
    FVisible: Boolean;
    FGlueNext: Boolean;
    FInactiveColor: TColor;
    procedure SetCaption(const Value: string);
    procedure SetFont(Value: TFont);
    procedure SetParentFont(Value: Boolean);
    procedure FontChanged(Sender: TObject);
    function IsFontStored: Boolean;
    function GetTextWidth: Integer;
    procedure SetVisible(Value: Boolean);
    procedure SetInactiveColor(Value: TColor);
    procedure SetGlueNext(Value: Boolean);
  protected
    function GetParentCaption: TRxGradientCaption;
    property TextWidth: Integer read GetTextWidth;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure RestoreDefaults; virtual;
    property GradientCaption: TRxGradientCaption read GetParentCaption;
  published
    property Caption: string read FCaption write SetCaption;
    property Font: TFont read FFont write SetFont stored IsFontStored;
    property ParentFont: Boolean read FParentFont write SetParentFont
      default True;
    property InactiveColor: TColor read FInactiveColor write SetInactiveColor
      default clInactiveCaptionText;
    property GlueNext: Boolean read FGlueNext write SetGlueNext default False;
    property Visible: Boolean read FVisible write SetVisible default True;
  end;

function GradientFormCaption(AForm: TCustomForm;
  AStartColor: TColor): TRxGradientCaption;

{$ENDIF WIN32}

implementation

{$IFDEF WIN32}

uses SysUtils, {$IFDEF RX_D5}RxAppUtils{$ELSE}AppUtils{$ENDIF};  // Polaris

function GradientFormCaption(AForm: TCustomForm;
  AStartColor: TColor): TRxGradientCaption;
begin
  Result := TRxGradientCaption.Create(AForm);
  with Result do
    try
      FStartColor := AStartColor;
      FormCaption := AForm.Caption;
      Update;
    except
      Free;
      raise;
    end;
end;

{ TRxCaptionList }

constructor TRxCaptionList.Create(AParent: TRxGradientCaption);
begin
  inherited Create(TRxCaption);
  FParent := AParent;
end;

function TRxCaptionList.Add: TRxCaption;
begin
  Result := TRxCaption(inherited Add);
end;

function TRxCaptionList.GetCaption(Index: Integer): TRxCaption;
begin
  Result := TRxCaption(inherited Items[Index]);
end;

{$IFDEF RX_D3}
function TRxCaptionList.GetOwner: TPersistent;
begin
  Result := FParent;
end;
{$ENDIF}

procedure TRxCaptionList.RestoreDefaults;
var
  I: Integer;
begin
  BeginUpdate;
  try
    for I := 0 to Count-1 do
      Items[I].RestoreDefaults;
  finally
    EndUpdate;
  end;
end;

procedure TRxCaptionList.SetCaption(Index: Integer; Value: TRxCaption);
begin
  Items[Index].Assign(Value);
end;

procedure TRxCaptionList.Update(Item: TCollectionItem);
begin
  if (FParent <> nil) and not (csLoading in FParent.ComponentState) then
    if FParent.Active then FParent.Update;
end;

{ TRxCaption }

constructor TRxCaption.Create(Collection: TCollection);
var
  Parent: TRxGradientCaption;
begin
  Parent := nil;
  if Assigned(Collection) and (Collection is TRxCaptionList) then
    Parent := TRxCaptionList(Collection).Parent;
  try
    inherited Create(Collection);
    FFont := TFont.Create;
    if Assigned(Parent) then begin
      FFont.Assign(Parent.Font);
      FFont.Color := Parent.Font.Color;
    end
    else FFont.Color := clCaptionText;
    FFont.OnChange := FontChanged;
    FCaption := '';
    FParentFont := True;
    FVisible := True;
    FGlueNext := False;
    FInactiveColor := clInactiveCaptionText;
  finally
    if Assigned(Parent) then Changed(False);
  end;
end;

destructor TRxCaption.Destroy;
begin
  FFont.Free;
  FFont := nil;
  inherited Destroy;
end;

procedure TRxCaption.Assign(Source: TPersistent);
begin
  if Source is TRxCaption then begin
    if Assigned(Collection) then Collection.BeginUpdate;
    try
      RestoreDefaults;
      Caption := TRxCaption(Source).Caption;
      ParentFont := TRxCaption(Source).ParentFont;
      if not ParentFont then
        Font.Assign(TRxCaption(Source).Font);
      InactiveColor := TRxCaption(Source).InactiveColor;
      GlueNext := TRxCaption(Source).GlueNext;
      Visible := TRxCaption(Source).Visible;
    finally
      if Assigned(Collection) then Collection.EndUpdate;
    end;
  end
  else inherited Assign(Source);
end;

procedure TRxCaption.RestoreDefaults;
begin
  FInactiveColor := clInactiveCaptionText;
  FVisible := True;
  ParentFont := True;
end;

function TRxCaption.GetParentCaption: TRxGradientCaption;
begin
  if Assigned(Collection) and (Collection is TRxCaptionList) then
    Result := TRxCaptionList(Collection).Parent
  else
    Result := nil;
end;

procedure TRxCaption.SetCaption(const Value: string);
begin
  FCaption := Value;
  Changed(False);
end;

procedure TRxCaption.FontChanged(Sender: TObject);
begin
  FParentFont := False;
  Changed(False);
end;

procedure TRxCaption.SetFont(Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TRxCaption.SetParentFont(Value: Boolean);
begin
  if Value and (GradientCaption <> nil) then begin
    FFont.OnChange := nil;
    try
      FFont.Assign(GradientCaption.Font);
    finally
      FFont.OnChange := FontChanged;
    end;
  end;
  FParentFont := Value;
  Changed(False);
end;

function TRxCaption.IsFontStored: Boolean;
begin
  Result := not FParentFont;
end;

function TRxCaption.GetTextWidth: Integer;
var
  Canvas: TCanvas;
  PS: TPaintStruct;
begin
  BeginPaint(Application.Handle, PS);
  try
    Canvas := TCanvas.Create;
    try
      Canvas.Handle := PS.hDC;
      Canvas.Font := FFont;
      Result := Canvas.TextWidth(FCaption);
    finally
      Canvas.Free;
    end;
  finally
    EndPaint(Application.Handle, PS);
  end;
end;

procedure TRxCaption.SetVisible(Value: Boolean);
begin
  if FVisible <> Value then begin
    FVisible := Value;
    Changed(False);
  end;
end;

procedure TRxCaption.SetInactiveColor(Value: TColor);
begin
  if FInactiveColor <> Value then begin
    FInactiveColor := Value;
    if (GradientCaption = nil) or not GradientCaption.FWindowActive then
      Changed(False);
  end;
end;

procedure TRxCaption.SetGlueNext(Value: Boolean);
begin
  if FGlueNext <> Value then begin
    FGlueNext := Value;
    Changed(False);
  end;
end;

{$IFNDEF RX_D4}
const
  COLOR_GRADIENTACTIVECAPTION   =    27;
  COLOR_GRADIENTINACTIVECAPTION =    28;
  SPI_GETGRADIENTCAPTIONS       = $1008;
{$ENDIF}

const
  clGradientActiveCaption = TColor(COLOR_GRADIENTACTIVECAPTION or $80000000);
  clGradientInactiveCaption = TColor(COLOR_GRADIENTINACTIVECAPTION or $80000000);

function SysGradient: Boolean;
var
  Info: BOOL;
begin
  if SystemParametersInfo(SPI_GETGRADIENTCAPTIONS, SizeOf(Info), @Info, 0) then
    Result := Info
  else Result := False;
end;

{ TRxGradientCaption }

constructor TRxGradientCaption.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FGradientSteps := 64;
  FGradientActive := True;
  FActive := True;
  FCaptions := TRxCaptionList.Create(Self);
  FWinHook := TRxWindowHook.Create(Self);
  FWinHook.BeforeMessage := BeforeMessage;
  FWinHook.AfterMessage := AfterMessage;
  FStartColor := clWindowText;
  FFontInactiveColor := clInactiveCaptionText;
  FFormCaption := '';
  FFont := TFont.Create;
  SetFontDefault;
end;

destructor TRxGradientCaption.Destroy;
begin
  FOnDeactivate := nil;
  FOnActivate := nil;
  if not (csDesigning in ComponentState) then
    ReleaseHook;
  FCaptions.Free;
  FCaptions := nil;
  FFont.Free;
  FFont := nil;
  inherited Destroy;
end;

procedure TRxGradientCaption.Loaded;
var
  Loading: Boolean;
begin
  Loading := csLoading in ComponentState;
  inherited Loaded;
  if not (csDesigning in ComponentState) then begin
    if Loading and (Owner is TCustomForm) then Update;
  end;
end;

procedure TRxGradientCaption.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (AComponent = PopupMenu) and (Operation = opRemove) then
    PopupMenu := nil;
end;

procedure TRxGradientCaption.SetPopupMenu(Value: TPopupMenu);
begin
  FPopupMenu := Value;
  if Value <> nil then Value.FreeNotification(Self);
end;

procedure TRxGradientCaption.SetCaptions(Value: TRxCaptionList);
begin
  Captions.Assign(Value);
end;

procedure TRxGradientCaption.SetDefaultFont(Value: Boolean);
begin
  if FDefaultFont <> Value then begin
    if Value then SetFontDefault;
    FDefaultFont := Value;
    if Active then Update;
  end;
end;

procedure TRxGradientCaption.SetFontDefault;
var
  NCMetrics: TNonClientMetrics;
begin
  with FFont do begin
    OnChange := nil;
    try
      NCMetrics.cbSize := SizeOf(NCMetrics);
      if SystemParametersInfo(SPI_GETNONCLIENTMETRICS, 0, @NCMetrics, 0) then
      begin
        if (Owner is TForm) and
          ((Owner as TForm).BorderStyle in [bsToolWindow, bsSizeToolWin]) then
          Handle := CreateFontIndirect(NCMetrics.lfSmCaptionFont)
        else
          Handle := CreateFontIndirect(NCMetrics.lfCaptionFont);
      end
      else begin
        Name := 'MS Sans Serif';
        Size := 8;
        Style := [fsBold];
      end;
      Color := clCaptionText;
{$IFNDEF VER90}
      Charset := DEFAULT_CHARSET;
{$ENDIF}
    finally
      OnChange := FontChanged;
    end;
  end;
  FDefaultFont := True;
end;

function TRxGradientCaption.IsFontStored: Boolean;
begin
  Result := not DefaultFont;
end;

function TRxGradientCaption.GetForm: TForm;
begin
  if Owner is TCustomForm then
    Result := TForm(Owner as TCustomForm)
  else
    Result := nil;
end;

function TRxGradientCaption.GetFormCaption: string;
begin
  if (Form <> nil) and (csDesigning in ComponentState) then
    FFormCaption := Form.Caption;
  Result := FFormCaption;
end;

procedure TRxGradientCaption.SetFormCaption(const Value: string);
begin
  if FFormCaption <> Value then begin
    FFormCaption := Value;
    if (Form <> nil) and (csDesigning in ComponentState) then
      Form.Caption := FFormCaption;
    if Active then Update;
  end;
end;

procedure TRxGradientCaption.SetHook;
begin
  if not (csDesigning in ComponentState) and (Owner <> nil) and
    (Owner is TCustomForm) then
    FWinHook.WinControl := Form;
end;

procedure TRxGradientCaption.ReleaseHook;
begin
  FWinHook.WinControl := nil;
end;

procedure TRxGradientCaption.CheckToggleHook;
begin
  if Active then SetHook
  else ReleaseHook;
end;

function TRxGradientCaption.CheckMenuPopup(X, Y: Integer): Boolean;
begin
  Result := False;
  if not (csDesigning in ComponentState) and Assigned(FPopupMenu) and
    FPopupMenu.AutoPopup then
  begin
    FPopupMenu.PopupComponent := Self;
    if Form <> nil then begin
      Form.SendCancelMode(nil);
      FPopupMenu.Popup(X, Y);
      Result := True;
    end;
  end;
end;

procedure TRxGradientCaption.BeforeMessage(Sender: TObject; var Msg: TMessage;
  var Handled: Boolean);
var
  DrawRgn: HRgn;
  R: TRect;
  Icons: TBorderIcons;
begin
  if Active then begin
    case Msg.Msg of
      WM_NCACTIVATE:
        begin
          FWindowActive := (Msg.wParam <> 0);
        end;
      WM_NCRBUTTONDOWN:
        if Assigned(FPopupMenu) and FPopupMenu.AutoPopup then begin
          FClicked := True;
          Msg.Result := 0;
          Handled := True;
        end;
      WM_NCRBUTTONUP:
        with TWMMouse(Msg) do
          if FClicked then begin
            FClicked := False;
            if CheckMenuPopup(XPos, YPos) then begin
              Result := 0;
              Handled := True;
            end;
          end;
      WM_NCPAINT:
        begin
          FSaveRgn := Msg.wParam;
          FRgnChanged := False;
          CalculateGradientParams(R, Icons);
          if RectInRegion(FSaveRgn, R) then begin
            DrawRgn := CreateRectRgn(R.Left, R.Top, R.Right, R.Bottom);
            try
              Msg.WParam := CreateRectRgn(0, 0, 1, 1);
              FRgnChanged := True;
              CombineRgn(Msg.WParam, FSaveRgn, DrawRgn, RGN_DIFF);
            finally
              DeleteObject(DrawRgn);
            end;
          end;
        end;
    end;
  end;
end;

procedure TRxGradientCaption.AfterMessage(Sender: TObject; var Msg: TMessage;
  var Handled: Boolean);
var
  DC: HDC;
  S: string;
begin
  if Active then begin
    case Msg.Msg of
      WM_NCACTIVATE:
        begin
          DC := GetWindowDC(Form.Handle);
          try
            DrawGradientCaption(DC);
          finally
            ReleaseDC(Form.Handle, DC);
          end;
        end;
      WM_NCPAINT:
        begin
          if FRgnChanged then begin
            DeleteObject(Msg.WParam);
            Msg.WParam := FSaveRgn;
            FRgnChanged := False;
          end;
          DC := GetWindowDC(Form.Handle);
          try
            DrawGradientCaption(DC);
          finally
            ReleaseDC(Form.Handle, DC);
          end;
        end;
      WM_GETTEXT:
        { Delphi doesn't send WM_SETTEXT to form's window procedure,
          so we need to handle WM_GETTEXT to redraw non-client area
          when form's caption changed }
        begin
          if csDesigning in ComponentState then begin
            SetString(S, PChar(Msg.LParam), Msg.Result);
            if AnsiCompareStr(S, FFormCaption) <> 0 then begin
              FormCaption := S;
              PostMessage(Form.Handle, WM_NCPAINT, 0, 0);
            end;
          end;
        end;
    end;
  end;
end;

procedure TRxGradientCaption.SetStartColor(Value: TColor);
begin
  if FStartColor <> Value then begin
    FStartColor := Value;
    if Active then Update;
  end;
end;

function TRxGradientCaption.GetActive: Boolean;
begin
  Result := FActive;
  if not (csDesigning in ComponentState) then
    Result := Result and NewStyleControls and (Owner is TCustomForm);
end;

procedure TRxGradientCaption.SetActive(Value: Boolean);
begin
  if FActive <> Value then begin
    FActive := Value;
    FClicked := False;
    Update;
    if ([csDestroying, csReading] * ComponentState = []) then begin
      if FActive then begin
        if Assigned(FOnActivate) then FOnActivate(Self);
      end
      else begin
        if Assigned(FOnDeactivate) then FOnDeactivate(Self);
      end;
    end;
  end;
end;

procedure TRxGradientCaption.Clear;
begin
  if FCaptions <> nil then FCaptions.Clear;
end;

procedure TRxGradientCaption.MoveCaption(FromIndex, ToIndex: Integer);
begin
  Captions[FromIndex].Index := ToIndex;
end;

procedure TRxGradientCaption.Update;
var
  Rgn: HRgn;
begin
  if not (csDesigning in ComponentState) and (Owner is TCustomForm) and
    not (csLoading in ComponentState) then
  begin
    CheckToggleHook;
    FWindowActive := False;
    if (Form <> nil) and Form.HandleAllocated and Form.Visible then begin
      if Active then begin
        FWindowActive := (GetActiveWindow = Form.Handle) and
          IsForegroundTask;
      end;
      with Form do
        Rgn := CreateRectRgn(Left, Top, Left + Width, Top + Height);
      try
        SendMessage(Form.Handle, WM_NCPAINT, Rgn, 0);
      finally
        DeleteObject(Rgn);
      end;
    end;
  end;
end;

procedure TRxGradientCaption.CalculateGradientParams(var R: TRect;
  var Icons: TBorderIcons);
var
  I: TBorderIcon;
  BtnCount: Integer;
begin
  GetWindowRect(Form.Handle, R);
  Icons := Form.BorderIcons;
  case Form.BorderStyle of
    bsDialog: Icons := Icons * [biSystemMenu, biHelp];
    bsToolWindow, bsSizeToolWin: Icons := Icons * [biSystemMenu];
    else begin
      if not (biSystemMenu in Icons) then
        Icons := Icons - [biMaximize, biMinimize];
      if (Icons * [biMaximize, biMinimize] <> []) then
        Icons := Icons - [biHelp];
    end;
  end;
  BtnCount := 0;
  for I := Low(TBorderIcon) to High(TBorderIcon) do
    if I in Icons then Inc(BtnCount);
  if (biMinimize in Icons) and not (biMaximize in Icons) then
    Inc(BtnCount)
  else if not (biMinimize in Icons) and (biMaximize in Icons) then
    Inc(BtnCount);
  case Form.BorderStyle of
    bsToolWindow, bsSingle, bsDialog:
      InflateRect(R, -GetSystemMetrics(SM_CXFIXEDFRAME),
        -GetSystemMetrics(SM_CYFIXEDFRAME));
    bsSizeable, bsSizeToolWin:
      InflateRect(R, -GetSystemMetrics(SM_CXSIZEFRAME),
        -GetSystemMetrics(SM_CYSIZEFRAME));
  end;
  if Form.BorderStyle in [bsToolWindow, bsSizeToolWin] then begin
    R.Bottom := R.Top + GetSystemMetrics(SM_CYSMCAPTION) - 1;
    Dec(R.Right, BtnCount * GetSystemMetrics(SM_CXSMSIZE));
  end
  else begin
    R.Bottom := R.Top + GetSystemMetrics(SM_CYCAPTION) - 1;
    Dec(R.Right, BtnCount * GetSystemMetrics(SM_CXSIZE));
  end;
end;

{$IFDEF RX_D4}
function TRxGradientCaption.IsRightToLeft: Boolean;
var
  F: TForm;
begin
  F := Form;
  if F <> nil then Result := F.IsRightToLeft
  else Result := Application.IsRightToLeft;
end;
{$ENDIF}

procedure TRxGradientCaption.DrawGradientCaption(DC: HDC);
var
  R, DrawRect: TRect;
  Icons: TBorderIcons;
  C: TColor;
  Ico: HIcon;
  Image: TBitmap;
  S: string;
  IconCreated, DrawNext: Boolean;
  I, J, SumWidth: Integer;

  procedure SetCaptionFont(Index: Integer);
  begin
    if (Index < 0) or Captions[Index].ParentFont then
      Image.Canvas.Font.Assign(Self.Font)
    else Image.Canvas.Font.Assign(Captions[Index].Font);
    if not FWindowActive then begin
      if Index < 0 then
        Image.Canvas.Font.Color := FFontInactiveColor
      else
        Image.Canvas.Font.Color := Captions[Index].InactiveColor;
    end;
  end;

  function DrawStr(GluePrev, GlueNext: Boolean; PrevIndex: Integer): Boolean;
  const
    Points = '...';
  var
    Text: string;
    Flags: Longint;
  begin
    if Length(S) > 0 then begin
      Text := MinimizeText(S, Image.Canvas, R.Right - R.Left);
      if GlueNext and (Text = S) then begin
        if (Image.Canvas.TextWidth(Text + '.') >= R.Right - R.Left) then begin
          if GluePrev then Text := Points
          else Text := Text + Points;
        end;
      end;
      if (Text <> Points) or GluePrev then begin
        if (Text = Points) and GluePrev then begin
          SetCaptionFont(-1);
          if PrevIndex > 0 then begin
            if FWindowActive then
              Image.Canvas.Font.Color := Captions[PrevIndex].Font.Color
            else
              Image.Canvas.Font.Color := Captions[PrevIndex].InactiveColor;
          end;
        end;
        Flags := DT_VCENTER or DT_SINGLELINE or DT_NOPREFIX;
{$IFDEF RX_D4}
        if IsRightToLeft then
          Flags := Flags or DT_RIGHT or DT_RTLREADING else
{$ENDIF}
        Flags := Flags or DT_LEFT;
        DrawText(Image.Canvas.Handle, PChar(Text), -1, R, Flags);
{$IFDEF RX_D4}
        if IsRightToLeft then
          Dec(R.Right, Image.Canvas.TextWidth(Text)) else
{$ENDIF}
        Inc(R.Left, Image.Canvas.TextWidth(Text));
      end;
      Result := (Text = S);
    end
    else Result := True;
  end;

begin
  if Form.BorderStyle = bsNone then Exit;
  Image := TBitmap.Create;
  try
    CalculateGradientParams(R, Icons);
    GetWindowRect(Form.Handle, DrawRect);
    OffsetRect(R, -DrawRect.Left, -DrawRect.Top);
    DrawRect := R;
    Image.Width := WidthOf(R);
    Image.Height := HeightOf(R);
    R := Rect(-Image.Width div 4, 0, Image.Width, Image.Height);
    if SysGradient then begin
      if FWindowActive then C := clGradientActiveCaption
      else C := clGradientInactiveCaption;
    end
    else begin
      if FWindowActive then C := clActiveCaption
      else C := clInactiveCaption;
    end;
    if (FWindowActive and GradientActive) or
      (not FWindowActive and GradientInactive) then
    begin
      GradientFillRect(Image.Canvas, R, FStartColor, C, fdLeftToRight,
        FGradientSteps);
    end
    else begin
      Image.Canvas.Brush.Color := C;
      Image.Canvas. FillRect(R);
    end;
    R.Left := 0;
    if (biSystemMenu in Icons) and (Form.BorderStyle in [bsSizeable,
      bsSingle]) then
    begin
      IconCreated := False;
      if Form.Icon.Handle <> 0 then
        Ico := Form.Icon.Handle
      else if Application.Icon.Handle <> 0 then begin
        Ico := LoadImage(HInstance, 'MAINICON', IMAGE_ICON,
          GetSystemMetrics(SM_CXSMICON), GetSystemMetrics(SM_CYSMICON), 0);
        IconCreated := Ico <> 0;
        if not IconCreated then Ico := Application.Icon.Handle;
      end
      else Ico := LoadIcon(0, IDI_APPLICATION);
      DrawIconEx(Image.Canvas.Handle, R.Left + 1 + (R.Bottom + R.Top -
        GetSystemMetrics(SM_CXSMICON)) div 2, (R.Bottom + R.Top -
        GetSystemMetrics(SM_CYSMICON)) div 2, Ico,
        GetSystemMetrics(SM_CXSMICON), GetSystemMetrics(SM_CYSMICON),
        0, 0, DI_NORMAL);
      if IconCreated then DestroyIcon(Ico);
      Inc(R.Left, R.Bottom - R.Top);
    end;
    if (FFormCaption <> '') or ((Captions <> nil) and (Captions.Count > 0)) then
    begin
      SumWidth := 2;
      SetBkMode(Image.Canvas.Handle, TRANSPARENT);
      Inc(R.Left, 2);
      if FHideDirection = hdLeftToRight then begin
        for I := 0 to Captions.Count - 1 do
          if Captions[I].Visible then
            SumWidth := SumWidth + Captions[I].TextWidth;
        SumWidth := SumWidth + TextWidth;
        J := 0;
        while (SumWidth > (R.Right - R.Left)) and (J < Captions.Count) do
        begin
          SumWidth := SumWidth - Captions[J].TextWidth;
          while (J < Captions.Count - 1) and Captions[J].GlueNext do begin
            SumWidth := SumWidth - Captions[J + 1].TextWidth;
            Inc(J);
          end;
          Inc(J);
        end;
        for I := J to Captions.Count do begin
          if I < Captions.Count then begin
            if Captions[I].Visible then begin
              S := Captions[I].Caption;
              SetCaptionFont(I);
            end
            else S := '';
          end
          else begin
            S := FFormCaption;
            SetCaptionFont(-1);
          end;
          DrawStr(I = Captions.Count, False, -1);
        end;
      end
      else begin
        DrawNext := True;
        J := 0;
        if Captions <> nil then begin
          while (SumWidth < (R.Right - R.Left)) and (J < Captions.Count) do
          begin
            if Captions[J].Visible then begin
              SumWidth := SumWidth + Captions[J].TextWidth;
              while Captions[J].GlueNext and (J < Captions.Count - 1) do
              begin
                SumWidth := SumWidth + Captions[J + 1].TextWidth;
                Inc(J);
              end;
            end;
            Inc(J);
          end;
          for I := 0 to J - 1 do begin
            if Captions[I].Visible and DrawNext then begin
              S := Captions[I].Caption;
              if S <> '' then begin
                SetCaptionFont(I);
                DrawNext := DrawStr(((I > 0) and Captions[I - 1].GlueNext) or
                  (I = 0), Captions[I].GlueNext, I - 1) and
                  (Captions[I].GlueNext or (R.Right > R.Left));
              end;
            end;
          end;
        end;
        if (R.Right > R.Left) and DrawNext and (FFormCaption <> '') then
        begin
          S := FFormCaption;
          SetCaptionFont(-1);
          DrawStr(False, False, -1);
        end;
      end;
    end;
    BitBlt(DC, DrawRect.Left, DrawRect.Top, Image.Width, Image.Height,
      Image.Canvas.Handle, 0, 0, SRCCOPY);
  finally
    Image.Free;
  end;
end;

procedure TRxGradientCaption.SetFont(Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TRxGradientCaption.FontChanged(Sender: TObject);
var
  I: Integer;
begin
  FDefaultFont := False;
  if (Captions <> nil) then begin
    Captions.BeginUpdate;
    try
      for I := 0 to Captions.Count - 1 do
        if Captions[I].ParentFont then Captions[I].SetParentFont(True);
    finally
      Captions.EndUpdate;
    end;
  end
  else if Active then Update;
end;

function TRxGradientCaption.GetTextWidth: Integer;
var
  Canvas: TCanvas;
  PS: TPaintStruct;
begin
  BeginPaint(Application.Handle, PS);
  try
    Canvas := TCanvas.Create;
    try
      Canvas.Handle := PS.hDC;
      Canvas.Font := FFont;
      Result := Canvas.TextWidth(FFormCaption);
    finally
      Canvas.Free;
    end;
  finally
    EndPaint(Application.Handle, PS);
  end;
end;

procedure TRxGradientCaption.SetGradientSteps(Value: Integer);
begin
  if FGradientSteps <> Value then begin
    FGradientSteps := Value;
    if Active and ((FWindowActive and GradientActive) or
      (not FWindowActive and GradientInactive)) then Update;
  end;
end;

procedure TRxGradientCaption.SetGradientActive(Value: Boolean);
begin
  if FGradientActive <> Value then begin
    FGradientActive := Value;
    if Active and FWindowActive then Update;
  end;
end;

procedure TRxGradientCaption.SetGradientInactive(Value: Boolean);
begin
  if FGradientInactive <> Value then begin
    FGradientInactive := Value;
    if Active and not FWindowActive then Update;
  end;
end;

procedure TRxGradientCaption.SetFontInactiveColor(Value: TColor);
begin
  if FFontInactiveColor <> Value then begin
    FFontInactiveColor := Value;
    if Active and not FWindowActive then Update;
  end;
end;

procedure TRxGradientCaption.SetHideDirection(Value: THideDirection);
begin
  if FHideDirection <> Value then begin
    FHideDirection := Value;
    if Active then Update;
  end;
end;

{$ENDIF WIN32}

end.