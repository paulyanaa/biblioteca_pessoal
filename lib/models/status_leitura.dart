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

  // Converte uma string para StatusLeitura
  static StatusLeitura? fromString(String value) {
    switch (value.toLowerCase()) {
      case 'lido':
        return StatusLeitura.lido;
      case 'lendo':
        return StatusLeitura.lendo;
      case 'não lido':
      case 'naolido':
        return StatusLeitura.naoLido;
      default:
        return null;
    }
  }
}