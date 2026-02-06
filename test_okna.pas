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
      '1 as ID, ''To jest testowe okno pluginu.'' as INFO',  // SELECT
      'rdb$database',                                        // FROM
      '',                                                    // WHERE
      '',                                                    // GROUP BY
      '',                                                    // HAVING
      ''                                                     // ORDER BY
    );

    okno.IDColumns := 'ID';
    okno.AddFields('Informacja', 'INFO', '');

    if okno.ShowWindowCheckStr(aWhere) then
    begin
      // nic nie robimy – samo wyświetlenie okna
    end;
  finally
    okno.Free;
  end;
end.