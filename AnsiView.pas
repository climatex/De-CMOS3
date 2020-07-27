unit ansiview;

interface

uses
   SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
   Forms, Dialogs, StdCtrls, Printers;
   {$M+}

type
 TLinkType = (ltMailto, ltHttp, ltFTP);

 TSVLink = class(TObject)
 public
   Link:   string;
   LinkType : TLinkType;
   X0,X1,Y0,Y1: integer;
 end;

//  TSVLinkPtr=^TSVLink;
  TSVLinkEvent=procedure(Sender: TObject; Link: string) of object;

  {------------------------------------------------------------------}
  TBackgroundStyle = (bsNoBitmap, bsStretched, bsTiled, bsTiledAndScrolled);
  {------------------------------------------------------------------}

   TAnsiView = class(TCustomControl)
   protected
      { Private declarations }
      TextAttr : word;
      TruncateLines, Bold : boolean;
//      FSelWords: TStrings;
      fdx,fdy: integer;
      CanMark,Marking,Marked: Boolean;
      MkL0,Mkc0,MkL1,Mkc1,MkL2,Mkc2: integer;
     XSize, YSize: Integer;
      FullRedraw: Boolean;
      bmp: TBitmap;
      FBackBitmap: TBitmap;
      FBackgroundStyle: TBackgroundStyle;
      OldWidth, OldHeight: Integer;
      FColor: TColor;
      FTextColor: TColor;
      FSelColor: TColor;
      Border: TBorderStyle;
      FileLoaded: Boolean;
      FShowPages: Boolean;
      MyCursor: Integer;
      FOrigin: TPoint;
      FClientSize: TPoint;
      FCharSize: TPoint;
      FOverhang: longint;
      FPageSize: longint;
      FHideScrollBars : Boolean;
      maxlen, scx: longint;
      crMyCurs: TCursor;

        FOnMouseDown,FOnMouseUp: TMouseEvent;
        FOnMouseMove: TMouseMoveEvent;
        FonKeyDown,FOnKeyUp: TKeyEvent;
        FOnKeyPress: TKeyPressEvent;

      FOnLink: TSVLinkEvent;
//      Links: array[1..1000] of TSVLinkPtr;
      NumLinks: integer;

      procedure DrawCanvas;
      procedure Paint; override;
      procedure SetLines(Value: TStrings);
      procedure SetShowPages(Value: boolean);
      procedure SetSelWords(Value: TStrings);
      procedure SetFont(Fnt: TFont);
      procedure SetColor(Col: Tcolor);
      procedure SetSelColor(Col: Tcolor);
      procedure SetTextColor(Col: Tcolor);
      procedure SetBorder(Bor: TBorderStyle);
      procedure SetBackBitmap(Value: TBitmap);
      procedure DrawBack(DC: HDC; Rect: TRect);
      procedure SetBackgroundStyle(Value: TBackgroundStyle);
      procedure DoScroll(Which, Action, Thumb: longint);
      procedure WMHScroll(var M: TWMHScroll); message wm_HScroll;
      procedure WMVScroll(var M: TWMVScroll); message wm_VScroll;
      procedure WMSize(var M: TWMSize); message wm_Size;
      procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
      procedure KeyDown(var Key: Word; Shift: TShiftState); override;
//      procedure KeyDown(var Key: Word; Shift: TShiftState; X: Integer; Y: Integer);
      procedure WMGetDlgCode(var M: TWMGetDlgCode); message wm_GetDlgCode;
      { Protected declarations }
      procedure FontChanged(Sender: TObject);
      procedure InsertPages;
      procedure RemovePages;
      procedure CreateParams(var Params: TCreateParams); override;
      procedure SetScrollBars;
      procedure SetHideScrollBars( Value : Boolean );
        procedure GraphicMouseDown(Sender: TObject; Button: TMouseButton;
           Shift: TShiftState; X, Y: Integer);
        procedure GraphicMouseUp(Sender: TObject; Button: TMouseButton;
           Shift: TShiftState; X, Y: Integer);
        procedure GraphicMouseMove(Sender: TObject;Shift: TShiftState;
           X, Y: Integer);
      procedure KeyPressed(Sender: TObject;var Key: char);
   public
      { Public declarations }
      maxstrlen: longint;
      FRange: TPoint;
      FLines: TStrings;
      FFont: TFont;
      AnsiColor : TColor;
      AnsiBackGround : TColor;
      PageCount: integer;
      IsJump: boolean;
      JmpStr: string;
        procedure CopyToClipboard;
        procedure CutToClipboard;
        procedure Clear;
        procedure SelectAll;
      constructor Create(AnOwner: TComponent); override;
      destructor Destroy; override;
      procedure LoadFromFile(const FileName: string);
      procedure ScrollTo(X, Y: longint);
      procedure Add(const Str: string);
      procedure Print(const fn: string; stpg, endpg: longint; infile, allfile: boolean);
      function GetPos(const Str: string; curpos: longint): longint;
      function GetCurPos: longint;
      procedure RecalceMaxStrLen;
      procedure RecalcRange;
      function RowLine(s : string) : string;
      procedure AnsiWrite(device : TCanvas; x, y : integer; S : string);
      function GetClickLink( clickx, clicky : integer): string; 
   published
      { Published declarations }
      property Font: TFont read FFont write SetFont;
      property Color: TColor read FColor write SetColor;
      property Lines: TStrings read FLines write SetLines;
      property SelectColor: TColor read FSelColor write SetSelColor;
      property TextColor: TColor read FTextColor write SetTextColor;
      property Align;
      property HelpContext;
      property BorderStyle: TBorderStyle read Border write SetBorder default bsNone;
      property ShowPages: Boolean read FShowPages write SetShowPages default false;
      property TabStop;
      property BackgroundBitmap: TBitmap read FBackBitmap write SetBackBitmap;
      property BackgroundStyle: TBackgroundStyle read FBackgroundStyle write SetBackgroundStyle;
      property HideScrollBars : Boolean read FHideScrollBars write SetHideScrollBars default False;
      property OnClick;
      property OnDblClick;
      property OnDragDrop;
      property OnDragOver;
      property OnEndDrag;
//        property OnKeyDown: TKeyEvent read FOnKeyDown write FOnKeyDown;
//        property OnKeyUp: TKeyEvent read FOnKeyUp write FOnKeyUp;
//        property OnKeyPress: TKeyPressEvent read FOnKeyPress write FOnKeyPress;
//        property OnMouseDown: TMouseEvent read FOnMouseDown write FOnMouseDown;
//        property OnMouseUp: TMouseEvent read FOnMouseUp write FOnMouseUp;
//        property OnMouseMove: TMouseMoveEvent read FOnMouseMove write FOnMouseMove;
      property OnStartDrag;
      property OnLinkClicked: TSVLinkEvent read FOnLink write FOnLink;
   end;

CONST
  ColorArray : array[0..15] of integer = (
             clBlack, clMaroon, clGreen, clOlive, clNavy, clPurple, clTeal, clSilver,
             clGray, clRed, clLime,  clYellow, clBlue, clFuchsia, clAqua, clWhite);


procedure Register;

implementation

uses ClipBrd;

type
   TScrollKey = record
   sKey: Byte;
   Ctrl: Boolean;
   SBar: Byte;
   Action: Byte;
end;

{ Scroll keys table }

const
   ScrollKeyCount = 17;
   ScrollKeys: array[1..ScrollKeyCount] of TScrollKey = (
   (sKey: vk_Left;  Ctrl: False; SBar: sb_Horz; Action: sb_LineUp),
   (sKey: vk_Right; Ctrl: False; SBar: sb_Horz; Action: sb_LineDown),
   (sKey: vk_Left;  Ctrl: True;  SBar: sb_Horz; Action: sb_PageUp),
   (sKey: vk_Right; Ctrl: True;  SBar: sb_Horz; Action: sb_PageDown),
   (sKey: vk_Home;  Ctrl: False; SBar: sb_Vert; Action: sb_Top),
   (sKey: vk_End;   Ctrl: False; SBar: sb_Vert; Action: sb_Bottom),
   (skey: vk_Space; Ctrl: False; SBar: sb_Vert; Action: sb_PageDown),
   (sKey: vk_Up;    Ctrl: False; SBar: sb_Vert; Action: sb_LineUp),
   (sKey: vk_Down;  Ctrl: False; SBar: sb_Vert; Action: sb_LineDown),
   (sKey: vk_Prior; Ctrl: False; SBar: sb_Vert; Action: sb_PageUp),
   (sKey: vk_Next;  Ctrl: False; SBar: sb_Vert; Action: sb_PageDown),
   (sKey: vk_F1;    Ctrl: False; SBar: sb_Vert; Action: sb_PageDown),
   (sKey: vk_F2;    Ctrl: False; SBar: sb_Vert; Action: sb_PageUp),
   (sKey: vk_F3;    Ctrl: False; SBar: sb_Vert; Action: sb_Top),
   (sKey: vk_F4;    Ctrl: False; SBar: sb_Vert; Action: sb_Bottom),
   (sKey: vk_Home;  Ctrl: True;  SBar: sb_Horz; Action: sb_Top),
   (sKey: vk_End;   Ctrl: True;  SBar: sb_Horz; Action: sb_Bottom));


function UpStr(const s: string): string;
function UpChar(const St: char): char;
var ch: char;
begin
   case St of
      {English char`s}
      'A': ch := 'À';
      'a': ch := 'À'; 'b': ch := 'Â'; 'B': ch := 'Â'; 'c': ch := 'Ñ'; 'C': ch := 'Ñ'; 'd': ch := 'D';
      'e': ch := 'Å'; 'E': ch := 'Å'; 'f': ch := 'F'; 'g': ch := 'G'; 'h': ch := 'H'; 'H': ch := 'Í';
      'i': ch := 'I'; 'j': ch := 'J'; 'k': ch := 'Ê'; 'K': ch := 'Ê'; 'l': ch := 'L'; 'M': ch := 'Ì';
      'm': ch := 'Ì'; 'n': ch := 'N'; 'o': ch := 'Î'; 'O': ch := 'Î'; 'p': ch := 'Ð'; 'P': ch := 'Ð';
      'q': ch := 'Q'; 'r': ch := 'R'; 's': ch := 'S'; 't': ch := 'Ò'; 'T': ch := 'Ò';
      'u': ch := 'U'; 'v': ch := 'V'; 'w': ch := 'W'; 'x': ch := 'Õ'; 'X': ch := 'Õ';
      'y': ch := 'Y'; 'z': ch := 'Z';
      {Russian char`s}
      'à': ch := 'À'; 'á': ch := 'Á'; 'â': ch := 'Â'; 'ã': ch := 'Ã';
      'ä': ch := 'Ä'; 'å': ch := 'Å'; '¸': ch := '¨'; 'æ': ch := 'Æ';
      'ç': ch := 'Ç'; 'è': ch := 'È'; 'é': ch := 'É'; 'ê': ch := 'Ê';
      'ë': ch := 'Ë'; 'ì': ch := 'Ì'; 'í': ch := 'Í'; 'î': ch := 'Î';
      'ï': ch := 'Ï'; 'ð': ch := 'Ð'; 'ñ': ch := 'Ñ'; 'ò': ch := 'Ò';
      'ó': ch := 'Ó'; 'ô': ch := 'Ô'; 'õ': ch := 'Õ'; 'ö': ch := 'Ö';
      '÷': ch := '×'; 'ø': ch := 'Ø'; 'ù': ch := 'Ù'; 'ú': ch := 'Ú';
      'û': ch := 'Û'; 'ü': ch := 'Ü'; 'ý': ch := 'Ý'; 'þ': ch := 'Þ';
      'ÿ': ch := 'ß';
      else ch := St;
   end;
   UpChar := ch;
end;
var i, Len: integer;
   temp: string;
//   mes: array[0..512]of char;
begin
   Len := Length(s);
   temp := s;
   for i := 1 to len do temp[i] := UpChar(s[i]);
   result := temp;
end;

function Max(i1, i2: longint): longint;
begin
   if i1>i2 then result := i1
   else result := i2;
end;

function Min(i1, i2: longint): longint;
begin
   if i1<i2 then result := i1
   else result := i2;
end;

Constructor TAnsiView.Create(AnOwner: TComponent);
begin
   inherited Create(AnOwner);
   try
      FLines := TStringList.Create;
   except
      Exit;
   end;
   FColor := clWhite;
   FSelColor := clTeal;
   FTextColor := clBlack;
   FFont := TFont.Create;
   FFont.Name := 'Courier New';
   FFont.Color := FTextColor;
   FBackBitmap := TBitmap.Create;
   bmp := TBitmap.Create;
   FBackGroundStyle := bsNoBitmap;
   maxstrlen := 0;
   Width := 200;
   Height := 300;
   FFont.OnChange := FontChanged;
   FontChanged(nil);
   Align := alNone;
   FileLoaded := False;
   PageCount := 0;
   AnsiColor := FTextColor;
   AnsiBackGround := FColor;
   Repaint;
        OnMouseDown:=GraphicMouseDown;
        OnMouseUp:=GraphicMouseUp;
        OnMouseMove:=GraphicMouseMove;
//        OnKeyPress:=KeyPressed;
        CanMark:=False;
//        Modified:=False;
        NumLinks:=0;
end;


destructor TAnsiView.Destroy;
begin
   bmp.Free;
   FLines.Free;
//   FSelWords.Free;
   FFont.Free;
   FBackBitmap.Free;
   inherited Destroy;
end;

procedure TAnsiView.CreateParams(var Params: TCreateParams);
begin
   inherited CreateParams(Params);
   Params.Style := Params.Style or ( WS_HSCROLL or WS_VSCROLL);
end;

procedure TAnsiView.SetLines(Value: TStrings);
var
  i : LongInt;
begin
   FLines.Assign(Value);
   maxstrlen := 0;
   for i:=0 to FLines.Count-1 do begin
     if ( Length( FLines[i] ) > maxstrlen ) then
        maxstrlen := Length( FLines[i] );
   end;
   if FShowPages then
   begin
      RemovePages;
      InsertPages;
   end;
//   maxstrlen := 80;
   RecalcRange;
   Repaint;
end;

procedure TAnsiView.SetSelWords(Value: TStrings);
begin
end;

procedure TAnsiView.SetScrollBars;
begin
   if HandleAllocated then begin
      { If Scroll Bars are hidden, just hide them ! }
      if ( FHideScrollBars ) then begin
         ShowScrollBar( Handle, SB_HORZ, False );
         ShowScrollBar( Handle, SB_VERT, False );
         Exit;
      end;


      { If FRange.X > 0, Horizontal Scrollbar needs to be shown }
      if ( FRange.X > 0 ) then begin
         { Show the ScrollBar }
         ShowScrollBar( Handle, SB_HORZ, True );
         { Compute the new range }
         SetScrollRange(Handle, sb_Horz, 0, Max(1, FRange.X), False);
         { Compute the new position }
         SetScrollPos(Handle, sb_Horz, FOrigin.X, True);
      end
      else { if not, the ScrollBar is hidden }
          ShowScrollBar( Handle, SB_HORZ, False );

      { If FRange.Y > 0, Vertical Scrollbar needs to be shown }
      if ( FRange.Y > 0 ) then begin
         { Show the ScrollBar }
         ShowScrollBar( Handle, SB_VERT, True );
         { Compute the new range }
         SetScrollRange(Handle, sb_Vert, 0, Max(1, FRange.Y), False);
         { Compute the new position }
         SetScrollPos(Handle, sb_Vert, FOrigin.Y, True);
      end
      else { if not, the ScrollBar is hidden }
          ShowScrollBar( Handle, SB_VERT, False );
   end;
end;

procedure TAnsiView.LoadFromFile(const FileName: string);
var
  i : LongInt;
begin
   FLines.Clear;
   try
      FLines.LoadFromFile(FileName);
   except exit;
   end;
   FileLoaded := true;
   maxstrlen := 0;
   for i:=0 to FLines.Count-1 do begin
     if ( Length( FLines[i] ) > maxstrlen ) then
        maxstrlen := Length( FLines[i] );
   end;
   if FShowPages then
   begin
      RemovePages;
      InsertPages;
   end;
//   maxstrlen := 80;
   RecalcRange;
   Repaint;
   ScrollTo(0, 0);
end;

procedure TAnsiView.GraphicMouseDown(Sender: TObject; Button: TMouseButton;
           Shift: TShiftState; X, Y: Integer);
var
  RectReDraw : TRect;
begin
  GetClickLink( X, Y );
  exit;
  CanMark:=True;
  Marked:=False;
  //MkL0:=VScrollBar.Position+Y div fdy;
  MkL0:=FOrigin.Y+Y div FCharSize.Y;
  //Mkc0:=HScrollBar.Position+X div fdx+1;
  Mkc0 := FOrigin.X + X div FCharSize.X+ 1;
  MkL1:=MkL0; MkL2 := MkL0;
  Mkc1:=Mkc0; Mkc2 := Mkc0;
  //        PaintCanvas(self);
  RectReDraw.Top:=0;
  RectReDraw.Left:=0;
  RectReDraw.Right:=Width;
  RectReDraw.Bottom:=Height;
  DrawBack(canvas.Handle, RectReDraw);
  DrawCanvas;
//  inherited;
  if Assigned(FOnMouseDown) then FOnMouseDown(self,Button,Shift,X,Y);
end;

procedure TAnsiView.GraphicMouseUp(Sender: TObject; Button: TMouseButton;
           Shift: TShiftState; X, Y: Integer);
begin
        if CanMark then Marked:=True;
        CanMark:=False;
//        inherited;
        if Assigned(FOnMouseUp) then FOnMouseUp(self,Button,Shift,X,Y);
end;

procedure TAnsiView.GraphicMouseMove(Sender: TObject;Shift: TShiftState;
           X, Y: Integer);
begin
  if CanMark then
  begin
    MkL2 := Mkl1; Mkc2 := Mkc1;
    MkL1:=FOrigin.Y+Y div FCharSize.Y;
    Mkc1:=FOrigin.X+X div FCharSize.X+1;
    DrawCanvas;
  end;
  //inherited;
  if Assigned(FOnMouseMove) then FOnMouseMove(self,Shift,X,Y);
end;

function TAnsiView.GetClickLink( clickx, clicky : integer): string;
var
  cury : LongInt;
  tx, x, y, i, cy, z : Longint;
  i1, i2, i3, j :integer;
  ct: TColor;
  s, ps, ss : string;
  emailchars : set of char;
  Linklist : TStringList;
  sv : TSVLink;
begin
  sv := TSVLink.Create;
  emailchars := ['a'..'z', '.', 'A'..'Z'];
//  for i:=1 to NumLinks do FreeMem(Links[i],Sizeof(TSVLink));
  Linklist := TStringList.Create;
  NumLinks:=0;
  cury := FOrigin.Y; x := 0; y := 0;
  i := 0; z:=0;
  while (i<FPageSize)and (i<FLines.Count)do
  begin
    //Line := i + cury;
    cy := FCharSize.Y * i + y;
    s := Rowline(FLines[i+cury]); ps := s;
    {draw link}
    //Line := i;
    //MAIL
    ss:= s;
    tx:=x;
    while Pos('@',s) <> 0 do begin
      i1 := Pos('@',s); i2 := i1-1;i3 := i1+1;
      while (i2 > 1) and (s[i2] in emailchars) do dec(i2);
      if i2>=1 then Inc(i2);
      while (i3 <= Length(s)) and (s[i3] in emailchars) do inc(i3);
      //Dec(i3);
      ps:= Copy(s, 1, i2-1);
      Inc(tx, canvas.TextWidth(ps));
      ps := Copy(s, i2, i3-i2);
      Inc(NumLinks);
      //sv := TSVLink.Create;
      sv.Link:=ps;
      sv.LinkType:=ltMailto;
      sv.X0:=tx; sv.Y0:= cy;
      Inc(tx,LOWORD(GetTabbedTextExtent(Canvas.Handle,@ps[1],Length(ps),0,z)));
      //Inc(tx,Canvas.TextWidth(ps));
      sv.X1:=tx;sv.Y1:=cy+FCharSize.y;
      LinkList.AddObject(ps, sv);
      Delete(s,1,i3-1);
     // sv.Free;
    end;
    //            FTP
    s:=ss;
    tx:=x;
    while Pos('ftp://',s)<>0 do begin
      i1:=Pos('ftp://',s);
      ps:=Copy(s,1,i1-1);
      Inc(tx,LOWORD(GetTabbedTextExtent(Canvas.Handle,@ps[1],Length(ps),0,z)));
      Delete(s,1,i1-1);
      i1:=Pos(' ',s);
      j:=Pos(#9,s);
      if (j<>0) and ((j<i) or(i1=0))  then i1:=j;
      if i1=0 then i1:=Length(s)+1;
      ps:=Copy(s,1,i1-1);
      Inc(NumLinks);
      //sv := TSVLink.Create;
      sv.Link:=ps;
      sv.LinkType:=ltFTP;
      sv.X0:=tx; sv.Y0:= cy;
      Inc(tx,LOWORD(GetTabbedTextExtent(Canvas.Handle,@ps[1],Length(ps),0,z)));
      sv.X1:=tx;
      sv.Y1:=cy+FCharSize.y;
      LinkList.AddObject(ps, sv);
      Delete(s,1,i1-1);
      //sv.Free;
    end;
    //HTTP
    s:=ss;
    tx:=x;
    while Pos('http://',s)<>0 do begin
      i1:=Pos('http://',s);
      ps:=Copy(s,1,i1-1);
      Inc(tx,LOWORD(GetTabbedTextExtent(Canvas.Handle,@ps[1],Length(ps),0,z)));
      //Inc(tx, canvas.TextWidth(ps));
      Delete(s,1,i1-1);
      i1:=Pos(' ',s);
      j:=Pos(#9,s);
      if (j<>0) and ((j<i) or(i1=0))  then i1:=j;
      if i1=0 then i1:=Length(s)+1;
      ps:=Copy(s,1,i1-1);
      Inc(NumLinks);
      //sv := TSVLink.Create;
      sv.Link:=ps;
      sv.LinkType:=ltHttp;
      sv.X0:=tx; sv.Y0:= cy;
      Inc(tx,LOWORD(GetTabbedTextExtent(Canvas.Handle,@ps[1],Length(ps),0,z)));
      //Inc(tx,Canvas.TextWidth(ps));
      sv.X1:=tx;
      sv.Y1:=cy+FCharSize.y;
      LinkList.AddObject(ps, sv);
      Delete(s,1,i1-1);
      //sv.Free;
    end;
    Inc(i);
  end;
  for i:=0 to LinkList.Count-1 do
  begin
    sv := TSVLink(LinkList.Objects[i]);
    if (ClickX>=sv.X0) then
      if (ClickX<=sv.X1) then
        if (ClickY>=sv.Y0) then
          if (ClickY<=sv.Y1) then
            if Assigned(FOnLink) then
            begin
              ct:=Canvas.Font.Color;
              Canvas.Font.Color:=clRed;
              Canvas.TextOut(sv.X0,sv.Y0,sv.Link);
              Canvas.Font.Color:=ct;
              FOnLink(self,sv.Link);
            end;
  end;
  LinkList.Free;
  sv.Free;
end;

function TAnsiView.RowLine(s : string) : string;
var
  i : integer;
  r : string;
begin
  i := 1; r := '';
  while i <= Length(s) do begin
    if (s[i] = #27) and (s[i+1] = '[') then begin
      while (s[i] <> 'm') and (i<Length(s)) do Inc(i);
      if s[i] = 'm' then Inc(i);
    end;
    if i<= Length(s) then r := r + s[i];
    Inc(i);
  end;
  Result := r;
end;

procedure TAnsiView.Paint;
var
   RectRedraw:TRect;
begin
   {added myself}
   RectReDraw.Top:=0;
   RectReDraw.Left:=0;
   RectReDraw.Right:=Width;
   RectReDraw.Bottom:=Height;
   DrawBack(canvas.Handle, RectReDraw);
   DrawCanvas;
end;

procedure TAnsiview.DrawCanvas;
var
  z, line, t : Longint;
  ocb, ocf : TColor;
  ofs : TFontStyles;
  ps, s, ss: string;
  Switched: Boolean;
   cy, tx, y, wp, swc, j, cury, x, i, i1, i2, i3: longint;
   flag: Word;
//   tmpstr: string;
//   tmpwrd: string;
//   err: array[0..50]of char;
//   err1: array[0..50]of char;
//   outstr: array[0..255]of char;
   emailchars : set of char;
   r : TRect;
begin
   i3 := 0;
   Switched := false;
   emailchars := ['a'..'z', '.', 'A'..'Z'];
   AnsiColor := FTextColor;
   AnsiBackGround := FColor;
   bmp.Width := Width; bmp.Height := Height;
//   bmp.Assign(BackgroundBitmap);
   bmp.Canvas.Brush.Color := FSelColor;
   bmp.Canvas.FillRect(Rect(0, 0, Width, Height));

   if ( ( BackgroundStyle = bsNoBitmap ) or ( AnsiBackground <> FColor ) ) then begin
      Canvas.Brush.Style := bsSolid;
      Canvas.Brush.Color := AnsiBackground;
   end
   else
       Canvas.Brush.Style := bsClear;

   y := 0;
   if Border = bsSingle then
   begin
      Canvas.Pen.Style := psSolid;
      Canvas.Pen.Color := clBlack;
      Canvas.Pen.Width := 1;
      Canvas.Rectangle(0, 0, Width, Height);
      x := FOrigin.X + 1;
      Y := 1;
   end
   else
   begin
      x := FOrigin.X;
   end;

   SetViewportOrgEx(Canvas.Handle, -FOrigin.X * FCharSize.X, 0, nil );
   if FLines.Count<>0 then
   begin
      NumLinks:=0;
      if (MkL1<MkL0) or ((MkL1=MkL0) and (Mkc1<Mkc0)) then
      begin
        t:=MkL0;
        MkL0:=MkL1;
        MkL1:=t;
        t:=Mkc0;
        Mkc0:=Mkc1;
        Mkc1:=t;
        Switched:=True;
      end
      else Switched:=False;
      Canvas.Font := FFont;
      cury := FOrigin.Y;
      i := 0;
      z:=0;

      canvas.Brush.Style := bsClear;
      canvas.CopyMode := cmSrcAnd;
      if (CanMark or Marked) then begin
        r.Left := x; r.Right := x+Width;
        if Mkl2>= Mkl1 then begin
          r.Top := (-cury+MkL1)*FCharSize.Y; r.Bottom := (-cury+Mkl2+1)*FCharSize.Y;
        end
        else begin
          r.Top := (-cury+MkL2-1)*FCharSize.Y; r.Bottom := (-cury+Mkl1)*FCharSize.Y;
        end;
        canvas.Brush.Style := bsSolid;
        //canvas.Brush.Color := FSelcolor;
        canvas.FillRect(r);
        canvas.Brush.Style := bsClear;
      end;
      while (i<FPageSize)and (i<FLines.Count)do
      begin
            Line := i + cury; cy := FCharSize.Y * i + y;
            s := Rowline(FLines[i+cury]); ps := s;
            if not (CanMark or Marked) then begin
              //canvas.Brush.Style := bsClear;
              AnsiWrite(canvas, x, cy, FLines[i + cury]);
            end else
            begin
              AnsiWrite(canvas, x, cy, FLines[i + cury]);
              if (Line<MkL0) or (Line>MkL1) then

              else begin
              //r.Left := x; r.Right := Width;
              //r.Top := cy; r.Bottom := cy+FCharSize.Y;
              //canvas.CopyRect(r, bmp.Canvas, r);
                //TabbedTextOut(Canvas.Handle,x,y,@s[1],Length(s),0,z,0);
                //AnsiWrite(canvas, x, cy, FLines[i+ cury]);
             //tx:=x;
              if Line=MkL0 then begin
                if MkL1=Line then begin
                  r.Left := Mkc0*FCharSize.X; r.Top := cy;
                  r.Right := Mkc1*FCharSize.X; r.Bottom := cy+FCharSize.Y;
                  canvas.CopyRect(r, bmp.Canvas, r);
                end
                else begin
                  r.Left := (Mkc0-1)*FCharSize.X; r.Top := cy;
                  r.Right := Width; r.Bottom := cy+FCharSize.Y;
                  canvas.CopyRect(r, bmp.Canvas, r);
                end;
              end;
              if (Line>MkL0) and (Line<MkL1) then begin
                r.Left := 0; r.Top := cy;
                r.Right := Width; r.Bottom := cy+FCharSize.Y;
                canvas.CopyRect(r, bmp.Canvas, r);
              end;
              if ((Line=MkL1) and (Line<>MkL0)) then begin
                r.Left := 0; r.Top := cy;
                r.Right := Mkc1*FCharSize.X; r.Bottom := cy+FCharSize.Y;
                canvas.CopyRect(r, bmp.Canvas, r);
              end;
              end;
            end;
            {draw link}
            //Line := i;
            //MAIL
            emailchars := ['a'..'z', '.', 'A'..'Z', '-', '_', '1'..'9', '0'];
            ss:=Rowline(FLines[i+cury]); s := ss;
            tx:=x;
            while Pos('@',s) <> 0 do begin
              i1 := Pos('@',s); i2 := i1-1;i3 := i1+1;
              while (i2 > 1) and (s[i2] in emailchars) do dec(i2);
              if i2>=1 then Inc(i2);
              while (i3 <= Length(s)) and (s[i3] in emailchars) do inc(i3);
              //Dec(i3);
              ps:= Copy(s, 1, i2-1);
              Inc(tx,LOWORD(GetTabbedTextExtent(Canvas.Handle,@ps[1],Length(ps),0,z)));
              //Inc(tx, canvas.TextWidth(ps));
              ps := Copy(s, i2, i3-i2);
              ocb:=canvas.Font.Color;
              canvas.Font.color:=SelectColor;
              ofs:=canvas.Font.Style;
              canvas.Font.Style:=[fsUnderline];
              TabbedTextOut(Canvas.Handle,tx,cy,@ps[1],Length(ps),0,z,0);
              //Canvas.TextOut(tx, cy, ps);
{              Inc(NumLinks);
              GetMem(Links[NumLinks],Sizeof(TSVLink));
              Links[NumLinks]^.Link:=ps;
              Links[NumLinks]^.LinkType:=ltMailto;
              Links[NumLinks]^.X0:=tx;
              Links[NumLinks]^.Y0:= cy;
              Inc(tx,LOWORD(GetTabbedTextExtent(Canvas.Handle,@ps[1],Length(ps),0,z)));
              //Inc(tx,Canvas.TextWidth(ps));
              Links[NumLinks]^.X1:=tx;
              Links[NumLinks]^.Y1:=cy+FCharSize.y;}
              canvas.Font.Color:=ocb;
              canvas.Font.Style:=ofs;
              Delete(s,1,i3-1);
            end;
//            FTP
            s:=ss; tx:=x;
            emailchars := ['a'..'z', '.', 'A'..'Z', '-', '_',
                       '1'..'9', '0', ':', '~', '/'];
            while Pos('ftp://',s)<>0 do begin
              i1:=Pos('ftp://',s);
              ps:=Copy(s,1,i1-1);
              Inc(tx,LOWORD(GetTabbedTextExtent(Canvas.Handle,@ps[1],Length(ps),0,z)));
              Delete(s,1,i1-1);
              while (i3 <= Length(s)) and (s[i3] in emailchars) do inc(i3);
              i1 := i3;
              if i1=0 then i1:=Length(s)+1;
              ps:=Copy(s,1,i1-1);
              ocb:=canvas.Font.Color;
              canvas.Font.color:=SelectColor;
              ofs:=canvas.Font.Style;
              canvas.Font.Style:=[fsUnderline];
              TabbedTextOut(Canvas.Handle,tx,cy,@ps[1],Length(ps),0,z,0);
{              Inc(NumLinks);
              GetMem(Links[NumLinks],Sizeof(TSVLink));
              Links[NumLinks]^.Link:=ps;
              Links[NumLinks]^.LinkType:=ltFTP;
              Links[NumLinks]^.X0:=tx;
              Links[NumLinks]^.Y0:= cy;
              Inc(tx,LOWORD(GetTabbedTextExtent(Canvas.Handle,@ps[1],Length(ps),0,z)));
              Links[NumLinks]^.X1:=tx;
              Links[NumLinks]^.Y1:=cy+FCharSize.y;}
              canvas.Font.Color:=ocb;
              canvas.Font.Style:=ofs;
              Delete(s,1,i1-1);
            end;
            //HTTP
            s:=ss;
            tx:=x;
            while (Pos('http://',s) <> 0) do begin
              i1:=Pos('http://',s);
              ps:=Copy(s,1,i1-1);
              Inc(tx,LOWORD(GetTabbedTextExtent(Canvas.Handle,@ps[1],Length(ps),0,z)));
              //Inc(tx, canvas.TextWidth(ps));
              Delete(s,1,i1-1);
              while (i3 <= Length(s)) and (s[i3] in emailchars) do inc(i3);
              i1 := i3;
              if i1=0 then i1:=Length(s)+1;
              ps:=Copy(s,1,i1-1);
              ocb:=canvas.Font.Color;
              canvas.Font.color:=SelectColor;
              ofs:=canvas.Font.Style;
              canvas.Font.Style:=[fsUnderline];
              TabbedTextOut(Canvas.Handle,tx,cy,@ps[1],Length(ps),0,z,0);
              //Canvas.TextOut(tx, cy, ps);
{              Inc(NumLinks);
              GetMem(Links[NumLinks],Sizeof(TSVLink));
              Links[NumLinks]^.Link:=ps;
              Links[NumLinks]^.LinkType:=ltHttp;
              Links[NumLinks]^.X0:=tx;
              Links[NumLinks]^.Y0:= cy;
              Inc(tx,LOWORD(GetTabbedTextExtent(Canvas.Handle,@ps[1],Length(ps),0,z)));
              //Inc(tx,Canvas.TextWidth(ps));
              Links[NumLinks]^.X1:=tx;
              Links[NumLinks]^.Y1:=cy+FCharSize.y;}
              canvas.Font.Color:=ocb;
              canvas.Font.Style:=ofs;
              Delete(s,1,i1-1);
            end;
//            TabbedTextOut(Canvas.Handle,tx,cy,@s[1],Length(s),0,z,0);
//            if Length(s)>maxl then maxl:=Length(s);
//            Inc(y,fdy);
            //Inc(Line);
            Canvas.Font := FFont;
            //i := Line;
            if (i + cury) = (FLines.Count - 1) then Exit;
            inc(i);
      end;
//      FRange.HScrollBar.Max:=maxl;
   end;
   if Switched then begin
     t:=MkL0;
     MkL0:=MkL1;
     MkL1:=t;
     t:=Mkc0;
     Mkc0:=Mkc1;
     Mkc1:=t;
   end;

end;

{-------------------------------------}
procedure TAnsiView.SetBackgroundStyle(Value: TBackgroundStyle);
begin
  FBackgroundStyle := Value;
  if FBackBitmap.Empty then
     FullRedraw := False
  else
     case FBackgroundStyle of
       bsNoBitmap, bsTiledAndScrolled:
               FullRedraw := False;
       bsStretched, bsTiled:
               FullRedraw := True;
     end;
  Invalidate;
end;
{-------------------------------------}
procedure TAnsiView.SetBackBitmap(Value: TBitmap);
begin
  FBackBitmap.Assign(Value);
  if (Value=nil) or (Value.Empty) then
     FullRedraw := False
  else
     case FBackgroundStyle of
       bsNoBitmap, bsTiledAndScrolled:
               FullRedraw := False;
       bsStretched, bsTiled:
               FullRedraw := True;
     end;
  Invalidate;
end;
{-------------------------------------}
procedure TAnsiView.DrawBack(DC: HDC; Rect: TRect);
var i, j: Integer;
    hbr: HBRUSH;
begin
 if FBackBitmap.Empty or (FBackgroundStyle=bsNoBitmap) then begin
   hbr := CreateSolidBrush(ColorToRGB(FColor));
   dec(Rect.Bottom, Rect.Top);
   dec(Rect.Right, Rect.Left);
   Rect.Left := 0;
   Rect.Top := 0;
   FillRect(DC, Rect, hbr);
   DeleteObject(hbr);
  end
 else
   case FBackgroundStyle of
     bsTiled:
      for i:= Rect.Top div FBackBitmap.Height to Rect.Bottom div FBackBitmap.Height do
        for j:= Rect.Left div FBackBitmap.Width to Rect.Right div FBackBitmap.Width do
          BitBlt(DC, j*FBackBitmap.Width-Rect.Left,i*FBackBitmap.Height-Rect.Top, FBackBitmap.Width,
                 FBackBitmap.Height, FBackBitmap.Canvas.Handle, 0, 0, SRCCOPY);
     bsStretched:
          StretchBlt(DC, -Rect.Left, -Rect.Top, ClientWidth, ClientHeight,
                     FBackBitmap.Canvas.Handle, 0, 0, FBackBitmap.Width, FBackBitmap.Height,
                     SRCCOPY);
     bsTiledAndScrolled:
      for i:= (Rect.Top+FOrigin.Y*FCharSize.Y) div FBackBitmap.Height to
              (Rect.Bottom+FOrigin.Y*FCharSize.Y) div FBackBitmap.Height do
        for j:= (Rect.Left+FOrigin.X*FCharSize.X) div FBackBitmap.Width to
                (Rect.Right+FOrigin.X*FCharSize.X) div FBackBitmap.Width do
          BitBlt(DC, j*FBackBitmap.Width-FOrigin.X*FCharSize.X-Rect.Left,i*FBackBitmap.Height-FOrigin.Y*FCharSize.Y-Rect.Top, FBackBitmap.Width,
                 FBackBitmap.Height, FBackBitmap.Canvas.Handle, 0, 0, SRCCOPY);
   end
end;
{-------------------------------------}
procedure TAnsiView.WMEraseBkgnd(var Message: TWMEraseBkgnd);
var r1: TRect;
begin
  if (csDesigning in ComponentState) then exit;
  Message.Result := 1;
  if (OldWidth<ClientWidth) or (OldHeight<ClientHeight) then begin
      GetClipBox(Message.DC, r1);
      DrawBack(Message.DC, r1);
  end;
  OldWidth := ClientWidth;
  OldHeight := ClientHeight;
end;

procedure TAnsiView.SetFont(Fnt: TFont);
begin
   FFont.Assign(Fnt);
        fdy:=Canvas.TextHeight('M');
        fdx:=Canvas.TextWidth('M');
end;

procedure TAnsiView.FontChanged(Sender: TObject);
var
   DC: HDC;
   Save: THandle;
   Metrics: TTextMetric;
begin
   DC := GetDC(0);
   Save := SelectObject(DC, Font.Handle);
   GetTextMetrics(DC, Metrics);
   SelectObject(DC, Save);
   ReleaseDC(0, DC);
   with Metrics do
   begin
      FCharSize.X := tmAveCharWidth;
      FCharSize.Y := tmHeight + tmExternalLeading;
      FOverhang   := Max(tmOverhang, tmMaxCharWidth - tmAveCharWidth);
      RecalcRange;
      Repaint;
   end;
   scx := 0;
   ScrollTo(0, FOrigin.Y);
end;

procedure TAnsiView.SetColor(Col: Tcolor);
begin
   if Col<>FColor then begin
      Fcolor := Col;
      AnsiBackground := Col;
      Repaint;
   end;
end;

procedure TAnsiView.SetSelColor(Col: Tcolor);
begin
   if Col<>FSelColor then
   begin
      FSelcolor := Col;
      Repaint;
   end;
end;

procedure TAnsiView.SetTextColor(Col: Tcolor);
begin
   if Col<>FTextColor then
   begin
      FTextColor := Col;
      FFont.Color := FTextColor;
      AnsiColor := Col;
      Repaint;
   end;
end;

procedure TAnsiView.SetBorder(Bor: TBorderStyle);
begin
   if Bor<>Border then
   begin
      Border := Bor;
      Repaint;
   end;
end;

procedure TAnsiView.WMHScroll(var M: TWMHScroll);
begin
     DoScroll(sb_Horz, M.ScrollCode, M.Pos);
end;

procedure TAnsiView.WMVScroll(var M: TWMVScroll);
begin
     DoScroll(sb_Vert, M.ScrollCode, M.Pos);
end;

procedure TAnsiView.WMSize(var M: TWMSize);
begin
   inherited;
   RecalcRange;
//   Refresh;
end;

procedure TAnsiView.WMGetDlgCode(var M: TWMGetDlgCode);
begin
   M.Result := dlgc_WantArrows or dlgc_WantChars;
end;

procedure TAnsiView.KeyPressed(Sender: TObject;var Key: char);
begin
  case Key of
        'A': {CTRL+A}
                begin
                        SelectAll;
                end;
        'C','X': {CTRL+C,CTRL+X}
                begin
                        CopyToClipboard;
                end;
        else
                begin
                ;
                end;
        end;
  if Assigned(FOnKeyPress) then FOnKeyPress(self,Key);
end;

procedure TAnsiView.KeyDown(var Key: Word; Shift: TShiftState);
var
   I: Integer;
   ch : Char;
begin
   inherited KeyDown(Key, Shift);
   if Char(Key) = #27 then begin
     Marked:=False;
     Refresh;
   end;
   if ssCtrl in shift then begin
     ch := Char(Key);
     KeyPressed(self, ch);
   end;
   if (Key = vk_F1)then
   begin
      Application.HelpContext(HelpContext);
      Exit;
   end;
   if Key <> 0 then
   begin
      for I := 1 to ScrollKeyCount do
         with ScrollKeys[I] do
            if (sKey = Key) and (Ctrl = (Shift = [ssCtrl])) then
            begin
               DoScroll(SBar, Action, 0);
               Exit;
            end;
   end;
end;

procedure TAnsiView.DoScroll(Which, Action, Thumb: longint);
var
   X, Y: longint;
function GetNewPos(Pos, Page, Range: longint): longint;
begin
   case Action of
      sb_LineUp: GetNewPos := Pos - 1;
      sb_LineDown: GetNewPos := Pos + 1;
      sb_PageUp: GetNewPos := Pos - Page;
      sb_PageDown: GetNewPos := Pos + Page;
      sb_Top: GetNewPos := 0;
      sb_Bottom: GetNewPos := Range;
      sb_ThumbPosition,
      sb_ThumbTrack   : GetNewPos := Thumb;
      else
         GetNewPos := Pos;
   end;
end;
begin
   X := FOrigin.X;
   Y := FOrigin.Y;
   case Which of
      sb_Horz: X := GetNewPos(X, FClientSize.X, FRange.X);
      sb_Vert: Y := GetNewPos(Y, FClientSize.Y, FRange.Y);
   end;
   ScrollTo(X, Y);
end;

procedure TAnsiView.ScrollTo(X, Y: longint);
var
   R: TRect;
   OldOrigin: TPoint;
   Num : Integer;
   save: TBackgroundStyle;
begin


   X := Max(0, Min(X, FRange.X));
   Y := Max(0, Min(Y, FRange.Y));
   if (X <> FOrigin.X) or (Y <> FOrigin.Y) then
   begin
      OldOrigin := FOrigin;
      FOrigin.X := X;
      FOrigin.Y := Y;
      if HandleAllocated then begin
         R := Parent.ClientRect;
         if (OldOrigin.X - X)<0 then scx := scx + ((OldOrigin.X - X) * FCharSize.X) + 1 * abs((OldOrigin.X - X))
            else if (OldOrigin.X - X) = 0 then
               else scx := scx + ((OldOrigin.X - X) * FCharSize.X) - 1 * abs((OldOrigin.X - X));

         if Y <> OldOrigin.Y then
               SetScrollPos(Handle, sb_Vert, Y, True);
         if X <> OldOrigin.X then
               SetScrollPos(Handle, sb_Horz, X, True);

         //Reduce flicker
         save := BackgroundStyle;
         BackgroundStyle := bsNoBitmap;

         { First, scroll the non-updated area of the canvas }
         ScrollWindowEx( Handle, (OldOrigin.X - X) * FCharSize.X, (OldOrigin.Y - Y) * FCharSize.Y,
                         nil, @R, 0, @R, 0);

         BackgroundStyle := save;

         { Now, compute the rectangle that needs to be updated }
         R := ClientRect;

         { If the text has been horizontally scrolled...}
         Num := ( ( R.Bottom - R.Top ) div FCharSize.Y ) - 1;

         if ( OldOrigin.Y < Y ) then
            R.Top := R.Top + ( ( Num + OldOrigin.Y - Y ) * FCharSize.Y );

         if ( OldOrigin.Y > Y ) then
            R.Bottom := R.Bottom - ( ( Num - OldOrigin.Y + Y ) * FCharSize.Y );

         { It should be the same if the text has been vertical scrolled, but it does not
           work very well if the font has Italic style }
         {
            Num := ( ( R.Right - R.Left ) div FCharSize.X ) - 1;

            if ( OldOrigin.X < X ) then
               R.Left := R.Left + ( ( Num + OldOrigin.X - X ) * FCharSize.X );

            if ( OldOrigin.X > X ) then
               R.Right := R.Right - ( ( Num - OldOrigin.X + X ) * FCharSize.X );
            }

         { The proper rectangle that needs to be updated is invalidated }
         InvalidateRect(Handle, @R, False);
         Repaint;

      end;
   end;
end;

procedure TAnsiView.RecalceMaxStrLen;
var
  i : integer;
begin
  maxstrlen := 0;
  for i:=0 to FLines.Count-1 do
  begin
    if Length(FLines[i])>maxstrlen then maxstrlen:=Length(FLines[i]);
  end;
end;

procedure TAnsiView.RecalcRange;
begin
   if HandleAllocated then
   begin
      FClientSize.X := ClientWidth div FCharSize.X;
      FClientSize.Y := ClientHeight div FCharSize.Y;
      FPageSize := FClientSize.Y;
      FRange.X := Max(0, maxstrlen*5 div 4 - FClientSize.X);
      FRange.Y := Max(0, FLines.Count - FClientSize.Y);
      if Border = bsSingle then
      begin
         FRange.X := FRange.X + 1;
         FRange.Y := FRange.Y + 1;
      end;
      ScrollTo(Min(FOrigin.X, FRange.X), Min(FOrigin.Y, FRange.Y));
      SetScrollBars;
   end;
end;

procedure TAnsiView.Add(const Str: string);
begin
   try

      //hide cursor
      if (FLines.Count > 0) then begin
        if (FLines[FLines.Count-1] = #$5F) then
          FLines[FLines.Count-1] := #$A0;
       end;

      FLines.Add(str);
      if FShowPages then
      begin
         RemovePages;
         InsertPages;
      end;
      RecalcRange;
      Repaint;
      ScrollTo(0,FRange.y);
   except exit;
   end;
end;


function TAnsiView.GetPos(const Str: string; curpos: longint): longint;
var wp, i: longint;
begin
   i := curpos;
   while i < FLines.Count do
   begin
      wp := pos(UpStr(Str), UpStr(FLines[i]));
      if wp>0 then
      begin
         result := i;
         exit;
      end;
      inc(i);
   end;
   result := curpos;
end;

function TAnsiView.GetCurPos: longint;
begin
   result := FOrigin.Y;
end;

procedure TAnsiView.Print(const fn: string; stpg, endpg: longint; infile, allfile: boolean);
var
   Xs, Ys, y, i, Line, pg: longint;
   PrintTextF: System.TextFile;
begin
   if endpg<stpg then
   begin
      Exit;
   end;
   if infile = true then
   begin
      AssignFile(PrintTextF, fn);
      Rewrite(PrintTextF);
      if allfile = True then
      begin
         for i := 0 to FLines.Count - 1 do WriteLn(PrintTextF, FLines[i]);
         System.Close(PrintTextF);
      end
      else
      begin
         for i := stpg to endpg do
         begin
            Line := (i - 1) * 51;
            while Line<(i * 51) do
            begin
               if Line = FLines.Count - 1 then
               begin
                  System.Close(PrintTextF);
                  Exit;
               end;
               WriteLn(PrintTextF, FLines[Line]);
               Line := Line + 1;
            end;
         end;
         System.Close(PrintTextF);
         Exit;
      end;
   end
   else
   begin
      if AllFile = True then
      begin
         try
            Printer.Title := 'Printing Doc';
            Printer.BeginDoc;
            Printer.Canvas.Font := FFont;
            Printer.Canvas.Font.Size := FFont.Size;
            Xs := (Printer.PageWidth - 100)div 80;
            Xs := Xs * 4;
            Ys := (Printer.PageHeight - 800)div 45;
            pg := 1;
            for i := 0 to FLines.Count - 1 do
            begin
//               Printer.Canvas.TextOut(Xs, i * Ys, FLines[i]);
               AnsiWrite(Printer.Canvas, Xs, i * Ys, FLines[i]);
               if i = pg * 51 then
               begin
                  pg := pg + 1;
                  Printer.NewPage;
               end;
            end;
            Printer.EndDoc;
         except
            Exit;
         end;
         Exit;
      end
      else
      begin
         for i := stpg to endpg do
         begin
            try
               Printer.Title := 'Printing Doc';
               Printer.BeginDoc;
               Printer.Canvas.Font := FFont;
               Xs := (Printer.PageWidth - 100)div 80;
               Ys := (Printer.PageHeight - 800)div 45;
               Printer.Canvas.Font.Size := FFont.Size;
               Xs := Xs * 4;
               Line := (i - 1) * 51;
               y := Ys;
               while Line<(i * 51) do
               begin
                  if Line = FLines.Count - 1 then
                  begin
                     Printer.EndDoc;
                     Exit;
                  end;
//                  Printer.Canvas.TextOut(Xs, 400 + y, FLines[Line]);
                  AnsiWrite(Printer.Canvas, Xs, 400 + Y, FLines[Line]);
                  y := y + Ys;
                  Line := Line + 1;
               end;
               Printer.EndDoc;
            except
               Printer.EndDoc;
               Exit;
            end;
         end;
      end;
   end;
end;





procedure TAnsiView.InsertPages;
var
   i, pgc: longint;
begin
   pgc := FLines.Count div 44;
   PageCount := pgc + 1;
   for i := 0 to pgc do
   begin
      try
         FLines.Insert((i * 44) + i, '------------------------------ Page '
         + IntToStr(i + 1) + '------------------------------------');
      except
         RecalcRange;
         Repaint;
         ScrollTo(0, 0);
         exit;
      end;
   end;
   RecalcRange;
   Repaint;
   ScrollTo(0, 0);
end;

procedure TAnsiView.RemovePages;
var i: longint;
begin
   PageCount := 0;
   for i := FLines.Count - 1 downto 0 do
   begin
      try
         if pos('------------------------------ Page ', FLines[i])>0 then FLines.Delete(i);
      except
         RecalcRange;
         Repaint;
         ScrollTo(0, 0);
         exit;
      end;
   end;
   RecalcRange;
   Repaint;
   ScrollTo(0, 0);
end;

procedure TAnsiView.SetShowPages(Value: boolean);
begin
   if FShowPages<>Value then
   begin
      FShowPages := Value;
      if FShowPages then
      begin
         InsertPages;
      end
      else
      begin
         RemovePages;
      end
   end;
end;


procedure TAnsiView.CutToClipboard;
begin
        CopyToClipboard;
end;

procedure TAnsiView.CopyToClipboard;
var
        l: TStrings;
        Switched: Boolean;
        i,t: integer;
        s: string;
        c: PChar;
begin
        if not Marked then Exit;
        l:=TStringList.Create;
        if MkL1>=Lines.Count then MkL1:=Lines.Count-1;
        if MkL0>=Lines.Count then MkL0:=Lines.Count-1;
        if (MkL1<MkL0) or ((MkL1=MkL0) and (Mkc1<Mkc0)) then
        begin
                t:=MkL0;
                MkL0:=MkL1;
                MkL1:=t;
                t:=Mkc0;
                Mkc0:=Mkc1;
                Mkc1:=t;
                Switched:=True;
        end
        else Switched:=False;
        s:=Lines[MkL0];
        if MkL0=MkL1 then l.Add(Copy(s,Mkc0,Mkc1-Mkc0-1))
        else
        begin
                l.Add(Copy(s,Mkc0,999));
                for i:=MkL0+1 to MkL1-1 do l.Add(Lines[i]);
                s:=Lines[MkL1];
                l.Add(Copy(s,1,Mkc1));
        end;
        if StrLen(l.GetText)<31000 then Clipboard.SetTextBuf(l.GetText)
        else
        begin
                GetMem(c,31000);
                StrLCopy(c,l.GetText,30999);
                c[30999]:=#0;
                Clipboard.SetTextBuf(c);
                FreeMem(c,31000);
        end;
        if Switched then
        begin
                t:=MkL0;
                MkL0:=MkL1;
                MkL1:=t;
                t:=Mkc0;
                Mkc0:=Mkc1;
                Mkc1:=t;
        end;
        l.Free;
end;

procedure TAnsiView.Clear;
begin
  Lines.Clear;
end;

procedure TAnsiView.SelectAll;
begin
        MKL0:=0;
        MKL1:=Lines.Count-1;
        MKc0:=0;
        MKc1:=999;
        Marked:=True;
//        PaintCanvas(Self);
          Repaint;
end;

procedure TAnsiView.AnsiWrite(device : TCanvas; x, y : integer; S : string);
{****************************************************************************}
{***                                                                      ***}
{***    Procedure to process string "s" and write its contents to the     ***}
{***          screen, interpreting ANSI codes as it goes along.           ***}
{***                                                                      ***}
{****************************************************************************}
//   PROCEDURE ANSIWrite(s : string);
VAR
  SaveX, SaveY : word;
  wherex, wherey : integer;
  z, MusicPos : integer;
  sst : string;
  temc : TColor;

   {*** Procedure to process the actual ANSI sequence ***}
     PROCEDURE ProcessEsc;
     VAR
       DeleteNum : integer;
       ts : string[5];
       Num : array[0..20] of byte;

       LABEL loop;

      {*** Procedure to extract a parameter from the ANSI sequence and ***}
      {*** place it in "Num" ***}
         PROCEDURE GetNum(cx : byte);
            VAR
               code : integer;
            BEGIN
               ts := '';
               {reverse the checking to avoid access violation}
               WHILE (length(s) > 0) and (s[1] in ['0'..'9']) DO
                  BEGIN
                     ts := ts + s[1];
                     Delete(s,1,1);
                  END;
               val(ts,Num[cx],code)
            END;

         BEGIN
            IF s[2] <> '[' THEN begin
              Delete(s,1,2);
              exit;
            end;
            Delete(s,1,2);
            if length(s)>0 then
            IF (UpCase(s[1]) = 'M') and (UpCase(s[2]) in ['F','B',#32]) THEN
{| Added allowance for "esc[M " as a valid music prefix in line above. DDA|}

{play music}   BEGIN
                  Delete(s,1,2);
                  MusicPos := pos(#14,s);
//                  Play(copy(s,1,MusicPos-1));
                  DeleteNum := MusicPos;
                  Goto Loop;
               END;
            fillchar(Num,sizeof(Num),#255);
            GetNum(0);
            DeleteNum := 1;
            {adding safety for access violation}
            WHILE (length(s)>0) and (s[1] = ';') and (DeleteNum < 21) DO
               BEGIN
                  Delete(s,1,1);
                  GetNum(DeleteNum);
                  DeleteNum  := DeleteNum + 1;
               END;
            {adding safety for access violation}
            if length(s)>0 then
            CASE UpCase(s[1]) of
{move up}      'A' : BEGIN
                        if Num[0] = 0 THEN
                           Num[0] := 1;
                        WHILE Num[0] > 0 DO
                           BEGIN
//                              GotoXY(wherex,wherey - 1);
                              Num[0] := Num[0] - 1;
                           END;
                        DeleteNum := 1;
                     END;
{move down}    'B' : BEGIN
                        if Num[0] = 0 THEN
                           Num[0] := 1;
                        WHILE Num[0] > 0 DO
                           BEGIN
//                              GotoXY(wherex,wherey + 1);
                              Num[0] := Num[0] - 1;
                           END;
                        DeleteNum := 1;
                     END;
{move right}   'C' : BEGIN
                        if Num[0] = 0 THEN
                           Num[0] := 1;
                        WHILE Num[0] > 0 DO
                           BEGIN
//                              GotoXY(wherex + 1,wherey);
                              Num[0] := Num[0] - 1;
                           END;
                        DeleteNum := 1;
                     END;
{move left}    'D' : BEGIN
                        if Num[0] = 0 THEN
                           Num[0] := 1;
                        WHILE Num[0] > 0 DO
                           BEGIN
//                              GotoXY(wherex - 1,wherey);
                              Num[0] := Num[0] - 1;
                           END;
                        DeleteNum := 1;
                     END;
{goto x,y}     'H',
               'F' : BEGIN
                        if (Num[0] = 0) THEN
                           Num[0] := 1;
                        if (Num[1] = 0) THEN
                           Num[1] := 1;
//                        GotoXY(Num[1],Num[0]);
                        DeleteNum := 1;
                     END;
{save current} 'S' : BEGIN
{position}              SaveX := wherex;
                        SaveY := wherey;
                        DeleteNum := 1;
                     END;
{restore}      'U' : BEGIN
{saved position}//        GotoXY(SaveX,SaveY);
                        DeleteNum := 1;
                     END;
{clear screen} 'J' : BEGIN
                        if Num[0] = 2 THEN
//                           ClrScr;
                        DeleteNum := 1;
                     END;
{clear from}   'K' : BEGIN
{cursor position}//       ClrEOL;
{to end of line}        DeleteNum := 1;
                     END;
{change}       'M' : BEGIN
{colors and}            DeleteNum := 0;
{attributes}            WHILE (Num[DeleteNum] <> 255) or (DeleteNum = 0) DO
                           BEGIN
                              CASE Num[DeleteNum] of
{all attributes off}             0 : BEGIN
{ie. normal white on black}             textattr:=7;
                                        AnsiColor := self.Font.Color;
                                        AnsiBackGround := self.Color;
                                        Bold := false;
                                     END;
{bold on}                        1 : BEGIN
                                        Bold := true;
//                                        HighVideo;
{| Added "HighVideo" line, since "esc[1m" by itself would not otherwise
   activate "Bold". DDA|}

                                     END;
{blink on}//                       5 : textattr := textattr or blink;
{| Changed from "textattr+blink", which would turn blink off if it was
   already on. DDA|}

{reverse on}                     7 : //textattr := ((textattr and $07) shl 4) +
                                     //((textattr and $70) shr 4);
                                     begin
                                       temc := AnsiColor;
                                       AnsiColor := AnsiBackGround;
                                       AnsiBackGround := temc;
                                     end;
{invisible on}                   8 : textattr := 0;
{general foregrounds}            30..
                                 37 : BEGIN
                                         IF Bold THEN
                                           Ansicolor := ColorArray[Num[DeleteNum]
                                                  - 30 + 8]
                                         else
                                           Ansicolor := ColorArray[Num[DeleteNum]
                                                  - 30];
//                                         textcolor((textattr and blink)+color);

{| Added "textattr and blink" to preserve blink status. DDA|}

                                      END;
{general backgrounds}            40..
                                 47 : begin
                                    AnsiBackground := ColorArray[Num[DeleteNum] - 40];
                                 end;
                              END;
                              DeleteNum := DeleteNum + 1;
                           END;
                        DeleteNum := 1;
                     END;
{change text}  '=',
{modes}        '?' : BEGIN
                        Delete(s,1,1);
                        GetNum(0);
                        if Length(s)>0 then
                        if UpCase(s[1]) = 'H' THEN
                           BEGIN
{                              CASE Num[0] of
                                 0 : TextMode(bw40);
                                 1 : TextMode(co40);
                                 2 : TextMode(bw80);
                                 3 : TextMode(co80);
                                 4 : GraphColorMode;
                                 5 : GraphMode;
                                 6 : HiRes;
                                 7 : TruncateLines := false;
                              END;}
                           END;
                        if length(s)>0 then
                        if UpCase(s[1]) = 'L' THEN
                           if Num[0] = 7 THEN
                              TruncateLines := true;
                        DeleteNum := 1;
                     END;
            END;
loop:       Delete(s,1,DeleteNum);
         END;

BEGIN

  if ((length(s) > 0) and (s[1] = ':')) or
     ((length(s) > 0) and (s[1] = '>')) then
    AnsiColor := clTeal
  else AnsiColor := self.Font.Color;

  WHILE length(s) > 0 DO BEGIN
    if s[1] = #27 THEN begin
      device.Font.Color := AnsiColor;
      if sst <> '' then begin
         if ( ( BackgroundStyle = bsNoBitmap ) or ( AnsiBackground <> FColor ) ) then begin
            device.Brush.Color := AnsiBackGround;
            device.Brush.Style := bsSolid;
         end
         else
             device.Brush.Style := bsClear;

        TabbedTextOut(device.Handle,x,y,@sst[1],Length(sst),0,z,0);
//         device.TextOut(x, y, sst);
         x := x + device.TextWidth(sst);
         sst := '';
      end;
      ProcessEsc;
      device.Font.Color := AnsiColor;
    end
    else BEGIN
      //Write(s[1]);
      sst := sst + s[1];
      Delete(s,1,1);
    END;
  END;
  device.Font.Color := AnsiColor;
  if ( ( BackgroundStyle = bsNoBitmap ) or ( AnsiBackground <> FColor ) ) then begin
     device.Brush.Color := AnsiBackGround;
     TabbedTextOut(device.Handle,x,y,@sst[1],Length(sst),0,z,0);
//     device.TextOut(x, y, sst);
     device.Brush.Color := Color;
     device.Brush.Style := bsSolid;
  end
  else begin
       device.Brush.Style := bsClear;
       TabbedTextOut(device.Handle,x,y,@sst[1],Length(sst),0,z,0);
//       device.TextOut(x, y, sst);
  end;
//  x := x + device.TextWidth(sst);
  sst := '';
END;


procedure TAnsiView.SetHideScrollBars( Value : Boolean );
begin
     if ( Value = FHideScrollBars ) then Exit;

     FHideScrollBars := Value;
     SetScrollBars;
end;

procedure Register;
begin
   RegisterComponents('Tango/04', [TAnsiView]);
end;

end.
