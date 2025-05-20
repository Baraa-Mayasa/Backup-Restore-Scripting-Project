#!/bin/bash

# ---- AYARLAR ----
KAYNAK_DIZIN="/home/baraa/Documents/important_files"
HEDEF_DIZIN="/mnt/yedekler/gunluk"
YEDEK_ADI="important_files_$(date +%Y%m%d_%H%M%S).tar.gz"
LOG_DOSYASI="/var/log/yedekleme.log"
RCLONE_REMOTE_ADI="gdrive" # rclone config ile ayarladığınız Google Drive remote adı
GDRIVE_HEDEF_KLASOR="OtomatikYedekler/important_files" # Google Drive'da yedeklerin yükleneceği klasör

# ---- FONKSIYONLAR ----
log_mesaji() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_DOSYASI"
}

# ---- ANA İŞLEM ----
mkdir -p "$HEDEF_DIZIN"
echo "Yedekleme işlemi başlatılıyor:"
log_mesaji "Yedekleme işlemi başlatılıyor: $KAYNAK_DIZIN -> $HEDEF_DIZIN/$YEDEK_ADI"
tar -czf "$HEDEF_DIZIN/$YEDEK_ADI" -P "$KAYNAK_DIZIN"

if [ $? -eq 0 ]; then
    log_mesaji "Yerel yedekleme başarıyla tamamlandı: $HEDEF_DIZIN/$YEDEK_ADI"
    echo "Yerel yedekleme başarıyla tamamlandı: $HEDEF_DIZIN/$YEDEK_ADI"
    
    # Eski yedekleri silme (opsiyonel - örneğin son 7 yedeği tut)
    #find "$HEDEF_DIZIN" -name "important_files_*.tar.gz" -type f -mtime +1 -delete
    #If you want to confirm deletion manually, replace -delete with -exec rm -i {} \;:
    find "$HEDEF_DIZIN" -name "important_files_*.tar.gz" -type f -mtime +1 -exec rm -i {} \;
    log_mesaji "1 günden eski yedekler silindi."
    
    
    # Google Drive'a yükleme (rclone ile)
    log_mesaji "Google Drive'a yükleme başlatılıyor: $HEDEF_DIZIN/$YEDEK_ADI -> $RCLONE_REMOTE_ADI:$GDRIVE_HEDEF_KLASOR/"
    echo "Google Drive'a yükleme başlatılıyor: $HEDEF_DIZIN/$YEDEK_ADI -> $RCLONE_REMOTE_ADI:$GDRIVE_HEDEF_KLASOR/"
    rclone copyto "$HEDEF_DIZIN/$YEDEK_ADI" "$RCLONE_REMOTE_ADI:$GDRIVE_HEDEF_KLASOR/$YEDEK_ADI" --progress

    if [ $? -eq 0 ]; then
        log_mesaji "Google Drive'a yükleme başarıyla tamamlandı."
        echo "Google Drive'a yükleme başarıyla tamamlandı."
        # İsteğe bağlı: Google Drive'a yüklendikten sonra yerel yedek dosyasını sil
        # rm "$HEDEF_DIZIN/$YEDEK_ADI"
        # log_mesaji "Yerel yedek dosyası ($HEDEF_DIZIN/$YEDEK_ADI) silindi."
    else
        log_mesaji "HATA: Google Drive'a yükleme başarısız oldu!"
    fi
else
    log_mesaji "HATA: Yerel yedekleme işlemi başarısız oldu!"
    exit 1
fi

exit 0
