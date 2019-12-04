import 'album.dart';
import 'artist.dart';
import 'image_uri.dart';

class Track {
  final Album album;
  final Artist artist;
  final List<Artist> artists;
  final int duration;
  final ImageUri imageUri;
  final bool isEpisode;
  final bool isPodcast;
  final String name;
  final String uri;

  Track(this.album, this.artist, this.artists, this.duration, this.imageUri,
      this.isEpisode, this.isPodcast, this.name, this.uri);

  Track.fromJson(Map<String, dynamic> json)
      : album = Album.fromJson(json["album"]),
        artist = Artist.fromJson(json["artist"]),
        artists = getArtists(json),
        duration = json["duration"],
        imageUri = ImageUri.fromJson(json["imageUri"]),
        isEpisode = json["isEpisode"],
        isPodcast = json["isPodcast"],
        name = json["name"],
        uri = json["uri"];

  Map<String, dynamic> toJson() => {
        'album': album,
        'artist': artist,
        'artists': artists,
        'duration': duration,
        'imageUri': imageUri,
        'isEpisode': isEpisode,
        'isPodcast': isPodcast,
        'name': name,
        'uri': uri,
      };

  static List<Artist> getArtists(Map<String, dynamic> json) {
    if (json['artists'] == null) {
      return null;
    } else {
      var artists = new List<Artist>();
      json['artists'].forEach((v) {
        artists.add(Artist.fromJson(v));
      });
      return artists;
    }
  }
}
