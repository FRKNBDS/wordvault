import { useState, useEffect } from 'react';
import { 
  BookOpen, 
  ChevronRight, 
  ChevronLeft, 
  RotateCcw, 
  CheckCircle, 
  XCircle, 
  Bookmark, 
  BookmarkCheck,
  Search,
  Volume2,
  HelpCircle,
  Award,
  Sparkles,
  Layers
} from 'lucide-react';
import './App.css';

// 1. DEĞİŞİKLİK: words.json dosyasını doğrudan içeri aktarıyoruz
import wordsData from './words.json';

function App() {
  const [words, setWords] = useState([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isFlipped, setIsFlipped] = useState(false);
  const [loading, setLoading] = useState(true);
  const [showMnemonic, setShowMnemonic] = useState(false);
  const [favorites, setFavorites] = useState([]);
  const [learned, setLearned] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterMode, setFilterMode] = useState('all'); // 'all', 'favorites', 'learned', 'notLearned'
  const [score, setScore] = useState({ correct: 0, total: 0 });
  const [showQuizResult, setShowQuizResult] = useState(false);

  // 2. DEĞİŞİKLİK: Sunucudan fetch etmek yerine import ettiğimiz veriyi doğrudan yüklüyoruz
  useEffect(() => {
    if (wordsData && wordsData.words) {
      setWords(wordsData.words);
    } else if (Array.isArray(wordsData)) {
      setWords(wordsData);
    }
    setLoading(false);
  }, []);

  // Yerel depolama yüklemeleri
  useEffect(() => {
    const savedFavs = localStorage.getItem('wordvault_favs');
    const savedLearned = localStorage.getItem('wordvault_learned');
    if (savedFavs) setFavorites(JSON.parse(savedFavs));
    if (savedLearned) setLearned(JSON.parse(savedLearned));
  }, []);

  // Filtrelenmiş kelime listesi
  const filteredWords = words.filter(word => {
    const matchesSearch = 
      word.word.toLowerCase().includes(searchTerm.toLowerCase()) ||
      word.translation.toLowerCase().includes(searchTerm.toLowerCase()) ||
      word.mnemonic.toLowerCase().includes(searchTerm.toLowerCase());
    
    if (!matchesSearch) return false;
    
    if (filterMode === 'favorites') return favorites.includes(word.id);
    if (filterMode === 'learned') return learned.includes(word.id);
    if (filterMode === 'notLearned') return !learned.includes(word.id);
    return true;
  });

  const currentWord = filteredWords[currentIndex];

  // Favori Yönetimi
  const toggleFavorite = (id) => {
    const newFavs = favorites.includes(id) 
      ? favorites.filter(favId => favId !== id)
      : [...favorites, id];
    setFavorites(newFavs);
    localStorage.setItem('wordvault_favs', JSON.stringify(newFavs));
  };

  // Öğrenildi Yönetimi
  const toggleLearned = (id) => {
    const newLearned = learned.includes(id)
      ? learned.filter(lId => lId !== id)
      : [...learned, id];
    setLearned(newLearned);
    localStorage.setItem('wordvault_learned', JSON.stringify(newLearned));
    
    // Eğer öğrenildi olarak işaretlendiyse ve sonraki kelime varsa otomatik geç
    if (!learned.includes(id) && currentIndex < filteredWords.length - 1) {
      setTimeout(() => {
        handleNext();
      }, 300);
    }
  };

  const handleNext = () => {
    if (currentIndex < filteredWords.length - 1) {
      setCurrentIndex(currentIndex + 1);
      setIsFlipped(false);
      setShowMnemonic(false);
    }
  };

  const handlePrev = () => {
    if (currentIndex > 0) {
      setCurrentIndex(currentIndex - 1);
      setIsFlipped(false);
      setShowMnemonic(false);
    }
  };

  const speakWord = (text) => {
    if ('speechSynthesis' in window) {
      const utterance = new SpeechSynthesisUtterance(text);
      utterance.lang = 'en-US';
      window.speechSynthesis.speak(utterance);
    }
  };

  // 3. DEĞİŞİKLİK: Uygulamanın çömesini engellemek için koruma satırları
  if (loading) {
    return (
      <div className="min-h-screen bg-[#0B132B] flex flex-col items-center justify-center text-white">
        <div className="animate-spin text-cyan-400 mb-4">
          <Layers size={48} />
        </div>
        <p className="text-xl font-semibold tracking-wider animate-pulse">WORDVAULT YÜKLENİYOR</p>
      </div>
    );
  }

  if (words.length === 0) {
    return (
      <div className="min-h-screen bg-[#0B132B] flex flex-col items-center justify-center text-white p-4 text-center">
        <XCircle size={48} className="text-red-500 mb-4" />
        <p className="text-xl font-semibold">Kelimeler yüklenemedi!</p>
        <p className="text-gray-400 mt-2 text-sm">src/words.json dosyasının doğru formatta olduğunu kontrol edin.</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#0B132B] text-gray-100 font-sans pb-12">
      {/* Üst Bar */}
      <header className="border-b border-[#1C2541] bg-[#0B132B]/80 backdrop-blur sticky top-0 z-50 px-4 py-4">
        <div className="max-w-md mx-auto flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div className="p-2 bg-cyan-500/10 rounded-xl text-cyan-400 border border-cyan-500/20 shadow-[0_0_15px_rgba(34,211,238,0.1)]">
              <Layers size={20} />
            </div>
            <div>
              <h1 className="text-lg font-bold tracking-tight bg-gradient-to-r from-white via-gray-200 to-cyan-400 bg-clip-text text-transparent">WordVault</h1>
              <p className="text-[10px] text-cyan-400/70 font-mono uppercase tracking-widest">YDS Vocab V1.0</p>
            </div>
          </div>
          
          {/* İlerleme Özeti */}
          <div className="flex items-center gap-3 text-xs bg-[#1C2541]/50 px-3 py-1.5 rounded-full border border-[#3A506B]/30">
            <span className="text-gray-400">Öğrenilen: <strong className="text-green-400 font-mono">{learned.length}</strong></span>
            <span className="text-[#3A506B]">|</span>
            <span className="text-gray-400">Favori: <strong className="text-amber-400 font-mono">{favorites.length}</strong></span>
          </div>
        </div>
      </header>

      <main className="max-w-md mx-auto px-4 mt-6 space-y-6">
        {/* Arama ve Filtreleme */}
        <div className="bg-[#1C2541]/40 p-3 rounded-2xl border border-[#3A506B]/20 space-y-3">
          <div className="relative">
            <Search className="absolute left-3 top-2.5 text-gray-400" size={18} />
            <input 
              type="text" 
              placeholder="Kelime, anlam veya hafıza kartı ara..."
              value={searchTerm}
              onChange={(e) => { setSearchTerm(e.target.value); setCurrentIndex(0); }}
              className="w-full bg-[#0B132B] border border-[#3A506B]/40 rounded-xl pl-10 pr-4 py-2 text-sm text-white placeholder-gray-500 focus:outline-none focus:border-cyan-500 transition-colors"
            />
          </div>
          
          {/* Filtre Butonları */}
          <div className="grid grid-cols-4 gap-1 text-[11px] font-medium">
            {[
              { id: 'all', label: 'Tümü' },
              { id: 'favorites', label: 'Favoriler' },
              { id: 'notLearned', label: 'Kalanlar' },
              { id: 'learned', label: 'Öğrenilen' }
            ].map(btn => (
              <button
                key={btn.id}
                onClick={() => { setFilterMode(btn.id); setCurrentIndex(0); setIsFlipped(false); }}
                className={`py-1.5 rounded-lg border transition-all ${
                  filterMode === btn.id 
                    ? 'bg-cyan-500/10 border-cyan-500/40 text-cyan-400 font-semibold shadow-[0_0_10px_rgba(34,211,238,0.05)]' 
                    : 'bg-[#0B132B]/40 border-transparent text-gray-400 hover:bg-[#0B132B]'
                }`}
              >
                {btn.label}
              </button>
            ))}
          </div>
        </div>

        {/* Ana Kart Alanı */}
        {filteredWords.length > 0 && currentWord ? (
          <div className="space-y-6">
            {/* Kelime Sayacı */}
            <div className="flex justify-between items-center text-xs text-gray-400 font-mono px-1">
              <span>Filtre sonucu: {filteredWords.length} kelime</span>
              <span className="text-cyan-400">{currentIndex + 1} / {filteredWords.length}</span>
            </div>

            {/* Flashcard (3D Flip Effect) */}
            <div className="perspective-1000 h-64 w-full cursor-pointer" onClick={() => setIsFlipped(!isFlipped)}>
              <div className={`relative w-full h-full duration-500 transform-style-3d ${isFlipped ? 'rotate-y-180' : ''}`}>
                
                {/* ÖN YÜZ */}
                <div className="absolute inset-0 backface-hidden bg-gradient-to-b from-[#1C2541] to-[#111A36] rounded-3xl border border-[#3A506B]/30 p-6 flex flex-col justify-between shadow-xl">
                  <div className="flex justify-between items-start">
                    <span className="text-[10px] uppercase tracking-widest font-mono text-cyan-400/70 bg-cyan-500/5 px-2 py-0.5 rounded border border-cyan-500/10">
                      {currentWord.type}
                    </span>
                    <div className="flex gap-2" onClick={(e) => e.stopPropagation()}>
                      <button onClick={() => toggleFavorite(currentWord.id)} className="text-gray-400 hover:text-amber-400 transition-colors p-1">
                        {favorites.includes(currentWord.id) ? <BookmarkCheck className="text-amber-400" size={22} /> : <Bookmark size={22} />}
                      </button>
                    </div>
                  </div>

                  <div className="text-center space-y-2">
                    <h2 className="text-3xl font-bold tracking-wide text-white">{currentWord.word}</h2>
                    <p className="text-xs text-gray-400 font-mono italic">{currentWord.pronunciation}</p>
                  </div>

                  <div className="flex justify-between items-center" onClick={(e) => e.stopPropagation()}>
                    <button 
                      onClick={() => speakWord(currentWord.word)} 
                      className="p-2.5 bg-[#0B132B] border border-[#3A506B]/30 rounded-xl text-gray-400 hover:text-white hover:border-cyan-500/50 transition-all"
                    >
                      <Volume2 size={18} />
                    </button>
                    <span className="text-[11px] text-gray-500 font-medium animate-pulse">Kartı çevirmek için tıkla</span>
                  </div>
                </div>

                {/* ARKA YÜZ */}
                <div className="absolute inset-0 backface-hidden rotate-y-180 bg-gradient-to-b from-[#152244] to-[#0B132B] rounded-3xl border border-cyan-500/30 p-6 flex flex-col justify-between shadow-[0_0_25px_rgba(34,211,238,0.05)]">
                  <div className="flex justify-between items-center">
                    <span className="text-[10px] uppercase tracking-widest font-mono text-emerald-400 bg-emerald-500/5 px-2 py-0.5 rounded border border-emerald-500/10">Anlamı</span>
                    <button 
                      onClick={(e) => { e.stopPropagation(); toggleLearned(currentWord.id); }} 
                      className={`flex items-center gap-1.5 text-xs px-2.5 py-1 rounded-lg border transition-all ${
                        learned.includes(currentWord.id)
                          ? 'bg-green-500/20 border-green-500/40 text-green-400'
                          : 'bg-[#1C2541] border-[#3A506B]/40 text-gray-400 hover:text-white'
                      }`}
                    >
                      <CheckCircle size={14} />
                      {learned.includes(currentWord.id) ? 'Öğrenildi' : 'Öğrendim İşaretle'}
                    </button>
                  </div>

                  <div className="text-center">
                    <h3 className="text-2xl font-bold text-cyan-400 tracking-wide">{currentWord.translation}</h3>
                  </div>

                  <div className="bg-[#0B132B]/60 border border-[#3A506B]/20 p-2.5 rounded-xl text-xs text-center text-gray-300 italic">
                    "{currentWord.example}"
                  </div>
                </div>

              </div>
            </div>

            {/* Mnemonic (Hafıza Teknikleri) Kartı */}
            <div className="bg-gradient-to-r from-[#1C2541]/60 to-[#1C2541]/30 border border-[#3A506B]/20 rounded-2xl p-4 space-y-3">
              <button 
                onClick={() => setShowMnemonic(!showMnemonic)}
                className="w-full flex items-center justify-between text-xs font-semibold tracking-wide text-cyan-400/90 uppercase"
              >
                <div className="flex items-center gap-1.5">
                  <Sparkles size={14} className="text-amber-400 animate-pulse" />
                  <span>Hafıza İpucu (Mnemonic)</span>
                </div>
                <span className="text-[10px] bg-[#0B132B] px-2 py-0.5 rounded text-gray-400 border border-[#3A506B]/20">
                  {showMnemonic ? 'Gizle' : 'Göster'}
                </span>
              </button>
              
              {showMnemonic && (
                <div className="text-sm text-gray-200 border-t border-[#3A506B]/20 pt-2.5 leading-relaxed animate-fadeIn">
                  {currentWord.mnemonic}
                </div>
              )}
            </div>

            {/* Navigasyon Kontrolleri */}
            <div className="flex gap-3 pt-2">
              <button 
                onClick={handlePrev}
                disabled={currentIndex === 0}
                className="flex-1 bg-[#1C2541] hover:bg-[#222F54] disabled:opacity-30 border border-[#3A506B]/30 py-3.5 rounded-xl flex items-center justify-center transition-all active:scale-95 text-sm font-medium"
              >
                <ChevronLeft size={20} className="mr-1" /> Geri
              </button>
              <button 
                onClick={handleNext}
                disabled={currentIndex === filteredWords.length - 1}
                className="flex-1 bg-gradient-to-r from-cyan-500 to-blue-600 hover:from-cyan-400 hover:to-blue-500 disabled:from-gray-700 disabled:to-gray-800 disabled:opacity-30 py-3.5 rounded-xl flex items-center justify-center font-semibold text-sm tracking-wide shadow-lg shadow-cyan-500/10 active:scale-95 transition-all text-white"
              >
                İleri <ChevronRight size={20} className="ml-1" />
              </button>
            </div>
          </div>
        ) : (
          <div className="bg-[#1C2541]/20 border border-[#3A506B]/20 rounded-2xl p-8 text-center space-y-3">
            <HelpCircle size={40} className="text-gray-500 mx-auto" />
            <p className="text-sm text-gray-400">Bu filtreye uygun kelime bulunamadı.</p>
            <button 
              onClick={() => { setFilterMode('all'); setSearchTerm(''); }}
              className="text-xs text-cyan-400 underline decoration-cyan-400/30 underline-offset-4"
            >
              Filtreleri Sıfırla
            </button>
          </div>
        )}
      </main>
    </div>
  );
}

export default App;
