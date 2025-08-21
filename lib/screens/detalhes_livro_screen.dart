import 'package:flutter/material.dart';
import '../models/livro.dart';
import '../models/emprestimo.dart';
import '../models/status_leitura.dart';
import '../services/livro_service.dart';

class DetalhesLivroScreen extends StatefulWidget {
  final Livro livro;

  const DetalhesLivroScreen({Key? key, required this.livro}) : super(key: key);

  @override
  _DetalhesLivroScreenState createState() => _DetalhesLivroScreenState();
}

class _DetalhesLivroScreenState extends State<DetalhesLivroScreen> {
  final _formKey = GlobalKey<FormState>();
  final LivroService _livroService = LivroService();
  
  late TextEditingController _tituloController;
  late TextEditingController _autorController;
  late TextEditingController _categoriaController;
  late TextEditingController _anotacoesController;
  
  late StatusLeitura _statusSelecionado;
  late bool _emprestado;
  DateTime? _dataEmprestimo;
  DateTime? _dataDevolucao;
  String? _nomePessoaEmprestimo;
  double _avaliacao = 0;
  
  final Map<StatusLeitura, Color> _statusColors = {
    StatusLeitura.lido: Colors.green,
    StatusLeitura.lendo: Colors.blue,
    StatusLeitura.naoLido: Colors.grey,
  };

  bool _editando = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    _tituloController = TextEditingController(text: widget.livro.titulo);
    _autorController = TextEditingController(text: widget.livro.autor);
    _categoriaController = TextEditingController(text: widget.livro.categoria ?? '');
    _anotacoesController = TextEditingController(text: widget.livro.anotacoes ?? '');
    
    _statusSelecionado = widget.livro.status;
    _avaliacao = widget.livro.avaliacao ?? 0;
    _emprestado = widget.livro.emprestimo != null;
    
    if (_emprestado) {
      _nomePessoaEmprestimo = widget.livro.emprestimo!.nomePessoa;
      _dataEmprestimo = widget.livro.emprestimo!.dataEmprestimo;
      _dataDevolucao = widget.livro.emprestimo!.dataDevolucao;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _autorController.dispose();
    _categoriaController.dispose();
    _anotacoesController.dispose();
    super.dispose();
  }

  Future<void> _salvarAlteracoes() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        Emprestimo? emprestimo;
        if (_emprestado && _nomePessoaEmprestimo != null && _nomePessoaEmprestimo!.isNotEmpty) {
          emprestimo = Emprestimo(
            id: widget.livro.emprestimo?.id,
            nomePessoa: _nomePessoaEmprestimo!,
            dataEmprestimo: _dataEmprestimo ?? DateTime.now(),
            dataDevolucao: _dataDevolucao,
          );
        }

        final livroAtualizado = Livro(
          id: widget.livro.id,
          titulo: _tituloController.text,
          autor: _autorController.text,
          capaUrl: widget.livro.capaUrl,
          categoria: _categoriaController.text.isNotEmpty ? _categoriaController.text : null,
          status: _statusSelecionado,
          anotacoes: _anotacoesController.text.isNotEmpty ? _anotacoesController.text : null,
          avaliacao: _avaliacao > 0 ? _avaliacao : null,
          emprestimo: emprestimo,
        );

        await _livroService.atualizar(widget.livro.id!, livroAtualizado);
        
        Navigator.of(context).pop(livroAtualizado);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Livro atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar livro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selecionarDataEmprestimo() async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: _dataEmprestimo ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (dataSelecionada != null) {
      setState(() {
        _dataEmprestimo = dataSelecionada;
      });
    }
  }

  Future<void> _selecionarDataDevolucao() async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: _dataDevolucao ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (dataSelecionada != null) {
      setState(() {
        _dataDevolucao = dataSelecionada;
      });
    }
  }

  void _mostrarDialogoEmprestimo() {
    final TextEditingController nomeController = TextEditingController(text: _nomePessoaEmprestimo);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Informações do Empréstimo'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomeController,
                  decoration: InputDecoration(
                    labelText: 'Nome da pessoa',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, informe o nome';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Text('Data do empréstimo:'),
                    SizedBox(width: 8),
                    TextButton(
                      onPressed: _selecionarDataEmprestimo,
                      child: Text(
                        _dataEmprestimo != null
                            ? '${_dataEmprestimo!.day}/${_dataEmprestimo!.month}/${_dataEmprestimo!.year}'
                            : 'Selecionar data',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Text('Data de devolução:'),
                    SizedBox(width: 8),
                    TextButton(
                      onPressed: _selecionarDataDevolucao,
                      child: Text(
                        _dataDevolucao != null
                            ? '${_dataDevolucao!.day}/${_dataDevolucao!.month}/${_dataDevolucao!.year}'
                            : 'Selecionar data',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nomeController.text.isNotEmpty) {
                  setState(() {
                    _nomePessoaEmprestimo = nomeController.text;
                    if (_dataEmprestimo == null) {
                      _dataEmprestimo = DateTime.now();
                    }
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAvaliacaoEstrelas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Avaliação:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              onPressed: _editando ? () {
                setState(() {
                  _avaliacao = index + 1.0;
                });
              } : null,
              icon: Icon(
                index < _avaliacao ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 32,
              ),
            );
          }),
        ),
        SizedBox(height: 8),
        Text(
          _avaliacao == 0 ? 'Sem avaliação' : '${_avaliacao.toInt()} estrela${_avaliacao.toInt() > 1 ? 's' : ''}',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar Livro' : 'Detalhes do Livro'),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (!_editando)
            IconButton(
              icon: Icon(Icons.edit, color: Colors.black),
              onPressed: () {
                setState(() {
                  _editando = true;
                });
              },
            ),
          if (_editando)
            IconButton(
              icon: Icon(Icons.save, color: Colors.black),
              onPressed: _isLoading ? null : _salvarAlteracoes,
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _tituloController,
                      decoration: InputDecoration(
                        labelText: 'Nome do livro',
                        border: OutlineInputBorder(),
                      ),
                      enabled: _editando,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, informe o título do livro';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _autorController,
                      decoration: InputDecoration(
                        labelText: 'Autor',
                        border: OutlineInputBorder(),
                      ),
                      enabled: _editando,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, informe o autor do livro';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _categoriaController,
                      decoration: InputDecoration(
                        labelText: 'Gênero',
                        border: OutlineInputBorder(),
                      ),
                      enabled: _editando,
                    ),
                    SizedBox(height: 24),
                    
                    _buildAvaliacaoEstrelas(),
                    SizedBox(height: 24),
                    
                    Text(
                      'Status de Leitura:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: _editando ? () {
                            setState(() {
                              _statusSelecionado = StatusLeitura.lido;
                            });
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _statusSelecionado == StatusLeitura.lido 
                                ? _statusColors[StatusLeitura.lido] 
                                : Colors.grey[300],
                            foregroundColor: _statusSelecionado == StatusLeitura.lido 
                                ? Colors.white 
                                : Colors.black,
                          ),
                          child: Text('Lido'),
                        ),
                        
                        ElevatedButton(
                          onPressed: _editando ? () {
                            setState(() {
                              _statusSelecionado = StatusLeitura.lendo;
                            });
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _statusSelecionado == StatusLeitura.lendo 
                                ? _statusColors[StatusLeitura.lendo] 
                                : Colors.grey[300],
                            foregroundColor: _statusSelecionado == StatusLeitura.lendo 
                                ? Colors.white 
                                : Colors.black,
                          ),
                          child: Text('Lendo'),
                        ),
                        
                        ElevatedButton(
                          onPressed: _editando ? () {
                            setState(() {
                              _statusSelecionado = StatusLeitura.naoLido;
                            });
                          } : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _statusSelecionado == StatusLeitura.naoLido 
                                ? _statusColors[StatusLeitura.naoLido] 
                                : Colors.grey[300],
                            foregroundColor: _statusSelecionado == StatusLeitura.naoLido 
                                ? Colors.white 
                                : Colors.black,
                          ),
                          child: Text('Não Lido'),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    
                    Row(
                      children: [
                        Checkbox(
                          value: _emprestado,
                          onChanged: _editando ? (value) {
                            setState(() {
                              _emprestado = value!;
                              if (_emprestado) {
                                _mostrarDialogoEmprestimo();
                              } else {
                                _nomePessoaEmprestimo = null;
                                _dataEmprestimo = null;
                                _dataDevolucao = null;
                              }
                            });
                          } : null,
                        ),
                        Text('Emprestado'),
                      ],
                    ),
                    
                    if (_emprestado && _nomePessoaEmprestimo != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 40, bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Emprestado para: $_nomePessoaEmprestimo'),
                            if (_dataEmprestimo != null)
                              Text('Data do empréstimo: ${_dataEmprestimo!.day}/${_dataEmprestimo!.month}/${_dataEmprestimo!.year}'),
                            if (_dataDevolucao != null)
                              Text('Data de devolução: ${_dataDevolucao!.day}/${_dataDevolucao!.month}/${_dataDevolucao!.year}'),
                            if (_editando)
                              TextButton(
                                onPressed: _mostrarDialogoEmprestimo,
                                child: Text('Editar informações'),
                              ),
                          ],
                        ),
                      ),
                    SizedBox(height: 24),
                    
                    Text(
                      'Anotações:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _anotacoesController,
                      maxLines: 5,
                      enabled: _editando,
                      decoration: InputDecoration(
                        hintText: 'Digite suas anotações sobre o livro...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 32),
                    
                    if (_editando)
                      ElevatedButton(
                        onPressed: _salvarAlteracoes,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Salvar Alterações',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}