#  Dubsar Dictionary Project
#  Copyright (C) 2010-14 Jimmy Dee
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 2
#  of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

# The following code loads the WN 3.1 data set without changing row IDS for
# senses, synsets or words whenever possible. It should work with any subsequent
# update using the same file format, with the exception of this list, which
# refers to the numeric offset of each synset as listed in the first column of each
# row in the data.* files. These represent synsets with significant changes that
# are difficult to identify automatically. If using this code with any subsequent
# data set, remove the contents of the dictionary for each part of speech below, so
# that you have "adjective" => {}, "adverb" => {}, and so forth. Synsets in this
# list will not be identified by the synset_for_data_line method otherwise with WN 3.1.
#
# The key in the dictionary for each part of speech is the offset read from the
# data file, as a string, with the initial 0's stripped. The value is an integer
# equal to the synset ID in the database for the matching synset.
#
# Essentially, any synset listed here will have the assigned ID. If this list is empty
# or incorrect, the build will succeed, but old rows will be replaced by equivalent new
# ones that may differ by little. Any correspondence between these synsets in WN 3.1
# with their equivalents in 3.0 will be lost. This will be inconvenient for search engines
# and caches of any kind, as well as any sort of bookmarking. The WOTD history may be
# incorrect for the next month. But the content of the DB will be exactly the content
# of WN 3.1.
@synset_exceptions = {
  "adjective" => {
    "24458" => 116,
    "24701" => 117,
    "25079" => 119,
    "43834" => 222,
    "51791" => 266,
    "52486" => 427,
    "101225" => 530,
    "106981" => 562,
    "119817" => 628,
    "123654" => 650,
    "165213" => 889,
    "177648" => 952,
    "178829" => 957,
    "242247" => 1340,
    "243558" => 1349,
    "247479" => 1376,
    "302053" => 1670,
    "302637" => 1673,
    "318624" => 1755,
    "357450" => 1979,
    "403798" => 2284,
    "403922" => 2286,
    "414699" => 2343,
    "427259" => 2411,
    "490985" => 2752,
    "492970" => 2761,
    "493366" => 2763,
    "510662" => 2860,
    "2331344" => 2939,
    "529920" => 2957,
    "533833" => 2975,
    "537047" => 2988,
    "537516" => 2992,
    "558079" => 3101,
    # manually edited data.adj for 562326 to correct spelling of "crowded".
    # parsing here does not depend on offsets being accurate, just unique.
    "562326" => 3127,
    "575501" => 3195,
    "576056" => 3198,
    "594915" => 3291,
    "596783" => 3301,
    "598545" => 3306,
    "2506031" => 3357,
    "618080" => 3415,
    "627729" => 3478,
    "628097" => 3480,
    "660221" => 3651,
    "661271" => 3657,
    "662119" => 3663,
    "683799" => 3789,
    "699967" => 3876,
    "700543" => 3879,
    "714186" => 3944,
    "717749" => 3962,
    "735762" => 4054,
    "736942" => 4060,
    "746008" => 4114,
    "752408" => 4144,
    "760641" => 4187,
    "768832" => 4224,
    "786516" => 4314,
    "828657" => 4537,
    "829356" => 4540,
    "868970" => 4748,
    "881395" => 4815,
    "889690" => 4860,
    "911705" => 4973,
    "913487" => 4981,
    "923395" => 5039,
    "946057" => 5163,
    "953800" => 5209,
    "973992" => 5313,
    "992194" => 5412,
    "997760" => 5443,
    "1012028" => 5523,
    "1012335" => 5525,
    "1018989" => 5554,
    "1022875" => 5575,
    "1033904" => 5633,
    "1034170" => 5635,
    "1047301" => 5716,
    "1065188" => 5818,
    "1116284" => 6107,
    "1119860" => 6123,
    "1121419" => 6129,
    "1143790" => 6238,
    "1149209" => 6267, # manually changed veritcal to vertical
    "1159105" => 6323,
    "2608757" => 6575,
    "1249700" => 6822,
    "1251747" => 6831,
    "1253778" => 6843,
    "1554025" => 7074,
    "1303318" => 7085,
    "1308279" => 7113,
    "1320185" => 7175,
    "1338108" => 7281,
    "1341128" => 7296,
    "667636" => 7318,
    "1362125" => 7405,
    "1362306" => 7406,
    "1371994" => 7458,
    "1386320" => 7531,
    "1395848" => 7584,
    "1407374" => 7659,
    "1408930" => 7670,
    "1415578" => 7705,
    "1418056" => 7722,
    "1444145" => 7877,
    "187511" => 7926,
    "1459756" => 7970,
    "1461111" => 7979,
    "1461331" => 7980,
    "1461461" => 7981,
    "1461579" => 7982,
    "1461821" => 7983,
    "1461939" => 7984,
    "1466459" => 8009,
    "1468558" => 8020,
    "1475013" => 8061,
    "1475232" => 8062,
    "1478687" => 8081,
    "1490267" => 8154,
    "1490840" => 8158,
    "1493868" => 8174,
    "1159816" => 8183,
    "1514513" => 8292,
    "1514879" => 8295,
    "1515033" => 8296,
    "1517859" => 8310,
    "1524174" => 8344,
    "1537778" => 8421,
    "1542473" => 8445,
    "1542711" => 8446,
    "1558769" => 8533,
    "1581122" => 8645,
    "1613579" => 8815,
    "1644403" => 8978,
    "2682500" => 9133,
    "1679481" => 9181,
    "1682215" => 9190,
    "1751027" => 9421,
    "1734977" => 9494,
    "1737104" => 9506,
    "1752186" => 9592,
    "1757717" => 9624,
    "1759375" => 9632,
    "1773890" => 9707,
    "1803966" => 9887,
    "1806732" => 9898,
    "1807949" => 9900,
    "1808909" => 9905,
    "1812324" => 9923,
    "1848878" => 10126,
    "1852738" => 10146,
    "1868236" => 10226,
    "1880529" => 10286,
    "1884969" => 10312,
    "1885720" => 10315,
    "1895355" => 10365,
    "1920631" => 10498,
    "1940682" => 10601,
    "1943120" => 10610,
    "1968015" => 10739,
    "1972513" => 10765,
    "1991733" => 10869,
    "2007041" => 10949,
    "2031662" => 11090,
    "2032205" => 11093,
    "2037940" => 11126,
    "2048059" => 11179,
    "2058261" => 11248,
    "2059434" => 11255,
    "86117" => 11365,
    "2098311" => 11460,
    "2141133" => 11681,
    "2141804" => 11685,
    "2171017" => 11887,
    "2187588" => 11985,
    "2203651" => 12104,
    "2275064" => 12553,
    "2276242" => 12557,
    "2277044" => 12561,
    "2287272" => 12612,
    "2305827" => 12721,
    "2328429" => 12855,
    "2328637" => 12856,
    "2332671" => 12877,
    "2333471" => 12881,
    "2344113" => 12938,
    "2344882" => 12942,
    "2351216" => 12976,
    "2354846" => 12995,
    "2359909" => 13026,
    "2371053" => 13081,
    "2412395" => 13306,
    "2334464" => 13308,
    "2435043" => 13425,
    "2435464" => 13428,
    "2444489" => 13485,
    "2445119" => 13487,
    "2455914" => 13561,
    "2463673" => 13608,
    "2475791" => 13666,
    "2479427" => 13686,
    "2505376" => 13843,
    "2512593" => 13880,
    "2516967" => 13901,
    "2528983" => 13969,
    "2542324" => 14043,
    "2542621" => 14045,
    "2548215" => 14078,
    "2548368" => 14079,
    "2548500" => 14080,
    "2548631" => 14081,
    "2548820" => 14082,
    "2548958" => 14083,
    "2549079" => 14084,
    "2549225" => 14085,
    "2570464" => 14200,
    "2532138" => 14242,
    "2581199" => 14268,
    "2582052" => 14270,
    "2596626" => 14350,
    "2171017" => 14354,
    "2784673" => 15671,
    "2900710" => 16438,
    "2916222" => 16535,
    "2943474" => 16701,
    "2964788" => 16842,
    "3099007" => 17700,
    "3119449" => 17830,
    "3119629" => 17831
  },
  "adverb" => {
    "2669" => 18163,
    "3317" => 18165,
    "8102" => 18195,
    "20362" => 18256,
    "21667" => 18264,
    "27761" => 18298,
    "36138" => 18350,
    "172866" => 18528,
    "80132" => 18621,
    "80266" => 18622,
    "86161" => 18664,
    "95613" => 18732,
    "95742" => 18733,
    "103874" => 18787,
    "109919" => 18828,
    "110206" => 18830,
    "113022" => 18976,
    "140318" => 19067,
    "145227" => 19108,
    "149175" => 19135,
    "156898" => 19192,
    "157363" => 19196,
    "165875" => 19254,
    "168477" => 19274,
    "168718" => 19276,
    "169587" => 19283,
    "172866" => 19305,
    "174785" => 19322,
    "187293" => 19412,
    "192471" => 19453,
    "193383" => 19459,
    "196934" => 19488,
    "197608" => 19493,
    "212370" => 19596,
    "224618" => 19672,
    "232612" => 19730,
    "237364" => 19762,
    "247755" => 19839,
    "261760" => 19958,
    "269134" => 20010,
    "280708" => 20098,
    "297139" => 20206,
    "305545" => 20255,
    "306956" => 20266,
    "333090" => 20429,
    "344222" => 20499,
    "382155" => 20747,
    "400747" => 20877,
    "458383" => 21347,
    "472106" => 21403,
    "473918" => 21415,
    "503489" => 21646,
    "386914" => 21654,
    "505869" => 21664,
    "508298" => 21681
  },
  "noun" => {
    "45638" => 21875,
    "50548" => 21898,
    "173531" => 22554,
    "258637" => 22982,
    "422316" => 23852,
    "432277" => 23896,
    "443377" => 23956,
    "460751" => 24065,
    "464604" => 24088,
    "469063" => 24104,
    "609469" => 24855,
    "609736" => 24856,
    "632200" => 24975,
    "728118" => 25481,
    "728250" => 25482,
    "751514" => 25611,
    "774891" => 25705,
    "789119" => 25778,
    "847184" => 26079,
    "919445" => 26460,
    "967829" => 26693,
    "998599" => 26853,
    "1046116" => 27106,
    "1156868" => 27684,
    "1259202" => 28223,
    "1259362" => 28224,
    "1296823" => 28405,
    "2410277" => 34501,
    "2686412" => 36088,
    "2716785" => 36267,
    "2723487" => 36294,
    "2733566" => 36342,
    "2803952" => 36748,
    "2825534" => 36887,
    "2828584" => 36908,
    "2829422" => 36914,
    "2834779" => 36948,
    "2839812" => 36980,
    "2841101" => 36989,
    "2842193" => 36996,
    "2844544" => 37012,
    "2853790" => 37072,
    "2857998" => 37096,
    "2861187" => 37115,
    "2861345" => 37116,
    "2872589" => 37181,
    "2896189" => 37324,
    "2899704" => 37346,
    "2904397" => 37375,
    "2906120" => 37387,
    "2914189" => 37441,
    "2950279" => 37658,
    "2971443" => 37783,
    "3003364" => 37967,
    "3012598" => 38023,
    "3023088" => 38094,
    "3347602" => 39955,
    "3409064" => 40336,
    "3443167" => 40535,
    "3448836" => 40570,
    "3461243" => 40652,
    "3482896" => 40793,
    "3499638" => 40889,
    "3529313" => 41069,
    "3542421" => 41146,
    "3599921" => 41475,
    "3605477" => 41509,
    "3642609" => 41736,
    "3840952" => 42892,
    "3905309" => 43287,
    "3909811" => 43315,
    "3922839" => 43394,
    "3931348" => 43444,
    "4130834" => 44608,
    "4160108" => 44792,
    "4212364" => 45082,
    "4229661" => 45194,
    "4231230" => 45204,
    "4238967" => 45255,
    "4279164" => 45518,
    "4345281" => 45922,
    "4363134" => 46026,
    "4400491" => 46244,
    "4401914" => 46253,
    "4487538" => 46765,
    "4546830" => 47116,
    "4594218" => 47398,
    "4599768" => 47432,
    "4692211" => 47905,
    "4756794" => 48218,
    "4774278" => 48297,
    "4788030" => 48367,
    "4811860" => 48485,
    "4819019" => 48524,
    "4995915" => 49451,
    "5002599" => 49489,
    "5051127" => 49741,
    "5097462" => 49979,
    "5128718" => 50137,
    "5162155" => 50304,
    "5223633" => 50614,
    "5232895" => 50652,
    "5246919" => 50719,
    "5321780" => 51116,
    "5432547" => 51390,
    "5432307" => 51694,
    "5534035" => 52198,
    "5619057" => 52630,
    "5640055" => 52739,
    "5685184" => 52983,
    "5756230" => 53344,
    "5791038" => 53513,
    "5798949" => 53550,
    "5822120" => 53668,
    "5910447" => 54089,
    "5935996" => 54212,
    "5941068" => 54239,
    "6033170" => 54667,
    "6134103" => 55028,
    "6164956" => 55030,
    "6162992" => 55143,
    "6229122" => 55445,
    "5989123" => 55471,
    "6240471" => 55502,
    "6226161" => 55508,
    "6249497" => 55538,
    "6325134" => 55895,
    "6394213" => 56255,
    "6436708" => 56494,
    "6604544" => 57332,
    "6655934" => 57624,
    "6766514" => 58216,
    "6836640" => 58587,
    "6905066" => 58951,
    "6952319" => 59292,
    "6979234" => 59454,
    "6984279" => 59484,
    "7026665" => 59751,
    "7048658" => 59858,
    "7048968" => 59859,
    "7123492" => 60253,
    "7191150" => 60597,
    "7309129" => 61260, # edited poetic_jstice
    "7569690" => 62692,
    "7600424" => 62859,
    "7895635" => 64874,
    "7915951" => 65003,
    "7985266" => 65426,
    "7993684" => 65463,
    "8024219" => 65612,
    "8073958" => 65785,
    "8102739" => 65933,
    "8154010" => 66160,
    "8168497" => 66223,
    "8517241" => 67956,
    "8561479" => 68115,
    "8581164" => 68223,
    "8606395" => 68347,
    "8625308" => 68444,
    "8922758" => 69755,
    "8923207" => 69758,
    "8925281" => 69776,
    "8925719" => 69777,
    "8986934" => 70039,
    "8987197" => 70040,
    "9133059" => 70741,
    "9190986" => 71045,
    "9366956" => 71960,
    "9392309" => 72093,
    "9418792" => 72227,
    "9450914" => 72379,
    "9551861" => 72951,
    "9553360" => 72963,
    "9555346" => 72976,
    "9593643" => 73191,
    "9602248" => 73238,
    "9659490" => 73495,
    "9660255" => 73510,
    "9693448" => 73708,
    "9695732" => 73725,
    "9695957" => 73727,
    "9696139" => 73728,
    "9755744" => 74109,
    "9756838" => 74117,
    "9757020" => 74118,
    "9839449" => 74580,
    "9872949" => 74794,
    "9890770" => 74906,
    "10021475" => 75686,
    "10081850" => 76018,
    "10095821" => 76103,
    "10099673" => 76128,
    "10176938" => 76624,
    "10177117" => 76625,
    "10193566" => 76733,
    "10202544" => 76785,
    "10230422" => 76955,
    "10316895" => 77472,
    "10343657" => 77639,
    "10348226" => 77668,
    "10454188" => 78269,
    "10421528" => 78303,
    "10474308" => 78368,
    "10522535" => 78647,
    "10571133" => 78943,
    "10595760" => 79089,
    "10626886" => 79275,
    "10662798" => 79483,
    "10662895" => 79484,
    "10698101" => 79687,
    "10705796" => 79736,
    "10742949" => 79970,
    "10750194" => 80019,
    "10798906" => 80345,
    "10849337" => 80589,
    "10884454" => 80783,
    "10994732" => 81362,
    "11086420" => 81855,
    "11319202" => 83143,
    "11471676" => 84000,
    "12104901" => 86892,
    "12417727" => 88392,
    "13168466" => 91972,
    "13286803" => 92600,
    "13351613" => 92991,
    "13615208" => 94366,
    "13667846" => 94651,
    "13931968" => 96267,
    "13990169" => 96564,
    "13990515" => 96566,
    "14032966" => 96785,
    "14280859" => 98080,
    "14350534" => 98474,
    "14452888" => 99065,
    "14595655" => 99829,
    "14944995" => 101744,
    "14973365" => 101919,
    "15010563" => 102129,
    "15013061" => 102143,
    "15149100" => 102909,
    "15227065" => 103340
  },
  "verb" => {
    "3316" => 103899,
    "8435" => 103924,
    "35596" => 104071,
    "54345" => 104161,
    "57849" => 104180,
    "106714" => 104423,
    "153784" => 104590,
    "175817" => 104693,
    "179012" => 104714,
    "187671" => 104765,
    "196708" => 104817,
    "203298" => 104853,
    "235689" => 105010,
    "277400" => 105216,
    "288320" => 105273,
    "313597" => 105407,
    "391513" => 105800,
    "419690" => 105932,
    "463047" => 106144,
    "463563" => 106145,
    "550851" => 106606,
    "587970" => 106813,
    "714537" => 107271,
    "718950" => 107402,
    "899241" => 107722,
    "873606" => 108099,
    "898453" => 108214,
    "905665" => 108250,
    "615215" => 108405,
    "1009072" => 108663,
    "1199565" => 109720,
    "1303637" => 110298,
    "1304044" => 110300,
    "1324555" => 110411,
    "1486108" => 111250,
    "1490749" => 111276,
    "1492094" => 111285,
    "1584919" => 111754,
    "1637966" => 112033,
    "1748492" => 112571,
    "1765377" => 112666,
    "1872244" => 113160,
    "1927051" => 113445,
    "2048171" => 114080,
    "233707" => 115963,
    "2428558" => 115968,
    "2490911" => 116261,
    "2514936" => 116374,
    "2581611" => 116679,
    "2591574" => 116725,
    "2593624" => 116736,
    "2624202" => 116880,
    "2655932" => 117034,
    "1185870" => 117120,
    "2714280" => 117318
  }
}

@word_exceptions = {
  "adjective" => {
    "retaliative" => 13365
  },
  "adverb" => {
  },
  "noun" => {
    "Sempach" => 35419,
    "battle of Sempach" => 35420,
    "blue jeans" => 57408,
    "pedal pushers" => 59903,
    "skivvies" => 62285,
    "penetralium" => 90852,
    "Mount Rainier National Park" => 90951,
    "Kennedy International" => 94264,
    "Rainier" => 96067,
    "Mount Rainier" => 96068,
    "Mt. Rainier" => 96069
  },
  "verb" => {
  }
}

@new_inflections = {
  "adjective" => {},
  "adverb" => {},
  "noun" => {
    "gip" => %w{gips},
    "bricolage" => %w{bricolages},
    "neuromarketing" => %w{neuromarketings},
    "chinos" => [], # already plural
    "moulin" => %w{moulins},
    "lacunar" => %w{lacunars lacunaria},
    "golfclub" => %w{golfclubs},
    "liftgate" => %w{liftgates},
    "jeans" => [], # already plural
    "mic" => %w{mics},
    "humidifier" => %w{humidifiers},
    "dehumidifier" => %w{dehumidifiers},
    "trousers" => [], # already plural
    "kenosis" => %w{kenoses},
    "dendrology" => %w{dendrologies},
    "panentheism" => %w{panentheisms},
    "pandeism" => %w{pandeisms},
    "paronym" => %w{paronyms},
    "manga" => [], # same in plural
    "malware" => %w{malwares},
    "volvelle" => %w{volvelles},
    "initialism" => %w{initialisms},
    "promo" => %w{promos},
    "obsequy" => %w{obsequies},
    "criterium" => %w{criteriums}, # bicycle road race
    "crit" => %w{crits}, # " " "
    "mysoandry" => %w{mysoandries},
    "moon" => %w{moongs},
    # "munggo" => %w{munggos munggoes}, # Or no plural? From Tagalog and other languages.
    # "monggo" => %w{monggos monggoes}, # Or no plural? From Tagalog and other languages.
    "munggo" => [], # Or no plural? From Tagalog and other languages.
    "monggo" => [], # Or no plural? From Tagalog and other languages.
    "tamal" => %w{tamales},
    "zumbooruk" => %w{zumbooruks},
    "zumbooruck" => %w{zumboorucks},
    "zamburek" => %w{zambureks},
    "zamboorak" => %w{zambooraks},
    "zamburak" => %w{zamburaks},
    "depths" => [], # already plural
    "concertinist" => %w{concertinists},
    "biker" => %w{bikers},
    "dyslexic" => %w{dyslexics},
    "kiddie" => %w{kiddies},
    "transgendered" => %w{transgendereds},
    "clochard" => %w{clochards},
    "rem" => [], # same in the plural
    "mrem" => [], # same in the plural
    "millirem" => [], # same in the plural
    "bazillion" => %w{bazillions},
    "lemniscate" => %w{lemniscates},
    "couth" => %w{couths},
    "polynucleotide" => %w{polynucleotides},
    "oligonucleotide" => %w{oligonucleotides},
    "oligo" => %w{oligos},
    "vacay" => %w{vacays}
  },
  "verb" => {
    "minor" => %w{minors minoring minored},
    "rewind" => %w{rewinds rewinding rewound},
    "underrun" => %w{underruns underrunning underran},
    "exfiltrate" => %w{exfiltrates exfiltrating exfiltrated},
    "regift" => %w{regifts regifting regifted},
    "babysit" => %w{babysits babysitting babysat}
  }
}

def strings_equal_by_words(s1, s2)
  words1 = s1.split(/[^A-Za-z0-9]+/)
  words2 = s2.split(/[^A-Za-z0-9]+/)

  return false unless words1.count == words2.count

  words1.join(" ") == words2.join(" ")
end

def word_count(s)
  s.split(/[^A-Za-z0-9]+/).count
end

def words_in_common(s1, s2)
  words1 = s1.split(/[^A-Za-z0-9]+/)
  words2 = s2.split(/[^A-Za-z0-9]+/)

  smaller_list = words1.count < words2.count ? words1 : words2
  larger_list = words1.count < words2.count ? words2 : words1

  smaller_list.count { |w| larger_list.include? w }
end

# Poorly named method. Returns true if and only if one of defn1 and defn2
# contains all the words in the other. This happens a lot: samples and qualifying phrases
# like "(used in the plural)" are added and removed.
def definitions_overlap(defn1, defn2)
  words1 = defn1.split(/[^A-Za-z0-9]+/).uniq
  words2 = defn2.split(/[^A-Za-z0-9]+/).uniq

  words1.all? { |word| words2.include? word } or words2.all? { |word| words1.include? word }
end

def make_word!(name, part_of_speech)
  inflections = @irregular_inflections[name.gsub(' ', '_').to_sym] || []

  inflections << name # may dupe, but don't care that much

  new_inflections = @new_inflections[part_of_speech][name]
  if new_inflections
    puts "add'l inflections for new word #{name}, #{part_of_speech}: #{new_inflections.join(", ")}"
    inflections += new_inflections
  else
    puts "no add'l inflections for new word #{name}, #{part_of_speech}"
  end
  STDOUT.flush

  spelling_change = @word_exceptions[part_of_speech][name]
  if spelling_change
    word = Word.find(spelling_change)
    puts "spelling change for Word #{spelling_change} from \"#{word.name}\" to \"#{name}\""
    word.update_attributes name: name

    word.inflections.destroy_all

    inflections.each do |inflection|
      word.inflections.create! name: inflection
    end

    return word
  end

  puts "New word: #{name}, #{part_of_speech}"

  @new_word_count += 1
  word = Word.create! name: name, part_of_speech: part_of_speech, irregular: inflections

  @new_inflections_required << word if
    (part_of_speech == "noun" || part_of_speech == "verb") && name =~ /^[a-z]+$/
  word
end

def make_synset!(offset, defn, lexname, part_of_speech, synonyms, markers)
  @new_synset_count += 1
  synset = Synset.create! offset: offset, definition: defn, lexname: lexname, part_of_speech: part_of_speech

  synonyms.each_with_index do |synonym, index|
    make_synonym! synset, synonym, markers[index], part_of_speech
  end
  synset
end

def make_synonym!(synset, synonym, marker, part_of_speech)
  word = Word.find_by_name_and_part_of_speech synonym, part_of_speech
  word ||= make_word! synonym, part_of_speech

  @new_sense_count += 1
  Sense.create! synset_id: synset.id, word_id: word.id, marker: marker
end

def make_synonyms!(synset, synonyms, markers, part_of_speech)
  # out with the old
  synset.senses.each do |sense|
    next if synonyms.include? sense.word.name
    sense.destroy
  end

  # in with the new
  synonyms.each_with_index do |synonym, index|
    next if synset.words.where(name: synonym).count == 1
    make_synonym! synset, synonym, markers[index], part_of_speech
  end
end

def synset_for_data_line(line)
  left, defn = line.split('| ')
  synset_offset, lex_filenum, ss_type, w_cnt, *rest = left.split(' ')
  w_cnt = w_cnt.to_i(16)

  defn.chomp!
  synset_offset_s = synset_offset
  synset_offset = synset_offset.to_i

  synonyms = []
  markers = []
  sentence_array = []
  verb_frame_array = []

  # Read synonyms
  rest.slice(0, 2*w_cnt).each_slice(2) do |a|
    s = a[0].gsub('_', ' ')
    marker = nil

    md = /^(.+)\(([a-z]+)\)\s*$/.match s
    if md
      marker = md[2]
      s = md[1]
    end

    synonyms << s
    markers << marker

    if @part_of_speech == 'verb'
      lex_id = case a[1].to_i
      when (0..9)
        '0' + a[1]
      else
        a[1]
      end
      sense_key = "#{a[0]}%2:#{lex_filenum}:#{lex_id}::"
      sentences = @verb_sentences[sense_key]
    else
      sentences = nil
    end

    sentence_array << sentences

    p_cnt, *more = rest.slice(2*w_cnt, rest.length-2*w_cnt)
    if more
      p_cnt = p_cnt.to_i
  
      f_cnt, *more_frames = more.slice(4*p_cnt, more.length-4*p_cnt)
      f_cnt = f_cnt.to_i
      if f_cnt != 0 and more_frames
        more_frames.slice(0, 3*f_cnt).each_slice(3) do |f|
          plus, f_num, w_num = f
          verb_frame_id = @verb_frames[f_num.to_i][0]
          w_num = w_num.to_i
          verb_frame_array << [ w_num, verb_frame_id ]
        end
      end
    end
  end

  synset = nil

  exceptions = @synset_exceptions[@part_of_speech]
  synset_id = exceptions[synset_offset.to_s] if exceptions

  puts "synset exception ID for #{synset_offset.to_s}: #{synset_id}" if synset_id
  synset = Synset.find synset_id if synset_id

  # 1. Look for a synset with the same lexname, synonyms and definition.

  Synset.where(lexname:@lexnames[lex_filenum], definition: defn).each do |a_synset|
    if a_synset.senses.count == synonyms.count &&
      synonyms.all? { |synonym| a_synset.words.where(name: synonym).count == 1 }
      synset = a_synset if a_synset.id <= @max_synset_id # don't take new ones
      break
    end
  end unless synset

  defn.strip!

  # 2. Check each synonym's synsets from the DB to see if we can find something with
  #    a close definition
  synonyms.each do |synonym|
    word = Word.find_by_name_and_part_of_speech synonym, @part_of_speech
    word ||= make_word! synonym, @part_of_speech

    next unless word

    # Only looking for matches among the old 3.0 data set.
    word.synsets.where(["synsets.id <= ?", @max_synset_id]).each do |synonym_synset|
      stripped_synset_defn = synonym_synset.definition.strip
      if stripped_synset_defn == defn ||
        defn.starts_with?(stripped_synset_defn) ||
        stripped_synset_defn.starts_with?(defn) ||
        strings_equal_by_words(defn, stripped_synset_defn)

        synset = synonym_synset
      elsif synonym_synset.lexname == @lexnames[lex_filenum] &&
        synonym_synset.words.count == synonyms.count &&
        synonyms.all? { |synonym| synonym_synset.words.where(name: synonym).count == 1 }

        in_common = words_in_common(defn, stripped_synset_defn)
        defn_count = word_count(defn)
        stripped_synset_defn_count = word_count(stripped_synset_defn)

        # puts "Non-matching definition \"#{stripped_synset_defn}\" has #{in_common} of #{stripped_synset_defn_count} with \"#{defn}\" (#{defn_count})"
        # This difference has to be at least 1
        # If the two definitions differ by one word, take this one
        if defn_count == stripped_synset_defn_count && defn_count - in_common <= 1
          synset = synonym_synset
        end
      end

      if !synset && definitions_overlap(stripped_synset_defn, defn)
        synset = synonym_synset
      end
    end

    break if synset # synonyms.each
  end unless synset

  if !synset
    synset = make_synset! synset_offset, defn, @lexnames[lex_filenum], @part_of_speech, synonyms, markers
    puts "New Synset ID #{synset.id} at offset #{synset_offset} <#{@lexnames[lex_filenum]}> #{defn.strip} (#{synonyms.join(",")})"
  end

  synset.update_attributes offset: synset_offset unless synset.offset == synset_offset
  updated = false
  if @lexnames[lex_filenum] != synset.lexname

    updated = true
    puts "Lexname changed for Synset ID #{synset.id}: <#{@lexnames[lex_filenum]}>"
    synset.update_attributes lexname: @lexnames[lex_filenum]
  end

  # The definition and synonyms have changed, or they would have been found above.
  if defn != synset.definition.strip

    updated = true
    puts "Definition changed for Synset ID #{synset.id}: \"#{defn}\" (WAS \"#{synset.definition}\")"
    synset.update_attributes definition: defn
  end

  if synset.senses.count != synonyms.count ||
    synonyms.any? { |synonym| synset.words.where(name: synonym).count != 1 }

    updated = true
    puts "Synonyms changed for Synset ID #{synset.id}: \"#{synonyms.join(",")}\""
    make_synonyms! synset, synonyms, markers, @part_of_speech
  end

  # Update lexical info (after updating synonyms)
  synonyms.each_with_index do |synonym, index|
    sense = synset.senses.includes(:word).where(words: {name: synonym}).first

    sense_key = @part_of_speech + '_' + synset_offset_s + '_' + synonym.gsub(' ', '_')
    sense.update_attributes marker: markers[index], freq_cnt: @sense_index[sense_key.to_s], synset_index: index+1

    sentences = sentence_array[index]
    if sentences
      sentences.each do |number|
        frame = VerbFrame.find_by_number(number.to_i+1000)
        SensesVerbFrame.create :sense => sense, :verb_frame => frame if SensesVerbFrame.where(sense_id: sense.id, verb_frame_id: frame.id).blank?
      end
    end

    sense.word.save # update the freq. cnt. for each word
  end

  verb_frame_array.each do |entry|
    w_num = entry.first
    verb_frame_id = entry.second

    if w_num != 0
      sense = synset.senses.where(synset_index: w_num).first
      SensesVerbFrame.create :sense_id => sense.id, :verb_frame_id => verb_frame_id if SensesVerbFrame.where(sense_id: sense.id, verb_frame_id: verb_frame_id).blank?
    else
      synset.senses.each do |sense|
        SensesVerbFrame.create :sense_id => sense.id, :verb_frame_id => verb_frame_id if SensesVerbFrame.where(sense_id: sense.id, verb_frame_id: verb_frame_id).blank?
      end
    end
  end

  @updated_synset_count += 1 if updated

  synset.save
  synset
end

def pointer_type(symbol)
  case symbol
  when '!'
    'antonym'
  when '@'
    'hypernym'
  when '@i'
    'instance hypernym'
  when '~'
    'hyponym'
  when '~i'
    'instance hyponym'
  when '#m'
    'member holonym'
  when '#s'
    'substance holonym'
  when '#p'
    'part holonym'
  when '%m'
    'member meronym'
  when '%s'
    'substance meronym'
  when '%p'
    'part meronym'
  when '='
    'attribute'
  when '+'
    'derivationally related form'
  when ';c'
    'domain of synset (topic)'
  when '-c'
    'member of this domain (topic)'
  when ';r'
    'domain of synset (region)'
  when '-r'
    'member of this domain (region)'
  when ';u'
    'domain of synset (usage)'
  when '-u'
    'member of this domain (usage)'
  when '*'
    'entailment'
  when '>'
    'cause'
  when '^'
    'also see'
  when '$'
    'verb group'
  when '&'
    'similar to'
  when '<'
    'participle of verb'
  when '\\'
    'derived from/pertains to'
  else
    ''
  end
end

def reflected_pointer_type(symbol)
  case symbol
  when '!'
    'antonym'
  when '~'
    'hypernym'
  when '@'
    'hyponym'
  when '~i'
    'instance hypernym'
  when '@i'
    'instance hyponym'
  when '#m'
    'member meronym'
  when '#s'
    'substance meronym'
  when '#p'
    'part meronym'
  when '%m'
    'member holonym'
  when '%s'
    'substance holonym'
  when '%p'
    'part holonym'
  when '&'
    'similar to'
  when '='
    'attribute'
  when '$'
    'verb group'
  when '+'
    'derivationally related form'
  when ';c'
    'member of this domain (topic)'
  when '-c'
    'domain of synset (topic)'
  when ';r'
    'member of this domain (region)'
  when '-r'
    'domain of synset (region)'
  when ';u'
    'member of this domain (usage)'
  when '-u'
    'domain of synset (usage)'
  else
    ''
  end
end

@sense_index = Hash.new(0)
@lexnames = {}

@verb_frames = {}
File.open(File.expand_path('defaults/frames.vrb', File.dirname(__FILE__))).each do |line|
  matches = /^(\d+)\s+(.*)$/.match(line.chomp)
  number = matches[1].to_i
  frame = matches[2]
  verb_frame = VerbFrame.create :number => number, :frame => frame
  @verb_frames[number] = [ verb_frame.id, frame ]
end

puts "#{Time.now} loaded verb frames"
STDOUT.flush

File.open(File.expand_path('defaults/lexnames', File.dirname(__FILE__))).each do |line|
  number, name, pos_index = line.chomp.split
  @lexnames[number] = name
end

puts "#{Time.now} loaded lexical names"
STDOUT.flush

File.open(File.expand_path('../defaults/sents.vrb', __FILE__)).each do |line|
  matches = /^(\d+) (.*)$/.match(line.chomp)
  index = matches[1].to_i + 1000
  frame = matches[2]

  VerbFrame.create :frame => frame, :number => index
end

@verb_sentences = Hash.new []
File.open(File.expand_path('../defaults/sentidx.vrb', __FILE__)).each do |line|
  sense_key, sentences = line.chomp.split
  next unless sentences
  @verb_sentences[sense_key] = sentences.split(',')
end

puts "#{Time.now} loaded verb sentences"
STDOUT.flush

File.open(File.expand_path('defaults/index.sense', File.dirname(__FILE__))).each do |line|
  sense_key, synset_offset, sense_number, tag_cnt = line.chomp.split
  next if tag_cnt == '0'

  lemma, lex_sense = sense_key.split '%'
  ss_type, lex_filenum, lex_id, head_word, head_id = lex_sense.split ':'
  part_of_speech= case ss_type.to_i
  when 1
    'noun'
  when 2
    'verb'
  when 3,5
    'adjective'
  when 4
    'adverb'
  end

  # one big string
  key = part_of_speech + '_' + synset_offset + '_' + lemma
  @sense_index[key.to_s] = tag_cnt.to_i
end

puts "#{Time.now} loaded sense index"
STDOUT.flush

failure_count = 0

@max_synset_id = 117659 # Synset.order('id desc').limit(1).first.id
puts "Max Synset ID is #{@max_synset_id}"

to_delete = []
(1..@max_synset_id).each do |synset_id|
  to_delete << synset_id
  # puts "Added #{synset_id}"
end

puts "to_delete initialized with #{to_delete.count} members"

@total_synset_count = 0
@new_sense_count = 0
@new_synset_count = 0
@new_word_count = 0
@updated_synset_count = 0

@new_inflections_required = []

# Make this a migration?
# drop_table :senses_verb_frames
# create_table :senses_verb_frames do |t|
#   t.references :sense
#   t.references :verb_frame
# end
puts "#{Time.now} Clearing senses_verb_frames..."
STDOUT.flush
SensesVerbFrame.delete_all
puts "#{Time.now} Done clearing senses_verb_frames"
STDOUT.flush

puts "#{Time.now} Clearing pointers..."
STDOUT.flush
Pointer.delete_all
puts "#{Time.now} Done clearing pointers"
STDOUT.flush

%w{adj adv noun verb}.each do |sfx|
  @part_of_speech = case sfx
  when 'adj'
    'adjective'
  when 'adv'
    'adverb'
  else
    sfx
  end

  @irregular_inflections = {}
  File.open(File.expand_path("defaults/#{sfx}.exc", File.dirname(__FILE__))).each do |line|
    i, *_w = line.chomp.split

    _w.each do |w|
      @irregular_inflections[w.to_sym] ||= []
      inflections = @irregular_inflections[w.to_sym]

      inflections << i.gsub('_', ' ')
    end
  end
  puts "#{Time.now} loaded irregular #{@part_of_speech} inflections"
  STDOUT.flush

  puts "#{Time.now} loading #{@part_of_speech.pluralize}"
  STDOUT.flush
  synset_count = 0
  sense_count = 0
  @clean_so_far = true
  File.open(File.expand_path("defaults/data.#{sfx}", File.dirname(__FILE__))).each do |line|
    next if line =~ /^\s/

    synset = synset_for_data_line line

    # poor-person's assert(synset)
    nil.foo unless synset

    @total_synset_count += 1

    next if synset.id > @max_synset_id # new Synset

    if to_delete.include?(synset.id)
      # puts "FOUND #{synset.id}"
      to_delete.delete synset.id
    else
      puts "Duplicate synset ID #{synset.id}"
    end

  end
end

puts "Deleting #{to_delete.count} synsets: "
STDOUT.flush

to_delete.each do |synset_id|
  synset = Synset.find synset_id

  puts "DELETING #{synset_id}: <#{synset.lexname}> \"#{synset.definition}\" (#{synset.words.map(&:name).join(",")})"
  STDOUT.flush

  synset.destroy
end

puts "##### Started with #{@max_synset_id} synsets. Loaded #{@total_synset_count}. After clean-up, #{Synset.count} remain"

puts "Deleting #{Word.empty.count} words: "
STDOUT.flush

Word.empty.each do |word|
  puts "DELETING #{word.id}: #{word.name_and_pos}"
  STDOUT.flush

  word.destroy
end

puts "#{@new_inflections_required.count} new inflections required:"
@new_inflections_required.each do |word|
  puts " #{word.name_and_pos}"
end

puts "#{@updated_synset_count} existing synsets updated"
puts "#{@new_synset_count} new synsets created"
puts "#{@new_word_count} new words created"
puts "#{@new_sense_count} new senses created"

# Here on out is straight out of seeds.rb. The IDS in the senses_verb_frames and
# pointers tables are never exposed, so there's no need to be concerned about keeping
# their REST IDS constant like the words, senses and synsets tables. So we just reseed
# the pointers table here.
%w{adj adv noun verb}.each do |sfx|
  part_of_speech = case sfx
  when 'adj'
    'adjective'
  when 'adv'
    'adverb'
  else
    sfx
  end

  puts "#{Time.now} loading #{part_of_speech} pointers"
  STDOUT.flush
  File.open(File.expand_path("defaults/data.#{sfx}", File.dirname(__FILE__))).each do |line|
    next if line =~ /^\s/

    left, defn = line.split('| ')
    synset_offset, lex_filenum, ss_type, w_cnt, *rest = left.split(' ')

    synset = Synset.find_by_offset_and_part_of_speech synset_offset.to_i,
      part_of_speech

    w_cnt = w_cnt.to_i(16)
    p_cnt, *more = rest.slice(2*w_cnt, rest.length-2*w_cnt)
    next unless more

    p_cnt = p_cnt.to_i
    more.slice(0, 4*p_cnt).each_slice(4) do |p|
      pointer_symbol, target_synset_offset, target_pos, source_target = p

      target_synset =
        Synset.find_by_offset_and_part_of_speech target_synset_offset.to_i,
        case target_pos
        when 'n'
          'noun'
        when /^[as]$/
          'adjective'
        when 'r'
          'adverb'
        when 'v'
          'verb'
        end

      if source_target == '0000'
        ptype = pointer_type(pointer_symbol)
        Pointer.create_new :source => synset, :target => target_synset,
            :ptype => ptype

        rtype = reflected_pointer_type(pointer_symbol)
        Pointer.create_new :source => target_synset, :target => synset,
          :ptype => rtype
      else
        source_no = source_target[0,2]
        target_no = source_target[2,2]
        source_no = source_no.to_i(16)
        target_no = target_no.to_i(16)

        sense = synset.senses.where(synset_index: source_no).first
        target = target_synset.senses.where(synset_index: target_no).first

        Pointer.create_new :source => sense, :target => target, :ptype => pointer_type(pointer_symbol)
        rtype = reflected_pointer_type(pointer_symbol)
        Pointer.create_new(:source => target, :target => sense, :ptype => rtype) unless rtype.blank?
      end
    end
  end
end

puts "#{Time.now} finished"
