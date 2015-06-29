require 'lcsort'

class Lcsort
  # Volume-type abbreviations used in call numbers, taken from
  # https://www.libraries.psu.edu/psul/cataloging/catref/callnumbers/callterms.html
  #
  # We create an array of them, just the abbreviations without the periods,
  # normalized to upcase. 
  #
  # We also add a few more. 
  #
  # This is used for left-padding vol/num numbers with 0's in the 'extra',
  # So they sort properly. 


  abbrevs = [
    'Abh', # Abhandlung
    'Abs', # Abschnitt
    'abstr', # abstracts
    'Abt', # Abteilung, Abtheilung
    'addendum', #addendum
    'addit', # additamenta (Latin)
    'afd', # afdeling
    'afl', # aflevering
    'anejo', # anejo
    'anexo', # annexo
    'annex', # annex
    'appx', #appendix
    'ar', #arithmos (Greek)
    'arg', # argang
    'atlas', # atlas
    'aux', # auxiliary
    'avd', # avdeling
     

    'Bdchn', # Bandchen
    'Bde', # Bande
    'Bd', #Band (German)
    'bd', #band (Swedish), b'and (Yiddish)
    'bk', #book
    'bklet', # booklet
    'Buch', #Buch
     

    'canto', # canto
    'cart', #cartridge
    'cs', #cassette
    'c', # cast
    'chap', #chapter [1]
    'charts', #charts
    'ch', #chast', chastyna
    'cis', # cislo
    'class', # class
    'comment', # commentarium, commentaries
    'cong', #congress
    'cz', #czesc
     

    'd', # disc
    'dala', #dala
    'dalis', # dalis
    'deel', #deel [2]
    'del', # del [2]
    'deo', # deo
    'dial', #dial
    'diel', #diel
    'dil', # dil
    'dzel', #dzel
     

    'ed', #edition
    'Ergbd', # Erganzungsband
    'Erghft', #Erganzungsheft
     

    'F', # Folge
    'fasc', #fascicle, fasciculus
    'Fasz', #Faszikel
     

    'g', # godina
    'Gesamtausg', #Gesamtausgabe
    'graphs', #graphs
    'guide', # guide
     

    'hft', # hafte (Swedish)
    'Halbbd', #Halbband
    'halvbd', #halvband (Swedish)
    'handbk', #handbook
    'Hft', # Heft
    'hov',  # hoveret (Hebrew)
     

    'illus', # illustration, -s [3]
    'index', # index
    'intro', # introduction [4]
     

    'jaarg', # jaargang
    'Jahrg', # Jahrgang
    'Jahrhdt', # Jahrhundert
     

    'Kap', # Kapitel
    'kn', #kniga, kniha
    'knj', # knjiga
    'koide', # koide
    'kommentar', # kommentar
    'kot', # kotet
     

    'Lfg', # Lieferung
    'livr', #livraison
    'livre', # livre
     

    'maj', # major
    'manual', #manual
    'maps', #maps
    'med', # medium
    'min', # minor
    'module', #module
    'ms\'', # mispar (Yiddish)
     

    'n.F', # neue Folge
    'n.s', # new series, nuova serie,nova serie, nueva serie [5]
    'nom', # nomer
    'nouv', #nouveau, nouvelle
    'no', #number, -s, numero (French), numero (Spanish)
    'nr', #numer
    'n', # numero (Italian)
    'n:o', # numero (Finnish)
    'Nr', #Nummer
    'nr', #nummer
     

    'op', #opus
    'osa', # osa
    'osat', #osat (Finnish)
    'otd', # otdel, otdelenie
     

    'pars', #pars
    'pt', 
    'pts', #part, -s
    'pt', #parte
    'ptie', #partie
    'p', # pik
    'plates', #plates
    'portfolio', # [6] portfolio
    'prelim', #preliminary
     

    'qtr', # quarter
     

    'reel', #reel
    'rept', #report
    'rev', # revised, revision
    'r', # rik
    'roc', # rocnik
    'rocz', #rocznik
    'r', # rok
     

    'Samml', # Sammlung
    'sect', #section
    'sejums', #sejums
    'ser', # serie, series
    'ses', # sesit
    'sess', #session
    'study', # study
    'sub', # subject
    'suppl', # supplement
    'sv', #svazek, svazok, sveska, svezak
    'sz', #szam
     

    'tables', #tables
    'T', # Teil, Theil
    'Tbd', # Teilband
    'theme', # theme
    'title', # title
    'Titel', # Titel (German)
    't', # tom, tome, tomo, tomos, tomus
    'tl', #tayl, tiyl (Yiddish)
     

    'Uabs', #Unterabschnitt
     

    'v', # volume, -s
    'vol', # volumul
    'Vorber', #Vorbericht
    'vyp', # vypusk
     

    'workbk', #workbook
     

    'yaarg', # yaargang (Hebrew)
     

    'zesz', #zeszyt
    'zosh', #zoshyt
    'zv', #zvazok, zvezek
  ]
  abbrevs = abbrevs.collect {|a| a.upcase}

  abbrevs << "K"  # Mozart Kochel catalog number

  VolumeAbbreviations = abbrevs

end
