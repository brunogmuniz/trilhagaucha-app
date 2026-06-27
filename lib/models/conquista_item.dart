/// Representa uma conquista/medalha do "Álbum de Troféus" do usuário.
class ConquistaItem {
  final int id;
  final String nome; // Ex: "Pé na Estrada", "Alma Serrana"
  final String descricao; // Ex: "Visite suas primeiras 10 cidades no estado."
  final String iconeNome; // Ex: "trofeu", "mapa", "cuia"
  final String corHex; // Ex: "#1F918B" ou "#EF4B4F"
  final bool desbloqueada; // true = o usuário já tem | false = bloqueada
  final String? dataConquista; // ISO-8601, null se desbloqueada == false

  const ConquistaItem({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.iconeNome,
    required this.corHex,
    required this.desbloqueada,
    this.dataConquista,
  });

  factory ConquistaItem.fromJson(Map<String, dynamic> json) {
    return ConquistaItem(
      id: json['id'] as int,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String,
      iconeNome: json['iconeNome'] as String,
      corHex: json['corHex'] as String,
      desbloqueada: json['desbloqueada'] as bool? ?? false,
      dataConquista: _parseDataConquista(json['dataConquista']),
    );
  }

  /// O Jackson, por padrão, serializa LocalDateTime como array
  /// `[ano, mes, dia, hora, minuto, segundo]` em vez de string ISO,
  /// a menos que `write-dates-as-timestamps: false` esteja configurado
  /// no backend. Aceita os dois formatos para não depender dessa config.
  static String? _parseDataConquista(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) return raw;
    if (raw is List && raw.length >= 6) {
      final ano = raw[0] as int;
      final mes = raw[1] as int;
      final dia = raw[2] as int;
      final hora = raw[3] as int;
      final minuto = raw[4] as int;
      final segundo = raw[5] as int;
      return DateTime(ano, mes, dia, hora, minuto, segundo).toIso8601String();
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'descricao': descricao,
    'iconeNome': iconeNome,
    'corHex': corHex,
    'desbloqueada': desbloqueada,
    'dataConquista': dataConquista,
  };
}