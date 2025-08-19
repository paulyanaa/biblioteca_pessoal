import 'emprestimo.dart';
import 'status_leitura.dart';

class Livro {
  int? id;
  String titulo;
  String autor;
  String? capaUrl;
  String? categoria;
  StatusLeitura status;
  String? anotacoes;
  double? avaliacao;
  Emprestimo? emprestimo;

  Livro({
    this.id,
    required this.titulo,
    required this.autor,
    this.capaUrl,
    this.categoria,
    required this.status,
    this.anotacoes,
    this.avaliacao,
    this.emprestimo,
  });

  factory Livro.fromJson(Map<String, dynamic> json) => Livro(
    id: json['id'],
    titulo: json['titulo'],
    autor: json['autor'],
    capaUrl: json['capaUrl'],
    categoria: json['categoria'],
    status:
        StatusLeituraExtension.fromString(json['status']) ??
        StatusLeitura.naoLido,
    anotacoes: json['anotacoes'],
    avaliacao: json['avaliacao'] != null
        ? (json['avaliacao'] as num).toDouble()
        : null,
    emprestimo: json['emprestimo'] != null
        ? Emprestimo.fromJson(json['emprestimo'])
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'autor': autor,
    'capaUrl': capaUrl,
    'categoria': categoria,
    'status': status.name,
    'anotacoes': anotacoes,
    'avaliacao': avaliacao,
    'emprestimo': emprestimo?.toJson(),
  };
}
