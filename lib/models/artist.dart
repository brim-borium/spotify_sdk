class Artist {
  final String name;
  final String uri;

  Artist(this.name, this.uri);

  Artist.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        uri = json["uri"];

  Map<String, dynamic> toJson() => {
        'name': name,
        'uri': uri,
      };
}
