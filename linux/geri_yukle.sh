#!/bin/bash

# ---- AYARLAR ----
YEREL_YEDEKLER_DIZINI="/mnt/yedekler/gunluk" # Yerel yedeklerin indirileceği veya bulunduğu dizin
TEMP_INDIRME_DIZINI="/tmp/indirilen_yedekler" # Buluttan indirilen yedekler için geçici dizin

RCLONE_REMOTE_ADI="gdrive" # rclone config ile ayarladığınız Google Drive remote adı
GDRIVE_KAYNAK_KLASOR="OtomatikYedekler/important_files" # Google Drive'da yedeklerin bulunduğu klasör

GERI_YUKLEME_HEDEF_DIZINI="/"
LOG_DOSYASI="/var/log/geri_yukleme.log"

# ---- FONKSIYONLAR ----
log_mesaji() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_DOSYASI"
}

# ---- ANA İŞLEM ----
mkdir -p "$YEREL_YEDEKLER_DIZINI"
mkdir -p "$TEMP_INDIRME_DIZINI"

echo "Geri yükleme kaynağı seçin:"
echo "1. Yerel yedek dosyası"
echo "2. Google Drive'dan indir"
read -p "Seçiminiz (1 veya 2): " KAYNAK_SECIMI

YEDEK_DOSYASI_YOLU=""

if [ "$KAYNAK_SECIMI" == "1" ]; then
    echo "Mevcut yerel yedekler ($YEREL_YEDEKLER_DIZINI):"
    ls -lh "$YEREL_YEDEKLER_DIZINI"/*.tar.gz 2>/dev/null | awk '{print $9}' || echo "Yerel yedek bulunamadı."
    read -p "Geri yüklenecek yerel yedek dosyasının tam yolunu veya adını girin: " GIRILEN_YEDEK_ADI
    
    if [ -f "$GIRILEN_YEDEK_ADI" ]; then # Tam yol girilmişse
        YEDEK_DOSYASI_YOLU="$GIRILEN_YEDEK_ADI"
        
    elif [ -f "$YEREL_YEDEKLER_DIZINI/$GIRILEN_YEDEK_ADI" ]; then # Sadece dosya adı girilmişse
        YEDEK_DOSYASI_YOLU="$YEREL_YEDEKLER_DIZINI/$GIRILEN_YEDEK_ADI"
    fi
    
elif [ "$KAYNAK_SECIMI" == "2" ]; then
    echo "Google Drive'daki yedekler ($RCLONE_REMOTE_ADI:$GDRIVE_KAYNAK_KLASOR/):"
    rclone lsf "$RCLONE_REMOTE_ADI:$GDRIVE_KAYNAK_KLASOR/" --files-only # Sadece dosyaları listeler
    # Alternatif olarak daha detaylı liste: rclone ls "$RCLONE_REMOTE_ADI:$GDRIVE_KAYNAK_KLASOR/"

    read -p "Google Drive'dan indirilecek yedek dosyasının adını girin (örn: website_yedek_20250517_153000.tar.gz): " BULUT_YEDEK_DOSYASI_ADI

    if [ -z "$BULUT_YEDEK_DOSYASI_ADI" ]; then
        log_mesaji "HATA: Google Drive'dan indirilecek dosya adı girilmedi."
        exit 1
    fi

    YEDEK_DOSYASI_YOLU="$TEMP_INDIRME_DIZINI/$BULUT_YEDEK_DOSYASI_ADI"
    log_mesaji "Yedek dosyası Google Drive'dan indiriliyor: $RCLONE_REMOTE_ADI:$GDRIVE_KAYNAK_KLASOR/$BULUT_YEDEK_DOSYASI_ADI -> $YEDEK_DOSYASI_YOLU"
    #echo "Yedek dosyası Google Drive'dan indiriliyor: $RCLONE_REMOTE_ADI:$GDRIVE_KAYNAK_KLASOR/$BULUT_YEDEK_DOSYASI_ADI -> $YEDEK_DOSYASI_YOLU"
    
    rclone copyto "$RCLONE_REMOTE_ADI:$GDRIVE_KAYNAK_KLASOR/$BULUT_YEDEK_DOSYASI_ADI" "$YEDEK_DOSYASI_YOLU" --progress --log-file="$LOG_DOSYASI.rclone_download"

    if [ $? -ne 0 ]; then
        log_mesaji "HATA: Yedek dosyası Google Drive'dan indirilemedi: $BULUT_YEDEK_DOSYASI_ADI. rclone logunu kontrol edin: $LOG_DOSYASI.rclone_download"
        exit 1
    fi
    log_mesaji "Yedek dosyası başarıyla indirildi: $YEDEK_DOSYASI_YOLU"
else
    log_mesaji "Geçersiz kaynak seçimi."
    exit 1
fi


if [ -z "$YEDEK_DOSYASI_YOLU" ] || [ ! -f "$YEDEK_DOSYASI_YOLU" ]; then
    log_mesaji "HATA: Yedek dosyası bulunamadı veya belirlenemedi: $YEDEK_DOSYASI_YOLU"
    exit 1
fi

read -p "UYARI: '$YEDEK_DOSYASI_YOLU' içeriği '$GERI_YUKLEME_HEDEF_DIZINI' dizinine AÇILACAKTIR ve mevcut dosyaların üzerine yazılabilir. Devam etmek istiyor musunuz? (evet/hayır): " ONAY

if [ "$ONAY" != "evet" ]; then
    log_mesaji "Geri yükleme işlemi kullanıcı tarafından iptal edildi."
    echo "Geri yükleme iptal edildi."
    # Eğer buluttan indirildiyse ve iptal edildiyse geçici dosyayı sil
    if [ "$KAYNAK_SECIMI" == "2" ] && [ -f "$YEDEK_DOSYASI_YOLU" ]; then
        rm "$YEDEK_DOSYASI_YOLU"
        log_mesaji "İndirilen geçici yedek dosyası silindi: $YEDEK_DOSYASI_YOLU"
    fi
    exit 0
fi

log_mesaji "Geri yükleme işlemi başlatılıyor: $YEDEK_DOSYASI_YOLU -> $GERI_YUKLEME_HEDEF_DIZINI"
tar -xzf "$YEDEK_DOSYASI_YOLU" -C "$GERI_YUKLEME_HEDEF_DIZINI"

if [ $? -eq 0 ]; then
    log_mesaji "Geri yükleme başarıyla tamamlandı: $YEDEK_DOSYASI_YOLU -> $GERI_YUKLEME_HEDEF_DIZINI"
    echo "Geri yükleme başarıyla tamamlandı."
    # İndirilen geçici yedek dosyasını sil (eğer buluttan indirildiyse ve işlem başarılıysa)
    if [ "$KAYNAK_SECIMI" == "2" ] && [ -f "$YEDEK_DOSYASI_YOLU" ]; then
        rm "$YEDEK_DOSYASI_YOLU"
        log_mesaji "İndirilen geçici yedek dosyası silindi: $YEDEK_DOSYASI_YOLU"
    fi
else
    log_mesaji "HATA: Geri yükleme işlemi başarısız oldu!"
    echo "HATA: Geri yükleme işlemi başarısız oldu."
    exit 1
fi

exit 0