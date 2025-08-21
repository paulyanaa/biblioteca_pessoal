import 'package:flutter/material.dart';
import '../models/livro.dart';
import '../models/emprestimo.dart';
import '../models/status_leitura.dart';
import '../services/livro_service.dart';

class AdicionarLivroScreen extends StatefulWidget {
  @override
  _AdicionarLivroScreenState createState() => _AdicionarLivroScreenState();
}

class _AdicionarLivroScreenState extends State<AdicionarLivroScreen> {
  final _formKey = GlobalKey<FormState>();
  final LivroService _livroService = LivroService();
  
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _autorController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  final TextEditingController _anotacoesController = TextEditingController();
  
  StatusLeitura _statusSelecionado = StatusLeitura.naoLido;
  bool _emprestado = false;
  DateTime? _dataEmprestimo;
  String? _nomePessoaEmprestimo;
  
  final Map<StatusLeitura, Color> _statusColors = {
    StatusLeitura.lido: Colors.green,
    StatusLeitura.lendo: Colors.blue,
    StatusLeitura.naoLido: Colors.grey,
  };

  @override
  void dispose() {
    _tituloController.dispose();
    _autorController.dispose();
    _categoriaController.dispose();
    _anotacoesController.dispose();
    super.dispose();
  }

  Future<void> _salvarLivro() async {
    if (_formKey.currentState!.validate()) {
      try {
        Emprestimo? emprestimo;
        if (_emprestado && _nomePessoaEmprestimo != null && _nomePessoaEmprestimo!.isNotEmpty) {
          emprestimo = Emprestimo(
            nomePessoa: _nomePessoaEmprestimo!,
            dataEmprestimo: _dataEmprestimo ?? DateTime.now(),
          );
        }

        final novoLivro = Livro(
          titulo: _tituloController.text,
          autor: _autorController.text,
          categoria: _categoriaController.text,
          status: _statusSelecionado,
          anotacoes: _anotacoesController.text.isNotEmpty ? _anotacoesController.text : null,
          emprestimo: emprestimo,
        );

        await _livroService.adicionar(novoLivro);
        
        Navigator.of(context).pop(true);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Livro adicionado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar livro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selecionarDataEmprestimo() async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (dataSelecionada != null) {
      setState(() {
        _dataEmprestimo = dataSelecionada;
      });
    }
  }

  void _mostrarDialogoEmprestimo() {
    final TextEditingController nomeController = TextEditingController();
    
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Livro'),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
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
              ),
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
                    onPressed: () {
                      setState(() {
                        _statusSelecionado = StatusLeitura.lido;
                      });
                    },
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
                    onPressed: () {
                      setState(() {
                        _statusSelecionado = StatusLeitura.lendo;
                      });
                    },
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
                    onPressed: () {
                      setState(() {
                        _statusSelecionado = StatusLeitura.naoLido;
                      });
                    },
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
                    onChanged: (value) {
                      setState(() {
                        _emprestado = value!;
                        if (_emprestado) {
                          _mostrarDialogoEmprestimo();
                        } else {
                          _nomePessoaEmprestimo = null;
                          _dataEmprestimo = null;
                        }
                      });
                    },
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
                        Text('Data: ${_dataEmprestimo!.day}/${_dataEmprestimo!.month}/${_dataEmprestimo!.year}'),
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
                decoration: InputDecoration(
                  hintText: 'Digite suas anotações sobre o livro...',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _salvarLivro,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Salvar Livro',
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