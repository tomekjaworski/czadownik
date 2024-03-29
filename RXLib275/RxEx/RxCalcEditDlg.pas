unit RxCalcEditDlg;
{
Component: TRxCalcEditDlg
Version: 1.00
Author: Craig Manley.
Email: c.manley@chello.nl
Website: http://www.skybound.nl
Last updated: 14 March 2000

Notice:
You may use this component free of charge in any project as long as this
source code is left intact. Please report bugs fixes or improvements to me
by email. RxLib is required (http://www.rxlib.com).

Description:
This is a dialog component that uses the RxCalcEdit control from RxLib for editing
numbers. When shown, this dialog centers itself over the bounding rect of it's owner if possible otherwise over the desktop working area.
Also defined in this unit are 4 global functions (ByteInputDlg, WordInputDlg, IntegerInputDlg, ExtendedInputDlg) for displaying specialized number editing dialogs without having to paste the TRxCalcEditDlg on your form.
}


interface

uses
  Windows, Messages, Classes, Controls, Forms, StdCtrls, Buttons, ExtCtrls,
  Mask, ToolEdit, CurrEdit;

function ByteInputDlg(const ACaption, AText: string; AMaxValue, AMinValue: byte; var AValue: byte): boolean;
function WordInputDlg(const ACaption, AText: string; AMaxValue, AMinValue: WORD; var AValue: word): boolean;
function IntegerInputDlg(const ACaption, AText: string; AMaxValue, AMinValue: Integer; var AValue: integer): boolean;
function ExtendedInputDlg(const ACaption, AText: string; AMaxValue, AMinValue: Extended; ADecimalPlaces: byte; const ADisplayFormat: string; var AValue: Extended): boolean;

type
  TRxCalcEditDlg = class(TComponent)
  private
    { Form properties }
    FCaption: TCaption;
    FText: string;
    { TRxCalcEdit properties }
    FAlignment: TAlignment;
    FDecimalPlaces: byte;
    FDisplayFormat: string;
    FMaxLength: integer;
    FMaxValue,
    FMinValue: Extended;
    function IsFormatStored: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    function Execute(var AValue: Extended): boolean;
  protected
    function DefaultDisplayFormat: string; virtual;
  published
    // Form properties...
    property Caption: TCaption read FCaption write FCaption;
    property Text: string read FText write FText;
    // TRxCalcEdit properties...
    property Alignment: TAlignment read FAlignment write FAlignment default taRightJustify;
    property DecimalPlaces: byte read FDecimalPlaces write FDecimalPlaces default 0;
    property DisplayFormat: string read FDisplayFormat write FDisplayFormat stored IsFormatStored;
    property MaxLength: integer read FMaxLength write FMaxLength default 0;
    property MaxValue: Extended read FMaxValue write FMaxValue;
    property MinValue: Extended read FMinValue write FMinValue;
  end;

{ TFormRxCalcEdit }
type
  TFormRxCalcEdit = class(TForm)
    RxCalcEdit: TRxCalcEdit;
    BitBtnOK: TBitBtn;
    BitBtnCancel: TBitBtn;
    LabelText: TLabel;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    procedure SetText(const AValue: string);
  published
    property Text: string write SetText;
  end;


procedure Register;

implementation

{$R *.DFM}
{$R *.RES}

procedure Register;
begin
  RegisterComponents('Freeware', [TRxCalcEditDlg]);
end;


function ByteInputDlg(const ACaption, AText: string; AMaxValue, AMinValue: byte; var AValue: byte): boolean;
var
  dlg: TRxCalcEditDlg;
  x: Extended;
begin
  dlg := TRxCalcEditDlg.Create(nil);
  try
    dlg.Caption := ACaption;
    dlg.Text := AText;
    dlg.MaxValue := AMaxValue;
    dlg.MinValue := AMinValue;
    dlg.DisplayFormat := '0';
    dlg.DecimalPlaces := 0;
    x := AValue;
    Result := dlg.Execute(x);
    if Result then
      AValue := Trunc(x);
  finally
    dlg.Free;
  end;
end;

function WordInputDlg(const ACaption, AText: string; AMaxValue, AMinValue: word; var AValue: word): boolean;
var
  dlg: TRxCalcEditDlg;
  x: Extended;
begin
  dlg := TRxCalcEditDlg.Create(nil);
  try
    dlg.Caption := ACaption;
    dlg.Text := AText;
    dlg.MaxValue := AMaxValue;
    dlg.MinValue := AMinValue;
    dlg.DisplayFormat := '0';
    dlg.DecimalPlaces := 0;
    x := AValue;
    Result := dlg.Execute(x);
    if Result then
      AValue := Trunc(x);
  finally
    dlg.Free;
  end;
end;

function IntegerInputDlg(const ACaption, AText: string; AMaxValue, AMinValue: integer; var AValue: integer): boolean;
var
  dlg: TRxCalcEditDlg;
  x: Extended;
begin
  dlg := TRxCalcEditDlg.Create(nil);
  try
    dlg.Caption := ACaption;
    dlg.Text := AText;
    dlg.MaxValue := AMaxValue;
    dlg.MinValue := AMinValue;
    dlg.DisplayFormat := '0';
    dlg.DecimalPlaces := 0;
    x := AValue;
    Result := dlg.Execute(x);
    if Result then
      AValue := Trunc(x);
  finally
    dlg.Free;
  end;
end;

function ExtendedInputDlg(const ACaption, AText: string; AMaxValue, AMinValue: Extended; ADecimalPlaces: byte; const ADisplayFormat: string; var AValue: Extended): boolean;
var
  dlg: TRxCalcEditDlg;
begin
  dlg := TRxCalcEditDlg.Create(nil);
  try
    dlg.Caption := ACaption;
    dlg.Text := AText;
    dlg.MaxValue := AMaxValue;
    dlg.MinValue := AMinValue;
    dlg.DisplayFormat := ADisplayFormat;
    dlg.DecimalPlaces := ADecimalPlaces;
    Result := dlg.Execute(AValue);
  finally
    dlg.Free;
  end;
end;

procedure TFormRxCalcEdit.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  inherited;
  if Key = VK_RETURN then
    BitBtnOK.Click
  else if Key = VK_ESCAPE then
    BitBtnCancel.Click;
end;

procedure TFormRxCalcEdit.SetText(const AValue: string);
var
  r: TRect;
begin
  r := LabelText.ClientRect;
  DrawText(Canvas.Handle,PChar(AValue),-1,r,DT_CALCRECT or DT_LEFT or DT_WORDBREAK);
  LabelText.ClientHeight := r.Bottom - r.Top;
  RxCalcEdit.Top := 8 + LabelText.BoundsRect.Bottom;
  BitBtnOK.Top := 8 + RxCalcEdit.BoundsRect.Bottom;
  BitBtnCancel.Top := BitBtnOK.Top;
  ClientHeight := BitBtnOK.BoundsRect.Bottom + 8;
  LabelText.Caption := AValue;
end;

procedure TFormRxCalcEdit.FormShow(Sender: TObject);
var
  rSelf, rWA, rWnd: TRect;
  i: integer;
begin
  if SystemParametersInfo(SPI_GETWORKAREA,0,@rWA,0) then
  begin
    if (Owner <> nil)
       and (Owner.Owner is TWinControl)
       and TControl(Owner.Owner).Visible
       and GetWindowRect(TWinControl(Owner.Owner).Handle,rWnd) then
    begin
      rSelf.Left := rWnd.Left + (rWnd.Right - rWnd.Left - Width) div 2;
      rSelf.Top := rWnd.Top + (rWnd.Bottom - rWnd.Top - Height) div 2;
      rSelf.Right := rSelf.Left + Width;
      rSelf.Bottom := rSelf.Top + Height;
      if rSelf.Top < rWA.Top then
      begin
        i := rWA.Top - rSelf.Top;
        inc(rSelf.Top,i);
        inc(rSelf.Bottom,i);
      end
      else if rSelf.Bottom > rWA.Bottom then
      begin
        i := rSelf.Bottom - rWA.Bottom;
        dec(rSelf.Bottom,i);
        dec(rSelf.Top,i);
      end;
      if rSelf.Left < rWA.Left then
      begin
        i := rWA.Left - rSelf.Left;
        inc(rSelf.Left,i);
        inc(rSelf.Right,i);
      end
      else if rSelf.Right > rWA.Right then
      begin
        i := rSelf.Right - rWA.Right;
        dec(rSelf.Right,i);
        dec(rSelf.Left,i);
      end;
      BoundsRect := rSelf;
    end
    else
    begin
      Left := rWA.Left + (rWA.Right - rWA.Left - Width) div 2;
      Top := rWA.Top + (rWA.Bottom - rWA.Top - Height) div 2;
    end;
  end;
end;


{TRxCalcEditDlg}
constructor TRxCalcEditDlg.Create(AOwner: TComponent);
begin
  inherited;
  FCaption := 'Enter a number:';
  FAlignment := taRightJustify;
end;

function TRxCalcEditDlg.IsFormatStored: Boolean;
begin
  Result := (DisplayFormat <> DefaultDisplayFormat);
end;

function TRxCalcEditDlg.DefaultDisplayFormat: string;
begin
  Result := '0';
end;

function TRxCalcEditDlg.Execute(var AValue: Extended): boolean;
var
  f: TFormRxCalcEdit;
begin
  f := TFormRxCalcEdit.Create(self);
  try
    f.Caption := FCaption;
    if Owner is TCustomForm then
      f.Font := TCustomForm(Owner).Font;
    f.Text := FText;
    f.RxCalcEdit.Alignment := FAlignment;
    f.RxCalcEdit.DecimalPlaces := FDecimalPlaces;
    f.RxCalcEdit.DisplayFormat := FDisplayFormat;
    f.RxCalcEdit.MaxLength := FMaxLength;
    f.RxCalcEdit.MaxValue := FMaxValue;
    f.RxCalcEdit.MinValue := FMinValue;
    f.RxCalcEdit.Value := AValue;
    if (f.ShowModal = mrOK) then
    begin
      AValue := f.RxCalcEdit.Value;
      Result := True;
    end
    else
      Result := False;
  finally
    f.Free;
  end;
end;

end.
