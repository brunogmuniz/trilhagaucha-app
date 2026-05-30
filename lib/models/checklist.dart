class Checklist {
  final int id;
  final int usuarioId;
  final int cidadeId;
  final bool visitado;
  final DateTime? dataVisita;

  const Checklist({
    required this.id,
    required this.usuarioId,
    required this.cidadeId,
    required this.visitado,
    this.dataVisita,
  });

  factory Checklist.fromJson(Map<String, dynamic> json) {
    // usuario pode vir como objeto ou como id
    final usuarioRaw = json['usuario'];
    final int usuarioId = usuarioRaw is Map
        ? (usuarioRaw['id'] as int? ?? 0)
        : (json['usuario_id'] as int? ?? 0);

    // cidade pode vir como objeto ou como id
    final cidadeRaw = json['cidade'];
    final int cidadeId = cidadeRaw is Map
        ? (cidadeRaw['id'] as int? ?? 0)
        : (json['cidade_id'] as int? ?? 0);

    return Checklist(
      id:         json['id'] as int? ?? 0,
      usuarioId:  usuarioId,
      cidadeId:   cidadeId,
      visitado:   json['visitado'] as bool? ?? false,
      dataVisita: json['dataVisita'] != null
          ? DateTime.tryParse(json['dataVisita'] as String)
          : json['data_visita'] != null
          ? DateTime.tryParse(json['data_visita'] as String)
          : null,
    );
  }
}