import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/livro.dart';
import '../models/emprestimo.dart';

class LivroService {
  final String baseUrl = 'http://localhost:8080';

  Future<List<Livro>> listarTodos() async {
    final response = await http.get(Uri.parse('$baseUrl/livros'));
    if (response.statusCode == 200) {
      final List dados = jsonDecode(response.body);
      return dados.map((json) => Livro.fromJson(json)).toList();
    }
    throw Exception('Erro ao listar livros');
  }

  Future<Livro?> buscarPorId(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/livros/$id'));
    if (response.statusCode == 200) {
      return Livro.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<void> adicionar(Livro livro) async {
    final response = await http.post(
      Uri.parse('$baseUrl/livros'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(livro.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erro ao adicionar livro: ${response.body}');
    }
  }

  Future<void> atualizar(int id, Livro livro) async {
    final response = await http.put(
      Uri.parse('$baseUrl/livros/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(livro.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar livro: ${response.body}');
    }
  }

  Future<void> remover(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/livros/$id'));
    if (response.statusCode != 200) {
      throw Exception('Erro ao remover livro: ${response.body}');
    }
  }

  Future<void> emprestar(int livroId, Emprestimo emprestimo) async {
    final response = await http.post(
      Uri.parse('$baseUrl/livros/$livroId/emprestar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(emprestimo.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao emprestar livro: ${response.body}');
    }
  }

  Future<void> devolver(int livroId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/livros/$livroId/devolver'),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao devolver livro: ${response.body}');
    }
  }
}
