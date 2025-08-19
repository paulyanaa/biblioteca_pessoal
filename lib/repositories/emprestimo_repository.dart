import '../models/emprestimo.dart';

class EmprestimoRepository {
  final List<Emprestimo> _emprestimos = [];

  // CREATE
  void adicionar(Emprestimo emprestimo) {
    _emprestimos.add(emprestimo);
  }

  // READ
  List<Emprestimo> listarTodos() => List.unmodifiable(_emprestimos);

  Emprestimo? buscarPorId(int id) =>
      _emprestimos.firstWhere((e) => e.id == id, orElse: () => null);

  // UPDATE
  bool atualizar(int id, Emprestimo novoEmprestimo) {
    final index = _emprestimos.indexWhere((e) => e.id == id);
    if (index != -1) {
      _emprestimos[index] = novoEmprestimo;
      return true;
    }
    return false;
  }

  // DELETE
  void remover(int id) => _emprestimos.removeWhere((e) => e.id == id);

  // BUSCAR POR NOME
  Emprestimo? buscarPorNome(String nomePessoa) {
    return _emprestimos.firstWhere(
      (e) => e.nomePessoa == nomePessoa,
      orElse: () => null,
    );
  }
}
