# Dokumentasi & Status Proyek UTS Platformer 2D (Godot 4)

Dokumen ini dibuat sebagai ringkasan akurat dan panduan serah terima (*handover*) status pengerjaan proyek game platformer 2D untuk sesi selanjutnya.

---

## 1. Ringkasan Struktur Game (Tepat 3 Level / World)

Game ini dirancang dengan struktur linear bertingkat yang terdiri dari **tepat 3 Level (World)**:

| Level | Scene Path | Tema Visual | Fitur Utama & Rintangan | Titik Akhir / Selesai |
|---|---|---|---|---|
| **World 1** | `res://Scenes/world_1.tscn` | **Benteng Batu (Castle/Fortress)**<br>- Tile bata abu-abu (`Terrain (16x16).png`)<br>- Background abu-abu (`Gray.png`) | - 2 Checkpoint aktif (`Checkpoint_GrandHall`, `Checkpoint_Ramparts`)<br>- Saw Trap berpatroli (gergaji besi)<br>- Fire Trap (semburan api)<br>- Parit berduri (Spikes) & Trampolin pantul<br>- Buah: Apple (1 pt), Banana (2 pt), Cherries (5 pt) | Bendera Portal `ExitToWorld2` menuju World 2 |
| **World 2** | `res://Scenes/world_2.tscn` | **Hutan Kanopi (Forest/Canopy)**<br>- Tile tanah hijau bertingkat<br>- Background hijau (`Green.png`) | - Platforming vertikal melewati jurang<br>- Spikes hazard & Trampolin penyelamat<br>- Buah-buahan bertaburan | Bendera Portal `ExitToWorld3` menuju World 3 |
| **World 3** | `res://Scenes/world_3.tscn` | **Sanctuari Kerajaan (Citadel Sanctuary)**<br>- Tile batu & balok kastil<br>- Background ungu (`Purple.png`) | - Precision jumping di atas deretan duri<br>- Platform sempit & buah berharga tinggi | **Golden Victory Trophy** (`end_trophy.tscn`) |

---

## 2. Alur Game & Sistem Transisi Antar Level

```
[Main (main.tscn)]
       │
       ▼
 [World 1 (Benteng)]  ──(Portal Bendera ExitToWorld2)──►  [World 2 (Hutan)]
                                                                   │
                                                                   ▼ (Portal Bendera ExitToWorld3)
                                                          [World 3 (Citadel Final)]
                                                                   │
                                                                   ▼ (Sentuh Trophy Emas)
                                                            [ WIN PANEL HUD ]
                                                      "CONGRATULATIONS! ALL WORLDS CLEARED!"
```

- **Scene Utama (Root Project)**: `res://Scenes/main.tscn` (didaftarkan pada `project.godot` sebagai `run/main_scene`).
- **Autoload Singleton (`GameManager`)**:
  - Path: `res://Scripts/game_manager.gd`
  - Mengelola `total_score` agar skor buah yang dikumpulkan **tidak ter-reset** saat pindah dari World 1 ke World 2 dan World 3.

---

## 3. Fitur Pemain & Kontrol (Sesuai Ketentuan `task.md`)

- **Input Map Kustom** (Dikonfigurasi di `project.godot`):
  - Gerak Kiri: Tombol **A** atau Panah Kiri (`move_left`)
  - Gerak Kanan: Tombol **D** atau Panah Kanan (`move_right`)
  - Lompat: Tombol **W** atau Space atau Panah Atas (`jump`)
- **Player Character** (`res://Scenes/player.tscn` & `res://Scripts/player.gd`):
  - Memakai AnimatedSprite2D 3 variasi: `idle`, `run`, `jump`.
  - Sprite otomatis membalik arah (flip horizontal) sesuai arah gerak.
  - Lompat hanya bisa dilakukan saat `is_on_floor()`.
  - Dilengkapi `Camera2D` yang mengikuti pemain secara halus.
  - HUD di tengah atas layar menampilkan `SCORE: X`.

---

## 4. Mekanisme Checkpoint & Respawn

- **Checkpoint** (`res://Scenes/checkpoint.tscn` & `res://Scripts/checkpoint.gd`):
  - Terdapat 2 Checkpoint di World 1.
  - Memiliki animasi unroll bendera catur (`flag_out` dilanjutkan `flag_idle`).
  - Saat tersentuh, HUD pemain menampilkan notifikasi `"CHECKPOINT REACHED!"` dan `spawn_position` pemain diperbarui ke titik bendera tersebut.
- **Respawn System**:
  - Jika pemain menyentuh duri (Spikes), terkena gergaji (Saw), atau api (Fire), fungsi `die_and_respawn()` dipanggil.
  - Pemain langsung di-respawn kembali ke Checkpoint terakhir yang aktif tanpa mereset perolehan skor pemain.

---

## 5. Rintangan, Jebakan & Objek Interaktif

1. **Saw Trap** (`res://Scenes/saw_trap.tscn` & `res://Scripts/saw_trap.gd`):
   - Gergaji besi berputar animasi 8-frame.
   - Bergerak bolak-balik secara dinamis sesuai parameter `move_distance` dan `speed`.
2. **Fire Trap** (`res://Scenes/fire_trap.tscn` & `res://Scripts/fire_trap.gd`):
   - Semburan api berkala pada blok lantai.
3. **Spikes** (`res://Scenes/spikes.tscn` & `res://Scripts/spikes.gd`):
   - Deretan duri tajam yang memicu respawn.
4. **Trampoline** (`res://Scenes/trampoline.tscn` & `res://Scripts/trampoline.gd`):
   - Melontarkan pemain ke atas dengan animasi pegas.
5. **Collectibles (Buah)**:
   - Apple (`apple.tscn`): 1 Poin
   - Banana (`banana.tscn`): 2 Poin
   - Cherries (`cherries.tscn`): 5 Poin
6. **Victory Trophy** (`res://Scenes/end_trophy.tscn` & `res://Scripts/end_trophy.gd`):
   - Terletak di akhir World 3. Menampilkan layar panel kemenangan dan skor akhir akumulatif.

---

## 6. Standar Level Building & Fisika Tilemap

- **146 Collision Polygons Aktif**: Seluruh tile pada `TileSetAtlasSource` memiliki poligon tabrakan fisika solid, mencegah pemain tembus lantai atau dinding.
- **Ketinggian Lompat Aman**: Selisih tinggi antar platform diatur maksimal $\le 3$ blok (48 px) sehingga tidak ada platform yang terlalu tinggi atau membuat pemain stuck.
- **Lebar Celah / Lorong**: Semua lorong dan gap platform berukuran $\ge 3-4$ blok (melebihi batas minimal ketentuan $2 \times 2$ blok).

---

## 7. Lokasi File & Status Git

- **Folder Project Godot**: `C:\Users\Asus Ryzen3\Documents\uts-nama`
- **Folder Data Workspace**: `C:\Users\Asus Ryzen3\Documents\godotdata`
- **Git Remote**: `https://github.com/danielhengkerpro/uts-daniel.git`
- **Branch**: `main`
- **Status Commit**: Semua perubahan, scene, script, dan asset telah di-commit dan di-push ke branch `main`.
