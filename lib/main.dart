import 'dart:io';
import 'dart:convert';

import 'models/livro.dart';
import 'models/emprestimo.dart';
import 'services/livro_service.dart';
import 'services/emprestimo_service.dart';
import 'models/status_leitura.dart';

void main() async {
  final livroService = LivroService();
  final emprestimoService = EmprestimoService();

  while (true) {
    print('\n=== Biblioteca Pessoal ===');
    print('1. Listar todos os livros');
    print('2. Adicionar livro');
    print('3. Emprestar livro');
    print('4. Listar todos os empréstimos');
    print('5. Buscar livro por ID'); // NOVA OPÇÃO
    print('0. Sair');
    stdout.write('Escolha uma opção: ');
    final input = stdin.readLineSync();

    switch (input) {
      case '1':
        final livros = await livroService.listarTodos();
        print('\n=== Livros ===');
        for (var livro in livros) {
          final emprestado = livro.emprestimo != null ? ' - Emprestado para ${livro.emprestimo!.nomePessoa}' : '';
          print(
              '${livro.id}. ${livro.titulo} - ${livro.autor} - Status: ${livro.status.label}$emprestado');
        }
        break;

      case '2':
        stdout.write('Título: ');
        final titulo = stdin.readLineSync() ?? '';
        stdout.write('Autor: ');
        final autor = stdin.readLineSync() ?? '';
        stdout.write('Categoria: ');
        final categoria = stdin.readLineSync() ?? '';
        stdout.write('URL da capa: ');
        final capaUrl = stdin.readLineSync() ?? '';
        stdout.write('Avaliação (0-5): ');
        final avaliacaoInput = stdin.readLineSync();
        final avaliacao = double.tryParse(avaliacaoInput ?? '0') ?? 0;

        final livro = Livro(
          titulo: titulo,
          autor: autor,
          categoria: categoria,
          capaUrl: capaUrl,
          status: StatusLeitura.naoLido,
          avaliacao: avaliacao,
        );

        await livroService.adicionar(livro);
        print('Livro adicionado com sucesso!');
        break;

      case '3':
        stdout.write('ID do livro a emprestar: ');
        final livroIdInput = stdin.readLineSync();
        final livroId = int.tryParse(livroIdInput ?? '');
        if (livroId == null) {
          print('ID inválido!');
          break;
        }

        stdout.write('Nome da pessoa: ');
        final nomePessoa = stdin.readLineSync() ?? '';

        final emprestimo = Emprestimo(
          nomePessoa: nomePessoa,
          dataEmprestimo: DateTime.now(),
          dataDevolucao: null,
        );

        await emprestimoService.adicionar(emprestimo);

        final livro = await livroService.buscarPorId(livroId);
        if (livro != null) {
          livro.emprestimo = emprestimo;
          livro.status = StatusLeitura.lendo;
          await livroService.atualizar(livroId, livro);
          print('Livro emprestado com sucesso para $nomePessoa!');
        } else {
          print('Livro não encontrado!');
        }
        break;

      case '4':
        final emprestimos = await emprestimoService.listarTodos();
        print('\n=== Empréstimos ===');
        for (var e in emprestimos) {
          final devolucao = e.dataDevolucao != null
              ? e.dataDevolucao.toString()
              : 'Não devolvido';
          print('${e.nomePessoa} - ${e.dataEmprestimo} - $devolucao');
        }
        break;

      case '5': // BUSCAR POR ID
        stdout.write('Digite o ID do livro: ');
        final idInput = stdin.readLineSync();
        final id = int.tryParse(idInput ?? '');
        if (id == null) {
          print('ID inválido!');
          break;
        }

        final livro = await livroService.buscarPorId(id);
        if (livro != null) {
          print('\n=== Detalhes do Livro ===');
          print('ID: ${livro.id}');
          print('Título: ${livro.titulo}');
          print('Autor: ${livro.autor}');
          print('Categoria: ${livro.categoria}');
          print('Capa: ${livro.capaUrl}');
          print('Status: ${livro.status.label}');
          print('Avaliação: ${livro.avaliacao}');
          if (livro.emprestimo != null) {
            print('Emprestado para: ${livro.emprestimo!.nomePessoa}');
            print('Data do empréstimo: ${livro.emprestimo!.dataEmprestimo}');
            print('Data de devolução: ${livro.emprestimo!.dataDevolucao ?? 'Não devolvido'}');
          }
        } else {
          print('Livro não encontrado!');
        }
        break;

      case '0':
        print('Saindo...');
        return;

      default:
        print('Opção inválida!');
    }
  }
}
