unit gnugettext;
(**************************************************************)
(*                                                            *)
(*  (C) Copyright by Lars B. Dybdahl and others               *)
(*  E-mail: Lars@dybdahl.dk, phone +45 70201241               *)
(*  You may distribute and modify this file as you wish       *)
(*  for free                                                  *)
(*                                                            *)
(*  Contributors: Peter Thornqvist, Troy Wolbrink,            *) 
(*                Frank Andreas de Groot                      *)
(*                                                            *)
(*  See http://dybdahl.dk/dxgettext/ for more information     *)
(*                                                            *)
(**************************************************************)

interface

{$ifdef VER100}
  // Delphi 3
  {$DEFINE DELPHI5OROLDER}
  {$DEFINE DELPHI6OROLDER}
{$endif}
{$ifdef VER110}
  // C++ Builder 3
  {$DEFINE DELPHI5OROLDER}
  {$DEFINE DELPHI6OROLDER}
{$endif}
{$ifdef VER120}
  // Delphi 4
  {$DEFINE DELPHI5OROLDER}
  {$DEFINE DELPHI6OROLDER}
{$endif}
{$ifdef VER125}
  // C++ Builder 4
  {$DEFINE DELPHI5OROLDER}
  {$DEFINE DELPHI6OROLDER}
{$endif}
{$ifdef VER130}
  // Delphi 5
  {$DEFINE DELPHI5OROLDER}
  {$DEFINE DELPHI6OROLDER}
  {$ifdef WIN32}
  {$DEFINE MSWINDOWS}
  {$endif}
{$endif}
{$ifdef VER135}
  // C++ Builder 5
  {$DEFINE DELPHI5OROLDER}
  {$DEFINE DELPHI6OROLDER}
  {$ifdef WIN32}
  {$DEFINE MSWINDOWS}
  {$endif}
{$endif}
{$ifdef VER140}
  // Delphi 6
{$ifdef MSWINDOWS}
  {$DEFINE DELPHI6OROLDER}
{$endif}
{$endif}
{$ifdef VER150}
  // Delphi 7
{$endif}

uses
{$ifdef DELPHI5OROLDER}
  gnugettextD5,
{$endif}
  Classes, SysUtils;

(*****************************************************************************)
(*                                                                           *)
(*  MAIN API                                                                 *)
(*                                                                           *)
(*****************************************************************************)

// All these identical functions translate a text
function _(const szMsgId: widestring): widestring;
function gettext(const szMsgId: widestring): widestring;

// Translates a component (form, frame etc.) to the currently selected language.
// Put TranslateComponent(self) in the OnCreate event of all your forms.
// See the FAQ on the homepage if your application takes a long time to start.
procedure TranslateComponent(AnObject: TComponent; TextDomain:string='');

// Add more domains that resourcestrings can be extracted from. If a translation
// is not found in the default domain, this domain will be searched, too.
// This is useful for adding mo files for certain runtime libraries and 3rd
// party component libraries
procedure AddDomainForResourceString (domain:string);

// Set language to use
procedure UseLanguage(LanguageCode: string);

// Unicode-enabled way to get resourcestrings, automatically translated
// Use like this: ws:=LoadResStringW(@NameOfResourceString);
function LoadResString(ResStringRec: PResStringRec): widestring;
function LoadResStringA(ResStringRec: PResStringRec): ansistring;
function LoadResStringW(ResStringRec: PResStringRec): widestring;



(*****************************************************************************)
(*                                                                           *)
(*  ADVANCED FUNCTIONALITY                                                   *)
(*                                                                           *)
(*****************************************************************************)

const
  DefaultTextDomain = 'default';

(*
 Make sure that the next TranslateProperties(self) will ignore
 the string property specified, e.g.:
 TP_Ignore (self,'ButtonOK.Caption');   // Ignores caption on ButtonOK
 TP_Ignore (self,'MyDBGrid');           // Ignores all properties on component MyDBGrid
 TP_Ignore (self,'.Caption');           // Ignores self's caption
 Only use this function just before calling TranslateProperties(self).
 If this function is being used, please only call TP_Ignore and TranslateProperties
 From the main thread.
*)
procedure TP_Ignore(AnObject:TObject; const name:string);

// Make TranslateProperties() not translate any objects descending from IgnClass
procedure TP_GlobalIgnoreClass (IgnClass:TClass);

// Make TranslateProperties() not translate a named property in all objects
// descending from IgnClass
procedure TP_GlobalIgnoreClassProperty (IgnClass:TClass;propertyname:string);

type
  TTranslator=procedure (obj:TObject) of object;

// Make TranslateProperties() not translate any objects descending from HClass
// but instead call the specified Handler on each of these objects. The Name
// property of TComponent is already added and doesn't have to be added.
procedure TP_GlobalHandleClass (HClass:TClass;Handler:TTranslator);

// Translate a component's properties and all subcomponents
// Use this on a Delphi TForm or a CLX program's QForm.
// It will only translate string properties, but see TP_ functions
// below if there are things you don't want to have translated.
procedure TranslateProperties(AnObject: TObject; TextDomain:string='');

// Load an external GNU gettext dll to be used instead of the internal
// implementation. Returns true if the dll is loaded. If the dll was already
// loaded, this function can be used to query whether it was loaded.
// On Linux, this function enables the Libc version of GNU gettext
// After calling this function, you must set all settings again
function LoadDLLifPossible (dllname:string='gnu_gettext.dll'):boolean;

function GetCurrentLanguage:string;

// These functions are also from the orginal GNU gettext implementation.
// Only use these, if you need to split up your translation into several
// .mo files.
function dgettext(const szDomain: string; const szMsgId: widestring): widestring; 
procedure textdomain(const szDomain: string);
function getcurrenttextdomain: string;
procedure bindtextdomain(const szDomain: string; const szDirectory: string);




(*****************************************************************************)
(*                                                                           *)
(*  CLASS based implementation. Use this to have more than one language      *)
(*  in your application at the same time                                     *)
(*  Do not exploit this feature if you plan to use LoadDLLifPossible()       *)
(*                                                                           *)
(*****************************************************************************)

type
  TExecutable=
    class
      procedure Execute; virtual; abstract; 
    end;
  TGnuGettextInstance=
    class   // Do not create multiple instances on Linux!
    public
      Enabled:Boolean;      // Set this to false to disable translations
      constructor Create;
      destructor Destroy; override;
      procedure UseLanguage(LanguageCode: string);
      function gettext(const szMsgId: widestring): widestring; 
      function GetCurrentLanguage:string;

      // Form translation tools, these are not threadsafe. All TP_ procs must be called just before TranslateProperites()
      procedure TP_Ignore(AnObject:TObject; const name:string);
      procedure TP_GlobalIgnoreClass (IgnClass:TClass);
      procedure TP_GlobalIgnoreClassProperty (IgnClass:TClass;propertyname:string);
      procedure TP_GlobalHandleClass (HClass:TClass;Handler:TTranslator);
      function TP_CreateRetranslator:TExecutable;  // Must be freed by caller!
      procedure TranslateProperties(AnObject: TObject; textdomain:string='');
      procedure TranslateComponent(AnObject: TComponent; TextDomain:string='');

      // Multi-domain functions
      function dgettext(const szDomain: string; const szMsgId: widestring): widestring;
      procedure textdomain(const szDomain: string);
      function getcurrenttextdomain: string;
      procedure bindtextdomain(const szDomain: string; const szDirectory: string);

      // Debugging and advanced tools
      procedure SaveUntranslatedMsgids(filename: string);
    private
      curlang: string;
      curmsgdomain: string;
      savefileCS: TMultiReadExclusiveWriteSynchronizer;
      savefile: TextFile;
      savememory: TStringList;
      DefaultDomainDirectory:string;
      domainlist: TStringList;     // List of domain names. Objects are TDomain.
      TP_IgnoreList:TStringList;   // Temporary list, reset each time TranslateProperties is called
      TP_ClassHandling:TList;      // Items are TClassMode. If a is derived from b, a comes first
      TP_Retranslator:TExecutable; // Cast this to TTP_Retranslator
      procedure SaveCheck(szMsgId: widestring);
      procedure TranslatePropertiesSub(AnObject: TObject;Name, TextDomain:string);
    end;

var
  DefaultInstance:TGnuGettextInstance;

implementation

{$ifdef MSWINDOWS}
{$ifndef DELPHI6OROLDER}
{$WARN UNSAFE_TYPE OFF}
{$WARN UNSAFE_CODE OFF}
{$WARN UNSAFE_CAST OFF}
{$endif}
{$endif}

uses
  {$ifdef MSWINDOWS}
  Windows,
  {$endif}
  {$ifdef LINUX}
  Libc,
  {$endif}
  {$ifdef DELPHI5OROLDER}
  FileCtrl,
  {$endif}
  UnitMain,
  TypInfo;

type
  TTP_RetranslatorItem=
    class
      obj:TObject;
      Propname:string;
      OldValue:WideString;
    end;
  TTP_Retranslator=
    class (TExecutable)
      TextDomain:string;
      Instance:TGnuGettextInstance;
      constructor Create;
      destructor Destroy; override;
      procedure Remember (obj:TObject; PropName:String; OldValue:WideString);
      procedure Execute; override;
    private
      list:TList;
    end;
  TAssemblyFileInfo=
    class
      offset,size:int64;
    end;
  TAssemblyAnalyzer=
    class
      constructor Create;
      destructor Destroy; override;
      procedure Analyze;
      function FileExists (filename:string):boolean;
      procedure GetFileInfo (filename:string; var realfilename:string; var offset, size:int64);
    private
      basedirectory:string;
      filelist:TStringList; //Objects are TAssemblyFileInfo. Filenames are relative to .exe file
      function ReadInt64 (str:TStream):int64;
    end;
  TGnuGettextComponentMarker=
    class (TComponent)
    public
      LastLanguage:string;
      Retranslator:TExecutable;
    end;
  TDomain =
    class
    private
      vDirectory: string;
      procedure setDirectory(dir: string);
    public                    
      Domain: string;
      property Directory: string read vDirectory write setDirectory;
      constructor Create;
      destructor Destroy; override;
      procedure SetLanguageCode (langcode:string);
      function gettext(msgid: ansistring): ansistring; // uses mo file
    private
      moCS: TMultiReadExclusiveWriteSynchronizer; // Covers next three lines
      doswap: boolean;
      N, O, T: Cardinal; // Values defined at http://www.linuxselfhelp.com/gnu/gettext/html_chapter/gettext_6.html
      FileOffset:int64;
      {$ifdef mswindows}
      mo: THandle;
      momapping: THandle;
      {$endif}
      momemoryHandle:PChar;
      momemory: PChar;
      curlang: string;
      isopen, moexists: boolean;
      procedure OpenMoFile;
      procedure CloseMoFile;
      function gettextbyid(id: cardinal): ansistring;
      function getdsttextbyid(id: cardinal): ansistring;
      function autoswap32(i: cardinal): cardinal;
      function CardinalInMem(baseptr: PChar; Offset: Cardinal): Cardinal;
    end;
  TClassMode=
    class
      HClass:TClass;
      SpecialHandler:TTranslator;
      PropertiesToIgnore:TStringList; // This is ignored if Handler is set
      constructor Create;
      destructor Destroy; override;
    end;
  TRStrinfo = record
    strlength, stroffset: cardinal;
  end;
  TStrInfoArr = array[0..10000000] of TRStrinfo;
  PStrInfoArr = ^TStrInfoArr;
  {$ifdef MSWindows}
  tpgettext = function(const szMsgId: PChar): PChar; cdecl;
  tpdgettext = function(const szDomain: PChar; const szMsgId: PChar): PChar; cdecl;
  tpdcgettext = function(const szDomain: PChar; const szMsgId: PChar; iCategory: integer): PChar; cdecl;
  tptextdomain = function(const szDomain: PChar): PChar; cdecl;
  tpbindtextdomain = function(const szDomain: PChar; const szDirectory: PChar): PChar; cdecl;
  tpgettext_putenv = function(const envstring: PChar): integer; cdecl;
  {$endif}

var
  Win32PlatformIsUnicode:boolean=False;
  AssemblyAnalyzer:TAssemblyAnalyzer;
  TPDomainListCS:TMultiReadExclusiveWriteSynchronizer;
  TPDomainList:TStringList;
  DLLisLoaded: boolean=false;
  {$ifdef MSWINDOWS}
  pgettext: tpgettext;
  pdgettext: tpdgettext;
  ptextdomain: tptextdomain;
  pbindtextdomain: tpbindtextdomain;
  pgettext_putenv: tpgettext_putenv;
  dllmodule: THandle;
  {$endif}

function StripCR (s:string):string;
var
  i:integer;
begin
  i:=1;
  while i<=length(s) do begin
    if s[i]=#13 then delete (s,i,1) else inc (i);
  end;
  Result:=s;
end;

function LF2LineBreakA (s:string):string;
{$ifdef MSWINDOWS}
var
  i:integer;
{$endif}
begin
  {$ifdef MSWINDOWS}
  Assert (sLinebreak=#13#10);
  i:=1;
  while i<=length(s) do begin
    if (s[i]=#10) and (copy(s,i-1,1)<>#13) then begin
      insert (#13,s,i);
      inc (i,2);
    end else
      inc (i);
  end;
  {$endif}
  Result:=s;
end;

function IsWriteProp(Info: PPropInfo): Boolean;
begin
  Result := Assigned(Info) and (Info^.SetProc <> nil);
end;

procedure SaveUntranslatedMsgids(filename: string);
begin
  DefaultInstance.SaveUntranslatedMsgids(filename);
end;

function string2csyntax(s: string): string;
// Converts a string to the syntax that is used in .po files
var
  i: integer;
  c: char;
begin
  Result := '';
  for i := 1 to length(s) do begin
    c := s[i];
    case c of
      #32..#33, #35..#255: Result := Result + c;
      #13: Result := Result + '\r';
      #10: Result := Result + '\n"'#13#10'"';
      #34: Result := Result + '\"';
    else
      Result := Result + '\0x' + IntToHex(ord(c), 2);
    end;
  end;
  Result := '"' + Result + '"';
end;

function ResourceStringGettext(MsgId: widestring): widestring;
var
  i:integer;
begin
  if TPDomainListCS=nil then begin
    // This only happens during very complicated program startups that fail
    Result:=MsgId;
    exit;
  end;
  TPDomainListCS.BeginRead;
  try
    for i:=0 to TPDomainList.Count-1 do begin
      Result:=dgettext(TPDomainList.Strings[i], MsgId);
      if Result<>MsgId then
        break;
    end;
  finally
    TPDomainListCS.EndRead;
  end;
end;

function gettext(const szMsgId: widestring): widestring;
begin
  Result:=DefaultInstance.gettext(szMsgId);
end;

function _(const szMsgId: widestring): widestring;
begin
  Result:=DefaultInstance.gettext(szMsgId);
end;

function dgettext(const szDomain: string; const szMsgId: widestring): widestring;
begin
  Result:=DefaultInstance.dgettext(szDomain, szMsgId);
end;

procedure textdomain(const szDomain: string);
begin
  DefaultInstance.textdomain(szDomain);
end;

procedure SetGettextEnabled (enabled:boolean);
begin
  DefaultInstance.Enabled:=enabled;
end;

function getcurrenttextdomain: string;
begin
  Result:=DefaultInstance.getcurrenttextdomain;
end;

procedure bindtextdomain(const szDomain: string; const szDirectory: string);
begin
  DefaultInstance.bindtextdomain(szDomain, szDirectory);
end;

procedure TP_Ignore(AnObject:TObject; const name:string);
begin
  DefaultInstance.TP_Ignore(AnObject, name);
end;

procedure TP_GlobalIgnoreClass (IgnClass:TClass);
begin
  DefaultInstance.TP_GlobalIgnoreClass(IgnClass);
end;

procedure TP_GlobalIgnoreClassProperty (IgnClass:TClass;propertyname:string);
begin
  DefaultInstance.TP_GlobalIgnoreClassProperty(IgnClass,propertyname);
end;

procedure TP_GlobalHandleClass (HClass:TClass;Handler:TTranslator);
begin
  DefaultInstance.TP_GlobalHandleClass (HClass, Handler);
end;

procedure TranslateProperties(AnObject: TObject; TextDomain:string='');
begin
  DefaultInstance.TranslateProperties(AnObject, TextDomain);
end;

procedure TranslateComponent(AnObject: TComponent; TextDomain:string='');
begin
  
  DefaultInstance.TranslateComponent(AnObject, TextDomain);
end;

{$ifdef MSWINDOWS}

// These constants are only used in Windows 95
// Thanks to Frank Andreas de Groot for this table
const
  IDAfrikaans                 = $0436;  IDAlbanian                  = $041C;
  IDArabicAlgeria             = $1401;  IDArabicBahrain             = $3C01;
  IDArabicEgypt               = $0C01;  IDArabicIraq                = $0801;
  IDArabicJordan              = $2C01;  IDArabicKuwait              = $3401;
  IDArabicLebanon             = $3001;  IDArabicLibya               = $1001;
  IDArabicMorocco             = $1801;  IDArabicOman                = $2001;
  IDArabicQatar               = $4001;  IDArabic                    = $0401;
  IDArabicSyria               = $2801;  IDArabicTunisia             = $1C01;
  IDArabicUAE                 = $3801;  IDArabicYemen               = $2401;
  IDArmenian                  = $042B;  IDAssamese                  = $044D;
  IDAzeriCyrillic             = $082C;  IDAzeriLatin                = $042C;
  IDBasque                    = $042D;  IDByelorussian              = $0423;
  IDBengali                   = $0445;  IDBulgarian                 = $0402;
  IDBurmese                   = $0455;  IDCatalan                   = $0403;
  IDChineseHongKong           = $0C04;  IDChineseMacao              = $1404;
  IDSimplifiedChinese         = $0804;  IDChineseSingapore          = $1004;
  IDTraditionalChinese        = $0404;  IDCroatian                  = $041A;
  IDCzech                     = $0405;  IDDanish                    = $0406;
  IDBelgianDutch              = $0813;  IDDutch                     = $0413;
  IDEnglishAUS                = $0C09;  IDEnglishBelize             = $2809;
  IDEnglishCanadian           = $1009;  IDEnglishCaribbean          = $2409;
  IDEnglishIreland            = $1809;  IDEnglishJamaica            = $2009;
  IDEnglishNewZealand         = $1409;  IDEnglishPhilippines        = $3409;
  IDEnglishSouthAfrica        = $1C09;  IDEnglishTrinidad           = $2C09;
  IDEnglishUK                 = $0809;  IDEnglishUS                 = $0409;
  IDEnglishZimbabwe           = $3009;  IDEstonian                  = $0425;
  IDFaeroese                  = $0438;  IDFarsi                     = $0429;
  IDFinnish                   = $040B;  IDBelgianFrench             = $080C;
  IDFrenchCameroon            = $2C0C;  IDFrenchCanadian            = $0C0C;
  IDFrenchCotedIvoire         = $300C;  IDFrench                    = $040C;
  IDFrenchLuxembourg          = $140C;  IDFrenchMali                = $340C;
  IDFrenchMonaco              = $180C;  IDFrenchReunion             = $200C;
  IDFrenchSenegal             = $280C;  IDSwissFrench               = $100C;
  IDFrenchWestIndies          = $1C0C;  IDFrenchZaire               = $240C;
  IDFrisianNetherlands        = $0462;  IDGaelicIreland             = $083C;
  IDGaelicScotland            = $043C;  IDGalician                  = $0456;
  IDGeorgian                  = $0437;  IDGermanAustria             = $0C07;
  IDGerman                    = $0407;  IDGermanLiechtenstein       = $1407;
  IDGermanLuxembourg          = $1007;  IDSwissGerman               = $0807;
  IDGreek                     = $0408;  IDGujarati                  = $0447;
  IDHebrew                    = $040D;  IDHindi                     = $0439;
  IDHungarian                 = $040E;  IDIcelandic                 = $040F;
  IDIndonesian                = $0421;  IDItalian                   = $0410;
  IDSwissItalian              = $0810;  IDJapanese                  = $0411;
  IDKannada                   = $044B;  IDKashmiri                  = $0460;
  IDKazakh                    = $043F;  IDKhmer                     = $0453;
  IDKirghiz                   = $0440;  IDKonkani                   = $0457;
  IDKorean                    = $0412;  IDLao                       = $0454;
  IDLatvian                   = $0426;  IDLithuanian                = $0427;
  IDMacedonian                = $042F;  IDMalaysian                 = $043E;
  IDMalayBruneiDarussalam     = $083E;  IDMalayalam                 = $044C;
  IDMaltese                   = $043A;  IDManipuri                  = $0458;
  IDMarathi                   = $044E;  IDMongolian                 = $0450;
  IDNepali                    = $0461;  IDNorwegianBokmol           = $0414;
  IDNorwegianNynorsk          = $0814;  IDOriya                     = $0448;
  IDPolish                    = $0415;  IDBrazilianPortuguese       = $0416;
  IDPortuguese                = $0816;  IDPunjabi                   = $0446;
  IDRhaetoRomanic             = $0417;  IDRomanianMoldova           = $0818;
  IDRomanian                  = $0418;  IDRussianMoldova            = $0819;
  IDRussian                   = $0419;  IDSamiLappish               = $043B;
  IDSanskrit                  = $044F;  IDSerbianCyrillic           = $0C1A;
  IDSerbianLatin              = $081A;  IDSesotho                   = $0430;
  IDSindhi                    = $0459;  IDSlovak                    = $041B;
  IDSlovenian                 = $0424;  IDSorbian                   = $042E;
  IDSpanishArgentina          = $2C0A;  IDSpanishBolivia            = $400A;
  IDSpanishChile              = $340A;  IDSpanishColombia           = $240A;
  IDSpanishCostaRica          = $140A;  IDSpanishDominicanRepublic  = $1C0A;
  IDSpanishEcuador            = $300A;  IDSpanishElSalvador         = $440A;
  IDSpanishGuatemala          = $100A;  IDSpanishHonduras           = $480A;
  IDMexicanSpanish            = $080A;  IDSpanishNicaragua          = $4C0A;
  IDSpanishPanama             = $180A;  IDSpanishParaguay           = $3C0A;
  IDSpanishPeru               = $280A;  IDSpanishPuertoRico         = $500A;
  IDSpanishModernSort         = $0C0A;  IDSpanish                   = $040A;
  IDSpanishUruguay            = $380A;  IDSpanishVenezuela          = $200A;
  IDSutu                      = $0430;  IDSwahili                   = $0441;
  IDSwedishFinland            = $081D;  IDSwedish                   = $041D;
  IDTajik                     = $0428;  IDTamil                     = $0449;
  IDTatar                     = $0444;  IDTelugu                    = $044A;
  IDThai                      = $041E;  IDTibetan                   = $0451;
  IDTsonga                    = $0431;  IDTswana                    = $0432;
  IDTurkish                   = $041F;  IDTurkmen                   = $0442;
  IDUkrainian                 = $0422;  IDUrdu                      = $0420;
  IDUzbekCyrillic             = $0843;  IDUzbekLatin                = $0443;
  IDVenda                     = $0433;  IDVietnamese                = $042A;
  IDWelsh                     = $0452;  IDXhosa                     = $0434;
  IDZulu                      = $0435;

function GetWindowsLanguage: string;
var
  langid: Cardinal;
  langcode: string;
  CountryName: array[0..4] of char;
  LanguageName: array[0..4] of char;
  works: boolean;
begin
  // The return value of GetLocaleInfo is compared with 3 = 2 characters and a zero
  works := 3 = GetLocaleInfo(LOCALE_USER_DEFAULT, LOCALE_SISO639LANGNAME, LanguageName, SizeOf(LanguageName));
  works := works and (3 = GetLocaleInfo(LOCALE_USER_DEFAULT, LOCALE_SISO3166CTRYNAME, CountryName,
    SizeOf(CountryName)));
  if works then begin
    // Windows 98, Me, NT4, 2000, XP and newer
    LangCode := PChar(@LanguageName[0]) + '_' + PChar(@CountryName[0]);
  end else begin
    // This part should only happen on Windows 95.
    langid := GetThreadLocale;
    case langid of
      IDBelgianDutch: langcode := 'nl_BE';
      IDBelgianFrench: langcode := 'fr_BE';
      IDBrazilianPortuguese: langcode := 'pt_BR';
      IDDanish: langcode := 'da_DK';
      IDDutch: langcode := 'nl_NL';
      IDEnglishUK: langcode := 'en_UK';
      IDEnglishUS: langcode := 'en_US';
      IDFinnish: langcode := 'fi_FI';
      IDFrench: langcode := 'fr_FR';
      IDFrenchCanadian: langcode := 'fr_CA';
      IDGerman: langcode := 'de_DE';
      IDGermanLuxembourg: langcode := 'de_LU';
      IDGreek: langcode := 'gr_GR';
      IDIcelandic: langcode := 'is_IS';
      IDItalian: langcode := 'it_IT';
      IDKorean: langcode := 'ko_KO';
      IDNorwegianBokmol: langcode := 'no_NO';
      IDNorwegianNynorsk: langcode := 'nn_NO';
      IDPolish: langcode := 'pl_PL';
      IDPortuguese: langcode := 'pt_PT';
      IDRussian: langcode := 'ru_RU';
      IDSpanish, IDSpanishModernSort: langcode := 'es_ES';
      IDSwedish: langcode := 'sv_SE';
      IDSwedishFinland: langcode := 'fi_SE';
    else
      langcode := 'C';
    end;
  end;
  Result := langcode;
end;

procedure OverwriteProcedure(OldProcedure, NewProcedure: pointer);
{ OverwriteProcedure originally from Igor Siticov }
var
  x: pchar;
  y: integer;
  ov2, ov: cardinal;
begin
  x := PChar(OldProcedure);
  if not VirtualProtect(Pointer(x), 5, PAGE_EXECUTE_READWRITE, @ov) then
    RaiseLastOSError;

  x[0] := char($E9);
  y := integer(NewProcedure) - integer(OldProcedure) - 5;
  x[1] := char(y and 255);
  x[2] := char((y shr 8) and 255);
  x[3] := char((y shr 16) and 255);
  x[4] := char((y shr 24) and 255);

  if not VirtualProtect(Pointer(x), 5, ov, @ov2) then
    RaiseLastOSError;
end;
{$endif}

function LoadResStringA(ResStringRec: PResStringRec): string;
begin
  Result:=LoadResString(ResStringRec);
end;

procedure gettext_putenv(const envstring: string);
begin
  {$ifdef mswindows}
  if DLLisLoaded and Assigned(pgettext_putenv) then
    pgettext_putenv(PChar(envstring));
  {$endif}
end;

procedure UseLanguage(LanguageCode: string);
begin
  DefaultInstance.UseLanguage(LanguageCode);
end;

function LoadResString(ResStringRec: PResStringRec): widestring;
{$ifdef MSWINDOWS}
var
  Len: Integer;
  Buffer: array [0..1023] of char;
{$endif}
begin
  if (ResStringRec = nil) then
    exit;
  if ResStringRec.Identifier >= 64*1024 then
    Result:=PChar(ResStringRec.Identifier)
  else
  {$ifdef LINUX}
  // This works with Unicode if the Linux has utf-8 character set
  Result:=System.LoadResString(ResStringRec);
  {$endif}
  {$ifdef MSWINDOWS}
  if not Win32PlatformIsUnicode then begin
    SetString(Result, Buffer,
      LoadString(FindResourceHInstance(ResStringRec.Module^),
        ResStringRec.Identifier, Buffer, SizeOf(Buffer)))
  end else begin
    Result := '';
    Len := 0;
    While Len = Length(Result) do begin
      if Length(Result) = 0 then
        SetLength(Result, 1024)
      else
        SetLength(Result, Length(Result) * 2);
      Len := LoadStringW(FindResourceHInstance(ResStringRec.Module^),
        ResStringRec.Identifier, PWideChar(Result), Length(Result));
    end;
    SetLength(Result, Len);
  end;
  {$endif}
  Result:=ResourceStringGettext(Result);
end;

function LoadResStringW(ResStringRec: PResStringRec): widestring;
begin
  Result:=LoadResString(ResStringRec);
end;



function GetCurrentLanguage:string;
begin
  Result:=DefaultInstance.GetCurrentLanguage;
end;

function getdomain(list:TStringList; domain, DefaultDomainDirectory, CurLang: string): TDomain;
// Retrieves the TDomain object for the specified domain.
// Creates one, if none there, yet.
var
  idx: integer;
begin
  idx := list.IndexOf(Domain);
  if idx = -1 then begin
    Result := TDomain.Create;
    Result.Domain := Domain;
    Result.Directory := DefaultDomainDirectory;
    Result.SetLanguageCode(curlang);
    list.AddObject(Domain, Result);
  end else begin
    Result := list.Objects[idx] as TDomain;
  end;
end;

{ TDomain }

function TDomain.CardinalInMem (baseptr:PChar; Offset:Cardinal):Cardinal;
var pc:^Cardinal;
begin
  inc (baseptr,offset);
  pc:=Pointer(baseptr);
  Result:=pc^;
  if doswap then
    autoswap32(Result);
end;

function TDomain.autoswap32(i: cardinal): cardinal;
var
  cnv1, cnv2:
    record
      case integer of
        0: (arr: array[0..3] of byte);
        1: (int: cardinal);
    end;
begin
  if doswap then begin
    cnv1.int := i;
    cnv2.arr[0] := cnv1.arr[3];
    cnv2.arr[1] := cnv1.arr[2];
    cnv2.arr[2] := cnv1.arr[1];
    cnv2.arr[3] := cnv1.arr[0];
    Result := cnv2.int;
  end else
    Result := i;
end;

procedure TDomain.CloseMoFile;
begin
  moCS.BeginWrite;
  try
    if isopen then begin
      {$ifdef mswindows}
      UnMapViewOfFile (momemoryHandle);
      CloseHandle (momapping);
      CloseHandle (mo);
      {$endif}
      {$ifdef linux}
      FreeMem (momemoryHandle);
      {$endif}

      isopen := False;
    end;
    moexists := True;
  finally
    moCS.EndWrite;
  end;
end;

constructor TDomain.Create;
begin
  moCS := TMultiReadExclusiveWriteSynchronizer.Create;
  isOpen := False;
  moexists := True;
end;

destructor TDomain.Destroy;
begin
  CloseMoFile;
  FreeAndNil(moCS);
  inherited;
end;

function TDomain.gettextbyid(id: cardinal): ansistring;
var
  offset: cardinal;
begin
  offset := CardinalInMem (momemory,O+8*id+4);
  Result := strpas(momemory+offset);
end;

function TDomain.getdsttextbyid(id: cardinal): ansistring;
var
  offset: cardinal;
begin
  offset := CardinalInMem (momemory,T+8*id+4);
  Result := strpas(momemory+offset);
end;

function TDomain.gettext(msgid: ansistring): ansistring;
var
  i, nn, step: cardinal;
  s: string;
begin
  if (not isopen) and (moexists) then
    OpenMoFile;
  if not isopen then begin
    Result := msgid;
    exit;
  end;

  // Calculate start conditions for a binary search
  nn := N;
  i := 1;
  while nn <> 0 do begin
    nn := nn shr 1;
    i := i shl 1;
  end;
  i := i shr 1;
  step := i shr 1;
  // Do binary search
  while true do begin
    // Get string for index i
    s := gettextbyid(i-1);
    if msgid = s then begin
      // Found the msgid
      Result := getdsttextbyid(i-1);
      break;
    end;
    if step = 0 then begin
      // Not found
      Result := msgid;
      break;
    end;
    if msgid < s then begin
      if i < 1+step then
        i := 1
      else
        i := i - step;
      step := step shr 1;
    end else
    if msgid > s then begin
      i := i + step;
      if i > N then
        i := N;
      step := step shr 1;
    end;
  end;
end;

{$ifdef mswindows}
function GetLastWinError:string;
var
  errcode:Cardinal;
begin
  SetLength (Result,2000);
  errcode:=GetLastError();
  Windows.FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM,nil,errcode,0,PChar(Result),2000,nil);
  Result:=StrPas(PChar(Result));
end;
{$endif}

procedure TDomain.OpenMoFile;
var
  i: cardinal;
  filename: string;
  offset,size:Int64;
{$ifdef linux}
  mofile:TFileStream;
{$endif}
begin
  moCS.BeginWrite;
  try
    // Check if it is already open
    if isopen then
      exit;

    // Check if it has been attempted to open the file before
    if not moexists then
      exit;

    if sizeof(i) <> 4 then
      raise Exception.Create('TDomain in gnugettext is written for an architecture that has 32 bit integers.');

    filename := Directory + curlang + PathDelim + 'LC_MESSAGES' + PathDelim + domain + '.mo';
    if (not AssemblyAnalyzer.FileExists(filename)) and (not fileexists(filename)) then
      filename := Directory + copy(curlang, 1, 2) + PathDelim + 'LC_MESSAGES' + PathDelim + domain + '.mo';
    if (not AssemblyAnalyzer.FileExists(filename)) and (not fileexists(filename)) then begin
      moexists := False;
      exit;
    end;
    AssemblyAnalyzer.GetFileInfo(filename,filename,offset,size);
    FileOffset:=offset;

    {$ifdef mswindows}
    // The next two lines are necessary because otherwise MapViewOfFile fails
    size:=0;
    offset:=0;
    // Map the mo file into memory and let the operating system decide how to cache
    mo:=createfile (PChar(filename),GENERIC_READ,FILE_SHARE_READ,nil,OPEN_EXISTING,0,0);
    if mo=INVALID_HANDLE_VALUE then
      raise Exception.Create ('Cannot open file '+filename);
    momapping:=CreateFileMapping (mo, nil, PAGE_READONLY, 0, 0, nil);
    if momapping=0 then
      raise Exception.Create ('Cannot create memory map on file '+filename);
    momemoryHandle:=MapViewOfFile (momapping,FILE_MAP_READ,offset shr 32,offset and $FFFFFFFF,size);
    if momemoryHandle=nil then begin
      raise Exception.Create ('Cannot map file '+filename+' into memory. Reason: '+GetLastWinError);
    end;
    momemory:=momemoryHandle+FileOffset;
    {$endif}
    {$ifdef linux}
    // Read the whole file into memory
    mofile:=TFileStream.Create (filename, fmOpenRead or fmShareDenyNone);
    try
      if size=0 then
        size:=mofile.Size;
      Getmem (momemoryHandle,size);
      momemory:=momemoryHandle;
      mofile.Seek(FileOffset,soFromBeginning);
      mofile.ReadBuffer(momemory^,size);
    finally
      FreeAndNil (mofile);
    end;
    {$endif}
    isOpen := True;

    // Check the magic number
    doswap:=False;
    i:=CardinalInMem(momemory,0);
    if (i <> $950412DE) and (i <> $DE120495) then
      raise Exception.Create('This file is not a valid GNU gettext mo file: ' + filename);
    doswap := (i = $DE120495);

    CardinalInMem(momemory,4);       // Read the version number, but don't use it for anything.
    N:=CardinalInMem(momemory,8);    // Get string count
    O:=CardinalInMem(momemory,12);   // Get offset of original strings
    T:=CardinalInMem(momemory,16);   // Get offset of translated strings
  finally
    moCS.EndWrite;
  end;
end;

procedure TDomain.setDirectory(dir: string);
begin
  vDirectory := IncludeTrailingPathDelimiter(dir);
  CloseMoFile;
end;

function LoadDLLifPossible (dllname:string='gnu_gettext.dll'):boolean;
begin
  {$ifdef MSWINDOWS}
  if not DLLisLoaded then begin
    dllmodule := LoadLibraryEx(PChar(dllname), 0, 0);
    DLLisLoaded := (dllmodule <> 0);
    if DLLisLoaded then begin
      pgettext := tpgettext(GetProcAddress(dllmodule, 'gettext'));
      pdgettext := tpdgettext(GetProcAddress(dllmodule, 'dgettext'));
      ptextdomain := tptextdomain(GetProcAddress(dllmodule, 'textdomain'));
      pbindtextdomain := tpbindtextdomain(GetProcAddress(dllmodule, 'bindtextdomain'));
      pgettext_putenv := tpgettext_putenv(GetProcAddress(dllmodule, 'gettext_putenv'));
    end;
  end;
{$endif}
{$ifdef LINUX}
  // On Linux, gettext is always there as part of the Libc library.
  // But default is not to use it, but to use the internal implementation instead.
  DLLisLoaded := False;
{$endif}
  Result:=DLLisLoaded;
end;

procedure AddDomainForResourceString (domain:string);
begin
  TPDomainListCS.BeginWrite;
  try
    TPDomainList.Add (domain);
  finally
    TPDomainListCS.EndWrite;
  end;
end;

procedure TDomain.SetLanguageCode(langcode: string);
begin
  CloseMoFile;
  curlang:=langcode;
end;

{ TGnuGettextInstance }

procedure TGnuGettextInstance.bindtextdomain(const szDomain,
  szDirectory: string);
var
  dir:string;
begin
  dir:=IncludeTrailingPathDelimiter(szDirectory);
  getdomain(domainlist,szDomain,DefaultDomainDirectory,CurLang).Directory := dir;
  {$ifdef LINUX}
  dir:=ExcludeTrailingPathDelimiter(szDirectory);
  Libc.bindtextdomain(PChar(szDomain), PChar(dir));
  {$endif}
  {$ifdef MSWINDOWS}
  if DLLisLoaded then
    pbindtextdomain(PChar(szDomain), PChar(dir));
  {$endif}
end;

constructor TGnuGettextInstance.Create;
var
  lang: string;
begin
  Enabled:=True;
  curmsgdomain:=DefaultTextDomain;
  savefileCS := TMultiReadExclusiveWriteSynchronizer.Create;
  domainlist := TStringList.Create;
  TP_IgnoreList:=TStringList.Create;
  TP_IgnoreList.Sorted:=True;
  TP_ClassHandling:=TList.Create;

  // Set some settings
  DefaultDomainDirectory := IncludeTrailingPathDelimiter(extractfilepath(paramstr(0)))+'\Recursos\locale';

  UseLanguage(lang);

  bindtextdomain(DefaultTextDomain, DefaultDomainDirectory);
  textdomain(DefaultTextDomain);

  {$ifdef LINUX}
  bind_textdomain_codeset(DefaultTextDomain,'utf-8');
  {$endif}

  // Add default properties to ignore
  TP_GlobalIgnoreClassProperty(TComponent,'Name');
  TP_GlobalIgnoreClassProperty(TCollection,'PropName');
end;

destructor TGnuGettextInstance.Destroy;
begin
  if savememory <> nil then begin
    savefileCS.BeginWrite;
    try
      CloseFile(savefile);
    finally
      savefileCS.EndWrite;
    end;
    FreeAndNil(savememory);
  end;
  FreeAndNil (savefileCS);
  FreeAndNil (TP_IgnoreList);
  while TP_ClassHandling.Count<>0 do begin
    TObject(TP_ClassHandling.Items[0]).Free;
    TP_ClassHandling.Delete(0);
  end;
  FreeAndNil (TP_ClassHandling);
  while domainlist.Count <> 0 do begin
    domainlist.Objects[0].Free;
    domainlist.Delete(0);
  end;
  FreeAndNil(domainlist);
  inherited;
end;

function TGnuGettextInstance.dgettext(const szDomain: string;
  const szMsgId: widestring): widestring;
begin
  if not Enabled then begin
    Result:=szMsgId;
    exit;
  end;
  if DLLisLoaded then begin
    {$ifdef LINUX}
    Result := utf8decode(StrPas(Libc.dgettext(PChar(szDomain), PChar(utf8encode(szMsgId)))));
    {$endif}
    {$ifdef MSWINDOWS}
    Result := utf8decode(LF2LineBreakA(StrPas(pdgettext(PChar(szDomain), PChar(StripCR(utf8encode((szMsgId))))))));
    {$endif}
  end else begin
    Result:=UTF8Decode(LF2LineBreakA(getdomain(domainlist,szDomain,DefaultDomainDirectory,CurLang).gettext(StripCR(utf8encode(szMsgId)))));
  end;
  if (Result = szMsgId) and (szDomain = DefaultTextDomain) then
    SaveCheck(szMsgId);
end;

function TGnuGettextInstance.GetCurrentLanguage: string;
begin
  Result:=curlang;
end;

function TGnuGettextInstance.getcurrenttextdomain: string;
begin
  if DLLisLoaded then begin
    {$ifdef LINUX}
    Result := StrPas(Libc.textdomain(nil));
    {$endif}
    {$ifdef MSWINDOWS}
    Result := StrPas(ptextdomain(nil));
    {$endif}
  end else
    Result := curmsgdomain;
end;

function TGnuGettextInstance.gettext(
  const szMsgId: widestring): widestring;
begin
  Result := dgettext(curmsgdomain, szMsgId);
end;

procedure TGnuGettextInstance.SaveCheck(szMsgId: widestring);
var
  i: integer;
begin
  savefileCS.BeginWrite;
  try
    if (savememory <> nil) and (szMsgId <> '') then begin
      if not savememory.Find(szMsgId, i) then begin
        savememory.Add(szMsgId);
        Writeln(savefile, 'msgid ' + string2csyntax(utf8encode(szMsgId)));
        writeln(savefile, 'msgstr ""');
        writeln(savefile);
      end;
    end;
  finally
    savefileCS.EndWrite;
  end;
end;

procedure TGnuGettextInstance.SaveUntranslatedMsgids(filename: string);
begin
  // If this happens, it is an internal error made by the programmer.
  if savememory <> nil then
    raise Exception.Create(_('You may not call SaveUntranslatedMsgids twice in this program.'));

  AssignFile(savefile, filename);
  Rewrite(savefile);
  writeln(savefile, 'msgid ""');
  writeln(savefile, 'msgstr ""');
  writeln(savefile);
  savememory := TStringList.Create;
  savememory.Sorted := true;
end;

procedure TGnuGettextInstance.textdomain(const szDomain: string);
begin
  curmsgdomain := szDomain;
  {$ifdef LINUX}
  Libc.textdomain(PChar(szDomain));
  {$endif}
  {$ifdef MSWINDOWS}
  if DLLisLoaded then begin
    ptextdomain(PChar(szDomain));
  end;
  {$endif}
end;

function TGnuGettextInstance.TP_CreateRetranslator : TExecutable;
var
  ttpr:TTP_Retranslator;
begin
  ttpr:=TTP_Retranslator.Create;
  ttpr.Instance:=self;
  TP_Retranslator:=ttpr;
  Result:=ttpr;
end;

procedure TGnuGettextInstance.TP_GlobalHandleClass(HClass: TClass;
  Handler: TTranslator);
var
  cm:TClassMode;
  i:integer;
begin
  for i:=0 to TP_ClassHandling.Count-1 do begin
    cm:=TObject(TP_ClassHandling.Items[i]) as TClassMode;
    if cm.HClass=HClass then
      raise Exception.Create ('You cannot set a handler for a class that has already been assigned otherwise.');
    if HClass.InheritsFrom(cm.HClass) then begin
      // This is the place to insert this class
      cm:=TClassMode.Create;
      cm.HClass:=HClass;
      cm.SpecialHandler:=Handler;
      TP_ClassHandling.Insert(i,cm);
      exit;
    end;
  end;
  cm:=TClassMode.Create;
  cm.HClass:=HClass;
  cm.SpecialHandler:=Handler;
  TP_ClassHandling.Add(cm);
end;

procedure TGnuGettextInstance.TP_GlobalIgnoreClass(IgnClass: TClass);
var
  cm:TClassMode;
  i:integer;
begin
  for i:=0 to TP_ClassHandling.Count-1 do begin
    cm:=TObject(TP_ClassHandling.Items[i]) as TClassMode;
    if cm.HClass=IgnClass then
      raise Exception.Create ('You cannot add a class to the ignore list that is already on that list: '+IgnClass.ClassName);
    if IgnClass.InheritsFrom(cm.HClass) then begin
      // This is the place to insert this class
      cm:=TClassMode.Create;
      cm.HClass:=IgnClass;
      TP_ClassHandling.Insert(i,cm);
      exit;
    end;
  end;
  cm:=TClassMode.Create;
  cm.HClass:=IgnClass;
  TP_ClassHandling.Add(cm);
end;

procedure TGnuGettextInstance.TP_GlobalIgnoreClassProperty(
  IgnClass: TClass; propertyname: string);
var
  cm:TClassMode;
  i:integer;
begin
  propertyname:=uppercase(propertyname);
  for i:=0 to TP_ClassHandling.Count-1 do begin
    cm:=TObject(TP_ClassHandling.Items[i]) as TClassMode;
    if cm.HClass=IgnClass then begin
      if Assigned(cm.SpecialHandler) then
        raise Exception.Create ('You cannot ignore a class property for a class that has a handler set.');
      cm.PropertiesToIgnore.Add(propertyname);
      exit;
    end;
    if IgnClass.InheritsFrom(cm.HClass) then begin
      // This is the place to insert this class
      cm:=TClassMode.Create;
      cm.HClass:=IgnClass;
      cm.PropertiesToIgnore.Add(propertyname);
      TP_ClassHandling.Insert(i,cm);
      exit;
    end;
  end;
  cm:=TClassMode.Create;
  cm.HClass:=IgnClass;
  cm.PropertiesToIgnore.Add(propertyname);
  TP_ClassHandling.Add(cm);
end;

procedure TGnuGettextInstance.TP_Ignore(AnObject: TObject;
  const name: string);
begin
  TP_IgnoreList.Add(uppercase(name));
end;

procedure TGnuGettextInstance.TranslateComponent(AnObject: TComponent;
  TextDomain: string);
var
  comp:TGnuGettextComponentMarker;
begin
  comp:=AnObject.FindComponent('GNUgettextMarker') as TGnuGettextComponentMarker;
  if comp=nil then begin
    comp:=TGnuGettextComponentMarker.Create (nil);
    comp.Name:='GNUgettextMarker';
    comp.Retranslator:=TP_CreateRetranslator;
    TranslateProperties (AnObject, TextDomain);
    AnObject.InsertComponent(comp);
  end else begin
    if comp.LastLanguage<>curlang then begin
      comp.Retranslator.Execute;
    end;
  end;
  comp.LastLanguage:=curlang;
end;

procedure TGnuGettextInstance.TranslateProperties(AnObject: TObject; textdomain:string='');
begin
  if textdomain='' then
    textdomain:=curmsgdomain;
  if TP_Retranslator<>nil then
    (TP_Retranslator as TTP_Retranslator).TextDomain:=textdomain;
  TranslatePropertiesSub (AnObject,'',textdomain);
  TP_IgnoreList.Clear;
  TP_Retranslator:=nil;
end;

procedure TGnuGettextInstance.TranslatePropertiesSub(AnObject: TObject;
  Name, TextDomain: string);
var
  i, k: integer;
  j, Count: integer;
  PropList: PPropList;
  PropName, UPropName: string;
  PropInfo: PPropInfo;
  sl: TObject;
  comp:TComponent;
  {$ifdef DELPHI5OROLDER}
  ws: string;
  old: string;
  Data: PTypeData;
  {$endif}
  {$ifndef DELPHI5OROLDER}
  ppi:PPropInfo;
  ws: WideString;
  old: WideString;
  {$endif}
  cm,currentcm:TClassMode;
  ObjectPropertyIgnoreList:TStringList;
begin
  if (AnObject = nil) then
    Exit;
  ObjectPropertyIgnoreList:=TStringList.Create;
  try
    ObjectPropertyIgnoreList.Sorted:=True;
    ObjectPropertyIgnoreList.Duplicates:=dupIgnore;
    // Find out if there is special handling of this object
    currentcm:=nil;
    for j:=0 to TP_ClassHandling.Count-1 do begin
      cm:=TObject(TP_ClassHandling.Items[j]) as TClassMode;
      if AnObject.InheritsFrom(cm.HClass) then begin
        if cm.PropertiesToIgnore.Count<>0 then begin
          ObjectPropertyIgnoreList.AddStrings(cm.PropertiesToIgnore);
        end else begin
          currentcm:=cm;
          break;
        end;
      end;
    end;
    if currentcm<>nil then begin
      ObjectPropertyIgnoreList.Clear;
      // Ignore or use special handler
      if Assigned(currentcm.SpecialHandler) then
        currentcm.SpecialHandler (AnObject);
      exit;
    end;

    {$ifdef DELPHI5OROLDER}
    Data := GetTypeData(AnObject.Classinfo);
    Count := Data^.PropCount;
    GetMem(PropList, Count * Sizeof(PPropInfo));
    {$endif}
    try
      {$ifdef DELPHI5OROLDER}
      GetPropInfos(AnObject.ClassInfo, PropList);
      {$endif}
      {$ifndef DELPHI5OROLDER}
      Count := GetPropList(AnObject, PropList);
      {$endif}
        for j := 0 to Count - 1 do begin
          PropInfo := PropList[j];
          PropName := PropInfo^.Name;
          UPropName:=uppercase(PropName);
          // Ignore properties that are meant to be ignored
          if ((currentcm=nil) or (not currentcm.PropertiesToIgnore.Find(UPropName,i))) and
             (not TP_IgnoreList.Find(Name+'.'+UPropName,i)) and
             (not ObjectPropertyIgnoreList.Find(UPropName,i)) then begin
            try
              // Translate certain types of properties
              case PropInfo^.PropType^.Kind of
                tkString, tkLString, tkWString:
                  begin
                    {$ifdef DELPHI5OROLDER}
                    old := GetStrProp(AnObject, PropName);
                    {$endif}
                    {$ifndef DELPHI5OROLDER}
                    old := GetWideStrProp(AnObject, PropName);
                    {$endif}
                    if (old <> '') and (IsWriteProp(PropInfo)) then begin
                      if TP_Retranslator<>nil then
                        (TP_Retranslator as TTP_Retranslator).Remember(AnObject, PropName, old);
                      ws := dgettext(textdomain,old);
                      if ws <> old then begin
                        {$ifdef DELPHI5OROLDER}
                        SetStrProp(AnObject, PropName, ws);
                        {$endif}
                        {$ifndef DELPHI5OROLDER}
                        ppi:=GetPropInfo(AnObject, Propname);
                        if ppi=nil then
                          raise Exception.Create ('Property disappeared...');
                        SetWideStrProp(AnObject, ppi, ws);
                        {$endif}
                      end;
                    end;
                  end;
                tkClass:
                  begin
                    sl := GetObjectProp(AnObject, PropName);
                    if (sl = nil) then
                      Continue;
                    // Check the global class ignore list
                    for k:=0 to TP_ClassHandling.Count-1 do begin
                      if AnObject.InheritsFrom(TClass(TP_ClassHandling.Items[k])) then
                        exit;
                    end;
                    // Check for TStrings translation
                    if sl is TStrings then begin
                      old := TStrings(sl).Text;
                      if old <> '' then begin
                        if TP_Retranslator<>nil then
                          (TP_Retranslator as TTP_Retranslator).Remember(sl, 'Text', old); 
                        ws := dgettext(textdomain,old);
                        if (old <> ws) then begin
                          TStrings(sl).Text := ws;
                        end;
                      end
                    end else
                    // Check for TCollection
                    if sl is TCollection then
                      for i := 0 to TCollection(sl).Count - 1 do
                        TranslatePropertiesSub(TCollection(sl).Items[i],'',textdomain);
                  end;
                end; // case
            except
              on E:Exception do
                raise Exception.Create ('Property cannot be translated.'+sLineBreak+
                  'Use TP_GlobalIgnoreClassProperty('+AnObject.ClassName+','+PropName+') or'+sLineBreak+
                  'TP_Ignore (self,''.'+PropName+''') to prevent this message.'+sLineBreak+
                  'Reason: '+e.Message);
            end;                                  
          end;  // if
        end;  // for
    finally
      {$ifdef DELPHI5OROLDER}
      FreeMem(PropList, Data^.PropCount * Sizeof(PPropInfo));
      {$endif}
    end;
    if AnObject is TComponent then
      for i := 0 to TComponent(AnObject).ComponentCount - 1 do begin
        comp:=TComponent(AnObject).Components[i];
        if not TP_IgnoreList.Find(uppercase(comp.Name),j) then begin
          TranslatePropertiesSub(comp,uppercase(comp.Name),TextDomain);
        end;
      end;
  finally
    FreeAndNil (ObjectPropertyIgnoreList);
  end;
end;

procedure TGnuGettextInstance.UseLanguage(LanguageCode: string);
var
  i,p:integer;
  dom:TDomain;
begin
  if LanguageCode='' then begin
    LanguageCode:=GetEnvironmentVariable('LANG');
    {$ifdef MSWINDOWS}
    if LanguageCode='' then
      LanguageCode:=GetWindowsLanguage;
    {$endif}
    p:=pos('.',LanguageCode);
    if p<>0 then
      LanguageCode:=copy(LanguageCode,1,p-1);
  end;

  curlang := LanguageCode;
  gettext_putenv('LANG=' + LanguageCode);
  for i:=0 to domainlist.Count-1 do begin
    dom:=domainlist.Objects[i] as TDomain;
    dom.SetLanguageCode (curlang);
  end;
  {$ifdef LINUX}
  setlocale (LC_MESSAGES, PChar(LanguageCode));
  {$endif}
end;

{ TClassMode }

constructor TClassMode.Create;
begin
  PropertiesToIgnore:=TStringList.Create;
  PropertiesToIgnore.Sorted:=True;
  PropertiesToIgnore.Duplicates:=dupIgnore;
end;

destructor TClassMode.Destroy;
begin
  FreeAndNil (PropertiesToIgnore);
  inherited;
end;

{ TAssemblyAnalyzer }

procedure TAssemblyAnalyzer.Analyze;
var
  s:ansistring;
  i:integer;
  offset:int64;
  fs:TFileStream;
  fi:TAssemblyFileInfo;
  filename:string;
begin
  s:='6637DB2E-62E1-4A60-AC19-C23867046A89'#0#0#0#0#0#0#0#0;
  s:=copy(s,length(s)-7,8);
  offset:=0;
  for i:=8 downto 1 do
    offset:=offset shl 8+ord(s[i]);  
  if offset=0 then
    exit;
  BaseDirectory:=ExtractFilePath(paramstr(0));
  try
    fs:=TFileStream.Create(paramstr(0),fmOpenRead or fmShareDenyNone);
    try
      while true do begin
        fs.Seek(offset,soFromBeginning);
        offset:=ReadInt64(fs);
        if offset=0 then
          exit;
        fi:=TAssemblyFileInfo.Create;
        try
          fi.Offset:=ReadInt64(fs);
          fi.Size:=ReadInt64(fs);
          SetLength (filename, offset-fs.position);
          fs.ReadBuffer (filename[1],offset-fs.position);
          filename:=trim(filename);
          filelist.AddObject(filename,fi);
        except
          FreeAndNil (fi);
          raise;
        end;
      end;
    finally
      FreeAndNil (fs);
    end;
  except
  end;
end;

constructor TAssemblyAnalyzer.Create;
begin
  filelist:=TStringList.Create;
  filelist.Duplicates:=dupError;
  {$ifdef LINUX}
  filelist.CaseSensitive:=True;
  {$endif}
  {$ifndef DELPHI5OROLDER}
  {$ifdef MSWINDOWS}
  filelist.CaseSensitive:=False;
  {$endif}
  {$endif}
  filelist.Sorted:=True;
end;

destructor TAssemblyAnalyzer.Destroy;
begin
  while filelist.count<>0 do begin
    filelist.Objects[0].Free;
    filelist.Delete (0);
  end;
  FreeAndNil (filelist);
  inherited;
end;

function TAssemblyAnalyzer.FileExists(filename: string): boolean;
var
  idx:integer;
begin
  if copy(filename,1,length(basedirectory))=basedirectory then 
    filename:=copy(filename,length(basedirectory)+1,maxint);
  Result:=filelist.Find(filename,idx);
end;

procedure TAssemblyAnalyzer.GetFileInfo(filename: string;
  var realfilename: string; var offset, size: int64);
var
  fi:TAssemblyFileInfo;
  idx:integer;
begin
  offset:=0;
  size:=0;
  realfilename:=filename;
  if copy(filename,1,length(basedirectory))=basedirectory then begin
    filename:=copy(filename,length(basedirectory)+1,maxint);
    idx:=filelist.IndexOf(filename);
    if idx<>-1 then begin
      fi:=filelist.Objects[idx] as TAssemblyFileInfo;
      realfilename:=paramstr(0);
      offset:=fi.offset;
      size:=fi.size;
    end;
  end;
end;

function TAssemblyAnalyzer.ReadInt64(str: TStream): int64;
begin
  Assert (sizeof(Result)=8);
  str.ReadBuffer(Result,8);
end;

{ TTP_Retranslator }

constructor TTP_Retranslator.Create;
begin
  list:=TList.Create;
end;

destructor TTP_Retranslator.Destroy;
var
  i:integer;
begin
  for i:=0 to list.Count-1 do
    TObject(list.Items[i]).Free;
  FreeAndNil (list);
  inherited;
end;

procedure TTP_Retranslator.Execute;
var
  i:integer;
  item:TTP_RetranslatorItem;
  newvalue:WideString;
  {$ifndef DELPHI5OROLDER}
  ppi:PPropInfo;
  {$endif}
begin
  for i:=0 to list.Count-1 do begin
    item:=TObject(list.items[i]) as TTP_RetranslatorItem;
    newValue:=instance.dgettext(textdomain,item.OldValue);
    if item.obj is TStrings then begin
      if uppercase(item.Propname)='TEXT' then begin
        (item.obj as TStrings).Text:=newValue;
      end;
    end else begin
      {$ifdef DELPHI5OROLDER}
      SetStrProp(item.obj, item.PropName, newValue);
      {$endif}
      {$ifndef DELPHI5OROLDER}
      ppi:=GetPropInfo(item.obj, item.Propname);
      if ppi=nil then
        raise Exception.Create ('Property disappeared...');
      SetWideStrProp(item.obj, ppi, newValue);
      {$endif}
    end;
  end;
end;

procedure TTP_Retranslator.Remember(obj: TObject; PropName: String;
  OldValue: WideString);
var
  item:TTP_RetranslatorItem;
begin
  item:=TTP_RetranslatorItem.Create;
  item.obj:=obj;
  item.Propname:=Propname;
  item.OldValue:=OldValue;
  list.Add(item);
end;

initialization
  AssemblyAnalyzer:=TAssemblyAnalyzer.Create;
  AssemblyAnalyzer.Analyze;
  TPDomainList:=TStringList.Create;
  TPDomainList.Add(DefaultTextDomain);
  TPDomainListCS:=TMultiReadExclusiveWriteSynchronizer.Create;
  DefaultInstance:=TGnuGettextInstance.Create;
  {$ifdef MSWINDOWS}
  Win32PlatformIsUnicode := (Win32Platform = VER_PLATFORM_WIN32_NT);
  // replace Borlands LoadResString with gettext enabled version:
  OverwriteProcedure(@system.LoadResString, @LoadResStringA);
  {$endif}

finalization
  FreeAndNil (DefaultInstance);
  FreeAndNil (TPDomainListCS);
  FreeAndNil (TPDomainList);
  {$ifdef mswindows}
  // Unload the dll
  if dllmodule <> 0 then
    FreeLibrary(dllmodule);
  {$endif}
  FreeAndNil (AssemblyAnalyzer);

end.