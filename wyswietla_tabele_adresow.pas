program test_okna;

var
  okno: TWindowPlugins;
  aWhere: string;

begin
  okno := TWindowPlugins.Create(7);
  try
    okno.Caption := 'Test pluginu';

    okno.SqlSet(
      'ID_ADRES, MIEJSCOWOSC, KODPOCZTOWY, POCZTA, ULICA, NRDOMU', // Wybrane kolumny z tabeli ADRES
      'ADRES', // Tabela źródłowa
      '',
      '',
      '',
      ''
    );

    okno.IDColumns := 'ID_ADRES'; // Kolumna identyfikująca rekord

    if okno.ShowWindowCheckStr(aWhere) then
    begin
       // Logika po zamknięciu okna
    end;
  finally
    okno.Free;
  end;
end.