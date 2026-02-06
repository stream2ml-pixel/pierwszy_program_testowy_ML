 //M.K. 202510

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
      //inf300(inttostr(id_miesobr));
    end;
  finally
    my_okno1.Free;
  end;


  //id_miesobr:=10003;


  my_getuser:=getuser;
  //my_getuser:='MPIESIO';

{
  //my_getuser:='LOG1';
  c:=TfCzytajCos.Create(nil);
  i:=1;
  try
    lista1:=['LOG1','SPYTLARCZYK','MMIANOWSKI','AWOJDAT','KZIELINSKI'];

    if c.CzytajCosZComboText('Wybierz login tymczasowy', my_getuser, lista1)
    //if c.CzytajCosZCombo('Wybierz login tymczasowy',i,lista1)
    then
    begin
      if i=0 then my_getuser:='LOG1';
      if i=1 then my_getuser:='SPYTLARCZYK';
      if i=2 then my_getuser:='MMIANOWSKI';
      if i=3 then my_getuser:='AWOJDAT';
      if i=4 then my_getuser:='KZIELINSKI';

      //inf300(my_getuser);
      //inf300('w49');
    end;

  finally
    c.Free;
  end;
}
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
    //my_okno.fQueryTmp.UnMarkAllRows(False);
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
  //mies1:=copy(datetimetostr(Now()),1,10);
  data1:=getfromquerysql('SELECT cast(R.ROKKAL || ''-'' || MO.MIESKAL || ''-01'' as date)'
  +' FROM MIESOBR MO join ROKKAL R on R.ID_ROKKAL=MO.ID_ROKKAL where MO.ID_MIESOBR='+inttostr(ID_MIESOBR),0);
  {
  inf300(login1);
  pracownik1:=getfromquerysql('select first 1 P.KAL_NAZWISKOIMIE'
  +' from PRACOWNIK P'
  +' join OKRESLCECHY OC on OC.ID_PRACOWNIK=P.ID_PRACOWNIK'
  +' where OC.ID_CECHA=10021 and OC.WARTOSC='''+login1+'''',0);
  }
  sql:='select NAZWISKOIMIE from UZYTKOWNIK where LOGIN='''+login1+'''';
  pracownik1:=getfromquerysql(sql,1);

  my_okno:=TWindowPlugins.Create(7);
  try
    my_okno.Caption:='Premie podwładnych pracownika '+pracownik1+' na miesiąc '+copy(DATA1,1,7);
    my_okno.IDColumns:='ID_PRACOWNIK'
    my_okno.SqlSet('P2.ID_PRACOWNIK,S2.NAZWA,P2.KAL_NAZWISKOIMIE,X1.PREMIA'
    //+',''M'+copy(mies1,1,4)+copy(mies1,6,2)+''''
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
{
    my_okno.AddFields('PRACOWNIK','ID_PRACOWNIK','P');
    my_okno.Lastfield.Visible:=False;
    my_okno.AddFields('STANOWISKO','NAZWA','S2');
    my_okno.AddFields('PRACOWNIK','KAL_NAZWISKOIMIE','P2');
    my_okno.AddFieldsXXX('XXX_MK_PREMIA_DO_PLAC','PREMIA','Wysokość premii','X1');
}
    my_okno.AddAction('Przyznaj premie','money_bag_24',@przyznaj_premie)
    if my_okno.ShowWindowCheckStr(aWhere) then begin

    end;
  finally
    my_okno.Free;
  end;
end;

begin
  //inf300('Wybrano login '+pobierz_login);
  premie(pobierz_login(id_miesobr));
end.