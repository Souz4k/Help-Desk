class Horario {
  final String id;
  final String hora;
  bool disponivel;
  String? nome;
  String? configuracao;
  String? problema;

  Horario({
    required this.id,
    required this.hora,
    this.disponivel = true,
    this.nome,
    this.configuracao,
    this.problema,
  });
}
