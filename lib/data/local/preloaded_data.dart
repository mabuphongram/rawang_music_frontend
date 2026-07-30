import 'package:rawang_melodies/data/local/entity/entities.dart';

class PreloadedData {
  static final List<AlbumEntity> initialAlbums = [
    AlbumEntity(
      id: "alb_1",
      title: "Rawang Echoes of the Mountains",
      ownerType: OwnerType.singer.name,
      ownerName: "Ah Dang Rawang",
      coverResName: "img_rawang_hero_1785383680261",
      releaseYear: 2023,
      description: "Soulful vocal ballads preserving ancient Rawang poetry and acoustic acoustic guitar.",
      trackCount: 4,
    ),
    AlbumEntity(
      id: "alb_2",
      title: "Golden Highland Melodies",
      ownerType: OwnerType.singer.name,
      ownerName: "Seng Rawang",
      coverResName: "img_rawang_hero_1785383680261",
      releaseYear: 2024,
      description: "Celebrated modern and folk songs reflecting love for the Northern mountains.",
      trackCount: 3,
    ),
    AlbumEntity(
      id: "alb_3",
      title: "Rawang Heritage Archive Vol. 1",
      ownerType: OwnerType.organization.name,
      ownerName: "Rawang Literature & Culture Association",
      coverResName: "img_rawang_hero_1785383680261",
      releaseYear: 2021,
      description: "Official cultural field recordings of ritual chants, festivals, and folk lore.",
      trackCount: 4,
    ),
    AlbumEntity(
      id: "alb_4",
      title: "Northern Valley Choral Hymns",
      ownerType: OwnerType.organization.name,
      ownerName: "Rawang Youth Heritage Choir",
      coverResName: "img_rawang_hero_1785383680261",
      releaseYear: 2022,
      description: "Harmonious polyphonic choral singing in traditional Rawang dialects.",
      trackCount: 3,
    ),
    AlbumEntity(
      id: "alb_5",
      title: "Ancient River Chants & Rituals",
      ownerType: OwnerType.anonymous.name,
      ownerName: "Anonymous Collection",
      coverResName: "img_rawang_hero_1785383680261",
      releaseYear: 1998,
      description: "Traditional ancestral chants recorded across generations without individual author attribution.",
      trackCount: 3,
    ),
    AlbumEntity(
      id: "alb_6",
      title: "Bamboo Harp & Flute Solos",
      ownerType: OwnerType.anonymous.name,
      ownerName: "Anonymous Collection",
      coverResName: "img_rawang_hero_1785383680261",
      releaseYear: 2005,
      description: "Soothing instrumental bamboo flute (Pung-lu) and mouth harp melodies.",
      trackCount: 3,
    ),
    AlbumEntity(id: "alb_dummy_1", title: "John's Acoustic Hits", ownerType: OwnerType.singer.name, ownerName: "John Singer", coverResName: "img_rawang_hero_1785383680261", releaseYear: 2023, description: "Dummy album", trackCount: 1),
    AlbumEntity(id: "alb_dummy_2", title: "Maria's Folk Songs", ownerType: OwnerType.singer.name, ownerName: "Maria Artist", coverResName: "img_rawang_hero_1785383680261", releaseYear: 2022, description: "Dummy album", trackCount: 1),
    AlbumEntity(id: "alb_dummy_3", title: "David Unplugged", ownerType: OwnerType.singer.name, ownerName: "David Vocals", coverResName: "img_rawang_hero_1785383680261", releaseYear: 2021, description: "Dummy album", trackCount: 1),
    AlbumEntity(id: "alb_dummy_4", title: "Sarah's Classic Melodies", ownerType: OwnerType.singer.name, ownerName: "Sarah Melody", coverResName: "img_rawang_hero_1785383680261", releaseYear: 2024, description: "Dummy album", trackCount: 1),
    AlbumEntity(id: "alb_dummy_5", title: "Peter's Evening Tunes", ownerType: OwnerType.singer.name, ownerName: "Peter Tune", coverResName: "img_rawang_hero_1785383680261", releaseYear: 2023, description: "Dummy album", trackCount: 1),
    AlbumEntity(id: "alb_dummy_6", title: "Traditional Arts Compilation", ownerType: OwnerType.organization.name, ownerName: "Traditional Arts Org", coverResName: "img_rawang_hero_1785383680261", releaseYear: 2020, description: "Dummy album", trackCount: 1),
  ];

  static final List<TrackEntity> initialTracks = [
    // Album 1 (Singer: Ah Dang Rawang)
    TrackEntity(
      id: "trk_101",
      albumId: "alb_1",
      title: "Pungye Harvest Song",
      rawangTitle: "Pungye Lagung Rung",
      artistName: "Ah Dang Rawang",
      albumName: "Rawang Echoes of the Mountains",
      ownerType: OwnerType.singer.name,
      durationSeconds: 215,
      audioUrl: "synth:440:600",
      lyrics: """
[Rawang]
Pungye lagung, pangsi zong,
Kadu mu mado, goli so.
Rawang ka ring, zi mu ma,
Aba amya, nung kamo.

[English Translation]
When the golden harvest ripens in the valley,
We gather under the eternal snow peaks.
Preserve our heritage with pride,
For future generations to hear our song.""",
      genre: "Traditional Folk Ballad",
      isDownloaded: true,
      isFavorite: true,
      hasKaraoke: true,
      karaokeAudioUrl: "synth:karaoke:440:600",
    ),
    TrackEntity(
      id: "trk_102",
      albumId: "alb_1",
      title: "Mali River Sunset",
      rawangTitle: "Mali Hka Wang",
      artistName: "Ah Dang Rawang",
      albumName: "Rawang Echoes of the Mountains",
      ownerType: OwnerType.singer.name,
      durationSeconds: 198,
      audioUrl: "synth:380:520",
      lyrics: """
[Rawang]
Mali hka ring, so zong pe,
Goli so chyu, Rawang ka.

[English Translation]
Beside the clear Mali Hka river streams,
We sing of peace and homeland.""",
      genre: "Acoustic Ballad",
      hasKaraoke: true,
      karaokeAudioUrl: "synth:karaoke:380:520",
    ),
    TrackEntity(
      id: "trk_103",
      albumId: "alb_1",
      title: "Snow Peak Longing",
      rawangTitle: "Hkakabo Razi So",
      artistName: "Ah Dang Rawang",
      albumName: "Rawang Echoes of the Mountains",
      ownerType: OwnerType.singer.name,
      durationSeconds: 240,
      audioUrl: "synth:320:440",
      lyrics: """
[Rawang]
Hkakabo razi, zi goli,
Rawang pong ka, mu so.

[English Translation]
Looking towards Hkakabo Razi mountain,
Our heart remains steadfast in tradition.""",
      genre: "Acoustic Folk",
    ),
    TrackEntity(
      id: "trk_104",
      albumId: "alb_1",
      title: "Mother's Lullaby",
      rawangTitle: "Anu So Lagung",
      artistName: "Ah Dang Rawang",
      albumName: "Rawang Echoes of the Mountains",
      ownerType: OwnerType.singer.name,
      durationSeconds: 185,
      audioUrl: "synth:260:350",
      lyrics: """
[Rawang]
Yupa yupa, zi nung ka,
Anu ka ring, zong so.

[English Translation]
Sleep peacefully little child,
Protected by mother's ancient love.""",
      genre: "Traditional Lullaby",
      isFavorite: true,
    ),
    // Album 2 (Singer: Seng Rawang)
    TrackEntity(
      id: "trk_201",
      albumId: "alb_2",
      title: "Highland Spring Festival",
      rawangTitle: "Manau Poi Lagung",
      artistName: "Seng Rawang",
      albumName: "Golden Highland Melodies",
      ownerType: OwnerType.singer.name,
      durationSeconds: 210,
      audioUrl: "synth:520:680",
      lyrics: """
[Rawang]
Manau poi rung, zi mu ma,
Goli so ring, Rawang ka.

[English Translation]
Dance together at the Highland festival,
Joy fills our ancestral hills.""",
      genre: "Festive Folk",
      isDownloaded: true,
      hasKaraoke: true,
      karaokeAudioUrl: "synth:karaoke:520:680",
    ),
    TrackEntity(
      id: "trk_202",
      albumId: "alb_2",
      title: "Voice of Putao",
      rawangTitle: "Putao Hka So",
      artistName: "Seng Rawang",
      albumName: "Golden Highland Melodies",
      ownerType: OwnerType.singer.name,
      durationSeconds: 225,
      audioUrl: "synth:480:600",
      lyrics: """
[Rawang]
Putao ma, zi mu ma,
Rawang ka, ring zong so.""",
      genre: "Modern Folk",
    ),
    TrackEntity(
      id: "trk_203",
      albumId: "alb_2",
      title: "Dawn Chorus in N'Mai Hka",
      rawangTitle: "N'Mai Hka So Lagung",
      artistName: "Seng Rawang",
      albumName: "Golden Highland Melodies",
      ownerType: OwnerType.singer.name,
      durationSeconds: 190,
      audioUrl: "synth:350:500",
      lyrics: "[Rawang Traditional Dawn Song]",
      genre: "Acoustic",
    ),
    // Album 3 (Organization: RLCA)
    TrackEntity(
      id: "trk_301",
      albumId: "alb_3",
      title: "Traditional Courtship Chant",
      rawangTitle: "Shingla Kadu So",
      artistName: "RLCA Elders",
      albumName: "Rawang Heritage Archive Vol. 1",
      ownerType: OwnerType.organization.name,
      durationSeconds: 310,
      audioUrl: "synth:300:420",
      lyrics: """
[Rawang]
Shingla kadu, zong zi ma,
Rawang ka ring, ka ma.

[English Translation]
Recorded by the Cultural Association for heritage preservation.""",
      genre: "Heritage Archive",
      isDownloaded: true,
    ),
    TrackEntity(
      id: "trk_302",
      albumId: "alb_3",
      title: "Elders' Wisdom Chant",
      rawangTitle: "Dawa So Lagung",
      artistName: "RLCA Elders",
      albumName: "Rawang Heritage Archive Vol. 1",
      ownerType: OwnerType.organization.name,
      durationSeconds: 280,
      audioUrl: "synth:280:390",
      lyrics: "[Heritage Field Recording]",
      genre: "Cultural Lore",
    ),
    TrackEntity(
      id: "trk_303",
      albumId: "alb_3",
      title: "New Year Unity Anthem",
      rawangTitle: "Rawang Num Poi",
      artistName: "Rawang Cultural Ensemble",
      albumName: "Rawang Heritage Archive Vol. 1",
      ownerType: OwnerType.organization.name,
      durationSeconds: 250,
      audioUrl: "synth:440:580",
      lyrics: "[Unity Cultural Choir]",
      genre: "Anthem",
    ),
    TrackEntity(
      id: "trk_304",
      albumId: "alb_3",
      title: "Plow & Soil Blessing",
      rawangTitle: "Pung Lagung Blessing",
      artistName: "RLCA Heritage Group",
      albumName: "Rawang Heritage Archive Vol. 1",
      ownerType: OwnerType.organization.name,
      durationSeconds: 230,
      audioUrl: "synth:310:430",
      lyrics: "[Agricultural Blessing Chant]",
      genre: "Ritual Chant",
    ),
    // Album 4 (Organization: Rawang Youth Heritage Choir)
    TrackEntity(
      id: "trk_401",
      albumId: "alb_4",
      title: "Mountains Rejoice Choir",
      rawangTitle: "Razi Lagung Choir",
      artistName: "Rawang Youth Choir",
      albumName: "Northern Valley Choral Hymns",
      ownerType: OwnerType.organization.name,
      durationSeconds: 245,
      audioUrl: "synth:400:550",
      lyrics: "[Four-Part Rawang Polyphonic Harmony]",
      genre: "Choral Hymn",
      isFavorite: true,
    ),
    TrackEntity(
      id: "trk_402",
      albumId: "alb_4",
      title: "Grace Over Valley",
      rawangTitle: "Hka Wang Grace",
      artistName: "Rawang Youth Choir",
      albumName: "Northern Valley Choral Hymns",
      ownerType: OwnerType.organization.name,
      durationSeconds: 210,
      audioUrl: "synth:360:480",
      lyrics: "[Sacred Gospel Harmony]",
      genre: "Choral Hymn",
    ),
    // Album 5 (Anonymous)
    TrackEntity(
      id: "trk_501",
      albumId: "alb_5",
      title: "Ancient Pine Ridge Ritual",
      rawangTitle: "Pungye Ritual Chant",
      artistName: "Traditional Ancestors",
      albumName: "Ancient River Chants & Rituals",
      ownerType: OwnerType.anonymous.name,
      durationSeconds: 295,
      audioUrl: "synth:220:330",
      lyrics: "[Ancient Oral Tradition Passed Through Generations]",
      genre: "Ritual Chant",
      isDownloaded: true,
    ),
    TrackEntity(
      id: "trk_502",
      albumId: "alb_5",
      title: "Solitary Hunter's Echo",
      rawangTitle: "Hkamti Echo",
      artistName: "Highland Nomads",
      albumName: "Ancient River Chants & Rituals",
      ownerType: OwnerType.anonymous.name,
      durationSeconds: 205,
      audioUrl: "synth:250:370",
      lyrics: "[Highland Echo Call]",
      genre: "Traditional Call",
    ),
    // Album 6 (Anonymous)
    TrackEntity(
      id: "trk_601",
      albumId: "alb_6",
      title: "Pung-Lu Bamboo Flute Melody",
      rawangTitle: "Pung-Lu Solos",
      artistName: "Anonymous Bamboo Master",
      albumName: "Bamboo Harp & Flute Solos",
      ownerType: OwnerType.anonymous.name,
      durationSeconds: 260,
      audioUrl: "synth:520:700",
      lyrics: "[Instrumental Bamboo Flute Performance]",
      genre: "Instrumental Solo",
      isDownloaded: true,
      isFavorite: true,
    ),
    TrackEntity(
      id: "trk_602",
      albumId: "alb_6",
      title: "Rawang Mouth Harp Echoes",
      rawangTitle: "Goli Mouth Harp",
      artistName: "Anonymous Highland Musician",
      albumName: "Bamboo Harp & Flute Solos",
      ownerType: OwnerType.anonymous.name,
      durationSeconds: 175,
      audioUrl: "synth:600:800",
      lyrics: "[Instrumental Mouth Harp]",
      genre: "Instrumental Solo",
    ),

    // Album: John's Acoustic Hits (John Singer)
    TrackEntity(id: "trk_d101", albumId: "alb_dummy_1", title: "Highland Morning", rawangTitle: "Dingsa Wang Rung", artistName: "John Singer", albumName: "John's Acoustic Hits", ownerType: OwnerType.singer.name, durationSeconds: 203, audioUrl: "synth:320:480", lyrics: "[Rawang]\nDingsa wang rung, ma rung so,\nPungye rung nung, ladu so.\n\n[English]\nThe morning mist rolls over highland peaks,\nAs birds of the valley begin to sing.", genre: "Folk Ballad", isFavorite: true),
    TrackEntity(id: "trk_d102", albumId: "alb_dummy_1", title: "Forest Path", rawangTitle: "Shingla Lan Rung", artistName: "John Singer", albumName: "John's Acoustic Hits", ownerType: OwnerType.singer.name, durationSeconds: 187, audioUrl: "synth:350:500", lyrics: "[Rawang]\nShingla lan rung, za mu so,\nZi mu ma, goli so.\n\n[English]\nThrough the ancient forest paths I walk,\nFollowing the river to my home.", genre: "Acoustic Folk"),
    TrackEntity(id: "trk_d103", albumId: "alb_dummy_1", title: "River Stone Song", rawangTitle: "Hka Nong Rung", artistName: "John Singer", albumName: "John's Acoustic Hits", ownerType: OwnerType.singer.name, durationSeconds: 221, audioUrl: "synth:380:540", lyrics: "[Rawang]\nHka nong rung, mali so,\nRawang ka ring, nung kamo.\n\n[English]\nSmooth river stones beneath cold water,\nRemind me of ancestors who passed before.", genre: "Traditional Folk"),

    // Album: Maria's Folk Songs (Maria Artist)
    TrackEntity(id: "trk_d201", albumId: "alb_dummy_2", title: "Bamboo Wind Song", rawangTitle: "Pung Lung Rung", artistName: "Maria Artist", albumName: "Maria's Folk Songs", ownerType: OwnerType.singer.name, durationSeconds: 195, audioUrl: "synth:440:620", lyrics: "[Rawang]\nPung lung rung, so mu ma,\nDingsa wang, kadu so.\n\n[English]\nThe bamboo sways in gentle highland breeze,\nSinging songs my grandmother once knew.", genre: "Folk Ballad", isFavorite: true, hasKaraoke: true, karaokeAudioUrl: "synth:karaoke:440:620"),
    TrackEntity(id: "trk_d202", albumId: "alb_dummy_2", title: "Mountain Harvest Hymn", rawangTitle: "Lagung Rung Zong", artistName: "Maria Artist", albumName: "Maria's Folk Songs", ownerType: OwnerType.singer.name, durationSeconds: 212, audioUrl: "synth:400:580", lyrics: "[Rawang]\nLagung rung zong, pungye so,\nAba amya, nung kamo.\n\n[English]\nAt harvest time the villagers gather,\nThankful for the land that feeds our people.", genre: "Traditional Hymn"),
    TrackEntity(id: "trk_d203", albumId: "alb_dummy_2", title: "Moonlit Valley Lullaby", rawangTitle: "Larwi Rung Nu", artistName: "Maria Artist", albumName: "Maria's Folk Songs", ownerType: OwnerType.singer.name, durationSeconds: 178, audioUrl: "synth:360:510", lyrics: "[Rawang]\nLarwi rung nu, zi mu ma,\nGoli so chyu, la du so.\n\n[English]\nUnder moonlight the valley lies quiet,\nSleep, little one, our ancestors watch over you.", genre: "Lullaby"),

    // Album: David Unplugged (David Vocals)
    TrackEntity(id: "trk_d301", albumId: "alb_dummy_3", title: "Echo of the Peaks", rawangTitle: "Hkakabo Larwi So", artistName: "David Vocals", albumName: "David Unplugged", ownerType: OwnerType.singer.name, durationSeconds: 230, audioUrl: "synth:460:640", lyrics: "[Rawang]\nHkakabo larwi so, ring mu ma,\nPungye rung, kadu mu so.\n\n[English]\nThe echo of Hkakabo drifts down the valley,\nCarrying ancient melodies on cold winds.", genre: "Acoustic Ballad", isFavorite: true),
    TrackEntity(id: "trk_d302", albumId: "alb_dummy_3", title: "Sunset Over Putao", rawangTitle: "Putao Wang Rung", artistName: "David Vocals", albumName: "David Unplugged", ownerType: OwnerType.singer.name, durationSeconds: 198, audioUrl: "synth:420:600", lyrics: "[Rawang]\nPutao wang rung, so zong pe,\nMali hka ring, nung kamo.\n\n[English]\nThe sun sets golden over Putao town,\nI think of home and those I left behind.", genre: "Folk Ballad"),
    TrackEntity(id: "trk_d303", albumId: "alb_dummy_3", title: "Ancestral Chant", rawangTitle: "Amya Rung Nu", artistName: "David Vocals", albumName: "David Unplugged", ownerType: OwnerType.singer.name, durationSeconds: 245, audioUrl: "synth:390:560", lyrics: "[Rawang]\nAmya rung nu, goli so,\nZi mu ma, Rawang ka.\n\n[English]\nI chant the words my ancestors taught,\nSo our language will never fade away.", genre: "Traditional Chant"),

    // Album: Sarah's Classic Melodies (Sarah Melody)
    TrackEntity(id: "trk_d401", albumId: "alb_dummy_4", title: "Singing By the Stream", rawangTitle: "Hka Rung Zong", artistName: "Sarah Melody", albumName: "Sarah's Classic Melodies", ownerType: OwnerType.singer.name, durationSeconds: 210, audioUrl: "synth:480:660", lyrics: "[Rawang]\nHka rung zong, mali so,\nPung lung rung, dingsa wang.\n\n[English]\nSitting by the stream I sing softly,\nWatching silver fish dart between stones.", genre: "Folk Ballad", isFavorite: true, hasKaraoke: true, karaokeAudioUrl: "synth:karaoke:480:660"),
    TrackEntity(id: "trk_d402", albumId: "alb_dummy_4", title: "Dance of the Festival", rawangTitle: "Dawt Rung Pungye", artistName: "Sarah Melody", albumName: "Sarah's Classic Melodies", ownerType: OwnerType.singer.name, durationSeconds: 185, audioUrl: "synth:500:700", lyrics: "[Rawang]\nDawt rung pungye, kadu so,\nAba amya, nung kamo.\n\n[English]\nThe festival drums beat as we dance together,\nCelebrating harvest with joy and song.", genre: "Festival Folk"),
    TrackEntity(id: "trk_d403", albumId: "alb_dummy_4", title: "Highland Farewell", rawangTitle: "Dingsa Wang Nu", artistName: "Sarah Melody", albumName: "Sarah's Classic Melodies", ownerType: OwnerType.singer.name, durationSeconds: 222, audioUrl: "synth:410:590", lyrics: "[Rawang]\nDingsa wang nu, so mu ma,\nRawang ka ring, zi mu ma.\n\n[English]\nFarewell dear highland, I must leave now,\nBut my heart stays rooted in your mountains.", genre: "Farewell Ballad"),

    // Album: Peter's Evening Tunes (Peter Tune)
    TrackEntity(id: "trk_d501", albumId: "alb_dummy_5", title: "Campfire Stories", rawangTitle: "Me Rung Lagung", artistName: "Peter Tune", albumName: "Peter's Evening Tunes", ownerType: OwnerType.singer.name, durationSeconds: 200, audioUrl: "synth:340:490", lyrics: "[Rawang]\nMe rung lagung, goli so,\nZi mu ma, shingla lan.\n\n[English]\nAround the campfire elders tell old stories,\nFlames crackle as night falls on the village.", genre: "Folk Storytelling"),
    TrackEntity(id: "trk_d502", albumId: "alb_dummy_5", title: "Starlight Over Nmai", rawangTitle: "Larwi Nmai So", artistName: "Peter Tune", albumName: "Peter's Evening Tunes", ownerType: OwnerType.singer.name, durationSeconds: 218, audioUrl: "synth:370:530", lyrics: "[Rawang]\nLarwi nmai so, ring mu ma,\nPutao wang rung, nung kamo.\n\n[English]\nA million stars shine over the Nmai Hka valley,\nReflecting silver in its ancient waters.", genre: "Acoustic Ballad", isFavorite: true),
    TrackEntity(id: "trk_d503", albumId: "alb_dummy_5", title: "Hunter's Return", rawangTitle: "Dawt Rung Hkra", artistName: "Peter Tune", albumName: "Peter's Evening Tunes", ownerType: OwnerType.singer.name, durationSeconds: 196, audioUrl: "synth:430:610", lyrics: "[Rawang]\nDawt rung hkra, pungye so,\nAba amya, lagung rung.\n\n[English]\nThe hunter returns before the mountain shadows fall,\nCarrying meat and song for the village feast.", genre: "Traditional Folk"),

    // Album: Traditional Arts Compilation (Traditional Arts Org)
    TrackEntity(id: "trk_d601", albumId: "alb_dummy_6", title: "Collective Harvest Hymn", rawangTitle: "Rung Lagung Zong", artistName: "Traditional Arts Ensemble", albumName: "Traditional Arts Compilation", ownerType: OwnerType.organization.name, durationSeconds: 238, audioUrl: "synth:450:630", lyrics: "[Rawang]\nRung lagung zong, kadu so,\nGoli so chyu, Rawang ka.\n\n[English]\nWe sing together in the season of harvest,\nOur voices unite like rivers to the sea.", genre: "Choral Traditional"),
    TrackEntity(id: "trk_d602", albumId: "alb_dummy_6", title: "Cultural Heritage March", rawangTitle: "Ka Ring Rung So", artistName: "Traditional Arts Ensemble", albumName: "Traditional Arts Compilation", ownerType: OwnerType.organization.name, durationSeconds: 195, audioUrl: "synth:510:710", lyrics: "[Rawang]\nKa ring rung so, zi mu ma,\nPungye rung nung, ladu so.\n\n[English]\nWe march proudly carrying our cultural torch,\nPassing it forward to our children's children.", genre: "Cultural March"),
    TrackEntity(id: "trk_d603", albumId: "alb_dummy_6", title: "Night of the Full Moon Feast", rawangTitle: "Larwi Pungye Nu", artistName: "Traditional Arts Ensemble", albumName: "Traditional Arts Compilation", ownerType: OwnerType.organization.name, durationSeconds: 262, audioUrl: "synth:390:555", lyrics: "[Rawang]\nLarwi pungye nu, dawt rung so,\nAba amya, nung kamo.\n\n[English]\nOn the night of the full moon we feast and dance,\nGiving thanks for the blessings of the year.", genre: "Festival Choral", isFavorite: true),
  ];

  static final List<PlaylistEntity> initialPlaylists = [
    PlaylistEntity(
      id: "pl_1",
      name: "Cultural Favorites",
      description: "My saved Rawang songs for daily listening",
      iconName: "favorite",
    ),
    PlaylistEntity(
      id: "pl_2",
      name: "Offline Mountain Journey",
      description: "Tracks downloaded for listening without cellular connection",
      iconName: "download",
    ),
  ];

  static final List<ChatMessageEntity> initialChatMessages = [
    ChatMessageEntity(
      id: "msg_1",
      senderName: "Ah Dang (Putao)",
      message: "Shingla kadoo! Welcome to the Rawang Music preservation platform!",
      timestamp: DateTime.now().millisecondsSinceEpoch - 86400000 * 2,
      isUser: false,
    ),
    ChatMessageEntity(
      id: "msg_2",
      senderName: "Seng Hkawn (Myitkyina)",
      message: "I am so happy to see old traditional bamboo flute songs preserved here! Check out 'Pungye Harvest Song'!",
      timestamp: DateTime.now().millisecondsSinceEpoch - 86400000,
      attachedTrackId: "trk_101",
      attachedTrackTitle: "Pungye Harvest Song",
      isUser: false,
    ),
    ChatMessageEntity(
      id: "msg_3",
      senderName: "Mung Rawang",
      message: "Downloading songs for offline listening is so helpful when travelling to northern mountain villages without internet.",
      timestamp: DateTime.now().millisecondsSinceEpoch - 3600000 * 4,
      isUser: false,
    ),
  ];
}
