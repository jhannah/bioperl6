use v6;

use lib './lib';

use Test;

use Bio::Tools::FTLocationParser;

my %testcases = 
   # note: the following are directly taken from
   # http://www.ncbi.nlm.nih.gov/collab/FT/#location
    "467" => [0,
        467, 467, "EXACT", 467, 467, "EXACT", "EXACT", 0, 1, Nil],
    "340..565" => [0,
         340, 340, "EXACT", 565, 565, "EXACT", "EXACT", 0, 1, Nil],
    "<345..500" => [0,
         Nil, 345, "BEFORE", 500, 500, "EXACT", "EXACT", 0, 1, Nil],
    "<1..888" => [0,
         Nil, 1, "BEFORE", 888, 888, "EXACT", "EXACT", 0, 1, Nil],
    
    "(102.110)" => [0,
         102, 102, "EXACT", 110, 110, "EXACT", "WITHIN", 0, 1, Nil],
    "(23.45)..600" => [0,
         23, 45, "WITHIN", 600, 600, "EXACT", "EXACT", 0, 1, Nil],
    "(122.133)..(204.221)" => [0,
         122, 133, "WITHIN", 204, 221, "WITHIN", "EXACT", 0, 1, Nil],
    "123^124" => [0,
         123, 123, "EXACT", 124, 124, "EXACT", "IN-BETWEEN", 0, 1, Nil],
    "145^146" => [0,
         145, 145, "EXACT", 146, 146, "EXACT", "IN-BETWEEN", 0, 1, Nil],
    "J00194:100..202" => [0,
         100, 100, "EXACT", 202, 202, "EXACT", "EXACT", 0, 1, 'J00194'],

    # these variants are not really allowed by the FT definition
    # document but we want to be able to cope with it

    # Not supported!!!
    #"J00194:(100..202)" => ['J00194:100..202',
    #     100, 100, "EXACT", 202, 202, "EXACT", "EXACT", 0, 1, 'J00194'],
    #"((122.133)..(204.221))" => ['(122.133)..(204.221)',
    #     122, 133, "WITHIN", 204, 221, "WITHIN", "EXACT", 0, 1, Nil],

    # UNCERTAIN locations and positions (Swissprot)
    "?2465..2774" => [0,
        2465, 2465, "UNCERTAIN", 2774, 2774, "EXACT", "EXACT", 0, 1, Nil],
    "22..?64" => [0,
        22, 22, "EXACT", 64, 64, "UNCERTAIN", "EXACT", 0, 1, Nil],
    "?22..?64" => [0,
        22, 22, "UNCERTAIN", 64, 64, "UNCERTAIN", "EXACT", 0, 1, Nil],
    "?..>393" => [0,
        Nil, Nil, "UNCERTAIN", 393, Nil, "AFTER", "EXACT", 0, 1, Nil],
    "<1..?" => [0,
        Nil, 1, "BEFORE", Nil, Nil, "UNCERTAIN", "EXACT", 0, 1, Nil],
    "?..536" => [0,
        Nil, Nil, "UNCERTAIN", 536, 536, "EXACT", "EXACT", 0, 1, Nil],
    "1..?" => [0,
        1, 1, "EXACT", Nil, Nil, "UNCERTAIN", "EXACT", 0, 1, Nil],
    "?..?" => [0,
        Nil, Nil, "UNCERTAIN", Nil, Nil, "UNCERTAIN", "EXACT", 0, 1, Nil],
    "1..?12" => [0,
        1, 1, "EXACT", 12, 12, "UNCERTAIN", "EXACT", 0, 1, Nil],
    # Not sure if this is legal...
    "?" => [0,
        Nil, Nil, "UNCERTAIN", Nil, Nil, "EXACT", "EXACT", 0, 1, Nil],

    # Split locations (now collections of locations)

    # this isn't a legal split location string AFAIK (can't have two remote
    # locations), though it is handled. In this case the parent location can't
    # be used in any location-based analyses (has no start, end, etc.)
    
    "join(AY016290.1:108..185,AY016291.1:1546..1599)"=> [0,
        Nil, Nil, "EXACT", Nil, Nil, "EXACT", "JOIN", 2, 0, Nil],
    "complement(join(3207..4831,5834..5902,8881..8969,9276..9403,29535..29764))",
        [0, 3207, 3207, "EXACT", 29764, 29764, "EXACT", "JOIN", 5, -1, Nil],
    "join(complement(29535..29764),complement(9276..9403),complement(8881..8969),complement(5834..5902),complement(3207..4831))",
        ["complement(join(3207..4831,5834..5902,8881..8969,9276..9403,29535..29764))",
        3207, 3207, "EXACT", 29764, 29764, "EXACT", "JOIN", 5, -1, Nil],
    "join(12..78,134..202)" => [0,
        12, 12, "EXACT", 202, 202, "EXACT", "JOIN", 2, 1, Nil],
    "join(<12..78,134..202)" => [0,
        Nil, 12, "BEFORE", 202, 202, "EXACT", "JOIN", 2, 1, Nil],
    "complement(join(2691..4571,4918..5163))" => [0,
        2691, 2691, "EXACT", 5163, 5163, "EXACT", "JOIN", 2, -1, Nil],
    "complement(join(4918..5163,2691..4571))" => [0,
        2691, 2691, "EXACT", 5163, 5163, "EXACT", "JOIN", 2, -1, Nil],
    "join(complement(4918..5163),complement(2691..4571))" => [
        'complement(join(2691..4571,4918..5163))',
        2691, 2691, "EXACT", 5163, 5163, "EXACT", "JOIN", 2, -1, Nil],
    "join(complement(2691..4571),complement(4918..5163))" => [
        'complement(join(4918..5163,2691..4571))',
        2691, 2691, "EXACT", 5163, 5163, "EXACT", "JOIN", 2, -1, Nil],
    "complement(34..(122.126))" => [0,
        34, 34, "EXACT", 122, 126, "WITHIN", "EXACT", 0, -1, Nil],

    # complex, technically not legal FT types but we handle and resolve these as needed

    'join(11025..11049,join(complement(239890..240081),complement(241499..241580),complement(251354..251412),complement(315036..315294)))'
        => ['join(11025..11049,complement(join(315036..315294,251354..251412,241499..241580,239890..240081)))',
            11025,11025, 'EXACT', 315294, 315294, 'EXACT', 'JOIN', 2, 0, Nil],
    'join(11025..11049,complement(join(315036..315294,251354..251412,241499..241580,239890..240081)))'
        => [0, 11025,11025, 'EXACT', 315294, 315294, 'EXACT', 'JOIN', 2, 0, Nil],
    'join(20464..20694,21548..22763,complement(join(314652..314672,232596..232990,231520..231669)))'
        => [0, 20464,20464, 'EXACT', 314672, 314672, 'EXACT', 'JOIN', 3, 0, Nil],
    'join(20464..20694,21548..22763,join(complement(231520..231669),complement(232596..232990),complement(314652..314672)))'
        => ['join(20464..20694,21548..22763,complement(join(314652..314672,232596..232990,231520..231669)))',
            20464,20464, 'EXACT', 314672, 314672, 'EXACT', 'JOIN', 3, 0, Nil],
    
    'join(1000..2000,join(3000..4000,join(5000..6000,7000..8000)),9000..10000)'
        => [0, 1000,1000,'EXACT', 10000, 10000, 'EXACT', 'JOIN', 3, 1, Nil],
    
    # not passing completely yet, working out 'order' semantics
    'order(S67862.1:72..75,1..788,S67864.1:1..19)'
        => [0,  Nil, Nil, 'EXACT', Nil, Nil, 'EXACT', 'ORDER', 3, 0, Nil],
        
    # WGS contig-based 'locations'
    'join(GL002586.1:1..34478191,gap(100000),GL002587.1:1..43354415)'
        => [0,  Nil, Nil, 'EXACT', Nil, Nil, 'EXACT', 'ORDER', 3, 0, Nil],
        
    # really put it through the ringer. Contig assembly file GG704824.1, lots of
    # gaps w/ different contigs
    'join(ACZS01000113.1:1..31090,gap(50),ACZS01000114.1:1..32367,gap(300),ACZS01000115.1:1..23926,gap(50),' ~
    'ACZS01000116.1:1..37939,gap(50),ACZS01000117.1:1..2415,gap(498),ACZS01000118.1:1..90824,gap(249),' ~
    'ACZS01000119.1:1..20094,gap(1288),ACZS01000120.1:1..7526,gap(50),ACZS01000121.1:1..8396,gap(916),' ~
    'ACZS01000122.1:1..4711,gap(50),ACZS01000123.1:1..7610,gap(50),ACZS01000124.1:1..13068,gap(471),' ~
    'ACZS01000125.1:1..2062,gap(274),ACZS01000126.1:1..36253,gap(50),ACZS01000127.1:1..17718,gap(50),' ~
    'ACZS01000128.1:1..56336,gap(355),ACZS01000129.1:1..14298,gap(328),ACZS01000130.1:1..16632,gap(360),' ~
    'ACZS01000131.1:1..29485,gap(1163),ACZS01000132.1:1..61637,gap(50),ACZS01000133.1:1..2189,gap(415),' ~
    'ACZS01000134.1:1..2638,gap(268),ACZS01000135.1:1..3234,gap(399),ACZS01000136.1:1..36276,gap(50),' ~
    'ACZS01000137.1:1..37251,gap(320),ACZS01000138.1:1..23265,gap(226),ACZS01000139.1:1..1945,gap(330),' ~
    'ACZS01000140.1:1..3783,gap(165),ACZS01000141.1:1..41750,gap(226),ACZS01000142.1:1..3866,gap(220),' ~
    'ACZS01000143.1:1..8883,gap(161),ACZS01000144.1:1..4681,gap(50),ACZS01000145.1:1..23948,gap(228),' ~
    'ACZS01000146.1:1..2990,gap(388),ACZS01000147.1:1..9633,gap(259),ACZS01000148.1:1..9932,gap(261),' ~
    'ACZS01000149.1:1..1565,gap(1288),ACZS01000150.1:1..60690,gap(425),ACZS01000151.1:1..65167,gap(50),' ~
    'ACZS01000152.1:1..46726,gap(50),ACZS01000153.1:1..18917,gap(510),ACZS01000154.1:1..22264,gap(50),' ~
    'ACZS01000155.1:1..37797,gap(729),ACZS01000156.1:1..9564,gap(569),ACZS01000157.1:1..2030,gap(362),' ~
    'ACZS01000158.1:1..5937,gap(287),ACZS01000159.1:1..28478,gap(267),ACZS01000160.1:1..12114,gap(218),' ~
    'ACZS01000161.1:1..26732,gap(616),ACZS01000162.1:1..11090,gap(330),ACZS01000163.1:1..26447,gap(224),' ~
    'ACZS01000164.1:1..2114,gap(225),ACZS01000165.1:1..75967,gap(96),ACZS01000166.1:1..67895,gap(1838),' ~
    'ACZS01000167.1:1..10047,gap(634),ACZS01000168.1:1..28315,gap(50),ACZS01000169.1:1..25678,gap(309),' ~
    'ACZS01000170.1:1..2746,gap(439),ACZS01000171.1:1..13328,gap(2838),ACZS01000172.1:1..567,gap(627),' ~
    'ACZS01000173.1:1..1451,gap(544),ACZS01000174.1:1..2654,gap(572),ACZS01000175.1:1..1758,gap(1463),' ~
    'ACZS01000176.1:1..1978,gap(613),ACZS01000177.1:1..8076,gap(1120),ACZS01000178.1:1..5510,gap(275),' ~
    'ACZS01000179.1:1..3481,gap(159),ACZS01000180.1:1..35889,gap(50),ACZS01000181.1:1..27693,gap(50),' ~
    'ACZS01000182.1:1..21337,gap(261),ACZS01000183.1:1..9546,gap(324),ACZS01000184.1:1..16424,gap(158),' ~
    'ACZS01000185.1:1..44270,gap(1288),ACZS01000186.1:1..12351,gap(143),ACZS01000187.1:1..3169,gap(50),' ~
    'ACZS01000188.1:1..13970)'
        => [0,  Nil, Nil, 'EXACT', Nil, Nil, 'EXACT', 'ORDER', 3, 0, Nil],
;

my $p = Bio::Tools::FTLocationParser.new();

ok($p ~~ Bio::Tools::FTLocationParser);

# sorting is to keep the order constant from one run to the next
for %testcases.keys -> $locstr {    
    
    Bio::Grammar::Location.parse($locstr);
    
    ok($/.defined, $locstr);
}

done();
