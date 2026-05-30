class Usuario {
  final int id;
  final String uuid;
  final String nome;
  final String sobrenome;
  final String email;
  final int? cidadeId;
  final String roleUser;
  final String status;
  final String? fotoPerfil;
  final bool emailVerificado;
  final double? porcentagemVisitada;
  final DateTime? ultimoLogin;
  final DateTime? dataCadastro;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const Usuario({
    required this.id,
    required this.uuid,
    required this.nome,
    required this.sobrenome,
    required this.email,
    this.cidadeId,
    required this.roleUser,
    required this.status,
    this.fotoPerfil,
    required this.emailVerificado,
    this.porcentagemVisitada,
    this.ultimoLogin,
    this.dataCadastro,
    this.updatedAt,
    this.deletedAt,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id:                  json['id'] as int? ?? 0,
      uuid:                json['uuid'] as String? ?? '',
      nome:                json['nome'] as String? ?? '',
      sobrenome:           json['sobrenome'] as String? ?? '',
      email:               json['email'] as String? ?? '',
      cidadeId:            json['cidade_id'] as int?,
      roleUser:            (json['roleUser'] ?? json['role_user']) as String? ?? 'USER',
      status:              json['status'] as String? ?? 'ATIVO',
      fotoPerfil:          json['fotoPerfil'] as String? ?? json['foto_perfil'] as String?,
      emailVerificado:     json['emailVerificado'] as bool? ?? json['email_verificado'] as bool? ?? false,
      porcentagemVisitada: (json['porcentagemVisitada'] ?? json['porcentagem_visitada'] as num?)?.toDouble(),
      ultimoLogin:         _parseDate(json['ultimoLogin'] ?? json['ultimo_login']),
      dataCadastro:        _parseDate(json['dataCadastro'] ?? json['data_cadastro']),
      updatedAt:           _parseDate(json['updatedAt'] ?? json['updated_at']),
      deletedAt:           _parseDate(json['deletedAt'] ?? json['deleted_at']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() => {
    'uuid':                 uuid,
    'nome':                 nome,
    'sobrenome':            sobrenome,
    'email':                email,
    'cidade_id':            cidadeId,
    'role_user':            roleUser,
    'status':               status,
    'foto_perfil':          fotoPerfil,
    'email_verificado':     emailVerificado,
    'porcentagem_visitada': porcentagemVisitada,
  };

  String get nomeCompleto => '$nome $sobrenome';
}