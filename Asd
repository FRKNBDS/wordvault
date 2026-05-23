import { supabase } from './supabaseClient';
import { useState, useEffect, useCallback, useRef } from "react";

// ── WORD DATA — GitHub'dan çekilir, fallback olarak gömülü veri kullanılır ───
// GITHUB_RAW_URL: Bu satırı repo oluşturduktan sonra güncelleyin
const GITHUB_DATA_URL = "https://raw.githubusercontent.com/FRKNBDS/wordvault/main/words.json";

async function fetchWordData() {
  try {
    const res = await fetch(GITHUB_DATA_URL + "?t=" + Date.now());
    if (!res.ok) throw new Error("HTTP " + res.status);
    const data = await res.json();
    window.__WV_WORD_DATA__ = data;
    console.log("✅ Kelime verisi GitHub'dan yüklendi");
    return data;
  } catch (e) {
    console.warn("⚠️ GitHub'dan yüklenemedi, gömülü veri kullanılıyor:", e.message);
    return window.__WV_WORD_DATA__ || null;
  }
}

// ── FALLBACK: Gömülü kelime verisi (GitHub erişilemezse kullanılır) ────────────
if (typeof window !== "undefined") {
  window.__WV_WORD_DATA__ = {"VERB_SET_1": [["live", "yaşamak", "Many indigenous tribes still live in harmony with nature in the remote areas of the Amazon.", "Birçok yerli kabile, Amazon'un uzak bölgelerinde hala doğayla uyum içinde yaşamaktadır.", "Canlı yayınlarda sağ üstte çıkan 'LIVE' ibaresi, o an yaşanan anı aktarır."], ["reside", "ikamet etmek, yaşamak", "The right to reside in the European Union is granted to individuals who meet specific legal criteria.", "Avrupa Birliği'nde ikamet etme hakkı, belirli yasal kriterleri karşılayan bireylere tanınır.", "Rezidans (Residence) - Zenginlerin 'ikamet ettiği', yaşadığı lüks binalar."], ["inhabit", "bir yerde yaşamak, yerleşmek", "Rare species of birds inhabit the dense forests of Madagascar, making the island a biodiversity hotspot.", "Nadir kuş türleri Madagaskar'ın yoğun ormanlarında yaşar ve bu da adayı biyolojik çeşitlilik merkezi haline getirir.", "Habitat - Canlıların doğal olarak 'yaşadığı', yerleştiği yaşam alanı."], ["occupy", "işgal etmek, yer kaplamak, meşgul etmek", "The new administrative offices will occupy the top three floors of the skyscraper.", "Yeni idari ofisler, gökdelenin en üst üç katını kaplayacak (işgal edecek).", "Okul (Occu-py) - Okul sıraları sınıfta çok büyük bir 'yer kaplar'."], ["populate", "yerleşmek, nüfus oluşturmak", "Early humans began to populate different continents due to shifting climatic conditions.", "İlk insanlar, değişen iklim koşulları nedeniyle farklı kıtalara yerleşmeye başladılar.", "Population (Nüfus) - Bir bölgeye yerleşerek oranın 'nüfusunu oluşturmak'."], ["settle", "yerleşmek, çözmek/karara bağlamak", "After years of traveling, the family decided to settle in a quiet coastal town.", "Yıllarca seyahat ettikten sonra aile, sakin bir kıyı kasabasına yerleşmeye karar verdi.", "Set (Kurmak) - Düzenini kurup bir yere kalıcı olarak 'yerleşmek'."], ["undergo", "başından geçmek, maruz kalmak, ameliyat/değişim geçirmek", "The historical building will undergo extensive restoration to preserve its original architecture.", "Tarihi bina, orijinal mimarisini korumak için kapsamlı bir restorasyondan geçecek.", "Under (Altına) + Go (Gitmek) - Bir sürecin altına girmek, o süreci 'deneyimlemek/geçirmek'."], ["experience", "deneyimlemek, tecrübe etmek, başından geçmek", "Developing nations often experience rapid economic fluctuations during financial crises.", "Gelişmekte olan ülkeler, finansal krizler sırasında genellikle hızlı ekonomik dalgalanmalar yaşarlar.", "Eksper (Exper-ience) - Arabanın başından ne geçtiğini bilen 'deneyimli/tecrübeli' kişi."], ["go through", "yaşamak, geçirmek, içinden geçmek", "The patients had to go through a rigorous screening process before the clinical trial.", "Hastalar, klinik araştırmadan önce zorlu bir tarama sürecinden geçmek zorunda kaldı.", "Go (Gitmek) + Through (İçinden) - Zorlu bir tünelin içinden gitmek, o zorluğu 'yaşamak'."], ["be faced with", "ile karşı karşıya kalmak", "The committee was faced with a difficult decision regarding the budget cuts.", "Komite, bütçe kesintileriyle ilgili zor bir kararla karşı karşıya kaldı.", "Face (Yüz) - Bir problemle 'yüz yüze' gelmek, karşı karşıya kalmak."], ["be exposed to", "maruz kalmak", "Workers who are exposed to high levels of radiation must wear protective gear.", "Yüksek düzeyde radyasyona maruz kalan işçiler koruyucu giysi giymelidir.", "Poz (Ex-posed) - Kameranın ışığına doğrudan 'maruz kalan' fotoğraf pozu."], ["put up with", "katlanmak, tahammül etmek", "Residents have to put up with the constant noise from the nearby highway construction.", "Sakinler, yakındaki otoyol inşaatından gelen sürekli gürültüye katlanmak zorunda.", "Put (Koymak) + Up (Yukarı) - Yükü yukarı kaldırıp 'tahammül ederek' taşımak."], ["bear", "katlanmak, üstlenmek, (meyve) vermek", "The company had to bear the financial losses resulting from the failed product launch.", "Şirket, başarısız ürün lansmanından kaynaklanan finansal kayıplara katlanmak zorunda kaldı.", "Bear (Ayı) - Kış uykusundaki bir ayının açlığa ve soğuğa 'katlanması'."], ["stand", "katlanmak, dayanmak, ayakta durmak", "I cannot stand the pressure of working under such chaotic conditions anymore.", "Artık böyle kaotik koşullar altında çalışmanın baskısına katlanamıyorum.", "Stand (Ayakta kalmak) - Ayakta dimdik durarak zorluklara 'direnmek/dayanmak'."], ["withstand", "dayanmak, karşı koymak, direnmek", "The modern bridge was engineered to withstand powerful earthquakes and high winds.", "Modern köprü, güçlü depremlere ve şiddetli rüzgarlara dayanacak şekilde tasarlandı.", "With (Karşı) + Stand (Durmak) - Bir güce karşı durmak, zarar görmeden 'direnmek'."], ["tolerate", "tolere etmek, katlanmak, müsamaha göstermek", "The university does not tolerate any form of academic dishonesty or plagiarism.", "Üniversite, akademik sahtekarlığın veya intihalin hiçbir türüne müsamaha göstermez.", "Tolerans (Tolerance) - Karşı tarafa tolerans göstermek, onun hatasına 'katlanmak'."], ["endure", "dayanmak, katlanmak, sürmek", "The political prisoners had to endure harsh conditions during their long captivity.", "Siyasi mahkumlar, uzun esaretleri boyunca ağır koşullara katlanmak zorunda kaldılar.", "Dayanıklılık (Endurance) - Maraton koşucularının sahip olduğu 'dayanma' gücü."], ["survive", "hayatta kalmak, sağ kalmak", "Only a few ancient manuscripts managed to survive the destructive fire in the library.", "Kütüphanedeki yıkıcı yangından sadece birkaç antik el yazması hayatta kalmayı başardı.", "Survivor - Yarışmadaki gibi zor şartlarda 'hayatta kalma' mücadelesi vermek."], ["start (off)", "başlamak, başlatmak", "The festival will start off with a spectacular parade through the city center.", "Festival, şehir merkezinden geçecek muhteşem bir geçit töreniyle başlayacak.", "Start - Yarışlardaki 'start' çizgisinden, yani 'başlangıç' noktasından hatırlanabilir."], ["begin", "başlamak", "The judicial proceedings will begin as soon as the defense files the necessary documents.", "Savunma gerekli belgeleri sunar sunmaz adli süreç başlayacak.", ""], ["initiate", "başlatmak, önayak olmak", "The government decided to initiate a new program to upgrade public infrastructure.", "Hükümet, kamu altyapısını geliştirmek için yeni bir program başlatmaya karar verdi.", "Initial (İlk/Baş harf) - Bir işin 'ilk' adımını atmak, süreci 'başlatmak'."], ["launch", "başlatmak, (roket) fırlatmak, (ürün) piyasaya sürmek", "The tech firm plans to launch its new artificial intelligence software next month.", "Teknoloji firması, yeni yapay zeka yazılımını önümüzdeki ay piyasaya sürmeyi (başlatmayı) planlıyor.", "Lansman - Yeni üretilen bir arabanın piyasaya sürülme, 'başlatılma' gecesi."], ["introduce", "tanıtmak, piyasaya sürmek, ilk kez getirmek", "The school board wants to introduce modern coding classes to the primary curriculum.", "Okul aile birliği, ilkokul müfredatına modern kodlama dersleri getirmek (tanıtmak) istiyor.", "Introduction (Giriş) - Kitapların 'giriş' kısmında konunun 'tanıtılması'."], ["take up", "yapmaya başlamak (hobi/meslek), yer/zaman kaplamak", "He decided to take up photography as a hobby after his retirement from the bank.", "Bankadan emekli olduktan sonra hobi olarak fotoğrafçılığa başlamaya karar verdi.", "Take (Almak) + Up (Yukarı) - Hobiyi yukarı kaldırıp hayatının içine almak, 'başlamak'."], ["break out", "aniden başlamak/patlak vermek (savaş/yangın), kaçmak", "Fears grew that a civil war might break out due to the political instability.", "Siyasi istikrarsızlık nedeniyle bir iç savaşın patlak verebileceği endişeleri arttı.", "Prison Break - Hapishaneden 'kaçmak' veya bir krizin zincirlerini kırıp 'patlak vermesi'."], ["originate from", "-den kaynaklanmak, -den doğmak", "Many words in the English language originate from Latin and ancient Greek roots.", "İngiliz dilindeki birçok kelime, Latince ve antik Yunanca kökenlerden kaynaklanmaktadır.", "Orijinal (Original) - Bir şeyin orijinal yeri, çıktığı, 'kaynaklandığı' nokta."], ["derive from", "-den türemek, -den kaynaklanmak", "The scientist explained how the new compound is derived from natural plant extracts.", "Bilim insanı, yeni bileşiğin doğal bitki özlerinden nasıl türetildiğini açıkladı.", "Derive (Türev) - Matematikteki 'türev' gibi, bir kökten başka bir şey 'türetmek'."], ["come from", "-den gelmek", "Most of the funding for this environmental research comes from private donations.", "Bu çevre araştırması için finansmanın büyük kısmı özel bağışlardan gelmektedir.", ""], ["result from", "-den kaynaklanmak, -den ileri gelmek", "The flooding in the coastal city resulted from a unique combination of high tides and heavy rain.", "Kıyı kentindeki sel, yüksek gelgit ve şiddetli yağmurun eşsiz birleşiminden kaynaklandı.", "Result (Sonuç) - Bir sebebin 'sonucu olarak' ortaya çıkmak."], ["stem from", "-den kaynaklanmak, -den gelmek", "Her deep-seated fear of flying stems from a turbulent flight she experienced as a child.", "Onun köklü uçuş korkusu, çocukken yaşadığı türbülanslı bir uçuştan kaynaklanmaktadır.", "Stem (Kök/Gövde) - Ağacın gövdesinden, yani 'kökünden kaynaklanmak'."], ["argue", "tartışmak, ileri sürmek", "Some economists argue that reducing taxes is the best way to stimulate market spending.", "Bazı ekonomistler, vergileri düşürmenin piyasa harcamalarını canlandırmanın en iyi yolu olduğunu ileri sürüyor.", "Argu (Argüman) - Tartışmalarda haklı çıkmak için öne sürülen 'argüman'."], ["dispute", "tartışmak, itiraz etmek, anlaşmazlığa düşmek", "The two neighboring countries dispute the exact location of their maritime border.", "İki komşu ülke, deniz sınırlarının tam yeri konusunda anlaşmazlığa düşüyor.", "Dis-put (Ters koymak) - Karşı tarafın fikrini tersine koyup onunla 'tartışmak'."], ["quarrel", "tartışmak, kavga etmek, atışmak", "The siblings used to quarrel constantly over who would inherit the family estate.", "Kardeşler, aile mülkünün kime kalacağı konusunda sürekli tartışırlardı.", "Kural (Quar-rel) - Kurallara uymayan insanlar arasında çıkan ağız 'kavgası'."], ["negotiate", "müzakere etmek, görüşmek", "The labor union met with the management to negotiate better working hours for the staff.", "İşçi sendikası, personel için daha iyi çalışma saatleri müzakere etmek üzere yönetimle bir araya geldi.", "Nego (Negosyo/Ticaret) - Ticaret masasında şartları karşılıklı 'müzakere etmek'."], ["discuss", "tartışmak, görüşmek, fikir alışverişinde bulunmak", "The board of directors will gather tomorrow to discuss the new international investment plan.", "Yönetim kurulu, yeni uluslararası yatırım planını görüşmek üzere yarın toplanacak.", "Discussion - Forumlarda açılan 'tartışma/görüşme' başlıkları."], ["debate", "tartışmak (özellikle resmi/akademik ortamda)", "Politicians gathered on television to debate the social impacts of the new educational reform.", "Politikacılar, yeni eğitim reformunun sosyal etkilerini tartışmak üzere televizyonda toplandılar.", "Münazara (Debate) - İki grubun bir konuyu resmi olarak 'tartışması'."], ["exchange ideas", "fikir alışverişinde bulunmak", "The international summit provided an excellent platform for scientists to exchange ideas.", "Uluslararası zirve, bilim insanlarının fikir alışverişinde bulunmaları için mükemmel bir platform sağladı.", "Exchange (Döviz/Takas) + Ideas (Fikirler) = Karşılıklı fikir takası yapmak."], ["bargain*", "pazarlık etmek, anlaşmak", "In local markets, it is common practice to bargain with vendors to get a lower price.", "Yerel pazarlarda, daha düşük bir fiyat almak için satıcılarla pazarlık etmek yaygın bir uygulamadır.", "Barkod (Bar-gain) - Barkodu olmayan eski usul ürünlerde 'pazarlık etmek'."], ["offer", "önermek, teklif etmek, sunmak", "The university decided to offer a new online degree program in data science.", "Üniversite, veri bilimi alanında yeni bir online lisans programı sunmaya karar verdi.", "Ofis (Offer) - Ofiste müşteriye yeni bir iş sözleşmesi 'teklif etmek'."], ["propose", "önermek, teklif etmek (evlilik/proje)", "The research team will propose a novel solution to reduce toxic waste at the conference.", "Araştırma ekibi, konferansta toksik atıkları azaltmak için yeni bir çözüm önerecek.", "Proposal - Evlilik teklifi (Marriage proposal) veya bir projeyi 'önermek'."], ["suggest", "önermek, tavsiye etmek, belirtmek", "Recent studies suggest that global warming is accelerating faster than previously expected.", "Son çalışmalar, küresel ısınmanın önceden beklenenden daha hızlı ivme kazandığını göstermektedir (belirtmektedir).", "Sünger (Sug-gest) - Temizlik için sünger kullanmayı 'önermek'."], ["recommend", "tavsiye etmek, önermek", "Doctors highly recommend taking a brief walk every day to improve cardiovascular health.", "Doktorlar, kalp ve damar sağlığını iyileştirmek için her gün kısa bir yürüyüş yapmayı önemle tavsiye ediyor.", "Yorumlar (Re-commend) - Alışveriş sitelerinde ürünün altındaki 'tavsiye' yorumları."], ["advise", "tavsiye vermek, öğütlemek", "Financial experts advise investors to diversify their portfolios to avoid catastrophic losses.", "Finans uzmanları, büyük kayıplardan kaçınmak için yatırımcılara portföylerini çeşitlendirmelerini tavsiye ediyor.", "Advisor - Şirketlerde stratejik yön gösteren danışman, 'tavsiye veren' kişi."], ["come up with", "(fikir/çözüm) bulmak, ileri sürmek, üretmek", "The marketing department needs to come up with a brilliant strategy for the product launch.", "Pazarlama departmanının, ürün lansmanı için zekice bir strateji bulması gerekiyor.", "Come (Gelmek) + Up (Yukarı) - Kafada aniden yukarı fırlayan, 'bulunan' parlak fikir."], ["show", "göstermek", "The official graphs show a clear correlation between education levels and income stability.", "Resmi grafikler, eğitim düzeyleri ile gelir istikrarı arasında net bir ilişki göstermektedir.", "Şov (Show) - Sahnede yapılan, insanların izlemesi için 'gösterilen' etkinlik."], ["indicate", "göstermek, işaret etmek, belirtmek", "A sudden drop in atmospheric pressure can indicate an approaching storm.", "Atmosfer basıncındaki ani bir düşüş, yaklaşan bir fırtınayı işaret edebilir (gösterebilir).", "İndikatör - Kimyada veya borsada yönü 'gösteren' teknik gösterge."], ["reveal", "ortaya çıkarmak, ifşa etmek, göstermek", "The archaeological excavation revealed a magnificent ancient palace hidden underground.", "Arkeolojik kazı, yer altında gizlenmiş muhteşem bir antik sarayı ortaya çıkardı.", "Rövaşata (Re-veal) - Futbolda rövaşata atarak gerçek yeteneğini 'ortaya çıkarmak'."], ["demonstrate", "göstermek, kanıtlamak, gösteri yapmak", "The laboratory experiment was designed to demonstrate the laws of thermodynamics.", "Laboratuvar deneyi, termodinamik yasalarını göstermek (kanıtlamak) için tasarlandı.", "Demonstrasyon - Bir ürünün nasıl çalıştığını uygulamalı olarak 'göstermek'."], ["suggest (that)", "ileri sürmek, göstermek, işaret etmek", "The initial data suggest that the new vaccine provides long-term protection against the virus.", "İlk veriler, yeni aşının virüse karşı uzun vadeli koruma sağladığını göstermektedir.", "Sünger (Sug-gest) - Delillerin suyu çekmesi gibi, gerçeği 'işaret etmek'."], ["signify", "anlamına gelmek, ifade etmek, göstermek", "The dark clouds on the horizon signify a dramatic change in the local weather pattern.", "Ufuktaki kara bulutlar, yerel hava durumunda ciddi bir değişikliği ifade eder (gösterir).", "Significant (Önemli) - Önemli bir anlam 'ifade etmek', bir manaya gelmek."], ["present", "sunmak, göstermek, takdim etmek", "The research team will present their final findings to the international committee tomorrow.", "Araştırma ekibi, nihai bulgularını yarın uluslararası komiteye sunacak.", "Prezantasyon (Presentation) - Sahnede slaytlarla yapılan proje 'sunumu'."], ["think", "düşünmek", "Many historians think that ancient civilizations had advanced knowledge of astronomy.", "Birçok tarihçi, antik medeniyetlerin astronomi konusunda gelişmiş bilgilere sahip olduğunu düşünüyor.", ""], ["feel", "hissetmek, düşünmek/öyle gelmek", "The managers feel that the current strategy is inadequate to survive the market crash.", "Yöneticiler, mevcut stratejinin piyasa çöküşünden sağ çıkmak için yetersiz olduğunu düşünüyorlar (hissediyorlar).", ""], ["ponder", "üzerinde derin derin düşünmek, kafa yormak", "The philosopher spent his entire life pondering the true meaning of human existence.", "Filozof, tüm hayatını insan varoluşunun gerçek anlamı üzerinde derin derin düşünerek geçirdi.", "Pano (Pon-der) - Panodaki karmaşık formüllere bakıp 'derin derin düşünmek'."], ["consider", "düşünmek, göz önünde bulundurmak, saymak/kabul etmek", "We must consider all alternative energy sources before making a permanent investment.", "Kalıcı bir yatırım yapmadan önce tüm alternatif enerji kaynaklarını göz önünde bulundurmalıyız.", "Konsantre (Con-sider) - Bir konuya konsantre olup onu 'enine boyuna düşünmek'."], ["regard", "olarak görmek/kabul etmek, saygı duymak", "Many critics regard the author's third novel as a true masterpiece of modern literature.", "Birçok eleştirmen, yazarın üçüncü romanını modern edebiyatın gerçek bir başyapıtı olarak görüyor.", "Regards - E-postaların sonuna yazılan 'saygılarımla' (Kind regards) ifadesinden."], ["view", "görmek, bakmak, değerlendirmek", "Sociologists view the rise of digital communities as a fundamental shift in human interaction.", "Sosyologlar, dijital toplulukların yükselişini insani etkileşimde temel bir değişim olarak görüyorlar.", "View (Manzara) - Güzel bir manzaraya 'bakmak', onu gözle 'görmek'."]], "VERB_SET_2": [["stop (from)", "durdurmak, engel olmak", "The new security measures are designed to stop unauthorized users from accessing the database.", "Yeni güvenlik önlemleri, yetkisiz kullanıcıların veri tabanına erişmesini engellemek (durdurmak) için tasarlanmıştır.", "Otobüs durağındaki 'STOP' tabelası trafiği ve arabaları 'durdurmak' içindir."], ["cease", "durmak, durdurmak, sona ermek", "The two factions agreed to cease all hostile actions during the peace negotiations.", "İki grup, barış müzakereleri sırasında tüm düşmanca eylemleri durdurma konusunda anlaştı.", "Ceasefire (Ateşkes) - Ateş etmeyi 'durdurmak', savaşa son vermek."], ["quit", "bırakmak, çıkmak, vazgeçmek", "He decided to quit his corporate job to pursue a full-time career in creative writing.", "Yaratıcı yazarlık alanında tam zamanlı bir kariyer sürdürmek için kurumsal işini bırakmaya karar verdi.", "Bilgisayar oyunlarından çıkarken veya programı kapatırken basılan 'QUIT' butonu."], ["halt", "durdurmak, kesilmek, duraklamak", "Production was temporarily halted due to a major technical failure in the main power supply.", "Ana güç kaynağındaki büyük bir teknik arıza nedeniyle üretime geçici olarak ara verildi (durduruldu).", "Askerlerin hazır ol durumunda 'Halt!' (Dur!) diye bağırması."], ["give up", "bırakmak, vazgeçmek, teslim olmak", "Despite facing numerous economic challenges, the entrepreneurs refused to give up on their project.", "Çok sayıda ekonomik zorlukla karşılaşmalarına rağmen, girişimciler projelerinden vazgeçmeyi reddettiler.", "Give (Vermek) + Up (Yukarı) - Ellerini yukarı kaldırıp mücadeleyi 'bırakmak', teslim olmak."], ["abandon", "terk etmek, bırakmak", "The crew had to abandon the sinking ship after the rescue boats arrived.", "Kurtarma botları geldikten sonra mürettebat batan gemiyi terk etmek zorunda kaldı.", "Abanmak (Aban-don) - Birinin üstüne çok abanınca seni 'terk edip gitmesi'."], ["terminate", "sonlandırmak, bitirmek", "The company reserves the right to terminate the contract if the terms are breached.", "Şirket, şartlar ihlal edilirse sözleşmeyi sonlandırma hakkını saklı tutar.", "Terminatör - Düşmanlarını tamamen yok edip onların hayatını 'sonlandıran' robot."], ["understand", "anlamak, kavramak", "To solve complex global issues, scientists must first understand the root causes of climate change.", "Karmaşık küresel sorunları çözmek için bilim insanları öncelikle iklim değişikliğinin temel nedenlerini anlamalıdır.", "Under (Altında) + Stand (Durmak) - Bir konunun altında durup onu iyice 'anlamak'."], ["comprehend", "anlamak, kavramak, idrak etmek", "The written text was so dense that it was difficult for the students to comprehend the main idea.", "Yazılı metin o kadar yoğundu ki öğrencilerin ana fikri kavraması zordu.", "Komple (Compre-hend) - Bir konuyu 'komple' beynine alıp 'idrak etmek'."], ["realize", "farkına varmak, gerçekleştirmek", "It took several months for the management to realize the full impact of the marketing campaign.", "Yönetimin pazarlama kampanyasının tüm etkisinin farkına varması birkaç ay sürdü.", "Real (Gerçek) - Bir şeyin 'gerçek' halini görüp aniden 'farkına varmak'."], ["recognize", "tanımak, fark etmek, (resmi olarak) kabul etmek", "The software is designed to recognize human faces even in low-light environments.", "Yazılım, düşük ışıklı ortamlarda bile insan yüzlerini tanımak üzere tasarlanmıştır.", "Cognitive (Bilişsel) - Re (Yeniden) + Cognize = Hafızadaki bir şeyi yeniden görüp 'tanımak'."], ["perceive", "algılamak, kavramak", "Animals can perceive environmental changes that are completely unnoticeable to humans.", "Hayvanlar, insanlar tarafından tamamen fark edilemeyen çevresel değişiklikleri algılayabilir.", "Perception (Algı) - Duyu organlarıyla yapılan 'algılama' işlemi."], ["learn", "öğrenmek, sonuç çıkarmak", "Children learn foreign languages much faster when they are exposed to them at an early age.", "Çocuklar erken yaşta maruz kaldıklarında yabancı dilleri çok daha hızlı öğrenirler.", ""], ["discover", "keşfetmek, ortaya çıkarmak", "Researchers discover new deep-sea species every time they explore the Mariana Trench.", "Araştırmacılar, Mariana Çukuru'nu her keşfettiklerinde yeni derin deniz türleri keşfederler.", "Dis (Kaldırmak) + Cover (Kapak) - Bir şeyin üstündeki kapağı kaldırıp onu 'keşfetmek'."], ["find out", "öğrenmek, bulmak, ortaya çıkarmak", "The investigation aimed to find out the truth behind the financial fraud.", "Soruşturma, finansal dolandırıcılığın arkasındaki gerçeği ortaya çıkarmayı (öğrenmeyi) amaçlıyordu.", "Find (Bulmak) + Out (Dışarı) - Gizli kalmış bir bilgiyi dışarı çıkarıp 'bulmak/öğrenmek'."], ["sort out*", "çözmek, halletmek, sınıflandırmak", "The IT department is working diligently to sort out the server issues affecting the website.", "Bilişim departmanı, web sitesini etkileyen sunucu sorunlarını çözmek için titizlikle çalışıyor.", "Sort (Sıralamak/Tür) - Sorunları türlerine göre ayırıp ortadan kaldırmak, 'halletmek'."], ["pick up*", "öğrenmek (zahmetsizce/kapmak), toplamak, (birini) arabayla almak", "Living abroad allows individuals to pick up the local language and cultural nuances quickly.", "Yurtdışında yaşamak, bireylerin yerel dili ve kültürel nüansları hızlıca kapmasını (öğrenmesini) sağlar.", "Pick (Seçmek/Almak) + Up (Yukarı) - Yerdeki bilgiyi yukarı kaldırıp havada 'kapmak/öğrenmek'."], ["figure out", "anlamak, çözmek, hesaplayıp bulmak", "Scientists are trying to figure out how the virus mutates so rapidly under laboratory conditions.", "Bilim insanları, virüsün laboratuvar koşullarında nasıl bu kadar hızlı mutasyona uğradığını çözmeye çalışıyor.", "Figür (Figure) - Karmaşık bir figürün/şifrenin ne anlama geldiğini 'çözmek'."], ["conclude", "sonucuna varmak, sonlandırmak", "Based on the gathering evidence, the jury will likely conclude that the suspect is guilty.", "Toplanan kanıtlara dayanarak, jüri muhtemelen şüphelinin suçlu olduğu sonucuna varacak.", "Conclusion (Sonuç) - Makalelerin en sonundaki 'sonuç/bağlam' bölümü."], ["emerge", "ortaya çıkmak, belirmek", "New economic powers began to emerge in Asia during the late twentieth century.", "Yirminci yüzyılın sonlarında Asya'da yeni ekonomik güçler ortaya çıkmaya başladı.", "E-merge (E-ticaret) - İnternetin hayatımıza girmesiyle yeni iş kollarının 'ortaya çıkması'."], ["arise", "ortaya çıkmak, baş göstermek (sorun/durum)", "Serious legal complications can arise if the contract is signed without legal review.", "Sözleşme yasal bir inceleme yapılmadan imzalanırsa, ciddi yasal karmaşıklıklar ortaya çıkabilir.", "Rise (Yükselmek) - Bir problemin dipten yukarı doğru yükselip 'baş göstermesi'."], ["originate", "başlamak, kaynaklanmak, ortaya çıkmak", "The custom of drinking tea is believed to originate from ancient China.", "Çay içme geleneğinin antik Çin'den kaynaklandığına (ortaya çıktığına) inanılmaktadır.", "Orijinal (Original) - Bir şeyin ilk üretildiği, ilk 'ortaya çıktığı' köken."], ["appear", "görünmek, ortaya çıkmak, belirmek", "Symptoms of the disease usually appear within two weeks of initial exposure.", "Hastalığın semptomları genellikle ilk maruziyetten sonraki iki hafta içinde görünür.", "Hopörler (Appear-ance) - Sahneye bir anda çıkıp 'görünen' sanatçı."], ["develop", "gelişmek, ortaya çıkmak, (hastalığa) yakalanmak", "The local tech industry continues to develop rapid software solutions for global markets.", "Yerel teknoloji sektörü, küresel piyasalar için hızlı yazılım çözümleri geliştirmeye devam ediyor.", "Developer (Yazılımcı) - Sürekli yeni projeler ve yazılımlar 'geliştiren' kişi."], ["show up", "çıkagelmek, ortaya çıkmak, görünmek", "Despite his previous promises, he did not show up for the strategic board meeting.", "Önceki sözlerine rağmen, stratejik yönetim kurulu toplantısına gelmedi (ortaya çıkmadı).", "Show (Gösteri) + Up (Yukarı) - Sahneye yukarı doğru çıkıp aniden 'görünmek'."], ["enable", "olanak sağlamak, imkan vermek", "The advancements in biotechnology enable doctors to treat previously incurable genetic conditions.", "Biyoteknolojideki gelişmeler, doktorların daha önce tedavi edilemeyen genetik hastalıkları tedavi etmesine olanak sağlıyor.", "Able (Yapabilmek) - En-able = Birine bir işi yapabilmesi için yetki/imkan 'sağlamak'."], ["empower", "yetkilendirmek, güçlendirmek, imkan vermek", "The educational foundation aims to empower young women through technical training programs.", "Eğitim vakfı, teknik eğitim programları aracılığıyla genç kadınları güçlendirmeyi amaçlıyor.", "Power (Güç) - Em-power = Birine güç vermek, onu 'yetkilendirmek'."], ["facilitate", "kolaylaştırmak", "The introduction of modern infrastructure will facilitate trade between the two provinces.", "Modern altyapının getirilmesi, iki il arasındaki ticareti kolaylaştıracaktır.", "Facile (Kolay) - Fransızca/Latince kökenli 'kolay' kelimesinden türemiş eylem."], ["make possible", "mümkün kılmak, olanak tanımak", "Satellite imagery has made possible the accurate mapping of remote rainforests.", "Uydu görüntüleri, uzak yağmur ormanlarının doğru haritalanmasını mümkün kılmıştır.", "Make (Yapmak) + Possible (Mümkün) - Bir durumu imkansızlıktan çıkarıp 'mümkün kılmak'."], ["weaken", "zayıflatmak, güçten düşürmek", "Prolonged exposure to economic sanctions can drastically weaken a country's currency value.", "Ekonomik yaptırımlara uzun süre maruz kalmak, bir ülkenin para birimi değerini büyük ölçüde zayıflatabilir.", "Weak (Zayıf) - Weak-en = Bir şeyi gücünü azaltarak 'zayıflatmak'."], ["ruin", "mahvetmek, bozmak, yıkmak", "The sudden frost overnight threatened to ruin the entire seasonal crop of the farmers.", "Gece meydana gelen ani don olayı, çiftçilerin tüm mevsimlik ürününü mahvetmekle tehdit etti.", "Ruin (Harabe) - Bir şehri harabeye çevirmek, tamamen 'mahvetmek'."], ["harm", "zarar vermek", "Industrial factories must implement filtering systems to avoid harming the public health.", "Sanayi fabrikaları, halk sağlığına zarar vermekten kaçınmak için filtreleme sistemleri uygulamalıdır.", "Harmful (Zararlı) kelimesinin fiil köküdür; incitmek, 'zarar vermek'."], ["undermine", "baltalamak, temelini kazımak/zayıflatmak", "Constant criticism without constructive feedback can severely undermine an employee's confidence.", "Yapıcı geri bildirim olmadan yapılan sürekli eleştiriler, bir çalışanın güvenini ciddi şekilde baltalayabilir.", "Under (Altından) + Mine (Maden kazmak) - Bir yapının altından maden kazarak onu 'baltalamak'."], ["damage", "hasar vermek, zarar vermek", "The heavy hailstorm managed to damage several vehicles parked in the open street.", "Şiddetli dolu fırtınası, açık sokakta park edilmiş birkaç araca hasar vermeyi başardı.", "Hasar raporlarında yazan 'Damage' (Zarar/Hasar) miktarı."], ["spoil", "bozmak, şımartmak, çürümek (yiyecek)", "If milk is not kept in a cold refrigerator, it will spoil within a few hours.", "Süt soğuk bir buzdolabında saklanmazsa, birkaç saat içinde bozulur (çürür).", "Spoiler - Bir filmin sonunu söyleyerek tüm seyir zevkini 'bozmak'."], ["disrupt", "aksatmak, düzenini bozmak, kesintiye uğratmak", "The widespread protests threatened to disrupt the city's public transportation network.", "Geniş çaplı protestolar, şehrin toplu taşıma ağını aksatmakla (düzenini bozmakla) tehdit etti.", "Dis-rupt (Rüptür/Yırtılma) - Var olan düzeni yırtıp 'kesintiye uğratmak'."], ["devastate", "yerle bir etmek, büyük yıkıma uğratmak", "The hurricane was strong enough to devastate entire coastal villages within minutes.", "Kasırga, kıyı köylerini dakikalar içinde yerle bir edecek kadar güçlüydü.", "Dev-Asa (Devastat-e) - 'Devasa' bir güçle ortalığı 'yerle bir etmek'."], ["demolish", "yıkmak, yerle bir etmek (bina vb.)", "The local municipality decided to demolish the old warehouse to build a green park.", "Yerel belediye, yeşil bir park yapmak için eski depoyu yıkmaya karar verdi.", "Delice imha (Demol-ish) - Eskimiş binaları iş makineleriyle 'yıkmak'."], ["mess up", "mahvetmek, karıştırmak, yüzüne gözüne bulaştırmak", "One wrong mathematical calculation can mess up the entire engineering project plan.", "Tek bir yanlış matematiksel hesaplama, tüm mühendislik proje planını mahvedebilir.", "Mess (Dağınıklık) - Ortalığı 'mess' hale getirmek, yani 'mahvetmek'."], ["cause", "sebep olmak, yol açmak", "Reckless driving is one of the primary factors that cause fatal traffic accidents.", "Dikkatsiz sürüş, ölümlü trafik kazalarına sebep olan birincil faktörlerden biridir.", "Because (Çünkü) kelimesinin köküdür; bir olayın 'sebebi olmak'."], ["lead to", "yol açmak, -e götürmek", "Ignoring minor medical symptoms can eventually lead to severe health complications.", "Küçük tıbbi semptomları göz ardı etmek, sonunda ciddi sağlık sorunlarına yol açabilir.", "Leader (Lider) - Takımı başarıya veya belirli bir sonuca 'götüren' kişi."], ["bring about", "sebep olmak, getirmek, (değişime) yol açmak", "The technological revolution will bring about major changes in daily manufacturing methods.", "Teknoloji devrimi, günlük üretim yöntemlerinde büyük değişikliklere yol açacak (beraberinde getirecek).", "Bring (Getirmek) + About (Hakkında) - Bir konuyu gündeme getirmek, değişime 'sebep olmak'."], ["contribute to", "katkıda bulunmak, -e sebep olmak (olumlu veya olumsuz)", "Regular physical exercise can significantly contribute to long-term cardiovascular health.", "Düzenli fiziksel egzersiz, uzun vadeli kalp sağlığına önemli ölçüde katkıda bulunabilir.", "Kontribüsyon (Contribution) - Projeye veya sürece verilen 'katkı'."], ["result in", "ile sonuçlanmak, -e yol açmak", "The long negotiation process between the two countries finally result in a peace treaty.", "İki ülke arasındaki uzun müzakere süreci nihayet bir barış antlaşmasıyla sonuçlandı.", "Result (Sonuç) - Bir işin finalde o 'sonuca varmasını' sağlamak."], ["end in", "-ile bitmek, sonuçlanmak", "The intense football match ended in a draw despite the continuous efforts of both teams.", "Zorlu futbol maçı, her iki takımın sürekli çabalarına rağmen beraberlikle bitti (sonuçlandı).", "End (Son) - Filmin veya sürecin o şekilde 'son bulması'."], ["trigger", "tetiklemek, harekete geçirmek", "A sudden increase in global gas prices can trigger inflation across multiple sectors.", "Küresel gaz fiyatlarındaki ani bir artış, birden fazla sektörde enflasyonu tetikleyebilir.", "Silahların ucundaki 'tetik' mekanizması (Trigger)."], ["stimulate", "canlandırmak, uyarmak, teşvik etmek", "The government lowered interest rates to stimulate economic spending and investments.", "Hükümet, ekonomik harcamaları ve yatırımları canlandırmak için faiz oranlarını düşürdü.", "Stimulant (Uyarıcı) - Vücudu veya sistemi 'canlandıran' doping etkisi."], ["prompt", "tetiklemek, -e sevk etmek, yol açmak", "The unexpected market crash prompted investors to withdraw their capital immediately.", "Beklenmedik piyasa çöküşü, yatırımcıları sermayelerini derhal çekmeye sevk etti (tetikledi).", "Yapay zekaya komut verip onu 'harekete geçiren/tetikleyen' yazı kelimesi (Prompt)."], ["inspire", "ilham vermek, teşvik etmek", "Her successful career story continues to inspire young students around the world.", "Onun başarılı kariyer hikayesi, dünya çapındaki genç öğrencilere ilham vermeye devam ediyor.", "İspirto (İnspir-e) - Sanatçının içindeki yaratıcılık ateşini yakan 'ilham'."], ["motivate*", "motive etmek, isteklendirmek", "Good managers know how to motivate their team members during tight project deadlines.", "İyi yöneticiler, sıkışık proje teslim tarihlerinde ekip üyelerini nasıl motive edeceklerini bilirler.", "Motivasyon (Motivation) - Bir işi yapmak için duyulan yüksek 'istek/enerji'."]], "ADJACTIVE_SET_1": [["important", "önemli", "It is important to understand the cultural context of a language.", "Bir dilin kültürel bağlamını anlamak önemlidir.", "İmparator (import-ant) halkı için 'önemli' kararlar alır."], ["significant", "önemli, kayda değer", "There has been a significant increase in the number of people using renewable energy.", "Yenilenebilir enerji kullanan insan sayısında önemli bir artış oldu.", "Sign (işaret) - Verilen önemli bir işaret 'significant'tır."], ["crucial", "hayati, çok önemli", "Vitamin C plays a crucial role in maintaining a healthy immune system.", "C vitamini sağlıklı bir bağışıklık sistemini korumada hayati bir rol oynar.", "Cruise gemisinde kaptan 'crucial' (hayati) biridir."], ["critical", "kritik, çok önemli", "The first few hours after the surgery are critical for the patient's recovery.", "Ameliyattan sonraki ilk birkaç saat hastanın iyileşmesi için kritiktir.", "Kritik (critical) kararlar hayat kurtarır."], ["vital", "hayati, çok önemli", "Education is vital for the economic development of a country.", "Eğitim bir ülkenin ekonomik gelişimi için hayatidir.", "Vital bulgular (nabız vb.) yaşamak için 'vital'dir."], ["necessary", "gerekli", "It is necessary to take precautions before the storm hits the city.", "Fırtına şehri vurmadan önce önlem almak gereklidir.", "Ne ses (ne-cess-ary) duyarsan duy, kaçmak için hız 'gerekli'."], ["essential", "temel, zorunlu", "Water is essential for all living organisms to survive.", "Su, tüm canlı organizmaların hayatta kalması için esastır.", "En sevdiğim (es-sen-tial) şeyler hayatım için 'temel'dir."], ["fundamental", "temel, esas", "The fundamental principles of democracy include freedom of speech.", "Demokrasinin temel ilkeleri ifade özgürlüğünü içerir.", "Funda mental (zihinsel) olarak 'temel' eğitimini tamamladı."], ["required", "gerekli, zorunlu", "The position requires a high level of expertise in computer science.", "Bu pozisyon, bilgisayar bilimlerinde yüksek düzeyde uzmanlık gerektirmektedir.", "Reket (re-quir-ed) tenis oynamak için 'gerekli'dir."], ["needed", "gerekli, ihtiyaç duyulan", "More funding is needed to complete the scientific research project.", "Bilimsel araştırma projesini tamamlamak için daha fazla fon gereklidir.", "Neden (need-ed) bu kadar çok malzemeye 'ihtiyaç duyuluyor'?"], ["strange", "tuhaf, garip", "I heard a strange noise coming from the basement last night.", "Dün gece bodrumdan gelen garip bir ses duydum.", "Doctor Strange oldukça 'tuhaf' bir karakterdir."], ["unusual", "sıradışı, alışılmadık", "It is unusual for him to be late for meetings.", "Toplantılara geç kalması onun için alışılmadık bir durumdur.", "Usual (olağan) - 'un' gelince 'sıradışı' oldu."], ["weird", "garip, tuhaf", "She has a weird habit of collecting old bus tickets.", "Eski otobüs biletlerini toplamak gibi tuhaf bir alışkanlığı var.", "Viyırtt (weird) diye 'garip' bir ses çıktı."], ["uncommon", "nadir, alışılmamış", "Red squirrels are quite uncommon in this part of the country.", "Kızıl sincaplar ülkenin bu bölgesinde oldukça nadirdir.", "Common (yaygın) olmayan şey 'nadir'dir."], ["massive", "devasa, büyük", "The explosion caused massive damage to the surrounding buildings.", "Patlama çevredeki binalarda devasa hasara yol açtı.", "Masa (mass-ive) o kadar büyük ki 'devasa' görünüyor."], ["huge", "çok büyük, kocaman", "They have a huge garden where they grow their own vegetables.", "Kendi sebzelerini yetiştirdikleri kocaman bir bahçeleri var.", "Hücum (huge-um) eden ordu 'çok büyük'tü."], ["vast", "geniş, çok büyük (alan)", "The Sahara Desert covers a vast area of Northern Africa.", "Sahra Çölü Kuzey Afrika'nın çok geniş bir alanını kaplar.", "Vast (bastığın) yerler 'geniş' ve uçsuz bucaksız."], ["immense", "muazzam, çok büyük", "The project was an immense challenge for the young engineering team.", "Proje, genç mühendislik ekibi için muazzam bir zorluktu.", "İmmen (İmkan) 'çok büyük' olunca başarı gelir."], ["enormous", "devasa, çok büyük", "The dinosaur was enormous compared to the modern-day animals.", "Dinozor, günümüz hayvanlarına kıyasla devasaydı.", "O norm (e-norm-ous) dışı, yani 'devasa'."], ["compulsory", "zorunlu", "Primary education is compulsory for all children in the country.", "Ülkede ilköğretim tüm çocuklar için zorunludur.", "Komiser (compul-sory) 'zorunlu' olarak ifade aldı."], ["mandatory", "zorunlu", "Wearing a seatbelt is mandatory for all passengers.", "Emniyet kemeri takmak tüm yolcular için zorunludur.", "Manda (mand-atory) gibi güçlü kurallar 'zorunlu'dur."], ["obligatory", "zorunlu", "It is obligatory to present a valid ID to enter the building.", "Binaya girmek için geçerli bir kimlik sunmak zorunludur.", "Obli (Abli-abla) 'zorunlu' ödevlerini yapıyor."], ["enforced", "uygulanan, zorunlu kılınan", "The new regulations were strictly enforced by the local authorities.", "Yeni düzenlemeler yerel makamlarca sıkı bir şekilde uygulandı.", "Force (güç) kullanarak 'zorunlu kılındı'."], ["sudden", "ani, birden", "A sudden change in the weather ruined our picnic plans.", "Havadaki ani bir değişiklik piknik planlarımızı mahvetti.", "Satan (sudd-en) kişi 'ani'den ortadan kayboldu."], ["abrupt", "ani, sert", "The meeting came to an abrupt end when the power went out.", "Elektrikler kesilince toplantı ani bir şekilde sona erdi.", "Abra (abrupt) kadabra! 'Ani'den bir tavşan çıktı."], ["hasty", "acele, hızlı", "He made a hasty decision without thinking about the consequences.", "Sonuçlarını düşünmeden acele bir karar verdi.", "Hasta (hasty) olunca 'acele' doktora gidilir."], ["urgent", "acil", "The patient needs urgent medical attention due to severe pain.", "Hasta, şiddetli ağrı nedeniyle acil tıbbi yardıma ihtiyaç duyuyor.", "Urcan (urgent) 'acil' yetiş!"], ["steady", "istikrarlı, sabit", "The patient's condition has remained steady throughout the night.", "Hastanın durumu gece boyunca sabit kaldı.", "Stadyum (steady-um) 'sabit' ve yerinden oynamaz."], ["stable", "istikrarlı, dengeli", "The economy needs a stable political environment to grow.", "Ekonominin büyümesi için istikrarlı bir siyasi ortama ihtiyacı var.", "Stabil (stable) - Durumu 'istikrarlı' gidiyor."], ["fixed", "sabit, değişmez", "The price of the product is fixed and cannot be negotiated.", "Ürünün fiyatı sabittir ve pazarlık yapılamaz.", "Fikstür (fix-ed) maçların 'sabit' zamanlarını gösterir."], ["constant", "sürekli, sabit", "The constant noise from the construction site made it hard to work.", "İnşaat alanından gelen sürekli gürültü çalışmayı zorlaştırdı.", "Konstan (Kantine) 'sürekli' giderdi."], ["persistent", "ısrarcı, kalıcı", "Despite persistent efforts, they couldn't solve the technical issue.", "Israrlı çabalara rağmen teknik sorunu çözemediler.", "Pes etmeyen (persist-ent) kişi 'ısrarcı'dır."], ["consistent", "tutarlı", "Her performance in the exams has been consistent throughout the year.", "Sınavlardaki performansı yıl boyunca tutarlı oldu.", "Konsis (Konuşması) 'tutarlı' biridir."], ["abundant", "bol, çok miktarda", "This region is known for its abundant natural resources.", "Bu bölge bol doğal kaynaklarıyla tanınır.", "Abun (Odun) o kadar 'bol' ki kışın üşümeyiz."], ["numerous", "çok sayıda", "Numerous studies have shown the benefits of regular exercise.", "Çok sayıda çalışma düzenli egzersizin faydalarını göstermiştir.", "Numara (numer-ous) 'çok sayıda' kişi tarafından alındı."], ["plentiful", "bol, bereketli", "The harvest was plentiful this year due to the good weather.", "İyi hava koşulları nedeniyle bu yıl hasat boldu.", "Plenty (bol) - Masada 'bol' meyve var."], ["ample", "bol, kafi, geniş", "There is ample evidence to support the theory of evolution.", "Evrim teorisini desteklemek için bol miktarda kanıt vardır.", "Ampul (ample) odaya 'bol' ışık verdi."], ["considerable", "önemli ölçüde, epey", "The project required a considerable amount of time and effort.", "Proje, epey zaman ve çaba gerektirdi.", "Consider (düşünmek) - Üzerinde düşünmeye değer, 'önemli ölçüde'."], ["substantial", "kayda değer, önemli", "A substantial number of employees were satisfied with the new policy.", "Çalışanların önemli bir kısmı yeni politikadan memnundu.", "Substant (öz) - İşin özü 'kayda değer' bir değişim olması."], ["noteworthy", "dikkate değer", "There are several noteworthy achievements in her professional career.", "Mesleki kariyerinde dikkate değer birkaç başarı var.", "Note (not) + worthy (değer) - 'Not almaya değer'."], ["remarkable", "dikkat çekici, olağanüstü", "The discovery of the new planet was a remarkable scientific achievement.", "Yeni gezegenin keşfi olağanüstü bir bilimsel başarıydı.", "Marka (remark-able) ürünler 'dikkat çekici'dir."], ["wonderful", "harika, müthiş", "We had a wonderful time at the seaside last weekend.", "Geçen hafta sonu deniz kenarında harika vakit geçirdik.", "Wonder Woman 'harika' bir kahramandır."], ["amazing", "şaşırtıcı, hayranlık uyandırıcı", "The view from the top of the mountain was absolutely amazing.", "Dağın tepesinden manzara kesinlikle şaşırtıcıydı.", "Amca (amaz-ing) o kadar 'şaşırtıcı' bir sihir yaptı ki."], ["brilliant", "parlak, zekice", "The young scientist came up with a brilliant solution to the problem.", "Genç bilim insanı soruna zekice bir çözüm buldu.", "Pırlanta (brilliant) gibi 'parlak' bir fikir."], ["fascinating", "büyüleyici", "The documentary provided a fascinating insight into ancient Egyptian life.", "Belgesel, eski Mısır yaşamına büyüleyici bir bakış sağladı.", "Fas-fıs (fascin-ating) sesleri arasında 'büyüleyici' bir hikaye."], ["magnificent", "muhteşem, görkemli", "The palace is famous for its magnificent architecture and gardens.", "Saray, muhteşem mimarisi ve bahçeleriyle ünlüdür.", "Magn (mıknatıs) gibi 'görkemli' yapısıyla herkesi çekti."], ["outstanding", "seçkin, çok başarılı", "She received an award for her outstanding contribution to medicine.", "Tıbba yaptığı seçkin katkılardan dolayı ödül aldı.", "Out (dışarıda) stand (durmak) - Diğerlerinin 'dışında/üstünde' başarı."], ["striking", "çarpıcı, dikkat çekici", "The contrast between the two paintings was quite striking.", "İki tablo arasındaki kontrast oldukça çarpıcıydı.", "Strike (vurmak) - Etkisiyle 'çarpıcı' bir iz bıraktı."], ["spectacular", "göz alıcı, muhteşem", "The fireworks display was a spectacular end to the festival.", "Havai fişek gösterisi festivalin göz alıcı bir sonu oldu.", "Spektak (Sepet) dolusu 'muhteşem' çiçek."], ["immediate", "derhal, hemen", "The situation required immediate action to prevent further damage.", "Durum, daha fazla hasarı önlemek için derhal harekete geçilmesini gerektiriyordu.", "İm (imza) atıldı, 'derhal' işe başlandı."], ["close", "yakın", "The two brothers have always been very close to each other.", "İki kardeş birbirlerine her zaman çok yakın olmuşlardır.", "Klozet (close-t) banyoya çok 'yakın'."], ["approaching", "yaklaşan", "The approaching deadline put a lot of pressure on the team.", "Yaklaşan son teslim tarihi ekip üzerinde büyük bir baskı oluşturdu.", "Ap-roç (Aperatif) yemeğe 'yaklaşan' zamanda yenir."], ["near", "yakın", "The hotel is located near the city center and the main train station.", "Otel, şehir merkezine ve ana tren istasyonuna yakın bir konumdadır.", "Nere (near-e) gidersen git, bana 'yakın' ol."]], "ADJACTIVE_SET_2": [["dangerous", "tehlikeli", "The accumulation of toxic waste poses a dangerous threat to local ecosystems.", "Toksik atıkların birikmesi, yerel ekosistemler için tehlikeli bir tehdit oluşturmaktadır.", "Danger (Tehlike) - Sonu 'ous' sıfat ekiyle biten, bilinen en temel kelime."], ["hazardous", "tehlikeli, riskli", "Working in chemical plants involves handling hazardous materials on a daily basis.", "Kimya tesislerinde çalışmak, günlük olarak tehlikeli maddelerin taşınmasını içerir.", "Hazard (Risk/Kaza) - 'Hazar' denizinde fırtınaya yakalanmak çok 'riskli' ve tehlikelidir."], ["harmful", "zararlı", "Excessive consumption of processed sugar has multiple harmful effects on the body.", "İşlenmiş şekerin aşırı tüketiminin vücut üzerinde çok sayıda zararlı etkisi vardır.", "Harm (Zarar) + ful (Dolu) - Kelime kökü 'harm' zarar vermek anlamına gelir."], ["detrimental", "zararlı, yıkıcı", "Lack of sleep can have a detrimental impact on a student's cognitive performance.", "Uykusuzluk, bir öğrencinin bilişsel performansı üzerinde zararlı bir etkiye sahip olabilir.", "De-Trient (Diyet) - Diyetini bozup 'mentalleri' (akıl sağlığını) yemek sağlığa 'zararlı'dır."], ["malignant", "kötü huylu (tümör vb.), zararlı", "The biopsy confirmed that the tumor was malignant and required immediate surgery.", "Biyopsi, tümörün kötü huylu olduğunu ve derhal ameliyat gerektirdiğini doğruladı.", "Mal (Kötü) - Latince 'mal-' kökü kötülük belirtir. Malign (Kötü niyetli/kötü huylu)."], ["harmless", "zararsız", "Most species of spiders found in this region are completely harmless to humans.", "Bu bölgede bulunan çoğu örümcek türü insanlara tamamen zararsızdır.", "Harm (Zarar) + less (Siz/Sız) - Zararı olmayan, temiz."], ["benign", "iyi huylu, zararsız", "The doctor reassured the patient that the cyst was benign and not cancerous.", "Doktor, hastaya kistin iyi huylu ve kanserli olmadığını söyleyerek güvence verdi.", "Benign (Ben iyi) - 'Ben iyi' huylu biriyim, kimseye zararım dokunmaz."], ["kind", "nazik, kibar, iyi niyetli", "It was very kind of the local authorities to provide free shelters during winter.", "Yerel yetkililerin kış boyunca ücretsiz barınak sağlaması çok nazikçeydi.", "Kind (Kayın) - 'Kayın' pederim bana karşı her zaman çok 'nazik' davrandı."], ["gentle", "nazik, yumuşak, hafif", "A gentle breeze from the ocean lowered the temperature during the hot afternoon.", "Okyanustan esen hafif bir meltem, sıcak öğleden sonra sıcaklığı düşürdü.", "Gentleman (Centilmen) - Centilmen erkekler 'nazik' ve kibar olur."], ["helpful", "yardımsever, faydalı", "The statistics provided in the report were highly helpful for our investigation.", "Raporda sunulan istatistikler araştırmamız için son derece faydalı oldu.", "Help (Yardım) + ful (Dolu) - Yardım etmeyi seven veya işe yarayan."], ["innocent", "masum, suçsuz", "The jury concluded that the suspect was innocent due to a lack of evidence.", "Jüri, kanıt yetersizliğinden dolayı şüphelinin masum olduğuna karar verdi.", "Ino-cent (İnleyen çocuk) - Mahkemede ağlayan o çocuk tamamen 'masum'du."], ["talented", "yetenekli", "The university supports talented musicians by offering full scholarships.", "Üniversite, tam burslar sunarak yetenekli müzisyenleri desteklemektedir.", "Talent (Yetenek) - Yarışma programı 'Got Talent' (Yetenek Sizsiniz) konseptinden gelir."], ["gifted", "doğuştan yetenekli, üstün zekalı", "Gifted children often require specialized educational programs to reach their potential.", "Üstün zekalı çocukların potansiyellerine ulaşmaları için genellikle özel eğitim programları gerekir.", "Gift (Hediye) - Tanrı tarafından kendisine yetenek 'hediye' edilmiş kişi."], ["skilful", "becerikli, usta", "The surgeon was highly skilful, completing the complex operation ahead of schedule.", "Cerrah oldukça becerikliydi ve karmaşık ameliyatı planlanandan önce tamamladı.", "Skill (Beceri) + ful (Dolu) - Becerisi tam, elinden her iş gelen usta."], ["capable", "kabiliyetli, yapabilen", "With proper training, she is capable of managing the entire international department.", "Doğru bir eğitimle, tüm uluslararası departmanı yönetecek kabiliyete sahiptir.", "Kapasite (Capacity) - Bir işi yapmaya kapasitesi, yani 'kabiliyeti' olan."], ["proficient", "profesyonel, uzman, yetkin", "Applicants must be proficient in at least two foreign languages for this position.", "Adayların bu pozisyon için en az iki yabancı dilde yetkin olmaları gerekmektedir.", "Profession (Meslek/Profesyonel) - İşinde tamamen 'uzmanlaşmış' kişi."], ["versatile", "çok yönlü, hamarat", "Graphene is a versatile material that can be used in electronics, medicine, and energy.", "Grafen; elektronik, tıp ve enerjide kullanılabilen çok yönlü bir malzemedir.", "Versiyon (Version) - Her versiyona uyum sağlayabilen, 'çok yönlü' ürün."], ["competent", "yetkin, ehil, becerikli", "The company is seeking a competent manager to oversee the new financial transition.", "Şirket, yeni finansal geçişi denetlemek için yetkin bir müdür arıyor.", "Compete (Rekabet etmek) - Rekabet edebilecek güçte ve 'yetkinlikte' olan kişi."], ["famous for", "ile ünlü/meşhur", "The region is famous for its historic architecture and vast vineyards.", "Bölge, tarihi mimarisi ve geniş üzüm bağları ile ünlüdür.", "Fame (Şöhret) - Şöhret sahibi, herkes tarafından bilinen."], ["notable for", "ile tanınan, dikkate değer", "The philosopher was notable for his radical views on social justice.", "Filozof, sosyal adalet konusundaki radikal görüşleriyle tanınırdı.", "Note (Not) - Not edilmeye değer, başarılarıyla göze çarpan."], ["well-known for", "ile iyi bilinen/tanınan", "Switzerland is well-known for its high-quality watches and stable banking system.", "İsviçre, yüksek kaliteli saatleri ve istikrarlı bankacılık sistemiyle iyi bilinir.", "Well (İyi) + Known (Bilinen) - Toplumca 'iyi bilinen' popüler şey."], ["prominent", "seçkin, önde gelen, önemli", "Several prominent scientists attended the international conference on biotechnology.", "Biyoteknoloji konusundaki uluslararası konferansa önde gelen birkaç bilim insanı katıldı.", "Premium - Premium sınıfa ait, toplumda 'önde gelen' seçkin şahsiyet."], ["distinguished", "seçkin, ayırt edici, başarılı", "He had a long and distinguished career as a diplomat in the United Nations.", "Birleşmiş Milletler'de bir diplomat olarak uzun ve seçkin bir kariyere sahipti.", "Distinguish (Ayırt etmek) - Diğer insanlardan başarılarıyla kolayca 'ayırt edilen' seçkin kişi."], ["eminent", "saygın, seçkin, ünlü", "The book features essays written by eminent scholars from across the globe.", "Kitap, dünyanın dört bir yanından saygın akademisyenler tarafından yazılmış makaleleri içeriyor.", "Emin (Emin olmak) - Bilgisinden emin olduğumuz 'saygın' profesör."], ["distinct", "farklı, belirgin, net", "There is a distinct possibility that inflation will continue to rise next quarter.", "Önümüzdeki çeyrekte enflasyonun yükselmeye devam etmesi bariz bir olasılıktır.", "Distinct (Disko) - Diskodaki ışıklar karanlıkta çok 'belirgin' ve 'farklı' görünür."], ["lucrative", "karlı, kazançlı", "Investing in renewable energy projects has proven to be a highly lucrative business.", "Yenilenebilir enerji projelerine yatırım yapmanın son derece karlı bir iş olduğu kanıtlanmıştır.", "Lucre (Cukka/Para) - 'Lüküs' hayat yaşatacak kadar çok para getiren, 'kazançlı' iş."], ["profitable", "karlı, kazanç getiren", "The company closed down its non-profitable branches to cut corporate expenses.", "Şirket, kurumsal masrafları kısmak için karlı olmayan şubelerini kapattı.", "Profit (Kar/Kazanç) - Şirkete yüksek oranda 'profit' getiren karlı yatırım."], ["gainful", "kazançlı, faydalı", "The government is trying to create more gainful employment opportunities for youth.", "Hükümet, gençler için daha fazla kazançlı istihdam fırsatı yaratmaya çalışıyor.", "Gain (Kazanmak/Kazanım) - Bize maddi veya manevi gelişim 'kazandıran' iş."], ["thriving", "gelişen, büyüyen, başarılı", "The tech start-up turned into a thriving global corporation within five years.", "Teknoloji girişimi, beş yıl içinde büyüyen ve gelişen küresel bir şirkete dönüştü.", "Drive (Sürmek) - İşleri sürekli ileriye doğru süren, 'hızla gelişen' esnaf."], ["flourishing", "gelişen, parlayan, çiçek açan", "Tourism is a flourishing industry that provides jobs to millions of people.", "Turizm, milyonlarca insana iş sağlayan, hızla gelişen bir sektördür.", "Flower (Çiçek) - Çiçek gibi açılan, işleri tıkırında gidip 'gelişen' işletme."], ["recurrent", "tekrarlayan, nükseden", "The patient suffered from recurrent headaches that resisted standard treatment.", "Hasta, standart tedaviye direnen tekrarlayan baş ağrılarından muzdaripti.", "Current (Mevcut/Akıntı) - Re (Yeniden) + Current = Sürekli yeniden akıntıya kapılan, 'tekrarlayan'."], ["repeated", "tekrarlanan", "Despite repeated warnings, the factory continued to discharge waste into the river.", "Tekrarlanan uyarılara rağmen fabrika nehre atık boşaltmaya devam etti.", "Repeat (Tekrar etmek) - Defalarca üst üste yapılmış, yinelenmiş."], ["ongoing", "devam eden, süregelen", "The ongoing negotiations between the two nations are expected to end soon.", "İki ulus arasında devam eden müzakerelerin yakında sona ermesi bekleniyor.", "On (Açık) + Going (Gidiş) - Süreç hala açık ve 'devam ediyor'."], ["continuous", "kesintisiz, sürekli", "The continuous rain caused severe flooding in the low-lying agricultural areas.", "Kesintisiz yağmur, alçakta kalan tarım alanlarında ciddi sellere neden oldu.", "Continue (Devam etmek) - Hiç durmadan, sürekli aralıksız devam eden."], ["uninterrupted", "kesintisiz, aralıksız", "The hospital relies on generators to ensure an uninterrupted supply of electricity.", "Hastane, kesintisiz bir elektrik kaynağı sağlamak için jeneratörlere güvenmektedir.", "Interrupt (Yarıda kesmek) - Un (Olumsuz) + Interrupt = Araya hiçbir şey girmemiş, 'kesintisiz'."], ["little", "az, küçük", "There is little hope left that the missing hikers will be found alive.", "Kayıp yürüyüşçülerin canlı bulunacağına dair çok az umut kaldı.", "Little (Litre) - Şişenin dibinde sadece bir 'litre'cik 'az' su kaldı."], ["few", "az, birkaç (sayılabilen)", "Very few historical documents from that specific era have survived to this day.", "O belirli döneme ait çok az tarihi belge günümüze kadar ulaşabilmiştir.", "Few (Fevç) - Fevç fevç geldiler ama sayıca 'az' kişi kaldılar."], ["small", "küçük, ufak", "A small error in the code caused the entire software system to crash.", "Koddaki küçük bir hata tüm yazılım sisteminin çökmesine neden oldu.", "Small (Small beden) - Tişört alırken 'S' yani en 'küçük' bedeni seçti."], ["tiny", "minicik, çok küçük", "Microscopes are essential instruments used to observe tiny microorganisms.", "Mikroskoplar, minicik mikroorganizmaları gözlemlemek için kullanılan temel araçlardır.", "Tane - Toz 'tane'leri gözle görülemeyecek kadar 'minicik'tir."], ["meagre", "kıt, yetersiz, az", "The refugees had to survive on a meagre ration of water and bread for weeks.", "Mülteciler haftalarca kıt bir su ve ekmek istihkakıyla hayatta kalmak zorunda kaldı.", "Meğer - 'Meğer' ambarımızdaki tüm buğday stokları ne kadar da 'kıt'mış."], ["minor", "küçük, önemsiz, ikincil", "The pilot managed to land the plane safely despite a minor mechanical failure.", "Pilot, küçük bir mekanik arızaya rağmen uçağı güvenli bir şekilde indirmeyi başardı.", "Minör (Müzik) - Majör büyük ve baskınken, minör daha 'küçük' ve hüzünlüdür."], ["slight", "hafif, azıcık, önemsiz", "There was a slight misunderstanding regarding the schedule of the final exam.", "Final sınavının takvimiyle ilgili hafif bir yanlış anlaşılma oldu.", "Slayt - Sunumdaki 'slayt' üzerinde 'hafif/azıcık' bir değişiklik yaptık."], ["trivial", "önemsiz, kayda değmez, ıvır zıvır", "We shouldn't waste our precious time arguing over such trivial matters.", "Böylesine önemsiz meseleler üzerinde tartışarak değerli vaktimizi boşa harcamamalıyız.", "Trivia - Genel kültür yarışmalarındaki 'ıvır zıvır/önemsiz' ama eğlenceli bilgiler."], ["insignificant", "önemsiz, değersiz", "The difference in output between the two production lines was completely insignificant.", "İki üretim hattı arasındaki çıktı farkı tamamen önemsizdi.", "Significant (Önemli) + In (Değil) - Önemli olmayan, 'göz ardı edilebilir'."], ["unimportant", "önemli olmayan", "In the grand scheme of things, this minor delay is relatively unimportant.", "Büyük resme bakıldığında, bu küçük gecikme nispeten önemli değildir.", "Important (Önemli) + Un (Değil) - Gündem maddesi dışı kalan sıradan olay."], ["negligible", "ihmal edilebilir, çok az", "The environmental risks associated with the new factory were deemed negligible.", "Yeni fabrikayla ilgili çevresel riskler ihmal edilebilir düzeyde görüldür.", "Neglect (İhmal etmek) - İhmal etsen de hiçbir şeyin değişmeyeceği kadar 'az' miktar."], ["valuable", "değerli, kıymetli", "The museum displays valuable artifacts from the ancient Roman civilization.", "Müze, eski Roma medeniyetine ait değerli eserleri sergiliyor.", "Value (Değer) - Maddi veya manevi yüksek 'değer' taşıyan nesne."], ["invaluable", "paha biçilemez derecede değerli", "Her advice on international trade laws proved to be invaluable to our legal firm.", "Uluslararası ticaret hukuku konusundaki tavsiyeleri hukuk firmamız için paha biçilemez oldu.", "In (Sınır yok) + Valuable = Değer biçme sınırlarının ötesinde, 'çok kıymetli'."], ["precious", "kıymetli, nadide", "Diamonds and rubies are classified as precious stones due to their rarity.", "Elmaslar ve yakutlar, nadirlikleri nedeniyle kıymetli taşlar olarak sınıflandırılır.", "Precious (My Precious) - Yüzüklerin Efendisi'ndeki Gollum'un 'kıymetlimisss' repliği."], ["priceless", "paha biçilemez", "The historical paintings preserved in the national gallery are absolutely priceless.", "Ulusal galeride korunan tarihi tablolar kesinlikle paha biçilemez.", "Price (Fiyat) + less (Sız) - Parayla satın alınamayacak kadar 'eşsiz'."], ["irreplaceable", "yeri doldurulamaz, benzersiz", "The damage to the ancient archives caused an irreplaceable loss to human history.", "Antik arşivlerin zarar görmesi, insanlık tarihi için yeri doldurulamaz bir kayba neden oldu.", "Replace (Yerine yenisini koymak) - Ir (Olumsuz) + Replaceable = Dünyada 'ikincisi olmayan'."], ["notorious for", "adı çıkmış, kötü şöhretli", "The criminal organization was notorious for its sophisticated smuggling operations.", "Suç örgütü, karmaşık kaçakçılık faaliyetleriyle kötü bir şöhrete sahipti.", "Noter - Sadece 'kötü olayları' ve suçluların sicilini tasdikleyen hayali bir 'noter' düşün."], ["infamous for", "kötü ünlü/şöhretli", "The pirate captain was infamous for his cruelty toward captured crews.", "Korsan kaptanı, esir alınan mürettebata karşı acımasızlığıyla kötü bir üne sahipti.", "Famous (Ünlü) + In (Zıtlık) - İyi bir şeyle değil, yaptığı rezilliklerle 'kötü tanınan'."]], "ADJACTIVE_SET_3": [["wealthy", "zengin, varlıklı", "The government introduced new tax reforms targeting wealthy individuals and large corporations.", "Hükümet, varlıklı bireyleri ve büyük şirketleri hedef alan yeni vergi reformları getirdi.", "Wealth (Servet) - Kökü olan 'wealth' servet ve refah anlamına gelir."], ["rich", "zengin", "The region is rich in natural resources, particularly natural gas and iron ore.", "Bölge, başta doğal gaz ve demir cevheri olmak üzere doğal kaynaklar bakımından zengindir.", ""], ["prosperous", "gelişen, refah içinde, zengin", "A stable political environment is essential for building a prosperous society.", "Refah içinde bir toplum inşa etmek için istikrarlı bir siyasi ortam şarttır.", "Pronto + Para - 'Profesyonel'ce yönetilen işler şirketi 'refah içinde' ve zengin yapar."], ["affluent", "zengin, varlıklı, nüfuzlu", "Many affluent families prefer to send their children to private international schools.", "Birçok varlıklı aile, çocuklarını özel uluslararası okullara göndermeyi tercih ediyor.", "Afili (Afflu-ent) - 'Afili' ve lüks bir hayat yaşayan 'zengin' insanlar."], ["fast", "hızlı, çabuk", "The internet has enabled the fast dissemination of information across the globe.", "İnternet, bilginin dünya çapında hızlı bir şekilde yayılmasını sağladı.", "Fast food - Sipariş verdiğinde 'hızlı' ve çabuk hazırlanan yiyecek tarzı."], ["quick", "hızlı, çabuk", "The economic analyst made a quick assessment of the market crash.", "Ekonomik analist, piyasa çöküşünün hızlı bir değerlendirmesini yaptı.", "Quick (Kuvvetli) - Kuvvetli ve 'hızlı' adımlarla yürüyen atlet."], ["rapid", "hızlı, ani", "The rapid growth of the tech industry has created thousands of new job opportunities.", "Teknoloji sektörünün hızlı büyümesi binlerce yeni iş fırsatı yarattı.", "Raptiye - Kağıdı panoya 'hızlıca' ve çabucak tutturmaya yarayan araç."], ["prompt", "hızlı, anında, dakik", "The emergency services received praise for their prompt response to the accident.", "Acil servisler, kazaya verdikleri hızlı yanıttan dolayı övgü aldı.", "Program - Bilgisayar 'program'ı komut verdiğinde 'anında/hızlıca' çalışır."], ["instant", "anlık, hemen olan", "Social media platforms provide instant communication between users worldwide.", "Sosyal medya platformları, dünya çapındaki kullanıcılar arasında anlık iletişim sağlar.", "Instant kahve - Sıcak suyu dökünce 'anında' hazır olan hazır kahve."], ["various", "çeşitli, türlü türlü", "The scientists analyzed the data using various statistical methods.", "Bilim insanları, verileri çeşitli istatistiksel yöntemler kullanarak analiz ettiler.", "Varyasyon (Variation) - Bir ürünün farklı 'varyasyon'ları, yani 'çeşitli' halleri."], ["diverse", "çeşitli, farklı, çok sesli", "A diverse workforce brings innovative ideas and different perspectives to the company.", "Çeşitlilik gösteren (farklı) bir iş gücü, şirkete yenilikçi fikirler ve farklı bakış açıları getirir.", "Dizi (Di-verse) - Bir 'dizi' farklı ve 'çeşitli' karakterin bir araya gelmesi."], ["separate", "ayrı, bağımsız", "The two departments operate in separate buildings located on opposite sides of the city.", "İki departman, şehrin zıt taraflarında bulunan ayrı binalarda faaliyet göstermektedir.", "Sepet (Separ-ate) - Çürük elmaları sağlamlardan 'ayrı' bir 'sepet'e koymak."], ["different", "farklı", "The researchers compared two different treatment methods for the disease.", "Araştırmacılar, hastalık için iki farklı tedavi yöntemini karşılaştırdı.", "Differ (Farklı olmak) - Fiil kökü 'differ' ayrışmak, farklılaşmak anlamına gelir."], ["versatile", "çok yönlü, değişken", "The iPad has proven to be a versatile tool for both students and professionals.", "iPad'in hem öğrenciler hem de profesyoneller için çok yönlü bir araç olduğu kanıtlanmıştır.", "Versiyon (Version) - Her 'versiyon'a ayak uydurabilen, 'çok yönlü' yetenek."], ["novel", "yeni, özgün, alışılmadık", "The company developed a novel approach to water purification using nanotechnology.", "Şirket, nanoteknoloji kullanarak su arıtmaya yönelik yeni ve özgün bir yaklaşım geliştirdi.", "Novel (Roman) - Roman yazarları her zaman 'yeni' ve 'özgün' konular arar."], ["innovative", "yenilikçi, inovatif", "Innovative technologies are crucial for reducing carbon emissions in heavy industries.", "Ağır sanayide karbon emisyonlarını azaltmak için yenilikçi teknolojiler çok önemlidir.", "İnovasyon (Innovation) - Sektöre 'yenilik' getiren projeler."], ["new", "yeni", "The museum opened a new exhibition showcasing modern digital art.", "Müze, modern dijital sanatı sergileyen yeni bir sergi açtı.", ""], ["fresh", "taze, yeni, yeni mezun/başlamış", "The committee is looking for candidates with fresh perspectives on social policy.", "Komite, sosyal politika konusunda yeni bakış açılarına sahip adaylar arıyor.", "Fresh (Taze) - İngilizce'deki 'fresh graduate' (yeni mezun) kalıbından hatırlanabilir."], ["latest", "en son, en yeni", "According to the latest reports, the economic growth has slowed down significantly.", "En son raporlara göre, ekonomik büyüme önemli ölçüde yavaşladı.", "Late (Geç) - En geç gelen şey, doğal olarak 'en son/en yeni' olandır."], ["harmful", "zararlı", "The ozone layer protects the Earth from harmful ultraviolet radiation.", "Ozon tabakası, Dünya'yı zararlı ultraviyole radyasyondan korur.", "Harm (Zarar) + ful (Dolu) - İçi tamamen zarar verme dürtüsüyle dolu olan."], ["damaging", "zarar verici, yıkıcı", "The scandal had a damaging effect on the politician's reputation.", "Skandalın, politikacının itibarı üzerinde zarar verici bir etkisi oldu.", "Damage (Hasar/Zarar) - Bilgisayara veya arabaya 'hasar' veren durum."], ["adverse", "olumsuz, zıt, ters", "The drug was withdrawn from the market due to its severe adverse side effects.", "İlaç, ciddi olumsuz yan etkileri nedeniyle piyasadan çekildi.", "Ad-Verse (Zıt ayet/Zıt mısra) - İşlerin 'ters' ve 'olumsuz' gitmesi."], ["detrimental", "zararlı, yıkıcı", "Constant stress can be highly detrimental to both physical and mental health.", "Sürekli stres hem fiziksel hem de zihinsel sağlık için son derece zararlı olabilir.", "Diyet-Mental - Diyetini bozup 'mental' (akıl) sağlığını tehlikeye atmak 'zararlı'dır."], ["destructive", "yıkıcı, tahrip edici", "The economic crisis had a destructive impact on small businesses across the country.", "Ekonomik kriz, ülke genelindeki küçük işletmeler üzerinde yıkıcı bir etki yarattı.", "Destroy (Yıkmak/Yok etmek) - Bir binayı tamamen 'yok eden' güç."], ["devastating", "yıkıcı, kahredici", "The earthquake caused devastating damage to the historic structure of the city.", "Deprem, şehrin tarihi yapısında yıkıcı hasara yol açtı.", "Dev-Asa (Devastat-ing) - 'Devasa' bir gücün ortalığı 'yerle bir etmesi/yıkması'."], ["deep", "derin", "The oceans hold deep mysteries that scientists are still trying to uncover.", "Okyanuslar, bilim insanlarının hala çözmeye çalıştığı derin gizemler barındırır.", "Dip (Deep) - Türkçe'deki 'dip' kelimesiyle ses olarak benzer, 'en dipteki/derin'."], ["bottomless", "dipsiz, sonsuz", "The financial black hole seemed bottomless, consuming all investment capital.", "Finansal kara delik, tüm yatırım sermayesini yutarak dipsiz göründü.", "Bottom (Dip) + less (Siz) - Dibi olmayan, 'dipsiz' kuyu."], ["profound", "derin, köklü (etki/bilgi)", "The invention of the printing press had a profound impact on human history.", "Matbaanın icadı insanlık tarihi üzerinde derin (köklü) bir etki yarattı.", "Profesör - Bir konuyu 'profesör' düzeyinde 'derinlemesine' bilmek."], ["neutral", "tarafsız, nötr", "Switzerland remained neutral during both of the major global conflicts.", "İsviçre, her iki büyük küresel çatışmada da tarafsız kaldı.", "Nötr (Türkçeyle aynı) - Elektrikteki 'nötr' gibi, ne artı ne eksi, yani 'tarafsız'."], ["impartial", "tarafsız, adil", "A judge must remain completely impartial throughout the judicial process.", "Bir yargıç, yargı süreci boyunca tamamen tarafsız kalmalıdır.", "Part (Taraf/Kısım) - Im (Olumsuz) + Part = Bir 'taraf' tutmayan, 'adil' kişi."], ["unbiased", "tarafsız, ön yargısız", "Journalists are expected to provide unbiased reporting on political events.", "Gazetecilerin siyasi olaylar hakkında tarafsız habercilik yapması beklenir.", "Bias (Ön yargı) - Un (Olumsuz) + Bias = Kafasında hiçbir 'ön yargı/taraf' olmayan."], ["unprejudiced", "ön yargısız, tarafsız", "An unprejudiced evaluation is necessary to select the best project proposal.", "En iyi proje teklifini seçmek için ön yargısız bir değerlendirme gereklidir.", "Prejudice (Ön yargı) - Un (Olumsuz) + Pre-judice = Peşin hüküm vermeyen, 'tarafsız'."], ["objective", "nesnel, tarafsız, objektif", "Scientific research must rely on objective data rather than personal opinions.", "Bilimsel araştırma, kişisel görüşlerden ziyade nesnel verilere dayanmalıdır.", "Objektif (Türkçeyle aynı) - Kameranın 'objektif'i gerçeği olduğu gibi, 'tarafsız' çeker."], ["fair", "adil, hakkaniyetli", "The committee ensured a fair distribution of funds among all departments.", "Komite, fonların tüm departmanlar arasında adil bir şekilde dağıtılmasını sağladı.", "Fair-play - Spor müsabakalarında 'dürüst' ve 'adil' oyun ruhu."], ["indifferent to", "kayıtsız, ilgisiz", "The corporation was indifferent to public concerns about environmental pollution.", "Şirket, çevre kirliliği konusundaki halkın endişelerine karşı kayıtsızdı.", "Different (Farklı) - In (Olumsuz) + Different = Onun için hiçbir şey fark etmiyor, çünkü 'ilgisiz'."], ["overlooking", "göz ardı eden, tepeden bakan", "Overlooking small mistakes in the initial phase can lead to major failures later.", "İlk aşamada küçük hataları göz ardı etmek, daha sonra büyük başarısızlıklara yol açabilir.", "Over (Üstünden) + Looking (Bakmak) - Hataların üstünden bakıp geçmek, yani 'göz ardı etmek'."], ["neglecting", "ihmal eden, umursamayan", "Neglecting regular maintenance can drastically shorten the lifespan of industrial machinery.", "Düzenli bakımı ihmal etmek, endüstriyel makinelerin ömrünü büyük ölçüde kısaltabilir.", "Neglect (İhmal etmek) - Bir işi yapmayı sürekli erteleyip 'ihmal etmek'."], ["unconcerned", "ilgisiz, gamsız, endişesiz", "He seemed completely unconcerned about the upcoming job interview.", "Yaklaşan iş görüşmesi hakkında tamamen endişesiz (ilgisiz) görünüyordu.", "Concern (Endişe/İlgi) - Un (Olumsuz) + Concern = Hiçbir şeyi dert etmeyen, 'ilgisiz/gamsız'."], ["insensitive to", "duyarsız, hissiz", "The management was criticized for being insensitive to the needs of the workers.", "Yönetim, işçilerin ihtiyaçlarına karşı duyarsız olduğu için eleştirildi.", "Sensitive (Hassas) - In (Olumsuz) + Sensitive = Hassas olmayan, 'duyarsız/hissiz'."], ["unprecedented", "eşi benzeri görülmemiş", "The rise in global temperatures is occurring at an unprecedented rate.", "Küresel sıcaklıklardaki artış, eşi benzeri görülmemiş bir hızla gerçekleşiyor.", "Precedent (Emsal/Örnek) - Un (Olumsuz) + Precedent = Tarihte hiç emsali, 'eşi benzeri olmamış'."], ["unique", "benzersiz, tek, özgün", "Each snowflake has a unique pattern that distinguishes it from all others.", "Her kar tanesi, onu diğerlerinden ayıran benzersiz bir desene sahiptir.", "Uni (Tek) - 'Üniversite' veya 'Üniforma' gibi tek tip/tek ve 'benzersiz' olan."], ["unparalleled", "paralelsiz, eşsiz, rakipsiz", "The ancient empire possessed unparalleled military power in the region.", "Antik imparatorluk, bölgede eşsiz (paralelsiz) bir askeri güce sahipti.", "Parallel (Paralel) - Un (Olumsuz) + Parallel = Yanına koyulabilecek bir paraleli, yani dengi olmayan 'eşsiz'."], ["matchless", "eşsiz, rakipsiz", "The museum displays jewelry crafted with matchless skill from the Ottoman era.", "Müze, Osmanlı döneminden eşsiz bir ustalıkla işlenmiş takıları sergiliyor.", "Match (Eşleşmek) + less (Siz) - Hiç kimseyle eşleşemeyecek kadar 'rakipsiz/eşsiz'."], ["careful", "dikkatli", "A careful analysis of the historical artifacts revealed their true origin.", "Tarihi eserlerin dikkatli bir analizi, onların gerçek kökenini ortaya çıkardı.", "Care (Önem/Bakım) + ful (Dolu) - İşine büyük önem ve 'dikkat' gösteren."], ["cautious", "tedbirli, temkinli", "Investors are cautious about putting money into volatile emerging markets.", "Yatırımcılar, istikrarsız gelişmekte olan piyasalara para yatırma konusunda temkinlidir.", "Caution (Tehlike/Dikkat) - Sarı 'Caution' şeritlerini görünce 'temkinli' davranmak."], ["watchful", "uyanık, tetikte, gözünü dört açan", "The security guards kept a watchful eye on the main entrance during the event.", "Güvenlik görevlileri, etkinlik boyunca ana girişi dikkatle (tetikte) izledi.", "Watch (İzlemek/Bakmak) + ful (Dolu) - Gözünü kırpmadan sürekli 'tetikte' izleyen."], ["alert", "tetikte, uyanık, hazır", "Pilots must remain alert at all times, especially during takeoff and landing.", "Pilotlar, özellikle kalkış ve iniş sırasında her zaman tetikte olmalıdır.", "Alarm - Telefonda 'alarm' çalınca aniden 'uyanık' ve tetikte olursun."], ["meticulous", "titiz, kılı kırk yaran", "The researcher was meticulous in documenting every step of the laboratory experiment.", "Araştırmacı, laboratuvar deneyinin her adımını belgelemede titizdi.", "Metik (Matematik) - Matematiksel işlemler yaparken çok 'titiz' ve dikkatli olmak gerekir."], ["temporary", "geçici, kalıcı olmayan", "The closure of the bridge is only temporary while construction is being completed.", "Köprünün kapatılması, inşaat tamamlanırken sadece geçicidir.", "Tempo - Belirli bir 'tempo' ile yapılan işler sonsuza kadar sürmez, 'geçici'dir."], ["momentary", "anlık, geçici", "A momentary lapse in concentration caused the athlete to lose the race.", "Konsantrasyondaki anlık bir kayıp, atletin yarışı kaybetmesine neden oldu.", "Moment (An) - Sadece bir 'an' süren, anlık ve 'geçici' durum."], ["brief", "kısa, öz", "The prime minister made a brief statement before entering the parliament building.", "Başbakan, parlamento binasına girmeden önce kısa bir açıklama yaptı.", "Briefing (Brifing) - Askeriyede veya şirketlerde verilen 'kısa' ve öz bilgilendirme toplantısı."], ["interim", "geçici, ara (dönem/hükümet)", "An interim manager was appointed until a permanent CEO could be found.", "Kalıcı bir CEO bulunana kadar geçici bir müdür atandı.", "Terim (In-terim) - Bir futbol 'terim'i olarak teknik direktörün 'ara dönem'de gelmesi."], ["disposable", "tek kullanımlık, gözden çıkarılabilir", "The use of disposable plastics has contributed significantly to ocean pollution.", "Tek kullanımlık plastiklerin kullanımı, okyanus kirliliğine önemli ölçüde katkıda bulunmuştur.", "Dispose (Atmak) - Kullandıktan sonra çöpe 'atılabilen', tek kullanımlık eşya."]]};
}


const DEFAULT_LEVELS_CONFIG = [
  { name: "Fiiller", emoji: "⚡", color: "#4A90D9", sets: [
    { name: "Verb Set 1", key: "VERB_SET_1" },
    { name: "Verb Set 2", key: "VERB_SET_2" },
  ]},
  { name: "Sıfatlar", emoji: "🌟", color: "#D4AF37", sets: [
    { name: "Adjective Set 1", key: "ADJACTIVE_SET_1" },
    { name: "Adjective Set 2", key: "ADJACTIVE_SET_2" },
    { name: "Adjective Set 3", key: "ADJACTIVE_SET_3" },
  ]},
];

// ── INDEXEDDB ─────────────────────────────────────────────────────────────────
const DB_NAME = "wordvault_v3";
const DB_VER = 1;

function openDB() {
  return new Promise((res, rej) => {
    const req = indexedDB.open(DB_NAME, DB_VER);
    req.onupgradeneeded = e => {
      const db = e.target.result;
      const stores = {
        users:       { keyPath:"id", autoIncrement:true },
        levels:      { keyPath:"id", autoIncrement:true },
        wordsets:    { keyPath:"id", autoIncrement:true },
        words:       { keyPath:"id", autoIncrement:true },
        progress:    { keyPath:["userId","wordId"] },
        active_sets: { keyPath:["userId","wordSetId"] },
        sessions:    { keyPath:"id", autoIncrement:true },
      };
      for (const [name, opts] of Object.entries(stores)) {
        if (!db.objectStoreNames.contains(name)) {
          const store = db.createObjectStore(name, opts);
          if (name === "users")    store.createIndex("username","username",{unique:true});
          if (name === "wordsets") store.createIndex("levelId","levelId");
          if (name === "words")    store.createIndex("wordSetId","wordSetId");
          if (name === "progress") store.createIndex("userId","userId");
          if (name === "active_sets") store.createIndex("userId","userId");
          if (name === "sessions") store.createIndex("userId","userId");
        }
      }
    };
    req.onsuccess = () => res(req.result);
    req.onerror  = () => rej(req.error);
  });
}

async function dbTx(stores, mode, fn) {
  const db = await openDB();
  return new Promise((res, rej) => {
    const tx = db.transaction(stores, mode);
    tx.onerror = () => rej(tx.error);
    fn(tx, res, rej);
  });
}
const dGet  = (s,k)       => dbTx(s,"readonly",  (tx,r)=>{ const q=tx.objectStore(s).get(k);     q.onsuccess=()=>r(q.result); });
const dPut  = (s,v)       => dbTx(s,"readwrite", (tx,r)=>{ const q=tx.objectStore(s).put(v);     q.onsuccess=()=>r(q.result); });
const dAdd  = (s,v)       => dbTx(s,"readwrite", (tx,r)=>{ const q=tx.objectStore(s).add(v);     q.onsuccess=()=>r(q.result); });
const dDel  = (s,k)       => dbTx(s,"readwrite", (tx,r)=>{ const q=tx.objectStore(s).delete(k);  q.onsuccess=()=>r(q.result); });
const dAll  = (s)         => dbTx(s,"readonly",  (tx,r)=>{ const q=tx.objectStore(s).getAll();   q.onsuccess=()=>r(q.result); });
const dIdx  = (s,idx,val) => dbTx(s,"readonly",  (tx,r)=>{ const q=tx.objectStore(s).index(idx).getAll(val); q.onsuccess=()=>r(q.result); });

// ── DB INIT (seed default data) ───────────────────────────────────────────────
async function initDB(wordData) {
  // Create admin user if not exists
  const users = await dAll("users");
  if (!users.find(u => u.username === "Admin")) {
    await dAdd("users", {
      username: "Admin", passwordHash: "admin",
      isAdmin: true, dailyGoal: 15,
      createdAt: Date.now(), currentStreak: 0, longestStreak: 0
    });
  }
  // Seed default levels & sets if not seeded
  const levels = await dAll("levels");
  if (levels.length === 0 && wordData) {
    for (let li = 0; li < DEFAULT_LEVELS_CONFIG.length; li++) {
      const lc = DEFAULT_LEVELS_CONFIG[li];
      const levelId = await dAdd("levels", {
        name: lc.name, iconEmoji: lc.emoji, color: lc.color,
        orderIndex: li, createdAt: Date.now(), isDefault: true
      });
      for (let si = 0; si < lc.sets.length; si++) {
        const sc = lc.sets[si];
        const words = wordData[sc.key] || [];
        const setId = await dAdd("wordsets", {
          levelId, name: sc.name, description: "",
          orderIndex: si, createdAt: Date.now(), isDefault: true
        });
        for (let wi = 0; wi < words.length; wi++) {
          const w = words[wi];
          await dAdd("words", {
            wordSetId: setId,
            english: w[0], turkish: w[1],
            ydsExampleSentence: w[2]||"",
            ydsExampleTranslation: w[3]||"",
            mnemonicTip: w[4]||"",
            orderIndex: wi, addedAt: Date.now()
          });
        }
      }
    }
  }
}

// ── TIMING HELPERS ────────────────────────────────────────────────────────────
const DAY_MS = 86400000;
const startOfDay = (ts) => {
  const d = new Date(ts);
  d.setHours(0,0,0,0);
  return d.getTime();
};
const daysDiff = (from, to) => Math.floor((startOfDay(to) - startOfDay(from)) / DAY_MS);

// Returns how many days until a word is ready, 0 = ready now
function daysUntilDaily(prog) {
  // Hiç çalışılmamış (lastReviewedAt yok) → hemen çıkar
  if (!prog.lastReviewedAt) return 0;
  // Doğru bilinmiş (haftalığa gidecek) → bu fonksiyon çağrılmaz ama yine de 0
  if (!prog.wrongCount || prog.wrongCount === 0) return 0;
  // Yanlış bilinmiş: son görülme bugünse 1 gün beklet, dün veya öncesiyse hazır
  const diff = daysDiff(prog.lastReviewedAt, Date.now());
  // diff=0 → bugün görüldü → 1 gün bekle
  // diff>=1 → dün veya öncesi görüldü → hazır (0)
  return diff === 0 ? 1 : 0;
}
function daysUntilWeekly(prog) {
  if (!prog.movedToWeeklyAt) return 0;
  const diff = daysDiff(prog.movedToWeeklyAt, Date.now());
  return Math.max(0, 7 - diff);
}
function daysUntilMonthly(prog) {
  if (!prog.movedToMonthlyAt) return 0;
  const diff = daysDiff(prog.movedToMonthlyAt, Date.now());
  return Math.max(0, 30 - diff);
}

// ── STUDY WORDS ───────────────────────────────────────────────────────────────
async function getStudyWords(userId, dailyGoal, sessionType) {
  const allProg = await dIdx("progress","userId",userId);

  if (sessionType === "WEEKLY_REVIEW") {
    // 7+ gün haftalıkta bekleyen kelimeler
    const ready = allProg.filter(p => p.box==="WEEKLY" && daysUntilWeekly(p)===0);
    const words = await Promise.all(ready.map(p=>dGet("words",p.wordId)));
    return words.filter(Boolean).map(w=>({word:w, progress:ready.find(p=>p.wordId===w.id)}));
  }

  if (sessionType === "MONTHLY_REVIEW") {
    // 30+ gün aylıkta bekleyen kelimeler
    const ready = allProg.filter(p => p.box==="MONTHLY" && daysUntilMonthly(p)===0);
    const words = await Promise.all(ready.map(p=>dGet("words",p.wordId)));
    return words.filter(Boolean).map(w=>({word:w, progress:ready.find(p=>p.wordId===w.id)}));
  }

  // DAILY
  const acts = await dIdx("active_sets","userId",userId);
  const activeSetIds = acts.map(a=>a.wordSetId);
  if (!activeSetIds.length) return [];
  const allWords = await dAll("words");
  const activeWords = allWords.filter(w=>activeSetIds.includes(w.wordSetId));
  const progMap = {};
  allProg.forEach(p=>{ progMap[p.wordId]=p; });
  let daily = allProg.filter(p=>p.box==="DAILY");
  daily = daily.filter(p => activeWords.find(w=>w.id===p.wordId));
  // 1 gün bekleme: bugün yanlış bilinenler yarın tekrar çıkar
  const dailyReady = daily.filter(p => daysUntilDaily(p)===0);
  let result = dailyReady.slice(0, dailyGoal);
  if (result.length < dailyGoal) {
    const studiedIds = new Set(allProg.map(p=>p.wordId));
    const newWords = activeWords.filter(w=>!studiedIds.has(w.id));
    const needed = dailyGoal - result.length;
    for (let i=0; i<Math.min(needed, newWords.length); i++) {
      const w = newWords[i];
      const prog = {userId, wordId:w.id, box:"DAILY", correctCount:0, wrongCount:0, saturdayFailed:false, lastReviewedAt:null, movedToWeeklyAt:null, movedToMonthlyAt:null};
      await dPut("progress", prog);
      result.push(prog);
    }
  }
  result = result.sort(()=>Math.random()-0.5).slice(0, dailyGoal);
  const words = await Promise.all(result.map(p=>dGet("words",p.wordId)));
  return result.map((p,i)=>({word:words[i], progress:p})).filter(x=>x.word);
}

// Get pending counts with timing
async function getBoxCountsWithTiming(userId) {
  const allProg = await dIdx("progress","userId",userId);
  const daily   = allProg.filter(p=>p.box==="DAILY").length;
  const weekly  = allProg.filter(p=>p.box==="WEEKLY").length;
  const monthly = allProg.filter(p=>p.box==="MONTHLY").length;
  const dailyReady   = allProg.filter(p=>p.box==="DAILY"   && daysUntilDaily(p)===0).length;
  const weeklyReady  = allProg.filter(p=>p.box==="WEEKLY"  && daysUntilWeekly(p)===0).length;
  const monthlyReady = allProg.filter(p=>p.box==="MONTHLY" && daysUntilMonthly(p)===0).length;
  const dailyPending   = allProg.filter(p=>p.box==="DAILY"   && daysUntilDaily(p)>0);
  const weeklyPending  = allProg.filter(p=>p.box==="WEEKLY"  && daysUntilWeekly(p)>0);
  const monthlyPending = allProg.filter(p=>p.box==="MONTHLY" && daysUntilMonthly(p)>0);
  const nextDailyHours  = dailyPending.length   ? "yarın" : null;
  const nextWeeklyDays  = weeklyPending.length  ? Math.min(...weeklyPending.map(p=>daysUntilWeekly(p)))  : null;
  const nextMonthlyDays = monthlyPending.length ? Math.min(...monthlyPending.map(p=>daysUntilMonthly(p))) : null;
  return { daily, weekly, monthly, dailyReady, weeklyReady, monthlyReady, nextDailyHours, nextWeeklyDays, nextMonthlyDays };
}

async function getPracticeWords(userId, setIds) {
  const allWords = await dAll("words");
  const words = allWords.filter(w=>setIds.includes(w.wordSetId));
  return words.sort(()=>Math.random()-0.5);
}

// ── ACTIVATE / DEACTIVATE SET ─────────────────────────────────────────────────
async function activateSet(userId, wordSetId) {
  await dPut("active_sets",{userId, wordSetId, addedAt:Date.now()});
  const words = await dIdx("words","wordSetId",wordSetId);
  for (const w of words) {
    const ex = await dGet("progress",[userId,w.id]);
    if (!ex) await dPut("progress",{userId, wordId:w.id, box:"DAILY", correctCount:0, wrongCount:0, saturdayFailed:false, lastReviewedAt:null});
  }
}

async function deactivateSet(userId, wordSetId) {
  await dDel("active_sets",[userId, wordSetId]);
  // Remove DAILY progress for words in this set that aren't in other active sets
  const words = await dIdx("words","wordSetId",wordSetId);
  const acts = await dIdx("active_sets","userId",userId);
  const otherActiveSetIds = acts.map(a=>a.wordSetId).filter(id=>id!==wordSetId);
  const otherActiveWords = new Set();
  for (const sid of otherActiveSetIds) {
    const ws = await dIdx("words","wordSetId",sid);
    ws.forEach(w=>otherActiveWords.add(w.id));
  }
  for (const w of words) {
    if (!otherActiveWords.has(w.id)) {
      const prog = await dGet("progress",[userId,w.id]);
      if (prog && prog.box==="DAILY") await dDel("progress",[userId,w.id]);
    }
  }
}

// ── UTILITIES ─────────────────────────────────────────────────────────────────
const TODAY = () => new Date().toISOString().slice(0,10);
// Gün kısıtlaması yok — tamamen zamana dayalı
const SESSION_LABELS_TR = {DAILY_STUDY:"Günlük",WEEKLY_REVIEW:"Haftalık Sınav",MONTHLY_REVIEW:"Aylık Tekrar",PRACTICE:"Pratik"};
const SESSION_LABELS_EN = {DAILY_STUDY:"Daily",WEEKLY_REVIEW:"Weekly Exam",MONTHLY_REVIEW:"Monthly Review",PRACTICE:"Practice"};
const SESSION_COLORS = {DAILY_STUDY:"#D4AF37",WEEKLY_REVIEW:"#4A90D9",MONTHLY_REVIEW:"#9B59B6",PRACTICE:"#50C878"};
const BOX_COLORS = {DAILY:"#4a90d9",WEEKLY:"#7b68ee",MONTHLY:"#4caf50"};

// Gün rozetleri için kırmızı→mavi renk geçişi (1 gün=kırmızı, 29 gün=mavi)
function getDayBadgeStyle(days) {
  const minDay = 1, maxDay = 29;
  const t = Math.max(0, Math.min(1, (days - minDay) / (maxDay - minDay)));
  // kırmızı: rgb(229,57,53) → mavi: rgb(74,144,217)
  const r = Math.round(229 + (74  - 229) * t);
  const g = Math.round(57  + (144 - 57)  * t);
  const b = Math.round(53  + (217 - 53)  * t);
  const color = `rgb(${r},${g},${b})`;
  return {
    fontSize:9, color, border:`1px solid rgba(${r},${g},${b},0.6)`,
    borderRadius:6, padding:"1px 5px", marginTop:2, display:"inline-block",
    background:`rgba(${r},${g},${b},0.10)`, fontFamily:"var(--fd)", letterSpacing:".3px"
  };
}

// Global language helper — reads from localStorage so all components can use it
const getLang = () => (typeof window !== "undefined" ? localStorage.getItem("wv_lang") || "tr" : "tr");
const t = (tr, en) => getLang() === "en" ? en : tr;

const shuffle = arr => [...arr].sort(()=>Math.random()-0.5);
const EMOJIS = ["📚","🔤","✏️","📖","🧠","💬","🎯","⚡","🌟","🏆","📝","🔥","🗺","⚓","🎨","🌊"];
const COLORS = ["#4A90D9","#D4AF37","#50C878","#E53935","#9B59B6","#FF6B35","#00BCD4","#FF69B4","#8BC34A","#FF9800"];

// ── CSS ───────────────────────────────────────────────────────────────────────
const CSS = `
@import url('https://fonts.googleapis.com/css2?family=Cinzel:wght@400;600;700&family=Crimson+Pro:ital,wght@0,300;0,400;0,600;1,300;1,400&display=swap');
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
:root{
  --n0:#040e1e;--n1:#0a1628;--n2:#112244;--n3:#1a3060;--n4:#243a72;
  --g0:#8b6914;--g1:#c49a1a;--g2:#d4af37;--g3:#e8c84a;--g4:#f5e07a;
  --w:rgba(255,255,255,1);--w9:rgba(255,255,255,0.9);--w7:rgba(255,255,255,0.7);
  --w4:rgba(255,255,255,0.4);--w15:rgba(255,255,255,0.15);--w08:rgba(255,255,255,0.08);
  --green:#4caf50;--red:#e53935;--blue:#4a90d9;--purple:#7b68ee;
  --fd:'Cinzel',serif;--fb:'Crimson Pro',serif;--r:14px;
}
html,body,#root{height:100%;width:100%;margin:0;padding:0;overflow:hidden}
body{background:var(--n0);color:var(--w);font-family:var(--fb);font-size:17px;-webkit-font-smoothing:antialiased;-webkit-text-size-adjust:100%;touch-action:manipulation}
.app{position:fixed;top:0;left:50%;transform:translateX(-50%);width:100%;max-width:430px;height:100%;display:flex;flex-direction:column;background:linear-gradient(160deg,var(--n1),var(--n0));overflow:hidden}
.screen{flex:1;overflow-y:auto;overflow-x:hidden;-webkit-overflow-scrolling:touch;overscroll-behavior-y:contain;padding-bottom:calc(env(safe-area-inset-bottom,0px) + 24px);min-height:0;height:0}
.screen::-webkit-scrollbar{display:none}

/* AUTH */
.auth-bg{min-height:100%;display:flex;flex-direction:column;align-items:center;padding:60px 28px 40px;background:linear-gradient(160deg,var(--n1),var(--n0));position:relative;overflow:hidden}
.auth-bg::before{content:'';position:absolute;top:-40%;left:-20%;width:140%;height:70%;background:radial-gradient(ellipse,rgba(212,175,55,0.07) 0%,transparent 70%);pointer-events:none}
.auth-anchor{font-size:56px;animation:bob 3s ease-in-out infinite}
@keyframes bob{0%,100%{transform:translateY(0)}50%{transform:translateY(-7px)}}
.auth-title{font-family:var(--fd);font-size:30px;color:var(--g2);letter-spacing:3px;margin:8px 0 4px}
.auth-sub{color:var(--w4);font-size:14px;margin-bottom:36px}

/* USER SELECT */
.user-list{width:100%;display:flex;flex-direction:column;gap:10px;margin-bottom:16px}
.user-btn{width:100%;padding:14px 18px;background:var(--w08);border:1px solid rgba(212,175,55,0.2);border-radius:var(--r);color:var(--w9);font-family:var(--fb);font-size:17px;cursor:pointer;text-align:left;display:flex;align-items:center;gap:12px;transition:background .2s,border-color .2s}
.user-btn:active{background:var(--w15);border-color:var(--g2)}
.user-avatar{width:36px;height:36px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-family:var(--fd);font-size:14px;font-weight:700;flex-shrink:0}
.user-name{flex:1}
.user-admin-tag{font-size:10px;color:var(--g2);font-family:var(--fd);letter-spacing:1px;background:rgba(212,175,55,0.15);padding:2px 7px;border-radius:10px}
.add-user-btn{width:100%;padding:12px;border:1px dashed rgba(212,175,55,0.3);border-radius:var(--r);background:transparent;color:var(--g2);font-family:var(--fd);font-size:13px;letter-spacing:1px;cursor:pointer;transition:background .2s}
.add-user-btn:active{background:rgba(212,175,55,0.08)}

/* ADMIN LOGIN */
.field{position:relative;margin-bottom:10px}
.field input{width:100%;padding:14px 16px;background:var(--w08);border:1px solid rgba(212,175,55,0.25);border-radius:var(--r);color:var(--w);font-family:var(--fb);font-size:16px;outline:none;transition:border-color .2s,background .2s}
.field input:focus{border-color:var(--g2);background:var(--w15)}
.field input::placeholder{color:var(--w4)}
.field label{position:absolute;top:-8px;left:12px;font-size:11px;color:var(--g2);background:var(--n1);padding:0 4px;font-family:var(--fd);letter-spacing:1px;pointer-events:none}

.btn{padding:13px;border:none;border-radius:var(--r);font-family:var(--fd);font-size:13px;letter-spacing:1px;cursor:pointer;transition:all .2s;outline:none;width:100%}
.btn-gold{background:var(--g2);color:var(--n1);font-weight:700}
.btn-gold:active{transform:scale(.97);background:var(--g3)}
.btn-outline{background:transparent;border:1px solid var(--w4);color:var(--w7)}
.btn-outline:active{background:var(--w08)}
.btn-red{background:rgba(229,57,53,.2);border:1px solid rgba(229,57,53,.4);color:#ff6b6b}
.auth-err{color:#ff6b6b;font-size:13px;text-align:center;margin:4px 0}
.back-link{background:none;border:none;color:var(--w4);font-family:var(--fb);font-size:14px;cursor:pointer;margin-top:12px;text-align:center;width:100%}

/* TOPBAR */
.topbar{padding:calc(env(safe-area-inset-top,0px) + 48px) 16px 10px;display:flex;align-items:center;gap:8px;flex-shrink:0}
.topbar-title{font-family:var(--fd);font-size:19px;color:var(--g2);flex:1;letter-spacing:.5px}
.topbar-sub{font-size:11px;color:var(--w4)}
.icon-btn{width:36px;height:36px;border-radius:50%;border:none;background:var(--w08);color:var(--w7);cursor:pointer;display:flex;align-items:center;justify-content:center;font-size:18px;transition:background .2s;flex-shrink:0}
.icon-btn:active{background:var(--w15)}

/* BOTTOM NAV */
.bnav{display:flex;background:rgba(10,22,40,.96);border-top:1px solid rgba(212,175,55,.15);padding:6px 0 env(safe-area-inset-bottom,6px);flex-shrink:0;backdrop-filter:blur(12px)}
.ni{flex:1;display:flex;flex-direction:column;align-items:center;gap:2px;padding:5px 2px;background:none;border:none;cursor:pointer;transition:all .2s}
.ni-icon{font-size:20px;transition:transform .2s}
.ni-label{font-size:9px;color:var(--w4);font-family:var(--fd);letter-spacing:.5px;transition:color .2s}
.ni.active .ni-label{color:var(--g2)}
.ni.active .ni-icon{transform:scale(1.15)}

/* CARDS */
.card{background:var(--n3);border-radius:16px;padding:15px;border:1px solid var(--w08)}

/* HOME */
.home-wrap{padding:0 14px 14px;display:flex;flex-direction:column;gap:12px}
.greeting{padding:calc(env(safe-area-inset-top,0px) + 48px) 16px 2px}
.g-sub{color:var(--w4);font-size:13px}
.g-name{font-family:var(--fd);font-size:26px;color:var(--g2);letter-spacing:1px}
.boxes-row{display:grid;grid-template-columns:1fr 1fr 1fr;gap:8px}
.box-card{background:var(--n3);border-radius:13px;padding:11px 6px;text-align:center;border:1px solid var(--w08);cursor:pointer;transition:background .15s}
.box-card:active{background:var(--n4)}
.box-emoji{font-size:20px}
.box-count{font-family:var(--fd);font-size:22px;font-weight:700;margin:2px 0}
.box-label{font-size:10px;color:var(--w4)}
.study-card{background:linear-gradient(135deg,var(--n3),var(--n4));border-radius:16px;padding:16px;border:1px solid rgba(212,175,55,.25)}
.sc-title{font-family:var(--fd);font-size:15px;color:var(--w);margin-bottom:5px;letter-spacing:.5px}
.sc-sub{color:var(--w4);font-size:13px;margin-bottom:12px;line-height:1.5}
.sect-label{font-size:10px;color:var(--g2);font-family:var(--fd);letter-spacing:2px}
.practice-card{background:linear-gradient(135deg,rgba(74,144,217,.15),rgba(123,104,238,.1));border-radius:16px;padding:16px;border:1px solid rgba(74,144,217,.25)}

/* EXPLORE */
.explore-wrap{padding:0 14px 14px;display:flex;flex-direction:column;gap:10px}
.level-card{background:var(--n3);border-radius:16px;overflow:hidden;border:1px solid var(--w08)}
.level-header{display:flex;align-items:center;gap:11px;padding:13px 14px;cursor:pointer;-webkit-tap-highlight-color:transparent}
.level-emoji-bg{width:38px;height:38px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:19px;flex-shrink:0}
.level-info{flex:1}
.level-name{font-family:var(--fd);font-size:13px;color:var(--w);letter-spacing:.5px}
.level-meta{font-size:11px;color:var(--w4);margin-top:2px}
.chevron{color:var(--w4);font-size:18px;transition:transform .25s;display:inline-block}
.chevron.open{transform:rotate(90deg)}
.sets-wrap{overflow:hidden;transition:max-height .3s ease}
.set-row{margin:0 10px 7px;background:var(--w08);border-radius:12px;padding:11px 12px;display:flex;align-items:flex-start;gap:10px;border:1px solid transparent;transition:border-color .2s,background .2s}
.set-row.active{border-color:rgba(212,175,55,.3);background:rgba(212,175,55,.06)}
.set-info{flex:1}
.set-name{font-size:13px;color:var(--w9);font-weight:600}
.set-meta{font-size:11px;color:var(--w4);margin-top:1px}
.set-prog{height:3px;background:var(--w15);border-radius:2px;margin-top:5px;overflow:hidden}
.set-prog-bar{height:100%;border-radius:2px;transition:width .5s}
.toggle{width:42px;height:22px;border-radius:11px;border:none;cursor:pointer;position:relative;transition:background .25s;flex-shrink:0}
.toggle::after{content:'';position:absolute;top:2px;left:2px;width:18px;height:18px;border-radius:50%;background:white;transition:transform .25s;box-shadow:0 1px 4px rgba(0,0,0,.3)}
.toggle.on{background:var(--g2)}
.toggle.on::after{transform:translateX(20px)}
.toggle.off{background:rgba(255,255,255,.2)}

/* BOX DETAIL */
.box-detail-wrap{padding:0 14px 14px;display:flex;flex-direction:column;gap:8px}
.word-item{background:var(--n3);border-radius:12px;padding:11px 13px;border:1px solid var(--w08)}
.word-item-en{font-weight:600;font-size:14px;color:var(--w9)}
.word-item-tr{font-size:12px;color:var(--w4);margin-top:2px}
.word-item-badge{font-size:10px;padding:2px 7px;border-radius:8px;font-family:var(--fd);letter-spacing:.5px;flex-shrink:0}

/* STUDY */
.study-screen{height:100%;display:flex;flex-direction:column;padding:0 18px}
.study-topbar{padding:calc(env(safe-area-inset-top,0px) + 44px) 0 10px;display:flex;align-items:center;gap:8px}
.study-counter{flex:1;text-align:center;font-family:var(--fd);font-size:12px;color:var(--w4);letter-spacing:1px}
.study-badge{padding:3px 9px;border-radius:20px;font-size:10px;font-family:var(--fd);letter-spacing:.5px}
.prog-wrap{height:3px;background:rgba(212,175,55,.15);border-radius:2px;overflow:hidden;margin-bottom:20px}
.prog-fill{height:100%;background:var(--g2);transition:width .4s ease;border-radius:2px}
.fc-wrap{flex:1;display:flex;align-items:center;perspective:1000px}
.fc{width:100%;height:300px;position:relative;transform-style:preserve-3d;cursor:pointer;-webkit-tap-highlight-color:transparent;transition:transform .5s cubic-bezier(.4,0,.2,1)}
.fc.flipped{transform:rotateY(180deg)}
.fc-face{position:absolute;inset:0;backface-visibility:hidden;-webkit-backface-visibility:hidden;border-radius:20px;display:flex;flex-direction:column;align-items:center;justify-content:center;padding:24px;border:1px solid rgba(212,175,55,.2)}
.fc-front{background:linear-gradient(145deg,var(--n3),var(--n4))}
.fc-back{background:linear-gradient(145deg,#1a3a5c,#1a3060);transform:rotateY(180deg);align-items:flex-start;justify-content:flex-start;overflow-y:auto}
.fc-back::-webkit-scrollbar{display:none}
.fc-word{font-family:var(--fd);font-size:32px;color:var(--w);text-align:center;letter-spacing:1px;line-height:1.2}
.fc-hint{font-size:11px;color:var(--w4);margin-top:14px;animation:pulse 2s ease-in-out infinite}
@keyframes pulse{0%,100%{opacity:.4}50%{opacity:.8}}
.fc-en{font-family:var(--fd);font-size:15px;color:var(--g2);margin-bottom:5px}
.fc-tr{font-family:var(--fd);font-size:19px;color:var(--w);margin-bottom:10px}
.fc-div{width:100%;height:1px;background:rgba(212,175,55,.2);margin:6px 0}
.fc-stitle{font-size:9px;color:var(--g2);font-family:var(--fd);letter-spacing:1px;margin-bottom:3px}
.fc-sbody{font-size:12px;color:var(--w7);line-height:1.5}
.fc-ssub{font-size:11px;color:var(--w4);font-style:italic;line-height:1.4;margin-top:2px}
.ans-btns{display:grid;grid-template-columns:1fr 1fr;gap:10px;padding:12px 0 20px}
.btn-wrong{background:rgba(229,57,53,.2);border:1px solid rgba(229,57,53,.4);color:#ff6b6b;border-radius:13px;padding:14px;font-family:var(--fd);font-size:12px;letter-spacing:1px;cursor:pointer;transition:all .2s;display:flex;align-items:center;justify-content:center;gap:7px}
.btn-correct{background:rgba(76,175,80,.2);border:1px solid rgba(76,175,80,.4);color:#81c784;border-radius:13px;padding:14px;font-family:var(--fd);font-size:12px;letter-spacing:1px;cursor:pointer;transition:all .2s;display:flex;align-items:center;justify-content:center;gap:7px}
.btn-wrong:active{background:rgba(229,57,53,.35);transform:scale(.97)}
.btn-correct:active{background:rgba(76,175,80,.35);transform:scale(.97)}
.flip-hint{text-align:center;padding:12px 0 20px;color:var(--w4);font-size:12px;animation:pulse 2s ease-in-out infinite}
.summary{display:flex;flex-direction:column;align-items:center;justify-content:center;height:100%;padding:28px;gap:6px}
.sum-emoji{font-size:68px;margin-bottom:6px}
.sum-title{font-family:var(--fd);font-size:22px;color:var(--g2);letter-spacing:1px;margin-bottom:20px}
.stat-row{display:flex;justify-content:space-between;width:100%;padding:7px 0;border-bottom:1px solid var(--w08)}
.stat-lbl{color:var(--w4);font-size:14px}
.stat-val{font-weight:700;font-family:var(--fd);font-size:14px}
.no-cards{display:flex;flex-direction:column;align-items:center;justify-content:center;height:100%;gap:10px;padding:36px;text-align:center}

/* STATS */
.stats-wrap{padding:0 14px 14px;display:flex;flex-direction:column;gap:12px}
.streak-card{background:linear-gradient(135deg,var(--n3),var(--n4));border-radius:16px;padding:18px;border:1px solid rgba(212,175,55,.25);display:flex;align-items:center}
.streak-num{font-family:var(--fd);font-size:44px;color:var(--g2);line-height:1}
.acc-bar{height:7px;background:var(--w15);border-radius:4px;overflow:hidden;margin-top:7px}
.acc-fill{height:100%;border-radius:4px;background:linear-gradient(90deg,var(--red),var(--g2),var(--green));transition:width .8s ease}
.sess-row{display:flex;align-items:center;padding:9px 12px;background:var(--n3);border-radius:10px;border:1px solid var(--w08);gap:10px}

/* SETTINGS */
.settings-wrap{padding:0 14px 14px;display:flex;flex-direction:column;gap:12px}
.scard{background:var(--n3);border-radius:16px;padding:16px;border:1px solid var(--w08)}
.srow{display:flex;align-items:center;gap:10px;margin-bottom:12px}
.s-icon{font-size:20px}
.s-info{flex:1}
.s-label{font-size:14px;color:var(--w);font-weight:600}
.s-sub{font-size:11px;color:var(--w4);margin-top:1px}
.slider-wrap{margin:6px 0 14px}
input[type=range]{-webkit-appearance:none;width:100%;height:4px;border-radius:2px;background:linear-gradient(90deg,var(--g2) var(--pct,50%),var(--w15) var(--pct,50%));outline:none}
input[type=range]::-webkit-slider-thumb{-webkit-appearance:none;width:20px;height:20px;border-radius:50%;background:var(--g2);cursor:pointer;box-shadow:0 2px 8px rgba(212,175,55,.4)}
.user-mgmt-item{display:flex;align-items:center;gap:10px;padding:10px 12px;background:var(--w08);border-radius:11px;margin-bottom:8px}
.save-badge{background:rgba(76,175,80,.15);border:1px solid rgba(76,175,80,.3);border-radius:10px;padding:9px 12px;display:flex;align-items:center;gap:7px;color:#81c784;font-size:13px;animation:fadeIn .2s}
@keyframes fadeIn{from{opacity:0}to{opacity:1}}

/* ADMIN */
.admin-wrap{padding:0 14px 14px;display:flex;flex-direction:column;gap:10px}
.admin-item{display:flex;align-items:center;gap:11px;padding:13px;background:var(--n3);border-radius:12px;border:1px solid var(--w08);cursor:pointer;-webkit-tap-highlight-color:transparent;transition:background .2s}
.admin-item:active{background:var(--n4)}
.admin-item-info{flex:1}
.admin-item-name{font-size:14px;color:var(--w9);font-weight:600}
.admin-item-sub{font-size:11px;color:var(--w4);margin-top:2px}
.del-btn{background:none;border:none;color:rgba(229,57,53,.5);font-size:17px;cursor:pointer;padding:3px;flex-shrink:0}
.del-btn:active{color:var(--red)}

/* MODAL */
.modal-overlay{position:fixed;inset:0;background:rgba(0,0,0,.7);display:flex;align-items:flex-end;justify-content:center;z-index:100;backdrop-filter:blur(4px);animation:fadeIn .2s}
.modal{background:var(--n2);border-radius:20px 20px 0 0;padding:22px 18px 36px;width:100%;max-width:430px;border-top:1px solid rgba(212,175,55,.2);animation:slideUp .25s ease-out;max-height:88vh;overflow-y:auto}
.modal::-webkit-scrollbar{display:none}
@keyframes slideUp{from{transform:translateY(100%)}to{transform:translateY(0)}}
.modal-title{font-family:var(--fd);font-size:17px;color:var(--g2);margin-bottom:16px;letter-spacing:1px}
.mi{width:100%;padding:12px 13px;background:var(--w08);border:1px solid rgba(212,175,55,.2);border-radius:10px;color:var(--w);font-family:var(--fb);font-size:15px;outline:none;margin-bottom:9px}
.mi:focus{border-color:var(--g2)}
.mi::placeholder{color:var(--w4)}
textarea.mi{resize:none;min-height:65px}
.modal-btns{display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-top:6px}
.emoji-grid{display:flex;flex-wrap:wrap;gap:7px;margin:6px 0}
.emoji-opt{width:38px;height:38px;border-radius:9px;border:1px solid var(--w15);background:var(--w08);font-size:18px;cursor:pointer;display:flex;align-items:center;justify-content:center;transition:all .15s}
.emoji-opt.sel{border-color:var(--g2);background:rgba(212,175,55,.15)}
.color-grid{display:flex;gap:7px;margin:6px 0;flex-wrap:wrap}
.color-opt{width:26px;height:26px;border-radius:7px;cursor:pointer;border:2px solid transparent;transition:border-color .15s}
.color-opt.sel{border-color:white}
.import-pre{background:var(--w08);border-radius:9px;padding:10px;font-family:monospace;font-size:10px;color:var(--w7);line-height:1.6;margin-bottom:10px;white-space:pre-wrap;word-break:break-all}
.mini-label{font-size:10px;color:var(--w4);font-family:var(--fd);letter-spacing:1px;margin:6px 0 4px}

/* RED BORDERED DAY BADGE */


/* GB INFO BUTTON */
.gb-info-btn{background:none;border:1px solid rgba(212,175,55,.3);border-radius:8px;color:var(--g2);font-family:var(--fd);font-size:10px;letter-spacing:.5px;padding:3px 9px;cursor:pointer;transition:all .2s;flex-shrink:0}
.gb-info-btn:active{background:rgba(212,175,55,.15)}
.gb-tooltip{background:var(--n2);border:1px solid rgba(212,175,55,.25);border-radius:12px;padding:12px 14px;font-size:12px;color:var(--w7);line-height:1.7;margin-top:6px}
.gb-tooltip b{color:var(--g2);font-family:var(--fd)}

/* TOAST */
.toast{position:fixed;bottom:90px;left:50%;transform:translateX(-50%);background:rgba(26,48,96,.97);border:1px solid rgba(212,175,55,.3);padding:9px 18px;border-radius:20px;font-size:13px;color:var(--w9);z-index:200;animation:toastIn .3s ease-out;white-space:nowrap;max-width:90vw;text-align:center}
@keyframes toastIn{from{opacity:0;transform:translateX(-50%) translateY(8px)}to{opacity:1;transform:translateX(-50%) translateY(0)}}
.admin-badge{background:rgba(212,175,55,.15);border:1px solid rgba(212,175,55,.3);border-radius:6px;padding:2px 7px;font-size:10px;color:var(--g2);font-family:var(--fd);letter-spacing:.5px}
.loading-screen{height:100%;display:flex;align-items:center;justify-content:center;font-size:36px;animation:bob 1.5s ease-in-out infinite}
.tab-title{font-size:10px;color:var(--w4);font-family:var(--fd);letter-spacing:2px;padding:4px 0}
.switch-user-btn{display:inline-flex;align-items:center;gap:5px;background:rgba(255,255,255,0.06);border:1px solid rgba(212,175,55,0.2);border-radius:20px;padding:4px 10px 4px 5px;color:var(--w7);font-size:11px;font-family:var(--fd);letter-spacing:.5px;cursor:pointer;transition:all .2s;margin-bottom:4px}
.switch-user-btn:active{background:rgba(26,48,96,0.95);border-color:var(--g2)}
.switch-user-avatar{width:20px;height:20px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:10px;font-weight:700;font-family:var(--fd)}
.switch-modal-user{display:flex;align-items:center;gap:12px;padding:12px 14px;background:var(--w08);border-radius:12px;border:1px solid transparent;cursor:pointer;transition:all .2s;margin-bottom:8px}
.switch-modal-user:active{background:var(--w15)}
.switch-modal-user.current{border-color:rgba(212,175,55,.3);background:rgba(212,175,55,.06)}
`;

// ── MAIN APP ──────────────────────────────────────────────────────────────────
export default function App() {
  const [ready,      setReady]      = useState(false);
  const [user,       setUser]       = useState(null);
  const [tab,        setTab]        = useState("home");
  const [study,      setStudy]      = useState(null);
  const [boxView,    setBoxView]    = useState(null);
  const [toast,      setToast]      = useState(null);
  const [switchOpen, setSwitchOpen] = useState(false);
  const [allUsers,   setAllUsers]   = useState([]);
  const [lang,       setLang]       = useState(() => (typeof window !== "undefined" ? localStorage.getItem("wv_lang") || "tr" : "tr"));
  const toastRef = useRef(null);

useEffect(() => {
  const fetchWords = async () => {
    try {
      setLoading(true);
      // Supabase 'words' tablosundaki tüm verileri çekiyoruz
      const { data, error } = await supabase
        .from('words')
        .select('*')
        .order('id', { ascending: true }); // ID sırasına göre diz

      if (error) throw error;

      if (data) {
        setWords(data);
      }
    } catch (error) {
      console.error('Veritabanından kelimeler çekilemedi:', error.message);
    } finally {
      setLoading(false);
    }
  };

  fetchWords();
}, []);

  const loadAllUsers = useCallback(() => {
    dAll("users").then(setAllUsers);
  }, []);

  useEffect(() => { if (user) loadAllUsers(); }, [user, loadAllUsers]);

  const showToast = useCallback((msg) => {
    setToast(msg);
    if (toastRef.current) clearTimeout(toastRef.current);
    toastRef.current = setTimeout(() => setToast(null), 2500);
  }, []);

  const handleLogin = (u) => {
    setUser(u);
    localStorage.setItem("wv_uid", u.id);
  };

  const handleLogout = () => {
    setUser(null);
    localStorage.removeItem("wv_uid");
    setStudy(null);
    setBoxView(null);
    setTab("home");
    setSwitchOpen(false);
  };

  // Switch to another user directly (non-admin: instant, admin: goes through auth)
  const handleSwitchUser = (u) => {
    setSwitchOpen(false);
    if (u.id === user?.id) return;
    // Non-admin users: switch instantly
    if (!u.isAdmin) {
      setUser(u);
      localStorage.setItem("wv_uid", u.id);
      setStudy(null);
      setBoxView(null);
      setTab("home");
      showToast(`${u.username} ${lang==="en"?"logged in":"olarak giriş yapıldı"}`);
    } else {
      // Admin: go to login screen so they can enter password
      handleLogout();
    }
  };

  const avatarColors = ["#4A90D9","#D4AF37","#50C878","#E53935","#9B59B6","#FF6B35"];

  if (!ready) return <div className="app"><style>{CSS}</style><div className="loading-screen">⚓</div></div>;

  if (!user) return (
    <div className="app">
      <style>{CSS}</style>
      <div className="screen"><AuthScreen onLogin={handleLogin} /></div>
    </div>
  );

  if (study) return (
    <div className="app">
      <style>{CSS}</style>
      <StudyScreen user={user} session={study} lang={lang} onDone={(saved) => { setStudy(null); if (saved) showToast(lang==="en"?"Session saved ✓":"Oturum kaydedildi ✓"); }} onBack={() => setStudy(null)} showToast={showToast} />
      {toast && <div className="toast">{toast}</div>}
    </div>
  );

  if (boxView) return (
    <div className="app">
      <style>{CSS}</style>
      <div className="screen"><BoxDetailScreen user={user} box={boxView} lang={lang} onBack={() => setBoxView(null)} /></div>
      {toast && <div className="toast">{toast}</div>}
    </div>
  );

  const tabs = [
    {id:"home",icon:"⚓",label:lang==="en"?"Home":"Ana"},
    {id:"explore",icon:"🗺",label:lang==="en"?"Explore":"Keşfet"},
    {id:"stats",icon:"📊",label:lang==="en"?"Stats":"İstatistik"},
    {id:"settings",icon:"⚙️",label:lang==="en"?"Settings":"Ayarlar"},
    ...(user.isAdmin?[{id:"admin",icon:"🛡",label:"Admin"}]:[]),
  ];

  return (
    <div className="app">
      <style>{CSS}</style>

      <div className="screen">
        {tab==="home"     && <HomeScreen     user={user} lang={lang} onStartStudy={setStudy} onBoxView={setBoxView} onSwitchUser={()=>{ loadAllUsers(); setSwitchOpen(true); }} showToast={showToast} />}
        {tab==="explore"  && <ExploreScreen  user={user} lang={lang} showToast={showToast} />}
        {tab==="stats"    && <StatsScreen    user={user} lang={lang} />}
        {tab==="settings" && <SettingsScreen user={user} lang={lang} onLangChange={setLang} onUserUpdate={(u)=>{ setUser(u); localStorage.setItem("wv_uid",u.id); dPut("users",u); }} onLogout={handleLogout} onSwitchUser={()=>{ loadAllUsers(); setSwitchOpen(true); }} showToast={showToast} />}
        {tab==="admin" && user.isAdmin && <AdminScreen user={user} lang={lang} showToast={showToast} />}
      </div>

      <nav className="bnav">
        {tabs.map(n=>(
          <button key={n.id} className={`ni ${tab===n.id?"active":""}`} onClick={()=>setTab(n.id)}>
            <span className="ni-icon">{n.icon}</span>
            <span className="ni-label">{n.label}</span>
          </button>
        ))}
      </nav>

      {/* ── Kullanıcı değiştir modalı ── */}
      {switchOpen && (
        <div className="modal-overlay" onClick={() => setSwitchOpen(false)}>
          <div className="modal" onClick={e => e.stopPropagation()}>
            <div className="modal-title">{lang==="en"?"SWITCH USER":"KULLANICI DEĞİŞTİR"}</div>
            {allUsers.map((u, i) => (
              <div key={u.id}
                className={`switch-modal-user ${u.id === user.id ? "current" : ""}`}
                onClick={() => handleSwitchUser(u)}
              >
                <div className="switch-user-avatar" style={{width:36,height:36,fontSize:15,background:avatarColors[i%avatarColors.length]+"33",color:avatarColors[i%avatarColors.length],border:`1px solid ${avatarColors[i%avatarColors.length]}66`}}>
                  {u.username.charAt(0).toUpperCase()}
                </div>
                <div style={{flex:1}}>
                  <div style={{fontSize:15,color:"var(--w9)",fontWeight:600}}>{u.username}</div>
                  {u.isAdmin && <div style={{fontSize:10,color:"var(--g2)",fontFamily:"var(--fd)",letterSpacing:1}}>{lang==="en"?"ADMIN · Password required":"ADMİN · Şifre gerekli"}</div>}
                </div>
                {u.id === user.id && <div style={{fontSize:11,color:"var(--g2)",fontFamily:"var(--fd)"}}>{lang==="en"?"ACTIVE":"AKTİF"}</div>}
              </div>
            ))}
            <button className="btn btn-red" style={{marginTop:8}} onClick={handleLogout}>{lang==="en"?"LOG OUT":"ÇIKIŞ YAP"}</button>
          </div>
        </div>
      )}

      {toast && <div className="toast">{toast}</div>}
    </div>
  );
}

// ── AUTH SCREEN ───────────────────────────────────────────────────────────────
function AuthScreen({ onLogin }) {
  const [users, setUsers]         = useState([]);
  const [mode,  setMode]          = useState("select"); // select | admin | addUser | userPass
  const [adminPass, setAdminPass] = useState("");
  const [userPass,  setUserPass]  = useState("");
  const [newName, setNewName]     = useState("");
  const [error, setError]         = useState("");
  const [selectedUser, setSelectedUser] = useState(null);
  const lang = getLang();

  useEffect(() => { dAll("users").then(setUsers); }, []);

  const selectUser = (u) => {
    if (u.isAdmin) { setMode("admin"); setError(""); return; }
    // Non-admin with password set
    if (u.passwordHash) { setMode("userPass"); setSelectedUser(u); setError(""); return; }
    onLogin(u);
  };

  const adminLogin = async () => {
    const admins = users.filter(u=>u.isAdmin);
    const admin  = admins.find(u=>u.passwordHash===adminPass);
    if (!admin) { setError(lang==="en"?"Incorrect password.":"Şifre hatalı."); return; }
    onLogin(admin);
  };

  const addUser = async () => {
    const name = newName.trim();
    if (!name) { setError(lang==="en"?"Name cannot be empty.":"İsim boş olamaz."); return; }
    if (users.find(u=>u.username.toLowerCase()===name.toLowerCase())) { setError(lang==="en"?"This name already exists.":"Bu isim zaten var."); return; }
    const id = await dAdd("users", {
    username: name,
    passwordHash: "",
    isAdmin: false,
    dailyGoal: 15,
    createdAt: Date.now(),
    currentStreak: 0,
    longestStreak: 0
  });
    const newUser = await dGet("users",id);
    onLogin(newUser);
  };

  const avatarColors = ["#4A90D9","#D4AF37","#50C878","#E53935","#9B59B6","#FF6B35"];

  if (mode==="userPass" && selectedUser) return (
    <div className="auth-bg">
      <div className="auth-anchor">🔒</div>
      <div className="auth-title">{selectedUser.username.toUpperCase()}</div>
      <div className="auth-sub">{lang==="en"?"Enter your password":"Şifrenizi girin"}</div>
      <div className="auth-form" style={{width:"100%",maxWidth:320}}>
        <div className="field"><label>{lang==="en"?"PASSWORD":"ŞİFRE"}</label><input type="password" placeholder="••••••" value={userPass} onChange={e=>setUserPass(e.target.value)} onKeyDown={e=>{if(e.key==="Enter"){if(selectedUser.passwordHash===userPass){onLogin(selectedUser);}else{setError(lang==="en"?"Incorrect password.":"Şifre hatalı.");}}}} autoFocus /></div>
        {error && <div className="auth-err">{error}</div>}
        <button className="btn btn-gold" onClick={()=>{if(selectedUser.passwordHash===userPass){onLogin(selectedUser);}else{setError(lang==="en"?"Incorrect password.":"Şifre hatalı.");}}}>{lang==="en"?"LOGIN":"GİRİŞ"}</button>
        <button className="back-link" onClick={()=>{setMode("select");setError("");setUserPass("");}}>← {lang==="en"?"Back":"Geri"}</button>
      </div>
    </div>
  );

  if (mode==="admin") return (
    <div className="auth-bg">
      <div className="auth-anchor">🛡</div>
      <div className="auth-title">ADMIN</div>
      <div className="auth-sub">{lang==="en"?"Enter your password":"Şifrenizi girin"}</div>
      <div className="auth-form" style={{width:"100%",maxWidth:320}}>
        <div className="field"><label>{lang==="en"?"PASSWORD":"ŞİFRE"}</label><input type="password" placeholder="••••••" value={adminPass} onChange={e=>setAdminPass(e.target.value)} onKeyDown={e=>e.key==="Enter"&&adminLogin()} autoFocus /></div>
        {error && <div className="auth-err">{error}</div>}
        <button className="btn btn-gold" onClick={adminLogin}>{lang==="en"?"LOGIN":"GİRİŞ"}</button>
        <button className="back-link" onClick={()=>{setMode("select");setError("");}}>← {lang==="en"?"Back":"Geri"}</button>
      </div>
    </div>
  );

  if (mode==="addUser") return (
    <div className="auth-bg">
      <div className="auth-anchor">👤</div>
      <div className="auth-title">{lang==="en"?"NEW USER":"YENİ KULLANICI"}</div>
      <div className="auth-sub">{lang==="en"?"Enter your name, treasure awaits":"Adını gir, hazine seni bekliyor"}</div>
      <div style={{width:"100%",maxWidth:320}}>
        <div className="field"><label>{lang==="en"?"USERNAME":"KULLANICI ADI"}</label><input placeholder={lang==="en"?"Your name":"Adın"} value={newName} onChange={e=>setNewName(e.target.value)} onKeyDown={e=>e.key==="Enter"&&addUser()} autoFocus /></div>
        {error && <div className="auth-err">{error}</div>}
        <button className="btn btn-gold" onClick={addUser} style={{marginBottom:8}}>{lang==="en"?"START":"BAŞLA"}</button>
        <button className="back-link" onClick={()=>{setMode("select");setError("");}}>← {lang==="en"?"Back":"Geri"}</button>
      </div>
    </div>
  );

  return (
    <div className="auth-bg">
      <div className="auth-anchor">⚓</div>
      <div className="auth-title">WORDVAULT</div>
      <div className="auth-sub">{lang==="en"?"Whose treasure?":"Kimin hazinesi?"}</div>
      <div className="user-list" style={{maxWidth:320,width:"100%"}}>
        {users.map((u,i)=>(
          <button key={u.id} className="user-btn" onClick={()=>selectUser(u)}>
            <div className="user-avatar" style={{background:avatarColors[i%avatarColors.length]+"33",color:avatarColors[i%avatarColors.length],border:`1px solid ${avatarColors[i%avatarColors.length]}66`}}>
              {u.username.charAt(0).toUpperCase()}
            </div>
            <span className="user-name">{u.username}</span>
            {u.isAdmin && <span className="user-admin-tag">ADMIN</span>}
          </button>
        ))}
        <button className="add-user-btn" onClick={()=>{setMode("addUser");setError("");}}>{lang==="en"?"＋ Add New User":"＋ Yeni Kullanıcı Ekle"}</button>
      </div>
    </div>
  );
}

// ── HOME SCREEN ───────────────────────────────────────────────────────────────
function HomeScreen({ user, lang, onStartStudy, onBoxView, onSwitchUser, showToast }) {
  const [counts, setCounts]   = useState({daily:0,weekly:0,monthly:0,activeSets:0,weeklyReady:0,monthlyReady:0,nextWeeklyDays:null,nextMonthlyDays:null});
  const [actSets, setActSets] = useState([]);
  const [allSets, setAllSets] = useState([]);

  const reload = useCallback(async () => {
    const [timing, acts, sets] = await Promise.all([
      getBoxCountsWithTiming(user.id),
      dIdx("active_sets","userId",user.id),
      dAll("wordsets")
    ]);
    setCounts({ ...timing, activeSets:acts.length });
    setActSets(acts);
    setAllSets(sets);
  }, [user.id]);

  useEffect(() => { reload(); }, [reload]);

  const activeSetsData = actSets.map(a=>allSets.find(s=>s.id===a.wordSetId)).filter(Boolean);

  const weeklyReady  = counts.weeklyReady  || 0;
  const monthlyReady = counts.monthlyReady || 0;
  const dailyCanStudy   = counts.activeSets>0 && (counts.dailyReady||0)>0;
  const weeklyCanStudy  = weeklyReady>0;
  const monthlyCanStudy = monthlyReady>0;

  const startPractice = async () => {
    if (!activeSetsData.length) { showToast("Önce Keşfet'ten set seç"); return; }
    const setIds = activeSetsData.map(s=>s.id);
    const words  = await getPracticeWords(user.id, setIds);
    if (!words.length) { showToast("Aktif setlerde kelime yok"); return; }
    onStartStudy({type:"PRACTICE", words});
  };

  return (
    <>
      <div className="greeting">
        <button className="switch-user-btn" onClick={onSwitchUser}>
          <div className="switch-user-avatar" style={{width:20,height:20,fontSize:10,background:'rgba(212,175,55,0.15)',color:'var(--g2)',border:'1px solid rgba(212,175,55,0.3)'}}>
            {user.username.charAt(0).toUpperCase()}
          </div>
          {user.username}
        </button>
        <div className="g-sub">{lang==="en"?"Hello,":"Merhaba,"}</div>
        <div className="g-name">{user.username}</div>
      </div>
      <div className="home-wrap">
        {/* Boxes */}
        <div>
          <div className="tab-title">{lang==="en"?"WORD BOXES":"KELİME KUTULARI"}</div>
          <div className="boxes-row" style={{marginTop:6}}>
            <div className="box-card" onClick={()=>onBoxView("DAILY")} style={{position:"relative"}}>
              <div className="box-emoji">📅</div>
              <div className="box-count" style={{color:"#4a90d9"}}>{counts.daily||0}</div>
              <div className="box-label">{lang==="en"?"Daily":"Günlük"}</div>
              {(counts.dailyReady||0)>0 && <div style={{position:"absolute",top:6,right:6,width:8,height:8,borderRadius:"50%",background:"#4a90d9"}}/> }
              {counts.daily>0 && (counts.dailyReady||0)===0 && counts.nextDailyHours && (
                <div style={getDayBadgeStyle(1)}>{lang==="en"?"1 day":"1 gün"}</div>
              )}
            </div>
            <div className="box-card" onClick={()=>onBoxView("WEEKLY")} style={{position:"relative"}}>
              <div className="box-emoji">📆</div>
              <div className="box-count" style={{color:"#7b68ee"}}>{counts.weekly||0}</div>
              <div className="box-label">{lang==="en"?"Weekly":"Haftalık"}</div>
              {counts.weeklyReady>0 && <div style={{position:"absolute",top:6,right:6,width:8,height:8,borderRadius:"50%",background:"#7b68ee"}}/>}
              {counts.weekly>0 && counts.weeklyReady===0 && counts.nextWeeklyDays!=null && (
                <div style={getDayBadgeStyle(counts.nextWeeklyDays)}>{counts.nextWeeklyDays}{lang==="en"?"d":"g"}</div>
              )}
            </div>
            <div className="box-card" onClick={()=>onBoxView("MONTHLY")} style={{position:"relative"}}>
              <div className="box-emoji">🗓</div>
              <div className="box-count" style={{color:"#4caf50"}}>{counts.monthly||0}</div>
              <div className="box-label">{lang==="en"?"Monthly":"Aylık"}</div>
              {counts.monthlyReady>0 && <div style={{position:"absolute",top:6,right:6,width:8,height:8,borderRadius:"50%",background:"#4caf50"}}/>}
              {counts.monthly>0 && counts.monthlyReady===0 && counts.nextMonthlyDays!=null && (
                <div style={getDayBadgeStyle(counts.nextMonthlyDays)}>{counts.nextMonthlyDays}{lang==="en"?"d":"g"}</div>
              )}
            </div>
          </div>
        </div>

        {/* Günlük çalışma */}
        <div className="study-card">
          <div className="sc-title">{lang==="en"?"Daily Study 📚":"Günlük Çalışma 📚"}</div>
          <div className="sc-sub">
            {counts.activeSets===0 ? (lang==="en"?"Select a word set from Explore.":"Keşfet'ten kelime seti seç.") :
             counts.daily===0     ? (lang==="en"?"All daily words learned 🎉":"Tüm günlük kelimeler öğrenildi 🎉") :
             (counts.dailyReady||0)===0 && counts.nextDailyHours
               ? (lang==="en"?`${counts.daily} words — wrong ones retry tomorrow.`:`${counts.daily} kelime var — yanlışlar yarın tekrar çıkar.`)
               : (lang==="en"?`${counts.dailyReady||counts.daily} words ready.`:`${counts.dailyReady||counts.daily} kelime hazır.`)}
          </div>
          {dailyCanStudy && (
            <button className="btn btn-gold" onClick={async()=>{
              const words = await getStudyWords(user.id,user.dailyGoal,"DAILY_STUDY");
              if (!words.length){showToast(lang==="en"?"All words retry tomorrow!":"Tüm kelimeler yarın tekrar çıkacak!");return;}
              onStartStudy({type:"DAILY_STUDY",words});
            }}>{lang==="en"?"START STUDYING":"ÇALIŞMAYA BAŞLA"}</button>
          )}
        </div>

        {/* Haftalık sınav — sadece 7+ gün bekleyen varsa */}
        {counts.weekly>0 && (
          <div className="study-card" style={{borderColor:"rgba(74,144,217,0.3)"}}>
            <div className="sc-title" style={{color:"#7ab8f5"}}>{lang==="en"?"Weekly Exam 🎓":"Haftalık Sınav 🎓"}</div>
            <div className="sc-sub">
              {weeklyCanStudy
                ? (lang==="en"?`${weeklyReady} words ready. (${counts.weekly} total in weekly)`:`${weeklyReady} kelime hazır. (toplam ${counts.weekly} haftalıkta)`)
                : (lang==="en"?`${counts.weekly} words waiting — ready in `:`${counts.weekly} kelime bekleniyor — `)}
              {!weeklyCanStudy && <span style={{...getDayBadgeStyle(counts.nextWeeklyDays),fontSize:10,verticalAlign:"middle"}}>{counts.nextWeeklyDays}{lang==="en"?" days":" gün"}</span>}
            </div>
            {weeklyCanStudy && (
              <button className="btn" style={{background:"rgba(74,144,217,0.25)",border:"1px solid rgba(74,144,217,0.5)",color:"#7ab8f5",fontFamily:"var(--fd)",fontSize:12,letterSpacing:1}}
                onClick={async()=>{
                  const words = await getStudyWords(user.id,user.dailyGoal,"WEEKLY_REVIEW");
                  if (!words.length){showToast(lang==="en"?"No words found":"Kelime bulunamadı");return;}
                  onStartStudy({type:"WEEKLY_REVIEW",words});
                }}>{lang==="en"?"TAKE EXAM":"SINAVA GİR"}</button>
            )}
          </div>
        )}

        {/* Aylık tekrar — sadece 30+ gün bekleyen varsa */}
        {counts.monthly>0 && (
          <div className="study-card" style={{borderColor:"rgba(155,89,182,0.3)"}}>
            <div className="sc-title" style={{color:"#c39bd3"}}>{lang==="en"?"Monthly Review 🗓":"Aylık Tekrar 🗓"}</div>
            <div className="sc-sub">
              {monthlyCanStudy
                ? (lang==="en"?`${monthlyReady} words ready. (${counts.monthly} total in monthly)`:`${monthlyReady} kelime hazır. (toplam ${counts.monthly} aylıkta)`)
                : (lang==="en"?`${counts.monthly} words waiting — ready in `:`${counts.monthly} kelime bekleniyor — `)}
              {!monthlyCanStudy && <span style={{...getDayBadgeStyle(counts.nextMonthlyDays),fontSize:10,verticalAlign:"middle"}}>{counts.nextMonthlyDays}{lang==="en"?" days":" gün"}</span>}
            </div>
            {monthlyCanStudy && (
              <button className="btn" style={{background:"rgba(155,89,182,0.25)",border:"1px solid rgba(155,89,182,0.5)",color:"#c39bd3",fontFamily:"var(--fd)",fontSize:12,letterSpacing:1}}
                onClick={async()=>{
                  const words = await getStudyWords(user.id,user.dailyGoal,"MONTHLY_REVIEW");
                  if (!words.length){showToast(lang==="en"?"No words found":"Kelime bulunamadı");return;}
                  onStartStudy({type:"MONTHLY_REVIEW",words});
                }}>{lang==="en"?"START REVIEW":"TEKRARA BAŞLA"}</button>
            )}
          </div>
        )}

        {/* Practice */}
        {activeSetsData.length > 0 && (
          <div className="practice-card">
            <div className="sc-title" style={{color:"#4a90d9"}}>{lang==="en"?"Practice 🎲":"Pratik Yap 🎲"}</div>
            <div className="sc-sub">{lang==="en"?"Study randomly from your active sets without categories.":"Aktif setlerinden rastgele kelimelerle kategorisiz çalış."}</div>
            <button className="btn" style={{background:"rgba(74,144,217,.25)",border:"1px solid rgba(74,144,217,.4)",color:"#7ab8f5",fontFamily:"var(--fd)",fontSize:12,letterSpacing:1}} onClick={startPractice}>{lang==="en"?"START PRACTICE":"PRATİK BAŞLAT"}</button>
          </div>
        )}
      </div>
    </>
  );
}

// ── BOX DETAIL SCREEN ─────────────────────────────────────────────────────────
function BoxDetailScreen({ user, box, lang, onBack }) {
  const [items, setItems] = useState([]);
  const boxLabels = lang==="en"
    ? {DAILY:"📅 Daily Box",WEEKLY:"📆 Weekly Box",MONTHLY:"🗓 Monthly Box"}
    : {DAILY:"📅 Günlük Kutu",WEEKLY:"📆 Haftalık Kutu",MONTHLY:"🗓 Aylık Kutu"};
  const boxColors = BOX_COLORS;

  const [progMap, setProgMap] = useState({});

  useEffect(() => {
    const load = async () => {
      const prog  = await dIdx("progress","userId",user.id);
      const boxed = prog.filter(p=>p.box===box);
      const pm = {};
      boxed.forEach(p=>{ pm[p.wordId]=p; });
      setProgMap(pm);
      const words = await Promise.all(boxed.map(p=>dGet("words",p.wordId)));
      setItems(words.filter(Boolean));
    };
    load();
  }, [user.id, box]);

  const getDaysLeft = (w) => {
    const p = progMap[w.id];
    if (!p) return null;
    if (box==="DAILY")   return daysUntilDaily(p);
    if (box==="WEEKLY")  return daysUntilWeekly(p);
    if (box==="MONTHLY") return daysUntilMonthly(p);
    return null;
  };

  return (
    <>
      <div className="topbar">
        <button className="icon-btn" onClick={onBack}>‹</button>
        <div>
          <div className="topbar-title">{boxLabels[box]}</div>
          <div className="topbar-sub">{items.length} {lang==="en"?"words":"kelime"}</div>
        </div>
      </div>
      <div className="box-detail-wrap">
        {items.length===0 && <div style={{textAlign:"center",padding:"32px 0",color:"var(--w4)"}}>{lang==="en"?"No words in this box yet.":"Bu kutuda henüz kelime yok."}</div>}
        {items.map(w=>{
          const daysLeft = getDaysLeft(w);
          const isReady  = daysLeft === 0 || daysLeft === null;
          const bx = boxColors[box];
          return (
            <div key={w.id} className="word-item" style={{display:"flex",alignItems:"center",gap:10}}>
              <div style={{flex:1}}>
                <div className="word-item-en">{w.english}</div>
                <div className="word-item-tr">{w.turkish}</div>
              </div>
              <div style={{textAlign:"right",flexShrink:0}}>
                {isReady ? (
                  <div className="word-item-badge" style={{background:bx+"22",color:bx,border:`1px solid ${bx}44`}}>{lang==="en"?"Ready ✓":"Hazır ✓"}</div>
                ) : (
                  <div style={getDayBadgeStyle(box==="DAILY"?1:daysLeft)}>{box==="DAILY"?(lang==="en"?"1 day":"1 gün"):`${daysLeft}${lang==="en"?"d":"g"}`}</div>
                )}
              </div>
            </div>
          );
        })}
      </div>
    </>
  );
}

// ── EXPLORE SCREEN ────────────────────────────────────────────────────────────
function ExploreScreen({ user, lang, showToast }) {
  const [levels, setLevels]     = useState([]);
  const [setsMap, setSetsMap]   = useState({});
  const [wordsMap, setWordsMap] = useState({}); // setId → words[]
  const [wCount, setWCount]     = useState({});
  const [actIds, setActIds]     = useState(new Set());
  const [expanded, setExpanded] = useState({});
  const [expandedSet, setExpandedSet] = useState({}); // setId → bool (word list open)
  const [searchQ, setSearchQ]   = useState("");
  const [searchMode, setSearchMode] = useState(false);
  const [searchResults, setSearchResults] = useState([]);
  const [allWords, setAllWords] = useState([]);

  const load = useCallback(async () => {
    const [lvls,sets,words,acts] = await Promise.all([dAll("levels"),dAll("wordsets"),dAll("words"),dIdx("active_sets","userId",user.id)]);
    setLevels(lvls.sort((a,b)=>(a.orderIndex||0)-(b.orderIndex||0)));
    const sm={};  sets.forEach(s=>{if(!sm[s.levelId])sm[s.levelId]=[];sm[s.levelId].push(s);});
    setSetsMap(sm);
    const wc={}; words.forEach(w=>{wc[w.wordSetId]=(wc[w.wordSetId]||0)+1;});
    setWCount(wc);
    // Group words by set
    const wm={};
    words.forEach(w=>{if(!wm[w.wordSetId])wm[w.wordSetId]=[];wm[w.wordSetId].push(w);});
    setWordsMap(wm);
    setAllWords(words);
    setActIds(new Set(acts.map(a=>a.wordSetId)));
  },[user.id]);

  useEffect(()=>{load();},[load]);

  const toggle = async (setId, words_count) => {
    if (actIds.has(setId)) {
      await deactivateSet(user.id, setId);
      showToast(lang==="en"?"Set disabled — words removed":"Set devre dışı — kelimeler kaldırıldı");
    } else {
      await activateSet(user.id, setId);
      showToast(lang==="en"?`Set active — ${words_count||0} words added`:`Set aktif — ${words_count||0} kelime eklendi`);
    }
    await load();
  };

  const doSearch = (q) => {
    const query = q.trim().toLowerCase();
    if (!query) { setSearchResults([]); return; }
    const results = allWords.filter(w =>
      w.english.toLowerCase().includes(query) ||
      w.turkish.toLowerCase().includes(query)
    ).slice(0, 40);
    setSearchResults(results);
  };

  const handleSearchChange = (e) => {
    const q = e.target.value;
    setSearchQ(q);
    doSearch(q);
  };

  return (
    <>
      <div className="topbar" style={{gap:6}}>
        <div style={{flex:1}}>
          <div className="topbar-title">{lang==="en"?"Word Sets":"Kelime Setleri"}</div>
          <div className="topbar-sub">{actIds.size} {lang==="en"?"active sets selected":"aktif set seçili"}</div>
        </div>
        <button className="icon-btn" style={{fontSize:16}} onClick={()=>{setSearchMode(s=>!s);setSearchQ("");setSearchResults([]); }}>🔍</button>
      </div>

      {searchMode && (
        <div style={{padding:"0 14px 8px"}}>
          <input
            className="mi"
            style={{marginBottom:0,padding:"10px 14px",fontSize:14}}
            placeholder={lang==="en"?"Search word...":"Kelime ara..."}
            value={searchQ}
            onChange={handleSearchChange}
            autoFocus
          />
        </div>
      )}

      <div className="explore-wrap">
        {/* SEARCH RESULTS */}
        {searchMode && searchQ.trim() && (
          <>
            <div className="tab-title">{searchResults.length} {lang==="en"?"RESULTS":"SONUÇ"}</div>
            {searchResults.length===0 && <div style={{textAlign:"center",padding:"20px 0",color:"var(--w4)"}}>{lang==="en"?"No words found.":"Kelime bulunamadı."}</div>}
            {searchResults.map(w=>(
              <WordCard key={w.id} word={w} lang={lang}/>
            ))}
          </>
        )}

        {/* NORMAL LIST */}
        {(!searchMode || !searchQ.trim()) && <>
          {levels.length===0 && <div style={{textAlign:"center",padding:"40px 0",color:"var(--w4)"}}>
            <div style={{fontSize:44,marginBottom:10}}>📭</div>
            <div>{lang==="en"?"Admin hasn't added sets yet.":"Admin henüz set eklemedi."}</div>
          </div>}
          {levels.map(level=>{
            const sets = (setsMap[level.id]||[]).sort((a,b)=>(a.orderIndex||0)-(b.orderIndex||0));
            const isOpen = expanded[level.id];
            const activeCnt = sets.filter(s=>actIds.has(s.id)).length;
            const bgColor = level.color||"#4A90D9";
            return (
              <div key={level.id} className="level-card">
                <div className="level-header" onClick={()=>setExpanded(e=>({...e,[level.id]:!e[level.id]}))}>
                  <div className="level-emoji-bg" style={{background:bgColor+"2a"}}>{level.iconEmoji||"📚"}</div>
                  <div className="level-info">
                    <div className="level-name">{level.name}</div>
                    <div className="level-meta">{sets.length} {lang==="en"?"sets":"set"} {activeCnt>0&&<span style={{color:bgColor,marginLeft:4}}>{activeCnt} {lang==="en"?"active":"aktif"}</span>}</div>
                  </div>
                  <span className={`chevron ${isOpen?"open":""}`}>›</span>
                </div>
                <div className="sets-wrap" style={{maxHeight:isOpen?"9999px":0}}>
                  {sets.map(set=>{
                    const total  = wCount[set.id]||0;
                    const isAct  = actIds.has(set.id);
                    const setWordsOpen = expandedSet[set.id];
                    const setWordsList = wordsMap[set.id]||[];
                    return (
                      <div key={set.id} className={`set-row ${isAct?"active":""}`} style={{flexDirection:"column",alignItems:"stretch",gap:0}}>
                        <div style={{display:"flex",alignItems:"center",gap:10}}>
                          <div className="set-info" style={{flex:1}}>
                            <div className="set-name">{set.name}</div>
                            <div className="set-meta">{total} {lang==="en"?"words":"kelime"}{set.description?` · ${set.description}`:""}</div>
                          </div>
                          <button
                            style={{background:"none",border:"none",color:"var(--w4)",fontSize:13,cursor:"pointer",padding:"2px 6px",fontFamily:"var(--fd)",letterSpacing:.3,flexShrink:0}}
                            onClick={e=>{e.stopPropagation();setExpandedSet(s=>({...s,[set.id]:!s[set.id]}));}}
                          >{setWordsOpen?"▲":"▼"}</button>
                          <button className={`toggle ${isAct?"on":"off"}`} onClick={()=>toggle(set.id, total)} />
                        </div>
                        {setWordsOpen && (
                          <div style={{marginTop:8,borderTop:"1px solid rgba(255,255,255,0.07)",paddingTop:6,display:"flex",flexDirection:"column",gap:4,width:"100%"}}>
                            {setWordsList.length===0 && <div style={{color:"var(--w4)",fontSize:12,padding:"6px 0",textAlign:"center"}}>{lang==="en"?"No words yet.":"Kelime yok."}</div>}
                            {setWordsList.map(w=><WordCard key={w.id} word={w} lang={lang} compact/>)}
                          </div>
                        )}
                      </div>
                    );
                  })}
                  <div style={{height:6}}/>
                </div>
              </div>
            );
          })}
        </>}
      </div>
    </>
  );
}

// ── WORD CARD (Explore & Search) ──────────────────────────────────────────────
function WordCard({ word, lang, compact }) {
  const [open, setOpen] = useState(false);
  if (compact) return (
    <div onClick={()=>setOpen(o=>!o)} style={{padding:"6px 4px",cursor:"pointer",borderRadius:8,transition:"background .15s"}} >
      <div style={{display:"flex",alignItems:"center",gap:8}}>
        <div style={{flex:1}}>
          <span style={{fontSize:13,color:"var(--w9)",fontWeight:600}}>{word.english}</span>
          <span style={{fontSize:12,color:"var(--w4)",marginLeft:6}}>{word.turkish}</span>
        </div>
        <span style={{fontSize:11,color:"var(--w4)"}}>{open?"▲":"▼"}</span>
      </div>
      {open && <WordDetail word={word} lang={lang}/>}
    </div>
  );
  return (
    <div className="word-item" onClick={()=>setOpen(o=>!o)} style={{cursor:"pointer"}}>
      <div style={{display:"flex",alignItems:"center",gap:8}}>
        <div style={{flex:1}}>
          <div className="word-item-en">{word.english}</div>
          <div className="word-item-tr">{word.turkish}</div>
        </div>
        <span style={{fontSize:13,color:"var(--w4)"}}>{open?"▲":"▼"}</span>
      </div>
      {open && <WordDetail word={word} lang={lang}/>}
    </div>
  );
}

function WordDetail({ word, lang }) {
  return (
    <div style={{marginTop:8,paddingTop:8,borderTop:"1px solid rgba(212,175,55,0.12)"}}>
      {word.ydsExampleSentence && <>
        <div style={{fontSize:9,color:"var(--g2)",fontFamily:"var(--fd)",letterSpacing:1,marginBottom:2}}>📝 {lang==="en"?"YDS EXAMPLE":"YDS ÖRNEĞİ"}</div>
        <div style={{fontSize:12,color:"var(--w7)",lineHeight:1.5,marginBottom:3}}>{word.ydsExampleSentence}</div>
        {word.ydsExampleTranslation && <div style={{fontSize:11,color:"var(--w4)",fontStyle:"italic",lineHeight:1.4,marginBottom:6}}>{word.ydsExampleTranslation}</div>}
      </>}
      {word.mnemonicTip && <>
        <div style={{fontSize:9,color:"var(--g2)",fontFamily:"var(--fd)",letterSpacing:1,marginBottom:2}}>🧠 MNEMONİC</div>
        <div style={{fontSize:12,color:"var(--w7)",lineHeight:1.5}}>{word.mnemonicTip}</div>
      </>}
      {!word.ydsExampleSentence && !word.mnemonicTip && <div style={{fontSize:12,color:"var(--w4)"}}>{lang==="en"?"No extra info.":"Ek bilgi yok."}</div>}
    </div>
  );
}

// ── STUDY SCREEN ──────────────────────────────────────────────────────────────
function StudyScreen({ user, session, lang, onDone, onBack, showToast }) {
  const { type, words: rawItems } = session;
  const isPractice = type === "PRACTICE";

  // For practice mode, rawItems is Word[]; for study mode it's {word,progress}[]
  const items = isPractice
    ? rawItems.map(w=>({word:w, progress:null}))
    : rawItems;

  const [index,   setIndex]   = useState(0);
  const [flipped, setFlipped] = useState(false);
  const [correct, setCorrect] = useState(0);
  const [wrong,   setWrong]   = useState(0);
  const [done,    setDone]    = useState(false);
  // Key to force card remount, preventing flash of next word before flip resets
  const [cardKey, setCardKey] = useState(0);
  const startTime = useRef(Date.now());

  const total    = items.length;
  const current  = items[index];
  const word     = current?.word;
  const progress = (total * (index)) / total;

  const answer = async (isCorrect) => {
    if (!current) return;

    if (!isPractice && current.progress) {
      const prog = await dGet("progress",[user.id,current.word.id]) || current.progress;
      let updated = {...prog, lastReviewedAt:Date.now()};
      const cc = (prog.correctCount||0)+(isCorrect?1:0);
      const wc = (prog.wrongCount||0)+(isCorrect?0:1);
      if (type==="DAILY_STUDY") {
        if (isCorrect) updated = {...updated, box:"WEEKLY",  correctCount:cc, wrongCount:wc, movedToWeeklyAt:Date.now()};
        else           updated = {...updated, box:"DAILY",   correctCount:cc, wrongCount:wc};
      }
      if (type==="WEEKLY_REVIEW") {
        // Doğru → Aylık. Yanlış → Haftalık'ta kalır, timer sıfırlanır (yarın tekrar dene)
        if (isCorrect) updated = {...updated, box:"MONTHLY", correctCount:cc, wrongCount:wc, movedToMonthlyAt:Date.now()};
        else           updated = {...updated, box:"WEEKLY",  correctCount:cc, wrongCount:wc, movedToWeeklyAt:Date.now()};
      }
      if (type==="MONTHLY_REVIEW") {
        // Doğru → Aylık'ta kalır, timer yenilenir (30 gün sonra tekrar). Yanlış → Haftalıka geri.
        if (isCorrect) updated = {...updated, box:"MONTHLY", correctCount:cc, wrongCount:wc, movedToMonthlyAt:Date.now()};
        else           updated = {...updated, box:"WEEKLY",  correctCount:cc, wrongCount:wc, movedToWeeklyAt:Date.now()};
      }
      await dPut("progress", updated);
    }

    const newCorrect = correct + (isCorrect?1:0);
    const newWrong   = wrong   + (isCorrect?0:1);

    if (index >= total - 1) {
      if (!isPractice) {
        await dAdd("sessions",{userId:user.id,sessionType:type,date:TODAY(),total,correct:newCorrect,wrong:newWrong,duration:Math.round((Date.now()-startTime.current)/1000),completedAt:Date.now()});
      }
      setCorrect(newCorrect);
      setWrong(newWrong);
      setDone(true);
    } else {
      setCorrect(newCorrect);
      setWrong(newWrong);
      // Reset flip FIRST via key, then advance index
      setFlipped(false);
      setCardKey(k => k+1);
      // Small delay so CSS transition resets before new word renders
      setTimeout(() => setIndex(i => i+1), 30);
    }
  };

  if (done) return (
    <div className="summary">
      <div className="sum-emoji">🎯</div>
      <div className="sum-title">{isPractice?(lang==="en"?"PRACTICE DONE":"PRATİK BİTTİ"):(lang==="en"?"COMPLETED":"TAMAMLANDI")}</div>
      <div style={{width:"100%"}}>
        <div className="stat-row"><span className="stat-lbl">{lang==="en"?"Total":"Toplam"}</span><span className="stat-val" style={{color:"var(--w)"}}>{total}</span></div>
        <div className="stat-row"><span className="stat-lbl">✅ {lang==="en"?"Known":"Bilinen"}</span><span className="stat-val" style={{color:"#81c784"}}>{correct}</span></div>
        <div className="stat-row"><span className="stat-lbl">❌ {lang==="en"?"Unknown":"Bilinmeyen"}</span><span className="stat-val" style={{color:"#ff6b6b"}}>{wrong}</span></div>
        <div className="stat-row"><span className="stat-lbl">{lang==="en"?"Score":"Başarı"}</span><span className="stat-val" style={{color:"var(--g2)"}}>{total>0?Math.round(correct/total*100):0}%</span></div>
      </div>
      <button className="btn btn-gold" style={{width:"100%",marginTop:20}} onClick={()=>onDone(!isPractice)}>{lang==="en"?"BACK TO HOME":"ANA SAYFAYA DÖN"}</button>
    </div>
  );

  if (!word) return <div className="no-cards"><div style={{fontSize:56}}>🎉</div><div style={{fontFamily:"var(--fd)",fontSize:18}}>{lang==="en"?"No words found":"Kelime bulunamadı"}</div><button className="btn btn-outline" style={{marginTop:16}} onClick={onBack}>{lang==="en"?"Go Back":"Geri Dön"}</button></div>;

  const sessionLabel = (lang==="en"?SESSION_LABELS_EN:SESSION_LABELS_TR)[type] || type;
  const badgeColor   = SESSION_COLORS[type]  || "#D4AF37";

  return (
    <div className="study-screen">
      <div className="study-topbar">
        <button className="icon-btn" onClick={onBack}>‹</button>
        <div className="study-counter">{index+1} / {total}</div>
        <div className="study-badge" style={{background:badgeColor+"2a",color:badgeColor,border:`1px solid ${badgeColor}55`}}>{sessionLabel}</div>
      </div>

      <div className="prog-wrap">
        <div className="prog-fill" style={{width:`${progress*100}%`}}/>
      </div>

      <div className="fc-wrap">
        {/* key forces full remount when card changes, preventing back-face flash */}
        <div key={cardKey} className={`fc ${flipped?"flipped":""}`} onClick={()=>setFlipped(f=>!f)}>
          <div className="fc-face fc-front">
            <div style={{fontSize:36,marginBottom:14}}>📖</div>
            <div className="fc-word">{word.english}</div>
            <div className="fc-hint">{lang==="en"?"Tap to flip":"Çevirmek için dokun"}</div>
          </div>
          <div className="fc-face fc-back">
            <div className="fc-en">{word.english}</div>
            <div className="fc-tr">{word.turkish}</div>
            {word.ydsExampleSentence && <>
              <div className="fc-div"/>
              <div className="fc-stitle">📝 {lang==="en"?"YDS EXAMPLE":"YDS ÖRNEĞİ"}</div>
              <div className="fc-sbody">{word.ydsExampleSentence}</div>
              {word.ydsExampleTranslation && <div className="fc-ssub">{word.ydsExampleTranslation}</div>}
            </>}
            {word.mnemonicTip && <>
              <div className="fc-div"/>
              <div className="fc-stitle">🧠 MNEMONİC</div>
              <div className="fc-sbody">{word.mnemonicTip}</div>
            </>}
          </div>
        </div>
      </div>

      {flipped ? (
        <div className="ans-btns">
          <button className="btn-wrong"  onClick={()=>answer(false)}>✕ {lang==="en"?"Don't Know":"Bilmiyorum"}</button>
          <button className="btn-correct" onClick={()=>answer(true)}>✓ {lang==="en"?"I Know":"Biliyorum"}</button>
        </div>
      ) : (
        <div className="flip-hint">👆 {lang==="en"?"Flip card, then answer":"Kartı çevir, sonra cevapla"}</div>
      )}
    </div>
  );
}

// ── STATS SCREEN ──────────────────────────────────────────────────────────────
function StatsScreen({ user, lang }) {
  const [stats, setStats] = useState(null);

  useEffect(() => {
    const load = async () => {
      const [prog, sessions, acts] = await Promise.all([dIdx("progress","userId",user.id), dIdx("sessions","userId",user.id), dIdx("active_sets","userId",user.id)]);
      const totalCorrect = prog.reduce((s,p)=>s+(p.correctCount||0),0);
      const totalWrong   = prog.reduce((s,p)=>s+(p.wrongCount||0),0);
      const total        = totalCorrect+totalWrong;
      const accuracy     = total>0?totalCorrect/total:0;
      const dates        = [...new Set(sessions.map(s=>s.date))].sort().reverse();
      let streak=0, cur=new Date(TODAY());
      for (const d of dates) {
        const dd=new Date(d), diff=Math.round((cur-dd)/86400000);
        if (diff<=1){streak++;cur=dd;}else break;
      }
      setStats({daily:prog.filter(p=>p.box==="DAILY").length,weekly:prog.filter(p=>p.box==="WEEKLY").length,monthly:prog.filter(p=>p.box==="MONTHLY").length,totalCorrect,totalWrong,accuracy,activeSets:acts.length,streak,sessions:sessions.sort((a,b)=>b.completedAt-a.completedAt).slice(0,10)});
    };
    load();
  },[user.id]);

  if (!stats) return <div style={{height:"100%",display:"flex",alignItems:"center",justifyContent:"center",fontSize:32}}>⚓</div>;

  return (
    <>
      <div className="topbar"><div className="topbar-title">{lang==="en"?"Statistics":"İstatistikler"}</div></div>
      <div className="stats-wrap">
        <div className="streak-card">
          <div style={{flex:1}}>
            <div style={{fontSize:10,color:"var(--w4)",fontFamily:"var(--fd)",letterSpacing:1,marginBottom:4}}>{lang==="en"?"STUDY STREAK":"ÇALIŞMA SERİSİ"}</div>
            <div className="streak-num">{stats.streak}</div>
            <div style={{fontSize:12,color:"var(--w4)"}}>{lang==="en"?"days":"gün"}</div>
          </div>
          <div style={{fontSize:stats.streak>0?50:38}}>{stats.streak>0?"🔥":"💤"}</div>
        </div>
        <div className="boxes-row">
          {[[`📅`,lang==="en"?"Daily":"Günlük",stats.daily,"#4a90d9"],[`📆`,lang==="en"?"Weekly":"Haftalık",stats.weekly,"#7b68ee"],[`🗓`,lang==="en"?"Monthly":"Aylık",stats.monthly,"#4caf50"]].map(([em,lb,ct,cl])=>(
            <div key={lb} className="box-card">
              <div className="box-emoji">{em}</div>
              <div className="box-count" style={{color:cl}}>{ct}</div>
              <div className="box-label">{lb}</div>
            </div>
          ))}
        </div>
        <div className="card">
          <div style={{display:"flex",justifyContent:"space-between",marginBottom:10}}>
            {[["#81c784",`✅ ${lang==="en"?"Known":"Bilinen"}`,stats.totalCorrect],["#ff6b6b",`❌ ${lang==="en"?"Unknown":"Bilinmeyen"}`,stats.totalWrong],["var(--g2)",`📊 ${lang==="en"?"Rate":"Oran"}`,`${Math.round(stats.accuracy*100)}%`]].map(([cl,lb,v])=>(
              <div key={lb} style={{textAlign:"center"}}>
                <div style={{fontFamily:"var(--fd)",fontSize:20,color:cl}}>{v}</div>
                <div style={{fontSize:11,color:"var(--w4)"}}>{lb}</div>
              </div>
            ))}
          </div>
          <div className="acc-bar"><div className="acc-fill" style={{width:`${stats.accuracy*100}%`}}/></div>
        </div>
        <div style={{display:"flex",gap:8}}>
          {[["var(--g2)",lang==="en"?"Active Sets":"Aktif Set",stats.activeSets,"rgba(212,175,55,.1)","rgba(212,175,55,.2)"],["#4a90d9",lang==="en"?"Total Answers":"Toplam Cevap",stats.totalCorrect+stats.totalWrong,"rgba(74,144,217,.1)","rgba(74,144,217,.2)"]].map(([cl,lb,v,bg,bd])=>(
            <div key={lb} style={{flex:1,background:bg,borderRadius:10,padding:"9px 12px",textAlign:"center",border:`1px solid ${bd}`}}>
              <div style={{fontFamily:"var(--fd)",fontSize:18,color:cl}}>{v}</div>
              <div style={{fontSize:11,color:"var(--w4)"}}>{lb}</div>
            </div>
          ))}
        </div>
        {stats.sessions.length>0&&<>
          <div style={{fontSize:10,color:"var(--g2)",fontFamily:"var(--fd)",letterSpacing:2}}>{lang==="en"?"RECENT SESSIONS":"SON OTURUMLAR"}</div>
          {stats.sessions.map((s,i)=>(
            <div key={i} className="sess-row">
              <div style={{flex:1,fontSize:12,color:"var(--w7)"}}>{lang==="en"?{"DAILY_STUDY":"📅 Daily","WEEKLY_REVIEW":"📆 Weekly Exam","MONTHLY_REVIEW":"🗓 Monthly Review","PRACTICE":"🎲 Practice"}[s.sessionType]||s.sessionType:{"DAILY_STUDY":"📅 Günlük","WEEKLY_REVIEW":"📆 Haftalık Sınav","MONTHLY_REVIEW":"🗓 Aylık Tekrar","PRACTICE":"🎲 Pratik"}[s.sessionType]||s.sessionType}</div>
              <div style={{textAlign:"right"}}>
                <div style={{fontFamily:"var(--fd)",fontSize:12,color:"var(--g2)"}}>{s.correct}/{s.total}</div>
                <div style={{fontSize:10,color:"var(--w4)"}}>{s.date}</div>
              </div>
            </div>
          ))}
        </>}
      </div>
    </>
  );
}

// ── SETTINGS SCREEN ───────────────────────────────────────────────────────────
function SettingsScreen({ user, lang, onLangChange, onUserUpdate, onLogout, onSwitchUser, showToast }) {
  const [goal,     setGoal]     = useState(user.dailyGoal||15);
  const [saved,    setSaved]    = useState(false);
  const [editingName, setEditingName] = useState(false);
  const [newUsername, setNewUsername] = useState(user.username);
  // Admin password change
  const [adminOld, setAdminOld] = useState("");
  const [adminNew, setAdminNew] = useState("");
  const [adminNew2,setAdminNew2]= useState("");
  const [pwErr,    setPwErr]    = useState("");
  // User management (admin only)
  const [users,    setUsers]    = useState([]);
  const [showAdd,  setShowAdd]  = useState(false);
  const [newName,  setNewName]  = useState("");
  // Optional password for non-admin user
  const [showSetPw,  setShowSetPw]  = useState(false);
  const [userPwNew,  setUserPwNew]  = useState("");
  const [userPwNew2, setUserPwNew2] = useState("");
  const [userPwErr,  setUserPwErr]  = useState("");

  const switchLang = (l) => {
    localStorage.setItem("wv_lang", l);
    if (onLangChange) onLangChange(l);
    showToast(l === "tr" ? "Dil: Türkçe" : "Language: English");
  };

  const loadUsers = () => dAll("users").then(setUsers);
  useEffect(() => {
  if (user.isAdmin) loadUsers();
}, [user]);

  const saveGoal = async () => {
    const updated = {...user, dailyGoal:goal};
    await dPut("users",updated);
    onUserUpdate(updated);
    setSaved(true);
    setTimeout(()=>setSaved(false),2000);
  };

  const saveName = async () => {
    const name = newUsername.trim();
    if (!name){showToast(lang==="en"?"Name cannot be empty":"İsim boş olamaz");return;}
    const all = await dAll("users");
    if (all.find(u=>u.id!==user.id&&u.username.toLowerCase()===name.toLowerCase())){showToast(lang==="en"?"This name already exists":"Bu isim zaten var");return;}
    const updated = {...user, username:name};
    await dPut("users",updated);
    onUserUpdate(updated);
    setEditingName(false);
    showToast(lang==="en"?"Name updated ✓":"İsim güncellendi ✓");
  };

  const saveAdminPw = async () => {
    setPwErr("");
    if (user.passwordHash!==adminOld){setPwErr(lang==="en"?"Old password incorrect.":"Eski şifre hatalı.");return;}
    if (adminNew.length<4){setPwErr(lang==="en"?"New password must be at least 4 chars.":"Yeni şifre en az 4 karakter olmalı.");return;}
    if (adminNew!==adminNew2){setPwErr(lang==="en"?"Passwords don't match.":"Şifreler eşleşmiyor.");return;}
    const updated = {...user,passwordHash:adminNew};
    await dPut("users",updated);
    onUserUpdate(updated);
    setAdminOld("");setAdminNew("");setAdminNew2("");
    showToast(lang==="en"?"Password updated ✓":"Şifre güncellendi ✓");
  };

  const saveUserPw = async () => {
    setUserPwErr("");
    if (userPwNew.length<4){setUserPwErr(lang==="en"?"Min 4 characters.":"En az 4 karakter.");return;}
    if (userPwNew!==userPwNew2){setUserPwErr(lang==="en"?"Passwords don't match.":"Şifreler eşleşmiyor.");return;}
    const updated = {...user,passwordHash:userPwNew};
    await dPut("users",updated);
    onUserUpdate(updated);
    setUserPwNew("");setUserPwNew2("");setShowSetPw(false);
    showToast(lang==="en"?"Password set ✓":"Şifre oluşturuldu ✓");
  };

  const deleteUser = async (uid) => {
    if (uid===user.id){showToast(lang==="en"?"Cannot delete yourself":"Kendini silemezsin");return;}
    await dDel("users",uid);
    loadUsers();
    showToast(lang==="en"?"User deleted":"Kullanıcı silindi");
  };

  const addNewUser = async () => {
    const name = newName.trim();
    if (!name){showToast(lang==="en"?"Name cannot be empty":"İsim boş olamaz");return;}
    const all = await dAll("users");
    if (all.find(u=>u.username.toLowerCase()===name.toLowerCase())){showToast(lang==="en"?"This name already exists":"Bu isim zaten var");return;}
    await dAdd("users",{username:name,passwordHash:"",isAdmin:false,dailyGoal:15,createdAt:Date.now(),currentStreak:0,longestStreak:0});
    setNewName("");setShowAdd(false);
    loadUsers();
    showToast(lang==="en"?"User added ✓":"Kullanıcı eklendi ✓");
  };

  const pct = `${((goal-5)/45)*100}%`;

  return (
    <>
      <div className="topbar"><div className="topbar-title">{lang==="en"?"Settings":"Ayarlar"}</div></div>
      <div className="settings-wrap">

        {/* Current user info + name edit */}
        <div className="scard">
          <div className="srow" style={{marginBottom:8}}>
            <span className="s-icon">👤</span>
            <div style={{flex:1}}>
              {editingName ? (
                <input className="mi" style={{marginBottom:0,padding:"6px 10px",fontSize:14}} value={newUsername} onChange={e=>setNewUsername(e.target.value)} onKeyDown={e=>e.key==="Enter"&&saveName()} autoFocus/>
              ) : (
                <div className="s-label">{user.username}</div>
              )}
              {user.isAdmin&&<div className="s-sub">{lang==="en"?"Admin account":"Admin hesabı"}</div>}
            </div>
            {user.isAdmin&&<div className="admin-badge">{lang==="en"?"ADMIN":"ADMİN"}</div>}
            {editingName ? (
              <div style={{display:"flex",gap:5}}>
                <button style={{background:"var(--g2)",border:"none",borderRadius:7,padding:"5px 11px",color:"var(--n1)",fontSize:12,cursor:"pointer",fontFamily:"var(--fd)"}} onClick={saveName}>✓</button>
                <button style={{background:"var(--w08)",border:"none",borderRadius:7,padding:"5px 9px",color:"var(--w7)",fontSize:12,cursor:"pointer"}} onClick={()=>{setEditingName(false);setNewUsername(user.username);}}>✕</button>
              </div>
            ) : (
              <button style={{background:"none",border:"none",color:"var(--g2)",fontSize:16,cursor:"pointer",padding:"2px 6px"}} onClick={()=>setEditingName(true)}>✏️</button>
            )}
          </div>
          <button onClick={onSwitchUser} style={{width:"100%",padding:"10px",background:"rgba(212,175,55,0.08)",border:"1px solid rgba(212,175,55,0.2)",borderRadius:10,color:"var(--g2)",fontFamily:"var(--fd)",fontSize:12,letterSpacing:1,cursor:"pointer",display:"flex",alignItems:"center",justifyContent:"center",gap:8}}>
            <span>👥</span> {lang==="en"?"SWITCH USER / LOG OUT":"KULLANICI DEĞİŞTİR / ÇIKIŞ YAP"}
          </button>
        </div>

        {/* Daily goal */}
        <div className="scard">
          <div className="srow"><span className="s-icon">🎯</span><div><div className="s-label">{lang==="en"?"Daily Goal":"Günlük Hedef"}</div><div className="s-sub">{goal} {lang==="en"?"words / day":"kelime / gün"}</div></div></div>
          <div className="slider-wrap">
            <input type="range" min={5} max={50} step={5} value={goal} onChange={e=>setGoal(parseInt(e.target.value))} style={{"--pct":pct}}/>
            <div style={{display:"flex",justifyContent:"space-between",fontSize:10,color:"var(--w4)",marginTop:3}}><span>5</span><span>50</span></div>
          </div>
          <button className="btn btn-gold" onClick={saveGoal}>{lang==="en"?"SAVE":"KAYDET"}</button>
          {saved&&<div className="save-badge" style={{marginTop:8}}><span>✅</span> {lang==="en"?"Saved!":"Kaydedildi!"}</div>}
        </div>

        {/* Non-admin: optional password */}
        {!user.isAdmin && (
          <div className="scard">
            <div className="srow" style={{marginBottom:showSetPw?10:0}}>
              <span className="s-icon">🔒</span>
              <div style={{flex:1}}>
                <div className="s-label">{lang==="en"?"Password":"Şifre"}</div>
                <div className="s-sub">{user.passwordHash?(lang==="en"?"Password is set":"Şifre var"):(lang==="en"?"No password (optional)":"Şifre yok (isteğe bağlı)")}</div>
              </div>
              <button style={{background:"none",border:"1px solid rgba(212,175,55,.3)",borderRadius:8,padding:"4px 10px",color:"var(--g2)",fontFamily:"var(--fd)",fontSize:10,letterSpacing:.5,cursor:"pointer"}} onClick={()=>setShowSetPw(s=>!s)}>
                {showSetPw?"✕":(user.passwordHash?(lang==="en"?"Change":"Değiştir"):(lang==="en"?"Set":"Oluştur"))}
              </button>
            </div>
            {showSetPw && <>
              <input className="mi" type="password" placeholder={lang==="en"?"New password (min 4 chars)":"Yeni şifre (min 4 karakter)"} value={userPwNew} onChange={e=>setUserPwNew(e.target.value)}/>
              <input className="mi" type="password" placeholder={lang==="en"?"Repeat password":"Şifreyi tekrarla"} value={userPwNew2} onChange={e=>setUserPwNew2(e.target.value)}/>
              {userPwErr&&<div className="auth-err">{userPwErr}</div>}
              <button className="btn btn-gold" onClick={saveUserPw}>{lang==="en"?"SAVE PASSWORD":"ŞİFREYİ KAYDET"}</button>
            </>}
          </div>
        )}

        {/* Admin: user management */}
        {user.isAdmin && (
          <div className="scard">
            <div className="srow"><span className="s-icon">👥</span><div className="s-label">{lang==="en"?"Users":"Kullanıcılar"}</div></div>
            {users.map((u)=>(
              <div key={u.id} className="user-mgmt-item">
                <span style={{flex:1,fontSize:14,color:"var(--w9)"}}>{u.username}{u.isAdmin&&<span style={{fontSize:10,color:"var(--g2)",marginLeft:6}}>{lang==="en"?"ADMIN":"ADMİN"}</span>}</span>
                {!u.isAdmin&&<button className="del-btn" onClick={()=>deleteUser(u.id)}>🗑</button>}
              </div>
            ))}
            {showAdd ? (
              <div style={{display:"flex",gap:7,marginTop:4}}>
                <input className="mi" style={{flex:1,marginBottom:0,padding:"9px 12px",fontSize:14}} placeholder={lang==="en"?"New username":"Yeni kullanıcı adı"} value={newName} onChange={e=>setNewName(e.target.value)} onKeyDown={e=>e.key==="Enter"&&addNewUser()} autoFocus/>
                <button style={{background:"var(--g2)",border:"none",borderRadius:10,padding:"0 14px",color:"var(--n1)",fontFamily:"var(--fd)",fontSize:12,cursor:"pointer"}} onClick={addNewUser}>{lang==="en"?"ADD":"EKLE"}</button>
                <button style={{background:"var(--w08)",border:"none",borderRadius:10,padding:"0 10px",color:"var(--w7)",cursor:"pointer"}} onClick={()=>setShowAdd(false)}>✕</button>
              </div>
            ) : (
              <button className="add-user-btn" style={{marginTop:6}} onClick={()=>setShowAdd(true)}>＋ {lang==="en"?"Add User":"Kullanıcı Ekle"}</button>
            )}
          </div>
        )}

        {/* Admin password change */}
        {user.isAdmin && (
          <div className="scard">
            <div className="srow"><span className="s-icon">🔐</span><div className="s-label">{lang==="en"?"Change Admin Password":"Admin Şifre Değiştir"}</div></div>
            <input className="mi" type="password" placeholder={lang==="en"?"Current password":"Mevcut şifre"} value={adminOld} onChange={e=>setAdminOld(e.target.value)}/>
            <input className="mi" type="password" placeholder={lang==="en"?"New password":"Yeni şifre"} value={adminNew} onChange={e=>setAdminNew(e.target.value)}/>
            <input className="mi" type="password" placeholder={lang==="en"?"Repeat new password":"Yeni şifre tekrar"} value={adminNew2} onChange={e=>setAdminNew2(e.target.value)}/>
            {pwErr&&<div className="auth-err">{pwErr}</div>}
            <button className="btn btn-gold" onClick={saveAdminPw}>{lang==="en"?"UPDATE PASSWORD":"ŞİFREYİ GÜNCELLE"}</button>
          </div>
        )}

        {/* Dil seçimi */}
        <div className="scard">
          <div className="srow" style={{marginBottom:0}}>
            <span className="s-icon">🌐</span>
            <div className="s-info">
              <div className="s-label">{lang==="tr"?"Sistem Dili":"System Language"}</div>
              <div className="s-sub">{lang==="tr"?"Uygulama arayüz dili":"App interface language"}</div>
            </div>
          </div>
          <div style={{display:"flex",gap:8,marginTop:12}}>
            <button onClick={()=>switchLang("tr")} style={{flex:1,padding:"10px",borderRadius:10,border:`1px solid ${lang==="tr"?"var(--g2)":"rgba(255,255,255,0.15)"}`,background:lang==="tr"?"rgba(212,175,55,0.15)":"var(--w08)",color:lang==="tr"?"var(--g2)":"var(--w7)",fontFamily:"var(--fd)",fontSize:12,letterSpacing:1,cursor:"pointer",transition:"all .2s"}}>🇹🇷 TÜRKÇE</button>
            <button onClick={()=>switchLang("en")} style={{flex:1,padding:"10px",borderRadius:10,border:`1px solid ${lang==="en"?"var(--g2)":"rgba(255,255,255,0.15)"}`,background:lang==="en"?"rgba(212,175,55,0.15)":"var(--w08)",color:lang==="en"?"var(--g2)":"var(--w7)",fontFamily:"var(--fd)",fontSize:12,letterSpacing:1,cursor:"pointer",transition:"all .2s"}}>🇬🇧 ENGLISH</button>
          </div>
        </div>

        {/* App info */}
        <div style={{textAlign:"center",color:"var(--w4)",fontSize:12,padding:"6px 0",lineHeight:1.7}}>
          WordVault v5.0 · {lang==="tr"?"Tüm veriler cihazında saklanır.":"All data stored on your device."}<br/>
          {lang==="tr"?"Safari/Chrome → Paylaş → Ana Ekrana Ekle":"Safari/Chrome → Share → Add to Home Screen"}
        </div>
      </div>
    </>
  );
}

// ── ADMIN SCREEN ──────────────────────────────────────────────────────────────
function AdminScreen({ user, lang, showToast }) {
  const [levels,   setLevels]  = useState([]);
  const [selLevel, setSelLevel]= useState(null);
  const [sets,     setSets]    = useState([]);
  const [selSet,   setSelSet]  = useState(null);
  const [words,    setWords]   = useState([]);
  const [modal,    setModal]   = useState(null);
  const [editWord, setEditWord]= useState(null);
  const [searchQ,  setSearchQ] = useState("");
  const [searchMode, setSearchMode] = useState(false);
  const [searchResults, setSearchResults] = useState([]);
  const [allWords, setAllWords] = useState([]);

  const loadLevels = async () => { const l=await dAll("levels"); setLevels(l.sort((a,b)=>(a.orderIndex||0)-(b.orderIndex||0))); };
  const loadSets   = async (lid)=> { const s=await dIdx("wordsets","levelId",lid); setSets(s.sort((a,b)=>(a.orderIndex||0)-(b.orderIndex||0))); };
 const loadWords = async (sid) => {
  const { data, error } = await supabase
    .from("words")
    .select("*")
    .eq("wordSetId", sid)
    .order("orderIndex", { ascending: true });

  if (!error && data) {
    setWords(data);
  }
};
  const loadAllWords = async () => { const w=await dAll("words"); setAllWords(w); };

  useEffect(()=>{loadLevels();loadAllWords();},[]);

  const back = () => { if(selSet){setSelSet(null);setWords([]);}else if(selLevel){setSelLevel(null);setSets([]);} };
  const title = selSet?selSet.name:selLevel?selLevel.name:(lang==="en"?"Admin Panel":"Admin Paneli");

  const doSearch = (q) => {
    const query = q.trim().toLowerCase();
    if (!query) { setSearchResults([]); return; }
    setSearchResults(allWords.filter(w =>
      w.english.toLowerCase().includes(query) || w.turkish.toLowerCase().includes(query)
    ).slice(0, 50));
  };

  return (
    <>
      <div className="topbar" style={{gap:6}}>
        <button className="icon-btn" onClick={selLevel?back:undefined} style={{visibility:selLevel?"visible":"hidden"}}>‹</button>
        <div style={{flex:1}}><div className="topbar-title">{title}</div><div className="topbar-sub">⚙️ Admin</div></div>
        <button className="icon-btn" style={{fontSize:15}} onClick={()=>{setSearchMode(s=>!s);setSearchQ("");setSearchResults([]);}}>🔍</button>
        <button className="icon-btn" onClick={()=>setModal(selSet?"import":selLevel?"set":"level")}>＋</button>
      </div>

      {searchMode && (
        <div style={{padding:"0 14px 8px"}}>
          <input
            className="mi"
            style={{marginBottom:0,padding:"10px 14px",fontSize:14}}
            placeholder={lang==="en"?"Search word...":"Kelime ara..."}
            value={searchQ}
            onChange={e=>{setSearchQ(e.target.value);doSearch(e.target.value);}}
            autoFocus
          />
        </div>
      )}

      <div className="admin-wrap">
        {/* SEARCH RESULTS */}
        {searchMode && searchQ.trim() && (
          <>
            <div className="tab-title">{searchResults.length} {lang==="en"?"RESULTS":"SONUÇ"}</div>
            {searchResults.length===0 && <div style={{textAlign:"center",padding:"20px 0",color:"var(--w4)"}}>{lang==="en"?"No words found.":"Kelime bulunamadı."}</div>}
            {searchResults.map(word=>(
              <div key={word.id} className="word-item" style={{display:"flex",alignItems:"center",gap:8,marginBottom:6}}>
                <div style={{flex:1}}>
                  <div className="word-item-en">{word.english}</div>
                  <div className="word-item-tr">{word.turkish}</div>
                </div>
                <button style={{background:"none",border:"none",color:"var(--g2)",fontSize:15,cursor:"pointer",padding:"2px 5px"}} onClick={()=>{setEditWord(word);setModal("editWord");}}>✏️</button>
                <button className="del-btn" onClick={async()=>{await supabase
  .from("words")
  .delete()
  .eq("id", word.id);}}>🗑</button>
              </div>
            ))}
          </>
        )}

        {/* NORMAL VIEW */}
        {(!searchMode || !searchQ.trim()) && <>
          {!selLevel && <>
            <div className="tab-title">{lang==="en"?"LEVELS":"SEVİYELER"}</div>
            {levels.length===0&&<div style={{textAlign:"center",padding:"24px 0",color:"var(--w4)"}}>{lang==="en"?"No levels yet. Add with ＋.":"Henüz seviye yok. ＋ ile ekle."}</div>}
            {levels.map(level=>(
              <div key={level.id} className="admin-item" onClick={()=>{setSelLevel(level);loadSets(level.id);}}>
                <span style={{fontSize:22}}>{level.iconEmoji||"📚"}</span>
                <div className="admin-item-info"><div className="admin-item-name">{level.name}</div>{level.description&&<div className="admin-item-sub">{level.description}</div>}</div>
                <span style={{color:"var(--w4)",fontSize:17}}>›</span>
                <button className="del-btn" onClick={async e=>{e.stopPropagation();await dDel("levels",level.id);loadLevels();showToast(lang==="en"?"Deleted":"Silindi");}}>🗑</button>
              </div>
            ))}
          </>}

          {selLevel&&!selSet&&<>
            <div className="tab-title">{lang==="en"?"SETS":"SETLER"} — {selLevel.name}</div>
            {sets.length===0&&<div style={{textAlign:"center",padding:"24px 0",color:"var(--w4)"}}>{lang==="en"?"No sets. Add with ＋.":"Set yok. ＋ ile ekle."}</div>}
            {sets.map(set=>(
              <div key={set.id} className="admin-item" onClick={()=>{setSelSet(set);loadWords(set.id);}}>
                <span style={{fontSize:22}}>📂</span>
                <div className="admin-item-info"><div className="admin-item-name">{set.name}</div>{set.description&&<div className="admin-item-sub">{set.description}</div>}</div>
                <span style={{color:"var(--w4)",fontSize:17}}>›</span>
                <button className="del-btn" onClick={async e=>{e.stopPropagation();await dDel("wordsets",set.id);loadSets(selLevel.id);showToast(lang==="en"?"Deleted":"Silindi");}}>🗑</button>
              </div>
            ))}
          </>}

          {selSet&&<>
            <div style={{display:"flex",gap:8,marginBottom:4}}>
              <button className="btn btn-outline" style={{fontSize:12,padding:"9px"}} onClick={()=>setModal("word")}>＋ {lang==="en"?"Add Word":"Kelime Ekle"}</button>
              <button className="btn btn-gold" style={{fontSize:12,padding:"9px"}} onClick={()=>setModal("import")}>📁 Import</button>
            </div>
            <div className="tab-title">{words.length} {lang==="en"?"WORDS":"KELİME"}</div>
            {words.map(word=>(
              <div key={word.id} className="word-item" style={{display:"flex",alignItems:"center",gap:8,marginBottom:6}}>
                <div style={{flex:1}}>
                  <div className="word-item-en">{word.english}</div>
                  <div className="word-item-tr">{word.turkish}</div>
                </div>
                <button style={{background:"none",border:"none",color:"var(--g2)",fontSize:15,cursor:"pointer",padding:"2px 5px"}} onClick={()=>{setEditWord(word);setModal("editWord");}}>✏️</button>
                <button className="del-btn" onClick={async()=>{await dDel("words",word.id);loadWords(selSet.id);}}>🗑</button>
              </div>
            ))}
          </>}
        </>}
      </div>

      {/* MODALS */}
      {modal==="level"&&<CreateLevelModal lang={lang} onClose={()=>setModal(null)} onSave={async d=>{await dAdd("levels",{...d,orderIndex:levels.length,createdAt:Date.now()});loadLevels();setModal(null);showToast(lang==="en"?"Level created!":"Seviye oluşturuldu!");}}/>}
      {modal==="set"&&selLevel&&<CreateSetModal lang={lang} levelName={selLevel.name} onClose={()=>setModal(null)} onSave={async d=>{await dAdd("wordsets",{...d,levelId:selLevel.id,orderIndex:sets.length,createdAt:Date.now()});loadSets(selLevel.id);setModal(null);showToast(lang==="en"?"Set created!":"Set oluşturuldu!");}}/>}
      {modal==="word"&&selSet&&<AddWordModal lang={lang} setId={selSet.id} orderIndex={words.length} onClose={()=>setModal(null)} onSaved={()=>{loadWords(selSet.id);loadAllWords();showToast(lang==="en"?"Word added!":"Kelime eklendi!");}} checkDuplicate={async(eng)=>{const ws=await dIdx("words","wordSetId",selSet.id);return ws.some(w=>w.english.toLowerCase()===eng.toLowerCase());}}/>}
      {modal==="editWord"&&editWord&&<EditWordModal lang={lang} word={editWord} onClose={()=>{setModal(null);setEditWord(null);}} onSaved={()=>{if(selSet)loadWords(selSet.id);loadAllWords();if(searchQ.trim())doSearch(searchQ);showToast(lang==="en"?"Updated ✓":"Güncellendi ✓");}}/>}
      {modal==="import"&&selSet&&<ImportModal lang={lang} set={selSet} onClose={()=>setModal(null)} onDone={()=>{loadWords(selSet.id);loadAllWords();}} showToast={showToast}/>}
    </>
  );
}

// ── MODALS ────────────────────────────────────────────────────────────────────
function CreateLevelModal({lang,onClose,onSave}){
  const [name,setName]=useState(""); const [desc,setDesc]=useState(""); const [emoji,setEmoji]=useState("📚"); const [color,setColor]=useState("#4A90D9");
  return <Modal lang={lang} title={lang==="en"?"NEW LEVEL":"YENİ SEVİYE"} onClose={onClose} onConfirm={()=>name&&onSave({name,description:desc,iconEmoji:emoji,color})}>
    <input className="mi" placeholder={lang==="en"?"Level name *":"Seviye adı *"} value={name} onChange={e=>setName(e.target.value)}/>
    <input className="mi" placeholder={lang==="en"?"Description":"Açıklama"} value={desc} onChange={e=>setDesc(e.target.value)}/>
    <div className="mini-label">{lang==="en"?"ICON":"SİMGE"}</div>
    <div className="emoji-grid">{EMOJIS.map(e=><button key={e} className={`emoji-opt ${emoji===e?"sel":""}`} onClick={()=>setEmoji(e)}>{e}</button>)}</div>
    <div className="mini-label">{lang==="en"?"COLOR":"RENK"}</div>
    <div className="color-grid">{COLORS.map(c=><div key={c} className={`color-opt ${color===c?"sel":""}`} style={{background:c}} onClick={()=>setColor(c)}/>)}</div>
  </Modal>;
}

function CreateSetModal({lang,levelName,onClose,onSave}){
  const [name,setName]=useState(""); const [desc,setDesc]=useState("");
  return <Modal lang={lang} title={`${lang==="en"?"NEW SET":"YENİ SET"} — ${levelName}`} onClose={onClose} onConfirm={()=>name&&onSave({name,description:desc})}>
    <input className="mi" placeholder={lang==="en"?"Set name *":"Set adı *"} value={name} onChange={e=>setName(e.target.value)}/>
    <input className="mi" placeholder={lang==="en"?"Description":"Açıklama"} value={desc} onChange={e=>setDesc(e.target.value)}/>
  </Modal>;
}

function AddWordModal({lang,setId,orderIndex,onClose,onSaved,checkDuplicate}){
  const [f,setF]=useState({english:"",turkish:"",ydsExampleSentence:"",ydsExampleTranslation:"",mnemonicTip:""});
  const [err,setErr]=useState("");
  const save=async()=>{
    if(!f.english||!f.turkish){setErr(lang==="en"?"English and Turkish are required.":"İngilizce ve Türkçe zorunlu.");return;}
    const dup=await checkDuplicate(f.english);
    if(dup){setErr(lang==="en"?"This word already exists in this set.":"Bu kelime bu sette zaten var.");return;}
    await supabase
  .from("words")
  .insert([{
    ...f,
    wordSetId:setId,
    orderIndex,
    addedAt:Date.now()
  }]);
    onSaved();
    setF({english:"",turkish:"",ydsExampleSentence:"",ydsExampleTranslation:"",mnemonicTip:""});
    setErr("");
  };
  return <Modal lang={lang} title={lang==="en"?"ADD WORD":"KELİME EKLE"} onClose={onClose} onConfirm={save} confirmLabel={lang==="en"?"Save":"Kaydet"}>
    <input className="mi" placeholder="English *" value={f.english} onChange={e=>setF({...f,english:e.target.value})}/>
    <input className="mi" placeholder={lang==="en"?"Turkish *":"Türkçe *"} value={f.turkish} onChange={e=>setF({...f,turkish:e.target.value})}/>
    <textarea className="mi" placeholder={lang==="en"?"YDS example sentence":"YDS Örnek cümle"} value={f.ydsExampleSentence} onChange={e=>setF({...f,ydsExampleSentence:e.target.value})}/>
    <textarea className="mi" placeholder={lang==="en"?"Turkish translation":"Türkçe çevirisi"} value={f.ydsExampleTranslation} onChange={e=>setF({...f,ydsExampleTranslation:e.target.value})}/>
    <textarea className="mi" placeholder="Mnemonic" value={f.mnemonicTip} onChange={e=>setF({...f,mnemonicTip:e.target.value})}/>
    {err&&<div className="auth-err">{err}</div>}
  </Modal>;
}

function EditWordModal({lang,word,onClose,onSaved}){
  const [f,setF]=useState({english:word.english,turkish:word.turkish,ydsExampleSentence:word.ydsExampleSentence||"",ydsExampleTranslation:word.ydsExampleTranslation||"",mnemonicTip:word.mnemonicTip||""});
  const save = async () => {
  await supabase
  .from("words")
  .update({...f})
  .eq("id", word.id);};
  return <Modal lang={lang} title={lang==="en"?"EDIT WORD":"KELİMEYİ DÜZENLE"} onClose={onClose} onConfirm={save} confirmLabel={lang==="en"?"Update":"Güncelle"}>
    <input className="mi" placeholder="English" value={f.english} onChange={e=>setF({...f,english:e.target.value})}/>
    <input className="mi" placeholder={lang==="en"?"Turkish":"Türkçe"} value={f.turkish} onChange={e=>setF({...f,turkish:e.target.value})}/>
    <textarea className="mi" placeholder={lang==="en"?"YDS sentence":"YDS cümle"} value={f.ydsExampleSentence} onChange={e=>setF({...f,ydsExampleSentence:e.target.value})}/>
    <textarea className="mi" placeholder={lang==="en"?"Turkish translation":"Türkçe çeviri"} value={f.ydsExampleTranslation} onChange={e=>setF({...f,ydsExampleTranslation:e.target.value})}/>
    <textarea className="mi" placeholder="Mnemonic" value={f.mnemonicTip} onChange={e=>setF({...f,mnemonicTip:e.target.value})}/>
  </Modal>;
}
function ImportModal({lang,set,onClose,onDone,showToast}) {
  const [result,setResult] = useState(null);
  const doImport = async (text, isJson) => {
    try {
      let rows = [];
      if (isJson) {
        const arr = JSON.parse(text);
        rows = arr.map(w => ({
          wordSetId: set.id,
          english: w.english || "",
          turkish: w.turkish || "",
          ydsExampleSentence: w.ydsExample || "",
          ydsExampleTranslation: w.ydsTranslation || "",
          mnemonicTip: w.mnemonic || "",
          addedAt: Date.now()
        }));
      } else {
        const lines = text.trim().split("\n");
        const start =
          lines[0].toLowerCase().startsWith("english")
            ? 1
            : 0;
        rows = lines.slice(start).map(l => {
          const [en, tr, yds, ydsT, mn] =
            l.split(",").map(c =>
              c.trim().replace(/^"|"$/g, "")
            );
          return {
            wordSetId: set.id,
            english: en || "",
            turkish: tr || "",
            ydsExampleSentence: yds || "",
            ydsExampleTranslation: ydsT || "",
            mnemonicTip: mn || "",
            addedAt: Date.now()
          };
        });
      }
      const validRows = rows.filter(
        w => w.english && w.turkish
      );
      const { error } = await supabase
        .from("words")
        .insert(validRows);
      if (error) throw error;
      setResult({
        added: validRows.length,
        skipped: 0
      });
      onDone();
    } catch (e) {
      showToast(
        (lang === "en" ? "Error: " : "Hata: ")
        + e.message
      );
    }
  };
  const handleFile = (e) => {
    const file = e.target.files[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = async (ev) => {
      await doImport(
        ev.target.result,
        file.name.endsWith(".json")
      );
    };
    reader.readAsText(file);
  };
}
function Modal({lang,title,children,onClose,onConfirm,confirmLabel}){
  const cl = confirmLabel || (lang==="en"?"Create":"Oluştur");
  return(
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal" onClick={e=>e.stopPropagation()}>
        <div className="modal-title">{title}</div>
        {children}
        <div className="modal-btns">
          <button className="btn btn-outline" onClick={onClose}>{lang==="en"?"Cancel":"İptal"}</button>
          <button className="btn btn-gold" onClick={onConfirm}>{cl}</button>
        </div>
      </div>
    </div>
  );
}
