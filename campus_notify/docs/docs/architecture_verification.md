Tabel Usulan vs Keputusan FinalItem EvaluasiUsulan Awal AIKeputusan Final PengembangAlasan TeknisUse Case CRUDBuat GetAnnouncementsUseCaseDitolak (Bypass)Operasi hanya baca 1 baris; delegasi langsung ke AnnouncementRepository via Riverpod FutureProvider.Use Case AuthBuat LoginWithCampusIdDiterimaMengkoordinasikan validasi input, persistensi storage, dan sinkronisasi push notification payload.Entity MappingSerialisasi di ModelDiterimaMencegah library JSON pihak ketiga bocor ke entitas domain.DI ToolingRiverpod Provider bawaanDiterimaMenghindari dependensi tambahan dan menyatukan state management dengan DI.



[ Presentation ]
  (Widget / Page / Provider)
         │
         ▼  (bergantung pada)
   [ Domain ]   ◄──────────────────┐ (mengimplementasikan)
(Entities / Repositories Interface) │
                                   │
                           [ Data Layer ]
                    (Models / Repositories Impl)