import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/emprestimo.dart';

class EmprestimoService {
  final String baseUrl = 'http://localhost:8080';

  Future<List<Emprestimo>> listarTodos() async {
    final response = await http.get(Uri.parse('$baseUrl/emprestimos'));
    if (response.statusCode == 200) {
      final List dados = jsonDecode(response.body);
      return dados.map((json) => Emprestimo.fromJson(json)).toList();
    }
    throw Exception('Erro ao listar empréstimos');
  }

  Future<Emprestimo?> buscarPorId(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/emprestimos/$id'));
    if (response.statusCode == 200) {
      return Emprestimo.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<void> adicionar(Emprestimo emprestimo) async {
    final response = await http.post(
      Uri.parse('$baseUrl/emprestimos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(emprestimo.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao adicionar empréstimo: ${response.body}');
    }
  }

  Future<void> atualizar(int id, Emprestimo emprestimo) async {
    final response = await http.put(
      Uri.parse('$baseUrl/emprestimos/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(emprestimo.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar empréstimo: ${response.body}');
    }
  }

  Future<void> remover(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/emprestimos/$id'));
    if (response.statusCode != 200) {
      throw Exception('Erro ao remover empréstimo: ${response.body}');
    }
  }
}
