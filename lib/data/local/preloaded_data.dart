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
    )
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
