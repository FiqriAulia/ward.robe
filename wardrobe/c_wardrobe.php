<?php
// Controller: aturan bisnis di atas model (validasi jenis, upload foto, dll).

require_once __DIR__ . '/m_wardrobe.php';

class c_wardrobe
{
    private m_wardrobe $model;

    public function __construct()
    {
        $this->model = new m_wardrobe();
    }

    /** Jenis pakaian dari input user; 404 bila tidak dikenal. */
    public function requireType(mixed $type): string
    {
        if (!is_string($type) || !isset(m_wardrobe::TYPES[$type])) {
            not_found();
        }
        return $type;
    }

    public static function label(string $type): string
    {
        return m_wardrobe::TYPES[$type]['label'] ?? $type;
    }

    public function getAllData(): array
    {
        return $this->model->getAllData();
    }

    public function getByType(string $type): array
    {
        return $this->model->getByType($type);
    }

    public function getAllLaundryData(): array
    {
        return $this->model->getAllLaundryData();
    }

    public function getLaundryCandidates(): array
    {
        return $this->model->getLaundryCandidates();
    }

    public function dressMe(): array
    {
        return $this->model->dressMe();
    }

    /** Pakaian berdasarkan jenis & id dari input user; 404 bila tidak ada. */
    public function requireItem(string $type, mixed $id): array
    {
        $id = to_id($id);
        $item = $id === null ? null : $this->model->find($type, $id);
        if ($item === null) {
            not_found();
        }
        return $item;
    }

    /** Simpan pakaian baru. Foto yang sudah ter-upload dihapus lagi bila insert gagal. */
    public function addItem(string $type, string $nama, string $deskripsi, array $file): void
    {
        $foto = store_uploaded_image($file);
        try {
            $this->model->insert($type, $nama, $deskripsi, $foto);
        } catch (Throwable $e) {
            delete_image($foto);
            throw $e;
        }
    }

    /** Ubah pakaian. Foto baru opsional; foto lama baru dihapus setelah update berhasil. */
    public function editItem(array $item, string $nama, string $deskripsi, ?array $file): void
    {
        $newFoto = null;
        if ($file !== null && ($file['error'] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_NO_FILE) {
            $newFoto = store_uploaded_image($file);
        }

        try {
            $this->model->update($item['jenis'], (int) $item['id'], $nama, $deskripsi, $newFoto ?? $item['foto']);
        } catch (Throwable $e) {
            if ($newFoto !== null) {
                delete_image($newFoto);
            }
            throw $e;
        }

        if ($newFoto !== null) {
            delete_image($item['foto']);
        }
    }

    /** Jual (hapus) pakaian. Foto dihapus hanya setelah data di DB berhasil dihapus. */
    public function sellItems(string $type, array $ids): int
    {
        $sold = 0;
        foreach ($ids as $rawId) {
            $id = to_id($rawId);
            $item = $id === null ? null : $this->model->find($type, $id);
            if ($item === null) {
                continue;
            }
            $this->model->delete($type, $id);
            delete_image($item['foto']);
            $sold++;
        }
        return $sold;
    }

    /**
     * Masukkan pakaian ke laundry. Setiap nilai berbentuk "jenis:id".
     * @return int jumlah pakaian yang benar-benar ditambahkan.
     */
    public function addToLaundry(array $keys): int
    {
        $added = 0;
        foreach ($keys as $key) {
            [$type, $rawId] = array_pad(explode(':', $key, 2), 2, '');
            $id = to_id($rawId);
            if (!isset(m_wardrobe::TYPES[$type]) || $id === null) {
                continue;
            }
            if ($this->model->addToLaundry($type, $id)) {
                $added++;
            }
        }
        return $added;
    }

    public function removeFromLaundry(array $laundryIds): int
    {
        $removed = 0;
        foreach ($laundryIds as $rawId) {
            $id = to_id($rawId);
            if ($id !== null) {
                $this->model->removeFromLaundry($id);
                $removed++;
            }
        }
        return $removed;
    }

    public function passwordHash(): ?string
    {
        return $this->model->getSetting('password_hash');
    }

    /** Set password pertama kali. @return bool false bila sudah pernah di-set. */
    public function setInitialPassword(string $password): bool
    {
        return $this->model->addSettingIfMissing('password_hash', password_hash($password, PASSWORD_DEFAULT));
    }

    public function rehashPassword(string $password): void
    {
        $this->model->setSetting('password_hash', password_hash($password, PASSWORD_DEFAULT));
    }
}
