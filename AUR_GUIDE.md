# Session Manager AUR Package

## AUR'a Yükleme Adımları

### 1. Git Repository Oluştur

```bash
# yeni git repository oluştur
mkdir sessionmanager-aur
cd sessionmanager-aur
git init

# PKGBUILD kopyala
cp /home/livaiyena/Documents/niceideas/sessionmanager/PKGBUILD .

# .SRCINFO oluştur
makepkg --printsrcinfo > .SRCINFO

# git'e ekle
git add PKGBUILD .SRCINFO
git commit -m "initial commit: sessionmanager v1.0.0"
```

### 2. AUR Hesabı ve SSH Key

```bash
# ssh key oluştur (yoksa)
ssh-keygen -t ed25519 -C "youremail@example.com"

# public key'i kopyala
cat ~/.ssh/id_ed25519.pub

# AUR hesabına ekle: https://aur.archlinux.org/account/
```

### 3. AUR'a Push

```bash
# aur remote ekle
git remote add aur ssh://aur@aur.archlinux.org/sessionmanager.git

# push et
git push aur master
```

## Kullanıcılar İçin Kurulum

### İlk Kurulum

```bash
# yay ile kur
yay -S sessionmanager

# systemd service aktifleştir
systemctl --user enable sessionmanager.service
systemctl --user start sessionmanager.service
```

### Kullanım

```bash
# komutlar artık system-wide
sessionmanager monitor status
sessionmanager session start --topic "Work" --description "Coding" --duration 120
sessionmanager report daily
```

### Güncelleme

```bash
# otomatik güncelleme (tüm paketlerle birlikte)
yay -Syu

# sadece sessionmanager güncelle
yay -S sessionmanager
```

## Yeni Versiyon Yayınlama

### 1. Versiyon Güncelle

```bash
cd sessionmanager-aur

# PKGBUILD'de pkgver değiştir
vim PKGBUILD
# pkgver=1.0.0 → pkgver=1.1.0
# pkgrel=1 → pkgrel=1 (yeni versiyon ise 1'e sıfırla)

# .SRCINFO yeniden oluştur
makepkg --printsrcinfo > .SRCINFO
```

### 2. Push

```bash
git add PKGBUILD .SRCINFO
git commit -m "bump version to 1.1.0"
git push aur master
```

## Lokal Test

```bash
# paketi lokal olarak test et
cd sessionmanager-aur
makepkg -si

# çalıştığını kontrol et
sessionmanager --help
```

## Paket Bağımlılıkları

PKGBUILD'de tanımlı:
- **depends**: python, sqlite, hyprland
- **optdepends**: fish, bash-completion, zsh-completions

## Dosya Konumları

Paket kurulunca:
- `/usr/bin/sessionmanager` - ana komut
- `/usr/lib/python3.12/site-packages/sessionmanager/` - python modülleri
- `/usr/share/bash-completion/completions/` - bash completion
- `/usr/share/zsh/site-functions/` - zsh completion
- `/usr/share/fish/vendor_completions.d/` - fish completion
- `/usr/lib/systemd/user/sessionmanager.service` - systemd service
- `/usr/share/doc/sessionmanager/` - documentation

## AUR Package Linki

Package yayınlandıktan sonra:
- https://aur.archlinux.org/packages/sessionmanager
- Vote ve comment yapabilirler
- Orphan olduğunda maintain edebilirler
