class Cidade {
  final int id;
  final String nome;
  final String regiao;

  const Cidade({
    required this.id,
    required this.nome,
    required this.regiao,
  });

  factory Cidade.fromJson(Map<String, dynamic> json) {
    return Cidade(
      id: json['id'] as int,
      nome: json['nome'] as String,
      regiao: json['regiao'] as String? ?? '',
    );
  }
}