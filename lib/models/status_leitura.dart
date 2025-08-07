enum StatusLeitura {
  lido,
  lendo,
  naoLido,
}

extension StatusLeituraExtension on StatusLeitura {
  String get label {
    switch (this) {
      case StatusLeitura.lido:
        return 'Lido';
      case StatusLeitura.lendo:
        return 'Lendo';
      case StatusLeitura.naoLido:
        return 'Não lido';
    }
  }
}
