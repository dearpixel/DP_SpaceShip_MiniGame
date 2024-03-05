//Игра с физикой корабля на двух турбинах. Типо приземлиться надо правильно, управление сложноватое, но аккуратное.
Uses GraphABC, System.Windows.Forms;

var
  ///Ширина окна
  W := WindowWidth;
  H := WindowHeight;
  ///Игровые клавиши
  GUP, GRIGHT, GLEFT: boolean;
  ///Что по X?
  GameKey: integer;
  ///Проигрыш
  GameOver := false;
  ///Победа
  Win: boolean;
  ///Клавиша подтверждения
  ENTER: boolean;
  KeyPressed: boolean;

procedure KeyDown(key: integer);
begin
  case key of
    VK_UP: GUP := true;
    VK_RIGHT: GRIGHT := true;
    VK_LEFT: GLEFT := true;
    VK_ENTER: ENTER := true;
  end;
  KeyPressed := true;
end;

procedure KeyUp(key: integer);
begin
  case key of
    VK_UP: GUP := false;
    VK_RIGHT: GRIGHT := false;
    VK_LEFT: GLEFT := false;
    VK_ENTER: ENTER := false;
  end;
  KeyPressed := false;
end;

procedure InitApplication;
begin
  Window.Title := 'UFO';
  Font.Size := 25;
  OnKeyDown := KeyDown;
  OnKeyUp := KeyUp;
  LockDrawing;
end;

type
  _Ship = class
  private
    ///Координаты корабля
    X, Y: double;
    ///Укорение по осям
    X1, Y1: double;
    ///Наклон корабля
    Angle: integer;
    ///Максимальное Y1 для ограничения X1
    //MaxY1: double;
    ///Прошлый угол для сохранения X1 при повороте
    //LastAngle: integer;
    ///Очки игрока
    Score := 0;
    ///Картинка корабля
    Pic: Picture;
    ///Корабль с включенным двигателем
    Pic2: Picture;
  public
    constructor Create(_X, _Y: integer);
    begin
      X := _X;
      Y := _Y;
      Pic := Picture.Create('UFO.png');
      Pic.Transparent := true;
      Pic2 := Picture.Create('UFO2.png');
      Pic2.Transparent := true;
    end;
    
    procedure Spawn(_X, _Y: integer);
    begin
      X := _X;
      Y := _Y;
      X1 := 0;
      Y1 := 0;
      Angle := 0;
      Score := 0;
    end;
    ///Нарисовать корабль
    procedure Show;
    begin
      if GUP then
        Pic2.Draw(Round(X), Round(Y), Angle, Pic.Width, Pic.Height)
      else
        Pic.Draw(Round(X), Round(Y), Angle, Pic.Width, Pic.Height);
    end;
    ///Обработать движение корабля
    procedure Move(_X: integer; _Y: boolean);
    begin
      if _Y then //Дать ускорение кораблю,
      begin
        if Y1 < 0 then
          X1 += Cos(DegToRad(Angle + 90)) * Y1 * 0.2
        else
          X1 -= Cos(DegToRad(Angle + 90)) * Y1 * 0.2;
        
        if (Angle > 90) and (Angle < 270) then//(Angle < 90) and (Angle > -180) then //Отследить переворот корабля, не работает
          Y1 += 0.02
        else
          Y1 -= 0.02;
        
        {if Y1 < 0 then//Здесь проблема
        begin
        MaxY1 := Y1;
        LastAngle := Angle;
        end;}//Нету кода нет проблемы))
      end
      else
        Y1 += 0.03; //или имитировать гравитацию
      
      if _X = 1 then //Поворот по стрелкам ЛЕВО ПРАВО
        Angle += 1
      else
      if _X = -1 then
        Angle -= 1;
      if Angle > 360 then Angle -= 360;
      if Angle < 0 then Angle += 360;
      
      Y += Y1;
      X += X1;
      
      //if X1 > Abs(Cos(DegToRad(LastAngle+90))*MaxY1) then X1 := Abs(Cos(DegToRad(LastAngle+90))*MaxY1); //Инерция ломается, надо что то сделать с angle и maxy1
      //if X1 < -Abs(Cos(DegToRad(LastAngle+90))*MaxY1) then X1 := -Abs(Cos(DegToRad(LastAngle+90))*MaxY1);
      if X1 > 3 then X1 := 3;
      if X1 < -3 then X1 := -3;
      if Y1 < -2 then Y1 := -2;
      if Y1 > 3 then Y1 := 3;
      if (Y > H - Pic.Height) or (Y < 0) or (X > W - Pic.Width) or (X < 0) then //Здесь могла быть обработка столкновения со стеной, если добавить карту
      begin
        Y -= Y1 * 2;
        X -= X1 * 2;
        Y1 := 0;
        X1 := 0;
        GameOver := true;
      end;
      if (Y < Pic.Height) and (Abs(Y1) < 0.01) then
        Win := true;
    end;
  end;

var
  ///Корабль
  Ship: _Ship;

procedure GetGameKey;
begin
  if GRIGHT then GameKey := 1
    else
  if GLEFT then GameKey := -1
  else
    GameKey := 0;
end;

procedure ShowWinZone;
begin
  Brush.Color := clGreen;
  FillRect(0, 0, W, 64);
end;

begin
  InitApplication;
  Ship := _Ship.Create(Round(W / 2) - 32, Round(H / 2)); //Это можно было перенести в процедуру InitObjects; , но здесь создаётся не так много объектов
  ClearWindow(clBlack);
  while true do
  begin
    while not GameOver and not Win do
    begin
      GetGameKey;
      Brush.Color := ARGB(16, 0, 0, 0);
      FillRect(0, 0, W, H);
      ShowWinZone;
      Ship.Move(GameKey, GUP);
      Ship.Show;
      Redraw;
    end;
    //lose
    if GameOver then
    begin
      ClearWindow(clGray);
      DrawTextCentered(0, 0, W, H, 'Проигрыш' + newline + 'Нажмите кнопку чтобы повторить');
      Redraw;
      while not KeyPressed do Sleep(1);
      GameOver := false;
      ClearWindow(clBlack);
      Ship.Spawn(Round(W / 2) - 32, Round(H / 2));
    end
    else//win
    begin
      ClearWindow(clGray);
      DrawTextCentered(0, 0, W, H, 'Победа! Это было так сложно, правда?' + newline + 'Нажмите кнопку чтобы повторить');
      Redraw;
      while not KeyPressed do Sleep(1);
      Win := false;
      ClearWindow(clBlack);
      Ship.Spawn(Round(W / 2) - 32, Round(H / 2));
    end;
  end;
end.