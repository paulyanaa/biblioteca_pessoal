import '../models/livro.dart';
import '../models/emprestimo.dart';

class LivroRepository {
  final List<Livro> _livros = [];

  // CREATE
  void adicionar(Livro livro) {
    _livros.add(livro);
  }

  // READ
  List<Livro> listarTodos() => List.unmodifiable(_livros);

  Livro? buscarPorId(int id) =>
      _livros.firstWhere((l) => l.id == id, orElse: () => null);

  // UPDATE
  bool atualizar(int id, Livro novoLivro) {
    final index = _livros.indexWhere((l) => l.id == id);
    if (index != -1) {
      _livros[index] = novoLivro;
      return true;
    }
    return false;
  }

  // DELETE
  void remover(int id) => _livros.removeWhere((l) => l.id == id);

  // EMPRESTAR
  bool emprestar(int livroId, Emprestimo emprestimo) {
    final livro = buscarPorId(livroId);
    if (livro != null && livro.emprestimo == null) {
      livro.emprestimo = emprestimo;
      return true;
    }
    return false;
  }

  // DEVOLVER
  bool devolver(int livroId) {
    final livro = buscarPorId(livroId);
    if (livro != null && livro.emprestimo != null) {
      livro.emprestimo = null;
      return true;
    }
    return false;
  }
}
