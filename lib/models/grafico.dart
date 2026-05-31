class Grafico {
  final int id;
  final String uuid;
  final int usuarioId;
  final double? porcentagemTotal;
  final double? porcentagemNorte;
  final double? porcentagemSerra;
  final double? porcentagemLitoral;
  final double? porcentagemCentroOeste;
  final double? porcentagemMissoes;
  final double? porcentagemMetropolitana;

  const Grafico({
    required this.id,
    required this.uuid,
    required this.usuarioId,
    this.porcentagemTotal,
    this.porcentagemNorte,
    this.porcentagemSerra,
    this.porcentagemLitoral,
    this.porcentagemCentroOeste,
    this.porcentagemMissoes,
    this.porcentagemMetropolitana,
  });

  factory Grafico.fromJson(Map<String, dynamic> json) {
    return Grafico(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      usuarioId: json['usuario_id'] as int,
      porcentagemTotal: (json['porcentagem_total'] as num?)?.toDouble(),
      porcentagemNorte: (json['porcentagem_norte'] as num?)?.toDouble(),
      porcentagemSerra: (json['porcentagem_serra'] as num?)?.toDouble(),
      porcentagemLitoral: (json['porcentagem_litoral'] as num?)?.toDouble(),
      porcentagemCentroOeste:
          (json['porcentagem_centro_oeste'] as num?)?.toDouble(),
      porcentagemMissoes: (json['porcentagem_missoes'] as num?)?.toDouble(),
      porcentagemMetropolitana:
          (json['porcentagem_metropolitana'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'usuario_id': usuarioId,
        'porcentagem_total': porcentagemTotal,
        'porcentagem_norte': porcentagemNorte,
        'porcentagem_serra': porcentagemSerra,
        'porcentagem_litoral': porcentagemLitoral,
        'porcentagem_centro_oeste': porcentagemCentroOeste,
        'porcentagem_missoes': porcentagemMissoes,
        'porcentagem_metropolitana': porcentagemMetropolitana,
      };

  Map<String, double> get porPorRegiao => {
        'Norte': porcentagemNorte ?? 0,
        'Serra': porcentagemSerra ?? 0,
        'Litoral': porcentagemLitoral ?? 0,
        'Centro-Oeste': porcentagemCentroOeste ?? 0,
        'Missões': porcentagemMissoes ?? 0,
        'Metropolitana': porcentagemMetropolitana ?? 0,
      };
}
