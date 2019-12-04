class Album {
  final String name;
  final String uri;

  Album(this.name, this.uri);

  Album.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        uri = json["uri"];

  Map<String, dynamic> toJson() => {
        'name': name,
        'uri': uri,
      };
}
