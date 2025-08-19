class Emprestimo {
  int? id;
  String nomePessoa;
  DateTime? dataEmprestimo;
  DateTime? dataDevolucao;

  Emprestimo({
    this.id,
    required this.nomePessoa,
    this.dataEmprestimo,
    this.dataDevolucao,
  });

  factory Emprestimo.fromJson(Map<String, dynamic> json) => Emprestimo(
    id: json['id'],
    nomePessoa: json['nomePessoa'],
    dataEmprestimo: json['dataEmprestimo'] != null
        ? DateTime.parse(json['dataEmprestimo'])
        : null,
    dataDevolucao: json['dataDevolucao'] != null
        ? DateTime.parse(json['dataDevolucao'])
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nomePessoa': nomePessoa,
    'dataEmprestimo': dataEmprestimo?.toIso8601String(),
    'dataDevolucao': dataDevolucao?.toIso8601String(),
  };
}
