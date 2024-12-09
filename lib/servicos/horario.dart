class Horario {
  final String id;
  final String hora;
  bool disponivel;
  String? nome;
  String? configuracao;
  String? problema;
  String? contato;

  Horario({
    required this.id,
    required this.hora,
    this.disponivel = true,
    this.nome,
    this.configuracao,
    this.problema,
    this.contato,
  });
}
