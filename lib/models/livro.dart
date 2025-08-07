import 'emprestimo.dart';
import 'status_leitura.dart';

class Livro {
  final int id;
  String titulo;
  String autor;
  String? capaUrl;
  String? categoria;
  StatusLeitura status;
  String? anotacoes;
  int? avaliacao; // de 1 a 5 estrelas
  Emprestimo? emprestimo;

  Livro({
    required this.id,
    required this.titulo,
    required this.autor,
    this.capaUrl,
    this.categoria,
    this.status = StatusLeitura.naoLido,
    this.anotacoes,
    this.avaliacao,
    this.emprestimo,
  });
}


