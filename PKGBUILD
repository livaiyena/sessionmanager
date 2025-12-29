# Maintainer: Livaiyena <livaiyena@users.noreply.github.com>
pkgname=sessionmanager
pkgver=0.0.1
pkgrel=1
pkgdesc="cli-based activity tracker and session manager for hyprland"
arch=('any')
url="https://github.com/livaiyena/sessionmanager"
license=('GPL3')
depends=('python' 'sqlite' 'hyprland')
optdepends=(
    'fish: fish shell completion support'
    'bash-completion: bash completion support'
    'zsh-completions: zsh completion support'
)
source=("$pkgname-$pkgver.tar.gz::https://github.com/livaiyena/sessionmanager/archive/v$pkgver.tar.gz")
sha256sums=('SKIP')

package() {
    cd "$srcdir/$pkgname-$pkgver"
    
    # install main application
    install -Dm755 sessionmanager "$pkgdir/usr/bin/sessionmanager"
    
    # install python package
    install -dm755 "$pkgdir/usr/lib/python3.12/site-packages/sessionmanager"
    install -Dm644 src/sessionmanager/__init__.py "$pkgdir/usr/lib/python3.12/site-packages/sessionmanager/"
    install -Dm644 src/sessionmanager/config.py "$pkgdir/usr/lib/python3.12/site-packages/sessionmanager/"
    install -Dm644 src/sessionmanager/database.py "$pkgdir/usr/lib/python3.12/site-packages/sessionmanager/"
    install -Dm644 src/sessionmanager/monitor.py "$pkgdir/usr/lib/python3.12/site-packages/sessionmanager/"
    install -Dm644 src/sessionmanager/enforcer.py "$pkgdir/usr/lib/python3.12/site-packages/sessionmanager/"
    install -Dm644 src/sessionmanager/cli.py "$pkgdir/usr/lib/python3.12/site-packages/sessionmanager/"
    install -Dm644 src/sessionmanager/whitelist.py "$pkgdir/usr/lib/python3.12/site-packages/sessionmanager/"
    
    # install completions
    install -Dm644 completions/session_manager.bash "$pkgdir/usr/share/bash-completion/completions/sessionmanager"
    install -Dm644 completions/_session_manager "$pkgdir/usr/share/zsh/site-functions/_sessionmanager"
    install -Dm644 completions/session_manager.py.fish "$pkgdir/usr/share/fish/vendor_completions.d/sessionmanager.fish"
    
    # install systemd service
    install -Dm644 sessionmanager.service "$pkgdir/usr/lib/systemd/user/sessionmanager.service"
    
    # install documentation
    install -Dm644 README.md "$pkgdir/usr/share/doc/$pkgname/README.md"
}
