$(function () {
    // Prefix ke root aplikasi ('' atau '../'), di-set oleh PHP di <body data-base>.
    const base = document.body.dataset.base || '';

    // Landing: wizard menghilang lalu pindah ke home.
    $('.wizard').delay(3000).fadeOut('slow', function () {
        $('body').css('background-color', '#F5CB5C');
        window.location.href = base + 'home.php';
    });

    // Mata wizard mengikuti kursor (hanya di halaman yang ada wizard-nya).
    const anchor = document.getElementById('anchor');
    const eyes = document.querySelectorAll('.eye');
    if (anchor && eyes.length) {
        document.addEventListener('mousemove', function (e) {
            const rect = anchor.getBoundingClientRect();
            const anchorX = rect.left + rect.width / 2;
            const anchorY = rect.top + rect.height / 2;
            const angleDeg = Math.atan2(anchorY - e.clientY, anchorX - e.clientX) * 180 / Math.PI;
            eyes.forEach(function (eye) {
                eye.style.transform = 'rotate(' + (90 + angleDeg) + 'deg)';
            });
        });
    }

    // Klik wizard 3x: kembali ke home (wizard tidur lagi).
    onTripleClick('#anchor', base + 'home.php');

    // Klik judul "Wardrobe" 3x: easter egg.
    onTripleClick('#egg', base + 'wardrobe.php');

    // Minta konfirmasi untuk form yang menghapus data.
    $('form[data-confirm]').on('submit', function (e) {
        if (!window.confirm($(this).data('confirm'))) {
            e.preventDefault();
        }
    });

    function onTripleClick(selector, target) {
        let clicks = 0;
        $(selector).on('click', function () {
            clicks++;
            if (clicks === 3) {
                window.location.href = target;
            }
        });
    }
});
