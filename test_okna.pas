{$AT TWindowPlugins}
program test_okna;

var
  okno: TWindowPlugins;
  aWhere: string;

begin
  okno := TWindowPlugins.Create(7);
  try
    okno.Caption := 'Test pluginu';

    okno.SqlSet(
      '1 as ID, ''To jest testowe okno pluginu.'' as INFO', // Pole nazywa się INFO
      'rdb$database',
      '',
      '',
      '',
      ''
    );

    okno.IDColumns := 'ID';

    if okno.ShowWindowCheckStr(aWhere) then
    begin
       // Logika po zamknięciu okna
    end;
  finally
    okno.Free;
  end;
end.