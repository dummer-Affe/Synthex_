# Synthex Stitch Tasarim Raporu

## 1. Proje Ozeti

- Uygulama Flutter ile yazilmis ve pratikte tek bir ekrandan olusuyor: `Live Interpreter`.
- Route yapisinda kullanilan tek anlamli sayfa `/liveInterpreter`; default route da ayni ekrana gidiyor.
- Uygulama sadece portre modunda calisiyor.
- Tasarim referans frame'i `390 x 844`; bu iPhone 12/13/14 tabanli bir mobil kompozisyon hissi veriyor.
- Tema `Material 3`, `dark` brightness ve `SF Pro Display` font ailesi ile kurulmus.
- Ekranda gorsel asset, fotograf, ilustrasyon veya bottom navigation yok; arayuz tamamen kartlar, metinler, sistem ikonlari ve CTA butonlari uzerine kurulu.

## 2. Tasarim Sistemi

### 2.1 Renk Paleti

| Token | Hex | Rol |
| --- | --- | --- |
| `background` | `#07111A` | Ana arka plan, en koyu zemin |
| `surface` | `#10202D` | Kartlarin ana yuzeyi |
| `surfaceStrong` | `#173243` | Gradient ust tonu, input fill rengi, daha kuvvetli panel hissi |
| `border` | `#2A4B5F` | Kart ve input stroke rengi |
| `primary` | `#44D7B6` | Ana aksan, secili state, aktif CTA, transcript aksani |
| `primarySoft` | `#173E40` | Sistem token olarak var, bu ekranda dogrudan gorunur kullanimi yok |
| `textHigh` | `#F3FAFF` | Ana baslik ve icerik metinleri |
| `textMid` | `#B1C6D3` | Status mesaji ve ikincil bilgi |
| `textLow` | `#7F9AAA` | Label, placeholder, dusuk vurgu |
| `success` | `#3DDC97` | Sistem token, bu ekranda aktif kullanilmiyor |
| `warning` | `#FFC857` | Translation aksani ve aktif/dinleme CTA tonu |
| `error` | `#FF6B6B` | Hata paneli |

### 2.2 Renk Turevleri ve Uygulama Kurallari

- Sayfa arka plani ustten alta lineer gradient: `surfaceStrong (#173243)` -> `background (#07111A)`.
- Tum ana kartlar: `surface` renginin `0.94` opaklikli varyanti + `border` stroke.
- Dropdown field fill: `surfaceStrong`.
- Transcript/translation ic kutusu: `surfaceStrong`, border ise kartin aksan renginin `%25` opakligi.
- Hata paneli: `error` `%12` dolgu + `%30` border.
- Hold CTA butonu: aksan rengi ile baslayan lineer gradient ve ikinci stop ayni rengin `%82` opakligi.
- Hold CTA golgesi: aktif aksan renginin `%25` opakligi.

### 2.3 Tipografi

- Tema seviyesinde hedef font: `SF Pro Display`.
- `pubspec.yaml` icinde custom font tanimi yok; yani Android veya bazi ortamlarda bu font garanti degil, sistem sans fallback devreye girebilir.
- Stitch tarafinda en guvenli yorum: `SF Pro Display` karakterinde, temiz, modern, iOS hissi veren neo-grotesk sans serif kullanmak.

| Rol | Font Size | Weight | Ek Not |
| --- | --- | --- | --- |
| Sayfa basligi | `22` | `700` | Ortalanmis baslik |
| Kart basligi (`Languages`) | `16` | `700` | Sola hizali |
| Kart satir basligi | `15` | `700` | `Live transcript`, `Translation` satiri |
| Buton/CTA etiketi | `15` | `700` | `letterSpacing: 0.2` |
| Dropdown value | `15` | `600` | Form field ana secim stili |
| Dropdown selected text | `14` | `600` | Dar alan icin ellipsis kullaniliyor |
| Body text | `15` | default/regular | `height: 1.45` |
| Status text | `13` | `600` | `height: 1.35`, center |
| Error text | `13` | default/regular | `height: 1.35` |
| Field label | `12` | `600` | `From`, `To` |

### 2.4 Spacing Sistemi

- Ana yatay bosluklar agirlikli olarak `16` ve `20`.
- Mikro bosluklar: `6`, `8`, `10`, `12`, `14`, `16`, `18`, `24`.
- Header padding: `20 / 16 / 20 / 12`.
- Scroll body padding: `16 / 4 / 16 / 18`.
- Bottom dock padding: `20 / 12 / 20 / 24`.
- Kartlar arasi dikey bosluk: `16`.
- Kart ic padding: `16`.
- Transcript text box ic padding: `14`.
- CTA padding:
  - Hold butonu: `18 x 18`
  - Mode butonlari: `12` dikey
  - Permission butonlari: `12 x 12`
- Header'da title'i tam ortalamak icin sag ve solda `48` px placeholder kullaniliyor.

### 2.5 Radius ve Stroke Sistemi

| Ogeler | Radius | Border |
| --- | --- | --- |
| Ana yuzey kartlari | `24` | `1px`, `border` |
| CTA hold paneli | `24` | Border yok, gradient fill |
| Hands-free button | `24` | Filled button |
| Transcript/translation ic paneli | `16` | `1px`, aksan renginin `%25` opakligi |
| Error paneli | `16` | `1px`, `error` renginin `%30` opakligi |
| Dropdown alanlari | `14` | Normalde `border`, focus'ta `primary` |

### 2.6 Shadow ve Motion

- Ekrandaki belirgin tek custom motion, hold-to-talk butonunda.
- `AnimatedContainer` sure: `160ms`.
- Easing: `easeOutCubic`.
- CTA shadow:
  - Idle blur: `14`
  - Active blur: `24`
  - Offset: `(0, 10)`
- Uygulama genel olarak sakin; abartili micro-animation, glassmorphism veya particle efektleri yok.

## 3. Bilesen Envanteri

### 3.1 Base Shell

- Full-screen dark scaffold.
- Safe area icinde ustte merkezli title, ortada scrollable card stack, altta sabit action dock.
- Background gradient sadece shell seviyesinde tanimlanmis; kartlar bu gradientin ustune yerlestiriliyor.

### 3.2 Header

- Baslik: `Live Interpreter`.
- Ilk ekranda geri butonu gosterilmiyor.
- Simetrik bosluklarla merkezleme yapiliyor; bu nedenle title her durumda optik olarak ortada kaliyor.

### 3.3 Surface Card

- Tum ana bloklar ayni kart primitive'ini kullaniyor.
- Fill: yarim opak koyu mavi-gri.
- Border: ince, soguk mavi stroke.
- Radius: `24`.

### 3.4 Language Selector Card

- Baslik: `Languages`.
- Icerik:
  - Sol dropdown: `From`
  - Orta ikon butonu: `swap_horiz_rounded`
  - Sag dropdown: `To`
- Varsayilan dil ciftleri:
  - Source: `English`
  - Target: `German`
- Desteklenen diller:
  - English
  - Turkish
  - Spanish
  - French
  - German
  - Italian
  - Portuguese
  - Hindi
  - Japanese
  - Korean

### 3.5 Transcript Card

- Baslik satiri: `record_voice_over` ikonu + `Live transcript - {source language}`.
- Aksan rengi: `primary`.
- Icerik alani minimum yukseklik: `112`.
- Text secilebilir (`SelectableText`), yani utilitarian/productivity odakli.
- Placeholder:
  - Hold mode: `Press and hold the mic button, then speak.`
  - Hands-free mode: `Tap the mic once, speak, then pause for 2 seconds.`
- Transcript doluysa:
  - sagda delete butonu gorunur
  - `Speak` tonal butonu gorunur

### 3.6 Translation Card

- Baslik satiri: `volume_up` ikonu + `Translation - {target language} - Auto TTS`.
- Aksan rengi: `warning`.
- Icerik alani transcript karti ile ayni primitive'i kullanir.
- Placeholder: `Translated text appears here.`
- Ceviri varsa `Speak` tonal butonu gorunur.

### 3.7 Bottom Dock

- Scroll disinda, sayfanin altina sabitlenmis hareket alani.
- Icinde su sirayla:
  - varsa error paneli
  - mode selector (`Hold` / `Hands-free`)
  - status text
  - ana CTA
  - gerekiyorsa permission butonlari

### 3.8 Mode Selector

- Iki secenekli, yatay yerlesimli segment benzeri kontrol.
- Secili buton filled `primary`.
- Secili olmayan buton outlined.
- Variants:
  - `Hold`
  - `Hands-free`

### 3.9 Main CTA

- Hold mode:
  - full-width, gradient dolgu, buyuk rounded panel gibi davranir
  - ikon: idle `mic_none`, aktif `mic`
  - idle metin: `Press And Hold To Talk`
  - preparing metin: `Preparing Native Tools`
  - active metin: `Release To Stop`
- Hands-free mode:
  - full-width filled button
  - idle metin: `Start Hands-Free`
  - active metin: `Stop Hands-Free`
- Aktif dinleme sirasinda aksan `primary` yerine `warning` tonuna kayiyor.

### 3.10 Supporting Actions

- Mikrofon izni yoksa iki outlined buton cikiyor:
  - `Grant mic`
  - `Settings`
- Error state oldugunda dock'un tepesinde kirmizi uyari paneli gorunuyor.

## 4. Sayfa Yapisi ve UX Akisi

### 4.1 Genel Hiyerarsi

1. Ustte net ve sade bir baslik
2. Dilleri secmeye yarayan kontrol karti
3. Gercek zamanli transcript karti
4. Ceviri karti
5. Altta sticky voice interaction dock

Bu hiyerarsi sayesinde kullanici once dil ciftini belirliyor, sonra gelen sesin ham halini goruyor, hemen altinda da hedef dildeki cevriyi izliyor. En kritik aksiyon olan mikrofon tetikleme ise ekranin en altinda, thumb-reach alaninda sabit.

### 4.2 Sayfa Davranisi

- Hold mode:
  - Kullanici butona basili tutar.
  - Sistem dinlemeye baslar.
  - Buton warning tonuna doner.
  - Kullanici birakinca son kelimeler toplanir, ceviri uretilir, gerekirse TTS oynatilir.
- Hands-free mode:
  - Kullanici bir kez basar.
  - Sistem 2 saniyelik pause mantigi ile segment bazli dinler.
  - Segment tamamlaninca ceviri uretilir ve auto-TTS tetiklenebilir.
  - Echo loop'u onlemek icin TTS sonrasinda 1.2 saniyelik speech blanking uygulanir.

### 4.3 Dinamik Metin ve Durumlar

Status alani sadece dekoratif degil; ekranin islevsel rehberligi burada.

Temel status tonlari:

- Hazirlaniyor: `Preparing native speech and offline translation...`
- Izin gerekiyor: `Grant microphone access to start speech input.`
- Idle hold: `Press and hold the mic button, then speak.`
- Idle hands-free: `Tap the mic to start hands-free listening.`
- Listening hold: `Listening on-device in {language}. Release to stop.`
- Listening hands-free: `Hands-free listening on-device in {language}...`
- Finalizing: `Finishing your last words...`
- Translating: `Translating final speech...`
- Model hazirlaniyor: `Preparing {source} -> {target} offline model...`

### 4.4 Uygulamanin Tonu

- Profesyonel
- Guven veren
- Teknik ama karmasik olmayan
- iOS benzeri premium utility hissi
- Cyberpunk veya oyun arayuzu gibi degil
- Klinik, net ve arac odakli

## 5. Stitch Icin Tasarim Yorumlari

Stitch bu ekrani uretirken asagidaki sinirlara uymali:

- Tek ekran uret; ek onboarding, ayarlar sayfasi, navigation drawer veya alt tab ekleme.
- Fotograf, avatar, ilustrasyon, mascot veya marketing hero kullanma.
- Layout mobile-first ve portre olsun.
- Scrollable card stack + sticky bottom action dock yapisini koru.
- Dark navy utility aesthetic korunmali; ama gereksiz neon, mor agirlikli cyberpunk, cam efekti veya parlak gradient kaosu olmamali.
- `Hold` ve `Hands-free` modlarini tasarimda ayri state/variant olarak dusun.
- Transcript ve translation alanlarini ayni bilesen ailesinin iki varyanti gibi kur.
- Utility-first, high legibility, low ornamentation.

## 6. Tasarim Riski ve Notlar

- Font riski: Kod `SF Pro Display` istiyor ama font asset olarak bundle edilmemis. Stitch tarafinda ayni hissi verecek iOS/system sans secilmeli.
- Responsive notu: `ScreenUtil` initialize edilmis olsa da ekran icindeki olculerin buyuk kismi sabit pixel degerleriyle yazilmis. Yani tasarim mantigi gercekte `390 x 844` kompozisyonuna daha yakin.
- Feature notu: View model'de `soundLevel`, `speechLocaleLabel`, `modelStatusLabel`, `toggleAutoSpeak` gibi alanlar var ama bu ekranda gorsellestirilmiyor. Stitch yeni bilesen uydurmamali; sadece istenirse ikinci iterasyonda eklenmeli.
- Sayfa sayisi: Projede anlamli olarak tek ekran var; Stitch'in cok sayfali akisa genisletmesine gerek yok.

## 7. Stitch Prompt

Asagidaki promptu Stitch'e direkt verebilirsin. En iyi sonuc icin bunu Ingilizce tuttum.

```text
Design a mobile-first iOS-style screen for a live speech translation app called "Live Interpreter". Use a 390x844 portrait frame and create a clean, premium dark utility interface, not a marketing page. The app should feel calm, professional, and highly legible, like a serious real-time translation tool.

Use this design system:
- Background gradient: top #173243 to bottom #07111A
- Card surface: #10202D at about 94% opacity
- Border/stroke: #2A4B5F
- Primary accent: #44D7B6
- Warning accent: #FFC857
- Error accent: #FF6B6B
- Primary text: #F3FAFF
- Secondary text: #B1C6D3
- Low-emphasis text: #7F9AAA
- Typography should feel like SF Pro Display / iOS system sans
- Main corner radii: 24 for cards and primary controls, 16 for inner content panels, 14 for dropdown fields

Create one single screen with this structure:
1. A centered top title: "Live Interpreter"
2. A language selection card titled "Languages"
3. A live transcript card
4. A translation card
5. A sticky bottom interaction dock

Language selection card:
- Two side-by-side dropdowns labeled "From" and "To"
- A compact swap icon button between them
- Default pair should feel like English to German
- Dropdowns should have dark filled backgrounds, thin borders, and compact rounded corners

Live transcript card:
- Leading voice-related icon in mint
- Header text format: "Live transcript - English"
- Optional compact delete action and a tonal "Speak" button on the right
- Large inner rounded text area with minimum medium height
- Empty state text should read like: "Press and hold the mic button, then speak."

Translation card:
- Leading speaker icon in amber
- Header text format: "Translation - German - Auto TTS"
- Same card family as transcript card
- Tonal "Speak" button when content exists
- Empty state text: "Translated text appears here."

Sticky bottom dock:
- Optional error panel at the top of the dock
- Two-option segmented control style selector: "Hold" and "Hands-free"
- A centered status message below the mode selector
- One large full-width primary CTA below that

CTA behavior and visual states:
- In Hold mode, the main CTA should look like a large press-and-hold panel with a subtle vertical gradient and soft glow shadow
- Idle label: "Press And Hold To Talk"
- Active label: "Release To Stop"
- Idle icon: outlined mic
- Active icon: filled mic
- When actively listening, the CTA should shift from mint to amber
- In Hands-free mode, use a full-width rounded filled button with labels like "Start Hands-Free" and "Stop Hands-Free"

If microphone permission is missing, show two compact secondary buttons under the CTA:
- "Grant mic"
- "Settings"

Important constraints:
- Do not add photos, avatars, onboarding slides, bottom navigation, charts, or decorative hero sections
- Keep the interface compact, functional, and product-oriented
- Preserve a strong card hierarchy and a fixed bottom action area
- Make transcript and translation cards reusable as part of the same component system
- Prioritize clarity, spacing rhythm, and premium iOS utility aesthetics over flashy effects

Please produce:
- the final mobile screen
- reusable components for the card, dropdown, segmented mode selector, and CTA
- variants for idle hold mode, active listening mode, hands-free mode, and error/permission state
```
