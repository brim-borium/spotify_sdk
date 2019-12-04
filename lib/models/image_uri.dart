class ImageUri {
  final String raw;

  ImageUri(this.raw);

  ImageUri.fromJson(Map<String, dynamic> json) : raw = json["raw"];

  Map<String, dynamic> toJson() => {
        'raw': raw,
      };
}
