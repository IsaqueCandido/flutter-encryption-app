import 'package:flutter/material.dart';

void main() {
  runApp(const CriptografiaApp());
}

// Tela principal com os campos e botões
class CriptografiaApp extends StatelessWidget {
  const CriptografiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Criptografia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      // Define a tela inicial
      home: const CriptografiaScreen(),
    );
  }
}

// Tela principal com os campos e botões
class CriptografiaScreen extends StatefulWidget {
  const CriptografiaScreen({super.key});

  @override
  State<CriptografiaScreen> createState() => _CriptografiaScreenState();
}

class _CriptografiaScreenState extends State<CriptografiaScreen> {
  // Controladores para capturar os textos digitados
  final TextEditingController _mensagemController = TextEditingController();
  final TextEditingController _chaveController = TextEditingController();
  List<int> _espacos = [];

  String _resultado = '';
  String _algoritmoSelecionado = 'Cifra de César';
  bool _criptografar = true;

 // Função principal: processa o texto com base no algoritmo e na chave
  void _processar() {
    String textoOriginal = _mensagemController.text;
    String chave = _chaveController.text;

    String textoSemEspacos = textoOriginal.replaceAll(' ', '');

    if (_criptografar) {
      _espacos = [];
      for (int i = 0; i < textoOriginal.length; i++) {
        if (textoOriginal[i] == ' ') {
          _espacos.add(i);
        }
      }
    }

    switch (_algoritmoSelecionado) {
      case 'Cifra de César':
        int? deslocamento = int.tryParse(chave);
        if (deslocamento == null) {
          setState(() => _resultado = 'Chave inválida! Insira um número.');
          return;
        }
        String processado = _criptografar
            ? cifraCesar(textoSemEspacos, deslocamento)
            : descriptografarCesar(textoSemEspacos, deslocamento);

        setState(() => _resultado = _criptografar ? processado : restaurarEspacos(processado));
        break;

      case 'Cifra por Transposição':
        if (!RegExp(r'^[a-zA-Z]+$').hasMatch(chave) || chave.split('').toSet().length != chave.length) {
          setState(() => _resultado = 'Chave inválida! Use apenas letras sem repetição.');
          return;
        }
        String processado = _criptografar
            ? cifraTransposicao(textoSemEspacos, chave)
            : descriptografarTransposicao(textoSemEspacos, chave);

        setState(() => _resultado = _criptografar ? processado : restaurarEspacos(processado));
        break;

      case 'Cifra por Chave Única':
        if (chave.isEmpty) {
          setState(() => _resultado = 'Insira uma chave válida.');
          return;
        }
        String processado = _criptografar
            ? cifraChaveUnica(textoSemEspacos, chave)
            : descriptografarChaveUnica(textoSemEspacos, chave);

        setState(() => _resultado = _criptografar ? processado : restaurarEspacos(processado));
        break;
    }
  }
  // Restaura os espaços nos lugares originais após descriptografia
  String restaurarEspacos(String texto) {
    StringBuffer buffer = StringBuffer();
    int textoIndex = 0;

    for (int i = 0; i < texto.length + _espacos.length; i++) {
      if (_espacos.contains(i)) {
        buffer.write(' ');
      } else if (textoIndex < texto.length) {
        buffer.write(texto[textoIndex]);
        textoIndex++;
      }
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criptografia de Mensagens'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // Dropdown para selecionar o algoritmo
              DropdownButtonFormField<String>(
                value: _algoritmoSelecionado,
                decoration: const InputDecoration(labelText: 'Algoritmo'),
                items: const [
                  DropdownMenuItem(value: 'Cifra de César', child: Text('Cifra de César')),
                  DropdownMenuItem(value: 'Cifra por Transposição', child: Text('Cifra por Transposição')),
                  DropdownMenuItem(value: 'Cifra por Chave Única', child: Text('Cifra por Chave Única')),
                ],
                onChanged: (value) => setState(() => _algoritmoSelecionado = value!),
              ),
              const SizedBox(height: 16),

              // Botão de alternância Criptografar/Descriptografar
              Center(
                child: ToggleButtons(
                  borderRadius: BorderRadius.circular(12),
                  isSelected: [_criptografar, !_criptografar],
                  onPressed: (index) => setState(() => _criptografar = index == 0),
                  children: const [
                    Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('Criptografar')),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('Descriptografar')),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Campo de texto para a mensagem
              TextField(
                controller: _mensagemController,
                maxLines: null,
                decoration: const InputDecoration(labelText: 'Mensagem'),
              ),
              const SizedBox(height: 16),

              // Campo de texto para a chave
              TextField(
                controller: _chaveController,
                decoration: const InputDecoration(labelText: 'Chave'),
              ),
              const SizedBox(height: 20),

              // Botão Executar
              ElevatedButton.icon(
                onPressed: _processar,
                icon: const Icon(Icons.lock),
                label: const Text('Executar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                ),
              ),
              const SizedBox(height: 20),

              // Área de exibição do resultado
              Text('Resultado:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              TextField(
                controller: TextEditingController(text: _resultado),
                readOnly: true,
                maxLines: null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------- CIFRAS -----------------

  String cifraCesar(String texto, int chave) {
    return texto.split('').map((c) {
      if (RegExp(r'[a-zA-Z]').hasMatch(c)) {
        int base = c.codeUnitAt(0) >= 97 ? 97 : 65;
        return String.fromCharCode((c.codeUnitAt(0) - base + chave) % 26 + base);
      }
      return c;
    }).join();
  }

  String descriptografarCesar(String texto, int chave) {
    return cifraCesar(texto, -chave);
  }

  String cifraTransposicao(String texto, String chave) {
    List<String> colunas = List.filled(chave.length, '');
    for (int i = 0; i < texto.length; i++) {
      colunas[i % chave.length] += texto[i];
    }

    // Ordena as colunas de acordo com a ordem alfabética da chave
    List<MapEntry<String, int>> ordem = chave.split('').asMap().entries
        .map((e) => MapEntry(e.value, e.key)).toList();
    ordem.sort((a, b) => a.key.compareTo(b.key));

    return ordem.map((e) => colunas[e.value]).join();
  }

  String descriptografarTransposicao(String texto, String chave) {
    int numColunas = chave.length;
    int numLinhas = texto.length ~/ numColunas;
    int sobra = texto.length % numColunas;

    // Ordena as colunas
    List<MapEntry<String, int>> ordem = chave.split('').asMap().entries
        .map((e) => MapEntry(e.value, e.key)).toList();
    ordem.sort((a, b) => a.key.compareTo(b.key));

    // Reconstrói as colunas
    List<String> colunas = List.filled(numColunas, '');
    int index = 0;
    for (var e in ordem) {
      int len = numLinhas + (e.value < sobra ? 1 : 0);
      colunas[e.value] = texto.substring(index, index + len);
      index += len;
    }

    String resultado = '';
    for (int i = 0; i < numLinhas + (sobra > 0 ? 1 : 0); i++) {
      for (var col in colunas) {
        if (i < col.length) resultado += col[i];
      }
    }

    return resultado;
  }

  String _toBinary(String text) {
    return text.codeUnits.map((c) => c.toRadixString(2).padLeft(8, '0')).join();
  }

  String _fromBinary(String binary) {
    List<String> bytes = [];
    for (int i = 0; i < binary.length; i += 8) {
      bytes.add(binary.substring(i, i + 8));
    }
    return bytes.map((b) => String.fromCharCode(int.parse(b, radix: 2))).join();
  }

  String cifraChaveUnica(String texto, String chave) {
    String binTexto = _toBinary(texto);
    String binChave = _toBinary(chave);

    // Aplica XOR bit a bit
    String resultado = '';
    for (int i = 0; i < binTexto.length; i++) {
      int bitTexto = int.parse(binTexto[i]);
      int bitChave = int.parse(binChave[i % binChave.length]);
      resultado += (bitTexto ^ bitChave).toString();
    }

    return resultado;
  }

  String descriptografarChaveUnica(String binTexto, String chave) {
    String binChave = _toBinary(chave);

    String resultado = '';
    for (int i = 0; i < binTexto.length; i++) {
      int bitTexto = int.parse(binTexto[i]);
      int bitChave = int.parse(binChave[i % binChave.length]);
      resultado += (bitTexto ^ bitChave).toString();
    }

    return _fromBinary(resultado);
  }
}
