import 'package:flutter/material.dart';
import '../models/livro.dart';
import '../models/status_leitura.dart';
import '../services/livro_service.dart';
import 'adicionar_livro_screen.dart';
import 'detalhes_livro_screen.dart';

class MinhaBibliotecaScreen extends StatefulWidget {
  @override
  _MinhaBibliotecaScreenState createState() => _MinhaBibliotecaScreenState();
}

class _MinhaBibliotecaScreenState extends State<MinhaBibliotecaScreen> {
  final LivroService _livroService = LivroService();
  List<Livro> _livros = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _carregarLivros();
  }

  Future<void> _carregarLivros() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final livros = await _livroService.listarTodos();
      setState(() {
        _livros = livros;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar livros: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _removerLivro(int id) async {
    try {
      await _livroService.remover(id);
      setState(() {
        _livros.removeWhere((livro) => livro.id == id);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Livro removido com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao remover livro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmarRemocao(Livro livro) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar exclusão'),
          content: Text('Tem certeza que deseja remover o livro "${livro.titulo}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _removerLivro(livro.id!);
              },
              child: Text(
                'Remover',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _adicionarLivro() {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => AdicionarLivroScreen())
    ).then((livroAdicionado) {
      if (livroAdicionado != null && livroAdicionado == true) {
        _carregarLivros();
      }
    });
  }

  void _mostrarDetalhesLivro(Livro livro) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalhes do Livro'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (livro.capaUrl != null && livro.capaUrl!.isNotEmpty)
                  Center(
                    child: Image.network(
                      livro.capaUrl!,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                SizedBox(height: 16),
                Text('Título: ${livro.titulo}', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Autor: ${livro.autor ?? "Não informado"}'),
                SizedBox(height: 8),
                Text('Categoria: ${livro.categoria ?? "Não informada"}'),
                SizedBox(height: 8),
                Text('Status: ${livro.status.label}'),
                SizedBox(height: 8),
                Text('Avaliação: ${livro.avaliacao ?? "Não avaliado"}'),
                if (livro.emprestimo != null) ...[
                  SizedBox(height: 16),
                  Text('Emprestado para: ${livro.emprestimo!.nomePessoa}', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Data do empréstimo: ${livro.emprestimo!.dataEmprestimo}'),
                  if (livro.emprestimo!.dataDevolucao != null)
                    Text('Data de devolução: ${livro.emprestimo!.dataDevolucao}'),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Minha Estante',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: _carregarLivros,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarLivro,
        backgroundColor: Colors.blue,
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
        shape: CircleBorder(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregarLivros,
              child: Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_livros.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhum livro na biblioteca',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Clique no botão + para adicionar um livro',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: RefreshIndicator(
        onRefresh: _carregarLivros,
        child: ListView.builder(
          itemCount: _livros.length,
          itemBuilder: (context, index) {
            final livro = _livros[index];
            return _buildLivroCard(livro);
          },
        ),
      ),
    );
  }

  Widget _buildLivroCard(Livro livro) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalhesLivroScreen(livro: livro),
            ),
          ).then((livroAtualizado) {
            if (livroAtualizado != null) {
              _carregarLivros();
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                  image: livro.capaUrl != null && livro.capaUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(livro.capaUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: livro.capaUrl == null || livro.capaUrl!.isEmpty
                    ? Icon(Icons.book, size: 30, color: Colors.grey)
                    : null,
              ),
              SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      livro.titulo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      livro.autor ?? 'Autor desconhecido',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      livro.categoria ?? 'Categoria não informada',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          livro.avaliacao != null ? livro.avaliacao!.toStringAsFixed(1) : 'N/A',
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(width: 16),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(livro.status),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            livro.status.label,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              IconButton(
                onPressed: () => _confirmarRemocao(livro),
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(StatusLeitura status) {
    switch (status) {
      case StatusLeitura.lido:
        return Colors.green;
      case StatusLeitura.lendo:
        return Colors.blue;
      case StatusLeitura.naoLido:
        return Colors.orange;
    }
  }
}