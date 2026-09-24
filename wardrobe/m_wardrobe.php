<?php
// Model: semua akses database ada di sini.

class m_wardrobe
{
    /**
     * Deskripsi tiap jenis pakaian. Nama tabel/kolom di sini satu-satunya yang
     * boleh disisipkan langsung ke SQL; nilai dari user selalu lewat parameter.
     */
    public const TYPES = [
        'baju' => [
            'label' => 'Baju',
            'table' => 'baju',
            'id' => 'BAJU_ID',
            'nama' => 'BAJU_NAMA',
            'deskripsi' => 'BAJU_DESKRIPSI',
            'foto' => 'BAJU_FOTO',
            'laundry' => 'LAUNDRY_BAJU_ID',
            'proc' => 'Baju',
        ],
        'celana' => [
            'label' => 'Celana',
            'table' => 'celana',
            'id' => 'CELANA_ID',
            'nama' => 'CEL_NAMA',
            'deskripsi' => 'CEL_DESKRIPSI',
            'foto' => 'CEL_FOTO',
            'laundry' => 'LAUNDRY_CEL_ID',
            'proc' => 'Celana',
        ],
        'aksesoris' => [
            'label' => 'Aksesoris',
            'table' => 'aksesoris',
            'id' => 'AKSESORIS_ID',
            'nama' => 'ACC_NAMA',
            'deskripsi' => 'ACC_DESKRIPSI',
            'foto' => 'ACC_FOTO',
            'laundry' => 'LAUNDRY_ACC_ID',
            'proc' => 'Aksesoris',
        ],
    ];

    private const DUPLICATE_KEY = 1062;

    /** Semua pakaian; kolom: jenis, id, nama, deskripsi, foto. */
    public function getAllData(): array
    {
        return db_rows('CALL DisplayAllData()');
    }

    public function getAllLaundryData(): array
    {
        return db_rows('CALL GetAllLaundryData()');
    }

    public function dressMe(): array
    {
        return db_rows('CALL Dress_Me()');
    }

    /** Semua pakaian satu jenis, dengan kolom yang sama seperti getAllData(). */
    public function getByType(string $type): array
    {
        return db_rows($this->selectSql($type) . ' ORDER BY nama');
    }

    public function find(string $type, int $id): ?array
    {
        $t = self::TYPES[$type];
        $rows = db_rows($this->selectSql($type) . " WHERE {$t['id']} = ?", 'i', [$id]);
        return $rows[0] ?? null;
    }

    public function insert(string $type, string $nama, string $deskripsi, string $foto): void
    {
        $proc = self::TYPES[$type]['proc'];
        db_rows("CALL Insert{$proc}(?, ?, ?)", 'sss', [$nama, $deskripsi, $foto]);
    }

    public function update(string $type, int $id, string $nama, string $deskripsi, string $foto): void
    {
        $proc = self::TYPES[$type]['proc'];
        db_rows("CALL Edit{$proc}(?, ?, ?, ?)", 'isss', [$id, $nama, $deskripsi, $foto]);
    }

    /** Menghapus pakaian; baris laundry-nya ikut terhapus (ON DELETE CASCADE). */
    public function delete(string $type, int $id): void
    {
        $proc = self::TYPES[$type]['proc'];
        db_rows("CALL DeleteFrom{$proc}(?)", 'i', [$id]);
    }

    /** Pakaian yang belum ada di laundry, semua jenis. */
    public function getLaundryCandidates(): array
    {
        $parts = [];
        foreach (self::TYPES as $type => $t) {
            $parts[] = $this->selectSql($type)
                . " WHERE NOT EXISTS (SELECT 1 FROM laundry l WHERE l.{$t['laundry']} = {$t['table']}.{$t['id']})";
        }
        return db_rows(implode(' UNION ALL ', $parts) . ' ORDER BY jenis, nama');
    }

    /** @return bool false bila pakaian itu sudah ada di laundry. */
    public function addToLaundry(string $type, int $id): bool
    {
        $params = [
            $type === 'baju' ? $id : null,
            $type === 'celana' ? $id : null,
            $type === 'aksesoris' ? $id : null,
        ];
        try {
            db_rows('CALL InsertIntoLaundry(?, ?, ?)', 'iii', $params);
            return true;
        } catch (mysqli_sql_exception $e) {
            if ($e->getCode() === self::DUPLICATE_KEY) {
                return false;
            }
            throw $e;
        }
    }

    public function removeFromLaundry(int $laundryId): void
    {
        db_rows('CALL DeleteFromLaundry(?)', 'i', [$laundryId]);
    }

    public function getSetting(string $key): ?string
    {
        $rows = db_rows('SELECT setting_value FROM app_settings WHERE setting_key = ?', 's', [$key]);
        return $rows[0]['setting_value'] ?? null;
    }

    public function setSetting(string $key, string $value): void
    {
        db_rows(
            'INSERT INTO app_settings (setting_key, setting_value) VALUES (?, ?)
             ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value)',
            'ss',
            [$key, $value]
        );
    }

    /** Simpan setting hanya kalau belum ada. @return bool true bila tersimpan. */
    public function addSettingIfMissing(string $key, string $value): bool
    {
        try {
            db_rows('INSERT INTO app_settings (setting_key, setting_value) VALUES (?, ?)', 'ss', [$key, $value]);
            return true;
        } catch (mysqli_sql_exception $e) {
            if ($e->getCode() === self::DUPLICATE_KEY) {
                return false;
            }
            throw $e;
        }
    }

    private function selectSql(string $type): string
    {
        $t = self::TYPES[$type];
        return "SELECT '{$type}' AS jenis, {$t['id']} AS id, {$t['nama']} AS nama,"
            . " {$t['deskripsi']} AS deskripsi, {$t['foto']} AS foto FROM {$t['table']}";
    }
}
