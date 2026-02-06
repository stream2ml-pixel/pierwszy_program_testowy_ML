{$AT TFCzytajCos}
{$AT TWindowPlugins}
program premie_podwladnych;
var
  id_miesobr: integer;
  my_okno: TWindowPlugins;
  aWhere: string;


function pobierz_login(var id_miesobr: integer): string;
var
  my_okno1: TWindowPlugins;
  my_getuser: string;
  id_miesobr2: integer;

  c: TfCzytajCos;
  lista1: array of variant;
  i: integer;
begin

  id_miesobr2:=0;
  my_okno1:=TWindowPlugins.Create(5);
  try
    my_okno1.Caption:='Wybierz miesiąc';
    my_okno1.IDColumns:='ID_MIESOBR'
    my_okno1.SqlSet('MO.ID_MIESOBR,MO.MIESKAL,RK.ROKKAL'
    ,'miesobr MO'
    +' join ROKKAL RK on RK.ID_ROKKAL=MO.ID_ROKKAL'
    ,'RK.ROKKAL>2025','','','');
    my_okno1.AddFields('MIESOBR','ID_MIESOBR','MO');
    my_okno1.LastField.Visible:=False;
    my_okno1.AddFields('MIESOBR','MIESKAL','MO');
    my_okno1.AddFields('ROKKAL','ROKKAL','RK');
    if my_okno1.ShowWindow(id_miesobr2) then begin
      id_miesobr:=id_miesobr2;
    end;
  finally
    my_okno1.Free;
  end;

  my_getuser:=getuser;
  result:=my_getuser;
end;

procedure przyznaj_premie_w_wysokosci(premia: integer);
var
  my_query: TDataSource;
begin
  my_query:=openquerysql('select ID_PRACOWNIK from PRACOWNIK where ID_PRACOWNIK in ('+my_okno.getIdValueCheckStr+')',0);
  if my_query<>nil then begin
    my_query.dataset.First;
    while not my_query.dataset.eof do begin
      executesql('update or insert into XXX_MK_PREMIA_DO_PLAC (ID_PRACOWNIK,ID_MIESOBR,PREMIA)'
      +' values ('+my_query.dataset.fieldbyname('ID_PRACOWNIK').asstring
      +','+inttostr(id_miesobr)
      +','+inttostr(premia)
      +') MATCHING (ID_PRACOWNIK,ID_MIESOBR)',0);
      my_query.dataset.Next;
    end;
    closequerysql(my_query);
  end;
end;

procedure przyznaj_premie(asender: TObject);
var
  c: TfCzytajCos;
  premia: integer;
begin
  premia:=0;
  c:=TfCzytajCos.Create(nil);
  try
    if c.CzytajCosInteger('Podaj wysokość premii',premia,0,1000000,True) then begin
      przyznaj_premie_w_wysokosci(premia);
    end;

    my_okno.Refresh;
  finally
    c.Free;
  end;
end;

procedure premie(login1: string);
var
  data1: string;
  pracownik1: string;
  sql: string;
begin
  data1:=getfromquerysql('SELECT cast(R.ROKKAL || ''-'' || MO.MIESKAL || ''-01'' as date)'
  +' FROM MIESOBR MO join ROKKAL R on R.ID_ROKKAL=MO.ID_ROKKAL where MO.ID_MIESOBR='+inttostr(ID_MIESOBR),0);

  sql:='select NAZWISKOIMIE from UZYTKOWNIK where LOGIN='''+login1+'''';
  pracownik1:=getfromquerysql(sql,1);

  my_okno:=TWindowPlugins.Create(7);
  try
    my_okno.Caption:='Premie podwładnych pracownika '+pracownik1+' na miesiąc '+copy(DATA1,1,7);
    my_okno.IDColumns:='ID_PRACOWNIK'
    my_okno.SqlSet('P2.ID_PRACOWNIK,S2.NAZWA,P2.KAL_NAZWISKOIMIE,X1.PREMIA'
    ,'OKRESLCECHY OC'
    +' join PRACOWNIK P on P.ID_PRACOWNIK=OC.ID_PRACOWNIK'
    +' join ANGAZ A on A.ID_PRACOWNIK=P.ID_PRACOWNIK'
    +' join ZASZEREG Z on Z.ID_ANGAZ=A.ID_ANGAZ'
    +' and (Z.DATAROZPOCZECIA<dateadd(month,1,cast('''+data1+''' as date)))'
    +' and (Z.DATAZAKONCZENIA>cast('''+data1+''' as date) or Z.DATAZAKONCZENIA is null)'
    +' join STANOWISKO S on S.ID_STANOWISKO=Z.ID_STANOWISKO'
    +' join STANOWISKO S2 on S2.STA_ID_STANOWISKO=S.ID_STANOWISKO'
    +' join ZASZEREG Z2 on Z2.ID_STANOWISKO=S2.ID_STANOWISKO'
    +' and (Z2.DATAROZPOCZECIA<dateadd(month,1,cast('''+data1+''' as date)))'
    +' and (Z2.DATAZAKONCZENIA>cast('''+data1+''' as date) or Z2.DATAZAKONCZENIA is null)'
    +' join ANGAZ A2 on A2.ID_ANGAZ=Z2.ID_ANGAZ'
    +' join PRACOWNIK P2 on P2.ID_PRACOWNIK=A2.ID_PRACOWNIK'
    +' left join XXX_MK_PREMIA_DO_PLAC X1 on X1.ID_PRACOWNIK=P2.ID_PRACOWNIK and X1.ID_MIESOBR='+inttostr(id_miesobr)
    ,'OC.ID_CECHA=10026 and OC.WARTOSC='''+login1+'''','','','');
    my_okno.AddAction('Przyznaj premie','money_bag_24',@przyznaj_premie)
    if my_okno.ShowWindowCheckStr(aWhere) then begin

    end;
  finally
    my_okno.Free;
  end;
end;

begin
  premie(pobierz_login(id_miesobr));
end.